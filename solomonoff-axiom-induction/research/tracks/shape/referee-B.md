# Referee B (computation and counterexamples) for thread `shape`

*Adversarial referee report, 2026-10-16. Object: `notes.md` (this folder, 543 lines, as of 02:22) and its scripts in `checks/`. I wrote independent, seeded code in `referee_code/refB_*.py`. Each script writes `refB_*.out` next to itself. The code uses its own library `refB_lib.py`, which does not import or copy `checks/shapelib.py`: it has DIMACS-style literals, its own parallel unit propagation, forward chaining, brute-force entailment and prime implicates. I did not use referee A's files in the same folder (`refA_*`). I read referee A's draft issue list (`referee-A.md`, 02:37) only to mark where our findings overlap; every finding below was reproduced by my own code. No git command was run.*

## Verdict

**Sound in its mathematics, with three major issues of statement and reading, and no fatal one.**

**What survived.** Every theorem that can be checked on small cases survived exhaustive or large randomised tests with independent code:
* T2: Lemma 2.1, Prop 2.2, Prop 2.3, Lemma 2.4, Prop 2.5, Theorem 2.6, Cor 2.7, Cor 2.8;
* T3: Prop 3.1, Prop 3.2, Prop 3.3, Lemma 3.4, and the reduction inside Theorem 3.6 at n = 4, 5;
* T4: Prop 4.2(a), Prop 4.2(c);
* T5: Prop 5.1(c);
* T6: Lemma 6.1 and Theorem 6.2(a)–(e), exactly;
* T7: the whole s_k(m) table, Prop 7.1a, and the "only if" half of Theorem 7.1;
* T1: Prop 1.8 and Theorem 1.11.

All six developer scripts reproduce their saved outputs exactly. The headline new result, Theorem 2.6 (the unique minimum UP-usable theory over the base variables when d* ≥ 3), held on every law tested, by three independent methods (necessity of each clause together with usability, exact minima, and the core criterion of Cor 2.7(b)). Conjecture 7.1b now holds for m ≤ 16; the extended run is reported in §C.

**What did not survive.**
* **Issue 1.** The record's reading of the simplex family as a gap *between reasoners* is false for the hypothesis class it defines, which allows auxiliary variables. With auxiliary variables, unit propagation has a usable theory of O(m²) clauses: computed, and the clause counts are exact for r ≤ 7.
* **Issue 2.** The "vocabulary" separation for one law needs a reasoner whose propagation depth grows with m. This is computed, and for fixed depth there is a proof sketch from Håstad's theorem. So vocabulary and reasoner do not separate cleanly, contrary to Thm 4.3(4) and §10.
* **Issue 3.** The "iff" of Theorem 7.1 is false. The counterexample has a forced prime-implicate replacement, so no reading of the statement saves it.

There are also several minor errors in statements and counts (Issues 4–11).

---

## A. Re-run of the developer's scripts

All six scripts of `checks/` were copied to a scratch directory and run there. Each output was compared with the saved `.out`, ignoring the timing line.

| script | run time | output vs saved |
|---|---|---|
| `c1_linear_noaux.py` | 29 s | identical |
| `c2_intermediate.py` | 157 s | identical |
| `c3_directions_decider.py` | 1.5 s | identical |
| `c4_setting_depth2.py` | 4.7 s | identical |
| `c5_learning.py` | 1.3 s | identical |
| `c6_spanners.py` | 366 s | identical |

---

## B. Issues

### Major

**Issue 1 (major). The simplex "reasoner gap" holds only without auxiliary variables, or for one round of propagation. Under the record's own hypothesis class for UP it is polynomial.**

