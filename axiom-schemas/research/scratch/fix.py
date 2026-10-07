p='sections/experiments.tex'
s=open(p).read()
def rep(old,new):
    global s
    assert old in s, old[:90]
    s=s.replace(old,new)
rep(r"is the universal-set schema $\forall a\exists b\forall x\,(P(x,a)\to x\in b)$.",r"is the universal-set schema $U=\forall a\exists b\forall x\,(P(x,a)\to x\in b)$.")
rep(r"When the motives' root symbols differ and the $\in$-induction motive does not begin with $\forall$ (the most frequent case),",
    r"When the motives' root symbols differ, the $\in$-induction motive does not begin with $\forall$, and some motive uses its variable (the most frequent case),")
open(p,'w').write(s)
p='sections/app-experiments.tex'
s=open(p).read()
rep(r"(b) Let $e=\EInd(\varphi)$ and $e'=\mathrm{EInd2}(\psi)$, where the roots of $\varphi$ and $\psi$ differ and $\varphi$ does not begin with $\forall$.",
     r"(b) Let $e=\EInd(\varphi)$ and $e'=\mathrm{EInd2}(\psi)$, where the roots of $\varphi$ and $\psi$ differ, $\varphi$ does not begin with $\forall$, and $\varphi$ or $\psi$ uses its variable.")
rep(r"it is $T_{EE}$ (with $P_0$ of arity at most $1$, as only $y$ can occur in the column at $\square_1$).",
     r"it is $T_{EE}$: $P_0$ is unary, since only $y$ occurs in the column at $\square_1$ and $z\in y$ mentions it, and $P_1$ is unary, since some motive uses its variable.")
rep("which fails at $x=\\{\\emptyset\\}$.\n\nThe remaining claims",
"""which fails at $x=\\{\\emptyset\\}$.
% NOTE: the record states (b) for "the motives' heads differ and the EInd motive does not begin with forall".
% If neither motive uses its variable, P_1 is 0-ary and the template is valid (its premise fails at x = emptyset
% whenever P_1 is false), so the hypothesis "some motive uses its variable" was added.
If neither motive uses its variable, $P_1$ is $0$-ary and the template is valid: when $P_1$ is false its premise $\\forall x\\,\\neg\\forall y(y\\in x\\to P_0(y))$ fails at $x=\\emptyset$. This case, not covered by the record's statement, is why (b) assumes that some motive uses its variable.

The remaining claims""")
rep(r"so $U$ is the unique normal configuration and the unique minimal covering template.",r"so the universal-set schema $U$ is the unique normal configuration and the unique minimal covering template.")
open(p,'w').write(s)
