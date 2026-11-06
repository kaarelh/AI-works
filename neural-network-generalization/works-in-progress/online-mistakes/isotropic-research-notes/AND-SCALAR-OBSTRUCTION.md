# The scalar AND implementation is not optimal at large width and dimension

This is a separate canonical-prior obstruction. It does not establish an online mistake lower bound.

Let d=n and let f be AND of all n Boolean inputs, positive only at the all-positive corner. Its scalar affine unit-margin vector is

    a_*=(-(n-1),1,...,1),    Q=n²-n+1.

For the canonical shallow-tanh energy E=n E_neurons||u||²+E_neurons b², the best scalar clone has u=r a_*, b=C=1/(2tanh r), where r minimizes nQ r²+1/(4tanh²r). Its only active signed output margins are the positive corner and the n corners with one negative bit.

The positive affine KKT probabilities on these n+1 active points are

    rho_+=(n²-2n+2)/(2Q),
    rho_j=n/(2Q), j=1,...,n.

They sum to one and their signed-vector mean is a_*/Q. The active vectors are linearly independent. Set

    lambda=1/tanh²r,
    K=lambda²/4,
    zeta=nQ r²-1/(4tanh²r).

Choose any fixed t>0, put c=t/(n-1), and consider an extra atom with

    u1=c(1,1,...,1).

Its active signed average is

    S_n=rho_+ tanh((n+1)c)-[n²/(2Q)]tanh(t).

Choose b1=lambda S_n/2. Its atomwise dual value is

    Jbad=n(n+1)c²-K S_n².

As n tends to infinity, r tends to zero, K/n³ tends to one, and zeta tends to -1/6. Moreover

    n S_n -> -a_t,
    a_t=tanh t-t sech²t>0.

The last strict inequality follows because a_0=0 and a_t'=2t sech²t tanh t>0. Thus

    Jbad/n -> -a_t²<0,

and Jbad<zeta for every sufficiently large n.

## Explicit feasible descent, rather than only a failed dual

Give the new atom mass epsilon and the main atom mass 1-epsilon. Keep the main readout C fixed. Choose its first-layer affine coefficients to be beta(epsilon) for the bias and w(epsilon) for every input. Define its scores at the positive corner and a one-negative neighbor by

    R_+(epsilon)=atanh[(1/2-epsilon b1 tanh((n+1)c))/((1-epsilon)C)],
    R_-(epsilon)=atanh[(-1/2-epsilon b1 tanh((n-1)c))/((1-epsilon)C)].

For sufficiently small epsilon these are well-defined analytic functions, equal to r and -r at zero. Set

    w(epsilon)=(R_+-R_-)/2,
    beta(epsilon)=R_+-n w(epsilon).

The resulting two-atom mixture has exactly the original margins on all n+1 active inputs. Every other negative cube input had a strictly larger margin at epsilon=0, so all remain strictly valid for sufficiently small epsilon by continuity and finiteness of the cube.

Let J(epsilon) be its energy. The scalar atom's parameter stationarity has output multipliers lambda*rho_i: this follows directly from the affine KKT identity and the common sech²r derivative at its active scores. Differentiating the active output identities gives

    J'(0)=n||u1||²+b1²-lambda b1 S_n-zeta
          =Jbad-zeta<0.

Equivalently this identity follows by direct differentiation of R_+,R_-. Hence the mixture has strictly lower energy than the best scalar clone for every sufficiently small positive epsilon.

For each sufficiently large n, take epsilon=1/N. One new atom and N-1 copies of the adjusted main atom realize this mixture exactly at every sufficiently large finite width N, with the canonical mean-field normalization. This proves strict scalar nonoptimality at all such widths. Weak versus strict global margin infima are identical by a small common readout amplification, so the conclusion applies to the strict-margin Bayesian setting as an energy comparison.


## Verification status

The asymptotic expansion and the explicit feasible descent were independently checked by a separate AI agent. This is a mathematical research record, not a formalization in Lean. The conclusion compares network energies; it supplies neither an online mistake count nor a posterior-ordering theorem.
