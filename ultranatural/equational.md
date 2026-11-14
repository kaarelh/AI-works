# The equational inductor

*Induction over laws stated in a fixed vocabulary, and how strongly it pins down addition*

A second research note by Claude (Anthropic), following [`note.md`](note.md), in response to a question from Kaarel Hänni. Draft. One independent AI referee checked every statement of the first version and re-implemented the computations; its report is in [`verification/referee-report-equational.md`](verification/referee-report-equational.md). This version applies its corrections and adds Proposition 4a and the referee's Proposition 10; a second pass on the changes is pending. No human has checked the mathematics.

## The question

[`note.md`](note.md) asked whether many properties of input–output pairs can pin a function down more strongly than Solomonoff operator induction (SOI) does, and found that they cannot: one guard breaks all of them at once. Hänni then asked about properties of the *whole function*. Addition satisfies many short universally quantified statements. Is there something there that pins down plus over quus?

This note studies the simplest inductor of that kind. Its hypotheses are finite sets of *identities* (universally quantified equations) in the vocabulary {0, S, f}, where f is the function being learned and S is successor. There are no other symbols: no auxiliary functions and no case distinctions.

## Answers in brief

1. **The inductor.** A hypothesis is a finite set T of identities, with prior weight exponentially small in its number of symbols. T *fits* the data if it is consistent (it proves no equation between two different numerals) and proves every datum f(x) = y by equational reasoning. The belief in a label y at a new input x is the posterior weight of the fitting sets that prove f(x) = y. Beliefs need not add up to 1: the rest is "undetermined" (Section 1).
2. **Laws must be true so far.** A set that fits the data contains no identity that the data refute, where an identity is refuted when some instance of it can be evaluated from the data alone and comes out false (Lemma 1). This is the notion of a property "true of all pairs so far", for laws.
3. **Addition is pinned at every input, with strength linear in the side of the data square.** Suppose the data contain x + y for all x, y < n. Then every fitting set whose identities have sides of at most n + 1 symbols is true of addition, and so proves no wrong sum anywhere (Theorems 2 and 3). A wrong sum at any input, however far, needs an identity longer than n. The belief in any wrong sum is at most 2^(36.5 − 0.485·n). This says something from n = 76 on (the exact bound from n = 59; it is 2^(−71) at n = 200). SOI, given the same square, keeps probability at least about 2^(−K(n)), roughly 1/n or more, for a wrong sum just outside it. The same holds for successor, with the bound 2^(13 − 1.58·n). A few missing pairs do not matter unless they are small (Proposition 4a).
4. **What exceptions cost.** Call the least size of a fitting set for all values of g its *law complexity*. Plus has law complexity at most 12. Quus with threshold N (x + y if x, y < N, else 5) has law complexity between N + 3 and 2N³ + 2N² + 2N + 18, and plus with one value changed at (a, b) has at least max(a, b) + 3 (Proposition 5). In SOI such exceptions cost about K(N) bits, at most about log N. So the equational inductor prefers plus to quus by at least N − 9 symbols where SOI prefers it by about log N bits.
5. **The price.** The inductor's loss is never less than SOI's by more than a constant. If quus is the truth, then at the first exception, having seen the square below N, the inductor gives the true label belief at most 2^(36.5 − 0.485·N): a loss of at least about N/2 bits (Proposition 7). Some simple functions have no finite set of identities at all, squaring for one (Proposition 6). On those its loss grows without bound.
6. **Why it works: big numbers are expensive to name.** The grue theorem of `note.md` does not apply, because the inductor has no reference machine: its bias is the vocabulary. An exception at x costs at least what it costs to name x in the vocabulary, and in our examples at most about the square of that.
   * With unary numerals, naming x takes x symbols.
   * With a doubling function in the vocabulary, plus with one value changed at (2^j, 0) has a set of j² + 10j + 33 symbols (Proposition 9).
   * With auxiliary function symbols, quus with threshold 2^j has a set of 79 + 2j symbols (Proposition 8), and the inductor behaves much like SOI.
   * A fast-growing target supplies the names itself. For doubling, a set of about 1.5·log₂² n symbols fits the values below n and proves a wrong value at n (Proposition 10, found by the referee). So doubling is pinned only about as strongly as in SOI.
7. **A machine-free way to tell plus from quus.** The *test radius* of g at size m is how far the data must reach before they refute every false identity with sides of at most m symbols. For plus it is exactly m − 1: every short false law fails on small numbers. For quus with threshold N it is at least N + 1 for every m ≥ 3: laws such as f(x, 0) = x look true until N. Once the data cover the test radius at size m, a wrong prediction anywhere needs a term of more than m symbols (Theorem 2). So what matters about addition's laws is not how many there are. It is that two of them determine addition, and that nothing short is false of it without being false early.
8. **A run of the inductor.** For a unary f, every identity set of at most 12 symbols was enumerated, with proofs bounded in length (Section 6.2). Before any data the inductor leaves a far input undetermined with weight 0.94. After two values of successor its belief in the right value at a far input is 0.9995, and in a wrong value 2·10⁻⁴. After three values no enumerated set fits and proves a wrong value. An exception at 0 is learned, at a prior weight about 2000 times smaller than successor's. An exception at 3 is fitted by a set of 36 symbols; none of at most 12 was found.

So there is something there, and it is provable. It is a choice of prior and not a theorem about induction in general: it believes that the truth is governed by laws in the given vocabulary, and it is confident in proportion to how hard exceptions are to state in that vocabulary. Two limits should be kept in mind. The strong pinning is specific to targets, like addition and successor, that cannot name large numbers by their own values. And the theorems bound the belief in wrong values; they do not show that the rest is on the right value and not on "undetermined", though in the runs it is.

## 1. The inductor

**Vocabulary.** Fix the arity k of f (1 or 2 below), the symbols 0, S and f, and a finite set of variable names (x, y for k = 1 and x, y, z for k = 2). A *term* is built from these; its *size* is its number of symbols. The numeral n̲ is S applied n times to 0. An *identity* is a pair of terms, written s = t and read as holding for all values of the variables. An *identity set* T is a finite list of identities; its size |T| is the total size of its terms.

