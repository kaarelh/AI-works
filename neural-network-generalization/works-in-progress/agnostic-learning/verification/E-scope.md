# Scope referee report: `../research-notes/E-finite-prior-scale.md`, and the README draft's summary of it

*Published record of a scope referee report made during finalization, on the final text of the note and on the draft of the main README. Line numbers refer to those texts as of the review; links inside quoted replacement texts were adjusted to resolve from this folder. The README draft was revised in answer to this report before publication. The referee's scripts and outputs are in [`../checks/verify-E-scope/`](../checks/verify-E-scope/).*

*Lens: scope and adversarial interpretation. I read E in full (final text), brief §§1–4, the cited parts of A (§§0, 1.2–1.4, 4, 5, 6.2), B (§0, Lemma 5.3, Proposition 6.1, Theorems 6.3, 6.4, 7.4, §7.5, Corollaries 8.1, 9.3), `NNG/works-in-progress/slt-likelihood/README.md` §2 ("Finite scales"), `NNG/side-results/continuous-domains/source/paper.tex` (eqs. `law`, `finite-scales`, `A`; Proposition `tube`; Theorems `strong`, `finite`), `meanfield.tex` (Proposition `mf-cover` and the γ = 1 proof of Theorem `finite`), the finite-scale mentions in `depth-two.md` and `small-learner-width.md`, and the README draft (`the README draft (published, with these points answered, as ../README.md)`) intro, §2, §7, §9 and §11. Scripts and outputs: `../checks/verify-E-scope/scope_numbers.py` / `.out` and `../checks/verify-E-scope/alpha_range.py` / `.out`. Nothing in the repository was modified.*

**Verdict: major_flaw.** The flaw is in how the README draft reports E, not in E. E's theorems hold as stated, and E's own summaries are accurately scoped apart from the minor points below. The README draft's summary of E ("the picture is the same", intro item 6; "same picture as above", §2 table) claims that strong-prior results carry over to finite scale when E does not prove them: unclipped predictors, the conjecture's form with competitors of size n^α, the weight-bound results, the polylogarithmic sharpness, and the threshold θ = 1/H for 1 ≤ γ < 2 − 1/H, which includes mean field. It also leaves out that the γ = 1 case depends on an imported result. This needs rewording; nothing in E's mathematics needs to change.

---

## Issues

### 1. (major) README draft, intro item 6 (line 20) and §2 table, finite-scale row (line 61): "the picture is the same" / "same picture as above for L≥3, γ≥2−1/H" claim more than E proves

**What E proves at finite scale.**

- *Negative side.* For L ≥ 3, every γ ≥ 1 and c = 1, or c with c(d⁴+(dn)^{1/H}) = o(n): the learner memorizes on the noisy cube with d = log₂n, at widths N ≥ N_*(n) (Theorem 5.2, Corollaries 5.3–5.4, Remark 5.4a). This matches the strong-prior negative side.
- *Positive side.* Only two quantities are controlled: the posterior-averaged clipped loss E_Π L_D(clip z_w), and the loss of the mean of the clipped outputs, E_Π clip z_w. The conditions are θ < θ_{L,γ} and N ≥ m (Theorem 2.7; Remark 2.9(a),(b)).
  - At the widths covered by regime S, a single posterior draw is not controlled.
  - θ_{L,γ} = 1/H only for L = 2 or γ ≥ 2 − 1/H. For 1 ≤ γ < 2 − 1/H the proved range is much smaller: θ < 1/52 instead of 1/2 at L = 3, γ = 1; 1/292 instead of 1/3 at L = 4; 1/1300 instead of 1/4 at L = 5 (`scope_numbers.out`, Parts 1–2). It tends to 0 as γ ↓ 1; for example θ_{3,1.01} = 0.0098.
  - The window [θ_{L,γ}, 1/H) is open (E §6, open problems 1 and 6).
  - The γ = 1 case depends on the imported mean-field cover (I3). E §8 classifies it as "proved, conditional on an imported result that I checked only at the level of its statement and formulas".