*Where.*
* Summary item 2: "exponential gaps in $K_{\rm lst}$, linear in bits under $Kt$".
* Theorem 1.12(a): "§2–§3's size bounds are bounds on $K_{\rm lst}$".
* The paragraph after Theorem 1.12: for the simplex family, "the gap between a unit-propagation reasoner and Gaussian elimination is … about $(m-1)/2$ bits under time charging, and a factor $2^{(m-1)/2}/\mathrm{poly}(m)$ in written length".
* Theorem 4.3(4): "between reasoners (GE against UP: Corollary 2.8 …)".
* §10 item 2, first bullet.
* Theorem 6.2(f): "under $Kt$ the gap is $m+O(\log m)$".

*Why it fails.* Definition 1.6 takes $H_{\mathrm{UP}}$ to be explicit theories over $X\cup Y$, so auxiliary variables are allowed. Corollary 2.8 is a statement about theories over $X$ only. Prop 3.2 gives every affine law a UP-usable library of size $\sum_u \min(2^{|u|-1},4|u|-6)$. For the simplex family that is $m(2m-4)$ clauses: polynomial.

*Evidence* (`refB_t3_aux.out`, part S).
* The circuit library with chain encodings is UP-usable for r = 3 (m = 7): exhaustive over all $3^7$ base partial assignments, with 2,352 entailed literals.
* It is also UP-usable for r = 4 (m = 15, 390 clauses, 90 auxiliary variables). All 15,360 minimal questions are answered, and the projection equals $\mathcal S$ over all $2^{15}$ base points. 4,000 random partial assignments were all answered correctly, and each inconsistent one ended in a conflict.
* The record's own listing code gives these lengths:

| r | m | PI over X (clauses; bits) | circuit library with aux (clauses; bits) | GE core (bits) |
|---|---|---|---|---|
| 3 | 7 | 56; 1,187 | 70; 1,531 | 60 |
| 4 | 15 | 1,920; 9.2·10⁴ | 390; 11,066 | 170 |
| 5 | 31 | 1,015,808; 1.1·10⁸ | 1,798; 62,280 | 456 |
| 6 | 63 | 1.35·10¹¹; 3.2·10¹³ | 7,686; 313,524 | 1,224 |
| 7 | 127 | 1.17·10²¹; 6.1·10²³ | 31,750; 1,488,480 | 3,229 |

So for UP to the fixpoint the written-length gap to GE grows polynomially (ratio 25 to 461 for r = 3 to 7), not as $2^{(m-1)/2}$. Under $Kt$ the gap is $O(\log m)$, because the library is printed in polynomial time.

*What does survive.*
* For $\mathrm{UP}_1$ the claims are true even with auxiliary variables. In round 1 a clause that contains an auxiliary literal cannot derive a base literal: that literal is unassigned, and α assigns only base variables. So a $\mathrm{UP}_1$-usable theory must contain $\mathrm{PI}(\mathcal S)$. Theorem 1.12(b)'s upper bound is in fact stated for $\mathrm{UP}_1$.
* For UP over $X$ the claims are Cor 2.8.
* With auxiliary variables and UP to the fixpoint, the only reasoner separation in the record is Theorem 3.6, which rests on GKRS 2019.

*Fix.*
* State the simplex gap for $\mathrm{UP}_1$ (or $\mathrm{UP}_k$ with k fixed: see Issue 2), or for UP over $X$.
* Add the polynomial library with auxiliary variables as a remark.
* In Theorem 4.3(4) and §10 item 2, cite Theorem 3.6, not Cor 2.8, for "between reasoners".
* In Theorem 1.12(a), say that §2's bounds apply to $K_{\rm lst}$ for the class without auxiliary variables (or for $\mathrm{UP}_1$).
* In Theorem 6.2(f), say "for the inducer without auxiliary variables".

*Overlap.* This is referee A's draft M1; I confirm it independently and with exact numbers.

**Issue 2 (major). Intermediate concepts help only a reasoner whose propagation depth grows with the law's width, so "vocabulary" and "reasoner" do not separate as §4 and §10 say.**

*Where.*
* §3.3 reading: intermediate concepts "make it usable by the weakest reasoner (Prop 3.1)".
* Theorem 4.3(4): "the large separations are … between vocabularies (… $2^{m-1}$ against $4m-6$)".
* §10 item 2, second bullet: "exponentially on the vocabulary for one law".

