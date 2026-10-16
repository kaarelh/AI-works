# Referee B (computation and counterexamples): thread `fundamentals`

*Referee record, 2026-10-16.*

* **Record refereed:** `notes.md` (743 lines, dated 2026-10-15) and its scripts `checks/c1_structure.py`, `c2_separations.py`, `c3_kolmogorov.py` and `c4_coloring.py`.
* **Independent code:** `referee_code/`, consisting of the shared module `rb_common.py` and the scripts `rb1_machines.py`, `rb2_updates.py`, `rb3_loss.py`, `rb4_order.py`, `rb5_kolmogorov.py`, `rb6_misc.py`, `rb7_monadic.py` and `rb8_referee_claims.py`.
  * Every script is seeded with 20261016.
  * Each output is saved next to its script as `rbN_*.out`.
  * The code is written from the definitions in `notes.md`, not from `checks/`, and uses a different representation (see §1).

---

## 0. Verdict

**Sound; accept after minor revisions, plus one recommended addition. No fatal issue, and no claim is refuted.**

* **The developer's scripts reproduce.** I re-ran c1–c4 on scratch copies; all four outputs are byte-identical to the saved ones.
* **My own code finds no counterexample.** I tested every claim that has a finite stand-in, over thousands of random and adversarial instances and in exact rational arithmetic. Every identity holds exactly, and every inequality holds.
* **I re-derived every proof in §1–§11 by hand.** I found no error. The places where a hypothesis is used silently are listed as minor issues.

**The one substantive addition (issue M1).** Prop 7.2(b) leaves open whether the consistency-requiring (CR) cumulative loss of $M_A$ *itself* depends on the reveal order. A short disjointness argument settles it: yes, and the gap can be made linear.
* I give the proof below (§3, M1).
* It is checked exactly on finite stand-ins (rb4 R4.4, rb8 R8.2).
* With it, §7.5's case for the proof-requiring variant rests on a property of $M_A$ itself, not of one hand-built law.

**Minor issues.** They concern:
* a terminology clash with P1 Def 3.2 that hides the real separation between the PR and graded CR weights (m1);
* a well-order and a length-refining order that some statements need but do not state (m2);
* two reference statuses that can now be upgraded, one of which restores scout F's factor 2 (m3);
* small wording points (m4);
* the developer's scripts (m5).

---

## 1. What was run

**Representation (independent of `checks/`).** `rb_common.py` works in propositional logic over $k$ atoms.
* **Sentences** are syntax trees, so logically equivalent but syntactically different sentences exist (double negation, $\varphi\wedge\varphi$, Craig powers).
* **Content** is the model set, computed by truth table.
* **A theory machine** is a finite list of pairs $(w,\varphi)$: "after reading $w$, emit $\varphi$".
* **Its law** is computed exactly by enumerating every tape prefix up to the machine's horizon.
* **A toy universal machine** $G_U=\{(p_iw,\varphi):(w,\varphi)\in G_i\}$ uses a prefix-free code $(p_i)$. As in Def 1.4, tapes with no program prefix get the empty theory.
* **All one-tape quantities** ($M$, $M^3$, $\Bel_D$, $M^{\rm nc}$, $\Bel^{\rm nc}$, $M^{1/2}$) are computed from the resulting focal law $\{$model set of $B\cup A_\omega\mapsto$ mass$\}$ with `fractions.Fraction`.

**Decidable first-order fragment (rb7).** One unary predicate, constants, equality, and quantifier rank at most 2.
* Validity is decided over "capped" canonical structures. A structure is given by its constant pattern and by the counts of non-constant elements inside and outside $R$, each count capped at 3. By the Ehrenfeucht–Fraïssé argument for monadic structures, this decides validity for sentences of rank at most 2.
* The procedure is validated against all 3450 structures of size at most 6: 400 random sentences, 0 disagreements (R7.0).

**Reproduction of the developer's scripts.**
* I copied `checks/*.py` to a scratch directory, ran each script and compared the output with `cmp`.
* `c1_structure.out`, `c2_separations.out`, `c3_kolmogorov.out` and `c4_coloring.out` are all **byte-identical**.
* Run times are 0.47 s, 0.21 s, 0.04 s and 0.04 s.
* Every number quoted in the notes' §15 matches the outputs. Examples: strict excess in 166 of 173 (A9), 61 entailed-datum drops (A12), mean order gaps 2.24/3.36/4.47/5.54 (B4), and Bayes mistakes 1–5 (c3).

