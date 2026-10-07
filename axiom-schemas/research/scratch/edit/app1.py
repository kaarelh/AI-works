import sys
P='/home/user/AI-works/axiom-schemas/paper/sections/app-many.tex'
ORIG='/tmp/claude-0/-home-user-AI-works/c4435474-536f-5a96-a73c-7d0c5ea93659/scratchpad/orig/'
s=open(ORIG+'app-many.tex').read()
m=open(ORIG+'many.tex').read()
def rep(old,new,cnt=1):
    global s
    n=s.count(old)
    if n!=cnt:
        print('MISMATCH',n,repr(old[:80])); sys.exit(1)
    s=s.replace(old,new)
def cut(text,a,b):
    i=text.index(a); j=text.index(b,i)
    return text[i:j]

# --- setting subsection: lemma proof
rep(r"""(a) $\manyRstar=\bigcup_i\inst(\sigma_i)\in\Hk{k}$ because $k\ge k'$; it contains $D$ and avoids $N$. Larger $D$ or $N$
shrink the version space, so they enlarge its intersection.""",
r"""(a) $\manyRstar=\bigcup_i\inst(\sigma_i)\in\Hk{k}$ because $k\ge k'$; it contains $D$ and avoids $N$. Larger $D$ or $N$
shrink the version space, so they enlarge its intersection (\cref{thm:setting:vs}(a), \cref{lem:setting:onesided}(b)).""")
rep(r"""and membership of a query are decided by matching (\cref{sec:single}).""",
    r"""and membership of a query are decided by matching (\cref{thm:setting:matching}).""")

# --- bound subsection: insert slots theorem and PA corollary before proof of splits? after it.
slots=cut(m,r"\begin{theorem}[slot accounting]",r"\begin{remark}[head classes and numerals]")
# renumber Q in corollary
slots=slots.replace(r"""\status{proved; computed (consistency check)}\src{untagged Cor 4.2}
Let the targets be $\Q$'s axioms Q1--Q7 as ground sentences in closure-normal form ($\neg Sp=0$; $Sp=Sp'\to p=p'$;
$p+0=p$; $p+Sp'=S(p+p')$; $p\cdot0=0$; $p\cdot Sp'=p\cdot p'+p$; $\neg p=0\to\exists y\,p=Sy$) and $T_{\Ind}$, so
$k'=8$. (Abs) holds for induction for every motive: a template covering a $\Q$-axiom and an induction instance is $F_0$,
or $F_0\to F_1$ for Q2 and Q7, and both contain $\inst(T_{\Ind})$. On positive data $c=4$ (Q3--Q6 share $z_0=z_1$; Q1,
Q2, Q7 stay alone), so at $k=8$ induction gets four slots:""",
r"""\status{proved; computed}\src{untagged Cor 4.2}
Let the targets be $\Q$'s axioms Q1--Q7 (numbered as in \cref{sec:setting:examples}) as ground sentences in
closure-normal form ($\neg Sp=0$; $Sp=Sp'\to p=p'$; $\neg p=0\to\exists y\,p=Sy$; $p+0=p$; $p+Sp'=S(p+p')$; $p\cdot0=0$;
$p\cdot Sp'=p\cdot p'+p$) and $T_{\Ind}$, so $k'=8$. (Abs) holds for induction for every motive: a template covering a
$\Q$-axiom and an induction instance lies above $F_0$, or above $F_0\to F_1$ for Q2 and Q3 ($F_0,F_1$ $0$-ary formula
metavariables), and both contain $\inst(T_{\Ind})$. On positive data $c=4$ (Q4--Q7 share $z_0=z_1$; Q1, Q2, Q3 stay
alone), so at $k=8$ induction gets four slots:""")
assert 'Q4--Q7 share' in slots
slots=slots.replace(r"""$c=7$, induction gets one slot, and the tagged anchor condition \evR{}+\evN{} suffices. (In the Sub-encoded presentation
of induction analysed in the prior work of this project, $c=1$.)""",
r"""$c=7$, induction gets one slot, and the tagged anchor condition \evR{}+\evN{} suffices. (In the Sub-encoded presentation
of induction of the earlier analysis of untagged PA, $c=1$ \src{prior pa-untagged}.)""")
assert 'earlier analysis of untagged PA' in slots
slots=slots.replace(r"""The computed check of $c=4$ and $c=7$ (24/24 cases) holds by construction given (Abs) and the anchor theorem for
$T_{\Ind}$, so it is a consistency check of the implementation, not independent evidence (as the referee noted).""",
r"""The computed check of $c=4$ and $c=7$ (24/24 cases, untagged u2) holds by construction given (Abs) and the anchor theorem
for $T_{\Ind}$ (\cref{thm:zf:indanchor}), so it is a consistency check of the implementation, not independent evidence.""")
assert 'not independent evidence.' in slots
slotsintro="In general a target's slots may be shared with others, provided every shared slot contains the whole target.\n\n"
rep(r"""\begin{proof}[Proof of \cref{thm:many:slots}]""", slotsintro+slots.rstrip()+"\n\n"+r"""\begin{proof}[Proof of \cref{thm:many:slots}]""")

