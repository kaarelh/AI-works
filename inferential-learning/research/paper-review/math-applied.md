# Review: mathematical correctness of the informal-mathematics and physics sections (lens: math-applied)

Reviewer lens: `paper/sections/informal.tex`, `paper/sections/physics.tex`, `paper/sections/app-informal.tex`, `paper/sections/app-physics.tex`, checked against `research/theory/T3-contexts-idealization-export.md` and `research/theory/T4-informal-math-latent-formalization.md` (including their Verification logs, T3's Def 5.2 checklist, and the round-2 notes in `research/verification/reverification-round2.md`). I also re-ran every script in `research/theory/T3-checks/` and `research/theory/T4-checks/run_all.sh`.

Snapshot: the four lens files were last modified at 03:36 to 03:47 UTC and did not change during the review. `abstract.tex`, `intro.tex`, `philosophy.tex` and `open.tex` were being edited by another process while I worked (06:31 to 06:34 UTC). Several cross-section overclaims I first found had already been fixed by then; they are omitted here. The single remaining one is listed below.

## Summary

The mathematics of both sections holds up. I re-derived every one of the roughly 15 headline results:

- informal: thm:informal:soundness, ville, escalation, identify, objects, paradoxes, bags, prop:informal:products, ldim1, frz, robust, monsters, sorites, emergence;
- physics: thm:physics:eternalism, realizability, framerealizability, soundness, hygiene, nofree, gronwall, projectile, chains, stipulation, relative, judgment, superval, lipschitz, monotone; props legexact, thinleg, finitesun.

Each matches the post-verification statement in T3 or T4, and each proof in the appendices checks line by line. That includes:

- the injectivity case analysis in Prop legexact(b);
- Step 0 of Prop thinleg;
- the Napier and convex-combination step of Prop finitesun;
- the Ldim game argument;
- the bag lower-bound recursion and the potential argument for products;
- the upper-bracket lemma;
- the Ville and escalation supermartingale arguments;
- Nelson's reduction and conservativity steps;
- the Benacerraf transport.

All repairs from the T3 and T4 Verification logs are present in the paper versions.

The real problems sit at the interface between the checker definition and the relative-soundness theorem. Both were flagged as "minor" in the round-2 re-verification and never propagated.

1. **Who supplies the well-posedness certificate ω_c.** The checker only requires ω_c to be *derived in the parent*. Nothing makes ω_c come from the trusted catalogue. A solver can therefore cite ω_c := ⊤. The paper's own rope counterexample (Thm stipulation(c)) then passes every check, and the "for every solver whatsoever" claim of Thm relative fails as literally stated.
2. **Who supplies the reading ρ, and with it Ax_ρ.** Def SPS makes ρ part of the solver's submission. Nothing checks that Ax_ρ holds on W_ρ. A solver can keep W_ρ wide, so that (J1) holds, while putting a narrowing such as α = 45° into Ax_ρ. So "the residual judgment layer is exactly (J1), (J2), (J3)" is incomplete.

Both are easy to repair: take ω from the catalogue entry and ρ from the trusted specification. The fixes are given below.

The rest is minor:

- an imprecise hypothesis in Thm nofree(c);
- loose quantifiers in Thm judgment(b);
- an incomplete case statement in Thm frz(iv), whose computational check covers a condition the theorem never states;
- an expansion overclaim in Thm robust(d2);
- the calculus-relativity of the Gödel-II example in Prop emergence(c);
- several reproducibility details of the "computed" numbers.

## Numerical spot-checks (re-run 2026-10-03)

| Claim in paper | Script / recomputation | Result |
|---|---|---|
| Checker run table (honest budget 0.0888; V0 0.0888>0.05; V1 0.380; V3 half-osc 0.42; V9 ε=0.952; V2, V4, V5, V6–V11 rejected) | `T3-checks/sps_checker.py` | reproduced exactly |
| Lit disc r ≤ 60 tan(29.73°)a = 34.3a | arithmetic | 34.28a ✓ |
| Exact point-sun error on honest domain ≤ 2.56%; sun term ≤ 0.93% | own script (exact inversion of Prop legexact) | 2.564% at r=20a, σ=1; Δ/(2σ)=0.93% ✓ |
| V6 true error ≈ 0.5; V9 true error 0.909 | own script, metric \|E_true/answer−1\| | 0.513; 0.9091 ✓ |
| **V7 true error 0.159** | own script, same metric, honest domain × α∈[30°,60°] | **0.150 (not reproduced; see issue)** |
| Thin-leg bound certifies 5% from r=21a, 31a, 44a, 111a (σ=1, .5, .3, .1) | own root-finding | 21.00a, 30.84a, 44.07a, 110.6a ✓ |
| Exact error >5% only for r≤10.5a, 10.4a, 27.6a, 98a | own root-finding | 10.50a, 10.44a, 27.57a, 98.08a ✓ (but `leg_exact.py` §(6) still prints the superseded 11.0a, 28.5a, 107.1a) |
| Gap factor 2× (σ=1), 3× (0.9), 6× (0.8), 18× (0.7), ~23× and 49× at σ=1/√2 | own script | 2.0, 3.0, 6.3, 18.3; ≥20.9 (5%) and 49.0 (1%) at 1/√2 ✓ |
| 2.5×10⁶ points, 0 violations; 2×10⁶ ray pairs, 0 forward intersections | `leg_exact.py` | 2,524,919 / 0; 0 ✓ |
| 40M-ray MC/exact 0.9997–1.0099 on five bins | `leg_mc_flux.py` | 0.9997, 1.0038, 1.0099, 1.0030, 1.0009 ✓ |
| Projectile: x=0.0276, R∈[9.653,10.483], sim 9.978; ping-pong x=1.42, −49%; 0/300; 5% region 0.0260 certified vs 0.0679 true | `projectile.py`, `learn_regions.py` | ✓ |
| Small-angle certified 7.243°, 16.168°, 22.810°, 49.946° | `learn_regions.py` | ✓ |
| Tolerance drift 0.0077 → 4.4; conformal 0.913, ε̂=1.44e-2, 60° error 7.3e-2 | `learn_regions.py` | ✓ |
| Laymon drag shifts −3.0, −5.3, −7.7, −3.9, +10.9, +36.2 ×10⁻⁶ | `drag_sign.py` | ✓ |
| Realizability: 1,500 / 3,000 / 2,000 instances with 0 mismatches; 117/600 uninformative; 8,000 frame instances, 0 violations, 598 in gap | `realizability*.py` | ✓, but only with non-default arguments (`realizability_deep.py 11 2000`; `realizability_frame.py 7 3000` + `8 5000`). Defaults print N=400 and N=3000. |
| T4: n=6 single culprit 1,2,3,4,5,5; two-of-six 2,4,4,4,4,4; 295 / 43 / 195; V1 2604 / 527 / 0 / 1545; V4 248; V5 304; 519 pairs | `T4-checks/run_all.sh` | ✓ all |
| Experiment G coverage table | `comprehension_toy.py` | ✓ |

## Verified without objection (selected)

**Informal section**

- **thm:informal:soundness.** One structural fact, h* ∈ VS_t, carries the result. The partial-reading convention is handled.
- **thm:informal:ville.** The paper's version is more careful than T4's: practice data i.i.d., independent of the prover. The appendix proof is correct.
  - The supermartingale is Σw(h)Πp_h/p_{h*}, dominated pathwise.
  - Shadow-measurability gives w_t([h*]) = W*/Z_t.
- **thm:informal:escalation.**
  - (a) The elastic-chain argument is correct.
  - (b) Each "yes" multiplies Z by 1−π ≤ 1−δ, and Z ≥ W*.
  - (c) The ratio 2(ln n + ln 1/δ'')/(δ'(1−δ')) checks.
