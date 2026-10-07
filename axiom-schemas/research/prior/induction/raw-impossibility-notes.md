# Track B: raw induction instances and first-order patterns. Impossibility results and what to do instead

Scope. The data are raw sentences of first-order arithmetic (language 0, S, +, *, =; connectives and quantifiers) of the form

    Ind(phi) := phi(0) & Ax (phi(x) -> phi(Sx)) -> Ax phi(x),

as used by a community, with no mistakes (noise in B8). Classical first-order logic is trusted. The question is what the report's
learner does with these data: Plotkin lgg over first-order schemas, the cautious verifier, and the TTL audit with world feedback.
All scripts are in this directory and use the paper's lgg implementation (`research/theory/T1-code/terms.py`).

Status labels: **proved** (full proof here), **computed** (script run; output file named), **known** (literature), **conjecture**.

---------------------------------------------------------------------------------------------------------------------------

## 0. Answers in brief

1. **Two instances suffice; one never does** (B1). Every first-order schema with Ind(x+0=x) and Ind(0+x=x) as instances also has
   the false instance (0+0=0) & Ax(0+0=x -> 0+S0=Sx) -> Ax(0+0=x). This is the paper's false instance, which the paper got from
   four instances. Two instances also suffice in the pairs {Ind(x=x), Ind(0=x)} (motive size 3+3, the minimum),
   {Ind(x=x), Ind(0+x=x)} (3+5, the minimum when both motives are true for all x), and any pair whose motives have different
   main symbols with x free in at least one. Not every pair suffices: {Ind(x=x), Ind(Sx=Sx)} has a sound lgg.
2. **No finite union of first-order schemas covers the raw induction instances soundly** (B2). The proof uses an infinite family
   F' = {Ind(g_n(x) = x)}, where g_n(x) = 0+(0+...+(0+x)) with n additions. Any first-order schema that covers two members of F'
   has a false instance, and Q refutes that instance. So a sound schema covers at most one member of F', a sound union of k
   schemas covers at most k, and no finite union of schema instance sets equals the set of raw induction instances. This already
   holds for atomic motives, so it holds for open induction too.
3. **Consequences for the cautious verifier and for TTL** (B3–B5).
   - After two root-diverse data the H_1 cautious verifier accepts inst(L_inf), with L_inf = A & Ax(B -> C) -> Ax B. That
     includes (0=0) & Ax(0=S0 -> 0=S0) -> Ax(0=S0).
   - Over untagged H_k, k+1 members of F' put a false sentence into the intersection of VS(D). No sound member of H_k is
     consistent with such data.
   - With Delta_0 world feedback and trusted first-order logic, each over-general schema is refuted by an 8- to 11-judgment
     natural-deduction refutation. Its descent is unblocked, so blame is singleton. TTL then removes the schema and ends with no
     induction schema at all. The refutations and descents are machine-checked, with sizes in B5.
4. **Relation to non-finite axiomatizability** (B7). The two facts are logically independent and are proved by unrelated methods.
   Ryll-Nardzewski's theorem is about deductive consequence and uses nonstandard models. B2 is about the syntax of substitution and
   uses only a few true closed equations. In fact PA *is* axiomatized by Q plus one sound first-order pattern, the
   substitution-free (Tarski-style) form of induction IndEq(P) (B6). So the obstruction is the meta-level substitution in phi(0)
   and phi(Sx), not induction or arithmetic.

---------------------------------------------------------------------------------------------------------------------------

## 1. Setting and conventions

* **Encoding.** Formulas are ground terms over the signature Omega = {0, S, add, mul, eq, not, and, or, imp, all, ex, x, y, ...}.
  Object variables are constants of Omega, and `all(x, body)` is a binary symbol whose first argument is the bound variable. This
  is the encoding of `ind_lgg.py` and the paper. A *first-order schema* is a term over Omega with metavariables
  (def:setting:schema); inst(tau) is its set of ground instances. tau >= sigma means sigma = tau theta.
* **Plotkin–Reynolds lgg** (thm:setting:lgg; Plotkin 1970, Reynolds 1970; Huet's 1976 thesis gives the same algorithm, I
  believe). Its key property here: **every schema tau with P ⊆ inst(tau) satisfies tau >= lgg(P), hence
  inst(lgg(P)) ⊆ inst(tau).** So "every schema covering P has a false instance" is equivalent to "lgg(P) has a false
  instance".
* **Soundness of a schema.** tau is *sound* if every instance of tau that is a sentence is true in N. Ill-sorted or open
  instances are ignored, which is the weakest requirement.
  - Every false instance exhibited below is a closed, well-sorted sentence obtained by substituting closed terms (or 0*x
    padding, B2 remark), with no variable capture.
  - So the impossibility results hold verbatim under each of these choices: universal-closure semantics for open instances;
    sorted or unsorted metavariables; named variables or de Bruijn indices; fixed or varying bound-variable names (varying names
    only make the lgg more general); parameter-free instances or instances with parameters (F' is parameter-free and is
    contained in both sets).
