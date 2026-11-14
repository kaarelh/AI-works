# Referee report 6 (proofs, part b) on Section 7, "Circuits in place of programs", second half

Date: 2026-11-14. Written by an AI referee that had not seen the note before; not reviewed by a human.

**Version refereed.** `paper/sec7-circuits.tex` as committed in `6b534400` on `claude/lucid-hypatia-j4jg12`, from
the subsection "No refund for search; computation is paid for in description" (line 602) to the end: Sections 7.7
to 7.12 of the PDF, that is Theorem 38 (seeds, instances, universal circuits), Proposition 39 (capture),
Proposition 40 (self-reproduction), the paragraphs on encoding and basis and on concentration, Proposition 41
(recurrence), the computed small cases, the minimal-circuit question and the overall view. Also the passages
that summarise this half in `paper/main.tex` (abstract), `paper/sec1-intro.tex`, `paper/sec8-answers.tex` and
`README.md`, and the source `research/circuits-final.md` ("source Theorem $k$" is its numbering). Read first:
`README.md`, `paper/main.tex`, `paper/sec2-toy.tex`, `paper/sec3-floor.tex`, `paper/sec4-limits.tex`,
`verification/README.md`, and the first half of Section 7 for its definitions. I did not read the other
reports of this round. Line numbers are those of `paper/sec7-circuits.tex` unless a file is named.

**Lens.** Mathematics only. Each statement was written down and derived before its proof was read; constants,
directions of inequalities, quantifier order, edge cases and every use of an earlier result were checked;
what can be computed was computed.

**Method.** Pencil and paper, and five Python scripts in a scratch directory (listed in the last section; they
are not part of the repository). The scripts count small Boolean circuits and evaluate their truth tables, in
exact integer and rational arithmetic. No script executes strings as programs, decodes blocks into circuits,
or searches for self-reproducing objects. The example in finding 3 was derived by hand.

## Verdict

No numbered statement of the second half is wrong. Theorem 38 (a) to (i) holds with its constants, and the
proofs given in the paper are complete up to the points in findings 2 and 16. Propositions 39, 40 and 41 and
the statements of the two paragraphs taken by pointer (source Theorems 19 and 20) agree with the source, and
the source's proofs of them hold. That includes the lower bound for universal circuits with the constants
$16.5$, $17$, $1/34$ and $2^{33}$ (source Proposition 16(b), (c)), which the source's editor wrote and no
referee of the source had seen: it is correct. Every computed number of this half was reproduced exactly with
an independent implementation, including the two examples of Proposition 39(d). Nothing was strengthened in
transcription inside a numbered statement. The problems are these.

* **A definition makes the seeded statements empty if read literally.** The mixture prior has
  $\sum_sw_s=1$; Section 7.7 then sets $\sum_{r,s}w_{r,s}=1$ with $w_s=w_{0,s}$, which forces every seeded
  format to have weight $0$. The mixture $\xi$ is never extended to seeded circuits, and part (h) is proved
  "by the definition of $\xi$" (finding 2).
* **A question declared open is settled by a one-gate example.** "Whether $\SR_m(x)\ne\emptyset$ for some
  context under the literal code is not proved." For $k=21$ the one-gate circuit $b_0\oplus b_{10}$ has, at
  positions $1020$ to $1037$ of its truth table, a block of $18$ bits that decodes to it (finding 3).
* **Summaries say more than the theorem.** The subsection title "No refund for search" and the README's "no
  refund for the rarity of uses, and no simple world with a long history" are the two claims the source lists
  as dropped (finding 1). "Only a time bound excludes it" returns to a wording corrected in round 5
  (finding 4). Assumptions (A1) and (A2) and the conditions on $k$ are dropped in several places (finding 5).
  Two items of the list headed "Proved" are not theorems as worded (finding 7).
* **Three sentences about the computed cases are wrong as written** (finding 6): the deviation is not "$0$ at
  the least size" when the world depends on the bit; the smallest value is $1.9$ per cent, not $2$; and "2 to
  32 per cent when the predictor has gates to spare" (abstract, Section 8, README) attributes to slack a value
  that occurs only without slack. With gates to spare the range is $1.9$ to $29$ per cent.

The remaining findings are small: loose wording in Proposition 41, a caveat of the source that was dropped,
an inverted phrase, undefined symbols, and slips in the source that the paper did not inherit.

On the commissioner's question: the labelling of the overall view (proved, argued, guessed) is sound once
findings 5 and 7 are applied. Nothing in this half supports a statement about all hypotheses that deviate at a
use, and the text says so.

## Findings

### 1. The title "No refund for search" and the README assert what the section says is not shown (overclaim)

