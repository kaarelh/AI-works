# A depth-independent circuit converse from distribution-universal online mistakes

25 October 2026. A corollary of the newly proved posterior-to-arithmetic-circuit theorem, not a converse for one fixed input distribution or exact-majority prediction.

Fix a Boolean target f, the original globally margined tanh posterior, one learner depth L and one sufficiently large width N in the fixed-gamma>1 theorem, or the stated fixed-width strong-prior limit. Let Q_t be the exact-fit posterior after t examples. The posterior ceiling applies uniformly to every sample of at most n points, putting all but beta mass on functions of product poly(d+n), with no L in this product bound. Its width threshold may depend on L and the other resources.

Suppose for every iid input law D the expected total number of confidence errors of the online learner is at most M, where a confidence error at the next point means Q_t assigns probability at most 2/3 to its true label. Then f has an ordinary Boolean circuit of size poly(d+M+1), independently of L and N. More precisely it belongs to the quantitative nonuniform PNC1 class supplied by the arithmetic-formula compiler, at size poly(d+M+1). The same conclusion follows from a distribution-universal bound M on expected total Gibbs mistakes, with a simpler reduction. Neither statement claims an efficient circuit construction.

## Confidence errors

Set n=ceil(16(M+1)), and use the posterior ceiling for all sample lengths at most n. For each D, the first n online predictions have

    sum_{t=0}^{n-1} E_{S_t} D{x: Q_t(correct at x)<=2/3} <= M.

Thus there is t<n and one realized sample S_t for which the displayed confidence-failure mass is at most M/n<1/16. Existence is all that the circuit converse needs; t and S_t can depend on D. The energy ceiling is uniform in their length, and its product bound can use n throughout. The two-majority/minimax proof therefore produces an exact PNC1 representation of f of size poly(d+n)=poly(d+M+1).

This does not require extending S_t to n points or claiming monotonic improvement in test error after conditioning. In particular, the t=0 case causes no padding problem. It only uses the common posterior representation class at the resource ceiling n.

A guarantee for every input sequence implies the distribution-universal hypothesis, by averaging over iid sequences. An expected total-mistake bound for one specified distribution does not: the minimax step needs a weak approximator for every D.

## Gibbs mistakes

If each online prediction is an independent posterior draw, the same averaging gives a posterior at some t<n with Gibbs risk at most M/n<1/16. Condition it on the low-product event of probability at least 1-beta, with beta<=1/6. Some low-product voter then has D-error at most (1/16)/(1-beta)<1/8. For every D there is such a voter in the same class. Finite minimax and an O(d)-voter majority make the representation exact. PNC1 is closed under this polynomial majority, by its constant-depth composition theorem.

## Scope

The fixed-width cold limit is taken at the same finite collection of sample lengths as in the existing ceiling; the domain and all such samples are finite. The actual finite-scale statement requires a fixed positive gamma-1 gap and the sufficient width threshold chosen before D. If a mistake guarantee is asserted uniformly over all eligible widths, it can be applied at that width. At gamma=1 the existing weaker TC1 posterior converse gives a related statement with resources poly(d+M+L), subject to its minimum-depth and finite-width conditions; it does not yield the sharper depth-independent PNC1 conclusion here.

A bound on ordinary deterministic-majority errors is insufficient for this proof without a predictive probability gap. A posterior can put probabilities 1/2 plus extremely small input-dependent biases on correct labels, while its individual voters are inaccurate. The confidence and Gibbs conventions above are substantive.

This corollary does not bound the size of f from its expected mistakes under the uniform cube alone, or from its mistakes in one random complete reveal order. It also does not prove an upper bound on mistakes for arbitrary deep targets. It isolates a distribution-universal converse without an internal robustness restriction or exponential teacher-depth factor.
