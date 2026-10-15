# Paper 1: mathematical review A (setting, versions, learning, Appendices A–C)

Reviewer: p1-math-A. Scope: `paper/sections/setting.tex`, `versions.tex`, `learn.tex`, `app-setting.tex`, `app-versions.tex` and `app-learn.tex`, as compiled into `paper/main.pdf` (build of 12 Oct 2026, 16:59). Sources checked against: `research/tracks/foundations/notes-final.md` (with `referee.md`, `checks/`, `referee_code/`), `research/tracks/context/notes-final.md` §§1, 2.4, 5 (with checks c3, c4 and c7), history notes Prop 2.4 and Prop 4.10, examples notes Prop 2.9, Hänni's notes (`research/prior/hanni-sfi-notes.md`) and `research/00-brief.md`. Independent code is in `research/paper-review/scratch/p1mathA_s*.py`, with outputs `*.out.txt`. The machine-readable issue list is `p1/issues-p1-math-A.json`.

## 1. Verdict

The mathematics of these sections is sound and follows the foundations and context final notes closely. I checked every statement and every proof in the six files line by line, both against the notes and on its own. No theorem or proposition is false as stated. The proofs are complete, apart from the places marked as sketches, which are labelled correctly. The numbers I could recompute agree with the paper to the precision printed.

The defects are of four kinds.

1. **One unsupported claim (P1A-01).** It is the only fatal issue, and it sits in a gloss rather than in a theorem. `rem:versions:prediction`(3) says the single shortest program "can exceed SFI's loss … by about log(k(d+2)) on k incompressible binary labels". Only the upper bound is proved. The only lower bound in the paper is log d − O(1), for k = 2. Changing "by about" to "by at most …", with the precise bound, fixes it. Line 96 ("So a logarithmic cost is real …") has the same slant.
2. **One wrong formula in a proof (P1A-02).** The proof of `prop:learn:freshnoise`(b) sums from j = 0 and so counts the labels in the j = 0 term. As printed, the formula exceeds 1: 1.445 against the true 0.955 in my check. The source has it right; the transcription introduced the error.
3. **Glosses that drop a hypothesis or misstate what is proved (P1A-03 to P1A-08).**
   * W is compared with the fair-coin law, not with SFI (P1A-03).
   * "Data no random function produces" is false as written (P1A-04).
   * After the swap example, the history-aware lower bound needs "lower-semicomputable" and a predictor-dependent constant (P1A-05).
   * The loss form of the invariance theorem holds only in the semimeasure convention (P1A-06).
   * The recommendation's "agree up to K(dom D)" for M_pq holds only on consistent sequences and is not argued (P1A-07).
   * `rem:versions:hist` drops the maximum over labels (P1A-08).

   Each is easy to fix. Several readers would notice them, which is why I rate them major.
4. **arXiv-standard violations in visible text (P1A-09 to P1A-15).** The conversion pass will remove `\status`/`\src`, but it will not remove the many in-text mentions of scripts and tracks. These include "(context c3)", "foundations r6", "(c8(a) checks …)", the caption "Source: foundations Table 4.12", the heading "Reformulation (proof sketch; foundations Problem 3.6)", and the "Computations" paragraph that lists referee scripts. It will not remove the internal-correction remark `rem:learn:cesaro`, the reference to "hypothesis H7", or the printed "not checked / snippet / abstract only seen" hedges either. These must be rewritten by hand. Several `\status` values are also outside the allowed set, so the conversion pass cannot map them mechanically (P1A-09).

Twenty-one minor issues follow: quantifiers, undefined notation, statements that refer to objects defined only in proofs, and register.

**Counts:** 1 fatal, 14 major (7 mathematical and 7 arXiv-form), 21 minor.

## 2. What I checked, item by item

"Verified" means I re-derived the statement and its proof from the definitions and found it correct, and that it matches the source item cited in its `\src`. "+ code" means I also computed it independently (Section 3).

**Section 2 and Appendix A (setting).**

