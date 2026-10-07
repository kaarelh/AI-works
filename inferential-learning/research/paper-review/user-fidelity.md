# Review: fidelity to the commissioning person's notes and preferences

Reviewer lens: how faithfully the paper represents Kaarel Hänni, who posed the question, and his notes at `/home/user/kaarelh/notes`. This covers quotation accuracy, hedging, tone, attribution (both over- and under-attribution), how the paper refers to him, the title page, and how his stated views are represented (pluralism about meaning, distrust of limit framings, verification-first motivation, caution about publishing capability research).

Method:
* I grepped every `.tex` file under `paper/` for `user`, `notes`, `Hänni`, `Sam`, `wtf`, `L10` and quoted strings.
* I opened every note the paper quotes and checked each quotation verbatim against the original file. Notes checked:
  * `logic/a 'philosophical version'…`
  * `beating solomonoff…`
  * `ai/DLK/{DLK notes, june meeting notes, logic}.md`
  * `verification from truth.md`
  * `the structure of physics olympiad solutions.md`
  * `…general principles.md`
  * `is verification really easier…`
  * `a few notes on frames.md`
  * `assigning probabilities in a conception…`
  * `the domain of applicability…`
  * `introspect-solving eupho 2025-T1.md`
  * `physics/symmetry.md`
  * `how come mathematicians…`
  * `why is it a good idea to make vague notions precise?`
  * `how do i resolve contradictions, tensions?`
  * `logical models as distinct from mental models.md`
  * `math is a mere string game iff everything is.md`
  * `how are the natural numbers pinned down?`
  * `logic/confusions/soundness.md`
  * Advent-of-thought 1f, 3f (footnote 5) and 99n
  * `Trajectories of moral-reflective flight…`
  * `formalizing philosophy.pdf`
  * the notes' `README.md`
* I also read `research/lit/L10-user-notes-digest.md` and the brief.

## Summary

Most verbatim quotations are accurate. In particular, the simplicity section quotes `beating solomonoff…` with care, and the physics quotes on 100 = 99.9, reductio and "wtf is that???" match their sources.

The problems lie in framing, attribution and hedging:

1. **"The user" appears on 56 lines**, in 10 section files (existence 19 lines, physics 15, twotier 7, informal 5, coherence 3, setting 2, imitation 2, caution 1, plus 2 appendices). It even appears in a subsection title ("Reading in the user's terms", §7.9, which is in the table of contents). This is unsuitable for a paper. Naming is also inconsistent: the abstract says "the notes that motivated this work", §8 says "K. Hänni's notes", and everywhere else it is "the user". The intro never says who posed the question; only the title-page footnote does.
2. **The notes are never cited.** There is no bibliography entry and no URL. They are described as "publicly available" (§13.5) and also as "unpublished" (§8, footnote). The notes' README matters here and the paper ignores it. It says the notes are public as of June 2026, but that he does "not think of [himself] as publicly asserting the things I'm saying in them in quite the way that I would be if I e.g. published a paper". It also says "various claims I make in these notes are wrong". The paper nonetheless grades his notes as if they were asserted claims ("The user is right that…", "This is correct for complete consistent assignments", "the user's proposition").
3. **Hedges are removed in several places**, making him sound more certain:
   * "maybe this is some argument in favor of trusting 'constructive' reasoning" became "This is why his 'constructive' reasoning is more trustworthy".
   * "I think this is an argument that any assignment…" became "The user's DLK note says that any assignment…".
   * "existing solutions from the wild often … more of a dance" became "An olympiad solution is … a dance".
   * The robust-core explanation, offered for "this particular case" (functions), became a general hypothesis.
4. **Over-attributions:**
   * The DLK constraints are presented as what "the user's notes … impose". In fact they are meeting-note brainstorms; one sits next to "suggestion from Alex", and the MP constraint is "one choice would e.g. be", just after "that seems like an arbitrary choice".
   * The interactive checker becomes "the architecture the user sketches", though it is a passing remark about questioning friends.
   * "The user's view that justification is an infinite endeavour" is not what the notes say: they say thinking, mathematics and "how should one think?" are infinite endeavors.
   * The C-model/L-model "C-model without an L-model" is put in quotation marks although it is not his phrase. The note is also headed "text below now disendorsed probably", and the paper does not say so.
   * A third party is cited as "Sam" with no surname, and the quotation from that note cuts off the note's own answer to "what is this image?".
