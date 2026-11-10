# Referee report 1 on "A toy malign-prior question with an answer"

Date: 2026-11-10. Version refereed: the `.tex` sources in `paper/` with `main.pdf` built at 10:34 UTC, `code/` and `experiments/` as of the same time. Line numbers refer to that version.

Numbering used below is that of the PDF: Def. 1 (bounded mixture), Lemma 2 (basic), Def. 3 (universality), Lemma 4 (transfer), Def. 5 (world, handover), Def. 6 (SR), Def. 7 (malign prior hypotheses), Thm 8 (calibration), Thm 9 (floor), Thm 10 (self-reproducing floor), Remark 11 (searcher), Prop. 12 (repetition, persistence), Thm 13 (budget), Thm 14 (capture), Thm 15 (machine dependence), Thm 16 (feedback), Thm 17 (contrarian).

**Bottom line.** The numbered theorems are correct, apart from one edge case in Thm 15 and small bookkeeping gaps. The errors are in what the prose says the theorems show, and in the explanation of the computation:

1. The self-reproducing floor is reported in the abstract, Section 1, Section 3 and Section 7 as `2^{-c}` times a factor that is 1 without resource bounds. Thm 10 does not say that, and the claim is false (B1).
2. Section 6 names the wrong programs as the cause of both headline effects, and its split into "a floor" and "a capture" is not supported by the data. The majority at bit 17 also weakens steadily as the length bound grows (B2, B3).
3. Remark 11 is true only of the one machine it defines. The conclusions drawn from it in the abstract and Section 7 do not follow (B4).
4. Several summary sentences state upper bounds or necessity claims that no theorem in the note provides (B5, B6, B8, section C).

What I ran: `python3 test_bf8.py` (passes); a rebuild of `bf8enum.c` (binary identical to the committed one); `run_profiles.py` and `make_table.py` in a scratch copy (JSON and both tables byte-identical to the committed ones); the existing enumerator at 7 to 11 commands; `bf8.run` on a dozen hand-written programs; `bf8.mixture_bruteforce` up to 7 commands. No file in the repository was changed except this report.

---

## (A) Verdict per numbered result

| Result | Verdict |
|---|---|
| Def. 1 (bounded mixture) | Sound. `xi^{T,L}` is a semimeasure: the schedule is imposed at every bit and `r(omega,.)` is nondecreasing, so imposing `L` at the last bit equals imposing it at every bit. Two conventions are missing: `r(omega,k)` when `t(omega,k)` is infinite, and `gamma(infinity) = infinity` (F1). |
| Lemma 2 (basic) | CORRECT AS STATED. (iii) needs only `L` finite and holds for any `T`, finite or not. With `L` infinite it claims nothing; the analogous bound for finite `T` would be `2^{-T(|x|)}` by `r <= t`, which the note does not need. |
| Def. 3, Lemma 4 (transfer) | CORRECT AS STATED. |
| Defs. 5 to 7 | Sound as definitions. Two consequences are not acknowledged: every world whose transcript hits `G` hands over, so handover is a function of the transcript (B4); and the three forms of Def. 7 are satisfied by ordinary uncertainty (B9). |
| Thm 8 (calibration) | CORRECT AS STATED. Disjointness and conditional independence are right. The sentences after it drop the conditioning on `H` (B9). |
| Thm 9 (floor) | CORRECT AS STATED for a first hit `x` other than the empty string. `T''` is nondecreasing, and (eq:slack) is exactly the hypothesis of Lemma 4 for the string `xy`. If the empty string is in `G` the statement needs `L >= c` and (eq:slack) refers to `T°(0)`; exclude that case (B11). |
| Thm 10 (self-reproducing floor) | CORRECT, with a small gap in the proof: (eq:twin) and `eta` are defined for a payload `P(x)`, but the payload here depends on `omega_{1:r}` (B11). The fixed point `q = w e(w)`, (eq:quine), the read count, the choice of `L°` and the proof that `y` lies in `SR_m(x)` within `(T,L)` are all right. The prose that summarises the theorem is WRONG (B1). |
| Remark 11 (searcher) | True of the machine it defines. The general conclusion ("conditioning on a handover gains nothing") is NOT PROVED and fails on average for a searcher that keeps looking until it finds a handover (B4). |
| Prop. 12 | CORRECT AS STATED. The word "persistence" oversells (b): the expected number of further generations is `s/(1-s)`, about the size of the floor (C20). |
| Thm 13 (budget) | CORRECT AS STATED, including both bullet consequences and their constants. The count bound `2 ln 2 * m * l` can be improved to `m * l` (F2). |
| Thm 14 (capture) | (a) CORRECT. (b) CORRECT; the counting and the strict inequalities are right, given `xi(x) > 0`. (c) CORRECT under the standing assumption that the matcher is within the bounds, but that assumption fails under exactly the schedules Section 4.4 is about (B8). |
| Thm 15 (machine dependence) | CORRECT for `n >= 1` and nonempty `x`. WRONG AS STATED at `n = 0` in (ii), and at the empty first hit in (i) (B7). `U_k` and `U'_k` are universal in the sense of Def. 3; the identity `M_{U_k} = (1/2) M_Tw + 2^{-k-1} M_U` holds for nonempty strings; `M_Tw(x) = M_U(x)` for a first hit `x` is right. The sentence after the theorem is false (B7). |
| Section 4.4, three observations | First and third: correct, with one omission in the first (B10). Second: the displayed fact is correct; the claim that the surviving hypotheses "are" wrappers and readers is an unproved classification (B12). |
| Thm 16 (feedback) | (a), (b), (d) CORRECT. (c) CORRECT wherever the process is defined; it is undefined once `Z_m` is 0, which can happen after a sampled block (B11). |
| Thm 17 (contrarian) | CORRECT AS STATED, and the bound `j <= L` is tight. The prose restatements are off by one (B10). |

