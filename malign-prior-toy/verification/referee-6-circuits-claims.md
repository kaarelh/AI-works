# Referee report 6 (claims) on Section 7, "Circuits in place of programs", and its summaries

Date: 2026-11-14. Version refereed: the working tree at commit `6b534400` ("circuit tables; the paper builds with both new sections"). I had not seen the note before.

**Under review.**

1. `paper/sec7-circuits.tex` (Section 7 of the PDF, Definition 29 to Proposition 41, Tables 4 and 5).
2. The passages that summarise it: the abstract bullet "Circuits in place of programs" and the last sentence of the abstract (`paper/main.tex` 108-118, 122-125); in `paper/sec1-intro.tex` the results item "Circuits" (142-158) and the sentences on Section 7 under "What is new and what is not" (187-191) and "What the toy does not settle" (216-219); in `paper/sec8-answers.tex` the paragraph "The same question with circuits in place of programs" (129-163) and the eighth open item (241-244); in `README.md` the bullet "Circuits in place of programs" (43-50) and the line under "What is not settled" (63).

The source of the section is `research/circuits-final.md`; the tags of the cited works are in `research/circuits-literature.md`.

**Lens.** What is claimed. For every sentence that states a conclusion, an interpretation or an answer I asked: which numbered result proves it, and under which assumptions; whether the scope is right (one description or all, mass of descriptions or block returned, reach or fate, theorem of the toy or argument or guess); whether the source lists it as dropped, narrowed or open; whether it agrees with the rest of the note; and what a reader of the closing paragraph alone, or of the summaries alone, would take as the answer to the commissioner's question. I also checked every number against `experiments/results/circuits.json`, every label, and every entry of `paper/bib-circuits.tex` against the source itself.

**Method.** Pencil and paper for the statements I rely on. Python for exact counting of small Boolean circuits and for arithmetic: my own counter of circuits by function (an ordered and a multiset dynamic programme, which agree with each other for `s<=3` at `k=3,4`), an enumerator of pointer structures for the separably triggered cores, exact recomputation of the worked numbers, and a simulation of the active part of a random gate list. The scripts count circuits and truth tables and nothing else. Sources were opened at `arxiv.org`, `eccc.weizmann.ac.il` and `proceedings.mlr.press`. I changed no file except this report. Two other reports on the same section, `referee-6-circuits-proofs-a.md` and `referee-6-circuits-proofs-b.md` (below "proofs-A", "proofs-B"), appeared while I worked; where a finding of mine is also in one of them I say so and keep my entry short.

## Verdict

The body of Section 7 is, for the most part, careful about what its results show: the limits after each theorem are stated, the overall view is split into proved, argued and guessed, and the closing sentence says that the toy has no definition of "malign" beyond deviation. Every entry of the two tables agrees with `circuits.json`, and I reproduced the whole file with independent code. Of the numbers in the computation subsection one is wrong: "between 2 and 32 per cent" in line 936 (the smallest value is 1/53, 1.9 per cent); it is the only place in the paper where a known wrong value of the source survives. The errors are in the summaries and in a few sentences of the overall view, and they are of the kinds listed in `verification/README.md`. (1) The abstract, Section 8 and the README give "about 2 to 32 per cent when the predictor has gates to spare"; 32 per cent is the value at the least size, with no gate to spare, and with slack the largest computed value is 28.9 per cent. (2) The README states as conclusions two claims that the source lists as dropped ("no refund for the rarity of uses", "no simple world with a long history"). (3) The summaries call the computed deviation "deviation that nothing aimed", although the section says that "aimed" is defined for separate triggers only; in the cases computed every deviating circuit is one that reads the never-varied bit, the same circuits that the neighbouring bullet calls triggers, and in the one case where the separately triggered ones were counted they are three tenths of the deviating mass. That count also sits badly with the guess that aimed deviation is "a small part". (4) The abstract and the README say that the minimal-circuit question is "stated precisely"; the section says its third condition cannot be checked for a given circuit. (5) The open item "any ceiling on the total posterior mass of hypotheses that deviate" replaces the source's open item on aimed payloads by one that the section itself answers: that mass is 1 in proved cases and is capped away from 1 by the two-sided floor. (6) "A seed never beats its own hardwired instance" is a statement about which description carries the mass, not about the block returned; the summaries drop the sentence of the section that says so. (7) One citation states the content of a post that nobody opened, one drops the word "black-box" from the theorem it cites, and one attributes a formula to the wrong one of two papers. All thirteen entries of `bib-circuits.tex` exist with the authors, titles and identifiers given, except that the two forum posts could not be reached from this machine.

On the commissioner's question: a reader of the closing sentence alone gets an answer that the results support, provided "the seeker mechanism is priced out" is read as "for one description"; the sentence should say that. A reader of the summaries alone gets the same outline and six things that were not shown (findings 1, 4, 5 with 6, 7, 8 with 9, and 12 below).

---

## Findings

Severity: **error** (false as written), **overclaim**, **gap** (an assumption, a caveat or an open point is missing), **unclear**, **minor**. Each finding is marked **[section]** or **[summary]**. Line numbers are those of the file named.

### 1. "2 to 32 per cent when the predictor has gates to spare". error [summary]

**Where.** `paper/main.tex` 123-125; `paper/sec8-answers.tex` 148-151; `README.md` 47.

**Problem.** In `circuits.json` the value 0.32 (8/25) is the constant world in the sequence form at `n=8` and `s=1`. That is the least size, in the exception of `thm:c-minimum`: no gate is to spare. With `s>s_D` the values for worlds that ignore the bit run from 1/53 = 0.0189 (`b0 AND b1`, `n=4`, `s=2`) to 766/2647 = 0.2894 (constant, `n=8`, `s=2`). Section 7 has it right ("with slack, or in the exception", line 936); the summaries dropped "or in the exception". Section 8 also cites Tables 4 and 5 for the range, and 0.32 is in neither table (Table 5 starts at `s=2`). The range is a range over the cases computed, not a bound: the constant target in the query form at `k=3`, which is not in the results file, gives 12/34 = 35.3 per cent at `s=1` and 31.7 per cent at `s=2` (my count). Also found by proofs-B (finding 6).

