# Check of the revised Claim E note (round 1)

*Published record of a check of the revised note, made during finalization. Paths under `stage/` refer to the lead's unpublished working copies; the pre-revision text there is the version that the referee reports reviewed, published as [`E-first-version.md`](E-first-version.md). This check's scripts and outputs are in the `../checks/revision-check-*` folder named below. Re-runs of the note's own scripts, which some reports keep in a `rerun/` subfolder, are not published; each report says whether they reproduced the recorded outputs.*

**Document:** `research-notes/E-finite-prior-scale.md` (777 lines; timestamp 16:32, unchanged during the check), compared with the pre-revision text `stage/E-finite-prior-scale.md` (691 lines, 329 diff lines). I read the whole revised note, every diff hunk, both referee reports (`verification/E-logic.md`, `verification/E-computation.md`), the cited items of the current A (the second revision in `research-notes/`), B, C, `stage/red-team.md` §8, the brief, the cited repository sources (`paper.tex` eq. `law`, `meanfield.tex` Prop. `mf-cover`), and `checks/E/`.

**Verdict: minor fixes.** Every referee issue is resolved, either fixed or validly rebutted. Every changed statement, constant and exponent that I re-derived is correct, and the one new result, Remark 5.4a, is proved correctly. No claim was strengthened, and no proved result was dropped. What remains is small: one summary of the referee's simulation leaves out a configuration, two quoted numbers are slightly off, bare script names do not resolve, one O-term misses a corner case, and the new symbol list (§1.6) is incomplete.

## 1. Remaining problems (all minor)

1. **§7 item 4, last bullet (line 684): the summary leaves out one configuration of the referee's simulation.** "The error decreased with N in every configuration, to 0.016 at (H,γ)=(2,1) and 0.035 at (3,1)." The value 0.035 comes from the (3,1) run with R=4. In the (3,1) run with R=30, `check_memoriser_insitu.out` gives errors 1.27 at N=10^6 and 0.28 at N=10^7. The referee explains this as expected, because N must exceed about R^{2H−2}ℓ_d/a². Logic issue 6 was about selective reporting in this same item, so this case should be stated. *Fix:* add "(with R=4; with R=30 the error is 1.27 at N=10^6 and 0.28 at N=10^7, since N must exceed about R^{2H−2}ℓ_d/a²)".
2. **Two quoted numbers are slightly off.**
   - Line 670 gives the sampling error as "0.73–1.52". The unrounded maximum is 1.514792 (`../checks/revision-check-E-1/rerun`, printed to 6 digits), so the range is 0.73–1.51. The 1.52 comes from rounding the printed 1.515 a second time; the referee's I-6 has the same slip.
   - Line 699 says the referee's K_rob/n and log₁₀N_* "differ from the table in the last printed digit". At (H,d)=(3,30), K_rob/n is 3.56·10⁻³ against 3.60·10⁻³, so two printed digits differ (1%). *Fix:* "differ by at most 1% (K_rob/n) and 0.1 (log₁₀N_*)".
   - The claim "agrees to within 10⁻⁴ in e" is correct. I recomputed both implementations unrounded, and the largest difference is 3.0·10⁻⁵.
3. **Bare script names do not resolve from `research-notes/`.** They appear at lines 88, 221, 395, 404, 453, 591, 638 (the new §6 paragraph), 642, 747, 749 and 767. The round-1 check of B flagged the same issue, and B fixed it. *Fix:* write `../checks/E/<name>`, or keep bare names only under a sentence that names the folder, as in §7.
4. **§3, first consequence (line 372): the O-form of A_L fails in a corner case.** The text writes A_L = ½E_* + O_L((d+m)(ln(1/ρ)+ln(dmB))). At d=m=B=1 and ρ=1 the bracket is 0, while A_L − E_*/2 = 27.7 at L=3. *Fix:* O_L((d+m)(1+ln(1/ρ)+ln(dmB))). The referee's suggested form has the same gap.
5. **The new §1.6 is incomplete, and one docstring phrase is stale.**
   - §1.6 says that it "gives each meaning", but it omits several:
     - §5.2 defines β_n with K ~ Bin(n,1/M), and two lines later Theorem 5.2 sets K = K_rob;
     - M and e are also the generic polynomial and exponent in "Polylogarithmic factors" (line 313), and M_i appears in Case II;
     - E_ℓ := R^{H+1−ℓ}e_ℓ in Lemma 4.3 is missing.
   - The docstring of `checks/E/robust_memorizer_det.py` still says that the script reports "the deterministic noisy-chain prediction". The script does not print it.

## 2. What was verified

**(a) Referee issues.** The Referee record (§9) has one row for each issue: logic 1–10, with 8 split into (a) and (b); computation E1, E2 and I-1 to I-10, with I-4 split. I found each fix where its row says it is, and each fix is correct.
- *Rebuttal, computation I-4 for §3.* This is valid. The pre-revision bullet already required N ≥ (√(d+1)+t_L)².
- *Correction of logic 6, "17%".* This is valid. `robust_memorizer_det.py` prints `dropped = Σ_dropped|γ_j|` against A = Σ|γ_j|, so 0.173/19.7 = 0.88%.
- *Rebuttal of the η renaming in logic 10.* This is acceptable. A's lines 101 and 1258 quote E's "with B=ηn". The two η never occur in one argument, and the clash is now listed in §1.6.
- No issue is left unaddressed.

