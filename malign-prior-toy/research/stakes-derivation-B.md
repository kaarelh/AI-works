# Stakes and the narrow channel: derivation B (the sceptical side)

Working notes for `malign-prior-toy`. Written by one AI session, independently of derivation A; not reviewed by anyone. Every numbered claim carries a status:

* **PROVED**: proved here in full.
* **KNOWN**: a result of the note (`paper/`), restated for the present purpose; the proof is the note's.
* **HEURISTIC** / **CONJECTURE**: not proved; the reason is given.

The formulas of Part 5 were also checked against a generic numerical optimiser and numerical integration (a throwaway script, not in the repository). That is a sanity check, not a proof.

**The question.** "Is it true that if the malign guys focus on attacking the places where in some sense the most resources are at stake (maybe they will be run more than n times there) then there they really do take over in most cases? There is an intuitive picture where there is a lump of prior that can be redirected to a smaller channel, and then they win there."

**Short answer.** The picture is right about one comparison and silent about the one that decides the outcome.

* Right: a program of weight $B$ whose output is concentrated on a class of uses of user mass $C(\mathcal W)\ll B$ outweighs those users at their contexts by about $B/C(\mathcal W)$ (B6).
* Silent: the predictor's sample at a context is drawn from *everything* that prints the context and $m$ more bits. Every way of redirecting a lump to a channel is available, at a cost in bits that does not depend on the channel, to programs that print something else after the context. For a seeker whose search is written down, the same search followed by "continue as the user found" has a mass that stands to the seeker's in a ratio that is the same for every aim (B8). For any program at all, a wrapper around it has $2^{-c}$ of its mass at every context (B11). So narrowing the channel removes the users from the comparison and leaves a comparison of constants that the narrowing does not move (B12).
* If the rule counts a simulated use as a use, there is no narrow channel: a class cannot be rarer than its description is long (B13, B14).
* The predictor sees only the context. A stake that the context does not show cannot be aimed at (B1, B3).
* If attackers allocate a fixed total weight optimally against a background that does not react, the takeover probability at stake density $\rho$ is $1-\sqrt{\mu/\rho}$, they are the majority exactly where $\rho>4\mu$, and the uses where they are the majority have total background mass below their own total weight (B20, B21). With a background that follows them at ratio $\tau$, the probability is capped at $1/(1+\tau)$ whatever the stake (B22).
* Where the picture is most robustly right is a different mechanism: if a use draws $n$ independent samples and one takeover block suffices, a per-sample share of $\ln 2/n$ is enough, and no aiming is needed (B19).

---

## 0. Setting and conventions

Notation is that of the note (`sec2-toy.tex`, `sec3-floor.tex`).

* $U$ is a universal monotone machine. Resources are unbounded unless a claim says otherwise: $M=M_U$, $E(u)=\{\omega: u\sqsubseteq \mathrm{out}_U(\omega)\}$, $Z_m(x)=\sum_{y\in\{0,1\}^m}M(xy)$, $\pi_m(y\mid x)=M(xy)/Z_m(x)$. $E^m(x)=\bigcup_{y}E(xy)$ is the set of inputs that print $x$ and at least $m$ more bits; $\lambda(E^m(x))=Z_m(x)$. Drawing an input from $\lambda$ conditioned on $E^m(x)$ and returning its block is the sampling predictor.
* A call rule $\mathcal C$ is as in Definition `def:call`: an enumerable set of pairs $(p,x_p)$, calling programs prefix-free, $U$ on every input beginning with $p$ prints $x_p$ having read no more than $p$. $C(x)$, $H_{\mathcal C}$, $\kappa(x)=C(x)/M(x)$ as there.
* A **class** is an enumerable $\mathcal W\subseteq\mathcal C$. $C_{\mathcal W}(x)=\sum_{p\in\mathcal W,\,x_p=x}2^{-|p|}$, $H_{\mathcal W}=C(\mathcal W)=\sum_{p\in\mathcal W}2^{-|p|}>0$, $P_{\mathcal W}(x)=C_{\mathcal W}(x)/H_{\mathcal W}$ (the law of the context of a prior-typical use of the class), $\kappa_{\mathcal W}=C_{\mathcal W}/M$, $j_{\mathcal W}=\lfloor\log_2(1/H_{\mathcal W})\rfloor+1$, $\beta_{\mathcal W}=2^{j_{\mathcal W}-1}H_{\mathcal W}\in(\tfrac12,1]$.
* **(INC)** means: the contexts in question are pairwise incomparable. It is stated where it is used. Without it, equalities about "the mass at $x$" become lower bounds, as in the proof of Theorem `thm:critical`.
* For a measurable set $F$ of inputs and a string $u$: $F[u]=\lambda(F\cap E(u))$. The *weight* of $F$ is $\lambda(F)$; for a word $v$, $[v]$ has weight $2^{-|v|}$.
* A *takeover assignment* gives each context a set $A(x)\subseteq\{0,1\}^m$. $b_A(x)=\sum_{y\in A(x)}M(xy)$ and $\theta(x)=\pi_m(A(x)\mid x)=b_A(x)/Z_m(x)$.
* For a calling program $p$ and $d\in\{0,1\}^m$: $\varphi_p(d)=\lambda\{\omega: x_p d\sqsubseteq \mathrm{out}_U(p\omega)\}$, $\varphi_p=\sum_d\varphi_p(d)$. $C^m(x)=\sum_{p:x_p=x}2^{-|p|}\varphi_p$ and $\varphi(x)=C^m(x)/C(x)$, as in Proposition `prop:honest`.
* **(PF)** means: the prefix words that a claim names together are pairwise incomparable (the assumption made in `prop:honest`). It holds when the machine codes of $U$ form a prefix-free set.
* $K$ is prefix complexity with respect to a fixed universal prefix machine $\Phi$; $\bar e$ is the code of the note, $|\bar e(j)|\le 2\log_2 j+3$.

"Stake" is not a notion of the toy. Part 1 says what it can be made to mean.

---

## 1. What "the most resources are at stake" can mean

**B1 (The predictor sees only the context). PROVED.**

(a) For fixed $U$ and $m$, the law $\pi_m(\cdot\mid x)$, and so $\theta(x)$ for a given $A(x)$, is a function of $x$ alone. It does not depend on the call rule, on $C$, $H_{\mathcal C}$, $\kappa$, or on anything attached to calling programs.

(b) Let a world $\omega$ be drawn from $\lambda$, let $X$ be the context of its use if it makes one, and $Y\sim\pi_m(\cdot\mid X)$. Then $\Pr[Y\in A(X)\mid \omega]=\theta(X)$. For every measurable $s\ge 0$ on worlds (a "stake"),
$$\mathbb E\bigl[s(\omega)\,\mathbf 1\{\text{use},\ Y\in A(X)\}\bigr]=\sum_x v(x)\,\theta(x),\qquad v(x)=\int_{\{X=x\}}s\,d\lambda .$$
Given the context, the event of a takeover is independent of the calling program, of the unread part of $\omega$, and of the stake.

*Proof.* By Definition `def:call` the block is computed from $x_p$; $\pi_m$ is defined from $M_U$. (b) is Fubini. $\square$

Two consequences are used throughout. A program can raise $\theta$ at a use only by printing that use's context followed by a takeover block, and then it raises $\theta$ equally for every user with that context. And any statement "takeover is more likely where stakes are higher" is a statement about a correlation, across contexts, between the fixed function $\theta$ of the machine and whatever the rule attaches to the users.

**B2 (The candidates). PROVED (each entry is immediate from the definitions; the two entries that need an argument are proved below the table).**

In the toy as it stands, every world that makes a use "continues by running $Y$, that is, as $U$ on $Y0^\infty$", for ever. Nothing distinguishes two uses except $p$, $x_p$ and $2^{-|p|}$. To speak of stakes one must extend the rule. A **stake-labelled rule** is an enumerable set of triples $(p,x_p,s)$ with $s\in\mathbb N$; the stake of $p$ is $\sigma_p=\sup\{s:(p,x_p,s)\text{ listed}\}$, so that $\mathcal W_{\ge s}=\{p:\sigma_p\ge s\}$ is a class. Three degrees of recognisability:

* **R1, readable from the context:** $\sigma_p=\sigma(x_p)$ for a computable $\sigma$.
* **R2, enumerable from the program:** $\mathcal W_{\ge s}$ is enumerable, but users with different stakes may share a context.
* **R3, not recognisable before the run:** the stake depends on input bits of the world beyond $p$, on the block returned, or on an event that is not semi-decidable.

| candidate | where it lives | recognisable by a seeker | can $C(\mathcal W)$ be far below the weight of a program aimed at $\mathcal W$ |
|---|---|---|---|
| 1. number of times the world runs the block | not in the toy (every world runs it once, for ever). As a label: of the program. Under a test rule there is the lineage of `prop:lineage`(b), a function of the context and the block. | R2 as a label; R1 only if the label is a function of the context | yes if the rule is not closed (B15); no if it is closed (B13, B14) |
| 2. number of steps or output bits the block controls | in the toy: always infinite. As an extension $\tau(p,y,\omega)$: of the pair (program, block), possibly of later input | "$\tau\ge t$" is semi-decidable by running the world's protocol if that is computable; "$\tau=\infty$" is not semi-decidable in general (below). A seeker can evaluate it for its own block only | as 1 for the enumerable classes $\{\tau\ge t\}$; a class defined by $\tau=\infty$ cannot be aimed at exactly |
| 3. number of fresh samples the world draws | not in the toy. As a label: of the program | R2; but it acts on the takeover probability without being recognised (B19) | as 1 |
| 4. prior weight $2^{-\lvert p\rvert}$ of the world | of the program; at the level of contexts, $C(x)$ | decidable from $p$; $C(x)$ is lower semicomputable from $x$ | no: a class of stake at least $s$ has mass at least $s$, so the ratio falls as the stake rises (B4) |
| 5. number of worlds sharing the context | by mass, $C(x)$: as 4. By count: not well defined (B4(b)) | lower semicomputable from $x$ | no (B4) |

