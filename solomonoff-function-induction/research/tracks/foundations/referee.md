# Referee report: track "foundations"

*Adversarial referee for `notes.md` and `checks/` of the foundations track (brief items H1, H2, H7, and invariance). I did not edit the notes. My independent code is in `referee_code/`. Every script is deterministic or seeded (seed 20261011) and writes `<name>_output.txt` next to itself.*

## 0. Verdict

* **The mathematics is sound.** I checked every proof marked [proved] line by line. I looked for hidden hypotheses, wrong constants, quantifier order, measure versus semimeasure, conditional versus unconditional complexity, and dropped logarithmic terms.
  * I found no wrong inequality and no broken proof.
  * Three proofs need an extra line (m9, m10, m11).
* **All six check scripts reproduce** their saved outputs byte for byte. Ten independent scripts confirm or extend the computed claims. They also test four constructions the track proved but did not compute: Lemma 3.1, Thm 3.4, the sufficiency half of Prop 2.3, and Prop 3.3(c).
* **No fatal issues.**
* **Three major issues.** None makes a proved statement false, but all three change what the paper should say.
  * **M1. H7 and operator induction.** Prop 6.8 refutes H7 for random-function SFI only. The notes identify $M_{\rm prod}$ with Solomonoff's operator induction. In the form described by secondary sources, operator induction is a *per-query* product mixture, and that mixture satisfies H7 directly, with no stamps.
  * **M2. The gap between $W$ and $M_F$ is much smaller than the notes say.** The bound $K(n,|D|)$ of Prop 4.4 and the verdict "the brief's hashing hint is confirmed" are superseded by a simpler argument. The deterministic program mixture loses at most the cost of *naming the number of random bits used*. For fair-coin labels this is $\min_{L\ge2^{n+1}}K(L)+O(1)\le K(\lceil\log_2(n+1)\rceil)+O(1)$, independent of $|D|$ and with no hashing. The same argument settles most of Problem 4.6(b,c) and the Remark after Prop 4.4.
  * **M3. Several headline statements claim more than the body proves.** These are: "necessary" (the $K(\mathrm{dom}\,D)$ term), "and no better" (Answer to H1(a)), "normalising makes it order-dependent" (as a statement about SFI), and "Hänni's Thm 1 (template): proved".

---

## 1. What I did

* Re-ran `checks/c1`–`c6` on scratch copies (Python 3.11.15, numpy 2.4.6, scipy 1.17.1). All six output files are byte-identical to the saved ones.
* Read Hänni's sources (`prior/hanni-sfi-notes.md`, `prior/hanni-sfi-draft-2025-09.txt`), the brief, and the other tracks' notes where they use foundations results (cross-track remarks in §6).
* Wrote ten independent checks:

| script | target in notes | result |
|---|---|---|
| `r1_tau_blocks_exact.py` | Ex 2.4, Thm 3.5(iii) | Two-input example: Möbius sum $-1$. $\tau^{\otimes k}$ weak for $k=1,2,3$ (27, 1458, 59049 one-point inequalities; 0 violations). The explicit law "uniform over $g_1\supseteq E_1$, $g_2\supseteq E_2$, $g_3\supseteq E_3$" and its $k$-fold product attain $\min_D P(F\supseteq D)/\tau^{\otimes k}(D)=(2/3)^k$ exactly for $k=1,\dots,4$, so the LP of c1 is not needed (m6). The $3^k$ sets $E_{\vec\imath}$ are pairwise inconsistent ($k\le4$). |
| `r2_lemma31_intervals.py` | Lemma 3.1 (proved, not computed by the track) | The construction ($\mu_t$, $\mu'_t$, top-down allocation), run literally with exact rationals on 60 random semimeasures on $\{0,1,2\}^{\le3}$ over 14 stages: 0 invariant violations (nesting, sibling disjointness, $\lambda(I_t(s))=\mu'_t(s)$, growth, dyadic endpoints, $\mu'_t\le\mu$); final $\lambda(I(s))=\mu(s)$ in 60/60 runs. |
| `r3_trimming_thm34.py` | Thm 3.4 (proved, not computed) | Weak $\varphi$ ($\tau$ and 40 random containment functionals): no freezing, limit $=\varphi$ exactly. 200 random non-weak $\varphi$: 88 freeze; the limit is weak in all 200; 0 stage-invariant violations. Lemma 3.1's rounding claim: 0 monotonicity violations in 20000 random sequences. |
| `r4_moebius_and_intervals.py` | Prop 2.3 sufficiency; Prop 3.3(c) | From $\nu$ alone, the Möbius sums rebuild the exact cylinder law of 40 random laws, and the rebuilt containment equals $\nu$. **200 of 200 random weak semimeasures have a negative Möbius sum**: weak semimeasures are generically not random-function laws, which supports Ex 2.4. The interval machine of Prop 3.3(c) has nesting, tiling, lengths $q_k(v)$ and level-consistent labels on 40 random laws. |
| `r5_tape_length_bound.py` | M2 | $\nu^{(L)}(D)$ is nondecreasing in $L$ and reaches $\nu(D)$ on 30 random shared-tape machines (all $3^5$ data sets). Lookup table: $\Pr_w[\varphi_w\supseteq D]=2^{-\lvert D\rvert}$ for every $D$ on $\{0,1\}^{\le2}$, $L=7,8,9$. Prefix-code lengths illustrate the three description costs (hash, lookup, tower). |
| `r6_merging_rule_sees_F.py` | Thm 6.5 and its remark | Mixture $\tfrac12U+\tfrac12Z$ (bound 1 bit). Past-only rule: $\sum_t\mathbb E d_t=\mathbb E\log U/M\le1$ (0.9991 at $N=14$). Rule that sees $F$: $\sum_t\mathbb E d_t=12.48$ at $N=14$, while the pathwise maximum stays exactly 1.000. This confirms both parts of the remark. |
| `r7_operator_induction_noisy.py` | Prop 6.8, Thm 6.7(b), M1 | Fresh-noise i.i.d. data, 27-law class (bound $\log_227=4.755$). Per-query mixture: expected regret 2.69 and worst pathwise regret 4.46 at $n=20$, both below the bound for all $n\le20$. Per-input (random-function) mixture: data consistent with probability 0.004 at $n=20$ (otherwise infinite loss). Stamped random-function mixture equals the per-query mixture exactly on 2000 sequences. |
| `r8_normalisation_and_swap.py` | Prop 5.3, Ex 6.4 | Normalised loss order-dependent for 300/300 random partial laws and 0/300 total laws; normalised $\ge$ semimeasure probability always. The notes' $\rho_1$ is reproduced. Swap data: the shared-randomness law $F(x)=x\oplus r$ gives exactly $2^{-n}$ for every pair, $n=2..6$ (m7). |
| `r9_supervised_bounds.py` | Thm 6.7(a), Prop 6.8, Prop 4.5 | Exact Bayes mixture over 32 Boolean functions with non-uniform $\pi$, $n\le6$: $\mathbb EL_n\le K$, $\mathbb ER(\bar Q_n)\le K/n$ and the 0–1 bound hold for 3 targets. Prop 6.8's bound: 0 violations in 7500 cases. Prop 4.5's counting inequality: 0 violations in 2000 instances. |
| `r10_hash_independent.py` | Prop 4.4 hashing | Different field and modulus ($\mathrm{GF}(2^5)$, $x^5+x^2+1$), restricted to the 31 embedded points of $\{0,1\}^{\le4}$: exact $j$-wise uniformity for $k=2,3$. |

* Checked references with WebSearch (snippets only; arxiv.org, hutter1.net and raysolomonoff.com do not resolve here). See §5.

---

## 2. Fatal issues

None.

---

## 3. Major issues

### M1. H7, Prop 6.8 and the operator-induction identification: the per-query mixture satisfies H7 as intended

* **Claims.**
  * §4: "$M_{\rm prod}$ is how I formalise Solomonoff's *operator induction*". F36: "$M_{\rm prod}$ matches Solomonoff's operator induction (unverified match)".
  * Summary 5(v), Prop 6.8, F31: "H7 as stated is refuted for noisy labels".
  * §6.7: H7 needs repairs (stamps or frozen noise).
* **Problem.**
  * $M_{\rm prod}(D)=\sum_im(i)\prod_{(x,y)\in D}P_i(y\mid x)$ is defined on *data sets*, which are partial functions. So a repeated input is counted once, and a repeated input with a different label has probability 0.
  * Operator induction, as secondary sources describe it, is $\sum_ja_j\prod_{i\le n}O^j(A_i\mid Q_i)$ over *all* question–answer pairs. Repeated questions with different answers are allowed. In other words it is a **per-query** product mixture, and it is not the law of a random function.
    * Sources: Özkural, arXiv 1504.03303 and 1709.03879 (snippets). The context track's §6 has the same recollection. Solomonoff 2008's abstract says "unordered set of ordered pairs". Primary text not checked (unverified).
  * The per-query mixture satisfies H7 in its intended regret form (Prop R4 below). It does so on every sequence, with noisy labels and repeated inputs, and without stamps.
  * So Prop 6.8 is a fact about random-function SFI ($M_F$, $M_{\rm prod}$ on sets, $W$). It is not a fact about "Solomonoff-style supervised learning". The notes present it as a refutation of H7 without this distinction.
  * The identification in F36 is wrong in exactly the respect that matters for H7.
* **Evidence.**
  * `r7`: on fresh-noise data the per-query mixture's regret stays below $\log_2|{\rm class}|$, both pathwise and in expectation.
  * The per-input mixture has infinite loss with probability $1-0.004$ at $n=20$.
  * The stamped random-function mixture of Thm 6.7(b) *equals* the per-query mixture on stamp-ignoring classes. So stamps are a way of rebuilding per-query randomness inside $M_F$.
* **Proposition R4 (per-query mixture) [proved, referee].**
  * *Definition.* Let $(P_i)$ enumerate the lower-semicomputable conditional semimeasures, and put $S(y_{1:n}\|x_{1:n}):=\sum_im(i)\prod_{t\le n}P_i(y_t\mid x_t)$.
  * *Claims.*
    * (i) $S$ is a lower-semicomputable chronological semimeasure and depends only on the multiset of pairs.
    * (ii) For every sequence, with repeats and arbitrary labels allowed: $-\log S(y_{1:n}\|x_{1:n})\le\sum_t-\log P(y_t\mid x_t)+K(P)+O(1)$.
    * (iii) For i.i.d. pairs from $\pi\times P$ with $P$ computable and $\pi$ arbitrary, the expected regret is at most $K(P)+O(1)$. The Cesàro predictor $\bar q_n=\frac1n\sum_{t\le n}S(\cdot\mid x,z_{<t})$ has $\mathbb E\,\mathbb E_\pi\mathrm{KL}(P\|\bar q_n)\le(K(P)+O(1))/n$. For non-computable $P$ one gets the resolvability bound of Thm 6.7(b).
    * (iv) On sequences with distinct inputs, $S=M_{\rm prod}$.
  * *Proof.*
    * (i) $\sum_{y_n}S(y_{1:n}\|x_{1:n})=\sum_im(i)\prod_{t<n}P_i(y_t\mid x_t)\sum_{y_n}P_i(y_n\mid x_n)\le S(y_{<n}\|x_{<n})$. Products commute, which gives the multiset claim. Lower semicomputability is clear.
    * (ii) Keep only the term for $P$: $S\ge m(i_P)\prod_tP(y_t\mid x_t)$, and $m(i)\ge2^{-K(i)}$.
    * (iii) Take expectations of (ii). Then argue exactly as in the proof of Thm 6.7(b): the $t$-th term of the telescoped sum is $\mathbb E\,\mathbb E_\pi\mathrm{KL}(P\|q_t)$ because $x_t\sim\pi$ is independent of the past; then use convexity of KL.
    * (iv) By definition. $\square$
* **Fix.**
  * Correct F36: $M_{\rm prod}$ is the restriction of the per-query mixture to data with distinct inputs. Operator induction (if the secondary sources are right) is the per-query mixture.
  * Restate Prop 6.8 as "random-function SFI cannot model fresh label noise". Add Prop R4 as the positive counterpart.
  * In §6.7, present three objects:
    * random-function SFI ($M_F$): ideal when labels are a (possibly random) function of the input;
    * per-query SFI (operator induction): ideal under fresh noise, but it cannot use shared randomness;
    * stamped $M_F$: dominates both up to constants on stamped data.
  * State H7 in regret form ("cumulative expected log loss at most $K(P)$" ignores the entropy term).

### M2. §4 (Prop 4.4, Problem 4.6, Remark after Prop 4.3, answer to Hänni §2.2): deterministic programs lose only the cost of naming the number of random bits

* **Claims.**
  * Prop 4.4: $W(D)\ge2^{-|D|-K(n,k)-c}$ for binary labels via $k$-wise hashing.
  * Verification log: "H1(b): ... for fair-coin labels the hint 'log factor via k-wise hashing' is confirmed, giving $K(n,k)+O(1)$".
  * Remark after Prop 4.4: general product laws "not carried out".
  * Remark after Prop 4.3: the 2-point gap is "at most $K(n)+O(1)$", with no rate.
  * Problem 4.6(b,c): open.
  * Answer to §2.2: "The reason is ... that a random tape can separate any two inputs at constant cost, while a fixed program must be chosen in advance."
* **Problem.** A deterministic program can *store a finite piece of the random tape*. The weight of all such programs sums the fair-coin measure over the stored string. The only cost is a self-delimiting description of the stored length $L$, and $L$ can be padded to any larger number of small complexity. This gives a much stronger and more general bound with a one-line proof. Hashing is unnecessary, and its seed-length description $K(n,k)$ is strictly worse than the lookup table's $K(n)$.
* **Proposition R1 (tape-length bound) [proved, referee].**
  * *Definition.* Let $T$ be a function machine with law $\nu$. For $L\in\mathbb N$ let $\nu^{(L)}(D):=\lambda\{\omega:\ \text{every }(x,y)\in D\text{ has some }(x,w',y)\in T\text{ with }w'\sqsubseteq\omega_{1:L}\}$.
  * *Claims.*
    * $\nu^{(L)}(D)$ is nondecreasing in $L$ and tends to $\nu(D)$.
    * For all $D\ne\emptyset$ and all $L'\ge L$: $W(D)\ \ge\ 2^{-K(T)-K(L')-c}\,\nu^{(L)}(D)$, with $c$ independent of $T,D,L,L'$.
    * Hence, with $L_{1/2}(T,D):=\min\{L:\nu^{(L)}(D)\ge\nu(D)/2\}$: $-\log W(D)\ \le\ -\log\nu(D)+K(T)+\kappa(L_{1/2}(T,D))+c+1$, where $\kappa(N):=\min_{L\ge N}K(L)$.
  * *Proof.*
    * *Deterministic programs from tape prefixes.* For $w\in\{0,1\}^L$ put $\varphi_{T,w}(x):=y$ if some $(x,w',y)\in T$ has $w'\sqsubseteq w$. This is well defined, because two such $w'$ are comparable and $T$ is consistent. It is partial computable, with an index computable from (an index of $T$, $w$).
    * *A prefix machine.* $V'$ reads a shortest $V$-program for an index of $T$, then a shortest $V$-program for $L'$, then $L'$ bits $w$, and outputs an index of $\varphi_{T,w}$. Its domain is prefix-free.
    * *Weight.* By universality $V(rq)=V'(q)$ for a fixed $r$. So $W(D)\ge\sum_{w\in\{0,1\}^{L'}}2^{-|r|-K(T)-K(L')-L'}[\varphi_{T,w}\supseteq D]$.
    * *Evaluation.* $\varphi_{T,w}\supseteq D$ iff $w$ certifies every pair of $D$. The fraction of such $w$ is $\nu^{(L')}(D)\ge\nu^{(L)}(D)$. Monotonicity holds because a certificate inside $\omega_{1:L}$ lies inside $\omega_{1:L'}$.
    * *Limit.* $f_\omega\supseteq D$ iff some finite prefix certifies all of $D$ (take the longest of the $|D|$ witnesses), so $\nu^{(L)}(D)\uparrow\nu(D)$.
    * Choosing $L'$ to minimise $K(L')$ over $L'\ge L$ gives the last claim. $\square$
* **Corollary R2 (lookup table) [proved, referee].**
  * For labels in $\{0,1\}$ and $\mathrm{dom}\,D\subseteq\{0,1\}^{\le n}$, take the $O(1)$-complexity machine $F(x)=\omega_{j(x)}$, with $j$ the length-lexicographic index. Its certificates lie in $\omega_{1:2^{n+1}}$, so $\nu^{(2^{n+1})}(D)=2^{-|D|}$. Hence
  $$W(D)\ \ge\ 2^{-|D|-\kappa(2^{n+1})-c},\qquad \kappa(2^{n+1})\le K(\lceil\log_2(n+1)\rceil)+O(1)\le K(n)+O(1),$$
  using $L'=2^{2^{m}}$ with $m=\lceil\log_2(n+1)\rceil$.
  * This is independent of $|D|$ and strictly stronger than Prop 4.4 (note $K(n,k)\ge K(n)-O(1)$).
  * With Thm 6.3(a): if $K(D\mid\mathrm{dom}\,D)\ge|D|-d$, then $\log(M_F(D)/W(D))\le\kappa(2^{n+1})+d+O(1)$.
* **Lemma R3 ($\kappa$ grows more slowly than the logarithm of every computable unbounded function) [proved, referee].**
  * *Claim.* Let $g$ be computable, nondecreasing and unbounded. Then $\kappa(N)\le2\log_2(g(N)+1)+O_g(1)$.
  * *Proof.*
    * Put $k:=g(N)+1$ and $N_k:=\min\{N':g(N')\ge k\}$. Then $N_k>N$, and $N_k$ is computable from $k$, so $K(N_k)\le K(k)+O_g(1)$.
    * So $\kappa(N)\le K(k)+O_g(1)\le2\log_2k+O_g(1)$. $\square$
  * *Consequences for the notes.*
    * The two-point gap of Prop 4.3 tends to infinity, but by Cor R2 it is at most $\kappa(2^{n+1})+O(1)$. That is slower than $\log$ of any computable unbounded function, e.g. $\le2\log_2\log^*n+O(1)$.
    * The notes' own lower bound $\log(1/\tau_V(\ell_n))$, with $\ell_n\approx\log n$, is of the same "minimum of $K$ over a tail" type. Programs "$V$-code of $N$, then $N$ free bits" give $\tau_V(\ell)\ge2^{-\kappa(\ell)-O(1)}$, so the lower bound is $\le\kappa(\ell_n)+O(1)\le\kappa(2^{n+1})+O(1)$, consistent with the upper bound.
    * This answers most of Problem 4.6(c) for the two-point gap, up to the threshold ($\log n$ vs $2^{n+1}$) inside $\kappa$.