- **thm:informal:identify.**
  - (a)–(d) and the upper-bracket lemma check, in both directions.
  - Example weaker: I checked the chain-extension argument for g ≤ 3, and the claim that g = 4 refutes the rival.
- **thm:informal:objects(c).** M_obj = Ldim via the standard Littlestone tree.
- **thm:informal:paradoxes.**
  - (b) The recursion f(c) = 1+min(f(c−1), [c>r]f(r)) gives min(r, n−1).
  - (c) The chain is coherent under every h_j, and every bag is S.
- **thm:informal:bags.** ln(1+1/r) ≥ 1/(r+1).
- **prop:informal:products.** The potential argument checks.
- **prop:informal:ldim1.** The disjointness characterization of M_obj = 1 checks.
- **thm:informal:frz.** Coverage formulas, F1–F6 and the full-support selections check; the issue below concerns partial supports.
- **prop:informal:continuum.** Exactly 2^ℵ0; the M_A model checks.
- **prop:informal:ist, prop:informal:benacerraf.** Steps 1–3 and the transport check.
- **thm:informal:robust (a)–(c), thm:informal:monsters, prop:informal:sorites.** All check, including tightness for every ε ≤ 1/n with the σ_0 sharpening.
- **prop:informal:emergence (a), (b).** Both check.

