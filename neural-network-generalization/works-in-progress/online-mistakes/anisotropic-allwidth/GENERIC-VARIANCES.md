# Generic fixed-amplitude anisotropy at every width

This companion to the [all-width tanh paper](paper.pdf) shows that generic small coordinate asymmetries of a fixed size across dimensions suffice. It uses an exponential calibration prefix, followed by an even longer sequence of forced mistakes. The exactly isotropic case remains open.

**Authors:** ChatGPT-6 Astra, Kaarel Hänni, and Dmitry Vaintrob.[^order]

## Statement

Let q>=3 be odd and d=9q. Fix coordinate precision coefficients lambda_1,...,lambda_d in [a,b], where 0<a<=b<2a. Let lambda_0>0 be any bias-coordinate precision. Assume the sums over the transversal supports defined below are pairwise distinct; it suffices that all distinct q-subsets of [d] have different coefficient sums.

Use the usual shallow tanh model with Gaussian variances N sigma^2/(d lambda_i) in the first layer, sigma^2/N at the readout, full-cube absolute output margin >1/2, and exact label conditioning. The target is full majority f(x)=sign(sum_i x_i).

The Gaussian energy and scalar profile are

```text
kappa_{N,lambda}=(d/N) sum_{i=0}^d lambda_i ||W_{:,i}||_2^2 + N||v||_2^2,
Phi_d(Q)=min_{u>0} [d Q u^2+(1/4)coth^2(u)].
```

Let E_N(g) be the infimum of this energy among networks implementing g with global signed margin at least 1/2. Weak and strict margin infima agree by readout scaling. The weighted essential-coordinate theorem proves E_N(g)>=Phi_d(sum_{i essential to g}lambda_i), with equality for positive majority on every odd-cardinality support. Phi_d is strictly increasing. These statements hold for every finite N.

There is one fixed distinct-input order, determined by the coefficients but independent of learner width and prior scale, with 2^q calibration points followed by exactly

```text
T=9^((q+1)/2)
```

designated rounds on which the actual posterior's wrong-label probability tends to one as sigma->0, at every N>=1. Thus all T sampled mistakes occur with arbitrarily high probability at sufficiently small positive scale; majority and >2/3-confidence conclusions follow too. The target has C_2=1 and Boolean circuit size Theta(d).

## Proof

Sort the d input coordinates by nondecreasing lambda and partition them into q consecutive blocks B_1,...,B_q, each of size nine. Write

```text
l_j=min_{i in B_j}lambda_i,    u_j=max_{i in B_j}lambda_i,
L=sum_j l_j,                 U=sum_j u_j.
```

The intervals [l_j,u_j] are ordered and disjoint except possibly for shared endpoints. Hence

```text
U-L=sum_j(u_j-l_j)<=b-a<a.                    (1)
```

First reveal every block-constant input: for every z in {-1,1}^q, set all coordinates in B_j equal to z_j. Its target label is sign(sum_j z_j), since each block has the same size nine. These are exactly 2^q distinct inputs.

Every consistent Boolean function has at least one essential coordinate in every block. To see this, fix a block j and balance the other q-1 block signs equally between + and -. Flipping block j then flips the calibration label. A function independent of all coordinates in that block could not fit both examples.

If a consistent function has exactly q essential coordinates, it has one in each block. The block-constant examples realize every assignment to these selected coordinates. Therefore their labels force the entire function to be positive majority on the chosen transversal support S. Conversely, every transversal majority fits the calibration. There are 9^q such functions.

The weighted essential-coordinate theorem gives, for every width,

```text
E_N(h_S)=Phi_d(sum_{i in S}lambda_i) <=Phi_d(U).
```

Every other consistent Boolean function still has an essential coordinate in every block, plus at least one additional essential coordinate. Its total essential precision is at least L+a: pick one essential coordinate per block, each costing at least l_j, and the extra coordinate costs at least a. Thus

