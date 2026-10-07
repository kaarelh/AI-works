import sys
P='/home/user/AI-works/axiom-schemas/paper/sections/many.tex'
A='/home/user/AI-works/axiom-schemas/paper/sections/app-many.tex'
s=open(P).read(); a=open(A).read()
def cut(text,x,y):
    i=text.index(x); j=text.index(y,i); return text[i:j]
def rep(old,new,which='s'):
    global s,a
    t=s if which=='s' else a
    n=t.count(old)
    if n!=1: print('MISMATCH',which,n,repr(old[:90])); sys.exit(1)
    t=t.replace(old,new)
    if which=='s': s=t
    else: a=t

# MDL
old=cut(s,r"by the main connective of the motive. A naive code",r"%=====")
rep(old, r"""by the main connective of the motive. A naive code splits, by a margin linear in the number of induction data
(\cref{prop:many:mdlnaive}); a well-specified code gains at most $O(\log n)$ from splitting (\cref{prop:many:mdlwell});
and under a natural usage law even depth-aware adaptive codes split for $n\ge1.6\cdot10^4$, while under a law for which
the code is well specified it keeps $T_{\Ind}$ whole (\cref{tab:many:mdl}). \textbf{MDL tracks the statistics of usage,
not the logical boundaries of schemas}: it errs towards incompleteness for schemas and towards unsoundness for rarely used
ground axioms, errors that the anchor condition and the refutation test of \DTRC{} control (\cref{app:many:mdl}).

""")
rep(r"""\subsection{MDL}\label{app:many:mdl}
""", r"""\subsection{MDL}\label{app:many:mdl}

MDL with likelihood errs in two directions. For schemas it errs towards incompleteness: a split is a sound but incomplete
hypothesis, which never accepts induction on an unused connective. For rarely used ground axioms it errs towards
unsoundness: two ground axioms used $m$ times each are merged by the naive code into their lgg once $m$ times the body
cost is below the template saving, and for $0+0=0$ and $0\cdot0=0$ that lgg, $z=0$, is false. The refutation test of
\DTRC{} catches the second error, and the anchor condition (data diversity) controls the first. This is the size principle
\citep{tenenbaum2001generalization} and MDL \citep{rissanen1978modeling} meeting a hypothesis space whose boundaries are
logical rather than statistical. The definitions and results follow.
""",'a')
rep(r"""The regret bound and the no-hypercompression inequality are standard, but we cite them from memory and did not re-check
them. Two ground axioms used $m$ times each are merged by the naive code into their lgg once $m$ times the body cost is
below the template saving; for $0+0=0$ and $0\cdot0=0$ that lgg, $z=0$, is false.""",
r"""The regret bound and the no-hypercompression inequality are standard, but we cite them from memory and did not re-check
them. With a well-specified code, splitting cannot win linearly; the decision falls to lower-order terms, which favour
fewer templates. This does not prove that MDL selects the target partition. Computed (\cref{tab:many:mdl}): the naive code
splits from $n\approx10^3$; under the natural law G1 even the depth-aware code DPC splits for $n\ge1.6\cdot10^4$, because
usage really differs across connectives (terms under a quantifier see a bound variable); under G2, for which DPC is well
specified, DPC keeps $T_{\Ind}$ whole with a margin growing like $\log n$, while the misspecified PC eventually splits.""",'a')

# univset proof -> appendix
old=cut(s,r"""\begin{proof}
Every instance holds in $M_0$ with $x:=u$;""",r"With logic and HF only, \DTRC{} merges")
rep(old, r"""\noindent\emph{Proof idea.} Every instance holds in $M_0$ with $x:=u$, and R-HF's steps are sound in $M_0$; a witness $b$
of $\exists x\forall y(y=y\to y\in x)$ gives $b\in b$ (\cref{app:many:examples}).\medskip

""")
univproof=old.replace(r"\begin{proof}",r"\begin{proof}[Proof of \cref{prop:many:univset}]").rstrip()+"\n"
rep(r"""\begin{example}[\DTRC{} on ZF and ZFC]""", univproof+"\n"+r"""\begin{example}[\DTRC{} on ZF and ZFC]""",'a')

