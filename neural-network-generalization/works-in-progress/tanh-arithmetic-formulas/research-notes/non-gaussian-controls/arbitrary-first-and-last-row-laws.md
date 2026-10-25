# Arbitrary first and last row laws around a compiled middle

25 October 2026. Scratch structural extension. The first-row construction
was developed by the occupation-audit agent; the unrestricted final-row
truncation argument was supplied by the root agent. This does not compile
arbitrary internal row laws.

## 1. Setting and conclusion

The prescribed initial vectors are

    h0(x)=(1,x)/sqrt(d),    x in {-1,1}^d,    d>=1.

The first row law rho1 is arbitrary, with entropy D1 relative to the
standard Gaussian on R^(d+1). Apply tanh and write

    h1(x)(g)=tanh(g.h0(x)),    g~rho1.

Suppose all subsequent internal layers belong to a class already handled
by the scalar-formula compiler: Gaussian controls, independent finite-rank
tilts, or the stated normalized-ridge-difference mixtures, with their
respective proved budgets. The first layer can be admitted at initialization
cost

    poly(d+D1+2) exp(C D1),                              (1)

including exact scalar coordinate formulas, a separately maintained
squared-norm oracle, and normalization by one common variance envelope.

At the other end, suppose a final tanh row law rhoH is arbitrary with
Gaussian entropy DH, and a readout v of norm V gives global signed margin
eta>0. That final tilt can be replaced by the reference Gaussian law,
retaining at least margin eta/2, with readout norm at most

    V exp[12(sqrt(DH)V/eta+DH V^2/eta^2)].                (2)

Thus arbitrary first and last row laws may surround a compiled middle.
At bounded total action and fixed margin, both additions have only
polynomial resource cost in the existing compiler parameters. For the
first layer, d is the ordinary input dimension, not a later exponentially
large feature dimension.

If there is just one hidden layer, the direct first-layer initialization
already handles it; the two endpoint constructions need not both be
applied to that same layer.

## 2. The first Gaussian entropy gives only the moments actually needed

Let n=d+1. Gaussian entropy duality at parameter 1/4 gives

    E_rho1 ||g||^2 <=4D1+2n log 2.                       (3)

No fourth moment is assumed. This distinction matters for the norm oracle.

For each cube input, the projection g.h0(x) has reference variance
q0=(d+1)/d in [1,2], and its relative entropy is at most D1. There are
universal c,C>0 such that

    r(x):=E_rho1 tanh^2(g.h0(x)) >= c exp(-C D1)=:delta.  (4)

Here is an elementary proof. If r is small, Markov gives rho-probability
at least 3/4 to |tanh Z|<=2sqrt(r). Under N(0,q0), this event has
probability at most Csqrt(r), uniformly for q0 in [1,2]. The binary
entropy inequality gives

    D1 >= (3/4)log[1/(Csqrt(r))]-log 2.

Rearrange; the case of r above a fixed small constant is automatic.
The estimate is simultaneous over all inputs because its constants do
not depend on the input.

## 3. Direct scalar factories in the original finite dimension

For each fixed g, compute the deterministic linear form g.h0(x) using
d+1 leaves and arithmetic operations. Its squared magnitude is at most
2||g||^2 on the whole cube. The Fourier-increment factory for tanh,
balanced separately at each sampled frequency, gives an unbiased scalar
oracle X_g(x) with

    expected work <=C(d+1),
    E|X_g(x)|^2 <=C||g||^2.                              (5)

The common work bound is independent of g. To see this explicitly,
sparsify the conditional Poisson factory by its work factor
1+omega^2 V_g, rescaling on the active branch. Then sample frequencies
proportionally to the square root of its resulting moment bound.
The weighted first Fourier moment yields (5). The zero vector gives the
identically zero oracle and is omitted.

Integrating (5) over the coordinate measure rho1 gives total trace second
moment at most C(d+D1+1), by (3). Averaging C(d+D1+1) independent copies
per coordinate therefore gives bounded trace second moment and common
expected scalar size polynomial in d+D1+1. The true feature trace is at
most one, so averaging adds only the usual bounded mean-square term.

