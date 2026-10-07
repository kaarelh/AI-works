# Readability review: structure, length, redundancy, tone

Reviewer lens: structure, length and readability for a mathematically and philosophically literate reader.
Scope: main text `paper/sections/{intro,setting,search,caution,imitation,coherence,twotier,simplicity,existence,informal,physics,experiments,philosophy,open}.tex` (PDF pp. 8–158, about 150 pages; about 80k words of LaTeX source once comments are excluded). Line numbers refer to the raw `.tex` files as they stand.

No files were edited. All proposals below are concrete edits for the author to apply.

---

## 0. Headline findings

1. **The main text can lose about 13–14k words (≈17%, roughly 25 pages) without losing any result.** About 60% of that is moving proof-heavy and computation-heavy passages to the existing per-section appendices. The rest is deleting duplicates. §1 has the plan.
2. **Five pieces of material each appear 3–5 times across sections.** They are the reliable-learning/KWIK framing, the negative-bag/multiple-instance remark, the Experiment B narrative, the "inventing a language" reading, and the "true in the context at hand" answer. §2 has the list.
3. **Experiment B is reported with two different sets of numbers.** `coherence.tex` uses the *quick run* (13 valid / 44 invalid candidates; 22 unsound rules, 13 tonk-like). `experiments.tex` and `twotier.tex` use the *full run* (59 / 118; 45.6 ± 19.3 unsound, 30.2 tonk-like). A careful reader will think one of them is wrong (§2, R11; §6, I1).
4. **The reader cannot follow the paper's internal labelling.** Results carry `[T1 Thm 3.1]`-style tags that are never explained. Running text cites memo items instead of paper labels in about 60 places (e.g. "(T2 Thm 5.3)" where `thm:coherence:complexity` exists). "The user" appears about 50 times with no antecedent. Other unexplained internal references include "Sam's image", "the brief", "theory thread T7", "In T3's own accounting", "the verification of T3 caught it" and file names of private notes (§5).
5. **Six subsections open with notation or a theorem and never say what they establish** (§4). The most important are `sec:physics:export`, `sec:physics:learning` and `sec:twotier:special`.
6. **Duplicate BibTeX entries** make the bibliography list the same paper twice: Rivest–Sloan 1988a/b, El-Yaniv–Wiener 2010a/b, Li et al. 2008a/b, and Cohen 1981 with *two different page ranges* (§6, I2).

---

## 1. The cut plan (≥15% of main text, no result lost)

"Move" means move to the existing appendix of that section (`app-<section>.tex`), keep every `\label`, and leave a 1–3 sentence summary with `\cref`s in the main text. Word counts are for the LaTeX source with comments removed; math tokens count as words, so page savings are larger than the word share suggests.

| # | File: lines | Action | Gross words | Net after summary |
|---|---|---|---|---|
| C1 | `twotier.tex` 414–431 | Arithmetic theorem (a)–(f) and "Three computations": keep a 5-line statement of (a), (b), (d); move (c), (e), (f) and the computations to `app:twotier:arith` | 809 | ~650 |
| C2 | `twotier.tex` 460–469 | "Reading in the user's terms": replace with one summary paragraph (text in R19) | 750 | ~570 |
| C3 | `twotier.tex` 121–123, 180, 193–204, 236, 299–302, 319, 412 | Bayesian remark; "Two details found by verification"; cost paragraph and voting audit; non-monotonicity example; (OE)/LP paragraphs and concrete instance; Hilbert illustration; "why learn at all" → appendix | 1214 | ~1050 |
| C4 | `twotier.tex` 457 | Experiment B duplicate (R11) | 262 | ~170 |
| C5 | `simplicity.tex` 51–59, 63–65, 91–103, 194–250, 328–329 | Empirical-selection lemma; second "relation to literature" paragraph; sequence pathology; idealized rate threshold, its repair and convex-frontier corollary; parity-example theorem and corollary (keep "The note's own numbers"); "Further pathologies" → appendix | 1179 | ~980 |
| C6 | `existence.tex` 336–375 | Term models, prime models, compactness/computability barriers, Beth, "how are the natural numbers pinned", Tennenbaum → `app:existence:learned` with summary (P5) | 1050 | ~880 |
| C7 | `existence.tex` 184–197, 220–229 | Threshold strictness, "Scope", closed agendas, vNM → `app:existence:credences` | 470 | ~380 |
| C8 | `physics.tex` 643–692, 766–860 | Gronwall, projectile certificate with numbers, chains; conformal, Lipschitz and monotone certifiers, Laymon → `app:physics` with two summary paragraphs (P4) | 1157 | ~900 |
| C9 | `physics.tex` 1038–1066, 1102–1117 | Thin-leg and finite-sun bridge statements; "Residual defects of the prototype" → appendix | 394 | ~330 |
| C10 | `physics.tex` 41–59, 395–406, 425–434 | "In T3's own accounting" (rewrite, T10); brute-force paragraph → appendix; `rem:physics:existence` → one-line cross-reference | 383 | ~250 |
| C11 | `experiments.tex` 135–210 | D–G and the `verbatim` reproduction block → one paragraph; reproduction block to `code/README.md` or an appendix (R15) | 1152 | ~1000 |
| C12 | `imitation.tex` 36–54, 128, 272–281, 284–288 | Duplicate cautious-verifier lemma (R9); duplicate reading (R6); dimension remark → `app:imitation:dimension`; "Imitation in practice" numbers → `experiments.tex` (R12) | 1196 | ~1000 |
| C13 | `coherence.tex` 171, 191, 367, 421, 246–261, 451–469 | Experiment B passages (R11); trilemma/costs → appendix; consensus remark and projection lemma → appendix with summary | 1077 | ~830 |
| C14 | `search.tex` 21, 83–87, 96–98, 200, 223, 228 | Re-recalled step language (R8); Remarks (a), (c); duplicate "pure schema" definition (R7); duplicate protocol (R4); duplicate truth-maintenance sentence (R5); Experiment C duplicate (R13) | ~835 | ~635 |
| C15 | `caution.tex` 35–37, 164–169, 176–182, 261–271 | Conventions and lemma recall (dup of §2); linear-flat (iii); exact-value and conjecture-evidence paragraphs; noisy-oracle example and `prop:caution:tight` → appendix | ~700 | ~580 |
| C16 | `setting.tex` 207–212, 299–313, 375–380, 466–472, 475–495 | Duplicate readings (R1–R3), meadow numbers (R14); contexts preview cut to 3 sentences | 695 | ~445 |
| C17 | `informal.tex` 113, 125–129, 188–191, 264, 207–222, 469 | Transport duplicates (R10); computational details; IST and Benacerraf propositions → appendix with 2-sentence summary; last paragraph (duplicate of open problem 1) | ~820 | ~670 |
| C18 | `philosophy.tex` 156–178 | Answers table (duplicate of intro table and list; R18) | 478 | ~440 |
| C19 | all sections | Running-text verification history (T3) and repeated "trivial once set up" boilerplate (T12) | ~1100 | ~1000 |
| | | **Total** | **~15.6k** | **≈13–14k (≈17%)** |