---

## (B) Errors and gaps, most serious first

### B1. The self-reproducing floor is misreported outside the theorem

**Where.**
- `main.tex` 46-48: "self-reproducing hypotheses hold at least a fraction `2^{-c}` of the posterior ... it does not depend on the world or on the amount of data".
- `sec1-intro.tex` 29-32: "programs that emit their own code as the continuation have posterior mass at least `2^{-c}` times a slack factor that is 1 without resource bounds".
- `sec3-floor.tex` 109-113 and 146: "at least a `2^{-c} rho` share", "the floor `eps = 2^{-c} rho` of Thm 10".
- `sec7-answers.tex` 11-13: "at least `2^{-c} rho` of the posterior (Thm 10), where ... `rho` is 1 without resource bounds".

**What is wrong.** Thm 10 gives `2^{-c} * xi^{T°,L°}(x) / xi^{T,L}(x)` with `L° = min(L, m-1) - c`. That factor is not the `rho` of Thm 9, and it is not 1 without resource bounds: with `T` and `L` infinite, `L° = m-1-c` is finite. It is the posterior share of explanations of `x` that read at most `m-1-c` bits, so it depends on the world, on the data and on the block length.

**Counterexample to the unqualified claim.** If `y` is in `SR_m(x)` then `x` is a prefix of `out_U(y 0^infinity)`. So for a fixed `m`, at most `2^m` infinite sequences have any prefix with a nonempty `SR_m`. Take `G = {x : |x| = n}` with `n > m`: of the `2^n` first hits, at most `2^m` have `SR_m(x)` nonempty, and at all the others the self-reproducing share is exactly 0, with or without resource bounds. For `m = 1` at most two sequences qualify.

**Fix.** Define `rho°(x) = xi^{T°, min(L,m-1)-c}(x) / xi^{T,L}(x)` and use it wherever Thm 10 is summarised. Say that it is below 1 even without bounds, and 0 unless the block is long enough to hold the wrapper plus a whole explanation of the context (`m >= c + 1 + r`). In the abstract, separate the two floors: a payload fixed in advance gets `2^{-c} rho`; a self-reproducing continuation gets `2^{-c}` times the share of explanations short enough to fit in one block.

### B2. Section 6 attributes both headline effects to the wrong programs

**Where.** `sec6-computation.tex` 36-50, and `sec1-intro.tex` 51-52 ("shows a floor, a capture").

**What the text says.** For `1^48`: the stream "is printed ... by `+[:+]` for exactly 15 bits, after which the loop ends", and the 0.205 share at bit 16 is "the shape of Thm 9". For the alternating stream: "the five-command program `+[.+]` prints its first 15 bits and then leaves its loop", and the world is "the seven-command program `+[.+.+]`".

**What the data say** (existing enumerator at 10 commands, `T(k) = 24k`; restricted masses from `bf8.mixture_bruteforce`; programs run with `bf8.run`):

| Quantity | Value | Share due to three-command programs |
|---|---|---|
| `xi(1^15 0)`, the "other" mass at bit 16 of `1^48` | 0.005541 | 0.003906 = `2 * 8^-3` (70%), from `+:]` and `-:]` |
| `xi` of the first 16 alternating bits | 0.006817 | 0.003906 = `2 * 8^-3` (57%), from `+.]` and `-.]` |

- `+:]` and `-:]` print `1^15 0`. `+.]` and `-.]` print the first 16 bits of the alternating stream and then fall through with a blank tape. All four use the rule that an unmatched `]` restarts the program while the cell is nonzero. The paper states the rule but mentions none of these programs.
- The programs the paper names are negligible: `+[:+]` and `+[.+]` each weigh `8^-5 = 3.1e-5`, under half a percent of the 15-bit prefix mass.
- The shortest programs that print `1^16` have four commands (14 of them); none has three. So at bit 16 of `1^48` the deviating mass comes from programs *shorter* than every program for the truth. This is the same mechanism as in the alternating example, not a wrapper. The split into "a cheap test gives a visible floor" and "a shorter description takes the majority" is not supported; the two streams differ only in how much mass the long-lived programs have.
- The alternating stream is printed forever by six-command programs, for example `++[:.]` (the cell stays at 2; `:` prints 1 and `.` prints 0). 34 six-command programs print all 48 bits; none with five commands does. "Seven-command" is not the stream's description length.
- Section 6 says the short explanation covers 15 bits; the abstract says 16. The abstract is right, because of `+.]`.

