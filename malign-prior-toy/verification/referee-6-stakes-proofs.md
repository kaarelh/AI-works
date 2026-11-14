# Referee report 6 (proofs) on Section 3.7, "Concentration where the most is at stake"

Date: 2026-11-14. Written by an AI referee that had not seen the note before; not reviewed by a human.

**Version refereed.** `paper/sec3b-stakes.tex` as committed in `6b534400` on `claude/lucid-hypatia-j4jg12`, with the
passages that summarise it in `paper/main.tex` (abstract), `paper/sec1-intro.tex`, `paper/sec8-answers.tex` and
`README.md`, and its source `research/stakes-final.md`. Read first: `README.md`, `paper/main.tex`,
`paper/sec2-toy.tex`, `paper/sec3-floor.tex`, `paper/sec4-limits.tex`, `verification/README.md`.

**Lens.** Mathematics only: each statement was written down and derived before its proof was read; constants,
directions of inequalities, quantifier order, edge cases and every use of an earlier result were checked; what
can be computed was computed. I did not read the other report of this round.

**Numbering.** That of the PDF: Proposition 16 (what the toy fixes), Theorem 17 (the lump), Theorem 18
(weighted seeker), Proposition 19 (cost of aiming), Proposition 20 (honest twin under concentration and
closure), Example 21, Proposition 22 (optimal allocation), Proposition 23 (readings of "run more than $n$
times"). "Source Proposition $k$" means the numbering of `research/stakes-final.md`. Line numbers are those
of the source files.

**Method.** Pencil and paper, and seven Python scripts run in a scratch directory (exact rational arithmetic
where possible). The scripts are not part of the repository; what each did is listed in the last section. No
script executes strings as programs: the "machines" are lookup tables, closed-form masses, or the reading rule
of Theorem 18 simulated as a process on intervals.

## Verdict

No numbered statement of Section 3.7 is wrong. Propositions 16, 19, 20, 22, 23 and Theorems 17, 18 hold with
their constants, their proofs are complete up to one-line steps, and all six items of Example 21 are correct.
The statements taken by pointer agree with the source, the source's proofs of them hold, and so do the four
items used in the paper that the source lists as not seen by a referee (the proof of Theorem 18 through
maximal dyadic intervals; the condition (B1) with a following rest; $B>(2^n-1)\,\xi(z)$; item (f) of the
example). Every closed form agreed with numerical optimisation. The problems are in what the prose and the
summaries say the results show.

* One sentence of the abstract is wrong as written: an aimed seeker does not outweigh the users of a class
  "however rare the class is", only once the class is rare enough (finding 1).
* Example 21 is presented as a class that is "not won". What it proves is the failure of (W1), which holds for
  every $n$ and for a reason unrelated to $n$; for most uses, (W2) and (W3), the example gives necessary
  conditions on two constants and decides nothing where they hold. Two summaries turn the necessary condition
  into "is decided by" (findings 2, 3).
* The question asks about "most cases". Theorem 17(A) gives a necessary condition for (W1) only. The source
  has the one for (W3); it was dropped, and it is the one place where the users are the channel (finding 4).
* One cross-reference gives a wrong reason (the lineage and conservation, finding 5), one reading of "run $n$
  times" is treated only in the form the question does not ask about (finding 6), and several sentences drop
  a hypothesis of the statement they summarise (findings 7 to 10).
* The rest is small (findings 11 to 16).

---

## Findings

### 1. "It then outweighs the users of the class, however rare the class is." Overclaim

**Where.** `paper/main.tex` 78-81 (abstract).

**Problem.** By Proposition 19(a) the seeker aimed at $\mathcal W_n$ has, at each use of the class, at least
$2^{-a_n}2^{j_n-1}$ times the mass of the users of the class, with $\tfrac1{2C(\mathcal W_n)}<2^{j_n-1}\le\tfrac1{C(\mathcal W_n)}$;
under (INC) this is the exact ratio (Theorem 18(b)). The factor exceeds $1$ only if $C(\mathcal W_n)<2^{-a_n}$,
and it certainly does once $C(\mathcal W_n)\le2^{-a_n-1}$. Under (INC) no program family of weight $2^{-a_n}$
outweighs the users of a class of mass at least $2^{-a_n}$ at every one of its uses (Proposition 16(b)). So
for a class that is not rare the seeker is lighter than the users. The sentence states the conclusion
without the condition, and "however rare" points the wrong way: rarity is what makes it true. `README.md` 29
and `paper/sec8-answers.tex` 98-99 state it correctly.

**Corrected text.** "It then outweighs the \emph{users} of the class once the class is rarer than half the
seeker's weight; the bits that name the scale grow only as twice the logarithm of the logarithm of the
rarity."

### 2. Example 21 proves the failure of (W1) only, and that failure holds for every $n$. Overclaim

**Where.** `paper/sec3b-stakes.tex` 279 (title "and not won"), 301-306 (item (e)), 462-464; the same claim in
`paper/sec1-intro.tex` 125-127, `paper/sec8-answers.tex` 109-111, `README.md` 31.

**Problem.** Three things.

(i) The section defines three meanings of "they win" and says they are kept apart. Item (e) shows that $F_n$
does not have the majority at *every* use of $\mathcal W_n$: that is not-(W1). The title and the summaries
("not won"; "still cannot have the majority at every use") are read as evidence that the seeker loses on the
class. For (W2) and (W3) the example shows no such thing.

(ii) The failure of (W1) needs no "large $n$" and has nothing to do with the stake. For every $n\ge1$ and all
values of the constants,
$$\frac{\mu_{F_n}(x_k)}{O_{F_n}(x_k)}\ \le\ \frac{2^{-|v_A|-1}n^{-2}\,2^{-(k-n+1)}}{2^{-|v_D|-3}k^{-2}}\ =\ 2^{|v_D|-|v_A|+2}\,(k/n)^2\,2^{-(k-n+1)}\ \longrightarrow\ 0\quad(k\to\infty),$$
so $F_n$ is below the rest at $x_k$ for all large $k$. The attacker spreads in proportion to the users,
$2^{-(k-n)}$, and the proved part of the rest falls like $k^{-2}$. The uses from $x_k$ on carry a share
$2^{-(k-n)}$ of the class, so this failure can be confined to an arbitrarily small part of it. The threshold $n\ge2^{|v_D|-|v_A|+2}$ is needed only for the stronger
statement that no redistribution of the same weight helps.

(iii) What the example says about most uses. Write $d=|v_D|-|v_A|$.

* (W2) by prior mass needs the majority at $x_n$, because the other uses carry exactly half of the class. So
  it needs $|v_A|+1<|v_D|$, that is $d\ge2$. This is the sentence at the end of (e), and it is the
  substantive one.
* (W3) needs $|v_A|\le|v_D|$. Proof: $O_F(x_k)\ge2^{-|v_D|-|\bar e(k)|}$ for every attacker (finding 12), so
  $C(x_k)/O_F(x_k)\le2^{|v_D|-|u|}\,2^{|\bar e(k)|-k}\le2^{|v_D|-|u|+|\bar e(n)|-n+1}$ for $k\ge n$, and by
  the inequality of finding 4, with $H_{\mathcal W_n}=2^{-|u|-n+1}$, the average share is at most
  $2^{|v_D|+|\bar e(n)|}B$. For $B=B_n=2^{-|v_A|-|\bar e(n)|}$ this is $2^{|v_D|-|v_A|}$, which exceeds
  $\frac12$ only if $|v_A|<|v_D|+1$.
* Where these hold the example decides nothing, because only a lower bound on the rest is proved. Against
  that lower bound alone, for $d\ge2$ and large $n$, the attacker is above users and $\mathsf{Ho}$ together at
  $x_n,\dots,x_{n+d-2}$ at least, which carry the share $1-2^{-(d-1)}$ of the prior mass of $\mathcal W_n$
  (computed: $0.5$, $0.75$, $0.875$, $0.9375$ for $d=2,3,4,5$ at $n=1000$).

So in the example (W1) always fails; (W2) by prior mass is excluded by what is proved exactly when $d\le1$;
(W3) is excluded when $d\le-1$ (proved; also for $d=0$ in every case computed); for larger $d$ the example
leaves them open.

**Corrected text.** Title: "A class of mass $2^{-n}$, aimed at with $2\log_2n$ bits: the outcome is set by two
constants". Item (e):

> (e) For every $n$ the attacker fails to supply the majority at some use of $\mathcal W_n$, since
> $\mu_{F_n}(x_k)/O_{F_n}(x_k)\le2^{|v_D|-|v_A|+2}(k/n)^2\,2^{-(k-n+1)}\to0$ as $k\to\infty$; so (W1)
> fails, if nowhere else then far out in the class, at uses that together carry a small share of it. For $n\ge2^{|v_D|-|v_A|+2}$ no redistribution of its weight helps:
> its whole weight is below $O(\mathcal W_n)$, and by Theorem 17(A2) the same holds for every attacker of
> weight at most $2^{-|v_D|-3}/n$. This does not show that most uses of the class are not won. At $x_n$, which
> carries half the prior mass of $\mathcal W_n$, the attacker has $2^{-|v_A|-|\bar e(n)|-1}$ against a rest of
> at least $2^{-|v_D|-|\bar e(n)|}$. So (W2) by prior mass needs $|v_A|+1<|v_D|$, and (W3) needs
> $|v_A|\le|v_D|$: comparisons of two constants of $U$ in which $n$ does not occur. Where they hold the
> example decides nothing, since only a lower bound on the rest is proved.

In the summaries add "(the failure may be confined to uses that carry a small share of the class; for most
uses the example gives only a necessary comparison of two constants)".

