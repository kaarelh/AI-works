# Lemma T (level-mass regularity of the tanh NNGP kernel): proof

Author: deep-1 subagent. Scripts and data: `expd/deep1/` (absolute paths in Section 9).

## 0. Verdict

**Lemma T is true.** It holds for every depth L >= 2 and every choice of gains, in a form slightly stronger than stated.

* **(T1).** The bound theta_j <= C_T/sqrt(j) holds for all odd j in [j_0, D/4], where j_0 is a constant, not d/log d. A matching lower bound theta_j >= c_T/sqrt(j) also holds.
* **(T2).** The bound W_i <= C_T W_{j+2} holds for every odd i >= j+2, not only up to D/2.
* **Depth 2 is monotone.** For L = 2 the pair masses are nonincreasing up to an error eps_D <= C D exp(-pi^2 D/(4 sigma_1^2)), so (T2) holds with C_T = 2.
* **Consequences.** The three consequences listed in the lemma follow (Section 5, (C1)–(C3)). The new lower bound theta_r >= c_T/sqrt(r) is used to absorb the e^{-cD} tail term in (C2).

**How complete the proof is.**

* **L = 2.** The proof is complete and self-contained. Outside elementary calculus it uses only two standard facts: Bernstein's inequality and the one-dimensional Brascamp–Lieb variance inequality.
* **L >= 3.** The proof is complete modulo two standard limit theorems: the Kolmogorov–Rogozin concentration inequality and Gnedenko's lattice local limit theorem.
* **New ingredient for L >= 3.** A "composition lemma" (Section 4) proves the two-sided bound c^{(L)}_m ≍ m^{-1/2} exp(-alpha_L sqrt m) for the composite Taylor coefficients. Here
  alpha_L = min_{1<=l<=L-1} (pi/sqrt(q_l)) (mu_1 ... mu_{l-1})^{-1/2},
  where q_l are the layer variances and mu_l = phihat_{q_l}'(1).
* **Transfer theorem.** A transfer theorem (Section 3) turns any such two-sided bound into (T1) and (T2).

**The conjectured sharp form.**

* **True for L = 2** (Theorem 6.1). The leading order is theta_j ~ (pi/sigma_1)/((1-2rho') sqrt(D kappa(rho'))).
* **False as stated for L >= 3 and general gains.** The constant pi/sigma_1 must be replaced by alpha_L.
  * For unit gains, alpha_L = pi/sigma_1, so the stated form is right there.
  * For L = 3 with (sigma_1, sigma_2) = (1, 3): alpha_3 = 1.5367, while pi/sigma_1 = 3.1416. The measured theta is 0.50–0.55 times the sigma_1-prediction and 0.96–0.997 times the alpha_3-prediction (D = 641, 2561, 6001).
  * With alpha_L in place of pi/sigma_1, the sharp form for L >= 3 follows (Theorem 6.1(b)) once c^{(L)}_m ~ C m^{-1/2} e^{-alpha_L sqrt m} (asymptotic equivalence, not only ≍). Numerics strongly support this, but it is not proved here.
* **Finite-size accuracy.** The claim "within 1–3% for d >= 640" fails at rho >= 0.2. At d = 640 the error is 4.5% at rho = 0.2 and 6.3% at rho = 0.25. At d = 10240 it is 1.4% and 2.1%. The error is O(D^{-1/2}).

**Correction of the paper's description.** theta_r ≍ r^{-1/2}, so w_{r+2}/tau_r = Theta(d^{-1/2}) at linear degree. The "constant factor ~0.46 per two levels" seen at d = 160 is a finite-d effect. The true factor is exp(-alpha_L/((1-2rho)sqrt(D kappa))), which tends to 1.

**Constants.** All constants are astronomically large in this proof (for example C_T contains exp(50a^2/3 + 12.5(a+B)) with a = pi/(2 sigma_1)). They depend only on L and the gains.

---

## 1. Setting and exact identities

Notation:

* D = d+1, and j, i always denote odd integers.
* X_m is the Hamming weight after m uniform single-coordinate flips of the D-cube, started at 0. It is a birth–death chain, X_m ≡ m mod 2.
* For the composite F = sum_m c_m t^m (odd), a_j = sum_m c_m p_m(j). Hence

  W_j := C(D,j) a_j = sum_m c_m P(X_m = j).   (1.1)

* For odd r, tau_r = A sum_{odd j >= r+2} W_j and lambda_{r+1} = A W_{r+2}/C(D,r+2). The pairing gives C(d,j-1) + C(d,j) = C(D,j). Hence
  theta_r = W_{r+2}/T_r with T_r := sum_{odd i >= r+2} W_i.
  This was checked numerically against w_q = C(d,q) lambda_q.
* p(t) = (1 - e^{-2t/D})/2 and tau(x) := -(D/2) log(1-2x) = p^{-1}(x).
* b_j(x) := C(D,j) x^j (1-x)^{D-j} and kappa(rho) = -(1/2)log(1-2rho), so tau(rho) = D kappa(rho).
* f ≍ g means c <= f/g <= C with constants depending only on L and the gains.

**Poissonization.** Run the walk for Poisson(t) steps. The coordinates are then flipped independently, each an odd number of times with probability p(t). So

  sum_m pi_t(m) P(X_m = j) = b_j(p(t)),   pi_t(m) = e^{-t} t^m/m!.   (1.2)

Consequently, whenever odd-index coefficients have the form c_m = int_0^inf pi_t(m) M(t) dt for odd m with M >= 0, Tonelli gives, for odd j,

  W_j = int_0^inf M(t) b_j(p(t)) dt = D int_0^{1/2} psi(x) b_j(x) dx = (D/(D+1)) E[psi(X); X < 1/2],   X ~ Beta(j+1, D-j+1),   (1.3)

with psi(x) := M(tau(x))/(1-2x).

* Even m contribute nothing to (1.1) for odd j, so M need not reproduce the even coefficients.
* The last equality uses int_0^1 b_j = 1/(D+1).

## 2. Depth 2: the Poisson-mixture density mu

Fix sigma > 0 and set v = E tanh^2(sigma G), a := pi/(2 sigma), g(w) = e^{-sigma^2 w^2/2}/sinh(pi w/2). For t > 0 define

  mu(t) := (1/(v sigma^2)) int_R exp(Phi(t,u)) du,
  Phi(t,u) := -2t sinh^2 u - log sinh(a sqrt(t) e^u) - log sinh(a sqrt(t) e^{-u}).   (2.1)

