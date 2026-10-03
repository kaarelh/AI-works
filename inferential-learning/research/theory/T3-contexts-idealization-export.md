# T3. Contexts, idealization and export: toward a principled checker for physics-olympiad reasoning

*Theory thread T3 of the inferential-learning project. Read `00-brief.md` first. This note builds on `lit/L7` (context-tree calculus, three import regimes, no-free-export, adversarial stipulation), `lit/L9` (germ semantics, the Structured Physics Solution format, worked problems), `lit/L10` (the user's notes, in particular "reductio hygiene" and "verification from truth… wtf is that?"), and on T1 (soundness under search) and T2 (coherence as negative data).*

*Status labels: **[proved]** = full proof here; **[cited]** = known result, source given, **(unverified)** where from memory; **[sketch]**, **[conjecture]**, **[computed]** = numerical check by a script in `theory/T3-checks/`. **TOSU** = "trivial once set up": the content is in the definitions. I try to say plainly which results are TOSU.*

*Scripts (all re-run for this version): `leg_exact.py`, `leg_mc_flux.py`, `sps_checker.py` (worked example and mini-checker; revised after verification); `realizability.py`, `realizability_uninformative.py`, `realizability_sup.py`, `realizability_deep.py` (Thm 2.4(a)); `realizability_frame.py` (Thm 2.4(b),(c), Prop 2.7; added after verification); `learn_regions.py`, `pendulum.py`, `drag_sign.py`, `projectile.py` (Sections 3–4); `hygiene.py` (Thm 1.9).*

*This version was revised after adversarial verification. Statements that changed materially keep their numbers and are marked "(revised after verification)"; the full list is in the Verification log at the end.*

---

## 0. Summary

The user wants to *check untrusted physics reasoning*. Such reasoning is "a dance with many clear setups". Some setups are suppositions made for reductio. Some are idealizations that contradict known facts ("air pressure is 0"). Some are underdetermined ("the sun's elevation is not given"). This thread gives a semantics for that dance, a soundness theorem for a checker of it, and impossibility results marking what no checker can do.

1. **Semantics (§1).** Every context denotes a *filter of models drawn from one deformation family* (the "top model" with its parameters).
   * The root is the actual or intended point.
   * A suppositional context SUP(A) refines its parent's filter by ‖A‖.
   * An idealized context DEF is the push-forward of the parent filter along a *declared deformation* of named parameters toward an ideal value. "Limit" semantics uses the principal filter at the ideal point; "germ" semantics uses the punctured neighbourhood filter.

   Truth in a context is classical and never explodes while the filter is proper, even when the stipulations contradict the root or the limit model does not exist (Prop 1.4–1.6). Discharge is exact (Prop 1.5). Import filters are not a free parameter. Sentences stable under the declared deformation are always soundly importable, and they are *exactly* the sentences that are soundly importable uniformly over all actual points and ideal values (Lemma 1.8, revised after verification).

2. **Reductio hygiene (§1.4)** [proved]. This is the user's worry made precise.
   * A reductio inside a context whose imported fragment is inconsistent refutes every sentence, both A and ¬A (Thm 1.9b).
   * No test that looks only at the derivation can detect this, if it accepts every sound reductio from consistent premises. An elementary 3-premise example shows it (Thm 1.9c).
   * A *consistency certificate* does suffice (Thm 1.9d). It is a structure that satisfies the imported fragment *and every rule instance used*, for example a properness witness for the context.
   * In approximately-true frameworks, exact-equality reasoning can derive ⊥ from approximately true premises read as exact equalities ("100 = 99.9"). ⊥ is a discontinuous functional of the data, while directly derived values are continuous ones. That is the precise sense in which "constructive reasoning is more trustworthy in messy domains" (Prop 1.10).

3. **Coherence (§2).**
   * *Eternalism is impossible* [proved, TOSU]. Take a proper idealized context c whose stipulation is false. No translation of "φ holds in c" into a world sentence that is truth-functional in (stipulation, φ) can track in-context truth. Stripping indices makes correct idealizations incoherent; conditionalizing makes them vacuous (Thm 2.1).
   * *The right constraint is realizability* (revised after verification).
     * In the **frame-free** sense, DEF contexts are unconstrained by their parents. There it has an exact local characterization [proved; brute-force checked on 4,500 random instances plus 2,000 deeper ones]. A set of context-indexed judgments with bridge uses is realizable iff, after folding suppositional contexts into their parents as conditionals, the root and every **anchored** idealized context are consistent. A context is anchored if it is certified, or exports through an informative bridge into an anchored context (Thm 2.4(a)).
     * In this paper's own frame semantics (Def 1.3), undeformed parameters are rigid and identically declared contexts share a filter. So the local criterion is necessary but *not sufficient* (Thm 2.4(b),(c)).
     * Under limit semantics the exact criterion is *non-local* [proved; checked on 8,000 instances]. Contexts at the same parameter point must be jointly consistent with the actual parameter values (Prop 2.7).
     * Reductio immunity and "well-posedness only for exporting idealizations" are corollaries.
     * The informativeness hypothesis is necessary (117/600 counterexamples without it).
   * *Soundness and blame localization* [proved]. Every contradiction derived in a designated context has an unsound step in its *derivation cone*. Steps outside the cone are never blamed (Thm 2.5, Cor 2.6). This feeds T2's oligarchic-halving learner, with context-indexed steps and the root (plus certified contexts) as the designated contexts.

4. **Export (§3).**
   * *No free export* [proved]. One "invisible perturbation" lemma gives four instances; it is the standard adversary argument of information-based complexity. On a class closed under adding smooth functions, no export rule is sound for any finite tolerance if its information is:
     * the full jet at the idealization (C^∞ families, flat perturbations);
     * the full germ (C^∞ families, bump perturbations);
     * any finite jet, even for entire analytic families;
     * any finite set of samples.

     Sound export needs *information of finite radius* in the sense of information-based complexity (Thm 3.3, Prop 3.4).
   * *Certified-neighbourhood export*, *rate-qualified asymptotic export* and *Gronwall finite-horizon export* [proved] (Thms 3.5–3.6). The Gronwall export has a tube form whose hypotheses the parent can check.
   * A *fully rigorous projectile certificate* for any antiparallel drag force bounded by k|v|² [proved; checked against simulation, 0/300 violations] (Thm 3.7).
   * *Error propagation through chains*, including the "100 = 99.9" catastrophe as an error budget exceeding the claim [proved] (Thm 3.8).
   * *Adversarial stipulation* [proved; revised after verification]. With side conditions evaluated in the child, or with free (non-deformation) stipulations, a solver can export arbitrary false claims. Every accepted export is sound given three things: declared deformations, parent-evaluated side conditions, and a **parent-derived well-posedness certificate** for the exporting context. Without the certificate, an ill-posed limit exports anything through a vacuously true schema (Thm 3.9).

5. **Learning bridge validity (§4).**
   * *Coherence cannot calibrate tolerances* [proved]. If the environment class is closed under common shifts, every coherence-only calibrator is unsound or outputs infinite tolerances (Thm 4.1). Minimal-repair learners drift to ∞ and never restrict a regime: computed on the small-angle bridge, the tolerance grows 1e-3 → 4.4 (Prop 4.2).
   * *Conformal calibration* gives exchangeable coverage (here 0.913 at nominal 0.9) but fails on the adversary's chosen instance (Thm 4.3).
   * *No certification without regularity* (Thm 4.4) is the learning twin of no free export.
   * *A conservative Lipschitz certifier* is deterministically sound against any solver. It is complete at margin γ with ⌈L/(γ−η)⌉^d validated oracle calls, and any sound certifier needs ⌊L/(2γ)⌋^d (Thm 4.5).
   * *A monotone certifier* needs log₂(1/h) calls (Thm 4.6). Monotonicity is a real hypothesis: for the drag-damped pendulum the period shift is non-monotone in the drag, and a monotone certifier would certify a false region (Prop 4.7, computed).

6. **Main theorem (§5).** *Relative soundness of the SPS checker* [proved; TOSU given §§1–3; revised after verification]: for every solver, an accepted SPS's export holds in every admissible world of its reading. The checker must check four things:
   * the legality of every axiom (canonical stipulations only in idealized contexts);
   * that each cited bridge schema is indexed by its context's declared deformation;
   * the side conditions and well-posedness certificates in the parent;
   * kernel steps and imports.

   A first version omitted the first two checks, and Thm 3.9(b)'s attack then passed. The residual **judgment layer** is exactly:
   * (J1) reading containment, W_{ρ*} ⊆ W_ρ;
   * (J2) top-model adequacy, needed only for world claims;
   * (J3) the trusted base (kernel, law and bridge catalogues, validated numerics).

   (J1) and (J2) are ineliminable (Thm 5.4). *Supervaluational correctness* is the maximal sound criterion under reading uncertainty (Thm 5.5). *Gricean determinacy is one-sided* (Prop 5.6). It can refute some over-wide readings but never an over-narrow one, and silent narrowing never decreases it. So silent narrowing is the solver's natural attack.

   This completes a table of three one-sided signals:

   | Object | Error the free signal catches | Error it misses |
   |---|---|---|
   | rules | over-acceptance (coherence) | under-acceptance |
   | tolerances | too-narrow tolerances (coherence) | too-wide tolerances |
   | readings | too-wide readings (determinacy) | too-narrow readings |

7. **Worked example (§6): EuPhO 2025 T1(a), the polished chair leg** (statement as reconstructed in L9).
   * I derive the *exact* top-model illuminance E = I₀ac/(2s + ac) [proved; matches a 40M-ray Monte Carlo to within ≈1% sampling noise]. At every lit floor point it is *exactly* independent of the free sun angle α, so the completion-invariance certificate is exact.
   * I prove a *rigorous thin-leg bridge bound* in (a/r, sin(φ/2)) [proved; 0 violations on 2.5M points] and compose it with a finite-sun bridge.
   * The mini-checker accepts the honest solution on r ∈ [20a, 34a] with certified error ≤ 8.9% (exact error ≤ 2.6% + 0.9%). It rejects eleven adversarial variants:
     * an overclaimed domain;
     * a child-evaluated side condition;
     * an α-dependent answer (the user's own algebra slip);
     * a silently narrowed reading;
     * a silent import, declared or undeclared;
     * five further attacks.

     A referee showed that the first version of the mini-checker *accepted* four of those five attacks: α-dependent wrong answers and a domain violating the bridge hypotheses. It was repaired after verification (§6.4).

**Honest assessment** (§7). Mathematically, almost everything here is TOSU or standard (filters, Łoś, Gronwall, conformal, covering numbers, the IBC adversary argument). The contributions are:
* the *definitions* that make the user's informal desiderata into checkable conditions;
* the frame-free realizability criterion and its limit-semantics refinement;
* a clean statement of reductio hygiene;
* the three-way one-sidedness;
* a complete worked checker run with rigorous certificates.

The deep, unsolved part is the reading (J1). Here I can only prove that it cannot be eliminated, and say what evidence bears on it.

---

## 1. Contexts: syntax and semantics

### 1.1 Deformation frames, worlds, readings

**Definition 1.1.**
* Let $L$ be a many-sorted first-order language with a sort $\mathbb R$ and **parameter constants** $p_1,\dots,p_n$ of that sort.
* A **deformation frame** is a partial map $\mathfrak M:\Lambda\rightharpoonup\mathrm{Str}(L)$ with $\Lambda\subseteq\mathbb R^n$ and $p_i^{\mathfrak M(\lambda)}=\lambda_i$. Its domain $\mathrm{dom}\,\mathfrak M$ is the set of parameter values at which the model exists ("is well-posed").
* *(Added after verification.)* In every $\mathfrak M(\lambda)$ the sort $\mathbb R$ is interpreted as the ordered field of real numbers, with standard numerals and standard arithmetic. So distinct numerals denote distinct reals, and an arithmetic formula in the $p_i$ means the same thing in every structure. Def 1.7's "undeformed data", the standard names of Def 2.3 and the informativeness of interval exports all rely on this. Ideal values at infinity (e.g. a mass $m\to\infty$) are handled by reparametrizing (e.g. $\mu=1/m\to0$), so every parameter value, ideal ones included, is a real number.
* A **world** is a pair $w=(\mathfrak M_w,\lambda^*_w)$ with $\lambda^*_w\in\mathrm{dom}\,\mathfrak M_w$: a top-model family together with the actual (or intended) parameter point.
* A **reading** $\rho$ of a problem yields three things:
  * a set $W_\rho$ of worlds (the *admissible completions*: given parameters fixed, measured ones in intervals, free ones in ranges);
  * a query term $Q$;
  * a set $\mathrm{Ax}_\rho$ of sentences true at every $\mathfrak M_w(\lambda^*_w)$, $w\in W_\rho$.

  The **laws** of the frame are the sentences true at every $\mathfrak M_w(\lambda)$, $\lambda\in\mathrm{dom}$.

*Example.* For a projectile, take $L$ with position and velocity functions of time and parameters $(g,v_0,\theta,k)$. Then $\mathfrak M(\lambda)$ is the solution of $\ddot{\mathbf x}=-g\hat z-k|\dot{\mathbf x}|\dot{\mathbf x}$. "Neglect air" is a deformation of the single coordinate $k$ toward $0$.

### 1.2 Context trees and filter semantics

**Definition 1.2 (contexts).** A context tree is a finite rooted tree with root $@$ and parent map $\pi$. Each non-root context has a kind:
* **SUP(A):** supposition of a sentence $A$ (reductio, case split, conditional proof).
* **DEF(D, λ°, 𝒢):** a *declared deformation*. Here $D\subseteq\{1..n\}$ names the deformed parameters, $\lambda^\circ\in\mathbb R^D$ the ideal values, and $\mathcal G$ is a filter on $\mathbb R^D$ converging to $\lambda^\circ$ (the *path*). Two cases:
  * $\mathcal G=$ principal filter at $\lambda^\circ$: **limit semantics** (L7's local models);
  * $\mathcal G=$ punctured neighbourhood filter, possibly restricted to a curve: **germ semantics** (L9 §2.3).
* **AUX:** a definitional extension (new symbols with explicit definitions, e.g. "the reversed trajectory"). It is semantically part of its parent and is not discussed further.

**Definition 1.3 (filter semantics).** For each world $w$, each context $c$ gets a filter $\mathcal F_c(w)$ on $\mathrm{dom}\,\mathfrak M_w$. Write $\|\varphi\|_w=\{\lambda\in\mathrm{dom}\,\mathfrak M_w:\mathfrak M_w(\lambda)\models\varphi\}$ and $\delta(\lambda,\mu)=\lambda[D:=\mu]$.
* $\mathcal F_@(w)$ is the principal filter at $\lambda^*_w$.
* SUP(A) under $p$: $\mathcal F_c(w)=\mathcal F_p(w)\sqcup\|A\|_w$, the filter generated by $\mathcal F_p(w)\cup\{\|A\|_w\}$.
* DEF under $p$: $\mathcal F_c(w)$ is generated by the sets $\delta(F\times G)\cap\mathrm{dom}\,\mathfrak M_w$ for $F\in\mathcal F_p(w)$ and $G\in\mathcal G$.

**Truth** is $c\models_w\varphi$ iff $\|\varphi\|_w\in\mathcal F_c(w)$. The context-free (eternal) proposition **ist(c, φ)** is true at $w$ iff $c\models_w\varphi$. A claim is **supertrue** under $\rho$ iff it is true at every $w\in W_\rho$. A context is **proper** at $w$ if $\emptyset\notin\mathcal F_c(w)$.

So, below a root parent, a germ context is true of φ iff "φ holds for all deformed parameters sufficiently close to the ideal, along the path, at the actual values of everything else." That is L9's germ semantics, now also defined for nested contexts.

**Proposition 1.4 (classicality without explosion; Łoś) [proved; Łoś cited].** Fix $w$ and $c$, and let $\mathrm{Th}_w(c)=\{\varphi:c\models_w\varphi\}$.
* (a) $\mathrm{Th}_w(c)$ is closed under first-order consequence.
* (b) It is consistent iff $c$ is proper at $w$.
* (c) $\mathrm{Th}_w(c)=\bigcap_{U}\mathrm{Th}\big(\prod_U\mathfrak M_w\big)$, where $U$ ranges over the ultrafilters extending $\mathcal F_c(w)$ and $\prod_U$ is the ultraproduct of the structures $\mathfrak M_w(\lambda)$.

*Proof.*
* (a) Suppose $T\models\psi$ with $T\subseteq\mathrm{Th}_w(c)$. By compactness, $\varphi_1..\varphi_k\models\psi$ for some $\varphi_i\in T$. Then $\|\psi\|\supseteq\bigcap_i\|\varphi_i\|\in\mathcal F$, and filters are upward closed.
* (b) If $c$ is proper, every finite subset of $\mathrm{Th}_w(c)$ has a truth-set intersection in $\mathcal F$, hence nonempty, hence a model. Compactness finishes. If $c$ is improper, $\|\bot\|=\emptyset\in\mathcal F$.
* (c) A set is in a filter iff it is in every ultrafilter extending it (standard: if $X\notin\mathcal F$, then $\mathcal F\cup\{X^c\}$ generates a proper filter, which extends to an ultrafilter). Łoś's theorem (Łoś 1955 [cited]) gives $\prod_U\models\varphi\iff\|\varphi\|\in U$. ∎

Reading (c) (revised after verification): an idealized context's theory is what holds in every ultraproduct of the family $\mathfrak M_w$ along an ultrafilter refining $\mathcal F_c(w)$.
* Under limit semantics, $\mathcal F_c$ is principal or improper. So this is just the standard model $\mathfrak M_w(\lambda^*[D:=\lambda^\circ])$, and no nonstandard model is involved.
* Under germ semantics with a root parent, the ultraproducts are nonstandard models. In them the deformed parameters are infinitely close to the ideal along the declared path, while the undeformed parameters take *exactly* their actual values, since $\mathcal F_c$ contains the slice on which the undeformed coordinates equal $\lambda^*$. Ultraproducts in which an undeformed parameter is merely infinitely close to its actual value are not covered.

This gives McCarthy's `ist` a concrete semantics. In the germ case it is the precise sense in which Robinson vindicated Leibniz (L6, H5). Th(c) is not complete in general (germs may oscillate). Its incompleteness is the residual underdetermination that the reading must settle.

**Proposition 1.5 (SUP is exact discharge) [proved].** For SUP(A) under $p$: $c\models_w\psi$ iff $p\models_w A\to\psi$. In particular, $c$ is improper iff $p\models_w\neg A$.

*Proof.* $X\in\mathcal F_p\sqcup\|A\|$ iff $X\supseteq F\cap\|A\|$ for some $F\in\mathcal F_p$. Now $\|\psi\|\supseteq F\cap\|A\|$ iff $\|A\to\psi\|=\|A\|^c\cup\|\psi\|\supseteq F$. Take $\psi=\bot$. ∎

**Proposition 1.6 (what idealized contexts may do) [proved; TOSU].**
* (a) *Contradicting the root.* Let DEF deform $p_{\rm atm}$ toward $0$, with limit semantics, in a hydrostatics frame whose laws do not mention phase change. Then $c\models p_{\rm atm}=0$ and $@\models p_{\rm atm}=1.0\times10^5$. Both contexts are proper, and no sentence is both true and false *in one context*.
* (b) *Inconsistent limit, consistent germ.* Take a rope of mass $m_r$ pulled by a force $\Phi\ne0$, with $\mathrm{dom}=\{m_r>0\}$ (at $m_r=0$, $\Phi=m_r a$ has no solution). The limit context is improper, since $\lambda^\circ\notin\mathrm{dom}$ makes $\delta(\{\lambda^*\}\times\{0\})\cap\mathrm{dom}=\emptyset$. The germ context is proper and proves "$|a|>K$" for every numeral $K$. (Revised after verification: the sign of $a=\Phi/m_r$ is that of $\Phi$, so "$a>K$" needs $\Phi>0$.) (Painlevé's rigid-body paradox and L9's uniform gas ball are the same phenomenon.)
* (c) *Norton's distinction.* The limit model's value is the germ's limit iff $Q$ is continuous at $\lambda^\circ$ along $\mathcal G$. Here "the limit model's value is the germ's limit" means: for every open interval $I$, if $Q(\lambda^\circ)\in I$ then the germ context proves $Q\in I$. ("The limit property equals the property of the limit system.") d'Alembert's paradox is the failure case: the potential-flow limit model has drag $0$, while the germ as viscosity $\to0$ has drag bounded away from $0$.

*Proof.* (a) and (b) are by inspection of Def 1.3. For (c): under germ semantics, $Q\in I$ holds iff $Q(\lambda)\in I$ for 𝒢-almost all λ. "Every open $I\ni Q(\lambda^\circ)$ eventually contains $Q(\lambda)$" is the definition of $Q(\lambda)\to Q(\lambda^\circ)$ along 𝒢. ∎

### 1.3 Imports are fixed by the deformation

**Definition 1.7.** A sentence φ is **D-stable** in $w$ if, for all $\lambda,\lambda'\in\mathrm{dom}\,\mathfrak M_w$ that differ only in coordinates in $D$, $\mathfrak M_w(\lambda)\models\varphi\iff\mathfrak M_w(\lambda')\models\varphi$. Two syntactic sufficient conditions:
* φ is a **law** (true on all of dom);
* φ is an arithmetic formula in the parameter constants $p_i$ with $i\notin D$ (**undeformed data**).

**Lemma 1.8 (import soundness) [proved] (part (b) and the scope remark added after verification).**
* (a) If φ is D-stable and $p\models_w\varphi$, then $c\models_w\varphi$ for the DEF child $c$ deforming $D$. This holds for any parent filter and any path 𝒢.
* (b) *Uniform converse.* Fix the frame $\mathfrak M_w$ and $D$. Suppose that, for every actual point $\lambda^*\in\mathrm{dom}\,\mathfrak M_w$ and every ideal value $\lambda^\circ\in\mathbb R^D$, the limit-semantics child $c$ of the root satisfies $@\models\varphi\Rightarrow c\models\varphi$. Then φ is D-stable.
* *Scope.* For one *fixed* declared deformation the converse of (a) is false. Take $D=\{k\}$, $\lambda^\circ=0$, limit semantics and φ := "$k\le1$". Importing φ is sound at every world: either the parent refutes φ, or $c\models k=0$ and hence $c\models\varphi$ (or $c$ is improper). Yet φ is not D-stable when dom contains points that differ only in $k$, say $k=0.5$ and $k=2$.

*Proof.*
* (a) $\|\varphi\|\in\mathcal F_p$. For $\lambda\in\|\varphi\|$ and any μ, $\delta(\lambda,\mu)$ differs from λ only on $D$, so it lies in $\|\varphi\|$ when it lies in dom. Hence $\delta(\|\varphi\|\times G)\cap\mathrm{dom}\subseteq\|\varphi\|$, which puts $\|\varphi\|$ in $\mathcal F_c$.
* (b) Let $\lambda,\lambda'\in\mathrm{dom}$ differ only on $D$, with $\mathfrak M_w(\lambda)\models\varphi$. Take $\lambda^*=\lambda$ and $\lambda^\circ=\lambda'_D$. Then $@\models\varphi$. The child's filter is generated by $\{\lambda'\}\cap\mathrm{dom}=\{\lambda'\}$, so it is principal at $\lambda'$, and $c\models\varphi$ says $\mathfrak M_w(\lambda')\models\varphi$. The other direction is symmetric. ∎

*Consequence.* L7 treated the import filter as a third learned object. L9 observed that it is "problem-relative" (IPhO 2025 T2 imports vapour pressure into a no-surface-tension context; T3 makes surface tension decisive). Both observations are explained by Lemma 1.8: **the imports that are sound uniformly in the actual point and the ideal value are exactly what the declared top-model family makes stable**.
* "The vapour pressure of water is 2.3 kPa" is a law or datum of a frame that includes phase equilibrium. It is importable there, and the $p_{\rm atm}\to0$ context then correctly boils.
* In a frame of incompressible hydrostatics without phases it is simply not in the language.

So, for imports required to be sound uniformly in this sense, learning import filters reduces to learning which top-model family the problem intends. That is part of the reading (§5).

### 1.4 Reductio hygiene

The user's warning (L10 §1.8): proofs by contradiction inside a known-inadequate framework "might really involve subverting the background framework… and there's a chance such an argument could equally be provided starting from the statement itself."

**Setting.**
* A context $c$ has an explicit **imported fragment** $K_c$, a finite set of sentences used as premises.
* $\hat R$ is the (learned) rule set.
* A **reductio of A in c** is an $\hat R$-derivation of ⊥ from $K_c\cup\{A\}$, inside SUP(A). Accepting it yields $c\Vdash\neg A$.

**Theorem 1.9 (reductio hygiene) [proved] (parts (c), (d), (e) revised after verification).**
* (a) *Soundness.* If every $\hat R$-instance used is $c$-sound and $c\models K_c$, every accepted reductio yields a true $\neg A$ in $c$.
* (b) *Inconsistent imports refute everything.* If $K_c\vdash_{\hat R}\bot$, then every sentence, including both $A$ and $\neg A$, has a reductio in $c$. The set of reductio-refuted sentences is then independent of the world. A reductio thus carries information about $A$ only *relative to the consistency of $K_c$*.
* (c) *Derivation-local tests are not enough.* Let $K=\{A\to q,\ \neg A\to q,\ \neg q\}$. Then:
  * $K$ is unsatisfiable;
  * the reductio $D_A$ of $A$ uses $\{A\to q,\neg q\}$, which is satisfiable and becomes unsatisfiable only when $A$ is added;
  * the reductio $D_{\neg A}$ of $\neg A$ uses $\{\neg A\to q,\neg q\}$, which is satisfiable and becomes unsatisfiable only when $\neg A$ is added.

  Consider any test that is a function of the derivation alone (its used premises, steps and conclusion) and accepts every sound reductio from a consistent premise set. It accepts both $D_A$ and $D_{\neg A}$, although together they refute $A$ and $\neg A$ (`hygiene.py`). This is an elementary illustration, not a deep result: an inconsistent premise set supports reductios of both $A$ and $\neg A$, each from a consistent sub-premise set.
* (d) *A consistency certificate suffices.* Suppose a structure $N$ is supplied with $N\models K_c$ that also satisfies every $\hat R$-instance used in the reductio ($N\models\bigwedge\varphi_i\to\psi$). Then every reductio-refuted $A$ is false in $N$. In particular, no $A$ and $\neg A$ are both refuted.
  * The extra condition holds automatically if $\hat R$ is logically sound.
  * It is genuinely needed when the instances are only *context-relatively* sound, as in (a) and §2.3. Suppose $c\models q$ (e.g. $q$ is a law), so that the zero-premise instance "$/q$" is $c$-sound, and take $K_c=\{\neg q\}$. Then every $A$ and every $\neg A$ is reductio-refuted, although $K_c$ has a model.
  * If $c$ is proper and $c\models K_c$, a suitable $N$ always exists. The finitely many truth sets of $K_c$ and of the instances used all lie in $\mathcal F_c$, so their intersection is nonempty; any point $\lambda$ in it gives $N=\mathfrak M_w(\lambda)$. A properness witness for $c$ is therefore a certificate.
* (e) *Learning consequence.* Consider a coherence loss that consumes reductio outcomes from contexts whose imported fragment is $\hat R$-inconsistent; an uncertified context may be one. It receives the labels "$A$ false" and "$\neg A$ false" for every $A$. These labels are jointly unsatisfiable, systematic and world-independent, so they carry no information about the world. An uncertified context with a consistent fragment and sound rules produces no such labels.

*Proof.*
* (a) Run Thm 2.5 below in the child SUP(A).
  * Its filter refines $\mathcal F_c$ ($\mathcal F_{\mathrm{SUP}(A)}\supseteq\mathcal F_c$). So every $c$-sound Step instance is SUP(A)-sound, and every import of $K_c$ into the SUP child is sound.
  * The axiom $A$ is true there.
  * Hence SUP(A) ⊨ ⊥, i.e. $c\models\neg A$ by Prop 1.5.
* (b) Derivability is monotone in premises: a derivation of ⊥ from $K_c$ is one from $K_c\cup\{A\}$.
* (c) The facts about $K$ are checked by truth tables. From $A\to q$ and $\neg A\to q$, case analysis gives $q$, contradicting $\neg q$. Each two-premise subset has the model where $q$ is false and the supposition is false.
  * *Indistinguishability.* As a derivation, $D_A$ is identical to the reductio of $A$ from the consistent fragment $K'=\{A\to q,\neg q\}$. That reductio is sound, since $K'\cup\{A\}$ is unsatisfiable. So a test that depends only on the derivation and accepts sound reductios from consistent premise sets accepts $D_A$.
  * The same holds for $D_{\neg A}$ with $K''=\{\neg A\to q,\neg q\}$.
* (d) By induction along the derivation, if $N\models A$ then $N$ satisfies every derived line, because $N$ satisfies the premises and every instance used. So $N\models\bot$, which is impossible; hence $N\models\neg A$. The counterexample is direct. The existence claim was shown in the third bullet of (d).
* (e) follows from (b). ∎

So the hygiene condition is a **global** certificate on the imported fragment. In physics, that is a well-posedness witness: an explicit or validated-numerical solution of the local model (L9's SPS demands one for every local model). Such a solution satisfies $K_c$ and the local model's laws, relative to which the context's rules are sound. It is *not* a syntactic relevance condition on the derivation.

**Proposition 1.10 (the continuity asymmetry: why reductio is fragile in approximate frameworks) [proved; Moore cited].**
* Let the premises be equations $x_i=m_i$ that hold only to tolerance, $x_i\in[m_i-r_i,m_i+r_i]$.
* (a) A *direct* derivation that computes $y=g(x)$ for continuous $g$ is wrong by at most the modulus of continuity of $g$ on the box. It degrades gracefully.
* (b) *Exact-equality* reasoning can derive ⊥ from approximately true premises read as exact equalities. Take two models' values for the same length, $x=100$ m (flat Earth) and $x=99.9$ m (sphere), both true to ±0.2 m. Read exactly, the premises are jointly false. Substituting equals for equals is sound; the error is reading approximate premises as exact. Exact substitution gives $0=0.1$. The interval reading gives $x\in[99.8,100.1]\neq\emptyset$.
* (c) Sound replacement: a reductio of $A$ in an approximate framework is sound whenever the interval extension of the derived discrepancy excludes 0. That is, it *suffices* that the contradiction has a *margin* exceeding the propagated tolerance. This follows from inclusion monotonicity of interval arithmetic (Moore 1966 [cited]). The condition is sufficient, not necessary, because interval extensions overestimate ranges (the dependency problem).

The user's suggestion that "constructive" reasoning is more trustworthy in messy domains is thus right in a precise, limited sense. "x = y" defines a closed, typically interior-free set of data values, so ⊥-derivability is a discontinuous function of the data, while derived values are continuous functions of it. The fix is not to give up reductio but to type approximate claims as intervals (this is also the type discipline answering his "100 = 99.9" question, L10 Q11).

---

## 2. Coherence: why eternalism fails, and what to enforce instead

### 2.1 The impossibility of eternalism

**Theorem 2.1 (no truth-functional eternal reading of idealized claims) [proved; TOSU] (revised after verification: properness hypothesis added; generic witnesses).**
* Let $c$ be a DEF context that is **proper at $w$**, with a stipulation $S_c$ ($c\models_w S_c$; e.g. $p_{\rm atm}=0$) that is false at the actual point $\mathfrak M_w(\lambda^*_w)$.
* Let $\tau(c,\varphi)$ be any translation of "φ holds in c" into a world sentence whose truth value at $w$ is a function $f(S_c^w,\varphi^w)$ of the truth values of $S_c$ and φ at $w$.

Then $\tau$ does not track in-context truth at $w$. The sentences φ := ⊤ and ψ := ¬$S_c$ satisfy $c\models\varphi$, $c\models\neg\psi$ (so $c\not\models\psi$), and $\tau(c,\varphi)^w=\tau(c,\psi)^w$. Specifically:
* stripping ($f=\wedge$) makes every in-context claim false at $w$, so it is incoherent with the root;
* conditionalizing ($f=\to$) makes every in-context claim true at $w$, so it is vacuous;
* the remaining choices collapse "in c" into "at w".

*Proof.* Both φ and ψ are true at $w$, ψ because $S_c$ is false there. So $\tau(c,\varphi)^w=f(0,1)=\tau(c,\psi)^w$. Trivially $c\models\top$, and $c\models S_c=\neg\psi$. Since $c$ is proper, $\mathrm{Th}_w(c)$ is consistent (Prop 1.4b), so $c\not\models\psi$. ∎

The properness hypothesis is needed. An improper context proves everything; an example is the rope limit of Prop 1.6(b), whose stipulation $m_r=0$ is false at the actual point. There conditionalizing ($S_c\to\varphi$, true at $w$ for every φ) tracks in-context truth perfectly.

**Corollary 2.2 (eternalist coherence penalizes correct reasoning) [proved; TOSU] (revised after verification: representation dependence made explicit).** Call a coherence check *eternalist* if it flags a judgment set $J$ whenever the context-stripped set $\{\bigwedge\Gamma\to\varphi:(c,\Gamma,\varphi)\in J\}$ is unsatisfiable. Stripping deletes context indices and does *not* add suppositions as antecedents. It flags:
* (i) every sound reductio whose internal judgment $(\mathrm{SUP}(A),\Gamma,\bot)$ is recorded in $J$;
* (ii) every sound idealization whose stipulation contradicts a root judgment recorded in $J$ (e.g. the $p_{\rm atm}$ pair in Prop 1.6(a));
* (iii) every pair of sound contexts whose different answers to the same query are both recorded in $J$ (IPhO 2025 T2 vs T3 on gas-phase formation; L9 §8.4).

If $J$ records only the discharged conclusion $(@,\emptyset,\neg A)$ of a reductio, nothing is flagged. So what the check penalizes depends on how much of the reasoning is recorded.

By T2 Prop 7.1, a *structural* learner that keeps such sets coherent must drop a classical schema *globally*, e.g. become atomically paraconsistent everywhere. And "ANDing the whole framework", as the user observed, yields a conjunction of probability 0, on which nothing can be conditioned. ∎

The way out is the user's own suggestion made formal: **meta-level eternalism**. `ist(c, φ)` is a context-free proposition about a finitely specified context. By Thm 2.1, it is necessarily *non-truth-functional* in the world's facts, because it depends on the deformation family.

### 2.2 The right constraint: realizability (frame-free criterion; frame-semantics refinement)

**Definition 2.3.**
* A **judgment set** $J$ is a finite set of triples $(c,\Gamma,\varphi)$ over a context tree. Here SUP contexts have only SUP descendants (no idealization inside a supposition; see Remark (iii)). A set $C$ of DEF contexts is **certified**, i.e. claimed well-posed.
* A **bridge use** is $(c,\beta,t)\in U$ with $c$ DEF, together with the judgments $(c,\emptyset,\phi_\beta(t))$, $(\pi c,\emptyset,\sigma_\beta)$, $(\pi c,\emptyset,\varepsilon_\beta(t))$ in $J$.
* β is a **value-export** bridge for a term $Q$ if:
  * $\phi_\beta(v)$ is "$Q=\bar v$" for $v$ in a value set $V$ with standard names (distinct names denote distinct values in every structure);
  * the side condition $\sigma_\beta$ does not depend on $v$.
* β is **informative** if $\{\sigma_\beta\}\cup\{\varepsilon_\beta(v):v\in V_0\}$ has no model for some *finite* $V_0\subseteq V$. An interval export "$Q_p\in[v-\epsilon,v+\epsilon]$" over unbounded $V$ is informative: two values more than $2\epsilon$ apart suffice.
* *(Added after verification.)* Throughout §2.2, "structure", "model" and "satisfiable" refer to one fixed class 𝒦 of $L$-structures. In the frame semantics 𝒦 is the class of structures with the standard real sort (Def 1.1). Compactness can fail for that class: $\{Q\neq v:v\in\mathbb R\}$ is finitely satisfiable but has no model. So informativeness is *defined* in finite form, rather than derived by compactness as in an earlier version, and the anchoring arguments below never invoke compactness.
* A **realization** assigns to each context a set $M_c$ of structures such that:
  * (R0) $M_@\neq\emptyset$;
  * (R1) $M_c=M_{\pi c}\cap\|A_c\|$ for SUP;
  * (R2) $M_c$ is arbitrary, possibly empty, for DEF;
  * (R3) each judgment holds, i.e. $\forall N\in M_c\,(N\models\bigwedge\Gamma\Rightarrow N\models\varphi)$;
  * (R4) each used bridge is sound: $\forall v\,[M_c\models\phi_\beta(v)\Rightarrow M_{\pi c}\models\sigma_\beta\to\varepsilon_\beta(v)]$;
  * (R5) $M_c\ne\emptyset$ for $c\in C$.

  *(Revised after verification.)* Realizations in this sense are **frame-free**. By (R2), a DEF context's value is unconstrained by its parent, so two things that are automatic in Def 1.3 are not enforced:
  * the rigidity of undeformed parameters across contexts;
  * the identity of identically declared sibling contexts.

  Everything in Thm 2.4(a) holds verbatim for *frame-free filter realizations*: each DEF context gets an arbitrary filter, "nonempty" is read as "proper", and the anchoring lemma uses the finite unsatisfiable subset $\{\sigma_\beta\}\cup\{\varepsilon_\beta(v):v\in V_0\}$. An earlier version said it held "verbatim for filter realizations (Def 1.3)"; that is false. Realizability in the frame semantics of Def 1.3 is treated in Thm 2.4(b),(c) and Prop 2.7.
* The **SUP-collapse** $J^*$ replaces each $(c,\Gamma,\varphi)$ with $c$ SUP by $(b,\Gamma\cup\mathrm{Asm}(c),\varphi)$, where $b$ is the nearest non-SUP ancestor and $\mathrm{Asm}(c)$ the suppositions on the path.
* The **anchored set** Anc is the least set of non-SUP contexts that contains $@$ and $C$ and contains $c$ whenever $(c,\beta,t)\in U$, β is informative, and $\pi c\in$ Anc.

**Theorem 2.4 (realizability criterion) [proved; brute-force checked] (revised after verification: (a) is the original statement, now explicitly frame-free; (b) and (c) are added).** Suppose every used bridge is an informative value-export bridge. Write $\mathrm{Th}^*(c):=\{\bigwedge\Gamma\to\varphi:(c,\Gamma,\varphi)\in J^*\}$.
* (a) *Frame-free realizability.* $J$ is realizable in the sense of (R0)–(R5) iff $\mathrm{Th}^*(c)$ is satisfiable for every $c\in$ Anc.
* (b) *Necessity in the frame semantics.* Call $J$ **frame-realizable** if there is a world $w=(\mathfrak M_w,\lambda^*_w)$ such that, with the filters of Def 1.3:
  * every judgment holds ($c\models_w\bigwedge\Gamma\to\varphi$);
  * every $c\in C$ is proper at $w$;
  * every bridge use is sound at $w$: $\forall v\,[c\models_w\phi_\beta(v)\Rightarrow\pi c\models_w\sigma_\beta\to\varepsilon_\beta(v)]$.

  If $J$ is frame-realizable, then the criterion of (a) holds. The paths may be limit or germ.
* (c) *Non-sufficiency in the frame semantics.* The converse of (b) fails. Here are two counterexamples, both under limit semantics.
  * *CE1, a silent change of an undeformed parameter.* Root @ and a certified DEF child $c$ deforming $D=\{2\}$ toward 0, with $J=\{(@,\emptyset,p_1=1),(c,\emptyset,p_1=0)\}$ and $C=\{c\}$.
    * Anc $=\{@,c\}$, and both $\{p_1=1\}$ and $\{p_1=0\}$ are satisfiable.
    * Under Def 1.3, however, $\mathcal F_c$ is principal at $\lambda^*[2:=0]$ (proper by certification), whose first coordinate is $\lambda^*_1=1$. So $c\models p_1=1$, and $c\not\models p_1=0$.
  * *CE2, identically declared siblings.* Two certified DEF children with the same $(D,\lambda^\circ,\mathcal G)$ have equal filters under Def 1.3. With judgments $Q=1$ in one and $Q=2$ in the other, the criterion holds but $J$ is not frame-realizable.

  CE1 is exactly the "free stipulation" attack of Thm 3.9(b). The frame-free coherence signal therefore cannot see it. In the checker it is excluded by the declaration discipline instead (canonical stipulations, D-stable imports, schema indexing; Def 5.2 as revised). Prop 2.7 gives the exact frame criterion under limit semantics.

*Proof of (a).* Two preliminary observations.
* By (R1) and induction along SUP chains, $M_c=M_b\cap\bigcap_{A\in\mathrm{Asm}(c)}\|A\|$. Hence $(c,\Gamma,\varphi)$ holds at $M_c$ iff $(b,\Gamma\cup\mathrm{Asm}(c),\varphi)$ holds at $M_b$. So $J$ and $J^*$ impose the same constraints on the non-SUP contexts.
* **Anchoring lemma.** In any realization, $M_c\neq\emptyset$ for every $c\in$ Anc. Induct on the closure:
  * $@$ by (R0), and $C$ by (R5).
  * If $c$ enters via an informative $(c,\beta,t)$ with $M_{\pi c}\ne\emptyset$, and $M_c=\emptyset$, then $M_c\models\phi_\beta(v)$ for *every* $v$. By (R4), $M_{\pi c}\models\sigma_\beta\to\varepsilon_\beta(v)$ for all $v$. By (R3) at $\pi c$, $M_{\pi c}\models\sigma_\beta$. So any $N\in M_{\pi c}$ is a model of $\{\sigma_\beta\}\cup\{\varepsilon_\beta(v)\}_{v\in V_0}$, contradicting informativeness.

(⇒) For $c\in$ Anc, any $N\in M_c\neq\emptyset$ satisfies $\mathrm{Th}^*(c)$, by the first observation.

(⇐) Choose a model $N_c\models\mathrm{Th}^*(c)$ for each $c\in$ Anc and set $M_c=\{N_c\}$. Set $M_c=\emptyset$ for non-anchored DEF contexts, and define SUP contexts by (R1). Check each condition:
* (R0) and (R5) hold since $@\in$ Anc and $C\subseteq$ Anc.
* (R3) holds at anchored contexts by the choice of $N_c$ and the first observation. It holds vacuously elsewhere.
* (R4), for a use $(c,\beta,t)$:
  * If $\pi c\notin$ Anc, then $M_{\pi c}=\emptyset$ and (R4) is vacuous.
  * If $\pi c\in$ Anc, then $c\in$ Anc by closure (β is informative). Since "$Q=\bar t$" $\in\mathrm{Th}^*(c)$, we have $Q^{N_c}=t$, so by standard names $M_c\models\phi_\beta(v)$ only for $v=t$. Finally $M_{\pi c}=\{N_{\pi c}\}\models\varepsilon_\beta(t)$, because $(\pi c,\emptyset,\varepsilon_\beta(t))\in J$. ∎

*Proof of (b).* Fix a frame realization at $w$.
* *Filter anchoring lemma.* Every $c\in$ Anc is proper at $w$. The root is proper (Def 1.3), and $C$ is proper by assumption. Suppose $c$ enters via an informative use $(c,\beta,t)$ with $\pi c$ proper, and suppose $c$ is improper. Then:
  * $c\models\phi_\beta(v)$ for every $v$;
  * by bridge soundness $\pi c\models\sigma_\beta\to\varepsilon_\beta(v)$ for all $v$, and $\pi c\models\sigma_\beta$ because $(\pi c,\emptyset,\sigma_\beta)\in J$;
  * so $\pi c\models\varepsilon_\beta(v)$ for all $v$;
  * by informativeness some finite $\{\sigma_\beta,\varepsilon_\beta(v_1),\dots,\varepsilon_\beta(v_k)\}$ has no model in 𝒦, in particular none among the frame's structures. The truth set of its conjunction is then $\emptyset\in\mathcal F_{\pi c}$, contradicting properness.
* For $c\in$ Anc, iterating Prop 1.5 shows that $(c',\Gamma,\varphi)$ with $c'$ a SUP descendant of $c$ holds iff $c\models\bigwedge\mathrm{Asm}(c')\wedge\bigwedge\Gamma\to\varphi$. So $\mathrm{Th}^*(c)\subseteq\mathrm{Th}_w(c)$. Since $\mathrm{Th}^*(c)$ is finite, the intersection of its truth sets is in $\mathcal F_c(w)$, hence nonempty, and any point λ in it gives a model $\mathfrak M_w(\lambda)\in$ 𝒦. No compactness is needed. ∎

*Proof of (c).* Both counterexamples are verified above. They are also brute-forced over all frames on a toy $\Lambda=\{0,1\}^2$ in `realizability_frame.py`: criterion true, frame-realizable false in both cases. ∎

*Checks [computed].*
* `realizability.py`: three contexts, valuations of $(p,Q)$, and all $64^2\times6$ candidate realizations, on 1,500 random instances: 621 realizable, **0 mismatches**.
* `realizability_sup.py` adds a SUP context: 3,000 instances, 1,767 realizable, **0 mismatches** with the collapsed criterion.
* `realizability_deep.py` was written by a referee during verification and added here. It covers up to 3 nested or sibling DEF contexts, SUP under DEF, 0–2 bridge uses per context, interval exports, informativeness that holds only through σ, and arbitrary nonempty root sets. Result: 2,000 instances, 746 realizable, **0 mismatches**. The referee reports a further 10,000 with 0 mismatches.
* `realizability_uninformative.py`: with uninformative bridges, "$Q\in[a-1,a+1]$" on $Q\in\{0,1,2\}$, the anchored criterion is wrong on **117/600** instances. So the hypothesis is needed.
* `realizability_frame.py` brute-forces frame realizability (b),(c): 8,000 random instances (seeds 7 and 8), 2,734 frame-realizable, **0 violations of (b)**, and 598 instances where the criterion holds but $J$ is not frame-realizable.

**Corollaries [proved] (revised after verification).**
* (i) *Reductio immunity.* A SUP context that derives ⊥ contributes exactly $\neg\bigwedge\mathrm{Asm}$ to its base, by the SUP-collapse or Prop 1.5 in both the frame-free and the frame semantics. It creates incoherence only if the base already commits to the suppositions, and that is a genuine incoherence of the base.
* (ii) *Well-posedness exactly where it matters.* Take an idealized context that derives ⊥.
  * In the frame-free sense it is incoherent iff it is anchored, i.e. certified, or exporting informatively into an anchored context. This is L7's Prop 2 ("ill-posed idealizations must not export"), now an iff.
  * In the frame semantics the "if" direction holds by (b).
  * The "only if" direction can fail when the frame forces the context to be proper. For example, the context may deform a parameter to the value the root already assigns it, so that its point coincides with the root's (closure rule (iii) of Prop 2.7).
* (iii) *Eternalism is strictly stronger than frame-free realizability.* Take eternalism in the sense of Cor 2.2: satisfiability of the context-stripped set, without SUP-collapse.
  * If $N$ satisfies the stripped set, then $M_c=\{N\}$ on non-SUP contexts, with SUP contexts defined by (R1), is a realization. For (R4), $M_c\models\phi_\beta(v)$ only for $v=Q^N=t$, and $N\models\varepsilon_\beta(t)$.
  * The converse fails: Cor 2.2(i)–(iii) give realizable sets that eternalism flags.
  * The collapsed variant (satisfiability of the union of all $\mathrm{Th}^*(c)$) is also strictly stronger, witnessed by Cor 2.2(ii)–(iii). It does not flag sound reductios, which contribute only $\neg\bigwedge\mathrm{Asm}$.

*Remarks.*
* (i) *(Revised after verification.)* The frame-free criterion is local: each anchored context is checked separately, with no adjunction across contexts. This locality is a *consequence of (R2)*, which leaves DEF contexts unconstrained by their parents. It is not a theorem about the frame semantics. An earlier version claimed it was "obtained as a theorem rather than imposed", and that was an overclaim.
  * In the frame semantics, rigid undeformed parameters and the shared filters of identically declared contexts force cross-context constraints (Prop 2.7).
  * Even there, under limit semantics, only contexts *at the same parameter point* are conjoined. Contexts at different points interact only through the shared actual values.
  * That restricted, point-wise adjunction is the structural core of discussive and preservationist logics (L7 §3.2).
* (ii) The restriction to value-exports is what makes singleton realizations work. For exports of sets of claims, the criterion becomes "anchored contexts consistent *with the export pattern*", which I have not characterized.
* (iii) Idealizations inside suppositions ("suppose the string breaks; then model the bob as free") make anchoring depend on whether the supposition is consistent. That case is open (§7).

**Proposition 2.7 (frame realizability under limit semantics) [proved; brute-force checked] (added after verification; numbered 2.7 so that earlier numbers stay stable).** Assume the following:
* every DEF context in $J$ uses limit semantics ($\mathcal G$ principal at $\lambda^\circ$);
* every used bridge is an informative value-export bridge;
* SUP contexts have only SUP descendants (Def 2.3).

Define the **points** of the non-SUP contexts from a candidate actual point λ: $\lambda_@=\lambda$ and $\lambda_c=\lambda_{\pi c}[D_c:=\lambda^\circ_c]$. Let $S(\lambda)$ be the least set of non-SUP contexts that contains @ and $C$ and is closed under three rules:
* (i) *parents*: $c\in S\Rightarrow\pi c\in S$;
* (ii) *informative bridges*: $(c,\beta,t)\in U$ and $\pi c\in S$ $\Rightarrow c\in S$;
* (iii) *coincidence*: $\pi c\in S$ and $\lambda_c=\lambda_{c'}$ for some $c'\in S$ $\Rightarrow c\in S$.

Then $J$ is frame-realizable iff there is $\lambda\in\Lambda$ such that, for every point $x\in\{\lambda_c:c\in S(\lambda)\}$:
* $x\in\Lambda$;
* $\bigcup\{\mathrm{Th}^*(c):c\in S(\lambda),\ \lambda_c=x\}$ has a model $N\in$ 𝒦 (standard real sort) with $p_i^N=x_i$ for all $i$.

*Proof.* Under limit semantics every non-SUP context's filter is either improper or principal at its point. This follows by induction. $\mathcal F_@$ is principal at $\lambda^*$. If $\mathcal F_{\pi c}$ is principal at $\lambda_{\pi c}$, then $\mathcal F_c$ is generated by $\{\lambda_c\}\cap\mathrm{dom}$. If $\mathcal F_{\pi c}$ is improper, so is $\mathcal F_c$. A SUP context below a principal base at $x$ is principal at $x$ or improper, and its judgments collapse into the base (Prop 1.5).

(⇒) Let $(\mathfrak M,\lambda^*)$ be a frame realization, and let $P$ be the set of proper non-SUP contexts.
* $P$ contains @ and $C$.
* $P$ is closed under (i), since an improper parent gives an improper child.
* $P$ is closed under (ii), by the filter anchoring lemma in the proof of Thm 2.4(b).
* $P$ is closed under (iii): if $\pi c\in P$ and $\lambda_c=\lambda_{c'}$ with $c'\in P$, then $\lambda_c\in\mathrm{dom}$, so $c$ is proper.

Hence $S(\lambda^*)\subseteq P$. For each point $x=\lambda_c$ with $c\in S(\lambda^*)$ we have $x\in\mathrm{dom}\subseteq\Lambda$. Every $c'\in S(\lambda^*)$ at $x$ is principal at $x$, so $N=\mathfrak M(x)$ satisfies their collapsed theories, and $p_i^N=x_i$.

(⇐) Fix such a λ, put $S=S(\lambda)$, $\lambda^*=\lambda$ and $\mathrm{dom}=\{\lambda_c:c\in S\}$, and let $\mathfrak M(x)$ be the given model at $x$.
* *Contexts in $S$ are proper.* All their ancestors are in $S$ by (i), and all the ancestors' points are in dom. So each $c\in S$ is principal at $\lambda_c$.
* *Non-SUP contexts outside $S$ are improper.* If $\pi c\notin S$, this follows by induction. If $\pi c\in S$, then (iii) gives $\lambda_c\notin\mathrm{dom}$.
* *Judgments* hold: at proper contexts by the choice of $\mathfrak M(\lambda_c)$ and the collapse, at improper ones vacuously.
* *Certified contexts* are in $S$, hence proper.
* *Bridge uses.* If $\pi c$ is improper, soundness is vacuous. Otherwise $\pi c\in S$, so $c\in S$ by (ii). Then $c$ is principal at $\lambda_c$, so $c\models Q=v$ only for $v=t$ by standard names, and $\pi c\models\varepsilon_\beta(t)$ because $(\pi c,\emptyset,\varepsilon_\beta(t))\in J$. ∎

*Reading.* The exact frame criterion is **non-local** in two ways.
* It quantifies over the actual parameter values.
* It conjoins the theories of all forced-proper contexts that sit at the same parameter point.

CE1 fails it because $c$'s point shares $p_1$ with the root. CE2 fails it because the two siblings share a point. *Check [computed]:* `realizability_frame.py` compares the criterion with brute-force frame realizability over all frames on $\Lambda=\{0,1\}^2$, with up to 3 DEF and 2 SUP contexts and 0–2 bridge uses per context: 8,000 instances, **0 mismatches**. Germ semantics is open (§7.3).

### 2.3 The calculus, soundness and blame localization

The rules, adapted from L7 §8.1, are given below. *(Revised after verification: the canonical form of DEF axioms, the name $\mathrm{Imp}_c$ for the import set (formerly $F_c$, which clashed with the filter), σ_β without argument as in Def 2.3, and the well-posedness premise of (Exp).)*
* **(Ax)** $c\Vdash\varphi$ for $\varphi\in\mathrm{Ax}(c)$:
  * $\mathrm{Ax}(@)=\mathrm{Ax}_\rho$;
  * $\mathrm{Ax}(\mathrm{SUP}(A))=\{A\}$;
  * $\mathrm{Ax}(\mathrm{DEF}(D,\lambda^\circ,\mathcal G))$ is the **canonical stipulations generated by the declaration**. Under limit semantics these are "$p_i=\lambda^\circ_i$" for $i\in D$. Under germ semantics they are "$p_D\in U$" for definable $U\in\mathcal G$ (e.g. "$k\le\eta$").

    These are $\mathcal F_c$-true at every $w$, since every generating set $\delta(F\times G)\cap\mathrm{dom}$ with $G\subseteq U$ lies inside their truth set. Stipulations about undeclared parameters are *not* axioms (cf. Thm 3.9(b)).
* **(Step)** From $c\Vdash\varphi_1..\varphi_k$ and an instance $\varphi_1..\varphi_k/\psi$ of $\hat R$, infer $c\Vdash\psi$.
* **(Imp)** From $\pi c\Vdash\varphi$ with $\varphi\in \mathrm{Imp}_c$ (the declared import set of $c$), infer $c\Vdash\varphi$.
* **(Dis)** For SUP: from $c\Vdash\psi$, infer $\pi c\Vdash A\to\psi$.
* **(Exp)** For DEF: from $c\Vdash\phi_\beta(t)$, $\pi c\Vdash\sigma_\beta$ and $\pi c\Vdash\omega_c$, infer $\pi c\Vdash\varepsilon_\beta(t)$. Here $\omega_c$ is the **well-posedness certificate** of $c$: a sentence such that, at every $\lambda\in\|\omega_c\|$, the deformed models exist for 𝒢-almost all μ (Thm 3.9(c)).

An instance is **sound** if it preserves truth at every $w\in W$:
* Step: $c\models_w\bigwedge\varphi_i\to\psi$. This is *context-relative* validity. Time reversal, for example, is sound in a drag-free DEF context and unsound at the root.
* Imp: $\pi c\models_w\varphi\Rightarrow c\models_w\varphi$.
* Exp: $c\models_w\phi_\beta(t)$, $\pi c\models_w\sigma_\beta$ and $\pi c\models_w\omega_c$ imply $\pi c\models_w\varepsilon_\beta(t)$.

**Theorem 2.5 (soundness) [proved].** If every Ax judgment is true and every Step, Imp and Exp instance in a derivation of $c\Vdash\varphi$ is sound, then $c\models_w\varphi$ for all $w\in W$.

*Proof.* Induct on the derivation.
* (Ax) and (Step) hold by hypothesis and filter closure (Prop 1.4a).
* (Imp) and (Exp) hold by soundness of the instance.
* (Dis) holds by Prop 1.5. ∎

**Corollary 2.6 (blame localization) [proved] (revised after verification: designation and the propagation bullet made precise).** Assume the reading is non-vacuous ($W\neq\emptyset$). By Def 1.3 the root is then proper at every $w\in W$.

A context is **designated** if it is either of the following:
* the root;
* a certified DEF context $d$ whose certificate is a *properness witness*, i.e. it shows that $\mathcal F_d(w)$ is proper for some $w\in W$.

A model of the imported fragment, as in Thm 1.9(d), is a different object and does not by itself witness properness. A parent-derived well-posedness certificate $\omega_d$ does witness it, at every $w$ where $\pi d$ is proper and $\omega_d$'s derivation is sound. The reason: if $\pi d\models\omega_d$ and $\pi d$ is proper, then for every $F\in\mathcal F_{\pi d}$ and $G\in\mathcal G$, pick $\lambda\in F\cap\|\omega_d\|$; then $\{\mu:\delta(\lambda,\mu)\in\mathrm{dom}\}\cap G\neq\emptyset$, so $\mathcal F_d$ is proper.

Suppose $d\Vdash\bot$ is derived by $D$ for a designated $d$. Then the **cone** of $D$ contains an unsound Step, Imp or Exp instance, or a false Ax. The cone is the set of all instances in the derivation tree of $D$, including those inside sub-contexts whose conclusions reach $d$ by Dis or Exp.
* Instances outside the cone are never implicated. In particular, a SUP ⊥ that is not discharged into $D$ is never implicated, and neither is any pair of contradictory `ist`-claims.
* *Propagation (needs extra hypotheses).* Suppose $c\Vdash\bot$ is derived in a DEF context $c$ with an informative bridge use $(c,\beta,t)$, and $\pi c\Vdash\sigma_\beta$ and $\pi c\Vdash\omega_c$ are derived. Suppose also that $\hat R$ contains ex falso (⊥/ψ), and that the parent's kernel is refutation-complete for finite sets (it derives ⊥ from any finite unsatisfiable set). Then:
  * informativeness gives $t_1..t_k$ with $\{\sigma_\beta,\varepsilon_\beta(t_1),\dots,\varepsilon_\beta(t_k)\}$ unsatisfiable;
  * ex falso gives $c\Vdash\phi_\beta(t_i)$;
  * $k$ new, *synthetic* Exp instances give $\pi c\Vdash\varepsilon_\beta(t_i)$;
  * refutation completeness gives $\pi c\Vdash\bot$.

  Iterating along the anchoring chain reaches a designated context, so $c$'s ⊥ lies in the cone of a designated contradiction. *Where the blame falls:* if $c$ is proper at the relevant world, some step of $c$'s own derivation is unsound. If $c$ is improper there, all of $c$'s own steps are vacuously sound, and the unsound items are in the derivation of $\omega_c$, since a sound $\omega_c$ makes $c$ proper wherever $\pi c$ is. Without the certificate requirement, the unsound items are among the synthetic Exp($t_i$) instances, i.e. the bridge applied to an ill-posed context.

*Proof.* The main claim is the contrapositive of Thm 2.5 at a world where $d$ is proper, since ⊥ is true nowhere. The propagation claim is the computation in the last bullet, applied link by link. ∎

The cone is a **negative bag** in the sense of T2 (Lemma 2.1 there), with Cor 2.6 playing the role of T2's Lemma 2.1. This requires reading T2's step hypotheses as sets of *context-indexed items*, not context-free steps: (context, Step instance), (context, Imp instance), (context, Exp instance) and Ax judgments. T2's halving argument uses only that the target never contains a whole detected bag, so its bounds apply unchanged to such item sets. With the root and the certified contexts as the *only* designated contexts, T2's oligarchic-halving learner gets at most $\log_2(1/w(h^*))$ detections (T2 Thm 2.2), with no false alarms as long as the reading is correct. T2 Thm 2.5 prices any false alarms caused by a wrong reading.

What root coherence cannot see is silent unsoundness: exports that are false but consistent with everything else (T2 Thm 2.6, and §4 below).

---

## 3. Export: what can justify leaving a context

### 3.1 No free export, in full rigour

Fix a one-parameter deformation (the multi-parameter case is identical) with ideal value $\lambda^\circ=0$ and actual value $\lambda^*\in(0,\Lambda]$. A family is represented by its query function $Q:[0,\Lambda]\to\mathbb R$, and a **family class** is a set $\mathcal C$ of such functions.
* An **information map** $I$ sends $Q$ to what the export rule may use. Examples: the jet $(Q^{(j)}(0))_{j\ge0}$; the germ at 0; the restriction $Q|_S$; finitely many values.
* An **export rule** $E$ maps $(I(Q),\lambda^*)$ to "abstain" or to a finite interval $[q-\epsilon,q+\epsilon]$.
* $E$ is **sound on $\mathcal C$** if $Q(\lambda^*)\in E(I(Q),\lambda^*)$ whenever it does not abstain.

**Lemma 3.2 (invisible perturbation) [proved].** Suppose there is a function $f$ with $f(\lambda^*)\neq0$ such that, for every $Q\in\mathcal C$ and every $A\in\mathbb R$, $Q+Af\in\mathcal C$ and $I(Q+Af)=I(Q)$. Then every export rule sound on $\mathcal C$ abstains at $\lambda^*$ on every $Q\in\mathcal C$.

*Proof.* If $E$ outputs $[q-\epsilon,q+\epsilon]$ on $I(Q)$, it outputs the same on $I(Q+Af)$ for all $A$. Soundness would need $Q(\lambda^*)+Af(\lambda^*)\in[q-\epsilon,q+\epsilon]$ for all $A$, which is impossible. ∎

**Theorem 3.3 (no free export) [proved] (revised after verification: closure hypothesis corrected).** Every rule sound on the stated class abstains at every $\lambda^*>0$, on every $Q\in\mathcal C$, in each of the following cases:
* (a) $\mathcal C+C^\infty[0,\Lambda]\subseteq\mathcal C$ ($\mathcal C$ is closed under adding smooth functions) and $I$ is the full jet at 0. Use the flat function $f(\lambda)=e^{-1/\lambda^2}$.
* (b) $\mathcal C+C^\infty\subseteq\mathcal C$ and $I$ is the germ at 0, or more generally $Q|_S$ for any $S$ whose closure omits $\lambda^*$. Use a $C^\infty$ bump supported in a neighbourhood of $\lambda^*$ disjoint from $S$, with $f(\lambda^*)=1$.
* (c) $\mathcal C$ is the class of restrictions of entire functions (closed under adding polynomials) and $I$ is the jet up to any finite order $N$. Use $f(\lambda)=\lambda^{N+1}$.
* (d) $\mathcal C+C^\infty\subseteq\mathcal C$ and $I$ is any finite set of values $Q(\lambda_1),\dots,Q(\lambda_m)$ with $\lambda^*\notin\{\lambda_j\}$. Use a bump at $\lambda^*$ vanishing at the $\lambda_j$. This is the special case of (b) with $S$ finite.

If only $\mathcal C\supseteq C^\infty$ is assumed in (a), (b) or (d), the conclusion holds for every $Q\in C^\infty$. A rule sound on $\mathcal C$ is sound on $C^\infty$, which satisfies the closure hypothesis. But the conclusion can fail for $Q\in\mathcal C\setminus C^\infty$. Take $\mathcal C=C^\infty\cup\{\sqrt\lambda\}$ with $I$ the germ at 0, and let the rule output $\sqrt{\lambda^*}$ exactly when shown the germ of $\sqrt\lambda$, abstaining otherwise. It is sound on $\mathcal C$, because no smooth function has that germ, and it does not abstain on $\sqrt\lambda$.

*Proof.* In each case $f$ meets Lemma 3.2's hypotheses:
* $Af\in C^\infty$ (respectively a polynomial), so $Q+Af\in\mathcal C$ by the closure hypothesis;
* $e^{-1/\lambda^2}$ (extended by 0) has all derivatives 0 at 0;
* bumps vanish near the information set;
* $\lambda^{N+1}$ has vanishing $N$-jet. ∎

*Remarks.*
* (i) For analytic families, the **full** jet *does* determine $Q(\lambda^*)$ by the identity theorem. But no rule that reads finitely many coefficients is sound, by (c). Sound use of a series needs a *remainder bound*, e.g. a Cauchy bound $|Q|\le B$ on a complex disc of radius $R>\lambda^*$, which gives tail $\le B(\lambda^*/R)^{N+1}/(1-\lambda^*/R)$. That bound is information about the family *away from* 0. This is the formal content of "a formal power series without a remainder bound is an uncontrolled approximation" (L7 Prop 3), and a theorem-shaped vindication of McMullin's and Laymon's demand for de-idealization information.
* (ii) Case (d) is the learning-theoretic face of the same fact (Thm 4.4): finitely many simulations certify nothing between them without a regularity assumption.

**Proposition 3.4 (minimax export = radius of information) [proved; standard in information-based complexity, Traub–Wasilkowski–Woźniakowski 1988 [cited]].** For an information value $i$, let $\mathcal C_i=\{Q\in\mathcal C:I(Q)=i\}$ and $r(i)=\tfrac12\big(\sup_{\mathcal C_i}Q(\lambda^*)-\inf_{\mathcal C_i}Q(\lambda^*)\big)$.
* A sound rule with tolerance $\epsilon$ at $i$ exists iff $r(i)\le\epsilon$, with the infimum attained when finite.
* The optimal rule outputs the midrange.

*Proof.* Any sound interval must contain $\{Q(\lambda^*):Q\in\mathcal C_i\}$; conversely the midrange interval of radius $r(i)$ does. ∎

So an **export certificate** *is* information of small radius. Every entry in L7's taxonomy E1–E10 is a way of obtaining such information:
* a uniform derivative bound;
* a Gronwall bound;
* an invariance that pins $Q$;
* a monotone sandwich between the ideal and a computed less-ideal value (Laymon);
* data near $\lambda^*$.

### 3.2 Positive export theorems

**Theorem 3.5 (certified-neighbourhood and rate-qualified export) [proved; TOSU].**
* (a) Suppose the parent proves $\lambda^*\in U$ (from data or measurement intervals), and a theorem of the frame gives $\sup_{\lambda\in U}|Q(\mathfrak M(\lambda))-q|\le\epsilon$. Then the parent may assert $Q\in[q-\epsilon,q+\epsilon]$, soundly.
* (b) A germ claim "$Q\sim q$ along $\mathcal G$" ($Q/q\to1$) exports nothing at a fixed $\lambda^*$ (Thm 3.3b). With a rate, "$|Q/q-1|\le C\|\lambda\|^k$ on $U$", it exports $|Q/q-1|\le C\sup_U\|\lambda\|^k$.
* (c) *Germ roots.* If the problem itself declares a regime ("$S_t\ll S_b$, valid until the end"; L9 provenance P2), the root is a germ context. Asymptotic equivalence is then *the correctness relation itself*, and no export is needed. For exp-log expressions in one parameter it is decidable modulo constant zero-equivalence (Gruntz's algorithm; L9 TC4 [cited]).

*Proof.* (a) is immediate from the semantics at $\lambda^*\in U$. (b) is (a) applied to the stated rate, and Thm 3.3(b) for the negative half. (c): the root filter is the declared germ, so $Q\sim q$ is a root claim. ∎

Part (a) fixes the *logical form* of every side condition: a parent-certified set $U$ plus a uniform bound over $U$. Here is how it handles IPhO 2025 T2 C.3 (L9 §8.3). The official premise "X is a few cm" is false, since $X^*\approx0.94$ mm. The checker should demand the *robust* form "for all $X$ in the apparatus range, the switching time $\sqrt{M_{\rm eff}/k}\lesssim0.1$ s $\ll\tau_1\approx6\times10^5$ s". That is a side condition over a certified set, not at a guessed point.

**Theorem 3.6 (Gronwall finite-horizon export) [proved; standard (Gronwall 1919 [cited])] (revised after verification: checkable tube form (b) added).** Let $\dot x=f(x)$ (idealized) and $\dot y=f(y)+g(t,y)$ (de-idealized) have solutions $x,y$ on $[0,T]$, and let $L>0$. Write $B(t)=|x_0-y_0|e^{Lt}+\frac\eta L(e^{Lt}-1)$.
* (a) Suppose $f$ is $L$-Lipschitz *on a set* $K$ containing both trajectories, i.e. $|f(z)-f(z')|\le L|z-z'|$ for $z,z'\in K$; a derivative bound on a non-convex set is not enough. Suppose also $|g(t,y(t))|\le\eta$. Then $|x(t)-y(t)|\le B(t)$.
* (b) *Checkable form.* Let $K_r=\{z:\mathrm{dist}(z,x([0,T]))\le r\}$ be the tube of radius $r$ around the idealized trajectory. Suppose:
  * $f$ is $L$-Lipschitz on $K_r$;
  * $|g(t,z)|\le\eta$ for $t\in[0,T]$ and $z\in K_r$;
  * $B(T)<r$.

  Then $y$ stays in $K_r$ on $[0,T]$ and the bound of (a) holds. Every hypothesis of (b) concerns the computed idealized trajectory and bounds on $f$ and $g$ over an explicit set, so the parent can certify all of them. The hypotheses of (a), by contrast, are claims about the unknown de-idealized trajectory. The existence of $y$ on $[0,T]$ is the root model's well-posedness.

*Proof.*
* (a) Let $u=|x-y|$. Then $u(t)\le u(0)+\int_0^t(Lu+\eta)$. Let $v$ be the right-hand side. Then $v'=Lu+\eta\le Lv+\eta$, so $(e^{-Lt}(v+\eta/L))'\le0$, giving $u\le v\le(u(0)+\eta/L)e^{Lt}-\eta/L$.
* (b) Let $t_1=\sup\{t\in[0,T]:|x(s)-y(s)|\le r\text{ for all }s\in[0,t]\}$. The set contains 0 because $|x_0-y_0|\le B(T)<r$, and the sup is attained by continuity.
  * On $[0,t_1]$ both $x(s)$ and $y(s)$ lie in $K_r$. So (a) applies with $K=K_r$ and gives $|x-y|\le B(t)\le B(T)<r$ there.
  * If $t_1<T$, continuity gives $|x-y|<r$ on a neighbourhood of $t_1$, which contradicts the definition of $t_1$. Hence $t_1=T$. ∎

The bound grows with the horizon $T$. So *qualitative* long-time claims ("oscillates forever") from structurally unstable idealizations do not export, while finite-horizon quantitative ones do (L7 E3/E8).

**Theorem 3.7 (rigorous projectile certificate) [proved; checked].** A point mass is launched with speed $v_0$ at angle $\theta\in(0,\pi/2)$ under gravity $g$. The neglected force per unit mass is $a_n=-\kappa(t)\,v$ with $0\le\kappa(t)\le k|v(t)|$. This covers quadratic drag with any $C_d\le C_{d,\max}$ and any *antiparallel* (drag-type) force dominated by it, including time-varying ones. The antiparallel form is needed; a lift force is not covered. Let $x:=kv_0^2/g<1$ and $R_0=v_0^2\sin2\theta/g$. Then the range satisfies
$$R_0\Big[\frac1{1+x}-\frac{x\tan\theta}{(1+x)^2}\Big]\ \le\ R\ \le\ \frac{R_0}{1-x}.$$

*Proof.* Let $T=\inf\{t>0:y(t)=0\}$.
1. *Speed bound.* On $[0,T)$, $y\ge0$ and $\frac{d}{dt}(\frac12|v|^2+gy)=-\kappa|v|^2\le0$. So $|v|\le v_0$ and $|a_n|=\kappa|v|\le kv_0^2=xg$.
2. *Flight time.* $\ddot y\in[-g(1+x),-g(1-x)]$. So $v_{0y}t-\frac12g(1+x)t^2\le y(t)\le v_{0y}t-\frac12g(1-x)t^2$.
   * The upper bound vanishes at $T_{hi}=2v_{0y}/(g(1-x))$. If $T>T_{hi}$ we would have $y(T_{hi})\le0$ with $T_{hi}\in(0,T)$, a contradiction. So $T\le T_{hi}$.
   * The lower bound is positive on $(0,T_{lo})$ with $T_{lo}=2v_{0y}/(g(1+x))$. So $T\ge T_{lo}$.
3. *Horizontal motion.* $\dot v_x=-\kappa v_x$ gives $v_x=v_{0x}e^{-\int\kappa}>0$, so $X$ is increasing. Also $\ddot X\in[-xg,0]$.
   * Hence $R=X(T)\le v_{0x}T\le v_{0x}T_{hi}=R_0/(1-x)$.
   * And $R\ge X(T_{lo})\ge v_{0x}T_{lo}-\frac12xgT_{lo}^2$, which equals the stated lower bound because $R_0=2v_{0x}v_{0y}/g$. ∎

*Numbers [computed, `learn_regions.py`].*
* Steel ball (r = 1 cm, m = 32.7 g, $C_d=0.47$, $v_0=10$ m/s, 45°): $x=0.0276$. Certified $R\in[9.653,10.483]$ m. Simulation gives 9.978 m.
* Ping-pong ball: $x=1.42>1$. The certificate is silent (export blocked); the simulated range is 49% short of $R_0$.
* Random $(x\in[0,0.9],\theta)$: **0/300** violations. A referee's adversarial test with time-varying, bang-bang $\kappa(t)\le k|v|$ found 0/400 violations.
* For a 5% tolerance at 45°, the certificate's validity region is $x\le(1/0.95)^{1/2}-1=0.0260$ (closed form; the binding constraint is the lower bound $1/(1+x)^2$). The simulated true region is $x\le0.0679$, located by root-finding (revised after verification; the earlier 0.0673 was a grid artefact). The certificate is sound but about 2.6× conservative. `projectile.py` now uses the same $(1+x)^2$ bound and reproduces these numbers; an earlier version used the weaker, also valid, $(1-x)^2$ bound.

**Theorem 3.8 (error propagation through chains) [proved; TOSU].**
* (a) *Towers.* For a chain $\lambda^\circ=\lambda^{(0)},\dots,\lambda^{(k)}=\lambda^*$ (one deformation per link) with certified $|Q(\lambda^{(i)})-Q(\lambda^{(i-1)})|\le\delta_i$, we get $|Q(\lambda^*)-Q(\lambda^\circ)|\le\sum\delta_i$.
* (b) *Downstream computation.* Suppose the answer is $F(q_1..q_m)$ from exported $q_j$ with $|Q_j-q_j|\le\delta_j$. Suppose $F$ is differentiable on the box $B=\prod[q_j\pm\delta_j]$ (e.g. $C^1$ on a neighbourhood of it; added after verification), and let $L_j=\sup_B|\partial_jF|$. Then $|F(Q)-F(q)|\le\sum_jL_j\delta_j$.
* (c) *Catastrophe as budget.* If $\sum_jL_j\delta_j\ge|F(q)|$, then not even the sign of $F(Q)$ is certified *by this first-order budget*. For "100 − 99.9" with tolerances 0.2: budget 0.4 > 0.1, and indeed $Q_1-Q_2\in[-0.3,0.5]$. A direct range enclosure can sometimes still certify the sign. For example, $F(q)=q^2$ at $q=1$ with $\delta=0.6$ has budget $1.92\ge1$, yet $F(Q)\in[0.16,2.56]$.

*Proof.* (a) is the triangle inequality. (b) is the mean value theorem along the segment from $q$ to $Q$, which lies in the convex box. (c) follows from (b). ∎

The budget makes the user's "100 = 99.9" catastrophe *visible as a typing error* instead of forbidding it by fiat.

### 3.3 Adversarial stipulation

Take a schema of the form "neglect $p_D$": pattern $Q=\bar v$ in the child; side condition $s(\vec p)\le\eta$ for a dimensionless smallness parameter (e.g. $kv_0^2/g$); conclusion $Q\in[v\pm\epsilon]$ in the parent.

**Theorem 3.9 (where side conditions live, and what contexts may be) [proved] (part (c) revised after verification).**
* (a) *Child-evaluated side conditions are unsound.* Suppose (Exp) accepts $c\Vdash s\le\eta$ in place of $\pi c\Vdash s\le\eta$. Every context with $p_D=0$ satisfies $s=0\le\eta$. The export then fires on any world, including those with $s(\lambda^*)$ huge. On any $C^\infty$-closed class this is unsound for every $\epsilon$ (Thm 3.3b). Concretely: the ping-pong ball receives the drag-free range ±5%, while its true range is 49% short.
* (b) *Free stipulations are unsound even with parent evaluation.* Suppose contexts may stipulate values of *undeclared* parameters. A solver stipulates $p_D=0$ and $g_c=g'$. The parent condition $s(\lambda^*)\le\eta$ is true for the steel ball, and the child's $Q=R_0(g')$ is any desired value. The export is false.
* (c) *Sufficiency* (revised after verification; the well-posedness certificate is now a hypothesis). Suppose:
  * contexts are declared deformations (DEF) whose only axioms are the canonical stipulations of §2.3;
  * the side condition $\sigma_\beta$ (e.g. $s\le\eta$) is derived in the parent;
  * a **well-posedness certificate** $\omega_c$ is derived in the parent. This is a sentence such that, for every $w$ and every $\lambda\in\|\omega_c\|_w$, the deformed models exist for 𝒢-almost all μ: $\{\mu:\lambda[D:=\mu]\in\mathrm{dom}\,\mathfrak M_w\}\in\mathcal G$. For limit semantics this just says $\lambda[D:=\lambda^\circ]\in\mathrm{dom}$. The certificate may be folded into $\sigma_\beta$.
  * the schema is a theorem of the frame. For all $w$, all $\lambda\in\mathrm{dom}$ with $\mathfrak M_w(\lambda)\models\sigma_\beta$ and all $v$: if $\{\mu:\lambda[D:=\mu]\in\mathrm{dom},\ Q(\mathfrak M_w(\lambda[D:=\mu]))=v\}\in\mathcal G$, then $\mathfrak M_w(\lambda)\models\varepsilon_\beta(v)$. Typically $\varepsilon_\beta(v)$ is "$|Q-v|\le\epsilon(v,\vec p)$", where ε may depend on $v$ and on undeformed parameters.

  Then every accepted export is sound, *for every solver*. Theorem 3.7 is such a schema: $\sigma$ is "$x=kv_0^2/g\le\eta$" with $\eta<1$, $\omega$ is ⊤ (drag-free models always exist), and $\epsilon(v,\theta)=v\max\big(\tfrac{\eta}{1-\eta},\ \tfrac{\eta}{1+\eta}+\tfrac{\eta\tan\theta}{(1+\eta)^2}\big)$ is read off its bounds.

  *Without the certificate, (c) is false.* Use the frame of Prop 1.6(b): a rope of mass $m_r$ pulled by $\Phi\ne0$, with $\mathrm{dom}=\{m_r>0\}$, $D=\{m_r\}$ and limit semantics.
  * The child is improper, so $c\models a=0$ by sound steps.
  * The schema "if $m_r\le\eta$ and $a=v$ at the deformed model, then $|a-v|\le\epsilon$" is a theorem, vacuously, since no deformed model exists.
  * The parent proves $m_r\le\eta$.
  * (Exp) would then accept $|a|\le\epsilon$, while the actual $|a|=|\Phi|/m_r\ge|\Phi|/\eta$.

  With the certificate, no sound parent derivation of $\omega_c$ exists, since $\|\omega_c\|$ must be empty. The first version stated (c) without this hypothesis and used it only inside the proof.

*Proof.* (a) and (b) are the constructions. For (c): by Lemma 1.8 and Thm 2.5 it suffices that the instance is sound.
* Suppose $c\models_w Q=\bar v$, $p\models_w\sigma_\beta$ and $p\models_w\omega_c$.
* Then there are $F_1\in\mathcal F_p$ and $G\in\mathcal G$ with $\delta(F_1\times G)\cap\mathrm{dom}\subseteq\|Q=\bar v\|$.
* Let $F=F_1\cap\|\sigma_\beta\|\cap\|\omega_c\|\in\mathcal F_p$, and fix $\lambda\in F$. The set $E_\lambda=\{\mu:\delta(\lambda,\mu)\in\mathrm{dom}\}$ is in 𝒢 because $\lambda\in\|\omega_c\|$. For $\mu\in G\cap E_\lambda$ we have $Q(\mathfrak M_w(\delta(\lambda,\mu)))=v$.
* So the schema's antecedent holds at λ, and the schema gives $\mathfrak M_w(\lambda)\models\varepsilon_\beta(v)$.
* Hence $\|\varepsilon_\beta(v)\|\supseteq F\in\mathcal F_p$. ∎

*Remark (asymptotic patterns).* In germ contexts the natural in-context claim is "$Q\simeq v$", i.e. $c\models|Q-v|<\eta'$ for every rational $\eta'>0$ (in Łoś terms, the standard part of $Q$ is $v$), rather than exact equality. The analogous schema has the hypothesis "$Q(\mathfrak M_w(\lambda[D:=\mu]))\to v$ along 𝒢".
* Its lifting goes through when the parent filter is principal (root or limit-semantics parent), because then every witness set contains the actual point.
* It *also* needs the well-posedness certificate $\omega_c$ (added after verification). An improper child proves $Q\simeq v$ for every $v$.
* Under a nested germ parent it additionally needs the convergence to be uniform on a parent filter set, which is a genuine extra side condition.

The pointwise schema lifts to arbitrary parent filters (the proof of (c) never used that $\mathcal F_p$ is principal). So catalogue theorems need to be proved once per frame and declaration, not per nesting pattern.

A bound that holds at every λ in a parent-certified set needs no child context at all. Prop 6.2 below is an example: it is a theorem about the top model at all λ satisfying its hypotheses. Such a bound enters as a *law* of the frame, used in a root Step (Thm 3.5(a)), and is trusted through the law catalogue.

AUX contexts, i.e. auxiliary models related by *exact* theorems (time reversal, decomposition, the degenerate Kepler ellipse), are definitional extensions. They need a proof, not a deformation declaration.

---

## 4. Learning bridge validity regions

Setting: a bridge schema $s$ has a dimensionless regime parameter $\pi\in\Pi$ and an error function $e_s(\pi)$, the relative difference between the top model and the idealization. The question is how to learn *where* $e_s\le\tau$, soundly against a solver who chooses π.

### 4.1 What coherence can and cannot do

**Theorem 4.1 (coherence cannot calibrate tolerances) [proved].**
* Schemas $s=1..m$ export intervals $[q_{s,i}\pm\epsilon_s]$ for true values $V_i$.
* A **coherence-only calibrator** chooses $\hat\epsilon$ as a function of the discrepancy data $(q_{s,i}-q_{s',i})$.
* Suppose the environment class is closed under **common shifts**: $(q,V)$ admissible implies $(q,V+b)$ admissible for $|b|\le\beta$ (all models may share an omitted effect).

Then any $\hat\epsilon$ that is sound on the class has $\hat\epsilon_s\ge\beta$ for all $s$. If shifts are unbounded, $\hat\epsilon=\infty$.

*Proof.* Environments $(q,V\pm\beta)$ yield identical data, hence identical $\hat\epsilon$. Soundness requires $|V_i\pm\beta-q_{s,i}|\le\hat\epsilon_s$ for both signs, and adding the two inequalities gives $2\beta\le2\hat\epsilon_s$. ∎

**Proposition 4.2 (minimal-repair drift) [proved; TOSU; computed].** The set of tolerance vectors under which a fixed set of exports is coherent is an up-set. So the minimal coherent repair after new data is coordinatewise non-decreasing. A schema whose discrepancy with another is unbounded on the stream gets $\epsilon\to\infty$, and coherence never *restricts its regime*.

*Computed (`learn_regions.py`).* Export $T/T_0$ by the small-angle schema (value 1) and by the exact elliptic one. Feeding amplitudes 20°, 60°, 120°, 170°, 179°, 179.9° drives the small-angle tolerance through 0.0077, 0.073, 0.37, 1.44, 2.9, 4.4, diverging like $\log\frac1{1-k^2}$. Two small-angle-based schemas never disagree, so both export ratio 1 at 120°, where the truth is 1.373 (common mode).

**Theorem 4.3 (split-conformal calibration, and its failure under selection) [proved; cited: Vovk, Gammerman & Shafer 2005; Lei et al. 2018].**
* (a) Suppose $e_1..e_{n+1}$ are exchangeable and $\hat\epsilon$ is the $k$-th smallest of $e_1..e_n$, with $k=\lceil(n+1)(1-\alpha)\rceil$ and the convention $\hat\epsilon=+\infty$ if $k>n$, i.e. if $\alpha<1/(n+1)$. Then $P(e_{n+1}\le\hat\epsilon)\ge1-\alpha$.
* (b) If the solver chooses the instance after $\hat\epsilon$ is fixed, from a regime where $\sup e>\hat\epsilon$, coverage on the chosen instance is 0.

*Proof.*
* (a) Assume no ties (ties only help). The rank of $e_{n+1}$ among the $n+1$ values is uniform. Then $e_{n+1}>\hat\epsilon$ iff its rank exceeds $k=\lceil(n+1)(1-\alpha)\rceil$, which has probability $(n+1-k)/(n+1)\le\alpha$.
* (b) is immediate. ∎

*Computed.* Small-angle schema, calibrated on $\theta_0\sim U[0°,30°]$ with $n=200$ and α = 0.1: $\hat\epsilon=1.44\times10^{-2}$, and coverage 0.913 on fresh exchangeable draws. The adversary's instance 60° has error $7.3\times10^{-2}$ and is not covered.

*Not computed; it follows from (b).* Mondrian (per-regime) calibration narrows the gap but does not close it, because within each bin the adversary still picks the worst point.

### 4.2 Sound certification needs regularity, and regularity suffices

**Theorem 4.4 (no certification without regularity) [proved].** Let $\mathcal C$ be closed under $e\mapsto e+Af$ for every continuous bump $f\ge0$ and every $A>0$. Consider a *deterministic* certifier that makes finitely many oracle queries and outputs a region $V$ with $e\le\tau$ on $V$, soundly on $\mathcal C$. Then $V\subseteq\{\text{queried points}\}$. A randomized certifier that is sound almost surely satisfies the same inclusion almost surely.

*Proof.* Fix $e$ and record its queries. Take a bump $f$ at an unqueried $\pi\in V$ with $f(\pi)=1$, vanishing at the recorded queries.
* On $e$ and $e+Af$ the first answer coincides. By induction the whole adaptive query sequence and the output coincide.
* Soundness on $e+Af$ needs $e(\pi)+A\le\tau$ for all $A>0$, which is impossible.

This is the argument of Lemma 3.2. The lemma does not apply verbatim, because here $f$ depends on $e$. ∎

No free export and no free certification thus rest on *one argument*: the standard adversary argument of information-based complexity. Simulation is an oracle for the top model (L9 TC6), but an oracle without a regularity guarantee certifies only the points it was asked about.

**Theorem 4.5 (conservative Lipschitz certifier: soundness, completeness, sample complexity, lower bound) [proved].**
* Let $\Pi=[0,1]^d$ (after rescaling), and let $e$ be $L$-Lipschitz in $\|\cdot\|_\infty$.
* A *validated oracle* returns $e_{hi}(\pi)\in[e(\pi),e(\pi)+\eta]$, e.g. interval ODE enclosures (Tucker; Immler [cited in L9]).
* Let $G_h$ be the centres of the $\lceil1/h\rceil^d$ cubes of side $\le h$ tiling Π. Output
$$V=\Pi\cap\bigcup_{\pi_j\in G_h}\big\{\pi:\|\pi-\pi_j\|_\infty\le(\tau-e_{hi}(\pi_j))/L\big\}.$$

Then:
* (a) **Soundness.** $e\le\tau$ on $V$, for every $L$-Lipschitz $e$, deterministically. So it holds against any solver choosing π.
* (b) **Completeness.** Let $\gamma>\eta$. If $h\le(\gamma-\eta)/L$, then $V\supseteq\{\pi:e(\pi)\le\tau-\gamma\}$. This takes $N=\lceil L/(\gamma-\eta)\rceil^d$ oracle calls.
* (c) **Lower bound.** Every deterministic certifier that is sound on the $L$-Lipschitz class and complete at margin γ makes at least $\lfloor L/(2\gamma')\rfloor^d$ queries for every $\gamma'>\gamma$, even with an exact oracle.

*Proof.*
* (a) For π in the ball around $\pi_j$: $e(\pi)\le e(\pi_j)+L\|\pi-\pi_j\|\le e_{hi}(\pi_j)+(\tau-e_{hi}(\pi_j))=\tau$.
* (b) Let $e(\pi)\le\tau-\gamma$. Its cell centre satisfies $\|\pi-\pi_j\|_\infty\le h/2$, so $e_{hi}(\pi_j)\le e(\pi)+Lh/2+\eta\le\tau-\gamma+Lh/2+\eta$. The radius is then $(\tau-e_{hi}(\pi_j))/L\ge(\gamma-\eta)/L-h/2\ge h/2$.
* (c) Let $e_0\equiv\tau-\gamma$. Completeness forces $V(e_0)=\Pi$. Put $\rho=\gamma'/L$ and pack $M=\lfloor1/(2\rho)\rfloor^d$ disjoint open $\infty$-balls of radius ρ in Π. With fewer than $M$ queries on $e_0$, some ball $B(\pi_0,\rho)$ is unqueried. Define $e_1=e_0+\max(0,\gamma'-L\|\pi-\pi_0\|_\infty)$. It is $L$-Lipschitz, it equals $e_0$ off the ball, and $e_1(\pi_0)>\tau$. All answers agree, so $V(e_1)=\Pi\ni\pi_0$: unsound. ∎

The upper and lower bounds match up to $2^d$ and the oracle slack η. (Randomized certifiers that are sound with probability $1-\delta$ and complete on $e_0$ surely need $(1-\delta)M$ queries in expectation, by the same construction with $\pi_0$ uniform. If completeness holds only with probability $1-\delta'$, the bound becomes $(1-\delta-\delta')M$.) This is Piyavskii–Shubert-style covering and the standard $\Omega((L/\gamma)^d)$ barrier for Lipschitz problems (Nemirovsky & Yudin 1983 [cited, unverified details]). *Where does $L$ come from?* It must be **proved** in the top model; an estimate makes soundness conditional.
* *Demonstration (flagged).* For the projectile, an $L$ *estimated* from simulations (0.94 including a 1.2 safety factor) certifies $x\in[0,0.066]$ with 16 oracle calls, against the true region $x\le0.0679$. With a proved $L$ this would be a certificate; with the estimate it is only a calibrated guess.

**Theorem 4.6 (monotone certifier) [proved] (revised after verification: query count, lower-bound adversary, reported thresholds).** Let $e$ be non-decreasing on $[0,1]$ (no continuity needed), with a validated upper oracle.
* *Lazy bisection* queries only midpoints. Start with $lo=0$, $hi=1$, neither queried. Query $m=(lo+hi)/2$. If $e_{hi}(m)\le\tau$, set $lo=m$ and mark it accepted; otherwise set $hi=m$. Repeat $k$ times. The output is $V=[0,lo]$ if some query was accepted, and $V=\emptyset$ otherwise. It is sound.
* With an exact oracle, after $k$ queries $V$ misses at most an interval of length $2^{-k}$ of $\{e\le\tau\}$. A variant that first queries both endpoints, to output ∅ or $[0,1]$ early, spends two extra queries and guarantees only $2^{-(k-2)}$. An earlier version stated that variant with the bound $2^{-k}$, which was off by those two queries.
* $\lceil\log_2(1/h)\rceil$ queries are necessary for resolution $h$, i.e. for missing at most length $h$ of $\{e\le\tau\}$ on every non-decreasing $e$, even with an exact oracle.
* In dimension $d\ge2$ (down-sets), $\Theta(h^{1-d})$ queries are needed and suffice [sketch: an antichain of grid cells must each be probed; a staircase walk achieves it].

*Proof.*
* Soundness: if $V=[0,\hat\pi]$ then $e_{hi}(\hat\pi)\le\tau$ was observed, and $e(\pi)\le e(\hat\pi)\le e_{hi}(\hat\pi)\le\tau$ for $\pi\le\hat\pi$.
* Miss bound: $hi-lo$ halves with every query, so it equals $2^{-k}$ at the end.
  * If some query was rejected, the last rejected point is $hi$. Then $e(hi)>\tau$, and by monotonicity $\{e\le\tau\}\subseteq[0,hi)$.
  * If none was rejected, $hi=1$.
  * If $V\neq\emptyset$, the missed part lies in $(lo,hi]$.
  * If $V=\emptyset$, every query was rejected, so $hi=2^{-k}$ and the missed part lies in $[0,hi)$.
* Lower bound, via an explicit adversary (no continuity is assumed). Consider $e_t=2\tau\cdot\mathbf 1[\pi\ge t]$, which is non-decreasing with $\{e_t\le\tau\}=[0,t)$.
  * Exact answers on $e_t$ take only the two values $0$ and $2\tau$. So a deterministic certifier with $q$ queries has at most $2^q$ transcripts, and hence at most $2^q$ outputs.
  * Take $M=\lceil1/h\rceil$ thresholds in $(0,1]$ pairwise more than $h$ apart. Two of them, $t<t'$, sharing a transcript share $V$. Soundness on $e_t$ gives $V\subseteq[0,t)$, so on $e_{t'}$ the miss exceeds $h$.
  * Hence $2^q\ge M$, i.e. $q\ge\lceil\log_2(1/h)\rceil$. ∎

*Computed (`learn_regions.py`; thresholds revised after verification).*
* The small-angle schema has $e(\theta_0)=\frac2\pi K(\sin^2\frac{\theta_0}2)-1$. It is provably increasing, being a power series in $k^2$ with positive coefficients.
* A rigorous enclosure $[k^2/4,\ k^2/4+\frac9{64}k^4/(1-k^2)]$ follows from the decreasing coefficients $c_n=((2n-1)!!/(2n)!!)^2$.
* The monotone certifier (20 lazy-bisection queries on $[0,0.9\pi]$) then gives:
  * $\theta_0\le7.243°$ for τ = 10⁻³ (exact threshold 7.2441°);
  * 16.168° for 5×10⁻³ (exact 16.1687°);
  * 22.810° for 10⁻² (exact 22.8138°);
  * 49.946° for 5×10⁻² (exact 50.1040°).

  *Rigour.* Each reported value is truncated *downward* to 0.001°, and the enclosure at the reported angle is re-checked in mpmath interval arithmetic: $e_{\rm up}\le\tau$ holds rigorously. The earlier version printed 16.17° and 49.95°. Both were rounded *up* past the certified thresholds 16.1681° and 49.9468°, so they were not certified. In fact $e(16.17°)=5.0008\times10^{-3}>5\times10^{-3}$, so 16.17° is truly outside the region. 49.95° is truly safe ($e=0.04968$), but it was not certified.

**Proposition 4.7 (Laymon monotonicity can fail) [computed, `drag_sign.py`].**
* Take a pendulum with quadratic drag β at amplitude 6.75°. The signed relative period shift is −3.0, −5.3, −7.7, −3.9, +10.9, +36.2 (×10⁻⁶) at β = 0.0125, 0.025, 0.05, 0.1, 0.15, 0.2. Amplitude decay shortens the period (through the nonlinearity), and damping lengthens it at second order.
* So $|e|$ is non-monotone in β. With τ = 6×10⁻⁶, a monotone certifier that queries β = 0.1 ($|e|=3.9\times10^{-6}$) certifies $[0,0.1]$, which contains β = 0.05 with $|e|=7.7\times10^{-6}>\tau$.

"Better data, better predictions" (Laymon 1987) is a substantive property of a model–query pair. It is to be proved, not assumed. I believe this is in the spirit of Laymon's own discussion. The wording "monotonicity and truth are independent", attributed to him in earlier drafts, is from memory and **unverified**; no page reference is available.

---

## 5. The checker and its main theorem

**Definition 5.1 (SPS).** A *Structured Physics Solution* (L9 §7.1, made precise) is a tuple $(\rho,\mathcal T,D,X)$:
* $\rho$ is a reading:
  * the frame class, with parameter roles (given, measured with intervals, free with ranges, deformable);
  * the query $Q$ and its type (dimension and the allowed symbols);
  * the conventions used.
* $\mathcal T$ is a context tree of SUP, DEF and AUX contexts.
* $D$ is a derivation in the calculus of §2.3, whose (Exp) instances cite schemas from a catalogue $\mathcal B$.
* $X$ is the final judgment $@\Vdash Q\in[q-\delta,q+\delta]$.

  *(Revised after verification.)* Germ-root problems (declared regimes, Thm 3.5(c)) are represented by a top-level DEF(germ) context $d$ whose declaration belongs to the trusted specification. Then $X$ is a judgment $d\Vdash\chi$ at $d$, and Thm 5.3's conclusion becomes $d\models_w\chi$ for every $w\in W_\rho$.

**Definition 5.2 (checker) (revised after verification: the first three checks below were missing, and without them the checker accepted Thm 3.9(b)'s attack).** The checker accepts iff all of the following hold:
* **Ax legality.**
  * Every Ax at the root is in $\mathrm{Ax}_\rho$.
  * Every Ax in SUP(A) is $A$.
  * Every Ax in a DEF context is a canonical stipulation generated by its declaration (§2.3): $p_i=\lambda^\circ_i$ under limit semantics, $p_D\in U$ with $U\in\mathcal G$ under germ semantics.
* **Kernel and laws.** Every Step is accepted by the kernel, and every law it cites is in the trusted law catalogue.
* **Schema indexing.** Every Exp cites a $\beta\in\mathcal B$ whose catalogue entry is indexed by *exactly* the context's declaration $(D,\lambda^\circ,\mathcal G)$. Its side condition $\sigma_\beta$ and the context's well-posedness certificate $\omega_c$ (Thm 3.9(c)) are derived *in the parent*. An asymptotic schema (Remark after Thm 3.9) may be cited only below a principal parent.
* **Imports.** Every Imp into a DEF context is a catalogue law or an undeformed datum for that context's $D$ (Def 1.7). Imports into SUP children are unrestricted.
* every non-root, non-AUX context is SUP or DEF;
* every AUX bridge is a kernel-checked theorem;
* $X$ is derived at the root (or at the declared germ-root context).

All of these checks are deterministic.

*Which parameters are "deformable" need not be trusted for soundness.* Any declared deformation is semantically legitimate (Def 1.3). What soundness needs is two things: the context's axioms are canonical for its declaration, and every export goes through a schema proved for that very declaration. Suppose a solver-supplied ρ declares $g$ deformable and uses DEF($\{k,g\}$, $(0,g')$). Then the "neglect $k$" schema, which is indexed by DEF($\{k\}$, 0), cannot be cited. A catalogue schema proved for the joint deformation would have to account for the change of $g$ in its ε. The deformable list matters only for fidelity to the intended problem, i.e. under (J1).

**Trusted base (revised after verification).**
* (T1) The kernel and the law catalogue are sound for the frame. Every accepted Step instance and every catalogue law is valid in every $\mathfrak M_w(\lambda)$, $\lambda\in\mathrm{dom}$. The law catalogue covers the laws cited in Steps and Imps, including top-model theorems used as certified-neighbourhood bridges (Thm 3.5(a)), such as Prop 6.2.
* (T2) Every $\beta\in\mathcal B$ is a theorem of the frame, for its indexed declaration, in one of two forms:
  * the pointwise form of Thm 3.9(c), with its well-posedness clause;
  * the asymptotic form of the Remark after Thm 3.9.
* (T3) Validated numerics return correct enclosures.

**Theorem 5.3 (relative soundness of the SPS checker) [proved; TOSU given §§1–3] (revised after verification, with Def 5.2).** Assume (T1)–(T3). For every solver whatsoever: if the checker accepts $(\rho,\mathcal T,D,X)$ with a root judgment $X$, then $Q^{\mathfrak M_w(\lambda^*_w)}\in[q-\delta,q+\delta]$ for every $w\in W_\rho$. For a germ root the conclusion is $d\models_w\chi$ for every $w\in W_\rho$. Moreover:
* if the intended reading satisfies $W_{\rho^*}\subseteq W_\rho$ (J1), the export is supertrue for the intended problem;
* if the actual system is in $W_{\rho^*}$ (J2), it is true of the world.

*Proof.* Apply Theorem 2.5, checking each kind of instance:
* *Step instances*, by (T1). A frame-valid instance has truth set dom, which lies in every filter, so it is $c$-sound in every context $c$.
* *Root axioms*, since $\mathrm{Ax}_\rho$ is true at every $w\in W_\rho$ by definition.
* *SUP axioms*, by Def 1.3.
* *DEF axioms*, since canonical stipulations are $\mathcal F_c$-true (§2.3). This is the check that blocks Thm 3.9(b).
* *Imports into DEF contexts*, by Lemma 1.8(a). Imports into SUP children hold because the child's filter refines the parent's.
* *Discharges*, by Prop 1.5.
* *Exports*, by Thm 3.9(c) (or its Remark) with (T2) and (T3). Schema indexing ensures that the cited schema is a theorem for the context's actual declaration. The side condition and $\omega_c$ are true in the parent because their derivations are sound, by the induction of Thm 2.5.

The root filter at $w$ is principal at $\lambda^*_w$, so root truth is truth at the actual point. Nothing in the argument depends on how $D$ was produced. ∎

**Theorem 5.4 (the judgment layer is ineliminable) [proved; TOSU].**
* (a) *Reading.* Let $\mathcal R$ be the set of readings that the checker's inputs (problem text, figures, SPS) do not exclude. A checker that is sound for every $\rho^*\in\mathcal R$ can accept $X$ only if $X$ holds on $\bigcup_{\rho\in\mathcal R}W_\rho$.
* (b) *Open world* (hypotheses made explicit after verification). Extend the frame by an unmodelled effect with parameter μ, so that $\mathfrak M'(\lambda,0)=\mathfrak M(\lambda)$. Suppose the class of admissible extensions satisfies two conditions:
  * it contains worlds whose actual $\mu^*\neq0$;
  * it is closed under perturbing the query $Q\mapsto Q+Af(\mu)$, for every $A\in\mathbb R$ and every $C^\infty$ function $f$ with $f(0)=0$; for example, extensions are only required to be $C^\infty$ in μ.

  Consider a checker whose information about the extension is the μ = 0 slice $\mathfrak M'(\cdot,0)$ together with the SPS. Every finite-tolerance world claim it accepts is false in some admissible extension. If $\mu^*=0$, or if the extensions must obey laws that bound $Q$, the conclusion can fail.

*Proof.*
* (a) If $X$ fails at some $w\in W_{\rho_0}$ with $\rho_0\in\mathcal R$, the checker is unsound when $\rho^*=\rho_0$.
* (b) Apply Lemma 3.2 in the μ direction at the actual λ. The checker's input is unchanged by $Q\mapsto Q+Af$, since $f(0)=0$. Choose $f$ with $f(\mu^*)=1$, possible since $\mu^*\neq0$. Then $Q(\mu^*)+A$ leaves any finite interval for large $|A|$. ∎

**Theorem 5.5 (supervaluational correctness; completion invariance) [proved; TOSU] (revised after verification).** Write $Q^w$ for $Q^{\mathfrak M_w(\lambda^*_w)}$. $W_\rho$ ranges over all admissible completions: free parameters $\theta_f\in\Theta_f$ *and* measured parameters in their intervals.
* "$Q\in[q\pm\delta]$" is supertrue iff $\sup_{w\in W_\rho}|Q^w-q|\le\delta$.
* A supertrue answer at precision δ exists iff $\mathrm{osc}_{W_\rho}Q\le2\delta$, where $\mathrm{osc}=\sup-\inf$. The midrange is then such an answer.
* A **completion-invariance certificate** is a root derivation of $Q\in[q\pm\delta]$ from $\mathrm{Ax}_\rho$ in which $\theta_f$ enters only through "$\theta_f\in\Theta_f$".
  * A sentence "$\forall\theta_f\in\Theta_f\ldots$" would be ill-typed in Def 1.1/1.3, since $\theta_f$ is a parameter constant evaluated at $\lambda^*_w$.
  * By Thm 5.3, every accepted root derivation is automatically completion-invariant. So in the formal checker completion invariance is not a separate obligation; it is the content of deriving from $\mathrm{Ax}_\rho$ rather than from a narrowed axiom set.
  * Informal certificate forms are $\partial Q/\partial\theta_f=0$ on a connected $\Theta_f$ *where $Q$ is differentiable in $\theta_f$*, or a variation bound. In §6 the regularity proviso matters: $E$ is constant in α only while the point stays lit for every admissible α, and it jumps to 0 at $s=L\tan\alpha$. That is why the export is restricted to $r\le34.3a$.
* By Thm 5.4(a), supertruth over $\bigcup\mathcal R$ is the *largest* acceptance criterion that is sound under reading uncertainty. This is the precise answer to "true in the context at hand — wtf is that?": true in every admissible completion of the context.

*Proof.* The first two bullets and the last are immediate from the definitions and Thm 5.4(a), using $W_{\rho^*}\subseteq\bigcup_{\rho\in\mathcal R}W_\rho$ for the last. The third is Thm 5.3 applied to root derivations. ∎

**Proposition 5.6 (Gricean determinacy is one-sided) [proved] (wording revised after verification).** Call ρ *determinate at δ* if $\mathrm{osc}_{W_\rho}Q\le2\delta$.
* If $W_{\rho'}\subseteq W_\rho$, then $\mathrm{osc}_{\rho'}\le\mathrm{osc}_\rho$.
* Hence the assumption "the problem is well-posed" can refute only (some) over-wide readings, namely those that are actually indeterminate, and never over-narrow ones. An over-wide reading such as α ∈ [20°, 70°] in §6 is still determinate on the (smaller) disk lit for every admissible α.
* Silent narrowing never decreases determinacy:
  * fixing the sun's angle α;
  * choosing a specular mirror;
  * importing an extra law;
  * the user's "is the finger horizontal?".

  Yet narrowing violates (J1), $W_{\rho^*}\subseteq W_\rho$, which soundness needs.

*Proof.* The supremum over a subset is at most the supremum over the set, and the infimum is at least the infimum. (For $W_{\rho'}=\emptyset$ take $\mathrm{osc}=-\infty$.) ∎

So the free internal signal for readings pushes *toward* the unsafe error, unlike coherence for rules (which pushes away from over-acceptance) and coherence for tolerances (which pushes away from over-confidence). The opposite signal must come from outside:
* a formal problem specification by the setter (then J1 becomes F);
* intended-completion data (official solutions, marking schemes: "peeked at the solution and it seems to assume that's not the case");
* partial S-checks such as rendering the model's observable and comparing it with the figure.

These are non-adversarial and one-sided too: a reading can fail a round-trip test, but passing one does not certify it.

---

## 6. Worked example: EuPhO 2025 Theory 1(a), the polished chair leg

*The setup is as reconstructed in L9 §8.2 from the user's introspection notes. It has not been checked against the official text. The answer $E=\frac{aI_0}2|\sin\frac\varphi2|/r$ is the user's, reported by him to match the official one.*

### 6.1 Reading and frame (the trusted problem specification)

* **Frame.** A vertical specular cylinder of radius $a$, lit over height $L$, on a flat floor. The sun is a parallel beam of irradiance $I$ at angle α from the vertical, travelling in $+x$. The floor's direct illuminance is $I_0=I\cos\alpha$. The query is the reflected-light floor illuminance ("surplus") $E(r,\varphi)$, with φ measured from the anti-sun direction.
* **Given:** $a,I_0,L$.
* **Free completion:** $\alpha\in[30°,60°]$, which the photo does not fix.
* **Conventions:** perfect specular reflectance, geometric optics, incoherent addition, sun angular radius $\delta_s=4.65$ mrad, leg vertical.
* **Answer type:** a function of $(a,I_0,r,\varphi)$ only, with dimension of $I_0$.

### 6.2 The in-model theorem

**Proposition 6.1 (exact reflected illuminance) [proved; SymPy-verified].** Parametrize the lit side by $\theta\in(\pi/2,3\pi/2)$ and the reflection height by $h\in[0,L]$. Let $\psi=2\theta-\pi\in(0,2\pi)$, $s=h\tan\alpha$ and $c=\sin\frac\psi2$. Then:
* (a) the reflected ray from $(a\cos\theta,a\sin\theta,h)$ lands at $P=a\,e(\theta)+s\,e(\psi)=(s+ac)\,e(\psi)+a\cos\frac\psi2\,e(\psi+\frac\pi2)$;
* (b) $(\theta,s)\mapsto P$ is injective with $|\det\partial P/\partial(\theta,s)|=2s+ac$;
* (c) $E(P)=I_0\,\dfrac{ac}{2s+ac}$ for $s\le L\tan\alpha$, and the total reflected flux is $2aLI\sin\alpha$, equal to the intercepted flux. $E=0$ at floor points outside the image of the map, and at points whose preimage has $s>L\tan\alpha$ (made explicit after verification);
* (d) at a fixed floor point, $E$ does not depend on α. Only the lit domain $s\le L\tan\alpha$ does.

*Proof.*
* (a) Reflection in the vertical surface keeps the vertical velocity component and reflects the horizontal one: $u'=u-2(u\cdot n)n=e(2\theta-\pi)$ for $u=e(0)$. Descending height $h$ takes horizontal travel $h\tan\alpha$. The second form uses $e(\theta)\cdot e(\psi)=\sin\frac\psi2$ and $e(\theta)\cdot e(\psi+\frac\pi2)=\cos\frac\psi2$.
* (b) The Jacobian determinant is $a\cos\theta-2s$ (SymPy), which is negative on the lit side. For injectivity (equivalently: the caustic of a convex cylindrical mirror is virtual), write ray ψ as $t\,e(\psi)+a\cos\frac\psi2\,e(\psi+\frac\pi2)$ with $t\ge a\sin\frac\psi2$, and set $\psi_1=2x<\psi_2=2y$, $d=y-x$. Intersecting the lines gives $t_1=a(\cos x\cos2d-\cos y)/\sin2d$ and $t_2=a(\cos x-\cos y\cos2d)/\sin2d$.
  * If $\sin2d>0$: $t_2\ge a\sin y$ forces $d\ge2x$, while $t_1\ge a\sin x$ reduces to $\cos(x+2d)\ge\cos(x+d)$ and forces $2x+3d\ge2\pi$. Together these give $4d\ge2\pi$, contradicting $d<\pi/2$.
  * If $\sin2d<0$: the inequalities flip. $t_2\ge a\sin y$ forces $d\le2x$, and $t_1\ge a\sin x$ forces $2x+3d\le2\pi$ (since $x+2d>\pi$). Together these give $4d\le2\pi$, contradicting $d>\pi/2$.
  * If $\sin2d=0$ ($d=\pi/2$), the rays are antiparallel. They share a line only when $x=\pi/4$, and then they point apart.

  A numerical search over $2\times10^6$ random pairs (`leg_exact.py` (9)) also found no forward intersection.
* (c) The irradiance on the surface element is $I\sin\alpha|\cos\theta|$ and the element is $a\,d\theta\,dh$ with $dh=ds/\tan\alpha$. Dividing by $|\det|\,d\theta\,ds$ gives $I\cos\alpha\cdot ac/(2s+ac)$. The flux integral was done symbolically.
* (d) Neither $P(\theta,s)$ nor $E$ in terms of $(\theta,s,I_0)$ contains α. ∎

*Cross-check [computed, `leg_mc_flux.py`].* A 40M-ray Monte Carlo of the same physics, binned over annular sectors and compared with the exact flux through each bin's preimage, gives MC/exact = 0.9997, 1.0038, 1.0099, 1.0030, 1.0009 at $(r/a,\varphi)$ = (3, π), (5, 2π/3), (10, π), (10, 4π/3), (20, π). That is consistent with ≈0.6% sampling noise. (L9's single-point comparisons showed apparent 3–7% deviations; these were bin noise and the thin-leg error, now separated.)

Part (d) is the **completion-invariance certificate**, and it is *exact* in the top model, not just in the thin-leg limit. The user's episode "I suspected [the angle doesn't matter] but then I messed up a calculation" corresponds to a failed proof obligation that the checker would have flagged at once.

### 6.3 The bridges

**Proposition 6.2 (thin-leg bridge, rigorous) [proved; checked on 2.5×10⁶ points] (lit-domain hypothesis added after verification).** Let $E_0=\frac{aI_0}2\sigma/r$, $\sigma=|\sin\frac\varphi2|$, $\epsilon=a/r$ and $m=\frac12\arcsin\epsilon$. Assume $\epsilon<2/\sqrt5$, $\sigma>m$ and $r\le L\tan\alpha$, or $L=\infty$. Then:
$$1-\frac m\sigma\ \le\ \frac{E}{E_0}\ \le\ \frac{1+m/\sigma}{\sqrt{1-\epsilon^2}-\epsilon/2}.$$
Without the lit-domain hypothesis the lower bound fails. For example, with $L=60a$, α = 30°, $r=40a$ and φ = π, the preimage has $s=39a>L\tan\alpha=34.6a$, so $E=0$.

*Proof.*
0. *The point is lit and in the image.* For $r\ge a$, every ψ gives $s=u-ac\ge0$, where $u=\sqrt{r^2-a^2\cos^2\frac\psi2}$.
   * As ψ runs over $(0,2\pi)$, the angle $\varphi(\psi)=\psi+\delta(\psi)$ (step 2) runs continuously from $\arcsin\epsilon$ to $2\pi-\arcsin\epsilon$.
   * $\sigma>m$ implies $\varphi\in(\arcsin\epsilon,2\pi-\arcsin\epsilon)$, since $\sin x\le x$.
   * So the point has a preimage, unique by 6.1(b). That preimage satisfies $s\le u\le r\le L\tan\alpha$, so the point is lit.
1. Let $u=s+ac\ge0$. From 6.1(a), $r^2=u^2+a^2\cos^2\frac\psi2$, so $u\in[r\sqrt{1-\epsilon^2},r]$.
2. $\varphi=\psi+\delta$ with $\tan\delta=a\cos\frac\psi2/u$, so $|\sin\delta|\le\epsilon$ and $|\delta|\le\arcsin\epsilon$. Hence $|\sigma-c|\le|\delta|/2\le m$.
3. $E/E_0=(c/\sigma)\cdot2r/(2u-ac)$. The second factor lies in $[1,\ 1/(\sqrt{1-\epsilon^2}-\epsilon/2)]$, since $2u-ac\le2r$ and $2u-ac\ge2r\sqrt{1-\epsilon^2}-a$.
4. The first factor lies in $[1-m/\sigma,1+m/\sigma]$. Multiply. ∎

*Numbers [computed] (revised after verification).*
* Equality analysis: at φ = π the exact ratio is $2r/(2r-a)$, i.e. 1.0256 at $r=20a$, against the bound's 1.053.
* Smallest $r$ at which the bound gives 5%: $r\ge21a,\ 31a,\ 44a,\ 111a$ for σ = 1, 0.5, 0.3, 0.1.
* The exact error exceeds 5% only for $r\le10.5a,\ 10.4a,\ 27.6a,\ 98a$ respectively. These come from root-finding on exact σ level sets. The earlier values 11a, 28.5a and 107a came from grid bands $|\sigma-\sigma_g|<0.01$ and were biased upward.

How conservative is the bound in $r$, at 5%? About 1.1× at σ = 0.1, 2× at σ = 1, 3× at σ = 0.9 and 6× at σ = 0.8. Near σ = $1/\sqrt2$ the factor grows sharply: 18× at σ = 0.7 and 23× at σ = $1/\sqrt2$. The earlier claim "at worst about 3×" was wrong.

The reason is that the exact error has first-order term $E/E_0-1\approx\epsilon(2\sigma^2-1)/(2\sigma)$, which vanishes at σ = $1/\sqrt2$. There the exact error is second order in ε, while the bound is first order. As tol → 0 the factor is unbounded. At σ = $1/\sqrt2$ it is 23×, 49×, 108× and 242× for tol = 5%, 1%, 0.2% and 0.04%: the rigorous $r\propto1/\mathrm{tol}$, while the exact $r\propto1/\sqrt{\mathrm{tol}}$.

A sharper certificate would use the first-order estimates $\sigma-c\approx\epsilon(1-\sigma^2)/2$ (the absolute deviation; earlier drafts had a spurious $1/\sigma$) and $E/E_0-1\approx\epsilon(2\sigma^2-1)/(2\sigma)$. At $r=20a$, σ = 0.5 these give 1.875×10⁻² against the exact 1.911×10⁻², and −2.50% against the exact −2.56%. The export domain is an *annulus* $a\ll r<L\tan\alpha$, away from the shadow-side kink σ → 0: Barenblatt's intermediate asymptotics, with the failure at small $r$ being the ray-optics $1/r$ artefact.

**Proposition 6.3 (finite-sun bridge) [proved] (hypotheses made explicit after verification).** Let α denote the sun's *zenith angle* (from the vertical), with admissible range $[\alpha_{\min},\alpha_{\max}]\subseteq(0,\pi/2]$. Let $\delta_s<\alpha_{\min}$ be the sun's angular radius and $\Delta=\arcsin(\sin\delta_s/\sin\alpha_{\min})$. Assume:
* $r\le L\tan(\alpha_{\min}-\delta_s)$;
* $\epsilon<2/\sqrt5$;
* $\sigma-\Delta/2>m=\frac12\arcsin\epsilon$. This makes Prop 6.2 apply at every shifted azimuth, and all lower-bound factors nonnegative before multiplying.

Then the finite-sun illuminance satisfies
$$\frac{E_{\odot}}{E_0}\in\Big[(1-\tfrac{\Delta}{2\sigma})\,\mathrm{lo}(\epsilon,\sigma-\tfrac\Delta2),\ (1+\tfrac{\Delta}{2\sigma})\,\mathrm{hi}(\epsilon,\sigma-\tfrac\Delta2)\Big],$$
with lo and hi the bounds of Prop 6.2.

*Proof.*
1. *Domain.* Each sun direction $d$ has zenith angle in $[\alpha-\delta_s,\alpha+\delta_s]$. Since $s\le u\le r$, every $P$ with $r\le L\tan(\alpha_{\min}-\delta_s)$ is lit by every direction, for every admissible α.
2. *Convex combination.* By Prop 6.1(d) and rotational symmetry, direction $d$ contributes $G(r,\varphi-\beta_d)\,\cos\alpha_d\,dI(d)$, where $G=E/I_0$ is the α-free geometric factor. The direct illuminance is $I_0=\int\cos\alpha_d\,dI(d)$, so $E_\odot/I_0$ is a convex combination of $G(r,\varphi-\beta)$ over the sun's azimuth spread. This holds for *any* radiance profile over the solar disk, limb darkening included.
3. *Azimuth spread.* By Napier's rule for the right spherical triangle (zenith, sun centre, tangent point), $\sin(\text{spread})=\sin\delta_s/\sin\alpha\le\sin\delta_s/\sin\alpha_{\min}$, using $\alpha\in[\alpha_{\min},\pi/2]$. So $|\beta|\le\Delta$.
4. *Combine.* Apply Prop 6.2 at φ − β. This is legitimate because $|\sin\frac{\varphi-\beta}2|\ge\sigma-\frac\Delta2>m$, using $|\sin\frac{\varphi-\beta}2-\sin\frac\varphi2|\le\frac\Delta2$. Then use the monotonicity of lo and hi in σ, and $E_0(\varphi-\beta)/E_0(\varphi)\in[1-\frac\Delta{2\sigma},1+\frac\Delta{2\sigma}]$. ∎

*Check.* A referee tested a limb-darkened solar disc with $\delta_s\in\{4.65\times10^{-3},0.05,0.15\}$ rad, α ∈ [30°, 60°], $r\in[3,200]a$ and σ ∈ [0.05, 1], under the stated hypotheses: 0/859 violations.

### 6.4 The checker run

`sps_checker.py` encodes the specification above (with $L=60a$) and runs the checks of Def 5.2. SymPy stands in for a proof kernel; a real system would discharge these in Lean or Isabelle, with interval arithmetic for the bounds. The checks are:
* C0: reading containment against the formal specification;
* C1: answer type. The allowed symbols are $(a,I_0,r,\varphi)$ only, so *no free-completion symbol* may appear; the dimension is also checked;
* C2: no declared extra imports;
* C3: completion invariance. The top-model quantity is exactly α-invariant (Prop 6.1(d)), and the answer must *coincide identically* with the certified α-free form;
* C4: bridge side conditions recomputed from the root's declared domain, with every hypothesis of Props 6.2/6.3 asserted and the composed error budget.

For C4 the bounds are increasing in ε and decreasing in σ, so the worst case is at the corner $(a/r_{\min},\sigma_{\min},\alpha_{\min})$. All admissible α light the disk $r\le60\tan(29.73°)a=34.3a$.

*The first version was unsound (found in verification and repaired).* It accepted four attacks (V6–V9 below), for three reasons:
* C1 allowed α in the answer;
* C3 checked only the oscillation over α of answer/certified form, never its offset from 1;
* C4 never enforced $\epsilon<2/\sqrt5$ or $\sigma_{\min}-\Delta/2>m$. For $\epsilon>2/\sqrt5$ the upper bound turns negative and was silently dropped by a `max`.

In the repaired version, V2 and V5 are rejected because the SPS *declares* the violation. The semantic protection lies elsewhere:
* C4 recomputes every side condition from root data, so a child evaluation cannot affect the budget;
* C3 rejects any answer that differs from the form certified from the declared imports, which catches an *undeclared* import that changes the answer (V11).

The checker is still a toy. It accepts only answers symbolically identical to the certified form. A fuller checker would add a rigorously enclosed offset |answer/certified − 1| to the budget.

| Submitted SPS | Outcome |
|---|---|
| **Honest**: $E=\frac{aI_0}2\sin\frac\varphi2/r$ on $r\in[20a,34a]$, σ ≥ 0.5, tolerance 10% | **ACCEPT**, certified error ≤ 8.88% (point-sun exact error there ≤ 2.56%; sun term ≤ 0.93%) |
| V0: same, tolerance 5% | REJECT: budget 0.0888 > 0.05. A *completeness* gap of the certificate: the truth is within 5% |
| V1: overclaimed domain $r\ge5a$ | REJECT: budget 0.380 > 0.10 |
| V2: thin-leg side condition evaluated in the child ($a:=0$ there), declared as such | REJECT: Thm 3.9(a). A silent child evaluation cannot change the budget, since C4 recomputes it from root data |
| V3: answer $\frac{aI_0}{2\cos\alpha}\sin\frac\varphi2/r$ (writing $I$ for $I_0$) | REJECT by C1 (α in the answer) and C3 (not completion-invariant; half-oscillation over α = 0.42) |
| V4: reading narrowed to α = 45° | REJECT by C0, which is possible only because the spec is formal; otherwise this is (J1) |
| V5: declared extra import "10% Lambertian fraction" | REJECT: import not in the specification |
| V6: $2\cdot E_{\rm thin}\cos(\alpha)^{1/1000}$ (true error ≈ 0.5) | REJECT by C1, C3. *Accepted by the first version* ("≤ 0.0888") |
| V7: $\frac{23}{20}E_{\rm thin}\cos(\alpha)^{1/50}$ (true error 0.159 > 0.10) | REJECT by C1, C3. *Accepted by the first version* |
| V8: $1.5\,E_{\rm thin}\,e^{\alpha/1000}$ | REJECT by C1, C3. *Accepted by the first version* |
| V9: domain $r\ge1.05a$, σ ≥ 1, tolerance 0.7 (true error 0.909) | REJECT by C4: $\epsilon=0.952>2/\sqrt5$. *Accepted by the first version* ("≤ 0.635") |
| V10: constant factor $1.09\,E_{\rm thin}$ (control) | REJECT by C3: differs from the certified form |
| V11: undeclared 10% diffuse correction, $1.1\,E_{\rm thin}$, with honest declarations | REJECT by C3: differs from the certified form |

**What remains judgment (J1, J2) in this problem.**
* The photo-to-model reading:
  * the leg is a *specular* cylinder (from the radial streaks and the shadow);
  * it is lit over its full height;
  * its reflectance (which multiplies $E$ and is not supplied);
  * the meaning of "illuminance surplus";
  * the admissible α range.
* The open-world effects:
  * leg taper and tilt;
  * floor roughness;
  * the chair seat's shadow on the leg.

Each could be added to the frame as a declared deformation with its own bridge, which would move it from J to F. What cannot be moved is the claim that *these* are all the effects the setters intend (Thm 5.4). The one F-checkable consistency test on the reading is the round-trip: render the predicted floor pattern (an annulus-limited $|\sin\frac\varphi2|/r$ fan with a shadow-side kink) and compare it with the photograph.

**Secondary examples (numbers from L9, [computed] there).**
* *IPhO 2025 T2 C.4* is a germ-root problem (regime "$S_t\ll S_b$" declared). The leading-order $W^*=19.8$ mJ differs from the exact-ξ optimum 20.1 mJ by 1.3%. The export with that budget lies inside the marking interval [19, 21] mJ, so the tolerance-aware check of Thm 3.8 passes.
* *C.3 "switch is instantaneous"* passes only in the robust form of Thm 3.5(a).

---

## 7. Assessment, open problems, experiments

### 7.1 What is deep, what is TOSU, what is new

* **TOSU (the content is in the definitions):**
  * Props 1.4–1.6;
  * Lemma 1.8;
  * Thms 2.1, 2.5;
  * Cor 2.6;
  * Prop 2.7;
  * Thms 3.5, 3.8;
  * Thms 4.1, 4.4;
  * Thms 5.3–5.5;
  * Prop 5.6.

  This is unsurprising. The user's request is largely for the right *setup*, and the theorems certify that the setup does what it should.
* **Standard results, imported:**
  * Łoś;
  * Gronwall;
  * split conformal;
  * radius of information;
  * the invisible-perturbation (kernel/adversary) argument of information-based complexity behind Lemma 3.2 and Thms 3.3, 4.4 (Bakhvalov; Traub–Wasilkowski–Woźniakowski 1988 [cited, unverified details]);
  * Lipschitz covering lower bounds;
  * interval inclusion monotonicity.

  *(Reclassified after verification.)* Using one argument for both no-free-export and no-free-certification is an expository framing, not a new result.
* **Elementary illustrations (not new):** the reductio-hygiene example (Thm 1.9c). An inconsistent premise set supports reductios of both A and ¬A, each from a consistent sub-premise set. *(Reclassified after verification.)*
* **Small but real (new as far as I know):**
  * the frame-free realizability criterion with anchoring, and the necessity of informativeness (Thm 2.4(a)). *(Revised after verification:* its locality is a consequence of the frame-free definition. The exact frame criterion under limit semantics (Prop 2.7) is a TOSU refinement.)
  * the two-sided necessity in adversarial stipulation, including the well-posedness certificate (Thm 3.9);
  * the three-way table of one-sided signals. Its ingredient Prop 5.6 is an observation, monotonicity of sup and inf, and only interpretively new;
  * a rigorous thin-leg certificate for the cylinder mirror, and a complete checker run with adversarial variants (§6). The exact cylinder-mirror illuminance itself (Prop 6.1) is elementary catoptrics. I have not found it in the sources I checked, but the official solution of the olympiad problem may contain it, so its novelty is **uncertain (unverified)**.
* **Deep and unsolved:** the reading layer. I proved that it cannot be eliminated (Thm 5.4), that the free signal for it points the wrong way (Prop 5.6), and that supervaluation is the best one can do under reading uncertainty (Thm 5.5). I have no theorem about *learning* readings.

### 7.2 Where this leaves the user's questions

* *"Arguments for P and ¬P in contradictory contexts should not be penalized."* Correct.
  * In the frame-free sense, Theorem 2.4(a) says exactly which contexts *must* be consistent: the root, and idealizations that are certified or export informatively.
  * In the paper's own frame semantics this is necessary but not sufficient (Thm 2.4(b),(c)). Contexts at the same parameter point must also be jointly consistent with the actual parameter values (Prop 2.7, limit semantics).
  * The checker enforces those frame constraints through the declaration discipline (canonical stipulations, D-stable imports, schema indexing), not through coherence.
* *"Verification from truth… but wtf is that?"* A claim is true in the context at hand iff it holds on the context's filter for every admissible completion (Def 1.3, Thm 5.5). Checking it decomposes into kernel steps, stable imports, certified bridges with parent-evaluated side conditions, and a reading. Only the reading is not mechanizable.
* *Reductio in inadequate frameworks.* It is legitimate given a consistency certificate: a structure satisfying the imported fragment and the rule instances used, such as a properness witness for the context. With approximate premises it also needs a margin (Thm 1.9, Prop 1.10).
* *"How come we usually avoid catastrophic reasoning [100 = 99.9]?"* Tolerance typing turns it into a visible budget violation (Thm 3.8c).
* *Untrusted solvers.* Soundness holds against all solvers for everything except the reading. The solver's characteristic attack, silent narrowing, is invisible to the internal determinacy signal and to every check that does not compare against a specification (Prop 5.6, Thm 5.4). Hence the strongest recommendation: **have the problem setter supply a formal specification of the admissible completions**, and grade only supertrue claims. With that, the checker is sound relative to the top model alone.

### 7.3 Open problems

1. **Idealization inside supposition.** Extend Thm 2.4 to DEF contexts below SUP contexts, where anchoring depends on the consistency of the supposition.
2. **Non-value exports.** Characterize realizability for bridges exporting sets of claims (e.g. qualitative shape features).
3. **Learning readings.** What positive data identify $W_{\rho^*}$, given that determinacy is one-sided? A natural conjecture is that official solutions together with marking schemes form a tell-tale for readings in a class where each reading is "the minimal completion consistent with the intended solution's imports". This is untested.
4. **Sharper certificates.** Close the gap in Prop 6.2: 2× at σ = 1, up to about 23× near σ = $1/\sqrt2$ at 5%, and unbounded as tol → 0. The cure is a second-order certificate using $E/E_0-1\approx\epsilon(2\sigma^2-1)/(2\sigma)$. More generally, obtain *validated exact-error maps* from closed-form or interval-ODE top models, so that certificate incompleteness (V0) disappears.
5. **Proving regularity.** Automate Lipschitz or monotonicity proofs for bridge error functions (Thms 4.5–4.6) in a proof assistant. Without them, simulation-calibrated validity regions are statistical, not sound.
6. **Kelly link (L7 conjecture).** Exports make a world claim verifiable in the limit iff the query is continuous at the true parameters, given shrinking certified neighbourhoods. Thm 3.5(a) gives the "if" direction; Thm 3.3 suggests the "only if".
7. **Frame realizability under germ semantics** (added after verification). Prop 2.7 characterizes frame realizability for limit semantics. Under germ semantics the DEF filters are non-principal, so contexts no longer sit at single points. The coincidence and rigidity constraints then become constraints on filter germs. Characterize them.

### 7.4 Suggested experiments

1. **Checker on three problems.** Encode the §6 problem, IPhO 2012 T1-A (fully F after reading) and IPhO 2025 T2 as SPSs in Lean or SymPy with interval arithmetic. Generate adversarial variants with an LLM instructed to "make the checker accept a wrong answer". Measure which attacks succeed. The prediction is that only reading narrowing succeeds, *provided the checks are semantic*: the checker must recompute side conditions from root data, check axioms and schema indexing, and compare answers with certified forms. The verification of this note found that a first, syntactic version of the §6 mini-checker accepted four simple attacks (§6.4), which shows how easily this proviso fails.
2. **Tolerance learning.** For 5–10 catalogue idealizations, compare three calibrators on adversarially chosen test instances: coherence-only (drifts), conformal (fails at the tail), and Lipschitz/monotone certification with proved constants (sound).
3. **Reductio hygiene in learners.** Train a step verifier with a coherence loss that consumes reductios from (a) certified and (b) uncertified contexts, some of them with inconsistent imported fragments. The prediction from Thm 1.9(e) (revised) is systematic, world-independent, contradictory labels from the inconsistent fragments, and degraded accuracy in (b).
4. **Determinacy pressure.** Let a model choose readings to maximize answer determinacy and measure how often it lands on over-narrow, unintended readings (Prop 5.6).

---

## References

Items marked **(unverified)** are from memory; L7 and L9 give fuller bibliographic notes.

* Brown, B., & Priest, G. (2004). Chunk and permeate. *J. Phil. Logic* 33:379–388.
* Fine, K. (1975). Vagueness, truth and logic. *Synthese* 30. (unverified pages)
* Gronwall, T. H. (1919). Note on the derivatives with respect to a parameter of the solutions of a system of differential equations. *Ann. Math.* 20:292–296. (unverified pages)
* Laymon, R. (1987). Using Scott domains to explicate the notions of approximate and idealized data. *Phil. Sci.* 54:194–221.
* Lei, J., G'Sell, M., Rinaldo, A., Tibshirani, R., & Wasserman, L. (2018). Distribution-free predictive inference for regression. *JASA* 113:1094–1111. (unverified pages)
* Łoś, J. (1955). Quelques remarques, théorèmes et problèmes sur les classes définissables d'algèbres. In *Mathematical Interpretation of Formal Systems*, North-Holland. (unverified details)
* McCarthy, J. (1993). Notes on formalizing context. *IJCAI-93*.
* McMullin, E. (1985). Galilean idealization. *Stud. Hist. Phil. Sci.* 16:247–273.
* Moore, R. E. (1966). *Interval Analysis*. Prentice-Hall.
* Nemirovsky, A., & Yudin, D. (1983). *Problem Complexity and Method Efficiency in Optimization*. Wiley. (unverified details)
* Norton, J. D. (2012). Approximation and idealization: why the difference matters. *Phil. Sci.* 79:207–232.
* Traub, J. F., Wasilkowski, G. W., & Woźniakowski, H. (1988). *Information-Based Complexity*. Academic Press. (unverified details)
* Vovk, V., Gammerman, A., & Shafer, G. (2005). *Algorithmic Learning in a Random World*. Springer.
* Project memos: L6, L7, L9, L10; theory threads T1, T2.

---

## Verification log

Three independent adversarial referees checked this note: A covered §§1–2, B covered §§3–4, C covered §§5–6. Each reported issue was re-checked by the author, with computation where useful. The referee reports are held by the verification workflow. The repairing agent could not write the requested copy `research/verification/T3-contexts-idealization-export-verification.md`, because its harness blocks subagents from writing report files, so that copy still has to be made.

Nothing was rated fatal. Four issues were major, and all four were genuine and are fixed:
* A1, Thm 2.4 vs the frame semantics;
* B1, Thm 3.9(c);
* C1, Def 5.2/Thm 5.3;
* C2, the mini-checker.

All minor issues were genuine and are fixed, weakened or clarified. No reported issue was rejected.

### Referee A (§§1–2)

| # | Item | Sev. | Verdict and action |
|---|---|---|---|
| A1 | Thm 2.4: characterizes frame-free (Def 2.3) realizability, not Def 1.3 | major | **Genuine.** I reproduced both counterexamples (`realizability_frame.py`, which re-runs the referee's `def13.py`). **Fixed.** Thm 2.4 is split. (a) is the original criterion, stated as *frame-free*. (b) is new: necessity for frame realizability, proved via a filter anchoring lemma. (c) is new: non-sufficiency, with CE1 and CE2. New **Prop 2.7** gives the exact frame criterion under limit semantics. It is non-local: closure under parents, informative bridges and point coincidence, plus joint satisfiability per parameter point with the parameter values. Prop 2.7 and (b) were brute-forced over all frames on Λ={0,1}² on 8,000 instances: 0 mismatches, 0 necessity violations, 598 instances in the gap. Also: the "verbatim for Def 1.3" sentence was deleted; Remark (i) now says locality follows from (R2); Cor (ii) was adjusted; §0, §7.1 and §7.2 were softened; open problem 7 (germ semantics) was added. |
| A2 | Thm 2.4 core proof and checks | ok | Confirmed. The referee's deeper DP stress test was added as `realizability_deep.py`; re-run gives 2,000 instances, 746 realizable, 0 mismatches. |
| A3 | Cor (iii) vs Cor 2.2: two notions of eternalism | minor | **Genuine. Fixed.** Cor (iii) now uses Cor 2.2's stripping definition. It proves that stripped-satisfiability implies realizability, and states the strictness of the collapsed variant separately, witnessed by Cor 2.2(ii)–(iii) only. |
| A4 | Def 1.1: real sort not required standard; ±∞ ideal values | minor | **Genuine. Fixed.** Def 1.1 now requires a standard ordered-field interpretation with standard numerals, and Λ ⊆ ℝⁿ. Infinite ideals are reparametrized. Def 1.2 now has λ° ∈ ℝ^D. *Follow-up found during repair.* The class of standard-real structures is not compact, since {Q≠v : v∈ℝ} is finitely satisfiable but has no model. So informativeness (Def 2.3) is now *defined* in finite form, and the anchoring lemmas of Thm 2.4(a),(b) and Cor 2.6 no longer invoke compactness. Thm 2.4(b)'s last step now uses the finiteness of Th*(c) instead of Prop 1.4(b). |
| A5 | Stale script docstrings; certP | minor | **Genuine. Fixed** in `realizability.py`, `realizability_sup.py` and `hygiene.py`. certP is noted as an extension. |
| A6 | Lemma 1.8 | ok | Confirmed. No change to the proof; now Lemma 1.8(a). |
| A7 | "Sound imports are exactly the D-stable sentences" | minor | **Genuine** (checked the "k ≤ 1" counterexample). **Fixed.** New Lemma 1.8(b), the uniform converse, is proved. A scope remark gives the counterexample. §0 and the Consequence paragraph now say "exactly … uniformly in the actual point and ideal value". |
| A8 | Prop 1.4 "Reading (c)" gloss | minor | **Genuine. Fixed.** Under limit semantics the ultraproduct is the standard model. Under germ semantics with a root parent, the undeformed parameters are exact. |
| A9 | Prop 1.5 | ok | Confirmed. No change. |
| A10 | Thm 1.9(d) ambiguous under context-relative soundness | minor | **Genuine** (checked the "/q" counterexample). **Fixed.** N must satisfy every instance used. The counterexample is included. Such an N exists whenever c is proper and c ⊨ K_c, so a properness witness is a certificate. The closing paragraph of §1.4 and §7.2 were adjusted. |
| A11 | Thm 1.9(c): "every derivation-local test" undefined; novelty | minor | **Genuine. Fixed.** The claim now covers tests that are functions of the derivation alone and accept sound reductios from consistent premise sets, with an indistinguishability proof. §7.1 reclassifies it as an elementary illustration. |
| A12 | Thm 1.9(a) proof gap; (e) overgeneralized and "noise" | minor | **Genuine. Fixed.** (a)'s proof now runs Thm 2.5 in SUP(A), using filter refinement. (e) is restricted to contexts with R̂-inconsistent fragments, and the labels are described as "systematic" rather than "noise". Experiment 3 was adjusted. |
| A13 | Prop 1.10 wording | minor | **Genuine. Fixed:** "approximately true premises read as exact"; the margin is "sufficient, not necessary". |
| A14 | Thm 2.1 needs c proper; generic witnesses | minor | **Genuine. Fixed.** The hypothesis "c proper at w" is added. The witnesses are φ=⊤ and ψ=¬S_c, which work for every f. A note covers the improper case (rope). |
| A15 | Cor 2.2 representation dependence; probability remark | minor | **Genuine. Fixed:** "whenever J records …"; the probability remark is rephrased. |
| A16 | Thm 2.5 notation (σ_β(t); F_c clash) | ok/nit | **Fixed.** The import set is now Imp_c, and σ_β is written without argument. |
| A17 | Cor 2.6 gaps (ex falso, refutation completeness, synthetic Exp, two certificate notions, T2 indexing) | minor | **Genuine. Fixed.** Designation is now defined via properness witnesses and distinguished from Thm 1.9(d)'s certificate. Propagation now assumes ex falso and refutation completeness explicitly. Blame falls on the ω_c derivation, or on the synthetic Exp instances if ω_c is not required. T2 is read with context-indexed items, and Cor 2.6 takes the role of T2 Lemma 2.1. |
| A18 | Prop 1.6(b) sign | minor | **Genuine. Fixed:** \|a\| > K. |

### Referee B (§§3–4)

| # | Item | Sev. | Verdict and action |
|---|---|---|---|
| B1 | Thm 3.9(c) omits the well-posedness certificate used in its proof | major | **Genuine.** I checked the rope counterexample: an improper child, a vacuously true schema, and a false export. **Fixed.** A parent-derived certificate ω_c is now a hypothesis of (c) and a premise of (Exp) in §2.3, and it appears in Def 5.2 and §0. The schema conclusion is generalized to ε_β(v), which may depend on v and on undeformed data, and Thm 3.7's instance is written out. The proof was rewritten. The Remark (asymptotic) also requires ω_c. |
| B2 | Thm 3.3 (a),(b),(d): C ⊇ C^∞ does not give Lemma 3.2's closure | minor | **Genuine** (C^∞ ∪ {√λ} counterexample, checked). **Fixed.** The hypothesis is now C + C^∞ ⊆ C. The weaker conclusion under C ⊇ C^∞ alone (abstention on smooth Q) is stated, with the counterexample. |
| B3 | Thm 4.6: query count; one-bit argument; thresholds rounded up | minor | **Genuine** (mpmath re-check: 16.17° has e = 5.0008e-3 > τ). **Fixed.** The rule is now lazy bisection with miss ≤ 2^{-k}; the endpoint variant gets 2^{-(k-2)}. The lower bound uses an explicit two-valued adversary. `learn_regions.py` now truncates thresholds downward and verifies them in mpmath interval arithmetic: 7.243°, 16.168°, 22.810°, 49.946°. |
| B4 | `projectile.py` stale; true region a grid artefact | minor | **Genuine. Fixed.** `projectile.py` now uses the (1+x)² bound and reproduces [9.653, 10.483]. Root-finding gives a true region of x ≤ 0.06788, and the text says 0.0679. The closed-form certificate threshold is 0.0260. The ratio of 2.6 stands. |
| B5 | Thm 3.6 hypotheses concern the unknown trajectory | minor | **Genuine. Fixed.** The new Thm 3.6(b) is a tube/bootstrap form with a proof, and every hypothesis concerns the idealized trajectory. "Lipschitz on the set" is made explicit. |
| B6 | Thm 3.8: differentiability; (c) wording | minor | **Genuine. Fixed:** F differentiable on B; "not certified by this first-order budget", with the q² example. |
| B7 | §7.1: Lemma 3.2 / 3.3 / 4.4 unification claimed new | minor | **Accepted.** Moved to "standard results" (IBC adversary argument); the framing is called expository. |
| B8 | Lemma 3.2; Prop 3.4; Thm 3.5; Thm 4.1 | ok | Confirmed. No change. (Thm 3.5(c) already says "modulo constant zero-equivalence".) |
| B9 | Thm 3.7 mathematics | ok | Confirmed. Wording changed to "antiparallel (drag-type) force" in the theorem and in §0. The referee's adversarial bang-bang test (0/400) is cited. |
| B10 | Thm 4.3 | ok | **Fixed** the small omissions: ε̂ = ∞ if k > n; the Mondrian sentence moved out of "Computed". |
| B11 | Thm 4.4 | ok | **Clarified:** "deterministic certifier", the closure form, the a.s. randomized version, and why Lemma 3.2 does not apply verbatim. |
| B12 | Thm 4.5 | ok | **Clarified:** γ > η; the randomized remark assumes sure completeness, with (1−δ−δ′)M otherwise. |
| B13 | Prop 4.7 (Laymon quotation) | ok | Numbers confirmed. The quotation is now flagged as from memory and **unverified**. |

### Referee C (§§5–6)

| # | Item | Sev. | Verdict and action |
|---|---|---|---|
| C1 | Def 5.2 / Thm 5.3: missing Ax-legality, schema-indexing and deformable-list checks; germ roots; asymptotic exports; law catalogue | major | **Genuine.** As written, Def 5.2 accepted Thm 3.9(b)'s attack. **Fixed.** Def 5.2 now checks Ax legality (canonical DEF stipulations, root Ax ∈ Ax_ρ) and schema indexing by the exact declaration, and requires parent-derived σ and ω. The trusted base now includes the law catalogue (T1) and asymptotic schemas, which may be cited only below principal parents (T2). Prop 6.2-type bounds enter as catalogue laws. A germ-root variant is stated. The deformable-parameter list is shown to be unnecessary for soundness, given the other checks; it matters only for (J1). The proof of Thm 5.3 was rewritten. |
| C2 | `sps_checker.py` unsound (accepts 2× answer, etc.) | major | **Genuine.** Reproduced: the original checker ACCEPTS V6–V9. **Fixed.** C1 now forbids free-completion symbols. C3 requires answer ≡ certified form. C4 asserts the hypotheses of Props 6.2/6.3 from root data. V6–V11 were added, and all are rejected. The honest SPS is still accepted with budget 0.0888, and V0–V5 reproduce. §6.4, §0 and §7.4 were updated, and V2/V5 are described as self-declared, with the semantic protections named. |
| C3 | Prop 6.2 lit-domain hypothesis | minor | **Genuine** (checked L=60a, α=30°, r=40a, φ=π). **Fixed.** The hypothesis r ≤ L tan α (or L = ∞) is added, and an image-coverage step was added to the proof. |
| C4 | Prop 6.2 numerical commentary | minor | **Genuine.** I recomputed independently by root-finding on exact σ level sets. Thresholds: 10.5a, 10.4a, 27.6a, 98a; the referee's 27.54a and 98.03a agree to rounding. Conservativeness: 1.1× to 23× at 5%, unbounded as tol → 0. I confirmed the corrected first-order formulas. **Fixed** in the text and in open problem 4. |
| C5 | Prop 6.3 missing hypotheses; "elevation" | minor | **Genuine. Fixed:** ε < 2/√5, σ − Δ/2 > m, δ_s < α_min, α ≤ π/2; "zenith angle" is used throughout. |
| C6 | Thm 5.4(b) implicit hypotheses | minor | **Genuine. Fixed:** restated with μ* ≠ 0, closure under C^∞ perturbations vanishing at μ = 0, and information equal to the μ = 0 slice. Failure cases are noted. |
| C7 | Thm 5.5 imprecisions | minor | **Genuine. Fixed.** Supertruth is now taken over all of W_ρ. The certificate is a root derivation from Ax_ρ, and is automatically completion-invariant by Thm 5.3. A regularity proviso was added, with the lit-domain jump. |
| C8 | Prop 5.6 wording | ok | **Fixed:** "never decreases"; "can refute only (some) over-wide readings". |
| C9 | Prop 6.1 | ok | Confirmed. Added the optional statement that E = 0 off the image and beyond s = L tan α. |
| C10 | §6.4 numbers, `leg_exact.py` | ok | Confirmed. No change. |
| C11 | §7.1 novelty (Prop 5.6; cylinder-mirror formula) | minor | **Accepted.** Prop 5.6 is now called an observation. The exact illuminance formula is marked "not found in sources checked; novelty uncertain (unverified)". |

**Items whose statement or proof changed non-trivially (to re-verify):**
* Thm 2.4(a)–(c) and new Prop 2.7;
* Thm 3.9(c), with the (Exp) rule and canonical Ax in §2.3;
* Def 5.2 / trusted base / Thm 5.3;
* `sps_checker.py` and §6.4;
* Cor 2.6;
* Thm 4.6;
* Lemma 1.8(b);
* Thm 1.9(a),(c)–(e);
* Thm 2.1;
* Thm 3.3;
* Thm 3.6(b);
* Prop 6.2 (hypothesis, proof step 0, numbers) and Prop 6.3;
* Thms 5.4(b) and 5.5.