5. **Misrepresented views:**
   * The frames note says plural frames are "very useful" and "needn't be easily reconcilable". The paper turns this into "The user worries that frames…".
   * The verdict that the philosophical completeness theorem "fails in the intended sense" credits him with an intended (standard-model) reading. The notes themselves already reject that reading in the Gödel-sentence footnote.
   * The philosophy section presents the whole setup as reflective equilibrium, and says this "matches" his suspicion of limit framings. It ignores his note "Trajectories of moral-reflective flight — an alternative to reflective equilibrium", which calls reflective equilibrium "pretty flat/dead".
   * The publication caution is softened. The source says publishing insightful research on AI theorem provers is "omnicidal"; the paper says "flag as risky". In addition, open problem 8 recommends how "any such work" on strong provers should be done.
   * The abstract says "eternalism is provably impossible", about an option he raised. Yet the theorem refutes only truth-functional readings, and the paper itself adopts "meta-level eternalism".
6. **Success criteria:** the intro table answers "Yes" to his criterion 3 ("a principled system for checking physics olympiad solutions"), while §11 says the mini-checker "is not a system". It answers "Yes" to criterion 2 while §10 says "history violated realizability at every decisive step". The intro also omits his verification-first motivation and adds a capability framing ("a reasoner that derives many correct conclusions").

The title-page footnote ("Prepared in response to questions by Kaarel Hänni. Draft; authorship and publication to be decided by him.") is appropriate in substance. It should be extended to cite the notes and state their status.

No fatal issues: no quotation is fabricated. Each issue is listed in the structured output, with file, location and replacement text. Detailed findings follow.

## Detailed findings

### A. How the paper refers to him (all sections)

"The user" occurs on these lines:
* existence.tex 32, 38, 40, 75, 151, 166, 169, 193, 198, 204, 273, 295, 310, 336, 342, 350, 368, 374, 383
* physics.tex 29, 37, 49, 78, 123, 308, 497, 533, 556, 967, 999, 1007, 1008, 1089, 1156
* twotier.tex 32, 246, 386, 460 (subsection title), 464, 466, 468
* informal.tex 36, 142, 166, 437, 467
* coherence.tex 34, 171, 204
* setting.tex 383, 466
* imitation.tex 128, 269
* caution.tex 217
* app-coherence.tex 123
* app-existence.tex 127

Recommended convention:
* Introduce him once, in §1.1, by name, as the person who posed the question, and cite the notes.
* Afterwards, write "the motivating question" or "the question as posed" for the request, and "the motivating notes" or "the notes" for the note files, giving the file path at first quotation.
* Do not write "the user", and do not use "he"/"his" detached from a referent.
* Keep "K. Hänni's notes" (§8) only if the intro introduces the name. Otherwise change it to "the motivating notes" for consistency.

Per-line replacements are given in the structured issues.

### B. Citation and status of the notes

* No `.bib` entry and no URL for github.com/kaarelh/notes. The repository is MIT-licensed and public; its README is dated June 2026.
* philosophy.tex:158 says the notes are "publicly available". simplicity.tex:30, footnote, says "(unpublished)". These contradict each other.
* The README's status caveat should be reported. Its footnote 1 also asks to be added as coauthor or acknowledged; the title footnote covers that.
* "An Advent of Thought" (notes 1f–3f, 99n) was posted on the AI Alignment Forum from 14 March 2025, per `0f advent of thought (2024) meta.md`. It is citable as a published essay series.
* Six internal memo citations stand in for his notes: "(L10 §1.5)", "(L10 §1.3)", "(L10 §1.7)", "(L10 §1.8)" ×3, and "L9 §8.2". Readers cannot reach them. Replace them with the note paths.

### C. Quotation checks (verbatim against source)

