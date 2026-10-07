# T6. Coherence and existence: a family of "philosophical completeness theorems"

*Theory thread T6 of the inferential-learning project. Read `00-brief.md`, `lit/L10-user-notes-digest.md` §1.5, and T2 first. This note answers the user's question in `logic/a 'philosophical version' of gödel's completeness theorem.md`:*

> *"'a mode of talking makes sense (is coherent) iff there is something it could be talking about' … is a generalization of the completeness thm available that justifies this philosophical proposition more broadly?"*

*It also answers his friend Sam's remark there: "completeness is an adjunction between sentences and models … if you are in [the] image, then [the] round trip is just identity. what is this image?"*

**Status tags** (as in T2).
* **[proved]**: a full proof is given here.
* **[proved; TOSU]**: proved, but "trivial once set up"; the content is in the framing.
* **[cited]**: a known result. **(u)** means the bibliographic or technical details are from memory and unverified.
* **[sketch]**, **[conjecture]**: as stated.

Sanity-check scripts are in `theory/T6-checks/` (§10). `repair_checks.py` and part (a2) of `contexts_local_global.py` were added after adversarial verification; see the Verification log at the end. I build on T2 and cite its numbering ("T2 Lemma 4.1", etc.). I do not reprove T2's results.

---

## 0. Summary

**Short answer.** Yes: there is a whole family of "coherent iff there is something it could be talking about" theorems. They share one anatomy, and that anatomy also shows exactly where the philosophical proposition stops being true.

1. **Two slogans, two theorems (§1).**
   * Sentences and models form a Galois connection $\mathrm{Mod}\dashv\mathrm{Th}$ (Sam's adjunction).
   * Sam's slogan is *strong* completeness: the image of $\mathrm{Th}$ is exactly the set of deductively closed sets (Prop 1.3). The user's slogan is *weak* completeness. Weak is strictly weaker: IPC is weakly but not strongly complete for Boolean valuations (Prop 1.6).
   * Both reduce to one statement: completeness ⟺ every *point* (completely meet-irreducible theory) is realized by a model (Thm 1.5). Every proof has two steps: (i) points exist (Zorn, free); (ii) points are realized (Henkin, Zariski, or trivially).
   * Every calculus is strongly complete for its own closed theories (Thm 1.4; no Zorn needed) and, if finitary, for its own points (Thm 1.5(a); step (i) alone). So the proposition is a tautology if the "something" may be built from syntax. It is informative exactly when the semantic class is fixed independently.
2. **Positions (§2).**
   * Coherent maximal positions *are* the admissible valuations (Thm 2.2).
   * Scott relations are dually isomorphic to closed sets of valuations. The closure operators are explicit: overlap + weakening + cut on the syntax side, topological closure on the semantic side (Thm 2.4). This is Stone duality for the free Boolean algebra on the formulas (Rem 2.5).
   * Structurality ⟺ substitution-invariance, and every structural calculus is complete for its Lindenbaum bundle (Thm 2.6).
3. **Credences (§3).**
   * Coherent ⟺ in the de Finetti polytope ⟺ satisfies every **counting sequent** (Thm 3.1).
   * CCS-style local constraints are not sufficient, in two ways. Arity: for every $k$ there is a credence coherent on every sub-agenda over $<k$ atoms but incoherent (Thm 3.4). Threshold: the hierarchy of counting sequents by their threshold $m$ is strict (the violated sequent repeats no formula), and even all ordinary sequents' union bounds fail (Thm 3.5). Each single finite agenda needs only finitely many counting sequents (its facets). What fails is any bound on arity or threshold that works uniformly across agendas.
   * Local additivity does suffice on logically closed agendas (Prop 3.6).
   * First-order: coherent ⟺ measure on complete theories (Thm 3.7). The Gaifman condition is a probabilistic ω-rule that pins true arithmetic (Thm 3.8). Every logical inductor's limit violates it (Cor 3.9).
   * Finite VNM data are coherent iff no derivation of $L\succ L$ by mixing (independence) plus transitivity exists, a money-pump-like certificate (Prop 3.10).
4. **Contexts (§4).**
   * A monotone multi-context calculus is sound and complete for local-models (belief-state) semantics. Designated-context coherence ⟺ a bridge-compatible family of local belief states exists that is nonempty at every designated context. The canonical one is the grounded equilibrium (Thm 4.1, Cor 4.2, Prop 4.3).
   * Bridges as rules of proof ≠ bridges as conditionals between worlds (Thm 4.5). A global world follows from local coherence on tree covers (Thm 4.6) but not on cycles (Prop 4.7, the frustrated triangle/Specker).
   * This yields Def 4.8: what "true in the context at hand" means.
5. **Learned rules (§5).**
   * Coherence on a designated context buys a Lindenbaum (syntactic) model (Thm 5.1). After Leibniz reduction it is the intended model iff the point is the theory of a *generating* (surjective) intended valuation; in general one gets the reduction of the generated submatrix (Thm 5.2, Prop 5.3). For CPC every point is about **2**; finite-matrix logics talk about reductions of generated submatrices (Prop 5.3). T2's residue of alternative meanings = a set of non-isomorphic things talked about (Ex 5.4).
   * Non-standardness has two layers: coherent-but-false, and true-but-non-categorical. Two barriers make the caveat a theorem:
     * compactness (Thm 5.6);
     * computability: a computable coherence notion matches "has an *intended* model" only if that is a Π₁ property (Thm 5.7). It fails for ℕ, for ℤ-solvability (MRDP) and for finite models (in a vocabulary with a binary relation symbol).
   * Anchoring pins exactly the definable vocabulary *uniformly over all possible anchorings* (Beth; Prop 5.8). A particular anchoring structure can pin more.
   * ℕ is pinned by second-order induction, initiality, Tennenbaum (the *unique computable* model of PA, answering "lowest-complexity structure?"), or the ω-rule. Each is an ingredient the barriers show no finitary computable coherence can supply.
6. **Verdict (§6).**
   * Vindicated if "something" means "some model of the kind the semantics allows".
   * Not vindicated for *intended* existence. That needs categoricity or world-anchoring, matching the user's split between coherence and "hooking onto the world".

## 1. The abstract frame: Galois connections, closure operators, points

### 1.1 The adjunction

**Definition 1.1.** A **semantic frame** is a triple $(S,M,\models)$:
* $S$ is a set ("sentences": formulas, sequents, equations, inequalities, labelled claims);
* $M$ is a set or class ("models": structures, valuations, points, probability measures, local-model families);
* ${\models}\subseteq M\times S$ is a satisfaction relation.

For $\Sigma\subseteq S$ and $K\subseteq M$, define
$$\mathrm{Mod}(\Sigma)=\{m:\ m\models\sigma\ \forall\sigma\in\Sigma\},\qquad \mathrm{Th}(K)=\{\sigma:\ m\models\sigma\ \forall m\in K\}.$$

**Fact 1.2 (Galois connection) [cited: Birkhoff 1940; Ore 1944; standard].**
* $K\subseteq\mathrm{Mod}(\Sigma)\iff\Sigma\subseteq\mathrm{Th}(K)$.
* Hence $\mathrm{Th}\circ\mathrm{Mod}$ is a closure operator on $\mathcal P(S)$ and $\mathrm{Mod}\circ\mathrm{Th}$ is a closure operator on $\mathcal P(M)$.
* $\mathrm{Mod}$ and $\mathrm{Th}$ restrict to mutually inverse, inclusion-reversing bijections between the two families of closed sets. Both families are complete lattices, so these lattices are dually isomorphic.

Viewing $(\mathcal P(S),\subseteq)$ and $(\mathcal P(M),\supseteq)$ as categories, the first bullet says that $\mathrm{Mod}$ is left adjoint to $\mathrm{Th}$. This is the precise content of "completeness is an adjunction between sentences and models". The adjunction exists for *every* frame. A completeness theorem says something about its fixed points.

A **deductive system** on $S$ is a closure operator $C$ (Tarski): extensive, monotone and idempotent. It is *finitary* if $C(X)=\bigcup\{C(X_0):X_0\subseteq_{\rm fin}X\}$.
* $C$ is **sound** for the frame if $C\le\mathrm{Th}\circ\mathrm{Mod}$ pointwise. Equivalently, every $\mathrm{Th}(\{m\})$ is $C$-closed.
* $C$ is **strongly complete** if $C=\mathrm{Th}\circ\mathrm{Mod}$.
* Call $X$ **$C$-coherent** if $C(X)\neq S$. Then $C$ is **weakly complete** if every $C$-coherent $X$ has $\mathrm{Mod}(X)\neq\emptyset$.

### 1.2 Sam's question: what is the image?

**Proposition 1.3 [proved; TOSU].** Let $C$ be sound. Then $\{\mathrm{Th}(K):K\subseteq M\}=\mathrm{Fix}(C)$ iff $C$ is strongly complete. In words: the image of the round trip is exactly the family of sets closed under the inference rules iff the rules are complete.

*Proof.*
* Since $\mathrm{Th}\circ\mathrm{Mod}\circ\mathrm{Th}=\mathrm{Th}$, the image of $\mathrm{Th}$ is $\mathrm{Fix}(\mathrm{Th}\circ\mathrm{Mod})$.
* A closure operator is determined by its fixed points, via $C(X)=\bigcap\{T\in\mathrm{Fix}(C):X\subseteq T\}$.
* So $\mathrm{Fix}(C)=\mathrm{Fix}(\mathrm{Th}\circ\mathrm{Mod})$ iff $C=\mathrm{Th}\circ\mathrm{Mod}$. ∎

*Note (added after verification).* The proof never uses soundness, so Prop 1.3 holds for every closure operator $C$. Soundness is stated only because it is the case of interest. [checked: `repair_checks.py` (A), 0 failures on random unsound finite frames]

### 1.3 Every calculus is complete for something

**Theorem 1.4 (tautological completeness) [proved; TOSU].** Every closure operator $C$ on $\mathcal P(S)$ is strongly complete for the **canonical frame** $(S,\mathrm{Fix}(C),\ni)$, where a "model" is a closed set $T$ and $T\models\sigma$ iff $\sigma\in T$.

*Proof.* $\mathrm{Mod}(X)=\{T\in\mathrm{Fix}(C):X\subseteq T\}$, so $\mathrm{Th}(\mathrm{Mod}(X))=\bigcap\{T\in\mathrm{Fix}(C):X\subseteq T\}=C(X)$. ∎

This theorem is the reason the philosophical proposition needs care. If "something it could be talking about" may be *any* object, the proposition is trivially true: the coherent mode of talking is about its own closed theories. Real completeness theorems have content only because their models are specified *before* and *independently of* the calculus: truth tables, Tarskian structures, points of $\bar k^n$, probability measures.

### 1.4 Points: the anatomy of completeness

**Definition.** A closed $T\in\mathrm{Fix}(C)$ is **completely meet-irreducible**, or a **point** of $C$, if $T\neq S$ and there is some $\sigma\notin T$ that belongs to every closed $T'\supsetneq T$. Equivalently, $T$ is *relatively maximal*: maximal among closed sets omitting σ. Write $\mathrm{Pt}(C)$ for the set of points.

**Theorem 1.5 (completeness = realization of points) [proved; the order theory is Birkhoff's subdirect representation, the logic is Lindenbaum's lemma].** Let $C$ be finitary.
* **(a) Lindenbaum.** Every closed $T$ is the intersection of the points containing it. The intersection of the empty family is $S$.
* **(b)** Let $C$ be sound for a frame $(S,M,\models)$. Then $C$ is strongly complete iff every point is the theory of a model: $\mathrm{Pt}(C)\subseteq\{\mathrm{Th}(\{m\}):m\in M\}$.
* **(c) (revised after verification: soundness hypothesis added)** Let $C$ be sound for $(S,M,\models)$. Suppose there is a finite $F$ with $C(F)=S$ (a finite "explosive" set, e.g. $\{\bot\}$), and suppose $\mathrm{Th}(\{m\})\neq S$ for every $m$. Then $C$ is weakly complete iff every *maximal* proper closed set is the theory of a model. Soundness is needed only for (⇒). Without it (⇒) fails. Example: $S=\{a,b,\bot\}$ with closed sets $\emptyset,\{a\},S$, and one model $m$ with $\mathrm{Th}(\{m\})=\{a,b\}$. Then $C$ is weakly complete, but the maximal proper closed set $\{a\}$ is not the theory of a model. [checked: `repair_checks.py` (A)]

*Proof.*
* (a) Let $\sigma\notin T$.
  * The closed supersets of $T$ omitting σ, ordered by ⊆, are closed under unions of chains: by finitarity the union of a chain of closed sets is closed, and it still omits σ.
  * Zorn gives a maximal one, $T_\sigma$. Every closed set strictly above $T_\sigma$ contains σ, so $T_\sigma$ is a point.
  * Then $T=\bigcap_{\sigma\notin T}T_\sigma$.
* (b) (⇐) Soundness gives $C(X)\subseteq\mathrm{Th}(\mathrm{Mod}(X))$. For the converse, write $C(X)=\bigcap_i P_i$ as an intersection of points, by (a).
  * Each $P_i=\mathrm{Th}(\{m_i\})$, and $m_i\in\mathrm{Mod}(X)$ because $X\subseteq P_i$.
  * So $\mathrm{Th}(\mathrm{Mod}(X))\subseteq\bigcap_i\mathrm{Th}(\{m_i\})=C(X)$.
* (b) (⇒) Let $P$ be a point. Then $P=\mathrm{Th}(\mathrm{Mod}(P))=\bigcap_{m\in\mathrm{Mod}(P)}\mathrm{Th}(\{m\})$.
  * $\mathrm{Mod}(P)\ne\emptyset$, since otherwise the right-hand side is $S\neq P$.
  * Each $\mathrm{Th}(\{m\})$ is closed by soundness and contains $P$. If all of them strictly contained $P$, all would contain the witnessing σ, and so would $P$. So $P=\mathrm{Th}(\{m\})$ for some $m$.
* (c) Proper closed sets are closed under unions of chains: if the union were $S$, the finite $F$ would lie in one member $T$, giving $T\supseteq C(F)=S$. So by Zorn every proper closed set extends to a maximal one.
  * (⇐) A coherent $X$ lies in a maximal $T=\mathrm{Th}(\{m\})$, so $m\in\mathrm{Mod}(X)$.
  * (⇒) If $T$ is maximal, weak completeness gives $m\in\mathrm{Mod}(T)$. Then $T\subseteq\mathrm{Th}(\{m\})\ne S$, and $\mathrm{Th}(\{m\})$ is closed *by soundness*, so maximality gives equality. ∎

**Proposition 1.6 (weak ≠ strong: the user's slogan is weaker than Sam's) [proved, modulo the standard deduction theorem for IPC].** Intuitionistic propositional logic (IPC) is weakly complete, but not strongly complete, for the Boolean valuations BV.

*Proof.*
* *Soundness:* every Boolean theory is IPC-closed.
* *Not strongly complete:* $p\vee\neg p\in\mathrm{Th}(\mathrm{BV})$ but IPC does not prove it.
* *Weakly complete,* via Thm 1.5(c) with $F=\{\bot\}$. Let $T$ be maximal IPC-consistent.
  * If $\varphi\notin T$, then maximality and the deduction theorem give $T\vdash\varphi\to\bot=\neg\varphi$, so $\neg\varphi\in T$.
  * Hence $T$ contains every instance of excluded middle. As consequence relations, $\mathrm{CPC}=\mathrm{IPC}+\mathrm{EM}$, so $C_{\rm CPC}(T)=C_{\rm IPC}(T\cup\mathrm{EM})=T\not\ni\bot$.
  * So $T$ is maximal CPC-consistent, i.e. $T=\mathrm{Th}(v)$ for a Boolean $v$. ∎
* *Alternative for weak completeness:* Glivenko's theorem (Glivenko 1929 [cited]): $X$ is IPC-consistent iff it is CPC-consistent.

*Reading.* T2 Thm 3.6(a) showed that IPC and CPC have the same coherence data. Here is the semantic mirror. Every coherent intuitionistic position *is* about a classical world: the existence slogan holds. But those worlds do not *determine* intuitionistic consequence. IPC has non-maximal points, for instance a theory maximal among those omitting $p\vee\neg p$ (Lindenbaum, Thm 1.5(a)). Such points are prime and are realized only by Kripke or Heyting models; no Boolean valuation realizes them. In general:
* weak completeness needs the *maximal* theories to be realized;
* strong completeness needs *all* points to be realized;
* the two coincide when every point is maximal. This is true in classical logic, by proof by cases. Let $T$ be maximal among closed sets omitting φ, and suppose neither ψ nor ¬ψ is in $T$. By maximality, φ ∈ C(T,ψ) and φ ∈ C(T,¬ψ). Proof by cases gives C(T,ψ) ∩ C(T,¬ψ) = C(T) = T, so φ ∈ T, a contradiction. So $T$ is complete: it contains ψ or ¬ψ for every ψ. Since $T\neq S$ it is consistent, and a complete consistent theory is maximal consistent. (Sentence repaired after verification.)

### 1.5 The family of instances

| syntax $S$ | calculus $C$ | models $M$ | points $\mathrm{Pt}(C)$ | realization step | name |
|---|---|---|---|---|---|
| finite sequents Γ▷Δ | overlap, weakening, cut | valuations $\mathrm{Fm}\to2$ | maximal coherent positions | trivial (points *are* valuations) | Scott 1974; Shoesmith–Smiley 1978 (§2) |
| first-order sentences | any complete proof system | $L$-structures | complete theories | Henkin witnesses: objects = closed terms | Gödel 1930; Henkin 1949 |
| polynomials $f\in k[\bar x]$ (read $f=0$) | ideal rules + radical rule ($f^n\Rightarrow f$) | points of $\bar k^n$ | maximal ideals | Zariski's lemma: $k[\bar x]/\mathfrak m$ is finite over $k$, so it embeds in $\bar k$ | Hilbert's Nullstellensatz (1893) |
| finite systems of linear inequalities | nonnegative combination, relaxation, ex falso | $\mathbb R^n$ | — | LP duality | Farkas (1902) |
| bets / credences on an agenda | counting sequents (§3) | probability mixtures of valuations | — | separating hyperplane | de Finetti (1937) |
| FOL sentences + credences | Gaifman coherence | measures on complete theories | — | Carathéodory | Gaifman (1964) (§3) |
| real polynomial (in)equalities | Positivstellensatz certificates | points of $\mathbb R^n$ | — | real closure | Krivine 1964; Stengle 1974 [cited] |
| finite preference data on lotteries | mixing + transitivity (independence) | utility functions | — | Motzkin's transposition theorem | von Neumann–Morgenstern (§3.4) |
| labelled claims $i{:}\varphi$ | local rules + bridges | local-model families | — | canonical chain | §4 |

The Nullstellensatz row is Sam's other pointer. The weak Nullstellensatz *is* a weak completeness theorem:
* "$1=0$ is not derivable from $f_1=\dots=f_m=0$ by ideal manipulations" iff "there is a common zero in $\bar k^n$".
* The strong Nullstellensatz $I(V(J))=\sqrt J$ is the strong completeness theorem. Its round trip is the radical, so the closed sets are the radical ideals.
* The points of the radical-closure operator are the maximal ideals. (Every prime ideal of $k[\bar x]$ is an intersection of maximal ideals, so non-maximal primes are not completely meet-irreducible; Jacobson property [cited].) They are realized by Galois orbits of points of $\bar k^n$.

The table's anatomy appears in each row: (i) Zorn gives a maximal ideal; (ii) Zariski realizes it as a point. Categorical logic gives a strong form of the slogan "completeness = enough points": Deligne's theorem that coherent toposes have enough points is equivalent to Gödel completeness for coherent logic (SGA 4; Makkai & Reyes 1977) [cited (u)].

**Every row also has a non-standard caveat.** Coherence buys existence in a *closure* of the naive model class:
* **Nullstellensatz:** points over $\bar k$, not $k$. $x^2-2$ and $x^2+1$ are coherent over $\mathbb Q$ but have no rational zero; `misc_checks.py` confirms this.
* **Farkas:** finite systems only. The infinite system $\{x\ge n:n\in\mathbb N\}$ is coherent (no finite refutation) but has no real solution. Its "model" is an infinite element of a non-Archimedean ordered field.
* **Integers:** over $\mathbb Z$, LP-coherence of $2x=1$ does not give an integer point. A new rule, Chvátal–Gomory rounding, is needed. For unbounded polynomial constraints no r.e. calculus suffices (Thm 5.7).
* **FOL:** non-standard models.
* **de Finetti:** on infinite agendas, finitely additive or non-Gaifman measures (§3.3).
* **VNM:** with infinitely many comparisons, lexicographic (non-Archimedean) utilities (Hausner 1954 [cited (u)]).

Historically, the term-model construction *is* how $\sqrt{-1}$ entered mathematics as a "thing talked about". Cauchy (1847) [cited (u)] defined the complex numbers as real polynomials modulo $x^2+1$: a coherent mode of talking about $i$, with the Lindenbaum quotient as its object. This is the user's own puzzle ("we hypothesized an object with some properties and these properties turned out to be those of a real thing", L10 §1.2) in its cleanest instance.

---

## 2. Positions: bilateral completeness is Stone duality

Fix a set $\mathrm{Fm}$. A **sequent** is $\Gamma\rhd\Delta$ with $\Gamma,\Delta\subseteq_{\rm fin}\mathrm{Fm}$. A **valuation** is any $v:\mathrm{Fm}\to\{0,1\}$; it need not be compositional. $v\models\Gamma\rhd\Delta$ iff $v$ falsifies some γ ∈ Γ or verifies some δ ∈ Δ. A **position** is a pair $[X:Y]$ of arbitrary sets, read "assert all of X, deny all of Y". Given a set $R$ of sequents, $[X:Y]$ is **R-incoherent** if some $\Gamma\rhd\Delta\in R$ has $\Gamma\subseteq X$ and $\Delta\subseteq Y$ (Restall's reading, T2 §1).

**Definition 2.1.** A **Scott relation** is a set ⊢ of sequents closed under:
* (Ov) $\Gamma\rhd\Delta$ whenever $\Gamma\cap\Delta\neq\emptyset$;
* (Wk) $\Gamma\rhd\Delta\ \Rightarrow\ \Gamma\cup\Gamma'\rhd\Delta\cup\Delta'$;
* (Cut) $\Gamma,\varphi\rhd\Delta$ and $\Gamma\rhd\varphi,\Delta\ \Rightarrow\ \Gamma\rhd\Delta$.

Intersections of Scott relations are Scott relations. Write $\langle S\rangle$ for the least Scott relation containing $S$.

**Theorem 2.2 (bilateral Lindenbaum: coherent maximal positions are valuations) [proved; Scott 1974, Shoesmith & Smiley 1978 cited for the original].** Let ⊢ be a Scott relation.
* (a) Every ⊢-coherent position $[X:Y]$ is realized by some $v\in\mathrm{Val}(\vdash)$, i.e. $v[X]=1$ and $v[Y]=0$.
* (b) The maximal ⊢-coherent positions are exactly the pairs $[v^{-1}(1):v^{-1}(0)]$ with $v\in\mathrm{Val}(\vdash)$.

*Proof.*
* (a) Order the coherent positions extending $[X:Y]$ componentwise.
  * The union of a chain is coherent, because sequents are finite: a witness $\Gamma\subseteq\bigcup X_i$, $\Delta\subseteq\bigcup Y_i$ lies in a single member of the chain.
  * Zorn gives a maximal coherent $[X^\*:Y^\*]$.
  * *Disjoint:* by (Ov), $X^\*\cap Y^\*=\emptyset$.
  * *Exhaustive:* suppose $\varphi\notin X^\*\cup Y^\*$. By maximality both $[X^\*\cup\{\varphi\}:Y^\*]$ and $[X^\*:Y^\*\cup\{\varphi\}]$ are incoherent. So there are $\Gamma_1,\varphi\rhd\Delta_1$ and $\Gamma_2\rhd\varphi,\Delta_2$ in ⊢ with $\Gamma_i\subseteq X^\*$ and $\Delta_i\subseteq Y^\*$. Weaken both to $\Gamma_1\cup\Gamma_2$ and $\Delta_1\cup\Delta_2$ and cut on φ. The result $\Gamma_1\cup\Gamma_2\rhd\Delta_1\cup\Delta_2$ shows $[X^\*:Y^\*]$ incoherent, a contradiction.
  * So $v:=\chi_{X^\*}$ is a valuation. It satisfies every $\Gamma\rhd\Delta\in{\vdash}$: otherwise $\Gamma\subseteq X^\*$ and $\Delta\subseteq Y^\*$.
* (b) For $v\in\mathrm{Val}(\vdash)$, the position $[v^{-1}(1):v^{-1}(0)]$ is coherent, because $v$ satisfies ⊢. It is maximal, because any proper extension puts some φ on both sides, and (Ov) makes that incoherent. The converse is (a). ∎

**Corollary 2.3 (strong bilateral completeness) [proved].** For every set $S$ of sequents, $\mathrm{Th}(\mathrm{Mod}(S))=\langle S\rangle$.

*Proof.*
* *Soundness.* Every valuation satisfies (Ov) instances and preserves (Wk) and (Cut). For (Cut): if $v[\Gamma]=1$ and $v[\Delta]=0$, the two premises force $v(\varphi)=0$ and $v(\varphi)=1$.
* *Completeness.* If $\Gamma_0\rhd\Delta_0\notin\langle S\rangle$, then $[\Gamma_0:\Delta_0]$ is $\langle S\rangle$-coherent: a witness inside it would yield $\Gamma_0\rhd\Delta_0$ by (Wk). Thm 2.2 gives $v\in\mathrm{Val}\langle S\rangle\subseteq\mathrm{Mod}(S)$ violating $\Gamma_0\rhd\Delta_0$. ∎

**Theorem 2.4 (the duality, with both closure operators) [proved; the correspondence between compact (finite-sequent) consequence relations and closed classes of valuations is standard: Scott 1974; Shoesmith & Smiley 1978].** Give $2^{\mathrm{Fm}}$ the product (Cantor) topology. The Galois connection between sets of sequents and sets of valuations has:
* syntactic closure $S\mapsto\langle S\rangle$: generate by (Ov), (Wk), (Cut);
* semantic closure $V\mapsto\overline V$: topological closure.

So it restricts to a dual lattice isomorphism
$$\{\text{Scott relations}\}\ \cong^{\rm op}\ \{\text{closed subsets of }2^{\mathrm{Fm}}\},\qquad {\vdash}\mapsto\mathrm{Val}(\vdash),\quad V\mapsto\mathrm{Th}(V).$$

*Proof.* The syntactic closure is Cor 2.3. The semantic closure is T2 Lemma 4.1(a): $\mathrm{Mod}(\mathrm{Th}(V))=\overline V$, because each sequent excludes the basic clopen set $U(\Gamma,\Delta)$. Fact 1.2 then gives the dual isomorphism of fixed points. ∎

So Sam's "image" in the bilateral setting is exactly the Scott relations. The semantic objects are arbitrary closed sets of valuations. Script `scott_duality.py` checks Cor 2.3 on 300 random sequent sets over 4 formulas. It also checks exhaustively, over 3 formulas, that all 256 sets of valuations are Galois-closed and that $V\mapsto\mathrm{Th}(V)$ is injective. For the single-conclusion analogue, T2 Lemma 4.1(b) identifies the semantic closure as "topological closure, then closure under arbitrary intersections (including the all-true valuation)". `misc_checks.py` (b) confirms this exhaustively for 3 formulas.

**Remark 2.5 (this is Stone duality) [proved modulo Stone 1936].**
* Let $B$ be the free Boolean algebra generated by $\mathrm{Fm}$, with every formula treated as an independent generator. Its Stone space is $2^{\mathrm{Fm}}$ with the product topology.
* The sequent $\Gamma\rhd\Delta$ is the clause $\bigvee_{\gamma\in\Gamma}\neg\gamma\vee\bigvee_{\delta\in\Delta}\delta\in B$, whose clopen set is $\{v:v\models\Gamma\rhd\Delta\}$.
* Every element of $B$ is a finite meet of clauses (CNF), and a filter is determined by its clauses. Filters of $B$ correspond to closed sets of $2^{\mathrm{Fm}}$ (Stone). Thm 2.4 identifies those closed sets with Scott relations.
* Hence Scott relations ↔ closed sets ↔ filters of $B$.

The point is that at this level of generality **the connectives play no role at all in the duality**. Completeness for positions is pure Boolean algebra over formulas-as-atoms. The connectives enter only through *which* closed set the rules carve out. This is Suszko's thesis, seen as a duality. Every Tarskian consequence, structural or not, is determined by non-truth-functional bivaluations, namely the characteristic functions of its theories (Suszko 1977 [cited (u)]; Suszko stated it for structural logics).

**Theorem 2.6 (structural calculi: substitution-invariance and Lindenbaum bundles) [proved].** Let $\mathrm{Fm}$ be a term algebra. Substitutions are endomorphisms σ. ⊢ is **structural** if $\Gamma\rhd\Delta\in{\vdash}$ implies $\sigma\Gamma\rhd\sigma\Delta\in{\vdash}$.
* (a) ⊢ is structural iff $\mathrm{Val}(\vdash)$ is closed under $v\mapsto v\circ\sigma$. So structural Scott relations are dually isomorphic to closed, substitution-invariant sets of valuations.
* (b) For $v\in\mathrm{Val}(\vdash)$, let $L_v=\langle\mathrm{Fm},v^{-1}(1)\rangle$. It is a logical matrix, with algebra the term algebra and designated set the true-set of $v$. If ⊢ is structural:
  * each $L_v$ validates every sequent of ⊢ under every assignment;
  * ⊢ is exactly the set of sequents valid in all $L_v$;
  * every coherent position is realized in some $L_v$ by the identity assignment.

*Proof.*
* (a) Use $v\circ\sigma\models\Gamma\rhd\Delta$ iff $v\models\sigma\Gamma\rhd\sigma\Delta$.
  * (⇒) If ⊢ is structural and $v\in\mathrm{Val}(\vdash)$, then $v\circ\sigma$ satisfies every $\Gamma\rhd\Delta\in{\vdash}$ because $\sigma\Gamma\rhd\sigma\Delta\in{\vdash}$.
  * (⇐) If $\mathrm{Val}(\vdash)$ is substitution-invariant and $\Gamma\rhd\Delta\in{\vdash}=\mathrm{Th}(\mathrm{Val}(\vdash))$, then every $v$ satisfies $\sigma\Gamma\rhd\sigma\Delta$, because $v\circ\sigma\in\mathrm{Val}(\vdash)$.
  * The dual isomorphism is the restriction of Thm 2.4.
* (b) Assignments into $L_v$ are substitutions σ, and $L_v$ validates $\Gamma\rhd\Delta$ iff $v\circ\sigma\models\Gamma\rhd\Delta$ for all σ. That holds by (a). If $\Gamma\rhd\Delta\notin{\vdash}$, Thm 2.2 gives $v\in\mathrm{Val}(\vdash)$ violating it, and the identity assignment in $L_v$ violates it. ∎

*Reading.*
* Thm 2.2 is the cleanest form of the user's proposition. A position is coherent iff it is the partial description of some admissible valuation: "some way the sentences could all come out". The something is a total, possibly non-compositional valuation.
* Thm 2.6 upgrades it to a compositional "model": a matrix whose algebra is *the language itself*. That is the Lindenbaum bundle, the multiple-conclusion analogue of Wójcicki's theorem for single-conclusion logics (Łoś & Suszko 1958; Wójcicki 1988) [cited].
* Whether the *intended* compositional semantics (truth tables) is reached depends on the rules. If ⊢ contains the eleven truth-table schemata TT and one coherence datum, then $\mathrm{Val}(\vdash)=\mathrm{BV}$ exactly (T2 Thm 4.4).
* With single-conclusion data, coherent maximal positions still correspond to $\mathrm{Val}$. But $\mathrm{Val}$ then includes the ∩-closure $\mathrm{BV}^\cap$, i.e. the "gappy" valuations of T2 Thm 4.2–4.3. What the user's coherence loss licenses talk *about* then includes undecided, non-Boolean "worlds". §5.2 identifies what they are.

---

## 3. Credences: de Finetti, counting sequents, and why pairwise constraints fail

### 3.1 The finite propositional case

Let $\mathrm{BV}$ be the Boolean valuations over finitely many atoms. Let $F$ be a finite **agenda** of formulas and $P:F\to[0,1]$ a credence function. For $v\in\mathrm{BV}$ write $\bar v=(v(\varphi))_{\varphi\in F}\in\{0,1\}^F$.

**Definition.** $P$ is **coherent** if $P=\sum_v\mu(v)\bar v$ for some probability μ on BV. Equivalently, $P$ lies in the **coherence polytope** $\Pi_F=\mathrm{conv}\{\bar v:v\in\mathrm{BV}\}$. In words: $P$ is the expected truth value under a random world.

A **counting sequent** over $F$ is a pair $(\Phi,m)$, with Φ a finite multiset of members of $F$ and $m\in\mathbb Z$. It is **valid** if every $v\in\mathrm{BV}$ makes at least $m$ members of Φ true, counted with multiplicity. Call $m$ its **threshold**. When $F$ contains complements $\gamma^\*$ (formulas equivalent to $\neg\gamma$), an ordinary multiple-conclusion sequent $\Gamma\rhd\Delta$ is the case $m=1$, $\Phi=\{\gamma^\*:\gamma\in\Gamma\}\cup\Delta$.

**Theorem 3.1 (de Finetti, the polytope, and counting sequents) [proved; hypothesis restated after verification].** Let $F$ be a finite union of **complementary pairs** $\{\varphi,\varphi^\*\}$ with $\varphi^\*\equiv\neg\varphi$. (A finite agenda cannot be literally closed under ¬, since φ, ¬φ, ¬¬φ, … are distinct. The complement of $\varphi^\*$ is φ.) Let $P$ be negation-coherent: $P(\varphi^\*)=1-P(\varphi)$. The following are equivalent.
* (i) $P$ is coherent.
* (ii) There is no **Dutch book**: no $\lambda\in\mathbb R^F$ with $\lambda\cdot(\bar v-P)<0$ for every $v$. (λ_φ units of the bet on φ are traded at price $P(\varphi)$; the agent's net gain is $\lambda\cdot(\bar v-P)$.)
* (iii) For all rational λ and $c$: if $\lambda\cdot\bar v\ge c$ for all $v$, then $\lambda\cdot P\ge c$.
* (iv) For every valid counting sequent $(\Phi,m)$: $\sum_{\varphi\in\Phi}P(\varphi)\ge m$.

*Proof.*
* (i)⇒(iii): $\lambda\cdot P=\mathbb E_\mu[\lambda\cdot\bar v]\ge c$.
* (i)⇒(ii): $\mathbb E_\mu[\lambda\cdot(\bar v-P)]=0$, so the gain cannot be negative in every world.
* (iii)⇒(i) and (ii)⇒(i): Π_F is the convex hull of finitely many 0/1 points, so it is a rational polytope (Weyl–Minkowski): $\Pi_F=\{x:a_i\cdot x\ge b_i,\ i\le r\}$ with rational $a_i,b_i$ [cited, standard].
  * If $P\notin\Pi_F$, some $a\cdot P<b\le a\cdot\bar v$ for all $v$. This violates (iii).
  * The book $\lambda=-a$ has gain $a\cdot P-a\cdot\bar v<0$ in every world, so it is a Dutch book.
* (iii)⇒(iv): put $\lambda$ = the multiplicity vector and $c=m$.
* (iv)⇒(iii): multiply λ and $c$ by a positive common denominator; this preserves both inequalities. For each φ with $\lambda_\varphi<0$, use $\lambda_\varphi v(\varphi)=|\lambda_\varphi|v(\varphi^\*)-|\lambda_\varphi|$, and the same identity for $P$ (negation coherence).
  * Let Φ contain $\lambda_\varphi$ copies of φ when $\lambda_\varphi>0$, and $|\lambda_\varphi|$ copies of $\varphi^\*$ when $\lambda_\varphi<0$. Let $m=c+\sum_{\lambda_\varphi<0}|\lambda_\varphi|$.
  * Then $\lambda\cdot\bar v\ge c$ iff $v$ makes at least $m$ members of Φ true, and $\lambda\cdot P\ge c$ iff $\sum_\Phi P\ge m$. ∎

Negation coherence is used only in (iv)⇒(iii), and it is needed there. $P\equiv1$ satisfies every valid counting sequent, because validity forces $m\le|\Phi|$, yet $P\equiv1$ is incoherent.

*Reading.*
* The probabilistic completeness theorem says a credence is coherent iff it is a mixture of worlds. Its proof-theoretic side is not ordinary sequents but **counting sequents**: graded positions such as "at least two of these six claims hold".
* An ordinary valid sequent yields the generalized union bound $\sum_{\gamma\in\Gamma}(1-P(\gamma))+\sum_{\delta\in\Delta}P(\delta)\ge1$. This is Adams' uncertainty-sum theorem, in multiple-conclusion form (Adams 1975, 1998 [cited (u)]).
* Script `counting_sequents.py` takes 215 random negation-coherent but incoherent credences. For each, it extracts the Farkas certificate, converts it to an integer counting sequent, verifies the sequent exactly, and checks that it is violated.

### 3.2 Which CCS-style constraints suffice?

The user's DLK notes use three kinds of constraint on a probe's credences (`ai/DLK/*`):
* negation coherence, $P(\neg Q)=1-P(Q)$ (CCS's "consistency");
* $P(A\wedge B)+P(A\vee B)=P(A)+P(B)$;
* a modus-ponens constraint. He suggests reading MP as the tautology $\neg P\vee\neg(P\to Q)\vee Q$. That reading gives exactly the union bound $P(Q)\ge P(P)+P(P\to Q)-1$.

**Proposition 3.2 [proved; TOSU].** Negation coherence alone is far from sufficient. Take the agenda $\{p,q,p\wedge q\}$ plus negations, with $P(p)=P(q)=0.2$, $P(p\wedge q)=0.9$, and complements on negations. This is negation-coherent but violates the valid sequent $p\wedge q\rhd p$.

**Example 3.3 (the MP polytope: three sequent bounds and one trivial bound) [computed; `prob_coherence.py` (a)].** For the agenda $(P(p),P(q),P(p\to q))=(a,b,c)$, the coherence polytope is the tetrahedron with vertices $(0,0,1),(0,1,1),(1,0,0),(1,1,1)$. Its four facets are:
* $a+c\ge1$ (from $\rhd p,\ p\to q$);
* $b\ge a+c-1$ (modus ponens);
* $c\le1$;
* $b\le c$ (from $q\rhd p\to q$).

On this tiny agenda, the user's MP constraint, two other single-sequent bounds and the trivial bound $c\le1$ are *exactly* coherence.

The next two theorems show that this does not scale.

**Theorem 3.4 (no bounded-arity family of constraints suffices) [proved; `prob_coherence.py` (b) for k ≤ 6].** Fix $k\ge3$. Let
$$F_k=\{A_i,\neg A_i: i\le k\}\cup\{A_i\wedge A_j,\neg(A_i\wedge A_j):i<j\le k\}$$
over atoms $A_1..A_k$. Let $P_k(A_i)=\frac1{k-1}$, $P_k(A_i\wedge A_j)=0$, with complements on negations. Then:
* (a) for every sub-agenda $F'\subseteq F_k$ whose formulas jointly mention at most $k-1$ atoms, $P_k|_{F'}$ extends to a coherent credence on all of $F_k$;
* (b) $P_k$ is incoherent.

Hence any family of necessary coherence constraints, each depending only on sub-agendas over $<k$ atoms, is satisfied by $P_k$ and fails to characterize coherence. In particular pairwise (CCS-style) constraints fail, and so does every bounded arity.

*Proof.*
* (a) Let $J$ be the mentioned atoms, $|J|\le k-1$. Let μ put mass $\frac1{k-1}$ on each valuation $e_j$ ($j\in J$) that makes exactly $A_j$ true. Put the remaining mass $1-\frac{|J|}{k-1}\ge0$ on the all-false valuation. Then $\mu(A_j)=\frac1{k-1}$ for $j\in J$ and $\mu(A_i\wedge A_j)=0$, so μ's credence on $F_k$ agrees with $P_k$ on $F'$.
* (b) Suppose μ is a probability on worlds giving $P_k$. Then $\mu(A_i\wedge A_j)=0$ makes the events $A_i$ pairwise μ-disjoint, so $\mu(\bigvee_iA_i)=\sum_i\mu(A_i)=\frac k{k-1}>1$. ∎

The same holds if $F_k$ is enlarged to *all* formulas in at most two atoms, valued by the two-atom marginals of μ. By the computation in (a), these marginals do not depend on $J$. So $P_k$ can even be "pairwise coherent" in the strongest sense: every pair of atoms has a genuine joint distribution consistent with everything else. This is the probabilistic face of local-versus-global consistency (§4.3), and it is the frustration in Specker's three-box parable [cited: Specker 1960].

**Theorem 3.5 (the counting-sequent hierarchy by threshold is strict; ordinary sequents do not suffice) [proved; checked by brute force for k = 3, by search for k = 4, and by exact MILP for k = 3, 4, 5].** With $F_k,P_k$ as in Thm 3.4:
* (a) $P_k$ violates the valid counting sequent
  $$\Phi=\{\neg A_1,\dots,\neg A_k\}\cup\{A_i\wedge A_j:i<j\},\qquad m=k-1.$$
* (b) $P_k$ satisfies *every* valid counting sequent over $F_k$ with $m\le k-2$.

In particular, for $k=3$, $P_3$ satisfies the union bound of every valid ordinary multiple-conclusion sequent over $F_3$ (the $m=1$ case), yet is incoherent.

*Proof.*
* (a) *Validity.* In a world with $t$ atoms true, the members of Φ that hold number $(k-t)+\binom t2$. This is $\ge k-1$ iff $\binom t2\ge t-1$ iff $(t-1)(t-2)\ge0$, which holds for all integers $t$.
  * *Violation.* $\sum_\Phi P_k=k\cdot\frac{k-2}{k-1}<k-1$, since $k(k-2)<(k-1)^2$.
* (b) Let Φ contain $a_t$ copies of $A_t$, $b_t$ of $\neg A_t$, $c_{ij}$ of $A_i\wedge A_j$ and $n_{ij}$ of $\neg(A_i\wedge A_j)$. Put $N=\sum n_{ij}$ and $x_t=b_t-a_t$. Write $\#(S)$ for the number of members of Φ true in the world whose true atoms are $S$.
  * *Two worlds.* In the all-false world, $\#(\emptyset)=\sum_tb_t+N$. In the world $\{t\}$, $\#(\{t\})=\#(\emptyset)-x_t$, because conjunctions are false in both.
  * *A direct computation:*
    $$\textstyle\sum_\Phi P_k=\frac{\sum a}{k-1}+\frac{(k-2)\sum b}{k-1}+N=\#(\emptyset)-\frac{\sum_tx_t}{k-1}.$$
  * *Using validity.* Let $s=\#(\emptyset)-m$. Validity at ∅ gives $s\ge0$, and validity at $\{t\}$ gives $x_t\le s$.
  * *Using violation.* Suppose $\sum_\Phi P_k<m$, i.e. $\sum_tx_t>(k-1)s$. If $s=0$, this contradicts $x_t\le0$, so $s\ge1$.
  * Since $a_t\ge0$, we have $x_t\le b_t$. Hence $\#(\emptyset)\ge\sum_tb_t\ge\sum_tx_t\ge(k-1)s+1$, by integrality.
  * Therefore $m=\#(\emptyset)-s\ge(k-2)s+1\ge k-1$.
* *The $m=1$ case for $k=3$.* A multiset counting sequent with $m=1$ is valid iff the ordinary sequent formed by its support is valid, and its $P$-sum is at least that of its support. So (b) with $k=3$ covers all ordinary sequents. ∎

*Terminology (revised after verification).* The hierarchy is in the **threshold** $m$, not in repetitions of formulas. The violated sequent in (a) is a plain set with no repeated formula, and (b) allows arbitrary repetitions. Earlier versions of this note called $m$ the "multiplicity"; the script name `multiplicity.py` is kept.

*Scope.* For any *single* finite agenda $F$, the finitely many facets of $\Pi_F$ give finitely many counting sequents that already characterize coherence (Thm 3.1). Thms 3.4–3.5 show that no bound on arity or threshold works *uniformly across agendas*. $F_k$ needs arity $k$ and threshold $k-1$.

*Checks.* `prob_coherence.py` (c) enumerates all $3^{12}$ assignments of the 12 formulas of $F_3$ to premises, conclusions or neither. It finds 503,270 valid sequents and no violated union bound, while the LP confirms that $P_3$ is incoherent. Part (d) confirms the $m=2$ certificate. `multiplicity.py` searches integer books with $|\lambda_\varphi|\le2$. The smallest violated threshold it finds is $m=2$ for $k=3$ and $m=3$ for $k=4$, in agreement with (b). `repair_checks.py` (C) solves the exact MILP: minimize $\sum_\Phi P_k-m$ over valid counting sequents with integer multiplicities in $[0,8]$. For $k=3,4,5$ the minimum is 0 when $m\le k-2$. When $m\le k-1$ it is $-\frac1{k-1}$, and the repetition-free sequent of (a) attains it.

**Proposition 3.6 (on logically closed agendas, local additivity suffices) [proved].** Let $F$ be (representatives of) a finite Boolean subalgebra of the Lindenbaum algebra, i.e. closed under ∧, ¬ up to equivalence and containing ⊤. Suppose $P$ respects equivalence. Then $P$ is coherent iff:
* $P\ge0$;
* $P(\top)=1$;
* $P(\varphi)=P(\varphi\wedge\psi)+P(\varphi\wedge\neg\psi)$ for all $\varphi,\psi\in F$.

Each constraint mentions at most three agenda formulas.

*Proof.* (⇒) is clear. (⇐):
* Taking $\varphi=\psi=\top$ gives $P(\bot)=0$.
* Let $a_1..a_N$ be the atoms (minimal nonzero elements) of the finite Boolean algebra $F$. Each $\varphi\wedge a_j$ is $a_j$ or ⊥. Splitting φ successively by $a_1,\dots,a_N$ gives $P(\varphi)=\sum_{a_j\le\varphi}P(a_j)+P(\varphi\wedge\bigwedge_j\neg a_j)=\sum_{a_j\le\varphi}P(a_j)$.
* Each $a_j$ is consistent, so pick $v_j\in\mathrm{BV}$ with $v_j(a_j)=1$. Since $a_j$ is an atom, $v_j(\varphi)=1$ iff $a_j\le\varphi$.
* Put $\mu=\sum_jP(a_j)\delta_{v_j}$. Its total mass is $P(\top)=1$, and $\mu(\varphi)=\sum_{a_j\le\varphi}P(a_j)=P(\varphi)$. ∎

*Exact answer to "which constraints are needed".*
* On a logically closed agenda, the local additivity identities suffice. The user's $P(A\wedge B)+P(A\vee B)=P(A)+P(B)$ is a consequence of them.
* On the arbitrary, unclosed agendas that a CCS probe actually sees (a list of statements), coherence of a given finite agenda is characterized by finitely many counting sequents, namely its facets. But no bound on their arity (Thm 3.4) or threshold (Thm 3.5) works uniformly across agendas. So no fixed stock of constraint *types* suffices: not pairwise, not $k$-wise, and not union bounds of ordinary sequents. (Revised after verification; the earlier wording "needs the full family" overstated this.)
* For agendas of "marginals on a hypergraph of variables", pairwise consistency suffices for all value assignments iff the hypergraph is acyclic (Vorob'ev 1962 [cited (u)]; the possibilistic/relational analogue is Beeri, Fagin, Maier & Yannakakis 1983 [cited]). §4.3 proves the possibilistic tree case.
* Deciding coherence of a credence on an arbitrary agenda (probabilistic satisfiability) is NP-complete (Georgakopoulos, Kavvadias & Papadimitriou 1988 [cited (u)]; cf. Pitowsky 1991 on correlation polytopes [cited (u)]). So the facet structure is genuinely complicated.

### 3.3 First-order credences, the Gaifman condition, and non-standard credences

Let $L$ be a countable first-order language. A function $P:\mathrm{Sent}_L\to[0,1]$ is **(Gaifman-)coherent** if:
* (G1) $P(\varphi)=1$ whenever $\vdash\varphi$;
* (G2) $P(\varphi\vee\psi)=P(\varphi)+P(\psi)$ whenever $\vdash\neg(\varphi\wedge\psi)$.

These imply $P(\varphi)=P(\psi)$ when $\vdash\varphi\leftrightarrow\psi$. (Apply (G2) to $\varphi\vee\neg\varphi$ and to $\psi\vee\neg\varphi$; both disjunctions are provable and both pairs are provably exclusive.) This is the notion used in the MIRI draft the user cites (Christiano et al. 2013 [cited]), following Gaifman (1964) [cited].

**Theorem 3.7 (coherent credences are mixtures of complete theories) [proved].** Let $S_L$ be the Stone space of complete consistent $L$-theories, with basic clopens $[\varphi]=\{T:\varphi\in T\}$. Then $P$ is coherent iff there is a (unique) Borel probability μ on $S_L$ with $P(\varphi)=\mu([\varphi])$. By Gödel completeness each $T\in S_L$ is $\mathrm{Th}(\mathfrak M_T)$ for a model $\mathfrak M_T$. So a coherent credence is the expected truth value of φ in a random model, drawn up to elementary equivalence.

*Proof.*
* (⇐) Clear.
* (⇒) By equivalence-invariance, $\mu_0([\varphi]):=P(\varphi)$ is well defined on the clopen algebra, which is isomorphic to the Lindenbaum–Tarski algebra (Stone). By (G1)–(G2) it is a finitely additive probability.
* *It is countably additive on the clopen algebra.* If $[\varphi]=\bigsqcup_n[\varphi_n]$ with disjoint clopens, then compactness of $[\varphi]$ and openness of the $[\varphi_n]$ imply that finitely many cover it, so all but finitely many are empty.
* Carathéodory extends $\mu_0$ uniquely to the σ-algebra generated by the clopens. This is the Borel σ-algebra, because there are countably many clopens and they form a basis. ∎

So the probabilistic version of the user's proposition holds verbatim: **a credence function is coherent iff there is a probability distribution over things it could be talking about.** The non-standard caveat holds too. If $T\supseteq\mathrm{PA}+\neg\mathrm{Con(PA)}$ is complete, then $\delta_T$ is coherent and gives probability 1 to every PA-theorem and every true quantifier-free sentence. It "believes" there is a proof of $0=1$.

**Theorem 3.8 (the Gaifman condition is a probabilistic ω-rule that pins true arithmetic) [proved; the probabilistic transcription of ω-completeness; essentially a consequence of Gaifman 1964 (credit added after verification). Gaifman showed that a probability satisfying the Gaifman condition is determined by its values on quantifier-free sentences (exact formulation (u)). Here those values are the true diagram of ℕ].** Work in the language of arithmetic. Let $P$ be coherent, let it give probability 1 to every true quantifier-free sentence, and let it satisfy the **Gaifman condition with respect to the numerals**:
$$P(\exists x\,\varphi(x))=\sup_n P\Big(\bigvee_{i\le n}\varphi(\underline i)\Big).$$
Then $P(\varphi)=1$ if $\mathbb N\models\varphi$ and $P(\varphi)=0$ otherwise. That is, $P=\delta_{\mathrm{Th}(\mathbb N)}$. No arithmetic axioms are needed.

*Proof.* By equivalence-invariance it suffices to treat sentences built from atomic sentences with ¬, ∧, ∃. Induct on the number of logical symbols, simultaneously for all sentences.
* *Atomic sentences* are quantifier-free. A true one has $P=1$. A false one has $P=1-P(\neg\cdot)=0$, because its negation is true and quantifier-free.
* *Negation:* $P(\neg\varphi)=1-P(\varphi)$.
* *Conjunction:* if $P(\varphi),P(\psi)\in\{0,1\}$, then coherence gives $P(\varphi)+P(\psi)-1\le P(\varphi\wedge\psi)\le\min(P(\varphi),P(\psi))$, which forces the min.
* *Existential:* the instances $\varphi(\underline i)$ have fewer logical symbols, since numerals are non-logical terms. By the induction hypothesis they get their truth values. By the conjunction case and de Morgan, $P(\bigvee_{i\le n}\varphi(\underline i))=\max_{i\le n}P(\varphi(\underline i))$. So the sup is 1 iff some $\varphi(\underline i)$ is true, iff $\mathbb N\models\exists x\varphi$, because every natural number is a numeral's value. ∎

**Corollary 3.9 (every logical inductor's limit is a non-standard credence) [proved modulo cited properties; proof revised after verification].** Let $\mathbb P$ be a logical inductor over a consistent r.e. theory $\Gamma\supseteq\mathrm{Q}$ in the language of arithmetic. Then its limit $\mathbb P_\infty$ violates the Gaifman condition with respect to the numerals.

*Proof.*
* By Garrabrant et al. (2016), Thm 4.1.2 "Limit Coherence" [cited; numbering from search snippets (u)], $\mathbb P_\infty$ exists and is coherent relative to Γ. So it gives 1 to every Γ-theorem, and in particular to every true quantifier-free sentence (Q proves them).
* If it also satisfied the Gaifman condition, Thm 3.8 would give $\mathbb P_\infty=\delta_{\mathrm{Th}(\mathbb N)}$. Either of two arguments refutes this.
* *Via non-dogmatism.*
  * By the Gödel–Rosser theorem, Γ is incomplete: some σ has Γ ⊬ σ and Γ ⊬ ¬σ. Let ψ be whichever of σ, ¬σ is false in ℕ. Then Γ ⊬ ¬ψ.
  * Non-Dogmatism (Garrabrant et al., Thm 4.6.2 [cited (u)]: if Γ ⊬ ¬φ then $\mathbb P_\infty(\varphi)>0$) gives $\mathbb P_\infty(\psi)>0=\delta_{\mathrm{Th}(\mathbb N)}(\psi)$.
* *Via Δ₂.*
  * A market is by definition a *computable* sequence of rational pricings (Garrabrant et al., Def 3.1.3 [cited; confirmed by search snippet, numbering (u)]). So "$\mathbb P_n(\varphi)>\frac12$" is decidable in $(n,\varphi)$.
  * If $\mathbb P_\infty=\delta_{\mathrm{Th}(\mathbb N)}$, then φ ∈ Th(ℕ) iff $\exists N\,\forall n\ge N\ \mathbb P_n(\varphi)>\frac12$ (Σ₂) iff $\forall N\,\exists n\ge N\ \mathbb P_n(\varphi)>\frac12$ (Π₂). The two agree because the limit exists and is 0 or 1. So Th(ℕ) would be Δ₂.
  * That contradicts Tarski's theorem that Th(ℕ) is not arithmetical [cited]. ∎

The Δ₂ argument proves more, with no reference to logical induction. **No limit-computable coherent credence that gives probability 1 to every true quantifier-free sentence satisfies the Gaifman condition** [proved: Thm 3.8 plus Tarski]. The quantifier-free hypothesis cannot be dropped. Let $T$ be the (decidable) theory of the one-element structure, where $S0=0=0+0=0\cdot0$. Then $\delta_T$ is computable and coherent, and it satisfies the Gaifman condition with respect to the numerals, because every element is a numeral's value. It fails only by giving $P(0=S0)=1$.

So the probabilistic "something" is always available (Thm 3.7). A *standard* something is fixed by an infinitary condition (Thm 3.8) that no limit-computable coherent credence giving probability 1 to all true quantifier-free sentences satisfies (Cor 3.9 and the remark above; sentence qualified after verification). This is the probabilistic face of Thm 5.7 below.

### 3.4 Preferences (the user's "vnm stuff?")

**Proposition 3.10 (finite VNM data: coherent iff a real utility exists) [proved modulo Motzkin's transposition theorem, cited].**
* *Data.* Let $X$ be a finite set of outcomes. The data are finitely many strict comparisons $p_i\succ q_i$ and weak comparisons $r_j\succsim s_j$ between lotteries in $\Delta(X)\subseteq\mathbb R^X$.
* *Coherence.* The data are EU-coherent if some $u\in\mathbb R^X$ has $u\cdot(p_i-q_i)>0$ and $u\cdot(r_j-s_j)\ge0$.
* *Claim.* The data are EU-incoherent iff there are $\lambda\ge0$ and $\kappa\ge0$, with λ not identically 0, such that $\sum_i\lambda_i(p_i-q_i)+\sum_j\kappa_j(r_j-s_j)=0$.

*Proof.* This is Motzkin's transposition theorem (1936) [cited] applied to the rows $p_i-q_i$ (strict) and $r_j-s_j$ (weak). ∎

*Reading.*
* The certificate is a derivation of "$L\succ L$" from the data by the VNM rules: mixing (independence) plus transitivity. Normalize the coefficients and mix the stated comparisons. By the independence axiom the mixed better-lottery is strictly preferred to the mixed worse-lottery, yet the two lotteries are equal.
* Such a certificate is **money-pump-like**. Calling it a money pump is an interpretive gloss, since no trading or payment structure is formalized (wording revised after verification).
* So VNM coherence on finite data is a weak completeness theorem. The "something being maximized" is a *real-valued* utility.
* Non-standard (lexicographic, non-Archimedean) utilities appear only with infinitely many comparisons (Hausner 1954 [cited (u)]). That is the same compactness phenomenon as $\{x\ge n\}$ in §1.5. The continuity axiom plays the role of the ω-rule.

---

## 4. Contexts: a completeness theorem for "true in the context at hand"

### 4.1 A monotone multi-context calculus

**Definition 4.0 (MCS).** Fix an index set $I$ of contexts. For each $i\in I$ fix:
* a language $L_i$;
* a class $M_i$ of local models with satisfaction $\models_i$;
* the local consequence $C_i=\mathrm{Th}_i\circ\mathrm{Mod}_i$. So local logics are assumed locally complete, e.g. classical propositional or first-order logic over $L_i$.
  * *(Revised after verification.)* A learned logic $C_i$ of §5 also qualifies, with Lindenbaum semantics in this form: $M_i=\mathrm{Fix}(C_i)\setminus\{L_i\}$, the *proper* closed theories, with $T\models_i\varphi$ iff $\varphi\in T$.
  * Then $\mathrm{Th}_i\circ\mathrm{Mod}_i=C_i$. If $C_i(X)\neq L_i$, then $C_i(X)$ is itself a model and the computation of Thm 1.4 applies. Otherwise $\mathrm{Mod}_i(X)=\emptyset$ and $\mathrm{Th}_i(\emptyset)=L_i$.
  * Thm 1.4's frame with *all* of $\mathrm{Fix}(C_i)$ does **not** qualify. The trivial theory $L_i$ satisfies every formula, so no falsum as in the last bullet can exist;
* local axioms $K_i\subseteq L_i$, the context's stipulations and imported background;
* a local falsum $\bot_i$ with $\mathrm{Mod}_i(\bot_i)=\emptyset$.
  * For a learned logic with the Lindenbaum semantics above, this means that $\bot_i$ is $C_i$-explosive: $C_i(\{\bot_i\})=L_i$, e.g. because ex falso is among the learned rules.
  * If it is not, read Cor 4.2 with "$T_i\neq L_i$" in place of "$\bot_i\notin T_i$" (see the remark after Cor 4.2).

**Bridge rules** have the form $b=(j_1{:}\varphi_1,\dots,j_n{:}\varphi_n\Rightarrow i{:}\psi)$ with $n\ge0$. The set of bridge rules may be infinite, e.g. schematic. Labelled formulas $i{:}\varphi$ are the McCarthy–Buvač $\mathrm{ist}(i,\varphi)$ (L7 §2).

**Calculus MC.** For a set Γ of labelled premises, let $\mathrm{Der}(\Gamma)=(T_i)_{i\in I}$ be the least family with:
* $T_i\supseteq K_i\cup\Gamma_i$, where $\Gamma_i=\{\varphi:i{:}\varphi\in\Gamma\}$;
* each $T_i$ is $C_i$-closed (rule Loc);
* closure under bridges (rule Br): if $\varphi_k\in T_{j_k}$ for all $k$, then $\psi\in T_i$.

It exists because the family of such families is closed under componentwise intersection. Write $\Gamma\vdash_{\rm MC}i{:}\varphi$ iff $\varphi\in T_i$. When the $C_i$ are finitary this is derivability by finite trees.

**Local-models (LMS) semantics** (Ghidini & Giunchiglia 2001, simplified [cited]).
* A **chain** is $c=(c_i)_{i\in I}$ with $c_i\subseteq M_i$: a *belief state*, i.e. the set of local models the context leaves open.
* $c\models i{:}\varphi$ iff every $m\in c_i$ satisfies φ. So an empty $c_i$ satisfies everything: an "ill-posed" context, as in L7 Prop 2.
* $c$ is a **model** if $c\models i{:}\varphi$ for all $\varphi\in K_i$ and $c$ is **bridge-compatible**: for every bridge rule, if $c\models j_k{:}\varphi_k$ for all $k$ then $c\models i{:}\psi$.
* $\Gamma\models_{\rm LMS}i{:}\varphi$ iff every model $c\models\Gamma$ has $c\models i{:}\varphi$.

**Theorem 4.1 (soundness and completeness; the canonical chain) [proved].** Let $c^\Gamma_i:=\mathrm{Mod}_i(T_i)$, where $(T_i)=\mathrm{Der}(\Gamma)$.
* (a) $c^\Gamma$ is a model of the MCS and of Γ.
* (b) Every model $c\models\Gamma$ has $c_i\subseteq c^\Gamma_i$ for all $i$. So $c^\Gamma$ is the *largest* (least committal) model.
* (c) $\Gamma\vdash_{\rm MC}i{:}\varphi\iff\Gamma\models_{\rm LMS}i{:}\varphi$.

*Proof.*
* (a) $c^\Gamma\models i{:}\varphi$ iff $\mathrm{Mod}_i(T_i)\subseteq\mathrm{Mod}_i(\varphi)$ iff $\varphi\in\mathrm{Th}_i\mathrm{Mod}_i(T_i)=C_i(T_i)=T_i$.
  * Hence $c^\Gamma$ satisfies $K$ and Γ.
  * It is bridge-compatible: if $c^\Gamma\models j_k{:}\varphi_k$ for all $k$, then $\varphi_k\in T_{j_k}$, so ψ ∈ $T_i$ by (Br), so $c^\Gamma\models i{:}\psi$.
* (b) Let $c\models\Gamma$ be a model and put $U_i=\mathrm{Th}_i(c_i)$.
  * Each $U_i$ is $C_i$-closed (soundness of $C_i$) and contains $K_i\cup\Gamma_i$.
  * The family is closed under bridges: if $\varphi_k\in U_{j_k}$, then $c\models j_k{:}\varphi_k$, so $c\models i{:}\psi$, i.e. ψ ∈ $U_i$.
  * By leastness $T_i\subseteq U_i$, so every $m\in c_i$ satisfies $T_i$, i.e. $c_i\subseteq c^\Gamma_i$.
* (c) (⇒) By (b), $c\models i{:}\varphi$ for all φ ∈ $T_i$. (⇐) If φ ∉ $T_i$, then $c^\Gamma\not\models i{:}\varphi$ by (a). ∎

**Corollary 4.2 (context coherence iff existence) [proved].** Let $D\subseteq I$ be the **designated** contexts: the actual context @, observations, and idealized contexts used for export. Then the system with premises Γ is **D-coherent** ($\Gamma\nvdash_{\rm MC}i{:}\bot_i$ for every $i\in D$) iff there is a model $c\models\Gamma$ with $c_i\neq\emptyset$ for all $i\in D$.

*Proof.* $\bot_i\in T_i$ iff $c^\Gamma_i=\emptyset$, by Thm 4.1(a). If some model is nonempty on $D$, then so is $c^\Gamma$, since $c_i\subseteq c^\Gamma_i$ by 4.1(b). ∎

*Remark (learned local logics; added after verification).* With the Lindenbaum semantics of Def 4.0, $M_i=\mathrm{Fix}(C_i)\setminus\{L_i\}$, the same proof gives, with no falsum at all: $T_i\neq L_i$ iff $c^\Gamma_i\neq\emptyset$. The reason is that $\mathrm{Mod}_i(T_i)\neq\emptyset$ iff the closed set $T_i$ is proper.
* So for a learned local logic, Cor 4.2 holds with D-coherence read as **non-triviality** of $T_i$ at each $i\in D$.
* This coincides with "$\bot_i\notin T_i$" exactly when $\bot_i$ is $C_i$-explosive. Otherwise the two come apart: with $R=\emptyset$ and $K_i=\{\bot_i\}$, $\bot_i$ is derivable, yet $c^\Gamma_i\ni\{\bot_i\}$ is nonempty.
* [checked: `repair_checks.py` (B), 3,000 random finite closure systems with an explosive falsum, 0 violations, plus the non-explosive counterexample]

Non-designated contexts, such as suppositions under reductio, may have $c_i=\emptyset$. They are then "about nothing", and that is what a successful reductio shows. This is T2 §7's designation discipline as an existence theorem.

**Proposition 4.3 (the canonical chain is the grounded equilibrium) [proved].** Call a belief state $S=(S_i)$ an **equilibrium** if
$$S_i=C_i\Big(K_i\cup\Gamma_i\cup\{\psi:(\cdots\Rightarrow i{:}\psi)\text{ has all premises in }S\}\Big)$$
(Brewka & Eiter 2007, with monotone bridges and $\mathrm{ACC}_i(kb)=\{C_i(kb)\}$ [cited (u)]). Then:
* (a) $\mathrm{Der}(\Gamma)$ is the least equilibrium;
* (b) there is an equilibrium consistent at every $i\in D$ iff the system is D-coherent.

*Proof.*
* (a) $T=\mathrm{Der}(\Gamma)$ contains the right-hand side $R(T)$ and is $C_i$-closed, so $T\supseteq R(T)$.
  * $R(T)\subseteq T$ contains $K\cup\Gamma$, is closed, and is bridge-closed: a rule whose premises lie in $R(T)\subseteq T$ is applicable in $T$, so its head is in $R(T)$.
  * So $T\subseteq R(T)$ by leastness, and $T$ is an equilibrium.
  * Any equilibrium $S$ is closed, contains $K\cup\Gamma$ and is bridge-closed, so $S\supseteq T$.
* (b) Any equilibrium contains $T$, so a D-consistent equilibrium forces $T$ to be D-consistent. Conversely, $T$ itself is an equilibrium. ∎

**Proposition 4.4 (non-monotone bridges break existence) [proved; TOSU; wording revised after verification].** Let context $i$ have consistent $K_i$ with $K_i\nvdash p$, and the single bridge rule "$i{:}p$ if not $i{:}p$" (negation as failure). Then $K_i$ is consistent (the context is coherent without its bridge), yet there is no equilibrium.
* If $p\in S_i$, the rule is inapplicable and $S_i=C_i(K_i)\not\ni p$.
* If $p\notin S_i$, the rule fires and $p\in S_i$.

So existence for default-style bridges needs an extra condition, such as stratification or the absence of odd loops through negation as failure. Coherence alone does not supply it, and stratification is sufficient, not necessary.

*Relation to L7's context-tree calculus (L7 §8) [sketch; revised after verification].*
* L7's calculus has stipulations (local axioms), imports $\pi(c){:}\varphi\Rightarrow c{:}\varphi$ for φ in the import filter $F_c$, discharge $c{:}\psi\Rightarrow\pi(c){:}A\to\psi$, and side-conditioned export $c{:}\varphi_\beta(t),\ \pi(c){:}\sigma_\beta(t)\Rightarrow\pi(c){:}\varepsilon_\beta(t)$. All of these are monotone bridge rules. So it is an MC system.
* Thm 4.1 is its completeness theorem for local-models semantics *with bridges read as compatibility constraints*. In that semantics an exported ε shrinks the parent's belief state $c^\Gamma_{\pi(c)}$.
* L7 §8.2 uses a different semantics. There $\mathrm{Mod}(@)=\mathrm{Mod}(K\cup O)$ and $\mathrm{Mod}(\pi(c))$ do not depend on exports, and bridges are required to be *sound*. L7 Prop 1 proves soundness for that semantics, assuming that every Step and Exp instance is sound.
* **The two semantics coincide** when the local consequence is the complete base logic and every Step and Exp instance is sound. Then $T_c=\mathrm{Th}(\mathrm{Mod}_{\rm L7}(c))$ for every $c$:
  * ⊆ is L7 Prop 1.
  * ⊇ is by induction down the tree. At @, local completeness gives $T_@\supseteq C(K\cup O)$. An IDL child imports $F_c\cap T_{\pi(c)}=\mathrm{Imp}^\*(c)$. A SUP child imports all of $T_{\pi(c)}$ and has $A$.
  * Hence $c^\Gamma_c=\mathrm{Mod}_{\rm L7}(c)$.
* Without that hypothesis the two differ. Suppose an unsound export yields $@{:}Q=5$ while $K\cup O$ proves $Q=3$. Then MC derives $@{:}\bot$ and $c^\Gamma_@=\emptyset$, as LMS completeness requires, while L7's $\mathrm{Mod}(@)$ stays nonempty.
* For SUP contexts with full import, the canonical chain always satisfies $c^\Gamma_c=c^\Gamma_{\pi(c)}\cap\mathrm{Mod}(A)$, the analogue of L7's $\mathrm{Mod}(c)$.

### 4.2 Rules of proof versus conditionals between worlds

A **world family** is $w=(w_i)$ with each $w_i\in M_i$ a *single* local model, satisfying $K_i$, and satisfying each bridge rule *as a material conditional*: if $w_{j_k}\models\varphi_k$ for all $k$, then $w_i\models\psi$. Write $\models_W$ for consequence over world families.

**Theorem 4.5 [proved; `mcs_completeness.py`].**
* (a) $\models_{\rm LMS}\subseteq\models_W$: a world family is a model chain of singletons.
* (b) The inclusion is strict in general. Let $K_j=\{p\vee q\}$, $K_i=\{\neg r\}$, with bridges $j{:}p\Rightarrow i{:}r$ and $j{:}q\Rightarrow i{:}r$.
  * MC does not derive $i{:}\bot$: the canonical chain has $T_j=C(p\vee q)$, no bridge fires, and $c^\Gamma_i=\mathrm{Mod}(\neg r)\neq\emptyset$.
  * There is no world family: $w_j$ satisfies $p$ or $q$, so $w_i\models r$, contradicting $\neg r$.
* (c) For classical propositional local logics, $\models_W$ is classical consequence in the disjoint union of the local languages ($i{:}\varphi\mapsto\varphi^{(i)}$, atoms tagged by context). The axioms are the tagged local axioms $K_i^{(i)}$ together with the bridge axioms $\bigwedge_k\varphi_k^{(j_k)}\to\psi^{(i)}$, and the premises Γ are tagged in the same way (tagged $K_i$ and Γ made explicit after verification). This is the "eternalist" translation.

*Proof.* (a) Check the definitions. (b) As stated. (c) World families are exactly the Boolean valuations of the tagged language that satisfy the tagged $K_i$ and the tagged bridge axioms. Apply CPC completeness. ∎

*Status (added after verification).* Thm 4.5 is the context-logic instance of a standard distinction: a rule of proof versus the corresponding conditional, i.e. global versus local consequence. In belief-state semantics $c\models j{:}\varphi$ is a box over $c_j$. Thm 4.5(b) is then the familiar failure of □ to distribute over ∨: □(p∨q) ⊭ □p ∨ □q. This gap is also why Ghidini & Giunchiglia use *sets* of local models. What is new here is only its use as a criterion for physics bridges.

The script checks Thm 4.1(c) and Cor 4.2 by brute force on 400 random three-context systems, with 4 local models each and random bridges and premises: there are no mismatches. It also finds 2,348 (context, formula) pairs where world-family entailment strictly exceeds belief-state entailment.

*Reading.* MC treats a bridge as a **rule of proof**: "export what context $j$ *establishes*". The tagged theory treats it as a **conditional between worlds**: "whatever world $j$ is about, if φ holds there then ψ holds in $i$'s world". Only the first is right for idealized contexts.
* A physics bridge ("if the idealized model establishes $Q=q$, then in the world $Q\approx q\pm\varepsilon$") is certified for claims the idealization *establishes*. It is not certified for case splits over the idealization's undetermined possibilities.
* Under the conditional reading, an idealization that settles only $p\vee q$ would export $r$ by reasoning by cases over idealized worlds that are not the actual one.
* So "a context makes sense iff there is something it could be about" holds with *belief states* as the somethings (Cor 4.2). It can fail with *worlds* as the somethings (Thm 4.5(b)).

### 4.3 Local coherence versus a global world

Even with the world reading, the user's worry about "many frames … needn't be easily reconcilable" (L10 §1.3) has a precise form.

**Theorem 4.6 (local-to-global on trees) [proved; essentially the propositional join-tree / iterated Robinson-consistency argument (cf. Beeri et al. 1983); checked by `contexts_local_global.py` (a) on one fixed 3-node path cover with 7,131 random local theory systems, and (a2) on 2,000 random tree covers with 2–5 nodes, plus a negative control (description corrected after verification)].** Set up as follows.
* The contexts are the vertices of a finite tree $\mathcal T$.
* Context $i$ is classical propositional over an atom set $A_i$ with a consistent closed theory $T_i$.
* **Running intersection:** for each atom $a$, $\{i:a\in A_i\}$ is connected in $\mathcal T$.
* **Mutual conservativity on edges:** for adjacent $i,j$, $T_i\cap L(A_i\cap A_j)=T_j\cap L(A_i\cap A_j)$.

Then every model of every $T_i$ extends to a global valuation satisfying all $T_j$. In particular $\bigcup_iT_i$ is consistent.

*Proof.*
* *Projection lemma.* For consistent $T$ over $A$ and $B\subseteq A$: $\mathrm{Mod}(T)|_B=\mathrm{Mod}_B(T\cap L(B))$.
  * ⊆ is clear.
  * For ⊇: if a $B$-valuation $w$ satisfies $T\cap L(B)$ but $T\cup\{\text{literals of }w\}$ is inconsistent, compactness gives $T\vdash\neg(l_1\wedge\dots\wedge l_r)$ with $l_k$ literals true in $w$. That is a $B$-consequence of $T$ false in $w$, a contradiction.
* So mutual conservativity says $\mathrm{Mod}(T_i)|_{A_i\cap A_j}=\mathrm{Mod}(T_j)|_{A_i\cap A_j}$.
* Root the tree at $i_0$, with $m_{i_0}\models T_{i_0}$ given. Visit vertices in breadth-first order. When visiting $c$ with parent $p$, the atoms of $A_c$ already assigned lie in $A_c\cap A_p$: by running intersection, any such atom lies on the path from $c$ to a visited context, and that path passes through $p$.
* The current assignment restricted to $A_c\cap A_p$ is $m_p|_{A_c\cap A_p}\in\mathrm{Mod}(T_p)|_{A_c\cap A_p}=\mathrm{Mod}(T_c)|_{A_c\cap A_p}$. So some $m_c\models T_c$ agrees with it, and we extend the assignment by $m_c$.
* The final assignment satisfies every $T_c$. ∎

**Proposition 4.7 (the frustrated triangle: cycles break it) [proved; `contexts_local_global.py` (b),(c)].** Take contexts on atoms $\{a,b\},\{b,c\},\{c,a\}$ with $T_{ab}=\mathrm{Cn}(a\leftrightarrow\neg b)$, $T_{bc}=\mathrm{Cn}(b\leftrightarrow\neg c)$ and $T_{ca}=\mathrm{Cn}(c\leftrightarrow\neg a)$.
* Each theory is consistent.
* Each pair is mutually conservative on its single shared atom: both have only tautologies in that atom.
* The union is inconsistent, being an odd cycle of negations.

The probabilistic version: the marginals on each pair are uniform on $\{01,10\}$. They agree on every single-variable marginal (all 1/2), but no joint distribution has them (LP-infeasible).

This is Specker's parable (1960) in logical form, and the simplest instance of what Abramsky & Brandenburger (2011) [cited] call *contextuality*: local sections that agree on overlaps but admit no global section. Vorob'ev (1962) and Beeri et al. (1983) [cited] show that acyclicity of the cover is exactly what rules this out.

*Reading for physics contexts.*
* An olympiad solution's contexts (idealizations, sub-models) need not jointly describe one world, and need not even be pairwise reconcilable into one.
* Cor 4.2 guarantees a *family of local belief states, nonempty at every designated context*, whenever the designated contexts are coherent. Non-designated (suppositional) contexts may be forced empty. That is the right "something" for a context system.
* Demanding a single world for all contexts at once is a strictly stronger, cover-dependent requirement. It holds automatically only on tree-like covers with conservative overlaps.

### 4.4 "True in the context at hand"

**Definition 4.8.** Given a context system (MC with designated set $D\ni@$) and accepted premises Γ:
* **φ is true in context $c$** iff $\Gamma\vdash_{\rm MC}c{:}\varphi$. By Thm 4.1, equivalently, φ holds in every local model that $c$'s canonical belief state leaves open. It is supervaluational truth over the context's admissible local models: "admissible completions of the intended model" (L7).
* **φ is true *enough* in $c$** for a world claim ε (revised after verification: clauses (i) and (ii) were missing) iff:
  * (i) φ is true in $c$, i.e. $\Gamma\vdash_{\rm MC}c{:}\varphi$;
  * (ii) some bridge $c{:}\varphi\Rightarrow @{:}\varepsilon$ is in the system, possibly with side conditions σ at @, and its side conditions hold in the actual world. For a checker: $\Gamma\vdash_{\rm MC}@{:}\sigma$;
  * (iii) that bridge is **sound**: whenever the canonical state of $c$ establishes φ and the side conditions hold in the actual world, ε holds in the actual world (L7 §8.2).

*What this buys.* "True in the context at hand" is not truth in the world, and not mere derivability in an arbitrary string game. It is truth in all local models of a canonically determined belief state. By Thm 4.1, a checker that accepts exactly MC-derivations accepts exactly the claims that are true in this sense. That answers the user's "wtf is that???" with a semantics plus a completeness theorem.

What this does *not* buy is the justification of bridges. Bridge soundness is a world-relative property. It is certified, as in L7 §9, by stability arguments or world feedback, not by coherence. Coherence can only demand $c^\Gamma_i\neq\emptyset$ at designated contexts (Cor 4.2).

---

## 5. Learned rules: what coherence buys, and what pins the model down

### 5.1 Coherence on designated contexts buys a (syntactic) model

Let $R$ be a learned set of rule schemas. Write $C_R$ for the least structural finitary consequence operation containing $R$ (single-conclusion), or $\langle R\rangle$ for the least structural Scott relation (bilateral). Let 𝒜 be the designated contexts, certified $R$-coherent: $\bot\notin C_R(A)$, or $A\nvdash_R D$ for bilateral positions $[A:D]$. As in T2, this is all the learner knows.

**Theorem 5.1 (what coherence buys) [proved].** For each designated $A$:
* (a) there is a $C_R$-theory $T\supseteq A$ that is maximal among theories omitting ⊥ (Lindenbaum; Thm 1.5(a));
* (b) the **Lindenbaum matrix** $\langle\mathrm{Fm},T\rangle$ validates every rule of $C_R$ under every assignment, and the identity assignment designates all of $A$ and not ⊥ (Wójcicki 1988; Łoś & Suszko 1958 [cited]);
* (c) bilaterally: for every designated coherent position $[A:D]$ there is $v\in\mathrm{Val}\langle R\rangle$ realizing it, and $L_v$ is a matrix model (Thm 2.6).

So *if a learned mode of talking is coherent on a context, there is something it is talking about there*: a model of the learned rules in which the context's claims are true.

*Proof.*
* (a) is Thm 1.5(a) applied to the closed set $C_R(A)$ and σ = ⊥.
* (b) $\langle\mathrm{Fm},T\rangle$ validates $\Gamma\rhd\varphi$ iff $\sigma\Gamma\subseteq T\Rightarrow\sigma\varphi\in T$ for every substitution σ. That holds because $\sigma\varphi\in C_R(\sigma\Gamma)\subseteq C_R(T)=T$ by structurality.
* (c) is Thm 2.2 plus Thm 2.6. ∎

*Note.* The proof of (b) does not use the maximality from (a). It works for any $C_R$-theory $T\supseteq A$ omitting ⊥, e.g. $C_R(A)$ itself. Maximality matters only for the reduction results of §5.2.

The model's universe, however, *is the language*. This is the "degenerate" model, and it is the formal content of the user's worry that the something may exist only "in the same sense that there is a 'proof' of the Gödel sentence". The next result says when this syntactic something is the intended one.

### 5.2 Identifying indiscernibles: when the syntactic model is the intended one

For a matrix $\langle\mathbf A,D\rangle$, the **Leibniz congruence** $\Omega_{\mathbf A}(D)$ is the largest congruence θ of $\mathbf A$ **compatible** with $D$: $a\,\theta\,b$ and $a\in D$ imply $b\in D$. It exists because the join of compatible congruences is compatible: each step in a chain $a=c_0\,\theta_1\,c_1\cdots c_r=b$ preserves membership in $D$. The **reduction** is $\langle\mathbf A/\Omega,D/\Omega\rangle$, i.e. "identify elements no formula context can tell apart" (Blok & Pigozzi 1989; Font 2016 [cited]).

**Theorem 5.2 (the syntactic model collapses to the intended one) [proved].**
* **(a)** Let $h:\mathrm{Fm}\to\mathbf A$ be a *surjective* homomorphism (a generating valuation) and $T=h^{-1}(D)$. Then
  $$\langle\mathrm{Fm}/\Omega(T),\,T/\Omega(T)\rangle\ \cong\ \langle\mathbf A/\Omega_{\mathbf A}(D),\,D/\Omega_{\mathbf A}(D)\rangle.$$
  In particular, if $\langle\mathbf A,D\rangle$ is reduced, the reduced Lindenbaum matrix of $T$ *is* $\langle\mathbf A,D\rangle$.
* **(b)** In CPC, every maximal consistent theory has reduced Lindenbaum matrix $\cong\langle\mathbf 2,\{1\}\rangle$.

*Proof.*
* (a) *Claim: $\Omega(T)=h^{-1}(\Omega_{\mathbf A}D)$.*
  * $h^{-1}(\Omega_{\mathbf A}D)$ is a congruence of Fm compatible with $T$: if $(a,b)$ is in it and $a\in T$, then $ha\in D$ and $ha\,\Omega\,hb$, so $hb\in D$ and $b\in T$.
  * Maximality. Let θ′ be any congruence compatible with $T$. Then $\ker h$ is compatible with $T$ (since $T$ is a union of $\ker h$-classes), so $\theta''=\theta'\vee\ker h$ is compatible.
  * Its image $\theta_{\mathbf A}=\{(ha,hb):(a,b)\in\theta''\}$ is a congruence of $\mathbf A$:
    * reflexive, by surjectivity;
    * transitive, because $hb=hb'$ implies $b\,\theta''\,b'$, as $\ker h\subseteq\theta''$;
    * compatible with the operations, because $h$ is a homomorphism.
  * $\theta_{\mathbf A}$ is compatible with $D$, so $\theta_{\mathbf A}\subseteq\Omega_{\mathbf A}D$. Hence $\theta'\subseteq\theta''\subseteq h^{-1}(\Omega_{\mathbf A}D)$.
  * The isomorphism is then $[a]\mapsto[ha]$. It is well defined and injective by the claim, surjective since $h$ is, and it maps $T/\Omega$ onto $D/\Omega$ because $a\in T$ iff $ha\in D$.
* (b) A maximal consistent $T$ is $v^{-1}(1)$ for a Boolean homomorphism $v:\mathrm{Fm}\to\mathbf 2$. This $v$ is onto, because $p\vee\neg p\mapsto1$ and $p\wedge\neg p\mapsto0$. The matrix $\langle\mathbf 2,\{1\}\rangle$ is reduced, because the only other congruence of $\mathbf 2$ identifies 0 with 1. Apply (a). ∎

**Proposition 5.3 (what the points of a finite-matrix logic talk about) [proved, modulo the standard finitarity of finite-matrix logics].** Let $C$ be the consequence of a single finite matrix $\langle\mathbf A,D\rangle$; such a $C$ is finitary [cited, standard]. Then every point $P$ of $C$ has reduced Lindenbaum matrix isomorphic to the reduction of $\langle h(\mathrm{Fm}),D\cap h(\mathrm{Fm})\rangle$ for some homomorphism $h$. In other words, it is *the reduction of a generated submatrix* of $\langle\mathbf A,D\rangle$: a strict homomorphic image of a submatrix, not necessarily itself a submatrix (wording corrected after verification). Up to isomorphism there are finitely many.

*Proof.* By Thm 1.5(b), applied to the frame whose models are homomorphisms $h:\mathrm{Fm}\to\mathbf A$, every point is $h^{-1}(D)$ for some $h$. Apply Thm 5.2(a) to $h$ onto its image. ∎

So for classical logic, everything a coherent position can be about is, after identifying indiscernibles, the two truth values. Coherence pins the intended semantics.

*Why (revised after verification).* Every point of CPC is maximal (the proof-by-cases argument after Prop 1.6), and maximal theories are Boolean (Thm 5.2(b)). Carnap categoricity for bilateral data (T2 Thm 4.4) supplies the bilateral side.
* The earlier text credited this to Post-completeness (T2 Thm 3.1). It also claimed that for non-Post-complete calculi "distinct coherent completions talk about non-isomorphic things". That claim is false as stated.
* Counterexample: IPC is not Post-complete, yet by Prop 1.6 every maximal IPC-consistent theory is a maximal CPC theory, and so it reduces to **2**.
* What can differ is the *non-maximal points*: a calculus can have points that talk about non-isomorphic things (Ex 5.4).
* Level P3 in the table of §5.4 is accordingly a condition on all points, not on Post-completeness.

**Example 5.4 (the Kripkenstein residue as a set of things talked about) [proved; uses cited algebraizability of IPC].**
* *IPC.* Let $h:\mathrm{Fm}\to\mathbf H_3$ be onto the three-element Heyting chain $0<\frac12<1$, e.g. $h(p)=\frac12$. Then $T=h^{-1}(1)$ is a prime, non-maximal theory, since $p\vee\neg p\mapsto\frac12$.
  * $\langle\mathbf H_3,\{1\}\rangle$ is reduced. Identifying $\frac12$ with 1 breaks compatibility. Identifying 0 with $\frac12$ forces $(0\to0)\,\theta\,(\frac12\to0)$, i.e. $1\,\theta\,0$.
  * $T$ is a point of IPC: it is maximal among theories omitting $p$. Take any ψ ∉ T. If $h(\psi)=\frac12$, then $\psi\leftrightarrow p\in T$. If $h(\psi)=0$, then $\neg\psi\in T$. Either way, adding ψ yields $p$.
  * So this coherent intuitionistic position talks about the three-element chain, while maximal positions talk about **2** (Prop 1.6). Different points of the same coherent logic are about genuinely different structures.
* *Quantifier swap.* FOL with equality plus the schema $\forall x\exists yR/\exists y\forall xR$ is coherent (T2 §6), and its models are exactly the one-element structures. What the learned fallacy is "about" is the singleton world. A designated context with two distinct objects kills it, because it has no singleton model.

In general, consider multiple-conclusion hypotheses. By Thms 2.2, 2.4 and 2.6(a), T2 Thm 6.4's residue $\mathrm{Alt}(h^\*,\mathcal A)$ of coherent uniform alternatives corresponds exactly to the closed, substitution-invariant sets $V\subseteq\mathrm{Val}(h^\*)$ that realize every designated position. **Non-identifiability of meaning is non-uniqueness of the thing talked about.**

### 5.3 First-order term models and prime models

For a consistent first-order theory, the Lindenbaum construction becomes Henkin's (Henkin 1949 [cited]):
* add witness constants;
* extend to a complete Henkin theory $T^\*$;
* take closed terms modulo $T^\*$-provable equality.

That last step is the Leibniz reduction. The user's DLK note (`ai/DLK/logic.md`) says: "any assignment of truth-values to sentences which does not violate inference rules can be extended to a full model … this is cool because a model also needs to assign actual functions and objects". This is correct for complete consistent assignments. The objects are equivalence classes of witness terms, and the functions are term formation. That is a precise answer to his "can we think about this in model-theoretic terms? i.e. ML model has a model attached to it?".

There is one caveat. If the assignment makes $\exists x\varphi(x)$ true but $\varphi(c)$ false for every *named* $c$ (an ω-inconsistent assignment), the model must contain unnamed objects. This is the Gaifman failure of §3.3.

**Theorem 5.5 (prime models: what a complete arithmetic talks about) [cited, standard; e.g. Kaye 1991 (u) for presentation].**
* PA has definable Skolem functions (least-number principle). So for every complete consistent $T\supseteq\mathrm{PA}$, the parameter-free definable elements of any model of $T$ form an elementary submodel $\mathcal K(T)$.
* $\mathcal K(T)$ is the **prime model** of $T$: unique up to isomorphism, and elementarily embeddable in every model of $T$.
* $\mathcal K(\mathrm{Th}(\mathbb N))=\mathbb N$.
* If $T\ni\neg\mathrm{Con(PA)}$, then $\mathcal K(T)$ is non-standard. Indeed "the least code of a PA-proof of $0=1$" is definable. $T$ refutes each standard instance $\mathrm{Prf}(\underline n,\ulcorner0{=}1\urcorner)$, because its negation is a true Δ₀ sentence (assuming PA is consistent) and hence provable in Q ⊆ T.

*Reading.* This is the most precise version of the user's footnote ("there might only be such a thing in the same sense that there is a 'proof' of the Gödel sentence G"). The complete coherent theory $T$ has a *canonical* thing it talks about: exactly the objects it can define. The "proof" is one of them, a definable non-standard number.

### 5.4 Two layers of non-standardness, and two barriers

The non-standard caveat is really two different phenomena.
* **Layer (i): coherent but false.** PA + ¬Con(PA) is consistent (Gödel II) and false. It is even Π₁-sound (L4 Prop 3.1). This is *finitary*: a single sentence. It comes from the incompleteness of the calculus relative to the intended model. Coherence is not truth (T2 Thm 3.10(b)).
* **Layer (ii): true but not categorical.** Th(ℕ) itself has non-standard models. This is a *limit* phenomenon from compactness. Every finite part of a true theory is about ℕ, but no first-order totality pins ℕ.

**Levels of pinning.** For a mode of talking (a theory or a calculus) with model class $\mathcal M$:

| level | name | for theories | for logics / learned calculi |
|---|---|---|---|
| P0 | coherent | $\mathcal M\neq\emptyset$ | $\mathrm{Val}\neq\emptyset$ on designated contexts |
| P1 | complete | all models elementarily equivalent | Post-complete (T2 Thm 3.1) |
| P2 | κ-categorical | unique model of size κ (e.g. DLO, ℵ₀; Cantor) | — |
| P3 | categorical | unique model up to isomorphism | all points reduce to one matrix (Thm 5.2(b), Prop 5.3) |

**Theorem 5.6 (compactness barrier) [cited; Löwenheim–Skolem–Tarski].** A first-order theory with an infinite model has models of every infinite cardinality $\ge|L|$. So no first-order mode of talking reaches P3 for an infinite structure.

By contrast, every finite structure in a finite language is characterized up to isomorphism by a single first-order sentence [cited, standard]. Consider the user's icosahedron example (`math is a mere string game iff everything is.md`). After the physical icosahedron explodes, the mode of talking remains coherent, and the thing talked about is *pinned up to isomorphism*. The non-standard caveat bites only for infinite objects.

**Theorem 5.7 (computability barrier: "coherent iff an *intended* model exists" forces Π₁ existence) [proved; TOSU. This is the standard argument "a complete r.e. calculus makes semantic consequence r.e.", applied here to the coherence slogan (status corrected after verification). The corollaries cite MRDP, Tarski and Trakhtenbrot].** Let $S$ be a decidable set of finite syntactic objects, and $K$ an intended class of models. Suppose some calculus has an r.e. set of incoherent finite sets, and that a finite $X\subseteq S$ is incoherent iff $X$ has no model in $K$. Then $\{X\text{ finite}:X\text{ has a }K\text{-model}\}$ is co-r.e. (Π₁). Consequently:
* (a) $K=\{\mathbb N\}$ (sentences of arithmetic): impossible. $\{X:\mathbb N\models\bigwedge X\}$ is computably equivalent to Th(ℕ), which is not even arithmetical (Tarski).
* (b) Diophantine equations, $K=\{\mathbb Z\}$: impossible. Solvability is Σ₁-complete (MRDP: Matiyasevich 1970, building on Davis–Putnam–Robinson), so it is not Π₁.
* (c) First-order sentences in a vocabulary containing at least one binary relation symbol, $K$ = finite structures: impossible. Finite satisfiability is Σ₁ and undecidable (Trakhtenbrot 1950), so it is not Π₁. (Vocabulary hypothesis added after verification. For purely monadic vocabularies, finite satisfiability is decidable, by the finite model property of monadic FOL, and there is no barrier.)
* (d) First-order sentences, $K$ = all structures: satisfiability is Π₁, consistent with Gödel completeness. Polynomial equations with $K=\bar k^n$: decidable (Gröbner bases), consistent with the Nullstellensatz.

*Proof.* "No $K$-model" equals "incoherent", which is r.e., so its complement is co-r.e. For (a)–(c): a Σ₁ set that is also Π₁ is decidable, which contradicts the cited undecidability results. Th(ℕ) is not even Π₁. ∎

*Reading.* This is the non-standard caveat as a theorem. **For any computable notion of coherence, "coherent iff there is something it could be talking about" can hold only if *having such a something* is a Π₁ property.** "Having a model of any kind" is Π₁, so Gödel's theorem is possible. "Having the standard model", "having an integer solution" and "having a finite model" (in a vocabulary with a binary relation symbol) are not, so no computable coherence notion matches them. The proposition is true exactly to the extent that "something" is construed liberally.

**Proposition 5.8 (anchoring pins exactly the definable vocabulary) [cited: Beth 1953; the reading is ours].** Let $L_o\subseteq L$ be an "anchored" (observational, world-hooked) vocabulary and $T$ an $L$-theory. Say $T$ **pins $L$ given $L_o$** if any two models of $T$ with the same universe and the same $L_o$-interpretation are identical. By Beth's definability theorem, $T$ pins $L$ given $L_o$ iff every symbol of $L$ is explicitly $T$-definable from $L_o$.

*Reading (revised after verification).* Beth's theorem quantifies over *all* models of $T$, i.e. over every possible anchoring structure.
* So world-anchoring (fixing the world's interpretation of the hooked vocabulary) determines what the rest of the language talks about *uniformly, whatever the anchoring structure turns out to be*, iff the rest is definable from the hooked part.
* Over the *actual* anchoring structure, pinning can hold without definability. Example: $L_o=\{<\}$, and $T$ says that $R$ is a nonempty initial segment with no largest element.
  * Over $(\mathbb N,<)$ the only expansion is $R=\mathbb N$, so this anchoring pins $R$.
  * Over $\omega+\omega$, both $R=\omega$ and $R={}$everything satisfy $T$, so $R$ is not $T$-definable from $<$.
  * A trivial variant: $T=\{\exists!x\,R(x)\}$ over a one-element world.
* Definability relative to a *fixed* structure, possibly with parameters, is the subject of Svenonius- and Chang–Makkai-type theorems [cited (u)].
* So theoretical terms that are not definable are multiply realizable over *some* anchoring, though possibly not over the actual one. This is the Ramsey–Lewis–Newman situation (Lewis 1970 [cited]).

### 5.5 "How are the natural numbers pinned down?"

The user asks: "how are the natural numbers pinned down? … is there a way they are the 'lowest-complexity-structure' which satisfy some axioms??" (`philosophy/questions/how are the natural numbers pinned down?.md`). Coherence (P0) and first-order completeness (P1) cannot do it (Thms 5.6–5.7). The known pin-downs, with what each adds:

1. **Second-order induction: Dedekind (1888)** [cited]. Second-order PA with full semantics is categorical.
   * *Adds:* quantification over *all* subsets.
   * *Price:* no complete r.e. calculus for full second-order consequence. Gödel I plus categoricity force this, consistent with Thm 5.7(a). The pinning lives in the semantics of "all", not in any rules.
   * "Internal categoricity" (Parsons 1990; McGee 1997; Väänänen & Wang 2015; Button & Walsh 2018) [cited (u)] moves the argument into a deductive system with *open-ended* induction. It shows that two number systems sharing a language are isomorphic. It pins the *structure* relative to whatever language is available, not the *theory* (L5 §8.6).
2. **Initiality / minimality** [cited, standard].
   * ℕ is the initial algebra of $(0,S)$: there is a unique homomorphism into any $(A,a,f)$.
   * Equivalently, ℕ is the least Herbrand model of the Horn theory $\{N(0),\ N(x)\to N(Sx)\}$ (van Emden & Kowalski 1976).
   * Every model of PA has ℕ as an initial segment (the standard cut), so ℕ is the unique ⊑-least model of PA.
   * *Adds:* a universal property, "nothing else is a number". Minimality is not first-order expressible. This is the same "closed-world" step that logic programming makes by fiat.
3. **Tennenbaum (1959)** [cited]. No countable non-standard model of PA has computable $+$ or $\times$. So **ℕ is the unique computable model of PA** up to isomorphism.
   * This is a theorem-level "yes" to "is ℕ the lowest-complexity structure satisfying some axioms?". Among models of PA it is the only one whose operations can be computed at all.
   * The caveat (the user's own, `logic/confusions/soundness.md`): "computable" is defined using ℕ of the meta-language. The pin is relative to the meta-level numbers.
   * Weaker theories can have computable non-standard models, e.g. open induction (Shepherdson 1964 [cited (u)]). So *which* axioms matter.
4. **The ω-rule / Gaifman condition (Thm 3.8).**
   * *Adds:* an infinitary rule saying "every number is a numeral". Coherence plus this rule plus computation yields exactly Th(ℕ), even probabilistically.
   * *Price:* no limit-computable coherent credence that gives probability 1 to all true quantifier-free sentences obeys it (Cor 3.9 and the remark after it).
5. **World anchoring by computation** (T2 Lemma 3.7) adds nothing beyond coherence with Q. Computation fixes the Δ₀ facts, and every consistent extension of Q already agrees with them.

Each pin uses something beyond finitary computable coherence:
* second-order quantification;
* a universal property;
* a complexity bound measured in ℕ itself;
* an infinitary rule.

Thms 5.6–5.7 say that this is forced. The user's own categoricity note proposes "the length of the smallest set of conditions determining it (ie the sum of lengths of the assumptions in the smallest categoricity result)" as a complexity measure for structures. In these terms ℕ's smallest categoricity result is short, but it is necessarily stated in a non-first-order or non-computable idiom.

---

## 6. Does this vindicate the philosophical proposition?

**Where yes.** In every one of the generalized senses below, "coherent iff there is something it could be talking about" is a theorem with a full proof.

| mode of talking | coherent | something it could be about | theorem |
|---|---|---|---|
| positions under a multiple-conclusion calculus | no excluded position is occupied | an admissible valuation | Thm 2.2 |
| structural calculus (learned) | ⊥ not derivable on the designated context | a Lindenbaum matrix model (syntactic) | Thm 5.1 |
| credences, finite agenda | no Dutch book; all counting sequents | a probability mixture of worlds | Thm 3.1 |
| credences, first-order | Gaifman coherence | a mixture of complete theories, i.e. of models | Thm 3.7 |
| finite preference data | no derivation of $L\succ L$ by mixing + transitivity (money-pump-like) | a real expected-utility function | Prop 3.10 |
| context system with monotone bridges | ⊥ not derivable at designated contexts | a bridge-compatible family of local belief states, nonempty at every designated context (grounded equilibrium) | Thm 4.1, Cor 4.2, Prop 4.3 |
| first-order theory | consistent | a structure (made of witness terms) | Gödel/Henkin |
| polynomial equations | $1\notin$ ideal | a point over $\bar k$ | Nullstellensatz |

Sam's stronger slogan also holds in each strongly complete case: the round trip fixes exactly the closed sets (Prop 1.3; Thm 2.4 for positions). The user's DLK claim that a rule-respecting truth assignment "can be extended to a full model" is correct (§5.3).

**Where no, or only with qualifications.**
1. **The something may be made of syntax** (Thm 1.4, Thm 5.1). The proposition is substantive only if the class of somethings is specified independently. When it is (truth tables, structures, points of $\bar k^n$, measures), each theorem has a non-trivial *realization step*: Henkin witnesses, Zariski's lemma, Carathéodory.
2. **Weak ≠ strong** (Prop 1.6). Existence of somethings for every coherent position does not imply that those somethings determine the consequence relation.
3. **Intended existence needs more than coherence.**
   * Layer (i), coherent but false, is defeated only by truth-tracking principles: reflection, accepting stronger theories (T2 §3.5), or Popperian policies.
   * Layer (ii), true but non-categorical, is defeated only by infinitary, second-order or meta-level ingredients (§5.5).
   * Both are *forced*: by compactness for infinite structures (Thm 5.6) and by computability for any computable coherence notion (Thm 5.7).
4. **Contexts.** The right something for a context system is a family of belief states, not a family of worlds (Thm 4.5). A single global world exists automatically only on tree-like covers (Thm 4.6, Prop 4.7).
5. **Probabilistic coherence is global.** A CCS-style probe satisfying pairwise or local constraints on an unclosed agenda need not be "about" any mixture of worlds (Thms 3.4–3.5). On logically closed agendas, local constraints suffice (Prop 3.6).
6. **Choice of semantics is a choice.** Thm 1.4 shows that a calculus is complete for its own points. The question "which semantics?" is answered by which models we can *independently access*: the two truth values, ℕ via computation, the world via observation.

**Connection to the user's views.**
* *Coherence plus "hooking onto the world".* This work splits the user's open question ("what is the structure of the hooking of a model onto the world?") into two parts.
  * *Coherence* answers "is there any world this way of talking could be about?". The answer is yes, in a canonical, partly syntactic sense.
  * *Hooking* answers "is it this world?". Hooking is positive data in valuation space (T2 §4.1: world feedback says the actual valuation is admissible). Uniformly over all possible anchorings, it pins exactly the vocabulary that is definable from the hooked vocabulary (Prop 5.8). The actual anchoring may pin more.
  * Neither does the other's job. A coherent theory hooked onto the world on its observational vocabulary can still talk about many things, unless its theoretical vocabulary is definable, categoricity holds, or the actual anchoring structure happens to admit a unique expansion (Prop 5.8).
* *C-models versus L-models* (`logical models as distinct from mental models.md`). The user imagined "a C-model … with some 'axioms and inference rules' such that if one tried to construct a mathematical object 'wrt which all these … would be valid', one would not be able to construct anything (QFT infinities?)". The results here sharpen this into two cases.
  * Either the C-model is incoherent in its own calculus. Then no L-model of that calculus exists (soundness). Such a C-model can still be *used* by chunking: it is a multi-context system whose designated chunks are coherent, so it has local belief states that are nonempty on those chunks (Cor 4.2), and possibly no global world (Prop 4.7).
  * Or it is coherent. Then an L-model exists, possibly syntactic (Thm 5.1).
  * So "a C-model without an L-model" is precisely an incoherent calculus used only through coherent chunks. It is a contextual family without a global section.
* *Aboutness in math and physics* (`math is a mere string game iff everything is.md`). The user's view that "the talking-about-something-ness of the two situations is clearly the same" fits the frame. In both cases the something is a model of the mode of talking. What differs is only the *anchoring*: the physical icosahedron hooks some vocabulary to the world; the mathematical one hooks none, but is pinned up to isomorphism by finiteness (§5.4).
* *"Infinite endeavors."* Thm 5.7 is a formal reason why there is no final formula. For ℕ, no computable coherence notion ever reaches the intended model. One can only add pins (reflection, stronger theories) on other grounds. This matches T2's Turing-progression picture and the user's view that justification is open-ended.

---

## 7. Honest assessment of depth

* **Standard results reorganized:** Fact 1.2, Thm 1.5, Thm 2.2–2.6, Thm 3.1, Thm 3.7, Thm 3.8, Thm 5.1–5.2, and the citations in §5.5. Their value here is the *organization*.
  * Completeness = realization of points.
  * Two steps: Zorn, then realization.
  * The tautological canonical frame shows exactly where content lives.
  * The weak/strong distinction separates the user's slogan from Sam's.
* **Standard arguments, newly applied** (list revised after verification).
  * **Thm 4.5** is the context-logic instance of the standard distinction between a rule of proof and the corresponding conditional: global versus local consequence, or □(p∨q) ⊭ □p∨□q. It is also why Ghidini & Giunchiglia use sets of local models. Only its use as a criterion for physics bridges is new here.
  * **Thm 5.7**, the computability barrier, uses the textbook argument "a complete r.e. calculus makes semantic consequence r.e.". The same argument is behind "no complete r.e. axiomatization of Th(ℕ)", "no complete proof system for finite validity" and "no complete calculus for full second-order logic". Only its framing as the formal content of the non-standard caveat is new here.
  * **Thm 3.8**, the probabilistic ω-rule pin, is essentially a consequence of Gaifman 1964.
* **Small new pieces, as far as I know; all are elementary.**
  * The **counting-sequent** form of de Finetti's theorem (Thm 3.1(iv)). This is likely folklore in probability logic; cf. Paris 1994 (u).
  * The **strictness theorems** for CCS-type constraints: Thm 3.4 on arity, and Thm 3.5 on the threshold, with the clean $m\ge k-1$ bound. Thm 3.5 includes the perhaps surprising fact that *all* valid ordinary sequents' union bounds together do not imply coherence. Both are statements about uniform bounds across agendas; any single finite agenda needs only its finitely many facets.
  * **Thm 4.1** in exactly this form. LMS completeness results exist (Ghidini & Giunchiglia 2001; Serafini & Bouquet 2004) [cited (u)]; mine is the simplest monotone case, made to fit L7's calculus. It matches L7's own semantics only when all Step and Exp instances are sound (remark after Prop 4.4).
  * The corollary for logical inductors (Cor 3.9), a short combination of cited facts.
* **TOSU warnings.** Thms 1.4, 4.1 and 5.7 and Prop 1.3 are short once the definitions are right. Thm 3.5(b) is the only proof with an actual combinatorial argument.
* **Unverified citations:** marked (u). The ones most worth checking before reuse:
  * Garrabrant et al.'s Limit Coherence (Thm 4.1.2), Non-Dogmatism (Thm 4.6.2) and the definition of a market as a computable sequence of pricings (Def 3.1.3). All three are used in Cor 3.9; the statements were confirmed by search snippets, but the numbering is (u);
  * Gaifman's uniqueness-of-extension theorem as credited in Thm 3.8;
  * the Svenonius and Chang–Makkai theorems cited after Prop 5.8;
  * Vorob'ev's exact theorem statement;
  * Hausner's non-Archimedean utility representation;
  * the Brewka–Eiter terminology for grounded equilibria.

---

## 8. Open problems

1. **Graded sequent calculi.**
   * Find a natural, finitely presented proof system for valid counting sequents over a propositional language. A cutting-planes-like system is a candidate (Chvátal 1973 [cited (u)]).
   * Prove completeness for de Finetti coherence.
   * Find how the minimal threshold of a violated counting sequent relates to Dutch-book size and to LP distance from the polytope.
2. **Learning-theoretic Carnap tell-tales.** T2 Thm 4.4 gives a 12-datum tell-tale for CPC. For which finite reduced matrices $\langle\mathbf A,D\rangle$ is there a *finite* set of bilateral data plus designated coherence data that forces every point of every surviving structural calculus to reduce to $\langle\mathbf A,D\rangle$ (P3 in Prop 5.3's sense)?
3. **Contextual coherence as a loss.** Make a graded measure of the gap between Cor 4.2 (local belief states exist) and a global world (Prop 4.7). Abramsky et al.'s "contextual fraction" [cited (u)] is a candidate.
   * Is it the right penalty for physics context systems?
   * Or should such contextuality be *tolerated*, as the user's "frames needn't be reconcilable" suggests?
4. **Probabilistic multi-context completeness.** Combine §3 and §4: context-indexed credences with bridge constraints. Prove a local-to-global theorem on tree covers, a probabilistic Thm 4.6 in the style of Vorob'ev. Characterize Dutch books against context systems.
5. **Pinning by simplicity.** Formalize "lowest-complexity model" for theories other than PA.
   * Which theories have exactly one computable model up to isomorphism?
   * Is there a resource-bounded version, e.g. a unique polynomial-time presentable model, that pins structures for physics' real-closed-field core?
6. **Non-monotone bridges.** Characterize when coherence of the designated contexts guarantees an equilibrium, e.g. stratification or acyclicity of default dependencies (Prop 4.4 shows it can fail).

## 9. Suggested experiments

1. **Global coherence of CCS probes.**
   * Build agendas with $k$-way structure: mutually exclusive alternatives (the $F_k$ of Thm 3.4) and implication chains.
   * Train probes with (a) negation coherence only, (b) all pairwise constraints, (c) counting-sequent losses.
   * Measure LP distance to the coherence polytope and Dutch-book exploitability.
   * Prediction: (a) and (b) leave $\Omega(1/k)$ violations of exactly the Bonferroni/counting type; (c) removes them.
2. **A Gaifman probe for arithmetic credences.** For LM credences, compare $P(\exists x\,\varphi(x))$ with $\max_{i\le n}P(\varphi(\underline i))$ on bounded-search statements. Large gaps mark non-standard belief: belief in a witness that is never named.
3. **Belief-state versus world-family checkers on physics solutions.** Encode solutions as MC context systems. Run both semantics (Thm 4.5). Look for steps that case-split across an idealized context's undetermined possibilities: these are licensed only under the world reading. Flag them as suspect exports.
4. **Contextual frustration in solution corpora.** For olympiad solutions using several idealizations, test whether the designated contexts admit a global world (Thm 4.6) or form frustrated cycles (Prop 4.7). Correlate with grader judgments of rigor.
5. **Alternative meanings as models.** For a learned calculus with surviving coherent fallacies (T2 §6), compute reduced Lindenbaum matrices on finite fragments. Report *what the learned logic is about*, e.g. singleton domains for quantifier swap. This is a diagnostic that turns Kripkensteinian residue into inspectable objects.

## 10. Computational checks (`theory/T6-checks/`, run all with `run_all.sh`)

| script | checks | result |
|---|---|---|
| `scott_duality.py` | Cor 2.3 on 300 random sequent sets (4 formulas); Thm 2.4 exhaustively for 3 formulas | all equal; 256/256 closed, Th injective |
| `prob_coherence.py` | Ex 3.3 facets; Thm 3.4 for k = 3..6; Thm 3.5 for k = 3 (all $3^{12}$ sequents); the m = 2 certificate | 4 facets as stated; locally coherent / globally incoherent for all k; 503,270 valid sequents, 0 violated; certificate valid and violated |
| `counting_sequents.py` | Thm 3.1(iv) via extracted Farkas certificates | 215/215 verified |
| `multiplicity.py` | minimal violated threshold $m$ for $P_k$ | m = 2 (k = 3), m = 3 (k = 4), consistent with Thm 3.5(b) |
| `mcs_completeness.py` | Thm 4.1(c), Cor 4.2 on 400 random systems; Thm 4.5(b) | 0 mismatches; disjunction example confirmed |
| `contexts_local_global.py` | Thm 4.6: (a) 7,131 random local-theory systems on one fixed 3-node path cover; (a2, added after verification) 2,000 random tree covers (2–5 nodes) plus a negative control without running intersection. Prop 4.7 (logical and probabilistic) | all global; negative control: 437/2,000 fail; triangle has no global model or distribution |
| `repair_checks.py` (added after verification) | (A) Thm 1.5(c) needs soundness, Prop 1.3 does not; (B) Lindenbaum semantics for Def 4.0/Cor 4.2; (C) Thm 3.5 by exact MILP, k = 3, 4, 5; (D) the $\mathbf H_4$ example for Thm 5.2 | counterexample confirmed; 0 failures on 1,602 sound frames; 0 violations on 3,000 systems; minima $0$ and $-rac1{k-1}$; generated subalgebra $\cong\mathbf H_3$ |
| `misc_checks.py` | Nullstellensatz instances; single-conclusion closure = ∩-closure (exhaustive, 3 formulas) | as stated |

---

## References

✓ = confident in the bibliographic data; (u) = details unverified.

* Abramsky, S., Brandenburger, A. (2011). The sheaf-theoretic structure of non-locality and contextuality. *New J. Phys.* 13:113036. ✓
* Abramsky, S., Barbosa, R., Kishida, K., Lal, R., Mansfield, S. (2015). Contextuality, cohomology and paradox. *CSL 2015*. (u)
* Adams, E. (1975). *The Logic of Conditionals*. Reidel; (1998) *A Primer of Probability Logic*. CSLI. ✓ (theorem attribution (u))
* Beeri, C., Fagin, R., Maier, D., Yannakakis, M. (1983). On the desirability of acyclic database schemes. *JACM* 30:479–513. ✓
* Beth, E. W. (1953). On Padoa's method in the theory of definition. *Indag. Math.* 15:330–339. ✓
* Birkhoff, G. (1940). *Lattice Theory*. AMS. ✓
* Blok, W., Pigozzi, D. (1989). *Algebraizable Logics*. Memoirs AMS 396. ✓
* Brewka, G., Eiter, T. (2007). Equilibria in heterogeneous nonmonotonic multi-context systems. *AAAI-07*, 385–390. ✓
* Burns, C., Ye, H., Klein, D., Steinhardt, J. (2023). Discovering latent knowledge in language models without supervision. *ICLR 2023*. ✓
* Button, T., Walsh, S. (2018). *Philosophy and Model Theory*. OUP. ✓
* Cauchy, A.-L. (1847). Mémoire sur une nouvelle théorie des imaginaires … (u)
* Chang, C. C. (1964). Some new results in definability. *Bull. AMS* 70:808–813. (u)
* Christiano, P., Yudkowsky, E., Herreshoff, M., Barasz, M. (2013). Definability of truth in probabilistic logic. MIRI draft. ✓
* Chvátal, V. (1973). Edmonds polytopes and a hierarchy of combinatorial problems. *Discrete Math.* 4:305–337. (u)
* Dedekind, R. (1888). *Was sind und was sollen die Zahlen?* ✓
* de Finetti, B. (1937). La prévision: ses lois logiques, ses sources subjectives. *Ann. Inst. H. Poincaré* 7:1–68. ✓
* Farkas, J. (1902). Theorie der einfachen Ungleichungen. *J. reine angew. Math.* 124:1–27. ✓
* Font, J. M. (2016). *Abstract Algebraic Logic: An Introductory Textbook*. College Publications. ✓
* Gaifman, H. (1964). Concerning measures in first order calculi. *Israel J. Math.* 2:1–18. ✓
* Garrabrant, S., Benson-Tilsen, T., Critch, A., Soares, N., Taylor, J. (2016). Logical induction. arXiv:1609.03543. ✓ (theorem numbering (u))
* Georgakopoulos, G., Kavvadias, D., Papadimitriou, C. (1988). Probabilistic satisfiability. *J. Complexity* 4:1–11. (u)
* Ghidini, C., Giunchiglia, F. (2001). Local models semantics, or contextual reasoning = locality + compatibility. *AIJ* 127:221–259. ✓
* Glivenko, V. (1929). Sur quelques points de la logique de M. Brouwer. *Bull. Acad. Royale de Belgique* 15:183–188. ✓
* Gödel, K. (1930). Die Vollständigkeit der Axiome des logischen Funktionenkalküls. *Monatsh. Math. Phys.* 37:349–360. ✓
* Hausner, M. (1954). Multidimensional utilities. In Thrall, Coombs, Davis (eds), *Decision Processes*. Wiley. (u)
* Henkin, L. (1949). The completeness of the first-order functional calculus. *JSL* 14:159–166. ✓
* Hilbert, D. (1893). Über die vollen Invariantensysteme. *Math. Ann.* 42:313–373. ✓
* Kaye, R. (1991). *Models of Peano Arithmetic*. OUP. ✓
* Krivine, J.-L. (1964). Anneaux préordonnés. *J. Analyse Math.* 12:307–326. (u)
* Lewis, D. (1970). How to define theoretical terms. *J. Phil.* 67:427–446. ✓
* Łoś, J., Suszko, R. (1958). Remarks on sentential logics. *Indag. Math.* 20:177–183. ✓
* Makkai, M. (1964). On a generalization of a theorem of E. W. Beth. *Acta Math. Acad. Sci. Hungar.* 15:227–235. (u)
* Makkai, M., Reyes, G. (1977). *First Order Categorical Logic*. LNM 611. ✓
* Matiyasevich, Y. (1970). Enumerable sets are Diophantine. *Soviet Math. Dokl.* 11:354–358. ✓
* McCarthy, J. (1993). Notes on formalizing context. *IJCAI-93*, 555–560. ✓
* McGee, V. (1997). How we learn mathematical language. *Phil. Review* 106:35–68. ✓
* Motzkin, T. (1936). *Beiträge zur Theorie der linearen Ungleichungen*. Dissertation, Basel. ✓
* Ore, O. (1944). Galois connexions. *Trans. AMS* 55:493–513. ✓
* Paris, J. (1994). *The Uncertain Reasoner's Companion*. CUP. ✓
* Parsons, C. (1990). The uniqueness of the natural numbers. *Iyyun* 39:13–44. ✓
* Pitowsky, I. (1991). Correlation polytopes: their geometry and complexity. *Math. Programming* 50:395–414. (u)
* Rosser, J. B. (1936). Extensions of some theorems of Gödel and Church. *JSL* 1:87–91. ✓
* Scott, D. (1974). Completeness and axiomatizability in many-valued logic. In *Proc. Tarski Symposium*, Proc. Symp. Pure Math. 25, AMS, 411–435. ✓
* Serafini, L., Bouquet, P. (2004). Comparing formal theories of context in AI. *AIJ* 155:41–67. ✓ (per L7)
* SGA 4 (Artin, Grothendieck, Verdier; Deligne's exposé on coherent toposes), LNM 269/270/305. (u)
* Shepherdson, J. (1964). A non-standard model for a free variable fragment of number theory. *Bull. Acad. Polon. Sci.* 12. (u)
* Shoesmith, D. J., Smiley, T. J. (1978). *Multiple-Conclusion Logic*. CUP. ✓
* Specker, E. (1960). Die Logik nicht gleichzeitig entscheidbarer Aussagen. *Dialectica* 14:239–246. ✓
* Stengle, G. (1974). A Nullstellensatz and a Positivstellensatz in semialgebraic geometry. *Math. Ann.* 207:87–97. ✓
* Stone, M. (1936). The theory of representations for Boolean algebras. *Trans. AMS* 40:37–111. ✓
* Suszko, R. (1977). The Fregean axiom and Polish mathematical logic in the 1920s. *Studia Logica* 36:377–380. (u)
* Svenonius, L. (1959). A theorem on permutations in models. *Theoria* 25:173–178. (u)
* Tennenbaum, S. (1959). Non-archimedean models for arithmetic. *Notices AMS* 6:270. ✓
* Trakhtenbrot, B. (1950). The impossibility of an algorithm for the decision problem for finite domains. *Doklady* 70:569–572. ✓
* Väänänen, J., Wang, T. (2015). Internal categoricity in arithmetic and set theory. *NDJFL* 56:121–134. (u)
* van Emden, M., Kowalski, R. (1976). The semantics of predicate logic as a programming language. *JACM* 23:733–742. ✓
* von Neumann, J., Morgenstern, O. (1944). *Theory of Games and Economic Behavior*. Princeton. ✓
* Vorob'ev, N. N. (1962). Consistent families of measures and their extensions. *Theory Probab. Appl.* 7:147–163. (u)
* Wójcicki, R. (1988). *Theory of Logical Calculi*. Kluwer. ✓
* Zariski, O. (1947). A new proof of Hilbert's Nullstellensatz. *Bull. AMS* 53:362–368. ✓

---

## Verification log

Two independent adversarial referees checked this file. Referee A covered §§0–3, and Referee B covered §§4–5 together with the §0, §6 and §7 claims about them. Their full reports are reproduced in `verification/T6-verification.md`. I re-checked every reported issue myself, using computation where useful. Severity tags are the referees' own.

**Re-checks run.**
* `run_all.sh`, which re-runs all T6 scripts. Every number quoted in the file reproduces.
* New script `T6-checks/repair_checks.py`:
  * (A) the referee's counterexample to Thm 1.5(c) without soundness; 1,602 random sound finite frames with 0 failures of 1.5(b) or 1.5(c); 2,949 unsound frames with 0 failures of Prop 1.3 and 258 failures of 1.5(c), confirming that soundness is needed;
  * (B) the Lindenbaum semantics for Def 4.0: 3,000 random closure systems with an explosive falsum, 0 violations, plus the non-explosive counterexample;
  * (C) an exact MILP for Thm 3.5 with $k=3,4,5$;
  * (D) the $\mathbf H_4$ example for the §0 gloss of Thm 5.2.
* New part (a2) of `contexts_local_global.py`: 2,000 random tree covers with running intersection, with 0 failures. The negative control without running intersection has 437 failures out of 2,000.
* `counting_sequents.py`: the docstring is corrected (Thm 3.1, complementary pairs). The output is unchanged: 215/215.
* Literature check for Cor 3.9. Search snippets confirm Garrabrant et al.'s definition of a market as a *computable* sequence of pricings (Def 3.1.3), Limit Coherence (Thm 4.1.2) and Non-Dogmatism (Thm 4.6.2). The full text was not reachable (arXiv and intelligence.org are blocked by the egress proxy), so the numbering stays (u).

**Outcome in brief.**
* No issue was labelled fatal or major, and I found none.
* Every minor issue was genuine and has been fixed, or the claim has been weakened or recast. No issue was rejected.
* The substantive repairs are:
  * the soundness hypothesis in Thm 1.5(c);
  * the restated hypothesis of Thm 3.1;
  * a revised proof of Cor 3.9, now with two independent arguments and an explicit computability premise, and the qualified "no limit-computable credence" sentence;
  * the Lindenbaum semantics in Def 4.0, with the non-triviality reading of Cor 4.2;
  * Def 4.8, which now requires that $c$ establishes φ;
  * the retracted Post-completeness sentence after Prop 5.3;
  * the vocabulary hypothesis in Thm 5.7(c);
  * the reading of Prop 5.8 (uniform versus actual anchoring);
  * the novelty claims in §7 for Thms 3.8, 4.5 and 5.7, which are now classed as standard arguments, newly applied.

#### Referee A (§§0–3)

| # | item | severity | genuine? | action |
|---|---|---|---|---|
| A1 | Prop 1.3 (soundness unused) | ok | n/a | **Clarified.** A note says that the proof does not use soundness [checked: `repair_checks.py` (A), 0 failures on 2,949 unsound frames]. |
| A2 | Thm 1.4 | ok | n/a | No change. |
| A3 | Thm 1.5(c) needs soundness | minor | **yes** | **Fixed (hypothesis added; marked "revised after verification").**<br>• (c) now assumes $C$ sound. The proof of (⇒) says where soundness is used ("$\mathrm{Th}(\{m\})$ is closed *by soundness*").<br>• The referee's 3-sentence counterexample is included in the statement and reproduced by `repair_checks.py` (A).<br>• Random tests: 0 failures with soundness; 258/2,949 failures of (c) without it.<br>• Prop 1.6 already proves soundness before applying (c), so it is unaffected. |
| A4 | Prop 1.6 | ok | n/a | **Clarified.** Glivenko's theorem is added as a one-line alternative for weak completeness. |
| A5 | Prop 1.6 Reading (garbled proof-by-cases sentence) | minor | yes | **Fixed.** The argument is written out: maximal omitting φ, neither ψ nor ¬ψ in $T$ ⇒ φ ∈ C(T,ψ) ∩ C(T,¬ψ) = T, contradiction ⇒ complete ⇒ maximal consistent. |
| A6 | §0 item 1 ("complete for its own points (Thm 1.4)") | minor | yes | **Fixed.** §0 now reads "strongly complete for its own closed theories (Thm 1.4; no Zorn) and, if finitary, for its own points (Thm 1.5(a))". |
| A7 | Thm 2.2 / Cor 2.3 | ok | n/a | No change. |
| A8 | Thm 2.4 | ok | n/a | **Clarified.** The tag credits the compact-relation/closed-class correspondence to Scott 1974 and Shoesmith–Smiley 1978 as standard. |
| A9 | Rem 2.5 (Suszko holds for all Tarskian consequences) | ok | n/a | **Clarified.** The text now says "every Tarskian consequence, structural or not", and notes that Suszko stated it for structural logics. |
| A10 | Thm 2.6 | ok | n/a | No change. |
| A11 | Thm 3.1 ("closed under negation" impossible for finite $F$) | minor | yes | **Fixed (hypothesis restated).**<br>• $F$ is now a finite union of complementary pairs $\{\varphi,\varphi^\*\}$ with $\varphi^\*\equiv\neg\varphi$, and $P(\varphi^\*)=1-P(\varphi)$.<br>• The proof of (iv)⇒(iii) and the $m=1$ sequent definition use $\varphi^\*$.<br>• A note records that negation coherence is needed: $P\equiv1$ satisfies every valid counting sequent but is incoherent.<br>• The docstring of `counting_sequents.py` is corrected ("Thm 3.2" → "Thm 3.1"; complementary pairs). |
| A12 | Prop 3.2 / Ex 3.3 | ok | n/a | No change. |
| A13 | Thm 3.4 | ok | n/a | No change. |
| A14 | Thm 3.5 ("multiplicity" is really the threshold; "needs the full family" overstated) | minor | yes | **Fixed (wording; mathematics unchanged).**<br>• $m$ is now called the **threshold**. A terminology note says that the violated sequent of (a) repeats no formula.<br>• A *Scope* paragraph says that any single finite agenda is characterized by its finitely many facets, and that Thms 3.4–3.5 rule out only *uniform* bounds across agendas.<br>• §0, §3.2 ("Exact answer"), §7, §8 and §10 are updated to match.<br>• New exact MILP check (`repair_checks.py` (C), multiplicities in $[0,8]$): the minimum of $\sum_\Phi P_k-m$ is 0 for $m\le k-2$ and $-\frac1{k-1}$ for $m\le k-1$ ($k=3,4,5$), attained by the repetition-free sequent of (a). This reproduces the referee's MILP. |
| A15 | Prop 3.6 | ok | n/a | No change. |
| A16 | Thm 3.7 | ok | n/a | No change. |
| A17 | Thm 3.8 (attribution to Gaifman 1964) | minor | yes | **Fixed.** The tag now credits Gaifman 1964: a Gaifman measure is determined by its quantifier-free restriction (exact formulation (u)). §7 moves Thm 3.8 from "new" to "standard". |
| A18 | Cor 3.9 (silent computability premise; overstated sentence after it) | minor | yes | **Fixed (proof revised; sentence qualified).**<br>• The Δ₂ argument now states its premise: a market is a computable sequence of rational pricings (Garrabrant et al. Def 3.1.3, confirmed by search snippet).<br>• The referee's more robust second proof is added. Gödel–Rosser gives an independent sentence, and the false one, ψ, gets $\mathbb P_\infty(\psi)>0$ by Non-Dogmatism (Thm 4.6.2), so $\mathbb P_\infty\neq\delta_{\mathrm{Th}(\mathbb N)}$.<br>• A general remark is proved: no limit-computable coherent credence giving 1 to all true QF sentences satisfies the Gaifman condition. The referee's one-element-structure example shows that the QF hypothesis is needed.<br>• The "no computable or limit-computable credence" sentence and §5.5 item 4 are qualified accordingly. |
| A19 | Prop 3.10 ("money pump" gloss) | minor | yes | **Fixed.** §0, the §6 table and the Reading now say "no derivation of $L\succ L$ by mixing + transitivity (money-pump-like)", and flag "money pump" as an interpretive gloss. |

#### Referee B (§§4–5)

| # | item | severity | genuine? | action |
|---|---|---|---|---|
| B1 | Thm 4.1 | ok | n/a | No change. |
| B2 | Cor 4.2 (statement) | ok | n/a | No change to the statement. See B3 and B4. |
| B3 | Def 4.0 / Cor 4.2 applied to learned logics with Lindenbaum semantics | minor | **yes** | **Fixed (Def 4.0 revised; remark added).**<br>• Def 4.0 now specifies Lindenbaum semantics as $M_i=\mathrm{Fix}(C_i)\setminus\{L_i\}$ (proper closed theories), shows $\mathrm{Th}_i\circ\mathrm{Mod}_i=C_i$, and says that Thm 1.4's full frame does not qualify, because the trivial theory satisfies everything.<br>• The falsum condition becomes "$\bot_i$ is $C_i$-explosive".<br>• A remark after Cor 4.2 proves the falsum-free version: $T_i\neq L_i$ iff $c^\Gamma_i\neq\emptyset$. So for learned logics, D-coherence should be read as non-triviality. It includes the referee's non-explosive counterexample ($R=\emptyset$, $K_i=\{\bot_i\}$).<br>• [checked: `repair_checks.py` (B), 3,000 random systems, 0 violations] |
| B4 | §0 / §6 summaries drop "nonempty on D" | minor | yes | **Fixed.** §0 item 4, the §6 table, the §4.3 Reading and the §6 C-models paragraph now say "nonempty at every designated context", and note that suppositional contexts may be forced empty. |
| B5 | Prop 4.3 | ok | n/a | No change. |
| B6 | Prop 4.4 ("context i alone is coherent"; "must come from stratification") | minor | yes | **Fixed (wording).** "$K_i$ is consistent (the context is coherent without its bridge)". Existence "needs an extra condition, such as stratification or the absence of odd loops through negation as failure … stratification is sufficient, not necessary". |
| B7 | Remark relating MC to L7's calculus | minor | yes | **Fixed (rewritten; [sketch]).**<br>• Thm 4.1 is now described as completeness for LMS *with bridges as compatibility constraints*. L7 §8.2's semantics keeps $\mathrm{Mod}(@)$ fixed and asks bridges to be sound.<br>• The two coincide when the local logic is the complete base logic and every Step/Exp instance is sound. Proof sketch: ⊆ by L7 Prop 1; ⊇ by induction down the tree.<br>• The referee's unsound-export example shows that they differ otherwise.<br>• The SUP identity is kept. |
| B8 | Thm 4.5 ((c) omits tagged $K_i$ and Γ) | ok | yes (small) | **Fixed.** (c) and its proof now include the tagged $K_i^{(i)}$ and the tagged premises Γ. |
| B9 | Thm 4.5 novelty claim | minor | yes | **Fixed.** A *Status* note after the proof, and §7, present Thm 4.5 as the context-logic instance of rule-of-proof versus conditional (global/local consequence; □(p∨q) ⊭ □p∨□q). It is listed under "standard arguments, newly applied". |
| B10 | Thm 4.6 (script description) | ok | yes (description) | **Fixed.**<br>• The theorem tag and the §10 table now say that (a) uses one fixed 3-node path cover.<br>• New part (a2) tests 2,000 random tree covers with 2–5 nodes and random running-intersection placement: 0 failures. A negative control without running intersection gives 437/2,000 failures.<br>• The tag credits the join-tree/Robinson-consistency argument (Beeri et al. 1983). |
| B11 | Prop 4.7 and the Vorob'ev/BFMY citation | ok | n/a | No change. |
| B12 | Def 4.8 ("true enough" does not require $c$ to establish φ) | minor | yes | **Fixed (definition revised).** It now requires (i) $\Gamma\vdash_{\rm MC}c{:}\varphi$, (ii) the bridge's side conditions hold at @ ($\Gamma\vdash_{\rm MC}@{:}\sigma$ for a checker), and (iii) bridge soundness. |
| B13 | Thm 5.1 | ok | n/a | **Clarified.** A note says that (b) holds for any $C_R$-theory $\supseteq A$ omitting ⊥. |
| B14 | Thm 5.2 | ok | n/a | No change. |
| B15 | §0 gloss of Thm 5.2 (needs a generating valuation) | minor | yes | **Fixed.** §0 now says "a *generating* (surjective) intended valuation; in general the reduction of the generated submatrix". The referee's example is reproduced in `repair_checks.py` (D): $h(p)=a$ in $\mathbf H_4$ generates $\{0,a,1\}\cong\mathbf H_3$, which is reduced. |
| B16 | Prop 5.3 wording; the "not Post-complete ⇒ non-isomorphic completions" sentence | minor | yes | **Fixed (wording corrected; sentence retracted and replaced).**<br>• "Reduced generated submatrix" → "the reduction of a generated submatrix (a strict homomorphic image of a submatrix)".<br>• The Post-completeness sentence is retracted, using the IPC counterexample: IPC is not Post-complete, yet all its maximal theories reduce to **2** (Prop 1.6).<br>• The CPC fact is re-derived from "every point is maximal, and maximal theories are Boolean". The non-isomorphism is located in non-maximal points (Ex 5.4), and P3 is tied to points. |
| B17 | Ex 5.4 | ok | n/a | **Clarified.** "FOL with equality". |
| B18 | Thm 5.5 | ok | n/a | **Clarified.** The wording is now: "its negation is a true Δ₀ sentence, hence provable in Q ⊆ T". |
| B19 | §5.4 layer (i) | ok | n/a | No change. |
| B20 | Thm 5.6 | ok | n/a | No change. |
| B21 | Thm 5.7 ((c) needs a binary relation symbol; novelty) | minor | yes | **Fixed.**<br>• (c) now assumes a vocabulary with at least one binary relation symbol, and notes that the monadic case is decidable. The Reading and §0 are updated.<br>• The tag and §7 recast Thm 5.7 as the textbook argument ("a complete r.e. calculus makes semantic consequence r.e."), newly applied. |
| B22 | Prop 5.8 reading (actual vs uniform anchoring) | minor | yes | **Fixed (reading revised).**<br>• Beth is now read as pinning *uniformly over all anchorings* iff definable.<br>• The referee's $(\mathbb N,<)$ vs $\omega+\omega$ counterexample and the one-element variant are included, together with a pointer to Svenonius / Chang–Makkai for fixed structures [cited (u)].<br>• §0 and §6 are updated. |
| B23 | §5.5 pins | ok | n/a | No change, except item 4, which is qualified as in A18. |
| B24 | `run_all.sh` | ok | n/a | No change to the earlier scripts' outputs. `repair_checks.py` is added to `run_all.sh`. |
