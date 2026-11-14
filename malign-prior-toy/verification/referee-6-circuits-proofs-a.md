# Referee report 6 (proofs, part A) on Section 7, "Circuits in place of programs", first half

Date: 2026-11-14. Version refereed: the working tree at commit `6b534400` ("circuit tables; the paper builds with both new sections"). I had not seen the note before.

**Under review.** `paper/sec7-circuits.tex` from its beginning through the subsection "A ceiling for separable triggers" (lines 1 to 600): the setup, Theorem "Two degenerate readings" (`thm:c-readings`), Theorem "Measure, calibration, budget, feedback" (`thm:c-transfer`), Theorem "Core law; price of an active gate" (`thm:c-core`), Lemma "Sizes of triggers and payloads" (`lem:c-trigger`), Theorem "Floor for a triggered payload" (`thm:c-floor`), Theorem "Minimum-size circuits" (`thm:c-minimum`), Theorem "Ceiling for separable triggers" (`thm:c-ceiling`), Proposition "Small self-contained gadgets" (`prop:c-gadget`), and the prose between them. The source of the section is `research/circuits-final.md`. Another referee has the second half.

**Lens.** Mathematics. For every numbered statement and every displayed or worked claim I wrote the statement down, derived it, read the proof line by line, checked constants, directions and edge cases, and checked each use of an earlier result of the note against that result's statement. For the statements taken from the source by pointer I compared the two statements and checked the source's proof.

**Method.** Pencil and paper for every proof. Python for exact counting of small Boolean circuits and for arithmetic: my own enumerator of gate lists and of reduced circuits, my own dynamic programme for the number of circuits per function (it agrees with `code/circuit_count.py` at `(k,s)=(2,4),(3,4),(4,3)`), exact rational arithmetic for the core weights, and a simulation of pointer structures. The scripts count circuits and truth tables and nothing else. They are in a scratch directory outside the repository. I changed no file except this report.

## Verdict

Every numbered statement in this half is correct as stated, with its constants, and every proof given in the paper is complete; I found no wrong inequality, no wrong direction and no missing hypothesis in a theorem, lemma or proposition. The two statements taken from the source without proof (the AND family, `thm:c-minimum`(e), and `prop:c-gadget`) agree with the source, and the source's proofs are correct. The transcription from the source neither strengthened nor weakened any statement. The errors are in worked numbers and in the prose. One of them changes what the reader is told a theorem shows: the list of limits after `thm:c-ceiling` says that the bound, summed over all input-only triggers with `g` gates, reaches 0.57 at four gates and exceeds 1 at five. Those figures count all gate lists of `g` gates as triggers; the theorem's triggers are reduced circuits, of which there are far fewer, and the correct sums are about 0.001 for each `g` up to 5, about 0.14 for all triggers of at most 19 gates together, and above 1 only from about 25 gates on (finding 1). The other findings are small: a threshold `A=43` that belongs to an older trigger count, bit prices that leave out the term for the size weight, a sentence that calls `k-1-z(n)` the price of the test and then says it is zero at dyadic cuts, a typical active size "of order `sqrt(k+s)`" that holds only when `s` is large against `k^2`, a few sentences that leave out an assumption or a parameter, and three summary sentences outside the section (findings 15 and 17).

---

## Findings

Severity: **error** (false as written), **overclaim**, **gap** (an assumption or an open point is missing), **unclear**, **minor**. Each finding is marked **[section]** or **[summary]**. Line numbers are those of `paper/sec7-circuits.tex` unless another file is named.

### 1. The sums over many triggers are computed with the wrong count. error [section]

**Where.** Lines 556 to 558, item (v) of the list after `thm:c-ceiling`. The same figures are in the source (`research/circuits-final.md` 232, marked "recomputed") and come from `research/circuits-verify-model.md` 334.

**Sentence.** "Summed over all input-only triggers with `g` gates it is `8·10^-4`, `0.0096`, `0.082`, `0.57` for `g=1,2,3,4`, and it exceeds 1 at `g=5`."