**Reproduction of my own scripts.** I copied `referee_code/*.py` to a scratch directory and re-ran all eight. Each output is byte-identical to the saved one. Run times range from 0 to 36 s (rb4 is the slowest, because of its sympy sign search).

---

## 2. Claim-by-claim coverage

Each claim was checked by code where a finite stand-in exists, and by hand everywhere. Results are exact (Fractions) unless marked as floats.

| claim | independent check | result |
|---|---|---|
| Prop 1.8(a) Craig: at most two readings $\theta=\chi^{\wedge m}$; the decider decides $A^C_e$ | R6.3: all 129 958 conjunction trees over 2 atoms with at most 8 leaves, brute force; 106 446 (enumeration, sentence) tests | at most 2 readings (maximum 2 attained); the decider's readings equal brute force in all cases; 0 disagreements with membership |
| Prop 1.8(c),(d): the lemma "a consistent $\psi$ proving $R(c_j)$ for all $j<n$ and $\exists x\neg R(x)$ mentions every $c_j$"; the upper-bound sentence | R7.1 (5984 random sentences, 958 meet the hypothesis); negative control without the existential datum; R7.3 | 0 omissions; the control finds 443 omissions, so the checker can detect them; the upper bound holds |
| Lemma 6.2a (L1),(L2) | R7.2: all 27 literal sets on 3 constants, $B$ = distinct constants | 0 violations |
| Prop 2.1(a)–(g): positivity iff consistent; semimeasure identity with defect $\nu^3$; content only; entailed data free; order independence with repeats; $0<M(\emptyset)=1-\Inc_0<1$; containment functional | R1.2–R1.7: 40–60 toy universal machines at tape level | all exact; the order-independence error is $8.9\cdot10^{-16}$ (floats) |
| Thm 4.1 mixture identity | R1.1: law from enumerated tapes vs. the mixture formula, 40 machines | difference 0 |
| Thm 3.2 machine $G_\alpha$ and the decomposition $\Inc_0=2^{-\lvert p\rvert}\alpha+\gamma$ | R1.8: 30 dyadic $\alpha$ | exact |
| Lemma 3.3 (randomness passes up) | R6.1: 11 800 (real, $n$) tests, $k=0..5$, reals with non-dyadic tails, random left-c.e. approximations | $\alpha$ always lies in $[\alpha_s,\alpha_s+2^{k+1-n})$; $\alpha_{1:n}$ is always among the candidates; at most $2^{k+1}+1$ candidates |
| Thm 3.2(b) Solovay reduction inequality | R6.2: 7901 rationals $q<\beta$ | 0 violations |
| Prop 4.3 background shift | R1.9 | exact |
| Thm 4.4 faithful translations | R1.10: (T1),(T2) on 400 random $(\Gamma,\varphi)$; push-forward and pull-back machines | push-forward exact; the pull-back keeps consistency and compatibility in 86 of 86 |
| Prop 2.2 geometric conditioning, total monotonicity, bracketing | R2.1–R2.3: 71 (law, $D$) pairs | exact, 0 violations |
| Prop 2.3 Dempster conditioning; $M^{\rm nc}=\Pl_0(\psi)$ | R2.4 | exact |
| Prop 7.1(a)–(c) | R2.5 | exact |
| Prop 7.2(a) per-datum CR bound | R2.6: 562 non-entailed queries | 0 violations |
| Prop 7.2(b) explicit law | R4.3 | CR probabilities $\frac12$ and $\frac14$; PR $\frac12$ in both orders |
| Prop 7.3(a)–(d) graded CR | R2.7 | weak; at least $M$; every entailed datum drops by at least $\varepsilon/4$; the packaging gap equals mass(neither)/4 exactly |
| Prop 7.4 decomposition | R2.8 | exact |
| Thm 5.1 loss bound against $T$ | R3.1: 28 800 (theory, order) cases | 0 violations |
| Prop 5.2(c) laws plus coin facts | R3.3: 100 cases, tape level | 0 violations |
| Prop 5.3(a) Bayes mistakes | R3.2: exhaustive adversary over all orders of 6 sentences, ties counted against | at most $-\log(\text{Ext}/M(\emptyset))$ |
| Prop 5.3(b) Kolmogorov predictor bound $2^k$ | R5.1: exhaustive adversary, 5931 sequences, length-refining order | failures at most #(programs of length at most $k$), which is at most $2^k$; **with an arbitrary order the count bound fails** (m2) |
| Thm 5.4 three-valued merging identity and bound; Pinsker | R3.6: 40 instances, adaptive coin-dependent questions with repeats | identity error $6.2\cdot10^{-15}$ (floats); bounds hold |
| Cor 5.5 | R3.4: 37 presentations | holds (margin 0.046 bits or more) |
| Prop 6.1(a),(b) core: incompatible masses sum to at most $M(\emptyset)$ | R3.5 | holds |
| Thm 6.2(i) arithmetic; (ii),(iii) "exactly a quarter"; pigeonhole | R6.5: $d=2..3000$ in exact integers; all 168 two-literal data sets for $d=2$ over all $2^{16}$ coin strings | 0 violations; exactly $\frac14$ in 168 of 168 |
| Prop 8.1 total-variation bound | R3.7: 60 streams | 0 violations |
| Prop 8.3(a),(c) | R3.7 | limit Bel/Dis formulas exact; the Indep lower bound holds; three-valued data leave only $[T^*]$ in 30 of 30 |
| Prop 10.1(a),(d) Demski's process | R6.4: exact absorbing-chain law, $k=2,3$ atoms, full-support sentence measures | complete with probability 1; coherent; $P_\mu\ge\mu$; skipping implied sentences gives the same outcome law in 12 of 12 |
| Thm 11.1(a) closed form and sign | R4.1: 300 random laws, some focal masses zeroed | closed form exact; strict inequality exactly when the numerator is positive, in 300 of 300 |
| Thm 11.1(b) linear gap | R4.2: $n=2,3,4$, toy universal machine containing $G_{ca}$ | per-pair ratio at least $1+v_i$; per-$y$ bound holds; mean gaps 2.42/3.60/4.74 bits against floors 0.125/0.19/0.25 |
| Prop 11.2(b) graded/PR gap | R6.6: $(m,k)\in\{(3,1),(3,2),(3,3),(4,1),(4,2),(5,2)\}$, $\varepsilon_\emptyset\ge\frac12$, so every bound is positive (non-vacuous) | gap minus bound is at least 3.0 bits in every case |
| Thm 11.3 Kolmogorov adversary | R5.2: $m=2,3,4$, decoys, length-refining and random orders | exactly $2^m-1$ failures in 72 of 72; data true at $w^*$; $K_A(D)=\lvert\pi(w^*)\rvert\ge m$ for length orders; Bayes within its bound |
| Thm 11.3, choice of $w^*$ (self-check 3 of the notes) | R5.3: $w^*$ chosen as $\prec$-first instead of $\prec$-last | the loop stops early in 90 of 90, so the proof's choice is needed |
| Lemma 8.0, Props 8.4–8.7, 9.1, 11.4, 11.5, 6.4, 3.4 | by hand (not finitely testable) | correct as written. Two notes: Lemma 8.0's cylinder-density step and the stage argument were checked; in Prop 8.5(b) the model $\mathbb N\sqcup\{a\}$ was re-checked, all operations are total and closed terms stay in $\mathbb N$ |

