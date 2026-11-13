# The equational inductor

*Induction over laws stated in a fixed vocabulary, and how strongly it pins down addition*

A second research note by Claude (Anthropic), following [`note.md`](note.md), in response to a question from Kaarel Hänni. Draft, in progress: Section 6.2, the discussion and the open questions are still to be added, and nothing in this note has been refereed yet.

## The question

[`note.md`](note.md) asked whether many properties of input–output pairs can pin a function down more strongly than Solomonoff operator induction (SOI) does, and found that they cannot: one guard breaks all of them at once. Hänni then asked about properties of the *whole function*. Addition satisfies many short universally quantified statements. Is there something there that pins down plus over quus?

This note studies the simplest inductor of that kind. Its hypotheses are finite sets of *identities* (universally quantified equations) in the vocabulary {0, S, f}, where f is the function being learned and S is successor. There are no other symbols: no auxiliary functions and no case distinctions.

## Answers in brief

1. **The inductor.** A hypothesis is a finite set T of identities, with prior weight exponentially small in its number of symbols. T *fits* the data if it is consistent (it proves no equation between two different numerals) and proves every datum f(x) = y by equational reasoning. The belief in a label y at a new input x is the posterior weight of the fitting sets that prove f(x) = y. Beliefs need not add up to 1: the rest is "undetermined" (Section 1).
2. **Laws must be true so far.** A set that fits the data contains no identity that the data refute, where an identity is refuted when some instance of it can be evaluated from the data alone and comes out false (Lemma 1). This is the notion of a property "true of all pairs so far", for laws.
3. **Addition is pinned at every input, with strength linear in the scale of the data.** Suppose the data contain x + y for all x, y < n. Then every fitting set whose identities have sides of at most n + 1 symbols is true of addition, and so proves no wrong sum anywhere (Theorem 3). A wrong sum at any input, however far, needs an identity longer than n. The belief in any wrong sum is at most 2^(36.5 − 0.485·n); the exact bound is 2^(−71) for n = 200. SOI, given the same data, keeps probability at least about 2^(−K(n)), roughly 1/n or more, for a wrong sum outside the square. The same holds for successor, with the bound 2^(13 − 1.58·n).
4. **What exceptions cost.** Call the least size of a fitting set for all values of g its *law complexity*. Plus has law complexity at most 12. Quus with threshold N (x + y if x, y < N, else 5) has law complexity between N + 3 and 2N³ + 2N² + 2N + 18, and plus with one value changed at (a, b) has at least max(a, b) + 3 (Proposition 5). In SOI such exceptions cost about K(N) bits, at most about log N. So the equational inductor prefers plus to quus by at least N symbols where SOI prefers it by about log N bits.
5. **The price.** The inductor's loss is never less than SOI's by more than a constant, and when quus is true it pays about half a bit per unit of N at the first exception (Proposition 7). Some simple functions have no finite set of identities at all, squaring for one (Proposition 6). On those the inductor memorises the data and declines to predict.
6. **Why it works: big numbers are expensive to name.** The grue theorem of `note.md` does not apply, because the inductor has no reference machine: its bias is the vocabulary. An exception at x costs what it costs to single x out in the vocabulary. With unary numerals that is about x symbols. Add a doubling function to the vocabulary, and plus with one value changed at (2^j, 0) costs j² + 10j + 33 symbols (Proposition 9). Allow auxiliary function symbols, and quus with threshold 2^j costs 79 + 2j symbols (Proposition 8): the inductor then behaves like SOI.
7. **A machine-free way to tell plus from quus.** The *test radius* of g at size m is how far the data must reach before they refute every false identity with sides of at most m symbols. For plus it is m − 1: every short false law fails on small numbers. For quus with threshold N it is at least N + 1 for every m ≥ 3: laws such as f(x, 0) = x look true until N. The inductor pins a target at every input as soon as the data cover its test radius (Theorem 2). So what matters about addition's laws is not how many there are. It is that two of them determine addition, and that nothing short is false of it without being false early.
8. **A run of the inductor.** For a unary f, every identity set of at most 12 symbols was enumerated, with proofs bounded in length (Section 6.2, to be added).

