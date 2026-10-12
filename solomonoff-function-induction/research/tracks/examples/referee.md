# Referee report (run 2): track "examples"

*Adversarial referee for `notes.md`, its scripts `checks/e1`–`e5`, and `code/sfi_examples.py`, `code/sfi_dsl.py`. The track covers brief items H5 and H6, the positive examples and Hänni's OOD examples. I did not edit the notes or the track's code.*

*The first referee run's report is kept as `referee-run1.md`, and its scripts are `referee_code/r1`–`r3`. The notes have not changed since that run. I re-derived every proof myself and wrote new scripts, `referee_code/s1`–`s3`. Where I agree with run 1 I say so; where I go further or disagree, I say that too. Each script is seeded and writes `<name>_output.txt` next to itself.*

---

## 0. Verdict

**No fatal issues.**
* I checked every proof marked [proved] line by line.
* Each is correct as stated, with two exceptions, both cosmetic:
  * a false sentence about Prop 3.7(2), which is repeated in the summary table (m2);
  * a parenthetical in §2.4 whose stated justification does not apply, although its conclusion is true (m4).
* Every [computed] number reproduces. The five check scripts, re-run on scratch copies, give byte-identical outputs; e2 differs only in its runtime line.
* My independent code confirms the exact law of Eisenstat's process and the touching chain. It also confirms $\kappa$, the limits $3$ and $3\kappa$, the brief's-rule statistics (exact limits 2 and 1/2), and the constants of H5.
* One printed remark is false: the remark on the Stirling error (m3).

**Three major issues.** All three are about what the paper should state. None says a proved claim is false.
* **M1. H5 $k$-step bounds are not sharp.**
  * The upper bound in Thm 2.3(1) is loose by about $n-K(k)$ bits.
  * A "broom" hypothesis, which is the upper-bound program of [history] Thm 2.1(a), together with a depth-counting lemma gives $L_{\rm SFI}(D_k)=\log_2(N-1)_{k-1}\pm O(K(k))$ w.h.p. for all $1\le k\le N-1$.
  * This answers open problem 3 negatively. I confirm run 1's M1, and I correct one of its emphases (§2).
* **M2. The verdicts on Hänni's claims concern only $-\log M_F$.**
  * I add a new result. In H5 the per-step **normalised** SFI predictor pays at least $\log_2(N-t+1)-K(t-1)-c$ bits at step $t$ in expectation.
  * So Hänni's "high loss under SFI" holds for the normalised predictor too, at about $n-\log t$ bits per step for the first $2^{(1-\delta)n}$ steps.
  * The full cycle and H6 remain open, and I explain why the argument stops there.
* **M3. SI's $K(n)$ in H5 is an artefact of the encoding.**
  * With the prefix-free code that the history track uses ($\bar s=1^{|s|}0s$), SI's expected label loss on the cyclic example is $O(1)$ **uniformly in $n$**, and also w.h.p. (proof in §2).
  * The track's Prop 2.6 uses raw $n$-bit blocks. Thm 3.10 (H6) uses a prefix-free code. So the notes are internally inconsistent here.
  * The remark after Prop 2.5 ("constant independent of $n$, unlike SI") is therefore misleading.
  * Open problem 2 should be restated as a question about the delimiter-free encoding only.

**Fourteen minor issues** (§3).

---

## 1. What I did

* Re-ran `checks/e1`–`e5` on copies in the scratchpad, with `code/` copied alongside. All five outputs are identical to the saved ones; e2 differs only in its runtime line (52.3 s against 77.6 s).
* Read `code/sfi_examples.py` and `code/sfi_dsl.py` in full. No errors found (§4, last item).
* Checked every cross-reference against the current notes of the other tracks:
  * `foundations/notes.md`;
  * `history/notes.md` and the partial `history/notes-final.md`;
  * `context/notes.md` and `context/notes-final.md`.
* Checked references by WebSearch where possible (§5).
* Wrote three new scripts:

| script | target | main results |
|---|---|---|
| `s1_cyclic_sharp_normalised.py` | H5: Thm 2.1, 2.3, Prop 2.4; M1, M2; Stirling | (a) Exhaustive hypothesis-side counts for $n=2,3$: cyclic law $1/(N-1)_k$, broom $1/(N-1)_{k-1}$, partial-chain formulas; all exact. (b) Depth-count lemma $\lvert A_k(F)\rvert\le N-k$ on 26 000 random partial functions ($n=3,4$), never violated; the broom attains it. (c) An order-free proxy mixture with total and partial components: semimeasure and normalised losses for $n=4,\dots,12$. The referee per-step lower bound of M2 holds at every step. With 96% of the prior on partial chains, the normalised loss over the full cycle falls **below** $\log_2((N-1)!)$ (28.4 against 40.25 bits at $n=4$). (d) Track bounds against sharpened bounds at $n=64$. (e) Robbins window at 120 digits for $n\le24$ and $n=32,40,64$: holds. The e3 remark is false (m3). |
| `s2_eisenstat_dp.py` | H6: Lemma 3.5, Prop 3.4, 3.7, 3.9, Cor 3.11, Thm 3.6 steps | (a) Exact forward DP over the frontier chain, truncated at $U\le1500$ with retained mass $1-O(10^{-12})$. $\mathbb E N_{\rm touch}(n)\to3$; $\mathbb E L_{P^*}(n)\to3\kappa=2.398550209$; rule errors $\to2$; $\Pr[\text{no error}]\to1/2$. Exact $\Pr[\eta_n<\tau_n]$ is $6.48\cdot10^{-2}$, $1.55\cdot10^{-2}$, $1.11\cdot10^{-3}$, $7.31\cdot10^{-6}$, $4.27\cdot10^{-10}$ at $n=10,20,40,80,160$. (b) $\kappa=0.799516736349594872386\ldots$ (50 digits). $\varphi=1/2$ by value iteration from 0. Return probability $2/3$. Rule errors per touching step $2/3$. (c) Fresh simulator: $\mathbb E UB_n/n=0.45903\pm0.00071$ ($n=10^3$) and $0.45913\pm0.00061$ ($n=10^4$). $\mathbb E[g_n-\tau_n]=0.50$–$0.53$ (bound $\le1/2$; within $1.1\sigma$). Plug-in $H(g_n)$ is below the max-entropy bound. $\mathbb E[-\log\Pr(D_n\mid S_n)]/n=0.45918\pm0.0006$ at $n=10^4$. (d) Prop 3.7(2): $\sum_D\Pr[D\mid S]=1$ exactly on all 3301 reachable domains with $\lvert S\rvert\le7$ inside $[0,12)$. Exact counterexample to the "only through the number of heads" sentence. |
| `s3_si_encoding.py` | H5: Prop 2.6, M3 | An exact bitwise Bayes mixture of the true processes $\mu_m$, $m\le12$, plus a null model. Label loss over the full cycle: 0.9–8.7 bits with raw blocks; 0.02–0.09 bits with the prefix code, for every $n=2,\dots,8$. |

---

## 2. Major issues

### M1. The $k$-step bounds for the cyclic example are not sharp; open problem 3 has a negative answer

**Claims.**
* Thm 2.3(1): $L(D_k)\le\log_2(N-1)_k-\max\{0,\log_2(N-k)-k\}+c$.
* Thm 2.3(2): $L(D_k)\ge\log_2(N-1)_k-\log_2(N-1)-m-c$ w.p. $\ge1-2^{-m}$.
* Prop 2.4(1).
* The "Reading" after Thm 2.3: "SFI pays $\log_2(N-1)_k\pm O(n)$ bits … the $\log_2(N-1)$ slack in part 2 cannot be removed for small $k$".
* Open problem 3 (§7): is $L(D_k)=\log_2(N-1)_k+O(1)$ w.h.p. once $k\ge n$?

