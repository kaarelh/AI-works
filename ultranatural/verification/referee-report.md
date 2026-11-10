# Referee report on `ultranatural/note.md`

Referee: an independent AI referee (Claude), instructed to look for errors. Read: `note.md` in full (version with the status line "check … is in progress"), `code/*`, `results/*.out`, and Paper 1 `sections/ood.tex`. Date: 2026-11-10.

**Summary.**

* **No fatal error.** Every numbered statement (Theorem 1, Proposition 2, Lemma A, Theorem 3, Proposition 4, Theorem 5, Propositions 6–8, Theorem 9) is correct as stated, some with small gaps in definitions that are fixable in a line each.
* **Four major findings, all overclaims in "Answers in brief", in a heading, or in the headline numbers of the experiment** (M1–M4). The summary there says more than the body proves. In M1, M2 and M3 the summary is not just unproved: it is false as worded, and I give the argument.
* **One improvement:** the slack s in Theorem 5(3) can be removed (m1).
* **The experiment reproduces exactly.** My own exhaustive syntactic enumeration to 11 nodes (74,715,136 terms of size 11, direct recursive evaluation) gives the same 86,265 functions with the same least size for every one of them, the same distance profile, the same isolation counts and the same dissent tables. Every number in Section 6 matches the saved output. Reservations about what the dissent numbers mean are in M4.

---

## Findings by severity

### Fatal

None.

### Major

**M1. Answers item 4 misstates Proposition 6 (wrong exponent).**
* *Where:* "a change of machine by a bits can change the prediction only on a set of inputs of measure about 2^a/n".
* *What is wrong:* By Proposition 4 a change by a bits is harmless where sep(x; A | f) > 2a + K(f) + c. Proposition 6 then bounds the exceptional set by 2^(2a+K(f)+c)·((2a+K(f)+c)·ln 2 + ln(1/η))/n. The summary drops the factor 2 in the exponent, the factor 2^(K(f)) and the linear factor. The factor 2 of Proposition 4 is sharp input by input for the Kolmogorov version (see M2).
* *Fix:* "…only on a set of measure about 2^(2a+K(f))·(a+K(f))/n". The body (Section 3.4) is correct.

**M2. "SOI attains the bound" / "as stable as anything can be" is not proved, and for the Kolmogorov version the bound of Theorem 3 is not attained.**
* *Where:* Answers item 3 last sentence; heading of 3.2; last paragraph of 3.2; closing paragraph of the Answers ("no machine-independent notion … beyond SOI's own margin, and this is a theorem").
* *What is wrong:* Theorem 3 gives the upper bound sep(x; A) + c for every equivariant scheme. Proposition 4 gives the lower bound (sep(x; A | f) − K(f) − c)/2 for the Kolmogorov version. These differ by a factor 2 (and K(f)). Nothing shows that no equivariant scheme is stable beyond sep/2.
* *The factor 2 is real for the Kolmogorov version.* Let f be the simplest consistent total function on V, g a dissenting consistent total function of least V-complexity, and m = K_V(g) − K_V(f) (so m ≤ sep(x; A) + c by the floor). Assume m ≥ 3. For any integer a with m/2 < a < m put L = K_V(g) − a, and let P be the finite set of V-programs of length ≤ L that compute total functions consistent with D and agreeing with f at x. Define V″ = V except: each p ∈ P is replaced by p·1·0^(a−1) (same output), and p_f·0^(L−K_V(f)) outputs g, where p_f ∈ P is a shortest program for f. The domain stays prefix-free, every complexity moves by at most a, so V″ is universal with dist(V, V″) ≤ a; on V″ every consistent function agreeing with f at x has complexity > L ≥ K_V″(g). So the Kolmogorov prediction at x flips at distance ⌊m/2⌋ + 1 ≤ (sep(x; A) + c)/2 + 1. Proposition 4 is therefore tight, and the Kolmogorov version's stability radius is about half the bound of Theorem 3.
* *Fix:* Rename 3.2 "SOI is within a factor 2 of the bound". Replace "it is already as stable as anything can be" by "it is stable up to about half that distance; whether an equivariant scheme can be stable beyond sep/2 is open". State the sharpness of Proposition 4 (construction above). Add the question to Section 7. In the closing paragraph say "no relabelling-equivariant scheme is stable at x beyond sep(x; A) + O(1) bits of machine change; SOI is stable to about half of that".