```text
E_N(g)>=Phi_d(L+a)>Phi_d(U),                  (2)
```

where strictness follows from (1) and strict monotonicity of Phi_d. This compares every nonlinear competitor, not only subnetworks. Candidate energy ordering is exactly their subset-sum ordering, which is distinct by hypothesis and independent of N.

Put m=(q+1)/2 and fix the first m blocks. While candidates remain, choose the cheapest surviving transversal S and query the point positive exactly at S's selected coordinate in each of these m blocks, negative everywhere else. It has m positive coordinates out of d and hence negative target label, whereas the selected q-majority has score 2m-q=1 and predicts positive.

Any other transversal T predicts positive precisely when it agrees with S in all m queried blocks. Thus the query removes exactly one complete projection fiber, of size 9^(q-m). Fibers are removed one at a time and there are 9^m of them, proving the exact count. No query repeats. None is block-constant because each queried block has one positive coordinate and eight negative coordinates, so all lie outside the calibration prefix. Complete the sequence arbitrarily to a permutation of the cube.

At each designated round the cheapest consistent function is unique, with a positive width-independent gap to all other candidates and the outsider gap in (2). Standard finite-dimensional Gaussian energy concentration therefore sends its posterior probability to one for each fixed N. A common sufficiently small scale and a finite-round union bound prove the sampled, majority, and confidence conclusions. The same product-neighborhood/chi-squared argument in the [all-width paper](paper.pdf) gives one sufficiently small mean-field scale t=sqrt(N)sigma uniformly over all N.

## Genericity and fixed amplitude

For independent non-atomic random coefficients supported in [a,b], distinct finite subset sums occur almost surely. For a proposed equality between different subsets, condition on all coefficients except one appearing with a nonzero coefficient; the equality requires that remaining non-atomic variable to equal one fixed value, an event of probability zero. There are finitely many such equalities in each finite dimension. For one infinite independent sequence, a countable union shows that all required finite subset sums are distinct simultaneously for every odd q.

In particular, iid continuous coefficients in [1,1+eta] with any fixed 0<eta<1 satisfy the theorem almost surely, with no dimension-dependent shrinking of eta. The input order may depend on the realized known coefficients. It never depends on N, sigma, or posterior samples. Exactly equal coefficients remain excluded.

An explicit fixed profile also works: let `lambda_i=1+delta/p_i`, where `p_i` is the ith prime and `0<delta<1` is fixed and rational. Distinct subset sums of reciprocal primes follow by multiplying a proposed equality by the product of the participating primes and reducing modulo a prime occurring on only one side. All coefficients lie in `[1,1+delta/2]`. The standard bound on the ith prime gives polynomial-size denominators, and hence `O(log d)` bits per coefficient for fixed `delta`. This does not give a polynomial lower bound on the separation between subset sums, or a prior-scale threshold uniform in dimension.

The calibration size 2^q is exponential, but smaller than the forced-mistake count 9^((q+1)/2). This construction should not be presented as having polynomial calibration; the paper’s explicit small-amplitude construction supplies that separate guarantee.

## IID and scaling corollaries

The same direct IID proof applies with a bounded-factor change in its energy cutoff. The cloned full-majority witness with first coefficient d^(-1/2) has energy

```text
sum_i lambda_i+coth^2(d^(-1/2)) < (b+4)d.
```

Take K=(b+4)d+1 in the threshold-voter compression argument. It gives the same O(d^4) IID sample bound up to a constant depending on b, independent of width. A product-ball denominator and chi-squared numerator make a sufficiently small mean-field scale work uniformly over width and history. Hence the published gamma>1 and small-prefactor gamma>=1 conclusions carry over verbatim, with constants depending on the fixed coefficients and [a,b].

## Verification status

The support characterization, sorted-interval inequality, energy gap, exact fiber count, genericity argument, and scaling/IID transfer were independently checked. This is a conventional proof, not a Lean formalization.

[^order]: Authors are listed in alphabetical order.
