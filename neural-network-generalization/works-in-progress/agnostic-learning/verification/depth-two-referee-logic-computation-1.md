# Re-referee report (logic and computation of the changed passages): `../research-notes/depth-two.md`, final candidate

*Published record of a referee report on the final candidate of the note, made during finalization. Paths under `stage/` refer to the lead's unpublished working copies; the pre-revision text there is the version that the second-round referee reports reviewed, published as [`depth-two-first-version.md`](depth-two-first-version.md). The referee's scripts and outputs are in the `../checks/depth-two-referee-*` folder named below. Re-runs of the note's own scripts (`author_rerun/` and similar subfolders) are not published; the report says whether they reproduced the recorded outputs.*

**What was refereed.** I refereed the passages of `../research-notes/depth-two.md` that changed relative to the pre-revision text, which is the text the second-round referees read. I diffed the two versions: 64 hunks, grouped by passage in §1. For each changed passage I did three things:

- re-derived every statement, constant and number in it;
- checked its quantifiers and the limit order: $\sigma\downarrow0$ comes after $n$, the sample and the width are fixed;
- checked it against the source it cites. The sources are `../research-notes/B-tempered-likelihood.md` (Lemmas 2.2, 2.3, 3.1, 5.3, Proposition 6.1 and the paragraph after it, Theorems 6.3–6.4, §7 opening, §7.5, Corollary 8.1), `../research-notes/A-tight-conditioning-fails.md` (§5.1, Proposition 5.2, §5.4), `../research-notes/small-learner-width.md` (Theorem 1(c)), `../research-notes/problem-brief.md` §1–2, and the staged `red-team.md` (§0 item 6, §2.3 A3, §5, §6.1, §6.4, §7, Appendix A).

I also checked that each issue of the second-round reports, `RT-depth2-logic-revised.md` (issues 1–9) and `RT-depth2-computation-revised.md` (issues 1–7 and the script remark), is resolved as §9 of the note says.

Unchanged passages were not re-refereed; both second-round referees found every proof correct. Where a changed sentence quotes an unchanged result, I checked only the quotation.

**Lens.** Logic and computation.

**Scripts.** The scripts are new and independent of the author's. They sit in the staging folder next to this report, under `../checks/depth-two-referee-logic-computation-1/` (§5):

- they compute the binomial statistics by a falling-factorial log sum, not the author's pmf recursion;
- they take the worst case on the event directly from the displayed formulas of §4;
- they search width-one networks by their own routine.

I also re-ran, from a copy of `../checks/depth-two/`, the four author scripts that §7 says were changed or re-run: `t1_range.py`, `prop53_check.py`, `bounds_t51.py` and `lemma_checks.py`. All four outputs are byte-identical to the published `.out` files.

---

## Verdict: minor fixes

**The three issues that the second-round logic referee raised as definition and scope flaws are fixed, and no new error of substance was introduced.**

1. **Issue 1 is fixed.** (P$_2^{o(1)}[\phi]$) now asks for the bound at every learner width $N\ge n^\alpha$. This matches `B-tempered-likelihood.md` Corollary 8.1 ("simultaneously for all learner widths $N\ge n^\alpha$"), and the brief's $N\ge m$. Corollary 5.2(b) and its proof use the width $N=\max\{N_0(a_d),\lceil n^\alpha\rceil\}$, which is legitimate because failure is shown at every $N\ge N_0(a_d)$.
   - The amended property is satisfiable. Remark 5.7a, which I checked line by line against B, shows that SP$_c$ has it for $\log^2n\ll c\le n^{1-\epsilon}$. So the refutation for $c\le\nu/\log_2n$ now says something about SP$_c$ specifically.
   - Remark 5.2a's width-one example is correct: $\Delta=0.64486$, and $\Delta^2/6=0.06931$ equals the minimum my search found over width-one networks, clipped or not.
2. **Issue 2 is fixed.** No sentence still says that Proposition 5.3 refutes a formulation.
   - Remark 5.3a's impossibility argument is correct, with one quantifier step to write out (issue 2 below).
   - The constants check: $1/(2e)=0.184>1/7$, $\lvert U\rvert/n\to e^{-1}$, and the $d=\lceil n/b\rceil$ variant gives $e^{-b}/2$.
