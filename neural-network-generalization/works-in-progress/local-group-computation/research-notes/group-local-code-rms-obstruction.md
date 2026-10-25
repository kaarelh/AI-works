# A Wasserstein obstruction for local group-product networks

25 October 2026. Scratch theorem, conventionally independently checked. This strengthens the earlier RMS argument: internal codes may retain arbitrary information about their whole subwords. No exact product code, linear decoder, internal margin, or code-conditioning assumption remains. The only substantive representation restriction is the local physical-band architecture below. This is not an intrinsic lower bound over arbitrary tanh networks.

## 1. Physical architecture and target

Let G be a fixed finite group, let b>=2 and h>=1, and set n=b^h. The leaves of a complete ordered b-ary tree carry independent uniform group letters; each node corresponds to a contiguous block in the word order. Each letter is supplied through a fixed encoding E:G->R^s; six Boolean bits suffice for A5.

At every node v, its boundary code e_v(w) is an arbitrary deterministic vector-valued function of the entire ordered subword w below it. It may retain the whole history, auxiliary values, or fixed-seed random-estimator outputs. Codes need not depend only on the subword product.

Each logical level is implemented by a band of **at least one actual charged matrix layer**. The bands consist of disjoint successive sets of the network's physical layers. Within a band, different parent modules have disjoint data-dependent channels. A parent's first matrix receives only its b child boundary codes; subsequent matrices in that module have no data-dependent input from other modules or outside the band. Shared input-independent constants are allowed and may be treated as biases for the lower estimate. Every matrix needed to carry a module through the band is charged.

Activations are coordinatewise 1-Lipschitz; ordinary tanh is included. A final linear readout z=v dot e_root+c has global signed margin

    f(product(w)) z(w) >=1,

where f:G->{-1,1} is nonconstant. Let p=P_uniform{f=-1}, so 0<p<1. The real output magnitude may depend on the entire word; only its required sign depends on the product.

The theorem measures the product P_F of the Frobenius norms of all actual weight matrices, including the readout and all constant-channel costs. A lower estimate may omit input-independent weights. Virtual factorizations, free concatenations, and uncharged input-dependent bypasses are not physical bands under these assumptions.

## 2. A conditional Wasserstein signal

For each node v and group element g, let mu_(v,g) be the distribution of its code e_v(w) under uniform subwords conditioned on product(w)=g. All these distributions have finite support. Define

    a_v^2 = (1/(2|G|^2)) sum_(g,h in G) W2(mu_(v,g),mu_(v,h))^2.       (1)

Optimal W2 couplings exist here. This number measures how far apart the code distributions for different group products are. Arbitrary within-class history is allowed and is coupled away optimally.

At a leaf, mu_(v,g) is the point mass at E(g). Thus

    a_v^2 = Var_uniform E(g).

For a Boolean s-bit encoding, a_v^2<=s. Let A_0 be the geometric mean of the leaf signals; for a common six-bit A5 encoding, A_0<=sqrt(6).

## 3. Exact one-child contraction

First consider a binary parent with code map F(e_l(w_l),e_r(w_r)). Suppose its Lipschitz constant when only the left input code varies is at most L_l.

Conditional on the parent product being a, the full right subword remains unconditionally uniform. Indeed the independent left product is uniform on G, so every right word has the same factor 1/|G| in the conditioning probability. If the right word has product h, the conditional left product must be a h^(-1).

To couple the parent code laws for products a and b, draw the same uniform right word on both sides and use an optimal coupling of

    mu_(l,a h^(-1)) and mu_(l,b h^(-1))

for the left codes. Push this coupling through F with that shared right code. It gives

    W2(mu_(parent,a),mu_(parent,b))^2
       <= L_l^2 E_(right words)
             W2(mu_(l,a h^(-1)),mu_(l,b h^(-1)))^2.

Averaging uniformly over a,b turns (a h^(-1),b h^(-1)) into a uniform pair for every fixed h. Therefore

    a_parent <= L_l a_l.                                      (2)

The same proof gives a_parent<=L_r a_r. No product-code or decoder hypothesis has been used.

For b children, condition on all the other full subwords and vary one child. If the products before and after it are L and R, its required product is L^(-1) a R^(-1). The other full subwords again remain jointly uniform under the parent-product conditioning. The same bijective change of variables proves (2) for each child.