| item | result |
|---|---|
| `def:setting:data`, two loss conventions | verified; matches F §1 (repeated-input convention) |
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
| `prop:setting:normalise` (a)–(c) and its example (2/3, 1/2, 1/4) | verified + code |
| `prop:setting:twopoint` (i)–(iii) and the law of (iii) | verified + code ((⋆) agrees with order independence on 300 of 300 random positive laws; product laws satisfy both; (iii) law: criterion false, order-free true) |
| `prop:setting:transfer` (a)–(c) | verified (Z_1 ≥ 2^{-c}; the normalised product is a probability on Y^n for a fixed input list; relativised coding; Gibbs) |
| `rem:setting:conventions` | matches CLAIMS C7, history Prop 2.4 and examples Prop 2.9 (P1A-28: wording, "in expectation") |
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
| `thm:versions:chain`, steps (1)–(5) | verified |
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
| Table `tab:versions:compare` | every row matches F Table 4.12 and the proofs (P1A-27: row M_prod vs M_F; P1A-11: caption) |
| `rem:versions:prediction` (1)–(7) | (1), (6), (7) verified; (2) P1A-03; (3) P1A-01; (4) P1A-04; (5) P1A-18 |
| `rem:versions:answer` | verified |
| `prop:versions:structured` | verified (matches Co Prop 5.4(3),(4)) |
| `rem:versions:hist` | P1A-08 |
| Kleitman–Spencer two-point family | code: it 2-covers C(N−1, ⌊N/2⌋−1) inputs for N = 3..12 |

**Section 4 and Appendix C (learn).**

| item | result |
|---|---|
| `thm:learn:dominance` (a)–(c) | verified |
| `rem:learn:h2` | verified |
| `thm:learn:merging` (posterior lemma, integrability bound Σ p max(0, log q/p) ≤ log e, telescoping, Pinsker in bits) | verified + code (exact identity Σ E d_t = E log(ν/M) on a finite mixture, for an i.i.d. rule and an adaptive past-only rule, n ≤ 3; Pinsker and integrability on 20000 random pairs, largest value 0.503) |
| `cor:learn:mistakes` | verified |
| `thm:learn:batch` (a) convexity and Markov; (b) stamps, stamp-ignoring comparator, integrability, KL convexity, 0–1 excess via ‖·‖₁ and Pinsker; (c) | verified |
| `prop:learn:freshnoise` (a)–(c) | statements verified + code (P(consistent) = 0.95, 0.112864, 0.000498 at n = 2, 10, 20; bound (b) holds in all tested cases) (P1A-02: proof formula; P1A-14: wording) |
| `prop:learn:perquery` (a)–(d) | verified (positive conditional probability 2^{-2|y|-1} sums to 1) |
| `prop:learn:curve` | verified + code (closed forms agree with brute-force enumeration for t ≤ 6 and w ∈ {1/16, 1/5, 1/4}; (1+w)^3 − 8w = 0.128 at 1/5 and decreasing on [0, 1/5]; the crossing is at w ≈ 0.2361; r_0 + 2r_1 = log(1/w)) |
| `rem:learn:lastiterate` (identity) | verified |
| error definitions and e^wr ≤ e_norm ≤ e | verified + code |
| `prop:learn:splits`, `prop:learn:loo`, `conj:learn:loo` | verified + code (finite mixture over all 243 partial functions on 5 points: splits identity exact to 10^{-10}; LOO bound on all 31 subsets) |
| `prop:learn:typical` (1)–(3) and the separation step (machine and program constructions) | verified + code (the constant chain holds for every n ≤ 5000 and n = 10^4..10^{12}) |
| `cor:learn:perstep` (a), (b) | verified + code (exact E e(x*) ≤ the exchangeability bound and ≤ the Markov bound for n ≤ 4 under a non-uniform μ; ε choice gives exactly 1/n) |
| `prop:learn:occam` | verified (K_F(D_n) ≤ K(φ) holds exactly) |
| `rem:learn:ideal`, `rem:learn:hutterEX` | P1A-30 (computability of P); P1A-15 (hedges) |
| `prop:learn:active` (1), (2) | verified + code (mean of min(pos, N−1) ≥ (N−1)/2) |
| `rem:learn:increasing` (1 bit, 0.255, LOO error 1/2, sum 8 against bound 16) | verified + code |
| `rem:learn:cesaro` (mathematics) | verified (P1A-13: form) |
| `rem:learn:relations`, comparison paragraph, `rem:learn:positive`, `rem:learn:interventions` | consistent with Co Rem 2.18, F §6.6, Co Rem 5.5 and 5.6 |
| Numbers quoted from track checks (c5, c11, r6, r12; context c3, c4, c7) | all match the saved outputs (12.5 against 1; 63/300; 0.8731; 1.55·10^{-15}; 0.5084; seeds 20261011, 20261012, 2, 3, 7) |

