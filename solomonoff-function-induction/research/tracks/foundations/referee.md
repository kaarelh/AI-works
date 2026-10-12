# Referee report: track "foundations" (second pass)

*Adversarial referee for `notes.md` and `checks/` of the foundations track (brief items H1, H2, H7, invariance, and Hänni's later request on the Kolmogorov and universal-semimeasure versions). I did not edit the notes.*

*This report replaces the earlier version of `referee.md`. That first pass wrote `referee_code/r1`–`r10`. I re-ran them; all ten outputs are byte-identical to the saved ones. Every claim I take from them below I re-derived myself, and I say where I disagree with the first pass. My new scripts are `referee_code/r11`–`r13`. Each is deterministic or seeded (seed 20261012) and writes `<name>_output.txt` next to itself.*

---

## 0. Verdict

* **No fatal issues.** I checked every proof marked [proved] line by line. I looked for hidden hypotheses, wrong constants, quantifier order, measure versus semimeasure, conditional versus unconditional complexity, and dropped logarithmic terms. I found no false inequality and no broken proof. Three proofs need an extra line (m4, m8, m9).
* **The scripts reproduce.** `checks/c1`–`c7` reproduce byte for byte (Python 3.11.15, numpy 2.4.6, scipy 1.17.1). `c7` is not mentioned in `notes.md` (m15).
* **Four major issues.** None makes a proved statement false. All four change what the paper should say.
  * **M1. Problem 4.6(a) can be settled, and the answer is stronger than the conjecture.** The shortest-program ("Kolmogorov") version $K_F$ and the program mixture $W$ differ by an unbounded amount already on two-point data sets with binary labels. On those data sets $-\log W(D)\le\log_2K_F(D)+O(\log\log K_F(D))$, so there is no coding theorem for function programs even up to a constant *factor*. Against $M_F$, the two-point gap of $K_F$ is $\Theta(\log n)$ for $n$-bit inputs. The proof is three lines (Prop A below). This answers the open part of Hänni's §2.2 question.
  * **M2. The gap between $W$ and $M_F$ is much smaller than the notes say** (first pass, verified). A deterministic program can store a stretch of the random tape. It then pays only for naming the stretch's length, which can be padded to a number of small complexity. For fair-coin labels the cost is at most $K(\lceil\log_2(n+1)\rceil)+O(1)$, independent of $|D|$. This supersedes Prop 4.4 (hashing), settles the Remark after Prop 4.4, and gives rates for Problem 4.6(c).
  * **M3. Per-input versus per-query randomness** (first pass, verified). `notes.md` identifies $M_{\rm prod}$ with Solomonoff's operator induction. As secondary sources describe it, operator induction is a *per-query* product mixture. That mixture satisfies the regret form of H7 under fresh label noise, with no stamps. Prop 6.8 refutes H7 only for random-function SFI. The history track (its claim 4.9) already uses the per-query reading, while the context track (X53) uses the notes' reading.
  * **M4. Several headline statements claim more than the body proves.** These are: "necessary" for the $K(\mathrm{dom}\,D)$ term; "and no better"; "normalising makes it order-dependent" (said of SFI); the hashing verdict in Summary 3; and the stated reason for the §2.2 gap.
* **Missed questions** (§5). The most important is what the lower bounds mean under the normalised convention. I give an exact two-point criterion for order-independence of normalised losses (Prop B, computed in `r13`).

---

## 1. What I did

* Read the brief, Hänni's sources (`prior/hanni-sfi-notes.md`, `prior/hanni-sfi-draft-2025-09.txt`), `notes.md` in full, all seven check scripts, and the parts of the other tracks' current notes that use foundations results (§6).
* Re-ran `checks/c1`–`c7` and `referee_code/r1`–`r10` on scratch copies. All 17 output files are byte-identical.
* Read each check script against the claim it supports. They compute what the notes say they compute. One exception: `c7` appears to come from a later revision attempt; it refers to a `notes-final.md` that does not exist (m15).
* Wrote three new scripts:

| script | target | result |
|---|---|---|
| `r11_kf_two_point_covering.py` | M1 (Prop A, A3) | Exact maximum-clique search. For $N=3,\dots,8$ binary functions, the largest number of inputs on which every pair shows all four label patterns is $1,3,4,10,15,35$. This equals Kleitman–Spencer's $\binom{N-1}{\lfloor N/2\rfloor-1}$ in every case. Allowing partial functions does not help ($N\le5$). So $2^n$ inputs need $N_{\min}=4,5,6,8,8,10,11$ functions for $n=1,\dots,7$, above the pigeonhole bound $n/\log_23$. Greedy coverings of labelled $k$-sets ($M=8,16$; $k=2,3$) use 8–22 functions, between $2^k$ and the union bound. |
| `r12_last_iterate_risk.py` | Thm 6.7(a); Q4 | Exact finite analogue (all Boolean functions on 2–5 inputs, i.i.d. inputs, inclusion–exclusion over seen sets). Cumulative bound $\sum_{t<n}\mathbb E R(Q_t)\le K$ holds in all 301 instances. The averaged-predictor bound $\mathbb E R(\bar Q_n)\le K/n$ holds in every case checked. The expected risk of the posterior predictive is **not monotone** in $t$ in 63 of 300 random instances. No instance violated $\mathbb E R(Q_n)\le K/(n+1)$ (largest ratio 0.87). |
| `r13_normalised_two_point_criterion.py` | Prop 5.3; Q1 (Prop B) | Exact rationals, 3 labels. Prop B's criterion agrees with order-independence of the normalised probability on 300/300 random laws (all fail both). 300/300 laws built to satisfy the criterion are order-independent. The notes' $\rho_1$ fails it ($P(B\mid F(a)=0)=1/2\ne2/3=P(B\mid A)$) and gives $2/3$ versus $1/2$. 100/100 total laws satisfy both. |

* Checked references with WebSearch (snippets only; arxiv.org and journal sites do not resolve here). See §7.

---

## 2. Fatal issues

None.

---

## 3. Major issues

### M1. Problem 4.6(a) and Hänni's §2.2: the shortest program is far from the program mixture

* **Claims.**
  * Problem 4.6(a), F17, Summary 3: "Whether $-\log W=K_F+O(1)$ is [open]"; "conjectured false".
  * Remark after Prop 4.3 and Problem 4.6(c): no rates for the two-point gaps.
  * Answer to Hänni §2.2: the gap is "between unbounded and $K(\mathrm{dom}\,D)+O(1)$".
* **Problem.** Problem 4.6(a) has a short proof, and it gives explicit rates. The track has the needed pieces: Prop 4.3's colouring argument, kept with its length bound, and the lookup-table bound of M2.
* **Proposition A (referee) [proved].** Let $\{0,1\}\subseteq Y$ and $n\ge2$. There are distinct $x_1,x_2\in\{0,1\}^n$ such that $D:=\{(x_1,0),(x_2,1)\}$ satisfies
  * (i) $K_F(D)\ \ge\ \log_2n-2$;
  * (ii) $-\log_2W(D)\ \le\ 2+K(\lceil\log_2(n+1)\rceil)+c$;
  * (iii) $-\log_2M_F(D)\ \le\ 2+c$;

  with $c$ independent of $n$. Hence
  $$K_F(D)+\log_2W(D)\ \ge\ \log_2n-K(\lceil\log_2(n+1)\rceil)-c-4\ \to\ \infty,$$
  and on these data sets $-\log_2W(D)\le\log_2K_F(D)+O(\log\log K_F(D))$.
* *Proof.*
  * (i) Put $g:=\lceil\log_2(n/\log_23)\rceil-1$, so $2^g<n/\log_23$. Let $E:=\{V(p):p\in\mathrm{dom}\,V,\ |p|<g\}$; then $|E|<2^g$. Colour $x\in\{0,1\}^n$ by $(\chi_e(x))_{e\in E}\in\{0,1,*\}^E$, where $\chi_e(x)=\varphi_e(x)$ if this is $0$ or $1$ and $*$ otherwise. There are at most $3^{|E|}<3^{2^g}<2^n$ colours. So two distinct $x_1,x_2$ share a colour. Then no $e\in E$ has $\varphi_e(x_1)=0$ and $\varphi_e(x_2)=1$, so $K_F(D)\ge g\ge\log_2n-\log_2\log_23-1>\log_2n-2$.
  * (ii) Put $m:=\lceil\log_2(n+1)\rceil$ and $L:=2^{2^m}\ge2^{n+1}$. Let $j$ be the length-lexicographic index, so $j(x)\le2^{n+1}-2<L$ for $|x|\le n$. Let $V'$ read a shortest $V$-program for $m$, compute $L$, read $L$ further bits $w$, and output an index of $\varphi_w:x\mapsto w_{j(x)}$ (undefined if $j(x)\ge L$). $\mathrm{dom}\,V'$ is prefix-free. By universality $V(rs)=V'(s)$ for a fixed string $r$. The programs $rqw$ are distinct elements of $\mathrm{dom}\,V$, so
  $$W(D)\ \ge\ \sum_{w\in\{0,1\}^L}2^{-|r|-K(m)-L}\,[\varphi_w\supseteq D]\ =\ 2^{-|r|-K(m)}\Pr_w[w_{j(x_1)}=0,\ w_{j(x_2)}=1]\ =\ 2^{-|r|-K(m)-2}.$$
  * (iii) The uniform product law, as in Prop 4.3.
  * For the last claim: by (i), $\log_2n\le K_F(D)+2$, so $m\le K_F(D)+4$. Then $K(m)\le\log_2m+2\log_2\log_2m+O(1)$. $\square$
* **Corollary A2 (two-point rates against $M_F$) [proved].** For every two-point $D$ with binary labels and inputs in $\{0,1\}^{\le n}$, $K_F(D)\le K(n)+\log_2(n+2)+O(1)$ (Prop A3 with $k=2$). With (i) and (iii): the largest two-point gap between the "Kolmogorov version" $2^{-K_F}$ and $M_F$ on $n$-bit inputs lies between $\log_2n-O(1)$ and $K(n)+\log_2n+O(1)$. Against $W$ the two-point gap of $M_F$ is at most $K(\lceil\log_2(n+1)\rceil)+O(1)$ (by (ii); see M2).
* **Proposition A3 (covering bound for single programs) [proved].** For every $D$ with binary labels, $|D|=k$ and $\mathrm{dom}\,D\subseteq\{0,1\}^{\le n}$:
  $$K_F(D)\ \le\ k+\log_2\big(k(n+2)\big)+K(n,k)+O(1).$$
  * *Proof.* There are at most $\binom{2^{n+1}-1}{k}2^k\le2^{k(n+2)}$ such data sets. Put $N:=\lfloor2^kk(n+2)\ln2\rfloor+1$. $N$ independent uniform truth tables on $\{0,1\}^{\le n}$ all miss a fixed $D$ with probability $(1-2^{-k})^N<e^{-N2^{-k}}\le2^{-k(n+2)}$. By the union bound, some family of $N$ truth tables covers every such $D$. The lexicographically first such family is computable from $(n,k)$ by exhaustive search. A program consists of a $V$-program for $(n,k)$ and a $\lceil\log_2N\rceil$-bit index, and it outputs an index of the chosen member. $\square$
  * *Consequence.* With Thm 6.3(a): if $K(D\mid\mathrm{dom}\,D)\ge|D|-d$, then $K_F(D)\le-\log M_F(D)+d+\log_2(k(n+2))+K(n,k)+O(1)$. So the brief's "log factor via $k$-wise hashing" is right for the **single shortest program**, via covering rather than hashing. The program mixture needs no log factor (M2).
* **Evidence.**
  * `r11` checks the combinatorial core exactly on small cases. The minimum number of functions that 2-cover $2^n$ inputs is Kleitman–Spencer's (exact for $N\le8$) and exceeds the pigeonhole bound used in (i). Greedy coverings for $k=2,3$ sit between $2^k$ and the union bound of A3.
  * The complexity terms are not computable, so nothing about them is computed.
* **What it changes.**
  * Problem 4.6(a) is answered: **no**. The notes' conjecture is correct. The gap is not only unbounded, it is not bounded by any constant multiple of $-\log W$.
  * The analogy with Gács's $Km$ versus $KM$ understates the function case. For sequences the gap is known to be at most logarithmic in $Km$ (secondary snippet, unverified: $Km\le KM+2\log Km+O(1)$). Here $K_F$ can be exponentially larger than $-\log W$.
  * The answer to §2.2 should distinguish three objects:
    * the shortest program $K_F$: worse than $M_F$ by $\Theta(\log n)$ already on two points;
    * the program mixture $W$: worse than $M_F$ by an unbounded amount (Prop 4.3), but only by $O(K(\log n))$ on fair-coin labels (M2);
    * $M_F$.
* **Witnesses cannot be explicit.** This also bears on the brief's request for "an unbounded gap with an explicit example". Two facts [proved, referee]:
  * If $k\mapsto D_k$ is computable, then $K_F(D_k)\le K(k)+O(1)$. All five quantities lie between $2^{-K_F(D_k)}$ and $1$, so they agree on $D_k$ up to $K(k)+O(1)$ bits. A gap that grows faster than $K(k)$, as in Thm 3.5(iii), therefore needs a non-computable family.
  * Suppose each $D_n$ is computable from the length $n$ of its inputs, as an explicit choice of the pairs in Props 4.3 and A would be. Then one program reads $n$ from its input and outputs the labels, so $K_F(D_n)=O(1)$ and all five quantities agree up to $O(1)$. So the pairs in Props 4.3 and A cannot be chosen computably.
  * The paper should say this, rather than present the non-constructive witnesses as missing constructions. Whether Prop 4.5's gap can be witnessed computably, within the $K(k)$ budget, is open.
* **Fix.**
  * Add Prop A, Cor A2 and Prop A3. Mark Problem 4.6(a) and F17 as solved (refuted, with rates).
  * Rewrite the answer to §2.2 with the three-way distinction.
  * Add the remark on non-computable witnesses.
  * Cite Kleitman–Spencer only as the exact two-point covering number (unverified; computed in `r11`). The proof needs only the pigeonhole bound.

### M2. The program mixture loses only the cost of naming a padded tape length (first pass, verified)

* **Claims.**
  * Prop 4.4 and F14: $W(D)\ge2^{-|D|-K(n,k)-c}$ via $k$-wise hashing.
  * Verification log: "the hint 'log factor via $k$-wise hashing' is confirmed, giving $K(n,k)+O(1)$".
  * Remark after Prop 4.4: general product laws "not carried out".
  * Remark after Prop 4.3: the two-point gap is at most $K(n)+O(1)$, with no rate.
  * Problem 4.6(b,c): open.
* **Problem.** The first pass's Proposition R1 is correct. I re-derived it.
  * For a function machine $T$ with law $\nu$, put $\nu^{(L)}(D):=\lambda\{\omega:$ every pair of $D$ is certified by some triple of $T$ inside $\omega_{1:L}\}$.
  * Then for all $D\ne\emptyset$ and all $L'\ge L$: $W(D)\ge2^{-K(T)-K(L')-c}\nu^{(L)}(D)$, with $c$ independent of $T,D,L,L'$.
  * *Proof.* The programs "index of $T$; shortest program for $L'$; $L'$ bits $w$" output $\varphi_{T,w}(x):=y$ whenever some $(x,w',y)\in T$ has $w'\sqsubseteq w$. This is well defined because $T$ is consistent. Summing over $w$ gives weight $2^{-|r|-K(T)-K(L')}\nu^{(L')}(D)$, and $\nu^{(L')}\ge\nu^{(L)}$. Also $\nu^{(L)}\uparrow\nu$: $f_\omega\supseteq D$ is certified by a finite prefix (the longest of $|D|$ witnesses). $\square$
  * Write $\kappa(N):=\min_{L\ge N}K(L)$. For fair-coin labels, take $F(x)=\omega_{j(x)}$. Then $W(D)\ge2^{-|D|-\kappa(2^{n+1})-O(1)}$ and $\kappa(2^{n+1})\le K(\lceil\log_2(n+1)\rceil)+O(1)$. This is independent of $|D|$, and stronger than Prop 4.4 since $K(n,k)\ge K(n)-O(1)$.
  * The first pass's Lemma R3 is also correct: for every computable nondecreasing unbounded $g$, $\kappa(N)\le2\log_2(g(N)+1)+O_g(1)$. *Proof:* $N_k:=\min\{N':g(N')\ge g(N)+1\}>N$ is computable from $g(N)+1$.
* **Consequences I checked.**
  * Prop 4.3 (the two-point gap $M_{\rm prod}/W$): at most $\kappa(2^{n+1})+O(1)$. By R3 this grows more slowly than the logarithm of any computable unbounded function of $n$.
  * Prop 4.5 (the $\sigma$ gap $M_F/M_{\rm prod}$): certificates for inputs of length at most $n$ lie in $\omega_{1:n+1}$. So $M_{\rm prod}\ge W\ge2^{-\kappa(n+1)-O(1)}\sigma$ on such data. The compactness witnesses therefore give a gap of at most $\kappa(n_k+1)+O(1)$. This is new relative to the first pass; it gives the upper half of Problem 4.6(c) for Prop 4.5.
  * Remark after Prop 4.4: settled by R1 with a data-dependent $\kappa(L_{1/2})$ term.
  * The general bound $K(\mathrm{dom}\,D)$ of Thm 4.2 remains the only one established for arbitrary $D$, because the tape length $T_U$ needs is not computably bounded in $(n,|D|)$. That is what remains of Problem 4.6(b).
* **Evidence.** `r5` (first pass, re-run) checks monotonicity of $\nu^{(L)}$ on 30 random shared-tape machines and the lookup identity $\Pr_w[\varphi_w\supseteq D]=2^{-|D|}$. The $\kappa$ terms are not computable.
* **Fix.**
  * Replace Prop 4.4 by R1 and its lookup corollary; keep hashing, if at all, as a remark.
  * Correct the verification-log verdict on H1(b): the hashing hint is right for $K_F$ (M1, Prop A3), not for $W$.
  * Update the Remark after Prop 4.3, the Remark after Prop 4.5, Problem 4.6(b,c) and Summary 3.

### M3. Per-input versus per-query randomness: operator induction and H7 (first pass, verified)

* **Claims.**
  * §4 and F36: "$M_{\rm prod}$ is how I formalise Solomonoff's *operator induction*".
  * Summary 5(v), Prop 6.8, F31: "H7 as stated is refuted for noisy labels".
  * §6.6: "SFI has the resolvability bound (b)".
* **Problem.**
  * $M_{\rm prod}$ is defined on data *sets*. A repeated input counts once, and a repeated input with another label gets probability 0.
  * Operator induction, as secondary sources write it, is $\sum_ja_j\prod_{i\le n}O^j(A_i\mid Q_i)$: the product runs over the $n$ question–answer pairs, and nothing merges repeated questions. That is a per-query mixture $S$. Sources: Özkural, arXiv 1709.03879 (snippet confirms the product over pairs). Solomonoff 2008's abstract says "unordered set of ordered pairs". Primary text not checked.
  * Facts about $S$ [proved; first pass's R4, re-derived]. $S(y_{1:n}\|x_{1:n}):=\sum_im(i)\prod_tP_i(y_t\mid x_t)$ is a lower-semicomputable chronological semimeasure. It depends only on the multiset of pairs. It equals $M_{\rm prod}$ on sequences with distinct inputs, and is $\le M_{\rm prod}$ on consistent sequences with repeats. On *every* sequence, $-\log S\le\sum_t-\log P(y_t\mid x_t)+K(P)+O(1)$. So it satisfies the regret form of H7 under fresh noise directly.
  * The track's own `c7` (written later) computes all of this on a 133-law class, and shows stamped per-input mixtures equal $S$ exactly. `r7` (first pass) shows the same on fresh-noise data.
  * So Prop 6.8 is a fact about random-function SFI ($M_F$, $W$, and $M_{\rm prod}$ on sets). It is not a fact about Solomonoff-style supervised learning.
* **Where I disagree with the first pass.** The first pass called F23 ("Hänni's Thm 1 (template) proved") an overclaim. Hänni's notes state the setting as "input-output pairs from a function $f:X\to Y$ revealed". Data from a function are consistent sequences, and on those Thm 6.1(a) proves the template. F23 needs its hypothesis stated (m14), not a downgrade.
* **Fix.**
  * Correct F36: $M_{\rm prod}$ is the restriction of the per-query mixture to distinct inputs.
  * Restate Prop 6.8 as "random-function SFI cannot model fresh label noise". Add $S$ as the positive counterpart.
  * In §6.6 say that the resolvability bound needs stamps (Thm 6.7(b)) or per-query mixing.
  * Align with the history track's claim 4.9 and the context track's X53, which currently disagree (§6).

### M4. Headline statements that claim more than the body proves

* **(a) "this is necessary"** (§6.1), "which is necessary" (Summary 5(i)), F21 "correct with $+K(\mathrm{dom}\,D_n)$".
  * Thm 3.5(iii) shows only that some unbounded term is needed. On its witnesses the gap is $\ge k\log\frac32-K(k)-O(1)$, while $K(\mathrm{dom}\,D_k)\le k\log3+O(\log k)$.
  * *Fix:* "cannot be replaced by $O(1)$; on some data at least a constant fraction (about 0.37) of $K(\mathrm{dom}\,D)$ is needed".
* **(b) "They agree up to $2^{K(\mathrm{dom}\,D)+O(1)}$ and no better (Thm 3.5)"** (Answer to H1(a)). Same problem.
  * *Fix:* "and not up to a constant".
* **(c) Summary 4: "Normalising each prediction lowers the loss but makes it order-dependent".**
  * Prop 5.3(b) is about toy laws, and §5 itself says order dependence for $M_F$ "is not settled here".
  * "Lowers" should be "does not increase". For total laws normalisation changes nothing (`r8`, `r13`).
  * Prop B (§5, Q1) gives the exact two-point condition.
  * *Fix:* "can make it order-dependent (for random partial functions; open for $M_F$)".
* **(d) Summary 3: "For fair-coin labels the gap is at most $K(n,|D|)+O(1)$".**
  * Prop 4.4 bounds $W$ against the fair-coin law $2^{-|D|}$, not against $M_F$. Against $M_F$ the incompressibility deficiency $d$ must be added.
  * The bound is superseded anyway (M2).
* **(e) Answer to §2.2: "The reason is ... that a random tape can separate any two inputs at constant cost, while a fixed program must be chosen in advance."**
  * For $W$ this is misleading: with stored tape bits $W$ separates two $n$-bit inputs at cost $O(K(\log n))$ (M2).
  * For $K_F$ it is right, and quantitatively $\log_2n-O(1)$ (M1).
  * *Fix:* rewrite as in M1.

---

## 4. Minor issues

* **m1. Thm 6.5, parenthetical "For finite $Y$ these are exactly the computable such laws".** It holds for every countable $Y$ [proved, referee].
  * A lower-semicomputable law of a random total function is computable. The induction $\nu(D+(x,y))=\nu(D)-\sum_{y'\ne y}\nu(D+(x,y'))$ works with an infinite sum, which is still lower semicomputable.
  * Conversely, for a random total function $q_S(v)=\nu(v)$ if $v$ has no $\bot$ and $0$ otherwise. So computable $\nu$ gives computable cylinder probabilities, and Prop 3.3(c) applies for any countable $Y$.
  * *Fix:* drop "finite"; in "Status of H2" add "all computable laws of random total functions, any countable $Y$".
* **m2. Example 6.4 is tight, and §6.7 cites it for the wrong conclusion.**
  * The $O(1)$-complexity machine $F(x)=x\oplus\omega_{1:|x|}$ gives the swap data probability exactly $2^{-n}$ (`r8`). So $-\log M_F(D)\le n+O(1)$, and also $K_F(D)\le K(x_1\oplus x_2)+O(1)\le n+2\log n+O(1)$.
  * Choosing $x_2$ with $K(x_2\mid x_1)\ge n$ (counting, for each $x_1$) gives $-\log M_F(D)\ge n-O(1)$. So $-\log M_F(D)=n\pm O(1)$ for suitable pairs.
  * A history-aware predictor shown $x_1$ first also pays $K(x_2\mid x_1)\approx n$ for the first label. So Ex 6.4 shows only that $K(D\mid\mathrm{dom}\,D)$ is a poor lower bound. It does not show that "predictors that use the list of past inputs are not dominated" (§6.7, "Comparator class").
  * *Fix:* cite the history track's chain or skipped-string examples for that.
* **m3. Thm 3.5 remark and F9: "LP tightness of $(2/3)^k$ for $k\le3$ computed".** The uniform law on the three total functions $(a,b,c)=(0,1,0),(1,0,1),(1,0,0)$ attains $\tfrac23\tau$. Its $k$-fold product attains $(2/3)^k\tau^{\otimes k}$, and the counting argument gives the matching upper bound. So $(2/3)^k$ is exact for every $k$ [proved; `r1` checks $k\le4$]. The LP is redundant, and "for $k\le3$" understates.
* **m4. Thm 6.5 proof, integrability.** "Take expectations" skips a step.
  * Add: $\mathbb E[Z_t^-\mid\mathcal F_{t-1}]\le\log_2e$ termwise (from $\log x\le(x-1)\log_2e$). Since $\sum_tZ_t\le K(\nu)$ pathwise, every $\mathbb EZ_t^+$ is then finite and linearity applies.
  * Also say that the input rule must be measurable. The result is unaffected.
* **m5. Summary 3: "a Ramsey argument"** (Prop 4.3). It is a pigeonhole argument.
* **m6. Prop 4.3 is weaker than necessary for the default $Y=\{0,1\}^*$.** $M_F/W$ is unbounded already on one-point data sets with $n$-bit labels (context track, Prop 5.4). A counting argument over short programs, as in Prop 4.3, applies to the $2^n$ possible labels of the single input $0^n$. *Fix:* state both.
* **m7. §6.7 item 1: "machine laws weighted by $2^{-K}$".** The weights are $m(i)\ge2^{-K(i)}$. Machine laws are lower semicomputable, not "computable labellers".
* **m8. F1 and §2 "Predictor reading": "Weak semimeasures are exactly the order-independent online predictors".** The telescoped product is $\nu(D)/\nu(\emptyset)$. So the correspondence holds for $\nu(\emptyset)=1$, with predictors identified when they agree on histories of positive probability. *Fix:* state both.
* **m9. Prop 5.2, "for every weak semimeasure".** For $x\in\mathrm{dom}\,D$, $D+(x,y)$ is undefined, so a convention is needed: factor 1 for the stored label, 0 otherwise. The same applies to $M^w$, $W$ and $M_{\rm prod}$.
* **m10. Stale labels.** §6.3 ("the correct general form of (iii) in the brief") and the verification log ("(iii)", "(iv)") refer to items of the track prompt, not the brief. *Fix:* point to Thm 6.3 and Thm 6.5 directly.
* **m11. Prop 7.2 rests on an unverified citation** (Hutter 2005, ch. 5) for the existence of $\xi$. The history track now *defines* the universal chronological semimeasure as $M_H$, the law of a universal history-oracle function machine, and proves its universality. *Fix:* cite that, or adapt Thm 3.4's trimming to chronological semimeasures in two lines.
* **m12. Remark after Thm 6.2: "A pixel permutation ... changes losses by that much".** Only the upper bound $K(\alpha,\beta)+O(1)$ is proved. *Fix:* "can change losses by up to that much".
* **m13. Prop 3.3(a): "this covers every 'computably samplable predictor' in Hänni's sense".** A probabilistic machine run on each query naturally draws fresh randomness per *query*. The notes' choice of per-*input* randomness is the right one for function data, but the sentence should say it is a choice (M3).
* **m14. F23.** Add the hypothesis: "for data from a function (consistent sequences)", which is Hänni's own setting (M3).
* **m15. `checks/c7_per_query_mixture.py` is not referenced by `notes.md`.**
  * Its docstring cites `notes-final.md` Def 4.1, Prop 6.9 and "referee item M1", which do not exist in the current notes.
  * The verification log says "all six scripts".
  * *Fix:* when the revision is written, cite `c7` from the per-query statement (M3) and update the log.
* **m16. Definition of $W$.** $W$ uses programs that self-delimit *before* seeing the input. Summing $2^{-|p|}$ over conditional prefix programs $V(p,x)$ is a different object: its total mass need not be $\le1$, because $\{p:V(p,x)\!\downarrow\}$ is prefix-free only for each fixed $x$. *Fix:* one sentence saying why $W$ is the right reading.
* **m17. Bibliographic gaps** (§7). Full data are missing for Levin 1974, Gács 1974 and Chaitin 1975, and pages for Barzdin–Freivalds.

---

## 5. Important questions the track missed or under-treated

* **Q1. Which lower bounds hold under the normalised convention?**
  * Every lower bound in the notes (Thm 6.3(a), Ex 6.4), and in the examples and history tracks (H5, H6, the chain), is for $-\log M_F(D)$. Normalised losses are smaller (Prop 5.3(a)), so these bounds do not transfer automatically. Foundations is the place to say this, because §5 recommends the semimeasure convention.
  * **Proposition B (referee) [proved; computed: `r13`].** Let $P$ be a random-partial-function law on inputs $a,b$. Write $A=\{F(a)\!\downarrow\}$ and $B=\{F(b)\!\downarrow\}$, and assume $P(A),P(B)>0$. Consider the condition
  $$P(B\mid F(a)=\alpha)=P(B\mid A)\ \ \forall\alpha\qquad\text{and}\qquad P(A\mid F(b)=\beta)=P(A\mid B)\ \ \forall\beta .$$
    * (i) If the condition holds, the normalised probability of $\{(a,\alpha),(b,\beta)\}$ is the same in both reveal orders for every $(\alpha,\beta)$.
    * (ii) Conversely, suppose every two-point probability $P(F(a)=\alpha,F(b)=\beta)$ is positive, as it is for $M_F$. If the two orders agree for every $(\alpha,\beta)$, the condition holds.
  * *Proof.* Put $u(\alpha):=P(B\mid F(a)=\alpha)/P(B)$ and $v(\beta):=P(A\mid F(b)=\beta)/P(A)$. Both normalised products contain the factor $P(F(a)=\alpha,F(b)=\beta)$. When it is positive, comparing the remaining factors shows that the two orders agree exactly when $u(\alpha)=v(\beta)$. When it is $0$, both products are $0$.
    * (ii) Agreement on all pairs forces $u\equiv v\equiv c$. Averaging $u$ over $\alpha$ with weights $P(F(a)=\alpha)/P(A)$ gives $c=P(A\cap B)/(P(A)P(B))$, which is the condition.
    * (i) The condition gives $u\equiv P(A\cap B)/(P(A)P(B))\equiv v$. $\square$
  * Without positivity, (ii) can fail. For example, if the labels at $a$ and $b$ are perfectly correlated when both are defined, only the diagonal pairs constrain $u$ and $v$.
  * In words, the normaliser leaks order information exactly when whether one input is defined says something about another input's label. Total laws always pass. The notes' $\rho_1$ fails.
  * Whether $M_F$ passes is open. Since every $M_F(D)$ is positive, it fails as soon as some pair $(a,b)$ violates the condition. That seems likely but is unproved.
  * Two easy general facts (first pass) belong here too:
    * if the input order does not depend on the labels, the normalised product is a probability on label sequences, so its expected loss is at least the conditional entropy of the labels;
    * the normalised conditionals are $0'$-computable, so a relativised coding theorem gives $-\log\bar P\ge K^{0'}(y_{1:n}\mid x_{1:n})-O(1)$ [proof sketch].
  * Neither fact helps when the order carries label information, as in H5 and H6. That is where the question matters.
* **Q2. The comparison table the later request asks for.** For each pair the paper should state: equal up to a constant, witness and rate of the gap, upper bound, and what is open. With M1 and M2 the table is:

| comparison | equal up to $O(1)$? | gap: lower bound (witness) | gap: upper bound | open |
|---|---|---|---|---|
| $2^{-K_F}$ vs $W$ | **no** (Prop A) | $\ge\log_2n-O(K(\log n))$ on two points | $K(\mathrm{dom}\,D)+O(1)$; binary labels with $k$ points: $d+\log_2(k(n+2))+K(n,k)+O(1)$, where $d=k-K(D\mid\mathrm{dom}\,D)$ (A3 and Thm 6.3(a)) | general rate |
| $W$ vs $M_{\rm prod}$ | no (Prop 4.3; one point: context Prop 5.4) | $\log(1/\tau_V(\ell_n))$, non-explicit | two points, binary labels: $\kappa(2^{n+1})+O(1)$; general: $K(T)+\kappa(L_{1/2})$ against any machine law (M2) | $O(K(n,\lvert D\rvert))$ in general (4.6(b)) |
| $M_{\rm prod}$ vs $M_F$ | no (Prop 4.5) | unbounded, no rate | $\sigma$-data: $\kappa(n+1)+O(1)$ (M2); general: $K(\mathrm{dom}\,D)$ | rate |
| $M_F$ vs $M^w$ | no (Thm 3.5) | $\ge k\log\frac32-K(k)$ on $2k$ points | $K(\mathrm{dom}\,D)+O(1)$ | closeness to $K(\mathrm{dom}\,D)$ |
| $M_F$ vs lsc random-function laws | ? | — | $K(\mathrm{dom}\,D)$ | Problem 3.6 |
| $M_{\rm prod}$ vs per-query $S$ | equal on distinct inputs | — | — | — |

  * The table should come with M1's remark that witnesses of super-$K(k)$ gaps cannot be computable.
* **Q3. What the gaps mean for prediction** (the later request asks for this explicitly).
  * Because cumulative loss is order-free, a gap of $g$ bits between two of these objects on $D$ is exactly a difference of $g$ bits in cumulative log loss, in every reveal order. Per-step predictions can differ more at some steps and less at others.
  * Concretely:
    * the program mixture predicts fair-coin data almost as well as $M_F$ (within $O(K(\log n))$ bits in total);
    * the single-shortest-program code length $K_F(D)$ exceeds $-\log M_F(D)$ by $\Theta(\log n)$ on some two-point sets. $2^{-K_F}$ is not a semimeasure, so this is a statement about description length (MDL with one program), not about the loss of a sequential predictor;
    * the weak universal semimeasure can beat $M_F$ by a linear amount on structured data that no random function produces.
  * The track says only that "for deterministic computable targets the difference does not matter for the basic bounds".
* **Q4. Last iterate versus averaged predictor (H7).**
  * Thm 6.7(a) bounds the Cesàro average $\bar Q_n$, correctly. But the expected risk of SFI's actual posterior predictive is not monotone in the sample size: `r12` finds non-monotone examples in 63 of 300 random finite instances. So "more data never hurts in expectation" is false for a fixed target.
  * Whether $\mathbb ER(Q_n)\le(K+O(1))/(n+1)$ holds for the last iterate is open. No counterexample was found (largest ratio 0.87).
  * The paper should state the averaged predictor and should not suggest monotone improvement.
* **Q5. Prior work the track does not cite.** All unverified, snippets only.
  * Hutter 2005, ch. 6: "supervised learning from examples (EX)" in the AIXI framework. This is prior work for §6.7.
  * Levin, "Occam bound on lowest complexity of elements" (APAL 2016), and Epstein–Levin, "Sets have simple members" (arXiv 1107.1458). Per the abstracts, they bound $\min_{x\in S}K(x)$ by $-\log m(S)$ plus the information of $S$ about the halting sequence.
    * Since $W(D)=m(S_D)$ and $K_F(D)=\min_{e\in S_D}K(e)$ for $S_D=\{e:\varphi_e\supseteq D\}$, this is the natural frame for Prop A.
    * If their bound applies here, Prop A's witnesses must carry about $\log n$ bits of information about the halting sequence. That would fit their non-computability.
    * The result is stated for finite sets, so applying it to the infinite c.e. $S_D$ needs care.
  * Kleitman–Spencer 1973 on 2-independent families: the exact two-point covering number in `r11`.
  * Day 2011 (Trans. AMS 363:5577–5604): sharper $Km$ versus $KM$ gap.
* **Q6. Problem 3.6 framing (first pass).** A sufficient condition: the law is a limit of computable finite laws, each obtained from the previous one by *filling in* undefined values on sub-masses. Then it is a machine law exactly [proof sketch]. Stating the problem this way would sharpen the "obstacle" paragraph.

---

## 6. Cross-track remarks

* **History track** (`notes-final.md`):
  * Its claim 4.9 reads operator induction as a per-query mixture, and its claim 4.10 already uses the $\kappa$ bound for $W$. Foundations should align with both (M2, M3).
  * The history track defines the universal chronological semimeasure as $M_H$; Prop 7.2 should cite it (m11).
* **Context track** (`notes-final.md`):
  * Its X53 ("$M_{\rm prod}$ is Solomonoff's operator induction") conflicts with the history track's 4.9. Foundations should settle the wording once (M3).
  * Its Prop 5.4 (one-point gap of $W$) strengthens foundations Prop 4.3 (m6).
  * Several of its bounds use $2^{-K_F}$ as the lower estimate of $M_F$ or $W$ on the training set, e.g. Prop 2.16's $2^{K_F(f)-K(x^*\mid f)}$. Prop A shows that $K_F$ can exceed $-\log W$ and $-\log M_F$ by $\Theta(\log n)$ even on two points. So those bounds are valid but can be loose, and $K_F$ should not be described as interchangeable with $-\log W$.
* **Steeper track:** relies on product laws on sets, i.e. frozen per-input noise. The teacher's-mistakes setting is a fixed teacher function with fixed errors, so per-input is right. It should say so explicitly (M3).

---

## 7. References

| reference (as in the notes) | status after my search |
|---|---|
| Solomonoff 2008, *Comput. J.* 51(5):566–570 | Bibliographic data confirmed (Utah bib index). Abstract: third kind = "unordered set of ordered pairs". The product-over-all-pairs formula was seen only in Özkural, arXiv 1709.03879 (snippet). Full text unverified. |
| Gács 1983, *TCS* 22:71–93 | Confirmed (Utah bib index; FOCS 1981 short version, pp. 296–303). Snippets confirm $Km-KM$ unbounded. Add Day 2011 (*Trans. AMS* 363(10):5577–5604) for the sharper gap. |
| Zvonkin–Levin 1970; Solomonoff 1978; Li–Vitányi 2008 (section numbers); Hutter 2005 (ch. 5); Leike–Hutter ALT 2015; Blumer et al. 1987; McAllester 1999; Barron–Cover 1991; Barron 1998; Vovk 1990; Cesa-Bianchi–Lugosi 2006; Littlestone 1988, 1989; Cesa-Bianchi–Conconi–Gentile 2004; Wegman–Carter 1981 | Bibliographic data match my knowledge. Not checked against sources: unverified, as the track says. |
| Barzdin–Freivalds 1972, *Soviet Math. Dokl.* 13 | First pass found pp. 1224–1228. Add pages. Content unverified. |
| Levin 1974 / Gács 1974 / Chaitin 1975 | Standard, but the notes give no titles, volumes or pages. Add them. |
| Choquet, Matheron, Shafer (Prop 2.3 remark) | Analogy only; correctly flagged. |

**Missing references** (all unverified): Hutter 2005 ch. 6 (EX); Levin 2016 (*Ann. Pure Appl. Logic* 167(10):897–900, arXiv 1403.4539); Epstein–Levin (arXiv 1107.1458); Kleitman–Spencer, "Families of $k$-independent sets", *Discrete Math.* 6 (1973) 255–262; Day 2011.

---

## 8. Claims I confirmed

Each was checked line by line. Script references are where I or the first pass also computed.

* **§2.**
  * Def 2.1 consequences (a), (b).
  * Prop 2.3, both directions, including absolute convergence and the consistency identity for the Kolmogorov extension (`c6`, `r4`).
  * Example 2.4, both parts (`c1`, `r1`).
  * Prop 2.6.
  * The effective enumeration of function machines.
* **§3.**
  * Lemma 3.1 (rounding monotonicity, $\mu'_t\le\mu$, room argument; `r2`).
  * Thm 3.2, including consistency of $T_U$ and $M_F=\sum_im(i)\nu_{T_i}$ on $D\ne\emptyset$.
  * Prop 3.3(a)–(d); (c) also for infinite $Y$ with $J(v\bot)$ placed last.
  * Thm 3.4, including the frozen case (a frozen $\varphi'_{i,t-1}$ is weak because it vanishes outside $U_{t-1}$; `r3`).
  * Thm 3.5(i)–(iii), with the constant $k\log\frac32-K(k)-O(1)$.
* **§4.**
  * Thm 4.2, all five steps; step (2) uses the universality of $m$ correctly.
  * Prop 4.3.
  * Prop 4.4 as stated (correct but superseded; `c2`, `r10`).
  * Prop 4.5: compactness, the dichotomy $S_i=1\Rightarrow\alpha_i=\beta_i=\delta_{y_i}$, subsequence, and the count $\le\varepsilon+r^k+\varepsilon<4\varepsilon$.
  * Problem 4.6(a)'s conjecture (now proved; M1).
* **§5.**
  * Def 5.1 (the defect is the posterior probability of undefinedness).
  * Prop 5.2.
  * Prop 5.3(a), and (b) for $\rho_1$ (`c3`, `r8`, `r13`).
* **§6.**
  * Thm 6.1(a)–(c), with M4(a) on wording.
  * Thm 6.2(a)–(c), including lower semicomputability of transformed weak semimeasures and the transfer of one-point inequalities.
  * Thm 6.3(a)–(c).
  * Example 6.4 as stated (see m2).
  * Thm 6.5, with m1 and m4 (`c4`, `r6`).
  * Cor 6.6.
  * Thm 6.7(a)–(c) (`r9`, `r12` for (a); `c7`, `r7` for (b)).
  * Prop 6.8, including the closed-form bound (`c5`, `r9`).
  * The Occam derivation in §6.6.
* **§7.**
  * Prop 7.1 (both machines are consistent and correct).
  * Prop 7.2, given $\xi$ (m11).
  * Prop 7.3(a)–(d); the diagonal argument works for both conditionals.
* **Verification log.** The scripts compute what the log says, and the outputs reproduce byte for byte.

---

## 9. Summary of requested changes

1. **M1:** add Prop A, Cor A2 and Prop A3. Mark Problem 4.6(a) and F17 solved, with rates. Rewrite the §2.2 answer with the three-way distinction ($K_F$, $W$, $M_F$). Add the remark that super-$K(k)$ witnesses cannot be computable.
2. **M2:** replace Prop 4.4 by the tape-length bound. Update the Remarks after Props 4.3, 4.4 and 4.5, Problem 4.6(b,c), Summary 3 and the H1(b) verdict.
3. **M3:** correct F36. Restate Prop 6.8 for random-function SFI. Add the per-query mixture $S$ with its H7 bound, and cite `c7`.
4. **M4:** fix the five overstatements.
5. Minor fixes m1–m17.
6. Add Q1 (Prop B and the normalised-convention caveat), Q2 (the comparison table), Q3 (what the gaps mean for prediction) and Q4 (averaged versus last iterate).
7. Add the missing references, marked unverified.
