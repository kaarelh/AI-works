# The malign-prior toy with circuits in place of programs: direct translation (A)

Research file for the note in `malign-prior-toy/paper/`. Not reviewed by a human. Pencil-and-paper
mathematics; one arithmetic script was used to sanity-check the counting inequalities (no circuit or
program was generated or executed). Notation follows the note (`sec2-toy.tex`, `sec3-floor.tex`,
`sec4-limits.tex`) where it exists; references such as `thm:twin` are to the note's labels.

**Status labels.** PROVED: full proof here, explicit constants. KNOWN: a published result quoted from
memory, not re-proved. HEURISTIC: an argument with a gap that is named. CONJECTURE: a statement believed
but not argued in full. REFUTED: a natural expectation that is false, with the counterexample.

**The short version.** There are two natural ways to make a circuit a hypothesis about a sequence. In the
first (the circuit has one output wire per bit of the sequence) the predictor is degenerate: it is the
uniform measure, or an exchangeable one that learns only the frequency of ones (CA1, CA2). The second
(the circuit maps the index of a position to the bit at that position) is the right analogue of a program
that prints a sequence, and everything below is about it. In that toy the two results of the note that
hold for any machine, calibration and the budget, hold verbatim (CA4, CA5). The wrapper floor survives,
but its cost is no longer a constant: it is a number of gates times a pointer width that grows with the
size of the world (CA7). The constructions that give the program toy its distinctive effects have no
cheap counterpart: a circuit cannot read its own description (CA9 to CA12), it pays for every step of
computation in description length (CA14), a circuit that serves $N$ targets has shares that sum to at most
$1$ over them, and all the instances of a searching template together weigh less than one honest circuit
once the template is moderately larger than its targets (CA16). These upper bounds hold whatever is
inside the circuit, so they cover the seekers that are "not written down" (CA21, CA22). What remains as a
route to a majority off the truth is the one the note calls capture: a strictly smaller circuit that
agrees with the context and continues differently (CA23). All of the program-side effects come back when
the description is paid once and the computation repeated, as in a recurrent circuit (CA28, CA29).

---

## 1. Setting up

### 1.1 Circuits and their description length

Fix a number $k\ge 1$ of input wires. A **circuit** of size $s\ge1$ over $k$ inputs is a list of gates
$g_1,\dots,g_s$ in topological order, $g_i=(\tau_i,a_i,b_i)$ with a truth table $\tau_i\in\{0,1\}^4$ and
two pointers $a_i,b_i\in\{1,\dots,k+i-1\}$. Wires $1,\dots,k$ are the inputs, wire $k+i$ is gate $i$, and
the value of gate $i$ is $\tau_i(\text{value of }a_i,\text{value of }b_i)$. All sixteen binary functions
are available, so constants, projections and negations are single gates, and a negation can always be
absorbed into the truth table of the gate that consumes it. The **output** is the last gate. Let
$\mathcal C_{k,s}$ be the set of these circuits. Then
$$|\mathcal C_{k,s}|=\prod_{i=1}^{s}16\,(k+i-1)^2,\qquad
\Lambda(k,s):=\log_2|\mathcal C_{k,s}|=\sum_{i=1}^{s}\bigl(4+2\log_2(k+i-1)\bigr),$$
$$\Delta(\sigma,a):=\Lambda(k,\sigma+a)-\Lambda(k,\sigma)=\sum_{i=\sigma+1}^{\sigma+a}\bigl(4+2\log_2(k+i-1)\bigr),\qquad
a\bigl(4+2\log_2(k+\sigma)\bigr)\le\Delta(\sigma,a)\le a\bigl(4+2\log_2(k+\sigma+a-1)\bigr).$$
$\Lambda(k,s)$ is the description length of a circuit of size $s$ when the pointers of gate $i$ are coded
optimally among the $k+i-1$ wires available to it; it is between $s(4+2\log_2k)$ and
$s(4+2\log_2(k+s-1))$, in agreement with "about $s(2\log_2(r+s)+4)$ bits".

*Two priors.* (i) The **fixed-size prior** is the uniform distribution on $\mathcal C_{k,s}$. (ii) The
**mixture prior** takes weights $w_s>0$ for $1\le s\le S$ with $\sum_sw_s=1$ and gives a circuit
$C\in\mathcal C_{k,s}$ the weight $q(C)=w_s\,2^{-\Lambda(k,s)}$; we write $l(C)=-\log_2q(C)$. The standing
assumption **(A1)** is that $w_s$ is nonincreasing in $s$ (for instance $w_s\propto2^{-|\bar e(s)|}$ made
monotone); then $q$ is nonincreasing in the size. We write $\varrho(\sigma,a)=w_{\sigma+a}/w_\sigma\le1$.
$S$ plays the part of both bounds of the note, the length bound $L$ and the schedule $T$: a circuit of
size $s$ does exactly $s$ gate operations per output bit.

*A literal code.* Where a block of bits has to *be* a description (Section 4) we use the fixed-width code
$e(C)=\bar e(s)\,\prod_i\tau_i\,[a_i]\,[b_i]$ with pointer fields of $\omega=\lceil\log_2(k+s)\rceil$ bits,
of length $l_{\rm fw}(C)=|\bar e(s)|+s(4+2\omega)$; a pointer field with value $c$ at gate $i$ is read as
wire $1+(c\bmod(k+i-1))$, so every string of the right length decodes.

*Seeds.* A **seeded circuit** has $k+r$ inputs, the last $r$ of which are fair random bits $\rho$; it lies
in $\mathcal C_{k+r,s}$ and gets weight $q(S)=\omega(r,s)\,2^{-\Lambda(k+r,s)}$ with $\omega(0,s)=w_s$. The
assumption **(A2)**, used only where stated, is $\omega(r,s)\le w_s$: a seeded format is not favoured over
the unseeded format with the same number of gates. $S_\rho$ denotes $S$ with the seed fixed to $\rho$.

### 1.2 Two ways to read a circuit as a hypothesis about a sequence

**Option I (generative).** The circuit has $r\ge1$ random inputs and $N$ output bits and induces a
distribution on $\{0,1\}^N$. The outputs are either (I-a) the last $N$ gates in order, or (I-b) $N$ output
pointers $o_1,\dots,o_N\in\{1,\dots,r+s\}$ to arbitrary wires, which are further independent parts of the
description of $\lceil\log_2(r+s)\rceil$ bits each. The context is the first $n$ output bits and the
continuation the next $m$.

**Option II (index).** Put $K=2^k$. The $k$ inputs carry the binary expansion of $t-1$ for a position
$t\in\{1,\dots,K\}$, and the circuit $C$ says that the bit at position $t$ is $C(t)$. The sequence it
"prints" is its truth table $\mathrm{tt}(C)=C(1)C(2)\cdots C(K)$. A context $x$ of length $n$ is explained
by $C$ if $x\preceq\mathrm{tt}(C)$, and $C$ then predicts the continuation $\mathrm{tt}(C)_{n+1:n+m}$. A
seeded circuit prints $\mathrm{tt}(S_\rho)$ with probability $2^{-r}$ for each $\rho$.

For Option II and the mixture prior let $\xi_s(x)$ be the fraction of $\mathcal C_{k,s}$ that prints $x$
and
$$\xi(x)=\sum_{s\le S}w_s\,\xi_s(x)=\sum_{C}q(C)\,[x\preceq\mathrm{tt}(C)],\qquad
\pi_m(y\mid x)=\frac{\xi(xy)}{\xi(x)}\quad(|x|+m\le K).$$
For a string $u$ of length at most $K$ let $\mathrm{size}(u)$ be the least $s$ such that some circuit in
$\mathcal C_{k,s}$ prints $u$.

**CA1 (PROVED). Option I-a under the fixed-size prior is the uniform measure.** Let $r\ge1$, $s\ge N$,
let the circuit be uniform on $\mathcal C_{r,s}$ and let the outputs be the last $N$ gates. Then for every
fixed $\rho$ the output is uniform on $\{0,1\}^N$. Hence $\pi_m(y\mid x)=2^{-m}$ for every context and
every block, and the same holds for any mixture over $s$ and $r$.

*Proof.* Condition on $\rho$ and on gates $1,\dots,s-N$. For $j=s-N+1,\dots,s$ in turn, the value of gate
$j$ is $\tau_j(u,v)$, where $(u,v)$ are the values of the two wires it points to. These are determined by
the earlier gates and by $(a_j,b_j)$, all of which are independent of $\tau_j$. The four entries of
$\tau_j$ are independent fair bits, so $\tau_j(u,v)$ is a fair bit independent of everything earlier,
including the values of gates $s-N+1,\dots,j-1$. $\square$

**CA2 (PROVED). Option I-b is exchangeable; the explanation of the context constrains the continuation
only through the frequency of ones.** Let the prior on $(r,s,\text{gates})$ be arbitrary and let, given
these, the output pointers be independent and uniform on the $r+s$ wires (as they are whenever the
description length does not depend on where a pointer points). Let $p=p(\text{gates},\rho)$ be the
fraction of the $r+s$ wires that carry the value $1$. Then for every $x\in\{0,1\}^n$ with $j$ ones
$$\xi(x)=\mathbb E\bigl[p^{\,j}(1-p)^{\,n-j}\bigr],$$
so $\xi$ is invariant under permutations of the positions, and $\pi_m(y\mid x)$ depends on $x$ and $y$ only
through their numbers of ones. If every circuit in the support has at most $W$ wires and, for every
seed, a wire with value $0$ and one with value $1$, then $\pi_m(y\mid x)\ge W^{-m}$ for every $x$ and $y$.

*Proof.* Given the gates and $\rho$ every wire has a value, and the output bits are independent draws of
the value of a uniform wire, that is, independent Bernoulli($p$). Average over gates and $\rho$. For the
last claim $1/W\le p\le1-1/W$ in every term. $\square$

*What CA1 and CA2 say.* In Option I a gate or pointer that serves the continuation is a part of the
description that the context does not touch. Under I-a the predictor has learned nothing after any
amount of data. Under I-b it is a frequency estimator: on the context $0101\cdots01$ it predicts exactly
as on $0\cdots01\cdots1$. Neither can express "predict well up to the use and then deviate", because
neither predicts well. The continuation with its bits replaced by constants costs the same number of
bits as the honest continuation ($m$ pointers to constant wires instead of $m$ pointers elsewhere), or
fewer, since the gates that served only the honest continuation become dead and can be deleted. So in
Option I the "wrapper" has cost at most zero and every block of a given number of ones has the same
posterior as the truth. Option I is used below only for the counting obstruction to self-reproduction
(CA9). The link between context and continuation that makes induction possible is the reuse of the same
gates at different positions, which is Option II (and, with state, Section 11).