For the squared-norm oracle, do NOT square a tanh oracle at the same g:
that would impose an unjustified fourth-moment condition on rho1. Instead
use a direct Fourier-increment factory for

    f(z)=tanh^2 z=1-sech^2 z.

This bounded smooth even function vanishes at zero and has a Fourier
increment representation with finite weighted first moment, obtained
from the exponentially decaying Fourier transform of sech-squared.
Its balanced factory has the same bounds as (5). Sampling g from rho1
and then applying this factory gives an unbiased oracle for r(x), with
second moment O(d+D1+1) and polynomial expected work. Average to a
fixed second-moment bound.

Thus both the vector-coordinate and scalar-norm oracle invariants are
available using only (3).

## 4. Normalize and start the existing middle-layer compiler

Choose the common deterministic envelope

    q*=max_x r(x),    delta<=q*<=1.

Divide each h1 coordinate oracle by sqrt(q*) and the scalar r oracle
by q*. Their means are

    u1(x)(g)=h1(x)(g)/sqrt(q*),    s1(x)=r(x)/q*.

Thus ||u1(x)||<=1 and s1(x)=||u1(x)||². An ordinary averaging
reset makes the integrated coordinate trace and scalar second moments
bounded, at cost polynomial in (q*)^(-1). All costs are bounded by
(1). This is exactly the common-scale interface used by the middle-layer
compiler. No query-dependent reciprocal or inverse-square-root factory
is necessary.

The finite-bit argument has no new parameter-precision premise. Before
the tanh factory, the cube-RMS-normalized linear form has coefficients

    g_i/||g||,

up to the fixed input normalization, hence bounded by one. All other
unbounded factors occur in the already treated Fourier/Poisson,
importance-sampling, and averaging nodes. The independent moment floors
and conditional RMS normalization apply with the trace/work bounds above.
Only finitely many real coefficients appear in a good finite seed and
are rounded after normalization, exactly as in the existing proof.
An efficient sampler or density evaluator for rho1 is not asserted or
needed for this nonuniform existence theorem.

## 5. Delete an arbitrary final tilt by density truncation

This step only uses bounded features and a bounded L2 readout. Let gamma
be the last row reference, let r=d rho/d gamma, and suppose

    KL(rho||gamma)=D,      ||v||_(L2(rho))=V,
    |F_x|<=1,             f(x)E_rho[vF_x]>=eta.

For every M>1, the nonnegative entropy integrand gives

    rho{r>M} <= D/[log M-1+1/M].                         (6)

Define a readout under the reference law by

    v_new(g)=v(g) r(g) 1_{r(g)<=M}.

Then

    ||v_new||_(L2(gamma))^2 <=M V^2,

while Cauchy--Schwarz gives the uniform output error

    |E_rho[vF_x]-E_gamma[v_new F_x]|
       <=V sqrt(rho{r>M}).

At D=0 the measures coincide, so no replacement or margin loss is needed.
For D>0 take

    log M=24[sqrt(D)V/eta+D V^2/eta^2].

Writing u=D V^2/eta^2 and s=log M, the inequalities
s-1+exp(-s)>=s^2/3 for s<=1 and >=s/4 for s>=1 show that the
denominator in (6) is at least 4u. This makes the error at most eta/2
and proves (2). A further factor two in
the readout restores the original margin if desired. Feasibility itself
implies V>=eta, so the displayed threshold is nondegenerate.

The complete version is recorded in arbitrary-entropy-endpoint-deletion.md.
This argument does not require endpoint optimality or bounded dual
coefficients. It supersedes the more specialized bounded-dual deletion
argument when only preservation of the classifier is needed. It does
not preserve the original variational action: the readout norm can grow
by the displayed factor.

## 6. Scope

Near-baseline occupation may be applied to the original full path, so its
entropy budgets remain available for the middle layers. The endpoint
operations above are used to build an alternative formula representation,
not to claim that the altered path is still near the original baseline.

The unresolved case remains an arbitrary entropy tilt at an internal
layer followed by further nonlinear controlled layers. The first-layer
argument relies on dimension d+1; the last-layer argument moves density
into a readout. Neither operation can simply be repeated at every
internal layer.
