# Ultranatural functions

*Can many confirmed properties pin a function down more strongly than Solomonoff operator induction does?*

A research note by Claude (Anthropic), in response to a question from Kaarel Hänni. Draft. One independent AI referee checked every statement and re-implemented the experiment; its report and what was changed in response are in [`verification/`](verification/). No human has checked the mathematics.

## The question

In Solomonoff operator induction (SOI) we predict the label y at a new input x from pairs (x₁,y₁),…,(xₙ,yₙ). Hänni's question:

* Sometimes many natural properties P(x,y) have held of every pair so far, and together they leave a single choice of y at the new x.
* Every choice of y breaks *some* property for the first time, for instance the property "at this particular x the label is not y".
* Is there still a useful notion of a function being pinned down, by many properties at once, more strongly than SOI pins it down, at least on most new inputs? Could successor or addition be "ultranatural"?
* Or does a contrived universal machine, one that likes to break every property at one particular input, spoil any such notion?

## Answers in brief

1. **The idea formalises cleanly, and in its machine-independent form it is what SOI already does.** Call the *exclusion complexity* of a label y at x the complexity of the simplest property that is true of all pairs so far and that (x,y) would break. For a target f, the properties of complexity at most k leave exactly the label f(x) for every k from K(f) up to about the *separation complexity* sep(x; A): the complexity of the simplest test that tells x apart from all the inputs A seen so far. Beyond sep(x; A) they leave no label at all (Theorem 1). Up to K(f) + O(1) bits, this window is SOI's own margin at x.
2. **How many properties a wrong label breaks does not matter.**
   * One guard, "if the input is like x, do something else", breaks all of them at once for about sep(x; A) bits.
   * The cheapest property that the *right* label breaks costs sep(x; A) bits, up to K(f). For simple f it is essentially "no input like x occurs", which every label breaks.
   * A tally of the properties each label would break adds nothing to SOI. At typical new inputs it agrees with SOI. At inputs with sep(x; A) below SOI's loss on the data it is dominated, for every label, by guard properties that the data never tested (Proposition 2).
3. **The worry about contrived machines is exactly right, and it applies to every scheme whose inductive bias comes from the reference machine alone** (Theorem 3). For every such scheme, every new input x and binary labels, there is a universal machine at distance sep(x; A) + O(1) from the given one that agrees with it on everything that does not involve inputs like x and on which the scheme gives the opposite answer at x. No way of tallying properties gets around this. SOI's Kolmogorov version is stable under changes of machine of up to half its margin at x, and no further (Proposition 4). Whether some scheme is stable beyond half of sep(x; A) is open.
4. **"On most new inputs" is true of SOI itself.** After n independent samples, a change of machine by a bits can change the prediction only on a set of inputs of measure about 2^(2a+K(f))·(a + K(f))/n (Propositions 4 and 6). Inputs of a new kind, all separated from the data by one simple test, are all fragile together.
5. **Stronger pinning has a price, and the room for it is known.** The strength with which a learner pins f(x) against a label y is, by definition, the loss it suffers if (x,y) turns out to be the next datum. A learner whose regret on every computable function g is at most K(g) + b can exceed SOI's pinning by at most b plus the loss SOI has already paid on the data, which is at most K(f) bits (Theorem 5). So within universal learners, "pinned more strongly" can only mean "f has more prior mass than 2^(−K(f))", which is a choice of machine.
6. **Where the intuition is right.** The hypotheses that disagree with f at x and survive the data are of two kinds. *Far* alternatives differ from f on a fraction δ of inputs; n data points kill them at rate (1−δ)ⁿ, so the cheapest survivor costs at least about δn bits (Proposition 7). Laws such as linearity or the recursion equations of addition make all lawful alternatives far, and against these many confirmed constraints do add up, exponentially. *Near* alternatives are patches of f on small sets; their cheapest survivor costs only about K(f) + log n bits. SOI's residual doubt at a typical new input, of order 1/n up to factors 2^(±K(f)) and log² n, is entirely patches.
7. **A notion that does not collapse: isolated functions.** Call f *δ-isolated*, or *ultranatural at scale δ*, if every other function that differs from f on less than a fraction δ of inputs is more complex than f. Equivalently: erase the values of f on any set of measure less than δ, and the simplest function consistent with what remains is f again (Proposition 8). Induction over isolated functions only ("patch-free" induction) pins an isolated f at *every* input at once, with expected posterior error at most 2^(K(f))·(1−δ)ⁿ (Theorem 9). The price: it cannot learn small exceptions, and its confidence is exactly as machine-relative as item 3 says.
8. **Successor and addition are ultranatural in a concrete language.** In a small language of bounded primitive recursion with no addition primitive, enumerated exhaustively up to 11 nodes (86,265 functions on a 6×6 grid of inputs), the nearest function no more complex than successor differs from it on 30 of 36 inputs, and for addition on 24 of 36. The patches of addition that we tried are not isolated, or only at the scale of the patch. About 13% of all functions are isolated at scale δ = 1/6. After 16 random examples of addition, a hypothesis at most 2 nodes larger than addition still fits the data and disagrees with addition at 7% of the unseen inputs; among hypotheses isolated at δ = 1/6 there is none, and the posterior probability of a wrong label falls from 2·10⁻³ to about 10⁻⁶ (Section 6).

So: no scheme that takes its bias from the machine is stable at x beyond sep(x; A) + O(1) bits of machine change, and the tally of properties has the same window as SOI's margin; both are theorems. Relative to a reference machine there is a natural stronger notion, isolation, with a matching inductor. It makes precise the sense in which many constraints at once pin a function down, and it says what the extra confidence costs.

## 1. Setting and notation