**What E does not treat at finite scale, though the strong-prior "picture" contains it:**

- unclipped predictors, including the Bayes model average E_Π z_w (strong prior: θ < 1/L, B Theorem 6.4; README §2, row 3, "unclipped for θ<1/L");
- the conjecture's form, with competitors of width and weights at most n^α (B Corollary 8.1; README intro item 2 and §2, row 5). E's bounds as written would not even reproduce B's range α < 1/(4H) (issue 7);
- the weight-bound results (B Proposition 9.1 and Corollary 9.3; README intro item 4 and §2, row 5);
- the polylogarithmic narrowing of the transition (B §7.5; README intro item 3, "up to polylogarithmic factors"). E's §6 table says explicitly that this "is not done here";
- Claim A′ (E §5.4(c)).

**How the README overstates this.**

- Intro item 6 says "the picture is the same". The next sentence then says the threshold "is smaller, but positive, below that". It does not say that only the proved range is smaller and that the rest of the range is open. A reader can conclude either that the transition at 1/H is proved at every γ, mean field included, or that the true threshold is smaller there. Neither is established.
- The γ = 1 conditionality is missing from intro item 6 (README §7 has it).
- The §2 row's "same picture as above" carries over the "unclipped for θ<1/L" entry of row 3 and the whole n^α-competitor row 5, and neither is proved at finite scale.
- The §2 row says nothing at all about 1 ≤ γ < 2 − 1/H.

At the repository's flagship mean-field scale (γ = 1), a reader would come away believing that the strong-prior conclusions (sharp transition at θ = 1/H, the conjecture's form, the weight thresholds) are proved. They are not.

**Suggested replacement, intro item 6:**

> 6. **Finite prior scale.** With the repository's width-tied prior scale $\sigma^2=N^{-\gamma}$, $\gamma\ge1$ (Gaussian weights), and no limit taken, close conditioning still fails and tempering still works, but the sharp transition is reproduced only for $\gamma\ge2-1/H$. At depth $L\ge3$ the clean-label scaling $c=1$ memorizes at every $\gamma\ge1$, mean field included, on the same noisy-cube laws and at learner widths above a polynomial in $n$. Tempering with $\theta<\theta_{L,\gamma}$ gives the oracle inequality for the posterior-averaged test loss of the clipped outputs and for the posterior mean of the clipped outputs, at every learner width. $\theta_{L,\gamma}$ equals $1/H$ for $\gamma\ge2-1/H$. Below that the proved range is smaller, for example $\theta<1/52$ instead of $\theta<1/2$ at depth 3 and $\gamma=1$, where the proof also relies on an imported mean-field cover, and the range up to $1/H$ is open. Unclipped predictions and the conjecture's form of item 2 are not treated at finite scale (§7).

**Suggested replacement, §2 finite-scale row:**

> | Gaussian learner at finite prior scale: prior $\mu_{N,\gamma}$, $\gamma\ge1$, likelihood variance $cN^{-\gamma}$, no limit | tempered or close | for $c=n^{1-\theta}$, **holds** for clipped predictions (posterior-averaged loss; mean of the clipped outputs) at every learner width $N\ge m$ when $\theta<\theta_{L,\gamma}$, where $\theta_{L,\gamma}=1/H$ for $L=2$ or $\gamma\ge2-1/H$ and is smaller below ($\gamma=1$ via an imported cover); at depth $L\ge3$, **fails** for $c=1$ and for $\theta>1/H$, at every $\gamma\ge1$; unclipped predictions and the $n^\alpha$ competitor classes are not treated | §7; [E](../research-notes/E-finite-prior-scale.md) Thms 2.7, 5.2, Cor 5.4, Rem 5.4a |

### 2. (minor) README draft, §2 table, finite-scale row: depth qualifier, learner name and citation