**Physics section**

- prop:physics:los, sup, idealized (including the rope germ, |a|>K for μ<|Φ|/max(K,1)), and lem:physics:import (a)–(c).
- **thm:physics:eternalism.** Correct with the properness hypothesis.
- **thm:physics:realizability.** (a) and (b) are proved by the finite-form anchoring lemmas; CE1 and CE2 check.
- **prop:physics:framerealizability.** Correct in both directions.
- **cor:physics:immunity.** Correct, including the frame counterexample for (ii).
- **cor:physics:blame and prop:physics:propagation.** Correct, including the ω_d properness argument.
- **thm:physics:hygiene (a)–(e).** All check.
- **thm:physics:nofree.** All four perturbations check, and so does the √λ counterexample.
- **thm:physics:gronwall.** (a) and the tube bootstrap (b) check.
- **thm:physics:projectile.** Every inequality checks, including R_0 tanθ = 2v_{0y}²/g.
- **thm:physics:chains.**
- **thm:physics:stipulation.**
  - (c) The generator argument checks.
  - The rope counterexample checks.
  - The ε(v,θ) formula is the max of the two bound deviations at x = η; both are monotone in x.
- **thm:physics:lipschitz.** Soundness, completeness and lower bound check.
- **thm:physics:monotone.** The lazy-bisection miss bound is 2^{−k}; ⌈1/h⌉ thresholds fit because (M−1)h < 1.
- **thm:physics:conformal.** The "high index" counting argument handles ties correctly.
- **thm:physics:noreg.** The deterministic and randomized versions both check.
- **thm:physics:superval and prop:physics:gricean.** Both check.
- **prop:physics:legexact (a)–(d).** Including the case analysis for sin 2d > 0, < 0 and = 0.
- **prop:physics:thinleg.** Steps 0–4, and positivity of the denominator iff ε < 2/√5.
- **prop:physics:finitesun.** The paper's added hypothesis α_max + δ_s ≤ π/2 is correct and needed for cos α_d ≥ 0.
- **T3's Def 5.2 checklist versus the paper's Def checker.** Every item is present: Ax legality (root, SUP, canonical DEF stipulations), kernel and laws, schema indexing by the exact declaration with σ_β and ω_c derived in the parent, asymptotic schemas only below principal parents, imports restricted to laws and undeformed data, shape, and AUX bridges. The gaps below concern the *provenance* of ω_c and ρ, not missing checklist items.

## Issues

### Major

**M1. physics.tex, Def checker / Assumption trusted / Thm relative: ω_c can be supplied by the solver.**