*Evidence.* `refB_misc3_depth.out` gives the least k for which each encoding of $x_1\oplus\dots\oplus x_m=0$ is $\mathrm{UP}_k$-usable, exhaustive over base partial assignments:

| m | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 |
|---|---|---|---|---|---|---|---|---|
| PI over X (2^(m-1) clauses) | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 |
| chain encoding of Prop 3.1 (4m-6 clauses) | 1 | 3 | 4 | 5 | 6 | 7 | 8 | 9 |
| balanced XOR tree (same size) | 2 | 3 | 3 | 4 | 5 | 5 | 5 | 5 |

* The chain needs m − 1 rounds; a balanced tree needs about $2\log_2 m$.
* The "weakest reasoner" in the record's own sense is $\mathrm{UP}_1$ (Theorem 1.11 calls it that). It cannot use intermediate concepts at all (Issue 1).
* For every fixed k, auxiliary variables cannot make one parity law polynomial. *Proof sketch, given Håstad.* The circuit of Lemma 3.5 without the prefix trick has, per round, an AND gate for each pair (clause, literal) and then an OR gate for each literal. That gives a depth-2k unbounded fan-in circuit with at most $k(\|F\|+N)$ gates whose inputs are the literals of α. On antecedents that assign all of $\mathrm{supp}(u)\setminus\{j\}$, its output for $x_j$ is the parity of $w-1$ input bits given with their negations. Håstad's bound (STOC 1986, pp. 6–20; the form $2^{\Omega(n^{1/(d-1)})}$ for depth d is taken from secondary sources) gives $\|F\|\ge2^{\Omega(w^{1/(2k-1)})}/k-N$, with $N\le\|F\|+m$.
* So for a reasoner of bounded depth the simplex family stays superpolynomial even with intermediate concepts, while for UP to the fixpoint it does not (Issue 1).

*Fix.* Add a remark: the depth that intermediate concepts require. The chain needs m − 1 rounds and a tree about $2\log_2 m$. For fixed k there is a superpolynomial lower bound, given Håstad. Then rephrase Theorem 4.3(4) and §10: the gap between $2^{m-1}$ and $4m-6$ is a separation between vocabularies *for reasoners that can propagate to depth Ω(log m)*. For bounded-depth reasoners, vocabulary and depth trade off, as §7 shows for the chain law. This also sharpens the textbook reading: a written theory with new intermediate quantities helps a reader only if the reader can chain many steps.

*Overlap.* Not in referee A's draft list.

**Issue 3 (major as a statement; its main consequence is unaffected). The "iff" of Theorem 7.1 is false for wide clauses, even when the prime-implicate replacement is forced.**

*Claim.* "An explicit theory over $X$, with clauses of any width, is $\mathrm{UP}_k$-usable for $\mathrm{Ch}_m$ iff, after replacing each clause by a prime implicate it contains, its edges form a k-hop TC-spanner."

*Counterexamples* (`refB_t7_spanners.out`, part A).
* m = 3, k = 1: $F=\{\neg x_1\vee x_2,\ \neg x_1\vee x_3,\ \neg x_2\vee x_1\vee x_3\}$. The wide clause contains exactly one prime implicate, $\neg x_2\vee x_3$. The forced replacement gives the edges {12, 13, 23}, a 1-hop TC-spanner. But F is not $\mathrm{UP}_1$-usable: from $x_3=0$ it does not derive $x_2=0$.
* m = 4, k = 2: $F=\{\neg x_1\vee x_2,\ \neg x_1\vee x_3,\ \neg x_3\vee x_4,\ \neg x_2\vee x_1\vee x_3\}$. The forced replacement gives the 2-hop spanner {12, 13, 23, 34}. F is not $\mathrm{UP}_2$-usable: from $x_4=0$ it does not derive $x_2=0$.