3. **Issue 3 is fixed.** The open range is now $c\log n\to\infty$ with $c=O(\log^2n)$ for the clipped readings and $c=O(\sqrt n\log n)$ for the unclipped ones. It is stated consistently in §0, §0.2, Corollary 5.2(c), Remarks 5.7a and 5.8, and the §6 errata. The combination of B's statements in Remark 5.7a is correct:
   - (5.7a) is B's Proposition 6.1 with Lemma 5.3(a) at $H=1$, $K=n/c+1$ and $\delta'=\delta/2$;
   - $E_*+1\le(d(d+1)+4)n^{4\alpha}$ and $4+(U+1)^2\le8n^{4\alpha}$;
   - the exponents give $\alpha<\min\{1/8,\epsilon/4\}$;
   - the $\epsilon_n$/$n_\delta$ construction is right, with $\sigma_0$ free to depend on $n$ and $\delta$;
   - the unclipped variant is of order $D_n\sqrt n/c$.

**Every changed number reproduces** (§2), and the six minor second-round items and the computation items are resolved as §9 states. Logic issue 6, an optional strengthening, is declined. Declining it is acceptable, but the stated reason is partly inaccurate (issue 7 below).

**What remains** is three minor issues and six nits, all wording or proof presentation. None changes a theorem, a regime or a status entry:

- §0.2 row 3 and the RT §6.1 erratum misstate the unit-ball case;
- Remark 5.3a passes over the dependence of its law $D_{\theta_n}$ on $\sigma$ and does not cover the Gibbs-risk reading explicitly;
- the §8 preamble misdescribes how §8 was edited;
- plus six nits (§3).

---

## 1. Changed passages and what was checked