* **Evidence.**
  * `r5` checks the combinatorial facts: monotonicity of $\nu^{(L)}$; $\Pr_w[\varphi_w\supseteq D]=\nu^{(L)}(D)$; and the lookup identity $2^{-|D|}$.
  * The cost terms ($K$ of the descriptions) are not computable. `r5(c)` only illustrates them with Elias-omega code lengths, e.g. at $n=k=10^9$: hash 82, lookup 41, tower 11 bits. These numbers are upper bounds up to additive constants, nothing more.
* **What it changes.**
  * The brief's hint "(b) may need to pay roughly $K(\mathrm{dom}\,D)$, or a log factor via hashing": neither is the right scale. The deterministic program mixture is within $K(T)+\kappa(L_{1/2})$ of every machine law, and $\kappa$ is sub-logarithmic in every computable sense.
  * The $K(\mathrm{dom}\,D)$ bound of Thm 4.2 is the right *general* bound only because $L_{1/2}(T_U,D)$ is not bounded computably in $(n,|D|)$. Whether it can be is exactly what remains of Problem 4.6(b).
  * The Remark after Prop 4.4 (general lower-semicomputable product laws "not carried out") is settled by Prop R1: $-\log W(D)\le\sum_{(x,y)\in D}-\log P(y\mid x)+K(P)+\kappa(L_{1/2})+O(1)$.
  * The informal answer to §2.2 should read: "a fixed program must commit to how many random bits it stores; naming that number costs $\kappa(L)$". It is not that "a fixed program cannot separate inputs": with stored random bits it separates them at cost $\kappa(2^{n+1})$.