| Paper location | Verdict |
|---|---|
| simplicity.tex 30–34, 70, 124, 172, 309, 373, 391, 416, 420 | Verbatim (ellipses fair). "very much uncertain", "1 bit paying for 1 bit", "pay the likelihood term separately at every $x$", chair, rabbit/chicken, abstract/concrete: all correct. |
| existence.tex 34–36 (block quote) | Verbatim. |
| existence.tex 38 (Sam) | Verbatim, but the next line of the note answers the question: "this is all sets of sentences closed under inference rules. this is by the completeness theorem". The paper omits it and then presents "Proposition (Sam's image)" as the answer. |
| existence.tex 38 (Gödel caveat) | Verbatim. Source: 3f footnote 5, not "L10 §1.5". |
| existence.tex 166 (DLK) | Over-attributed. "impose" is wrong. The identity appears below "suggestion from Alex" (`DLK notes.md` l.147–152). The MP constraint (`june meeting notes.md` l.70–72) follows "seems like an arbitrary choice". Negation coherence restates the CCS loss. |
| existence.tex 273 (frames) | Words verbatim, sense inverted (a "worry" in the paper; "very useful" in the note). |
| existence.tex 295, physics.tex 37–38, 959–960 | Verbatim. philosophy.tex 170 changes the case and turns "???" into "?". |
| existence.tex 336 (DLK logic.md) | Drops the hedge "I think this is an argument that". |
| existence.tex 368 | Verbatim. Omits that the question is about pinning the numbers down "in a brain, to a thinker, or something". |
| existence.tex 383 "C-model without an L-model" | Not a quotation. The note is a draft comment marked "now disendorsed probably". |
| existence.tex 383 "hooking onto the world" | Not verbatim. The note has "hooking of a model onto the world" (twotier.tex 466 has it right). |
| informal.tex 36 | Verbatim. The robust-core passage is "an attempt at an explanation for this particular case" (functions). |
| informal.tex 142 "explain/justify/derive" | Verbatim words, but "the architecture the user sketches" overstates a passing remark about questioning friends. |
| informal.tex 437 (Euclid) | Verbatim. |
| informal.tex 467 | Verbatim ("we created a language in which formal proofs can be written"). "says as much" stretches it to ε-δ and the fundamental group. |
| caution.tex 217 "inventing a language" | In quotation marks but not verbatim. |
| twotier.tex 464 "go back to what caused the contradiction" | Not verbatim. Source: "go back to what caused one (or each) of the contradicting views/predictions/claims". |
| twotier.tex 468 "justification is an infinite endeavour" | Misattribution (see A/5 above). |
| physics.tex 29–31 "a dance…" | Words verbatim; the hedge "existing solutions from the wild often … more of a dance" is dropped. |
| physics.tex 78–81, 497–499, 556–557 | Verbatim. |
| physics.tex 560 "his 'constructive' reasoning is more trustworthy" | Hedge removed. Source: "maybe this is some argument in favor of trusting 'constructive' reasoning more … at least in messy domains". |
| physics.tex 966–967, 999, 1008 | Verbatim. The "peeked" line is about whether a finger in the part-(b) photograph is tilted, and the paper gives no context. Answer: "ok yay this is the correct ans!" |
| physics.tex 1156 (symmetry) | Accurate. |
| intro.tex 84 | Altered quotation: "is coherent" for "makes sense (is coherent)". |

### D. His views

* **Pluralism about meaning.** philosophy.tex 148–154 correctly says inferential role is one aspect of meaning. It lists the other aspects ("hooking", activities a concept supports, questions it lets one ask) without crediting the notes, where all three appear. The notes credit "compositional inference warranting" as "one aspect" only. Minor fix: attribute.
* **Distrust of limit framings.** philosophy.tex 36 claims a "match". The notes distrust *convergence to a point*, and in particular reflective equilibrium (`99n`; `Trajectories of moral-reflective flight — an alternative to reflective equilibrium.md`: "All this seems pretty flat/dead to me"). The paper's central philosophical claim is that the setup *is* (narrow or wide) reflective equilibrium. Its main theorem (`thm:twotier:main`) is convergence to a fixed target modulo residue. The tension should be stated, not presented as agreement.
* **Verification-first motivation.** It appears only obliquely (philosophy.tex 37). The intro omits it. The sources are `formalizing philosophy.pdf` (safety with an untrusted prover; "we might have lost all the safety") and `some good questions in conceptual alignment.md`, item 4. The search section's central mechanism (one rare bad rule exploited by search) parallels his own observation (`solomonoff function induction.md`: "doesn't work that well when there is a simple property distinguishing test from train") and is not credited.
* **Caution about publishing capability research.** Source (`formalizing philosophy.pdf`, July 2024 draft): "in my opinion, publishing such research is omnicidal" (about "insightful research on AI theorem-provers"). The paper says only "capability work is the part the user's notes flag as risky" (physics.tex 49). open.tex item 8 then recommends how "any such work" on a strong prover should be organized. The title footnote's "publication to be decided by him" is good. The body should state the view accurately and not give implicit how-to advice for prover building on his behalf.