**Fix.** Name `+:]`, `-:]`, `+.]`, `-.]` and the restart rule. Give the stream's shortest programs as six commands. Present both examples as "a shorter program explains the context and continues differently", and drop the claim that the first shows the shape of Thm 9. BF8 has no wrappers (see D4).

### B3. The majority at bit 17 depends on the 10-command limit

**Where.** `main.tex` 63-64; `sec6-computation.tex` 44-50.

**What is wrong.** The statement is exact for the predictor with `L = 30` bits. It is presented as showing "the sizes involved", and no other `L` is reported. Rerunning the existing enumerator (`bf8enum LC 48 0 24 16`):

| Commands | Bit 17, alternating: true / other / none | True, normalised | `xi(z_{1:17})` | `xi(z_{1:16} 0)` | `xi(z_{1:48})` | Bit 16 of `1^48`: other |
|---|---|---|---|---|---|---|
| 7 | 0.157 / 0.419 / 0.424 | 0.273 | 0.000899 | 0.002395 | 0.000356 | 0.275 |
| 8 | 0.210 / 0.442 / 0.348 | 0.322 | 0.001282 | 0.002702 | 0.000615 | 0.243 |
| 9 | 0.256 / 0.452 / 0.291 | 0.362 | 0.001662 | 0.002934 | 0.000893 | 0.221 |
| 10 | 0.294 / 0.457 / 0.249 | 0.392 | 0.002007 | 0.003114 | 0.001155 | 0.205 |
| 11 | 0.326 / 0.458 / 0.217 | 0.416 | 0.002316 | 0.003253 | 0.001397 | 0.194 |

- The mass that continues correctly is still growing by about 15% per extra command at 11 commands (increments 0.00038, 0.00038, 0.00035, 0.00031). The deviating mass is saturating (increments 0.00031, 0.00023, 0.00018, 0.00014).
- The ratio other/true falls 2.66, 2.11, 1.77, 1.55, 1.40.
- Nothing in these numbers shows the majority surviving a longer length bound. If the increments keep shrinking at the observed rates (about 0.90 and 0.77 per command) the true mass overtakes at roughly 17 commands; that is an extrapolation, not a computation.
- The reason is visible in `xi(z_{1:48})`: the long-lived programs for the stream are spread over many lengths, and each extra command adds about as much mass as the one before (0.00026, 0.00028, 0.00026, 0.00024). A 10-command cut therefore removes a large and unknown part of it. The three-command deviators are counted in full.
- A large part of the "none" column is this truncation, not slowness: it falls from 0.424 to 0.217 between 7 and 11 commands.

**Fix.** Report the shares for several `L`, state the direction of the drift, and qualify the abstract ("for the predictor with `L = 30` bits; the share of the true bit rises with `L`"). Say that "none" includes mass cut by the command limit.

### B4. Remark 11 does not support what the abstract and Section 7 take from it

**Where.** `sec3-floor.tex` 115-123; `main.tex` 51 ("A hypothesis that searches all programs for handovers is the wrapper again"); `sec1-intro.tex` 32-33 ("the hypothesis that enumerates all worlds and waits for a handover is the same program"); `sec7-answers.tex` 18-19 and 72-73 ("showing that searching for opportunities is not such a program").

**What is wrong, in two parts.**

1. *The remark covers one machine.* Its searcher draws one world with the prior's own weights and waits. That is the twin by definition. A hypothesis that searches is a different machine. Let `S` split its input into infinitely many worlds, dovetail them, and print the context `x` of the first one found to hand over, then `P(x)`. Let `Q(x)` be the probability that `S` picks `x`, and `H = sum over first hits of M_U(x)`, the prior probability that a world hands over at all. Then `sum_x Q(x) = 1` while `sum_x M_U(x) = H < 1`. The posterior share of `S` at `x` is at least `2^{-|s|} Q(x) / M_U(x)`, and by Cauchy-Schwarz `sum_x Q(x) * Q(x)/M_U(x) >= 1/H`. So on average over the contexts it produces, the searcher beats the twin by a factor of at least `1/H`, up to the difference of the two prefix words. "Conditioning on 'this is a handover' gains it nothing" is false for this machine. (For scale: on BF8 only 9.4% of the prior prints 48 bits within the bounds of Section 6.) The remark's second claim, that the search costs no time, is also specific to the twin: `S` has a long start-up.