- *Where.* Def physics:checker (line ~880, "σ_β and ω_c are derived in the parent"); Assumption physics:trusted (TB2); Thm physics:relative.
- *Problem.* Def calculus defines ω_c *semantically*: for λ ∈ ‖ω_c‖, {μ : λ[D:=μ] ∈ dom} ∈ 𝒢. The checker never verifies that property, and (TB2) does not say that ω comes from the catalogue. T3's (T2) said "with its well-posedness clause"; the paper drops even that.
- *Concrete failure.* Take the rope frame of Prop idealized(b) with a catalogue entry "neglect rope mass", indexed by DEF({m_r}, 0, principal). The entry is a theorem of the frame, vacuously, so (TB2) admits it. A solver:
  - derives a = 0 in the improper child, using frame-valid steps and ex falso;
  - derives m_r ≤ η in the root;
  - cites ω_c := ⊤, trivially derived in the parent.

  Every check of Def checker passes, and the checker accepts |a| ≤ ε while |a| ≥ |Φ|/η. This is exactly the counterexample in Thm stipulation(c).
- *Consequences.* "All checks are deterministic" together with "for every solver whatsoever" is false as written. Round-2 re-verification flagged this ("provenance of omega_c"), and it was not fixed.
- *Fix.*
  - In Def checker, Schema indexing, replace "$\sigma_\beta$ and $\omega_c$ are derived \emph{in the parent}" with: "$\sigma_\beta$ and the well-posedness certificate $\omega_\beta$ \emph{listed in the catalogue entry of $\beta$} are derived \emph{in the parent} (the solver may not choose $\omega_c$)".
  - In (TB2), append: "each catalogue entry carries a well-posedness certificate $\omega_\beta$ for its declaration: for every $w$ and $\lambda\in\tset{\omega_\beta}_w$, $\{\mu:\lambda[D{:=}\mu]\in\dom\fM_w\}\in\fG$".
  - In the proof idea of Thm relative, add "(by (TB2), $\omega_c$ is a genuine certificate)".

**M2. physics.tex, Def SPS / Thm relative / judgment-layer paragraph: the reading ρ, and hence Ax_ρ, comes from the solver and is never checked.**

- *Where.* Def physics:sps; Thm physics:relative; the paragraph "The residual judgment layer is exactly (J1) … (J2) … (J3)".
- *Problem.* Def SPS lists ρ (frame class, parameter roles, query and type, conventions) as part of the solver's tuple. The checker checks only that root axioms lie in Ax_ρ. Def frame(iii) *assumes* that Ax_ρ holds at every w ∈ W_ρ, and nothing checks it.
- *Concrete failure.* A solver declares the full α ∈ [30°, 60°], so W_{ρ*} ⊆ W_ρ and (J1) holds, but places "α = 45°" in Ax_ρ. The checker then accepts α-specific answers that are false at other admissible completions.
- *Further gap.* (TB1) quantifies over w ∈ W_ρ, i.e. over the solver's frame class.
- *Consequences.* The claim that the residual is "exactly" (J1)–(J3) is incomplete. The worked example avoids the problem only because ρ there is the trusted specification and C0 checks against it. Round-2 flagged this too ("solver-supplied reading rho").
- *Fix.*
  - In Def SPS, replace "a reading $\rho$ (the frame class …)" with "a reading $\rho$, which is either the trusted problem specification or is checked against it (C0): $W_\rho$, $Q$, the type and $\Ax_\rho$ must be those of the specification, or $\Ax_\rho$ must be kernel-derivable from the specification's axioms".
  - Add a check "\emph{Reading:} $\rho$ is the trusted specification (or passes C0)" to Def checker.
  - In the judgment-layer paragraph, replace "(J1) \emph{reading containment}, $W_{\rho^*}\subseteq W_\rho$" with "(J1) \emph{reading adequacy}: $\rho$ is a reading ($\Ax_\rho$ holds at every $w\in W_\rho$) and $W_{\rho^*}\subseteq W_\rho$; when $\rho$ is the setter's formal specification, only the second half remains".

**M3. intro.tex line 79: the mis-designation result is overstated.**

