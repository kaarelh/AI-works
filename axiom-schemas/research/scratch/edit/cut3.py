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
# 1 computed paragraph -> appendix
old=cut(s,r"\Cref{prop:univ:tv} characterizes when closed instances decide universals",r"\begin{proposition}[quantifier-free templates]")
rep(old, r"""\Cref{prop:univ:tv} characterizes when closed instances decide universals (the Tarski--Vaught criterion); computed
examples, e.g.\ numeral instances of Q4--Q6 merging into their instance schemas, are in \cref{app:many:dtrc}.

""")
comp=r"""\noindent Computed (untagged u6): numeral instances of Q4--Q6, as 12 ground targets, form three clusters with templates
$z_0+0=z_0$, $z_0+Sz_1=S(z_0+z_1)$, $z_0\cdot0=0$, and \DTRC{} accepts $p+0=p$; instances of the false $n\cdot n=n$
($n=0,1$) stay apart (refuted at $2$); $\neg(n\cdot n=2)$, $n\le2$, merge and the true $\neg(p\cdot p=2)$ is accepted.

"""
rep(r"""\begin{proof}[Proof of \cref{prop:many:qf}]""", comp+r"""\begin{proof}[Proof of \cref{prop:many:qf}]""",'a')
# 2 twopoint idea
rep(r"""\noindent\emph{Proof idea.} If $G(z),K(z)$ contain $z$ only as a leaf and agree at two closed values with different heads,
then $G=K$; this forces every occurrence of a covering template to agree with $\varphi(z)$ (\cref{app:many:dtrc}). The
lemma is the one-metavariable case of \cref{prop:univ:dt}(a), and the case of \cref{thm:single:anchor} in which \evU{}
holds automatically.""", r"""\noindent It is the one-metavariable case of \cref{prop:univ:dt}(a), and the case of \cref{thm:single:anchor} in which
\evU{} holds automatically; the proof rests on a two-point identity (\cref{app:many:dtrc}).""")
# 3 K0 compress
old=cut(s,r"\emph{$K_0$} (\cref{thm:zf:K0}), the first-order lgg",r"\emph{Permanent residue}")
rep(old, r"""\emph{$K_0$}, the first-order lgg of $\Ind(0+x=x)$ and $\Ind(S0+x=Sx)$, has a false instance $J^*_0$ that R-$\Delta_0$ and
logic never refute (\cref{thm:zf:K0}). In $\DT$ these data also have a sound $T_{\Ind}$-specialization, and the verifier
intersects both, so $J^*_0$ is rejected; the $K_0$-shaped template harms only when a mistake removes the sound alternative
(\cref{ex:many:noise}), and coherence with designated or learned $\Q$ refutes it (\cref{app:many:examples}). """)
# 4 budget sentence
rep(r"""\Cref{prop:exp:qF} reports a finite-budget effect (a residue in $\Res_d$, not a permanent one): with
injected mistakes and a small refutation budget, two mistakes merged into a false template and a false sentence was
accepted; a larger budget refuted the merge.""", r"""\Cref{prop:exp:qF} reports a finite-budget effect (a residue in $\Res_d$, not a permanent one): two
injected mistakes merged into a false template at a small refutation budget, and a larger budget refuted the merge.""")
# 5 residual merges paragraph
rep(r"""Only separating data such as $SS0+0=SS0\in\manyRstar_P\setminus\manyRstar_{P'}$ resolve this; the $k'$-union learner with
self-generated negatives is not exact on this $D$ either (computed), since the true template $0+z=z$ violates (X).
Residual merges come in three kinds: \emph{target-sound} ones (a redundant axiom that is an instance of a target schema,
e.g.\ Empty Set as an instance of Separation); \emph{sound} ones (true templates below no target, as for $\forall x\varphi$
below); and \emph{unsound unrefuted} ones (the $K_0$-shaped templates of induction and the universal-set schema,
\cref{sec:many:examples}).""", r"""Only separating data such as $SS0+0=SS0\in\manyRstar_P\setminus\manyRstar_{P'}$ resolve this; the $k'$-union learner with
self-generated negatives is not exact on this $D$ either (computed), since the true template $0+z=z$ violates (X).
Residual merges are \emph{target-sound} (a redundant axiom that is an instance of a target schema, e.g.\ Empty Set of
Separation), \emph{sound} (true templates below no target, as for $\forall x\varphi$ below), or \emph{unsound unrefuted}
($K_0$-shaped templates, the universal-set schema; \cref{sec:many:examples}).""")
# 6 summary
rep(r"""\DTRC{} answers Question~3; \cref{tab:many:summary} collects the guarantees. Under refutation separation untagged
learning is as easy as tagged learning: \DTRC{} recovers the hidden labels without being told their number, is
target-sound at all times, and is exact from anchors at the tagged rates. PA is separated at small depth (proved for
Q1--Q7 and $T_{\Ind}$), and ZF and ZFC on every sampled pair and every run. Without separation \DTRC{} is sound relative to
a residue that no computable learner can avoid in general.""", r"""\DTRC{} answers Question~3 (\cref{tab:many:summary}). Under refutation separation untagged learning is as easy as
tagged learning, and the number of targets need not be known; PA is separated at small depth (proved for Q1--Q7 and
$T_{\Ind}$), and ZF and ZFC on every sampled pair and every run. Without separation \DTRC{} is sound relative to a residue
that no computable learner can avoid in general.""")
open(P,'w').write(s); open(A,'w').write(a); print('ok')