**Cross-references.** Every printed P1 number in the notes matches the intended label in `solomonoff-operator-induction/paper/main.aux`, and every AI-paper number matches the intended label in `axiom-induction/paper/main.aux`. The labels checked include `def:setting:weak`=3.2, `def:setting:rpf`=3.4, `prop:setting:twopoint`=A.7, `q:setting:normorder`=A.8, `thm:comp:ladder`=9.10, `prop:model:whichsize`=2.22 and `thm:time:equiv`=6.3.

**Supporting computation for the notes' "open" remarks (R4.5).** I ran a symbolic sign search with sympy over generic positive masses on all 15 nonempty focal sets on 4 valuations, for two-datum sets $\{(x,1),(y,1)\}$.
* **Normalised PR.** The order difference has a constant sign on exactly the 36 entailment pairs ($x\subseteq y$), and mixed sign on all 30 other pairs, logically independent pairs included. This supports the notes' remark that Thm 11.1's mechanism is entailment, and that the independent-data case (P1 Question A.8) cannot be settled by a single pair.
* **CR.** No pair at all has a constant sign (66 of 66 mixed). This supports the developer's self-check 2: no single pair settles the CR order question for $M_A$. A family argument is needed, as in M1.

---

## 3. Issues

### Fatal

None.

### Major

