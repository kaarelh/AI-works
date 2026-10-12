# Track "examples": worked examples for Solomonoff function induction (final notes)

*Track "examples" of the SFI project. It covers brief items H5 (Hänni's cyclic permutation) and H6 (Eisenstat's example), positive examples, and Hänni's out-of-distribution (OOD) examples. Read `../../00-brief.md` first.*

This is the revised version of `notes.md`, written after the referee report `referee.md` (second run; the first run's report is kept as `referee-run1.md`). It is self-contained: every result used is stated here, and every result marked **[proved]** is proved here, except results imported from the parallel tracks, which are marked as such and proved there. Results keep their `notes.md` numbers wherever they survived, so that the other tracks' references stay valid. New results have new numbers. §0.1 lists every referee item and what was done about it. `notes.md` is kept unchanged for the record.

Scripts: `checks/e1`–`e7` (this track; `e6` and `e7` are new in this revision) and `referee_code/r1`–`r3`, `s1`–`s3` (the referees'). All are seeded or deterministic, run with `python3`, and save their output next to themselves (`*.out.txt`, `*_output.txt`). Reusable code is in `../../../code/sfi_examples.py` and `../../../code/sfi_dsl.py`.

**Status tags.** **[proved]**: full proof here. **[computed]**: checked by a script with saved output. **[known]**: published result with an exact reference; **(unverified)** means I could not check it against the source (arxiv.org, journal sites and lesswrong.com do not resolve here; WebSearch gives snippets only). **[proof sketch]**, **[conjecture]**, **[open]**, **[refuted]** (kept with its counterexample). Results imported from the parallel tracks are marked **[foundations]**, **[history]** or **[context]** with the item number in that track's current notes (§8 lists the files). Hänni's statements are treated as hypotheses.

---

## 0. Summary

**Convention.** Unless a row says otherwise, SFI's loss is in the *semimeasure convention*: the cumulative loss on a data set $D$ is $L_{\rm SFI}(D)=-\log_2M_F(D)$, the Bayesian marginal likelihood, which does not depend on the order of the data. The per-step *normalised* predictor has cumulative loss at most this, and it can depend on the order (§1.1). Upper bounds therefore hold in both conventions. Lower bounds hold in the normalised convention only where a row says so.

| # | Claim | Status |
|---|---|---|
| **H5** | **Cyclic permutation** of $\{0,1\}^n$, $N=2^n$, revealed backwards along the cycle from $0^n$: the $k$-th pair is $(x_k,x_{k-1})$ with $x_0=0^n$. | |
| 2.1 | For every total $f:\{0,1\}^n\to\{0,1\}^n$: $L_{\rm SFI}(f)=K(f\mid n)\pm c$. For every cyclic $f$: $L_{\rm SFI}(f)\le\log_2((N-1)!)+c$. For uniform cyclic $f$: $\Pr[L_{\rm SFI}(f)<\log_2((N-1)!)-m-c]<2^{-m}$ and $\mathbb E\,L_{\rm SFI}(f)\ge\log_2((N-1)!)-c$. Here $\log_2((N-1)!)=(n-\log_2e)2^n-\tfrac n2+\tfrac12\log_2(2\pi)+\epsilon_N$ with $\epsilon_N$ in Robbins' window. | proved; computed (e3, e6(d)) |
| 2.3 | **Sharp $k$-step bounds.** For $1\le k\le N-1$: $L_{\rm SFI}(D_k)\le\log_2(N-1)_{k-1}+\min\{K(k),\log_2(N-k)\}+c$ on every chain, and $\Pr[L_{\rm SFI}(D_k)<\log_2(N-1)_{k-1}-m-c]<2^{-m}$. So $L_{\rm SFI}(D_k)=\log_2(N-1)_{k-1}\pm O(K(k))$ w.h.p.: SFI pays for the $k-1$ nonzero labels as an injective sequence, and the identity of the newest input is free. The upper bound comes from a "broom" hypothesis. This replaces `notes.md` Thm 2.3, whose upper bound was about $n$ bits too high, and answers its open problem 3 negatively. | proved; computed (e6(a),(b),(c)) |
| 2.4 | The cost is intrinsic to order-free prediction. Every law of a random partial function has $\mathbb E[-\log_2\nu(D_k)]\ge\log_2(N-1)_{k-1}$. Every weak function semimeasure has $\mathbb E[-\log_2\nu(D_k)]\ge\log_2(N-1)_k-\log_2(N-1)$ and $\mathbb E[-\log_2\nu(f)]\ge\log_2((N-1)!)$. Whether the sharper bound holds for weak semimeasures is open. | proved; one case open |
| 2.9 | **Normalised SFI** (new). At step $2\le t\le N-1$ the normalised predictor pays at least $\log_2(N-t+1)-K(t-1)-c$ bits in expectation, and with probability $\ge1-2^{-m}$ at least that minus $m$. So for $t\le2^{(1-\delta)n}$ it pays at least $\delta n-O(\log n)$ bits per step. Hänni's "high loss under SFI" therefore holds for the predictor itself over the first $2^{(1-\delta)n}$ steps. Over the full cycle the normalised loss is **[open]**. | proved; proxy computed (e6(e)) |
| 2.5 | SFI$^{\rm hist}$ (and the universal chronological semimeasure $\xi$): loss $\le c$ on every chain, every $n$, every $f$. | proved, given (F7) |
| 2.11 | SFI$^{\rm set}$ (hypotheses see the *set* of previous inputs) pays as much as SFI on the full cycle: $\log_2((N-1)!)\pm(m+c)$ with probability $\ge1-2^{-m}$. The oracle of H4 must give the *list* of previous inputs. | proved (new) |
| 2.10 | **SI with the paper's prefix code** $\bar s=1^{\lvert s\rvert}0s$ on $\bar x_1\bar y_1\bar x_2\bar y_2\cdots$: expected label loss $\le c$, and $\le m+c$ for all $k$ simultaneously with probability $\ge1-2^{-m}$, with $c$ independent of $n$. This holds for $M$ and for the normalised Solomonoff measure. Hänni's "very low loss under SI" holds in this strong sense. | proved (new); illustrated (e6(f)) |
| 2.6 | SI on raw $n$-bit blocks with no delimiters: label loss $\le K(n)+m+c$ w.h.p. and $\le K(n)+c$ in expectation. The $K(n)$ is the price of not knowing where blocks end; a matching lower bound is a conjecture. | proved; lower bound conjecture |
| 2.13 | The same method gives the normalised lower bounds for the history track's chain and skipped strings, pathwise and in expectation; they are proved there ([history] Prop 2.4). | cited |
| **H6** | **Eisenstat's example.** $b_i\sim$ Bern(1/3) i.i.d.; a Bern(2/3) coin chooses "next unrevealed head" (label 1) or "next unrevealed tail" (label 0). $\tau_n$ is the tail frontier, $T_n$ the number of tails revealed, $UB_n:=-\log_2P_{1/3}(b_{<\tau_n})=\tau_n\log_23-T_n$. | |
| 3.2 | For every $b$ and every reveal sequence: $L_{\rm SFI}(D_n)\le UB_n+K(\tau_n)+c$. The "threshold function" is Bern(1/3) below $\tau_n$ and constant 1 from $\tau_n$ on. | proved |
| 3.3 | Pathwise sandwich: if $b$ is Martin-Löf random for Bern(1/3) and the heads frontier is not behind, then $UB_n-K(g_n)-c_b\le L_{\rm SFI}(D_n)\le UB_n+K(\tau_n)+c$ for every reveal sequence. So $L_{\rm SFI}(D_n)=UB_n\pm O(\log n)$ almost surely. | proved |
| 3.4 | $\mathbb E\,UB_n=\tfrac{h(1/3)}2n=0.459148\,n$ and $\mathrm{Var}(UB_n)=\sigma^2n$ **exactly** for every $n$, $\sigma^2=1.049660$; $UB_n/n\to h(1/3)/2$ a.s.; $(UB_n-\tfrac{h(1/3)}2n)/\sqrt n\Rightarrow N(0,\sigma^2)$. | proved (CLT now with full proof); computed (e1, e2, e7(d)) |
| 3.5 | $\Pr[\eta_n<\tau_n]\le20e^{-n/18}$; exact values $6.48\cdot10^{-2}$, $1.55\cdot10^{-2}$, $1.11\cdot10^{-3}$, $7.31\cdot10^{-6}$, $4.27\cdot10^{-10}$ at $n=10,20,40,80,160$. | proved; computed (e7(a)) |
| 3.6 | $-\log_2n-c\le\mathbb E\,L_{\rm SFI}(D_n)-\tfrac{h(1/3)}2n\le\log_2n+2\log_2\log_2n+c$. In the semimeasure convention the brief's $\approx0.459n$ is correct. The i.i.d. Bern(1/3) hypothesis pays $1.2516\,n$. | proved; computed (e2) |
| 3.7 | Exact law: $\Pr[D_n=D]=\binom nH(2/9)^nr^{M-n}$. The labels given the domain have law $\propto\binom nHr^{M-n}$, which depends on the labelling through $H$ **and the label at $\max S$** (`notes.md` wrongly said "only through $H$"). Every order-free predictor has expected loss $\ge\tfrac{h(1/3)}2n-\log_2n-O(1)$, so SFI is optimal among order-free predictors up to $O(\log n)$. | proved; computed (e1, s2(d)) |
| §3.6 | Hänni's e-mail claim ("SFI's log loss is the threshold function's up to $o(n)$") is **correct in the semimeasure convention**, up to $O(\log n)$ a.s. His proof sketch is correct in substance, with two repairs. For the normalised predictor the claim is **[open]**. | proved; normalised open |
| 3.8–3.9 | The Bayes history-aware predictor $P^*$ is explicit and has positive loss only at "touching" steps. Their number is Geometric(1/3) with mean 3; $\mathbb E\,L_{P^*}(\infty)=3\kappa=2.39855$ bits, $\kappa=0.7995167$. | proved; computed (e1, e7) |
| 3.10 | SFI$^{\rm hist}$: $L\le L_{P^*}+c$ on every path. SI (prefix code): $\mathbb E\,L^y\le3\kappa+c$ for all $n$, and $\sup_n(L^y-L_{P^*})\le m+c$ with probability $\ge1-2^{-m}$. | proved |
| 3.11–3.12 | The brief's rule "the input is a tail iff it is the smallest unrevealed index" is exact after the last touching step. Its expected number of errors over the infinite run is **exactly 2**, and it makes no error at all with probability **exactly 1/2**. | proved (exact limits new); computed (e2, e7) |
| **Pos.** | **Positive examples** | |
| 4.1 | Deterministic computable target: $L_{\rm SFI}\le K(f)+c$ and at most $K(f)+c$ steps with $P(\text{correct})\le1/2$, on every input sequence. Parity of a $k$-subset of $[d]$, thresholds, sorting, integer polynomials: explicit bounds, optimal for every learner up to $O(\log)$ terms. | proved; computed (e4) |
| 4.6 | Frozen i.i.d. label noise at rate $\varepsilon$ around a computable $g$, on $n$ distinct inputs chosen without access to the noise at unrevealed inputs: expected regret against the noise entropy $nh(\varepsilon)$ is between 0 and $K(g)+\log_2(n+1)+c$. | proved; computed (e4) |
| **OOD** | **Hänni's OOD examples** (proof/disproof labels; shortest proofs; lengths of odd strings) | |
| §5 | Proved: the intended answer has probability $\ge2^{L_{\rm SFI}(D)-K(g)-c}$; a simple unseen property gives a wrong answer probability bounded below independently of the amount of data; total online errors $\le K(g)+c$. Plausible only: that the intended answer gets probability near 1 on a natural machine. This is machine-dependent ([context] Prop 2.4(a),(b)); on the enumerated grammar of e5 it is 0.983, 0.998 or 0.9998 depending on one prior weight, and 0.11 on a tilted grammar. | proved (citing [context]); computed (e5); plausibility claims are conjecture |

**Verdicts on Hänni's claims, with their scope.**
* *H5, "high loss under SFI".* True in the semimeasure convention, at $n-\log_2e$ bits per pair over the cycle (Thm 2.1) and $\log_2(N-1)_{k-1}\pm O(K(k))$ after $k$ steps (Thm 2.3). True for the normalised predictor at $\ge n-\log_2t-O(\log\log t)$ bits per step for $t\le2^{(1-\delta)n}$ (Prop 2.9). Open for the normalised predictor over the full cycle.
* *H5, "very low loss under SI".* True: $O(1)$ in expectation and with high probability, uniformly in $n$, with the paper's prefix code (Prop 2.10).
* *H6, "SFI's loss is the threshold function's up to $o(n)$".* True in the semimeasure convention, up to $O(\log n)$ (Thm 3.3, Thm 3.6). Open for the normalised predictor.
* *H6, SI's loss is bounded.* True: $\mathbb E\le3\kappa+c$ (Thm 3.10).

**Constants.** $c$ denotes a constant that depends only on the fixed universal machines and encodings. It can be large. Statements of the form "loss $\le c$" are qualitative.

### 0.1 Response to the referees

The second referee found no fatal issues, three major issues and fourteen minor ones. I agree with all of them, re-derived each new argument before writing it down, and wrote two new scripts (`e6`, `e7`) that check the new statements independently of the referee's code. The first referee's items are covered by the second report except where listed at the end.

| item | what the referee said | what I did | where |
|---|---|---|---|
| M1 | The $k$-step upper bound is about $n-K(k)$ bits too high; a broom hypothesis and a depth-count lemma give $\log_2(N-1)_{k-1}\pm O(K(k))$; open problem 3 has answer "no" | Agreed. New Lemma 2.2a (depth count) and Thm 2.3 (sharp form) replace `notes.md` Thm 2.3 and Prop 2.4(1). The "Reading" is rewritten: the slack was in the upper bound and is real for all $k\le2^{(1-\delta)n}$. Open problem 3 closed. The broom is [history] Thm 2.1(a)'s upper-bound program, randomised over its spine; cited. Broom law, depth count and the bounds at $n=64$ checked independently | §2.2; e6(a),(b),(c) |
| M2 | Verdicts hold only in the semimeasure convention; for H5 the normalised version can be proved for most of the cycle | Agreed. Every verdict now names its convention (§0). New Prop 2.9 (the referee's Prop R2, re-derived). The explanation of why the argument stops, and the H6 case, are in §2.3 and §3.9. The proxy evidence that the full-cycle question is real is reproduced with my own proxy (e6(e)). The referee's remark on the history chain is now the history track's Prop 2.4 (Remark 2.13) | §0, §2.3, §3.9; e6(e) |
| M3 | SI's $K(n)$ in H5 is an artefact of the delimiter-free encoding | Agreed. New Prop 2.10 (the referee's Prop R3, re-derived and extended to the normalised Solomonoff measure). Prop 2.6 is kept for raw blocks only, with a conjecture for its lower bound. "Unlike SI" after Prop 2.5 is deleted. Open problem 2 is restated for raw blocks | §2.5; e6(f) |
| m1 | Thm 2.1(1): the $K(n)$ term is unnecessary | Agreed and proved, with the general form $L(D)=K(D\mid\mathrm{dom}\,D)\pm c$ when the domain is computable from each element | Thm 2.1(1) |
| m2 | Prop 3.7(2): "only through the number of heads" is false | Agreed; the sentence and the summary row now say "through $H$ and the label at $\max S$", with the exact counterexample | §3.5 |
| m3 | The Stirling-error remark is false | Agreed. Removed; the Robbins window is checked at 120 digits in e6(d). e3's column is double-precision noise for $n\ge17$; e3 is left unchanged as a record and flagged in the verification log | §2.6; e6(d) |
| m4 | The parenthetical on a prior over $n$ has a wrong justification | Agreed. Correct proof given (Remark 2.6b); it is secondary after Prop 2.10 | §2.5 |
| m5 | Prop 2.4 prose overreaches for weak semimeasures | Agreed. Prop 2.4 now proves the $\log_2(N-1)_k-\log_2(N-1)$ bound for every weak semimeasure (the history track's Prop 2.3(a), adapted and proved here). The depth-count form for weak semimeasures is stated as open | Prop 2.4 |
| m6 | SFI$^{\rm set}$ also fails on H5; notation clash in Remark 2.7 | Agreed. New Prop 2.11. Remark 2.7 corrected and the clash removed ($s$ strings) | §2.4, §2.7 |
| m7 | §5.1 should use the conditional complexity $K(L'\mid p)$; §5.4's "false" column overstates; cite [context] Prop 2.4(b) | Agreed; all three done | §5.1, §5.4 |
| m8 | Example 4.5 bound is loose | Agreed; sharp form $(d+1)\log_2A+K(d)+K(A)+c$ | Ex 4.5 |
| m9 | Prop 4.6 notation | Fixed: $D$ with $\lvert\mathrm{dom}\,D\rvert=n$; the expectation statements assume distinct inputs chosen without access to the noise at unrevealed inputs (adaptive choice from revealed labels is allowed) | Prop 4.6 |
| m10 | Lemma 3.5 vacuous at simulated sizes; Hoeffding uncited | Exact values quoted (e7(a)); Hoeffding cited | Lemma 3.5 |
| m11 | Prop 3.4(3) can be proved without Anscombe | Agreed and proved by conditional characteristic functions. Also new: $\mathrm{Var}(UB_n)=\sigma^2n$ exactly | Prop 3.4 |
| m12 | The proxy constant is approximate | "$\approx$" with the exact correction | §2.6 |
| m13 | Prop 2.6 and Thm 3.10(2) do not cite the block-code lemma | Cited as (F10) ([history] Lemma B) | Props 2.6, 2.10, Thm 3.10 |
| m14 | Stale cross-references; duplicated results; (F7)'s phrase on Hutter's $\xi$ | Cross-references updated to the final notes of the other tracks; one home proposed for each duplicated result; (F7) reworded | §1.2, §8 |
| §6.1–6.4 | Missed questions: normalised predictor; encoding; which oracle; exact $k$-step statement | Prop 2.9; Prop 2.10; Prop 2.11; Thm 2.3 | §2 |
| §6.5 | Optional: a separation in the other direction | Remark 2.12 states what is known and points to the history track, which owns the question | §2.7 |
| run 1, M1 fix | The e3 proxy has no broom; at $k=N/2$ it overstates the cost by about $n-1$ bits | Said in §2.6; a proxy with brooms is computed in e6(e) | §2.6 |
| run 1, m13 | Open problem 2 has an obvious candidate | Conjecture 2.6a with the heuristic | §2.5 |
| run 1, §6.5 | Positive example with fresh noise | Remark 4.7 | §4 |

---

## 1. Setting, facts used, and three lemmas

### 1.1 Notation

This follows the foundations track ([foundations] `notes-final.md` §1, Def 2.1, Def 2.5, Thm 3.2, Def 5.1, Props 5.2–5.5).
* **Inputs, labels, data.** $X=Y=\{0,1\}^*$; in §3 the inputs are natural numbers, identified with strings by the length-lexicographic bijection. A *data set* $D$ is a finite partial function from $X$ to $Y$; $\mathrm{dom}\,D$ is its domain, and $D+(x,y):=D\cup\{(x,y)\}$ for $x\notin\mathrm{dom}\,D$. A sequence $(x_t,y_t)_{t\le n}$ is *consistent* if $D_n:=\{(x_t,y_t):t\le n\}$ is a partial function. $h_t:=(x_1,y_1,\dots,x_t,y_t)$ is the history.
* **Function machines.** A function machine $T$ reads a uniformly random infinite tape $\omega$ shared by all inputs; its value $f^T_\omega(x)$ at $x$ is fixed by a finite prefix of $\omega$, or undefined ([foundations] Def 2.5). Its law is $\nu_T(D):=\lambda\{\omega:f^T_\omega\supseteq D\}$, where $\lambda$ is the fair-coin measure. A machine law is the containment functional of a random partial function ([foundations] Prop 2.6). $K(\nu)$ is the complexity of an index of a machine for $\nu$.
* **SFI.** $M_F:=\nu_{T_U}$ is the law of the universal function machine ([foundations] Thm 3.2, Def 5.1).
* **Losses.** $L_{\rm SFI}(D):=-\log_2M_F(D)$. The semimeasure-convention conditional is $M_F(y\mid D,x):=M_F(D+(x,y))/M_F(D)$. On a consistent sequence these conditionals multiply to $M_F(D_n)$ ([foundations] Prop 5.2), so the cumulative loss is $L_{\rm SFI}(D_n)$, whatever the order. The foundations track writes $L_n$ for this, and the context track $L_{M_F}(D_n)$. The *normalised conditional* is $\bar M_F(y\mid D,x):=M_F(D+(x,y))/\sum_{y'}M_F(D+(x,y'))$. Its cumulative loss is $\bar L_{\rm SFI}(h_n):=\sum_{t\le n}-\log_2\bar M_F(y_t\mid D_{t-1},x_t)$, which may depend on the order. With $Z_t:=\sum_yM_F(D_{t-1}+(x_t,y))/M_F(D_{t-1})$,
  $$\bar L_{\rm SFI}(h_n)=L_{\rm SFI}(D_n)-\sum_{t\le n}\log_2(1/Z_t)\ \le\ L_{\rm SFI}(D_n)\qquad\text{([foundations] Prop 5.3, 5.5(a))}.$$
* **Weak function semimeasures.** $\nu\ge0$ on data sets with $\nu(\emptyset)\le1$ and $\nu(D)\ge\sum_y\nu(D+(x,y))$ for $x\notin\mathrm{dom}\,D$ ([foundations] Def 2.1). Consequences: monotonicity, and $\sum_{\mathrm{dom}\,D=S}\nu(D)\le1$ for every finite $S$. With $\nu(\emptyset)=1$ these are exactly the order-independent online predictors ([foundations] Prop 2.1a). Every machine law is one.
* **Complexity.** $K(\cdot)$, $K(\cdot\mid\cdot)$ are prefix complexities with respect to a fixed universal prefix machine $V$; the conditional machine $V(\cdot,w)$ has a prefix-free domain for each $w$. $\mathbf m(i)$ is the universal discrete semimeasure, $\mathbf m(i)\ge2^{-K(i)}$. For a function $f$, $K(f)$ is the least $K(e)$ over indices $e$ of $f$.
* **Other.** $\log=\log_2$. $h(p)=-p\log p-(1-p)\log(1-p)$. $(a)_k=a(a-1)\cdots(a-k+1)$, $(a)_0=1$.
* **History-aware prediction.** A history-aware predictor gives $P(y\mid h,x)$ with $\sum_yP(y\mid h,x)\le1$; its loss is $L_P=\sum_t-\log P(y_t\mid h_{t-1},x_t)$. SFI$^{\rm hist}$ is SFI whose hypotheses see the list of previous inputs; its law is $M_H$, and the history track *defines* the universal chronological semimeasure as $\xi:=M_H$ ([history] §1.3, §4.1). $L_{\rm hist}:=-\log M_H(y_{1:n}\Vert x_{1:n})$.
* **Solomonoff induction (SI).** $M$ is the universal monotone semimeasure on $\{0,1\}^*$ (F8), and $M_{\rm norm}$ its Solomonoff normalisation: $M_{\rm norm}(\varepsilon)=1$, $M_{\rm norm}(zb)=M_{\rm norm}(z)M(zb)/(M(z0)+M(z1))$. A history is encoded as $\mathrm{code}(h_t)=\bar x_1\bar y_1\cdots\bar x_t\bar y_t$ with the paper's prefix-free code $\bar s:=1^{\lvert s\rvert}0s$ ([history] §1.1), unless a raw encoding is stated. For a semimeasure $\rho$ on $\{0,1\}^*$, SI's *label loss* is
  $$L^y_\rho(k):=\sum_{t\le k}-\log\frac{\rho(\mathrm{code}(h_{t-1})\bar x_t\bar y_t)}{\rho(\mathrm{code}(h_{t-1})\bar x_t)},$$
  the history track's $L^y_M$ ([history] §4.4). For a multi-bit label it is the sum of SI's bitwise conditional losses on the label's code.

### 1.2 Facts used

* **(F1) Dominance** [foundations Thm 3.2, Prop 3.3]. $M_F(D)\ge2^{-K(\nu)}\nu(D)$ for every machine law $\nu$ and every $D\neq\emptyset$. Machine laws include deterministic partial computable functions ($M_F(D)\ge2^{-K(\varphi)-c}$ for $D\subseteq\varphi$), lower-semicomputable product laws (private randomness per input), computable laws of random functions, and lower-semicomputable mixtures of these. Below I build each machine explicitly.
* **(F2) Monotonicity and disjointness.** $D\subseteq D'$ implies $M_F(D')\le M_F(D)$. For every law of a random partial function, the events $\{f\supseteq l\}$ for distinct labellings $l$ of one finite set are disjoint.
* **(F3) Conditional coding theorem** [known: L. A. Levin, *Problems Inform. Transmission* 10(3):206–210, 1974; P. Gács, *Soviet Math. Dokl.* 15:1477–1480, 1974; G. J. Chaitin, *J. ACM* 22(3):329–340, 1975; M. Li, P. Vitányi, *An Introduction to Kolmogorov Complexity and Its Applications*, 3rd ed., Springer 2008, §4.3 (section number unverified)]. If $\nu(z\mid w)\ge0$ is lower semicomputable uniformly in $(z,w)$ and $\sum_z\nu(z\mid w)\le1$ for all $w$, then $K(z\mid w)\le-\log\nu(z\mid w)+K(\nu)+c$.
* **(F4) Levin–Schnorr for computable measures** [known: L. A. Levin 1973; C. P. Schnorr 1973; Li–Vitányi 2008, §3.6 and §4.5 (numbering unverified)]. If $\mu$ is a computable measure on $\{0,1\}^\infty$, then $\omega$ is Martin-Löf random for $\mu$ iff there is $c_\omega$ with $K(\omega_{<k})\ge-\log\mu(\omega_{<k})-c_\omega$ for all $k$.
* **(F5) Ville's maximal inequality** [known: J. Ville, *Étude critique de la notion de collectif*, Gauthier-Villars 1939 (unverified)]. A nonnegative supermartingale $W$ with $W_0\le1$ has $\Pr[\sup_nW_n\ge a]\le1/a$.
* **(F6) Kraft and Gibbs.** $\sum_z2^{-K(z\mid w)}\le1$. For any random variable $Z$ and any $q$ with $\sum_zq(z)\le1$: $\mathbb E[-\log q(Z)]\ge H(Z)$.
* **(F7) SFI$^{\rm hist}$ dominance** [history Cor 4.3(b)]. For every lower-semicomputable history-aware predictor $P$ and every consistent sequence, $L_{\rm hist}\le L_P+K(P)+c$. By [history] Prop 4.4(a), seeing previous labels as well gives the same class. The history track defines $\xi:=M_H$; [foundations] Prop 7.2 constructs a universal chronological semimeasure independently and notes $\xi\asymp M_H$. That these agree with Hutter's universal chronological semimeasure (M. Hutter, *Universal Artificial Intelligence*, Springer 2005, ch. 5) is **known (unverified)**; nothing here depends on it. (`notes.md` called dominance "the defining property" of Hutter's $\xi$; that was inaccurate, since it is a consequence of the mixture definition.)
* **(F8) Solomonoff's universal semimeasure** [known: A. K. Zvonkin, L. A. Levin, *Russian Math. Surveys* 25(6):83–124, 1970; Li–Vitányi 2008 §4.5 (numbering unverified)]. $M$ is a lower-semicomputable semimeasure on $\{0,1\}^*$ with $M\ge2^{-K(\mu)-c}\mu$ for every lower-semicomputable semimeasure $\mu$.
* **(F9)** $K(i)\le\log(i+1)+2\log\log(i+2)+c$ for integers $i\ge0$ [known; standard].
* **(F10) Block codes** [history Lemma B (§4.4), proved there]. If $\nu$ is a lower-semicomputable semimeasure on alternating block sequences $(x_1,y_1,x_2,\dots)$ (a sequence may end after an $x$-block), then $M(\mathrm{code}(b))\ge2^{-K(\nu)-c}\nu(b)$ for every block sequence $b$. It holds for every fixed prefix-free code with nonempty codewords, in particular for $\bar s=1^{\lvert s\rvert}0s$ and for fixed-length blocks of one length $n$.
* **(F11) Normalisation** [proved]. $M_{\rm norm}\ge M$, and $M_{\rm norm}$ is a probability measure on $\{0,1\}^\infty$. *Proof.* $M_{\rm norm}(z)=\frac{M(z)}{M(\varepsilon)}\prod_{i\le\lvert z\rvert}\frac{M(z_{<i})}{M(z_{<i}0)+M(z_{<i}1)}$, each factor of the product is $\ge1$ because $M$ is a semimeasure, and $M(\varepsilon)\le1$. Additivity holds by construction. $\square$

### 1.3 Three lemmas

**Lemma 1.1 (domain lower bound)** **[proved]**. For every data set $D$: $L_{\rm SFI}(D)\ge K(D\mid\mathrm{dom}\,D)-c$. For every law $\nu$ of a random partial function, and more generally every weak function semimeasure, and every finite $S$: $\sum_{D:\,\mathrm{dom}\,D=S}\nu(D)\le1$.

*Proof.* Fix a finite set $S$. For distinct labellings $l,l'$ of $S$ the events $\{f_\omega\supseteq l\}$ and $\{f_\omega\supseteq l'\}$ are disjoint, so $l\mapsto M_F(l)$ is a discrete semimeasure. It is lower semicomputable uniformly in $S$. Apply (F3) with $w=S$. For weak semimeasures the sum bound is consequence (b) of [foundations] Def 2.1. $\square$

