# Referee report, round 6: the circuit computation

Scope: `code/circuit_count.py`, `code/test_circuit_count.py`, `experiments/run_circuits.py`, `experiments/make_circuit_table.py`, `experiments/results/circuits.json`, `paper/table-circuits-query.tex`, `paper/table-circuits-seq.tex`; the model and numbers in `research/circuits-final.md` (Sections 1.1 to 1.3, Computation 22); the subsection "Small cases, computed" of `paper/sec7-circuits.tex`, and the places where the paper or README quote these numbers. Lens: correctness of the computation. AI referee; not reviewed by a human.

## Verdict

The computation is correct. All exact entries of `circuits.json` that exhaustive enumeration can reach agree with my own enumeration to the last integer. This covers every entry at k=3 with s≤4 and at k=4 with s≤4, which is every entry of both tables except the s=5 column of the query table. My Monte Carlo estimate agrees with every s=5 entry within 2 standard errors. The definitions in the code (which inputs are data, which is the query, the index reading, what is counted) match the research file and the paper's captions. The test passes, and rerunning the scripts in a copy reproduces `circuits.json` and both tables byte for byte. I also recomputed three numbers that the paper quotes from outside `circuits.json`, and they are correct. The errors are in the prose that summarises the tables:
* the lower end "2 per cent" is wrong (the smallest case is 1.89 per cent);
* the upper end "32 per cent" is attained only at the least size, yet the abstract, Section 8 and the README attach it to "gates to spare";
* "0 at the least size" omits the case of a world that depends on the bit;
* "with slack it grows for the targets that depend on two or more inputs" is false for two of the rows;
* one rounding error in the research file;
* a few reproducibility and caption gaps.

## Findings

**1. (error) `paper/sec7-circuits.tex`, subsection "Small cases, computed", second paragraph after the tables (lines 936 to 939): "It is between 2 and 32 per cent in every case computed with slack, or in the exception, when the world ignores the bit".** The smallest such case is the world b0∧b1 at the cut n=4, s=2. It has 16 of 848 fitting circuits off the truth, which is 1/53 = 0.018868 (shown as 0.019 in `table-circuits-seq.tex`). That is below 2 per cent. The next smallest are b0∧b1, n=8, s=2: 2/97 = 0.0206, and (b0∧b1)⊕b2, n=8, s=3: 4/115 = 0.0348. The same sentence is in `research/circuits-final.md`, Computation 22, last paragraph. *Correction:* "between 1.9 and 32 per cent".

**2. (overclaim) `paper/main.tex` abstract (lines 124 and 125), `paper/sec8-answers.tex` (lines 150 and 151) and `README.md` (line 47): "off the world's answer by about 2 to 32 per cent when the predictor has gates to spare and the world ignores the bit, and by 81 to 100 per cent when the world depends on it".** The value 0.32 is the constant world at n=8 and s=1 (16 of 50 fitting circuits). Here s=1 is the least size of a fitting circuit (`size_of_context` = 1 in `circuits.json`), so the predictor has no gates to spare. With at least one spare gate (s_D < s ≤ s_D+4) and a world that ignores the bit, the computed range is 0.0189 (b0∧b1, n=4, s=2) to 0.2894 (constant 0, n=8, s=2: 766/2647). For a world that depends on the bit and has spare gates, the range is 0.8104 ((x1∧x2)⊕v, s=5: 38821427/47904755) to 0.9794 ((b0∧b1)⊕b3, n=8, s=2: 95/97). The value 1 occurs only at the least size. This is the "summary drops an assumption" pattern: the 32 per cent belongs to the exception of `thm:c-minimum` at the least size, not to "gates to spare". *Correction:* either "about 2 to 29 per cent when the predictor has gates to spare and the world ignores the bit, and 81 to 98 per cent when the world depends on it", or drop "when the predictor has gates to spare" and write "in the small cases computed (up to four gates more than the least size)" with the ranges "about 2 to 32" and "81 to 100".