- **Depth.** "c=1 fails at every γ≥1" needs "at depth L ≥ 3". E shows no failure at depth two (§6 table: "none shown here"). The depth-two failure of `depth-two.md` (c ≤ polylog n) is proved only in the strong-prior limit. The semicolon in the row lets "for L≥3" be read as covering only the first clause.
- **Learner name.** README §1 defines SP_c with the limit σ → 0 taken. "SP_c at finite prior scale" therefore names a different learner with the same label.
- **Citation.** The refutation of (P_L) is E Corollary 5.4 and Remark 5.4a, not only Theorem 5.2.

*Fix:* covered by the replacement row in issue 1.

### 3. (minor) README draft, §7, first paragraph: what "the repository's finite-scale" learner is

- "The results above take the strong-prior limit σ→0" is wrong for §6: Theorem C uses μ_{N,γ}.
- E treats only Gaussian coordinates (Lemma 1.1). The repository's finite-scale prior allows the coordinate laws of `paper.tex` eq. `law`.
- The repository has two finite-scale theorems, which use different learners:
  - `paper.tex` Theorem `finite` uses the TUBE likelihood. E treats TUBE only through A's prior-free statements (Remark 2.9(e)).
  - E's learner at c = 1 is exactly the finite-scale learner of `slt-likelihood/README.md` §2: Gaussian μ_{N,γ}, observation variance N^{−γ}. I checked both definitions, and they agree.

*Fix:* "The results of §§3–5 take the strong-prior limit … The repository's finite-scale prior μ_{N,γ}, with Gaussian weights, instead ties the scale to the width … With likelihood variance cN^{−γ} (c = 1 is the finite-scale learner of the smooth-likelihood note) the posterior is proportional to exp(−N^γF_c/2) …"

### 4. (minor) README draft, §7, Theorem E, positive bullet: "the Gibbs risk of the clipped outputs"

- **Ambiguity.** README §1 calls a posterior draw "Gibbs". "The Gibbs risk … at most L_D(g)+ε" can therefore be read as a bound on a single draw. E controls only the posterior expectation at the widths covered by its PAC-Bayes bound (N^γ ≲ εn^{1−θ}); at larger widths the bad posterior mass is at most ε/32 (Remark 2.9(b)).
- **Missing caveats about γ ↓ 1 (optional).** The polynomial depends on (L, γ, θ). Its degree blows up as γ ↓ 1. For 1 < γ < γ_H (1.020 at L = 3) the proved threshold lies below its value at γ = 1 (E §6).

*Fix:* "… the posterior-averaged test loss of the clipped outputs (at small learner widths only this average, not a single draw, is controlled) and the test loss of the posterior mean of the clipped outputs are at most L_D(g)+ε …". Optionally add the γ ↓ 1 caveats.

### 5. (minor) E §0 row 6, Answers (2), and README §7 negative bullet: "n ≍ 2^d" with "β(λ)"

λ is never defined there. The limit 1 + β(λ) − o(1) of Corollary 5.3 needs n_d/2^d → λ ∈ (0,∞). If n/2^d only stays bounded and oscillates, "β(λ)" has no meaning; the true statement is then 1 + β(n/2^d) − o(1).

*Fix:* "with n/2^d → λ ∈ (0,∞)" in all three places.

### 6. (minor) README draft, §7, "So for L≥3 and γ≥2−1/H the finite-scale learner has the same critical tempering c≈n^{1−1/H} as the strong-prior limit", and the "Open:" sentence

**The "critical tempering" sentence.**

- Intro item 3 defines the critical tempering as "c≈n^{1−1/H}, up to polylogarithmic factors". At finite scale the positive side is shown only for c = n^{1−θ} with fixed θ < 1/H, so only the exponent is shared.
- The negative side is in fact polylog-sharp, since (5.1) covers c = o(n^{1−1/H}(log n)^{−1/H}). The positive side is not, and E's §6 table says so.
- The sentence also drops the qualifiers that make the dichotomy true: clipped predictors, worst case over laws, and failure only with d = log₂n and widths N ≥ N_*(n).

*Fix:* "So for L ≥ 3, γ ≥ 2 − 1/H and clipped predictions, the finite-scale learner has the same critical exponent θ = 1/H as the strong-prior limit, in the worst case over laws (the failure uses d = log₂n and learner widths above a polynomial in n). The polylogarithmic narrowing of the strong-prior transition is not established at finite scale."