2. *The toy cannot express the update it claims to perform.* By Def. 5 every world whose transcript hits `G` hands over. The original argument, as the literature survey records it (items 1.1 and 1.2), turns on a fact that is *not* a function of the data: that the string is being fed to an inductor for an important decision, which "Solomonoff induction can't make ... on its own". The sentence "the anthropic update of the original argument is, in this toy, performed by Bayesian conditioning on `x`" is true because the toy defines the fact away. Hänni's second suggestion says "*some* of them hand their output" to the predictor; the note's formalisation drops the "some".

**Fix.** Restate the remark as the identity "a hypothesis that prints a first hit `x` with probability `Q(x)` and then the payload has share at least `2^{-|s|} Q(x)/M_U(x)`; the twin is `Q = M_U`", and state `H`. Delete "is the wrapper again" from the abstract and "showing that searching for opportunities is not such a program" from Section 7. Add to "What the toy does not settle" that handover is a function of the transcript, so the importance update is outside the model.

### B5. The abstract states the budget without the factor `m`

**Where.** `main.tex` 51-53: "the posterior mass off the true continuation, summed over all cut points, is at most the world's description length".

**What is wrong.** Thm 13(iv) gives `m * l * ln 2`, which exceeds `l` for `m >= 2`. The stronger claim is false. Counterexample: a machine prints `00`, reads one bit `b`, and prints `b` forever. The world `0 0 1 1 1 ...` has the one-bit program `1`, so `l = 1`. With `m = 3` the cut points 0, 1, 2 each have mass 1/2 off the true block, total 1.5 > 1.

**Fix.** "at most the block length times the world's description length" (as Section 7 already says).

### B6. Summary sentences that claim upper bounds or necessity the note does not prove

- **`main.tex` 49, "There is no more than the floor in general."** No theorem bounds the share from above at a given recognisable handover. Thm 8 is a symmetry statement, Remark 11 is B4, and Thm 13 bounds a sum over cut points. Thms 14 and 15 show that more than the floor does occur. *Fix:* "No general argument gives more than the floor."
- **`main.tex` 54, "A majority needs one of three things."** Necessity is not proved. Read literally it is false: a prior-drawn world with a spread-out `pi_m(.|x)` satisfies the majority form with no wrapper, no copy and no slowness. Read with "shorter description" meaning "the programs for `x` that do not continue with `d` outweigh those that do", it is the definition of the majority form. *Fix:* "Three ways to get a majority."
- **`sec7-answers.tex` 45-46, "the answer is no, up to the constant `2^{-c}`."** This needs an upper bound at the deployment point. The note has only the lower bound there, and an average over cut points elsewhere. *Fix:* state the answer as an average over cut points, or as conditional on nothing cheaper than the wrapper existing.
- **`sec7-answers.tex` 14, "three reasons why no argument of this kind yields more."** None of the three is an upper bound at a handover. *Fix:* "three reasons to expect no more".
- **`sec7-answers.tex` 51-52, "It does help against everything that is not a wrapper of the truth, by Thm 13."** Thm 13 bounds a sum. More data lowers the average over cut points; it does nothing against a copy that keeps agreeing (Thm 14) or any deviation at a position that is cheap to name.
- **`sec7-answers.tex` 40-42, "it is close to 1 if ..."** Thm 14 bounds the odds of `y` against `d` only. `pi_m(y|x)` is close to 1 only if `y` also outweighs every other continuation, which in the situation of Thm 14(b) includes the other `N-1` locations. *Fix:* "the odds against the sensor's own continuation are large".

### B7. Thm 15: an edge case, and a false sentence after it

**Where.** `sec4-limits.tex` 110-111 and 124.

- **(ii) is false at `n = 0`.** `M(empty) = 1` and `M_{U'_k}(z_{1:m}) <= 1/2 + 2^{-k-1}`, which is below `1/(1+2^{-k})` for every `k >= 2`. The proof's "`M_{U'_k}(z_{1:n}) <= 1/2 + 2^{-k-1}`" needs `n >= 1`. (i) fails the same way if the empty string is in `G`. *Fix:* state both parts for nonempty contexts, or for `pi_m`, where the claim holds at `n = 0` too.
- **"Both machines change every description length by at most `k+1` bits" is false.** They *raise* every description length by at most `k+1` bits. They lower some without bound: `z_{1:n}` has the one-bit program `0` on `U'_k` for every `n`. That is the point of the construction. *Fix:* "raise ... by at most".
- **"No version ... is invariant" is only half shown for the self-reproduction form.** (ii) makes it fail on `U'_k`. (i) uses a fixed payload and does not produce a machine on which it holds at a high level; that needs the quine construction on `U_k`.
- "whose prefix words are those of `U` preceded by `1^k 0`": it has others too (`0` is a prefix word of the twin). Write "has as prefix words".

### B8. Capture: what the prose claims beyond Thm 14

**Where.** `sec1-intro.tex` 37-40; `sec4-limits.tex` 84-95.

