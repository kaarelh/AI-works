# Tiny feature components can remain essential on canonical nearbaseline paths

26 October 2026. This is an obstruction to discarding small feature components from a nearbaseline path. It is not a lower bound for learning, not a globally optimal path claim, and not a counterexample to a compiler that keeps the component.

## 1. Statement in the original critical variational model

Use the original augmented Boolean input with d=1, the two inputs x=+1 and x=−1, exact tanh, and critical prefactor t=1. Let f(x)=x.

For every fixed A>0 and all sufficiently large M, there is a legitimate full-cube hard-margin row-control path with:

- total hidden depth H=Theta_A(M);
- total action at most V_*+C_A log²(M)/M;
- a middle layer whose maximum feature variance is Theta(log(M)/M);
- an orthogonal dictator component at that layer of squared norm between M^(−B_A) and M^(−A), for a finite constant B_A;
- a continuation that learns the dictator with margin 1/2.

If that one middle-layer component is deleted, the two input feature vectors become exactly equal. No subsequent finite-entropy row controls, at any depth, can then realize opposite output labels.

Thus the component may be arbitrarily polynomially small in depth and still be essential to an admissible canonical nearbaseline continuation.

The construction uses Gaussian row controls up to its final scalar continuation. The final continuation may use the unrestricted scalar nearoptimal laws. All statements are about the critical population row-control/Gram variational model; no finite-width posterior lower bound is inferred.

It suffices to prove the construction for A>=3, since increasing A strengthens the asserted smallness bound.

The imported component facts are the "Cheap holding and prescribed growth" lemma (`lem:critical-cheap-holding`), component equations (`eq:critical-residual-nonincreasing`, `eq:critical-component-growth`), and "Lifting with a small residual" lemma (`lem:critical-scalar-lift`) in `neural-network-generalization/works-in-progress/critical-depth/source/critical-rate-foundations.tex`. The growth proof itself gives the stated arbitrary-start log(p/v_f) bound. The lifting lemma gives overhead at most 12m delta for scalar cost at most3 and 2m delta<=1/2; here m=O(1/p), delta=M^(−R). The short increasing scalar path is the theorem in `critical-scalar-paths.tex` in the same source directory. The inverse-depth action lower bound is stated in `critical-main-theorem.tex` and proved in `critical-rate-lower-proof.tex` there. The derivative-Poincare purification estimate is also written explicitly below.

## 2. Free cooling from the actual augmented input

At d=1 the two augmented inputs (1,+1) and (1,−1) are orthogonal and both have squared norm2. Under free critical Gaussian tanh layers their feature covariance therefore remains

    Q=q I_2,

with q evolving by q_next=F(q), F(q)=E tanh²(sqrt(q)Z). The critical free drift reaches q in [b/2,b] in O(1/b) layers, where

    b=log(M)/M.

This costs zero entropy. Write e=(1,1) and f=(1,−1). Then

    Q=(q/2) e e^T+(q/2) f f^T.

All constants below may depend on the prescribed A, but not M.

## 3. Hold the wrong common direction

Track the common component v=q/2=Theta(b). At each step inflate only its scalar Gaussian variance by a factor 1+eta, with 0<=eta<=Cb, choosing eta so the full conditional-mean common component remains exactly v.

The existing critical holding proof provides this choice and entropy at most Cb² per step. Its residual covariance R has constant diagonal r<=Cb, and conditional Gaussian Poincare gives

    r_next <=r E sech^4(G),
    Var(G)=(1+eta)v+r>=v>=c b.

