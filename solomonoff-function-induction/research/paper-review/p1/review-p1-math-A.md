# Paper 1: mathematical review A (setting, versions, learning, Appendices A–C)

Reviewer: p1-math-A. Scope: `paper/sections/setting.tex`, `versions.tex`, `learn.tex`, `app-setting.tex`, `app-versions.tex` and `app-learn.tex`, as compiled into `paper/main.pdf` (build of 12 Oct 2026, 16:59). Sources checked against: `research/tracks/foundations/notes-final.md` (with `referee.md`, `checks/`, `referee_code/`), `research/tracks/context/notes-final.md` §§1, 2.4, 5 (with checks c3, c4, c7), history notes Prop 2.4 and Prop 4.10, examples notes Prop 2.9, Hänni's notes in `research/prior/` (quotations checked verbatim against `hanni-sfi-notes.md` and `hanni-sfi-draft-2025-09.txt`) and `research/00-brief.md`.

This report merges two independent passes over the same files. Each pass read every statement and proof line by line, against the sources and on its own, and wrote its own code. Pass 1 code: `research/paper-review/scratch/p1mathA_s{1,2,3}_*.py`. Pass 2 code: `research/paper-review/scratch/p1-math-A-r2/a{1,2,3,4}_*.py`. All outputs are saved next to the scripts. The second pass confirms every issue of the first (P1A-01 to P1A-36), raises P1A-27 from minor to major, and adds P1A-37 to P1A-53. The machine-readable list is `p1/issues-p1-math-A.json`.

## 1. Verdict

The mathematics of these sections is sound and follows the foundations and context final notes closely. No theorem, proposition, lemma or corollary is false as stated, and every proof is complete except where a sketch is labelled as such. Both passes recomputed every number they could (Section 3); all agree with the paper to the printed precision. Neither pass found a step that fails.

The defects are of five kinds.

1. **One unsupported claim (P1A-01, fatal).** `rem:versions:prediction`(3) says the single shortest program "can exceed SFI's loss … by about log(k(d+2)) on k incompressible binary labels". Only the upper bound (`prop:versions:covering`) is proved; the only lower bound is log d − O(1) at k = 2. The same sentence is in the foundations notes, also unproved. Replacing "by about" with "by at most", and giving the bound, fixes it.
2. **One wrong formula in a proof (P1A-02).** The proof of `prop:learn:freshnoise`(b) sums from j = 0, where Σ_y P(y|x₀)⁰ counts labels. The statement is right; the transcription from the source is not.
3. **Summary statements that say more than is proved, or drop a hypothesis (P1A-03 to P1A-08, P1A-27, P1A-37).**
   * `rem:versions:prediction`(2) compares W with SFI where only the comparison with the fair-coin law is proved (P1A-03); (4) says the M^w-versus-M_F gap lives on "data no random function produces", which is false (P1A-04).
   * After the swap example, the history-aware lower bound needs "lower-semicomputable" and a predictor-dependent constant (P1A-05). The loss form of the invariance theorem holds only in the semimeasure convention (P1A-06). The recommendation's "agree up to K(dom D)" fails for M_pq on inconsistent sequences (P1A-07). `rem:versions:hist` drops the maximum over labels (P1A-08).
   * In Table 2, the M_prod-versus-M_F upper-bound cell cites a bound on ν_len/M_prod, not on M_F/M_prod (P1A-27); and the caption's "no computable family exhibits a gap larger than K(k)+O(1) in any row" is false for the table's own last row (P1A-37).
4. **arXiv-standard violations a reader would notice (P1A-09 to P1A-15, P1A-38).** Track and script names in running text ("foundations r6", "(context c3)", "Source: foundations Table 4.12", a "Computations" paragraph listing referee scripts); an internal-correction remark (`rem:learn:cesaro`); "hypothesis H7"; printed hedges ("search snippet only", "not checked against the source"); and conversational references to "Hänni's request", including a citation of a personal communication from the sole author to himself whose bibliography entry points to the internal brief (P1A-38). The conversion pass that strips `\status`/`\src` will not catch these.
5. **Minor issues (35).** Quantifiers, undefined or overloaded notation, statements that use objects defined only in proofs, cross-references to open questions that print section numbers, and register.

**Counts:** 1 fatal, 17 major, 35 minor (53 issues).

## 2. What was checked, item by item

"Verified" means I re-derived the statement and its proof from the definitions and found it correct, and that it matches the source item cited in its `\src`. "+ code" means I also computed it independently (Section 3).

**Section 2 and Appendix A (setting).**

| item | result |
|---|---|
| `def:setting:data`, two loss conventions | verified; matches F §1 (repeated-input convention) (P1A-49: effective presentation of Y) |
| `def:setting:weak` and its two consequences | verified (P1A-24: consequences unnumbered) |
| `prop:setting:predictor` (a), (b) | verified |
| `prop:setting:normtotal` | verified (Kolmogorov extension on Y^A, Y countable) |
| `prop:setting:mobius` (absolute convergence, inclusion–exclusion, consistency identity q_{S∪{x}}(v,⊥) = q_S(v) − Σ_a q_{S∪{x}}(v,a), uniqueness) | verified + code (1920 identities on random laws) |
| `ex:setting:weaknotrpf` (a) ∇ = −1; (b) ν_tri weak (27 inequalities), E_i pairwise inconsistent of mass 3/2, P_1 ≥ (2/3)ν_tri | verified + code; an LP over all 27-outcome laws gives the optimum c* = 2/3 exactly |
| `def:setting:machine`, `prop:setting:machinelaw`, enumeration (T_i) | verified |
| `thm:setting:universal` (consistency of T_U, mixture formula, M_F(∅) = 1) | verified |
| `prop:setting:includes` (a) private streams; (b); (c) nested partitions, endpoint formula for J(v⊥), finite-Y and total cases; (d) | verified (P1A-23: j and ⟨·,·⟩ undefined there) |
| `rem:setting:perinput`, `lem:setting:total`, `cor:setting:normuniversal` | verified (P1A-22: hypothesis wording) |
| `rem:setting:fillin` and proof | verified |
| `lem:setting:realise` (leaf-up ψ′_t, monotonicity in t, room argument, sibling disjointness) | verified |
| `thm:setting:weakuniversal` (trimming, freezing, monotone limit, ν_i = φ_i for weak φ_i) | verified |
| `thm:setting:weakvsmachine` (i)–(v) | verified + code (ν_tri^{⊗2} weak, 1458 inequalities; min ratio of P_1^{⊗2} is 4/9) (P1A-19: statement uses objects defined only in the proof) |
| `rem:setting:h1a`, `q:setting:rpf`, Appendix A.6 sketch (Strassen step) | consistent with F Problem 3.6 and correctly labelled a sketch (P1A-26: main-text condition too short; P1A-32: unattributed quotation in `rem:setting:h1a`) |
| `def:setting:sfi` | verified (P1A-20: "E consistent with D") |
| `prop:setting:order` | verified + code (one value over 24 orders) |
| `prop:setting:normalise` (a)–(c) and its example (2/3, 1/2, 1/4) | verified + code (P1A-46: notation of (b), (c)) |
| `prop:setting:twopoint` (i)–(iii) and the law of (iii) | verified + code ((⋆) agrees with order independence on 300 of 300 random positive laws; product laws satisfy both; (iii) law: criterion false, order-free true) (P1A-52: how the evidence is reported) |
| `prop:setting:transfer` (a)–(c) | verified (Z_1 ≥ 2^{-c}; the normalised product is a probability on Y^n for a fixed input list; relativised coding; Gibbs) |
| `rem:setting:conventions` | matches CLAIMS C7, history Prop 2.4 and examples Prop 2.9 (P1A-28: wording, "in expectation"; P1A-47: the swap entry partly transfers) |
| `rem:setting:recommend` | P1A-07 |
| `thm:setting:invariance` (a)–(c), including the M^w transformation | verified (P1A-06: convention; P1A-29: wording) |
| `thm:setting:coding` (a)–(c) | verified |
| `ex:setting:swap` | verified + code (XOR machine has probability exactly 2^{-d}, d ≤ 5) (P1A-05: the paragraph after it) |
| `prop:setting:si` | verified |
| `prop:setting:computability` (a)–(d), diagonal argument with threshold 0.6 | verified |

**Section 3 and Appendix B (versions).**

