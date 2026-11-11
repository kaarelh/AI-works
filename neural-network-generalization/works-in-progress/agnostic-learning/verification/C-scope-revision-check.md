# Check of the Claim C note revised after the scope report

*Published record of the independent check of the C note's revision in answer to its scope report, made during finalization. Paths under `stage/` refer to the lead's unpublished working copies. The check's scripts and outputs are in [`../checks/revision-check-C-scope/`](../checks/revision-check-C-scope/).*

**Document:** `research-notes/C-fixed-temperature-bayes.md` (717 lines). I diffed it against the pre-revision text `stage/C-pre-scope.md` (694 lines; identical to the note at commit 29417ff8, which the scope referee reviewed). I checked it against the scope report `verification/C-scope.md`, the cited sources and the referee's scripts in `checks/verify-C-scope/`. My scripts and outputs are in `../checks/revision-check-C-scope/`:

- `v_remark3.py` and `v_remark3.out`: mpmath, 40 digits;
- `v_spc.py` and `v_spc.out`;
- reruns of `s1`–`s3`.

**Verdict: minor fixes.**

- Issues 7–12 are resolved as the new "Scope referee" table says. Each fix is correct, and none was rebutted.
- Every changed passage is mathematically correct and claims no more than is proved.
- All links resolve.

The remaining problems are three small inaccuracies in the new record section, where it describes its own changes. None affects a statement of the note.

## Remaining points (all in the new "Scope referee" section)

1. **Line 700: "The changes are confined to the sentences named in the table".** The opening paragraph (line 3) was also rewritten. It now names the scope referee and says that the changes have not been refereed again. No row names this change. The earlier records note such edits ("Besides these changes, the opening paragraph …").
   *Fix:* add "Besides these changes, the opening paragraph now mentions the scope report."
2. **Line 700: "Resolutions use the terms defined before the first table".** Rows 1–6, 13 and 14 read "answered in the README / brief by the lead editor", which is not one of the defined terms (fixed / weakened / rebutted).
   *Fix:* "The resolutions of issues 7–12 use the terms defined before the first table."
3. **Row 11: "… is not addressed here, and the preceding sentence now states $0<\eta\le1/8$".** This clause follows the description of the last sentence, so "the preceding sentence" reads as the sentence on $\gamma\le0$. That sentence states no range of $\eta$. The range is stated in the sentence on Remarks C.4.1–C.4.2.
   *Fix:* "and the sentence on Remarks C.4.1–C.4.2 now states $0<\eta\le1/8$".

## Record of the scope issues

| issue | the note's resolution | check |
|---|---|---|
| 1–6 | answered in the README by the lead editor | answered in the README / brief by the lead editor; not checked here. A grep finds the new wording in `../README.md`. |
| 7 | weakened | resolved. "Bearing on the conjecture" now states $0<\eta\le1/8$, and it cites items 2 and 5 for $\gamma\ge1$ and Remark C.4.2 for $\gamma<1$ (all real $\gamma<1$). Cor C.2.2 is now tied to $\gamma\ge1$, which it needs. The C.9 bullet names the width $N=\lceil n^\alpha\rceil$, the predictor $\bar f_n$ and "in expectation". |
| 8 | weakened | resolved. The heading is renamed. The new sentence is correct: $\mathbb E T=n/2$, and the permutation average is $\frac1{n+1}\sum_t\binom nt^{-1}\sum_{\lvert A\rvert=t}\hat f_A$, an average of posterior means given subsamples of every size. Theorem C.7 carries $4\eta$. |
| 9 | weakened | resolved. Theorems C.6 and C.7 hold for any prior and any $Q$ that does not depend on $S$. $\mu_{N,\gamma}(\cdot\mid U_\rho(g))$ has KL bounded by the display of Remark C.4.2 for every real $\gamma$. $q_t$ (App. C.B) does not depend on $S$, has $\int L_D(\phi_w)\,dq_t\le L_D(g)+4\rho$, and has KL at most $E^{\rm fi}_N+\frac{Q_N}2\log(A^{\rm fi}/\rho^2)$. So $\tilde f_n$ is polynomially agnostic with probability $\ge1-2\delta$. Prop C.4 already has $\eta\le1/8$ as a hypothesis. |
| 10 | weakened | resolved. With $\eta=1/(2c\sigma^2)$, part (a) gives $2cA_L/(n+1)$ exactly when $\sigma^2\le1/N$, and $\eta\le1/8\iff\sigma^2\ge4/c$ gives $N\le c/4$. Beyond that range, the right side of (C.3.1) is at least $N(d+2)\log\frac1{c_\nu h_\rho}$, with $\log\frac1{c_\nu h_\rho}\ge\log\frac{16}3$, so it grows at least linearly. The $\log^+$ term makes it grow like $N\log N$: in `v_spc.out`, $R/(N\log N)$ tends to about $13.5$. `slt-likelihood/README.md` line 206 reads "Let $L_S$ be a fixed-temperature Gaussian or logistic likelihood", as quoted. |
| 11 | weakened | resolved. Thm C.5(b) gives test losses $\to\mathbb E_Dy^2=L_D(0)$, which is $1$ on parity. The restriction to $\gamma>0$ is correct, since Thm C.5 needs it. C.9 open item 4 covers $\gamma\le0$. |
| 12 | fixed | resolved; see the numbers below. |
| 13 | answered in the brief by the lead editor | answered in the README / brief by the lead editor; the header note of `problem-brief.md` (line 9) has the new wording. |
| 14 | answered in the README by the lead editor | answered in the README / brief by the lead editor. |