| Passage (revised text) | Change | Check | Result |
|---|---|---|---|
| Header | refereeing record; Remarks 5.2a, 5.3a, 5.7a flagged as not refereed | consistency with §§8–9 | ✓ (after this report the flag can cite it) |
| §0 "What is refuted …" (new) | five-bullet summary | each bullet against Cor. 5.2, Remarks 5.3a, 5.5, 5.7a | ✓; "lower bound tends to 0 only polylogarithmically" correct, since $(18dc+1)^{-2}\ge1/\mathrm{poly}(d)$ for $c\le\mathrm{poly}(d)$ |
| §0.1 items 1–3 | (R1′), widths $N\ge n^\alpha$, Prop. 5.3 reframed | against Thm 5.1(3), §1.4, Remark 5.3a | ✓ |
| §0.2 row 1 | (P$_2$) holds at $c=n^{1-\theta}$ ($\theta<1$ clipped, $\theta<1/2$ unclipped) | B Thm 6.3 ("any $\theta\in(0,1)$ when $H=1$", every $N\ge m$, $n_0$ polynomial) and Thm 6.4 ($\theta<1/L=1/2$) | ✓ |
| §0.2 row 2 | holds / open ranges | Remark 5.7a, re-derived (§2.3) | ✓ |
| §0.2 row 3 | "false for every learner"; Prop. 5.3 reframed | Remark 5.3a; Remark 5.4 | ✓, except the unit-ball parenthetical (issue 1) |
| §0.2 row 4 | $(8\cdot2^d/\delta+4c)/n$ w.p. $\ge1-\delta-2^de^{-n/2^{d+3}}$ | A Prop. 5.2(c) at $t=1$: $(8M/\delta'+4ct)/n$, $1-\delta'-Me^{-n/(8M)}$; simulation | ✓ (simulated frequency 1.000 against guaranteed 0.8946/0.8785/0.9500) |
| §0.2 restrictions, §0.3–0.4 | widths, readings, change log | consistency with body | ✓ |
| §1.3, Lemma 1.2 | general finite atom set $\mathcal A$ | proof unchanged and atom-free; $Q\le s\le\min\{n,\lvert\mathcal A\rvert\}$; $L_D=1+\lvert\mathcal A\rvert^{-1}\sum f^2$ for uniform atoms with fair signs | ✓ |
| §1.4 (P$_2^{o(1)}[\phi]$) | $N\ge n^\alpha$ | against brief §1, B Cor. 8.1 | ✓ |
| §1.4 "Learner widths" | why the refutations apply | $N=\max\{N_0,\lceil n^\alpha\rceil\}$; single-width variants; widths below $N_0$ | ✓ |
| §1.4 (R1′), clipped/unclipped readings | new reading | used in Cor. 5.2(a),(b), Remark 5.6 | ✓ |
| §1.4 measurability | joint continuity, kernel, Tonelli | $F_{c,S}(w)$ jointly continuous; $Z_\sigma(S)>0$ continuous by dominated convergence ($F\ge\kappa_N$); the event $A_S$ in fact does not depend on $S$ | ✓ |
| Cor. 5.2(a), (R1′) step | new | $(1-\eta)(1+2\varepsilon_d)>1+\varepsilon_d\iff\eta<\varepsilon_d/(1+2\varepsilon_d)$ | ✓ |
| Cor. 5.2(b) and proof | width; $\limsup_{\sigma\downarrow0}$ of the probability $\le\rho_n$ | quantifiers (§2.4) | ✓; edge case $\epsilon_n\le0$ (nit 4) |
| Cor. 5.2(c) | pointer | — | ✓ |
| §4 "Numbers" | $a=1/n$ and $a=1/d$ separated | recomputed (§2.1) | ✓ |
| Remark 5.2a (new) | width-one example | recomputed (§2.2) | ✓ |
| Prop. 5.3 proof | $Q\le s\le M$ in place of $Q^+\le2M$; $2\sqrt3<4$ | re-derived; rate constant computed (§2.1) | ✓ |
| §5 table | $0.016\to0.015$ | recomputed | ✓ ($0.01549$) |
| "What it shows" bullet | Prop. 5.3 reframed | — | ✓ |
| Remark 5.3a (new) | impossibility at $d\asymp n$ | re-derived (§2.2) | ✓ with issue 2 |
| Remark 5.4 | wording; opt_hadamard evidence | `../checks/verify-RT-depth2-logic/opt_hadamard.out`: ball rows have test excess 0.003, 0.000, 0.001, 0.000 | ✓ |
| Remark 5.5 | widths $N\ge n^\alpha$; Theorem 1(c) | small-learner-width.md Thm 1(c): $K'=E_*+1+n(U+1)^2/c=d^2+d+3+4n/c$ at $m=B=1$, $L=2$; probability $1-\delta/2\ge1-\delta$ | ✓ |
| Remark 5.6 | readings named | — | ✓ |
| Remark 5.7a (new) | B at depth two; general $c$; status table; $c=\log^3n$ | re-derived (§2.3) | ✓; nit 6 |
| Remark 5.8 items 1, 4 | open range; Prop. 5.3 under unit ball | consistency | ✓ |
| §6 errata | RT §0 item 6, §2.3 A3, §6.1, §6.4, §7 item 3, §5 corrections | against staged `red-team.md` sentences; numbers | ✓; issue 1 (§6.1), nits 5, 8 |
| §7 | script table and change paragraph | re-ran scripts; outputs identical | ✓ |
| §8 | preamble; L2, L3, C2, C3 bullets | diff against pre-revision §8 | content ✓; preamble inaccurate (issue 3) |
| §9 | resolution table | each row against the revised text | ✓ (logic 6: nit 7) |

---

## 2. Re-derivations and recomputations

### 2.1 Numbers in §4, §5 and §7

**$c=1$, $\lambda=1$, worst case on $\mathcal E_d$** (`rr_numbers.out`, N1; independent binomial evaluation, 120 digits):

| | $a=1/n$ | $a=1/d$ |
|---|---|---|
| first $d$ with a positive bound | 30, and positive at every $d\in[30,1000]$ | 30, and positive at every $d\in[30,1000]$ |
| bound at $d=30$ | $1.928\cdot10^{-8}$ | $1.168\cdot10^{-8}$ |
| first $d$ with bound $\ge2\varepsilon_d$; exceptions up to 1000 | 33; none | 34; none |
| $d=33$ | $2.027\cdot10^{-7}\ge2\varepsilon_{33}=1.881\cdot10^{-7}$ (ratio $0.718483$) | $1.805\cdot10^{-7}<1.881\cdot10^{-7}$ (ratio $0.6395$) |
| ratio at $d=34$ | $0.8309$ | $0.748261$ |
| decreases of the ratio on $[31,1000]$ | 0 | 0 |
| maximum | $2.2584\cdot10^{-7}$ at $d=35$ | $2.0484\cdot10^{-7}$ at $d=35$ |
| $d=60$ | $8.548\cdot10^{-8}=\gamma(1)\vartheta_1^2$ to 4 digits | — |

Every value quoted in §4 "Numbers" and in the §7 table reproduces: $1.80\cdot10^{-7}<1.88\cdot10^{-7}$ at $d=33$, $0.748$ at $d=34$, "positive from $d=30$ for both $a$", and "the ratio never decreases".

**Table after Proposition 5.3** (N2). The values are
- $c=1$: $0.09308$, $0.27941$, $0.41570$, $0.47385$, $0.48303$, $0.48478$;
- $c=0.1\sqrt M$: $0.01549$, $0.06187$, $0.09301$, $0.10326$, $0.10429$, $0.10441$, with limit $0.104408$.

The three-decimal table, including the corrected $0.015$, is right.

**Proposition 5.3, case $c\le\sqrt M$, as now proved** (N3, `rr_n3_fullgrid.out`). The argument has four steps:
- $Q\le s\le M$ gives $2\sqrt Q+1\le3\sqrt M$;
- hence $\mathcal R^{\rm H}_{\max}/M\le3cM^{-1/2}+n/(9Q^-M)$;
- hence $\sqrt{\mathcal R^{\rm H}_{\max}/M}\le\sqrt3\sqrt cM^{-1/4}+O_\lambda(M^{-1/2})$;
- finally $(\sqrt q-r)_+^2\ge q-2r$ for $q=Q^-/M\le1$.

All four steps are correct, and the remainder is uniform in $c$. On the event, the worst case of
$$\bigl(\beta(1)-2\sqrt3\sqrt c\,M^{-1/4}-\text{bound}\bigr)M^{1/3}$$
over $M=2^8,\dots,2^{120}$ and $c\in[1/M,\sqrt M]$ is $2.07$. So the $O_\lambda(M^{-1/3})$ term has constant about $2$ at $\lambda=1$; it comes from $h=2n^{2/3}/M$. The statement keeps the weaker constant 4, which is fine.

**Author's scripts.** `t1_range.py` (200 digits), `prop53_check.py`, `bounds_t51.py` and `lemma_checks.py` re-run byte-identically. The old outputs differ from the new ones only where §7 says they do: the five-decimal part (2) of `prop53_check.out`, and the extended `t1_range.out`.

### 2.2 The two new examples

**Remark 5.2a** (N4).
- $g^*(\pm1)=\frac12(\tanh3-\tanh1)=0.11673$ and $g^*(0)=\tanh1=0.76159$, so $\Delta=0.64486$.
- The weights of $g^*$ are the rows $(1,\pm2)$ and the readouts $\frac12,\frac12$, so they lie in $[-2,2]$. Also $\sup\lvert g^*\rvert<1$.
- A width-one network $v\tanh(\omega_0+\omega_1x)$, and its clip, is monotone in $x$.
- The isotonic fit of $(a,b,a)$ with $b>a$ pools one adjacent pair, leaving squared error $2(\Delta/2)^2$ over 3 points. That is $\Delta^2/6=0.06931$.
- 600 Nelder–Mead restarts over width-one networks reach $0.06931$, clipped and unclipped.

The remark also covers (R1′), since a Gibbs risk averages losses that are each at least $0.0693$. (R2) escapes the example, because a mixture of monotone functions need not be monotone. The remark claims only (R1) and (R3), which is correct.

**Remark 5.3a** (N5).
- **Competitor.** $\lvert n^\alpha\tanh(n^{-\alpha})-1\rvert\le n^{-2\alpha}/3$; checked at $(n,\alpha)=(10^3,0.1)$, $(10^6,0.1)$ and $(10^6,0.25)$. The competitor $g_\theta$ lies in $\mathcal G^{(\alpha)}_n$, because $n^\alpha\ge1$ and $n^{-\alpha}\le n^\alpha$.
- **Unseen atoms.** $\lvert U\rvert/n=0.3678$ at $n=10^6$.
- **The constant.** $1/(2e)=0.18394>1/7$.
- **The $d=\lceil n/b\rceil$ variant.** The fraction of atoms forced to be wrong is $0.0673$ against $e^{-2}/2=0.0677$ at $b=2$, and $0.0255$ against $e^{-3}/2=0.0249$ at $b=3$.
- **Proposition 5.3's regime.** $d=M>n/(\lambda+1)$, since $n=\lceil\lambda M\rceil<(\lambda+1)M$. So $\lceil n/(\lambda+1)\rceil\le M$, and any $\phi$ covering Proposition 5.3's dimensions covers this case.
- **Gibbs-risk variant.** Given the sample, $n^{-1}\sum_{j\in U}\Pi(s_j(w)=-\theta_j)$ is a sum of independent $[0,1]$ terms with mean $\lvert U\rvert/(2n)$. In simulation it stays above $0.18$.

### 2.3 Remark 5.7a against `B-tempered-likelihood.md`

- **Theorem 6.3 at $H=1$.** $8(2/H)^{H/2}D_nn^{-(1-\theta H)/2}=8\sqrt2D_nn^{-(1-\theta)/2}$. Also $D_n=\sqrt{2(d+1)\ln(n+1)}+(H-1)/2=\sqrt{2(d+1)\ln(n+1)}$, and B states "any $\theta\in(0,1)$ when $H=1$". ✓ Theorem 6.4 needs $\theta<1/L=1/2$. ✓
- **Corollary 8.1 at $H=1$.** $\theta=(1+8\alpha)/3$, so $c=n^{(2-8\alpha)/3}$. For $\alpha\in(0,1/8)$ the exponent runs over $(1/3,2/3)$. The constant is $\Xi_n=d(d+1)+2L+8\sqrt2\sqrt{2(d+1)\ln(n+1)}+4\sqrt{2\ln(2/\delta)}$ with $2L=4$, and $\beta=\min\{(1-4\alpha)/3,\frac12-4\alpha\}>0$ iff $\alpha<1/8$. These match the remark, and so does "B allows $\alpha<1/4$".
- **(5.7a).** Lemma 5.3(a) with $K=n/c+1$ and $\delta'=\delta/2$ gives $8\sqrt K\,D_n/\sqrt n=8D_n\sqrt{1/c+1/n}$ plus $4\sqrt{\ln(2/\delta)/(2n)}$. Proposition 6.1 adds $c(E_*+1)/n$ and $(U+1)^2\sqrt{\ln(2/\delta)/(2n)}$. ✓ With $g\equiv0$ as a width-one network, $E_*=d^2+d+2$ and $U=1$, which gives Remark 5.7 exactly.
- **Class version.**
  - With B's $E_*=d(d+1)B^2+2(L-1)m^2B^2$ and $U=mB$ at $m=\lfloor n^\alpha\rfloor$, $B=n^\alpha$: the largest values of $(E_*+1)/((d(d+1)+4)n^{4\alpha})$ and $(4+(U+1)^2)/(8n^{4\alpha})$ over a grid are $0.9997$ and $1.0000$ (N7).
  - The minimizer over $\mathcal G^{(\alpha)}_n$ exists, because the parameter set is compact and $L_D$ is continuous. It depends only on $D$ and $n$, so it is a fixed competitor for B's events.
- **Rates.** At $d\le\log_2n+C_0$ the three terms are $O(n^{4\alpha-\epsilon}\log^2n)$, $O(\log n/\sqrt c)$ and $O(n^{4\alpha-1/2})$.
  - The two remaining steps are right. The first two terms increase in $d$. The third term divided by $n^{2\alpha-1/4}$ is $8\sqrt{\ln(2/\delta)/2}\,n^{2\alpha-1/4}\to0$, so it eventually lies below $n^{2\alpha-1/4}$.
  - The extra $4\eta$ in B's statement for the clipped Gibbs risk and for $\bar f_\sigma$ is absorbed in the same slack: choose $\eta$ for each $n$, which is allowed because $\sigma_0$ may depend on everything except the sample.
- **Unclipped variant.** Lemma 5.3(b) at $H=1$ gives $4(\sqrt K+1)\sqrt K\,D_n/\sqrt n+(\sqrt K+1)^2\sqrt{\ln(2/\delta)/(2n)}$, which is of order $D_n\sqrt n/c$. Replacing only the middle term of (5.7a) keeps a redundant $4\sqrt{\cdot}$, which is conservative. Sample uniformity comes from Lemma 3.1 with Corollary 3.2 and $\Phi=L_D(z_w)\le2F+2$. ✓
- **$c=\log^3n$.**
  - The middle term times $\sqrt{\ln n}$ stays between 13.6 and 14.3 for $n=2^{20}$ to $2^{320}$, so the rate is $O(1/\sqrt{\log n})$.
  - $c=O(d^3)$ along the family, so Corollary 5.2(a) applies. The two formulations do differ there.

### 2.4 Quantifiers and limit order

- **Cor. 5.2(b): negation of (P$_2^{o(1)}$).** The property has the form ∃$\alpha$ ∃$\epsilon_n$ ∀$\delta$ ∃$n_\delta$ ∀$n\ge n_\delta$ ∀$d\le\phi(n)$ ∀$D$ ∀$N\ge n^\alpha$ ∃$\sigma_0$ ∀$\sigma<\sigma_0$. The proof supplies the negation:
  - every $\alpha$ and every $\epsilon_n$;
  - any $\delta$;
  - $n=\lceil\lambda2^d\rceil$ with $d$ large;
  - $D=D_d$;
  - $N=\max\{N_0(a_d),\lceil n^\alpha\rceil\}$;
  - every $\sigma$ below $\sigma_0(\eta;d,n,c,N)$.
  
  The probability bound is $\rho_n+\eta$ under (R1) and $\rho_n$ under (R1′), (R2) and (R3). The new "$\limsup_{\sigma\downarrow0}\le\rho_n$" is the correct iterated limit: $\sigma\downarrow0$ at fixed $d,n,N$, then $d\to\infty$. ✓
- **(R1′) and $\sigma_0$.** In Cor. 5.2(a), $\sigma_0$ is uniform over samples (Theorem 5.1(3), from Lemma 1.1(ii)). So "on $\mathcal E_d$ and for $\sigma<\sigma_0$" can be read in either order. ✓
- **Positive side.** Remark 5.7a uses B's $\sigma_0(N,n,c,d,H,\eta)$, which does not depend on $D$, $\delta$, $g$ or $S$ (the paragraph after B's Proposition 6.1). ✓
- **Remark 5.3a.** The law $D_{\theta_n}$ is chosen by averaging over $\theta$ for a fixed learner. For SP$_c$ the learner depends on $\sigma$ and $N$, so as written $\theta_n=\theta_n(\sigma,N)$. The property's negation needs one law and arbitrarily small $\sigma$. The conclusion holds because $\theta$ ranges over a finite set, but this step is not written (issue 2).