**Problem.**
* For $k\le N/2$ the two lower bounds differ by at most one bit: $\log_2(N-1)_{k-1}-[\log_2(N-1)_k-\log_2(N-1)]=\log_2\frac{N-1}{N-k}$. So the lower bound is essentially right for $k\le N/2$.
* The **upper** bound is the loose side. For $\log_2N\lesssim k\le N/2$ it equals $\log_2(N-1)_k+c$. That is about $n$ bits above the truth whenever $K(k)\ll n$.
* The "Reading" thus has the wrong cause. The $\approx n$-bit slack is real for *every* $k\le2^{(1-\delta)n}$, not only for small $k$. It lives in the upper bound.
* (Run 1's M1 presented the improvement as acting on both sides. It acts on the lower bound only near the end of the cycle, by $\log_2\frac{N-1}{N-k}$.)

**Correct statement** [proved below; computed: s1(a),(b),(d)]. For $1\le k\le N-1$, with $(N-1)_0:=1$:
1. For every chain $D_k$: $L(D_k)\le\log_2(N-1)_{k-1}+\min\{K(k),\ \log_2(N-k),\ k\}+c$.
2. For every law $\nu$ of a random partial function: $\mathbb E_f[-\log_2\nu(D_k)]\ge\log_2(N-1)_{k-1}$.
3. For every $m\ge0$: $\Pr[L(D_k)<\log_2(N-1)_{k-1}-m-c]<2^{-m}$.

So $L(D_k)=\log_2(N-1)_{k-1}\pm O(K(k))$ w.h.p. SFI pays for the $k-1$ nonzero labels as an injective sequence. The identity of the head $x_k$ is free.

*Proof of 1.*
* Let $B_k$ be the following function machine. For each length $\ell$, it reads its own sub-stream of the tape and draws, by rejection sampling, a uniform injective sequence $(v_1,\dots,v_{k-1})$ of nonzero $\ell$-bit strings. If $k-1>2^\ell-1$, it answers $0^\ell$ everywhere on that length.
* On input $x$ of length $\ell$ it outputs:
  * $0^\ell$ if $x=v_1$;
  * $v_{i-1}$ if $x=v_i$, $2\le i\le k-1$;
  * $v_{k-1}$ otherwise ($0^\ell$ for every $x$ when $k=1$).
* The value at $x$ is fixed by finitely many tape bits almost surely, and $K(\nu_{B_k})\le K(k)+c$.
* On the event $(v_1,\dots,v_{k-1})=(x_1,\dots,x_{k-1})$, which has probability $1/(N-1)_{k-1}$, the hypothesis extends $D_k$. The reason: $x_k$ is not a $v_i$, so it is sent to $v_{k-1}=x_{k-1}$.
* (F1) gives the $K(k)$ term. The other two terms are Thm 2.3(1), rewritten.
* This "broom" is exactly the upper-bound program of [history] Thm 2.1(a) ("otherwise output $x_{n-1}$"), randomised over its spine. $\square$

*Depth-count lemma.* For a partial function $F$ on strings, let $A_k(F)$ be the set of nonzero $x\in\{0,1\}^n$ whose orbit $F(x),\dots,F^{k-1}(x)$ consists of nonzero $n$-bit strings and has $F^k(x)=0^n$. Then $\lvert A_k(F)\rvert\le N-k$.
* *Proof.* If $x\in A_k$, the strings $F(x),\dots,F^{k-1}(x)$ have first hitting times of $0^n$ equal to $k-1,\dots,1$. So they are distinct, nonzero, and not in $A_k$. $\square$

*Proof of 2 and 3.*
* Fix $\omega$. Each $x\in A_k(f_\omega)$ has exactly one $z\in(\{0,1\}^n\setminus0^n)^{k-1}$ with $f_\omega\supseteq D(x,z)$ (its orbit), and every other $x$ has none. Hence $\sum_{x,z}\nu(D(x,z))=\mathbb E_\omega\lvert A_k(f_\omega)\rvert\le N-k$.
* (2) The tuple $(x_k,x_{k-1},\dots,x_1)$ is uniform over the $(N-1)_k$ injective sequences. Apply Gibbs with $q=\nu/(N-k)$.
* (3) $q(x,z\mid n,k):=M_F(D(x,z))/(N-k)$ is lower semicomputable uniformly in $(n,k)$ and sums to $\le1$. So (F3) gives $K(x,z\mid n,k)\le L(D(x,z))+\log_2(N-k)+c$. Apply Lemma 1.2 with $w=(n,k)$. $\square$

**Answer to open problem 3: no.**
* For $k\le N/2$, part 1 gives $L(D_k)\le\log_2(N-1)_k-(n-1)+K(k)+c$.
* For example, at $n=64$ and $k=64$ this lies at least about 53 bits below $\log_2(N-1)_k$, up to $c$ (s1(d)).
* The deficit grows like $n-K(k)$.

**Evidence.**
* s1(a): the broom gives exactly $1/(N-1)_{k-1}$ for every $k$ and three random orderings ($n=2,3$, exhaustive over spines). The cyclic law gives $1/(N-1)_k$.
* s1(b): the depth-count maximum is exactly $N-k$.
* s1(d): the gap between the bounds is 64 bits for the track and 11.2 bits for the referee ($n=64$, $k=64$); 64 and 16.6 at $k=1000$.

**Fix.**
* Replace Thm 2.3(1),(2) and Prop 2.4(1) by parts 1–3.
* Rewrite the "Reading": the slack is in the upper bound and is real for all $k\le2^{(1-\delta)n}$.
* Close open problem 3.
* Cite [history] Thm 2.1(a) for the broom.

### M2. The verdicts hold only in the semimeasure convention; for H5 the normalised version can be proved for most of the cycle

**Claims.**
* Summary row 2.1: "Hänni's claim 'high loss under SFI' holds".
* Rows 2.3 and 3.6: "SFI pays about $n$ bits per step"; "The brief's $\approx0.459n$ is **verified**".
* §2.2 after Prop 2.4: "the gap between SFI and SI here is not a weakness of the universal prior".
* Open problem 1.

**Problem.**
* Every lower bound in §2 and §3 is for $L=-\log M_F(D)$, the cumulative loss of the raw (unnormalised) conditionals. The top caveat says this, but the verdicts do not.
* A reader of the summary will take them as statements about the predictor.
* No information-theoretic argument settles the normalised case. The normalised predictor is a set-based history-aware predictor, and such predictors achieve $O(1)$ in both examples.
* The gap between the conventions can be large. In my proxy with heavy weight on partial chains (s1(c)), the normalised loss over the full cycle is **28.4 bits at $n=4$, below the order-free lower bound $\log_2((N-1)!)=40.25$**. At $n=12$ it is 43 049.8 against 43 238.0.
* So the order-free lower bounds do not transfer to the normalised predictor without an argument.

**New result** [proved here; computed for a proxy: s1(c)].

*Proposition R2.* Let $\bar P(y\mid D,x):=M_F(D+(x,y))/\sum_{y'}M_F(D+(x,y'))$ and $\bar\ell_t:=-\log_2\bar P(y_t\mid D_{t-1},x_t)$ in the cyclic example. For uniform cyclic $f$ and $2\le t\le N-1$:
$$\mathbb E\,\bar\ell_t\ \ge\ \log_2(N-t+1)-K(t-1)-c,$$
and $\bar\ell_t\ge\log_2(N-t+1)-K(t-1)-m-c$ with probability $\ge1-2^{-m}$. Consequently, for $k\le N/2$,
$$\mathbb E\sum_{t\le k}\bar\ell_t\ \ge\ \sum_{t=2}^{k}\big(\log_2(N-t+1)-K(t-1)-c\big)^+\ \ge\ (k-1)\big(n-1-\log_2k-2\log_2\log_2(k+1)-c\big).$$
So for $k\le2^{(1-\delta)n}$ the normalised SFI predictor pays at least $(k-1)(\delta n-O(\log n))$ bits.

