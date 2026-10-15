# Track "context": out-of-distribution behaviour, computable versions, NN Bayes, literature, extras

*Track notes for the SFI paper. Read `../../00-brief.md` first. This track covers brief items H8 and H10, the motivation (NN Bayes and simplicity bias), the literature, and further results. Scripts are in `checks/` (seeded; each writes `<name>_output.txt` next to itself).*

**Status labels.**
* **[proved]**: full proof in these notes.
* **[computed]**: checked by a seeded script whose saved output is cited.
* **[known]**: published result, with reference. **(unverified)** means I could not check it against the source in this session. Only web-search snippets were available; arxiv.org, lesswrong.com and publisher sites did not resolve. "(snippet)" means the bibliographic data, and only what the snippet says, were confirmed by a search snippet.
* **[proof sketch]**: argument given, some steps not written out.
* **[conjecture]**: believed, not proved.
* **[refuted]**: a claim shown false, kept with its counterexample.
* Hänni's claims are treated as hypotheses.

---

## 0. Summary

**OOD (H8).**
1. Hänni's proposition holds, in a stronger form, with **no log term** [proved, Prop 2.1]. Let a decidable property $Q$ contain no training input. Then SFI gives probability at least $2^{-K(Q,b)-c}$ to any computable behaviour $b$ on all $Q$-inputs at once. This holds for the program mixture $W$ and for the universal function semimeasure $M_F$, and for the shortest consistent program. The bound holds for every training set, however large.
   * No log term appears because prefix-free codes concatenate. One appears only if the property's complexity is measured by plain complexity $C$, or if $Q$ is merely semi-decidable (Remark 2.2).
   * The universal semimeasure is not needed to avoid it.
2. A relative version [proved, Prop 2.3]: a property that is simple *given a good training program* $p$ forces bad behaviour with probability at least $2^{-K(Q,b\mid p)-c}$ times $p$'s posterior weight.
3. Language dependence [proved, Prop 2.4]. For each fixed $Q$ and $b$ there is a universal machine under which the bad behaviour gets posterior $\ge 1/2$ for *every* training set avoiding $Q$. Such a machine is about $K(Q,b)$ bits away from the reference machine.
4. The PDF draft's two-sided "result", reconstructed [Thm 2.5]. Let $P$ be a property of input–output pairs. On inputs in an unseen decidable $Q$, the probability of $P$-abiding outputs lies in $[2^{-K(P,Q)-c},\,1-2^{-K(P,Q)-c}]$ (when $P$ and its complement are r.e. and both kinds of output exist). There is also a finer single-input form, using the simplest violating output $z$: violation probability at least $2^{-K(Q)-K(z\mid x)-c}$ for $M_F$, and with $K^{\mathcal P}(z\mid x)$ in place of $K(z\mid x)$ for $W$.
   * The draft's literal "at most $2^{-C(Q)}\cdot2^{-K(\cdot)}\cdot$const" is **refuted**: it must read "the probability of *violation* is at least ...".
   * Its "at least $2^{-C(P)}$" is **refuted** without the separating property $Q$ (Prop 2.6).
5. **OOD failure is a bounded resource** [proved, Thm 2.7, Prop 2.8].
   * Over any sequence of distinct inputs (adversarial, adaptive), the posterior error probabilities $e_k$ of SFI on a computable $f$ with binary labels satisfy $2^{-c}\sum_k2^{-\sigma_k}\le\sum_ke_k\le(\ln2)(K_F(f)+c)$.
   * Here $\sigma_k$ is the complexity of the simplest property separating $x_k$ from $x_1,\dots,x_{k-1}$. Each property can be "new" only once, so $\sum_k2^{-\sigma_k}\le1$.
   * This formalises Hänni's "fake OOD generalisation": after enough shifts of a kind, the kind is learned.
6. Positive results and their limits.
   * **Random splits generalise** [proved, Prop 2.9]: for *any* finite input set $B$, a uniformly random split (random order, random split point) gives expected test loss equal to (the order-free total loss)$/|B|\le(K_B(f)+c)/|B|$.
   * With a fixed training size (leave-one-out) only $2^{K}/|B|$ follows from the elementary argument [proved, Prop 2.10]. Bayes mixtures can have increasing learning curves [computed, c3]. Whether SFI's leave-one-out error is $O(K/|B|)$ is open [conjecture 2.11].
   * **Even in distribution, simple separating properties are typical** at complexity $\approx\log m$. So SFI's error on a fresh uniform input after $m$ training inputs is $\Omega(1/(m\log^2m))$ even for $f\equiv0$ [proved, Prop 2.12; computed, c4]. This matches the $O(1/m)$ Cesàro upper bound up to $\log^2m$.
   * **The naive converse is false** [proved, Prop 2.13]: "no property of complexity $\le\log m-O(1)$, even relative to $f$'s program, separates test from train" holds w.h.p. for a random function, yet every learner, SFI included, errs with probability 1/2.
   * The strongest true positive statements are (a) the relative one (dominance plus the bounded resource), (b) the random-split theorem, and (c) a sandwich [proved, Prop 2.14]: SFI errs at $x^*$ only when a wrong completion of the training labels is nearly as simple, *given the whole input set*, as the training labels are to produce without it.
   * Easy-to-hard [proved, Example 2.15]: if every training statement has a proof or refutation of length $\le L$ and the test statement needs one longer than $2^{\lceil\log_2L\rceil}$, then SFI's error is $\ge2^{-K(T)-c}/\log_2^2L$ (for a theory $T$), however many easy statements were seen.

**Computable versions (H10).**
7. **Time-bounded SFI** [proved regret, proof sketch of running time, Thm 3.1; computed, c5]. There is an online learner whose round on input $x$ costs about $\log\log|x|$ simulations of $p(|x|)\log\log|x|$ steps. It has constant regret (depending only on $A$) against every $x$-only probability predictor $A$ running in time $O(p(|x|))$, on every sequence of distinct inputs.
   * Activation is by *input length*, not round number.
   * Hänni's "apples to oranges" caveat disappears for $x$-only predictors: they have nothing to reuse (Remark 3.2).
   * Against history-aware time-bounded predictors even unbounded $x$-only SFI fails (H3). The right object there is a chronological version, where his amortisation trick applies [proof sketch].
8. Against **samplers** (randomised predictors) the clocked mixture has the same constant regret [proved, Prop 3.3], but computing it exactly takes time $2^{O(p\log\log)}$. Whether an efficient learner exists is open (Question 3.4). It is connected to Impagliazzo–Levin universal extrapolation [known, snippet].
9. **Circuit Bayes: mistakes and circuit size are polynomially related, in both directions, on every ordering** [proved, Thm 3.5; computed, c1 for formulas, $d=3$]. Take the prior "size $s$ with probability $2^{-s}$, then uniform over size-$s$ circuits"; this is the description-length prior of a unary size code followed by a gate list.
   * (a) $c(f)\le\lceil L(f)\rceil$, where $L(f)=-\log_2W(f)$ is the cumulative log loss on any enumeration of the domain.
   * (b) For every ordering, the expected number of posterior-sampling mistakes $m$ satisfies $m\le(\ln2)L(f)=O(c(f)\log(c(f)+d))$ and $L(f)\le2m(B+3)$, with $B=O(d\log(d+L))$. Hence $c(f)=O(m\,d\log(md))$.
   * This proves Hänni's "$O(m\log m\cdot d)$" claim (up to $\log(md)$ for $\log m$), for every ordering rather than in expectation, with no Markov step. It also proves its converse for every ordering.
   * Hänni's sketch has a gap, closed here by the exponential size tail of the prior: going from small log loss to a small circuit needs a "circuit coding theorem". With a polynomially decaying size prior this step is open (Remark 3.6).
10. **Occam (simplest-consistent) learning** [proved, Props 3.8, 3.9].
   * In distribution it makes $O(\ell(f)(d+\log\ell(f))+d^2)$ expected mistakes ($\ell$ = description length). This proves Hänni's in-distribution claim with constants.
   * Out of distribution only the trivial bound $|H_f|-1=2^{O(\ell)}$ is known.
   * Hänni's "physicist's proof" is a correct proof for the Bayes **MAP** (weighted-majority/halving) learner, whose mistakes are $\le L(f)$ on every ordering [proved, Remark 3.10]. It is not a proof for Occam.

**NN Bayes and circuit SFI (motivation).**
11. Proved general facts.
   * The NN posterior is function-space Bayes with the parameter–function-map prior $P_A$ [Prop 4.1].
   * $P_A(f)\le2^{-K(f\mid a)+c}$ with $c$ independent of the architecture. This is the coding theorem; Hänni's $\log\log$ term is unnecessary [Prop 4.2].
   * Functions sampled from *any* lower-semicomputable prior nearly saturate this bound with high probability, so that fact carries no NN-specific content, as Hänni suspected [Prop 4.3].
   * There is no general matching lower bound [Prop 4.4].