So there is something there, and it is provable. It is a choice of prior and not a theorem about induction in general: it believes that the truth is governed by laws in the given vocabulary, and it is confident in proportion to how hard exceptions are to state in that vocabulary.

## 1. The inductor

**Vocabulary.** Fix the arity k of f (1 or 2 below), the symbols 0, S and f, and a finite set of variable names (x, y for k = 1 and x, y, z for k = 2). A *term* is built from these; its *size* is its number of symbols. The numeral n̲ is S applied n times to 0. An *identity* is a pair of terms, written s = t and read as holding for all values of the variables. An *identity set* T is a finite list of identities; its size |T| is the total size of its terms.

**Proof.** T ⊢ s = t means that s = t follows from T by equational logic: reflexivity, symmetry, transitivity, substitution of terms for variables, and replacement of equals inside a term. By Birkhoff's completeness theorem this is the same as: s = t holds in every algebra (any set with interpretations of 0, S and f) in which T holds.

* T is *consistent* if it proves m̲ = n̲ for no two different numbers m and n.
* T *proves the datum* (x, y) if T ⊢ f(x̲) = y̲. T *fits* a data set D if T is consistent and proves every datum in D.
* A function g on the natural numbers is a *standard model* of T if every identity of T is true of g, with 0 and S read as usual. If T has a standard model g then T is consistent and every datum it proves is true of g (soundness).

**Prior and beliefs.** Write T as a string: its terms in Polish notation, then an end marker. The alphabet has a symbols (a = 6 for k = 1 and a = 7 for k = 2), and w(T) = a^(−(|T|+1)). These weights sum to less than 1. For a data set D,

    M_E(D) = sum of w(T) over the sets T that fit D,      Bel(y | D, x) = M_E(D + (x,y)) / M_E(D).

Basic facts:

* **Beliefs are sub-additive.** A consistent T proves at most one value at x, so the beliefs in the labels at x sum to at most 1. The remainder is the posterior weight of the sets that leave f(x) *undetermined*.
* **Some set always fits.** The data themselves, written as identities f(x̲) = y̲, are a consistent set that proves every datum and determines nothing else. So M_E(D) > 0 for every D.
* **Order does not matter.** M_E(D) depends on D as a set.
* **Consistency is not the existence of a standard model.** For unary f, the single identity x = S(f(S(x))) forces S to be a bijection with inverse f∘S. It holds in the integers with f(x) = x − 2, so it is consistent, and it proves that f(x̲) is the numeral of x − 2 for every x ≥ 2. But no function on the natural numbers satisfies it, since 0 would need a predecessor.
* **Neither proof nor consistency is decidable.** Proofs can be searched for, and so can proofs of inconsistency, so M_E(D) is a difference of two numbers that can be approximated from below. We know no way to compute it. Section 6 computes a version with bounded proofs.

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

The bound for addition is attained for 3 ≤ m ≤ 6 among identities in three variables (Section 6).

**Corollary 4 (pinning of addition and successor).**

1. Let D be data from addition that contain x + y for all x, y < n. Every fitting set whose identities have sides of at most n + 1 symbols has addition as a standard model. For every input x and every wrong value y,

       Bel(y | D, x) ≤ 7^13 · ε(n+1) ≤ 2^(36.5 − 0.485·n).

2. Let D be data from successor that contain x + 1 for all x < n. Every fitting set whose identities have sides of at most n symbols has successor as a standard model, and Bel(y | D, x) ≤ 6^5 · ε(n) ≤ 2^(13 − 1.58·n) for every wrong y.

