# Diagonal-defect dynamics and quadratic occupation for centered Gaussian paths

26 October 2026. New scratch derivation. Exact real-constant scalar
formulas; no posterior theorem or non-Gaussian extension is asserted.
The scalar Fourier factory and coefficient estimates are imported from
`variable-diagonal-gaussian-scalar-formulas.md`. This note removes its
linear free-variance occupation charge by changing the scalar state.

## 1. A strict diagonal-ratio telescope

Let F(q)=E tanh²(sqrt(q)Z) and g(q)=F(q)/q, with g(0)=1.
On every fixed compact interval [0,Q],

    0<c_Q <= -g'(q)/g(q) <= C_Q.                         (1)

Here and below constants may depend on Q; we will only use fixed Q.
To prove strict negativity, let f(y)=tanh²(sqrt(y)). Its derivative is
f'(y)=tanh(x) sech²(x)/x for x=sqrt(y). The sign of f'' is negative
because

    tanh x-x+3x tanh²x >0   (x>0),

whose derivative is 2tanh²x+6x tanh x sech²x>0. Thus f is strictly
concave, as is F(q)=E f(qZ²), and F(q)/q is strictly decreasing.
All fixed derivatives extend continuously to zero by the bounded
fixed derivatives of tanh(sqrt(y))/sqrt(y) and Gaussian domination.
In particular F(q)=q-2q²+O(q³), so -g'(0)/g(0)=2. Strict negativity
and compactness prove (1).

For 0<s<=1, a free layer normalized by its common upper variance has

    s_next=F(qs)/F(q).

Consequently

    log(s_next/s)=log g(qs)-log g(q)
                >=c_Q q(1-s).                            (2)

If a deterministic lower envelope is s_min=1-Delta>0, update it by the
same map. Its defect Delta never increases. Along a sequence of free
layers with q<=Q,

    sum q Delta <= C_Q log(1/s_min,initial).              (3)

More generally, interspersed controlled stages may lower s_min by
factors l_j in (0,1]. Then the bound becomes

    sum_free q Delta <= C_Q[log(1/s_min,initial)
                                  +sum_j log(1/l_j)].    (4)

This follows by summing log s_min changes; the final log s_min is at
most zero. No additive sum q² error is needed.

## 2. A scalar defect oracle for free layers

Represent the physical feature as

    h(x)=sqrt(qbar[1-Delta e(x)]) u(x),
    ||u(x)||=1,  0<=e(x)<=1,  0<=Delta<1.

The deterministic envelope is qbar, and s_min=1-Delta. If Delta=0,
take e=0 and omit its updates until a control creates a defect.
At a free step with preactivation upper variance q,

    Delta_next=1-F(q(1-Delta))/F(q),
    e_next= [F(q)-F(q(1-Delta e))]
             /[F(q)-F(q(1-Delta))].                     (5)