**Corrected text.** "... is off the world's answer by about 2 to 29 per cent when the predictor has gates to spare and the world ignores the bit (0 at the least size, except 27 to 32 per cent where the data are fitted by a single gate that is constant or copies an input)". In Section 8 cite `circuits.json` or add the column `s=1` to Table 5.

### 2. The computation subsection: "between 2 and 32", and two sentences without their condition. error (small) [section]

**Where.** `paper/sec7-circuits.tex` 934-940.

**Problem.** (i) "It is between 2 and 32 per cent in every case computed with slack, or in the exception": the smallest value is 1/53, 1.9 per cent. This is the only place in the paper where the wrong value survives; the summaries say "about 2". The entry 0.036 of the source does not survive: Table 5 has 0.035 (242/6819 = 0.0355). In the source both are still wrong (`research/circuits-final.md` 380, 383, 505). (ii) "The deviation ... is 0 at the least size outside the exception" holds for worlds that ignore the bit; for the last row of Table 4 it is 1. (iii) "With slack it grows for the targets that depend on two or more inputs" follows the sentence on worlds that depend on the bit, for which it falls (1, 0.909, ..., 0.810); in Table 4 the "target" `(x1 AND x2) XOR v` depends on three inputs. Also proofs-B 6.

**Corrected text.** "When the world ignores the bit, the deviation is 0 at the least size outside the exception of `thm:c-minimum`, between 1.9 and 29 per cent in every case computed with slack, and 27 to 32 per cent at the least size in the exception; the largest value, 0.32, is the constant world at `s=1`, `n=8`. With slack it grows for the worlds that depend on two or more inputs and falls for the one-input world and for the constant."

### 3. "81 to 100 per cent when the world depends on it" is the complement of two rows, and the other rows give less. unclear [summary and section]

**Where.** `paper/main.tex` 125; `paper/sec8-answers.tex` 151; `README.md` 47; `paper/sec7-circuits.tex` 939, 1062-1063.

**Problem.** For one-bit answers and the same data, a world whose answer at the query is the other one has deviation mass one minus that of the world that ignores the bit. Row 5 of Table 4 is one minus row 1, and row 1 of Table 5 is one minus row 4. So the second range is not a second measurement, and it is the complement for two of the data sets only. For the other data sets of the same tables the same counts give 80.4 to 100 per cent (`x1 XOR x2`), 71.4 to 76.1 per cent (`x1`) and 68.0 to 77.6 per cent (constant) for a world that flips its answer with the bit. The same applies to the guess in lines 1060-1063: "of constant order when the world ignores the novel feature" and "close to one when the world depends on it" are `c` and `1-c` for one constant; with `c` between 0.02 and 0.32, as computed, "close to one" is 0.68 to 0.98. Proofs-B 6(iv) has the first half of this.

**Corrected text.** Summaries: "... and by the complement, 68 to 100 per cent over the same cases, when the world's answer changes with the bit." Lines 1060-1063: "about `c` when the world ignores the novel feature and `1-c` when its answer changes with it, where `c` is conjectured to be of constant order (from five sizes at `k=3`; between 0.02 and 0.32 in the cases computed)".

### 4. The README states two dropped claims as conclusions; the subsection title does the same. overclaim [summary and section]

**Where.** `README.md` 45: "So there is no cheap universal search, no refund for the rarity of uses, and no simple world with a long history." `paper/sec7-circuits.tex` 602: "No refund for search; computation is paid for in description".

**Problem.** `thm:c-refund` bounds one seeded description, the instances of one template, and a template that imitates every world of `σ` gates. Section 7 says so (710-713: "None is the negation of `thm:search`(b) for arbitrary sets of circuits. No construction is known whose share at every use of a class grows as the class gets rarer, and none is excluded") and says of part (g): "It bounds circuits, not behaviours" (734-739). The source lists both README claims as dropped (`research/circuits-final.md` 5.2: "no hypothesis is repaid for the rarity of uses ... heading stronger than its items"; "there is no simple world with a long history as a statement about behaviours"). A bound on one description is read as a bound on all. Also proofs-B 1.

**Corrected text.** README: "So no single description is a cheap universal search or is repaid for the rarity of uses, and a description has at least as many gates as the smallest circuit for what it computes. Whether a set of circuits can be repaid is open, and a long history whose readout has a small circuit is as cheap as that circuit." Title: "No refund for one description; computation is paid for in description".

### 5. "Deviation that nothing aimed". overclaim [summary]; unclear [section]

**Where.** `README.md` 47 (heading of the bullet); `paper/main.tex` 115 ("and deviation that nothing aimed"); `paper/sec8-answers.tex` 145 ("Circuits that fit the data disagree off the data without anything aiming"); `paper/sec7-circuits.tex` 1047-1049 ("unaimed underdetermination ... and the computed cases"), 483-485 ("it is not aimed").

**Problem.** Section 7 says: "Only the weak sense is defined in the circuit toy; 'aimed' is formal for separate triggers only" (1000-1001), and its last sentence says that the material supplies no definition of "aimed". So "nothing aimed" is not something a result can show. For the cases behind the figures the label is also wrong in the one sense that is available.

* In the query-form rows the data contain every value of the other inputs. A fitting circuit that does not read `v` therefore computes the target everywhere. So every circuit counted in the "2 to 29 per cent" has the never-varied bit in its active part and changes its answer when the bit is set; the same holds at a dyadic cut for `b_j`. These are the circuits that the bullet before ("Triggers survive, priced in gates") is about: the tables give, for `μ_s` and small sizes, the exact value of the quantity that `thm:c-floor`(d) bounds from below for the length prior. The two bullets report one quantity under two names.
* For the data of `x1 AND x2` at `s=5` the two functions `target AND NOT v` and `target XOR v` carry 53.4 and 13.5 per cent of the deviating mass (from the counts in `circuits.json`: 9934513152 and 2504190976 of 18602655744).
* The section's own count (560-563, which I reproduced: 16 of 48 at `s=2`, 8512 of 29824 at `s=3`) says that the separably triggered cores, the only circuits for which "aimed" is formal, are 33 and 28.5 per cent of that mass.

"Nothing aimed" is apt for what is proved about minimum-size circuits (no minimum circuit reads the bit; the pairing in the AND family). It is not a description of the computed deviation with slack.