# --- proof of PA corollary, renumbered
old=cut(s,r"\begin{proof}[Proof of \cref{cor:many:paslots}]",r"\begin{corollary}[thresholds in terms of failure families]")
new=r"""\begin{proof}[Proof of \cref{cor:many:paslots}]
\emph{(Abs).} At the top level of a sentence no bound variable is in scope, so a metavariable whose pattern occurrence
is not under a binder is 0-ary. A $\Q$-axiom with root $\neg$ or $=$ and an induction instance (root $\to$) have no common
root, so their minimal covering template is the bare $F_0$. Q2 and Q3 have root $\to$; their antecedents ($=$, resp.\
$\neg$) differ in head from the induction antecedent ($\wedge$), and their consequents ($=$, resp.\ $\exists$) from the
induction consequent ($\forall$); the two slots are closed and not equal in either datum, so the minimal covering template
is $F_0\to F_1$. This holds for every motive. Every covering template lies above one of these (\cref{prop:many:W}), and
both contain $\inst(T_{\Ind})$.
\emph{$c=4$ with $N=\emptyset$.} Any template covering two of Q1, Q2, Q3, or one of them and one of Q4--Q7, lies above
$F_0$ or $F_0\to F_1$ (compare the roots and, for Q2 and Q3, the heads of antecedents and consequents), hence contains
$\inst(T_{\Ind})$. So Q1, Q2 and Q3 need a slot each and Q4--Q7 at least one; $z_0=z_1$ covers Q4--Q7 and contains no
induction instance. \emph{$c=7$ with $N=\{0=S0,(p+0)=0,(p\cdot0)=S0\}$.} Q4 and Q5 have the lgg $p+z_0=z_1$ (common prefix
$=,+,p$; closed slots), which has the instance $(p+0)=0\in N$; Q6 and Q7 have $p\cdot z_0=z_1\ni(p\cdot0)=S0$; the other
pairs among Q4--Q7 have $z_0=z_1\ni0=S0$. All covering templates of these pairs lie above the lggs, so Q4--Q7 need a slot
each. ($F_0$ is now refuted, $F_0\to F_1$ is not, so (Abs) still holds.) Then induction gets $k-7=1$ slot, and by
\cref{thm:many:slots} it is learned exactly iff its data contain an anchor, which for $T_{\Ind}$ is \evR{}+\evN{}
(\cref{thm:zf:indanchor}).
\emph{The four-slot criterion.} Let $q$ be an induction instance whose motive has $x$ free and has a main connective that
occurs in no datum. By \cref{thm:zf:indanchor}, a block of induction data is a non-anchor iff its motives all have the same
root $f$ or are all vacuous; then $T_{\Ind}[P:=\lambda x.f(\dots)]$, resp.\ $T_{\Ind}[P:=\lambda x.A]$, covers the block and
misses $q$. Let $\chi$ be the least number of blocks in a partition of the induction data into blocks that are
root-homogeneous or all-vacuous (without vacuous motives: the number of main connectives occurring). If $\chi\le4$, these
templates for an optimal partition, together with the cover $\{$Q1, Q2, Q3, $z_0=z_1\}$ of the $\Q$-data, form a hypothesis
with $8$ slots missing $q$ (\cref{thm:many:slots}(b)). If $\chi>4$, every family of at most four templates covering the
induction data has, by partition into first covering members, an anchor block, whose template contains $\inst(T_{\Ind})$
(\cref{thm:many:slots}(a)).
\end{proof}

"""
s=s.replace(old,new)