For small b this yields r_next<=(1−c'b)r. Holding for T=C_A M steps, with C_A sufficiently large, therefore gives r_T<=M^(−A). The dictator component is contained in this residual and has variance

    v_f=(Q(+,+)−Q(+,-))/2<=r_T<=M^(−A).             (1)

The entire holding entropy is O_A(Mb²)=O_A(log²(M)/M).

The component also retains a polynomial lower bound. Every controlled preactivation covariance is Q+eta v e e^T, which dominates Q and has common diagonal O(b). Gaussian first-chaos projection gives

    Q_next >=[E sech²(G)]² (Q+eta v e e^T)
             >=(1−Cb)Q

in positive-semidefinite order. Iterating for O_A(M) steps gives

    lambda_min(Q_T)>=q exp(−C_A Mb)>=M^(−B_A)

for some fixed B_A. Hence v_f is positive and at least another inverse polynomial in M.

Exchange symmetry of the two inputs is preserved, so the exact middle covariance decomposes as

    Q_T=v_f f f^T+v_e e e^T,    v_e=Theta(b).         (2)

No arbitrary query covariance has been substituted for the original input: this middle state is reached by the stated free and Gaussian-controlled layers.

## 4. Recover and amplify the dictator direction

At (2), switch the tracked component from e to f. It has an exact bounded score representation: if h_+,h_- are the two current row features, use

    B=(h_+−h_-)/(2sqrt(v_f)).

Then E B²=1, E[B h_x]=sqrt(v_f)f(x), and |B|<=1/sqrt(v_f), a fixed polynomial in M.

Set the residual barrier Delta=Cb and a target component level p=B0 b, with B0 a sufficiently large fixed constant. The critical prescribed-growth construction starts from v_f>=M^(−B_A), leaves the residual at most Delta, and reaches p in O_A(M) layers, at entropy

    O[p+Delta log(p/v_f)]=O_A(log²(M)/M).

Hold this correct component at p for O_A(log(M)/p)=O_A(M) more layers. The derivative Poincare estimate now reduces the residual to M^(−R), for any prescribed fixed R, while costing O_A(p log(M))=O_A(log²(M)/M).

Append an increasing critical scalar path from p of cost at most V(p)+p, length O(1/p), and square-root entropy O(log(1/p)). Lift it along f with the purified residual. The standard scalar-channel lifting estimate incurs only O(M^(−R)/p) extra readout cost. Taking R sufficiently large makes this negligible.

The final readout has margin1/2 at both inputs. Since V(p)<=V_*, total action is at most

    V_*+C_A log²(M)/M.

If strict margin is desired, inflate the readout by 1+M^(−R), which changes this bound only by a negligible term.

The cooling, holding, growth, purification and scalar continuation use Theta_A(M) layers in total. These are precisely the critical scalar-component constructions, with an intentional interval of holding the wrong direction before recovering f.

## 5. Why deleting the component fails

A Hilbert realization of (2) is

    u_+=sqrt(v_e)a+sqrt(v_f)c,
    u_−=sqrt(v_e)a−sqrt(v_f)c,

for orthogonal unit vectors a,c. Projection onto the a direction changes each input by norm sqrt(v_f)<=M^(−A/2), but makes their projected states equal.

For equal feature vectors, the next reference Gaussian preactivations are equal almost surely. Any finite-relative-entropy control preserves this support constraint. Applying tanh preserves equality, and the argument repeats at every later layer. A common linear readout cannot give opposite labels. Thus deletion makes the dictator impossible, even though the deleted squared norm can be smaller than any prescribed inverse polynomial.

At the unmodified midpoint the full path is nearbaseline, the row entropies are small, and the total quadratic-variance/entropy occupation has the previously proved bounds. Those facts alone therefore do not justify a dimension-free rule that discards every sufficiently small orthogonal feature innovation. Selective subsequent amplification is a real possibility in the original critical model.

The construction is deliberately wasteful and is NOT shown to minimize the total target action. A theorem exploiting global optimality could still rule out this behavior. Likewise, a formula compiler may retain the small component at polynomial precision; this example only invalidates the unqualified deletion shortcut.

Quantitatively, the established inverse-depth lower bound J_(H+1)(f)>=V_*−C/H shows that this construction is nevertheless within O_A(log²(H)/H) of the actual optimum at its depth. Thus a proof using only that nearoptimality tolerance cannot exclude it; exact global stationarity or additional structural information would have to do further work.