* **Inputs and labels.** X is the set of binary strings, Y a countable set of labels containing 0 and 1. A data set D is a finite partial function from X to Y, with domain A = dom D. D + (x,y) is D with one more pair, for x ∉ A.
* **Hypotheses.** Total computable functions g : X → Y. "g ⊇ D" means g is consistent with D. Working with total functions makes the set where two hypotheses differ decidable. The papers' versions of SOI allow partial functions; Remark 1.1 says what carries over.
* **Complexity.** Fix a universal prefix machine. K(g) is the length of a shortest program for g. For a decidable set (a set of inputs Q ⊆ X or a set of pairs P ⊆ X × Y), K is the length of a shortest program for a total decider; K of a label or of a computable map is defined likewise. K(· | f) is complexity given a shortest program for f. We use:
  * K(Q | f) ≤ K(Q) + c and K(Q) ≤ K(Q | f) + K(f) + c;
  * at most 2^k objects have complexity at most k (programs form a prefix-free set);
  * subadditivity: an object built by a fixed effective construction from objects u and v has complexity at most K(u) + K(v) + c, and at most K(u) + K(v | u) + c.

  The letter c denotes a constant that depends only on the reference machine and may differ from one occurrence to the next. Logarithms are to base 2.
* **Vanilla induction.**
  * K_tot(D) is the least K(g) over total g ⊇ D. The Kolmogorov version predicts at x the value of a simplest consistent total function (the one with the first shortest program, if there are several).
  * W_tot(D) is the sum of 2^(−K(g)) over total g ⊇ D: the mixture version. Its posterior probability of the label y at x is W_tot(D + (x,y)) / W_tot(D), and L(D) = −log W_tot(D) is its cumulative loss on D. Always 2^(−K_tot(D)) ≤ W_tot(D) ≤ 1, so L(D) ≤ K_tot(D) ≤ K(f) for every total f ⊇ D.
* **Separation complexity** (the novelty of Paper 1, Proposition 8.5). A set Q ⊆ X *separates* x from A if x ∈ Q and Q ∩ A = ∅.
  * sep(x; A) is the least K(Q) over decidable Q separating x from A.
  * sep(x; A | f) is the least K(Q | f). So sep(x; A) − K(f) − c ≤ sep(x; A | f) ≤ sep(x; A) + c.
* **The floor** (after Paper 1, Proposition 8.1). If Q separates x from A and f ⊇ D is total, the function equal to the constant y on Q and to f elsewhere is total, consistent with D, takes the value y at x, and has complexity at most K(f) + K(Q | f) + K(y) + c. Hence, for y ∈ {0,1},

      K_tot(D + (x,y)) ≤ K(f) + sep(x; A | f) + c   and   W_tot(D + (x,y)) ≥ 2^(−K(f) − sep(x; A | f) − c).

  We call such a function a *patch* of f, and the test "is the input in Q?" a *guard*.

"Paper 1" is *Solomonoff Operator Induction: Definitions, Versions and Basic Theorems* in [`../solomonoff-operator-induction/`](../solomonoff-operator-induction/); its Section 8 treats out-of-distribution behaviour. "Paper 2" is its companion on steeper priors.