**CA3 (PROVED). Option II is a bounded mixture in the sense of the note, and it is a measure.** For the
mixture prior, $\xi(\epsilon)=1$ and $\xi(x0)+\xi(x1)=\xi(x)$ for $|x|<K$. Consequently
$Z_m(x)=\sum_{y\in\{0,1\}^m}\xi(xy)=\xi(x)$ whenever $|x|+m\le K$. Up to the use of non-integer code
lengths, $\xi=\xi_V^{T,L}$ of `def:mixture` for the monotone machine $V$ that reads $\bar e(s)$ and a
description of a circuit of size $s$ and then prints its truth table, with a schedule $T(n)$ of order
$S\cdot n$.

*Proof.* Every circuit has a truth table of exactly $K$ bits, so the sets $\{C:x\preceq\mathrm{tt}(C)\}$
for $x\in\{0,1\}^n$ partition the set of all circuits. $\square$

*Consequence used repeatedly.* A circuit that "prints the context and then nothing" does not exist: every
hypothesis and every world has a next bit. The quantity $\varphi$ of `prop:honest` (the share of users
that go on printing) is $1$, and the loophole "the users wait for the answer, so nothing honest competes"
is closed in this toy.

### 1.3 Worlds, critical uses, and running a block

A **world** is a circuit $W\in\mathcal C_{k,\sigma}$; its transcript is $\mathrm{tt}(W)$; $\sigma$ may
exceed $S$. A **test** is a set $G$ of nonempty strings of length less than $K$; a world *hands over* at
the first hit $x=\mathrm{tt}(W)_{1:n}$ if $n+m\le K$. Its **own continuation** is
$d=\mathrm{tt}(W)_{n+1:n+m}$, which always exists. A **call rule** is a set $\mathcal C$ of pairs
$(W,n_W)$, at most one for each circuit; the world $W$ makes a critical use at the context
$x_W=\mathrm{tt}(W)_{1:n_W}$. As in `def:call`,
$$C(x)=\sum_{W:\,x_W=x}q(W),\qquad H_{\mathcal C}=\sum_{(W,n_W)\in\mathcal C}q(W),\qquad\kappa(x)=\frac{C(x)}{\xi(x)} .$$
No prefix-freeness is needed: a circuit is a finite object and reads nothing beyond itself.

*Running a block.* The predictor returns $Y\in\{0,1\}^m$. To run it, decode it: $D(y)$ is the circuit $C$
with $y=e(C)\,1\,0^{j}$ for some $j\ge0$ (the literal code of 1.1), if there is one. The world then
continues as $D(y)$, that is, its transcript becomes $\mathrm{tt}(D(y))$ from the beginning, as the
program world continues as $U$ on $y0^\infty$. A block that does not decode is taken to do nothing. The
analogue of `def:sr` is
$$\mathrm{SR}_m(x)=\bigl\{y\in\{0,1\}^m:\ D(y)\text{ is defined and }xy\preceq\mathrm{tt}(D(y))\bigr\}:$$
the block describes a circuit whose truth table shows the context and then the block itself. The
critical-use form and the forms for one world of `def:mph` are taken over without change.

---

## 2. Calibration and budget transfer verbatim

**CA4 (PROVED). Calibration (`thm:calibration`).** Let $G$ be a test and let the world be drawn from the
mixture prior $q$. Let $X$ be the first hit of $G$ among the prefixes of its transcript (on the event that
there is one, of length $n\le K-m$), $D$ the next $m$ bits of the transcript, and $Y$ a sample from
$\pi_m(\cdot\mid X)$. Then given $X=x$ the blocks $D$ and $Y$ are independent with the common law
$\pi_m(\cdot\mid x)$. In particular $\Pr[(X,Y)\in B]=\Pr[(X,D)\in B]$ for every set $B$ of pairs, for
instance $B=\{(x,y):y\in\mathrm{SR}_m(x)\}$.

*Proof.* First hits are pairwise incomparable, so $\Pr[X=x,D=d]=\xi(xd)$ and $\Pr[X=x]=\xi(x)$ by CA3.
$Y$ is drawn from $\pi_m(\cdot\mid x)$ independently of the world. $\square$

The first of the three qualifications in the note disappears: by CA3 no world prints fewer than $m$
further bits, so the predictor returns each block exactly as often as worlds continue with it. The other
two stand: the statement is about worlds drawn from the predictor's own prior (so of size at most $S$),
and about a use that can be read off the data.

**CA5 (PROVED). Budget (`thm:budget`).** Let $z=\mathrm{tt}(W)$ for a circuit $W$ with $q(W)>0$. With
$\tau_m(n)=1-\xi(z_{n+1:n+m}\mid z_{1:n})$,
$$\sum_{n=0}^{K-1}\bigl(1-\xi(z_{n+1}\mid z_{1:n})\bigr)\le l(W)\ln2,\qquad
\sum_{n=0}^{K-m}\tau_m(n)\le m\,l(W)\ln2,\qquad\#\{n:\tau_m(n)\ge\tfrac12\}\le m\,l(W),$$
where $l(W)=\log_2(1/w_\sigma)+\Lambda(k,\sigma)\le\log_2(1/w_\sigma)+\sigma\bigl(4+2\log_2(k+\sigma-1)\bigr)$.

*Proof.* The proof of `thm:budget` uses only that $\xi$ is a semimeasure with $\xi(z_{1:N})>0$; here
$\xi(z_{1:K})\ge q(W)$. $\square$

The budget has content when $m\,\sigma\,(4+2\log_2(k+\sigma))\ll 2^k$, that is, when the world is much
smaller than its own truth table. It is void for a world of size above $S$. Almost every sequence of
length $2^k$ needs a circuit of about $2^k/k$ gates (Shannon; KNOWN), so the regime "the world is too
expensive for the predictor" is the generic one for arbitrary sequences, as in the note.

---

## 3. The wrapper floor

In the program toy the twin machine copies $U$ and checks after every bit whether the prefix so far is in
$G$. A circuit in Option II computes the bit at position $t$ from $t$ alone. It can test the *position*
cheaply; it can test the *data* only by recomputing them (CA8). So the natural test is "the position lies
in the block $[n+1,n+m]$", the note's test $G=\{x:|x|=n\}$.

**CA6 (PROVED). Sizes of the parts of a wrapper.** Over the full binary basis:

* (a) For a constant $c$, the function $[\,t-1\ge c\,]$ of the index is a constant, an index wire, or
  computed by at most $k-1$ gates.
* (b) The interval test $I_{n,m}(t)=[\,n<t\le n+m\,]$ is computed by at most $2k-1$ gates.
* (c) Every Boolean function of $j\ge2$ variables is computed by at most $2^j-3$ gates. Hence for every
  block $y\in\{0,1\}^m$ with $n+m\le K$ there is a circuit $P_{n,y}$ on the index with
  $P_{n,y}(n+i)=y_i$ for $1\le i\le m$ and at most $p(m)=\max(1,2^{\lceil\log_2m\rceil}-3)\le\max(1,2m-5)$
  gates.
* (d) The selector $\mathrm{mux}(c;u,v)=(c\wedge v)\vee(\neg c\wedge u)$ is three gates.
* (e) For $m=1$ and $k\ge2$: the circuit that agrees with a given wire except that it has the value $y_1$
  at position $n+1$ needs $k$ further gates.

*Proof.* (a) Let $b_0,\dots,b_{k-1}$ be the index bits and $c_0,\dots,c_{k-1}$ those of $c$ (for $c\le0$
or $c\ge K$ the function is constant). Let $G_i=[\,(b_i\dots b_0)\ge(c_i\dots c_0)\,]$. Then $G_0$ is $b_0$
or the constant $1$, and $G_i=b_i\wedge G_{i-1}$ if $c_i=1$, $G_i=b_i\vee G_{i-1}$ if $c_i=0$; when
$G_{i-1}$ is a constant, $G_i$ is $b_i$ or a constant and needs no gate. So each of the steps
$i=1,\dots,k-1$ adds at most one gate. (b) $I_{n,m}=[t-1\ge n]\wedge\neg[t-1\ge n+m]$: two functions as in
(a) and one gate, which also serves to produce a gate wire when the result is a constant or an index
wire. (c) By induction: a function of two variables is one gate, and
$f=\mathrm{mux}(x_j;f_0,f_1)$ with $f_0,f_1$ functions of $j-1$ variables gives
$M(j)\le2M(j-1)+3$, so $M(j)+3\le2^{j-2}(M(2)+3)=2^j$. For the block, let $j=\lceil\log_2m\rceil\le k$. The
$m\le2^j$ consecutive numbers $t-1\in\{n,\dots,n+m-1\}$ are distinct modulo $2^j$, so there is a function of
the low $j$ index bits with the required values; for $j\ge2$ use the bound, for $j\le1$ one gate suffices.
(e) $[t=n+1]$ is a conjunction of $k$ literals, $k-1$ gates, and the output is
$u\wedge\neg[t=n+1]$ or $u\vee[t=n+1]$. $\square$

For a circuit $E\in\mathcal C_{k,\sigma}$, a position $n$ and a block $y$ let $\mathrm{Tw}_{n,y}[E]$ be the
circuit whose first $\sigma$ gates are those of $E$, followed by the gates of $I_{n,m}$, of $P_{n,y}$, and
the selector $\mathrm{mux}(I_{n,m};E,P_{n,y})$. It has $\sigma+a$ gates,
$$a=a(n,y)\le(2k-1)+p(m)+3\le2k+2m+1,$$
and for $m=1$ one can take $a=k$ by (e). More generally, for any test circuit of $g$ gates on the index
that is $0$ on $[1,n]$ and $1$ on $[n+1,n+m]$ and any payload circuit of $p$ gates, $a=g+p+3$.

**CA7 (PROVED). The floor for circuits (`thm:twin`).** Let $x$ have length $n$, let $y\in\{0,1\}^m$,
$n+m\le K$, and let $a$ be the number of gates added by the wrapper. Then
$$\xi(xy)\ \ge\ \sum_{\sigma=1}^{S-a}w_{\sigma+a}\,2^{-\Delta(\sigma,a)}\,\xi_\sigma(x),\qquad
\pi_m(y\mid x)\ \ge\ \sum_{\sigma=1}^{S-a}\varrho(\sigma,a)\,2^{-\Delta(\sigma,a)}\ \frac{w_\sigma\xi_\sigma(x)}{\xi(x)} .$$
In particular, if a share $\rho_{\sigma_0}(x)$ of the posterior at $x$ is on circuits of size at most
$\sigma_0\le S-a$, then
$$\pi_m(y\mid x)\ \ge\ \rho_{\sigma_0}(x)\cdot\min_{\sigma\le\sigma_0}\varrho(\sigma,a)\cdot
\bigl(16\,(k+\sigma_0+a-1)^2\bigr)^{-a}.$$
For the fixed-size prior on $\mathcal C_{k,s}$, $s>a$:
$\ \pi_m(y\mid x)\ge2^{-\Delta(s-a,a)}\,\xi_{s-a}(x)/\xi_s(x)$.

