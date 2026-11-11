# Check of the revised Claim C note (round 1)

*Published record of a check of the revised note, made during finalization. Paths under `stage/` refer to the lead's unpublished working copies; the pre-revision text there is the version that the referee reports reviewed, published as [`C-first-version.md`](C-first-version.md). This check's scripts and outputs are in the `../checks/revision-check-*` folder named below. Re-runs of the note's own scripts, which some reports keep in a `rerun/` subfolder, are not published; each report says whether they reproduced the recorded outputs.*

**Document:** `research-notes/C-fixed-temperature-bayes.md` (655 lines; its timestamp did not change during the check), compared with the pre-revision text `stage/C-fixed-temperature-bayes.md` (592 lines). I read all 44 diff hunks against the two referee reports, the brief, `B-tempered-likelihood.md`, the cited repository sources and `checks/C/`.

**Verdict: minor fixes.** The revision resolves the referee issues (17 issues, 21 rows in its Referee record), and every new proof, constant and quoted number that I re-derived is correct, with one exception. A clause that the revision added to Proposition C.3(c) is false. Nothing else in the note depends on it, and it needs a one-sentence fix plus a matching edit to the "logic 9" row of the Referee record. Two presentational points remain.

## 1. A false clause in Proposition C.3(c)

Line 276 now reads: "So, when $\sigma^2\le1$ (…), the excess of $\bar f_n$, $\hat f_n$ or the Gibbs predictor on this target can be below $1/2$ on some sample only if $\eta\sigma^2n>(2-\sqrt3)m_\nu/16\approx0.0167m_\nu$. Without $\sigma^2\le1$ this implication fails: $k_n=1/(16\sigma^4)$ gives $\sigma^2\sqrt{2k_n}=\sqrt2/4>1/4$, while $\eta\sigma^2n=m_\nu/(16\sigma^2)\to0$."

The first sentence and its proof are correct. I re-derived the root $(\sqrt6-\sqrt2)/8$ and the constant $(2-\sqrt3)/16=0.016747$. The second sentence is false under its natural reading, because "this implication" is the statement about the excess. The example shows only that the sufficient condition of part (b) fails. It does not show that the excess drops below $1/2$, and in fact the implication holds at every scale. The likelihood ratio $\Lambda_n/Z_n$ lies in $[e^{-4\eta n},e^{4\eta n}]$, and the prior mean of $\phi_w(x)$ is $0$ by (P3). So $\sup_X|\hat f_t|\le e^{4\eta t}-1$ at every $\sigma$. Suppose $\sigma^2>1$ and $\eta\sigma^2n\le(2-\sqrt3)m_\nu/16$. Then $\eta n<0.0168$, so $|\hat f_n|$ and $|\bar f_n|$ are at most $0.0693$. The excess on the constant target is then at least $0.866$, and by Jensen the same holds for the Gibbs risk.

At the note's own example the excess is at least $0.90$ for $\sigma=1.5$ and at least $0.994$ for $\sigma=3$. An exact quadrature of the width-one, depth-two strong-prior network agrees: the BMA excess is $0.977$ at $\sigma=1.5$ and $0.998$ at $\sigma=3$.

The referee's sentence (C-logic.md, issue 9) concerned the step from part (b), and there it is correct. The revision attached it to the conclusion about the excess. The Referee record repeats this reading ("the referee's counterexample without the hypothesis").

*Fix:* either write "Without $\sigma^2\le1$, part (b) alone does not give this: …", or drop the hypothesis $\sigma^2\le1$ and add the likelihood-ratio argument above, which proves the implication for every $\sigma$. Then update the "logic 9" row.

## 2. Smaller points

- **Overbroad phrase in C.0.** The first paragraph of C.0 says that "for an arbitrary prior Theorem C.1 is false for them", where "them" is all the unclipped predictors. Remark 3 shows failure for three predictors: the progressive mixture of $\bar z_t$, its clip, and $\operatorname{clip}\bar z_t$ used per step. It says nothing about the unclipped Gibbs predictor. The "Not proved here" bullet and C.9 open item 6 state this precisely, and C.0's first paragraph should match them.
- **"Its clip" in Remark 3 means two different predictors.** In the first sentence, "or with its clip" puts $\operatorname{clip}\bar z_t$ in place of $\hat f_t$. In "its clip has test loss $4$", it means the clip of the progressive mixture. The theorem fails for both, so nothing false is stated, but each sentence should name its predictor. With $\operatorname{clip}\bar z_t$ at $M=10^3$, the average risk in (C.2.4) is $0.55$ against the bound $0.055$ at $n=100$, and $0.056$ against $0.0055$ at $n=1000$. The mixture of the clips violates (C.2.5) at $n=100$ ($0.087$ against $0.055$), but it satisfies (C.2.5) at $n=1000$ ($8.9\cdot10^{-4}$ against $5.5\cdot10^{-3}$). The parenthesis "(Except for the value $4$ …, these numbers are from the logic referee's script)" is also slightly off. The script prints the loss $4$ of the clipped mixture, but it does not print $\bar z_0=4.5$ or $(\operatorname{clip}\bar z_0-y)^2=4$.
- **Expected, not an issue.** The link `../README.md` does not resolve yet, because the lead writes that README later.

## What was verified

**(a) Referee issues.** The Referee record has one row for each issue in logic §3 (1–10, with 7 split into three) and computation §3 (C1–C7, with C6 split into three). I found each fix where its row says, and every fix except "logic 9" (Section 1 above) is correct. The two points taken up from outside the issue lists, the adversarial ratio $0.49$ and the explicit $K$, match C-computation.md §2.4–2.5. No issue was rebutted. Of the notation overloads in logic 10, only $\lambda$ was left unchanged, with a valid reason.