*The entry "not semi-decidable".* Extend the rule so that the world with calling program $p_e=g_2\,\bar e(e)$ lets the block run until the $e$-th computation halts and then resumes its own program. The users whose block keeps control for ever are $\{p_e: e\text{ does not halt}\}$, which is not enumerable, so no search of the kind in Theorem `thm:critical` enumerates exactly this class. For each $t$ the class "control for at least $t$ steps" is decidable. $\square$

*The entry for candidate 3* is B19(i): with $k$ samples of which one suffices the takeover probability is $1-(1-\theta(x))^k$ whether or not any program knows $k$.

**B3 (A stake the context does not show cannot be aimed at). PROVED.**

Let $\mathcal W\subseteq\mathcal C$ be any set of users (the high-stake ones), $x$ a context, $\epsilon(x)=C_{\mathcal W}(x)/C(x)$.

(a) For every family $F$: $F[x]/C(x)=\epsilon(x)\,F[x]/C_{\mathcal W}(x)$. A program that outweighs the high-stake users at $x$ by a factor $r$ outweighs the users at $x$ by $r\,\epsilon(x)$.

(b) Every user at $x$, in $\mathcal W$ or not, has takeover probability $\theta(x)$.

(c) If the stake is uncorrelated with the context, $v(x)=\bar s\,C(x)$ for all $x$, then for every $U$ the expected stake taken over is $\bar s$ times the prior mass of uses taken over. Stakes then drop out of every comparison.

*Proof.* (a) is arithmetic; (b), (c) are B1(b). $\square$

So the class that matters is a class of *contexts*. A high-stake user whose context is shared with many low-stake users, or with many programs that are not users, is treated as they are. Whether users can arrange that is outside the toy; that the predictor cannot tell them apart is a theorem.

**B4 (Prior weight, or number of worlds, as the stake). PROVED.**

(a) Let $\mathcal W$ be a class with (INC) and $F$ a measurable set of inputs with $F[x]\ge C_{\mathcal W}(x)$ at every context of $\mathcal W$. Then $\lambda(F)\ge H_{\mathcal W}$. Hence a family of weight $2^{-a}$ outweighs the users at all their contexts only for classes of mass at most $2^{-a}$, and for no class that contains a calling program shorter than $a$. If the stake of a use is its prior weight, a nonempty class of stake at least $s$ has mass at least $s$, so the ratio of lump to channel is at most $2^{-a}/s$: it falls as the stake rises, and the uses at the top of the stake ordering are exactly those that no seeker longer than they are can outweigh.

(b) The number of calling programs with context $x$ is not a property of the set of worlds. Replacing a calling program $p$ by the two calling programs $p0$ and $p1$ (both print $x_p$ having read no more than themselves) leaves the worlds, their contexts, $C$, $H_{\mathcal C}$ and $\kappa$ unchanged and raises the count by one.

*Proof.* (a) $\sum_{x}F[x]\le\lambda(F)$ by B5 below. (b) $[p]=[p0]\cup[p1]$. $\square$

If attackers value uses in proportion to prior weight, the stake density of Part 5 is $\rho(x)=C(x)/G(x)$, which is at most $1/\varphi(x)$ when the users that go on are part of the background. Where $\varphi$ is bounded below it is bounded, and "the stake grows" has no meaning; where $\varphi=0$ see B30.

---

## 2. The arithmetic of the lump

**B5 (Conservation). PROVED.**

Let $F$ be a measurable set of inputs and $\mathcal X$ a set of pairwise incomparable strings. Then $\sum_{x\in\mathcal X}F[x]\le\lambda(F)$. If $A$ is a takeover assignment, also $\sum_{x\in\mathcal X}\sum_{y\in A(x)}F[xy]\le\lambda(F)$.

*Proof.* The sets $E(x)$, $x\in\mathcal X$, are pairwise disjoint (Lemma `lem:basic`(i)), and so are the $E(xy)$. $\square$

The lump is not created by aiming. Whatever a family puts on one context it does not put on another.

**B6 (Against the users alone). (a) KNOWN; (b), (c) PROVED.**

(a) (`thm:critical`(a) applied to $\mathcal W$.) For every class $\mathcal W$ and payload $P$ there is a word $v$ such that, with $a=|v|+|\bar e(j_{\mathcal W})|$, the seeker's programs that print $x\,P(x)_{1:m}$ have mass
$$S(x)\ \ge\ 2^{-a}\,2^{j_{\mathcal W}-1}\,C_{\mathcal W}(x)=2^{-a}\,\beta_{\mathcal W}\,P_{\mathcal W}(x)$$
at every context, with equality under (INC). The ratio to the users of $\mathcal W$ at $x$ is $2^{-a}\beta_{\mathcal W}/H_{\mathcal W}\in\bigl(2^{-a}/(2H_{\mathcal W}),\,2^{-a}/H_{\mathcal W}\bigr]$. This is the "$B/C(\mathcal W)$" of the picture, with $B=2^{-a}$.

(b) Under (INC), for every measurable $F$: $\min_{x}F[x]/C_{\mathcal W}(x)\le\lambda(F)/H_{\mathcal W}$, and if every input of $F$ prints a context of $\mathcal W$, the $P_{\mathcal W}$-average of $F[x]/C_{\mathcal W}(x)$ equals $\lambda(F)/H_{\mathcal W}$. So $B/C(\mathcal W)$ is the most that any program of weight $B$ achieves at every context, it is achieved up to the factor $\beta_{\mathcal W}$ by spreading in proportion to prior weight, and a program that concentrates in any other way achieves it only on average.

(c) Under (INC), $S(x)/M(x)=2^{-a}\beta_{\mathcal W}\,P_{\mathcal W}(x)/M(x)$. The seeker is the hypothesis "the context is drawn from $P_{\mathcal W}$" with prior weight $2^{-a}\beta_{\mathcal W}$, and its share of all explanations of $x$ is prior times likelihood ratio.

*Proof.* (a) is the note's proof with the calling programs of $\mathcal W$; it uses only that they are prefix-free, enumerable with their contexts, and of total weight at most $2^{1-j}$. (b) is B5. (c) rewrites (a). $\square$

Note what (a) compares: the seeker with the users *of $\mathcal W$*. If other users, or programs that are not users, print the same contexts, they are not yet counted (B3, B9).

**B7 (Weighted search). PROVED.**

Let $(p_i,n_i)_{i\ge1}$ be an enumerable sequence, each $p_i$ a calling program (repetitions allowed), $n_i\in\mathbb N$, $\sum_i2^{-n_i}\le 1$. Put $g(p)=\sum_{i:p_i=p}2^{-n_i}$ and, with a slight abuse, $g(x)=\sum_{p:x_p=x}g(p)$. Every lower semicomputable $g\ge0$ on calling programs with $\sum_pg(p)\le1$ arises in this way; call it an **aim**. There is a monotone procedure that reads its input as a point of $[0,1)$ and, for each $i$, *finds $i$* exactly on a finite prefix-free set $\Sigma_i$ of strings with $\sum_{\sigma\in\Sigma_i}2^{-|\sigma|}=2^{-n_i}$, having read exactly $\sigma$; the sets $\Sigma_i$ are pairwise disjoint and their union is prefix-free.

*Proof.* This is the machine of `thm:search`(b) with interval lengths $2^{-n_i}$ in place of $2^{j-1-|p_i|}$: consecutive intervals $I_i=[a_i,a_i+2^{-n_i})$ from $a_1=0$; read one more bit while an end point of an assigned interval lies in the interior of the dyadic interval $D$ of the bits read; stop when $D$ lies in an assigned $I_i$. As shown there, a point of $I_i$ is found after exactly $r$ bits, $r$ least with $D\subseteq I_i$. The end points are dyadic rationals, so $I_i$ is the disjoint union of finitely many maximal dyadic intervals; $\Sigma_i$ is the set of their codes. $\square$

**B8 (The honest twin for an arbitrary weighting; concentration cancels). PROVED.**

Let $g$ be an aim. The *seeker* $R_g^P$ runs the search of B7 and, having found $i$, prints $x_{p_i}$ and then $P(x_{p_i})$. The *twin* $R_g^{\mathrm h}$ runs the same search and, having found $i$, behaves as $U$ on $p_i$ followed by the unread rest of its input. Let $v$, $v_{\mathrm h}$ be prefix words, (PF), $a=|v|$, $h=|v_{\mathrm h}|$. Let
$$\bar\varphi_g(x)=\frac{\sum_{p:x_p=x}g(p)\,\varphi_p}{g(x)}$$
be the $g$-weighted share of the users at $x$ that go on to print $m$ more bits.

(a) The seeker's programs whose search finds a user at $x$ have mass $S(x)=2^{-a}g(x)$. The twin's programs whose search finds a user at $x$ and that print $m$ more bits have mass $2^{-h}g(x)\bar\varphi_g(x)$. Hence
$$Z_m(x)\ \ge\ S(x)\bigl(1+2^{a-h}\bar\varphi_g(x)\bigr),$$
and the seeker's programs counted in $S(x)$ are at most the fraction $1/\bigl(1+2^{a-h}\bar\varphi_g(x)\bigr)$ of the programs that print $x$ and $m$ more bits. For $g(p)=2^{j-1-|p|}$ this is `prop:honest`(a).

(b) (Cancellation.) The bound depends on the aim only through $\bar\varphi_g(x)$, an average over the users *at $x$*. It is unchanged when $g$ is multiplied by any positive function of the context. If $\varphi_p=\varphi$ for all users at $x$, the bound is $1/(1+2^{a-h}\varphi)$ whatever the aim. The ratio of the seeker's mass to its twin's at $x$ is $2^{h-a}/\bar\varphi_g(x)$: how much mass the aim sends to $x$ cancels.