*Proof.* Theorems 2 and 3, with the sets {f(x,0) = x, f(x,S(y)) = S(f(x,y))} of 12 symbols and {f(x) = S(x)} of 4 symbols, which have addition and successor as standard models and prove all their values. The weights ε are computed exactly in [`code/prior_tail.py`](code/prior_tail.py): ε(m) = (1/a)·(1/(1 − q²) − 1/(1 − q_m²)), where q is the total weight a^(−size) of all terms and q_m that of the terms of size at most m. For k = 2 the number of terms of size s grows like 5^s, so ε(n+1) decays like (5/7)^n = 2^(−0.485·n); for k = 1 it is 3·2^(s−1), and ε(n) is about 3^(−n). The stated inequalities were checked for n ≤ 3000. ∎

| n | bound on the belief in any wrong sum (addition) | bound for successor | for comparison, log₂ n |
|---|---|---|---|
| 20 | (no bound below 1) | 2^(−18.8) | 4.3 |
| 50 | (no bound below 1) | 2^(−66.4) | 5.6 |
| 100 | 2^(−21.1) | 2^(−145.6) | 6.6 |
| 200 | 2^(−71.1) | 2^(−304.1) | 7.6 |
| 1000 | 2^(−462.9) | 2^(−1572.1) | 10.0 |

These are guarantees and are far from tight for small n: the constant 2^36.5 is the whole prior cost of the two laws of addition, and the sets that actually deviate cost much more than one long identity (Section 4).

**Comparison with SOI.** Given the same data, SOI gives a wrong sum at an input x outside the square probability at least 2^(−K(Q) − K(y) − c) for every decidable Q that contains x and no seen input (Paper 1, Proposition 8.1). For x just outside the square this is about 2^(−K(n)), and for x beyond the simplest number above n it is far more. So SOI's pinning outside the square is at most about log₂ n + 2·log₂ log₂ n + c bits, the last column of the table, and for round n much less. The equational inductor's is at least 0.485·n − 36.5 bits, at every input.

The statement is about data that are complete up to n. If small pairs are missing, exceptions at those pairs are cheap: plus with the value at (1,1) changed has an identity set of 68 symbols (Section 4), which fits every data set that omits (1,1). What the inductor never offers cheaply is an exception at a pair of large numbers.

## 4. What exceptions cost

**Definition.** The *law complexity* C_E(g) of a function g is the least size of a consistent identity set that proves every value of g, and ∞ if there is none. By Lemma 1 applied to all of g, such a set contains only identities that are true of g. So C_E(g) is the least size of a set of laws of g from which all its values follow.

**Proposition 5.**

1. C_E(plus) ≤ 12 and C_E(successor) ≤ 4. The table below gives verified sets for some other targets.
2. If g ≠ plus agrees with plus on [0, n)², then C_E(g) ≥ n + 3. So C_E(quus_N) ≥ N + 3, where quus_N(x,y) is x + y if x, y < N and 5 otherwise, and C_E(g) ≥ max(a, b) + 3 when g is plus with a different value at (a, b).
3. C_E(quus_N) ≤ 2N³ + 2N² + 2N + 18.

*Proof.* (2) Let T be consistent and prove every value of g, and let x be an input with g(x) ≠ plus(x). T fits plus on [0, n)², since g agrees with plus there. If all its sides had at most n + 1 symbols, plus would be a standard model of T by Theorems 2 and 3, and T could not prove the datum (x, g(x)), which is false of plus. So some side has at least n + 2 symbols, and the other side has at least one. (3) The set with the two identities f(S^N(x), y) = 5̲ and f(x, S^N(y)) = 5̲ and the N² ground identities f(a̲, b̲) = a+b for a, b < N is true of quus_N and proves all its values. ∎

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

In SOI a patch costs K(f) plus the complexity of its guard, so quus_N costs K(plus) + K(N) + c bits: about log N more than plus, and much less for round N. Here it costs at least N symbols more. The true cost is somewhere between N and 2N³; we have not tried to narrow this.

**Proposition 6 (squaring has no finite set of laws).** For unary f, C_E(x ↦ x²) = ∞.

*Proof.* Let T be consistent and prove every value of squaring; then every identity of T is true of squaring. A term is a word over {S, f} applied to a variable or to 0. Under squaring, a word w applied to x is a polynomial p_w(x) with positive leading coefficient, of degree 2^(number of f in w).