## 4. Charging each physical band

For parent module p, partition its first variable-input matrix into W_(p,i), one block for each child code. Let T_p be the product of the Frobenius norms of its remaining variable-channel matrices. Its one-child Lipschitz constant is at most T_p ||W_(p,i)||_F. Hence (2) gives

    T_p ||W_(p,i)||_F >= a_p/a_i.

If P_p is the product of the variable-channel Frobenius norms for the entire module, its first matrix satisfies

    P_p^2 >= T_p^2 sum_(i child of p) ||W_(p,i)||_F^2
          >= a_p^2 sum_(i child of p) a_i^(-2).               (3)

The root signal is positive by the margin calculation below, so (2) propagates positivity to every descendant. Divisions in (3) are therefore legitimate.

For each physical layer t in this band, channel disjointness gives

    ||W_t||_F^2 >= sum_p ||W_(p,t)||_F^2.

Expanding products of nonnegative sums yields

    product_t ||W_t||_F^2
       >= product_t sum_p ||W_(p,t)||_F^2
       >= sum_p product_t ||W_(p,t)||_F^2
        = sum_p P_p^2.                                     (4)

Let logical level j contain n_j=b^(h-j) parent nodes, and let A_j be the geometric mean of their signals a_p. Combining (3)--(4) and applying AM--GM over the b n_j child edges gives

    band_product_j >= sqrt(b n_j) A_j/A_(j-1).              (5)

Every parent signal occurs b times and every child signal once, so the geometric-mean ratio is exact. Module depth does not enter the lower bound; it can be arbitrary within the stipulated physical band.

## 5. The final margin and the product lower bound

If f(g) and f(h) are opposite, every root code in the support of mu_(root,g) and every root code in the support of mu_(root,h) have readout values separated by at least two. Consequently every coupling has squared displacement at least 4/||v||_2^2, giving

    W2(mu_(root,g),mu_(root,h))^2 >=4/||v||_2^2.

The ordered fraction of opposite-label pairs is 2p(1-p). The factor 1/2 in (1) therefore gives

    a_root^2 >=4p(1-p)/||v||_2^2,
    ||v||_2 >=2sqrt(p(1-p))/a_root.                          (6)

Multiplying (5) over all logical levels and then (6) telescopes all internal signals:

    P_F >= [2sqrt(p(1-p))/A_0] product_(j=1)^h sqrt(b n_j)
        = [2sqrt(p(1-p))/A_0] b^(h(h+1)/4)
        = [2sqrt(p(1-p))/A_0]
          exp[(log n)^2/(4log b)+(log n)/4].                (7)

The readout may instead be included inside the last root band. Then its scalar output code itself has Wasserstein signal at least 2sqrt(p(1-p)), and the same calculation applies.

For the A5 character predicate that is negative exactly on 3-cycles, p=1/3. With six-bit leaf encodings,

    P_F >= [2/(3sqrt(3))] b^(h(h+1)/4).                    (8)

Thus fixed arity gives exp(Omega(log^2 n)) product, while logarithmic block arity still gives exp(Omega(log^2 n/log log n)), matching the order of the existing blocked local upper construction. For b=n and h=1, there is only one global band; the theorem then gives only the elementary Omega(sqrt(n)) bound and does permit an arbitrary network for the predicate inside that band.

## 6. Unbalanced hierarchies and partition entropy

Balanced arity is unnecessary. Consider any successive hierarchy of partitions of the n letters into contiguous subwords. Each physical band merges at most b child blocks into each parent block; unary carry modules are allowed and remain physically charged. The code of each block may again be an arbitrary function of all letters in that block. Start with the n singleton blocks and end with the whole word.

Give each node v mass mu_v equal to its number of descendant letters divided by n. At each cut the node masses sum to one, and each parent mass is the sum of its child masses. The band estimate (3)--(4) remains

    band_product^2 >= sum_(child edges v->p) (a_p/a_v)^2.

Weighted AM--GM, using weights mu_v on the child edges, yields

    log band_product
      >= sum_(v->p) mu_v(log a_p-log a_v)
          +(1/2) H(mu_child_cut),