*Where the proof breaks.* Lemma 2.4 gives only one direction: the replaced theory derives at least as much.

*What survives.* The "only if" direction held in all 19 random usable wide theories, with 5 random replacement choices each. The minimum $s_k(m)$ is also unaffected.

*Fix.* State it as two parts: (i) every $\mathrm{UP}_k$-usable theory over $X$ becomes a k-hop TC-spanner under every replacement; (ii) a 2-CNF over $X$ is $\mathrm{UP}_k$-usable iff its edges form a k-hop TC-spanner. "Hence the minimum is $s_k(m)$" follows as before.

*Overlap.* This is referee A's M5; my counterexample additionally removes the ambiguity about which prime implicate is chosen.

### Minor

**Issue 4 (minor). Lemma 1.5 fails for the chain law with m = 2.**
* $F=\{\neg x_1\vee x_2,\ \neg x_2\vee x_1\}$ is compatible with all of $\mathcal Q(\mathrm{Ch}_2)$, both for UP and for $\mathrm{PS}_\infty$. Its projection is {00, 11}, not $\mathrm{Ch}_2$ = {00, 01, 11}.
* The hypothesis fails at the point 01, which is the only point of $\mathrm{Ch}_m$, m = 2..8, with no coordinate determined by the others (`refB_t1_setting.out`, part A).
* For $\mathrm{Ch}_3$, and for the affine laws tested, every compatible theory of at most 5 clauses has the right projection.
* Fix: say m ≥ 3. Section 7 and Theorem 7.2 use m ≥ 4, so nothing downstream changes. (Referee A draft, minor.)

**Issue 5 (minor). Prop 4.2(b) miscounts sound rules and overstates uniqueness.**
* Under Definition 4.1 a rule $P\Rightarrow\ell$ with $\ell\in P$ is sound, since its premise is consistent and $\mathcal S\wedge P\models\ell$. The parity law with m = 2..6 has 12, 54, 216, 810 and 2,916 sound rules (`refB_t4_rules.out`, part A), not $m2^{m-1}$ = 4, 12, 32, 80, 192.
* Excluding rules whose premise mentions the conclusion's variable gives exactly $m2^{m-1}$.
* Adding a trivial rule to a usable set keeps it usable, so "the unique usable rule set" is false. "The unique minimal usable rule set" is true: exhaustive for m = 3 (4,096 subsets), single-deletion tests for m = 4, 5.
* Fix: exclude rules with $\mathrm{var}(\ell)\in\mathrm{var}(P)$ in Definition 4.1, and say "unique minimal". (Referee A draft, minor.)

**Issue 6 (minor). Remark 2.9 understates the d* = 2 minima.**
* For $x_1=x_2=x_3=x_4$ the exact minimum UP-usable theory over $X$ has 4 clauses: a directed cycle $x_1\to x_2\to x_3\to x_4\to x_1$. The record mentions only the 6-clause chain of equivalences. For $x_1=x_2=x_3$ (simplex r = 2) the minimum is 3, not 4 (`refB_t2_linear.out`, part F).
* In general, one equivalence class of size c needs exactly c clauses: each variable needs a positive and a negative occurrence, and a cycle achieves this.
* Fix: replace "a spanning tree of each class suffices" with "a directed cycle on each class suffices, and is optimal for a single class". This partly answers open problem 1.

**Issue 7 (minor). The size formula of Prop 3.2 is wrong at weight 1 and does not match the construction at weight 4.**
* $\min(2^{|u|-1},4|u|-6)$ is −2 at $|u|=1$, which occurs when some variable is fixed (`refB_t3_aux.out`, part B).
* The construction says circuits of weight ≤ 3 are written directly and the rest chain-encoded. At weight 4 the chain encoding has 10 clauses against 8 direct, so the formula describes a different construction: the cheaper of the two encodings.
* Fix: define the library as "each circuit by the cheaper of its direct clauses and its chain encoding (direct for $|u|\le4$)", with size $\sum_u(2^{|u|-1}\text{ if }|u|\le4\text{, else }4|u|-6)$.