**M1 (an open case is settled; add it). Prop 7.2(b): the CR cumulative loss of $M_A$ itself is order dependent, with a linear gap.**

*Where.* Prop 7.2(b) ("Whether the CR loss of $M_A$ itself is order dependent is [open]"), the summary table row "Prop 7.2", §7.5 item 3, the remark after Prop 7.3, §15 "Not done", and §12.2.

**Proposition (proposed replacement for 7.2(b); proof by the referee, to be re-checked by the developer before adoption).**

*Setting.* Work in the setting of Lemma 6.2a with two fresh unary predicates $P$ and $R$. Let:
* $a_i:=P(t_i)$;
* $(e_{i,j})_{j\ge1}$, for each $i$, be pairwise incompatible conjunctions of $R$-literals on terms reserved for block $i$, each consistent; for example $e_{i,j}:=\neg R(s_{i,1})\wedge\dots\wedge\neg R(s_{i,j-1})\wedge R(s_{i,j})$;
* $b_{i,j}:=a_i\vee e_{i,j}$.

*Claims.*
* **(a)** For $D_j:=\{(a_1,1),(b_{1,j},1)\}$, all but at most $1/(\Bel_0(a_1)\,\varepsilon_\emptyset)$ indices $j$ satisfy the following: the CR (Dempster-predictor) probability of $D_j$ is strictly larger in the order $(a_1,b_{1,j})$ than in the order $(b_{1,j},a_1)$. So the CR cumulative loss of $M_A$ depends on the reveal order.
* **(b)** There is a constant $c$ such that for every $n$ there are indices $j_1,\dots,j_n$ with the following property. Let $D_n:=\{(a_i,1),(b_{i,j_i},1):i\le n\}$. Its CR losses in the orders $(a_1,b_1,a_2,b_2,\dots)$ and $(b_1,a_1,b_2,a_2,\dots)$ differ by at least $n\log(1+2^{-c}\varepsilon_\emptyset/2)$ bits.

*Proof.*

*Step 1 (the CR predictor through the conditioned random theory).* Let $D$ be the set revealed so far, which is the same in both orders after every completed pair. Let $H:=B\cup A_\omega\cup D^\pm$, under $\Unif$ conditioned on $H$ being consistent; write $\Pr$ for this law. By Prop 2.3 and Prop 7.1(c):
* the CR predictor gives a datum $x$ the probability $\Pr[H\vdash x]$;
* after $x$ is added, it gives $y$ the probability $\Pr[H\cup\{x\}\vdash y\mid H\cup\{x\}\text{ consistent}]$.

*Step 2 (the per-pair ratio).* Fix a pair $(a,b)$ with $b=a\vee e$. Define:
* $\Pl(b):=\Pr[H\cup\{b\}\text{ consistent}]$;
* $T:=\Pr[H\cup\{b\}\text{ consistent},\ H\vdash b\to a]$;
* $\rho:=\Pr[H\cup\{e\wedge\neg a\}\text{ consistent}]$;
* $\delta:=\Pr[H\vdash b,\ H\nvdash a]$.

Order $(a,b)$ has probability $\Pr[H\vdash a]\cdot1$, because $b$ is then entailed. Order $(b,a)$ has probability $\Pr[H\vdash b]\cdot T/\Pl(b)$. Two facts follow from the definitions:
* $\Pl(b)-T=\rho$, because $H\nvdash b\to a$ iff $H\cup\{b,\neg a\}$ is consistent iff $H\cup\{e\wedge\neg a\}$ is consistent;
* $\Pr[H\vdash b]=\Pr[H\vdash a]+\delta$.

Hence
$$\frac{P_{(a,b)}}{P_{(b,a)}}=1+\frac{N}{\Pr[H\vdash b]\,T},\qquad N=\Pr[H\vdash a]\,\rho-\delta\,T\ \ge\ \Pr[H\vdash a]\,\rho-\delta .$$

*Step 3 (lower bounds).*
* $\rho\ge\varepsilon_\emptyset$. On tapes with $A_\omega=\emptyset$ we have $H=B\cup D^\pm$, and $H\cup\{e\wedge\neg a\}$ is consistent by (L1), since all atoms involved are fresh. These tapes have mass $\varepsilon_\emptyset/M^{\rm nc}(D)\ge\varepsilon_\emptyset$.
* $\Pr[H\vdash a_i]\ge2^{-c}$. The tapes beginning with a program for $\{\forall xP(x)\}$ qualify: this theory is consistent with $D^\pm$, whose members are $P$-positive literals and disjunctions containing them.