**M3. Answers item 2 overstates Proposition 2; in the regime the question is about, the naive tally is not swamped.**
* *Where:* Answers item 2 ("A tally of properties that ignores what each property was tested on is swamped by such never-tested properties (Proposition 2)"; "It costs sep(x; A) bits whatever f is"; "is always the same one"); Section 2, "The tally is then decided by properties that the data never tested on inputs like x".
* *What is wrong, (a):* Proposition 2 shows swamping only when 2^(−sep(x; A)) ≫ W_tot(D), i.e. sep(x; A) ≪ L(D) ≤ K(f). For a simple target (successor, addition) and a typical new input, sep ≈ log n ≫ K(f) and the proposition says nothing. There the graph of f alone gives v(y′) ≥ 2^(−K(f)−c) for every wrong y′, which exceeds the guard terms 2^(−sep).
* *(b) The naive tally in fact works at typical inputs.* For i.i.d. samples and a fresh x, each property P with t_P = μ{x′ : (x′, f(x′)) ∉ P} is true so far and excludes the right label at x with probability t_P(1−t_P)ⁿ ≤ 1/(n+1). So E[v(f(x))] ≤ 1/(n+1), while v(y′) ≥ 2^(−K(f)−c) always. With probability 1 − η the right label breaks the least weight as soon as n + 1 > 2^(K(f)+c)/η. This is the same 2^(K(f))/n rate as SOI's per-step bound (Paper 1, Remark 8.9(iv), `rem:ood:answer`).
* *(c) "whatever f is", "always the same one":* Theorem 1(2) gives sep(x; A | f) − c ≤ excl(x, f(x)) ≤ sep(x; A) + c, so the cost is sep(x; A) only up to K(f) + c. Example: all labels so far are 0 and f(x) = 1; the property "the label is never 1" costs O(1), is true so far and is broken by the right label, and it is not of the form "no input like x occurs".
* *(d)* Even in the swamped regime, "decided by never-tested properties" is not what is proved: what is proved is that graphs of consistent functions are a negligible part of each side. Tested non-functional properties (e.g. "the label is never y′") also contribute.
* *Fix:* Item 2: "The cheapest property that the right label breaks costs sep(x; A) up to K(f) bits; for simple f it is essentially 'no input like x occurs'. At inputs with sep(x; A) well below L(D) a tally that ignores records is dominated by guard properties on both sides (Proposition 2); at typical inputs it agrees with SOI." Add (b) as a remark after Proposition 2 and note that the hypothesis forces sep(x; A) < K(f). Weaken the sentence in (d) to "the consistent functions are then a negligible part of the tally".

**M4. The headline dissent numbers (Answers item 8; Section 6 tables, first number in each cell) depend on the 11-node cap.**
* *Where:* "some enumerated hypothesis … still disagrees with addition at 38% of the unseen inputs; among hypotheses isolated at δ = 1/6 this drops to 4%, and at δ = 1/3 to none"; "(functions above 11 nodes are left out, so this is a lower estimate)"; "Among isolated hypotheses it is gone after a few samples".
* *What is wrong:* The language can express every function on the grid (ifz and P give all threshold tests), so with no cap some consistent hypothesis dissents at every unseen input: the "all hypotheses" fraction tends to 1. With my data (`extra_checks.out`, addition, n = 16): caps 9 / 10 / 11 give 0.20 / 0.28 / 0.38 for all hypotheses and 0 / 0.033 / 0.036 for δ = 1/6. In the isolated class every least dissenter has size 10 or 11, so the bracketed posterior there (1·10⁻⁶) is carried by the two sizes next to the cap, and the omitted tail is of the same order. "Lower estimate" is also not rigorous: truncation removes mass from numerator and denominator (in practice the denominator hardly moves: the total weight 8^(−K) of functions above 11 nodes, extrapolated geometrically from the ratio 0.40 between sizes 10 and 11, is about 5·10⁻⁶, against 8⁻⁵ = 3·10⁻⁵ for addition).
* *What is robust:* the second number in each cell (a dissenter of size ≤ K + 2; exact, since all sizes ≤ 11 are enumerated) and the vanilla posterior (dominated by sizes 7–9). The ordering vanilla ≫ isolated holds at every cap I tried.
* *Sampling noise:* over 8 seeds the 0.38 is 0.377 ± 0.010 and the 0.04 is 0.036 ± 0.005 (300 trials each).
* *Fix:* In item 8 and Section 6 lead with the cap-independent statistics ("a hypothesis of size ≤ K+2 dissents at 7% of unseen inputs, among δ=1/6-isolated ones at none; wrong-label posterior 2·10⁻³ against about 10⁻⁶, truncated at 11 nodes"). State that the "some enumerated hypothesis" fraction grows with the cap and tends to 1 without the restriction. Replace "lower estimate" by "truncated at 11 nodes". Replace "after a few samples" by the actual n (addition, δ = 1/6: 0.23 at n = 8, 0.04 at 16, 0.009 at 24, 0 at 32). Give the seed spread.