What should *not* be cut: the intro enumerated answers (the reader's map), the "Reading" paragraphs that are not duplicates, the necessity table `tab:twotier:necessary`, the worked EuPhO example and its checker table, and the philosophy section apart from its answers table.

---

## 2. Redundancy: exact or near-exact duplicates (keep one copy, cross-reference the rest)

**R1. Reliable learning / perfect selective classification / KWIK "accept" side (5 copies).** The copies are `setting.tex` 466–472 (Reading), `search.tex` 86 (Remark (c)), `caution.tex` 29 and 46/91, and `imitation.tex` 54. *Keep* `caution.tex` 29 and 46, where the VS verifier is defined.
- `setting.tex` 466–472: replace with "*Reading.* The prover is unbounded and adaptive, so soundness is a worst-case property (\cref{sec:search}); its price is counted separately in escalations, samples, detections and oracle calls (\cref{sec:caution})."
- `search.tex` 86: delete Remark (c).
- `imitation.tex` 54: replace "and it coincides with El-Yaniv and Wiener's consistent selective strategy and with the ``accept'' side of KWIK \citep{...}" with "(the VS verifier of \cref{def:caution:vs} without an oracle)".

Note also that `search.tex` 86 cites `rivest1988reliable`, `elyaniv2010selective` and `li2008kwik`. These are duplicates of the keys used elsewhere and create "1988a/1988b" bibliography entries (I2).

**R2. Negative bag as a multiple-instance label.** The copies are `setting.tex` 299–305 and `coherence.tex` 57, which say nearly the same thing. *Keep* coherence. In setting, replace from "A negative bag is a multiple-instance label" through "not themselves cut-closed." with "A negative bag is a multiple-instance label (\cref{lem:coherence:bag})."

**R3. "Inference data are negative data about valuations".** The copies are `setting.tex` 207–212 and `coherence.tex` 273. *Keep* coherence. In setting, replace the paragraph with "Inference data and coherence data inform the learner from opposite sides; \cref{sec:coherence:carnap} makes this precise."

**R4. The online coherence protocol is defined twice.** The copies are `search.tex` 200 (re-stated "in minimal form") and `def:coherence:protocol` (`coherence.tex` 45–47). In search, replace the paragraph from "We use the online protocol" through "never deleted (the negative-bag lemma of \cref{sec:coherence})" with: "We use the online protocol of \cref{def:coherence:protocol}: hypotheses are step sets with prior $w$, designated contexts $\Ac$ are target-coherent, and a detected incoherence deletes every hypothesis containing its steps. \emph{Majority aggregation} announces $\hat R_t=\{s: w(\{R\in\VS_t:s\in R\})>\tfrac12 w(\VS_t)\}$." A forward reference is acceptable here. The alternative is to move `sec:search:ensembles` whole into `sec:coherence:negative`, just before "Oligarchic acceptance", which already begins "Not by voting".

**R5. Truth maintenance (2 copies).** The copies are the last sentence of `search.tex` 223 and `coherence.tex` 81. Delete the search copy.

**R6. "Inventing a language" makes inference learnable (2 copies, plus `informal.tex` 467).** The copies are `caution.tex` 217 and `imitation.tex` 128. *Keep* caution, which has the quantitative table. In imitation 128, replace "The user's note that mathematics ... at coupon-collector cost." with "This is the positive-data counterpart of the gap between cited and uncited rules in \cref{tab:caution:cost}."

**R7. "Pure schema" and "purification" are defined twice.** The copies are `def:setting:schema` (`setting.tex` 106–108) and `def:search:pure` plus line 114 (`search.tex` 96–98, 114). Replace `def:search:pure` with: "Recall pure schemas and purification $\tau^\circ$ (\cref{def:setting:schema}). A step set is \emph{substitution-closed} if it is closed under uniform substitution of formulas for atoms (instance sets of pure schemas are); a step $\Pi\step\varphi$ is \emph{sound} if $\Pi\models\varphi$." Delete line 114. `twotier.tex` 360 cites `def:search:pure`; change it to `def:setting:schema`.

**R8. The step language is re-recalled in search, with different notation.** `search.tex` 21 restates `def:setting:step` and `lem:setting:closure` using $\mathcal S$ and $\Pi$ where setting uses $S$ and $P$, and an acceptance region $A$ where setting uses $\hat R_t$. Replace the paragraph with: "Steps, closure and $\Sound(\Rstar)$ are as in \cref{def:setting:step}. A deterministic verifier $\hatV$ has acceptance region $A=\{s:\hatV(s)=\ACCEPT\}$, and an unbounded prover chaining accepted steps from $B$ reaches exactly $\Cl_A(B)$." Use one notation throughout ($S$, $\Pi$ for premise sets) and `\ACCEPT` rather than `\textsc{accept}`.

**R9. The cautious-verifier lemma in imitation restates caution.** `lem:imitation:cautious` (`imitation.tex` 36–54) is, by its own `\src`, "T1 Thm 3.1, Prop 3.3, positive data". Replace the definition, lemma and proof with: "With no oracle, the VS verifier of \cref{def:caution:vs} accepts $\hat R(D):=\bigcap\VS(D)$, $\VS(D)=\{R\in\Hc:D\subseteq R\}$. By \cref{thm:caution:vs}(a) and \cref{prop:caution:closure} it is sound against every prover at every time, it is the largest acceptance region sound for every target compatible with $D$, it is monotone in $D$, and for $H_1$ it is $\inst(\lgg D)$." Keep `\label{def:imitation:cautious}` on this sentence, since it is referenced.

**R10. Ville and escalation costs are transported twice.** `thm:informal:ville` and its proof idea (`informal.tex` 113–123) and `thm:informal:escalation` (125–129) repeat the corresponding results in `sec:caution:bayes`. The sentence "There is no union bound over queries (as in sec:caution)" repeats caution's paragraph of the same name. Keep both statements, but replace the ville proof idea with "As for \cref{thm:caution:ville}, with shadow-measurability giving $w_t([h^*])=W^*/Z_t$; Appendix~\ref{app:informal}." Delete the sentence about union bounds.

**R11. Experiment B is narrated in five places, with two sets of numbers.** The places are `coherence.tex` 171 (end), 191 (last sentence), 367 and 421; `twotier.tex` 457; and `experiments.tex` 60–90. *Keep* experiments. Replacements:
- `coherence.tex` 171, last sentence: "In Experiment~B (\cref{sec:experiments:prop}) a bold learner over classical natural deduction accepted all 59 valid and refuted all 118 invalid structural candidate schemas, each by an explicit derivation of $\vdash\bot$, while the non-structural $\vdash p$ survived."
- `coherence.tex` 191, last sentence: "Experiment~B shows the predicted drift toward $\CPC$ (\cref{sec:experiments:prop})."
- `coherence.tex` 367: delete the Experiment B sentence.
- `coherence.tex` 421: replace the paragraph with "Experiment~B (\cref{tab:experiments:prop}) shows the negative-data role end to end: coherence pruning cut the unsound rules left by imitation from $45.6$ to $1.2$ on average and closed every route to $\vdash\bot$, at no cost in completeness; at $N\le10$ it left unsound rules in 4 of 18 runs, because a small learned calculus may lack the rules needed to derive the contradiction. Outside a Post-complete target, fallacies can survive."
- `twotier.tex` 457: replace with "Experiment~B (\cref{sec:experiments:prop}) runs a related pipeline, not an implementation of TTL, and shows this section's phenomena: coherence pruning closes every route to $\vdash\bot$, Post probes refute every invalid structural schema, non-structural rules escape (\cref{prop:twotier:structurality}), and world feedback mainly speeds up blame (5.0 versus 9.1 pruning rounds): localization, not refutation."

**R12. Experiment A's positive-data numbers live in imitation, and experiments defers to them.** `imitation.tex` 286 is a 500-word paragraph; `experiments.tex` 43 says "\Cref{sec:imitation:experiment} reports the positive-data part". Move the numbers into `experiments.tex` 43. These are the shape recovery rates (0/67/92/100%), the OOD acceptance figures (1.00 vs the classifier's 89%/73%), the guard results ($11.7\pm0.5$ and $0.3\pm0.5$ unsound schemas), fallacy support (6/6) and the noise counts ($102\pm11$, $18.5\pm3.6$). In `imitation.tex` keep: "Experiment~A (\cref{sec:experiments:algebra}) illustrates each limit on school algebra: rule shapes are recovered once a rule has a few instances and generalize out of distribution, but no guard is ever displayed, all five systematic fallacies reach support, and spurious schemas from sporadic noise grow with $N$ under a fixed support threshold." Keep line 288 ("In short, …").