*An identity with a variable that is true of squaring has identical sides.* A term with a variable is not constant, so its other side must contain the same variable, and we need: p_w = p_w′ implies w = w′. Induct on the lengths. The degrees give the same number of f. If one word is empty, the other has no f, and no S either, by comparing constant terms. If both words begin with S, or both with f, remove it (a polynomial with positive leading coefficient is determined by its square) and continue. If w = S·w₁ and w′ = f·w′₁, then p_w₁ + 1 = q² with q = p_w′₁ not constant. Write w₁ = S^a·w₂ with w₂ empty or beginning with f. If w₂ is empty, x + a + 1 = q² is impossible by degree. Otherwise p_w₂ = r² with r not constant and r² + a + 1 = q², so (q − r)(q + r) is the constant a + 1; then q − r and q + r are constants, and so are q and r, a contradiction.

So T consists of ground identities and identities with identical sides. Let V be the finite set of numbers at which f is applied when the ground terms of T are evaluated under squaring. Take j outside V and let g′ be squaring with the value at j changed. Evaluating the terms of T under g′ never applies f at j, so T is true of g′, and T does not prove f(j̲) = j². ∎

**Proposition 7 (learning, and the price of confidence).**

1. If C_E(g) < ∞, then M_E(D) ≥ a^(−(C_E(g)+1)) for all data D from g. So along any sequence of distinct inputs the total of −log₂ Bel(true label) is at most (C_E(g) + 1)·log₂ a, and the true label has belief at most ½ at most that many times.
2. If C_E(g) = ∞, then M_E(D_n) → 0 along any enumeration D_n of the values of g: every hypothesis is eventually refuted or fails to prove a datum. The inductor's cumulative loss grows without bound, while SOI's stays below K(g) + c.
3. Let the truth g agree with plus on [0, n)² and differ from it at x. After data containing that square, the belief in the true label at x is at most 7^13·ε(n+1) ≤ 2^(36.5 − 0.485·n). SOI's loss at the same datum is at most K(Q) + K(g(x)) + c for any decidable Q that contains x and no seen input.

*Proof.* (1) A least set for g fits every D from g; the beliefs along the sequence multiply to M_E(D_n)/M_E(∅) ≥ M_E(D_n). (2) No single set fits all the D_n, so each term of the sum defining M_E(D_n) is eventually 0, and the sum is dominated by the convergent sum of all weights. For SOI see Paper 1. (3) is Corollary 4 with the roles reversed: the true label is a wrong sum. ∎

Item 3 is the price, as in Theorem 5 of `note.md`: pinning is a bet. If quus_N is the truth, the equational inductor is confident of the wrong answer at the first exception, loses about N/2 bits there, and then needs a set of more than N symbols to recover. SOI loses about log N bits.

## 5. The vocabulary is the bias

**No machine, no grue theorem.** Theorem 3 of `note.md` says that a scheme whose bias comes from a reference machine alone can be flipped at x by a machine about sep(x; A) bits away. The equational inductor is not such a scheme. It has no machine. And a relabelling of outputs is not a symmetry of its hypotheses: exchanging two labels at the inputs in a set Q turns plus into a patched function whose law complexity is far larger (Proposition 5), because the laws apply S to outputs and feed outputs back in as inputs, and a relabelling of outputs alone does not respect that. What it has in place of a machine is its vocabulary, and the right question is how its behaviour depends on that.

**Proposition 8 (auxiliary symbols bring the guards back).** Let identities use further function symbols, of any arities, with "fits" defined as before (consistent, and proves the data about f).

