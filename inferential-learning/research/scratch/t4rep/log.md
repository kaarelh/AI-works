## Verification log

Three independent adversarial referees checked this file. Referee A covered §1–§3, referee B covered §4–§5, and referee C covered §6–§7 together with the related claims in §0 and §8. The full reports are in `../verification/T4-informal-math-latent-formalization-verification.md`. Issue numbers below (A1, B1, C1, …) follow the order of each report.

I re-checked every issue by hand, and by computation where that helped:
* A new script, `T4-checks/verification_checks.py`, was added to `run_all.sh`. It covers:
  * V1: Thm 3.4(d), the counterexample, and the revised statement on 2604 random (target, rival) pairs;
  * V2: Thm 5.2(iv) on all sub-supports;
  * V3: the figures after Thm 4.4, and the antichain;
  * V4: $M_{\rm obj}=\mathrm{Ldim}$;
  * V5: Prop 4.6′.
* I re-ran `bag_vs_object_game.py` and `robust_core_and_mdl.py`, and recomputed the Prop 7.3 convex hull.
* I checked the cross-references to T1 (Thms 3.2, 3.9, 4.4, Cor 4.5), T5 (Lemma 3.1, Thms 3.2, 3.5, 4.1, Prop 4.2), L6 (Steiner row) and L8 (TC4).

Numbering is unchanged. Materially changed items are marked "(revised after verification)". There is one new item, Prop 4.6′, and one new open problem, §8 item 6. No reported issue was rejected. Some referee citations and historical claims are from memory; I adopted them with "unverified" flags rather than asserting them.

**Fatal and major issues (all genuine, all fixed).**

