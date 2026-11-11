# Re-referee report, round 2 (logic and computation of the changed passages): `../research-notes/depth-two.md`, final candidate

*Published record of a referee report on the final candidate of the note, made during finalization. Paths under `stage/` refer to the lead's unpublished working copies; the pre-revision text there is the version that the second-round referee reports reviewed, published as [`depth-two-first-version.md`](depth-two-first-version.md). The referee's scripts and outputs are in the `../checks/depth-two-referee-*` folder named below. Re-runs of the note's own scripts (`author_rerun/` and similar subfolders) are not published; the report says whether they reproduced the recorded outputs.*

**What was refereed.** I diffed the final candidate of `../research-notes/depth-two.md` against the pre-revision text, which is the text the second-round referees read (`RT-depth2-logic-revised.md`, `RT-depth2-computation-revised.md`). The diff has 63 hunks, in two layers:

- the answers to the second round, which the first check of the revision already examined (`depth-two-referee-logic-computation-1.md`, `depth-two-referee-scope-1.md`);
- the answers to that check, which the note's header lists as not yet reviewed. These are chiefly the paragraph of Remark 5.7a on Proposition 9.1 of `B-tempered-likelihood.md` (B below) and the record of the red-team optimisation runs in §7.1, with the new scripts `prop91_l2.py` and `rt54_record.py`.

I refereed both layers, and the second in full. For every changed passage I did three things:

- re-derived each statement, constant and number in it;
- checked its quantifiers and the limit order: $\sigma\downarrow0$ comes after $n$, the sample and the learner width are fixed;
- checked it against its source. The sources are:
  - B: §0, §1, Lemmas 2.1, 2.3, 3.1, 5.3, Corollary 3.2, Proposition 6.1 and the paragraph after it, Theorems 6.3–6.4, Remark 6.5, §7.5, Corollary 8.1, Proposition 9.1, the §9 Discussion, Remark 9.4 and §11;
  - `A-tight-conditioning-fails.md` §5.1, Proposition 5.2 and §5.4;
  - `small-learner-width.md` Theorem 1(c);
  - `problem-brief.md` §§1–2;
  - the staged `red-team.md`: §0 item 6, §2.3 A3, §5, §5.4, §6.1, §6.4, §7 item 3 and Appendix A;
  - the run files and referee outputs that the note quotes.

I also checked that each issue of the two second-round reports, and each point of the first check of the revision, is resolved as §9 of the note says. Unchanged passages were not re-refereed.

**Lens.** Logic and computation.

**Scripts.** New, and independent of the author's. They sit in the staging folder next to this report, under `../checks/depth-two-referee-logic-computation-2/` (§5). I also did three things with existing files:

- re-ran three of the optimisations of RT §5.4 from an unmodified copy of `memorize_opt2.py`;
- re-ran the two new author scripts from a copy;
- compared the six older author scripts and their four re-run outputs with the copies made by the first check.

---

## Verdict: minor fixes

The three definition and scope flaws of the second-round logic report stay fixed, and the material added after the first check is correct.

1. **Second-round issues.** All nine logic issues, all seven computation issues and the script remark are resolved as §9 says (§4 below). Logic issue 6, an optional strengthening, is declined with an accurate reason.
2. **The new large-$c$ paragraph of Remark 5.7a is correct.** At $L=2$, B's Proposition 9.1 with $\delta_0=\min\{1/2,1/K\}$ gives $\eta_0\le1/2$.
   - Hence every near-minimizer, at every width, and the $\sigma\downarrow0$ limit of every posterior predictor have test MSE at least $1/4$.
   - A width-one competitor with zero loss and weights at most $1.5\max\{\sqrt2,\sqrt K\}$ exists.
   - Both consequences follow with the quantifiers right. When $n/c(n)\le n^{o(1)}$, (P$_2^{o(1)}[\phi]$) and (P$_2$) fail. When $c\ge n/4$, (P$_2$) fails on one fixed law ($\delta_0=1/5$).
   - Every number reproduces, including the entry points $10^6$, $10^{16}$, $10^{123}$ and $10^{16}$, $10^{40}$, $10^{282}$.
   - Minimizing $F_{n/4}$ directly on $D_{1/5}$ returns the zero network, with test MSE 1.
3. **§7.1 is an accurate record.**
   - Every entry of its table matches the run files, or RT §5.4 for the one row without a file.
   - $G,Q,V,W$ and $s$ reproduce exactly from the seeds.
   - The certified values reproduce: $\phi\ge0.3958$ and $0.5777$; near-minimizer capture at least $0.3894$ and $0.5761$; clipped excess at least $0.0146$ and $0.0325$.
   - The $d=10$ depth-two run had not been re-run by any referee. From an unmodified copy of the script it reproduces its run file to every printed digit.
   - Two runs of the tempering sweep reproduce with the stated budget of one restart of up to 6000 iterations.
4. **Every other changed number reproduces** (§2.4). The two new author scripts reproduce their outputs byte for byte, and each runs in under a second.

**What remains** is one minor wording issue in a displayed bound, ten nits and one optional suggestion (§3). None changes a theorem, a regime, a status entry or a number.

---

## 1. Changed passages and what was checked