| item | result |
|---|---|
| `def:versions:variants`, `rem:versions:Wdelim` (K^P sandwich) | verified (P1A-21: "not a mixture of fixed functions") |
| `rem:versions:operator`, `rem:versions:randomness` | consistent with F and CLAIMS C1 (P1A-15: printed hedges) |
| `thm:versions:chain`, steps (1)–(5) | verified (P1A-41: notation in step (2)) |
| `prop:versions:Wgap` (a) colouring and (b) counting, with the two lower bounds | verified |
| `rem:versions:Wrate` and its proof (ℓ_d; log(1/Ω^{≥ℓ}) ≤ K^pad(ℓ)+O(1); padding function g) | verified + code (ℓ_d is the largest ℓ with 3^{2^ℓ} < 2^d for every d ≤ 4000, by exact integer test; g(2^{d+1}) = h(d)) (P1A-16, P1A-17: main-text sentence) |
| `prop:versions:tape` (a)–(c) | verified + code (j(x) a bijection onto [0, 2^{d+1}−2]; lookup machine gives 2^{-|D|} for every binary D on {0,1}^{≤2}) |
| `rem:versions:hashing` and proof (Vandermonde over GF(2^q), injective 1x encoding) | verified + code (114 point sets for q ∈ {2,3}, k ≤ 3, all uniform) |
| `prop:versions:shared` (compactness, subsequence, injectivity of b ↦ T_b, ∏(1+ε′2^{-j}) − 1 ≤ 2ε′, contradiction 4ε ≤ 3ε) | verified + code (identities) (P1A-35: ϱ when I_0 = ∅) |
| `rem:versions:sharedsize` | verified (P1A-36: ν_len index shift across papers) |
| `thm:versions:nocoding` (i)–(iii) and the corollary sentence | verified + code (g > log d − 2 for every d ≤ 4000) (P1A-34: asymptotic clause) |
| `cor:versions:twopoint` | verified |
| `prop:versions:covering` and proof (padding d′, count bound, N_cov, union bound, self-delimitation) | verified + code (all inequalities for d ≤ 2000, k ≤ 40; exact minimum covering families for tiny cases are 2, 2 and 4, below N_cov) |
| `rem:versions:noncomputable`, `q:versions:explicit` | verified |
| `q:versions:open` | consistent with F Problem 4.6(b) (P1A-39: the L_{1/2} sentence) |
| Table `tab:versions:compare` | every row matches F Table 4.12 and the proofs (P1A-27: row M_prod vs M_F; P1A-37 and P1A-11: caption; P1A-38: caption register) |
| `rem:versions:prediction` (1)–(7) | (1), (6), (7) verified; (2) P1A-03; (3) P1A-01; (4) P1A-04; (5) P1A-18 |
| `rem:versions:answer` | verified (P1A-38: title and register) |
| `prop:versions:structured` | verified (matches Co Prop 5.4(3),(4)) |
| `rem:versions:hist` | P1A-08 |
| Kleitman–Spencer two-point family | code: it 2-covers C(N−1, ⌊N/2⌋−1) inputs for N = 3..12 |

**Section 4 and Appendix C (learn).**

| item | result |
|---|---|
| `thm:learn:dominance` (a)–(c) | verified |
| `rem:learn:h2` | verified |
| `thm:learn:merging` (posterior lemma, integrability bound Σ p max(0, log q/p) ≤ log e, telescoping, Pinsker in bits) | verified + code (exact identity Σ E d_t = E log(ν/M) on a finite mixture, for an i.i.d. rule and an adaptive past-only rule, n ≤ 3; Pinsker and integrability on 20000 random pairs, largest value 0.503) |
| `cor:learn:mistakes` | verified (P1A-45: existence of the maximiser) |
| `thm:learn:batch` (a) convexity and Markov; (b) stamps, stamp-ignoring comparator, integrability, KL convexity, 0–1 excess via ‖·‖₁ and Pinsker; (c) | verified |
| `prop:learn:freshnoise` (a)–(c) | statements verified + code (P(consistent) = 0.95, 0.112864, 0.000498 at n = 2, 10, 20; bound (b) holds in all tested cases) (P1A-02: proof formula; P1A-14: wording) |
| `prop:learn:perquery` (a)–(d) | verified (positive conditional probability 2^{-2|y|-1} sums to 1) |
| `prop:learn:curve` | verified + code (closed forms agree with brute-force enumeration for t ≤ 6 and w ∈ {1/16, 1/5, 1/4}; (1+w)^3 − 8w = 0.128 at 1/5 and decreasing on [0, 1/5]; the crossing is at w ≈ 0.2361; r_0 + 2r_1 = log(1/w)) |
| `rem:learn:lastiterate` (identity) | verified |
| error definitions and e^wr ≤ e_norm ≤ e | verified + code (P1A-44: case x* ∈ A) |
| `prop:learn:splits`, `prop:learn:loo`, `conj:learn:loo` | verified + code (finite mixture over all 243 partial functions on 5 points: splits identity exact to 10^{-10}; LOO bound on all 31 subsets) (P1A-51: convention; P1A-43: misattached reference) |
| `prop:learn:typical` (1)–(3) and the separation step (machine and program constructions) | verified + code (the constant chain holds for every n ≤ 5000 and n = 10^4..10^{12}) |
| `cor:learn:perstep` (a), (b) | verified + code (exact E e(x*) ≤ the exchangeability bound and ≤ the Markov bound for n ≤ 4 under a non-uniform μ; ε choice gives exactly 1/n) |
| `prop:learn:occam` | verified (K_F(D_n) ≤ K(φ) holds exactly) |
| `rem:learn:ideal`, `rem:learn:hutterEX` | P1A-30 (computability of P); P1A-50 (prior class); P1A-15 (hedges) |
| `prop:learn:active` (1), (2) | verified + code (mean of min(pos, N−1) ≥ (N−1)/2) |
| `rem:learn:increasing` (1 bit, 0.255, LOO error 1/2, sum 8 against bound 16) | verified + code |
| `rem:learn:cesaro` (mathematics) | verified (P1A-13: form) |
| `rem:learn:relations`, comparison paragraph, `rem:learn:positive`, `rem:learn:interventions` | consistent with Co Rem 2.18, F §6.6, Co Rem 5.5 and 5.6 |
| Numbers quoted from track checks (c5, c11, r6, r12; context c3, c4, c7) | all match the saved outputs (12.5 against 1; 63/300; 0.8731; 1.55·10^{-15}; 0.5084; seeds 20261011, 20261012, 2, 3, 7) |

**Fidelity to the sources.** Apart from P1A-01 (which repeats an unsupported sentence of the foundations notes) and P1A-02 (a transcription error), no statement in these sections is stronger than its source. Two statements are slightly stronger than the source but proved in the paper: `prop:learn:perquery`(a) "positive on inconsistent sequences", where the source says "possible", and `cor:setting:normuniversal` for countable Y, which extends context Cor 5.2(c) via F Lemma 6.5a, as CLAIMS C3 records. The places where hypotheses were dropped in transcription are P1A-05 (from F Ex 6.4) and P1A-07 (from F §5 "on data sets").

## 3. Independent computations

### 3.1 First pass

All scripts are deterministic (fixed seeds) and use exact rationals where possible. Run with `python3 -I`.

* `scratch/p1mathA_s1_semimeasures.py` → `.out.txt`: two-input example; ν_tri weakness, inconsistency and mass; LP optimum 2/3 over all laws; ν_tri^{⊗2} (1458 inequalities, ratio 4/9); Möbius identities on random laws (1920, no failures); the `prop:setting:normalise`(b) and `prop:setting:twopoint`(iii) examples; (⋆) against order independence on 300 random positive laws (agreement in all) and 100 product laws; order independence of the semimeasure loss on a random 4-input law (one value over 24 orders; normalised values 0.0666–0.1150); the swap XOR machine.
* `scratch/p1mathA_s2_versions.py` → `.out.txt`: ℓ_d by exact integer comparison; covering arithmetic; exact minimum covering families; Kleitman–Spencer family for N ≤ 12; GF(2^q) hashing uniformity; the lookup machine; the shared-coin counting identities; the padding function of `rem:versions:Wrate`.
* `scratch/p1mathA_s3_learn.py` → `.out.txt`: fresh-noise probabilities and bound (b), with the printed j ≥ 0 formula shown to exceed 1; learning-curve closed forms against brute force; `rem:learn:increasing` numbers; the active-learning bound; the constants of `prop:learn:typical` and `cor:learn:perstep`; a finite partial-function mixture (splits identity, LOO bound, e^wr ≤ e_norm ≤ e, the exchangeability and Markov bounds); the merging identity under i.i.d. and adaptive rules; Pinsker for sub-probabilities and the integrability inequality.

### 3.2 Second pass

All scripts are deterministic (seed 20261012), use exact rationals where cheap, and were run with `python3 -I`. Outputs are in `*.out.txt` next to each script in `research/paper-review/scratch/p1-math-A-r2/`.