### Minor

**m1. Theorem 5(3), converse: the slack s is unnecessary.** If π(E) ≥ 2^(−K_tot(E)−b) for every data set E, then π({g}) ≥ 2^(−K(g)−b) for every total computable g: take E_n = g on the first n inputs; K_tot(E_n) = K(g) for large n (finitely many simpler functions, each refuted eventually) and π(E_n) ↓ π({g}). Hence π(E) ≥ 2^(−b)·W_tot(E) for all E, and pin_π − pin_{W_tot} = log(W_tot(D′)/π(D′)) + log(π(D)/W_tot(D)) ≤ b + L(D). *Fix:* state the converse as "≤ L(D) + b" and drop s here and in the "Reading" bullet. As written, Answers item 5 (which has no s) is not covered by Theorem 5; with this change it is.

**m2. Definitions in 3.1 do not cover everything they are used for.**
* A reference machine is defined as a map from programs to functions X ⇀ Y. But K(Q), K(ρ), K(y) in Lemma A/Theorem 3, and sep_V(x; A | f), K_V(f) in Proposition 4, need complexities of sets, labels and relabellings, and conditional complexity. *Fix:* say that K of sets, labels and relabellings is always taken on the fixed machine of Section 1 and that c may depend on V (not on V′); in Proposition 4 write sep(x; A | f) without the subscript, or replace the hypothesis by "2a < m_V − K_V(f), m_V the least K_V of a dissenting consistent total function", which is all the proof uses.
* "Any tally of properties is equivariant, provided the properties are described on the same relabelled machine" needs the machine to describe properties and V^ρ to act on them by P ↦ ρP; then K_{V^ρ}(ρP) = K_V(P) and the distance bound of Lemma A extends by the same proof. Say so.
* The one-tape and per-query versions use machines of another type (random tapes); "V^ρ" has to be defined for them (post-compose the output with ρ). The equivariance claim is then right.
* Section 1 does not say how the Kolmogorov version breaks ties; 3.1 does (order of programs). Move it to Section 1.

**m3. The margin sentence after Theorem 1.** "…between sep(x; A | f) − c and K(f) + sep(x; A) + c … the same quantity up to K(f) + c": with the bounds as written the gap is up to 2K(f) + c. It is K(f) + c if the floor is used in conditional form, K(f) + sep(x; A | f) + c (describe f, then Q given f), which is true. *Fix:* use the conditional floor.

**m4. The "repair" paragraph after Proposition 2 is a sketch.**
* A uniform law on "the labels a property allows" needs finite Y (or finite fibres); Section 1 allows countable Y, and then the guard property P_Q has no likelihood.
* "It is a mixture of product laws … so the repaired tally is SOI": what follows is that the repaired tally lies between 2^(−c)·W_tot and 2^c·M_prod (Paper 1), and those agree only up to K(dom D) + O(1) bits, which is typically more than sep(x; A). *Fix:* restrict to finite Y and say "is a version of SOI, between W_tot and the product mixture".

**m5. Proposition 8(3).** Q_g must be the exact set { x : g(x) ≠ f(x) } (the proof uses this; the statement says "differs only on a set Q_g"). The title "Patches are not isolated" claims more than the statement: it covers only patches whose guard is at least as complex as f given f. The general fact is the definition itself (g is not isolated iff some f ≠ g within δ has K(f) ≤ K(g)). *Fix:* define Q_g; retitle "Patches with costly guards are not isolated".

**m6. Proposition 8(4) and null sets.** κ(δ) is over nonempty Q with μ(Q) < δ, which admits nonempty μ-null sets. With μ uniform on {0,1}^d and X all strings, the singleton of the empty string gives κ(δ) = O(1) for every δ, so no f has margin above c at any scale, and δ-isolated functions must be the simplest in their μ-a.e. class. The example in the text (all-zero string, K(d) + O(1)) understates this. Nothing is false, but the notion depends on values outside supp μ. *Fix:* take X = supp μ or identify functions μ-almost everywhere, and say so in the definition.