**3. (error) `paper/sec7-circuits.tex`, same paragraph, first sentence: "The deviation at a query that differs from the data in a never-varied bit is 0 at the least size outside the exception of thm:c-minimum".** Two rows contradict this. For (x1∧x2)⊕v (query table, s=s_D=1) the deviation is 1 (2 of 2 fitting circuits). For (b0∧b1)⊕b3 at n=8 and s=1, which is the least size, it is also 1 (2 of 2). Neither is in the exception: the labels x1∧x2 and (b0∧b1) on the cut are neither constant nor an input. `thm:c-minimum`(b) itself says the deviation is 0 or 1 according to the world's own answer. The same omission is in `research/circuits-final.md`, Computation 22, last paragraph. *Correction:* "At the least size and outside the exception of thm:c-minimum, the deviation is 0 when the world ignores the bit and 1 when it depends on it."

**4. (error) `paper/sec7-circuits.tex`, same paragraph: "With slack it grows for the targets that depend on two or more inputs and falls for the one-input target and for the constant."** For the two worlds that depend on the bit, the deviation falls with slack, although their targets depend on two or more inputs:
* (x1∧x2)⊕v: 1, 0.9091, 0.8609, 0.8309, 0.8104 for s=1 to 5;
* (b0∧b1)⊕b3, n=8: 1, 0.9794, 0.9645, 0.9534 for s=1 to 4.

For the worlds that ignore the bit the statement is right, and monotone in every computed case:
* growing: x1∧x2, x1⊕x2, (x1∧x2)⊕x3, (b0∧b1)⊕b2, b0∧b1 at both cuts;
* falling: x1, constant 0 at both cuts.

The same sentence is in `research/circuits-final.md`. *Correction:* "When the world ignores the bit, the deviation grows with slack for the targets that depend on two or more inputs and falls for the one-input target and for the constant. When the world depends on the bit, it falls from 1."

**5. (unclear) The rows for worlds that depend on the bit are not independent evidence.** (x1∧x2)⊕v has the same data as x1∧x2 and the opposite own answer at 111. So its row in `table-circuits-query.tex` is exactly 1 minus the x1∧x2 row: 1−1/11 = 10/11, 1−466/3349 = 2883/3349, and so on, with identical fitting counts in `circuits.json`. Likewise (b0∧b1)⊕b3 at n=8 has the context 00010001 of b0∧b1 and is exactly 1 minus the b0∧b1, n=8 row (95/97 = 1−2/97, 6577/6819 = 1−242/6819, 625061/655580 = 1−30519/655580). The range "0.81 to 1" is therefore a restatement of the 0 to 0.19 deviations of the bit-ignoring twins. *Suggested wording,* after the sentence on 0.81 to 1: "(these rows are one minus the rows of the world with the same data that ignores the bit)".

**6. (error, research file) `research/circuits-final.md`, Computation 22, sequence-form table, row b0∧b1, column s=3: "0.033; 0.036".** The value at n=8 is 15488/436416 = 242/6819 = 0.035489, which rounds to 0.035 (`circuits.json`; `paper/table-circuits-seq.tex` correctly shows 0.035). *Correction:* "0.033; 0.035".

**7. (gap) `paper/sec7-circuits.tex`, `thm:c-capture`(d) (lines 763 to 768), and the "16 of the 48 … 28.5 per cent" sentence (lines 560 to 562).** These numbers are computed, but no committed script produces them and they are not in `circuits.json`. The paper says of the second that it was "computed by a referee of the source", and `research/circuits-final.md` says "not recomputed here". I recomputed all of them, and all are correct:
* World b0∧b1, k=4, context 000, true next bit 1:
  * μ1: 2 of 76 fitting circuits = 1/38 = 0.02632;
  * μ2: 848/31264 = 53/1954 = 0.02712;
  * μ3: 507200/18378496 = 7925/287164 = 0.02760;
  * μ4: 408380928/14637099008 = 797619/28588084 = 0.02790.
  The paper's "0.027 to 0.028" is right.