* `a1_semimeasures.py`: `ex:setting:weaknotrpf` (a) weak, ∇ = −1; (b) ν_tri weak (27 inequalities), P₁ ≥ (2/3)ν_tri on all 10 support points; an LP over **all** laws of random partial functions gives the best domination constant 0.666666666667 for k = 1 and 0.444444444444 for k = 2 (100 support data sets, 729 outcomes), i.e. exactly (2/3)^k as `thm:setting:weakvsmachine`(v) says; Möbius identities on 30 random laws (1920 identities, 0 failures); the `prop:setting:normalise`(b) law (2/3 against 1/2, (⋆) false) and the (iii) law ((⋆) false, order-independent); (⋆) against order independence on 300 random laws with positive cells (agreement 300/300, (⋆) true in 0) and on 200 laws with label-independent definedness (both hold in 200/200; this is the positive direction that P1A-52 asks the paper to report); `prop:setting:transfer`(a),(b) on 3240 input lists with repeats (normalised products sum to exactly 1; |L̄ − (L − Σ log 1/Z_t)| ≤ 8.9·10⁻¹⁶); the swap XOR machine (probability exactly 2^{−d}, d ≤ 5).
* `a2_versions.py`: ℓ_d = ⌈log(d/log 3)⌉ − 1 is the largest ℓ with 3^{2^ℓ} < 2^d (floating check for d ≤ 2·10⁵, exact integer check for d < 2000) and g ≥ log d − 2; the arithmetic of `thm:versions:nocoding`'s last clause; every inequality in the proof of `prop:versions:covering` (padding, count, union bound, log N_cov) for d < 3000 and k ∈ {1,2,3,5,10,40}; exact minimum covering families by brute force (2, 2, 4, 2 for (d,k) = (0,1), (1,1), (1,2), (2,1), all below N_cov); the Kleitman–Spencer family for N ≤ 12 and "at most d + 6 functions for d ≤ 40" (maximum excess exactly 6); k-wise uniformity of lowest-bit polynomial hashing over GF(2³), GF(2⁴) for k ≤ 3 (960 point sets, all uniform); the counting step of `prop:versions:shared`; max j(x) = 2^{d+1} − 2.
* `a3_learning.py`: `prop:learn:curve` closed forms against brute force (w ∈ {1/2, 1/4, 1/5, 1/16, 1/100}; r₀ = 0.9125, r₁ = 1.5437 at w = 1/16; crossing of (1+w)³ = 8w at √5 − 2 ≈ 0.2361; r₀ + 2r₁ = log(1/w)); fresh-noise consistency probabilities 0.950000, 0.112864, 0.000498 at n = 2, 10, 20 (exact dynamic programme) and the bound of (b) on a grid; `rem:learn:increasing` (last step 1 bit, split mean 0.2555, LOO sum 8 against bound 16); `prop:learn:loo` and the `prop:learn:splits` identity on 200 random mixtures of partial and shared-tape hypotheses (0 violations); `cor:learn:perstep` (a) and (b) exactly for n ≤ 4 (0 violations); a finite analogue of `thm:learn:merging` with 7 laws and 200 random past-only adaptive rules each (largest Σ E d_t / (−log w) = 0.61 ≤ 1); a finite analogue of `thm:learn:batch`(a) (0 violations of either bound); `prop:learn:perquery`(a) on a 6-law class (0 violations of the chronological inequality or multiset invariance, M_pq ≤ M_prod on consistent sequences, strict at repeats in 32 cases, M_pq > 0 on all 40 inconsistent sequences); the constants of `prop:learn:typical` for n ≤ 2·10⁵; the active-learning mean; Pinsker for sub-probabilities (20 000 random pairs).
* `a4_realise.py`: the sequential realisation in the proof of `thm:setting:weakvsmachine`(ii) on 300 random weak semimeasures over three inputs: equality on domain S in every case, "≤" on every nonempty proper subset (strict in 2667 cases); and the computable family behind P1A-37.
* `merge_issues.py` builds `p1/issues-p1-math-A.json` and Section 6 of this report from one source.

The second pass also re-derived by hand every proof in the six files (the list in Section 2 applies to both passes). Points it found that the first pass did not are P1A-37 to P1A-53. The most consequential are P1A-37 (a false caption sentence in the main summary table) and P1A-38 (conversational and self-referential citation of "Hänni's request", which the binding note forbids).

## 4. Remarks that are not issues

* The `\status` and `\src` tags are accurate wherever their values are standard, so the conversion pass can rely on them. The exceptions are listed in P1A-09.
* `prop:versions:shared` uses ν_len := law of ω_{|x|+1}. This is a deliberate and correct change from the source's ω_{|x|}, which would leave ω_0 undefined at x = ε. With it, the bound K^pad(d+1) of `rem:versions:sharedsize` is exactly right. Only the cross-paper alignment needs fixing (P1A-36).
* `rem:setting:fillin`, `q:setting:rpf` and Appendix A.6 present the open problem honestly. The Strassen step is labelled as quoted and the reduction step as not carried out.
* The 0.84 pt overfull box in Table 2 (`main.log` l.693) is invisible.

## 5. Notes on the second pass's additions

* **P1A-39.** The open question says L_{1/2} is not computably bounded. For the default Y = {0,1}^* this has a one-line proof (a certificate determines the label, so L_{1/2} ≥ K(y|x) − O(log K(y|x)) on one-point data), which the paper should give; for finite Y it is unproved.
* **P1A-47.** `rem:setting:conventions` lists the swap example as semimeasure-only. Part of it transfers: the first revealed pair is a single point, so `prop:setting:transfer`(a) gives min{K(x₂|x₁), K(x₁|x₂)} − O(1) in every order, which is d − O(log d) for pairs with K(x₁), K(x₂|x₁) ≥ d.
* **Checked and not an issue.** The quotations of Hänni's notes in these sections ("you have a bunch of input-output pairs …", "use different bits of randomness …", "input-output pairs from a function", "Thm 1 (template)" with "at most a constant (depending on P but not the distribution)", the headings of §§2.1–2.2 of the draft, "need coding theorem") match `research/prior/` verbatim. The numbers quoted from the track checks (12.5 against 1 for r6; 63/300 and 0.8731 for r12; 0.95, 0.113, 5·10⁻⁴ for c5; 10.919980315195, 7.33 and 10.64 for context c3; d + 6 for d ≤ 40; 400/400 and 16 200 for c10) match the saved outputs. The full build has no undefined references or citations.

## 6. Numbered issue list (most severe first)

**P1A-01** [fatal] `paper/sections/versions.tex`, rem:versions:prediction item (3), line 130; also line 96 (sentence after prop:versions:covering)

* *Problem.* Item (3) says the single shortest program 'can exceed SFI's loss by log d - O(1) bits on two points and by about log(k(d+2)) on k incompressible binary labels'. The second clause asserts that k-point data sets with a gap of order log(k(d+2)) exist. Nothing in the paper proves a lower bound on K_F(D) - L_SFI(D) for k > 2 points: prop:versions:covering is an upper bound only, and the only lower bound (thm:versions:nocoding, cor:versions:twopoint) is log d - O(1) for k = 2. Line 96 has the same problem in milder form: right after the covering upper bound it says 'So a logarithmic cost is real for the single shortest program', which reads as if the covering argument showed the cost is real.
* *Evidence.* prop:versions:covering (versions.tex l.88-94, proof app-versions.tex l.98-100) proves only K_F(D) <= k + log(k(d+2)) + K(ceil(log(d+2)),k) + O(1). The foundations final notes (Section 4, 'What the differences mean for prediction') contain the same sentence, also without proof; their Thm 4.7 and Cor 4.8 are two-point results. A lower bound of order log(kd) would need a lower bound on the size of k-universal families (Kleitman-Spencer type). The paper does not prove or use one. app-versions.tex l.102 cites Kleitman-Spencer only for an explicit two-point construction and says 'Nothing above depends on optimality'.
* *Fix.* Replace the clause with: 'and, on k binary labels with randomness deficiency delta_D, by at most delta_D + log(k(d+2)) + K(ceil(log(d+2)),k) + O(1) (prop:versions:covering); whether gaps of order log k occur is open.' In line 96 write: 'A logarithmic cost in d is real for the single shortest program already on two points (thm:versions:nocoding); the covering argument shows that it is at most logarithmic in k(d+2).' Optionally add the k-point lower bound to q:versions:open.

**P1A-02** [major] `paper/sections/app-learn.tex`, proof of prop:learn:freshnoise, part (b), line 40

* *Problem.* The displayed probability that the labels at x_0 agree, sum_{j>=0} C(n,j) alpha^j (1-alpha)^{n-j} sum_y P(y|x_0)^j, is wrong at j = 0. There sum_y P(y|x_0)^0 counts the labels (|supp P(.|x_0)|, or |Y| read literally), so the expression exceeds 1, and it is infinite for infinite Y. The j = 0 term must be (1-alpha)^n: x_0 is never drawn, so agreement is certain. The bound in the next sentence is correct only for the corrected sum.
* *Evidence.* scratch/p1mathA_s3_learn.py, check (1): for alpha=0.3, P(.|x_0)=(1/2,1/2), n=2 the correct agreement probability is 0.9550, while the printed formula gives 1.4450. The source proof (foundations notes, Prop 6.8) reads '(1-alpha)^n + sum_{j>=1} ...', so the error was introduced in transcription. Statement (b) itself is correct: the bound holds in all tested cases (same check).
* *Fix.* Write: 'The labels at x_0 agree with probability (1-alpha)^n + sum_{j>=1} C(n,j) alpha^j (1-alpha)^{n-j} sum_y P(y|x_0)^j. For j>=1, sum_y P(y|x_0)^j <= p_max^{j-1}, so this is at most (1-alpha)^n + p_max^{-1}[(1-alpha+alpha p_max)^n - (1-alpha)^n] <= (1-alpha)^n + p_max^{-1}(1-alpha+alpha p_max)^n.'

**P1A-03** [major] `paper/sections/versions.tex`, rem:versions:prediction item (2), line 129; also line 96 ('W pays no factor depending on |D|')

* *Problem.* Item (2) says W 'predicts as well as SFI ... up to K(ceil(log(d+1)))+O(1) bits on fair-coin labels however many are predicted'. What is proved (prop:versions:tape(b)) is L_W(D) <= |D| + K^pad(2^{d+1}) + c': W is close to the fair-coin law, not to SFI. Against SFI the proved bound is L_W(D) - L_SFI(D) <= |D| - L_SFI(D) + K(ceil(log(d+1))) + O(1) <= delta_D + K(ceil(log(d+1))) + O(1) with delta_D = |D| - K(D|dom D) (thm:setting:coding(a)). This is small only when the labels have small randomness deficiency (for labels actually drawn by fair coins, delta_D <= m with probability >= 1 - 2^-m). For compressible labels only the general K^pad(L_{1/2}(M_F,D)) bound applies. Line 96, 'W pays no factor depending on |D|', is likewise proved only relative to the fair-coin law.
* *Evidence.* prop:versions:tape(b) (l.54) and its proof (app-versions.tex l.50) compare W with the law of F(x)=omega_{j(x)+1}, which gives D probability 2^-|D|. No step compares W with M_F(D) on such data. The foundations notes (Section 4) use the same compressed wording.
* *Fix.* In (2) write: '... and its loss exceeds the fair-coin loss |D| by at most K(ceil(log(d+1)))+O(1) bits, however many labels are predicted. Hence it exceeds SFI's loss by at most delta_D + K(ceil(log(d+1))) + O(1), where delta_D = |D| - K(D|dom D) (thm:setting:coding(a)).' In l.96 write: 'while W, compared with the fair-coin law, pays no factor depending on |D| (prop:versions:tape(b)).'