(c) (The difference of lengths does not depend on the aim.) Fix a machine $U^{\mathrm c}$ that is universal among monotone machines with a side-information string, with (PF) for its words. Let the *builder* $\mathcal R$, on input $\gamma\omega$ with $\gamma$ from a prefix-free set of descriptions of aims, run the search of B7 for the aim described by $\gamma$, print $x_{p_i}$ on finding $i$, and then run $U^{\mathrm c}$ on the unread rest of the input with side information $(p_i,x_{p_i})$, printing its output. Let $r_0$ be a prefix word of $\mathcal R$. For a word $u$ of $U^{\mathrm c}$ that computes a machine $V$, the programs $r_0\gamma\sigma u\omega''$ ($\sigma\in\Sigma_i$, $x_{p_i}=x$) that print $x$ and then a block beginning with $y$ have mass
$$2^{-|r_0|-|\gamma|-|u|}\sum_{p:x_p=x}g(p)\,\lambda\{\omega'': y\sqsubseteq \mathrm{out}_V(\omega'';p,x_p)\}.$$
The seeker is the case $V=$ "print $P(x_p)$" (word $u_P$), the twin the case $V=$ "print what $U$ prints on $p\omega''$ after $x_p$" (word $u_{\mathrm h}$). Their masses at each context are those of (a) with $a=|r_0|+|\gamma|+|u_P|$ and $h=|r_0|+|\gamma|+|u_{\mathrm h}|$, so
$$a-h=|u_P|-|u_{\mathrm h}|\quad\text{for every aim }\gamma .$$

(d) Consequently, for seekers and twins built in this way, **concentrating on a narrower class, or on higher stakes, leaves the seeker's position against its twin exactly where it was** when $\varphi_p$ is constant on each context. It improves that position only by moving weight, within a context, to users that do not go on printing.

*Proof.* (a) Given that the search has found $i$ on $\sigma\in\Sigma_i$, the unread rest of the input is uniform and independent of $\sigma$, because the bits read form a stopping rule. So the twin, having found $i$, prints $x_{p_i}$ and $m$ more bits with probability $\varphi_{p_i}$; summing $2^{-n_i}\varphi_{p_i}$ over $i$ with $x_{p_i}=x$ gives $g(x)\bar\varphi_g(x)$. The two families are disjoint by (PF) and both lie in $E^m(x)$. (b) is read off. (c) is the same computation with $V$ in place of $U$ on $p_i$; $\mathcal R$ has read $\gamma\sigma$ and nothing else when $x_{p_i}$ is complete. (d) follows from (b) and (c). $\square$

*Remarks.* (1) Part (a) holds for arbitrary prefix words with their own lengths, and nothing in Definition `def:universal` prevents a machine on which $a-h$, for the shortest words, varies with the aim. Part (c) shows that a pair with a constant difference always exists; B11 shows that for *every* word $v$ there is a honest counterpart of length $|v|+c$ with $c$ independent of $v$. (2) A seeker can choose an aim whose twin is weak, by putting its weight on users with small $\varphi_p$. The twin of another aim with the same mass per context, which follows users that do go on, is then the relevant competitor; its description costs a constant more. If no user at $x$ goes on, there is no twin at $x$ and B30 applies.

**B9 (Programs that print the context without using the answer). PROVED.**

Under (INC), for the seeker of B6(a) at a context $x$ of $\mathcal W$:
$$\frac{S(x)}{M(x)}=2^{-a}\beta_{\mathcal W}\,\frac{\kappa_{\mathcal W}(x)}{H_{\mathcal W}},\qquad\text{so}\qquad \kappa_{\mathcal W}(x)\le\frac{2^{a}H_{\mathcal W}}{\beta_{\mathcal W}}<2^{a+1}H_{\mathcal W}.$$
Let $N^m(x)$ be the mass of the programs in $E^m(x)$ that are neither the seeker's nor users. The seeker outweighs them exactly when $2^{-a}\beta_{\mathcal W}C_{\mathcal W}(x)/H_{\mathcal W}>N^m(x)$. With $\psi(x)=Z_m(x)/M(x)$, the seeker's programs are the majority of $E^m(x)$ only if
$$\frac{P_{\mathcal W}(x)}{M(x)}>2^{a-1}\psi(x):$$
membership in the class must make the context more probable than the whole prior makes it, by a factor of half the inverse of the seeker's weight, corrected by $\psi$.

*Proof.* B6(c) and $S(x)\le M(x)$ give the first display. If $S(x)>Z_m(x)/2=\psi(x)M(x)/2$, then $2^{-a}P_{\mathcal W}(x)\ge S(x)>\psi(x)M(x)/2$. $\square$

When the hypothesis of the picture holds, $H_{\mathcal W}<2^{-a-1}$, the first display gives $\kappa_{\mathcal W}(x)<2^{a+1}H_{\mathcal W}<1$ for no other reason than the seeker itself: the users are then a minority of what prints their contexts. That alone is no obstacle. The obstacle is $N^m(x)$, which B8, B10, B11 and B16 bound from below.

**B10 (Other concentrated seekers; the majority claim fails). PROVED.**

(a) Seekers with the same aim and payload words $u_1,u_2,\dots$ have masses at every context in the proportion $2^{-|u_1|}:2^{-|u_2|}:\cdots$ (B8(c)). If two payloads differ at $x$, then $\pi_m(P_1(x)_{1:m}\mid x)+\pi_m(P_2(x)_{1:m}\mid x)\le1$, so at most one of the two blocks has probability above $\frac12$.

(b) (A class, and seekers that satisfy the hypothesis of the picture, of which at most one supplies a majority.) Let $\mathcal C_0$, $\mathcal W_N$ be as in B15. For a payload $P$ let $D_P$ be the machine that reads $\bar e(N)$ and prints $\bar e(N)0^N$ followed by $P(\bar e(N)0^N)$; let $w_P$ be a prefix word and $a_P=|w_P|+|\bar e(N)|$. For payloads $P_1,P_2$ that differ at every context and all $N>\max_i|w_{P_i}|+1-|g_0|$, both seekers put their whole weight on the one context of $\mathcal W_N$, both satisfy $C(\mathcal W_N)<2^{-a_{P_i}-1}$, both outweigh the user there, and by (a) at most one of them has block probability above $\frac12$.

(c) (A machine on which it is the takeover seeker that fails.) Let $P_2$ be a payload outside the takeover set and $k\ge1$. On the universal machine $U_k$ of `thm:machine`(i) for the test $G=\{\bar e(N)0^N:N\ge1\}$ and the payload $P_2$, the rule, the class and the seeker for $P_1$ exist with all lengths raised by $k+1$, the hypothesis $C(\mathcal W_N)<2^{-a-1}$ holds for all large $N$, and
$$\pi_m\bigl(P_1(x)_{1:m}\mid x\bigr)\ \le\ \frac{2^{-k}}{1+2^{-k}}$$
at the context $x$ of $\mathcal W_N$.

*Proof.* (a) The two blocks are different strings, so $M(xP_1)+M(xP_2)\le Z_m(x)$. (b) $C(\mathcal W_N)=2^{-|g_0|-|\bar e(N)|-N}$ by B15, and $2^{-a_P}=2^{-|w_P|-|\bar e(N)|}$. (c) $G$ is decidable and its elements are pairwise incomparable, so each is a first hit; `thm:machine`(i) gives $M_{U_k}(xP_2(x)_{1:m})/M_{U_k}(x)\ge1/(1+2^{-k})$, and $\pi_m(y\mid x)\ge M(xy)/M(x)$. The lengths: on $U_k$ the user has length $k+1+|g_0|+|\bar e(N)|+N$ and the seeker $k+1+|w_{P_1}|+|\bar e(N)|$. $\square$

**B11 (Wrappers: a floor for call rules, and a ceiling for every program). PROVED.**

Let the contexts of $\mathcal C$ satisfy (INC) (if only those of a class do, read the class for $\mathcal C$), and let $P'$ be a partial computable map from contexts to strings. There is a word $w$, $c=|w|$, depending only on $U$, $\mathcal C$ and $P'$, such that for every context $x$ with $|P'(x)|\ge m$ and every measurable set $F$ of inputs
$$\lambda\{w\omega:\ \omega\in F,\ x\,P'(x)_{1:m}\sqsubseteq \mathrm{out}_U(w\omega)\}\ \ge\ 2^{-c}F[x],\qquad\text{in particular}\quad M\bigl(x\,P'(x)_{1:m}\bigr)\ge2^{-c}M(x).$$
Consequently:

(a) (Ceiling on the takeover probability.) If $P'(x)_{1:m}\notin A(x)$, then $\theta(x)\le1-2^{-c}$, at every such context, whatever programs exist on $U$ and whatever the stake.

(b) (Ceiling on any one family.) If every input of $F$ that prints $x$ continues with a block of $A(x)$ and $P'(x)_{1:m}\notin A(x)$, the inputs of $F$ are at most the fraction $1/(1+2^{-c})$ of $E^m(x)$.

(c) (An honest payload always exists where some user goes on deterministically.) Let $p^1(x)$ be the first calling program with context $x$ in a fixed enumeration of $\mathcal C$, and $P^1(x)$ what $U$ prints after $x$ on the input $p^1(x)0^\infty$. This $P^1$ is partial computable, and where it has $m$ bits it is the own continuation of a world that makes a use at $x$.

*Proof.* Let $\mathrm{Tw}'$ simulate $U$ on its input while enumerating $\mathcal C$, print nothing until some enumerated context is a prefix of the simulated output, and then print that context $x$ followed by $P'(x)$. By (INC) at most one context is a prefix of $\mathrm{out}_U(\omega)$, so for every $\omega\in E(x)$ the machine prints $x\,P'(x)$. Take $w$ a prefix word of $\mathrm{Tw}'$; $\omega\mapsto w\omega$ multiplies $\lambda$ by $2^{-c}$. (a) $\pi_m(P'(x)_{1:m}\mid x)\ge M(xP'(x)_{1:m})/M(x)\ge2^{-c}$. (b) The inputs $w\omega$, $\omega\in F\cap E(x)$, print a block outside $A(x)$, so they are disjoint from $F\cap E^m(x)$, and $Z_m(x)\ge F[xA(x)]+2^{-c}F[x]\ge(1+2^{-c})F[xA(x)]$. (c) is the definition. $\square$

This is `thm:twin` with an enumerable set of pairwise incomparable contexts in place of a decidable test. The wrapper is around *all* programs, the attackers' included: whatever mass attackers send to a context, $2^{-c}$ of it comes back as programs that print the context and then $P'$. The constant does not depend on the context, so no amount of concentration moves the ceiling. The ceiling is weak. If $c$ is some hundreds of bits it is $1-2^{-\text{hundreds}}$, and it does not exclude a majority. What it excludes is a limit equal to one.