- **(b) needs `N` locations with the same `n`-bit record and pairwise different continuations.** With one sensor, `N = 1` and (b) says nothing. "For all but a small fraction of sensor locations" is a statement about a hypothetical ensemble of placements that share the record and all differ afterwards. `N` sensors with the same future count once. The introduction should say so.
- **"a factor of about `N 2^{-|e(l_0)|}`" (line 86) drops `2^{-c_X} / xi(x)`.** `c_X` contains the description of the whole world. The factor is near 1 only if the context is explained almost entirely through this reader.
- **(c) is not available under a tight schedule.** The matcher searches `l = 0, 1, 2, ...` up to the sensor's location before it prints its first bit. That is the long start-up that the second observation of Section 4.4 excludes. So the cap disappears in the time-bounded regime while (a) and (b) stay. The text presents (c) as "the limit of the effect ... however large `N` is" and never notes this. *Fix:* say that (c) needs `T(1)` at least the search time, and that with a tight schedule no cap is proved.
- The hypothesis of (c) does give what is claimed: the matcher prints the record at the least other location that agrees on the first `n_1` bits, whatever `n` is.

### B9. Calibration: the sentences after the theorem

**Where.** `sec3-floor.tex` 22-29; `sec1-intro.tex` 26-28.

- **"the predictor's distribution *is* the distribution of own continuations among prior-drawn worlds with that context"** is not exactly right. It holds among prior-drawn worlds with that context *that print `m` more bits within the bounds* (the event `H`). Among all worlds that hand over at `x`, a fraction `1 - Z_m(x)/xi(x)` has no own continuation and still receives a block. So the predictor hands over self-reproducing blocks more often than worlds continue with them, by the factor `xi(x)/Z_m(x)`. In the note's own table that stalled share is 25% at bit 17 of the alternating stream, and 45% under the tight schedule. "There is no excess to attribute to the predictor" needs "among worlds that continue within the bounds". The event `H` also depends on `m`.
- **"A malign prior hypothesis in the sense of Def. 7 is therefore a statement about a world, or a population, that the prior does not describe well"** does not follow, and neither does "Malignity can therefore only be defined relative to a world ... that differs from the prior". Def. 7 applies to prior-drawn worlds, and its forms hold for them with positive probability; if `pi_m(.|x)` is uniform on four blocks, the majority form holds for every one. What Thm 8 shows is that on this population predictor and world are exchangeable. *Fix:* say that.
- The population of Thm 8 consists of arbitrary programs to which a handover is applied from outside. Programs that actually call the predictor are more expensive than the predictor and are not in the bounded class.

### B10. Smaller errors in the prose

- **The floor and time bounds.** `main.tex` 48 ("the bound survives time bounds"), `sec1-intro.tex` 45 ("The floor needs only the time of the explanation it wraps"), `sec4-limits.tex` 133-135. By the note's own inequality `r <= t` and Def. 3, every program `v omega` reads `c = |v|` bits before its first output bit, so its first bit comes at step `c` or later. If `T(1) < c`, the wrapper is off schedule at every context and `rho` is identically 0: the wrapper is itself a hypothesis with a long start-up, in the sense of the second observation. (eq:slack) also contains the overheads `a` and `gamma`, which the sentence in 4.4 omits for `gamma`. *Fix:* "the floor survives a schedule that allows at least `c` steps before the first bit and the overhead (eq:slack) afterwards".
- **Off by one.** `sec5-feedback.tex` 67 ("After at most `L` rounds"), `main.tex` 60-61 ("within `L` steps"), `sec7-answers.tex` 61. Thm 17 gives mass 0 for `j > L`. Example with a hypothesis left after `L` rounds: a machine copies its first `L-1` input bits, then reads the `L`-th bit `c` and prints `c 0`. The contrarian record is `1^L` with mass `2^{-L}`; the predictor still predicts (0) in round `L+1`, and only then has nothing left. *Fix:* "after at most `L+1` rounds".
- **`sec3-floor.tex` 72-73, "`P` a single flipped bit".** A payload is a function of `x` and cannot know which bit is the flipped one. Hutter's construction uses a constant bit; the bound for the flipped bit follows by taking each constant in turn.
- **`sec4-limits.tex` 27-28, "with equality if the sampler gives no answer ..."** Equality holds only if "no answer" counts as differing from the transcript.
- **`sec4-limits.tex` 149, "`xi(z)` ... is 0 when no program within the bounds prints `z`".** Right for finite `L`. For infinite `L` a closed set of inputs of positive measure can print `z` on schedule without containing a cylinder.

### B11. Small gaps in proofs

- **Thm 10, bookkeeping.** `Tw_s` writes `s omega_{1:r} 1 0^infinity`, which is not `P(x)`. (eq:twin) must be restated for `W` on input `e(w) omega`, with `a` absorbing the time to read `e(w)`. A finite `eta(n,j)` independent of `r` needs a word of justification: either `W` keeps its record so that no rewind is needed (the cost moves into `a`), or `eta` is taken over inputs with `r <= m`, which is all the proof uses since `L° < m`.
- **Thms 9, 10, 15.** Exclude the empty first hit.
- **Thm 16(c).** Add "as long as `Z_m > 0`"; the sampled record can reach a context where every surviving program stalls.
- **Thm 14(b).** The first sentence needs `xi(x) > 0`.