**R13. Experiment C is reported twice.** The copies are `search.tex` 228 and `experiments.tex` 95–134. Replace the search paragraph with: "Experiment~C (\cref{sec:experiments:adversarial}) illustrates the gap: a step classifier with in-distribution AUC $0.995$ lets a black-box prover prove $16.3$ of $23$ false goal equations, while the learned calculus proves none. That learned verifiers are exploited by search is well documented \citep{gao2023scaling,cobbe2021training}; the theorems explain why in-distribution accuracy cannot rule it out, though not the rate."

**R14. The meadow result appears three times.** The copies are `setting.tex` 375–380, `experiments.tex` 53–55 and `philosophy.tex`. In setting, replace from "In experiment A, coherence without (W)" to the end of the example with "Without (W), coherence in experiment A converges to a coherent calculus for the total reading $1/0=0$, a different meaning of `/' (\cref{sec:experiments:algebra})."

**R15. Experiments D–G duplicate tables in other sections.** D restates `tab:twotier:sim`, E restates `tab:physics:checkerrun` and repeats "the first version accepted V6–V9", F's table repeats numbers stated inline in `sec:simplicity`, and G repeats `thm:informal:frz`(iv). Replace `experiments.tex` 135–186 with a single subsection: "\subsection{D--G: re-runs of the check scripts}\label{sec:experiments:checks} Four check scripts were re-run for this section and reproduce the numbers quoted where the results are stated: \texttt{ttl\_sim.py} (\cref{tab:twotier:sim}), \texttt{sps\_checker.py} (\cref{tab:physics:checkerrun}), the simplicity scripts \texttt{c1}--\texttt{c5} (the \textsf{computed} figures of \cref{sec:simplicity}) and \texttt{comprehension\_toy.py} (\cref{thm:informal:frz}(iv))." Keep the old labels `sec:experiments:ttl`, `:physics`, `:simplicity` and `:comprehension` on that subsection, or update their few uses. Move the `verbatim` reproduction block (193–210) to `code/README.md` or an appendix.

