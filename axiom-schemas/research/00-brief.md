# Brief: learning axioms and axiom schemas from their instances

Commissioned by Kaarel Hänni (follow-up to the report in `../inferential-learning/`). This brief is the shared starting point for all research tracks. It fixes the questions, the conventions, a proposed method, and what is already known. Tracks may improve the method; any change must be argued.

## 1. The questions (verbatim, from the commissioner)

* does the same thing work for learning an axiom of the form forall x phi(x) from a bunch of sentences of the form phi(x)?
* does the same thing work for learning each axiom schema of ZFC from a bunch of instances?
* anyway can you try to come up with a method that works for all these? ideally, your method would also work for learning many axiom( scheme)s at once, even if they do not come with labels for instances of which axiom scheme they are
* if you succeed please write this up as a separate standalone paper and give me a pdf

"The same thing" = the method developed for PA induction (summarized in §4).

## 2. Framework (from the parent report; keep consistent)

* Steps/sentences are ground terms. A *schema/template* is a term with metavariables; inst(T) its instance set. Hypothesis classes: single templates H_1, tagged calculi, untagged unions H_k of at most k templates.
* *Cautious (version-space) verifier*: accept q iff every hypothesis in the class that covers the data (and avoids known negatives) contains q. Sound at all times against adaptive provers when the target is in the class (more precisely, iff the target equals the intersection of class members containing it — "closed in the class"). Exact once the data contain an *anchor*: a finite T ⊆ target such that every hypothesis containing T contains the target.
* Plotkin–Reynolds least general generalization (lgg, anti-unification). Witness events (R) roots of each metavariable's instantiations not all equal, (D) distinct metavariables differ somewhere; lgg recovers sigma iff (R) and (D).
* Coupon-collector rate for tagged rules; untagged unions need a bound k and a diversity condition (Gold: without a bound the class is superfinite and the cautious verifier never generalizes).
* *World / refutation channel*: sound but one-sided evidence that some sentence is false (e.g. a Delta_0 counterexample in N; a hereditarily finite counterexample to a Pi_1 sentence of set theory, sound by Delta_0 absoluteness; derivation of ⊥ from designated true premises = coherence). Refutation can never condemn a subset of the target; nothing certifies that a schema is genuine.
* Credit classical work: Gold 1967, Angluin 1980, Plotkin 1970, Reynolds 1970, Huet (higher-order unification, 1975/76), Huet–Lang 1978 (second-order matching), Miller 1991 (patterns), Pfenning 1991 and Baumgartner–Kutsia–Levy–Villaret 2017 (higher-order pattern anti-unification), Cerna–Kutsia (anti-unification surveys), Hirata–Ogawa–Harao 2004 (second-order generalization), Wright 1989 / Motoki–Shinohara–Wright 1991 (finite elasticity of unions), Shinohara, Muggleton (ILP), Tenenbaum (size principle), Ryll-Nardzewski 1952, Vaught 1967 (schematic axiomatizability), Tarski (substitution-free formulations), Metamath set.mm (implicit substitution), Lean/Coq motives. Mark uncertain citations as such.

## 3. Conventions to use

* **Closure-normal form.** Data are formulas whose free variables are *parameters*, read under universal closure. This removes the variable-length outer prefix ∀w1…∀wn of schema instances with parameters (Separation, Replacement, induction with parameters).
* **Bound variables** are de Bruijn indices (or locally nameless); free parameters are names. Metavariable values are λ-terms whose free variables are parameters only, so capture cannot occur and freshness side conditions ("b not free in φ") are built in. Compare with the named first-order encoding, where they must be learned as guards.
* **Determinate templates (class DT°).** Second-order templates over the object language: metavariables M of type ι^n→o (formula) or ι^n→ι (term) may be applied to metavariable-free argument terms; each metavariable has at least one *pattern occurrence* (rigid position, applied to pairwise distinct bound variables in scope; a 0-ary metavariable needs only a rigid occurrence). Instances: substitute closed-up λ-terms, β-reduce (one-step plugging). First-order patterns are the 0-ary case. Prior work (§4) showed: unique linear-time matching; restriction to metavariable-free arguments is needed (with nested arguments the learner was unsound and minimal covering sets could be infinite).

## 4. What is already established (prior session; files in `prior/`)