---

## 3. Issues, most severe first

### Issue 1 (minor; wording of a status entry and of an erratum). The unit-ball parenthetical overstates what Remark 5.4 proves

**Where.**
- §0.2 row 3: "Proposition 5.3 shows that SP$_c$ with $c=o(\sqrt n)$ is worse than the Bayes-optimal zero network by $\beta(\lambda)-o(1)$ (inputs of norm $\sqrt d$; for unit-ball inputs only for $c<\sqrt{\beta(\lambda)}/2$, Remark 5.4)".
- §6, the replacement for RT §6.1: "… by $\beta(\lambda)-o(1)$, for inputs of norm $\sqrt d$; for unit-ball inputs it shows this only when $c<\sqrt{\beta(\lambda)}/2$, not at $c=1$."

**Problem.** In both places the unit-ball clause attaches to "worse … by $\beta(\lambda)-o(1)$". Under unit-ball inputs, Remark 5.4 proves two things:
- for fixed $c<\sqrt{\beta(\lambda)}/2$, a smaller gap $\beta(\lambda)\bigl(1-\sqrt{2c/\sqrt{\beta(\lambda)}}\bigr)_+^2-o(1)$, which is $0.104$ at $c=0.1$ and $0.0025$ at $c=0.3$;
- $\beta(\lambda)-o(1)$ only when $c\to0$.