**Lemma 2.1 (Poisson-mixture identity).** For odd m, the first-layer tanh coefficient is c_m(sigma^2) = sigma^{2m} I_m(sigma)^2/(m! v) = int_0^inf pi_t(m) mu(t) dt. Hence, for L = 2,

  W_j = int_0^inf mu(t) b_j(p(t)) dt   for odd j.

*Proof.*

1. Write I_m^2 = ∬ (w w')^m g(w) g(w') dw dw'.
2. Substitute w = sqrt(t) e^u/sigma and w' = sqrt(t) e^{-u}/sigma. The Jacobian is dw dw' = dt du/sigma^2. Then sigma^{2m}(ww')^m = t^m and sigma^2(w^2 + w'^2)/2 = t cosh 2u = t + 2t sinh^2 u.
3. Also pi w/2 = a sqrt(t) e^u. Hence sigma^{2m} I_m^2/(m! v) = int (e^{-t} t^m/m!) mu(t) dt. Everything is positive, so Tonelli applies.
4. The level-mass formula is (1.3) with M = mu. ∎

Numerical check (`check_identity.py`): relative error 1e-14 for m = 3..301. The mu-formula for W_j matches the direct Ehrenfest-walk computation of the level masses to 1e-9 for d = 160, 640, 2560, 10240 (`levels_mu.py`).

**Lemma 2.2 (properties of mu).** Put B := 1.649 + 0.134a and M_0 := 2.4/(v sigma^2 a^2). Then:

* (i) mu is C^1 on (0,inf) and -(log mu)'(t) >= a/sqrt(t) for all t > 0. In particular mu is strictly decreasing.
* (ii) -(log mu)'(t) <= a/sqrt(t) + B/t for all t >= 1.
* (iii) mu(t) <= M_0 (1 + log(1/t))/t <= 2 M_0 t^{-2} for 0 < t <= 1.
* (iv) mu(t) ≍ t^{-1/2} e^{-2a sqrt(t)} for t >= 1. Explicitly,
  (8 e^{-2.76-2a}/(v sigma^2)) t^{-1/2} e^{-2a sqrt t} <= mu(t) <= (C_a/(v sigma^2)) t^{-1/2} e^{-2a sqrt t}.

*Proof.*

**Step 1 (the derivative).** Write y_{1,2} = a sqrt(t) e^{±u}. Then
  d_t Phi = -2 sinh^2 u - (y_1 coth y_1 + y_2 coth y_2)/(2t) <= 0.
So e^{Phi(t,u)} is decreasing in t, and differentiation under the integral is dominated on [t_1, t_2] ⊂ (0,inf). Let E_t be the expectation under the probability density p_t(u) ∝ e^{Phi(t,u)}. Then

  -(log mu)'(t) = E_t[2 sinh^2 u] + E_t[(y_1 coth y_1 + y_2 coth y_2)/(2t)].

**Step 2, part (i).** Since y coth y >= y and y_1 + y_2 = 2a sqrt(t) cosh u, the second term is at least (a/sqrt t) E_t cosh u >= a/sqrt t.

**Step 3, part (ii).**
* Upper bound on the second term: y coth y <= 1 + y, so it is at most 1/t + (a/sqrt t) E_t cosh u.
* Strong log-concavity: d_u^2(-2t sinh^2 u) = -4t cosh 2u <= -4t. Also, for y = c e^{±u}, d_u^2 log sinh y = y(coth y - y/sinh^2 y) >= 0, because sinh y cosh y >= y. So d_u^2 Phi <= -4t, and p_t is 4t-strongly log-concave and even.
* Laplace-transform bound: by Brascamp–Lieb, every tilt e^{lambda u} p_t has variance <= 1/(4t). With E_t u = 0, the function F(lambda) = log E_t e^{lambda u} satisfies F'' <= 1/(4t) and F(0) = F'(0) = 0. Hence E_t e^{lambda u} <= e^{lambda^2/(8t)}.
* Consequences: E_t[2 sinh^2 u] = E_t e^{2u} - 1 <= e^{1/(2t)} - 1 <= 0.649/t, and E_t cosh u <= e^{1/(8t)} <= 1 + 0.134/t, both for t >= 1.
* Collecting terms: -(log mu)' <= a/sqrt t + (1 + 0.649 + 0.134 a)/t.

**Step 4, part (iii).** Use 1/(sinh y_1 sinh y_2) <= 1/(y_1 y_2) = 1/(a^2 t). For t <= 1, int_R e^{-2t sinh^2 u} du <= log(1/t) + 2.4. (Use sinh^2 u >= 0.187 e^{2|u|} for |u| >= 1 and cut at e^{2U} = 1/(0.37t).)

**Step 5, part (iv).** Write 1/sinh y = 2e^{-y}/(1-e^{-2y}) and y_1 + y_2 = 2a sqrt(t) cosh u. Then

  mu(t) = (4/(v sigma^2)) int e^{-2t sinh^2 u - 2a sqrt t cosh u} / ((1 - e^{-2y_1})(1 - e^{-2y_2})) du.

* Lower bound: restrict to |u| <= t^{-1/2}. There 2t sinh^2 u <= 2.76, cosh u <= 1 + u^2, and the denominator is <= 1.
* Upper bound: use cosh u >= 1 and 1/(1-e^{-2y}) <= 1 + 1/(2y) <= 1 + e^{|u|}/(2a) for t >= 1. Then int e^{-2t sinh^2 u}(1 + e^{|u|}/(2a))^2 du <= C_a t^{-1/2}. ∎

All four parts were checked numerically for sigma in {0.3, 0.5, 1, 2, 3} on t in [1, 1e6] (`check_mu_bounds.py`).

