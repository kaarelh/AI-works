# Independent derivation of the leverage-sampling reconstruction

Research note, 22 October 2026. This is an independent derivation of the reconstruction lemma. Its readout argument is an alternative to the importance-sampling argument in the final [paper](../original-support-all-scales/paper.pdf); the [full assembly audit](all-scales-review.md) verifies the published numerical budgets. This replaces the expensive finite-source reconstruction in the existing entropy compressor. It retains the original RMS robustness support and Gaussian prior. It does not alter the conditional-entropy/active-direction argument preceding that reconstruction.

## Conditional setup

Fix a current virtual prefix, its active-query list, and the active coordinates of the current matrix. Let `U` be the N-by-s orthonormal active basis, `s<=q`, and write

$$
u_j=\sqrt N\,U_{j,:},\qquad \frac1N\sum_j u_j u_j^\top=I_s.
$$

At an input x, write `h_j=h_j(x)`, with `|h_j|<=1`, and

$$
\psi=\frac1N\sum_j u_jh_j,\quad K_x=\frac1N\sum_jh_j^2,\quad C_x=K_x-\|\psi\|^2\in[0,1].
$$

The ideal reconstructed layer has mean `H_i psi` in row i and independent Gaussian residual fields with scalar variance `t^2 C_x`. Here H is the active matrix after the old row clipping. The old entropy moment bound gives

$$
\mathbb E\frac{\|H\|_F^2}{N}\le V.
$$

The averaging in this last statement is over the canonical construction; H need not be independent of the prefix or of later original weights.

## Importance sampling

For s>=1, sample m independent source indices with probabilities

$$
p_j=\frac{1+\|u_j\|^2/s}{2N}.
$$

These sum to one. Set, for a sampled source j,

$$
c_j=\frac{u_j}{\sqrt{Np_j}},\qquad g_j(x)=\frac{h_j(x)}{\sqrt{Np_j}}.
$$

Then

$$
\mathbb E cc^\top=I_s,\quad \mathbb E cg=\psi,\quad
\mathbb E g^2=K_x,\quad \|c\|^2\le2s\le2q,\quad |g|^2\le2.
$$

The source probabilities depend only on the prefix and query list, since U does. They do not use the active values H or additional future-weight information.

Let

$$
G=\frac1m\sum_{a=1}^m c_ac_a^\top,\quad
\widehat\psi=\frac1m\sum_ac_ag_a,\quad
\widehat K=\frac1m\sum_ag_a^2.
$$

Matrix Chernoff gives

$$
\Pr\{G\not\succeq I_s/2\}\le s\exp[-m/(16s)].
$$

The event is independent of x. Abort on this event. There is no need for an upper bound on G. On its complement, define D to have rows `c_a^T G^{-1/2}/sqrt(m)`. Then `D^T D=I_s` and `I-DD^T` is an orthogonal projection.

For each target row draw `xi_i~N(0,I-DD^T)`, independently across rows. Use actual coefficients on the sampled, unrescaled neural activations h:

$$
\widehat w_{ia}=\frac{H_i u_{S_a}}{mNp_{S_a}}
 +\frac{t\xi_{ia}}{\sqrt{mNp_{S_a}}}.
$$

The mean is `H_i widehat(psi)`, and the Gaussian residual variance is

$$
t^2\widehat C_x,\qquad
\widehat C_x=\widehat K-\widehat\psi^\top G^{-1}\widehat\psi\ge0.
$$

The whole candidate field is defined by the displayed weights, giving one law independent of which input is subsequently coupled.

## Mean-square error of the active mean

For every fixed H and x, independence of the sampled indices and `p_j>=1/(2N)` give

$$
\mathbb E\frac{\|H(\widehat\psi-\psi)\|_2^2}{N}
 \le\frac{2\|H\|_F^2}{Nm}.
$$

To see this, drop the square of the mean from the sampling variance and use

$$
\sum_j\frac{\|Hu_j\|^2h_j^2}{N^2p_j}
 \le\frac2N\sum_j\|Hu_j\|^2=2\|H\|_F^2.
$$

This is an averaged error bound. Replacing it by a worst-case row norm times a uniform cross-feature error unnecessarily worsens the sample polynomial.

## Mean-square error of the Gaussian standard deviation

Put `r_j=h_j-u_j^T psi`. For a sampled source set

$$
a_j=\frac{r_j}{\sqrt{Np_j}},\quad
A=\frac1m\sum_a a_{S_a}^2,\quad b=\frac1m\sum_a c_{S_a}a_{S_a}.
$$

Orthogonality gives

$$
\mathbb E a^2=C_x,\qquad \mathbb E ca=0.
$$

Since `||psi||<=1`,

$$
a_j^2\le\frac{2(1+\|u_j\|^2)}{Np_j}
 =\frac{4(1+\|u_j\|^2)}{1+\|u_j\|^2/s}\le4s\le4q.
$$

Therefore

