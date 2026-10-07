# L9 — Physics olympiad solutions, and how physics reasoning could be checked in a principled way

*Literature memo, strand L9, for the inferential-learning project. Written against `00-brief.md` (especially H1, H6, H7) and building on L7 (contexts, idealization, export), which already covers the philosophy of idealization (McMullin, Laymon, Norton, Batterman, Wilson), compositional modeling (Falkenhainer–Forbus, Nayak, Weld, Addanki et al.), the context-tree calculus, the export-certificate taxonomy E1–E10 and the "no free export" proposition. I do not repeat those. This memo adds:*
* *the anatomy of real olympiad solutions and marking schemes;*
* *the physicist's coherence checks, formalized, with their different logical roles;*
* *formalized physics as it exists in late 2026;*
* *AI solving and grading;*
* *a concrete checker design;*
* *three fully worked problem decompositions, with numerical verification.*

**Verification policy.** Web search and web fetch were unavailable in this session: the search budget was exhausted and every host was blocked by the proxy. I was, however, able to clone public GitHub repositories. That let me read primary material directly:
* **Physlib** (formerly HepLean/PhysLean), commit `d630c36`, 2 Oct 2026;
* the READMEs and code of OlympiadBench, UGPhysics, PhysReason, HiPhO, Physics Supernova and P1;
* the full **IPhO 2025** theory texts (in the Physics Supernova repo);
* the **official IPhO 2025 Problem 2 solution with its marking scheme** (a PDF in the P1 repo).

Claims based on these are marked **[repo-verified]**. All numerical claims about the worked problems were recomputed by me in Python/SymPy and are marked **[computed]**. The scripts are in `research/lit/L9-scripts/` (`ballistics.py`, `leg.py`, `leg2.py`, `protostar.py`); the Cox-timepiece and asymptotic-equivalence checks were inline one-offs. Everything else is from memory. Bibliographic items I am confident of are given plainly; anything with uncertain details is marked **[unverified]**. Before anything is cited in the paper it should be re-checked against the source.

---

## 0. Bottom line

1. **A physics olympiad solution is a DAG of clear local models joined by bridges, rooted in a reading of the problem.** This makes the user's "dance with many clear setups" precise. In the three problems analysed in §8, most bridges are *exact* reformulations: symmetries (time reversal), decompositions (horizontal and vertical components of a reflection), isomorphisms (radial infall as a degenerate Kepler orbit), and Archimedes-type identities. Exact bridges are ordinary theorems. Only a handful of bridges are *approximations*. Of those, the problem statement usually *stipulates* them or *states their regime*. Occasionally it even *quantifies them first* and only then adopts them: IPhO 2025 T2 computes ε = P_sat/P₀ ≈ 1.6×10⁻⁶ and then says "take P_sat = 0" [repo-verified]. The irreducibly informal part is small and identifiable. It is the **reading** (text and figure → admissible model family), plus a few **solver-introduced idealizations**, which official solutions justify by order-of-magnitude remarks or not at all.

2. **The checks physicists use are not one kind of thing.** They have at least four logical roles, which the brief's H6 list lumps together:
   * **Invariance constraints on the rule set.** Dimensional homogeneity and context symmetries are worst-case checkable, and they generate negative data for free.
   * **In-model theorems.** Conservation laws check computations.
   * **Regression tests against other contexts.** Limiting cases are valid only for *regular* limits.
   * **Export-side plausibility.** Order-of-magnitude estimates and the check that a neglected term is small belong here.

   Only the first two are "coherence" in the brief's sense. The third is cross-context and the fourth is about bridges.

3. **Dimensional analysis is the cleanest case anywhere of "learning meanings from positive examples".** The dimension of a quantity *is* its inferential role: what it may be added to or equated with. Dimension inference from observed equations is linear algebra over ℤ (Smith normal form). A *finest* grading consistent with the data exists and is unique. Positive data never refutes a coarser one (a miniature Gold theorem), and the residual non-identifiability is exactly the conventional choice of base dimensions and of which constants are dimensional: SI versus Gaussian versus natural units. This is a fully worked instance of H7 (§3.1, TC1).

4. **Many problem contexts are literally inconsistent at the idealized limit but consistent along the limit.** Examples are rigid bodies with Coulomb friction (Painlevé), and a uniform isothermal gas ball with vacuum outside. I propose **germ semantics**: an idealized context is a model family M_ε together with a limit. "φ holds in c" means "φ holds in M_ε for all sufficiently small ε". Equivalently, φ holds in one nonstandard model with ε infinitesimal (§2.3, TC3). This refines L7's Proposition 2. Well-posedness should be required *along the family*, not at ε = 0.