| Passage (final candidate) | Change | Check | Result |
|---|---|---|---|
| Header | refereeing record; unreviewed material named | against §§8–9 and the two first-check reports | ✓; becomes out of date once this report is recorded (nit 11) |
| §0, "What is refuted …" (five bullets) | regimes, B's Proposition 9.1, open range, one learner | each bullet against Cor. 5.2, Remarks 5.3a, 5.5, 5.7a; $c=n^{1/2}$ against B Thm 6.3 ($\theta=1/2$) and Cor 8.1 ($\alpha=1/16$, so $(2-8\alpha)/3=1/2$, $\beta=1/4$) | ✓; nit 5 |
| §0, "Relation to the open items of B" | B §0 and §11 (iii) superseded or narrowed | quotations against B lines 29 and 958; content against Remark 5.7a | quotations verbatim ✓; nit 6 |
| §0.1 items 1–3 | (R1′); widths $N\ge n^\alpha$; Prop. 5.3 reframed | against Thm 5.1(3), §1.4, Remark 5.3a | ✓ |
| §0.2 rows 1–4, restrictions | Prop. 9.1 entries; holds/open ranges; fixed-$d$ row | Remark 5.7a; B Thms 6.3 and 6.4; A Prop. 5.2(c) at $t=1$ ($8M=2^{d+3}$, $Me^{-n/(8M)}=2^de^{-n/2^{d+3}}$) | ✓; optional 12 |
| §0.3–§0.5 | change logs | against the diff | ✓; nit 8 |
| §1.1, §1.3, Lemma 1.2 | `paper.tex` name; general atom set $\mathcal A$ | proof atom-free; $Q\le s\le\min\{n,\lvert\mathcal A\rvert\}$ | ✓ |
| §1.4 | $N\ge n^\alpha$; one learner; learner widths; (R1′); clipped readings; measurability | against brief §1, B Cor 8.1 (quotation verbatim), A §5.1 | ✓ |
| Cor. 5.2 (a)–(c) and proof | (R1′) step; width $\max\{N_0,\lceil n^\alpha\rceil\}$; $\limsup_{\sigma\downarrow0}\le\rho_n$; $\epsilon_n>0$ w.l.o.g. | quantifiers (§2.5) | ✓ |
| §4 "Numbers" | $a=1/n$ and $a=1/d$ separated | recomputed (§2.4) | ✓ |
| Remark 5.2a | width-one example | recomputed (§2.4) | ✓ |
| Prop. 5.3 proof, table, "What it shows" | $Q\le s\le M$; $0.016\to0.015$; reframing | re-derived and recomputed | ✓ |
| Remark 5.3a | impossibility at $d\asymp n$; (R1′); one law | re-derived (§2.5) | ✓ |
| Remark 5.4 | wording; evidence "at most 0.003" | `../checks/verify-RT-depth2-logic/opt_hadamard.out` ball rows: 0.003, 0.000, 0.001, 0.000 | ✓; nit 4 |
| Remark 5.5 | "for SP$_c$ with the stated $c$"; Theorem 1(c) | `small-learner-width.md` Thm 1(c): $K'=E_*+1+n(U+1)^2/c=d^2+d+3+4n/c$ at $m=B=1$, $L=2$; probability $1-\delta/2$ | ✓ |
| Remark 5.7a | B at $H=1$; passage to the readings; (5.7a); class version; **large $c$ (new)**; status table; $c=\log^3n$ | re-derived against B (§§2.1, 2.3) | ✓; issue 1, nits 3, 10 |
| Remark 5.8 items 1, 4 | open range; unit ball | consistency | ✓ |
| §6 errata | RT §0 item 6, A3, §6.1, §6.4, §7 item 3, Appendix A, §5 items | quotations against the staged `red-team.md`; numbers against `rt54_record.out` | quotations verbatim ✓; nits 2, 11 |
| §7, §7.1 (**new**) | two new scripts; record of RT §5.4 | §2.2; re-runs | ✓; nit 10 |
| §8 | preamble; L2, L3, C2, C3 | against pre-revision §8 | ✓; nit 9 |
| §9 | both tables | each row against the text | ✓; nit 7 |

---

## 2. Re-derivations and recomputations

### 2.1 The large-$c$ paragraph of Remark 5.7a (B Proposition 9.1 at $L=2$)

`rr2_prop91.out` holds the computations of this section.

**B's statement at $L=2$.**

- B puts $K=n/c+1$ and $\eta=\delta_0(K/L)^{L/2}$, which is $\delta_0K/2=\eta_0$ at $L=2$. ✓
- **(a).** Lemma 2.3(a) gives $\kappa_N(w)\le c^{-1}\sum_iy_i^2+1=K$, since the labels are $\pm1$. Lemma 2.1(b) at $d=1$, $L=2$ gives $\lvert z_w(x)-z_w(x')\rvert\le(\kappa_N/2)\lvert x-x'\rvert$, so $\lvert z_w(\delta_0)-z_w(-\delta_0)\rvert\le K\delta_0=2\eta_0$.
  - Then $L_D(f)=\frac12(p^2+q^2)\ge\frac14(p-q)^2\ge(1-\eta_0)^2$. On a grid the constrained minimum equals $(1-\eta)^2$ for $\eta\in\{0.1,0.25,0.5,0.9\}$.
  - I maximised the Lipschitz ratio adversarially: 300 Nelder–Mead runs at widths $N\le5$ (`rr2_lipschitz.out`).
    - Re-evaluated at 60 digits with the same parameters, the largest ratio is $1-7\cdot10^{-18}$, so the ratio approaches 1 without exceeding it.
    - Floating-point ratios above 1 do occur, up to $1.495$, but only at $\lvert x-x'\rvert\le8\cdot10^{-12}$, where $z(x)-z(x')$ is lost to cancellation. The parameters of the $1.495$ case give $0.919$ at 60 digits.
    - So the inequality is correct, and tight in the linear regime. The author's random check reports $0.962$; a random check does not come near the bound, and a floating-point check near the bound needs this care.