$$
\operatorname{Var}(A)\le\frac{4qC_x}{m},\qquad
\mathbb E\|b\|^2\le\frac{2qC_x}{m}.
$$

The exact regression identity is

$$
\widehat C_x=A-b^\top G^{-1}b.
$$

On the Gram-good event, the correction is at most `2||b||^2`. For nonnegative a>=b, `(sqrt(a)-sqrt(a-b))^2<=b`. Also, if `C_x>0`,

$$
\mathbb E(\sqrt A-\sqrt{C_x})^2
 \le\frac{\operatorname{Var}(A)}{C_x}\le\frac{4q}{m}.
$$

Combining these two inequalities gives

$$
\mathbb E\left[(\sqrt{\widehat C_x}-\sqrt{C_x})^2;
 G\succeq I_s/2\right]\le\frac{16q}{m}.
$$

When `C_x=0`, all residuals vanish, so this inequality also holds.

For s=0 use uniform source sampling, no Gram matrix, and no active mean. The elementary variance bound on the empirical average of `h_j^2` gives a standard-deviation error at most `1/m`. The same formulas below are valid with `q+1`.

## Transport and bounded candidate weights

Couple the two scalar Gaussian evaluations at a fixed input using the same standard normal. Conditional on the structural data and sampled sources, its mean is zero, so the mean-shift and Gaussian-variance errors have zero cross term. Averaging the rows and all structural data yields

$$
\mathbb E\left[\text{squared preactivation RMS error};\text{Gram good}\right]
 \le\frac{2V+16(q+1)}m.
$$

Scalar couplings can be extended to full weight fields by disintegration, exactly as in the original proof. They do not assert that a single coupling is close at every input simultaneously.

The original row clipping can be retained: `||H_i||<=B_H`, with `B_H^2=4V/e`, and its activation-error contribution is at most e. The coefficient bound

$$
\frac{\|u_j\|}{Np_j}
 =\frac{2\|u_j\|}{1+\|u_j\|^2/s}\le\sqrt s\le\sqrt q
$$

shows that every active sampled weight has magnitude at most `B_H sqrt(q)/m`.

Each xi coordinate has variance at most one. Clip all of them to `[-B_G,B_G]`, where

$$
B_G=\max\{2,\,2\sqrt{\log(6m/e)}\}.
$$

As `|g_j|<=sqrt(2)`, Cauchy--Schwarz and the same Gaussian-tail estimate used in the original proof bound its expected squared preactivation effect by

$$
6m e^{-B_G^2/4}\le e.
$$

The final internal weights are consequently bounded by

$$
B_H\sqrt q/m+\sqrt2 B_G/\sqrt m.
$$

All transformations after the active query list are randomized functions of `(prefix, query list, active coordinates)`. The existing unprocessed-weight entropy lemma therefore continues to apply unchanged.

A sufficient internal source count is

$$
m\ge512(V+q+1)/e,
\qquad
m\ge128(q+1)\log\frac{2(q+1)}\eta.
$$

The first inequality controls reconstruction transport; the second bounds the Gram abort probability by eta. Both are far smaller than the old leverage-vector truncation budget.

## The readout must also use its variance

The old Hoeffding readout budget would dominate the improved internal bound. Replace that step by scalar Bernstein.

After the original readout-energy truncation, `E_v<=K_0`. Delete coordinates with `|Nv_i|>B_v=16K_0/r`; their total absolute output contribution is at most `r/16`. For a uniformly sampled source,

$$
Y=Nv_I\mathbf1_{|Nv_I|\le B_v}\,h_I
$$

has `|Y|<=B_v` and variance at most `K_0`. Bernstein at accuracy `r/16`, followed by a union bound over all `2^d` Boolean inputs, gives failure at most eta whenever

$$
m\ge1024 K_0r^{-2}\left[d\log2+\log(2/\eta)\right].
$$

This replaces the old quadratic-in-`B_v` Hoeffding cost with a cost linear in `K_0`.

## Width exponent and scope

Retain the original parameter choices

$$
e=\frac{\alpha r^2}{1000L},\quad
\eta=\frac\alpha{100L},\quad
q=\left\lceil\frac{2K}{e\eta}\right\rceil,
\quad V=8K+2q,\quad K_0=(4K+2\log2)/\eta.
$$

The dominant width is now proportional to `(V+q)/e`, up to the displayed dimension/logarithm terms. Holding the other parameters fixed, when `r^{-2}=O(K)`, one has

$$
q=O(K^2),\qquad m=\widetilde O(K^3).
$$

The unchanged small-width cutoff, parameter bounding, and final grid produce a log-cardinality `widetilde O(K^6)`, and therefore a sixth-power teacher-width bound up to logarithms, since the robust target-cylinder cost is nearly linear in C.

This applies to the **existing entropy proof for every gamma>=1**, including actual finite mean-field priors, because its preceding relative-entropy argument and following statistical comparison remain unchanged. The derivation above is mathematical, not Lean verified. Its precise aggregate sample-budget constants should be assembled and checked in the main new note before making a publication-level theorem claim.
