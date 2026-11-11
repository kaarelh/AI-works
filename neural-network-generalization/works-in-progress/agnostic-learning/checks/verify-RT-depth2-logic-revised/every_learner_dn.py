"""Illustration for issue 2 of the report: the "+o(1)" formulation uniform over d <= n is false for EVERY learner.

Law: d = n, x uniform on {e_1, ..., e_n} (unit vectors, so in [-1,1]^d and in the unit ball), y = theta_J at x = e_J,
theta uniform on {-1,1}^n.  Competitor in G_n^(alpha): g(x) = n^alpha tanh(n^{-alpha} theta . x) (width 1, weights
n^{-alpha} and n^alpha), with L_D(g) <= n^{-4 alpha}/9.  For unseen coordinates j the learner's output is independent of
theta_j, so any learner has (f(e_j) - theta_j)^2 >= 1 with conditional probability >= 1/2; the Bayes-optimal learner
(predict 0 on unseen atoms) has loss exactly |U|/n -> 1/e.  We print |U|/n, the Bayes-optimal loss, the loss of a
learner that guesses +1 on unseen atoms, and L_D(g) for alpha = 0.1.
"""
import numpy as np

rng = np.random.default_rng(5)
alpha = 0.1
for n in (10 ** 3, 10 ** 4, 10 ** 5, 10 ** 6):
    theta = rng.choice([-1.0, 1.0], size=n)
    J = rng.integers(0, n, size=n)
    seen = np.zeros(n, bool); seen[J] = True
    U = ~seen
    f_bayes = np.where(seen, theta, 0.0)
    f_guess = np.where(seen, theta, 1.0)
    L_bayes = np.mean((f_bayes - theta) ** 2)
    L_guess = np.mean((f_guess - theta) ** 2)
    g = n ** alpha * np.tanh(n ** -alpha * theta)
    L_g = np.mean((g - theta) ** 2)
    print("n=d=%7d  |U|/n=%.4f  L(Bayes-opt learner)=%.4f  L(guess +1)=%.4f  L(competitor)=%.2e (bound %.2e)" % (
        n, U.mean(), L_bayes, L_guess, L_g, n ** (-4 * alpha) / 9))