### B12. Section 4.4, second observation

"Under a tight schedule the hypotheses that can depart from the truth are those that ride on a cheap explanation of the context: wrappers ... and readers" is a classification, not something "immediate from the definitions". *Fix:* "include".

---

## (C) Overclaims in the prose

Items already argued in (B) are listed by reference.

**Abstract (`main.tex`).**
1. Bullet 1, "at least a fraction `2^{-c}` ... does not depend on the world or on the amount of data": false for self-reproducing hypotheses (B1).
2. "the bound survives time bounds": only if `T(1) >= c` and (eq:slack) holds (B10).
3. "There is no more than the floor in general": not a theorem (B6).
4. "A hypothesis that searches all programs for handovers is the wrapper again": B4.
5. "at most the world's description length": missing factor `m` (B5).
6. "A majority needs one of three things": necessity not proved (B6).
7. "within `L` steps": `L+1` (B10).
8. Last sentence: true for `L = 30` only, and the mechanism named in Section 6 is not the one at work (B2, B3).

**Section 1.**
9. Item 1, "Malignity can therefore only be defined ...": B9.
10. Item 2, "a slack factor that is 1 without resource bounds" and "the hypothesis that enumerates all worlds ... is the same program": B1, B4. The remark's searcher draws one world; it does not enumerate.
11. Item 3, "A handover at a position that is not cheap to recognise is safe": proved only as an average over a window of cut points (`sec4-limits.tex` 32-34 has the same step from an average to "a position").
12. Item 4: hypotheses of Thm 14(b) not stated (B8).
13. Item 6, "The floor needs only the time of the explanation it wraps": B10.
14. "shows a floor, a capture": BF8 has no wrappers and both examples have the same cause (B2).
15. "What the toy does not settle", "in the toy their formal counterpart is the wrapper": a modelling choice presented as an identification. A wrapper is always `c` bits longer than what it wraps; the agents of the original argument are claimed to be shorter than the truth.
16. Every statement about "the original argument" (here, `sec3-floor.tex` 121, `sec4-limits.tex` 43-45 and 142, `sec7-answers.tex` 42-43 and 72) rests on sources that the literature survey marks as not opened in this session (items 1.1 and 1.5, both tagged UNVERIFIED: host blocked, content from memory and search digests). The summaries agree with the survey, but the note cites the posts as if read. Say so once.

**Section 7.**
17. Lines 11-13: B1. Line 14: B6.
18. Lines 23-24, "a wrapper that simulates, tests, and prints its own text is some hundreds of bits long": stated as fact, and the same sentence says it was not measured. A wrapper needs a self-interpreter with lazy input. That may be a few hundred bits on machines designed for short self-interpreters (my recollection, not checked), and is far more on anything "one would write programs in" without a built-in `eval`. In Thm 10, `c = 3|w| + 1`, three times the prefix word. *Fix:* "we guess", or measure it.
19. Lines 25-28, "about `1/eps` independent handovers ... are needed": the floor is a lower bound on a probability, so `1/eps` handovers *suffice*. Same wording at `sec3-floor.tex` 146.
20. Line 27, "persists for a geometric number of generations": the mean number of further generations is `s/(1-s)`. With `s` near the floor, the lineage ends at the next generation with probability about `1 - 2^{-c}`.
21. Lines 36-37, "hypotheses that simulate the world can read the deployment off their own simulation, so such a test is available to them": **no result in the note covers a trigger that depends on the simulated world's state.** In Thms 9 and 10 the test is a decidable set of output prefixes, checked on the copied output. A generic wrapper cannot interpret the internal state of an arbitrary explanation. A hypothesis built on one specific explanation `p` can, but its mass is `2^{-|p|-c'}`: a share of `p`'s own posterior weight, not `2^{-c} rho`, and `c'` contains the description of where the trigger sits in that world. The sentence also conflicts with Section 4.4: a hypothesis that simulates a world containing the predictor up to the deployment costs more than the predictor's schedule allows. *Fix:* delete the clause or state it as a conjecture with this cost accounting.
22. Lines 40-46: B6.
23. Lines 50-52, "their share does not depend on the amount of data": true of the constant `2^{-c}` for a fixed payload without bounds. With bounds `rho(x)` depends on `x`; for self-reproduction the share depends on whether an explanation still fits in the block (B1).
24. Lines 63-66, MAP against sampling. "by Thm 14(b) it does not when the world is one of many ..." is not what (b) says. The fact is pigeonhole: one returned block equals the continuation of at most one of `N` worlds with pairwise different continuations, so "it does not" is wrong for that one. It is not a contrast with sampling, which returns a typical such world's continuation with probability below `1/(delta N)`. The contrasts the note could state are: MAP never outputs a share below the largest, so the accumulation of Prop. 12(a) does not occur; and by Thm 13(iii) the bit-wise MAP predictor errs at most `l` times on an in-class world.
25. Lines 66-68, "remove the floor at that position": it shrinks to `2^{-K(n)-O(1)}`.
26. Lines 72-73: B4.