## What was verified

**Issue 12 numbers** (two-point prior, $\eta=1/8$, $Q=\delta_{w_2}$; `v_remark3.out`).

- The right side of (C.2.3) is $8\log2=5.5452$.
- With $\operatorname{clip}\bar z_t$ the left side is $4$ at $T=1$. The chain holds there, and only the first inequality fails ($4>1.7526$).
- $\bar z_1=3.153\ge1$, so the left side is $8$ at $T=2$ and at least $8$ for every $T\ge2$. This needs $M\ge4.30$, which holds at $M=10$.
- (C.2.4) at $M=10$, $n=10$: $1.71372$ against $0.50411$.
- Gibbs risk:
  - $p_n$ does not depend on $M\ge1$, and the unclipped Gibbs risk is $p_n(M+1)^2$.
  - The right side of (C.7.2) is $4\eta+(\log2+2\log(1/\delta))/(\eta n)=0.92387$ at $n=100$, $\delta=0.1$.
  - The closed form $(10+e^{-2\eta n})^2/(1+e^{-4\eta n})$ equals $p_n(M+1)^2$ at $M=10e^{2\eta n}$ (to 25 digits, $n\le2000$).
  - It is at most $101$ for all $n$, by Cauchy–Schwarz, with equality only at $n=4\ln10\approx9.21$. It exceeds $100$ for $n\ge7$, and equals $100.968$ at $n=10$. So "between 100 and 101 for every $n\ge10$" holds.
  - All quantities are independent of the sample.
- Theorem C.7 is stated for any prior and any $\eta>0$, so this counterexample tests it as stated.

**Scripts.** `s1_two_point.py`, `s2_width_thresholds.py` and `s3_spc_window.py` rerun with `python3 -I` reproduce their recorded `.out` files exactly. `s1` prints the values the note attributes to it: $5.5452$, $8.0000$, $1.71$, $0.5041$ in parts (a)–(c), and $1.000\cdot10^2$ and $0.924$ in part (d).

**Nothing else changed.** The diff has 12 changed lines plus the appended section. Each changed line maps to a row of the table, except line 3 (point 1).

- No displayed equation, result number or label changed.
- The files in `checks/C/` were last modified at 15:46, before the scope report.
- The Markdown nesting of Remark 3 is intact, and inline `$` signs and table cells are balanced.
- No other file in the project quotes the replaced wording.

**Links.** All 11 Markdown link targets resolve from `research-notes/`. All `../` code-span paths resolve, except the literal placeholder `../checks/C/...` in the old record. All `NNG/` paths resolve.

**Observations, no change needed.**

- The docstring of the referee's `s1_two_point.py` still says that the Gibbs-risk failure is "not claimed in the note". It predates the revision, and the script is a record.
- `s1` prints the $n=10$ Gibbs value as `1.010e+02`; the true value is $100.968$.
- In Remark C.6.4, "For FIX$_\eta$ with $\gamma>0$ the obstruction is …" relies on the preceding sentence for $\eta\le1/8$. That reading is clear in context.
