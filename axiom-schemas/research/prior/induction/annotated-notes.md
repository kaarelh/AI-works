# Learning the induction rule from motive-annotated examples (Track A)

Scripts and outputs: `/tmp/claude-0/-home-user-AI-works/c4435474-536f-5a96-a73c-7d0c5ea93659/scratchpad/induction/`
(`run_all.sh` re-runs everything; each `aN_*.py` writes `aN_*.out`). The term library and `lgg_list` are the
paper's T1 code (`research/theory/T1-code/terms.py`). Status labels: **proved** (full proof here or a direct
application of a cited paper result), **computed** (script run, output quoted), **conjecture**, **known**.

---------------------------------------------------------------------------------------------------------

## 0. The answer in brief

* **Algorithm.** Record each induction used by the community as a ground step term that *contains its motive*,
  canonicalize the record, discard records whose substitution side-facts are false, anti-unify (Plotkin lgg) the
  records cited as "induction", and accept a query iff it matches the lgg and its substitution side-facts are true.
  Add a per-tag noise budget (trimmed lgg) if records can be wrong, and pass the learned schema (and any fallacy tag,
  e.g. "step by 2") to the two-tier audit.
* **Encodings.** Three equivalent first-order encodings are analysed: the paper's Sub encoding (3 metavariables
  with the induction variable fixed, 4 if it varies), a Lean-style encoding with the motive as an unreduced λ-redex
  (1 metavariable, needs trusted β), and a Metamath-style implicit-substitution encoding (4 metavariables plus freshness
  guards, premises are provable biconditionals).
* **Headline facts** (Sub encoding, x fixed):
  1. A finite set of genuine instances is an anchor iff the motives do not all have the same main symbol and at
     least one has x free. Two instances suffice; one never does. If x is a metavariable you also need two distinct
     induction variables; with trusted FOL, α-normalizing to x makes this unnecessary.
  2. With the usage law 60% `=`, 20% `→`, 10% `∀`, 10% other, the paper's constants are c = 9, ρ = 0.4, giving
     N = 18 for δ = 0.01. The exact requirement is N = 10, against a lower bound of 9.02.
  3. The verifier is sound at every time, for motives of any size. It is exact once an anchor is seen. Improper
     instances (false Sub premise, ill-formed motive) are harmless because Sub judgments can only be W-checked leaves.
  4. Escalation cost from one example `x+0=x`: the paper's bound gives 39. A new "tuple gap" bound gives 17, which is
     tight if improper queries count. If only genuine queries count, the worst chain found is 10.
  5. The Metamath encoding is a first-order pattern only together with freshness guards. Among the guards
     {x∉ψ, x∉χ, x∉θ, y∉φ, x≠y}, a subset is sound iff it contains y∉FV(φ) and also contains x∉FV(χ) or x∉FV(θ).
     Learning guards from canonical uses also keeps the spurious guard y∉FV(ψ) forever.
  6. "Step by 2" behaves differently depending on how it is cited.
     * Cited as induction under the per-tag one-schema class, it is sporadic noise. Trimming removes it iff its rate
       is below min(0.4, q)·β, a sharp threshold for this usage law.
     * Under its own tag it is identified by the same anchors.
     * With only Δ0 truth and the empty position, the audit can blame it only as a bag {step-by-2, Q1, Q2}. This is
       proved: {step-by-2} alone has no refutation at any depth.
     * With Q1, Q2 asserted, trusted, or decided by the world, blame is a singleton.

---------------------------------------------------------------------------------------------------------

## 1. Setting, data and encodings

First-order arithmetic: terms over `0, S, +, ·` and object variables; formulas over `=, <, ¬, ∧, ∨, →, ∀, ∃`.
Classical FOL with equality is trusted (`T_trust`). In step terms, object variables are constants of the signature
Ω, as in the paper. `rt(t)` is the root symbol, `FV` the free variables, `φ[t/x]` capture-avoiding substitution.

**(E1) Sub encoding.** This is the paper's App. twotier (e), checked by T7 `ind_sub_lgg.py`.
`Sub(φ,x,t,ψ)` is a W-decidable judgment, with `W(Sub(φ,x,t,ψ)) = 1` iff all of the following hold:
* φ is a well-formed formula;
* x is an object variable;
* t is a term, free for x in φ;
* ψ = φ[t/x].

A genuine instance with motive φ and induction variable v is

    ind(φ,v) = st( Sub(φ,v,0,φ[0/v]),  Sub(φ,v,Sv,φ[Sv/v]),  (φ[0/v] ∧ ∀v(φ → φ[Sv/v])) → ∀v φ ).

The patterns are `σ_x = ind_raw(P,x,A,B)` (x fixed; metavariables P, A, B) and `σ = ind_raw(P,X,A,B)` (X a
metavariable). Substituting `0` or `Sv` for `v` never captures, since a free occurrence of v is not under a v-binder.
So the capture clause of W is vacuous here.

**(E2) Lean-style redex encoding.** The motive is recorded as `M = lam(x,φ)` with x α-normalized (or de Bruijn).
The step has no premises and conclusion `(app(M,0) ∧ ∀n(app(M,n) → app(M,Sn))) → ∀n app(M,n)`. β-conversion
`app(lam(x,φ),t) ⇝ φ[t/x]` is a trusted step. The pattern `σ_λ` has one metavariable P, with `M = lam(x,P)`.

