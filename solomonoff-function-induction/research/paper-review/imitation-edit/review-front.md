# Paper 2: review of the framing and caveats after the imitation integration (2026-10-14)

*Reviewer: framing and caveats. Object: `paper-steeper/` as built at 22:17 on 2026-10-14 (`main.pdf`, 86 pages, newer than every source file; SHA-256 prefix `a6c0381a92584eea`). Nothing in `paper-steeper/`, `paper/` or the research records was edited, no build was run, and no git command was run. This file is the only file written.*

* **Read in full.**
  * The whole PDF text (`pdftotext -layout`): front matter, §1–§12, references, App A–I. The proof-only parts of App D–G were read for wording and framing, not re-proved.
  * The brief with the author's message (`research/tracks/imitation/00-brief.md`).
  * The integration log (`imitation-edit/log-integrate.md`).
  * The binding rules: `REFRAME.md`; `DECISIONS.md` §0 and §A–§B; `restructure/DECISIONS-restructure.md`.
  * The sources `abstract.tex`, `intro.tex`, `imit.tex` and `discussion.tex`.
* **Read in part.**
  * The synthesis `research/tracks/imitation/notes-final.md`: §0–§2.4, §3, §4, §5.3, §6, §7 and the Verification log.
  * `final-check.md` §4–§5.
  * `referee-final.md` §2.3–§2.8 and §7.
  * The header of `decay/notes-final.md` (on the reading of "params").
  * `imitation-edit/literature.md`, for the related-work paragraph.
* **Checks run** (read-only):
  * the vocabulary grep of DECISIONS §A5 on the PDF text;
  * the status grep of §A2.5;
  * the Wyeth count of §B.6;
  * a grep for the author's notes and for "the author";
  * a script that checks `\status`/`\src` on every theorem-like environment of `imit.tex`, `app-imit.tex`, `teacher.tex` and `app-teacher.tex`;
  * a character count of the abstract and of the proposed sentences;
  * page lookups.

---

## 0. Verdict

* **No fatal finding.** The three requests are carried out honestly.
  * **Weight decay.** The remark (Remark 8.5, App F.7) says what is analogous and what is not.
  * **Imitation.** §10 reads as a toy result with its limits stated in the section itself.
  * **Caveats.** The introduction and the discussion now say plainly that the motivating problems are not solved. They offer the results as tools, name the four toy cases that the proved results settle, and list six concrete open problems. Nothing found overclaims a result, and nothing is falsely modest.
* **Compliance.** REFRAME and DECISIONS are met:
  * no process vocabulary in the PDF;
  * no Wyeth;
  * the author's notes only in footnotes 1–2 and the acknowledgements;
  * "we" voice throughout;
  * `\status`/`\src` on every new theorem-like environment, and they print nothing.
* **Three major findings.**
  * **M1. The imitation result is attached to the wrong thread in the framing.** The introduction and §10 present imitation as a motivation for the *first* reason (fixed λ > 1). But the theorem lives in the *second* reason's regime (λ ∝ n above a reuse factor). With environment-driven coins, a fixed λ provably returns a program that stores the person's coins. That is exactly the failure the author wanted to avoid, and the paper never says it in so many words.
  * **M2. The abstract has no caveat.** The introduction and the discussion carry the author's requested caveat, but the abstract does not. Adding one needs either a cut or a decision on the 1920-character cap.
  * **M3. Length.** All three page caps are now exceeded: main text 39.08 against 33.5, appendices 42.89 against 37.5, total 85.66 against 73.5. Since the caps predate the request, this is a decision for the author. Specific trims are listed in §7.
* **Smaller findings.** 10 minor findings and 4 suggestions (§1), mostly wording that keeps the caveats exact.

---

## 1. Findings

Page numbers are those of the current PDF. Source lines refer to `paper-steeper/sections/`.