* **Fix.**
  * Replace Prop 4.4 by Prop R1 and Cor R2 (keep hashing, if at all, as a remark).
  * Update the Remark after Prop 4.3, Problem 4.6(b,c), the Summary item 3, and the verification-log verdict on H1(b).
  * Problem 4.6(a) ($K_F$ versus $-\log W$) is untouched by this: R1 concerns the mixture, not the single shortest program.

### M3. Headline statements that claim more than the body proves

* **(a) "which is necessary"** (Summary 5(i)), "and this is necessary" (§6.1), F21 "correct with $+K(\mathrm{dom}\,D_n)$".
  * Thm 3.5(iii) shows only that *some unbounded* term is needed. On witnesses $D_k$ the gap is $\ge k\log\frac32-K(k)-O(1)$. Since $K(\mathrm{dom}\,D_k)\le k\log3+O(\log k)$, this is at least about $0.37\,K(\mathrm{dom}\,D_k)-O(\log k)$.
  * Nothing shows that the full $K(\mathrm{dom}\,D_n)$ is needed; the notes' own "How tight is (iii)?" says so.
  * *Fix:* "cannot be replaced by $O(1)$; on some data at least a constant fraction of $K(\mathrm{dom}\,D)$ is needed".
* **(b) "They agree up to $2^{K(\mathrm{dom}\,D)+O(1)}$ and no better (Thm 3.5)"** (Answer to H1(a)). Same problem.
  * *Fix:* "and not up to a constant".