* **Raw induction set.** Ind := {Ind(phi) : phi a formula with FV(phi) ⊆ {x}}. Every member is true in N.
* **Exact truth evaluation (computed parts).** `raw_common.truth` decides sentences in which each quantifier body is
  quantifier-free with one free variable. Each atom s=t becomes p(x)=0 for an integer polynomial p. A nonzero p has all its
  natural roots below the Cauchy bound, so beyond that point every atom, and hence the body, is constant. Checking x = 0..bound+1
  therefore decides "Ax body" exactly. Every "true"/"false" verdict below that comes from a script is exact, not
  bounded-domain. The one exception is the bounded sanity check in B6, which is labelled.

---------------------------------------------------------------------------------------------------------------------------

## 2. The learning algorithm

**Analyzed (the report's algorithm, applied to raw data).** For the induction tag, compute tau = lgg(D_Ind). The cautious verifier
accepts inst(tau) (class H_1), or the intersection of VS_{H_k}(D) for untagged unions. TTL then audits with W = Delta_0 truth,
trusted classical first-order logic with equality, the prefer-unblocked refutation oracle, and descent.

**Proposed for raw data ("lgg, audit, escalate").**
1. tau := lgg(D_tag).
2. Search refutations of {tau} of size <= d.
   - On raw induction data, one of two refutations is always available and has an unblocked descent: the refutation of
     I*_a (n=0: size 82; n>=1: 139+44(a-1), contexts counted), or the refutation of the L_inf instance
     (0=0)&Ax(0=S0->0=S0)->Ax(0=S0) (size 78).
3. On an unblocked refutation with clean data:
   - withhold tau (singleton blame, no collateral);
   - record the certificate "no sound first-order schema covers D_tag" (B4(c)).
4. Escalate the representation for that tag. Two options:
   - the report's Sub-encoding;
   - the substitution-free form IndEq(P) (B6). Here each raw datum Ind(phi) is rewritten as IndEq(phi). Recovering phi is a
     decidable second-order match: read phi off the conclusion Ax phi, then check A = phi[0/x] and C = phi[Sx/x].

   On IndEq data plain lgg is sound at all times and exact after two root-diverse instances. Without escalation, the
   first-order learner provably cannot learn raw induction (B2, B5).

---------------------------------------------------------------------------------------------------------------------------

## 3. Propositions

### B1. Two raw instances force an unsound first-order schema; one never does. (proved; computed)

**Statement.**
(a) For a single raw instance I, the ground schema I covers {I} and is sound. So no 1-element set forces unsoundness.

(b) Let D2 = {Ind(x+0=x), Ind(0+x=x)}. Then, up to renaming,

    lgg(D2) = (0+0=0) & Ax(z1+z2 = x -> z3+z4 = Sx) -> Ax(z1+z2 = x),

with four distinct metavariables. It has the false instance

    I*_1 := (0+0=0) & Ax(0+0=x -> 0+S0=Sx) -> Ax(0+0=x)      (z1=z2=z3 := 0, z4 := S0).

So **every first-order schema covering D2 has I*_1 as an instance**, and the minimum cardinality is 2.

(c) Other 2-element sets that work:
- {Ind(0+x=x), Ind(0+(0+x)=x)}. Its lgg is (0+z''=0) & Ax(0+z=x -> 0+z'=Sx) -> Ax(0+z=x), which also has I*_1 as an instance.
- {Ind(x=x), Ind(0=x)}. Its lgg is (0=0) & Ax(z=x -> z'=Sx) -> Ax(z=x), with false instance
  I*_0 := (0=0) & Ax(0=x -> S0=Sx) -> Ax(0=x).
- {Ind(x=x), Ind(~(x=Sx))}, or any pair whose motives have different main symbols with x free in at least one (B3). Its lgg is
  L_inf.

(d) Not every pair works. lgg(Ind(x=x), Ind(Sx=Sx)) = (t=t) & Ax(u=u -> Su=Su) -> Ax(u=u) is sound.

(e) Minimal sizes (computed):
- the smallest unsound pairs have motive sizes 3+3 (e.g. {0=x, x=0}, {x=x, 0=x});
- if both motives must be true for all x (non-vacuous inductions), the minimum is 3+5 (e.g. {x=x, 0+x=x}, {x=x, 0=0*x}).

**Proof.**
(a) inst(I) = {I}, and I is true.

(b) Write Ind(phi) = imp(and(phi[0/x], all(x, imp(phi, phi[Sx/x]))), all(x, phi)) and anti-unify columnwise.
- Frame. Both data share the symbols imp, and, all(x, .), imp, all(x, .).
- A-slot. The column is (0+0=0, 0+0=0), two identical terms, so the lgg keeps 0+0=0.
- B-slot. The column is (x+0=x, 0+x=x). Descending through eq and add gives add(z_(x,0), z_(0,x)) = x.
- C-slot. The column is (Sx+0=Sx, 0+Sx=Sx), giving add(z_(Sx,0), z_(0,Sx)) = Sx.
- D-slot. Its column is the B-slot column, so it gets the same metavariables.
- The four index tuples are distinct, so the metavariables are distinct. This gives the displayed lgg.

Truth of I*_1 in N:
- 0+0=0 holds.
- For each x, 0+0=x forces x=0, and then 0+S0 = 1 = Sx. So Ax(0+0=x -> 0+S0=Sx) holds.
- Ax(0+0=x) fails at x=1.

So I*_1 is false. Every tau covering D2 satisfies tau >= lgg(D2), hence I*_1 ∈ inst(lgg(D2)) ⊆ inst(tau).

(c) The same column computation applies.
- For {x=x, 0=x}: the A column is identical (0=0). B gives z_(x,0) = x, C gives z_(Sx,0) = Sx.
- I*_0 is false: 0=x forces x=0, then S0=S0; but Ax(0=x) fails.
- For {Ind(0+x=x), Ind(0+(0+x)=x)}: this is B2 with n=1, m=2.

(d) Every well-sorted instance substitutes terms t, u for the two metavariables. A sentence instance therefore has the true
conclusion Ax(u=u).

(e) is computed.

The paper's claim needs four instances; two suffice. The lgg of the paper's four instances is strictly more general than lgg(D2)
(`b1_pairs.out`: "lgg(4) >= lgg(2): True; converse False").

**Evidence.**
- `b1_pairs.py` → `b1_pairs.out`: all lggs above, exact falsity of each false instance, and checks that each datum is a true
  instance.
- `b1b_bruteforce.py 5 2000` → `b1b_bruteforce.out`. All 2556 unordered pairs of quantifier-free motives of size <= 5 (72
  motives, 58 with x free):

  | pair class | unsound (exact false instance found) | no false instance found |
  |---|---|---|
  | x free in both | 1589 (96.1%) | 64 |
  | x free in one | 768 | 44 |
  | x free in neither | 0 | 91 |

  The 91 pairs with x free in neither are provably sound: the lgg is beta & Ax(beta -> beta) -> Ax beta with beta closed in
  every sentence instance. "No false instance found" is a finite-pool search failure, not a soundness proof. The
  hand-checkable examples are coupled pairs (x=x, Sx=Sx), pairs with false A-slot (0=Sx, x=Sx), and "parametric" pairs
  (0=x, S0=x). The last have lgg Ind(t=x) for closed t, which is sound.
- Minimum total size of an unsound pair: 6, the least possible since every formula has size >= 3. With both motives true for
  all x: 8. This minimum is exact, not just the best found:
  - the motives of size 3 that are true for all x are only 0=0 and x=x, and {Ind(0=0), Ind(x=x)} has the sound lgg
    0=0 & Ax(z=z -> z'=z') -> Ax(z=z);
  - no motive of size 4 is true for all x;
  - so totals 6 and 7 are impossible for true motives.

### B2. A pairwise-unsound infinite family; no finite union of first-order schemas is sound and covers Ind. (proved; computed)

Let g_0(t) = t and g_{n+1}(t) = 0 + g_n(t). Let

    phi_n := (g_n(x) = x),     F' := {Ind(phi_n) : n >= 0}   (true motives; Ind(phi_1) = Ind(0+x=x)).

For each n, define

    L_n  := (g_n(a) = 0) & Ax(g_n(b) = x -> g_n(c) = Sx) -> Ax(g_n(b) = x)        (metavariables a, b, c)
    I*_n := (g_n(0) = 0) & Ax(g_n(0) = x -> g_n(S0) = Sx) -> Ax(g_n(0) = x).

**Lemma B2.1.** For n < m, lgg(Ind phi_n, Ind phi_m) = L_n up to renaming. More generally, the lgg of any subset of F' with at
least two members, minimum index n, is L_n.

**Lemma B2.2.** Each I*_M is false in N, and I*_M ∈ inst(L_a) for every a <= M. Moreover Q ⊢ ¬I*_M; indeed the true
closed equations g_M(0)=0 and g_M(S0)=S(g_M(0)) and the true inequation ¬(g_M(0)=S0) suffice, by first-order logic.

**Theorem B2.**
(a) Every first-order schema that covers two members of F' has a false sentence instance, refutable in Q. So every sound
first-order schema covers at most one member of F'.

(b) Every union of k first-order schemas whose instances are all true covers at most k members of F'. Hence no finite union of
first-order schemas covers Ind, or even F', soundly.

(c) No finite union of first-order schema instance sets equals Ind. Nor does any such union lie between F' and Th(N), or
between F' and any consistent theory extending Q.

(d) The same holds for the second family F = {Ind(S^n0 + x = S^n x)}. There, for n < m,

    lgg = K_n = (S^n z1 + 0 = S^n z1) & Ax(S^n z1 + x = S^n z2 -> S^n z1 + Sx = S^{n+1} z2) -> Ax(S^n z1 + x = S^n z2),

with the false instance J*_n given by z1 = z2 := 0. Note that K_n reads like the recursion equations of + with the parameter
function z2 forgotten. Every member of F is a genuine use of induction (n + x = S^n x).

**Proof of B2.1.** Let n < m and d = m - n >= 1. Then g_m(t) = g_n(g_d(t)) as terms. Anti-unify the frame columnwise.
- B-slot. Both left sides begin with n copies of `0 + .`, so the lgg descends n times and meets the column (x, g_d(x)). The roots
  are x (a constant) and add, so the result is the metavariable b := z_(x, g_d(x)). The right sides are x and x. This gives
  g_n(b) = x.
- A-slot. The columns are (g_n(0), g_n(g_d(0))) and (0, 0). The first meets (0, g_d(0)), with roots 0 and add, giving
  a := z_(0, g_d(0)). This gives g_n(a) = 0.
- C-slot. The column is (g_n(Sx), g_n(g_d(Sx))). It meets (Sx, g_d(Sx)), with roots S and add, giving c := z_(Sx, g_d(Sx)). The
  right sides are Sx and Sx. This gives g_n(c) = Sx.
- D-slot. Same column as B, so the same metavariable.

The tuples indexing a, b, c are pairwise distinct (first entries 0, x, Sx). So lgg = L_n.

For a subset {n_1 < n_2 < ...} the same descent stops at the columns (x, g_{d_2}(x), ...) and so on. These have mixed roots
because the first entry is a constant and the others have root add. So the result is again L_{n_1}.

**Proof of B2.2.**

*Falsity of I*_M.* g_M(0) denotes 0 and g_M(S0) denotes 1.
- The A-slot g_M(0)=0 is true.
- For each x, g_M(0)=x forces x=0, and then g_M(S0) = 1 = Sx. So the step clause is true.
- Ax(g_M(0)=x) fails at x=1.

*Instance.* Substitute into L_a: a, b := g_{M-a}(0) and c := g_{M-a}(S0). Since g_a(g_{M-a}(t)) = g_M(t) as terms, the result is
I*_M.

*Q-refutation.* From g_M(S0) = S(g_M(0)), assume g_M(0)=x. Congruence gives S(g_M(0)) = Sx, and transitivity gives
g_M(S0) = Sx. Then ->I and AI give the step clause. With g_M(0)=0, ->E gives Ax(g_M(0)=x), and AE gives g_M(0)=S0,
contradicting ¬(g_M(0)=S0). Q proves the three closed (in)equations because it decides closed atomic sentences; this is the
standard Sigma_1-completeness of Q.

**Proof of Theorem B2.**
(a) If tau covers Ind phi_n and Ind phi_m with n < m, then tau >= lgg(Ind phi_n, Ind phi_m) = L_n by B2.1. So I*_n ∈ inst(tau),
and it is false and Q-refutable by B2.2.

(b) Pigeonhole: k sound schemas covering k+1 members of F' put two members into one schema, contradicting (a). F' is infinite
(the phi_n are pairwise distinct), so it is not covered by any finite union.

(c) If the union of the inst(tau_l) equaled Ind, every tau_l would have only true instances and the union would cover F',
contradicting (b). The same argument works for any set S with F' ⊆ S ⊆ Th(N), or with F' ⊆ S ⊆ {sentences consistent with Q}:
use the Q-refutability in (a).

(d) The column computation is the same, with descents through S^n.
- z1 = z_(0, S^d 0) in all of the A, B, C slots.
- z2 = z_(x, S^d x) in B. In C, the column (S^{n+1}x, S^{m+1}x) descends n+1 times to (x, S^d x), giving S^{n+1} z2.
- J*_n = (n+0=n) & Ax(n+x=n -> n+Sx=n+1) -> Ax(n+x=n) is false: n+x=n forces x=0, after which the step holds; the conclusion
  fails at x=1.

**Remark (guards; computed).** Data from F' always instantiate b and c by terms containing x, and a by closed terms. So the
strongest occurrence and freshness guards learnable from F' (in the sense of lem:setting:guard) are x ∈ FV(b), x ∈ FV(c), and
"a closed". They do not rescue L_n. Padding gives a false guarded instance: a := 0, b := 0*x, c := S0 + 0*x, which has the same
truth values as I*_n (`b2b_guards.py`, n = 0..5). For an arbitrary guard family Phi the statement can fail trivially, e.g. if Phi
contains "is an induction instance". That decidable guard is exactly what the report's Sub premises implement.

**Evidence.** `b2_family.py` → `b2_family.out`:
- for all 0 <= n < m <= 10, lgg = L_n (and K_n for F), and I*_n (J*_n) is an exactly-false instance;
- I*_M ∈ inst(L_a) for all a <= M <= 10;
- the lgg of each of the 247 subsets of {0..7} with >= 2 members equals L_min.

`b2b_guards.py`: the guard remark.

### B3. Collapse to the bare frame, at a coupon-collector rate. (proved)

Let L_inf := A & Ax(B -> C) -> Ax B, with three distinct metavariables.

(a) If D ⊆ Ind contains two motives with different main symbols, and some motive in D has x free, then lgg(D) = L_inf. In
particular lgg(Ind) = L_inf; the lgg of an infinite set exists by app:setting:infinite. L_inf has the false instance

    (0=0) & Ax(0=S0 -> 0=S0) -> Ax(0=S0).

(b) Let the data be i.i.d. motives phi ~ mu. Let p_max = max_f mu(root(phi) = f) and q = mu(x ∈ FV(phi)). Then

    P[lgg(D_N) != L_inf] <= p_max^(N-1) + (1-q)^N.

So the H_1 cautious verifier on raw induction data becomes unsound at the same kind of rate at which it becomes exact on a
realizable rule (thm:imitation:coupon). There, mixed roots identify the rule; here they destroy it.

**Proof.**
(a) Substituting a term for x never changes the root of a formula, so the A, B and C columns all have the same mixed roots.
Each is therefore a metavariable indexed by its column. If phi_j has x free, then phi_j[0/x], phi_j and phi_j[Sx/x] are pairwise
distinct, so the three columns are distinct and the metavariables are distinct. The D column equals the B column.

For lgg(Ind): L_inf covers Ind, so L_inf >= lgg(Ind). Conversely, lgg(Ind) covers the pair Ind(x=x), Ind(~x=Sx), so
lgg(Ind) >= lgg(pair) = L_inf.

The displayed instance is false: its premise is true, and Ax(0=S0) is false.

(b) The lgg can differ from L_inf only on one of two events: E1, all N roots are equal, which has probability
sum_f p_f^N <= p_max^(N-1); or E2, no sampled motive has x free, which has probability (1-q)^N.

On E2 without E1 the three columns coincide and the lgg is Z & Ax(Z -> Z) -> Ax Z. This is sound under sentence semantics, because Z must be closed.
It is unsound under universal-closure semantics: Z := (x=0) gives a false closure.

### B4. The cautious verifier: unsound, with an empty sound version space and a certificate. (proved; computed)

(a) **H_1 (per tag).** If D_Ind contains two members of F', or a root-diverse pair with x free, the cautious verifier
inst(lgg(D_Ind)) accepts a false sentence (I*_a or the L_inf instance). Lemma imitation:cautious(a) fails because realizability
fails, and fails in the strong sense that no sound member of H_1 contains D_Ind (B2(a)).

(b) **H_k (untagged unions).** If |D ∩ F'| >= k+1 and M is the largest index in D ∩ F', then:
- every h ∈ VS_{H_k}(D) contains the false I*_M;
- in particular I*_M ∈ ∩VS_{H_k}(D);
- no sound member of H_k is consistent with D.

*Proof.* Write h as a union of inst(tau_l) over l <= k. It covers k+1 members of F', so some tau_l covers two of them, with
indices a < b <= M. Then tau_l >= L_a, and I*_M ∈ inst(L_a) by B2.2.

*Computed* (`b2_family.out`): for D = {Ind phi_0..Ind phi_N}, N+1 <= 7, and all k <= N, a brute force over all set partitions into
<= k blocks finds I*_N in every minimal member of VS. (The minimal members are unions of block lggs.) As a control, with k = N+1
the all-singletons hypothesis excludes I*_N.

(c) **Certificate of unrealizability.** If the data are clean (D ⊆ Ind) and lgg(D) has a refutation, then no sound first-order
schema covers D. This is immediate from tau >= lgg(D). So the audit's refutation does more than remove a schema: it proves that
the tag's rule is not a first-order pattern. That is the trigger for step 4 of the proposed algorithm.

With noisy data the same refutation is ambiguous between "noise" and "unrealizable". The noise-robust certificate: suppose at
most e data are noisy and lgg(D') is refuted for *every* D' obtained by deleting at most e data. Then no sound first-order
schema covers the clean data, because the clean data are one such D'. If the clean data contain at least e+2 members of F', this
condition holds (B8).

### B5. World feedback: singleton blame, and TTL ends with no induction. (proved using lem:twotier:descent; computed)

Setting. W is the truth of closed quantifier-free (Delta_0) sentences. The trusted steps are natural deduction for classical
first-order logic with equality: assume, refl, congruence for S, symmetry, transitivity, ->I, AI, &I, ->E, AE. The designated
position is the empty position. (WS) holds with V the truth in N of the universal closure of each sequent, because the trusted
steps preserve it.

**(a) The refutation of I*_n.** It is valid for every schema tau with I*_n ∈ inst(tau). Write a := g_n(0) and b := g_n(S0).

     1  |- I*_n                                   [tau]
     2  |- a = 0                                  [leaf, W=1]
     3  |- b = S(a)                               [leaf, W=1]   (omitted for n=0, where b = S(a) syntactically)
     4  a=x |- a = x                              [assume]
     5  a=x |- S(a) = Sx                          [congS 4]
     6  a=x |- b = Sx                             [trans 3,5]   (omitted for n=0)
     7  |- a=x -> b=Sx                            [->I]
     8  |- Ax(a=x -> b=Sx)                        [AI; x not free in the context]
     9  |- a=0 & Ax(a=x -> b=Sx)                  [&I 2,8]
    10  |- Ax(a = x)                              [->E 1,9]
    11  |- a = S0                                 [AE 10, t := S0; W=0]

Propagation.
- Forward: 4, 5, 6, 7, 8, 9 get value 1 (trusted steps, from the true leaves).
- Backward: 11 = 0, so AE gives 10 = 0. Then ->E with 9 = 1 gives 1 = 0.

The descent visits 11 → 10 → 1 and outputs the tau-step, so it is unblocked. By lem:twotier:descent(c),(d), every schema having
I*_n as an instance is a fallacy and {tau} is a singleton conflict; no genuine schema is touched.

Sizes, counted as symbols of distinct judgments with contexts included: 82 for n=0; 139, 183, 227, 271, 315 for n=1..5 (that is,
139 + 44(n-1)). In the compressed Hilbert format, where 3 → 8 is a single trusted first-order step, the sizes are 64 + 28n.

For n = 1 the refuted instance is the paper's (0+0=0) & Ax(0+0=x -> 0+S0=Sx) -> Ax(0+0=x). The machine-checked derivation agrees
with the paper's informal description in app:twotier:arith(e).

**(b) The refutation of L_inf.** Use the instance (0=0) & Ax(0=S0 -> 0=S0) -> Ax(0=S0) with 8 judgments: refl, assume, ->I, AI,
&I, ->E, AE. The descent is unblocked and the size is 78.

**(c) Consequence for TTL.** Use the per-tag practice estimate, the prefer-unblocked oracle, and depth d >= s_a, where s_a = 82
for a = 0 and s_a = 139 + 44(a-1) for a >= 1 (d >= 78 if D_Ind is root-diverse). Here a is the smallest F' index in D_Ind. Then:
- The audit removes the induction tag's schema lgg(D_Ind), which is L_a or L_inf, with singleton blame and no collateral.
- The asserted calculus then contains no schema covering two members of F'. Every such schema has I*_M (M >= its indices) as an
  instance, which is refutable at depth s_M.
- If the rest of the practice is Q, the final calculus is Q. Q ⊬ Ax(0+x=x); this is standard (known). So the learner is sound
  but has lost induction, and the loss is forced by the hypothesis class, not by the data.
- The learner discovers unrealizability. It does not discover induction.

**(d) Family F needs more than Delta_0 plus logic (computed).** The natural refutation of K_0 through J*_0 must use the recursion
axiom Q3 = AxAy(x+Sy = S(x+y)) to derive Ax(0+x=0 -> 0+Sx=S0).
- Relative to the empty position, Q3's value is undefined, so the descent is blocked at ->E and only the bag {K_0, Q3} is
  condemned. That means collateral.
- If the position asserting Q3 is designated, which is legitimate because N ⊨ Q, the descent is unblocked and the blame is
  singleton.

F' was chosen so that its refutations need only closed equations. (I do not claim that {K_0} has no singleton refutation at all.)

**Evidence.** `b3_refutation.py` → `b3_refutation.out`. The script contains a rule checker for every step, the forward/backward
propagation, the descent, and the sizes.

### B6. The substitution-free form makes induction a one-metavariable first-order pattern. (proved; computed)

    IndEq(P) := Ax(x = 0 -> P) & Ay(Ax(x = y -> P) -> Ax(x = Sy -> P)) -> Ax P,

with P a formula metavariable and x, y fixed distinct variables. This is Tarski's device of expressing phi(t) as Ax(x=t -> phi)
without a substitution operation (Tarski 1965; Monk 1965; Kalish–Montague 1965).

**(a)** For every phi with FV(phi) ⊆ {x}, FOL ⊢ IndEq(phi) <-> Ind(phi) (up to renaming the bound variable of the step clause).
So every sentence instance of IndEq(P) is a theorem of PA, and the pattern is sound.
- Under universal-closure semantics, the guard "y ∉ FV(P)" (a freshness guard, as in Phi) is needed. Without it,
  psi = (x=0 ∨ ¬x=y) gives a false closure: computed; by hand, at y=1 the premises hold and Ax psi fails at x=1.

**(b)** For data IndEq(psi_1), ..., IndEq(psi_N), lgg = IndEq(lgg(psi_1..psi_N)).
- This is always an instance of IndEq(P). So the cautious verifier is sound at all times and the class is realizable.
- It equals IndEq(P) iff the psi_j do not all have the same root: witness event (R); (D) is vacuous.
- So two root-diverse instances form an anchor, and P[not exact after N] <= p_max^(N-1).

**(c)** Q + inst(IndEq) ⊢ PA. So PA is axiomatized by 7 ground axioms and one sound first-order pattern.

**Proof.**
(a) In FOL with equality, Ax(x = t -> phi) <-> phi[t/x] (capture-avoiding) when x ∉ FV(t). Apply this with t = 0, y, Sy. Since
FV(phi) ⊆ {x}, y is not free in phi, so the step clause becomes Ay(phi[y/x] -> phi[Sy/x]), an alpha-variant of
Ax(phi -> phi[Sx/x]). A sentence instance IndEq(psi) forces FV(psi) ⊆ {x}, because the first conjunct leaves any other free
variable free. So psi is such a phi.

(b) The four occurrences of P sit at positions where each datum carries the same psi_j. Elsewhere all data agree. So the lgg is
IndEq applied to the anti-unification of the psi-column, computed once; equal columns give equal results (column indexing).

(c) By (a), the instances give every parameter-free induction instance. Parameter-free induction for all formulas yields
induction with parameters. Given phi(x, p), apply parameter-free induction to

    psi(x) := Ap[phi(0,p) & Az(phi(z,p) -> phi(Sz,p)) -> phi(x,p)].

Then psi(0) is trivial, and psi(x) -> psi(Sx) uses the step clause. From Ax psi(x), induction for phi follows for every p.
(This is the standard trick; it raises quantifier complexity, which is why parameter-free IΣ_n^- is weaker than IΣ_n,
Kaye–Paris–Dimitracopoulos 1988.) Hence Q + inst(IndEq) ⊢ PA. Conversely, PA proves every instance.

**Caveat.** To use (b) on raw data the learner must rewrite Ind(phi) as IndEq(phi). Recovering phi is the second-order matching
of P(0) & Ax(P(x) -> P(Sx)) -> Ax P(x), which is decidable and trivial for this pattern (read phi off the conclusion). That is
precisely the step first-order anti-unification cannot take. The obstruction of B2 is the meta-level substitution, not induction.

**Evidence.** `b4_equational.py` → `b4_equational.out`:
- every pair of the sample has an lgg that is an instance of IndEq(P), and root-diverse pairs recover it exactly;
- an F' pair in equational form has the sound lgg IndEq(0+z = x);
- bounded-domain sanity check (B = 25): IndEq(phi) and Ind(phi) agree on 400 random quantifier-free phi;
- the capture counterexample: IndEq(x=0 ∨ ¬x=y) is false at y = 1..5.

### B7. Relation to non-finite axiomatizability. (known; proved separations)

**Known.**
- Ryll-Nardzewski (1952, Fund. Math. 39:239–263): no finitely many sentences in the language of arithmetic prove all instances
  of the induction schema, i.e. PA is not finitely axiomatizable. The proof uses nonstandard models.
- Stronger and standard: PA proves the consistency of each of its finite subtheories (reflexivity: Mostowski 1952;
  Kreisel–Lévy 1968, I believe). Hence no consistent extension of PA in the same language is finitely axiomatizable.
- Parsons' work (1970; "On n-quantifier induction", JSL 1972) concerns the fine structure IΣ_n / PRA, not non-finite
  axiomatizability as such. I am not sure which "Parsons-style result" was meant.

**Proved here: neither fact implies the other.**
(i) Non-finite axiomatizability does not obstruct first-order pattern axiomatizability. By B6(c), PA = Q + inst(IndEq) with
one sound first-order pattern.

(ii) B2 is insensitive to deductive strength. Its proof uses only the truth of a few closed equations (Q-refutability,
B2.2). So it holds verbatim for the raw arithmetic induction instances in any setting where the I*_n are false, including
settings where the theory proving all of Ind is finitely axiomatizable. For example ACA_0 is finitely axiomatizable and proves
every instance of arithmetic induction (known; Simpson, *Subsystems of Second Order Arithmetic*, ch. VIII, I believe).

**What connects them.** Only the slogan "induction needs infinitely much first-order structure", and along different axes:
- Ryll-Nardzewski is about consequence. It needs nonstandard models or Gödel II.
- B2 is about the syntactic form of the instances, a fact about the pattern language. It needs only Delta_0 facts, and it
  disappears under a FOL-equivalent change of form (B6).

Vaught (1967, JSL 32:473–479) studied axiomatizability "by a schema" in the sense of a formula with a schematic relation symbol R
into which formulas are substituted. That is a second-order pattern in the present terms, of which induction is the paradigm.
Vaught showed that every r.e. theory directly interpreting a weak set theory VS is so axiomatizable. First-order patterns, whose
metavariables cannot take arguments, are strictly weaker. B2 shows that for the raw schema this weakness bites.

### B8. Noise. (proved, trivial)

Mistakes only make the lgg more general (monotonicity of lgg), so B1–B4 persist. With the trimmed lgg (thm:imitation:trimmed,
budget e), if the clean data contain at least e+2 members of F', then every trimmed subset contains two of them, so the trimmed
lgg is >= some L_a and is unsound. A refutation of the tag's schema then certifies "noise or unrealizable", and only the absence
of noise makes it a certificate of unrealizability.

---------------------------------------------------------------------------------------------------------------------------

## 4. Scripts and outputs (this directory)

| script | claims | output |
|---|---|---|
| `raw_common.py` | encodings Ind, IndEq; exact truth evaluator (Cauchy-bound decision of single-variable universal sentences) | (library) |
| `raw_search.py` | sorted instantiation search for false sentence instances; printer | (library) |
| `b1_pairs.py` | B1(a)–(d): lggs of explicit pairs, exact false instances; paper's 4 vs 2 | `b1_pairs.out` |
| `b1b_bruteforce.py 5 2000` | B1(e): all 2556 pairs of motives of size <= 5 | `b1b_bruteforce.out` |
| `b2_family.py` | B2.1, B2.2, B2(d), B4(b) (partition brute force) | `b2_family.out` |
| `b2b_guards.py` | B2 guard remark | (stdout) |
| `b3_refutation.py` | B5: checked refutations, propagation, descent, sizes; F-family blocked/unblocked | `b3_refutation.out` |
| `b4_equational.py` | B6: lgg recovery of IndEq, bounded agreement check, capture counterexample | `b4_equational.out` |

Re-run: `cd` to this directory, then `python3 <script>`. Everything runs in about 3 s in total.

## 5. Caveats

- "Sound" means all *sentence* instances are true in N. Every exhibited false instance is a closed, capture-free, well-sorted
  sentence, so the negative results do not depend on this choice. The positive B6 needs the freshness guard under
  universal-closure semantics.
- B2 is about unguarded first-order patterns, and about the occurrence and freshness guards learnable from F'. A guard family
  containing "is an induction instance" (or the Sub premises) trivially escapes it; that is the report's Sub route.
- In B1(e), "no false instance found" is a finite search failure. Only the classes proved sound in the text are claimed sound.
- B5(d) shows a blocked natural refutation for the family F. I do not claim that F has no singleton refutation from Delta_0 plus
  logic.
- Citations I am less sure of:
  - Huet's 1976 thesis as a source of first-order anti-unification;
  - Mostowski 1952 and Kreisel–Lévy 1968 for reflexivity;
  - the exact chapter in Simpson for the finite axiomatizability of ACA_0;
  - which Parsons paper is meant.
- Tarski's paper is in Arch. Math. Logik Grundlagenforsch. 7 (1965 volume; some sources date it 1964), 61–79.
- For higher-order generalization (Track A context): Pfenning (LICS 1991) and Baumgartner–Kutsia–Levy–Villaret (JAR 58, 2017) give
  unique lggs in the higher-order pattern fragment. The induction schema is not a Miller (1991) pattern, since P is applied to
  0 and Sx, not to bound variables. Hirata–Ogawa–Harao (ILP 2004) study second-order generalization. Second-order matching is
  decidable (Huet–Lang 1978); higher-order matching is decidable (Stirling 2009).