**Issue 8 (minor). The listing code needs $\ell_{\mathbb N}(0)$, which Elias delta does not provide.**
* Definition 1.6 uses $\ell_{\mathbb N}(N-m)$, which is $\ell_{\mathbb N}(0)$ whenever there are no auxiliary variables. It also uses $\ell_{\mathbb N}(|F|)$ with $F=\emptyset$, and Lemma 1.7 uses $\ell_{\mathbb N}(s-1)$.
* Elias delta codes only n ≥ 1.
* Fix: $\ell_{\mathbb N}(n):=$ the length of the delta code of n + 1.
* With that convention the Kraft sum over all theories over $X$ is 0.2525 for m = 2 (all 256 theories), and 0.2519 for m = 3 restricted to at most 6 clauses (`refB_t1_setting.out`, part B). Lemma 1.7 holds. (Referee A draft mentions Lemma 1.7 renaming, which is a different point.)

**Issue 9 (minor). The computed fractions in §3.2 come from one system per m, and vary a lot from system to system.**
* The record reports the fraction of questions the core answers as 0.803, 0.772 and 0.826 for m = 12, 16, 20.
* An independent replication, with 3 fresh systems × 1,000 questions per m and an independent sampler (`refB_misc_core.out`), gives per-system fractions 0.805–0.857 (m = 12), 0.701–0.789 (m = 16) and 0.736–0.876 (m = 20).
* The record's values lie within these ranges, but the spread (about ±0.07) is as large as the differences the record reports.
* Fix: report a range over several systems, or say "one system per m".

**Issue 10 (minor). §6's computed paragraph says the simulated all-patterns time "matched the coupon-collector expectation (21.7, 54.1, 129.9)".**
* Those are the theoretical values. The 12, 12 and 6 runs in `c5_learning.out` average 21.3, 49.3 and 126.5, which is consistent given the run counts.
* My 4,000-run simulation gives 21.52, 54.09 and 129.73, against exact $nH_n$ = 21.74, 54.09, 129.87.
* The approximation $2^{m-1}((m-1)\ln2+0.577)$ in Theorem 6.2(c) omits the +1/2 of $H_n\approx\ln n+\gamma+1/(2n)$: it gives 21.25 against 21.74 at m = 4.
* Fix: report simulated and exact values separately, and use $\approx 2^{m-1}((m-1)\ln 2+0.577)+\tfrac12$.

**Issue 11 (minor, suggestion). Prop 2.5 has an exact converse for every d*, which the record could state.**
* For all 40 random laws tested, including 33 with d* ≤ 2, a clause is contained in every UP-usable theory over $X$ iff it belongs to $F_{\rm ind}(\mathcal S)$ (`refB_t2_linear.out`, part C, "necessity" test: Imp(S) minus C usable or not).
* The converse has a three-line proof:
  * a non-prime implicate is never needed, because $\mathrm{PI}$ is usable;
  * for a clause of a decomposable circuit $u=u'+u''$ through i, the clauses of $u'$ and $u''$ lie in Imp(S) \ {C} and derive $x_i$ and then $x_j$.
* This shows that for d* ≤ 2 the difficulty in open problem 1 is not which clauses are forced, but the choice among alternatives.

---

## C. Claims tested and confirmed (independent code)

Each line gives the claim, the test, and the result. "Exhaustive" means all partial assignments or all theories in the stated range.

**T1 (`refB_t1_setting.out`, `refB_misc2.out`)**
* Lemma 1.5, for m ≥ 3 and the affine laws tested: all compatible theories have the right projection (see Issue 4 for m = 2).
* Prop 1.8: the point theory proves α → ℓ for all 7,480 questions of 30 laws.
* Theorem 1.11: the compiler $\kappa(F')=\mathrm{PI}(\mathrm{proj}\,F')$ is $\mathrm{UP}_1$-compatible in all 2,570 compatible triples, with F′ random theories with auxiliary variables and reasoners UP and $\mathrm{PS}_\infty$.