**Problem.** The bound of `thm:c-ceiling`(c) is `12|Θ| / (g! s_D (16(k-1))^(g+1))`, and `Θ` is a set of reduced circuits of `g` gates that read inputs only (the circuit induced on `A_r` is always reduced). The quoted figures are this bound with `|Θ|` replaced by `N_g = prod_{i<=g} 16(k+i-1)^2`, the number of all gate lists of `g` gates: `12 N_g/(g! 1000 · 304^(g+1))` is `8.3·10^-4`, `0.0096`, `0.082`, `0.57`, `3.46` for `g=1,...,5`, exactly the paper's numbers. The number `R_g` of reduced circuits of `g` gates on `k=20` inputs is 6 400, 4 198 400, 4 199 219 200, `5.69·10^12`, `9.80·10^15` for `g=1,...,5` (for `g=2`: `6400 · 16 · (21^2-20^2)`; for `g=3`: `4096 · 400 · (41·43 + 400·2)`; in general from `sum_{b<=a} R_b N_a β_a(b) = N_a`; checked against direct enumeration for `k=2,3`, `g<=4`). With `|Θ| <= R_g` the bound is

| `g` | 1 | 2 | 3 | 4 | 5 | 10 | 19 | 25 | 28 |
|---|---|---|---|---|---|---|---|---|---|
| bound for all triggers with `g` gates | `8.3·10^-4` | `9.0·10^-4` | `9.8·10^-4` | `1.1·10^-3` | `1.2·10^-3` | `2.9·10^-3` | `0.035` | `0.33` | `1.24` |
| sum over `0,...,g` (all 20 inputs at `g=0`) | `1.6·10^-3` | `2.5·10^-3` | `3.5·10^-3` | `4.6·10^-3` | `5.8·10^-3` | `0.016` | `0.14` | `1.06` | `3.6` |

So the statement "it exceeds 1 at `g=5`" is false for the quantity named; the paper's figures overstate the bound by the factors 10.8, 83, 520 and 2785 at `g=2,...,5`. The theorem is stronger than the paragraph says. For `k=20` and `s_D=1000` all separable input-only triggers of at most 5 gates have together at most 0.6 per cent of the posterior, and all of at most `k-1=19` gates, which is enough for the position test of `lem:c-trigger`(a) at every cut, at most 14 per cent. The sum is empty only from about 25 gates on (it also grows like `1/s_D` as `s_D` falls).

**Corrected text.** "(v) *The sum over many triggers.* For `k=20` and `s_D=1000` the bound is `2^-14.6` for the single trigger 'a given never-varied input'. Summed over all reduced input-only circuits with `g` gates it is about `10^-3` for each `g<=5` (`8.3·10^-4` at `g=1`, `1.2·10^-3` at `g=5`), and summed over all `g<=19` it is at most `0.14`. It exceeds 1 only from `g=28` on for a single `g`, and from `g=25` on for the sum over all smaller triggers. The bound falls like `1/s_D`." The source and its referee report should carry a note.

### 2. `A=43` does not belong to the lemma of this section. minor [section]

**Where.** Lines 592 to 593.

**Sentence.** "for `k=20` it needs `σ>=1744` for `A=1` and `σ>=15 856` for `A=43`, which covers blocks of up to 16 bits at the worst position."

**Problem.** By `lem:c-trigger` and `thm:c-floor` the wrapper for a block of `m` bits at the worst position has `a = (k-1) + max(1, 2^ceil(log2 m) - 3) + 3` gates, which is 35 for `m=16` and 51 for `17<=m<=32`. So `A=35` covers blocks of up to 16 bits, and it needs `σ >= 4·55^2 - 20 = 12 080`. The value 43 is `2k+2m+1` with `m=1`, from the interval test of an earlier draft (`research/circuits-verify-model.md` 165). The sentence is true (35 <= 43) but the threshold is not the one the lemma gives.

