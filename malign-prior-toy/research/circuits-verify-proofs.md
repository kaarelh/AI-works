# Referee report on the circuit material: proofs

Report by an AI referee (Claude), 13 November 2026. Not reviewed by a human. Lens: proofs. Files reviewed:
`circuits-A.md` (claims CA1 to CA29), `circuits-B.md` (claims CB1 to CB26, with `circuit_count.py`), and
the derived statements in `circuits-literature.md` (its section D and its pointer 5). The note's
definitions and theorems were read in `paper/sec2-toy.tex`, `sec3-floor.tex`, `sec4-limits.tex`.

**How to read the verdicts.** *correct*: I re-derived the statement and the proof has no gap.
*correct with fix*: the statement or proof needs the stated change. *unclear*: the proof has a gap I did
not close, or the file itself labels the claim heuristic, conjecture, open or guess. *overclaim*: what is
proved is narrower than what the claim's heading or summary says. *wrong*: none of the numbered claims
got this verdict; one sub-argument (in CA12) is a non sequitur.

**Summary.**

* Every claim labelled PROVED in `circuits-B.md` is correct as stated, apart from wording (CB6, CB26),
  scope (CB20) and one heading that says more than its proofs (CB18). All computed numbers reproduce.
  The cited lower bound for universal circuits (CB19 part 2, and CA17(c)) needs a condition on the
  number of inputs.
* Every inequality labelled PROVED in `circuits-A.md` is correct. The defects are: a bound that holds
  only for one-bit payloads (CA8); a counting step that does not give the conclusion drawn from it
  (CA12, second "weaker notion"); a reading of CA7 that gives the worst case as if it were typical; a
  bound on universal circuits that needs a condition on $k$ (CA17(d)); and small constants (CA3, CA9).
* The two files do not contradict each other on any inequality. They differ on eight readings, listed in
  the section on disagreements. The most important: `circuits-B.md` says no circuit can hand over its own
  description and `circuits-A.md` says index circuits can; both are right for their own output
  convention, and neither proves existence for the literal code.
* Neither file proves an upper bound on the posterior share of aimed payloads at a use. The statements
  "rare" and "astronomically small" in both overall views rest on bounds for one description, for
  separate triggers, and on guesses. The files say so; the summaries should say it as plainly.
* One connection is missing from both files and changes how A's numbers read: a context of length $n$ in
  A's index reading is B's data set $S=\{0,\dots,n-1\}$, and a cut at $n=2^j$ is exactly B's query that
  differs from the data in a never-varied bit. I state and prove this below (section "Missing", item 1)
  and give the exact numbers.

**Numerical checks made for this report.** Scripts were run in a scratch directory outside the
repository. They enumerate Boolean circuits and their truth tables and nothing else.

| check | result |
|---|---|
| `circuit_count.py` re-run | output identical, line for line, to the 75 lines quoted in `circuits-B.md` |
| second implementation: direct enumeration of all circuits (no dynamic programme), $k=3$, $s\le3$ ($14\,745\,600$ circuits at $s=3$) and $k=2$, $s\le3$ | number of circuits per function equal to the script's for every function |
| direct enumeration, $k=4$, $s=3$ ($58\,982\,400$ circuits) | task F: fit $7360$, shares $106/115$; $4/115$, $1/23$, $6/115$, $6/115$. Task G: fit $4608$, $1/8$; $1/2$, $1/2$, $1/4$, $3/8$. All equal to the file |
| Monte Carlo, $4.8\times10^7$ random circuits per size, $k=3$ | $s=4$: task A at 111 $0.1691\pm0.0004$ (file $0.1691$); task E at 001 $0.4466\pm0.0011$ ($0.4457$); task C $0.2425\pm0.0002$ ($0.2427$). $s=5$: $0.1900\pm0.0005$ ($0.1896$); $0.4277\pm0.0010$ ($0.4294$); $0.2393\pm0.0002$ ($0.2393$) |
| Monte Carlo, $1.2\times10^8$ random circuits, $k=4$, $s=4$ | task F at 1111 $0.0881\pm0.0021$ (file $0.0874$); task G at 1100 $0.4809\pm0.0035$ ($0.4792$) |
| core law CB2 with all 16 gate types, $k=3$, $s\le3$ | every core of size $a$ has exactly $N_s\beta_s(a)$ circuits: at $s=3$, $144$ cores with $36\,864$ circuits each, $16\,128$ with $400$ each, $2\,985\,984$ with one each (total $N_3$) |
| CB3, exact rationals, $2\le k\le6$, $2\le s\le15$, all $a$ | 525 cases, no violation of either bound; Euler-product ratio for $k=1$ agrees to six digits |
| CB9 and CB10 | 400 random data sets at $k=3$ (311 with $s_D=2$, 89 with $s_D=3$), $38\,872$ minimum circuits examined, no violation |
| CB15(2) | $24=12\times2$ at size 2 and $2880=12\times240$ at size 3, as stated |
| CA1, CA2, CA5, CA6, CA7, CA13(b), CA16, CA19, CA23, CB7, CB11, CB14 | see the claims |

The files contain no optimisation claim with a closed form (those are in the stakes files, which are
not under review here), so there is no closed form to compare with a numerical optimum. Inequalities
were checked on exact small instances instead, and the numbers are given with each claim.

---

## Part A. `circuits-A.md`

### Setting (section 1.1)

The count $|\mathcal C_{k,s}|=\prod_i16(k+i-1)^2$ and the bounds on $\Lambda$ and $\Delta$ are right.
Two remarks.

