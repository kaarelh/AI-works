import sys
P='/home/user/AI-works/axiom-schemas/paper/sections/many.tex'
s=open(P).read()
def rep(old,new):
    global s
    n=s.count(old)
    if n!=1: print('MISMATCH',n,repr(old[:90])); sys.exit(1)
    s=s.replace(old,new)
rep(r"""\noindent\emph{Idea.} Via MRDP \citep{davis1961decision,matiyasevich1993hilbert}, whether a two-instance merge of a
true-looking arithmetic schema is ever refuted encodes the halting problem, so ``this merge is never refuted'' is
$\Pi_1$-complete (\cref{app:many:dtrc}).\medskip

The obstruction is the $\Pi_1$-completeness of ``this merge is never refuted'', not lack of information. \DTRC{} with a
depth schedule""", r"""\noindent\emph{Idea.} Via MRDP \citep{davis1961decision,matiyasevich1993hilbert}, whether a two-instance merge of a
true-looking arithmetic schema is ever refuted encodes the halting problem (\cref{app:many:dtrc}).\medskip

The obstruction is the $\Pi_1$-completeness of ``this merge is never refuted'', not lack of information. \DTRC{} with a
depth schedule""")
old=s[s.index("When targets share slots"):s.index("spare-slot threshold is open.")+len("spare-slot threshold is open.")]
rep(old,r"""Slot accounting refines this when targets share slots (\cref{thm:many:slots}). For $\Q$ plus induction at $k=k'=8$,
positive data leave induction four slots: an induction instance whose motive has $x$ free and a main connective unseen in
the data is accepted iff the induction data cannot be split into four blocks each root-homogeneous or all-vacuous; three
sound negatives leave it one slot and restore the tagged anchor condition \evR{}+\evN{} (\cref{cor:many:paslots}). Spare
slots cost diversity even for $\forall x\varphi$: if the target is the instance schema $\varphi(z)$ and $\varphi(a)$ lies in
no other target's instance set, numeral-only data never make the learner accept $\varphi(a)$ once $k>k'$, since
$\{\varphi(0)\}\cup\inst(\varphi(Su))$ is a sound split. Exact thresholds for one-variable schemas:
\cref{rem:many:numerals}.""")
rep(r"""\item From positive data alone a bound $k$ on the number of targets is necessary, and spare slots are paid for in data
  diversity, which no sound negative evidence can replace (\cref{sec:many:bound}).""", r"""\item From positive data alone a bound $k$ on the number of targets is necessary, and spare slots cost data diversity,
  which no sound negative evidence can replace (\cref{sec:many:bound}).""")
rep(r"""So the two refutation channels
of the setting separate the ZFC axioms on every sampled pair and every run, and Russell's paradox does the work exactly
where the axioms look alike. \Cref{sec:exp}""", r"""So the two refutation channels
of the setting separate the ZFC axioms on every sampled pair and every run. \Cref{sec:exp}""")
rep(r"""\paragraph{PA.} Every cross merge among Q1--Q7 and $T_{\Ind}$, and among the instance schemas of $\Q$'s axioms (the
alternative presentation of $\Q$ by closed instances), is refuted""", r"""\paragraph{PA.} Every cross merge among Q1--Q7 and $T_{\Ind}$, and among the instance schemas of $\Q$'s axioms, is
refuted""")
open(P,'w').write(s); print('ok')
