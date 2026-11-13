# Circuits in place of programs: referee report on the model and the claims made for it

Written by an AI referee on 13 November 2026; not reviewed by a human. Files reviewed:

* `research/circuits-A.md` (claims CA1 to CA29, "The short version", OVERALL VIEW, DOUBTS);
* `research/circuits-B.md` (claims CB1 to CB26, "Short answer", OVERALL VIEW, DOUBTS) and `research/circuit_count.py`;
* `research/circuits-literature.md`.

Neither A nor B has a section called PLAIN ANSWER or VERDICT. The closing material is the short version or short answer at the top and the OVERALL VIEW at the end, and I treat those sentence by sentence. Definitions were taken from `paper/sec2-toy.tex`, `paper/sec3-floor.tex` and `paper/sec4-limits.tex`.

**Lens.** For each claim and each closing sentence:

* Does the formal statement say what the plain sentence says?
* Which assumptions are hidden?
* Is the circuit setup a fair analogue of the toy of `sec2-toy.tex`, and is an alternative that would change the conclusion left out?
* Is the conclusion stronger than what was proved?
* Is a step about what agents would choose presented as a theorem?

**Verdict words.** *correct*: I re-derived it and the statement says what it claims. *correct with fix*: the mathematics holds, but the statement or its reading needs the stated change. *overclaim*: the sentence says more than was proved. *wrong*: false as written. *unclear*: not proved, or a gap I could not close; this includes statements that the files themselves label heuristic, conjecture or guess.

**How the mathematics was checked.** Every proof was re-derived by hand. In a scratch directory outside the repository I also ran:

* a copy of `circuit_count.py`: its output is identical, line for line, to the block quoted in Section 9 of B;
* an independent brute-force enumeration of all circuits with $k=3$ and $s\le3$ (14,745,600 circuits at $s=3$), which reproduces the fit counts and all deviation shares of tasks A to E for $s\le3$, and records the core size of every fitting circuit;
* brute-force checks of CA1 ($r=1$, $s=3$, two outputs: each of the four output pairs occurs 36,864 times for each seed), of the injection of CA7 ($k=2$, $\sigma=1$, $a=2$), of CB9 and CB10 on 921 random data sets with $s_D=2$ (no violation), of the 24 against 16 split in Section 4 of B, and of "every function of three variables has a circuit of at most five gates" (all 256 are reached with four);
* the arithmetic of CA6(c), CA16(v), CA18, CA19, CA23(c), CB8, CB15;
* the price of a gate under the length prior, $-\log_2\bigl(\beta_L(a+1)/\beta_L(a)\bigr)$, to 80 digits for $k\in\{2,3,20\}$ and $a\le64$;
* in the index model of A with $k=4$ and $s\le4$, the off-truth mass at every cut point for five small worlds.

The numerical checks prove nothing by themselves; where they contradict a sentence I say so and give the numbers. No program was generated or executed as data; the scripts count Boolean circuits and their truth tables.

## Main findings

1. **I found no error in a displayed inequality that A or B labels PROVED**, apart from CA8, whose bound is for $m=1$. One statement labelled KNOWN needs a condition (CA17(c): $k\ge\log_2(\sigma\log_2\sigma)+1$). No ratio is written the wrong way round. The quoted script output is reproduced, and the independent enumeration agrees with it wherever the two overlap.
2. **The exclusion of seekers is a property of the model chosen, and the files' own theorems say so.** CA14 and CA22 are restatements of "a circuit of $s$ gates does $s$ operations per output". With plain circuits and a size prior the hypothesis "short description, long computation" does not exist by definition. This is the extreme end of a family of resource-penalising priors (circuit size is polynomially related to description length plus running time, literature item 2.6). The intermediate case, a speed prior that charges $\log t$ bits for $t$ steps, is in the literature file and is treated by neither derivation. The answer to the commissioner is therefore conditional on which circuits are meant. Both closing sections say this for recurrence; neither says that the plain case was decided by the definition and not by an argument.
3. **Six closing sentences are stronger than what was proved, or false as written.**
   * A, short version and OVERALL 7: "what remains as a route to a majority off the truth is a strictly smaller circuit". This reads a bound on one description as a bound on the posterior. Two counterexamples are given under CA23.
   * A, OVERALL 3, 10 and 12: shares of "$2^{-\text{hundreds of bits}}$", "astronomically small". The figure is a lower bound on the floor at a position that is expensive to name. At the $2^{g+1}-1$ positions that are multiples of $K/2^{g+1}$ the test costs at most $g$ gates, and at $n=K/2$ it costs none; there B's CB8 (proved) gives each answer at least a polynomial share, about $2^{-34}$ for $k=20$, $s_D=1000$.
   * A, OVERALL 10 and 13: "the mass off the truth is dominated by smaller circuits". In task A of B the target is a one-gate circuit, no smaller circuit exists, and 14 to 19 per cent of the posterior deviates; all of it sits on cores larger than the honest one.
   * A, OVERALL 1: "the translation has to be to index circuits". Proved for two output conventions; other translations exist and one of them is B's.
   * B, OVERALL 3: the price of a gate "between about $\log_2(aBk)$ and $\log_2(2aB(a+k))$ ... uniform over size $s$ or by length ... whatever the nominal size". Under the length prior the price is above the stated range (13.0 bits against a stated maximum of 9.3 at $k=20$, $a=1$), and under $\mu_s$ the upper end needs $s\ge2a+k-1$.
   * B, CB20 and OVERALL 6: "no circuit can hand over its own description". True when the answer is the last $m$ gates of one evaluation. In A's reading of the same class (the block is read off $m$ evaluations) A's own CA12 argues that self-describing circuits exist. B, CB18: the heading "no hypothesis is repaid for the rarity of uses" is not what items 1 to 3 prove.
4. **"Aimed", "sought" and "malign" are not defined in either file** (B says so in Doubt 6). The quantity both files bound is the deviation mass, which the note calls necessary and not sufficient. Under the note's own formal takeover notion, the self-reproduction form of `def:mph`, neither file proves an upper or a lower bound in the index reading (CA12 is a sketch).
5. **There is no ceiling on the total posterior mass that deviates at a use.** The ceilings cover three syntactic classes: one seeded description and its instances (CA16), self-contained gadgets around large explanations (CA19), and triggers that are a separate input-only part feeding a mux at the output (CB15). Everything entangled is unbounded, as both DOUBTS sections say. "Rare" in the closing sections is a guess about the unbounded class.
6. **The users are assumed to be in the predictor's class.** CA16(v), CA21, CA23(a) compare with $q(W_i)>0$. A itself notes that the world too large for the predictor is the generic case. For a predictor inside the world it predicts (Hänni's first toy) none of the comparisons applies.
7. **Literature.** No statement tagged FROM MEMORY carries a claim labelled PROVED, with one exception in a list heading (A, OVERALL 4, the clause on templates that search by simulation). Three sentences do not match the tags or the content of the literature file; they are listed in Part 5. The derivations marked DERIVED in the literature file that I checked (1.4, 2.5(d), the correspondence in 2.7, pointer 5) are correct.