**Location.** Line 602 (subsection title); `README.md` line 45 ("So there is no cheap universal search, no
refund for the rarity of uses, and no simple world with a long history").

**Problem.** Theorem 38 bounds one seeded description ((d), (f)), the instances of one template ((e)), and a
template that imitates every world of $\sigma$ gates ((i)). The paragraph after it says so: "None is the
negation of Theorem 12(b) for arbitrary sets of circuits. No construction is known whose share at every use of
a class grows as the class gets rarer, and none is excluded." Section 7.4 states the opposite of the title for
a family: "Relative to its own prior mass the family of wrappers around the users is repaid the factor
$1/H_{\mathcal C}$" (line 403). For "no simple world with a long history" the paper says "Part (g) does not
show that the behaviour ... is expensive. It bounds circuits, not behaviours" (line 734). Both README claims
are in the source's list of dropped claims (source Section 5.2: "no hypothesis is repaid for the rarity of
uses", "heading stronger than its items"; "there is no simple world with a long history as a statement about
behaviours"). This is a bound on one seeker read as a bound on all.

**Corrected text.** Title: "No refund for a single description; computation is paid for in description".
README: "So no single description is a cheap universal search or is repaid for the rarity of uses, and a
description has at least as many gates as the smallest circuit for anything it computes. Whether a set of
circuits can be repaid is open."

### 2. The prior on seeded circuits is not consistently defined; $\xi$ is not extended; proof of (h) (gap)

**Location.** Lines 607 to 612; Theorem 38(d), (h); proof line 694.

**Problem.** (i) The paragraph on priors (line 32) defines a mixture prior with $\sum_sw_s=1$. Line 610 adds
$\sum_{r,s}w_{r,s}=1$ and $w_s=w_{0,s}$. Together these give $w_{r,s}=0$ for all $r\ge1$, so every seeded
circuit has weight $0$ and (d), (f), (h) are empty. The source redefines $w_s:=\omega(0,s)$ at this point and
notes that every statement is a ratio (its Section 1.2); the note was not carried over.

(ii) $\xi$ is defined as $\mu\{\Gamma:x\pre\ctt(\Gamma)\}$ for a prior on unseeded circuits. In (d) "the
share of $S$ at $x_i$" and in (h) "$\pi_m(y_x\mid x)\ge q(S)Q(x)/\xi(x)$" need a mixture that contains $S$.
With the unseeded $\xi$, (h) is not "the definition of $\xi$".

Both readings can be repaired, and all inequalities of (d), (e), (f) hold in both: their proofs use only
$\xi(x_i)\ge w_s/N_s$ and $q(S)\le w_s/N^{(k+r)}_s$.

**Corrected text.** After line 612: "In this subsection the prior is extended to seeded formats: weights
$w_{r,s}\ge0$ with $\sum_{r,s}w_{r,s}=1$, and $w_s$ now stands for $w_{0,s}$, so that $\sum_sw_s\le1$. The
earlier results are statements about ratios and are not affected. The mixture is
$\xi(x)=\sum_{r,s}\sum_{S\in\cG_{k+r,s}}q(S)\Pr_\omega[x\pre\ctt(S_\omega)]$." Proof of (h): "By the definition
of the extended $\xi$. For the mixture over unseeded circuits alone the same bound holds under (A2) when
$Q(x)>0$: by (b) some instance prints $x\,y_x$ and has weight $w_s/N_s\ge q(S)\ge q(S)Q(x)$."

### 3. $\SR_m(x)\ne\emptyset$ under the literal code: an explicit example exists (gap, now closed)

**Location.** Lines 808 to 810 ("Whether $\SR_m(x)\ne\emptyset$ for some context under the literal code is not
proved"); source Section 5.1 item 3 and Theorem 18 ("existence under the literal code is open").

**Problem.** The question has a one-gate answer. Take $k=21$ and the circuit $\Gamma'$ with the single gate
$\oplus$ on wires $1$ and $11$, that is $f_{\Gamma'}=b_0\oplus b_{10}$. The pointer width is
$\lceil\log_2(21+1)\rceil=5$ and $l(1)=3+4+10=17$. Let
$$y=\underbrace{101}_{\bar e(1)}\ \underbrace{0110}_{\tau}\ \underbrace{10101}_{[a]=21}\
\underbrace{01010}_{[b]=10}\ \underbrace{1}_{\text{end}}\in\B^{18}.$$
The decoder reads $s=1$, the table $0110$ (exclusive or, in either order of the two middle entries), the
field $21$ as wire $1+(21\bmod21)=1$ and the field $10$ as wire $1+(10\bmod21)=11$; the rest of $y$ is $1$. So
$\cdec(y)=\Gamma'$. Both pointer fields are palindromes, so the example does not depend on the bit order of a
field. Now let $n=1019$ and $x=\ctt(\Gamma')_{1:1019}=(01)^{509}0$. At positions $t=1020,\dots,1037$, that is
$t-1=1019,\dots,1036$, the bit $b_{10}$ is $0$ up to $t-1=1023$ and $1$ from $1024$ on, so the truth table
reads $1,0,1,0,1$ and then $1,0,1,0,1,0,1,0,1,0,1,0,1$: this is $y$. Hence $xy\pre\ctt(\cdec(y))$ and
$y\in\SR_{18}(x)$. The necessary condition of Proposition 40(b) holds with equality ($s'=\csize(x)=1$,
$m=l(1)+1$).

The share is not negligible in this instance. Of the $16\cdot21^2=7056$ one-gate circuits, $110$ print $x$ and
$2$ of them print $xy$ (the gate $\oplus$ on wires $(1,11)$ and $(11,1)$); so under $\mu_1$,
$\pi_{18}(\SR_{18}(x)\mid x)\ge\frac1{55}$, while the world $b_0$ has a different continuation.

I found the example by hand, looking only at one-gate circuits. A one-gate stream that begins $1,0,1$ must
read $b_0$. The end mark sits at an even offset, where an alternating stream has a $0$, so the second input
bit must change inside the block. In the case of one such change, matching the table field with the stream
gives $\oplus$ and a change after the fifth bit; the two pointer fields are then read off the stream, and
with fields of five bits the first of them is wire $1$ exactly for $k=21$. I did not run a search, and I do
not claim that this is the smallest example. The example was checked by evaluating $b_0\oplus b_{10}$ at the
$18$ positions and by counting the one-gate circuits against the two fixed strings.

What remains open is narrower: existence for contexts whose smallest circuit is large (a circuit with a table
and logic that prints its own code), and any bound on $\sum_{y\in\SR_m(x)}\xi(xy)$ where it is not zero.

**Corrected text.** "Under the literal code $\SR_m(x)$ is not always empty: for $k=21$, $n=1019$, $m=18$ and
$x=(01)^{509}0$ the block $101\,0110\,10101\,01010\,1$ decodes to the one-gate circuit $b_0\oplus b_{10}$,
whose truth table begins with $x$ followed by that block; under $\mu_1$ it has share $\frac1{55}$ at $x$.
Whether this happens at a context whose smallest circuit is large is not proved." Item 6 of the list
"Proved" stands. The source's open item 5.1(3) should be narrowed in the same way.

### 4. "Only a time bound excludes it" returns to a wording corrected in round 5 (overclaim)

**Location.** Line 719; the same sentence in source Section 3.1.

**Problem.** For the unwritten seeker of Section 3.5 the note proves that a schedule with a short first
deadline gives the example no mass, and it says that this is "a feature of the example and not of every
program that meets the condition". Round 5, finding A5, changed "the only obstacle" to "the only thing shown
to exclude it"; `sec1-intro.tex` line 44 and `sec8-answers.tex` line 64 have the corrected form. Line 719
states it as a fact again.

**Corrected text.** "Its weight $2^{-|p|}$ does not depend on its running time, the honest twin does not apply,
and a time bound is the only thing shown to exclude it." The same in source Section 3.1.

### 5. Assumptions (A1), (A2) and the conditions on $k$ are dropped in the prose and the summaries (overclaim)

**Location.** Lines 698 to 708 ("What is excluded and what is not"); line 1019 to 1022 (item 2 of "Proved");
abstract (`main.tex` lines 110 to 111, "a random seed never beats its own hardwired instance");
`sec8-answers.tex` line 136; `README.md` line 45.

**Problem.** Theorem 38(d) needs (A2); (e) needs (A1); (f) needs both; (i) needs $\sigma+3\le2^k$ for the first
bound and $k\ge j(\sigma)$ for the second. Each is needed.

* Without (A2) a seeded description beats its instance whenever $w_{r,s}/w_{0,s}>N^{(k+r)}_s/N_s$. So "a seed
  never beats its own hardwired instance" is a statement about how the format weighs seeds, and the conclusion
  "priced out" rests on that choice.
* Without (A1) a larger description can outweigh a smaller one ($w_{s+1}/w_s>16(k+s)^2$ is compatible with
  $\sum_sw_s=1$).
* Without the condition on $k$ the lower bound fails: for $\sigma\ge2^k-3$ every function of the $k$ inputs has
  a circuit of $\sigma$ gates, and a selector tree over $2^k$ seed bits, $3(2^k-1)$ gates, is universal for
  size $\sigma$; this is below $(\sigma+1)/2$ once $\sigma\ge6\cdot2^k$.

Line 705 says "has more than $(\sigma+1)/2$ gates, and more than $\sigma$ for large $\sigma$" with no
condition. Item 2 of "Proved" has the conditions on $k$ and not (A1), (A2), although its heading announces
"the priors of the family". `sec1-intro.tex` lines 152 to 156 has all of them and can serve as the model.

**Corrected text.** Line 699: "Under (A2) fixing a seed is free, so ...". Line 704: "Under (A1) and (A2) one
description outweighs a user's description only if it has fewer gates than that user (f). A description that
can become any world of size $\sigma$ has more than $(\sigma+1)/2$ gates when $\sigma+3\le2^k$, and more than
$\sigma$ when $\sigma\ge2^{33}$ and $k\ge j(\sigma)$; under (A1) all instances of a template with
$s\ge\sigma\,(1+1/(1+\log_2(k+\sigma)))$ gates weigh together at most one description of $\sigma$ gates (e),
(i)." Item 2 of "Proved": add "for mixture priors with (A1) and (A2)" to the second sentence. Abstract,
Section 8 and README: "a random seed does not beat its own hardwired instance if seeded formats get no more
weight than unseeded ones"; README: add "when $\sigma+3\le2^k$".

### 6. Three sentences about the computed cases are wrong as written (error, small)

**Location.** Lines 934 to 939; abstract (`main.tex` lines 123 to 125); `sec8-answers.tex` lines 149 to 151;
`README.md` line 47.

**Problem.** (i) "The deviation at a query that differs from the data in a never-varied bit is $0$ at the least
size outside the exception." In row 5 of Table 4, and for the world of row 1 of Table 5 at its least size $s=1$
(in the results file, not in the table), the deviation at the least size is $1$: the world depends on the bit.
The sentence needs "when the world ignores the bit", which only the next sentence has. (ii) "Between 2 and 32
per cent in every case computed": the smallest value is $1/53=0.0189$ ($b_0\wedge b_1$, $n=4$, $s=2$). (iii) The
abstract, Section 8 and the README say "about 2 to 32 per cent when the predictor has gates to spare and the
world ignores the bit". The value $0.32$ is the constant world at $s=1$, the least size, in the exception of
Theorem 35; there are no gates to spare. With slack the largest value is $0.289$ (constant world, $n=8$, $s=2$).
Line 936 is right on this point ("with slack, or in the exception"); the summaries dropped "or in the
exception". (iv) The range "0.81 to 1 when the world depends on the bit" is not a second measurement: row 5 of
Table 4 is one minus row 1, and row 1 of Table 5 is one minus row 4, because the data are the same and the
answers opposite. Its lower end is where the computation stopped, at $s=5$.

**Corrected text.** Lines 934 to 939: "When the world ignores the bit, the deviation at a query that differs
from the data in a never-varied bit is $0$ at the least size outside the exception of Theorem 35. It is between
$1.9$ and $29$ per cent in every case computed with slack, and $27$ to $32$ per cent at the least size in the
exception; the largest value, $0.32$, is the constant world at $s=1$, $n=8$. When the world depends on the bit
it is $1$ at the least size and $0.81$ to $0.98$ with slack; these are the complements of the rows for
$x_1\wedge x_2$ and for $b_0\wedge b_1$ at $n=8$." Abstract, Section 8, README: "by about 2 to 29 per cent when
the predictor has gates to spare and the world ignores the bit".

### 7. Two items of the list "Proved" are not theorems as worded (overclaim)

**Location.** Lines 1026 to 1033 (items 4 and 5); source Section 3.3, items 4 and 5.

**Problem.** Item 5 opens with "Deviation in the weak sense is not rare at uses that are off the data." No
result says this in general, and the next sentence gives a case where the deviation is zero. What is proved is
the list that follows. The general statement reappears, correctly, under "Guessed" ("is common ... which is
conjectured"). Item 4 says "three syntactic classes are capped". For the third class the bound of Theorem
38(e) is $2^{2s}N_\sigma/N_s$ times the weight of one description of $\sigma$ gates; it is below $1$ only for
$s-\sigma\ge\sigma/(1+\log_2(k+\sigma))$, equals $4^\sigma$ at $s=\sigma$, and needs (A1). The second class
needs $k+\sigma\ge4(k+A)^2$.

**Corrected text.** Item 5: "Deviation in the weak sense occurs at uses that are off the data with nothing
aiming at them. For minimum-size circuits it is zero ...". Item 4: "... namely separate triggers,
self-contained gadgets around much larger explanations, and, under (A1), the instances of one seeded template
that is sufficiently larger than the users."

### 8. Proposition 41: three loose statements (minor)

**Location.** Lines 875 to 879 ((a), (b)); lines 890 to 892.

**Problem.** (i) "$\xi^T_{\mathrm{rec}}$ is a bounded mixture in the sense of Definition 1" is not literally
true. Definition 1 counts the steps of a monotone machine, which reads at most one bit per step; here time is
counted in applications of the cell, and a machine that reads a code of $F$ and evaluates $s$ gates per
application has a step count that depends on $F$. Also $\xi(\eps)=1$ there, and here the weights "sum to at
most $1$". What the source proves, and what is needed, is that the sets of pairs $(F,p)$ that print $x$ on
schedule are nested along prefixes and disjoint for incomparable strings. (ii) "A cell of $s$ gates performs
$s\,T(n)$ gate evaluations before its $n$-th bit": it performs $s\,t(F,p,n)\le s\,T(n)$. (iii) "With $w$
output pointers every cell has weight at most $(w+s)^{-w}$" holds when the cells of each size are equally
weighted. The proposition allows any weights that sum to at most $1$, and the count of cells,
$N^{(w)}_s(w+s)^w$, which the source gives in its statement, was dropped.

**Corrected text.** (a): "With time counted in applications of the cell, the sets of pairs $(F,p)$ that print
$x$ on schedule are nested along prefixes and disjoint for incomparable strings. So Lemma 2(i), (ii), Theorem
9 (with its event $H_m$) and Theorem 24 hold for $\xi^T_{\mathrm{rec}}$, with ...". (b): "performs up to
$s\,T(n)$ gate evaluations". Line 890: "In the format in which the $N^{(w)}_s(w+s)^w$ cells with $s$ gates are
equally weighted, every cell has weight at most $(w+s)^{-w}$".

### 9. Part (i) is about imitating every world; the source's caveat was dropped, and the seeded circuit is not the only counterpart of a word $v$ (gap)

**Location.** Lines 604 to 609, 705 to 711; source, text after Proposition 16.

**Problem.** (i) The source ends its Proposition 16 with: "This is about a template that imitates every world
of size $\sigma$; a seeker needs only the users, and for a structured class of users only Theorem 14(d), (e)
apply." The paper keeps the bound and drops the sentence. In the program toy the seeker enumerates the calling
programs, not all programs, so the universal-circuit bound applies to a circuit seeker only when the users are
all circuits of $\sigma$ gates. (ii) Line 607 calls the seeded circuit "the counterpart of $v$". A second
literal counterpart of "the programs beginning with $v$" is the set of circuits that begin with a fixed gate
list $V\in\cG_{k,s}$. There are $N_{s+j}/N_s$ of them with $s+j$ gates, so the set has mass
$\sum_{j\ge0}w_{s+j}/N_s$, which is $2q(V)$ under the length prior, as $2^{-|v|}$ is the mass of the programs
beginning with $v$. Gates read only earlier wires, so $V$ cannot interpret what follows it, and each member
that prints $u$ has at least $\csize(u)$ gates by (g). Parts (c) and (g) apply to this family; (d), (e), (f)
do not, since its members have different sizes and are not instances of one template. The paper's general
sentence "none is the negation ... for arbitrary sets of circuits" covers this, but the reader is told that
the seeded circuit is the counterpart.

**Corrected text.** Line 607: "One counterpart of $v$ is a seeded circuit". After line 711: "Part (i) concerns
a template that can become every world of $\sigma$ gates; a seeker needs to become only the users, and for a
structured class of users only (d) to (f) apply. The circuits that begin with a fixed gate list $V$ are another
counterpart of the programs beginning with $v$, of mass $\sum_{j\ge0}w_{s+j}/N_s$; only (c) and (g) apply to
them."

### 10. "The average gain is at most the base rate" has the ratio the wrong way round (minor)

**Location.** Line 624 (heading of (c)); line 697.

**Problem.** (c) says that the average share is at most $q(\mathcal F)/H_G$. The gain, the share over the prior
mass, is then at most $1/H_G$, which exceeds $1$; "at most the base rate" would be at most $H_G$. Theorem 12 is
titled "Searching gains the base rate, and no more", so this is the note's idiom, but the phrase is false if
read as a formula.

**Corrected text.** Heading: "The average share is at most the weight over the base rate." Line 697: "The
average gain of any family, its share relative to its prior mass, is at most $1/H_G$, as for programs (c)."

### 11. The minimal-circuit paragraph drops $s_D\ge2$ (minor)

**Location.** Lines 959 to 963.

**Problem.** "A minimum circuit has no gate that is constant on the data, ... and no pointer to an input that
never varied" is Theorem 35(a), (b), which assumes $s_D\ge2$. For $s_D=1$ it fails in the stated exception:
for the target $x_1$, $4$ of the $14$ minimum circuits read the frozen input (line 488). The open problem has
$s_{D_n}\to\infty$, so nothing downstream is affected.

**Corrected text.** "a minimum circuit for data that need at least two gates has no gate ...".

### 12. "Harsher ... by the pointer width" compares a necessary condition with a sufficient one (unclear)

**Location.** Lines 809 to 810.

**Problem.** Proposition 40(b) is necessary: a block in $\SR_m(x)$ contains a code of a circuit that prints
$x$. The condition $c+r+1\le m$ of Theorem 11 is the condition under which the constructed wrapper fits; it is
sufficient for a contribution. The program-side counterpart of (b) is "some program of fewer than $m$ bits
prints $x$". Nor is the literal code longer than the prior's own cost gate by gate: the literal code spends
$4+2\lceil\log_2(k+s)\rceil$ bits on every gate, the length prior $5+2\log_2(k+i-1)$ bits on gate $i$, which
is more for the last gates when $k+s$ is a power of two.

**Corrected text.** "The condition in Proposition 40(b) is necessary, and it is the counterpart of 'a program
for $x$ fits into the block'; Theorem 11's $c+r+1\le m$ is sufficient. No sufficient condition is proved here
beyond the example above."

### 13. The paragraph on concentration: one inaccurate reference to Section 3.7 and three undefined symbols (minor)

**Location.** Lines 830 to 842.

**Problem.** (i) "In the program toy a seeker ... can compute the stakes by simulation at no cost in bits."
Proposition 19 charges the description of the aim: about $2\log_2n+2\log_2j_n+6$ bits for the class "stake at
least $n$", and the stakes must be enumerable from below. (ii) $s_0$ and $\epsilon$ of Theorem 34(b) are used
without definition, next to an unrelated $\varepsilon_n$. "Whatever $n$" is right, but $s_0$ depends on the
data; the reason is $\ell_D\le\log_2(1/\mu(f^*))$. (iii) "The cores separably triggered on $\mathcal K$ have
share at most the bound of Theorem 36(c)": that bound contains $|\Theta|$, and the set $\Theta$ of triggers is
not named. (iv) "With probability at least $(1-\rho)^n$" is an equality.

**Corrected text.** (i) "can compute the stakes by simulation at no cost beyond the bits that describe the aim
(Proposition 19)". (ii) "... have posterior share at least $(1-\epsilon)(32(k+s_0+g)^2)^{-(g+1)}$ under the
length prior, for every $\epsilon\in(0,1)$ and $s_0=\lceil\ell_D+\log_2(1/\epsilon)\rceil
\le\lceil\log_2(1/\mu(f^*))+\log_2(1/\epsilon)\rceil$, which does not grow with $n$". (iii) "the cores
separably triggered by a set $\Theta$ of $g$-gate circuits that recognise $\mathcal K$ have share at most
$12|\Theta|/(g!\,s_D(16(k-1))^{g+1})$".

### 14. Hypotheses left implicit in Proposition 39 and in the paragraph on encoding (minor)

**Location.** Lines 750 to 762; lines 818 to 819.

**Problem.** (i) Proposition 39(a) and (c) are for a mixture prior and need $\sigma_V\le s_{\max}$, respectively
$\sigma+|P|+3\le s_{\max}$; otherwise the weights are not defined. (c) also needs $n+m\le2^k$. (ii) The weight
$\varrho(\sigma,1)\frac1{17}(k+\sigma)^{-(k+1)}$ of the one-gate wrapper presupposes the prior on the enlarged
basis that the source states: the $17$ gate types equally likely and all pointers uniform. The paper gives the
weight without the prior.

**Corrected text.** (c): "... $\ge w_{\sigma+|P|+3}/N_{\sigma+|P|+3}$ if $\sigma+|P|+3\le s_{\max}$." Line 818:
"With the $17$ gate types equally likely and the pointers uniform, one added gate type ...".

### 15. Status and reproducibility (minor)

**Location.** `README.md` line 91; lines 763 to 765; line 851; lines 726 to 733.

**Problem.** (i) The README lists "the statements on seeds and universal circuits" among results "proved here
(short proofs in the paper)". Part (i) is stated without proof and taken from the source, where its proof is
the editor's own and had not been seen by a referee. It is correct (see the last section). (ii) The first
example of Proposition 39(d) ($2$ of $76$; $0.027$ to $0.028$) is not produced by
`experiments/run_circuits.py` and is not in `experiments/results/circuits.json`. The values are right:
$2/76$, $848/31264=0.02712$, $507200/18378496=0.02760$, $408380928/14637099008=0.02790$. (iii) Section 7 opens
with "results are theorems of the circuit toy unless they are marked". Two sentences of this half are neither:
"which is often what makes a use critical" (line 851), and "so the circuit toy is far harsher on computation
than a speed prior" (line 732), which compares a time per bit with a total running time through a cited
relation.

**Corrected text.** (i) README: "... and the statements on seeds; the bound for universal circuits is taken
from `research/circuits-final.md`." (ii) Add the context $000$ of $b_0\wedge b_1$ to `run_circuits.py`. (iii)
Mark both sentences as argued.

### 16. Small points of wording in Theorem 38 (minor)

**Location.** Lines 617 to 619, 630 to 637, 648 to 654, proof lines 673 to 694.

**Problem.** (i) (a): "at most $2s$ inputs are pointed to by any gate" reads as a bound per gate; meant is
"by some gate". (ii) (f) uses $w_s$ and so assumes $s\le s_{\max}$, as (d) says; for $s>s_{\max}$ the seeded
circuit has weight $0$ under (A2). (iii) Proof of (g): the cone of an input wire has no gate, and a circuit
has at least one; the claim holds because $|\Gamma|\ge1$ and one gate copies an input. (iv) The last sentence
of (c) is not proved; it is immediate, since a circuit has one truth table and first hits are incomparable.

**Corrected text.** (a): "and at most $2s$ of its inputs are pointed to at all".

### 17. Slips in the source that the paper did not inherit (minor; for the record)

**Location.** `research/circuits-final.md`, Computation 22 and Theorem 19(d).

**Problem.** (i) The source's table has $0.036$ for $b_0\wedge b_1$ at $n=8$, $s=3$. The exact value is
$242/6819=0.03549$; the paper's $0.035$ is right. (ii) In the proof of source Theorem 19(d), "a gadget with
fewer gates can be padded with unused gates" fails for the empty gadget (the block that $E$ itself prints).
The statement holds: the number of gadgets with exactly $a^*$ gates is an integer below $2^{m-j}$, so with the
one further block the count is at most $2^{m-j}$. (iii) The source's Section 1.2 has the conflict of finding
2 in a milder form: it says $\sum_sw_s=1$ and three lines later redefines $w_s:=\omega(0,s)$.

## What was verified, and how

**Theorem 38.** Each part derived by hand before reading the proof.

* (a) The count of pointers. Checked by enumeration: for $k=5$ the largest number of inputs a function of size
  $s$ depends on is $2,3,4$ for $s=1,2,3$ (own dynamic programme; $112$, $1252$, $12822$ functions).
* (b), (d) Hardwiring and the number of instances. For $(k,r,s)=(2,2,1),(2,3,1),(2,2,2),(1,3,1),(1,3,2)$ every
  seeded circuit was enumerated: every instance is a function computed by a circuit of exactly $s$ gates on $k$
  inputs, and the number of distinct instances never exceeds $2^{\min(r,s+1)}$.
* (c), (d), (f), (h) Derived; (d) and (f) in both readings of $\xi$ (finding 2). The last claim of (f) was
  re-derived from $s\ge\csize(x_i)=|W_i|$.
* (e) $|\mathcal F_S|\le2^{\min(r,2s)}$ and the chain $2^{2s}N_\sigma/N_s\le2^{2\sigma-(s-\sigma)(2+2\log_2(k+\sigma))}$:
  no violation for $2\le k\le29$, $1\le\sigma\le39$, $\sigma\le s<\sigma+60$, and the bound is at most $1$
  whenever $s-\sigma\ge\sigma/(1+\log_2(k+\sigma))$.
* (g) The bounds on $\beta$ taken from Theorem 32: the core law was checked against a direct enumeration of all
  circuits with their cores for $(k,s)=(2,1),(2,2),(2,3),(3,2)$; the two-sided ratio bound and the bound
  $\beta(a)\le\frac1{16k^2}(16(k-1))^{-(a-1)}/(a-1)!$ in exact arithmetic for $2\le k\le7$, $s\le13$, all $a$.
  The prices $13.00$ and $14.12$ bits under the length prior at $k=20$ were reproduced.
* (i) Source Proposition 16, line by line. Construction: $6(2^\omega-1)+9\le12(k+\sigma)-3$ for $2\le k<40$,
  $\sigma<200$. Upper bound $16.5\cdot2^j/j$: the constructed size times $j/2^j$ is at most $9.0$ for
  $4\le j<200$, and the three inequalities on $t$ hold. Lower bound: $s+1\ge2^{j^*}$ from (a); $j^*\ge
  \min(k,\lfloor\log_2(\sigma+3)\rfloor)$ from Lemma 33(c); $2^{\lfloor\log_2(\sigma+3)\rfloor}-1>(\sigma+1)/2$
  for $\sigma<10^5$; the chain $2^{j(\sigma)}-1>\sigma(j(\sigma)+1)/34-1>\sigma(\log_2\sigma-2)/34-1$ for
  $68\le\sigma\le2\cdot10^5$ and at $\sigma=10^6,2^{33}\pm1,2^{40}$; $j(\sigma)\ge34$ exactly from
  $\sigma=2^{33}$ on, and at $\sigma=2^{33}-1$ the bound gives only $s\ge\sigma$. The condition on $k$ is
  necessary (finding 5). For $\sigma\ge2^{33}$ and $k\ge j(\sigma)$ the bound also meets the threshold of (e).
  I did not build the universal circuit as a program; its gate count was checked by hand.

**Proposition 39.** (a), (b), (c) derived. (d) recomputed with my own counter: $76$ fitting and $2$ with the
true bit under $\mu_1$; $0.02712$, $0.02760$, $0.02790$ under $\mu_2,\mu_3,\mu_4$; in the AND family with
$k=4$, $4608$ minimum circuits, a quarter answering $1$ at each input with three $0$s. Source Theorem 17(c) and
the second half of (d), which the paper omits, are also correct.

**Proposition 40.** (a) to (d) derived, with the prefix code of (d) written out. (b) is tight in the example
of finding 3. Source Theorem 18(a), second half, and (b)(iii) are correct.

**Encoding and basis.** The prior $\frac12\mathrm{Tw}_*q+2^{-j-1}q$: $\xi'(x)=(\frac12+2^{-j-1})\xi(x)$ and
$\xi'(xy)\ge\frac12\xi(x)$. The weight of the wrapper with the added gate type. The factor $4$ between the
bases (exclusive or and its negation need four gates over $\{\wedge,\vee,\neg\}$, every other binary function
at most two). The counting statement, with the repair of finding 17(ii).

**Concentration.** Source Theorem 3(c) re-derived ($\varepsilon+e^{-\varepsilon n}/\mu(f^*)$ with
$\varepsilon=(\ln(1/\mu(f^*))+\ln n)/n$), the division by $\rho$, the floor from Theorem 34(b) with $a=g+1$,
and the counting bound ($\sum_{j\le s}N_j<2N_s\le2(16(k+s-1)^2)^s$ for $k,s<12$). Source Theorem 20(d) and the
second half of (e) are correct.

**Proposition 41.** (c) from Lemma 33(c). (d): the cell was built and run for $300$ random circuits with
$k\in\{2,3,4\}$ and $s\le5$; it prints $\ctt(\Gamma)$ with $t(n)=n$ and has $s+2k-1$ gates. (a), (b): finding 8.

**Small cases.** My own dynamic programme agrees with a direct enumeration of every circuit for
$(k,s)=(2,1),(2,2),(2,3),(3,1),(3,2),(4,1),(4,2)$, and reproduces every count in
`experiments/results/circuits.json` as an exact integer: the five rows of the query form, the six rows of the
sequence form, the AND family for $k=3,4$, and the three triggered variants. Both tables and every number
quoted in Section 7.10 agree with the file, apart from the wording in finding 6.

**The minimal-circuit question.** Conditions 1 and 2 of the open problem are met by Theorem 35(c) for every
world that is not periodic at the cut: condition 2 only says that $y_n$ is not the label of $u_n^\dagger$,
since $u_n^\dagger$ belongs to the larger data set.

**Paper against source.** Statements of Theorem 38, Propositions 39 to 41 and the two paragraphs were compared
with source Theorems 14 to 21 item by item. Weakened without loss: (c) keeps the inequality and drops the
equality. Dropped: source 14(d)(iv), 14(f), 15(c) middle clause, 17(c), half of 17(d), half of 18(a),
18(b)(iii), 19(a) second half, 20(d), half of 20(e); all are correct. Dropped with loss: the caveat after
source Proposition 16 (finding 9), the count of cells in source Proposition 21 (finding 8), the prior on the
enlarged basis in source Theorem 19(b) (finding 14). Corrected in the paper: one table entry (finding 17).
Strengthened: nothing in a numbered statement; the title and the README (finding 1).

**Not checked.** The cited literature. In particular the relation between circuit size and
$\mathrm{KT}$ (line 729) is quoted from the ECCC report; from memory, the journal version of that paper states
a weaker pair of polynomial bounds for a machine with random access to its description. "Polynomially
related" holds either way, and the claims referee should say which version is quoted. The argued paragraph
after Proposition 41 was read and not verified; it is marked as argued.

**Scripts** (in a scratch directory, not kept in the repository; it may have been cleared since):

* `/tmp/claude-0/-home-user-AI-works/6274030e-7ece-5c94-928b-387c437d466d/scratchpad/ref-circuits-math-b/mycount.py`: own counter of circuits by function (direct enumeration and a dynamic programme over the
  multiset of wire functions), tested against each other.
* `/tmp/claude-0/-home-user-AI-works/6274030e-7ece-5c94-928b-387c437d466d/scratchpad/ref-circuits-math-b/check_tables.py`: all entries of `circuits.json`, the capture example, the functions of three variables
  by size.
* `/tmp/claude-0/-home-user-AI-works/6274030e-7ece-5c94-928b-387c437d466d/scratchpad/ref-circuits-math-b/check_misc.py`: core law and bounds on $\beta$; dependence on inputs; seeded circuits; the arithmetic of
  universal circuits; the inequality of (e); $\sum_jN_j<2N_s$.
* `/tmp/claude-0/-home-user-AI-works/6274030e-7ece-5c94-928b-387c437d466d/scratchpad/ref-circuits-math-b/check_rec.py`: the counter cell of Proposition 41(d); the $18$ values of $b_0\oplus b_{10}$ of
  finding 3.
* `/tmp/claude-0/-home-user-AI-works/6274030e-7ece-5c94-928b-387c437d466d/scratchpad/ref-circuits-math-b/check_onegate.py`: the counts $110$ and $2$ of finding 3.