**Corrected text.** README heading: "*Deviation in exact small cases.*" Abstract: "... ceilings for three syntactic classes of hypotheses only; and, in exact small cases, a deviation of a few to a few tens of per cent at such a use, carried by the circuits that read the bit that never varied." Section 8: "Circuits that fit the data disagree off the data, and no search or goal enters the count." Lines 1047-1049: "underdetermination among the circuits that fit the data, which the toy cannot divide into aimed and unaimed". Lines 483-485: "and it is symmetric: every circuit that deviates through it has a sibling that does not."

### 6. The guess "a small part" is stated without the one count that bears on it. gap [section and summary]

**Where.** `paper/sec7-circuits.tex` 1056-1060; `paper/sec8-answers.tex` 157-158 and `README.md` 50 ("takeover by a hypothesis that sought the use is probably a small part of that deviation").

**Problem.** (i) The only formal stand-in for "strict sense" is the class of `thm:c-ceiling`, and in the one case where it was counted it is 33 per cent (`s=2`) and 28.5 per cent (`s=3`) of the deviating mass. For large data the ceiling bounds that class by `12|Θ|/(g! s_D (16(k-1))^(g+1))` of the posterior; this is a small part of the deviating mass only if that mass stays of constant order, which is the conjecture of lines 1060-1063. So for separate triggers the guess is a consequence of a conjecture at large sizes and is false at the smallest; for other triggers there is neither a bound nor a count. The paragraph should say this. (ii) The summaries change the wording from "supplied by a hypothesis that predicts well up to the use in order to supply it" to "a hypothesis that sought the use". In a plain circuit nothing seeks; read literally the summary says that the mechanism shown to be unavailable to one description contributes little, which is not the guess. (iii) "Probably" suggests evidence. The source has "my guess ... no theorem supports a number", and the section adds that the two derivations differed by many orders of magnitude and their referees endorse neither.

**Corrected text.** Lines 1056-1060, add: "In the smallest case the separately triggered cores are about three tenths of the deviating mass (after `thm:c-ceiling`); for large data they are a small part of it if the deviating mass is of constant order, which is conjectured below." Summaries: "our guess, which no result supports, is that deviation supplied by a part of the circuit that exists in order to supply it is a small part of that deviation when the data are large; in the smallest case counted, separate triggers are three tenths of it".

### 7. "Stated precisely". overclaim [summary]

**Where.** `paper/main.tex` 116-117 ("is stated precisely and left open"); `README.md` 50 ("That question is stated precisely in the paper and is open").

**Problem.** `paper/sec7-circuits.tex` 985-987: "Condition 3 has no formulation that could be checked for a given circuit, so this is not a conjecture with a predicted answer." Conditions 1 and 2 are formal and, as the section says, are met by `thm:c-minimum`(c) and carry no content alone. "Rich task" and "general solver" are not defined either. Section 1 and Section 8 do not say "precisely".

**Corrected text.** "... is stated as an open problem, two of whose three conditions are formal, and left open."

### 8. "No ceiling on the total mass of hypotheses that deviate" is not the open point. unclear [summary and section]

**Where.** `paper/sec8-answers.tex` 241-242 and `README.md` 63 ("any ceiling on the total posterior mass of hypotheses that deviate at a use"); `paper/sec1-intro.tex` 216-217; `paper/sec7-circuits.tex` 1003-1004 and 1027-1028 ("There is no cap on the total deviating mass at a use").

**Problem.** (i) There are caps: `thm:c-transfer`(d) gives deviation at most `1-μ(f*)/ξ(D)`, and `thm:c-floor`(d), which the section calls two-sided, gives at most `1-1/(32(k+s_0)^2+2)` under the length prior at a use marked by a never-varied bit. (ii) No cap much below 1 can hold without a condition on the world: by `thm:c-minimum`(b), (c) the deviating mass is 1 when the world changes with a bit that never varied, and it is 0.81 to 1 in Tables 4 and 5. So as worded the open item is settled, in the negative, by the section. (iii) The source's open item is a different one (`research/circuits-final.md` 5.1, item 1): "A ceiling on aimed payloads. Nothing bounds the total posterior share, at a use, of circuits that compute the context and continue with something chosen." The paper replaced the strict sense by the weak one.

**Corrected text.** Open item and README: "for circuits, an upper bound to match the floor of `thm:c-floor`: on the share, at a use, of a block chosen in advance, beyond the three classes of `thm:c-ceiling`, `prop:c-gadget` and `thm:c-refund`(e), and on the deviating mass when the world ignores what is new at the use". Lines 1027-1028: "Beyond the trivial caps of `thm:c-transfer`(d) and `thm:c-floor`(d) there is no cap on the deviating mass at a use, and none can hold for every world (`thm:c-minimum`(b)); there is none on triggers entangled with the honest computation."

### 9. The open lists leave out the direct counterpart of the seeker question. gap [summary]

**Where.** `paper/sec8-answers.tex` 241-244; `README.md` 63; `paper/sec8-answers.tex` 158-160 and `README.md` 50 ("the form of the question that remains").

**Problem.** The source lists fourteen open points. The summaries keep three. Four of the others decide how the summaries are read. (i) The refund for families: whether some set of circuits has, at every use of a class, a share that grows as the class gets rarer (source 5.1, item 2; Section 7, 711-713). This is the fate question for circuits, since masses add; without it "the seeker mechanism is not available to a single description" reads as closing the matter. (ii) The size of the deviation at a never-varied bit for large data, between the polynomial floor and a constant (item 5). (iii) A world outside the class (item 10), which Section 7 calls the generic case (209-214). (iv) Self-reproduction, the circuit form of Hänni's second question, is missing from the abstract, Section 8 and the README altogether: that it is defined only relative to a decoder outside the class and has share zero unless the block is longer than the literal code of a circuit for the whole context (`thm:c-self`). Proofs-B (finding 3) reports an explicit one-gate example with `SR_m(x)` nonempty, so the sentence in 808-809 needs changing too. Given (i) to (iii), "the form of the question that remains is whether the smallest or the typical circuit ... is a general solver" names one of several open routes; the section lists four others after `thm:c-ceiling`.