# --- cor:many:failure examples: nine root specializations
rep(r"""for $T_{\Ind}$ the eight root
specializations $T_{\Ind}[P:=\lambda x.f(\bar P(x))]$, $f\in\{=,\neg,\wedge,\vee,\to,\leftrightarrow,\forall,\exists\}$, and the
vacuous one $T_{\Ind}[P:=\lambda x.A]$.)""",
r"""for $T_{\Ind}$ the nine root
specializations $T_{\Ind}[P:=\lambda x.f(\bar P(x))]$, $f\in\{=,<,\neg,\wedge,\vee,\to,\leftrightarrow,\forall,\exists\}$
(eight in the untagged prototype, whose arithmetic has no $<$), and the vacuous one $T_{\Ind}[P:=\lambda x.A]$.)""")

old=cut(s,r"The first version of the research record added that Plotkin's failure family",r"\paragraph{Head classes.}")
new=r"""On positive data ($N=\emptyset$) target $i$ is learned exactly if every partition of $D_i$ into at most $k$ blocks (at most
$k-c_i$ under (Abs)) has an anchor block, and not if $D_i$ is covered by $k-k'+1$ proper specializations missing an
instance of $\sigma_i$ that lies in no other target \src{untagged Prop 6.1}. For PA the gap between $k-c$ and $k-k'+1$ is
the whole story: $c=1$ for Sub-encoded steps, $c=4$ for raw sentences, and $c=7=k'-1$ with three negatives. The classical
sufficient condition ``not covered by $k$ failure sets'' is vacuous for $T_{\Ind}$ at $k\ge9$, because the nine root
specializations cover every induction instance. Plotkin's failure families are not $m$-noncovering for every $m$ once data
are read under universal closure (\cref{prop:many:heads}; the earlier contrary claim is withdrawn, \cref{app:ver:corr}).

"""
s=s.replace(old,new)

# --- head classes: insert rem:many:numerals after the identification sentence
rem=cut(m,r"\begin{remark}[head classes and numerals]",r"%=====")
rem_new=r"""\begin{remark}[head classes and numerals]\label{rem:many:numerals}
\status{proved; computed}\src{untagged U17}
Because data are read under universal closure, a one-variable instance schema $\varphi(z)$ is covered by its
$h=|F|+p+1$ head specializations ($F$ the function symbols, $p$ the number of parameters of $\varphi$; $5+p$ in
arithmetic), one per head class of the value of $z$, a parameter outside $\varphi$ being one class
(\cref{prop:many:heads}). So once $m\ge h$ (i.e.\ at least $h-1$ spare slots) the ``failure family'' covers everything.
For quantifier-free, parameter-free $\varphi$, under the hypotheses of \cref{prop:many:onevar}, the exact threshold is known
for $m\le h$ (\cref{prop:many:onevar}) and, over a unary signature, in closed form (\cref{prop:many:unary}). In particular
\emph{numeral-only data never make the cautious $k$-union learner accept $\forall x\varphi$ with one spare slot} when
$\varphi(a)$ lies in no other target's instance set: the sound split $\{\varphi(0)\}\cup\inst(\varphi(Su))$ misses
$\varphi(a)$ (\cref{thm:many:splits}(a)). Brute-force checks agree with all three propositions (2000/2000, 60/60, 254/254,
2509/2509 cases). Beyond this the spare-slot threshold is open (binary symbols with $m>h$, several metavariables,
templates with parameters, $T_{\Ind}$ with $m\ge9$, where the nine root specializations already cover $\inst(T_{\Ind})$).
\end{remark}
"""
rep(r"""as the closure reading demands and as the implementation does (parameters are renamed canonically by first occurrence).
""", r"""as the closure reading demands and as the implementation does (parameters are renamed canonically by first occurrence).
\Cref{rem:many:numerals} summarizes the results; \cref{prop:many:heads,prop:many:onevar,prop:many:unary} state and prove them.

"""+rem_new)