*Step 4 (disjointness).* The events $\{H\vdash b_{i,j},\ H\nvdash a_i\}$ are pairwise disjoint in $j$: from $H\vdash a\vee e_j$ and $H\vdash a\vee e_{j'}$ with $e_j,e_{j'}$ incompatible, we get $H\vdash a$. So $\sum_j\delta_{i,j}\le1$.

*Conclusion.*
* (a) is the case $D=\emptyset$. There $N_j\ge\Bel_0(a)\varepsilon_\emptyset-\delta_j$ up to the positive normaliser $1-\Inc_0$, so $N_j>0$ unless $\delta_j\ge\Bel_0(a)\varepsilon_\emptyset$, which by disjointness happens for at most $1/(\Bel_0(a)\varepsilon_\emptyset)$ indices.
* For (b), at step $i$ choose $j_i$ with $\delta_{i,j_i}\le2^{-c}\varepsilon_\emptyset/2$; such a $j_i$ exists among the first $\lceil2^{c+1}/\varepsilon_\emptyset\rceil$ indices. Then $N_i\ge2^{-c}\varepsilon_\emptyset/2$, and $\log(P_{(a,b)}/P_{(b,a)})\ge\log(1+N_i)$ because $\Pr[H\vdash b]\,T\le1$.
* The CR conditionals depend only on the revealed set, so the per-pair log-ratios add. ∎

*Evidence.*
* **rb4 R4.4:** 40 toy laws in which short adversarial theories prove $a\vee e_j$ without proving $a$.
  * The identity $N_j=\Bel_0(a)\rho_j-\delta_jT_j$ holds exactly.
  * The lower bound holds; maximum violation 0.
  * $\sum_j\delta_j\le Z$ holds, with maximum excess $-43/128$.
  * The number of $j$ with $N_j\le0$ never exceeds $1/(\Bel_0(a)\varepsilon)$.
  * Single pairs go both ways (58 with $N_j\le0$, 182 with $N_j>0$), so the counting step is necessary.
* **rb8 R8.2:** sequential pairs with adaptive $j_i$, for $(n,J)=(2,3),(3,3),(2,4)$, 8 laws each.
  * Disjointness, the identity for $N$ and the identity $\text{ratio}=1+N/(\Pr[H\vdash b]T)$ hold exactly in 24 of 24.
  * The bound $N_i\ge\Bel'(a_i)\varepsilon'-1/J$ holds in 24 of 24.
  * The total gap is at least $\sum\log(1+N_i)$ in 24 of 24, with minimum margin 2.1 bits.
* **rb4 R4.5:** no single two-datum CR pair has a sign-definite order difference (66 of 66 mixed).

*Fix.*
1. Replace "[open]" in Prop 7.2(b) by the proposition above, with status **proved**, citing rb4 R4.4 and rb8 R8.2. Keep the explicit-law example as an illustration.
2. Update §0: the summary item, the table row "Prop 7.2" and the "Q5" paragraph.
3. Update §7.5 item 3 to "its cumulative loss depends on the order, already for $M_A$ itself, with a linear gap".
4. Update the remark after Prop 7.3, §12.2 and §15 "Not done".
5. Add a one-line contrast with Thm 11.1. Under CR, revealing the *stronger* datum $a$ first is more probable. Under normalised PR, revealing the weaker datum $a\vee c$ first is more probable.

### Minor

**m1. "Semimeasure (P1 Def 3.2)" and "weak semimeasure (P1 Def 3.2)" are the same definition; the real separation is the containment functional (P1 Def 3.4).**

*Where.*
* Prop 2.1(b): "So $\nu_G$ is a semimeasure on data sets (P1 Def 3.2)".
* Prop 7.3(a): "$\nu^{1/2}_A$ is a weak semimeasure on data sets (P1 Def 3.2)".
* §7.5 items 1 and 4.

P1 Def 3.2 is the *weak* function semimeasure (`def:setting:weak`). Both statements are therefore true, but the reader cannot tell from them that PR and graded CR differ in kind. They do differ, and P1's three-notion vocabulary expresses it: $\nu_G$ is a containment functional (Prop 2.1(g); P1 Def 3.4), while $M^{1/2}$ is weak but not a containment functional, not even of a random partial function on $\Sent$ that ignores logic.

