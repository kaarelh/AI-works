# The lead's decisions on the referee round (for the editors of the section sources)

Five referees read the assembled note (`verification/referee-reader.md`, `referee-math.md`, `referee-consistency.md`, `referee-references.md`, `reproduction.md`), after a second check of each part had been applied by a fixer. This file says what is to be done with their findings. It is a working file and stays on the working branch.

## 1. Who edits what

* Each editor edits one section source in `research/sections/` and, where a correction requires it, the proof file of the same part in `proofs/`. Nothing else.
* The lead edits `intro.md` (Section 0), `open.md` (Section 13), `toy.md` (Section 11), `related-work-final.md` (Section 12), `references-short.md`, `references.md`, `README.md`, `verification/README.md`, `assemble.py`. Findings on these files are the lead's; an editor who sees something that concerns them reports it and does not edit.
* `note.md` is generated (`python3 research/orchestration/assemble.py`, from the project folder). Nobody edits it. Line numbers in the referee reports refer to the note as assembled on 16 November at 03:11; the text has moved since, so find passages by their words.
* `research/orchestration/patches.py` is now empty: the earlier replacements are written into the section sources. Ignore every remark in the reports about patches.

## 2. General rules

1. **Every finding of the four reports that concerns your section source is to be decided**: applied, applied in other words, already settled (say by what), or rejected (say why). The second-round fixer of your part settled many already; the referee of the mathematics marks those "already corrected in the sources of 04:19". Check that they are in fact in your file.
2. **Check before you apply.** A replacement proposed by a referee is a proposal. Compare it with the proof file. The reader marked with (*) the replacements that restate his own reading; those in particular. If a proposal is wrong, correct it.
3. **Length.** The word limits of the outline do not bind in this round. Add what a finding requires: a hypothesis, a definition, a sentence that says what a statement does not give. Do not cut content to make room, and do not pad.
4. **Style** as in `research/outline.md`: plain words, full sentences, no coined terms without a definition at first use, the result before the construction, "What it does not say." after a main statement. No advertising.
5. **Do not weaken or strengthen a mathematical statement** beyond what a finding establishes. If a correction changes a statement, the proof file must agree; change it there too, mark the passage "(editor, referee round)", and add a short subsection "Referee round" to the proof file's section "Checking" that lists what was changed and who has seen it.
6. **New mathematics.** If a finding makes you write an argument that nobody has checked (a proof of V1(c), an idea of a proof), write it in the proof file as well, check it by hand and, where it has numbers, with a script in `proofs/code/` (saved output next to it), and report it under `unchecked` so that it can be given to a second reader.

## 3. Conventions that hold for the whole note

**Labels.**
* The three steps of Section 2 are called **Protocol R** there, by name.
* **H1** and **H2** (never "Theorem A", "Theorem B").
* **N6** is the statement of Section 4.5 only. Section 3.2 cites it as "(N6, Section 4.5)" and may add the variant with other constants by its number in the proof file.
* **S2** is to be stated, as a proposition with its status, at the head of what is now "What S2 needs" (lower-bounds block of Section 6.1).
* **R6(a)** is stated in the form "at most L·(i₀ − 1) ≤ L·(2^K − 1) …, i₀ − 1 being the number of hypotheses ranked before f in an order by non-increasing weight".
* **R6(c)** is "proved here" without a mark: the second check, the fixer and the referee of the mathematics each went through its proof.
* **Ab5** is new: `research/sections/shift-abstain.md`, end of Section 7.4; `proofs/shift-abstain.md`, Section 7.4. It is being checked separately.
* Cite parts of statements by their letter: R6(b), not R6.

**Letters.**
* V1(a): **r** for the probability that a validation round records a disagreement, **r̂** for the recorded rate, **s_P** for the human's own rate of disagreement with a second draw (not ρ, ρ̂, s). ρ stays the scaffold's random bits.
* R3a: **ζ** for the slack (done).
* L4: the squared Hellinger distance at call j is written **H²_j** (not h_j, which is the history in Section 1). Define H²(p, q) := 1 − Σ_y √(p(y)·q(y)) in the statement.
* I1 and its surroundings: **γ** for the separation (not δ).
* Sections 8.4 and 8.5: **λ** for the rate of the exponential weights (not η), **κ** for the strength of the tilt (not β).
* Section 8.3: **K_ν** := log₂(1/w(ν)) (not K(ν)).
* **K(Q)** is "the length of a shortest program that decides the set Q"; say so at its first use in Section 4.1 and again in the first paragraph of Section 7, with **sep(x; A)** := the least K(Q) over the decidable sets Q that contain x and no element of A.
* A region of inputs in R7 and N1 is written **X₀** (not Q). Q with a subscript stays the law of a run.
* N7 and the table of Ab4: the number of questions is written **Qu**, as Sil and Abs are.
* Ab4, last row, and the sentence after the table: **p_s** for the probability of a silent failure and **p_a** for the probability of an abort (not σ and a).
* Ab2(d): **G** for the logarithmic term (not Γ, which is a set of tasks in S3).
* Other letters stay, unless two meanings meet in one subsection.

