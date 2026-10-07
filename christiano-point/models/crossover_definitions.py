"""How the readings of "AI's contribution exceeds humans'" come apart in the task model.

Task model (Zeira 1998; Acemoglu & Restrepo 2018): tasks i in [0, 1] are combined by
a CES aggregator with elasticity sigma < 1. Humans (quantity H) can perform every task;
AI (quantity A, in human-equivalent units) only tasks i < I. Output is the maximum over
allocations. With symmetric tasks the optimum has two regimes:

  AI-scarce    A (1 - I) <= I H :  Y = H + A
  AI-saturated otherwise        :  Y = [ I^(1-rho) A^rho + (1-I)^(1-rho) H^rho ]^(1/rho)

where rho = 1 - 1/sigma < 0. This script checks numerically the facts used in section 2
of the report:

  (1) with abundant AI, m = Y(H,A)/Y(H,0) -> (1-I)^(-1/(1-sigma)), so m = 2 at
      I* = 1 - 2^-(1-sigma);
  (2) the two-player Shapley share of AI is (m-1)/2m < 1/2 whenever I < 1;
  (3) the Shapley value with many small players approaches the Euler share
      A F_A / F (Aumann-Shapley), which is at most I and goes to 0 as A grows.
"""
import numpy as np

rng = np.random.default_rng(0)


def output(H, A, I, sigma):
    rho = 1 - 1 / sigma
    if I >= 1:
        return H + A
    if A * (1 - I) <= I * H:
        return H + A
    if H == 0:
        return 0.0  # rho < 0 and the non-automatable tasks get no input
    return (I ** (1 - rho) * A ** rho + (1 - I) ** (1 - rho) * H ** rho) ** (1 / rho)


def euler_share(H, A, I, sigma, h=1e-7):
    y0, y1 = output(H, A, I, sigma), output(H, A * (1 + h), I, sigma)
    return (np.log(y1) - np.log(y0)) / np.log1p(h)


def shapley_two_player(H, A, I, sigma):
    yHA, yH, yA = output(H, A, I, sigma), output(H, 0, I, sigma), output(0, A, I, sigma)
    return 0.5 * ((yHA - yH) + yA) / yHA


def shapley_many_players(H, A, I, sigma, n=400, samples=300):
    """Monte-Carlo Shapley value of the AI coalition with n human and n AI players."""
    total = 0.0
    for _ in range(samples):
        is_ai = rng.permutation(np.r_[np.zeros(n, bool), np.ones(n, bool)])
        h = np.cumsum(~is_ai) * H / n
        a = np.cumsum(is_ai) * A / n
        ys = np.array([output(hh, aa, I, sigma) for hh, aa in zip(h, a)])
        gains = np.diff(np.r_[0.0, ys])
        total += gains[is_ai].sum()
    return total / samples / output(H, A, I, sigma)


if __name__ == "__main__":
    print("(1) Uplift with abundant AI (A = 1e9 per unit of H)")
    print("    sigma   I* = 1-2^-(1-sigma)   m at I*")
    for sigma in [0.05, 0.25, 0.5, 0.75]:
        I_star = 1 - 2 ** (-(1 - sigma))
        m = output(1, 1e9, I_star, sigma) / output(1, 0, I_star, sigma)
        print(f"    {sigma:5.2f}   {I_star:.3f}                 {m:.3f}")
    print()
    I, sigma = 0.5, 0.5
    print(f"(2)-(3) One domain: I = {I}, sigma = {sigma}, H = 1, AI supply A varies")
    print("    A        volume  uplift m  U-share  Euler  2-player Shapley  n-player Shapley (n=400)")
    for A in [0.25, 0.5, 1, 2, 5, 20, 100]:
        y = output(1, A, I, sigma)
        m = y / output(1, 0, I, sigma)
        print(f"    {A:7.2f}  {A / (1 + A):.3f}   {m:.3f}     {1 - 1 / m:.3f}    "
              f"{euler_share(1, A, I, sigma):.3f}  {shapley_two_player(1, A, I, sigma):.3f}"
              f"             {shapley_many_players(1, A, I, sigma):.3f}")