The pre-revision row 3 said "with constant $\beta(1)$ when $c\to0$"; the revision dropped that clause. §0.1 item 3 ("gives a constant only when $c<\sqrt{\beta(\lambda)}/2$") and Remark 5.4 are stated correctly. The §6.1 text is meant to be pasted into `red-team.md`, so it should be exact.

**Fix.** Write: "for unit-ball inputs it shows a constant gap $\beta(\lambda)(1-\sqrt{2c/\sqrt{\beta(\lambda)}})_+^2-o(1)$ only for $c<\sqrt{\beta(\lambda)}/2$, the full $\beta(\lambda)-o(1)$ only when $c\to0$, and nothing at $c=1$ (Remark 5.4)". Use the same wording in §0.2 row 3.

### Issue 2 (minor; quantifiers in an unrefereed remark). Remark 5.3a leaves the $\sigma$-dependence of $\theta_n$ and the Gibbs-risk reading implicit

**Where.** Remark 5.3a, "Any learner" bullet and the paragraph after it ("So, for every learner, every reading, every width and every $c$ …").

**Problem.**
- **The $\sigma$-dependence of $\theta_n$.** "Hence for each $n$ some $\theta=\theta_n$ has $L_{D_{\theta_n}}(f)>1/7$ with probability $1-o(1)$" is an averaging argument for one fixed learner.
  - Under (R1), (R1′) and (R2), SP$_c$'s output depends on $\sigma$ and $N$, so the $\theta_n$ found depends on them.
  - (P$_2^{o(1)}$) requires, for each law, a $\sigma_0$ such that the bound holds for all $\sigma<\sigma_0$. Its negation needs one law for which the bound fails at arbitrarily small $\sigma$.
  - This is true, but not by the argument as written. Since $\theta$ ranges over the finite set $\{\pm1\}^n$: if the property held, every $\theta$ would have a threshold $\sigma_0(\theta)$, and at any $\sigma<\min_\theta\sigma_0(\theta)$ the average over $\theta$ of the success probability would be at least $1-\delta$. The Hoeffding bound makes that average $o(1)$, for every learner and every $\sigma$.
