# Check of the revised Claim E note (round 2)

*Published record of a check of the revised note, made during finalization. Paths under `stage/` refer to the lead's unpublished working copies; the pre-revision text there is the version that the referee reports reviewed, published as [`E-first-version.md`](E-first-version.md). This check's scripts and outputs are in the `../checks/revision-check-*` folder named below. Re-runs of the note's own scripts, which some reports keep in a `rerun/` subfolder, are not published; each report says whether they reproduced the recorded outputs.*

**Verdict: minor fixes.** Every referee issue is resolved, by a fix or a valid rebuttal, and the five problems of the round-1 check are fixed. Every changed statement I re-derived is correct, including the new Remark 5.4a. No claim was strengthened beyond its proof, no proved result was dropped, the numbering is stable, the cross-references match the current A, B, C and `red-team.md` §8, and all ten scripts reproduce their outputs byte for byte. Six small problems remain (§1): one quoted script result has no output behind it, one sentence of §2.3 is false at γ = 1, the γ = 1 gap is still misattributed in two places, three bookkeeping statements in §1.6 and §9 are slightly off, `paper.tex` is never introduced as a short name, and §1.6 calls c "the likelihood ratio".

**Documents.** Revised note `research-notes/E-finite-prior-scale.md` (794 lines, 17:20, unchanged during the check), against the pre-revision text `stage/E-finite-prior-scale.md` (691 lines). I read both in full and every one of the 58 diff hunks (`../checks/revision-check-E-2/diff.txt`), both referee reports, the cited items of A (the second revision in `research-notes/`), B, C, `stage/red-team.md` §8, the brief, `paper.tex` eq. `law` and `meanfield.tex` Prop. `mf-cover`. My scripts and outputs are in `../checks/revision-check-E-2/`.

## 1. Remaining problems (all minor)

1. **§7 item 4, first sub-bullet: a number with no output behind it.** The text says "In both scripts the exact expansion in smoothed features has error ≤ 4·10⁻¹⁵". Only `robust_memorizer.out` records this error (2.0–3.6·10⁻¹⁵); `robust_memorizer_det.py` neither computes nor prints it. The claim is true: the det script's own `expansion()` on its seven configurations gives 1.3–3.6·10⁻¹⁵ (`../checks/revision-check-E-2/detexp/det_expansion_err.py`). The pre-revision text made the claim without "in both scripts". *Fix:* make the det script print the error and re-run it, or restrict the sentence to `robust_memorizer.py`.

2. **§2.3, third bullet after Lemma 2.3: "this condition is sufficient, not necessary" is false at γ = 1.** At γ = 1, and at N = 1, N^{1−γ} = 1, so 3(H−1)N^{2−γ} ≤ K′ − 3(d+2) is equivalent to (2.1) (`check_E_r2.out`, item 8). The reason given for computation I-2, N^{1−γ} < 1 for N > 1, holds only for γ > 1. *Fix:* "...; for γ > 1 this condition is sufficient, not necessary."

3. **The γ = 1 gap is still attributed to the γ > 1 mechanism in two places.** The revision moved the attribution in the last paragraph of §2.7 to the degrees of (I3), as §9 "Other changes" records. Two passages still cover γ = 1 with the old reason.
   - §0 Answers (1): the proven range "is smaller for 1 ≤ γ < 2 − 1/H, where the cover's width threshold must be bridged". At γ = 1 the binding condition is the entropy degree D_H in (C5) (Case III). Bridging the threshold T_mf needs only θ < 1/(D_T+1), which is larger than 1/D_H.
   - Open problem 1: for 1 ≤ γ < 2 − 1/H, "the obstruction in the proof is Lemma 2.4, step 6". Lemma 2.4 is not used at γ = 1.

   *Fix:* restrict both statements to 1 < γ < 2 − 1/H and refer to open problem 6 for γ = 1.

4. **Bookkeeping in §1.6 and §9.**
   - §9 says "I accepted every issue, with three exceptions". The list omits the figure of computation I-6 (0.73–1.52), which the I-6 row corrects; that is the same kind of exception as the figure of logic 6, which is counted.
   - §9 says "Neither found a wrong step in the proofs". Computation E2 was a wrong justification inside the proof of Proposition 4.4: the displayed bound held, but the stated reason, H² ≥ 1, does not give it. "Neither found an error that affects a result" would be exact.
   - §1.6 says "Two clashes were removed in revision by renaming" (f\*, and m_ν, M_ν). The logic-10 row of §9 lists four renamings; c_mf and 𝓔_{δ_d} also removed clashes.