**Corrected text.** "for `k=20` it needs `σ>=1744` for `A=1` and `σ>=12 080` for `A=35`, which covers blocks of up to 16 bits at the worst position."

### 3. The bit prices leave out the term for the size weight. minor [section]

**Where.** Lines 388 and 394 to 398; the same figures are in `research/circuits-final.md` 400 and 498.

**Sentences.** "A gate appended to an explanation of `σ` gates costs at most `4+2log2(k+σ+a-1)+log2(1/ϱ)` bits"; "for `k=20` and explanations of 1000 gates an appended gate costs about 24.0 bits. A one-bit deviation costs about 24 bits at a dyadic cut and at most 480 bits at the positions hardest to name; a block of 64 arbitrary bits adds at most 64 gates for payload and selector, about 1540 bits."

**Problem.** `4+2log2(1020) = 23.99`, so 24.0, 480 and 1540 are `log2(N_{σ+a}/N_σ)` alone (I get 24.0, 480.3, 1540.9). The formula in the same sentence has the further term `log2(1/ϱ)`, which under the length prior, the prior of parts (b) and (d), is one bit per gate. Under the length prior the figures are 25.0, 25, 500 and about 1605. (For comparison, the price the posterior charges for one more active gate of a core of 1000 gates under the length prior is 24.7 bits, computed from the core weights.) Also `ϱ` is written without arguments: the term is `log2(1/ϱ(σ,a))` for the whole wrapper of `a` gates, not per gate.

**Corrected text.** "A wrapper of `a` gates appended to an explanation of `σ` gates costs at most `a(4+2log2(k+σ+a-1)) + log2(1/ϱ(σ,a))` bits ... In numbers, for `k=20` and explanations of 1000 gates an appended gate costs about 24.0 bits and the bit for the size, 25.0 under the length prior. A one-bit deviation then costs about 25 bits at a dyadic cut and at most 500 bits at the positions hardest to name; a block of 64 arbitrary bits adds at most 64 gates, about 1600 bits."

### 4. `k-1-z(n)` is the size of one test, not the price of recognising the cut. unclear [section]

**Where.** Lines 321 and 391 to 392.

**Sentences.** "The count in (a) is exact (source, Lemma 7(a))." "The counterpart of the `K(n)` of the note is `k-1-z(n)` gates; like `K(n)` it is small at a few positions, and it is zero at every dyadic cut with a block no longer than the context."