**(E3) Metamath-style encoding**, after set.mm `finds`/`nnind`:

    st( ⊢x=0→(φ↔ψ),  ⊢x=y→(φ↔χ),  ⊢x=Sy→(φ↔θ),  ⊢ψ,  ⊢χ→θ,  ⊢φ )

The metavariables are φ, ψ, χ, θ, plus X and Y if the variables vary. The encoding needs freshness guards (§3, P9).
The *canonical* genuine instance is ψ = φ[0/x], χ = φ[y/x], θ = φ[Sy/x], with y not occurring in φ.

**What the formal systems record (checked).**
* **Lean 4.32.0** (local toolchain; `lean/NatRec.lean`, `lean/NatRec.out`):
  * `#check @Nat.rec` gives
    `{motive : Nat → Sort u_1} → motive Nat.zero → ((n : Nat) → motive n → motive n.succ) → (t : Nat) → motive t`.
    So the motive is an *implicit* binder at the surface, not an explicit one as the brief says.
  * The elaborated term of `induction n` on `n + 0 = n` is `@Nat.recAux (fun n => n + 0 = n) ... n`. The kernel term
    therefore records the motive explicitly, as a λ (the `induction` tactic uses `Nat.recAux`, not `Nat.rec`).
* **Metamath set.mm** (`develop` branch, downloaded 2026-10-04; excerpt in `setmm_finds_nnind_excerpt.txt`).
  `finds` has hypotheses
  `finds.1 |- ( x = (/) -> ( ph <-> ps ) )`, `finds.2 |- ( x = y -> ( ph <-> ch ) )`,
  `finds.3 |- ( x = suc y -> ( ph <-> th ) )`, `finds.4 |- ( x = A -> ( ph <-> ta ) )`, `finds.5 |- ps`,
  `finds.6 |- ( y e. _om -> ( ch -> th ) )`, conclusion `|- ( A e. _om -> ta )`, and distinct-variable conditions
  `$d x y, x A, x ps, x ch, x th, x ta, y ph`. `nnind` is the same over NN, with `x = 1` and `x = ( y + 1 )`.
  In set.mm, `$d x ps` means that x does not occur in ψ at all. The brief's "x = (/) -> ( ph <-> ps )" is confirmed.
  I did not check how individual proofs in set.mm encode the substitutions. My belief is that the proof records the
  wff substitutions for ph, ps, ch, th, ta through their syntax-construction steps, but I have not verified it.

---------------------------------------------------------------------------------------------------------

## 2. The algorithm LEARN-IND (per tag)

Input: records D cited "induction", each canonicalized to an encoding (E1, E2 or E3); noise budget e ≥ 0.

1. **Canonicalize.**
   * Premises go in a fixed order. In E1, sort the two Sub premises by their term argument, `0` before `Sx`.
   * Conjuncts go in a fixed order (base first).
   * Optionally α-normalize the induction variable to x: rename x away inside the motive, then rename v to x.
     This is sound under trusted FOL (P4).
2. **W-filter.** In E1, drop records whose Sub premises are W-false; in E3 with NF premises, drop those with false NF
   premises. Such records are useless as steps (P6) and dropping data never hurts soundness.
3. **Generalize.**
   * If e = 0, set `L = lgg(D)` (Plotkin–Reynolds anti-unification, T1 `lgg_list`).
   * If e > 0, accept the trimmed version space `⋂_{|E|=e} inst(lgg(D∖E))` (paper Thm imitation:trimmed). Matching
     against each of the at most C(|D|,e) trimmed lggs decides it.
4. **Verify.** Accept q iff `q ∈ inst(L)` (first-order matching, linear time) and q's Sub premises are W-true.
   Reject q if a Sub premise is W-false (no derivation can use it). Otherwise escalate.
   This is the cautious verifier of the guarded single-schema class with the guard ψ_Sub = "all Sub premises W-true"
   (paper Lemma setting:guard).
5. **Audit.** In the two-tier learner (paper Def twotier:ttl), the learned schema of every tag, including latent
   fallacy tags such as step-by-2, goes through the audit.

Diagnostic: by P1/P2, the data have identified the rule iff they contain two motives with different main symbols, one
with the induction variable free (plus two distinct induction variables if not α-normalized). In E2 it suffices that
two motives have different main symbols.

---------------------------------------------------------------------------------------------------------

## 3. Propositions

### P0 (reduction to the metavariable tuple) — proved; computed check

**Statement.** Let σ have metavariables x₁..x_v, each occurring at least once, and let `tup` be a fresh v-ary symbol.
For ground instances `t_j = σθ_j`:
* `lgg(t_1..t_n) = ση` with `tup(ηx₁..ηx_v) = lgg(tup(θ_j x₁..θ_j x_v) : j≤n)`, with the same metavariable names.
* For schemas of this form, `ση ⪯ ση'` iff `tup(η) ⪯ tup(η')`.

Hence strict lgg chains of σ-instances correspond one to one to strict lgg chains of tuples.

**Proof.**
* The claim in the paper's proof of Lemma setting:recover gives `A(t_1..t_n) = ση` with `η(x_i) = A(c_{x_i})`, where
  `c_{x_i} = (θ_1x_i..θ_nx_i)` and one metavariable table is shared. Anti-unifying the tuples applies the same
  recursion to the same columns.
