# Referee report: track "context"

*Adversarial referee for `notes.md` and `checks/` of the context track (brief items H8, H10, motivation, literature, extras). I did not edit the notes. My independent code is in `referee_code/` (seeded where random; each script writes `<name>_output.txt` next to itself).*

## 0. Verdict

* The mathematics in §§1–4 is largely sound. I checked every proof marked [proved] line by line. Apart from one interpretive error in §5 (M2), I found no wrong inequality, wrong constant or broken quantifier order.
* All five check scripts reproduce their saved outputs byte for byte. The headline numbers of c1 were reproduced by an independent implementation (r3).
* The main problems are elsewhere:
  * **Stale source.** The track did not use the Vaintrob–Hänni slides, which the brief says are available. As a result it declares open a problem the slides settle (M1), it misses a source for its kernel theorem (M3), and its "open" list for NN Bayes is out of date (M3).
  * **Wrong reading in §5.** The track reads Prop 5.1 as a characterisation of Bayesian random-function predictors. That is false for sub-probability predictors, and Cor 5.2's hypothesis is false (M2).
  * **Incomplete answer to H8.** The track's answer to the converse question omits a simple positive converse that follows from its own Prop 2.14 (M4).
  * **Overstated novelty.** Several "apparently new" items are known (M5).
* No fatal issues.

## 1. What I did

* Re-ran `checks/c1`–`c5` on scratch copies (numpy 2.4.6). All outputs are identical to the saved ones.
* Wrote seven independent checks (`referee_code/`):

| script | target | result |
|---|---|---|
| `r1_weak_function_semimeasure.py` | Prop 5.1 reading, Cor 5.2 | Weak function semimeasure with $k$ pairwise incompatible cylinders of total mass $k/2$; exhaustive one-step inequality check ($k=3,4,5$; 196 830 pairs for $k=5$); LP optimum of the domination constant $=2/k$ exactly ($k=3,4$); block version undominated by any random-partial-function law |
| `r2_occam_ladder.py` | Rem 3.10, open problem 5 | Occam on the conjunction ladder: formulas $2^d-1$ mistakes ($d=3,4,5$); circuits $2^d-O(d)$ ($d=3,4$); ladder lemma verified exhaustively |
| `r3_formula_bayes_independent.py` | Thm 3.5, Rem 3.6, 3.7, 3.10 | All c1 numbers reproduced (L ranges, max $L/m_{\min}=4.92$); float recursion vs exact fractions $9.7\cdot10^{-16}$; halving bound on every ordering; surgery constants $B(s)$ (circuits) and $B$ (formulas) for $d\le20$, $s\le200$ |
| `r4_walsh_krawtchouk.py` | Thm 4.6(a), Rem 4.8 | Exact (60-digit) Walsh eigenvalues via Krawtchouk sums, $d=10,20,40$: bias-free 2-layer NNGP/NTK odd eigenvalues $\le3\cdot10^{-63}$; nonzero with bias and for 3 layers; matches c2 at $d=10$ |
| `r5_constants.py` | Props 2.12, 2.13, 3.8, 3.9, 4.5, Thm 3.5; slides' warm-up | All constants hold; Prop 4.5 by brute-force enumeration of all circuits for $(d,S)=(1,2),(2,2),(3,2),(1,3)$ (up to 14.7M circuits); explicit constant $L\le52\,md\log_2(md+2)$ for Thm 3.5 |
| `r6_split_and_loo_exact.py` | Props 2.9, 2.10, Thm 2.7 | Exact over all 720 orders and split points, 40 random laws: identity error $8\cdot10^{-14}$; LOO bound holds |
| `r7_time_bounded_adversarial.py` | Thm 3.1(a) | Labels chosen adversarially against $S$, plus a second stream favouring one comparator: the bound holds for every comparator at every prefix; min slack 0.8 bits |

* Checked references with WebSearch. Snippets only; arxiv.org, ar5iv, neurips.cc and the ANU repository do not resolve here.
* Read the slides `prior/vaintrob-hanni-nnbayes-generalization-slides.txt` (Appendices A, F, J and K are relevant), the foundations and history track notes for cross-track consistency, and Hänni's source notes.

---

## 2. Major issues