**m7. Universal-distribution paragraph.** "Sets of measure below δ have complexity at least log(1/δ) − c" needs "nonempty". Proof (missing): the least element x_Q has K(x_Q) ≤ K(Q) + c, so m(Q) ≥ 2^(−K(Q)−c). The margin log(1/δ) − 2K(f) − c is right. m is a semimeasure and not computable; for Proposition 7 and Theorem 9 it must be normalised. Say so.

**m8. "What it costs", first bullet.** Theorem 9 is about data labelled by f. With data labelled by the patch g†, the confidence statement holds only while no sample has fallen in the patch (probability (1−ε)ⁿ), and conditionally on that the rate is ((1−δ)/(1−ε))ⁿ, not (1−δ)ⁿ. "Converges to f" is wrong for n ≫ 1/ε: f is refuted at the first sample in the patch. *Fix:* "for n ≪ 1/ε it predicts f on the patch with confidence 1 − 2^(K(f))·((1−δ)/(1−ε))ⁿ/η; at the first sample in the patch f is refuted and …".

**m9. "What it costs", second bullet.** The two-sided bound is correct, but the lower bound ε·W_tot(D + (x,y)) is up to 2^(K(f)) below "vanilla SOI's floor scaled by ε", so the sentence that follows does not follow from it. Since π_ε(D) ≤ W_tot(D) (the patch-free prior, as defined, is an unnormalised part of W_tot), the lower bound ε·W_tot(D + (x,y))/W_tot(D) = ε·(vanilla wrong-label probability) holds. *Fix:* use it.

**m10. "What it costs", third bullet.** Proposition 8(5) needs μ(Q) < δ; the cheapest Q separating x from A may have measure ≥ δ. The flipped, equally confident prediction follows from Theorem 3 alone; "regards f as its near-miss" needs μ(Q) < δ. Add the condition.

**m11. Open question 2 states a false sufficient condition.** δ_n·n → ∞ gives error 2^(K(f))·e^(−δ_n·n) → 0 (consistency) but not super-polynomial pinning: δ_n = (log log n)/n gives 1/log n. Needs δ_n·n/log n → ∞.

**m12. Section 4, "about" and "of order 1/n".**
* The far row of the table is a lower bound only ("at least δn·log e − log(1/η) bits"), not "about".
* "SOI's remaining doubt … of order 1/n" (also Answers items 6, 7; Section 5): the note proves only the lower bound 2^(−K(f)−c)/(n·log² n), with probability ¾, for uniform μ on {0,1}^d. The upper bound 2^(K(f)+c)/(n+1), in distribution, is in Paper 1 (Remark 8.9(iv)); cite it and say "between 1/(n log² n) and 1/n up to 2^(±K(f))".
* "In the same setting" in Section 5 imports the uniform-cube assumption silently.

**m13. Answers item 7.** "with error at most 2^(K(f))·(1−δ)ⁿ" is the expected posterior mass off f (or: error < η with probability 1 − 2^(K(f))(1−δ)ⁿ/η). Say "expected".

**m14. Answers item 1.** The window proved is K(f) + c ≤ k < sep(x; A | f) − c, and sep(x; A | f) can be K(f) below sep(x; A). "The window … is, up to constants, SOI's own margin" should be "up to K(f) + O(1)" (the body says this correctly).

**m15. Theorem 3(2) and Answers item 3.** The distance is K(Q) + K(y) + K(y′) + c; "sep(x; A) + O(1)" is for binary labels. The flip is to "the opposite answer" only if y is chosen as S_V(D, x). Item 3's heading "applies to every scheme" should read "every relabelling-equivariant scheme".

**m16. Section 6, statements not supported by the output.**
* "It is S(P(x+y))": three functions of size 7 lie within distance 5 of addition and five within distance 6 (`extra_checks.out`, 4a: "x+1 where y = 0 and x ≥ 1" and its mirror at distance 5, the (0,0) patch at distance 1, "x+1 where y = 0" and "y+1 where x = 0" at distance 6). S(P(x+y)) is the only one at distance 1. Say "the one at distance 1 is".
* "isolation separates successor, addition and product from their patches": only patches of addition were examined.
* "The fourth is isolated only below δ = 5/36": R = 5 means isolated for δ ≤ 5/36 (inclusive).
* Two of the patched additions ("y+1 where x=0", "x where y≤1") are at distance 6 from addition; their R = 1 comes from an equally complex function at distance 1 (`extra_checks.out`, 4b), not from addition. The sentence in the note is literally true but the reader will assume addition is the neighbour.
* The language description omits that a closed term is run with a = 0 and that n and init of It are evaluated in the enclosing environment (both are in the docstring of `enumerate_pr.py`).
* "fixed before any results were seen" cannot be checked from the repository.