- **The choice of $\delta_0$.** With $\delta_0=\min\{1/2,1/K\}$: if $K\ge2$ then $\eta_0=1/2$, and if $K<2$ then $\eta_0=K/4<1/2$. So $(1-\eta_0)^2\ge1/4$. ✓
- **(b).** $\omega=\delta_0^{-1/2}$ satisfies $\omega^2\ge2$ iff $\delta_0\le1/2$. The readout $v=1/\tanh(\omega\delta_0)$ lies in $[\omega,1.5\omega]$; on a grid of $K$ from 1 to $10^{12}$, $v/\omega$ falls from $1.161$ to $1$. The fit is exact to machine precision. Since $\delta_0^{-1/2}=\max\{\sqrt2,\sqrt K\}$, the weight bound $1.5\max\{\sqrt2,\sqrt K\}$ is right. ✓

**The posterior predictors and the corrections.**

- B's Proposition 9.1(a) covers the $\liminf_{\sigma\downarrow0}$ of $\mathcal G^{\rm clip}_\sigma$, $\mathcal G_\sigma$, $L_D(\bar f_\sigma)$ and $L_D(\bar z_\sigma)$.
- $\operatorname{clip}\bar z_\sigma$ is covered as the note says. Clip is monotone and 1-Lipschitz, so $\operatorname{clip}\bar z(\delta_0)-\operatorname{clip}\bar z(-\delta_0)\le\max\{0,\bar z(\delta_0)-\bar z(-\delta_0)\}$. B's lower-bound argument needs only this one-sided difference.
- B's proof bounds the corrections at finite $\sigma$ in three ways:
  - $\mathcal G^{\rm clip}_\sigma\ge\Pi_\sigma(\mathcal N_1)(1-\eta_0)^2$;
  - $\bar f_\sigma(\delta_0)-\bar f_\sigma(-\delta_0)\le2\eta_0+2\Pi_\sigma(\mathcal N_1^c)$;
  - $\bar z_\sigma(\delta_0)-\bar z_\sigma(-\delta_0)\le2\eta_0+2\mathbb E_\Pi[(1+F)\mathbf 1_{\mathcal N_1^c}]$.
- B's Lemma 3.1 makes all of them uniform over samples in $(\{\pm\delta_0\}\times[-1,1])^n$, with a threshold depending on $(N,n,c)$. The readings allow that dependence. So the claim "at all small $\sigma$ … under every reading of §1.4" is correct. ✓

**Consequence 1: $n/c(n)\le n^{o(1)}$.**

- **(P$_2^{o(1)}[\phi]$).** For every $\epsilon>0$, eventually $K\le n^\epsilon+1$. So the largest weight is $n^{o(1)}\le n^\alpha$ for every $\alpha>0$ and large $n$, and width $1\le\lfloor n^\alpha\rfloor$ always holds. The dimension $d=1$ is at most $\log_2n+C_0$ for $n\ge2$, and $\inf_{\mathcal G^{(\alpha)}_n}L_D=0$.
  - For large $n$, $\epsilon_n<1/8$. The probability of the inequality is then at most $\sup_S\Pi_{\sigma,S}(\mathcal N_1^c)\to0$ under (R1), and $0$ under (R1′), (R2) and (R3) once $\sigma$ is small.
  - So the property fails for every $\alpha$, every $\epsilon_n\to0$ and every $\delta$, at every learner width. ✓
- **(P$_2$).** Take $B_n=1.5\max\{\sqrt2,\sqrt K\}=n^{o(1)}$. If $\mathsf p$ has degree $k$ in $B$, then $\mathsf p(1,1,B_n,10,\log(1/\delta))\le C(1+B_n^k)<n$ eventually. With $\varepsilon=1/10<1/4$ the bound fails. ✓

**Consequence 2: $c\ge n/4$.**

- Then $K\le5$. At $\delta_0=1/5$, $\eta_0=K/10\le1/2$.
- $\omega=\sqrt5=2.23607$ and $v=1/\tanh(1/\sqrt5)=2.38319$, which give the note's $(0,2.2361)$ and $2.3832$. The competitor fits $\pm1$ exactly.
- The law and the competitor are fixed, so (P$_2$)'s threshold $\mathsf p(1,1,2.3832,10,\log(1/\delta))$ is a constant, and failure at every large $n$ refutes (P$_2$) on one law. ✓

**The entry points.** The exact entry points, by bisection in $\ln n$ at 60 digits, are:

- $10^{5.93}$, $10^{15.80}$ and $10^{122.68}$ for $c=n/\ln n$;
- $10^{15.54}$, $10^{39.09}$ and $10^{281.11}$ for $c=n/\ln^2n$.

So the quoted $10^6$, $10^{16}$, $10^{123}$ and $10^{16}$, $10^{40}$, $10^{282}$ are the first powers of ten after the crossings, and the competitor stays inside afterwards. ✓ These use the competitor's actual largest weight $v\approx\sqrt K$. With the bound $1.5\max\{\sqrt2,\sqrt K\}$ they would be $10^9$, $10^{21}$, $10^{144}$ and $10^{18}$, $10^{44}$, $10^{302}$. The remark speaks of "the competitor", so it is right as written (nit 10).

**Direct experiment.** I minimized $F_{n/4}$ on samples of $D_{1/5}$ with L-BFGS, 60 restarts per setting, at $n\in\{40,200\}$ and $N\in\{1,4,16\}$. In every setting the best value found is $4.0000=n/c$, that of the zero network, and the network found has test MSE 1, above the guaranteed $1/4$.