**Remark 1.1 (the papers' versions).** For the papers' mixtures over all programs (W) and over tapes (M_F) the floor holds in the stronger relative form ν(D + (x,y)) ≥ 2^(−K(Q) − K(y) − c)·ν(D) (Paper 1, Proposition 8.1); for W_tot, a sum over functions, we only have the form above. Theorem 3 below holds for those versions as well. Statements below that bound the complexity of a dissenting hypothesis from below use that the set where it differs from f is decidable. For partial hypotheses that set is only computably enumerable, and we expect the same proofs to give the bounds with separation by c.e. sets in place of decidable ones; we have not written this out, nor tried to close the gap between the two kinds of separation.

## 2. Properties true so far

**Definition.** A *property* is a decidable set P ⊆ X × Y. It is *true so far* if D ⊆ P. For x ∉ A:

* the *exclusion complexity* excl(x,y) is the least K(P) over properties P that are true so far and do not contain (x,y);
* the *consensus at level k* is S_k(x) = { y : excl(x,y) > k }, the labels allowed at x by every property of complexity at most k that is true so far.

Every label has finite exclusion complexity: this is the observation that every label breaks some property for the first time.

**Theorem 1 (the consensus window).** There is a constant c such that for every data set D, every x ∉ A and every total computable f ⊇ D:

1. excl(x,y) ≤ K(f) + c for every y ≠ f(x);
2. sep(x; A | f) − c ≤ excl(x, f(x)), and excl(x,y) ≤ sep(x; A) + c for *every* label y, including f(x);
3. consequently S_k(x) = { f(x) } whenever K(f) + c ≤ k < sep(x; A | f) − c, and S_k(x) = ∅ whenever k ≥ sep(x; A) + c;
4. if g ⊇ D is total and K(g) + c ≤ k, then S_k(x) ⊆ { g(x) }.

*Proof.* (1) and (4): the graph of a total computable g is decidable with complexity at most K(g) + c, it contains D when g ⊇ D, and it contains (x,y) only for y = g(x).

(2), upper bound: let Q separate x from A with K(Q) = sep(x; A). The property P_Q = { (x′,y′) : x′ ∉ Q } has complexity at most K(Q) + c, contains D because A ∩ Q = ∅, and contains no pair (x,y).

(2), lower bound: let P be true so far with (x, f(x)) ∉ P. The set Q = { x′ : (x′, f(x′)) ∉ P } is decidable from a decider for P and a program for f, so K(Q | f) ≤ K(P) + c. It contains x. It misses every xᵢ ∈ A, because (xᵢ, f(xᵢ)) = (xᵢ, yᵢ) ∈ D ⊆ P. So Q separates x from A and sep(x; A | f) ≤ K(P) + c.

(3) follows from (1) and (2). ∎

What the theorem says about the question:

* **The properties do single out one label**, the one that every sufficiently simple consistent function gives. Inside the window, properties that are not graphs of functions add nothing.
* **The right label is excluded too**, at a level between sep(x; A | f) and sep(x; A), which differ by at most K(f) + c. The property that always does it at level sep(x; A) has nothing to do with f: "no input in Q occurs". It is true of all pairs so far, and every label at x breaks it. A cheaper property can exclude the right label only by using up to K(f) bits about f. For example, if all labels so far are 0 and f(x) = 1, then "the label is never 1" does it for O(1) bits.
* **The window is SOI's margin.** By the floor, and by the proof of the lower bound applied to graphs, the simplest total function consistent with D that disagrees with f at x has complexity between sep(x; A | f) − c and K(f) + sep(x; A | f) + c. So the margin of the Kolmogorov version at x and the width of the consensus window both equal sep(x; A | f) up to K(f) + c.

**Proposition 2 (a tally of broken properties).** For x ∉ A let v(y) be the sum of 2^(−K(P)) over properties P that are true so far and do not contain (x,y): the weight of what the label y would break. For two labels y ≠ y′ let m(y, y′) be the sum of 2^(−K(P)) over properties true so far that contain (x,y) and not (x,y′), so that v(y′) − v(y) = m(y, y′) − m(y′, y). Let f ⊇ D be total computable.

1. v(y′) ≥ 2^(−K(f) − c) for every y′ ≠ f(x).
2. For y, y′ ∈ {0,1}: v(y) ≥ 2^(−sep(x; A) − c), and m(y, y′) ≥ 2^(−sep(x; A) − c) in both orders.
3. The graphs of total functions consistent with D contribute at most 2^c · W_tot(D) to m(y, y′).
4. If A consists of n independent samples from a probability measure μ on X and x is a further independent sample, then the expectation of v(f(x)) is at most 1/(n+1).

*Proof.* (1) The graph of f. (2) For a separating Q of least complexity, P_Q of Theorem 1 gives the bound on v, and { (x′,y″) : x′ ∉ Q or y″ = y } is true so far, contains (x,y) and not (x,y′), with complexity at most K(Q) + c. (3) A decider for the graph of g yields a program for g, so K(g) ≤ K(graph g) + c; sum over g. (4) Fix a property P and let t = μ{ x′ : (x′, f(x′)) ∉ P }. P is true so far and excludes (x, f(x)) with probability t·(1−t)ⁿ ≤ 1/(n+1). The weights 2^(−K(P)) sum to at most 1. ∎

So the tally behaves as follows.

* **At typical new inputs it agrees with SOI.** By (1) and (4), with probability 1 − η the right label breaks the least weight as soon as n + 1 > 2^(K(f)+c)/η. This is the rate 2^(K(f))/n of SOI's own error bound (Paper 1, Remark 8.9(iv)).
* **At inputs with sep(x; A) well below L(D) it is dominated by guards.** By (2) and (3), the consistent functions, which are all that SOI's verdict rests on, are then a negligible part of the tally for either label, and guard properties, true so far only because no input so far was in Q, weigh at least 2^(−sep(x; A) − c) on each side. Since L(D) ≤ K(f), this regime needs sep(x; A) < K(f).
* **In no regime does it pin the right label beyond the floor:** v(f(x)) ≥ 2^(−sep(x; A) − c) by (2).

One can weigh each property by its record: by the likelihood it gives the data when a label is drawn uniformly from the labels it allows (for finite Y). That is Bayes over set-valued hypotheses, a mixture of product laws in the sense of Paper 1, and so a version of SOI, between W_tot and Paper 1's product mixture up to constant factors. Under it a guard property alone has saved nothing on the data, and a guard combined with f costs K(f) + sep(x; A | f) bits.

**Remark 2.1 (properties of several pairs).** Laws such as commutativity relate several pairs. Allowing properties of finite sets of pairs adds ways to exclude every label, the right one included, while wrong labels were already excluded at level K(f) + c. The property "no two inputs differ in exactly their last bit" may be true of the data, costs O(1) bits, and is broken by every label at a new input that is a last-bit neighbour of an old one, although no cheap *function* misbehaves there. Laws about several pairs matter in Section 4, where they make classes of functions rigid.

## 3. Why no tally of properties can beat the margin

### 3.1 The grue theorem

Goodman's predicate "grue" is a relabelling of colours on the unexamined emeralds. Here is the corresponding statement for any inductive scheme.

**Definitions.**

* A *reference machine* V is a partial computable map from a prefix-free set of programs to indices of partial computable functions X ⇀ Y. K_V(g) is the length of a shortest V-program for g. V is *universal* if for every reference machine V′ there is c with K_V ≤ K_V′ + c. The *distance* between universal machines is dist(V, V′) = sup over total computable g of |K_V(g) − K_V′(g)|, which is finite. Complexities of sets, labels and relabellings, and separation complexities, are always taken on the fixed machine of Section 1; constants c may depend on V.
* A *relabelling* ρ is a computable bijection of X × Y of the form ρ(x,y) = (x, ρ_x(y)). It acts on functions by (ρg)(x) = ρ_x(g(x)) and on data sets pair by pair. V^ρ is the machine on which each program p computes ρ applied to what p computes on V. K(ρ) is the complexity of a pair of programs for ρ and ρ⁻¹.
* A *scheme* S assigns to every universal machine V, data set D and input x ∉ dom D a label S_V(D,x), or a probability distribution on labels. S is *relabelling-equivariant* if S_{V^ρ}(ρD, x) = ρ_x(S_V(D,x)) for all V, ρ, D and x.

Equivariance says that the scheme has no preference among labellings beyond what its reference machine supplies. It fails for schemes with a built-in bias, such as "always answer 0" or "use the machine V₀ whatever V is". It holds for:

* the Kolmogorov version, and every mixture whose weights depend only on program length (W, W_tot, the steeper priors of Paper 2): a program is consistent with ρD on V^ρ exactly when it is consistent with D on V;
* the one-tape and per-query versions, when the universal function machine's outputs are relabelled in the same way;
* any tally of properties, when the machine also describes properties and V^ρ lets each program describe ρP where it described P on V;
* the patch-free induction of Section 5.

**Lemma A.** V^ρ is universal, K_{V^ρ}(g) = K_V(ρ⁻¹g), and dist(V, V^ρ) ≤ K(ρ) + c.

*Proof.* A program computes g on V^ρ exactly when it computes ρ⁻¹g on V. For any relabelling σ, the machine that reads a self-delimiting description of σ followed by a V-program p, and computes σ applied to what p computes, is a reference machine; so K_V(σh) ≤ K_V(h) + K(σ) + c for every h. With σ = ρ⁻¹ and h = g this gives K_{V^ρ}(g) ≤ K_V(g) + K(ρ) + c. With σ = ρ and h = ρ⁻¹g it gives the reverse inequality. Universality follows. ∎

**Theorem 3 (grue).** Let S be relabelling-equivariant, V universal, D a data set, x ∉ A, Q a decidable set separating x from A, and y ≠ y′ two labels. Let ρ exchange y and y′ at the inputs in Q and fix everything else, and let V′ = V^ρ. Then:

1. S_{V′}(D,x) is S_V(D,x) with the roles of y and y′ exchanged; in particular, if S_V(D,x) = y then S_{V′}(D,x) = y′;
2. dist(V, V′) ≤ K(Q) + K(y) + K(y′) + c, which for y, y′ ∈ {0,1} and the best Q is sep(x; A) + c;
3. V′ and V are indistinguishable away from Q: S_{V′}(E, x′) = S_V(E, x′) for every data set E with dom E ∩ Q = ∅ and every x′ ∉ Q.

*Proof.* ρ is its own inverse and K(ρ) ≤ K(Q) + K(y) + K(y′) + c, so (2) is Lemma A. Since A ∩ Q = ∅ we have ρD = D, and equivariance gives S_{V′}(D,x) = S_{V′}(ρD,x) = ρ_x(S_V(D,x)), which is (1). For (3), ρE = E and ρ_{x′} is the identity. ∎

So the machine "that likes to flip everything at inputs like x" always exists, lies only sep(x; A) + O(1) bits away for binary labels, and defeats every equivariant scheme at x, however the scheme aggregates properties. Paper 1 (Proposition 8.2) constructs such machines for SOI, giving the bad behaviour posterior probability ½. Here the flip is exact and the scheme arbitrary.

### 3.2 How stable SOI is

**Proposition 4.** Let V be the machine of Section 1. Let f be a total function of least complexity consistent with D, let g be a total function of least complexity among those consistent with D and different from f at x, and let m = K(g) − K(f) be the margin at x.

1. sep(x; A | f) − K(f) − c ≤ m ≤ sep(x; A | f) + c.
2. If V′ is universal with dist(V, V′) = a and 2a < m, then every total function of least V′-complexity consistent with D takes the value f(x) at x.
3. If m ≥ 3, then for every integer a with m/2 < a < m there is a universal V″ with dist(V, V″) ≤ a on which every total function of least complexity consistent with D differs from f at x.

*Proof.* (1) The set { x′ : g(x′) ≠ f(x′) } is decidable from programs for g and f and separates x from A, so K(g) ≥ sep(x; A | f) − c. The upper bound is the floor.

(2) For every total h ⊇ D with h(x) ≠ f(x): K_V′(h) ≥ K(h) − a ≥ K(g) − a > K(f) + a ≥ K_V′(f).

(3) (This construction is the referee's.) Let L = K(g) − a, so K(f) < L. Let Π be the finite set of V-programs of length at most L that compute total functions consistent with D and equal to f(x) at x, and let p_f ∈ Π be a shortest program for f. Define V″ as V with two changes: each p ∈ Π is replaced by the program p·1·0^(a−1) with the same output, and the program p_f·0^(L−K(f)) is added with output g. The domain stays prefix-free. The complexity of g drops by a, complexities of functions computed by programs in Π rise by at most a, and nothing else changes, so V″ is universal and dist(V, V″) ≤ a. On V″ the function g has complexity L, while every consistent total function equal to f(x) at x has complexity above L: its programs of length at most L were lengthened to at least K(f) + a > L. ∎

So the Kolmogorov version is stable at x under changes of machine of up to m/2 bits, and not beyond m/2 + 1, where m is sep(x; A | f) up to K(f) + c. Theorem 3 bounds every equivariant scheme by sep(x; A) + c. We do not know whether any equivariant scheme is stable beyond half of sep(x; A).

### 3.3 The price of pinning

**Definition.** Let π be a probability measure (or a semimeasure) on total functions, and π(E) the mass of the functions consistent with the data set E. The *pinning* of π at x against the label y is

    pin_π(x, y; D) = −log π(D + (x,y)) + log π(D),

minus the log of the posterior probability of the label y at x.

**Theorem 5 (price and headroom).**

1. pin_π(x, y; D) is the log loss that π suffers at x if (x,y) is the next datum.
2. Suppose π has regret at most λK + b: π(E) ≥ 2^(−λ·K_tot(E) − b) for every data set E. Then for every total f ⊇ D, every decidable Q separating x from A and every label y,

       pin_π(x, y; D) ≤ λ·(K(f) + K(Q | f) + K(y) + c) + b.

3. Let π_f = ½·(point mass at f) + ½·W_tot, where f ⊇ D. It has regret at most K + 1, and for every y ≠ f(x)

       L(D) ≤ pin_{π_f}(x, y; D) − pin_{W_tot}(x, y; D) ≤ L(D) + 1.

   Conversely, for every π with regret at most K + b, and all x and y, pin_π(x, y; D) − pin_{W_tot}(x, y; D) ≤ L(D) + b.

*Proof.* (1) is the definition. (2) The patch g of Section 1 is consistent with D + (x,y) and K(g) ≤ K(f) + K(Q | f) + K(y) + c, so pin_π ≤ −log π(D + (x,y)) ≤ λ·K_tot(D + (x,y)) + b. (3) For y ≠ f(x), π_f(D + (x,y)) = ½·W_tot(D + (x,y)) and ½ ≤ π_f(D) ≤ 1, so pin_{π_f} lies between −log W_tot(D + (x,y)) and −log W_tot(D + (x,y)) + 1, while pin_{W_tot} = −log W_tot(D + (x,y)) − L(D).

For the converse, first π({g}) ≥ 2^(−K(g) − b) for every total computable g: let E_n be g restricted to the first n inputs. Then K_tot(E_n) ≤ K(g), so π(E_n) ≥ 2^(−K(g) − b), and π(E_n) decreases to π({g}). Hence π(E) ≥ 2^(−b)·W_tot(E) for every E. With D′ = D + (x,y),

    pin_π − pin_{W_tot} = log( W_tot(D′)/π(D′) ) + log( π(D)/W_tot(D) ) ≤ b + L(D). ∎

Reading:

* **Pinning is a bet.** To pin f(x) with s bits against y is to pay s bits when the exception is real.
* **Universal learners have at most L(D) + b ≤ K(f) + b bits of room over SOI.** The room is reached by a learner that was told f in advance, which is a change of machine that makes f short. This is the only sense in which a universal learner can treat addition as more natural than SOI does.
* **Non-universal routes all pay according to (1).**
  * *Steeper priors* (Paper 2): weights 2^(−λ·length) on deterministic programs lower the floor to 2^(−λ·sep(x; A)), and the regret has slope λ.
  * *Independent priors on the coordinates of the output* charge a patch once per coordinate it changes, and pay the sum of the coordinates' complexities to learn f.
  * *Patch-free induction* (Section 5) charges a small patch infinitely much.

### 3.4 Most new inputs

**Proposition 6.** Let μ be a probability measure on X, let A consist of n independent samples from μ, and let f be total computable. For every a ≥ 0 and η ∈ (0,1), with probability at least 1 − η over A,

    μ{ x : sep(x; A | f) ≤ a } ≤ 2^a · (a·ln 2 + ln(1/η)) / n.

*Proof.* At most 2^a decidable sets Q have K(Q | f) ≤ a. One with μ(Q) > t misses all n samples with probability less than e^(−tn). With t = (a·ln 2 + ln(1/η))/n, the probability that some such Q of measure above t misses A is at most η. Otherwise the inputs with sep(x; A | f) ≤ a lie in at most 2^a sets of measure at most t. ∎

With Proposition 4: when f is a simplest function consistent with the data, a change of machine by a bits can change the Kolmogorov prediction only at inputs with m ≤ 2a, hence with sep(x; A | f) ≤ 2a + K(f) + c. With probability 1 − η these form a set of measure at most

    2^(2a + K(f) + c) · ((2a + K(f) + c)·ln 2 + ln(1/η)) / n.

In the other direction nothing can be said for inputs of a new kind: if one simple Q separates a whole test set from A, Theorem 3 flips all of it at once.

## 4. Where the intuition is right: far alternatives and near ones

Fix a probability measure μ on X and write d(f,g) = μ{ x : f(x) ≠ g(x) }.

**Proposition 7 (Occam's razor, after Blumer, Ehrenfeucht, Haussler and Warmuth).** Let f be total and let D_n consist of n independent μ-samples labelled by f. For every δ and k,

    Pr[ some total g with K(g) ≤ k and d(f,g) ≥ δ is consistent with D_n ] ≤ 2^k · (1−δ)ⁿ.

So with probability at least 1 − η, every consistent hypothesis of complexity at most δn·log e − log(1/η) is within δ of f.

*Proof.* A fixed g at distance at least δ survives with probability at most (1−δ)ⁿ, and at most 2^k functions have complexity at most k. ∎

Compare the near alternatives. For μ uniform on {0,1}^d, 4 ≤ n ≤ 2^(d−3) and any fixed x of length d, let Q be the set of strings that begin with the first ⌈log n⌉ + 2 bits of x. It misses all n samples with probability at least ¾, and K(Q) ≤ log n + 2·log log n + c. So with probability at least ¾,

    sep(x; A) ≤ log n + 2·log log n + c,

and by the floor a patch of f that is wrong at x and consistent with the data costs at most K(f) + log n + 2·log log n + c bits. The vanilla posterior probability of a wrong label at x is then at least 2^(−K(f) − c)/(n·log² n).

So the hypotheses that dissent at x and survive the data split into two populations.

| | cheapest survivor | why |
|---|---|---|
| far from f (distance ≥ δ) | at least δn·log e − log(1/η) bits | each datum is a test that a far alternative fails with probability at least δ |
| near f (patches) | at most K(f) + log n + 2·log log n + c bits | a guard on a set of measure about 1/n is cheap and is missed by the data |

This is the precise sense in which many constraints at once pin a function down. Every datum is a constraint that *all* far alternatives must meet simultaneously, and against them the evidence compounds exponentially. SOI's remaining doubt at a typical new input comes from the second row. For the uniform measure on {0,1}^d it is at least 2^(−K(f)−c)/(n·log² n), as just shown; for any μ it is at most 2^(K(f)+c)/(n+1) in expectation (Paper 1, Remark 8.9(iv), for the papers' versions).

**Laws make alternatives far.** Call a class of total functions *δ-rigid* if any two distinct members are at distance at least δ. In a rigid class a wrong label at one input cannot come alone: any lawful function that gives it disagrees with f on a fraction δ of all inputs. Examples, each cut out by laws that relate several pairs:

* *Translations* x ↦ x + c on the natural numbers, the solutions of g(x+1) = g(x) + 1. Successor is the member with g(0) = 1. Distinct members differ everywhere: 1-rigid under every μ.
* *Additive maps* from GF(2)^d to GF(2), the solutions of g(x ⊕ x′) = g(x) ⊕ g(x′). Distinct members differ on exactly half of all inputs: ½-rigid under the uniform measure. A wrong value at x forces wrong values at half of all inputs.
* *Polynomials of degree at most k* over a field with q elements: (1 − k/q)-rigid under the uniform measure.
* *Addition* is the only solution of a + 0 = a and a + S(b) = S(a + b). Among binary operations satisfying these two laws there is no alternative at all.

By Proposition 7, with probability 1 − η every member of a δ-rigid class that contains f, is consistent with n samples and differs from f anywhere has complexity above δn·log e − log(1/η). The cheap hypotheses that keep SOI's doubt near 1/n are therefore all *unlawful*: each breaks the law somewhere, and the law has never been tested there.

## 5. Isolated functions and patch-free induction

The two populations of Section 4 suggest how to say that a function is natural in a way its patches are not.

In this section μ is a probability measure whose support is decidable, and X denotes that support, so that two functions at distance 0 are equal.

**Definition.** Fix δ ∈ (0,1]. A total computable f is *δ-isolated*, or *ultranatural at scale δ*, if K(g) > K(f) for every total computable g ≠ f with d(f,g) < δ. It is *(δ,m)-isolated* if K(g) ≥ K(f) + m for every such g. I_δ denotes the set of δ-isolated functions.

So f is isolated if it is not a near-miss of anything that is at most as complex as itself.

**Proposition 8.**

1. (*Erasure.*) f is δ-isolated if and only if, for every set B ⊆ X with μ(B) < δ, f is the unique total computable function of least complexity among those that agree with f outside B.
2. (*Separation.*) Two distinct δ-isolated functions are at distance at least δ.
3. (*Patches with costly guards are not isolated.*) Let g ≠ f be total computable, let Q_g = { x : g(x) ≠ f(x) }, and suppose μ(Q_g) < δ. If K(Q_g | f) ≥ K(f) + c, then g is not δ-isolated.
4. (*The margin is the price of a small guard.*) Let κ(δ) be the least K(Q) over nonempty decidable Q with μ(Q) < δ, and κ(δ | f) the same with K(Q | f). Every total computable f is (δ, κ(δ | f) − K(f) − c)-isolated, and no f is (δ, m)-isolated with m > κ(δ) + c.
5. (*Machines.*) If dist(V, V′) ≤ a, a function that is (δ,m)-isolated for V is (δ, m − 2a)-isolated for V′. In the other direction, let f be δ-isolated for V and let ρ exchange two labels y, y′ on a decidable set Q with μ(Q) < δ, where f takes the value y somewhere on Q. Then for V^ρ, at distance at most K(Q) + K(y) + K(y′) + c, the patch ρf is δ-isolated and f is not.

*Proof.* (1) If f is δ-isolated and g ≠ f agrees with f outside B, then d(f,g) ≤ μ(B) < δ, so K(g) > K(f). Conversely, for g ≠ f with d(f,g) < δ take B = { x : f(x) ≠ g(x) }.

(2) Of two distinct functions at distance below δ, each would have to be strictly simpler than the other.

(3) Q_g is decidable from programs for g and f, so K(Q_g | f) ≤ K(g) + c′. With the constant c of the statement equal to c′, K(g) ≥ K(f); and f is within δ of g and different from it.

(4) For g ≠ f with d(f,g) < δ, the set Q_g is nonempty and decidable with μ(Q_g) < δ and K(Q_g | f) ≤ K(g) + c, so K(g) ≥ κ(δ | f) − c. For the second claim let Q attain κ(δ) and let g equal f outside Q and, on Q, equal 1 where f is 0 and 0 elsewhere. Then g ≠ f, d(f,g) ≤ μ(Q) < δ and K(g) ≤ K(f) + K(Q) + c.

(5) The first claim: complexities move by at most a each. The second: K_{V^ρ}(ρg) = K_V(g) for all g and d(ρg, ρh) = d(g,h), so the functions isolated for V^ρ are exactly the ρ-images of those isolated for V; hence ρf is isolated for V^ρ. Also ρf ≠ f and d(f, ρf) ≤ μ(Q) < δ, and K_{V^ρ}(f) = K_V(ρf) > K_V(f) = K_{V^ρ}(ρf) since ρ is its own inverse and f is isolated for V. So f is a near-miss of the simpler ρf on V^ρ. ∎

Item 1 is the link to the original question. For an isolated function, *every* small part of its table is forced by the rest: erase it, and Occam's razor restores it. A patched function fails the test where it was patched: erase the patch, and the razor restores the unpatched values. In this sense an isolated function is held in place by constraints from all sides at once, in the way a codeword is determined by any large enough part of itself.

Items 4 and 5 say how far the notion is machine-independent.

* Under the uniform measure on {0,1}^d the singleton of the all-zero string has measure 2^(−d) and complexity K(d) + O(1). So κ(δ) is small and margins are small: a patch at a *special* input is cheap in every language.
* Let μ be the universal distribution on inputs, normalised. A nonempty decidable Q has m(Q) ≥ 2^(−K(Q) − c), because its least element has complexity at most K(Q) + c. So nonempty sets of measure below δ have complexity at least log(1/δ) − c, and every total computable f is isolated with margin at least log(1/δ) − 2K(f) − c: every function is ultranatural at scales finer than about 2^(−2K(f)).
* The notion is informative at coarser scales, where it depends on the machine, as Theorem 3 says it must.

**Patch-free induction** is induction with the prior weight 2^(−K(g)) on the δ-isolated functions g only. It is relabelling-equivariant.

**Theorem 9 (exponential pinning, everywhere).** Let f be δ-isolated and let D_n consist of n independent μ-samples labelled by f.

1. For every k, the probability that some δ-isolated g ≠ f with K(g) ≤ k is consistent with D_n is at most 2^k·(1−δ)ⁿ.
2. The expected patch-free posterior mass off f is at most 2^(K(f))·(1−δ)ⁿ. So for every η > 0, with probability at least 1 − 2^(K(f))·(1−δ)ⁿ/η the posterior gives f mass more than 1 − η, and on that event the patch-free predictive probability of a wrong label is below η at every input x ∈ X simultaneously, whatever its separation complexity.

*Proof.* (1) By Proposition 8(2) every isolated g ≠ f is at distance at least δ from f; apply Proposition 7. (2) Let R be the total weight 2^(−K(g)) of the isolated g ≠ f consistent with D_n. Its expectation is at most (1−δ)ⁿ, since the weights sum to at most 1. The posterior mass off f is R/(2^(−K(f)) + R) ≤ 2^(K(f))·R; apply Markov's inequality. ∎

Vanilla SOI, on the same data, keeps a wrong-label probability of at least 2^(−K(f) − sep(x; A | f) − c) at every input, which at a typical input under the uniform measure on {0,1}^d is at least 2^(−K(f)−c)/(n·log² n) (Section 4). Patch-free induction does to the patches what the data do to the far alternatives.

**What it costs.**

* **It cannot learn small exceptions.** Suppose the truth is a patch g† of an isolated f on a set of measure ε < δ, and g† is not isolated. Until a sample falls in the patch, which takes about 1/ε samples, the data are data from f, and patch-free induction predicts f on the patch with growing confidence and is wrong there. The first sample in the patch refutes f, at a loss of the pinning it had reached, and after that it may have no consistent hypothesis left.
* **A fallback restores universality and the floor.** The mixture π_ε = (1−ε)·patch-free + ε·W_tot has regret at most K(g) + log(1/ε) on every computable g. For isolated f and data labelled by f, its probability of a wrong label y at x is at least ε·W_tot(D + (x,y))/W_tot(D), which is ε times vanilla SOI's, and at most 2^(K(f))·R + (ε/(1−ε))·2^(K(f))·W_tot(D + (x,y)), where R is as in the proof of Theorem 9. So ε is a dial: about log(1/ε) more bits of pinning for isolated functions, log(1/ε) more bits of regret for the others. This is Theorem 5 again.
* **Its confidence is as machine-relative as SOI's prediction.** By Theorem 3, patch-free induction on a machine sep(x; A) + O(1) bits away is as confident of the opposite answer at x. When the separating set has measure below δ, Proposition 8(5) says how: that machine regards the patch as the isolated function and f as its near-miss. Isolation buys confidence. It does not buy independence from the machine.

**Is it a sensible prior?** It encodes the belief that exceptions, if there are any, are not small: that the truth is not a near-miss of something simpler. For functions fixed by definitions and proofs, such as addition, this is how we reason. For empirical laws it is often false: they have held on all the data and then failed in a new regime, which is the floor 2^(−sep(x; A)) doing its work. The universal prior is the humble one. It gives exceptions at every scale comparable total weight, and this is why its doubt decays only like 1/n.

## 6. A concrete language

The claim that addition is isolated is a claim about a machine. We checked it in one concrete language. We fixed the language before running anything; the repository cannot show this.

**The language.** Bounded primitive recursion on two inputs x, y:

    t ::= x | y | a | 0 | S(t) | P(t) | It(t, t, t) | ifz(t, t, t)

* Values are 0..31, with saturating successor S and predecessor P.
* It(n, body, init) starts from init and n times replaces the accumulator a by the value of body. n and init are evaluated in the enclosing environment, and an inner It shadows a. A closed term is run with a = 0.
* ifz(c, u, v) is u if c = 0 and v otherwise.
* There is no addition primitive: x + y is It(x, S(a), y), with 5 nodes.
* K(f) is the least number of nodes of a term computing f on the 36 inputs with x, y < 6, and μ is uniform on these inputs.
* The enumeration is exhaustive up to 11 nodes: 698,521 behaviours of open terms and 86,265 distinct functions. Every function on the 36 inputs is expressible by some larger term.

**Isolation of named functions.** R is the number of inputs, out of 36, on which the nearest other function of size at most K(f) differs from f; f is δ-isolated exactly when R ≥ 36δ. The last two columns give the least size of another function within distance 1 and within distance 6 of f.

| function | K | R | within 1 | within 6 | smallest term |
|---|---|---|---|---|---|
| successor x+1 | 2 | 30 | 7 | 4 | S(x) |
| addition x+y | 5 | 24 | 7 | 7 | It(x,S(a),y) |
| x+y+1 | 6 | 24 | 8 | 8 | S(It(x,S(a),y)) |
| monus x∸y | 5 | 10 | 7 | 7 | It(y,P(a),x) |
| product x·y | 8 | 16 | >11 | 9 | It(x,It(y,S(a),a),a) |
| max(x,y) | 8 | 6 | 10 | 6 | ifz(It(x,P(a),y),x,y) |
| addition, but 1 at (0,0) | 7 | 1 | 5 | 5 | S(P(It(x,S(a),y))) |
| addition, but y+1 where x=0 | 7 | 1 | 7 | 5 | S(It(y,S(a),P(x))) |
| addition, but x where y≤1 | 9 | 1 | 9 | 5 | It(x,S(a),It(P(y),y,a)) |
| addition, but 0 where x=0 | 8 | 5 | 10 | 5 | ifz(x,x,It(x,S(a),y)) |

* **Successor and addition are isolated at every scale up to 5/6 and 2/3.** No function of at most their size comes anywhere near them.
* **The four patches of addition that we tried are not isolated, or only at the scale of the patch.** Three have a function of at most their own size at distance 1. For the patch at (0,0) that function is addition. For the other two it is another function of the same size, and addition is at distance 6. The fourth is isolated only for δ ≤ 5/36, the size of its patch.
* **The cheapest near-misses of addition cost 2 more nodes.** Five functions of size 7 lie within distance 6 of addition. The one at distance 1 is S(P(x+y)), which changes the value at the single input (0,0); the others add 1 along the row x = 0 or the column y = 0. This is Proposition 8(4) at work: the margin of isolation is the price of the cheapest small guard, and guards on special inputs are cheap.

**How common is isolation?** Of the 86,265 functions, 12.6% are isolated at δ = 1/6, 1.5% at δ = 1/3 and 0.45% at δ = 1/2. Among the 59,866 functions of size 11 the fractions are 11.2%, 1.1% and 0.19%.

**Dissent that survives the data.** Data are n inputs drawn uniformly with replacement and labelled by f (300 trials, seed 0). For an unseen input x, a hypothesis *dissents* if it is consistent with the data and disagrees with f at x. Each cell gives:

* the fraction of (trial, unseen input) pairs at which some hypothesis of size at most K(f) + 2 dissents. This does not depend on the 11-node limit;
* in brackets, the mean posterior probability of a wrong label under the weights 8^(−K(g)), with functions above 11 nodes left out. For all hypotheses this is carried by dissenters a few nodes larger than f and is insensitive to the limit. For addition among isolated hypotheses the dissenters all have size 10 or 11, so the figure is of the order of what the limit leaves out and should be read as "about 10⁻⁶", not as an exact value.

Addition (K = 5):

| n | all hypotheses | isolated at δ = 1/6 | isolated at δ = 1/3 |
|---|---|---|---|
| 4 | 0.33 (7·10⁻²) | 0.07 (2·10⁻²) | 0.04 (2·10⁻²) |
| 8 | 0.14 (5·10⁻³) | 0 (5·10⁻⁶) | 0 (0) |
| 16 | 0.07 (2·10⁻³) | 0 (1·10⁻⁶) | 0 (0) |
| 32 | 0.03 (6·10⁻⁴) | 0 (0) | 0 (0) |
| 48 | 0.03 (5·10⁻⁴) | 0 (0) | 0 (0) |

Successor (K = 2):

| n | all hypotheses | isolated at δ = 1/6 | isolated at δ = 1/3 |
|---|---|---|---|
| 4 | 0.10 (3·10⁻³) | 0.10 (2·10⁻³) | 0.003 (5·10⁻⁵) |
| 8 | 0.04 (1·10⁻³) | 0.04 (6·10⁻⁴) | 0 (1·10⁻⁷) |
| 16 | 0.01 (4·10⁻⁴) | 0.01 (2·10⁻⁴) | 0 (0) |
| 32 | 0.003 (9·10⁻⁵) | 0.003 (4·10⁻⁵) | 0 (0) |
| 48 | 0 (6·10⁻⁶) | 0 (0) | 0 (0) |

Among all hypotheses, cheap dissent decays slowly and persists: these are patches at the inputs the sample happened to miss. Among hypotheses isolated at δ = 1/3 it is gone by n = 8. For addition it is also gone by n = 8 at δ = 1/6. For successor at δ = 1/6 it persists: successor has a near-miss of size 4 at distance 6, S(S(P(x))), which is x + 1 except that it is 2 at x = 0, and which is itself isolated at exactly that scale.

The fraction of unseen inputs at which *some* enumerated hypothesis of any size up to the limit dissents is also in the output, but it depends on the limit, and without a limit it is 1 for all hypotheses, since every function is expressible. For addition at n = 16 it is 0.20, 0.28 and 0.38 at limits of 9, 10 and 11 nodes for all hypotheses, against 0, 0.03 and 0.04 for those isolated at δ = 1/6, and 0 at every limit for δ = 1/3. Over eight seeds the last pair at 11 nodes is 0.377 ± 0.010 against 0.036 ± 0.005 (the referee's `verification/extra_checks.out`). The full output, with monus, max and product, is in [`results/analyze_pr11.out`](results/analyze_pr11.out).

**What this does and does not show.** It shows that the definition is not vacuous in a natural small language: successor, addition and product are isolated at large scales, the patches of addition we tried are not, and patch-free induction removes cheap dissent that vanilla induction keeps. It does not show that addition is isolated on any standard universal machine. The language was chosen by us, the domain has 36 inputs, and terms have at most 11 nodes. In a language with a cheap test for one particular input the patch at that input would be cheap, as Theorem 3 requires.

## 7. Open questions

1. **Stability beyond half the margin.** Theorem 3 bounds every equivariant scheme by sep(x; A) + c, and the Kolmogorov version is stable only to half its margin (Proposition 4). Is some equivariant scheme, for instance a mixture, stable beyond sep(x; A)/2?
2. **Standard machines.** Is addition δ-isolated for binary lambda calculus or a small universal Turing machine, on inputs of moderate length, for δ well above the measure of its special inputs? The experiment suggests looking at the cheapest near-misses and at which inputs they change.
3. **A scale that shrinks with the data.** With δ_n → 0 and δ_n·n → ∞, the error bound 2^(K(f))·(1−δ_n)ⁿ of Theorem 9 tends to 0 for every target that is isolated at some scale; it is super-polynomially small when δ_n·n/log n → ∞. Is there a natural schedule, and what is its regret on patched targets? A prior over δ gives a universal learner again, with the headroom of Theorem 5.
4. **Noise.** With noisy labels a wrong label at one input is a different kind of event. The redundancy that relational laws provide, in the form of many independent derivations of f(x) from other values as in self-correction for linear functions, should then matter quantitatively. What is the analogue of isolation for hypotheses with private randomness at each query?
5. **Sums against maxima.** Theorem 1 is about the simplest broken property. Is the total weight v(y) of Proposition 2 within a constant factor of 2^(−excl(x,y)), or can many broken properties of equal complexity add up, as they do for function programs in Paper 1 (Section 4)?
6. **Decidable against c.e. separation** (Remark 1.1).
7. **Non-equivariant schemes.** Theorem 3 leaves room only for schemes with a bias that does not come from the machine. Is there a principled one, for instance a restriction to laws in a fixed logical form that has no guards?

## 8. Related work

* **Goodman's new riddle of induction** (*Fact, Fiction, and Forecast*, 1955). Theorem 3 is the riddle for arbitrary equivariant schemes, with the cost of the grue-like machine measured by sep(x; A).
* **Machine dependence of universal priors.** Leike and Hutter, *Bad universal priors and notions of optimality* (2015), for AIXI; Paper 1, Proposition 8.2, for SOI.
* **Out-of-distribution behaviour of SOI.** Paper 1, Section 8: the floor from unseen simple properties, the novelty budget, and upper bounds given the labelled sample. Hänni's working notes there already contain the floor and the observation about tailored machines.
* **Occam's razor in PAC learning.** Blumer, Ehrenfeucht, Haussler and Warmuth, *Occam's razor* (1987): Proposition 7.
* **Self-testing and self-correcting.** Blum, Luby and Rubinfeld, *Self-testing/correcting with applications to numerical problems* (1990): functions characterised by robust local laws, the rigid classes of Section 4.
* **Algorithmic statistics.** A patch is a "model plus exceptions" description of a function. Isolation asks that a function have no description of that form over a simpler model. Paper 2 studies related splits of data into model and randomness.
* **Steeper priors.** Paper 2 (*Steeper Simplicity Priors in Solomonoff Operator Induction*): a lower floor, at a slope λ in regret.