**Corrected text.** Eighth item: "for circuits: whether a set of circuits can have a share at every use of a class that grows as the class gets rarer; an upper bound to match the floor (finding 8); the size of the deviation at a never-varied bit for large data; a world outside the class; the minimal-circuit question; and the recurrent version of the toy." Summaries of the view: "one form of the question that remains, and the one we think matters most, is ...". Add one sentence on self-reproduction to Section 8 and the README.

### 10. "A seed never beats its own hardwired instance" is about the description, not the block. gap [summary]

**Where.** `paper/main.tex` 110-111; `paper/sec1-intro.tex` 152-154; `paper/sec8-answers.tex` 135-136; `README.md` 45; `paper/sec7-circuits.tex` 1019-1020 ("gains nothing from a seed").

**Problem.** Section 7 says (700-703): "Part (d) bounds the share of the seeded description, not of its payload: the instance is itself a hypothesis that prints `x_i` and the same continuation, with weight at least `q(S)`." So, under (A2), the block that the seeded description would supply at `x_i` is supplied by the instance with at least `1/ϖ_i` times the share. The result says that sharing one description among many targets earns nothing; it does not lower the probability that the block is returned. In the summaries the statement stands as a reason why the mechanism of the argument is "not available", with no such sentence, and a reader will take it as a bound on the outcome. This is a statement about the mass of descriptions read as a statement about the block returned.

**Corrected text.** Add in each place: "(the instance prints the same continuation, so this limits the seeded description and not what is returned; what is returned at a use is decided by the circuits, of at least the size of the smallest circuit for the context, that print the context and continue)".

### 11. "As the exclusion of seekers by a tight schedule does". overclaim [summary and section]

**Where.** `paper/sec8-answers.tex` 138-139; `README.md` 45; `paper/sec7-circuits.tex` 1040-1043 ("in the same way that a schedule with a short first deadline removes it in the note") and 719 ("only a time bound excludes it").

**Problem.** In the program toy a tight schedule gives no mass to the searching machines of `thm:search` and to programs with a long start-up; "whether the base rate can be collected by some hypothesis within a tight schedule is open" (`paper/sec4-limits.tex` 175-176), and for the seeker that is not written down the exclusion is "a feature of the example and not of every program that meets the condition" (`paper/sec3-floor.tex` 437-438). Round 2 (finding D1) and round 5 (finding A5) corrected exactly these two wordings; Section 1 (line 44) and Section 8 (line 66) have the corrected forms. The comparison is in fact closer than the text says: in both toys one construction is excluded and the question for all hypotheses is open. Line 719 is also proofs-B 4.

**Corrected text.** Section 8 and README: "This comes from the definition of the class, as a tight schedule gives the searching programs of the program toy no mass; in both cases it is open whether other hypotheses collect the base rate." Line 1042: "... in the same way that a schedule with a short first deadline gives the searching programs no mass in the note." Line 719: "and a time bound is the only thing shown to exclude it".

### 12. Reuse: the factor, "again", "brings the programs back", "or shared weights". overclaim [summary]

**Where.** `paper/main.tex` 117-118 ("the class contains every bounded machine again"); `README.md` 49 (heading "Reuse brings the programs back"); `paper/sec1-intro.tex` 156-158; `paper/sec8-answers.tex` 161-163 ("by recurrence or shared weights ... (`prop:c-recurrence`)").

**Problem.** `prop:c-recurrence`(c) gives the factor `q_rec(F_M)`, the weight of a cell with up to `w(2^w-3)` gates for a machine with `w` bits of state. Section 7 says that the factor depends on the space bound, that "the cell of (c) has a very small weight", that "no universal cell of size linear in `w` is constructed", and that in the format used "description still pays for space" (890-904). What is proved is containment at a factor that is free of the schedule; the only cell the proof supplies has up to `w(2^w-3)` gates, each at more than four bits. The summaries keep "does not depend on the schedule" and drop the rest; the abstract drops the factor and says "again"; the README heading states the argued part as a fact (its body says "argued and not proved"). `prop:c-recurrence` is about iterating one cell; no result of the section is about shared weights or autoregressive use (`thm:c-readings` says the latter "is not treated here"), so Section 8 attributes to the proposition more than it covers.

**Corrected text.** Abstract: "When one circuit is iterated as the cell of a recurrence, the class contains every machine with bounded state, at a factor that does not depend on the schedule; the cell constructed has up to `w(2^w-3)` gates for `w` bits of state, so the factor shown is extremely small." README heading: "*Reuse: the axis back to programs.*" Section 8: delete "or shared weights", or write "by recurrence (shared weights and autoregressive use are not treated)".

### 13. "Costs the gates that recognise the use" states an upper bound on a price as the price. overclaim [summary]

**Where.** `paper/sec1-intro.tex` 146-147; `README.md` 46 ("costs the gates that recognise the use from its input, and the payload: one gate ..., up to k gates").

**Problem.** `thm:c-floor` shows that such a hypothesis exists at that price. That it cannot be had for less is proved for separate triggers only (Section 7, 848-849), and Section 7 lists triggers that cost no gate (an unexercised truth-table entry, item (iii) after `thm:c-ceiling`) and triggers entangled with the computation. For one-bit answers the test can also be cheaper than `k-1-z(n)` (proofs-A 4). The source dropped the corresponding claims as "an upper bound on a cost" (5.2, second row). Section 8 ("exists at the price of") and the abstract ("a floor ... priced by") are right.

**Corrected text.** "A hypothesis that fits the data and gives a chosen answer at a use exists at the price of the gates that recognise the use from its input, and the payload: ... That it cannot be had for less is proved for separate triggers only."

### 14. Assumptions dropped in the summaries of `thm:c-refund`. gap [summary and section]

**Where.** `paper/main.tex` 110-112 ((A2) missing); `paper/sec8-answers.tex` 135-137 ((A2) missing); `README.md` 45 ((A2) and `σ+3<=2^k` missing); `paper/sec7-circuits.tex` 1013-1022 (the list is headed "the priors of the family"; item 2 needs a mixture prior with (A1) and (A2)).