**Sources.** B's §9 Discussion contains "for every $c$ and $n$ with $n/c\ge2L$" verbatim, and B's Remark 9.4 contains the rescaling remark. ✓

### 2.2 §7.1 and the numerics in the errata

`rr2_rt54.out` holds the computations of this section.

**The samples.** I rebuilt them from the seeds with the random calls of `memorize_opt.py`, and computed the statistics with plain dictionaries and exact fractions:

- $d=8$: $s=164$, $G=774/5=154.8$, $Q/M=0.477969$, $V=242$, $W=101.2$;
- $d=10$: $s=640$, $G=9511/15=634.0667$, $Q/M=0.470429$, $V=1002$, $W=389.9333$.

These match `rt54_record.out` and the run files.

**The table.**

- Rows 1, 2 and 4–8 match their run files field by field.
- Row 3 ($d=8$, $L=3$, $c=1$) matches RT §5.4: $\phi=0.70$, $\mathcal R=3.1$, excess $0.500$ ($0.367$), and $\kappa_N=43.7$ from the sweep paragraph. Its $F_c-W/c=46.8=\kappa_N+\mathcal R$, and $1-46.8/154.8=0.6977$.
- In every row $\kappa_N+\mathcal R/c$ equals the recorded $F_c-W/c$ within the two-decimal rounding of the three fields. Row 6 is the tightest: $38.6025$ against $38.61$, inside the rounding interval.
- The run files' "rigorous near-min excess LB" is $\max\{\phi G,0\}^2/(4MV)$ in the code, and $0.0152$ and $0.0327$ reproduce. ✓

**The certified values.** Take $\phi_{\rm cert}=1-c(F_{\rm rec}+0.005)/G$, which allows for the rounding of the recorded objective. Then:

- $\phi_{\rm cert}=0.395898$ and $0.577718$;
- the near-minimizer capture $\phi_{\rm cert}-c/G$ is $0.389438$ and $0.576141$;
- the clipped excess bound for near-minimizers, by Lemma 1.2 with budget $(1-\phi_{\rm cert})G+c$, is $0.014666$ and $0.032516$. The (b) branch dominates; the (a) branch gives $0.0070$ and $0.0301$.

Rounded down, these are the note's $0.3958$, $0.5777$, $0.3894$, $0.5761$, $0.0146$ and $0.0325$. The errata quote $0.395$, $0.577$, $0.389$ and $0.576$. ✓

**The rows with $c\ge4$.** At $c=4$ and $c=16$, $\phi_{\rm cert}-c/G$ is $-0.0012$ and $-0.0236$ (depth two and three at $c=4$) and $-0.104$ (at $c=16$). So "nothing is certified" is right. Three more values check:

- $F_4-W/4=43.7+3.1/4=44.475>G/4=38.70$ for the depth-three memorizer;
- $G/16=9.675$ prints as $9.68$;
- $n^{1-1/H}=16$ at $n=256$, $H=2$. ✓

**The logic of "What the runs certify".**

- A network of any width with $\kappa_N+\mathcal R/c\le(F_c-W/c)_{\rm found}$ has $\mathcal R\le c(F_c-W/c)_{\rm found}=(1-\phi)G$.
- A near-minimizer at width $N$ has $F_c\le\min^{(N)}F_c+1$. When $N$ is at least the run's width, $\min^{(N)}F_c\le F_c(w_{\rm found})$, because zero padding embeds the network found. So $\mathcal R\le(1-\phi)G+c$.
- §7.1 states this "at the run's width", which is correct and conservative.

**Budgets and re-runs.** RT Appendix A gives $3\times20000$ for $d=8$, $c=1$ and $1\times6000$ for the rest. The first-round computation referee's re-run of row 1 used $3\times20000$ (`RT-depth2-computation.md` §7, issue 7). From an unmodified copy of `memorize_opt2.py`:

- $d=10$, $L=2$, $N=512$, $c=1$, seed 1, $1\times6000$ reproduces `run_d10_L2.txt` to every printed digit ($F-W/c=267.75$, $\kappa_N=198.17$, $\mathcal R=69.58$; 4 min 49 s);
- $d=8$, $L=2$, $c\in\{4,16\}$, $1\times6000$ reproduce `run_d8_L2_c4.txt` and `run_d8_L2_c16.txt` to every printed digit.

So the $d=10$ certificate rests on a reproducible network, not only on a recorded number, and the stated sweep budget is confirmed.

### 2.3 The rest of Remark 5.7a, and §0

**Theorem 6.3 and 6.4 bullets.** At $H=1$, $8(2/H)^{H/2}=8\sqrt2$, $D_n$ has no $(H-1)/2$ term, and B allows "any $\theta\in(0,1)$ when $H=1$". Theorem 6.4 needs $\theta<1/L=1/2$. ✓

**Corollary 8.1 bullet.**