- *Problem.* The intro says "Designating 'idealization plus full background' as coherent forces a globally paraconsistent logic (\cref{prop:physics:misdesignation})". The proposition proves global *sub-classicality*: some classical schema used in a refutation of the designated set is not C-valid. It yields atomic paraconsistency only under (b), when the designated set literally contains some α and ¬α. physics.tex's own title ("forces global sub-classicality") and its Reading paragraph state exactly this distinction. In the p_atm example the background typically *derives* p_atm ≠ 0 rather than containing it.
- *Fix.* Replace the sentence with: "Designating ``idealization plus full background'' as coherent forces a learner to drop some classical schema in every context, and to become atomically paraconsistent everywhere if the background states the negated stipulation outright (\cref{prop:physics:misdesignation})."

### Minor

**m1. physics.tex line 594–595, Thm nofree(c): the hypothesis can be misread.**

- *Problem.* "(c) $\mathcal C$ consists of restrictions of entire functions" can be read as "$\mathcal C$ ⊆ entire functions". Under that reading the conclusion is false: a singleton class admits an exact export rule. The proof needs Q + Aλ^{N+1} ∈ 𝒞.
- *Fix.* Replace with "(c) $\mathcal C+\{\text{polynomials}\}\subseteq\mathcal C$ (e.g.\ $\mathcal C$ is the class of all restrictions of entire functions) and $I$ is the jet up to a finite order $N$".

**m2. physics.tex line 930, Thm judgment(b): quantifiers are loose (round-2 flag, not fixed).**

- *Problem.* The perturbed counter-world must share the slice and actual λ* that the checker sees.
- *Fix.* Replace "If the admissible extensions include worlds with actual $\mu^*\neq0$" with "If, for the given slice $\fM'(\cdot,0)$ and actual $\lambda^*$, some admissible extension has actual $\mu^*\neq0$, and the admissible extensions are closed under …".

**m3. physics.tex lines 489–491: the designated contexts are described too broadly, and the theorem reference uses theory-file numbering.**

- *Problem.* The text reads "with the root and the certified contexts as the \emph{only} designated contexts … no false alarms while the reading is correct (T2 Thm~2.2)". Cor blame designates only certified contexts *with a properness witness*. A certified but improper context can produce a false alarm even under a correct reading. Also, "T2 Thm 2.2" is the theory-file numbering, not a paper reference.
- *Fix.* Replace with "with the designated contexts of \cref{cor:physics:blame} (the root, and certified contexts with properness witnesses) as the only designated contexts … no false alarms while the reading and the certifications are correct (\cref{thm:coherence:halving}; false alarms are priced by \cref{thm:coherence:robust})".

**m4. physics.tex lines 429–433, Remark existence: theory-file numbering used for results that have paper labels.**

- *Fix.* Replace "(T6 Thm~4.1, Cor~4.2)" with "(\cref{thm:existence:mcs,cor:existence:contexts})", "(T6 Thm~4.5)" with "(\cref{thm:existence:rules})", and "(T6 Prop~4.7)" with "(\cref{prop:existence:triangle})".

**m5. physics.tex line 192: the claim about limit semantics needs a hypothesis.**

- *Problem.* "Under limit semantics $\fF_c(w)$ is principal or improper" is false for a limit-semantics context below a germ ancestor, whose filter is non-principal.
- *Fix.* Replace with "If $c$ and all its $\DEF$ ancestors use limit semantics, $\fF_c(w)$ is principal or improper".

**m6. physics.tex line 358, Def realization (R4): realizability uses a different bridge soundness from the calculus.**

- *Problem.* (R4), and bridge soundness in Thm realizability(b) and Prop framerealizability, are ω-free. Exp soundness in Def calculus is ω-relative. So realizability does not apply verbatim to judgment sets produced by the calculus (round-2 flag).
- *Fix.* After Thm realizability add: "Bridge soundness here is $\omega$-free. For judgment sets produced by the calculus of \cref{def:physics:calculus}, add $(\pi c,\emptyset,\omega_c)$ to each bridge use and read (R4) as $M_{\pi c}\models\sigma_\beta\wedge\omega_c\to\varepsilon_\beta(v)$; the anchoring arguments go through unchanged."