5. **Grading practice already encodes a precise semantics.** The official IPhO 2025 T2 marking scheme accepts expressions "with or without using S_t ≪ S_b, S_c" and grades numbers by intervals (e.g. W* ∈ [19, 21] mJ) [repo-verified].
   * So answers are graded **modulo asymptotic equivalence in the declared small parameters, plus a numeric tolerance**.
   * For exp-log answers in one small parameter this relation is mechanically decidable in practice (Gruntz's limit algorithm, in SymPy) (§3.3, TC4).
   * I computed the leading-order error in the official C.4 answer: 1.3%. That is inside the ±5% marking interval [computed]. A checker should *verify* this kind of inclusion: approximation error ≤ answer tolerance.

6. **For physics, simulation of the top model is to export rules what Schwartz–Zippel evaluation is to algebraic rules.** It is a cheap, unlimited truth oracle, but *relative to the top model* M_top, not to the world. I checked the EuPhO 2025 T1(a) answer, E = (aI₀/2)|sin(φ/2)|/r, by Monte Carlo ray tracing on a finite cylinder. For r ≳ 35a it agrees within the ~3% Monte Carlo noise, at each sun elevation tried (α = 30°, 50°, 70°). Near the leg the thin-leg error grows roughly like a/r (at α = 45°): up to ~7% at r = 20a, 3–12% at r = 10a and 10–35% at r = 2–3a [computed]. Validated numerics (Tucker; Immler's verified ODE solver in Isabelle) can turn such checks into proofs.

7. **AI already scores at gold level on IPhO 2025 theory under rubric grading, but not on the modeling-heavy EuPhO 2025.**
   * HiPhO data (version 2025-09-16): IPhO 2025 best model 22.7/29.4 (Gemini-2.5-Pro), GPT-5 22.3, P1-235B + PhysicsMinions 23.2; gold threshold 19.7; best human 29.2.
   * EuPhO 2025: best model 14.9/29, *below* the gold threshold of 16.5; best human 27.0.
   * HiPhO's README later reports that Gemini-3-Pro reached gold on all 13 olympiads (Dec 2025).

   [all repo-verified] The grading is LLM-mediated, rubric-based and average-case, and current agents' "review" modules are LLM self-checks. This is precisely the regime H1 warns about. The open problem is *principled checking*, not solving.

8. **Existing formal physics is real but thin where olympiads live.**
   * Physlib has a semantic definition of dimensional correctness: invariance under unit rescaling.
   * It formalizes small-angle pendulum residual bounds.
   * It has the pendulum period formula with continuity and monotonicity in the amplitude. But the identification of that formula with the nonlinear ODE's period is an explicit TODO.
   * Its optics directory is a placeholder.
   * It has nothing on projectiles, Kepler or thin lenses, and no Buckingham Π theorem.

   [repo-verified] Export certificates are formalizable, but the labour is substantial. That argues for a checker that mixes kernel-checked math, CAS and validated numerics, rather than demanding full formalization.

9. **Closest precedent for a principled checker: the Andes physics tutor** (VanLehn et al. 2005). Students declare variables and principles. Each entered equation is checked for units and checked against the solution values of the author-supplied model. That is exactly the in-model (F) layer of the checker proposed here. Andes never checks bridges, because the idealizations are fixed by the problem author.

---

## 1. Digest of the user's notes (what the design must respect)

* **"Not quite math problems … a dance with many clear setups, with some relations to the physical problem of interest … contradictions being provable from stuff."** And: "how would we verify a suggested way to turn the problem into a clear (math) problem?" Restatements are allowed, but not ones that make part of the solution "go away". **Hypothesis: "there's a local setting up of a clear thing."** (`the structure of physics olympiad solutions.md`)

* **Physics should follow the precedent of math.** Formalizing math meant creating a language into which proofs can be translated, not translating word for word. So a physics protocol may reject existing solutions that leave things out or say false things. (`… general principles.md`)

* **A solution as a proof.** A solution is roughly "a proof that φ(x) implies x = something", with existence presupposed. (`cases of verification.md`)

* **Symmetry needs uniqueness.** "Symmetry of problem is used to imply symmetry of solution, but … it only implies symmetry of the set of solutions. Symmetry of a single solution is implied if we make the further assumption that there is a unique solution." (`physics/symmetry.md`)

* **Truth in a context.** "Verification from truth: check that a claim is true in the context at hand. But wtf is that???" (`verification from truth.md`)

* **Inadequate conceptions.** We assign probabilities in a conceptual frame we know to be inadequate. Treating each sentence as ANDed with the whole frame gives probability 0 to everything. Proofs by contradiction can "subvert the background framework". (`assigning probabilities in a conception of the world you know to be inadequate.md`)

  This is the same phenomenon as an idealized context being literally inconsistent, and germ semantics (§2.3) is one answer.

* **EuPhO 2025 T1 introspection.** The solving process is a sequence of *questions that complete the model*:
  * mirror or diffuse?
  * what does "illuminance surplus" mean?
  * which direction is the light from?
  * is the finger horizontal?

  It also contains a key *invariance conjecture*: "the angle from horizontal turns out not to matter". That conjecture was first held, then doubted because of an algebra slip, then confirmed. Its formal counterpart is the completion-independence certificate (TC7).

* **The thermodynamics lecture note justifies the mirror-wall idealization by a second-law argument:** "pressure cannot change if you change the wall, because otherwise you'd have a way to get infinite work from a gas". This is a coherence argument that justifies an idealization choice by showing that the answer is invariant across admissible completions. It is a nice example of E1/E6 reasoning in the wild.

---

## 2. The structure of olympiad solutions (strand item a)

### 2.1 Anatomy: reading, local models, bridges, export

Abstracting from the problems in §8, every solution I examined has the following parts.

* **Root context c_P.** This is the problem text plus figures plus conventions. Following L7 §10.4, the graded "world" is c_P, not the actual world.

* **Reading ρ.** The reading maps c_P to an *admissible model family* 𝓜_P, which may be one model or a family with free completion parameters. It also fixes the *query functional* Q. The reading includes:
  * entity identification (the leg is a vertical specular cylinder; the sun is a parallel beam);
  * quantity definitions ("illuminance surplus" means the reflected irradiance on the floor);
  * extraction of data from figures;
  * the "express in terms of" list, which is a **type signature** for the answer.

* **Local models M_i.** Each is a clear mathematical problem: a signature with dimensions, equations or inequalities, and a query.

* **Bridges between models.** Bridges come in two kinds.
  * *Exact* reformulations: symmetry, decomposition, isomorphism, change of variables, an identity.
  * *Approximate* ones: a small parameter is set to its limit, together with an error claim.

* **Export.** Export is the final claim about Q in c_P. Its form is "Q = q exactly in c_P", "Q ∼ q as ε → 0", or "Q ∈ q ± δ".

Approximate bridges can be sorted by **provenance**. The kinds observed in §8 are:

| Provenance | Example | Justification burden |
|---|---|---|
| (P1) Stipulated by c_P | "no surface tension", "neglect air drag", "cables inextensible and massless" | none; defines c_P |
| (P2) Regime stated by c_P | "S_t ≪ S_b, S_c (assume valid until the end)"; "Gmμ/r₀ ≫ RT₀" | asymptotic reading; graded modulo ∼ |
| (P3) Quantified by c_P, then adopted | IPhO 2025 A.3: ε = P_sat/(P₀ + mg/S) ≈ 1.6×10⁻⁶, then "take P_sat = 0" | certificate supplied by the problem |
| (P4) Solver-introduced, with estimate | IPhO 2025 C.3 official solution: "X is of the order of a few centimeters, so the time needed to switch … can reasonably be neglected in front of the period τ₁" | order-of-magnitude certificate (E6) |
| (P5) Solver-introduced, silent | point ball (IPhO 2012 T1-A); vapour appears exactly at P_sat with no metastability (IPhO 2025 T2); leg uniformly lit (EuPhO 2025 T1) | none given; a checker must demand one |
| (P6) Convention | g = 9.8 m/s², ideal pulleys, incoherent sunlight, geometric optics | library default (Strevens-style default values, L7) |

Two empirical points matter for the design.

* **Grading rewards (P4) and (P5) steps.** The C.3 marking scheme awards 0.2 pt for "the switch is instantaneous" [repo-verified]. So the intended model of c_P is fixed partly by the *solution*, not only by the problem. The reading is the problem setters' joint practice.

* **P4 justifications can be wrong in their premise and still right in their conclusion.** The official C.3 premise "X ≈ a few cm" does not match the problem's own optimum X* = A/(4ρg) ≈ 0.94 mm [computed]. The conclusion survives because it is robust over the whole admissible range. The switching time scale is √(M_eff/k), where k = 4S_bS_cρg/(S_b+S_c) ≈ 5.4×10³ N/m and M_eff ≳ 70 kg (67.5 kg of mercury alone). That gives ~0.1 s, against τ₁ ≈ 6×10⁵ s [computed]. *Robustness of the conclusion*, not truth of the premise, is what certifies the bridge. This is L7's E6.

### 2.2 The standard idealizations and what would justify each

Each standard idealization is a limit ε → 0 of a dimensionless parameter. A bridge theorem with side conditions backs it, and each has a known failure mode. This is the bridge catalogue a checker needs. It is the physics-specific content of L7's E-taxonomy.

| Idealization | Small parameter ε | Backing theorem / first correction | Known failure (singular or non-uniform limit) |
|---|---|---|---|
| point mass | size ℓ / length scale L; I/(mL²) | rigid-body equations reduce to centre-of-mass motion; physical pendulum T = T₀√(1 + (2/5)r²/L²) | rolling, collisions, tidal effects; "hitting a point" vs touching with finite radius (§8.1) |
| massless string/spring | m_s/m | continuous dependence on parameters; Rayleigh effective mass m_s/3 for springs | whip-cracking and falling chains, where energy concentrates at the end (Calkin & March 1989, *Am. J. Phys.* 57 [unverified details]) |
| rigid body | compliance / stiffness | quasi-static elasticity | statically indeterminate supports (four-legged table: forces depend on the *family* of compliances); Painlevé paradox with Coulomb friction (Stewart 2000, *SIAM Review* 42:3–39) |
| frictionless / no drag | μ; drag/weight a_d/g; Re | Gronwall bound (L7 §10.2) | d'Alembert's paradox (ν → 0 singular); "frictionless" with rolling, which means non-dissipative rather than zero tangential force (L7, Wilson) |
| small angle | θ₀ | sin θ = θ − θ³/6 + …; period T = T₀(1 + θ₀²/16 + …) | long-time phase drift: error ∝ θ₀²·t/T₀, so the bridge is horizon-limited (E3) |
| ideal gas | n b; a/(RTV) | virial expansion | phase transitions, condensation |
| quasi-static / "slowly" | τ_fast/τ_slow | Tikhonov's singular-perturbation theorem (attracting fast manifold); Fenichel 1979 (*J. Diff. Eq.* 31:53–98); Simon & Ando 1961 aggregation | fast subsystem unstable (snap-through, as in Cox's clock!), adiabatic-invariant breakdown at resonances |
| thin lens / paraxial | aperture/focal length, field angle | Seidel aberration expansion | caustics, large field angles |
| geometric optics | λ/a; Fresnel number a²/(λL) | stationary phase / WKB | caustics, where ray optics gives infinities (Batterman's rainbow; the 1/r singularity in §8.2) |
| uniform g, flat Earth | h/R_E | Taylor expansion of GM/r² | orbital problems |
| incompressible | Mach² | low-Mach expansion | acoustics |

The quasi-static row is worth a note. "Slowly lifted" (IPhO 2025 T2) is a stipulation whose rigorous content is a Tikhonov-type statement: as the lifting rate goes to 0, the trajectory converges to the hydrostatic equilibrium branch, provided that branch is attracting. In Cox's clock the fast subsystem (the sliding mass M) is *unstable* between the stops. That is why the official solution needs a separate (P4) bridge, "the switch is instantaneous", instead of quasi-statics.

### 2.3 Literally inconsistent contexts and germ semantics

The user worries that many reasonable contexts are technically contradictory. There are three distinct phenomena here.

1. **The context conflicts with imported background.** The standard example is "air pressure 0" against the measured atmosphere. L7 handles this: idealized contexts import only a designated fragment, and stipulations never permeate out.

   L9 adds that *import filters are problem-relative*, not idealization-relative. IPhO 2025 T2 says globally "no surface tension effects" and then deliberately imports the saturated vapour pressure, so that a vapour cavity forms exactly when P_w = P_sat. IPhO 2025 T3, in the same exam, makes surface tension the *mechanism*. Its critical radius a_c is the radius above which a bubble grows, and "in practice, bubbles mainly grow from pre-existing gas cavities" [repo-verified]. Read naively, the two contexts give contradictory answers to "does a gas phase appear as soon as the liquid's pressure (or its dissolved-gas content) passes the equilibrium threshold?". Both are fine. The filter is fixed by what is a difference-maker for each query, not by the idealization type.

2. **The context is literally inconsistent at the limit.**
   * *Rigid bodies with Coulomb friction* can have no solution or several solutions (the Painlevé paradox; Stewart 2000).
   * *A uniform isothermal gas ball with vacuum outside* (IPhO 2012 T3, as I recall it [unverified]) has a pressure discontinuity at its surface. It cannot stay uniform: the surface layer must expand.
   * *A massless string with a net force on it* would need infinite acceleration.

   In each case the literal ε = 0 theory is contradictory or degenerate. Every M_ε with small ε > 0 is fine, and the intended answers are limits along the family.

3. **The context is underdetermined.** Examples are the four-legged rigid table and an unspecified sun elevation α (EuPhO 2025 T1). Here the answer is determinate only if it is *invariant across completions* (supervaluation, L7 §10.4).

For (2), and also as a uniform treatment of (1) and (3), I propose the following **germ semantics** (my proposal, and a theorem candidate, TC3).

* An idealized context is c = (Θ, θ ↦ M_θ, 𝓕), where 𝓕 is a filter on the parameter space Θ, e.g. "ε → 0⁺" or "a/r → 0 and r/R fixed".
* A sentence φ holds in c iff {θ : M_θ ⊨ φ} ∈ 𝓕.
* Quantitative claims "Q ≈ q" are read as "Q(M_θ) − q → 0 along 𝓕", or at a stated order.

This has four consequences.

* **(a) No explosion.** Truth in c is closed under classical consequence, because a filter is closed under finite intersections. So reasoning *inside* c is classical, but nothing explodes as long as M_θ is consistent eventually along 𝓕. That holds even when the "limit theory" is inconsistent.
* **(b) Eternal propositions.** For an ultrafilter refining 𝓕, truth in c becomes truth in a single ultraproduct, i.e. a nonstandard model with ε infinitesimal (Łoś). This gives exactly McCarthy's eternal `ist(c, φ)` propositions with a concrete semantics. It also connects to Raiman's nonstandard semantics for order-of-magnitude reasoning (§3.5) and to Robinson's vindication of infinitesimals (H5). Different ultrafilter refinements correspond to the residual underdetermination of case (3).
* **(c) Contexts are paths.** Non-commuting limits mean different filters on the same family give different contexts. "Frictionless" with μ → 0 at fixed rolling geometry and "no-slip" with μ → ∞ are different filters. So the *path* to the limit is part of the reading, and that is J-type (§7).
* **(d) Well-posedness along the family.** L7's Proposition 2 ("ill-posed idealized contexts must not export") should be restated with Mod(c) replaced by the germ. A context that is ill-posed at ε = 0 but well-posed along 𝓕 is fine, and it is the normal case in physics.

---

## 3. The physicist's coherence checks, formalized (strand item b)

### 3.1 Dimensional analysis

**Type systems.** Kennedy's line of work is the standard reference.
* Kennedy (1994), "Dimension types", ESOP '94, LNCS 788.
* Kennedy (1996), *Programming Languages and Dimensions*, PhD thesis, Cambridge (Computer Laboratory TR 391) [unverified TR number].
* Kennedy (1997), "Relational parametricity and units of measure", POPL '97.
* Kennedy (2010), "Types for units-of-measure: theory and practice", CEFP 2009, LNCS 6299 [unverified pages].

Its content, in brief:
* dimensions form a free abelian group;
* type inference needs unification modulo the theory of abelian groups, which is decidable and unitary;
* dimension polymorphism plus *relational parametricity* yields **dimensional invariance as a free theorem**: every definable term of a dimension-polymorphic type commutes with rescaling of units.

Kennedy uses this to show that some types are uninhabited and to obtain Π-theorem-like type isomorphisms [unverified in detail]. F# ships units of measure based on this work. Atkey, Johann & Kennedy (2013), "Abstraction and invariance for algebraically indexed types", POPL 2013, generalize this from scaling to other groups, e.g. geometric transformations, so that free theorems become equivariance statements [unverified in detail].

**Semantic definition in Physlib** [repo-verified]. `IsDimensionallyCorrect m := ∀ u1 u2, scaleUnit u1 u2 m = m`. Here `scaleUnit` is the action of changing the unit choice (length, time, mass, charge, temperature) on any unit-dependent type, *including propositions and functions*. This is the right semantics: dimensional correctness is invariance under the unit group G = ℝ_{>0}^k. The library also defines a deliberately "primed" unit system (scaling factors 2, 3, 5, 7, 11) for disproving dimensional correctness.

**Buckingham Π** (Buckingham 1914, "On physically similar systems; illustrations of the use of dimensional equations", *Phys. Rev.* 4:345–376). A rigorous linear-algebra treatment is Curtis, Logan & Parker 1982, *Linear Algebra Appl.* 47:117–126 [unverified pages].

The precise statement:
* Let positive quantities q₁…q_n have dimension vectors forming a k×n matrix D of rank r.
* Let a relation q₁ = f(q₂…q_n) be invariant under the unit group, which acts by q_i ↦ ∏_j λ_j^{D_{ji}} q_i.
* Then q₁ = (∏ q_i^{a_i}) · F(Π₁…Π_{n−r}), with the Π_j a basis of dimensionless monomials (the kernel of D).

The proof: orbits of the log-linear action are parametrized by the Π's.

Two consequences matter for checking.
* **The "express in terms of" list is a type signature.** In IPhO 2025 A.1, F must be a function of (P₀, ρ, m, S, h, g) with the dimension of force. So F = mg·Φ(ρSh/m, P₀S/(mg)), and the official answer F = (m + ρSh)g is Φ(π₁, π₂) = 1 + π₁.
* **Problem audit.** If the target dimension is not in the column space of D, no correct answer exists. This is a cheap check on the problem itself.

**What dimension checking cannot do.**
* It cannot catch errors in dimensionless factors (2π, ½, signs) or in functions of Π groups.
* Radians are dimensionless, so θ versus sin θ slips through.
* Torque and energy share dimensions.

*Orientational analysis* (Siano 1985, *J. Franklin Inst.* 320 [unverified]; Huntley's directed lengths) refines the grading and catches more errors. A finer grading is a stronger coherence check.

**Barenblatt's warning.** Dropping a Π group because it is small assumes **complete similarity**: F(Π₁, Π₂) → F(Π₁, 0) finite and non-zero. Its failure, **incomplete similarity**, gives anomalous exponents, as in intermediate-asymptotic problems (Barenblatt 1996, *Scaling, Self-Similarity, and Intermediate Asymptotics*, CUP). So dimensional analysis is worst-case sound as a *type check*, but the step "Π₂ ≪ 1, so ignore it" is a *bridge*, not a type-theoretic fact.

**Inferentialist reading and a theorem candidate (TC1, "universal grading").** The dimension of a quantity symbol is nothing but its inferential role: which sums and equations it may enter.

* *Setup.* Take a finite set E of observed polynomial equations over symbols q₁…q_n. Require every equation to be homogeneous under a grading deg: {q_i} → A, where A is an abelian group. Each monomial identity contributes a linear relation among the deg(q_i).
* *Finest grading.* The **finest grading** is A* = ℤⁿ/⟨relations⟩, taken modulo torsion if rational exponents are allowed. It exists, it is unique, and every homogeneous grading factors through it. It is computable in polynomial time by Smith normal form.
* *Gold-type limitation.* Positive data alone never refutes a coarser grading, since the trivial grading "everything dimensionless" is always consistent.
* *Learner.* The most-specific learner (output A*(E_t)) identifies the target grading in the limit from any text that eventually exhibits a generating set of the target's relations. It is also *conservative*: it never accepts an inhomogeneous equation that the target would reject.
* *Residual non-identifiability.* What remains is exactly (i) the choice of basis, i.e. of base dimensions (GL(k, ℤ)), and (ii) *which constants are dimensional*. SI makes ε₀ dimensional and has an independent current dimension. Gaussian units absorb it. Natural units set c = ħ = 1 and collapse L and T.

  These are coherent alternative meanings that are empirically equivalent: a clean, harmless Kripkenstein residue, settled by *convention*, the third answer in H7.
* *Noise.* A single wrong equation can merge two dimensions. So the robust version is MDL or outlier removal: drop equations whose removal increases rank.

This is a cheap, fully provable component for the project, and a nice toy for the "learning meanings from positive inferences" thesis.

### 3.2 Symmetry

Two different things go by the name "symmetry".
* A **context symmetry** is a group G_c acting on M_c that preserves its laws: translations, rotations, Galilean boosts, time reversal, scaling, mirror symmetry of the setup.
* A **symmetry inference** is "the problem is G-symmetric, so the answer is G-invariant".

The user's note is exactly right. The inference is valid only for *the set* of solutions. A single solution is invariant only given uniqueness. Design rule: **a symmetry-of-solution step must carry a uniqueness certificate**, or it must be stated as a claim about the solution set. Spontaneous symmetry breaking is the case where uniqueness fails. Two more points:

* **Context symmetries are context-indexed.** Time reversal holds in the drag-free context and fails with drag. IPhO 2012 T1-A uses it essentially (§8.1). Galilean invariance fails when air at rest defines a frame. So a learned rule "reverse the trajectory" is *valid in some contexts only*: a concrete case of context-dependent inference validity, which H6 should make explicit.
* **Learning payoff (TC2).** If G_c is declared, soundness of a rule implies G_c-equivariance. So every non-equivariant candidate rule is refuted by a G_c-translate of one of its *own accepted instances*. This is negative data without world feedback, and it is the general form of the dimensional check.

### 3.3 Limiting cases

A limiting-case check is a **regression test against another context**: lim_{p→p₀} A(p) must equal the answer A₀ of the limit model. It is valid iff the limit is regular. In Norton's terms (2012), the limit property must equal the property of the limit system (L7). When it is not regular (boundary layers, caustics, d'Alembert's paradox), the check gives false alarms.

For grading, the relevant operation is **asymptotic equivalence**: q₁ ∼ q₂ iff q₁/q₂ → 1 along the declared filter. For exp-log expressions in one parameter, limits are computable by Gruntz's algorithm (Gruntz 1996, PhD thesis, ETH Zürich; implemented as `sympy.series.gruntz` [repo-verified locally]). Zero-equivalence of constants is the residual hard part (Richardson 1968, *JSL* 33:514–520).

For example, with S_t = εS_b, SymPy returns ξ_exact/ξ_lo = 1 − εS_b/(S_b+S_c) + O(ε²) [computed]. So the two forms the IPhO 2025 marking scheme accepts are ∼-equivalent, as intended. With *several* small parameters the equivalence is ill-defined until the reading fixes a scale ordering or filter (§2.3(c)).

### 3.4 Conservation laws

These are **in-model theorems** (Noether). As checks they validate computations: a claimed trajectory must conserve energy and momentum where the model says so. A violated conservation law in an idealized model signals either an arithmetic error or a non-smooth idealization. Inelastic contacts, falling chains and the two-capacitor paradox are cases where the limit system "violates" conservation (Norton's examples). Conservation checks are worst-case sound *for the model*. They say nothing about exports.

### 3.5 Order of magnitude

Raiman's FOG ("Order of magnitude reasoning", *Artificial Intelligence* 51, 1991 [unverified pages]) axiomatizes relations such as A ≪ B ("negligible w.r.t.") and A ≈ B, with a nonstandard-analysis semantics: A ≪ B iff A/B is infinitesimal. Related work: Mavrovouniotis & Stephanopoulos 1988 (O[M], *Comput. Chem. Eng.* 12 [unverified]) and Dague 1993 (IJCAI) [unverified].

The rules are sound in the infinitesimal semantics. With finite ratios they are *sorites-unsound* when chained: n steps of "≪ with ratio ≤ η" compound to (1+η)ⁿ. That is a precise instance of a rule valid in the idealized context (the germ, §2.3) whose export needs a budget.

Mahajan's *Street-Fighting Mathematics* (MIT Press 2010) and *The Art of Insight in Science and Engineering* (MIT Press 2014) are the best practitioner taxonomies of these checks: dimensions, easy cases, lumping, symmetry, proportional reasoning.

### 3.6 Signs, monotonicity, qualitative behaviour

The formal analogue is qualitative simulation. Kuipers's QSIM ("Qualitative simulation", *AIJ* 29:289–338, 1986) is **sound but incomplete**: every behaviour of every ODE consistent with the qualitative differential equation is generated, but spurious behaviours are generated too. That is exactly a one-sided check, useful for refuting claimed qualitative behaviour ("the mass oscillates", "x(t) is a 50% duty-cycle square wave").

de Kleer & Brown's "no-function-in-structure" principle ("A qualitative physics based on confluences", *AIJ* 24:7–83, 1984) is a modularity requirement on model fragments: component laws must not presuppose how the whole device works. It is the physics counterpart of "no silent imports".

### 3.7 Summary: logical roles

| Check | Logical role | Certifies | Soundness status |
|---|---|---|---|
| Dimensions (and orientation) | invariance of the rule set under G_units | homogeneity of every derived equation | worst-case, decidable; necessary only |
| Context symmetry | invariance under G_c (context-indexed) | equivariance; with uniqueness, invariance of the answer | worst-case given G_c; G_c itself must be declared |
| Conservation | theorem of M_i | correctness of in-model computation | worst-case within M_i |
| Limiting cases | regression vs. other contexts | consistency with solved sub-models | sound only for regular limits |
| Order of magnitude / neglected-term estimate | export side condition | bridge validity at stated tolerance | sound with explicit budgets; heuristic otherwise |
| Sign / qualitative | one-sided refutation (QSIM-style) | absence of impossible behaviour | sound for refutation, incomplete |
| Final-answer equivalence | grading relation ∼_𝓕 + tolerance | agreement with the reference answer | decidable for exp-log (Gruntz), up to constants |

---

## 4. Formalized physics (strand item c)

* **Physlib** (formerly HepLean, then PhysLean, now `leanprover-community/physlib`; "The Physlib Community", initial release 2024-04-16) [repo-verified].
  * *Origin.* Tooby-Smith's HepLean paper is "HepLean: Digitalising high energy physics", *Computer Physics Communications* (2025) [unverified volume and pages].
  * *Structure at commit `d630c36`.* About 590 Lean files in the core `Physlib` and about 300 in `PhyslibAlpha`, which has "a lighter review process built to handle large-scale, human- or AI-generated contributions". Coverage spans classical mechanics (pendulums, harmonic and damped oscillators, rigid bodies, Euler–Lagrange, Hamilton's equations, vis-viva), electromagnetism, fluid dynamics (Euler, Bernoulli, incompressible), thermodynamics (ideal-gas entropy and adiabatics), relativity, QFT, the Standard Model, and the units system above.
  * *Exports are partly formalized.* `SimplePendulum/SmallAngle.lean` proves that the linearization discards exactly mgℓ(θ − sin θ), with norm ≤ mgℓ|θ|³/6. A small-angle motion therefore solves the nonlinear equation up to a cubic residual.
  * *But not completely.* That is a *residual* bound, not a trajectory or period error bound. `PeriodFormula.lean` proves continuity, the zero-amplitude limit, monotonicity and an upper bound for T = 4√(ℓ/g)K(sin²(θ₀/2)). It states explicitly that identifying this formula with the period of the nonlinear ODE "is not yet carried out".
  * *Gaps.* `Optics/Basic.lean` is a placeholder. There are no projectile, Kepler-orbit, thin-lens or Snell's-law files, and no Buckingham Π.
  * *Policy.* The AI policy contains a sentence that is the fidelity problem in one line: "A clean Lean build proves what was written, but only the human can certify what was written is what they meant."

* **Isabelle/HOL.**
  * Fleuriot (2001), *A Combination of Geometry Theorem Proving and Nonstandard Analysis with Application to Newton's Principia* (Springer). It formalizes Newton's infinitesimal geometric arguments using nonstandard analysis. This is directly relevant to H5, and to germ semantics: it shows Newton's "ultimate ratios" are a consistent infinitesimal context.
  * Stannett & Németi (2014), "Using Isabelle/HOL to verify first-order relativity theory", *J. Automated Reasoning* 52 [unverified pages]. This verifies the Andréka–Madarász–Németi–Székely axiomatization of special relativity, an example of axiomatizing a physical theory as a first-order theory with an explicit, small axiom set.
  * Immler (2018), "A verified ODE solver and the Lorenz attractor", *J. Automated Reasoning* 61:73–111. Rigorous enclosures of ODE solutions inside a proof assistant: the tool that upgrades simulation-based export certificates from S to F.
  * Foster & Wolff, physical quantities and units in the Archive of Formal Proofs [unverified title and year].

* **HOL Light optics.** Siddique, Aravantinos & Tahar formalized geometrical optics with ray-transfer matrices and the stability of optical resonators (e.g. NFM 2013) [unverified details]. As far as I know, they formalize the paraxial model itself, not the bridge from exact ray optics to paraxial optics.

* **Validated numerics.** Tucker (2002), "A rigorous ODE solver and Smale's 14th problem", *Found. Comput. Math.* 2:53–117. Tucker (2011), *Validated Numerics*, Princeton UP. Interval and Taylor-model methods make "numerically simulate the less-idealized model" a proof.

* **Language design.** Sussman & Wisdom, *Structure and Interpretation of Classical Mechanics* (MIT Press 2001; 2nd ed. 2014), is the closest physics analogue of "math was formalized by inventing a language". They show that the traditional notation for Lagrange's equations is ambiguous, and they replace it with a functional, executable notation. The ambiguity is what ∂L/∂q̇ means as a function, and when one substitutes the path.

* **Equation-based modeling.**
  * *Modelica.* Acausal equations; connectors whose flow variables sum to zero, which builds in conservation; `replaceable` components, i.e. swappable idealizations; unit attributes with unit checking (Broman, Aronsson & Fritzson 2008, Modelica Conference [unverified]); and `assert` statements that check validity ranges at simulation time. The Modelica media libraries assert temperature and pressure ranges [unverified specifics].
  * `assert` *is runtime checking of idealization side conditions*, and `replaceable` *is a model-fragment library*. Fritzson's *Principles of Object-Oriented Modeling and Simulation with Modelica* is the standard text [edition unverified].
  * Bond graphs (Paynter) are an older compositional formalism with energy conservation built in.

* **Brief's "Boender et al.?"** I could not identify a Boender et al. paper on physics formalization. The closest match I know is Boender, Kammüller & Nagarajan, "Formalization of quantum protocols using Coq" (QPL 2015) [unverified], which is protocol verification, not physical modeling.

**Lessons.**
1. In-model mathematics is formalizable today.
2. *Exports are formalizable but costly*: even the pendulum period bridge is unfinished in the leading library.
3. Validated numerics is the scalable route for de-idealization checks.
4. Modelica already has the right *engineering* primitives (swappable idealizations, asserted validity ranges, unit checks), but not proofs.

---

## 5. AI physics solving and grading (strand item d)

### 5.1 Benchmarks and how they grade

| Benchmark | Content | Grading | Source |
|---|---|---|---|
| **OlympiadBench** (He, Luo, Bai, … Liu, Sun; ACL 2024; arXiv 2402.14008) | 8,476 math + physics problems (international and Chinese olympiads, Gaokao); text-only and multimodal | final answer only; `auto_scoring_judge.py` tries string equality, interval equality, numeric equality within a per-problem tolerance (default 1e-8, also allowing ×100 percentage forms), SymPy `simplify(e1 − e2)` with \|·\| < 1e-3 when both sides are symbolic, and equation equivalence via ratio simplification. No unit or dimension check. GPT-4V scored 10.74% on physics | [repo-verified] |
| **UGPhysics** (Xu, Xu, Xiao, Chen, Yan, Zhang, Diao, Yang, Wang; ICML 2025; arXiv 2502.00334) | 5,520 undergraduate problems, 13 subjects | rule-based `auto_judge` with a model-based `aux_judge` fallback; the paper calls it MARJ, "Model-Assistant Rule-based Judgment" [name from memory] | [repo-verified code structure] |
| **PhysReason** (Zhang, Dong, Wu, Huang, Jia, Fernando, Shou, Zhang, Liu; ACL 2025; arXiv 2502.12054) | 1,200 problems, 147 theorems, 81% with diagrams | PSAS-A (answer level, LLM extraction + semantic verification, weighted by step length) and PSAS-S (step level: score steps, find first error, classify errors as theorem application / process understanding / calculation / condition analysis) | [repo-verified] |
| **HiPhO** (Yu, Wan, Cheng, … Cui, Ye; arXiv 2509.07894) | 13 olympiads 2024–25 (IPhO, APhO, EuPhO, NBPhO, PanPhO, …), 360 problems; 4 modality types; 6 answer types | answer-level *and* step-level grading aligned with *official marking schemes*; medal thresholds | [repo-verified] |
| **PHYBench** (2025) | olympiad-style symbolic-answer problems | "Expression Edit Distance" (EED) between expression trees, giving partial credit | [unverified] |
| **PhysicsEval** (2025) | — | — | [unverified; could not check] |
| **OlymMATH** | as far as I know a *math* olympiad benchmark, not physics | — | [unverified] |

### 5.2 AI at IPhO 2025 (and EuPhO 2025)

From HiPhO data v2025-09-16, theory only (models' full mark < 30 because some items are not gradable) [repo-verified]:
* **IPhO 2025** (full mark 29.4 for models). Gemini-2.5-Pro 22.7, GPT-5 22.3, P1-235B-A22B 21.2, P1 + PhysicsMinions 23.2, Gemini-2.5-Flash-Thinking 20.2. Gold, silver and bronze thresholds 19.7 / 12.1 / 7.2; best human 29.2.
* **EuPhO 2025** (full mark 29.0 for models). Best model 14.9 (Gemini-2.5-Pro); P1 + PhysicsMinions 12.4. Gold threshold 16.5; best human 27.0.
* **Later.** The HiPhO README (Dec 2025) reports that Gemini-3-Pro was at gold level on all 13 olympiads [repo-verified as a README claim].

**Physics Supernova** (Qiu, Shi, Juan, Zhao, Geng, Liu, Wang, Wu, Wang; arXiv 2509.01659) is a CodeAgent with an ImageAnalyzer (measurements from figures), an AnswerReviewer, a WolframAlpha tool and a memory summarizer. It claims gold at IPhO 2025 theory, above the gold-medallist median. Its own answer judge uses an LLM to extract final answers and another LLM prompt to decide expression equivalence [repo-verified]. I recall a figure of 23.5/30 [unverified].

**P1** (P1 Team; arXiv 2511.13612) uses multi-stage RL on Qwen3. **PhysicsMinions** (arXiv 2509.24855) is a co-evolving multi-agent system whose "Review Studio performs two-stage validation: physical consistency and logical correctness" [repo-verified].

**Reading.** The IPhO/EuPhO gap fits the anatomy of §2. EuPhO problems are designed around *modeling* rather than standard computation; EuPhO 2025 T1 is a photograph of a chair leg. Under the reading/bridge decomposition, that is where current systems fail. Also, every verification component in these systems is an LLM judge: average-case, in-distribution and hackable. That is exactly the regime H1 says is insufficient for an adversarial prover.

### 5.3 What an official marking scheme reveals (IPhO 2025 T2, official) [repo-verified]

* **Rubric items are named inferences.** Examples: "Physical law: Conservation of the total mass/volume 0.2", "Physical law: Expression of barometric difference of heights 0.2", "Use of Coulomb's law in sticky situation 0.1". So the community's own unit of credit is an *application of a named model fragment*. That is the inferentialist unit. It is also Andes's "principle application" unit.
* **Numeric answers are graded by intervals**, e.g. F_max ∈ [14.6, 15] N and W* ∈ [19, 21] mJ.
* **Several items say "(with or without using S_t ≪ S_b, S_c)".** That is grading modulo ∼ (§3.3).
* **Qualitative items grade features.** For graphs: "4 straight pieces", "the 3rd piece has a negative slope". For behaviours: "All behaviours are correct (all or nothing)". These are QSIM-like qualitative signatures.
* **Unstated-idealization items earn credit.** "The switch is instantaneous" (0.2 pt) is one.

### 5.4 Historical problem solvers and tutors

* **ISAAC** (Novak 1977, IJCAI) read English statics problems and mapped objects to idealized "canonical objects", e.g. a person on a ladder becomes a point mass. It was an early explicit treatment of idealization as a *view*.
* **NEWTON** (de Kleer 1977, IJCAI) used qualitative "envisionment" before quantitative solving.
* **MECHO** (Bundy, Byrd, Luger, Mellish & Palmer 1979, IJCAI) used meta-level inference to select equations [author list unverified].
* **Cognitive studies of experts.** Larkin, McDermott, Simon & Simon (1980, *Science* 208:1335–1342) found that experts work forward from principles. Chi, Feltovich & Glaser (1981, *Cognitive Science* 5:121–152) found that experts categorize problems by deep principle, novices by surface features. Together: expert solutions are organized around *named model fragments*.
* **Andes** (VanLehn, Lynch, Schulze, Shapiro, Shelby, Taylor, Treacy, Weinstein & Wintersgill 2005, *IJAIED* 15:147–204; algebra subsystem: Shapiro 2005, *IJAIED* 15 [unverified pages]). Students define variables and draw vectors, then enter equations one at a time. Each equation is checked for units, and checked *by numerical substitution* against the solution of the author's model. Feedback comes from a solution graph of principle applications.

  This is a deployed F-layer checker with Schwartz–Zippel-style evaluation. Its limitation is instructive: the idealization is fixed by the problem author, so *bridges are never checked*.
* **LLM grading of physics work.** Kortemeyer (2023), "Toward AI grading of student problem solutions in introductory physics: a feasibility study", *Phys. Rev. Phys. Educ. Res.* 19 [unverified article number]. It found useful but imperfect agreement with human graders [unverified details].

---

## 6. Compositional and qualitative modeling (strand item e)

See L7 §7 for Falkenhainer & Forbus 1991 (model fragments, assumption classes, "consider" statements), Nayak 1994 (adequacy; finding a minimal adequate model is intractable in general, while checking a supplied one is easy), Weld 1992 (fitting approximations) and Addanki, Cremonini & Penberthy 1991 (graphs of models, traversed by conflicts with data). Additions for L9:

* **Model selection from data happens inside olympiad problems.** IPhO 2025 T3 A.3 offers two flux models, j = (D/a)(c_l − c_b) and j = K(c_l − c_b), and asks "which model explains the experimental results in Fig. 2" [repo-verified]. That is Addanki-style conflict-driven traversal of a two-node graph of models, with world feedback given as a figure.
* **Quasi-static and time-scale separation have AI-modeling formalizations:**
  * Iwasaki & Simon 1986, "Causality in device behavior", *AIJ* 29:3–32;
  * Iwasaki & Bhandari 1988, "Formal basis for commonsense abstraction of dynamic systems", AAAI-88 [unverified];
  * all building on Simon & Ando 1961, "Aggregation of variables in dynamic systems", *Econometrica* 29:111–138.

  These are the AI-side counterparts of Tikhonov's theorem.
* **The compositional-modeling insight that transfers directly:** a solution is a *selection of model fragments plus assumptions*, and the checker's job is easy when the solver *declares* the selection (Nayak). That is the design principle of §7.

---

## 7. Key question 1: what a principled checker would look like

### 7.1 The Structured Physics Solution (SPS) format

A solution is a tuple ⟨ρ, {M_i}, {B_k}, {D_i}, X⟩.

* **ρ — reading.** ρ declares, in a formal specification language:
  * (i) the admissible family 𝓜_P = {M_θ : θ ∈ Θ_P} with its filter 𝓕 (germ semantics), separating parameters *given* by c_P, *measured* from figures (with error intervals) and *free* (completion parameters);
  * (ii) the query Q and its type, i.e. the dimension and the allowed variables;
  * (iii) the stipulations and conventions used, cited from a library;
  * (iv) a **no-silent-imports** list: every law used must be an axiom of a cited model fragment, a stipulation, or derived.
* **M_i — local models.** Each is a clear mathematical problem. Each carries a **well-posedness certificate**: an existence witness, which can be an explicit or validated-numerical solution, plus a uniqueness lemma for the queried quantity. The witness blocks explosion; uniqueness licenses symmetry inferences and "the answer is x".
* **B_k — bridges.** Each bridge is one of:
  * **exact** (symmetry under a declared G_c, decomposition, isomorphism, identity), with a proof; or
  * **approximate**, citing a catalogue schema (§2.2), with side conditions evaluated on the *parent's* parameter values (L7 Prop. 6) and an error certificate. The certificate type is E2/E3 bound, validated numerics, simulation, or asymptotic order.
* **D_i — derivations inside models.** Kernel-checked proof, CAS certificate, or Andes-style random numerical substitution.
* **X — export.** The final claim, as "Q = q in c_P", "Q ∼_𝓕 q", or "Q ∈ q ± δ", together with the error composition |Q − q| ≤ Σ_k L_k δ_k, where L_k is the Lipschitz constant of everything downstream of bridge k (TC5). If c_P has a stated tolerance, as marking intervals do, X must show that the total error is within it.

### 7.2 Which parts are verified how

| Component | F: formally verifiable (worst-case) | S: simulation / randomized | J: learned judgment |
|---|---|---|---|
| reading ρ | type signature; dimensional consistency of the query; Π-form of admissible answers; completion-independence ∂Q/∂θ_free = 0 (TC7) | round-trip rendering: simulate the model's observable (e.g. render the floor pattern) and compare with the photo; Gricean checks (all data used, answer determinate) | entity identification, intended meaning of terms, which figure features matter, which path/filter 𝓕 is intended, the convention library |
| local models M_i | consistency (existence witness), uniqueness, dimensional typing | numerical witness when no closed form exists | choice of fragments (Nayak: checking easy, finding hard) |
| exact bridges | always: they are theorems (time reversal, decomposition, Kepler degeneration) | — | that the declared symmetry group G_c holds in c_P (the drag-free context licenses time reversal) |
| approximate bridges | Taylor/residual bounds, Gronwall, Tikhonov hypotheses, validated numerics for de-idealized models | Monte Carlo / ODE / CFD on M_{θ>0}; random-instance error profiles | whether *unnamed* effects matter (open world: no finite certificate covers them) |
| derivations D_i | proof assistant, CAS, interval arithmetic | random substitution (Schwartz–Zippel for rational identities) | — |
| export X | asymptotic equivalence (Gruntz), interval inclusion in tolerance | — | — |
| global checks | dimensions, symmetry equivariance, conservation in M_i | limiting-case regression against a library of solved sub-models | sign and magnitude plausibility against world knowledge |

**Soundness statement (relative).** Suppose ρ is correct, i.e. 𝓜_P is the intended family, and suppose every F and S item passes, with S items carried out by validated numerics. Then the exported claim holds for every admissible completion of c_P. This is TC5. The residual risks are exactly two:
* (i) ρ is wrong;
* (ii) an effect outside M_top matters.

Both are J-type. (ii) is unavoidable by an open-world version of L7's "no free export".

**Attack surface (H1).** An adversarial solver can attack only the J items. Mitigations:
* restrict contexts to *declared deformations of the parent* (L7 Prop. 6);
* require *completion-independence* certificates whenever a free parameter is set by fiat;
* require round-trip agreement of ρ with the figure;
* require that independent readings converge. This is robustness, L7's E9; note that it is blind to common-mode errors.

### 7.3 Where learning fits

The brief's learning loop fits each component differently.

* **In-model rules** are mathematics plus model-fragment axioms. They are learnable from positive examples, and they are *constrained a priori* by unit invariance and declared symmetries, which give free negative data (TC1, TC2). A Lean or CAS kernel checks them, so they never need to be trusted statistically.
* **Bridge schemas** are learned from human solutions as patterns ("neglect X because Π_X ≪ 1"). Their *tolerances* are learned from **simulation of M_top on random instances**: cheap, unlimited, and labeled. This is TC6, and it means "world feedback for export rules" in olympiad physics does not need the world.
* **World feedback proper** is needed only to calibrate M_top itself (classical mechanics, ideal gases, ray optics) on the observable classes the problems use. For olympiad grading even that is moot, because c_P is the root.
* **The reading** is where imitation learning (official solutions and marking schemes) and the Gricean coherence constraints of problem statements belong:
  * the answer is determinate;
  * the data are sufficient and used;
  * the needed idealizations are stated or conventional;
  * the "express in terms of" list is honored.

---

## 8. Key question 2: three problems decomposed

### 8.1 IPhO 2012 Problem 1, Part A "Ballistics" (the user's `ipho 2012 T1-A.md`)

The user's note contains only the image. **The statement below is from my memory [unverified]:**
* a ball is thrown with speed v₀ in a homogeneous field, with air drag neglected;
* (i) the reachable region is z ≤ z₀ − kx²; find z₀ and k;
* (ii) launching from anywhere on level ground, hit the topmost point of a spherical building of radius R with minimal v₀, without bouncing on the roof; sketch the optimal trajectory;
* (iii) find v_min.

I recall the answers z₀ = v₀²/2g, k = g/2v₀², v_min = 3√(gR/2). My computation reproduces v_min for a full sphere resting on the ground, i.e. with the top at height 2R [computed]. A hemispherical dome would give a different answer, so the figure is load-bearing (J).

**Decomposition.**

| # | Step | Type | Verification |
|---|---|---|---|
| ρ1 | ball = point; building = rigid sphere tangent to the ground, top at 2R (from the figure); "minimal" read as infimum (grazing allowed, entering not) | reading | J (figure); infimum vs minimum is a (P5) convention |
| D1 | (i) envelope of z = x tan β − gx²/(2v₀²cos²β) over β: z₀ = v₀²/2g, k = g/2v₀² | in-model | F (discriminant in tan β) |
| D2 | energy conservation: v₀² = w² + 4gR, so minimize the speed w at the top | in-model theorem | F |
| B1 | **time reversal**: a trajectory reaching T from the ground with speed w is equivalent to one launched from T with speed w that reaches the ground without entering the ball | exact bridge, *valid only in the drag-free context* | F, given G_c ∋ time reversal (licensed by stipulation P1) |
| D3 | trajectories from T with speed w lie under the envelope z = 2R + w²/2g − gx²/2w² | in-model (re-uses D1) | F |
| D4 | **necessity**: if the envelope dips into the ball, the region below the envelope and outside the ball separates T from the ground, and a continuous trajectory cannot cross; hence the envelope must not dip in | in-model topological lemma | F (connectedness) |
| D5 | tangency of envelope and circle: discriminant zero ⇔ w² = gR/2, with tangency at height 1.5R | in-model | F [computed: SymPy discriminant] |
| D6 | **sufficiency**: the trajectory tangent to the envelope at the tangency point clears the ball. In SymPy, with launch angle 30°: x² + (z−R)² − R² = 2x(2x − √3R)²(2x + √3R)/(9R²) ≥ 0 for x ≥ 0 | in-model; **typically left implicit** | F (polynomial certificate) [computed] |
| X | v_min² = gR/2 + 4gR = 9gR/2, so v_min = 3√(gR/2) ≈ 2.12√(gR) | export into c_P (exact) | F |

* *Forward-time picture* [computed]: launch about 1.46R from the building's axis at an elevation of about 73°. The ball grazes the sphere at the point 30° above the horizontal through the centre, reaches its apex (height ≈ 2.06R), and comes *down* onto the top at 30° below horizontal.
* *Bridges back to the world* (not required by c_P): finite ball radius b replaces R by R + b in the clearance condition. That is an E2 export with O(b/R) relative error. Drag is handled by L7's E3 certificate.
* *Lesson.* After the reading, this problem is ~100% F. It is "a math problem in disguise". The official-style argument needs one context-dependent exact bridge (B1) and one usually unstated sufficiency lemma (D6).

### 8.2 EuPhO 2025 Theory Problem 1(a): a polished chair leg reflecting sunlight

The official text was inaccessible. **The setup is reconstructed from the user's introspection notes [unverified against the official PDF]:**
* a photo shows a chair whose polished cylindrical leg reflects sunlight onto the floor;
* part (a) asks for the "illuminance surplus" inside the bright circle as a function of polar coordinates (r, φ).

The user's final answer, which he reports matches the official one, is E = (aI₀/2) sin(φ/2)/r. Here a is the leg radius, I₀ the direct floor illuminance, and φ the polar angle measured from the anti-sun direction, so the pattern is brightest on the sun side at φ = π.

**Decomposition.**

| # | Step | Type | Verification |
|---|---|---|---|
| ρ1 | the leg is a vertical *specular* cylinder (radial streaks and the central shadow show it is not diffuse) | reading of photo | J; round-trip check: render the predicted pattern and compare (S) |
| ρ2 | sunlight = parallel beam at elevation angle α from the vertical, incident from the left (shadow direction) | reading + convention | J; α is *not* readable reliably, so it is a free completion parameter |
| ρ3 | "illuminance surplus" = irradiance on the floor from reflected light only (incoherent superposition, so additive); spectral content irrelevant | quantity definition | J (the user's "a lot of these choices are equivalent" is a completion-independence claim, provable for wavelength-independent reflection) |
| ρ4 | leg uniformly illuminated over height L, so the pattern is a disk of radius R = L tan α | idealization (P5) | J + S |
| B1 | **decomposition**: reflection off a vertical surface preserves the vertical velocity component and reflects the horizontal one in the 2D circle | exact bridge | F |
| D1 | 2D: a strip at angle θ (on the lit side) sends horizontal flux ∝ a\|cos θ\| dθ into direction φ = 2θ − π; so dφ = 2dθ | in-model | F |
| D2 | reflection height h uniform on [0, L], with horizontal travel h tan α; so the flux along each ray is uniform in r on [0, R], and the illuminance ∝ 1/r | in-model | F |
| D3 | normalization: E = I sin α · a\|cos θ\| L/(2Rr) = (aI cos α/2)\|sin(φ/2)\|/r; total flux ∫E = 2aLI sin α, which equals the intercepted flux ✓ | in-model | F [computed] |
| B2 | **α cancels**: R ∝ tan α, intercepted flux ∝ sin α, and I₀ = I cos α | completion-independence certificate (TC7) | F: ∂E/∂α = 0 at fixed I₀ |
| B3 | thin leg: reflection point taken at the axis, valid for a ≪ r | approximate bridge (E2, non-uniform) | S [computed]: Monte Carlo on a finite cylinder, ratio MC/formula: 0.97–1.03 (mean 1.002–1.007) for r ≳ 35a at α = 30°, 50°, 70°; at α = 45°: 1.00–1.07 at r = 20a, 1.03–1.12 at r = 10a, 1.1–1.34 at r = 2–3a (noisy bins) |
| B4 | sun is a point at infinity (angular radius ≈ 4.65 mrad) | approximate (E7): smooths the kink at φ = 0 and the edge at r = R over widths ~ δ and ~ Lδ/cos²α | S or F (convolution bound); the export holds away from those sets only |
| B5 | perfect reflectance; geometric optics (Fresnel number a²/λL ~ 10² ≫ 1) | (P6) conventions; a reflectance ρ multiplies E | F given ρ |
| X | E(r, φ) = (aI₀/2)\|sin(φ/2)\|/r for a ≪ r < R, away from φ ≈ 0 and r ≈ R | export | composite |

**Lessons.**
* *Where the work is.* The mathematics is short and fully F. The work is in the reading (ρ1–ρ4) and in recognizing the invariance B2.
* *The user's introspection is the process of completing ρ.* His mistaken belief that α matters, caused by an algebra slip, is what a completion-independence obligation would have caught immediately.
* *The export is non-uniform.* It fails near the leg (the 1/r singularity is a ray-optics artifact at r ≲ a), at the shadow-side kink φ ≈ 0, and at the disk edge. A correct export must state its domain. This is exactly the Batterman/Norton point (L7) in an olympiad.
* *Why models do worse at EuPhO.* This problem has a photo-to-model reading as its hard part. It is plausibly why EuPhO 2025 is harder for current AI than IPhO 2025 (§5.2), though I have not checked per-problem scores.

### 8.3 IPhO 2025 Theory Problem 2, "Cox's Timepiece" (official text and marking scheme) [repo-verified]

**Stated context.** The problem declares, globally:
* the field is uniform with g = 9.8 m s⁻²;
* liquids are incompressible;
* there are "no surface tension effects";
* atmospheric pressure does not vary with altitude;
* the temperature is uniform and all transformations are isothermal;
* tube walls have zero thickness;
* the tube is lifted "slowly".

In Part C, add:
* cables are inextensible and massless;
* pulleys are ideal;
* friction is Coulomb, with no distinction between static and dynamic coefficients;
* P₁(t) is a triangular wave (A = 500 Pa, τ₁ = 1 week);
* S_t ≪ S_b, S_c, "valid until the end of the problem";
* S_b ≃ S_c in C.4.

**Decomposition** (main line; all numbers recomputed [computed]).

| # | Step | Type | Verification |
|---|---|---|---|
| A.1 | hydrostatics P_w = P₀ − ρgh; equilibrium F = (m + ρSh)g | in-model | F; dimensional/Π form checks the answer (§3.1) |
| A.2 | vapour appears when P_w reaches P_sat, at h* = (P₀ − P_sat)/ρg. Exp. 1: A, F_max = 14.70 N. Exp. 2: A, 14.41 N. Exp. 3: B, h* = 2.13 cm, F_max = 5.10 N | in-model + **imported phase-equilibrium fact** (no metastability: an unstated P5 idealization) | F given the import; the import is J, problem-relative (§2.3) |
| A.3 | ε = P_sat/(P₀ + mg/S) ≈ 1.6×10⁻⁶ for mercury | **sensitivity certificate supplied by the problem** (P3) | F |
| B.0 | "take P_sat = 0" | approximate bridge licensed by A.3 | F (E2 with explicit ε) |
| B.1 | m_add = mass of liquid in the tube above the bath level | exact bridge (Archimedes-type identity) | F |
| B.2 | piecewise-linear m_add(h_t), with slopes ρS_b, ρS_t, −ρ(S_b − S_t), 0 and corners at h_t = 0, z*−H_b = 56 cm, z* = 76 cm | in-model | F; graded by qualitative features (QSIM-like) |
| B.3 | Δm_add = S_bA/g ≈ 1.02 kg | in-model | F |
| C.1 | tension imbalance R_t = 2S_bS_cP₁/(S_b + S_c − S_t); M stays put iff ξ > ξ* = 2 | in-model (hydrostatics + volume conservation + Coulomb) | F |
| C.3 | **"the time needed to switch between x = 0 and x = X can reasonably be neglected in front of τ₁"**, justified from Fig. 5 ("X is a few centimetres") | solver-introduced approximate bridge (P4), *graded* (0.2 pt) | the premise contradicts X* ≈ 0.94 mm, but the conclusion is robust: √(M_eff/k) ~ 0.1 s ≪ τ₁ ≈ 6×10⁵ s. E6 certificate; S-checkable by integrating the snap-through ODE |
| C.3′ | regimes: ξ + 2λ > 2 (aperiodic) vs < 2 (periodic square wave, duty cycle 50%) | in-model | F; graphs graded by features |
| C.4 | W = 4F_sX, maximized on ξ + 2λ = 2, gives X* = A/4ρg ≈ 0.94 mm, F_s* = AS_c/2 ≈ 5.25 N, W* = A²S_c/2ρg ≈ 19.8 mJ | in-model under P2 regime (S_t ≪ S_b, S_b ≃ S_c) | F; **export tolerance check**: the optimum with the exact ξ, λ is 20.1 mJ, a 1.3% difference, inside the marking interval [19, 21] mJ [computed] |
| C.5 | (P, V) cycle area: W_pr* = 4S_cX*A = S_cA²/ρg, so W*/W_pr* = ½ | in-model | F |

**Lessons.**
* *The problem itself practises principled export.* It quantifies an approximation before adopting it (A.3 → B.0), states its asymptotic regime once and for all, and grades both forms as equivalent.
* *The one solver-introduced bridge (C.3) is justified by an order-of-magnitude remark with a wrong premise and a robust conclusion.* A checker should demand the robust form: "for every X up to the apparatus scale, the switching time ≪ τ₁".
* *The silent import is visible.* "Vapour appears exactly at P_sat" is invisible to the problem's own context declaration. It would be flagged by "no silent imports".

### 8.4 Two short supplementary cases

* **IPhO 2012 Problem 3, "Protostar formation"** (statement from memory [unverified]). It is a textbook *chain of contexts*.
  * *Stated regimes.* "Gmμ/r₀ ≫ RT₀" licenses pressure-free collapse. It also makes the literally inconsistent "uniform isothermal ball with sparse surroundings" asymptotically consistent (germ semantics).
  * *Part (ii): "neglect the change of the gravity field" for r: r₀ → 0.95r₀.* The constant-g estimate √(0.1r₀³/Gm) differs from the exact Kepler-radial time by 0.85% [computed].
  * *Part (iii): an exact isomorphism bridge.* Radial infall is a degenerate Kepler ellipse with semi-major axis r₀/2, so t_collapse = π√(r₀³/8Gm). That matches the exact limit and a numerical ODE integration (1.11072 in units G = m = r₀ = 1) [computed].
  * *Part (vi): an explicitly order-of-magnitude export* ("rough estimates with inaccurate numerical prefactors"). Pressure balance RT₄/μ ~ Gm/r₄, combined with the adiabat T ∝ r^{−(3γ−3)}, gives r₄ ~ r₃(RT₀r₃/μGm)^{1/(3γ−4)} [computed]. The collapse halts only if γ > 4/3 (p ∝ r^{−3γ} must beat r^{−4}), which is a stated condition that guarantees a qualitative behaviour.
  * *Contradictory contexts across parts.* Part (iii) neglects pressure; part (vi) is about pressure stopping the collapse. These are different contexts and must not be mixed.
* **Cross-problem contexts at IPhO 2025.** T2 globally excludes surface tension and lets a gas phase appear at the equilibrium threshold. T3 makes surface tension decisive: a critical radius a_c for growth, and bubbles growing from pre-existing cavities. Later in T3 it is neglected again for visible bubbles ("the excess pressure due to surface tension can be neglected and P_b ≈ P₀", a stated P2 regime a ≫ a_c) [repo-verified]. One exam contains three different contexts for the same physics, all fine. This is the user's "arguments for P and not-P in contradictory contexts", observed in the wild.

**Tally over §8.1–8.3** (rough):

| | §8.1 | §8.2 | §8.3 |
|---|---|---|---|
| in-model F steps | 6 | 3 | ~12 |
| exact bridges | 1 | 2 | 2 |
| approximate bridges | 0 (c_P stipulates) | 3 | 3 (one P3, one P2, one P4) |
| reading items needing judgment | 1–2 | 4 | 1–2 (plus one silent import) |

The user's hypothesis "there's a local setting up of a clear thing" holds in all three. The local models are clear; the unclear part is concentrated in ρ and in the few approximate bridges.

---

## 9. Theorem candidates and design ideas from this strand

**TC1. Universal grading (dimension inference as learning meaning from positive examples).**
* *Existence and computability.* The finest abelian grading under which a set E of observed equations is homogeneous exists and is unique up to isomorphism. It is computable by Smith normal form, and every homogeneous grading factors through it.
* *Learning.* The most-specific learner identifies the target grading in the limit on any text that eventually exhibits generating relations. It is conservative, and positive data never refutes coarser gradings.
* *Residue.* The residual non-identifiability is precisely base change plus the choice of dimensional constants (SI / Gaussian / natural units), an exact H7 residue settled by convention.
* *Extensions.* A noise-robust MDL version. The analogous statement for orientation gradings.

**TC2. Invariance-generated negative data.**
* *Statement.* If a group G_c is declared valid in context c, then every sound rule is G_c-equivariant. A candidate rule that is not equivariant is refuted by a G_c-image of one of its own accepted instances.
* *Quantitative version.* Augmenting positive data by G_c-orbits multiplies effective coverage. For finite-elasticity classes it preserves identifiability.
* *Context indexing.* G_c is context-indexed (time reversal only without dissipation). So the learner must learn *which symmetries hold where*, and that too is learnable from coherence failures.
* *Companion rule.* Symmetry-of-solution steps require uniqueness certificates (the user's note).

**TC3. Germ semantics for idealized contexts.**
* *Definition.* Contexts are (family, filter) pairs. Truth in a context is filter-eventual truth.
* *Properties.*
  * (a) closure under classical consequence, with no explosion when the M_θ are eventually consistent, even when the ε = 0 theory is inconsistent (Painlevé, the uniform gas ball);
  * (b) equivalence to truth in a nonstandard model for an ultrafilter refinement (Łoś), giving `ist(c, φ)` a concrete semantics;
  * (c) non-commuting limits give distinct contexts, so the filter is part of the reading;
  * (d) L7's well-posedness precondition restated along the filter.
* *Connections.* This links the brief's contexts problem, Raiman's FOG and Fleuriot's Principia to one construction.

**TC4. Decidable asymptotic grading.**
* *Statement.* For exp-log answers in one small parameter, "q₁ ∼ q₂" and "q₁ − q₂ = o(εᵏ)" are decidable via Gruntz's algorithm, modulo constant zero-equivalence (Richardson). With several parameters, decidability needs a declared scale hierarchy.
* *Use.* This formalizes marking-scheme practice ("with or without S_t ≪ S_b").

**TC5. Relative soundness of the SPS checker against adversarial solvers.**
* *Statement.* Suppose in-model steps are kernel-checked; exact bridges are proved; approximate bridges carry certificates with side conditions evaluated in the parent; and contexts are declared deformations. Then accepted exports hold in every admissible completion, with error ≤ Σ L_k δ_k.
* *Negative companion.* No finite certificate set covers effects outside M_top. Soundness is necessarily relative to (ρ, M_top).

**TC6. Simulation-as-oracle learning of bridge tolerances.**
* *Setting.* Inside M_top, random instances give labeled data for "schema s at Π-value π meets tolerance τ".
* *Monotone case.* If the error is monotone in π (Laymon monotonicity), the acceptance region is a threshold. It is PAC-learnable with O((1/ε)log(1/δ)) samples, and it is upgradable to worst-case soundness by one validated-numerics check at the learned threshold.
* *Non-monotone case.* Without monotonicity, worst-case soundness needs a covering argument plus a Lipschitz bound.
* *Role.* This is the physics analogue of Schwartz–Zippel spot checks for algebra (orchestrator idea 3).

**TC7. Completion-independence certificates.**
* *Statement.* Let an underspecified c_P have free completion parameters θ_f. An answer is supervaluationally correct iff it is invariant in θ_f to within the stated tolerance. A proof of ∂Q/∂θ_f = 0 (EuPhO's α) or a variation bound is a sufficient F certificate.
* *Use.* The Gricean heuristic "unspecified ⇒ irrelevant" becomes a proof obligation.

**Design ideas.**
1. Adopt the SPS format (§7.1) with three hard rules:
   * no silent imports;
   * every local model carries an existence witness and a uniqueness lemma;
   * every approximate bridge carries a neglected-term estimate *in the robust form* (valid over the admissible range of the parameter, not at a guessed value; cf. C.3).
2. **Tolerance-aware export.** If c_P gives an answer tolerance (marking intervals, significant figures), the checker verifies that the composed approximation error is within it, as in C.4 (1.3% vs ±5%).
3. **Bridge catalogue = §2.2 table**, each row backed by a theorem (Taylor with remainder, Gronwall, Tikhonov, stationary phase) and a known-failure list. Model it on Modelica's `replaceable` + `assert`.
4. **Andes-style F-layer**: random numerical substitution against a validated solution of each M_i, together with dimension typing using Physlib-style semantics.
5. **Analysis-by-synthesis for readings**: render the model's observable (floor illumination pattern, graph shape) and compare with the problem's figure. This is a partial, non-adversarial S-check on ρ.
6. **Experiments the project could run cheaply:**
   * (i) TC1 on equations scraped from olympiad solutions: does the finest grading recover SI, and which errors collapse it?
   * (ii) TC6 tolerance learning for 5–10 catalogue idealizations by simulation;
   * (iii) a mini-checker for the three §8 problems in SymPy plus validated ODE integration.

---

## 10. Where the brief's hypotheses need correction or refinement

1. **H6's list of coherence checks mixes four logical roles** (§3.7). Dimensions and symmetry are invariance constraints on the rule set: worst-case, and a source of free negative data. Conservation laws are in-model theorems. Limiting cases are cross-context regression tests, valid only for regular limits. Order-of-magnitude checks are export side conditions. Only the first two are "coherence" in the brief's sense.
2. **H6 says "world feedback trains export rules".** For olympiad-grade checking, export tolerances can be trained by *simulating M_top* (TC6). World feedback is needed only to calibrate M_top, and for olympiad grading not even that, since c_P is the root (agreeing with L7). Many exports are moreover *exact* (symmetry, decomposition, isomorphism) and purely mathematical.
3. **The brief takes "contexts are internally consistent chunks".** Problem contexts are often *literally inconsistent at the limit* yet fine along it. Germ semantics (TC3) is needed, and L7's well-posedness precondition should be restated along the filter.
4. **Import filters are problem-relative, not idealization-relative.** IPhO 2025 T2 deliberately imports vapour pressure into a "no surface tension" context, and T3 makes surface tension decisive. L7's example (vapour pressure must not enter the p = 0 context) is right for its query and wrong as a general filter.
5. **H1 needs a physics-specific split.** Most steps of a structured physics solution *can* be checked worst-case. The non-worst-case residue is the reading and unmodeled effects. Present AI systems put LLM judges *everywhere*: answer equivalence (Physics Supernova), step scoring (PhysReason PSAS-S, HiPhO), self-review (PhysicsMinions). That is exactly the average-case verification H1 warns about. A principled checker shrinks the J-surface to ρ and defends it with completion-independence, round-trip rendering and declared deformations.
6. **H7 has a fully solvable instance**: dimension systems (TC1). Coherent, empirically equivalent alternative "meanings" (SI, Gaussian, natural units) are exactly the residue that positive data plus coherence leave, and *convention* settles it. That is the third of the brief's three answers.
7. **Success criterion 3 should be re-aimed.** *Solving* IPhO-style problems at gold level under rubric grading is already done by AI (HiPhO data; Physics Supernova; P1). The unmet and valuable target is a *principled checker*: SPS plus TC5, with an explicit, minimized judgment layer. The modeling-heavy EuPhO is the right stress test.
8. **Bibliographic notes on the brief.** I could not identify "Boender et al." in physics formalization; the nearest is a quantum-protocol paper. OlymMATH is, to my knowledge, a math benchmark [unverified]. HepLean/PhysLean is now **Physlib** (leanprover-community) [repo-verified].

---

## References

**Repo-verified** (read directly from cloned repositories in this session):
* Physlib (HEPLean/physlean → leanprover-community/physlib), commit `d630c36` (2026-10-02): README, CITATION.cff, AI-POLICY.md, `Units/UnitDependent.lean`, `Units/Basic.lean`, `Units/Examples.lean`, `ClassicalMechanics/Pendulum/SimplePendulum/SmallAngle.lean`, `PeriodFormula.lean`, `Optics/Basic.lean`.
* He et al. (2024), OlympiadBench, ACL 2024, arXiv 2402.14008 (README and `eval/auto_scoring_judge.py`).
* Xu et al. (2025), UGPhysics, ICML 2025, arXiv 2502.00334 (README and `codes/eval.py`).
* Zhang et al. (2025), PhysReason, ACL 2025, arXiv 2502.12054 (README).
* Yu et al. (2025), HiPhO, arXiv 2509.07894 (README; `hipho.json` v2025-09-16 via the P1 repo).
* Qiu et al. (2025), Physics Supernova, arXiv 2509.01659 (README, judge code, IPhO 2025 problem texts).
* P1 Team (2025), P1, arXiv 2511.13612; PhysicsMinions, arXiv 2509.24855 (README).
* IPhO 2025 Theory Problem 2, "Cox's Timepiece", official solution and marking scheme (PDF in the P1 repo); IPhO 2025 Theory Problems 1–3 texts (Physics Supernova repo).

**From memory, confident:**
* Buckingham 1914, *Phys. Rev.* 4:345–376.
* Bridgman 1922, *Dimensional Analysis*.
* Barenblatt 1996, CUP.
* Kennedy 1994 (ESOP), 1997 (POPL).
* Atkey, Johann & Kennedy 2013 (POPL).
* Fleuriot 2001 (Springer).
* Immler 2018, *JAR* 61:73–111.
* Tucker 2002, *FoCM* 2:53–117; Tucker 2011 (Princeton UP).
* Sussman & Wisdom 2001/2014 (MIT Press).
* Gruntz 1996 (ETH thesis).
* Richardson 1968, *JSL* 33.
* Kuipers 1986, *AIJ* 29.
* de Kleer & Brown 1984, *AIJ* 24.
* Iwasaki & Simon 1986, *AIJ* 29.
* Simon & Ando 1961, *Econometrica* 29.
* Fenichel 1979, *JDE* 31.
* Stewart 2000, *SIAM Review* 42.
* Norton 2012, *Phil. Sci.* 79.
* Larkin, McDermott, Simon & Simon 1980, *Science* 208.
* Chi, Feltovich & Glaser 1981, *Cognitive Science* 5.
* VanLehn et al. 2005, *IJAIED* 15.
* Mahajan 2010, 2014 (MIT Press).

**From memory, details unverified:**
* Kennedy 1996 thesis TR number; Kennedy 2010 CEFP pages.
* Curtis, Logan & Parker 1982.
* Siano 1985.
* Raiman 1991 pages; Mavrovouniotis & Stephanopoulos 1988; Dague 1993.
* Stannett & Németi 2014 pages.
* Foster & Wolff AFP entry.
* Siddique, Aravantinos & Tahar 2013.
* Broman, Aronsson & Fritzson 2008; Fritzson's Modelica text edition.
* Tooby-Smith, HepLean, *CPC* 2025 volume and pages.
* Novak 1977; de Kleer 1977; Bundy et al. 1979.
* Shapiro 2005.
* Kortemeyer 2023.
* Calkin & March 1989.
* Iwasaki & Bhandari 1988.
* PHYBench, PhysicsEval, OlymMATH descriptions.
* Physics Supernova score figure (23.5/30).
* IPhO 2012 Problems 1 and 3 statements; EuPhO 2025 T1 official text.
