# L4 — Inferentialism, proof-theoretic semantics, and the determinacy of meaning by rules

*Literature memo for the inferential-learning project, strand L4. Covers:*
- *Sellars and Brandom: material inference, incompatibility, logical expressivism.*
- *Gentzen, Lorenzen, Prawitz, Dummett, Schroeder-Heister: proof-theoretic semantics and harmony.*
- *Prior, Belnap and Stevenson on tonk.*
- *Carnap's categoricity problem and the bilateral / multiple-conclusion / compositional responses: Smiley, Rumfitt, Restall, Ripley, Garson, Raatikainen, Murzi–Hjortland, Bonnay–Westerståhl, Shoesmith–Smiley.*
- *Rule-following: Wittgenstein, Kripke, Goodman, Lewis.*

*Throughout, the question is what these results do for a learner that acquires inference rules from human examples, coherence and sparse world feedback.*

**Verification legend.** This session had **no working web access**. The search budget was exhausted, and every fetch (SEP, PhilPapers, publishers, arXiv, Crossref, Wikipedia, author pages) was blocked by the egress proxy. So **nothing below was re-checked online.**
- **[mem]**: a standard reference whose bibliographic data and main claim I am confident of from memory. Treat it as unverified for anything load-bearing.
- **[unverified]**: I am less sure of details such as exact formulation, pages, year or venue.
- **(ours)**: statements and proofs worked out for this memo. Proofs are included so that they can be checked directly. Several are folklore-level, and I say so where I believe a result is known.

---

## 0. Bottom line

1. **There are three levels of determinacy, not two.**
   - **(A) Which steps are valid**, i.e. the consequence relation $\vdash$. This is all a reasoner needs in order to derive conclusions.
   - **(B) Which truth-conditions the logical vocabulary has, given $\vdash$.** This is Carnap's problem.
   - **(C) Which valuation is actual, and what the non-logical vocabulary refers to.** This is Putnam's model-theoretic argument, Kripkenstein, and, in the user's own DLK work, "which feature CCS found".

   Coherence constraints act on (A) and (B). Only world feedback, or a prior, acts on (C). H3 runs (A) and (B) together, and H7 runs (B) and (C) together.

2. **Exact categoricity facts.**
   - **Single-conclusion consequence.** The valuations that respect single-conclusion ("SET-FMLA") classical consequence are exactly the characteristic functions of CL-theories, i.e. the supervaluations plus the all-true valuation. In these valuations:
     - $\wedge$ is always normal;
     - $\vee$ and $\to$ are undetermined only on the F/F row;
     - $\neg$ can be *gappy* ($A$ and $\neg A$ both false);
     - $A$ and $\neg A$ can both be true only in the trivial valuation.
   - **Multiple-conclusion consequence.** The valuations that respect multiple-conclusion ("SET-SET") classical consequence are exactly the Boolean ones. This is Carnap's 1943 "full formalization" and Scott's 1974 completeness theorem for SET-SET relations.
   - **Quantifiers** remain non-categorical even with multiple conclusions. This is an $\omega$-incompleteness/compactness phenomenon. It needs an infinitary rule or objectual model theory plus extra assumptions (Bonnay–Westerståhl).

3. **The deep reason is Horn-ness** (ours; the core is folklore going back to McKinsey and Horn).
   - A single-conclusion rule is a *definite Horn clause* about valuations.
   - A coherence constraint of the user's kind ("don't have good arguments for both $P$ and $\neg P$") is a *Horn goal clause*.
   - Model classes of Horn clauses are closed under intersection.

   So **no amount of sound inference data plus sound "not-both" coherence data can force classical $\neg$ or $\vee$.** The meet of two possible worlds always survives. Categoricity needs a *non-Horn* ingredient: multiple conclusions, denial with complementarity (bilateralism), compositionality, or bivalent world feedback. *The user's coherence loss eliminates tonk-style triviality but not gaps.*

4. **H3 is half right.**
   - Carnap's problem is a **data-format (representability) underdetermination**: it persists with *infinite* data. Gold's theorem is a **finite-data** underdetermination. They are not twins.
   - Carnap's true twin at level (A) is L1's interval theorem: *theorems* determine the consequence relation only up to $[\vdash^{\min}_T,\vdash^{\rm adm}_T]$.
   - In both cases expressive vocabulary collapses the format gap: the conditional via a deduction theorem, negation via bilateral coordination, disjunction for multiple conclusions. This is Brandom's expressivism read as an *identifiability* principle. Each collapse is bought with a bridge principle that the poorer data cannot confirm.

5. **For building a reasoner, level-(B) indeterminacy is harmless.** Derivations are unaffected. The gappy valuation is simply the honest "settled / refuted / open" status of an incomplete reasoner, which is exactly the "true/false/independent" triple in the user's *solomonoff axiom induction* note. Level (B) matters only when we interpret world feedback and do "verification from truth".

6. **Restall's normative reading gives the right hypothesis space.** Take as primitive the *incoherent positions*: pairs of things asserted and things denied.
   - The defining conditions (identity, weakening, cut-for-positions) are Horn in the incoherence atoms. So cautious learning is sound and monotone (the closure-system story of L1 carries over).
   - Level (B) becomes categorical once denial is read as exhaustive.
   - World states and consistent observed agents supply *coherent* positions, which give upper bounds.

   **Contrast Brandom–Aker incompatibility semantics.** There entailment is defined *from* incompatibility by a universal quantifier, and it is **non-monotone in the incompatibility data in both directions** (ours, §6.4). So incoherence data alone can never certify an entailment there; it needs a two-sided sandwich.