*Proof.*
* Write $\bar\ell_t=-\log_2M_F(D_t)+\log_2S_t$ with $S_t:=\sum_yM_F(D_{t-1}+(x_t,y))$.
* (i) M1 part 2 with $\nu=M_F$ gives $\mathbb E[-\log_2M_F(D_t)]\ge\log_2(N-1)_{t-1}$. This is valid because $M_F$ is a machine law, hence the containment functional of a random partial function ([foundations] Prop 2.6, Thm 3.2).
* (ii) $x_t\ne0^n$ for $t\le N-1$. The broom $B_{t-1}$ is defined at every nonzero input, so $\sum_y\nu_{B_{t-1}}(D_{t-1}+(x_t,y))=\nu_{B_{t-1}}(D_{t-1})\ge1/(N-1)_{t-2}$ (M1 part 1).
* By [foundations] Thm 3.2, $S_t\ge2^{-K(t-1)-c}/(N-1)_{t-2}$ on every path.
* (iii) Subtract: $\log_2(N-1)_{t-1}-\log_2(N-1)_{t-2}=\log_2(N-t+1)$.
* The high-probability version uses M1 part 3 in place of (i).
* The cumulative bound uses $\bar\ell_t\ge0$, $K(j)\le\log_2j+2\log_2\log_2(j+1)+c$ and $N-t+1\ge N/2$. $\square$

*Why the argument stops there.*
* Per step it pays the overhead $K(t-1)$ to name a total hypothesis that dominates the normaliser, against $\log_2(N-t+1)$ bits of information.
* Near the end of the cycle ($t\gtrsim N/\mathrm{poly}(n)$) the overhead wins, so the full-cycle normalised loss remains **[open]**.
* In H6 the per-step information is only $0.46$ bits, while the analogous overhead is $K(\tau_{t-1})+K(g_t)=O(\log t)$. So the same argument gives nothing, and H6 remains **[open]**.
* This also explains why H5 is the tractable one.

**Fix.**
* Attach "in the semimeasure convention ($-\log M_F$, the Bayesian marginal likelihood)" to every verdict in §0, §2 and §3.6.
* Add Prop R2 to §2. State that Hänni's H5 claim holds for the normalised predictor at about $n-\log_2t$ bits per step for $t\le2^{(1-\delta)n}$.
* Keep open problem 1 for the full cycle and for H6, with the s1(c) proxy as evidence that it is a real question.
* (The history track's Q4 is the same question for its examples. Prop R2's method also applies to its chain, Thm 2.1, when the blocks are independent and uniform. A broom over the first $t-2$ blocks dominates the normaliser at cost $K(t-1)$, and [history] `notes-final.md` Prop 2.3(c) gives $\mathbb E[-\log M_F(D_t)]\ge L_{t-1}$. So the normalised predictor pays at least $\ell_{t-1}-K(t-1)-c$ bits at step $t$ in expectation, which is positive for $\ell_i=i$.)

### M3. SI's $K(n)$ in the cyclic example is an artefact of the delimiter-free encoding

**Claims.**
* Prop 2.6: $\mathbb E L^y_M(k)\le K(n)+c$, with "blocks of $n$ bits, no delimiters; SI is not told $n$".
* The remark after Prop 2.5: "with a constant independent of $n$ (unlike SI, Prop 2.6)".
* Open problem 2: is SI's label loss $O(1)$, $O(\log n)$ or $\Theta(K(n))$?

**Problem.**
* The track's H6 analysis (Thm 3.10(2)) uses a prefix-free code. The history track's common convention codes every string as $\bar s=1^{|s|}0s$ ([history] §1.1, Lemma B, Thm 4.6).
* Under that convention SI's label loss in H5 is $O(1)$ uniformly in $n$. The $K(n)$ appears only because the raw encoding never tells SI where the first block ends.
* So the contrast drawn after Prop 2.5 between SFI$^{\rm hist}$ and SI comes from the encoding, not from the predictors.

**New result** [proved here; illustrated by s3].

*Proposition R3.* Encode the history as $\bar x_1\bar y_1\bar x_2\bar y_2\cdots$ with $\bar s=1^{|s|}0s$. There is a constant $c$, independent of $n$, such that for uniform cyclic $f$, every $k\le N$ and every $m\ge0$:
* $\mathbb E\,L^y_M(k)\le c$;
* $\Pr[\exists k\le N:\ L^y_M(k)>m+c]\le2^{-m}$.

*Proof.*
* Let $\mu_n$ be the law of the pair sequence (Prop 2.6) and $\mathrm m(n)$ the universal discrete semimeasure ($\mathrm m(n)\ge2^{-K(n)}$). Then $\mu:=\sum_n\mathrm m(n)\mu_n$ is a lower-semicomputable semimeasure on block sequences.
* By [history] Lemma B, $M(\mathrm c(h))\ge2^{-c}\mu(h)\ge2^{-c}\mathrm m(n)\mu_n(h)$ for every history $h$.
* Telescoping as in Lemma 1.3, with $Q_t:=M(\mathrm c(h_{t-1})\bar x_t)/M(\mathrm c(h_{t-1}))$ and $\mu_n$'s label conditionals equal to 1:
$$L^y_M(k)=-\log M(\mathrm c(h_k))+\log M(\varepsilon)+\sum_{t\le k}\log Q_t\ \le\ c-\log\mathrm m(n)+\log M(\varepsilon)+\log W_k,$$
where $W_k:=\prod_{t\le k}Q_t/\mu_n(x_t\mid h_{t-1})$.
* Under $\mu_n$, $(W_k)_{k\ge1}$ is a nonnegative supermartingale (prefix-freeness, as in Lemma 1.3).
* The first step is where the improvement comes from:
$$\mathbb E W_1=\sum_{x}M(1^n0x)/M(\varepsilon)\le M(1^n0)/M(\varepsilon).$$
* The strings $1^n0$ form a prefix-free family and $n\mapsto M(1^n0)$ is lower semicomputable. So (F3) gives $\log M(1^n0)\le-K(n)+c$.
* Hence $\mathbb E L^y_M(k)\le c-\log\mathrm m(n)+\log M(1^n0)\le c+K(n)-K(n)+c'$.
* Ville's inequality applied to $W$ gives the second statement. $\square$