### 3. "Who supplies the block at the main context is decided by two constants." Overclaim

**Where.** `README.md` 31; `paper/sec8-answers.tex` 111-112. (The source's plain answer 3 has the same
wording.)

**Problem.** Example 21(e) proves "only if": the attacker has the majority at $x_n$ only if $|v_A|+1<|v_D|$.
If that inequality holds, the outcome depends on the part of the rest that the example does not bound. A
necessary condition is reported as a criterion.

**Corrected text.** "at the main context it can have the majority only if its word is more than one bit
shorter than that of a program that prints the same contexts without taking over, a comparison of two
constants of the machine in which $n$ does not occur."

### 4. No necessary condition for "most uses end in a takeover" (W3). Gap

**Where.** `paper/sec3b-stakes.tex` 92-100 (Theorem 17, Part A), 118-122, 459-462.

**Problem.** The question is whether they take over "in most cases". Part A is a necessary condition for the
majority at every use of a set: (W1), and (W2) when applied to the set where the majority holds. For (W3) the
section proves nothing, and the sentence "the channel in this theorem is the rest and not the users" is then
read for all three meanings. The source has the statement (Theorem 10(A4) there, with (B5) for the model).
For (W3) the lump has to outweigh half the users of the class, divided by the largest number of users per
unit of rest; where the users go on without taking over, half the users. This is the commissioner's picture
as a necessary condition, and it should be stated.