5. **`paper.tex` is not introduced as a short name.** It appears bare 11 times. §1.1 gives the full path `NNG/side-results/continuous-domains/source/paper.tex` once but never says that the bare name abbreviates it, so the bare name does not resolve from `research-notes/`. A writes "cited below as `paper.tex`", and B added the same after its round-1 check. *Fix:* add "(cited below as `paper.tex`)" at the first mention in §1.1.

6. **§1.6, entry c: "the likelihood ratio".** That term usually means a ratio of two likelihoods. The brief calls c the "ratio c" of SP_c, the ratio of the observation variance cσ² to the prior scale σ². *Fix:* "the variance ratio of the likelihood (observation variance cN^{−γ})".

*Optional.* §2.7 item 1 ends "for L = 2 no lower bound is given". Adding "here" would stop it being read as a claim about the other notes: `red-team.md` §5 gives a depth-two lower bound for strong-prior SP_c, and B §7.5 item 3 cites it. If E cites it, it must use its status: two referees found the proofs correct, but the sentence of its Corollary 5.2 about the "+o(1)" formulation is false for c → 0, and a repair is in progress.

## 2. What was verified

**(a) Referee issues.** §9 has one row per issue: logic 1–10 (8 split into (a), (b)), computation E1, E2 and I-1 to I-10 (I-4 split). I found each fix at the location its row gives, and each is correct. The three rebuttals are valid. For computation I-4, the pre-revision §3 bullet already required N ≥ (√(d+1)+t_L)². For logic 10, A's symbol list (its line 101) quotes E's "with B = ηn", so renaming η would break A's quotation, and the clash is now listed in §1.6. For logic 6, `robust_memorizer_det.py` prints the absolute dropped mass Σ|γ_j| over dropped features, so 0.173 is 0.88% of 𝒜 = 19.7, not 17%. No issue is left unaddressed.

**(b) Changed passages, re-derived** (`../checks/revision-check-E-2/check_E_r2.py`, output `check_E_r2.out`).
- *Remark 5.4a.* (1−2x)(1+e_d) − (1+e_d−4x) = 2x(1−e_d) ≥ 0, with x = e^{−N^γ} ≤ e^{−N} and e_d ≤ β_n ≤ 1. Also N ≥ N_* ≥ s_0 = 2^d, and e_d → β(1) > ε uniformly in N ≥ N_* and γ ≥ 1, so the (F0) event lies in 𝓔_{δ_d}^c. Correct, for z_w as well as clip z_w.
- *Corollary 5.3.* c_d ≤ c_d(dn_d)^{1/H} = o(2^d) gives a_d ≤ 1, and η_d = ε_fs/λ_d → 0. *Theorem 5.2(ii):* V ⊆ B_t^c and Π(V) > 0. *Remark 1.2:* sublevel sets are compact (B Lemma 3.1).
- *E1.* For general c the extra terms are 2cA/n + 2c ln(1/δ′)/(N^γ n) + N^γ/c (sympy residual 0), and Λ_N/n = N^γ/(2c). *E2:* the fifth term is a/(24H²) ≤ a/96, and the five terms sum to 37/96 < 0.39. *I-1:* (C1) gives h_n ≤ ε/32 and (C2) gives ε/8.
- *I-3 with the added 1.* Over a grid, the ratio of A_L − E_*/2 to (d+m)(1+ln(1/ρ)+ln(dmB)) is at most 6.7, 13.9, 23.9 and 36.7 for L = 2, …, 5, and A_L − E_*/2 = 27.71 at d = m = B = ρ = 1, L = 3.
- *I-5.* N_* = O_H(d²s/a² + d(ds)^{(H−1)/H}/a² + d a^{−(H+1)}) follows term by term from the definition; the grid ratio is bounded for each H, with constants that grow with H, as O_H allows.
- *γ_H.* (D_H−1)/(D_H−H) = 1.02000, 1.00692, 1.00231, 1.00077 for H = 2, …, 5. It lies below the route crossover, and θ_{L,γ} < 1/D_H holds exactly for 1 < γ < γ_H on a grid of 2·10⁵ points.
- *Other passages.* Remark 2.9(d) matches B Remark 8.2 (B′ = max{B,1}/tanh 1 ≥ 1). §5.4(a) at n = M gives the lower bound 2 − o(1) for a Gibbs draw and for the posterior means. In §7 item 4, 1 − Π_* = 0.394 and 0.538, Π_*·0.132 = Π_*·0.173 = 0.080, and the dropped mass is 0.15–0.88% of 𝒜.