**R16. Physics restates existence results with memo labels.** `rem:physics:existence` (`physics.tex` 425–434) cites "T6 Thm 4.1, Cor 4.2", "T6 Thm 4.5" and "T6 Prop 4.7". Replace it with: "\Cref{sec:existence} gives the multi-context counterpart: coherence on designated contexts is equivalent to a model nonempty there (\cref{thm:existence:mcs,cor:existence:contexts}); bridges must be read as rules of proof over belief states, not conditionals between worlds (\cref{thm:existence:rules}); and locally coherent contexts need not glue into one world (\cref{prop:existence:triangle})."

**R17. "True in the context at hand" is given two definitions, each called *the* answer.** `existence.tex` 291–296 (`def:existence:truecontext`, "This answers the user's ... wtf is that???") and `physics.tex` 942–969 (`thm:physics:superval`, "This answers ...") both claim to answer the question. The intro and philosophy tables cite only the physics version. *Keep* physics as the answer. In existence 295, replace "This answers the user's ``maybe you just check ... wtf is that???'' (\texttt{verification from truth.md}): truth in the context at hand is" with "This is the multi-context counterpart of the answer given in \cref{thm:physics:superval}: truth in the context at hand is".

**R18. The motivating questions are answered in three summaries.** The copies are `philosophy.tex` 156–178 (`tab:philosophy:answers`), `tab:intro:answers` together with the enumerated list in `intro.tex`, and the abstract. Delete `tab:philosophy:answers` and the paragraph that introduces it. Replace them with "The motivating questions, and where each is answered, are listed in \cref{sec:intro:answers} and \cref{tab:intro:answers}." One row is not in the intro, the emergence of a notion of proof. Add it as a bullet under intro item (6): "Selection of steps by counterexample objects, plus Gödel completeness, explains why surviving informal steps are derivable, though not why they are short (\cref{prop:informal:emergence})."

**R19. Twotier's closing section duplicates philosophy.** `sec:twotier:reading` (`twotier.tex` 460–469, about 750 words) restates the three acts, Goodman's mutual adjustment and the warrant. Philosophy 13.1–13.2 does the same. Replace it with: "\subsection{Summary}\label{sec:twotier:reading} Learning which inferences are valid is learning the \emph{audited practice}. Imitation finds the practice's rules, fallacies included, and is the only channel that says anything positive about a rule (\cref{lem:twotier:onesided,prop:twotier:positive}). Confrontation with designated positions and the world sorts them, withholding every rule in a minimal conflict and, where descent applies, only the culprit (\cref{lem:twotier:reiter,lem:twotier:descent}). Assertion comes last, after the burn-in (\cref{thm:twotier:burnin}). Coherence fixes the learned role only up to which member of a conflicting set is given up: in the MP/AC example only the world or a denial decides whether `$\to$' means $\to$ or $\leftarrow$. The residue $F_{\mathrm{res}}$ is empty for $\CPC$ and, given realizability, for complete decidable theories; in arithmetic it contains $\neg\Con(\PA)$ under presumption of validity. \Cref{sec:philosophy} discusses the resulting warrant." Move the open-problem list in line 468 to `open.tex` item 4/5.

**R20. Smaller duplicates (one sentence each).**
- The air-pressure/misdesignation result is restated in `setting.tex` 489–494, `coherence.tex` 204 (last sentence), `twotier.tex` `prop:twotier:designation` and `physics.tex` 308–323. Keep physics and cut the others to "(\cref{prop:physics:misdesignation})".
- "Rules can be identifiable when truths are not" appears at the end of `coherence.tex` 352 and in `philosophy.tex`. Keep philosophy.
- The Post substitution proof is written out three times: `prop:search:post`, `thm:coherence:post` and `lem:twotier:post`. The proof of `lem:twotier:post` can read "as in the proof of \cref{prop:search:post}, by induction on $\tau$."
- `informal.tex` 469 ("The hardest open problem…") nearly duplicates `open.tex` item 1. Cut it to: "The hardest open problem, affordable soundness with language invention, is stated in \cref{sec:open}(1)."
- The dimension inference remark (`imitation.tex` 272–281) overlaps `physics.tex` 1152–1159 (Kennedy and Buckingham are cited in both). Move the remark to `app:imitation:dimension`. Keep the physics paragraph, which already points back.

---

## 3. Proof-heavy passages to move to the appendix

**P1. Twotier, the longest section at 21 pages.** Keep: set-up, the two "naive claim is false" propositions, the Reiter lemma statement (move its inline proof to `app:twotier:reiter`), the descent lemma, the learner definition, the audit lemma (statement only), the main theorem, the necessity results with `tab:twotier:necessary`, and `cor:twotier:cpc`. Move:
- `rem:twotier:bayes` (121–123);
- the "Two details were found by verification" paragraph (180);
- the "Cost" paragraph (193) and `prop:twotier:voting` with its example (195–204), leaving one sentence: "When at most $m$ positions may violate (WS), a per-position voting audit keeps $\Sigma^*$ and removes every fallacy refuted at $m+1$ complete positions (\cref{prop:twotier:voting}, Appendix~\ref{app:twotier:voting})";
- the non-monotonicity example (236);
- the (OE) discussion, LP check and concrete instance after `thm:twotier:burnin` (299–302), keeping the first sentence of 299;
- `thm:twotier:blame`(c) (311) and the "Hilbert illustration" (319);
- `prop:twotier:coherenceonly`(b) detail (391);
- the "honest caveat: why learn at all?" (412);
- `thm:twotier:arith` (c), (e), (f) and "Three computations" (431).