**Corrected text.** Add to Part A:

> \textup{(A3)} Let $\mathcal W$ be a class with contexts in $\mathcal M$ and
> $k_F=\sup_xC_{\mathcal W}(x)/O_F(x)$ over its contexts. Then
> $\sum_x\frac{C_{\mathcal W}(x)}{H_{\mathcal W}}\,w_F(x)\le k_F\,B/H_{\mathcal W}$, so (W3) holds for $F$
> on $\mathcal W$ only if $B>H_{\mathcal W}/(2k_F)$. The users of
> $\mathcal W$ at $x$ that go on with a block outside $A(x)$ belong to the rest of every attacker; if they
> have mass at least $\underline\varphi\,C_{\mathcal W}(x)$ at every context, then $k_F\le1/\underline\varphi$
> and (W3) needs $B>\underline\varphi\,H_{\mathcal W}/2$. With $F$ the set of inputs that print a context of
> $\mathcal W$ followed by a takeover block, this is a statement about $\theta$.

Proof: $w_F\le\mu_F/O_F$, so $C_{\mathcal W}(x)w_F(x)\le k_F\,\mu_F(x)$; sum and use Proposition 16(b). (Checked
on 2278 random table machines, no violation.) After the theorem: "For (W1) and (W2) the channel is the rest.
For (W3) it is the users of the class divided by the users per unit of rest; the users themselves where they
go on without taking over."

### 5. "The lineage of Proposition 15(b); there conservation fails (Proposition 16(b))." Error (wrong reason)

**Where.** `paper/sec3b-stakes.tex` 420-422. The source says the same (Section 3.2, under Lemma 2), and so
did derivation A.

**Problem.** Proposition 16(b) shows that conservation fails for two *different* contexts $x$ and $x'=xyu$
nested through an attack block. In the lineage of `prop:lineage`(b) a world hands over at a first hit $x$,
receives $y\in\mathrm{SR}_m(x)$, and the world $y0^\infty$ "hands over at $x$ again": the context is the same
$x$ in every generation, and two first hits of a test are never nested. On the one-element set $\{x\}$
conservation holds trivially. What is true is different and simpler: the same programs supply the sample in
every generation, so no budget is divided between generations at all.

**Corrected text.** "The one repetition native to the toy is the lineage of \cref{prop:lineage}(b). There
every generation has the same context $x$, so the same programs supply every generation and no weight is
divided between them: with $A(x)=\mathrm{SR}_m(x)$ the block stays in $A(x)$ for $j$ further generations with
probability $\theta(x)^j$. Under a call rule that is not a test a later use can also lie at a context nested
through the earlier block, where conservation fails (\cref{prop:stakes-basic}(b)). Nothing here covers
either."

### 6. The third reading is treated only for a uniform factor. Gap

**Where.** `paper/sec3b-stakes.tex` 417-419; the section's first sentence (4-5) has "run more than $n$ times
*there*".

**Problem.** "Multiplies stakes by $n$ in the model and changes neither the optimal allocation nor the
conditions of Theorem 17" is true if *every* stake is multiplied by $n$ (Proposition 22(b), last sentence).
The reading in the question, and in the section's own first sentence, is that the block is run more often at
the high-stake places. Then $\varrho$ is multiplied there only and the optimal allocation does change; only
the conditions of Theorem 17 do not. The source has this case (Proposition 14(2) there); the paper dropped it.

