# Check of the revised Claim C note (round 2)

*Published record of a check of the revised note, made during finalization. Paths under `stage/` refer to the lead's unpublished working copies; the pre-revision text there is the version that the referee reports reviewed, published as [`C-first-version.md`](C-first-version.md). This check's scripts and outputs are in the `../checks/revision-check-*` folder named below. Re-runs of the note's own scripts, which some reports keep in a `rerun/` subfolder, are not published; each report says whether they reproduced the recorded outputs.*

**Document:** `research-notes/C-fixed-temperature-bayes.md`, 670 lines. I compared it with the pre-revision text `stage/C-fixed-temperature-bayes.md` (592 lines) and checked it against:

- the two referee reports, `verification/C-logic.md` and `verification/C-computation.md`;
- the brief, `research-notes/problem-brief.md` (§1, §2 and §4 match the staged copy);
- `B-tempered-likelihood.md` §1, the only other note that C cites;
- the cited repository sources;
- `checks/C/`, the referees' check folders, and the round-1 report `C-revision-check-1.md`.

**Verdict: minor fixes.**

- The revision resolves every issue in both referee reports and the three points of the round-1 check.
- Every new proof, constant, exponent and quoted number that I re-derived is correct.
- Numbering, paths and script outputs are in order.

Three small wording problems remain. None affects a theorem.

## Remaining problems

1. **"Neither fact is used below" is now false (§C.1.2, line 54).** The sentence refers to $m_\nu\le1\le M_\nu$. The revision now uses $m_\nu\le1$ in two places:
   - the explicit $K_1$ of Corollary C.2.2, which writes $\log(16/\sqrt{m_\nu})$ for the $\log(16/\min\{1,\sqrt{m_\nu}\})$ of (C.3.3);
   - the parenthesis "(which equals $\sqrt{m_\nu}$, since $m_\nu\le1$)" in Appendix C.A, Step 1.

   $K_1$ is correct, because $m_\nu\le1$ is proved on that same line by Brascamp–Lieb. Only the sentence is wrong.

   *Fix:* say that the first fact is used only in $K_1$ and in Appendix C.A, Step 1, or write $K_1$ with $\min\{1,\sqrt{m_\nu}\}$.

2. **C.9, first bullet of the proved list.** The bullet says "By Remark 3 after it, the likelihood may also use the unclipped outputs". Read literally, it says that Theorem C.1 holds as stated for the unclipped likelihood, and that is false. Remark 3 proves the theorem only with $\int L_D(z_w)\,dQ$ in place of $\int L_D(\phi_w)\,dQ$.

   A counterexample to the literal reading: $\mu$ uniform on two points, $z_{w_1}\equiv10$, $z_{w_2}\equiv-1$, $y\equiv1$, $\eta=1/8$, and $Q=\delta_{w_1}$. Then $\sum_{t<50}(\hat f_t-y)^2=197$, while the clipped comparison term gives $8\log2=5.5$.

   *Fix:* add "with $\int L_D(z_w)\,dQ$ in the comparison term". The Referee record (row C2) and "Relation to SP$_c$" already state it this way.

3. **Predictor lists (trivial).**
   - C.0, first paragraph: "All predictors studied here are built from the clipped outputs" is contradicted by Theorem C.5(e) and by Remark 3, which study unclipped predictors. Item 4 of C.0 mentions them too. "All predictors of the positive results" would be accurate.
   - Theorem C.5(e) lists $\bar z_t$, $\operatorname{clip}\bar z_t$ and the progressive mixtures of either. It does not list the clip of the progressive mixture, which C.0, Remark 3 and C.9 discuss. Its proof covers that predictor ("clipping and averaging over $t$ do not increase the supremum norm").

   A bookkeeping point in the Referee record: no row's "where" column lists the new "clipped outputs" qualifiers in the C.9 bullets on Theorems C.1 and C.2. They belong to logic 2.

## What was verified

**(a) Referee issues.** The Referee record has 21 rows:

