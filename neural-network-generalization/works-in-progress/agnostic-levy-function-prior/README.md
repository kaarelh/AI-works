# Formula complexity and neural-network prior probabilities

[Paper](paper.pdf) · [LaTeX source](source/paper.tex) · [Verification record](verification/README.md)

This paper proves an actual function-prior relation in both directions for a fixed dense network with independent, continuous Lévy weight coordinates. A small bounded-coefficient formula has a uniform function neighborhood with controlled negative log prior probability. Conversely, a neighborhood with appreciable prior probability contains a function approximable by a small rational-weight formula. Both bounds are independent of the learner's width.

At hidden depth `H`, a prior draw has, with probability `1−delta`, a uniform `tau` approximation of formula size `[C L log(eL)]^(H+2)` and coefficient bit length `C L³`, where `L = H+1+log(1/(delta tau))`. Input-coordinate addresses are included separately in the finite description bound. Thus approximate formula complexity is polynomial in negative log neighborhood probability at each fixed depth.

For ReLU on Boolean inputs, the paper also treats the exact sign-function prior conditioned on an all-input output margin. Appreciable conditional function probability implies a small Boolean circuit, with polynomial dependence on negative log probability at fixed depth and margin. This converse needs a positive margin but does not need an upper bound on raw outputs.

The first prior uses one fixed infinitely divisible coordinate family at time `1/fan-in`, independently in every coordinate. The same conclusions also hold for an explicit signed beta-prime density with first shape parameter proportional to `1/fan-in`; the paper proves this without a Poisson representation. There is no prior over network sizes or architectures. Its central concentration and rare large jumps make it a continuous shrinkage prior; it is not a Gaussian prior. Formula size can be much larger than circuit size when computations are shared, and the bounds retain that distinction.

At fixed depth, the wide Lévy prior converges to a random-formula law. A finite-width motif bound shows that retaining a prescribed shared computation costs `(E−V) log N`; this explains the direct embedding penalty, without claiming a function-level learning lower bound when alternative formulas may exist.

The proofs have undergone independent AI-agent mathematical review. They are not Lean formalized. Run `./build.sh` to rebuild the PDF. Authors are listed alphabetically.