where H(mu)=-sum_v mu_v log mu_v. The first term telescopes over successive cuts because the child masses sum to their parent mass. Including the root readout gives the general bound

    P_F >= [2sqrt(p(1-p))/A_0]
             exp[(1/2) sum_(physical bands j) H(mu_pre-band,j)],       (9)

where A_0 is the geometric mean of the n leaf signals. Thus the obstruction is the accumulated partition entropy across actual charged bands.

Merging at most b children decreases entropy by at most log b:

    H(mu_child_cut)-H(mu_parent_cut)
       =sum_p mu_p H(child masses/mu_p) <=log b.

The first cut has entropy log n and the last has entropy zero. Hence, whatever the hierarchy's balance or additional depth,

    sum_j H(mu_pre-band,j)
       >=sum_(j>=0) max(log n-j log b,0)
       >=(log n)^2/(2log b)+(log n)/2.

Substituting into (9) proves the same closed-form lower bound

    P_F >= [2sqrt(p(1-p))/A_0]
             exp[(log n)^2/(4log b)+(log n)/4]             (10)

for arbitrary n>=2 and maximum merge arity 2<=b<=n. Equality in the entropy-area estimate occurs for the balanced b-ary hierarchy when n is a power of b. Additional unary-carry bands add entropy area and cannot improve the lower estimate. As before, free concatenations or virtual cuts are not charged bands.

There is a useful design consequence within this architecture. With fixed leaf encoding and predicate, P_F<=n^K implies

    sum_j H(mu_pre-band,j) <=2K log n+O(1).

For fixed epsilon>0, at most 2K/epsilon+O(1) charged bands can have pre-band entropy greater than epsilon log n. Since the cuts coarsen monotonically, a cut of entropy at most epsilon log n must occur within that many bands, or earlier at the final cut. At such a cut, H(mu)>=log(1/max_v mu_v) implies that some block contains at least n^(1-epsilon) letters. Thus a polynomial-product implementation using this physical hierarchy must create a very large interaction block within a constant number of charged bands. This is a statement about these local partition architectures, not a restriction on arbitrary fully connected networks.

## 7. Why this subsumes the earlier RMS and decoder arguments

If e_v(w)=e_v(product(w)), each conditional code law is a point mass and (1) is exactly the centered RMS variance of the group-state code. The earlier RMS translation proof is therefore the point-mass special case. The Wasserstein coupling is what removes the need to discard or linearly decode retained history.

In particular the theorem covers physical implementations whose boundary codes consist of bounded-moment randomized arithmetic estimators after fixing their random seeds, provided those implementations obey the same channel-disjoint local bands. No RMS decoder-conditioning hypothesis remains. It does not identify an arithmetic estimator with a tanh network, or charge arithmetic operation count as Frobenius product.

Finite ensembles are ordinary deterministic code vectors. A direct-integral random-feature ensemble can be treated similarly only when it is a deterministic Hilbert-valued code and the physical maps are charged Hilbert--Schmidt operators; the coupling proof still concerns finite-support distributions of those code vectors over input subwords. No claim is made about arbitrary stochastic networks with uncontrolled shared randomness.

The superseded RMS/linear-decoder derivations are preserved in `group-local-code-rms-history.md` as research history, not as needed assumptions of (7).

## 8. Scope and audit

The actual locality and charged-band conditions remain essential. Nonlocal interactions between different subwords before their designated merge, a single large global band, or a different global network organization are not ruled out. Every logical band must contain at least one actual matrix layer; free relabeling or concatenation cannot manufacture logical depth for this theorem.

This is not a function-level lower bound. Even G=Z/2Z satisfies the proof, so a balanced local physical realization of parity has this obstruction, although parity itself has a cheap shallow nonlocal tanh representation. The result shows that changing local codes, retaining the full history, adding fixed-seed estimator noise, or using deeper local modules cannot remove the repeated Frobenius penalty while keeping this physical hierarchy.

The same conditional-coupling argument works for finite operations that preserve the uniform law and are bijective in each argument, but no additional application is asserted here.

The conditional-law Wasserstein argument was proposed by the parent research agent and independently checked here, including the full-word conditioning, mixture coupling, root constant, and physical-layer charging. This note is not Lean verified and proves no statistical lower bound or circuit separation.