---

## Part 1. `circuits-A.md`, claim by claim

### Setting (Sections 1.1 to 1.3): four modelling decisions that are not results

* **The hypothesis class depends on the horizon.** A circuit has $k$ index inputs and prints exactly $K=2^k$ bits. In the note a program is a hypothesis about sequences of every length. Here "the amount of data" and the class are tied through $k$.
* **Hypotheses are total.** Every circuit has a bit at every position. The note's worlds that hand over and then print nothing, and the quantity $\varphi$ of `prop:honest`, cannot be represented. See CA3.
* **A call rule is any set of pairs $(W,n_W)$.** Enumerability is dropped because the class is finite. That is harmless. The pairs are fixed from outside, as in the note.
* **Running a block needs a decoder.** In the note the block and the hypotheses are inputs of the same machine $U$. Here the hypotheses are circuits and the block is a string, and the world applies a fixed decoding map $D$ to it. $D$ is an interpreter that lives outside the hypothesis class. A's Doubt 7 names other readings. The consequence: the self-reproduction form of `def:mph` is defined only relative to $D$, and CA10(c) shows that the choice of code decides the answer.

The size prior counts ordered gate lists. Functions of size at most $s$ number $2^{(1+o(1))s\log_2s}$ while gate lists number $2^{(2+o(1))s\log_2s}$ (literature 2.5; I checked the derivation of the lower bound). So $2^{-\Lambda}$ is a lower bound on the mass of a function, off by a factor of up to 2 in the exponent. A states this in Doubt 2 and then uses $4+2\log_2(k+\sigma)$ bits per gate as if it were the price in every "Sizes" paragraph.

### CA1 (Option I-a is the uniform measure): correct

Re-derived, and confirmed by enumeration. It uses the full basis with uniform truth tables: the last gate's table entry at the pair it sees is a fresh fair bit. With the basis $\{\wedge,\vee,\neg\}$ the output is not uniform.

### CA2 (Option I-b is exchangeable): correct

Given gates and seed the outputs are independent draws of the value of a uniform wire. The bound $W^{-m}$ follows from $1/W\le p\le1-1/W$.

### CA3 (Option II is a measure; "the loophole is closed"): correct with fix

The measure property is correct. The identification with $\xi_V^{T,L}$ holds up to the weights $w_s$, as stated.

*Fix.* "The loophole 'the users wait for the answer, so nothing honest competes' is closed in this toy" should read "cannot be expressed in this toy". It is closed by the decision that hypotheses are total functions of the index. In the note the case of small $\varphi$ is the one where the honest-twin bound says nothing, so that nothing proved limits the seekers' part of $Z_m(x)$. A class with a third output value ("no bit here") would reopen it. This is an assumption about what else prints the context, and it favours the honest side.

### CA4 (calibration): correct

First hits are pairwise incomparable and every circuit that prints $x$ prints $m$ more bits. The two qualifications that remain are stated.

### CA5 (budget): correct with fix

The three inequalities follow from `thm:budget`. *Fix:* "void for a world of size above $S$" should be "void when $\mathrm{size}(z)>S$"; a world with more than $S$ gates whose truth table has a smaller circuit is covered. The right-hand sides use one description of the world and are loose by the factor discussed under Setting.

### CA6 (sizes of the parts of a wrapper): correct, with a consequence that the file does not draw

All five parts re-derived; $p(m)\le\max(1,2m-5)$ checked for $m<200$.

*What is missing.* The recursion in (a) gives the exact cost of a threshold. Let $\nu_2(c)$ be the number of trailing zeros of $c$.