**(b) Changed passages, re-derived.** My script is `../checks/revision-check-E-1/check_E_r1.py`, with output `check_E_r1.out`.
- **Remark 5.4a.** (1−2e^{−N^γ})(1+e_d) ≥ 1+e_d−4e^{−N} holds because e_d ≤ β_n ≤ 1 and N^γ ≥ N. N_* ≥ 256A_max²ℓ_d/a_d² ≥ s_0 = 2^d. The bound is uniform in N ≥ N_* and γ ≥ 1, so the (F0) event lies in 𝓔_{δ_d}^c. The dichotomy of §6 now compares the same predictors.
- **Corollary 5.3.** (5.1) implies c_d ≤ c_d d⁴ = o(2^d). Hence a_d → 0, η_d → 0, and the "for all large d" qualifier holds.
- **Theorem 5.2(ii).** V ⊆ B_t^c, since R_S ≤ R_V on V, and Π(V) > 0.
- **Remark 1.2.** A minimiser exists, because F is continuous and its sublevel sets are compact.
- **E1.** The extra terms for general c are 2cA/n + 2c ln(1/δ′)/(N^γ n) + N^γ/c (symbolic residual 0). At c=1 the variance term is N^γ ≥ 1.
- **E2.** The five Ξ terms sum to 37/96 = 0.385 at H ≥ 2, and to 5/12 at H = 1.
- **I-1.** The slack is h_n ≤ ε/32 from (C1), and ε/8 from (C2).
- **I-5.** N_* = O_H(d²s/a² + d(ds)^{(H−1)/H}/a² + d a^{−(H+1)}). The grid ratio is bounded by a constant per H.
- **γ_H.** γ_H = (D_H−1)/(D_H−H) = 1.02000, 1.00692, 1.00231 and 1.00077 for H = 2, …, 5. It lies below the route crossover 2−2/H+1/H², so θ_{L,γ} < 1/D_H holds exactly when 1 < γ < γ_H (grid check).
- **Other passages.** These are correct:
  - the dropped-mass statements in §7 item 4 (below 1% of A; Π_*·0.132 = Π_*·0.173 = 0.080);
  - the naive errors against (1−Π_*) = 0.39 and 0.54;
  - Π_*·(sampling error) ≈ the noisy median in all six sampled runs, which supports "sampling error dominates";
  - Remark 2.9(d) (B Remark 8.2);
  - the (I3) remark (11 against 36 at L=3, from `check_degrees_theta.out`);
  - §5.4(a), lower bound only.

**(c) No strengthening.** The changes are of three kinds:
- Weakened, and declared in §9: the title, "sharp", "at every width", "tends to 2", and the capacity-bound remark.
- New and proved: Remark 5.4a.
- New, and only citations or immediate consequences: Remark 2.9(d)–(e) and the general-c terms.

Nothing proved in the old text was removed.

**(d) Numbering.** All pre-revision section numbers, result labels and equation tags (1.1)–(5.1) are unchanged. The additions are:
- Remark 5.4a and the reading (F0);
- Remark 2.9(d)–(e) and open problems 7–8;
- §1.6 and §9, both appended after the last existing item, so nothing moved.

**(e) Cross-references.**
- **A** (second revision, `research-notes/`):
  - Lemmas 2.1, 2.2(b),(e), 3.1(a), 4.1(a),(c), 4.2(b), 4.3(b)–(d);
  - eq. (2.4), condition (4.4), Table 4.1;
  - Theorem 4.4(i), Corollary 4.6, Remark 2.5;
  - §1.4, §5.1 (P_L), Proposition 5.2 (fixed d, strong prior), Proposition 6.1(a′) (upper bound, strong prior only), Proposition 8.2;
  - Lemma 6.4(a), Propositions 6.5, 6.6(b), 6.6a, §6.2 and §10 item 6.
  All match.
- **B:** Lemmas 2.1(a), 2.2, 3.1, 4.2, 5.2, 5.3(a), Theorem 6.3 (rate n^{−1/(H+2)}), Remark 8.2, §7.5 (polylog window, strong prior). All match.
- **C:** Theorem C.7 is the final-posterior bound with clipped outputs in the likelihood (φ_w = clip∘z_w). This matches.
- **red-team.md:** only §8 is cited, and its content matches (θ < (γ−1)/(2(L−2)); mean field open in both directions; N(d+m_0+H) constraints). None of the red-team propositions with a restricted status is cited.
- **Sources:** `paper.tex` eq. `law` has constants m, M; `meanfield.tex` has c = min{1/4, m/16}. Both match.

**(f) Paths and outputs.**
- Every `../` path resolves except `../README.md`, which is expected. `red-team.md` is absent, also expected. All four `NNG/` paths exist, and there are no absolute paths. For bare script names, see item 3.
- I re-ran all ten scripts into `../checks/revision-check-E-1/rerun/`. The outputs are byte-identical to `checks/E/*.out`, and the longest run took 106 s.
- The pre-revision outputs (`stage/E_timing`) differ only in the four new lines of `theta_table.out`, as §7 states.
- Every number quoted in §§0, 4, 5 and 7 matches the `.out` files and the referee's outputs, except the two in item 2.