**Problem.** The count is exact for the function `[t-1>=n]` (I checked the source's lower bound, and by enumeration for `k=3,4`). A wrapper needs less: any wire that is 0 on the context and 1 on the block. At `n=2^j` the formula gives `k-1-j`, which is zero only for `j=k-1`; the zero of the second sentence comes from the different test of part (b). For a one-bit block the conjunction of the index bits that are 1 in `n` is another test, with `popcount(n)-1` gates (source, Lemma 7(c), not taken over), often fewer. So the price of the test is at most `min(k-1-z(n), ...)`, and its exact value is not determined in the paper; only its largest value is (`k-1` gates at `n=2^k-1`, where the test must be the conjunction of all index bits).

**Corrected text.** Line 321: "The count in (a) is exact for the function `[t-1>=n]` (source, Lemma 7(a)); a wrapper may use any cheaper wire that is 0 on the context and 1 on the block, as in (b)." Lines 391 to 392: "The counterpart of the `K(n)` of the note is the number of gates of such a test: at most `k-1-z(n)`, at most `popcount(n)-1` for a one-bit block, and zero at every dyadic cut with a block no longer than the context; like `K(n)` it is small at a few positions."

### 5. The test on the data: a count that reads as doubled, and an upper bound stated as a cost. minor [section]

**Where.** Lines 322 to 326 and 392 to 394.

**Sentences.** "the source uses `w` shifted copies of `E` and at most `w(σ+2k)+g_φ+k+1` further gates (Lemma 7(f) there)." "Third, a test on the data costs copies of the explanation".

**Problem.** In the source the function is computed by `E` followed by at most `w(σ+2k)+g_φ+k+1` gates, and the `w` copies of `E` are among them (`w` copies of `σ` gates, `w` subtractors of at most `2k` gates, the test, a guard of at most `k-1` gates, one AND, one payload gate; I checked the count). "Copies and ... further gates" reads as if the copies came on top. The second sentence states as a cost what line 325 says is an upper bound without a matching lower bound.

**Corrected text.** "the source computes it by `E` followed by at most `w(σ+2k)+g_φ+k+1` gates, among them `w` shifted copies of `E`". "Third, in the construction used a test on the data costs copies of the explanation".

### 6. "Of order `sqrt(k+s)`" holds only for `s` large against `k^2`. minor [section]

**Where.** Lines 279 to 282.

**Sentence.** "Under `μ_s` the active part of a typical circuit has of order `sqrt(k+s)` gates."

**Problem.** For fixed `k` and `s -> ∞` the mean number of active gates is about `2.1 sqrt(s)` (simulation: 2.08 and 2.21 at `k=4`, `s=10^4, 10^5`; 1.88 and 2.02 at `k=20`). When `k` is not small against `sqrt(s)` it is about `1+2s/k`, far below `sqrt(k+s)`: 1.2 at `k=1000`, `s=100` (`sqrt(k+s)=33`), 2.9 at `k=s=1000` (45), 11.2 at `k=200`, `s=1000` (35). A limit law for `s -> ∞` at fixed `k` can give only the first regime; I did not read the cited source.

**Corrected text.** "Under `μ_s`, for fixed `k` and large `s`, the active part of a typical circuit has of order `sqrt(s)` gates (about `1+2s/k` gates while `s` is small against `k^2`)."

### 7. The prior mass of the family of wrappers needs (A1) and a choice of `σ`. minor [section]

**Where.** Lines 404 to 407.

**Sentence.** "its prior mass is at most `(N_σ/N_{σ+a}) H_C` by construction".

**Problem.** The family has prior mass `sum_W ϱ(σ_W,a) (N_{σ_W}/N_{σ_W+a}) q(W)`. This is at most `(N_σ/N_{σ+a}) H_C` if `ϱ<=1`, which is assumption (A1) and is "used only where named", and if `σ` is the least size of a calling circuit. The statement "repaid the factor `1/H_C`" is exact only when all users have one size; in general the share at `x` is between the least and the largest value of `ϱ N_σ/N_{σ+a}` times `κ(x)`.

**Corrected text.** "its prior mass is at most `max_σ[ϱ(σ,a) N_σ/N_{σ+a}] H_C`, which under (A1) is at most `(N_σ/N_{σ+a}) H_C` with `σ` the least size of a user".

### 8. The small cases quoted against the floor are for the fixed-size prior. minor [section]

**Where.** Lines 401 to 403.

**Sentence.** "Parts (a) to (c) are floors for one construction ...: in exact small cases (`k=3`, `s=4,5`) the floor is at most `2·10^-8` where the posterior probability of the flipped bit is between `0.06` and `0.95`".

**Problem.** Parts (a) to (c) are stated for mixture priors; the computation is under `μ_s`, where the floor is the same injection, `#{fitting, size s-3}/#{fitting, size s}`. I reproduced it for the world `b_0∧b_1`, cuts `n=3,...,7`: floors `1.5·10^-8` to `1.9·10^-8` at `s=4` and `5.1·10^-9` to `6.1·10^-9` at `s=5`, flipped-bit probabilities `0.057` to `0.949`. For the two other worlds of the referee's table the ranges differ (parity: floor `2.1·10^-8` at `n=4`, `s=4`, and probability `0.002` at `n=7`).

**Corrected text.** "in exact small cases under `μ_s`, where the same injection gives the floor (`k=3`, `s=4,5`, the world `b_0∧b_1`, cuts 3 to 7), the floor is at most `2·10^-8` where ...".

### 9. "4 of the 14" is for `k=3`. minor [section]

**Where.** Lines 486 to 489.

**Problem.** The count depends on `k`: the fitting one-gate circuits number `2k+8` (4 with both pointers on `x_1`, `2(k-2)` with the other pointer on an input that varies, 8 with it on the frozen input), and 4 of them deviate at each query with the frozen bit set. For `k=3` this is 4 of 14 (confirmed at each of the four queries), for `k=4` it is 4 of 16 (confirmed).

**Corrected text.** "for `k=3` and the target `x_1` with a frozen coordinate, 4 of the 14 fitting one-gate circuits ...".

### 10. "Keeps mass ... however large the nominal size". unclear [section]

**Where.** Lines 271 to 272.

**Sentence.** "a function with a small circuit keeps mass at least `β(size(f))` however large the nominal size."

**Problem.** True as an inequality, but under `μ_s` the bound itself falls with the nominal size: `β_s(a) <= p_s e_1^(a-1)/(a-1)!`, so it falls like `s^-2`; the total mass of all one-gate cores is `k^2/(k+s-1)^2`. What is kept is a mass that falls polynomially in `s` where the weight `1/N_s` of one list falls faster than exponentially. Under the length prior `β_q(a)` is a constant.

**Corrected text.** "a function with a small circuit has mass at least `β(size(f))`, which under `μ_s` is at least `p_s/N_{size(f)-1}` and so falls only like `s^-2` with the nominal size".

### 11. "The two ways". overclaim [section]

**Where.** Line 477.

**Sentence.** "These are the two ways in which a predictor confined to minimum-size circuits generalises."

**Problem.** The theorem proves two facts about minimum-size circuits (no pointer to a frozen input; an even split in one family and a pairing at the last gate). It does not classify how such a predictor generalises, for instance at a query that is new in inputs that varied and is not novel for the last gate.

**Corrected text.** "Two things are proved about how a predictor confined to minimum-size circuits generalises."

### 12. `thm:c-floor`(c): the range of the minimum, and "the bound in (a)". minor [section]

**Where.** Lines 347 to 351.

**Problem.** In `min_σ[ϱ(σ,a_x) N_σ/N_{σ+a_x}]` the range of `σ` is not given. It must be the set of sizes of the calling circuits with context `x`; over all `σ` the minimum is 0 when `s_max=∞`. Part (a) has two bounds; the one meant in "the expectation over uses of the bound in (a)" is the bound on the posterior share, taken at the context `X` with a trigger that is 0 on positions `1,...,|X|` and 1 on the block.

**Corrected text.** "the wrappers around them alone have share at least `min[ϱ(σ,a_x) N_σ/N_{σ+a_x}] · κ(x)` at `x`, the minimum being over the sizes `σ` of these calling circuits."

### 13. Which triggers the 28.5 per cent counts. minor [section]

**Where.** Lines 560 to 563.

**Problem.** I reproduced both figures: at `s=2`, 16 of the 48 fitting circuits that answer 0 at 111 have a core separably triggered by the frozen input; at `s=3`, 8512 of 29 824 (28.5 per cent) have a core separably triggered by the frozen input or by a one-gate trigger that vanishes on the data. With the frozen input alone the figure at `s=3` is 8128, which is 27.3 per cent. The sentence does not say which `Θ` is meant.

**Corrected text.** "... carry 16 of the 48 circuits that are off the target at the query 111 for `s=2`, and, with one-gate triggers included, 28.5 per cent of that mass for `s=3`".

### 14. The ceiling is for inputs frozen at 0. minor [section]

**Where.** `thm:c-ceiling`, lines 494 to 507, and "a given never-varied input" in line 557.

**Problem.** `thm:c-minimum` calls a coordinate frozen if it is constant on `I`; the triggers of `thm:c-ceiling` are 0 on `I`, and a mux has `ς(·,0)` equal to the identity or the negation. A last gate `h∧v` with `v` frozen at 1 is the same kind of circuit and is not in the class as defined. The mirrored statement (triggers that are 1 on `I`, `ς(·,1)` the identity or the negation) holds with the same proof and the same bound.

**Corrected text.** Add after the theorem: "For triggers that are 1 on `I` the same holds with the roles of `ς(·,0)` and `ς(·,1)` exchanged."

### 15. The README drops "for data that need at least two gates", and "at such a use" has no clear antecedent. overclaim [summary]

**Where.** `README.md` 47 and 46.

**Sentences.** "Minimum-size circuits never read an input that did not vary." "... one gate where the use is marked by an input bit that never varied in the data ..., up to k gates at the positions hardest to name. Under the length prior each answer keeps at least a polynomial share at such a use."

**Problem.** The first sentence is false without the hypothesis `s_D>=2` of `thm:c-minimum`: the paper's own exception has 4 of 14 minimum-size circuits reading the frozen input (`paper/sec1-intro.tex` 149 and `paper/sec8-answers.tex` 145 to 146 keep the hypothesis). In the second, "such a use" follows "the positions hardest to name", where the floor of `thm:c-floor`(b) is a `k`-th power; the polynomial share of part (d) is proved at uses marked by a never-varied bit only.

**Corrected text.** "A minimum-size circuit for data that need at least two gates never reads an input that did not vary." "Where the use is marked by a never-varied bit, each answer keeps at least a polynomial share under the length prior."

### 16. "Never polynomially close to 0 or to 1". unclear [section]

**Where.** Lines 409 to 411.

**Problem.** The phrase can be read either way round, and it does not say polynomial in what. What part (d) gives: the share of each answer, and so of the world's own, lies between `1/(32(k+s_0)^2+2)` and one minus that, with `s_0 <= s_D + log2 N_{s_D} + 2`. The bound depends on the data only through `ℓ_D`.

**Corrected text.** "It is two-sided: at a use marked by a bit that never varied, the share of the world's own answer stays at least `1/(32(k+s_0)^2+2)` away from 0 and from 1 under the length prior, a distance that is polynomial in `k` and in the size of the smallest fitting circuit."

### 17. "Hold unchanged" is too strong for the contrarian statement. overclaim [summary]

**Where.** `paper/main.tex` 109 to 110; `paper/sec1-intro.tex` 143 to 144; `paper/sec8-answers.tex` 132 to 133; `README.md` 44; the heading in line 145 of the section. The statement of `thm:c-transfer`(e), lines 179 to 182, is correct.

**Problem.** In the program toy the contrarian world leaves a length-`L` predictor without a hypothesis after at most `L+1` rounds. In the circuit toy the last clause of `thm:c-transfer`(e) needs a mixture with `s_max<∞` and a horizon with `2^k - n > log2(1/q_min) >= log2 N_{s_max}`. Under the length prior, the prior of the main floors of the section, every function of `k` bits has positive mass, so the posterior is never empty and only the halving `ξ(x_{1:n+j}) <= 2^-j ξ(x_{1:n})` remains. The budget is likewise a statement relative to a horizon of `2^k` cuts: the count `m log2(1/ξ(z))` says something only while it is below `2^k`. Calibration changes too, in the other direction (no worlds that stall).

**Corrected text.** In the summaries: "Calibration, the budget and the one-round feedback results carry over; the contrarian world empties the posterior only for a prior with a finite size bound and a horizon longer than `log2(1/q_min)`." One sentence to the same effect after `thm:c-transfer`.

### 18. Small points in statements. minor [section]

* **`thm:c-transfer`(c), lines 165 to 168.** The data `D_0` before the first query are not named (the bound holds for any `D_0` that `f*` fits, since `prod a_t = ξ(D_n)/ξ(D_0) >= μ(f*)`). "Repetitions allowed" uses `π(·|u,D)` at a `u` in the data, where line 50 defines it for `u∉I` only; there `a_t=1`. Say both.
* **`thm:c-transfer`(b) and line 199.** "No world prints fewer than `m` further bits" holds for first hits of length at most `2^k-m`, as the theorem says; a world whose first hit is longer is left out of the event, so one qualification remains at the end of the horizon.
* **`thm:c-readings`(a), line 75.** It uses `G_{r,s}` with `r>=1`, where `def:c-circuit` fixes `k>=2`. The proof does not need `r>=2`; say that the definition is used with `r` in place of `k`.

---

## What I verified, and how

**Definitions and setup (lines 12 to 143).**

* `N_s`, `p_i`, the core, the core weight: read against their uses. The length prior sums to 1 and satisfies (A1) with `ϱ(σ,a)=2^-a`.
* The sequence form. `ξ(xy)/ξ(x)` is the predictor's distribution because every circuit has a truth table of exactly `2^k` bits. At a cut `n=2^j` the bits `b_j,...,b_{k-1}` are 0 on the context, and positions `n+i` and `i` differ only in `b_j`: checked.
* Under a test `C(x)=ξ(x)` at a first hit, so `κ=1`: a circuit that prints a first hit has that hit as the first hit among the prefixes of its truth table.

**`thm:c-readings`.** (a) derived: conditionally on everything earlier the value of gate `i` is one entry of an independent uniform truth table. Enumerated for `(r,s,N)=(1,2,2),(2,2,2),(1,3,2)`: the output is uniform for each input value. (b) is a mixture of Bernoulli sequences; derived. The source's further claim (`π_m>=W^-m`) was dropped, which is fine.

**`thm:c-transfer`.** (a) to (e) derived. (c): the two counts with the factor `m`, and the count for queries revealed whole, re-derived; checked numerically for all truth tables in the support at `k=3`, `s<=4`, `m<=3` (largest ratio of sum to bound 0.82). (e): each clause checked against `thm:feedback` and `thm:contrarian`; the equality in the obedient case follows from `Z_m=ξ`; the contrarian clause needs only that the two one-bit extensions sum to `ξ(x)` and that a positive `ξ` is at least `q_min`. This part has no referee before the source's editor (the source says neither derivation treated feedback); it is correct. "Fewer than `2N_s` functions have circuits with at most `s` gates": `N_i >= 64 N_{i-1}`, so the sum is below `2N_s`.

**`thm:c-core`.** (a) derived, including that the active set of the constructed list is exactly `J`. Enumerated at the level of pointer structures for `(k,s)` = (2,1) to (2,5), (3,1) to (3,4), (4,3), (4,4): every core of size `a` has exactly `N_s β_s(a)` lists. (b) derived (the complement of an `(a-1)`-set has `s-a` elements, the smallest sum is `sum_{i=a}^{s-1} p_i`; the integral comparisons; the slack condition `s>=2a+k-1`; the mixture step; the closed form). Checked in exact arithmetic for `2<=k<=8`, `2<=s<=24`, all `a` (1932 cases, no violation). Worked numbers: lower bounds 8.25 and 11.25 bits, computed prices 13.00 and 14.12 bits under the length prior at `k=20`: reproduced (13.001, 14.123).

**`lem:c-trigger`.** (a) the recursion `G_i` checked; the count `2^(g+1)-1`; exactness: the source's lower bound checked (dependence on each of the digits `b_j,...,b_{k-1}`, and a circuit that depends on `q` inputs has at least `q-1` gates), and the least circuit sizes computed for all `n` at `k=3` and `k=4` (they equal `k-1-z(n)`, with one gate where the test is an input wire). (b) checked. (c) `M(j)<=2M(j-1)+3`, `M(2)=1`, so `M(j)<=2^j-3`; the bound `max(1,2m-5)`; at `k=3` all 256 functions have circuits of at most 4 gates. (d) by inspection. The count of the source's Lemma 7(f) checked.

**`thm:c-floor`.** (a) the injection, the sum, the share bound with `N_{σ+a}/N_σ <= (16(k+σ_0+a-1)^2)^a`. (b) the tail `2^-s_0`. (c) the restriction to calling circuits. (d) both families of appended gates, the weights `q(Γ)p_{s+1}`, the inequality `π(ȳ) >= η(1/2-π(ȳ))`, the sequence form. Exact counts at `k=3`, three targets, `s<=4`: the number of fitting circuits of size `s+1` with the other answer is at least twice the number of size `s` with the given answer, and likewise for the constant answers on `{v=1}`. Worked numbers: `s_0 = 22 326`, bound `2^-33.9`: reproduced. Bit prices: see finding 3.

**`thm:c-minimum`.** (a) to (d) derived, with every case of the proof of (a). Enumeration: all 6560 data sets at `k=3`; for the 1978 with `s_D=2`, all 44 016 minimum circuits satisfy (a); the exception clause for `s_D=1` holds on the 2510 data sets outside it. Part (b) is vacuous at `k=3` for `s_D>=2`, so I tested it at `k=4`: with `x_4` frozen on the eight inputs `x_4=0` (the dyadic cut `n=8`), all 1200 minimum circuits for the 114 label functions with `s_D=2` and all 18 432 for the 80 with `s_D=3` have no pointer to `x_4` and a truth table of period 8; on 1500 random data sets with one or two coordinates frozen at 0 or 1 and `s_D=2` (24 960 minimum circuits, 9987 instances of the consequence) no violation. (e), from the source: the proof read line by line (the pointer count `2a>=k+a-1`, the read-once formula, the free entry at each gate, the meeting gate); confirmed by counting for `k=2,3,4`: `s_D=k-1`, exactly half of the 4, 96, 4608 minimum circuits answer 1 at every input with two 0s.

**`thm:c-ceiling`.** The six mux types and two orders; (a), (b), (c) derived, including `C(a'+g,g) prod_{j=a'}^{a'+g} 1/j = 1/(g! a')` and the sum over `a'`. Enumeration of all reduced circuits of at most 3 gates at `k=3` (144, 16 128, 2 985 984) for five data sets: every honest restriction is a fitting core of size `a-g-1`; the largest number of separably triggered cores with one honest restriction equals the bound in (b) (12, 12, 816 for one frozen input; 24, 24, 1248 for two); the shares under `μ_1, μ_2, μ_3` are below the bound in (c). Worked numbers: `2^-14.6` reproduced; the sums are wrong (finding 1); 16 of 48 and 28.5 per cent reproduced (finding 13).

**`prop:c-gadget`.** Statement identical to the source's Proposition 13. Proof checked: the count of position sets, the weight of a realisation, `ϱ<=1` from (A1), the count `prod_{j<=a} 16(k+j)^2` of self-contained gadgets, the two inequalities under `k+σ>=4(k+A)^2`, `e^(1/2)-1<0.65`, and the step to posterior shares (a union bound; the wrappers need not fit). The term-by-term inequality checked exactly on a grid (`2<=k<=11`, `A<=11`, three values of `σ`). Thresholds 1744 and 15 856 reproduced; see finding 2.

**Transcription.** Statement by statement the paper agrees with the source (Theorems 1 to 6, Lemma 7, Theorems 8 to 12, Proposition 13). Dropped without loss: the last claim of Theorem 1(b), Theorem 3(c) and the second half of 3(d), Lemma 7(c), Theorem 8(c), the last clause of Theorem 11(a). Nothing was strengthened. The source names its editor's additions in the "Source:" line under each result and not in its Section 5. In this half they are Theorem 4 (feedback), which is correct, and the figures marked "recomputed"; of these the price of a gate, `s_0` and `2^-33.9`, and `2^-14.6` are right, and the sums over triggers are not (finding 1).

**Not checked.** The citations (Frandsen and Miltersen; Janson as stated in Burghart), beyond the simulation in finding 6. The second half of the section. The tables, except the rows that this half quotes (`x_1∧x_2`, `x_1⊕x_2`, `x_1` at `k=3`, `s<=3`, which I reproduced).
