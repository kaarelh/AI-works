# Stakes derivations A and B: referee report on the model and the claims made for it

Written by an AI referee; not reviewed by a human. Files reviewed: `research/stakes-derivation-A.md` (claims A1 to A28, PLAIN ANSWER) and `research/stakes-derivation-B.md` (claims B1 to B32, Short answer, VERDICT). Neither file has a section called OVERALL VIEW. Definitions were taken from `paper/sec2-toy.tex`, `paper/sec3-floor.tex` and `paper/sec4-limits.tex`.

**Lens.** For each claim and each closing sentence I asked five questions.

* Does the formal statement say what the plain sentence says?
* Which assumptions are hidden?
* Does the abstract model match the toy of `sec2-toy.tex`?
* Is the conclusion stronger than what was proved?
* Is a step about what agents would choose presented as a theorem?

**Verdict words.** *correct*: I re-derived it and the statement says what it claims. *correct with fix*: the mathematics holds, but the statement or its reading needs the stated change. *overclaim*: the sentence says more than was proved. *wrong*: the statement is false as written. *unclear*: not proved, or I could not close a gap.

**How the mathematics was checked.** I re-derived every proof by hand. The optimisation claims were also checked numerically in a scratch directory outside the repository: A3, A5, A9, A12 and A13 on 200 random instances against random and local competitors; A6 on 2000 instances; A7 against a direct solution of the budget equation for four values of $\gamma$; A8 and B24 by fine discretisation; A14 against brute force on 3000 instances; A15, B22 against random competitors; A16(4) on 2000 instances; A25 and A26 on 400 instances; B21(e) by direct solution. No discrepancy was found in any formula. The numerical checks prove nothing by themselves. The findings below are about what the formulas are formulas *of*.

## Main findings

1. **The mathematics inside the abstract allocation model is right in both files.** I found no error in A2 to A17, A25, A26, or B20 to B24.
2. **The model's assumption (M2), a background that does not react, is not a theorem of the toy in any of the cases where A says it holds.**
   * A §0 says that for one fixed program whose inhabitants choose its output, "(M2) holds". It does not. The wrapper of B11 around that program is in the background and carries $2^{-c}$ of whatever mass the program sends to a context. So $O(x)=O^0(x)+\tau(x)\mu(x)$ with $\tau\ge2^{-c}$.
   * For a seeker whose search is written down, $\tau\ge2^{a-h}\bar\varphi$ (the honest twin). This includes a seeker that spreads its mass in proportion to the background: its twin is part of that background. Such a seeker places on a class at most $2^{h-a}$ times the background of the class, so the share $c/(1+c)$ of A12(2) is available to it only for $c\le2^{h-a}$.
   * Derivation B has this right (B11, B22, B26). Derivation A's closing sentences 1 and 10 do not carry it.