**The "Open:" sentence.**

- It should also list the endpoint θ = 1/H and Claim A′ at finite scale; README §11 item 6 lists A′.
- It should use the same bracket as §11: [θ_{L,γ}, 1/H) with the endpoint listed separately, or [θ_{L,γ}, 1/H] in both places.

### 7. (minor) E §2.1, paragraph after Lemma 2.1, and Remark 2.8, last sentence (also §2.7 item 1, first bullet): the (U+2)² energy budget is an artifact of the proof, and Remark 2.8 understates the gap with B

**Where the factor comes from.** Lemma 2.1(c) bounds the normaliser with the competitor's tube. This forces the budget K ≳ 8A + 4n^θ(U+2)², with U = mB (Lemmas 2.3, 2.5, 2.6).

**Why it is avoidable.**

- The posterior Π_{N,S} does not depend on g.
- Lower-bound the normaliser instead with the zero network's tube: (I1) with width 1, weights 0, B = 1 and ρ₀ = 1/2. This gives Π(G^c) ≤ μ(G^c)·exp(N^γ[A₀ + (9/8)n^θ]), with A₀ = A_L(d,1,1,1/2).
- The resulting energy budget, 8A₀ + 9n^θ + 8 ln(64/ε), is independent of (m, B).
- The competitor's tube is still needed for Lemma 2.1(b), the training-loss control, and that use is unchanged.

**Consequences for the text.**

- (a) §2.1's "A Borel set of prior mass e^{−N^γK/8} is negligible under the posterior only if K≳4n^θ(U+2)²" states a requirement of this proof route as if it were necessary. For large U it is false as a necessity claim. The same applies to "only if K≳4n(U+2)²" in §2.7.
- (b) Remark 2.8 says "Only the logarithmic factor from A_L(ρ) is new". The exponent of n is indeed B's. But E's capacity term exceeds B's by at least (2(U+2)²)^{H/2}: 18 at H = 2, U = 1; 288 at U = 10; 4.9·10³ at H = 3, U = 10 (`alpha_range.out`). In addition, K̄ contains 8A ≥ 4E_*. So the poly(d,m,B) prefactor is polynomially worse, not only by a logarithm.
- (c) For the conjecture's form (m, B ≤ n^α), Remark 2.8's bound in Case I reaches only α < 1/(8H), against B Corollary 8.1's α < 1/(4H). With the zero-network budget it would reach 1/(4H). The grid search in `alpha_range.out` gives 0.0625 / 0.125 at H = 2 and 0.0417 / 0.0833 at H = 3.

**Effect on E's results.** None: θ_{L,γ} depends only on exponents of n.

**Fix.**

- Reword (a): "with the competitor's tube as the normaliser bound, a set of prior mass e^{−N^γK/8} is shown negligible once K ≳ 4n^θ(U+2)²; comparing with the zero network's tube gives a competitor-free budget of order n^θ".
- Reword (b): "the exponent of n is that of B; the logarithmic factor from A_L(ρ) and a larger (d, m, B) prefactor, from K̄ ∋ 4n^θ(U+2)², are new".
- Optionally add the zero-network comparison to Lemma 2.1(c).

### 8. (minor) E §0 row 7, Answers (1) and §6: the "sharp" dichotomy is asymptotic and, for the tempered learner, a large-width phenomenon

Neither point is false in E, but neither is stated, and both matter to how a skeptic reads "θ > 1/H fails".

**(a) Asymptotic.** Near θ = 1/H the certified excess of Theorem 5.2 vanishes until d is in the hundreds. With E's own constants and Corollary 5.3's schedule (a_d, δ_d):

| H | θ | e = 0 up to | certified excess e |
|---|---|---|---|
| 2 | 0.55 | d = 100 | 0.060 at d = 200, 0.462 at d = 400 |
| 2 | 0.60 | d = 50 | 0.101 at d = 100 |
| 3 | 0.36 | d = 200 | 0.178 at d = 400, 0.474 at d = 800 |