**(c) No strengthening, nothing dropped.** The changes weaken claims (the title, "sharp", "at every width", "tends to 2", the capacity remark of §2.7, "this proves"), each declared in §9; add the proved Remark 5.4a; or add citations and immediate consequences (Remark 2.9(d)–(e), the general-c terms). The more specific §0 row 6 (probability 1 − e^{−2^{d/2}}, the expected Gibbs risk) follows from Corollary 5.3 and Theorem 5.2(i). Every item of the old §8 "Proved here" list remains. The one claim extended without recorded support is item 1 above.

**(d) Numbering.** All pre-revision headings, result labels, (G1)–(G5), (I1)–(I4) and the tags (1.1)–(5.1) are unchanged. The additions are §1.6, Remark 5.4a, Remark 2.9(d)–(e), open problems 7–8 and §9 with an unnumbered subsection; each is appended or lettered, so nothing moved.

**(e) Cross-references.**
- *A* (second revision): Lemmas 2.1 (K_mem, N_0(d,s,a)), 2.2(b),(e), 3.1(a), 4.1(a),(c), 4.2(b), 4.3(b)–(d); eq. (2.4), condition (4.4), Table 4.1; Theorem 4.4(i); Corollary 4.6 (η, √(32n log(1/δ))); §1.4, §5.1, the limit order of (1.2); Proposition 5.2 (fixed d, strong prior, every width); Proposition 6.1(a′) (upper bound, strong prior only); Remark 2.5 and Proposition 8.2 (energy linear in s up to factors polynomial in d); Lemma 6.4(a), Propositions 6.5, 6.6(b) and 6.6a, the paragraph of §6.2 after Lemma 6.2, and §10 item 6. All match.
- *B:* Lemmas 2.1(a), 2.2, 3.1, 4.2, 5.3(a); Theorem 6.3 (clipped, every N ≥ m, rate n^{−1/(H+2)}); Remark 8.2; §7.5 item 1 (polylogarithmic window, strong prior). All match.
- *C:* Theorem C.7 bounds the final posterior, with clipped outputs in the likelihood. Matches.
- *red-team.md §8* (stage): θ < (γ−1)/(2(L−2)); mean field open in both directions; m_0 first-layer groups and N(d+m_0+H) constraints. Matches. No red-team proposition with a restricted status is cited.
- *Sources:* `paper.tex` eq. `law` has constants m, M, with m = M = 1 for Gaussian coordinates; `meanfield.tex` Prop. `mf-cover` has the exponent cNK with c = min{1/4, m/16}. Both match.

**(f) Paths and outputs.** Every link and backticked path resolves from `research-notes/` except `../README.md`, `red-team.md` and `literature.md`, which may be missing for now. The four `NNG/` paths exist, there are no absolute paths, and bare script names occur only in §7, under its lead sentence. I re-ran all ten scripts into `../checks/revision-check-E-2/rerun/`: every output is byte-identical to `checks/E/*.out`, and the longest run took 91 s. Against the pre-revision outputs only `theta_table.out` differs, by the four new lines, as §7 says. Every number quoted in §§1.5, 4–7 and 9 matches the `.out` files of `checks/E/` and `checks/verify-E-computation/`, including all six configurations of `check_memoriser_insitu.out`, the 7 cases with Ξ ≤ 1, the ratio 0.253, and the referee's Table 7.1 differences (at most 1.1% in K_rob/n and 0.1 in log₁₀N_*), except item 1 above. To six digits the sampling-error extremes are 0.727092 and 1.514792 (`../checks/revision-check-E-2/samp6.py`), and the largest unrounded difference in e between the two Table 7.1 implementations is 2.97·10⁻⁵ (`../checks/revision-check-E-2/table/`), as §9 states.