| id | severity | where | problem | fix |
|---|---|---|---|---|
| M1 | major | intro p. 3 (`intro.tex` l.15); §10 p. 34 (`imit.tex` l.16, l.18); discussion p. 37 (`discussion.tex` l.12) | The introduction says "One motivation is imitation" of the **first** reason, the one for which "noise needs only a fixed λ > 1". §10 opens the same way ("Imitation is one motivation for the first reason … Fill-ins are rejected per query (Theorem 6.3)"). Its theorem, however, holds only for c = λ/n in a window above the reuse factor 2^{-m}. That is the second reason's geometry. **When the input carries information about the cell, a fixed λ (or any λ_n = o(n)) eventually selects a shortest program for the data kernel P\* (Theorem 6.3(a) with the sampler P\*).** In the feature case such a program encodes the coupling: the person with its coins stored, the author's "sampler with some bits specified". The paper implies this but never states it. The closest statements are the last sentence of Theorem 10.2 (the program for P\* beats every copy below about 2^{-m}), the remark in App H.3 and one clause of Remark 8.5. So a reader of §1 and of Theorem A will conclude that the first reason's fixed λ recovers a person, and that is false for exactly the case §10 studies. | State the bridge in three places (exact wording in §3.2): (a) in §10 paragraph 1, that with private coins this is the first reason (fixed λ > 1 returns a copy); (b) in §10 paragraph 2, that with environment-driven coins the data kernel is P\*, fixed λ returns a program that stores the coupling, and a copy needs λ/n above 2^{-m}, as for the teacher; (c) one sentence in the introduction and one in "Two reasons, one geometry": imitation needs both reasons. |
| M2 | major (author decision: the cap) | abstract p. 1 (`abstract.tex` l.6) | The author asked that it be "made clear" that the practical motivating problems are not solved. The introduction (Scope) and the discussion ("What the toy cases leave open") say so. The abstract says nothing of the kind and does not mention imitation. It is truthful, since every claim in it is a precise toy statement, but the three framing places are not consistent, and the abstract is what most readers see. It sits at the 1920-character cap of DECISIONS-restructure D9. | Append "These are toy cases of imitation and of learning from a fallible teacher; we offer tools, not solutions." (105 characters with the space). To stay at the cap, cut ", such as Solomonoff induction and SFI with shared randomness," (62) and "; asymptotically, windows exist for flip rates below $0.1233$" (61). Alternatively, the author raises the cap by about 110 characters. |
| M3 | major (author decision: the caps) | whole paper | Measured in the log (§7): main text 39.08 pp against the cap of 33.5, appendices 42.89 against 37.5, total 85.66 against 73.5. Imitation adds about 7.3 pp in all (§10 2.33, App H 3.99, related work about 0.4, introduction and discussion about 0.6). Weight decay adds about 2.4 pp (Remark 8.5 0.62, App F.7 about 1.7). The synthesis itself rates the imitation result "modestly" cool (synthesis §1.3). The present weight is at the upper end of what that supports. | Either the author relaxes the caps for this request, or the trims of §7 are applied (about 1.1–1.4 pp of main text without losing any result). |
| m1 | minor | intro p. 3 (`intro.tex` l.15) | The motivation sentence says a copy should be returned "rather than … a different system that predicts the person's answers". The paper proves that a different system with the *same* behaviour cannot be told apart from imitation data (§10 last paragraph; discussion gap (1)). What Theorem 10.2 excludes, within its window, is a system that predicts *better*. | "…, or a different system that predicts the person's answers better than the person does." The behaviourally equivalent case is then gap (1), as now. |
| m2 | minor | §10 p. 34 (`imit.tex` l.16) | "systems that infer from the data which person they face are excluded by the private-randomness class (Appendix H.1)" reads like a result. App H.1 and discussion gap (5) say correctly that the exclusion is "by construction … not because of anything in the data". This is precisely the author's "completely alien system that just thinks about what the human would say", so the main text should say that it is excluded by a modelling choice. | "…are excluded by the choice of the private-randomness class, not by the data (Appendix H.1)". This is included in the M1 wording. |
| m3 | minor | §10 p. 34 (`imit.tex` l.18) | "We do not show … recovery when the environment's influence has a short description (Proposition H.4)" understates a proved negative result. Proposition H.4(i) shows that every c fails there (some non-copy is at least as good as every copy). | "…; and a coupling with a short description defeats every λ/n (Proposition H.4)". |
| m4 | minor | intro Scope p. 6 (`intro.tex` l.59) | The fourth toy case, "a sampler whose coins are an incompressible function of the environment on many more cells than it has bits", is exact only up to the factor H(ρ). The condition used in §10 is ℓ0 + \|Σ\|m + δβ ≪ 2^m H(ρ) (final-check §5 item 3). For the low-entropy parity person of §8 (H(ρ) = 0.0112), the bound of Theorem 10.2(iv) exceeds H(ρ) at c = 10^{-4}, inside the teacher window (App H.3). The paragraph's other toy cases are listed with their hypotheses. Two are missing here: this one, and the full-table case, which needs typical flip sets (δE = O(d)). Without them the list is less exact than "names exactly" requires. | Fourth case: "…of the environment with far more entropy, 2^m H(ρ), than it has bits, for λ/n in a window above 2^{-m} (Theorem 10.2)". Second case: "…below ¼, for large d and typical flip sets (Proposition 7.8)". The bullet and the table row may keep the short form. |
| m5 | minor | intro Scope p. 5–6 (`intro.tex` l.59) | The caveat is clear, but it shares one long paragraph with the reader's guide. It names the open problems only by pointer ("the conceptual problems listed in Section 12 remain open"). The author's request is for the problems to be made clear, and the introduction is where readers decide what is claimed. | Split the paragraph: one paragraph on what is claimed (the present first five sentences), then "Reader's guide". Name three gaps in the claim paragraph: "…remain open, among them that imitation data identify behaviour, not mechanism, that the complexity weight cannot be chosen from imitation data, and that realistic errors have structure (Section 12)". This adds about 2 lines. |
| m6 | minor (length, readability) | discussion pp. 37–38 (`discussion.tex` l.34, l.36, l.38) | Three statements are each made twice in adjacent paragraphs: "rate, not validity" (Proposition 9.3) in "The gap to realistic errors" and in gap (3); "cheap rules defeat every c" (Proposition 9.2) in the same two places; "strictly proper scores prefer the teacher's channel" (Proposition G.3) in "The window and its price" and in gap (2). Separately, the weight-decay clause was joined with a semicolon to keep a three-sentence limit, which makes the first sentence of "The window and its price" 74 words long. | In gaps (2) and (3), refer back ("as above") instead of restating, or drop the restated clauses (about 4 lines). Split the 74-word sentence after "so λ must grow linearly with n". The three-sentence limit of DECISIONS-restructure §3 is a length device, and the cut above pays for the extra sentence. |
| m7 | minor | Remark 8.5 p. 27 (`teacher.tex` l.50–56) | The remark lists the disanalogies of practice (norm against code length, normalisation, SGD noise, decoupled decay, per-step action). It omits the structural one that matters most to this paper, which is stated only in App F.7. A description-length penalty selects one hypothesis on a whole interval of c (a hull vertex: windows, kinks). A smooth L2 penalty moves a nonzero minimiser with every ω. In Example F.7 only the induced classifier is stable on an interval. | After "The analogy is one of objectives.", add: "Unlike a vertex of the hull, a nonzero minimiser of a differentiable L + (ω/2)‖θ‖² changes with every ω, so the analogue of a window is a range of ω with one classifier, not one hypothesis (Appendix F.7)." |
| m8 | minor (notation) | App F.7 pp. 73–74 (`app-teacher.tex` l.168, l.175, l.178) | λ is used for the decoupled weight-decay coefficient of AdamW ("θ ← θ − η_t(α∇L(θ) + λθ)", "decoupled coefficient λ", "λ ≥ 2ε/ln((2−3q)/q)", "θ1 = 1/λ"). This is in the subsection titled "λ = cn and weight decay", in a paper where λ is the complexity weight. | Rename it locally, for example ω_d (the main text already uses ω for coupled decay). No label is affected. |
| m9 | minor (literature, abstract level) | Example F.7 p. 74 (`app-teacher.tex` l.175) | "Full-batch AdamW with decoupled coefficient λ ends near the minimiser of L under ‖θ‖∞ ≤ 1/λ (Xie and Li, 2024)". The abstract of Xie and Li (synthesis §3.4) says: *if* full-batch AdamW converges (non-increasing learning rate with divergent partial sums), it converges to a KKT point of L under that constraint. "Ends near the minimiser" drops the condition. | "If full-batch AdamW with decoupled coefficient ω_d converges, it converges to a KKT point of L under ‖θ‖∞ ≤ 1/ω_d (Xie and Li, 2024), here the constrained minimiser, since L is convex." |
| m10 | minor (DECISIONS §A10 form) | Open problems (7) p. 39 (`discussion.tex` l.51) | Items (1)–(6) each cite a `question` environment of the body. Item (7) cites only "(Section 10)", because `q:imit:open` was dropped for length. The collected list is no longer uniform, and §10 has no question of its own. | Either restore a three-line `question` (new label `q:imit:open`) at the end of §10 or of App H.1 and cite it from (7), or accept (7) as written. The questions are precise enough. |
| s1 | suggestion | Novelty p. 7 (`related.tex`) | "Known are … and our tools (dominance bounds, Ville's inequality, …)" uses "tools" for known proof techniques. The Scope paragraph uses "tools" for the paper's own offering (the private-randomness class, the kink geometry, the reuse factor, the per-sample threshold). | In Novelty, write "our proof techniques". |
| s2 | suggestion | contributions p. 5 (`intro.tex` l.36–37) | The "Imitation (Section 10)" bullet follows "Limits and computable classes (Sections 9 and 11)", out of section order. | Move the bullet before "Limits and computable classes", or split that bullet. |
| s3 | suggestion | Table 4 p. 37; Remark 3.7 p. 9 | The row "What the learner is" ("a family of batch objectives (Rem. 3.7)") and Remark 3.7 do not point to the new proof that no fixed prior gives the cn-MAPs. | Cite Remark 8.5 or Proposition F.6 in both. |
| s4 | suggestion | Remark 8.5 p. 27 | The three-paragraph remark sits between Remark 8.4 and §8.2. It interrupts the path from the schedules (Proposition 8.3) to the theorem, and it forward-references Theorem 8.7 and Theorem 10.2. | Move it to the end of §8.3, or shorten it as in §7. |