*Proof of the missing statement (one line).* For any consistent theory, take the two inputs $(\varphi,\neg\varphi)$. The Möbius mass of (undefined, undefined) of $\nu^{1/2}_A$ is:
* $0$ if $A$ decides $\varphi$;
* $1-4\cdot\frac12+2\cdot\frac14=-\frac12$ otherwise.

So for $M^{1/2}$ it equals $-\frac12\,\Unif\{\omega\in C:A_\omega\text{ decides neither }\varphi\text{ nor }\neg\varphi\}\le-\frac12\varepsilon_\emptyset<0$ for every $\varphi$ that $B$ leaves undecided.

*Evidence.*
* **rb8 R8.1:** 120 random laws. The identity holds exactly in all of them. The mass is negative for $M^{1/2}$ in all 109 laws where $\varphi$ is undecided, and never negative for $M$.
* **rb2 R2.9:** 65 of 96 random pairs are negative for $M^{1/2}$, and 0 of 96 for $M$.

*Fix.*
* In Prop 2.1(b), write "a weak semimeasure (P1 Def 3.2), and by (g) a containment functional (P1 Def 3.4)".
* Add Prop 7.3(e): $M^{1/2}$ is not a containment functional, with the proof above.
* In §7.5 items 1 and 4, say "containment functional" where the distinction is meant.

**m2. Orders that need to be well-orders or length-refining.**
* **(a) Thm 11.3** says "Fix any total order $\prec$ on $\dom V$" and then uses "$\prec$-first" over infinite sets. This needs a well-order; order type $\omega$ suffices. *Fix:* write "any well-order (for instance of type $\omega$)".
* **(b) Prop 5.3(b)** correctly assumes an order that refines length. Nothing nearby says the hypothesis is essential, and Thm 11.3 then works with an arbitrary order, so a reader may carry the $2^k$ bound over.
  * The hypothesis is necessary. Under random orders, the failure count exceeded #(programs of length at most $k$) (R5.1: maximum excess 1).
  * On the Thm 11.3 sequences, failures exceeded $2^{K_A(D)}$ in 4 of 36 random-order runs (R5.2: 1 of 12 for $m=2$, 3 of 12 for $m=4$).

  *Fix:* add "(the length-refining order is needed: with an arbitrary well-order the count can exceed $2^k$)", citing rb5.
* **(c) §0** says the Bayes predictor makes "$\le k+c$ mistakes" on the Thm 11.3 data, while Thm 11.3(ii) states $m+K(m)+c$. Both are true: the first follows from Thm 5.1's last chain, $L_A(D)\le K_A(D)+c$. *Fix:* add that half-line to Thm 11.3(ii).

**m3. Two reference statuses can be upgraded, and one restores scout F's factor 2.** I searched the web; arXiv, Google Docs and lesswrong.com could not be fetched, so these are abstract-level or secondary-source checks.

* **Solovay / Vereshchagin / Shekhovtsov–Zakharov (Props 6.4(b), 11.5(c)).**
  * *Sources.*
    * Shekhovtsov and Zakharov, "Enumerating Complexity Revisited": arXiv:2312.04187, also ECCC TR23-201.
    * Vereshchagin, "Kolmogorov complexity of enumerating finite sets", *IPL* 103(1):34–39, 2007; also ECCC TR04-030.
  * *What the abstracts and secondary descriptions say.*
    * Solovay's bound is $I(A)\le3H(A)+O(\log H(A))$. Here $I$ is the shortest enumerating program, and $H(A)$ is the negative logarithm of the probability that a *random (probabilistic) machine* enumerates $A$.
    * Vereshchagin lowers the constant to 2 for finite sets.
    * Shekhovtsov–Zakharov show that any bound for finite sets transfers to all sets "up to logarithmic factors", so the constant 2 holds for every set.
  * *Consequences.*
    * The developer's "probabilistic reading", needed by Prop 11.5(c), is the right one.
    * Scout F's factor 2 can be restored at abstract level: $K_\equiv(T)\le2(-\log\Unif_A[T])+O(\log(-\log\Unif_A[T]))+c$, and likewise for $\mm_\equiv$.
    * The exact form of the logarithmic error term should be read in the paper (arXiv v2 html, or the ECCC pdf) before the statement is fixed.
  * *Fix.*
    * Give Props 6.4(b) and 11.5(c) the factor 2, with status "known (abstract-level: Shekhovtsov–Zakharov 2023 with Vereshchagin 2007); error term to be checked", and keep the factor-3 version as the fully safe fallback.
    * Update §14 and §12.1 ("downgraded" becomes "restored at abstract level").
    * In the PA remark after Prop 11.5, $3K_\equiv(\PA)$ becomes $2K_\equiv(\PA)$.
  * *Open lead.* Whether a coding theorem $I(A)\le H(A)+O(1)$ is known to fail is the second half of Q2. I did not find it stated in the abstracts; the introductions of the two papers above are where to look.