* (⇐) If `tup(η) = tup(η')ρ`, then `ηx_i = (η'x_i)ρ` for all i, so `ση = (ση')ρ`.
* (⇒) If `ση = (ση')ρ`, take an occurrence position π_i of x_i in σ. The subterm of ση at π_i is ηx_i. The subterm
  of (ση')ρ at π_i is (η'x_i)ρ, because π_i lies in the skeleton σ. So `tup(η) = tup(η')ρ`. ∎

**Evidence.** `a4_cost.py`: on 3000 random 4-chains of genuine instances, the strictness of the σ-chain and of the
tuple chain agree, and `tup(lgg) = lgg(tuples)`, with 0 mismatches.

### P1 (anchors, induction variable fixed) — proved; computed exhaustively on pairs

**Statement.** Let T = {ind(φ₁),…,ind(φ_n)} be genuine, n ≥ 1, x fixed. The following are equivalent:
* (i) T is an anchor for inst(σ_x) in the per-tag single-schema class H₁; equivalently, for the genuine set G in the
  guarded class of step 4;
* (ii) lgg(T) ≡ σ_x;
* (iii) the main symbols rt(φ_j) are not all equal, **and** x ∈ FV(φ_j) for some j.

So the minimum anchor size is 2, and any two instances with different main symbols, at least one non-vacuous, are an
anchor (e.g. `x+0=x` and `¬(Sx=0)`, or `x+0=x` and the vacuous `¬(0=S0)`). One instance never is, since its lgg is
ground.

**Proof.**
* *Fact (a).* `rt(φ[t/x]) = rt(φ)` for every formula φ, because a formula's root is a predicate, connective or
  quantifier and substitution acts only at term leaves.
* *Fact (b).* `φ[0/x] = φ` iff `φ[Sx/x] = φ` iff `φ[0/x] = φ[Sx/x]` iff x ∉ FV(φ). If x has a free occurrence at
  position π, the three terms carry x, 0 and Sx at π, which are pairwise distinct. Otherwise all three equal φ.
* *(ii)⟺(iii).* Apply Lemma setting:recover to θ_j = {P↦φ_j, A↦φ_j[0/x], B↦φ_j[Sx/x]}.
  * By (a), the witness events (R) at P, A and B are one event: the main symbols are not all equal.
  * By (b), the events (D) for the pairs PA, PB and AB are one event: some φ_j has x free.
* *(i)⟺(ii).* H₁∪{∅} is intersection-closed, and the cautious verifier accepts inst(lgg T) (Lemma
  imitation:cautious(d)). By Thm imitation:anchor(a) and its proof, T is an anchor iff inst(lgg T) = inst(σ_x). Since
  lgg T ⪯ σ_x and a proper specialization has strictly fewer instances (Ω has two or more constants), this holds iff
  lgg T ≡ σ_x.
* *Guarded class.* (⇐) is clear. (⇒): if (iii) fails, one of two things happens.
  * If all roots equal f, then ηP has root f, and a genuine instance with a motive of another root is missed.
  * If all motives are vacuous, then ηP = ηA = ηB (equal columns get equal anti-unifiers), and every non-vacuous
    genuine instance is missed. ∎

**Evidence** (`a1_anchor.py`, universe of 324 motives of size ≤ 5):
* all 52,326 pairs agree with (ii)⟺(iii), with 0 mismatches; 30,512 of the pairs are anchors;
* 20,000 random 3-sets and 20,000 random 4-sets give 0 mismatches.

### P2 (anchors, induction variable a metavariable X) — proved; computed

**Statement.** For genuine T = {ind(φ_j, v_j)}, lgg(T) ≡ σ iff all three of the following hold:
* (iii-a) the main symbols are not all equal;
* (iii-b) v_j ∈ FV(φ_j) for some j;
* (iii-c) the v_j are not all equal.

The minimum anchor size is still 2, e.g. `x+0=x` on x and `¬(Sy=0)` on y. The extra requirement is (iii-c). If every
datum inducts on the same v, the lgg is exactly the v-fixed rule. That rule is sound and complete up to α-renaming
(P4).

**Proof.** Lemma setting:recover with the four columns.
* (R) at X: the constants v_j are not all equal.
* (D) for pairs containing X always holds, since an object variable never equals a formula.
* (R) and (D) for P, A, B are as in P1, with v_j in place of x.
* In ind(φ,v), X occurs inside S(X) and as a binder. Its columns `(S(v_j))` have uniform root S and give S(z_X), so
  no new condition arises. ∎

**Evidence** (`a1_anchor.py`): 60,000 random pairs and 20,000 random triples with v ∈ {x,y}, 0 mismatches.

### P3 (failure modes) — computed; the repairs proved

The merging behaviour of anti-unification ("equal tuples get equal metavariables") can only merge the P, A, B
columns, and it does so exactly when all motives are vacuous. A merge of X with a formula column is impossible. No
other column coincidences exist, because all other positions of σ_x are constants. The following were checked in
`a1_anchor.py` and `a6_noise_fallacy.py`.

1. **Same main symbol only** (three `=` motives). The lgg is
   `st(Sub(eq(v0,v1),x,0,eq(v2,v3)), Sub(eq(v0,v1),x,S(x),eq(v4,v5)), …)`: induction for equational motives only.
   Sound but incomplete.
