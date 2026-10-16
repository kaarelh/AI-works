# Thread `logic`: random theories, $\Pi_1$ truth and Gödel phenomena

*Thread record, 2026-10-16. The family studied here has the working name "Solomonoff axiom induction" (SAI); the final name is undecided and nothing below depends on it. Folder: `research/tracks/logic/`; scripts in `checks/`, each seeded where it uses randomness, with its output saved next to it. Notation: `../../NOTATION-draft.md` (binding); local symbols and requests are in §8.*

**Statuses.** Every claim carries one of:
* **[proved]**: a full proof is given here;
* **[proved, given X]**: proved here from a cited result X whose verification level is in §9;
* **[known: ref]** (reference verified to the level stated in §9);
* **[proof sketch]**, with the missing steps named;
* **[computed: script, item]**;
* **[conjecture]**, **[open]**;
* **[refuted]**: kept with its counterexample.

**Pointers.** "AI-paper" is `../axiom-induction/paper/main.pdf`, cited by printed numbers. `fundamentals` is the thread record `../fundamentals/notes.md` (development round), cited by its item numbers (e.g. `fundamentals` Thm 4.1); scout records are cited as scout F, S, L, N1 with their item numbers; P1 is SOI Paper 1. Logarithms are base 2; $c,c',c''$ are constants depending only on the fixed universal machines, the coding of syntax and the background $B$.