- **The Gibbs risk.** The argument is written for an output $f$. Under (R1′) the learner's loss is $\mathbb E_\Pi L_{D_\theta}(z_w)\ge n^{-1}\sum_{j\in U}\Pi(s_j(w)=-\theta_j)$. Given the sample, this is a sum of independent $[0,1]$ terms with mean $\lvert U\rvert/(2n)$, so the same Hoeffding step applies. In simulation the minimum over 200 draws of $\theta$ is $0.18>1/7$ (N5).
- **Nit.** "With $d=\lceil n/b\rceil$ … so $\phi(n)\ge n/b$ is excluded": if $\phi(n)=n/b$ exactly and $n/b\notin\mathbb Z$, use $d=\lfloor n/b\rfloor$. The constant is unchanged.

**Fix.** After "Hoeffding's inequality gives …", add: "This bound holds for every learner and every $\sigma$. If (P$_2^{o(1)}$) held, then at any $\sigma$ below $\min_\theta\sigma_0(\theta)$, a minimum over finitely many $\theta$, the average over $\theta$ of the success probability would be at least $1-\delta$, which contradicts it. Under (R1′) apply the bound to $n^{-1}\sum_{j\in U}\Pi(s_j(w)=-\theta_j)$." Replace $\lceil n/b\rceil$ by $\lfloor n/b\rfloor$.