**Terms.** "The deployed run" (not "the run that counts"). Drop "the ladder" as a name. "Questions put to the human at random (audits)" at the first use of "audit" in a section. "The class of N2" (not "a needle class"). Explain the letters of "Rule NH" and of "Protocol AB" where they are introduced, or drop the letters. "The human's answer distributions P(·|x)" (not "kernel"). Define "memoriser", "patch", "a class without patches", "isolated", "the driver", "trap", "rock", "whitelist" at first use in the section that uses them. The reader's table in his finding F18 has wordings.

**The two papers of this repository.** At the first use in a section write "Paper 1" or "Paper 2" with a pointer "(see References)"; the list of references has both with title and path.

**Attributions to the researcher's notes.** The seven tests of Section 10 and "Observation B" (Ab3) are derivations of this project's digest of his notes (`research/understand/notes.md`, Sections 5 and 6.2), not his: say so, in the words that `verification/referee-references.md` proposes. Supported by the digest and to be kept or added: the claim cited in Pr2(a) ("as the researcher's notes claim"); the random-stopping argument behind R7 (digest, Section 2.10: the argument is his, the lemma in its exact form is the digest's); the steeper prior, weights w^λ with λ > 1 together with private coins, as his proposal for telling the sampler from the sampler with its coins filled in (digest, Section 2.4; developed in Paper 2).

**Marks of checking in the note's text.** Remove a mark that the second check has made obsolete ("not independently checked" for a statement that the second check verified). For a work that nobody in the project read in the source, the note does not carry a mark in the running text; `references.md` records for every work how it is known, and the list of references will say so. Keep a mark only where the correctness of a sentence of the note depends on an unread source, and then write "(not read in the source)".

**The order of K for a person** is written "of the order of 10⁹ bits" everywhere; the hedge and the source are in Section 9.1 only.

**Where a bound in K is a main result,** the place that states it says that it is empty for a person under a generic prior (reader, Part G: missing at R3, Ab1, I1 and E1).

**"What it does not say."** is the label everywhere (not "Not said", not "What S1 does not say"). The sketch of a proof is "*Idea.*"; a proof is "*Proof.*".

## 4. Decisions on single findings

**Structure of Section 1 (reader F20, item 3).** The three paragraphs of caveats on A1 to A3 (BLOCK A of `assumptions.md`) move behind the theorems: the assembly will place BLOCK A as a new Section 3.7, "The assumptions in practice". The editor of `assumptions.md` rewrites BLOCK A for that place (it may now name R1, R3, V1, E1) and adds a new block, marked `<!-- BLOCK A0` and placed before BLOCK A, of at most three sentences for Section 1: one sentence for each assumption saying in plain words what may fail, with a pointer to Section 3.7. The editor of `rehearsal-core.md` changes nothing for this.

**Reader F4 (failing obviously, the published result on batches).** Worked out: Proposition Ab5. The editor of `shift-abstain.md` applies the findings of the two reports on Ab5 (`verification/shift-abstain-ab5-check.md`, `-attack.md`) to the proof file and to the Ab5 block. The editor of `assumptions.md` changes test 6 of Section 10 and the objection "silent failures" of Section 9.5 accordingly: for a deterministic human, a known bound on K and inputs known as a batch in advance, a rule that is silently wrong on at most a fraction ε of the batch and refuses little on the law of its questions is a theorem at a price linear in the bound (Ab5); it does not act on inputs that arrive one at a time, and its ε is a fraction of a batch and not a bound for a run; nothing in the note acts on new inputs one at a time, is never silently wrong and needs no assumption.

**Reader F5, F6, F7, F15, F16, F27, F28, F29, F30 (Sections 9 and 10).** Accepted, with the reader's wordings as the starting point: the paragraph "The human reads what the imitator wrote" in Section 9.5 (check Proposition 1.16 of `proofs/assumptions.md` first); I1 keeps the factor L·K and is empty for a person; a list of the bets opens Section 9; "What survives" names the two guarantees without K (R7, Pr6); the sentence on what a prior built from knowledge can buy (Proposition 2.4); the cells and paragraphs of tests 1, 3, 4, 5; three sentences with the verdicts of the seven tests for the imitator built from tests (Pr6); the objections as sentences. The break-even numbers of O22 (reader F29(b)) may go into test 5 if they are checked first.

**Reader F31 (one statement per number; the result first).** Put the result before the construction where this is a matter of the order of sentences (N2, N2b, N5, N8, R5, Pr5). Do not split or renumber statements.

**Reader F23.** The paragraph on what becomes of the researcher's objection goes after Pr5 (editor of `property-online.md`), with the sentence on properties that no short program decides in Section 8.5. The sentence on why the estimate of Section 8.3 belongs to the property idea goes into 8.3 (editor of `property-batch.md`).

**Consistency, finding 19** (add "not independently checked" at four pointers): rejected. The second check has since verified all four statements.

**References, findings 1 to 10 and the 15 replacements of its Section 3:** accepted. Finding 13 (what Li and Zhang leave open, now read in the source by that referee): the editor of `one-mind.md` may add the sentence proposed there for Section 5.1.

**Mathematics, F5** (V1(c) has no printed argument): add the argument in the note and in the proof file. **F9** (R7 where no hypothesis fits the recorded answers): accepted. **F16** (terms "outcome of a run", "unfaithful run"): define both in Section 1.

## 5. What an editor hands back

A list of decisions, one for each finding that concerns the section (report, number, decision, and the old and new sentence where text changed); the statements or arguments that only the editor has seen; anything that concerns a file of the lead or of another editor.