2. **Vacuous only.** The lgg is `st(Sub(v0,x,0,v0),Sub(v0,x,S(x),v0),(v0∧∀x(v0→v0))→∀x v0)`. Sound but incomplete.
3. **Premise order varies** (some records list the S-premise first). The lgg is
   `st(Sub(v0,x,v1,v2),Sub(v0,x,v3,v4),(v5∧∀x(v0→v6))→∀x v0)`, which is **not** below σ_x. The search found an instance
   with W-true Sub premises and a false conclusion:
   `P := (SSy = 0)`, conclusion `(0 = y+y) ∧ ∀x(SSy=0 → SSy=0) → ∀x(SSy = 0)`, false at y = 0.
4. **Conjunct order varies.** The lgg is `st(Sub(v0,x,0,v1),Sub(v0,x,S(x),v2),(v3∧v4)→∀x v0)`, which is unsound. With
   `P := (y+y < x)`, the conclusion `(y+y<x) ∧ (0+0=y) → ∀x(y+y<x)` is false at y = 0, x = 1.
5. **Canonicalization repairs 3 and 4** (computed: the lgg of a mixed-order anchor after canonicalization is σ_x).
   *Proof:* canonicalization maps every order variant of a genuine record to ind(φ). Any fixed Sub argument order is
   fine, and the two Sub premises are always distinguishable by their term argument (0 vs Sx). Unordered premise
   *sets* would need anti-unification modulo AC, which is finitary rather than unitary; the paper remarks this, and
   Alpuente–Escobar–Espert–Meseguer (Inf. & Comput. 2014) treat equational generalization, though I am unsure of the
   exact reference.
6. **A record whose conclusion's A differs from its Sub premise's A** (shape-breaking). The lgg splits A into two
   metavariables and becomes unsound. Computed example:
   `P := ∀x(0=y)`, conclusion `(x+0=x) ∧ ∀x(P→P) → ∀x P`, false at y = 1.

### P4 (α-completeness of the x-fixed rule under trusted FOL) — proved

**Statement.** If FOL is trusted, the conclusion of every genuine induction on any variable v is derivable from one
x-fixed instance by trusted steps. Derivationally, identifying σ_x is as good as identifying σ. At the step level, a
query "induction on y" is still escalated unless it is expanded as a macro.

**Proof.** Let ψ be a motive on v ≠ x, and let u be a fresh variable.
1. Let ψ₁ be ψ with its bound x renamed apart and its free x (a parameter) renamed to u. Let φ := ψ₁[x/v]; x is free
   for v because x does not occur in ψ₁.
2. ind(φ) concludes `C(φ,x)`. This is α-equivalent to `C(ψ₁,v)`, because φ[0/x] = ψ₁[0/v] and the bound x can be
   renamed back to v.
3. Theorems are closed under substitution of a variable for a free variable (∀I then ∀E; x does not occur in
   C(ψ₁,v)). So renaming u to x gives `C(ψ,v)`. Every step used is FOL-valid. ∎

### P5 (coupon-collector rate, concrete constants) — proved (constants and exact formula); computed (numbers, simulation)

Usage law: main symbol `=` 0.6, `→` 0.2, `∀` 0.1, other 0.1 (also split as five symbols at 0.02 each).
Non-vacuity rate q ≥ 0.4. Data are i.i.d.

**x fixed** (v = 3).
* *Constants.* `c = 2v + C(v,2) = 9`. `ρ_P = ρ_A = ρ_B = 0.4` (best split {=} vs. rest; no subset of the remaining
  mass 0.4 gets closer to 0.5). `r_PA = r_PB = r_AB = q`, so `ρ = min(0.4, q) = 0.4`.
* *Thm imitation:coupon* (k = 1, π = 1): `N ≥ ln(c/δ)/ρ = ln 900 / 0.4 = 17.006`, so **N = 18** at δ = 0.01.
* *Refined union bound.* By P1 the three (R) events coincide and the three (D) events coincide, so
  `P(fail) ≤ 2(0.6)^N + (1−q)^N`, giving **N = 11**.
* *Exact.* By P1, failure ⟺ (all roots equal) ∨ (all vacuous). If the root and vacuity are independent,
  `P(fail) = 1 − (1 − Σ_f p_f^N)(1 − (1−q)^N)`. The smallest N with P(fail) ≤ 0.01 is **N = 10**
  (P(fail) is 0.01008 at N = 9 and 0.00605 at N = 10, for both readings of "other").
* *Necessity.* `P(fail) ≥ 0.6^N` (Thm coupon, lower bound), so N ≥ 9.015. The exact value 10 is the first integer
  above this lower bound.
* *Simulation* (`a2_coupon.py`, T1 lgg on random Sub-encoded records, 3000 trials):

  | N | 4 | 6 | 8 | 9 | 10 | 12 |
  |---|---|---|---|---|---|---|
  | empirical P(fail), q=1 | .126 | .048 | .017 | .011 | .0067 | .0017 |
  | exact formula | .131 | .047 | .017 | .010 | .0060 | .0022 |

**X a metavariable** (v = 4), induction variable n 70%, x 20%, k 10%.
* *Constants.* c = 14, ρ_X = 0.3, ρ = 0.3. Thm coupon gives N = 25.
* *Exact* (independence): **N = 14**. Simulation at N = 14 gives 0.0090, against 0.0076 from the formula.

**Other encodings.**
* E2: v = 1, c = 2, ρ = 0.4, so Thm coupon gives N = 14; the exact value is 10.
* E3 (x, y fixed): c = 14, so Thm coupon gives N = 19; the exact value is 10 (all witness events coincide).