* *Normalisation with seeds.* The text sets $\sum_sw_s=1$ and then adds seeded formats with weights
  $\omega(r,s)$, $\omega(0,s)=w_s$. If any seeded format has positive weight the total mass exceeds $1$.
  Nothing downstream depends on it, because every statement is a ratio. Fix: require
  $\sum_{r,s}\omega(r,s)=1$ and state (A2) as $\omega(r,s)\le\omega(0,s)$.
* *(A1) excludes the fixed-size prior.* Weights concentrated on one size are not nonincreasing. So
  CA16(v), CA19, CA21 and CA23, which use (A1), are theorems about the mixture prior only. CA7 is stated
  for both. The fixed-size versions follow from CB2: under $\mu_s$ the mass of the circuits with a given
  core of size $a$ is $\beta_s(a)$, and $\beta_s$ is decreasing in $a$ (CB3), which is the property (A1)
  is used for.

### CA1. Option I-a under the fixed-size prior is uniform

**Verdict: correct.** Own derivation: given the seed and all earlier gates, the value of gate $j$ is the
entry of $\tau_j$ at a position fixed by things independent of $\tau_j$, and the entries of $\tau_j$ are
independent fair bits. The author's proof is this. The extension to mixtures needs $s\ge N$ in every
component, which the output convention already requires. Check: for $(r,s,N)=(1,2,2),(2,3,2),(2,3,3),
(1,3,1)$, direct enumeration gives exactly $|\mathcal C_{r,s}|/2^N$ circuits for every output and seed.

### CA2. Option I-b is exchangeable

**Verdict: correct.** Given gates and seed the outputs are independent Bernoulli($p$) draws; the formula
and the bound $W^{-m}$ follow ($p^{j'}(1-p)^{m-j'}\ge W^{-m}$ termwise in numerator and denominator).
Check: $r=1$, $s=2$, three output pointers: $\xi(000)=\xi(111)=\frac14$ and $\xi=\frac1{12}$ on the six
other strings; the sum is $1$.

### CA3. Option II is a measure and a bounded mixture

**Verdict: correct with fix.** The measure property and $Z_m(x)=\xi(x)$ are right. The identification
with `def:mixture` is loose in one place: the machine $V$ reads the whole description, up to
$|\bar e(S)|+\Lambda(k,S)$ bits, before its first output bit, so the schedule needs
$T(1)\ge\Lambda(k,S)$, which is of order $S\log S$, and then about $S$ gate evaluations (with the
simulation overhead) per further bit. "A schedule $T(n)$ of order $S\cdot n$" should read "$T(n)$ of
order $S\log S+nS$ up to the machine's overhead". Nothing uses the schedule afterwards.

### CA4. Calibration

**Verdict: correct.** $\Pr[X=x,D=d]=\xi(xd)$ and $\Pr[X=x]=\xi(x)$ because $x$ is the first hit among
the prefixes of the transcript exactly when $x$ is a first hit and a prefix. One point of citation: the
note's second and third qualifications are "the one-world forms hold to the extent that worlds are
unpredictable" and "the handover is applied from outside". The two the file lists ("drawn from the
predictor's own prior", "a use that can be read off the data") are true but are the theorem's
hypotheses, not those qualifications.

### CA5. Budget

**Verdict: correct.** `thm:budget` uses only the semimeasure property and $\xi(z_{1:K})\ge q(W)$; the
finite sums are covered because every index lies in at most $m$ blocks. Check ($k=3$, fixed-size prior,
exact): for five worlds and $s=2,\dots,5$, in the eighteen cases where the world is in the class, the
sum of the one-bit deviations lies between $2.1$ and $4.4$ and the bound $\ln(1/\xi_s(z))$ between
$4.4$ and $13.2$; in the two cases where it is not (the majority function at $s=2,3$) the predictor
puts mass $1$ off the truth at the seventh bit.

### CA6. Sizes of the parts of a wrapper

**Verdict: correct.** (a) $G_0\in\{b_0,1\}$ and $G_i=b_i\wedge G_{i-1}$ or $b_i\vee G_{i-1}$; I rebuilt
the recurrence and checked the function and the count for all thresholds, $k\le7$: the worst case is
exactly $k-1$ gates, and exactly $2k-1$ for the interval test. (c) $M(j)+3\le2(M(j-1)+3)$ and $M(2)=1$
give $2^j-3$; for $j=3$ the exact maximum over the 256 functions is 4 gates (38, 114, 80, 24 functions
of least size 1, 2, 3, 4), below the bound 5. $p(m)\le\max(1,2m-5)$ and $a\le2k+2m+1$ checked for
$m<5000$, $k<40$.

*A sharper count that the file does not state.* For $m=1$ the trigger does not need the comparator. The
function $\bigwedge_{i:\,n_i=1}b_i$ ($n_i$ the binary digits of $n$) is $1$ at index $n$ and $0$ at every
index below $n$, because an index that has all the ones of $n$ is at least $n$. So a one-bit deviation
at position $n+1$ costs $\mathrm{popcount}(n)$ added gates for $n\ge1$, not $k$: one gate when $n$ is a
power of two, and $k$ only when $n=2^k-1$. Verified for all $n<2^{10}$. This matters for CA7.

### CA7. The floor for circuits

**Verdict: correct with fix (the fix is to a reading, not to the theorem).** The injection
$E\mapsto\mathrm{Tw}_{n,y}[E]$ and the three displays are right; so is the arithmetic ($480.3$ bits for
$a=20$ and $2485$ bits for $a=103$ at $k=20$, $\sigma=1000$).

* *Reading 2 gives the worst case.* "The floor for a one-bit deviation at a given position is about
  $K^{-(4+2\log_2(k+\sigma))}$" should be "at least", and by the count under CA6 the cost is
  $\mathrm{popcount}(n)\,(4+2\log_2(k+\sigma))$ bits: between $24$ bits (the $20$ positions with $n$ a
  power of two) and $480$ bits at $k=20$, $\sigma=1000$, and about $240$ for a typical $n$. For a block
  at $n=2^j$ with $m\le2^j$ the trigger is the index wire $b_j$ and costs no gate.