---

## 2. The caveats: abstract, introduction, discussion

### 2.1 Against the author's request (brief, message, third paragraph)

| requirement | abstract | introduction | discussion | status |
|---|---|---|---|---|
| does not claim to solve the practical motivating problems | absent | "We do not claim to solve the problems that motivate the two reasons, imitating a person and learning what a teacher means rather than what the teacher says." (p. 5) | "the problems that motivate them remain far from solved" (p. 38); "We do not expect steeper penalisation alone to solve the general problem of learning a norm from imperfect imitation" (p. 38) | met in the introduction and the discussion; **M2** for the abstract |
| offers ideas for a toolkit | absent | "We offer tools for them: the private-randomness class, the kink geometry, the reuse factor and a per-sample threshold on the rate at which a component buys fit." | "We see the results as tools for these problems, with toy cases in which the tools work, not as solutions." | met; s1 (word clash with Novelty) |
| names exactly the toy cases solved | n/a | four cases: Theorem 6.3; Proposition 7.8; Theorem 8.7 with Remark 8.9 and Proposition 8.13; Theorem 10.2; the last two for the population objective only | "it works in one toy case and fails in others" (teacher) | met; checked against the results in §2.2; m4 for two missing hypotheses |
| big philosophical problems remain, named concretely | absent | by pointer only | six gaps, each tied to a result (p. 38) | met in the discussion; m5 for the introduction |
| no overclaiming | every abstract claim traces to the body (D9 list) | "solve toy cases … up to near-copies" is accurate | gaps (1)–(6) as proved; (3) says "reliably" for a probability bound (F9, C6 applied) | met |
| no false modesty | – | the four cases are real theorems, and the paragraph says so | m3 is the one place where a proved negative is written as "we do not show" | met, except m3 |