* **(c) Summary 4: "Normalising each prediction lowers the loss but makes it order-dependent (Prop 5.3)."**
  * Prop 5.3(b) is about a toy law, and §5 says that order dependence for $M_F$ itself "is not settled here". So the Summary asserts for SFI what is shown only for some random partial functions.
  * "Lowers" should be "does not increase".
  * `r8` confirms that order dependence needs partiality: 300/300 random partial laws are order-dependent, and 0/300 total laws.
  * *Fix:* "can make it order-dependent (for random partial functions; open for $M_F$)".
* **(d) F23: "Hänni's 'Thm 1 (template)' for x-only computable samplers: proved".**
  * Hänni's template quantifies over "any data distribution". For a data distribution that samples from $P$ with fresh randomness per query and repeats inputs, SFI's loss is infinite (Prop 6.8). The template as stated is therefore false for SFI.
  * What is proved is the per-input reading on consistent sequences, which §6.1 does say.
  * *Fix:* mark F23 "proved for consistent sequences (randomness per input); false as stated for per-query sampling (Prop 6.8); true for the per-query mixture (Prop R4)".

---

## 4. Minor issues

* **m1. Stale cross-references.**
  * §6.3 ("the correct general form of (iii) in the brief") and the verification log ("(iii)", "(iv)") refer to items the brief does not contain. They seem to come from an earlier version of the brief.
  * *Fix:* point to H1/H2 or to the summary item.