* **The geometric rule of conditioning (Prop 2.2(a)).** Secondary sources attribute it to Suppes and Zanotti (1977) as an alternative to Dempster's rule, with the same formula $\Bel(B\mid A)=\Bel(B\cap A)/\Bel(A)$ and the same random-set reading as the notes ("keep the focal elements inside the conditioning event and renormalise"). Examples:
  * Gong and Meng, "Judicious Judgment Meets Unsettling Updating", arXiv:1712.08946;
  * Smets, "About Updating", arXiv:1303.5752.

  *Fix:* upgrade "known, unverified" to "known (attribution via secondary sources; original not read)".
* **Demski's process (§10).** Secondary descriptions confirm the notes' description: sample a sentence, keep it if consistent, and the limit is complete almost surely. These are alignmentforum/greaterwrong mirrors of the MIRI posts, for example "an approach to logical counterfactuals inspired by the Demski prior" and "the two update problem: monotonicity". The original AGI 2012 paper was not read, so the status stays "known, unverified" as to the original. The proposition itself is about the process as described and is fully proved; R6.4 checks it exactly.

**m4. Wording.**
* **(a) Remark after Prop 6.1.** "A simple question such as 'which of these $m$ incompatible laws holds' gives slack $K(m)$" holds only when $S$ is computable from $m$; in general the slack is $K(S)$. *Fix:* "slack $K(S)$, which is $K(m)+O(1)$ when $S$ is computable from $m$".
* **(b) §1.2 Example (iv).** The dyadic weights need not sum to 1; the remaining tapes give the empty theory. *Fix:* say so. This is also the convention of Def 1.4, and it matters for m5(a).
* **(c) §1.6.** "$2^{-K_\equiv(T)}\le\mm_\equiv(T)\le\mm(\Ext T)$" needs $B\cup T$ consistent, because $\Ext$ contains only consistent indices. *Fix:* add "for $B\cup T$ consistent".
* **(d) Prop 8.5(b).** The proof uses $B=\emptyset$, or at least $B\cup\mathrm{Diag}(\mathbb N)\cup\{\neg\theta\}$ consistent. *Fix:* state the hypothesis on $B$.

**m5. Developer scripts (they reproduce; these are points of fidelity, not errors).**
* **(a) c1 does not model the one-tape setting.** `c1_structure.py`'s priors (`rand_prior`) have total weight between 0.5 and 1.0, and the remainder is "missing mass" assigned to no theory. Under Def 1.4 every tape yields a theory (the empty one when there is no program), so these priors are not theory-machine laws.
  * The identities A1–A12 are linear in the prior and are unaffected.
  * But c1 does not check Prop 2.1(e) ($M(\emptyset)=1-\Inc_0$), and its A10 ("$M^{\rm nc}\ge$ weight of the empty theory") uses only the explicitly listed empty theory.
  * rb1 checks the tape-level statements, R1.2(e) included.
  * *Fix:* put the missing mass on the empty theory, or say in the docstring that the stand-in is a sub-probability over theories.
* **(b) c2 B5's lower bounds are vacuous in five of its seven lines.** The block bounds $k\log\frac32+\log w_{\rm empty}$ are $-1.415$, $-0.830$ and $-0.245$ for $k=1,2,3$, and the single-datum bounds for $m=4$ and $m=8$ are $-1.000$ and $0.000$. A bound at or below $0$ is implied by $M^{1/2}\ge M$, so these lines test nothing. Only $k=4$ (0.340) and $m=16$ (1.000) are real tests. rb6 R6.6 runs the same test with $\varepsilon_\emptyset\ge\frac12$, where all six bounds are positive (0.17–2.23 bits), and the gaps exceed them by at least 3 bits. *Fix:* raise $w_{\rm empty}$ in B5, or note which lines are vacuous.
* **(c) c3's column header** "index of final theory (F15(b) bound)" is unexplained. *Fix:* relabel it.