In words: SI pays about $K(n)$ bits on the **input** header $1^n0$. That header tells it $n$ before the first label, so the labels are free.

**Evidence (s3).** The exact bitwise Bayes mixture over $\mu_m$, $m\le12$, with a null model, gives these label losses over the full cycle:
* raw blocks: 0.94–8.71 bits;
* prefix code: 0.021–0.093 bits, the residual weight of the null model.

This holds for every $n=2,\dots,8$ and every permutation tried.

**Fix.**
* Use the paper's common prefix-free code in Prop 2.6 (as in Thm 3.10), and state Prop R3.
* Keep the raw-block statement only as a remark: SI not told $n$ pays at most $K(n)+c$. Restate open problem 2 for that encoding. The natural conjecture is a lower bound of order $K(n)$ for typical $n$, because the first label requires guessing where an undelimited random block ends.
* Delete "unlike SI" after Prop 2.5.

---

## 3. Minor issues

**m1. Thm 2.1(1): the $K(n)$ term is unnecessary** (confirms run 1, m1).
* *Claim:* $K(f\mid n)-c\le L(f)\le K(f\mid n)+K(n)+c$.
* *Problem:* hypotheses see $x$, hence $n=|x|$.
* *Proof:* let the function machine read a program $p$ from the tape lazily as the conditional prefix machine $V(\cdot,|x|)$ requests bits, compute the table $V(p,|x|)$, and output its entry at $x$. With probability $\ge2^{-K(f\mid n)}$ the program read is a shortest one for $f$ given $n$. The machine is fixed. So $L(f)=K(f\mid n)\pm c$.
* *General form:* $L(D)=K(D\mid\mathrm{dom}\,D)\pm c$ whenever $\mathrm{dom}\,D$ is computable from each of its elements by one fixed map.
* *Fix:* state the two-sided equality.

**m2. Prop 3.7(2): a sentence and a summary entry are false** (confirms run 1, m3).
* *Claims:* "Part 2 says the conditional law of the labels given the domain depends on the labelling only through the number of heads". Summary row 3.7: "the labels given the domain have law $\propto\binom nH$".
* *Problem:* the factor $r^{M-n}$ depends on the label at $\max S$.
* *Evidence:* s2(d), exact. On $S=\{0,1,3\}$ the labellings $(0,1,1)$ and $(1,1,0)$ both have $H=2$, with conditional probabilities $1/5$ and $1/10$.
* The formula in Prop 3.7(2) itself is right. It normalises to exactly 1 on all 3301 reachable domains tested.
* *Fix:* "through $H$ and the label at $\max S$"; write $\propto\binom nHr^{M-n}$ in the table.

**m3. §2.5 and e3: the remark on the Stirling error is false** (confirms run 1, m4).
* *Claim:* "The Stirling error equals $1/(12N\ln2)$ to the printed precision for $n\le24$."
* *Problem:*
  * At $n=1,2$ the errors are $0.05964$ and $0.02999$, against $0.06011$ and $0.03006$.
  * For $n\ge17$ the e3 column is double-precision noise. At $n=18$ e3 prints $4.591\cdot10^{-7}$ against the true $4.586\cdot10^{-7}$; at $n=24$, $5.96\cdot10^{-8}$ against $7.17\cdot10^{-9}$.
* *Evidence:* s1(e), at 120 digits. Thm 2.1(4) (the Robbins window) holds at every $n$ tested, including $n=64$.
* *Fix:* drop the remark, or compute with mpmath.

**m4. §2.4, the parenthetical on a prior over $n$: the justification does not apply.**
* *Claim:* "If $n$ is drawn from a computable prior $w$ … Lemma 1.3 applied to the mixture gives $\mathbb E L^y_M\le H(w)+c$: the Bayes label loss of the mixture is at most $H(w)$, by the same Gibbs argument on the input part."
* *Problem:*
  * With raw blocks of varying length the input code is not prefix-free across $n$. The supermartingale step of Lemma 1.3 fails at $t=1$: $\sum_{x_1}M(x_1)$ over all lengths can exceed 1.
  * In the pair formalism the Bayes label loss of the mixture is 0. The $H(w)$ comes from the input side (the first block), not from the labels.
* The bound itself is true. Run the proof of Prop R3: the first-step term satisfies
$$\mathbb E\log W_1\le\sum_nw(n)\Big[\log\sum_{|x|=n}M(x)+\log\tfrac1{w(n)}\Big]\le H(w),$$
because the strings of one length form a prefix-free set.
* *Fix:* give this proof, or drop the parenthetical. M3 makes it secondary.