* **m2. "a Ramsey argument" (Summary 3)** for Prop 4.3. It is a pigeonhole argument.
* **m3. Prop 4.3 is weaker than necessary for $Y=\{0,1\}^*$, the notes' default.**
  * The context track (Prop 5.4(2)) proves $M_F/W$ unbounded already on *one-point* data sets with $n$-bit labels. Two points are needed only for binary labels.
  * *Fix:* state both, and align the tracks.
* **m4. Example 6.4 is not tight as stated, and §6.7 cites it for the wrong conclusion.**
  * *Upper bound.* The $O(1)$-complexity machine $F(x)=x\oplus\omega_{1:|x|}$ gives the swap data probability exactly $2^{-n}$ (`r8`), so $-\log M_F(D)\le n+O(1)$.
  * *Lower bound.* Choosing $x_2$ with $K(x_2\mid x_1)\ge n-1$ (by counting, for each $x_1$) instead of $K(x_1,x_2)\ge2n$ gives $-\log M_F(D)\ge n-O(1)$. So $-\log M_F(D)=n\pm O(1)$ for suitable pairs.
  * *Not a separation.* A history-aware predictor shown $x_1$ first must also pay $K(x_2\mid x_1)\approx n$ for the first label. So Example 6.4 shows only that $K(D\mid\mathrm{dom}\,D)$ is a poor lower bound, not that "predictors that use the list of past inputs are not dominated" (§6.7, "Comparator class").
  * *Fix:* use the chain or skipped-string examples (history track) for that claim.
* **m5. Remark after Thm 6.2.** "A pixel permutation of complexity comparable to the data size changes losses by that much." Only the upper bound $K(\alpha,\beta)+O(1)$ is proved.
  * *Fix:* "can change losses by up to that much".
* **m6. Thm 3.5 remark ("exact for $k\le3$, computed").** The product of the explicit three-function law attains $(2/3)^k$ for *every* $k$, and the disjointness argument gives the matching upper bound. So the LP is redundant and "for $k\le3$" understates (`r1`).
* **m7. §6.7 item 1: "machine laws weighted by $2^{-K}$".** The weights are $m(i)$ ($\ge2^{-K(i)}$), and machine laws are lower semicomputable, not "computable labellers".
* **m8. "Weak semimeasures are exactly the order-independent online predictors" (§2, F1).**
  * The correspondence is between weak semimeasures with $\nu(\emptyset)=1$ and predictors, identified when they agree off null histories. Different predictors can agree on all histories of positive $\nu$-probability.
  * *Fix:* state the normalisation and the identification.
* **m9. Prop 5.2's "for every weak semimeasure".** For $x\in\mathrm{dom}\,D$, $D+(x,y)$ is undefined, so a convention is needed: "repeated input: factor 1 for the stored label, 0 otherwise". The same applies to $M^w$.
* **m10. Thm 6.5 proof, integrability.** "Take expectations (tower property; all conditional expectations are nonnegative)" skips one step.
  * The log-ratio terms $Z_t$ may have infinite positive part a priori. The argument needs $\mathbb E[Z_t^-\mid\mathcal F_{t-1}]\le\log_2e$ (from $p\log(q/p)\le q\log_2e$ termwise), so that $\sum_t\mathbb EZ_t=\mathbb E\sum_tZ_t\le K(\nu)$ follows by monotone convergence.
  * *Fix:* add that sentence. The result is unaffected.
* **m11. Prop 7.2 relies on an unverified citation** (Hutter 2005, ch. 5) for the existence and dominance of $\xi$.
  * The trimming proof of Thm 3.4 adapts verbatim to chronological semimeasures: trim on finite prefixes of action/percept sequences.
  * *Fix:* add two lines and make §7 self-contained.
* **m12. H1(b) formalisation choice not stated.**
  * $W$ uses programs that self-delimit *before* seeing the input. The literal "$\sum_{p\text{ consistent with }D}2^{-|p|}$" with a conditional prefix machine $V(p,x)$ is a different object. Its total mass $\sum_p2^{-|p|}$ over all programs can exceed 1, because $\{p:V(p,x)\!\downarrow\}$ is prefix-free only for each fixed $x$. So it is not a prior over functions.
  * *Fix:* say why $W$ is the right reading (one sentence). The context track's Prop 5.4(2) remark makes the same point.
* **m13. Verification log, "Things I did not check by computer".** Lemma 3.1, Thm 3.4, Prop 2.3 (sufficiency) and Prop 3.3(c) are now checked by `r2`–`r4`. The track may cite them, or add its own.
* **m14. Bibliographic gaps** (§5): missing full data for Levin 1974, Gács 1974, Chaitin 1975; Barzdin–Freivalds pages.

---

## 5. References