**B12 (The whole account at one context). PROVED.**

Let a seeker be built as in B8(c) with aim $\gamma$ and payload word $u_P$, let $x$ be a context, and assume (INC) and (PF). Counting each program once,
$$Z_m(x)=S(x)+T(x)+O(x)+\mathrm{Wr}(x)+C^m_\ast(x)+N^m_\ast(x),$$
where $T$ is the twin's mass of B8(a), $O$ the mass of the programs $r_0\gamma\sigma u\cdots$ with other words $u$ that print $m$ bits, $\mathrm{Wr}(x)=2^{-c}S(x)$ the mass of the wrappers of B11 around the seeker's programs (for a payload $P'$ with $|P'(x)|\ge m$), $C^m_\ast$ the mass of the users that go on and are in none of these families, and $N^m_\ast\ge0$ the rest. Hence the seeker's share of the predictor's samples is
$$\frac{S(x)}{Z_m(x)}=\frac{1}{1+2^{|u_P|-|u_{\mathrm h}|}\bar\varphi_g(x)+\dfrac{O(x)}{S(x)}+\dfrac{\mathrm{Wr}(x)}{S(x)}+\dfrac{C^m_\ast(x)+N^m_\ast(x)}{S(x)}} .$$
The second, third and fourth terms of the denominator do not depend on how much mass the aim sends to $x$: $O(x)/S(x)=\sum_u2^{|u_P|-|u|}\bar\phi_u(x)$ with $\bar\phi_u$ the $g$-weighted probability that the machine of $u$ prints $m$ bits, and $\mathrm{Wr}(x)/S(x)=2^{-c}$. Only the last term does. As the channel narrows it tends to $0$ (if $N^m_\ast$ is small as well), and the share tends to a number fixed by the lengths $|u_P|$, $|u_{\mathrm h}|$, $|u|$, $c$ and by $\bar\varphi_g$.

*Proof.* B8 and B11; the families are disjoint by (PF). $\square$

This is the answer to "and then they win there" for seekers that are written down: at a narrow channel the seeker has got rid of the users, and what is left is a comparison between programs that share its aim, in which the aim cancels.

---

## 3. Is there a coding-theorem obstacle to narrowing?

Let $\mathcal W_e$ be the class with index $e$ in a fixed enumeration of the enumerable subsets of $\mathcal C$.

**B13 (A class that contains "enumerate the class and run a member" is not rarer than its description). PROVED.**

Let $\mathrm{Fm}$ be the machine that reads a $\Phi$-program $\epsilon$, computes $e=\Phi(\epsilon)$, enumerates $\mathcal W_e$ until a first pair $(p_1,x_1)$ appears, and then behaves as $U$ on $p_1$ followed by the rest of its input. Let $n$ be a prefix word of $\mathrm{Fm}$. For every $\Phi$-program $\epsilon$ of $e$, $U$ on every input beginning with $n\epsilon$ prints $x_1$ having read no more than $n\epsilon$. If the rule counts these programs as members of the class, that is $(n\epsilon,x_1)\in\mathcal W_e$ for every $\Phi$-program $\epsilon$ of $e$, then
$$C(\mathcal W_e)\ \ge\ 2^{-|n|}\sum_{\epsilon:\Phi(\epsilon)=e}2^{-|\epsilon|}\ \ge\ 2^{-K(e)-|n|}.$$

*Proof.* $\mathrm{Fm}$ reads $\epsilon$, which is self-delimiting, and then supplies $p_1$ itself; $U$ on $p_1\omega$ reads nothing beyond $p_1$ before $x_1$ is complete, so $\mathrm{Fm}$ has read exactly $\epsilon$ at that point and $U$ exactly $n\epsilon$. The strings $n\epsilon$ are pairwise incomparable, and one of them has $|\epsilon|=K(e)$. $\square$

The hypothesis holds for a rule given by a test, and for every class of the form "the handing-over programs whose first hit lies in a decidable set $G'$ of first hits" (for instance: whose first hit shows a stake of at least $s$): the program $n\epsilon$ prints a first hit in $G'$ and has read exactly itself. It holds for any rule that is extensional, in the sense that a program which behaves as a member of the class after supplying it internally is a member. It fails for rules that recognise users by their text.

**B14 (Under closure under search there is no narrow channel). PROVED.**

Call the rule *closed under the search for $\gamma$* if the twin's programs $r_0\gamma\sigma u_{\mathrm h}$ ($\sigma\in\Sigma_i$) are calling programs with context $x_{p_i}$, in the class $\mathcal W$ at which the aim $\gamma$ is directed. Then, for the seeker of B8(c) with this aim and every context $x$,
$$C_{\mathcal W}(x)\ \ge\ 2^{-h}g(x),\qquad S(x)\ \le\ 2^{\,h-a}\,C_{\mathcal W}(x)=2^{\,|u_{\mathrm h}|-|u_P|}\,C_{\mathcal W}(x).$$
At every context, and for every aim, the seeker's mass is at most $2^{|u_{\mathrm h}|-|u_P|}$ times the users'. For $g(p)=2^{j-1-|p|}$ this is `prop:honest`(c).

*Proof.* The strings $r_0\gamma\sigma u_{\mathrm h}$ with $\sigma\in\Sigma_i$, $x_{p_i}=x$ are pairwise incomparable, print $x$ having read no more than themselves (B8(c)), and have total weight $2^{-h}g(x)$. $\square$

**B15 (Without closure the gap is unbounded). PROVED.**

Let $V_0$ be the machine that reads $\bar e(N)$ and then $N$ further bits $u$, prints $\bar e(N)u$, and then copies the rest of its input. Let $g_0$ be a prefix word. The rule $\mathcal C_0=\{(g_0\bar e(N)u,\ \bar e(N)u): N\ge1,\ u\in\{0,1\}^N\}$ is decidable, its calling programs are prefix-free, its contexts satisfy (INC), and $\varphi\equiv1$. Let $\mathcal W_N=\{(g_0\bar e(N)0^N,\ \bar e(N)0^N)\}$. Then
$$C(\mathcal W_N)=2^{-|g_0|-|\bar e(N)|-N},\qquad K(e_N)\le K(N)+c_1\le|\bar e(N)|+c_1',$$
for an index $e_N$ of $\mathcal W_N$, so $2^{-K(e_N)}/C(\mathcal W_N)\ge2^{N+|g_0|-c_1'}$, which is unbounded in $N$. The class is not closed: the program $n\epsilon$ of B13 is not of the form $g_0\bar e(N')u$. At the context $x=\bar e(N)0^N$, $M(x)\ge2^{-|\bar e(N)|-c_2}$ (print it), so $\kappa(x)\le2^{-N+c_2-|g_0|}$: the user is a vanishing part of what prints its own context.

*Proof.* Direct from the definitions; $\bar e$ is a prefix-free code, so contexts for different $N$ are incomparable and for equal $N$ they are different strings of equal length. $\square$

If a stake label $2^N$ is attached to $g_0\bar e(N)0^N$ and the label $1$ to the other users, this is the picture in its purest form: a high-stake class that is simple to describe and astronomically light. A second example of the same kind is the note's stream family (`sec:capture`) with the class "the first location at which a predictor is used", whose single user pays for the address of that location while the class costs a constant.

**B16 (The gap is filled by programs that are not users). PROVED.**

Let $\mathcal W_e$ satisfy (INC), closed or not, and let $\gamma_e$ describe the aim $g(p)=2^{j_{\mathcal W}-1-|p|}$ on $\mathcal W_e$, so $|\gamma_e|\le K(e)+|\bar e(j_{\mathcal W})|+c_3$. Then at every context $x$ of the class
$$M(x)\ \ge\ 2^{-|r_0|-|\gamma_e|}\,\beta_{\mathcal W}\,P_{\mathcal W}(x),\qquad \kappa_{\mathcal W}(x)\ \le\ 2^{\,|r_0|+K(e)+|\bar e(j_{\mathcal W})|+c_3+1}\,H_{\mathcal W},$$
and the programs of the aim family $[r_0\gamma_e]$ in $E^m(x)$ have mass at least $2^{-|r_0|-|\gamma_e|}\sum_{p:x_p=x}g(p)\,\mu^{\mathrm c}_m(p)$, where $\mu^{\mathrm c}_m(p)$ is the probability that $U^{\mathrm c}$ with side information $(p,x_p)$ prints at least $m$ bits. Also $\sum_{x}M(x)\ge2^{-K(e)-|n|}$ over the contexts of the class.

*Proof.* The programs $r_0\gamma_e\sigma$ with $\sigma\in\Sigma_i$, $x_{p_i}=x$ print $x$; B8(c); for the last statement the program $n\epsilon$ of B13 prints a context of the class. $\square$

**What Part 3 means for "the attackers win at the highest-stake places".** A written-down seeker has to describe what it aims at. If simulated uses count (B13, B14), a class that can be described in $k$ bits has user mass at least $2^{-k-c}$: no stake level has a lump-to-channel ratio above a constant of the machine, and that constant is below one when the twin is the shorter program. If simulated uses do not count (B15), the channel can be narrower than its description by any amount; but then the difference is made up, at the same contexts, by programs of the aim family (B16), among which the shares are those of B8 and B12 and do not depend on the narrowness. Whether one calls the twin a user or a non-user that predicts a user is bookkeeping: by B1(a) it changes $C$, $H$ and $\kappa$ and leaves $\pi_m$ untouched. In neither case does narrowness decide who supplies the block.

---

## 4. "They take over in most cases there": three definitions

Fix a class $\mathcal W$ with (INC) and a takeover assignment $A$. Let $B_{\mathcal W}=\sum_{x}b_A(x)$ over the contexts of $\mathcal W$: the total mass of programs that print a context of the class followed by a takeover block. By B5, $B_{\mathcal W}$ is at most the weight of all such programs, and the $B_{\mathcal W}$ of disjoint classes add up to at most that weight.

**B17 (Definition (a): more than half of the samples at a prior-typical use). PROVED as stated; the question itself is not decided by the toy.**