**m17. Remark 1.1** asserts "the same proofs give the bounds with c.e. separation" without proof. I believe it for Propositions 4, 6, 8(3,4) (the disagreement set of a partial g with a total f is c.e., and counting c.e. sets by program length is the same). For the Kolmogorov version over partial hypotheses the prediction at an x where the simplest hypothesis is undefined needs a convention.

### Wording

* **w1.** After Theorem 1: "Non-functional properties add nothing beyond what functions give" holds only for k inside the window; at level sep they are exactly what excludes the right label.
* **w2.** Section 4: additive maps "differ on half of all inputs" is "at least half" unless the codomain is GF(2).
* **w3.** Answers item 6: "about log n bits" is K(f) + log n + 2·log log n + c.
* **w4.** Remark 2.1: "only adds ways to exclude the right label" — it adds ways to exclude every label; the point is that wrong labels were already excluded at K(f) + c.
* **w5.** "Reading" after Theorem 5: "a learner that charges an exception m times its description length learns patched functions m times more slowly" is a heuristic, not a consequence of the theorem.
* **w6.** Proposition 6 says "let f be total"; K(· | f) needs f total computable (Proposition 7 does not).
* **w7.** Paper 1's floor for W and M_F is relative, ν(D + (x,y)) ≥ 2^(−K(Q)−K(y)−c)·ν(D), with no K(f) in the posterior. The note's W_tot floor carries 2^(−K(f)); worth one sentence, since the relative form is not available for sums over functions (no coding theorem there).

---

## Per-statement verdicts