### Issue 3 (minor; record accuracy). The §8 preamble misdescribes §8

**Where.** §8, first paragraph: "This section is the response to the first round as it was made. Where the second round changed the text again, §9 says so; in particular one sentence of C3 below is corrected there."

**Problem.** Against the pre-revision text, §8 itself was edited in four bullets:
- L2: the small-learner-width.md Theorem 1(c) clause;
- L3: "via the readings of §1.4";
- C2: "with $a=1/n$", and the $a=1/d$ sentence;
- C3: the $E_0$ comparison.

The C3 correction is made inside §8, and §9's logic-7 row points there ("§8, C3"); it is not made in §9. So §8 is not "as it was made", and "corrected there" points the reader to the wrong section.

**Fix.** Write: "§8 is the response to the first round, updated in place in four bullets (L2, L3, C2, C3) to match the current text; §9 records the second round, including these updates."

### Nit 4 (Corollary 5.2(b) proof). The case $\epsilon_n\le0$

"Repeat the argument of (a) with $\varepsilon_d$ replaced by $\epsilon_n$" uses the new (R1′) step, which needs $\eta<\epsilon_n/(1+2\epsilon_n)$. That is impossible if $\epsilon_n\le0$, which the definition "numbers $\epsilon_n\to0$" allows.

The conclusion is unaffected. The property is monotone in $\epsilon_n$, so it suffices to refute it with $\max\{\epsilon_n,1/n\}$. Alternatively, run (a) with $\varepsilon_d$ replaced by $\Gamma_\lambda(\nu)/4$, which exceeds $\epsilon_n$ eventually, while $\underline\Psi_d\ge\Gamma_\lambda(\nu)/2$. Add one clause.

### Nit 5 (§6 erratum for RT §0 item 6, numerics bullet). $\varphi$ is still rounded up inside an upper bound

The run files give $\varphi=1-93.51/154.8=0.39593$ at $d=8$ and $1-267.75/634.1=0.57775$ at $d=10$ (`../checks/verify-RT-depth2-computation/rerun_d8_L2_c1.txt`, `../checks/red-team-and-literature/run_d10_L2.txt`). The bullet says "leaves training residual at most $(1-\varphi)G$, with $\varphi=0.396$ … and $0.578$". With the rounded values, $(1-\varphi)G$ is $93.499<93.51$ and $267.59<267.75$, so the stated bound is slightly stronger than what was measured.

This is far smaller than the $0.40$/$0.58$ that the second-round computation referee flagged, and the near-minimizer figures $0.389$ and $0.576$ are correctly rounded down. Still, write $\varphi\approx0.396$ and $0.578$, or state the bound with $0.395$ and $0.577$.

### Nit 6 (Remark 5.7a, third bullet). The relay of B §7.5 item 3 omits $c=o(n)$

"Vanishing excess as soon as $c\gg D_n^2$" also needs $c=o(n)$, because of the $c(E_*+1)/n$ term; with $w'=0$ in B's Remark 6.5 this term is $c/n$. B's own sentence omits this condition too. The note's Remark 5.7 states both conditions correctly ("$c/d^2\to\infty$ and $cd^2/n\to0$"). Add "and $c=o(n)$".

### Nit 7 (§9, logic 6). The reason given for declining is partly inaccurate