**T2 (`refB_t2_linear.out`, `refB_misc2.out`)**
* Lemma 2.1: 6,640 pairs (S, j) over 24 laws, with d* = 1, 2, 3, 4 occurring 8, 7, 6 and 3 times. (i), (ii) and (iii) agree everywhere.
* Prop 2.2 and Prop 2.3 (implicate width): 16 laws, no failure.
* Prop 2.3's bound against exact minimum CNF sizes (set cover by prime implicates): 14 laws, the bound holds everywhere and is tight in the 7 single-equation laws.
* Lemma 2.4, round by round: 7,200 runs on affine and chain laws, no violation.
* Prop 2.5 and Theorem 2.6 by necessity: in all 40 laws, $F_{\rm ind}$ is exactly the set of necessary clauses. For all 7 laws with d* ≥ 3, $F_{\rm ind}$ is usable.
* Theorem 2.6 on 30 targeted laws (part C2). Each law has m = 6, 7, k = 2, 3, d* ≥ 3, and at least one decomposable circuit, so $F_{\rm ind}\subsetneq\mathrm{PI}$: for example, 24 clauses against 64. In all 30:
  * $F_{\rm ind}$ is usable, by exhaustive test;
  * for every $C\in F_{\rm ind}$, the set of all implicates minus C is not usable.
  * Together these prove, for each law, that $F_{\rm ind}$ is the unique minimum among all theories over $X$.
* Theorem 2.6 by exact minima. Search over all subsets of PI in increasing size, assuming nothing about $F_{\rm ind}$, on 26 laws:
  * all 13 laws with d* ≥ 3 have $F_{\rm ind}$ as the unique minimum; 4 of them have k = 2, and 3 of those have $F_{\rm ind}\subsetneq\mathrm{PI}$;
  * for d* = 2 the minimum always contains $F_{\rm ind}$, and is sometimes much larger (10 vs 2; 7 vs 0).
* Cor 2.7(b): 60 random systems, plus 60 systems built to contain non-circuit rows. The prediction agrees with exhaustive usability in 120/120. The core was usable in 40 and in 0 of the two groups, so both outcomes are tested.
* Cor 2.8:
  * r = 3: $|\mathrm{PI}|=56$, 7 circuits of weight 4, every one of the 56 single deletions breaks usability;
  * the table for r = 3..7 recomputes exactly.
* Prop 5.1(c): the decider agrees with brute-force prime-implicate membership on 11,396 clauses over 25 laws.

**T3 (`refB_t3_aux.out`)**
* Prop 3.1: exhaustive over all partial assignments to base and auxiliary variables, consistent and inconsistent, for m = 4..7 and c = 0, 1. No failure, and $4m-6$ clauses.
* Prop 3.2: 6 random systems; the library is usable and conflict-complete, and its projection is $\mathcal S$.
* Prop 3.3: 5 systems (m = 7..9). The direct core, the chain-encoded core, and an arc-consistency closure computed by brute force per constraint agree on all base partial assignments.
* Lemma 3.4: usable theories with auxiliary variables detect every inconsistency. A non-usable core misses 4 inconsistent assignments, which shows the hypothesis is needed.
* Theorem 3.6 checks:
  * $\dim\mathcal H_n=n+1$ and $k=M-n$ for n = 4, 5; for n = 3 the dimension is 2, as the record notes;
  * "$x_t$ determined" ⇔ "XOR system unsatisfiable" ⇔ "$t\in\mathrm{span}$" on all 256 subsets at n = 4 and on 3,000 sampled subsets at n = 5;
  * for a usable theory for $\mathcal H_4$, UP derives $\neg x_t$ from $\alpha_S$ exactly when the system is unsatisfiable, on all 256 inputs.
  * The developer's 16-clause theory for $\mathcal H_4$ (the four weight-3 circuits through $x_t$) is indeed UP-usable with projection $\mathcal H_4$. I checked this separately because its description looked doubtful; it is correct.

