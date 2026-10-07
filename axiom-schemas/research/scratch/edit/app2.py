import sys
P='/home/user/AI-works/axiom-schemas/paper/sections/app-many.tex'
s=open(P).read()
def rep(old,new,cnt=1):
    global s
    n=s.count(old)
    if n!=cnt:
        print('MISMATCH',n,repr(old[:80])); sys.exit(1)
    s=s.replace(old,new)
def cut(text,a,b):
    i=text.index(a); j=text.index(b,i)
    return text[i:j]
rep(r"""R-$\Delta_0$ cannot verify bounded universal quantifiers, which is why the construction uses MRDP rather than Kleene's
$T$ predicate (\cref{app:ver:corr}).""", r"""R-$\Delta_0$ cannot verify the bounded universal quantifiers of Kleene's $T$ predicate, which is why the construction
uses MRDP (\cref{app:ver:corr}).""")
# testcost proof refs
rep(r"""so the anchor-determines-template result of \cref{sec:single} (single Cor G.4) makes $\sigma$ the least covering
template, computed by its polynomial lgg construction.""", r"""so \cref{cor:single:anchor-lgg} makes $\sigma$ the least covering template, computed by the polynomial lgg
construction of \cref{prop:single:lgg}.""")
rep(r"""$\Acc(X)$ is decided in polynomial time by the feature
verifier (single Thm C).""", r"""$\Acc(X)$ is decided in polynomial time by the feature
verifier (\cref{thm:single:feat,cor:single:poly}).""")
# features paragraph
old=cut(s,r"\paragraph{Features (recalled from \cref{sec:single}).}",r"\begin{lemma}[failure types]")
new=r"""\paragraph{Features.} Common prefix $C(B)$, slots, $A(B)$, scopes $Y_\sigma(B)$, the features $\mathrm{Sym}(p)$,
$\mathrm{Scope}(\sigma)$, $\mathrm{Eq}(\sigma,r,\bar u)$ and $\Feat(B)$ are as in \cref{def:single:features}, and
$\Acc(B)=\Feat(B)$, decidable in polynomial time (\cref{thm:single:feat,cor:single:poly}). For positions $\sigma\perp r$ of the
same sort and a sentence $d$, the \emph{matcher} $e_d$, if it exists, is the unique partial map on $\FV(d|_\sigma)$ with
$d|_r=(d|_\sigma)[e_d]$ (forcing, \cref{lem:single:basic}(d)). With \eqref{eq:many:partition}, ``$q\in\Acc_k(D)$'' is in
coNP for every $k$: a partition into at most $k$ blocks $B$ with $q\notin\Acc(B)$ is a certificate of non-membership.

"""
s=s.replace(old,new)
rep(r"""covering template does (minimal templates are saturated, \cref{sec:single}).""", r"""covering template does (minimal templates are saturated, \cref{thm:single:min}(c)).""")
rep(r"""Whether $X$ has a least covering template is decidable in polynomial time, and then
it is computed (single Prop G.3), and $\Min(X)$ is that template; under \Rich{} an anchor gives one (single Cor G.4).""",
r"""Whether $X$ has a least covering template is decidable in polynomial time, and then
it is computed (\cref{prop:single:lgg}), and $\Min(X)$ is that template; under \Rich{} an anchor gives one
(\cref{cor:single:anchor-lgg}).""")
rep(r"""$k=1,\dots,4$; on 25 random set systems $q\in\Acc_k(D)$ iff no $k$ sets cover; for $n\le6$, $|\Min(X)|=2^n$ in the SAT
reduction, and the test equals satisfiability on 360/360 random CNFs. These results were added to the single track's
record after its referee round and were not refereed independently.""",
r"""$k=1,\dots,4$; on 25 random set systems $q\in\Acc_k(D)$ iff no $k$ sets cover; for $n\le6$, $|\Min(X)|=2^n$ in the SAT
reduction, and the test equals satisfiability on 360/360 random CNFs. These results were not refereed independently
(\cref{app:ver:unref}).""")
rep(r"""$k=1$ is the feature theorem.""", r"""$k=1$ is \cref{thm:single:feat}.""")
# MDL
rep(r"""\status{proved, using standard coding facts cited from memory}\src{untagged Prop 6.3}""",
    r"""\status{proved}\src{untagged Prop 6.3; coding facts cited from memory}""")