# --- rem:many:combine: drop history, keep caveat
rep(r"""cross pair $d$-refuted, so $N(D,d)$ satisfies (X) and \cref{thm:many:pigeonhole} applies. (The research record says
``exact whenever \DTRC{} is exact and $k=k'$''; \DTRC{} can be exact without anchors, because refuted templates of whole
clusters drop out, while $N(D,d)$ contains only refutations of pair templates, so the anchor hypothesis is needed for the
argument given.)""",
r"""cross pair $d$-refuted, so $N(D,d)$ satisfies (X) and \cref{thm:many:pigeonhole} applies. The anchor hypothesis is
needed for this argument: \DTRC{} can be exact without anchors, because refuted templates of whole clusters drop out,
while $N(D,d)$ contains only refutations of pair templates (\cref{app:ver:corr}).""")
rep(r"""since the $\Q$/induction templates $F_0$ and $F_0\to F_1$ are absorbing, three suffice (\cref{cor:many:paslots}).""",
r"""since the $\Q$/induction templates $F_0$ and $F_0\to F_1$ contain all of $\inst(T_{\Ind})$, three suffice for the
$k$-union learner (\cref{cor:many:paslots}).""")
rep(r"""For PA (\cref{tab:many:pacross}) the four sentences""", r"""For PA (\cref{tab:many:pacross}) the four sentences""")

# --- dtrc proofs
rep(r"""(iv) Under global separation, (ii) and (iii) hold for every $D\subseteq\manyRstar$. So \DTRC{} fails to be exact only if some
$D_i$ lacks an anchor, which is the failure event of the tagged learner given the labels. Averaging the tagged bound over
the binomial number of target-$i$ data gives the rate.""",
r"""(iv) Under global separation, (ii) and (iii) hold for every $D\subseteq\manyRstar$. So \DTRC{} fails to be exact only if some
$D_i$ lacks an anchor, which is the failure event of the tagged learner given the labels; the union bound over $i$ gives
the sum, and averaging the tagged bound over the binomial number of target-$i$ data gives the rate.""")

rep(r"""By the rigid-prefix lemma of \cref{sec:single} the rigid skeleton""", r"""By \cref{lem:single:basic}(c) the rigid skeleton""")