(This is [history] Lemma 1.1 and the left side of [foundations] Thm 6.3(a).)

**Lemma 1.2 (complexity is at least surprisal, with high probability)** **[proved]**. Let $Z$ be a random variable with values in a countable set, $w$ fixed, and $P$ the law of $Z$ (computable or not). For every $m\ge0$, $\Pr[K(Z\mid w)<-\log P(Z)-m]<2^{-m}$, and $\mathbb E\,K(Z\mid w)\ge H(Z)$.

*Proof.* $\Pr[K(Z\mid w)<-\log P(Z)-m]=\sum_{z:\,P(z)<2^{-K(z\mid w)-m}}P(z)<\sum_z2^{-K(z\mid w)-m}\le2^{-m}$ by Kraft. The expectation bound is (F6). $\square$

When $Z$ is uniform on a set of size $A$ this is the counting bound: fewer than a $2^{-m}$ fraction of the elements have $K(\cdot\mid w)<\log A-m$.

**Lemma 1.3 (SI's label loss is controlled by the true input law)** **[proved]**. Let $\mu$ be a probability law on infinite sequences of pairs $(x_t,y_t)$ in countable sets, with histories encoded by a prefix-free code. Let $\rho$ be a semimeasure on $\{0,1\}^*$ with $\rho(\mathrm{code}(h_t))\ge2^{-k}\mu(h_t)$ for all $t$ and all histories, where $\mu(h_t)$ is the probability of the history. Define $L^y_\rho(n)$ as in §1.1 and $L^y_\mu(n):=\sum_{t\le n}-\log\mu(y_t\mid h_{t-1},x_t)$. Then (i) $\mathbb E_\mu L^y_\rho(n)\le\mathbb E_\mu L^y_\mu(n)+k$ for all $n$, and (ii) $\mu[\exists n:\ L^y_\rho(n)>L^y_\mu(n)+k+m]\le2^{-m}$.

*Proof.* Put $Q_t:=\rho(\mathrm{code}(h_{t-1})\bar x_t)/\rho(\mathrm{code}(h_{t-1}))$. Telescoping, $\rho(\mathrm{code}(h_n))=\rho(\varepsilon)\prod_tQ_t\cdot2^{-L^y_\rho(n)}$, and $\rho(\varepsilon)\le1$. So
$$L^y_\rho(n)\le-\log\rho(\mathrm{code}(h_n))+\sum_t\log Q_t\le k-\log\mu(h_n)+\sum_t\log Q_t=k+L^y_\mu(n)+\log W_n,$$
with $W_n:=\prod_{t\le n}Q_t/\mu(x_t\mid h_{t-1})$. (Along $\mu$-almost every path all these quantities are positive.) $W$ is a nonnegative supermartingale under $\mu$ with $W_0=1$: given $h_{t-1}$, $\mathbb E[Q_t/\mu(x_t\mid h_{t-1})\mid h_{t-1}]=\sum_{x:\mu(x|h_{t-1})>0}Q_t(x)\le1$. The last step holds because the codewords $\bar x$ are prefix-free, and a semimeasure satisfies $\sum_{w\in A}\rho(sw)\le\rho(s)$ for every prefix-free set $A$ (induction on finite $A$, then a limit). The label $y_t$ does not change $W$. Hence $\mathbb E\log W_n\le\log\mathbb EW_n\le0$, which gives (i), and Ville's inequality (F5) gives (ii). $\square$

*Use.* Take $\rho=M$ or $\rho=M_{\rm norm}$ ((F11)), and $\mu$ computable. By (F10), $M(\mathrm{code}(h))\ge2^{-K(\mu)-c}\mu(h)$, so $k=K(\mu)+c$. Then SI's label loss exceeds the Bayes-optimal history-aware label loss by at most $K(\mu)+c$ in expectation. The inputs may be incompressible: the argument only needs SI to predict the inputs no better than $\mu$ does on average, which Gibbs' inequality guarantees. Pathwise comparisons between SI's label loss and SFI$^{\rm hist}$ are in [history] Thm 4.6: the excess is bounded by input-loss terms, and by $K(\delta)+c$ for a deterministic computable input policy $\delta$. Lemma 1.3 is the probabilistic counterpart for random inputs from a computable law. It does not contradict the Lattimore–Hutter–Gavane remark that unnormalised $M$ "can fail to predict very simple recursive sub-patterns" ([history] §4.4; T. Lattimore, M. Hutter, V. Gavane, "Universal prediction of selected bits", ALT 2011, *Lecture Notes in Artificial Intelligence* 6925, 262–276; abstract checked by WebSearch, full text unverified): that failure concerns particular input sequences, while Lemma 1.3 holds in expectation and with high probability.

---

## 2. Hänni's cyclic-permutation example (H5)

### 2.1 Setup

Fix $n\ge1$ and $N=2^n$. Let $f$ be a uniformly random cyclic permutation of $\{0,1\}^n$ (a single $N$-cycle). Put $x_0:=0^n$ and $x_k:=f^{-1}(x_{k-1})$ for $k=1,\dots,N$, so $x_N=0^n$. The $k$-th revealed pair is $(x_k,x_{k-1})$, and $D_k:=\{(x_i,x_{i-1}):1\le i\le k\}$. $D_N$ is the graph of $f$.

*Distribution* **[proved; computed for $n=2,3$ by exhaustion: e3(c)]**. $(x_1,\dots,x_{N-1})$ is a uniformly random ordering of $\{0,1\}^n\setminus\{0^n\}$. The map from orderings to cyclic permutations is a bijection: $f$ is the cycle $0^n\mapsto x_{N-1}\mapsto x_{N-2}\mapsto\dots\mapsto x_1\mapsto0^n$. There are $(N-1)!$ of each.

For $k\le N-1$, $D_k$ is a *chain*: $x_k\to x_{k-1}\to\dots\to x_1\to0^n$, with $x_1,\dots,x_k$ distinct and nonzero.

### 2.2 SFI in the semimeasure convention

**Theorem 2.1 (full cycle)** **[proved]**.
1. For every total $f:\{0,1\}^n\to\{0,1\}^n$: $\lvert L_{\rm SFI}(f)-K(f\mid n)\rvert\le c$. More generally, if a partial computable map $e$ satisfies $e(x)=\mathrm{dom}\,D$ for every $x\in\mathrm{dom}\,D$, then $\lvert L_{\rm SFI}(D)-K(D\mid\mathrm{dom}\,D)\rvert\le K(e)+c$.
2. For every cyclic permutation $f$ of $\{0,1\}^n$ and every $n$: $L_{\rm SFI}(f)\le\log_2((N-1)!)+c$.
3. For uniform cyclic $f$ and every $m\ge0$: $\Pr\big[L_{\rm SFI}(f)<\log_2((N-1)!)-m-c\big]<2^{-m}$, and $\mathbb E\,L_{\rm SFI}(f)\ge\log_2((N-1)!)-c$.
4. $\log_2((N-1)!)=(n-\log_2e)N-\tfrac n2+\tfrac12\log_2(2\pi)+\epsilon_N$ with $\frac1{(12N+1)\ln2}<\epsilon_N<\frac1{12N\ln2}$.

The same bounds hold for $L_{\rm SFI}(D_{N-1})$, since $D_{N-1}$ determines $f$ (computably, given $n$).

*Proof.* 1. Lower bound: Lemma 1.1. Upper bound, general form: let $T$ be the function machine that on input $x$ computes $S=e(x)$, then simulates the conditional machine $V(\cdot,S)$, reading the program bits it requests one by one from the tape. If $V$ halts with a data set $E$ with $\mathrm{dom}\,E=S$, $T$ outputs $E(x)$. For fixed $x$ the tape prefixes on which $T$ halts are halting programs of $V(\cdot,S)$, a prefix-free set, so $T$ is consistent. Inputs with the same $S$ read the same program. With probability $2^{-K(D\mid S)}$ the tape starts with a shortest program for $D$ given $S$, and then $f^T_\omega\supseteq D$. So $\nu_T(D)\ge2^{-K(D\mid\mathrm{dom}\,D)}$, and $K(\nu_T)\le K(e)+c$; apply (F1). For total $f$ on $\{0,1\}^n$ take $e(x)=\{0,1\}^{\lvert x\rvert}$, with $K(e)=O(1)$; $\mathrm{dom}\,f$ and $n$ are computable from each other.
2. Let $T_{\rm cyc}$ be the function machine that, for each length $\ell$, reads its own sub-stream $(\omega_{\langle\ell,j\rangle})_{j\ge0}$ of the tape and runs Sattolo's algorithm on $\{0,1\}^\ell$, drawing each uniform integer by rejection sampling from fair bits. This produces a uniformly random cyclic permutation $\pi_\ell$ [known: S. Sattolo, "An algorithm to generate a random cyclic permutation", *Inf. Process. Lett.* 22(6):315–317, 1986; bibliographic data and statement checked by WebSearch snippet, full text unverified]. It halts with probability 1, and the sub-streams for different lengths are independent. On input $x$ it outputs $\pi_{\lvert x\rvert}(x)$, which is fixed by finitely many tape bits. $T_{\rm cyc}$ is one fixed machine, so $K(\nu_{T_{\rm cyc}})=O(1)$, and $\nu_{T_{\rm cyc}}(f)=1/(N-1)!$ for every cyclic $f$. Apply (F1).
3. By part 1, $L_{\rm SFI}(f)\ge K(f\mid n)-c$. Apply Lemma 1.2 with $Z=f$, $w=n$, $P$ uniform on $(N-1)!$ values.
4. Robbins' bounds $\ln m!=m\ln m-m+\tfrac12\ln(2\pi m)+r_m$, $\frac1{12m+1}<r_m<\frac1{12m}$ [known: H. Robbins, "A remark on Stirling's formula", *Amer. Math. Monthly* 62(1):26–29, 1955; checked by WebSearch snippet, full text unverified], applied to $(N-1)!=N!/N$. $\square$

Per revealed pair, SFI pays $\log_2((N-1)!)/N\to n-\log_2e\approx n-1.4427$ bits on average over the cycle.

**Lemma 2.2 (chain semimeasure)** **[proved]**. For a string $x$ and a finite sequence $z=(z_1,\dots,z_j)$ of strings different from $0^{\lvert x\rvert}$ ($j\ge0$), let
$$D(x,z):=\{(x,z_1),(z_1,z_2),\dots,(z_{j-1},z_j),(z_j,0^{\lvert x\rvert})\}\quad(\text{for }j=0:\ \{(x,0^{\lvert x\rvert})\}),$$
read as a set of pairs, and $\nu(z\mid x):=\lambda\{\omega:\ f_\omega(x)=z_1,\ f_\omega(z_i)=z_{i+1}\ (i<j),\ f_\omega(z_j)=0^{\lvert x\rvert}\}$. Then $\sum_z\nu(z\mid x)\le1$, $\nu$ is lower semicomputable uniformly in $(x,z)$, and $\nu(z\mid x)=M_F(D(x,z))$ whenever $D(x,z)$ is a partial function. Hence $K(z\mid x)\le L_{\rm SFI}(D(x,z))+c$. The same disjointness holds for every law of a random partial function in place of $M_F$.

*Proof.* Fix $\omega$ and $x$. If $z$ satisfies the condition, then $z_i=f_\omega^{\,i}(x)\neq0^{\lvert x\rvert}$ for $i\le j$ and $f_\omega^{\,j+1}(x)=0^{\lvert x\rvert}$. So $j+1$ is the first hitting time of $0^{\lvert x\rvert}$ along the $f_\omega$-orbit of $x$, and $z$ is the orbit up to that time. At most one $z$ qualifies, so the events are disjoint. Lower semicomputability is as in Lemma 1.1. Apply (F3). $\square$

(This is [history] Lemma 2.0 with the terminal label $0^{\lvert x\rvert}$ in place of $\varepsilon$.)

**Lemma 2.2a (depth count)** **[proved; computed: e6(b)]**. For a partial function $F$ on strings and $1\le k\le N-1$, let $A_k(F)$ be the set of nonzero $x\in\{0,1\}^n$ such that $F(x),\dots,F^{k-1}(x)$ are nonzero $n$-bit strings and $F^k(x)=0^n$. Then $\lvert A_k(F)\rvert\le N-k$, and equality is attained.

*Proof.* Every $x\in A_k(F)$ has first hitting time of $0^n$ exactly $k$. If $A_k(F)\neq\emptyset$, pick $x\in A_k(F)$. The strings $F(x),\dots,F^{k-1}(x)$ are nonzero, $n$-bit, and have first hitting times $k-1,\dots,1$. So they are distinct and none is in $A_k(F)$. Hence $\lvert A_k(F)\rvert\le(N-1)-(k-1)$. The broom of Thm 2.3 below, with a fixed spine, attains equality. $\square$

[computed: e6(b): exhaustively over all 625 partial functions for $n=2$ and all $8^8$ total functions for $n=3$, and over $10^5$ random partial functions for $n=3,4$: no violation; the maximum is exactly $N-k$ in the exhaustive cases; the broom attains $N-k$ for every $k$ at $n=2,3,4$. The referee's `s1(b)` and the first referee's `r2(b)` found the same.]

**Theorem 2.3 ($k$ steps, sharp)** **[proved; computed: e6(a),(c)]**. Let $1\le k\le N-1$.
1. *Upper bound, every chain.* $L_{\rm SFI}(D_k)\le\log_2(N-1)_{k-1}+\min\{K(k),\ \log_2(N-k)\}+c$. In particular $L_{\rm SFI}(D_1)\le c$ and $L_{\rm SFI}(D_{N-1})\le\log_2((N-1)!)+c$.
2. *Every order-free law, in expectation.* For every law $\nu$ of a random partial function (computable or not): $\mathbb E_f[-\log_2\nu(D_k)]\ge\log_2(N-1)_{k-1}$.
3. *SFI, with high probability.* For uniform cyclic $f$ and every $m\ge0$: $\Pr\big[L_{\rm SFI}(D_k)<\log_2(N-1)_{k-1}-m-c\big]<2^{-m}$.
4. *Simultaneously.* With probability $\ge1-2^{-m}$, for all $k\le N-1$ at once: $L_{\rm SFI}(D_k)\ge\log_2(N-1)_{k-1}-n-m-c$.

So $L_{\rm SFI}(D_k)=\log_2(N-1)_{k-1}\pm O(K(k))$ with high probability, uniformly in $1\le k\le N-1$.

*Proof.* 1. *The broom.* Let $B_k$ be the following function machine. For each length $\ell$ it reads its own sub-stream of the tape and draws, by rejection sampling, a uniformly random injective sequence $(v_1,\dots,v_{k-1})$ of nonzero $\ell$-bit strings; if $k-1>2^\ell-1$ it answers $0^\ell$ everywhere on that length. On input $x$ of length $\ell$ it outputs $0^\ell$ if $x=v_1$; $v_{i-1}$ if $x=v_i$ with $2\le i\le k-1$; and $v_{k-1}$ for every other $x$ (for $k=1$: $0^\ell$ for every $x$). The value at $x$ is fixed by finitely many tape bits almost surely, $B_k$ is total almost surely, and its index is computable from $k$, so $K(\nu_{B_k})\le K(k)+c$. On the event $(v_1,\dots,v_{k-1})=(x_1,\dots,x_{k-1})$, which has probability $1/(N-1)_{k-1}$, $f^{B_k}_\omega$ extends $D_k$: $x_1\mapsto0^n$, $x_i\mapsto x_{i-1}$ for $2\le i\le k-1$, and $x_k$, which is not among the $v_i$, goes to $v_{k-1}=x_{k-1}$. (F1) gives $\log_2(N-1)_{k-1}+K(k)+c$.
   *The second term.* Under $T_{\rm cyc}$ the $k$ arcs of $D_k$ form a path that does not close the cycle, so $\nu_{T_{\rm cyc}}(D_k)=(N-k-1)!/(N-1)!=1/(N-1)_k$ (contract the path). This gives $\log_2(N-1)_k+c=\log_2(N-1)_{k-1}+\log_2(N-k)+c$.
   The broom is exactly the upper-bound program of [history] Thm 2.1(a) ("otherwise output $x_{n-1}$"), randomised over its spine. (`notes.md` had a third term $k$, from a machine $T'$ that answers $0^{\lvert x\rvert}$ with a private probability $1/2$; it is subsumed, since $K(k)\le k+c$.)
2. *Depth count.* Fix $\omega$. Each $x\in A_k(f_\omega)$ has exactly one $z\in(\{0,1\}^n\setminus\{0^n\})^{k-1}$ with $f_\omega\supseteq D(x,z)$, namely its orbit, and every other nonzero $x$ has none (a $z$ with a repetition cannot be an orbit that reaches $0^n$). Hence
   $$\textstyle\sum_{x,\,z}\nu(D(x,z))=\mathbb E_\omega\lvert A_k(f_\omega)\rvert\le N-k$$
   by Lemma 2.2a, the sum running over nonzero $n$-bit $x$ and $z$ of length $k-1$. The tuple $(x_k,x_{k-1},\dots,x_1)$ is uniform over the $(N-1)_k$ injective sequences of nonzero strings, and $D_k=D(x_k,(x_{k-1},\dots,x_1))$. Apply Gibbs (F6) with $q:=\nu(D(\cdot,\cdot))/(N-k)$: $\mathbb E[-\log\nu(D_k)]\ge\log_2(N-1)_k-\log_2(N-k)=\log_2(N-1)_{k-1}$.
3. $q(x,z\mid n,k):=M_F(D(x,z))/(N-k)$ is lower semicomputable uniformly in $(n,k)$ and sums to at most 1 by part 2. So (F3) gives $K(x,z\mid n,k)\le L_{\rm SFI}(D(x,z))+\log_2(N-k)+c$. Apply Lemma 1.2 with $Z=(x_k,x_{k-1},\dots,x_1)$, uniform on $(N-1)_k$ values, and $w=(n,k)$.
4. Union bound over the $N-1<2^n$ values of $k$ in part 3, with $m+n$ in place of $m$. $\square$

[computed: e6(a) compares the laws of the brooms $B_j$, the cyclic law and the partial chains of §2.6 with their closed forms on every chain, for $n=2$ (all orderings) and $n=3$ (four orderings), by enumerating each law's finite randomness in exact rationals: 1092 comparisons, no mismatch. For example, at $n=3$, $k=4$ the broom gives $1/210$ and the cyclic law $1/840$. e6(c) evaluates the bounds at $n=64$ with mpmath.]

*Reading.* `notes.md` stated $\log_2(N-1)_k-\log_2(N-1)-m-c\le L_{\rm SFI}(D_k)\le\log_2(N-1)_k-\max\{0,\log_2(N-k)-k\}+c$ and said that "the $\log_2(N-1)$ slack in part 2 cannot be removed for small $k$". Both bounds were true, but the explanation had the wrong cause. For $k\le N/2$ the two lower bounds differ by $\log_2\frac{N-1}{N-k}\le1$ bit. The loose side was the upper bound: for $\log_2N\lesssim k\le N/2$ it equals $\log_2(N-1)_k+c$, which is about $n-K(k)$ bits above the truth. At $n=64$, $k=64$ the new upper bound lies 52.8 bits below the old one, up to constants (e6(c)). The cyclic law pays $\log_2(N-1)$ bits for "where on the cycle the newest input sits"; SFI does not have to pay this, because a broom names the spine and lets every other input point at its end. So SFI pays about $n$ bits per step, $\log_2(N-t+1)$ at step $t$, until the end of the cycle; the newest input is free up to $K(k)$. This answers `notes.md` open problem 3 ("is $L_{\rm SFI}(D_k)=\log_2(N-1)_k+O(1)$ w.h.p. once $k\ge n$?") negatively: for $k\le N/2$, $L_{\rm SFI}(D_k)\le\log_2(N-1)_k-(n-1)+K(k)+c$.

**Proposition 2.4 (the cost is intrinsic to order-free prediction)** **[proved]**.
1. For every law $\nu$ of a random partial function (computable or not; this includes every machine law, so every x-only predictor with shared or private randomness) and every $k\le N-1$: $\mathbb E_f[-\log_2\nu(D_k)]\ge\log_2(N-1)_{k-1}$. (Thm 2.3(2).)
2. For every weak function semimeasure $\nu$ (every order-free online predictor, [foundations] Prop 2.1a) and every $k\le N-1$: $\mathbb E_f[-\log_2\nu(D_k)]\ge\log_2(N-1)_k-\log_2(N-1)=\log_2(N-2)_{k-1}$.
3. For every weak function semimeasure $\nu$: $\mathbb E_f[-\log_2\nu(f)]\ge\log_2((N-1)!)$.

*Proof.* 2. *Claim:* for every weak $\nu$ and every nonzero $x\in\{0,1\}^n$, $\sum_z\nu(D(x,z))\le1$, the sum running over finite sequences $z$ of distinct nonzero strings different from $x$. This is [history] `notes-final.md` Prop 2.3(a) with terminal label $0^n$ in place of $\varepsilon$; the proof is the same. For $j\ge0$ and distinct nonzero $z_1,\dots,z_j\neq x$ let $O_j(z_{1:j}):=\{(x,z_1),(z_1,z_2),\dots,(z_{j-1},z_j)\}$, with $O_0:=\emptyset$. Its last point $z_j$ ($x$ when $j=0$) is not in its domain. The weak inequality at that point gives $\sum_y\nu(O_j\cup\{(z_j,y)\})\le\nu(O_j)$. Among the terms, $y=0^n$ gives $D(x,z_{1:j})$, and each nonzero $y\notin\{x,z_1,\dots,z_j\}$ gives $O_{j+1}(z_{1:j},y)$; the other terms are $\ge0$ and are dropped. By induction on $J$, $\sum_{j\le J}\sum_{\lvert z\rvert=j}\nu(D(x,z))+\sum_{\lvert z\rvert=J+1}\nu(O_{J+1}(z))\le\nu(\emptyset)\le1$, and every partial sum of the first part is at most 1. Now condition on $x_k$: $(x_{k-1},\dots,x_1)$ is uniform over the $(N-2)_{k-1}$ injective sequences of nonzero strings other than $x_k$, and $z\mapsto\nu(D(x_k,z))$ is a sub-probability. Apply Gibbs.
3. $\sum_{g:\{0,1\}^n\to\{0,1\}^n}\nu(g)\le1$ (Lemma 1.1); apply Gibbs to the uniform law on the $(N-1)!$ cyclic permutations. $\square$

So, for random-function laws, the gap between SFI and SI here is not a weakness of the universal prior. In expectation, no random partial function, with shared or private randomness, does better than SFI by more than $O(K(k))$ bits. For weak semimeasures (all order-free online predictors) the same holds up to $\log_2\frac{N-1}{N-k}+O(K(k))$ bits, which is at most $1+O(K(k))$ for $k\le N/2$ and which vanishes over the full cycle (part 3). Whether part 1 extends to weak semimeasures, i.e. whether $\sum_{x,\lvert z\rvert=k-1}\nu(D(x,z))\le N-k$ for every weak $\nu$, is **[open]**; the first referee's linear program found the maximum $N-k$ for $N=4$ (`referee_code/r2`, part (d)), the only nontrivial case it could reach. Set-based *history-aware* predictors are a different class: they can reconstruct the order from the set of pairs (Remark 2.7).

### 2.3 Normalised SFI

The lower bounds above are for $L_{\rm SFI}=-\log M_F$. The normalised predictor $\bar M_F$ is not order-free ([foundations] Prop 5.3), and set-based history-aware predictors have loss $O(1)$ here (Remark 2.7), so an information-theoretic argument alone cannot give a lower bound for it. The following uses instead that a *total* hypothesis consistent with the past, and wrong at the next input, keeps the normaliser large.

**Proposition 2.9 (normalised SFI pays about $n$ bits per step for most of the cycle)** **[proved; proxy computed: e6(e)]**. Let $\bar\ell_t:=-\log_2\bar M_F(y_t\mid D_{t-1},x_t)$ be the normalised loss at step $t$, with $f$ uniform cyclic. For $2\le t\le N-1$:
$$\mathbb E\,\bar\ell_t\ \ge\ \log_2(N-t+1)-K(t-1)-c,$$
and $\bar\ell_t\ge\log_2(N-t+1)-K(t-1)-m-c$ with probability $\ge1-2^{-m}$. Consequently, for $k\le N/2$,
$$\mathbb E\sum_{t\le k}\bar\ell_t\ \ge\ \sum_{t=2}^{k}\big(\log_2(N-t+1)-K(t-1)-c\big)^+\ \ge\ (k-1)\big(n-1-\log_2k-2\log_2\log_2(k+1)-c\big).$$
For $k\le2^{(1-\delta)n}$ this is at least $(k-1)(\delta n-O(\log n))$.

*Proof.* Write $\bar\ell_t=-\log_2M_F(D_t)+\log_2S_t$ with $S_t:=\sum_yM_F(D_{t-1}+(x_t,y))$.
* (i) $M_F$ is the containment functional of a random partial function ([foundations] Prop 2.6, Thm 3.2), so Thm 2.3(2) with $\nu=M_F$ gives $\mathbb E[-\log_2M_F(D_t)]\ge\log_2(N-1)_{t-1}$.
* (ii) The broom $B_{t-1}$ is total almost surely, and $x_t\notin\mathrm{dom}\,D_{t-1}$. So $\sum_y\nu_{B_{t-1}}(D_{t-1}+(x_t,y))=\nu_{B_{t-1}}(D_{t-1})\ge1/(N-1)_{t-2}$ (proof of Thm 2.3(1)). Applying (F1) to each data set $D_{t-1}+(x_t,y)$ and summing ([history] Lemma 2.4a states this step for any machine), $S_t\ge2^{-K(t-1)-c}/(N-1)_{t-2}$ on every path.
* (iii) Subtract: $\log_2(N-1)_{t-1}-\log_2(N-1)_{t-2}=\log_2(N-t+1)$.

The high-probability version uses Thm 2.3(3) in place of (i). The cumulative bound uses $\bar\ell_t\ge0$, (F9) for $K(t-1)$, and $N-t+1\ge N/2$ for $t\le N/2$. $\square$

*In words.* At step $t$ the broom on the first $t-2$ inputs is consistent with the past, has prior weight $2^{-K(t-1)}$, and sends $x_t$ to the wrong label $x_{t-2}$. It is defined everywhere, so normalisation cannot discount it. Its contribution to the normaliser, $2^{-K(t-1)}/(N-1)_{t-2}$, exceeds the total mass on the correct label, which is about $1/(N-1)_{t-1}$ or less (in the sense of part (i)), by a factor of about $(N-t+1)2^{-K(t-1)}$. In the proxy of e6(e) this broom dominates the normaliser, and the normalised step loss is close to $\log_2(N-t+1)+\log_2(w_{t-1}/w_t)$, where $w_j$ are the broom weights.

*Why the argument stops there.* Per step it pays the overhead $K(t-1)$ to name a total hypothesis that dominates the normaliser, against $\log_2(N-t+1)\le n$ bits of information. The per-step bounds therefore sum to at most $\sum_{t<N}(n-K(t))^+\le2N$ bits over the whole cycle, because fewer than $2^{n-j+1}$ integers $t$ have $K(t)\le n-j$. That is far below $\log_2((N-1)!)\approx nN$. So the full-cycle normalised loss remains **[open]**. The question is real: in e6(e), mixtures that put most of their prior on *partial* chains (defined only along a random spine of random length) have full-cycle normalised loss well below $\log_2((N-1)!)$, e.g. 19.2 against 40.25 bits at $n=4$ and 8748.7 against 8759.0 at $n=10$, while Prop 2.9's per-step inequality holds at every step (with margins $\ge2.7$ bits). The referee's proxy (`s1(c)`) found 28.4 against 40.25 at $n=4$. In H6 the per-step information is only about 0.46 bits, and the analogous overhead is $O(\log t)$; the argument gives nothing there (§3.9).

**Remark 2.13 (the history track's chain and skipped strings)** **[history Prop 2.4]**. The method of Prop 2.9 was suggested by the second referee for the history track's chain as well. The history track now proves it there, as its Prop 2.4, with its Lemma 2.4a (the normaliser bound used in Prop 2.9(ii)): on the chain with $\ell_i=i$ and Martin-Löf random blocks, the normalised cumulative loss is $\ge n(n-1)/2-n(4\log n+c_\omega+c)$; with independent uniform blocks, step $t$ costs $\ge\ell_{t-1}-K(t-2)-c$ in expectation; and the skipped strings have the analogous bound. I re-derived the expectation form for the chain by the proof of Prop 2.9: replace the depth-count bound by [history] Prop 2.3(c), $\mathbb E[-\log M_F(D_t)]\ge L_{t-1}$, and the broom by the total machine that draws the first $t-2$ blocks and sends every other input to the last of them, which extends $D_{t-1}$ with probability $2^{-L_{t-2}}$. This answers the history track's Q4 for those two examples. It remains open there for examples whose information per step is $O(1)$ bits, as it is here for H6 (§3.9).

### 2.4 SFI$^{\rm hist}$ and SFI$^{\rm set}$

**Proposition 2.5** **[proved, given (F7)]**. Let $P_{\rm copy}$ be the deterministic history-aware predictor: on the empty history predict $0^{\lvert x\rvert}$; otherwise predict the most recent input. For every $n$, every cyclic $f$ and every $k\le N$: $L_{\rm hist}(D_k\text{ in reveal order})\le K(P_{\rm copy})+c=c'$.

*Proof.* $P_{\rm copy}$ is computable and has loss 0 on the sequence $(x_1,0^n),(x_2,x_1),\dots$. Apply (F7). $\square$

The bound holds pathwise, for every $n$, with a constant independent of $n$, and for every chain of distinct strings ending at $0^n$, random or not. ([history] Prop 4.8 states and proves the same result; §8 proposes one home for it.)

**Proposition 2.11 (the set of previous inputs is not enough)** **[proved]**. Let SFI$^{\rm set}$ be SFI whose hypotheses see the *set* $\{x_1,\dots,x_{t-1}\}$ of previous inputs when answering $x_t$ ([history] §4.3), with law $M_{\rm set}$ and loss $L_{\rm set}$. For uniform cyclic $f$, over the full cycle $(x_1,0^n),\dots,(x_N,x_{N-1})$, and every $m\ge0$:
$$\Pr\big[L_{\rm set}<\log_2((N-1)!)-m-c\big]<2^{-m},\qquad\mathbb E\,L_{\rm set}\ge\log_2((N-1)!),\qquad L_{\rm set}\le\log_2((N-1)!)+c .$$

*Proof.* Let $\sigma=(x_1,\dots,x_{N-1})$ range over orderings of the nonzero strings; the input list is $(\sigma,0^n)$ and the labels $y_1=0^n$, $y_t=x_{t-1}$ are determined by $\sigma$. Fix $\omega$ and let $U^\omega(A,x)$ be the universal set-hypothesis's answer at $x$ given the set $A$. If $\sigma$ is consistent with $U^\omega$, then at step $N$ the set is $\{0,1\}^n\setminus\{0^n\}$ whatever $\sigma$ is, so $x_{N-1}=U^\omega(\{0,1\}^n\setminus\{0^n\},0^n)$ is determined by $\omega$. Then $x_{N-2}=U^\omega(\{0,1\}^n\setminus\{0^n,x_{N-1}\},x_{N-1})$ is determined, and so on down to $x_1$. So at most one $\sigma$ is consistent with each $\omega$, and $\sum_\sigma M_{\rm set}(y(\sigma)\Vert(\sigma,0^n))\le1$. This map is lower semicomputable uniformly in $n$. Gibbs gives the expectation bound; (F3) gives $K(\sigma\mid n)\le L_{\rm set}+c$, and Lemma 1.2 with $\sigma$ uniform on $(N-1)!$ values gives the probability bound. The upper bound is $L_{\rm set}\le L_{\rm SFI}+c$ ([history] Prop 4.4(c); the inputs are distinct) and Thm 2.1(2). $\square$

So for H4 the oracle must give the *list* of previous inputs: SFI$^{\rm hist}$ pays $O(1)$ (Prop 2.5), and SFI$^{\rm set}$ pays as much as SFI. (The history track's Prop 4.5(iii) separates SFI$^{\rm set}$ from SFI$^{\rm hist}$ on a suitably chosen order with a $\log_2s$ loss in the bound, $s$ the number of strings. Here the last input $0^n$ is fixed, which removes that factor.)

### 2.5 SI on the interleaved sequence

**Proposition 2.10 (SI with the prefix code)** **[proved; illustrated: e6(f)]**. Encode the history as $\bar x_1\bar y_1\bar x_2\bar y_2\cdots$ with $\bar s=1^{\lvert s\rvert}0s$. Let $\rho\in\{M,M_{\rm norm}\}$. There is a constant $c$, independent of $n$, such that for uniform cyclic $f$, every $k\le N$ and every $m\ge0$:
$$\mathbb E\,L^y_\rho(k)\le c,\qquad\Pr\big[\exists k\le N:\ L^y_\rho(k)>m+c\big]\le2^{-m}.$$

*Proof.* Let $\mu_n$ be the law of the pair sequence: $x_t$ uniform over the nonzero $n$-bit strings not yet used ($t\le N-1$), $x_N=0^n$, $y_1=0^n$, $y_t=x_{t-1}$, continued after step $N$ by a fixed computable rule. $\mu_n$ is computable uniformly in $n$, so $\mu:=\sum_n\mathbf m(n)\mu_n$ is a lower-semicomputable semimeasure on block sequences. By (F10) and (F11), $\rho(\mathrm{code}(h))\ge M(\mathrm{code}(h))\ge2^{-c}\mu(h)\ge2^{-c}\mathbf m(n)\mu_n(h)$ for every history $h$.
Telescoping as in Lemma 1.3, with $Q_t:=\rho(\mathrm{code}(h_{t-1})\bar x_t)/\rho(\mathrm{code}(h_{t-1}))$ and the label conditionals of $\mu_n$ equal to 1:
$$L^y_\rho(k)=-\log\rho(\mathrm{code}(h_k))+\log\rho(\varepsilon)+\sum_{t\le k}\log Q_t\ \le\ c-\log\mathbf m(n)+\log\rho(\varepsilon)+\log W_k,$$
where $W_k:=\prod_{t\le k}Q_t/\mu_n(x_t\mid h_{t-1})$. The improvement over Lemma 1.3 is at the first step:
$$\mathbb E\,W_1=\sum_{x}\rho(1^n0x)/\rho(\varepsilon)\le\rho(1^n0)/\rho(\varepsilon),$$
the sum running over nonzero $n$-bit $x$ (prefix-freeness). For $t\ge2$, $\mathbb E[Q_t/\mu_n(x_t\mid h_{t-1})\mid h_{t-1}]\le1$ as in Lemma 1.3. So $V_k:=W_k\,\rho(\varepsilon)/\rho(1^n0)$, with $V_0:=1$, is a nonnegative supermartingale, and
$$L^y_\rho(k)\le c-\log\mathbf m(n)+\log\rho(1^n0)+\log V_k .$$
Now $-\log\mathbf m(n)\le K(n)$, and $\log\rho(1^n0)\le-K(n)+c$:
* for $\rho=M$: the strings $1^n0$ form a prefix-free set, so $\sum_nM(1^n0)\le1$, and $n\mapsto M(1^n0)$ is lower semicomputable; apply (F3);
* for $\rho=M_{\rm norm}$: $M_{\rm norm}(1^n0)\le M_{\rm norm}(0\mid1^n)=\frac{M(1^n0)}{M(1^n0)+M(1^{n+1})}\le\frac{M(1^n0)}{M(1^{n+1})}\le2^{-K(n)+c}$, because $M(1^{n+1})\ge2^{-c}$ (domination of the point mass on $1^\infty$).

Hence $L^y_\rho(k)\le c'+\log V_k$. Jensen gives $\mathbb E\log V_k\le\log\mathbb EV_k\le0$, and Ville's inequality (F5) gives the second claim. $\square$

In words: SI pays about $K(n)$ bits on the **input** header $1^n0$ of $x_1$. That header tells it $n$ before the first label, so the labels are free. Both SI and SFI$^{\rm hist}$ pay $O(1)$ uniformly in $n$ under the paper's common code.

*Illustration* **[computed: e6(f)]**. An exact Bayes mixture of the true processes $\mu_m$ ($m=1,\dots,10$, weights $\propto1/(m(m+1))$, total $3/4$) and a uniform-bits null model (weight $1/4$) has full-cycle label loss $0.13$–$0.26$ bits with the prefix code (the null model's residual weight) and $1.3$–$7.8$ bits with raw blocks, for $n=2,\dots,6$ and three permutations each. The referee's `s3` found $0.02$–$0.09$ and $0.9$–$8.7$ bits for a similar mixture.

**Proposition 2.6 (raw blocks)** **[proved]**. Encode the history as the binary string $x_1y_1x_2y_2\cdots$ with each block written as $n$ raw bits (no delimiters; SI is not told $n$). For $\rho\in\{M,M_{\rm norm}\}$, every $n$ and $m\ge0$, with $f$ uniform cyclic: $\Pr[\exists k\le N:\ L^y_\rho(k)>K(n)+m+c]\le2^{-m}$, and $\mathbb E\,L^y_\rho(k)\le K(n)+c$ for every $k\le N$.

*Proof.* $\mu_n$ as in Prop 2.10 is computable from $n$, and for fixed $n$ the blocks have one length, so (F10) gives $M\ge2^{-K(n)-c}\mu_n$ on encoded histories; $\mu_n$'s label loss is 0. Apply Lemma 1.3 with $k=K(n)+c$. $\square$

**Conjecture 2.6a (raw blocks, lower bound)** **[conjecture]**. For raw blocks, SI's expected label loss is of order $K(n)$ for typical $n$. *Heuristic* (the first referee's m13, refined): after the $n$ random bits of $x_1$, SI does not know where the first block ends. The first label $0^n$ is predicted well by the models with block length $m=n$, and by models with $m>n$ only at a cost $m-n$ (the rest of $x_1$ must be zeros). So the first label costs about $-\log_2\big(\mathbf m(n)/\sum_{m\ge n}\mathbf m(m)\big)\approx K(n)-\min_{L\ge n}K(L)$ bits, which is $K(n)-O(\log\log n)$ for typical $n$, and the later labels are copies. Not proved.

**Remark 2.6b (a prior over $n$; corrects `notes.md`)** **[proved]**. If $n$ is drawn from a computable prior $w$ with $H(w)<\infty$, then with raw blocks $\mathbb E\,L^y_M\le H(w)+K(w)+c$. `notes.md` justified this by Lemma 1.3 applied to the mixture, which fails at $t=1$: raw blocks of different lengths are not prefix-free across $n$. Correct proof: $\nu:=\sum_nw(n)\mu_n^{\rm bin}$, with $\mu^{\rm bin}_n$ the law of the raw binary encoding, is a computable semimeasure on $\{0,1\}^*$, so $M\ge2^{-K(w)-c}w(n)\mu_n^{\rm bin}$. Telescoping as in Prop 2.10 gives $L^y_M(k)\le K(w)+c-\log w(n)+\log M(\varepsilon)+\log W_k$, and given $n$, $\mathbb E[W_1\mid n]\le\sum_{\lvert x\rvert=n}M(x)/M(\varepsilon)\le1$ because the strings of one length form a prefix-free set; later steps are as in Lemma 1.3. Take expectations over $n$. The $H(w)$ is paid on the inputs' block length, not on the labels. With the prefix code it is unnecessary (Prop 2.10).

### 2.6 Numbers

**Constants** **[computed: e3(a); Robbins window at 120 digits: e6(d)]**. $\log_2((N-1)!)$ and the per-pair average:

| $n$ | $N$ | $\log_2((N-1)!)$ | per pair $/N$ | $n-\log_2e$ |
|---|---|---|---|---|
| 2 | 4 | 2.585 | 0.646 | 0.557 |
| 4 | 16 | 40.250 | 2.516 | 2.557 |
| 8 | 256 | 1675.996 | 6.547 | 6.557 |
| 10 | 1024 | 8759.006 | 8.554 | 8.557 |
| 16 | 65536 | 954020.864 | 14.557 | 14.557 |
| 20 | $2^{20}$ | 19458735.931 | 18.557 | 18.557 |

The error term $\epsilon_N$ of Thm 2.1(4) lies strictly inside Robbins' window for every $n\le24$ and for $n=32,40,64$ (e6(d)). For example $\epsilon_N=0.059642$ at $n=1$ (window $(0.057708,0.060112)$) and $7.16594\cdot10^{-9}$ at $n=24$. `notes.md` said that $\epsilon_N$ "equals $1/(12N\ln2)$ to the printed precision for $n\le24$": that is false at $n=1,2$, and e3's double-precision column is rounding noise for $n\ge17$ (it prints $5.96\cdot10^{-8}$ at $n=24$).

**Proxies from `notes.md`** **[computed: e3(b)]**. Three exact Bayes mixtures over small enumerated classes (code: `sfi_examples.cyclic_example_losses`):
* *SFI proxy* (order-free): weight 1/6 each on the uniform cyclic-permutation law, the uniform permutation law, the uniform function law, and the maps $x\mapsto0$, identity, $x\mapsto x+1\bmod N$.
* *History proxy*: weight 1/3 each on copy-the-previous-input, uniform label, uniform over labels not yet used.
* *SI proxy*: weight 1/3 each on three joint models of $(x_1,y_1,x_2,\dots)$ with $n$-bit blocks as symbols: the true process; true inputs with uniform labels; all symbols uniform.

Cumulative losses in bits. At $k=N/2$ and $k=N$ they were identical across the 3 seeds for $n\ge3$: the random-function components depend only on $k$, and the three deterministic maps were inconsistent with the data.

| $n$ | SFI proxy, $k=N/2$ | $\log_2(N-1)_{N/2}$ | SFI proxy, $k=N$ | $\log_2((N-1)!)$ | history proxy, $k=N$ | SI proxy label loss, $k=N$ |
|---|---|---|---|---|---|---|
| 4 | 29.894 | 27.951 | 42.748 | 40.250 | 1.585 | 1.544 |
| 6 | 179.332 | 177.332 | 292.558 | 289.995 | 1.585 | 1.577 |
| 8 | 968.835 | 966.835 | 1678.576 | 1675.996 | 1.585 | 1.583 |
| 10 | 4894.840 | 4892.840 | 8761.590 | 8759.006 | 1.585 | 1.584 |
| 12 | 23670.861 | 23668.861 | 43240.632 | 43238.047 | 1.585 | 1.585 |

Over the cycle the SFI proxy pays $\approx\log_2((N-1)!)+\log_26$; exactly, $\log_2((N-1)!)+\log_26-\log_2(1+1/N+(N-1)!/N^N)$, which is $42.748$ at $n=4$ against $40.250+2.585=42.835$. The history and SI proxies pay the cost of their prior weight, $\log_23=1.585$ bits, in total. At $k=1$ the SFI proxy pays $\le2.6$ bits (the zero map), as Thm 2.3(1) predicts for SFI. This proxy has **no broom**, so at $k=N/2$ it pays about $\log_2(N-1)_k+\log_26$. For SFI, $K(N/2)\le K(n)+c$, so Thm 2.3(1) gives $L_{\rm SFI}(D_{N/2})\le\log_2(N-1)_{N/2}-(n-1)+K(n)+c$: the proxy overstates SFI's cost at $k=N/2$ by $n-O(\log n)$ bits. For a typical $k$, with $K(k)\ge\log_2(N-k)$, the cyclic law is already within a constant of the bound.

**Proxies with brooms and partial chains** **[computed: e6(e)]**. Closed forms, validated in e6(a), make these exact for every chain.
* *Order-free proxy with brooms*: weight $1/2$ on the cyclic law; on the broom $B_j$, weight $\tfrac14/(j(j+1))$ plus a further $\tfrac14/(i(i+1))$ when $j=2^i$ (imitating that $K(k)$ is small for simple $k$). Its loss after $k$ steps exceeds $\log_2(N-1)_{k-1}$ by about the cheaper of two routes: the cyclic law, at $\log_2(N-k)+1$ bits, and the broom $B_k$, at $\log_2(1/w_k)$ bits. This is Thm 2.3(1)'s $\min\{K(k),\log_2(N-k)\}$ in miniature. At $k=\lfloor N/3\rfloor$ the broom is expensive in this prior and the excess is $\log_2(N-k)+1$ up to $0.4$ bits (e.g. $12.41$ at $n=12$). At $k=N/2=2^{n-1}$ the broom route costs $2+\log_2(n(n-1))$ bits against $n$, and wins from $n=8$ on: the excess is $6.90$, $8.06$, $8.87$ bits at $n=8,10,12$, against $8$, $10$, $12$ for the cyclic route. At $k=N-1$ the excess is $\le1$ bit.
* *Normalised proxy*: cyclic law, brooms, and partial chains $P_j$ (a random spine $v_1,\dots,v_j$ with $v_1\mapsto0^n$, $v_i\mapsto v_{i-1}$, undefined elsewhere), with weights $(w_{\rm cyc},w_{\rm broom},w_{\rm partial})$:

| $n$ | weights | $\min_t$ margin in Prop 2.9's inequality | normalised loss, full cycle | semimeasure loss, full cycle | $\log_2((N-1)!)$ |
|---|---|---|---|---|---|
| 4 | (0.5, 0.5, 0) | 3.13 | 41.250 | 41.250 | 40.250 |
| 4 | (0.02, 0.02, 0.96) | 5.34 | 31.502 | 45.894 | 40.250 |
| 4 | (0.001, 0.001, 0.998) | 8.13 | 19.206 | 50.216 | 40.250 |
| 8 | (0.02, 0.02, 0.96) | 7.57 | 1673.913 | 1681.640 | 1675.996 |
| 10 | (0.001, 0.001, 0.998) | 10.58 | 8748.686 | 8768.972 | 8759.006 |

  With only total components the two conventions agree, as they must ([foundations] Prop 5.3(c)). With heavy weight on partial chains the normalised loss falls below the order-free bound, while the per-step inequality of Prop 2.9 (in its proxy form $\bar\ell_t\ge\log_2(N-t+1)+\log_2w^B_{t-1}$) holds at every step.

### 2.7 Remarks

**Remark 2.7 (where the information is)** **[proved]**. The labels carry no information beyond the inputs: $y_k=x_{k-1}$. All of $f$ is in the order of the inputs. SI and SFI$^{\rm hist}$ see the order; SFI sees each pair in isolation, and its loss is that of the unordered set. A set-based history-aware predictor that sees the previous *pairs* $D_{t-1}$ as a set can also predict perfectly: in $D_{t-1}$ the most recent input is the unique input that is not a label (this holds at every $t\le N$, including $x_N=0^n$). So the separation is between evaluating the data set as a whole and predicting with the past in view, not between sets and sequences. A predictor that sees only the *set of previous inputs* is weaker: on the full cycle SFI$^{\rm set}$ pays as much as SFI (Prop 2.11).

**Remark 2.8 (relation to the chain example).** Hänni's chain of increasingly long random strings is [history] Thm 2.1. The cyclic permutation is the finite, uniform version: one length $n$, all strings used, and a cost per step of about $n$ bits instead of the length of a new random block. The broom of Thm 2.3 is the randomised form of the chain's upper-bound program, and the method of Prop 2.9 transfers to the chain ([history] Prop 2.4; Remark 2.13).

**Remark 2.12 (a separation in the other direction).** All the H5 and H6 comparisons show SFI worse than SI or SFI$^{\rm hist}$. In the other direction, take $X=Y=\{0,1\}$ and identity labels $y_i=x_i$. SFI's loss is $\le c$ on every input sequence, by (F1) with the identity map. The history track (§4.4) shows: if unnormalised $M$ has unbounded loss on the copied bits of some sequence $\omega_1\omega_1\omega_2\omega_2\cdots$ (its hypothesis (LHG-even), which the abstract of Lattimore–Hutter–Gavane supports; theorem statement unverified), then with the identity code on single bits SI's unnormalised conditional label loss $L^y_M$ is unbounded on that input sequence, while SFI's loss and SFI$^{\rm hist}$'s are bounded. For the framed code $\bar s=1^{\lvert s\rvert}0s$ this needs a further transfer, and for $M_{\rm norm}$ it is open ([history] Q3). The history track owns this question; I add nothing to it.

---

## 3. Eisenstat's example (H6)

### 3.1 Setup

$b=(b_0,b_1,\dots)$ with $b_i$ i.i.d., $\Pr[b_i=1]=1/3$ ("heads", label 1). At each step $t=1,2,\dots$ an independent coin $\zeta_t$ with $\Pr[\zeta_t=1]=2/3$ decides: if $\zeta_t=1$, reveal the smallest unrevealed index $i$ with $b_i=1$, with label 1; else reveal the smallest unrevealed index with $b_i=0$, with label 0. After $n$ steps:
* $H_n,T_n$: numbers of heads and tails revealed ($H_n+T_n=n$, $T_n\sim\mathrm{Bin}(n,1/3)$, independent of $b$);
* $\tau_n$: tail frontier, $1+$ the index of the last revealed tail ($0$ if none); $\eta_n$: head frontier; $F_n=\max(\tau_n,\eta_n)$;
* $g_n$: the smallest unrevealed index; $R_n=\mathrm{dom}\,D_n$;
* $UB_n:=-\log_2P_{1/3}(b_{<\tau_n})=T_n\log_2\tfrac32+(\tau_n-T_n)\log_23=\tau_n\log_23-T_n$, where $P_{1/3}$ is the Bern(1/3) product measure.

Inputs are natural numbers; for SFI they are strings via the length-lexicographic bijection, which changes nothing below but constants.

**Lemma 3.1 (shape of the revealed set)** **[proved]**. The revealed tails are exactly the tails below $\tau_n$, and the revealed heads exactly the heads below $\eta_n$. An unrevealed index below $\eta_n$ is a tail; an unrevealed index below $\tau_n$ is a head; no unrevealed index lies below $\min(\tau_n,\eta_n)$. If $\tau_n\le\eta_n$ ("heads ahead"), then $[0,\tau_n)\subseteq R_n$, $g_n\ge\tau_n$, and every index in $[\tau_n,g_n)$ is a head. In all cases $[0,g_n)\subseteq R_n$, by definition of $g_n$.

*Proof.* The process always reveals the first unrevealed head (or tail), so the revealed heads are the first $H_n$ heads, and these are the heads below $\eta_n$; likewise for tails. The rest follows: an index below both frontiers is revealed whatever its label, and an index in $[\tau_n,g_n)$ is revealed but is not a revealed tail. $\square$

So after $n$ steps the revealed set is about $[0,n/2)$ together with the heads in $[n/2,2n)$, as the brief says: $\tau_n\approx\tfrac32T_n\approx n/2$ and $\eta_n\approx3H_n\approx2n$.

### 3.2 The threshold hypothesis and the upper bound

For $t\in\mathbb N$, the *threshold law* $\nu_t$ is the product law with $\Pr[y=1\mid i]=1/3$ for $i<t$ and $\Pr[y=1\mid i]=1$ for $i\ge t$. This is "our threshold function" of Hänni's e-mail, as I read it: Bern(1/3) below the threshold, constant 1 at and above it. It is a computable product law, hence a machine law with private randomness per input ([foundations] Prop 3.3(a)), with an index computable from $t$.

**Proposition 3.2 (upper bound)** **[proved]**. For every $b$, every reveal sequence of the above type (the choices may be arbitrary, even adversarial), and every $n$:
$$L_{\rm SFI}(D_n)\le UB_n+K(\tau_n)+c\le UB_n+\log(\tau_n+1)+2\log\log(\tau_n+2)+c.$$
The same bound holds for the normalised predictor's cumulative loss $\bar L_{\rm SFI}$ (§1.1).

*Proof.* $M_F\ge2^{-K(t)-c}\nu_t$ (F1). Take $t=\tau_n$. Revealed indices at or above $\tau_n$ are heads (Lemma 3.1), so they contribute factor 1. The revealed indices below $\tau_n$ contribute a sub-product of $P_{1/3}(b_{<\tau_n})$, which is $\ge P_{1/3}(b_{<\tau_n})$. Then (F9). $\square$

### 3.3 The lower bound and the pathwise sandwich

**Theorem 3.3 (pathwise sandwich, semimeasure convention)** **[proved]**. For every $b$, every reveal sequence and every $n$: $L_{\rm SFI}(D_n)\ge K(b_{<g_n}\mid g_n)-c$. If moreover $b$ is Martin-Löf random for $P_{1/3}$, then at every $n$ with $\tau_n\le\eta_n$:
$$UB_n-K(g_n)-c_b\ \le\ L_{\rm SFI}(D_n)\ \le\ UB_n+K(\tau_n)+c .$$
In Eisenstat's process, almost surely $\tau_n\le\eta_n$ and $g_n\le3n$ for all large $n$, so $\lvert L_{\rm SFI}(D_n)-UB_n\rvert\le\log_2n+O(\log\log n)+c_b$ eventually.

*Proof.* $[0,g_n)\subseteq R_n$ with labels $b_{<g_n}$ (Lemma 3.1). By (F2) and Lemma 1.1, $L_{\rm SFI}(D_n)\ge L_{\rm SFI}(D_n|_{[0,g_n)})\ge K(b_{<g_n}\mid[0,g_n))-c$, and the set $[0,g_n)$ and the number $g_n$ are computable from each other. For the second statement, $K(b_{<g_n}\mid g_n)\ge K(b_{<g_n})-K(g_n)-c\ge-\log P_{1/3}(b_{<g_n})-c_b-K(g_n)-c$ by (F4), and $-\log P_{1/3}(b_{<g_n})\ge-\log P_{1/3}(b_{<\tau_n})=UB_n$ because $g_n\ge\tau_n$ when $\tau_n\le\eta_n$. The upper bound is Prop 3.2. For the last sentence: $\Pr[\eta_n<\tau_n]\le20e^{-n/18}$ (Lemma 3.5) is summable, so by Borel–Cantelli the heads are eventually ahead. By the strong law of large numbers $H_n/n\to2/3$, $T_n/n\to1/3$, and the $j$-th head (tail) of $b$ sits at about $3j$ ($3j/2$), so $\eta_n/n\to2$ and $\tau_n/n\to1/2$ almost surely; hence $g_n\le F_n\le3n$ for all large $n$. Martin-Löf random $b$ have probability 1. Apply (F9) to $K(g_n)$ and $K(\tau_n)$. $\square$

The sandwich holds for **every** reveal sequence with the heads ahead, not only for Eisenstat's random one. The lower bound uses only that an initial segment of $b$ is revealed with its true labels.

### 3.4 Asymptotics of the threshold loss

**Proposition 3.4** **[proved; computed: e1(d), e2, e7(d)]**. Let $a:=\tfrac32\log_23-1$ and $\sigma^2:=\tfrac29a^2+\tfrac14(\log_23)^2=1.0496602$.
1. $\mathbb E\,UB_n=\tfrac{h(1/3)}2n=(\tfrac12\log_23-\tfrac13)n=0.4591479\,n$ exactly, for every $n$.
2. $\mathrm{Var}(UB_n)=\sigma^2n$ exactly, for every $n$.
3. $UB_n/n\to h(1/3)/2$ almost surely.
4. $(UB_n-\tfrac{h(1/3)}2n)/\sqrt n\Rightarrow N(0,\sigma^2)$.

*Proof.* Let $G_j$ be the number of heads before the $j$-th tail of $b$. Then $\tau_n=T_n+G_{T_n}$, so $UB_n=T_n(\log_23-1)+G_{T_n}\log_23$. $G_j=\sum_{i\le j}\xi_i$ with $\xi_i$ i.i.d. geometric (heads before a tail; $\Pr[\xi=j]=\tfrac23(\tfrac13)^j$), mean $1/2$ and variance $3/4$, and $G$ is independent of $T_n\sim\mathrm{Bin}(n,1/3)$. Write
$$UB_n-\tfrac{h(1/3)}2n=a\,(T_n-\tfrac n3)+\log_23\cdot(G_{T_n}-\tfrac{T_n}2).$$
1. $\mathbb E[G_{T_n}-T_n/2\mid T_n]=0$ and $\mathbb E\,T_n=n/3$; also $\tfrac n3a=\tfrac n2h(1/3)$ since $h(1/3)=\log_23-\tfrac23$.
2. The two terms are uncorrelated (condition on $T_n$). $\mathrm{Var}(T_n)=2n/9$ and $\mathrm{Var}(G_{T_n}-T_n/2)=\mathbb E[\tfrac34T_n]=n/4$.
3. $T_n/n\to1/3$ and $G_j/j\to1/2$ almost surely.
4. Let $\psi(s):=\mathbb E\,e^{is(\xi-1/2)}$. Since $\xi$ has a finite second moment, $\psi(s)=1-\tfrac38s^2+o(s^2)$ as $s\to0$. Fix $\theta$ and put $s_n:=\theta\log_23/\sqrt n$. By independence,
$$\mathbb E\exp\!\Big(i\theta\frac{UB_n-\frac{h(1/3)}2n}{\sqrt n}\Big)=\mathbb E\Big[e^{i\theta a(T_n-n/3)/\sqrt n}\,Z_n\Big],\qquad Z_n:=\psi(s_n)^{T_n}.$$
For large $n$, $\lvert\psi(s_n)-1\rvert<\tfrac12$, so $Z_n=\exp(T_n\,\mathrm{Log}\,\psi(s_n))$ with $\mathrm{Log}\,\psi(s_n)=-\tfrac38s_n^2+o(1/n)$. Since $T_n/n\to1/3$ in probability and $T_n\le n$, $Z_n\to z:=\exp(-\tfrac18\theta^2(\log_23)^2)$ in probability, and $\lvert Z_n\rvert\le1$. Hence $\lvert\mathbb E[e^{i\theta a(T_n-n/3)/\sqrt n}(Z_n-z)]\rvert\le\mathbb E\lvert Z_n-z\rvert\to0$ by bounded convergence, while $\mathbb E\,e^{i\theta a(T_n-n/3)/\sqrt n}\to\exp(-\tfrac12\theta^2a^2\cdot\tfrac29)$ by the de Moivre–Laplace theorem. The product of the limits is $\exp(-\tfrac12\theta^2\sigma^2)$. Lévy's continuity theorem gives the claim. $\square$

(`notes.md` marked part 4 as a proof sketch via an Anscombe-type random-sum CLT. No random-index theorem is needed: $T_n$ is independent of $G$. The second referee pointed this out.)

Computed: $\mathbb E\,UB_n-\tfrac h2n$ vanishes to $10^{-11}$ for $n\le1000$ (e1(d)); $\mathbb E\,UB_n/n$ and $\mathrm{Var}(UB_n)/n$ computed from the exact laws of $T_n$ and $G$ equal $0.459147917027$ and $1.049660151594$ for every $n$ tested (e7(d)); the empirical sd of $UB_n/\sqrt n$ is $0.99$–$1.11$ for $n=100,\dots,10^4$ against $\sigma=1.0245$ (e2).

**Lemma 3.5 (the heads frontier is rarely behind)** **[proved; computed: e7(a)]**. $\Pr[\eta_n<\tau_n]\le20\,e^{-n/18}$.

*Proof.* If $\eta_n<\tau_n$, all $H_n$ revealed heads lie below $\tau_n$, so $\tau_n\ge H_n+T_n=n$ and the prefix $b_{<\tau_n}$ contains exactly $T_n$ tails. Hence either $T_n\ge n/2$, or some $k\ge n$ has fewer than $k/2$ tails in $b_{<k}$. Hoeffding's inequality [known: W. Hoeffding, "Probability inequalities for sums of bounded random variables", *J. Amer. Statist. Assoc.* 58(301):13–30, 1963; bibliographic data confirmed by the referee's WebSearch snippet, full text unverified] gives $\Pr[T_n\ge n/2]\le e^{-2n(1/6)^2}=e^{-n/18}$ and $\Pr[\#\text{tails}(b_{<k})<k/2]\le e^{-k/18}$. Summing, $\Pr\le e^{-n/18}(1+1/(1-e^{-1/18}))\le19.6\,e^{-n/18}$. $\square$

The bound is far from tight, and it exceeds 1 for $n\le53$, but it is summable, which is all Theorem 3.3 needs. The exact values, from an exact DP over the frontier chain of Prop 3.9 (e7(a); the referee's `s2(a)` agrees), are $\Pr[\eta_n<\tau_n]=6.48\cdot10^{-2}$, $1.55\cdot10^{-2}$, $1.11\cdot10^{-3}$, $7.31\cdot10^{-6}$, $4.27\cdot10^{-10}$ at $n=10,20,40,80,160$. The DP agrees with exact rational arithmetic to $6\cdot10^{-17}$ at $n=10$, with a truncated exact enumeration over coins and $b$-prefixes for $n\le5$, and with a seeded direct simulation at $n=10,20,40$ within one standard error.

**Theorem 3.6 (expected SFI loss, semimeasure convention)** **[proved]**. For all $n\ge2$:
$$\tfrac{h(1/3)}2n-\log_2n-c\ \le\ \mathbb E\,L_{\rm SFI}(D_n)\ \le\ \tfrac{h(1/3)}2n+\log_2n+2\log_2\log_2n+c .$$
The upper bound also holds for $\mathbb E\,\bar L_{\rm SFI}$.

*Proof.* Upper: take expectations in Prop 3.2. $t\mapsto\log(t+1)+2\log\log(t+2)$ is concave and $\mathbb E\tau_n=n/2$, so Jensen applies; then Prop 3.4(1).
Lower: by Theorem 3.3, $L_{\rm SFI}(D_n)\ge K(b_{<g_n}\mid g_n)-c$ on every path. For each value $g$, Kraft gives $\mathbb E[K(b_{<g_n}\mid g)\mid g_n=g]\ge H(b_{<g_n}\mid g_n=g)$, so $\mathbb E\,L_{\rm SFI}\ge H(b_{<g_n}\mid g_n)-c=H(b_{<g_n})-H(g_n)-c$ (the string $b_{<g_n}$ determines its length $g_n$). Next:
* $\Pr[b_{<g_n}=s]\le\Pr[b_{<\lvert s\rvert}=s]=P_{1/3}(s)$, so $H(b_{<g_n})\ge\mathbb E[-\log P_{1/3}(b_{<g_n})]$.
* On $\{\tau_n\le\eta_n\}$, $g_n\ge\tau_n$ and $-\log P_{1/3}(b_{<g_n})\ge UB_n$. So $\mathbb E[-\log P_{1/3}(b_{<g_n})]\ge\mathbb E\,UB_n-\mathbb E[UB_n;\eta_n<\tau_n]$, and $\mathbb E[UB_n;\eta_n<\tau_n]\le\log_23\,(\mathbb E\tau_n^2)^{1/2}\Pr[\eta_n<\tau_n]^{1/2}=O(n)e^{-n/36}$ by Cauchy–Schwarz and Lemma 3.5.
* $g_n\le$ the first tail at or after $\tau_n$. The event $\{\tau_n=k\}$ depends only on the coins and $b_{<k}$, so the number of heads from $\tau_n$ to that tail has mean $1/2$, and $\mathbb Eg_n\le n/2+1/2$. A random variable on $\mathbb N$ with mean $\mu$ has entropy $\le\log_2(\mu+1)+\log_2e$ (the geometric law maximises it). So $H(g_n)\le\log_2(n/2+3/2)+\log_2e$.

Combine with Prop 3.4(1). $\square$

### 3.5 The exact law, and optimality among order-free predictors

**Proposition 3.7** **[proved; computed: e1(a), e1(b); s2(d), r1]**. Let $D$ be a possible value of $D_n$ ($n\ge1$), $H$ its number of 1-labels, $S=\mathrm{dom}\,D$, $M=\max S+1$, $g=\min(\mathbb N\setminus S)$, and $r=2/3$ if the label at $\max S$ is 1, $r=1/3$ if it is 0.
1. $\Pr[D_n=D]=\binom nH(2/9)^n\,r^{M-n}$.
2. Given $\mathrm{dom}\,D_n=S$, the labelling has law $\Pr[D\mid S]=\binom nHr^{M-n}/Z(S)$ with $Z(S)=\big((2/3)^{M-n}+(1/3)^{M-n}\big)\binom{n+g}g$ if $g<M$, and $Z(S)=\binom{2n}n$ if $S=[0,n)$.
3. For every weak function semimeasure $\nu$ (any order-free predictor, computable or not): $\mathbb E[-\log_2\nu(D_n)]\ge\mathbb E\,UB_n-\log_2n-O(1)=\tfrac{h(1/3)}2n-\log_2n-O(1)$.

*Proof.* 1. $D_n=D$ requires that the coins $\zeta_1,\dots,\zeta_n$ contain exactly $H$ ones (probability $\binom nH(2/3)^H(1/3)^{n-H}$, independent of $b$), and that the revealed heads and tails are the first $H$ heads and first $T=n-H$ tails of $b$. By Lemma 3.1 the second event fixes $b$ on $[0,M)$: the revealed indices carry their labels, and each of the $M-n$ unrevealed indices below $M$ is a tail if the top revealed index is a head (it lies below $\eta$) and a head otherwise. So it has probability $(1/3)^H(2/3)^T\,r'^{\,M-n}$ with $r'=2/3$ or $1/3$ accordingly. Multiplying, $(2/3)^H(1/3)^T(1/3)^H(2/3)^T=(2/9)^n$, and $r'=r$.
2. All labellings with domain $S$ share $n$ and $M$. Suppose $g<M$. A labelling with top label 1 is determined by its tail frontier $\tau'\in[0,g]$: labels on $[0,\tau'-1)$ arbitrary, label 0 at $\tau'-1$ (if $\tau'\ge1$), label 1 on $S\setminus[0,\tau')$. Summing $\binom nH$ over those with frontier $\tau'$ gives $\sum_j\binom{\tau'-1}j\binom n{\tau'-j}=\binom{n+\tau'-1}{\tau'}$ (Vandermonde), and $\sum_{\tau'=0}^g\binom{n-1+\tau'}{\tau'}=\binom{n+g}g$ (hockey stick). Top label 0 is symmetric. If $S=[0,n)$, every labelling of $[0,n)$ is possible with $M-n=0$, and $\sum_H\binom nH^2=\binom{2n}n$.
3. Weak semimeasures are monotone ([foundations] Def 2.1, consequence (a)), so $\nu(D_n)\le\nu(D_n|_{[0,g_n)})$. For each $g$, $\sum_l\nu(l)\le1$ over the labellings $l$ of $[0,g)$ (consequence (b)), so Gibbs' inequality, applied conditionally on $g_n=g$, gives $\mathbb E[-\log\nu(D_n|_{[0,g_n)})]\ge H(b_{<g_n}\mid g_n)$. The rest of the lower-bound part of the proof of Theorem 3.6 applies verbatim. $\square$

**Correction.** `notes.md` said: "Part 2 says the conditional law of the labels given the domain depends on the labelling only through the number of heads." That is **[refuted]**: the factor $r^{M-n}$ depends on the label at $\max S$. *Counterexample* (exact; both referees' code confirms it): on $S=\{0,1,3\}$ ($n=3$, $M=4$, $g=2$, $Z(S)=10$), the labellings $(0,1,1)$ and $(1,1,0)$ both have $H=2$, but their conditional probabilities are $3\cdot\tfrac23/10=\tfrac15$ and $3\cdot\tfrac13/10=\tfrac1{10}$. The formula of part 2 itself is right; it normalises to exactly 1 on all 3301 reachable domains with $\lvert S\rvert\le7$ inside $[0,12)$ (`s2(d)`) and on all domains for $n\le6$ (`r1`, e1(b)). The conditional law depends on the labelling through $H$ **and the label at $\max S$**.

Part 2's surprisal $-\log_2\Pr[D_n\mid S_n]\approx\log_2\binom{n+g_n}{g_n}-\log_2\binom n{T_n}$ is what Lemma 1.2 compares $K(D_n\mid S_n)$ with. Computed (e2, column BayesX): its mean is $0.4597n$ at $n=3000$ and $10^4$, and it differs from $UB_n$ by $-0.3$ to $-0.6$ bits on average and by at most $8.7$ bits in any of 1040 runs.

By Theorem 3.6 and Prop 3.7(3), SFI is optimal among all order-free predictors up to $O(\log n)$ in expectation. The gap to SI below is a property of order-free prediction, as in H5.

### 3.6 Hänni's e-mail claim

The claim: "log loss in your solomonoff function induction coinflip question is the loss given by our threshold function, up to o(n) terms." **Verdict: correct in the semimeasure convention, and true there up to $O(\log n)$ almost surely** (Theorem 3.3), with the threshold placed at the tail frontier $\tau_n$. For the normalised predictor the upper bound holds and the lower bound is **[open]** (§3.9).

His sketch, checked step by step.
* *Easy direction.* "SFI's loss is at most the threshold function's, up to a log n term for specifying the threshold, because this guy lives inside the Solomonoff distribution." Correct: Prop 3.2, with $K(\tau_n)\le\log n+2\log\log n+c$.
* *Other direction.* "If $L_S<0.999L_T$, then SFI's loss on the initial mixed segment is even lower; then one can specify the coinflip sequence with only that many bits (pointing trick); this contradicts incompressibility at $h(1/3)$ per bit." Correct in substance. The precise version is Theorem 3.3:
  * "Even lower" is monotonicity (F2) applied to the initial segment $[0,g_n)$, which is entirely revealed.
  * The "pointing trick" is the coding theorem conditional on the domain (Lemma 1.1). Unconditionally one pays $K(g_n)=O(\log n)$ to specify the segment.
  * Incompressibility must be measured by the empirical surprisal $-\log_2P_{1/3}(b_{<\tau_n})$, via Levin–Schnorr (F4) pathwise or Lemma 1.2 in probability. Measuring it by $\tau_nh(1/3)$, as the sketch does, gives only $\pm O(\sqrt n)$: $UB_n-\tau_nh(1/3)=\tfrac23(G_{T_n}-T_n/2)$ fluctuates by $\Theta(\sqrt n)$ (check: $T_n=1$, $G_{T_n}=0$ gives $\log_2\tfrac32-h(1/3)=-\tfrac13$ on both sides). That is enough for $o(n)$ but not for $O(\log n)$.
* *Numbers.* $\mathbb E\,L_{\rm SFI}(D_n)=0.459148\,n+O(\log n)$, with fluctuations of standard deviation $1.0245\sqrt n$; the brief's $\approx0.459n$ is right. The i.i.d. Bern(1/3) hypothesis pays $\mathbb E[H_n\log_23+T_n\log_2\tfrac32]=(\log_23-\tfrac13)n=1.2516n$; the i.i.d. Laplace mixture pays about $0.92n$ (e2), because the revealed labels are 2/3 heads.

### 3.7 The Bayes history-aware predictor

**Lemma 3.8 ($P^*$)** **[proved; computed: e1(c)]**. Let $h$ be a history after $t-1$ steps, with frontiers $\tau,\eta$, $F=\max(\tau,\eta)$, smallest unrevealed index $g$, and let $x$ be the next input. Call $h$ *touching* if $g=F$, i.e. the revealed set is the initial segment $[0,F)$. The true conditional probability that the label of $x$ is 1 is
* $0$ if $x<\eta$; $1$ if $x<\tau$ (exactly one of these holds when $x<F$);
* if $x\ge F$ and $h$ is not touching: $1$ if $\tau\le\eta$, and $0$ if $\eta<\tau$;
* if $x\ge F$ and $h$ is touching, with $d=x-F$: $2^d/(2^d+1)$.

Call this $P^*(1\mid h,x)$. It is computable, and its loss is positive only at touching steps.

*Proof.* The first case is Lemma 3.1. Suppose $x\ge F$. If $\tau\le\eta$ and $h$ is not touching, there is an unrevealed index in $[\tau,\eta)$; the first one is the first tail at or after $\tau$, so a tail reveal would give an input $<\eta\le x$; hence the reveal was a head. The case $\eta<\tau$ is symmetric. If $h$ is touching, the history depends only on $\zeta_1,\dots,\zeta_{t-1}$ and $b_{<F}$, so $\zeta_t$ and $b_{\ge F}$ are still independent with their prior laws. A head reveal at $x=F+d$ has probability $\tfrac23\cdot(\tfrac23)^d\tfrac13$ (the coin, $d$ tails, a head); a tail reveal there has probability $\tfrac13(\tfrac13)^d\tfrac23$. The ratio is $2^d$. $\square$

The script e1(c) compares $P^*$ with the brute-force conditional on every reachable (history, input) pair for $n\le5$ (14178 pairs): the maximum difference is 0.

**Proposition 3.9 (the burn-in)** **[proved; computed: e1(e), e7(a),(b)]**. Let $N_{\rm touch}$ be the number of touching steps over the whole infinite run (step 1 is always touching). Then $\Pr[N_{\rm touch}=j]=(2/3)^{j-1}(1/3)$, so $\mathbb EN_{\rm touch}=3$. Each touching step costs $P^*$ an expected
$$\kappa=\sum_{d\ge0}\tfrac29\Big[(\tfrac23)^d\log_2(1+2^{-d})+(\tfrac13)^d\log_2(1+2^d)\Big]=0.79951673634959487\ \text{bits},$$
and $\mathbb E\,L_{P^*}(n)\le\mathbb E\,L_{P^*}(\infty)=3\kappa=2.39855020904878$ bits. $L_{P^*}(\infty)<\infty$ almost surely.

*Proof.* Track the *state* after each step: touching; $(A,U)$, heads ahead with $U\ge1$ unrevealed tails in $[\tau,\eta)$; or $(B,U)$, heads behind with $U\ge1$ unrevealed heads in $[\eta,\tau)$. Indices $\ge F$ are fresh. The transitions are:
* From touching: a head reveal skips $d$ tails with probability $\tfrac23(\tfrac23)^d\tfrac13$, giving $(A,d)$, or touching if $d=0$; a tail reveal skips $d$ heads with probability $\tfrac13(\tfrac13)^d\tfrac23$, giving $(B,d)$, or touching if $d=0$.
* From $(A,U)$: a tail reveal (probability $1/3$) gives $U-1$; a head reveal (probability $2/3$) gives $U+j$ with $\Pr[j]=\tfrac13(\tfrac23)^j$. Reaching $U=0$ means touching.
* From $(B,U)$: a head reveal (probability $2/3$) gives $U-1$; a tail reveal gives $U+j$ with $\Pr[j]=\tfrac23(\tfrac13)^j$.

The $A$-walk moves down by exactly one and has drift $-\tfrac13+\tfrac23\cdot2=1>0$. Let $\varphi$ be the probability of ever going one level down. By the strong Markov property, descending $j+1$ levels has probability $\varphi^{j+1}$, so first-step analysis gives $\varphi=\tfrac13+\tfrac23\sum_j\tfrac13(\tfrac23)^j\varphi^{j+1}=\tfrac13+\tfrac{2\varphi}{3(3-2\varphi)}$, i.e. $2\varphi^2-3\varphi+1=0$, with roots $1/2$ and $1$. If $\varphi=1$, the walk would reach every lower level almost surely, contradicting its convergence to $+\infty$ (strong law). So $\varphi=1/2$, and from $(A,d)$ the walk returns to touching with probability $2^{-d}$. The $B$-walk has drift $-\tfrac23+\tfrac13\cdot\tfrac12=-\tfrac12<0$ and returns almost surely. The return probability from touching is
$$\tfrac29+\tfrac29+\sum_{d\ge1}\tfrac29(\tfrac23)^d2^{-d}+\sum_{d\ge1}\tfrac29(\tfrac13)^d=\tfrac49+\tfrac19+\tfrac19=\tfrac23 .$$
After each touching step the future is a fresh copy of the process from a touching state (the revealed initial segment plays no role), so $N_{\rm touch}$ is geometric. $\kappa$ is the expected $P^*$ loss of a touching step, by Lemma 3.8 and the probabilities in its proof. Given a touching history, the step's loss has conditional mean $\kappa$, so $\mathbb E\,L_{P^*}(n)=\kappa\,\mathbb EN_{\rm touch}(n)\le3\kappa$. $\square$

Computed: the return probability evaluates to $2/3$ and $\varphi=1/2$ by value iteration from 0 (e7(b)); $\kappa$ to 40 digits (e7(b)); $\mathbb EN_{\rm touch}(n)=2.611,2.907,2.993,3.000$ at $n=10,20,40,80$ by exact DP (e7(a)); a simulated $A$-walk descends with frequency $0.5008$ (e1(e), 20000 runs).

**Theorem 3.10 (SFI$^{\rm hist}$ and SI)** **[proved]**.
1. *SFI$^{\rm hist}$.* For every $b$, every coin sequence and every $n$: $L_{\rm hist}(n)\le L_{P^*}(n)+c$. Hence $\mathbb E\,L_{\rm hist}(n)\le3\kappa+c$ for all $n$, and $\sup_nL_{\rm hist}(n)<\infty$ almost surely.
2. *SI.* Encode the history with the paper's code, $\bar x_1\bar y_1\bar x_2\bar y_2\cdots$, writing each index as a string and each label as a one-bit string. For $\rho\in\{M,M_{\rm norm}\}$: $\mathbb E\,L^y_\rho(n)\le3\kappa+c$ for all $n$, and $\Pr[\exists n:L^y_\rho(n)>L_{P^*}(n)+c+m]\le2^{-m}$. So SI's total label loss over the infinite run is finite almost surely, and at most $L_{P^*}(\infty)+c+m$ with probability $\ge1-2^{-m}$.

*Proof.* 1. $P^*$ is computable and gives positive probability to every realised label; apply (F7). 2. The true process $\mu$ is a computable law on pair sequences, with all conditional probabilities rational (Lemma 3.8 and its proof give them). By (F10), $M(\mathrm{code}(h))\ge2^{-K(\mu)-c}\mu(h)$ with $K(\mu)=O(1)$, and $M_{\rm norm}\ge M$ (F11). The label conditionals of $\mu$ are $P^*$. Apply Lemma 1.3 and Prop 3.9. $\square$

(Any fixed prefix-free code for the indices gives the same statement with another constant; `notes.md` left the code unspecified.)

**Corollary 3.11 (the brief's rule)** **[proved]**. In a state $(A,U)$, the rule "the new input is a tail iff it equals the smallest unrevealed index $g$" is exact. Almost surely there is a last touching step (Prop 3.9). After it the process moves to some $(A,d)$ and stays in $A$-states forever ($B$-excursions return surely, so the last exit cannot be into $B$). From then on the rule never errs. Before that it can err, at touching steps and in $B$-states: this is the burn-in, whose expected cost to the Bayes predictor is $3\kappa$.

*Proof.* In $(A,U)$ the unrevealed indices in $[\tau,\eta)$ are tails, so $g$ is the next tail to be revealed, and a head reveal lands at an index $\ge\eta>g$. The rest is Lemma 3.8 and the proof of Prop 3.9. $\square$

**Proposition 3.12 (exact statistics of the brief's rule)** **[proved; computed: e7(a),(b); simulated: e2]**. Let $E_{\rm rule}$ be the number of steps over the infinite run at which the brief's rule errs. Then $\mathbb E\,E_{\rm rule}=2$ and $\Pr[E_{\rm rule}=0]=1/2$.

*Proof.* Classify steps by the state of the history before them.
* *Touching step.* The input is $x=F+d$ and $g=F$, so the rule says "tail" iff $d=0$. It errs on a head with $d=0$ (probability $\tfrac29$) and on a tail with $d\ge1$ (probability $\sum_{d\ge1}\tfrac29(\tfrac13)^d=\tfrac19$).
* *$A$-state.* No error (Cor 3.11).
* *$B$-state.* Every step is an error: the unrevealed indices below $\tau$ are heads, so $g$ is the next head; a head reveal lands at $g$ (the rule says "tail"), and a tail reveal lands at an index $\ge\tau>g$ (the rule says "head").

A $B$-excursion from $(B,d)$ lasts until the $B$-walk hits 0. Its increments are i.i.d. with mean $-\tfrac12$, it moves down by exactly one, and so by Wald's identity [known: standard, e.g. A. Wald, *Sequential Analysis*, Wiley 1947 (unverified)] its expected length is $2d$ (the hitting time $S_0$ is integrable because, by optional stopping at $S_0\wedge m$ and $U\ge0$, $\mathbb E[S_0\wedge m]\le2d$ for every $m$). From a touching step the expected number of $B$-steps that follow before the next touching step is $\sum_{d\ge1}\tfrac13(\tfrac13)^d\tfrac23\cdot2d=\tfrac49\cdot\tfrac34=\tfrac13$. So the expected number of errors in a *cycle* (a touching step and the excursion after it) is $\tfrac29+\tfrac19+\tfrac13=\tfrac23$. The cycles are i.i.d. (regeneration, as in Prop 3.9), and $N_{\rm touch}$ is the index of the first cycle that does not return, a stopping time for the cycle sequence. Wald's identity gives $\mathbb E\,E_{\rm rule}=\mathbb EN_{\rm touch}\cdot\tfrac23=2$.
For the second claim, let $p$ be the probability of no error ever, from a touching history. A first step without error is a tail with $d=0$ (probability $\tfrac29$; back to touching) or a head with $d\ge1$ (probability $\tfrac29(\tfrac23)^d$; to $(A,d)$, error-free, returning to touching with probability $2^{-d}$). So $p=\tfrac29p+\sum_{d\ge1}\tfrac29(\tfrac23)^d\big(2^{-d}p+1-2^{-d}\big)=\tfrac29p+\tfrac19p+\tfrac49-\tfrac19$, whence $p=\tfrac12$. $\square$

Finite-$n$ values (exact DP, e7(a)): expected rule errors in the first $n$ steps $1.575$, $1.891$, $1.992$, $2.000$ and probability of no error $0.508$, $0.501$, $0.500$, $0.500$ at $n=10,20,40,80$. e2's simulation (1000 runs of length 1000) gave $1.98$ errors on average and no error in $48.8\%$ of runs, consistent with the exact limits; the first referee's and second referee's DPs give the same limits.

### 3.8 Numbers

**Monte Carlo** **[computed: e2, seed 20261011]**. Means over runs; losses in bits. SFIproxy is the exact order-free Bayes mixture of the i.i.d. Laplace law and two threshold families (Bern($\theta$) with Laplace $\theta$ below $s$, constant 1 or constant 0 from $s$ on, $s\sim1/((s+1)(s+2))$), weight 1/3 per family (code: `sfi_examples.threshold_mixture_loss`). All its components are total, so its semimeasure and normalised losses coincide ([foundations] Prop 5.3(c)). BayesX is $-\log_2\Pr[D_n\mid S_n]$ (Prop 3.7(2)). SIproxy is the label loss of a Bayes mixture of three joint models (true process; true inputs with Laplace labels; a null model), weight 1/3 each.

| $n$ | runs | SFIproxy$/n$ | $UB_n/n$ | BayesX$/n$ | iid(1/3)$/n$ | sd$(UB_n)/\sqrt n$ | SFIproxy$-UB_n$ mean [min, max] | $P^*$ | SIproxy | touching steps |
|---|---|---|---|---|---|---|---|---|---|---|
| 100 | 400 | 0.5785 | 0.4498 | 0.4548 | 1.2532 | 0.989 | 12.9 [6.8, 15.5] | 2.18 | 3.32 | 2.83 |
| 300 | 300 | 0.5157 | 0.4598 | 0.4617 | 1.2516 | 1.053 | 16.8 [11.3, 19.1] | 2.47 | 3.59 | 3.06 |
| 1000 | 200 | 0.4840 | 0.4630 | 0.4636 | 1.2502 | 1.113 | 21.0 [15.7, 23.2] | 2.30 | 3.43 | 2.88 |
| 3000 | 100 | 0.4682 | 0.4597 | 0.4599 | 1.2517 | 1.042 | 25.3 [20.9, 27.1] | 2.32 | 3.43 | 3.01 |
| 10000 | 40 | 0.4627 | 0.4597 | 0.4597 | 1.2510 | 1.113 | 29.4 [26.2, 31.1] | 2.17 | 3.29 | 2.85 |

Theory: $UB_n/n\to0.4591$, $\sigma=1.0245$, iid(1/3) $\to1.2516$, $P^*\to2.3986$, touching $\to3$. The standard error of $UB_n/n$ is $0.005$ at $n=100$ and $0.0018$ at $n=10^4$, so the means agree with $0.4591$ within two standard errors.

* SFIproxy $-\,UB_n$ grows like $2.5\log_2n$: about $2\log_2\tau_n$ for the threshold prior, $\tfrac12\log_2\tau_n$ for the unknown bias, and $\log_23$ for the family weight. This is the $O(\log n)$ of Prop 3.2 in a concrete mixture.
* SIproxy $-\,P^*$ is $1.12$ on average and at most $2.42$ over all runs; Lemma 1.3 bounds it by $\log_23+m$ with probability $\ge1-2^{-m}$.
* $P^*$'s loss is heavy-tailed: a tail revealed far beyond $F$ at a touching step costs $\log_2(1+2^d)\approx d$ bits; the largest total in 1040 runs was 20.6 bits.
* The brief's literal rule (1000 runs of length 1000, seed 20261012): 1.98 errors per run on average, at most 35; no error at all in 48.8% of runs; the last error occurred at step 4 (median over runs with an error), at step $\le30$ in 99% of them, and never after step 42. The exact limits are 2 and 1/2 (Prop 3.12).
* One run of length $2\cdot10^4$ (seed 7): SFIproxy$/t$ is $1.25,0.70,0.46,0.48,0.47$ at $t=10,100,10^3,10^4,2\cdot10^4$, while $P^*$ and SIproxy stay at $2.76$ and $3.90$ bits from $t=10$ on. Shuffling the reveal order leaves SFIproxy unchanged ($9309.577698$ bits both ways).

### 3.9 Normalised SFI in H6

Upper bounds transfer: $\bar L_{\rm SFI}(h_n)\le L_{\rm SFI}(D_n)\le UB_n+K(\tau_n)+c$ on every path (Prop 3.2), so $\mathbb E\,\bar L_{\rm SFI}\le\tfrac{h(1/3)}2n+\log_2n+2\log_2\log_2n+c$. Whether $\mathbb E\,\bar L_{\rm SFI}\ge\tfrac{h(1/3)}2n-o(n)$ is **[open]**. The method of Prop 2.9 does not work here. It would bound the normaliser at step $t$ from below by a total hypothesis consistent with the past, the threshold law $\nu_{\tau_{t-1}}$, at cost $K(\tau_{t-1})$. Against this overhead of order $\log t$, the expected information of one step is only $\mathbb E[UB_t-UB_{t-1}]\approx0.46$ bits, so the per-step bound is negative. Grouping steps into blocks does not help: over a block, the loss of normalisation is a sum of per-step terms $\log(1/Z_s)$, each of which this method bounds only by $O(\log s)$. A set-based history-aware predictor ($P^*$) has $O(1)$ loss here, so information-theoretic arguments alone cannot settle the question.

---

## 4. Positive examples

The bounds in this section are stated with $K(f)$ or explicit code lengths. They are upper estimates of $L_{\rm SFI}$, which can be smaller ([foundations] Thm 4.7; [context] §1.3, "Notation $L_\nu$").

**Proposition 4.1 (deterministic targets)** **[proved]**. Let $f$ be partial computable and $(x_t)$ any sequence of inputs in $\mathrm{dom}\,f$ (adversarial, adaptive, or uncomputable; repetitions allowed). Then for every $n$:
1. $L_{\rm SFI}(D_n)\le K(f)+c$, whatever the order;
2. the number of steps $t\le n$ at which SFI's predictive probability of $f(x_t)$ is $\le1/2$ is at most $K(f)+c$, in the semimeasure convention and in the normalised one.

*Proof.* 1. (F1) with the deterministic machine for $f$ ([foundations] Thm 6.1(b)). 2. Each such step contributes at least 1 bit to $\sum_t-\log_2[M_F(D_t)/M_F(D_{t-1})]=L_{\rm SFI}(D_n)$. The normalised conditional is at least the raw one ([foundations] Cor 6.6). $\square$

This is the deterministic case of [context] Thm 2.7, which also bounds the sum of error probabilities by $(\ln2)(K(f)+c)$. The examples below give explicit $K(f)$ bounds and, where possible, matching lower bounds for every learner.

**Example 4.2 (sparse parity)** **[proved; computed: e4(a)]**. For $S\subseteq\{0,\dots,d-1\}$ with $\lvert S\rvert=k$, let $\chi_S(x)=\bigoplus_{i\in S}x_i$ on bit strings (positions beyond $\lvert x\rvert$ read as 0).
* *Upper.* $K(\chi_S)\le K(S)+c\le\log_2\binom dk+K(d)+K(k)+c$ (enumerative code given $d,k$). So $L_{\rm SFI}\le\log_2\binom dk+K(d)+K(k)+c$ on every input sequence.
* *Lower, for every learner.* Let $S$ be uniform among $k$-subsets and the inputs any fixed sequence whose labels determine $S$ (e.g. containing $e_0,\dots,e_{d-1}$). Every predictor, history-aware or not, issues sub-probabilities over label sequences given the inputs, so its expected loss is $\ge H(S)=\log_2\binom dk$ (F6).

So SFI is optimal here up to $K(d)+K(k)+c=O(\log d)$. Computed on a proxy with prior $2^{-(\lvert S\rvert+1)}/\binom d{\lvert S\rvert}$ for $\lvert S\rvert\le4$, $d=16$, $k=3$ (200 random targets per row; random inputs):

| $m$ examples | mean loss | max loss | mean / max steps with $P(\text{correct})\le1/2$ | $P(S^*\mid D)$ |
|---|---|---|---|---|
| 4 | 4.81 | 6.89 | 1.99 / 4 | 0.004 |
| 8 | 9.93 | 11.87 | 4.02 / 8 | 0.140 |
| 16 | 13.11 | 13.12 | 5.07 / 8 | 0.989 |
| 24 | 13.13 | 13.13 | 5.04 / 9 | 1.000 |
| 64 | 13.13 | 13.13 | 4.95 / 9 | 1.000 |

The loss saturates at $-\log_2w(S^*)=13.13$ bits ($=\log_2\binom{16}3+4$, the 4 bits paying for $\lvert S\rvert$), and the shuffled order gives the same loss to machine precision. In the unit-vector order the loss rises by about 4 bits exactly at the three coordinates in $S^*$ and by $\le0.2$ bits elsewhere.

**Example 4.3 (threshold)** **[proved; computed: e4(b)]**. $f_\theta(x)=[x\ge\theta]$ on $\mathbb N$. $L_{\rm SFI}(D)\le-\log_2\sum_{\theta'\text{ consistent with }D}2^{-K(\theta')}+c\le K(\theta)+c$. Lower bound for every learner: for $\theta$ uniform on $[0,2^j)$ and the $j$ bisection queries, the labels determine $\theta$, so the expected loss is $\ge j$ (the queries are adaptive, but the probabilities a predictor assigns to the $2^j$ possible label sequences still sum to at most 1); SFI pays $\le j+K(j)+c$. On a proxy with prior $2^{-(2\lfloor\log_2(\theta+1)\rfloor+1)}$, the bisection inputs cost exactly $-\log_2w(\theta^*)$ (5, 19, 33, 39 bits for $\theta^*=5,10^3,123456,10^6$), while 20 random inputs cost 0 to 22 bits, the same for random and sorted order.

**Example 4.4 (sorting)** **[proved]**. With a fixed encoding of finite lists, $f_{\rm sort}$ has $K=O(1)$. So SFI's total loss over any number of (list, sorted list) examples, of any lengths, in any order, is at most a constant depending only on the universal machine and the encoding; and so is the number of steps where the correct sorted list gets probability $\le1/2$.

**Example 4.5 (integer polynomials)** **[proved]**. $p(x)=\sum_{i\le d}a_ix^i$.
* For coefficients in $\{0,\dots,A-1\}$: $K(p)\le(d+1)\log_2A+K(d)+K(A)+c$, by the enumerative code of the coefficient tuple given $(d,A)$. If $(a_0,\dots,a_d)$ is uniform on $\{0,\dots,A-1\}^{d+1}$ and the inputs include $d+1$ distinct points, the labels determine $p$, so every learner has expected loss $\ge(d+1)\log_2A$. So SFI is optimal up to $K(d)+K(A)+c=O(\log d+\log A)$.
* For arbitrary integer coefficients: $K(p)\le\sum_iK(a_i)+K(d)+c$ (read $d$, then $d+1$ self-delimiting descriptions).

(`notes.md` stated $(d+1)(\log_2A+2\log_2\log_2A)+O(d)$ for the first case; that is true but loose.)

**Proposition 4.6 (frozen label noise)** **[proved; computed: e4(c)]**. Let $g:X\to\{0,1\}$ be partial computable and let the labels be $y_x=g(x)\oplus\xi_x$, with $\xi_x$ i.i.d. Bern($\varepsilon$), drawn once per input ("frozen" noise, so a repeated input repeats its label).
1. For every data set $D$ with $\mathrm{dom}\,D\subseteq\mathrm{dom}\,g$, $\lvert\mathrm{dom}\,D\rvert=n$, and $e$ labels that disagree with $g$:
$$L_{\rm SFI}(D)\le\log_2\binom ne+\log_2(n+1)+K(g)+c.$$
2. Suppose the $n$ distinct inputs are chosen without access to the noise at unrevealed inputs (fixed in advance, random, or adaptively from the revealed labels). Then $e\sim\mathrm{Bin}(n,\varepsilon)$ and $nh(\varepsilon)\le\mathbb E\,L_{\rm SFI}(D_n)\le nh(\varepsilon)+\log_2(n+1)+K(g)+c$. The lower bound $nh(\varepsilon)$ holds for every learner, history-aware or not.

*Proof.* 1. Let $T_g$ read a uniform real $\varepsilon'$ lazily from a shared part of the tape and, for each input $x$, a private uniform real $u_x$; it outputs $g(x)\oplus[u_x<\varepsilon']$, comparing bits until they differ (finitely many with probability 1). Its law is the Laplace mixture $\nu_g(D)=\int_0^1\varepsilon'^{\,e}(1-\varepsilon')^{\lvert D\rvert-e}d\varepsilon'=1/((\lvert D\rvert+1)\binom{\lvert D\rvert}e)$, and $K(\nu_g)\le K(g)+c$. Apply (F1). 2. Each new input's flip is Bern($\varepsilon$) and independent of the past, so $e\sim\mathrm{Bin}(n,\varepsilon)$. For the upper bound use $\log_2\binom ne\le nh(e/n)$ and concavity of $h$. For the lower bound: given the past and the new input, the new label has conditional entropy $h(\varepsilon)$, so Gibbs' inequality at each step gives every predictor expected loss $\ge h(\varepsilon)$ per step. $\square$

$T_g$ shares the flip rate $\varepsilon'$ across inputs, so it is a machine law (a mixture of product laws), not a product law. In the product class the same bound holds up to $O(\log n)$ ([steeper] §8.3). Computed on a proxy ($d=12$, $\lvert S^*\rvert=3$, $\varepsilon=0.1$; parities $\lvert S\rvert\le3$ with Laplace flip rate; 100 runs per row): the regret against the noise-aware oracle is $14.9,15.8,16.5,17.3$ bits at $n=100,400,1600,3200$, close to $-\log_2w(S^*)+\tfrac12\log_2n$ ($15.0,16.0,17.0,17.5$), and the mixture loss is below the bound of Prop 4.6 in every run (up to $10^{-11}$ rounding). The posterior on $S^*$ is $0.53$ at $n=25$ and $1.000$ from $n=100$.

**Remark 4.7 (fresh noise, brief H7)** **[proved, citing foundations]**. Let pairs be drawn i.i.d. from $\pi\times P(y\mid x)$ with fresh noise at every draw. If inputs never repeat (for example, distinct by design), fresh and frozen noise coincide, and [foundations] Thm 6.1(a) gives $L_{\rm SFI}(D_n)\le\sum_t-\log P(y_t\mid x_t)+K(P)+c$ pathwise, so the expected regret against $P$ is at most $K(P)+c$. Prop 4.6 is the case $P(y\mid x)=$ Bern($\varepsilon$) around $g$. If some input has positive probability and $P(\cdot\mid x)$ is not deterministic there, a repeat with a different label occurs with positive probability, and $\mathbb E\,L_{\rm SFI}=\infty$ in both conventions ([foundations] Prop 6.8). Time stamps or the per-query mixture $M_{\rm pq}$ repair this ([foundations] Thm 6.7(b), Prop 6.9).

---

## 5. Hänni's OOD examples

The general OOD results are in the context track; I use them and do not re-prove them ([context] `notes-final.md`).
* [context] Prop 2.1: if a decidable property $Q$ contains no training input, then for every partial computable $b$ the posterior probability that SFI behaves like $b$ on all of $Q$ is $\ge2^{-K(Q,b)-c}$, however large the training set.
* [context] Prop 2.3: the same with $Q,b$ simple *given* a program $p$ consistent with the data: the bound is $2^{-K(q,r\mid p)-c}$ times the posterior weight of $p$.
* [context] Thm 2.5 (two-sided bound; part (3) for single inputs) and Prop 2.4 (machine dependence: (a) for the program mixture $W$, (b) for $M_F$; a universal machine at most $K(Q,b)+c$ bits from the reference gives probability $\ge1/2$ to $b$ on $Q$).
* [context] Thm 2.7: the total error over any input sequence is $\le(\ln2)(K(f)+c)$ (Prop 4.1 above).
* [context] Ex 2.15 and 2.15a: easy-to-hard generalisation and shortest-proof labels.

These lower bounds bound the posterior mass that is *defined and wrong*, so they hold in both conventions ([context] §1.2).

**Proposition 5.1 (the intended answer)** **[proved]**. If the labels follow a partial computable $g$ and $x\in\mathrm{dom}\,g$ is any new input, SFI's predictive probability of $g(x)$ is at least $2^{L_{\rm SFI}(D)-K(g)-c}$, in both conventions.

*Proof.* $M_F(D+(x,g(x)))\ge2^{-K(g)-c}$ by (F1); divide by $M_F(D)=2^{-L_{\rm SFI}(D)}$. The normalised conditional is at least the raw one. $\square$

The bound is near 1 only if $L_{\rm SFI}(D)\approx K(g)$, i.e. if $g$-like programs carry most of the posterior.

### 5.1 Proof/disproof labels

Setting (Hänni): sentences of a consistent recursively axiomatised theory $T$, labelled 1 if proved and 0 if refuted, training only on resolved sentences.
* **Proved.** The proof-search program $p_T$ (enumerate proofs; output 1 or 0 when one is found) has length $K(T)+c$ and is consistent with every correctly labelled training set. So $L_{\rm SFI}(D)\le K(T)+c$, and by Prop 5.1 a new decidable sentence gets its correct label with probability $\ge2^{L_{\rm SFI}(D)-K(T)-c}$. Over any sequence of sentences revealed online, SFI gives the correct label probability $\le1/2$ at most $K(T)+c$ times in total.
* **Proved (an upper limit).** If every training sentence has a proof or refutation of length $\le L$ and the test sentence (say the Riemann hypothesis, if decidable) has none of length $\le L':=2^{\lceil\log_2L\rceil}$, the wrong label has probability $\ge2^{-K(T)-2\log_2\log_2L-c}$ ([context] Ex 2.15). Relative to proof search the bound is much stronger ([context] Prop 2.3). Take $p_T$ in the canonical form "fixed searcher, then a description of $T$", so that $T$ is computable from $p_T$. The property $Q:=\{x:\text{no proof or refutation of }x\text{ of length}\le L'\}$ and the constant wrong label $b$ are then described given $p_T$ at cost $K(q,r\mid p_T)\le K(L'\mid p_T)+c$. So the wrong label has probability at least $2^{-K(L'\mid p_T)-c}$ times the posterior weight of $p_T$. Since $K(L'\mid p_T)\le K(\lceil\log_2L\rceil)+c$, this is at least $2^{-c'}/(\log_2L\,(\log_2\log_2L)^2)$ times that weight. (`notes.md` used a wrapper with $\lvert p'\rvert\le\lvert p\rvert+K(L')+c$, which presumes that $p$ has a parseable form; the conditional form of [context] Prop 2.3 avoids this.)
* **Plausible, not proved.** That the correct label gets probability close to 1. This needs the posterior to concentrate on unbounded proof search rather than on its truncations. The bounds above do not decide this, and by [context] Prop 2.4(b) the answer depends on the universal machine. **[conjecture]** for natural machines and large natural training sets; no proof is known to me.

### 5.2 Shortest proofs as labels

Setting: each provable sentence labelled by its shortest proof (in a fixed enumeration order). The intended program (search proofs by length) has $K=K(T)+c$, so Prop 4.1 and Prop 5.1 apply as above: at most $K(T)+c$ online errors, and the intended output on a new provable sentence has probability $\ge2^{L_{\rm SFI}(D)-K(T)-c}$. The upper limit is [context] Ex 2.15a (from its Thm 2.5(3) with the separating property "no proof of length $\le L'$" and the violating output $\varepsilon$): if all training proofs have length $\le L$ and the test sentence's shortest proof is longer than $L'$, a wrong output has probability $\ge2^{-K(T)-2\log_2\log_2L-c}$, independently of the number of training sentences. Whether RH would get its shortest proof with high probability is, as in §5.1, plausible and machine-dependent **[conjecture]**.

### 5.3 Lengths of odd strings

Setting: training pairs $(x,\lvert x\rvert)$ for strings of odd length; test on even lengths. Hänni: "plausibly we will generalize correctly to all strings".
* **Proved.** $K(\lvert\cdot\rvert)=O(1)$, so the correct answer has probability $\ge2^{-c}$ on every even-length input, and SFI makes at most $c$ online errors over any sequence. "$\lvert x\rvert$ is even" and "output 0" are $O(1)$ bits, so a wrong answer has probability $\ge2^{-c'}$ on every even-length input, however many odd-length strings were seen ([context] Prop 2.1; Ex 2.15, last bullet). Both constants depend on the machine.
* **Computed (e5).** An exact Bayes mixture over an enumerated grammar (code `sfi_dsl.py`): programs are an arithmetic expression $E$ of depth $\le2$ over $\{\lvert x\rvert,\#_1(x),\#_0(x),0,1,2\}$ with $+,-,\times$, or `if C then E else E` with 80 simple conditions (even($\cdot$), $<$, $=$ on leaves, first/last bit). Prior $p_{\rm plain}$ on plain programs, $1-p_{\rm plain}$ on `if` programs, grammar weights below. Training: all 170 strings of length 1, 3, 5, 7. Test: all 340 strings of length 2, 4, 6, 8. Only one plain value class ("len") fits the training data.

| prior | $P(\text{correct})$ at length 2 / 4 / 6 / 8 | $P(\text{label }0)$ at length 8 | min over test strings |
|---|---|---|---|
| $p_{\rm plain}=0.5$ | 0.9824 / 0.9835 / 0.9834 / 0.9834 | $3.3\cdot10^{-3}$ | 0.9790 |
| $p_{\rm plain}=0.9$ | 0.9975 / 0.9977 / 0.9977 / 0.9977 | $4.6\cdot10^{-4}$ | 0.9971 |
| $p_{\rm plain}=0.99$ | 0.99977 / 0.99978 / 0.99978 / 0.99978 | $4.3\cdot10^{-5}$ | 0.99972 |
| tilted ×1 (one extra program "if even(len) then 0 else len" with the mass of all plain programs) | 0.557 / 0.557 / 0.557 / 0.557 | 0.435 | 0.555 |
| tilted ×10 | 0.114 / 0.114 / 0.114 / 0.114 | 0.885 | 0.113 |

Online, with $p_{\rm plain}=0.5$: after all length-2 strings are revealed, $P(\text{wrong})$ at lengths 4–8 drops to $2.7\cdot10^{-3}$; after length 4, to $1.5\cdot10^{-8}$; after length 6, to 0 within the class. A single revealed string ("00", 2) leaves $P(\text{wrong})\approx6.7\cdot10^{-3}$, because programs like "if even(len) then 2 else len" survive it.

* **Reading.** On a natural-looking grammar the intended generalisation gets probability 0.98–0.9998, depending on a single prior weight; on a tilted grammar it gets 0.11. A finite grammar is not a universal machine, so this only illustrates [context] Prop 2.4, which is the proof that the answer depends on the machine (for $W$, part (a); for $M_F$, part (b)). It also illustrates Hänni's own remark that "there's a programming language in which it doesn't have a better const". Hänni's "plausibly generalizes correctly" is a statement about the machine, not about SFI as such **[conjecture for natural machines]**. What is machine-invariant is the bounded number of errors.

### 5.4 Summary for Hänni's OOD list

Hänni wrote "plausibly" for each example. The last column therefore lists natural strengthenings of his statements that are false, not claims he made.

| Example | Proved | Plausible only | Natural strengthenings that are false |
|---|---|---|---|
| Proof/disproof labels | correct label prob. $\ge2^{L(D)-K(T)-c}$; $\le K(T)+c$ online errors; wrong label prob. $\ge2^{-K(T)-2\log_2\log_2L-c}$, and $\ge2^{-K(L'\mid p_T)-c}\cdot$(posterior weight of proof search) | correct label on RH with probability near 1 | "with the difficulty $L$ of the training sentences fixed, the wrong-label probability tends to 0 as more of them are added": it stays $\ge2^{-K(T)-2\log_2\log_2L-c}$ ([context] Ex 2.15). (This floor is tiny for a natural theory, so it does not refute "nearly certain" in a practical sense. The bound that can bite is the relative one.) |
| Shortest proofs | same form | RH labelled by its shortest proof w.h.p. | the same statement for shortest proofs ([context] Ex 2.15a) |
| Odd-length counting | correct prob. $\ge2^{-c}$, wrong prob. $\ge2^{-c'}$, $\le c$ online errors | correct w.h.p. on natural machines (0.98–0.9998 on the grammar of e5) | "correct w.h.p. on every universal machine": false by [context] Prop 2.4(a),(b); e5's tilted grammar (0.11) illustrates it |

---

## 6. Code and computations

* `code/sfi_examples.py` (reusable): log-space helpers; Eisenstat's process (`simulate_eisenstat`), frontiers (`EisenstatState`), $P^*$ (`pstar_prob_one`), the true input law (`true_input_log2prob`), the threshold-mixture SFI proxy (`threshold_mixture_loss`), the exact conditional surprisal (`bayes_xonly_surprisal`), $\kappa$ (`kappa_touching`); the cyclic-permutation proxies (`cyclic_example_losses`).
* `code/sfi_dsl.py` (reusable): the enumerated program grammar of §5.3, with exact posterior predictive.
* `checks/e1_eisenstat_exact.py`: exact checks for §3 (brute-force law, $P^*$, $\mathbb E\,UB_n$, the touching chain, simulated Lemma 3.5 frequencies).
* `checks/e2_eisenstat_sim.py`: Monte Carlo table of §3.8 and the brief's-rule statistics.
* `checks/e3_cyclic.py`: constants and proxies of §2.6; exhaustive counting checks for §2.1 and the cyclic law.
* `checks/e4_positive.py`: §4 examples.
* `checks/e5_dsl_odd_lengths.py`: §5.3.
* `checks/e6_cyclic_sharp.py` (new): §2.2–§2.6: component laws (cyclic, brooms, partial chains) against their closed forms by exhaustive enumeration; the depth-count lemma; the bounds at $n=64$; Robbins' window at 120 digits; the broom and normalised proxies; the SI encoding illustration.
* `checks/e7_eisenstat_dp.py` (new): §3.4–§3.7: exact DP over the frontier chain ($\Pr[\eta_n<\tau_n]$, $\mathbb EN_{\rm touch}(n)$, $\mathbb E\,L_{P^*}(n)$, the brief's-rule statistics), cross-checked by exact rational arithmetic, truncated exact enumeration and direct simulation; $\kappa$ to 40 digits; exact $\mathrm{Var}(UB_n)$.

The proxies are finite or explicitly parametrised Bayes mixtures. They are not SFI. They show the qualitative gaps with exact numbers: order-free mixtures pay $\Theta(n)$ per step (H5) or $\Theta(n)$ in total (H6), while history-aware and joint-sequence mixtures pay $O(1)$.

---

## 7. Open problems from this track

1. **Normalised SFI over the whole H5 cycle, and in H6.** Prop 2.9 covers the first $2^{(1-\delta)n}$ steps of H5. Over the full cycle, and for H6 at all, the lower bound for the normalised predictor is **[open]**; §2.3 and §3.9 explain why the broom method stops, and e6(e) shows that the full-cycle question is not a formality. This is part of [foundations] §8 problem 6 and of [history] Q4, which remains open there for separations with $O(1)$ bits of information per step.
2. **SI with raw blocks** (Conjecture 2.6a): is the label loss of order $K(n)$ for typical $n$, or $K(n)-\min_{L\ge n}K(L)$?
3. **Depth count for weak semimeasures** (Prop 2.4): is $\sum_{x,\lvert z\rvert=k-1}\nu(D(x,z))\le N-k$ for every weak function semimeasure? Checked only for $N=4$ (first referee's LP).
4. **OOD.** A natural-machine statement (e.g. for a fixed reference machine such as a standard prefix-free encoding of a programming language) that would make "plausibly generalises" in §5 provable for a specific training distribution. I see no route.

`notes.md` open problem 3 (the $\log_2(N-1)$ slack) is answered negatively by Thm 2.3. Its open problem 2 is answered for the paper's prefix code by Prop 2.10 and restated for raw blocks as item 2.

---

## 8. Cross-track consistency

**Sources compared** (2026-10-12): `../foundations/notes-final.md` (09:53); `../history/notes-final.md`, completed during this revision (13:54; I re-checked every history item cited here against the completed file); `../context/notes-final.md` (09:27); `../steeper/notes-final.md` (09:23). The other tracks were written against this track's `notes.md`; §8.3 lists which of their citations change content.

### 8.1 Definitions and notation

| object | here | foundations | history | context | steeper |
|---|---|---|---|---|---|
| data set, consistent sequence, $D_n$, $D+(x,y)$ | §1.1 | §1 | §1.1 | §1.1 | §8.1 |
| function machine, law $\nu_T$ | §1.1 | Def 2.5, Prop 2.6 | §1.2 | §1.1 | §1.2 |
| SFI and its loss | $M_F$, $L_{\rm SFI}(D)=-\log M_F(D)$ | $M_F$ (Def 5.1), $L_n$ | $M_F$, $L_{\rm SFI}$ | $M_F$, $L_\nu$ | mixture of $\Pi_F$, $-\log P(D)$ |
| normalised predictor | $\bar M_F$, $\bar L_{\rm SFI}$, $Z_t$, $S_t$, $\bar\ell_t$ | $\bar M_F$, $\bar L_n$, $Z_t$ (Props 5.3, 5.5) | $\bar M_F$, $S_t$, $\bar l_t$, $\bar L$ (§1.2, §2.4) | $\bar\nu$ (§1.2) | — |
| order-free predictors | weak function semimeasures | Def 2.1, Prop 2.1a | §2.3 | Prop 5.1(a) | $\Pi_w$ |
| universal discrete semimeasure | $\mathbf m$ | $\mathbf m$ | — | $m(i)$ | $\mathbf m$ |
| tape measure | $\lambda$ | $\lambda$ | $\lambda$ | $\lambda$ | $\lambda$ is the steepness exponent |
| history-aware universal | $\xi:=M_H$, $L_{\rm hist}$ | $\xi$ by trimming, $\asymp M_H$ (Prop 7.2) | $\xi:=M_H$ (§1.3, §4.1) | SFI$^{\rm hist}$ | $\Pi_{\rm chr}$, $M_H$ |
| SI on $x_1y_1x_2y_2\cdots$ | $M$, $M_{\rm norm}$ on $\bar x_1\bar y_1\cdots$, $\bar s=1^{\lvert s\rvert}0s$; raw blocks only in Prop 2.6 | Prop 7.1 (sequences) | any fixed prefix-free code (§4.4) | — | $\Pi_{\rm SI}$ |
| SI's label loss | $L^y_\rho$ | — | $L^y_M$ | — | — |

All tracks use the same objects with the same definitions. This revision adopts the foundations notation where `notes.md` differed ($\mathbf m$, $\bar M_F$, $Z_t$) and the history track's code $\bar s=1^{\lvert s\rvert}0s$ for SI, which removes the encoding inconsistency the referee found between `notes.md` Prop 2.6 and Thm 3.10. The history track's §8.1 asks the paper to fix one encoding for SI; Prop 2.10 and Thm 3.10 use the common one.

**Notation clashes the paper should resolve.**
* $\kappa$: here the expected $P^*$ loss of a touching step in H6 ($0.7995$); in foundations and history the padded length $\kappa(N)=\min_{L\ge N}K(L)$; in steeper a machine constant; in context a kernel profile and the slides' norm complexity. I suggest $\kappa_{\rm touch}$ for this track's constant in the paper.
* $\tau$: here the tail frontier $\tau_n$ in H6; in history $\tau(N):=-\log\sum_{L\ge N}2^{-K(L)}$ (its Prop 4.10).
* $\lambda$: the tape measure here and in foundations, history and context; the steepness exponent in steeper and the brief. I agree with the other tracks that the tape measure should get another symbol in the paper.
* $h$: here both the binary entropy $h(p)$ and histories $h_t$ (distinguished by the argument); history uses $h_i$ for histories only.
* $n$: here the bit length in H5 and the number of steps in H6; in history the number of steps.
* $m$: here a confidence exponent ($2^{-m}$) and the block length of the model $\mu_m$ in §2.5; in history the field degree of $GF(2^m)$; in context a sample size; in steeper a junta size; foundations uses only the bold $\mathbf m$.
* $c$: an additive machine constant here, in foundations, history and context; $c=\lambda/N$ in steeper.

### 8.2 Results used from other tracks, checked against their current notes

* **Foundations.** Def 2.1 and its consequences (a), (b) (Lemma 1.1, Props 2.4, 3.7); Prop 2.1a (order-free predictors); Def 2.5, Prop 2.6 (function machines; $M_F$ is a containment functional, used in Thm 2.3(2) and Prop 2.9(i)); Thm 3.2, Prop 3.3 ((F1)); Def 5.1, Props 5.2, 5.3, 5.5(a) (conventions; the identity behind Prop 2.9); Thm 6.1(a),(b), Cor 6.6 (§4); Thm 6.3(a) (Lemma 1.1); Thm 6.7(b), Prop 6.8, Prop 6.9 (Remark 4.7); Prop 7.2 ((F7)). All say what is used here.
* **History.** Lemma 1.1, Lemma 2.0 (Lemma 2.2 here, with a fixed end point), Thm 2.1(a) (the deterministic broom), Prop 2.3(a),(c) (Prop 2.4(2) and Remark 2.13), Prop 2.4 and Lemma 2.4a (Remark 2.13, Prop 2.9(ii)), §1.3 and §4.1 ($\xi:=M_H$), Cor 4.3(b) ((F7)), Prop 4.4(a),(c) ((F7), Prop 2.11), Prop 4.5(iii) (Prop 2.11), §4.4 with Lemma B ((F10)), Thm 4.6 and the (LHG-even) consequence (Lemma 1.3, Remark 2.12), Q3, Q4. Checked against the completed final notes.
* **Context.** §1.2 (both conventions for the OOD lower bounds), §1.3 (upper bounds via $K_F$ are upper estimates), Props 2.1, 2.3, 2.4(a),(b), Thm 2.5, Thm 2.7, Ex 2.15, 2.15a (§5).
* **Steeper.** §8.3: Prop 4.6's machine $T_g$ is a mixture of product laws, and the bound holds in the product class up to $O(\log n)$; the threshold law of §3.2 is a computable sampler covered by its Theorem 3. Used as stated.

### 8.3 Items of this track cited elsewhere

Numbers are kept from `notes.md`. Content changes that affect other tracks:
* **Thm 2.3 and Prop 2.4(1)** are now sharp ($\log_2(N-1)_{k-1}\pm O(K(k))$), and Prop 2.4 now covers every weak function semimeasure with the weaker bound. History §2.3 cites Prop 2.4 for "the cost is intrinsic to order-free prediction"; that statement is now proved here for weak semimeasures too.
* **Prop 2.6** is now the raw-block statement only. History Prop 4.8 cites it for SI's comparison loss ($K(n)+m+c$). With the paper's prefix code SI pays $O(1)$ uniformly in $n$ (Prop 2.10); the history track's comparison sentence should cite Prop 2.10.
* **Convention status of H5 and H6.** Foundations Remark 5.6, the context track's §8.1 and the history track's §8.4 list the H5 and H6 lower bounds as semimeasure-only. After Prop 2.9, the H5 lower bound also holds for the normalised predictor for $t\le2^{(1-\delta)n}$, at $\log_2(N-t+1)-K(t-1)-c$ bits per step; the full cycle and H6 remain semimeasure-only. This partly answers foundations §8 problem 6.
* **(F7)** no longer calls dominance "the defining property" of Hutter's $\xi$ (referee m14).
* **Prop 3.7(2)**: the sentence on the conditional law is corrected (it depends on $H$ and the label at $\max S$); the formula is unchanged.
* **Prop 3.4**: the CLT is now proved; $\mathrm{Var}(UB_n)=\sigma^2n$ exactly. **Prop 3.12** (new) gives the exact rule statistics.
* **§5.1**: the relative bound now uses the conditional complexity $K(L'\mid p_T)$, as the context track's §8.2 anticipated; the stated bound still holds.
* **Example 4.5**: the bound is sharpened; the context track's §8.2 comparison with its Cor 4.7 concerns Example 4.2, which is unchanged.

### 8.4 One home for duplicated results

* *SFI$^{\rm hist}$ on H5*: Prop 2.5 here and history Prop 4.8 have the same statement and proof. I suggest the paper state it once, in the H5 example, citing the history track's Cor 4.3(b).
* *Order-free lower bounds*: history Prop 2.3(a) is the general lemma for weak semimeasures; Prop 2.4 here is its H5 instance, with the depth-count sharpening (Lemma 2.2a) for random-function laws.
* *The broom*: history Thm 2.1(a) (deterministic, for the chain) and Thm 2.3 here (randomised over the spine, for H5); history Prop 2.4 uses a total broom for the normaliser, as Prop 2.9 does.
* *Normalised predictor*: Prop 2.9 (H5) here; history Prop 2.4 (chain, skipped strings). One method; the paper can present it once with both instances.
* *SFI$^{\rm set}$*: history Prop 4.5(iii) and 4.5′(iii) give the strict separation from SFI$^{\rm hist}$ on chosen orders; Prop 2.11 here shows that on H5 itself SFI$^{\rm set}$ pays the full SFI cost.

### 8.5 Disagreements

* **None with other tracks.** No result of another track contradicts a result here.
* **With the second referee, one sign.** Its report (§4, H6) writes $UB_n-\tau_nh(1/3)=-\tfrac23(G_{T_n}-T_n/2)$; the correct sign is $+$ (first referee and §3.6 here; check $T_n=1$, $G_{T_n}=0$). This does not affect any statement, which uses only the $\Theta(\sqrt n)$ size.

---

## Verification log

All scripts were run with `python3` (numpy 2.4.6, scipy 1.17.1, mpmath 1.3.0) from `research/tracks/examples/checks/`. Outputs are saved next to the scripts as `*.out.txt`.

| Script | Seed | What it checks | Result | Runtime |
|---|---|---|---|---|
| `e1_eisenstat_exact.py` | 20261011 (simulation parts) | (a) $\Pr[D_n=D]$ vs exhaustive enumeration, $n=3,4,5$; (b) $Z(S)$; (c) $P^*$ vs brute-force conditional on all (history, input) pairs, $t\le n\le5$; (d) $\mathbb E\,UB_n=nh/2$; (e) return probability $2/3$, $\mathbb EN_{\rm touch}=3$, $\kappa$, simulation; (f) simulated $\Pr[\eta_n<\tau_n]$ | (a) 252, 756, 2016 data sets, max error 0 (exact rationals); (b) 84, 210, 462 domains, error 0; (c) 475, 2414, 11289 pairs, error 0; (d) diff $\le2.5\cdot10^{-11}$; (e) $r=0.666666666667$, $\varphi_{\rm sim}=0.5008$, $\kappa=0.7995167363$; (f) frequencies $0.068,0.014,0.001,0,0$ (superseded by e7's exact values) | 40 s |
| `e2_eisenstat_sim.py` | 20261011; 7 and 11 for the single run; 20261012 for the rule | Table of §3.8; order independence of the proxy; errors of the brief's rule | as tabulated; shuffled order gives identical loss (9309.577698); rule: 1.98 errors, 48.8% error-free | 47–78 s |
| `e3_cyclic.py` | 20261011 | Constants of Thm 2.1(4); $k$-step quantities; proxies; bijection orderings ↔ cyclic permutations and $\Pr[\pi\supseteq D_k]=1/(N-1)_k$ for $n=2,3$ | counting checks pass for all $k$. Its "Stirling error" column is double-precision noise for $n\ge17$ and its printed remark is false; superseded by e6(d) | 1 s |
| `e4_positive.py` | 20261011 | Parity, threshold and frozen-noise tables of §4 | order-independence differences 0; mixture loss $\le$ Prop 4.6 bound in all 800 runs (max excess $1.3\cdot10^{-11}$, rounding) | 8 s |
| `e5_dsl_odd_lengths.py` | none (deterministic) | §5.3 table | 1345 expression classes, 80 conditions; one plain class consistent | 14 s |
| `e6_cyclic_sharp.py` (new) | 20261012 | (a) cyclic law, brooms $B_j$, partial chains $P_j$ and their normalisers vs closed forms, $n=2$ (all 6 orderings) and $n=3$ (4 orderings), exact rationals; (b) depth-count lemma: all 625 partial functions ($n=2$), all $8^8$ total functions ($n=3$), $10^5$ random partial functions ($n=3,4$), attainment by brooms ($n=2,3,4$); (c) old and new $k$-step bounds at $n=64$; (d) Robbins window at 120 digits, $n\le24$ and $32,40,64$; (e) order-free proxy with brooms (cyclic vs broom route); normalised proxy and Prop 2.9's per-step inequality; (f) SI label loss, prefix code vs raw blocks, $n=2..6$ | (a) 1092 comparisons, 0 mismatches; (b) 0 violations, maxima exactly $N-k$ in the exhaustive cases, brooms attain $N-k$; (c) new upper bound 52.8 bits below the old at $k=64$, gap 11.2 bits against 64; (d) window holds for every $n$ tested; (e) excess over $\log_2(N-1)_{k-1}$ follows the cheaper route (broom wins at $k=N/2$ from $n=8$); min margin in Prop 2.9's inequality 2.77 bits over all steps and weightings; full-cycle normalised loss down to 19.2 vs $\log_2((N-1)!)=40.25$ ($n=4$); (f) prefix code 0.13–0.26 bits, raw blocks 1.3–7.8 bits | 42 s |
| `e7_eisenstat_dp.py` (new) | 20261012 | (a) exact DP ($U\le1500$) for $\Pr[\eta_n<\tau_n]$, $\mathbb EN_{\rm touch}(n)$, $\mathbb E\,L_{P^*}(n)$, rule errors, $\Pr[\text{no rule error}]$, $n\le1000$; exact rational DP $n\le12$; (b) $\kappa$ to 40 digits, $\varphi$, return probability, per-cycle rule errors; (c1) truncated exact enumeration $n\le5$; (c2) direct simulation $n=10,20,40$; (d) exact $\mathbb E\,UB_n$, $\mathrm{Var}(UB_n)$ for $n\le200$ | (a) $6.48\cdot10^{-2},1.55\cdot10^{-2},1.11\cdot10^{-3},7.31\cdot10^{-6},4.27\cdot10^{-10}$ at $n=10,20,40,80,160$; limits $3$, $3\kappa=2.398550209$, $2$, $1/2$; retained mass $\ge1-7\cdot10^{-10}$ at $n=1000$; float vs exact $6\cdot10^{-17}$; (b) $\kappa=0.7995167363495948723861\ldots$, $\varphi=0.5$, return $2/3$, B-steps per cycle $1/3$; (c1) DP values inside the enumeration brackets; (c2) agreement within about 2 standard errors; (d) $\mathrm{Var}/n=1.049660151594=\sigma^2$ for every $n$ | 18 s |

**Re-runs.** `e1`–`e5` were re-run on scratch copies (with `code/` copied alongside) during this revision. All five outputs are byte-identical to the saved ones, except e2's runtime line (47.0 s against 77.6 s). `e6` was re-run after each edit; apart from the edited lines and the runtime lines, its output did not change. `e7` was re-run unchanged, and its output was byte-identical except the runtime line. The referees' scripts (`referee_code/r1`–`r3`, `s1`–`s3`) were read and their saved outputs compared with mine; I did not re-run them. My `e6` and `e7` do not import the referees' code or the track's `code/` module.

**Agreement with the referees' independent code.** Broom law and depth count: `r2(a),(b)`, `s1(a),(b)`. Robbins window: `r2(e)`, `s1(e)`. Normalised proxy: `s1(c)` (a different proxy; same qualitative finding). SI encodings: `s3`. Exact DP for H6: `r1(B)`, `s2(a),(b)` (same values for $\Pr[\eta_n<\tau_n]$, $\kappa$, the limits 3, 2, 1/2). Prop 3.7(2) counterexample: `r1`, `s2(d)`.

**What was not checked.**
* References marked (unverified) were not checked against their sources: Li–Vitányi section numbers, Levin–Schnorr, Ville, Zvonkin–Levin, Hutter 2005, the coding theorem papers, Wald's identity reference. Sattolo, Robbins and Hoeffding were checked by WebSearch snippets (by me or by the referees), not against the full texts. The Lattimore–Hutter–Gavane hypothesis (LHG-even) used in Remark 2.12 is the history track's, conditional and unverified.
* Results imported from the foundations, history and context tracks were read in their current notes (§8) but not re-proved here, except where a proof is given here (Prop 2.4(2) re-proves history Prop 2.3(a) for the H5 chain; Remark 2.13 re-derives one case of history Prop 2.4).
* Statements involving $K$, $M$, $M_F$, $\xi$ are proved by hand; the scripts check only the finite combinatorial or analytic steps and proxies, as listed.

**Corrections made during the work.**
* `notes.md` → this file: Thm 2.3 replaced by its sharp form; the Stirling remark removed; the Prop 3.7 sentence corrected; Example 4.5 sharpened; Prop 3.4(4) upgraded from proof sketch to proof; Remark 2.6b re-proved; (F7) reworded.
* e6, first run: a printed remark said the new $k=64$ upper bound lies "about 55 bits" below the old one; the table gives 52.8, and the remark was fixed.
* e6(e), first version: the order-free proxy gave every broom the weight $\tfrac12/(j(j+1))$, and I first described its loss at $k=N/2$ as the broom's prior cost. That was wrong: with those weights the broom costs about $2\log_2k>\log_2(N-k)$ and the cyclic law dominates. The proxy now also gives extra weight to simple $k$ (powers of two), as $K(k)$ does, and the output reports both routes. All other parts of the output were unchanged by the re-run.
* e7, first run: the DP was run to $n=1500$ with the walk truncated at $U\le1500$; since the $A$-walk drifts up by one level per step, mass was lost by $n=1500$ (retained 0.50). The checkpoints now stop at $n=1000$, where the retained mass is $1-7\cdot10^{-10}$.
* During writing, the history track completed its final notes. Its Prop 2.4 proves the normalised bound for its chain and skipped strings; my Corollary 2.13 (the chain, in expectation) duplicated part of it and was replaced by Remark 2.13, which cites it. The history citations here were updated to its final numbering.
* Earlier (`notes.md`): the first version of `bayes_xonly_surprisal` underflowed for $M-n\gtrsim1800$ and now uses $\log_2(1+2^{-(M-n)})$; the first draft of Lemma 3.5 had the constant 19, and the correct sum $1+1/(1-e^{-1/18})=19.5$ gives 20.
