# Check of the revised Claim B note (round 1)

*Published record of a check of the revised note, made during finalization. Paths under `stage/` refer to the lead's unpublished working copies; the pre-revision text there is the version that the referee reports reviewed, published as [`B-first-version.md`](B-first-version.md). This check's scripts and outputs are in the `../checks/revision-check-*` folder named below. Re-runs of the note's own scripts, which some reports keep in a `rerun/` subfolder, are not published; each report says whether they reproduced the recorded outputs.*

**Document:** `research-notes/B-tempered-likelihood.md`, compared with the pre-revision text `stage/B-tempered-likelihood.md`. I read all 40 diff hunks against the three referee reports, the brief and `checks/B/`.

**Verdict: minor fixes.** The revision handles all 33 referee issues (logic 1–11, with 9 split into three; computation M1–M10; scope 1–10). Every changed number, exponent and new proof that I re-derived is correct. One issue is only partly fixed: logic 1, the depth-two case. Five other small problems remain:

- one overstatement;
- one reference to a phrase the revision removed;
- one quotation the brief does not contain;
- three new results numbered with plain integers, not primed or lettered;
- several script paths given as bare filenames.

## What was verified

- **(a) Referee issues.** Section 12 has one row per issue, and each fix is in the text where the row says. No issue was rebutted.
- **(b) Changed passages.** I re-derived each of the following.

  **Sections 0–4 and the opening of Section 6:**
  - the power posterior in §1, with $K_{\rm mem}=O(\sqrt n\log n)$ and $m_t=\lceil2(d+1)^3n^{3/2}\ln2\rceil+1$ in exact arithmetic;
  - the tightness argument for $\sigma\in[\sigma_1,1)$ in Corollary 3.2(3);
  - the three Lemma 4.2 inequalities: 2700 grid points with $L$ up to 1000 and 60-digit arithmetic, no violation; the termwise split first fails at $L=16$ when $d=K=1$, as the text says;
  - Remark 6.1a.

  **The rest of Section 6:**
  - the degrees of $n_0$ for each variable;
  - the first $n$ at which the displayed $\mathrm{Exc}_n$ is at most $0.1$: $10^{14.088}$, versus $10^{13.379}$ with $K=n^\theta+1$, and $\mathrm{Exc}_n=0.1463$ at $10^{13.4}$;
  - Remark 6.5.

  **Sections 7–9:**
  - the slowest term of $\varepsilon_n$ (asymptotically);
  - §7.5(4): the window $2\kappa<\theta<(1-\kappa)/H$, which is nonempty if and only if $\kappa<1/(2H+1)$;
  - the exponents of Corollary 8.1 at $H=1$ and $H\ge2$;
  - the bias conversion in Remark 8.2: 300 random nets give error $8\times10^{-15}$, and the weight bound $\max\{B,1\}/\tanh1$ is attained;
  - the proof of Proposition 9.1(c);
  - the definition of "works" in Corollary 9.3 and the new closing step of its proof;
  - the counterexample $g_R$ in the §9 Discussion;
  - the consistency argument of Remark 9.4: the chain bound $2\lvert f\rvert^3/(3R^2)$ holds with maximum ratio $0.991$.

  The script and its output are `../checks/revision-check-B-1/verify_changes.py` and `.out`, plus `verify_changes_part2.out`.
- **(c) Strength of claims.** No proved result was dropped. The changes either add qualifiers or add new remarks with complete proofs. The exceptions are issues 1 and 2 below.
- **(d) Numbering.** Every existing section and result keeps its number and order. The additions are Remark 6.1a, Remark 8.2, Remark 9.4 and §12 (issue 5).
- **(e) Paths and outputs.**
  - Every `../` path resolves.
  - I re-ran `sample_sizes.py` and `transition_window.py` from copies. Both outputs are byte-identical to the `.out` files, and `transition_window.out` is unchanged from before the revision.
  - All quoted values match their `.out` files:
    - route 2: $14.09$, $13.38$ and $29.23$;
    - route 1: $101.4$, $101.9$, $260.6$ and $54.0$;
    - `v_cube_twopoint.out`: $0, 0, 0, 0.328$ and $0.197, 0.364$;
    - `width_dependence.out`: $0.4697$ and $0.0286$;
    - every other value in the §10 table.

## Remaining issues (all minor)

1. **Proposition 9.1(c), concluding sentence (what remains of logic 1).** The sentence reads: "So, in the worst case over laws and for $\theta<1/H$, the competitor energy at which matching breaks down is of order $n^\theta$." At $H=1$ the range $\theta<1/H$ includes $\theta\in(1/2,1)$. There the matching half is not proved: the preceding sentence and the proof need $\theta\le1/2$.
   *Fix:* write "under these hypotheses".
2. **§9 Discussion.** The sentence "What decides matching is the energy-penalized population risk of Remark 6.5" goes beyond what is proved. Remark 6.5 is only an upper bound, so it gives a sufficient condition for matching. The sentence is also stronger than the scope referee's wording, "the relevant quantity".
   *Fix:* say that the bound of Remark 6.5 depends on the energy-penalized risk, not on the competitor's own energy.
3. **Remark 8.2.** It cites '"depth-$L$ MLPs" in Corollary 8.1', but the revision removed that phrase from Corollary 8.1.
   *Fix:* refer to the user's word "MLPs" instead.
4. **Remark 6.6.** The revision changed "the task" to "the brief (Claim D)". The quoted "$K^{L/2}/\sqrt n$" does not occur in the brief, which says only "$n^{1-1/(H+1)}$ (norm-based Rademacher bounds?)".
   *Fix:* drop the quotation marks and cite the brief's guess $c\sim n^{1-1/(H+1)}$.
5. **New labels use plain integers.** Remark 8.2, Remark 9.4 and §12 are new labels without a prime or letter. Each sits at the end of its section, so no existing reference breaks. Possible renaming: Remark 8.1a and Remark 9.3a.
6. **Bare script and file names.** These do not resolve from `research-notes/`:
   - `sample_sizes.out`, twice in §6, both in rewritten paragraphs;
   - `cover_degree.py` (§4);
   - `transition_window.py` (§7.5);
   - `noisy-interpolation/README.md` (Lemma 7.2).

   Section 12 uses the full `../checks/B/...` form, so these are inconsistent with it.

   Three linked files are absent for now and are expected under the planned layout: `A-tight-conditioning-fails.md`, `red-team.md` and `../README.md`.
7. **§1, fixed-$c$ paragraph.** "The excess is $\ge1/e-o(1)$" omits the probability qualifier of Proposition 7.3, which holds with probability $\ge1-e^{-n^{1/3}/2}$.