**m7. physics.tex line 1093, checker table V7: "(true error 0.159)" does not reproduce.**

- *Problem.* Using the metric |E_true/answer − 1| (the one behind V6 ≈ 0.5 and V9 = 0.909), the worst case over r ∈ [20a, 34a], σ ≥ 0.5 and α ∈ [30°, 60°] is 0.150, at r = 20a, σ = 0.5, α = 30°. No script in the repository computes 0.159.
- *Fix.* Replace with "(true error $0.150$)", or state the metric and domain that give 0.159.

**m8. physics.tex line 1048, Prop thinleg numbers: the shipped script prints superseded values.**

- *Problem.* The values 10.5a, 10.4a, 27.6a and 98a are correct; I re-derived them. But `T3-checks/leg_exact.py` §(6) prints the old grid-band values 11.0a, 28.5a and 107.1a, which T3 says it replaced. No script prints the new ones.
- *Fix.* Add "(root-finding on exact $\sigma$ level sets)" after the list. Also update `leg_exact.py` §(6) to root-find; that is a code fix.

**m9. physics.tex lines 395–399: the reported brute-force counts need non-default script arguments.**

- *Problem.* The 2,000-instance deep check and the 8,000-instance frame check are reproduced only by `realizability_deep.py 11 2000` and by `realizability_frame.py 7 3000` plus `realizability_frame.py 8 5000`. The defaults print N = 400 and N = 3,000.
- *Fix.* Add the invocations in a footnote, or change the script defaults.

**m10. physics.tex lines 1073–1076 and 1102–1114, mini-checker description.**

- *Problem.*
  - C4 is said to assert "every hypothesis" of Props thinleg and finitesun. The script checks α_max ≤ π/2, not the paper's α_max + δ_s ≤ π/2; this is harmless at 60°.
  - The prototype accepts tol = NaN, as I confirmed. It also accepts tol = ∞, which is harmless.
- *Fix.*
  - In (C4) add "(the script checks $\alpha_{\max}\le\pi/2$; the stronger $\alpha_{\max}+\delta_s\le\pi/2$ holds trivially here)".
  - In the residual-defects list add "(vi) numeric inputs are not validated: a NaN tolerance is accepted".

**m11. physics.tex line 1179: the variants are not all adversarial.**

- *Problem.* The text says "twelve adversarial variants". V0 is the honest solution with a 5% tolerance (a completeness test) and V10 is labelled a control. T3 counts eleven adversarial variants.
- *Fix.* Replace with "twelve variants (ten attacks, one control and one completeness test)".

**m12. physics.tex line 966: the trusted base is left out.**

- *Problem.* "after which the checker is sound relative to the top model alone" omits the trusted base (J3).
- *Fix.* Replace with "after which the checker is sound relative to the top model and the trusted base (TB1)–(TB3) alone".

**m13. physics.tex line 124: the three problems are not named.**

- *Problem.* "holds in all three problems" never names them.
- *Fix.* Replace with "holds in all three problems analysed there (IPhO 2012 T1-A, EuPhO 2025 T1(a), IPhO 2025 T2)".

**m14. physics.tex line 1125: the stated percentage does not follow from the stated values.**

- *Problem.* "19.8 mJ differs from the exact optimum 20.1 mJ by 1.3%": the rounded values give 1.5%.
- *Fix.* Quote unrounded values, or write "by about 1.5% (1.3% before rounding, L9 §8.3)".

**m15. physics.tex line 543, Prop continuity(a): "errs by at most $g$'s modulus of continuity on $B$" does not say at what radius.**

- *Fix.* Replace with "errs by at most $\sup_{x\in B}|g(x)-g(m)|$, which tends to $0$ with the tolerances by continuity of $g$".