**m5. Prop 2.4 and the prose after it: weak semimeasures.**
* *Claim:* "No predictor that sees past data only as a set of pairs, and evaluates the data set as a whole, can do better on average."
* *Problem:* for $k<N-1$ the notes prove this only for random-partial-function laws.
* [history] `notes-final.md` Prop 2.3(a) now proves $\sum_z\nu(D(x,z))\le1$ for **every** weak semimeasure, so the track's $\log_2(N-1)_k-\log_2(N-1)$ bound extends.
* Whether the sharper $\log_2(N-1)_{k-1}$ (depth count) extends to weak semimeasures is **[open]**. Run 1's LP found the maximum $N-k$ at $N=4$ only.
* *Fix:* cite the history result, and keep the prose at that strength.

**m6. Remark 2.7: SFI$^{\rm set}$ also fails on H5; a notation clash.**
* (a) The remark says that SFI$^{\rm set}$ (hypotheses see the set of previous inputs) "is weaker", citing a different construction. On H5 itself it pays the full SFI cost.
  * *Proof.* For fixed $\omega$ and the full cycle, $x_N=0^n$ and $\{x_{<N}\}=\{0,1\}^n\setminus0^n$ are known. Backward reconstruction ($x_{j-1}=U^\omega(\{0,1\}^n\setminus\{x_N,\dots,x_j\},x_j)$) leaves at most one consistent order. So $\sigma\mapsto M_{\rm set}(\sigma)$ sums to $\le1$ and is lower semicomputable uniformly in $n$, and (F3) with Lemma 1.2 gives $L_{\rm set}\ge\log_2((N-1)!)-m-c$ w.p. $\ge1-2^{-m}$. By [history] Prop 4.4(c), $L_{\rm set}\le L_{\rm SFI}+c\le\log_2((N-1)!)+c$. $\square$
  * This is a clean statement for H4: the oracle must give the **list** of previous inputs. The set is not enough.
* (b) The remark quotes "$\log_2n!-\log_2n-c$" with $n$ the number of strings. In §2, $n$ is the bit length. Rename one of the two.