* *The floor says nothing about the size of the deviation mass.* Exact computation, $k=3$, $m=1$,
  fixed-size prior $s=4,5$: the floor of CA7 with $a=3$ is between $2\times10^{-9}$ and $2\times10^{-8}$,
  and the exact posterior probability of the flipped bit is between $0.06$ and $0.95$. The overall view
  of the file (item 3, "the floor for one deviating bit is about $2^{-480}$") should not be read as an
  estimate of anything but one construction at its most expensive position.
* *Reading 1* ("every pointer of the wrapper is priced as a pointer among all wires of the circuit it
  sits in") is true of the one placement the proof uses, the wrapper appended at the end. See
  disagreement 2 for the price that the posterior actually charges.
* For the fixed-size prior the bound contains the ratio $\xi_{s-a}(x)/\xi_s(x)$, which the file does not
  control. CB14(2) is the statement without such a factor.

### CA8. Tests that look at the data

**Verdict: correct with fix.** The count $w(\sigma+2k)+g_\phi+p+3$ is right for $m=1$ with two
additions. (i) For $t\le w$ the subtractors wrap around, so the copies read positions near $K$ and the
test can fire inside the context; a guard $[t>w]$ costs at most $k$ more gates. (ii) For a block of
$m>1$ bits the trigger at position $n+i$ has to recognise that the marker ended $i$ positions earlier,
and the payload has to know $i$; a payload "on the index" cannot. One needs the test at $m$ shifted
positions: at most $(w+m-1)(\sigma+2k)+m\,g_\phi+3m+3+k$ added gates. The lower bound is labelled
heuristic and I have nothing to add to it.

### CA9. Option I: no circuit outputs its own description

**Verdict: correct with fix (constants only).** $l_{\rm fw}\ge N+6s>N$ is right. The two counts of chain
members are off by one in trivial cases: a chain consisting of one circuit with $N_0<6$ outputs has one
member, more than $N_0/6$. Correct statements: the chain has at most $1+N_0/6$ members, and at most
$1+\log_2N_0$ if every member has at least three wires. (With the headers counted,
$N_{i+1}\le N_i-15$, so both of the file's bounds hold as soon as $N_0\ge10$.)

### CA10. What is independent of the encoding

**Verdict: correct.** (a), (b) as stated. In (c) the total weight is *at least* $1-2^{-N}$ (a member
with codeword beginning $1^N$ could also be a quine).

### CA11. Option II: necessary conditions

**Verdict: correct.** $y$ determines $D(y)$, so (a); $D(y)$ prints $x$, so (b); (c) is the definition.
The decoding is well defined because $\bar e(s)$ fixes the length of the code; the *encoding* $e(C)$ is
not unique under "value $c$ is read as wire $1+(c\bmod(k+i-1))$", so $\mathrm{SR}_m$ should be defined
through the decoder only.

### CA12. Self-describing circuits in Option II

**Verdict: unclear (the file labels it heuristic), and one sub-argument is a non sequitur.**

* *Existence.* The sketch is the standard table-plus-logic proof of the recursion theorem. I checked
  that the sizes can be fixed before the table is filled (the logic can take its numerical parameters
  from constant gates, so its gate count does not depend on them, and the pointer width can be made
  self-consistent by padding). I did not write the logic at gate level, and neither does the file. Not
  proved.
* *Cost.* The lower bound "at least $2\,l_{\rm fw}(E)$ further bits" is not proved. The gates of $E$
  could in principle do double duty; nothing in the file excludes it.
* *Second "weaker notion that survives, with proof": the proof does not give the conclusion.* The
  counting step is right: all but a fraction $2^{-j}$ of the circuits $C'$ of a format are emitted only
  by circuits of description length at least $\log_2(\#\text{format})-j$. But
  $\log_2(\#\text{format})=l(C')-\log_2(1/w_{s'})$, so this gives
  $l(C_i)\ge l(C_{i+1})-j-\log_2(1/w)$, which allows equality and increase. "Description lengths
  decrease strictly; the chain ends" does not follow. Counting descriptions cannot give it: as far as
  that count goes, the circuits of size $s'$ could be emitted one each by the circuits of size $s'$.
* *Repair, valid above a size threshold.* Count functions instead. Distinct $C'$ have distinct codes,
  and a circuit emits one string, so the $C'$ emitted by circuits with at most $s$ gates number at most
  $F(k,s)$, the number of functions with circuits of at most $s$ gates. A minimum circuit of $j$ gates
  has pairwise different gate functions, so its $j!$ renamings are different labelled circuits, and
  $F(k,s)\le\sum_{j\le s}j\,16^j(k+j)^{2j}/j!=2^{\,s\log_2s+O(s)}$ for $k\le s$, against
  $2^{\Lambda(k,s')}=2^{\,2s'\log_2s'+O(s')}$ gate lists. So for all but a fraction $2^{-10}$ of
  $C'\in\mathcal C_{k,s'}$ every emitter has at least $s$ gates, where $s$ is least with
  $F(k,s)\ge2^{\Lambda(k,s')-10}$. Evaluated: $s/s'=1.00$ ($k=10$, $s'=8$), $1.13$ ($k=10$, $s'=30$),
  $1.24$ ($k=20$, $s'=100$), $1.34$ ($k=20$, $s'=1000$), $1.44$ ($k=30$, $s'=10^4$), tending to $2$. So
  sizes decrease strictly along a chain of typical members once they exceed a few tens of gates; for
  small sizes it is not shown. (A typical circuit emits no code at all, so chains of typical members
  have at most two members; the statement has little content either way.)

### CA13. Reading and hardwiring

**Verdict: correct.** (a): $2c$ pointers in a cone of $c$ gates, $c-1$ of them go to gates. (b): a
constant operand is absorbed into the truth table. Check at the level of functions, $k=3$, $r=1$: all
$70$, $526$ and $3000$ functions computed by seeded circuits with $1$, $2$, $3$ gates restrict, for
both seed values, to functions computed by unseeded circuits with the same number of gates.

### CA14. Description length is at least computation

**Verdict: correct, as a statement about one description.** (a) and (b) are immediate. (c) is a remark
about the definition of evaluation and not a theorem; "there is no prefix word" is not formalised.

One limit, which the file names in its doubt 2: the bound is on the weight of one circuit, not on the
prior mass of the function it computes. Under the fixed-size prior most gates of a circuit are dead (a
simulation made for this report gives a cone of $1.90$ to $1.99$ times $\sqrt{k+s}$ gates on average at
$s=10^4$ and $10^5$, consistent with the constant $2.09$ in `circuits-literature.md` 2.7), so "a circuit
of size $s$ does $s$ operations per output bit" is true of the list and not of the computation. The
statement that survives for both priors is CB3: one more *active* gate costs at least
$\log_2(aB(k-1))$ bits.

### CA15. On average a family gains at most the base rate

**Verdict: correct.** Disjointness of the events over first hits.

### CA16. A circuit that serves $N$ targets

**Verdict: correct.** All six parts re-derived; the exponent in (v) is
$2s-\Delta(\sigma,s-\sigma)\le2\sigma-(s-\sigma)(2+2\log_2(k+\sigma))$, checked numerically at
$(k,\sigma)=(20,1000),(10,100),(3,5)$. (iii) needs (A2) only, not (A1). Two remarks on what the parts
say.

* (iii) bounds the share of the *seeded description*. It does not bound the share of its payload. The
  hardwired instance $S_{\rho_i}$ is an unseeded circuit that prints $x_i$ and then the same
  continuation, with weight $w_s2^{-\Lambda(k,s)}\ge q(S)$; so the payload's share at $x_i$ is at least
  the number of such instances times that weight over $\xi(x_i)$. The file says this in the reading
  after the claim; the short version at the top of the file ("shares that sum to at most 1") does not.
* The bound on the instances is (v), and it is void for $s\le\sigma$: a template of the size of the
  worlds has up to $2^{2s}$ instances, each of the weight of a world. What (v) and CA21 establish
  together is that such an instance outweighs a user only if it is a smaller circuit for the same
  context, which is the capture of CA23. That is the correct summary of the section.

### CA17. Universal circuits and the refund

**Verdict: correct with fix.** (a): per simulated gate $2\cdot3(2^\omega-1)+9\le12(k+\sigma)-3$ gates.
(b): $2^{s+1}\ge2^{2^j}$. (c) is a citation. (d) rests on the lower bound
$s\ge c\,\sigma\log_2\sigma$, which the file only quotes, and which is false without a condition on
$k$: if $2^k\le\sigma$ the circuits of size $\sigma$ compute every function of $k$ bits and a lookup
table of $3\cdot2^k$ gates is universal. Fix: assume $k\ge\log_2(\sigma\log_2\sigma)+O(1)$. Under that
condition the bound has an elementary proof: every function of $j$ variables has a circuit of
$O(2^j/j)$ gates (address tree over all functions of $\log_2(j-\log_2j)$ variables), so circuits of
size $\sigma$ compute at least $2^{c\,\sigma\log_2\sigma}$ functions of $j\approx\log_2(\sigma\log_2
\sigma)$ index bits, and by CA13(a) a seeded circuit with $s$ gates has at most $2^{s+1}$ instances.
`circuits-literature.md` 1.4 gives the same with constant $1-o(1)$ from Lupanov's bound; I checked that
derivation (see Part C).

### CA18. One gadget, all the ways of attaching it

**Verdict: correct.** A realisation is fixed by the positions of the gadget's gates;
$\binom{\sigma+a}{a}\le(\sigma+a)^a/a!$; $2^{-\Delta(\sigma,a)}\le(16(k+\sigma)^2)^{-a}$; and
$\sigma+a\le2(k+\sigma)$ for $a\le\sigma$.

### CA19. All small self-contained wrappers together

**Verdict: correct.** There are $\prod_{j\le a}16(k+j)^2$ self-contained gadgets with $a$ gates; with
CA18 the total is at most $\frac1{a!}\bigl(\frac{(k+a)^2}{k+\sigma}\cdot\frac{\sigma+a}{k+\sigma}
\bigr)^a\le\frac{2^{-a}}{a!}$ under the hypothesis. Evaluating the sum without the last two
simplifications, at the boundary $k+\sigma=4(k+A)^2$: $0.243$ ($k=2$, $A=1$), $0.028$ ($k=3$, $A=9$),
$0.028$ ($k=20$, $A=43$), $0.003$ ($k=20$, $A=171$), all below $e^{1/2}-1=0.649$. The set
$\mathrm{Wr}_A(E)$ also contains $E$ with dead self-contained gates, which are not wrappers; this only
makes the bound stronger than needed. What it leaves out is listed correctly in the file.

### CA20. Critical uses: what transfers

**Verdict: correct.** CA7 at each context, and its injection restricted to calling circuits. "No factor
$1/H_{\mathcal C}$ can be had by a single description" is CA16(iii) and has the limit noted there.

### CA21. Seekers that are not written down

**Verdict: correct.** In (b) the proof gives more than is stated: $q(S)p_i>q(W_i)$ implies
$w_s2^{-\Lambda(k,s)}>q(W_i)$, so $s$ is below the size of *every* user $W_i$, not only below the common
bound $\sigma$. (c) is right.

### CA22. No simple world with a long history

**Verdict: correct.** (a) and (b) restate CA14 and CA16. (c) is an interpretation of them and is right
in the sense needed: the weight of a description is bounded by its number of gates, so a description
cannot be short and contain a long computation. The file's remark handles the one loophole (the cell
that is read may have a small circuit, and then that circuit is the hypothesis). `circuits-B.md`,
CB19(4), states the same loophole as an assumption about circuit lower bounds; the two agree.

### CA23. Capture for circuits

**Verdict: correct.** (c): $2(k+\sigma)+2$ copying gates per wire; over all wires the ratio is
$\frac18+\frac1{8(k+\sigma)}\le\frac3{16}$ for $k+\sigma\ge2$ ($0.1875$, $0.15$, $0.125$ at
$k+\sigma=2,5,1020$). In (a) the wire $v$ must be a gate (for an index wire take a one-gate projection).

### CA24. An encoding can make either answer true

**Verdict: correct.** $\xi'(xy)\ge\frac12\xi(x)$ and $\xi'(x)=(\frac12+2^{-j-1})\xi(x)$; the new prior
has total mass $\frac12+2^{-j-1}$, which does not affect the ratio.

### CA25. A basis can make a chosen payload cost one gate

**Verdict: correct.** The prior with 17 types and uniform pointers sums to $1$ over the circuits of each
size, and the ratio is as stated.

### CA26. Invariance of sizes

**Verdict: correct.** (a): XOR and its negation need four gates over $\{\wedge,\vee,\neg\}$, every other
binary function at most two. (b): the padding argument is right, including the case of no gadget.

### CA27. Aiming does not pay

**Verdict: correct, as a statement about one seeded description.** It inherits the limit of CA16(iii):
the instances of the description are not bounded by $1/N$.

### CA28. Recurrence

**Verdict: correct.** (d): the increment needs at most $2k-1$ gates, and the run is
$h_1=(1,C(1),1)$, $h_j$ carries $C(j)$. (e) is right as stated; the description of a cell also pays
$w\log_2(w+s)$ bits for its output pointers whatever the cell does, which is the plainer reason that it
pays for space.

### CA29. Where each program-side phenomenon returns

**Verdict: unclear (labelled heuristic).** The caveat in the file is the right one: CA28(c) bounds
$\xi_{\rm rec}$ from below, so what returns is a share of the part of the posterior that runs through
the universal cell. No row of the table is proved.

---

## Part B. `circuits-B.md`

### CB1. Calibration

**Verdict: correct.**

### CB2. Core law

**Verdict: correct.** The bijection between circuits with core $\chi$ and pairs (active set, dead
gates) is right: the dead positions are free, and no choice of dead gates changes the active set. Check
with all gate types: see the table at the top.

### CB3. Price of a gate

**Verdict: correct.** $a\,e_a=\sum_{|T|=a-1}\prod_Tp\cdot\sum_{i\notin T}p_i$, and the inner sum lies
between the sum of the smallest $n-a+1$ of the $p_i$ and $e_1$. Checked exactly on 525 cases; the
zero-slack formula and the Euler product also checked.

### CB4. Mistake bound

**Verdict: correct.** The bound is pathwise, so it holds for adaptively chosen queries.

### CB5. A random query from the training distribution

**Verdict: correct.** $\varepsilon+e^{-\varepsilon n}/w(f^*)$ with the stated $\varepsilon$ is
$\varepsilon_n$.

### CB6. What the budget does not cover

**Verdict: correct with fix (wording).** The two-sided inequality is immediate. "Neither side improves
with more data from a region on which $f'=f^*$" is not accurate: such data can lower $W(D)$, which
raises both $w(f^*)/W(D)$ and $w(f')/W(D)$. What does not change is the ratio of the posterior masses
of $f'$ and $f^*$: whatever the data from that region, the answer of $f'$ keeps at least
$w(f')/w(f^*)$ times the posterior mass of the function $f^*$ itself. The numbers quoted for task D are
reproduced.

### CB7. Last-gate dichotomy

**Verdict: correct.** Check: task A at 111, $s=2$: $\nu=2/33$, 32 novel fitting circuits of which 16
answer each way; $s=3$: $\nu=300/3349$, $9600$ of $19\,200$. Task E at 001, $s=2$: $\nu=2/3$, 32 of
64; $s=3$: $\nu=133/219$, $17\,024$ of $34\,048$.

### CB8. A never-varied bit under the length prior

**Verdict: correct.** The two appended circuits have total weight $w_L(c)\,p_{s+1}$; the tail beyond
$s_0$ has posterior mass at most $\frac12$; solving gives $q/(2(1+q))$. The statement for $m$ output
bits is right under the convention that the outputs are the last $m$ gates.

### CB9. No idle gate in a minimum circuit

**Verdict: correct.** Each case of the proof removes a gate or produces a one-gate circuit. Check: see
the table at the top.

### CB10. Minimum circuits read no frozen input

**Verdict: correct.** Including the exception for $s_D=1$.

### CB11. Uniform prior with slack

**Verdict: correct.** Check at $\mu_3$, query 111: task A, bounds $0.0056$ ($a_0=1$, $\theta_0=0.344$)
and $0.0025$ ($a_0=2$, $\theta_0=0.792$) against a smaller answer share of $0.139$; task B, $0.0070$ and
$0.0026$ against $0.152$. The bound is far from tight.

### CB12. Exact shares for small circuits

**Verdict: correct.** Every entry of the table reproduced (script re-run; direct enumeration for
$s\le3$ at $k=3$ and $s=3$ at $k=4$; Monte Carlo for the rest).

### CB13. Size of the deviation share in general

**Verdict: unclear (labelled conjecture and heuristic).** One inconsistency in the paragraph that
follows it: "of constant order in every small case computed with slack, growing with the slack". For
the target $x_1$ the share falls with the slack ($0.2857$, $0.2609$, $0.2489$, $0.2427$, $0.2393$). The
overall view, item 7, has the qualifier; this paragraph should too.

### CB14. Floor for triggered payloads

**Verdict: correct.** In (2) the interleaved circuit determines the core and the interleaving because
the ancestors of the two pins of the mux are disjoint. Check ($g=1$, trigger $\mathrm{AND}(v,v)$, task
A): $5760$ and $1728$ fitting cores of size 3 give the answers $0$ and $1$ on the trigger set, against
the guaranteed $2\times2$.

### CB15. Ceiling for separable triggered circuits

**Verdict: correct.** Six mux types and two pin orders confirmed by enumeration; the counts $24$ and
$2880$ attain (2).

How much the ceiling leaves out, for task A (exact). The reduced circuits of size 3 that compute target
$\oplus v$, target $\vee v$, target $\wedge\bar v$ number $1344$, $1728$, $5760$. Of these, $800$,
$1184$, $1184$ are separably triggered, by the input $v$ itself or by a one-gate trigger; $544$, $544$,
$4576$ are not. Of the posterior mass that is off the target at the query 111 under $\mu_3$
($29\,824$ circuits of $214\,336$), the circuits with a separably triggered core are $8512$, which is
$28.5$ per cent; at $s=2$ they are $16$ of $48$. So the ceiling covers the smaller part of the
deviating mass already at two and three gates, as the file says it can.

### CB16. Aiming at $N$ unrelated uses

**Verdict: correct.** It is a statement about a random set of uses and one fixed posterior.

### CB17. The same in gates

**Verdict: correct.** The exceptional set in (1) grows with $s$, so the statement "for every $s$ with"
is covered by the largest admissible $s$.

### CB18. No hypothesis is repaid for the rarity of uses

**Verdict: overclaim.** Parts 1 to 3 are correct. They do not add up to the heading. Part 2 is one
class of worlds under $\mu_s$ at zero slack, where the posterior is supported on minimum circuits and
nothing else has any share; with one gate of slack the shares at the same uses are positive (task F:
$0$ at $s=2$, $0.052$ at $s=3$). Part 3 is for separable triggers. Part 4 is argued. What is proved is:
(i) the average gain is at most $1/H$, as for programs; (ii) there is a predictor and a class of uses
with no gain for any hypothesis; (iii) separable triggers get no gain. Whether, under the length prior
or under $\mu_s$ with slack, some set of circuits has a share at every use of a class that grows as the
class gets rarer is not settled by either file. The file's doubt 7 says this; the heading and the
overall view (item 8) should.

### CB19. Simulation and deliberation cost gates

**Verdict: correct for parts 1 and 4.** Parts 2 and 3 are citations and were not verified here; the
lower bound in part 2 needs the condition on the number of inputs given under CA17.

### CB20. No circuit hands over its own description

**Verdict: correct with fix (scope).** Under the stated convention (an answer of $m$ bits is produced by
the last $m$ gates at one input, and a gate costs at least 4 bits) the count is right. The conclusion
"what a circuit hypothesis can supply through the prediction channel is strictly smaller than itself"
is a property of that convention. If the block is read off $m$ inputs with one output bit each, which
is the file's own model with $m$ critical queries and is Option II of `circuits-A.md`, a circuit with
$s$ gates supplies up to $2^k$ bits and its description has about $s(4+2\log_2(k+s))$; the counting
obstruction is gone and the only necessary condition is CA11(b). The overall view, item 6, states the
claim without the convention. See disagreement 1.

### CB21. AND family

**Verdict: correct.** Re-derived: the minimum circuits are read-once formulas; on the data each gate
sees three of the four input pairs; at an input with two zeros the gate where the two paths meet sees
the fourth pair, and the output is $1$ or $0$ according to the free entry. Confirmed for $k=3$ and
$k=4$ by direct enumeration (exactly $\frac12$).

### CB22, CB23. The minimal-circuit question; a general solver

**Verdict: unclear (labelled open and heuristic).** The count $q+2Nb$ in CB23 is right (each bit of the
lookup is a function of $\lceil\log_2N\rceil$ index bits).

### CB24. Weight sharing and recurrence

**Verdict: unclear for parts 2 and 3 (argued); part 1 is correct.** In part 3 the gain of a search by
tries is $(1-e^{-1})\min(k,1/H^{(t_0)})$ in the note, with $H^{(t_0)}$ the mass of the worlds that
complete a first hit within $t_0$ steps; the file writes $H$.

### CB25. Where neural network training sits

**Verdict: unclear (labelled guess).**

### CB26. Stakes

**Verdict: correct with fix (wording) for parts 1 to 3.** In part 2 a circuit that agrees with $f^*$
outside $\mathcal K$ fits with probability *at least* $(1-\rho)^n$. Part 4 is argued.

---

## Part C. Derived statements in `circuits-literature.md`

* **1.4 and 2.5(d), lower bound on universal circuits and on the number of functions. Correct**, given
  Lupanov's bound, which that file marks as read in a secondary source. The dyadic decomposition is
  right: $N-N'<2^{m-t}\le N/m$, the subcubes exist by Kraft's inequality, and the selection costs
  $O(t^2)$ gates. The condition $n\ge\log_2(s\log_2s)+1$ is needed and is stated.
* **2.5(c), upper bound on the number of functions. Correct**; I re-derived it (the labelled-circuit
  argument used under CA12).
* **2.7, correspondence with Janson's model. Correct**: a gate reachable from the output is reached
  through gates only, because arrows go to smaller indices. Simulation: see CA14.
* **Pointer 5, the size-$s$ mass of a function is at least its size-$\sigma$ mass over $16(k+s-1)$.
  Correct**, and loose by more than the factor 2 that the proof gives away. Exact minimum of
  $\mu_s(f)/\mu_\sigma(f)\cdot16(k+s-1)$ over all functions and all $\sigma<s$: $49$ for $k=3$,
  $s\le5$, and $64$ for $k=4$, $s\le4$.
* **Pointers 3 and 4** (Lupanov's bound for a block whose length is not a power of two; gate lists
  carry twice the information of the function in the leading term) are right and apply to CA7,
  reading 3, and to every place where `circuits-A.md` turns $2^{-\Lambda}$ into a share.

---

## Disagreements between the files, and their resolution

**1. Can a circuit hand over its own description?** CB20: no, proved. CA9: no, for Option I. CA11 and
CA12: yes for index circuits, at a multiplicative cost, heuristic.

*Resolution.* CB20 and CA9 are the same count and are right: when each output bit has its own gate, the
description is longer than the output. In the index reading that count does not apply, and the right
necessary conditions are CA11(a) and (b). So "no circuit can hand over its own description" is false as
a statement about circuits and true about one output convention, exactly as CA10 says. Whether
$\mathrm{SR}_m(x)$ is nonempty under the literal code is proved in neither file. I checked the size
bookkeeping of the sketch in CA12 and found no obstacle, and did not construct the circuit. The cost
estimate in CA12 (a power of the honest mass, at least its square) is not proved.

**2. What a wrapper gate costs.** CA7: $4+2\log_2(k+\sigma)$ bits, with $\sigma$ the size of the
explanation it wraps, "priced as a pointer among all wires of the circuit it sits in". CB3 and CB14(2):
between $\log_2(aB(k-1))$ and $\log_2(2aB(k+a-1))$ bits, with $a$ the size of the active part, "not the
nominal size".

*Resolution.* B is right about what sets the price, and the two agree in size where both apply. CA7
counts one placement, the wrapper appended at the end; that is a valid lower bound on the mass and so an
upper bound on the price. Both priors are priors on cores (CB2), a core's weight depends only on its
size, and CB3 gives the price of an active gate. At $k=20$ and an active part of $1000$ gates B's
interval is $18.2$ to $25.0$ bits, and A's figure is $24.0$. They part under the fixed-size prior with
slack: at nominal size $10^6$ A's expression gives $44$ bits per gate and the price is still at most
$25$. So A's reading 1 should say "grows with the size of the active part of the explanation".

**3. What it costs to recognise the use.** A: a position, up to $2k-1$ gates, hundreds of bits. B: a
never-varied input bit, no gate for the trigger, shares of some per cent.

*Resolution.* The theorem is the same (CA7 with a test of $g$ gates, CB14 with a trigger of $g$ gates),
and the cost is the circuit complexity of the trigger from the wires already present. A's figures are
for the most expensive positions; by the count under CA6 a one-bit deviation at position $n+1$ costs
$\mathrm{popcount}(n)$ gates, and a cut at a power of two is B's cheap case (item 1 of "Missing").
CA23(d) and B's remark on triggers that share gates with the honest part say the same thing from the
two sides.

**4. What bounds the mass off the truth at a use.** A's overall view: ordinary inductive error,
"bounded on average by the budget". B: one off-distribution query is covered by no bound, and the
deviation there is of constant order.

*Resolution.* Both statements are true and B's is the one that applies to a use. The budget bounds the
number of bad cut points along a world; a use is a cut point that something singled out. The note makes
the same reservation after `thm:budget`. Exact profiles in A's own model ($k=3$, fixed-size prior,
$s=2,\dots,5$; position $n+1$ after a context of length $n$):

| world | $n=3$ | $n=4$ | $n=5$ | $n=6$ | $n=7$ |
|---|---|---|---|---|---|
| $0001\,0001$ ($b_0\wedge b_1$, ignores $b_2$) | $0.946$ to $0.949$ | $0.030$ to $0.076$ | $0.031$ to $0.064$ | $0.032$ to $0.068$ | $0.050$ to $0.125$ |
| $0001\,1110$ ($(b_0\wedge b_1)\oplus b_2$) | $0.946$ to $0.949$ | $0.970$ to $0.924$ | $0.000$ to $0.160$ | $0.000$ to $0.110$ | $0.500$ to $0.549$ |
| $0110\,1001$ (parity) | $0.532$ to $0.579$ | $0.897$ to $0.804$ | $0.333$ to $0.392$ | $0.250$ to $0.297$ | $0.000$ to $0.004$ |

Entries are the posterior mass off the world's next bit, at $s=2$ and at $s=5$. The sums over the eight
positions are $2.1$ to $4.1$, within the budget. At $n=4$ the second row equals task D of
`circuits-B.md` at the query 001 ($32/33$ at $s=2$): the same number computed in the two models.

**5. The factor $m$ in the budget.** CA5: at most $m\,l(W)$ positions. CB4: no factor $m$.

*Resolution.* Different protocols; both are right. A counts overlapping blocks at every cut point of
one sequence; B reveals each answer whole before the next query.

**6. What "no refund for search" means.** A proves it for one seeded description and for the hardwired
instances of one template (CA16, CA17). B proves an average statement (CB16), a counting statement
(CB17) and a zero-slack example (CB18).

*Resolution.* These are four different theorems, none of which is the negation of `thm:search`(b) for
arbitrary sets of circuits. What they jointly establish: a hypothesis cannot be a compressed description
of another (no interpreter below about $\sigma\log\sigma$ gates, for $k$ large enough), and an instance
that outweighs a user at its context is a smaller circuit for that context. Whether many such circuits
together hold a large share at the uses of a rare class is the question of how the explanations of a
context divide, which neither file bounds.

**7. The typical size of the active part.** B calls "of order $\sqrt s$" a heuristic; the literature
file has it as a theorem read in a source, with constant $2.09$. *Resolution:* the literature file is
right (simulation here: $1.90$ to $1.99$ at $s=10^4,10^5$, approaching from below). A's sentence "a
circuit of size $s$ does exactly $s$ gate operations per output bit" needs "including dead gates".

**8. Whether the ceiling over all triggers is small.** A (CA19): all self-contained wrappers of at most
$A$ gates together weigh less than $0.65$ of the explanation when $k+\sigma\ge4(k+A)^2$. B (doubt 2):
its ceiling summed over all triggers of $g$ gates is not small.

*Resolution.* No contradiction. B's remark is about B's bound, which uses the upper price
$1/(jB(k-1))$ per gate; A's bound is sharper in its regime because it uses the actual number of
pointer choices. A's is stated for the nominal size under (A1); a version at the level of cores is not
in either file.

---

## What is missing

1. **The link between the two models, and the special role of dyadic cut points.** A context of length
   $n$ in Option II is the data set $S=\{0,\dots,n-1\}$ of index values with their labels, and the next
   position is the query $u^\dagger=n$. The index bits $b_j$ with $2^j\ge n$ are frozen at $0$ on $S$.
   If $n=2^j$, the query differs from the data point $0$ only in the frozen bit $b_j$, and more
   generally position $n+i$ differs from position $i$ only in $b_j$ for $1\le i\le n$. Hence, by CB10:

   *If $|x|=2^j$ and $\mathrm{size}(x)\ge2$, every minimum-size circuit that prints $x$ reads none of
   the bits $b_j,\dots,b_{k-1}$, so its truth table is $x\,x\,x\cdots$. Under the fixed-size prior at
   $s=\mathrm{size}(x)$ the predictor continues $x$ periodically with probability $1$, and a world whose
   own continuation differs has deviation mass $1$ at that cut.* The same holds for
   $\mathrm{size}(x)=1$ unless $x$ is constant or equals an index bit or its negation on the context.

   Proof: CB10 with frozen coordinates $j,\dots,k-1$; a function of $b_0,\dots,b_{j-1}$ has a truth
   table of period $2^j$. With slack the mass is not $1$ but stays large: for $k=4$ and the world
   $(b_0\wedge b_1)\oplus b_3$ the deviation at $n=8$ is $0.96$ at $s=3$ and $0.95$ at $s=4$; for the
   world $(b_0\wedge b_1)\oplus b_2$, which ignores $b_3$, it is $0.03$ and $0.06$. CB7, CB8, CB11,
   CB14 and CB15 all apply to Option II in the same way. This is the sharp form of what A calls capture
   by a smaller circuit, it shows that A's toy has cheap positions (about $\binom kg$ positions at which
   a one-bit deviation costs $g$ gates), and it replaces the note's remark that few cut points are cheap
   to recognise.

2. **An upper bound on aimed payloads.** Nothing bounds the total posterior share, at a use, of
   circuits that compute the context and continue with something chosen. The ceilings are for separate
   triggers (CB15) and self-contained gadgets around large explanations (CA19). In task A the circuits
   outside the ceiling carry $71.5$ per cent of the deviating mass at three gates (CB15 above), and
   neither file has a definition of "aimed" that could be checked for a given circuit. The words "rare" and "astronomically small" in the two overall
   views are guesses and are labelled so there; the proved parts do not support them beyond single
   descriptions.

3. **The prior on functions.** A's bounds compare single descriptions. B's core law is the right
   intermediate object, but the number of cores per function is not controlled, so neither file can
   turn the weight of a minimum circuit into the mass of its function to better than the factor 2 in
   the exponent that the literature file points out. The fixed-size versions of CA16(v), CA19, CA21 and
   CA23 are not written; they follow from CB2 and the monotonicity of $\beta_s$.

4. **Self-reproduction for index circuits.** Existence under the literal code, with explicit sizes, and
   any lower bound on the cost. Until then, the statement that self-reproducing continuations hold "a
   power of the honest mass" has no proof in either direction.

5. **CA8 for blocks, and a lower bound for data-dependent tests.** The count for $m>1$ is given above;
   that nothing essentially cheaper exists is open and would be a circuit lower bound.

6. **The recurrent toy.** CA28 proves domination with an astronomically small constant ($w\,2^w$
   gates). There is no universal cell of size linear in $w$, no check that the note's twin, quine and
   rescaler fit a space bound, and so no theorem behind any row of CA29 or CB24(3). The order in which
   the program-side effects return is argued in both files and proved in neither.

7. **A world larger than the predictor's class.** Both files note it and stop. In the circuit toy it is
   the generic case, and task D at $s=1$ and the dyadic statement above show what happens: all of the
   posterior on the simpler extension.

8. **The dependence on the size weights.** Under weights that decay slowly, or under the fixed-size
   prior with large slack, most of a circuit is dead code and the posterior may sit on large cores that
   fit by chance; CB11 is conditional on exactly this and CB13 is a conjecture. No theorem controls the
   posterior distribution of the core size.

9. **Feedback, the majority predictor, and several rounds** are not translated at all.

10. **A second reader for the computation.** `circuits-B.md` says there is no second implementation.
    There is one now, described at the top of this report, and it agrees on every count; it is not in
    the repository.