**P2. Simplicity.** The section answers a side question and runs 13 pages of dense information theory. Move `lem:simplicity:empirical` (51–59), the second "Relation to the literature" paragraph (65), `prop:simplicity:sequence` (91–103), `thm:simplicity:idealized` with its "The repair" paragraph and `cor:simplicity:shapes` (194–230), and `thm:simplicity:example` with `cor:simplicity:example` (233–250). Keep "The note's own numbers" (251). Leave in the main text: "With $\ell=K$ and all hypotheses allowed, the rate threshold of \cref{thm:simplicity:separable} survives for independent parities up to explicit $O(\log)$ slack (\cref{thm:simplicity:idealized}), every convex frontier is realizable after rescaling (\cref{cor:simplicity:shapes}), and in the note's example every near-optimal hypothesis inside the window $(\approx1/n,\approx(1-H(p))/d)$ correlates with the parity and memorizes almost none of the errors (\cref{thm:simplicity:example,cor:simplicity:example}); all are proved in Appendix~\ref{app:simplicity}." Also condense "Further pathologies" (328) to its four italic headings, one sentence each.

**P3. Caution.** Move `thm:caution:untagged`(iii) (linear flat schemas, 164–169) and the "Exact values" paragraph (176), keeping a table row. Move the conjecture's "Evidence" paragraph (182), keeping its first sentence. Move the noisy-oracle counterexample and `prop:caution:tight` (261–271), keeping "The constant $\delta\le\wstar\delta'$ cannot be improved (\cref{prop:caution:tight})".

**P4. Physics.** Move `thm:physics:gronwall`, `thm:physics:projectile` with its "Numbers", and `thm:physics:chains` (643–692) to `app:physics`. Leave: "Certificates of this form include a checkable Gronwall bound for finite-horizon exports (\cref{thm:physics:gronwall}); a rigorous range certificate for projectiles under any drag dominated by quadratic drag (\cref{thm:physics:projectile}), which for a steel ball certifies $R\in[9.653,10.483]$\,m against a simulated $9.978$\,m and for a ping-pong ball is silent; and error budgets for chains of bridges (\cref{thm:physics:chains}), under which `$100-99.9$' with tolerances $0.2$ certifies not even a sign."

Move `thm:physics:conformal`, `thm:physics:noreg`, `thm:physics:lipschitz`, `thm:physics:monotone` and `prop:physics:laymon` (766–860). Keep `thm:physics:coherencetol` and the "Reading" (851) and add: "Calibration on exchangeable feedback gives average coverage and nothing under selection (\cref{thm:physics:conformal}); without a regularity guarantee finitely many simulations certify only the queried points (\cref{thm:physics:noreg}); with a \emph{proved} Lipschitz constant or monotonicity, validated simulation becomes a sound certifier at a matching query cost (\cref{thm:physics:lipschitz,thm:physics:monotone}), and monotonicity must be proved, since it fails for a damped pendulum (\cref{prop:physics:laymon})."

Move the thin-leg and finite-sun statements (1038–1066) and "Residual defects of the prototype" (1102–1117), keeping the checker table.

**P5. Existence.** Move 336–375 to `app:existence:learned` and leave: "\paragraph{What pins the intended model.} Two layers of non-standardness remain. Coherent but false theories such as $\PA+\neg\Con(\PA)$ have a prime model containing a definable non-standard `proof of $0=1$'. True theories need not be categorical, since by compactness no first-order mode of talking pins down an infinite structure (\cref{thm:existence:compactness}). For any computable coherence notion, `coherent iff there is something it could be talking about' can hold only if having such a something is $\Pi_1$ (\cref{thm:existence:computability}). Anchoring a vocabulary pins exactly what is definable from it (\cref{prop:existence:beth}). Every known pin of $\N$ (second-order induction, initiality, the $\omega$-rule, Tennenbaum's theorem) adds something beyond finitary computable coherence (Appendix~\ref{app:existence:learned})." Also move `thm:existence:threshold`, "Scope", `prop:existence:closed` and `prop:existence:vnm` (184–197, 220–229) to `app:existence:credences`. Keep de Finetti, the arity theorem, the probing caution and the Gaifman/inductor results, which the section's own Credit paragraph names as its new contributions.

**P6. Coherence.** Move `thm:coherence:trilemma` and `prop:coherence:costs` with the paragraph after them (246–261) to `app:coherence:costs`. Leave "The same $\Sigma_2$ boundary appears for credences: computable, weakly coherent, $\Pi_1$-convergent credences are dogmatic on infinitely many true $\Pi_2$ sentences (\cref{thm:coherence:trilemma}); see \cref{prop:coherence:costs} for what weak coherence costs." Condense `rem:coherence:consensus` and `lem:coherence:projection` (451–469) to one paragraph citing the appendix.

**P7. Informal.** Move the computational detail of `ex:informal:weaker` (2604 pairs, V1, 188–191), the "Exact minimax values" paragraph (264) and the referee-search sentence at 288 to `app:informal`. Move `prop:informal:ist` and `prop:informal:benacerraf` (207–222) to the appendix, leaving: "The same holds for $\varepsilon$-$\delta$ analysis versus Nelson's IST on standard sentences, and for von~Neumann versus Zermelo numerals on arithmetic sentences (\cref{prop:informal:ist,prop:informal:benacerraf}): practice fixes $\approx$ on its domain and nothing else."

---

## 4. Section openings that do not say what the section establishes

Each proposal is a 3–5 sentence opening to insert right after the heading.