**Web access.** WebSearch worked in this round; fetching pages (arXiv, HAL, ar5iv, publishers) was blocked by the proxy. References were therefore verified to the level of bibliographic data plus abstract or search-snippet content (§9). No result below depends on the content of an unread paper: every theorem is proved here from textbook facts (Gödel's second incompleteness theorem for r.e. extensions of $\PA$, $\Sigma_1$-completeness of $\Q$, the diagonal lemma), or carries a "given X" status.

---

## 0. Summary

### 0.1 What this record establishes

The thread studies what happens to the inducer *because its data are sentences of a logic*. Four phenomena, each with no analogue in SOI on strings:

1. **The lottery (§2).** There is a stream on which the one-tape inducer $M_A$ has bounded loss while no consistent r.e. theory proves the stream; the coin-free and Kolmogorov versions then have unbounded loss, and the limit posterior lives on non-r.e. random theories (Thm 2.2, re-verified from scout N1). New here: **the lottery exists inside true arithmetic with true data** of the lowest complexity beyond $\Sigma_1\cup\Pi_1$ (Boolean combinations of $\Sigma_1$ sentences), and on that stream the limit posterior is concentrated on *false* theories although every datum is true (Thm 2.9, Cor 2.10). The phenomenon is exactly a failure of the majority-vote argument of de Leeuw et al. for consistency constraints of unbounded arity (the lottery paradox); it cannot happen for bounded arity, for $\Pi_1$ data, for co-r.e. streams over lottery-type classes, or when a positive-measure set of true random theories succeeds (Props 2.3, 2.4, 2.7, Cor 3.5). On the lottery streams the coin-free loss diverges more slowly than any computable function (Cor 2.6′).
2. **$\Pi_1$ derandomisation (§3).** With a true background $\supseteq\Q$, every $\Pi_1$ sentence proved with prior probability $2^{-k}$ is proved by one true theory of complexity $k+O(\log k)$ (Thm 3.1, scout N1), and new here: on $\Pi_1$ data the universal mixture equals, up to a constant factor, **one** random true theory, a uniformly random threshold on the prior probability of provability (Thm 3.2). Consequences: a coding theorem for $\Pi_1$ data (Cor 3.3), Chaitin's theorem for random theories ($m\pm O(\log m)$ bits for one datum "$K(x)>m$", Cor 3.6). **The boundary is exact:** true Boolean combinations of $\Sigma_1$ sentences already break the coding theorem, with two data (Prop 3.9) and bounded-against-unbounded on a stream (Cor 2.10).
3. **Gödel phenomena (§4).** "Independent" on a $\Pi_1$ question certifies truth (Prop 4.1); soundness is never learned coin-free (Thm 4.2) and, new here, never learned one-tape from $\Pi_1$ data, with a uniform constant (Thm 4.4); in general, one-tape confidence in soundness requires a large coding gap (Prop 4.3); the direction of $\Con(T)$ given data from $T$ is a choice of universal machine (Prop 4.5); $\Q$-entailed instance checks confirm nothing, so induction in mathematics needs a bounded deducer (Prop 4.6).
4. **The ω-gap (§5).** Its anatomy (Prop 5.1); $\Bel$ satisfies the Gaifman condition exactly when the instances deductively settle the universal (Prop 5.2); a uniform Gödelian form: true $\Pi_1$ sentences with $\Q$-provable instances and belief below any $2^{-k}$ (Thm 5.3); closures (ω-rule, second order, generative).

Also: on $\Th(\mathbb N)$ in a length-lexicographic enumeration the loss grows at least like $n^\delta$ with an explicit $\delta$ ($\ge0.0525$ for a stated syntax), and every true r.e. theory leaves about $n^\delta$ of the first $n$ sentences undecided (Thm 6.1, Cor 6.2); whether the loss is $o(n)$ reduces to generic decidability of arithmetic and stays open (Prop 6.3).

### 0.2 Claims and statuses

| item | statement (short) | status |
|---|---|---|
| Lemma 2.1 | Lebesgue density on Cantor space | proved |
| Thm 2.2 | the lottery: bounded $L_A$, no consistent r.e. theory, $W_A\to0$, $K_A,K_{\rm fin}\to\infty$, posterior on non-r.e. random theories | proved; computed (c1 A1) |
| §2.3 | stream must be non-r.e.; only proof-requiring; consistent SOI separated one-tape vs coin-free | proved |
| Prop 2.3 | bounded inconsistency arity ⇒ an r.e. theory proves the stream; SOI analogue | proved; computed (c2 A, B) |
| Prop 2.4 | positive mass of true random theories ⇒ a true r.e. theory | proved; computed (c2 C) |
| Cor 2.5 | scout F's Q1: no in general; yes in the listed cases | proved |
| Prop 2.6 | $-\log W_A(D_n)\le\Kpad(h_G(n))+K(G)+\log(2/a_G)+c$ (proof horizon) | proved |
| Cor 2.6′ | on the lottery streams $-\log W_A(D_n)\le\Kpad(n)+c$; $K_A(D_n)\le n/2+O(\log n)$; batch lottery | proved; computed (c1 A2) |
| E-Q2 rest | a stream with bounded one-tape loss and computably-fast coin-free divergence? | open |
| Prop 2.7 | co-r.e. streams over block-decidable classes (incl. all lottery classes) are proved by a consistent decidable theory | proved; computed (c1 C) |
| co-r.e. Q1 | in general | open |
| Lemma 2.8 | flexible formulas with prescribed truth set | proved, given (Diag), ($\Sigma_1$C) |
| Thm 2.9(a) | lottery in arithmetic, $B$ true: false $\Sigma_1$ and true $\Pi_1$ data | proved, given Lemma 2.8 |
| Thm 2.9(b) | lottery in arithmetic with **true** data (Boolean combinations of $\Sigma_1$) | proved, given Lemma 2.8; computed (c1 A3, bookkeeping) |
| Cor 2.10 | on true data: no coding theorem; limit posterior on false theories; lottery theories $\Sigma_1$-unsound | proved |
| $P_\infty$(sound) on Thm 2.9(b) | is it $0$? | open |
| Thm 3.1 | threshold theories $T_k$ (N1's A1) | proved; computed (c3 T1) |
| Thm 3.2 | threshold machine $G^*$: $M_A\asymp\nu_{G^*}$ on $\Pi_1$ data | proved; computed (c3 T2) |
| Cor 3.3 | coding theorem for $\Pi_1$ data | proved |
| Rem 3.4 | $-\log W_A\le L_A+\Kpad(\lceil L_A\rceil+1)+c$ on $\Pi_1$ data; is $K_A\le L_A+O(1)$? | proved; computed (c3 T4); the $O(1)$ question open |
| Cor 3.5 | bounded loss on a $\Pi_1$ stream ⇒ one true theory | proved |
| Cor 3.6 | Chaitin for random theories: $m\pm O(\log m)$ | proved |
| Prop 3.7 | $\Unif_A(\Ext T)$ vs $\mm(\Ext T)$ for true $\Pi_1$ $T$, up to $K(k)$; Q2 for $[T]$ | proved; Q2 open |
| §3.4 | novelty against Bienvenu et al. 2014, Shen 2011, Chaitin 1974, Levin 2013 | known (abstract level) / new as stated |
| Prop 3.8 | one false $\Sigma_1$ datum: $\log d$ gap (N1's A5) | proved, given Lemma 2.8 (upgraded from sketch) |
| Prop 3.9 | two **true** data: $\log d$ gap (A-Q1 answered) | proved, given Lemma 2.8 |
| Prop 4.1 | arithmetical shape of the trichotomy | proved; computed (c4) |
| Thm 4.2 | coin-free: soundness posterior $\le1/(1+2^{-c})$ | proved, given (G2) |
| Prop 4.3 | one-tape: $P(\text{unsound}\mid D)\ge2^{L_A-K_A-c}$ | proved, given (G2) |
| Thm 4.4 | one-tape on $\Pi_1$ data: $P(\text{sound}\mid D)\le1-2^{-c}$ uniformly | proved, given (G2); computed (c3 T3) |
| D-Q1 | one-tape soundness for all data | open (partial cases proved, §4.4) |
| Prop 4.5 | $\Con(T)$: three positive limits; direction machine-dependent | proved, given (G2) |
| Prop 4.6 | old evidence; induction in mathematics needs a bounded deducer | proved |
| Prop 5.1 | anatomy of the ω-gap | proved |
| Prop 5.2 | Gaifman condition holds iff instances settle the universal | proved |
| Thm 5.3 | uniform Gödelian ω-gap (normalisation corrected) | proved, given (G2) |
| §5.4 | ω-rule, second-order ($\PA^2$), generative closures | proved / proved given Dedekind / known (AI-paper) |
| Prop 5.4 | line budgets ⇔ a Kreisel property; counterexample with $B=\emptyset$ | proved; finite-theory property over $\Q$ open |
| Thm 6.1 | $L_A(D_n)\ge C'^{-\delta}n^\delta-K(n)-c$ on $\Th(\mathbb N)$, $\delta\ge0.0525$ | proved, given $\Omega_V$ random (known); computed (c5) |
| Cor 6.2 | every true r.e. theory leaves $\gtrsim n^\delta/\log n$ of the first $n$ sentences undecided | proved |
| Prop 6.3 | $L_A=o(n)$ if some true r.e. theory decides a density-one set | proved |
| §6.2 | $(1-\rho)n$ upper bound from trivially decided sentences | proof sketch |
| Q3 | is $L_A(D_n)=o(n)$ on $\Th(\mathbb N)$? | open |
| refuted / withdrawn | see §10, items 7, 10, 11 | — |

---

## 1. Setting

### 1.1 Objects

I use the definitions of `fundamentals` §1 without change: language $\mathcal L$ with computable syntax, decidable consistent background $B$, data sets $D$ (finite partial functions $\Sent\rightharpoonup\{0,1\}$), $D^\pm$, $\psi_D$, theory machines $G$, the universal theory machine $G_U$, $A_\omega$, $O_\chi=\{\omega:B\cup A_\omega\vdash\chi\}$, $\Inc_0=\Unif(O_\bot)$, $E_D=O_{\psi_D}\setminus O_\bot$, $M_A(D)=\Unif(E_D)$, $L_A=-\log M_A$, $\Bel_D,\Dis_D,\Indep_D$, $\Bel_0(\chi)=\Unif(O_\chi)-\Inc_0$, $W_A$, $K_A$, $K_{\rm fin}$, $\Unif_A[T]$, $\Unif_A(\Ext T)$, $\mm(\Ext T)$. For an infinite stream, $E_\infty:=\bigcap_nE_{D_n}$ and $P_\infty:=\Unif(\cdot\mid E_\infty)$ when $\Unif(E_\infty)>0$.

Facts from `fundamentals` used throughout (all proved there):
* **(Dom)** $M_A\ge2^{-K(\nu)}\nu$ for every theory-machine law $\nu$; in particular $M_A(D)\ge2^{-K(e)-c}$ whenever $B\cup\mathsf W_e$ is consistent and proves $\psi_D$ (Thm 4.1).
* **(Chain)** $2^{-K_A(D)}\le W_A(D)\le2^cM_A(D)$ (Prop 6.1(c)).
* **(Lim)** If $\Unif(E_\infty)>0$, the posterior converges to $P_\infty$ in total variation and the cumulative loss is bounded; if $\Unif(E_\infty)=0$, the cumulative loss tends to $\infty$ (Prop 8.1).
* **(Old)** $M_A(D)$ depends on $D$ only through $\Cn(D^\pm)$; data entailed by $B$ change nothing (Prop 2.1(c)).

### 1.2 Arithmetic

* $\mathcal L_{\rm ar}=\{0,S,+,\cdot,<\}$, numerals $\underline n=S^n0$. $\Delta_0,\Sigma_1,\Pi_1$ as usual; $\Pi_1^*$ = finite conjunctions of $\Pi_1$ sentences and negations of $\Sigma_1$ sentences.
* "$B$ **true**" means: $B$ has a model whose $\mathcal L_{\rm ar}$-reduct is $\mathbb N$ (for $\mathcal L=\mathcal L_{\rm ar}$: $B\subseteq\Th(\mathbb N)$). "$B\supseteq\Q$" means $\Q\subseteq\Cn(B)$, likewise for $\PA$.
* A theory is **$\Sigma_1$-sound** if it proves no false $\Sigma_1$ sentence.

Standard facts used [known: textbook; Smoryński 1977, §9]:
* **($\Sigma_1$C)** $\Q$ proves every true $\Sigma_1$ sentence (in particular every true $\Delta_0$ sentence).
* **($\Pi_1$T)** Consequently, if $B\supseteq\Q$ and $B\cup A$ is consistent, every $\Pi_1^*$ sentence that $B\cup A$ proves is true: if a conjunct were false, its negation would be a true $\Sigma_1$ sentence, provable in $\Q$.
* **(G2)** For every consistent r.e. presentation $Z$ with $\PA\subseteq\Cn(Z)$, $Z\nvdash\Con(Z)$, where $\Con(Z)$ is the canonical consistency statement of the presentation (a $\Pi_1$ sentence).
* **(Diag)** For every formula $\Theta(z,x)$ there is a formula $\Phi(x)$ with $\Q\vdash\forall x\,(\Phi(x)\leftrightarrow\Theta(\ulcorner\Phi\urcorner,x))$.

### 1.3 Local notation

* The binary relation symbol of the lottery is written $\mathrm{Win}$ (scout N1 wrote $W$, which clashes with $W_A$; `sfi` §8 made the same request).
* $\mathrm{Lot}_k$ (lottery sentences; NOTATION §6.2), $N_k:=2^{k+1}-1$ (the tickets of lottery $k$ are $0,\dots,N_k$), $j^*_k$ (the diagonal ticket), $G_{\rm lot}$ (the random lottery theory).
* $T_k$ (threshold theory), $I'_k$ ($(k+2)$-bit truncation of $\Inc_0$), $\mathrm{Kgt}_m(x)$ ("$K(x)>m$") as in NOTATION §6.2.
* New local symbols: $G^*$ (threshold machine, §3.2), $G^{**}$ (its unsound companion, §4.3), $\Phi$ (flexible formulas, §2.7), $\theta_{k,j}$ (arithmetic tickets), $\Kpad(n):=\min_{n'\ge n}K(n')$ (as in SOI-N), $h_G(n)$ (proof horizon, §2.5).

---

## 2. The lottery (target T1)

### 2.1 A density lemma

**Lemma 2.1 (Lebesgue density on Cantor space) [proved].** Let $X\subseteq\{0,1\}^\infty$ be Borel with $\Unif(X)>0$ and $\varepsilon\in(0,1)$. Then there is a finite string $w$ with $\Unif(X\cap[w])>(1-\varepsilon)2^{-|w|}$.

*Proof.* By outer regularity there is an open $O\supseteq X$ with $\Unif(O)<\Unif(X)/(1-\varepsilon)$. Write $O=\bigsqcup_i[w_i]$ with $\{w_i\}$ prefix-free. If $\Unif(X\cap[w_i])\le(1-\varepsilon)2^{-|w_i|}$ for every $i$, summing gives $\Unif(X)\le(1-\varepsilon)\Unif(O)<\Unif(X)$. ∎

Write $\Pr_w(\cdot):=2^{|w|}\Unif(\cdot\cap[w])$.

### 2.2 The lottery theorem

**Setting.** $\mathcal L$ contains $0$, $S$ and a binary relation symbol $\mathrm{Win}$; $B$ is decidable, consistent, does not mention $\mathrm{Win}$, and has a model in which the numerals denote pairwise distinct elements (e.g. $B=\emptyset$, $\Q$ or $\PA$ with $\mathcal L=\mathcal L_{\rm ar}\cup\{\mathrm{Win}\}$). For $k\ge0$:
$$\mathrm{Lot}_k:=\exists x\,\mathrm{Win}(\underline k,x)\ \wedge\ \forall x\,\big(\mathrm{Win}(\underline k,x)\to x=\underline0\vee\cdots\vee x=\underline{N_k}\big),$$
"lottery $k$ has a winner, and every winner is one of its tickets".

**The random lottery theory $G_{\rm lot}$.** It reads the tape in consecutive blocks of $k+1$ bits, $k=0,1,2,\dots$; block $k$ is read as a number $J_k\in\{0,\dots,N_k\}$. After reading block $k$ it emits $\mathrm{Lot}_k$, $\mathrm{Win}(\underline k,\underline{J_k})$ and $\neg\mathrm{Win}(\underline k,\underline j)$ for every $j\le N_k$, $j\ne J_k$. Under $\Unif$ the $J_k$ are independent and uniform.

*Every $A^{G_{\rm lot}}_\omega$ is consistent with $B$*: take a model $\mathfrak M$ of $B$ with distinct numerals and put $\mathrm{Win}^{\mathfrak M}:=\{(\underline k^{\mathfrak M},\underline{J_k}^{\mathfrak M}):k\in\mathbb N\}$. Because the numerals are distinct, for each $k$ the only $\mathrm{Win}$-partner of $\underline k^{\mathfrak M}$ is $\underline{J_k}^{\mathfrak M}$, so every emitted sentence holds; $B$ does not mention $\mathrm{Win}$.

**Theorem 2.2 (the lottery) [proved; computed: c1 A1, A2].** There is an infinite stream $D_\infty$ of labelled sentences, computable from $\emptyset'$, such that:
* (a) **Bounded one-tape loss.** For every $n$, $M_A(D_n)\ge2^{-K(G_{\rm lot})-c}\prod_{k\ge0}(1-2^{-(k+1)})$, and the product equals $0.288788\ldots$ So $\Unif(E_\infty)>0$, the cumulative loss $L_A(D_n)-L_A(\emptyset)$ is bounded by $K(G_{\rm lot})+\log(1/0.2887)+c$, and the posterior converges in total variation to $P_\infty$.
* (b) **No theory.** No consistent r.e. theory proves every member of $D_\infty^\pm$ (together with $B$).
* (c) **The other versions diverge.** $W_A(D_n)\to0$ and $K_A(D_n)\to\infty$, while $L_A(D_n)$ stays bounded. Also $K_{\rm fin}^{\mathcal L'}(D_n)\to\infty$ for every language $\mathcal L'\supseteq\mathcal L$.
* (d) **The posterior abandons theories.** The posterior probability that the tape's program is a deterministic machine (one emitting only under the empty prefix) tends to $0$; and $E_\infty\cap\{\omega:\Cn(B\cup A_\omega)\text{ is r.e.}\}=\emptyset$, so the limit posterior lives entirely on random theories whose deductive closure is not r.e.

*Proof.* **The stream.** Let $\mathsf W_0,\mathsf W_1,\dots$ enumerate the r.e. sets of $\mathcal L$-sentences. For each $e$ define $j^*_e\in\{0,\dots,N_e\}$:
* if $B\cup\mathsf W_e$ is consistent and proves $\mathrm{Lot}_e$, let $j^*_e$ be the least $j\le N_e$ with $B\cup\mathsf W_e\nvdash\neg\mathrm{Win}(\underline e,\underline j)$;
* otherwise $j^*_e:=0$.

In the first case such a $j$ exists: if $B\cup\mathsf W_e$ proved $\neg\mathrm{Win}(\underline e,\underline j)$ for all $j\le N_e$, then with the second conjunct of $\mathrm{Lot}_e$ and the equality axioms it would prove $\forall x\,\neg\mathrm{Win}(\underline e,x)$, contradicting the first conjunct and its consistency. Put
$$D_\infty:=(\mathrm{Lot}_0,1),\ (\mathrm{Win}(\underline0,\underline{j^*_0}),0),\ (\mathrm{Lot}_1,1),\ (\mathrm{Win}(\underline1,\underline{j^*_1}),0),\ \dots$$
"$B\cup\mathsf W_e$ is consistent" is $\Pi_1$, "$B\cup\mathsf W_e\vdash\mathrm{Lot}_e$" and "$B\cup\mathsf W_e\vdash\neg\mathrm{Win}(\underline e,\underline j)$" are $\Sigma_1$, uniformly; so $e\mapsto j^*_e$ and the stream are computable from $\emptyset'$.

**(a)** Let $E:=\{\omega:J_k(\omega)\ne j^*_k\ \forall k\}$. By independence and continuity from above, $\Unif(E)=\prod_k(1-2^{-(k+1)})$, which is positive because $\sum_k2^{-(k+1)}<\infty$. For $\omega\in E$ the theory $B\cup A^{G_{\rm lot}}_\omega$ is consistent, emits every $\mathrm{Lot}_k$, and emits $\neg\mathrm{Win}(\underline k,\underline{j^*_k})$ because $j^*_k\le N_k$ and $j^*_k\ne J_k$. So $\nu_{G_{\rm lot}}(D_n)\ge\Unif(E)$ for all $n$, and (Dom) gives the bound. The rest is (Lim); $M_A(\emptyset)\le1$ gives the bound on the cumulative loss.

**(b)** If $B\cup\mathsf W_e$ is consistent and proves $D_\infty^\pm$, it proves $\mathrm{Lot}_e$, so $j^*_e$ was chosen with $B\cup\mathsf W_e\nvdash\neg\mathrm{Win}(\underline e,\underline{j^*_e})$; but that sentence is in $D_\infty^\pm$.

**(c)** $W_A(D_n)=\sum_e\mm(e)\ind[B\cup\mathsf W_e\text{ consistent},\ \vdash\psi_{D_n}]$. Each indicator is non-increasing in $n$ and, by (b), eventually $0$; dominated convergence ($\sum_e\mm(e)\le1$) gives $W_A(D_n)\to0$, and $K_A\ge-\log W_A$ (Chain). For a single sentence $\psi$ in $\mathcal L'\supseteq\mathcal L$ with $B\cup\{\psi\}$ consistent, the set $X_\psi:=\{\varphi\in\Sent_{\mathcal L}:B\cup\{\psi\}\vdash\varphi\}$ is r.e. and $B\cup X_\psi$ is consistent, so by (b) $X_\psi\not\supseteq D_\infty^\pm$: every consistent $\psi$ fails some datum. Only finitely many $\psi$ have $K(\psi)\le j$, so $K^{\mathcal L'}_{\rm fin}(D_n)\to\infty$.

**(d)** Let $P_{\rm det}$ be the set of $p\in\dom V$ such that $G_{V(p)}\subseteq\{\epsilon\}\times\Sent$, and $X_p$ the set it emits. Then $\Unif(\{\omega\in E_{D_n}:\omega\text{ begins with some }p\in P_{\rm det}\})=\sum_{p\in P_{\rm det}}2^{-|p|}\ind[B\cup X_p\text{ consistent},\ \vdash\psi_{D_n}]\to0$ by (b) and dominated convergence; divide by $M_A(D_n)$, which is bounded below by (a). If $\omega\in E_\infty$ and $\Cn(B\cup A_\omega)$ were r.e., it would be a consistent r.e. theory proving $D_\infty^\pm$, contrary to (b). ∎

### 2.3 Remarks on Theorem 2.2

* **The stream must be non-r.e. [proved].** If $\Unif(E_\infty)>0$ and $D_\infty^\pm$ is r.e., then $D_\infty^\pm$ is itself a consistent r.e. theory proving the stream. So every stream answering scout F's Q1 negatively has a non-r.e. set of literals; $D_\infty$ above is $\Delta_2$. Whether a co-r.e. set can serve is settled for lottery-type sentence classes in §2.6 (no) and open in general.
* **Only for proof-requiring compatibility [proved].** The r.e. theory $\{\mathrm{Lot}_k:k\in\mathbb N\}$ is consistent with every finite part of $D_\infty$, so under the consistency-requiring variant it remains compatible forever. The phenomenon needs compatibility to demand that each reported loser be *derived*.
* **Where the randomness sits.** Every random lottery theory has the same law ($\mathrm{Lot}_k$ for all $k$) and differs only in randomly drawn contingent facts (the winners). A deterministic theory that derives losers must commit to winners once, and the diagonal reports exactly a ticket it fails to refute; a random theory commits at random and dies only if it happens to have picked the reported ticket. This is a forced version of the split between laws and randomly drawn initial conditions (P2's model–randomness split): here no deterministic hypothesis at all succeeds.
* **Consequence for consistent SOI (one sentence).** Since $M_F^{\rm cons}\asymp M_A$ and $W^{\rm cons}\asymp W_A$ (`sfi` Thm 3.1 and Thm 2.1; scout F's F8), the stream of Theorem 2.2 separates one-tape consistent SOI (bounded loss) from coin-free consistent SOI (unbounded loss), while plain SOI is not separated (Prop 2.3(b); `sfi` Cor 4.2).
* **For `terms`.** On this stream every random *finite* theory, in any extended language, fails (its content is r.e.), so random r.e. theories strictly beat random finite theories (scout N1's B4, `terms` Rem 6.6).
* **Computed illustration [computed: c1 A1, A2].** Exhaustive enumeration over winner vectors confirms the survival probabilities $\prod_{k<K}(1-2^{-(k+1)})$ for $K\le5$ (single lottery per index) and the batch version's bound (§2.5) for $K\le3$; every deterministic theory in random finite lists fails at its own lottery.

### 2.4 Where the lottery cannot happen: bounded inconsistency arity

**Proposition 2.3 (majority vote) [proved; computed: c2 A].**
(a) *Axiom induction.* Let $S\subseteq\Sent_{\mathcal L}$ be decidable and $r\ge1$, and suppose every $B$-inconsistent finite subset of $S$ contains a $B$-inconsistent subset with at most $r$ elements. Let $D_\infty$ be a stream with $D_\infty^\pm\subseteq S$ and $\Unif(E_\infty)>0$. Then there is a consistent r.e. $T\subseteq S$ with $D_\infty^\pm\subseteq T$; hence $\inf_nW_A(D_n)\ge\mm(\text{index of }T)>0$, and the coin-free loss is bounded too.
(b) *SOI.* For P1's one-tape $M_F$ with inputs $X$ and labels $Y$: if $D_\infty:X\rightharpoonup Y$ is infinite with $\lim_nM_F(D_n)>0$, some partial computable $f$ extends $D_\infty$, so P1's coin-free $W$ also has bounded loss on $D_\infty$.

*Proof.* (a) Put $\varepsilon:=1/(r+1)$ and choose $w$ by Lemma 2.1 with $\Pr_w(E_\infty)>1-\varepsilon$. Let $T:=\{\varphi\in S:\Pr_w(O_\varphi)>1-\varepsilon\}$, r.e. because $\Pr_w(O_\varphi)$ is left-c.e. uniformly in $\varphi$ (`fundamentals` Lemma 1.3). For $\varphi\in D_\infty^\pm$, $O_\varphi\supseteq E_\infty$, so $\varphi\in T$. Suppose $B\cup T$ is inconsistent. By compactness and the hypothesis, some $\varphi_1,\dots,\varphi_j\in T$ with $j\le r$ are jointly $B$-inconsistent. Then $\Pr_w(\bigcap_iO_{\varphi_i})>1-j\varepsilon\ge1-r\varepsilon=\varepsilon$, and every tape in that intersection has an inconsistent theory, so $\Pr_w(O_\bot)>\varepsilon$. But $O_\bot\cap E_\infty=\emptyset$ gives $\Pr_w(O_\bot)<\varepsilon$. Contradiction.
(b) Choose $w$ with $\Pr_w\{\omega:f_\omega\supseteq D_\infty\}>\frac12$ and let $f(x):=y$ iff $\Pr_w\{f_\omega(x)=y\}>\frac12$. The events $\{f_\omega(x)=y\}$ are effectively open and disjoint in $y$, so $f$ is partial computable; for $x\in\dom D_\infty$ the event $\{f_\omega(x)=D_\infty(x)\}$ contains $\{f_\omega\supseteq D_\infty\}$. ∎

**Instances.** Literal data of a fresh predicate ($r=2$; scout F's condition (Lit)). Plain SOI. $\Pi_1$ data over a true background, by a different argument (Cor 3.5). The lottery class has minimal inconsistent sets $\{\mathrm{Lot}_k\}\cup\{\neg\mathrm{Win}(\underline k,\underline j):j\le N_k\}$ of size $N_k+2$, so no $r$ works; for every threshold $1-\varepsilon$ the majority set refutes every ticket of each lottery with $2^{k+1}>1/\varepsilon$ and is inconsistent [computed: c2 B].

**A truth version.** Truth is a constraint of arity one, so the majority argument transfers to it:

**Proposition 2.4 (majority over true theories) [proved].** Let $\mathcal L=\mathcal L_{\rm ar}$ and $B\subseteq\Th(\mathbb N)$ decidable. If $X:=\{\omega:B\cup A_\omega\subseteq\Th(\mathbb N),\ B\cup A_\omega\vdash D_\infty^\pm\}$ has $\Unif(X)>0$, then some r.e. $T\subseteq\Th(\mathbb N)$ has $B\cup T\vdash D_\infty^\pm$.

*Proof.* $X$ is Borel ($\{\omega:A_\omega\subseteq\Th(\mathbb N)\}=\bigcap_{\chi\text{ false}}\{\omega:\chi\notin A_\omega\}$ is closed). Choose $w$ with $\Pr_w(X)>\frac12$ and let $T:=\{\varphi:\Pr_w(O_\varphi)>\frac12\}$, r.e. It contains $D_\infty^\pm$. For $\varphi\in T$, $\Pr_w(O_\varphi\cap X)>0$, so a true theory proves $\varphi$ and $\varphi$ is true. ∎

**Corollary 2.5 (scout F's Q1) [proved].** $\Unif(E_\infty)>0$ does not in general imply that a consistent r.e. theory proves $D_\infty$ (Thm 2.2, and Thm 2.9 below inside true arithmetic). It does when the data's inconsistency arity is bounded (Prop 2.3), for $\Pi_1^*$ and true $\Sigma_1$ data over a true background (Cor 3.5), and for co-r.e. streams over lottery-type sentence classes (Prop 2.7). If a positive-measure set of *true* random theories proves $D_\infty$, a true r.e. theory does (Prop 2.4).

### 2.5 How fast does the coin-free loss diverge? (extension E-Q2)

For a theory machine $G$ and a finite string $u$ let $A^G_u$ be the set of axioms emitted under prefixes of $u$.

**Proposition 2.6 (the proof horizon bounds the coin-free loss) [proved].** Let $G$ be a theory machine and $D_\infty$ a stream with
$$a_G:=\Unif\{\omega:B\cup A^G_\omega\text{ consistent},\ B\cup A^G_\omega\vdash D_\infty^\pm\}>0 .$$
Let the *proof horizon* $h_G(n)$ be the least $m$ with $\Unif\{\omega:B\cup A^G_\omega\text{ consistent},\ B\cup A^G_{\omega_{1:m}}\vdash\psi_{D_n}\}\ge a_G/2$. Then for every $n$,
$$-\log W_A(D_n)\ \le\ \Kpad(h_G(n))+K(G)+\log(2/a_G)+c .$$

*Proof.* $h_G(n)$ exists: a derivation of $\psi_{D_n}$ uses finitely many axioms, all emitted under some finite prefix, so the events in the definition increase in $m$ to a set containing the one defining $a_G$. Fix $m\ge h_G(n)$ and let $\mathrm{Good}_m$ be the set of $u\in\{0,1\}^m$ such that $B\cup A^G_u\vdash\psi_{D_n}$ and $[u]$ contains a tape $\omega$ with $B\cup A^G_\omega$ consistent. For $u\in\mathrm{Good}_m$, $A^G_u\subseteq A^G_\omega$, so $B\cup A^G_u$ is consistent and proves $\psi_{D_n}$; and $|\mathrm{Good}_m|2^{-m}\ge a_G/2$. The set $A^G_u$ is r.e. with an index $e(G,u)$ computable from $(G,u)$ and injective in $u$ (write $u$ into the index). Hence
$$W_A(D_n)\ge\sum_{u\in\mathrm{Good}_m}\mm(e(G,u))\ge\sum_{u\in\mathrm{Good}_m}2^{-K(G)-m-K(m)-c}\ge\tfrac{a_G}22^{-K(G)-K(m)-c},$$
using $K(e(G,u))\le K(G)+K(u)+c$ and $K(u)\le m+K(m)+c$ for $|u|=m$. Minimise $K(m)$ over $m\ge h_G(n)$. ∎

**Corollary 2.6′ (rate on the lottery stream) [proved].** On the stream of Theorem 2.2:
* $-\log W_A(D_n)\le\Kpad(n)+c$ for all $n$. Since $\Kpad$ grows more slowly than every computable unbounded nondecreasing function, the coin-free loss diverges, but more slowly than any computable unbounded function.
* $K_A(D_n)\le\lceil n/2\rceil+O(\log n)$, and $K_A(D_n)\to\infty$.

*Proof.* For $G=G_{\rm lot}$ and $\omega\in E$ (proof of 2.2(a)), the axioms needed for $D_n$ are emitted once the first $\lceil n/2\rceil$ blocks are read, i.e. by the prefix of length $m(n):=\sum_{k<\lceil n/2\rceil}(k+1)$; so $h_{G_{\rm lot}}(n)\le m(n)$, which is computable from $n$, whence $\Kpad(h(n))\le K(m(n))+c\le K(n)+c'$. As $D_n\subseteq D_{n'}$ for $n\le n'$, $W_A(D_n)\ge W_A(D_{n'})$, so $-\log W_A(D_n)\le\min_{n'\ge n}K(n')+c'=\Kpad(n)+c'$. *Slow growth*: for computable nondecreasing unbounded $g$, let $\eta(j)$ be the least $n'$ with $g(n')\ge j$ (computable); then $\eta(g(n)+1)>n$ and $\Kpad(n)\le K(\eta(g(n)+1))\le2\log(g(n)+1)+c$; apply this to $g:=\lfloor2^{G/3}\rfloor$ for a given computable unbounded nondecreasing $G$. *Upper bound on $K_A$*: with $K:=\lceil n/2\rceil$, the tickets $j^*_k$, $k<K$, are determined by the truth values of the $\Sigma_1$ facts "$B\cup\mathsf W_k\vdash\mathrm{Lot}_k$" and "$B\cup\mathsf W_k\vdash\neg\mathrm{Win}(\underline k,\underline j)$" ($j\le N_k$): $j^*_k$ is the least unrefuted ticket if $\mathsf W_k$ proves $\mathrm{Lot}_k$ and some ticket is unrefuted, and $0$ otherwise (an inconsistent $\mathsf W_k$ refutes all tickets). There are fewer than $2^{K+1}+K$ such facts; given $K$ and the number of true ones ($K+2$ bits), enumerate until that many are found. So $K(\psi_{D_n})\le K+O(\log K)$ and $K_A\le K(\psi_{D_n})+c$. $K_A\to\infty$ is 2.2(c). ∎

**The batch lottery [proved; computed: c1 A2].** Give lottery $k$ the $2^{2k+1}$ tickets $0,\dots,2^{2k+1}-1$ (a block of $2k+1$ bits) and diagonalise in it against every $e<2^k$ at once: the data of lottery $k$ are $(\mathrm{Lot}_k,1)$ and $(\mathrm{Win}(\underline k,\underline{j^*_{k,e}}),0)$ for $e<2^k$, with $j^*_{k,e}$ the least ticket that $B\cup\mathsf W_e$ does not refute if $B\cup\mathsf W_e$ is consistent and proves $\mathrm{Lot}_k$, and $0$ otherwise. At most $2^k$ tickets are reported, so the random theory survives lottery $k$ with probability $\ge1-2^k/2^{2k+1}=1-2^{-(k+1)}$ and Theorem 2.2(a) holds with the same product; after lottery $k$ every $e<2^k$ has failed, so $W_A\le\sum_{e\ge2^k}\mm(e)$. The horizon after $n$ data is at most $(n+1)^2$ (at most $n$ lotteries are complete), so again $-\log W_A(D_n)\le\Kpad(n)+c$.

**Open (E-Q2, remaining part).** Is there a stream with bounded one-tape loss on which $-\log W_A(D_n)\ge f(n)$ for some computable unbounded nondecreasing $f$? By Prop 2.6 such a stream would need, for every machine $G$ with $a_G>0$, a proof horizon $h_G(n)$ with $\Kpad(h_G(n))\ge f(n)-O(1)$, i.e. horizons that are not bounded by any computable function of $n$.

### 2.6 Co-r.e. streams

**Proposition 2.7 (co-r.e. streams over block-decidable classes) [proved; computed: c1 C].** Let $S\subseteq\Sent_{\mathcal L}$ be decidable and computably partitioned into finite blocks $S_0,S_1,\dots$ (each given by a canonical index), such that
* (i) for every finite $X\subseteq S$: $B\cup X$ is consistent iff $B\cup(X\cap S_k)$ is consistent for every $k$;
* (ii) consistency of $B\cup X$ for finite $X\subseteq S_k$ is decidable, uniformly in $k$.

If $D_\infty^\pm\subseteq S$ is co-r.e. and $B\cup D_\infty^\pm$ is consistent, then some consistent decidable $T\subseteq S$ contains $D_\infty^\pm$.

*Proof.* $S_k\setminus D_\infty^\pm$ is r.e. uniformly in $k$; let $C^s_k$ be $S_k$ minus what has been enumerated by stage $s$. As $S_k$ is finite, $C^s_k=D_\infty^\pm\cap S_k$ for large $s$, and that set is consistent with $B$; so by (ii) the least $s_k$ with $B\cup C^{s_k}_k$ consistent exists and is computable. Put $T:=\bigcup_kC^{s_k}_k$ (decidable). $C^s_k\supseteq D_\infty^\pm\cap S_k$ for all $s$, so $T\supseteq D_\infty^\pm$, and $B\cup T$ is consistent by compactness and (i). ∎

**Instances.** (1) The lottery class $S=\{\mathrm{Lot}_k\}\cup\{\mathrm{Win}(\underline k,\underline j)^{b}:j\le N_k,b\in\{0,1\}\}$ with blocks by $k$: under the hypotheses of §2.2 a finite $X\subseteq S$ is consistent with $B$ iff no block contains a complementary pair or $\mathrm{Lot}_k$ together with all $N_k+1$ negative literals of lottery $k$ (choose the $\mathrm{Win}$-row of each $\underline k$ separately in a model with distinct numerals), so (i) and (ii) hold. (2) The arithmetic lottery classes of §2.7: by Lemma 2.8(i) every propositionally satisfiable finite set of Boolean combinations of the tickets is consistent with $B$, so consistency is a propositional (decidable, blockwise) property. **So every stream of the lottery kinds that answers Q1 negatively is properly $\Delta_2$: neither r.e. nor co-r.e.**

**Open.** Whether *some* co-r.e. stream (over a sentence class where consistency is not decidable) has $\Unif(E_\infty)>0$ and no consistent r.e. theory proving it. Prop 2.7's adversary waits, in each block, for a stage at which the remaining data are certifiably consistent; a counterexample must deny it any such certificate at every finite stage.

### 2.7 Lotteries inside arithmetic (extension E-Q1)

The lottery needs a family of sentences that behave, with respect to consistency with $B$, like independent atoms. Inside arithmetic with a true background they are provided by self-referential ("flexible") formulas. I give a self-contained proof of the weak form needed, in a version that also prescribes the truth values in $\mathbb N$.

**Lemma 2.8 (flexible formulas with prescribed truth) [proved, given (Diag), ($\Sigma_1$C)].** Let $\mathcal L=\mathcal L_{\rm ar}$ and $B$ decidable, true, $B\supseteq\Q$. Write $\mathrm{In}(y,e)$ for a $\Delta_0$ formula saying "$y$ is in the finite set with canonical index $e$", and for finite $F\subseteq\mathbb N$ with index $e_F$ write $y\in F$ for $\mathrm{In}(y,\underline{e_F})$. For every formula $\Psi(z,x)$ there is a formula $\Phi(x)$ such that
* (i) $B+\forall y\,(\Phi(y)\leftrightarrow y\in F)$ is consistent for every finite $F\subseteq\mathbb N$; hence any finite pattern $\{\Phi(\underline n)^{b_n}:n\in F'\}$ is consistent with $B$;
* (ii) $\mathbb N\models\Phi(\underline n)\iff\mathbb N\models\Psi(\ulcorner\Phi\urcorner,\underline n)$ for every $n$;
* (iii) $\Q\vdash\forall x\,\big(\Phi(x)\leftrightarrow\mathcal A(x)\vee(\mathcal N\wedge\Psi(\ulcorner\Phi\urcorner,x))\big)$ for a $\Sigma_1$ formula $\mathcal A(x)$ that is false of every number and a true $\Pi_1$ sentence $\mathcal N$.

*Proof.* Fix a computable enumeration $\tau_0,\tau_1,\dots$ of the theorems of $B$. For a code $z$ let $\varphi_z$ be the formula with code $z$, and call a sentence *of form $(z,e)$* if it is $\neg\forall y\,(\varphi_z(y)\leftrightarrow\mathrm{In}(y,\underline e))$; whether $\tau_s$ is of form $(z,e)$ for some $e$, and which $e$, is decidable from $(s,z)$. Let $\mathcal A_0(z,x)$ be the $\Sigma_1$ formula "there are $s$ and $e$ such that $\tau_s$ is of form $(z,e)$, no $\tau_{s'}$ with $s'<s$ is of form $(z,e')$ for any $e'$, and $\mathrm{In}(x,e)$" (the computation of $\tau_0,\dots,\tau_s$ is an existentially quantified witness, checked by a $\Delta_0$ formula), and $\mathcal N_0(z)$ the $\Pi_1$ formula "no $\tau_s$ is of form $(z,e)$ for any $e$". By (Diag) take $\Phi$ with
$$\Q\vdash\forall x\,\big(\Phi(x)\leftrightarrow\mathcal A_0(\ulcorner\Phi\urcorner,x)\vee(\mathcal N_0(\ulcorner\Phi\urcorner)\wedge\Psi(\ulcorner\Phi\urcorner,x))\big).$$
As $\Q$ is true, the same equivalence holds in $\mathbb N$. Suppose some $\tau_s$ is of form $(\ulcorner\Phi\urcorner,e)$; let $s_0$ be the least such $s$, with index $e_0$ and set $F_0$. In $\mathbb N$, $\mathcal A_0(\ulcorner\Phi\urcorner,n)$ holds iff $n\in F_0$, and $\mathcal N_0$ fails; so $\mathbb N\models\forall y\,(\Phi(y)\leftrightarrow y\in F_0)$. But $\tau_{s_0}$, the negation of this sentence, is a theorem of the true theory $B$. Contradiction. Hence no theorem of $B$ is of form $(\ulcorner\Phi\urcorner,e)$, which is (i) (the pattern follows from $\forall y(\Phi(y)\leftrightarrow y\in F)$ with $F:=\{n\in F':b_n=1\}$, since $\Q$ decides each $\underline n\in F$ correctly); $\mathcal N_0(\ulcorner\Phi\urcorner)$ is true and $\mathcal A_0(\ulcorner\Phi\urcorner,\underline n)$ false for every $n$, which gives (ii) and (iii) with $\mathcal A(x):=\mathcal A_0(\ulcorner\Phi\urcorner,x)$, $\mathcal N:=\mathcal N_0(\ulcorner\Phi\urcorner)$. ∎

*Literature.* This is the standard self-referential construction behind Kripke's flexible formulas (Kripke 1962) and Mostowski's independent sequences (Mostowski 1961); Woodin's universal algorithm (Woodin 2011; Blanck–Enayat 2017; Hamkins 2018) is a much stronger statement of the same kind. The version with a prescribed truth set (ii) is what the true lottery needs; I did not find it stated in this form, but it is a routine variant and I claim no novelty for it.

Let $\langle k,j\rangle$ be a $\Delta_0$ pairing and write $\underline{\langle k,j\rangle}$ for the numeral of the pair code.

**Theorem 2.9 (lotteries in arithmetic) [proved, given Lemma 2.8].** Let $\mathcal L=\mathcal L_{\rm ar}$ and $B$ decidable, true, $B\supseteq\Q$. Let $\mathsf W_e$ range over r.e. sets of $\mathcal L_{\rm ar}$-sentences.
* (a) **False $\Sigma_1$ lotteries.** Let $\Phi_0$ be Lemma 2.8's formula for $\Psi:\equiv(x\ne x)$, and put $\theta_{k,j}:=\Phi_0(\underline{\langle k,j\rangle})$ and $\mathrm{Lot}^{\rm ar}_k:=\bigvee_{j\le N_k}\theta_{k,j}$. Define $j^*_e$ and the stream $D^{(a)}_\infty:=((\mathrm{Lot}^{\rm ar}_k,1),(\theta_{k,j^*_k},0))_{k\ge0}$ exactly as in Theorem 2.2, with $\theta_{e,j}$ in place of $\mathrm{Win}(\underline e,\underline j)$. Then (a)–(d) of Theorem 2.2 hold. Each $\theta_{k,j}$ is $\Q$-equivalent to a false $\Sigma_1$ sentence; so the data are false $\Sigma_1$ sentences labelled true ($\mathrm{Lot}^{\rm ar}_k$) and true $\Pi_1^*$ sentences ($\neg\theta_{k,j^*_k}$).
* (b) **True lotteries.** Let $\mathrm{Ref}(z,k,j)$ be the $\Sigma_1$ formula "$B\cup\mathsf W_k\vdash\neg\varphi_z(\underline{\langle k,j\rangle})$", and $\Psi(z,x)$ the formula "$x=\langle k,t\rangle$ for some $k$ and some $t\le N_k$ such that either $\mathrm{Ref}(z,k,t)\wedge\forall i<t\,\neg\mathrm{Ref}(z,k,i)$, or $t=0\wedge\forall i\le N_k\,\neg\mathrm{Ref}(z,k,i)$". Let $\Phi_1$ be Lemma 2.8's formula for this $\Psi$, $\theta_{k,j}:=\Phi_1(\underline{\langle k,j\rangle})$, $\mathrm{Lot}^{\rm ar}_k:=\bigvee_{j\le N_k}\theta_{k,j}$, and $t_k$ the least $j\le N_k$ with $B\cup\mathsf W_k\vdash\neg\theta_{k,j}$ ($t_k:=0$ if none). Let $j^*_k$ be the least $j\le N_k$ with $j\ne t_k$ and $B\cup\mathsf W_k\nvdash\neg\theta_{k,j}$ if $B\cup\mathsf W_k$ is consistent and proves $\mathrm{Lot}^{\rm ar}_k$, and the least $j\ne t_k$ otherwise. Then the stream $D^{(b)}_\infty:=((\mathrm{Lot}^{\rm ar}_k,1),(\theta_{k,j^*_k},0))_k$ satisfies (a)–(d) of Theorem 2.2, **every datum is true in $\mathbb N$**, and every datum is $\Q$-equivalent to a Boolean combination of $\Sigma_1$ sentences.

*Proof.* *The random theory.* $G^{\rm ar}_{\rm lot}$ emits $\mathrm{Lot}^{\rm ar}_k$, $\theta_{k,J_k}$ and $\neg\theta_{k,j}$ ($j\le N_k$, $j\ne J_k$) after reading block $k$. A finite part of its output is implied by $B+\forall y\,(\Phi(y)\leftrightarrow y\in F)$ with $F:=\{\langle k,J_k\rangle:k\le K\}$, so by Lemma 2.8(i) and compactness its theory is consistent with $B$ on every tape. *The diagonal.* If $B\cup\mathsf W_e$ is consistent and proves $\mathrm{Lot}^{\rm ar}_e$, it does not refute every $\theta_{e,j}$, $j\le N_e$ (propositionally $\mathrm{Lot}^{\rm ar}_e\wedge\bigwedge_j\neg\theta_{e,j}$ is contradictory). In (b), $j^*_e$ exists in this case: if $\mathsf W_e$ refutes some ticket then $t_e$ is refuted and every unrefuted ticket differs from $t_e$; if it refutes none then $t_e=0$ and $j=1$ is unrefuted ($N_e\ge1$). Everything else is the proof of Theorem 2.2 verbatim, with $\theta$ for $\mathrm{Win}$: survival probability $\prod_k(1-2^{-(k+1)})$, the diagonal kills every consistent r.e. theory, dominated convergence, horizon.
*Truth and complexity.* (a) By Lemma 2.8(ii) with $\Psi\equiv\bot$ every $\theta_{k,j}$ is false, and by (iii) $\Q\vdash\theta_{k,j}\leftrightarrow\mathcal A(\underline{\langle k,j\rangle})$ (the second disjunct is $\Q$-refutable), a $\Sigma_1$ sentence. (b) By Lemma 2.8(ii), $\theta_{k,j}$ is true iff $j=t_k$; hence $\mathrm{Lot}^{\rm ar}_k$ is true and $\theta_{k,j^*_k}$ is false ($j^*_k\ne t_k$). By (iii), $\theta_{k,j}$ is $\Q$-equivalent to $\mathcal A(\underline{\langle k,j\rangle})\vee(\mathcal N\wedge\Psi(\ulcorner\Phi_1\urcorner,\underline{\langle k,j\rangle}))$, and with a numeral argument the bounded quantifiers of $\Psi$ unfold, provably in $\Q$, into a Boolean combination of the $\Sigma_1$ sentences $\mathrm{Ref}(\ulcorner\Phi_1\urcorner,k,i)$, $i\le N_k$. ∎

**Corollary 2.10 (true data, false theories) [proved].** On the stream $D^{(b)}_\infty$ of Theorem 2.9(b):
* (i) every datum is a true sentence of low complexity (a Boolean combination of $\Sigma_1$ sentences), $L_A(D_n)$ is bounded, and $K_A(D_n)-L_A(D_n)\to\infty$ with $L_A$ bounded. So no coding theorem of the form $K_A\le L_A+f(L_A)$ holds for true data beyond $\Sigma_1\cup\Pi_1$ (compare Cor 3.3: it holds for $\Pi_1^*$ and true $\Sigma_1$ data);
* (ii) $P_\infty\{\omega:B\cup A_\omega\subseteq\Th(\mathbb N)\}=0$: in the limit the posterior is concentrated on **false** theories, although every datum is true;
* (iii) the random lottery theory of $G^{\rm ar}_{\rm lot}$ is $\Sigma_1$-unsound on every tape with $J_k\ne t_k$ for some $k$, which, conditionally on its survival, has probability $1$.

*Proof.* (i) Theorem 2.9(b) with 2.2(a),(c). (ii) If $\Unif\{\omega\in E_\infty:B\cup A_\omega\text{ true}\}>0$, Prop 2.4 gives an r.e. true theory proving the stream, contrary to 2.2(b). (iii) Fix $k$ with $J:=J_k\ne t_k$; the theory proves $\theta_{k,J}$, $\Q$-equivalent to $\mathcal A_{k,J}\vee(\mathcal N\wedge\Psi_{k,J})$ with $\mathcal A_{k,J}$ a false $\Sigma_1$ sentence. Write $R_i$ for $\mathrm{Ref}(\ulcorner\Phi_1\urcorner,k,i)$. If some ticket is refuted and $J>t_k$: $R_{t_k}$ is a true $\Sigma_1$ sentence, $\Q\vdash R_{t_k}$, so $\Q\vdash\neg\Psi_{k,J}$ and the theory proves $\mathcal A_{k,J}$. If $J<t_k$, or no ticket is refuted (then $t_k=0<J$): $\Psi_{k,J}$ implies $R_J$ (for $J=0<t_k$ via $\Q\vdash R_{t_k}$, which refutes the "none refuted" disjunct), and $R_J$ is false; the theory proves $\mathcal A_{k,J}\vee R_J$, a false $\Sigma_1$ sentence. Given survival ($J_k\ne j^*_k$ for all $k$), the events $J_k=t_k$ are independent with probabilities $1/N_k$, so all hold with probability $\prod_k1/N_k=0$. ∎

*Reading.* Cor 2.10 is the sharpest form of "the hypotheses that succeed are random theories, not theories". Fed only true arithmetic sentences, of the lowest complexity beyond $\Sigma_1\cup\Pi_1$, the one-tape inducer predicts with bounded total loss, and in the limit it believes, with probability one, theories that are false (ii); the random lottery theories among them are moreover $\Sigma_1$-unsound (iii). A random theory that guesses winners is right where the data check it and wrong, at all but finitely many lotteries, where they do not.

**Open.** Whether $P_\infty(\text{$\Sigma_1$-sound})=0$ on this stream. Prop 2.4's majority argument does not transfer to $\Sigma_1$-soundness, which is not a constraint of arity one.

---

## 3. $\Pi_1$ data: derandomisation, a coding theorem, Chaitin (target T2)

### 3.1 Setting

Throughout §3: $\mathcal L\supseteq\mathcal L_{\rm ar}$, $B$ decidable, true, $B\supseteq\Q$. $\Inc_0$ is left-c.e. and not computable (`fundamentals` Thm 3.2(a)), hence irrational. $I'_k:=\lfloor2^{k+2}\Inc_0\rfloor2^{-(k+2)}$, so $I'_k\le\Inc_0<I'_k+2^{-(k+2)}$; $I'_k$ is given by an integer below $2^{k+2}$, i.e. by $k+2$ bits once $k$ is known. A data set $D$ is **of $\Pi_1$ type** if each literal in $D^\pm$ is in $\Pi_1^*$ or is a true $\Sigma_1$ sentence; then $\psi_D$ is logically equivalent to $\pi_D\wedge\sigma_D$ with $\pi_D\in\Pi_1^*$ and $\sigma_D$ a conjunction of true $\Sigma_1$ sentences, $B\vdash\sigma_D$ by ($\Sigma_1$C), and so $O_{\psi_D}=O_{\pi_D}$ and $M_A(D)=\Bel_0(\pi_D)$.

### 3.2 Derandomisation

**Theorem 3.1 (threshold theories; scout N1's A1) [proved; computed: c3 T1].** There is $c$ such that for every $k\ge0$ the set
$$T_k:=\{\pi\in\Pi_1^*:\Unif(O_\pi)>I'_k+2^{-(k+2)}\}$$
(i) is r.e. with an index $e_k$ of complexity $K(e_k)\le k+K(k)+c$; (ii) contains every $\pi\in\Pi_1^*$ with $\Bel_0(\pi)\ge2^{-k}$; (iii) consists of true sentences of positive prior belief, so $B\cup T_k$ is true, consistent and $\Sigma_1$-sound.

*Proof.* (i) $\Unif(O_\pi)$ is left-c.e. uniformly in $\pi$, and $\Pi_1^*$ is decidable, so $T_k$ is r.e. uniformly in $(k,I'_k)$; a program consists of a self-delimiting description of $k$, the $k+2$ bits of $I'_k$, and a fixed code. (ii) $\Unif(O_\pi)=\Inc_0+\Bel_0(\pi)\ge I'_k+2^{-k}>I'_k+2^{-(k+2)}$. (iii) If $\Unif(O_\pi)>I'_k+2^{-(k+2)}>\Inc_0$, then $\Bel_0(\pi)>0$: some tape has $B\cup A_\omega$ consistent and proving $\pi$, and $\pi$ is true by ($\Pi_1$T). ∎

The threshold can also be left random. This gives a cleaner statement, which also drives §4.3.

**Theorem 3.2 (the threshold machine) [proved; computed: c3 T2].** Let $G^*$ be the theory machine that, after reading $s$ tape bits $u$, emits every $\pi\in\Pi_1^*$ for which some lower approximation of $\Unif(O_\pi)$ exceeds $0.u+2^{-s}$ ($0.u$ the dyadic rational with digits $u$). For a tape $r$ that is not a dyadic rational (read as a real),
$$A^{G^*}_r=\{\pi\in\Pi_1^*:\Unif(O_\pi)>r\};$$
it is inconsistent if $r<\Inc_0$ and true if $r>\Inc_0$. For every data set $D$ of $\Pi_1$ type,
$$M_A(D)\ \le\ \nu_{G^*}(D)\ \le\ 2^{K(G^*)}M_A(D).$$

*Proof.* $\pi$ is emitted iff $\Unif(O_\pi)>0.r_{1:s}+2^{-s}$ for some $s$; as $0.r_{1:s}+2^{-s}$ decreases to $r$ and stays above it (non-dyadic $r$), this is iff $\Unif(O_\pi)>r$. If $r<\Inc_0$, every $\pi\in\Pi_1^*$ has $\Unif(O_\pi)\ge\Inc_0>r$, including false ones such as $\neg(0=0)$. If $r>\Inc_0$, every emitted $\pi$ has $\Bel_0(\pi)>0$ and is true by ($\Pi_1$T); $B$ is true; so $B\cup A^{G^*}_r$ is true. For $D$ of $\Pi_1$ type: if $\Inc_0<r<\Unif(O_{\pi_D})$, the theory is consistent and contains $\pi_D$, and $B\vdash\sigma_D$; so $\nu_{G^*}(D)\ge\Unif(O_{\pi_D})-\Inc_0=\Bel_0(\pi_D)=M_A(D)$. The upper bound is (Dom). ∎

*Reading.* On data of $\Pi_1$ type the universal random theory can be replaced, up to a constant factor, by **one** random theory: "every $\Pi_1^*$ sentence whose prior probability of being proved exceeds a uniformly random level". It is true whenever it is consistent, and its theories form a decreasing chain as the level rises. Theorem 3.1 is the special case in which $k+2$ bits of the level are fixed just above $\Inc_0$. The random tape helps on $\Pi_1$ data only by choosing the level, and choosing the level costs only what the probability of the datum already charges.

### 3.3 Corollaries

**Corollary 3.3 (a coding theorem for $\Pi_1$ data; scout N1's A2) [proved].** For every $D$ of $\Pi_1$ type,
$$L_A(D)\le-\log W_A(D)+c\le K_A(D)+c\le L_A(D)+K(\lceil L_A(D)\rceil)+c' .$$

*Proof.* The first two inequalities are (Chain). For the last, let $k:=\lceil L_A(D)\rceil$, so $\Bel_0(\pi_D)=M_A(D)\ge2^{-k}$; by Thm 3.1, $\pi_D\in T_k$, and $B\cup T_k$ is consistent and proves $\pi_D$ and $\sigma_D$. So $K_A(D)\le K(e_k)+c\le k+K(k)+c$. ∎

**Remark 3.4 (the coin-free version sums over levels) [proved; computed: c3 T4].** $-\log W_A(D)\le L_A(D)+\Kpad(\lceil L_A(D)\rceil+1)+c$ for $D$ of $\Pi_1$ type. *Proof.* For a dyadic $q$ let $Z_q:=\{\pi\in\Pi_1^*:\Unif(O_\pi)>q\}$, r.e. uniformly and injectively in $q$; for $q\in(\Inc_0,\Unif(O_{\pi_D}))$ it is true and contains $\pi_D$. With $k:=\lceil L_A(D)\rceil$ the interval has length $M_A(D)\ge2^{-k}$ and contains at least $2^{L-k-1}$ dyadic rationals of level $L$ for each $L\ge k+1$, each of complexity $\le L+K(L)+c$. So $W_A(D)\ge\sum_{L\ge k+1}2^{L-k-1}2^{-L-K(L)-c}\ge2^{-k-1-c-\Kpad(k+1)}$. ∎ Whether $K_A\le L_A+O(1)$ on $\Pi_1$ data is **[open]**; the deterministic threshold needs the level written in full.

**Corollary 3.5 (bounded loss on a $\Pi_1$ stream is explained by one true theory; scout N1's A3) [proved].** If $D_\infty$ has all its finite parts of $\Pi_1$ type and $\sup_nL_A(D_n)\le k$, then $B\cup T_k$ is true, proves every datum, and has an index of complexity $\le k+K(k)+c$; so $\sup_n-\log W_A(D_n)\le k+K(k)+c$ and scout F's Q1 holds on such streams. *Proof.* Thm 3.1(ii) for each $\pi_{D_n}$; $T_k$ does not depend on $n$. ∎

**Corollary 3.6 (Chaitin's theorem for random theories; scout N1's A4) [proved].** Code binary strings by length-lexicographic rank, so that the strings of length $\le m$ are the codes $\le P_m:=2^{m+1}-2$. Let $\mathrm{T}(p,t,y)$ be a $\Delta_0$ formula expressing "$t$ codes a halting computation of $V$ on $p$ with output $y$", and
$$\mathrm{Kgt}_m(x):=\forall t\,\forall p\,\big(p\le\underline{P_m}\to\neg\mathrm T(p,t,\underline x)\big),$$
a $\Pi_1$ sentence, true iff $K(x)>m$. Then for every $m$ and $x$:
* (a) if $K(x)\le m$, $L_A(\{(\mathrm{Kgt}_m(x),1)\})=\infty$; if $K(x)>m$, $L_A(\{(\mathrm{Kgt}_m(x),1)\})\ge m-K(m)-K(\lceil L_A\rceil)-c\ge m-2\log m-O(\log\log m)$;
* (b) if $K(x)>m$, $L_A(\{(\mathrm{Kgt}_m(x),1)\})\le K_A(\{(\mathrm{Kgt}_m(x),1)\})+c\le m+K(m)+c'$, and one true theory $B\cup\{\beta_m\}$ of complexity $\le m+K(m)+c$ proves $\mathrm{Kgt}_m(x)$ for every such $x$ at once.

*Proof.* *(Chaitin, deterministic.)* If $B\cup\mathsf W_e$ is consistent and proves $\mathrm{Kgt}_m(x)$, the program "given $e$ and $m$, enumerate the theorems of $B\cup\mathsf W_e$ and output the first $z$ with $\mathrm{Kgt}_m(z)$ among them" halts with some $z$, $K(z)\le K(e)+K(m)+c$; $\mathrm{Kgt}_m(z)$ is true by ($\Pi_1$T), so $K(z)>m$, whence $K(e)>m-K(m)-c$. So $K_A\ge m-K(m)-c$.
*(b)* Let $s_m$ be the largest code of a halting computation of $V$ on a program of length $\le m$ ($0$ if none), and $\beta_m:=\forall t\,\forall p\,\forall y\,(p\le\underline{P_m}\wedge\mathrm T(p,t,y)\to t\le\underline{s_m})$, a true $\Pi_1$ sentence. For $x$ with $K(x)>m$, the $\Delta_0$ sentence $\forall p\le\underline{P_m}\,\forall t\le\underline{s_m}\,\neg\mathrm T(p,t,\underline x)$ is true, hence $\Q$-provable, and with $\beta_m$ it gives $\mathrm{Kgt}_m(x)$. $s_m$ is computable from $m$ and the number $h_m\le2^m$ of halting programs of length $\le m$ (Kraft), an $(m+1)$-bit number: run them until $h_m$ have halted. So $K(\beta_m)\le K(m)+m+c$.
*(a)* For $K(x)\le m$ the datum is a false $\Pi_1$ sentence and $M_A=0$ by ($\Pi_1$T). Otherwise Cor 3.3 and the deterministic bound give $L_A\ge K_A-K(\lceil L_A\rceil)-c'\ge m-K(m)-K(\lceil L_A\rceil)-c''$; by (b), $\lceil L_A\rceil\le m+K(m)+c$, so $K(\lceil L_A\rceil)\le\log m+O(\log\log m)$, and $K(m)\le\log m+O(\log\log m)$. ∎

*Reading.* The datum $(\mathrm{Kgt}_m(x),1)$ carries at most one bit of label information: unconstrained SOI predicts it at cost $O(1)$ ("always true"), and the general lower bound of `fundamentals` Prop 5.6 is $O(1)$ here. Yet SAI, and consistent SOI with it, pays $m\pm O(\log m)$ bits, with random or deterministic hypotheses alike. That is the price of the consistency constraint at $\Pi_1$: every $\Pi_1$ affirmation must be backed by a true theory, and a true theory that proves high complexity lower bounds contains the corresponding halting information. Paying once pays for all such data at level $m$: one $m$-bit $\Pi_1$ law $\beta_m$ explains every true lower bound at level $m$, a clean instance of "laws versus data". The statement is about the inducer's loss; it does not say that a theory of $k$ bits "contains at most $k$ bits" (scout L's caution, after Raatikainen 1998): the deterministic step is exactly Chaitin's upper bound $K(e)>m-K(m)-c$, which Raatikainen does not dispute (§7).

**Proposition 3.7 (scout F's Q2 for true $\Pi_1$-axiomatised theories; scout N1's A6) [proved].** Let $T$ be an r.e. set of true $\Pi_1^*$ sentences and $k:=\lceil-\log\Unif_A(\Ext T)\rceil$. Then
$$-\log\Unif_A(\Ext T)-c\le-\log\mm(\Ext T)\le-\log\Unif_A(\Ext T)+K(k)+c.$$

*Proof.* Right: each $\pi\in T$ has $\Bel_0(\pi)\ge\Unif_A(\Ext T)\ge2^{-k}$, so $T\subseteq T_k$ and $e_k\in\Ext(T)$; $\mm(\Ext T)\ge\mm(e_k)\ge2^{-k-K(k)-c}$. Left: $\Unif_A(\Ext T)\ge2^{-c}\mm(\Ext T)$ (`fundamentals` §1.6). ∎ Q2 for the exact class $[T]$, and for general $T$, stays open (`fundamentals` Prop 11.5 reduces it to probabilistic versus deterministic enumeration).

### 3.4 Relation to the literature (novelty)

* **Bienvenu, Romashchenko, Shen, Taveneaux, Vermeeren (2014)** add to $\PA$ axioms "$C(x)\ge n-c$" for uniformly random strings $x$, with probabilistic proof strategies that spend an initial "capital" $\varepsilon$; a corollary says that a statement proved with probability above the capital is true, and the abstract says that such random axioms do not help prove new interesting theorems, can shorten proofs (unless NP = PSPACE), that adding all true statements "$C(x)>n$" proves every true $\Pi_1$ sentence, and that one carefully chosen such statement per $n$ suffices while statements for most strings give a weak theory [known: abstract and search snippets; full text not read, §9]. Shen (2011) is the preliminary note ("Are random axioms useful?").
* **What is new here.** (1) The random object: an arbitrary random theory machine (the universal mixture over all of them, inconsistent ones included), not a fixed scheme of complexity axioms. (2) The conclusion: a quantitative derandomisation, "a $\Pi_1$ sentence proved with probability $2^{-k}$ is proved by one true theory of complexity $k+O(\log k)$" (Thm 3.1), and the single random threshold theory (Thm 3.2). Neither is a counting argument over a fixed axiom scheme; both use the consistency probability $\Inc_0$. (3) The corollaries for an inductive inference rule: the coding theorem on $\Pi_1$ data (Cor 3.3), against its failure on literals (`fundamentals` Thm 6.2) and on Boolean combinations of $\Sigma_1$ (§3.5).
* **What is known in substance.** The truth-certificate principle (a $\Pi_1$ sentence proved by a consistent extension of $\Q$ is true) is standard; the soundness corollary of Bienvenu et al. is a probabilistic relative. The theory $\beta_m$ of Cor 3.6(b) ("the number of halting programs of length $\le m$") is the classical way to prove all true complexity bounds at level $m$, close to Bienvenu et al.'s "one carefully chosen statement per $n$"; Cor 3.6's deterministic step is Chaitin (1974).
* **Levin (2013)** ("Forbidden information") bounds the probability that a randomised algorithm produces a consistent completion of $\PA$ on formulas of size $n$ by $2^{-n}$ (up to factors) [known: abstract and search snippets]. This is a quantitative relative of `fundamentals` Prop 8.7 (random theories above $\Q$ are almost surely incomplete) and belongs in its related work.

### 3.5 Where the coding theorem fails (extensions A5, A-Q1)

**Proposition 3.8 (one false $\Sigma_1$ datum; scout N1's A5) [proved, given Lemma 2.8].** Let $\mathcal L=\mathcal L_{\rm ar}$, $B$ decidable, true, $\supseteq\Q$, and $\Phi_0$ the formula of Theorem 2.9(a) (false of every number, $\Q$-equivalent to a $\Sigma_1$ formula, every finite pattern of its instances consistent with $B$). For every $d\ge2$ there are distinct $x_1,x_2\in\{0,1\}^d$ such that $D:=\{(\Phi_0(\underline{x_1}),0),(\Phi_0(\underline{x_2}),1)\}$ (strings read as numbers) has $K_A(D)>\log d-2$ and $L_A(D)\le2+c$. The literal $\neg\Phi_0(\underline{x_1})$ is a true $\Pi_1^*$ sentence; $\Phi_0(\underline{x_2})$ is a false $\Sigma_1$ sentence.

*Proof.* *Upper bound.* The machine that, for every $n$, reads a fresh bit $b_n$ and emits $\Phi_0(\underline n)^{b_n}$ has a consistent theory on every tape (Lemma 2.8(i) and compactness) and proves $D$ with probability $\frac14$; apply (Dom). *Lower bound (colouring, as in `fundamentals` Thm 6.2).* Let $\ell:=\lceil\log(d/\log3)\rceil-1$, so $3^{2^\ell}<2^d$. Fewer than $2^\ell$ programs have length $<\ell$. Colour each $x\in\{0,1\}^d$ by the vector, over these programs $p$, of "$+$" if $B\cup\mathsf W_{V(p)}$ is consistent and proves $\Phi_0(\underline x)$, "$-$" if consistent and proves $\neg\Phi_0(\underline x)$, "$*$" otherwise. Two distinct $x_1,x_2$ share a colour; no program shorter than $\ell$ gives a consistent theory proving $\neg\Phi_0(\underline{x_1})\wedge\Phi_0(\underline{x_2})$. So $K_A(D)\ge\ell\ge\log d-\log\log3-1>\log d-2$. ∎

**Proposition 3.9 (two true data; A-Q1) [proved, given Lemma 2.8].** Under the same hypotheses there is a formula $\Phi_2$ such that for every $d\ge2$ some distinct $x_1,x_2\in\{0,1\}^d$ give **true** data $D_d:=\{(\Phi_2(\underline{x_1}),0),(\Phi_2(\underline{x_2}),1)\}$ with $K_A(D_d)>\log d-2$ and $L_A(D_d)\le2+c$. Each datum is $\Q$-equivalent to a Boolean combination of $\Sigma_1$ sentences (in particular, $\Phi_2(\underline{x_2})$ is a true $\Sigma_2$ sentence and $\neg\Phi_2(\underline{x_1})$ a true $\Pi_2$ sentence).

*Proof.* Let $\Psi(z,x)$ say: "$x$ is a string of some length $d\ge2$, and $x$ is the second element of the lexicographically first pair of distinct strings of length $d$ that have the same colour", the colour of a string $y$ being computed as in Prop 3.8 with $\varphi_z$ in place of $\Phi_0$ (over the programs of length $<\ell_d$). Let $\Phi_2$ be Lemma 2.8's formula for $\Psi$ and $(x_1,x_2)$ that pair for $z=\ulcorner\Phi_2\urcorner$. By Lemma 2.8(ii), $\Phi_2(\underline{x_2})$ is true and $\Phi_2(\underline{x_1})$ false; the fair-coin machine of Prop 3.8 (with $\Phi_2$) gives $L_A(D_d)\le2+c$ by Lemma 2.8(i); the pair has the same colour for the actual $\Phi_2$, which gives $K_A(D_d)\ge\ell_d$. For a numeral argument, $\Psi(\ulcorner\Phi_2\urcorner,\underline x)$ quantifies only over the finitely many colour tables for length $|x|$, and each entry of a table is a Boolean combination of $\Sigma_1$ facts (halting of $V$, provability, consistency); $\Q$ unfolds the bounded quantifiers, so with Lemma 2.8(iii) each datum is $\Q$-equivalent to a Boolean combination of $\Sigma_1$ sentences. ∎

**Answer to A-Q1.** No: true data do not admit a coding theorem beyond $\Sigma_1\cup\Pi_1$. Already two true data that are Boolean combinations of $\Sigma_1$ sentences give the $\log d$ gap (Prop 3.9), and a stream of such data gives bounded one-tape loss with $K_A\to\infty$ (Cor 2.10). The boundary is exact at the first level: $\Pi_1^*$ and true $\Sigma_1$ literals admit the coding theorem (Cor 3.3); Boolean combinations of $\Sigma_1$ sentences do not.

**Table 3.10 (where the random tape helps) [proved; references to items above].**

| data | can $M_A$ beat $W_A$ or $K_A$ by more than $O(\log)$? | reason |
|---|---|---|
| $\Pi_1^*$ and true $\Sigma_1$ literals (true $B\supseteq\Q$) | **no** (Cor 3.3, 3.5); $M_A\asymp\nu_{G^*}$ (Thm 3.2) | positive probability certifies truth; truths are jointly consistent |
| literals of a fresh predicate | on finite data yes (`fundamentals` Thm 6.2); not bounded-against-unbounded on a stream (Prop 2.3) | binary inconsistency; majority vote |
| sentences with inconsistency of unbounded arity ($\mathrm{Win}$-lottery) | yes, bounded against unbounded on one stream (Thm 2.2) | the majority vote is inconsistent |
| one false $\Sigma_1$ literal with one true $\Pi_1$ literal | yes on finite data (Prop 3.8) | consistent theories can affirm false $\Sigma_1$ sentences, incompatibly |
| false $\Sigma_1$ and true $\Pi_1$ literals, a stream | yes, bounded against unbounded (Thm 2.9(a)) | lottery on flexible $\Sigma_1$ atoms |
| **true** Boolean combinations of $\Sigma_1$ sentences | yes on two data (Prop 3.9) and bounded against unbounded on a stream (Thm 2.9(b), Cor 2.10) | truth no longer certified by positive probability |

---

## 4. Gödel phenomena (target T3)

### 4.1 The arithmetical shape of the trichotomy

**Proposition 4.1 (scout N1's D1) [proved; computed: c4].** Let $B$ be decidable and consistent with $\Q\subseteq\Cn(B)$, and $D$ consistent.
* (a) If $\sigma$ is a true $\Sigma_1$ sentence, $\Bel_D(\sigma)=1$.
* (b) If $\pi\in\Pi_1^*$ is false, $(\Bel_D,\Dis_D,\Indep_D)(\pi)=(0,1,0)$. Equivalently: $\Bel_D(\pi)>0$ or $\Indep_D(\pi)>0$ implies that $\pi$ is true.
* (c) If $B\cup D^\pm$ is true (has a model whose $\mathcal L_{\rm ar}$-reduct is $\mathbb N$), $\pi\in\Pi_1^*$ is true and $B\cup D^\pm\nvdash\pi$, then $\Bel_D(\pi),\Dis_D(\pi),\Indep_D(\pi)$ are all positive.
* (d) If $B\cup D^\pm$ is true, $\sigma$ is a false $\Sigma_1$ sentence and $B\cup D^\pm\nvdash\neg\sigma$, all three values of $\sigma$ are positive.

*Proof.* (a) The posterior lives on consistent extensions of $\Q$, all of which prove $\sigma$. (b) Some conjunct of $\pi$ is false, its negation is a true $\Sigma_1$ sentence, so every consistent extension of $\Q$ proves $\neg\pi$. (c) The r.e. theories $D^\pm\cup\{\pi\}$ (true in the model of $B\cup D^\pm$ with $\mathcal L_{\rm ar}$-reduct $\mathbb N$, so consistent with $B$; proves $\pi$), $D^\pm\cup\{\neg\pi\}$ (consistent with $B$ as $B\cup D^\pm\nvdash\pi$; proves $\neg\pi$) and $D^\pm$ (proves neither: not $\pi$ by hypothesis, not $\neg\pi$ because $B\cup D^\pm$ is true and $\neg\pi$ false) all prove $\psi_D$ and have positive weight (Dom). (d) Apply (c) to the $\Pi_1^*$ sentence $\neg\sigma$. ∎

*Reading.* The inducer errs one-sidedly, in opposite directions on the two classes:

| class | positive "true" on a false sentence? | positive "false" on a true sentence? | what positive "independent" means |
|---|---|---|---|
| $\Sigma_1$ | possible ($\Sigma_1$-unsound theories) | **never** | the sentence is false |
| $\Pi_1$ ($\Con(T)$, Gödel sentences, $\mathrm{Kgt}_m(x)$, Goldbach) | **never** | possible | the sentence is true |

So "independent" on a $\Pi_1$ question certifies truth: inside the inducer this is the content of "the Gödel sentence is true because it is unprovable". It also shows what the normalised convention throws away: $\Bel/(\Bel+\Dis)$ is $0$ on false $\Pi_1$ sentences, but it discards the $\Indep$ share, which only true $\Pi_1$ sentences carry. *Extreme case [proved].* If the data present $T:=\PA+\neg\Con(\PA)$ (consistent and $\Sigma_1$-unsound), every consistent extension of $T$ proves $\neg\Con(T)$ (as $\PA\vdash\Con(T)\to\Con(\PA)$), so $\Dis(\Con(T))=1$ although $\Con(T)$ is true.

The check c4 builds a finite model in which the only arithmetical input of Prop 4.1, ($\Sigma_1$C), is imposed (a world $0$ playing $\mathbb N$; true $\Sigma_1$ sentences hold in every world), and confirms (a)–(d) and the one-sided error pattern on 3000 random instances.

### 4.2 Soundness is never learned (coin-free), and a reduction

**Theorem 4.2 (coin-free; scout N1's D2) [proved, given (G2)].** Let $B$ be decidable and consistent with $\PA\subseteq\Cn(B)$. There is $c$ such that for every consistent $D$: $W_A(D;\text{$\Sigma_1$-unsound})\ge2^{-c}W_A(D;\text{$\Sigma_1$-sound})$, where $W_A(D;X):=\sum_{e\in X}\mm(e)\ind[B\cup\mathsf W_e\text{ consistent},\ \vdash\psi_D]$. Hence the coin-free posterior probability of $\Sigma_1$-soundness, and a fortiori of truth, is at most $1/(1+2^{-c})$ for every $D$, in particular for every finite part of true arithmetic; and in the Kolmogorov version the shortest compatible unsound theory is at most $c$ bits longer than the shortest compatible sound one.

*Proof.* By s-m-n there is an injective computable $g$ with $\mathsf W_{g(e)}=\mathsf W_e\cup\{\neg\Con(B\cup\mathsf W_e)\}$ (canonical consistency statement of the presentation $e$). If $B\cup\mathsf W_e$ is consistent, (G2) gives $B\cup\mathsf W_e\nvdash\Con(B\cup\mathsf W_e)$, so $B\cup\mathsf W_{g(e)}$ is consistent; its new axiom is a false $\Sigma_1$ sentence; it proves what $\mathsf W_e$ proves. As $\mm(g(e))\ge2^{-c}\mm(e)$, summing over the sound compatible $e$ (whose images are distinct) gives the claim. ∎

For a set $X$ of theories write $M_A(D;X):=\Unif(E_D\cap\{\omega:B\cup A_\omega\in X\})$ and $P_{M_A}(X\mid D):=M_A(D;X)/M_A(D)$. The event "$B\cup A_\omega$ is $\Sigma_1$-unsound" is $\bigcup_{\sigma}O_\sigma$ over false $\Sigma_1$ sentences $\sigma$, an open set, so these quantities are defined.

**Proposition 4.3 (one-tape soundness is controlled by the coding gap) [proved].** Under the hypotheses of Thm 4.2, for every consistent $D$:
$$P_{M_A}(\text{$\Sigma_1$-unsound}\mid D)\ \ge\ 2^{L_A(D)-K_A(D)-c}.$$
*Proof.* Let $e$ witness $K_A(D)$. Its companion $g(e)$ is consistent, unsound, proves $\psi_D$, and $K(g(e))\le K(e)+c$; by (Dom) its tapes have measure $\ge2^{-K_A(D)-c}$; divide by $M_A(D)$. ∎

So one-tape SAI can become confident of soundness only on data where the coding theorem fails badly, which is where randomness dominates (Table 3.10).

### 4.3 One-tape soundness on $\Pi_1$ data: a uniform bound

Scout N1 proved $P_{M_A}(\text{unsound}\mid D)\ge2^{-K(\lceil L_A(D)\rceil)-c}$ for $D$ of $\Pi_1$ type (its D2′; it also follows from Prop 4.3 and Cor 3.3). That bound degrades as the loss grows. The threshold machine removes the degradation.

**Theorem 4.4 (soundness is never learned from $\Pi_1$ data) [proved, given (G2); computed: c3 T3 for the dyadic facts].** Let $B$ be decidable and true with $\PA\subseteq\Cn(B)$. There is $c$ such that for every $D$ of $\Pi_1$ type with $M_A(D)>0$:
$$M_A(D;\text{$\Sigma_1$-unsound})\ \ge\ 2^{-c}M_A(D),\qquad\text{so}\qquad P_{M_A}(\text{$\Sigma_1$-sound}\mid D)\le1-2^{-c}.$$

*Proof.* For a finite string $w$ let $U_w$ be the set of sentences that $G^*$ (Thm 3.2) emits on some tape extending $w$; it is r.e. uniformly in $w$, and $U_w=\{\pi\in\Pi_1^*:\Unif(O_\pi)>0.w\}$ (the thresholds $0.v+2^{-|v|}$, $v\sqsupseteq w$, have infimum $0.w$, not attained). Hence $U_w$ is true if $0.w>\Inc_0$ and is all of $\Pi_1^*$, inconsistent, if $0.w<\Inc_0$ (equality is impossible, $\Inc_0$ being irrational); and $U_{w'}\subseteq U_w$ for $w\sqsubseteq w'$, provably in $\PA$ from the definitions. Let $G^{**}$ emit everything $G^*$ emits and, for every prefix $w$ of the tape, $\chi_w:=\neg\Con(B\cup U_w)$ (scout N1's companion construction, applied to $G^*$).

*Consistency.* Let $r>\Inc_0$ be a non-dyadic tape and $F$ a finite subset of $A^{G^{**}}_r$, with companion sentences $\chi_{w_1},\dots,\chi_{w_j}$; let $w^*$ be the longest $w_i$. If $0.w^*<\Inc_0$, every $U_{w_i}$ is inconsistent, every $\chi_{w_i}$ is a true $\Sigma_1$ sentence, provable from $B$, and the rest of $F$ lies in the true theory $A^{G^*}_r$. If $0.w^*>\Inc_0$, then $B\cup U_{w^*}$ is consistent, r.e. and contains $\PA$, so $B\cup U_{w^*}\cup\{\chi_{w^*}\}$ is consistent by (G2); it contains $F\cap A^{G^*}_r$ (as $A^{G^*}_r=\{\pi:\Unif(O_\pi)>r\}\subseteq U_{w^*}$, since $r\ge0.w^*$); and it proves each $\chi_{w_i}$, $w_i\sqsubseteq w^*$, because $U_{w^*}\subseteq U_{w_i}$ provably, so a proof of $\bot$ from $B\cup U_{w^*}$ is one from $B\cup U_{w_i}$.
*Unsoundness.* $r>\Inc_0$ has a prefix $w$ with $0.w>\Inc_0$ (the truncations increase to $r$); for it $\chi_w$ is a false $\Sigma_1$ sentence.
*Measure.* For $\Inc_0<r<\Unif(O_{\pi_D})$ the theory of $G^{**}$ is consistent, $\Sigma_1$-unsound, contains $\pi_D$, and $B\vdash\sigma_D$. So $\nu_{G^{**}}(D;\text{unsound})\ge M_A(D)$ (as in Thm 3.2), and (Dom) gives $M_A(D;\text{unsound})\ge2^{-K(G^{**})}M_A(D)$. ∎

### 4.4 The one-tape question in general (D-Q1)

**Open (D-Q1).** Is $P_{M_A}(\text{$\Sigma_1$-sound}\mid D)$ bounded away from $1$ uniformly over all data $D$ (with $B$ true, $\supseteq\PA$)?

What is proved:
* data of $\Pi_1$ type: yes, uniformly (Thm 4.4);
* data with a bounded coding gap $K_A-L_A$: yes (Prop 4.3);
* on the $\mathrm{Win}$-lottery stream with $B$ true $\supseteq\PA$ and $\mathcal L=\mathcal L_{\rm ar}\cup\{\mathrm{Win}\}$: yes [proved]: the machine "$G_{\rm lot}$ plus the axiom $\neg\Con(B)$" has the same survival event, its theories are consistent (expand a model of $B+\neg\Con(B)$, which exists by (G2) and has distinct numerals, by the winners) and $\Sigma_1$-unsound;
* on the arithmetic lotteries (Thm 2.9): the random lottery theories are themselves unsound (Cor 2.10(iii) for (b); for (a) they affirm the false $\Sigma_1$ sentences $\theta_{k,J_k}$);
* machines with a tape prefix $w$ whose continuation-union $U_w$ is consistent: yes, by scout N1's companion (used in Thm 4.4) [proved there; re-verified here].

Why the general case is hard: a companion must add a false $\Sigma_1$ sentence that the random theory $A_\omega$ does not refute, chosen from finitely much of the tape. $\neg\Con(A_\omega)$ is not a sentence, and $A_\omega$ may prove $\Con(Z)$ for every r.e. $Z$ read off a finite prefix (a machine can emit, at each stage, the consistency of everything it has emitted so far). Every attempt made here either needed a consistent $U_w$ (fails for coin machines) or a fixed false $\Sigma_1$ sentence that the random theory leaves open (fails for reflective machines).

### 4.5 $\Con(T)$ and Gödel sentences given data from $T$

**Proposition 4.5 (scout N1's D3) [proved, given (G2)].** Let $T$ be a true r.e. theory with $\PA\subseteq\Cn(B\cup T)$, let the data present $T$ ($\Cn(D_\infty^\pm)=\Cn(B\cup T)$), and let $\gamma$ be $\Con(B\cup T)$ (or the Gödel sentence of $B\cup T$, $\PA$-provably equivalent to it [known: Smoryński 1977]).
* (a) $\lim\Bel(\gamma)$, $\lim\Dis(\gamma)$, $\lim\Indep(\gamma)$ exist and all lie in $(0,1)$.
* (b) The $\Bel$ and $\Indep$ shares are truth certificates for $\gamma$ in the sense of Prop 4.1(b).
* (c) Which of "true" and "false" gets more mass is a choice of universal machine: for every universal prefix machine $V$ and every $j$ there are universal $V'$, $V''$ with $\lim\Bel(\gamma)/\lim\Dis(\gamma)\ge2^j-1$ under $V'$ and $\le1/(2^j-1)$ under $V''$.

*Proof.* (a) By `fundamentals` Prop 8.3(a) the limit posterior is the prior restricted to the consistent extensions of $B\cup T$ (incomplete by (G2)). The deterministic theories $T+\gamma$ (true), $T+\neg\gamma$ (consistent by (G2)) and $T$ (decides neither: not $\gamma$ by (G2), not $\neg\gamma$ by truth) have positive weight. (c) Let $V'(0^i1):=$ an index of the deterministic machine for $T+\gamma$ for $i<j$ and $V'(0^jp):=V(p)$; $V'$ is a universal prefix machine. Tapes beginning with some $0^i1$, $i<j$, have measure $1-2^{-j}$ and give a compatible theory proving $\gamma$; all tapes on which $\neg\gamma$ is proved begin with $0^j$. So $\lim\Bel\ge1-2^{-j}$ and $\lim\Dis\le2^{-j}$, normalised by the same $\Unif(E_\infty)\le1$. $V''$ is symmetric with $T+\neg\gamma$. ∎

*Answer to the brief's question.* Given data from a true $T$, the posterior on $\Con(T)$ or $T$'s Gödel sentence keeps positive shares on all three answers forever; no data from $T$ move them in the limit; which of "true" and "false" is favoured is fixed by the choice of universal machine. Machine-independent: all three are positive; any "true" or "independent" mass certifies truth; and "the theory is sound" never exceeds $1/(1+2^{-c})$ coin-free (Thm 4.2), nor $1-2^{-c}$ one-tape on $\Pi_1$ data (Thm 4.4).

### 4.6 Old evidence, and induction in mathematics

**Proposition 4.6 (scout N1's D4) [proved].** If $B\vdash\varphi^b$ for every $(\varphi,b)$ in $D$, then $M_A(D)=M_A(\emptyset)$ and the posterior equals the prior; the same holds for $W_A$ and $K_A$. In particular, with $\Q\subseteq\Cn(B)$ and a $\Delta_0$ formula $P(x)$, the data $\{(P(\underline n),1):n\le N\}$ (true, else they are inconsistent with $B$) leave $\Bel(\forall x\,P(x))$ at its prior value, for every $N$. *Proof.* (Old): $\Cn(D^\pm)=\Cn(\emptyset)$. ∎

*What this says about Hänni's working note on induction in mathematics.* The note asks whether checking $P(n)$ for all small $n$ licenses $\forall n\,P(n)$, or at least $P(n+1)$. SAI with free deduction says no, for a reason unrelated to the note's adversarial worries: the checks are entailed by $\Q$, so they are already "known" and carry no information. This is the problem of old evidence and logical omniscience (Garber 1983; Hacking 1967). Instances of a *fresh* predicate (empirical induction, $B=\emptyset$) do confirm, up to the ω-gap (§5). So the inference the note asks about needs a reasoner for whom computing $P(n)$ is costly: logical induction (Garrabrant et al. 2016) is one; a derivation-charged axiom inducer (AI-paper §6) is another. Whether a derivation-charged SAI posterior then concentrates on provers of $\forall x\,P(x)$ depends on competitors that prove instances cheaply without proving the universal (§5.5); this is not settled here. The note's other idea, committing in advance to a random stopping point, is a frequentist error-control argument; nothing here bears on it, and nothing here contradicts it.

---

## 5. The ω-gap (target T4)

### 5.1 Anatomy

**Proposition 5.1 (scout N1's C1) [proved].** Let $\mathcal L$ have a nonempty set $\mathrm{CT}$ of closed terms, $B$ decidable and consistent, $\varphi(x)$ a formula with one free variable, and suppose $I:=B\cup\{\varphi(t):t\in\mathrm{CT}\}$ is consistent. Let the stream list $(\varphi(t),1)$ for all $t\in\mathrm{CT}$, in any order. Then $\Unif(E_\infty)>0$, the posterior converges in total variation to $P_\infty=$ the prior restricted to the consistent extensions of $I$, and the limit trichotomy of $\forall x\,\varphi$ is:
* (i) $(1,0,0)$ if $I\vdash\forall x\,\varphi$;
* (ii) $(0,1,0)$ if $I\vdash\neg\forall x\,\varphi$ ($I$ is ω-inconsistent at $\varphi$);
* (iii) otherwise all three limits lie in $(0,1)$; $\lim\Dis=P_\infty(\text{the theory is ω-inconsistent at }\varphi)$ and $\lim\Indep=P_\infty(\text{the theory proves every instance and decides }\forall x\,\varphi\text{ neither way})$.

*Proof.* $I$ is an r.e. consistent theory proving the stream, so (Lim) and `fundamentals` Prop 8.3(a) apply. In (i) and (ii) every consistent extension of $I$ proves what $I$ proves. In (iii), $I$, $I+\forall x\varphi$ and $I+\neg\forall x\varphi$ are consistent r.e. theories with positive weight. ∎

So **the Bayesian ω-gap is exactly the ω-incompleteness of the background plus the instances**, made quantitative by prior shares. Two standard cases: $B=\emptyset$ with an atomic diagram (`fundamentals` Prop 8.5; AI-paper Prop B.8); and $B\supseteq\Q$ with $\varphi\in\Delta_0$, where the instances are free (Prop 4.6) and the posterior does not move at all, case (iii) holding iff $B\nvdash\forall x\varphi$.

*Relation to the AI-paper's ω-gap theorem (Thm 3.9).* That theorem concerns the generative (derivation-likelihood) inducer over a countable class with i.i.d. data from a generator $T^*$: the posterior probability of "proves $\forall x\varphi$" tends to the prior share of provers in the generator class $\{T:P_T=P_{T^*}\}$, and in a faithful regime with $\forall x\varphi$ in the data space it tends to the truth value. Prop 5.1 is the proof-requiring, one-tape counterpart, with the two non-proving shares identified (ω-inconsistent and ω-incomplete mass); `fundamentals` Prop 8.5 is its basic instance.

### 5.2 The Gaifman condition

**Proposition 5.2 (when $\Bel$ satisfies the Gaifman condition; sharpens scout L's Observation L1) [proved].** Under the hypotheses of Prop 5.1, enumerate $\mathrm{CT}=\{t_0,t_1,\dots\}$. Then $\lim_n\Bel_0(\bigwedge_{i\le n}\varphi(t_i))$ exists and
$$\lim_n\Bel_0\Big(\bigwedge_{i\le n}\varphi(t_i)\Big)-\Bel_0(\forall x\,\varphi)=\Unif\{\omega:B\cup A_\omega\text{ consistent, proves every }\varphi(t_i),\ \nvdash\forall x\,\varphi\}.$$
This is $0$ iff $I\vdash\forall x\,\varphi$, and otherwise at least $2^{-K(I)-c}$, where $K(I)$ is the complexity of an index of $I$. The same holds for every posterior $\Bel_D$ with $D$ compatible with $I$ (divide by $M_A(D)$).

*Proof.* The events $\{\omega:B\cup A_\omega$ consistent and proves $\varphi(t_0),\dots,\varphi(t_n)\}$ decrease in $n$ to the event of proving every instance; continuity from above gives the limit. A theory proving $\forall x\varphi$ proves every instance, so the difference is the stated measure. If $I\vdash\forall x\varphi$, every consistent theory proving all instances proves $\forall x\varphi$. Otherwise $I$ itself is in the event, with weight $\ge2^{-K(I)-c}$ (Dom). ∎

Scout L's Observation L1 is the case $\mathcal L=\{0,S,R\}$, $\varphi=R(x)$, $B=\emptyset$. *Reading.* The Gaifman condition, $P(\forall x\varphi)=\lim_nP(\bigwedge_{i\le n}\varphi(t_i))$, is a desideratum for credences about *truth* in models where the closed terms name everything; Hutter, Lloyd, Ng and Uther (2013) impose it, and logical inductors do not satisfy it (Garrabrant et al. 2016, after Sawin and Demski 2013). $\Bel$ is a probability of *provability* and satisfies the condition exactly when deduction from the instances settles the universal. So Gaifman-type desiderata do not apply to it, and the paper should not present the failure as a defect.

### 5.3 The universal prior does not close the gap

**Theorem 5.3 (a uniform Gödelian ω-gap; scout N1's C2) [proved, given (G2)].** Let $B$ be decidable and true with $\PA\subseteq\Cn(B)$. For every $k$ there is a $\Delta_0$ formula $\delta_k(x)$ such that $\forall x\,\delta_k$ is true, every instance $\delta_k(\underline n)$ is a true $\Delta_0$ sentence (so $\Q$-provable, and the instance data are free by Prop 4.6), and
$$2^{-k-K(k)-c}\ \le\ \Bel_0(\forall x\,\delta_k)\ <\ 2^{-k}.$$
Hence after any instance data the posterior belief is $\Bel_0(\forall x\delta_k)/(1-\Inc_0)<2^{-k+c'}$, so $\Dis+\Indep>1-2^{-k+c'}$, for every $n$.

*Proof.* Let $\forall x\,\delta_k$ be the canonical consistency statement $\Con(B\cup T_k)$ of the presentation $e_k$ (Thm 3.1), written with one universal quantifier over a code of a pair (derivation of $\bot$, enumeration stage), membership in $B$ certified inside the $\Delta_0$ matrix by a computation witness, and the two quantifiers contracted by $\Delta_0$ pairing. $B\cup T_k$ is true (Thm 3.1(iii)), so $\forall x\,\delta_k$ is true and its instances are true $\Delta_0$ sentences. If $\Bel_0(\forall x\,\delta_k)\ge2^{-k}$, Thm 3.1(ii) puts $\forall x\,\delta_k$ into $T_k$, so $B\cup T_k\vdash\Con(B\cup T_k)$, contradicting (G2) for the consistent r.e. presentation $B\cup T_k\supseteq\PA$. The lower bound is (Dom) for the true one-sentence theory $\{\forall x\,\delta_k\}$, whose complexity is $\le K(e_k)+c$. The posterior after $B$-entailed data is the prior normalised by $M_A(\emptyset)=1-\Inc_0$. ∎

*Correction to scout N1's C2.* N1 wrote "$\Bel_{D_n}(\forall x\varphi_k)=\Bel_0(\forall x\varphi_k)<2^{-k}$". $\Bel_0$ is unnormalised ($\Bel_0(\top)=1-\Inc_0$) while $\Bel_{D_n}$ is normalised, so the posterior is $\Bel_0/(1-\Inc_0)$; the bound becomes $2^{-k+c'}$. Nothing else changes.

*Reading.* For every confidence level there is a true universal statement, all of whose instances are trivially checkable, that the universal inducer believes below that level, uniformly over all random theory machines. This is Gödel's second theorem transported into the prior by the derandomisation of §3.

### 5.4 Versions where the gap closes

* **(a) The ω-rule [proved].** Let $\vdash_\omega$ be closure under first-order deduction and the ω-rule (from $\varphi(\underline n)$ for all $n$ infer $\forall x\varphi$). Then $\Q\vdash_\omega\chi$ for every true $\mathcal L_{\rm ar}$-sentence $\chi$: write $\chi$ in prenex form with a $\Delta_0$ matrix; true $\Delta_0$ sentences are $\Q$-provable; a true $\exists x\psi(x)$ has a true instance $\psi(\underline n)$, provable by induction on the prefix, and $\exists$-introduction applies; a true $\forall x\psi(x)$ has all instances true and provable, and the ω-rule applies. So with $B\supseteq\Q$ every $\vdash_\omega$-consistent random theory has $\mathcal L_{\rm ar}$-content exactly $\Th(\mathbb N)$ (it proves every truth and, being consistent, no falsehood). The gap closes because the inducer is omniscient about arithmetic a priori.
* **(b) Full second-order consequence [proved, given Dedekind's categoricity theorem (known; standard)].** Let hypotheses be second-order sentences, and let compatibility mean "has a full model, and every full model satisfies $\psi_D$". Every full model of second-order Peano arithmetic $\PA^2$ is isomorphic to $\mathbb N$, so $\{\PA^2\}$ is compatible with every finite correctly labelled data set; by the dominance argument (the tapes beginning with a program for $\{\PA^2\}$) the loss on any presentation of $\Th(\mathbb N)$, in any order, is at most $K(\PA^2)+c$, and the limit posterior has $\Bel(\varphi)=\ind[\mathbb N\models\varphi]$ for every $\mathcal L_{\rm ar}$-sentence. This pins the unlearnability of $\Th(\mathbb N)$ (`fundamentals` Prop 8.6) on *effective* consequence, not on the complexity of arithmetical truth (scout N1's N6).
* **(c) The generative variant [known: AI-paper Thm 3.9(c),(d)].** With $\forall x\varphi$ in the data space under a faithful likelihood, or with a selection-aware likelihood for filtered data, the posterior of "proves $\forall x\varphi$" converges to the truth value. These closures change the data model, not the logic.
* **(d) Finite theories with line budgets.** See §5.5.

### 5.5 Line budgets and Kreisel's conjecture (extension C3)

*Setting.* Hypotheses are single sentences $\psi$; a datum $\chi$ is **$\ell$-compatible** with $\psi$ if $B\cup\{\psi\}$ is consistent and proves $\chi$ in a fixed Hilbert calculus by a derivation of at most $\ell$ lines (lines, not symbols). The data are the closed instances $\varphi(S^n0)$, $n\in\mathbb N$.

**Proposition 5.4 (scout N1's C3) [proved; elementary].** For any prior with full support on sentences, the limit posterior gives $\Bel(\forall x\varphi)=1$ iff every $\psi$ that is consistent with $B$ and proves every $\varphi(S^n0)$ within $\ell$ lines also proves $\forall x\varphi$ (a "Kreisel property" of $(B,\varphi,\ell)$). *Proof.* The compatible set decreases to the set of such $\psi$; a $\psi$ in it not proving $\forall x\varphi$ has positive weight; it is nonempty when $B\cup\{\forall x\varphi\}$ is consistent and $\ell$ exceeds the constant length of instantiation. ∎

**Example [proved].** $B=\emptyset$, $\varphi(x):=x=0\vee\exists y\,x=Sy$. Each instance has a derivation of at most five lines, independently of $n$ (an equality axiom $S^n0=S^n0$, the axiom $\chi(t)\to\exists y\chi(y)$ with $t=S^{n-1}0$ and modus ponens, the axiom $\beta\to\alpha\vee\beta$ and modus ponens). But $\forall x\varphi$ is not valid: the structure $\mathbb N\sqcup\{a\}$ with $S(a):=0$ has $a\ne0$ and $a$ outside the range of $S$. So with $B=\emptyset$ even the trivial hypothesis keeps the gap open under a constant line budget. With $B=\Q$ the example closes ($\forall x\varphi$ is the axiom Q3).

**Literature [known; verification levels in §9].** Kreisel's conjecture: if $\PA$ proves $\varphi(S^n0)$ in at most $k$ lines for every $n$, then $\PA\vdash\forall x\varphi$. Parikh (1973) proved the corresponding statement for a version $\PA^*$ of $\PA$ with addition and multiplication as ternary relations (the $k$-line provability relation is decidable there); Baaz and Pudlák (1993) proved further cases ("Kreisel's conjecture for $L\exists_1$"); Hrubeš (2007) exhibited theories very close to $\PA$ for which the conjecture fails ($\PA$ with a minus function, the integers, $\PA$ with an arbitrary extra function symbol, $\PA$ with a predicate for "natural number"; earlier, Yukami 1978 for $\PA$ plus all true multiplication equations); Hrubeš (2009) proved it for $\PA$ axiomatised with the minimality principle; for the usual Hilbert-style $\PA$ it is open (Hrubeš's thesis; Santos and Kahle 2021 study variants). All these results concern *infinite* theories with schemata. Prop 5.4's property concerns finite extensions $B\cup\{\psi\}$, where a $k$-line derivation can use only the finitely many axioms of $\psi$ plus logical axioms; I found no result on it, so the link stays a reformulation. **[open]** whether, for $B=\Q$ and $\Delta_0$ formulas $\varphi$, every finite $\psi$ that proves all instances of $\varphi$ in boundedly many lines proves $\forall x\varphi$.

---

## 6. $\Th(\mathbb N)$: how fast does the loss grow? (target T5)

Setting: $\mathcal L=\mathcal L_{\rm ar}$, $B\subseteq\Th(\mathbb N)$ decidable, $(\varphi_i)_{i\ge1}$ a computable enumeration of all sentences, $D_n$ the first $n$ sentences labelled by truth, $b_{1:n}$ the labels. `fundamentals` Prop 8.6: $K(b_{1:n}\mid n)-c\le L_A(D_n)\le n+K(n)+c$, and the loss is unbounded.

### 6.1 A polynomial lower bound

**Theorem 6.1 (scout F's F26(c)) [proved, given Chaitin's theorem that $\Omega_V$ is Martin-Löf random (known); computed: c5].** Suppose the enumeration lists sentences by length and, within a length, in a fixed order, and that (1) the number of sentences of length $\le L$ is at most $C\gamma^L$, and (2) there are terms $\underline k^{\rm b}$ ("binary numerals") with value $k$ and length $|\underline k^{\rm b}|\le c_1\log_2k+c_2$. Then, with $\delta:=1/(c_1\log_2\gamma)$,
$$L_A(D_n)\ \ge\ C'^{-\delta}\,n^\delta-K(n)-c\qquad\text{for all }n,$$
where $C'$ depends only on the syntax and on the fixed formula $\beta$ below. For the 14-symbol Polish-notation syntax of c5, with $\underline k^{\rm b}$ defined by $\underline1^{\rm b}=S0$, $\underline{2m}^{\rm b}={\cdot}\,\underline m^{\rm b}\,SS0$, $\underline{2m+1}^{\rm b}=S{\cdot}\,\underline m^{\rm b}\,SS0$ (so $c_1=5$, $c_2=2$), one gets rigorously $\delta\ge1/(5\log_214)=0.0525$ (counting all strings), and $\delta\approx0.082$ from the numerically estimated growth rate $\gamma\approx5.38$ of well-formed formulas (computed, not proved).

*Proof.* Let $\Omega_s\uparrow\Omega_V$ be the computable approximations. Since $\Omega_V$ is irrational, its $k$-th binary digit is the eventual value of the $k$-th digit of $\Omega_s$. Let $\beta'(y)$ be a formula with $\mathbb N\models\beta'(\underline k)$ iff that digit is $1$: "$\exists s\,\forall s'\ge s$: the $k$-th digit of $\Omega_{s'}$ is $1$", with the digit predicate expressed by a $\Delta_0$ formula about a computation witness. Put $\beta(x):=\exists y\,(y=x\wedge\beta'(y))$, so that $x$ occurs once, and $\beta_k:=\beta(\underline k^{\rm b})$; then $|\beta_k|\le|\beta|+c_1\log_2k+c_2$, and the position of $\beta_k$ in the enumeration is at most $C\gamma^{|\beta|+c_2}\gamma^{c_1\log_2k}=C'k^{1/\delta}$. Let $m:=\lfloor(n/C')^\delta\rfloor$. The first $n$ sentences contain $\beta_1,\dots,\beta_m$, at positions computable from $k$, and their labels are the digits $\Omega_{1:m}$. So $\Omega_{1:m}$ is computable from $n$ and $b_{1:n}$: $K(\Omega_{1:m})\le K(b_{1:n}\mid n)+K(n)+c$. By Chaitin's theorem, $K(\Omega_{1:m})\ge m-c$. Combine with `fundamentals` Prop 8.6. ∎

*Remarks.* (i) Only the numeral length and the growth of the syntax enter $\delta$; the (large) size of $\beta$ enters only the constant. (ii) With unary numerals ($c_1=\infty$) the argument gives only a logarithmic bound. (iii) The bound is weak in absolute terms: for $n=10^6$, $n^{0.0525}\approx2$. It is an asymptotic statement about the shape of the growth, not a usable estimate.

**Corollary 6.2 (quantitative incompleteness along the enumeration) [proved, given Theorem 6.1].** Let $T$ be r.e. with $B\cup T\subseteq\Th(\mathbb N)$, and $u_n(T)$ the number of $i\le n$ such that $B\cup T$ proves neither $\varphi_i$ nor $\neg\varphi_i$. Then $u_n(T)\ge C'^{-\delta}n^\delta/(2\log n)$ for all large $n$.

*Proof.* $b_{1:n}$ is computable from an index of $T$, $n$, the set of undecided positions and their labels (a true theory decides correctly): $K(b_{1:n}\mid n)\le K(e_T)+K(u_n\mid n)+\log\binom n{u_n}+u_n+c\le K(e_T)+u_n(\log n+3)+2\log n+c$, using $\log\binom nu\le u\log(en/u)$. Compare with Theorem 6.1. ∎

*Reading.* Every true r.e. theory leaves undecided at least about $n^\delta$ of the first $n$ sentences. This is a Chaitin-type statement in the natural enumeration; Calude and Jürgensen (2005) prove, for a different measure ($\delta$-complexity of Gödel codes), that the probability that a true sentence of length $n$ is provable tends to $0$; their measure is not the length-lexicographic one, so their theorem does not transfer here.

### 6.2 An upper bound by a reduction (scout N1's N7)

**Proposition 6.3 [proved].** For every r.e. $T$ with $B\cup T\subseteq\Th(\mathbb N)$ and every $n$,
$$L_A(D_n)\le K(e_T)+\log\binom n{u_n(T)}+u_n(T)+2\log n+O(\log\log n).$$
Hence if some such $T$ has $u_n(T)/n\to0$, then $L_A(D_n)=o(n)$.

*Proof.* $B\cup T$ plus the correctly labelled undecided sentences among the first $n$ is a consistent (true) r.e. theory proving $D_n$, with an index computable from $e_T$, $n$, $u_n$, the positions (given $n,u_n$: $\log\binom n{u_n}$ bits) and the $u_n$ labels; then (Chain). If $u_n/n\to0$, $\log\binom n{u_n}\le nH(u_n/n)=o(n)$. ∎

**Open (scout F's Q3).** Is $L_A(D_n)=o(n)$? By Prop 6.3 it suffices that some true r.e. theory decides a set of sentences of asymptotic density one in the enumeration, i.e. that the truth of arithmetic is *generically decidable* in the sense of generic-case complexity (Myasnikov and Rybalov 2008 for the framework). Known nearby facts: the halting problem is decidable on a set of asymptotic probability one for one model of Turing machines (Hamkins and Miasnikov 2006), which shows that such questions depend on the representation; in the opposite direction Calude and Jürgensen's theorem (another measure) and Cor 6.2 (only a polynomial lower bound) say nothing decisive. The answer depends on the syntax conventions, and I do not know it. *[Proof sketch, not used elsewhere]* A weaker improvement is within reach: if a decidable set of sentences of positive lower density $\rho$ in the enumeration is decided by $B$ (for instance the sentences of the form $\wedge\neg(0=0)\,\psi$, which $\Q$ refutes), then $L_A(D_n)\le(1-\rho+o(1))n+K(n)+c$, because the labels of that set are computable from $n$. The missing step is a proof that the sentence counts of the syntax satisfy $\#\{\text{sentences of length }L-5\}\ge\rho'\,\#\{\text{sentences of length }L\}$ for large $L$; the formula counts of c5 behave so numerically (ratio $\approx5.38$ per symbol), but sentences (closed formulas) were not counted.

---

## 7. Relation to the literature (target T6)

* **Probabilities on sentences.** Gaifman (1964) and Scott and Krauss (1966) assign coherent probabilities to sentences (measures on models). Hutter, Lloyd, Ng and Uther (2013) extend given probabilities of some sentences to all sentences of a higher-order logic under desiderata that include the Gaifman condition and a Cournot condition. Demski (2012) defines a prior over first-order theories by drawing length-weighted random sentences and keeping each one consistent with those kept; the resulting random theory is complete. Garrabrant et al. (2016) construct computable logical inductors whose limit is a coherent probability over completions of the given axioms. **Against SAI:** all of these are probabilities of *truth* (or of membership in a random completion). SAI's $\Bel$ is a probability of *provability* by a random r.e.-in-the-tape theory, so it keeps an independent share and violates the Gaifman condition exactly when the instances do not deductively settle the universal (Prop 5.2). The lottery theorems (Thm 2.2, 2.9) concern a phenomenon these frameworks cannot express: a random *axiom system* that succeeds where every r.e. axiom system fails. Sawin and Demski (2013) show that computable distributions which come to believe true $\Pi_1$ sentences must give arbitrarily low limiting probability to some short true $\Pi_2$ sentences. §3 and Cor 2.10 show a parallel divide for the ideal (non-computable) SAI posterior: on $\Pi_1$ data it is derandomisable and its beliefs certify truth; one level up (Boolean combinations of $\Sigma_1$) it can concentrate on false theories. This is a parallel, not a consequence of their result.
* **Random axioms.** Bienvenu, Romashchenko, Shen, Taveneaux and Vermeeren (2014), with Shen (2011) and the discussion around Lipton's 2011 proposal, study adding *randomly chosen true* complexity axioms to $\PA$; Levin (2013) bounds the probability that a randomised algorithm completes $\PA$. §3.4 states what is new against them: arbitrary random theory machines and the universal mixture; derandomisation into one true theory or one random threshold theory; the coding theorem as a statement about an inductive inference rule.
* **Probabilistic enumeration.** de Leeuw, Moore, Shannon and Shapiro (1956) show that what a probabilistic machine produces with positive probability can be produced deterministically; the majority vote at a density point (Prop 2.3; `fundamentals` Lemma 8.0) is that argument. The lottery is exactly where it breaks for random theories: majority vote over *consistency* constraints of unbounded arity can be inconsistent.
* **The lottery paradox.** Kyburg (1961): for a fair lottery each "ticket $j$ loses" is highly probable, "some ticket wins" is certain, and closing highly probable beliefs under conjunction yields inconsistency. Theorem 2.2 turns the paradox into a separation: the majority-vote theory refutes every ticket and is inconsistent (Prop 2.3, Instances), and this is why no deterministic hypothesis can replace the random ones.
* **Chaitin and its critics.** Chaitin (1974): a formal system cannot prove "$K(x)>m$" for $m$ much larger than its own complexity. Raatikainen (1998): the *least* such bound for a given theory is determined by the coding of machines rather than by the theory's complexity; Chaitin's bound is an upper bound. Cor 3.6 uses only the upper bound, in the form "a consistent extension of $\Q$ proving $\mathrm{Kgt}_m(x)$ has complexity $>m-K(m)-c$", and makes no claim about least constants.
* **Flexible formulas and independent sequences.** Mostowski (1961), Kripke (1962), Woodin (2011), Blanck and Enayat (2017), Hamkins (2018). Lemma 2.8 is the routine weak form needed here, with prescribed truth values.
* **Kreisel's conjecture.** Parikh (1973), Baaz and Pudlák (1993), Hrubeš (2007, 2009), Santos and Kahle (2021); §5.5.
* **Generic-case decidability.** Hamkins and Miasnikov (2006), Myasnikov and Rybalov (2008); Calude and Jürgensen (2005) for the probability of provability; §6.2.
* **Old evidence.** Hacking (1967), Garber (1983); Prop 4.6.
* **Learning in the limit.** Gold (1967), text versus informant, is the learning-theoretic shadow of the two-valued/three-valued distinction (`fundamentals` Prop 8.4). Nothing in this thread changes that picture; the lottery adds that, on text, the hypotheses that succeed need not be r.e. at all.

---

## 8. Notation requests and interfaces with other threads

**Notation requests.**
1. The lottery's binary relation symbol: $\mathrm{Win}$ (scout N1's $W$ clashes with $W_A$; `sfi` made the same request). Please add to NOTATION §6.2.
2. New global symbols used by other threads or likely to be cited: $G^*$ (threshold machine, Thm 3.2) and $G^{**}$ (its unsound companion, Thm 4.4); "data of $\Pi_1$ type" (§3.1); $\theta_{k,j}$ and $\mathrm{Lot}^{\rm ar}_k$ (arithmetic tickets, Thm 2.9). Local only: $\Phi_0,\Phi_1,\Phi_2$, $h_G(n)$, $\mathcal A,\mathcal N$, $U_w$, $\chi_w$, $\beta_m$, $\beta_k$, $\underline k^{\rm b}$, $u_n(T)$.
3. NOTATION §3.1 says the background is decidable; scout N1 wrote "r.e.". Nothing here depends on the difference (Craig).

**Interfaces.**
* `fundamentals`: scout F's Q1 is answered (Cor 2.5): no in general, also inside true arithmetic with true data (Thm 2.9(b)); yes for bounded arity, $\Pi_1$ type, co-r.e. lottery-type streams, and positive-measure true random theories. F26(c) is Theorem 6.1. `fundamentals` Prop 8.7 should cite Levin (2013) as a quantitative relative.
* `sfi` Cor 4.2 cites scout N1's E1 and E2(b): re-verified here as Thm 2.2 and Prop 2.3(b), unchanged in substance.
* `terms` Rem 6.6 cites E1(a),(b): Thm 2.2(a),(b) and (c) (the finite-theory clause), unchanged.
* `philosophy` items 7 and 8 cite T1 and T3. Two additions for that thread to consider. (i) Cor 2.10: a formal case in which bounded predictive loss on *true* data coexists with the inducer believing, in the limit and with probability one, *false* theories (and the random lottery theories among them are $\Sigma_1$-unsound). As a possibility proof it bears on success-to-truth inferences, in an idealised setting with adversarially chosen data; it is not evidence about actual science. (ii) Thm 4.4 extends "soundness is never learned" from the coin-free to the one-tape inducer on $\Pi_1$ data, with a uniform constant.
* **Possible error in the author's view.** None raised. Nothing in this thread bears on a philosophical claim of Hänni's in a way that makes a disagreement probable; the working note on induction in mathematics asks a question, and §4.6 answers it for free deduction without contradicting the note.

---

## 9. References and their verification status

Fetching of full texts was blocked in this round. "[B]" = bibliographic data verified by web search in this round; "[A]" = abstract or search-snippet content seen in this round; "[R]" = content recalled, not seen; "[T]" = standard textbook fact.

| reference | used for | level |
|---|---|---|
| L. Bienvenu, A. Romashchenko, A. Shen, A. Taveneaux, S. Vermeeren, "The axiomatic power of Kolmogorov complexity", *Ann. Pure Appl. Logic* 165(9):1380–1402, 2014; arXiv:1301.3392 | §3.4 novelty | [B, A]: random axioms "$C(x)\ge n-c$", proof strategies with initial capital, soundness corollary, no new interesting theorems, proof shortening unless NP=PSPACE, all true complexity statements give all true $\Pi_1$, one per $n$ suffices; theorem numbers not checked |
| A. Shen, "Are random axioms useful?", arXiv:1109.5526, 2011 | §3.4 | [B, A]: Prop 1 (safe), Chaitin, Prop 2 ("cannot prove anything interesting"); exact statements not read |
| L. A. Levin, "Forbidden information", *J. ACM* 60(2), Art. 9, 2013; arXiv:cs/0203029 | §3.4, interface with `fundamentals` | [B, A]: randomised completion of $\PA$ on size-$n$ formulas has probability $\le2^{-n}$ (up to factors); not used in a proof |
| G. J. Chaitin, "Information-theoretic limitations of formal systems", *J. ACM* 21(3):403–424, 1974 | Cor 3.6 (deterministic step reproved) | [B] |
| G. J. Chaitin, "A theory of program size formally identical to information theory", *J. ACM* 22(3):329–340, 1975 | Thm 6.1 ($\Omega_V$ random) | as in `fundamentals` §14 (known; theorem number unverified) |
| P. Raatikainen, "On interpreting Chaitin's incompleteness theorem", *J. Philos. Logic* 27(6):569–586, 1998 | Cor 3.6 reading, §7 | [B, A] |
| S. Kripke, "'Flexible' predicates of formal number theory", *Proc. AMS* 13(4):647–650, 1962 | Lemma 2.8 (context) | [B, A] |
| A. Mostowski, "A generalization of the incompleteness theorem", *Fund. Math.* 49:205–232, 1961 | Lemma 2.8 (context) | [B, A]: independent sequences of sentences over consistent r.e. theories |
| W. H. Woodin, "A potential subtlety concerning the distinction between determinism and nondeterminism", in *Infinity: New Research Frontiers*, Cambridge UP, 2011 | Lemma 2.8 (context) | [R] for the venue (search found citations naming [Woo11] but not the volume details); not used in a proof |
| R. Blanck, A. Enayat, "Marginalia on a theorem of Woodin", *J. Symb. Logic* 82(1):359–374, 2017 | Lemma 2.8 (context) | [B] |
| J. D. Hamkins, "The modal logic of arithmetic potentialism and the universal algorithm", arXiv:1801.04599 | Lemma 2.8 (context) | [B, A] |
| H. Gaifman, "Concerning measures in first order calculi", *Israel J. Math.* 2(1):1–18, 1964 | §5.2, §7 | [B] |
| D. Scott, P. Krauss, "Assigning probabilities to logical formulas", in *Aspects of Inductive Logic* (Hintikka, Suppes, eds.), North-Holland, 1966, pp. 219–264 | §7 | [B] (page range 219–264 per Crossref; one source says 219–259) |
| M. Hutter, J. W. Lloyd, K. S. Ng, W. T. B. Uther, "Probabilities on sentences in an expressive logic", *J. Applied Logic* 11(4):386–420, 2013 | §5.2, §7 | [B, A] |
| A. Demski, "Logical prior probability", *AGI 2012*, LNCS 7716, pp. 50–59 | §7 | [B, A] (construction via secondary descriptions) |
| W. Sawin, A. Demski, "Computable probability distributions which converge on believing true $\Pi_1$ sentences will disbelieve true $\Pi_2$ sentences", MIRI technical report, 2013 (released 2014) | §5.2, §7 | [B, A] |
| S. Garrabrant, T. Benson-Tilsen, A. Critch, N. Soares, J. Taylor, "Logical induction", arXiv:1609.03543, 2016 | §4.6, §5.2, §7 | as verified by scout L [B, A]; not re-checked |
| K. de Leeuw, E. F. Moore, C. E. Shannon, N. Shapiro, "Computability by probabilistic machines", in *Automata Studies*, Ann. Math. Studies 34, Princeton UP, 1956, pp. 183–212 | §7 | [B, A] (the positive-probability statement via secondary sources) |
| H. E. Kyburg, *Probability and the Logic of Rational Belief*, Wesleyan UP, 1961 | §7 | [B, A] |
| R. Parikh, "Some results on the length of proofs", *Trans. AMS* 177:29–36, 1973 | §5.5 | [B, A]: $\PA^*$ with ternary $+$, $\cdot$; $k$-line provability decidable |
| M. Baaz, P. Pudlák, "Kreisel's conjecture for $L\exists_1$", in *Arithmetic, Proof Theory, and Computational Complexity* (Clote, Krajíček, eds.), Oxford UP, 1993, pp. 30–60 | §5.5 | [B]; content [R] |
| P. Hrubeš, "Theories very close to PA where Kreisel's Conjecture is false", *J. Symb. Logic* 72(1):123–137, 2007 | §5.5 | [B, A] |
| P. Hrubeš, "Kreisel's Conjecture with minimality principle", *J. Symb. Logic* 74(3):976–988, 2009 | §5.5 | [B, A] |
| P. G. Santos, R. Kahle, "Variants of Kreisel's conjecture on a new notion of provability", *Bull. Symb. Logic* 27(4), 2021 | §5.5 | [B, A] |
| J. D. Hamkins, A. Miasnikov, "The halting problem is decidable on a set of asymptotic probability one", *Notre Dame J. Formal Logic* 47(4):515–524, 2006 | §6.2 | [B, A] |
| A. Myasnikov, A. Rybalov, "Generic complexity of undecidable problems", *J. Symb. Logic*, 2008 | §6.2 | [A] via a survey snippet; volume and pages not checked |
| C. S. Calude, H. Jürgensen, "Is complexity a source of incompleteness?", *Adv. Appl. Math.* 35:1–15, 2005; arXiv:math/0408144 | §6.1, §6.2 | [B, A] |
| D. Garber, "Old evidence and logical omniscience in Bayesian confirmation theory", *Minnesota Studies in the Philosophy of Science* 10:99–131, 1983; I. Hacking, "Slightly more realistic personal probability", *Phil. Sci.* 34(4):311–325, 1967 | §4.6 | as verified by scout L [B]; not re-checked |
| E. M. Gold, "Language identification in the limit", *Information and Control* 10(5):447–474, 1967 | §7 | as in the AI-paper bibliography |
| C. Smoryński, "The incompleteness theorems", in *Handbook of Mathematical Logic* (J. Barwise, ed.), North-Holland, 1977, pp. 821–865 | (Σ₁C), (G2), (Diag), Gödel sentence ≡ Con | [B]; content [T] |
| Dedekind's categoricity of second-order Peano arithmetic | §5.4(b) | [T] |
| AI-paper (Thm 3.9, Prop B.8, §6); `fundamentals` (Defs 1.1–1.10, Lemma 1.3, Thm 3.2, Thm 4.1, Prop 6.1, Thm 6.2, Lemma 8.0, Props 8.1–8.7, 11.5); `sfi` Cor 4.2; `terms` Rem 6.6; scouts F, L, N1 | throughout | read in this repository in this round |

---

## 10. Verification log

**Sources read in this round.** The project brief `../../00-brief.md` (in full, including the epistemic policy); this thread's brief; `../../NOTATION-draft.md`; `../../select.md`; scout N1's record `../../scouts/novel-logic/notes.md` in full (§5 read for context only; it belongs to `terms`) with its `checks/c1_lottery.*`, `c3_threshold.*`; scout F's record §2–§3.7 and §7–§9 (F1–F4, F10–F14, F22–F27, Q1–Q3); scout L's §3.2, §3.7 and Observations L1–L3; the AI-paper's `sections/universal.tex` §"The Bayesian ω-gap" (Thm 3.9, number read from `main.aux`); `../axiom-induction/research/tracks/pa/notes-final.md` §4 (Th(ℕ) data); the prior note `../../prior/induction-in-mathematics.md`; the development-round records of `fundamentals` (§1–§3, §8, §11–§15), `sfi` (Thm 2.1, Thm 3.1, Cor 4.2), `terms` (Rem 6.6) and `philosophy` (the items citing this thread), for the interfaces.

**Literature.** WebSearch only (page fetching was blocked: `curl` through the proxy returned 403 for arxiv.org, ar5iv, HAL, export.arxiv.org). Every reference in §9 was searched in this round except the three marked "as verified by scout L" and the AI-paper's bibliography items. The content of Bienvenu et al. (2014) and Shen (2011) was seen only through the abstract and search snippets; §3.4 states only what those show, and no proof here depends on them.

**Computations** (scripts in `checks/`, outputs next to them; seeds 20261016; each script run twice, the second time on scratch copies, outputs byte-identical; total running time under 10 s).
* `c0_rerun_scout.py` → `c0_rerun_scout.out`: scout N1's `c1_lottery.py` and `c3_threshold.py`, copied to scratch and re-run, reproduce the scout's saved outputs byte for byte (4143 and 379 bytes).
* `c1_lottery.py` → `c1_lottery.out` (independent of the scout's code): A1, 1876 consistent theories in random lists, every one fails at its own lottery; exact survival $1/2,3/8,21/64,315/1024,9765/32768$ for $K=1..5$, equal to the product formula; product $\approx0.288788$. A2, batch lottery: survival $1/2$, $7/16$, $87/256$ for $K=1,2,3$, each $\ge$ the bound $\prod(1-2^{-(k+1)})$, and every $e<2^{K-1}$ killed. A3, true lottery: $0$ violations of "$j^*\ne t$" and of "a theory that refutes no true ticket refutes no ticket" in 500×8 cases; $P(\text{all true winners}\mid\text{survival})=\prod1/N_k$ exactly for $K\le4$. C, Prop 2.7: in 2000 random co-r.e. removal processes the first-consistent-stage adversary is consistent and proves the final data.
* `c2_majority.py` → `c2_majority.out`: Prop 2.3(a) at $\varepsilon=1/(r+1)$: $0$ violations for $r=1,2,3,4,6$ (582, 557, 519, 441 instances, and 600 for $r=1$); controls at $\varepsilon=1/2$, $2/3$: up to 9 and 113 violations, so the threshold matters. Part B prints, for thresholds down to $1-10^{-6}$, the lottery whose majority set is inconsistent. Part C, Prop 2.4: $0$ violations in 1132 instances at threshold $1/2$; 564 violations in 1407 at threshold $1/3$.
* `c3_threshold.py` → `c3_threshold.out`: Thm 3.1's threshold arithmetic ($0$ violations in 62370 checks), Thm 3.2's $\nu_{G^*}(D)\ge M(D)$ and truth of $A_r$ ($0$ in 4000 data sets), the companion's prefix facts for Thm 4.4 ($0$ violations in 82000; 488 boundary cases $0.w=\Inc$, which arise only because the finite model's $\Inc$ is dyadic; $\Inc_0$ is irrational), Remark 3.4's dyadic count ($0$ in 14000).
* `c4_trichotomy.py` → `c4_trichotomy.out`: Prop 4.1 in a finite world model with ($\Sigma_1$C) imposed: $0$ violations of (a), (b); (c) and (d) hold in all 1025 and 1053 applicable instances; the one-sided error pattern holds (positive belief on false $\Sigma_1$ and positive disbelief on true $\Pi_1$ occur, the reverse never).
* `c5_syntax.py` → `c5_syntax.out`: binary numerals evaluate correctly and have length $\le5\lfloor\log_2k\rfloor+2$ for $k\le20000$; formula counts by dynamic programming up to length 400, growth ratio $5.36$ at $L=400$, $\approx5.38$ after the $L^{-3/2}$ correction; $\delta_{\rm str}=0.05253$, $\delta_{\rm wff}\approx0.082$.

What the computations do and do not check: they check the finite combinatorics and the dyadic arithmetic of the proofs (off-by-one errors in thresholds, the diagonal bookkeeping, the survival products, the majority thresholds). They cannot check statements about all r.e. theories, consistency of arithmetic theories, or Gödel's theorem; those rest on the proofs.

**Proof checks done by hand** (each proof was re-derived line by line; the points that needed care):
* Thm 2.2: the existence of $j^*_e$ uses the second conjunct of $\mathrm{Lot}_e$ and the equality axioms; consistency of $G_{\rm lot}$ needs distinct numerals; (c)'s finite-theory clause needs $B\cup X_\psi$ consistent, where $X_\psi$ is the $\mathcal L$-content of $\psi$.
* Prop 2.3(a): $1-j\varepsilon\ge\varepsilon$ needs $\varepsilon\le1/(r+1)$.
* Prop 2.6: the injectivity of $u\mapsto e(G,u)$ is needed to sum masses; $\mathrm{Good}_m$ requires a consistent continuation in $[u]$, not only a proof.
* Lemma 2.8: the contradiction uses the *truth* of $B$ ($B$ proves the negation of a true sentence); the "first theorem of the form" clause makes the $\Sigma_1$ part single-valued.
* Thm 2.9(b): $j^*_e$ exists because a refuted ticket is never the unique unrefuted one; the data are true because $j^*_e\ne t_e$ by construction.
* Cor 2.10(iii): three cases ($J>t_k$; $J<t_k$; no ticket refuted), each yielding a false $\Sigma_1$ theorem; probability of picking every true winner given survival is $\prod1/N_k$ (checked in c1 A3).
* Thm 3.2: $A^{G^*}_r$ is computed for non-dyadic $r$ (a null set is excluded); for $r<\Inc_0$ the theory contains $\neg(0=0)\in\Pi_1^*$.
* Thm 4.4: the companion sentences' consistency argument takes $w^*$ the *longest* prefix (so that $U_{w^*}$ is the *smallest* set and its inconsistency implies the others'); the needed inclusion $U_{w'}\subseteq U_w$ is provable in $\PA$ from the definitions; unsoundness needs a prefix with $0.w>\Inc_0$, which exists because truncations increase to $r$.
* Cor 3.6: strings coded by length-lexicographic rank so that "$|p|\le m$" is "$p\le\underline{P_m}$"; $h_m\le2^m$ by Kraft, so $m+1$ bits.
* Prop 4.5(c): the modified machine $V'$ is prefix-free and universal; the ratio uses the same normaliser.
* Thm 5.3: corrected normalisation ($\Bel_0$ vs $\Bel_{D}$), see the note after the proof.
* Thm 6.1: $\beta(x)$ is chosen with a single occurrence of $x$, so the numeral enters the length once; $\Omega_V$'s irrationality makes its digits limits of the approximations' digits.

**Claims changed, strengthened or withdrawn during this round.**
1. *Scout N1's E-Q1 (a lottery inside arithmetic with a true background):* open there; **answered** here (Thm 2.9), in two forms: with false $\Sigma_1$ data (a), and with *true* data that are Boolean combinations of $\Sigma_1$ sentences (b).
2. *Scout N1's A-Q1 (do true $\Sigma_2/\Pi_2$ data admit a coding theorem?):* open there; **answered negatively** (Prop 3.9: two true data; Cor 2.10: a stream).
3. *Scout N1's A5 (one false $\Sigma_1$ datum breaks the coding theorem):* a proof sketch given a recalled flexible-formula lemma there; **proved** here (Prop 3.8), with the lemma proved (Lemma 2.8).
4. *Scout N1's D2′ (one-tape soundness on $\Pi_1$ data, bound $2^{-K(\lceil L_A\rceil)}$):* **strengthened** to a uniform constant (Thm 4.4) via the threshold machine $G^*$ (Thm 3.2, new).
5. *Scout N1's remark "whether a co-r.e. stream can serve is open":* **settled negatively for lottery-type sentence classes** (Prop 2.7); open in general.
6. *Scout N1's E-Q2 (rate):* the divergence of the coin-free loss on the lottery streams is at most $\Kpad(n)+c$ (Cor 2.6′), slower than any computable function; the general horizon bound is Prop 2.6; the remaining question is stated.
7. *Scout N1's C2:* the posterior bound was stated with the unnormalised $\Bel_0$; **corrected** to $2^{-k+c'}$ (Thm 5.3).
8. *Scout L's Observation L1:* **sharpened** to an exact characterisation (Prop 5.2).
9. *Scout F's F26(c):* a sketch there; **proved** with an explicit $\delta$ (Thm 6.1), plus a new corollary (Cor 6.2).
10. *A first draft of Cor 2.10 and of the interface note for `philosophy` said the limit posterior lives on $\Sigma_1$-unsound theories.* **Withdrawn**: only falsity is proved for the whole limit posterior (Prop 2.4); unsoundness is proved for the lottery machine's share. Whether $P_\infty(\text{$\Sigma_1$-sound})=0$ is left open (§2.7).
11. *In c3, a first version of check T3 asserted "$U_w$ consistent iff $0.w>\Inc$"* and failed on 488 cases where the finite model's dyadic $\Inc$ equals $0.w$. The statement for SAI is unaffected ($\Inc_0$ is irrational); the check now tests "$\ge$" and counts the boundary cases.

**Not done.**
* No referee in this round.
* Full texts of Bienvenu et al. (2014), Shen (2011), Levin (2013), Kripke (1962), Mostowski (1961), Parikh (1973), Baaz–Pudlák (1993), Hrubeš (2007, 2009) were not read (fetching blocked); the record uses only what the abstracts and snippets show, and no proof depends on them.
* Open: D-Q1 in general (§4.4); E-Q2's lower-rate question (§2.5); co-r.e. Q1 in general (§2.6); $P_\infty(\text{$\Sigma_1$-sound})$ on the true lottery (§2.7); $K_A\le L_A+O(1)$ on $\Pi_1$ data (Rem 3.4); Q2 for $[T]$ (Prop 3.7); the finite-theory Kreisel property over $\Q$ (§5.5); scout F's Q3, $L_A=o(n)$ on $\Th(\mathbb N)$ (§6.2).
* Nothing was checked in a proof assistant.
* No git command that changes repository state was run.