- logic 1–10, with issue 7 split into three rows;
- computation C1–C7, with C6 split into three rows.

Every fix is in the place its row names, and each is correct. Some details:

- **Logic 10.** $\lambda$ was left unchanged with a valid reason: the referee's three uses lie in separate proofs.
- **Not rebutted.** No issue was rebutted.
- **Extra points.** The two points taken from outside the issue lists match C-computation §2.4–2.5: the adversarial ratio $0.49$ (`v_lemma_c61_exact.out` prints $0.493$) and the explicit $K$.
- **Round 1.** Its three points are resolved as the "Check of the revision" table says. The likelihood-ratio argument recorded there is correct: $\eta n<0.01675$, so $|\hat f|\le0.0693$ and the excess is at least $0.866$.
- **Unaddressed.** No referee issue remains unaddressed.

**(b) Changed passages.** I re-derived each one by hand and recomputed it in `../checks/revision-check-C-2/check_C_r2.py` (output in `check_C_r2.out`):

- **Remark 3, the two-point example.**
  - Bounds: $0.504$, $0.0549$, $5.54\cdot10^{-3}$.
  - Losses: $2.712$ and $2.706\cdot10^6$; the loss $4$ holds for every $n\le100$ (in fact up to $n=399$), and the violation holds exactly for $1\le n\le100$.
  - $30.25$, $4$ and $1.7526$.
  - The lower bound $((M-1)/2-n)/(n+1)\ge1$ holds iff $n\le249$.
  - The logic script prints exactly the values the paragraph attributes to it.
- **Remark 3, the unclipped likelihood.**
  - The proof steps: (C.1.1) before Jensen; the extension of (C.2.1) to $h$ bounded above via $h\vee(-k)$; Tonelli in the ghost-sample step; Minkowski on $U_\rho$.
  - Numerics: no violation in 400 random sequences with outputs up to $\pm10$, and none in 8,174 comparisons with $Q$.
- **Theorem C.5(e).**
  - Proof: $\Sigma_N$ from Lemma C.6.1(ii)–(iii) with the KL bound monotone in $t$; Cauchy–Schwarz; Fubini, which is justified by $\iint z^2\le\Sigma_N$; Jensen pointwise.
  - In an exact 1-D model, the largest ratios to the three bounds were $0.72$, $0.33$ and $0.32$, and there was no violation of the lower bound.
- **Theorem C.5(d).**
  - $16(4+\sqrt2)=86.63<87$; over 200,000 random $(m_\nu,\eta,k_n\ge1)$ the largest ratio was $86.3$.
  - The ratio at $n=10^6$, $10^8$ and $10^{12}$ is $20929.4$, $20910.6$ and $20908.5$, against $64A_L=20908.5$ with $A_L=326.70$.
  - An excess of order $(A_LN^\gamma/\eta n)^2$ below the threshold is consistent with everything proved.
- **Proposition C.3(c).**
  - The root is $(\sqrt6-\sqrt2)/8$, and the constant is $(2-\sqrt3)/16=0.016747$.
  - The step $\sigma^2\sqrt{2k_n}=\sqrt{2\sigma^2u}\le\sqrt{2u}$ is correct.
  - The referee's example gives $\sigma^2\sqrt{2k_n}=0.354$. The new sentence says only that part (b) alone does not give the implication, which is correct.
- **Corollary C.2.2.**
  - The inequalities behind $K_1$, $K_2$ and $K$ hold: $d+L+1\le d(L+2)$, $E_*\le2Ld^2n^{4\alpha}$, and the bracket is at most $(L+1)dn^\alpha$.
  - $K=65.4$, $133.9$ and $341.7$ at $\gamma=1$, as stated.
  - On 19,200 grid points (four $(m_\nu,M_\nu)$ pairs with $m_\nu\le1$, $\gamma\le3$, $n\le10^{20}$) there was no violation; the largest ratio was $0.538$.
  - The $o(1)$ condition on $d$ is sufficient, and fixed $d$ is a special case of it.