Declining the optional strengthening is legitimate. But "would also need Lemma 1.3 uniformly in $\lambda$, which is not proved here" overstates the gap.
- Lemma 1.3's bounds are explicit and depend on $\lambda$ only through $\lambda'=n/M$: the failure probability is $\rho_n=4e^{-n^{1/3}/2}+(4+2n/M)n^{-1/3}$, and the Poisson errors are at most $(\lambda'+1)/M$. They are therefore uniform for $\lambda\in[1,2)$.
- What is not written is the limit step of Corollary 5.2(ii) along a varying $\lambda_k$. That step needs only continuity of $\beta$ and $\gamma$, and $\min_{[1,2]}\gamma>0$.

Suggested wording: "adopting it would strengthen Corollary 5.2(b) beyond what is written out here (the limit step along varying $\lambda$), so it is not adopted".

### Nit 8 (§6 errata, coverage). RT Appendix A still overstates the captured fractions

RT Appendix A (`memorize_opt.py` paragraph) says "the captured fractions are lower bounds on what every near-minimizer captures for that sample". For near-minimizers the bound is $\varphi-c/G$, that is $0.389$ and $0.576$, not $\varphi$, because of the $+1$ slack.

This sentence summarises §5's numerics but is not among the §6 errata. The replacement for §0 item 6 states it correctly. Add an erratum, or say that Appendix A is updated together with RT §5.

### Nit 9 (Remark 5.5). Ambiguous "respectively"

"In the ranges of $c$ of Corollary 5.2(a),(b), they therefore refute width-uniform formulations, … including (P$_2^{o(1)}$)" can be read as saying that range (a) refutes (P$_2^{o(1)}$). Only range (b) does. Write "(P$_2$) in the range of (a), and also (P$_2^{o(1)}$), with its widths $N\ge n^\alpha$, in the range of (b)".

---

## 4. Status of the second-round issues

| Report, issue | Status in the final candidate |
|---|---|
| logic 1 (major): $N\ge1$ in (P$_2^{o(1)}$) | **fixed**: §1.4 asks for $N\ge n^\alpha$; Cor. 5.2(b) uses $N=\max\{N_0(a_d),\lceil n^\alpha\rceil\}$; Remark 5.2a records the example; no stale use of $N\ge1$ remains. The only remaining mentions of $N\ge1$ are Proposition 5.3's "every width" and the historical notes |
| logic 2 (major): uniformity over $d\le n$ false for every learner | **fixed**: Remark 5.3a (issue 2 above: one quantifier step to write out); every claim that Proposition 5.3 refutes a formulation is withdrawn; row 3 and the RT §6.1 erratum are reframed (issue 1 above: unit-ball wording) |
| logic 3: open range overstated | **fixed**, and checked against B (§2.3) |
| logic 4: RT §0 item 6 headline, "precisely" | **fixed** |
| logic 5: fixed-$d$ row | **fixed**; matches A Prop. 5.2(c) at $t=1$ |
| logic 6 (optional): $\liminf_ddc_d<\infty$ | **declined**; acceptable for an optional item, but the stated reason is partly inaccurate (nit 7) |
| logic 7: §8 C3 | **fixed** in §8 (but see issue 3 on the §8 preamble) |
| logic 8: measurability; (R1′) | **fixed** |
| logic 9: "but not the $+o(1)$" summary | **fixed** |
| computation 1: $0.016\to0.015$ | **fixed** ($0.01549$) |
| computation 2: rounded-up lower bounds | **fixed** in substance; residual third-decimal rounding (nit 5) |
| computation 3: $Q^+\le2M$ | **fixed** ($Q\le s\le M$, $2\sqrt3<4$; remainder constant $\approx2.07$ uniform in $c$) |
| computation 4: Lemma 1.2 for general atoms | **fixed** |
| computation 5: fixed-$d$ row, bounded $c$ | **fixed** |
| computation 6: iterated limit in Cor. 5.2(b) | **fixed** |
| computation 7: $a=1/n$ versus $a=1/d$ | **fixed** ($d=34$ for $a=1/d$; $1.80$ versus $1.88\cdot10^{-7}$ at $d=33$) |
| computation, script remark: 80-digit monotonicity noise | **fixed** (200 digits; no decrease) |

---

## 5. Scripts and outputs (staging folder, `../checks/depth-two-referee-logic-computation-1/`)

| Script | What it checks | Result (`.out`) |
|---|---|---|
| `rr_numbers.py` | N1: $c=1$ numbers for $a=1/n$ and $a=1/d$, $d\le1000$, at 120 digits, with the binomial computed by a falling-factorial log sum. N2: Prop. 5.3 table. N4: Remark 5.2a and the width-one search. N5: Remark 5.3a. N6: $\varphi$ from the run files. N7: Remark 5.7a algebra, the Cor. 8.1 exponents, the rate at $c=\ln^3n$. N8: the fixed-$d$ row by simulation | every value quoted in the note reproduces (§2) |
| `rr_n3_fullgrid.py` | Prop. 5.3 remainder over $M=2^8..2^{120}$ and $c\in[1/M,\sqrt M]$, with the revised $Q\le M$ step | sup of the remainder times $M^{1/3}$: $2.07$ (with $2\sqrt3$), $2.07$ (with 4) |
| `rr_numbers_lib.py` | the function definitions of `rr_numbers.py`, imported by `rr_n3_fullgrid.py` | — |
| `author_rerun/` | copies of the author's scripts; `t1_range.py`, `prop53_check.py`, `bounds_t51.py` and `lemma_checks.py` re-run | outputs byte-identical to the corresponding `../checks/depth-two/*.out` |