### M1. Remark 3.10, summary item 10 and open problem 5: the "open" super-polynomial Occam lower bound is settled, by the slides and by the track's own data

* **Claim.**
  * Rem 3.10 says: "For natural languages a super-polynomial lower bound, or a polynomial upper bound, is **open**."
  * Summary item 10 says: "Out of distribution only the trivial bound $|H_f|-1=2^{O(\ell)}$ is known."
  * §7 lists this as open problem 5.
* **Problem.** The slides (Appendix K, "the conjunction ladder") give a natural construction. For a natural formula language they claim Occam's worst-case mistakes are $2^{\Theta(C/\log C)}$. The construction:
  * Target $f=x_1\wedge\dots\wedge x_d$.
  * Show $1^d$, then $0^d$, then all inputs in ascending Hamming weight, each level in the learner's tie order.
  * At stage $k$, the data say $h(1^d)=1$ and $h=0$ below weight $k$. By Möbius inversion every monomial of a consistent $h$ has degree $\ge k$. So every consistent $h$ reads $\ge k$ variables.
  * The cheapest survivors are therefore exactly the $\binom dk$ conjunctions of $k$ variables, and each mistake kills exactly one of them.
  * Total: about $2^d$ mistakes, while $f$'s description length is $\Theta(d\log d)$.