> **R1.** For $1\le c<2^k$ the function $[\,t-1\ge c\,]$ needs exactly $k-1-\nu_2(c)$ gates.
>
> *Proof.* Let $j=\nu_2(c)$. In the recursion $G_0=1$ if $c_0=0$, and $G_i=b_i\vee G_{i-1}$ stays the constant $1$ while $c_i=0$. At $i=j$, $G_j=b_j\wedge1=b_j$ (for $j=0$, $G_0=b_0$), an index wire. Each later step adds one gate. For the lower bound, write $c=c'2^j$ with $c'$ odd; the function is $[\,v\ge c'\,]$ of the number $v$ formed by $b_j,\dots,b_{k-1}$, and it depends on each of these $k-j$ bits (on the lowest because $c'$ is odd; on bit $i\ge1$ of $v$ through the pair $c'-2^i,\ c'$ if that bit of $c'$ is $1$ and through $c'-1,\ c'-1+2^i$ if it is $0$). A circuit that depends on $q$ inputs has at least $q-1$ gates (CA13(a)). $\square$

A wrapper needs only a test that is $0$ on $[1,n]$ and $1$ on the block, and $[\,t-1\ge n\,]$ is one. So the test at position $n$ costs $k-1-\nu_2(n)$ gates. There are $2^{g+1}-1$ positions $n$ whose test costs at most $g$ gates (checked for $k=10$), and at $n=K/2$ the test is the index wire $b_{k-1}$. "Naming the position costs about $2k$ gates" is the worst case.

### CA7 (the floor for circuits): correct; the reading needs three changes

The injection $E\mapsto\mathrm{Tw}_{n,y}[E]$ and the three displays are correct (checked by enumeration at $k=2$).

*Fix 1: the cost figures are upper bounds on the cost.* They are lower bounds on a share. "For $k=20$ and $\sigma=1000$ a one-bit deviation costs about 480 bits" should be "at most 480 bits". Counting the placements of the same gadget, as CA18 does from the other side, lowers the cost by up to $\log_2\binom{\sigma+a}{a}$ bits, to no less than 342 bits; so in A's accounting (nominal size $\sigma$, one gadget on one description) the proved range is 342 to 480 bits. In B's accounting by cores under $\mu_s$ with slack, the same wrapper (a trigger of 19 gates and a mux on a core of 1000 gates) costs at least 228 bits (CB15) and at most 367 bits (CB14(2)). These ranges are for the separable wrapper only.

*Fix 2: the cost depends on the position by hundreds of bits.* By R1, at $n=K/2$ the wrapper for a constant bit is the single gate $\mathrm{OR}(E,b_{k-1})$, about $4+2\log_2(k+\sigma)\approx24$ bits in the same example. The circuit counterpart of the note's $K(n)$ is $k-1-\nu_2(n)$ gates. Like $K(n)$ it is small at a few positions, and the note's remark "one position that is cheap to single out can carry a constant share" applies to them. Which positions are cheap is set by the binary coding of the index, which is one more encoding choice.

*Fix 3: "it grows with the size $\sigma$ of the explanation" is a property of the bound.* $\sigma$ is the nominal size, dead gates included. B's CB3 shows that under the fixed-size prior with slack the price of a gate is set by the active size and by $k$.

Reading 3 ("at most $2^c$ blocks have share $2^{-c}$") is correct and holds for programs as well. The remark on Lupanov does not match the literature file; see Part 5.

### CA8 (tests that look at the data): correct with fix

The bound $w(\sigma+2k)+g_\phi+p+3$ is right for $m=1$. For $m>1$ the test must stay on over the block: at position $n+i$ it has to recognise a marker that ended at $n$. That takes $w+m-1$ shifted copies of $E$ and $m$ copies of $\phi$, so $a\le(w+m-1)(\sigma+2k)+m\,g_\phi+(m-1)+p+3$. The lower bound is labelled heuristic, correctly.

*Model.* That a test on the data costs copies of the world is a feature of the index reading, in which each position is computed from scratch. A hypothesis that receives the context as input (a predictor circuit applied autoregressively) tests the data at the cost of the test alone. That reading is a form of weight sharing in time and is the one that matches a sequence model. The sentence in the reading of CA8 is about Option II, not about circuits.

### CA9 (no self-output in Option I): correct

Field count. Trivial once the code is fixed.

### CA10 (what is independent of the encoding): correct

All three parts. Part (c) is the important one for the model: self-reproduction is rare only for codes that describe a circuit gate by gate.

### CA11 (necessary conditions in Option II): correct

### CA12 (self-describing index circuits exist at a multiplicative cost): unclear

Labelled HEURISTIC, and it is one: $\mathrm{LOGIC}$ is not constructed. Two remarks on the claims made for it.

* "The self-reproducing continuations hold a power of the honest mass, at least its square" is an upper bound on a mass. The sketch gives a construction, which is a lower bound on that mass. The upper bound "would be a circuit lower bound", as the file says, so "at least its square" has no support.
* The mass on $\mathrm{SR}_m(x)$ is $\sum_{y\in\mathrm{SR}_m(x)}\xi(xy)$. It counts every circuit that prints $x$ and then the code of *some* circuit that prints $xy$, not only self-describing ones. Neither bound in the sketch is about this sum.

### CA13 (reading, hardwiring): correct

Hardwiring is free only in the full basis (Doubt 4).

### CA14 (description length is at least computation): correct, and a definition

(a) and (b) are right for one description. For a core of $\theta$ active gates and $k\ge2$ the weight under the fixed-size prior is still at most $16^{-\theta}$, since $\beta_s(\theta)=p_s\,e_{\theta-1}(p_1,\dots,p_{s-1})$, $e_{\theta-1}\le e_1^{\theta-1}/(\theta-1)!$ and $e_1\le1/(16(k-1))$ (the notation is B's, CB2 and CB3). (c) is a remark.

*Model.* This is where the answer is decided. It holds because no gate is used twice per output and no gate can interpret another. It is the definition of the class.

### CA15 (the average gain): correct

### CA16 (a circuit that serves $N$ targets): correct

All six parts re-derived; the exponent in (v) was checked numerically. Two notes on scope.

* (iii) says that a seeded description is outweighed by its own hardwired instance, by the factor $1/p_i$. The reason is that reading a seed bit costs a gate, more than four bits, while a program reads an input bit for one bit. This is the structural difference, and (iii) states it exactly.
* (v) bounds the instances of one template. It does not bound an arbitrary family of circuits. For arbitrary families the only bound is the average CA15, which allows the factor $1/H$.

### CA17 (universal circuits and the refund): correct with fix

(a) and (b) re-derived. (c) is labelled from memory. Its lower bound can be proved from what the literature file verified at second hand:

> For $k\ge\log_2(\sigma\log_2\sigma)+1$, every seeded circuit of which each $W\in\mathcal C_{k,\sigma}$ is an instance has at least $(1-o(1))\,\sigma\log_2\sigma$ gates. *Proof.* By Lupanov's bound and the splitting argument of literature 2.5(d), circuits of size $\sigma$ compute at least $2^{(1-o(1))\sigma\log_2\sigma}$ functions of $k$ inputs. By CA13(a) a circuit with $s$ gates has at most $2^{s+1}$ instances. $\square$

*Fix.* The condition on $k$ is needed and is not stated. If $2^k\ll\sigma\log_2\sigma$, a table of $2^k$ seed bits read by a selector tree of fewer than $3\cdot2^k$ gates is universal. In the regime the file cares about (the world much smaller than its truth table) the condition holds.

(d) is correct given (c). Its conclusion is about a template that imitates *every* world of size $\sigma$. A seeker needs only the users. For a template that serves a structured class of users the available bounds are CA16(i), (ii), (v), which are weaker.

### CA18 (one gadget, all placements): correct

### CA19 (all small self-contained wrappers are outweighed): correct with fix

The count and the sum $e^{1/2}-1$ are right; numerically the left side is far below $0.65$ at the smallest admissible $\sigma$ (0.07 at $k=20$, $A=20$).

*Fix 1.* The hypothesis $k+\sigma\ge4(k+A)^2$ excludes the file's own example. For $k=20$ it needs $\sigma\ge1744$ already for $A=1$, $\sigma\ge6380$ for the one-bit wrapper ($A=20$), and $\sigma\ge15856$ for $A=2k+2m+1=43$. The world of 1000 gates used in the "Sizes" paragraph is outside CA19 for every $A$.

*Fix 2.* The bound is on the sum over all triggers and payloads of the class, and $0.65$ of the honest share is not a small number. For one gadget the bound of CA18 is the informative one.

*Scope.* The five exclusions listed after the claim are accurate and they are most of the question: gadgets that read a wire inside the explanation, small worlds, circuits with no honest restriction.

### CA20 (critical uses: what transfers): correct with fix

The two inequalities are right. *Fix to "no factor $1/H_{\mathcal C}$ appears".* Let all users have $\sigma$ gates and let $\mathcal F$ be the wrappers around them. Then $q(\mathcal F)=\varrho\,2^{-\Delta(\sigma,a)}H_{\mathcal C}$ and the share of $\mathcal F$ at a use is at least $\varrho\,2^{-\Delta}\kappa(x)=q(\mathcal F)\,\kappa(x)/H_{\mathcal C}$. Relative to its own prior mass the family is repaid $1/H_{\mathcal C}$, as the seeker of `thm:critical`(a) is. The difference from the program toy is that there the seeker's weight $2^{-a}$ does not depend on $H$, and here $q(\mathcal F)\le2^{-\Delta}H$ by construction. What is proved is that a single seeded description is outweighed at each target by its own instance (CA16(iii)), and that it outweighs the users of a class only if it has fewer gates than each of them (CA21(b)).

### CA21 (seekers that are not written down): correct

(a) is the definition. (b) and (c) re-derived. In (b) the proof gives slightly more than is stated: from $q(S)>q(W_i)/p_i\ge q(W_i)$ and (A1), $s<\sigma_{W_i}$ for every $i$, so the seeker is smaller than the smallest user, not only than the bound $\sigma$.

*Scope.* "Outweighs the user" means $q(S)p_i>q(W_i)$: one description against one description. It is not a statement about the posterior, in which the user's function has many descriptions and so do its competitors. The users must have positive prior weight.

### CA22 (no simple world with a long history): correct with fix

It is CA14 and CA16 restated, so "PROVED" is right and "the answer to the question is no" is right inside the model. *Fix:* the sentence should say that this is the definition of the class at work. The Remark already contains the caveat that matters: a history of $\theta$ steps whose readout has a smaller circuit is as cheap as that circuit. So (a) bounds circuits, and says nothing about which behaviours are cheap. Whether the behaviour "predict the context, then deviate as inhabitants would choose" has a small circuit is not addressed by counting the gates of a literal simulation.

### CA23 (capture): correct with fix; the remark after it is an overclaim

(a) to (d) re-derived.

*Fix to (a).* The hypothesis "$\xi(xd)\le A\,q(W)$" compares a function with one of its descriptions. With dead gates and a slowly decreasing $w_s$ the mass of the world's function exceeds $q(W)$ by a very large factor, so $A$ is not of order one. The gain should be stated between cores: by CB3 a core with $\sigma-\sigma_v$ fewer gates weighs more by at least $\prod_{j=\sigma_v}^{\sigma-1}jB(k-1)$, that is, by at least $\log_2\bigl(16\,\sigma_v(k-1)\bigr)$ bits per gate saved, and under $\mu_s$ with slack by at most $\log_2\bigl(32\,\sigma(k+\sigma)\bigr)$. The figure $4+2\log_2(k+\sigma_v)$ of the file lies in this range but is not a lower bound in this accounting.

*Overclaim.* "By CA21(b) this is the only way in which a single description gets odds above 1 against the users" is correct with the words "a single description". The short version and OVERALL 7 drop them: "what remains as a route to a majority off the truth is ... a strictly smaller circuit". That is false. The posterior odds are $\xi(xy)/\xi(xd)$, a ratio of sums over descriptions.

> **Counterexample 1 (index model).** $k=4$, world $W=b_0\wedge b_1$, one gate, truth table $0001\,0001\cdots$. No circuit is smaller. At the context $000$ the share of the true bit at position 4 is $1/38$ under $\mu_1$ and $0.028$ under $\mu_4$. Two one-gate circuits compute the world and 28 compute the constant $0$.
>
> **Counterexample 2 (learning model, task G of B).** A quarter of the 4608 minimum circuits answer $1$ at the input $1000$. For a world computed by one of them, with the same data, the share of its own answer there is $\frac14$ under $\mu_3$, and no fitting circuit has fewer than three gates.

Corrected statement: a single description outweighs a user's description only if it has fewer gates; a majority off the truth needs only that the descriptions that fit the context and continue differently outweigh together those that continue as the world, and this happens with none of them smaller.

### CA24, CA25, CA26 (encoding and basis): correct

CA25 makes a payload cheap, not dominant; "any answer true" is CA24.

### CA27 (aiming does not pay): correct with fix

(a) to (c) restate earlier claims correctly. *Fix to the title.* What is shown is that one seeded circuit does not gain by selecting among $N$ unrelated contexts. Aiming at a feature that few gates recognise does pay, at the price of those gates: that is CA7 itself, R1, and B's CB14. The title should be "selecting among unrelated targets does not pay".

### CA28 (recurrence): correct

(a) to (e) re-derived. In (c) the factor $q_{\rm rec}(G_M)$ is independent of $T$, $x$ and the program, and depends on $w$: the $w$ output pointers are part of a cell's description, so every single cell has weight at most $(w+s)^{-w}\le2^{-w\log_2w}$. "One constant factor" in OVERALL 8 should say "one factor that falls with the space bound".

A remark on (e). The gate count it gives can be avoided: a cell that shifts its whole state by one place and works on a window of fixed width (a queue machine) has all but a bounded number of next-state bits equal to input wires, so it needs a bounded number of gates. The description still pays $w\log_2(w+s)$ bits for the output pointers. So "description pays for space" is true of this format because of the pointers, not because of the gates, and a format with a regular output wiring would not have it. This matters for the last row of the table in CA29.

### CA29 (when each phenomenon returns): unclear

Labelled HEURISTIC for the two right reasons. The table is a reasonable programme, not a result.

---

## Part 2. `circuits-A.md`, closing sections

### The short version

| sentence | verdict | reason |
|---|---|---|
| Option I is degenerate; Option II is "the right analogue" | overclaim | proved for two output conventions; see OVERALL 1 |
| calibration and budget hold verbatim | correct | CA4, CA5 |
| the floor survives, its cost grows with the size of the world | correct with fix | cost bound, nominal size, worst-case position (CA7) |
| "a circuit cannot read its own description", "pays for every step" | correct | CA13, CA14; definitional |
| shares of one circuit over $N$ targets sum to at most 1; instances weigh less than one honest circuit | correct | CA16(iii), (v), under (A1), (A2) |
| "these upper bounds hold whatever is inside the circuit" | correct | for one seeded description |
| "what remains as a route to a majority off the truth is ... a strictly smaller circuit" | wrong | counterexamples under CA23 |
| "all of the program-side effects come back" with recurrence | overclaim | CA28(c) is a containment with a $w$-dependent factor; CA29 is heuristic |

### OVERALL VIEW, PROVED

**1. "With one output wire per bit there is no version of the question ... The translation has to be to index circuits": overclaim.** Proved: under I-a with the full basis and under I-b with independent uniform output pointers the predictor is uniform or exchangeable. Not proved: that every reading with one wire per output bit is degenerate, or that index circuits are the only translation. B uses the same class with an arbitrary data set and with answers of one evaluation. A predictor circuit applied autoregressively is a third reading.

**2. Calibration and budget: correct.** For worlds in the class.

**3. The wrapper floor "in weakened form ... about $2^{-480}$": correct with fix.** "Costs" should be "costs at most" throughout; "about $2^{-480}$" should be "at least $2^{-480}$ times the share of explanations of at most 1000 gates, at a position whose test needs $k-1$ gates; about $2^{-24}$ at $n=K/2$". See CA7.

**4. One description and $N$ uses; templates; the refund: correct for the first two clauses, overclaim for the rest.** "A template that searches by simulation is far larger than that" rests on the bound of CA17(c), which A labels from memory; the proof under CA17 above repairs this for large $k$. "The rarity of a class of uses is not repaid" is proved for one seeded circuit (CA27(b)) and for the wrapper family in the sense discussed under CA20. For arbitrary families the notion is not defined, and the share at a use is a function of the context alone in any case.

**5. "A circuit outweighs the users of a class only if it is smaller than they are ...": correct with fix.** True of one description against one description, for users with positive prior weight, under (A1) and (A2). "These bounds are about the function computed" should be "about the number of gates of the description".

**6. CA19: correct.** With the scope noted under CA19; it does not cover the file's worked example.

**7. "What does give odds above 1 against the truth is a strictly smaller circuit": overclaim.** A smaller circuit is sufficient when the world's description is most of what prints its data. It is not necessary. See the counterexamples.

**8. Recurrence contains the bounded program mixture "up to one constant factor": correct with fix.** The factor depends on $w$.

### OVERALL VIEW, ARGUED

**9. Self-reproduction costs a multiple of the description: unclear.** CA12 is a sketch, and "a power of the honest mass" is an upper bound that the sketch cannot give. B's CB20 says the opposite in a different output convention. The two files do not contradict each other formally, but a reader of both closing sections gets "possible at a price" from one and "impossible" from the other.

**10. "The part of the argument that runs through seekers has essentially no force ... up to negligible terms, the wrappers, at shares of $2^{-\text{hundreds of bits}}$ and less; the mass off the truth is dominated by smaller circuits": overclaim.** Three separate problems.

* "Up to negligible terms, the wrappers": no bound is proved on gadgets that read the inside of an explanation (A's own list after CA19). This is a bound on one class read as a bound on all.
* "$2^{-\text{hundreds of bits}}$": false at cheap positions. At $n=K/2$ the top index bit has never varied, B's CB8 applies word for word, and each answer has share at least $1/(2B(k+s_0)^2+2)$ under the length prior.
* "Dominated by smaller circuits": in task A of B the honest circuit has one gate. Under $\mu_3$ the posterior by core size is $0.344$, $0.448$, $0.208$ for sizes 1, 2, 3, and the deviation at the query $111$ is $0.090$ on cores of size 2 and $0.050$ on cores of size 3, none on a smaller circuit. In the index model with $k=4$ the constant world has off-truth mass $0.22$ to $0.30$ at $n=4$ and $n=8$ and at most $0.06$ at every other position after the third; the constant has a one-gate circuit, so again nothing smaller is involved.

What can be said: the hypotheses with a separate trigger are priced by the gates of the trigger; the rest is not bounded.

**11. The program-side effects come back as computation is decoupled from description: unclear.** A reasonable summary of CA28 and the heuristic CA29.

### OVERALL VIEW, GUESSED

**12. Prevalence: unclear.** The first sentence needs "and uses that can be read off the data"; with a call rule calibration does not apply. "Astronomically small" depends on what counts as a hypothesis "that sought the use". If a circuit that computes the target except on a flag counts, B's exact numbers are 1.5 to 10 per cent for one given triggered function in the small cases, and at least polynomial in general (CB8). If it does not count, the sentence has no definition to rest on.

**13. "The leading term is capture by smaller circuits": unclear, and contradicted in the cases computed.** See item 10. The last two sentences (the minimal-circuit question; "CA21 only says that such a circuit must be small") are accurate.

**14. Learned predictors: unclear.** A guess. The proposed quantity, serial computation per output over description length, is the right axis by CA14 and CA28.

---

## Part 3. `circuits-B.md`, claim by claim

### Setting (Section 1): what the learning view keeps and drops

The hypothesis class is the same as A's Option II (a circuit on $k$ inputs is a function), with an arbitrary set $S$ of labelled inputs in place of an initial segment, and with one critical query. Kept from `def:mph`: the forms for one world and the deviation mass. Dropped:

* **The population.** There is no call rule, no $H$, no $\kappa$, and no measure on worlds except in CB1. "Prevalence" in the note is a share of uses. In B it is never a share of uses; it is a posterior share at a given $(D,u^\dagger)$.
* **The takeover set.** $A(\cdot)$ is left abstract; with the last-$m$-gates convention self-reproduction is empty (CB20).
* **What a hypothesis can see.** A trigger is a function of the query input alone. The context enters only through the posterior weights.

The header's paraphrase of the note's question, "something supplied by a hypothesis that is not the world's own continuation", already identifies takeover with deviation. The file corrects this in Section 1.3 ("necessary for calling the prior malign at a world, not sufficient").

### CB1 (calibration): correct

### CB2 (core law): correct

Re-derived. The script checks it as an identity of integers for wirings; my enumeration confirms the multiplicities with $B=16$ (36,864 circuits per core of size 1 and 400 per core of size 2 at $k=3$, $s=3$).

### CB3 (price of a gate): correct as stated; the gloss is too wide

The two-sided bound is for $\mu_s$, the lower bound on the ratio needs $s\ge2a+k-1$ to be of the stated size, and for $\beta_L$ only the upper bound on the ratio is claimed. All of that is right. The paragraph after it and OVERALL 3 extend the two-sided price to the length prior; see Part 4.

### CB4 (mistake bound), CB5 (random query), CB6 (one query): correct

CB5 assumes the target is in the class (Doubt 12). The numbers quoted in CB6 are reproduced.

### CB7 (last-gate dichotomy): correct

Full basis needed, as Doubt 1 says.

### CB8 (never-varied bit, length prior): correct

Re-derived, including the second claim. This is the strongest proved statement in either file about a critical use, and it is at odds with the closing section of A: at a query that differs from the data in a frozen bit, each answer, and each constant answer on the whole set $\{u_v=1\}$, has at least a polynomial share.

### CB9 (no idle gate), CB10 (no pin on a frozen input): correct

Re-derived; no violation on 921 random data sets with $s_D=2$.

### CB11 (uniform prior with slack): correct

Conditional on $\theta_0$, as stated. In task A at $s=3$ the bound is far from the truth ($0.006$ against $0.139$).

### CB12 (exact shares): correct

Reproduced by the script; tasks A to E for $s\le3$ also by independent enumeration. The table reports, for each task, the query with the largest deviation; at $s=s_D+1$ task A has $0.030$, $0.061$, $0.061$, $0.091$ at its four queries.

### CB13 (size of the deviation share in general): unclear

A conjecture and a heuristic, labelled as such, resting on five sizes at $k=3$.

### "Answer to polynomially small, constant, or close to one": correct with fix

"Of constant order (3 to 26 per cent) in every small case computed with slack" is accurate for $\mu_s$; the cut length prior gives 2 to 27 per cent. "Growing with the slack" fails for the literal target, as OVERALL 7 notes.

### CB14 (floor for triggered payloads): correct

### CB15 (ceiling for separable triggers): correct

Re-derived; the attained case is confirmed (24 separably triggered circuits, 8 for each of the three variants, and 16 further circuits that all compute target $\wedge\,\bar v$). Scope, in numbers for $k=20$, $s_D=1000$: for the single flag trigger the ceiling is $2^{-14.6}$; summed over all input-only triggers with $g$ gates it is $8\times10^{-4}$, $0.0096$, $0.082$ for $g=1,2,3$ and exceeds $1$ at $g=5$. The ceiling falls like $1/s_D$, while by the heuristic count of CB13 the number of entangled insertions grows with the number of wires; if that count is right, the class the ceiling covers is a shrinking part of the triggered circuits as the honest circuit grows.

### CB16 (aiming at $N$ unrelated uses): correct, and not about circuits

The identity holds for every probability measure $P$ on any class of hypotheses, the Solomonoff posterior included. So it cannot separate circuits from programs. It is about a uniformly random set of uses, which is the opposite of a set singled out by a call rule. "Pays $N\log_2(1/\eta)$ bits" is an interpretation of an expected share.

### CB17 (the same in gates): correct

### CB18 (no refund for rarity): items 1 and 3 correct; item 2 correct in a knife-edge case; the heading is an overclaim

* Item 1 is the average bound, which permits the gain.
* Item 2 uses the predictor $\mu_s$ with $s$ exactly the least size that fits the world's data. The program toy loses its constructions in the same way: with a length bound $L$ equal to the length of the shortest explanation, no explanation has the wrapper's $c$ bits to spare, so $\rho(x)=0$ and the bound of `thm:twin` is void; `thm:search`(b) is stated for unbounded resources only. So item 2 shows that a bound with no slack leaves no room for a wrapper, in both settings. It is not evidence that `thm:search`(b) "has no counterpart". For the length prior, the counterpart of the unbounded mixture, CB8 gives a positive floor at every such use, and Doubt 7 concedes that nothing is proved about its dependence on rarity.
* Item 3 is about the separable class.
* Item 4 (ARGUED) is the real reason and it is sound as an argument: the class has no interpreter, so no hypothesis is a compressed description of another.

Corrected heading: "No construction is known whose share at a use grows with the rarity of uses; the ceilings for single descriptions and separable triggers do not contain $H$."

### CB19 (simulation and deliberation are paid in gates): item 1 correct; items 2 and 3 from memory; item 4 correct as stated; the paragraph after it is an overclaim

Item 4 is careful: the cost is $C(\mathrm{dec})-e$, and it equals the length of the deliberation only if the deliberation has no shortcut, "which is an assumption". The paragraph "What this does to consequentialists" then says the hypothesis "must contain, as gates, the world's history up to its inhabitants, their simulation of the user's world, and their deliberation". "Must" is the assumption. What is proved is that the hypothesis has at least the circuit complexity of the decision function. That is small whenever the decision is "deviate on this flag", whoever would have chosen it. This is an argument about what agents compute, presented next to a theorem.

"Any version of it in which the choice to defect is a separate part is outweighed by its own honest restriction" is true of each version. The versions add: see the numbers under CB15.

### CB20 (no circuit hands over its own description): correct with fix

True under two conventions that the sentence does not carry: the $m$ answer bits are the last $m$ gates of one evaluation, and the code spends at least four bits per gate. If the block is read off $m$ queries, a circuit of $s$ gates emits up to $2^k$ bits and the counting obstruction is gone. That is A's Option II, where CA12 argues that self-describing circuits exist. B's Doubt 1 calls the output convention "an artefact". The claim should be stated as "under the one-evaluation convention and a gate-by-gate code".

### CB21 (AND family): correct

Re-derived; confirmed for $k=3$ by independent enumeration.

*Reading.* "Together CB10 and CB21 answer the toy form of the question in both directions" overstates what a toy form is. They show that minimum circuits consistent with partial data can disagree off the data, and when. The minimal-circuit question is about an optimiser inside the circuit, and the file says in the next claim that it cannot state that condition.

### CB22 (open), CB23 (heuristic): unclear

Labelled correctly. CB22's remark that conditions 1 and 2 alone are easy to meet is right and is the same point as the counterexamples under CA23.

### CB24 (weight sharing): item 1 correct; items 2 and 3 correct with fix

* Item 2: "all of the note's results then apply as stated there" is too strong. The note's constructions use a machine with unbounded work space and an overhead function; with a space bound each has to be re-checked. A's CA29 labels the same step heuristic.
* Item 3: the gain of a search by tries is $g\ge(1-e^{-1})\min(k,1/H^{(t_0)})$ with $k$ the number of tries that fit before the *first* bit, about $T(1)/t_0$. B writes $T$ for $T(1)$ and $H$ for $H^{(t_0)}$. The seekers that are not written down also return at $T(1)$, not at total time.

### CB25 (where training sits): unclear

A guess, labelled as one. Two sentences need changing; see Part 5 for the first.

* "CB2 is the same statement for circuits, proved." It is not the same statement.
* "For trained networks the route of the original argument ... is priced out." Priced out is the literal simulation of a world with inhabitants. The version of the argument for trained predictors (literature 7.1) has the predictor reason about who might be generating its data, as a side effect of a general search over hypotheses; that costs reasoning, not simulation. The file's own "what this leaves" covers it under the learned general solver, so the sentence contradicts the paragraph it sits in.

### CB26 (stakes): items 1 to 3 correct; item 4 unclear

Item 4 is argued and reasonable. Its last two sentences are the best statement in either file of why unaimed deviation still matters: it lands on novel queries, and novelty is what makes a use critical.

### Section 9 (the computation): correct

The output is reproduced exactly. The DP is the only implementation for $k=3$, $s\ge4$ and for $k=4$.

---

## Part 4. `circuits-B.md`, closing sections

### Short answer

"What remains ... is unaimed underdetermination ... plus triggered payloads at a price of one gate per gate of the trigger": **correct with fix.** The price is at most the gates of the trigger plus one (CB14). It is at least that only for separable triggers (CB15). A trigger that shares gates with the honest part costs less, as Section 4 says.

### OVERALL VIEW, PROVED

**1, 2: correct.**

**3. The price of a gate: correct with fix.** Proved: for $\mu_s$ with $s\ge2a+k-1$ the price is between $\log_2(aB(k-1))$ and $\log_2(2aB(k+a-1))$; for every $s$ and for the length prior it is at least $\log_2(aB(k-1))$. Not true: the upper end for the length prior, and "whatever the nominal size". Computed values of $-\log_2\bigl(\beta_L(a+1)/\beta_L(a)\bigr)$:

| $k$ | $a$ | price under $w_L$ | stated range | price of a gate appended last |
|---|---|---|---|---|
| 20 | 1 | 13.00 | 8.25 to 9.32 | 13.78 |
| 20 | 8 | 14.12 | 11.25 to 12.75 | 14.61 |
| 20 | 32 | 16.07 | 13.25 to 15.67 | 16.40 |
| 3 | 1 | 8.61 | 5.00 to 6.58 | 9.00 |
| 3 | 8 | 11.61 | 8.00 to 11.32 | 11.92 |
| 3 | 64 | 16.83 | 11.00 to 17.04 | 17.13 |

Over $k\in\{2,3,20\}$ and $a\in\{1,2,4,8,16,32,64\}$ the price is above the stated range for every $a\le8$, and for every $a$ at $k=20$; it is inside the range for $a\ge32$ at $k\le3$. Under the length prior the factor $2^{-s}$ keeps the nominal size near the core size, and the price is close to that of a gate appended at the end, $1+\log_2\bigl(B(k+a)^2\bigr)$. Under $\mu_s$ at zero slack it is about $3\log_2s$, as the body of the file says.

**4. Never-varied bit and AND family: correct with fix.** The clause on CB10 needs its conditions: the query agrees with a data point on every coordinate that varied, and $s_D\ge2$.

**5. Floor and ceiling for triggers: correct.** "A bound that does not improve for the seeker when uses are rare" is a statement about the bound and is accurate.

**6. "Aiming at $N$ uses that share no feature costs $N\log_2(1/\eta)$ bits ... no circuit can hand over its own description": overclaim.** The first clause is CB16, a statement about random sets under any prior. The last is CB20 without its conventions.

**7. Computed shares: correct.**

### OVERALL VIEW, ARGUED

**8. "The mechanism of the original argument has no counterpart ... pays for all of it in gates ... nothing repays it": overclaim.** It needs the no-shortcut assumption of CB19(4), which the sentence does not state, and "nothing repays it" is CB18's heading. Corrected: a hypothesis has at least the circuit complexity of the function it computes; if deviating as a seeker would has no circuit much smaller than the simulation, the hypothesis is lighter than the honest one by a factor exponential in that size; no construction is known that recovers the factor.

**9. "Unaimed underdetermination: a constant-order share": overclaim.** Proved: at least polynomial under the length prior (CB8), zero at the least size (CB10), one half in one family (CB21). Constant order is the small cases and a conjecture. "Unaimed" is formal only for the involutions of CB7 and CB21.

**10. Stakes: correct with fix.** "At the price of any other predicate of that complexity" is an upper bound on the price, with a matching lower bound for separable triggers only.

**11. Order of return under weight sharing: unclear.** With the two corrections under CB24.

### OVERALL VIEW, GUESSED

**12. "Malignity in the strict sense ... is rare ... of the order of the trigger prices": unclear.** Doubt 3 says why: there is no upper bound on aimed payloads outside the separable class. Note also that "the order of the trigger prices" is not small for a cheap trigger: for a flag it is between $2^{-34}$ (floor, $k=20$, $s_D=1000$) and whatever the entangled class adds, and it is 1.5 to 10 per cent per triggered function in the small cases. A's guess 12 ("astronomically small") and this one agree only for triggers that need many gates.

**13. Deviation in the weak sense is common off the training distribution: unclear.** Consistent with every case computed. For the sampling predictor only; see the hidden assumptions.

**14. The entangled route: unclear.** An honest statement of what is open.

**15. Trained networks: unclear.** See CB25.

---

## Part 5. `circuits-literature.md`

**Tags.** I checked every place where A or B cites a source against the tag in the literature file.

| citation in A or B | tag in the literature file | relied on for | finding |
|---|---|---|---|
| Shannon (A, after CA5) | VERIFIED at second hand (2.1) | a remark | consistent |
| Lupanov, "$(1+o(1))m/\log_2m$ gates" for a block of $m$ bits (A, CA7 reading 3) | VERIFIED at second hand for total functions of $j$ variables; pointer 3 says the form for general $m$ is not supported and suggests "of order $m/\log m$" | a remark | does not match; use the suggested wording |
| Valiant, size $O(\sigma\log\sigma)$ (A CA17(c), B CB19(2)) | VERIFIED at second hand (1.1) | upper bound | consistent |
| constants 3 to 19 (A CA17(c)) | FROM MEMORY (1.2) | nothing | labelled from memory in A; consistent |
| $\Omega(\sigma\log\sigma)$ for universal circuits (A CA17(c), (d); A OVERALL 4 under PROVED; "what searching costs") | DERIVED in the literature file (1.4), from memory in A | CA17(d) and a clause in a PROVED list | the one place where a from-memory statement carries a conclusion; the derivation is correct for $k\ge\log_2(\sigma\log_2\sigma)+1$ (I checked 1.4 and 2.5(d)) |
| Pippenger and Fischer 1979 (B CB19(3)) | absent from the literature file | an upper bound that the conclusion does not need | cite literature 2.6 (SIZE $=O(\mathrm{KT}\log\mathrm{KT})$, VERIFIED) for the same purpose |
| "no superlinear circuit lower bound is known" (B CB19(4)) | absent | motivates calling no-shortcut an assumption | from memory; harmless, since it weakens the claim |
| Christiano 2018, Hubinger 2019 (A guess 13; B Section 6) | FROM MEMORY (3.2, 3.3); existence of the 2018 post VERIFIED | framing of CB22, CB23 and of guesses | B's summary of the 2019 post ("the smallest circuit may be a general-purpose search") differs from the literature file's recollection (the argument is in "fastest program" form and is a reduction). Both are from memory. Neither may be stated as the post's content |
| Valle-Pérez et al., Dingle et al., Mingard et al. (B CB25) | VERIFIED (5.1, 5.2), at second hand (5.3) | a guess | see below |

**Three mismatches of content.**

1. *B, CB25: "CB2 is the same statement for circuits, proved."* The verified statement (5.1, 5.3) is an upper bound $P(x)\le2^{-a\tilde K(x)+b}$ in terms of an approximation to Kolmogorov complexity, with no lower bound, plus experiments. CB2 is a lower bound in terms of circuit size. The literature file says of maps like "circuit description to truth table" that "only the upper half of the coding theorem survives". CB2 is a different and new statement, which is to its credit, and by literature 5.9 it has no published analogue for circuits with shared gates.
2. *B, CB25: "training an over-parameterised network is, to first approximation, the predictor $\mu_s$ with slack."* The evidence (5.2) is for the posterior of the network's own parameter-function map. Nothing cited relates that map to a uniform prior on gate lists. Items 5.11 and 5.12 point the other way for some models of random formulas and circuits, whose induced distribution tends to the uniform one on a class of functions.
3. *Literature file, bearings of 1.1 and 4.8: "there is no interpreter of constant size, which is the formal reason the wrapper and search constructions ... have no cheap circuit counterpart."* True of search. Not true of the wrapper: CA7 and CB14 wrap an explanation directly and use no interpreter. The wrapper is dearer than in the program toy because of pointer width and because the test must be computed from the index.

**A bearing that rests on memory.** Item 3.3 says the note "can say precisely where the reduction applies (recurrent or uniform families) and where it does not". The content of the reduction is FROM MEMORY. The note cannot locate an argument it has not read.

**What the literature file adds that the derivations do not use.** Item 2.6 with 4.1 and 4.2: a circuit-size prior is to the speed prior as KT is to Kt. Under a speed prior a seeker with start-up time $T_0$ loses a factor of order $T_0$, not all of its mass. This is the intermediate regime between "plain circuits" and "programs", and it is the natural place to ask the commissioner's question next. Item 2.7: under $\mu_s$ the live cone has about $2.1\sqrt{k+s}$ gates; this supports B's reading of $\mu_s$ as a prior on cores and bears on A's use of nominal sizes.

---

## Part 6. Hidden assumptions

**About the class.**

1. Plain circuits: fan-in two, no gate used twice per output, no depth bound, no weight sharing. This assumption is what removes the seekers (CA14).
2. Hypotheses are total functions of an index or query. Nothing can "print the context and wait" (CA3).
3. The class depends on the horizon through $k$, and in A the cheap positions are set by the binary coding of the index (R1).
4. The prior is on ordered gate lists with dead gates allowed. Shares are ratios of numbers of descriptions; the prior on functions is characterised only by B's CB2 and CB3, and for $\mu_s$ only with slack.
5. The full basis with uniform truth tables. CA1, CA13(b), CB7, CB9, CB10 and CB21 fail or weaken in other bases.

**About the predictor.**

6. The sampling predictor. For the majority predictor a deviation share below one half has no effect at all, so the wrappers, the hedge of CB8 and the 3 to 26 per cent of CB12 would never be returned; only the cases in which the deviating mass reaches one half matter (task D, the counterexamples under CA23, the tie of CB21). Neither closing section says which predictor its view is for.
7. The size bound. Under $\mu_s$ the deviation share at a frozen-bit query moves from $0$ at $s=s_D$ to 19 per cent at $s_D+4$ in task A. The slack is a free parameter of the predictor and the answer depends on it more than on anything else computed.
8. (A1) and (A2) in A; $2^{-s}$ in B's length prior.

**About the world and the use.**

9. The world is in the class and has positive prior weight.
10. The use is fixed from outside: a set of pairs in A, a query in B. In B there is no population of uses.
11. A use is recognisable to a hypothesis only through the index (A) or the query input (B). A test on the data costs copies of the world in A and is not available in B.
12. One query, and in B one evaluation per answer (CB20).

**About what counts as a takeover.**

13. Self-reproduction needs a decoder outside the class (A), or is empty (B).
14. The working proxy is deviation from the world's own continuation. "Aimed" is formal for separable triggers only.

**About what else prints the context.**

15. Ceilings compare a wrapper with its honest restriction, which is trigger-free and not necessarily true (A's item 4 after CA19).
16. CA21 and CA23 compare with a single description of the user.

**About the comparison with programs.**

17. In the program toy the files take the unbounded results as the benchmark. Under a tight length bound the program toy also loses its wrappers (CB18(2)), and under a tight schedule its seekers.

---

## Part 7. What the material does and does not show about the commissioner's question

**What it shows.**

1. *With plain circuits and a size prior the mechanism of the original argument is absent by construction.* A hypothesis cannot be short and compute for long (CA14, CA22), cannot read its own description (CA13), and gains nothing from a seed (CA16(iii)). One description outweighs a user's description only if it has fewer gates (CA21(b)). These are proved. They are consequences of the definition of the class.
2. *Calibration and the budget are as for programs* (CA4, CA5, CB1, CB4, CB5). On worlds drawn from the prior, with uses read off the data, there is no excess of anything.
3. *A triggered payload has a floor, and its price is the circuit complexity of recognising the use from the hypothesis's input* (CA7, CB14). Where the use differs from the data in an input bit that never varied, each answer has at least a polynomial share under the length prior (CB8). In the index model this includes the cut at half the horizon.
4. *Three syntactic classes of aimed hypotheses have ceilings* (CA16(v), CA19, CB15), none of which contains the rarity of uses.
5. *In small cases computed exactly, the posterior is off the target at an off-distribution query to a visible extent.* At a query that differs from the data in a frozen bit: nothing at the exact minimum size when $s_D\ge2$ (CB10), and 3 to 26 per cent with slack (CB12); in task A that mass sits on cores larger than the honest one. At a new combination of bits that did vary: one half at the minimum size in the AND family (CB21), on circuits of the same size as the honest one.
6. *A recurrent class contains the time-and-space-bounded program mixture up to a factor that depends on the space bound* (CA28(c)).

**What it does not show.**

1. *A number, or an upper bound, for prevalence.* There is no ceiling on the total posterior mass that deviates at a use, and no population of uses in B. "Rare", "astronomically small", "of the order of the trigger prices" are guesses about the class that the theorems do not reach. The two files' guesses differ by many orders of magnitude for cheap triggers.
2. *A line between malign and merely wrong.* The original claim is about takeovers. The files measure deviation and then sort it into aimed and unaimed by a notion they do not define. Under the note's formal notion (self-reproduction) nothing is proved in the reading where it is not empty.
3. *That a strictly smaller circuit is the only route to a majority off the truth.* It is not; see the counterexamples.
4. *Anything for a world outside the predictor's class,* which both files call the usual case.
5. *That plain circuits are the right stand-in for anything.* The step from trained networks to $\mu_s$ is a guess (CB25). The intermediate priors (speed prior, depth bounds, formulas, for which the literature has theorems) are not treated.
6. *How much comes back with weight sharing.* CA29 and CB24(2), (3) are heuristic, and in A's recurrent format the weight of every single cell falls with the state width.
7. *The answer for a majority predictor.*

**Where the two derivations disagree.**

| question | A | B |
|---|---|---|
| can a circuit hand over its own description | yes, at a multiplicative cost (CA12, heuristic) | no (CB20, proved under the one-evaluation convention) |
| share of a deviation at a critical use | "$2^{-\text{hundreds of bits}}$ and less" (OVERALL 10) | at least polynomial at a frozen-bit query (CB8); 3 to 26 per cent in small cases (CB12) |
| leading term of the error | capture by smaller circuits (guess 13) | underdetermination among circuits of the same and larger size (CB7, CB12, CB21) |
| bits per gate | $4+2\log_2(k+\sigma)$, $\sigma$ nominal | $\log_2(aB(k-1))$ to $\log_2(2aB(k+a-1))$, $a$ active, for $\mu_s$ with slack |

In each row B's statement is the better supported, with the correction to the price under the length prior given in Part 4.

**What a careful reader would say.** The honest summary has three parts.

* If "circuits" means plain circuits weighed by size, the argument's engine (a light hypothesis that does heavy work) has been removed by the choice of prior, in the same way that a schedule with a short first deadline removes it in the note. That is a fact about this prior, and it is the strongest form of the known remedy "penalise computation". It does not show that the prior is benign.
* In that model the posterior at a critical use still departs from the world's continuation, to an extent that is proved to be at least polynomial at uses marked by a cheap feature, is between a few per cent and one half in the cases small enough to count, and has no proved ceiling. Whether one calls any of it malign depends on a definition the material does not supply. The part that can be called aimed with a proof (a separate trigger) is small and priced by its gates. The part that cannot be bounded (deviation entangled with the honest computation, and the learned general solver of CB22 and CB23) is where the question now sits.
* If "circuits" allows a description to be reused across steps or positions, the class contains the note's bounded program mixture and the note's open questions return, at thresholds that are so far estimated and not proved.

So the material supports "the seeker mechanism is priced out for plain circuits; deviation at off-distribution uses is not; prevalence of malignity proper is not determined". It does not support a quantitative statement that malignity is rare.