**m7. §5.1 and §5.4: wording of the OOD upper limits.**
* §5.1's relative bound uses $\lvert p'\rvert\le\lvert p\rvert+K(L')+c$.
  * This presumes that $p$ has a parseable form (search code plus a description of $T$), so that a wrapper can truncate its search.
  * [context] `notes-final.md` Prop 2.3 now states the general form with the conditional complexity $K(q,r\mid p)$; Ex 2.15 states the bound as $2^{-K(L'\mid p)-c}$.
  * Cite it and state the bound with $K(L'\mid p)$.
* §5.4's "false" column lists "more resolved sentences … make the RH label nearly certain".
  * The proved floor $2^{-K(T)-2\log\log L-c}$ can be astronomically small; $K(T)$ for ZFC is thousands of bits. So it does not refute "nearly certain" in any practical sense.
  * What it refutes is "the wrong-label probability tends to 0 as bounded-difficulty sentences are added".
  * The bound that bites is the relative one: $2^{-K(L'\mid p)-c}$ times the posterior of proof search.
  * Hänni wrote "plausibly", so the column should say "a natural strengthening", not his claim (run 1, m7).
* [context] Prop 2.4 now covers $M_F$ (part (b), added after run 1). Cite part (b).

**m8. Example 4.5: the bound is loose** (confirms run 1, m5).
* The enumerative code given $(d,A)$ gives $K(p)\le(d+1)\log_2A+K(d)+K(A)+c$.
* So SFI is optimal up to $O(\log d+\log A)$, not up to $2(d+1)\log_2\log_2A$.

**m9. Prop 4.6: notation.**
* "$n$ distinct inputs" is written as $L_{\rm SFI}(D_n)$, where $D_n$ is the data after $n$ steps. With repetitions these differ.
* *Fix:* write $D$ with $\lvert\mathrm{dom}\,D\rvert=n$. The statement already says the inputs are chosen independently of the noise, which the expectation needs.

**m10. Lemma 3.5: vacuous at the sizes simulated; uncited inequality.**
* $20e^{-n/18}\ge1$ for $n\le53$.
* The exact values (s2(a)) are $6.48\cdot10^{-2}$, $1.55\cdot10^{-2}$, $1.11\cdot10^{-3}$, $7.31\cdot10^{-6}$, $4.27\cdot10^{-10}$ at $n=10,20,40,80,160$. Quote these instead of the simulation.
* Cite Hoeffding: W. Hoeffding, "Probability inequalities for sums of bounded random variables", *JASA* 58 (1963) 13–30. Checked by WebSearch snippet.
* The lemma is correct and suffices for Borel–Cantelli.

**m11. Prop 3.4(3) can be upgraded from proof sketch to proved.**
* $T_n$ is independent of $G$. Conditionally on $T_n=j$, $G_j-j/2$ is a sum of $j$ i.i.d. centred terms with variance $3/4$.
* The conditional characteristic function, the binomial CLT for $T_n$ and dominated convergence give the limit directly. No random-index (Anscombe) theorem is needed.
* If Anscombe is kept, cite F. J. Anscombe, *Proc. Cambridge Philos. Soc.* 48 (1952) 600–607. I confirmed the citation by WebSearch but did not read the paper.
* *Evidence:* $\sigma^2=1.04966$. My simulation gives $\mathrm{Var}(UB_n)/n=1.043$, $1.011$, $1.13$ at $n=10^2,10^3,10^4$, the last with 300 runs (s2(c)).

**m12. §2.5: the proxy constant is approximate** (confirms run 1, m12).
* The SFI proxy pays $\log_2((N-1)!)+\log_26-\log_2(1+1/N+(N-1)!/N^N)$. At $n=4$ that is 42.748, against $40.250+2.585=42.835$.
* *Fix:* write "$\approx$".

**m13. Prop 2.6 and Thm 3.10(2): a step is not cited** (run 1, m8).
* Passing from "$\mu$ is a computable law on pair sequences" to "$M\ge2^{-K(\mu)-c}\mu$ on the binary encoding" needs [history] Lemma B, or the remark that the binary semimeasure is lower semicomputable with an index computable from $\mu$.
* Fixed-length blocks are prefix-free for fixed $n$ only.

**m14. Cross-references are stale or need coordination.**
* [history] `notes-final.md` (in progress) now contains:
  * Prop 2.3, "the cost is intrinsic to order-free prediction", which overlaps examples Prop 2.4;
  * summary row 4.8, "Cyclic permutation: SFI$^{\rm hist}$'s loss is $\le c$", which duplicates examples Prop 2.5;
  * the definition $\xi:=M_H$.
* Coordinate so that each result has one home.
* (F7)'s phrase "for Hutter's $\xi$ this is its defining property" is inaccurate. Dominance is a consequence of the mixture definition, and the history track now defines $\xi$ as $M_H$.
* [context] Prop 2.3 changed to conditional complexity, and Prop 2.4(b) and Ex 2.15a are new. The examples notes should cite the final numbering when the revision is written.

---

## 4. Claims confirmed

I checked each item line by line. "(code)" marks those I also confirmed with my own scripts.

**Setup.**
* Lemma 1.1.
* Lemma 1.2, including the strict inequality and the empty case.
* Lemma 1.3:
  * the telescoping with $\rho(\varepsilon)\le1$;
  * the decomposition $-\log\mu(h_n)=L^y_\mu+\sum_t-\log\mu(x_t\mid h_{t-1})$;
  * the supermartingale step via prefix-freeness, and Ville.
* (F1)–(F9) as used.

**H5.**
* §2.1 bijection.
* Thm 2.1(1)–(4): (1) is true but loose (m1); (4) checked at 120 digits (code).
* Lemma 2.2: uniqueness of $z$ per $\omega$; $\nu=0$ when $z$ repeats or contains $x$.
* Thm 2.3(1)–(3): true but not sharp (M1). Checked:
  * the contraction count $(N-k-1)!/(N-1)!$ (code);
  * the $T'$ bound $2^{-k}/(N-1)_{k-1}$;
  * the claim "within $k+m+c$" for $k<n$ (it carries an extra $\log_2\frac{N-1}{N-k}\le1$);
  * the union bound in (3).
* Prop 2.4(1),(2).
* Prop 2.5.
* Prop 2.6: true as stated for raw blocks (M3).
* Remark 2.7: the set-based predictor "the unique input that is not a label" is correct at every $t\le N$, including $x_N=0^n$.

**H6.**
* Lemma 3.1.
* Prop 3.2, for every reveal sequence including heads-behind paths.
* Thm 3.3, including $K(x\mid g)\ge K(x)-K(g)-c$ and Levin–Schnorr for the computable Bernoulli measure.
* Prop 3.4(1),(2) and the variance (code).
* Lemma 3.5: the reduction to "$T_n\ge n/2$ or some $k\ge n$ with fewer than $k/2$ tails"; $1+1/(1-e^{-1/18})=19.505$; exact values (code).
* Thm 3.6, both directions:
  * Jensen with $\mathbb E\tau_n=n/2$;
  * $H(b_{<g}\mid g)=H(b_{<g})-H(g)$;
  * $\Pr[b_{<g_n}=s]\le P_{1/3}(s)$;
  * the Cauchy–Schwarz tail;
  * $g_n\le$ first tail at or after $\tau_n$, in both cases $\tau\le\eta$ and $\eta<\tau$;
  * $\mathbb Eg_n\le n/2+1/2$ (code: $\mathbb E[g_n-\tau_n]$ consistent with $\le1/2$);
  * the maximum-entropy bound.
* Prop 3.7(1),(2),(3): Vandermonde and the hockey stick (code, exact), except the sentence in m2.
* Lemma 3.8, all cases. Note: $\tau=\eta$ forces touching.
* Prop 3.9:
  * transitions;
  * $\varphi=1/2$ as the minimal root (code);
  * the transience argument;
  * return probability $2/3$ (code);
  * the regeneration argument;
  * $\kappa$ (code, 30 digits);
  * $\mathbb EL_{P^*}(n)=\kappa\,\mathbb EN_{\rm touch}(n)$ (code, exact DP).
* Thm 3.10(1),(2): the label conditionals of $\mu$ are $P^*$; all of $\mu$'s probabilities are rational.
* Cor 3.11: in $A$-states the rule is exact; $A\to B$ only through touching; the last touching step exits into $A$.
* The brief's-rule statistics: exact limits $\mathbb E[\text{errors}]=2$ (errors per touching step $2/9+1/9+1/3$) and $\Pr[\text{no error}]=1/2$ (code).
* §3.6: the analysis of Hänni's e-mail, including $UB_n-\tau_nh(1/3)=-\tfrac23(G_{T_n}-T_n/2)$.

**Positive examples and OOD.**
* Prop 4.1 (raw and normalised mistake counts).
* Examples 4.2–4.4 (lower bounds via sub-probabilities over label sequences; adaptive bisection).
* Example 4.5 (true; m8).
* Prop 4.6: the Laplace integral $1/((n+1)\binom ne)$; concavity of $h$.
* Prop 5.1.
* The proved bullets of §5.1–5.3. Note: $2^{-K(L')}\ge2^{-c}/(\log_2L(\log_2\log_2L)^2)$ for $L'=2^{\lceil\log_2L\rceil}$.

**Track code.**
* `threshold_mixture_loss`: the lump $\sum_{s\ge M}\pi(s)=1/(M+1)$ is right, and both families' lumps are included.
* `bayes_xonly_surprisal`: the closed forms $\log_2(1+2^{-e})$ and $e+\log_2(1+2^{-e})$ are right.
* `pstar_prob_one` and `true_input_log2prob`: match Lemma 3.8 and its input law.
* `cyclic_example_losses`: permutation law $1/(N)_k$, function law $N^{-k}$, cyclic law.
* `sfi_dsl.py`: the grammar prior and the if-program weights $(1-p)\,p_C\,m_1m_2$.

All numbers in the tables of §2.5, §3.8, §4 and §5.3 match the saved outputs.

---

## 5. References

**Checked by WebSearch** (bibliographic data and the statement used; full text not opened):
* S. Sattolo, *Inf. Process. Lett.* 22 (1986) 315–317: uniform random cyclic permutations.
* H. Robbins, "A remark on Stirling's formula", *Amer. Math. Monthly* 62(1) (1955) 26–29: the bounds $1/(12n+1)$ and $1/(12n)$.
* T. Lattimore, M. Hutter, V. Gavane, "Universal prediction of selected bits", ALT 2011, LNCS 6925, 262–276 (arXiv:1107.5531). The abstract says what the notes say.
* Levin–Schnorr for computable measures, in the prefix-complexity form used in (F4). Stated as "Levin/Schnorr" in secondary sources (snippets). Section numbers in Li–Vitányi remain unverified.
* Hoeffding 1963 and Anscombe 1952 (m10, m11). Not cited in the notes; they should be.

**Not verified** (already marked unverified in the notes):
* Li–Vitányi section numbers;
* Hutter 2005 ch. 5;
* Ville 1939;
* Zvonkin–Levin 1970;
* Levin 1974, Gács 1974, Chaitin 1975 (coding theorem).

**Cross-references.**
* All references into [foundations] `notes.md` exist and say what is used: Def 2.1(a),(b), Prop 2.6, Thm 3.2, Prop 3.3, Prop 5.2, Thm 6.3, Prop 6.8.
* The same holds for [history] `notes.md`: Lemma 1.1, Lemma 2.0, Thm 2.1, Cor 4.3(b), Prop 4.4(a),(c), Prop 4.5(iii), §4.4, Lemma B, Thm 4.6, Q4.
* The same holds for [context] `notes.md`: Props 2.1, 2.3, 2.4, Thm 2.5, Thm 2.7, Ex 2.15.
* Changes in the newer final notes are listed in m14.

---

## 6. Important questions from the brief that the track missed or left open

1. **The normalised predictor (H5, H6).** Left as a conjecture with no partial result.
   * Prop R2 settles H5 for $t\le2^{(1-\delta)n}$.
   * The full cycle and H6 remain open; M2 explains why the method stops.
   * The paper should state Hänni's claims with this qualification.
2. **"As good as SI" in H5 depends on the encoding (M3).** With the paper's prefix-free code, SI and SFI$^{\rm hist}$ both pay $O(1)$ uniformly in $n$. This sharpens the H4 discussion.
3. **Which oracle is needed (H4).** On the full cycle, SFI$^{\rm set}$ pays as much as SFI (m6). The list of previous inputs is needed, not the set.
4. **Exact $k$-step statement in H5 (M1).** The brief asks for "exact statements". The track's bounds leave an $n$-bit gap that the broom closes to $O(K(k))$.
5. **A separation in the other direction (optional).**
   * The track's examples all show SFI worse than SI or SFI$^{\rm hist}$.
   * A worked example where SFI's loss is $O(1)$ and SI's unnormalised label loss is large would complete the picture. The Lattimore–Hutter–Gavane selected-bits phenomenon is a candidate.
   * The history track owns the general question (its Q3), so this is optional for the examples track.

---

## 7. Referee code log

All scripts were run with python3 (numpy 2.4.6, scipy 1.17.1, mpmath 1.3.0) from `referee_code/`. They do not import the track's code.

| script | seed | runtime | output |
|---|---|---|---|
| `s1_cyclic_sharp_normalised.py` | 20261012 | about 1 min | `s1_cyclic_sharp_normalised_output.txt` |
| `s2_eisenstat_dp.py` | 20261012 | about 15 s | `s2_eisenstat_dp_output.txt` |
| `s3_si_encoding.py` | 20261012 | about 1 s | `s3_si_encoding_output.txt` |
| `r1`–`r3` (run 1) | 20261011 | 1–3 min each | `r*_output.txt` (unchanged) |

The track's `checks/e1`–`e5` were re-run on scratch copies. Their outputs are identical to the saved ones, apart from e2's runtime line.

Corrections during my work:
* s1(d) first printed $\log_2(N-1)_k$ as 0 for small $k$, because of float cancellation at $N=2^{64}$. It now uses mpmath.
* s1(e) first ran at 60 digits, too few for the Robbins window at $n=64$. It now runs at 120.
* s2(a) first truncated the $A$-walk at $U\le400$, which lost mass by $n=400$. It now uses $U\le1500$.