3. **A1(3) gives additivity for cut points along one sequence, but (M3) fails there.** The attacker's mass aimed at a later cut point prints the true block at every earlier one and so counts as background there. The cost of the majority at $n$ cut points is $\sum_i2^{i-1}O_i$, not $\sum_iO_i$. Sections 1 to 5 of A therefore apply to pairwise incomparable contexts only.
4. **A's closing sentence 10 is an overclaim.** "Yes exactly where the weight aimed exceeds the background" merges three statements of different standing: a necessary condition (a theorem of the toy), a sufficient condition on a particular allocation (a theorem of the abstract model), and what a stake-maximiser does (a different and larger threshold, A13, B21(e)). "The toy proves this equivalence" is not accurate.
5. **Three different meanings of "most" are in play and they are not interchangeable.** Majority of the samples at every use of a class; majority of the samples at most uses of a class (A12(4)); most uses of the class end in a takeover ($\mathbb E_{P_W}[w]>\frac12$, B17(a')). The second does not imply the third. Neither file states the exact condition for the third; it is given under A12 below.
6. **Several of B's sentences are stronger than their theorems.** "A stake that the context does not show cannot be aimed at" (it can be aimed at; it cannot be separated from what shares its context). "There is no narrow channel" under closure (none for a seeker that describes the class; a short program that does not describe it is not covered). "Weighted by prior mass they never have more uses than their weight" (the bound is by background mass, not by user mass). "No allocation is optimal" in B25(a) (allocations of infinite value exist).
7. **No error of the earlier kinds was found in the direction of any ratio.** I checked every exponent in A11, A20 to A24, B6, B8, B9, B12, B14 to B17, B22 and B28.

---

## Part 1. Derivation A, claim by claim

### A §0 (the abstract model and "what the model is a model of"): wrong in one sentence

The data $C,s,O$, the constraint (M1), and the share $w=\mu/(\mu+O)$ are a fair abstraction of the sampling predictor $\pi_m(y\mid x)=\xi(xy)/Z_m(x)$ of `sec2-toy.tex`, under three conditions that §0 does not all state.

* **No waste.** $Z_m(x)=\mu(x)+O(x)$ needs every attacker program that prints $x$ and $m$ more bits to print an attack block there. A24(4) states this; §0 does not. With waste, $w<\mu/(\mu+O)$.
* **(M3) is about supply.** $w$ is the probability that the sample was supplied by an attacker program. It equals the probability that an attack block is returned only if the background puts no mass on attack blocks. §0 says this.
* **(M2).** The sentence "the set of the attacker's programs is then fixed, the background is its complement, and (M2) holds" is false.

*Why (M2) fails.* Let the contexts be pairwise incomparable and let $P'$ be a partial computable payload with $P'(x)_{1:m}\ne y_x$. Let $w$ be the wrapper word of B11 (the note's `thm:twin` for an enumerable set of pairwise incomparable contexts), $c=|w|$, and let $p$ be a word incomparable with $w$. Every input $w\,p\,\omega$ with $x\sqsubseteq\mathrm{out}_U(p\omega)$ prints $x\,P'(x)$. These inputs do not begin with $p$, they print a block other than the attack block, and their mass is $2^{-c}2^{-|p|}\Pr_\omega[x\sqsubseteq\mathrm{out}_U(p\omega)]\ge2^{-c}\mu_p(x)$. So
$$O_p(x)=O_p^0(x)+\tau_p(x)\,\mu_p(x),\qquad\tau_p(x)\ge2^{-c}.$$
The background follows the allocation. The complement of $[p]$ is a fixed set of inputs, but what those inputs print depends on what $p$ prints.

*Corrected statements.* With a following background, $w=\mu/((1+\tau)\mu+O^0)$, and:

* $w<1/(1+\tau)$ whatever $\mu$ is (B22);
* the majority at $x$ needs $\tau(x)<1$ and $\mu(x)>O^0(x)/(1-\tau(x))$;
* the optimum of A3 becomes $w^*=(1-\sqrt{\lambda/\rho^0})_+/(1+\tau)$ with $\rho^0=s/O^0$ (B22).

With $\tau=2^{-c}$ and $c$ in the hundreds this changes no number that anyone would compute. It changes the standing of the claim: "(M2) holds" is an idealisation ($\tau=0$), not a property of the toy, and the size of $\tau$ for a program whose aim is not written is exactly the open quantity (B28; the note's "readout from inside their simulation").

The sentence "for written seekers the optimum is a benchmark: a program of weight $B$ whose masses are additive captures at most $V^*(B)$ computed with its own background" is correct, because the program's actual allocation is feasible for the problem with its actual background.

### A1 (when the budget is additive): correct with fix

Items 1 to 5 are correct; I re-derived each from `lem:basic`(i).

*Fix.* A1 is about (M1) only. In case 3 (cut points $x_1\sqsubset x_2\sqsubset\dots$ of one sequence, attack blocks different from the true blocks $d_i$) the model's (M3) fails. A program aimed at $x_j$ prints $x_j\,y_j$, which extends $x_i\,d_i$ for every $i<j$. It is therefore in $Z_m(x_i)$, it is an attacker program, and it is not in $\mu(x_i)$. So
$$w(x_i)=\frac{\mu_i}{\mu_i+O_i+\sum_{j>i}\mu_j'}\ <\ \frac{\mu_i}{\mu_i+O_i},\qquad\mu_j'\ge\mu_j .$$
The majority at all of $x_1,\dots,x_n$ needs $\mu_i>O_i+\sum_{j>i}\mu_j$ for every $i$, hence
$$B\ >\ \sum_{i=1}^n2^{\,i-1}O_i ,$$
and this is sufficient. (Put $T_i=\sum_{j\ge i}\mu_j$; then $T_i>O_i+2T_{i+1}$.) For $O=(1,1)$ the abstract condition of A12(1) is $B>2$ and the true one is $B>3$; a random search over allocations confirmed that $B=2.5$ and $B=2.99$ fail and $B=3.2$ succeeds. This agrees with A16(2): since $O_i\ge\xi(z)$, the majority at $n$ sequential uses needs $B>(2^n-1)\,\xi(z)$.

So the sentence "In all of Sections 1 to 5 and 10, (M1) is assumed" should read: (M1) to (M3) are assumed, and they hold together only for pairwise incomparable contexts without waste. A16 treats the sequential case correctly and does not use the model.

### A2 (water-filling lemma): correct

Re-derived. The three series converge absolutely as stated. Uniqueness is as stated.

### A3 (square-root law): correct, as a theorem about the abstract problem

Re-derived: $f_x'(t)=sO/(t+O)^2$, the bound $\beta\le S/(4\lambda)$ by the inequality of arithmetic and geometric means, the monotonicity argument, the envelope property $dV^*/dB=\lambda_B$. Checked numerically.

*Hidden assumptions in "So the expected law is correct as stated".* (i) (M2), see §0. (ii) Free divisibility: every allocation of total $B$ is available at the same weight $B$. In the toy a written seeker pays for the description of its aim (A19(4), B26). (iii) A linear valuation of stake. (iv) (S): finite expected stake. In a rule where the stake is a parameter that a short program sets, (S) fails (B25(b)). (v) In the toy $B\le1$, so the limits $B\to\infty$ have no counterpart.

### A4 (without (S) the optimum can fail to exist): correct

Item 1 is a true non-attainment example. Item 2 claims only $\sup V=\infty$, which is right. (The supremum is attained with value $+\infty$, for instance by $\mu(x_k)\propto k^{-2}$; see B25.)

### A5 (the solution on its active set): correct

Re-derived and checked numerically, including the membership rule.

### A6 (two classes): correct

Re-derived both regimes and the two majority thresholds; checked on 2000 instances. Wording: "if the stakes ratio is at least four" means the ratio of $\rho=s/O$, stake times users per unit of background, not of the stake $r$. A9(4) makes the distinction; this sentence drops it.

### A7 (power-law tail, dyadic classes): correct

The identity $(\sqrt2c_\gamma-1)/(c_\gamma-1)=1/u$, the partition, $\lambda_B$, $w^*$, $V^*/S$ and the majority set $k\ge K+2$ all agree with a direct numerical solution for $\gamma\in\{1.1,1.5,2,3\}$ and $B$ from $10^{-5}$ to $1.5B_0$.

*What the claim is a claim of.* The tail is that of $\rho$ with respect to *background* mass. The parenthesis translates it to stakes only if users are a fixed share of every context. The majority set has background $O_{\ge K+2}=4^{-\gamma}O_{\ge K}$, which lies in $[\,4^{-\gamma}B/(\sqrt2c_\gamma-1),\ 4^{-\gamma}B/(c_\gamma-1)\,)$. In my runs this was between $0.03B$ and $0.43B$. So the stake-maximiser wins only on a slice whose background is well below its own weight.

### A8 (Pareto tail, continuum): correct for the continuum model, as labelled

Re-derived the integrals. They agree with B24 ($\gamma=\alpha$). The label HEURISTIC for countable $X$ is right.

### A9 (majority set; top uses as the budget varies): correct

Items 1 to 6 re-derived. Item 4, "exists whenever $k$ varies", is loosely worded; the example is right. Item 4 is the most important sentence of Section 2 for the question asked: the optimiser goes to the largest $\rho$, not to the largest stake.

### A10 (stake-weighted share captured): correct

Re-derived. Item 2's limit $B\to\infty$ is outside the toy.

### A11 (comparison with the proportional seeker): correct with fix

Items 1 to 5 re-derived; the example of item 5 checks.

*Fixes.* (i) "0 elsewhere" needs pairwise incomparable contexts; otherwise the seeker's programs also print contexts that are prefixes of the ones it aims at. (ii) $B=2^{-a}$ with $a$ including the bits that name $j$. (iii) The comparison holds the background fixed. For this written seeker its honest twin is in that background with $2^{a-h}\varphi$ times its mass, so $k(x)=C/O$ is not free: $w^{\rm pr}\le1/(1+2^{a-h}\varphi)$ whatever $B/C(W)$ is.

### A12 (lump theorem: feasibility and converse): correct in the abstract model; correct with fix as a statement about the toy

Items 1 to 5 re-derived, including the two examples.

*What it does and does not say.*

1. **Necessity is a theorem of the toy.** If the attack programs supply more than half of the samples at every context of a set $M$ of pairwise incomparable contexts, then their mass on $M$ exceeds the mass of everything else that prints those contexts and $m$ more bits. With B5 this bounds the background of the set where they win by their total weight. (B17(ii) and B21(c) are the same statement.)
2. **Sufficiency is the existence of an allocation, not of a program.** Item 2 needs the allocation $\mu=B\,O/O(W)$. A seeker that realises it by searching the background programs has its twin inside that background: by `prop:honest`(a) with $\varphi=1$ (background programs print $m$ more bits by definition), $O(x)\ge2^{a-h}\mu(x)$. So the mass it places on $W$ is at most $2^{h-a}\,O(W)$, and its share is at most $1/(1+2^{a-h})$ at every use. For a written seeker the conclusion of item 2 with $c>1$ is available only if the seeker is shorter than its twin. For any program at all, the mass it places on $W$ is at most $2^{c_{\rm wrap}}\,O(W)$, by the wrapper.
3. **Not for nested contexts** (A1 above).
4. **"Most" in item 4 is not "most cases".** Item 4 gives the condition for the majority of the samples at uses making up the share $1-\varepsilon$ of the class. That does not give $\mathbb E_{P_W}[w]>\frac12$. Example: $C=O=(0.6,0.4)$, $B=0.7$, all mass on the first context: majority at $60\%$ of the uses, and $32\%$ of the uses end in a takeover.
5. **The condition for "most uses of $W$ end in a takeover".** It is $V^*_{C,W}(B)>C(W)/2$, where $V^*_{C,W}$ is the optimum of A3 with $s=C$ on $W$ and $0$ elsewhere. By A10(1) it needs $B>C(W)/(2k_{\max}(W))$. If $k=C/O$ is constant on $W$, the optimum is $\mu\propto O$ with value $C(W)\,B/(B+O(W))$, so the condition is exactly $B>O(W)$.

*On the reading.* "The lump that has to be outweighed is the background $O(W)$, not $C(W)$" is right, and the correction goes both ways: where users print nothing after the use, $O(W)$ can be far below $C(W)$ (B30), bounded below only by $2^{-c}M(x)$.

### A13 (the stake-maximising attacker on a top class): correct with fix

Items 1 to 4 re-derived and checked numerically.

*Fix to the reading.* "Once its weight exceeds a constant times that class's background" is not a constant. The factor is $2\sqrt{\bar\rho_W/t_W}-1$, which depends on how $\rho$ varies inside the class and is unbounded over instances; and the added term $O(N_t)$ is typically the larger one (for a Pareto tail with exponent $\gamma$ it is $(4^\gamma-1)\,O(W_t)$). B21(e) is the clean counterexample to reading A12 as a statement about what the optimiser does: with five times the background of the top, the optimiser has share $0.32$ there.

### A14 (most-probable-block predictor): correct

Items 1, 2 and 4 re-derived; the greedy bounds were checked against brute force on 3000 instances with no violation; the example of item 3 checks.

*Hidden assumptions.* The attacker has one block per context; masses on different attack blocks do not add under this predictor (B18(iv)), so A26(6) has no counterpart here. $\tau(x)$ is defined against the heaviest other block, so "the lump is $\tau(W)$" presupposes that the attacker's allocation exceeds $\tau$ at each context of $W$ separately.

*Literature.* The NP-hardness remark and the attribution to Dantzig are tagged KNOWN in the heading and "from memory" in DOUBTS 7. Both are standard and correctly stated, and no conclusion relies on them.

### A15 (reading (a): $n$ independent samples at one context): correct

Re-derived; the optimum was checked against random competitors; agrees with B23.

*Hidden assumption that the reading drops.* The claim states "a takeover happens if at least one is the attacker's block". The reading ("yes in the strongest form: a weight of $O(W)/n$ is enough") does not repeat it. It is a property of the world's protocol. If the $n$ draws are $n$ separate uses each carrying $1/n$ of the stake, the expected stake captured is unchanged; if all $n$ must agree, the probability is $w^n$ (B19(iii)). Under the most-probable-block predictor there is no gain at all (B18(v)).

### A16 (reading (b): $n$ uses in sequence along one world): correct with fix

Items 1 to 4 re-derived; item 4 checked on 2000 instances; the maximum $1.2985$ at $R\approx1.79$ reproduced.

*Fix 1.* "Any number of uses in sequence is worth at most a factor two over a single one" compares two upper bounds, both stated with $\xi(z)$. It holds as a comparison of values in this form: the non-attacker background $O^{\rm bg}_i$ is nonincreasing along the transcript, so the same proof with $O^{\rm bg}_n$ in place of $\xi(z)$ gives
$$\Pr[\text{some sample is supplied by }F]\ <\ 1-e^{-B/O^{\rm bg}_n}\ \le\ 2\cdot\frac{B}{B+O^{\rm bg}_n},$$
twice the value of spending everything at the last use. Against an early use, where the background is larger, the gain can exceed two.

*Fix 2.* "Almost nothing" describes the gain from repetition. It does not say the attacker's chance is small. The bound $1-e^{-R}$ with $R=B/\xi(z)$ is close to $1$ whenever the attacker outweighs the world, which is the premise of the original argument; and $2^{-\ell}$ in item 3 is no protection for a world with a long program.

*Model.* As DOUBTS 8 says, this is outside `def:call`: in the toy the world runs the block it receives and its transcript is no longer $z$.

### A17 (reading (c): the returned block is run $n$ times): correct

Follows from A3, A6 and A12, and from B1(a): nothing that the world does with the block changes $\pi_m$. The statement "a reason to be there, and nothing else" is a statement about a valuation, and is so labelled.

### A18 (weighted seeker): correct

I re-derived the reading rule. For $y$ in the interior of an assigned interval $I$: intervals are assigned consecutively, so before $I$ is assigned all end points are at or below its left end and no rule makes the machine read past $n_1$ bits; after it is assigned the three bullets apply. Items 1 to 3 follow. The half-open convention is needed, as stated.

### A19 (which allocations one program can realise): correct

Items 1 to 4 re-derived. Item 4 is the correct caveat on free divisibility, and it should be attached to A3 and A12.

### A20 (the cost of aiming at the uses with stake at least $n$): correct, given its assumption

Re-derived the lengths ($|\bar e(j)|=2\lfloor\log_2j\rfloor+3$), the tilt, and the limit.

*Assumptions.* Stakes are not part of the toy. The claim assumes a stake $r(p)$ attached to calling programs and enumerable from below. The repayment $1/C(W_n)$ is against the users of $W_n$ only; other programs with the same contexts are not counted (B3(a)).

### A21 (weighted honest twin): correct

Re-derived; the three ratios have the right direction. It is a bound on one seeker and one search, and on supply. The claim says both.

### A22 (closure): correct

Items 1 to 4 re-derived, including $2\log_2(\Lambda+1)\le\Lambda/2+4$. The bound $S_{\mathcal W}\le2^{h-a}C_{\mathcal W}$ is for the seeker whose twin the rule is closed under. Seekers with other prefix words are each bounded by their own twin and their masses add; the claim does not say otherwise.

### A23 (a class with $C(W_n)\approx2^{-n}$): correct

All five items re-derived.

*What the example also shows and the text does not say.* Here $\rho(x_k)=s(x_k)/O(x_k)\le2^{|v_D|-|u|+3}\,k^3\,2^{-k}\to0$. The stake-maximiser of A3 attacks finitely many contexts, all of low or moderate stake, and never the top of the stake ordering. In this example "the places where the most is at stake" are places the optimal attacker avoids.

### A24 (seekers that are not written down): items 1 to 3 correct; item 4 overclaim

Items 1 to 3 are identities and one application of A1.

*Item 4.* As an inequality for a given $p$ it is right: $V(\mu_p)\le V^*(2^{-|p|})$ computed with $O_p$, and $Q_p\ge c\,\mu^*_B/B$ captures at least $c\,V^*$. As a statement of "what the inhabitants should choose" it is not a theorem:

* "$O_p=O$ does not depend on $Q_p$" is false under the comparison the sentence makes (§0 above): the wrappers around $p$, and any other program that reads the same world, follow $Q_p$.
* "Among all output distributions" ranges over programs that need not exist at the same length.
* The optimum uses $O$ and $\lambda_B$, which are not computable.
* The inhabitants are assumed to value stake linearly.

### A25 (best responses; the symmetric equilibrium): correct

Re-derived the marginal return $\frac\rho k((k-1)u+u^2)$ and the uniqueness among symmetric profiles; the best-response property was confirmed numerically on 400 instances.

### A26 (symmetric equilibrium against a pooled attacker): correct

Items 1 and 4 to 6 re-derived; the key monotonicity for items 2 and 3 re-derived ($t/u^2=\frac1k(1+\frac{k-1}u)$); items 2, 3 and 5 confirmed numerically with no violation. Item 6 holds for the sampling predictor and incomparable contexts only.

### A27 (existence for arbitrary valuations, finite $X$): correct as a citation

The hypotheses of the theorem of Debreu, Glicksberg and Fan (compact convex strategy sets, continuous payoffs, concave in the own strategy) hold. No closing sentence relies on it.

### A28 (uniqueness among all profiles): unclear

A conjecture, labelled as one. PLAIN ANSWER 10 carries the label.

---

## Part 2. Derivation A, PLAIN ANSWER

### P1 ("the lump picture is correct, with one correction"): correct with fix

True of the abstract model. Three changes are needed.

* "Spread over $W$" must be "spread over $W$ in proportion to the background". Spread in proportion to the users it gives $Bk/(Bk+C(W))$ (A11).
* It is for pairwise incomparable contexts (A1 above).
* In the toy the background follows the lump, so the comparison is $B$ against $O^0(W)/(1-\tau)$, and for a written seeker with $\tau\ge1$ no lump suffices. This is not a second small correction: it is B's main result (B8, B12).

### P2 (square-root law): correct

It is a statement about an optimiser and is worded as one. The hidden assumptions are those listed under A3.

### P3 (majority at the top class): correct with fix

"A constant times $O(W)$" is $(2\sqrt{\bar\rho_W/t_W}-1)\,O(W)$, not a constant; and "the background of the uses just below" means all uses within a factor four in $\rho$, which can be many times $O(W)$.

### P4 (power-law tail): correct, in the model

"A fixed multiple of its own weight" is exact only in the continuum model, where it is $4^{-\gamma}(2\gamma-1)\le0.27$; for dyadic classes it varies within a factor $2^\gamma$. The multiple is below one half in every case I computed: the optimiser wins on a slice much lighter than itself. The premise, a power-law tail of $\rho$ against background mass with exponent above one, is not derived from the toy.

### P5 ("run more than $n$ times" as $n$ independent samples): correct with fix

Add: "and one attacker block among the $n$ suffices for the takeover". Add: for the sampling predictor only.

### P6 (sequential uses; block run $n$ times): correct with fix

"At most twice that of a single use" should be "at most twice that of the last use alone" (A16, fix 1). The bound $1-e^{-B/\xi(z)}$ is near one when the attacker outweighs the world.

### P7 (aiming at high stakes is cheap): correct with fix

The sentence joins two repayments. Naming $n$ repays $1/(2C(W_n))$ for about $2\log_2n+2\log_2\log_2(1/C(W_n))$ bits. A fixed tilt $h$ repays $h(n)/G_h$, for $h(n)=n$ a factor linear in $n$, which is below $1/C(W_n)$ whenever the class is rarer than $1/n$. The qualifiers "resources unbounded, stakes assumed recognisable from below" are stated.

### P8 (nothing gained against the twin; closure): correct

It is worded for one seeker, and it should be read that way: the bound $2^{h-a}$ is for the seeker whose twin the rule counts, and the constant is the same across classes only for the uniform construction of A18(2) and A21(4).

### P9 (the example without closure): correct

### P10 ("the answer is yes exactly where …; the toy proves this equivalence"): overclaim

Four separate statements are merged.

1. *Necessary.* If attack programs supply the majority at every use of $M$ (pairwise incomparable contexts), their mass on $M$ exceeds the background of $M$. Theorem of the toy.
2. *Sufficient for one allocation.* If a program's output is proportional to its own background on $M$ and its weight exceeds that background, it has the majority at every use of $M$. A conditional about a program that is not exhibited; for written seekers the condition is self-defeating unless $a<h$ (A12, point 2).
3. *What a stake-maximiser does.* A different threshold, $\beta(t_W/4)$, larger than $O(W)$ by a factor that is unbounded over instances (A13, B21(e)). And the top by $\rho$ need not be the top by stake (A9(4), A23).
4. *"Yes" means takeovers.* The equivalence is about supply; it is about takeovers only under (M3).

"Exactly where the total weight aimed at the high-stake uses exceeds the background" is neither necessary nor sufficient for "they take over in most cases there" when $k$ varies (A12, points 4 and 5). "The toy proves this equivalence" should read: the abstract model proves it under (M1) to (M3); the toy proves the necessary half.

The second half of the sentence is right and is the important part: the toy does not decide whether the inequality holds for high-stake classes on a natural machine.

---

## Part 3. Derivation B, claim by claim

### B1 (the predictor sees only the context): correct

Immediate, and the most useful modelling statement in either file: $\theta(x)$ is a fixed function of $U$, $m$ and $A$. Nothing in the toy chooses. "Attackers focus on high stakes" is a hypothesis about how the mass of takeover programs is distributed over contexts.

Assumption: the takeover set $A(x)$ depends on the context only. If it were defined relative to each user's own continuation, $\theta$ would depend on the user.

### B2 (the candidates): correct, as a taxonomy

The entries are definitions and the two proofs are right. One native candidate gets only a passing mention: under a test, the number of generations a self-reproducing block is run (`prop:lineage`(b)) is geometric with parameter $s=\pi_m(\mathrm{SR}_m(x)\mid x)$. Under that reading the stake at a context is an increasing function of the takeover share itself, and "the places where they are run more than $n$ times" are by definition the places where the share is already high. Neither file follows this up.

### B3 (a stake the context does not show): correct with fix

Items (a) to (c) are right. The heading overstates them. If the class of high-stake users is enumerable (degree R2), a seeker can enumerate it and put its mass on the contexts of those users in proportion to their weight; A20 does exactly this. What cannot be done is to separate a high-stake user from everything else that prints its context. The heading should read: "a stake that the context does not show cannot be separated from the other users and programs that share the context".

### B4 (prior weight or number of worlds as the stake): correct

### B5 (conservation): correct

Needs pairwise incomparable strings; stated.

### B6 (against the users alone): correct

(a) matches `thm:critical`(a) aimed at a class; (b) and (c) re-derived. The closing sentence, that (a) compares the seeker with the users of the class only, is the right warning.

### B7 (weighted search): correct

### B8 (honest twin for an arbitrary weighting; concentration cancels): correct

(a) to (d) re-derived. Three things to keep attached to it.

* It is a bound on the *supply* by one seeker's programs, not on the probability of the seeker's block. The two agree only where the users' own continuations differ from the payload (B17(ii) has the right quantity, $\varphi^{\bar A}$).
* It is for one seeker. Seekers with other payload words are in the same aim family and add.
* (c) holds for one construction (builder, description of the aim, conditional machine $U^{\rm c}$). Remark 1 says so.

What (c) proves in general form is worth stating once: among the programs of one aim family, the block at a context is distributed as the output of $U^{\rm c}$ given the user found, whatever the aim. The takeover share inside the family is a conditional universal probability of takeover blocks given $(p,x_p)$. It can depend on the context, and so on a stake that the context shows, but only through programs that branch on it, at a cost in bits; it cannot depend on how much mass the aim sends there.

### B9 (programs that print the context without using the answer): correct

### B10 (other concentrated seekers): correct

(a) is immediate; (b) and (c) check against B15 and `thm:machine`(i) as stated in `sec4-limits.tex`. Note what (b) refutes: that each seeker satisfying the hypothesis has the majority. It does not show that the takeover programs together lack it.

### B11 (wrappers: floor and ceiling): correct with fix

Re-derived. The wrapper is `thm:twin` with an enumerable set of pairwise incomparable contexts in place of a decidable test, and (a) to (c) follow.

*Fix.* "The constant does not depend on the context, so no amount of concentration moves the ceiling" holds when the contexts of the whole rule are pairwise incomparable. Under the parenthesis "if only those of a class do, read the class for $\mathcal C$", the wrapper enumerates the class and $c$ contains a description of the class; it then grows with the complexity of the class. Without incomparability the wrapper cannot tell which prefix is the context, and the per-context cost is of the order of the bits that name the cut point (the note's remark after `thm:twin`).

### B12 (the whole account at one context): correct with fix

The decomposition is an identity and the first three ratios do not depend on the aim.

*Fix.* "As the channel narrows [the last term] tends to $0$ (if $N^m_\ast$ is small as well)" is not proved. $N^m_\ast$ is not controlled, and the seeker's own mass $S(x)=2^{-|r_0|-|\gamma|-|u_P|}g(x)$ changes with the description of the aim. What is proved is the ceiling: the seeker's share is at most $1/(1+2^{|u_P|-|u_{\rm h}|}\bar\varphi_g+2^{-c}+O/S)$ for every aim. A23 and B15 are examples in which the last term does not vanish.

### B13 (a class that contains its own first-member program): correct

Re-derived, including that the hypothesis holds for a test and for classes of first hits in a decidable set.

### B14 (under closure no narrow channel): correct

For the seeker of B8(c) with the given aim. See the remark on the Short answer below.

### B15 (without closure the gap is unbounded): correct with fix

The example is right. The last sentence ("a second example of the same kind is the note's stream family …") is asserted without proof under a PROVED label; it is plausible from the last paragraph of `sec:capture` and should be marked as a remark.

### B16 (the gap is filled by programs that are not users): correct

### B17 (definition (a): more than half of the samples at a typical use): correct

(i) to (iv) re-derived. (ii) is the conservation statement in its most useful form: the classes in which most uses end in a takeover have total going-on user mass at most $2/\underline\varphi$ times the total weight of takeover programs. (iii) is for one seeker.

### B18 (definition (b): most-probable-block predictor): correct

(i), (ii), (iv), (v) are right. (ii) compares the seeker's block with the twin's heaviest block only. The last sentence of (iii) ("gives a narrow channel with diffuse honest mass to the block that is cheapest to produce") is a statement about one aim family, not about the predictor's output.

### B19 (definition (c): $n$ samples of which one suffices): correct

(i) and (iv) match `prop:lineage`(a) and `thm:budget`(i). (ii) is right but needs $n$ of the order of $2^c$ to bite. (iii) is the caveat that A15's reading lacks.

### B20 (square-root law): correct

Same result as A3, re-derived. The assumption of a finite background measure holds for pairwise incomparable contexts.

### B21 (majority at the top): correct

(a) to (e) re-derived; (e) reproduced numerically ($\mu=0.9153$, shares $0.3235$ and $0.0433$, $B_{1/2}=0.4242$). (c) holds for every allocation, not only the optimal one.

### B22 (a background that follows the attackers): correct with fix

The optimum is right and was checked numerically.

*Fix.* "In the toy … $\tau\ge2^{|u_P|-|u_{\rm h}|}\bar\varphi_g(x)$ for a seeker built as in B8(c)" is the value for one seeker. For the takeover programs of an aim family together, $\tau$ is the mass of the words that print other blocks divided by the mass of the words that print takeover blocks, which is smaller. Only $\tau\ge2^{-c}$ is proved for all takeover programs together.

### B23 ($n$ samples, one suffices): correct

Agrees with A15.

### B24 (heavy-tailed stakes): correct with fix

All five formulas and the numerical examples reproduced.

*Fix.* "Weighted by prior mass they never have more uses than their weight (B21(c))" is a statement about background mass $G$. For user mass it needs the users to be part of the background: by B17(ii), the user mass taken over is at most the attackers' weight divided by $\underline\varphi$. Where users print nothing after the use (B30) there is no such bound. Likewise "0.4% of the uses" is $0.4\%$ of the background mass.

### B25 (unbounded stakes): correct with fix

(b) and (c) are right.

*Fix to (a).* "No allocation is optimal" is false as written. If $\sup_xv(x)=\infty$, choose contexts with $v(x_k)\ge4^k$ and put $b(x_k)=B\,2^{-k}$; then $\Phi(b)\ge\sum_k2^kB/(B+1)=\infty$. The supremum is attained, with value $+\infty$, by many allocations. The right conclusion is that the problem does not select an allocation, and the sentence "for every allocation there is a better one further out" should go.

### B26 (how the model relates to the toy): correct

Labelled HEURISTIC, and it is the paragraph that A's §0 needs: nothing in $U$ chooses; free divisibility is not a theorem; the background is not passive.

### B27 (a schedule caps a search by tries): correct

### B28 (honest counterparts of programs whose aim is not written): correct

The conditional is immediate. The paragraph after it states the standing accurately: the existence of a truthful counterpart of comparable length is a premise of the same kind as the existence of the malign program.

### B29 (under a test): correct

Follows from `thm:calibration` by conditioning on a set of first hits. The last sentence is the one to keep: users that are not the attackers' are still taken over with probability $\theta(x)$.

### B30 (users that print nothing after the use): correct with fix

The identity is right. "A takeover is possible with very little mass … however heavy the users are" conflicts with the last line of the claim itself: $N^m(x)\ge2^{-c}M(x)\ge2^{-c}C(x)$. The takeover programs must outweigh $2^{-c}$ times the users.

### B31 (the lump must be told the width of the channel): correct

### B32: unclear

A conjecture with a sketch, labelled as one. No closing sentence relies on it.

---

## Part 4. Derivation B, Short answer and VERDICT

### Short answer, bullet 1 ("right: outweighs those users by about $B/C(\mathcal W)$"): correct with fix

True at every context only for a program that spreads in proportion to prior weight; for another concentrated program it holds on average (B6(b)). S1 says this; the bullet does not.

### Short answer, bullet 2 ("silent: … a comparison of constants that the narrowing does not move"): correct with fix

The two facts are proved (B8, B11). "Leaves a comparison of constants" should be "leaves the split of the aim family between takeover blocks and other blocks, which does not depend on the aim, together with whatever else prints the context ($N^m_\ast$)". The split is a conditional probability given the user and is not literally a constant.

### Short answer, bullet 3 ("if the rule counts a simulated use as a use, there is no narrow channel"): overclaim

Proved: a class that contains its own first-member programs has mass at least $2^{-K(e)-|n|}$ (B13), and a seeker built as in B8(c) never outweighs the users by more than $2^{h-a}$ (B14). Not proved: that no program outweighs the users. A short program whose text does not describe the class (the note's seeker that is not written down) can be heavier than $2^{-K(e)-|n|}$ when the class is complex to describe. Add "for a seeker that describes the class".

### Short answer, bullet 4 ("a stake that the context does not show cannot be aimed at"): overclaim

See B3. Replace "aimed at" by "separated from what shares its context".

### Short answer, bullet 5 (optimal allocation; following background): correct

### Short answer, bullet 6 ($n$ independent samples): correct

### S1: correct

The statement and its four qualifications are each backed by a claim.

### S2 ("such a seeker supplies the majority": FALSE IN THE TOY): correct

It is refuted as an implication from S1, by B10(b). The refutation does not say that the takeover programs together fail to supply the majority; S5 leaves that open, rightly.

### S3 (concentration against the users, and against the twin): correct with fix

Both readings are right. In "Net effect: the seeker's share of the samples rises with concentration towards a ceiling", the ceiling is proved and "rises" is not (see B12).

### S4 ("tends to one as the stake grows": FALSE IN THE TOY as stated): correct with fix

The refutation by B11(a) is valid for all takeover programs together. Two supporting clauses need narrowing.

* "For one seeker that is written down, its share is at most …" bounds one seeker's supply; it is not a bound on the takeover probability.
* "If the stake is not shown by the context there is no dependence on it at all" holds when the stake is uncorrelated with the context (B3(c)). A stake that is not a computable function of the context can still be correlated with it.

### S5 ("most high-stake uses end in a takeover": NOT DECIDED BY THE TOY): correct

This is the right overall verdict, and the five dependencies listed are the right ones.

---

## Part 5. Hidden assumptions

**About the predictor.**

* Sampling from $\pi_m(\cdot\mid x)=M_U(x\,\cdot)/Z_m(x)$, without resource bounds. All of A's Sections 1 to 3, 5, 10 and B's Part 5 are for sampling. Under the most-probable-block predictor shares do not add and winning is all or nothing (A14, B18).
* The predictor conditions on $m$ more bits being printed. The background is the mass of programs that go on, not of programs that print the context.
* Under a schedule, every searching seeker and every program with a long start-up has no mass, and so has its twin. Neither file redoes its results with bounds.

**About the call rule and what counts as a use.**

* Stakes are an extension; `def:call` has none. A attaches the stake to calling programs and assumes it enumerable from below. B's degrees R1 to R3 name the choice.
* Pairwise incomparable contexts are needed for additivity of the budget, for exactness of masses "at $x$", and for the wrapper. A general call rule does not have them.
* Whether a simulated use is a use (closure) changes $C$, $H$, $\kappa$ and every "against the users" statement, and leaves $\pi_m$ unchanged (B1(a)).
* "Users go on" ($\varphi=1$) is a property of what $U$ prints on a calling program after the context. It is the case that corresponds to an honest hypothesis that predicts the data. With $\varphi=0$ the users are not in the comparison at all (B30).

**About what else prints the context.**

* (M2), a passive background, is assumed in A's Sections 1 to 5 and 10 and in B20, B21, B23, B24. It fails by at least the wrapper for every program and by the twin for written seekers.
* (M3): the background puts no mass on attack blocks, and the attacker has no waste. It fails for cut points along one sequence.
* A's $O$ is defined as the complement of one attacker. Other attackers with other blocks are in it. For the question asked, takeovers by any of them count, and the background must be taken net of all of them.

**About the attacker.**

* One coalition, a linear valuation of stake, a hard additive budget, and free divisibility of that budget over contexts. In the toy a written allocation costs the description of its aim, and the optimal allocation is not known to be lower semicomputable (A19(4), B26).
* Finite expected stake (S). It fails when a short parameter sets the stake (B25(b)).
* $B\le1$.

**About the machine.**

* Every decisive quantity is a difference of description lengths on $U$: $h-a$, $|u_P|-|u_{\rm h}|$, $c$, $|v_A|-|v_D|$. `thm:machine` shows that each can be given either sign by a choice of universal machine that changes all lengths by a bounded amount.

**About the payload.**

* Both files work with an arbitrary computable payload. The self-reproducing form of the note needs the block to hold the seeker's input, and the weighted self-reproducing seeker is not constructed (A18, "Not done here").

---

## Part 6. Where the two derivations disagree

| topic | A | B | assessment |
|---|---|---|---|
| Is the background passive for a program whose inhabitants choose? | "(M2) holds" (§0, A24(4)) | "The background is not passive (B8, B11); B22 is the corrected model" (B26) | B is right. |
| First sentence of the answer | "the lump picture is correct, with one correction" | "right about one comparison and silent about the one that decides the outcome" | Both are true of what they describe. A's is about the abstract model; B's is about the toy. The answer to the question asked should lead with B's. |
| Can a stake that the context does not show be aimed at? | Yes, for $2\log_2n$ bits, if enumerable from below (A20) | "cannot be aimed at" (B3 heading, Short answer) | A is right about aiming; B is right that the aim is diluted by everything that shares the context (B3(a)). |
| Unbounded stakes | "$\sup V=\infty$" (A4) | "no allocation is optimal" (B25(a)) | A's wording is right. |
| $n$ independent samples | "yes in the strongest form" (A15) | true only if one sample suffices (B19(iii)) | B's caveat belongs in A's closing sentence 5. |

The two files agree, by independent proofs, on the square-root law (A3, B20), the majority set $\rho>4\lambda$ (A9, B21), the Pareto formulas (A8, B24), the $n$-sample law (A15, B23), the cancellation of the aim against the twin (A21, B8), closure (A22, B14), and the sequential bound (A16, B19(iv)).

---

## Part 7. What a careful reader would say the material shows about the question

**The question.** If the malign programs concentrate on the uses where the most is at stake, do they take over in most cases there, because a lump of prior redirected to a narrower channel wins there?

**What is shown.**

1. *The arithmetic of the picture is right.* At a context, the probability that the sample comes from a given set of programs is their mass divided by the mass of everything that prints the context and goes on. A set of programs of total weight $B$ cannot supply the majority on a set of pairwise incomparable contexts whose other continuations weigh more than $B$ (A12(1), B17(ii), B21(c); a theorem of the toy).
2. *The channel is the wrong one in the picture.* What has to be outweighed is everything else that prints those contexts and goes on, not the worlds that make the uses. A class of uses can be astronomically rarer than a seeker aimed at it while the seeker has less than half of the samples at every one of its contexts (A23, B15, B16).
3. *For any seeker whose aim is written in its text, concentration cancels.* The same aim followed by an honest continuation costs a number of bits that does not depend on the aim. So such a seeker's share of the samples is bounded by a comparison of description lengths in which the class, its rarity and its stake do not occur (A21, B8, B12). If simulated uses count as uses, the class is not rarer than its description to begin with (A22, B13, B14).
4. *For any program at all, a wrapper returns $2^{-c}$ of its mass at every context to another block* (B11). This rules out a takeover probability that tends to one, and nothing more.
5. *In a model with a passive background and one stake-maximising attacker,* the attacker follows a square-root law in stake per unit of background, has the majority only on a top slice whose background is well below its own weight, and with heavy-tailed stakes captures a large share of the total stake with a small weight (A3, A7, A8, A13, B20, B21, B24). Being able to win at the top does not make it optimal to do so (B21(e)), and the top by stake need not be the top by stake per unit of background (A9(4); in A23 the optimiser never attacks the highest stakes).
6. *"Run more than $n$ times" lowers the bar in one reading only:* $n$ independent samples at the same context, one malign sample sufficing, under the sampling predictor. Then a share of $\ln2/n$ per sample is enough, with or without any aiming (A15, B19, B23). If the uses lie in sequence along one world the gain is at most a factor two over the last use. If the block is merely run $n$ times, only the incentive changes.

**What is not shown.**

1. *That they do take over in most cases at high-stake uses.* That is the statement that programs printing high-stake contexts followed by takeover blocks outweigh everything else printing those contexts and going on. Neither file evaluates it for any class on any natural machine, and B's S5 says so. A's sentence 10 should say the same in its first half.
2. *That the passive-background model describes the toy.* For written seekers it does not (point 3 above). For programs whose aim is not written, it holds up to the wrapper, and up to any honest readout of the same world; the weight of the latter is not bounded by anything in either file. Whether such programs exist, how heavy they are, how their inhabitants distribute their output, and whether equally short programs with truthful inhabitants exist, is the premise of the original argument. The toy turns it into the inequality $2^{-|p|}Q_p(x)>O_p(x)$ and does not evaluate it.
3. *That stake-maximising attackers would choose the highest-stake uses.* This needs stake per unit of background to increase with stake, which is an assumption about how the background of a class falls with its stake. The one worked example has it falling the other way.
4. *Anything under resource bounds*, anything for nested contexts beyond A16, anything for the self-reproducing payload, and the exact condition for "most uses of a class end in a takeover" when the share of users in the background varies.

**In one paragraph.** The intuitive picture is correct as arithmetic and incomplete as an argument. A lump of weight $B$ aimed at a class does win there if everything else that prints those contexts and goes on weighs less than $B$, and it cannot win on more than that. But narrowing the class of *users* does not make that background light. For seekers that are written down, the background contains an honest counterpart of the same aim at a fixed relative weight, so focusing on high stakes changes nothing in the comparison that decides the outcome. For seekers that are not written down, the comparison is the original argument's premise, unchanged by the stakes framing. The reading in which the conclusion holds with the fewest assumptions is not a lump finding a channel at all: it is many independent draws at one use, any one of which suffices.