### E. Title page (main.tex)

The footnote is right in substance. I suggest extending it, keeping the author line, as follows:
```
\thanks{Prepared in response to questions posed by Kaarel H\"anni; the design and success criteria in \S\ref{sec:intro:question} are his. Quotations from his public working notes \citep{hanni2026notes} are verbatim and cited by file path; as the notes' README says, they are working notes rather than claims asserted as in a paper, and the readings here are ours. Draft; authorship and publication to be decided by him.}
```

## Issue list (file, location, severity, fix)

The same list is returned as structured output. Severity follows the rubric: fatal = false or seriously misleading; major = real gap, inconsistency, misattribution or overclaim; minor = local.

### Major

1. **intro.tex §1.1, l.5–20.** The intro never names who posed the design and criteria and never cites the notes, yet later sections say "the user", "his", "K. Hänni's notes". The verification-first motivation is missing, and l.14 adds a capability framing ("a reasoner that derives many correct conclusions"). Fix: name him and cite the notes at l.5; replace l.14 with a question about trusting arguments from an untrusted generator; add a motivation paragraph after l.20 (text in structured output).
2. **intro.tex Table 1, l.102–103.** Criterion 2 is answered "Yes, relative to realizability", but §10 says history violated realizability at every decisive step. Criterion 3 ("a principled system for checking") is answered "Yes", but §11 says the mini-checker "is not a system". Fix: answer criterion 2 "Conditionally" and criterion 3 "A principled design, not yet a system" (text in structured output).
3. **intro.tex l.84.** The quotation is altered ("is coherent" instead of "makes sense (is coherent)"). "It fails in the intended sense" credits the notes with a standard-model reading that their own Gödel-sentence footnote already rules out. Fix: quote verbatim; write "positive in the generalized sense the note asks for; intended-model existence is not certifiable, as the notes anticipate".
4. **main.tex l.6, title footnote.** The footnote does not cite the notes or say what kind of document they are. Fix: extend it as in §E above.
5. **bib/philosophy.bib.** There is no entry for the notes or for "An Advent of Thought". Fix: add `hanni2026notes` and `hanni2025advent` and cite them at first quotation.
6. **simplicity.tex l.30, footnote.** It says "(unpublished)", but the note is in the public repository, and philosophy.tex l.158 calls the notes "publicly available". Fix: cite as a public working note; use "the motivating notes".
7. **existence.tex.** "The user" appears on 19 lines, and "L10 §1.5" stands in for the source. Fix: apply the per-line replacements.
8. **existence.tex l.38, 40, 57, 121, 379.** "Sam" is unidentified. The quotation drops the note's own answer to "what is this image?". Fix: identify him, hedged and to be confirmed; quote the answer; rename the proposition "The image of the round trip".
9. **existence.tex l.273.** The frames note's pluralism (plural frames are "very useful") is turned into a "worry". Fix: quote the note's view accurately.
10. **existence.tex l.166, 169, 193.** DLK meeting-note brainstorms are called constraints "the user's notes impose", "the user's MP constraint" and "the user's identity". Fix: describe them as tentative, partly a collaborator's, and note that negation coherence is the CCS loss.
11. **existence.tex l.336.** The DLK quotation drops the hedge "I think this is an argument that", and the next sentence then corrects the claim. Fix: restore the hedge.
12. **existence.tex l.383.** "C-model without an L-model" is put in quotation marks but is not his phrase, and the source note is marked "now disendorsed probably". "hooking onto the world" is not verbatim. Fix: rephrase, flag the disendorsement, and quote "the hooking of a model onto the world".
13. **existence.tex l.385.** "Not vindicated in the intended sense". Fix: "does not deliver intended-model existence, as the notes' Gödel-sentence footnote anticipates".
14. **physics.tex.** "The user" appears on 15 lines; "L10 §1.7/§1.8" stand in for sources; l.533 has the grading tone "The user is right that". Fix: apply the per-line replacements.
15. **physics.tex l.560.** The hedge is removed ("This is why his 'constructive' reasoning is more trustworthy"). Fix: quote "maybe this is some argument in favor of…" with its source.
16. **physics.tex l.47–49.** The publication caution is understated as "flag as risky"; the source says "omnicidal". Fix: state the view accurately, with its source.
17. **open.tex item 8.** The recommendation on how "any such work" on strong provers should be done sits uneasily with the notes' view. Fix: replace it with a neutral statement.
18. **philosophy.tex l.24–36.** The paper frames the setup as reflective equilibrium and claims a "match" with his suspicion of limit framings. This ignores his "alternative to reflective equilibrium" note. Fix: state the tension and the scope (fixed target, as opposed to open-ended development).
19. **twotier.tex.** "The user" appears on 7 lines, including the §7.9 title. The l.32 quotation comes from a paraphrase of the request. Fix: apply the replacements.
20. **twotier.tex l.468.** "The user's view that justification is an infinite endeavour" is a misattribution. Fix: "thinking and mathematics are 'infinite endeavors'".
21. **informal.tex.** "The user" appears on 5 lines. Fix: apply the replacements.
22. **informal.tex l.142.** "The architecture the user sketches" over-attributes a passing remark. Fix: attribute the phrase only.
23. **abstract.tex l.11 (and intro.tex l.74).** "Eternalism is provably impossible", about his option, although only truth-functional readings are refuted and the paper adopts meta-level eternalism. Fix: restate.
24. **coherence.tex l.34, 171, 204.** "The user". Fix: apply the replacements.
25. **setting.tex l.383, 466; imitation.tex l.128, 269.** "The user", and a quotation from a paraphrase of the request (setting l.466). Fix: apply the replacements.