Source: `scope_numbers.out`, Parts 4 and 4b. B states the analogous caveat after its Theorem 7.4; E does not.

**(b) Large-width.** Lemma 2.2 (regime S) and conditions (C1)–(C2) hold for every θ ∈ (0,1). So for θ ∈ (1/H, 1) the finite-scale learner satisfies the oracle inequality for the expected clipped Gibbs risk at all widths with N^γ ≤ εn^{1−θ}/4. The failure at θ > 1/H is therefore confined to large widths, just like the c = 1 failure (README §8). E defines "fails" with N ≥ N_*(n), which is correct, but never notes this complementary small-width success.

**Fix:** add to §6, after the table: "The failure side is asymptotic: near θ = 1/H the certified excess of Theorem 5.2 is zero until d is in the hundreds (H = 2, θ = 0.55: 0 at d = 100, 0.06 at d = 200, 0.46 at d = 400). It is also a large-width phenomenon: for every θ < 1, Lemma 2.2 gives the oracle inequality for the expected clipped Gibbs risk at every width with N^γ ≤ εn^{1−θ}/4, including θ > 1/H."

### 9. (minor) E §0 row 7 and Answers (1), first sentence: the γ = 1 conditionality is not restated

Row 2, Theorem 2.7, the §6 table ("via (I3)") and §8 all mark the γ = 1, L ≥ 3 positive case as relying on (I3). Row 7 does not: "For 1≤γ<2−1/H, θ<θ_{L,γ} works".

*Fix:* "… θ < θ_{L,γ} works (at γ = 1 conditionally on the imported mean-field cover (I3)) …".

### 10. (minor; outside the three requested README locations) README draft §9, "What holds", and §11 item 6

- **§9.** It says "the same holds at the repository's finite prior scale (§7) … provided the likelihood is tempered by a factor c≈n^{1−θ} with θ<1/H". At finite scale, θ < 1/H is shown only for γ ≥ 2 − 1/H, and only for clipped predictors.
  - *Fix:* "… and, for clipped predictions, the same holds at the repository's finite prior scale for θ < θ_{L,γ}, which equals 1/H when γ ≥ 2 − 1/H (§7)".
- **§11 item 6.** It says the window "needs either a better mean-field cover at γ=1 or a way past the width threshold of spectral truncation". E says only that these are the obstructions in its proof and the natural routes (open problems 1 and 6). A different proof might avoid both.
  - *Fix:* "which would follow from either …" instead of "which needs either …".

### 11. (minor, nit) E Lemma 1.1, paragraph after the proof, and open problem 5: "For the non-Gaussian coordinate laws … the identity in (b) fails"

Only the Lebesgue-density form e^{−N^γF_{c,S}/2} needs Gaussian coordinates. The form Π ∝ e^{−Λ_N L̂_S} μ_{N,γ} holds for every prior, and Lemmas 2.1, 2.2 and 5.1 use only that form. The Gaussian restriction comes from (G1)–(G4), Lemma 2.3's χ² law, Proposition 4.4's Gaussian noise, and the constants of (I1)–(I3).

*Fix:* "the first expression in (b) fails; the second holds for every prior, but (G1)–(G4) and the constants of (I1)–(I3) change".

---

## What I checked, and what holds

**The learner.**

- E's posterior, with prior μ_{N,γ} (variances N^{1−γ}/d, N^{−γ}, N^{−γ−1}), likelihood N(z_w, cN^{−γ}) and no limit, is exactly SP_c at σ² = N^{−γ}.
- At c = 1 it is the learner of the finite-scale theorem of `slt-likelihood/README.md` §2: "Gaussian finite-scale weight prior μ_{N,γ} … Gaussian observation variance N^{−γ}".
- Its prior is `paper.tex` eq. `finite-scales` with Gaussian ξ.
- `paper.tex` Theorem `finite` itself uses the TUBE likelihood and general coordinate laws. E does not claim to treat that learner, beyond A's prior-free TUBE results (Remark 2.9(e)). I checked those against A §6.2: Lemma 6.4(a), Proposition 6.5 (N ≥ N₀(d,n,ρ/2)) and Proposition 6.6a, under either repository prior, at every scale, tolerance and width.