For q Delta>0, factor out q Delta from the numerator and denominator:

    e_next=e * [integral_0^1 F'(q-q Delta e r)dr]
                  /[integral_0^1 F'(q-q Delta r)dr].

Since F'>0 has a positive minimum on [0,Q], all fixed derivatives of
F are bounded there, and q Delta<=Q, the correction satisfies

    ||e_next-id||_(C^k([0,1])) <= C_(Q,k) q Delta         (6)

for every fixed k. For the first derivative this follows by subtracting
the denominator average from F'(q-q Delta e); higher derivatives have
an explicit factor q Delta. A fixed bounded smooth extension operator
preserves the H³ bound C q Delta.

Apply the ordinary scalar Fourier--Poisson factory to this correction.
For a bounded-second-moment oracle E for e, it returns an unbiased
correction of second moment O((q Delta)²) and expected size C T_e.
Add it to an independent old e oracle only on a branch of probability
p=min(1,c q Delta), dividing by p. For q Delta below a fixed cutoff,
its second moment and size budgets increase by factors 1+O(q Delta).
Larger increments are handled by a bounded averaging reset, charged
O(q Delta) in logarithmic work. Thus exact defect-oracle work is
exp[O(sum q Delta)], rather than exp[O(sum q)]. The analytic factorization
above avoids an unexplained division by an arbitrarily small q Delta.

## 3. Unit-direction Fock coordinates cost only q²

The normalized output direction has coordinates

    b_k(q(1-Delta e(x))) u(x)^(tensor k).

Use unit directions here, not powers of the common-normalized physical
state: the latter would introduce non-summable s^(-k) factors.
The coefficient estimates from the variable-diagonal Gaussian note give,
after a fixed H³ extension from e in [0,1],

    sum_(k>=3 odd) k² ||b_k(q(1-Delta ·))||_(H³)² <= C_Q q²,
    ||b_1(q(1-Delta ·))-1||_(H³)² <= C_Q q⁴.             (7)

For detail, write phi_t(z)=tanh(sqrt(t)z)/sqrt(F(t)), phi_0(z)=z.
Its first three t derivatives have uniformly bounded Gaussian H² norms
for t in [0,Q]. Indeed psi(y)=tanh(sqrt(y))/sqrt(y) has bounded fixed
order derivatives, phi_t(z)=z psi(t z²)/sqrt(F(t)/t), and fixed mixed
z,t derivatives are dominated by fixed Gaussian-integrable polynomials.
The normalization F(t)/t is smooth and bounded below. Gaussian Sobolev
Parseval therefore controls sum k² |partial_t^ell b_k(t)|², ell<=3.
The exact Hermite estimate gives the sharper tail O(t²), while
b_1(t)-1=O(t²), b_1'(t)=O(t), and higher fixed derivatives are bounded.
Each e derivative brings q Delta; these facts give (7) for small q.
For q bounded away from zero the uniformly bounded coefficient norms
are absorbed by q² and q⁴. Constants are uniform in 0<=Delta<1; the
true physical variance may approach zero.

Construct coefficient oracles using the ordinary scalar factory with
fixed frequency density. Their common expected cost is C T_e, and the
weighted sum of tail moments is O(q²). Average ceil(kV) independent u
children for each tensor leg, where V bounds the trace moment. Create
each new degree-k coordinate with probability

    p_k=1/(C_* k² V).

Its zero branch has size one; its nonzero branch costs
C(k² V T_u+T_e). Maintain a deterministic common resource envelope T_base with
coordinate size bound T_base and scalar size bound C_0 T_base;
write T_u=T_base and T_e=C_0 T_base for those upper bounds. Taking C_*
sufficiently large makes tail-coordinate expected size at most T_u,
while its total trace contribution is O(q²).

At degree one copy u_i and add an independent product correction using
b_1(q(1-Delta e))-1 on a probability-cq² branch for small q. Its
coefficient second moment is O(q⁴); the trace increment and common
size multiplier are 1+O(q²). Larger bounded q is a constant-size reset,
charged O(q²). Ordinary averaging resets keep the u trace and e scalar
moments bounded. A free variable-diagonal layer therefore has total
logarithmic scalar-formula work charge

    C_Q(q²+q Delta).                                    (8)

All products use independent fresh children; the scalar Fourier
factory's internally repeated real-product terms are full-cost
syntactic copies, as in its existing audit.

## 4. Small centered controls do not divide the work budget by Delta

Let A=J+K, J a signed coordinate isometric injection, and
0<kappa=||K||HS<=kappa0. Put

    alpha=1+kappa, sigma=1-kappa,
    eta=1-sigma²/alpha²,
    Delta'=Delta+(1-Delta)eta.

The common physical upper variance is multiplied by alpha², while
s_min is multiplied by sigma²/alpha². A scalar common factor t does not
change this ratio and is kept separate. Let

    g_A(u)=(alpha²-||Au||²)/(alpha²-sigma²) in [0,1].

Writing B=A* A-I, ||B||HS<=2kappa+kappa² shows that g_A has an unbiased
quadratic coordinate oracle with bounded second moment and expected
size C T_u. Indeed its nonconstant matrix coefficient is B/(4kappa),
which has uniformly bounded Hilbert--Schmidt norm. Sample entries in
proportion to their squared coefficients and use independent u children.
No full identity matrix is sampled.

The exact new normalized defect is

    e'=[Delta e+eta(1-Delta e)g_A]/Delta'.

Write

    a=Delta/Delta',  c=eta Delta/Delta'<=eta=O(kappa).

The following identity is the useful cancellation:

    e'=a e+(1-a)g_A+c g_A(1-e).                          (9)

The first two terms are a convex mixture: choose either the old e
oracle or a fresh g_A oracle, with probabilities a and 1-a. Its second
moment is no greater than the larger input bound, and its expected size
is no greater than max(T_e,C T_u). Choose C_0 once so cost(g_A)<=C_0 T_base. The maintained scalar
upper envelope is T_e=C_0 T_base, whether or not the actual scalar
cost is smaller. Thus max(T_e,cost(g_A))<=C_0 T_base and the mixture
has no per-control constant work increase. Add the final correction only
on a probability-kappa branch. Its second moment before branching is
O(kappa²), and its expected nonzero-branch work is O(T_e+T_u).
Thus its charged moment/work increment is O(kappa), even when Delta'
is itself of order kappa or Delta=0. If Delta=0, (9) simply gives e'=g_A.
Zero controls are omitted.

The normalized direction update u'=Au/||Au|| is exactly the existing
small-control factory in variable-diagonal-gaussian-scalar-formulas.md:
copy J, sample K, and use the bounded quadratic oracle for ||Au||²-1
inside an O(kappa)-size inverse-square-root correction. Its charge is
O(kappa), independently of the scalar defect.

For large kappa, take rho=min(1,sigma_min(A)) and alpha=1+kappa. The
same deterministic envelope update uses sigma=rho. Its eta is bounded
below by a positive constant, so Delta'>=eta and direct defect arithmetic
has no small denominator. The existing large-control construction and
averaging reset cost a polynomial in 1+kappa and rho^(-1), whose
logarithm is O(kappa+log(1/rho)). The direction update has the same cost.

## 5. Resulting centered-Gaussian representation bound

The previous sections combine into the following exact real-formula
claim. Start from unit-direction coordinate formulas and a bounded-
moment scalar defect oracle, with s_min,0>0. Let centered controls
A_j=J_j+K_j be bounded below, and include a common scalar prefactor
1<=t<=1+delta0. Put

    S=sum_j ||K_j||HS,
    L=sum_j log_+(1/sigma_min(A_j)).

On steps with bounded preactivation upper variance q_j<=Q, the total
log work is at most

    C[ S+L+log(1/s_min,0)+sum_j q_j² ].                   (10)

Equation (4) absorbs sum q_j Delta_j, because each controlled loss is
at most 2log(alpha/rho), whose sum is O(S+L). Large-variance steps are
necessarily associated with large controls once the initial variance
is bounded: postactivation variances are at most one. Use the existing
polynomial-in-q large-step factory there. Its logarithmic cost is
O(log(1+q))=O(kappa) and is already charged to S; omit those steps from
the quadratic sum in (10).

Finally, for bounded initial upper variance, the deterministic envelope
recursion is qbar_j=F(t²(1+kappa_j)²qbar_(j-1)). At small-control steps,
its drift obeys

    qbar_j-qbar_(j-1)
       <=C delta qbar_(j-1)+C kappa_j-c qbar_(j-1)²
       <=C delta²+C kappa_j-c' qbar_(j-1)².

Large-control steps change the bounded postvariance by at most one,
and their count is O(S). Summing gives a bounded-variance quadratic
occupation at most C(1+delta²H+S). Therefore (10) becomes

    expected coordinate size
       <=C T0 exp{C[1+S+L+log(1/s_min,0)+delta²H]}.        (11)

The same bound holds for a sampled l2 readout up to its squared norm,
and simultaneous finite-input fixed-seed selection gives a majority of
real arithmetic signs with the usual polynomial input-set factor.
No finite-bit claim is made here without separately extending the
moment-floor argument to the convex-mixture defect update.

This is a centered Gaussian controlled-path representation theorem.
The controls are not the full margin-conditioned posterior. It does
not yield the original all-target canonical learning theorem or an
actual posterior positive window with delta²H. Nonzero mean controls
and arbitrary non-Gaussian tilts are outside this note.