- $\theta=(1+8\alpha)/3$, so $c=n^{(2-8\alpha)/3}$, which ranges over $(n^{1/3},n^{2/3})$ for $\alpha\in(0,1/8)$. In $\Xi_n$, $2L=4$. Also $\beta=\min\{(1-4\alpha)/3,\frac12-4\alpha\}>0$ iff $\alpha<1/8$.
- At $\alpha=1/16$, $c=n^{1/2}$ and $\beta=1/4$, which matches §0's example.
- The choice of $\epsilon_n$ and $n_\delta$ works.
  - B's $\delta$-term at confidence $\delta/2$ is $4\sqrt{2\ln(4/\delta)}\,n^{-\beta}$, which is below $n^{-\beta/2}$ for $n\ge n_\delta$.
  - $\epsilon_n$ is the $\delta$-free part at $d=\lfloor\log_2n+C_0\rfloor$, where that part, increasing in $d$, is largest, plus $2n^{-\beta/2}$. This absorbs the $\delta$-term and $4\eta\le n^{-\beta/2}$, and $\epsilon_n$ does not depend on $\delta$. ✓

**The passage to the readings.** It matches the paragraph after B's Proposition 6.1: $\sigma_0(N,n,c,d,H,\eta)$ does not depend on the sample, the bad posterior mass is at most $\eta$, and the clipped Gibbs risk carries the extra $4\eta$. Also $(1-\delta/2)^2\ge1-\delta$. ✓ The wording of the displays that precede or use it is the subject of issue 1.

**(5.7a) and the class version.**

- Lemma 5.3(a) at $H=1$, $K=n/c+1$ and $\delta'=\delta/2$ gives $8\sqrt K\,D_n/\sqrt n=8D_n\sqrt{1/c+1/n}$. With Proposition 6.1 this is (5.7a). ✓
- With $m=\lfloor n^\alpha\rfloor$ and $B=n^\alpha$, I evaluated the two constant bounds on a grid of $\alpha$, $n$ and $d$:
  - the largest ratio $(E_*+1)/((d(d+1)+4)n^{4\alpha})$ is $0.986$;
  - the largest ratio $(4+(U+1)^2)/(8n^{4\alpha})$ is $0.976$. ✓
- I checked the $\epsilon_n$/$n_\delta$ construction on a grid: $\alpha\in\{0.02,0.05,0.1\}$, three values of $\epsilon$ and $C_0$, $\delta\in\{0.5,10^{-3},10^{-9}\}$, $n\ge n_\delta$, $c=\min\{n^{1-\epsilon},\ln^3n\}$, every tested $d\le\log_2n+C_0$, and $4\eta=n^{2\alpha-1/4}$. The total bound never exceeds $\epsilon_n$. ✓
- Unclipped variant:
  - Lemma 5.3(b) at $H=1$ gives the stated middle term. It is of order $D_n\sqrt n/c$, since $(\sqrt K+1)\sqrt K\approx n/c$.
  - The new $\delta$-term is $(\sqrt K+1)^2\sqrt{\ln(4/\delta)/(2n)}=O(\sqrt n/c)$ for $c\le n$.
  - The slack $2(\sqrt n/c)^{1/2}$ absorbs it once $\sqrt n/c\to0$, which $c\gg\sqrt n\log n$ ensures. ✓
- At $c=\ln^3n$ the middle term times $\sqrt{\ln n}$ is between $13.6$ and $13.9$ for $n=10^6$ to $10^{96}$, so the rate is $O(1/\sqrt{\log n})$. Also $c=O(d^3)$ along the family, so Corollary 5.2(a) applies there. ✓
- The §7.5 item-3 relay is right to add "$c=o(n)$". With $w'=0$ in B's Remark 6.5 the term is $c/n$. ✓

**The status table.** Each row is consistent with the result it cites, and the rows are disjoint. B's Proposition 9.1 does not reach the open rows. There $K\ge n^{1/2-o(1)}$, so the width-one competitor needs weights $n^{1/4-o(1)}$, and B's width-$n^\alpha$ chains (Lemma 9.2 at $L=2$) need $K\lesssim n^{3\alpha}$. Both exclude only large $\alpha$, while the formulation asks for some $\alpha$. So "open" is right.

### 2.4 Numbers elsewhere

`rr2_numbers.out` holds the computations of this section; the binomial statistics come from an exact term recursion at 80 digits.

| Claim | Recomputed | |
|---|---|---|
| §4, $c=1$, $a=1/n$: bound 0 for $d\le29$, $1.9\cdot10^{-8}$ at $d=30$, $\ge2\varepsilon_d$ on $[33,1000]$, ratio $0.718$ at $d=33$, maximum $2.26\cdot10^{-7}$ at $d=35$, $8.5\cdot10^{-8}$ at $d=60$ | first positive $d=30$ ($1.928\cdot10^{-8}$); first $d$ with bound $\ge2\varepsilon_d$ is 33, no exception to 1000; ratio $0.718483$; maximum $2.2584\cdot10^{-7}$ at 35; $8.548\cdot10^{-8}$ | ✓ |
| §4, $c=1$, $a=1/d$: $1.80\cdot10^{-7}<2\varepsilon_{33}=1.88\cdot10^{-7}$; $\ge2\varepsilon_d$ on $[34,1000]$; ratio $0.748$ at 34 | $1.805\cdot10^{-7}$ against $1.881\cdot10^{-7}$; first $d$ is 34, no exception; $0.748261$; maximum $2.0484\cdot10^{-7}$ at 35 | ✓ |
| Widths at $d=30$ | $N_0(1/n)=5.746\cdot10^{31}$; $N_0(1/d)=4.485\cdot10^{16}=4.177\cdot10^7n$ | ✓ |
| Prop. 5.3 table, $c=0.1\sqrt M$, $M=2^{10}$: $0.015$ | $0.015487$; the $c=1$ row $0.09308,0.27941,0.41570,0.47385,0.48303,0.48478$; limit $0.104408$; threshold $0.34815$ | ✓ |
| Prop. 5.3 proof | $Q\le s\le M\Rightarrow2\sqrt Q+1\le3\sqrt M$; $Q^-\le M\beta_d\le M$; $(\sqrt q-r)_+^2\ge q-2r$ for $q\le1$ (both cases); $2\sqrt3<4$ | ✓ |
| Remark 5.2a: $\Delta=0.6449$, $\Delta^2/6=0.0693$ | $\Delta=0.644864$, $0.069308$; grid minimum over monotone fits $0.06931$ | ✓ |
| Remark 5.3a: $1/(2e)>1/7$; $e^{-b}/2$; $M\ge n/(\lambda+1)$; $\lvert\mathcal U\rvert/n\approx0.368$ | $0.18394>0.14286$; $M>n/(\lambda+1)$ for every $M=2^k$, $k<40$, at four values of $\lambda$; `every_learner_dn.out`: $0.3676$ at $n=10^6$ | ✓ |
| Remark 5.4: test excess at most $0.003$ | ball rows of `opt_hadamard.out`: $0.003,0.000,0.001,0.000$ | ✓ (nit 4) |

