# Math-core review: setting, search, caution, imitation, coherence

Reviewer lens: are the core formal sections mathematically correct? Files checked line by line:

* `paper/sections/{setting,search,caution,imitation,coherence}.tex`
* the appendices `app-{setting,search,caution,imitation,coherence}.tex`

They were checked against these sources:

* `research/theory/T1-soundness-under-search.md` and `T2-coherence-as-negative-data.md`, including their Verification logs;
* `research/lit/L3-…` (Lemma A, Thm D, Thm D′);
* `research/verification/T1-…`, `T2-…` and `reverification-round2.md` (verify-A);
* `lean/InfLearn/*.lean` and `lean/README.md`, the fidelity column.

## 1. Verdicts on the key results

Every statement below was re-derived by hand, with its appendix proof checked step by step. "OK" means the statement and proof are correct and match the repaired source.

| result (paper label, number in current build) | source | verdict |
|---|---|---|
| `lem:setting:closure`, `lem:setting:rank`, `lem:setting:recover`, `lem:setting:guard`, `lem:setting:WS` | T1 §1, T7 §1.3 | OK. Rank-lemma summand bound and renaming characterization checked. Recovery lemma: the column argument is correct (n=1 forces σ ground; the (D) case is via equal-tuple metavariables). |
| `lem:search:stepwise` (3.1) | T1 L1.1 | OK. The Lean tag `Cl_subset_Cl_iff_subset_Sound` (Steps.lean:147) is exactly this statement. |
| `thm:search:tonk` (3.2), `cor:search:pac` | T1 Thm 2.1, Cor 2.2 (repaired) | OK. The step count is j+2. Disjointness of the T_j is correct. In the tail bound, N_ε ≥ 2 is handled. The sample-complexity arithmetic (1−ε/2)^m ≤ e^{−mε/2} ≤ δ/2 is correct. |
| `prop:search:post`, `lem:search:purify`, `cor:search:purify` | T1 Prop 2.3 + repair | OK. The purification proof checks: renaming ρ, then the simultaneous σ, with σ(A′_s)=A_s. This uses the per-atom reading, which the paper states. |
| `lem:search:commitment` | L3 Lemma A (repaired) | OK. (iii): the conditional Schwartz–Zippel step and the Σ d/\|S_k\| ≤ δ choice are correct. Both counterexamples (F_{2^k}, freshman's dream mod p) check. |
| `thm:search:doctrinal` | T2 Thm 2.4 | OK. The membership table was re-derived. |
| `thm:caution:vs` (4.2) | T1 Thm 3.1 (joint form) | OK. The coupling lemma is correct, and so is the reckless-verifier counterexample. Lean: (a) `thm_3_1_a`; (c) `thm_3_1_b`, deterministic. Both match. |
| `thm:caution:esc` (4.4) | T1 Thm 3.2 (repaired proof) | OK. |
| `prop:caution:closure`, `lem:caution:h1`, `thm:caution:single`, `prop:caution:bell`, `thm:caution:tagged`, `thm:caution:untagged`, `prop:app:caution:conj23` | T1 §3 | OK, except for one degenerate case of `thm:caution:single`(ii) and `thm:caution:tagged` (issue 2). Re-checked: the Bell refinement ordering, the factorization, the Ramsey recursion g(d) ≤ 1+k·g(d−1), pattern counting (linear and repeated), and the (2,3) case of the conjecture. |
| `thm:caution:ville` (4.15), `thm:caution:bayesdet`, `prop:caution:tight`, `thm:caution:bayesesc`, `cor:caution:bayesopt`, `cor:caution:structbayes` | T1 §4 (repaired) | OK. Supermartingale and Ville step checked. In (b) the pathwise bound Z ≤ Z^H holds. Tightness numbers recomputed: t\*=90 gives 0.9889δ′; t\*=299 gives 0.9907δ′; t\*=7 gives 0.781δ′. In the escalation factors, the update Z_u = Z_{u−1}·Σ w_{u−1}(R)·1[…] checks. |
| `lem:imitation:cautious`, `thm:imitation:anchor`, `prop:imitation:telltale`, `prop:imitation:elastic` | T1 Thm 5.1, Prop 5.2 (repaired) | OK |
| `thm:imitation:coupon` (5.7) | T1 Thm 5.3 | OK. The split argument F(G)^n+(1−F(G))^n ≤ 2(1−ρ)^n is correct. The binomial average gives (1−π_iρ_i)^N, the ground-rule convention holds, and the necessity proof is correct. |
| `thm:imitation:untagged`, `prop:imitation:diversity`, `thm:imitation:trimmed`, `thm:imitation:iidnoise`, `lem:imitation:split`, `cor:imitation:necessity`, `thm:imitation:indist` | T1 §5–6 (repaired) | OK. The VC computation checks (φ(d_i)>0 iff 16k²M′ > 2kL+1). So do the Hoeffding margins, the per-tag counterexamples and the tight constant 2. |
| `cor:imitation:systematic` (5.20) | T1 Cor 6.5 | OK. Q(R′\R\*) = α·Q_err(inst τ \ R\*) ≤ α, so Thm `indist` applies. |
| `lem:coherence:bag`, `thm:coherence:halving` (6.5), `prop:coherence:oligarchy`, `thm:coherence:robust`, `prop:coherence:tradeoff` | T2 §2 (repaired) | OK. Continuity-from-above proof checked. The adaptive-adversary detail (target chosen at the end) is handled. One parenthetical has a scope issue (issue 10). |
| `thm:coherence:silent`, `prop:coherence:chains`, `cor:coherence:limitpoints`, `prop:coherence:informant` | T2 §2.5 | OK |
| `thm:coherence:post` (6.13), `prop:coherence:almost` | T2 Thm 3.1, Prop 3.2 | OK. The {→} induction and the lattice-term case analysis check. |
| `thm:coherence:cpc` (6.15) | T2 Thm 3.3 | Statement OK. The explicit finite basis in the appendix is incomplete for the paper's own language, which has ⊥ and ⊤ (issue 1). The Θ\* countermodel and the "renaming is not enough" operator check. |
| `prop:coherence:adm`, `thm:coherence:ipc`, `prop:coherence:complete` | T2 Props 3.4–3.5, Thm 3.6, Prop 3.11 | OK. The Jankov chain, the ∃-elimination induction, and the cubic (disc 229, roots −2.115, 0.254, 1.861, ℚ(r) not normal) check. One "open" remark is stale (issue 5). |
| `thm:coherence:turing`, `thm:coherence:popper` (6.22), `thm:coherence:trilemma`, `prop:coherence:costs` | T2 Thms 3.8–3.10, L3 Thm D/D′ | OK. The Σ₂ weak-coherence construction was re-checked (false σ: P_t=0 at every witness change; true σ: competitors' ages fall below). |
| `lem:coherence:duality`, `thm:coherence:carnap` (6.27), `thm:coherence:rank` | T2 Lemma 4.1, Thms 4.2–4.3 | OK. One table caption has the wrong quantifier (issue 3). |
| `thm:coherence:telltale` (6.29), `prop:coherence:compositional` | T2 Thm 4.4, Prop 4.5 | (a)–(c) OK. The headline of (d) is broader than its proof (issue 4). The matrix row-by-row argument checks. |
| `prop:coherence:tonk`, `prop:coherence:conservativity`, `thm:coherence:complexity` | T2 §5 | OK |
| `thm:coherence:elimination`, `cor:coherence:fallacies`, `ex:coherence:survivors`, `thm:coherence:residue` (6.38) | T2 §6 | Mostly OK. The fallacy witnesses were re-evaluated and are all correct, and (ii) is equality with a sound σ_v proof. Two imprecisions flagged at round 2 survive: issues 6 and 7. |
| `rem:coherence:consensus`, `lem:coherence:projection` | L11, L3 Lemma E′ | OK. The ratio is ≤ 1/(πb). The example values 2.0, 0.52 and 0.5 check. |

No fatal error was found. The core theorems are correct as stated and proved. The issues below are a real gap in an explicit basis, one false degenerate-case bound, a few overclaims or scope slips (several were flagged by the round-2 re-verification but not carried into the paper), and Lean-tag bookkeeping.

## 2. Lean tags in these sections

Every `\leanok{…}` name in the five sections is a real declaration with a matching module. Checked by grep in `lean/InfLearn`:

* Steps: `Cl_subset_Cl_iff_subset_Sound`.
* StepSoundness: `thm_3_1_a`, `thm_3_1_b`, `thm_3_1_a_static`, `thm_3_1_b_static`.
* CoherenceGames: `negative_bag`, `thm_2_2`, `prop_2_3`, `thm_2_5`.
* PostCompleteness: `Post.eq_Cn2_or_eq_trivial`, `Post.impFrag_postComplete`, `Post.versionSpace_eq_singleton_iff`, `Post.learner_identifies`, `Post.le_Cn2_of_empty_eq_Taut`.
* Carnap: `Val_mrel`, `lemma_4_1_b`, `intClosure_BV_eq`, `carnap_single`, `denialRank_eq_two_iff`, `structural_eq_BV`, `BV_not_BC_learnable`.

The unqualified names are currently unique across modules. Scope mismatches with the README fidelity column:

* `prop:coherence:adm`. The tag `Post.le_Cn2_of_empty_eq_Taut` sits after part (c), the IPC part. Lean proves only the maximality half of (b): a structural C with C(∅)=Taut is ≤ Cn₂. The README marks this "special case". The proposition is missing from `tab:lean:map` (issue 11).
* `lem:imitation:cautious` is tagged in the text but has no row in `tab:lean:map` (issue 12).
* `lem:coherence:bag`. Lean covers (a) and (b) (`negative_bag`, `refuted_of_superset`) but not (c). The table nevertheless says "exact".
* `thm:coherence:robust`. The tag has no "(finite classes)" qualifier, although the README and the table say "special case (finite)".
* `thm:coherence:post`. The tag names only the full-language theorem. The statement covers every fragment with ¬ and one of ∧, ∨, →, which is `Post.frag_postComplete_neg` (issue 13).
* `thm:coherence:cpc`. The tags are fine. The "finite D suffices" clause is not formalized, and `tab:lean:map` says so.

## 3. Issues

### Issue 1 (major): the explicit finite basis for Thm 6.15(a) is incomplete in the paper's language

* **File:** `app-coherence.tex`, paragraph "Explicit finite bases" in the proof of `thm:coherence:cpc`. Also the parenthetical in `coherence.tex`, Thm 6.15(a).
* **Problem:** The paper's formulas include the constants ⊥ and ⊤ (`setting.tex` §2.1; also the Lean language), and the coherence datum is A₀ ⊬_h ⊥. The displayed basis is Łukasiewicz axioms, the ∧/∨ →-axioms and modus ponens. It has no axiom involving ⊥ or ⊤, so ⊥ behaves as an unsubstitutable atom. Then ⊢¬⊥, ⊢⊤ and ⊢⊥→p are not in ⟨D⟩, and the conclusion "Hence ⟨D⟩ = Cn₂" is false for the paper's language. The round-2 re-verification flagged exactly this ("Thm 3.3(a), revised example basis … (1)"). It was not repaired, and the clause is not formalized in Lean.
* **Fix:** After "…$\step(p\to r)\to((q\to r)\to(p\vee q\to r))$." insert: "If $\bot$ or $\top$ is a primitive constant, add the axioms $\step\neg\bot$, resp. $\step\top$. With the third axiom and $K$ these give $\step\bot\to p$." In the next paragraph extend the list of facts used by Kalmár's lemma with "$\vdash\neg\bot$ and $\vdash\top$ (base cases for the constants)". In `coherence.tex` Thm 6.15(a), change "(with $\to$ in the language, Hilbert-style bases with modus ponens as the only rule; …)" to "(with $\to$ in the language, Hilbert-style bases with modus ponens as the only rule, plus $\step\neg\bot$ and $\step\top$ when these constants are primitive; …)".

### Issue 2 (minor): the bound in Thm 4.7(ii) and Thm 4.9 is false in a degenerate case

* **File:** `caution.tex`, `thm:caution:single`(ii) and the second case of the display in `thm:caution:tagged`. The same issue is in `app-caution.tex`, proof of (ii).
* **Problem:** Suppose σ\* has no instance of size ≤ N, for example a ground σ\* with |σ\*| = N+5. Then no chain elements exist and el = 0. The right-hand side 1+N−μ(σ\*) is negative, so the stated inequality is false. The proof assumes m ≥ 1. The round-2 re-verification noted this as the "degenerate case" of T1 Thm 3.4.
* **Fix:** In (ii) write $\el(H_1,\sigma^*\mid\emptyset;N)\le\max\{0,\,1+N-\mu(\sigma^*)\}$ (the second term applies when σ\* has an instance of size ≤ N). In `thm:caution:tagged` replace "$1+N-\mu(\sigma^*_i)$" by "$\max\{0,1+N-\mu(\sigma^*_i)\}$". In the appendix proof of (ii) add "(if no instance of $\sigma^*$ has size $\le N$, then $m=0$)". The conclusions Esc ≤ N+1 and ≤ k(N+1) are unaffected.

### Issue 3 (minor): the caption of Table 6 states the wrong quantifier

* **File:** `coherence.tex`, caption of `tab:coherence:rank`.
* **Problem:** "they exclude only meanings realizing no certified position" is false. A certification of ⟨A∣D⟩ excludes every meaning that fails to realize that particular position, so a meaning is excluded as soon as it misses some certified position. Example: certifying ⟨χ,¬χ∣ ⟩ excludes BV, which realizes many other positions. This was flagged in round-2 verify-A (T2 "Section 4.2 reading, item (i)").
* **Fix:** Replace the second sentence of the caption with: "Coherence \emph{certifications} are positive data about meanings: certifying $\pos AD$ excludes exactly the meanings that do not realize $\pos AD$ (for the empty position, only $V=\emptyset$), and adding $\valtop$ to a meaning never makes it fail a certification."

### Issue 4 (minor): the headline of Thm 6.29(d) is broader than its proof

* **File:** `coherence.tex`, `thm:coherence:telltale`(d). Also the "Non-learnability" paragraph in `app-coherence.tex`.
* **Problem:** The proof covers text plus the single datum ⟨ ∣ ⟩, which every member realizes, and Lean proves the same for text. With target-dependent certifications of all in-bounds positions, text plus certifications is an informant (cf. `prop:coherence:informant`). Then ⟨χ,¬χ∣ ⟩ separates BV ∪ {v′_χ} from BV, and the class {BV} ∪ {BV ∪ {v′_χ}} becomes identifiable. "Not identifiable in the limit at all" therefore overclaims. This was flagged in round-2 verify-A (T2 "Thm 4.4(d)").
* **Fix:** Replace "Without structurality $\BV$ is not identifiable in the limit at all, even with the coherence datum:" with "Without structurality $\BV$ is not identifiable in the limit from text plus the coherence datum $\pos{\ }{\ }$, or any other target-independent certifications:". Append: "(If every target-certified position is supplied, text plus certifications is an informant, as in \Cref{prop:coherence:informant}, and this obstruction disappears.)"

### Issue 5 (minor): the RCF question called "open" is settled negatively

* **File:** `coherence.tex`, Reading after `prop:coherence:complete`.
* **Problem:** The text says "(Whether a fixed finite family of contexts suffices for RCF is open." Round-2 re-verification (T2 Prop 3.11(c)) notes that a short argument settles it negatively. Sketch: let 𝒜 be a finite family of consistent contexts. Each A ∈ 𝒜 defines a semialgebraic set over ℚ. Every connected component of that set contains a point with real algebraic coordinates of degree ≤ D(𝒜). A term t with A ⊢ f(t)=0 is constant on components, so its root value has degree ≤ D′(𝒜). Take the rule $t^{d}=2\step t>0$ with d even and larger than D′(𝒜). By Eisenstein, the root has degree d, so the rule never fires in a designated context or from ∅. Its parameter-structural closure is therefore 𝒜-coherent, yet unsound, since $c=-2^{1/d}$ refutes it.
* **Fix:** Replace "(Whether a fixed finite family of contexts suffices for $\RCF$ is open." with "(No fixed finite family of contexts suffices: the rule $t^{d}=1+1\step t>0$ with $d$ even and large enough never fires in any context of the family, because points of semialgebraic sets defined over $\mathbb Q$ have algebraic coordinates of bounded degree, so it is coherent on the family but unsound; this observation is due to the second-round referee.)". Alternatively, delete the sentence.

### Issue 6 (minor): Thm 6.38(iii) conflicts with r.e. hypotheses and overclaims "cannot be discriminated"

* **File:** `coherence.tex`, `thm:coherence:residue`(iii). Also `app-coherence.tex`, proof of (iii).
* **Problem 1:** §6.3 fixes "Hypotheses are r.e. theories T ⊇ PA", but (iii) lists "PA+¬Con(PA) and its non-standard completions". Those completions are not r.e.
* **Problem 2:** "the sound T_k … remain, and cannot be discriminated" overstates `thm:coherence:turing`. Any two T_j ≠ T_k are separated by text, since Con(T_k) eventually appears for T_j with j > k. What fails is identification of the chain together with T_ω. Both points were flagged in round-2 verify-A (T2 "Thm 6.4(iii)").
* **Fix:** Replace the item with: "$\mathcal G$ deductive closure, $\hstar=\PA$, $\Ac=\{\emptyset\}$: $\Alt$ is the set of all consistent closed extensions of $\PA$ (the r.e. ones, if hypotheses are r.e.), e.g. $\PA+\neg\Con(\PA)$, whose completions (not r.e.) have only non-standard models. Designating all finite sets of true sentences removes exactly the unsound ones; the sound $T_k$ of \Cref{thm:coherence:turing} remain, and by that theorem no learner identifies them together with $T_\omega$ from text plus true-context coherence." Make the matching change in the last sentence of the appendix proof of (iii).

### Issue 7 (minor): Ex. 6.36(4), the claim about Clark's completion needs a qualifier

* **File:** `coherence.tex`, `ex:coherence:survivors`(4), last sentence.
* **Problem:** "The per-law converse is not Clark's completion, which is consistent there" holds only if rain and sprinkler are abducibles, so that only wet is completed. Clark's full completion also makes the clause-less predicates false, ¬rain and ¬sprinkler, and that is inconsistent with A = {wet}. This was flagged in round-2 verify-A (T2 "Section 6 example 4").
* **Fix:** Replace it with "The per-law converse is not Clark's completion \citep{clark1978negation}: completing only the head $\mathit{wet}$ (with $\mathit{rain},\mathit{sprinkler}$ abducible) gives $\mathit{wet}\leftrightarrow\mathit{rain}\vee\mathit{sprinkler}$, which is consistent there."

### Issue 8 (minor): an unsupported "testable prediction"

* **File:** `coherence.tex`, Reading after Table 6 (≈ line 312).
* **Problem:** `thm:coherence:carnap` and `thm:coherence:rank` show that imitation plus a coherence loss does not exclude gappy valuations ("provably free to settle on"). They give no reason to expect that training yields such reasoners. "Yields" is an overclaim a careful reader would object to.
* **Fix:** Replace "A testable prediction for language-model training: imitation plus a contradiction penalty yields consistent but noncommittal reasoners." with "A testable question for language-model training: imitation plus a contradiction penalty does not rule out consistent but noncommittal reasoners; whether training drifts toward them is empirical."

### Issue 9 (minor): §3.3 drops the complete-calculus hypothesis in its heading and first sentence

* **File:** `search.tex`, `\subsection` title of `sec:search:post` and its first paragraph.
* **Problem:** The heading "every unsound pure schema trivializes" and the sentence "In classical propositional logic it always does, provided it mentions no specific atom" drop the hypothesis that the schema is added to a complete calculus R\*_CPC. A pure schema alone can be unsound without trivializing: T_j alone has empty closure from ∅ (Remark `rem:app:search:pac`). This was flagged in round-2 verify-A (T1 "Prop 2.3 gloss").
* **Fix:** Retitle to "In classical propositional logic, every unsound pure schema added to a complete calculus trivializes". Change the sentence to "In classical propositional logic it always does once it is added to a complete calculus, provided it mentions no specific atom."

### Issue 10 (minor): a parenthetical in the proof of Prop 6.8(b) needs the worst-case hypothesis

* **File:** `app-coherence.tex`, proof of `prop:coherence:tradeoff`(b), final parenthetical sentence.
* **Problem:** "Equivalently, by \cref{prop:coherence:oligarchy}, detection-halving needs R̂ ⊆ h_i ∩ h_j" holds only under that proposition's worst-case hypothesis, that every finite P ⊆ R̂ with P ⊄ ∩VS is a possible detection. Part (b) itself is proved with a genuine ⊥-derivation, and under that reading the "needs" claim is false. This was flagged in round-2 verify-A (T2 "Prop 2.9(e), parenthetical").
* **Fix:** Begin the sentence with "Under the worst-case hypothesis of \cref{prop:coherence:oligarchy} (every finite $P\subseteq\hat R$ with $P\not\subseteq\bigcap\VS$ is a possible detection), detection-halving needs …".

### Issue 11 (minor): Prop 6.16 Lean tag is misplaced and missing from the map

* **File:** `coherence.tex`, `prop:coherence:adm`. Also `app-lean.tex`, `tab:lean:map`.
* **Problem:** `\leanok{Post.le\_Cn2\_of\_empty\_eq\_Taut}` is attached right after part (c), the IPC admissibility claim, so it reads as formalizing (c). That declaration (PostCompleteness.lean:171) proves only "structural C with C(∅)=Taut implies C ≤ Cn₂". This is the maximality half of (b), and `C_adm` is not defined in Lean. The README marks it "special case". The proposition has no row in `tab:lean:map`, although the appendix says tagged results are formalized "in the sense of" that table.
* **Fix:** Move the tag to the end of part (b) as `\leanok{Post.le\_Cn2\_of\_empty\_eq\_Taut} ((b): $\Cadm\le\Cn_2$ only)`. In `app-lean.tex` add the row `\cref{prop:coherence:adm} (b) & \texttt{Post.le\_Cn2\_of\_empty\_eq\_Taut} & PostCompleteness & special case (maximality half of (b))`.

### Issue 12 (minor): `tab:lean:map` disagrees with the in-text tags

* **File:** `app-lean.tex`, `tab:lean:map`.
* **Problem:**
  1. `lem:imitation:cautious` is tagged in `imitation.tex` with `thm_3_1_a_static` and `thm_3_1_b_static` but has no row.
  2. The `lem:coherence:bag` row says "exact", but Lean covers only (a) and (b) (`negative_bag`, `refuted_of_superset`); the README says "bullet 3 … not formalized".
* **Fix:** Add the row `\cref{lem:imitation:cautious} (a),(b) & \texttt{StepSoundness.thm\_3\_1\_a\_static}, \texttt{thm\_3\_1\_b\_static} & StepSoundness & exact for (a),(b)`. Change the `lem:coherence:bag` row to `\texttt{CoherenceGames.negative\_bag}, \texttt{refuted\_of\_superset} & CoherenceGames & exact for (a),(b)`.

### Issue 13 (minor): Lean tags in `coherence.tex` understate or mislabel scope

* **File:** `coherence.tex`.
* **Problem:**
  1. `thm:coherence:robust` is tagged `thm_2_5` with no "(finite classes)", unlike Thms 6.5 and 6.6; the README fidelity is special case (finite).
  2. `lem:coherence:bag` carries its tag after part (c), which is not formalized.
  3. `thm:coherence:post` names only the full-language theorem, although the statement covers fragments; the fragment result is `Post.frag_postComplete_neg`.
  4. Namespaces are used inconsistently: `Post.…` is qualified, while `negative_bag` and `carnap_single` are not.
* **Fix:**
  1. Write `\leanok{thm\_2\_5} (finite classes)`.
  2. Write `\leanok{negative\_bag} ((a),(b))`.
  3. Add `\leanok{Post.frag\_postComplete\_neg}` to the tags of `thm:coherence:post`.
  4. Optionally qualify the other tags as `CoherenceGames.…` and `Carnap.…`, to match `tab:lean:map`.

### Issue 14 (minor): §3.4 summary omits "per scene"

* **File:** `search.tex`, opening paragraph (line 16).
* **Problem:** The summary says average-case validity "survives search in two regimes where its randomness is drawn after the rules or claims are fixed". It omits that regime (i) needs validity per scene. The lemma and its follow-up stress that a per-(scene, instance) guarantee does not suffice. This was flagged in round-2 verify-A (L3 "Sec.0 #2 … omit the per-scene validity").
* **Fix:** Replace it with "Average-case validity survives search in two regimes, both with randomness drawn after the rules or claims are fixed and outside the prover's control (rules valid per random scene with the library fixed first; fresh randomness per check), and fails in a fixed world with prover-chosen instances (\cref{lem:search:commitment})."

### Issue 15 (minor): duplicate bibliography keys in `search.tex`

* **File:** `search.tex`, Remark (c) after `cor:search:pac` (line 86).
* **Problem:** It cites `rivest1988reliable`, `elyaniv2010selective` and `li2008kwik`. These are duplicate bib entries for the same three works that `setting.tex`, `caution.tex` and `imitation.tex` cite as `rivest1988learning`, `elyaniv2010foundations` and `li2008knows`, so each work appears twice in the bibliography.
* **Fix:** In `search.tex` replace the keys with `rivest1988learning`, `elyaniv2010foundations` and `li2008knows`. Then drop the duplicate entries from `bib/*.bib`.

### Issue 16 (minor): typos in §5.3

* **File:** `imitation.tex` §5.3.
* **Problem:** "(a term with $D^{(i)}=\emptyset$ contributes nothing)" should say "tag". "For distinct metavariables $x,y$ of $\sigma_i$ let $\rho_{i,x}:=\dots$" defines ρ for a single metavariable.
* **Fix:** Use "(a tag with $D^{(i)}=\emptyset$ contributes nothing)" and "For a metavariable $x$ of $\sigma_i$, and distinct metavariables $x\neq y$, let …".

### Issue 17 (minor): the guards appendix cites T1 instead of the paper's results

* **File:** `app-imitation.tex`, `app:imitation:guards`, last sentence.
* **Problem:** It cites "T1 Prop. 3.3 and Thm 3.2 (\cref{sec:caution})" rather than the paper's results.
* **Fix:** Replace it with "By \cref{prop:caution:closure}(ii) and \cref{thm:caution:esc} this bounds the escalations by …".