**Corrected text.** "A third reading, in which blocks are run $n$ times, changes only the stakes. If every
stake is multiplied by $n$, neither the optimal allocation (\cref{prop:allocation}(b)) nor the conditions of
\cref{thm:lump} change. If only the uses of a class $\mathcal W$ are multiplied, the conditions of
\cref{thm:lump} are still unchanged and the optimal allocation moves to $\mathcal W$: in the two-class case
above, with $\varrho\equiv\varrho_{\mathcal W}$ on $\mathcal W$, $\varrho\equiv\varrho_R$ on the remainder
$R$ and $n\varrho_{\mathcal W}>\varrho_R$, the whole weight goes to $\mathcal W$ as long as
$B\le O(\mathcal W)\bigl(\sqrt{n\varrho_{\mathcal W}/\varrho_R}-1\bigr)$, and the attacker has the majority on
$\mathcal W$ iff $B>O(\mathcal W)+O(R)\bigl(2\sqrt{\varrho_R/(n\varrho_{\mathcal W})}-1\bigr)_+$, which is
$O(\mathcal W)$ for $n\ge4\varrho_R/\varrho_{\mathcal W}$. More runs are a reason to be there; they do not
change what winning there costs."

(Checked against the two-class formulas, which were checked against numerical optimisation.)

### 7. Four sentences state the wrapper bound without its hypotheses. Overclaim