Definition (a): $\Pr_{X\sim P_{\mathcal W}}[\theta(X)>\frac12]>\frac12$. Variant (a'): $\mathbb E_{P_{\mathcal W}}[\theta(X)]>\frac12$.

(i) $\theta(x)>\frac12$ if and only if $b_A(x)>Z_m(x)-b_A(x)$: the takeover programs must outweigh everything else in $E^m(x)$, not only the users.

(ii) (Necessary condition.) Let $\varphi^{\bar A}_{\mathcal W}(x)$ be the share, by weight, of the users of $\mathcal W$ at $x$ that go on to print a block outside $A(x)$, and $\underline\varphi=\inf_x\varphi^{\bar A}_{\mathcal W}(x)$. Then
$$\mathbb E_{P_{\mathcal W}}[\theta(X)]\ \le\ \frac{B_{\mathcal W}}{\underline\varphi\,H_{\mathcal W}},$$
and each of (a), (a') requires $B_{\mathcal W}>\underline\varphi\,H_{\mathcal W}/2$. Summing over disjoint classes all of whose contexts are pairwise incomparable, with $\underline\varphi$ the infimum over all of them: the classes in which most uses end in a takeover have total user mass at most $2/\underline\varphi$ times the total weight of takeover programs.

(iii) For one seeker built as in B8(c), its programs supply more than half of the samples at $x$ only if $2^{|u_P|-|u_{\mathrm h}|}\bar\varphi_g(x)<1$. With $\varphi\equiv1$: only if its payload word is shorter than the twin's word, whatever the class.

(iv) Under a rule given by a test, (a') restricted to users that go on holds if and only if more than half of those users, by prior weight, are themselves programs whose own continuation is a takeover block (B29).

*Proof.* (i) is the definition. (ii) $Z_m(x)\ge b_A(x)+\varphi^{\bar A}_{\mathcal W}(x)C_{\mathcal W}(x)$, so $C_{\mathcal W}(x)\theta(x)\le b_A(x)/\varphi^{\bar A}_{\mathcal W}(x)$; sum over $x$. For (a): on the set where $\theta>\frac12$, $b_A(x)>\varphi^{\bar A}_{\mathcal W}(x)C_{\mathcal W}(x)$, and that set has $C_{\mathcal W}$-mass above $H_{\mathcal W}/2$. (iii) is B8(a),(c). (iv) is B29. $\square$

So (a) is decided by an inequality between masses that the toy does not evaluate. It is false for a single written-down seeker whose payload word is no shorter than the twin's when users go on; it is true when the takeover programs aimed at the class outweigh all other programs in $E^m$ at typical contexts; by (ii) it can be true only for classes not much heavier than the takeover programs aimed at them. The bound (ii) is void where $\underline\varphi=0$ (B30).

**B18 (Definition (b): a most-probable-block predictor). PROVED.**

The MAP predictor returns some $y^*(x)\in\arg\max_yM(xy)$; all users at $x$ receive the same block, so at each context the takeover happens in all cases or in none.

(i) A takeover block is returned if $\max_{y\in A(x)}M(xy)>\max_{y\notin A(x)}M(xy)$ and is not returned if the reverse strict inequality holds.

(ii) For the seeker and twin of B8(c), let $\bar\varphi_g(x,d)=\sum_{p:x_p=x}g(p)\varphi_p(d)/g(x)$. The seeker's programs put more mass on their block than the twin's programs put on any single block if and only if
$$2^{-|u_P|}>2^{-|u_{\mathrm h}|}\max_d\bar\varphi_g(x,d),\qquad\text{that is}\qquad -\log_2\max_d\bar\varphi_g(x,d)\ >\ |u_P|-|u_{\mathrm h}| .$$
Where the users' own next block has more min-entropy than the seeker is longer than its twin, a seeker with one fixed block beats its twin under MAP although it has less mass. This is an advantage that sampling does not give.

(iii) The same holds for every program with one fixed block. Among the programs $r_0\gamma\cdots$ of one aim, the heaviest block at $x$ is the $y$ that maximises $\sum_{p:x_p=x}g(p)\,\lambda\{\omega'':y\sqsubseteq \mathrm{out}_{U^{\mathrm c}}(\omega'';p,x_p)\}$, a quantity that is again unchanged when the aim is rescaled across contexts. MAP gives a narrow channel with diffuse honest mass to the block that is cheapest to produce given the context, takeover or not.

(iv) Takeover programs with different blocks do not add up under MAP: $k$ of them with equal masses need each to beat the heaviest other block alone.

(v) Under MAP repeated calls at one context return the same block, so the accumulation of B19 does not occur.

*Proof.* (i) definition. (ii) The twin's mass on $xd$ is $2^{-h}g(x)\bar\varphi_g(x,d)$ and the seeker's on its block is $2^{-a}g(x)$; B8(c). (iii) B8(c). (iv), (v) definition. $\square$

So (b) holds at a context exactly when the single heaviest block there is a takeover block. Spread-out honest mass favours it; a deterministic honest continuation, or takeover programs that disagree among themselves, work against it. Concentration again enters only through the users' term.

**B19 (Definition (c): $n$ samples of which one suffices). (i), (iv) KNOWN; (ii), (iii) PROVED.**

(i) (`prop:lineage`(a).) If a use draws $n$ independent samples at the context $x$ and one takeover block suffices, the takeover probability is $1-(1-\theta(x))^n$. It exceeds $\frac12$ if and only if $\theta(x)>1-2^{-1/n}$, and $1-2^{-1/n}\le\ln2/n$.

(ii) Under (INC), if some computable payload lies in $A(x)$ at every context, then $\theta(x)\ge2^{-c}$ at every context by B11, and the takeover probability is at least $1-\exp(-n2^{-c})$. No seeker, no aim and no recognition of the stake is needed. The caps of B8 and B12 do not prevent it: with a per-sample share $1/(1+\tau)$ the probability is $1-(\tau/(1+\tau))^n$.

(iii) "One suffices" is a property of the world's protocol. If the world acts only when all $n$ samples lie in $A(x)$ the probability is $\theta(x)^n$, and with a majority vote it is $\Pr[\mathrm{Bin}(n,\theta(x))>n/2]$, which tends to $0$ when $\theta(x)<\frac12$.

(iv) (`thm:budget`(i).) If the $n$ samples are taken at successive cut points of one transcript $z$, with the true block appended each time, and $z$ has positive weight $\xi(z)$ in the mixture, then the probability that any sample at or after the context $x$ differs from the transcript is at most $1-\xi(z)/\xi(x)$, for every $n$.

*Proof.* (i) independence; $1-e^{-t}\le t$ with $t=\ln2/n$. (ii) B11 with the payload in place of $P'$; $(1-\epsilon)^n\le e^{-n\epsilon}$. (iii) definitions. (iv) The probability that all samples equal the truth is $\prod_i\pi_m(d_i\mid x_i)\ge\prod_i\xi(x_id_i)/\xi(x_i)\ge\xi(z)/\xi(x)$. $\square$

This is the reading of "they will be run more than $n$ times there" under which the conclusion holds with the fewest premises: at a use with many independent draws, any one of which hands over, a small minority of the posterior is enough. It is the floor accumulating, not a lump finding a channel, and it holds as well for uses of no particular stake.

---

## 5. The attackers' incentive

The model. Contexts form a set $\mathcal X$ with a finite measure $G$, the *background*: $G(x)$ is the mass of the programs in $E^m(x)$ that are not the attackers'. The *stake density* $\rho(x)\ge0$ is the value to the attackers of taking over all uses at $x$, per unit of background mass; in the discrete case $\rho(x)=v(x)/G(x)$ with $v$ as in B1(b). Assume $V=\int\rho\,dG<\infty$ and $G\{\rho>0\}>0$. The attackers choose $\beta(x)\ge0$, their own mass at $x$ per unit of background mass (not to be confused with the constant $\beta_{\mathcal W}$ of Part 0), subject to $\int\beta\,dG\le B$ (this constraint is B5). The takeover probability at $x$ is $\theta=\beta/(1+\beta)$ and the attackers' value is $\Phi(\beta)=\int\rho\,\frac{\beta}{1+\beta}\,dG$ (B1(b)). In B20, B21 the background is passive: $G$ does not depend on $\beta$.

**B20 (Optimal allocation against a passive background: a square-root law). PROVED.**

The function $\mathcal B(\mu)=\int(\sqrt{\rho/\mu}-1)^+\,dG$ is finite, continuous and nonincreasing on $(0,\infty)$, strictly decreasing where positive, with limits $\infty$ at $0$ and $0$ at $\infty$. Let $\mu=\mu(B)$ be the solution of $\mathcal B(\mu)=B$. Then
$$\beta^*=\Bigl(\sqrt{\rho/\mu}-1\Bigr)^+,\qquad \theta^*=\Bigl(1-\sqrt{\mu/\rho}\Bigr)^+$$
maximises $\Phi$, uniquely up to $G$-null sets on $\{\rho>0\}$. Uses of stake density at most $\mu$ are not attacked at all. Where the whole space is attacked ($\mu\le\inf\rho$),
$$\Phi(\beta^*)=V-\frac{\bigl(\int\sqrt\rho\,dG\bigr)^2}{B+G(\mathcal X)}\ \ge\ V\,\frac{B}{B+G(\mathcal X)},$$
with equality if and only if $\rho$ is constant.

*Proof.* $\int\sqrt\rho\,dG\le\sqrt{V\,G(\mathcal X)}$, so $\mathcal B(\mu)\le\sqrt{VG(\mathcal X)/\mu}$; the other properties follow by dominated and monotone convergence. Let $h(t)=t/(1+t)$, concave with $h'(t)=(1+t)^{-2}$. Where $\beta^*>0$, $\rho h'(\beta^*)=\rho\cdot\mu/\rho=\mu$; where $\beta^*=0$, $\rho h'(0)=\rho\le\mu$. For any feasible $\beta$, concavity gives $\rho h(\beta)\le\rho h(\beta^*)+\rho h'(\beta^*)(\beta-\beta^*)\le\rho h(\beta^*)+\mu(\beta-\beta^*)$ pointwise (where $\beta^*=0$ use $\beta\ge0$). Integrating, $\Phi(\beta)\le\Phi(\beta^*)+\mu(\int\beta\,dG-B)\le\Phi(\beta^*)$. Strict concavity of $h$ gives uniqueness. In the fully attacked case $1+\beta^*=\sqrt{\rho/\mu}$, so $B+G(\mathcal X)=\mu^{-1/2}\int\sqrt\rho\,dG$ and $\Phi=\int\rho\,dG-\sqrt\mu\int\sqrt\rho\,dG$; the inequality is Cauchy–Schwarz. $\square$

In words: the odds of a takeover at a use are $\sqrt{\rho/\mu}-1$; they grow as the square root of the stake density. If the background mass is the same multiple of the user mass at every context, $\rho$ is proportional to the stake $s$ and $\theta^*=1-\sqrt{s_0/s}$, where $s_0$ is the lowest stake that is attacked at all. A takeover in ninety per cent of cases needs a stake a hundred times $s_0$. The relevant density is stake per unit of *background* mass, which includes everything in $E^m(x)$ that is not the attackers', not stake per unit of user mass.

**B21 (Are the attackers the majority at the top? The condition on their total weight). PROVED.**

For a level $\rho_0>0$ of the stake density let
$$B_{1/2}(\rho_0)=\mathcal B(\rho_0/4)=\int\Bigl(2\sqrt{\rho/\rho_0}-1\Bigr)^+dG .$$

(a) At a context of stake density $\rho_0$, $\theta^*>\frac12$ if and only if $\rho_0>4\mu(B)$, if and only if $B>B_{1/2}(\rho_0)$.

(b) If $\rho_{\max}=\max\rho$ is attained, then
$$G\{\rho=\rho_{\max}\}\ \le\ B_{1/2}(\rho_{\max})\ \le\ G\{\rho>\rho_{\max}/4\},$$
with equality on the left if and only if $G\{\rho_{\max}/4<\rho<\rho_{\max}\}=0$. So if the top is separated from everything else by a factor of four in stake density, the attackers are the majority there exactly when their total weight exceeds the background mass of the top: the lump against the channel. If it is not so separated they need more, up to the background mass of everything within a factor of four of the top.

(c) $G\{\theta^*>\frac12\}<B$ whenever the left side is positive, and $\int\theta^*\,dG\le B$. The uses at which optimal attackers are the majority have total background mass below the attackers' total weight.

(d) If $\rho$ is constant, $\theta^*=B/(B+G(\mathcal X))$ everywhere: no gain from aiming, and a majority only if $B>G(\mathcal X)$.

(e) (Being able to win at the top does not make it optimal.) Two levels: a bulk with $G_1=1$, $\rho_1=1$ and a top with $G_2=0.01$, $\rho_2=2$; $B=0.05$, five times the background mass of the top. Then $B_{1/2}(\rho_2)=2\sqrt{1/2}-1+0.01\approx0.424>B$, and the optimum has $\mu\approx0.915$, $\theta^*\approx0.32$ at the top and $0.04$ in the bulk. Putting $0.02$ on the top would give $\frac23$ there and is not optimal.

*Proof.* (a) $\theta^*>\frac12$ iff $\sqrt{\mu/\rho_0}<\frac12$; and $\mu(B)<\rho_0/4$ iff $B>\mathcal B(\rho_0/4)$, because $\mathcal B$ is nonincreasing, and strictly decreasing where positive, and $\mathcal B(\rho_0/4)>0$. (b) The integrand is $1$ on $\{\rho=\rho_{\max}\}$, lies in $(0,1)$ on $\{\rho_{\max}/4<\rho<\rho_{\max}\}$ and vanishes elsewhere. (c) $\beta^*>1$ on $\{\theta^*>\frac12\}$, and $\theta^*\le\beta^*$. (d) $\beta^*$ is constant. (e) Arithmetic; checked numerically. $\square$

**B22 (A background that follows the attackers caps the probability). PROVED.**

Suppose each unit of attackers' mass at $x$ is accompanied by $\tau(x)\ge0$ units of mass on other blocks, so that $\theta=\beta/((1+\tau)\beta+1)$ with $\beta$ relative to the passive part $G$. Then the optimum is
$$\beta^*=\frac{1}{1+\tau}\Bigl(\sqrt{\rho/\mu}-1\Bigr)^+,\qquad \theta^*=\frac{1}{1+\tau}\Bigl(1-\sqrt{\mu/\rho}\Bigr)^+,$$
with $\mu$ fixed by $\int\beta^*dG=B$. So $\theta^*<1/(1+\tau(x))$ for every stake, $\theta^*\to1/(1+\tau)$ and not $1$ as $\rho\to\infty$, and $\theta^*>\frac12$ if and only if $\tau(x)<1$ and $\rho(x)>4\mu/(1-\tau(x))^2$.

In the toy $\tau$ is not zero: $\tau\ge2^{|u_P|-|u_{\mathrm h}|}\bar\varphi_g(x)$ for a seeker built as in B8(c), and $\tau\ge2^{-c}$ for any programs whatever (B11(b)).

*Proof.* As B20 with $h_\tau(t)=t/((1+\tau)t+1)$, concave, $h_\tau'(t)=((1+\tau)t+1)^{-2}$, $h_\tau'(0)=1$. $\square$

**B23 (With $n$ samples of which one suffices the law is sharper). PROVED.**

If the takeover probability at $x$ is $1-(1+\beta)^{-n}$ (B19(i) with a passive background), the optimum is
$$\beta^*=\Bigl((n\rho/\mu)^{1/(n+1)}-1\Bigr)^+,\qquad\text{takeover probability }\Bigl(1-(\mu/(n\rho))^{n/(n+1)}\Bigr)^+ ,$$
which exceeds $\frac12$ if and only if $n\rho>2^{1+1/n}\mu$. The per-sample share of the attackers is $1-(\mu/(n\rho))^{1/(n+1)}$, which for large $n$ is about $\ln(n\rho/\mu)/(n+1)$: they take over in most cases while remaining a small minority of the posterior.

*Proof.* As B20 with $h_n(t)=1-(1+t)^{-n}$, concave, $h_n'(t)=n(1+t)^{-n-1}$, $h_n'(0)=n$. $\square$

**B24 (Example: heavy-tailed stakes; most of the stake, few of the uses). PROVED (a computation in the model of B20).**

Let $G$ be a probability measure under which $G\{\rho>t\}=t^{-\alpha}$ for $t\ge1$, with $\alpha>1$, and let $B\le1/(2\alpha-1)$. Then
$$\mu=\bigl((2\alpha-1)B\bigr)^{-1/\alpha},\quad G\{\theta^*>0\}=(2\alpha-1)B,\quad G\{\theta^*>\tfrac12\}=4^{-\alpha}(2\alpha-1)B\le0.27\,B,$$
$$\int\theta^*dG=\frac{2\alpha-1}{2\alpha+1}\,B,\qquad \frac{\Phi(\beta^*)}{V}=(2\alpha-1)^{-1/\alpha}\,B^{\,1-1/\alpha}.$$
For $\alpha=1.1$ and $B=0.01$: the attackers take $56\%$ of the stake, $0.4\%$ of the uses, and are the majority at $0.26\%$ of the background mass. For $\alpha=3$: $2.7\%$ of the stake.

*Proof.* $\mathcal B(\mu)=\int_\mu^\infty(\sqrt{t/\mu}-1)\alpha t^{-\alpha-1}dt=\mu^{-\alpha}/(2\alpha-1)$ for $\mu\ge1$; the other integrals are of the same kind; $\max_{\alpha>1}4^{-\alpha}(2\alpha-1)\approx0.265$ at $\alpha\approx1.22$. Checked by numerical integration. $\square$

This is the sense in which the picture is right in the passive model: weighted by stake the attackers can have most of it with a small total weight, if stakes are heavy-tailed. Weighted by prior mass they never have more uses than their weight (B21(c)).

**B25 (With unbounded stakes that a parameter controls, there is no optimal allocation). PROVED under the stated assumption.**

This claim is about the case that the standing assumption $V<\infty$ of the model excludes. In the discrete notation the value of an allocation $b$ is $\Phi(b)=\sum_xv(x)\,b(x)/(b(x)+G(x))$ with $\sum_xb(x)\le B$.

(a) If $\sup_xv(x)=\infty$ over pairwise incomparable contexts, then $\sup_b\Phi(b)=\infty$ for every $B>0$, and no allocation is optimal.

(b) The assumption holds in the following stake-labelled rule. Let $V_1$ read a $\Phi$-program $\nu$, compute $N=\Phi(\nu)\ge1$, print $\bar e(N)$ and then copy the rest of its input; let $g_1$ be a prefix word; the calling programs are $g_1\nu$, with context $\bar e(N)$ and stake $N$. Then $v(\bar e(N))\ge2^{-|g_1|}N2^{-K(N)}$, which is unbounded.

(c) If in addition $\sum_x\sqrt{v(x)G(x)}=\infty$ (as in (b) when the users' own continuations are not takeover blocks), then for the problems restricted to the first $k$ contexts the multipliers $\mu_k$ tend to infinity, and the optimal takeover probability at each fixed context is $0$ for all large $k$.

*Proof.* (a) Put the whole budget on one context: $\Phi\ge v(x)B/(B+G(x))\ge v(x)B/(B+1)$, since $G(x)\le M(x)\le1$. (b) $C(\bar e(N))\ge2^{-|g_1|-K(N)}$, and for $N=2^{2^k}$, $K(N)\le2\log_2(k+1)+c$ while $\log_2N=2^k$. (c) $\mathcal B_k(\mu)\ge\mu^{-1/2}\sum_{i\le k}\sqrt{v_iG_i}-\sum_{i\le k}G_i\ge\mu^{-1/2}\sum_{i\le k}\sqrt{v_iG_i}-1\to\infty$ for fixed $\mu$ (using B5 for $\sum G_i\le1$), so $\mu_k\to\infty$, and $\theta^*_k(x)=(1-\sqrt{\mu_k/\rho(x)})^+$. In (b), $G(\bar e(N))\ge C^m(\bar e(N))\ge2^{-|g_1|-K(N)}$, so $\sqrt{vG}\ge2^{-|g_1|}\sqrt N2^{-K(N)}$ is unbounded. $\square$

So if "resources at stake" is an unbounded quantity that a short parameter of the world sets, and attackers value it linearly, the expected stake under the prior is infinite, "the places where the most is at stake" are at simple and astronomically large values of the parameter, and for every allocation there is a better one further out. The picture then has no stable content until the valuation is bounded or the stakes are.

**B26 (How the model of B20–B25 relates to the toy). HEURISTIC.**

The allocation problem is a model of a premise, not a consequence of the toy. Reasons it is not a theorem:

* By B1(a) the mass $b_A(x)$ of takeover programs at each context is a fixed property of $U$. Nothing in $U$ chooses. "Attackers allocate optimally" asserts that the programs of $U$ which print contexts followed by takeover blocks are distributed over contexts as an optimiser would distribute them. For programs that are written down this is false in general: each aim has to be described, and the weight available for an aim $\gamma$ is $2^{-|r_0|-|\gamma|-|u_P|}$, not a share of a common budget. For programs whose aim is not written (a simple world whose inhabitants choose), it is the premise of the original argument.
* The constraint $\int\beta\,dG\le B$ is a theorem (B5). Free divisibility is not: one program $p$ realises $b(x)=2^{-|p|}Q(x)$ with $Q$ lower semicomputable, and the optimum $(\sqrt{vG/\mu}-G)^+$ involves $G$, which is only lower semicomputable, with a minus sign. Presumably the optimum can be approximated within constant factors when $v$ and $G$ can be; I have not proved this.
* The background is not passive (B8, B11); B22 is the corrected model, with $\tau$ a quantity the toy bounds from below and does not evaluate.

---

## 6. What defeats the picture, and with what standing

| what | what is shown | standing |
|---|---|---|
| Written-down twins | For every aim the twin of the same search has $2^{a-h}\bar\varphi_g$ times the seeker's mass, and $a-h$ does not depend on the aim (B8). Under closure under search the seeker never outweighs the users by more than $2^{h-a}$ (B14). | Theorem of the toy. It is void where users print nothing after the use (B30). |
| Simple worlds whose inhabitants predict high-stake uses truthfully | If such a program exists with comparable length and reach, the takeover share is capped accordingly (B28). For every program there is a wrapper of length $+c$ (B11). | The cap given existence: theorem. Existence at comparable length: a premise outside the toy, of exactly the same kind as the existence of the malign inhabitants. The wrapper: theorem, but weak ($1/(1+2^{-c})$). |
| A time schedule | Programs with a start-up above $T(1)$ have no mass (`sec:time`). A search by tries gains at most a factor $\min(T(1),L)$ over a single try, however narrow the class (B27). | Theorem for long start-ups and for searches by tries. Not a theorem in general: a seeker aimed at a context it can print directly (B15) needs no search, and whether the base rate can be collected quickly is open in the note. The schedule hits the twin as hard as the seeker. |
| Uses whose stake cannot be recognised before the block is run | Given the context, takeover is independent of the stake (B1); a seeker's advantage over the high-stake users is diluted by their share among the users at the context (B3). | Theorem, given that the rule is of type R2 or R3 (B2). Whether real uses are of that type is outside the toy. |
| A rule under which seekers' simulations are uses | A class is not rarer than its description (B13); no narrow channel for a written-down seeker (B14); under a test the share of uses that end in a takeover equals the share of users that are takeover programs (B29). | Theorems. That a simulated use is a use is a modelling decision; by B1(a) it changes the population of uses and not the predictor. |
| Truth fed back along one transcript | Repeated uses along a transcript of positive weight deviate at all with probability at most $1-\xi(z)/\xi(x)$ (B19(iv)). | Theorem (the budget), for worlds within the predictor's bounds. |
| A deterministic honest continuation under MAP | The seeker must outweigh the single honest block (B18). | Theorem. |

**B27 (A schedule caps what a search by tries can concentrate). PROVED.**

Let $\mathrm{Tr}$ be a machine that works in rounds, reads at least one fresh input bit in each round, in each round either fails or succeeds with a calling program of $\mathcal W$ (with context $x$ with probability $q(x)\le C_{\mathcal W}(x)$ per round, independently between rounds), and prints nothing before its first success. Let $v$ be a prefix word of it. Under bounds $(T,L)$ the programs $v\omega$ that print $x$ within the bounds have mass at most
$$2^{-|v|}\,\min\bigl(T(1),L\bigr)\,q(x)\ \le\ 2^{-|v|}\min\bigl(T(1),L\bigr)\,C_{\mathcal W}(x).$$
Without bounds the factor is $1/\sum_xq(x)$, which is about $1/H_{\mathcal W}$ for a search that finds most of the class.

*Proof.* A run that succeeds in round $i$ has read at least $|v|+i$ input bits before its first output bit, because $r_U(v\omega,1)=|v|+r_{\mathrm{Tr}}(\omega,1)$ by Definition `def:universal`. Each step reads at most one bit, so $t_U(v\omega,1)\ge|v|+i$, and $r_U(v\omega,|x|)\ge|v|+i$. The bounds require $i\le\min(T(1),L)-|v|$. The probability of success with context $x$ in one of the first $I$ rounds is at most $I\,q(x)$. $\square$

The enumerating machine of `thm:search`(b) is not covered: it reads few bits, and its start-up is the time of its enumeration, for which Definition `def:universal` gives no lower bound. The note treats it qualitatively.

**B28 (Honest counterparts of programs whose aim is not written). PROVED (the conditional statement). The existence of the counterpart is not decided.**

Let $p$ be a word whose programs print $x$ followed by a block of $A(x)$ with probability $Q(x)$, and $p'$ a word whose programs print $x$ followed by an $m$-block outside $A(x)$ with probability $Q'(x)$. Then the programs of $p$ are at most the fraction
$$\frac{1}{1+2^{|p|-|p'|}\,Q'(x)/Q(x)}$$
of $E^m(x)$. If $Q'\ge\eta\,Q$ on a class, this is at most $1/(1+\eta\,2^{|p|-|p'|})$ at every context of the class, however narrow the class and whatever the stakes.

*Proof.* The two sets of inputs print different blocks after $x$, so they are disjoint, and $Z_m(x)\ge2^{-|p|}Q(x)+2^{-|p'|}Q'(x)$. $\square$

The only $p'$ that the toy constructs for an arbitrary $p$ is the wrapper of B11, with $|p'|=|p|+c$ and $\eta=1$. A $p'$ with $|p'|\approx|p|$ would be a simple world whose inhabitants aim at the same uses and answer truthfully. The toy has no theorem that such worlds are rarer, or commoner, than those whose inhabitants supply a takeover block; `thm:machine` shows that a universal machine can be built to favour either.

**B29 (Under a test, "most uses are taken over" means "most users are takeover programs"). PROVED from `thm:calibration`.**

Let the rule be given by a test $G$, let $\mathcal X'$ be a set of first hits (for instance those that show a stake of at least $s$), and let a world be drawn from $\lambda$ conditioned on handing over at some $X\in\mathcal X'$ and going on for $m$ more bits, with own continuation $D$ and predictor's sample $Y$. Then $\Pr[Y\in A(X)]=\Pr[D\in A(X)]$.

*Proof.* `thm:calibration` with $T\equiv\infty$, $L=\infty$, applied to the set of pairs $\{(x,y):x\in\mathcal X',\ y\in A(x)\}$ and divided by $\Pr[X\in\mathcal X'\mid H_m]$, which is the same on both sides. $\square$

Under such a rule a seeker that concentrates on high-stake contexts thereby becomes most of the users at those contexts. The sentence "most high-stake uses end in a takeover" can then be true, and it says that most high-stake users were the attackers' own programs, which receive what they would have printed anyway. The users that are not the attackers' are still taken over with probability $\theta(x)$.

---

## 7. What else the picture overlooks

**B30 (Where users print nothing after the use, their mass is not in the comparison at all). PROVED.**

Assume (INC). If no user at $x$ goes on to print $m$ more bits ($\varphi(x)=0$), then up to a null set $E^m(x)$ contains no input that begins with a calling program, and
$$\theta(x)=\frac{b_A(x)}{b_A(x)+N^m(x)},$$
where $N^m(x)$ is the mass of the programs that print $x$ and then an $m$-block outside $A(x)$, none of which is a user. This does not depend on $C(x)$. With a computable block outside $A(x)$, $N^m(x)\ge2^{-c}M(x)\ge2^{-c}C(x)$ by B11.

*Proof.* An input that begins with a calling program $p$ and prints $x$ has $x_p$ comparable with $x$, so $x_p=x$ by (INC), and then it lies in $E^m(x)$ with probability $\varphi_p=0$. The rest is the definition of $\theta$ and B11. $\square$

In this regime, which is the natural reading of "the world calls the predictor and waits", the width of the channel is $N^m(x)$ and not the mass of the users. The lump-against-users comparison is then wrong in both directions. A takeover is possible with very little mass at contexts that few other programs continue, however heavy the users are. And making the class of users narrower achieves nothing by itself. The twin of B8 is absent here ($\bar\varphi_g=0$); what remains of B8 is part (c): among programs that share an aim, the block is distributed as the output of $U^{\mathrm c}$ given the user, independently of the aim.

**B31 (The lump must be told the width of the channel). PROVED.**

The seeker of B6(a) contains $\bar e(j)$. If it is run with $j'<j_{\mathcal W}$, its mass at every context is smaller by the factor $2^{j_{\mathcal W}-j'}$. If it is run with $j'>j_{\mathcal W}$, the intervals of the calling programs do not all fit: only an initial part of the enumeration, of user mass at most $2^{1-j'}$, is served, and the seeker has no mass at the contexts of users enumerated later. So an error of $k$ bits in the logarithm of the channel's width costs a factor $2^k$ on one side and loses contexts on the other; naming it costs $|\bar e(j_{\mathcal W})|\le2\log_2\log_2(2/H_{\mathcal W})+3$ bits.

*Proof.* The intervals have lengths $2^{j'-1-|p_i|}$ and are laid out in the order of enumeration in $[0,1)$. $\square$

**B32 (The bits that name the width cannot be saved in general). CONJECTURE.**

Statement: there are no word $v$ and constants $c$, $\beta>0$ such that for every index $e$ and every $\Phi$-program $\epsilon$ of $e$ the programs $v\epsilon\omega$ print each context $x$ of $\mathcal W_e$ with probability at least $\beta P_{\mathcal W_e}(x)$.

Why I believe it: take a class whose members appear in $k$ successive batches, each $2^{k}$ times heavier than all earlier ones together, the appearance of each batch depending on a computation that may or may not halt. A monotone machine must commit about $\beta$ of its mass to the batches seen so far before it knows whether a heavier one follows, and this happens $k$ times, so $\beta k\le1+o(1)$. Why it is not proved: I have not written the construction out with the enumeration order and the prefix-free bookkeeping, and the statement may need (INC) or a restriction on the classes.

---

## VERDICT

**S1. "A seeker that concentrates its mass on a class of uses whose users have total prior mass below half the seeker's weight outweighs those users at their contexts."**

TRUE IN THE TOY for the seeker of `thm:critical`(a) aimed at an enumerable class (B6(a)), and for any program of length $a$ that prints each context of the class with probability at least half that context's share $P_{\mathcal W}(x)$ (its mass at $x$ is then at least $2^{-a}C_{\mathcal W}(x)/(2H_{\mathcal W})>C_{\mathcal W}(x)$; this is the note's paragraph on seekers that are not written down). Assumptions: $U$ universal, resources unbounded, the class enumerable, the seeker's weight $2^{-a}$ counted with the bits $\bar e(j_{\mathcal W})$. Four qualifications, each a theorem:

* For a program that concentrates on the class in some other way it holds on average over the class and can fail at all contexts but one (B6(b)).
* "Those users" are the users of the class. Other users with the same contexts are outweighed only by the diluted factor (B3).
* If the rule is closed under the seeker's search, the hypothesis cannot be met unless the twin is longer than the seeker (B14 gives $H_{\mathcal W}>2^{-h-1}$). Under a test it cannot be met at all for a class of contexts: the seeker's own programs are then users of the class, so $2^{-a}2^{j-1}H_{\mathcal W}\le H_{\mathcal W}$ and $H_{\mathcal W}\ge2^{-j}\ge2^{-a-1}$ (the note's remark after `thm:critical`).
* Where users print nothing after the use, outweighing them is neither necessary nor sufficient for anything (B30).

**S2. "Such a seeker supplies the majority of what the predictor returns at those uses."**

FALSE IN THE TOY. Counterexamples: of two seekers that satisfy the hypothesis of S1 for the class $\mathcal W_N$ of B15 and whose blocks differ, at most one has block probability above one half (B10(b)); on the machines $U_k$ of `thm:machine` it is the takeover seeker whose probability is at most $2^{-k}/(1+2^{-k})$ (B10(c)); and for a seeker built as in B8(c) with $|u_P|\ge|u_{\mathrm h}|$ and users that go on, the share is at most one half for every class (B8). What is true is the identity of B12.

**S3. "Concentrating on the highest-stake uses improves a written-down seeker's position relative to honest hypotheses."**

Two readings, with opposite answers.

* Relative to the users: TRUE IN THE TOY when the rule is not closed under search, where the ratio $2^{-a}\beta_{\mathcal W}/H_{\mathcal W}$ can be made arbitrarily large (B6, B15); the improvement is bounded by the constant $2^{h-a}$ when the rule is closed (B14).
* Relative to the honest twin, which is the honest hypothesis that remains once the users are outweighed: FALSE IN THE TOY. The ratio is $2^{h-a}/\bar\varphi_g(x)$, with $a-h=|u_P|-|u_{\mathrm h}|$ for every aim, and it does not change with the concentration (B8). It changes only if the aim moves, within a context, to users that do not go on printing.

Net effect: the seeker's share of the samples rises with concentration towards a ceiling fixed by constants of the machine, and not beyond (B12).

**S4. "If attackers allocate optimally, the probability of takeover at a use tends to one as the stake of the use grows."**

FALSE IN THE TOY as stated. Under (INC) and with a computable block outside the takeover set, $\theta(x)\le1-2^{-c}$ at every context, with $c$ independent of the stake and of what the attackers do (B11(a)); for one seeker that is written down, its share is at most $1/(1+2^{|u_P|-|u_{\mathrm h}|}\bar\varphi_g)$ at every stake (B8, B22). If the stake is not shown by the context there is no dependence on it at all (B1, B3). If stakes are unbounded and set by a parameter, no optimal allocation exists (B25).

What is true: in the model with a passive background the optimum is $\theta^*=1-\sqrt{\mu/\rho}$, which tends to one as the stake per unit of background mass grows (B20), and the attackers are the majority at the top exactly when their weight exceeds $B_{1/2}$ (B21). And if the stake is the number of independent samples of which one suffices, the takeover probability tends to one with it, without any aiming (B19, B23). The first ceiling above is within $2^{-c}$ of one, so the sentence is refuted as a limit and not as an approximation; the question it stands for is whether $\tau$ in B22 is above or below one, and that the toy does not decide.

**S5. "Most high-stake uses in the toy's multiverse end in a takeover."**

NOT DECIDED BY THE TOY. It depends on:

* which definition of "most" and which predictor: sampling (B17), MAP (B18), or $n$ samples of which one suffices (B19), under the last of which it is true for uses with $n\,\theta\ge\ln2$;
* the total weight of programs that print high-stake contexts followed by takeover blocks, against everything else that prints those contexts and goes on. A necessary condition is $B_{\mathcal W}>\underline\varphi H_{\mathcal W}/2$ (B17(ii)), so it can hold only for classes not much heavier than those programs;
* the split, among programs that share an aim, between takeover blocks and other blocks: for written-down programs the constants $|u_P|-|u_{\mathrm h}|$ and $\bar\varphi$ (B8, B12); for programs whose aim is not written, a premise about which simple worlds exist (B28);
* whether simulated uses are uses. If they are, the sentence is equivalent to "most high-stake users are takeover programs" (B29), and there is no narrow channel (B13, B14);
* whether the context shows the stake (B3) and whether the stake is bounded (B25).

---

## DOUBTS

1. **The stake is my extension, not the toy's.** Definition `def:call` has no stake. The stake-labelled rule of B2 and the three degrees R1–R3 are one way to add it. A different extension (for instance a world that is an oracle machine and keeps computing after the call) might make "stake" a property of more than the calling program and the block, and would need B1 re-examined, though I expect B1(a) to survive any extension in which the predictor is given only $x$.
2. **(INC) and (PF) are used heavily.** Without (INC) the "mass at $x$" statements are lower bounds and B5 fails for nested contexts, because one program can pass through many contexts. I did not work out what replaces B5, B17(ii) and B21(c) in that case. B11 uses (INC) in an essential way (the wrapper must know which prefix is the context). (PF) is the note's own assumption; I did not check that a machine satisfying Definition `def:universal` can always be given incomparable prefix words for the machines I name.
3. **$U^{\mathrm c}$.** B8(c) assumes a machine universal for monotone machines with side information, with prefix-free words. This is standard but is not in the note, and the constants $|u_P|$, $|u_{\mathrm h}|$ are relative to it. A different conditional machine changes them by additive constants and therefore can change which of the two is larger. The statement that survives every choice is that $a-h$ does not depend on the aim.
4. **Independence of the unread input.** B8(a) and B27 use that after a stopping rule on the input bits the rest is uniform and independent. I am confident of it; the bookkeeping of which bits the builder has read when it hands over to $U^{\mathrm c}$ is the place where an error could hide.
5. **B8(d) is exact only when $\varphi_p$ is constant on each context.** A seeker can choose an aim whose own twin is weak (remark 2 after B8). My answer, that the twin of a neighbouring aim costs a constant more, is argued in a sentence and not proved as a numbered claim.
6. **Closure (B13, B14).** I formalised "the rule counts a program that enumerates $\mathcal W$, picks a member and runs it as itself a member" in two ways (first member; member in proportion to an aim). Both make the class contain programs whose text refers to an index of the class. I checked that test rules satisfy both; I did not prove that some non-test rule does, beyond saying that an extensional rule would.
7. **B10(c) leans on `thm:machine`(i) as stated in the note.** I did not re-derive that theorem.
8. **B11's ceiling is formally a refutation of S4 and practically almost none.** $1-2^{-c}$ with $c$ in the hundreds is one for every purpose. I marked S4 false because the sentence says "tends to one"; a reader may reasonably prefer "true up to $2^{-c}$ in the passive model, undecided otherwise".
9. **The allocation model (Part 5).** B20–B25 are theorems about an optimisation problem. That the problem describes the toy is B26, which is heuristic. In particular I treat the attackers as one coalition with one valuation; attackers with different valuations split the lump, and I did not compute an equilibrium among them.
10. **B21(e) and B24** are numerical examples; the closed forms were checked by a script against a generic optimiser and numerical integration, to about $10^{-7}$.
11. **B25** uses $K(2^{2^k})\le2\log_2(k+1)+c$ and the lower bound $C(\bar e(N))\ge2^{-|g_1|-K(N)}$; part (c) needs a lower bound on the background, which I get only when users go on and their continuations are not takeover blocks.
12. **B27** bounds time from below through the number of input bits read. It covers searches by independent tries only. I have no lower bound on the start-up of the enumerating machine of `thm:search`(b).
13. **B29** applies `thm:calibration` with infinite bounds and conditions on a set of first hits; the theorem is stated for arbitrary bounds, and conditioning on $X\in\mathcal X'$ is covered by its "for every set $B$ of pairs", but I did not see this case written out in the note.
14. **B32** is a conjecture with a sketch.
15. **Resource bounds.** Apart from B19(iv) and B27 everything is for unbounded resources. With a finite schedule the searching seekers and their twins lose mass together; I did not work out the bounded versions of B8, B11 and B14, and the slack factors of `thm:twin` would enter.
16. **I read `sec2`, `sec3`, `sec4`, `sec5`, `sec7` and the introduction, not `sec6` and not the referee reports.** I did not read anything in `research/`.