### 2.5 Quantifiers and limit order

- **Corollary 5.2(b).** The negation of (P$_2^{o(1)}$) is supplied at $N=\max\{N_0(a_d),\lceil n^\alpha\rceil\}$, with $\limsup_{\sigma\downarrow0}$ of the probability at most $\rho_n$: an iterated limit, $\sigma\downarrow0$ at fixed $(d,n,N)$ and then $d\to\infty$. ✓
  - The step "without loss of generality $\epsilon_n>0$" is valid. The property is monotone in $\epsilon_n$, and $\max\{\epsilon_n,1/n\}$ is positive and tends to 0.
  - The (R1′) step of (a) holds: $(1-\eta)(1+2\varepsilon)>1+\varepsilon$ iff $\eta<\varepsilon/(1+2\varepsilon)$. Its $\sigma_0$ is uniform over samples, so "on $\mathcal E_d$" and "for $\sigma<\sigma_0$" can be read in either order. ✓
- **Remark 5.3a.**
  - The new step "One law" is correct. If the property held, each of the $2^n$ laws $D_\theta$ would have a threshold $\sigma_0(\theta)$. Below their positive minimum the average over $\theta$ would be at least $1-\delta$, which contradicts the $o(1)$ bound, valid for every learner and every $\sigma$.
  - The Gibbs-risk step is correct. Given the sample, $q_j=\Pr_\xi(s_j(\xi)=-\theta_j)$ depends on $\theta_j$ alone and has conditional mean $1/2$.
  - The competitor bound $\lvert g_\theta(e_j)-\theta_j\rvert=n^\alpha(n^{-\alpha}-\tanh n^{-\alpha})\le n^{-2\alpha}/3$ holds. ✓
- **The large-$c$ paragraph.** The thresholds depend on $(N,n,c)$ and not on the sample. The failure is shown at each width separately, which is all the negation needs. ✓
- **Measurability (§1.4).** $F_{c,S}(w)$ is jointly continuous. $Z_\sigma(S)$ is positive and continuous by dominated convergence with $e^{-F/(2\sigma^2)}\le e^{-\kappa_N/(2\sigma^2)}$. Under (R1), $A_S$ does not depend on $S$ for a fixed law. So the kernel statement and Tonelli's theorem apply. ✓

---

## 3. Issues, most severe first

### Issue 1 (minor; quantifier in a displayed bound). (5.7a) and the Theorem 6.3 bullet state B's bounds "for the clipped readings" at confidence $1-\delta$

**Where.**

- Remark 5.7a, the Theorem 6.3 bullet: "with probability at least $1-\delta$ and at every learner width $N\ge m$, the clipped readings have excess over $L_D(g)$ at most $(E_*+1)n^{-\theta}+\dots+(4+(U+1)^2)\sqrt{\ln(2/\delta)/(2n)}$".
- The sentence introducing (5.7a): "with probability at least $1-\delta$ and at every $N\ge m$, the clipped readings have [(5.7a)]".

**Problem.**

- As B proves them, these bounds hold on an event of probability at least $1-\delta$ for three objects: every near-minimizer, and the $\limsup_{\sigma\downarrow0}$ of the clipped Gibbs risk and of $L_D(\bar f_\sigma)$.
- "The clipped readings" in §1.4 include (R1), (R1′) and (R2) at every $\sigma<\sigma_0$. For these the note's own "Passage to the readings" gives the bound only in an adjusted form:
  - with $\ln(4/\delta)$ in place of $\ln(2/\delta)$, because B is applied at $\delta/2$;
  - with an added $4\eta$ under (R1′) and (R2).
- Applying B at $\delta$ directly gives probability $(1-\delta)(1-\eta)<1-\delta$ under (R1).
- So (5.7a), read literally for the readings, is not what is proved.
- The Corollary 8.1 bullet and the class paragraph do this accounting correctly, so no conclusion changes. But (5.7a) is a numbered display that other documents may cite.

**Fix.**

- Say that (5.7a) holds, with probability at least $1-\delta$, for every near-minimizer and for the $\sigma\downarrow0$ limits of the clipped Gibbs risk and of $L_D(\bar f_\sigma)$.
- Add that the readings of §1.4 at $\sigma<\sigma_0$ satisfy it with $\ln(4/\delta)$ in place of $\ln(2/\delta)$, plus $4\eta$ under (R1′) and (R2), by the passage paragraph.
- Word the Theorem 6.3 bullet the same way.

