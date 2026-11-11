# Check of the revised Claim C note (round 3)

*Published record of a check of the revised note, made during finalization. Paths under `stage/` refer to the lead's unpublished working copies; the pre-revision text there is the version that the referee reports reviewed, published as [`C-first-version.md`](C-first-version.md). This check's scripts and outputs are in the `../checks/revision-check-*` folder named below. Re-runs of the note's own scripts, which some reports keep in a `rerun/` subfolder, are not published; each report says whether they reproduced the recorded outputs.*

**Document:** `research-notes/C-fixed-temperature-bayes.md` (684 lines). I compared it with the pre-revision text `stage/C-fixed-temperature-bayes.md` (592 lines, 45 diff hunks) and checked it against:

- the two referee reports, `verification/C-logic.md` and `verification/C-computation.md`;
- the brief, `research-notes/problem-brief.md` (§1, §2, §4);
- §1 of the final `B-tempered-likelihood.md`;
- the cited repository sources;
- `checks/C/` and the referees' check folders.

My scripts and outputs are in `../checks/revision-check-C-3/`: `check_C_r3.py` with output `check_C_r3.out`, and reruns of the seven scripts in `rerun/`.

**Verdict: minor fixes.**

- Every referee issue is resolved as the Referee record says.
- Every changed statement, constant and quoted number that I re-derived is correct.
- Numbering, cross-references, paths and script outputs are in order.

One sentence changed in the last round is slightly inaccurate. Two optional points concern text that was not changed. None of the three affects a result.

## Remaining points

1. **§C.1.2, "Coordinate law" (line 54), changed in round 2.** The sentence "The first fact is used only in two places" refers to $m_\nu\le1$. The fact is also used in a third place: the first row of "Check of the revision" (line 668). That row goes from $\eta\sigma^2n\le(2-\sqrt3)m_\nu/16$ and $\sigma^2>1$ to "$\eta n<0.0168$", and this step needs $m_\nu\le1$.

   *Fix:* restrict the sentence to the results and proofs, or name the record row as well.

2. **Optional; unchanged text. Remark C.6.2 (line 390).** The remark says that $\mu_{N,\gamma}\{|z_w(x)|\ge\frac12\}\le2e^{-m_\nu N^\gamma/8}$ "matches the tube cost $A_LN^\gamma$ up to the factor $A_L$". The two exponents differ by the factor $8A_L/m_\nu$. The revision made the analogous factor $1/m_\nu$ explicit in C.0 item 4, Theorem C.5(d) and C.9 (logic 1, C4). "Up to a factor $O(A_L/m_\nu)$" would be consistent with those places.
3. **Optional; unchanged text. C.8 item 2 (line 474).** The text says "The per-sequence inequality (C.2.3) had no violation in any run". `check_oracle_mc.py` tests only the first inequality of (C.2.3), that the online loss is at most $-\frac1\eta\log W_{n+1}$. "The first inequality of (C.2.3)" would describe the test accurately.

## What was verified

**(a) Referee issues.** The record has 21 rows:

- logic 1–10, with issue 7 split into three rows;
- computation C1–C7, with C6 split into three rows.

Each fix is where its row says, and each is correct. No issue was rebutted. For logic 10, $\lambda$ was left unchanged for a valid reason: its three uses lie in separate proofs. The two points taken from outside the issue lists also match their sources: the adversarial ratio $0.49$ (C-computation §2.4; `v_lemma_c61_exact.out` prints $0.493$) and the explicit $K_1,K_2,K$ (§2.5). The points of the two earlier checks are resolved as their tables state. No referee issue is unaddressed.

**(b) Changed passages.** I re-derived each one by hand and recomputed it in `check_C_r3.py`.

- **Remark 3, the two-point example.**
  - Bounds: $0.504$, $0.0549$ and $5.54\cdot10^{-3}$.
  - One step at $M=10$: $\bar z_0=4.5$, the losses $30.25$ and $4$, and $-\frac1\eta\log(Z_1/Z_0)=1.7526$.
  - The losses $2.712$ and $2.706\cdot10^6$.
  - The clip of the progressive mixture has loss $4$ at every $n\le100$, and it violates (C.2.5) exactly for $1\le n\le100$.
  - $((M-1)/2-n)/(n+1)\ge1$ holds if and only if $n\le249$.
  - The logic referee's script prints exactly the values attributed to it.
- **Remark 3, the unclipped likelihood.**
  - Proof steps: (C.1.1) before Jensen; the extension of (C.2.1) to $h$ bounded above via $h\vee(-k)$, with monotone and dominated convergence; Tonelli; Minkowski on $U_\rho$.
  - Numerics: 400 random dictionaries with outputs up to $\pm10$. The first inequality of (C.2.3) held with slack at least $0.10$. The second held for all 3,790 choices of $Q$, up to $2\cdot10^{-13}$.
