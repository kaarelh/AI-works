# Fixed-depth extension of the affine-ridge route obstruction

This extends `SHALLOW-RIDGE-OBSTRUCTION.md`. It remains a conditional obstruction to a proof mechanism, not an online bound for unrestricted NNbayes.

## Architecture and canonical energy

Let L>=2 be the number of weight layers, so there are L-1 hidden activation layers and a linear readout. Every hidden layer has width N. There is one constant input coordinate at the first layer and no separate hidden-layer biases. The activation phi is K-Lipschitz, K>0, and phi(0)=0. Write D=d+1 and use the original energy

    E=(d/N)||W_1||_F²
      +sum_(l=2)^(L-1)||W_l||_F²
      +N||v||².

Empty products and sums have their usual meanings at L=2.

## A uniform teacher embedding

Suppose a depth-L teacher has hidden widths at most C, every weight bounded by B, and global output margin greater than1/2. Pad each hidden layer to width C with zero neurons; phi(0)=0 makes this padding harmless.

For any N>=2C choose positive integers m_1,...,m_C summing to N, each floor(N/C) or ceil(N/C), and use these same cloning counts at every hidden layer. Clone each first-layer row i exactly m_i times. At an intermediate layer replace a teacher edge W_(ij) by W_(ij)/m_j between every source clone j and every destination clone i. Divide the final readout v_j by m_j. Every preactivation and output is preserved exactly.

The first-layer energy is at most dD B². At each intermediate layer,

    ||W_l^clone||_F²=sum_(i,j) (m_i/m_j) W_(l,ij)²
                     <=2 C²B²,

because the ratio of any two floor/ceiling counts is at most2. The readout energy is at most2C²B² because m_j>=N/(2C). Thus the target has energy at most

    E_T=d(d+1)B²+2(L-1)C²B²                         (1)

at every N>=2C.

## Energy of any network with a one-dimensional first-layer ridge

Let a be a nonzero convex minimum-Euclidean-norm affine unit-margin separator of a nonempty labeled history, and let Q=||a||². Suppose every first-layer row is proportional to a:

    (W_1)_j=r_j a.

No restriction is placed on any later hidden matrix or on the readout. This is the precise ridge condition used here. At an active affine training point, |a dot xbar|=1. Repeated Lipschitz bounds and phi(0)=0 give

    1/2 <= |F(x)|
         <= K^(L-1) ||r|| product_(l=2)^(L-1)||W_l||_F ||v||.

Let e_1,...,e_L be the nonnegative layer contributions to E. Their product is

    product_l e_l
      =dQ ||r||² product_(l=2)^(L-1)||W_l||_F² ||v||²
      >=dQ/[4 K^(2L-2)].

AM--GM therefore gives

    E >= L [dQ/(4 K^(2L-2))]^(1/L).                 (2)

If this ridge network realizes the closed-global-margin energy minimum for a target-consistent history, comparison with (1) yields

    Q <= [4 K^(2L-2)/d] (E_T/L)^L.                 (3)

Closed minima exist at fixed width by continuity and coercivity. Their fixed-function values equal the strict-margin infima by arbitrarily small readout amplification.

## Conditional online bound

Consider successive convex affine unit-margin minima a_t. Suppose an argument reduces the canonical energy minimum and its predictions at every state to a first-layer ridge along a_t, with the prediction following sign(a_t dot xbar). If a_t has global affine absolute margin at least1, each mistaken round raises Q_t=||a_t||² by at least4/(d+1), by the convex projection argument in the shallow note.

Combining with (3), the number of mistaken rounds is at most

    [(d+1)/d] K^(2L-2) (E_T/L)^L.                   (4)

If only the wrong affine sign is known, without the global affine margin, use the increment1/(d+1); the bound is then four times (4). If the ridge comparison is not known after the last update, add one.

For every fixed depth L, this is a polynomial in d,C,B,K. Hence the same affine-minimum route cannot produce exponential-in-complexity mistakes at a fixed depth for a bounded teacher and any fixed Lipschitz activation vanishing at zero. The bound may grow exponentially with L. This is consistent with the existing deep width-one constructions, where the depth itself grows with the example size.

Nothing here proves that an unrestricted wide minimum-energy network is a ridge, or that its prediction agrees with the convex affine minimum. Those are the hypotheses that a scalar-style proof would need, and the conclusion shows their limitations.