If induction is a fraction π of all tagged steps, divide by π. For example, at π = 5% Thm coupon needs 340 steps.

### P6 (soundness before identification, exactness after, realizability) — proved

1. **Realizability.** The target `R* = inst(σ_x)` lies in H₁, and genuine data lie in it. inst(σ_x) also contains
   *improper* instances (computed in `a3_realizability.py`):
   * false Sub premise, e.g. `ind_raw(x=0, x, 0=0, 0=0)`, whose conclusion `(0=0 ∧ ∀x(x=0→0=0)) → ∀x(x=0)` is false;
   * P a term (`S0`);
   * P a Sub judgment.

   The genuine set G is **not** H₁-realizable. If G = inst(τ), then τ ⪰ lgg(anchor) ≡ σ_x, so inst(σ_x) ⊆ G, which
   contradicts the existence of improper instances.
2. **Leaf lemma.** Let R and T_trust be step sets none of which concludes a Sub judgment, and let B be a base whose Sub
   judgments are W-true. Then every Sub judgment in an (R ∪ T_trust)-derivation from B is a leaf, hence W-true. So
   `Cl_{R∪T}(B) = Cl_{R_W∪T}(B)`, where `R_W = {s∈R : Sub premises of s W-true}`.
   *Proof:* a non-leaf node is the conclusion of a step in R ∪ T, so it is not a Sub judgment. ∎
   The hypothesis holds for target schemas and for every lgg ⪯ σ_x. For an over-general learned schema (e.g.
   `st(z)` in untagged or noisy settings) it can fail. The guard "reject steps concluding a W-false Sub judgment"
   restores it.
3. `inst(σ_x) ∩ SubTrue = G`. Truth of `Sub(P,x,0,A)` forces P to be a formula and A = P[0/x], and truth of
   `Sub(P,x,Sx,B)` forces B = P[Sx/x]. Computed: of 144,150 sampled instances, 173 have W-true Sub premises, and all
   173 equal ind(P). With X a metavariable, W also forces X to be an object variable.
4. **Guarded class.** `G = inst(σ_x, {ψ_Sub})`. With Φ = {ψ_Sub}, Lemma setting:guard says the cautious verifier
   accepts `inst(lgg D) ∩ SubTrue`, since every genuine datum satisfies ψ_Sub.
   * *Before identification:* it accepts only genuine inductions, for motives of every size, deterministically and
     against every prover (Lemma imitation:cautious(a)).
   * *After an anchor (P1/P2):* it accepts exactly G, for motives of every size and whatever the data law
     (Cor imitation:ood). The reasoner then derives exactly `Cl_G`.
   * It never accepts a step-by-2 instance or any other non-instance of σ_x.
5. **Which target to measure on.** Measure on G (well-formed, Sub-true instances), using the W-guarded verifier.
   Improper instances never enter a derivation (leaf lemma), so accepting or rejecting them is immaterial for
   soundness. Measuring on inst(σ_x) is consistent too, but it counts escalations on useless queries (17 instead of 10
   in P7).

### P7 (escalation cost before identification) — proved (a)–(c); computed (d); conjecture (e)

Write `m = |φ₀|` and `k` = number of free occurrences of x in φ₀. `|ind(φ)| = 15 + 8m + 2k` (computed over the
whole universe), `μ(σ_x) = 20`, and `μ(σ) = 19` when x is a metavariable.

**(a) Paper bound** (Thm caution:single(i)), one example s₀: `el ≤ μ(s₀) − μ(σ_x) = 8m + 2k − 5` (x fixed), and
`8m + 2k − 4` (X a metavariable). For `φ₀ = (x+0 = x)`: **39** (respectively 40).

**(b) Tuple-gap bound** (new, general).
* *Statement.* For any σ whose metavariables all occur, and nonempty P₀ ⊆ inst(σ) with lgg P₀ = ση₀,
  `el(H₁,σ|P₀) ≤ μ(tup η₀) − 1 = Σ_i|η₀x_i| − |vars η₀|`. This is at most the paper bound
  `Σ_i occ_i(|η₀x_i|−1) + v − |vars η₀|`, with equality iff every non-trivially instantiated metavariable occurs once.
* *Proof.* Each escalated honest query strictly generalizes the lgg (Lemma caution:h1). By P0 the tuple lggs then
  form a strict chain ending ⪯ tup(x₁..x_v), whose μ is 1. Apply the rank lemma. ∎
* *Value for one example:* `3m + k` (x fixed), `3m + k + 1` (X meta). For `x+0=x`: **17** (respectively 18).
* *Other encodings:*
  * E2 bound: m, i.e. **5**; paper bound 17.
  * E3 tuple bound: 4m + k, i.e. **22**; paper bound 48 (`a5b_mm_cost.out`).

**(c) Tightness of (b) for R* = inst(σ).** Assume infinitely many constants (object-variable names suffice). For every
ground s₀ = σθ₀, some honest prover with queries in inst(σ) forces exactly Σ_i|θ₀x_i| escalations from **every**
0-sound verifier for H₁.
* *Chain.* Generalize tup(θ₀) one symbol at a time: first each leaf occurrence becomes a fresh metavariable, then,
  bottom-up, each node whose children are distinct linear metavariables becomes a metavariable. Each step lowers μ by
  exactly 1.