**Proof.** T ⊢ s = t means that s = t follows from T by equational logic: reflexivity, symmetry, transitivity, substitution of terms for variables, and replacement of equals inside a term. By Birkhoff's completeness theorem this is the same as: s = t holds in every algebra (any set with interpretations of 0, S and f) in which T holds.

* T is *consistent* if it proves m̲ = n̲ for no two different numbers m and n.
* T *proves the datum* (x, y) if T ⊢ f(x̲) = y̲. T *fits* a data set D if T is consistent and proves every datum in D.
* A function g on the natural numbers is a *standard model* of T if every identity of T is true of g, with 0 and S read as usual. If T has a standard model g then T is consistent and every datum it proves is true of g (soundness).

**Prior and beliefs.** Write T as a string: its terms in Polish notation, then an end marker. The alphabet has a symbols (a = 6 for k = 1 and a = 7 for k = 2), and w(T) = a^(−(|T|+1)). These weights sum to less than 1 (to 8/21 for k = 1 and to 0.343 for k = 2). A data set D is a finite function: at most one datum per input. For a data set D,

    M_E(D) = sum of w(T) over the sets T that fit D,      Bel(y | D, x) = M_E(D + (x,y)) / M_E(D).

Basic facts:

* **Beliefs are sub-additive.** A consistent T proves at most one value at x, so the beliefs in the labels at x sum to at most 1. The remainder is the posterior weight of the sets that leave f(x) *undetermined*.
* **Some set always fits.** The data themselves, written as identities f(x̲) = y̲, are a consistent set that proves every datum and determines nothing else. So M_E(D) > 0 for every D.
* **Order does not matter.** M_E(D) depends on D as a set.
* **Consistency is not the existence of a standard model.** For unary f, the single identity x = S(f(S(x))) forces S to be a bijection with inverse f∘S. It holds in the integers with f(x) = x − 2, so it is consistent, and it proves that f(x̲) is the numeral of x − 2 for every x ≥ 2. But no function on the natural numbers satisfies it, since 0 would need a predecessor.
* **Proof and consistency are semi-decidable from opposite sides.** Proofs can be searched for, and so can proofs of inconsistency, so M_E(D) is a difference of two numbers that can be approximated from below. We know no way to compute it. Consistency is in fact undecidable already for unary f: the referee's report gives a reduction from the word problem for semigroups, which we have not included here. Section 6 computes a version with bounded proofs.

**Relation to the papers.** The inductor is modelled on Solomonoff axiom induction ([`../solomonoff-axiom-induction/`](../solomonoff-axiom-induction/)): a hypothesis is a set of axioms, and it must be consistent and prove the data. The differences are that the axioms are identities, that they are listed explicitly and not produced by a program, and that the vocabulary has no symbols beyond 0, S and f. The inductor is also a sub-mixture of SOI, as follows. For any T, the function "search for a proof of f(x̲) = y̲ and output the first y found" is partial computable, with a program of length at most −log w(T) + c. So with W the program mixture of Paper 1,

    M_E(D) ≤ 2^c · W(D)   for every data set D.

SOI's cumulative loss never exceeds the equational inductor's by more than c bits.

## 2. Data refute laws

**Definition.** Let D be a data set, u an assignment of numbers to the variables, and r a term. The *D-value* of r at u is computed from the inside out: a variable has its assigned value, 0 has value 0, S adds 1, and f(r₁,…,r_k) has the value that D gives at the values of the arguments. It is undefined if D has no datum there, or if an argument is undefined. An identity s = t is *refuted by D* if at some assignment both sides have D-values and these differ.

**Lemma 1 (a fitting set contains no refuted identity).** If T is consistent and proves every datum of D, then no identity of T is refuted by D.

*Proof.* If r has D-value v at u, then T proves r[u̲] = v̲, where r[u̲] is r with numerals put for the variables: this is an induction on r, and the case of f uses the datum. If an identity s = t of T were refuted at u, with values v ≠ v′, then T ⊢ s[u̲] = t[u̲] by substitution, hence T ⊢ v̲ = v̲′, and T would be inconsistent. ∎

So the identities of a fitting set are "true so far" in the only sense available for a law: no instance that the data can evaluate comes out false.

**Definition (reach, test radius).** Let g be a function and s = t an identity that is false of g. Its *reach* is the least r such that the values of g on [0, r)^k refute it. The *test radius* τ_g(m) is the largest reach of an identity that is false of g and has both sides of size at most m (0 if there is none). It is finite, since there are finitely many such identities.

**Theorem 2 (data up to the test radius pin the target).** Let g be any function, D a set of data from g that contains g(x) for every x in [0, τ_g(m))^k, and T a set that fits D.

1. Every identity of T whose sides have at most m symbols is true of g.
2. If all identities of T have sides of at most m symbols, then g is a standard model of T, and T proves no datum that is false of g.
3. Let ε(m) be the total weight of the identity sets that contain a term of more than m symbols. For every input x outside D and every y ≠ g(x): M_E(D + (x,y)) ≤ ε(m). If some set T_g fits every set of data from g, then Bel(y | D, x) ≤ ε(m) / w(T_g).

*Proof.* (1) An identity with such sides that is false of g is refuted by the values of g on the box, hence by D, and Lemma 1 excludes it. (2) follows by soundness. (3) A set that fits D + (x,y) fits D and proves a datum false of g, so by (2) it contains a term of more than m symbols; and M_E(D) ≥ w(T_g). ∎

The theorem holds for every target, definable by identities or not. What it gives depends on how fast τ_g grows.

## 3. Addition and successor

**Theorem 3 (linear test radius).**

1. For addition, τ(m) ≤ m − 1 for m ≥ 2.
2. For successor (k = 1), τ(m) ≤ m.
3. More generally, for g(x₁,…,x_k) = c + (the sum of the xᵢ with i in a fixed set I), τ(m) ≤ max(c, 1)·m.

*Proof.* For such g, the value of a term r is c₀ + Σⱼ cⱼ·xⱼ for natural numbers c₀, cⱼ depending on r: S adds 1 to c₀, and f adds c and sums the forms of its arguments in I. If two terms have different forms, either their c₀ differ, and then they differ at the all-zero assignment, or some cⱼ differ, and then they differ at the assignment with xⱼ = 1 and the rest 0. So a false identity has a refuting assignment with values in {0, 1}. At such an assignment the value of a term r is at most (the number of S and variable symbols in r) + c·(the number of f symbols in r) ≤ max(c, 1)·|r|. Every argument of an occurrence of f in a side of size at most m is a proper subterm, of size at most m − 1. So f is only applied to numbers up to max(c, 1)·(m − 1), and the reach is at most max(c, 1)·(m − 1) + 1.