| statement | verdict | note |
|---|---|---|
| Section 1 facts (K(Q) ≤ K(Q∣f)+K(f)+c, at most 2^k objects with K ≤ k, floor) | correct | prefix-free count ≤ 2^k by Kraft; tie-breaking of the Kolmogorov version unspecified (m2) |
| Remark 1.1 | plausible, unproved | m17 |
| Theorem 1 (1)–(4) | correct | separating set { x′ : (x′, f(x′)) ∉ P } is decidable (f total, P decidable), contains x, misses A |
| margin sentence after Theorem 1 | correct with a gap | needs the conditional floor (m3) |
| Proposition 2 (1), (2) and the identity v(y′) − v(y) = m(y,y′) − m(y′,y) | correct | |
| text after Proposition 2 ("decided by never-tested properties", "the repaired tally is SOI") | overclaim / sketch | M3(d), m4 |
| Remark 2.1 | correct | w4 |
| Lemma A | correct | V^ρ(p) = ρ∘V(p); K_{V^ρ}(g) = K_V(ρ⁻¹g); wrapper machine has prefix-free domain; c depends on V only |
| equivariance of the listed schemes | correct with a gap | Kolmogorov with program-order ties, W, W_tot, steeper priors, patch-free: checked. Tally of properties and tape versions need the machine extended (m2) |
| Theorem 3 (1)–(3) | correct | (2) includes K(y) + K(y′) (m15) |
| Proposition 4 | correct with a gap | sep_V(· ∣ f) undefined (m2); the set { g ≠ f } is decidable, contains x, misses A. Tight up to +1 (M2) |
| sentence "between (sep(x;A∣f) − K(f) − c)/2 and sep(x;A) + c" | correct, not sharp | upper end can be (sep + c)/2 + 1 for the Kolmogorov version (M2) |
| heading "SOI attains the bound" | wrong | M2 |
| Theorem 5 (1), (2) | correct | |
| Theorem 5 (3), π_f | correct | regret ≤ K + 1; ½ ≤ π_f(D) ≤ 1; difference in [L(D), L(D)+1] |
| Theorem 5 (3), converse | correct, improvable | direction and s ≥ 0 are right; s can be dropped (m1) |
| Proposition 6 | correct | union bound: 2^a·e^(−tn) = η |
| Proposition 4 + 6 sentence | correct | Answers item 4 misquotes it (M1) |
| Proposition 7 and "δn·log e − log(1/η)" | correct | 2^k(1−δ)ⁿ ≤ e^(δn)·η·e^(−δn) = η |
| cone computation (n ≤ 2^(d−3), ¾, K(Q) ≤ log n + 2 log log n + c, posterior ≥ 2^(−K(f)−c)/(n log² n)) | correct | Q = all strings with the given prefix of length ⌈log n⌉+2 ≤ d−1; μ(Q) ≤ 1/(4n); (1−μ(Q))ⁿ ≥ ¾ |
| rigid classes (translations, additive maps, polynomials, addition) | correct | w2 |
| Proposition 8 (1), (2) | correct | |
| Proposition 8 (3) | correct with a gap | Q_g must be the exact disagreement set (m5) |
| Proposition 8 (4) | correct | null-set caveat (m6) |
| Proposition 8 (5) | correct | ρf ≠ f because f = y somewhere on Q; K_{V^ρ}(f) = K_V(ρ⁻¹f) = K_V(ρf) since ρ is an involution; K_{V^ρ}(ρf) = K_V(f) |
| "sets of measure below δ have complexity ≥ log(1/δ) − c" | correct with a gap | add "nonempty"; proof missing (m7) |
| "isolated with margin ≥ log(1/δ) − 2K(f) − c" | correct | from 8(4) and κ(δ ∣ f) ≥ κ(δ) − K(f) − c |
| patch-free induction is equivariant | correct | isolated set for V^ρ = ρ(isolated set for V); ρ preserves d |
| Theorem 9 (1) | correct | |
| Theorem 9 (2) | correct | E[R] ≤ (1−δ)ⁿ; R/(2^(−K(f)) + R) ≤ 2^(K(f))·R; Markov |
| "What it costs", bullet 1 | wrong as worded | m8 |
| "What it costs", bullet 2 (π_ε) | correct; following sentence needs a better lower bound | regret K + log(1/ε); both bounds check (also if the patch-free prior is normalised); m9 |
| "What it costs", bullet 3 | correct with a gap | m10 |
| Open question 2, embedded claim | wrong | m11 |
| Answers 1 | overclaim in wording | m14 |
| Answers 2 | overclaim | M3 |
| Answers 3 | overclaim (last sentence) | M2, m15 |
| Answers 4 | wrong exponent | M1 |
| Answers 5 | true, but not what Theorem 5 states | needs m1 |
| Answers 6 | follows, loosely worded | m12, w3 |
| Answers 7 | follows; "error" is expected error; "1/n" not proved here | m12, m13 |
| Answers 8 | numbers correct; three of them are cap-dependent | M4 |
| closing paragraph of Answers | overclaim | M2 |

---

## Task B: the experiment

### B1. Code review (`code/`)

No bug found.

* **`enumerate_pr.py`.** Semantics as documented: S, P saturate at 31 and 0; It(n, body, init) evaluates n and init in the enclosing environment and iterates body with a := current value (`body[ROW, cur]`, masked by n ≥ k); ifz(c, u, v) = u iff c = 0. Behaviour tables cover all 36 inputs × all 32 values of a, which is every value a can take, so deduplication by behaviour is sound: the semantics is compositional, hence a least term for a behaviour can be built from least terms of its subterms' behaviours, and enumerating by increasing size over representatives finds every least size. Size splits cover all compositions of s − 1 into three positive parts. Closed functions take a = 0 and keep the first (smallest) index.
* **`nearest.c`.** Least K at each exact Hamming distance; d = 0 cannot occur (functions are distinct). Rows are written by one thread each.
* **`analyze.py`.** `within` is the running minimum over distances ≤ r. R is the first distance with a function of size ≤ K(f), so f is δ-isolated iff R ≥ 36δ; "isolated at radius r" is R ≥ r, i.e. no function of size ≤ K at distance < r. No off-by-one. Dissent statistics are computed as described. The comment "so e is a lower estimate" is not rigorous (M4).
* **Docstring vs note.** The docstring writes x + y as It(y,S(a),x), the note as It(x,S(a),y); both are 5-node terms for addition.
* **Reproducibility.** Rerunning `analyze.py` on the saved `pr11.npz`, `nearest11.npy` reproduces `results/analyze_pr11.out` byte for byte. `results/*.npz` and `*.npy` are git-ignored, so a reader must rerun the enumeration (3 minutes) to get them.