* *Realizing each step.* Query `q = g_{i+1}` with its metavariables replaced by distinct fresh constants. Then
  `lgg(g_i, q) ≡ g_{i+1}`: columns at the variable positions of g_{i+1} have a fresh constant, hence mixed roots, and
  equal columns arise exactly at the same variable. Hence q ∉ inst(g_i). Since inst(g_i) ∈ H₁ contains the history,
  q must be escalated or rejected.
* *Computed* for x+0=x: 17 escalations forced, all 17 queries improper, final lgg ≡ σ_x.

**(d) Genuine-only provers** (the W-guarded verifier of P6.4). These are exact longest chains of strictly increasing
lggs within finite motive universes, so they are lower bounds on the true worst case (`a4*_*.py`).
* For `x+0=x`: **10**, the same in universes of motive size ≤ 6, ≤ 7 and ≤ 8 (21,923 motives).
  The witness query motives are `x+x=x, x+y=x, x+0=Sx, x+0=S0, x+0=0, Sx+0=0, S0+0=0, 0+0=0, 0=0, 0<0`.
* Other starting motives (universe size ≤ 7):

  | motive | `x=0` | `0=0` | `x=x` | `x<Sx` | `Sx=x` | `¬(Sx=0)` | `x+y=y+x` | `0+0=0` | `x+x=x` | `¬(x=0)` | `SSx=0` |
  |---|---|---|---|---|---|---|---|---|---|---|---|
  | longest chain | 6 | 5 | 7 | 9 | 9 | 9 | 12 | 8 | 11 | 7 | 10 |
  | tuple bound 3m+k | 10 | 9 | 11 | 14 | 14 | 16 | 23 | 15 | 18 | 13 | 16 |

  All are strictly below the tuple bound. No clean closed form fitted; all values are ≤ 2m + k.
* In E2 every motive is genuine, and the bound m = 5 is attained with genuine queries (computed: 5 forced).

**(e) Conjecture.** The universe-limited values in (d) are the true maxima. For x+0=x the worst case for the
W-guarded verifier from one example is 10.

From no data the paper gives ≤ N + 1 escalations on steps of size ≤ N (Thm caution:single(ii)), plus at most |Φ| = 1
for the guard (Rem imitation:guards).

### P8 (Lean-style redex encoding E2) — proved; computed

* *Anchors.* `lgg(T) ≡ σ_λ` iff the motive main symbols are not all equal. **Vacuity is irrelevant**: there are no
  A/B metavariables, so no (D) events. Two vacuous motives with different roots already form an anchor.
  *Proof:* Lemma setting:recover with v = 1.
  *Computed:* all 52,326 pairs, 0 mismatches.
* *Soundness.* Every instance with a well-formed motive body is the β-expanded PA induction axiom for φ. β-normalizing
  gives exactly the E1 conclusion (computed). There are no improper instances apart from ill-formed motives, which
  type checking excludes.
* *Costs.* c = 2 and ρ = 0.4 give N = 14 by the theorem and 10 exactly. From one example the escalation bound is m, and
  it is tight with genuine queries.
* *Comparison.* E2 is the cheapest encoding on every count. Its price is that the reasoner needs β-conversion as a
  trusted step, which is what Lean's kernel does through definitional equality.

### P9 (Metamath-style encoding E3) — proved; computed

(a) **Pattern.** `σ_MM` is a first-order pattern with metavariables φ, ψ, χ, θ (x, y fixed), plus X, Y if they vary.
Its premises are ⊢-judgments, not decidable facts.

(b) **Guards are needed: characterization.** Read "v∉M" as "v not free in M". Within F = {x∉ψ, x∉χ, x∉θ, y∉φ, x≠y}, a
guard set Ψ makes every instance sound iff **y∉φ ∈ Ψ and (x∉χ ∈ Ψ or x∉θ ∈ Ψ)**. Here "sound" means: in every model of
PA, in fact in every structure satisfying the induction axiom for φ, the universal closures of the premises imply that
of the conclusion. So the rule is a derived rule of PA.