* For t >= 1, (-(log mu)' - a/sqrt t)·t lies in [0.31, 1.00]. This is >= 0 and <= B, as proved. It tends to 1/2.
* log(mu sqrt(t) e^{2a sqrt t}) varies by at most 0.76.
* For sigma = 1, (log mu)(t) = -2a sqrt t - (1/2)log t + log(4 sqrt(pi/2)/v) + O(t^{-1/2}).

## 3. Transfer theorem: a regular mixing profile gives (T1) and (T2)

**Definition 3.1 (admissible profile).** M: (0,inf) -> (0,inf) is C^1 and, for constants a > 0, B >= 0, M_0:

* (A1) -(log M)'(t) >= a/sqrt t for all t > 0;
* (A2) -(log M)'(t) <= a/sqrt t + B/t for t >= 1;
* (A3) M(t) <= M_0 t^{-2} on (0,1].

**Examples.**

* mu from Lemma 2.2, with a = pi/(2 sigma).
* M_alpha(t) := t^{-1/2} e^{-alpha sqrt t}, with a = alpha/2, B = 1/2, M_0 = 1.

For odd j >= 3 put

  W^M_j := int_0^inf M(t) b_j(p(t)) dt,   T^M_j := sum_{odd i>=j+2} W^M_i,   theta^M_j := W^M_{j+2}/T^M_j.

**Theorem 3.2.** Let M be admissible. There are j_0, D_0, c_*, C_* depending only on (a, B, M_0/M(1)) such that for D >= D_0:

* (i) **quasi-monotonicity:** W^M_i <= W^M_{i'} + eps_D for all odd 3 <= i' <= i <= D. Here
  eps_D := int_{a^2D^2/4}^inf M <= M(1) e^{2a} (D/2 + 1/(2a^2)) e^{-a^2 D}.
* (ii) c_*/sqrt j <= theta^M_j <= C_*/sqrt j for all odd j in [j_0, D/4].
* (iii) W^M_i <= 2 W^M_{j+2} for all odd 1 <= j <= D/4 and all odd i >= j+2.

*Proof.* Use (1.3): W^M_j = (D/(D+1)) E[psi(X_j); X_j < 1/2], with X_j ~ Beta(j+1, D-j+1) and psi(x) = M(tau(x))/(1-2x). Write

* xbar_i := (i+1)/(D+2) for the mean of X_i;
* xhat_i := xbar_i + 2 sqrt(i+1)/(D+2) for a point slightly above it;
* tau(x) >= D x;
* tau(x)/x increasing (tau convex, tau(0) = 0), so tau(x) <= 1.527 D x for x <= 0.3;
* tau'(x) = D/(1-2x) <= 2.5 D on [0, 0.3].

**Step 0 (monotonicity of psi).** We have (log psi)(x) = log M(tau(x)) + 2tau(x)/D. So
  (log psi)' = tau'(x)[(log M)'(tau) + 2/D] <= tau'(x)[2/D - a/sqrt(tau)] <= 0
whenever tau <= t* := a^2 D^2/4. Hence psi is nonincreasing on (0, x*], x* := p(t*).

**Step 1 (part i: monotone likelihood ratio).** Let psi_1 := psi·1_{(0,x*]}. This is nonincreasing on (0,1) and >= 0. Then

  W^M_i = (D/(D+1)) E psi_1(X_i) + int_{t*}^inf M(t) b_i(p(t)) dt.

The second term is <= eps_D. The density ratio of Beta(i+1, D-i+1) to Beta(i'+1, D-i'+1) is ∝ (x/(1-x))^{i-i'}, which is increasing. So X_i stochastically dominates X_{i'}, and E psi_1(X_i) <= E psi_1(X_{i'}). Hence W^M_i <= W^M_{i'} + eps_D.

The bound on eps_D comes from (A1): M(t) <= M(1) e^{-2a(sqrt t - 1)} for t >= 1, together with int_{t*}^inf e^{-2a sqrt t} dt = (sqrt(t*)/a + 1/(2a^2)) e^{-2a sqrt(t*)}.

**Step 2 (lower bound).** Var X_i <= (i+1)/(D+2)^2. Chebyshev gives P(X_i <= xhat_i) >= 3/4. Since psi_1 >= psi(xhat_i) on (0, xhat_i] (and xhat_i < x*),

  W^M_i >= (3D/(4(D+1))) psi(xhat_i).   (3.1)

**Step 3 (upper bound for 3 <= i <= 0.3D).** We claim

  W^M_i <= C_U psi(xbar_i) + eps_D.   (3.2)

On [xbar, x*] we have psi <= psi(xbar). It remains to bound E[psi(X); X < xbar] for X = X_i and xbar = xbar_i. Two facts are used throughout:

* For 1 <= tau(x) <= taubar := tau(xbar), (A2) gives
  log psi(x) - log psi(xbar) <= 2a(sqrt(taubar) - sqrt(tau(x))) + B log(taubar/tau(x)),
  since the term 2(tau - taubar)/D is <= 0.
* (Beta lower tail.) P(X <= xbar - delta) = P(Bin(D+1, xbar - delta) >= i+1) <= exp(-3(D+1)delta^2/(8 xbar)) for 0 <= delta <= xbar, by Bernstein.

The three regions:

* **R_1 = {xbar/2 <= X < xbar}.**
  * Here tau(X) >= D xbar/2 >= 1 and taubar/tau(X) <= 2.
  * Also 2a(sqrt(taubar) - sqrt(tau(X))) <= 2a(taubar - tau(X))/sqrt(taubar) <= 5a sqrt(D/xbar)(xbar - X).
  * Put Z = sqrt(D/xbar)(xbar - X)_+. Then P(Z >= z) <= e^{-3z^2/8}.
  * Hence E[psi(X); R_1] <= 2^B psi(xbar) E e^{5aZ} <= 2^B E_a psi(xbar), with E_a := 1 + 5a sqrt(8pi/3) e^{50a^2/3}.
* **R_2 = {X < xbar/2, tau(X) >= 1}.**
  * P(R_2) <= exp(-3(D+1)xbar/32) <= e^{-(i+1)/14}.
  * psi(X)/psi(xbar) <= exp(2a sqrt(taubar) + B log taubar), with taubar <= 1.527(i+1).
  * The product is bounded uniformly in i by a constant C_2(a,B).
* **R_3 = {tau(X) < 1}.**
  * Here 1 - 2X >= 1/2 and tau(X) >= DX, so psi(X) <= 2 M_0 (DX)^{-2}.
  * E[(DX)^{-2}; X < 1/D] <= (D+1) C(D,i) D^{-2} int_0^{1/D} x^{i-2} dx <= 2/((i-1) i!).
  * Meanwhile psi(xbar) >= M(1) exp(-2a sqrt(1.527(i+1)) - B log(1.527(i+1))).
  * The ratio is <= C_3(a, B, M_0/M(1)).

Summing, C_U = 1 + 2^B E_a + C_2 + C_3.

**Step 4 (regularity).** For 1 <= tau_1 <= tau_2, (A2) gives M(tau_2)/M(tau_1) >= exp(-(tau_2 - tau_1)(a/sqrt(tau_1) + B/tau_1)). Since (1-2x_1)/(1-2x_2) >= 1 for x_1 <= x_2,

  psi(x_2) >= psi(x_1) exp(-(tau(x_2) - tau(x_1))(a/sqrt(tau(x_1)) + B/tau(x_1))).   (3.3)

**Step 5 (part ii, upper bound).**

1. Let j_0 <= j <= D/4, K := floor(sqrt j), and i_k := j + 2k for 1 <= k <= K. For D >= D_0 we have i_K <= 0.29D, so xhat_{i_K} <= 0.3.
2. Distances: xhat_{i_k} - xbar_{j+2} <= 5 sqrt(j)/D. So tau(xhat_{i_k}) - tau(xbar_{j+2}) <= 12.5 sqrt j, while tau(xbar_{j+2}) >= j.
3. By (3.3), psi(xhat_{i_k}) >= e^{-12.5(a+B)} psi(xbar_{j+2}).
4. By (3.1), T^M_j >= sum_{k<=K} W^M_{i_k} >= 0.7 K e^{-12.5(a+B)} psi(xbar_{j+2}).
5. By (3.2), W^M_{j+2} <= (C_U + 1) psi(xbar_{j+2}). Here eps_D <= psi(xbar_{j+2}) for D >= D_0, because psi(xbar_{j+2}) >= M(tau(0.3)) >= M(1) e^{-2a sqrt(0.46D) - B log(0.46D)}.
6. Hence theta^M_j <= C_*/sqrt j with C_* = 3(C_U + 1) e^{12.5(a+B)}.

**Step 6 (part ii, lower bound).** We show T^M_j <= C sqrt(j) psi(xhat_{j+2}). With (3.1) this gives theta^M_j >= c_*/sqrt j. Split T^M_j by k:

* **1 <= k <= 1 + sqrt(j+3).** psi(xbar_{j+2k}) <= psi(xbar_{j+2}) <= e^C psi(xhat_{j+2}), by (3.3) applied to xbar_{j+2} <= xhat_{j+2}. Then (3.2) bounds each such W^M_{j+2k}.
* **Larger k with j + 2k <= 0.3D.** Here xbar_{j+2k} >= xhat_{j+2}, and (A1) gives
  psi(xbar_{j+2k})/psi(xhat_{j+2}) <= exp(-(tau_k - tauhat)(a/sqrt(tau_k) - 2/D)).
  * If tau_k <= 4 tauhat, this is <= exp(-c(k - 1 - sqrt(j+3))/sqrt j), a geometric sequence summing to O(sqrt j).
  * If tau_k > 4 tauhat, it is <= exp(-a sqrt(tau_k)/2) <= e^{-a sqrt(k)/2}, summable.
* **j + 2k > 0.3D.** Part (i) gives W^M_{j+2k} <= W^M_{i_1} + eps_D, where i_1 is the largest odd integer <= 0.3D. Also psi(xbar_{i_1})/psi(xhat_{j+2}) <= e^{-c sqrt D}. So these at most D terms contribute o(psi(xhat_{j+2})).

**Step 7 (part iii).** By (i), W^M_i <= W^M_{j+2} + eps_D. By (3.1), W^M_{j+2} >= 0.7 psi(xhat_{j+2}) >= eps_D for D >= D_0. ∎

**Corollary 3.3 (comparison).** Let (c_m) be the odd coefficients of any kernel F as in (1.1). Suppose K^{-1} c^M_m <= c_m <= K c^M_m for all odd m >= m_0, where c^M_m := int pi_t(m) M(t) dt and M is admissible. Then for D >= D_0:

* theta_j ∈ [c_*/(K^2 sqrt j), K^2 C_*/sqrt j] for odd j ∈ [max(j_0, m_0), D/4];
* W_i <= 2K^2 W_{j+2} for all odd j <= D/4 with j+2 >= m_0, and all odd i >= j+2.

*Proof.* P(X_m = j) = 0 for m < j. So for odd j >= m_0, (1.1) and (1.2) give K^{-1} W^M_j <= W_j <= K W^M_j. Hence theta_j/theta^M_j ∈ [K^{-2}, K^2]. Finally W_i <= K(W^M_{j+2} + eps_D) <= 2K W^M_{j+2} <= 2K^2 W_{j+2}. ∎

**Corollary 3.4 (Lemma T for L = 2).** By Lemma 2.1, c_m = c^{mu}_m exactly, so K = 1. Lemma 2.2 makes mu admissible. Theorem 3.2 then gives (T1) with both bounds, and (T2) with C_T = 2. The constants depend only on sigma_1; sigma_2 enters only through A.

## 4. Every depth: two-sided asymptotics of the composite coefficients

Notation for this section:

* q_1 = sigma_1^2, and q_{l+1} = sigma_{l+1}^2 v(q_l) with v(q) = E tanh^2(sqrt(q) G).
* c_m(q) are the single-layer coefficients of phihat_q, and mu_l := phihat_{q_l}'(1) = sum_m m c_m(q_l).
* F^{(2)} = phihat_{q_1} and F^{(L)} = phihat_{q_{L-1}} ∘ F^{(L-1)}. The coefficients of F^{(L)} are c^{(L)}_m.

**Lemma 4.1 (Poisson transform of a stretched exponential).** Let M >= 0 satisfy M(t) ≍ t^{-1/2} e^{-2a sqrt t} on [1,inf) and M <= M_0 t^{-2} on (0,1]. Then c^M_m := int pi_t(m) M(t) dt ≍ m^{-1/2} e^{-2a sqrt m} for m >= 3.

*Proof.* Let Gam ~ Gamma(m+1, 1). Then c^M_m = E M(Gam).

* **Lower bound.** On [m, m + sqrt m] the Gamma density is >= c/sqrt(m) (Stirling), so P(m <= Gam <= m + sqrt m) >= c_0. On this interval M >= c (2m)^{-1/2} e^{-a} e^{-2a sqrt m}.
* **Upper bound.** Split by the value of Gam:
  * E[M(Gam); Gam < 1] <= M_0/m!.
  * E[M(Gam); 1 <= Gam < m/2] <= C e^{-cm}.
  * On Gam >= m/2, sqrt m - sqrt(Gam) <= (m - Gam)_+/sqrt m. Also E e^{2a(m-Gam)/sqrt m} = e^{2a sqrt m}(1 + 2a/sqrt m)^{-(m+1)} <= e^{4a^2}. So E[M(Gam); Gam >= m/2] <= C m^{-1/2} e^{-2a sqrt m}(1 + e^{4a^2}). ∎

**Lemma 4.2 (single layer).** For every q > 0, c_m(q) ≍ m^{-1/2} exp(-(pi/sqrt q) sqrt m) for all odd m >= 1.

*Proof.* Lemma 2.1 with sigma = sqrt(q) gives c_m(q) = c^{mu}_m. Lemma 2.2(iii),(iv) put mu in the scope of Lemma 4.1, with 2a = pi/sqrt(q). The case m = 1 is a single positive number. ∎

**Lemma 4.3 (composition lemma).** Let h and beta be probability laws on the odd positive integers with h_m ≍ m^{-1/2} e^{-alpha sqrt m} and beta_k ≍ k^{-1/2} e^{-alpha' sqrt k} (constants c_1, C_1). Let

* mu = sum m h_m and v_2 = sum m^2 h_m;
* S_k = J_1 + ... + J_k with J_i iid ~ h;
* c_m := sum_k beta_k P(S_k = m), the coefficients of B∘H, where B and H are the generating functions of beta and h.

Then c_m ≍ m^{-1/2} e^{-alpha* sqrt m} for all odd m >= 1, with alpha* := min(alpha, alpha'/sqrt(mu)).

*Tools (standard).*

* **(R) Kolmogorov–Rogozin.** For iid integer-valued Y_i with max_n P(Y = n) <= 1 - delta, max_n P(Y_1 + ... + Y_k = n) <= C_R/sqrt(k delta). See Petrov, *Sums of Independent Random Variables*, Ch. III, §2.
* **(G) Gnedenko's lattice local limit theorem** for J' = (J-1)/2. It has span 1 because h_1, h_3 > 0, and finite variance.
* **(Tilt).** For y in [3, inf] and real lambda,
  P(S_k = m, max_i J_i <= y) = e^{-lambda m} Z^k P(S^{lambda,y}_k = m),
  where Z = sum_{j<=y} h_j e^{lambda j} and S^{lambda,y} sums iid copies of h_j e^{lambda j} 1_{j<=y}/Z.
  * For |lambda| <= max(1, alpha), neighbouring odd atoms of the tilted law have ratio >= delta' := (c_1/C_1) e^{-alpha-2max(1,alpha)}/sqrt(3). Hence its largest atom is <= 1/(1+delta') =: 1 - delta_0.
* **(Mgf).** For 0 <= lambda <= c alpha/sqrt(y) with c < 1, lambda j <= c alpha sqrt(j) for j <= y. Using e^u <= 1 + u + u^2 e^u/2,
  Z <= exp(lambda mu + lambda^2 V_c/2),   V_c := C_1 sum_j j^{3/2} e^{-(1-c) alpha sqrt j} < inf.
  Also E e^{-lambda J} <= exp(-lambda mu + lambda^2 v_2/2) for lambda >= 0.

Consequently, with constants depending only on (c_1, C_1, alpha, alpha', mu, v_2):

* (P1) P(S_k = m, max J <= y) <= (C/sqrt k) exp(-lambda(m - k mu) + k lambda^2 V_c/2), for 0 <= lambda <= c alpha/sqrt(y);
* (P2) P(S_k = m) <= (C/sqrt k) exp(-lambda(k mu - m) + k lambda^2 v_2/2), for 0 <= lambda <= 1;
* (P3) P(S_k = m, max J > y) <= k max_{j>y} h_j <= k C_1 e^{-alpha sqrt y}.

*Lower bound.*

* c_m >= beta_1 h_m.
* By (G), P(S_k = m) >= c/sqrt(k) whenever |m - k mu| <= sqrt(k), m ≡ k mod 2, and k >= k_0. There are >= c sqrt(m) odd such k, all with k <= m/mu + sqrt(m). For each, beta_k >= c m^{-1/2} e^{-alpha' sqrt(m/mu)}. So c_m >= c m^{-1/2} e^{-alpha' sqrt(m/mu)}.

*Upper bound.* Fix small eps, eta > 0, depending only on the data, and split the k-sum into four ranges.

**Range A: k <= eps·m.** At most one J_i can exceed m/2, so

  P(S_k = m) = P(S_k = m, max <= m/2) + k E[h_{m - S_{k-1}}; S_{k-1} < m/2].

* **First term.** Apply (P1) with y = m/2, c = 0.8, lambda = 1.131 alpha/sqrt(m). If eps·mu <= 0.05, this is <= C e^{-1.07 alpha sqrt m}.
* **Second term.** For s < m/2, h_{m-s} <= sqrt(2) C_1 m^{-1/2} e^{-alpha sqrt m} e^{0.586 alpha s/sqrt(m)}. Also {S_{k-1} < m/2} ⊂ {all J_i < m/2}. With theta = 0.586 alpha/sqrt(m), we have theta j <= 0.42 alpha sqrt(j) there, so
  E[e^{theta S_{k-1}}; S_{k-1} < m/2] <= exp(k theta mu + k theta^2 V_{0.42}/2).
  Hence the second term is <= C k m^{-1/2} e^{-alpha sqrt m} exp(0.586 alpha mu k/sqrt(m)).
* **Summing.** Choose eps <= (alpha'/(1.18 alpha mu))^2. Then 0.586 alpha mu k/sqrt(m) <= alpha' sqrt(k)/2 on range A. So

  sum_{k in A} beta_k P(S_k = m) <= C m^{-1/2} e^{-alpha sqrt m} sum_k k^{1/2} e^{-alpha' sqrt(k)/2} + C e^{-1.07 alpha sqrt m}.

**Range B: eps·m < k < (1-eta) m/mu.** Put x := m - k mu in (eta m, m) and y := (1-delta) x.

* (P1) with c = 1 - delta, together with (P3), gives P(S_k = m) <= C(k+1) e^{-sqrt(1-delta) alpha sqrt x}. Here k/x <= 1/(mu eta) bounds the quadratic term.
* Put u = k mu/m in [eps·mu, 1-eta]. Strict concavity of sqrt gives
  alpha' sqrt(k) + alpha sqrt(x) >= alpha* sqrt(m)(sqrt u + sqrt(1-u)) >= alpha* sqrt(m)(1 + g),
  with g = g(eps, eta) > 0.
* Taking sqrt(1-delta)(1+g) >= 1 + g/2, range B contributes <= C m^{3/2} e^{-(1 + g/2) alpha* sqrt m}.

**Range C: |m - k mu| <= eta m.** Write x := m - k mu. Then beta_k <= C m^{-1/2} e^{-alpha' sqrt(m/mu)} e^{alpha' x_+/sqrt(m mu)}. Four cases:

* **x <= 0.** Use (P2) with lambda = |x|/(k v_2) <= 1, which holds for eta small. This gives (C/sqrt k) e^{-x^2/(2k v_2)}, and the sum over k is O(1).
* **0 < x <= x_0 := A (log m)^2.** Use (R): the O((log m)^2) terms contribute O((log m)^2/sqrt(m)).
* **x_0 < x <= eta m, no jump above x/2.** Use (P1) with c = 1/2, y = x/2 and lambda = min(x/(kV), alpha/sqrt(2x)). This gives (C/sqrt k)(e^{-x^2/(2kV)} + e^{-alpha sqrt(x)/(2 sqrt 2)}).
* **x_0 < x <= eta m, a jump above x/2.** By (P3) this is <= k C_1 e^{-alpha sqrt(x/2)}.

For eta <= (alpha sqrt(mu)/(4 sqrt(2) alpha'))^2 the tilt satisfies e^{alpha' x/sqrt(m mu)} <= e^{alpha sqrt(x)/(4 sqrt 2)}. The three resulting sums are then:

* O(1), a Gaussian sum with k ≍ m;
* O(m^{-1/2});
* <= C m sum_{x > x_0} e^{-alpha sqrt(x)/(2 sqrt 2)} = O(1) for A large.

So range C contributes <= C m^{-1/2} e^{-alpha' sqrt(m/mu)}.

**Range D: k mu > (1+eta) m.** Chernoff with lambda = eta mu/((1+eta) v_2) gives P(S_k <= m) <= e^{-c_eta k}. The sum is <= C e^{-c_eta m/mu}.

Adding the four ranges, c_m <= C m^{-1/2}(e^{-alpha sqrt m} + e^{-alpha' sqrt(m/mu)}) <= 2C m^{-1/2} e^{-alpha* sqrt m}. ∎

**Corollary 4.4.** For every L >= 2 and all gains, c^{(L)}_m ≍ m^{-1/2} e^{-alpha_L sqrt m} for all odd m >= 1, where

  alpha_L = min_{1<=l<=L-1} (pi/sqrt(q_l)) (mu_1 ... mu_{l-1})^{-1/2}.

*Proof.* Induction on L.

* L = 2 is Lemma 4.2 with q = q_1.
* For the step, apply Lemma 4.3 with h = c^{(L-1)} and beta = c(q_{L-1}).
  * h is a probability law on the odd integers with all coefficients positive (paper, Lemma 2.3 and Corollary 4.2).
  * Its mean is (F^{(L-1)})'(1) = mu_1 ... mu_{L-2}, by the chain rule and phihat(1) = 1.
  * beta ≍ by Lemma 4.2. ∎

**Theorem 4.5 (Lemma T, all depths).** Fix tanh, L >= 2 and gains. Then the conclusions of Theorem 3.2(ii),(iii) hold for the true pair masses W_j:

* c_T/sqrt j <= theta_j <= C_T/sqrt j for odd j in [j_0, D/4];
* W_i <= C_T W_{j+2} for all odd i >= j+2;

for D >= D_0, with constants depending only on L and the gains.

*Proof.* Let M := M_{alpha_L}, which is admissible. Lemma 4.1 gives c^M_m ≍ m^{-1/2} e^{-alpha_L sqrt m} for m >= 3. With Corollary 4.4 this gives K^{-1} c^M_m <= c^{(L)}_m <= K c^M_m for odd m >= 3. Apply Corollary 3.3 with m_0 = 3. ∎

**Numerical confirmation of Corollary 4.4.** The coefficients were composed exactly in double precision, all terms positive (`compose.c`), up to m = 8001. The quantity r_m := log c_m + (1/2) log m + alpha_L sqrt(m) is tabulated below.

| case | alpha_L | r_11 | r_101 | r_1001 | r_4001 | r_8001 |
|---|---|---|---|---|---|---|
| L=2, sigma_1=1 | pi | 3.396 | 3.661 | 3.741 | 3.759 | 3.764 |
| L=3 unit gains | pi | 3.862 | 3.775 | 3.813 | 3.825 | 3.828 |
| L=3, (sigma_1,sigma_2)=(1,3) (bulk regime) | 1.5367 | 1.102 | 1.184 | 1.218 | 1.226 | 1.228 |
| L=3, sigma_2^2 = 1/(mu_1 v_1) (tie) | pi | 4.665 | 5.118 | 5.092 | 5.095 | 5.096 |
| L=4 unit gains | pi | 4.076 | 3.833 | 3.851 | 3.858 | 3.861 |

The values of r_m converge in every case, including the case where the second layer's "many small jumps" mechanism sets the rate (alpha_3 = (pi/sqrt(q_2))/sqrt(mu_1) with mu_1 = 1.17781). With any other alpha the values would drift linearly in sqrt(m). The L=3 unit-gain coefficients agree with an earlier independent computation (`expd/physics/c_tanh_L3.npy`) to 4e-6.

## 5. Consequences listed in Lemma T

Let r be odd with j_0 <= r <= D/4, rho = r/d, and let C_T, c_T be as in Theorem 4.5.

**(C1)** d theta_r^2 <= C_T^2 d/r = C_T^2/rho.

**(C2)** s_{2,r} <= 2 C_T^2 theta_r lambda_{r+1} tau_r, and hence n s_{2,r}/tau_r^2 <= 2 C_T^2 (n/C(D,r+2)) theta_r^2.

*Proof.*

1. Pairing gives s_{2,r} = sum_{q>r} C(d,q) lambda_q^2 = A^2 sum_{odd i>=r+2} W_i a_i, with a_i = W_i/C(D,i).
2. For i = r+2+2k <= D/3: by (T2), a_i <= C_T W_{r+2}/C(D,i). Also C(D,r+2)/C(D,i) <= 1.9^{-2k}, since (l+1)/(D-l) <= 1/1.9 for l < D/3 and D large. So a_i <= C_T 3.61^{-k} a_{r+2}.
3. For i > D/3: a_j is nonincreasing in odd j (paper, Lemma 2.4(a)). So a_i <= C_T e^{-cD} a_{r+2}.
4. Therefore
   sum_i W_i a_i <= C_T a_{r+2}(C_T W_{r+2} sum_k 3.61^{-k} + e^{-cD} T_r) <= C_T a_{r+2} T_r (1.39 C_T theta_r + e^{-cD}).
5. Use theta_r >= c_T/sqrt(r) >> e^{-cD}, together with lambda_{r+1} = A a_{r+2} and tau_r = A T_r.
6. For the second statement, lambda_{r+1}/tau_r = theta_r/C(D,r+2). ∎

**(C3)** tau_r/tau_{r+2k} <= exp(2 C_T k/sqrt r) whenever r >= 4C_T^2 and r + 2k <= D/4 + 2.

*Proof.* tau_{r+2}/tau_r = T_{r+2}/T_r = 1 - theta_r. For theta <= 1/2, -log(1-theta) <= 2 theta. Sum over the k factors. ∎

**(C4, new)** theta_r >= c_T/sqrt(r). Since w_{r+2} = A W_{r+2}(d-r-1)/D, also w_{r+2}/tau_r ≍ r^{-1/2}. This is Theta(d^{-1/2}) at linear degree, as the lemma's CONSEQUENCE paragraph claims.

**Remark (the Tropp middle term).** Write K' = n/C(D,r+2). By (C1) and (C2),
  sqrt(n·2 log M·s_{2,r})/tau_r <= sqrt(4 log 2·C_T^2 K' d theta_r^2) <= 2 C_T^2 sqrt(K' log 2/rho).
This bound is independent of d at fixed (rho, K'), as the CONSEQUENCE paragraph claims. I checked only these two inputs. I did not re-derive the paper's Tropp-type Lemma 5.2 or its probability bookkeeping.

## 6. The sharp form: true at depth 2, false as stated at depth >= 3

**Theorem 6.1.** Let rho' := (j+2)/D and kappa(rho) = -(1/2) log(1-2rho).

* **(a)** Let M be admissible and delta_j := 2a/((1-2rho') sqrt(D kappa(rho'))). Then
  sup_{odd j in [J, D/4]} |theta^M_j/(1 - e^{-delta_j}) - 1| -> 0 as J -> inf, uniformly in D >= 4J.
  For L = 2, M = mu and 2a = pi/sigma_1. So the conjectured form
  theta_r = (1+o(1))(1 - exp(-pi/(sigma_1(1-2rho') sqrt(D kappa(rho')))))
  is **proved** at depth 2. Since delta_j -> 0, this is the same as theta_j ~ delta_j.
* **(b)** For L >= 3, suppose c^{(L)}_m ~ C_L m^{-1/2} e^{-alpha_L sqrt m} (asymptotic equivalence). Then the same holds with pi/sigma_1 replaced by alpha_L.
* **(c)** alpha_L ≠ pi/sigma_1 in general. For example, L = 3 with (sigma_1, sigma_2) = (1, 3) gives q_2 = 9 v_1 = 3.5486, mu_1 = 1.17781 and alpha_3 = 1.5367 < pi. So the sigma_1-form is **false** there: theta is asymptotically alpha_3 sigma_1/pi = 0.489 times the sigma_1-prediction (table in Section 7).
  * For unit gains at L = 3, 4, alpha_L = pi/sigma_1, because alpha_ℓ/sqrt(mu_1...mu_{ℓ-1}) = 4.61, 5.78 > pi. So the stated form is right there.

*Proof of (a).*

1. **Setup.** Take the reference point xbar := xbar_{j+2} and scale s := sqrt(xbar(1-xbar)/D). Put G(x) := log psi(xbar) - log psi(x). Then
   G'(x) = (D/(1-2x))(-(log M)'(tau(x)) - 2/D).
2. **Linearization on a window.** On |x - xbar| <= R s we have tau(x)/taubar = 1 + O(R/sqrt j). Then (A1),(A2) give
   G(xbar + s z) = g z + O((1 + R^2)/sqrt j)   for |z| <= R,
   with g := s G'(xbar) = a sqrt(rho(1-rho))/((1-2rho) sqrt(kappa(rho)))·(1 + o(1)), a bounded quantity.
3. **Beta CLT.** For i - j = O(N sqrt j), the Beta(i+1, D-i+1) law, recentred at xbar_i and scaled by s, tends to N(0,1) together with its exponential moments of bounded order, uniformly in i.
4. **The window dominates.** The parts of E psi(X_i) outside the window are <= eps psi(xbar) once R is large. This uses the sub-Gaussian Beta tails against the bound log psi(x)/psi(xbar) <= 5a|Z| + O(1) from Step 3 of Theorem 3.2.
5. **Each pair mass.** Let Delta_i := (xbar_i - xbar)/s. For j+2 <= i <= j+2+2N sqrt j,
   W^M_i = (D/(D+1)) psi(xbar) e^{g^2/2} e^{-g Delta_i}(1 + O(eps)).
6. **Ratios.** g Delta_i = G'(xbar)(xbar_i - xbar) = ((i-j-2)/2) delta_j (1 + O(j^{-1/2}) + O(D^{-1})). Hence
   W^M_{j+2k}/W^M_{j+2} = e^{-(k-1) delta_j}(1 + O(eps))   for k <= N sqrt j.
7. **Tail.** By Step 6 of Theorem 3.2, the terms with k > N sqrt j are a fraction <= C e^{-cN} of T^M_j.
8. **Conclusion.** Summing the geometric series, T^M_j/W^M_{j+2} = (1 - e^{-delta_j})^{-1}(1 + O(eps) + O(e^{-cN})). ∎

*Proof of (b).* Under the hypothesis, c^{(L)}_m/(C' c^{M}_m) -> 1 with M = M_{alpha_L}. Then Corollary 3.3 holds with K -> 1 for j >= m_0 -> inf, so theta_j/theta^M_j -> 1. Now apply (a) to M. ∎

The numerics in Section 4 support the asymptotic equivalence assumed in (b): r_m converges. It is not proved here. Lemma 4.3 gives only ≍.

## 7. Numerics

These are independent of the earlier five computations. Level masses were computed two ways, which agree to 1e-9:

* by (1.3) with M = mu (`levels_mu.py`, `theta_scan.py`);
* through the exact Ehrenfest-walk recursion (`walk_theta.py`).

**Table 7.1. L = 2, sigma_1 = 1.** Columns 2–5 give theta_j sqrt(j) at four values of rho; the ratio theta_j/pred(sigma_1) is in parentheses.

| D | rho=.05 | rho=.1 | rho=.2 | rho=.25 | range of theta sqrt(j), j in [D/log D, D/4] | max over i in [j+2, D/2] of W_i/W_{j+2} |
|---|---|---|---|---|---|---|
| 641 | 2.444 (.981) | 2.870 (.977) | 3.616 (.956) | 4.070 (.937) | [3.28, 4.07] | 1.0000 |
| 2561 | 2.891 (.991) | 3.265 (.987) | 4.075 (.974) | 4.624 (.962) | [3.47, 4.62] | 1.0000 |
| 10241 | 3.139 (.996) | 3.484 (.993) | 4.339 (.986) | 4.955 (.979) | [3.54, 4.96] | 1.0000 |
| 40961 | 3.268 (.998) | 3.599 (.997) | 4.482 (.992) | 5.139 (.989) | [3.56, 5.14] | 1.0000 |
| 163841 | 3.334 (.999) | 3.658 (.998) | 4.557 (.996) | 5.236 (.994) | [3.54, 5.24] | 1.0000 |

Observations:

* The limit of theta_j sqrt(j) at fixed rho is (pi/sigma_1) sqrt(rho)/((1-2rho) sqrt(kappa(rho))). This runs from pi at rho -> 0 to 5.34 at rho = 1/4. So the "[1.8, 4.4]" quoted in the task is exceeded at rho near 1/4 once D >= 2561. That does not affect (T1).
* The relative error of the sharp form is O(D^{-1/2}). It is 6.3% at d = 640 and 2.1% at d = 10240, at rho = 1/4.
* The (T2) ratio is exactly 1: the W_i are nonincreasing, as Theorem 3.2(i) predicts.
* A run at D = 655361 was discarded: its mu-grid under-resolves the t-integral.

**Table 7.2. Composites,** computed with exact coefficients up to m = 8001. Each cell gives theta sqrt(j) / [theta/pred(alpha_L)] / [theta/pred(sigma_1)].

| case | D | rho=.05 | rho=.2 | rho=.25 | theta sqrt(j) on [D/log D, D/4] | (T2) ratio |
|---|---|---|---|---|---|---|
| L=3 unit | 6001 | 3.063/.995/.995 | 4.256/.982/.982 | 4.849/.973/.973 | [3.52, 4.85] | 1.0000 |
| L=3 sigma=(1,3) | 641 | 1.384/.986/.555 | 1.991/.974/.526 | 2.265/.963/.522 | [1.80, 2.27] | 1.0000 |
| L=3 sigma=(1,3) | 2561 | 1.527/.994/.524 | 2.124/.986/.507 | 2.427/.979/.505 | [1.80, 2.43] | 1.0000 |
| L=3 sigma=(1,3) | 6001 | 1.576/.997/.512 | 2.172/.990/.501 | 2.488/.986/.499 | [1.80, 2.49] | 1.0000 |
| L=3 tie | 6001 | 3.065/.995/.995 | 4.256/.982/.982 | 4.850/.973/.973 | [3.53, 4.85] | 1.0000 |
| L=4 unit | 6001 | 3.063/.995/.995 | 4.256/.982/.982 | 4.849/.973/.973 | [3.52, 4.85] | 1.0000 |

Observations:

* (T1) and (T2) hold with small constants in every case.
* In the bulk-regime case the sigma_1-form is off by the factor alpha_3 sigma_1/pi = 0.489, approached as D grows. The alpha_L-form converges to ratio 1.

## 8. What is and is not established

**Proved.**

* Theorem 4.5, which is Lemma T with both bounds in (T1) and the full range in (T2), for all L >= 2 and gains.
* The listed consequences (C1)–(C3), plus (C4).
* The sharp form at L = 2 (Theorem 6.1(a)).
* Proof inputs:
  * L = 2: Bernstein's inequality and the one-dimensional Brascamp–Lieb inequality.
  * L >= 3: additionally the Kolmogorov–Rogozin inequality and Gnedenko's lattice LCLT.
* Everything else is proved in this note.

**Not proved.**

* (i) The sharp form for L >= 3 with alpha_L. It is conditional on c^{(L)}_m ~ C m^{-1/2} e^{-alpha_L sqrt m}, which numerics support.
* (ii) Explicit constants for L >= 3. They are not computed and would be huge.
* (iii) Anything about Lemma C (coercivity without the log factor) or Tropp's lemma itself. Lemma T removes the d-dependence from the middle term of the tail-Gram bound. It does not by itself give exp(Omega(d)).

**Differences from the intended proof idea.**

* Step 1 is made rigorous with strong log-concavity rather than Laplace's method. The u-density e^{Phi} is 4t-strongly log-concave and even. This gives the global bound -(log mu)' >= a/sqrt t and the bound <= a/sqrt t + B/t for t >= 1, with explicit B.
* (T2) comes for free from a monotone-likelihood-ratio argument: W_i <= W_{i'} + e^{-a^2 D}·D.
* For L >= 3 the "window-local subexponential lemma" is replaced by a global two-sided composition lemma (Lemma 4.3) plus comparison with an admissible profile (Corollary 3.3). This avoids any window-by-window bookkeeping. The crossover (tie) needs no special care, because both mechanisms give ≍ m^{-1/2} e^{-alpha* sqrt m}.
* The rate constant is min(alpha, alpha'/sqrt(E J)), as anticipated.

## 9. Files

All in /tmp/claude-0/-home-user-AI-works/5853d160-1439-5d10-be76-59b58f86c983/scratchpad/expd/deep1/:

| file | purpose |
|---|---|
| mu.py | mu(t) and its log-derivative pieces |
| check_identity.py | Lemma 2.1 check |
| check_mu_bounds.py | Lemma 2.2 checks |
| levels_mu.py | W_j by (1.3) |
| theta_scan.py | Table 7.1 |
| coefs.py | single-layer coefficients |
| compose.c | exact composition |
| walk_theta.py | Table 7.2 |
| walk_theta.out | output of walk_theta.py |
| theta_scan.out | output of theta_scan.py; ignore its D = 655361 row (Section 7) |
| lc_s*_N8001.npy, c*_*.bin | coefficient data |

