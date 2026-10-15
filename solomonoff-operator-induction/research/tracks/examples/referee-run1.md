# Referee report: track "examples"

*Adversarial referee for `notes.md`, `checks/e1`–`e5` and `code/sfi_examples.py`, `code/sfi_dsl.py` (brief items H5, H6, positive examples, Hänni's OOD examples). I did not edit the notes or the track's code. My independent code is in `referee_code/`. It is seeded where random, and each script writes `<name>_output.txt` next to itself.*

## 0. Verdict

* **The proofs are sound.** I checked every proof marked [proved] line by line. I found no false inequality, no wrong constant that matters, no broken quantifier order, and no hidden use of a measure where only a semimeasure is available.
* **Every computed number reproduces.** All five check scripts reproduce their saved outputs on scratch copies. e2 differs only in the runtime line. An independent implementation reproduced the exact law of Eisenstat's process, $P^*$, the touching chain, $\kappa$, the asymptotics of $UB_n$, and the e5 table (§1).
* **No fatal issues. Two major issues:**
  * **M1.** The $k$-step analysis of the cyclic example (Thm 2.3) is not sharp. A simple "broom" hypothesis together with a depth-counting lemma gives
    $$L_{\rm SFI}(D_k)=\log_2(N-1)_{k-1}\pm O(\log k)\quad\text{w.h.p.},$$
    for all $1\le k\le N$. This answers open problem 3 negatively. It unifies Thm 2.1(3) and Thm 2.3(2), and it strengthens Prop 2.4(1). Full proofs are in §2.
  * **M2.** The verdicts on Hänni's claims ("high loss under SFI holds", "$0.459n$ verified") hold only in the semimeasure convention. The track says so in a caveat but not in the verdicts. For the normalised predictor the question is open, and it is not a formality: for a single partial hypothesis the two conventions differ by $\Theta(n)$ bits per step (r2(f)).
* **Thirteen minor issues** (§3). They include one false sentence about Prop 3.7(2), a removable $K(n)$ in Thm 2.1(1), a false remark about the Stirling error, and several citation and scope imprecisions.

---

## 1. What I did

* Re-ran `checks/e1`–`e5` on scratch copies, with `code/` copied alongside. e1, e3, e4 and e5 are byte-identical. e2 differs only in the runtime line.
* Wrote three independent checks:

| script | target | result |
|---|---|---|
| `r1_eisenstat_independent.py` | §3: Prop 3.7, Lemma 3.8, Prop 3.9, Prop 3.4, Lemma 3.5, Thm 3.6 steps, the brief's rule, track code | Lazy exact enumeration with no fixed tape length (exact rationals; $n=3,\dots,6$). Prop 3.7(1),(2) exact (max error 0 on 43 492 data sets at $n=6$). $P^*$ equals the brute-force conditional on 263 563 (history, input) pairs (error 0). Prop 3.7's sentence "depends only on the number of heads" is **false** (m3). Exact DP of the touching chain: $\mathbb EN_{\rm touch}\to3$, $\kappa=0.79951673634959\ldots$, the exact $\Pr[\eta_n<\tau_n]$, and for the brief's rule $\mathbb E[\text{errors}]\to2$ and $\Pr[\text{no error}]\to1/2$ exactly (e2 simulated 1.98 and 0.488). Own simulation: $\mathbb EUB_n/n=0.45911\pm0.00023$ ($n=10^3$), $\mathrm{Var}/n\approx1.04$. `bayes_xonly_surprisal` and `threshold_mixture_loss` agree with brute force to $4\cdot10^{-14}$. |
| `r2_cyclic_independent.py` | §2: Thms 2.1, 2.3, Prop 2.4, constants; new M1 bounds | Broom law: $\nu(D_k)=1/(N-1)_{k-1}$ exactly ($n=2,3$, all $k$). Depth-count lemma: max $=N-k$ exactly over all 625 partial functions ($n=2$) and all $8^8$ total functions ($n=3$). $T'$ bound of Thm 2.3(1) holds ($n=2,3$). LP over **all** weak function semimeasures on 4 points: $\max\sum_z\nu(D(x,z))=1$ (m2). Robbins window verified at 100 digits; e3's "to printed precision for $n\le24$" is false (m4). Normalised vs semimeasure demonstration (M2). |
| `r3_dsl_independent.py` | §5.3 (e5) | Re-implemented the grammar without merging by value vector (38 994 expressions; 1345 distinct value vectors, as e5 reports). Every number of the §5.3 table and of the online part is reproduced to the printed digits. |

* Checked every reference that WebSearch can reach (§5).
* Checked every cross-reference into the foundations, history and context notes (§5).

---

## 2. Major issues

### M1. The $k$-step bounds for the cyclic example are not sharp; open problem 3 has a negative answer

**Claims.**
* Thm 2.3(1): $L(D_k)\le\log_2(N-1)_k-\max\{0,\log_2(N-k)-k\}+c$.
* Thm 2.3(2): $L(D_k)\ge\log_2(N-1)_k-\log_2(N-1)-m-c$ with probability $\ge1-2^{-m}$.
* Prop 2.4(1): $\mathbb E[-\log\nu(D_k)]\ge\log_2(N-1)_k-\log_2(N-1)$.
* The "Reading" after Thm 2.3: "SFI pays $\log_2(N-1)_k\pm O(n)$ bits".
* Open problem 3 (§7): "is $L_{\rm SFI}(D_k)=\log_2(N-1)_k+O(1)$ with high probability once $k\ge n$?"

**Problem.** All of these statements are true, but the gap between the bounds is about $\min(n,k)$ bits. It should be $O(\log k)$. The upper bound uses only the cyclic law $T_{\rm cyc}$. That law pays $\log_2(N-1)$ bits for "where on the cycle $x_k$ sits", and SFI does not have to pay this. The lower bound wastes the same $\log_2(N-1)$ in the other direction.

**Correct statement (proved below; computed: r2(a),(b),(g)).** Let $1\le k\le N-1$ and $(N-1)_{k-1}=(N-1)(N-2)\cdots(N-k+1)$, with $(N-1)_0=1$.
1. For every chain $D_k$ ($x_k\to x_{k-1}\to\dots\to x_1\to0^n$, distinct nonzero $n$-bit strings):
   $$L_{\rm SFI}(D_k)\le\log_2(N-1)_{k-1}+\min\{K(k),\ \log_2(N-k),\ k\}+c.$$
2. For every law $\nu$ of a random partial function and uniform cyclic $f$:
   $$\mathbb E[-\log_2\nu(D_k)]\ge\log_2(N-1)_{k-1}=\log_2(N-1)_k-\log_2(N-k).$$
3. For uniform cyclic $f$ and $m\ge0$:
   $$\Pr\big[L_{\rm SFI}(D_k)<\log_2(N-1)_{k-1}-m-c\big]<2^{-m}.$$

So $L_{\rm SFI}(D_k)=\log_2(N-1)_{k-1}\pm O(\log k)$ with high probability, uniformly in $1\le k\le N-1$. At $k=N-1$, part 3 recovers Thm 2.1(3) (applied to $D_{N-1}$), and part 2 recovers the random-function case of Prop 2.4(2). In words: SFI pays for the $k-1$ nonzero labels as an injective sequence; the identity of the head $x_k$ is essentially free.

**Answer to open problem 3: no.** For $k\le N/2$, part 1 gives $L(D_k)\le\log_2(N-1)_k-(n-1)+K(k)+c$. This lies below $\log_2(N-1)_k$ by $\Theta(n)$ whenever $K(k)\le(1-\delta)n$; for example, $n=64$, $k=64$ gives a deficit of about 53 bits (r2(g), constants omitted).

**Proof of 1.** Let $B_k$ be the following function machine.
* For each length $\ell$, it reads its own sub-stream of the tape and draws, by rejection sampling, a uniformly random injective sequence $(v_1,\dots,v_{k-1})$ of nonzero $\ell$-bit strings. If $k-1>2^\ell-1$, it outputs $0^\ell$ everywhere on that length.
* On input $x$ of length $\ell$ it outputs:
  * $0^\ell$ if $x=v_1$;
  * $v_{i-1}$ if $x=v_i$ with $2\le i\le k-1$;
  * $v_{k-1}$ for every other nonzero $x$ (and $0^\ell$ for every nonzero $x$ when $k=1$).

The value at $x$ is fixed by finitely many tape bits almost surely. $B_k$ is computable from $k$, so $K(\nu_{B_k})\le K(k)+c$. On the event $(v_1,\dots,v_{k-1})=(x_1,\dots,x_{k-1})$, which has probability $1/(N-1)_{k-1}$, the hypothesis extends $D_k$: $x_k$ is not among the $v_i$, so it is sent to $v_{k-1}=x_{k-1}$. (F1) gives the $K(k)$ term. The other two terms are Thm 2.3(1), rewritten using $\log_2(N-1)_k-\max\{0,\log_2(N-k)-k\}=\log_2(N-1)_{k-1}+\min\{\log_2(N-k),k\}$. $\square$

**Proof of 2 and 3.** *Depth-count lemma.* For a partial function $F$, let $A_k(F)$ be the set of nonzero $x\in\{0,1\}^n$ whose $F$-orbit stays in the nonzero $n$-bit strings for $k-1$ steps and hits $0^n$ at step $k$. Then $|A_k(F)|\le N-k$.
* Proof of the lemma: if $x\in A_k$, then $F(x),\dots,F^{k-1}(x)$ are $k-1$ distinct nonzero $n$-bit strings whose first hitting times of $0^n$ are $k-1,\dots,1$. So none of them is in $A_k$, and $|A_k|\le(N-1)-(k-1)$.

For fixed $\omega$, each $x\in A_k(f_\omega)$ has exactly one $z$ with $|z|=k-1$ and $f_\omega\supseteq D(x,z)$ (its orbit), and every other $x$ has none. Hence
$$\textstyle\sum_{x,\,|z|=k-1}\nu(D(x,z))=\mathbb E_\omega|A_k(f_\omega)|\le N-k .$$
* Part 2: Gibbs' inequality with $q=\nu/(N-k)$, applied to $(x_k,x_{k-1},\dots,x_1)$, which is uniform over $(N-1)_k$ injective sequences.
* Part 3: $q(x,z\mid n,k):=M_F(D(x,z))/(N-k)$ is lower semicomputable uniformly in $(n,k)$ and sums to at most 1. So by (F3), $K(x,z\mid n,k)\le L(D(x,z))+\log_2(N-k)+c$. Then apply Lemma 1.2 with $w=(n,k)$. $\square$

**Evidence.**
* r2(a): exhaustive over all orderings, $n=2,3$, every $k$. The broom law gives exactly $1/(N-1)_{k-1}$; e.g. $n=3$, $k=4$: $1/210$ against $1/840$ for $T_{\rm cyc}$.
* r2(b): the depth-count maximum is exactly $N-k$ over all 625 partial functions on 4 points and all 16 777 216 total functions on 8 points.
* r2(g) tabulates both pairs of bounds. The referee gap is $\min\{K(k),\log_2(N-k),k\}$; the track's gap is about $\min\{n,k\}+\log_2\frac{N-1}{N-k}$.

**Fix.**
* Replace Thm 2.3(1),(2) and Prop 2.4(1) by parts 1–3.
* Correct the "Reading" paragraph.
* Close open problem 3.
* The SFI proxy of §2.5 has no broom component. At $k=N/2$ it therefore overstates the $k$-step cost by about $n-1$ bits, less the component's prior cost. Either add a broom component or say this in the text.

### M2. The verdicts on Hänni's claims hold only in the semimeasure convention

**Claims.**
* Summary row 2.1: "Hänni's claim 'high loss under SFI' holds, with these constants".
* Rows 2.3 and 3.6: "SFI pays about $n$ bits per step"; "The brief's $\approx0.459n$ is verified".
* §2.2: "So the gap between SFI and SI here is not a weakness of the universal prior."

**Problem.** Every SFI lower bound in §2 and §3 concerns $-\log M_F(D)$. That is the cumulative loss of the raw, unnormalised conditionals. The caveat at the top of the notes says this. The verdicts do not, and a reader of the summary table will take them as facts about the SFI predictor.
* No information-theoretic argument can settle the normalised case. The normalised conditional $M_F(D_t)/\sum_yM_F(D_{t-1}+(x_t,y))$ is a set-based history-aware predictor. Set-based predictors achieve $O(1)$ loss in both examples (Remark 2.7; $P^*$ is set-based).
* The gap between conventions can be large for individual hypotheses. In r2(f), $n=10$, the partial law $\nu_{\rm geo}$ (a random ordering, defined on a Geometric(1/2) number of chain positions) has:
  * normalised loss exactly 1 bit per step ($k=100$: 100 bits);
  * semimeasure loss $\log_2(N-1)_k+k$ (1091.6 bits).
* Mixed half and half with the cyclic law, the normalised loss returns to within 3.3 bits of the semimeasure loss (8756.8 against 8760.0 at $k=N-1$), because the total law dominates the denominator.

So the conjecture of §7.1 is plausible. It depends on how much mass total and partial hypotheses consistent with the data carry, which the existing arguments do not control.

**Fix.**
* Attach "in the semimeasure convention ($-\log M_F$, the Bayesian marginal likelihood)" to every verdict in §0, §2.6 and §3.6.
* Keep open problem 1 prominent in the paper. Add r2(f) as evidence that it is a real question.
* Note that SI's label loss in Prop 2.6 and Thm 3.10 is also computed with unnormalised conditionals of $M$, so that comparison is like for like.

---

## 3. Minor issues

**m1. Thm 2.1(1): the $K(n)$ term is unnecessary.**
* *Claim:* $K(f\mid n)-c\le L(f)\le K(f\mid n)+K(n)+c$.
* *Problem:* an SFI hypothesis sees the input, and $n=|x|$ is part of the input. So $L(f)=K(f\mid n)\pm c$.
* *Proof:* the function machine reads one self-delimiting program $p$ from the shared tape. On input $x$ it runs $V(p,|x|)$, expects a table of a function on $\{0,1\}^{|x|}$, and outputs its entry at $x$. With probability $\ge2^{-K(f\mid n)}$, $p$ is a shortest conditional program for $f$, and then $f_\omega\supseteq f$. The machine is fixed, so its complexity is $O(1)$.
* *General form:* $L(D)=K(D\mid\mathrm{dom}\,D)\pm c$ whenever $\mathrm{dom}\,D$ is computable from each of its elements by a fixed map.
* *Fix:* state $L(f)=K(f\mid n)\pm c$. The contrast with SI (Prop 2.6), which needs $K(n)$ because it does not see block boundaries, is worth one sentence.

**m2. Prop 2.4(1) holds for every weak function semimeasure; the prose after it overreaches unless this is proved.**
* *Claim:* Prop 2.4(1) is proved for random-partial-function laws only. The prose then says that no order-free predictor can do better on average.
* *Problem:* for $k<N-1$ the prose is supported only after this extension.
* *Proof of the extension:* fix $x$ and run the adaptive query tree: query $x$; then query the label just received, stopping at $0^{|x|}$ or at a repeat. The weak inequality at each internal node and induction on depth give that the leaves have total mass $\le\nu(\emptyset)\le1$. Every valid $D(x,z)$ is a distinct leaf. So $\sum_z\nu(D(x,z))\le1$, and Gibbs applies as before.
* *Computed:* the LP over all weak semimeasures on 4 points gives the maximum exactly 1 (r2(d)). The LP also gives $\max\sum_{x,|z|=k-1}\nu=N-k$ there, so M1(2) may also extend to weak semimeasures **[conjecture; checked only for $N=4$]**.

**m3. Prop 3.7(2): one sentence and one summary entry are false.**
* *Claims:* after Prop 3.7, "Part 2 says the conditional law of the labels given the domain depends on the labelling only through the number of heads". Summary row 3.7: "the labels given the domain have law $\propto\binom nH$".
* *Problem:* the factor $r^{M-n}$ depends on the label at $\max S$. Counterexample (r1(A2), exact): on domain $\{0,1,3\}$, the labellings with $H=2$ have conditional probabilities $0.1$ (top label 0) and $0.2$ (top label 1).
* *Fix:* "through the number of heads and the label at $\max S$". The formula in Prop 3.7(2) itself is correct (verified exactly up to $n=6$).

**m4. §2.5: the remark on the Stirling error is false.**
* *Claim:* "The Stirling error equals $1/(12N\ln2)$ to the printed precision for $n\le24$."
* *Problem:*
  * At $n=1,2$ the errors are $0.05964$ and $0.02999$, against $0.06011$ and $0.03006$.
  * For $n\ge18$ the e3 column is a double-precision artefact. At $n=24$ e3 prints $5.96\cdot10^{-8}$; the true value is $7.17\cdot10^{-9}$ (r2(e), 100 digits).
* Thm 2.1(4) itself is correct: the Robbins window holds for every $n\le24$ and for $n=32,40,64$ (r2(e)).
* *Fix:* drop the remark, or compute with mpmath.

**m5. Example 4.5: the bound is loose.**
* *Claim:* SFI pays $\le(d+1)(\log_2A+2\log_2\log_2A)+O(d)$, against the lower bound $(d+1)\log_2A$.
* *Problem:* the enumerative code given $(d,A)$ gives $K(p)\le(d+1)\log_2A+K(d)+K(A)+c$. So SFI is optimal up to $O(\log d+\log A)$, not up to $2(d+1)\log\log A$.
* *Fix:* state the sharp form. The subadditive bound $\sum_iK(a_i)+O(d)$ is the right one for arbitrary coefficients only.

**m6. Prop 4.6: the role of $n$ is unclear.**
* *Problem:* $n$ is "the number of distinct inputs", but it is written as the index of $D_n$. The expectation statement and the "every learner" lower bound need the input sequence (hence $n$) to be fixed, or chosen independently of the noise; adaptive choices based on revealed labels change the law of $e_n$.
* *Fix:* state this. The pathwise bound $L\le\log_2\binom n{e_n}+\log_2(n+1)+K(g)+c$ holds for every sequence, as stated.

**m7. §5: citation and scope.**
* [context] Prop 2.4, the machine-dependence result, is proved for the program mixture $W$, not for $M_F$. The function-machine analogue ($U'^{1\omega}(x)=b(x)$ on $Q$) is immediate but should be stated.
* §5.4 lists "0.11 on a tilted grammar" as evidence that "correct w.h.p. on every universal machine" is false. A finite grammar is not a universal machine; the proof is [context] Prop 2.4, and e5 only illustrates it.
* The "false as an unconditional claim" column states claims that Hänni did not make (e.g. "more resolved sentences … make the RH label nearly certain"). Label them as natural strengthenings, not as his claims.

**m8. Lemma 1.3 "Use", Prop 2.6 and Thm 3.10(2): a step is not cited.**
* *Problem:* passing from "$\mu$ is a computable law on pair sequences" to "$M\ge2^{-K(\mu)-c}\mu$ on the binary encoding" needs the block-code lemma ([history] Lemma B), or an explicit remark that the induced binary semimeasure is lower semicomputable with index computable from $\mu$.
* *Fix:* cite it. The statements are correct.

**m9. Prop 3.4(3) is marked "proof sketch" but needs no Anscombe argument.**
* $T_n$ is independent of $G$. Conditional on $T_n=j$, $G_j-j/2$ is a sum of $j$ i.i.d. centred terms. The conditional characteristic function and dominated convergence give the joint limit in three lines.
* *Fix:* upgrade to proved. Numerically, $\sigma^2=1.04966015$ (r1(C)); simulated $\mathrm{Var}(UB_n)/n=1.045$ at $n=10^3$, 20 000 runs.

**m10. Lemma 3.5: the bound is vacuous at the tested sizes.**
* *Problem:* $20e^{-n/18}\ge1$ for $n\le53$. So e1(f)'s "simulated probabilities below the bound" says nothing at $n=10,20,40$.
* The exact values are $6.48\cdot10^{-2}$, $1.55\cdot10^{-2}$, $1.11\cdot10^{-3}$, $7.3\cdot10^{-6}$, $4.3\cdot10^{-10}$ at $n=10,20,40,80,160$ (r1(B)). The lemma is correct and suffices for Borel–Cantelli.
* *Fix:* cosmetic. Quote exact values instead of the simulation.

**m11. Remark 2.7: notation clash.**
* *Problem:* it quotes [history] Prop 4.5(iii), "$\ge\log_2n!-\log_2n-c$", where $n$ is the number of strings. In §2, $n$ is the bit length.
* *Fix:* rename one of the two.

**m12. §2.5: the proxy constant is approximate.**
* *Problem:* "The SFI proxy pays $\log_2((N-1)!)+\log_26$ over the cycle" is exact only up to $-\log_2(1+1/N+(N-1)!/N^N)$, which is 0.087 bits at $n=4$.
* *Fix:* write "$\approx$".

**m13. Open problem 2 (SI's label loss in H5) has an obvious candidate.**
* *Problem:* the notes give no hint of where a $K(n)$-sized cost would arise.
* The first label $0^n$ follows $n$ random bits with no delimiter. Predicting it amounts to predicting "switch to zeros now" at position $n$, which costs about $-\log$ of a universal prior on $n$. Later labels are copies. So $\Theta(K(n))$ for typical $n$ is the natural conjecture.
* *Fix:* record this as a **[conjecture]** with the heuristic. It matters for H4: SFI$^{\rm hist}$ pays $O(1)$ uniformly in $n$ (Prop 2.5), so if SI pays $\Theta(K(n))$ on this sequence, that is a concrete difference between the two.

---

## 4. Claims confirmed

I checked each of the following line by line. Where marked, I also confirmed it with my own code.

**Setup and lemmas.**
* Lemma 1.1, Lemma 1.2.
* Lemma 1.3: both parts, including the supermartingale step via prefix-freeness and Ville's inequality.
* (F1)–(F9) as used.

**Cyclic example (H5).**
* §2.1 bijection.
* Thm 2.1(1)–(4): true; (1) is not tight (m1). (4) confirmed at 100 digits (r2(e)).
* Lemma 2.2: disjointness and lower semicomputability.
* Thm 2.3(1)–(3): true but not sharp (M1). The $T'$ bound confirmed exactly (r2(c)).
* Prop 2.4(1),(2).
* Prop 2.5, Prop 2.6, Remark 2.7.

**Eisenstat's example (H6).**
* Lemma 3.1.
* Prop 3.2: holds for every reveal sequence, including heads-behind paths, since revealed indices $\ge\tau_n$ are heads.
* Thm 3.3: including $K(x)\le K(x\mid g)+K(g)+c$ and the Levin–Schnorr step.
* Prop 3.4(1),(2) and the variance formula. Confirmed by own simulation: $0.45911\pm0.00023$ at $n=10^3$; $0.45925\pm0.00016$ at $n=10^4$.
* Lemma 3.5: $1+1/(1-e^{-1/18})=19.505$.
* Thm 3.6, both directions:
  * Jensen on the concave $\log(t+1)+2\log\log(t+2)$;
  * $\Pr[b_{<g_n}=s]\le P_{1/3}(s)$;
  * the Cauchy–Schwarz tail;
  * $\mathbb Eg_n\le n/2+1/2$, checked on the truncated exact enumeration ($n\le6$) and by simulation up to $n=10^4$;
  * the maximum-entropy bound for $H(g_n)$, checked on the truncated exact enumeration ($n\le6$).
* Prop 3.7(1),(2),(3): exact, $n=3,\dots,6$, except the sentence in m3.
* Lemma 3.8: exact on 263 563 pairs.
* Prop 3.9:
  * the transitions;
  * $\varphi=1/2$ as the minimal root (value iteration from 0 converges to $0.5$);
  * return probability $2/3$;
  * $\kappa=0.799516736349594872\ldots$;
  * $\mathbb EN_{\rm touch}(n)\to3$, by exact DP;
  * a Monte Carlo of $L_{P^*}$ with my own code: $2.381\pm0.011$ at $n=60$ against $3\kappa=2.3986$.
* Thm 3.10, Cor 3.11.
* The brief's-rule statistics: the exact limits are 2 errors on average and probability 1/2 of no error. e2's simulated 1.98 and 0.488 agree.
* §3.6 analysis of Hänni's e-mail: correct, including the $\Theta(\sqrt n)$ remark ($UB_n-\tau_nh(1/3)=\tfrac23(G_{T_n}-T_n/2)$ after substituting $\tau_n=T_n+G_{T_n}$).

**Positive examples.**
* Prop 4.1.
* Examples 4.2–4.4.
* Example 4.5: true; loose (m5).
* Prop 4.6: Laplace integral $=1/((n+1)\binom ne)$; Jensen via concavity of $h$.

**OOD.**
* Prop 5.1.
* The proved bullets of §5.1–5.3. The bound $2^{-K(L')}\ge2^{-c}/(\log L(\log\log L)^2)$ is correct up to the constant.
* All e5 numbers (r3).

**Track code.**
* `bayes_xonly_surprisal` and `threshold_mixture_loss` agree with brute force (r1(G)).
* `pstar_prob_one`, `true_input_log2prob` and the cyclic proxies are correct by inspection.

---

## 5. References and cross-references

**Checked against WebSearch snippets (bibliographic data and the statement used; full text not opened).**
* S. Sattolo, "An algorithm to generate a random cyclic permutation", *Inf. Process. Lett.* 22(6):315–317, 1986. Correct; it generates uniform $n$-cycles.
* H. Robbins, "A remark on Stirling's formula", *Amer. Math. Monthly* 62(1):26–29, 1955. Correct; bounds $e^{1/(12n+1)}$ and $e^{1/(12n)}$, as used.
* Lattimore–Hutter–Gavane, ALT 2011, LNCS 6925, pp. 262–276. The abstract says what the notes say.

**Not verified by me.** The notes already mark these unverified:
* Li–Vitányi section numbers. WebSearch gives chapter titles only.
* Hutter 2005 ch. 5. I found secondary confirmation that $\xi$ is the mixture over lower-semicomputable chronological semimeasures, but not the chapter.
* Ville 1939; Levin 1973; Schnorr 1973; Zvonkin–Levin 1970.

The notes do not cite Hoeffding or Anscombe; add a reference or drop the name (m9).

**Cross-references.** All exist and say what the track uses:
* [foundations] Def 2.1(a),(b), Thm 3.2, Prop 3.3, Prop 5.2, Thm 6.3, Prop 6.8;
* [history] Lemma 1.1, Lemma 2.0, Thm 2.1, Cor 4.3(b), Prop 4.4(a), Prop 4.5(iii), Thm 4.6, §4.4, Q4;
* [context] Props 2.1, 2.3, Thm 2.5, Thm 2.7, Ex 2.15.

The exception is [context] Prop 2.4, which is for $W$ only (m7).

---

## 6. Questions from the brief that the track did not settle

1. **Normalised SFI in H5 and H6 (M2).** It is left as a conjecture with no partial result. Even a bound on the cumulative "defect" terms in one example would let the paper state Hänni's claims about the predictor rather than about $-\log M_F$.
2. **The $k$-step answer for H5.** The brief asks for "exact statements". The track's statements leave an $n$-bit gap that M1 closes.
3. **SI's actual label loss in H5 (open problem 2, m13).** It bears directly on H4's "as good as SI".
4. **An example where SFI beats SI.** The brief asks for examples that clarify the difference, and the track gives only examples where SFI is worse. An example where SFI's loss is $O(1)$ and SI's label loss is large would complete the picture:
   * a simple labelling of an incompressible or adversarial input sequence, the unnormalised-$M$ failure of Lattimore–Hutter–Gavane;
   * or the "SFI$\preceq$SFI$^{\rm hist}$ but not SI" direction of [history] Q3.

   The history track owns the general question, but a worked example belongs here.
5. **Positive examples with genuine (non-frozen) noise.** The positive examples have deterministic labels or frozen noise. The brief's H7 asks about $P(y\mid x)$ with fresh noise, which needs inputs that do not repeat. A worked example would show the $K(P)$ bound, with the caveat of [foundations] Prop 6.8 in concrete form.

---

## 7. Referee code log

All scripts were run with python3 (numpy 2.4.6, scipy 1.17.1, mpmath 1.3.0) from `referee_code/`.

| script | seed | runtime | output |
|---|---|---|---|
| `r1_eisenstat_independent.py` | 20261011 (B2, D, G) | about 3 min | `r1_eisenstat_independent_output.txt` |
| `r2_cyclic_independent.py` | 20261011 (b, sampling only) | about 1 min | `r2_cyclic_independent_output.txt` |
| `r3_dsl_independent.py` | none | about 3 min | `r3_dsl_independent_output.txt` |

The track's `checks/e1`–`e5` were re-run on copies in the scratchpad. Their outputs are identical to the saved ones, apart from e2's runtime line.