**P1A-04** [major] `paper/sections/versions.tex`, rem:versions:prediction item (4), line 131

* *Problem.* 'M^w can beat M_F by linearly many bits on data no random function produces (blocks of nu_tri)'. As a statement about data this is false. The witnesses D_k are ordinary data sets, and random functions produce them with positive probability: the lookup table of D_k does, and so does P_1^{(x)k}, which gives each E_i probability 3^-k. What no law of a random function can do is dominate the weak semimeasure nu_tri^{(x)k} by a factor better than (2/3)^k. The sentence suggests the M^w-versus-M_F gap concerns only impossible data. That misrepresents thm:setting:weakvsmachine(iii), whose gap occurs on genuine function data.
* *Evidence.* app-setting.tex l.117 and l.125 (P_1^{(x)k}(F >= E_i) = 3^-k > 0). scratch/p1mathA_s1_semimeasures.py, checks (2)-(3): P_1 gives every E_i probability 1/3; the min ratio over the support is exactly (2/3)^k for k=1,2; an LP over all laws on {a,b,c} gives the optimum 2/3.
* *Fix.* Write: '(4) M^w can exceed M_F by linearly many bits on some data sets (thm:setting:weakvsmachine(iii)). The reason is that M^w dominates the weak semimeasure nu_tri^{(x)k}, which no law of a random function dominates by a factor better than (2/3)^k. M^w pays for this by having no posterior over functions.'

**P1A-05** [major] `paper/sections/setting.tex`, paragraph after ex:setting:swap, line 159

* *Problem.* 'a history-aware predictor shown x_1 first must predict x_2 from x_1 alone and pays K(x_2|x_1) - O(1) bits'. This is false for an arbitrary history-aware predictor. A computable predictor that hard-codes the pair (or the map x_1 -> x_2) pays 0 bits. The bound holds for lower-semicomputable predictors, and the constant depends on the predictor. By the conditional coding theorem, an lsc chronological semimeasure rho pays at least K(x_2|x_1) - K(rho) - O(1) bits on that step. This form is what the 'not a separation' point needs, since the separations compare SFI with simple predictors.
* *Evidence.* The foundations notes (Ex 6.4, discussion) say 'A lower-semicomputable history-aware predictor, for instance the universal chronological semimeasure xi ... y -> xi(y||x) is a lower-semicomputable semimeasure given x, so it pays at least K(x_2|x_1)-O(1)'. The hypothesis 'lower-semicomputable' and the dependence of the constant on the predictor were dropped.
* *Fix.* Write: '... every lower-semicomputable history-aware predictor rho shown x_1 first pays at least K(x_2|x_1) - K(rho) - O(1) bits on the label of x_1 (conditional coding theorem), and M_H pays at least K(x_2|x_1) - O(1). So no simple history-aware predictor beats SFI here by more than a constant.'

**P1A-06** [major] `paper/sections/setting.tex`, thm:setting:invariance(b), line 142

* *Problem.* 'So cumulative losses on original and re-encoded data differ by at most K(alpha,beta)+O(1) bits, uniformly over data sets and reveal orders' names no loss convention. The proof bounds |log M_F(D) - log M'_F(D^{alpha beta})|, so the statement holds in the semimeasure convention (prop:setting:order). For the normalised convention it is not proved. By prop:setting:transfer(a), Lbar = L - sum_t log(1/Z_t), and the normalisers of M'_F include mass on labels outside beta(Y). The proof does not control the difference between the two sums of log(1/Z_t). Section 2.1 (l.14) and NOTATION.md Section 1 require every statement about losses to name its convention.
* *Evidence.* app-setting.tex l.173-179 proves only the two-sided bound on values of M_F. No argument covers Mbar_F.
* *Fix.* Add '(semimeasure convention)' after 'cumulative losses'. If wanted, add: 'In the normalised convention only the one-sided bound Lbar'(D^{alpha beta}) <= L_SFI(D) + K(alpha,beta) + O(1) follows.'

**P1A-07** [major] `paper/sections/setting.tex`, rem:setting:recommend, line 135

* *Problem.* 'The variants W, K_F, M_prod, M_pq, M^w ... agree with it up to K(dom D)+O(1) bits'. M_pq is defined on sequences, not on data sets. On inconsistent sequences M_pq > 0 = M_F (prop:learn:perquery(a)), so no bound holds there. On consistent sequences with repeated inputs the paper nowhere proves agreement with M_F: thm:versions:chain covers only K_F, W, M_prod, M_F and M^w. The claim is true on consistent sequences, but the argument is missing: the deterministic components give M_pq >= 2^{-O(1)} W(D_n), and M_pq <= M_prod(D_n) <= 2^{O(1)} M_F(D_n).
* *Evidence.* thm:versions:chain (versions.tex l.30-36); prop:learn:perquery(a) (learn.tex l.92). The source (foundations notes, Section 5 'Recommendation') restricts the statement to 'on data sets'.
* *Fix.* Write: '... agree with it up to K(dom D)+O(1) bits on data sets. For M_pq this holds on consistent sequences: its deterministic components give M_pq >= 2^{-O(1)} W(D_n), and M_pq <= M_prod(D_n). On inconsistent sequences M_pq differs from all of them completely.'

**P1A-08** [major] `paper/sections/app-versions.tex`, rem:versions:hist, line 117

* *Problem.* 'while the single shortest program pays more than log n + log log n extra bits infinitely often along every input sequence' leaves out the maximum over labels. prop:hist:programs(d) is a statement about max_{y in {0,1}^n} K_hist(y||x_{1:n}) - n. For a fixed label sequence the statement is false: for y = 0^n, K_hist(0^n||x) = O(1), far below n. The contrast with W_hist also needs the quantifiers aligned: the W_hist bound holds for every y, while the K_hist bound concerns the worst y.
* *Evidence.* app-hist.tex l.185 (statement of prop:hist:programs(d)); history notes, Prop 4.10(d).
* *Fix.* Write: '... while for the worst labels the single shortest program pays more: max_{y in {0,1}^n} K_hist(y||x_{1:n}) - n > log n + log log n for infinitely many n, along every input sequence (prop:hist:programs(d)).'

**P1A-09** [major] `paper/sections/setting.tex, versions.tex, learn.tex, app-setting.tex, app-versions.tex, app-learn.tex`, every theorem-like environment (\status, \src)

* *Problem.* The compiled PDF prints \status{...} and \src{...} on every theorem-like environment of these sections, for example '[proved] foundations Prop 2.1a (= context Prop 5.1(a))' and '[proved; refuted (the brief's fresh-noise claim, as stated); computed (foundations c5, r9(b))]'. The binding note forbids them in the final PDF. It leaves their removal to a conversion pass that reads the tags, so the tags must use the allowed values, and several do not: rem:setting:h1a 'refuted (weak definition); open (random-function laws)', rem:learn:ideal 'remark (each item cited)', rem:learn:relations and rem:learn:interventions 'remark', prop:learn:occam 'proved (standard); references known, unverified', rem:learn:positive 'proof sketch; known (snippet)'.
* *Evidence.* pdftotext of paper/main.pdf (e.g. Proposition 2.3, Theorem 4.3, Proposition 4.6). OUTLINE.md binding note 'Status tags and source notes'.
* *Fix.* Run the conversion pass for these files. Before it, map the non-standard statuses: drop 'remark'; render 'open' as an open-problem paragraph; give rem:learn:positive's argument the label 'Proof sketch'. Check that no part of a tag is duplicated in visible text (see the next issues).

**P1A-10** [major] `paper/sections/setting.tex, app-setting.tex`, setting.tex l.119, l.156; app-setting.tex l.115, l.117, l.125, l.132, l.151, l.154, l.166

* *Problem.* Visible text outside \status/\src, which the conversion pass will not remove, names internal check scripts and research tracks. Examples: '(c3)' and '(context c3)' (setting l.119); '(c9(c))' (l.156); 'check c6 confirms both facts on examples' (app-setting l.115); '(c1 checks k=2 exhaustively, 1458 inequalities; r1 also k=3)' (l.117); '(checked by hand and by c9(b))' and '(c9(b) for k <= 4; r1)' (l.125); the paragraph heading 'Reformulation (proof sketch; foundations Problem 3.6)' (l.132); '(c10(a4))' (l.151); 'Check c10 found agreement ... (r13: 300 of 300)' (l.154); '(c10(b) checks this exactly on 16,200 cases ...)' (l.166). 'foundations' and 'context' are track names, and 'r1' and 'r13' are referee scripts. The binding note forbids this vocabulary.
* *Evidence.* pdftotext of paper/main.pdf. OUTLINE.md binding note: 'No process vocabulary in the paper'; computed results are to be stated as 'a direct computation (code in the accompanying repository) gives ...'.
* *Fix.* Rephrase each as 'a direct computation (code in the accompanying repository) confirms ...'. Example for l.119: 'On a randomly generated law of a random partial function on six inputs, the semimeasure loss is the same (10.92 bits) in all 720 orders, while the normalised loss ranges from 7.33 to 10.64 bits (direct computation).' Change the heading to 'Reformulation (proof sketch)'. Drop the r1/r13 mentions, or write 'an independent second implementation agrees'. Name the scripts once, in the 'Code and data' statement.