| # | item | sev. | verdict | action |
|---|---|---|---|---|
| A1 | Thm 3.4(d) | fatal | **Genuine.** Bounded-gap practice plus complete objects never refute a rival with *strictly weaker* $\models$ on $D^*$ that still contains $\mathrm{St}^g_{h^*}$. The proof broke at "Case 2 is unchanged", which needed ${\models_{h^*}}\subseteq{\models_h}$. Re-checked with V1. The 4-atom chain counterexample survives for $g\le3$ and is refuted at $g=4$. On 2604 random pairs the original statement mismatches the true survivors 527 times and the revised statement 0 times. The original statement mismatches 0 times on the 1545 pairs whose target is step-expressive. | **Statement revised.** Survivors are $S^g=\{h:\mathrm{St}^g_h\supseteq\mathrm{St}^g_{h^*},\ {\models_h}\vert_{D^*}\subseteq{\models_{h^*}}\}$. The accepted relation is still exactly $\mathrm{St}^g_{h^*}$. Meaning is bracketed, $\mathrm{Ch}_{D^*}(\mathrm{St}^g_{h^*})\subseteq{\models_h}\vert_{D^*}\subseteq{\models_{h^*}}$, and the original characterization is recovered under step-expressiveness on $D^*$. Full new proof (practice / objects (both directions) / coherence / conclusion), counterexample and computation recorded. Propagated to: "What (d) says" (two kinds of never-excluded rivals), §0 item 2, §3.5 items 2 and 4(b), Prop 2.8 remark, Prop 3.6, §8 table, open problem 6, experiment 6. |
| A2 | Prop 3.6 | major | **Genuine, both parts.** (1) Nelson's reduction algorithm is for standard parameters only; the $f(x)=Nx$ example is right. (2) By Case 1 of Thm 3.4(d), shorter IST steps *refute* $h_{\rm W}$. The text claimed the opposite. | Restricted to $D_{\rm st}$. Contextual constants are read as standard ($T_{\rm IST}=\mathrm{IST}+\mathrm{st}(c)$), and infinitesimal suppositions are folded into bound variables. $\rho_{\rm W}$ is defined as the reduction output. The proof is completed: reduction, deduction theorem plus transfer, conservativity. The tag is now "proved modulo cited theorems of Nelson". Added that $\rho_{\rm W}$ need not be the textbook ε-δ reading. The granularity bullet is corrected: the data are decisive against $h_{\rm W}$ as a granularity hypothesis, and meaning is unaffected. |
| B1 | Thm 5.2(iv) first bullet; ℓ remark; §0 item 4 | major | **Genuine.** The project's own learner gives POS for {INT, UNI} and SEP for {INT, DIFF}. V2 confirms the exact conditions on all 93 sub-supports (31 × 3 families), with 0 mismatches. I also found that with V in a partial support, POS can tie STRAT and win by ℓ. | The bullets are restated for full supports (DC; DC ∪ {ZR}; DC ∪ {ZR, V}), with exact conditions for sub-supports. The ℓ remark is corrected: only for full supports do two comparisons suffice, and the ordering is flagged as stipulated, so the outcome is ℓ-dependent. The historical reading and §0 are qualified: a purely positive practice selects POS. |
| C1 | Thm 6.2(c), (d); §0 item 5 | major | **Genuine.** It conflated $\mathrm{St}^g$ with $\models$. The ∧-introduction counterexample ($q\Rightarrow q\wedge(q\wedge q)$ at $g=1$) is right. | (c) split into (c1): ⊨-sound ⇒ ⊆ ${\models_{\rm SV}}$; and (c2): $g$-sound ⇒ ⊆ $\mathrm{St}^g_{\rm SV}$, attained. (d) split into (d1): outside ${\models_{\rm SV}}$, removable only by a definition or lemma-incorporation; and (d2): ${\models_{\rm SV}}\setminus\mathrm{St}^g_{\rm SV}$, removable by expansion or library growth. The faulty proof step is identified and corrected. §0 updated. |
| C2 | Prop 6.5 and its interpretation; §0 item 5 | major | **Genuine.** The bounded-repertoire hypothesis was unused, and $A_0\cap{\models_{\rm PA}}$ is undecidable with no gap bound. | Restated in three parts. (a) Derivability: single-sharpening statement with $T,\rho^*$, vague case per σ, "interpolates into a derivation". (b) No gap bound follows, with the PA example proved via decidability of $\mathrm{St}^g$. (c) A bounded gap follows under schema-level selection plus *uniform derivability*, a notion now defined. This is automatic for pure propositional schemas. It fails in PA, shown via Gödel II rather than any proof-length claim; I avoided the referee's "unbounded length" wording because that is Kreisel-conjecture territory. The "three ingredients" are rewritten so that ingredient 3 is an explicit extra hypothesis. Added the caveat that completeness of the surviving calculus does not follow. §0 updated. |

**Minor issues (all genuine, all fixed).**