- **Separate exponents.** The lower bound $2^{\gamma-1}M_\nu(L-1)/\eta$ held in all 744 cases.
- **Remark C.4.1.** The cases $L=3$ and $L\ge4$ match `parity-circuit.tex`:
  - at $L=3$ the summing neuron has $d+1$ incoming weights, $\pm1$ and $c/\tanh1$;
  - at $L\ge4$ the last hidden neuron has the single weight $2$;
  - $2e^{-7A'/4}\le\varepsilon'$ exactly when $\varepsilon'\le2$.
- **Other changed passages.** All of these are correct:
  - the rates in C.9, where the constants in the KL and TV forms are absolute ($\le8.3$ and $\le2$);
  - Appendix C.A, Step 1 with $R=2$;
  - C.0 items 2–5 and "Bearing on the conjecture", including the $\tilde f_n$ terms $\frac1n+\frac1n\varepsilon_n+4\sqrt{2\log(1/\delta)/n}$;
  - Remarks C.6.2–C.6.4;
  - "Relation to SP$_c$": $\eta\sigma^2=1/(2c)$, $2cA_L/(n+1)$, and $\eta\le1/8$ exactly when $\sigma^2\ge4/c$.

**(c) No strengthening.** Every new positive statement is proved where it stands: the unclipped-likelihood extension, Theorem C.5(e), the explicit $K$, the separate-exponent lower bound, Proposition C.3(c) under $\sigma^2\le1$, and the improvement of $c_\nu$. Every weakened or removed claim is declared in the Referee record: sharpness, the rates, "every predictor", Remark C.6.2, Proposition C.3(c), the Monte Carlo order, and the C.0 phrases. No proved result was dropped. The only overstatement is the summary sentence in item 2 above.

**(d) Numbering.**
- Section headers, result labels and the tags (C.1.1)–(C.7.2) are identical.
- The additions are Theorem C.5(e), C.9 open item 6 (appended, so nothing was renumbered) and the unnumbered Referee record.

**(e) Cross-references.**
- C cites only B §1. Its description of SP$_c$ matches the final B: prior $\mu_\sigma$, likelihood $\mathcal N(z_w(x_i),c\sigma^2)$, and $\sigma\downarrow0$ after $N$ and $S$ are fixed.
- C does not cite A, E or the red-team note.
- The brief's §1 quote is verbatim, and its §1 formalisation and §2 predictors are described correctly.
- The two new source citations are correct: `paper.tex` lines 356–357 ("variance at most $1/m$", which is a weaker but true bound because $m_\nu\le1$) and `slt-likelihood/README.md` line 289.

**(f) Paths and outputs.**
- Every relative path resolves from `research-notes/` except `../README.md`, which the lead writes later. There are no absolute paths, and all `NNG/` paths exist.
- I re-ran the seven scripts of `checks/C/` with `python3 -I` from a copy (`../checks/revision-check-C-2/rerun/`). All seven outputs are byte-identical to the recorded `.out` files, and the longest run took 12.9 s.
- The current outputs differ from the referee's `repro/` only in `constants_table.out` and in the two labels of `check_oracle_mc.out`, as the record says.
- Every number quoted in C.8 and in the paragraph after Theorem C.5 matches the outputs.
- The docstrings now use the note's numbering, and old line 29 of `constants_table.py` is the formula that C1 cites.

## Outside the scope of this check (for the lead)

- `stage/README.draft.md` §6 still says "the predictors tend to $0$", the wording that logic issue 3 corrected.
- The same section says "this is the conjecture's form with a polynomially small error" with no condition on $d$.
- "Clipping is essential for the first statement" there should say that clipping is essential in the predictor and not in the likelihood.
- `stage/literature.md` item (i) still says that the argument "does not cover" $\operatorname{clip}$ of the unclipped mean. C now shows that the bound fails for it for some priors.