---

## 4. Points checked and found correct that a reader might doubt

* **Prop 1.8(a), "at most two readings".**
  * If $\theta=\chi^{\wedge m}$ with $m\ge2$, then $\chi$ must be the left conjunct.
  * Stripping $\chi$ repeatedly stops exactly at $\chi$, because $\chi$ cannot be of the form $\chi\wedge X$.
  * Brute force agrees on all 129 958 trees (R6.3).
* **Thm 11.1(b), per-pair bound.** Under the normalised posterior the cell masses sum to at most 1, so the ratio is at least $1+p_{0\iota}$. The inequality $\log(1+v)\ge v$ on $[0,1]$ is correct for base-2 logarithms, with equality at both ends.
* **Thm 6.2(i), counting.** There are $2^\ell-1$ strings of length less than $\ell$, hence at most $3^{2^\ell-1}$ colours. In addition, $\ell_d>\log d-2$ because $\log\log3<0.67$; the exact-integer check covers $d\le3000$.
* **Lemma 3.3, the "+k+c".** The candidate index has a fixed length $k+2$, since $k$ is a constant. The proof uses $q=0.u-2^{-n}$ to make $q<\beta$ strict, which is correct (R6.1).
* **Prop 8.3(b), "most probable class".** Within $\Ext(T_j)$, every class other than $[T_j]$ is a strict extension. A most probable class exists, because only finitely many classes have mass above any positive threshold. So "the most probable class is a strict extension" follows from $[U]$ beating $[T_j]$.
* **Thm 5.4, Step 1.** The event $\{h_{t-1}=h\}$ factors into a $\xi$-event and the event $\{f^G\supseteq D_h\}$, and $\nu_G(\emptyset)=1$ is what makes $f^G$ total on every tape. Both points are used correctly.

---

## 5. Verification log

**Sources read.**
* `../../00-brief.md` (in full) and `00-brief.md` (this thread's brief).
* `notes.md` in full.
* `checks/c1_structure.py` (docstring and prior construction) and the outputs of c1–c4.
* P1 `sections/setting.tex` (Defs 3.2, 3.4, Ex 3.5, Thm 3.12).
* AI-paper `sections/model.tex` (Prop 2.22).
* The label tables of both papers (`main.aux`).

**Scripts run, and how.**
* Developer scripts: c1–c4 copied to the scratchpad and run with `python3`. Outputs compared with `cmp`: all four identical.
* Referee scripts: rb1–rb8 run in place to produce the saved outputs, then all copied to the scratchpad and re-run. Outputs compared with `cmp`: all eight identical.
  * Run times: rb1 2 s, rb2 under 1 s, rb3 3 s, rb4 36 s, rb5 under 1 s, rb6 9 s, rb7 9 s, rb8 under 1 s.
  * Python 3 with sympy 1.14.0 (rb4 only). Seed 20261016 throughout.

**Restart history.**
* A first run of this referee task was interrupted after rb1–rb3 had run and rb4 had been written.
* In this run I re-read rb1–rb3 and their outputs and found them sound, ran rb4, and wrote rb5–rb8.
* All eight were re-run from scratch copies at the end, so every saved output is complete and reproducible.

**Web.** I ran four WebSearch queries:
* Solovay / Vereshchagin / Shekhovtsov–Zakharov (twice);
* the geometric conditioning rule;
* Demski's process.

No page was fetched; the statements in m3 are at abstract or secondary-source level.

**Not done.**
* I did not test Lemma 8.0, Props 8.4–8.7, Props 11.4–11.5, Prop 6.4 or Prop 9.1 by code, as they have no finite stand-in; they were checked by hand only.
* I did not attempt the normalised order question on logically independent data (P1 Question A.8). R4.5 shows that a single pair cannot settle it. The disjointness trick of M1 might help; I found no proof.
* Statements about the universal machine are checked only through finite toy universal machines with explicit prefix-free codes.

**Git.** No git command that changes repository state was run.

**Epistemic policy.** This record is mathematical, and nothing here bears on the author's philosophical claims, so there is no "possible error" note.
