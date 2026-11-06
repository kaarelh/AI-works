# A fractional minimum Gaussian energy for a Boolean threshold function

This is an exact finite-dimensional counterexample to the possible assertion that every Boolean threshold function has an integral minimum squared Euclidean norm at unit margin. It is not an online-learning lower bound.

Let x∈{−1,+1}^9 and define

A(x)=11/2+7x1+9x2+13x3+15x4+13x5+16x6+12x7+7x8+(11/2)x9,

g(x)=sign A(x).

**Claim.** Among all affine forms B(x)=b+∑a_j x_j satisfying g(x)B(x)≥1 at every Boolean input, A is the unique minimizer of b²+∑a_j². The minimum is 2405/2, which is not an integer.

**Feasibility.** If x9=+1, A is an odd integer, hence its absolute value is at least1. If x9=−1, A is the signed sum of the eight integers (7,9,13,15,13,16,12,7), whose total is92. Zero would require a subset sum46. Split the list into its first and last four entries. Their possible subset sums are respectively

{0,7,9,13,15,16,20,22,24,28,29,31,35,37,44}

and

{0,7,12,13,16,19,20,23,25,28,29,32,35,36,41,48}.

No member of the first set plus a member of the second is46. Thus A is a nonzero even integer on the second slice, with absolute value at least2.

**Optimality certificate.** Let w=(11/2,7,9,13,15,13,16,12,7,11/2). The [companion JSON](fractional-ltf-certificate.json) lists nine Boolean inputs x_i, their labels y_i, and positive rational multipliers λ_i such that

1. y_i A(x_i)=1;
2. ∑ λ_i y_i (1,x_i)=w;
3. ∑ λ_i=||w||²=2405/2.

For every feasible coefficient vector v, these identities give

〈w,v〉=∑λ_i y_i B(x_i)≥∑λ_i=||w||².

Cauchy–Schwarz gives ||v||≥||w||. Equality forces v=w. This proves the claim.

The certificate and every cube margin are checked by [check_fractional_certificate.py](check_fractional_certificate.py) using Python's exact rational arithmetic, without any numerical solver. The numerical search used to discover the example is not part of the proof.

**Scope.** This shows that counting integer energy levels cannot establish a general polynomial online-mistake bound. It does not establish that there are exponentially many levels, or that any particular sequence visits many of them. The example is unchanged by adding unused input coordinates; therefore its fractional energy can lie below the unit-margin AND energy d²−d+1 in a sufficiently padded dimension. This padding observation alone has no online-learning implication.


## Verification status

The certificate, all full-cube margins, and the optimality argument were independently checked by a separate AI agent. Run `python check_fractional_certificate.py` from this folder to reproduce the exact arithmetic check using only the Python standard library. This certificate is not a Lean formalization.