**P1A-11** [major] `paper/sections/versions.tex, app-versions.tex`, versions.tex l.123 (caption of tab:versions:compare); app-versions.tex l.35, l.60, l.86, l.99, l.102

* *Problem.* The caption of Table 2 ends 'Source: foundations Table 4.12.', a track name printed in every copy. The appendix cites check and referee scripts in running text: '(c8(a))', '(c2 checks this exhaustively for ...)', '(c8(a) checks the arithmetic for all d <= 2*10^5 ...)', '(c8(d))', 'Check c8(c) computes ...', '(c8(b), N <= 14)', '... only for N <= 6 (c8(b)) and N <= 8 (r11)'.
* *Evidence.* pdftotext of paper/main.pdf (caption of Table 2 and Appendix B). OUTLINE.md binding note.
* *Fix.* Delete 'Source: foundations Table 4.12.' Replace the script names with 'a direct computation (code in the accompanying repository) confirms ...', keeping the ranges (d <= 2*10^5, N <= 14, and so on).

**P1A-12** [major] `paper/sections/learn.tex, app-learn.tex`, learn.tex l.49, l.87, l.108, l.112; app-learn.tex l.33, l.129, l.141

* *Problem.* Visible text names tracks and referee scripts: 'foundations r6' (l.49), '(foundations c5)' (l.87), '(foundations r12)' (l.108, l.112). app-learn l.33 has the run-in heading 'Integrability (not written out in the notes for (b))', which refers to the internal research notes. l.129 has '(foundations §6.6; ...)'. The 'Computations' paragraph (l.141) lists 'Foundations: c4 (...), r6 (...), ... Context: c3 (...)', that is, the track structure and the referee scripts.
* *Evidence.* pdftotext of paper/main.pdf. OUTLINE.md binding note: no 'track', 'referee' or 'notes-final' vocabulary; one 'Code and data' statement.
* *Fix.* Replace with neutral wording, e.g. 'in a finite analogue computed exactly (code in the accompanying repository)'. Make the heading 'Integrability'. Rewrite l.141 as a list of computations by content and seed, with no track names or 'r'-prefixed scripts, or move it to the 'Code and data' statement.

**P1A-13** [major] `paper/sections/app-learn.tex`, rem:learn:cesaro, lines 117-120; also learn.tex l.141

* *Problem.* The remark is an internal-correction narrative: 'An earlier version of the context notes read prop:learn:typical as "matching the O(1/n) Cesaro upper bound up to log^2 n". The comparison is invalid ...', with \status{refuted}. learn.tex l.141 repeats it: 'Reading this as ... is refuted (rem:learn:cesaro)'. The binding note admits refuted claims only as 'the natural strengthening X fails' and forbids lists of internal corrections. The mathematical content is correct and worth keeping: sum_k E e_k <= (ln 2)(K(f)+c) forces liminf_k k E e_k = 0, so a per-step lower bound cannot be compared with a Cesaro bound.
* *Evidence.* OUTLINE.md binding note ('Refuted earlier claims appear only where they inform the reader ... No list of internal corrections').
* *Fix.* Retitle the remark 'Per-step versus averaged bounds' and state only the mathematics: 'prop:learn:typical is a per-step lower bound; it cannot be compared with the Cesaro bound of thm:learn:batch(a). Indeed sum_k E e_k <= (ln 2)(K(f)+c), so liminf_k k E e_k = 0. The per-step rate is given by cor:learn:perstep.' Remove the 'refuted' tag. In learn.tex l.141 drop the sentence or cite the retitled remark.

**P1A-14** [major] `paper/sections/learn.tex`, prop:learn:freshnoise (c) and the paragraph after it, lines 84 and 87

* *Problem.* Visible text refers to the commissioning brief and to the drafting history: 'This refutes the fresh-noise form of the supervised-learning hypothesis H7 for random-function SFI (Table 1)' and 'The finite-loss proviso in (c) is ours'. Part (c) refutes a quoted statement whose source is not given, and Table 1 is a verdict table for the brief's hypotheses H1-H10.
* *Evidence.* pdftotext of paper/main.pdf, Section 4.3. OUTLINE.md binding note (no 'brief' vocabulary; refuted claims phrased as 'the natural strengthening X fails').
* *Fix.* Rephrase (c): 'The natural strengthening "for every input distribution and every computable conditional probability P, SFI's expected cumulative log loss exceeds that of P by at most K(P)+O(1)" fails for random-function SFI. For P with finite expected log loss it holds for all n exactly when ...'. Delete 'This refutes ... H7 ... (Table 1)'. Replace 'The finite-loss proviso in (c) is ours (...)' with '(For P with infinite expected log loss the inequality is trivial.)'

**P1A-15** [major] `paper/sections/setting.tex, app-setting.tex, versions.tex, app-versions.tex, learn.tex, app-learn.tex`, setting.tex l.12, l.40, l.175; app-setting.tex l.81, l.132; versions.tex l.21; app-versions.tex l.92, l.102; learn.tex l.49, l.77, l.171; app-learn.tex l.106, l.129, l.133

* *Problem.* Printed hedges about unchecked literature remain in visible text: 'we have not checked the analogy against these sources', '(not checked against the source)', '(abstract only seen)', '(search snippet only)', 'we have not checked its statement, nor whether it applies ...', '(statements not checked)', 'we did not check optimality against the source', '(source not checked)', '(not checked)', 'A table-of-contents snippet shows ... We have not read these sections' (rem:learn:hutterEX), '(content not checked)', 'the cited works were not checked against their sources', 'their exact model was not checked'. The binding note requires verified references only, says to drop or replace any citation that cannot be checked, and says never to print 'unverified'. These phrases are the same thing in other words, and they break the formal register.
* *Evidence.* OUTLINE.md binding note ('References: only references whose bibliographic data have been checked. Drop or replace a citation that cannot be checked; never print "unverified"'). pdftotext of paper/main.pdf.
* *Fix.* For each citation, either (a) keep it only for what its verified bibliographic record supports, phrased neutrally ('see also [X]', 'cf. [X]'), with no remark about checking, or (b) drop the citation together with the content claim it carries. rem:learn:hutterEX: keep one neutral sentence if the Hutter references are verified, otherwise drop the remark. rem:versions:operator: describe M_pq as 'the per-query form in which operator induction is usually stated [verified reference]', or drop the attribution. Levin 2016 and Kleitman-Spencer: keep only 'cf. [X]'.

**P1A-27** [major] `paper/sections/versions.tex`, tab:versions:compare, row 'M_prod vs M_F', line 117

* *Problem.* The upper-bound cell 'nu_len-type data: K^pad(d+1)+O(1) (rem:versions:sharedsize)' cites a remark that bounds log(nu_len(D)/M_prod(D)), not log(M_F(D)/M_prod(D)). On the same data the gap to M_F is controlled only by the general bound min{K^pad(L_{1/2}(M_F,D)), K(dom D)}. The cell sits under 'gap: upper bound' in the table that answers the Kolmogorov-versus-semimeasure question, so it states an upper bound on log(M_F/M_prod) that is not proved anywhere: on data with inputs of length <= d, M_F may exceed nu_len by up to K^pad(L_{1/2}(M_F,D)) bits, and nothing bounds that by K^pad(d+1). (Severity raised from minor to major in the second pass: a reader of the summary table takes the cell as a proved bound on the M_prod-versus-M_F gap.)
* *Evidence.* rem:versions:sharedsize (versions.tex l.66-68) and its proof (app-versions.tex l.81). The source row (foundations notes, Table 4.12, 'on sigma-type data: kappa(n+1)+O(1) (Remark 4.5a)') has the same mismatch; Remark 4.5a there also bounds only sigma/M_prod.
* *Fix.* Write 'against nu_len, inputs of length <= d: K^pad(d+1)+O(1) (rem:versions:sharedsize)'.

**P1A-37** [major] `paper/sections/versions.tex`, caption of tab:versions:compare, line 123 (sentence 'by rem:versions:noncomputable no computable family exhibits a gap larger than K(k)+O(1) in any row')

* *Problem.* The caption says that no computable family exhibits a gap larger than K(k)+O(1) 'in any row'. This is false for the last row of the same table, 'M_prod vs M_pq': along the computable family of length-2 sequences ((x_k,0),(x_k,1)), M_prod gives 0 (the sequence is not a data set) while M_pq > 0 (prop:learn:perquery(a)), an infinite gap, as the row itself says. rem:versions:noncomputable, which the caption cites, covers only the five quantities of thm:versions:chain on data sets. For the row 'M_F vs every lsc random-function law' the claim holds by the same argument (log(nu(D_k)/M_F(D_k)) <= -log M_F(D_k) <= K_F(D_k)+O(1) <= K(k)+O(1)), but the remark does not say so.
* *Evidence.* versions.tex l.120 (last row: 'M_pq > 0 = M_prod on inconsistent sequences'); l.99 (rem:versions:noncomputable: 'the five quantities of thm:versions:chain'); learn.tex l.92 (prop:learn:perquery(a): 'positive on inconsistent sequences'). Second-pass script scratch/p1-math-A-r2/a4_realise.py, item (2). The foundations notes (after Table 4.12) contain the same over-general sentence.
* *Fix.* Write: 'By rem:versions:noncomputable (and, for the sixth row, the bound log(nu/M_F) <= K_F+O(1)), along a computable family k -> D_k of data sets no gap in the first six rows exceeds K(k)+O(1). The last row compares objects on sequences; with repeated inputs M_pq and M_prod differ completely, also along computable families.'