| reference (as in notes) | status after my search |
|---|---|
| Solomonoff 2008, *Comput. J.* 51(5):566–570 | Bibliographic data confirmed (DBLP, Utah bib index; DOI 10.1093/comjnl/bxm120). Abstract: third kind = "unordered set of ordered pairs". Operator-induction formula only from secondary sources (Özkural, arXiv 1504.03303, 1709.03879; snippets): product over *all* pairs (see M1). Full text unverified. |
| Gács 1983, *TCS* 22:71–93 | Confirmed (DBLP; FOCS 1981 version, pp. 296–303). Snippets confirm $Km-KM$ unbounded. Content otherwise unverified. |
| Barzdin–Freivalds 1972, *Soviet Math. Dokl.* 13 | Confirmed: pp. 1224–1228 (Russian original: *Dokl. Akad. Nauk SSSR* 206(3):521–524). Add pages. Content unverified. |
| Levin 1974 / Gács 1974 / Chaitin 1975 (coding theorem, symmetry of information) | Standard. Full bibliographic data not given in the notes; add them. Unverified here. |
| Li–Vitányi 3rd ed. §4.3, §4.5 | Section numbers unverified (flagged correctly by the track). |
| Hutter 2005, ch. 5 ($\xi$) | Unverified. Not reachable. See m11 for removing the dependence. |
| Zvonkin–Levin 1970; Solomonoff 1978; Leike–Hutter ALT 2015; Blumer et al. 1987; McAllester 1999; Barron–Cover 1991; Barron 1998; Vovk 1990; Cesa-Bianchi–Lugosi 2006; Littlestone 1988, 1989; Cesa-Bianchi–Conconi–Gentile 2004; Wegman–Carter 1981 | Bibliographic data match my knowledge. Not checked against sources (unverified, as the track says). |

**Missing references (all unverified; snippets only).**
* **L. A. Levin, "Occam bound on lowest complexity of elements", *Ann. Pure Appl. Logic* 167(10):897–900, 2016 (arXiv 1403.4539), and S. Epstein, L. A. Levin, "Sets have simple members", arXiv 1107.1458 (2011).**
  * Per the abstracts, $-\log m(S)$ and $\min_{x\in S}K(x)$ differ by at most about $I(S:\mathcal H)$, the information of $S$ about the halting sequence.
  * This is the natural tool for Problem 4.6(a): $W(D)=m(S_D)$ and $K_F(D)=\min_{e\in S_D}K(e)$ for $S_D=\{e:\varphi_e\supseteq D\}$. It is closer than the analogy with Gács's $Km$ vs $KM$.
  * Caveat: the result is stated for finite sets, so applying it to the infinite c.e. set $S_D$ needs care.
* **Hutter 2005, ch. 6, "supervised learning from examples (EX)"** (the AIXI treatment of learning functions from examples; numbering differs between the book and the 2000/2007 reports). This is prior work for "SFI as ideal supervised learning" (§6.7). Content unverified; the context track also notes it as unread.

---

## 6. Important questions the track missed or under-treated

1. **Per-query versus per-input randomness (M1).** Hänni's x-only samplers are naturally per query. The foundations track fixes per-input as "the right reading". The paper needs both, and their relation (stamps).
2. **The tape-length bound (M2).** This is the precise version of the brief's "log factor" hint. It also gives a cleaner answer to "Kolmogorov vs semimeasure versions".
3. **What lower bounds transfer to the normalised predictor.**
   * Every lower bound in the notes (Thm 6.3(a), Ex 6.4) and in the examples and history tracks is for $-\log M_F(D)$ (semimeasure convention). Foundations is the place to say what transfers. Two easy facts:
     * (i) If the input order does not depend on the labels, the normalised product $\bar P(y_{1:n}\|x_{1:n})$ is a probability on label sequences. Gibbs then gives $\mathbb E[\text{loss}]\ge H(\text{labels}\mid x_{1:n})$.
     * (ii) The normalised conditionals are $0'$-computable (Prop 7.3(d)). The relativised coding theorem then gives, pathwise, $-\log\bar P(y_{1:n}\|x_{1:n})\ge K^{0'}(y_{1:n}\mid x_{1:n})-O(1)$ [proof sketch; relativised coding theorem known, unverified reference].
   * Neither fact helps when the order carries label information, as in H5 and H6. That is precisely where the question is open: can the normaliser $P(f(x_t)\!\downarrow\mid f\supseteq D_{t-1})$ extract information from the order? The notes should state this sharply.
4. **Problem 3.6 framing.**
   * A sufficient condition is easy to prove [proof sketch, referee]. Suppose $\nu=\lim_s\nu_{Q_s}$ for computable finite laws $Q_s$ in which each $Q_{s+1}$ arises from $Q_s$ by *filling in* undefined values on sub-masses. Then $\nu$ is a machine law exactly: realise the atoms by dyadic regions and fill in by splitting regions.
   * So Problem 3.6 asks whether every lower-semicomputable containment functional admits such a fill-in approximation up to a constant factor. Stating it this way would sharpen the "obstacle" paragraph.
