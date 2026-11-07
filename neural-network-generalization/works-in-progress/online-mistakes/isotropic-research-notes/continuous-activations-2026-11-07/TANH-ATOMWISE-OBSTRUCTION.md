# Exact obstruction to triangle-style atomwise rounding for tanh

This is an obstruction to one proof method, not to the desired online lower bound.

Fix `s>=2` and write `chi(x)=prod_i x_i` on `{−1,1}^s`. Define the true single-parity tanh cost

    a_s=inf_{theta: hhat_theta(chi)!=0}
             ||theta||_2/|hhat_theta(chi)|,
    h_theta(x)=tanh(theta·(1,x)).

Then the infimum is attained by a finite nonzero parameter vector, but no optimizing atom is constant on every parity fiber. Consequently there are no positive universal `kappa` and atom error numbers `e(theta)` satisfying both

    ||theta||_2-a_s |hhat_theta(chi)| >= kappa e(theta)

and

    |h_theta(x)-h_theta(x')| <= e(theta)||x-x'||_2
       whenever chi(x)=chi(x')

for all affine tanh atoms.

## Attainment

There is an atom with nonzero parity coefficient. For example, a steep affine tanh approximating the Boolean AND sign has limiting nonzero full-parity correlation `2^(1-s)`.

The parity coefficient is continuous in the parameters. As `r=||theta||_2` tends to zero, the uniform finite-cube Taylor estimate

    tanh(theta·xbar)=theta·xbar+O_s(r^3)

and the orthogonality of a degree-at-least-two character to affine functions give `hhat_theta(chi)=O_s(r^3)`. The ratio therefore tends to infinity. As `r` tends to infinity, the bound `|hhat_theta(chi)|<=1` also makes the ratio tend to infinity. A bounded sublevel set of the ratio stays away both from zero norm and from zero parity coefficient; compactness and continuity give an optimizer.

## Failure of fiber constancy

Suppose an affine tanh atom is constant on each of the two parity fibers. Strict injectivity of tanh implies that its affine preactivation is also constant on those fibers. Thus on the cube that affine function has the form `b+q chi(x)`. Since `s>=2`, Fourier orthogonality forces `q=0`; all incoming variable weights vanish. The atom is constant and has zero parity coefficient, contradicting optimality.

Hence an optimizing atom varies within a parity fiber. The graph on either parity fiber obtained by flipping two bits is connected, so at least one such edge has a nonzero output difference. Any error number controlling the displayed fiber Lipschitz inequality must be strictly positive. The exact single-parity deficit at the optimizer is zero, contradicting the proposed positive rounding penalty.

The triangle-wave proof avoids this obstruction because its parity-optimal atoms are themselves exact pure characters. Ordinary tanh needs a different, likely mixture-level and calibration-aware, exclusion of non-code sign completions. This note does not rule out such an exclusion.