**Where.** `paper/sec3b-stakes.tex` 72-73 ("no takeover probability and no attacker's share tends to one");
85-87 ("the rest of every attacker contains $2^{-c}$ times its own mass at each context"); 440-441 ("Its share
is at most $1/(1+2^{-c})$ by Proposition 16(c)"); 468-469 ("a wrapper returns $2^{-c}$ of every program's mass
at each context to another block").

**Problem.** Proposition 16(c) assumes (INC) for the contexts of the whole rule and a partial computable $P'$
with $P'(x)_{1:m}\notin A(x)$; it speaks of contexts of the rule. If $A(x)=\{0,1\}^m$ then $\theta(x)=1$. At
440-441 the takeover set is $\{y_x\}$ and no $P'$ is named. The abstract, Section 1 and Section 8 keep "where
some block that can be computed from the context is not a takeover"; they drop (INC).

**Corrected text.** Add "under (INC), at contexts where not every block is a takeover" in the four places.
The computability condition can be removed, which makes that phrase exact. Let the wrapper of Proposition
16(c) first read $m$ bits $b$ and then print $x\,b$: with $c'$ the length of its prefix word, every block has
$M_U(xb)\ge2^{-c'-m}M_U(x)$ at every context, so under (INC), wherever $A(x)\ne\{0,1\}^m$,
$\theta(x)\le1-2^{-c'-m}$ and $w_F(x)\le1/(1+2^{-c'-m})$ for every $F$. For 440-441: "by
\cref{prop:stakes-basic}(c) with the two constant payloads $0^\infty$ and $1^\infty$, one of which differs
from $y_x$, if the contexts of the rule satisfy (INC)".

### 8. "Most high-stake uses end in a takeover" under a test. Overclaim

**Where.** `paper/sec3b-stakes.tex` 277-278, summarising Proposition 20(d).

**Problem.** Part (d) is about worlds that hand over at a first hit in $\mathcal X'$ *and go on for $m$ more
bits*, and about a class that is a set of first hits, that is, a stake the context shows. The summary drops
both. Over all users at $x$, including those that print fewer than $m$ further bits, the two probabilities
are averages with the weights $M_U(x)$ and $Z_m(x)$ and differ unless $Z_m/M_U$ is constant on
$\mathcal X'$ (the first qualification after `thm:calibration`). "Are takeover programs" means "have an own
continuation in $A(X)$".

**Corrected text.** "Under a test, by (d), for a stake that the context shows and among the users that go
on, 'most high-stake uses end in a takeover' says that most high-stake users have a takeover block as their
own continuation."

### 9. The twin bound "at every use and for every aim" needs (INC). Minor

**Where.** `paper/sec3b-stakes.tex` 273-274.

**Problem.** Proposition 20(a) proves $w_F(x)\le1/(1+2^{a-h}\varphi_g(x))$ under (INC), where
$\mu_F(x)=S_g(x)$. Without (INC) programs of the seeker whose search finds another context can also print
$x\,P(x)_{1:m}$, and the bound is for the programs counted in $S_g(x)$, as in `prop:honest`.

**Corrected text.** "Under (INC), where the users go on, $\varphi_p\equiv1$, the seeker supplies at most
$1/(1+2^{a-h})$ of what the predictor returns, at every use and for every aim; without (INC) this holds for
its programs whose search finds a user at that context."

### 10. "$O_F(x)\ge\varphi(x)C(x)$" needs the attacker to be disjoint from the users. Minor

**Where.** `paper/sec3b-stakes.tex` 120-121.

**Problem.** The source states it conditionally. As written the inequality reads as general. It fails under a
test for every attacker with $\mu_F(x)>0$: there $\varphi(x)C(x)=Z_m(x)$ and $O_F(x)=Z_m(x)-\mu_F(x)$.

**Corrected text.** "If no user at $x$ is a program of $F$, the users that go on belong to the rest and
$O_F(x)\ge\varphi(x)C(x)$; in general $O_F(x)$ contains the users that go on with a block outside $A(x)$."

### 11. "For $F$ the set of all inputs" makes (A2) empty. Minor (weakened in transcription)

**Where.** `paper/sec3b-stakes.tex` 118-119. The source has "the set of all takeover programs" (Section 1.5).

**Problem.** For $F=\{0,1\}^{\mathbb N}$ indeed $w_F=\theta$, but $B=1$, and (A2) says $1>\sum_{\mathcal M}O_F$,
which is trivial under (INC). The statement about all takeover programs together needs their weight.

**Corrected text.** "For $F$ the set of all inputs that print a context of $\mathcal M$ followed by a takeover
block, $w_F=\theta$ on $\mathcal M$ and $B$ is the total mass of the takeover programs there: the theorem
then concerns all of them together."

### 12. Example 21(e): the disjointness hypothesis is not needed, and the bound covers all attackers. Minor (can be strengthened)

**Where.** `paper/sec3b-stakes.tex` 299-304.

**Problem.** The users and the programs of $\mathsf{Ho}$ print $x_k0^m$, and the takeover block is $1^m$.
An input that prints a block outside $A(x)$ is never counted in $\mu_F(x)$, whether or not it lies in $F$. So
$O_F(x_k)\ge C(x_k)+2^{-|v_D|-|\bar e(k)|}$ for *every* attacker $F$, and "that is disjoint from the users
and from the programs of $\mathsf{Ho}$" can be deleted. With $F$ as in finding 11 this gives the statement
for all seekers at once, which the section otherwise lacks for the example.

**Corrected text.** "(d) For every attacker $F$, $O_F(x_k)\ge C(x_k)+2^{-|v_D|-|\bar e(k)|}$, because the
users and the programs of $\mathsf{Ho}$ print the block $0^m$. ... (e) ... The same holds for every attacker
of weight at most $2^{-|v_D|-3}/n$. In particular $\theta>\frac12$ at every use of $\mathcal W_n$ requires
the programs that print some $x_k1^m$, $k\ge n$, to have total mass above $2^{-|v_D|-3}/n$, and
$\theta(x_k)>\frac12$ requires $M_U(x_k1^m)>2^{-|v_D|-|\bar e(k)|}$."

### 13. The description of what one word can realise is proved in one direction only. Gap (in a pointer statement and in its source)

**Where.** `paper/sec3b-stakes.tex` 220-222; source Proposition 16, item 4.

**Problem.** "The programs beginning with one word of length $a$ realise the allocations $2^{-a}q$ with $q$
lower semicomputable and of total at most $1$ on sets of contexts on which the strings $x\,P(x)_{1:m}$ are
pairwise incomparable" reads as a characterisation. The source proves: (item 3) every word's masses have this
form; (item 2) every lower semicomputable $q$ with $\sum_xq(x)\le1$ *over all contexts* is realised, with "at
least". When contexts are comparable a $q$ can satisfy the antichain condition with a larger total, and item
2 does not cover it. Under (INC) the two conditions are the same and the masses are exact.

**Corrected text.** "Every lower semicomputable $q\ge0$ on the contexts with $\sum_xq(x)\le1$ is realised
from below by one word: there is $v_q$, of length a constant plus that of a description of $q$, whose
programs put mass at least $2^{-|v_q|}q(x)$ on $x\,P(x)_{1:m}$ at every context. Conversely the masses that
the programs beginning with a word $v$ put on these strings are $2^{-|v|}Q_v(x)$ with $Q_v$ lower
semicomputable and of total at most $1$ on every set of contexts for which the strings are pairwise
incomparable. Under (INC) the two descriptions agree. Whether the optimum of \cref{prop:allocation} is of
this kind is not known."

### 14. "The rarity of the class among the users." Unclear

**Where.** `paper/sec3b-stakes.tex` 216-218 and 471-472.

**Problem.** The factor named is $2^{j_n-1}>1/(2C(\mathcal W_n))$: the rarity of the users of the class in
the prior. "Among the users" suggests $H_{\mathcal C}/C(\mathcal W_n)$, which is the gain over the unaimed
seeker of `thm:critical`(a) and a different number. The intended contrast is with the other programs that
print the same contexts.

**Corrected text.** "is repaid the factor $2^{j_n-1}>1/(2C(\mathcal W_n))$, the rarity of the class measured
by its users alone; other programs that print the same contexts are not counted. Compared with a seeker for
the whole rule the repayment is larger by $H_{\mathcal C}/C(\mathcal W_n)$, up to a factor $2$."

### 15. Example 21(c): "the rule is not closed under this search for large $n$." Unclear

**Where.** `paper/sec3b-stakes.tex` 295-298.

**Problem.** Closure was defined in Proposition 20(c) for the machine $R_g$ of Theorem 18; $\mathsf{At}$ is
another machine. And the rule of the example, whose only calling programs are the $p_k$, contains none of
the twin's programs for any $n$, so "for large $n$" is not where closure fails. What the computation shows
is that closure and the example's class mass are incompatible for large $n$.

**Corrected text.** "(c) The twin of $\mathsf{At}$ ..., with prefix word $v_T$, has the programs
$v_T\,\bar e(n)1^i0$, of total weight $2^{-|v_T|-|\bar e(n)|}\ge2^{-|v_T|-3}n^{-2}$. None of them is a
calling program. In any rule in which they counted as users of $\mathcal W_n$ the class would have mass at
least $2^{-|v_T|-3}n^{-2}$, which exceeds $2^{-|u|-n+1}$ for large $n$: a class this light exists only
without closure."

### 16. Small points

* **(W2) is not (W3), the numbers** (`sec3b-stakes.tex` 123-125). $C=O=(0.6,0.4)$ with $B=0.7$ has total mass
  $1.7$ and is an instance of the model, in which no $C$ is defined. Say "in the model, with users equal to
  the rest", or halve all five numbers, which makes it realisable in the toy.
* **Gloss of (A2)** (98-99). "The mass of everything else that prints those contexts and $m$ more bits" is a
  measure under (INC). Under the weaker hypothesis of the theorem (cut points of one sequence) it is the sum
  $\sum_{\mathcal M}O_F$, in which an input can be counted at several contexts and which contains the
  attacker's own later attack mass.
* **Proof of Proposition 22(b)** (350-353). For $\bar\varrho=\infty$ the infimum $0$ of $\beta$ needs
  $\beta(\eta)\le S/(4\eta)$, which the bound two lines earlier gives; one clause. The formula for $w^*$
  needs the convention $w^*=0$ where $\varrho=0$.
* **"Each depends on the machine (\cref{thm:machine})"** (478-479). The theorem as stated is about the
  posterior of a payload at first hits. That $h-a$ and $c$ take other values on another machine follows from
  the same construction (a machine with a one-bit prefix word for a chosen machine), not from the statement.
  Say "by the construction of \cref{thm:machine}". The source's "each can be given either sign" (Section 5.1)
  has the same gap.
* **Notation.** In Proposition 20, $D(\sigma)$ is a dyadic interval in (c) and $D$ the own continuation in
  (d). $\beta$ is an end point of an interval in the proof of Theorem 18 and the budget function in
  Proposition 22. In the proof of Proposition 16(c), $w$ is a prefix word next to the share $w_F$. $t$ is a
  time index, a string (proof of 20(c)), the argument of $f_x$ and $\sqrt{\varrho_2/\varrho_1}$. $r$ is the
  stake here and the number of bits read in Section 2; $\tau$, $\eta$, $s$, $S$ also have earlier meanings
  (`thm:budget`, \eqref{eq:twin}, `prop:lineage`, `prop:honest`). The mass of a class is $H_{\mathcal W}$ in
  the definitions and $C(\mathcal W_n)$ from Proposition 19 on. `README.md` and Section 8 write $\rho$ for the
  paper's $\varrho$.
* **Numbers of the source.** "Propositions 16, 18 and 19 there" and "Proposition 23 there" collide with the
  paper's own Propositions 16, 19 and 23. Write "Propositions 16, 18 and 19 of that file".
* **`README.md` 91** lists "the example" and "the three readings of repetition" under "Proved here (short
  proofs in the paper)". The example is stated without proof and proved in `research/stakes-final.md`; the
  third reading is a remark.