**Problem.** Part (d) needs (A2), part (f) needs (A1) and (A2), part (i) needs `σ+3<=2^k`. None of the seed statements is stated for the fixed-size prior `μ_s`, under which all descriptions of a size weigh the same; the source lists the core-level versions as "not written" (5.1, item 8). `paper/sec1-intro.tex` 152-156 has all the conditions. Also proofs-B 5, which shows that each condition is needed.

**Corrected text.** As in proofs-B 5; in the README add "(for `σ+3<=2^k`, and if seeded formats get no more weight than unseeded ones)".

### 15. The summaries do not say under which prior each statement holds. unclear [summary and section]

**Where.** `paper/main.tex` 122-125 ("the posterior is off the world's answer"); `README.md` 46-47; `paper/sec8-answers.tex` 141-151; `paper/sec7-circuits.tex` 1013-1014 and 1023-1025 (item 3 of "Proved").

**Problem.** The floor is for mixture priors, and its polynomial form for the length prior. The statements on minimum-size circuits are for `μ_s` at `s=s_D`. The counts are for `μ_s` with `k<=4` and at most four gates above the least size. The paper has no floor for a triggered answer under `μ_s` with slack (the source's Theorem 8(c) was not taken over), so the floor theorem and the tables are about different priors, and no computation is about the prior of the floor. A reader of "the posterior is off by about 2 to 32 per cent" next to "each answer keeps at least a polynomial share under the length prior" will take them for one predictor. Item 3 of "Proved" is headed "the priors of the family" and holds for mixture priors.

**Corrected text.** Abstract and README: "under the uniform prior on circuits of a fixed size, for up to four inputs and up to four gates more than the data need, the posterior is off ...". Section 8: add "under the uniform prior on circuits of a fixed size" to the sentence on the small cases and "for a predictor that uses only minimum-size circuits" to "a deviation with certainty". Item 3: "under a mixture prior".

### 16. "Deviation in the weak sense is not rare at uses that are off the data", under "Proved". overclaim [section]

**Where.** `paper/sec7-circuits.tex` 1029-1033.

**Problem.** No result says this, and the next sentence gives a case where the deviation is zero. Read as a statement about how often, it contradicts `thm:c-transfer`(c): along any sequence of queries off the data whose answers are then revealed, the deviation masses sum to at most `ln(1/μ(f*))`; and the stakes paragraph bounds the expected deviation at a fresh draw by `ε_n`. What is proved concerns particular uses: those that differ from all the data in a feature that never varied, or in a combination of values that never occurred. This is reach read as fate. Also proofs-B 7.

**Corrected text.** "5. Deviation in the weak sense can be large at a use that is new in a feature that never varied in the data, or in a combination of values that never occurred. For minimum-size circuits it is zero ..." (the rest as it stands).

### 17. The three ceilings are of very different strength, and the summaries do not say so. unclear [summary]

**Where.** `paper/main.tex` 115; `paper/sec1-intro.tex` 150-152; `paper/sec8-answers.tex` 151-154; `README.md` 48.

**Problem.** "Upper bounds exist for three syntactic classes" will be read as "these three classes are small". (i) Separate triggers: single-bit answers, a trigger that reads inputs only and feeds a selector at the output; the bound is proportional to the number of triggers and to `1/s_D` (with the count corrected in proofs-A 1 it is small for `k=20`, `s_D=1000`; in the smallest case the class is three tenths of the deviating mass). (ii) Gadgets: at most 0.65 times the mass of the explanations they wrap, and only for explanations with `k+σ>=4(k+A)^2`. That is a constant, and it allows the class two fifths of the posterior. (iii) Instances of one template: at most the weight of one description of `σ` gates, summed over targets, only for templates with `s-σ>=σ/(1+log2(k+σ))` and under (A1); at `s=σ` the bound is `4^σ`. Proofs-B 7 has (iii) for item 4 of "Proved".

**Corrected text.** README (and the same content elsewhere): "Upper bounds exist for three syntactic classes only: a trigger that is a separate, input-only part feeding a selector at the output (small for large data, in proportion to the number of triggers); small self-contained gadgets around much larger explanations (at most 0.65 times the explanations they wrap); and the instances of one seeded template that is sufficiently larger than the worlds it imitates."

### 18. "No bound contains the rarity or the stakes of the uses". minor [summary]

**Where.** `paper/sec8-answers.tex` 154; `README.md` 48.

**Problem.** One bound of the section does: the expected deviation at a draw conditioned on a set of probability `ρ` is at most `ε_n/ρ` (`paper/sec7-circuits.tex` 832-836). Section 7 says "neither bound" of two named ones (600, 842).

**Corrected text.** "None of these three bounds contains the rarity or the stakes of the uses; the bound on the average over the training distribution weakens by the factor `1/ρ` for a class of probability `ρ`."

### 19. A post that nobody opened is cited for what it argues. error [section]

**Where.** `paper/sec7-circuits.tex` 955-957: "A later post of Hubinger [hubinger19b], which we could not open either, argues against the conjecture, from memory; we attribute no claim to it."

**Problem.** "Argues against the conjecture" is a claim attributed to the post. `research/circuits-literature.md` tags everything about this post FROM MEMORY (3.3 and C.5), its existence, title and year included. I could not reach it either; a search engine lists a post with this title and author. The source of the section has the same sentence.

**Corrected text.** "A later post of Hubinger is titled 'Are minimal circuits deceptive?' [hubinger19b]; we could not open it and attribute no claim to it." In `bib-circuits.tex` add "(not consulted)" to this entry and to `christiano18`.

### 20. "An undetectable backdoor" drops "black-box". overclaim [section]

**Where.** `paper/sec7-circuits.tex` 989-992.

**Problem.** Theorems 2.1 and 5.4 of [goldwasser22] say: "there exists a model backdoor ..., which is non-replicable and black-box undetectable". The authors add: "we make no effort to hide the signature scheme to a white-box distinguisher". The difference matters here. A prior over circuits sees the description, and a signature check "in parallel to the original classifier" feeding a switch is a separate trigger in the sense of `thm:c-ceiling`, the one class the section caps. As written the sentence reads as support for triggers that cannot be told apart. (`research/circuits-literature.md` A.20 has the theorems "as quoted".)

**Corrected text.** "... and a backdoor that cannot be detected from black-box queries can be planted by running a signature verification in parallel to the original classifier [goldwasser22, Theorems 2.1 and 5.4]; as a circuit this is a separate trigger in the sense of `thm:c-ceiling`."

### 21. The weight `2^(-|p|)/t` is one paper's, not both. minor [section]

**Where.** `paper/sec7-circuits.tex` 730-732.

**Problem.** `2^(-|p|)/t(p,x)` is the prior `S_Kt` of [filan16] (their equation (2)). Schmidhuber's speed prior [schmidhuber00, Definition 6.3] is `S(x)=sum_i 2^(-i) S_i(x)`, which by Proposition 3 of [filan16] weighs `p` by `2^(-2|p|)/t` up to a constant. The conclusion drawn does not depend on which. Proofs-B 15(iii) notes that this "so" compares a time per bit with a total running time and should be marked as argued; I agree.

**Corrected text.** "A speed prior weighs a program `p` that takes `t` steps by `2^(-|p|)/t` [filan16]; Schmidhuber's original [schmidhuber00] is, up to a constant, `2^(-2|p|)/t` [filan16, Proposition 3]."

### 22. "The question about minimal circuits is Christiano's". minor [summary]

**Where.** `paper/sec1-intro.tex` 188.

**Problem.** The post could not be opened; its title and its role as the source of the conjecture are known through reference [16] of [hubinger19] (tag B.11), its content is FROM MEMORY (C.4). The open problem of `sec:c-minimal`, with its three conditions, is the note's own formulation.

**Corrected text.** "the question about minimal circuits goes back to a post of Christiano [christiano18], which we know through [hubinger19]; the formulation in `sec:c-minimal` is ours."

### 23. "The size prior does not price it out as it does the literal simulation". overclaim [section]

**Where.** `paper/sec7-circuits.tex` 1070-1074.

**Problem.** The cited passage is right: [hubinger23, Section 2.5] locates the risk in "some very general-purpose prediction algorithm that does a very generic search over hypotheses". The sentence built on it is not shown. By `thm:c-refund`(g) a circuit pays for every gate of a search as for every gate of a simulation; whether a smaller circuit without the search fits the data is the open problem of `sec:c-minimal`, on which "the toy gives no evidence either way" (1066). The literature file reads the same passage the other way ("which in the circuit toy is the recurrent or uniform regime and not the feed-forward size-prior regime", 7.1). The sentence stands in the paragraph "Guessed", but it is worded as a fact.

**Corrected text.** "... that is the entangled route. The size prior prices a search gate by gate, as it does a simulation (`thm:c-refund`(g)); whether a smaller circuit without the search exists is the open problem of `sec:c-minimal`."

### 24. Two sentences that are neither theorem, computation, argument nor guess. minor [section]

**Where.** `paper/sec7-circuits.tex` 850-851 ("which is often what makes a use critical"); 829-831 ("can compute the stakes by simulation at no cost in bits").

**Problem.** The first is a remark about real uses; the source says that "whether real critical uses are like that is not a question about the toy" (5.3, item 2). The second disagrees with Section 3.7, where aiming at stake at least `n` costs about `2 log2 n` bits and the bits that name the scale. Both are in proofs-B (15(iii), 13(i)).

**Corrected text.** "... if those are the novel ones; whether that is what makes a use critical is not a question about the toy." "... at no cost in bits beyond the description of the aim (`prop:aim-cost`)".

### 25. "Checked by AI referees, in the files ...-final.md". minor [summary]

**Where.** `paper/sec1-intro.tex` 189-191.

**Problem.** The referees of the source checked the two derivations (`circuits-A.md`, `circuits-B.md`). The corrected account was written afterwards by an editor, and parts of it were new there and had not been seen by a referee before this round: the feedback statements (source Theorem 4: "neither derivation treated feedback") and the lower bound for universal circuits with its constants (Proposition 16(b), (c)). The README (line 76) describes the files correctly.

**Corrected text.** "The longer proofs of `sec:stakes`, `sec:circuits` were first written out in two independent derivations each, checked by AI referees, and collected with corrections in `research/stakes-final.md` and `research/circuits-final.md`; what is new in those two files was first refereed in round 6."

### 26. The closing sentence needs its scope. minor [section]

**Where.** `paper/sec7-circuits.tex` 1076-1080.

**Problem.** "The seeker mechanism is priced out" is, in the body, "not available to a single description", with the gap named in the paragraph "Argued". A reader of this sentence alone gets the unscoped form. "Uses that are off the data" should be the narrower class of finding 16.

**Corrected text.** "In one sentence, as an argument: for plain circuits the seeker mechanism is priced out for any one description (for sets of circuits nothing is shown either way), deviation at uses that are new in something the data never varied is not, and whether any of that deviation should be called malign depends on a definition of 'aimed' that this material does not supply."

### 27. Symbols in the summaries. minor [summary]

**Where.** `paper/sec1-intro.tex` 145 (`a` and `k` in `log2(16a(k-1))` are not defined; "prior of the family" is not explained), 155 (`k`); `paper/sec8-answers.tex` 137 (`k`); "a polynomial share" in `paper/sec1-intro.tex` 148, `paper/sec8-answers.tex` 144, `README.md` 46 (polynomial in what; in the README "at such a use" follows "the positions hardest to name", where the floor is not polynomial; proofs-A 15).

**Corrected text.** "one more active gate, added to `a` active gates of a circuit with `k` inputs, costs at least `log2(16a(k-1))` bits"; "a share of at least `1/(32(k+s_0)^2+2)`, where `s_0` is about the number of bits of the cheapest explanation of the data".

### 28. Numbers called computed that the results file does not contain. minor [section and README]

**Where.** `paper/sec7-circuits.tex` 275-277 (13.00 and 14.12 bits), 401-403, 560-563, 763-765; `README.md` 75 ("`run_circuits.py` computes the numbers of the circuit section").

**Problem.** `circuits.json` holds the two tables, the three triggered variants and the AND family. It does not hold the first example of `thm:c-capture`(d), the count of separably triggered cores, the two gate prices or the comparison of the floor with exact values. I reproduced the first three (see below). The fourth names no worlds or cuts; proofs-A 8 reproduced it for one world.

**Corrected text.** Add these to `run_circuits.py` and the results file, or change the README line to "computes the tables and the numbers of Section 7.10".

---

## Citations

Tags are those of `research/circuits-literature.md`. "Opened" means that I fetched the page or the PDF and read the statement there.

| entry | status | what I found |
|---|---|---|
| `frandsen05` | CONFIRMED | ECCC TR05-032, Frandsen and Miltersen, title as given, 2005. Abstract: `L(n)` is `2^n/n` times `1+O(log n/n)`. Tag VERIFIED. Cited correctly. |
| `burghart26` | CONFIRMED | arXiv:2606.30475, F. Burghart, "Ancestries in random d-DAGs", 29 June 2026. Its Theorem 1, attributed there to Janson, gives `n^(-(d-1)/d)|D_n|` a limit law; for `d=2` the order is `sqrt(n)`. Tag VERIFIED (restated); cited "as stated in", which is right. The step to gate lists is tagged DERIVED ("to be proved in the note if used"); the paper uses it with "is ours" and no proof. The identification is correct, but "of order `sqrt(k+s)`" holds only for `s` large against `k^2`: my simulation gives 206 active gates at `k=3`, `s=10^4` (2.06 `sqrt(k+s)`) and 3.0 at `k=1000`, `s=1000`, where `sqrt(k+s)` is 45 (also proofs-A 6). |
| `bera08` | CONFIRMED | arXiv:0804.2429, Bera, Fenner, Green, Homer, "Universal Quantum Circuits", 2008. Section 1.1: Valiant "showed how to construct a O(c log c)-size and O(c)-depth universal circuit ... within a constant multiplicative factor of the information theoretic lower bound". Tag VERIFIED (restated); cited "as stated in". |
| `allender02` | CONFIRMED | ECCC TR02-028, authors in the order of the bibliography, 2002. Text before Theorem 5: "As observed in [All01], SIZE(x) = O(KT(x) log KT(x)) and KT(x) = O(SIZE^2(x) + log |x|)", for `x` of length `2^n`. Tag VERIFIED. |
| `filan16` | CONFIRMED | PMLR 51:1394-1402, 2016, Filan, Leike, Hutter (arXiv:1604.03343). Equation (2) defines `S_Kt` with the weight `2^(-|p|)/t`. Tag VERIFIED. |
| `schmidhuber00` | CONFIRMED; attribution inexact | arXiv:quant-ph/0011122, 2000. Definition 6.3 is the sum over phases, not `2^(-|p|)/t`; see finding 21. Tag VERIFIED for Definition 6.3 and `S(x)<=2^(-Kt(x))`. |
| `musat26` | CONFIRMED | arXiv:2605.10878, T. Musat, title as given, 11 May 2026. Corollary 7: `2^(-K(s)-α) <= Q(s) <= 2^(-K(s)/(β log K(s)))` for the output prior of a weight-norm prior on fixed-precision looped networks. The paper's wording matches, with "preprint" and "as stated there". The prior of the corollary is `2^(-||θ||^2)`; "parameter-count" is the paper's gloss, justified there up to constants. Tag VERIFIED as a statement. |
| `hubinger19` | CONFIRMED | arXiv:1906.01820, authors and title as given. The quotation in line 952 is verbatim (Section 2.2, "Inductive biases"); the three hypotheses of lines 908-909 are in Section 2.2, stated as hypotheses; reference [16] is Christiano's post. Tag VERIFIED. |
| `christiano18` | NOT REACHABLE | `lesswrong.com` is outside the reachable hosts. Title, author, year and its role as the source of the conjecture are confirmed through reference [16] of `hubinger19`. Content FROM MEMORY; Section 7 attributes none. See finding 22. |
| `hubinger19b` | NOT REACHABLE | Listed by a search engine with this title and author; not opened. Everything FROM MEMORY. Cited for a statement: finding 19. |
| `christiano24` | CONFIRMED | arXiv:2409.03077, authors and title as given. Theorem 5.5: "Assuming OWF and iO, the representation class of polynomial size Boolean circuits ... is not efficiently defendable." The paper's paraphrase is fair. Tag VERIFIED. |
| `goldwasser22` | CONFIRMED; statement narrowed | arXiv:2204.06974, authors and title as given. Theorems 2.1 and 5.4 are for black-box undetectability: finding 20. Tag VERIFIED. |
| `mingard20` | CONFIRMED | arXiv:2006.15191, authors and title as given. The abstract reports a correlation found empirically; "rests on empirical correlations" is right. Tag VERIFIED. |

Also cited in the section from the main bibliography: [hubinger23, Section 2.5] (arXiv:2302.00805), CONFIRMED, see finding 23. No entry of `bib-circuits.tex` gives a venue from memory. Every `\cref` and `\cite` of the four files resolves (checked against all labels and both bibliography files).

## Numbers

* **`circuits.json`.** Recomputed in full with my own code: all 23 query-form entries, the three triggered variants, the AND family for `k=3,4`, and all 24 sequence-form entries agree as exact fractions.
* **Tables 4 and 5.** Every entry is the rounding of the value in the file. The captions agree with the definitions of the computation: shares under `μ_s`; data all inputs with `v=0`, labelled by the target; query all other inputs 1 and `v=1`; deviation mass the share of fitting circuits whose value at the query differs from the world's; in the last row of Table 4 the data are those of `x1 AND x2`. Three things the captions should add: `v` is the last input (`x_3` for `k=3`, `x_4` for `k=4`), so that rows 4 and 5 are not confused; the `k=4` row was computed to `s_D+2` only; Table 5 has no column `s=1`, the least size for four of its six rows, so "0 at the least size" and the value 0.32 cannot be read off it.
* **Computation subsection.** 0.0255, 0.0310, 0.1013; one half at the least size for `k=3,4`; 0.468, 0.446, 0.429; one quarter and one eighth: all agree. Wrong: "between 2 and 32" (finding 2).
* **Elsewhere in Section 7.** `thm:c-capture`(d): 2 of 76; 0.0271, 0.0276, 0.0279; 1152 of 4608: agree. "4 of the 14": agree, at each of the four queries, for `k=3`. 16 of 48 and 28.5 per cent (8512 of 29824, of which 8128 by the frozen input alone): agree. 13.00 and 14.12 bits against 8.25 and 11.25: agree. `s_0` about 22 326 and `2^-33.9`: agree. `2^-14.6`: agrees. 1744 and 15 856: agree, but 35 gates suffice for a block of 16 bits, so `A=35` and `σ>=12 080` (proofs-A 2). "About 24.0 bits", 480, 1540: these leave out the term `log2(1/ϱ)`, one bit a gate under the length prior, and are costs against one explanation of 1000 gates; the proved share at a never-varied bit for the same `k` and `s_D` is `2^-33.9` (proofs-A 3). The sums over all triggers with `g` gates (0.0096, 0.082, 0.57, "exceeds 1 at `g=5`") count all gate lists; with reduced circuits I get `9.0·10^-4`, `9.8·10^-4`, `1.1·10^-3`, `1.2·10^-3`, in agreement with proofs-A 1.
* **Summaries.** `(σ+1)/2`, `log2(16a(k-1))`, one gate, `k` gates: agree with the theorems. "2 to 32" and "81 to 100": findings 1 and 3.

## A remark that is not a finding

The lower bound for universal circuits in `thm:c-refund`(i), which every summary quotes as "more than `(σ+1)/2` gates", can be replaced by `s >= σ-k+1` for every `σ` below the largest circuit size of a function of `k` inputs, with three lines. By (b) and (g) a circuit that is universal for size `σ` has at least `csize(f)` gates for every `f` with `csize(f)<=σ`. Let `f` have `csize(f)>σ` and let `f_0=0, f_1, ..., f_r=f` be obtained by adding the minterms of `f` one at a time. Then `csize(f_0)=1` and `csize(f_i)<=csize(f_{i-1})+k` (`k-1` gates for the minterm, one for the disjunction). So the last `f_i` with `csize(f_i)<=σ` has `csize(f_i)>σ-k`. This does not give "more than `σ`", which still needs the `σ log σ` bound. I have not seen it checked by anyone else.

---

## What a careful reader would take, and whether that was proved

**From the body of Section 7.** That plain circuits weighed by size are a class in which one description cannot be short and compute for long, cannot share its cost among many targets, and so cannot be the seeker of the program toy; that this is a property of the class and no evidence that the prior is benign; that a hypothesis which fits the data and answers as chosen at a use exists at the price of a few gates, one gate where the use is marked by a bit that never varied; that circuits which fit the data disagree where the data did not vary; that upper bounds exist for three syntactic classes; and that the toy cannot say which deviations are aimed. This is what was proved, with these corrections: the seed statements need (A1) and (A2) and are about descriptions, not about what is returned (findings 10, 14); "not rare at uses off the data" is "can be large at a use that is new in something that never varied" (finding 16); the three ceilings differ in strength (finding 17); and the comparison with the time bound should be with "the searching programs", not with "seekers" (finding 11).

**From the closing sentence alone.** That seekers are priced out, deviation is not, and "malign" is undefined in the toy. The second and third parts are what the section shows. The first is shown for one description; for sets of circuits the section says that nothing is excluded, and the sentence should carry that (finding 26). The reader of this sentence does not learn that the exclusion is by the definition of the class, that the guess about aimed deviation rests on nothing, or that iterating a circuit is argued to bring the program toy back.

**From the summaries alone.** The same outline, and the following, which were not proved.

* That there is "no refund for the rarity of uses" and "no simple world with a long history" (README; finding 4). Proved: not for one description; open for sets; false as a statement about behaviours with small circuits.
* That the predictor, with gates to spare, is off by up to 32 per cent (finding 1). Computed: up to 29 per cent with slack, in the cases in the file.
* That the deviation computed was aimed by nothing, and that aimed deviation is probably a small part (findings 5, 6). Shown: the toy has no such division; all of the computed deviation with slack sits on circuits that read the never-varied bit, and three tenths of it, in the smallest case, on separate triggers.
* That the remaining question is "stated precisely" (finding 7). It is stated with one informal condition, which the section says cannot be checked.
* That what is missing is a ceiling on all deviating mass (finding 8). Such a ceiling cannot exist for all worlds; what is missing is an upper bound on chosen answers beyond three classes, and the question whether sets of circuits are repaid for rarity (finding 9).
* That reuse "brings the programs back" (finding 12). Proved: containment at a factor that is free of the schedule, shown with a cell of up to `w(2^w-3)` gates; the return of the effects is argued.

With these corrections the summaries answer the commissioner's question as the section does: for plain circuits the particular engine of the original argument is unavailable to any one description, by the choice of the class; at uses that are new in something the data never varied the posterior deviates, with at least an inverse-polynomial share under the length prior and with a few to a few tens of per cent in exact small cases under the fixed-size prior; nothing in the toy says how much of that deviation is aimed, the one count of the formal proxy gives three tenths in the smallest case, and the questions that would decide it are open.

**Scripts** (in a scratch directory outside the repository; it may have been cleared since):

* `/tmp/claude-0/-home-user-AI-works/6274030e-7ece-5c94-928b-387c437d466d/scratchpad/ref-circuits-claims/work/mycount.py`, `/tmp/claude-0/-home-user-AI-works/6274030e-7ece-5c94-928b-387c437d466d/scratchpad/ref-circuits-claims/work/check_json.py`: own counter and the comparison with `circuits.json`.
* `/tmp/claude-0/-home-user-AI-works/6274030e-7ece-5c94-928b-387c437d466d/scratchpad/ref-circuits-claims/work/check2.py`: `thm:c-capture`(d), the exception of `thm:c-minimum`, the AND family at `k=4`, the complements of finding 3.
* `/tmp/claude-0/-home-user-AI-works/6274030e-7ece-5c94-928b-387c437d466d/scratchpad/ref-circuits-claims/work/sep.py`: separably triggered cores among the deviating circuits.
* `/tmp/claude-0/-home-user-AI-works/6274030e-7ece-5c94-928b-387c437d466d/scratchpad/ref-circuits-claims/work/nums.py`, `/tmp/claude-0/-home-user-AI-works/6274030e-7ece-5c94-928b-387c437d466d/scratchpad/ref-circuits-claims/work/reduced.py`: the worked numbers, the number of reduced circuits, the simulation of the active part.