### Minor

26. **caution.tex l.217.** "inventing a language" is in quotation marks but not verbatim, and "the user" appears. Fix: quote "a language in which formal proofs can be written".
27. **twotier.tex l.464.** The quotation is not verbatim. Fix: give the source wording.
28. **informal.tex l.36.** The robust-core passage is "an attempt at an explanation for this particular case" (functions), not a general hypothesis. Fix: state its scope.
29. **informal.tex l.467.** "says as much" stretches the source. Fix: "Compare…".
30. **physics.tex l.29–31.** The hedge on the "dance" quotation is dropped. Fix: restore it.
31. **physics.tex l.999, 1089.** The "peeked" quotation lacks its context (the finger in part (b)), and "the user's slip" reads poorly. Fix: add the context and phrase it respectfully.
32. **existence.tex l.368, 374.** The cognitive framing of the natural-numbers question is omitted, and "as the user himself notes" is a stretch. Fix: rephrase.
33. **philosophy.tex l.148–153.** The other aspects of meaning come from the notes but are not credited, which hides his pluralism. Fix: credit them.
34. **philosophy.tex l.158 and l.170.** "publicly available" is uncited, and the "wtf" quotation is altered. Fix: cite, and paraphrase the table entry.
35. **abstract.tex l.13.** "settle" overstates (simplicity is answered "Partly"). Fix: "answer".
36. **intro.tex l.18.** Criterion 3 silently drops "solving … or". Fix: give it in full and state the choice of the checking reading.
37. **search.tex §3 opening.** The notes' parallel observation (function induction fails when "a simple property distinguish[es] test from train"; "lost all the safety") is not credited. Fix: add one sentence.
38. **app-coherence.tex l.123, app-existence.tex l.127.** "The user". Fix: apply the replacements.