* **Evidence.**
  * r2 verifies the ladder lemma exhaustively. It holds for the notes' own formula language (Rem 3.6/c1: leaves $x_j,\neg x_j,0,1$; AND/OR/XOR; size = #leaves). It also holds for the notes' own circuit language (§3.2: all 16 gates; size = #gates; for $k\ge2$).
  * Occam with c1's tie rule makes $2^d-1$ mistakes for $d=3,4,5$ (formulas), and 4 and 11 mistakes for $d=3,4$ (circuits, $=2^d-O(d)$).
  * c1's own output already shows "Occam worst = 8" for the class $c=3$ at $d=3$, i.e. all 8 inputs. The notes dismissed this ("With 8 inputs these numbers say nothing about asymptotics").
  * Caveat: the slides warn that their appendices were largely machine-drafted and not fully reviewed. I checked the argument independently. It is correct for both of the track's languages.
* **Fix.**
  * Replace "open" by the theorem: worst-case Occam mistakes are $2^{\Omega(\ell/\log\ell)}$ for the formula and circuit languages of §3. This is matched by the trivial $2^{O(\ell)}$ upper bound.
  * Cite the slides (Appendix K) and give the Möbius proof.
  * Delete open problem 5, or restate it as the $\log\ell$ gap in the exponent.
  * Note the slides' complementary table: argmax $2^{\Theta(C/\log C)}$, randomised tie-breaking $\tilde\Theta(C^2)$, random consistent hypothesis $O(C)$, weighted majority $\le C$. The last row is the track's Rem 3.10 halving bound.

### M2. Prop 5.1 (title and reading), Cor 5.2 and summary bullet "SFI is the universal element of that class": wrong for sub-probability predictors

* **Claim.**
  * Prop 5.1 is titled "order-independent predictors are Bayesian predictors for random partial functions".
  * The reading says order independence "singles out exactly the Bayesian predictors over random (partial) functions".
  * Cor 5.2: "If $M_F$ dominates every lower-semicomputable function semimeasure (H1(a)), then SFI is universal among lower-semicomputable order-independent predictors."
* **Problem.**
  * The body of Prop 5.1 is correct as stated, but it uses the *weak* definition (one-step inequalities only). Weak function semimeasures need not be laws of any random partial function. Cylinders that are pairwise incompatible must have total mass $\le1$ under any such law, but can have arbitrarily large total under a weak semimeasure.
  * So the induced order-independent predictor is not Bayesian for any random partial function.
  * And no random-partial-function law, hence neither $M_F$ nor any $\mu_T$, dominates every computable weak semimeasure with a positive constant. Cor 5.2's hypothesis is false.
  * The universal element of the order-independent class is the universal weak semimeasure $M^w$, not $M_F$. This is what the foundations track finds (its Thm 3.4, Thm 3.5, Prop 7.2).
* **Evidence.**
  * r1 constructs, for each $k$, points $x_{ij}$ ($i<j<k$) and cylinders $D_i=\{x_{ij}\mapsto[i>j]\}$. It sets $\nu(\emptyset)=1$ and $\nu(D)=\tfrac12\#\{i:D\subseteq D_i\}$.
  * All one-step inequalities hold (exhaustive, $k=3,4,5$). The induced predictor is order independent. The $D_i$ are pairwise incompatible with $\sum_i\nu(D_i)=k/2$.
  * The LP optimum of $\max\{c:\exists\mu,\ \mu\ge c\nu\}$ is exactly $2/k$ ($k=3,4$).
  * The computable mixture $\sum_n2^{-n}\nu_n$ with $k_n=4^n$ (fresh points per block, uniform labels outside the block) has incompatible families of total mass $2^{n-1}$, so no random-partial-function law dominates it.
  * The foundations track reaches the same conclusion independently (its Ex 2.4 with $\tau$, Prop 2.3, Thm 3.5).
  * The two-point example $\nu(a{\to}0)=\nu(b{\to}0)=0.6$, $\nu(\text{both})=0$ is weak and order independent, but would need $P(f(a)=0\text{ or }f(b)=0)=1.2$.
* **Fix.**
  * Retitle Prop 5.1 "order-independent predictors = weak function semimeasures".
  * Keep the Bayesian reading only for (i) normalised predictors (random total functions, as in the last bullet of the proof), or (ii) weak semimeasures satisfying the foundations track's Möbius condition (its Prop 2.3).
  * Replace Cor 5.2 by: $M_F$ dominates every machine law (foundations Thm 3.2); $M^w$ is universal among lsc order-independent predictors; $M_F$ is not, since $M^w/M_F$ is unbounded (foundations Thm 3.5).
  * Correct summary §0 "Extras" accordingly.

### M3. The Vaintrob–Hänni slides are treated as unavailable (§4.5 placeholder); several statements are therefore stale

* **Claim.** §4.5: "⟦CITATION PENDING ... contents not available to this track. Nothing above describes or relies on their content.⟧"
* **Problem.** The brief says the slides are available (`prior/vaintrob-hanni-nnbayes-generalization-slides.{pdf,txt}`) and asks the paper to cite them for H10, stating only what they claim. Not reading them has concrete consequences:
  * (a) **Thm 4.6 is in the slides.** Appendix J has the $G$-invariance/character proof of Thm 4.6(a) and the trace-budget form of Thm 4.6(b) ("$\#\{S:\lambda_S\ge1/n\}\le n$ for any kernel"). It cites Kamath–Montasser–Srebro "Example 1", Yang–Salman, Donhauser–Wu–Yang (ICML 2021) and Ghorbani–Mei–Misiakiewicz–Montanari. The notes cite Kamath et al. as "Thm 19", which is unverified and conflicts with the slides' "Example 1".
  * (b) **M1** (Appendix K).
  * (c) **§4.3 and §4.5 "open" items.**
    * The slides claim that in the strong-prior regime ($\sigma\to0$, sigmoid MLPs of fixed depth) the NN Bayes prior tracks MLP-circuit complexity: $\kappa_N$ and $C_L$ are polynomially related, uniformly in width. They claim this gives $\mathrm{poly}(d,C)$ sample complexity.
    * They also state, under "Additional results" and next to an in-distribution online mistake bound, "the circuit complexity $C_L$ of the learned function is at most $\mathrm{poly}(d,\#\text{mistakes made while learning it})$". This is exactly the statement the notes call "unproved" when discussing Hänni's remark "true for NN bayes as well" (§4.3).
    * They list "give a lower bound on the log prior of a function" as open. That matches the notes' two-sided open problem only in part.
    * Infinite-width mean-field is claimed in arXiv 2607.05735 (snippet-verified).
  * (d) **The SFI warm-up** (prior $3^{-|p|}$, $n=O(C)$, 99.9%, probability $1-e^{-\Omega(C)}$) and the relevance-based bound (Appendix A) are the in-distribution counterparts of Prop 3.8 and Thm 2.7. I checked the arithmetic (r5(5)):
    * $3(2/3)^{3C+26}<3^{-C}/2000$ for all $C\ge0$;
    * the union-bound exponent gives exactly $e^{-C}$;
    * Appendix A's parameters reduce to $n=4000(\ln M+4)$ as claimed.
* **Fix.**
  * Replace the placeholder with an accurate, hedged summary of the slides' claims, with their caveats (machine-drafted appendices).
  * Withdraw any novelty claim for Thm 4.6.
  * Update §4.3/§4.5: the NN-Bayes "few mistakes ⇒ small circuit" direction is *claimed by the slides* in distribution. For circuits on every ordering it remains as in Thm 3.5.
  * Relate the warm-up to Thm 2.7: the warm-up is high-probability and per-$n$; Thm 2.7 is Cesàro and pathwise.

### M4. §2.4–2.5 (answer to H8's converse): "No bound of the form 'no simple separating property ⇒ small error' holds" is overbroad, and a positive converse is missed

* **Claim.** §2.5: "No bound of the form 'no simple separating property ⇒ small error' holds (Prop 2.13)." Summary item 6 calls Prop 2.13 the failure of the naive converse.
* **Problem.**
  * Prop 2.13 refutes the converse only when $f$ is *random*, so that $K(f)\gg m$. No information-theoretic converse could hold there, and nobody would state one without assuming $f$ simple.
  * For simple $f$ there is a clean converse once the separating property may depend on the *full input set* $B$. It follows in a few lines from the track's own sandwich (Prop 2.14) and (F2). The track states the ingredients ("A simple separating property makes $\lambda_y$ cheap given $B$") but not the result.
* **Referee proposition R1 (converse given the input set).** Setting of Prop 2.14; $\nu\in\{W,M_F\}$. Let:
  * $e^{\rm wr}(x^*)$ be the posterior mass of *defined, wrong* labels at $x^*$;
  * $e_{\rm norm}$ be the normalised error;
  * $\sigma_B(x^*;A):=\min\{K(Q\mid B):Q\text{ decidable},\ x^*\in Q,\ Q\cap A=\emptyset\}$.

  Then
  $$e^{\rm wr}(x^*),\ e_{\rm norm}(x^*)\ \le\ 2^{2K_B(f)-K(x^*\mid B)+c},\qquad |K(x^*\mid B)-\sigma_B(x^*;A)|\le c.$$
  * *Proof.*
    1. Let $p$ be a shortest program agreeing with $f$ on $B$.
    2. For $x\in B$ put $\mu(x):=\sum_{y\ne f(x)}\nu(f|_{B\setminus x}\cup\{(x,y)\})$.
    3. Labellings of $B$ that differ from $f|_B$ at distinct single points are pairwise incompatible. For $W$ and $M_F$ (measures on programs or tapes) this gives $\sum_x\mu(x)\le1$.
    4. $\mu$ is lower semicomputable given $(B,p)$: $p$ halts on $B$. By (F2), $\mu(x^*)\le2^{-K(x^*\mid B,p)+c}\le2^{-K(x^*\mid B)+|p|+c'}$, because $p$ is self-delimiting.
    5. $\nu(f|_A)\ge\nu(f|_B)\ge2^{-K_B(f)-c}$. Divide.
    6. For $\sigma_B$: $x^*$ is the unique element of $Q\cap B$, and conversely $Q=\{x^*\}$ is a separating property. ∎
  * The bound is for $e^{\rm wr}$ and $e_{\rm norm}$. Mass *undefined* at $x^*$ is not lower semicomputable, and I do not claim the bound for the semimeasure-convention $e$.
* **Two-sided reading.** $2^{-\sigma(x^*;A)-c}\le e(x^*)$ (Prop 2.1) and $e_{\rm norm}(x^*)\le2^{2K_B(f)-\sigma_B(x^*;A)+c}$. So "no property simple *given $B$* separates test from train, and $f$ is simple" does imply small error. The remaining slack is unconditional against $B$-conditional separating complexity, plus $2K_B(f)$.
* **Corollary R2 (per-step, any input distribution).**
  * Take i.i.d. $x_1,\dots,x_m,x^*$ from any distribution. Then
    $$\mathbb E\,e_{\rm norm}(x^*)\le2^{2K_F(f)+c}\,\frac{\log_2(m+1)+O(\log\log m)}{m+1}.$$
  * *Proof.*
    1. Given the multiset, $x^*$ is a uniformly random position.
    2. Repeated values give error 0.
    3. Fewer than $2^j$ elements $x$ of $B$ have $K(x\mid B)<j$.
    4. Hence $\sum_{x\in B}\min(1,2^{a-K(x\mid B)})\le2^{a+1}(\log_2|B|+O(\log\log|B|))$ with $a=2K_F(f)+c$.
  * This is a *per-step* upper bound, $O(2^{2K}\log m/m)$. It complements the per-step lower bound $\Omega(2^{-K}/(m\log^2m))$ of Prop 2.12, and it repairs m6 below.
  * Status: referee proofs. They need re-verification by the track before use.
* **Fix.** Add R1 and R2 (or a corrected version). Restrict the "no bound holds" sentence to random targets or to unconditional properties. In §2.5 item 1, replace "No bound ... holds" by the two-sided statement above.

### M5. "Apparently new" list (§6) and other novelty statements: several items are known

* **Claim.** §6 lists the following as "apparently new":
  * "the zero-eigenvalue observation for two-layer ReLU kernels as a learnability statement (Rem 4.8)";
  * the OOD results of §2, including Prop 2.4 and the random-split theorem (Prop 2.9);
  * Thm 4.6 is cited as known, but not to the slides.
* **Problem.**
  * *Rem 4.8.* Basri, Jacobs, Kasten & Kritchman, NeurIPS 2019 (arXiv 1906.00425): the abstract, as paraphrased by a search snippet, says that a shallow network without bias cannot represent or learn low-frequency functions with odd frequencies [verified (snippet, paraphrase)]. A search snippet of an NTK supplement gives "$\mu_k=0$ if $k=2j+1$ with $j\ge1$". This is very likely Bietti & Mairal, NeurIPS 2019, arXiv 1905.12173 [attribution unverified]. The cube statement is the same algebra (r4).
  * *Prop 2.4* (a universal machine tailored to make a bad behaviour likely) is the supervised analogue of Leike & Hutter, "Bad universal priors and notions of optimality", COLT 2015, PMLR 40:1244–1259 [verified (snippet)].
  * *Prop 2.9* is the exchangeability form of online-to-batch conversion. The foundations track already cites Littlestone 1989 and Cesa-Bianchi, Conconi & Gentile 2004 for it (unverified). The permutation argument is also used in Haussler, Littlestone & Warmuth, *Inf. Comput.* 115(2):248–292, 1994 [bibliography verified (snippet); content unverified]. The notes already say Lattimore–Hutter's "random selection of training data" theorem may be the same statement.
  * *Thm 4.6:* see M3(a).
* **Fix.**
  * Remove Rem 4.8 and Thm 4.6 from the "new" list.
  * Cite Basri et al. (and Bietti–Mairal, marked unverified) for Rem 4.8.
  * Cite Leike–Hutter 2015 at Prop 2.4.
  * Present Prop 2.9 as a standard argument applied to SFI.

---

## 3. Minor issues

* **m1. Thm 3.1(a), proof, short inputs.**
  * The proof says "for $|x_j|<N_A$: $-\log_2q_i(y_j\mid x_j)=\log_2|Y|$". This is false when $A$ is active ($|x_j|\ge n_i$) and finishes within the clock on that particular short input. Then $q_i=A$.
  * The needed inequality $-\log_2q_i\le\log_2|Y|-\log_2A(y_j\mid x_j)$ holds in both cases, so the theorem stands.
  * r7 includes such comparators: the bound holds and is nearly tight (slack 0.8 bits).
  * Fix: write "$\le$" with the two cases.
* **m2. §3.1 Setting: "restricting to distinct inputs loses nothing".**
  * This is false for the natural use of probability predictors, i.e. noisy labels. A repeated input with a different label gives the function mixture $S$ probability 0 (infinite regret), while an $x$-only comparator pays a finite loss. Compare foundations Prop 6.8.
  * Moreover, with length-based clocking a comparator may be over budget on short inputs forever. So even a per-round (sequence) mixture would not have constant regret on streams that repeat short inputs.
  * Fix: state distinctness as a genuine restriction. For noisy data, use time-stamped inputs (foundations' repair), or round-based clocking.
* **m3. Thm 3.1: size of the constant and hidden hypothesis.**
  * The regret bound $\log_2(1/w_i)+(2^{N_A}-1)\log_2|Y|$ with $N_A\ge n_i=2^{2^i}$ is triple-exponential in the index $i$. The index $i$ is itself up to exponential in $|A|$. Say so.
  * A hybrid design removes $n_i$ from the exponent: activate by round number, clock by input length. The regret becomes $\log_2(1/w_i)+(\text{activation round})\log_2|Y|+(2^{N'_A}-1)\log_2|Y|$ with $N'_A=\min\{n:g(n)\ge c_A\}$, at the cost of a per-round time that grows (as $\log\log k$) with the round count $k$.
  * $p$ must be time-constructible for the clock (hidden hypothesis).
* **m4. Prop 3.3: "the same mixture $S$".**
  * Against samplers the mixture must range over *clocked samplers*. A probability predictor with non-dyadic outputs is not a bounded-time sampler.
  * Fix: define $S$ over both interpretations of each program, or over samplers only.
* **m5. Prop 2.8: the sandwich is lopsided.**
  * Since $\sum_k2^{-\sigma_k}\le1$, the lower end is always $\le2^{-c}$. Prop 2.1-type arguments can therefore never force more than $O(1)$ cumulative error.
  * The phrase "SFI's total OOD error over any sequence lies between the input sequence's novelty and $f$'s complexity" should say this.
  * "This formalises Hänni's fake OOD generalisation" is interpretation, not a theorem.
* **m6. Prop 2.12 and summary item 6: "matches the $O(1/m)$ Cesàro upper bound up to $\log^2m$".**
  * This compares a per-step lower bound with a Cesàro average. Since $\sum_k\mathbb E e_k<\infty$, $\liminf_m m\,\mathbb E e_m=0$: the per-step error is often much smaller than $1/m$.
  * The correct per-step comparison is R2 above: $\Omega(1/(m\log^2m))$ against $O(\log m/m)$ for fixed simple $f$, normalised convention.
* **m7. Remark 2.2(ii).** A semi-decidable $Q$ does not produce "a log term". It loses the bound. Reword the heading.
* **m8. Prop 2.3.**
  * $K(Q_p,b_p\mid p)$ is defined as the shortest code of a pair of programs taking $p$ as input. That is not conditional complexity: the wrapper reads $z$ before $p$.
  * Either keep the definition and drop the conditional notation, or read $p$ before $z$ (the wrapper $wpz$) to get true conditional complexity.
* **m9. Prop 4.3.**
  * The first display holds for *every* semimeasure (Kraft only). The two-sided consequence needs Prop 4.2's hypotheses: lower semicomputability given $a$, and a probability measure for "probability over $\theta$". State this.
  * The fact is standard: it is the usual Kraft/Markov argument behind "$K(x)\approx-\log P(x)$ for $P$-most $x$" (Li & Vitányi, sections on the coding theorem and on expected complexity versus entropy; section numbers unverified). Cite it as known.
* **m10. Rem 4.8, "GP classification ... open".** Part of it is easy and should be added.
  * A zero eigenvalue means the GP prior's paths are a.s. orthogonal to $\chi_S$.
  * Any $z$ with $\mathrm{sign}(z)=\chi_S$ has $\langle z,\chi_S\rangle>0$.
  * So the GP-classification prior (and the slides' $|z|>\tfrac12$ rule) gives probability exactly 0 to $\chi_S$ as a whole function.
  * Per-point test error remains open.
* **m11. Remark 3.2 and summary item 7: "Hänni's amortisation trick then applies verbatim [proof sketch]".**
  * No sketch is given. The per-round time budget for *history-aware* function predictors is not defined: $p$ of what, $|x_k|$ or the history size?
  * With length-based budgets, catch-up can stall while inputs stay short.
  * Fix: relabel as conjecture and define the class.
* **m12. Thm 3.5(b).** The $O(\cdot)$ can be explicit: the largest $L$ allowed by the displayed inequality satisfies $L\le52\,md\log_2(md+2)$ on the grid $d\le10^3$, $m\le10^4$ (r5(7)).
* **m13. References.**
  * Kamath–Montasser–Srebro: PMLR 125:2236–2262 [verified (snippet)]. "Thm 19" is unverified; the slides cite "Example 1".
  * Goldblum et al.: page range PMLR 235:15788–15808 not confirmed by my search.
  * Grau-Moya et al. (PMLR 235:16178–16205), Mingard et al. (JMLR 22(79):1–64), Lattimore–Hutter (LNCS 7070, pp. 223–235), Impagliazzo–Levin (FOCS 1990 pp. 812–821; "universal extrapolation is possible precisely when cryptography is not") and Vaintrob–Hänni (arXiv 2607.05735, 7 July 2026): confirmed (snippet).
  * Özkural arXiv 1504.03303 / 1709.03879 are "Ultimate Intelligence" Parts II/III. Snippets confirm the operator-induction description and the $\ln2\cdot$complexity bound attributed to Solomonoff.
* **m14. Missing related work** (snippet-verified unless noted):
  * Filan, Leike & Hutter, "Loss bounds and time complexity for speed priors", AISTATS 2016, PMLR 51:1394–1402, and Schmidhuber's speed prior (unverified), for §3.1.
  * Leike–Hutter 2015 (M5).
  * Basri et al. 2019 (M5).
  * Prediction with expert advice: the Bayes-mixture log-loss regret $\log(1/w_i)$ is textbook (Cesa-Bianchi & Lugosi 2006; chapter unverified).
* **m15. Hänni's second OOD example** (labels = shortest proofs) is not treated, though Thm 2.5 applies directly:
  * $P=\{(x,y):y\text{ is a shortest proof of }x\}$ is decidable given $T$.
  * The simplest violating output at $x^*$ has $K(z\mid x^*)=O(1)$.
  * So violation has probability $\ge2^{-K(Q)-c}$ under the same separating $Q$ as Example 2.15.
* **m16. Corollary 4.7.** "Pointwise squared error $\le4e$" can be sharpened to $\le4e^2$. Harmless.
* **m17. Conjecture 2.11 (LOO).** I could not refute it. A counterexample needs $\gg K$ points $x$ whose one-point flips satisfy $K(f^x)\lesssim K(f)$. By symmetry of information this requires $K(x\mid f^{x*})\approx K(x\mid f^*)$ for many $x$: a "star" of near-$f$ functions covering a constant fraction of all functions of complexity $\le K$. The natural attempts (halting-set indicators, pseudo-random seeds, interval/threshold functions) give $O(1)$ or $O(K)$ bad points. The label "conjecture" is appropriate.

---

## 4. Cross-track notes

* **Context Prop 5.4(2) strengthens foundations Prop 4.3.**
  * $2^{-K(y\mid x)}$ is attained by a product law (the conditional universal discrete semimeasure). So $M_{\rm prod}/W$ (and $M_F/W$) is unbounded on *one-point* data sets, not just two-point ones, for $W$ with input-independent self-delimitation.
  * The two tracks should check that their $W$ is the same object. Context §1 makes programs self-delimiting independently of the input, and the separation depends on this.
* **Context Prop 5.1/Cor 5.2 contradict foundations §2–3** (M2). Foundations is right.
* **Context Thm 3.1's "distinct inputs" remark** should cite foundations Prop 6.8 (noise and repeats).

## 5. Claims I confirmed

Each was checked line by line; scripts are cited where I also computed.

* **§1.**
  * $K(z\mid x)-c\le K^{\mathcal P}(z\mid x)\le K(z\mid x)+K(K(z\mid x))+c$.
  * (F1) telescoping and $\le-\log\nu(D_n)$.
  * (F2) as stated, including uniformity in the program $z$.
* **§2.**
  * Prop 2.1, all three parts. The wrapper is prefix-free and injective; $D$-consistency uses $\operatorname{dom}D\cap Q=\emptyset$; $T_{Q,b}$ reuses $V$ correctly. The "no log term" remark is correct.
  * Remark 2.2(i),(iii).
  * Prop 2.3 (see m8).
  * Prop 2.4: $W'(D)=W(D)$; conditional $\ge\tfrac12$; mutual simulation constants.
  * Thm 2.5, parts 1–3, including the even/odd tape split for $M_F$. The consequence in part 2 holds in both conventions.
  * Prop 2.6(a),(b). (b) correctly uses that $W$ and $M_F$ are measures, so the disjoint events sum to $\le1$. The bound $\nu((x^*,0)\mid D)\le2^{-n+c'}$ also holds normalised.
  * Thm 2.7 ($c=0$ for $W$ is right).
  * Prop 2.8: distinct $Q$'s give distinct shortest codes, so Kraft applies (but see m5).
  * Prop 2.9 (r6: $8\cdot10^{-14}$).
  * Prop 2.10 (r6).
  * Rem 2.11 numbers (1 bit LOO against 0.2555 random-split average at $N=16$).
  * Prop 2.12 (r5(1); c4 matches the exact probabilities).
  * Prop 2.13 (r5(2)).
  * Prop 2.14.
  * Example 2.15, including $L'=2^{\lceil\log_2L\rceil}$ and $K(Q)\le K(T)+2\log\log L+c$.
* **§3.**
  * Thm 3.1(a): correct with m1's wording fix (r7).
  * Thm 3.1(b), proof sketch: the incremental formula is right. Rounding errors enter the cumulative loss additively ($\sum_k\varepsilon_k$) and do not compound.
  * Prop 3.3.
  * Circuit counting $N_s$ and $B(s)$ (r3).
  * Thm 3.5(a),(b) in full: the strict inequality via constant circuits at every size; the split at $\lceil L\rceil$; the chord bound; $\#\{P_i>\tfrac12\}\le2m$.
  * Rem 3.6: the formula $B$ (r3) and the gap in Hänni's sketch. The gap is real: with a polynomial size tail, small log loss gives only $c\le2^{O(L)}$.
  * Rem 3.7: all numbers reproduced independently (r3).
  * Prop 3.8 ($70\ell+531$; r5(3)).
  * Prop 3.9: the constant 5.7 holds with margin 1.68 on the grid (r5(4)); the post-$N$ injection argument is correct.
  * Rem 3.10: the halving bound (r3(e)). The "open" claim is wrong (M1).
* **§4.**
  * Props 4.1–4.4.
  * Prop 4.5 (counting checked by brute force, r5(6)).
  * Thm 4.6(a),(b); Cor 4.7.
  * Rem 4.8: the mathematics is right. A cleaner proof: $\kappa(\rho)-a\rho$ is even, with $a=\tfrac12$ for the NNGP and $a=1$ for the NTK. So $z\mapsto\kappa(\rho(z))-a\rho(z)$ is invariant under $z\mapsto-z$, and has no odd Walsh coefficients. r4 confirms this exactly for $d$ up to 40, and shows that biases break it.
  * The c2 numbers quoted in §4.4.
* **§5.**
  * Prop 5.1 *as a statement about weak semimeasures* (but see M2).
  * Prop 5.3.
  * Prop 5.4, all four parts. The failure of $W\ge2^{-K(y\mid x)-c}$ is a correct and neat argument.
* **Scripts.** c1–c5 reproduce exactly. Docstrings match what the scripts do. c2's assertion uses a tolerance of 0.05 and 20 sampled targets rather than all $\binom dk$; the notes' "asserted per cell" is accurate but weaker than Thm 4.6(b).

## 6. Important questions from the brief that the track missed or left incomplete

1. **H10 bridge.** The slides were not used (M3). The brief asks the paper to cite them for the NN Bayes ≈ circuit SFI bridge, with their caveats.
2. **H8 converse.** The positive converse conditional on the input set is missing (M4). So is a per-step in-distribution upper bound (R2).
3. **H8 examples.** The shortest-proof labelling example is missing (m15).
4. **Circuit Occam out of distribution.** Hänni's main question in `hanni-circuit-circuit-occam-learning.md` has a natural-language answer, the ladder (M1). The track lists it as open.
5. **Polytime note, Remark 4** (a learner in time $n^{\omega(1)}$ against all polynomial-time predictors) is not addressed. It is a one-line consequence of Thm 3.1 with a diagonal clock, and should at least be stated.
6. **History-aware time-bounded version.** It is asserted without definition or sketch (m11).