- **Counterexample of the second check.** The posterior weight is $6.6\cdot10^{-5}$, the sum is $197.0$, $8\log2=5.545$, $-\frac1\eta\log Z_{50}=205.5$, and the unclipped right side is $4055.5$.
- **Proposition C.3(c).**
  - The root is $(\sqrt6-\sqrt2)/8$, and $(2-\sqrt3)/16=0.016747$. A brute-force search over $\sigma^2\le1$ gives the same infimum.
  - The referee's example gives $\sqrt2/4=0.354>1/4$.
  - The argument of the first check gives $\eta n<0.01675$, $|\hat f|\le0.0693$ and an excess of at least $0.866$.
- **Theorem C.5(d).**
  - $16(4+\sqrt2)=86.63<87$.
  - With $k_n\ge1$, random search gives the ratio at most $74.5\,A_L/m_\nu$.
  - The limit is $64A_L/m_\nu$, with $A_L(10,1,2,\frac1{16})=326.70$.
- **Theorem C.5(e).**
  - Proof: Lemma C.6.1(ii)–(iii), with the bound monotone in $t$; Cauchy–Schwarz; Fubini; Jensen pointwise.
  - Numerics: exact quadrature in a one-dimensional model (all features $1$, Gaussian readout). The largest ratios were $0.71$ to $\Sigma_N$ and $0.28$ to the Gibbs bound, and there was no violation.
- **Corollary C.2.2.**
  - I re-derived $K_1$, $K_2$ and $K$ step by step, using $d+L+1\le d(L+2)$, $E_*\le2Ld^2n^{4\alpha}$, the bracket $\le(L+1)dn^\alpha$ and $\log(dn)\ge\log2$.
  - With Gaussian coordinates and $\gamma=1$, $K=65.4$, $133.9$ and $341.7$.
  - On 16,128 grid points, covering four pairs $(m_\nu,M_\nu)$, the largest ratio was $0.538$.
- **Separate exponents.** The lower bound $2^{\gamma-1}M_\nu(L-1)/\eta$ held in all 624 cases; the smallest ratio was $2.04$.
- **Remark C.4.1.**
  - The text matches `parity-circuit.tex`. At $L=3$ the summing neuron has $d+1$ incoming weights, $\pm1$ and $c/\tanh1$. At $L\ge4$ the last hidden neuron has the single weight $2$.
  - $2e^{-7A'/4}\le\varepsilon'$ holds exactly when $\varepsilon'\le2$.
  - The constructions hold numerically at depths 2–6, for $d\le11$ and $\varepsilon'$ down to $10^{-4}$.
- **C.9 rates.** The AM–GM constants are at most $8.3$ for KL and $2$ for TV.
- **Other changed passages.** All of these are correct:
  - C.0: every item, "Not proved here", and "Bearing on the conjecture", including the extra terms $\frac1n+\frac1n\varepsilon_n+4\sqrt{2\log(1/\delta)/n}$ of Theorem C.6;
  - §C.1.2–§C.1.3;
  - Remark C.4.2;
  - "Relation to SP$_c$";
  - the sentence after Theorem C.5(b), and the Monte Carlo paragraph;
  - Remarks C.6.2–C.6.4;
  - the heads of Appendices C.A and C.B, and Step 1 of C.A with $R=2$;
  - the Referee record;
  - the cited source lines: `paper.tex` lines 356–357, and `slt-likelihood/README.md` lines 195–215, 289 and 304.

**(c) No strengthening.**

- Every new positive statement is proved where it stands:
  - the unclipped-likelihood extension;
  - Theorem C.5(e);
  - the explicit $K$;
  - the separate-exponent lower bound;
  - Proposition C.3(c) under $\sigma^2\le1$;
  - the remark on $c_\nu$.
- Every weakened or removed claim is declared in the Referee record.
- No proved result was dropped.

**(d) Numbering.**

- The section headers, the 21 result labels and the 17 equation tags are identical in both versions.
- The additions are Theorem C.5(e), C.9 open item 6 (appended) and the unnumbered Referee record.

**(e) Cross-references.**

- Among the other notes, C cites only B §1. Its description of SP$_c$ matches the final B: prior $\mu_\sigma$, likelihood $\mathcal N(z_w(x_i),c\sigma^2)$, and $\sigma\downarrow0$ after $N$ and $S$ are fixed.
- C does not cite A, E or the red-team note.
- The brief is described correctly: the §1 formalisation and the verbatim quote; the §2 definitions of FIX$_\eta$ and of the predictors; the §4 displayed inequality.

**(f) Paths and outputs.**

- Every relative path resolves from `research-notes/` except `../README.md`, which the lead writes later. The string `../checks/C/...` in the record is a pattern, not a link.
- There are no absolute paths, and all eight `NNG/` paths exist.
- I re-ran the seven scripts with `python3 -I` from a copy. All outputs are byte-identical to the `.out` files, and the longest run took 12.7 s.
- The current outputs differ from the referee's `repro/` only in `constants_table.out` and in the two labels of `check_oracle_mc.out`, as the record states.
- Every number quoted in C.8 and in the paragraph after Theorem C.5 matches the outputs, and the script docstrings use the note's numbering.