### Nit 2 (§6, erratum for RT §0 item 6, numerics bullet). "Every near-minimizer" needs the width

"Every near-minimizer leaves at most $(1-\phi)G+c$" holds at the run's width, and at larger widths by zero padding. At smaller widths $\min F_c$ may exceed the value found, and then it can fail. §7.1 and the erratum for RT Appendix A say "at the run's width"; this bullet does not. Add "at the run's width".

### Nit 3 (Remark 5.7a, large $c$: first consequence and the last table row). Write "$n/c\le n^{o(1)}$"

"$n/c(n)=n^{o(1)}$, that is, $c(n)\ge n^{1-\epsilon}$ eventually for every $\epsilon>0$" equates a two-sided condition with a one-sided one. The table row "$n/c=n^{o(1)}$, that is $c\ge n^{1-o(1)}$" does the same.

- The two-sided form excludes $c\gg n$. For example, at $c=n^2$, $n/c=n^{-1}$.
- The argument covers that case ($K\le2$), and the "that is" clauses state it correctly.

Write "$n/c(n)\le n^{o(1)}$", or "$K=n^{o(1)}$", in both places.

### Nit 4 (Remark 5.4, "What is not settled"). State the width of the cited optimisation

The cited runs (`opt_hadamard.out`) are at learner width $N=8$, with $M=d\in\{64,256\}$. Remark 5.5 stresses that small widths behave differently. The Hadamard memorizer of Proposition 5.3 does exist at width 8, so the runs are not empty evidence. But local optimisation at width 8 cannot rule out cheaper memorizers at large widths. Add "at width $N=8$". The number $0.003$ is right.

### Nit 5 (§0, "Not covered"). The small-width parenthetical needs the range of $c$

"At widths $N=o(n/\log^2n)$, clipped near-minimizers have vanishing excess on this example" needs $n^{-O(1)}\le c\le\mathrm{poly}(d)$, as Remark 5.5 states. For $c$ below every power of $n$, $\ln K'\asymp\ln(n/c)$ is not $O(\log n)$, and the grid term of the display need not vanish. Add the range, or "for the $c$ of Remark 5.5".

### Nit 6 (§0, "Relation to the open items of B"). "Supersedes item (iii)" is broad

The note does settle the negative side for (P$_2$) at every $c\le\mathrm{polylog}(n)$. For the "$+o(1)$" formulation, the negative side at polylogarithmic $c$ with $c\log n\to\infty$ (for example $c=\log n$) remains open, as the third bullet says.

Suggested wording: "supersedes item (iii) for (P$_2$), and for the '$+o(1)$' formulation when $c\le\nu/\log_2n$". The next sentence, "narrows the §0 item", is right.

### Nit 7 (§9, row logic 6). "Refuted iff" is no longer true as stated

"The dichotomy 'refuted iff $\liminf c\log n<\infty$' over all $n$" describes what Corollary 5.2 refutes. After the large-$c$ paragraph, SP$_c$ also fails for $c\ge n^{1-o(1)}$, so as a statement about refutation the "iff" is false. Write "refuted by Corollary 5.2 iff".

### Nit 8 (§0.5 item 3). "One law at every $\sigma$"

Remark 5.3a proves, by contradiction, that some law $D_\theta$ fails at arbitrarily small $\sigma$, below the minimum of the $2^n$ thresholds. It does not prove that one law fails at every $\sigma$. The remark itself is correct; only the change log misdescribes it. Write "to one law at arbitrarily small $\sigma$".

### Nit 9 (§8, C3). "At the adopted $a=1/d$ it is larger" needs $c\le\mathrm{poly}(d)$

The comparison $\vartheta_cn/d>2$ holds iff $c<(n/(2d)-1)/(18d)$, that is, roughly $c<n/(36d^2)$. That covers Corollary 5.2's range $c\le\mathrm{poly}(d)$, but not every $c$. Add "for $c\le\mathrm{poly}(d)$".

### Nit 10 (§7, row `prop91_l2.py`). What the script asserts, and which weight it uses

- The row says the script checks "the lower bound $(1-\eta_0)^2$". The script prints $(1-\eta_0)^2$ but asserts nothing about it: the lower bound is B's proof, and the asserted items are $\eta_0\le1/2$, $\omega^2\ge2$, $\omega\le v\le1.5\omega$, the weight bound and the Lipschitz ratio.
- Its entry points $10^6,10^{16},\dots$ use the competitor's actual largest weight $v\approx\sqrt K$, not the bound $1.5\max\{\sqrt2,\sqrt K\}$ that Remark 5.7a quotes. With the bound the entry points would be $10^9$, $10^{21}$, $10^{144}$ (§2.1).

Write "prints $(1-\eta_0)^2$", and "with its actual weights".

### Nit 11 (record-keeping)

- The header says the material added in answer to the first check "has not been reviewed". Once this report is recorded, update that sentence and add this check to §9.
- In §6, under "Corrections to §5 itself, now replaced by this note", the item for the RT §5 "Open" paragraph is still phrased as an edit ("Add: …") to a section that is now a pointer. Phrase it as a record, as the other items of that group are.

### Optional 12 (§0.2, row 1). "Other $c$ are not settled here" understates what the note proves

(5.7a) with a fixed competitor already gives (P$_2$) for the clipped readings for every $c(n)$ with $n^\epsilon\le c(n)\le n^{1-\epsilon}$, for a fixed $\epsilon>0$, with a polynomial sample size whose degree depends on $\epsilon$. Its terms are at most $(E_*+1)n^{-\epsilon}$, $8\sqrt2D_nn^{-\epsilon/2}$ and $O(\sqrt{\log(1/\delta)/n})$. The row may say so, or say "not settled for $c$ outside these ranges". As written it is not wrong.

