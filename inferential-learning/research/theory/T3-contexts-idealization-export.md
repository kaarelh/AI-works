# T3. Contexts, idealization and export: toward a principled checker for physics-olympiad reasoning

*Theory thread T3 of the inferential-learning project. Read `00-brief.md` first. This note builds on `lit/L7` (context-tree calculus, three import regimes, no-free-export, adversarial stipulation), `lit/L9` (germ semantics, the Structured Physics Solution format, worked problems), `lit/L10` (the user's notes, in particular "reductio hygiene" and "verification from truth… wtf is that?"), and on T1 (soundness under search) and T2 (coherence as negative data).*

*Status labels: **[proved]** = full proof here; **[cited]** = known result, source given, **(unverified)** where from memory; **[sketch]**, **[conjecture]**, **[computed]** = numerical check by a script in `theory/T3-checks/`. **TOSU** = "trivial once set up": the content is in the definitions. I try to say plainly which results are TOSU.*

*Scripts (all re-run for this version): `leg_exact.py`, `leg_mc_flux.py`, `sps_checker.py` (worked example and mini-checker); `realizability.py`, `realizability_uninformative.py`, `realizability_sup.py` (Thm 2.4); `learn_regions.py`, `pendulum.py`, `drag_sign.py`, `projectile.py` (Sections 3–4); `hygiene.py` (Thm 1.9).*

---

## 0. Summary

The user wants to *check untrusted physics reasoning*. Such reasoning is "a dance with many clear setups". Some setups are suppositions made for reductio. Some are idealizations that contradict known facts ("air pressure is 0"). Some are underdetermined ("the sun's elevation is not given"). This thread gives a semantics for that dance, a soundness theorem for a checker of it, and impossibility results marking what no checker can do.

1. **Semantics (§1).** Every context denotes a *filter of models drawn from one deformation family* (the "top model" with its parameters).
   * The root is the actual or intended point.
   * A suppositional context SUP(A) refines its parent's filter by ‖A‖.
   * An idealized context DEF is the push-forward of the parent filter along a *declared deformation* of named parameters toward an ideal value. "Limit" semantics uses the principal filter at the ideal point; "germ" semantics uses the punctured neighbourhood filter.

   Truth in a context is classical and never explodes while the filter is proper, even when the stipulations contradict the root or the limit model does not exist (Prop 1.4–1.6). Discharge is exact (Prop 1.5). Import filters are not a free parameter: the *sound* imports are exactly the sentences that are stable under the declared deformation (Lemma 1.8).

2. **Reductio hygiene (§1.4)** [proved]. This is the user's worry made precise.
   * A reductio inside a context whose imported fragment is inconsistent refutes every sentence, both A and ¬A (Thm 1.9b).
   * A *local* "essential use of A" test does not detect this (explicit 3-premise counterexample, Thm 1.9c).
   * A *consistency certificate* for the imported fragment (a model, i.e. a well-posedness witness) does suffice (Thm 1.9d).
   * In approximately-true frameworks, exact-equality reasoning can derive ⊥ from true premises ("100 = 99.9"). ⊥ is a discontinuous functional of the data, while directly derived values are continuous ones. That is the precise sense in which "constructive reasoning is more trustworthy in messy domains" (Prop 1.10).

3. **Coherence (§2).**
   * *Eternalism is impossible* [proved, TOSU]. No translation of "φ holds in idealized context c" into a world sentence that is truth-functional in (stipulations, φ) can track in-context truth. Stripping indices makes correct idealizations incoherent; conditionalizing makes them vacuous (Thm 2.1).
   * *The right constraint is realizability*, and it has an exact characterization [proved; brute-force checked on 4,500 random instances]. A set of context-indexed judgments with bridge uses is coherent iff, after folding suppositional contexts into their parents as conditionals, the root and every **anchored** idealized context are consistent. A context is anchored if it is certified, or exports through an informative bridge into an anchored context (Thm 2.4).
     * Reductio immunity and "well-posedness only for exporting idealizations" are corollaries.
     * The informativeness hypothesis is necessary (117/600 counterexamples without it).
   * *Soundness and blame localization* [proved]. Every root contradiction from a realizable root has an unsound step in its *derivation cone*. Steps outside the cone are never blamed (Thm 2.5, Cor 2.6). This feeds T2's oligarchic-halving learner with the root as the only designated context.

4. **Export (§3).**
   * *No free export* [proved]. One "invisible perturbation" lemma gives four instances. No export rule is sound for any finite tolerance if its information is:
     * the full jet at the idealization (C^∞ families, flat perturbations);
     * the full germ (C^∞ families, bump perturbations);
     * any finite jet, even for entire analytic families;
     * any finite set of samples.

     Sound export needs *information of finite radius* in the sense of information-based complexity (Thm 3.3, Prop 3.4).
   * *Certified-neighbourhood export*, *rate-qualified asymptotic export* and *Gronwall finite-horizon export* [proved] (Thms 3.5–3.6).
   * A *fully rigorous projectile certificate* for any dissipative drag bounded by k|v|² [proved; checked against simulation, 0/300 violations] (Thm 3.7).
   * *Error propagation through chains*, including the "100 = 99.9" catastrophe as an error budget exceeding the claim [proved] (Thm 3.8).
   * *Adversarial stipulation* [proved]. With side conditions evaluated in the child, or with free (non-deformation) stipulations, a solver can export arbitrary false claims. With declared deformations and parent-evaluated side conditions every accepted export is sound (Thm 3.9).

5. **Learning bridge validity (§4).**
   * *Coherence cannot calibrate tolerances* [proved]. If the environment class is closed under common shifts, every coherence-only calibrator is unsound or outputs infinite tolerances (Thm 4.1). Minimal-repair learners drift to ∞ and never restrict a regime: computed on the small-angle bridge, the tolerance grows 1e-3 → 4.4 (Prop 4.2).
   * *Conformal calibration* gives exchangeable coverage (here 0.913 at nominal 0.9) but fails on the adversary's chosen instance (Thm 4.3).
   * *No certification without regularity* (Thm 4.4) is the learning twin of no free export.
   * *A conservative Lipschitz certifier* is deterministically sound against any solver. It is complete at margin γ with ⌈L/(γ−η)⌉^d validated oracle calls, and any sound certifier needs ⌊L/(2γ)⌋^d (Thm 4.5).
   * *A monotone certifier* needs log₂(1/h) calls (Thm 4.6). Monotonicity is a real hypothesis: for the drag-damped pendulum the period shift is non-monotone in the drag, and a monotone certifier would certify a false region (Prop 4.7, computed).

6. **Main theorem (§5).** *Relative soundness of the SPS checker* [proved; TOSU given §§1–3]: for every solver, an accepted SPS's export holds in every admissible world of its reading. The residual **judgment layer** is exactly:
   * (J1) reading containment, W_{ρ*} ⊆ W_ρ;
   * (J2) top-model adequacy, needed only for world claims;
   * (J3) the trusted base (kernel, catalogue, validated numerics).

   (J1) and (J2) are ineliminable (Thm 5.4). *Supervaluational correctness* is the maximal sound criterion under reading uncertainty (Thm 5.5). *Gricean determinacy is one-sided* (Prop 5.6): it refutes over-wide readings and rewards over-narrow ones, so silent narrowing is the solver's natural attack.

   This completes a table of three one-sided signals:

   | Object | Error the free signal catches | Error it misses |
   |---|---|---|
   | rules | over-acceptance (coherence) | under-acceptance |
   | tolerances | too-narrow tolerances (coherence) | too-wide tolerances |
   | readings | too-wide readings (determinacy) | too-narrow readings |

7. **Worked example (§6): EuPhO 2025 T1(a), the polished chair leg** (statement as reconstructed in L9).
   * I derive the *exact* top-model illuminance E = I₀ac/(2s + ac) [proved; matches a 40M-ray Monte Carlo to within ≈1% sampling noise]. It is *exactly* independent of the free sun elevation, so the completion-invariance certificate is exact.
   * I prove a *rigorous thin-leg bridge bound* in (a/r, sin(φ/2)) [proved; 0 violations on 2.5M points] and compose it with a finite-sun bridge.
   * The mini-checker accepts the honest solution on r ∈ [20a, 34a] with certified error ≤ 8.9% (exact error ≤ 2.6% + 0.9%). It rejects five adversarial variants:
     * an overclaimed domain;
     * a child-evaluated side condition;
     * an α-dependent answer (the user's own algebra slip);
     * a silently narrowed reading;
     * a silent import.

**Honest assessment** (§7). Mathematically, almost everything here is TOSU or standard (filters, Łoś, Gronwall, conformal, covering numbers). The contributions are the *definitions* that make the user's informal desiderata into checkable conditions, the exact realizability criterion, the reductio-hygiene counterexample, the unification of no-free-export with no-free-certification, the three-way one-sidedness, and a complete worked checker run with rigorous certificates. The deep, unsolved part is the reading (J1). Here I can only prove that it cannot be eliminated, and say what evidence bears on it.

---

## 1. Contexts: syntax and semantics

### 1.1 Deformation frames, worlds, readings

**Definition 1.1.**
* Let $L$ be a many-sorted first-order language with a sort $\mathbb R$ and **parameter constants** $p_1,\dots,p_n$ of that sort.
* A **deformation frame** is a partial map $\mathfrak M:\Lambda\rightharpoonup\mathrm{Str}(L)$ with $\Lambda\subseteq\overline{\mathbb R}^n$ and $p_i^{\mathfrak M(\lambda)}=\lambda_i$. Its domain $\mathrm{dom}\,\mathfrak M$ is the set of parameter values at which the model exists ("is well-posed").
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
* **DEF(D, λ°, 𝒢):** a *declared deformation*. Here $D\subseteq\{1..n\}$ names the deformed parameters, $\lambda^\circ\in\overline{\mathbb R}^D$ the ideal values, and $\mathcal G$ is a filter on $\overline{\mathbb R}^D$ converging to $\lambda^\circ$ (the *path*). Two cases:
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

Reading (c): an idealized context's theory is what holds in *every* nonstandard model in which the idealized parameter is infinitesimal along the declared path. This gives McCarthy's `ist` a concrete semantics, and it is the precise sense in which Robinson vindicated Leibniz (L6, H5). Th(c) is not complete in general (germs may oscillate). Its incompleteness is the residual underdetermination that the reading must settle.

**Proposition 1.5 (SUP is exact discharge) [proved].** For SUP(A) under $p$: $c\models_w\psi$ iff $p\models_w A\to\psi$. In particular, $c$ is improper iff $p\models_w\neg A$.

*Proof.* $X\in\mathcal F_p\sqcup\|A\|$ iff $X\supseteq F\cap\|A\|$ for some $F\in\mathcal F_p$. Now $\|\psi\|\supseteq F\cap\|A\|$ iff $\|A\to\psi\|=\|A\|^c\cup\|\psi\|\supseteq F$. Take $\psi=\bot$. ∎

**Proposition 1.6 (what idealized contexts may do) [proved; TOSU].**
* (a) *Contradicting the root.* Let DEF deform $p_{\rm atm}$ toward $0$, with limit semantics, in a hydrostatics frame whose laws do not mention phase change. Then $c\models p_{\rm atm}=0$ and $@\models p_{\rm atm}=1.0\times10^5$. Both contexts are proper, and no sentence is both true and false *in one context*.
* (b) *Inconsistent limit, consistent germ.* Take a rope of mass $m_r$ pulled by a force $\Phi\ne0$, with $\mathrm{dom}=\{m_r>0\}$ (at $m_r=0$, $\Phi=m_r a$ has no solution). The limit context is improper, since $\lambda^\circ\notin\mathrm{dom}$ makes $\delta(\{\lambda^*\}\times\{0\})\cap\mathrm{dom}=\emptyset$. The germ context is proper and proves "$a>K$" for every numeral $K$. (Painlevé's rigid-body paradox and L9's uniform gas ball are the same phenomenon.)
* (c) *Norton's distinction.* The limit model's value is the germ's limit iff $Q$ is continuous at $\lambda^\circ$ along $\mathcal G$. Here "the limit model's value is the germ's limit" means: for every open interval $I$, if $Q(\lambda^\circ)\in I$ then the germ context proves $Q\in I$. ("The limit property equals the property of the limit system.") d'Alembert's paradox is the failure case: the potential-flow limit model has drag $0$, while the germ as viscosity $\to0$ has drag bounded away from $0$.

*Proof.* (a) and (b) are by inspection of Def 1.3. For (c): under germ semantics, $Q\in I$ holds iff $Q(\lambda)\in I$ for 𝒢-almost all λ. "Every open $I\ni Q(\lambda^\circ)$ eventually contains $Q(\lambda)$" is the definition of $Q(\lambda)\to Q(\lambda^\circ)$ along 𝒢. ∎

### 1.3 Imports are fixed by the deformation

**Definition 1.7.** A sentence φ is **D-stable** in $w$ if, for all $\lambda,\lambda'\in\mathrm{dom}\,\mathfrak M_w$ that differ only in coordinates in $D$, $\mathfrak M_w(\lambda)\models\varphi\iff\mathfrak M_w(\lambda')\models\varphi$. Two syntactic sufficient conditions:
* φ is a **law** (true on all of dom);
* φ is an arithmetic formula in the parameter constants $p_i$ with $i\notin D$ (**undeformed data**).

**Lemma 1.8 (import soundness) [proved].** If φ is D-stable and $p\models_w\varphi$, then $c\models_w\varphi$ for the DEF child $c$ deforming $D$.

*Proof.* $\|\varphi\|\in\mathcal F_p$. For $\lambda\in\|\varphi\|$ and any μ, $\delta(\lambda,\mu)$ differs from λ only on $D$, so it lies in $\|\varphi\|$ when it lies in dom. Hence $\delta(\|\varphi\|\times G)\cap\mathrm{dom}\subseteq\|\varphi\|$, which puts $\|\varphi\|$ in $\mathcal F_c$. ∎

*Consequence.* L7 treated the import filter $F_c$ as a third learned object. L9 observed that it is "problem-relative" (IPhO 2025 T2 imports vapour pressure into a no-surface-tension context; T3 makes surface tension decisive). Both observations are explained by the fact that **sound imports are exactly what the declared top-model family makes stable**.
* "The vapour pressure of water is 2.3 kPa" is a law or datum of a frame that includes phase equilibrium. It is importable there, and the $p_{\rm atm}\to0$ context then correctly boils.
* In a frame of incompressible hydrostatics without phases it is simply not in the language.

So learning import filters reduces to learning which top-model family the problem intends. That is part of the reading (§5).

### 1.4 Reductio hygiene

The user's warning (L10 §1.8): proofs by contradiction inside a known-inadequate framework "might really involve subverting the background framework… and there's a chance such an argument could equally be provided starting from the statement itself."

**Setting.**
* A context $c$ has an explicit **imported fragment** $K_c$, a finite set of sentences used as premises.
* $\hat R$ is the (learned) rule set.
* A **reductio of A in c** is an $\hat R$-derivation of ⊥ from $K_c\cup\{A\}$, inside SUP(A). Accepting it yields $c\Vdash\neg A$.

**Theorem 1.9 (reductio hygiene) [proved].**
* (a) *Soundness.* If every $\hat R$-instance used is $c$-sound and $c\models K_c$, every accepted reductio yields a true $\neg A$ in $c$.
* (b) *Inconsistent imports refute everything.* If $K_c\vdash_{\hat R}\bot$, then every sentence, including both $A$ and $\neg A$, has a reductio in $c$. The set of reductio-refuted sentences is then independent of the world. A reductio thus carries information about $A$ only *relative to the consistency of $K_c$*.
* (c) *Local essential use is not enough.* Let $K=\{A\to q,\ \neg A\to q,\ \neg q\}$. Then:
  * $K$ is unsatisfiable;
  * the reductio of $A$ uses $\{A\to q,\neg q\}$, which is satisfiable and becomes unsatisfiable only when $A$ is added;
  * the reductio of $\neg A$ uses $\{\neg A\to q,\neg q\}$, which is satisfiable and becomes unsatisfiable only when $\neg A$ is added.

  So both reductios pass every derivation-local test of "essential use of the supposition" (`hygiene.py`).
* (d) *A consistency certificate suffices.* Suppose a model $N\models K_c$ is supplied and $\hat R$ is sound. Then every reductio-refuted $A$ is false in $N$. In particular, no $A$ and $\neg A$ are both refuted.
* (e) *Learning consequence.* A coherence loss that consumes reductio outcomes from uncertified contexts receives the labels "$A$ false" and "$\neg A$ false", which are jointly unsatisfiable, for every $A$. The supervision is world-independent noise.

*Proof.*
* (a) is Thm 2.5 below.
* (b) Derivability is monotone in premises: a derivation of ⊥ from $K_c$ is one from $K_c\cup\{A\}$.
* (c) is by truth tables: from $A\to q$ and $\neg A\to q$, case analysis gives $q$, contradicting $\neg q$; each two-premise subset has the model where $q$ is false and the supposition is false.
* (d) Soundness of $\hat R$ gives $K_c\cup\{A\}\models\bot$, so $N\models\neg A$.
* (e) follows from (b). ∎

So the hygiene condition is a **global** certificate on the imported fragment. In physics, that is a well-posedness witness: an explicit or validated-numerical solution of the local model (L9's SPS demands one for every local model). It is *not* a syntactic relevance condition on the derivation.

**Proposition 1.10 (the continuity asymmetry: why reductio is fragile in approximate frameworks) [proved; Moore cited].**
* Let the premises be equations $x_i=m_i$ that hold only to tolerance, $x_i\in[m_i-r_i,m_i+r_i]$.
* (a) A *direct* derivation that computes $y=g(x)$ for continuous $g$ is wrong by at most the modulus of continuity of $g$ on the box. It degrades gracefully.
* (b) *Exact-equality* reasoning can derive ⊥ from true premises. Take two models' values for the same length, $x=100$ m (flat Earth) and $x=99.9$ m (sphere), both true to ±0.2 m. Exact substitution gives $0=0.1$. The interval reading gives $x\in[99.8,100.1]\neq\emptyset$.
* (c) Sound replacement: a reductio of $A$ in an approximate framework is sound whenever the interval extension of the derived discrepancy excludes 0. That is, the contradiction must have a *margin* exceeding the propagated tolerance. This follows from inclusion monotonicity of interval arithmetic (Moore 1966 [cited]).

The user's suggestion that "constructive" reasoning is more trustworthy in messy domains is thus right in a precise, limited sense. "x = y" defines a closed, typically interior-free set of data values, so ⊥-derivability is a discontinuous function of the data, while derived values are continuous functions of it. The fix is not to give up reductio but to type approximate claims as intervals (this is also the type discipline answering his "100 = 99.9" question, L10 Q11).

---

## 2. Coherence: why eternalism fails, and what to enforce instead

### 2.1 The impossibility of eternalism

**Theorem 2.1 (no truth-functional eternal reading of idealized claims) [proved; TOSU].**
* Let $c$ be a DEF context whose stipulation $S_c$ (e.g. $p_{\rm atm}=0$) is false at the actual point $\mathfrak M_w(\lambda^*_w)$.
* Let $\tau(c,\varphi)$ be any translation of "φ holds in c" into a world sentence whose truth value at $w$ is a function $f(S_c^w,\varphi^w)$ of the truth values of $S_c$ and φ at $w$.

Then $\tau$ does not track in-context truth. There are φ, ψ with $c\models\varphi$, $c\models\neg\psi$, and $\tau(c,\varphi)^w=\tau(c,\psi)^w$. Specifically:
* stripping ($f=\wedge$) makes every in-context claim false at $w$, so it is incoherent with the root;
* conditionalizing ($f=\to$) makes every in-context claim true at $w$, so it is vacuous;
* the remaining choices collapse "in c" into "at w".

*Proof.* Since $S_c^w=0$, the value is $g(\varphi^w)$ with $g=f(0,\cdot):\{0,1\}\to\{0,1\}$. If $g$ is constant, take any φ with $c\models\varphi$ and ψ := ¬φ. Otherwise $g$ is the identity or negation. Take φ true in $c$ and true at $w$ (e.g. "$\rho_{\rm water}=1000$"), and ψ with $c\models\neg\psi$ but ψ true at $w$ (e.g. ψ: "$p_{\rm surface}\neq0$"). Then $g(\varphi^w)=g(\psi^w)$, while $c$ separates them. ∎

**Corollary 2.2 (eternalist coherence penalizes correct reasoning) [proved; TOSU].** Call a coherence check *eternalist* if it flags a judgment set whenever the context-stripped set $\{\bigwedge\Gamma\to\varphi\}$ is unsatisfiable. It flags:
* (i) every sound reductio;
* (ii) every sound idealization whose stipulation contradicts the root (e.g. the $p_{\rm atm}$ pair in Prop 1.6(a));
* (iii) every pair of sound contexts that answer the same query differently (IPhO 2025 T2 vs T3 on gas-phase formation; L9 §8.4).

By T2 Prop 7.1, a *structural* learner that keeps such sets coherent must drop a classical schema *globally*, e.g. become atomically paraconsistent everywhere. And "ANDing the whole framework" assigns probability 0 to every sentence, as the user observed. ∎

The way out is the user's own suggestion made formal: **meta-level eternalism**. `ist(c, φ)` is a context-free proposition about a finitely specified context. By Thm 2.1, it is necessarily *non-truth-functional* in the world's facts, because it depends on the deformation family.

### 2.2 The right constraint: realizability, characterized exactly

**Definition 2.3.**
* A **judgment set** $J$ is a finite set of triples $(c,\Gamma,\varphi)$ over a context tree. Here SUP contexts have only SUP descendants (no idealization inside a supposition; see Remark (iii)). A set $C$ of DEF contexts is **certified**, i.e. claimed well-posed.
* A **bridge use** is $(c,\beta,t)\in U$ with $c$ DEF, together with the judgments $(c,\emptyset,\phi_\beta(t))$, $(\pi c,\emptyset,\sigma_\beta)$, $(\pi c,\emptyset,\varepsilon_\beta(t))$ in $J$.
* β is a **value-export** bridge for a term $Q$ if:
  * $\phi_\beta(v)$ is "$Q=\bar v$" for $v$ in a value set $V$ with standard names (distinct names denote distinct values in every structure);
  * the side condition $\sigma_\beta$ does not depend on $v$.
* β is **informative** if $\{\sigma_\beta\}\cup\{\varepsilon_\beta(v):v\in V\}$ has no model. By compactness, some finite subset then has none. An interval export "$Q_p\in[v-\epsilon,v+\epsilon]$" over unbounded $V$ is informative.
* A **realization** assigns to each context a set $M_c$ of structures such that:
  * (R0) $M_@\neq\emptyset$;
  * (R1) $M_c=M_{\pi c}\cap\|A_c\|$ for SUP;
  * (R2) $M_c$ is arbitrary, possibly empty, for DEF;
  * (R3) each judgment holds, i.e. $\forall N\in M_c\,(N\models\bigwedge\Gamma\Rightarrow N\models\varphi)$;
  * (R4) each used bridge is sound: $\forall v\,[M_c\models\phi_\beta(v)\Rightarrow M_{\pi c}\models\sigma_\beta\to\varepsilon_\beta(v)]$;
  * (R5) $M_c\ne\emptyset$ for $c\in C$.

  Everything below holds verbatim for *filter* realizations (Def 1.3), reading "nonempty" as "proper". The only change is that the anchoring lemma uses the finite unsatisfiable subset given by compactness.
* The **SUP-collapse** $J^*$ replaces each $(c,\Gamma,\varphi)$ with $c$ SUP by $(b,\Gamma\cup\mathrm{Asm}(c),\varphi)$, where $b$ is the nearest non-SUP ancestor and $\mathrm{Asm}(c)$ the suppositions on the path.
* The **anchored set** Anc is the least set of non-SUP contexts that contains $@$ and $C$ and contains $c$ whenever $(c,\beta,t)\in U$, β is informative, and $\pi c\in$ Anc.

**Theorem 2.4 (realizability criterion) [proved; brute-force checked].** Suppose every used bridge is an informative value-export bridge. Then $J$ is realizable iff, for every $c\in$ Anc, $\mathrm{Th}^*(c):=\{\bigwedge\Gamma\to\varphi:(c,\Gamma,\varphi)\in J^*\}$ is satisfiable.

*Proof.* Two preliminary observations.
* By (R1) and induction along SUP chains, $M_c=M_b\cap\bigcap_{A\in\mathrm{Asm}(c)}\|A\|$. Hence $(c,\Gamma,\varphi)$ holds at $M_c$ iff $(b,\Gamma\cup\mathrm{Asm}(c),\varphi)$ holds at $M_b$. So $J$ and $J^*$ impose the same constraints on the non-SUP contexts.
* **Anchoring lemma.** In any realization, $M_c\neq\emptyset$ for every $c\in$ Anc. Induct on the closure:
  * $@$ by (R0), and $C$ by (R5).
  * If $c$ enters via an informative $(c,\beta,t)$ with $M_{\pi c}\ne\emptyset$, and $M_c=\emptyset$, then $M_c\models\phi_\beta(v)$ for *every* $v$. By (R4), $M_{\pi c}\models\sigma_\beta\to\varepsilon_\beta(v)$ for all $v$. By (R3) at $\pi c$, $M_{\pi c}\models\sigma_\beta$. So any $N\in M_{\pi c}$ is a model of $\{\sigma_\beta\}\cup\{\varepsilon_\beta(v)\}_v$, contradicting informativeness.

(⇒) For $c\in$ Anc, any $N\in M_c\neq\emptyset$ satisfies $\mathrm{Th}^*(c)$, by the first observation.

(⇐) Choose a model $N_c\models\mathrm{Th}^*(c)$ for each $c\in$ Anc and set $M_c=\{N_c\}$. Set $M_c=\emptyset$ for non-anchored DEF contexts, and define SUP contexts by (R1). Check each condition:
* (R0) and (R5) hold since $@\in$ Anc and $C\subseteq$ Anc.
* (R3) holds at anchored contexts by the choice of $N_c$ and the first observation. It holds vacuously elsewhere.
* (R4), for a use $(c,\beta,t)$:
  * If $\pi c\notin$ Anc, then $M_{\pi c}=\emptyset$ and (R4) is vacuous.
  * If $\pi c\in$ Anc, then $c\in$ Anc by closure (β is informative). Since "$Q=\bar t$" $\in\mathrm{Th}^*(c)$, we have $Q^{N_c}=t$, so by standard names $M_c\models\phi_\beta(v)$ only for $v=t$. Finally $M_{\pi c}=\{N_{\pi c}\}\models\varepsilon_\beta(t)$, because $(\pi c,\emptyset,\varepsilon_\beta(t))\in J$. ∎

*Checks [computed].*
* `realizability.py`: three contexts, valuations of $(p,Q)$, and all $64^2\times6$ candidate realizations, on 1,500 random instances: 621 realizable, **0 mismatches**.
* `realizability_sup.py` adds a SUP context: 3,000 instances, 1,767 realizable, **0 mismatches** with the collapsed criterion.
* `realizability_uninformative.py`: with uninformative bridges, "$Q\in[a-1,a+1]$" on $Q\in\{0,1,2\}$, the anchored criterion is wrong on **117/600** instances. So the hypothesis is needed.

**Corollaries [proved].**
* (i) *Reductio immunity.* A SUP context that derives ⊥ contributes exactly $\neg\bigwedge\mathrm{Asm}$ to its base. It creates incoherence only if the base already commits to the suppositions, and that is a genuine incoherence of the base.
* (ii) *Well-posedness exactly where it matters.* An idealized context that derives ⊥ is incoherent iff it is anchored, i.e. certified, or exporting informatively into an anchored context. This is L7's Prop 2 ("ill-posed idealizations must not export"), now an iff.
* (iii) *Eternalism is strictly stronger.* It demands satisfiability of the union of all $\mathrm{Th}^*(c)$, which fails on realizable sets (Cor 2.2).

*Remarks.*
* (i) The anchored criterion is local. Each anchored context is checked separately and *no adjunction across contexts* is ever required. That is the structural core of discussive and preservationist logics (L7 §3.2), obtained here as a theorem rather than imposed.
* (ii) The restriction to value-exports is what makes singleton realizations work. For exports of sets of claims, the criterion becomes "anchored contexts consistent *with the export pattern*", which I have not characterized.
* (iii) Idealizations inside suppositions ("suppose the string breaks; then model the bob as free") make anchoring depend on whether the supposition is consistent. That case is open (§7).

### 2.3 The calculus, soundness and blame localization

The rules, adapted from L7 §8.1, are:
* **(Ax)** $c\Vdash\varphi$ for $\varphi\in\mathrm{Ax}(c)$:
  * $\mathrm{Ax}(@)=\mathrm{Ax}_\rho$;
  * $\mathrm{Ax}(\mathrm{SUP}(A))=\{A\}$;
  * $\mathrm{Ax}(\mathrm{DEF})$ is the declared stipulations, each required to be $\mathcal F_c$-true. Examples: "$k=0$" under limit semantics; "$k\le\eta$" under germ semantics.
* **(Step)** From $c\Vdash\varphi_1..\varphi_k$ and an instance $\varphi_1..\varphi_k/\psi$ of $\hat R$, infer $c\Vdash\psi$.
* **(Imp)** From $\pi c\Vdash\varphi$ with $\varphi\in F_c$, infer $c\Vdash\varphi$.
* **(Dis)** For SUP: from $c\Vdash\psi$, infer $\pi c\Vdash A\to\psi$.
* **(Exp)** For DEF: from $c\Vdash\phi_\beta(t)$ and $\pi c\Vdash\sigma_\beta(t)$, infer $\pi c\Vdash\varepsilon_\beta(t)$.

An instance is **sound** if it preserves truth at every $w\in W$:
* Step: $c\models_w\bigwedge\varphi_i\to\psi$. This is *context-relative* validity. Time reversal, for example, is sound in a drag-free DEF context and unsound at the root.
* Imp: $\pi c\models_w\varphi\Rightarrow c\models_w\varphi$.
* Exp: $c\models_w\phi_\beta(t)$ and $\pi c\models_w\sigma_\beta(t)$ imply $\pi c\models_w\varepsilon_\beta(t)$.

**Theorem 2.5 (soundness) [proved].** If every Ax judgment is true and every Step, Imp and Exp instance in a derivation of $c\Vdash\varphi$ is sound, then $c\models_w\varphi$ for all $w\in W$.

*Proof.* Induct on the derivation.
* (Ax) and (Step) hold by hypothesis and filter closure (Prop 1.4a).
* (Imp) and (Exp) hold by soundness of the instance.
* (Dis) holds by Prop 1.5. ∎

**Corollary 2.6 (blame localization) [proved].** Call a context **designated** if it is the root (assuming the reading is non-vacuous: some $w\in W$ makes the root axioms true) or a certified DEF context (its certificate is a witness that it is proper). Suppose $d\Vdash\bot$ is derived by $D$ for a designated $d$. Then the **cone** of $D$ contains an unsound Step, Imp or Exp instance, or a false Ax. The cone is the set of all instances in its derivation tree, including those inside sub-contexts whose conclusions reach $d$ by Dis or Exp.
* Instances outside the cone are never implicated. In particular, a SUP ⊥ that is not discharged into $D$ is never implicated, and neither is any pair of contradictory `ist`-claims.
* An anchored DEF ⊥ propagates along its anchoring chain of informative exports to a designated context. At each link, ex falso gives $\phi_\beta(t)$ for every $t$, and compactness gives finitely many $t_1..t_k$ with $\sigma\wedge\bigwedge_i\varepsilon(t_i)$ unsatisfiable. So its steps lie in the cone of a designated contradiction.

*Proof.* Contrapositive of Thm 2.5 at a world where $d$ is proper, since $\bot$ is true nowhere. The propagation claim is the computation in the second bullet, applied link by link. ∎

So the cone is exactly T2's **negative bag** (Lemma 2.1 there), with the root and the certified contexts as the *only* designated contexts. T2's oligarchic-halving learner then gets at most $\log_2(1/w(h^*))$ detections, with no false alarms as long as the reading is correct. T2 Thm 2.5 prices any false alarms caused by a wrong reading.

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

**Theorem 3.3 (no free export) [proved].** Every rule sound on the stated class abstains at every $\lambda^*>0$ in each of the following cases:
* (a) $\mathcal C\supseteq C^\infty[0,\Lambda]$ and $I$ is the full jet at 0. Use the flat function $f(\lambda)=e^{-1/\lambda^2}$.
* (b) $\mathcal C\supseteq C^\infty$ and $I$ is the germ at 0, or more generally $Q|_S$ for any $S$ whose closure omits $\lambda^*$. Use a $C^\infty$ bump supported in a neighbourhood of $\lambda^*$ disjoint from $S$, with $f(\lambda^*)=1$.
* (c) $\mathcal C$ is the class of restrictions of entire functions and $I$ is the jet up to any finite order $N$. Use $f(\lambda)=\lambda^{N+1}$.
* (d) $\mathcal C\supseteq C^\infty$ and $I$ is any finite set of values $Q(\lambda_1),\dots,Q(\lambda_m)$ with $\lambda^*\notin\{\lambda_j\}$. Use a bump at $\lambda^*$ vanishing at the $\lambda_j$.

*Proof.* In each case $f$ meets Lemma 3.2's hypotheses: $e^{-1/\lambda^2}$ (extended by 0) is $C^\infty$ with all derivatives 0 at 0; bumps are $C^\infty$; $\lambda^{N+1}$ is entire with vanishing $N$-jet. ∎

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

**Theorem 3.6 (Gronwall finite-horizon export) [proved; standard (Gronwall 1919 [cited])].**
* Let $\dot x=f(x)$ (idealized) and $\dot y=f(y)+g(t,y)$ (de-idealized) on $[0,T]$.
* Assume both trajectories stay in a region where $f$ is $L$-Lipschitz, and $|g(t,y(t))|\le\eta$.

Then $|x(t)-y(t)|\le|x_0-y_0|e^{Lt}+\frac\eta L(e^{Lt}-1)$.

*Proof.* Let $u=|x-y|$. Then $u(t)\le u(0)+\int_0^t(Lu+\eta)$. Let $v$ be the right-hand side. Then $v'=Lu+\eta\le Lv+\eta$, so $(e^{-Lt}(v+\eta/L))'\le0$, giving $u\le v\le(u(0)+\eta/L)e^{Lt}-\eta/L$. ∎

The bound grows with the horizon $T$. So *qualitative* long-time claims ("oscillates forever") from structurally unstable idealizations do not export, while finite-horizon quantitative ones do (L7 E3/E8).

**Theorem 3.7 (rigorous projectile certificate) [proved; checked].** A point mass is launched with speed $v_0$ at angle $\theta\in(0,\pi/2)$ under gravity $g$. The neglected force per unit mass is $a_n=-\kappa(t)\,v$ with $0\le\kappa(t)\le k|v(t)|$. This covers quadratic drag with any $C_d\le C_{d,\max}$ and any isotropic dissipative drag dominated by it. Let $x:=kv_0^2/g<1$ and $R_0=v_0^2\sin2\theta/g$. Then the range satisfies
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
* Random $(x\in[0,0.9],\theta)$: **0/300** violations.
* For a 5% tolerance at 45°, the certificate's validity region is $x\le0.0259$; the simulated true region is $x\le0.0673$. The certificate is sound but about 2.6× conservative.

**Theorem 3.8 (error propagation through chains) [proved; TOSU].**
* (a) *Towers.* For a chain $\lambda^\circ=\lambda^{(0)},\dots,\lambda^{(k)}=\lambda^*$ (one deformation per link) with certified $|Q(\lambda^{(i)})-Q(\lambda^{(i-1)})|\le\delta_i$, we get $|Q(\lambda^*)-Q(\lambda^\circ)|\le\sum\delta_i$.
* (b) *Downstream computation.* Suppose the answer is $F(q_1..q_m)$ from exported $q_j$ with $|Q_j-q_j|\le\delta_j$, and $L_j=\sup_B|\partial_jF|$ on the box $B=\prod[q_j\pm\delta_j]$. Then $|F(Q)-F(q)|\le\sum_jL_j\delta_j$.
* (c) *Catastrophe as budget.* If $\sum_jL_j\delta_j\ge|F(q)|$, then not even the sign of $F(Q)$ is certified. For "100 − 99.9" with tolerances 0.2: budget 0.4 > 0.1.

*Proof.* (a) is the triangle inequality. (b) is the mean value theorem on the convex box (which contains both $q$ and $Q$). (c) follows from (b). ∎

The budget makes the user's "100 = 99.9" catastrophe *visible as a typing error* instead of forbidding it by fiat.

### 3.3 Adversarial stipulation

Take a schema of the form "neglect $p_D$": pattern $Q=\bar v$ in the child; side condition $s(\vec p)\le\eta$ for a dimensionless smallness parameter (e.g. $kv_0^2/g$); conclusion $Q\in[v\pm\epsilon]$ in the parent.

**Theorem 3.9 (where side conditions live, and what contexts may be) [proved].**
* (a) *Child-evaluated side conditions are unsound.* Suppose (Exp) accepts $c\Vdash s\le\eta$ in place of $\pi c\Vdash s\le\eta$. Every context with $p_D=0$ satisfies $s=0\le\eta$. The export then fires on any world, including those with $s(\lambda^*)$ huge. On any $C^\infty$-closed class this is unsound for every $\epsilon$ (Thm 3.3b). Concretely: the ping-pong ball receives the drag-free range ±5%, while its true range is 49% short.
* (b) *Free stipulations are unsound even with parent evaluation.* Suppose contexts may stipulate values of *undeclared* parameters. A solver stipulates $p_D=0$ and $g_c=g'$. The parent condition $s(\lambda^*)\le\eta$ is true for the steel ball, and the child's $Q=R_0(g')$ is any desired value. The export is false.
* (c) *Sufficiency.* Suppose:
  * contexts are declared deformations (DEF);
  * side conditions are derived in the parent;
  * the schema is a theorem of the frame: for all $w$, all $\lambda\in\mathrm{dom}$ and all $v$, if $s(\lambda)\le\eta$, the deformed models $\mathfrak M_w(\lambda[D:=\mu])$ exist for 𝒢-almost all μ, and $Q(\mathfrak M_w(\lambda[D:=\mu]))=v$ for 𝒢-almost all μ, then $|Q(\mathfrak M_w(\lambda))-v|\le\epsilon$. ("𝒢-almost all" means on a set in 𝒢. For limit semantics this is just $\mu=\lambda^\circ$. The existence clause is the well-posedness precondition of Thm 2.4, Corollary (ii).)

  Then every accepted export is sound, *for every solver*. Theorem 3.7 is such a schema, with $\eta<1$ and ε read off its bounds.

*Proof.* (a) and (b) are the constructions. For (c): by Lemma 1.8 and Thm 2.5 it suffices that the instance is sound. Suppose $c\models_w Q=\bar v$ and $p\models_w s\le\eta$. Then there are $F_1\in\mathcal F_p$ and $G\in\mathcal G$ with $\delta(F_1\times G)\cap\mathrm{dom}\subseteq\|Q=\bar v\|$. Let $F=F_1\cap\|s\le\eta\|\in\mathcal F_p$. The checker requires each exporting DEF context to carry a well-posedness certificate: a parent filter set $F_0$ on which the deformed models exist along 𝒢 (L9's existence witness). Replace $F$ by $F\cap F_0$. For each λ ∈ F, every deformed model along $G$ has $Q=v$, so the schema gives $|Q(\mathfrak M_w(\lambda))-v|\le\epsilon$. Hence $\|Q\in[v\pm\epsilon]\|\supseteq F\in\mathcal F_p$. ∎

*Remark (asymptotic patterns).* In germ contexts the natural in-context claim is "$Q\simeq v$", i.e. $c\models|Q-v|<\eta'$ for every rational $\eta'>0$ (in Łoś terms, the standard part of $Q$ is $v$), rather than exact equality. The analogous schema has the hypothesis "$Q(\mathfrak M_w(\lambda[D:=\mu]))\to v$ along 𝒢". Its lifting goes through when the parent filter is principal (root or limit-semantics parent), because then every witness set contains the actual point. Under a nested germ parent it additionally needs the convergence to be uniform on a parent filter set, which is a genuine extra side condition.

The pointwise schema lifts to arbitrary parent filters (the proof of (c) never used that $\mathcal F_p$ is principal). So catalogue theorems need to be proved once per frame, not per nesting pattern.

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
* (a) If $e_1..e_{n+1}$ are exchangeable and $\hat\epsilon$ is the $\lceil(n+1)(1-\alpha)\rceil$-th smallest of $e_1..e_n$, then $P(e_{n+1}\le\hat\epsilon)\ge1-\alpha$.
* (b) If the solver chooses the instance after $\hat\epsilon$ is fixed, from a regime where $\sup e>\hat\epsilon$, coverage on the chosen instance is 0.

*Proof.*
* (a) Assume no ties (ties only help). The rank of $e_{n+1}$ among the $n+1$ values is uniform. Then $e_{n+1}>\hat\epsilon$ iff its rank exceeds $k=\lceil(n+1)(1-\alpha)\rceil$, which has probability $(n+1-k)/(n+1)\le\alpha$.
* (b) is immediate. ∎

*Computed.* Small-angle schema, calibrated on $\theta_0\sim U[0°,30°]$ with $n=200$ and α = 0.1: $\hat\epsilon=1.44\times10^{-2}$, and coverage 0.913 on fresh exchangeable draws. The adversary's instance 60° has error $7.3\times10^{-2}$ and is not covered. Mondrian (per-regime) calibration narrows but does not close the gap: within each bin the adversary still picks the worst point.

### 4.2 Sound certification needs regularity, and regularity suffices

**Theorem 4.4 (no certification without regularity) [proved].** Let $\mathcal C$ be closed under adding continuous bumps. Any certifier that makes finitely many oracle queries and outputs a region $V$ with $e\le\tau$ on $V$, soundly on $\mathcal C$, has $V\subseteq\{\text{queried points}\}$.

*Proof.* This is Lemma 3.2 with $I$ = the query answers and $f$ = a bump at an unqueried $\pi\in V$ vanishing at the queries. The queries are adaptive, but on $e$ and $e+Af$ the answers coincide, hence so does the query sequence. ∎

No free export and no free certification are thus *one theorem*. Simulation is an oracle for the top model (L9 TC6), but an oracle without a regularity guarantee certifies only the points it was asked about.

**Theorem 4.5 (conservative Lipschitz certifier: soundness, completeness, sample complexity, lower bound) [proved].**
* Let $\Pi=[0,1]^d$ (after rescaling), and let $e$ be $L$-Lipschitz in $\|\cdot\|_\infty$.
* A *validated oracle* returns $e_{hi}(\pi)\in[e(\pi),e(\pi)+\eta]$, e.g. interval ODE enclosures (Tucker; Immler [cited in L9]).
* Let $G_h$ be the centres of the $\lceil1/h\rceil^d$ cubes of side $\le h$ tiling Π. Output
$$V=\Pi\cap\bigcup_{\pi_j\in G_h}\big\{\pi:\|\pi-\pi_j\|_\infty\le(\tau-e_{hi}(\pi_j))/L\big\}.$$

Then:
* (a) **Soundness.** $e\le\tau$ on $V$, for every $L$-Lipschitz $e$, deterministically. So it holds against any solver choosing π.
* (b) **Completeness.** If $h\le(\gamma-\eta)/L$, then $V\supseteq\{\pi:e(\pi)\le\tau-\gamma\}$. This takes $N=\lceil L/(\gamma-\eta)\rceil^d$ oracle calls.
* (c) **Lower bound.** Every deterministic certifier that is sound on the $L$-Lipschitz class and complete at margin γ makes at least $\lfloor L/(2\gamma')\rfloor^d$ queries for every $\gamma'>\gamma$, even with an exact oracle.

*Proof.*
* (a) For π in the ball around $\pi_j$: $e(\pi)\le e(\pi_j)+L\|\pi-\pi_j\|\le e_{hi}(\pi_j)+(\tau-e_{hi}(\pi_j))=\tau$.
* (b) Let $e(\pi)\le\tau-\gamma$. Its cell centre satisfies $\|\pi-\pi_j\|_\infty\le h/2$, so $e_{hi}(\pi_j)\le e(\pi)+Lh/2+\eta\le\tau-\gamma+Lh/2+\eta$. The radius is then $(\tau-e_{hi}(\pi_j))/L\ge(\gamma-\eta)/L-h/2\ge h/2$.
* (c) Let $e_0\equiv\tau-\gamma$. Completeness forces $V(e_0)=\Pi$. Put $\rho=\gamma'/L$ and pack $M=\lfloor1/(2\rho)\rfloor^d$ disjoint open $\infty$-balls of radius ρ in Π. With fewer than $M$ queries on $e_0$, some ball $B(\pi_0,\rho)$ is unqueried. Define $e_1=e_0+\max(0,\gamma'-L\|\pi-\pi_0\|_\infty)$. It is $L$-Lipschitz, it equals $e_0$ off the ball, and $e_1(\pi_0)>\tau$. All answers agree, so $V(e_1)=\Pi\ni\pi_0$: unsound. ∎

The upper and lower bounds match up to $2^d$ and the oracle slack η. (Randomized certifiers that are sound with probability $1-\delta$ need $(1-\delta)M$ queries in expectation, by the same construction with $\pi_0$ uniform.) This is Piyavskii–Shubert-style covering and the standard $\Omega((L/\gamma)^d)$ barrier for Lipschitz problems (Nemirovsky & Yudin 1983 [cited, unverified details]). *Where does $L$ come from?* It must be **proved** in the top model; an estimate makes soundness conditional.
* *Demonstration (flagged).* For the projectile, an $L$ *estimated* from simulations (0.94 including a 1.2 safety factor) certifies $x\in[0,0.066]$ with 16 oracle calls, against the true region $x\le0.0673$. With a proved $L$ this would be a certificate; with the estimate it is only a calibrated guess.

**Theorem 4.6 (monotone certifier) [proved].** Let $e$ be non-decreasing on $[0,1]$ (no continuity needed), with a validated upper oracle.
* Binary search with $k$ queries outputs $V=[0,\hat\pi]$ with $e_{hi}(\hat\pi)\le\tau$, or $V=\emptyset$ if $e_{hi}(0)>\tau$; it outputs $V=[0,1]$ if $e_{hi}(1)\le\tau$. It is sound.
* With an exact oracle, $V$ misses at most an interval of length $2^{-k}$ of $\{e\le\tau\}$.
* $\lceil\log_2(1/h)\rceil$ queries are necessary for resolution $h$.
* In dimension $d\ge2$ (down-sets), $\Theta(h^{1-d})$ queries are needed and suffice [sketch: an antichain of grid cells must each be probed; a staircase walk achieves it].

*Proof.*
* Soundness: $e(\pi)\le e(\hat\pi)\le e_{hi}(\hat\pi)\le\tau$ for $\pi\le\hat\pi$.
* Binary search keeps $e(lo)\le\tau<e(hi)$ with $hi-lo$ halving. Monotonicity puts $\{e\le\tau\}\subseteq[0,hi)$.
* Lower bound: there are $1/h$ possible thresholds and each query gives one bit. ∎

*Computed (`learn_regions.py`).*
* The small-angle schema has $e(\theta_0)=\frac2\pi K(\sin^2\frac{\theta_0}2)-1$. It is provably increasing, being a power series in $k^2$ with positive coefficients.
* A rigorous enclosure $[k^2/4,\ k^2/4+\frac9{64}k^4/(1-k^2)]$ follows from the decreasing coefficients $c_n=((2n-1)!!/(2n)!!)^2$.
* The monotone certifier then gives:
  * $\theta_0\le7.24°$ for τ = 10⁻³;
  * 16.17° for 5×10⁻³;
  * 22.81° for 10⁻²;
  * 49.95° for 5×10⁻² (exact threshold 50.10°).

  These are fully rigorous.

**Proposition 4.7 (Laymon monotonicity can fail) [computed, `drag_sign.py`].**
* Take a pendulum with quadratic drag β at amplitude 6.75°. The signed relative period shift is −3.0, −5.3, −7.7, −3.9, +10.9, +36.2 (×10⁻⁶) at β = 0.0125, 0.025, 0.05, 0.1, 0.15, 0.2. Amplitude decay shortens the period (through the nonlinearity), and damping lengthens it at second order.
* So $|e|$ is non-monotone in β. With τ = 6×10⁻⁶, a monotone certifier that queries β = 0.1 ($|e|=3.9\times10^{-6}$) certifies $[0,0.1]$, which contains β = 0.05 with $|e|=7.7\times10^{-6}>\tau$.

"Better data, better predictions" (Laymon 1987) is a substantive property of a model–query pair. It is to be proved, not assumed. This is Laymon's own "monotonicity and truth are independent".

---

## 5. The checker and its main theorem

**Definition 5.1 (SPS).** A *Structured Physics Solution* (L9 §7.1, made precise) is a tuple $(\rho,\mathcal T,D,X)$:
* $\rho$ is a reading:
  * the frame class, with parameter roles (given, measured with intervals, free with ranges, deformable);
  * the query $Q$ and its type (dimension and the allowed symbols);
  * the conventions used.
* $\mathcal T$ is a context tree of SUP, DEF and AUX contexts.
* $D$ is a derivation in the calculus of §2.3, whose (Exp) instances cite schemas from a catalogue $\mathcal B$.
* $X$ is the final judgment $@\Vdash Q\in[q-\delta,q+\delta]$, or $Q\sim q$ for germ roots.

**Definition 5.2 (checker).** The checker accepts iff all of the following hold:
* every Step is accepted by the kernel;
* every Imp is a law or undeformed datum (Def 1.7);
* every non-root, non-AUX context is SUP or a DEF over parameters that ρ declares deformable;
* every Exp cites $\beta\in\mathcal B$ with its side condition derived *in the parent*, and its DEF context carries a well-posedness certificate (existence of the deformed models along its path on a parent-certified set);
* every AUX bridge is a kernel-checked theorem;
* $X$ is derived at the root.

All of these checks are deterministic.

**Trusted base.**
* (T1) The kernel is sound for the frame: every accepted instance is valid in every $\mathfrak M_w(\lambda)$.
* (T2) Every $\beta\in\mathcal B$ is a theorem of the frame in the pointwise form of Thm 3.9(c).
* (T3) Validated numerics return correct enclosures.

**Theorem 5.3 (relative soundness of the SPS checker) [proved; TOSU given §§1–3].** Under (T1)–(T3), for every solver whatsoever: if the checker accepts $(\rho,\mathcal T,D,X)$, then $Q^{\mathfrak M_w(\lambda^*_w)}\in[q-\delta,q+\delta]$ for every $w\in W_\rho$. Moreover:
* if the intended reading satisfies $W_{\rho^*}\subseteq W_\rho$ (J1), the export is supertrue for the intended problem;
* if the actual system is in $W_{\rho^*}$ (J2), it is true of the world.

*Proof.* Apply Theorem 2.5, checking each kind of instance:
* Step instances by (T1);
* root axioms because they define $W_\rho$;
* DEF stipulations by the declaration check;
* imports by Lemma 1.8;
* discharges by Prop 1.5;
* exports by Thm 3.9(c) with (T2) and (T3).

The root filter at $w$ is principal at $\lambda^*_w$, so root truth is truth at the actual point. Nothing in the argument depends on how $D$ was produced. ∎

**Theorem 5.4 (the judgment layer is ineliminable) [proved; TOSU].**
* (a) *Reading.* Let $\mathcal R$ be the set of readings that the checker's inputs (problem text, figures, SPS) do not exclude. A checker that is sound for every $\rho^*\in\mathcal R$ can accept $X$ only if $X$ holds on $\bigcup_{\rho\in\mathcal R}W_\rho$.
* (b) *Open world.* Extend the frame by an unmodelled effect with parameter μ, so that $\mathfrak M'(\lambda,0)=\mathfrak M(\lambda)$. By Thm 3.3, unless the checker has information about $\mathfrak M'$ away from μ = 0, every finite-tolerance world claim is unsound for some extension.

*Proof.*
* (a) If $X$ fails at some $w\in W_{\rho_0}$ with $\rho_0\in\mathcal R$, the checker is unsound when $\rho^*=\rho_0$.
* (b) Apply Lemma 3.2 in the μ direction. ∎

**Theorem 5.5 (supervaluational correctness; completion invariance) [proved; TOSU].** Let free parameters $\theta_f$ range over $\Theta_f$.
* "$Q\in[q\pm\delta]$" is supertrue iff $\sup_{\Theta_f}|Q-q|\le\delta$.
* A supertrue answer at precision δ exists iff $\mathrm{osc}_{\Theta_f}Q\le2\delta$.
* A **completion-invariance certificate** is a root derivation of $\forall\theta_f\in\Theta_f\colon Q\in[q\pm\delta]$. Typical forms: $\partial Q/\partial\theta_f=0$ on a connected $\Theta_f$, or a variation bound.
* By Thm 5.4(a), supertruth over $\bigcup\mathcal R$ is the *largest* acceptance criterion that is sound under reading uncertainty. This is the precise answer to "true in the context at hand — wtf is that?": true in every admissible completion of the context.

*Proof.* Immediate from the definitions. ∎

**Proposition 5.6 (Gricean determinacy is one-sided) [proved].** Call ρ *determinate at δ* if $\mathrm{osc}_{W_\rho}Q\le2\delta$.
* If $W_{\rho'}\subseteq W_\rho$, then $\mathrm{osc}_{\rho'}\le\mathrm{osc}_\rho$.
* Hence the assumption "the problem is well-posed" can refute over-wide readings, but never over-narrow ones.
* Every silent narrowing increases determinacy:
  * fixing the sun's elevation;
  * choosing a specular mirror;
  * importing an extra law;
  * the user's "is the finger horizontal?".

  Yet narrowing violates (J1), $W_{\rho^*}\subseteq W_\rho$, which soundness needs.

*Proof.* The supremum over a subset is at most the supremum over the set, and the infimum is at least the infimum. ∎

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
* (c) $E(P)=I_0\,\dfrac{ac}{2s+ac}$ for $s\le L\tan\alpha$, and the total reflected flux is $2aLI\sin\alpha$, equal to the intercepted flux;
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

**Proposition 6.2 (thin-leg bridge, rigorous) [proved; checked on 2.5×10⁶ points].** Let $E_0=\frac{aI_0}2\sigma/r$, $\sigma=|\sin\frac\varphi2|$, $\epsilon=a/r$ and $m=\frac12\arcsin\epsilon$. For $\epsilon<2/\sqrt5$ and $\sigma>m$:
$$1-\frac m\sigma\ \le\ \frac{E}{E_0}\ \le\ \frac{1+m/\sigma}{\sqrt{1-\epsilon^2}-\epsilon/2}.$$

*Proof.*
1. Let $u=s+ac\ge0$. From 6.1(a), $r^2=u^2+a^2\cos^2\frac\psi2$, so $u\in[r\sqrt{1-\epsilon^2},r]$.
2. $\varphi=\psi+\delta$ with $\tan\delta=a\cos\frac\psi2/u$, so $|\sin\delta|\le\epsilon$ and $|\delta|\le\arcsin\epsilon$. Hence $|\sigma-c|\le|\delta|/2\le m$.
3. $E/E_0=(c/\sigma)\cdot2r/(2u-ac)$. The second factor lies in $[1,\ 1/(\sqrt{1-\epsilon^2}-\epsilon/2)]$, since $2u-ac\le2r$ and $2u-ac\ge2r\sqrt{1-\epsilon^2}-a$.
4. The first factor lies in $[1-m/\sigma,1+m/\sigma]$. Multiply. ∎

*Numbers [computed].*
* Equality analysis: at φ = π the exact ratio is $2r/(2r-a)$, i.e. 1.0256 at $r=20a$, against the bound's 1.053.
* Smallest $r$ at which the bound gives 5%: $r\ge21a,\ 31a,\ 44a,\ 111a$ for σ = 1, 0.5, 0.3, 0.1.
* The exact error exceeds 5% only for $r\le10.5a,\ 11a,\ 28.5a,\ 107a$ respectively.

The bound is sound and at worst about 3× conservative in $r$. A sharper certificate, exploiting $|\sigma-c|\lesssim\epsilon(1-\sigma^2)/2\sigma$, would close most of the gap. The export domain is an *annulus* $a\ll r<L\tan\alpha$, away from the shadow-side kink σ → 0: Barenblatt's intermediate asymptotics, with the failure at small $r$ being the ray-optics $1/r$ artefact.

**Proposition 6.3 (finite-sun bridge) [proved].** Let $\Delta=\arcsin(\sin\delta_s/\sin\alpha_{\min})$ and suppose $r\le L\tan(\alpha_{\min}-\delta_s)$. Then the finite-sun illuminance satisfies
$$\frac{E_{\odot}}{E_0}\in\Big[(1-\tfrac{\Delta}{2\sigma})\,\mathrm{lo}(\epsilon,\sigma-\tfrac\Delta2),\ (1+\tfrac{\Delta}{2\sigma})\,\mathrm{hi}(\epsilon,\sigma-\tfrac\Delta2)\Big],$$
with lo and hi the bounds of Prop 6.2.

*Proof.*
1. *Domain.* Each sun direction $d$ has elevation in $[\alpha-\delta_s,\alpha+\delta_s]$. Since $s\le u\le r$, every $P$ with $r\le L\tan(\alpha_{\min}-\delta_s)$ is lit by every direction, for every admissible α.
2. *Convex combination.* By Prop 6.1(d) and rotational symmetry, direction $d$ contributes $G(r,\varphi-\beta_d)\,\cos\alpha_d\,dI(d)$, where $G=E/I_0$ is the α-free geometric factor. The direct illuminance is $I_0=\int\cos\alpha_d\,dI(d)$, so $E_\odot/I_0$ is a convex combination of $G(r,\varphi-\beta)$ over the sun's azimuth spread. This holds for *any* radiance profile over the solar disk, limb darkening included.
3. *Azimuth spread.* By Napier's rule for the right spherical triangle (pole, sun centre, tangent point), the spread is $|\beta|\le\Delta$.
4. *Combine.* Apply Prop 6.2 at φ − β, using $|\sin\frac{\varphi-\beta}2-\sin\frac\varphi2|\le\frac\Delta2$ and the monotonicity of lo and hi in σ. ∎

### 6.4 The checker run

`sps_checker.py` encodes the specification above (with $L=60a$) and runs the checks of Def 5.2. SymPy stands in for a proof kernel; a real system would discharge these in Lean or Isabelle, with interval arithmetic for the bounds. The checks are:
* C0: reading containment against the formal specification;
* C1: answer type (allowed symbols and dimension);
* C2: no silent imports;
* C3: completion invariance over α ∈ [30°, 60°];
* C4: bridge side conditions evaluated at the parent's declared domain, with the composed error budget.

For C4 the bounds are increasing in ε and decreasing in σ, so the worst case is at the corner $(a/r_{\min},\sigma_{\min},\alpha_{\min})$. All admissible α light the disk $r\le60\tan(29.73°)a=34.3a$.

| Submitted SPS | Outcome |
|---|---|
| **Honest**: $E=\frac{aI_0}2\sin\frac\varphi2/r$ on $r\in[20a,34a]$, σ ≥ 0.5, tolerance 10% | **ACCEPT**, certified error ≤ 8.88% (point-sun exact error there ≤ 2.56%; sun term ≤ 0.93%) |
| V0: same, tolerance 5% | REJECT: budget 0.0888 > 0.05. A *completeness* gap of the certificate: the truth is within 5% |
| V1: overclaimed domain $r\ge5a$ | REJECT: budget 0.380 > 0.10 |
| V2: thin-leg side condition evaluated in the child ($a:=0$ there) | REJECT: Thm 3.9(a) |
| V3: answer $\frac{aI_0}{2\cos\alpha}\sin\frac\varphi2/r$ (writing $I$ for $I_0$) | REJECT: not completion-invariant; half-oscillation over α = 0.42 > 0.10 |
| V4: reading narrowed to α = 45° | REJECT by C0, which is possible only because the spec is formal; otherwise this is (J1) |
| V5: silent import "10% Lambertian fraction" | REJECT: undeclared import |

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
  * Lipschitz covering lower bounds;
  * interval inclusion monotonicity.
* **Small but real (new as far as I know):**
  * the reductio-hygiene counterexample showing that derivation-local relevance cannot replace a consistency certificate (Thm 1.9c);
  * the exact realizability criterion with anchoring, and the necessity of informativeness (Thm 2.4);
  * the single invisible-perturbation lemma behind both no-free-export and no-free-certification (Lemma 3.2, Thms 3.3, 4.4);
  * the two-sided necessity in adversarial stipulation (Thm 3.9);
  * the one-sidedness of Gricean determinacy and the three-way table (Prop 5.6);
  * the exact cylinder-mirror illuminance with a rigorous thin-leg certificate, and a complete checker run with adversarial variants (§6).
* **Deep and unsolved:** the reading layer. I proved that it cannot be eliminated (Thm 5.4), that the free signal for it points the wrong way (Prop 5.6), and that supervaluation is the best one can do under reading uncertainty (Thm 5.5). I have no theorem about *learning* readings.

### 7.2 Where this leaves the user's questions

* *"Arguments for P and ¬P in contradictory contexts should not be penalized."* Correct, and Theorem 2.4 says exactly which contexts *must* be consistent: the root, and idealizations that are certified or export informatively.
* *"Verification from truth… but wtf is that?"* A claim is true in the context at hand iff it holds on the context's filter for every admissible completion (Def 1.3, Thm 5.5). Checking it decomposes into kernel steps, stable imports, certified bridges with parent-evaluated side conditions, and a reading. Only the reading is not mechanizable.
* *Reductio in inadequate frameworks.* It is legitimate exactly with a consistency certificate for the imported fragment. With approximate premises it also needs a margin (Thm 1.9, Prop 1.10).
* *"How come we usually avoid catastrophic reasoning [100 = 99.9]?"* Tolerance typing turns it into a visible budget violation (Thm 3.8c).
* *Untrusted solvers.* Soundness holds against all solvers for everything except the reading. The solver's characteristic attack, silent narrowing, is invisible to the internal determinacy signal and to every check that does not compare against a specification (Prop 5.6, Thm 5.4). Hence the strongest recommendation: **have the problem setter supply a formal specification of the admissible completions**, and grade only supertrue claims. With that, the checker is sound relative to the top model alone.

### 7.3 Open problems

1. **Idealization inside supposition.** Extend Thm 2.4 to DEF contexts below SUP contexts, where anchoring depends on the consistency of the supposition.
2. **Non-value exports.** Characterize realizability for bridges exporting sets of claims (e.g. qualitative shape features).
3. **Learning readings.** What positive data identify $W_{\rho^*}$, given that determinacy is one-sided? A natural conjecture is that official solutions together with marking schemes form a tell-tale for readings in a class where each reading is "the minimal completion consistent with the intended solution's imports". This is untested.
4. **Sharper certificates.** Close the 3× gap in Prop 6.2. More generally, obtain *validated exact-error maps* from closed-form or interval-ODE top models, so that certificate incompleteness (V0) disappears.
5. **Proving regularity.** Automate Lipschitz or monotonicity proofs for bridge error functions (Thms 4.5–4.6) in a proof assistant. Without them, simulation-calibrated validity regions are statistical, not sound.
6. **Kelly link (L7 conjecture).** Exports make a world claim verifiable in the limit iff the query is continuous at the true parameters, given shrinking certified neighbourhoods. Thm 3.5(a) gives the "if" direction; Thm 3.3 suggests the "only if".

### 7.4 Suggested experiments

1. **Checker on three problems.** Encode the §6 problem, IPhO 2012 T1-A (fully F after reading) and IPhO 2025 T2 as SPSs in Lean or SymPy with interval arithmetic. Generate adversarial variants with an LLM instructed to "make the checker accept a wrong answer". Measure which attacks succeed: the prediction is reading narrowing only.
2. **Tolerance learning.** For 5–10 catalogue idealizations, compare three calibrators on adversarially chosen test instances: coherence-only (drifts), conformal (fails at the tail), and Lipschitz/monotone certification with proved constants (sound).
3. **Reductio hygiene in learners.** Train a step verifier with a coherence loss that consumes reductios from (a) certified and (b) uncertified contexts. The prediction from Thm 1.9(e) is symmetric label noise and degraded accuracy in (b).
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