* AND family, k=4, s=3: 4608 fitting circuits, and a quarter answer 1 at each input with three 0s (in `circuits.json`).
* Separably triggered cores (definition of Theorem 12 of the research file, Λ = all triggers), target x1∧x2, k=3, query 111:
  * s=2: 16 of 48 deviating circuits;
  * s=3: 8512 of 29824 = 0.2854.

*Correction:* add the capture (d) quantities and the separably triggered counts to `run_circuits.py`, so that they appear in `circuits.json`, and cite that file at both places.

**8. (unclear) `thm:c-capture`(d), line 767: "for a world computed by one of them the share of its own answer there is 1/4 under μ3".** This holds only for a world computed by one of the quarter of minimum-size fitting circuits that answer 1 at that input. For a world computed by one of the other three quarters, the share of its own answer (0) is 3/4. *Correction:* "for a world computed by one of those that answer 1 there, the share of its own answer is 1/4 under μ3".

**9. (minor) Caption of `tab:circuits-query`: "for sizes s from the least size s_D of a fitting circuit to s_D+4".** The k=4 row stops at s_D+2=4, because `run_circuits.py` counts k=4 circuits only up to s=4, and the two blank cells are not explained. *Correction:* add "(for k=4 up to s=4)".

**10. (minor) `tab:circuits-seq` has no s=1 column, although s=1 is the least size for three of its four worlds**, and the prose quotes an s=1 value (0.32) that appears in no table. The first sentence of the paragraph ("0 at the least size") cannot be checked against the sequence table either. *Correction:* add an s=1 column with the values in `circuits.json`: 1; (none fit); 0; 0; 0.270; 0.320. Alternatively, cite `circuits.json` for the value 0.32 in the prose.

**11. (minor) `paper/sec7-circuits.tex`, "One given triggered variant of x1∧x2 (the target ⊕v, ∨v, ∧¬v) has share 0.0255, 0.0310, 0.1013 at s=5".** The sentence does not say what the share is of. The values are the shares, among the size-5 circuits at k=3 that fit the data of the query table (x3 frozen at 0), of those that compute exactly that function on all eight inputs. Note also that target ∨v answers 1 at 111, the target's own answer, so it is not a deviation at the query of the table; it deviates at 001, 011 and 101. *Correction:* "Among the size-5 circuits that fit these data, the share of those that compute exactly target⊕v, target∨v, target∧¬v is 0.0255, 0.0310, 0.1013."

**12. (minor) `code/test_circuit_count.py` checks the dynamic programme against direct enumeration only for k=3, s≤3 and k=4, s≤2, while the reported values go to k=3, s=5 and k=4, s=4.** For the larger sizes the only built-in check is that the counts sum to N_s. My exhaustive enumeration (below) closes this for s=4 at k=3 and k=4, and my Monte Carlo for s=5 at k=3. The README's "checks it against direct enumeration" is literally true but covers fewer sizes than are reported. *Suggestion:* say in the test docstring or the README up to which sizes the check runs, or record this report's s=4 comparison.

## What I recomputed and how

All scripts are in the scratch directory `ref-compute/`. None of them imports the code under review. `compare.py` and `mc_compare.py` read `circuits.json` only to compare.

1. **Test and rerun.** `test_circuit_count.py` passes (4.5 s). I copied `code/`, `experiments/` and `paper/` to scratch and reran `run_circuits.py` (19.0 s, as its docstring says) and `make_circuit_table.py` there. `circuits.json`, `table-circuits-query.tex` and `table-circuits-seq.tex` came out identical to the committed files (`diff` empty).