5. **Tightness of the dominance constant in Thm 6.1.**
   * Thm 6.3(a) gives a matching lower bound for deterministic targets with a finite domain $S$, once all of $S$ is queried: $L\ge K(\varphi\mid S)-O(1)$.
   * Also $K(\varphi)\le K(S)+K(\varphi\mid S)+O(1)$. So $K(\varphi)$ is attained up to $K(S)+O(1)$, e.g. up to $K(n)+O(1)$ for $S=\{0,1\}^n$.
   * One sentence would make Thm 6.1 two-sided in this sense.

---

## 7. Cross-track remarks

* **History track, §"Kolmogorov vs semimeasure versions":** "With prefix-free deterministic programs, labels that are random bits cost an extra ≈ K(n)". For the *mixture* over such programs this is too large. The padding argument of Prop R1 gives at most $\kappa(n)+O(1)$. For the single shortest program the statement may stand.
* **Context track, Prop 5.4(2):** consistent with foundations, and stronger than Prop 4.3 for long labels (m3).
* **Context track, Cor 5.2:** conditions on "H1(a)", which foundations refutes for the weak reading (Thm 3.5(iii)); the context referee also flags this. The two tracks should use the same statement: $M_F$ dominates machine laws, and weak semimeasures only up to $K(\mathrm{dom}\,D)$.
* **Steeper track:** relies on $M_{\rm prod}$-type hypotheses, i.e. product laws on sets. Under M1 it should check whether it needs per-input or per-query private randomness. The teacher's-mistakes setting has a fixed teacher function with fixed errors, i.e. frozen noise, so per-input looks right; it should say so.

---

## 8. Claims I confirmed

Each was checked line by line; script references where I also computed.

* **§2.**
  * Def 2.1 consequences (a), (b).
  * Prop 2.3, both directions; the sufficiency half and the Kolmogorov-extension consistency identity were also computed in `r4`.
  * Example 2.4, both parts (`r1`).
  * Prop 2.6.
  * The effective enumeration of function machines.
* **§3.**
  * Lemma 3.1 (`r2`).
  * Thm 3.2, including the consistency of $T_U$ and the exact formula $M_F=\sum_im(i)\nu_{T_i}$ on $D\ne\emptyset$.
  * Prop 3.3(a)–(d); (c) also in `r4`.
  * Thm 3.4 (`r3`).
  * Thm 3.5(i)–(iii), with the constant $k\log\frac32-K(k)-O(1)$ (`r1`).
* **§4.**
  * Thm 4.2, all five steps; step (2) uses the universality of $m$ correctly.
  * Prop 4.3 (pigeonhole).
  * Prop 4.4 as stated (correct, but superseded; M2; hashing also checked in `r10`).
  * Prop 4.5: compactness, subsequence and counting steps, with the counting inequality checked in `r9`.
* **§5.**
  * Prop 5.2.
  * Prop 5.3(a), and (b) for partial laws (`r8`).
* **§6.**
  * Thm 6.1(a)–(c) (with M3(a) on wording).
  * Thm 6.2(a)–(c), including lower semicomputability of the transformed weak semimeasures (preimages under $\alpha,\beta$ are c.e.).
  * Thm 6.3(a)–(c).
  * Example 6.4 as stated (but see m4).
  * Thm 6.5 (`r6`, plus m10).
  * Cor 6.6.
  * Thm 6.7(a)–(c) (`r9` for (a); `r7` for the stamped form of (b)).
  * Prop 6.8, including the closed-form bound (`r9`).
  * The Occam derivation in §6.6.
* **§7.**
  * Prop 7.1 (both machines are correct).
  * Prop 7.2 (given $\xi$; see m11).
  * Prop 7.3(a)–(d); the diagonal argument in (c) is correct for both conditionals.

---

## 9. Summary of requested changes

1. M1: correct the operator-induction identification, add Prop R4, and restate Prop 6.8 and §6.7 with three objects (random-function SFI, per-query SFI, stamped SFI).
2. M2: replace Prop 4.4 by Prop R1/Cor R2/Lemma R3. Update the Remark after Prop 4.3, Problem 4.6(b,c), Summary 3, the H1(b) verdict and the answer to Hänni §2.2.
3. M3: fix the four overstatements (Summary 4, Summary 5(i)/§6.1/F21, Answer to H1(a), F23).
4. Minor fixes m1–m14; add the missing references in §5 (marked unverified).
5. Add the normalised-convention paragraph (§6, item 3) for the other tracks to cite.