### B2. Independent implementation (this folder)

| file | what it is |
|---|---|
| `independent_check.py`, `independent_check_8.out` | Pure Python, as specified: all terms up to 8 nodes generated syntactically (4, 8, 16, 160, 1088, 5248, 33024, 244224 terms), each evaluated by a direct recursive evaluator on the 36 inputs with a = 0. |
| `independent_full.c`, `independent_full_11.out` | The same method in C up to 11 nodes (74,715,136 terms of size 11), no semantic pruning. |
| `independent_profile.c` | Own distance profile for all 86,265 functions. |
| `independent_analysis.py`, `independent_analysis_11.out` | Own K, R, named-function table, isolation counts, and own implementation of the dissent statistics on the same random stream (seed 0); exact comparison with the authors' `pr11.npz` and `nearest11.npy`. |
| `independent_open.c`, `independent_open_11.out` | Count of distinct behaviours of open terms on (x, y, a), by the same syntactic enumeration. |
| `extra_checks.py`, `extra_checks.out` | Cap sensitivity, seed spread, neighbours of addition and of its patches. |
| `run_all.sh` | Runs everything. |

Results:

| quantity | mine | saved output | match |
|---|---|---|---|
| distinct functions by least size, K = 1..8 (Python) | 3, 5, 7, 15, 70, 215, 558, 1550 | same | yes |
| distinct functions by least size, K = 9, 10, 11 (C) | 5359, 18617, 59866; total 86,265 | same | yes |
| set of functions and least size of each (all 86,265) | — | — | identical |
| distance profile (86,265 × 36 entries) | — | `nearest11.npy` | identical |
| successor: K, R | 2, 30 | 2, 30 | yes |
| addition: K, R | 5, 24 | 5, 24 | yes |
| least size at Hamming distance exactly 1 from addition | 7 (unique function: 0 → 1 at (0,0); least terms S(P(It(x,S(a),y))) and S(P(It(y,S(a),x)))) | 7 | yes |
| named-function table (K, R, within-r profile), all 13 expressible functions | — | Part 1 | identical |
| isolation counts by K and r (Part 2), all 12 rows | — | Part 2 | identical |
| dissent tables (Part 3), 5 targets × 8 n × 4 classes | — | Part 3 | identical to the printed precision |
| behaviours of open terms, sizes 1..9 | 4, 7, 11, 39, 221, 743, 2151, 8423, 36810 | same | yes |
| behaviours of open terms, sizes 10, 11 and total | 142637, 507475; total 698,521 | same | yes |

Notes on the comparison.

* The Python script alone (the check that was asked for) already fixes the counts for K ≤ 8, and K and R for successor and addition, since R only involves functions of size ≤ K.
* The C run is the same method carried to 11 nodes. It confirms the whole enumeration, so the recorded sizes are exact minima.
* My dissent statistics are a separate implementation but draw the same random samples as `analyze.py` (seed 0, same order of calls), so agreement is exact and not just statistical. Other seeds: `extra_checks.out`.
* Open-term behaviours are identified by a 128-bit hash of the 1152-entry table; the per-size counts agree with `enumerate_pr11.out` at every size.
* The comparison with `pr11.npz` and `nearest11.npy` needs those two files, which are not in git.

### B3. Section 6 of the note against `results/analyze_pr11.out`

Every number checks.

* **Language and counts.** 698,521 behaviours, 86,265 functions, 59,866 of size 11: match `enumerate_pr11.out`.
* **Named-function table.** All ten rows (K, R, within 1, within 6, term) match Part 1.
* **Scales.** R = 30 and 24 give isolation up to 5/6 and 2/3. Three of four patches have R = 1; the fourth has R = 5.
* **How common.** 10863/86265 = 12.59%, 1332/86265 = 1.54%, 391/86265 = 0.453%; size 11: 6682/59866 = 11.16%, 645/59866 = 1.08%, 112/59866 = 0.187%. The note's 12.6, 1.5, 0.45, 11.2, 1.1, 0.19 are correct roundings.
* **Dissent tables.** All 30 cells (addition and successor, n = 4, 8, 16, 32, 48, three classes) are correct roundings of the c, b and e entries. Answers item 8 (38%, 4%, none; 30 of 36; 24 of 36; "about 13%") matches.
* **Reservations** are about interpretation, not arithmetic: M4 (cap dependence, "lower estimate", "a few samples") and m16.