| # | item | action |
|---|---|---|
| A3 | Lemma 3.3 | (iii) now reads "$y\in D_h$", with its proof written out. The gloss is replaced by exact converses: $\mathcal V_h$ determines $\models_h$ when $\mathcal V_h\neq\emptyset$; coherence of all finite subsets of $D_h$ determines it; a fixed $\mathcal A$ does not. Tagged "standard corollary". The novelty claims in §0 and §8 are adjusted. |
| A4 | Thm 3.4(a)–(c) | Added the hypotheses nonempty domains, consistent $T^*$ and designated contexts in $D^*$, with the empty-ρ counterexample. (b) now cites the closure-level Prop 3.2. (c) names $V^\infty$ and says it is information-theoretic (co-r.e. refutation), in contrast with (d). |
| A5 | Thm 2.5 Remark; §0 item 1 | Rewritten. $W^*$ counts the $\equiv_g$-class: renamings and Prop 3.5 ontological variants. The ≈-class mass matters only for a closure-level verifier. |
| A6 | Thm 2.7 | Only oracle-answered escalations are counted. (c) now says (a) is tight, and (b) is tight up to $O((\ln(1/W^*)+\ln(1/\delta''))/\delta')$ by T1 Cor 4.5 (checked in T1). |
| A7 | Formal model | (1) §1.3 routes larger steps to expansion or noise, and Thm 2.4 now assumes (P) ⊆ $\mathrm{St}^g_{h^*}$. (2) The effectivity assumptions are listed in §1.2. (3) A convention for partial readings is added in §1.4. (4) Membership in $\mathrm{VS}_t$ is decidable, but $V^g_t$ is computable only for finite $\mathcal H$; otherwise use Prop 2.6. |
| A8 | Lemma 2.2 | Domain condition added; unused premises are dropped. Carried into Thm 2.4. |
| A9 | Prop 3.5 | The hypothesis is now "$R$ sound for both, agreement on $\rho(\mathrm{dom}\,\rho)$". The instance uses only bounded axioms. Added why full elementary equivalence fails (the referee's unbounded sentence, checked in outline). |
| A10 | Prop 3.2 | Assumptions (i)–(iv), the closure-level version and an inductive proof are added. |
| A11 / B20 | Prop 2.3 commentary; §2.1 and §5.4 history | Seidel/Stokes wording fixed ("arbitrarily/infinitely slow"); the term "uniform convergence" is attributed to Gudermann and Weierstrass, flagged unverified. Abel's series is named. Frege's way out: Leśniewski 1938 (Sobociński 1949) and Quine 1955, flagged unverified. |
| B2 | Thm 4.3 novelty | Added (c). The object game is the equivalence-query model with improper hypotheses, which is the mistake-bound model, so $M_{\rm obj}=\mathrm{Ldim}$ (Littlestone 1988) [cited]. V4 confirms it on 248 random classes. Halving citations added. §0 and §8 updated. |
| B3 | Thm 4.4(a) | Now $M_{\rm bag}\le\mathrm{el}^*\le\vert\mathcal H\vert-1$, with the one-line argument. |
| B5 | Thm 4.4(c) | Sorites re-indexed: $q_k$ = "a pile of $n-k$ grains is a heap". |
| B6 | Figures after the table; antichain claim | Replaced by the script-reproduced figures 295 / 43 / 195 (V3); "244 / 32" withdrawn. The antichain claim is restricted, with counterexample $\{\{1\},\{0,3\},\{0,4\}\}$ ($M_{\rm bag}=1$, $\mathrm{el}^*=2$, V3). |
| B7 | Thm 4.5 phrasing | Restated as a per-target bound for the learner, then the minimax bound with the uniform prior. |
| B8 | Prop 4.6 proof | Rewritten: object upper bound ("every step not yet refuted"), adversary argument for $M_{\rm obj}\ge k$, and a potential Φ covering all bag cases. The referee's extra product values are recorded as referee computation. |
| B9 | "Settles TC4" | Rephrased: this refutes the Ldim × polylog(r) form and gives an $O(r\log\vert\mathcal H\vert)$ upper bound; an Ldim-only bound is open. Novelty marked uncertain, with a possible lead (unverified). |
| B10 | Conjecture | Restated as $M^{(r)}_{\rm bag}\le r\cdot\mathrm{Ldim}$. **New Prop 4.6′** proves the case $M_{\rm obj}=1$; I checked the proof, and V5 finds 0 violations in 304 pairs. Equality is qualified to $r\le n-1$ and $r\le b-1$. The referee's larger search is recorded as referee computation. |
| B11 | Def 4.2 availability | Object-completeness is now stated relative to ${\models_{h^*}}$ (it fails for $\mathcal H^g$ targets). Bag-availability is explicit. The consequence for silent unsoundness is stated. |
| B12 | "Moral" | Rewritten. Russell's paradox is a size-1 bag; set-theoretic non-selection is about generalization (Thm 5.1(e), 5.2(iii)). |
| B13 | Prop 4.7 | Reworded around a zero-cost selection criterion; the truthful-objects assumption is explicit. |
| B14 | Thm 5.1 | argmin over $c\in\mathcal R$. (d) requires $\ell_1$ convergence (Scheffé), and its proof is made quantitative. |
| B17 | ZR label; ℓ stipulation | ZR relabelled as Zermelo's 1908 subset (the diagonal for $f=\mathrm{id}$). Added a modelling caveat about Cantor's function-parameter diagonal, and flagged the ℓ-dependence. |
| B19 | Incurvati–Murzi consequence (b); §0 | (b) is now restricted to r.e. axiomatizations, and the Δ₂ greedy limit construction is noted (checked). "Under minimal assumptions" restored in §0. |
| B21 | Lemma 4.1 | "New" softened. |
| C3 | Thm 6.2(b) | Oracle-answer hypothesis added. New (b′) proves convergence for finite $\mathcal H$ with complete practice. Effectivity remark added, with the referee's $\Pi_1$ example. (c) carries the data hypotheses of (b). §0 no longer says "learns exactly". |
| C4 | Thm 6.2(a) | Restricted to arguments made of non-noise practice items; the theorem clause requires $T_\sigma$-provable premises. |
| C5 | Thm 6.3 | Domain hypothesis added. The proof is "by definition; completeness makes such $R_\sigma$ exist". Scope: the theorem concerns ⊨, not $\mathrm{St}^g$, and monsters need not be SV-presentable (Abel). §4.3's Lakatos terminology is aligned with §6. |
| C6 | Def 6.1 | Relabelled "(local) supervaluational validity". The global/local distinction is cited, with attributions flagged unverified. |
| C8 | Remark after Prop 6.4 | Restricted to the two precise statements. |
| C9 | Novelty of Prop 6.4 | A "Not new" paragraph cites Adams, Adams–Levine, Suppes, Edgington and Kyburg (unverified). Removed from §0's "real content". |
| C10 | Prop 6.5 statement | Folded into the C2 revision. |
| C11 | Euclid / Steiner | Steiner sentence rewritten: excess Veronese surface for every input, correct count 3264, consistent with L6. Relabelled "an analogy, not a proven instance". ADM completeness is now stated for a restricted class of sequents. |
| C15 | §7 Assessment; §0 item 6 | Cross-cites T5 Lemma 3.1, Thm 3.5, Thm 4.1 and Prop 4.2. Notes that the conjecture holds in the rare-expensive-error regime. "In MDL clothing" → "analogous to". |

**Items reported correct ("ok"); optional suggestions adopted.** A12 Thm 2.4 now states the inherited caveats (A7, A8). A13 Prop 2.6: no change. A14 Prop 2.8: weaker-hypothesis remark added. A15 Prop 3.7: closed-sentence and transport note added. B4 Thm 4.4(b): no change. B15 F1–F6: no change. B16 Thm 5.2(i)–(iii): no change. B18 Prop 5.4: added "exactly $2^{\aleph_0}$", pure logic, and the Extensionality variant (checked: $n=1$ must be excluded). C7 Prop 6.4: domain caveat, links counted, measurability, tightness for every ε ≤ 1/n, and the script's union-bound check described as tautological. C12 Prop 7.1: cross-reference to T5 Thm 3.2. C13 Cor 7.2: conventions made explicit. C14 Prop 7.3: Pareto-dominance remark added; I recomputed the hull ({A,B} is strictly interior, facet margin 0.38).

**Needs re-verification** (statement or proof changed non-trivially):
* Thm 3.4(d), together with the new hypotheses of (a)–(c);
* Prop 3.6;
* Thm 5.2(iv);
* Thm 6.2, i.e. (b′), (c1)/(c2), (d1)/(d2);
* Prop 6.5;
* Prop 4.6, whose proof was rewritten;
* Prop 4.6′, which is new;
* Thm 4.3(c), a new cited claim;
* Prop 3.5, whose hypothesis changed;
* Prop 3.2, whose proof was added.