old=cut(s,r"\begin{proof}[Proof of \cref{prop:many:forall}]",r"\begin{proof}[Proof of \cref{thm:many:depth}]")
new=r"""\begin{proof}[Proof of \cref{prop:many:forall}]
(a) $\varphi(z)$ covers $D$, and by \cref{lem:many:twopoint} every covering template contains $\inst(\varphi(z))$; so some
covering template is unrefuted iff $\varphi(z)$ is (\cref{lem:many:mono}). (b) In closure-normal form a parameter is read
universally; it must be fresh, so that $\varphi(a)$ is not an instance at a special parameter. If all instances are true,
so is the closure of $\varphi(a)$, i.e.\ $\forall x\varphi$; conversely every instance follows from $\forall x\varphi$.
(c) If $\forall x\varphi$ is true, every instance is true, so every subset of $D$ is coherent (\cref{thm:many:dtrc}(i) with
the single target $\varphi(z)$), and no two clusters can remain at termination. In the single final cluster every
unrefuted minimal template contains $\inst(\varphi(z))$ (\cref{lem:many:twopoint}), and one of them is contained in it
(\cref{prop:many:W}(c)), so $\Acc_d=\inst(\varphi(z))$. The oracle is a fixed function of the query, so the practices
``$n$ ground instances'' and ``$\varphi(z)$'' produce the same run. (d) By (a); a subset whose terms all have the same head,
e.g.\ $S$, has other minimal templates such as $\varphi(Sz)$, which need not be refuted. (e) The first claim is the
definition of completeness for false instances plus (b), and \cref{prop:many:qf} applied to $T=\varphi(z)$ gives it for
R-$\Delta_0$ and quantifier-free $\varphi$. R-$\Delta_0$ verifies universal statements only by equality reasoning from true
closed equations, so a false sentence whose refutation needs a true universal premise that this reasoning cannot verify is
never refuted; the noisy-PA computation (\cref{ex:many:noise}) contains such a sentence, the wrong-base induction variant
$(\neg S0=0\wedge\forall x(\neg x=0\to\neg Sx=0))\to\forall x\,\neg x=0$, whose refutation needs the universal premise
$\forall x(\neg x=0\to\neg Sx=0)$, which follows from Q1 \src{untagged referee U7; u8}. At a finite budget, a merge through
a false universal whose least counterexample lies beyond the budget is part of $\Res_d$ (\cref{thm:many:residue}). In $\R$
as an ordered field every closed term denotes an integer (\cref{ex:univ:fail}(a)), and no integer squares to $2$, so every
closed instance of $\neg(z\cdot z=1+1)$ is true, while $\neg(p\cdot p=1+1)$, read universally, is false; a decision
procedure for real closed fields would refute it. $\Q\vdash0+\num n=\num n$ for each $n$ but $\Q\nvdash\forall x(0+x=x)$ is
\cref{ex:univ:q}.
\end{proof}

\begin{proof}[Proof of \cref{prop:many:qf}]
Let $s=T\theta$ be false. Its universal closure is false in $\N$, so some assignment $\bar n$ of numerals to the
parameters of $s$ makes $s[\bar n]$ false. Let $\theta'$ agree with $\theta$ on term metavariables, and for a formula
metavariable $F$ let $\theta'(F):=(0=0)$ if $\theta(F)[\bar n]$ is true in $\N$ and $(0=S0)$ otherwise. Then $s':=T\theta'$
is quantifier-free, since $T$'s rigid part, the term values and the new formula values are. Moreover $s'[\bar n]$ has the
truth value of $s[\bar n]$: the rigid part has no binders, so it is a Boolean combination of equations between terms built
from rigid symbols and unchanged term values, and of occurrences of formula metavariables, whose replacements have the
same truth values at $\bar n$. So $s'$ is false. At depth at least $\max(\bar n,|s'|)$, R-$\Delta_0$ instantiates the
parameters of $s'$ (which are among those of $s$) by $\bar n$ and evaluates the resulting closed quantifier-free sentence,
so $s'\in\Ref_\infty$. If $T$ is in $\Res_\infty$, no instance is refuted, so $T$ has no false instance.
\end{proof}

"""
s=s.replace(old,new)

old=cut(s,r"The first version of this construction used Kleene's $T$ predicate",r"\begin{proof}[Proof of \cref{prop:many:linkage}]")
new=r"""R-$\Delta_0$ cannot verify bounded universal quantifiers, which is why the construction uses MRDP rather than Kleene's
$T$ predicate (\cref{app:ver:corr}). Alternatively, keep the Kleene-$T$ form and take as oracle the full evaluation of
closed $\Delta_0$ sentences with bounded quantifiers as primitives, which is also sound and decidable per depth.

%=====================================================================================================================
\subsection{Whole-cluster tests and noise}\label{app:many:noise}

"""
linkage=cut(m,r"\begin{proposition}[whole-cluster versus pairwise tests]",r"%=====")
new+=linkage.rstrip()+"\n\n"
s=s.replace(old,new)

open(P,'w').write(s)
print('ok')