2. **Independent exhaustive enumeration** (`ref_enum.py`, `ref_enum4.py`; numpy).
   * *Method.* Every circuit of size s is visited: all prefixes are built explicitly and the last gate is vectorised over all pointer pairs and all 16 tables. Gates use the opposite bit order of the table index (bit va+2vb rather than 2va+vb); this is a bijection on the 16 tables and so does not change the counts.
   * *Sizes covered.* k=3, s=1..4 (N_4 = 8 493 465 600 circuits); k=4, s=1..4 (N_4 = 46 242 201 600 circuits, 81 s on 4 cores). The histogram for each (k, s) sums to N_s = ∏16(k+i−1)².
   * *Recomputed* (`compare.py`), from my own definitions of data, query and index reading:
     * every fitting count, deviating count and exact share of the query form for s≤4, including s_D and the own answer;
     * the AND family for k=3, s=2..4 and k=4, s=3..4 (fitting counts, the deviation at every input with two and three 0s, checked to be equal across those inputs, and the share computing the target everywhere);
     * every row of the sequence form at s=1..4, including the truth tables;
     * the capture (d) numbers.

     All agree exactly with `circuits.json`: 0 discrepancies among about 100 integer and fraction comparisons.
   * *Definitions checked against the research file (Section 1.3) and the captions:*
     * in the query form the data are the inputs with the last input (x3 for k=3, x4 for k=4) equal to 0, and the query is all ones;
     * in the index reading, position t is input u = t−1 with b_i = (u>>i)&1, and the context of length n is u = 0..n−1;
     * the next bit is u = n;
     * what is counted is circuits (not functions) under μ_s.

3. **Monte Carlo for s=5 at k=3** (`mc.py`, `mc_compare.py`).
   * *Sampling.* 10⁹ circuits drawn uniformly from C_{3,5}: each gate has a uniform table and independent uniform pointers among the earlier wires.
   * *Standard error.* sqrt(p(1−p)/n_fit), conditional on the number n_fit of fitting samples.

   | quantity (s=5) | MC estimate ± s.e. | n_fit | `circuits.json` | z |
   |---|---|---|---|---|
   | x1∧x2 deviation | 0.18945 ± 0.00010 | 14 735 534 | 0.18961 | −1.6 |
   | x1⊕x2 deviation | 0.19608 ± 0.00012 | 10 720 550 | 0.19609 | 0.0 |
   | x1 deviation | 0.23929 ± 0.00005 | 78 381 703 | 0.23926 | +0.8 |
   | (x1∧x2)⊕v deviation | 0.81055 ± 0.00010 | 14 735 534 | 0.81039 | +1.6 |
   | triggered target⊕v | 0.02545 ± 0.00004 | 14 735 534 | 0.02552 | −1.8 |
   | triggered target∨v | 0.03103 ± 0.00005 | 14 735 534 | 0.03104 | −0.4 |
   | triggered target∧¬v | 0.10115 ± 0.00008 | 14 735 534 | 0.10126 | −1.3 |
   | AND k=3, two 0s (001/010/100) | 0.42922 / 0.42955 / 0.42906 ± 0.00022 | 4 899 676 | 0.42936 | −0.6 / +0.8 / −1.3 |
   | AND k=3, three 0s (000) | 0.26260 ± 0.00020 | 4 899 676 | 0.26285 | −1.3 |
   | AND k=3, target everywhere | 0.30487 ± 0.00021 | 4 899 676 | 0.30474 | +0.6 |

   *Checks of the Monte Carlo itself:*
   * 2·10⁷ samples at k=3, s=4 and 2·10⁸ at k=4, s=4, against the exact values. All |z| < 2, except b0∧b1, n=4, s=4 (z = −3.3).
   * A rerun of that case with 4·10⁸ new samples and other seeds gave z = −1.2. The exact value is in any case confirmed by the exhaustive enumeration, so the earlier z was a fluctuation.

4. **Separably triggered cores** (`septrig.py`, pure Python, exhaustive over all circuits of size 2 and 3 at k=3). This gives 16 of 48 and 8512 of 29 824 = 0.2854, as quoted.

5. **Rounding** of the generated tables against the exact fractions: all 23 non-blank cells of `table-circuits-query.tex` and all 18 of `table-circuits-seq.tex` are correctly rounded (4 and 3 decimals). The numbers quoted in the paper's prose (0.0255, 0.0310, 0.1013; 1/2; 0.468, 0.446, 0.429; 1/4, 1/8; 0.32; 0.81) match `circuits.json`. The only rounding error I found is the research file's 0.036 (finding 6).