**T4 (`refB_t4_rules.out`)**
* Prop 4.2(a): FC with rules(F) equals UP with F, state for state and conflict for conflict, in 20,000 runs (8,378 with conflicts), over round budgets 1–4 and the fixpoint.
* Prop 4.2(c): splitting preserves UP-usability, and rules(split) are FC-usable. The written-length ratios to PI are 5.4 and 6.0 for parity with m = 5 and 6, below the bound 9.

**T6 (`refB_t6_learning.out`)**
* Lemma 6.1: (i) ⇔ (ii) ⇔ (iii) on 35,424 + 36,000 (m = 3) and 96,000 (m = 4) pairs (theory, question). For m = 3 this includes every theory of at most 3 clauses.
* Theorem 6.2(a): among all 83,682 theories of at most 5 clauses for m = 3, exactly one is fully correct, and it is PI. No superset of a non-implicate is fully correct.
* Theorem 6.2(b):
  * all inclusion-minimal compatible theories, enumerated directly (129 for m = 3, 632 for m = 4);
  * random minimal hitting sets for m = 4, 5, 6 (1,087, 1,593 and 827 theories), each checked to be minimal with UP directly;
  * failures were never below the number of unseen patterns;
  * the bound is attained: the minimum of (failures − unseen) is 0;
  * the mean ratio of failures to unseen patterns is 6.6, 6.1 and 8.5.
* Theorem 6.2(c): coupon-collector values; see Issue 10.
* Theorem 6.2(d): the exact $W_{\rm lst}$ over *all* theories over $X$ (m = 3, block-complete data) gives $-\log_2W$ = 19.0, 33.0, 48.0 and 62.0 for r = 1, 2, 3, 4, against $rb_3$ = 14, 28, 42, 56. The bound holds with about 5–6 bits to spare.
* Theorem 6.2(e): the listing lengths are as claimed. The chain encoding is longer than PI for m ≤ 4 (172 against 145 bits at m = 4) and shorter from m = 5 on (241 against 410). Harmless, since the claim is asymptotic.

**T7 (`refB_t7_spanners.out`, `refB_t7_conj.out`)**
* Prime implicates of $\mathrm{Ch}_m$ are exactly the 2-clauses, m = 2..6.
* Exact $s_k(m)$ by two methods different from the developer's:
  * an exact search: iterative deepening over added edges, branching on the shortest uncovered pair over all ways to complete a path of at most k hops; used for m ≤ 12, 13 and 12 at k = 2, 3, 4;
  * an ILP with layered reachability variables, in which only the edge variables are integral (the developer used one variable per path), for m ≥ 6.
* Every entry of the record's table for k = 2 (m ≤ 16), k = 3 (m ≤ 13) and k = 4 (m ≤ 12) is confirmed. The optima for m ≤ 9 were re-checked as $\mathrm{UP}_k$-usable 2-CNFs.
* Prop 7.1a: the recursion, $\sum\lfloor\log_2 i\rfloor$, and the closed form agree for all n ≤ 3,000.
* Conjecture 7.1b: the ILP gives $s_2(16)=38=\sum_{i\le16}\lfloor\log_2i\rfloor$ in 34 s. The run for m = 17..22 is recorded in `refB_t7_conj.out` (status at the end of this report).
* Theorem 7.2: recursive Steiner (auxiliary-hub) constructions at depth 2 are $\mathrm{UP}_2$-usable for m = 4..14. They are never smaller than $s_2(m)$ (for example 48 against 31 at m = 14), and all lie above the bound.

---

## D. What I could not test