**Fidelity to the sources.** Apart from P1A-01 (which repeats an unsupported sentence of the foundations notes) and P1A-02 (a transcription error), no statement in these sections is stronger than its source. Two statements are slightly stronger than the source but proved in the paper: `prop:learn:perquery`(a) "positive on inconsistent sequences", where the source says "possible", and `cor:setting:normuniversal` for countable Y, which extends context Cor 5.2(c) via F Lemma 6.5a, as CLAIMS C3 records. The places where hypotheses were dropped in transcription are P1A-05 (from F Ex 6.4) and P1A-07 (from F §5 "on data sets").

## 3. Independent computations

All scripts are deterministic (fixed seeds) and use exact rationals where possible. Run with `python3 -I`.

* `scratch/p1mathA_s1_semimeasures.py` → `.out.txt`: two-input example; ν_tri weakness, inconsistency and mass; LP optimum 2/3 over all laws; ν_tri^{⊗2} (1458 inequalities, ratio 4/9); Möbius identities on random laws (1920, no failures); the `prop:setting:normalise`(b) and `prop:setting:twopoint`(iii) examples; (⋆) against order independence on 300 random positive laws (agreement in all) and 100 product laws; order independence of the semimeasure loss on a random 4-input law (one value over 24 orders; normalised values 0.0666–0.1150); the swap XOR machine.
* `scratch/p1mathA_s2_versions.py` → `.out.txt`: ℓ_d by exact integer comparison; covering arithmetic; exact minimum covering families; Kleitman–Spencer family for N ≤ 12; GF(2^q) hashing uniformity; the lookup machine; the shared-coin counting identities; the padding function of `rem:versions:Wrate`.
* `scratch/p1mathA_s3_learn.py` → `.out.txt`: fresh-noise probabilities and bound (b), with the printed j ≥ 0 formula shown to exceed 1; learning-curve closed forms against brute force; `rem:learn:increasing` numbers; the active-learning bound; the constants of `prop:learn:typical` and `cor:learn:perstep`; a finite partial-function mixture (splits identity, LOO bound, e^wr ≤ e_norm ≤ e, the exchangeability and Markov bounds); the merging identity under i.i.d. and adaptive rules; Pinsker for sub-probabilities and the integrability inequality.
* `scratch/p1mathA_issues.py` generates `p1/issues-p1-math-A.json` and the list below from one source.

## 4. Remarks that are not issues

* The `\status` and `\src` tags are accurate wherever their values are standard, so the conversion pass can rely on them. The exceptions are listed in P1A-09.
* `prop:versions:shared` uses ν_len := law of ω_{|x|+1}. This is a deliberate and correct change from the source's ω_{|x|}, which would leave ω_0 undefined at x = ε. With it, the bound K^pad(d+1) of `rem:versions:sharedsize` is exactly right. Only the cross-paper alignment needs fixing (P1A-36).
* `rem:setting:fillin`, `q:setting:rpf` and Appendix A.6 present the open problem honestly. The Strassen step is labelled as quoted and the reduction step as not carried out.
* The 0.84 pt overfull box in Table 2 (`main.log` l.693) is invisible.

## 5. Numbered issue list (most severe first)