**O1. `physics.tex` 567, `sec:physics:export`.** It opens with "Fix a one-parameter deformation…". Insert: "Contexts let an idealized model contradict the world; exports carry its conclusions back. This subsection shows that no export is free: information about the idealized model alone, however complete (its jet, its germ, finitely many values elsewhere), never justifies a finite-tolerance claim at the actual parameter (\cref{thm:physics:nofree}). What justifies one is information of small radius about the de-idealized family (\cref{prop:physics:radius}), and we list the forms such certificates take. The subsection ends with the attack this creates: a solver who may choose contexts can stipulate any answer unless side conditions are evaluated in the parent and contexts are declared deformations (\cref{thm:physics:stipulation})."

**O2. `physics.tex` 739, `sec:physics:learning`.** It opens with the error-function setting. Insert: "Export certificates need tolerances and validity regions, which are natural targets for learning. This subsection asks which signals learn them soundly against a solver who picks the regime. Coherence among exports catches only tolerances that are too narrow (\cref{thm:physics:coherencetol}); exchangeable calibration gives average coverage and nothing under selection; and only a \emph{proved} regularity property turns validated simulation of the top model into a sound certifier (\cref{thm:physics:lipschitz,thm:physics:monotone})."

**O3. `twotier.tex` 358, `sec:twotier:special`.** It opens directly with the paragraph "Classical propositional logic.". Insert: "\Cref{thm:twotier:main} is stated relative to a residue and to realizability. This subsection evaluates both for three targets. For classical propositional logic the residue is empty, closed-instance evaluation gives singleton blame, and TTL is exact (\cref{cor:twotier:cpc}); coherence alone is sound but may withhold genuine rules, and one denial per fallacy repairs this (\cref{prop:twotier:coherenceonly}). For complete decidable theories the same holds conditionally on a realizability hypothesis that is not established for the usual axiomatizations (\cref{cor:twotier:decidable}). Arithmetic is Popperian, with a permanent residue beyond $\Sigma_1$ (\cref{thm:twotier:arith})."

**O4. `caution.tex` 112, `sec:caution:cost`.** It opens directly with a theorem. Insert: "\Cref{thm:caution:esc} reduces the cost of caution to a property of the class. This subsection computes it for the classes that matter here; \cref{tab:caution:cost} collects the results. The main contrast is between rules cited by name, where caution costs at most $N+1$ escalations per rule, and uncited rules, where even one rule can force $\lfloor(N-1)/k\rfloor^k$. Unstructured classes cost exponentially in description length, and certifying invalidity too costs a Bell number."

**O5. `coherence.tex` 207, `sec:coherence:arith`.** It opens with "Hypotheses are r.e. theories…". Insert before it: "Arithmetic is where coherence stops being a complete test. Coherence with a $\Sigma_1$-complete base already does everything $\Delta_0$ world feedback can (\cref{lem:coherence:delta0}); no r.e.\ hypothesis is maximal, and Turing progressions are not identifiable (\cref{thm:coherence:rosser,thm:coherence:turing}). The right use of coherence is Popperian: it detects false $\Pi_1$ claims but not false $\Sigma_1$ claims, and no computable channel decides $\Sigma_2$ truth in the limit (\cref{thm:coherence:popper})."

**O6. `existence.tex` 298, `sec:existence:learned`.** It opens with notation. Insert: "We return from general completeness theorems to the learner. Coherence of a learned structural calculus on a designated context always yields a model, but a syntactic one (\cref{thm:existence:buys}). That model reduces to the intended one exactly when the intended semantics is a surjective image of the language (\cref{thm:existence:leibniz}). Compactness and computability then bound how far coherence can pin down an intended infinite structure (\cref{thm:existence:compactness,thm:existence:computability})."

The top-level section openings are adequate. The exception is the second paragraph of `physics.tex` (41–59), which a reader cannot parse (T10).

---

## 5. Tone: internal jargon a reader cannot follow

**T1. "The user" (about 50 occurrences, with no antecedent).** Counts: setting 2, caution 1, imitation 2, coherence 3, twotier 7, existence 19, informal 4, physics 11. The intro never introduces whose questions these are. The variants "in his words" (`physics.tex` 30) and "His caveat" (`informal.tex` 166) have no antecedent either.

Fix: at the end of the first paragraph of `intro.tex` (`sec:intro:question`), add "The questions are those of Kaarel Hänni, posed in his research notes; we quote the notes verbatim and refer to them as `the notes'." Then replace:
- "the user's X" with "the notes' X" (or "Hänni's X");
- "the user asks/warns/worries" with "the notes ask/warn/worry";
- "the user himself notes" with "the notes observe";
- "in his words" with "in the notes' words".

Specific rewrites:
- `twotier.tex` 32: "The user's first success criterion" becomes "The first success criterion of \cref{sec:intro:question}".
- `twotier.tex` 460: retitle the subsection as in R19.
- `physics.tex` 1089: "(the user's slip: $I$ for $I_0$)" becomes "(a slip recorded in the notes: $I$ for $I_0$)".
- `physics.tex` 1007–1008: "the answer … is the user's, reported by him to match the official one" becomes "the answer is the one in the notes, where it is reported to match the official solution".