* **Source Proposition 18, proof.** "Wait until the number is seen to exceed $\beta_0/(2i)$" needs $\beta_0$
  rational; replace $\beta_0$ by a smaller rational first. **Source Proposition 19** is vacuous for the empty
  context; say "nonempty context".

---

## Transcription from the source

**Agrees.** Proposition 16 = Lemmas 1 to 3; Theorem 17 = Theorem 10(A1),(A2),(B1),(B2); Theorem 18 = Theorem 15
with items 1 to 3; Proposition 19 = Proposition 17(1),(2); Proposition 20 = Propositions 20(1),(2),(4),(5),
21(1),(2), 22; Example 21 = Proposition 23, all six items word for word; Proposition 22 = Lemma 4 and Theorem
5(1) to (4),(6),(7); Proposition 23 = Propositions 12(1) to (3) and (4) in the passive case,
13(1),(3),(4),(5). The pointers are right: 16, 18, 19; 23; 6 to 9; 11, 25, 26 to 28.

**Weakened or dropped.**

* Theorem 10(A4) and (B3) to (B5), the conditions for (W2) and (W3): dropped (finding 4).
* Proposition 14(2), a class whose blocks alone are run $n$ times: dropped (finding 6).
* Section 1.5, "the set of all takeover programs" became "the set of all inputs" (finding 11).
* The conditional form of $O_F\ge\varphi C$ (finding 10); the remark after Lemma 3 that two constant payloads
  suffice for a one-block takeover set, which the second of the three variants needs (finding 7).