* Theorem 3.6's lower bound. It rests on GKRS 2019, and the full text was not available to the developer. Only the reduction was tested (part C, T3).
* Prop 7.3, which rests on CFL 1983.
* §8: Statman and Orevkov; Prop 8.1 is a proof sketch. Referee A's draft M4 concerns it.
* Theorem 5.2's dependence on the `sfi` record.
* The $K$-versus-$Kt$ issues in Theorem 1.12(b) and Prop 5.1(c) (referee A's draft M2). These are not computational.
* Theorem 7.2 itself. I checked its proof by hand (simplification, single sources, pairing, Harris) and found no gap. The constructions in part C only confirm that the bound is not violated by natural examples.

---

## Verification log

1. **Reading.**
   * The project brief and the thread brief in full.
   * `notes.md` in full (543 lines).
   * `checks/shapelib.py`, enough of it to make sure my library is independent of it.
   * c1 part D and c6, to identify their methods.
   * Referee A's draft list (`referee-A.md`, 02:37), only to mark overlaps.
2. **Re-runs.** c1–c6 re-run on scratch copies in `/tmp/claude-0/-home-user-AI-works/c4435474-536f-5a96-a73c-7d0c5ea93659/scratchpad/shape_rerun/`. All six outputs are identical to the saved ones apart from the timing line.
3. **Independent scripts** (in `referee_code/`, seed 20261016 or deterministic; outputs `.out` next to each):
   * `refB_lib.py`: the library.
   * `refB_t1_setting.py` (8 s): T1.
   * `refB_t2_linear.py` (36 s): T2, including part C2 (targeted laws with decomposable circuits).
   * `refB_t3_aux.py` (76 s): T3 and the simplex with auxiliary variables.
   * `refB_t4_rules.py` (1 s): T4.
   * `refB_t6_learning.py` (22 s): T6.
   * `refB_t7_spanners.py` (352 s): T7.
   * `refB_t7_conj.py`: Conjecture 7.1b for m = 16..22 (ILP, appends per m).
   * `refB_misc_core.py` (5 s): the §3.2 fractions.
   * `refB_misc2.py` (<1 s): Lemma 2.4, Prop 2.3 against exact minimum CNF size, Prop 5.1(c).
   * `refB_misc3_depth.py` (84 s): propagation depth of the encodings.
4. **Defects in my own code, found and fixed.**
   * `refB_t4_rules.py` first failed with a loop-variable error in part C; fixed and re-run.
   * `refB_t6_learning.py`'s first hitting-set enumerator was replaced by a random minimal hitting-set sampler, with minimality checked directly by UP, because exhaustive enumeration blew up for m ≥ 4. Exhaustive enumeration is kept for small |D|, where it ran.
   * Part E of t6 first included r = 0, which needs $2^{26}$ theories; dropped.
   * `refB_t7_spanners.py` part A was extended with forced-replacement counterexamples after I noticed that the first two counterexamples admit an alternative replacement.
   * One run of t7 was interrupted by a `pkill` that matched its own shell, and was restarted. The saved output is from a complete run.
   * `refB_t2_linear.py`:
     * part E first produced no system with a non-circuit row, so part E2 was added;
     * part D's laws with d* ≥ 3 were mostly single equations, so part C2 was added (targeted laws with decomposable circuits);
     * the numbers in §C are from the final run.
5. **Literature.**
   * Håstad, "Almost optimal lower bounds for small depth circuits", STOC 1986, pp. 6–20: bibliographic data confirmed by WebSearch. The depth-d form $2^{\Omega(n^{1/(d-1)})}$ is from secondary sources. It is used only in the proof sketch of Issue 2.
   * Emdin, Kulikov, Mihajlin, Slezkin (MFCS 2022; arXiv 2203.01082): the 3n lower bound and the $\Omega(2^{n/(s+1)}/n)$ bound cited in §3.1 match the abstract-level search result.
6. **Not done.**
   * No attempt to compute minimum usable theories *with* auxiliary variables: the search space is not finite in a useful sense.
   * No proof assistant.
7. **Restart safety.** No earlier `referee-B.md` or `refB_*` file existed when I started; `referee_code/` held only referee A's files. This report was first saved as a skeleton and then rewritten after the computations.