*Proof.* The map $E\mapsto\mathrm{Tw}_{n,y}[E]$ is injective from $\mathcal C_{k,\sigma}$ into
$\mathcal C_{k,\sigma+a}$, because $E$ is the list of the first $\sigma$ gates. If $E$ prints $x$ then
$\mathrm{Tw}_{n,y}[E]$ prints $xy$: the test is $0$ on $[1,n]$ and $1$ on the block. So the number of
circuits of size $\sigma+a$ that print $xy$ is at least $\xi_\sigma(x)|\mathcal C_{k,\sigma}|$, that is,
$\xi_{\sigma+a}(xy)\ge2^{-\Delta(\sigma,a)}\xi_\sigma(x)$. Multiply by $w_{\sigma+a}$ and sum. The third
display uses $\Delta(\sigma,a)\le a(4+2\log_2(k+\sigma+a-1))$. $\square$

*Reading.* The role of the constant $c$ of `thm:twin` is played by
$$c(\sigma)=\Delta(\sigma,a)+\log_2\frac1{\varrho(\sigma,a)}\ \approx\ a\,\bigl(4+2\log_2(k+\sigma)\bigr),\qquad a=g+p+3 .$$
Three differences from the program toy.

1. *It is not a constant.* It grows with the size $\sigma$ of the explanation, by $2\log_2(k+\sigma)$ bits
   per gate of the wrapper: every pointer of the wrapper is priced as a pointer among all wires of the
   circuit it sits in, although it points only into the wrapper. Under the literal fixed-width code it is
   worse at some sizes: if the $a$ new gates push $k+s$ across a power of two, every pointer field of the
   whole circuit grows by a bit and the wrapper costs $2\sigma$ bits more (PROVED:
   $l_{\rm fw}$ of the wrapped circuit is $|\bar e(\sigma+a)|+(\sigma+a)(4+2\omega')$ with
   $\omega'=\lceil\log_2(k+\sigma+a)\rceil$).
2. *Naming the position costs gates.* The test costs up to $2k-1$ gates, so about
   $2k\,(4+2\log_2(k+\sigma))$ bits, against the $K(n)\le\log_2n+2\log_2\log_2n+O(1)$ bits of the program
   toy. With $K=2^k$ positions the floor for a one-bit deviation at a given position is about
   $K^{-(4+2\log_2(k+\sigma))}$, against about $1/n$.
3. *A literal block costs more than its length.* A block of $m$ arbitrary bits costs a program $m+O(\log m)$
   bits. Here it costs up to $p(m)<2m$ gates, each of $4+2\log_2(k+\sigma+a)$ bits. By counting it cannot
   be cheap for most blocks under any wrapper: $\sum_y\pi_m(y\mid x)=1$, so at most $2^c$ blocks have share
   $2^{-c}$ or more. (Lupanov's bound, KNOWN, would lower $p(m)$ to $(1+o(1))m/\log_2m$ gates; the cost in
   bits is then still about $2m\cdot\log_2(k+\sigma)/\log_2m$.)

*Sizes* (arithmetic from the formulas, $\varrho$ ignored). For $k=20$ and $\sigma=1000$: a one-bit
deviation at one position costs $a=20$ gates, about $480$ bits; a block of $m=64$ arbitrary bits at one
position costs $a\le103$ gates, about $2500$ bits. In the program toy the same two wrappers cost
$K(n)+O(1)$ and $K(n)+64+O(1)$ bits.

**CA8 (upper bound PROVED; that nothing essentially cheaper exists is HEURISTIC). Tests that look at the
data.** Let the test be "the $w$ bits before position $t$ equal a marker $u$", or any function $\phi$ of
those $w$ bits with a circuit of $g_\phi$ gates. A wrapper for it exists with at most
$$a\le w\,(\sigma+2k)+g_\phi+p+3$$
added gates: $w$ copies of $E$, each fed with the index $t-i$ computed by a subtractor of at most $2k$
gates (one sum gate and one borrow gate per bit), then $\phi$, the payload and the selector. A test that
depends on the whole prefix, such as "first hit of $G$", needs a copy of $E$ for every earlier position
that $G$ looks at. *Why the matching lower bound is only heuristic:* a hypothesis could compute the same
predicate by a cheaper route for a particular $E$, and a general lower bound of the form $w\sigma$ would be
a circuit lower bound of a kind nobody can prove. Two cases where a data-dependent test is cheap are
proved: the marker's position is itself a simple function of $t$ (then it is a position test), and the
world's own circuit carries a wire that fires at the use (CA23(d)).

So the statement "at every use that a fixed test recognises, a fixed continuation has at least a share
$2^{-c}$, whatever the world and the amount of data" becomes: at every use at a *position* that a circuit
of $g$ gates recognises, a continuation with a circuit of $p$ gates has at least a share
$2^{-(g+p+3)(4+2\log_2(k+\sigma+g+p+2))}$ of the posterior mass on explanations of size at most $\sigma$
(times $\varrho$). It depends on the world through $\log_2\sigma$ and on the amount of data through $k$.

---

## 4. Self-reproduction

**CA9 (PROVED). In Option I no circuit outputs its own description, and lineages shrink.** Take the
literal code for Option I-b: $l_{\rm fw}(C)=|\bar e(r)|+|\bar e(s)|+|\bar e(N)|+s(4+2\omega)+N\omega$ with
$\omega=\lceil\log_2(r+s)\rceil\ge1$ (as $r,s\ge1$). Then $l_{\rm fw}(C)\ge N+6s>N$: the description is
longer than the output. For I-a, $N\le s$ and $l_{\rm fw}(C)\ge6s\ge6N$. Hence no circuit emits its own
description, and if $C_0,C_1,\dots$ are circuits with $N_i$ outputs such that the output of $C_i$ contains
the description of $C_{i+1}$, then $N_{i+1}\le N_i-6$; the chain has at most $N_0/6$ members, and at most
$\log_2N_0$ if every member has at least three wires ($\omega\ge2$, so $2N_{i+1}<N_i$).

*Proof.* Count the fields. For the chain, $N_{i+1}\omega_{i+1}+6s_{i+1}\le l_{\rm fw}(C_{i+1})\le N_i$.
$\square$

**CA10 (PROVED). What is and is not independent of the encoding.** Let $\mathcal K$ be any finite set of
objects, each of which emits one string $\mathrm{out}(C)\in\{0,1\}^N$ (deterministic circuits with $N$
output bits, or circuits in Option II with $\mathrm{out}(C)=\mathrm{tt}(C)_{n+1:n+N}$), and let
$e\colon\mathcal K\to\{0,1\}^*$ be injective. Call $C$ a *quine for $e$* if $\mathrm{out}(C)=e(C)$.

* (a) There is at most one quine for each emitted string, so at most $2^N$ quines; under the uniform prior
  on $\mathcal K$ their mass is at most $2^N/|\mathcal K|$. For the format of CA2 with the seed fixed and
  $r+s\ge3$ wires this is at most $(2/3)^N16^{-s}$.
* (b) If $e$ is a prefix code and the prior is $2^{-|e(C)|}$, every quine has weight exactly $2^{-N}$.
* (c) REFUTED: "under every encoding, self-reproducers are rare". If every string of $\{0,1\}^N$ is
  emitted by some member of $\mathcal K$, there is a prefix code under which the quines have total weight
  $1-2^{-N}$: choose for each $y\ne1^N$ one $C_y$ with $\mathrm{out}(C_y)=y$, put $e(C_y)=y$, and give all
  other members codewords that begin with $1^N$.

*Proof.* (a) If $C,C'$ are quines with the same output then $e(C)=e(C')$, so $C=C'$. The format has at
least $16^s(r+s)^N$ members. (b) $|e(C)|=|\mathrm{out}(C)|=N$. (c) The code is prefix-free and there are
$2^N-1$ quines of weight $2^{-N}$. $\square$

So the obstruction of CA9 is a property of encodings that describe a circuit gate by gate, in which each
output costs at least one bit of its own; it is not a property of circuits. This is the counterpart of
`thm:machine` for self-reproduction.

**CA11 (PROVED). Option II: necessary conditions (`thm:quine`, the "forced" part).**
* (a) For each $n$, at most $2^m$ contexts $x\in\{0,1\}^n$ have $\mathrm{SR}_m(x)\ne\emptyset$.
* (b) If $y\in\mathrm{SR}_m(x)$ then $D(y)$ has at least $\mathrm{size}(x)$ gates and
  $m\ge l_{\rm fw}(D(y))+1\ge\mathrm{size}(x)\,\bigl(4+2\lceil\log_2(k+\mathrm{size}(x))\rceil\bigr)+1$.
* (c) If a world hands over at $x$ under the test "the length is $n$" and receives $y\in\mathrm{SR}_m(x)$,
  the new world $D(y)$ hands over at $x$ again with own continuation $y$; `prop:lineage`(b) holds verbatim.

*Proof.* (a) $y$ determines $D(y)$ and hence $x=\mathrm{tt}(D(y))_{1:n}$. (b) $D(y)$ prints $x$. (c) By
definition of $\mathrm{SR}_m$. $\square$

**CA12 (HEURISTIC). Self-describing circuits exist in Option II, at a cost that multiplies the description
instead of adding a constant to it.** *Claim.* For every circuit $E$ that prints $x$ there is a circuit
$Q_E$ with $x\,e(Q_E)\,1\preceq\mathrm{tt}(Q_E)$, provided $2^k$ exceeds $n$ plus its description length; and
$l_{\rm fw}(Q_E)\ge l_{\rm fw}(E)+(\text{the cost of storing }l_{\rm fw}(E)\text{ arbitrary bits in gates})$,
which with the constructions known to me is between $2\,l_{\rm fw}(E)$ and
$l_{\rm fw}(E)\cdot(8+4\log_2(k+s))$ further bits.

*Sketch.* $Q_E$ consists of $E$; a table $\mathrm{DATA}$ in a fixed regular layout (a selector tree over
constant gates, as in CA6(c)) that stores the string $w=e$-records of $E$ and of $\mathrm{LOGIC}$; a
circuit $\mathrm{LOGIC}$ of size polynomial in $k$ which, given $t$, decides whether position $t-n$ of the
description falls in the header, in the records of $E$ and $\mathrm{LOGIC}$ (then it returns the
corresponding bit of $w$ from the table), or in the records of the table itself (then it computes the bit
from the regular layout, looking up one bit of $w$ when the record is that of a constant gate); and the
selector of CA6. The table is addressed through one computed address, so one copy suffices. The size of
$\mathrm{LOGIC}$ does not depend on the contents of the table, so the sizes can be fixed first and the
table filled afterwards; this is the usual proof of the recursion theorem.

*Why it is not a theorem here.* $\mathrm{LOGIC}$ is not written out at gate level, so no constant is
explicit; and the claimed lower bound on the cost would be a circuit lower bound.

*The point that is solid.* The program quine of `thm:quine` keeps a record of the input bits it has read
and prints them: a program can treat its own text as data at no cost in length, so quining costs the
additive constant $|q|$. A circuit cannot read its gates. Whatever a circuit emits has to be computed by
gates from the index, so a self-describing circuit carries a second copy of the description of everything
in it except the regular table, stored *in gates*, at more than one bit of description per stored bit
(CA7, reading 3). The self-reproducing floor $2^{-c}\rho^\circ(x)$ of the program toy, a constant fraction
of the mass of the explanations that fit into a block, becomes on this estimate the following: the
self-describing version of an explanation $E$ has weight about $q(E)^{1+\beta}$, where $\beta$ is the number
of bits of description needed per stored bit ($\beta\ge1$ for typical contents by counting, $\beta\ge2$ for
the constructions I know). So the self-reproducing continuations hold a *power* of the honest mass, at
least its square, and not a constant fraction of it.

*Weaker notions that survive, with proofs.* (i) A circuit can emit a *smaller* circuit: the wrapper of CA7
with $y=e(C')10^*$ for any $C'$ with $l_{\rm fw}(C')<m$. (ii) For all but a fraction $2^{-j}$ of the
circuits $C'$ of a given format, every circuit that emits $e(C')$ has description length at least
$\log_2(\#\text{format})-j$ (counting: fewer than $2^{b}$ circuits have description length below $b$).
So along a chain $C_0\to C_1\to\cdots$ in which each member emits the next and the members are typical of
their formats, description lengths decrease strictly; the chain ends. Persistence in the sense of
`prop:lineage`(b) needs the exact fixed point of CA12.

---

## 5. Universality and search

In the program toy a seeker is a word $v$: the programs $v\omega$ share the cost $|v|$, and the rest of
the input $\omega$ selects the world that is followed. The faithful analogue of "one seeker" is one seeded
circuit $S$: one description, with the seed $\rho$ in the part of $\omega$. Its posterior share at a
context is $\mathrm{sh}_S(x)=q(S)\Pr_\rho[x\preceq\mathrm{tt}(S_\rho)]/\xi(x)$, where $\xi$ is the mixture
over all formats in use (it includes the unseeded circuits of size at most $S$).

**CA13 (PROVED). Two lemmas.**
* (a) *Reading.* A circuit with $s$ gates and one output depends on at most $s+1$ of its inputs. At most
  $2s$ inputs are pointed to by any gate.
* (b) *Hardwiring.* For every seeded circuit $S\in\mathcal C_{k+r,s}$ and every seed $\rho$ there is a
  circuit $S_\rho\in\mathcal C_{k,s}$, with the same number of gates, such that $S_\rho(t)=S(t,\rho)$ for
  all $t$. As a description, $S_\rho$ depends on $\rho$ only through the seed bits that some gate points
  to.

*Proof.* (a) Let $c\le s$ gates lie in the cone of the output. They have $2c$ pointers, and each of the
$c-1$ gates other than the output is pointed to by a gate of the cone. So at most $c+1$ pointers go to
inputs. (b) Go through the gates in order. If the pointer $a_i$ goes to a seed bit with value $c$, replace
$\tau_i$ by $\tau_i'(u,v)=\tau_i(c,v)$ and let $a_i$ point to wire $1$; likewise for $b_i$. Renumber the
other pointers. Every gate computes the same value as before. $\square$

**CA14 (PROVED). For circuits the description length of a hypothesis is at least its computation.**
* (a) A circuit $C\in\mathcal C_{k,s}$ produces each output bit by at most $s$ gate evaluations, and
  $l(C)\ge\Lambda(k,s)\ge s\,(4+2\log_2k)$. So a hypothesis that spends $\theta$ gate evaluations on one
  output bit has prior weight at most $2^{-(4+2\log_2k)\,\theta}$, and at most $2^{-4\theta}$ for every
  $k$.
* (b) Every circuit, seeded or not, of which some seed instance prints $u$ has at least $\mathrm{size}(u)$
  gates; a deterministic one has weight at most $w_{\mathrm{size}(u)}2^{-\Lambda(k,\mathrm{size}(u))}$
  under (A1).
* (c) There is no prefix word. In `def:universal` a word $v$ changes how the rest of the input is read,
  $\mathrm{out}_U(v\omega)=\mathrm{out}_V(\omega)$, at the fixed price $|v|$ and for computations of any
  length. For circuits the map from descriptions to functions is fixed: each gate of the description is
  one operation, performed once per output bit, and the first $g$ gates of a description have no effect
  on what the later gates compute except as wires they may point to.

*Proof.* (a) and (c) restate the definition of evaluation; the bound on $\Lambda$ is in 1.1. (b) By
CA13(b) the instance is a circuit with the same number of gates that prints $u$. $\square$

This is the sense of the phrase, and it is the main structural difference. In the program toy the weight
$2^{-|p|}$ of a hypothesis does not depend on its running time, and the schedule $T$ is the only thing
that charges for computation. Here the charge is built into the prior, at more than four bits per
operation per output bit.

**CA15 (PROVED). On average a family gains at most the base rate (`thm:search`(a)).** Let $G$ be a test
with $H_G=\sum_{x\text{ first hit}}\xi(x)>0$ and $\mathcal F$ a set of circuits with
$\mathrm{sh}_{\mathcal F}(x)=q\{C\in\mathcal F:x\preceq\mathrm{tt}(C)\}/\xi(x)$. Then
$$\sum_{x\text{ first hit}}\frac{\xi(x)}{H_G}\,\mathrm{sh}_{\mathcal F}(x)=\frac{q\{C\in\mathcal F:\ \mathrm{tt}(C)\text{ has a prefix in }G\}}{H_G}\le\frac{q(\mathcal F)}{H_G},$$
and the same with a seeded circuit and $q(S)$ in place of $\mathcal F$ and $q(\mathcal F)$. A single
unseeded circuit has a positive share at no more than one first hit.

*Proof.* First hits are pairwise incomparable, so the events are disjoint. $\square$

**CA16 (PROVED). A circuit that serves $N$ targets.** Let $S$ be a seeded circuit with $s\le S$ gates and
$r$ seed bits. Let $x_1,\dots,x_N$ be pairwise incomparable nonempty strings with
$p_i=\Pr_\rho[x_i\preceq\mathrm{tt}(S_\rho)]>0$ for all $i$.

* (i) $\sum_ip_i\le1$ and $N\le2^{\min(r,\,s+1)}$, so $s\ge\log_2N-1$.
* (ii) $\mathrm{size}(x_i)\le s$ for every $i$: the seeker is at least as large as the smallest explanation
  of every context it imitates.
* (iii) *One description.* Under (A1) and (A2),
  $$\mathrm{sh}_S(x_i)\ \le\ p_i\,2^{-(\Lambda(k+r,s)-\Lambda(k,s))}\ \le\ p_i,\qquad\text{so}\qquad
  \sum_{i=1}^N\mathrm{sh}_S(x_i)\le1,\quad\min_i\mathrm{sh}_S(x_i)\le\frac1N,$$
  and $S$ holds more than half of the posterior at no more than one of the contexts.
* (iv) *In terms of $N$.* $q(S)\le\omega(r,s)\,\bigl(16(k+r)^2\bigr)^{-s}\le16(k+r)^2\,N^{-(4+2\log_2(k+r))}$,
  and the mass of $S$ at its worst target is at most $q(S)/N$.
* (v) *All its instances together.* Let $\mathcal F_S=\{S_\rho\}_\rho\subseteq\mathcal C_{k,s}$ be the
  hardwired instances as unseeded circuits. Then $|\mathcal F_S|\le2^{\min(r,2s)}$. If $W_i$ is a circuit of
  size at most $\sigma\le s$ that prints $x_i$ (for instance the world that makes the use there), then
  under (A1)
  $$\sum_{i=1}^N\frac{q\{C\in\mathcal F_S:\ x_i\preceq\mathrm{tt}(C)\}}{q(W_i)}\ \le\ \frac{q(\mathcal F_S)}{w_\sigma2^{-\Lambda(k,\sigma)}}
  \ \le\ 2^{\,2s-\Delta(\sigma,\,s-\sigma)}\ \le\ 2^{\,2\sigma-(s-\sigma)(2+2\log_2(k+\sigma))} .$$
  This is at most $1$ as soon as $s-\sigma\ge\sigma/(1+\log_2(k+\sigma))$.
* (vi) *Search by tries.* If the function computed by $S$ depends on $b$ seed bits then $s\ge b-1$. A
  search that examines $J$ candidates, each given by $\beta$ fresh seed bits, and whose output depends on
  all of them, has at least $J\beta-1$ gates and so at least $4(J\beta-1)$ bits of description, while $J$
  tries raise the probability of a success by a factor of at most $J$.

*Proof.* (i) The events are disjoint. Two seeds that agree on the seed bits the output depends on give
the same function, and there are at most $s+1$ such bits by CA13(a). (ii) CA14(b). (iii) Take $\rho_i$
with $x_i\preceq\mathrm{tt}(S_{\rho_i})$. Then $S_{\rho_i}\in\mathcal C_{k,s}$ prints $x_i$, so
$\xi(x_i)\ge w_s2^{-\Lambda(k,s)}$, while $q(S)p_i=\omega(r,s)2^{-\Lambda(k+r,s)}p_i\le w_s2^{-\Lambda(k+r,s)}p_i$.
(iv) $\Lambda(k+r,s)\ge s(4+2\log_2(k+r))$ and $s\ge\log_2N-1$. (v) By CA13(b) the description $S_\rho$
depends on at most $\min(r,2s)$ seed bits; each member of $\mathcal F_S$ has weight $w_s2^{-\Lambda(k,s)}$;
the sets in the numerators are disjoint; $q(W_i)\ge w_\sigma2^{-\Lambda(k,\sigma)}$ by (A1); and
$\Delta(\sigma,a)\ge a(4+2\log_2(k+\sigma))$ with $a=s-\sigma$. (vi) CA13(a) and the union bound. $\square$

*Reading, against `thm:search`(b) and `thm:critical`(a).* The program seeker of length $a$ has the same
share $2^{-a}2^{j-1}\kappa(x)$ at *every* use, however many uses there are; the sum of its shares over the
uses is unbounded. The reason is that an instance $v\,\bar e(j)\,\omega_{1:r}$ pays $|v|$ once and then
only the bits that select the target, of which the search refunds $\log_2(1/H)$. For circuits, fixing the
seed is free (CA13(b): no gate is added, and the pointers get shorter), so the instance $S_\rho$ is a
hypothesis that weighs at least as much as the whole seeded circuit, and a single description cannot hold
a large share at many contexts: (iii). If one counts all instances as separate circuits, (v) says that
together, over *all* targets, they weigh less than one honest circuit of size $\sigma$ once the template
has about $\sigma/\log_2\sigma$ gates more than $\sigma$. A template that finds its target by simulating
candidates is far above that:

**CA17 (construction and linear lower bound PROVED; the $\sigma\log\sigma$ bounds KNOWN, from memory).
Universal circuits and the refund.**
* (a) *A crude universal circuit.* For all $k,\sigma$ there is a seeded circuit $U_\sigma$ with
  $r=\sigma(4+2\omega)$ seed bits, $\omega=\lceil\log_2(k+\sigma)\rceil$, and at most
  $\sigma\,(12(k+\sigma)+9)$ gates, such that every $W\in\mathcal C_{k,\sigma}$ equals $(U_\sigma)_\rho$ as a
  function for some $\rho$ (namely $\rho=$ the records of $W$ in the literal code).
* (b) *Lower bound.* Every seeded circuit with this property has at least $2^j-1$ gates,
  $j=\min(k,\lfloor\log_2(\sigma+3)\rfloor)$; this is more than $(\sigma+1)/2$ when $\sigma+3\le2^k$.
* (c) KNOWN (Valiant 1976 and later work; quoted from memory, constants not checked): universal circuits
  of size $c\,\sigma\log_2\sigma$ exist, with $c$ between about $3$ and $19$ depending on the construction
  and on what is counted, and $\Omega(\sigma\log\sigma)$ is necessary by counting, since circuits of size
  $\sigma$ compute $2^{\Omega(\sigma\log\sigma)}$ different functions.
* (d) *The refund exists in form and is worth nothing.* Fixing $c_0$ of the seed bits of $U_\sigma$ costs
  no gates (CA13(b)) and multiplies by $2^{c_0}$ the seed probability of every world consistent with the
  fixed bits. This is the analogue of the rescaler of `thm:search`(b): a structural call rule that fixes
  $c_0$ bits of the description has $H=2^{-c_0}$ within its format, and the seeker restricted to callers
  is repaid exactly $1/H$. By CA16(iii) its shares still sum to at most $1$ over its targets, and by (b),
  (c) and CA16(v) all its instances together weigh at most $2^{2\sigma-(s-\sigma)(2+2\log_2(k+\sigma))}$
  times one honest circuit of size $\sigma$, with $s\ge c\,\sigma\log_2\sigma$ on the known bounds: a
  factor $2^{-\Omega(\sigma\log^2\sigma)}$.

*Proof.* (a) Simulate the gates of $W$ in order. For gate $i$, each of its two operands is selected among
$2^\omega$ slots by a tree of $2^\omega-1<2(k+\sigma)$ selectors of three gates each, driven by the seed
bits of the pointer field; slot $c$ holds wire $1+(c\bmod(k+i-1))$ among the index wires and the outputs of
the earlier simulated gates. The truth table is applied by three more selectors driven by the two
operands, with the four seed bits of $\tau_i$ as data. That is fewer than $12(k+\sigma)+9$ gates per
simulated gate. (b) By CA6(c) and padding with unused gates, circuits of size exactly $\sigma$ compute
every function of $j$ index bits, $2^{2^j}$ functions; by CA13(a) a circuit with $s$ gates has at most
$2^{s+1}$ different instances as functions. (d) is CA13(b) applied to $c_0$ seed bits, then CA16.
$\square$

*What searching costs, in one sentence.* In the program toy the search costs time and input but no
length. Here it costs length: to imitate any one of the worlds of size $\sigma$ a hypothesis must contain
a universal circuit, of $\Theta(\sigma\log\sigma)$ gates and $\Theta(\sigma\log^2\sigma)$ bits, which is
more than the $\Lambda(k,\sigma)\approx2\sigma\log_2\sigma$ bits of the world it imitates; to try $J$
candidates it must contain $J$ of them (CA16(vi)). The cheapest hypothesis that follows a given world $W$
up to a use and then deviates is not a searcher but the wrapper of CA7 around $W$ itself, or a smaller
circuit that happens to print the context (CA23).

---

## 6. The honest restriction

**Definitions.** Let $E\in\mathcal C_{k,\sigma}$. A **gadget over $E$** with $a$ gates is a list
$\gamma=(\gamma_1,\dots,\gamma_a)$ of gates whose pointers go to index wires, to gates of $E$, or to earlier
gates of $\gamma$; there are $\prod_{j=1}^{a}16(k+\sigma+j-1)^2=2^{\Delta(\sigma,a)}$ of them. A circuit
$C\in\mathcal C_{k,\sigma+a}$ **realises** $(E,\gamma)$ if its gates can be split into $\sigma$ positions
that carry the gates of $E$ in order and $a$ positions that carry those of $\gamma$ in order, with the
pointers translated. $\mathrm{Real}(E,\gamma)$ is the set of these circuits; it contains the circuit "first
$E$, then $\gamma$". The gadget is **self-contained** if its gates point only to index wires, to the
output wire of $E$, and to earlier gates of $\gamma$. The wrappers of CA7 are self-contained gadgets:
$C=\mathrm{mux}(\text{trigger};E,\text{payload})$ with trigger and payload computed from the index. Fixing
the trigger to $0$ and deleting the dead gates returns $E$, the **honest restriction**.

**CA18 (PROVED). One gadget, all the ways of attaching it.** For every $E\in\mathcal C_{k,\sigma}$ and
every gadget $\gamma$ with $a$ gates,
$$q\bigl(\mathrm{Real}(E,\gamma)\bigr)\ \le\ \binom{\sigma+a}{a}\,\varrho(\sigma,a)\,2^{-\Delta(\sigma,a)}\,q(E)
\ \le\ \frac{\varrho(\sigma,a)}{a!}\Bigl(\frac{\sigma+a}{16\,(k+\sigma)^2}\Bigr)^{a}q(E).$$
So the honest restriction outweighs all placements of the gadget together by at least
$a\,\bigl(4+2\log_2(k+\sigma)-\log_2(\sigma+a)\bigr)+\log_2a!$ bits: the bits saved, less the logarithm of
the number of ways to interleave. For $a\le\sigma$ this is at least $a\,(3+\log_2(k+\sigma))$.

*Proof.* A realisation is determined by the set of positions of the gadget's gates, so there are at most
$\binom{\sigma+a}{a}\le(\sigma+a)^a/a!$ of them, each of weight
$w_{\sigma+a}2^{-\Lambda(k,\sigma+a)}=\varrho\,2^{-\Delta(\sigma,a)}q(E)$, and
$2^{-\Delta(\sigma,a)}\le(16(k+\sigma)^2)^{-a}$. For the last claim $\sigma+a\le2(k+\sigma)$. $\square$

**CA19 (PROVED). All small self-contained wrappers together are outweighed (`prop:honest`).** Let
$A\ge1$ and let $E\in\mathcal C_{k,\sigma}$ with $k+\sigma\ge4(k+A)^2$. Let $\mathrm{Wr}_A(E)$ be the set of
all circuits that realise $(E,\gamma)$ for some self-contained gadget $\gamma$ with at most $A$ gates. Then
under (A1)
$$q\bigl(\mathrm{Wr}_A(E)\bigr)\ \le\ \sum_{a=1}^{A}\frac{2^{-a}}{a!}\,q(E)\ <\ 0.65\,q(E).$$
Consequently, for a context $x$, if $\mathrm{Hon}_A(x)$ is the set of circuits $E$ that print $x$ and have
$k+\sigma_E\ge4(k+A)^2$, the circuits in $\bigcup_{E\in\mathrm{Hon}_A(x)}\mathrm{Wr}_A(E)$ have posterior
share at most $0.65$ times the share of $\mathrm{Hon}_A(x)$. This covers every test and every payload that
are computed from the index with at most $A-3$ gates together, in particular every position wrapper of
CA7 with $2k+2m+1\le A$.

*Proof.* A self-contained gadget with $a$ gates is one of $\prod_{j=1}^a16(k+j)^2\le16^a(k+a)^{2a}$. By
CA18 and $\varrho\le1$ the realisations of all of them weigh at most
$$\frac1{a!}\Bigl(\frac{(k+a)^2}{k+\sigma}\cdot\frac{\sigma+a}{k+\sigma}\Bigr)^a q(E)\le\frac1{a!}\Bigl(\frac{2(k+A)^2}{k+\sigma}\Bigr)^aq(E)\le\frac{2^{-a}}{a!}\,q(E),$$
using $a\le A\le k+\sigma$. Sum over $a$: $\sum_{a\ge1}2^{-a}/a!=e^{1/2}-1$. $\square$

Compare `prop:honest`: there one seeker is bounded by its twin, by $1/(1+2^{a-h}\varphi)$, and seekers add.
Here $\varphi=1$ (CA3), the comparison is with the circuit itself and not with a twin that has to be
constructed, and the bound is on the *sum* over all triggers and payloads of the class. The price is the
restriction to self-contained gadgets and to worlds that are large compared with the square of the
gadget.

**Exactly what CA18 and CA19 do not cover.**
1. *Gadgets that read the inside of the explanation.* If the trigger or the payload is a wire of $E$
   (CA23(d)), CA18 still bounds each gadget, but the number of such gadgets is $2^{\Delta(\sigma,a)}$ and
   the bound on the class is void, as it must be: "$E$ and then $a$ arbitrary gates on its wires" includes
   circuits that compute anything.
2. *Small worlds and long blocks:* $k+\sigma<4(k+A)^2$, for instance $m>\sqrt\sigma/4$.
3. *Circuits with no honest restriction.* A circuit that prints the context but contains no closed
   subcircuit that prints it without the trigger: the computation of the context is itself entangled
   with what happens at the use. In particular every circuit smaller than all honest explanations of the
   context and its true continuation (CA23).
4. *What the restriction predicts.* $E$ is trigger-free, not true: the bound compares wrappers with the
   explanations they wrap, and says nothing about how the mass of the explanations of $x$ divides between
   the world's own continuation and others.
5. *Templates with seeds.* They are bounded by CA16, not here.

**CA20 (PROVED). Critical uses (`thm:critical`): what transfers.** Let a call rule have $H_{\mathcal C}>0$,
let $X$ be the context of a world drawn from the prior conditioned on making a critical use, $n_X$ its
length, and $Y$ the predictor's sample. For blocks $y_x$ and the wrappers of CA7 with $a_x$ added gates,
$$\Pr[Y=y_X]\ \ge\ \mathbb E\Bigl[\sum_{\sigma\le S-a_X}\varrho(\sigma,a_X)2^{-\Delta(\sigma,a_X)}\frac{w_\sigma\xi_\sigma(X)}{\xi(X)}\Bigr],$$
and, if the calling circuits with context $x$ have size at most $S-a_x$, the wrappers around them alone
have share at least $\min_{\sigma\le S-a_x}\varrho(\sigma,a_x)2^{-\Delta(\sigma,a_x)}\cdot\kappa(x)$ at $x$. No factor $1/H_{\mathcal C}$ appears, and by
CA15 to CA17 none can be had by a single description: the "reach" of one seeker in the sense of
`thm:critical`(a) is that of the wrapper family, whose members each pay for a whole world.

*Proof.* CA7 at each context, averaged; for the second claim restrict the injection of CA7 to calling
circuits. $\square$

---

## 7. Seekers that are not written down

The note's paragraph: a word $p$ may describe a simple world with a cheap readout, in which inhabitants
arise who work out which critical uses are worth having and write predictions and continuations where the
readout reads them. Then $|p|$ is small, no goal is written anywhere, the honest twin does not apply, and
the only thing shown to exclude $p$ is a time bound.

**CA21 (PROVED). The reach statement transfers; so does an upper bound, whatever is inside.**
* (a) *Reach.* If $S$ is any seeded circuit with $\Pr_\rho[x\,y_x\preceq\mathrm{tt}(S_\rho)]\ge Q(x)$, then
  $\pi_m(y_x\mid x)\ge q(S)\,Q(x)/\xi(x)$. If $Q(x)\ge C_{\mathcal W}(x)/(2H_{\mathcal W})$ on a class
  $\mathcal W$ of uses, the mass of $S$ on $x\,y_x$ is at least $q(S)/(2H_{\mathcal W})$ times the mass of
  the worlds that make the use, at every use in $\mathcal W$.
* (b) *Upper bound.* Let the uses of $\mathcal W$ be $(W_i,x_i)$, $i\le N$, with pairwise incomparable
  contexts and worlds of size at most $\sigma$. Assume (A1), (A2). If a seeded circuit $S$ with $s$ gates
  outweighs the user at every one of them, $q(S)\,p_i>q(W_i)$ for all $i$, then
  $$s<\sigma,\qquad w_s2^{-\Lambda(k,s)}>N\,w_\sigma2^{-\Lambda(k,\sigma)},\qquad\mathrm{size}(x_i)\le s<\sigma\ \text{ for all }i .$$
  So a circuit, with or without a written goal, can outweigh the users of a class only if it is smaller
  than they are, by more than $\log_2N$ bits of description, and every one of their contexts has an
  explanation strictly smaller than the world that prints it.
* (c) If every $W_i$ is a smallest circuit for its own context, $\mathrm{size}(x_i)=\sigma_{W_i}$, then for
  every seeded circuit $S$: $\ \sum_iq(S)p_i/q(W_i)\le1$.

*Proof.* (a) is the definition of $\xi$ and of $\kappa$. (b) Summing,
$q(S)\ge q(S)\sum_ip_i>\sum_iq(W_i)\ge Nw_\sigma2^{-\Lambda(k,\sigma)}$ by (A1), while
$q(S)\le w_s2^{-\Lambda(k+r,s)}\le w_s2^{-\Lambda(k,s)}$ by (A2). If $s\ge\sigma$ the right side is at most
$w_\sigma2^{-\Lambda(k,\sigma)}$, a contradiction. The last claim is CA16(ii). (c) By CA16(ii) and
minimality $s\ge\sigma_{W_i}$ whenever $p_i>0$, so $q(S)\le q(W_i)$ and the sum is at most $\sum_ip_i$.
$\square$

In the program toy the corresponding condition is $H_{\mathcal W}<2^{-|p|-1}$ with $|p|$ the length of a
simple world and its readout, and nothing ties $|p|$ to the complexity of the targets. Here the weight of
$S$ is tied to its number of gates, and its number of gates to the computation of every context it
imitates. The two things the note could not bound, a goal that is not in the text and a search that is
not in the text, do not matter for (b) and (c): they are statements about the function computed.

**CA22 (PROVED; the answer to the question is no). There is no simple world with a long history.**
* (a) In a circuit of $s$ gates the bit at each position is the result of at most $s$ elementary events.
  A hypothesis in which the bit at some position depends on a history of $\theta$ gate evaluations has
  at least $\theta$ gates and weight at most $2^{-(4+2\log_2k)\theta}$ (CA14).
* (b) The inhabitants' computation is not free either: if a seed instance of the circuit prints the
  context of a target, the circuit has at least $\mathrm{size}(\text{that context})$ gates (CA14(b)); if
  it can do so for $N$ targets, it also has at least $\log_2N-1$ gates (CA16(i)); and by
  CA16(v) all its instances together are outweighed by a single honest circuit of size $\sigma$ once it has
  $\sigma\,(1+1/(1+\log_2(k+\sigma)))$ gates.
* (c) So the circuit analogue of "a simple world with a cheap readout whose inhabitants do unbounded
  computation for free" does not exist in the plain circuit toy. The world's history, the arising of the
  inhabitants, and their simulations of the targets are all gates, and gates are description.

*Proof.* (a), (b) are CA14 and CA16. (c) is their conjunction. $\square$

*Remark.* A cellular automaton of width $w$ run for $T$ steps, written out as a circuit with one block of
$g_0$ gates per cell and step, has $wTg_0$ gates. A particular automaton may have a smaller circuit for
the cell that is read; then that circuit, not the history, is the hypothesis, and by (a) it contains no
more computation than it has gates. The exclusion that the note obtains from a schedule whose first
deadline is below the seeker's start-up is here a consequence of the prior, with no schedule to choose.

---

## 8. Capture

In `thm:capture` a copy of the record at a location with a short code $\bar e(i_0)$ beats the sensor's
location. In a circuit every pointer to a wire of the same circuit costs the same. For a wire $v$ of a
circuit $W$ let the **cone** of $v$ be the set of gates on which $v$ depends, $\sigma_v$ their number,
$W|_v\in\mathcal C_{k,\sigma_v}$ the circuit they form with $v$ as output, and $X^v=\mathrm{tt}(W|_v)$ the
**stream** at $v$.

**CA23 (PROVED). Capture for circuits.** Let $W\in\mathcal C_{k,\sigma}$ be the world, $x$ the context of
length $n$ and $d$ its own continuation. Assume (A1).

* (a) *A copy with a smaller cone.* If $X^v_{1:n+m}=xy$ and $\sigma_v\le S$, then
  $\xi(xy)\ge w_{\sigma_v}2^{-\Lambda(k,\sigma_v)}$, so
  $$\frac{\pi_m(y\mid x)}{\pi_m(d\mid x)}\ \ge\ \frac{w_{\sigma_v}2^{-\Lambda(k,\sigma_v)}}{\xi(xd)} .$$
  If the world is most of what prints its own data, $\xi(xd)\le A\,q(W)$, the right side is at least
  $A^{-1}\,2^{\Delta(\sigma_v,\sigma-\sigma_v)}\ge A^{-1}\bigl(16(k+\sigma_v)^2\bigr)^{\sigma-\sigma_v}$.
* (b) *Most placements are expensive* (verbatim). If $N$ circuits (or wires) have streams that begin
  with $x$ and continue with pairwise different blocks $d_i$, then for every $\delta\in(0,1]$ all but at
  most $\delta N$ of them have $\xi(xd_i)<\xi(x)/(\delta N)$, and for these the odds of the $y$ of (a)
  against $d_i$ exceed $\delta N\,w_{\sigma_v}2^{-\Lambda(k,\sigma_v)}/\xi(x)$.
* (c) *All wires of one circuit are equally cheap to read, and multiplicity alone does not capture.* The
  circuits "$W$ followed by one gate that copies wire $v$" number $2(k+\sigma)+2$ for each $v$, all of
  weight $w_{\sigma+1}2^{-\Lambda(k,\sigma+1)}$. So if $\mu_y$ wires of $W$ carry $xy$ and $\mu_d$ carry
  $xd$, these readers have odds exactly $\mu_y:\mu_d$. But all of them together, for all wires, weigh at
  most $q(W)/4$.
* (d) *A switch read off the world.* If $W$ has a wire $f$ whose stream is $0$ on $[1,n]$ and $1$ on
  $[n+1,n+m]$, then for every payload circuit $P$ on the index with $p$ gates
  $\xi\bigl(x\,P(n+1)\cdots P(n+m)\bigr)\ge w_{\sigma+p+3}2^{-\Lambda(k,\sigma+p+3)}$; and if the payload is
  the stream of another wire $u$ of $W$, $\xi(x\,X^u_{n+1:n+m})\ge\varrho(\sigma,3)\bigl(16(k+\sigma+2)^2\bigr)^{-3}q(W)$.
  The position $n$ of the use costs nothing.

*Proof.* (a) $W|_v$ prints $xy$; then $\pi_m(y\mid x)/\pi_m(d\mid x)=\xi(xy)/\xi(xd)$ and
$q(W)=w_\sigma2^{-\Lambda(k,\sigma)}\le w_{\sigma_v}2^{-\Lambda(k,\sigma)}$. (b) The strings $xd_i$ are
pairwise incomparable, so $\sum_i\xi(xd_i)\le\xi(x)$. (c) The last gate is one of: first projection with
pointers $(v,b)$, $b$ arbitrary; second projection with $(a,v)$; AND or OR with $(v,v)$. These are
$2(k+\sigma)+2$ gates, different for different $v$. Their number over all $k+\sigma$ wires, divided by
$16(k+\sigma)^2$ and multiplied by $\varrho\le1$, is at most $(2(k+\sigma)+2)/(16(k+\sigma))\le\frac14$.
(d) Append $P$ and the selector $\mathrm{mux}(f;\text{output of }W,P)$, respectively the selector
$\mathrm{mux}(f;\text{output of }W,u)$ alone. $\square$

*What replaces the effect.* The place with a short code becomes the wire with a small cone: a record of
the same data that takes less computation to produce than the sensor's. The gain is
$2^{\Delta(\sigma_v,\sigma-\sigma_v)}$, more than $4+2\log_2(k+\sigma_v)$ bits per gate saved, so it is
large as soon as the copy is produced upstream of any appreciable part of the world. As in the note, the
copy needs only to carry the data, and there is a harmless reading: if the sensor's record is a function
of an upstream signal and the two never part, the smaller cone is simply the better explanation. More
generally, (a) with any circuit in place of $W|_v$: *every circuit smaller than the honest explanations of
$xd$ that prints $x$ and then something else is a capturing hypothesis*, and by CA21(b) this is the only
way in which a single description gets odds above $1$ against the users. By CA5 it can happen with a
majority at no more than $m\,l(W)$ positions of one world. Part (c) says that decoys inside one world do
not help unless they are cheaper to compute; part (d) is the circuit form of `thm:capture`(d) and is the
case that CA19 does not cover.

---

## 9. The basis and the encoding

**CA24 (PROVED). An encoding can be chosen to make either answer true (`thm:machine`).** Fix $n$, a block
$y$ and $j\ge1$. Let $q'$ be the prior under which the code $0\,c$ stands for $\mathrm{Tw}_{n,y}[E]$ and
the code $1^j0\,c$ for $E$, where $c$ is a code of $E$ of length $l(E)$. Every circuit has a code at most
$j+1$ bits longer than before, and for every context $x$ of length $n$ with $\xi(x)>0$
$$\pi'_m(y\mid x)\ \ge\ \frac1{1+2^{-j}} .$$
Likewise the prior $\frac12\delta_W+2^{-j-1}q$ predicts the continuation of a given circuit $W$ with
probability at least $1/(1+2^{-j})$ at every context of $W$.

*Proof.* $\mathrm{Tw}_{n,y}[E]$ prints $x$ exactly when $E$ does, and then it prints $y$. So
$\xi'(xy)\ge\frac12\xi(x)$ and $\xi'(x)=(\frac12+2^{-j-1})\xi(x)$. The second claim is the same computation.
$\square$

**CA25 (PROVED). A basis can make a chosen payload cost one gate.** Add to the binary basis one gate type
$g^*$ of fan-in $k+1$ with $g^*(t,u)=y_{t-n}$ for $n<t\le n+m$ and $g^*(t,u)=u$ otherwise, and let a gate
be described by its type (one of $17$, uniformly) and its pointers (uniformly). Then for every circuit
$E$ of $\sigma$ gates that prints $x$, the circuit "$E$, then $g^*$ on the index wires and the output of
$E$" prints $xy$ and has weight $\varrho(\sigma,1)\cdot\frac1{17}(k+\sigma)^{-(k+1)}$ times that of $E$. The
wrapper costs $\log_217+(k+1)\log_2(k+\sigma)$ bits whatever $m$ is, against about
$(2k+2m)(4+2\log_2(k+\sigma))$ in CA7.

*Proof.* The last gate has type $g^*$ with probability $1/17$ and its $k+1$ pointers are the right ones
with probability $(k+\sigma)^{-(k+1)}$. $\square$

**CA26 (PROVED). Within what factor sizes are invariant, and what no basis can do.**
* (a) If every gate of a basis $B'$ is computed by at most $c$ gates of a basis $B$, then
  $\mathrm{size}_B(f)\le c\cdot\mathrm{size}_{B'}(f)$ for every $f$. Between the full binary basis and
  $\{\wedge,\vee,\neg\}$ one can take $c=4$ in one direction and $c=1$ in the other. For the basis of CA25
  against the binary basis, $c$ is the binary size of $g^*$, up to $2k+p(m)+2$.
* (b) For every basis $B$ of gates of fan-in at most $d$, every explanation $E$ of $\sigma$ gates, and
  every $j\ge0$: for all but a fraction $2^{-j}$ of the blocks $y\in\{0,1\}^m$, every gadget of $a$ gates
  over $E$ that makes the circuit print $xy$ satisfies $a\,\log_2\bigl(|B|\,(k+\sigma+a)^d\bigr)\ge m-j$.

*Proof.* (a) Replace gate by gate; $a\oplus b=(a\vee b)\wedge\neg(a\wedge b)$ and its negation need four
gates, the other binary functions at most two. (b) Given $E$, different blocks need different gadgets,
and each gate of a gadget is one of at most $|B|(k+\sigma+a)^d$. The left side of the inequality
increases with $a$; let $a^*$ be the largest $a$ that violates it. A gadget with fewer than $a^*$ gates can
be padded with unused gates, so every block reached by a gadget that violates the inequality is reached
by one with exactly $a^*$ gates, and there are at most $(|B|(k+\sigma+a^*)^d)^{a^*}<2^{m-j}$ of those.
$\square$

*Reading.* The invariance is weaker than for universal machines in one respect and stronger in another.
Weaker: a change of basis multiplies sizes by a constant, so it raises weights to a power; the ratio of
the weights of two hypotheses is not preserved even up to a constant factor, and a basis or an encoding
built for the purpose makes a chosen payload cheap or even dominant (CA24, CA25), exactly as a machine
does in the note. Stronger: within gate-by-gate encodings over a basis of bounded fan-in and bounded
number of types, the factor is explicit and small for the standard bases, and by (b) no such basis makes
more than a $2^{-j}$ fraction of payloads cheaper than their length allows. A basis cannot supply an
interpreter. There is no circuit counterpart of the fact that one fixed word turns a universal machine
into any other.

---

## 10. Concentration

**CA27 (PROVED, as a corollary). Aiming does not pay.**
* (a) An unseeded circuit is already concentrated: all of its mass is on one sequence, so on one context
  of each length. Aiming at a use means being an explanation of that one context, at the full price of
  one (CA14(b)).
* (b) Let a seeded circuit $S$ aim at a class of $N$ uses with pairwise incomparable contexts. Its shares
  there sum to at most $1$ (CA16(iii)), so its average share over the class is at most $1/N$ whatever
  the prior mass $H_{\mathcal W}$ of the class. Selecting among the $N$ targets takes at least $\log_2N-1$
  gates and so at least $(\log_2N-1)(4+2\log_2(k+r))$ bits of description (CA16(i), (iv)), for the
  $\log_2N$ bits of seed that the selection replaces.
* (c) The family of wrappers $\{\mathrm{Tw}[W]:W\in\mathcal W\}$ has share at least
  $\min_\sigma\varrho2^{-\Delta(\sigma,a)}\kappa(x)$ at each use of the class, the same number for a rare
  class as for a common one.

*Proof.* (a) and (b) restate the cited claims; (c) is CA20. $\square$

In the program toy a seeker for a class $\mathcal W$ has share
$2^{-a_{\mathcal W}}C_{\mathcal W}(x)/(2H_{\mathcal W}M_U(x))$, which grows without bound as the class
gets rarer in the prior: this is the anthropic update, and it is what lets a program of fixed length hold
a majority at every use of a sufficiently rare class. For a circuit the rarity of the class is not
repaid. What a seeded circuit saves by not spending seed on non-users it has already more than paid in
the gates that tell users from non-users.

---

## 11. Shared weights, recurrence, uniform families

Everything above rests on CA14: one gate of description is one operation per output bit. The moment a
part of the description is used more than once per output bit, this fails. The cleanest case is a
recurrent circuit.

**Recurrent hypotheses.** Fix a state width $w\ge2$ and a program region of $L\le w-2$ bits. A **cell** is
a map $G\colon\{0,1\}^w\to\{0,1\}^w$ given by a circuit with $w$ inputs, $s$ gates and $w$ output
pointers; there are $\prod_{i\le s}16(w+i-1)^2\cdot(w+s)^w=2^{\Lambda_{\rm rec}(w,s)}$ of them. State bit
$1$ is an emit flag, bit $2$ an emit value, bits $3,\dots,L+2$ the program region, the rest the work
region. The run starts at $h_0=(0,0,p,0\cdots0)$ with $p\in\{0,1\}^L$ uniform, and $h_{j+1}=G(h_j)$; at
every step $j\ge1$ at which the flag of $h_j$ is $1$, the value bit of $h_j$ is appended to the output.
$t(G,p,n)$ is the step at which the $n$-th bit appears. With weights
$q_{\rm rec}(G)=\omega_{\rm rec}(s)2^{-\Lambda_{\rm rec}(w,s)}$, $\sum_s\omega_{\rm rec}(s)\le1$, and a
schedule $T$,
$$\xi^T_{\rm rec}(x)=\sum_Gq_{\rm rec}(G)\ \Pr_p\bigl[\,x\preceq\mathrm{out}(G,p),\ t(G,p,i)\le T(i)\text{ for }i\le|x|\,\bigr].$$
This is a recurrent network unrolled for as many steps as the schedule allows, with the description of
the cell paid once.

**CA28 (PROVED). Recurrence interpolates between circuits and time-bounded programs.**
* (a) $\xi^T_{\rm rec}$ is a bounded mixture in the sense of `def:mixture` (for the machine that reads a
  code of $G$ and then $p$, and iterates $G$). So `lem:basic`, `thm:calibration` (with its event $H_m$,
  since a recurrent hypothesis can stop emitting) and `thm:budget` hold for it, with
  $\ell=\log_2(1/q_{\rm rec}(G))+L$ for a world $(G,p)$.
* (b) *The description is paid once.* A cell of $s$ gates performs $s\cdot T(n)$ gate evaluations before
  its $n$-th bit and has the same weight for every schedule. The bound of CA14(a) fails by the factor
  $T(n)/n$.
* (c) *Bounded machines are dominated.* Let $M$ be any deterministic machine whose configurations are
  the strings of $\{0,1\}^w$, with the same conventions (flag, value, program region, work region
  initially zero) and step function $F_M$, and let $\xi^T_M(x)$ be the probability over $p$ that it prints
  $x$ on schedule. Then $F_M$ is computed by a cell $G_M$ with at most $w\,(2^w-3)$ gates, and for every
  $x$ and every schedule $T$
  $$\xi^T_{\rm rec}(x)\ \ge\ q_{\rm rec}(G_M)\ \xi^T_M(x),$$
  where the factor depends on $M$ and $w$ only: not on $T$, not on $x$, not on the program.
* (d) *Plain circuits are the case of a counter and one step per bit.* For every $C\in\mathcal C_{k,s}$
  there is a cell with $w=k+2$, $L=0$ and at most $s+2k+1$ gates that prints $\mathrm{tt}(C)$ with
  $t(n)=n$.
* (e) *What time-sharing alone leaves.* A cell in which $u$ next-state bits are pairwise different
  functions, none of them an input wire, has at least $u$ gates. So with sharing in time only, the
  description is at least the number of state bits that are actually updated: description pays for
  space, not for time.

*Proof.* (a) The hypotheses are the inputs of a machine that reads a prefix-free code and at most $L$
further bits; the proofs of the cited statements use nothing else. (b) By definition. (c) Each next-state
bit is a function of $w\ge2$ bits and has a circuit of at most $2^w-3$ gates (CA6(c)); pad to a common
size. $G_M$ is one of the cells in the sum, and its runs are those of $M$. (d) The state is (flag, value,
counter). The cell increments the counter (one gate for the low bit, then a sum gate and a carry gate per
bit: at most $2k$ gates), sets the flag by one constant gate, and sets the value to $C$ applied to the
old counter. Then $h_j$ carries $C(j)$ for $j\ge1$. (e) Different functions that are not input wires are
different gates. $\square$

*Reading of (c).* Take for $M$ the note's universal machine $U$ confined to configurations of $w$ bits,
with its program on the program region. Then $\xi_M^T$ is the note's $\xi_U^{T,L}$ with an added space
bound, and (c) says that the recurrent mixture contains it up to one constant factor, the price of one
universal cell, for all schedules at once. In the plain toy the corresponding price is a universal
circuit for each size of world separately, $\Theta(\sigma\log\sigma)$ gates (CA17), which is why it was
never worth paying.

**CA29 (HEURISTIC). At what point each program-side phenomenon returns.** The following is what the
note's theorems give when applied to $\xi_U^{T,L}$ with a space bound and transported by CA28(c). It is
labelled heuristic for two reasons: the note's constructions (twin, quine, rescaler) are for a machine
with unbounded work tape, and I have not re-checked step by step that each fits in a space bound; and
CA28(c) is a lower bound on $\xi_{\rm rec}(xy)$, so what comes back is a share *of the part of the
posterior that runs through the universal cell*, not of the whole posterior.

| phenomenon | plain circuits (Sections 3 to 10) | recurrent, description paid once |
|---|---|---|
| universality | a universal circuit per size, $\Theta(\sigma\log\sigma)$ gates, more than the world it imitates | one cell, paid once, as soon as steps per output bit exceed the overhead $\gamma$ of $U$ |
| wrapper floor | $2^{-(g+p+3)(4+2\log_2(k+\sigma))}$, grows with the world | $2^{-c}\rho$ with $c$ constant, when the schedule has the slack of `eq:slack` and the state has room |
| self-reproduction | no reading of one's own gates; cost a multiple of the description (CA12) | additive constant: the program region is state, so the text is data; `thm:quine` with blocks loaded into the program region |
| search, base-rate refund | worthless (CA16, CA17) | returns when the steps allowed before the first bit, $T(1)$, exceed the start-up of the enumeration; with $\tau$ steps per bit only searches by tries, gain at most about $\tau/t_0$ |
| simple world with a long history | none (CA22) | returns when $T(1)$ exceeds the history and $w$ the world's space; by CA28(e) the description still pays for the space unless the cell is also shared across space (a cellular automaton rule), in which case it is a constant |
| capture | smaller cone (CA23) | shorter program, as in `thm:capture` |

So the interpolation has two parameters. With no sharing the description pays for space and time
(spacetime volume). With sharing in time it pays for space. With sharing in time and space it pays for
neither, and one is back at programs with a time bound, where the note's results and the note's open
questions apply unchanged. A uniform family (one generator that outputs the circuit for each size) is
the same thing seen from the other side: the hypothesis is then the generator, which is a program.

---

## OVERALL VIEW

**PROVED.**
1. With one output wire per bit (Option I) there is no version of the question: the circuit predictor is
   the uniform measure or an exchangeable one, and every block with a given number of ones has the same
   posterior as the truth (CA1, CA2). The translation has to be to index circuits.
2. For index circuits, calibration and the budget are exactly as for programs: on its own prior the
   predictor returns each block as often as worlds continue with it, and along a world of description
   length $\ell$ the majority is off the truth at no more than $m\ell$ positions (CA4, CA5).
3. The wrapper floor survives in weakened form. A wrapper of $g+p+3$ gates costs
   $(g+p+3)(4+2\log_2(k+\sigma))$ bits: it grows with the size of the world, naming a position costs about
   $2k$ gates, a literal block of $m$ bits up to $2m$ gates, and a test on the data costs copies of the
   world (CA7, CA8). For $k=20$, $\sigma=1000$ the floor for one deviating bit is about $2^{-480}$.
4. A single description that serves $N$ uses has posterior shares that sum to at most $1$ over them, and
   all instances of a template with $\sigma/(1+\log_2(k+\sigma))$ more gates than $\sigma$ weigh together
   less than one honest circuit of size $\sigma$; a template that searches by simulation is far larger
   than that. The base-rate refund can be collected in form and is worth nothing, and the rarity of a
   class of uses is not repaid (CA16, CA17, CA27).
5. These bounds are about the function computed, so they hold for seekers that are not written down: a
   circuit outweighs the users of a class only if it is smaller than they are and each of their contexts
   has a smaller explanation than the world that prints it; and there is no simple world with a long
   history, because history is gates (CA21, CA22).
6. All self-contained wrappers of at most $A$ gates around an explanation with $k+\sigma\ge4(k+A)^2$
   together weigh less than $0.65$ of it (CA19).
7. What does give odds above $1$ against the truth is a strictly smaller circuit that agrees on the
   context, for instance a wire of the world with a smaller cone (CA23); and an encoding or a basis can be
   built to make any answer true (CA24, CA25).
8. When the description is paid once and applied repeatedly, the recurrent mixture contains the
   time-and-space-bounded program mixture up to one constant factor (CA28).

**ARGUED.**
9. Self-reproduction through the prediction channel is possible for index circuits but costs a multiple
   of the description, because a circuit cannot read its own gates; the self-reproducing share is then a
   power of the honest mass and not a constant fraction of it (CA12).
10. Therefore, in the plain circuit toy, the part of the malign-prior argument that runs through seekers
    has essentially no force. The hypotheses that predict well up to a use and then supply something of
    their own are, up to negligible terms, the wrappers, at shares of $2^{-\text{hundreds of bits}}$ and
    less; the mass off the truth at a use is dominated by smaller circuits that fit the context and
    continue differently, which is ordinary inductive error, bounded on average by the budget.
11. The program-side effects come back in proportion as computation is decoupled from description:
    universality and the constant floor at once with recurrence, search and simple worlds with long
    histories when many steps are allowed before the first output (CA29).

**GUESSED.**
12. Prevalence. For worlds drawn from the prior it is the calibrated base rate, as for programs. For a
    particular world in the plain circuit toy I guess that the share of critical uses that end with the
    world running something supplied by a hypothesis that sought the use is astronomically small, far
    below the program toy on any machine with a short interpreter, and that it is not the leading term of
    the predictor's error.
13. The leading term is capture by smaller circuits. I guess it is mostly approximation error with no
    particular direction. Nothing here excludes that the smallest circuit for some context is itself
    something that optimises and behaves differently off the context (the question of whether minimal
    circuits are free of such things, raised by Christiano and discussed by Hubinger; cited from memory).
    CA21 only says that such a circuit must be small.
14. For learned predictors the relevant quantity is, I guess, the ratio of serial computation per output
    to description length. A feed-forward network of fixed depth sits at the circuit end. A recurrent or
    autoregressive model run for many steps with a scratchpad sits toward the program end, and the
    argument regains force about where one output can contain a universal simulation and a search.

## DOUBTS

1. *The choice of Option II.* Option I is degenerate for the two output conventions treated; a generative
   circuit with structured outputs (shared gates across output positions) is a form of weight sharing and
   belongs to Section 11, where I only treated recurrence.
2. *Descriptions versus functions.* The prior is uniform on descriptions of a given size. Every bound
   here compares sets of descriptions and is rigorous as such, but I have not characterised the prior on
   functions that random circuits induce. Posterior shares depend on how many circuits compute each
   function, and "the honest mass" is bounded below by a single circuit throughout, which may be far from
   tight. CA16(v) counts $2^{2s}$ instances, which is generous.
3. *The size prior.* (A1) and (A2) are assumptions. If seeded formats are favoured over unseeded ones of
   the same size, CA16(iii) acquires the factor $\omega(r,s)/w_s$. Code lengths are idealised (not
   integers); under the literal fixed-width code the cost of a wrapper jumps by $2\sigma$ bits at powers
   of two.
4. *Hardwiring is free only in the full binary basis,* where a constant operand is absorbed into the truth
   table. In another basis it costs a bounded number of gates per seed bit, and CA16(iii) weakens by the
   corresponding factor.
5. *CA12 is a sketch.* Neither the existence with explicit constants nor the lower bound on the cost of a
   self-describing circuit is proved; for a highly regular explanation the cost might be much lower than
   the estimate. *CA8*: the lower bound is not proved. *CA17(c)*: constants quoted from memory.
6. *CA19 is limited* to self-contained gadgets and to explanations with $k+\sigma\ge4(k+A)^2$; for blocks
   longer than about $\sqrt\sigma/4$ it says nothing, and wrappers that read a flag inside the world
   (CA23(d)) are outside it. No upper bound is proved on the total mass of circuits that read the inside
   of an explanation.
7. *"Running a block"* was read as restarting the world as the decoded circuit. Other readings (the
   decoded circuit takes over only the later positions; the block is data for a fixed interpreter inside
   the world) change Section 4, and the second of them is a step toward Section 11.
8. *CA28(c) with the crude cell* has an astronomically small constant ($w2^w$ gates). A real universal
   cell needs a number of gates linear in $w$; I did not construct it. *CA29* is not proved.
9. *Depth.* Circuits here are unrestricted in depth, so $s$ is serial computation. With a depth bound the
   circuit side moves further from programs; I did not treat it.
10. *Not treated:* feedback (`sec5`), the MAP predictor, the many-round dynamics, and worlds larger than
    the predictor's class beyond the remark after CA5. No part of this file was checked by a second
    reader; the script checked only the arithmetic of the inequalities in CA6, CA16, CA18 and CA19.