* Proposition 13(4): the paper keeps $1-e^{-B/\xi(z)}$ and drops the sharper $1-(1+R/n)^{-n}$. Harmless.
* Proposition 20's limit (iv), that an aim which prefers users who stop printing lowers $\varphi_g$ and so
  weakens its own twin: dropped. Proposition 20(b) says the aim enters through $\varphi_g$; the consequence
  is worth one sentence, since it is the one way an aim does change the twin bound.

**Strengthened.**

* The abstract's "however rare the class is" (finding 1) is not in the source.
* The four sentences of finding 7 state Lemma 3 without its hypotheses.
* "Is decided by two constants" (finding 3) is the source's own wording; it is stronger than its Proposition
  23(5).
* Proposition 16, item 4 (finding 13): the same sentence in source and paper, stronger than items 2 and 3.

**Proof steps in the paper.** None is missing beyond the one-line steps named in finding 16. The proof of
Proposition 20(d) uses `thm:calibration` at each $x$ and then averages over $x\in\mathcal X'$ with the
weights $Z_m(x)$; that average is not written and is immediate.

---

## What was verified, and how

**Section 3.7, by hand.**

* *Definitions.* $\theta\ge w_F$; (W1) implies (W2) and (W3) (strict inequality survives a countable average
  with positive weights); the (W2)-not-(W3) example ($0.7/1.3=0.538$; $0.6\cdot0.538=0.323$).
* *Proposition 16.* (a) from `def:call`; (b) including the cut-point clause and the nested case; (c) the
  wrapper prints $x\,P'(x)$ on every $\omega\in E(x)$ because of (INC), and its programs are in the rest of
  every $F$, also of one that contains them. That (b) holds for any machine and bounds: yes, by
  `lem:basic`(i).
* *Theorem 17.* (A1), (A2) with the strict inequality for infinite $\mathcal M$; (B1) both directions, the
  case $\Lambda=\infty$, and $\tau\ge1$; (B2).
* *Theorem 18.* The machine is monotone; total interval length $2^{j-1}\Gamma_g\le1$; the Claim, line by line
  (for a proper prefix $\sigma'$ an end point of $I$ lies in the interior of $D(\sigma')$; no end point of any
  interval ever assigned lies in the interior of $D(\sigma)$; rule (i) cannot fire early with another
  interval); the maximal dyadic intervals cover $I$ up to its left end point; (b) exactness and the
  optimality bound; $|j_g|\le|\log_2\Gamma_g|+1$ for both signs of $\log_2\Gamma_g$.