1. For N = 2^j, quus_N has a set of 79 + 2j symbols that is true in a standard model and proves all its values. It uses four auxiliary symbols: h for plus, d for doubling, l for "less than" and c for a conditional, each with its recursion equations, and the single identity f(x,y) = c(l(x,N̄), c(l(y,N̄), h(x,y), 5̲), 5̲), where N̄ is d applied j times to 1̲.
2. Every computable function has such a set (Herbrand, Gödel and Kleene's characterisation of the computable functions by systems of equations).

So with auxiliary symbols, a set of 79 + 2⌈log₂ n⌉ symbols fits plus on [0, n)² and proves wrong sums outside it. The pinning is logarithmic in n again, as in SOI. The extended inductor is in effect SOI with the equation calculus as its reference machine.

*Proof.* (1) The set is listed in [`results/theories.out`](results/theories.out) and checked there for j ≤ 3; its identities are true when the symbols are read as described, for every j. (2) Kleene, *Introduction to Metamathematics* (1952), §54–55. ∎

**Proposition 9 (a background doubling function makes powers of two cheap).** Add a symbol d to the vocabulary, with the *background* identities d(0) = 0 and d(S(x)) = S(S(d(x))), which every hypothesis contains at no cost. Let g_j be plus with the value at (2^j, 0) changed to 0. There is a set P_j of j² + 10j + 33 symbols that is true of g_j and, with the background, proves all its values:

    f(x, 1̲) = S(x),   f(x, S(S(y))) = S(f(x, S(y))),   f(0, 0) = 0,
    f(t, 0) = t   for t = dⁱ(S(d(x))), i = 0, …, j−1,   and for t = dʲ(S(S(x))),
    f(dʲ(1̲), 0) = 0.

So P_j fits plus on [0, n)² for every n ≤ 2^j and proves a wrong sum: with doubling in the vocabulary, the exception costs about log² n symbols.

*Proof.* Each identity is true of g_j: the first two concern pairs with second argument at least 1; a first argument of the form 2ⁱ·(2x+1) with i < j, or 2ʲ·(x+2), is never 2ʲ. Every first argument p falls under exactly one case: p = 0, or p = 2ⁱ·odd with i < j, or p = 2ʲ·m with m ≥ 2, or p = 2ʲ. The background proves p̲ equal to the corresponding term. Checked by machine for j ≤ 4. ∎

Lemma 1 and Theorem 2 hold in these vocabularies too. What changes is the test radius: with doubling, the identity f(dʲ(1̲), 0) = 0 has a side of j + 4 symbols, is false of plus, and is refuted only by data that reach 2^j.

**The naming principle.** For addition, a false identity fails already at an assignment of zeros and ones (proof of Theorem 3). So an identity that is false of plus and not refuted by plus on [0, n)² must contain a term whose value at such an assignment is at least n: it must *name a number beyond the data*. An exception costs at least what that costs in the vocabulary, and the examples show the cost is reached up to a polynomial.

| vocabulary | least size of a set that fits plus on [0, n)² and proves a wrong sum |
|---|---|
| {0, S, f} | more than n; at most n² + 8n + 36 (plus with the value at (n, 0) changed) |
| {0, S, f} with doubling in the background | more than log₂ n; at most log₂² n + 10·log₂ n + 33 for n a power of two |
| {0, S, f} with auxiliary symbols | at most 79 + 2·log₂ n for n a power of two |
| programs (SOI) | about K(n) bits, at most about log₂ n and far less for round n |

So the strong pinning of Section 3 is what induction over laws gives when large numbers have no short names. This is a real restriction and a real choice. The more functions the vocabulary contains, the more numbers have short names, and the cheaper it becomes to state an exception at one of them. A vocabulary that contains every computable function prices exceptions as SOI does.

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
| square | 3 | 5 | 17 | 257 | 65537 | | |

* **Plus and successor meet the bounds of Theorem 3 exactly** (m − 1 for m ≥ 3, and m), and x + 2 is within its bound 2m.
* **Targets with a threshold start high.** Quus_5 has test radius 7 already at m = 3, and the patched targets start above their patch: short laws that are false of them are refuted only by data that reach the exception.
* **Fast-growing targets have fast-growing test radius**, 2^(m−2) + 1 for doubling and doubly exponential for squaring, because a short term can reach a large number by nesting f. For these Theorem 2 needs much more data per symbol.
* The bound on the search matters for the last rows of each table only through what counts as false; for plus and successor the values agree with the proof.