rep(r"""The referee checked both proofs; the regret and no-hypercompression facts are standard but were cited from memory in the
research record and not re-checked there.""",
r"""The regret bound and the no-hypercompression inequality are standard, but we cite them from memory and did not re-check
them. Two ground axioms used $m$ times each are merged by the naive code into their lgg once $m$ times the body cost is
below the template saving; for $0+0=0$ and $0\cdot0=0$ that lgg, $z=0$, is false.""")
# examples
rep(r"""Refuter soundness is supported by code reading and by the referee's fuzzing (0 of 3000 true arithmetic and 1206 true
set-theoretic sentences refuted). Every \DTRC{} run of the record passed the audit on the first pass (24 runs checked), and
the re-audit after the separation check found no inconsistent decision.""",
r"""Refuter soundness is supported by code reading and by the referee's fuzzing (0 of 3000 true arithmetic and 1206 true
set-theoretic sentences refuted). Every \DTRC{} run passed the audit on the first pass (24 runs checked), and the re-audit
after the separation check found no inconsistent decision. (The prototype's first version decided refutation by
template-specific searches, which is not monotone in $\gen$; the global refuted set and the audit replaced it, and no
result changed, \cref{app:ver:corr}.)""")
rep(r"""\caption{PA cross merges: the unique minimal covering template of each cross pair and an R-$\Delta_0$ refutation (computed,
untagged u1; the referee's independent enumeration of all covering templates of size $\le14$ agrees). Q$_i^s$ is the
instance schema of Q$_i$ (closed terms for the parameters), an alternative presentation of $\Q$.}\label{tab:many:pacross}""",
r"""\caption{PA cross merges: the unique minimal covering template of each cross pair and an R-$\Delta_0$ refutation (computed,
untagged u1; the referee's independent enumeration of all 68 covering templates of size $\le14$ of the 49 cross pairs of
Q1--Q7 and $T_{\Ind}$ agrees). Numbering as in \cref{sec:setting:examples}, in parameter form. Q$_i^s$ is the instance
schema of Q$_i$ (closed terms for the parameters), an alternative presentation of $\Q$.}\label{tab:many:pacross}""")
rep(r"""different roots (Q1--Q3 etc.); Q$_i$--Ind, root $\neq\to$ & $F_0$ & $0=S0$\\
Q2--Q7, Q2--Ind, Q7--Ind & $F_0\to F_1$ & $0=0\to0=S0$\\
Q3--Q5, Q3--Q6, Q4--Q5, Q4--Q6 & $z_0=z_1$ & $0=S0$\\
Q3--Q4 & $p+z_0=z_1$ & $p+0=0$ at $p:=1$\\
Q5--Q6 & $p\cdot z_0=z_1$ & $p\cdot0=S0$ at $p:=0$\\""",
r"""different roots (Q1--Q4 etc.); Q$_i$--Ind, root $\neq\to$ & $F_0$ & $0=S0$\\
Q2--Q3, Q2--Ind, Q3--Ind & $F_0\to F_1$ & $0=0\to0=S0$\\
Q4--Q6, Q4--Q7, Q5--Q6, Q5--Q7 & $z_0=z_1$ & $0=S0$\\
Q4--Q5 & $p+z_0=z_1$ & $p+0=0$ at $p:=1$\\
Q6--Q7 & $p\cdot z_0=z_1$ & $p\cdot0=S0$ at $p:=0$\\""")
rep(r"""Held-out data come from other seeds; the referee found no leakage.""",
r"""Held-out data come from other seeds; the referee found no leakage. Separation on the data was verified for all 147, 201
and 175 cross pairs of the three PA runs.""")
rep(r"""\status{computed; independently confirmed by the referee}\src{untagged u4, u13}""",
    r"""\status{computed}\src{untagged u4, u13; confirmed by the referee}""")
rep(r"""\status{computed; reproduced by the referee}\src{untagged u8}""", r"""\status{computed}\src{untagged u8; reproduced by the referee}""")
old=cut(s,r"\paragraph{$K_0$.}",r"\paragraph{Computations.}")
new=r"""\paragraph{$K_0$.} $K_0=(z_1+0=z_1)\wedge\forall x(z_1+x=z_2\to z_1+Sx=Sz_2)\to\forall x(z_1+x=z_2)$ is the first-order lgg
(named encoding) of $\Ind(0+x=x)$ and $\Ind(S0+x=Sx)$. By \cref{thm:zf:K0}, no sound refutation from quantifier-free truths
exists, so R-$\Delta_0$ and logic refute none of its instances, among them the false $J^*_0$. In $\DT$ the pair has two
minimal covering templates (computed; the referee's enumerator found no other among 6258 covering templates of size
$\le24$): $T_{\Ind}[P:=\lambda x.(f(0)+x=f(x))]$ and the $K_0$-shaped template of \cref{ex:many:noise}. The intersection
verifier excludes $J^*_0$ (it is not an instance of the first). The $K_0$-shaped template has $J^*_0$ as an instance
($f:=\lambda h.0$) and is refuted by coherence with designated $\Q$: the refutation of $J^*_0$ through the recursion axiom
Q5, $\forall x\forall y\,(x+Sy=S(x+y))$, goes through once Q5 is designated (\src{prior induction B5(d)}; see the remark
after \cref{thm:zf:K0}).

"""
s=s.replace(old,new)
rep(r"""clustering is. Covering problems for first-order patterns, relevant to the open spare-slot thresholds, are decidable by
results on complement problems and ground reducibility \citep{lassez1987explicit,comon2003ground} (cited from memory in the
research record, not re-checked there). As far as the record knows, the refutation test, the separation theorem, the depth
impossibility, the head-class thresholds and the implementation audit are new.""",
r"""clustering is. Covering problems for first-order patterns, relevant to the open spare-slot thresholds, are decidable by
results on complement problems and ground reducibility \citep{lassez1987explicit,comon2003ground} (cited from memory, not
re-checked). As far as we know, the refutation test, the separation theorem, the depth impossibility, the head-class
thresholds and the implementation audit are new.""")
open(P,'w').write(s)
print('ok')