# fragmentation example
old=cut(s,r"For (d), let $\sigma_1=(z+0=z)$",r"\begin{proposition}[ambiguous practices]")
rep(old, r"""For (d), let $\sigma_1=(z+0=z)$, $g=(0+S0=S0)$ a ground target and $D=\{0+0=0,\ S0+0=S0,\ g\}$, which contains the
anchor $\{0+0=0,S0+0=S0\}$ of $\sigma_1$. In the order $g,0+0=0,S0+0=S0$, the pair $\{g,0+0=0\}$ merges through the
\emph{true} template $0+z=z$, and $S0+0=S0$ cannot join (\cref{app:many:dtrc}); the output rejects $p+0=p$ and accepts
the true non-target $0+p=p$. In the order $0+0=0,S0+0=S0,g$ it is exact (computed). This failure is intrinsic:

""")
# cost intro
old=cut(s,r"\Cref{thm:many:dtrc}(v) counts coherence tests.",r"\begin{theorem}[complexity]")
rep(old, r"""\Cref{thm:many:dtrc}(v) counts coherence tests. A test needs at most $|\Min(X)|$ refutation checks; $|\Min(X)|$ can be
$4^n$ for two data of size $O(n)$ (\cref{prop:single:blowup}), but it is $1$ when $X$ is quantifier-free or contains an
anchor (under \Rich), and with a single negative the test is polynomial (\cref{prop:many:testcost}). In every test of the
PA and ZF runs below, $|\Min(X)|=1$. In general both the exact union verifier and the refutation test are hard; write
$\Acc_k(D):=\Acc_k(D,\emptyset)$.

""")
# linkage summary
old=cut(s,r"Coherence is downward closed but not transitive, so \DTRC{} must test whole clusters",r"%=====")
rep(old, r"""Coherence is downward closed but not transitive, so \DTRC{} tests whole clusters: single linkage on the
pairwise-coherence graph can build clusters with no unrefuted minimal template; under $\RS_d(D)$ single linkage, complete
linkage and \DTRC{} agree (\cref{prop:many:linkage}). Refutable mistakes stay incoherent singletons, and under separation
of the clean data mistakes never bridge targets; an unrefutable mistake can be absorbed into a target's cluster, making it
unsound, or fragment it (\cref{prop:many:noise}). \emph{Robust} \DTRC{} asserts only clusters of multiplicity $\ge s>e$
and verifies them with a trimmed verifier that tolerates $e$ mistakes. If the clean data are separated, every mistake is
refutable or noise-separated, and every coherent set of mistakes has multiplicity $<s$, it asserts exactly the $D_i$ of
multiplicity $\ge s$, soundly, and exactly once every subset of $D_i$ of size $\ge|D_i|-e$ contains an anchor.
Fragmentation is not prevented, and a frequent coherent family of mistakes is a systematic error that no positive-data
method can tell from a rule (\cref{ex:many:noise}).

""")
rep(r"""under $\RS_d(D)$ with $k=k'$ once every $D_i$ contains an anchor, because $\RS_d(D)$ implies (X) for $N(D,d)$
(\cref{rem:many:combine}).""", r"""under $\RS_d(D)$ with $k=k'$ once every $D_i$ contains an anchor (\cref{rem:many:combine}).""")
# summary
old=cut(s,r"\DTRC{} answers Question~3 (\cref{tab:many:summary}).",r"\begin{table}[ht]")
rep(old, r"""\DTRC{} answers Question~3; \cref{tab:many:summary} collects the guarantees. Under refutation separation untagged
learning is as easy as tagged learning: \DTRC{} recovers the hidden labels without being told their number, is
target-sound at all times, and is exact from anchors at the tagged rates. PA is separated at small depth (proved for
Q1--Q7 and $T_{\Ind}$), and ZF and ZFC on every sampled pair and every run. Without separation \DTRC{} is sound relative to
a residue that no computable learner can avoid in general. Four features are forced by the results above, and a naive
version without them fails: (1)~test whole clusters and intersect all unrefuted minimal templates (coherence is not
transitive, and a $K_0$-shaped template can sit next to the sound one); (2)~keep the refutation depth as a parameter and
re-cluster as it grows; (3)~when a bound $k\ge k'$ is known, intersect with the $k$-union learner fed with \DTRC's own
negatives, which restores target-soundness without separation and, at $k=k'$ under separation, loses no exactness once
anchors are present; (4)~implement refutation as a growing set of refuted sentences, audited after each run
(\cref{prop:many:audit}). Spare slots cost diversity (\cref{sec:many:bound}), and ambiguous data defeat every learner
(\cref{prop:many:ambiguity}). Open problems: \cref{sec:disc:open}.

""")
open(P,'w').write(s); open(A,'w').write(a); print('ok')