---

## 4. Status of the second-round issues and of the first check

| Report, issue | Status in the final candidate |
|---|---|
| logic 1 (major): $N\ge1$ in (P$_2^{o(1)}$) | **fixed**. §1.4 asks for $N\ge n^\alpha$; Cor. 5.2(b) uses $N=\max\{N_0(a_d),\lceil n^\alpha\rceil\}$; Remark 5.2a records the example. No stale use of $N\ge1$ remains; the remaining occurrences are historical or concern Proposition 5.3's construction |
| logic 2 (major): uniformity over $d\le n$ is false for every learner | **fixed**. Remark 5.3a proves it, now with the one-law step and (R1′). No claim that Proposition 5.3 refutes a formulation remains |
| logic 3: open range overstated | **fixed**, and now with a source for the upper end (B Proposition 9.1) |
| logic 4: RT §0 item 6 headline; "precisely" | **fixed** |
| logic 5: fixed-$d$ row | **fixed** |
| logic 6 (optional): $\liminf_ddc_d<\infty$ | **declined**, with an accurate reason; nit 7 on one phrase |
| logic 7: §8 C3 | **fixed**; nit 9 on the range of $c$ |
| logic 8: measurability; (R1′) | **fixed** |
| logic 9: "but not the $+o(1)$" summary | **fixed**. The phrase appears only as a quotation of the withdrawn RT text |
| computation 1: $0.016\to0.015$ | **fixed** ($0.015487$) |
| computation 2: lower bounds rounded up | **fixed** ($\phi\ge0.395/0.577$; near-minimizers $0.389/0.576$; certified in §7.1) |
| computation 3: $Q^+\le2M$ | **fixed** ($Q\le s\le M$; $2\sqrt3<4$) |
| computation 4: Lemma 1.2 for general atoms | **fixed** |
| computation 5: fixed-$d$ row, bounded $c$ | **fixed** |
| computation 6: iterated limit in Cor. 5.2(b) | **fixed** |
| computation 7: $a=1/n$ versus $a=1/d$ | **fixed** |
| computation, script remark | **fixed** (200 digits; no decrease) |
| First check: S1 (B Proposition 9.1) | **fixed** and re-derived here (§2.1) |
| First check: S2, LC2 (Remark 5.3a) | **fixed** (§2.5) |
| First check: S3 ($\epsilon_n$ independent of $\delta$; passage to the readings) | **fixed** (§2.3); issue 1 on two displays |
| First check: S4, LC1 (unit-ball wording); S5 (one learner) | **fixed** |
| First check: S6(a)–(c) | **fixed**; nit 6 on (a) |
| First check: S6(d) | **declined** (optional) |
| First check: LC3–LC9 | **fixed**; nit 2 on LC8's companion bullet |

The six older author scripts in `../checks/depth-two/` are byte-identical to the copies the first check re-ran, and their four re-run outputs are identical to the published ones. So "No existing script changed" holds.

---

## 5. Scripts and outputs (staging folder, `../checks/depth-two-referee-logic-computation-2/`)

| Script | What it checks | Result |
|---|---|---|
| `rr2_rt54.py` | §7.1: samples rebuilt from the seeds, statistics by dictionaries and exact fractions; run files parsed field by field; $\phi$, $\phi_{\rm cert}$, near-minimizer capture, Lemma 1.2(a),(b) bounds; consistency $\kappa_N+\mathcal R/c$ against $F_c-W/c$; the sweep arithmetic | every value in §7.1 and the errata reproduces (`rr2_rt54.out`) |
| `memorize_opt2_copy.py` | unmodified copy of `../checks/red-team-and-literature/memorize_opt2.py` (checked with `cmp`) | `rerun_d10_L2_c1.txt`, `rerun_d8_L2_c4.txt` and `rerun_d8_L2_c16.txt` match the recorded run files to every printed digit; times in the `.time` files |
| `rr2_prop91.py` | Remark 5.7a, large $c$: $\eta_0\le1/2$; the $(1-\eta)^2$ bound by grid; competitor fit and weights at 60 digits; exact entry points by bisection, with actual weights and with the bound; a first Lipschitz search with a regularised denominator; direct minimisation of $F_{n/4}$ on $D_{1/5}$ | all as stated (`rr2_prop91.out`) |
| `rr2_lipschitz.py` | B Lemma 2.1(b) at $L=2$, $d=1$: unregularised adversarial maximisation of the Lipschitz ratio, every maximiser re-evaluated at 60 digits | largest 60-digit ratio $1-7\cdot10^{-18}$; floating-point ratios above $1+10^{-12}$ only at $\lvert x-x'\rvert\le8\cdot10^{-12}$ (cancellation) (`rr2_lipschitz.out`) |
| `rr2_numbers.py` | §4 numbers for $a=1/n$ and $a=1/d$, $d\le1000$, 80 digits; Prop. 5.3 table; Remarks 5.2a and 5.3a; Remark 5.7a exponents, class constants, the $\epsilon_n$/$n_\delta$ construction on a grid, the rate at $c=\ln^3n$; the fixed-$d$ constants | all as stated (`rr2_numbers.out`) |
| `author_rerun/` | copies of `prop91_l2.py` and `rt54_record.py` with the run files they read, re-run | outputs byte-identical to `../checks/depth-two/prop91_l2.out` and `rt54_record.out`; 0.45 s and 0.09 s |