12. **Uniform priors over circuits of a fixed size contain the circuit simplicity prior** (one half of Hänni's "first open problem") [proved, Prop 4.5]. For $c(f)<S$, $P_{\mathrm{unif},S}(f)\ge2^{-\ell_{\rm circ}(f)}/(16(d+1+S)^2)$, where $\ell_{\rm circ}(f)=\log_2N_{c(f)}$ is the gate-list code length of a minimal circuit. Bayes with this prior makes $\le(\ln2)(\ell_{\rm circ}(f)+2\log_2(d+1+S)+4)$ posterior-sampling mistakes on every ordering.
13. **The NNGP/NTK caveat is a theorem** [proved, Thm 4.6, Cor 4.7; computed, c2].
   * Dot-product kernels (all NNGP/NTK kernels of fully connected nets, on the cube) are diagonal in the Walsh basis with eigenvalue depending only on degree.
   * Any kernel method or GP posterior mean, from $n$ samples, has mean squared error $\ge1-n/\binom dk$ on a random $k$-sparse parity (the standard dimension argument).
   * SFI's cumulative mistakes are $\le(\ln2)(\log_2\binom dk+O(\log d))$.
   * For two-layer bias-free ReLU NNGP and NTK, odd degrees $\ge3$ have eigenvalue exactly $0$, so those parities are never learned [proved, Remark 4.8].
14. Simplicity-bias literature surveyed with verification status (§4.6). The Vaintrob–Hänni slides are a **placeholder** (§4.5).

**Literature (§6).** The closest prior objects are the following. A web search finds no prior use of the name "Solomonoff function induction" (snippet-level search only).
* Solomonoff's **third kind of induction / "operator induction"**: unordered sets of question–answer pairs, a universal distribution, and a convergence theorem. 2008 *Comput. J.* abstract confirmed (snippet); details unverified.
* Hutter's **chronological semimeasures** (history-aware; AIXI with actions as inputs).
* **Lattimore–Hutter's** Solomonoff-inspired off-line classifier (snippet).
* Lattimore–Hutter–Gavane on predicting **selected bits** (snippet).

**Extras (§5).**
* **Order independence characterises Bayesian random-function predictors** [proved, Prop 5.1; computed, c3]. SFI is the universal element of that class, given H1's universality [Cor 5.2].
* **Active learning** [proved, Prop 5.3]: the query order never changes total log loss, and small total log loss does not give efficient identification (point functions need about $2^{n-1}$ queries on average while SFI's total loss is $\le n+O(\log n)$).
* **Structured outputs** [proved, Prop 5.4].
  * Single-query $M_F$ is the conditional *discrete* universal distribution $2^{-K(y\mid x)\pm O(1)}$. It equals SI on $y\$$ (end-marked) up to constants. Without the end marker, SI can be exponentially more confident.
  * The program mixture $W$ is **not** $2^{-K(y\mid x)\pm O(1)}$ on single queries. Its programs must be self-delimiting without seeing the input, so it can fall short by an unbounded factor (a datum for H1).
* Remarks on positive-example induction and on interventions.

---

## 1. Setting and notation

These definitions are the ones I use; they are meant to be compatible with H1 (foundations track). Inputs and outputs are finite binary strings, $X=Y=\{0,1\}^*$; sometimes $Y$ is a finite label set. A **data set** $D$ is a finite partial function $X\rightharpoonup Y$, written as a set of pairs. $D+(x,y)$ adds a pair with $x\notin\operatorname{dom}D$.

**Programs.**
* $U$ is a universal prefix machine. Its programs form a prefix-free set $\mathcal P$, and a program is read before the input is used.
* $U(p,x)$ is the (possibly undefined) output of $p\in\mathcal P$ on $x$.
* Prefix complexity is $K(\cdot)$, conditional complexity $K(\cdot\mid\cdot)$.
* For a finite set $B$ and $f$ defined on $B$, $K_B(f):=\min\{|p|:p\in\mathcal P,\ U(p,x)=f(x)\ \forall x\in B\}$. $K_F(f)$ is the same with $B=X$, for computable total $f$.
* Programs in $\mathcal P$ are self-delimiting *independently of the input*. So the conditional complexity they define, $K^{\mathcal P}(z\mid x):=\min\{|h|:h\in\mathcal P,\ U(h,x)=z\}$, can exceed the standard conditional prefix complexity $K(z\mid x)$. In the standard version the machine may read $x$ before deciding how many program bits to read.
  * We have $K(z\mid x)-c\le K^{\mathcal P}(z\mid x)\le K(z\mid x)+K(K(z\mid x))+c$. For the upper bound, prefix a standard conditional program with a self-delimiting code of its length.
  * The gap matters for $W$ on single queries (Prop 5.4).

**Program mixture.** $W(D):=\sum\{2^{-|p|}:p\in\mathcal P,\ U(p,x)=y\ \forall(x,y)\in D\}$.

**Function machines and $M_F$.**
* A function machine $T$ gets an input $x$ and one-way read access to an infinite random tape $\omega\in\{0,1\}^{\mathbb N}$. $T(x,\omega)=y$ if it halts with output $y$; it has then read finitely many bits.
* $\mu_T(D):=\lambda\{\omega:T(x,\omega)=y\ \forall(x,y)\in D\}$, where $\lambda$ is the uniform measure.
* The universal function machine $V$ first reads a self-delimiting code $\langle T\rangle$ from $\omega$ and then runs $T$ on $x$ with the rest of the tape. Every input reads the same code, because it is a prefix of $\omega$. Hence
$$M_F(D):=\mu_V(D)=\sum_T2^{-|\langle T\rangle|}\mu_T(D)\ \ge\ 2^{-|\langle T\rangle|}\mu_T(D).$$
* Randomness is **shared** across inputs: one tape serves all inputs.
* A *product* (private-randomness) hypothesis is $\prod_{(x,y)\in D}P(y\mid x)$ for a conditional law $P$. It is a $\mu_T$ for a machine that reads input-specific bits of $\omega$ (dovetailed streams).

**Conventions.**
* For $\nu\in\{W,M_F\}$, the **semimeasure-convention** conditional is $\nu(E\mid D):=\nu(D\cup E)/\nu(D)$.
* The **normalised** one-step conditional is $\nu_{\rm norm}(y\mid x,D):=\nu(D+(x,y))/\sum_{y'}\nu(D+(x,y'))$. It is always $\ge\nu(y\mid x,D)$, so every *lower* bound on a probability proved in the semimeasure convention also holds normalised.
* For a computable $f$ and inputs $x_1,x_2,\dots$, write $D_k=\{(x_j,f(x_j)):j\le k\}$. The **posterior error** at step $k$ is $e_k:=1-\nu(f(x_k)\mid x_k,D_{k-1})$: the posterior mass that is wrong *or undefined* at $x_k$.

**Two facts used throughout.**
* **(F1) Chain rule / order independence** [proved, trivial]. For every enumeration of $D_n$,
$$\sum_{k\le n}-\log_2\nu(y_k\mid x_k,D_{k-1})=-\log_2\frac{\nu(D_n)}{\nu(\emptyset)},$$
by telescoping. In particular the total loss does not depend on the order. It is also $\le-\log_2\nu(D_n)$, since $\nu(\emptyset)\le1$.
* **(F2) Conditional coding theorem** [known: Levin; Li & Vitányi, *An Introduction to Kolmogorov Complexity and Its Applications*, §4.3, (unverified exact theorem numbers)]. Let $z\mapsto\mu(\cdot\mid z)$ be a family of semimeasures on a countable set ($\sum_x\mu(x\mid z)\le1$), lower semicomputable uniformly in $z$. Then $\mu(x\mid z)\le2^{-K(x\mid z)+c_\mu}$. The constant can be taken independent of the family member when $z$ is itself a program that lower-semicomputes $\mu(\cdot\mid z)$.

---

## 2. Out-of-distribution generalisation (H8)

Throughout, "property" means a set $Q\subseteq X$. $Q$ **separates** $x^*$ from a training set $A$ if $x^*\in Q$ and $Q\cap A=\emptyset$. $K(Q,b)$ is the length of a shortest self-delimiting code $z$ for a pair $(q,r)$, where $q$ is a total program deciding $Q$ and $r$ a program computing $b$ (on $Q\cap\operatorname{dom}b$). Up to $O(1)$ this is $K$ of the pair, and $K(Q,b)\le K(Q)+K(b)+O(1)$.

### 2.1 Hänni's proposition, with no log term

**Proposition 2.1 (unseen simple property ⇒ constant probability of any simple behaviour) [proved].**
Let $Q$ be decidable and $b$ partial computable. Let $D$ be a data set with $\operatorname{dom}D\cap Q=\emptyset$. Let $S\subseteq Q\cap\operatorname{dom}b$ be finite and $E:=b|_S$. Then, with $c$ depending only on $U$ (resp. $V$):
1. $W(D\cup E)\ge2^{-K(Q,b)-c}\,W(D)$. Moreover the set of programs consistent with $D$ that agree with $b$ on **all** of $Q\cap\operatorname{dom}b$ has $W$-weight $\ge2^{-K(Q,b)-c}W(D)$.
2. $M_F(D\cup E)\ge2^{-K(Q,b)-c}\,M_F(D)$, and likewise for the event "agrees with $b$ on all of $Q\cap\operatorname{dom}b$".
3. The shortest program consistent with $D\cup E$ is at most $K(Q,b)+c$ bits longer than the shortest program consistent with $D$.

Hence, in both conventions, the posterior probability that SFI behaves like $b$ on all of $S$ is at least $2^{-K(Q,b)-c}$, whatever $D$ is and however large it is. For example, with $b\equiv0$: SFI outputs $0$ on all unseen $Q$-inputs with probability at least $2^{-K(Q)-c}$.

*Proof.*
1. Let $w$ be the code of the "wrapper" machine. It reads a self-delimiting pair code $z=\langle q,r\rangle$ and then a program $p\in\mathcal P$. On input $x$ it outputs $U(r,x)$ if $U(q,x)=1$, and $U(p,x)$ otherwise.
   * The programs $wzp$ form a prefix-free subset of $\mathcal P$, and $p\mapsto wzp$ is injective.
   * If $p$ is consistent with $D$, so is $wzp$, because inputs of $D$ are not in $Q$. And $wzp$ agrees with $b$ on all of $Q\cap\operatorname{dom}b$.
   * Summing over consistent $p$: $W(D\cup E)\ge\sum_p2^{-|w|-|z|-|p|}=2^{-|w|-|z|}W(D)$. Take $|z|=K(Q,b)$ and $c=|w|$.
2. Let $T_{Q,b}(x,\omega):=b(x)$ if $x\in Q$, and $V(x,\omega)$ otherwise.
   * For every $\omega$ with $V(x,\omega)=y$ for all $(x,y)\in D$, we have $T_{Q,b}(x,\omega)=y$ on $D$ and $=b(x)$ on $Q\cap\operatorname{dom}b$. So $\mu_{T_{Q,b}}(D\cup E)\ge M_F(D)$.
   * The machine $T_{Q,b}$ has a code $w'z$ of length $K(Q,b)+c$. Universality gives $M_F(D\cup E)\ge2^{-K(Q,b)-c}M_F(D)$.
   * The infinite event is a countable intersection of open sets, and the same inclusion applies to it.
3. This is part 1 applied to a single shortest $p$. ∎

**Remark 2.2 (where a log term would come from).** Hänni asked whether "some log term" is lost, and whether the universal semimeasure avoids it.
* **No log term arises in either version.** The modified program is the concatenation of three self-delimiting codes, so its length is the sum. The proof also sums over *all* consistent programs, not just the best one, so the posterior ratio is exactly controlled.
* The semimeasure $M_F$ is not needed for this.
* A log term appears in three situations:
  * (i) If the complexity of $Q$ is measured by **plain** complexity $C(Q)$. Then one pays $K(Q)\le C(Q)+K(C(Q))+O(1)\le C(Q)+2\log C(Q)+O(1)$.
  * (ii) If $Q$ is only **semi-decidable**. The wrapper cannot decide $Q$, so it must race "$Q$ accepts $x$" against "$p$ halts on $x$", and the bound is lost for programs that halt first. Replacing $Q$ by a decidable subset $Q_t=\{x: Q\text{ accepts }x\text{ within }t(|x|)\text{ steps}\}$, for a simple computable $t$, restores the bound for inputs in $Q_t$.
  * (iii) If one insists on comparing a *single* modified program with the *total* posterior, rather than summing. Then the bound is $2^{-K(Q,b)-c}$ times the posterior weight of the chosen program.

**Proposition 2.3 (properties simple given a good training program) [proved].** Let $p\in\mathcal P$ be consistent with $D$. Let $q,r$ be programs that take $p$ as an auxiliary input: $Q_p:=\{x:U(q,\langle p,x\rangle)=1\}$ is decided by $q$, and $b_p(x):=U(r,\langle p,x\rangle)$. Write $K(Q_p,b_p\mid p)$ for the shortest code of such a pair. If $Q_p\cap\operatorname{dom}D=\emptyset$ and $S\subseteq Q_p\cap\operatorname{dom}b_p$ is finite, then
$$W(b_p|_S\mid D)\ \ge\ 2^{-K(Q_p,b_p\mid p)-c}\cdot\frac{2^{-|p|}}{W(D)},$$
that is, $2^{-K(Q_p,b_p\mid p)-c}$ times the posterior probability of the program $p$.

*Proof.* The wrapper program $wzp$ evaluates $q$ and $r$ on $\langle p,x\rangle$; it has length $|w|+|z|+|p|$. It is consistent with $D\cup b_p|_S$. ∎

This is Hänni's worry about "an internal variable set to 0". If the MAP program has an internal variable whose value never triggers on training inputs, then a test property defined through that variable is simple *relative to the program* even if it is complex in absolute terms. When the MAP program carries a constant fraction of the posterior, bad behaviour on that property gets probability $2^{-O(\text{bits to name the variable})}$.

**Proposition 2.4 (dependence on the programming language) [proved].** Fix $U$, a decidable $Q$ and a partial computable $b$. Define $U'(0p,x):=U(p,x)$ and $U'(1p,x):=b(x)$ if $x\in Q$, else $U(p,x)$. Then:
* $U'$ is a universal prefix machine.
* For every $D$ with $\operatorname{dom}D\cap Q=\emptyset$ and every finite $S\subseteq Q\cap\operatorname{dom}b$: $W'(D)=W(D)$ and $W'(b|_S\mid D)\ge1/2$.
* Conditional probabilities under $U$ and $U'$ differ by at most a factor $2^{K(Q,b)+c}$.

*Proof.*
* The programs $0p$ consistent with $D$ have total weight $W(D)/2$.
* The programs $1p$ consistent with $D$ also have total weight $W(D)/2$, because they agree with $p$ off $Q$. All of them output $b$ on $S$.
* $U$ simulates $U'$ with overhead $K(Q,b)+c$ (the wrapper of Prop 2.1), and $U'$ simulates $U$ with overhead 1. So $2^{-K(Q,b)-c}W'\le W\le2W'$. ∎

So Hänni's "there's a programming language in which [good behaviour] doesn't have a better const" is right. The language must be at least about $\log_2(\text{posterior odds})$ bits away from the reference machine, and it is tailored to one property and one behaviour.

### 2.2 The PDF draft's two-sided "result", reconstructed

The draft (`hanni-sfi-draft-2025-09.txt`, §3) says: "the probability of $P$-abiding generalization is at least $2^{-C(P)}$". It also says: "if no input with property $Q$ is seen during training, then probability of $P$-abiding generalization is at most $2^{-C(Q)}$ times 2 to the negative complexity of the smallest string not satisfying $P$ on the given input times a const". Here $P\subseteq X\times Y$ is a property of input–output pairs (e.g. "$y$ is a correct proof of $x$").

**Theorem 2.5 (two-sided bound on $P$-abiding generalisation) [proved].** Let $Q$ be decidable and $D$ a data set with $\operatorname{dom}D\cap Q=\emptyset$. Let $S\subseteq Q$ be finite and nonempty, and $\nu\in\{W,M_F\}$. $K(P,Q)$ denotes the shortest code of a pair (decider for $Q$, enumerator of $P$ or of its complement, as appropriate).
1. **Lower bound.** Suppose $P$ is r.e. and every $x\in Q$ has some $y$ with $(x,y)\in P$. Then $\nu(\text{every }x\in S\text{ gets a }P\text{-abiding output}\mid D)\ge2^{-K(P,Q)-c}$.
2. **Upper bound.** Suppose $(X\times Y)\setminus P$ is r.e. (e.g. $P$ decidable) and every $x\in Q$ has some $y$ with $(x,y)\notin P$. Then $\nu(\text{some }x\in S\text{ gets a }P\text{-violating output}\mid D)\ge2^{-K(P,Q)-c}$. Consequently $\nu(\text{every }x\in S\text{ is }P\text{-abiding}\mid D)\le1-2^{-K(P,Q)-c}$.
3. **Single-input form.** For $x\in Q$ and any $z$ with $(x,z)\notin P$: $M_F((x,z)\mid D)\ge2^{-K(Q)-K(z\mid x)-c}$, and $W((x,z)\mid D)\ge2^{-K(Q)-K^{\mathcal P}(z\mid x)-c}$. So, for $M_F$, the probability of a $P$-abiding output at $x$ is at most $1-2^{-K(Q)-\min_{z:(x,z)\notin P}K(z\mid x)-c}$, and for $W$ the same holds with $K^{\mathcal P}$.

*Proof.*
1. Let $b_P(x)$ be the first $y$ found in a fixed enumeration of $P$ with first coordinate $x$. It is partial computable, total on $Q$, and $K(Q,b_P)\le K(P,Q)+O(1)$. Apply Prop 2.1.
2. Same with $b_{\neg P}$, from an enumeration of the complement. For the consequence: the events "all abiding" and "some violating" are disjoint sets of labellings of $S$. For any semimeasure on partial functions, $\sum_E\nu(D\cup E)\le\nu(D)$ over the labellings $E$ of $S$. (For $W$: disjoint sets of programs. For $M_F$: disjoint sets of tapes.)
3. *For $W$:* let $h\in\mathcal P$ be a shortest program with $U(h,x)=z$, so $|h|=K^{\mathcal P}(z\mid x)$. Apply Prop 2.1 with $b:=U(h,\cdot)$, using $K(Q,b)\le K(Q)+|h|+O(1)$.
   *For $M_F$:* let $T(x',\omega)$ split $\omega$ into its even and odd bits. If $x'\in Q$, $T$ runs the universal *conditional* prefix machine on $x'$, reading program bits lazily from the odd bits; otherwise it runs $V(x',\cdot)$ on the even bits. The two bit streams are independent and uniform. So $\mu_T(D+(x,z))=M_F(D)\cdot\sum\{2^{-|q|}:q\text{ outputs }z\text{ on }x\}\ge M_F(D)\,2^{-K(z\mid x)}$. Universality costs $K(Q)+c$. ∎

**Reading of the draft.**
* Its upper bound must be read as a lower bound on the probability of *violation*, or equivalently as "abiding probability $\le1-(\ldots)$". This is part 3, with "the smallest string not satisfying $P$" as the simplest violating output.
* Taking $z_x$ to be the first violating output in an enumeration gives $K(z_x\mid x)\le K(P)+O(1)$. So part 3 contains part 2's form for each input.
* The draft's summary sentence ("good ood generalization ... has at least a const probability of happening but also at least some const probability of not happening") is then exactly Theorem 2.5 parts 1–2. It holds uniformly in the amount of training data, as long as no training input lies in $Q$.

**Proposition 2.6 (the draft's two bounds as literally stated are false) [refuted, with counterexamples; proved].**
* (a) *Literal upper bound.* Let $P=\{(x,0)\}$ ("output 0"). Let $Q_n$ be decidable properties with $K(Q_n)\to\infty$, let $D$ label inputs outside $Q_n$ with 0, and let $x^*\in Q_n$. The constant-0 program $p_0$ is consistent with $D\cup\{(x^*,0)\}$. So $\nu((x^*,0)\mid D)\ge2^{-|p_0|}/\nu(D)\ge2^{-|p_0|}$, a fixed positive constant. The literal claim $\le c\cdot2^{-K(Q_n)}2^{-K(z)}$ tends to 0. Contradiction for large $n$.
* (b) *"At least $2^{-C(P)}$" without a separating property.* Again let $P=\{(x,0)\}$, so $K(P)=O(1)$. Fix $n$ and $x^*\in\{0,1\}^n$ with $K(x^*\mid n)\ge n$. Let $D=\{(x,1):x\in\{0,1\}^n,\ x\ne x^*\}$ (a training set of size $2^n-1$). Then
$$\nu((x^*,0)\mid D)\le2^{-n+c'}\qquad(\nu\in\{W,M_F\}).$$
  * *Proof.* Let $\mu_n(x):=\nu(\{(x',1):x'\ne x\}\cup\{(x,0)\})$ for $x\in\{0,1\}^n$. These are disjoint events, so $\sum_x\mu_n(x)\le1$. And $\mu_n$ is lower semicomputable uniformly in $n$. By (F2), $\mu_n(x^*)\le2^{-K(x^*\mid n)+c}\le2^{-n+c}$. The constant-1 program gives $\nu(D)\ge2^{-c_1}$. ∎
  * So the probability of $P$-abiding output is far below $2^{-K(P)}$. Theorem 2.5(1) with $Q=\{x^*\}$ ($K(Q)\le n+2\log n+c$) gives the lower bound $2^{-n-2\log n-c}$. So the $K(Q)$ term in Theorem 2.5 is necessary and nearly tight here.

### 2.3 OOD failure is a bounded resource

**Theorem 2.7 (cumulative bound) [proved].** Let $f$ be computable by a program of length $K_F(f)$. Let $x_1,x_2,\dots$ be any sequence of distinct inputs; it may be adversarial, chosen adaptively, or uncomputable. Then for every $n$, with $c=0$ for $W$ and a machine constant for $M_F$:
$$\sum_{k\le n}-\log_2(1-e_k)\le K_F(f)+c,\qquad\sum_{k\le n}e_k\le(\ln2)(K_F(f)+c),\qquad\#\{k:e_k\ge\delta\}\le\frac{(\ln2)(K_F(f)+c)}{\delta}.$$
The same holds with $e_k$ replaced by the (smaller) normalised error, and with $K_F(f)$ replaced by $K_B(f)$ for $B=\{x_1,\dots,x_n\}$.

*Proof.* By (F1) the left sum equals $-\log_2(\nu(D_n)/\nu(\emptyset))\le-\log_2\nu(D_n)$. For $W$, $W(D_n)\ge2^{-K_F(f)}$; for $M_F$, $M_F\ge2^{-c}W$. Then use $-\ln(1-e)\ge e$, and Markov's inequality for the count. ∎

**Proposition 2.8 (the novelty budget) [proved].** For binary $Y$, let $\sigma_k:=\min\{K(Q):Q\text{ decidable},\ x_k\in Q,\ Q\cap\{x_1,\dots,x_{k-1}\}=\emptyset\}$. Then
$$2^{-c}\sum_k2^{-\sigma_k}\ \le\ \sum_ke_k\ \le\ (\ln2)(K_F(f)+c),\qquad\text{and}\qquad\sum_k2^{-\sigma_k}\le1.$$

*Proof.*
* Lower bound: Prop 2.1 with $b\equiv1-f(x_k)$, a constant of complexity $O(1)$, gives $e_k\ge2^{-\sigma_k-c}$.
* $\sum_k2^{-\sigma_k}\le1$: a fixed $Q$ can separate $x_k$ from its predecessors for at most one $k$, since once some $x_k\in Q$ has been seen $Q$ separates no later input. So distinct $k$ use distinct minimising $Q$'s. Their shortest codes are distinct elements of a prefix-free set, and Kraft's inequality applies. ∎

So SFI's total OOD error over any sequence lies between the input sequence's "novelty" and $f$'s complexity.
* Each simple property can cause surprise only once.
* After the shifts of some kind have been seen, they stop being shifts in the sense that matters. This is a precise form of Hänni's "fake OOD generalization ... where you've already seen many 'ood generalizations' of the same kind".
* Combined with the $x$-only dominance theorem (H2, foundations track), the positive statement is relative. If a computable $x$-only predictor $P$ generalises correctly across all the shifts, SFI's total excess log loss over $P$ is at most $K(P)+O(1)$ bits.
* Hänni's "human inductor" argument needs more than this: the human generalises *after seeing the data*, i.e. is history-aware. The $x$-only theorem does not cover such predictors (H3). The chronological version (H4) is needed.

### 2.4 Positive results, and why the naive converse fails

**Proposition 2.9 (random splits generalise, for every input set) [proved; computed, c3 Part 3].** Let $B$ be any finite set of inputs, $|B|=N$, possibly chosen adversarially, and $f$ any labelling of $B$. Choose a uniformly random order $x_{\pi(1)},\dots,x_{\pi(N)}$ of $B$ and an independent uniform split point $k\in\{1,\dots,N\}$. Train on the first $k-1$ inputs and test on the $k$-th. Then
$$\mathbb E_{\pi,k}\big[-\log_2\nu(f(x_{\pi(k)})\mid x_{\pi(k)},D_{\pi,k-1})\big]=\frac{-\log_2(\nu(f|_B)/\nu(\emptyset))}{N}\le\frac{K_B(f)+c}{N},$$
and $\mathbb E[e]\le(\ln2)(K_B(f)+c)/N$.

*Proof.* By (F1), for each $\pi$ the sum over $k$ of the step losses equals the order-free total. Average over uniform $k$. ∎

*Comment.* A random split leaves no property that systematically separates test from train: any fixed property must "guess" which point is the test point. The statement holds with *no* assumption on how $B$ was chosen. The expectation over the split point is essential (next two items). Monte Carlo on a toy mixture: $1.8230\pm0.0071$ against total$/N=1.8200$ [computed, c3].

**Proposition 2.10 (leave-one-out: the elementary bound) [proved].** For $\nu\in\{W,M_F\}$ and $f$ on $B$, $|B|=N$, with $e_{\rm LOO}(x):=1-\nu(f|_B)/\nu(f|_{B\setminus x})$:
$$\frac1N\sum_{x\in B}e_{\rm LOO}(x)\le\frac{\nu(\emptyset)-\nu(f|_B)}{N\,\nu(f|_B)}<\frac{2^{K_B(f)+c}}{N}.$$

*Proof.* $e_{\rm LOO}(x)\nu(f|_{B\setminus x})$ is the mass of hypotheses (programs or tapes) that are correct on $B\setminus x$ and not correct at $x$. These sets are disjoint for different $x$: such a hypothesis fails at exactly one point of $B$. None of them is correct on all of $B$. So the sum is $\le\nu(\emptyset)-\nu(f|_B)$. Finally $\nu(f|_{B\setminus x})\ge\nu(f|_B)$. ∎

**Remark 2.11 (learning curves can increase; leave-one-out for SFI) [computed, c3 Part 2; conjecture].**
* Consider a Bayes mixture of the truth $f$ (weight $w_f$) and $N$ hypotheses each wrong at exactly one point of $B$ (weight $w$ each). The step-$k$ loss $\log_2\frac{w_f+w(N-k+1)}{w_f+w(N-k)}$ is the same for every order and **increases** with $k$.
* With $w=w_f=1/(N+1)$ and $N=16$: the last step (leave-one-out) costs 1 bit, while the random-split average is $0.255$ bits [computed]. Kraft's inequality allows this only with $N\le2^{K}-1$ when $w=w_f=2^{-K}$. So Prop 2.10 is tight up to constants for general prior-weighted mixtures.
* For SFI's weights I conjecture more. **Conjecture:** $\frac1N\sum_xe_{\rm LOO}(x)=O(K_B(f)/N)$, up to logarithmic factors.
  * Heuristic: the natural one-exception hypotheses "$f$ except at $x$" have weight $2^{-K(f)-K(x\mid f)}$. Their total contribution is $\le\sum_x2^{-K(x\mid f)}\le1$.
  * In the examples I tried (indicators of random sets) the number of bad leave-one-out points is at most about $K(f)$.
  * I have no proof.

**Proposition 2.12 (separating properties are typical even in distribution) [proved; computed, c4].** Let $f\equiv0$ on $\{0,1\}^n$. Let $x_1,\dots,x_m$ be i.i.d. uniform training inputs and $x^*$ an independent uniform test input, with $n\ge\ell:=\lceil\log_2m\rceil+1$. Let $\pi$ be the $\ell$-bit prefix of $x^*$ and $Q_\pi=\{x:x\text{ starts with }\pi\}$. Then:
1. $\Pr[Q_\pi\text{ separates }x^*\text{ from the training set}]=(1-2^{-\ell})^m\ge1-m2^{-\ell}\ge1/2$.
2. $K(Q_\pi)\le\ell+2\log_2(\ell+1)+c$.
3. $\mathbb E[e(x^*)]\ge\frac12\cdot2^{-\ell-2\log_2(\ell+1)-c}\ge\frac{2^{-c}}{8m(\log_2m+3)^2}$, for $W$ and $M_F$ in either convention.

*Proof.* Part 1: each training input independently fails to share the prefix with probability $1-2^{-\ell}$, then Bernoulli's inequality. Part 2: an Elias-type code for $\pi$. Part 3: Prop 2.1 with $b\equiv1$ on the event of part 1, and $2^{-\ell}\ge1/(4m)$. ∎

* The Cesàro upper bound from Theorem 2.7 (per sequence, so also in expectation over i.i.d. inputs) gives $\frac1{m+1}\sum_{k\le m+1}\mathbb E[e_k]\le(\ln2)(K(0)+c)/(m+1)$.
* So in distribution the separation lower bound is tight up to $\log^2m$, in the Cesàro sense.
* For general binary $f$, take $b=1-f$: $\mathbb E[e]\ge2^{-K_F(f)-c}/(8m(\log_2m+3)^2)$.
* Computed (c4, $n=48$): the separating complexity $\sigma$ (1 + the longest common prefix with a training input) has median $\approx\log_2m+1$. $\Pr[\sigma\le\lceil\log_2m\rceil+1]\in[0.63,0.76]$, matching the exact value. $m\cdot\mathbb E[2^{-\sigma-2\log_2(\sigma+1)}]\cdot\log_2^2m$ stays in $[0.45,0.68]$ for $m=10,\dots,10^4$.

*What "no simple separating property" can mean.* Prop 2.12 shows that for $m$ i.i.d. training inputs a separating property of complexity $\log_2m+O(\log\log m)$ exists with probability $\ge1/2$. So "no simple property separates test from train" can hold typically only at scales $s\lesssim\log_2m$.

**Proposition 2.13 (the naive converse is false at every feasible scale) [proved].** Let $f:\{0,1\}^n\to\{0,1\}$ be uniformly random, and $A=\{x_1,\dots,x_m\}$, $x^*$ i.i.d. uniform, all independent.
1. For SFI in either version and convention, $\mathbb E[e(x^*)\mid x^*\notin A]\ge1/2$. In fact this holds for every learner.
2. Let $z$ be any string determined by $f$ (e.g. a shortest program for $f$). For every $s\ge0$,
$$\Pr\big[\exists\text{ decidable }Q:\ K(Q\mid z)\le s,\ Q\text{ separates }x^*\text{ from }A\big]\le\frac{2^{s+1}}{m+1}.$$
   So with $s=\log_2(m+1)-\log_2(1/\eta)-1$ the probability is $\le\eta$.

*Proof.*
1. Given $(A,f|_A,x^*)$ with $x^*\notin A$, the label $f(x^*)$ is a fair coin independent of the predictor's output $(\nu(0),\nu(1))$, where $\nu(0)+\nu(1)\le1$. So $\mathbb E[1-\nu(f(x^*))]=1-\frac{\nu(0)+\nu(1)}2\ge\frac12$.
2. Condition on $f$, hence on $z$. Fewer than $2^{s+1}$ properties have $K(Q\mid z)\le s$. For each, with density $\delta$ in $\{0,1\}^n$, $\Pr[x^*\in Q,\ A\cap Q=\emptyset]=\delta(1-\delta)^m\le\max_\delta\delta(1-\delta)^m=\frac1{m+1}\big(\frac m{m+1}\big)^m\le\frac1{m+1}$. Take a union bound. ∎

So "no property separating test from train that is simple relative to a good training program" does not imply good generalisation. The obstruction is information-theoretic (too little data relative to $K(f)$), not a defect of SFI. A positive statement must therefore be relative to what any learner could do, as in Theorem 2.7 with dominance, or be about random splits (Prop 2.9). The following sandwich shows what governs a single test error.

**Proposition 2.14 (sandwich for a single test point) [proved].** Let $A$ be finite, $x^*\notin A$, $B=A\cup\{x^*\}$, $y\ne f(x^*)$, and $\lambda_y:=f|_A\cup\{(x^*,y)\}$. Then
$$2^{-K(Q,b)-c}\ \le\ W(\lambda_y\mid f|_A)\ \le\ 2^{K_A(f)-K(\lambda_y\mid B)+c}$$
for every decidable $Q$ separating $x^*$ from $A$ and every program $b$ with $b(x^*)=y$.

*Proof.* The left inequality is Prop 2.1. For the right one:
* For a finite set $B$ (given as a list), $\lambda\mapsto W(\lambda)$ on labellings of $B$ is a semimeasure: the program sets are disjoint. It is lower semicomputable uniformly in $B$. By (F2), $W(\lambda_y)\le2^{-K(\lambda_y\mid B)+c}$.
* Also $W(f|_A)\ge2^{-K_A(f)}$. ∎

*Reading.*
* SFI errs at $x^*$ only if some wrong completion $\lambda_y$ of the training labels is, **given the full input set $B$**, not much more complex than the training labels are to produce **by a program that does not know $A$**.
* A simple separating property makes $\lambda_y$ cheap given $B$: $x^*$ is the unique element of $B\cap Q$.
* The gap between $K(\cdot\mid B)$ and $K_B(\cdot)$ is exactly where knowledge of the other inputs would help. It is the same gap as between $x$-only and history-aware prediction (H3/H4).

**Example 2.15 (easy-to-hard generalisation) [proved].**
* *Setting.* Inputs are sentences of a consistent theory $T$ with decidable proof checking (a recursively axiomatised theory, after Craig's trick). The label is 1 if $T$ proves the sentence and 0 if $T$ refutes it. The training statements all have a proof or refutation of length $\le L$. The test statement $x^*$ is decidable in $T$, but its shortest proof or refutation is longer than $L':=2^{\lceil\log_2L\rceil}\ (\le2L)$.
* Let $Q:=\{x:\text{no proof or refutation of }x\text{ of length}\le L'\}$. It is decidable given $T$ and $L'$, separates $x^*$ from the training set, and $K(Q)\le K(T)+K(\lceil\log_2L\rceil)+c\le K(T)+2\log_2\log_2L+c$ for large $L$.
* By Prop 2.1 with $b\equiv0$ and $b\equiv1$, one of which is wrong at $x^*$, SFI's error at $x^*$ is $\ge2^{-K(Q)-c}\ge2^{-K(T)-c'}/\log_2^2L$. This holds however many easy statements were seen.
* On the other side, the proof-search program (enumerate $T$-proofs; output 1 or 0 when one is found) has length $K(T)+c$ and is consistent with every correctly labelled data set. So the correct label at $x^*$ has probability $\ge2^{-K(T)-c}$.
* Thus SFI's probability of labelling the hard statement correctly lies in $[2^{-K(T)-c},\,1-2^{-K(T)-c'}/\log_2^2L]$. Both ends are independent of the number of training statements.
* This makes precise Hänni's remarks that "easy-to-hard generalization is not a thing" for SI, and that task decomposition creates a simple separating property.
* The same analysis applies to his "counting the lengths of odd strings" example. The correct generalisation to even-length strings has probability in $[2^{-c},1-2^{-c}]$ with machine constants, because "$|x|$ is even" and "output 0" are both $O(1)$ bits.

**2.5 Answer to "the strongest true positive statement".**
1. **Relative generalisation.** No bound of the form "no simple separating property ⇒ small error" holds (Prop 2.13). What holds is relative:
   * SFI's total OOD loss over any sequence of shifts exceeds that of any computable $x$-only generaliser $P$ by at most $K(P)+O(1)$ (H2 + Theorem 2.7).
   * SFI's total error is sandwiched between the input sequence's novelty and $K_F(f)$ (Prop 2.8).
2. **No selection, no failure.** For every input set, a random train/test split gives expected loss $\le K_B(f)/|B|$ (Prop 2.9).
3. **Single test points** are governed by the sandwich (Prop 2.14). In distribution, separation at complexity $\approx\log m$ is unavoidable and costs $\Omega(1/(m\log^2m))$. This is the $O(1/m)$ Cesàro rate up to a $\log^2m$ factor (Prop 2.12).

---

## 3. Computable versions (H10)

### 3.1 Time-bounded SFI

**Setting.**
* $Y$ is finite, $|Y|\ge2$.
* A **probability predictor** is a RAM program $A$ that on input $x$ halts and outputs rationals $(A(y\mid x))_{y\in Y}$, nonnegative and summing to 1. Its running time is $T_A(x)$.
* For nondecreasing $p:\mathbb N\to\mathbb N_{\ge1}$, let $\mathcal C_p:=\{A:\exists c_A\ \forall x\ T_A(x)\le c_Ap(|x|)\}$. A bound that holds only for long inputs can be extended to all inputs by enlarging $c_A$, since there are finitely many short inputs.
* Data are a sequence of **distinct** inputs with arbitrary labels.
* Under the semimeasure convention a repeated input carries no information and no loss, both for SFI and for any random function. So restricting to distinct inputs loses nothing.

**Construction.**
* Enumerate RAM programs $A_1,A_2,\dots$ with weights $w_i=2^{-i}$ (any computable positive weights with a computable sum work).
* Choose activation lengths $n_1<n_2<\cdots$ and a nondecreasing unbounded clock factor $g\ge1$. The running-time claims use $n_i=2^{2^i}$ and $g(n)=\lceil\log_2\log_2(n+4)\rceil$.
* The **clocked** hypothesis is $q_i(\cdot\mid x):=A_i(\cdot\mid x)$ if $|x|\ge n_i$ and $A_i$ halts on $x$ within $g(|x|)p(|x|)$ steps with a valid vector. Otherwise $q_i(\cdot\mid x)$ is uniform, $u$.
* Let $S(D):=\sum_iw_i\prod_{(x,y)\in D}q_i(y\mid x)$. Each term is a product of probability vectors, so $\sum_yS(D+(x,y))=S(D)$ and $S(\emptyset)=1$.
* The learner predicts $S(y\mid x_k,D_{k-1})=S(D_{k-1}+(x_k,y))/S(D_{k-1})$.

**Theorem 3.1 (time-bounded SFI) [(a) proved; (b) proof sketch; computed, c5].**
* **(a) Constant regret.** Let $A=A_i\in\mathcal C_p$ with constant $c_A$, and $N_A:=\max(n_i,\min\{n:g(n)\ge c_A\})$. For every sequence of distinct inputs, all labels and all $k$:
$$\sum_{j\le k}-\log_2S(y_j\mid x_j,D_{j-1})-\sum_{j\le k}-\log_2A(y_j\mid x_j)\ \le\ \log_2\tfrac1{w_i}+\#\{j\le k:|x_j|<N_A\}\log_2|Y|\ \le\ \log_2\tfrac1{w_i}+(2^{N_A}-1)\log_2|Y|.$$
* **(b) Running time.** $S$ can be run online, with round $k$ costing:
  * $a(|x_k|):=\#\{i:n_i\le|x_k|\}\le\log_2\log_2|x_k|+1$ simulations of $g(|x_k|)p(|x_k|)$ steps each;
  * plus $O(a(|x_k|))$ arithmetic operations on stored weights;
  * plus $O(1)$ bookkeeping.
  
  With floating-point weights at relative precision $k^{-2}$ the cumulative loss changes by $O(1)$, and the numbers have $O(\log k+\log p)$ bits.

*Proof of (a).*
* By (F1) and $S(\emptyset)=1$, the learner's cumulative loss is $-\log_2S(D_k)\le\log_2(1/w_i)+\sum_{j\le k}-\log_2q_i(y_j\mid x_j)$.
* For $|x_j|\ge N_A$: $A$ is active and finishes within $c_Ap\le g(|x_j|)p$ steps, so $q_i(\cdot\mid x_j)=A(\cdot\mid x_j)$.
* For $|x_j|<N_A$: $-\log_2q_i(y_j\mid x_j)=\log_2|Y|\le\log_2|Y|-\log_2A(y_j\mid x_j)$.
* Subtract $A$'s loss. There are at most $2^{N_A}-1$ distinct strings shorter than $N_A$. ∎

*Proof sketch of (b).*
* Store $v_i:=w_i|Y|^k\prod_{j\le k}q_i(y_j\mid x_j)$ for the machines with $n_i\le\max_{j\le k}|x_j|$. Every other machine has $v_i=w_i$. Then $S(D_k)=|Y|^{-k}V$ with $V:=\sum_iv_i$.
* A machine inactive at $x_k$ ($n_i>|x_k|$) has $q_i=u$. Its $v_i$ is unchanged by round $k$, since $|Y|\cdot u(y)=1$. Hence
$$S(y\mid x_k,D_{k-1})=\frac{\sum_{i\in\mathrm{act}(x_k)}v_iq_i(y\mid x_k)+(V-\sum_{i\in\mathrm{act}(x_k)}v_i)/|Y|}{V}.$$
* Updating touches only the $a(|x_k|)$ active $v_i$. $V$ is maintained by adding their changes, starting from $\sum_iw_i=1$.
* Precision: relative errors $\varepsilon_k$ in the weights perturb each predictive probability by a factor $1\pm O(\varepsilon_k)$. So the cumulative loss changes by $O(\sum_k\varepsilon_k)$.
* The machine-model details are not written out, notably RAM versus multitape (cf. Hänni's own technical remark).
* The script c5 checks on a toy instance that this incremental algorithm gives the brute-force mixture's predictive probabilities, to $2.5\cdot10^{-16}$. It also checks that the regret against a time-$3|x|$ target stays below the proved constant (132.4 against 184 bits) and is flat once no new short inputs arrive. ∎

**Remark 3.2 (Hänni's "apples to apples" caveat).**
* In his sequence theorem the predictor $P$ sees a growing prefix and gets $p(n)$ time per bit, while $S$ reuses state across steps. The fix lets $P$ reuse state too, with an amortised warm-up.
* In the function setting the natural comparison class is $x$-only predictors. They see one input and have nothing from earlier rounds to reuse, so the comparison in Theorem 3.1 is apples to apples as it stands.
* $S$ keeps state (weights). Every learner must, because it has to accumulate information from data.
* Activating machines by **input length** instead of round number makes the per-round cost depend only on $|x_k|$ (up to the precision term). The regret constant counts short inputs instead of early rounds.
* If the comparison class is enlarged to time-bounded **history-aware** predictors, the right learner is a time-bounded *chronological* mixture. That is sequence prediction with the inputs as free side information. Hänni's amortisation trick then applies verbatim [proof sketch]. The $x$-only $S$ cannot compete with that class even without time bounds: the history-aware predictors in the H3 counterexamples (chain and skipped string) run in time linear in the size of the history.

**Proposition 3.3 (samplers) [proved].**
* Let $A(x;r)$ be a probabilistic RAM program (fair coins $r$) that halts within $c_Ap(|x|)$ steps on all coin sequences, with output law $P_A(\cdot\mid x)$.
* Clock it as above. The probability of an over-budget run is redistributed uniformly.
* Then the same mixture $S$ satisfies Theorem 3.1(a) against every such sampler, with the same proof.
* $S$'s predictive probabilities are computable exactly: each $q_i(y\mid x)$ is a finite sum over at most $2^{g(|x|)p(|x|)}$ coin sequences. So round $k$ costs $O(a(|x_k|)2^{g p}gp)$ steps.

**Question 3.4 (open).** Is there a learner with per-round time polynomial in $p(|x|)$ that has constant regret against all time-$O(p)$ samplers?
* Monte Carlo estimation with $t$ samples per round adds, when probabilities are bounded away from 0 and 1, an expected excess loss of order $1/t$ per round. Constant regret then needs $t_k\to\infty$ with $\sum_k1/t_k<\infty$, so the time per round grows with the round count.
* Impagliazzo and Levin (FOCS 1990, pp. 812–821) [known (snippet): the abstract relates "universal extrapolation" to one-way functions; exact statements unverified] suggest that an efficient version is tied to the non-existence of one-way functions.

### 3.2 Circuit setting

* Fix $d\ge1$ and the basis $G$ of all 16 two-input Boolean gates.
* A circuit of size $s\ge1$ is a list of $s$ gates. Gate $j$ is a type in $G$ and two inputs from $\{x_1,\dots,x_d,0,1,\text{gate}_1,\dots,\text{gate}_{j-1}\}$. The output is gate $s$.
* There are $N_s=\prod_{j=1}^s16(d+1+j)^2$ circuits of size $s$.
* **Prior:** $w(C):=2^{-s}/N_s$ for $C$ of size $s$. This is $2^{-|{\rm desc}(C)|}$ for the prefix-free description "size in unary ($s$ bits), then the gate list in $\log_2N_s$ bits". So it is a description-length prior, and $\sum_Cw(C)=1$.
* $W(D):=\sum\{w(C):C\text{ consistent with }D\}$, $c(f)$ is the minimum circuit size of $f$, and $L(f):=-\log_2W(f)$.
* **Exception gadget.** For $a\in\{0,1\}^d$ and $v\in\{0,1\}$, append gates computing $E_a=[x=a]$: $\max(d-1,1)$ gates, using gates of the form $u\wedge v$, $u\wedge\neg v$, $\neg u\wedge\neg v$. Then add one output gate, $\mathrm{out}\vee E_a$ if $v=1$ or $\mathrm{out}\wedge\neg E_a$ if $v=0$. So $g\le d+1$ gates are added.
* The map $C\mapsto C'$ is injective: $C$ is the first $s$ gates of $C'$. $C'$ agrees with $C$ off $a$ and outputs $v$ at $a$.
* Weight ratio: $w(C')/w(C)=2^{-g}N_s/N_{s+g}\ge2^{-B(s)}$ with $B(s):=g\,(5+2\log_2(d+1+s+g))$.

### 3.3 Circuit Bayes: mistakes and circuit size

**Theorem 3.5 [proved; computed, c1].** Let $x_1,\dots,x_N$ be any ordering of any set $B\subseteq\{0,1\}^d$ (each point once), and $f$ any Boolean function. Let $P_i$ be the posterior probability of the wrong label at step $i$; circuits are total, so this is also the normalised value. Let $m:=\sum_iP_i$, the expected number of mistakes of posterior sampling (Gibbs), and $L_B:=-\log_2W(f|_B)$.
* **(a)** Some circuit of size $\le\lceil L_B\rceil$ agrees with $f$ on $B$, and $L_B\le c_B(f)+\log_2N_{c_B(f)}=O(c_B(f)\log(c_B(f)+d))$. For $B=\{0,1\}^d$: $c(f)\le\lceil L(f)\rceil$.
* **(b)** $m\le(\ln2)L_B$ and $L_B\le2m\,(B(\lceil L_B\rceil)+3)$. Hence $L_B=O(m\,d\log(md+2))$ and $c_B(f)=O(m\,d\log(md+2))$.
* Both directions hold for **every** ordering. The number of mistakes of the Bayes MAP predictor is $\le L_B$ (Remark 3.10).

*Proof.*
* (a), first part: $\sum_{s>S}2^{-s}=2^{-S}$. If no circuit of size $\le S$ agrees with $f$ on $B$, then $W(f|_B)<2^{-S}$. The inequality is strict because at every size there are constant circuits, and one of them disagrees with $f$ on $B\ne\emptyset$. So $2^{-L_B}<2^{-S}$, i.e. $S<L_B$. Take $S=\lceil L_B\rceil$.
* (a), second part: $W(f|_B)\ge w(C_{\min})=2^{-c_B}/N_{c_B}$.
* (b), the first inequality: $P_i\le-\ln(1-P_i)$ and the chain rule (F1). Here $W(\emptyset)=1$ and $W(D_N)=W(f|_B)$.
* (b), the second inequality. Fix $i$ and $S:=\lceil L_B\rceil$.
  * Let $\mathcal R$ (right) and $\mathcal W$ (wrong) be the circuits consistent with $D_{i-1}$ that give $x_i$ the right and wrong label.
  * The gadget map sends $\mathcal W_{\le S}$ (wrong circuits of size $\le S$) injectively into $\mathcal R$. Each image is consistent with $D_{i-1}$: earlier inputs differ from $x_i$, and the gadget changes only the output at $x_i$. So $w(\mathcal W_{\le S})\le2^{B(S)}w(\mathcal R)$.
  * Also $w(\mathcal W_{>S})\le2^{-S}\le2^{-L_B}\le w(\mathcal R)$, since $\mathcal R$ contains every circuit agreeing with $f$ on $B$.
  * So $P_i/(1-P_i)\le2^{B(S)}+1$, and $-\log_2(1-P_i)\le B(S)+2$.
  * Split the chain-rule sum $L_B=\sum_i-\log_2(1-P_i)$. Terms with $P_i\le\frac12$ contribute $\le2P_i$, by convexity: the chord from $(0,0)$ to $(\frac12,1)$. At most $2m$ indices have $P_i>\frac12$, each contributing $\le B(S)+2$. So $L_B\le2m+2m(B(S)+2)$.
  * With $g\le d+1$, $L\le2m[(d+1)(5+2\log_2(2d+4+L))+3]$, which solves to $L=O(md\log(md+2))$. ∎

**Remark 3.6 (relation to Hänni's sketch; where his argument has a gap).**
* *Hänni's direction.* "Expected regret $m$ ⇒ circuit of size $O(m\log m\cdot d)$" is Theorem 3.5(b)+(a), with $\log(md)$ in place of $\log m$, and with three improvements:
  * no expectation over orderings is needed, since one ordering suffices;
  * no Markov step is needed, because the total log loss $-\log_2W(f)$ is order independent, so any single ordering bounds it;
  * the "$+O(\log m)$" he flagged is the $\log(d+s)$ inside $B(s)$, handled by splitting at size $\lceil L\rceil$.
* *The gap.* His sketch goes from "log loss $\le\mathrm{poly}(m)$" to "a circuit of size $\mathrm{poly}(m)$" without argument. That step is a **circuit coding theorem**, and it depends on the prior's size tail.
  * With the exponential tail $2^{-s}$ it is part (a).
  * With a polynomial tail, e.g. an Elias code $\approx2^{-2\log s}$ for the size, the same argument gives only $c(f)\le2^{O(L)}$. A polynomial bound would need that random large circuits rarely compute functions without small circuits. This is open, as far as I know.
  * For random AND/OR *formulas* there are known limit laws relating a function's probability to its formula size [known (snippet): Lefmann–Savický 1997; Chauvin–Flajolet–Gardy–Gittenberger 2004; exact bounds unverified].
* *The converse ("regret $\le$ poly(circuit complexity)").* Hänni proves this for *Occam* learning *in distribution*. For circuit *Bayes* it holds for **every ordering**: $m\le(\ln2)L\le(\ln2)c(f)(5+2\log_2(d+1+c(f)))$.
* *Gibbs versus MAP.* The theorem is stated for Gibbs mistakes $m$. For MAP mistakes the direction "few MAP mistakes ⇒ small circuit" is open. Steps with $P_i$ just below $\frac12$ cost log loss but no MAP mistakes.
* *Other languages.* The proof uses only (i) a size prior with an exponential tail times a uniform choice within each size, and (ii) an injective exception surgery with bounded weight cost. For **formulas** (leaves $x_j,\neg x_j,0,1$; nodes AND, OR, XOR; size = number of leaves; prior $2^{-s}$ times uniform), the surgery adds $d$ leaves. Since $\mathrm{Cat}(n+1)/\mathrm{Cat}(n)<4$, the cost $B=d(1+\log_2(12(2d+2)))$ is *independent of size*.

**Remark 3.7 (computed check, c1: formulas on $d=3$) [computed].**
* All 256 functions have formula size $\le5$.
* $L(f)$ ranges from 2.87 (literals) to 17.66 (size-5 functions).
* For every $f$ and every ordering of the 8 inputs, the following hold, verified exactly by dynamic programming over subsets:
  * $c(f)\le\lceil L(f)\rceil$;
  * $L(f)\le c(f)+\log_2N_{c(f)}$;
  * $m\le(\ln2)L$;
  * $L\le2m_{\min}(B+3)$ with $B=22.75$. The observed maximum of $L/m_{\min}$ is 4.92, against the bound 51.5.
* Order independence of $\sum_i-\log_2(1-P_i)$ holds to $1.8\cdot10^{-14}$.
* Worst-case adversarial mistakes: Occam up to 8 (all inputs), Bayes MAP up to 7.5 (ties count $\frac12$). With 8 inputs these numbers say nothing about asymptotics.

### 3.4 Occam (simplest-consistent) learning

* Fix a prefix-free description language for hypotheses and order hypotheses by (length of shortest description, then that description).
* Let $\ell(f)$ be the length of $f$'s shortest description.
* The Occam learner predicts with the first hypothesis consistent with the data so far.
* It only ever uses hypotheses in $H_f:=\{h:h\text{ precedes or equals }f\}$, and $|H_f|<2^{\ell(f)+1}$.

**Proposition 3.8 (Occam PAC; Hänni's in-distribution theorem) [known: Blumer, Ehrenfeucht, Haussler & Warmuth, *Inf. Process. Lett.* 24(6):377–380, 1987 (snippet); proof standard, included].**
* For any input distribution $\mu$ and i.i.d. samples, $m\ge(\ln|H_f|+\ln(1/\delta))/\varepsilon$ samples give $\Pr[\mathrm{err}_\mu(h_m)>\varepsilon]\le\delta$.
* *Proof.* A fixed $h$ with error $>\varepsilon$ survives $m$ samples with probability $<(1-\varepsilon)^m\le e^{-\varepsilon m}$; take a union bound over $H_f$.
* With $\varepsilon=\delta=0.01$, $m\ge70\,\ell(f)+531$ suffices. So Hänni's "$10^6\cdot C(f)$ samples" is correct when $C(f)$ is the *description length*. If $C(f)$ means gate count, multiply by $O(\log(C(f)+d))$.

**Proposition 3.9 (Occam's expected mistakes in distribution; Hänni's converse direction) [proved].** Let inputs be i.i.d. from $\mu$, with repetitions allowed, and let $p_{\min}$ be the least positive point mass of $\mu$. Then
$$\mathbb E[\#\text{mistakes}]\le6.7+(\ln|H_f|)(1+\ln N)+\ln^2N,\qquad N:=\lceil\ln|H_f|/p_{\min}\rceil.$$
For uniform $\mu$ on $\{0,1\}^d$ this is $O(\ell(f)(d+\log\ell(f))+d^2)$.

*Proof.*
* *Step $n+1$, for $n\ge1$.* $\Pr[\text{mistake}]=\mathbb E[\mathrm{err}(h_n)]\le\varepsilon+|H_f|(1-\varepsilon)^n$ for every $\varepsilon$. With $\varepsilon_n:=\ln(|H_f|(n+1)^2)/n$ this is $\le\varepsilon_n+(n+1)^{-2}$.
* *The first $N$ steps.* Summing (step 1 costs $\le1$) and using $\ln(n+1)\le\ln n+1/n$ and $\sum_{n<N}\frac{\ln n}n\le\frac12\ln^2N+\frac1e$, the expected mistakes in steps $1,\dots,N$ are $\le5.7+(\ln|H_f|)(1+\ln N)+\ln^2N$.
* *After step $N$.* Each mistake is made by the current hypothesis $h_n\in H_f$. It is consistent with $D_N$, wrong on the support of $\mu$, and eliminated by the mistake. So the number of later mistakes is at most the number of such hypotheses surviving $N$ samples. That number has expectation $\le|H_f|(1-p_{\min})^N\le1$. ∎

**Remark 3.10 (Occam out of distribution; Hänni's "physicist's proof").**
* For Occam, the only general OOD bound I know is trivial: each mistake eliminates a distinct member of $H_f$, so there are at most $|H_f|-1=2^{O(\ell(f))}$ mistakes on any ordering.
* Hänni's contrived-language example attains exponentially many.
* For natural languages a super-polynomial lower bound, or a polynomial upper bound, is **open**.
* His "physicist's proof" assumes that when the current guess is wrong, a constant fraction of the competing weight is also wrong. That is exactly the guarantee of the **weighted-majority (Bayes MAP) predictor**: when MAP errs, at least half of the posterior mass errs. So $W(D_i)\le W(D_{i-1})/2$, and the number of MAP mistakes is $\le\log_2(1/W(f|_B))=L_B$ on every ordering [proved].
* This is the halving / weighted-majority argument [known: Littlestone 1988, *Machine Learning* 2:285–318; Littlestone & Warmuth 1994, *Inf. Comput.* 108:212–261 (unverified)].
* So the polynomial OOD mistake bound Hänni wanted holds for circuit **Bayes**: MAP mistakes $\le L=O(c\log(c+d))$. It is open for circuit **Occam**.

---

## 4. NN Bayes and circuit SFI

### 4.1 The exact identity

**Proposition 4.1 [proved, trivial].**
* Let an architecture be a parameter space $\Theta$ with prior $\pi$ and a map $\theta\mapsto f_\theta:\{0,1\}^d\to Y$.
* Let the likelihood depend on $\theta$ only through the values of $f_\theta$ on the data. This covers the 0–1 likelihood and any label-noise model.
* Then the Bayesian posterior predictive of the network equals the function-space Bayes predictive with prior $P_A(f):=\pi\{\theta:f_\theta=f\}$.
* *Proof.* Group the parameter integral by the value of $f_\theta$. ∎
* So "NN Bayes" is "function induction with the prior $P_A$". The question is how $P_A$ compares with $2^{-K}$, the program SFI prior, or with a circuit description-length prior.

### 4.2 The upper bound, and what it does not say

**Proposition 4.2 (coding-theorem upper bound) [proved, given (F2)].**
* Suppose $P_A$, as a semimeasure on truth tables, is lower-semicomputed by a program $a$ (architecture, prior and $d$). Then $P_A(f)\le2^{-K(f\mid a)+c}\le2^{-K(f)+K(a)+c'}$, where $c$ does not depend on the architecture.
* $P_A$ is lower semicomputable in the following cases:
  * for finite parameter sets with rational probabilities [proved];
  * for Gaussian priors on real weights with threshold or sign outputs [proof sketch]. Up to a null boundary, $\{\theta:f_\theta=f\}$ is an open semialgebraic set, and its Gaussian measure is approximable from below by rational boxes certified inside it.

*Proof.* (F2) applied to the family indexed by the program $a$. ∎

* Hänni's version has an extra $\log\log(1/p)$ term. It comes from describing a probability cutoff and is unnecessary.
* The bound is the "simplicity bias" bound of Dingle, Camargo & Louis (*Nat. Commun.* 9:761, 2018) [known (snippet)]. They state it with computable complexity approximations and fitted constants.

**Proposition 4.3 (sampled functions nearly saturate the bound, for any prior) [proved].** For any semimeasure $P$ on truth tables (given $a$) and any $t\ge0$:
$$P\{f:P(f)\le2^{-K(f\mid a)-t}\}\le2^{-t}.$$
So with probability $\ge1-2^{-t}$ over $\theta\sim\pi$, $|{-\log_2P_A(f_\theta)}-K(f_\theta\mid a)|\le\max(t,c)$.

*Proof.* The left side is $\le\sum_f2^{-K(f\mid a)-t}\le2^{-t}$ by Kraft. ∎

This confirms Hänni's later remark that the result "should be true about any low complexity prior on functions — the NNs aren't doing anything here". $P_A$ looks like $2^{-K}$ *on its own typical set*. That set can omit most simple functions.

**Proposition 4.4 (no general lower bound) [proved].**
1. Let $F_d$ be the set of functions computable by architecture $A_d$, with $|F_d|<2^{2^d}$ and membership in $F_d$ decidable given $d$. This covers any finite parameter set, and any fixed real-weight threshold architecture, by Tarski's decision procedure. Then the first truth table $f_d\notin F_d$ has $K(f_d)\le K(d)+c$ and $P_{A_d}(f_d)=0$.
   * For example, a threshold network with $s(d)=2^{o(d)}$ gates computes at most $2^{o(2^d)}$ functions (known counting; unverified constant).
   * So no bound $P_A(f)\ge2^{-aK(f)-b}$ with $a,b$ independent of $d$ holds for such families.
2. The parameter–function-map formalism alone implies no simplicity bias:
   * a lookup-table "architecture" with uniform parameters gives $P(f)=2^{-2^d}$ for every $f$;
   * Hänni's footnote construction gives zero mass to every simple fast function.

### 4.3 Uniform circuit priors and the bridge

**Proposition 4.5 (uniform priors over fixed-size circuits contain the simplicity prior) [proved].** This is one half of Hänni's "first open problem".
* Let $P_{\mathrm{unif},S}$ be the uniform distribution over circuits of size exactly $S$, with output gate $S$. Let $\ell_{\rm circ}(f):=\log_2N_{c(f)}$, the length of the fixed-length gate-list code of a minimal circuit. For every $f$ with $c(f)<S$:
$$P_{\mathrm{unif},S}(f)\ \ge\ \frac{1}{N_{c(f)}\cdot16(d+1+S)^2}\ =\ \frac{2^{c(f)}\,w(C_{\min})}{16(d+1+S)^2}.$$
* Consequently, by the transfer argument of Theorem 2.7 / 3.5(b), Bayes with the uniform size-$S$ circuit prior makes at most $(\ln2)\big(\log_2N_{c(f)}+2\log_2(d+1+S)+4\big)=O(c(f)\log(c(f)+d)+\log S)$ posterior-sampling mistakes on **every** ordering, for every $f$ with $c(f)<S$.

*Proof.*
* Let $C$ be a minimal circuit, of size $s=c(f)$.
* Consider the size-$S$ circuits whose first $s$ gates equal $C$, whose gates $s+1,\dots,S-1$ are arbitrary, and whose last gate is $\mathrm{AND}(\text{gate}_s,\text{gate}_s)$.
* All of them compute $f$. Their fraction is $\prod_{j=s+1}^{S-1}16(d+1+j)^2\big/\prod_{j=1}^S16(d+1+j)^2=1/(N_s\cdot16(d+1+S)^2)$.
* For the mistakes: the cumulative log loss on any ordering is $\le-\log_2P_{\mathrm{unif},S}(f)$, and $m\le(\ln2)\times$ that. ∎

This is the circuit analogue of the padding argument for programs: uniform programs of a fixed length with a free tail give the Solomonoff prior.
* The **other half** is open. It would show that the uniform prior is not much *larger* than the simplicity prior on functions without small circuits, and it is what one needs for "few mistakes ⇒ small circuit" under the uniform prior.
* The difficulty is that exception surgery must now be done *inside* a fixed size, by re-using dead gates.
* Hänni's **second open problem** is also open: getting from an MLP with continuous weights to a circuit prior. The extra difficulty there is that the parts of the network not used by the embedded circuit must not disturb its output.

**What a bridge would give, stated precisely [proved].**
* *Lower half.* If $P_A(f)\ge2^{-a\ell(f)-b}$ for a description length $\ell$ (e.g. circuit description length), then on every ordering NN Bayes makes $\le(\ln2)(a\ell(f)+b)$ Gibbs mistakes and $\le a\ell(f)+b$ MAP mistakes, by the proofs of Theorems 2.7 and 3.5 and Remark 3.10.
* *Upper half.* If also $P_A(f)\le2^{-a'\ell(f)+b'}$, the full-domain log loss is $\ge a'\ell(f)-b'$.
* *The converse (few mistakes ⇒ small circuit)* needs an exception-surgery property of the parameter prior. Hänni's remark that it is "true for NN bayes as well" is **unproved**. For any fixed finite architecture it is trivially true with a bound depending on the architecture size. The content would be a bound in terms of $m$ only, uniform in width.

### 4.4 The NNGP/NTK caveat as a theorem

**Theorem 4.6 [proved; computed, c2].**
* **(a) Walsh diagonalisation.** Let $k(x,x')=\kappa(\langle x,x'\rangle/d)$ on $\{\pm1\}^d$. Then every Walsh character $\chi_S$ is an eigenfunction of $(Tg)(x)=\mathbb E_{x'}k(x,x')g(x')$, with eigenvalue depending only on $|S|$.
  * This covers the NNGP and NTK kernels of fully connected networks with i.i.d. Gaussian weights and biases, since on the cube $\|x\|^2=d$ is constant. [known: NNGP (Lee et al., ICLR 2018) and NTK (Jacot, Gabriel & Hongler, NeurIPS 2018) are functions of inner products and norms (snippet). The diagonalisation is in Yang & Salman, arXiv 1907.10599 (snippet: "eigenvalue depends only on $|S|$").]
* **(b) Dimension lower bound.** Let $V$ be any space of functions on $\{\pm1\}^d$ of dimension $\le n$. For example, $V=\mathrm{span}\{k(x_i,\cdot)\}_{i\le n}$ for any kernel and any training inputs; it contains the GP posterior mean (Gaussian likelihood, any noise level) and the kernel ridge regression solution. Then, in $L^2$ of the uniform distribution,
$$\frac1{\binom dk}\sum_{|S|=k}\ \min_{g\in V}\|\chi_S-g\|^2\ \ge\ 1-\frac n{\binom dk}.$$

*Proof.*
* (a): $k(x,x')=h(x\odot x')$ with $h(z)=\kappa(\sum_jz_j/d)$, where $\odot$ is the coordinatewise product. Substitute $x'=x\odot z$, which is uniform: $(T\chi_S)(x)=\mathbb E_z[h(z)\chi_S(x\odot z)]=\chi_S(x)\,\hat h(S)$. And $\hat h(S)=\mathbb E_z[h(z)\chi_S(z)]$ depends only on $|S|$, because $h$ is invariant under coordinate permutations.
* (b): $\min_{g\in V}\|\chi_S-g\|^2=1-\|P_V\chi_S\|^2$, and $\sum_{\text{all }T}\|P_V\chi_T\|^2=\operatorname{tr}P_V=\dim V\le n$ because the $\chi_T$ are orthonormal. ∎

(b) is the standard "dimension argument" [known (snippet): Kamath, Montasser & Srebro, COLT 2020, Thm 19; D. Hsu, note "dimension argument"].

**Corollary 4.7 (separation from SFI) [proved; computed, c2].**
* *SFI side.* On any sequence of distinct inputs, program SFI on $\chi_S$ ($|S|=k$) has $\sum_te_t\le(\ln2)(K_F(\chi_S)+c)$, with $K_F(\chi_S)\le\log_2\binom dk+2\log_2(k+1)+2\log_2(d+1)+c$.
* For i.i.d. uniform inputs, the posterior-mean predictor $\hat g\in[-1,1]$ has pointwise squared error $\le4e$. Its test mean squared error, averaged over the first $n$ steps, is $\le4(\ln2)(K_F(\chi_S)+c)/n$.
* *Kernel side.* Any kernel method or GP posterior mean needs $n\ge(1-\varepsilon)\binom dk$ samples for average error $\le\varepsilon$ over random $k$-sparse targets. SFI needs $O(k\log d/\varepsilon)$ in the Cesàro sense. The separation is exponential in $k$.
* *Computed* ($d=10$, 20 targets per cell, ridge $10^{-3}$, c2):
  * For two-layer and three-layer ReLU NNGP, NTK and RBF, the kernel error is always above the bound $1-n/\binom dk$.
  * For $k=5$ it stays above 0.68 at every $n\le640$ for all kernels: 0.75 for the three-layer NNGP, 0.68 for RBF, and about 1.5 for the two-layer kernels.
  * The parity-restricted Bayes mixture (prior $2^{-\ell(S)}$) has error 0.000 from $n=20$ ($k=5$) and $n=40$ ($k=3$).
  * Its cumulative Gibbs mistakes (mean 3.7–5.5, max 6.04) are below the proved bound $(\ln2)\ell(S)$ (6.70–9.81).
  * Errors above 1 come from near-interpolation with a small ridge.

**Remark 4.8 (two-layer ReLU kernels never learn odd parities of degree $\ge3$) [proved; computed].**
* The arc-cosine kernel is $\kappa_1(\rho)=\big(\sqrt{1-\rho^2}+\rho(\pi-\arccos\rho)\big)/\pi=\rho/2+\big(\sqrt{1-\rho^2}+\rho\arcsin\rho\big)/\pi$. Apart from $\rho/2$, it is an even function of $\rho$.
* The NTK addition is $\rho\kappa_0(\rho)=\rho/2+\rho\arcsin(\rho)/\pi$, again $\rho/2$ plus an even function.
* A power $\rho^j=(\sum z_i/d)^j$ has a nonzero Walsh coefficient at $S$ only if $j\ge|S|$ and $j\equiv|S|\pmod2$. So the Walsh eigenvalue vanishes for odd $|S|\ge3$, for the two-layer bias-free ReLU NNGP and NTK.
* Then $V=\mathrm{span}\{k(x_i,\cdot)\}\perp\chi_S$, so $\|\chi_S-\hat g\|^2=1+\|\hat g\|^2\ge1$ for every $n$.
* The computed eigenvalues for odd degrees $\ge3$ are below $3\cdot10^{-18}$ in absolute value, i.e. zero to rounding. The three-layer kernel has nonzero odd eigenvalues.
* The arc-cosine kernel is from Cho & Saul, "Kernel methods for deep learning", NeurIPS 2009 [known (unverified)].
* This sharpens Hänni's "polyfit" intuition for these kernels: the kernel prior puts zero weight on those parities.
* For GP *classification* (sign likelihood) the linear-span argument does not apply; that case is **open** here.

### 4.5 What can be said rigorously about "NN Bayes ≈ circuit SFI"

* **Rigorous.**
  * (i) NN Bayes is function-space Bayes with prior $P_A$ (Prop 4.1).
  * (ii) $P_A\le2^{-K+O(K(a))}$, and on its typical set $P_A\approx2^{-K}$, for any prior whatever (Props 4.2–4.3).
  * (iii) No general lower bound holds. Fixed architectures miss $K$-simple functions without small circuits (Prop 4.4). So the right comparison object is **circuit** SFI, not program SFI.
  * (iv) For the "architecture" whose parameters are gate types and wirings, the uniform prior over a fixed size contains the circuit simplicity prior up to $\mathrm{poly}(S)$. It inherits circuit Bayes's mistake bounds on every ordering (Prop 4.5).
  * (v) In the infinite-width Gaussian limits (NNGP/NTK) the predictor is kernel regression diagonal in the Walsh basis. It needs $\binom dk$ samples for $k$-sparse parities where circuit and program SFI need $O(k\log d)$ (Thm 4.6, Cor 4.7). So these limits are *not* circuit SFI, as Hänni said.
* **Open.**
  * Whether finite-width MLP priors with continuous weights admit a two-sided bound $2^{-a\ell_{\rm circ}(f)-b}\lesssim P_A(f)\lesssim2^{-a'\ell_{\rm circ}(f)+b'}$ (Hänni's second open problem).
  * Whether NN Bayes generalises as well as SGD-trained networks at all (Hänni's skepticism, `hanni-bridging-parametrized-bayes-and-solomonoff.md`).
* **Related (unverified).** Vaintrob & Hänni, "Width-Robust Learnability in Mean-Field Bayesian Neural Networks", arXiv 2607.05735 (July 2026) [snippet only; content unverified]. According to the search snippet:
  * the paper defines a "reduced entropy", the prior cost of representing a target to given error;
  * for Boolean-cube targets at fixed depth it shows that polynomial-sample learnability at infinite (mean-field) width, at polynomial width, and polynomially bounded reduced entropy are equivalent.

  If accurate, this is a learnability-equals-prior-cost result of the same shape as Theorem 3.5 and Prop 4.5, for mean-field NN Bayes.
* **Placeholder.** ⟦**CITATION PENDING:** Vaintrob & Hänni, slides on "NN Bayes is kinda like a circuit version of Solomonoff function induction". Link requested; contents not available to this track. Nothing above describes or relies on their content.⟧

### 4.6 The simplicity-bias literature

**The parameter–function map.**
* **Dingle, Camargo & Louis (2018)**, "Input–output maps are strongly biased towards simple outputs", *Nature Communications* 9:761, doi 10.1038/s41467-018-03101-6 [verified (snippet)].
  * Claim: for many maps, $P(x)$ decays exponentially with an approximate complexity of $x$. The upper bound is tight for most inputs.
  * Relation to these notes: Prop 4.2 is the exact (uncomputable) version. Prop 4.3 explains "tight for most inputs" without any property of the map.
* **Valle-Pérez, Camargo & Louis (2019)**, "Deep learning generalizes because the parameter-function map is biased towards simple functions", ICLR 2019, arXiv 1805.08522 [verified (snippet)].
  * Applies the Dingle et al. bound to networks, and proposes PAC-Bayes with a prior over *functions*.
  * Hänni's critique (`hanni-kolmogorov-prior-in-NNs.md`) is that the upper bound holds for every map, and that the needed lower bound fails in general. Props 4.3–4.4 make both points rigorous.
* **Mingard, Valle-Pérez, Skalse & Louis (2021)**, "Is SGD a Bayesian sampler? Well, almost", *JMLR* 22(79):1–64 [verified (snippet)].
  * Empirically, $P_{\rm SGD}(f\mid S)\approx P_B(f\mid S)$ to first order.
  * This bears on Hänni's doubt that NN Bayes and SGD are similar. These notes take no position.
* Mingard et al. (2019), "Neural networks are a priori biased towards Boolean functions with low entropy", arXiv 1909.11522 [unverified].

**No free lunch, Kolmogorov complexity and universal predictors.**
* **Goldblum, Finzi, Rowan & Wilson (2024)**, "Position: The no free lunch theorem, Kolmogorov complexity, and the role of inductive biases in machine learning", ICML 2024, PMLR 235:15788–15808, arXiv 2304.05366 [verified (snippet)].
  * Argues that real data are low-complexity and that networks, even untrained language models, share a preference for low complexity.
* **Lattimore & Hutter (2011/2013)**, "No free lunch versus Occam's razor in supervised learning", in *Algorithmic Probability and Friends* (Solomonoff 85th memorial), LNCS/LNAI 7070, pp. 223–235, arXiv 1111.3846 [verified (snippet)].
  * Gives a Solomonoff-inspired off-line classifier that does well on structured problems, and proves that random selection of training data can reduce misclassification.
  * The latter is related to Prop 2.9; whether it is the same statement is unverified.
* **Grau-Moya, Genewein, Hutter, Orseau et al. (2024)**, "Learning universal predictors", ICML 2024, PMLR 235:16178–16205, arXiv 2401.14953 [verified (snippet)]. Meta-trains networks on data from universal Turing machines to approximate Solomonoff induction.
  * The function analogue is meta-training on $(x,f(x))$ prompts with $f$ drawn from a program prior.

**Amortised function induction.**
* **Müller, Hollmann, Pineda, Grabocka & Hutter (2022)**, "Transformers can do Bayesian inference" (prior-data fitted networks), ICLR 2022, arXiv 2112.10510 [verified (snippet)].
* **Garg, Tsipras, Liang & Valiant (2022)**, "What can transformers learn in-context? A case study of simple function classes", NeurIPS 2022, arXiv 2208.01066 [verified (snippet)].
* Both train a network on prompts $(x_1,y_1,\dots,x_k)$ with $f$ drawn from a prior. The trained network approximates the posterior predictive of function induction *with history in context*, i.e. a chronological predictor (H4).
* With a program or circuit prior this is amortised SFI. This is a natural place where SFI is "central to ML", beyond the "ideal supervised learning" reading (H7).

**Infinite-width limits.**
* Lee et al., "Deep neural networks as Gaussian processes", ICLR 2018 [verified (snippet)].
* Jacot, Gabriel & Hongler, "Neural tangent kernel", NeurIPS 2018, arXiv 1806.07572 [verified (snippet)].
* Yang & Salman, arXiv 1907.10599 [verified (snippet)].
* Neal (1996), *Bayesian Learning for Neural Networks* [known (unverified)].

**Hänni's notes in this area.**
* `hanni-kolmogorov-prior-in-NNs.md`: Props 4.2–4.4 prove its claims and remove its $\log\log$ term.
* `hanni-bridging-parametrized-bayes-and-solomonoff.md`: Prop 4.5 settles one half of its first open problem. Thm 4.6 and Rem 4.8 prove its NNGP/NTK remark for the posterior mean.
* The LessWrong post "Deep Learning is cheap Solomonoff induction?" (dated 7 Dec 2024 per snippet; author shown as "Lucius", surname unconfirmed) [snippet only].

---

## 5. Further results ("anything else")

### 5.1 Order independence as a principle

**Proposition 5.1 (order-independent predictors are Bayesian predictors for random partial functions) [proved; computed, c3 Part 1].**
* A **predictor** assigns to every finite data set $D$ and $x\notin\operatorname{dom}D$ a sub-probability vector $q(\cdot\mid x,D)$ on $Y$.
* It is **order independent** if, for every $D$, the product of its one-step probabilities along an enumeration of $D$ is the same for all enumerations.
* This holds iff there is a function semimeasure $\nu$ whose semimeasure-convention conditionals are $q$. That is, $\nu(\emptyset)=1$, $\sum_y\nu(D+(x,y))\le\nu(D)$, and $q(y\mid x,D)=\nu(D+(x,y))/\nu(D)$ whenever $\nu(D)>0$.
* If moreover every $q$ sums to 1, then $\nu$ extends to a probability measure on $Y^X$, the law of a random function.

*Proof.*
* (⇐) Telescoping.
* (⇒) Let $\nu(D)$ be the common product. Enumerating $D$ first and $x$ last gives $\nu(D+(x,y))=\nu(D)q(y\mid x,D)$. Summing over $y$ gives the semimeasure inequality.
* In the normalised case the finite-dimensional laws $\nu|_{Y^A}$ are consistent under marginalisation, so the Kolmogorov extension theorem applies (Y countable, product of discrete spaces) [known]. ∎

* *Computed (c3).* For a random 6-point mixture with partial and product hypotheses:
  * the semimeasure-convention loss is identical across all 720 orders, $10.919980315195$;
  * the normalised-convention loss varies from 7.33 to 10.64.
* *Reading.* Requiring that an inductor's total surprise on a data set not depend on presentation order singles out exactly the Bayesian predictors over random (partial) functions.
  * History-aware predictors that exploit order, such as the chain predictor of H3, violate it. Their success depends on the order.
  * SFI is the order-independent ideal. SFI$^{\rm hist}$ (H4) is the ideal for order-dependent prediction.

**Corollary 5.2 [proved for function-machine semimeasures; for all lower-semicomputable function semimeasures, conditional on H1(a)].**
* For every function machine $T$, every $D$ and every order: $-\log_2M_F(D)\le-\log_2\mu_T(D)+|\langle T\rangle|$.
* If $M_F$ dominates every lower-semicomputable function semimeasure (H1(a), foundations track), then SFI is universal among lower-semicomputable order-independent predictors.

### 5.2 Chosen inputs (active learning)

**Proposition 5.3 [proved].**
1. For any query set $A$, adaptive or not, the total semimeasure-convention log loss on the labels of $A$ is $-\log_2(\nu(f|_A)/\nu(\emptyset))$, whatever the query order. So for log loss on the queried labels, choosing the order is worthless; only the choice of set matters.
2. Small total loss does not give efficient identification. Let $f_a=[x=a]$ on $\{0,1\}^n$.
   * SFI's total loss on any query sequence, even all of $\{0,1\}^n$, is $\le K_F(f_a)+c\le n+2\log_2n+c$.
   * Yet any query strategy (adaptive, randomised) needs $\ge(2^n-1)/2$ queries in expectation over uniform $a$ to identify $a$. Until $a$ is queried every answer is 0, so the queries are those the strategy makes on $f\equiv0$ (with the same coins). Identification needs $\min(\text{position of }a,\,2^n-1)$ queries, whose mean over uniform $a$ is $\ge(2^n-1)/2$.

So for active learning the log-loss guarantee must be paired with a different objective, such as expected information gain [known (snippet): Orseau, Lattimore & Hutter, "Universal knowledge-seeking agents for stochastic environments", ALT 2013].

### 5.3 Structured outputs

**Proposition 5.4 (single-query SFI and structured outputs) [proved, given (F2)].**
1. *Shared-randomness version.* $M_F(\{(x,y)\})=2^{-K(y\mid x)\pm O(1)}$: single-query SFI is the conditional discrete universal distribution.
2. *Program mixture.* $2^{-K^{\mathcal P}(y\mid x)}\le W(\{(x,y)\})\le2^{-K(y\mid x)+c}$. The lower bound $W(\{(x,y)\})\ge2^{-K(y\mid x)-c}$ **fails** for every constant $c$. So $W$ and $M_F$ differ by more than a constant factor already on single queries.
3. Let $M(\cdot\mid x)$ be the universal monotone (continuous) semimeasure given $x$: SI predicting $y$ symbol by symbol after $x$. Then $2^{-K(y\mid x)}\le2^{c}M(y\mid x)$. But $M(0^n\mid\epsilon)\ge2^{-c}$, while $2^{-K(0^n)}=2^{-K(n)\pm O(1)}$.
4. With an end marker, $M(y\$\mid x)=2^{-K(y\mid x)\pm O(1)}$.

*Proof.*
1. Upper bound: $y\mapsto M_F(\{(x,y)\})$ is a lower-semicomputable semimeasure given $x$; apply (F2). Lower bound: the function machine that runs the universal conditional prefix machine on $x$, reading program bits lazily from $\omega$, outputs $y$ with probability $\ge2^{-K(y\mid x)}$.
2. The bounds: the shortest program in $\mathcal P$ for the lower one, (F2) for the upper one.
   *Failure of the lower bound.* Fix $t$ with $2^{1-t}\le\frac12$. For each $n$ pick $x_n$ of length $n$. At most $2^{n-t+1}$ programs have length $\le n-t$, and each has one output on $x_n$. So at least $2^{n-1}$ strings $y$ of length $n$ get all their $W$-mass from programs longer than $n-t$. Their total mass is at most $P_n:=\sum\{2^{-|p|}:p\in\mathcal P,|p|>n-t\}$, which tends to 0 as $n\to\infty$ (tail of a convergent Kraft sum). Hence some such $y$ has $W(\{(x_n,y)\})\le2P_n2^{-n}$. But $K(y\mid x_n)\le n+c_0$ for every $|y|=n$: read $n=|x_n|$, then $n$ bits. So $W(\{(x_n,y)\})\ge2^{-K(y\mid x_n)-c}$ would force $P_n\ge2^{-c-c_0-1}$ for all $n$. Contradiction.
3. A prefix program for $y$ given $x$ is a monotone program that outputs $y$. A constant program outputs $0^\infty$.
4. "≥" is part 3 applied to $y\$$. For "≤": $y\mapsto M(y\$\mid x)$ is a lower-semicomputable semimeasure over the prefix-free set $\{y\$\}$; apply (F2). ∎

* SFI treats an output as a complete object. It must commit to where the answer ends, and pays for the length.
* SI on an undelimited $y$ does not pay for the length. With delimiters, single-query $M_F$ and SI agree up to constants. Across examples they differ in how information is shared (H4).
* Part 2 is a datum for H1 (foundations track). The program mixture with input-independent self-delimitation pays for not seeing the input while reading its program, up to $K(K(y\mid x))$ bits, and not only $O(1)$. A program mixture over conditional prefix programs (the machine may read $x$ first) would remove this single-query gap. But it is no longer a mixture over *functions* with input-independent weights, so it is not a Bayesian prior on random functions in the sense of Prop 5.1.

### 5.4 Remarks

**Remark 5.5 (positive-example induction) [proof sketch].**
* Hänni's "positive example induction" learns a set or distribution from samples. In SFI terms, giving only positive labels $(x,1)$ is useless: the constant-1 program explains them.
* The right formalisation is a sampling likelihood: samples are outputs of a hypothesis with private randomness per sample. That is, SFI on index inputs $i\mapsto x_i$, restricted to index-ignoring product hypotheses. This gives the i.i.d. mixture $\sum_\mu w_\mu\prod_i\mu(x_i)$ over computable $\mu$.
* This is the private-randomness analogue of the universal semimeasure on the sample sequence, which is the shared-randomness version. It is the object of Chater & Vitányi's ideal learning from positive evidence [known (snippet): *J. Math. Psych.* 51(3):135–163, 2007; their exact model unverified].

**Remark 5.6 (interventions).**
* If inputs are interventions set by the experimenter independently of the system's randomness, $x$-only dominance (H2) applies to the interventional law $P(y\mid\mathrm{do}(x))$.
* With observational inputs, SFI targets $P(y\mid x)$ like any conditional learner.
* I found nothing specific to SFI to prove here.

---

## 6. Literature on SFI-like objects

Status as above. "(snippet)" means the bibliographic data, and only the claim quoted, were confirmed by a search snippet.

1. **Solomonoff's three kinds of induction.**
   * R. J. Solomonoff, "Three kinds of probabilistic induction: universal distributions and convergence theorems", *The Computer Journal* 51(5):566–570, 2008, doi 10.1093/comjnl/bxm120 (snippet). The abstract describes:
     * (1) sequence extrapolation;
     * (2) extrapolating an unordered set;
     * (3) **unordered sets of ordered pairs, where given the first element of a new pair one estimates a distribution over the second**, each with a convergence theorem.
   * Kind (3) is supervised learning with a universal distribution. Secondary sources call it **operator induction** (E. Özkural, arXiv 1504.03303 and 1709.03879 (snippet)). They describe it as inferring a conditional probability density, with a convergence theorem bounding the total error by $\ln2$ times the complexity of the source. They attribute the proof to Solomonoff using Hutter's extension to arbitrary alphabets.
   * Earlier: Solomonoff, "Two kinds of probabilistic induction", *Comput. J.* 42(4):256–259, 1999 (snippet; content unverified); "Progress in incremental machine learning", IDSIA-16-03, 2003 (snippet; content unverified).
   * **Unverified recollection.** Operator induction weights probabilistic "operators" $O^j(A\mid Q)$ by a priori probabilities and predicts with $\sum_ja_j\prod_iO^j(A_i\mid Q_i)$. That is the product, private-randomness mixture (H1(c)), and its convergence theorem is essentially H2/H7 in expectation.
   * If this recollection is right, the product version of SFI and its $x$-only dominance are **Solomonoff's operator induction**. The paper should say so, after checking the 2008 paper.
   * The 1964 papers (*Information and Control* 7(1):1–22 and 7(2):224–254, snippet) are confirmed bibliographically. Whether they discuss question–answer pairs is **unverified**.
   * Solomonoff (1978), *IEEE Trans. Inf. Theory* 24(4):422–432 (unverified) gives the sequence convergence theorem.
2. **Hutter's chronological semimeasures.**
   * M. Hutter, *Universal Artificial Intelligence*, Springer 2005, and the AIXI papers arXiv cs/0004001 and cs/0012011 (snippet).
   * Chronological semimeasures $\nu(e_{1:t}\|a_{1:t})$: outputs up to time $t$ do not depend on later actions. The universal $\xi^{AI}$ is a $2^{-\ell(q)}$-weighted sum over chronological programs and dominates all enumerable chronological semimeasures (snippet).
   * With actions as inputs and percepts as labels, this is the history-aware SFI$^{\rm hist}$ of H4.
   * The book lists supervised learning from examples among AIXI's problem classes (snippet of Hutter's 2013 slides). The section's content is unverified.
3. **Lattimore, Hutter & Gavane**, "Universal prediction of selected bits", ALT 2011, LNAI 6925, arXiv 1107.5531 (snippet). Normalised Solomonoff induction learns recursive sub-patterns in otherwise unstructured sequences; the unnormalised form can fail. Relevant to SI on interleaved $x_1y_1x_2y_2\ldots$ where only the $y$'s matter (H4/H5).
4. **Lattimore & Hutter**, "No free lunch versus Occam's razor in supervised learning" (above): a Solomonoff-inspired off-line classifier (snippet). Their exact prior over functions is unverified.
5. **MDL for regression and classification.**
   * J. Poland & M. Hutter, "Strong asymptotic assertions for discrete MDL in regression and classification", Benelearn 2005, pp. 67–72, arXiv math/0502315 (snippet). Countable model classes; finite Hellinger-loss bounds when the truth is in the class; the bound is exponentially larger than Solomonoff's.
   * "Asymptotics of discrete MDL for online prediction", *IEEE Trans. Inf. Theory* 51(11):3780–3795, 2005 (snippet).
   * P. Grünwald, *The Minimum Description Length Principle*, MIT Press 2007 (known); supervised/conditional MDL chapters (unverified section numbers).
   * Grünwald & Langford, "Suboptimal behavior of Bayes and MDL in classification under misspecification", *Machine Learning* 66:119–149, 2007 (snippet).
6. **Ryabko**, "Pattern recognition for conditionally independent data", *JMLR* 7:645–664, 2006 (snippet). Deterministic labels; objects conditionally i.i.d. given labels; classical error estimates survive. Relevant to non-i.i.d. input orders.
7. **Vovk**, "Universal forecasting algorithms", *Information and Computation* 96(2):245–277, 1992 (snippet; content unverified). Vovk, Gammerman & Shafer, *Algorithmic Learning in a Random World*, Springer 2005 (known (unverified)): conformal prediction, an exchangeability-based supervised framework related to Prop 2.9.
8. **PAC-Bayes and Occam.**
   * Blumer et al. 1987 (snippet).
   * McAllester, "Some PAC-Bayesian theorems", COLT 1998, pp. 230–234; *Machine Learning* 37(3):355–363, 1999. "PAC-Bayesian model averaging", COLT 1999, pp. 164–170 (snippet).
   * Haussler, Kearns & Schapire, *Machine Learning* 14:83–113, 1994 (snippet): Bayes-optimal mistake probability versus information gain. This is the in-expectation, well-specified analogue of the log-loss/mistakes relations used in Theorem 3.5.
   * Barron & Cover, *IEEE Trans. Inf. Theory* 37(4), 1991 (known).
9. **Li & Vitányi**, *An Introduction to Kolmogorov Complexity and Its Applications* (3rd ed. 2008; 4th ed. 2019) (known): the coding theorem, the conditional universal distribution, and the discrete/continuous distinction (Prop 5.4).
10. **Inductive inference of recursive functions.**
    * Gold, *Information and Control* 10(5):447–474, 1967 (known).
    * Bārzdiņš & Freivalds, *Dokl. Akad. Nauk SSSR* 206(3):521–524, 1972 (snippet; content unverified).
    * Case & Smith, *TCS* 25:193–220, 1983 (snippet).
    * These are the deterministic-identification ancestors: learning $f$ from $(x,f(x))$, mostly in the order $0,1,2,\ldots$.
11. **Average-case complexity.** Impagliazzo & Levin, FOCS 1990 (snippet): universal extrapolation of samplable distributions (Question 3.4).

**What exists, and what is new here (to the extent a snippet-level search can tell).**
* *Exists.*
  * The program/product mixture for supervised pairs and its convergence theorem (Solomonoff's third kind, very likely; verify).
  * The chronological, history-aware universal semimeasure (Hutter).
  * Solomonoff-style classifiers and NFL discussion (Lattimore–Hutter).
  * MDL classification consistency (Poland–Hutter).
  * Occam/PAC-Bayes bounds.
  * The dimension lower bound for kernels.
  * The halving/weighted-majority mistake bound.
* *Apparently new* (no prior use found of the name "Solomonoff function induction", and none of the following found in the snippets):
  * the shared-randomness function semimeasure $M_F$ and its comparison with the program and product mixtures (H1);
  * the explicit separation between $x$-only and history-aware dominance, with counterexamples (H3);
  * the order-independence characterisation (Prop 5.1);
  * the OOD results of §2 (two-sided separation bounds, novelty budget, random-split theorem, failure of the converse, sandwich, easy-to-hard);
  * time-bounded SFI with length-based activation (Thm 3.1);
  * circuit Bayes mistakes ↔ size on every ordering (Thm 3.5);
  * the uniform-circuit padding bound (Prop 4.5);
  * the zero-eigenvalue observation for two-layer ReLU kernels as a learnability statement (Rem 4.8). The fact that the expansion has only even powers beyond the linear term is presumably known.
* Each "apparently new" item should be re-checked against Solomonoff (2008), Hutter (2005, the EX section) and Lattimore–Hutter (2013) before publication.

---

## 7. Open problems from this track

1. Leave-one-out error of SFI: is $\frac1N\sum_xe_{\rm LOO}(x)=O(K_B(f)/N)$, up to logs (Conj 2.11)?
2. Efficient time-bounded SFI against samplers (Question 3.4).
3. A circuit coding theorem for size priors with polynomial tails (Remark 3.6). Equivalently: do random large circuits rarely compute functions without small circuits?
4. Few MAP mistakes ⇒ small circuit (Remark 3.6).
5. Occam OOD: super-polynomial mistakes for a natural circuit language, or a polynomial bound (Remark 3.10).
6. The upper half of the uniform-circuit bridge, and the MLP-to-circuit bridge (Prop 4.5 and below; Hänni's open problems 1 and 2).
7. GP *classification* with NNGP/NTK priors on parities (Remark 4.8).

---

## Verification log

**Scripts** (all in `checks/`, run with `python3 <script>` from that folder; numpy 2.4.6; outputs saved as `<script>_output.txt`):

| script | seed | what it checks | result |
|---|---|---|---|
| `c1_formula_bayes_d3.py` | 0 (orderings only) | Thm 3.5 inequalities for the formula prior, $d=3$, all 256 functions and all orderings (DP over subsets); order independence; worst-case Occam/MAP mistakes | all inequalities True; order-independence error $1.8\cdot10^{-14}$; max $L/m_{\min}=4.92$ vs bound 51.5; truncation error $\le1.7\cdot10^{-19}$ relative; 4 s |
| `c2_kernel_parity.py` | 1 | Thm 4.6(a) for four kernels (residual $\le7.9\cdot10^{-15}$; eigenvalue spread within a degree $\le5.6\cdot10^{-16}$); odd-degree zero eigenvalues of two-layer ReLU NNGP/NTK; Thm 4.6(b) (asserted per cell); Cor 4.7 (parity Bayes error and Gibbs mistakes vs bound) | all as reported in §4.4; 23 s |
| `c3_order_and_learning_curves.py` | 2 | Prop 5.1 (720 orders; semimeasure loss constant to 12 digits, normalised varies 7.33–10.64); Prop 2.9 Monte Carlo; Remark 2.11 toy curves | as reported; 3 s |
| `c4_ood_prefix_separation.py` | 3 | Prop 2.12: distribution of the separating-prefix complexity, $\Pr[\sigma\le\lceil\log_2m\rceil+1]$ against the exact value, $\log^2m$ scaling | matches; 1 s |
| `c5_time_bounded_mixture.py` | 4 | Thm 3.1(b) bookkeeping equals brute force; regret below the proved constant and flat after short inputs stop | max difference $2.5\cdot10^{-16}$; regret 132.4 ≤ 184 bits; 1 s |

**Proofs.** Each proof in §§2–5 was written out and re-read once for quantifier order and constants. Points checked specifically:
* Prop 2.1: concatenation of self-delimiting codes; injectivity; the $D$-consistency of the wrapper uses $\operatorname{dom}D\cap Q=\emptyset$.
* Prop 2.6(b): $\mu_n$ is a semimeasure because the events are disjoint.
* Prop 2.8: each $Q$ can be a minimiser at most once.
* Prop 2.13(2): the conditioning string must be independent of $(A,x^*)$.
* Thm 3.1(a): it is distinctness that bounds the number of short inputs.
* Thm 3.5(b): the size split at $\lceil L\rceil$; the chord bound $-\log_2(1-p)\le2p$ on $[0,\frac12]$; $\#\{P_i>\frac12\}\le2m$.
* Prop 3.9: the post-$N$ mistakes are injected into surviving wrong members of $H_f$.
* Prop 4.5: the counting of padded circuits.
* Thm 4.6(b): the trace identity.
* Rem 4.8: the parity of the power-series terms.

No external referee has checked these notes.

**Literature.** Every reference is marked verified (snippet), known (unverified), or unverified.
* The most important unverified item is the exact form of Solomonoff's operator induction (§6, item 1). It decides how much of the product-mixture theory is already Solomonoff's.
* The Vaintrob–Hänni slides are a placeholder. The arXiv 2607.05735 summary is from a search snippet only.

**Not done.**
* Hänni's "proof/disproof labels" example is treated only in the easy-to-hard form (Example 2.15).
* No experiments on real networks.
* Hutter's book section on supervised learning (EX) was not read.
