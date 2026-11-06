# Independent audit of `gelu-mixed-exact.md`

I checked every theorem/proof step independently. No mathematical error found, subject to the scope explicitly written in the note: no appended constant input and only the first hidden layer nonlinear.

## Exact energy and equality cases

* With b=v W^{L-1}...W^2, the odd projection is A=(c/2)bW1 exactly, including softplus with phi(0)>0.
* Paired opposite-label margin constraints imply y A.x>=a. The weighted Frobenius/AM-GM chain is correct and has product coefficient p, independent of N.
* The paired-row construction e1=(1,-1)/sqrt2 gives e1^T phi(s1 e1 u.x)=(c s1/2)u.x. Therefore the proposed balanced factors attain exactly A_*.x, with every energy summand r^2, at every N>=2, including L=2.
* At an energy minimizer all inequalities in the lower-bound chain are equalities. In particular A=A_* and equality in ||bW1||<=||b||||W1||_F gives W1=lambda b^T u^T for lambda>0. This equality characterization is valid because A_* and b are nonzero.
* Under condition (S), each nonzero b_i phi(lambda b_i s) has the sign of s. Under (M), each such summand is nondecreasing even when b_i<0. A finite nonempty margin-feasible history has at least one active constraint at its minimum-norm solution: otherwise scaling A_* down would reduce norm. The paired labels then give F(delta)>=a and F(-delta)<=-a, where delta=a/||A_*||. The global linear margin puts every cube projection outside (-delta,delta), proving the sign conclusion for softplus and ReLU as well. No unjustified assertion that F is odd is needed.
* Closed weak-margin sign cells and coercivity produce a strict energy gap to every other sign cell. The explicit attained linear function can be readout-scaled to strict margins, supplying the open denominator region for Gaussian concentration. This handles posterior mixtures, not merely MAP selection.

## Sequence and teacher

* Homogenization F(s,x,y,z)=s f(sx,sy,sz) agrees exactly with the displayed linear threshold. Appending the antipode after each old point makes the history paired without changing its linear constraint set. Distinct old points give distinct lifted/antipodal pairs because their s coordinates differ. Any existing duplicate calibration constraints can simply be removed before forming a permutation, as in the old paper.
* Only the first member of each future query pair is counted. Once that query and its antipode are labeled, the next history again satisfies the theorem's paired-history hypothesis. This is a fixed input sequence, not a posterior-adaptive construction. Arbitrarily ordering remaining unused cube points completes it to a permutation.
* At L=k+2 there are k+1 hidden layers: one nonlinear layer, one first linear layer, and k-1 remaining linear layers. Thus the teacher depth count and 2^k amplification are correct. The first-layer coefficients A_M/2^k are all bounded by one; the paired readout first row has entries 2/c and -2/c, bounded by two for all listed activations. The final output is exactly A_M and has margin >=1.
* For complexity one, the normalized odd projection coefficients are at most c<=2, while the existing carry inequalities require the top antisymmetric coefficient at least 2^(k-1)>2 for k>=3. Hence C_L=2. Zero-padding the teacher to every N>=2 preserves its function because only the first layer is nonlinear and its extra outputs have zero downstream columns, including softplus.

## Presentation cautions

The main theorem must say explicitly that the Boolean coordinate s is variable, not an appended constant/bias. It must also say explicitly that all hidden layers after the first are linear. It is a useful exact nonlinear-activation result but does not settle the ordinary fully nonlinear biased tanh/ReLU/GELU model. The exponent-scale threshold in the posterior theorem can depend on N; there is no interchange with an N->infinity limit.