**The negative side, "every γ ≥ 1, every width above a polynomial, stated probability".**

- I re-traced Proposition 4.4 → Lemma 5.1 → Theorem 5.2 → Corollaries 5.3–5.4 and Remark 5.4a.
- N_*, the event E_δ and the "large d" threshold do not depend on γ or N, so the statement is uniform in γ ≥ 1 and N ≥ N_*.
- The sample probability 1 − e^{−2^{d/2}} (δ_d) and the posterior probability 1 − 2e^{−N^γ} (t = 1) are as stated.
- N_*(d, 2^d, a_d, H) ≥ 2^d at every tested (H, d), which is what Remark 5.4a uses. Its degree in n is about 1.7 at large d for H ≤ 4 (2.5 for H = 6), and 2.4–6.8 at d = 30 (`scope_numbers.out`, Part 3).
- The same predictors appear on both sides of the dichotomy: (F0) is refuted by Remark 5.4a, and the mean of the clipped outputs by Corollary 5.4 (F2).
- Corollary 5.4 covers c = n^{1−θ} for every θ > 1/H, including θ ≥ 1.
- E correctly says that no failure is shown at fixed d (A Proposition 5.2: the cube family is consistent at every width in the strong-prior limit) or below N_*.
- My re-implementation of Theorem 5.2's certified e (mpmath, from the formulas of Proposition 4.4 and Theorem 5.2) reproduces Table 7.1 exactly at c = 1 (0.4171, 0.4718, 0.4844, 0.3885, 0.4748, 0.4847).

**The positive side.**

- θ_{L,γ} is as stated.
- On (1, 2 − 1/H), max H·θ_{L,γ} = 0.9995 < 1 on a grid (Part 1), so "< 1/H" there is correct.
- θ_{L,γ} = 1/H at γ = 2 − 1/H via route (ii).
- D_T = 4·3^{L−1} and D_H = 4 + 16(L−2)3^{L−2} agree with `meanfield.tex` (G_ℓ tower, eq. `T`, J, P).
- 1/D_H < 1/(D_T + 1), as E says.
- γ_H = (D_H − 1)/(D_H − H) = 1.0200, 1.0069, 1.0023.
- The event of Theorem 2.7 is uniform over N ≥ m: a countable union of PAC-Bayes events with δ_N = δ/(4N²).
- Lemma 2.2's arithmetic is correct: Hoeffding's lemma, then Donsker–Varadhan, then the Gibbs identity.
- The clipped-only and expected-Gibbs-only scope is stated in E (§0 row 2; Remark 2.9(a),(b)).

**Consistency with A and B.** I found no contradiction.

- B's θ > 1/H failure with excess 1/e − o(1) and E's (and A's) β(1) − o(1) are both valid lower bounds; they differ only in how Q is bounded (B uses Q ≥ S₁).
- A §5.4, A Remark 4.9 and A §0.1 describe E consistently.
- B §0 leaves Claim E open, consistently with E.
- E's transfer to the MAP (Remark 1.2) is valid: A Theorem 4.4(i) and B Proposition 6.1, statement 1, are prior-free, and argmin F_{c,S} ⊆ N_t.
- At depth two, E's θ_{2,γ} = 1 does not conflict with `depth-two.md`: c = n^{1−θ} ≫ polylog n there. Nor does it conflict with depth-two Remark 5.7a's two-point failure for c ≥ n^{1−o(1)}, since E's polynomial has degree 2/θ in B.

**Files.**

- `../checks/verify-E-scope/scope_numbers.py` and `.out`: Parts 1–4b, covering θ_{L,γ} ratios, cover degrees, N_* degrees and certified excess for θ > 1/H.
- `../checks/verify-E-scope/alpha_range.py` and `.out`: α ranges for the conjecture's form under B's budget, E's budget as written, and E with the zero-network normaliser; capacity-term prefactor ratios.