*Sufficiency.* Fix the parameters by a valuation v and let `X = {a : φ(v[x:=a])}`.
* 0 ∈ X: at x = 0, H1 gives φ ↔ ψ, and H4 gives ψ everywhere.
* a ∈ X ⇒ a+1 ∈ X, using w = v[x:=a, y:=a] and w' = v[x:=a+1, y:=a]:
  1. y∉φ gives φ(w), and H2 at w gives χ(w).
  2. If x∉χ, then χ(w') = χ(w), and H5 at w' gives θ(w'). If instead x∉θ, then H5 at w gives θ(w), and
     θ(w') = θ(w).
  3. H3 at w' (where x = Sy) gives φ(w'), hence a+1 ∈ X, using y∉φ again.
* X is definable, so induction gives X = everything.
* If X and Y are metavariables with X ≡ Y, then y∉φ means x∉φ, and H1 with H4 gives φ directly. So x≠y is never
  needed. ∎

*Necessity.* Two counterexamples have PA-provable premises and conclusions false in ℕ (computed in
`a5_metamath.py`):
* `φ = ¬(x=SSy)`, `ψ = ¬(0=SSy)`, `χ = ¬(y=SSy)`, `θ = ¬(Sy=SSy)` violates only y∉φ, and concludes `¬(x=SSy)`.
* `φ = (x=0)`, `ψ = (0=0)`, `χ = θ = (x=0)` violates only x∉χ and x∉θ, and concludes `x=0`.

A randomized bounded search found no counterexample for {y∉φ, x∉χ} or {y∉φ, x∉θ}. It found counterexamples for
{x∉ψ, x∉χ, x∉θ} and for {y∉φ, x∉ψ}. So set.mm's DV list, transcribed to PA with "not free", is sound but not minimal:
x∉ψ and x≠y are redundant. This says nothing about why set.mm, which uses "does not occur", includes them.

(c) **Anchors for canonical data.**
* `lgg ≡ σ_MM` iff the main symbols differ and some motive has x free.
  *Proof:* the four columns φ, φ[0/x], φ[y/x], φ[Sy/x] share their roots, and they are pairwise distinct iff x is
  free, because 0, y, Sy, x are pairwise distinct.
  *Computed:* all 52,326 pairs, 0 mismatches.
* With X, Y metavariables, the X column and the Y column must also each be non-constant (40,000 random pairs, 0
  mismatches).

(d) **Guard learning keeps a spurious guard.**
* Lemma setting:guard learns the guards true on all data. Over the family {v∉M : v∈{X,Y}, M∈{φ,ψ,χ,θ}} ∪ {X≠Y},
  canonical data give: set.mm's five guards plus **Y∉FV(ψ)** (computed).
* *Proof that the spurious guard persists:* canonical ψ = φ[0/x] with y∉φ, so y ∉ FV(ψ).
* So canonical usage never anchors the full set.mm rule in this guarded class. The learner converges to a sound
  sub-rule that is complete on canonical uses. A single non-canonical use (e.g. ψ := φ[0/x] ∧ y=y) removes the
  spurious guard (computed).

(e) **NF-premise variant.** Record the minimal guards as W-decidable premises `NF(x,χ), NF(y,φ)`. The result is a
plain first-order pattern; an anchor pair recovers it (computed). Improper instances, i.e. those with a false NF
premise, are harmless by the leaf lemma.

(f) **What validity means.** An E3 step is valid iff it is a sound derived rule. It is not a "decidable side-fact"
rule, so there are no improper instances: every guard-satisfying instance is sound whatever ψ, χ, θ are, and
simplified, non-canonical ψ are legitimate. Using a step requires *deriving* its premises:
* H1–H3 by trusted equality logic: Leibniz, `⊢ x=t → (φ ↔ φ[t/x])` for t free for x;
* H4 and H5 by the reasoner.

### P10 (noise) — proved (from the paper's theorems); computed

* **(a) Taxonomy.**
  * *Shape-consistent but improper records* (wrong A or B, used consistently) are still instances of σ_x. They do not
    change the lgg, and W filters them (computed: lgg = σ_x with such a record included).
  * *Shape-breaking records* (step-by-2 cited as induction; conclusion inconsistent with the Sub premise; another
    rule mis-tagged) collapse the lgg into an unsound schema. One step-by-2 record turns `S(x)` into `S(v2)`, and
    instantiating v2 := 0 gives a false instance with W-true premises (computed).
* **(b) Trimmed verifier.** Thm imitation:trimmed applies. With budget e it is exact when the genuine data are
  e-robustly generic: more than e examples with main symbol ≠ f for every f, and more than e non-vacuous examples.
  Computed:
  * 5 genuine records + 1 step-by-2 at e = 1: exact;
  * 2 errors at e = 1: not exact; at e = 2: exact.
  * Robust genericity is sufficient, not necessary. With genuine roots (=, =, ¬) plus step-by-2 at e = 1, the result
    is exact if the error's motive has root ¬, and not exact if it has root =.
* **(c) Sharp i.i.d. threshold for this usage law.** Write β for the rate of genuine induction records and α for the
  rate of shape-breaking errors under the tag.
  * *Sufficient* (Thm imitation:iidnoise): α < ρβ = min(0.4, q)·β (with margin Δ > 0).
  * *Necessary* (Cor imitation:necessity with f = '='): 0.4β > α and qβ > α.
  * Here m = 0.6 ≥ 1/2, so ρ_P = 1 − m exactly (Lemma imitation:split), and the two conditions coincide.
    **α* = min(0.4, q)·β is the exact threshold.**

### P11 (the systematic fallacy "step by 2") — proved; computed

`σ2 = st(Sub(P,x,0,A), Sub(P,x,SSx,B), (A ∧ ∀x(P→B)) → ∀xP)`.

1. **Identified under its own tag.** P1 holds verbatim, since φ[SSx/x] ≠ φ iff x is free. Two records with different
   roots, one non-vacuous, give lgg = σ2 (computed). The coupon constants are those of P5, for its own usage law.
2. **Unsound.** `P = ¬(x=S0)`: the Sub premises are W-true, the antecedent is true, and ∀xP is false (computed). The
   two-base-case variant (adding the premise P(S0)) is sound.
3. **Cited as induction, under per-tag H₁.** The union of σ and σ2 is not in H₁, so Cor imitation:systematic, which
   needs R* ∪ inst(σ2) ∈ H, does not apply. Step-by-2 records are then sporadic noise, removed by trimming iff
   α < min(0.4, q)·β (P10). Under per-tag unions H₂ they would be learned as a second rule.
4. **Audit, W = Δ0 truth (+ Sub), only ⟨∅⊢∅⟩ designated, Q1 and Q2 learned: only a bag.**
   * *Claim.* {step-by-2} alone has **no refutation at any depth**. Hence by Lemma twotier:descent(c),(d) **every**
     refutation of Σ* ∪ {step-by-2} has a blocked descent, and the audit falls back to B ∖ ⋃C_d(B), with collateral.
   * *Proof.* Suppose such a refutation existed. Its leaves are W-true Δ0 sentences and Sub facts, and no step
     concludes a Sub judgment, so each step-by-2 step concludes `C_P` for a genuine motive P. Then
     `Th_Δ0(ℕ) ∪ {C_P}` would prove a false Δ0 sentence (or ⊥), and so be inconsistent. By compactness some finite
     part {δ₁..δ_r} ∪ {C_P's} would be unsatisfiable. But it has a model:
     * Take ℤ/Nℤ with N odd and larger than every value arising in evaluating δ₁..δ_r in ℕ, with `<` read on
       representatives.
     * Each δ_i is evaluated exactly as in ℕ, so it holds.
     * Every C_P holds: SS = +2 generates ℤ/Nℤ, so a set containing 0 and closed under SS is everything. ∎
   * *Computed* (`a6b_bag_only.py`): in ℤ/7 and ℤ/9 all 2,368 sampled step-by-2 instances hold, and Q2 holds while Q1
     fails. In the "rho" structures (0→1→…→N−1→1, N = 8, 10) Q1 holds and Q2 fails. So {step2,Q1} and {step2,Q2} are
     clean, while {step2,Q1,Q2} is refuted. Collateral therefore includes Q1 and Q2.
   * *Computed descent* (`a6_noise_fallacy.py`): `blocked`, bag {Q1, Q2, step-by-2}.
5. **Singleton blame is restored** (proved, computed) by any one of:
   * designating ⟨Q1, Q2 ⊢ ∅⟩ ((WS) holds since both are true);
   * trusting Q1 and Q2;
   * letting W decide sentences of successor arithmetic Th(ℕ,0,S), which is decidable as a reduct of Presburger
     arithmetic.

   The refutation `C_P` with P = ¬(x=S0), then FOL from Q1,Q2 to `A ∧ ∀x(P→B)`, then MP, then ∀E, ends at `¬(S0=S0)`.
   It descends to step-by-2 alone (computed values `[1,1,0,1,1,1,0,0]`).

---------------------------------------------------------------------------------------------------------

## 4. Credits and literature

* Least general generalization and anti-unification: Plotkin (1970) and Reynolds (1970). Huet's 1976 thesis is often
  credited with an anti-unification algorithm as well; I am not certain of the exact content.
* Raw induction `φ(0) ∧ ∀x(φx → φ(Sx)) → ∀xφx` is a second-order schema with φ applied to the non-variable arguments
  0 and Sx. So it is **not** a higher-order pattern in Miller's sense (Miller 1991), and the pattern anti-unification
  of Pfenning (1991, LICS, calculus of constructions) and Baumgartner–Kutsia–Levy–Villaret (J. Autom. Reasoning 2017,
  linear-time HO pattern anti-unification) does not apply directly. In E2 the motive is data, so only first-order
  anti-unification is needed.
* Decidability: second-order matching (Huet & Lang 1978), third-order matching (Dowek 1994), higher-order matching in
  general (Stirling 2009, as I recall). Second-order *unification* is undecidable (Goldfarb 1981).
* For induction, the motive of a raw instance is read off the conclusion ∀xφ. So a learner that already knows to
  compute "substitute 0 and Sx into the conclusion's body" can annotate raw data itself. That is a choice of bias,
  not learned.
* Anchors, coupon rates, trimming, necessity, cautious verification, guards and the descent/audit lemmas are from the
  paper: Lemma setting:recover, Thm imitation:anchor, Thm imitation:coupon, Thm imitation:trimmed,
  Thm imitation:iidnoise, Cor imitation:necessity, Lemma imitation:cautious, Lemma setting:guard,
  Thm caution:single, Lemma twotier:descent, Thm twotier:blame.
  Descent is Shapiro's contradiction backtracing; conflicts and diagnosis follow Reiter (1987).
* Compactness: Gödel–Mal'cev. Decidability of Presburger arithmetic: Presburger (1929).
* Metamath: Megill & Wheeler, *Metamath* (2019). Lean 4: de Moura & Ullrich (CADE 2021).

## 5. Caveats and open points

* P7(d) values are exact only within finite motive universes, so they are lower bounds for genuine-only provers. That
  they equal the true maxima is a conjecture.
* All bounded-semantics checks (`ev_closure`) are evidence only. Every counterexample quoted was verified by hand,
  and every premise called "PA-provable" is a FOL= or easy PA fact.
* P5 assumes independence of root, vacuity and variable for the exact formula. Without it, the union bound
  Σp^N + (1−q)^N (+ Σq_v^N) holds.
* P11.4 is stated for W = Δ0 truth on sentences and the empty position. Richer W or designated positions change the
  answer (P11.5).
* Context from earlier work, not re-checked here: in the untagged class H_k with ground PA axioms, the Sub-induction
  threshold is "not covered by k−1 failure sets". E2 removes the equality failure sets and leaves only "root of P = f".
* The Lean fact corrects the brief: the motive of `Nat.rec` is an implicit binder at the surface. The elaborated
  `induction` term (`Nat.recAux`) carries it explicitly.