PA induction Ind(φ) = φ(0) ∧ ∀x(φ→φ[Sx/x]) → ∀xφ (see `prior/induction/*-notes.md` and `*-referee.md`, all refereed once):
* First-order lgg on raw instances is unsound: two instances suffice (Ind(x+0=x), Ind(0+x=x) → false instance (0+0=0) ∧ ∀x(0+0=x → 0+S0=Sx) → ∀x(0+0=x)); no finite union of first-order schemas covers induction soundly (family φ_n = (0+(…(0+x)) = x)); some unsound lggs are consistent with all true quantifier-free sentences (never refuted).
* Higher-order *pattern* anti-unification is unsound on induction (lgg A ∧ ∀x(P(x)→Q(x)) → ∀xP(x)); induction is not a Miller pattern (P(0), P(Sx)).
* Determinate-template learner: unique linear matching; anchor theorem: D ⊆ Ind is an anchor in DT iff (R) motives' main symbols not all equal and (N) some motive has x free; the induction template is the least of 26 covering generalizations; rate P[no anchor after N] = Σ p_f^N + (1−q)^N − Σ r_f^N; noise-trimmed version; soundness iff target closed in class; size-bounded classes need s ≥ 12; DT not unitary; SO° (no determinacy) needs stronger anchors.
* Sub-encoding and Tarski-style IndEq(P) = ∀x(x=0→P) ∧ ∀y(∀x(x=y→P) → ∀x(x=Sy→P)) → ∀xP give first-order patterns with the same anchors; Q + inst(IndEq) axiomatizes PA.
* Untagged (`prior/pa-untagged/`): with Q's 7 ground axioms + induction in unions of ≤ k schemas and positive data only, the cautious learner is exact iff induction data are not covered by k−1 failure sets (Q's axioms can be lumped into one over-general slot), so at k = 8 induction is learned per main connective; two world refutations (⊢∀x(0=S0), ⊢∀x∀y(0=S0)) forbid all lumpings of Q's axioms and restore the tagged anchor; theorem-level completeness is cheap (Ind(φ) ↔ Ind(¬¬φ)); from theorems alone PA is not identifiable (IΣ_n chain).

## 5. Proposed answers and method (to be confirmed, refined or refuted by the tracks)

**Q1 (∀xφ from instances φ(t)).** φ(z) with z a term metavariable is a first-order pattern: plain lgg works; anchor = instances whose substituted terms have different head symbols (plus (D) for several variables). But what is learned is the *instance schema*, not the sentence ∀xφ: passing from all closed instances to ∀xφ is an ω-rule step — truth-safe in pointwise-term-definable structures such as ℕ, not in ℝ (¬(x·x = 1+1) holds for every closed term of ordered-field language but fails for √2), not derivable in general (Q ⊢ 0+n̄ = n̄ for each n, Q ⊬ ∀x(0+x=x)). With instances at free variables (closure-normal form) and Gen, ∀xφ is recovered.

**Q2 (ZFC schemas).** Single axioms are ground. Separation and Collection are first-order patterns in the named encoding with a freshness guard (b ∉ FV(φ)), and in the λ/de Bruijn encoding freshness is automatic. Replacement with ∃! spelled out (φ(x,y) ∧ ∀z(φ(x,z) → z=y)) and ∈-induction (∀x(∀y∈x φ(y) → φ(x)) → ∀xφ(x)) rename a variable inside φ: not first-order patterns, but Miller patterns. So all ZF schemas lie in the higher-order pattern fragment (unlike PA induction): pattern anti-unification and the determinate learner both work; first-order lgg fails for Replacement/∈-induction (to be exhibited with explicit refutable instances).

**Q3 (one method, many schemas, no labels): DTRC — Determinate Templates with Refutation Clustering.**
1. Normalize data (closure-normal form, de Bruijn).
2. Agglomerative clustering: start with singletons; merge two clusters iff the merged set has a minimal covering DT° template none of whose (searched) instances is refuted by the world/coherence oracle. (Within-schema merges always succeed: some minimal covering template lies below the true template, hence is sound and never refuted. Cross-schema merges fail whenever every covering template has a refutable false instance — "refutation separation".)
3. Within each cluster, the cautious DT° verifier: accept q iff q is an instance of every unrefuted minimal covering template of the cluster.
4. Assert the union. (Optionally: if the number k of schemas is known, the pure version-space learner over k-unions with the refuted negatives.)
Intended theorems: matching; single-template anchor theorem in DT° (general witness events generalizing Plotkin's (R),(D) with (N) and possibly a no-coincidence condition (U)); *pigeonhole theorem* (exact bound k = k' plus negatives refuting every cross-schema merge ⇒ untagged anchors = tagged anchors); DTRC correctness under refutation separation (labels recovered, then tagged rates), soundness relative to a residue of unrefuted merges, truth-soundness when residual merges are true; necessity results (bound or negatives needed; first-order and pattern classes insufficient; depth relativization unavoidable). Learning ∀xφ from instances becomes a special case: different instances have a sound common generalization, so they merge.

## 6. Scope and framing

This is learning theory for *checking* (which steps/axioms a community uses), not theorem proving. Draft authored by Claude (Anthropic) for Kaarel Hänni; publication is his decision. Label everything proved / computed / conjecture / known.