7. **Tonk filters for learned rules.** Three are available.
   - **(i) Classical base (ours, folklore core).** Over a classical base, every *schematic* non-conservative extension is outright trivial (Post-completeness at the level of consequence relations). Moreover the $\bot$-derivation is explicit and polynomial. So coherence checking plus an adversarial prover detects *every structural tonk*. This fails over intuitionistic, arithmetic or *material* bases.
   - **(ii) Avron–Lev canonical calculi.** For canonical multiple-conclusion calculi, "coherence" is a decidable SAT-style check on rule pairs. It is equivalent to cut-admissibility and to having a 2-valued non-deterministic matrix. Belnap-uniqueness is equivalent to determinism of that matrix (ours, as a corollary).
   - **(iii) Harmony.** Harmony failures are valid *negative bags*. But Gentzen–Lorenzen inversion (deriving eliminations from learned introductions) is **anti-cautious**: it is unsound unless the learned introductions are complete. Local harmony without a complexity/positivity condition does not imply consistency (Read's $\bullet$). The strict positivity check in Lean/Coq is exactly that condition.

8. **New vocabulary comes in three tiers that need different treatment.**
   - **Logical vocabulary:** fixed, base-universal rules (Hacking, Došen, Hlobil–Brandom). There is nothing to learn, and functional-completeness results imply that no new logical connective adds expressive power.
   - **Definitional vocabulary:** must be conservative and eliminable (Suppes' criteria). This is Belnap's existence condition.
   - **Theoretical / material vocabulary:** non-conservative *by design*. Its non-conservative part is empirical content (the Ramsey–Carnap split; Dummett's *Boche*), and the learner should route it to world feedback.

9. **Constitutive versus collateral.** No sharp line survives Quine and Williamson, but there are four usable operational criteria:
   - substitution-invariance (formal vs material);
   - conservativeness (definitional vs substantive);
   - the Carnap-sentence / Ramsey-sentence split;
   - entrenchment (graded; AGM).

   The entrenchment ordering is exactly the information needed to set up idealized contexts. Supposing an idealization $I$ on top of background $K$ with $K\vdash\neg I$ explodes classically. Contexts must import a fragment $K_I$, chosen by entrenchment (revision) or by designation (L7's model stipulation).

10. **Kripkenstein gets a precise division of labour.**
    - *Community* fixes the target (normativity), supplies membership queries and averages out idiosyncratic noise. It does not correct shared errors.
    - *World feedback* kills deviant hypotheses in its own region.
    - *Coherence* transfers evidence across regions and kills non-uniform deviants. It cannot kill uniformly "gruesome" recodings.
    - *Simplicity / naturalness*, or *mind-change efficiency* (Schulte, Kelly), chooses among what remains. Mind-change efficiency is language-invariant but relative to the hypothesis space.
    - *Teleosemantics* answers Kripke's normativity worry for trained systems: errors are deviations from what training selected for.

11. **Correction to H4 (ours, short proof in §3.6).** $\mathsf{PA}+\neg\mathrm{Con}(\mathsf{PA})$ proves **no false $\Pi_1$ sentence**. So *no amount of computational world feedback ever refutes it*. It is excluded only by a *policy*:
    - Kelly-style Ockham: conjecture $\Pi_1$ claims until they are refuted;
    - Dummett-style: demand witnesses for $\Sigma_1$ assertions;
    - or Carnap's $\omega$-rule.

---

## 1. Frame and dictionary

### 1.1 Sellars's architecture is the learner's architecture

Sellars ("Inference and meaning", *Mind* 62 (1953) 313–338 [mem]) argued that *material* rules of inference are as essential to meaning as formal ones. Examples are "it is raining, so the streets will be wet" and "Pittsburgh is west of Philadelphia, so Philadelphia is east of Pittsburgh". He also argued that material inferences are not enthymemes with suppressed formal premises.

In "Some reflections on language games" (*Philosophy of Science* 21 (1954) 204–228 [mem]) he split linguistic practice into three kinds of move:
- **language-entry transitions** (perception);
- **intra-linguistic moves** (inference);
- **language-exit transitions** (action).

This is our architecture verbatim:
- world feedback consists of language-entry transitions;
- learned inference rules are intra-linguistic moves;
- "practical success" is evaluated at language-exit.

Sellars's later distinction between *ought-to-do* and *ought-to-be* rules ("Language as thought and as communication", *PPR* 29 (1969) 506–527 [mem]) is also the right gloss on a *trained* verifier. Its rules are ought-to-be patterns, instilled by correction rather than consulted. Lewis Carroll's regress ("What the tortoise said to Achilles", *Mind* 4 (1895) 278–280 [mem]) shows why they have to be: a rule cannot be replaced by a premise. This bears on the user's note *what is it to accept an axiom or an inference rule?* Accepting a rule is acquiring a disposition to make and endorse its instances, and to correct deviations from them. It is not adding a sentence.

### 1.2 Brandom's scorekeeping, and what it says about the coherence loss

Brandom (*Making It Explicit*, Harvard UP 1994; *Articulating Reasons*, Harvard UP 2000 [mem]) models discursive practice as scorekeeping of **commitments** and **entitlements**. Two claims are *incompatible* if commitment to one precludes entitlement to the other. He distinguishes three inferential relations:
- commitment-preserving (roughly deductive);
- entitlement-preserving (roughly inductive and defeasible);
- incompatibility-entailment: $A$ entails $B$ when everything incompatible with $B$ is incompatible with $A$.

Entitlement has a *default-and-challenge* structure.

**Lesson for the coherence loss.** In Brandom, a finite agent's commitments, closed under consequence, are *routinely* jointly incompatible. The norm is not "never have incompatible commitments". It is "incompatible commitments forfeit entitlement to them". For the learner, finding good arguments for both $P$ and $\neg P$ should therefore trigger three things:
- withdrawal of entitlement from the conclusions involved;
- quarantine, as a negative bag, of the steps those arguments used;
- a challenge, i.e. a query.

It is not a catastrophic loss on the whole model.

### 1.3 Levels A/B/C

Fix a language $\mathcal L$.
- **Level A.** The object to determine is a consequence relation $\vdash^*$, i.e. the set of valid steps. The data are human steps, coherence alarms and world labels.
- **Level B.** Given $\vdash^*$ completely, does it fix the *truth-conditions* (the class of admissible valuations, or models) of the logical vocabulary? This is Carnap's problem.
- **Level C.** Given the admissible class, which valuation is the *actual* one, and what do the non-logical terms denote? This is Putnam's model-theoretic argument and Kripkenstein's quus. For probes it is the Farquhar et al. (2023) critique of CCS: consistency plus confidence constraints are met by *any* Boolean-valued feature, not just truth.

The user's DLK note `logic.md` observes that "an assignment of truth to sentences which is stable under inference rules … can be extended to a full model". That is correct. But in general the assignment *itself* is one of Carnap's non-normal valuations (§2). The extension makes some sentences true that the assignment marked false.

---

## 2. Carnap's categoricity problem: exact statements

### 2.1 Set-up

A *valuation* is a map $v:\mathrm{Fm}\to\{T,F\}$; write $v^+=v^{-1}(T)$.
- $v$ **respects** a single-conclusion relation $\vdash$ if $\Gamma\subseteq v^+$ and $\Gamma\vdash A$ imply $A\in v^+$.
- $v$ respects a multiple-conclusion relation $\vdash$ (Shoesmith & Smiley, *Multiple-Conclusion Logic*, CUP 1978 [mem]) if $\Gamma\subseteq v^+$ and $\Gamma\vdash\Delta$ imply $\Delta\cap v^+\ne\emptyset$.
- $v$ is **normal** for a connective if it obeys that connective's classical table at every formula.

By Suszko's thesis, every Tarskian consequence relation is complete for *some* class of bivalent valuations (Suszko 1977 [unverified details]). What can fail is *truth-functionality*. Carnap's problem is precisely the question whether the valuations that respect $\vdash$ are truth-functional.

Carnap, *Formalization of Logic* (Harvard UP 1943) [mem], observed that the classical propositional calculus admits **non-normal interpretations**:
- the all-true valuation $v_\top$;
- valuations such as "true iff tautologous", under which $p$ and $\neg p$ are both false while $p\vee\neg p$ is true.

### 2.2 Single conclusion

**Proposition 2.1** (valuations respecting a single-conclusion relation; Lindenbaum-style, folklore).
- (a) For any reflexive, monotone, transitive $\vdash$: $v$ respects $\vdash$ iff $v^+$ is a $\vdash$-theory.
- (b) For classical propositional logic CL, the respecting valuations are exactly $v_\top$ together with the supervaluations $v_S(A)=T\iff\forall u\in S\ u(A)=T$, where $S$ ranges over the nonempty sets of Boolean valuations.

*Proof.* (a) is immediate. For (b): every consistent CL-theory is the intersection of the maximal consistent sets containing it (Lindenbaum), and these are the truth-sets of Boolean valuations (completeness). $\square$

**Normality profile (Carnap 1943; the derivation is routine).** Let $v\neq v_\top$ respect single-conclusion CL.

| connective | forced by single-conclusion rules | left open |
|---|---|---|
| $\wedge$ | fully normal ($A,B\vdash A\wedge B$; $A\wedge B\vdash A$; $A\wedge B\vdash B$) | nothing |
| $\vee$ | $T$ whenever a disjunct is $T$ ($A\vdash A\vee B$) | row $F,F$: $A\vee B$ may be $T$ |
| $\to$ | rows $TT$, $FT$ are $T$ ($B\vdash A\to B$); row $TF$ is $F$ (MP) | row $F,F$: $A\to B$ may be $F$ |
| $\neg$ | not both $T$ ($A,\neg A\vdash B$, given $v\ne v_\top$) | $A$ and $\neg A$ may both be $F$ |

Every open cell is realized by the tautology valuation $v_{S_{\rm all}}$.

Hardegree ("Completeness and super-valuations", *JPL* 34 (2005) 81–95 [unverified details]) is the reference usually cited for "single-conclusion CL is the logic of supervaluations". Van Fraassen's supervaluations ("Singular terms, truth-value gaps, and free logic", *J. Phil.* 63 (1966) 481–495 [mem]) famously validate every classical single-conclusion inference while letting $A\vee B$ be true with neither disjunct true. So **the gaps are not a pathology. They are the semantics of "settled by the premises".**

### 2.3 Why: Horn representability

**Proposition 2.2** (Horn closure; ours as stated, folklore core from McKinsey, *JSL* 8 (1943) 61–76, and Horn, *JSL* 16 (1951) 14–21 [mem]).

*Set-up.* Let $U$ be any set of "judgment atoms" and let hypotheses be subsets $h\subseteq U$. A *clause* $(B\Rightarrow H)$ has $B,H\subseteq U$ finite, and $h\models(B\Rightarrow H)$ iff $B\subseteq h$ implies $H\cap h\neq\emptyset$.
- A clause is *definite* if $|H|=1$.
- A clause is a *goal* clause if $H=\emptyset$.
- A clause is *Horn* if $|H|\le1$.

*Claims.*
- (a) If every clause in $C$ is definite, $\mathrm{Mod}(C)$ is closed under arbitrary intersections, including the empty intersection $U$.
- (b) If every clause in $C$ is Horn, $\mathrm{Mod}(C)$ is closed under non-empty intersections.
- (c) For finite $U$ the converse holds: every family closed under non-empty intersections is $\mathrm{Mod}$ of a Horn set.
- (d) With arbitrary finitary clauses, every family that is closed in the product (Cantor) topology on $2^U$ is a $\mathrm{Mod}$.

*Proof of (a), (b).* If $B\subseteq\bigcap_i h_i$, then $B\subseteq h_i$ for each $i$.
- Definite head $a$: $a\in h_i$ for all $i$.
- Goal clause: already $h_1$ fails it.

(c) and (d) are standard. $\square$

**Corollary 2.3 (no Horn fix; ours).** Let the intended class $K$ of valuations contain Boolean $u_1,u_2$ with $u_1(p)=T$ and $u_2(p)=F$. Let $C$ be *any* set of Horn constraints true throughout $K$. Examples:
- all valid single-conclusion sequents;
- any incoherence constraints $\Gamma\Rightarrow\emptyset$ valid in $K$;
- any rules whatsoever that are sound for $K$.

Then $w=u_1\wedge u_2$ (pointwise) satisfies $C$, and $w(p)=w(\neg p)=F$ while $w(p\vee\neg p)=T$.

*Consequences.*
- No sound positive-inference data plus sound "not-both" coherence data can force classical $\neg$ or $\vee$.
- The user's proposed coherence loss is a family of goal clauses. It removes $v_\top$ (tonk-triviality) and nothing else at level B.

### 2.4 Multiple conclusions and positions

Carnap's own 1943 cure was "full formalization", which uses "junctives", i.e. disjunctively read sets of conclusions. Shoesmith & Smiley (1978) developed multiple-conclusion logic systematically [mem].

**Scott's theorem** (Scott, "Completeness and axiomatizability in many-valued logic", *Proc. Tarski Symposium*, AMS 1974, 411–435 [mem]): every SET-SET relation satisfying reflexivity, monotonicity and cut-for-sets is complete for its class of respecting valuations. There is a Galois bijection between such relations and topologically closed classes of valuations. For SET-SET CL the respecting valuations are **exactly the Boolean valuations**:
- $A,\neg A\vdash\ $ excludes "both true";
- $\vdash A,\neg A$ excludes "both false";
- $A\vee B\vdash A,B$ fixes the F/F row of $\vee$;
- similarly for $\to$.

**Restall** ("Multiple conclusions", in Hájek, Valdés-Villanueva & Westerståhl (eds.), *Logic, Methodology and Philosophy of Science: Proc. 12th Int. Congress*, King's College Publications 2005, 189–205 [mem]) reads $\Gamma\vdash\Delta$ normatively: *the position of asserting everything in $\Gamma$ while denying everything in $\Delta$ is out of bounds*. The structural rules become rules about positions:
- **identity:** $[A:A]$ is incoherent;
- **weakening:** incoherence persists when the position is extended;
- **cut:** if $[\Gamma,A:\Delta]$ and $[\Gamma:A,\Delta]$ are both incoherent, so is $[\Gamma:\Delta]$.

Read this way, cut says that a coherent position can always be extended coherently by either asserting or denying $A$. That is exhaustiveness in disguise. In "Truth values and proof theory" (*Studia Logica* 92 (2009) 241–264 [mem]), Restall recovers Boolean valuations as the *maximal* coherent positions, which is a Lindenbaum argument on positions.

### 2.5 Bilateralism, and where its non-Horn power comes from

Smiley ("Rejection", *Analysis* 56 (1996) 1–9 [mem]) and Rumfitt ("'Yes' and 'No'", *Mind* 109 (2000) 781–823 [mem]) use *signed* formulas: $+A$ for assertion, $-A$ for rejection. Rumfitt's system has harmonious rules for $\neg$: $+\neg A\dashv\vdash -A$ and $-\neg A\dashv\vdash +A$. It also has *coordination principles*:
- Rejection: $+A,-A\vdash\bot$;
- Smilean reductio: from $+A\vdash\bot$ infer $-A$, and conversely.

They show that this yields classical logic harmoniously and **categorically**, with single conclusions. Humberstone surveys the area ("The revival of rejective negation", *JPL* 29 (2000) 331–381 [mem]).

**Analysis (ours).** Bilateral single-conclusion rules are still Horn, now over *signed* atoms. The categoricity argument works because a signed formula is *interpreted* through a bivalent valuation: $+A$ is correct iff $v(A)=T$, and $-A$ is correct iff $v(A)=F$. That makes $\pm A$ complementary. Under this translation the Horn constraint $(-A\Rightarrow+\neg A)$ becomes the non-Horn clause $(\emptyset\Rightarrow\{A,\neg A\})$. Bilateralism therefore *imports exhaustiveness through the semantics of the signs*. If signed "valuations" may leave both $+A$ and $-A$ incorrect, the meet construction of Corollary 2.3 returns.

I believe this is the substance of Incurvati & Smith, "Rejection and valuations" (*Analysis* 70 (2010) 3–10) [unverified that this is exactly their argument]. Hjortland ("Speech acts, categoricity, and the meanings of logical connectives", *NDJFL* 55 (2014) 445–467 [unverified]) compares the bilateral and multiple-conclusion routes.

**Subtlety for learners.** In CL, SET-SET consequence is *definable* from SET-FMLA consequence using $\neg$: $\Gamma\vdash\Delta$ iff $\Gamma,\neg\Delta\vdash\bot$. So at level A no extra *data* are needed. The extra ingredient is the *reading* that $\neg$ expresses denial and that denial is exhaustive. That reading has empirical bite: when the world reports $A$ false, $\neg A$ becomes assertible. So world feedback can test it.

### 2.6 Compositionality, open-endedness, intuitionistic logic, quantifiers

- **Bonnay & Westerståhl**, "Compositionality solves Carnap's problem" (*Erkenntnis* 81 (2016) 721–739 [mem]).
  - Their claim [details unverified]: if interpretations of the connectives must be *compositional* (operations on the semantic values of the arguments), then the classical consequence relation fixes the standard meanings of the propositional connectives.
  - For first-order logic, as I recall it, the consequence relation fixes $\forall$ only up to a small family of non-standard interpretations, which I believe are principal-filter quantifiers. An invariance requirement removes them [unverified].
  - The authors and collaborators have since treated modal and intuitionistic versions of Carnap's problem [unverified details; titles not recalled reliably].
- **Garson**, *What Logics Mean: From Proof Theory to Model-Theoretic Semantics* (CUP 2013) [mem], and "Natural semantics: why natural deduction is intuitionistic" (*Theoria* 67 (2001) 114–139) [mem].
  - Garson defines when a rule set *expresses* a semantic condition, locally (valuation by valuation) or globally (over a set of valuations).
  - He argues that the natural-deduction rules, read globally, express *intuitionistic*, Kripke-like truth conditions for $\to$, $\neg$ and $\vee$, not classical tables [precise formulations unverified].
  - This is the semantic content of the supervaluational gaps in §2.2.
- **Raatikainen**, "On rules of inference and the meanings of logical constants" (*Analysis* 68 (2008) 282–287 [mem]).
  - He argues that Carnap's problem undermines inferentialism.
  - He also argues that even intuitionistic rules fail to fix the intended intuitionistic meanings [unverified details].
- **Murzi & Hjortland**, "Inferentialism and the categoricity problem: reply to Raatikainen" (*Analysis* 69 (2009) 480–488 [mem]). They reply that bilateral and multiple-conclusion formats remove the problem for classical logic, and that the inferentialist need not accept truth-conditional standards of meaning.
- **Open-endedness.** McGee ("The categoricity of logic", in Caret & Hjortland (eds.), *Foundations of Logical Consequence*, OUP 2015 [unverified pages]) and Murzi & Topey ("Categoricity by convention", *Phil. Studies* 178 (2021) 3391–3420 [unverified pages]) argue that rules accepted *open-endedly*, i.e. as holding in every extension of the language, fix the classical meanings. On my reading this is again a non-Horn, second-order ingredient: quantifying over all possible new sentences.
- **Intuitionistic disjunction.** Woods, "Failures of categoricity and compositionality for intuitionistic disjunction" (*Thought* 1 (2012) 281–291 [unverified details]), shows that intuitionistic $\vee$ is not fixed by its rules under the relevant semantics.
- **Quantifiers, even multiple-conclusion (ours, standard).** Over sentences with constants $c_i$, compactness gives a complete consistent theory containing every $Fc_i$ and also $\neg\forall xFx$. So a respecting valuation can make every instance true and the universal false. Pinning this down needs an infinitary rule. Carnap's own $\omega$-rule is in *Logische Syntax der Sprache* (1934; English 1937) and in "Ein Gültigkeitskriterium für die Sätze der klassischen Mathematik" (*Monatshefte* 42 (1935) 163–190) [mem]. The alternative is objectual model theory plus invariance (Tarski, "What are logical notions?", *Hist. Phil. Logic* 7 (1986) 143–154 [mem]; Sher, *The Bounds of Logic*, MIT 1991 [mem]).

### 2.7 Summary table (what fixes what)

| format / extra assumption | $\wedge$ | $\vee,\to$ | $\neg$ | $\forall,\exists$ |
|---|---|---|---|---|
| SET-FMLA classical (Carnap) | fixed | F/F row open | gaps; gluts only in trivial valuation | open |
| + "not-both" coherence (goal clauses) | fixed | F/F row open | gaps; no gluts | open |
| SET-SET classical (Carnap 1943 full formalization, Shoesmith–Smiley, Scott) | fixed | fixed | fixed | open (compactness) |
| bilateral single-conclusion + complementary signs (Smiley, Rumfitt) | fixed | fixed | fixed | (analogous issue) |
| SET-FMLA + compositionality (Bonnay–Westerståhl) | fixed | fixed [unverified] | fixed [unverified] | up to a small non-standard family; invariance removes it [unverified] |
| infinitary $\omega$-rule / objectual semantics + permutation invariance | — | — | — | fixed |

---

## 3. The Carnap–Gold analogy made precise (key question 1)

### 3.1 One Galois framework, two instances

Use Prop. 2.2's language. The **type** of constraint the data can express determines which hypothesis classes are representable:

| constraint type | what it can single out | Gold instance | Carnap instance |
|---|---|---|---|
| positive atoms $(\emptyset\Rightarrow x)$ | up-sets only | **text** | assertions of theorems |
| definite Horn $(B\Rightarrow a)$ | intersection-closed families containing $U$ | closure conditions on consequence relations (L1 Prop 8.1) | SET-FMLA consequence |
| + goal clauses $(B\Rightarrow\emptyset)$ | families closed under non-empty intersections | negative bags (coherence alarms) | incompatibility / "not both" |
| literals | singletons | **informant** | a single actual valuation (level C) |
| arbitrary clauses | closed families | — | SET-SET consequence / positions |

Gold's text/informant contrast and Carnap's single/multiple-conclusion contrast are two rows of one table. Both say that data restricted to a format can single out only objects that are closed under the format's closure operator.

### 3.2 Where H3 is right and where it is wrong

- **Right.** In both cases positive, "head-only" information cannot exclude the *top* element:
  - $\Sigma^*$ in Gold;
  - $v_\top$ in Carnap;
  - the trivial consequence relation, i.e. tonk, at level A.

  In each case the cure for the top is a constraint with empty head: negative data, incoherence, "$\Gamma\vdash\ $". The user's coherence loss is exactly that cure.
- **Wrong, or at least imprecise.**
  1. **Gold's problem is dynamic.** A *complete* text determines its language: it is the least element of its up-set. The impossibility concerns *finite* initial segments and infinitely many hypotheses. Carnap's problem is *static*: complete SET-FMLA information never determines the Boolean class.
  2. **The true level-A twin of Carnap is L1's interval theorem (L1 §8.2).**
     - The theorems of a structural logic determine its consequence relation only up to $[\vdash^{\min}_T,\vdash^{\rm adm}_T]$.
     - A deduction theorem collapses that interval (L1 §8.3).
     - In the same way, multiple conclusions, or a disjunction that represents them, collapse Carnap's gap.
  3. **The intended objects differ in kind.** At level A the target is one relation. At level B it is a *class*: the Boolean valuations, which are the co-atoms of the lattice of theories. No Horn data ever reach co-atoms; only a maximality principle or non-Horn data can.

**Expressivism as identifiability (ours, a gloss on Brandom).** Brandom's thesis is that logical vocabulary "makes explicit" inferential relations. It can be read as a collapse of data formats:
- a conditional with a deduction theorem turns hypothetical consequence into theoremhood;
- a negation with bilateral coordination turns denial into assertion;
- a disjunction with $\Gamma\vdash A,B\iff\Gamma\vdash A\vee B$ turns multiple conclusions into single ones.

Each collapse needs a *bridge principle* stated in the richer format. So the poorer data cannot confirm it; it must be part of the hypothesis class, or be tested by world feedback (§2.5).

### 3.3 The gappy residue is the reasoner's honest incompleteness

For a reasoner whose premises are not complete, the valuation "true iff derivable" is a supervaluation (Prop. 2.1). The user's *solomonoff axiom induction* note derives exactly the three statuses provable, refutable and independent, and puzzles over them. The three statuses are what Carnap's non-normal valuations are. Within that framework the probabilistic version ("p(true/false/independent)") is then natural.

**Consequence for H4.** In arithmetic we do *not* want the reasoner's status function to be categorical (bivalent): it can't be, by incompleteness. We want the *consequence relation* (level A) to be right. We want *meaning* to be fixed only to the extent that world feedback and policies (§3.6) fix it.

### 3.4 Does level B matter for the user's goals?

- **It does not matter for deriving.** Single-conclusion CL has all the classical derivations, including case analysis.
- **It matters for interpreting world feedback.**
  - If the world says "$A\vee B$" (e.g. "the particle went through one of the slits"), only a non-gappy semantics licenses expecting one disjunct to be observable.
  - If the world says "$A$ is false", we need the bilateral bridge to conclude $\neg A$.
- **It matters for "verification from truth"** (user's physics-olympiad note). Checking that each claim is "true in the context" requires a semantics, and level-B indeterminacy means that "true in the context" is not fixed by the rules alone.

### 3.5 The recommended hypothesis space: incoherent positions (ours, building on Restall)

Let a hypothesis be a family $\mathcal I$ of finite positions $[\Gamma:\Delta]$, closed under identity, weakening and cut-for-positions. Each closure condition is a definite Horn clause in the "$\in\mathcal I$" atoms, so (Prop. 2.2):
- these families form a closure system;
- the **cautious learner**, which takes the least family containing the observed incoherent positions, is sound and monotone exactly as in L1 T1/T2;
- each human step $\Gamma\Rightarrow A$ is the positive datum $[\Gamma:A]\in\mathcal I$;
- each coherence alarm is a negative bag over the steps used.

The *upper* bound comes from **coherent positions**:
- the world's own position, i.e. observed truths asserted and observed falsities denied;
- a reliable agent's actual position;
- a mathematical model satisfying the context (L1 §4.4's "learning from interpretations").

Entailment here *is* membership in $\mathcal I$, so it is **monotone** in $\mathcal I$, and lower bounds are sound. With denial read as exhaustive, level B is categorical for the propositional connectives.

This is the precise version of H3's suggestion that "the coherence loss is Restall's reading". It needs **denial data** (or the bilateral bridge from world falsity to assertibility of $\neg$), not only "not both".

### 3.6 Arithmetic: what computation can and cannot pin down (ours; correction to H4)

**Proposition 3.1.** $T=\mathsf{PA}+\neg\mathrm{Con}(\mathsf{PA})$ is consistent, false, and **$\Pi_1$-sound**: it proves no false $\Pi_1$ sentence.

*Proof.* Consistency is Gödel's second incompleteness theorem. Suppose $T\vdash\theta$ with $\theta$ a false $\Pi_1$ sentence.
1. Then $\mathsf{PA}\vdash\neg\mathrm{Con}(\mathsf{PA})\to\theta$, i.e. $\mathsf{PA}\vdash\neg\theta\to\mathrm{Con}(\mathsf{PA})$.
2. Since $\theta$ is false, $\neg\theta$ is a true $\Sigma_1$ sentence, so $\mathsf{PA}\vdash\neg\theta$ by $\Sigma_1$-completeness.
3. Hence $\mathsf{PA}\vdash\mathrm{Con}(\mathsf{PA})$, contradicting Gödel II. $\square$

*Corollary.* A learner whose world feedback is computation can refute false $\Pi_1$ claims. But that feedback *never* refutes $T$, and $T$ is coherent. What excludes $T$:
- **(a) Carnap's $\omega$-rule.** $T$ is $\omega$-inconsistent: it proves $\exists x\,\mathrm{Prf}(x,\ulcorner\bot\urcorner)$ while refuting every instance.
- **(b) A Dummett/BHK policy.** Assert a $\Sigma_1$ sentence only with a witness. This is the "fundamental assumption" (§4.2) restricted to $\Sigma_1$.
- **(c) A Kelly-style Ockham policy.** Conjecture each $\Pi_1$ sentence until a counterexample is computed. This makes at most one mind change per sentence and converges on all $\Sigma_1/\Pi_1$ truths (Kelly, *The Logic of Reliable Inquiry*, OUP 1996 [mem]). Beyond $\Delta_2$, truth is not decidable in the limit from computational evidence, so here coherence plus computation runs out.

This sharpens H4's statement that "world feedback = computation refutes false $\Pi_1$". It does, but the over-generalizations that matter most are $\Pi_1$-sound.

---

## 4. Proof-theoretic semantics: meaning from rules, and harmony

### 4.1 Gentzen, Lorenzen and inversion

Gentzen ("Untersuchungen über das logische Schließen", *Math. Z.* 39 (1935) 176–210, 405–431 [mem]) wrote that "the introductions represent, as it were, the 'definitions' of the symbols concerned, and the eliminations are no more, in the final analysis, than the consequences of these definitions". Lorenzen's *inversion principle* (*Einführung in die operative Logik und Mathematik*, Springer 1955 [mem]) is the corresponding procedure: whatever follows from each canonical ground for $\ast A$ follows from $\ast A$. Prawitz named it and used it (*Natural Deduction*, Almqvist & Wiksell 1965 [mem]).

Semantically, inversion is an **extremal (closed-world) clause**: the introduction rules are the *only* ways to obtain $\ast A$. It is a least-fixed-point reading, the proof-theoretic cousin of Clark completion. Hallnäs & Schroeder-Heister's *definitional reflection* makes this exact for clausal definitions, i.e. logic programs ("A proof-theoretic approach to logic programming I/II", *J. Logic Comput.* 1 (1990/91) [mem]). Martin-Löf's meaning explanations (*Intuitionistic Type Theory*, Bibliopolis 1984 [mem]) and the inductive types of Coq and Lean mechanize the same idea: the kernel derives the eliminator (recursor) from the constructors.

**Proposition 4.1 (inversion is anti-cautious; ours, easy).** Let the true introduction rules for $\ast$ be $I^*$, and let the learner have cautiously learned $I\subseteq I^*$. The inversion-derived elimination $E_I$ is *at least as strong* as $E_{I^*}$, and it is sound only if every canonical ground in $I^*$ is derivable from grounds in $I$.

*Example.* Suppose only $A\vdash A\vee B$ has been observed. Inversion then yields "from $A\vee B$ and $A\vdash C$ infer $C$", hence $A\vee B\vdash A$, which is unsound.

**Moral.** "Intros define meaning" as a learning procedure needs the closed-world assumption that *all* ways of introducing $\ast$ have been seen. That is exactly what positive data never certify (Gold). Such definitions are fine for *mathematical* definitions, which are closed-world by stipulation. They are wrong for empirical kinds with open texture (Waismann, "Verifiability", *Proc. Arist. Soc. Supp.* 19 (1945) [mem]).

**Positive half (ours).** Suppose the target's rules are harmonious, and $I\subseteq I^*$ and $E\subseteq E^*$ are each learned cautiously. Then $I$ and $E$ are harmonious with each other, because each $E^*$-rule reduces against every $I^*$-rule. So **every learned intro/elim pair that fails local reduction is a negative bag**: at least one of the two is invalid. Harmony success, however, certifies nothing.

### 4.2 Dummett: harmony, stability, the fundamental assumption

Dummett introduced harmony between the grounds for an assertion and its consequences in *Frege: Philosophy of Language* (Duckworth 1973) [mem]. He refined it in *The Logical Basis of Metaphysics* (Harvard UP 1991) [mem], distinguishing:
- **intrinsic harmony:** local peaks (an intro immediately followed by an elim) can be levelled;
- **total harmony:** conservativeness over the rest of the language;
- **stability:** the eliminations are also not *weaker* than the introductions warrant. This corresponds to Pfenning–Davies's *local completeness*, i.e. $\eta$-expansion, alongside *local soundness*, i.e. $\beta$-reduction ("A judgmental reconstruction of modal logic", *MSCS* 11 (2001) 511–540 [mem]).

Local soundness and local completeness are **decidable syntactic checks** on rule schemas. They are cheap coherence constraints on learned rules.

**Fundamental assumption** [mem; wording to check]: if we have a valid argument for a complex statement, we can construct one that ends with an introduction rule for its principal operator. It fails for classical logic ($\vdash A\vee\neg A$ has no canonical proof), and it drives Dummett's revisionism. For us it supplies the $\Sigma_1$ witness policy of §3.6(b).

**Local harmony is not sufficient for consistency.** Read's $\bullet$ ("Harmony and autonomy in classical logic", *JPL* 29 (2000) 123–154 [mem; rule details from memory]) has, roughly, an introduction "from a derivation of $\bot$ from $\bullet$, infer $\bullet$" and its harmonious elimination "from $\bullet$ and $\bullet$, infer $\bot$". Together they derive $\bot$, and the derivation does not normalize.

The paradoxes generally have this shape (Tennant, "Proof and paradox", *Dialectica* 36 (1982) 265–296 [mem]). Prawitz's appendix on naive set theory (1965) shows that Russell's paradox is a non-normalizing derivation [mem].

Dummett's **complexity condition** blocks $\bullet$: introduction premises may not contain the constant being introduced, or may contain it only in lower-complexity positions. Coq and Lean's **strict positivity** requirement on inductive types is the mechanized version. A non-positive type such as `Bad := C : (Bad → False) → Bad` yields an inconsistency.

**Lemma we can reuse (standard).** If the extended system normalizes and normal derivations have the subformula property, then it is conservative over the old vocabulary. This is the usual route from intrinsic to total harmony. The project's inductive-definition (H5) and Russell (Frege→Zermelo) stories should be phrased in exactly these terms:
- naive comprehension is harmonious but violates the complexity condition;
- Russell's derivation is the non-normalizing witness;
- Separation restores a condition under which normalization or consistency can be proved relative to a stronger base.

### 4.3 Prawitz validity, base-extension semantics, and the admissible-rule gap

Prawitz defined proof-theoretic validity relative to *atomic bases*, i.e. sets of atomic (material) rules ("Ideas and results in proof theory", *Proc. 2nd Scand. Logic Symp.*, 1971; "Towards a foundation of a general proof theory", *LMPS IV*, 1973; "On the idea of a general proof theory", *Synthese* 27 (1974) 63–77 [mem]):
- a closed argument is valid if it reduces to canonical form;
- an open argument is valid if all its closed instances obtained by substituting valid arguments are valid.

He conjectured that intuitionistic logic is complete for this notion.

Piecha, de Campos Sanz & Schroeder-Heister ("Failure of completeness in proof-theoretic semantics", *JPL* 44 (2015) 321–335 [mem]) and Piecha & Schroeder-Heister (*Studia Logica* 107 (2019) 233–246 [mem]) showed incompleteness for broad classes of such semantics: certain non-derivable *admissible* rules, such as Harrop's, come out valid [details unverified]. Sandqvist ("Base-extension semantics for intuitionistic sentential logic", *Logic J. IGPL* 23 (2015) 719–731 [mem]) obtained completeness with a second-order clause for $\vee$. Stafford (*JPL* 2021 [unverified]) showed that a variant yields inquisitive logic.

**Relevance.** *Validity defined from canonical (closed) proofs relative to a material base* is the proof-theoretic formalization of our setup: material base plus logical constants. These incompleteness results are the semantic shadow of L1's interval theorem: semantics defined through categorical (closed) provability tends to validate admissible-but-underivable rules. For a learner that means **in-context (open, hypothetical) data are indispensable**, which is the same conclusion as L1 §8.2.

### 4.4 Schroeder-Heister: generalized eliminations and functional completeness

Schroeder-Heister ("A natural extension of natural deduction", *JSL* 49 (1984) 1284–1300 [mem]) introduced higher-level rules and general elimination rules. He showed that every connective given by introduction rules in this format has a canonical harmonious elimination, and that all such connectives are *explicitly definable* from $\wedge,\vee,\to,\bot$. Zucker & Tragesser (*JPL* 7 (1978) 501–516 [mem]) proved a related adequacy result.

**Consequence for the project.** Learning new *logical* connectives from data is pointless: within the intro-defined format, nothing new can be expressed. The logical layer can be fixed once. What must be learned is the **material base** and the **non-logical vocabulary**.

---

## 5. Tonk, conservativeness and uniqueness: constraints on learned rules for new vocabulary (key question 3)

### 5.1 The classic exchange

- **Prior**, "The runabout inference-ticket" (*Analysis* 21 (1960) 38–39 [mem]). Tonk has $A\vdash A\,\mathrm{tonk}\,B$ and $A\,\mathrm{tonk}\,B\vdash B$, so $A\vdash B$ for all $A$ and $B$.
- **Stevenson**, "Roundabout the runabout inference-ticket" (*Analysis* 21 (1961) 124–128 [mem]). Rules must be justified semantically, and tonk has no truth table.
- **Belnap**, "Tonk, plonk and plink" (*Analysis* 22 (1962) 130–134 [mem]). Rules may define a connective provided:
  - **existence**: the extension is *conservative* over the antecedently given deducibility relation;
  - **uniqueness** is desirable: two connectives obeying the same rules are interderivable.

  Both conditions are relative to a prior *context of deducibility*, i.e. the structural rules.
- **Prior**, "Conjunction and contonktion revisited" (*Analysis* 24 (1964) 191–195 [mem]).
- **Cook**, "What's wrong with tonk(?)" (*JPL* 34 (2005) 217–226 [mem]) and **Ripley**, "Anything goes" (*Topoi* 34 (2015) 25–36 [mem]). Tonk is harmless in a *non-transitive* consequence relation: its damage is done entirely by **cut**.

**Mapping to H1.** Tonk is the paradigm adversarially exploitable rule, and the exploitation is *chaining*. A verifier that checks steps locally but whose accepted arguments are compositions of steps is exactly a system with cut. So Ripley's observation is a precise form of H1's warning: step-level adequacy is not enough once cut is applied. Conversely, approximate physical reasoning is non-transitive at a fixed tolerance, because errors add. The appropriate structural rule is a *graded* cut, $\Gamma\vdash_\varepsilon A,\ A\vdash_\delta B\Rightarrow\Gamma\vdash_{\varepsilon+\delta}B$, not unrestricted cut (cf. Cobreros, Égré, Ripley & van Rooij, "Tolerant, classical, strict", *JPL* 41 (2012) 347–385 [mem]; and L7).

### 5.2 Uniqueness as implicit definability

Došen & Schroeder-Heister relate uniqueness to implicit definability, and the interplay of conservativeness, uniqueness and interpolation to Beth's theorem ("Conservativeness and uniqueness", *Theoria* 51 (1985) 159–173; "Uniqueness, definability and interpolation", *JSL* 53 (1988) 554–570 [mem; exact theorems unverified]).

In classical first-order logic, Beth (1953, *Indag. Math.* 15 [mem]) gives: a new symbol that is uniquely (implicitly) characterized by conservative rules is explicitly definable. **So uniquely characterized, conservative new vocabulary is eliminable.** It can compress, which helps MDL, but it adds no content.

### 5.3 A decidable tonk filter: Avron–Lev canonical calculi

Avron & Lev ("Canonical propositional Gentzen-type systems", IJCAR 2001, LNCS 2083, 529–544; "Non-deterministic multiple-valued structures", *J. Logic Comput.* 15 (2005) 241–261 [mem; exact formulations unverified]) study multiple-conclusion **canonical** rules:
- a rule introduces $\diamond(p_1..p_n)$ on the left or on the right;
- its premises are sequents built from the $p_i$;
- contexts are arbitrary.

A system is **coherent** if, for every left rule and every right rule for the same connective, the union of their premise sets is classically unsatisfiable. Tonk fails this: the premises $\{\Rightarrow p\}$ and $\{q\Rightarrow\}$ are jointly satisfiable.

Their theorem, as I recall it: for canonical systems, the following are equivalent:
- coherence;
- (strong) cut-admissibility;
- soundness and completeness for a *two-valued non-deterministic matrix* (2Nmatrix).

In that 2Nmatrix, row $\vec a$ of $\diamond$'s table is:
- forced $T$ if some right rule's premises hold at $\vec a$;
- forced $F$ if some left rule's premises hold at $\vec a$;
- $\{T,F\}$ otherwise.

**Corollary 5.1 (ours; probably known in that literature).** For coherent canonical systems:
- **(a) Existence.** Adding coherent canonical rules for a new connective is conservative over any coherent canonical base. This follows from cut-elimination and the subformula property.
- **(b) Uniqueness.** Belnap-uniqueness holds iff the 2Nmatrix is deterministic.

*Sketch of (b).* Put $\diamond$ and $\diamond'$ with the same rules into one system. This is still canonical and coherent. If a row is non-deterministic, a dynamic valuation can choose $T$ for $\diamond(\vec p)$ and $F$ for $\diamond'(\vec p)$, and completeness gives $\diamond(\vec p)\nvdash\diamond'(\vec p)$. If every row is deterministic, $\diamond$ and $\diamond'$ are the same truth function, and completeness gives interderivability.

**This is Carnap's problem at the level of one connective.** Under multiple conclusions, rules fix a *partial* truth table. Categoricity of the connective is the same thing as determinism, which is the same thing as uniqueness. It is a cheap filter: one SAT check over $n$ variables per pair of rules. It is applicable whenever learned rules can be put in canonical form. The canonical format excludes context-restricted rules such as intuitionistic $\to$R and modal rules [extensions exist; unverified].

### 5.4 Post-completeness turns conservativeness into coherence (ours; folklore core)

**Proposition 5.2.**
- *Set-up.*
  - Let $\mathcal L$ contain $\neg$ and $\to$. In general it must contain some single-variable tautology $\top_q$ and contradiction $\bot_q$.
  - Let $\mathcal L'\supseteq\mathcal L$ add new connectives with **schematic** rules.
  - Let $\vdash'$ be the least structural (substitution-closed), reflexive, monotone, transitive relation on $\mathcal L'$ containing $\vdash_{\rm CL}$ and the new rules.
- *Claim.* If $\vdash'$ is not conservative over CL, i.e. $\Gamma\vdash'A$ for some $\Gamma\cup\{A\}\subseteq\mathcal L$ with $\Gamma\nvdash_{\rm CL}A$, then $\vdash'$ is trivial.
- *Size.* From a witness derivation of size $s$, a derivation of $\vdash'B$ for arbitrary $B$ can be built with size polynomial in $s$ and $|\Gamma|+|A|$.

*Proof.*
1. By completeness there is a Boolean $u$ with $u(\Gamma)=T$ and $u(A)=F$. Put $\sigma(p)=\top_q$ if $u(p)=T$ and $\sigma(p)=\bot_q$ otherwise.
2. By induction, $\sigma\varphi$ takes value $u(\varphi)$ under every valuation. So each $\sigma\gamma$ is a tautology and $\sigma A$ is a contradiction, and both facts have polynomial-size CL-proofs by cases on $q$.
3. Structurality gives $\sigma\Gamma\vdash'\sigma A$. Cut with $\vdash_{\rm CL}\sigma\gamma$ gives $\vdash'\sigma A$. Then $\sigma A\vdash_{\rm CL}p$ for a variable $p$, so $\vdash' p$, and structurality on $\mathcal L'$ gives $\vdash' B$ for every $B\in\mathcal L'$. $\square$

*Remarks.*
- **(i)** The same argument shows that CL is a co-atom among structural consequence relations on $\mathcal L$, not only Post-complete at the level of theorems. This is the precise form of H4's "maximal coherent structural extension = truth".
- **(ii)** **For learning.** Over a classical base, a coherence oracle together with an adversarial prover detects *every* non-conservative **schematic** learned rule, and does so constructively. Here adversarial search *helps*: the prover is the tonk detector.
- **(iii)** The argument fails in three cases:
  - over **IPC**: intermediate logics are consistent proper extensions, and adding a classical negation to IPC collapses $\to$ without triviality [mem];
  - over **arithmetic** (Prop. 3.1);
  - for **material, non-schematic rules**: adding $p\vdash q$ for particular atoms is non-conservative but not trivial, because substitution is not available.

  So coherence alone can police logic, but it cannot police material content.

### 5.5 The logical layer can be fixed once, over any material base

- **Hacking** ("What is logic?", *J. Phil.* 76 (1979) 285–319 [mem]): logical constants are those whose sequent rules can be added to *any* base with cut-elimination, hence conservatively.
- **Došen** ("Logical constants as punctuation marks", *NDJFL* 30 (1989) 362–381 [mem]): logical constants are given by double-line rules that internalize structural features, e.g. $\Gamma\vdash A\to B$ iff $\Gamma,A\vdash B$. Uniqueness and conservativeness are then automatic. Sambin, Battilotti & Faggian ("Basic logic: reflection, symmetry, visibility", *JSL* 65 (2000) 979–1013 [mem]) develop the same idea.
- **Hlobil and Brandom.**
  - Hlobil, "A nonmonotonic sequent calculus for inferentialist expressivists" (*Logica Yearbook 2015*, College Publications 2016 [unverified pages]).
  - Brandom, "From logical expressivism to expressivist logic" (*Philosophical Issues* 28 (2018) [unverified]). The user's note *conceptual abstractions.md* links this paper.
  - Hlobil & Brandom, *Reasons for Logic, Logic for Reasons* (Routledge, 2024 [unverified year]).

  As I recall them [unverified details], these works give a calculus ("NM-MS") built as follows:
  - it extends an *arbitrary* SET-SET atomic **material** base, required only to satisfy containment ($\Gamma\cap\Delta\neq\emptyset\Rightarrow\Gamma\mathrel{|\!\sim}\Delta$);
  - the base may be **non-monotonic and non-transitive**;
  - logical connectives are added by invertible rules, without weakening or cut.

  The claimed results:
  - (i) the extension is conservative over the base;
  - (ii) the connectives are "explicitating", e.g. $\Gamma\mathrel{|\!\sim}A\to B,\Delta$ iff $\Gamma,A\mathrel{|\!\sim}B,\Delta$;
  - (iii) over the bare containment base the result is classical logic.

**Design consequence.** The learner should learn the **material base**: domain inferences and incompatibilities, which may be non-monotonic. It should take the logic from a fixed expressivist calculus that is conservative over every base. Learning effort and coherence policing then concentrate where the content is.

### 5.6 Three tiers of new vocabulary

1. **Logical.** Fixed rules (§5.5); harmony and conservativeness are guaranteed by construction.
2. **Definitional.** This is how mathematics introduces vocabulary. Suppes's criteria for proper definitions (*Introduction to Logic*, Van Nostrand 1957, ch. 8 [mem]) are **eliminability** and **non-creativity**, and non-creativity is Belnap-conservativeness. When a learner infers a definition *implicitly* from usage rather than reading an explicit definition, non-creativity must be checked. Over a classical base and for schematic rules, coherence checks it (Prop. 5.2).
3. **Theoretical / material.** Here non-conservativeness is the point: new vocabulary in physics has empirical content.
   - **Ramsey–Carnap split** (Ramsey, "Theories" (1929, publ. 1931); Carnap, *Philosophical Foundations of Physics*, Basic Books 1966; Lewis, "How to define theoretical terms", *J. Phil.* 67 (1970) 427–446 [mem]). For a finite theory $T(\tau,o)$:
     - the Ramsey sentence $R=\exists X\,T(X,o)$ has exactly $T$'s $o$-consequences;
     - the Carnap sentence $C=R\to T(\tau,o)$ is conservative over $o$, because every $o$-model expands;
     - $T\equiv R\wedge C$, and $C$ is the *weakest* sentence with $R\wedge C\models T$.

     This gives a canonical way of splitting a learned theory into a **meaning-constitutive** part ($C$) and a **collateral, empirical** part ($R$).
   - **Dummett's *Boche*** (1973 [mem]; used by Brandom, *Articulating Reasons* ch. 1 [mem]): introduced from "$x$ is German", eliminated to "$x$ is cruel". It is the tonk of material vocabulary, a concept whose rules smuggle in a substantive and false material inference. Brandom's remedy is to *make the inference explicit* with a conditional so that it can be challenged. For our learner: **a learned concept whose rules are non-conservative must have its non-conservative consequences surfaced and sent to world feedback.**

---

## 6. Constitutive versus collateral; material inference; contexts (key question 2)

### 6.1 Positions in the literature

- **Sellars**: material rules are meaning-constitutive.
- **Quine** ("Two dogmas of empiricism", *Phil. Rev.* 60 (1951) 20–43 [mem]): there is no principled analytic/synthetic line, only degrees of centrality in the web.
- **Dummett**: molecularity. Logical constants are constituted by harmonious, conservative rules.
- **Brandom**: holism about material content, with logical vocabulary conservative.
- **Fodor & Lepore** ("Brandom's burdens: compositionality and inferentialism", *PPR* 63 (2001) 465–481 [mem]): inferential-role semantics can be compositional only if restricted to a constitutive subset, which requires an analytic/synthetic distinction. Brandom replies in "Inferentialism and some of its challenges", *PPR* 74 (2007) 651–676 [mem].
- **Boghossian and Peacocke**:
  - Boghossian, "Analyticity reconsidered", *Noûs* 30 (1996) 360–391 [mem];
  - Boghossian, "Blind reasoning", *Proc. Arist. Soc. Supp.* 77 (2003) 225–248 [mem];
  - Peacocke, *A Study of Concepts*, MIT 1992 [mem].

  They hold that some inferences are possession conditions for concepts, but defective concepts such as tonk and Boche show that possession does not by itself entitle.
- **Williamson** ("Understanding and inference", *Proc. Arist. Soc. Supp.* 77 (2003) 249–273; *The Philosophy of Philosophy*, Blackwell 2007 [mem]) uses McGee's rejection of modus ponens ("A counterexample to modus ponens", *J. Phil.* 82 (1985) 462–471 [mem]) and similar experts to argue that *no* particular inference is required for understanding.

**Takeaway.** Treat constitutiveness as **graded and revisable**, not as a fixed label.

### 6.2 Four operational criteria a learner can compute

1. **Formal versus material: substitution invariance.** This is the Bolzano–Brandom variation criterion (*Making It Explicit* ch. 2 [mem]): an inference is formally valid iff it remains good under every substitution of non-logical for non-logical vocabulary. *Learner test:* is the learned rule schematic in all non-logical slots? Is it also *topic-neutral*, i.e. does it hold invariantly across domains and contexts? This is the learner analogue of Tarski–Sher permutation invariance.
2. **Definitional versus substantive: conservativeness** over the old vocabulary (Belnap, Dummett's total harmony). *Learner test:* derivation search for old-vocabulary consequences. Over a classical base this is constructive for schematic rules (Prop. 5.2). In general it is only semi-decidable.
3. **Meaning postulate versus empirical content: the Carnap/Ramsey split** (§5.6). *Learner policy:* accept the conservative part on inferential evidence, and route the non-conservative consequences to world feedback.
4. **Graded centrality: epistemic entrenchment.** Gärdenfors & Makinson ("Revisions of knowledge systems using epistemic entrenchment", *TARK* 1988 [mem]) show that entrenchment orderings correspond to AGM revision functions (Alchourrón, Gärdenfors & Makinson, *JSL* 50 (1985) 510–530 [mem]). *Learner estimate:* frequency of use, invariance across contexts and annotators, deductive centrality (how many accepted derivations use the rule), and survival under past contradictions. *Use:* when a negative bag arrives, revise the least-entrenched member. This is weighted hitting-set repair, i.e. Quine's minimal mutilation.

### 6.3 Brandom–Aker incompatibility semantics and why coherence data alone cannot ground entailment

In *Between Saying and Doing* (OUP 2008), Lecture 5 and the appendix by Alp Aker [mem; exact clauses unverified]:
- an **incoherence** family $\mathrm{Inc}\subseteq\mathcal P(\mathcal L)$ is closed under supersets;
- the incompatibility set of $X$ is $I(X)=\{Y:X\cup Y\in\mathrm{Inc}\}$;
- **incompatibility-entailment** is $X\models A$ iff $I(\{A\})\subseteq I(X)$;
- negation is the minimal incompatible: $X\cup\{\neg A\}\in\mathrm{Inc}$ iff $X\models A$;
- conjunction: $X\cup\{A\wedge B\}\in\mathrm{Inc}$ iff $X\cup\{A,B\}\in\mathrm{Inc}$;
- necessity has a clause quantifying over coherent extensions.

Aker proves that the non-modal logic is classical and that the modal logic is S5. Göcke, Pleitz & von Wulfen give a Kripke-style reconstruction in Prien & Schweikard (eds.), *Robert Brandom: Analytic Pragmatist*, Ontos 2008 [unverified]. This is the most developed "meaning from coherence data" semantics, so it matters for H2's "coherence acts as negative data".

**Proposition 6.1 (ours).** $\models_{\mathrm{Inc}}$ is **not monotone in $\mathrm{Inc}$ in either direction.**

*Example.*
1. With $\mathrm{Inc}_1=\emptyset$, every entailment holds vacuously; in particular $p\models q$.
2. With $\mathrm{Inc}_2=\{X:\{p,q\}\subseteq X\}$ we get $I(q)=\{Y:p\in Y\}\not\subseteq\{Y:q\in Y\}=I(p)$, so $p\not\models q$. Adding incoherences has *removed* an entailment.
3. With $\mathrm{Inc}_3=\{X:X\neq\emptyset\}$, $p\models q$ again. Adding incoherences has *added* an entailment.

**Corollary 6.2 (two-sided certification).** Suppose $\mathrm{Inc}_{\rm lo}\subseteq\mathrm{Inc}^*\subseteq\mathrm{Inc}_{\rm hi}$, where the lower bound comes from observed incoherences and the upper bound from witnessed coherent sets (models, world states). Then
$$X\models_{\rm cert}A\ :\iff\ \forall Y\,\big(Y\cup\{A\}\in\mathrm{Inc}_{\rm hi}\Rightarrow Y\cup X\in\mathrm{Inc}_{\rm lo}\big)$$
is sound for $\models_{\mathrm{Inc}^*}$.

*Proof.* If $Y\cup\{A\}\in\mathrm{Inc}^*\subseteq\mathrm{Inc}_{\rm hi}$, then $Y\cup X\in\mathrm{Inc}_{\rm lo}\subseteq\mathrm{Inc}^*$. $\square$

*Reading.* In a unilateral incompatibility semantics, **incoherence data are themselves positive data about Inc**. Over-estimating and under-estimating them can both make entailment unsound. Sound entailment needs a *sandwich*: incoherences from below, and coherence witnesses (world states, models) from above. This is L1's T7 sandwich, now forced by the semantics.

**Contrast with Restall (§3.5).** If incoherent *bilateral positions* are primitive, entailment is membership and is monotone. For a learner, Restall's primitive is the better choice.

### 6.4 Material inference is non-monotonic, and robustness ranges are contexts

Brandom stresses that material inference is non-monotonic. "If I strike this dry, well-made match, it will light" fails if the match is also in a vacuum. On his *modal Kant–Sellars thesis* (*Between Saying and Doing*, Lecture 4 [mem]), mastering a material inference includes knowing its **range of counterfactual robustness**: the auxiliary hypotheses $\Delta$ under which $\Gamma,\Delta\mathrel{|\!\sim}A$ still holds.

**Mapping.** Learning the guards or side-conditions of a rule (orchestrator idea 3) *is* learning its robustness range. That is learning the modal content of a material inference, and it is learning the contexts in which the rule may be used. An NM-MS-style calculus (§5.5) lets such a non-monotonic base sit under classical logic without collapse.

**Contexts (refining orchestrator idea 1).** Suppose idealization $I$ is stated against the *full* background $K$ with $K\vdash\neg I$. Then the position $[K,I:\ ]$ is incoherent, and under monotone transitive consequence everything follows from it. So "the idealized context is a supposition" is not enough on its own: classical supposition over the full background explodes. The context must import a fragment $K_I$ with $[K_I,I:\ ]$ coherent. $K_I$ is selected in one of two ways:
- by entrenchment (AGM revision $K*I$, the counterfactual reading);
- by explicit designation (L7's "model stipulation", chunk-and-permeate).

*Either way, the selection is an ordering of background commitments by how constitutive they are.* "Keep Newton's laws and arithmetic; drop 'there is an atmosphere'." Key question 2 and the context problem are therefore the same problem.

**Warning.** Gärdenfors's triviality theorem ("Belief revisions and the Ramsey test for conditionals", *Phil. Rev.* 95 (1986) 81–93 [mem]): a conditional that encodes revision via the Ramsey test cannot also satisfy preservation (in non-trivial belief spaces). So context-relative conditionals ("in context $c$, $P$") should live at the meta-level, as in McCarthy's `ist` (see L7), not as an object-language conditional in the monotone base.

---

## 7. Rule-following and non-identifiability (key question 4)

### 7.1 The sources

- **Wittgenstein**, *Philosophical Investigations* (1953) [mem]:
  - §185: the pupil who continues "+2" as 1000, 1004, 1008;
  - §201: "no course of action could be determined by a rule, because every course of action can be made out to accord with the rule";
  - §§217, 242: bedrock; agreement in judgments.
- **Kripke**, *Wittgenstein on Rules and Private Language* (Harvard UP/Blackwell 1982) [mem].
  - Quus: $x\oplus y=x+y$ if $x,y<57$, otherwise $5$.
  - No fact about past use or mental states constitutes meaning plus.
  - Dispositionalism fails on *finitude* (dispositions cover only finitely many cases) and *normativity* (dispositions include errors; meaning must say what is *correct*).
  - Simplicity is rejected as answering an epistemic question when the question is constitutive [page reference unverified].
  - The *skeptical solution* gives assertibility conditions for meaning-attributions within a community practice.
  - Critics: Blackburn, "The individual strikes back", *Synthese* 58 (1984) 281–301 [mem]; Boghossian, "The rule-following considerations", *Mind* 98 (1989) 507–549 [mem].
- **Goodman**, *Fact, Fiction, and Forecast* (Harvard UP 1955) [mem]. Grue/bleen; projectibility via **entrenchment**, i.e. the past projection history of predicates in a community.
- **Lewis**, "New work for a theory of universals" (*AJP* 61 (1983) 343–377) and "Putnam's paradox" (*AJP* 62 (1984) 221–236) [mem].
  - *Naturalness / eligibility*: the intended interpretation best combines fit with use and the naturalness of the referents.
  - Applied explicitly to Kripkenstein: plus is more natural than quus.
  - Answers **Putnam**, "Models and reality" (*JSL* 45 (1980) 464–482) [mem].
  - Williams ("Eligibility and inscrutability", *Phil. Rev.* 116 (2007) 361–399 [mem]) argues that some formulations of eligibility do not defeat permutation arguments [details unverified].

### 7.2 Making the non-identifiability precise

Let $\mathcal H$ be a class of calculi. Let the learner's evidence consist of:
- human steps on a region $D$;
- coherence verdicts;
- world labels on a region $W$;
- community answers to queries on a region $Q$.

The **residual** is
$$\mathrm{Res}=\{R\in\mathcal H:\ R \text{ coherent and agrees with } R^* \text{ on } D\cup W\cup Q\}.$$

No learner can distinguish members of $\mathrm{Res}$. Every reasoner errs, against some member of $\mathrm{Res}$, on the region where members disagree. This is the orchestrator's CIL(d) lower bound, and it is trivially true. The content lies in **which kind of alternatives each resolution removes**. Two kinds must be distinguished:

- **Symmetric alternatives.** These are images $\tau R^*$ under a recoding $\tau$ that preserves every observable relation in every region. Examples are Putnam's permutations and the "which Boolean feature" non-identifiability of CCS. They are *harmless for reasoning*: the conclusions are the same up to relabelling. They matter only at level C (reference).
- **Deviant alternatives.** These agree on the observed regions and differ elsewhere: quus, grue, the +2 pupil. They are *harmful*: they produce wrong conclusions out of distribution.

### 7.3 What each resolution does

| resolution | does | does not | learner counterpart |
|---|---|---|---|
| **Community** (Kripke's skeptical solution; Wittgenstein §242) | Fixes *the target* (what counts as error), answering the normativity question. Averages away idiosyncratic slips (if annotators err independently with rate $\eta<1/2$, majority error decays exponentially in their number). Extends the data indefinitely through new queries: membership queries, as in Angluin's $L^*$ (*Inf. Comput.* 75 (1987) 87–106 [mem]). | Correct *shared* systematic errors (Blackburn's and Boghossian's objection). Fix meaning where no member can compute. | Multi-annotator data; expert queries on the version-space disagreement region (L2's escalation). |
| **World feedback** | Kills deviant alternatives on $W$, and with rules, in regions linked to $W$. | Distinguish symmetric alternatives. Reach regions unconnected to $W$. Refute $\Pi_1$-sound falsehoods (Prop. 3.1). | Truth oracle on a decidable fragment; experiments; numerics. |
| **Coherence** | Transfers evidence between regions through shared rules. Kills *non-uniform* deviants: a rule with a guard "$x,y<57$" clashes with schema-level commitments such as $x+0=x$, which quus violates at $57+0$. | Kill *uniformly gruesome* calculi. The skeptic re-gruesifies every rule (quounting), and coherence is invariant under such recodings. | Negative bags; harmony and conservativeness checks. |
| **Simplicity / naturalness** (Lewis; Solomonoff) | Selects among residual deviants; plus beats quus under any "reasonable" reference machine. With Lewis's objective naturalness, the selection is anchored in the world rather than the language. | Avoid relativity to the representation: for any finite data some reference machine prefers quus (invariance holds only up to a constant). | MDL prior. Note: *imitation pretraining inherits human entrenchment*, which is Goodman's answer implemented. |
| **Efficiency of inquiry** (Schulte, "Means-ends epistemology", *BJPS* 50 (1999) 1–31; Kelly, "Ockham's razor, empirical complexity, and truth-finding efficiency", *TCS* 383 (2007) 270–289 [mem]) | Gives a language-invariant preference. In $\mathcal H=\{\text{plus}\}\cup\{\text{quus}_N\}_N$, a reliable learner achieves at most one mind change only if it never conjectures any quus$_N$ before the deviation at $N$ has been observed. Otherwise the data stream can confirm plus and then deviate later, forcing a second mind change. So it must conjecture plus or suspend judgment. The same holds for green over grue$_t$. | Avoid relativity to the *hypothesis space*. A skeptic can choose $\mathcal H$ so that quus is the accumulation point. | Retraction-minimizing selection rule: conjecture the "limit" hypothesis. |
| **Teleosemantics** (Millikan, *Language, Thought, and Other Biological Categories*, MIT 1984 [mem]; cf. the Shea reference in the user's `meaning.md`) | Answers normativity for *trained* systems: a learned verifier's "meaning" is what training selected it to track, and errors are deviations from that function. | Settle what the trainer's target is; that falls back on community and world. | The training objective as the meaning-fixer. |

**Kripke's finitude objection, for a learned system (ours, design idea).** The learned verifier is finite and makes errors. Define its competence as the MDL-shortest program $p$ such that running $p$ under the system's resource bounds reproduces its dispositions, with errors explained as resource failures. Kripke rejects simplicity for the *constitutive* question about humans. For an engineered system we may *stipulate* this decomposition, and it gives a usable notion of "the rule the system follows".

---

## 8. Theorem candidates suggested by this strand

Status labels: **proved** (proof in this memo; check it), **easy**, **conjecture**, **known** (literature result, to verify).

**L4-T1 (No Horn fix; categoricity requires non-Horn data). Proved (§2.3).**
- *Statement.* For any class of hypotheses or valuations, data restricted to definite Horn clauses (positive steps) and goal clauses (incoherence / negative bags) determine the target only up to closure under non-empty intersections.
- *Consequences:*
  - Carnap's gaps survive any sound single-conclusion data plus "not-both" coherence;
  - multiple-conclusion, bilateral-with-complementarity, compositional, or bivalent world-feedback information is *necessary* for classical $\neg$ and $\vee$;
  - at level A, Horn data make the cautious learner well-defined and sound.
- *Use.* An impossibility result showing that coherence of the "no P and ¬P" kind alone never yields truth-conditional determinacy. It pairs with L1 T1 to give one "format theorem" covering both levels.

**L4-T2 (Format collapse = expressivism). Easy/proved modulo L1 §8.3.** Three parts:
- *Deduction theorem.* The theorems determine the consequence relation iff the hypothesis class is restricted to relations with a deduction theorem for a fixed $\to$ (L1).
- *Bilateral bridge.* SET-FMLA data plus the bridge "$-A\Leftrightarrow+\neg A$" determine the SET-SET relation and hence the Boolean class.
- *Disjunction bridge.* SET-FMLA data plus "$\Gamma\vdash A,B\iff\Gamma\vdash A\vee B$" do likewise.
- *Paper role.* A formal version of "logical vocabulary makes inferential structure explicit", stated as identifiability: each piece of expressive vocabulary trades one data format for another, at the price of an unconfirmable bridge principle.

**L4-T3 (Post-completeness ⇒ coherence detects every structural tonk). Proved (Prop. 5.2).**
- *Positive part.* Over a classical base, every schematic non-conservative learned rule set yields $\bot$ via an explicit polynomial-size derivation. A sound learner equipped with a coherence alarm and an adversarial prover therefore converges, removing over-generalized schemas, if each alarm triggers a hitting-set repair.
- *Negative part.* Explicit counterexamples:
  - IPC with a collapsing classical negation;
  - PA with $\neg\mathrm{Con}$;
  - material atomic rules.
- *Paper role.* It refines H1 and H4: adversarial search is *helpful* at the logical level, and coherence is complete for logic but not for material content.

**L4-T4 (Decidable Belnap filter for canonical learned connectives). Known (Avron–Lev) plus corollary (ours).**
- *Statement.* For learned rules in canonical multiple-conclusion form:
  - coherence (a SAT check per rule pair) ⇒ cut-admissibility ⇒ conservativeness over any canonical coherent base;
  - the learned connective's meaning is a partial truth table (a 2Nmatrix);
  - Belnap-uniqueness ⇔ determinism of that table.
- *Paper role.* This is "Carnap's problem per connective": the residual indeterminacy of a learned connective is exactly the set of its non-deterministic rows.
- *Conjectured learning corollary (ours, unchecked).* Positive multiple-conclusion examples of a connective's use fill in rows cautiously. Each informative example forces at least one of the $2^k$ rows of a $k$-ary connective. So a target with a deterministic table is identified after at most $2^k$ informative examples, provided the learner's rule format is canonical. Full identification needs both right-rule (assertion) and left-rule (denial) examples. Setting this up properly requires a definition of "cautious generalization of an instance to a canonical rule", which I have not checked.

**L4-T5 (Inversion is anti-cautious; harmony failures are negative bags). Proved (Prop. 4.1 and §4.1).**
- *Statement.*
  - Inversion from incompletely learned introduction rules is unsound.
  - Harmony between cautiously learned intro and elim rules is a necessary condition, so each failure is a negative bag.
  - Local harmony plus a complexity/positivity condition plus normalization ⇒ conservativeness (standard).
- *Paper role.* It covers the H5 story: naive comprehension is harmonious but non-positive, Russell's paradox is the non-normalizing witness, and Separation is the repair.

**L4-T6 (Incompatibility semantics needs a sandwich). Proved (Prop. 6.1, Cor. 6.2).**
- *Statement.* Brandom–Aker incompatibility-entailment is non-monotone in the incoherence data in both directions. Sound certification of entailments requires an upper bound on Inc from coherence witnesses. In contrast, Restall-style incoherence of bilateral positions is monotone.
- *Paper role.* It decides between "coherence as the semantic primitive" designs.

**L4-T7 (Arithmetic: computation cannot exclude Π₁-sound falsehoods). Proved (Prop. 3.1).**
- *Statement.*
  - No learner whose world feedback is computation, and whose coherence is consistency, can be guaranteed to reject $\mathsf{PA}+\neg\mathrm{Con}(\mathsf{PA})$ on the basis of evidence alone.
  - The witness policy, the Kelly–Ockham $\Pi_1$-first policy, and the $\omega$-rule each exclude it.
  - The $\Pi_1$-first policy identifies $\mathrm{Th}_{\Sigma_1\cup\Pi_1}(\mathbb N)$ in the limit with at most one mind change per sentence.
- *Possible extension (conjecture).* A characterization of which levels of the arithmetical hierarchy are identifiable under computation feedback plus coherence plus a fixed policy, presumably Kelly's $\Delta_2$ bound.

**L4-T8 (Ramsey–Carnap decomposition of learned vocabulary). Conjecture (proof-theoretic version).**
- *Setting.* Base rules $B$ over old vocabulary $o$. Learned rules $R_\tau$ for new vocabulary $\tau$. Let $\mathrm{Coll}(R_\tau)=\mathrm{Cn}_{B\cup R_\tau}\cap\mathcal L_o\setminus\mathrm{Cn}_B$ be the collateral (non-conservative) content.
- *Claims.*
  - (i) Any reasoner that accepts $R_\tau$ makes old-vocabulary errors *only* through $\mathrm{Coll}(R_\tau)$.
  - (ii) Some "Carnap-rule" set $C_\tau$ is conservative and, together with $\mathrm{Coll}(R_\tau)$ taken as axioms, derives everything $R_\tau$ does.
- *Status of each part.* (i) is trivial. (ii) holds model-theoretically in second-order form. Whether a *rule-level* $C_\tau$ exists in a first-order or proof-theoretic setting is open, and I expect it only for restricted formats.
- *Paper role.* A principled "route non-conservative consequences to world feedback" policy for physics vocabulary.

**L4-T9 (Kripkenstein division of labour). Easy (definitions) plus known (Schulte/Kelly).**
- *Statement.*
  - Membership queries eliminate deviants on $Q$.
  - Coherence eliminates exactly the deviants that are not closed under the coherence-preserving recodings that fix $D\cup W\cup Q$.
  - Mind-change-optimal selection picks the accumulation-point hypothesis. In $\{\text{plus}\}\cup\{\text{quus}_N\}$ that hypothesis is plus.
  - Symmetric alternatives are harmless for every derivational query.
- *Paper role.* A precise answer to H7 that says which mechanism does which work.

**L4-T10 (Contexts need constitutive orderings). Easy, plus the known AGM representation.**
- *Statement.*
  - Under monotone transitive consequence, an idealization that contradicts the background trivializes unless a fragment is selected.
  - Fragment selection by an entrenchment ordering is equivalent to AGM revision (Gärdenfors–Makinson).
  - Hence the learner must learn an entrenchment or designation over background commitments, and this is learnable from positive examples of contexts that experts actually set up.
- *Paper role.* It ties key question 2 to H6.

---

## 9. Where the brief's hypotheses need correction or refinement

1. **H3: "Carnap ≈ semantic twin of Gold".**
   - *Partly right.* Both are cases of "restricted data formats represent only closure-closed classes", and in both the top element (tonk / $\Sigma^*$ / the all-true valuation) is removed by empty-head constraints.
   - *Wrong in two ways.*
     - Carnap's problem is *static*: it persists with complete data. Gold's is *dynamic*.
     - Carnap's real level-A twin is L1's theorems-versus-steps interval.
   - *The coherence loss.* The user's "not both P and ¬P" loss is Horn. It removes only triviality; Carnap's gaps (level B) survive it.
   - *Restall's reading needs denial.* It fixes level B only when denial is read as exhaustive. That reading is supplied by bilateral bridges or bivalent world feedback, not by the "not-both" loss.
2. **Separate levels A, B and C** (§1.3). H7's "alternative meanings" mixes three things:
   - deviant calculi (level A, harmful);
   - non-normal logical semantics (level B, harmless for derivation);
   - permutation/reference alternatives (level C, harmless for derivation; matters for grounding).

   CCS's non-identifiability (Farquhar et al. 2023 [mem]) is level C.
3. **Level B does not matter for "a reasoner that derives many correct conclusions"**, but it does matter for interpreting world feedback and for "verification from truth". The gappy, supervaluational status function is the *correct* semantics for an incomplete reasoner. It is the user's true/false/independent triple.
4. **H4.**
   - *Right:* Post-completeness of CL holds even at the level of structural consequence relations (Prop. 5.2, remark i).
   - *Missing:* the arithmetic failure is sharper than "many coherent extensions". There are coherent, **$\Pi_1$-sound** false extensions that computation can never refute (Prop. 3.1). What closes the gap is a *policy* (witness demand, $\Pi_1$-first Ockham, or the $\omega$-rule), not more feedback.
5. **H2 Remedy 2 ("coherence acts as negative data").** Correct as negative bags over *steps*. But if coherence is made the *semantic primitive* (Brandom–Aker), incoherence data become *positive* data about Inc, and the entailments they induce are non-monotone in it (Prop. 6.1). Use Restall's bilateral positions, or a two-sided sandwich.
6. **H1 (tonk).** Tonk's damage runs entirely through cut, i.e. chaining (Cook, Ripley). Over a classical base the danger is self-revealing: an adversarial prover will produce the $\bot$-derivation (Prop. 5.2). The truly dangerous over-generalizations are **material**, non-schematic ones, which coherence cannot catch, and **$\Pi_1$-sound** ones in arithmetic. Worst-case soundness matters most exactly there.
7. **New vocabulary.** Do not learn logical connectives. Fix them by base-universal, conservative rules (Hacking, Došen, Hlobil–Brandom), since functional completeness means nothing new is gained. Learn the *material base* and the *non-logical vocabulary*. Enforce:
   - non-creativity for definitions;
   - harmony plus positivity for inductive definitions;
   - Ramsey/Carnap routing for theoretical terms.
8. **Orchestrator idea 1 ("idealized context = supposition").** This needs a fix. Supposition over the *full* background explodes when $K\vdash\neg I$. The context must import a fragment selected by an entrenchment ordering or by designation. So "what is constitutive" (key question 2) and "how to set up a context" (H6) are the same problem.
9. **Orchestrator idea 3 (guards).** Guards are Brandom/Sellars *ranges of counterfactual robustness*. Learning guards is learning the modal content of material inferences. A non-monotonic material base, with logic layered conservatively on top (NM-MS), is the matching formal home.
10. **Gentzen's "intros define meaning" as a learning recipe** is anti-cautious (Prop. 4.1). It is right for mathematical definitions, which are closed-world by fiat. It is wrong for empirical concepts. The brief's inferentialist framing ("learning inference rules = learning meanings") should state which half (intros, elims or both) is learned and which is derived.
11. **Constitutiveness is graded.** Williamson-style counterexamples (McGee and modus ponens) show that experts can reject any particular inference without failing to understand it. The learner should maintain an entrenchment score, not a constitutive/collateral bit.

---

## 10. References

All bibliographic data are from memory. None were re-checked online this session (no web access).
- **[mem]**: confident.
- **[unverified]**: some uncertainty about details, venue, year or pages.

- Alchourrón, C., Gärdenfors, P., Makinson, D. (1985). On the logic of theory change: partial meet contraction and revision functions. *JSL* 50:510–530. [mem]
- Angluin, D. (1987). Learning regular sets from queries and counterexamples. *Information and Computation* 75:87–106. [mem]
- Avron, A., Lev, I. (2001). Canonical propositional Gentzen-type systems. *IJCAR 2001*, LNCS 2083, 529–544. [mem; theorem formulation unverified]
- Avron, A., Lev, I. (2005). Non-deterministic multiple-valued structures. *J. Logic and Computation* 15:241–261. [mem]
- Belnap, N. (1962). Tonk, plonk and plink. *Analysis* 22:130–134. [mem]
- Beth, E. W. (1953). On Padoa's method in the theory of definition. *Indagationes Mathematicae* 15:330–339. [mem]
- Blackburn, S. (1984). The individual strikes back. *Synthese* 58:281–301. [mem]
- Boghossian, P. (1989). The rule-following considerations. *Mind* 98:507–549. [mem]
- Boghossian, P. (1996). Analyticity reconsidered. *Noûs* 30:360–391. [mem]
- Boghossian, P. (2003). Blind reasoning. *Proc. Aristotelian Soc. Supp.* 77:225–248. [mem]
- Bonnay, D., Westerståhl, D. (2016). Compositionality solves Carnap's problem. *Erkenntnis* 81:721–739. [mem; theorem details unverified]
- Brandom, R. (1994). *Making It Explicit*. Harvard UP. [mem]
- Brandom, R. (2000). *Articulating Reasons*. Harvard UP. [mem]
- Brandom, R. (2007). Inferentialism and some of its challenges. *PPR* 74:651–676. [mem]
- Brandom, R. (2008). *Between Saying and Doing* (with an appendix by A. Aker). OUP. [mem]
- Brandom, R. (2018). From logical expressivism to expressivist logic: sketch of a program and some implementations. *Philosophical Issues* 28. [unverified]
- Burns, C., Ye, H., Klein, D., Steinhardt, J. (2022/2023). Discovering latent knowledge in language models without supervision. arXiv 2212.03827; ICLR 2023. [mem]
- Carnap, R. (1934/1937). *Logische Syntax der Sprache* / *The Logical Syntax of Language*. [mem]
- Carnap, R. (1935). Ein Gültigkeitskriterium für die Sätze der klassischen Mathematik. *Monatshefte für Mathematik und Physik* 42:163–190. [mem]
- Carnap, R. (1943). *Formalization of Logic*. Harvard UP. [mem]
- Carnap, R. (1966). *Philosophical Foundations of Physics* (ed. M. Gardner). Basic Books. [mem]
- Carroll, L. (1895). What the tortoise said to Achilles. *Mind* 4:278–280. [mem]
- Cobreros, P., Égré, P., Ripley, D., van Rooij, R. (2012). Tolerant, classical, strict. *JPL* 41:347–385. [mem]
- Cook, R. (2005). What's wrong with tonk(?). *JPL* 34:217–226. [mem]
- Došen, K. (1989). Logical constants as punctuation marks. *NDJFL* 30:362–381. [mem]
- Došen, K., Schroeder-Heister, P. (1985). Conservativeness and uniqueness. *Theoria* 51:159–173. [mem]
- Došen, K., Schroeder-Heister, P. (1988). Uniqueness, definability and interpolation. *JSL* 53:554–570. [mem]
- Dummett, M. (1973). *Frege: Philosophy of Language*. Duckworth. [mem]
- Dummett, M. (1991). *The Logical Basis of Metaphysics*. Harvard UP. [mem]
- Farquhar, S., Varma, V., Kenton, Z., Gasteiger, J., Mikulik, V., Shah, R. (2023). Challenges with unsupervised LLM knowledge discovery. arXiv. [mem; number unverified]
- Fodor, J., Lepore, E. (2001). Brandom's burdens: compositionality and inferentialism. *PPR* 63:465–481. [mem]
- Gärdenfors, P. (1986). Belief revisions and the Ramsey test for conditionals. *Phil. Review* 95:81–93. [mem]
- Gärdenfors, P., Makinson, D. (1988). Revisions of knowledge systems using epistemic entrenchment. *TARK 1988*, 83–95. [mem]
- Garson, J. (2001). Natural semantics: why natural deduction is intuitionistic. *Theoria* 67:114–139. [mem]
- Garson, J. (2013). *What Logics Mean: From Proof Theory to Model-Theoretic Semantics*. CUP. [mem; precise theorems unverified]
- Gentzen, G. (1935). Untersuchungen über das logische Schließen I, II. *Math. Zeitschrift* 39:176–210, 405–431. [mem]
- Göcke, B., Pleitz, M., von Wulfen, H. (2008). How to Kripke Brandom's notion of necessity. In Prien & Schweikard (eds.), *Robert Brandom: Analytic Pragmatist*, Ontos. [unverified]
- Goodman, N. (1955). *Fact, Fiction, and Forecast*. Harvard UP. [mem]
- Hacking, I. (1979). What is logic? *J. Philosophy* 76:285–319. [mem]
- Hallnäs, L., Schroeder-Heister, P. (1990/1991). A proof-theoretic approach to logic programming I, II. *J. Logic and Computation* 1. [mem]
- Hardegree, G. (2005). Completeness and super-valuations. *JPL* 34:81–95. [unverified details]
- Hjortland, O. (2014). Speech acts, categoricity, and the meanings of logical connectives. *NDJFL* 55:445–467. [unverified]
- Hlobil, U. (2016). A nonmonotonic sequent calculus for inferentialist expressivists. In *The Logica Yearbook 2015*, College Publications. [unverified]
- Hlobil, U., Brandom, R. (2024). *Reasons for Logic, Logic for Reasons*. Routledge. [unverified year and details]
- Horn, A. (1951). On sentences which are true of direct unions of algebras. *JSL* 16:14–21. [mem]
- Humberstone, L. (2000). The revival of rejective negation. *JPL* 29:331–381. [mem]
- Humberstone, L. (2011). *The Connectives*. MIT Press. [mem]
- Incurvati, L., Smith, P. (2010). Rejection and valuations. *Analysis* 70:3–10. [mem; content as described unverified]
- Kelly, K. (1996). *The Logic of Reliable Inquiry*. OUP. [mem]
- Kelly, K. (2007). Ockham's razor, empirical complexity, and truth-finding efficiency. *TCS* 383:270–289. [mem]
- Kripke, S. (1982). *Wittgenstein on Rules and Private Language*. Harvard UP / Blackwell. [mem]
- Lewis, D. (1970). How to define theoretical terms. *J. Philosophy* 67:427–446. [mem]
- Lewis, D. (1983). New work for a theory of universals. *AJP* 61:343–377. [mem]
- Lewis, D. (1984). Putnam's paradox. *AJP* 62:221–236. [mem]
- Lorenzen, P. (1955). *Einführung in die operative Logik und Mathematik*. Springer. [mem]
- Martin-Löf, P. (1984). *Intuitionistic Type Theory*. Bibliopolis. [mem]
- McGee, V. (1985). A counterexample to modus ponens. *J. Philosophy* 82:462–471. [mem]
- McGee, V. (2015). The categoricity of logic. In Caret & Hjortland (eds.), *Foundations of Logical Consequence*, OUP. [unverified]
- McKinsey, J. C. C. (1943). The decision problem for some classes of sentences without quantifiers. *JSL* 8:61–76. [mem]
- Millikan, R. (1984). *Language, Thought, and Other Biological Categories*. MIT Press. [mem]
- Murzi, J., Hjortland, O. (2009). Inferentialism and the categoricity problem: reply to Raatikainen. *Analysis* 69:480–488. [mem]
- Murzi, J., Topey, B. (2021). Categoricity by convention. *Phil. Studies* 178:3391–3420. [unverified pages]
- Peregrin, J. (2010). Inferentializing semantics. *JPL* 39:255–274. [unverified]
- Peregrin, J. (2014). *Inferentialism: Why Rules Matter*. Palgrave Macmillan. [mem]
- Pfenning, F., Davies, R. (2001). A judgmental reconstruction of modal logic. *MSCS* 11:511–540. [mem]
- Piecha, T., de Campos Sanz, W., Schroeder-Heister, P. (2015). Failure of completeness in proof-theoretic semantics. *JPL* 44:321–335. [mem]
- Piecha, T., Schroeder-Heister, P. (2019). Incompleteness of intuitionistic propositional logic with respect to proof-theoretic semantics. *Studia Logica* 107:233–246. [mem]
- Prawitz, D. (1965). *Natural Deduction: A Proof-Theoretical Study*. Almqvist & Wiksell. [mem]
- Prawitz, D. (1971). Ideas and results in proof theory. *Proc. 2nd Scandinavian Logic Symposium*, North-Holland, 235–307. [mem]
- Prawitz, D. (1973). Towards a foundation of a general proof theory. *LMPS IV*, North-Holland, 225–250. [mem]
- Prawitz, D. (1974). On the idea of a general proof theory. *Synthese* 27:63–77. [mem]
- Prior, A. N. (1960). The runabout inference-ticket. *Analysis* 21:38–39. [mem]
- Prior, A. N. (1964). Conjunction and contonktion revisited. *Analysis* 24:191–195. [mem]
- Putnam, H. (1980). Models and reality. *JSL* 45:464–482. [mem]
- Quine, W. V. O. (1951). Two dogmas of empiricism. *Phil. Review* 60:20–43. [mem]
- Raatikainen, P. (2008). On rules of inference and the meanings of logical constants. *Analysis* 68:282–287. [mem]
- Ramsey, F. P. (1929/1931). Theories. In *The Foundations of Mathematics*. [mem]
- Read, S. (2000). Harmony and autonomy in classical logic. *JPL* 29:123–154. [mem]
- Read, S. (2010). General-elimination harmony and the meaning of the logical constants. *JPL* 39:557–576. [mem]
- Restall, G. (2005). Multiple conclusions. In Hájek et al. (eds.), *Logic, Methodology and Philosophy of Science: Proc. 12th Int. Congress*, King's College Publications, 189–205. [mem]
- Restall, G. (2009). Truth values and proof theory. *Studia Logica* 92:241–264. [mem]
- Ripley, D. (2013). Paradoxes and failures of cut. *AJP* 91:139–164. [mem]
- Ripley, D. (2015). Anything goes. *Topoi* 34:25–36. [mem]
- Ripley, D. (2017). Bilateralism, coherence, warrant. In Moltmann & Textor (eds.), *Act-Based Conceptions of Propositional Content*, OUP. [unverified]
- Rumfitt, I. (2000). "Yes" and "No". *Mind* 109:781–823. [mem]
- Sambin, G., Battilotti, G., Faggian, C. (2000). Basic logic: reflection, symmetry, visibility. *JSL* 65:979–1013. [mem]
- Sandqvist, T. (2015). Base-extension semantics for intuitionistic sentential logic. *Logic J. IGPL* 23:719–731. [mem]
- Schroeder-Heister, P. (1984). A natural extension of natural deduction. *JSL* 49:1284–1300. [mem]
- Schulte, O. (1999). Means-ends epistemology. *BJPS* 50:1–31. [mem]
- Scott, D. (1974). Completeness and axiomatizability in many-valued logic. *Proc. Tarski Symposium*, AMS Proc. Symp. Pure Math. 25, 411–435. [mem]
- Sellars, W. (1953). Inference and meaning. *Mind* 62:313–338. [mem]
- Sellars, W. (1954). Some reflections on language games. *Philosophy of Science* 21:204–228. [mem]
- Sellars, W. (1969). Language as thought and as communication. *PPR* 29:506–527. [mem]
- Sher, G. (1991). *The Bounds of Logic*. MIT Press. [mem]
- Shoesmith, D. J., Smiley, T. J. (1978). *Multiple-Conclusion Logic*. CUP. [mem]
- Smiley, T. (1996). Rejection. *Analysis* 56:1–9. [mem]
- Stafford, W. (2021). Proof-theoretic semantics and inquisitive logic. *JPL* 50. [unverified]
- Steinberger, F. (2011). What harmony could and could not be. *AJP* 89:617–639. [mem]
- Stevenson, J. T. (1961). Roundabout the runabout inference-ticket. *Analysis* 21:124–128. [mem]
- Suppes, P. (1957). *Introduction to Logic*. Van Nostrand. [mem]
- Suszko, R. (1977). The Fregean axiom and Polish mathematical logic in the 1920s. *Studia Logica* 36:377–380. [unverified details]
- Tarski, A. (1986). What are logical notions? *History and Philosophy of Logic* 7:143–154. [mem]
- Tennant, N. (1982). Proof and paradox. *Dialectica* 36:265–296. [mem]
- van Fraassen, B. (1966). Singular terms, truth-value gaps, and free logic. *J. Philosophy* 63:481–495. [mem]
- Waismann, F. (1945). Verifiability. *Proc. Aristotelian Soc. Supp.* 19:119–150. [mem]
- Williams, J. R. G. (2007). Eligibility and inscrutability. *Phil. Review* 116:361–399. [mem]
- Williamson, T. (2003). Understanding and inference. *Proc. Aristotelian Soc. Supp.* 77:249–273. [mem]
- Williamson, T. (2007). *The Philosophy of Philosophy*. Blackwell. [mem]
- Wittgenstein, L. (1953). *Philosophical Investigations*. Blackwell. [mem]
- Wójcicki, R. (1988). *Theory of Logical Calculi*. Kluwer. [mem]
- Woods, J. (2012). Failures of categoricity and compositionality for intuitionistic disjunction. *Thought* 1:281–291. [unverified]
- Zucker, J., Tragesser, R. (1978). The adequacy problem for inferential logic. *JPL* 7:501–516. [mem]