**m16. informal.tex line 353 (with lines 358 and app-informal 235), Thm frz(iv): the third bullet is incomplete, and the check overstates it.**

- *Problem.* For supports containing both ZR and V, the theorem states only the full-support case and one POS example. Yet the proof and experiments.tex say "all 93 sub-supports agree with the stated conditions". In fact V2 tests that family only with w(ZR) > w(V), against the unstated rule "SEP if the support avoids UNI, PAIR, EMP, else Z". (SEP is selected, for example, for {INT, ZR, V}.)
- *Fix.* Replace the third bullet with:

  > "support $\mathrm{DC}\cup\{\mathrm{ZR},\mathrm V\}$: Z iff $w(\mathrm{ZR})>w(\mathrm V)$, ties to STRAT. For $\{\mathrm{ZR},\mathrm V\}\subseteq$ support $\subseteq\mathrm{DC}\cup\{\mathrm{ZR},\mathrm V\}$: if $w(\mathrm{ZR})>w(\mathrm V)$, SEP if the support avoids UNI, PAIR, EMP, else Z; if $w(\mathrm V)>w(\mathrm{ZR})$, POS if it avoids DIFF, EMP, else STRAT (e.g.\ $\{\mathrm{INT},\mathrm{UNI},\mathrm{PAIR},\mathrm{ZR},\mathrm V\}$ gives POS); if $w(\mathrm{ZR})=w(\mathrm V)$, POS if it avoids DIFF, EMP, else SEP if it avoids UNI, PAIR, EMP, else STRAT."

  I checked this rule against the project's own learner (`comprehension_toy.learner`): 32 sub-supports × 5 weight patterns, 160 cases, 0 mismatches.

**m17. informal.tex line 390, Thm robust(d2): the expansion claim is too strong.**

- *Problem.* "expansion or a library lemma removes them". Prop expansion is about a single target and needs step-expressiveness. In the vague case, an expansion must be one chain of steps that are g-short under *all* sharpenings at once, and such a chain may not exist (round-2 flag). The appendix already says "when one exists".
- *Fix.* Replace with "adding the step as a library lemma to every $R_\sigma$ removes them, and so does an expansion into steps of $\Stg{g}{\mathrm{SV}}$ when one exists".

**m18. informal.tex line 423, Prop emergence(c): the PA counterexample depends on the calculus.**

- *Problem.* "a uniform template would yield a $\PA$-proof of $\Con(\PA)$" holds only for calculi whose rules are closed under substituting a fresh variable for the numeral letter, such as a standard Hilbert calculus (the appendix says so). A complete calculus whose decidable library contains ⊢θ(n̄) for every n makes the schema uniformly 1-step derivable (round-2 flag).
- *Fix.* Replace with "fails in general: in a standard Hilbert calculus for $\PA$ (rules closed under substituting a fresh variable for a numeral), ``infer $\theta(\bar n)$'' … has all instances provable, but a uniform template would yield a $\PA$-proof of $\Con(\PA)$; uniform derivability is relative to the calculus and its library."

**m19. experiments.tex line 186: the wrong classes are said to tie.**

- *Problem.* "On the Dedekind–Cantor operations stratification and separation tie". It is STRAT and Z that tie, at coverage 18. SEP covers only 9.
- *Fix.* Replace with "On the Dedekind--Cantor operations stratification (STRAT) and the Zermelo-like class (Z: separation plus elementary sets) tie".

## Notes (no fix requested)

- **Lean coverage.** app-lean.tex lists Lean coverage for several physics and informal results, as special cases. That is outside this lens.
- **Reproducibility of `T3-checks/realizability_frame.py`.** The script's seeds and counts are reproducible, and the per-seed results add up to the paper's totals, 2,734 frame-realizable and 598 in the gap.
- **V5 message mismatch.** The mini-checker's V5 output says "silent/undeclared imports" while the paper says "declared extra import". This is a script message only; the outcome is the same.