**P1A-38** [major] `paper/sections/versions.tex, learn.tex (and bib/all.bib entry hanni2026request)`, versions.tex l.4 ('He later asked that the paper ...'), l.123 (caption '(Hänni's later request)'), l.137 (title 'Answer to Hänni's request'); learn.tex l.7 ('Hänni describes SFI as ... \citep{hanni2026request}')

* *Problem.* The visible text refers conversationally to a request for this paper: 'He later asked that the paper "include an equivalence ..." (Hänni, 2026c)', the caption '(Hänni's later request)', and the remark title 'Answer to Hänni's request'. The paper's sole author is Hänni, so the paper reports that its author asked the paper for something, and cites the request as 'Personal communication to the author' (bib entry hanni2026request), i.e. a communication from the author to himself. The bib entry's howpublished field also names the internal file 'research/00-brief.md'. learn.tex l.7 cites the same entry for the phrase 'just ideal supervised learning'. The binding note forbids conversational references to 'his request' and the word 'brief', and requires a formal register.
* *Evidence.* OUTLINE.md binding note ('Tone: formal academic register. No conversational references to "his request"'; no 'brief'). bib/all.bib l.73-79 (hanni2026request: 'Personal communication to the author, 11 October 2026; quoted verbatim in .../research/00-brief.md'). main.tex: author line 'Kaarel Hänni' alone.
* *Fix.* versions.tex l.4: 'The author's notes contain a section headed "Equivalence between Kolmogorov version and universal semimeasure version", whose text is "need coding theorem" [hanni2026notes]. We show that the versions are not equivalent: Table 2 summarises ...'. Drop '(Hänni's later request)' from the caption; retitle rem:versions:answer 'The versions are not equivalent'. learn.tex l.7: 'SFI can be viewed as ideal supervised learning. This section states the guarantees behind that view and where they stop.' Do not cite hanni2026request in these sections; if the entry is kept elsewhere, remove the pointer to research/00-brief.md. Throughout these sections prefer 'the author's notes' to third-person 'Hänni's draft' and 'his setting' (the binding note allows ideas to be described as the author's).

**P1A-16** [minor] `paper/sections/versions.tex`, line 46 (sentence after prop:versions:Wgap)

* *Problem.* 'The two-point gap of W against M_prod and M_F lies between log(1/Omega^{>=l_d}) ... and K^pad(2^{d+1})+O(1)' leaves out two things. The lower bound holds only for the largest gap over pairs, and it needs a '-O(1)' (the gap is log(M_F/W) >= log(1/Omega) + log M_F(D) >= log(1/Omega) - 2 - O(1)). Table 2 has the '-O(1)', so the text and the table disagree.
* *Evidence.* rem:versions:Wrate (app-versions.tex l.31) states the lower bound as a bound on -log W(D) for some D; Table 2 (l.116) writes 'log(1/Omega^{>=l_d}) - O(1)'.
* *Fix.* Write: 'The largest two-point gap log(M_F(D)/W(D)) (and log(M_prod(D)/W(D))) over d-bit inputs lies between log(1/Omega^{>=l_d}) - O(1) and K^pad(2^{d+1}) + O(1).'

**P1A-17** [minor] `paper/sections/versions.tex`, line 46 (parenthesis 'Pigeonhole: ...')

* *Problem.* '... so two inputs are never separated by them' has the wrong quantifier. The pigeonhole argument shows that, when 3^{2^l} < 2^d, some two inputs are not separated by any of the short programs. It does not show that no two inputs are ever separated.
* *Evidence.* Proof of prop:versions:Wgap(a) (app-versions.tex l.25).
* *Fix.* Write: '... so when 3^{2^l} < 2^d some two inputs are separated by none of them.'

**P1A-18** [minor] `paper/sections/versions.tex`, rem:versions:prediction item (5), line 132

* *Problem.* 'For a deterministic computable f all five are at least 2^{-K(f)-O(1)} on its data, so the basic learning bounds (dominance(b), mistakes, batch(a)) hold for all.' This includes 2^{-K_F}, which item (3) of the same remark says is 'a description length ..., not a predictor's loss'. The mistake bound and the online-to-batch bound concern predictors.
* *Evidence.* versions.tex l.130 versus l.132.
* *Fix.* Write: '... hold for W, M_prod, M_F and M^w; for K_F the corresponding statement is the Occam bound prop:learn:occam.'

**P1A-19** [minor] `paper/sections/setting.tex`, thm:setting:weakvsmachine (iv), (v), lines 88-91

* *Problem.* The statement refers to 'the 3^k explicit data sets E_i of the proof' and to nu_tri^{(x)k}, which are defined only in the appendix proof. (v) 'The constant (2/3)^k behind (iii) is exact for nu_tri^{(x)k}' does not say in what sense. What is proved is: sup over laws P of random partial functions of min over D in the support of P(F >= D)/nu_tri^{(x)k}(D) equals (2/3)^k, attained by P_1^{(x)k}. In l.91, 'at least a fraction ... approx 0.37 of the term K(dom D) is needed' holds only asymptotically, because of the K(k) terms.
* *Evidence.* app-setting.tex l.117-125. scratch/p1mathA_s1_semimeasures.py, checks (2)-(3), confirm the exact value 2/3 (LP over all laws) and (2/3)^2.
* *Fix.* Define nu_tri^{(x)k} and E_i in the statement. State (v) as the sup-min identity above. Add 'asymptotically' in l.91.

**P1A-20** [minor] `paper/sections/setting.tex`, def:setting:sfi, line 104

* *Problem.* The posterior is said to have containment functional E -> M_F(D u E)/M_F(D). This is defined only for E consistent with D, since D u E must be a data set. For E inconsistent with D the posterior containment probability is 0.
* *Evidence.* The foundations notes (Def 5.1) say 'for E consistent with D'.
* *Fix.* Add 'for E consistent with D (and 0 otherwise)'.

**P1A-21** [minor] `paper/sections/app-versions.tex`, rem:versions:Wdelim, line 9

* *Problem.* 'it is a machine law of complexity O(1), not a mixture of fixed functions'. The law of every random partial function is a mixture of point masses on fixed functions, so this is literally false. The intended contrast is with W, a countable mixture of partial computable functions with input-independent prefix-free weights. The law of x -> V(omega,x) is in general non-atomic, so it is not such a mixture.
* *Evidence.* versions.tex l.25 ('Nowhere in W and K_F (fixed functions)') uses 'fixed functions' to mean deterministic programs.
* *Fix.* Write: '... it is a machine law of complexity O(1), but not a countable mixture of partial computable functions with input-independent weights.'

**P1A-22** [minor] `paper/sections/app-setting.tex`, cor:setting:normuniversal, line 57

* *Problem.* The hypothesis 'all its conditionals sum to 1' conflicts with the convention of def:setting:data that nu(y|D,x) := 0 when nu(D) = 0. Read literally, it forces nu(D) > 0 for every D. The proof uses sum_y nu(D+(x,y)) = nu(D) for all D and all x not in dom D, which is the hypothesis of lem:setting:total.
* *Evidence.* setting.tex l.9 (convention); app-setting.tex l.49 (lem:setting:total's hypothesis).
* *Fix.* Write: 'if nu is lsc, nu(empty)=1 and sum_y nu(D+(x,y)) = nu(D) for all D and x not in dom D, then ...'.

**P1A-23** [minor] `paper/sections/versions.tex, app-setting.tex, app-versions.tex`, versions.tex l.51, l.58; app-setting.tex l.93; app-versions.tex l.4

* *Problem.* Several symbols are used before they are defined, or never defined. j(x), the length-lexicographic index, appears in versions.tex l.58 and app-setting.tex l.93 but is defined only in app-versions.tex l.4. The pairing <.,.> used for the private streams (app-setting l.93) is N x N -> N, whereas learn.tex l.70 defines <.,.> : X x N -> X. K(T) for a function machine T (prop:versions:tape, versions l.51; app-versions l.43, l.48) is never defined; only K(nu) for laws is (setting l.12).
* *Evidence.* Text cited.
* *Fix.* Define j and both pairings in sec:setting:data. Define K(T) := min{K(i) : T_i = T} for the enumeration of prop:setting:machinelaw (note that K(nu_T) <= K(T)).

**P1A-24** [minor] `paper/sections/app-setting.tex`, proof of prop:setting:mobius, line 21

* *Problem.* 'by the second consequence of def:setting:weak': the consequences (monotonicity, and sum over D with dom D = S of nu(D) <= nu(empty)) are stated in an unnumbered sentence after the definition (setting.tex l.22), so the reference cannot be resolved.
* *Evidence.* setting.tex l.22.
* *Fix.* Number the two consequences, e.g. (W1) and (W2), and cite (W2) here and in the proofs of thm:setting:coding(a) and thm:versions:chain.

**P1A-25** [minor] `paper/sections/setting.tex`, line 4

* *Problem.* 'We take the most general reading that still yields a random function: one random tape read by all inputs.' Whether every lsc law of a random partial function is a machine law is open (q:setting:rpf), so 'most general reading that still yields a random function' is not established. What is established is that, among programs that read random bits, one shared tape includes the deterministic and private-stream readings (prop:setting:includes).
* *Evidence.* q:setting:rpf (l.99); prop:setting:includes (l.68-73).
* *Fix.* Write: 'We take the most general of these readings, one random tape read by all inputs; deterministic programs and private streams are special cases (prop:setting:includes).'

**P1A-26** [minor] `paper/sections/setting.tex`, q:setting:rpf, line 99

* *Problem.* The main text gives the sufficient condition as 'lower approximations increasing on all up-sets of the extension order'. The appendix sketch (app-setting l.132) needs more: approximations by laws P_t on finite domains with finitely many labels and rational probabilities, computable from t, and, in the question, a constant-factor loss. The short form overstates what the sketch gives.
* *Evidence.* app-setting.tex l.132-134.
* *Fix.* Write: '... that every such law, up to a constant factor, is the increasing limit of computable finite rational laws P_t with P_t(U) <= P_{t+1}(U) for every up-set U of the extension order ...'.

**P1A-28** [minor] `paper/sections/setting.tex`, rem:setting:conventions, lines 126-128

* *Problem.* (i) 'they hold in the semimeasure convention only' can be read as 'they fail in the normalised convention', but the status (and q:setting:normorder) says transfer is open. (ii) 'the cyclic permutation at steps t <= 2^{(1-delta)d}, at delta d - O(log d) bits per step' leaves out that the source result (examples notes, Prop 2.9; prop:ex:normalised) holds in expectation, or with probability >= 1-2^-m up to an extra -m, and on average over the first k <= 2^{(1-delta)d} steps. The per-step bound is log(N-t+1) - K(t-1) - c.
* *Evidence.* Examples notes, Prop 2.9; q:setting:normorder (l.132).
* *Fix.* Write 'are proved only in the semimeasure convention (their normalised versions are open)' and 'the cyclic permutation over its first k <= 2^{(1-delta)d} steps, at delta d - O(log d) bits per step on average, in expectation (prop:ex:normalised)'.

**P1A-29** [minor] `paper/sections/setting.tex`, line 146 (remark after thm:setting:invariance)

* *Problem.* 'which can change losses by up to that much (only the upper bound is proved)' contradicts itself: 'can change ... by up to that much' asserts that the change is possible, and the parenthesis says it is not shown.
* *Evidence.* Foundations notes, Thm 6.2 remark: only the upper bound is proved.
* *Fix.* Write: 'The constant is not small for complex encodings; only the upper bound is proved, and whether such encodings can change losses by that much is not shown.'

**P1A-30** [minor] `paper/sections/learn.tex`, rem:learn:ideal item (2), line 165

* *Problem.* 'with frozen noise, or fresh noise on stamped inputs or for M_pq, the cumulative bound K(P)+c holds' leaves out that P must be computable (lsc). For non-computable P, thm:learn:batch(b) and prop:learn:perquery(c) give only the resolvability bound K(P') + n E KL(P||P') against lsc comparators P'.
* *Evidence.* thm:learn:batch(b),(c) (l.70-73); prop:learn:perquery(c) (l.94).
* *Fix.* Insert 'for computable P' and add 'for non-computable P, the resolvability bound against lsc comparators'.

**P1A-31** [minor] `paper/sections/learn.tex`, paragraph after thm:learn:dominance, line 28

* *Problem.* 'Part (a) is Hänni's "Thm 1 (template)"' sits next to sec:hist, which discusses 'Hänni's Thm 1', a different statement about samplers that see the data set and a reveal law Delta. A reader can easily conflate the two.
* *Evidence.* research/prior/hanni-sfi-notes.md (both the 'template' and the later 'Thm 1' appear); sec:hist:thm1.
* *Fix.* Add '(not to be confused with his Thm 1 for samplers that see the revealed data, sec:hist:thm1)'.

**P1A-32** [minor] `paper/sections/app-versions.tex, setting.tex`, rem:versions:hashing (title and text), app-versions.tex l.55-56; rem:setting:h1a, setting.tex l.96

* *Problem.* The title 'The hashing bound, superseded' records internal history. The text quotes 'a log factor via k-wise independent hashing', and rem:setting:h1a quotes 'lsc function semimeasures, or equivalently monotone function machines'. Both quotations come from the commissioning brief's hypothesis list and are given without a source.
* *Evidence.* research/00-brief.md (H1(a) and the hashing hint); OUTLINE.md binding note (no 'brief' vocabulary).
* *Fix.* Retitle 'A hashing bound'. Rephrase without quotation marks: 'One might expect a logarithmic factor from k-wise independent hashing; that is the behaviour of K_F, not of W' and 'A Levin-style equivalence between lsc function semimeasures and function machines, as for sequences, fails for the weak definition ...'.

**P1A-33** [minor] `paper/sections/setting.tex, app-setting.tex`, setting.tex l.4, l.12; app-setting.tex l.134

* *Problem.* Process-style phrasing remains: 'several of the claims checked below are Hänni's' (l.4); 'We use, without re-checking the sources, ... that m dominates ...' (l.12); 'An adversary argument ... was tried and settled neither direction' (app-setting l.134).
* *Evidence.* OUTLINE.md binding note (formal academic register).
* *Fix.* Write 'several of the claims treated below are Hänni's', 'We use the following standard facts [refs]', and 'A natural adversary argument ... does not settle either direction'.

**P1A-34** [minor] `paper/sections/versions.tex`, thm:versions:nocoding, last clause, line 79

* *Problem.* '-log W(D) <= log K_F(D) + O(log log K_F(D))' is asymptotic: for small d, K_F(D) can be <= 2 and log log K_F(D) is undefined or negative. The proof gives a bound valid for every d >= 2.
* *Evidence.* app-versions.tex l.89: ceil(log(d+1)) <= K_F(D)+4 and K(m) <= log m + 2 log log m + O(1) for m >= 2.
* *Fix.* Write '-log W(D) <= log(K_F(D)+4) + 2 log log(K_F(D)+4) + O(1)'.

**P1A-35** [minor] `paper/sections/app-versions.tex`, proof of prop:versions:shared, line 68

* *Problem.* rho := max_{i in I_0}(1+S_i)/2 is undefined when I_0 is empty, which happens when all of the first J laws become deterministic in the limit on 0^n and 1^n.
* *Evidence.* Text cited. The proof is otherwise complete. scratch/p1mathA_s2_versions.py check (6) confirms the counting identities it uses.
* *Fix.* Define rho := 0 if I_0 is empty (or take the max over I_0 together with {0}).

**P1A-36** [minor] `paper/sections/versions.tex, app-versions.tex`, prop:versions:shared, line 61; app-versions.tex l.66

* *Problem.* Here nu_len is the law of F(x) = omega_{|x|+1}. NOTATION.md (Section 3.1) and Paper 2 (paper-steeper/sections/app-absorb.tex l.67: 'w_{|x|}', x != epsilon) use omega_{|x|}. Paper 1's certificate bound K^pad(d+1) (rem:versions:sharedsize) is right for its own definition. Paper 2 quotes it with K^pad(k+1), which is also valid, since K^pad is nondecreasing. Still, the same macro denotes two shifted laws in the two papers.
* *Evidence.* NOTATION.md Section 3.1 (row nu_len); paper-steeper absorb.tex l.71 and app-absorb.tex l.67.
* *Fix.* Use one definition in both papers and in NOTATION.md, for example omega_{|x|+1}, which avoids the undefined omega_0 at x = epsilon.

**P1A-39** [minor] `paper/sections/versions.tex`, q:versions:open, line 147 ('L_{1/2} is not computably bounded in (d,|D|)')

* *Problem.* The claim is asserted without proof; the foundations notes (Problem 4.6(b)) and their referee report assert it without proof too. For the default label set Y = {0,1}^* it is true for a trivial reason, which the paper should give: a tape prefix omega_{1:L} that certifies (x,y) determines y given x and L (enumerate T_U until a triple with input x and certificate a prefix of omega_{1:L} appears; consistency fixes its label), so K(y|x) <= L + K(L) + O(1), and L_{1/2}(M_F,{(x,y)}) >= K(y|x) - 2 log K(y|x) - O(1), which is unbounded over y for fixed (d,|D|) = (d,1). For finite Y (binary labels, where the open question is most natural) no proof is given and none is in the sources.
* *Evidence.* versions.tex l.147; foundations notes Problem 4.6(b) and referee.md l.111 (both unproved). Argument above.
* *Fix.* Write: 'For Y = {0,1}^* the tape length L_{1/2} is unbounded in (d,|D|), because a certificate of a label determines it (K(y|x) <= L_{1/2} + K(L_{1/2}) + O(1)); for finite Y we know no computable bound.'

**P1A-40** [minor] `paper/sections/app-learn.tex`, line 94 ('The following proposition is stated here rather than in sec:learn, for the page cap.')

* *Problem.* Process vocabulary in visible text: 'for the page cap' refers to the internal page budget of OUTLINE.md.
* *Evidence.* app-learn.tex l.94; OUTLINE.md binding note (no process vocabulary).
* *Fix.* Delete the sentence, or write 'We state one further result on chosen inputs.'

**P1A-41** [minor] `paper/sections/app-versions.tex`, proof of thm:versions:chain, step (2), line 17

* *Problem.* 'P_e(y|x) := 1[phi_e(x)=y] ... let g be computable with P_{g(e)} = P_e'. The letter P with a subscript denotes both the deterministic law of program e and the i-th element of the enumeration (P_i) of def:versions:variants, so 'P_{g(e)} = P_e' reads as a tautology. The argument is right once the two objects are distinguished.
* *Evidence.* def:versions:variants (versions.tex l.9) fixes (P_i); app-versions.tex l.17 reuses the symbol.
* *Fix.* Write 'delta_e(y|x) := 1[phi_e(x)=y] ... let g be computable with P_{g(e)} = delta_e', and use delta_e in the rest of step (2).

**P1A-42** [minor] `paper/sections/learn.tex`, proof idea of cor:learn:perstep, line 151 ('the normaliser is at least 2^{-K(f)-c}')

* *Problem.* 'Normaliser' is defined in def:setting:sfi as Z(D,x) = sum_y M_F(D+(x,y)). Here it means nu(D_n), the denominator of the posterior. A reader who looks up the term gets the wrong quantity.
* *Evidence.* setting.tex l.104 (definition of the normaliser); app-learn.tex l.83 (the proof uses nu(D_n)).
* *Fix.* Write 'the posterior denominator nu(D_n) is at least 2^{-K(f)-c}'.

**P1A-43** [minor] `paper/sections/learn.tex`, line 134 ('For general prior weights prop:learn:loo is tight within a factor of about 2 (rem:learn:increasing; heuristic in app:learn:remarks)')

* *Problem.* The parenthesis attaches 'heuristic in app:learn:remarks' to the tightness claim, but that heuristic supports conj:learn:loo (one-exception hypotheses have small total weight), not tightness. The tightness claim rests on rem:learn:increasing alone (LOO errors 1/2 each, sum |B|/2 against the bound |B|).
* *Evidence.* app-learn.tex l.110 (heuristic for conj:learn:loo) and l.112-115 (rem:learn:increasing). Second-pass script a3_learning.py, item (3): LOO sum 8 against bound 16 at |B| = 16.
* *Fix.* Write 'For general prior weights prop:learn:loo is tight within a factor of about 2 (rem:learn:increasing).' and move 'A heuristic for the conjecture is in app:learn:remarks.' after conj:learn:loo.

**P1A-44** [minor] `paper/sections/learn.tex`, paragraph 'Errors.', line 115

* *Problem.* e(x*) is set to 0 for x* in A, but e^wr(x*) and e_norm(x*) are defined through D+(x*,y), which is not a data set when x* is in dom D; the chain e^wr <= e_norm <= e is then stated without covering that case.
* *Evidence.* learn.tex l.115; def:setting:data l.9 (D+(x,y) only for x not in dom D).
* *Fix.* Add '(all three errors are 0 if x* is in A, by the repeated-input convention)'.

**P1A-45** [minor] `paper/sections/learn.tex`, cor:learn:mistakes, lines 53-58

* *Problem.* y_hat_t := argmax_y M_F(y|D_{t-1},x_t) is used with Y countably infinite by default, but the existence of a maximiser and a tie-breaking rule are not stated. The source (foundations Cor 6.6) states existence: the conditionals are positive and sum to at most 1, so only finitely many exceed any positive threshold.
* *Evidence.* foundations notes Cor 6.6 proof ('The maximum exists because only finitely many labels have conditional above any positive threshold'); learn.tex l.53-58 omits it.
* *Fix.* Add '(the maximum exists because the conditionals are positive and sum to at most 1; ties are broken arbitrarily)'.

**P1A-46** [minor] `paper/sections/setting.tex`, prop:setting:normalise, line 116

* *Problem.* L_bar_SFI is defined with Mbar_F, but parts (b) and (c) are statements about laws of random partial (total) functions in general, and the example for (b) is not M_F. Read literally, (b) says that SFI's own normalised loss can depend on the order, which q:setting:normorder says is open.
* *Evidence.* setting.tex l.116 versus l.119 (example law on two inputs) and l.132 (q:setting:normorder).
* *Fix.* Define L_bar_nu for every weak nu, state (b) and (c) for L_bar_nu, and add 'for nu = M_F, (b) is open (q:setting:normorder)'.

**P1A-47** [minor] `paper/sections/setting.tex`, rem:setting:conventions, line 127 (ex:setting:swap and thm:setting:coding(a) listed as semimeasure-only)

* *Problem.* The remark lists ex:setting:swap, and thm:setting:coding(a) beyond single points, as holding 'in the semimeasure convention only'. Part of each transfers by prop:setting:transfer(a): the first revealed pair is a single point, so in every order the normalised loss is at least K(y_first|x_first) - O(1). For the swap data this gives L_bar >= min{K(x_2|x_1), K(x_1|x_2)} - O(1) in every order, and for pairs with K(x_1) >= d and K(x_2|x_1) >= d (which exist for every d) it gives d - O(log d), by symmetry of information. The remark understates what is proved.
* *Evidence.* prop:setting:transfer(a) (app-setting.tex l.158, Z_1 >= 2^{-c}); setting.tex l.156 (swap tight case). Symmetry of information: K(x_1|x_2) >= K(x_1) + K(x_2|x_1) - K(x_2) - O(log d).
* *Fix.* After the swap entry add: '(normalised: at least min{K(x_2|x_1),K(x_1|x_2)} - O(1) in every order, by the single-point transfer)'.

**P1A-48** [minor] `paper/sections/setting.tex, versions.tex, learn.tex`, all \paragraph{Open question.}\label{q:...} (q:setting:rpf l.99, q:setting:normorder l.132, q:setting:twosided l.161, q:setting:level l.175, q:versions:explicit l.102, q:versions:open l.147) and every \cref to them

* *Problem.* A label after an unnumbered \paragraph refers to the enclosing subsection, so every cross-reference to an open question prints a section number. Inside Section 2.3, rem:setting:h1a says 'For random-function laws it is open (Section 2.3)'; rem:learn:h2(iii) also prints '(Section 2.3)'; the 'open' column of Table 2 prints '§ 2.3' and '§ 3.4'. A reader cannot locate the question from the reference.
* *Evidence.* pdftotext of paper/main.pdf, p. 10 ('it is open (Section 2.3)'), p. 16 (Table 2), p. 17 (Remark 4.2(iii)).
* *Fix.* Give open questions their own counter (e.g. \newcounter{oq}[section] with \refstepcounter{oq} inside the paragraph heading 'Open question \theoq.' and \crefname{oq}{Open question}{Open questions}). This keeps them out of theorem environments, as OUTLINE.md requires, and makes \cref print 'Open question 2.1'.

**P1A-49** [minor] `paper/sections/setting.tex`, def:setting:data, line 9 ('any infinite decidable X and countable Y, |Y| >= 2, will do')

* *Problem.* Lower semicomputability of laws, the effective enumeration (P_i) of conditional semimeasures, computable injections beta: Y -> Y' (thm:setting:invariance), the enumeration 'Y_bot with bot last' (proof of prop:setting:includes(c)) and the alphabet enumeration of lem:setting:realise all need a fixed effective presentation of Y. 'Countable' alone does not supply one.
* *Evidence.* setting.tex l.9; app-setting.tex l.77 and l.97; setting.tex l.142.
* *Fix.* Write 'countable Y with a fixed computable enumeration (for example a decidable set of strings)'.

**P1A-50** [minor] `paper/sections/learn.tex`, rem:learn:ideal, item (1), line 165 ('the prior "a random lower-semicomputable labeller"')

* *Problem.* M_F is the Bayes mixture over machine laws. Whether every lower-semicomputable law of a random function is a machine law is open (q:setting:rpf), so 'a random lower-semicomputable labeller' suggests a larger prior class than the one for which universality is proved. This is the learning-section counterpart of P1A-25.
* *Evidence.* thm:setting:universal; q:setting:rpf (setting.tex l.99); rem:learn:h2(iii).
* *Fix.* Write 'the prior "a random labeller computed by a probabilistic machine with one shared random tape" (machine laws weighted by m(i))'.

**P1A-51** [minor] `paper/sections/learn.tex`, prop:learn:splits, line 119

* *Problem.* The proposition names no loss convention, against the paper's own rule (setting.tex l.14). The equality 'expected test loss = -log(nu(f|_B)/nu(empty))/|B|' uses the order-free total of prop:setting:order and holds only in the semimeasure convention; in the normalised convention only the upper bound follows (prop:setting:normalise(a)). The error bound holds in both.
* *Evidence.* app-learn.tex l.61 (proof uses prop:setting:order). Second-pass script a3_learning.py, item (4): the semimeasure identity holds exactly in 200 random mixtures.
* *Fix.* Add '(semimeasure convention; in the normalised convention the expected test loss is at most this)'.

**P1A-52** [minor] `paper/sections/app-setting.tex`, line 154 ('Check c10 found agreement between (star) and order independence on 400 of 400 random laws with positive two-point cells (r13: 300 of 300)')

* *Problem.* Besides the script names (P1A-10), the sentence overstates the evidence. In the cited runs (star) and order independence hold in none of the random laws, so the agreement confirms only '(star) fails and the law is order-dependent'. The direction '(star) implies order independence' was tested only on laws built to satisfy (star) (c10(a2)).
* *Evidence.* research/tracks/foundations/checks/c10_normalised_convention.out.txt (a1): 'criterion true in 0; order-free in 0'; (a2): 400 built laws. Second-pass a1_semimeasures.py, item (5): 300/300 random positive laws agree with (star) true in 0; 200/200 laws with label-independent definedness satisfy both.
* *Fix.* Write: 'A direct computation confirms both directions: random laws with positive two-point cells violate (star) and are order-dependent (400 of 400), and laws constructed to satisfy (star) are order-independent (400 of 400).'

**P1A-53** [minor] `paper/sections/setting.tex`, prop:setting:includes(a), line 69 ('K(nu_P) <= K(P)+O(1)')

* *Problem.* K(P) for a conditional semimeasure P is used in Section 2 but defined only in learn.tex l.7, through the enumeration (P_i) introduced in def:versions:variants (Section 3). Section 2's definition of K(nu) presupposes an enumeration that has not yet been given for conditional semimeasures. This is in addition to the undefined symbols listed in P1A-23.
* *Evidence.* setting.tex l.12 and l.69; versions.tex l.9; learn.tex l.7.
* *Fix.* Move the enumeration of lsc conditional semimeasures (trimming each P(.|x)) and the definition K(P) := min{K(i): P_i = P} to sec:setting:data.