**(b) Changed passages.** I re-derived these by hand and recomputed them in `../checks/revision-check-C-1/check_C_r1.py` (output `check_C_r1.out`), using my own implementation of $A_L$.

- *Remark 3, likelihood half.*
  - Proof: (C.1.1) before Jensen; the extension of (C.2.1) to $h$ bounded above, via $h\vee(-k)$ with monotone and dominated convergence; the Minkowski bound $2\rho\sqrt{L_D(g)}+\rho^2$.
  - Numerics: 300 random sequences with outputs in $[-4,4]$ gave no violation of either inequality of (C.2.3).
- *Remark 3, the two-point example.* $5.54\cdot10^{-3}$, $2.712$, $2.706\cdot10^6$, loss $4$ for every $n\le100$ at $M=10^3$, and $4.5$, $30.25$, $4$, $1.7526$, all as stated.
- *Theorem C.5(e).*
  - Proof: $\Sigma_N$ from Lemma C.6.1(ii)–(iii), Cauchy–Schwarz, Fubini (integrability from $\iint z^2\le\Sigma_N$), and pointwise Jensen.
  - Numerics: in an exact one-dimensional model the largest ratios to the three bounds were $0.72$, $0.33$ and $0.31$.
- *Theorem C.5(d).*
  - Constants: $16(4+\sqrt2)=86.63<87$. Over 200,000 random $(m_\nu,\eta,n)$ with $k_n\ge1$, the largest value of the ratio divided by $A_L/m_\nu$ was $86.59$.
  - Thresholds: the ratios are $20929.4$ and $20910.6$ against $64A_L=20908.5$, with $A_L(10,1,2,1/16)=326.7$.
  - The claimed limit $64A_L/m_\nu$ and the remark that an excess of order $(A_LN^\gamma/\eta n)^2$ is consistent with the bounds both hold.
- *Corollary C.2.2.* I re-derived $K_1$, $K_2$ and $K$ step by step: $d+L+1\le d(L+2)$, $\log(dn)\ge\log2$, $E_*\le2Ld^2n^{4\alpha}$, and the bracket at most $(L+1)dn^\alpha$. On 37,632 grid points, including three non-Gaussian $(m_\nu,M_\nu)$, there was no violation; the largest ratio of the two sides was $0.54$. The Gaussian values of $K$ are $65.4$, $133.9$ and $341.7$, as in the referee's report.
- *Separate exponents.* The new lower bound $2^{\gamma-1}M_\nu(L-1)/\eta$ held in all 1,728 cases with $2a+2b+\gamma\beta\ge1$.
- *C.8 item 6.* $A_L=346.0$, $1387.4$, $23088.2$, $82584.8$. The sample sizes are $5.54\cdot10^4$, $2.22\cdot10^6$, $3.69\cdot10^7$, $1.32\cdot10^9$. The rates are $\varepsilon_n=0.1137$, $3.223\cdot10^{-8}$ and $4.029$.
- *Remark C.4.1.* I checked the remark against `parity-circuit.tex`.
  - At $L=3$ the summing neuron has $d+1$ incoming weights, $\pm1$ and $c/\tanh1$ with $c\in\{0,1\}$. So after scaling they are at most $A'/\tanh1$, and $2e^{-7A'/4}\le\varepsilon'$ holds exactly when $\varepsilon'\le2$.
  - At $L\ge4$ the last hidden neuron has the single weight $2$.
- *Other changed passages.* All of these are correct:
  - the rates in C.9, with the AM–GM step for the KL and TV forms;
  - Proposition C.3(c) for $\sigma^2\le1$;
  - the $o(1)$ condition on $d$;
  - the $\tilde f_n$ terms in "Bearing on the conjecture";
  - Remark C.6.3;
  - Appendix C.A, Step 1 with $R=2$;
  - the new source citations: `paper.tex` lines 356–357 ("variance at most $1/m$") and `slt-likelihood/README.md` line 289 (unclipped likelihood);
  - the brief: §1, the verbatim quote, and §2's predictors.

**(c) No strengthening.** The new positive statements are proved where they are stated: the unclipped-likelihood extension, $K$, Theorem C.5(e), and the separate-exponent lower bound. Every claim that was removed or weakened is declared in the Referee record: sharpness, the rates, Remark C.6.2, Proposition C.3(c), and the Monte Carlo order. The only unproved new claim is the clause in Section 1.

**(d) Numbering.** The equation tags (C.1.1)–(C.7.2) and all result labels are unchanged. The additions are Theorem C.5(e), C.9 open item 6 (appended, so nothing was renumbered) and the unnumbered Referee record. Only the titles of Remark 3 and of Theorem C.5(d) changed.

**(e) Cross-references.** The note's only reference to another note is to B §1. C says that SP$_c$ has the likelihood $\mathcal N(z_w(x_i),c\sigma^2)$, which matches the final B. C does not cite A, E or the red-team note.

**(f) Paths and outputs.**
- Every relative path resolves from `research-notes/` except `../README.md`. There are no absolute paths, and all seven `NNG/` paths exist.
- I re-ran the seven scripts with `python3 -I` into `../checks/revision-check-C-1/rerun/`. The outputs are byte-identical to the recorded `.out` files, and the longest run took 12.4 s.
- The current outputs differ from the referee's `repro/` only in `constants_table.out` and in the two labels of `check_oracle_mc.out`, as the record says.
- Every number quoted in C.8 and in the paragraph after Theorem C.5 matches the `.out` files.