**T2. Memo labels in running text instead of paper labels or `\src` tags (about 60).** Where the paper has the result, use `\cref`:
- `setting.tex` 91: "(T1 Lemma~1.1)" → delete; `\cref{lem:search:stepwise}` is already there.
- 204: "(T1 Prop.~2.3, scope remark)" → "(\cref{ex:search:atoms})".
- 210: "(T2 \S4.1)" → "(\cref{sec:coherence:carnap})".
- 312: "(L3 Lemma~A, \Cref{sec:search})" → "(\cref{lem:search:commitment})".
- 424: "(T2 Thm~5.3)" → "(\cref{thm:coherence:complexity})".
- 427: "(T7 Thm~5.7, \Cref{sec:twotier})" → "(\cref{thm:twotier:depth})".
- 480: "(T3 \S1)" → delete.
- 482: "(T3 Prop.~1.5)" → "(\cref{prop:physics:sup})".
- 488: "(T3 Def.~1.3, Prop.~1.4)" → "(\cref{def:physics:filter,prop:physics:los})".
- 493: "(T2 Prop.~7.1)" → "(\cref{prop:physics:misdesignation})".
- `caution.tex` 37: delete "; T1 Lemma~1.2" and "; T1 Lemma~1.3".
- 324: "(T2 Prop.~2.9(a); …)" → "(\cref{prop:coherence:caution})".
- `imitation.tex` 96: "(T1 Thm~3.6; …)" → "(\cref{thm:caution:tagged}; …)".
- 128: "(T1 Thms~3.6--3.7, …)" → "(\cref{thm:caution:tagged,thm:caution:untagged})".
- 266: "(T7 Prop.~2.2; …)" → "(\cref{prop:twotier:practice}; …)".
- `physics.tex` 491: "(T2 Thm~2.2)" → "(\cref{thm:coherence:halving})".
- 759: "(T3 Prop~4.2)" → "(Appendix~\ref{app:physics})".

Where the paper does not have the result (literature-memo pointers), move the pointer into the result's `\src{}` tag or a footnote, or delete it:
- `imitation.tex` 81, 89, 182, 185, 277 (L1 and T1 §5);
- `coherence.tex` 326 ("the T2 verifier found") and 448 ("L11 TC4");
- `existence.tex` 38, 273, 296, 344 (L10, L7, L4);
- `physics.tex` 38, 48, 78, 85, 111, 113, 233, 237–238, 334, 420, 499, 537, 558, 641, 859, 1007, 1127, 1133, 1136, 1159 (L7, L9, L10).

**T3. Verification history in running text.** These passages record the history of the research process, not mathematics:
- `caution.tex` 182 ("as corrected after verification");
- `imitation.tex` 212 ("Two features of (b) were added in verification");
- `twotier.tex` 180 ("Two details were found by verification and simulation") and 269 ("Both qualifications were added in verification");
- `simplicity.tex` 126 ("added after verification"), 219 ("The original clause (b) … was false") and 328 ("An earlier claim … was false and is retracted");
- `informal.tex` 189 ("the original statement of (d) … mismatches") and 288 ("a referee's search");
- `physics.tex` 396, 676, 1064 ("a referee's …"), 888–889 ("A first version of this definition … the verification of T3 caught it"), 1091–1095 and 1102 ("first version accepted");
- `experiments.tex` 144.

Fix: keep the *mathematical* content, for example the counterexample that shows a hypothesis is needed ("without the clause the theorem fails for ground rules; Appendix~X"). Delete "added in verification", "original", "first version", "referee". Collect the history in one appendix paragraph, "Repairs made during verification", or leave it in `research/verification/`, which the intro already points to. The `\src{… as repaired}` tags can stay once T4 explains them.

**T4. The provenance and status tags are never explained.** Tags such as `[T1 §1.1; T2 §1]` appear on almost every result, together with `Lean: name` and `(computed; T5 c4)`. No legend says what T1–T7 and L1–L11 are. The intro only says "seven theory threads". Fix: add at the end of `sec:intro:method` (`intro.tex`, before "We have tried to mark scope honestly"):

> \paragraph{Conventions.} A superscript tag such as \src{T1 Thm 3.1} gives a result's provenance. T1–T7 are the theory documents `research/theory/T1-soundness-under-search.md`, `T2-coherence-as-negative-data.md`, `T3-contexts-idealization-export.md`, `T4-informal-math-latent-formalization.md`, `T5-steeper-simplicity-and-normativity-from-imitation.md`, `T6-philosophical-completeness.md` and `T7-two-tier-coherent-inferential-learner.md` of the accompanying repository. L1–L11 are the literature memos in `research/lit/`. "as repaired" means the statement was changed during adversarial verification (records in `research/verification/`). A superscript \textsf{Lean:\,name} names the Lean declaration (Appendix~\ref{app:lean}). Status labels mark results that are \textsf{known}, \textsf{computed} by a script (\cref{sec:experiments}), a \textsf{proof sketch} or a \textsf{conjecture}. Running text cites only results of this paper.

Also rewrite `intro.tex` 111–116. Replace "coordinated by one orchestrating instance", "Literature memos on eleven strands" and "Seven theory threads" with "The work was carried out by cooperating instances of Claude in four stages: literature surveys on eleven topics (L1–L11); seven theory documents (T1–T7); adversarial verification …; drafting, with a fidelity check …".

**T5. "Sam" (existence).** "Sam's image" (`prop:existence:image`, line 57), "Sam's slogan" (40, 379) and "Sam's other pointer" (121) refer to someone no reader can identify. Rename the proposition "[The image of $\Th$]". Rewrite line 38 as "records a remark by a colleague: …", or give the full name with permission. Then use "this slogan" elsewhere.