For addition c = 0, and an argument of f has size at most m − 2 because the other argument has at least one symbol: the reach is at most m − 1. For successor, a term of size at most m − 1 has at most m − 2 symbols S and f above its leaf, so its value at a 0–1 assignment is at most m − 1, and the reach is at most m. ∎

Both bounds are attained for every m (the examples are the referee's). The identity S^(m−3)(x) = f(x, S^(m−3)(x)) is false of addition exactly at x ≥ 1, where f is applied at (x, x + m − 3), so τ(m) = m − 1 for addition and m ≥ 3. The identity S^(m−1)(0) = f(S^(m−2)(x)) is false of successor exactly at x ≥ 1, so τ(m) = m for successor and m ≥ 2.

**Corollary 4 (pinning of addition and successor).**

1. Let D be data from addition that contain x + y for all x, y < n. Every fitting set whose identities have sides of at most n + 1 symbols has addition as a standard model. For every input x and every wrong value y,

       Bel(y | D, x) ≤ 7^13 · ε(n+1) ≤ 2^(36.5 − 0.485·n).

2. Let D be data from successor that contain x + 1 for all x < n. Every fitting set whose identities have sides of at most n symbols has successor as a standard model, and Bel(y | D, x) ≤ 6^5 · ε(n) ≤ 2^(13 − 1.58·n) for every wrong y.

*Proof.* Theorems 2 and 3, with the sets {f(x,0) = x, f(x,S(y)) = S(f(x,y))} of 12 symbols and {f(x) = S(x)} of 4 symbols, which have addition and successor as standard models and prove all their values. The weights ε are computed in [`code/prior_tail.py`](code/prior_tail.py), to machine precision from exact partial sums: ε(m) = (1/a)·(1/(1 − q²) − 1/(1 − q_m²)), where q is the total weight a^(−size) of all terms and q_m that of the terms of size at most m. Since q_m ≤ q, this gives ε(m) ≤ 2q·(q − q_m)/(a·(1 − q²)²).

*The closed forms.* For k = 2 the number T_s of terms of size s has a generating function that satisfies T = 4z + zT + zT², which at z = 1/5 gives T = 2. So the terms of more than m symbols weigh q − q_m ≤ 2·(5/7)^(m+1), and ε(n+1) ≤ 1.2845·(5/7)^n for every n. This implies the stated inequality for n ≥ 836; for smaller n it was checked by exact arithmetic ([`verification/eq_prior.out`](verification/eq_prior.out)). For k = 1 there are 3·2^(s−1) terms of size s, so q = 3/4, q − q_n = (3/4)·3^(−n) and ε(n) ≤ (48/49)·3^(−n). ∎

| n | bound on the belief in any wrong sum (addition) | bound for successor | for comparison, log₂ n |
|---|---|---|---|
| 20 | (no bound below 1) | 2^(−18.8) | 4.3 |
| 50 | (no bound below 1) | 2^(−66.4) | 5.6 |
| 100 | 2^(−21.1) | 2^(−145.6) | 6.6 |
| 200 | 2^(−71.1) | 2^(−304.1) | 7.6 |
| 1000 | 2^(−462.9) | 2^(−1572.1) | 10.0 |

These are guarantees, and for small n they say nothing: the bound for addition is below 1 only from n = 59, and the bound for successor from n = 9. The constant 2^36.5 is the whole prior cost of the two laws of addition, and the sets that actually deviate cost much more than one long identity (Section 4).

**Comparison with SOI.** Given the same data, SOI gives a wrong sum at an input x outside the square probability at least 2^(−K(Q) − K(y) − c) for every decidable Q that contains x and no seen input (Paper 1, Proposition 8.1). If the data are the square itself, this is about 2^(−K(n)) for x just outside it, and far more for x beyond the simplest number above n. So SOI's pinning outside the square is at most about log₂ n + 2·log₂ log₂ n + c bits, the last column of the table, and for round n much less. The equational inductor's is at least 0.485·n − 36.5 bits, at every input.

**Missing pairs.** Corollary 4 is about data that are complete up to n. It survives a few missing pairs, as long as none of them is small.

**Proposition 4a (a few missing pairs).** Let U be a set of h pairs in [0, n)², and let D be data from addition that contain x + y for every pair of [0, n)² outside U. Let T fit D, with all sides of at most m symbols, where n ≥ m²·(h + 1).

1. Every identity of T that is false of addition has a side containing a ground term f(r₁, r₂) whose arguments have values a and b with (a, b) in U: it *names a missing pair*. Such a side has at least a + b + 3 symbols.
2. So if a + b ≥ m − 2 for every missing pair (a, b), addition is a standard model of T, and T proves no wrong sum. The bound of Corollary 4 then holds with ε(m) in place of ε(n+1).

*Proof.* Let s = t be an identity of T that is false of addition and has no such ground subterm. Under addition its sides denote different linear forms, so the assignments at which they agree lie in a proper affine subspace H. For an occurrence f(r₁, r₂) in s or t and a missing pair p, the assignments at which the two arguments take the values p form an affine subspace. It is proper: otherwise both arguments would have constant forms, so would be ground (a variable that occurs in a term has a positive coefficient in its form), with values p. The two sides contain at most m − 1 occurrences of f, so these subspaces and H number at most K = (m − 1)·h + 1. The grid {0, …, K}^v of assignments is not covered by K proper affine subspaces: each lies in the zero set of a nonzero polynomial of degree at most 1, and the product of these, a nonzero polynomial of degree at most K, cannot vanish on a grid with K + 1 values in each coordinate. So some assignment with values at most K refutes the identity under addition, with no application of f at a missing pair. At that assignment every argument of f has value at most K·(m − 2) < n, so every application of f is at a pair in the data, and D refutes the identity, against Lemma 1. For the count in (1): a ground term with value a has at least a symbols S and one 0. ∎

So the pinning survives missing pairs as long as they are few and none of them is small. A missing small pair is different: if (1,1) is missing, the identity f(1̲, 1̲) = 0 is not refuted, and plus with the value at (1,1) changed has an identity set of 68 symbols (Section 4), which fits. A brute-force check of (1) for sides of at most 6 symbols is in [`code/holes_check.py`](code/holes_check.py).

**What is not bounded.** Theorem 2 and its corollaries bound the belief in wrong values. The rest of the belief is split between the right value and "undetermined", and nothing above controls the split. Short sides do not force a fitting set to determine everything: the referee's report gives, for each n ≥ 4, a set of about 2n² symbols with sides of at most n + 1 symbols that is true of addition, proves the whole square below n and leaves f(n−1, n) undetermined. Whether every fitting set of far fewer symbols determines all sums is open. In the runs of Section 6 the belief in the right value does go to 1.

## 4. What exceptions cost

**Definition.** The *law complexity* C_E(g) of a function g is the least size of a consistent identity set that proves every value of g, and ∞ if there is none. By Lemma 1 applied to all of g, such a set contains only identities that are true of g. So C_E(g) is the least size of a set of laws of g from which all its values follow.

**Proposition 5.**

1. C_E(plus) ≤ 12 and C_E(successor) ≤ 4. The table below gives verified sets for some other targets.
2. If g ≠ plus agrees with plus on [0, n)², then C_E(g) ≥ n + 3. So C_E(quus_N) ≥ N + 3, where quus_N(x,y) is x + y if x, y < N and 5 otherwise, and C_E(g) ≥ max(a, b) + 3 when g is plus with a different value at (a, b).
3. C_E(quus_N) ≤ 2N³ + 2N² + 2N + 18.
4. For n ≥ 1, plus with the value at (n, 0) changed to 0 has law complexity at most n² + 8n + 36.

*Proof.* (2) Let T be consistent and prove every value of g, and let x be an input with g(x) ≠ plus(x). T fits plus on [0, n)², since g agrees with plus there. If all its sides had at most n + 1 symbols, plus would be a standard model of T by Theorems 2 and 3, and T could not prove the datum (x, g(x)), which is false of plus. So some side has at least n + 2 symbols, and the other side has at least one. (3) The set with the two identities f(S^N(x), y) = 5̲ and f(x, S^N(y)) = 5̲ and the N² ground identities f(a̲, b̲) = a+b for a, b < N is true of quus_N and proves all its values. (4) Take f(0, S(y)) = S(y) and f(S(x), S(y)) = S(f(x, S(y))) for the rows above 0; the ground identities f(i̲, 0) = i̲ for i < n; the changed value f(n̲, 0) = 0; and f(n+1, 0) = n+1 with f(S^(n+2)(x), 0) = S(f(S^(n+1)(x), 0)) for the rest of row 0, where n+1 stands for its numeral. Each is true of the changed function, together they prove all its values, and their sizes add up to 16 + (n² + 3n) + (n + 4) + (2n + 6) + (2n + 10). ∎

Sizes of explicit sets, each checked by machine to be true of its target and to derive all its values on a test box ([`code/theories.py`](code/theories.py), [`results/theories.out`](results/theories.out)):

| target | size of the set | lower bound | cost of the exception in SOI |
|---|---|---|---|
| plus | 12 | | |
| max, min | 17 | | |
| monus | 16 | | |
| [x = y] | 23 | | |
| quus_5 | 328 | 8 | K(5) + c |
| quus_8 | 1186 | 11 | K(8) + c |
| plus, but 0 at (1,1) | 68 | 4 | K(1,1) + c |
| plus, but 0 at (5,5) | 296 | 8 | K(5,5) + c |
| plus, but 0 at (8,3) | 287 | 11 | K(8,3) + c |

In SOI a patch costs K(f) plus the complexity of its guard, so quus_N costs K(plus) + K(N) + c bits: about log N more than plus, and much less for round N. Here it costs at least N − 9 symbols more. The true cost is somewhere between N + 3 and about 2N³; we have not tried to narrow this.

**Proposition 6 (squaring has no finite set of laws).** For unary f, C_E(x ↦ x²) = ∞.

*Proof.* Let T be consistent and prove every value of squaring; then every identity of T is true of squaring. A term is a word over {S, f} applied to a variable or to 0. Under squaring, a word w applied to x is a polynomial p_w(x) with positive leading coefficient, of degree 2^(number of f in w).

*An identity with a variable that is true of squaring has identical sides.* A term with a variable is not constant, so its other side must contain the same variable, and we need: p_w = p_w′ implies w = w′. Induct on the lengths. The degrees give the same number of f. If one word is empty, the other has no f, and no S either, by comparing constant terms. If both words begin with S, or both with f, remove it (a polynomial with positive leading coefficient is determined by its square) and continue. If w = S·w₁ and w′ = f·w′₁, then p_w₁ + 1 = q² with q = p_w′₁ not constant. Write w₁ = S^a·w₂ with w₂ empty or beginning with f. If w₂ is empty, x + a + 1 = q² is impossible by degree. Otherwise p_w₂ = r² with r not constant and r² + a + 1 = q², so (q − r)(q + r) is the constant a + 1; then q − r and q + r are constants, and so are q and r, a contradiction.

So T consists of ground identities and identities with identical sides. Let V be the finite set of numbers at which f is applied when the ground terms of T are evaluated under squaring. Take j outside V and let g′ be squaring with the value at j changed. Evaluating the terms of T under g′ never applies f at j, so T is true of g′, and T does not prove f(j̲) = j². ∎

**Proposition 7 (learning, and the price of confidence).**

1. If C_E(g) < ∞, then M_E(D) ≥ a^(−(C_E(g)+1)) for all data D from g. So along any sequence of distinct inputs the total of −log₂ Bel(true label) is at most (C_E(g) + 1)·log₂ a, and the true label has belief at most ½ at most that many times.
2. If C_E(g) = ∞, then M_E(D_n) → 0 along any enumeration D_n of the values of g: every consistent set eventually fails to prove a datum. The inductor's cumulative loss grows without bound, while for computable g SOI's stays below K(g) + c.
3. Let the truth g agree with plus on [0, n)² and differ from it at x. Let D be data from g that contain that square and on which g agrees with plus, so that x is the first exception to be seen. Then the belief in the true label at x is at most 7^13·ε(n+1) ≤ 2^(36.5 − 0.485·n): the inductor loses at least 0.485·n − 36.5 bits at that datum. SOI's loss there is at most K(Q) + K(g(x)) + c for any decidable Q that contains x and no seen input.

*Proof.* (1) A least set for g fits every D from g; the beliefs along the sequence multiply to M_E(D_n)/M_E(∅) ≥ M_E(D_n). (2) No single set fits all the D_n, so each term of the sum defining M_E(D_n) is eventually 0, and the sum is dominated by the convergent sum of all weights. For SOI see Paper 1. (3) D is data from plus that contain the square, and the true label at x is a wrong sum, so this is Corollary 4. (The hypothesis that D agrees with plus is needed for the denominator: it makes the two laws of addition fit D.) ∎

Item 3 is the price, as in Theorem 5 of `note.md`: pinning is a bet. If quus_N is the truth, the equational inductor gives the first exception belief at most 2^(36.5 − 0.485·N), loses at least about N/2 bits there, and afterwards every set that fits has more than N symbols. SOI loses about log N bits. (The theorems do not say how the remaining belief at the exception was divided between plus's value and "undetermined".)

## 5. The vocabulary is the bias

**No machine, no grue theorem.** Theorem 3 of `note.md` says that a scheme whose bias comes from a reference machine alone can be flipped at x by a machine about sep(x; A) bits away. The equational inductor is not such a scheme. It has no machine. And a relabelling of outputs is not a symmetry of its hypotheses: exchanging two labels at the inputs in a set Q turns plus into a patched function whose law complexity is far larger (Proposition 5), because the laws apply S to outputs and feed outputs back in as inputs, and a relabelling of outputs alone does not respect that. What it has in place of a machine is its vocabulary, and the right question is how its behaviour depends on that.

**Proposition 8 (auxiliary symbols bring the guards back).** Let identities use further function symbols, of any arities, with "fits" defined as before (consistent, and proves the data about f).

1. For N = 2^j, quus_N has a set of 79 + 2j symbols that is true in a standard model and proves all its values. It uses four auxiliary symbols: h for plus, d for doubling, l for "less than" and c for a conditional, each with its recursion equations, and the single identity f(x,y) = c(l(x,N̄), c(l(y,N̄), h(x,y), 5̲), 5̲), where N̄ is d applied j times to 1̲.
2. Every total computable function has a finite set, with auxiliary symbols, that is true in a standard model with total auxiliary functions and proves all its values.

So with auxiliary symbols, a set of 79 + 2⌈log₂ n⌉ symbols fits plus on [0, n)² and proves wrong sums outside it. The pinning is logarithmic in n again, as in SOI. With auxiliary symbols the inductor behaves like SOI up to a constant factor in description length. (We have not fixed a prior for it; the alphabet would need names for unboundedly many symbols.)

*Proof.* (1) The set is listed in [`results/theories.out`](results/theories.out) and checked there for j ≤ 3; its identities are true when the symbols are read as described, for every j. (2) Write the function as u(μy. t(x, y) = 0) with u and t primitive recursive (Kleene's normal form). Take the recursion equations of u, t and their auxiliary functions, the two equations of the conditional c, a search symbol σ with σ(x, y) = c(t(x, y), σ(x, S(y)), y), and f(x) = u(σ(x, 0)). Reading σ(x, y) as the least witness at or above y if there is one, and as 0 otherwise, makes σ total and the equations true. The formalism of systems of equations is in Kleene, *Introduction to Metamathematics* (1952), §54–55; note that Kleene's notion of a system defining a function uses restricted rules of inference and does not by itself give consistency under full equational logic, which is why the standard model is needed. (This correction is the referee's.) ∎

**Proposition 9 (a background doubling function makes powers of two cheap).** Add a symbol d to the vocabulary, with the *background* identities d(0) = 0 and d(S(x)) = S(S(d(x))), which every hypothesis contains at no cost. Let g_j be plus with the value at (2^j, 0) changed to 0. There is a set P_j of j² + 10j + 33 symbols that is true of g_j and, with the background, proves all its values:

    f(x, 1̲) = S(x),   f(x, S(S(y))) = S(f(x, S(y))),   f(0, 0) = 0,
    f(t, 0) = t   for t = dⁱ(S(d(x))), i = 0, …, j−1,   and for t = dʲ(S(S(x))),
    f(dʲ(1̲), 0) = 0.

So P_j fits plus on [0, n)² for every n ≤ 2^j and proves a wrong sum: with doubling in the vocabulary, the exception costs about log² n symbols.

*Proof.* Each identity is true of g_j: the first two concern pairs with second argument at least 1; a first argument of the form 2ⁱ·(2x+1) with i < j, or 2ʲ·(x+2), is never 2ʲ. Every first argument p falls under exactly one case: p = 0, or p = 2ⁱ·odd with i < j, or p = 2ʲ·m with m ≥ 2, or p = 2ʲ. The background proves p̲ equal to the corresponding term. Checked by machine for j ≤ 4. ∎

Lemma 1 and Theorem 2 hold with a background symbol such as d, read as doubling when terms are evaluated. (With free auxiliary symbols they do not apply: an identity that contains such a symbol is neither true nor false of g.) What changes is the test radius. The identity f(dʲ(1̲), 0) = 0 has a side of j + 4 symbols, is false of plus, and is refuted only by data that reach 2^j. In the other direction, terms still denote linear forms with natural coefficients, so a false identity still fails at an assignment of zeros and ones, and there a term of s symbols has value at most 2^(s−1). So an identity that is false of plus and not refuted by plus on [0, n)² has a side of more than log₂ n symbols.

**The naming principle.** For addition, a false identity fails already at an assignment of zeros and ones (proof of Theorem 3). So an identity that is false of plus and not refuted by plus on [0, n)² must contain a term whose value at such an assignment is at least n: it must *name a number beyond the data*. An exception costs at least what that costs in the vocabulary, and in the examples it costs at most about the square of that.

| vocabulary | least size of a set that fits plus on [0, n)² and proves a wrong sum |
|---|---|
| {0, S, f} | more than n; at most n² + 8n + 36 (plus with the value at (n, 0) changed) |
| {0, S, f} with doubling in the background | more than log₂ n; at most log₂² n + 10·log₂ n + 33 for n a power of two |
| {0, S, f} with auxiliary symbols | at most 79 + 2·log₂ n for n a power of two |
| programs (SOI) | about K(n) bits, at most about log₂ n and far less for round n |

**Proposition 10 (a fast-growing target names large numbers itself; due to the referee).** Let f be unary and n = 2^j. Let Q_j be the set

    f(0) = 0,
    f(fⁱ(S(f(z)))) = S(S(f((S∘f)ⁱ(f(z)))))     for i = 0, …, j−1,
    f(fʲ(1̲)) = 0,

where (S∘f)ⁱ means i applications of "f, then S". It has 1.5j² + 8.5j + 7 symbols. It is consistent, it proves f(p̲) = 2p for every p < n, and it proves f(n̲) = 0. So Q_j fits doubling on [0, n) and proves a wrong value at n.

*Proof.* Under doubling, fⁱ(S(f(z))) has the value p = 2ⁱ·(2z + 1) and (S∘f)ⁱ(f(z)) has the value p − 1, so the identity for i says f(p) = 2 + f(p − 1). It is true of doubling.

*Q_j proves doubling below n,* by induction on p < n. For p = 0 use the first identity. Otherwise p = 2ⁱ·(2z + 1) with i < j. In the instance of the identity for i at z, evaluating the argument on the left applies f only at z and at 2ᵗ·(2z + 1) for t < i, and the right side applies f only at numbers up to p − 1. All of these are below p, so by induction both sides evaluate, and the instance gives f(p̲) = 2p.

*Q_j proves f(n̲) = 0.* The term fʲ(1̲) applies f at 1, 2, …, 2^(j−1), all below n, so it equals the numeral of n, and the last identity applies.

*Q_j is consistent:* the function x ↦ 2·(x mod n) is a standard model. Let r = z mod n. Modulo 2n, i applications of this function to 2r + 1 give 2ⁱ·(2r + 1), and the right-hand term (S∘f)ⁱ(f(z)) is 2ⁱ·(2r + 1) − 1. So the left side is 2P with P = 2ⁱ·(2r + 1) mod n, and P ≠ 0 because i < j. The right side is 2 + 2·(P − 1). The last identity holds because the function sends 2^(j−1) to n and n to 0.

*Size.* 3 for the first identity, 3i + 9 for the identity for i, and j + 4 for the last. Checked by machine for j ≤ 7 in [`verification/eq_doubling_patch.out`](verification/eq_doubling_patch.out), and independently by us for j ≤ 6. ∎

So for doubling the pinning is only polylogarithmic. After doubling on [0, n), the belief in the wrong value 0 at n is at least 6^(−(1.5j² + 8.5j + 8)). From the other side, Theorem 2 with the test radius 2^(m−2) + 1 of doubling bounds a wrong belief by 6^11·ε(m) for m about log₂ n. So the pinning of doubling at n is between about 1.58·log₂ n − 28 bits and about 3.9·log₂² n + 22·log₂ n + 21 bits: logarithmic up to a square, as in SOI and unlike addition. The reason is the naming principle again. Under doubling the term fʲ(1̲) names 2^j with j + 2 symbols. A target that grows fast is its own cheap name for large numbers.

So the strong pinning of Section 3 is what induction over laws gives when large numbers have no short names, neither in the vocabulary nor through the target itself. This is a real restriction and a real choice. The more functions the vocabulary contains, the more numbers have short names, and the cheaper it becomes to state an exception at one of them. A vocabulary that contains every computable function prices exceptions much as SOI does.

## 6. Computations

### 6.1 Test radius

[`code/test_radius.py`](code/test_radius.py) enumerates every identity whose sides have at most m symbols (three variables and m ≤ 6 for binary f, two variables and m ≤ 8 for unary f), decides which are false of the target by searching assignments with values up to 6 (binary) or 12 (unary), and computes the largest reach. The search bound means an identity with no refuting assignment in range counts as true. Output: [`results/test_radius.out`](results/test_radius.out).

| binary target | m = 3 | 4 | 5 | 6 |
|---|---|---|---|---|
| plus | 2 | 3 | 4 | 5 |
| x+y+1, first argument, max | 2 | 3 | 4 | 5 |
| min, monus | 2 | 4 | 6 | 8 |
| times | 3 | 3 | 5 | 7 |
| quus_5 | 7 | 7 | 7 | 8 |
| plus, but 0 at (3,4) | 5 | 6 | 9 | 10 |

| unary target | m = 2 | 3 | 4 | 5 | 6 | 7 | 8 |
|---|---|---|---|---|---|---|---|
| successor, identity | 2 | 3 | 4 | 5 | 6 | 7 | 8 |
| x+2 | 2 | 4 | 6 | 8 | 10 | 12 | 14 |
| predecessor | 3 | 4 | 5 | 6 | 7 | 8 | 9 |
| min(x+1, 3) | 4 | 4 | 4 | 5 | 6 | 7 | 8 |
| successor, but 0 at 4 | 5 | 6 | 7 | 8 | 10 | 11 | 12 |
| double | 2 | 3 | 5 | 9 | 17 | 33 | 65 |
| square | 3 | 5 | 17 | 257 | 65537 | 2³² + 1 | 2⁶⁴ + 1 |

* **Plus and successor meet the bounds of Theorem 3 exactly** (m − 1 for m ≥ 3, and m), as proved in Section 3, and x + 2 is within its bound 2m.
* **Targets with a threshold start high.** Quus_5 has test radius 7 already at m = 3, and the patched targets start above their patch: short laws that are false of them are refuted only by data that reach the exception.
* **Fast-growing targets have fast-growing test radius**, 2^(m−2) + 1 for doubling and doubly exponential for squaring, because a short term can reach a large number by nesting f. For these Theorem 2 needs much more data per symbol.
* The bound on the search matters only through what counts as false. The referee recomputed every entry with two search ranges and with exact integers and found no dependence on the range. For squaring the script uses exact integers, since the values exceed 64 bits.

### 6.2 The inductor on unary functions

For unary f a ground term is a word over {S, f} applied to 0, and an identity set generates a congruence on words: the least equivalence that is closed under writing any word in front and contains every instance of the identities. [`code/eq_unary.c`](code/eq_unary.c) enumerates every identity set of at most 12 symbols and computes this congruence on the words of at most L letters.

* **What is enumerated.** All 476,610 identity sets of at most 12 symbols, counted up to renaming of variables, swapping of sides and reordering; each carries the number of strings that encode it, and the total weight was checked against a direct recurrence. Supersets of a set found inconsistent are skipped, which is sound. These sets carry prior weight 0.3529 out of the 0.3810 of all identity sets; the larger sets, 7% of the prior, are left out, so every figure below is within the enumerated sets.
* **What "proves" means here.** Essentially: has a proof all of whose terms have at most L symbols above the leaf. (The program also identifies two instances when both equal a term too long to be represented; the referee's stricter program gives identical tables for sets of at most 12 symbols.) Proofs found are valid. The bound cuts both ways. A set counted as consistent may be inconsistent by a longer proof, and a set may prove a datum or a value only by a longer proof, in which case it is counted as not fitting or as leaving the value undetermined.
* **How much the bound matters.** The number of sets found consistent is 114,635 with L = 14, 114,465 with L = 16 and 114,416 with L = 18. The sets that slip through a small bound are mostly of one kind: an identity such as x = S(f(S(S(S(x))))) forces S to be a bijection and f to be its inverse applied four times, and with f(0) = 1̲ this identifies 0̲ and 5̲, but only by a proof through terms of 15 letters. In the other direction, between L = 16 and L = 18 weight 3.6·10⁻⁶ moves to more determined profiles ([`verification/eq_bound_drift.out`](verification/eq_bound_drift.out)). The successor rows below agree between L = 16 and L = 18 to the digits shown.
* **Recheck.** [`code/eq_unary_recheck.py`](code/eq_unary_recheck.py) takes every set that fits a target at 0, 1, 2 with L = 18 and proves a wrong value at some x ≤ 7, and tests it again with L = 22. The referee rechecked all 2,498 sets that fit one of nine targets at 0, 1, 2: none that did not deviate at L = 18 deviates at L = 22. The referee also showed, with no bound involved, that all 216 sets counted as fitting successor have successor as a standard model, so they are consistent outright; the same holds for x + 2, constant 1, double, [x > 0], min(x+1, 2) and "successor, but 0 at 0" ([`verification/eq_fitting_models.out`](verification/eq_fitting_models.out)).

The numbers below are for L = 18 ([`results/eq_unary_analysis_cap12_L18.out`](results/eq_unary_analysis_cap12_L18.out)); the recheck is in [`results/eq_unary_recheck_cap12_L18_to_L22.out`](results/eq_unary_recheck_cap12_L18_to_L22.out).

**Successor**, after its values at 0, …, n − 1. Beliefs are for the far input x = 7.

| n | weight of the fitting sets | right value | a wrong value | undetermined | smallest fitting set that proves a wrong value |
|---|---|---|---|---|---|
| 0 | 0.208 | 0.003 | 0.053 | 0.944 | f(x) = 0 (3 symbols) |
| 1 | 1.6·10⁻³ | 0.386 | 0.411 | 0.203 | f(x) = 1̲ (4 symbols) |
| 2 | 6.2·10⁻⁴ | 0.99945 | 1.8·10⁻⁴ | 3.7·10⁻⁴ | f(0) = 1̲, f(S(x)) = 2̲ (10 symbols) |
| 3 | 6.2·10⁻⁴ | 1.00000 | 0 | below 10⁻⁵ | none of at most 12 symbols |

**Other targets**, after their values at 0, 1, 2, again at x = 7.

| target | smallest fitting set for all values | weight of the fitting sets | right | wrong | undetermined |
|---|---|---|---|---|---|
| identity | f(x) = x (3) | 3.9·10⁻³ | 0.99999 | 6·10⁻⁷, all of it gone in the recheck | 10⁻⁵ |
| constant 1 | f(x) = 1̲ (4) | 6.6·10⁻⁴ | 1.000 | 0 | 0 |
| x + 2 | f(x) = S(S(x)) (5) | 1.0·10⁻⁴ | 1.000 | 0 | 0 |
| predecessor | f(0) = 0, f(S(x)) = x (7) | 1.4·10⁻⁵ | 0.982 | 0.010 | 0.008 |
| [x > 0] | f(0) = 0, f(S(x)) = 1̲ (8) | 3.0·10⁻⁶ | 0.841 | 0 | 0.159 |
| successor, but 0 at 0 | f(0) = 0, f(S(x)) = S(S(x)) (9) | 3.3·10⁻⁷ | 1.000 | 0 | 0 |
| double | f(0) = 0, f(S(x)) = S(S(f(x))) (10) | 5.5·10⁻⁸ | 1.000 | 0 | 0 |
| min(x+1, 2) | f(0) = 1̲, f(S(x)) = 2̲ (10) | 2.2·10⁻⁷ | 0.500 | 0 | 0.500 |
| parity | none of at most 12 symbols (its recursion has 14) | 0 | | | |
| successor, but 0 at 3 | none of at most 12 symbols (a set as in Section 4 has 36) | 6.2·10⁻⁴, all on successor | | | |
| square | none (Proposition 6) | 0 | | | |

What the run shows:

* **The inductor abstains before it knows.** With no data, 94% of the weight is on sets that prove nothing about f(7).
* **Two or three values suffice for the short targets, and what is left over is real competition.** After two values of successor, the wrong beliefs come from sets such as f(0) = 1̲, f(S(x)) = 2̲, which is true of min(x+1, 2). It has a side of 3 symbols, more than n = 2, as Corollary 4 requires. After three values, no set of at most 12 symbols fits successor and proves a wrong value anywhere on 0, …, 7, by proofs within the bound. The same holds for the other targets that have a fitting set of at most 12 symbols, except predecessor, where the set f(f(x)) = 0, f(S(S(x))) = 1̲, true of the function 0, 0, 1, 1, 1, …, fits the first three values; it is gone after the fourth.
* **Exceptions at small inputs are learned, at their price.** "Successor, but 0 at 0" is fitted by a set of 9 symbols. After three values the weight of its fitting sets is about 2000 times smaller than for successor.
* **An exception at a larger input is beyond reach.** Having seen successor at 0, 1, 2, the inductor is certain, within the enumerated sets, that f(3) = 4. If the value is 0, no set of at most 12 symbols fits. A set of 36 symbols does, built as in Section 4.
* **The bound produces artefacts, and they vanish as it grows.** For successor at n = 3 the wrong-value belief at x = 7 is 1.2·10⁻⁵ with L = 14, 2·10⁻⁶ with L = 16 and 0 with L = 18; each time the sets responsible were inconsistent by longer proofs.

This is an illustration on a small scale: unary f, sets of at most 12 symbols, bounded proofs. It does not test Theorem 3 at large n, where the content of the theorem lies.

## 7. What to make of it

**What the inductor believes.** That the function is governed by laws that can be stated in the given vocabulary, with nothing behind them: no hidden machinery (auxiliary symbols) and no case distinctions beyond what the constructors 0 and S provide. Under that belief a deviation of addition at a large number is not a simple hypothesis, because the vocabulary has no short way to say where it happens.

**How the many laws of addition enter.** Less directly than one might hope.

* *Their number matters little.* Any identity that is true of the target can be added to a fitting set, so a target with many short laws has more fitting sets and a larger share of the prior. But this does not single out addition: degenerate functions such as the projection (x, y) ↦ x satisfy far more short identities ([`results/identities_L9.out`](results/identities_L9.out)). And it plays no part in the theorems above.
* *Two of them determine addition.* This is what makes its law complexity small.
* *None of the short false ones is false late.* This is the linear test radius, and it is what makes the pinning strong: after the data reach n, the only laws still in play that are false of addition are longer than n. Quus is the opposite case. With threshold N, the false law f(x, 0) = x survives all data below N.

**Relation to isolation.** `note.md` called f isolated if no function close to it is as simple, and found that under Kolmogorov complexity the margin of isolation is capped by the price of a small guard. Under law complexity the margin grows with the region of agreement: every g ≠ plus that agrees with plus on [0, n)² has C_E(g) ≥ n + 3, against C_E(plus) ≤ 12. In this sense addition is isolated among law-governed functions at every scale n ≥ 10, with a margin of n − 9 symbols. (Closeness here means agreement on an initial square, not small measure of the set of disagreement as in `note.md`.)

**Is the vocabulary principled?** Partly.

* *For.* The natural numbers are the structure generated by 0 and S, and the laws of addition are stated over it. Identities are exactly the laws that survive passing to substructures, products and homomorphic images (Birkhoff), which is one way of saying that they make no case distinctions. An auxiliary symbol with no data of its own is hidden machinery, and Proposition 8 shows that admitting it is what readmits grue.
* *Against.* The strong pinning depends on large numbers being expensive to name (Propositions 9 and 10), and we do name large numbers cheaply. A learner that already knows doubling, or multiplication, has a vocabulary in which exceptions at their values are cheap. One response is to let the vocabulary grow only by functions that have themselves been learned from data; then exceptions are cheap exactly at numbers that some known law-governed function singles out.
* *The cost is real.* Squaring is not learnable in the bare vocabulary, and a truth with a genuine exception is learned late and at a high price.

**What is and is not shown.**

* The theorems are about data that contain a full initial square or segment, up to a few missing pairs that are not small (Proposition 4a). For sparse data Theorem 2 gives much less, and we do not know the truth (Section 8).
* They are about addition, successor and other targets with linear test radius. For doubling the pinning is only polylogarithmic (Proposition 10), and we expect the same of other fast-growing targets.
* They bound the belief in wrong values. They do not show that the rest of the belief is on the right value (Section 3, "What is not bounded").

## 8. Open questions

1. **Sparse data.** If the data are a random half of the pairs below n, exceptions at the small missing pairs are cheap, and Proposition 4a does not apply. Is an exception at a far input still expensive? A fitting set proves no wrong value at a seen pair, so all its wrong values lie on unseen pairs, which a law with variables can hardly arrange; but short false identities that name small missing pairs survive, and we have no theorem.
2. **Which targets are pinned linearly?** Addition and successor are (Corollary 4), doubling is not (Proposition 10). The difference is whether short terms can reach large numbers under the target. For max, min and monus the test radius is linear for m ≤ 6 (Section 6.1); if it is linear for all m, Theorem 2 pins them linearly too. Is it? And is multiplication pinned only polylogarithmically, like doubling?
3. **Does a small fitting set determine everything?** Is there a set of far fewer than n² symbols that is true of addition, proves the square below n and leaves some sum undetermined? If not, the belief in the right sum is close to 1 whenever the belief in wrong sums is small.
4. **The true cost of quus_N and of point patches**, between N + 3 and 2N³, and between max(a,b) + 3 and about max(a,b)².
5. **Which functions have finite law complexity?** Is multiplication determined by finitely many identities in {0, S, f}? Is there a simple criterion?
6. **A growing vocabulary.** Learn plus, add it to the vocabulary with its laws as background, then learn times as f(x,0) = 0, f(x,S(y)) = plus(f(x,y), x). What are the right statements about pinning when the background symbols were themselves learned?
7. **Noise and partial laws.** A hypothesis here must prove every datum. A version that tolerates a wrong datum would have to say what an exception costs, which is the question again.
8. **Exact computation.** Consistency is undecidable, and the bounded version of Section 6 counts some inconsistent sets as consistent. For unary f the sets are string-rewriting systems, and completion procedures might decide most small cases exactly.

## 9. Related work

* **Goodman's entrenchment.** Goodman's own answer to grue was that "green" is entrenched in our vocabulary and "grue" is not. The equational inductor is an instance: the vocabulary is fixed in advance, and Propositions 8 and 9 measure how the conclusions change with it.
* **Equational logic and universal algebra.** Birkhoff's completeness theorem and his characterisation of the classes defined by identities.
* **Recursion equations.** The Herbrand–Gödel–Kleene definition of the computable functions by systems of equations with auxiliary function letters (Kleene, *Introduction to Metamathematics*, 1952) is the extended inductor's hypothesis language.
* **Inductive synthesis of functional programs and inductive logic programming** learn recursive definitions from examples, usually with search strategies and language biases of the same kind; we have not surveyed that literature for results like Theorem 3.
* **Solomonoff axiom induction** ([`../solomonoff-axiom-induction/`](../solomonoff-axiom-induction/)): priors over axiom systems with three-valued predictions. The present inductor restricts the axioms to identities listed explicitly in a fixed small vocabulary.
* **Self-testing and identity testing.** That an identity true at all zero–one assignments is true everywhere, for terms that denote linear forms, is the simplest case of testing a polynomial identity at few points.