---

## (D) Computation and numbers

**D1. Reproducibility: no problem found.**
- `python3 test_bf8.py` prints `ok`.
- `gcc -O2` on `bf8enum.c` gives a binary with the same md5 as the committed one.
- `run_profiles.py` in a scratch copy gives a `profiles.json` byte-identical to the committed one (1 min 35 s); `make_table.py` reproduces both tables exactly.
- The 10-command run reports 855,587,944 leaves and 839,072 strings, matching "`8.6e8` branches" and "`8.4e5` strings".
- In that mixture no string violates `xi(x0) + xi(x1) <= xi(x)`, and every mass is a multiple of `8^-10`.
- Beyond the committed tests, the enumerator equals `mixture_bruteforce` at 5, 6 and 7 commands with `N = 48` for `T(k) = 24k` and `3k`, and at 4 commands for `6k`.

**D2. Every number in Section 6 and in both tables matches the JSON.** Checked: all 36 cells of Table 1; the four rows of Table 2 (recomputed independently from the mixture file); 0.205 and 0.037; "below 0.01 except at 15-17 and 31"; 0.294 / 0.457 / 0.249 and 0.392; 0.080, 0.105, 0.054; 0.022 to 0.038; median 0.0014; the three pairs under the tight schedule; `1593 * 2^-25`, `2^-26`, 0 and `2^-26` in the nine-command example. The figure caption matches what `run_profiles.py` plots.

**D3. Code against definitions.** `bf8enum.c` agrees with its header, with `bf8.py` and with Def. 1. In detail:
- Bracket matching is static over the commands read so far. An unmatched `]` with a nonzero cell sets the instruction pointer to command 0, as the paper says.
- Every executed command is one step, including `[` and `]` whether or not they jump.
- The schedule test (`steps >= T0 + T1*(outlen+1)`) runs before each executed command and not during a forward scan. This is equivalent to requiring bit `k` at a step no later than `T(k)`.
- Mass `8^-nread` is added when a bit is emitted, so the length bound is applied at the last bit, as in Def. 1.
- The machine forks at each read. The restore after a fork is correct: it zeroes what the child touched and copies back the parent's range, with one snapshot buffer per depth.

`bf8.py` has the same control flow as the C file, so the committed test checks the fork and restore logic, not the semantics. Three points of semantics are in the code but missing or ambiguous in the paper:
- `]` jumps to *just after* the matching `[`, which is not executed again. The paper's "jumps back to the matching `[`" suggests one more step per pass, which would change which programs meet `T(k) = 3k`.
- A forward jump reads the commands it skips. They count toward `L` and cost no step. The paper does not say so.
- Hence one BF8 step can read many input bits, and BF8 does not satisfy "each step reads at most one input bit, so `r <= t`" of Section 2. No result used for BF8 needs `r <= t`, but say it.

**D4. BF8 is not universal: the claim is correct.** A rigorous version of the reason given: suppose `v` were a prefix word for the identity machine. On `v 0^infinity` every command after `v` is `+`. If the instruction pointer ever enters that tail it executes `+` forever, or scans forever for a `]`, and prints only finitely many bits, not `0^infinity`. If it never does, the output is the same for all inputs that agree on the at most two bits completing the last command, including `0^infinity` and `000 1^infinity`. Either way the identity is not simulated. Thms 8, 13, 16, 17 (and Lemma 2, Prop. 12) use no universality; I checked each proof. Section 6 should add that Thms 14 and 15 do not apply to BF8 either.

**D5. Explanation of the examples: wrong.** See B2 and B3.

**D6. Smaller points.**
- Lines 19-20, "the positions where the mass off the true bit is largest after the first ten bits": not what the table shows. For the alternating stream, 18 (0.313) and 19 (0.083) exceed 31 (0.065); the row for `1^8 0^40` is `k = 9`. The caption's "selected positions" is accurate.
- Line 67, "A tighter schedule shifts mass off the truth": not uniform. The table's own row for `0^48` at 17 goes the other way (0.958 to 0.969). The true share is higher under `3k` than under `24k` at 9 of the 48 positions of `1^48`, at 16 of `0^48` and at 17 of the alternating stream.
- Line 70, "removes more of the mass ...": true as a proportion (true mass kept 23%, 30%, 0.9%; other mass kept 74%, 56%, 33%). In absolute terms it is false for bit 9 of `1^8 0^40`. Write "a larger fraction".
- "none" is defined as "prints nothing on schedule"; it also contains everything cut by the 10-command limit (B3).
- The population numbers and the middle panel are conditional on the world printing that bit within the bounds (prior mass 0.13 at position 16, 0.094 at 48). Text and caption omit this.
- Left panel: nine positions of the alternating curve and two of the zeros curve are exact zeros (every program within the bounds continues correctly there). On the log axis they fall out of the frame and read as small values.
- Table 2 checks the finite form of Thm 13(ii) and (iii) (with `xi(z_{1:48})`, not the limit). True and stronger; say "the finite form".
- `test_bf8.py` line 35: the comment mentions a program `.]` that no assertion tests.