**T6. File names of private notes in running text.** Examples: `existence.tex` 32 (\texttt{logic/a 'philosophical version' of g\"odel's completeness theorem.md}), 166 (\texttt{ai/DLK/}), 295 (\texttt{verification from truth.md}), 350 (\texttt{math is a mere string game iff everything is.md}), 374 (\texttt{logic/confusions/soundness.md}), 383 (\texttt{logical models as distinct from mental models.md}). Replace each with "(the notes)" and, if wanted, add a footnote with the path.

**T7. Script names and internal check labels in running text.** Examples: `twotier.tex` 119, 143, 180, 204, 236, 300, 311, 317–319, 370, 410, 430 (\texttt{overlap.py}, \texttt{noisefree.py}, \texttt{prop32\_voting.py}, …); `simplicity.tex` status tags such as "T5 c4" and "repair\_checks"; `informal.tex` 189, 264, 288 ("V1", "V3", \texttt{T4-checks/…}). Use a uniform `\status{computed}` and list the scripts in one appendix table, mapping each script to the claims it checks (the content of Experiment F's table, extended).

**T8. "The brief".** `physics.tex` 1132 reads "The brief listed dimensional analysis…". Replace with "The notes list dimensional analysis…".

**T9. "IPhO 2025 T2/T3" collides with the memo labels T2/T3.** See `physics.tex` 302 ("IPhO~2025 T2 versus T3"), 639 ("T2 C.3") and 1125 ("T2 C.4"). Line 76 already says "Theory~2". Use "Theory Problem 2/3" throughout, for example "(IPhO~2025 Theory Problems 2 and 3)" and "(IPhO~2025 Theory Problem 2, part C.3)".

**T10. Process self-reference.**
- `twotier.tex` 46: "All results come from theory thread T7, which went through two rounds of adversarial verification" → "All results of this section passed two rounds of adversarial verification (\src{T7})". Keep the honest disclosure about the second-round repairs.
- `physics.tex` 50–59: "In T3's own accounting, \cref{… 16 labels …} are trivial once set up" → "Most results here are trivial once the definitions are in place. The imported ingredients are Łoś's theorem, Gronwall's inequality, split conformal prediction, the radius of information and the adversary argument of information-based complexity, Lipschitz covering bounds and interval inclusion monotonicity. New, as far as we know, are the frame-free realizability criterion (\cref{thm:physics:realizability}(a)), the two-sided analysis of adversarial stipulation with its well-posedness certificate (\cref{thm:physics:stipulation}), and a rigorous thin-leg certificate with a complete worked checker run (\cref{sec:physics:example}). Proofs not given inline are in Appendix~\ref{app:physics}."
- `physics.tex` 308: "This is T2's formal version of the user's air-pressure worry." → "This is a formal version of the air-pressure worry of \cref{sec:intro:question}."
- `imitation.tex` 280: "This remark has not been through the project's adversarial verification." → "\status{not adversarially verified}" in the remark header.
- `informal.tex` 459: the caption "(from the project's literature memo L6, \S1, where dates are checked)" → "\src{L6 \S1}".
- `existence.tex` 296: "The context-tree calculus of the literature memo L7" → "The context-tree calculus of \citet{brown2004chunk}-style chunk systems", or drop the sentence.

**T11. Claims that rest only on internal memos.**
- `coherence.tex` 260: "Incoherent computable credences can gradually verify the $\Pi_2$ sentences convergently (L3 Thm~G(f), a standard construction given there as a sketch)". This supports the claim "weak coherence costs exactly the $\Pi_2$ class". Either give the construction in `app:coherence:costs` marked \status{proof sketch}, or delete the sentence and the claim that depends on it.
- `informal.tex` 85: "(T4 Prop~2.6)" → "(immediate: the accepted set only shrinks)".

**T12. "Trivial once set up" is repeated.** The phrase or a variant occurs about 40 times. `search.tex` says it three times in one section (16, 38, 84 "Remarks (a)"); `coherence.tex` 11 times; `informal.tex` 8 times. The intro already states the policy. Keep the "; trivial" marker in theorem titles and delete the running-text repetitions. For example, delete `search.tex` 38's first clause and Remark (a) at 84, `twotier.tex` 46's first two sentences, and the "trivial once set up (the content is in the definitions)" list in `physics.tex` 50.

---

## 6. Inconsistencies found while reading

**I1. Experiment B numbers differ between sections (major).** `coherence.tex` 171, 191, 367 and 421 quote `prop_learning_quick.md`: 13 valid and 44 invalid candidates, and "imitation ended with 22 unsound active rules, 13 of them tonk-like". `experiments.tex` 82 and `twotier.tex` 457 quote the full run, `prop_learning.md`: 59 and 118, with `tab:experiments:prop` giving $45.6\pm19.3$ unsound and $30.2$ tonk-like. Use the full-run numbers everywhere (R11).

**I2. Duplicate bibliography entries (major).** `bib/search.bib` adds `rivest1988reliable`, `elyaniv2010selective` and `li2008kwik`. These duplicate `rivest1988learning`, `elyaniv2010foundations` and `li2008knows`, and the compiled bibliography shows "Rivest and Sloan 1988a/1988b", "El-Yaniv and Wiener 2010a/2010b" and "Li et al. 2008a/2008b" for the same papers (main.txt lines 857, 989–990, 1275–1276). Also, `cohen1981irrationality` (`bib/philosophy.bib`, pp. 317–331) and `cohen1981can` (`bib/simplicity.bib`, pp. 317–370) are the same paper with conflicting page ranges. Delete the duplicate keys from `bib/search.bib` and use one Cohen key, with pp. 317–370 if the commentary is included and 317–331 for the target article alone. Then regenerate `all.bib`.

**I3. Two answers to "true in the context at hand" (major).** See R17.

**I4. Are the notes public?** `philosophy.tex` 158 says "notes that are publicly available"; the `simplicity.tex` 30 footnote says "(unpublished)". Pick one description and use it in the new intro sentence (T1).

**I5. Notation drift.** Setting uses $S$, $P\step j$ and `\ACCEPT`. Search and coherence use $\mathcal S$, $\Pi\step j$ and `\textsc{accept}` (`search.tex` 21). The acceptance region is $A$ in search and $\hat R_t$ elsewhere. Unify as in R8.

---

## 7. Summary of priorities

1. Add the conventions legend and the sentence introducing the notes (T4, T1). Replace memo labels with paper labels (T2). These are low-effort, high-value fixes.
2. Fix the Experiment B numbers and the duplicate bib keys (I1, I2).
3. Execute the cut plan in §1, starting with twotier, existence, physics, simplicity and experiments D–G, which give about 70% of the savings.
4. Add the six openings (§4) and remove verification history from running text (T3).