### 2.2 The four toy cases, against the statements

| Scope paragraph says | the result proves | verdict |
|---|---|---|
| exact recovery of a computable sampler from per-query samples with i.i.d. inputs (Theorem 6.3) | Theorem 6.3(a) for every schedule 1 ≤ λ_n = o(n), with the rate (d) for fixed λ > 1, in every countable Kraft class containing the sampler | exact |
| the full table of a noisy random parity with a dyadic flip rate below ¼, for large d (Proposition 7.8) | Proposition 7.8(iii): dyadic p < ¼, fixed λ > 1, m = d → ∞ **with δE = O(d)**; C₂(λ) gives level ≤ 2 ("knows the parity") | add the typical-flip-set condition (m4) |
| the teacher: random parity, incompressible product-form rule, uniform inputs, p < 0.05596, or 0.1233 asymptotically (Theorem 8.7, Remark 8.9, Proposition 8.13) | as stated, for λ/n in the window, population objective; error-label bounds need a large rule (s0 large against the information budget) | exact at summary level |
| up to near-copies, a sampler whose coins are an incompressible function of the environment on many more cells than it has bits (Theorem 10.2) | needs ℓ0 + \|Σ\|m + δβ ≪ 2^m H(ρ), c well below H(ρ)/ℓ0, a bounded away from 1; closeness in mean D_{1/2} on the scale H(ρ); population objective, samples only eventually (Proposition D.5(c)) | exact up to the factor H(ρ) (m4) |
| "the last two for the population objective, and from samples only asymptotically or with large constants" | teacher: Proposition 8.3(c), Corollary 8.12 (about 10^11 samples at the example's sizes); imitation: Proposition D.5(c) only | exact |

### 2.3 The six gaps of the discussion, against the results

All six are supported as written: (1) §10 and Proposition 10.3; (2) Proposition G.3 and Proposition 10.3(a), with the deterministic-state clause a remark; (3) Propositions 9.2, 9.3, 10.3(b) and H.4; (4) Proposition 6.10(a); (5) Theorem 4.4, Proposition B.6 and App H.1; (6) Proposition I.1, Question 11.4, Proposition D.2(e) and Remark 8.8. The brief's list (behavioural equivalence, the choice of λ, structured errors, frozen labels, uncomputability, class and machine) is fully covered. The paragraph also adds the person/environment split and entanglement, which the imitation results make concrete. Nothing in the paragraph is stronger than its citation.

---

## 3. The imitation section

### 3.1 Does it read as a toy result with its limits?

Yes. The section itself says, in the main text:
* what is shown and what is not (paragraph 2);
* "near-copies, not copies";
* "the hypotheses that predict better gain only by storing an incompressible table";
* the population objective, with samples only asymptotically;
* behaviour, not mechanism;
* that the person/environment split is a convention (with Armstrong–Mindermann);
* "an incompressible coupling is not enough" (Proposition 10.3(b));
* cheap couplings (Proposition H.4);
* that the target ν_H is itself a modelling choice.

App H.3 shows that the parity person gets no informative bound at c = 10^{-4}. The author's "ideal theorem" is delivered in a toy form, and its main gap is stated: compact environment models, the interesting form of "alien thinking", defeat every c. The vocabulary ("person", "copy") is tied to "sampler" in the first paragraph. The paper never uses "alien".

### 3.2 Is it consistent with the split thread? Not yet (M1)

* With **private** coins (Remark H.1), imitation is the first reason. Every fixed λ > 1 returns a copy (Theorem 6.3), and fill-ins are rejected.
* With **environment-driven** coins, the labels follow P\*, not ν_H. Theorem 6.3(a) applied to the sampler P\* (which has a program in H×) says that every λ_n = o(n) eventually selects a shortest program for P\*.
  * In the feature case with |Σ| ≥ 2, P\* is deterministic. Its programs determine the coupling, so the selected program stores the person's coins.
  * In the latent case with uninformative inputs, P\* = ν_H, and fixed λ still works.
  * Copies are kept only for λ/n above about 2^{-m}: the coins are reused at every input of a cell, like an error rule, which is the second reason's geometry. The section itself notes that the teacher is the feature case.

The paper contains every piece of this. It never puts them together, and its framing (intro paragraph 2, §10 paragraph 1) points the other way. Proposed wording (the editor may polish it):

* **`imit.tex` l.16**, replace from "Fill-ins are rejected per query" to the end of the paragraph by:
  > If the person's coins are private, this is the first reason: no predictor gains over the person more than its length plus a Ville deficiency, however it models the environment (\cref{rem:imit:private}), and every fixed $\lambda>1$ eventually returns a copy, not a fill-in (\cref{thm:recovery:main}). Systems that infer from the data which person they face are excluded by the choice of the private-randomness class, not by the data (\cref{app:imit:private}).
* **`imit.tex` l.18**, after the first sentence, insert:
  > The data then follow the kernel $P^*$ of \cref{def:imit:setting}, not the person's, so a fixed $\lambda$, or any $\lambda_n=o(n)$, eventually returns a shortest program for $P^*$ (\cref{thm:recovery:main}(a)); in the feature case such a program encodes the coupling, the person with its coins stored. The coins are reused at every input of a cell, like an error rule, and a copy needs the schedule of the second reason, $\lambda/n$ above the reuse factor $2^{-m}$ (\cref{sec:teacher}).
* **`intro.tex` l.15**: in the imitation sentence, apply m1, and add after "(\cref{sec:imit})": "; with private coins this is the first reason, and when the environment drives the person's coins it needs the schedule of the second reason below". Alternatively, move the sentence after the second reason is introduced.
* **`discussion.tex` l.12**, last sentence of "Two reasons, one geometry":
  > Imitation needs both: a person's private coins are discarded at every fixed $\lambda>1$, coins that the environment drives only at $\lambda\propto n$ (\cref{sec:imit}).
* Optional: in the `tab:intro:claims` row on imitation, add "for $\lambda/n$ in a window".

These sentences add about 6 lines in all, and the M3 trims pay for them. The mathematics does not change: every claim follows directly from Theorem 6.3(a), Remark H.1 and Theorem 10.2.

---

## 4. The weight-decay remark

| | what the paper says | verdict |
|---|---|---|
| analogous | λ = cn charges the length once per sample; a fixed λ is a fixed prior, while no fixed prior with full support gives the cn-MAPs at every n (Proposition F.6(i),(ii)). Coupled weight decay on an averaged loss is MAP under a Gaussian prior of precision nω, which grows linearly in n; a fixed prior needs ω ∝ 1/n. In both cases the penalty per sample does not vanish with data, and both can keep a cheaper, worse predictor or classifier in the limit (Proposition F.6(iii),(iv); Example F.7). This is why λ must grow with n (Propositions 9.3 and 8.3(a); the near-copies of Theorem 10.2). | correct and complete for the author's point. "Keeps going on each step" ↔ "charged once per sample"; "keep preferring a simpler hypothesis that is worse at classification even in the limit" ↔ Example F.7 and Proposition F.6(iii) |
| not analogous | ‖θ‖² is not a description length (Hinton and van Camp); with normalisation layers the norm mainly sets the effective learning rate (van Laarhoven); SGD iterates are not minimisers (Mandt et al.); decoupled decay is not an L2 penalty (Loshchilov and Hutter; Xie and Li); decay acts per step, so before convergence its effect depends on the learning rate and the number of steps | correct; the structural disanalogy (no windows for a smooth penalty) is only in App F.7 (m7) |
| the reading of "params" | "as the sample size varies" throughout; the other reading (number of model parameters) is not mentioned in the PDF | for the author (§8); the decay record argues the conclusion is the same under both readings |
| placement and length | 0.62 pp in §8.1, App F.7 about 1.7 pp, one related-work sentence, one discussion clause | heavy for an analogy (M3, s4) |
| notation | λ reused for AdamW's coefficient in App F.7 | m8 |

---

## 5. Citations: abstract level only

Each new citation was compared with what the records list as checked (synthesis §3.4; `imitation-edit/literature.md` §2). All are used at abstract level, with one exception (m9).

| work | used for | abstract-level? |
|---|---|---|
| Krogh and Hertz 1992 | weight decay as a regulariser (pointer) | yes |
| MacKay 1992 | the Gaussian-prior reading of weight decay; nω is derived in the text | yes (a Bayesian framework for weight-decay terms) |
| Hinton and van Camp 1993 | information in a weight depends on its precision, controlled by Gaussian noise | yes |
| van Laarhoven 2017 | with normalisation the norm sets the effective learning rate | yes |
| Mandt et al. 2017 | SGD iterates are not minimisers | yes (a stationary distribution) |
| Loshchilov and Hutter 2019 | decoupled decay is not L2 in adaptive methods | yes |
| Xie and Li 2024 | AdamW limit under the ℓ∞ box | the condition "if it converges" is dropped (m9) |
| Power et al. 2022; Liu et al. 2022 | grokking (no weight-decay claim) | yes |
| Liu et al. 2023 | grokking related to the weight norm and weight decay | yes |
| Nanda et al. 2023 | memorisation, then a cleanup that removes memorising components | yes (the abstract's closing sentence) |
| Zhu et al. 2026 | a large complexity weight as a sample-size-dependent prior ("read") | yes (abstract paraphrase; the verb "read" is kept) |
| Bain and Sammut 1999; Pomerleau 1991; de Haan et al. 2019 | behavioural cloning as supervised learning; more information can hurt; interventions identify more | yes |
| Zhang et al. 2020 | a graphical criterion for imitation with unobserved confounders | yes |
| Ng and Russell 2000; Armstrong and Mindermann 2018; Cao et al. 2021 | many rewards qualify; no unique planner–reward split, even with a simplicity prior; identification up to a constant from different environments | yes |
| Cohen et al. 2022 | a Bayesian imitation learner for never-resetting environments | yes |

No sentence uses an item marked "[beyond abstract]" in the literature record, and none says how the literature was checked.

---

## 6. REFRAME and DECISIONS compliance

| check | result |
|---|---|
| DECISIONS §A5 vocabulary grep on `pdftotext main.pdf` | only the title footnote's "independent AI referees"; every other hit is a formula fragment (c1, s0, E0, r0, S1, …) |
| §A2.5 status grep on the PDF | 0 hits; `\status`/`\src` are redefined to print nothing (`preamble.tex` l.122–123) |
| §B.6 Wyeth | 0 in the PDF |
| REFRAME §4: the author's notes outside footnotes and acknowledgements | none; `hanni2026grokking`/`hanni2026notes` appear only in footnote 1 (p. 2), footnote 2 (p. 14) and the acknowledgements |
| REFRAME §7: "the author" in the body | none outside the title footnote, the footnotes and the acknowledgements |
| "we" voice in the new text | yes ("we show", "We do not show", "We offer tools", "We see the results as tools") |
| `\status` and `\src` on theorem-like environments | present on all of `thm:imit:main`, `prop:imit:limits`, `rem:imit:private`, `lem:imit:coding`, `lem:imit:closeness`, `prop:imit:cheap`, `rem:teacher:weightdecay`, `prop:teacher:nofixedprior`, `ex:teacher:weightdecay`; `def:imit:setting` carries `\src` only, like all 11 definitions of Paper 2 |
| labels | none renamed (the log's list of new labels matches the sources) |
| §A9 computed numbers | outside statements, with "A direct computation (code in the accompanying repository)" and "(an illustration)" for the κ = 0 values (App H.3, H.5, F.7) |
| footnotes for credit (at most 5) | 2 |
| build log | 0 errors, 0 undefined or multiply defined; two overfull boxes of 1.84 pt and 2.75 pt |

---

## 7. Length

Measured values are taken from `log-integrate.md` §7. The page count of 86 and the page positions were re-confirmed here.

| part | cap (DECISIONS-restructure §3) | now | over |
|---|---|---|---|
| main text (title to Code and data) | 33.5 | 39.08 | 5.58 |
| appendices | 37.5 | 42.89 | 5.39 |
| total | 73.5 | 85.66 | 12.16 |

The main text was already 1.0 pp over before this request. Trims that lose no result, each with its rough saving:

* **§10** (2.33 pp):
  * move the last two sentences of Theorem 10.2 (the bound on Φ and the program for P\*) to App H.3, keeping one clause on fixed λ for M1 (about 0.15 pp);
  * drop the proof idea of Proposition 10.3 (0.07 pp);
  * move "An incompressible coupling is not enough …" and the literature sentence of the last paragraph to App H.4 and to related work (about 0.15 pp).
* **Remark 8.5** (0.62 pp):
  * keep the first two sentences of paragraph 1, paragraph 2, and the first sentence of paragraph 3 with its four disanalogies;
  * move "Per query, for c > c\* …", "The window of Theorem 8.7 … is an instance" and the grokking sentence to App F.7 (about 0.25 pp).
* **Discussion:** remove the three duplications of m6 (about 0.1 pp).
* **Related work:** use the fallback version of the imitation paragraph from literature §3.1 (about 0.25 pp; four fewer references).
* **App F.7:**
  * drop "Full support cannot be dropped from (ii) …" (6 lines);
  * drop the AdamW sentence of Example F.7 and the box part of its proof idea (5 lines).

  This also removes m8 and m9.

Together these save about 1.1–1.4 pp of main text and about 0.3 pp of appendix. That is not enough to reach the caps. Whether the caps still apply after this request is the author's decision (M3).

---

## 8. Points for the author

1. **Imitation and the two threads (M1).** The cleanest summary the results support is this. *Imitation needs both reasons: a person's private coins are discarded at every fixed λ > 1, but coins that the environment drives are discarded only at λ ∝ n, and then only near-copies are guaranteed, against better predictors that store an incompressible table.* We recommend saying this in the introduction, §10 and the discussion.
2. **The abstract (M2).** Add one caveat sentence, either with the cuts proposed or by raising the 1920-character cap.
3. **Length (M3).** Decide whether the caps of DECISIONS-restructure §3 still bind. The imitation material totals about 7 pp, for a result that the synthesis rates "modestly" cool. The 1.3-page fallback of synthesis §5.3 is still available if a lighter weight is preferred.
4. **"As the number of params varies."** The paper reads this as the sample size. If model size was meant, one sentence covers it (from the decay record's header): in both λ = cn and weight decay the charge per unit of model grows with n, so neither is a fixed prior over models of any size.
5. **Novelty.** `rem:related:new` claims no novelty for the near-imitation theorem, the closeness lemma or Proposition F.6. This is conservative. The search behind any such claim was four queries (log §9 item 3).
6. **Armstrong–Mindermann** is cited at abstract level only. A comparison with its simplicity-prior argument, which is the closest prior result to "behaviour, not mechanism" under a simplicity prior, would need the full text.

---

## Verification log

* **Reading.** As listed in the header. The PDF text was extracted with `pdftotext -layout` into the session scratchpad and read from title to the last page. The page numbers above were found with `pdftotext -f p -l p` lookups.
* **Greps on `pdftotext main.pdf`.**
  * The DECISIONS §A5 regex: only the footnote word plus formula fragments.
  * The §A2.5 status regex: 0.
  * `wyeth`: 0.
  * `author|notes|draft`: footnotes 1–2, the acknowledgements and the bibliography only.
  * `alien|synthesis|record|sub-track`: 0.
* **Sources.**
  * `abstract.tex`, `intro.tex`, `imit.tex` and `discussion.tex` were read in full.
  * `app-imit.tex` and `app-teacher.tex` were read in the PDF and checked at the lines cited.
  * The environment check: a shell loop over `\begin{…}` lines of `imit.tex`, `app-imit.tex`, `teacher.tex` and `app-teacher.tex`; all theorem-like environments carry both tags, and the definitions carry `\src` only (0 of 11 definitions in Paper 2 carry `\status`).
  * `main.log`: two overfull boxes below 3 pt, no LaTeX warnings counted.
* **Character counts** (Python, `-I`):
  * the abstract body is 1920 characters;
  * the proposed sentence is 105 characters with its leading space;
  * the two proposed cuts are 62 and 61 characters and occur verbatim in the abstract.
* **Not done.**
  * No mathematics was re-proved.
  * No WebSearch: the citation verdicts compare the text with the records' abstract-level entries.
  * No build.
  * No edit outside this file.
  * No git command.