---

## (E) Citations

Checked against the literature survey; "VERIFIED" and "UNVERIFIED" are its status tags.

- **Hutter 2007, eq. (17)** (VERIFIED). The note's use is consistent: the lower bound `2^{-K(n)}` up to a constant, for every `n` and every sequence, proved by programs "`q n* p`" that copy `p` and then print a fixed symbol. That is the twin with a constant payload (see B10 on "flipped bit"). "The budget is Solomonoff's bound in its deterministic form" matches Hutter's eq. (3) and the `Km ln 2` form quoted after eq. (16).
- **Solomonoff 1978** (UNVERIFIED; quoted through Hutter). Standard attribution, not checked.
- **Cohen, Hutter, Bengio, Russell 2025** (VERIFIED, arXiv v1). Consistent for the construction and for "a marker in the transcript". The wording "a fixed fraction of a Bayesian imitator's posterior follows any given policy after an unprecedented event" goes beyond the source in two places. Their Theorem 1 is a KL bound for a policy of near-optimal value for a utility function, not for any given policy. The fraction is `2^{-Delta}` with `Delta = K(U_m) + K(E) + K(v xi(x_{<2t})) + d`, which depends on the event, the utility and a function of the history; it is independent of the amount of training data, which is the sense in which it is "fixed".
- **Cohen and Hutter 2020** (VERIFIED). "A resource-bounded class is used the same way" is consistent with Theorem 11 and Definition 8. There the twin's weight is used to prove that a pessimistic agent defers; a clause saying so would help.
- **Leike and Hutter 2015** (VERIFIED). "Prediction analogue of the dogmatic prior" is a fair description: both mix, with weight 1/2, a hypothesis that copies the original until a condition and then departs. The note claims no more.
- **Putnam 1963 / Legg 2006** (Legg VERIFIED; Putnam known through Sterkenburg 2026). Consistent. Legg's Lemma 3.3 gives the sequence and its complexity bound "that of the predictor plus a constant".
- **Wyeth and Hutter 2025** (VERIFIED). "for the unbounded mixture with its own outputs in the sequence" goes beyond the source. Their Theorem 7 concerns an adversarially chosen action sequence; the survey notes "the adversarial action sequence need not be one the agent's own policy produces; the authors leave on-policy behaviour open". Write "with the agent's actions in the sequence, chosen adversarially".
- **Christiano 2016, Xu 2020** (UNVERIFIED): see C16.
- **Hubinger et al. 2023 section 2.5, Armstrong and O'Rourke 2017, Oesterheld et al. 2023** (VERIFIED). Uses are consistent.
- `filan16` and `hutter05` are in the bibliography and never cited.

---

## (F) Minor points

1. Conventions missing: `r(omega,k)` when `t(omega,k)` is infinite; `gamma(infinity) = infinity`; `T°(k)` infinite in (eq:slack).
2. `sec4-limits.tex` 30: the count can be `m l` instead of `m l * 2 ln 2`. With `b_i = -log_2 xi(z_{i+1}|z_{1:i})`, the sum of the `b_i` is at most `l`, each index lies in at most `m` blocks, and a block with `tau_m > 1/2` has block sum above 1.
3. Notation clashes: `l` is a program length (Thm 13) and a location (Section 4.2); `e-bar` codes strings (Thm 10) and numbers (Section 4.2); `a` is a time bound and, in the proof of Thm 10, a string; `k` is an output index and the parameter of `U_k`; `N` is a horizon (Thm 13), a number of locations (Thm 14) and the stream length in the code; `c_m` (matcher) next to the block length `m`.
4. Thm 13: "for all `n <= N`" is used only in (i).
5. `sec1-intro.tex` 21: "All statements are for ... the mixture `xi`" is not true of Thm 15, which is about `M`.
6. `sec4-limits.tex` 37-38: "the budget says there are few of them" mixes two facts. That few tests are cheap is Kraft's inequality; the budget says few cut points carry much mass.
7. `sec5-feedback.tex` 42-45: "at the first round" holds only if the first default block is already off schedule.
8. `sec2-toy.tex` 127-129: deciding the three forms presupposes that the world is given together with its handover point; whether a world ever hands over is only semi-decidable.
9. Two overfull lines in the PDF (`sec3-floor.tex` 98-107, 1.1pt; `sec5-feedback.tex` 26-30, 8.2pt).