* *Proposition 19.* Both parts; $g=f\circ r$ is a weight; $2^{-a_n}2^{j_n-1}>2^{-|v'|-7}/(n^2j_n^2C(\mathcal W_n))$;
  $\Gamma_g\le H_{\mathcal C}+S$.
* *Proposition 20.* (a) to (d). All ratios have the right direction throughout the section and the
  summaries: twin over seeker is $2^{a-h}$, seeker over twin $2^{h-a}$, seeker over users at most $2^{h-a}$
  under closure.
* *Example 21.* It is a call rule with (INC); (a) to (f) with every constant; the three sets of programs are
  disjoint. Also that pairwise incomparable prefix words of the three machines exist (two machines with
  different outputs cannot have comparable prefix words here).
* *Proposition 22.* (a) with uniqueness in the three cases; (b): $f_x'$, the budget function, existence and
  uniqueness of $\eta_B$, shares, the majority condition with $\tau$, scaling. The two-class formulas and
  the threshold $B>O_1+O_2(2t-1)_+$, by cases $t<\frac12$ and $t\ge\frac12$.
* *Proposition 23.* (a); (b) including $R_i\ge2^{n-i}\xi(z)$ and the sum; the model statement
  $B>(2^{1/n}-1)\,O(\mathcal M)$ and $2^{1/n}-1\le1/n$ (convexity of $2^t$ on $[0,1]$).
* *Uses of earlier results.* `lem:basic`(i), `def:call`, `def:universal`, `thm:twin`, `thm:critical`(a),
  `prop:honest`, `thm:calibration`, `prop:lineage`, `thm:budget` were compared with their statements. The one
  mismatch is finding 5.

**The source's proofs of the pointer statements, by hand.** Proposition 16(2),(3) (with finding 13);
Proposition 18 (the recursion-theorem argument is correct: the stages are reached one after another, the
last member has share at least $1/i$ of the class, and the $K$ disjoint events contradict the choice of
$K$); Proposition 19; Proposition 23; Proposition 6(a); Proposition 7(1),(2); Proposition 9(2),(3);
Proposition 11(1),(2); Proposition 25(2),(4); Proposition 26; Proposition 27 (the root $u_N$, the marginal
return $\frac\varrho N(u^2+(N-1)u)$, uniqueness among symmetric profiles, the majority condition);
Proposition 28(1),(4).

**Items the source lists as not seen by a referee, where the paper uses them.**

| item | in the paper | check |
|---|---|---|
| proof of Theorem 15 through maximal dyadic intervals | proof of Theorem 18 | by hand; simulated (below) |
| Theorem 10(B1) with a following rest | Theorem 17(B1) | by hand; 3000 random instances |
| Proposition 13(5), $B>(2^n-1)\xi(z)$ | Proposition 23(b) | by hand; 453 random instances with the majority at all uses; tight |
| Proposition 23(6) | Example 21(f) | by hand; exact for five choices of the constants |

The other unrefereed items (the bound $0.43\,B$, Theorem 10(B5), the following-rest clauses of Proposition
12(4), Theorem 15(4), the last sentence of Proposition 25(5)) are not used in the paper and were not
checked.

**Numerically.** All scripts ran without a failed assertion.

* `check_alloc.py`. Proposition 22(b) against a constrained optimiser (SLSQP, six random starts, the result
  projected back onto the budget) on 300 random instances with 2 to 8 contexts, random follow ratios and some
  zero stakes: largest difference in value $3\cdot10^{-14}$, in the allocation $8\cdot10^{-8}$; 15000 random
  feasible allocations never beat the closed form; attacked set, majority condition with $\tau$ and scaling
  agree. Two-class shares and majority threshold on 2000 random instances: no mismatch. (B1) and (B2). The
  thresholds of Proposition 23(a) for $n<60$. Partial sums of the infinite-value allocation.
* `check_reading_rule.py`. The reading rule of Theorem 18 with intervals arriving at random stages, exact
  rationals, 400 schedules with dyadic and 200 with other end points, 11074 halting cylinders: the machine
  outputs exactly on the maximal dyadic intervals inside assigned intervals, reads exactly $\sigma$ there, and
  the measure per label equals the assigned length (for non-dyadic end points up to the depth explored).
* `check_toy.py`. Random finite table machines, exact: conservation on 1500 antichains; (A1) and (A2) on 599
  majority sets; the cut-point clause on 1403 sequences; the nested counterexample; Proposition 23(b) on 3918
  instances. Tightness of $B>(2^n-1)\xi(z)$: ratios $1.000001$, $3.000004$, $7.000012$, $63.000192$ for
  $n=1,2,3,6$.
* `check_example.py`. Example 21 with $(|u|,|v_A|,|v_D|)=(5,9,9),(5,9,14),(12,7,20),(3,20,6),(30,10,11)$ and
  $n<400$: items (a), (b), (d), (e), (f) in exact arithmetic; $|\bar e(j)|=2\lfloor\log_2j\rfloor+3$ and
  $j^{-2}/8\le2^{-|\bar e(j)|}<j^{-2}/2$ for $j<5000$.
* `check_w123.py`. For finding 2: the first use at which $F_n$ is below users and $\mathsf{Ho}$, for $n$
  between $1$ and $10^5$ and eighteen choices of the constants (it exists in every case, at most $91$ places
  after $x_n$); the share of $\mathcal W_n$ on which $F_n$ is above the proved rest, $1-2^{-(d-1)}$; an upper
  bound on the average share from the proved rest (largest value $0.35$ for $d=0$, $0.51$ for $d=1$, $0.66$
  for $d=2$; never above $\frac12$ for $d\le0$); $\sup_{k\ge n}(|\bar e(k)|-k)\le|\bar e(n)|-n+1$ for
  $n<3000$. For finding 4: the inequality on 2278 random tables.
* `check_game.py`. Disjoint supports: best-response iteration from random starts reaches the stated
  equilibrium in 200 games. Symmetric game, 300 instances with 2 to 6 attackers: the closed form is a best
  response to itself, $\eta^{(N)}\ge\eta_1$, the attacked set is a subset, the captured stake is at most
  $V^*(B_{\rm tot})$, and the joint majority condition $\varrho>\frac{4N}{2N-1}\eta^{(N)}$ holds.
* `check_codes.py`. $|\tilde e(j_g)|\le2\log_2(|\log_2\Gamma_g|+2)+4$ and the inequality of Proposition 19(a)
  on 200000 random cases each; $\Gamma_g\le H_{\mathcal C}+S$.

**Not checked.** The self-reproduction constants of Section 3 (taken from rounds 3 and 4); the circuit
section; the literature. Nothing in this section counts circuits, so there was nothing to enumerate.
