# Polynomial-depth learning from internal-noise robustness and bounded noisy activity

Research derivation, 22 October 2026. This is a proposed natural alternative to neuron-merging stability. The condition is about internal perturbations and activity, not compressibility. The results below give a polynomial-depth learning bound for ReLU, and for exact GELU using its one-parameter rescaling family. The dependence on Boolean teacher width is roughly sixth power, not quadratic. The proof covers the strong-prior limit and every Gaussian exponent gamma at least two. The mean-field and intermediate finite-scale target-mass question remains open.

## 1. The prior restriction

Write H=L−1 and use Boolean inputs x in {−1,1}^d with a constant input coordinate. Hidden layers have common width N, activation phi, and a linear readout v. Assume phi(0)=0 and Lip(phi)≤lambda, with lambda≥1. Let

```text
kappa = (d/N)||W1||_F² + sum_{s=2}^H ||Ws||_F² + N||v||²,
Ev = N||v||²,
||eta||_*² = sum_s ||eta_s||²/N + |eta_out|²,
r(w) = c/sqrt(1+H Ev),       c=1/100.
```

Disturbances eta_s are added after each hidden activation. Let T clip the scalar output to [−1/2,1/2]. Fix R≥sqrt(2). The prior retains networks satisfying all three conditions:

1. `|z_w(x)|>1/2` at every input.
2. For every input and every disturbance with `||eta||_*≤r(w)`,
   `|T(z_w(x;eta))−T(z_w(x;0))|≤1/16`.
3. Under those same disturbances, every hidden state, **including its additive disturbance**, has RMS at most R:
   `||h_s(x;eta)||_2/sqrt(N)≤R`.

These are label-independent conditions on the network. The third condition is a bounded-activity condition on a perturbation neighborhood. It allows individual neuron values as large as order sqrt(N); it does not assume a coordinatewise activation cap. This distinction is essential.

The Gaussian prior is conditioned on this support, and training then conditions on exact signs. The theorem below does not assert that ordinary gradient descent typically satisfies this support restriction.

## 2. Clipping is a proof device and changes none of the allowed noisy computations

Fix an admissible network. For each neuron define the deterministic envelopes

```text
a_i^1 = lambda sqrt(d+1) ||W_i^1||_2,
a_i^s = lambda R sqrt(N) ||W_i^s||_2     (s>=2).
A_s² = (1/N) sum_i (a_i^s)².
```

Replace the activation at neuron i in layer s by phi followed by clipping to [−a_i^s,a_i^s]. For any fixed allowed disturbance, this modified network agrees exactly with the original network, including all hidden states. Indeed, the first-layer bound follows from Cauchy–Schwarz. At every later layer the preceding original noisy state has RMS at most R, so the pre-disturbance activation lies in the stated interval. Induct on layers, using the same injected disturbances in both networks.

Thus the clipped network inherits the original clipped-output stability on the full radius-r(w) noise ball. Clipping is not an additional condition on the prior. It is a consequence of the existing noisy-RMS envelope.

Rows with a_i^s=0 compute zero before disturbance and can be omitted from sampling. A globally margin-separated zero-at-zero network has A_s>0 at every layer.

Normalize neuron i by a_i^s. Its new activation is

```text
psi_a(t) = clip(phi(a t)/a, -1, 1).
```

It is lambda-Lipschitz, vanishes at zero, and has absolute value at most one. The normalized incoming weights are W_i^1/a_i^1 initially and W_ji^s a_i^{s-1}/a_j^s subsequently; the readout is v_i a_i^H.

## 3. An importance-sampling compressor

Suppose kappa≤K, K≥1. Put k_1=(d/N)||W1||_F², k_s=||Ws||_F² for 2≤s≤H, and k_L=Ev. Define

```text
S = 1 + sum_{s=2}^H A_{s-1}² k_s + A_H² Ev,
Q = 1 + K + S.
```

Since R≥sqrt(2),

```text
A_1² = lambda² (d+1) k_1/d <= lambda² R² k_1,
A_s² = lambda² R² k_s                       (s>=2),
S <= 1 + lambda² R² K².
```

For any radius 0<r≤r(w), the compressed width may be taken to be

```text
m = ceil(256 lambda² S r^(-2) [d+log(400L)]).
```

**Compression claim.** There is an actual width-m network using the normalized clipped activations above, with normalized energy at most 4Q, whose clipped output differs from the original by at most 1/16 on the whole Boolean cube.

### Sampling and pruning proof

At each hidden layer independently sample m source indices with probabilities

```text
p_i^s = (a_i^s)²/(N A_s²).
```

Let q=r/lambda. For each internal row in layer s, prune entries for which

```text
|W_ji^s|/a_i^{s-1} > 8 sqrt(S) ||W_j^s||_2 / (q sqrt(N) A_{s-1}).
```

Zero-envelope sources contribute zero and are omitted. The discarded weighted absolute row mass is at most the row squared norm divided by the threshold. Consequently, for any preceding normalized vector g with |g_i|≤1, the physical pruning error has normalized Euclidean norm at most

```text
q A_{s-1} sqrt(k_s/S)/8.
```

For the readout use the same formula with row v, source envelope A_H, and the threshold `8 sqrt(S)||v||/(q sqrt(N) A_H)`. Its scalar pruning error is at most `q A_H sqrt(Ev/S)/8`.

For an internal layer, a one-sample full-destination physical vector is

```text
Y_j = Wbar_{j,I} a_I g_I / p_I.
```

Conditional on all earlier source lists, the current full virtual state is independent of the fresh source list. Its coordinates remain bounded by their envelopes because the activation is clipped. The variance and centered norm obey

```text
E||Y−EY||² <= N A_{s-1}² k_s,
||Y−EY|| <= 16 sqrt(N) A_{s-1} sqrt(S k_s)/q.
```

Hilbert-space Bernstein at tolerance `q sqrt(N) A_{s-1} sqrt(k_s/S)/8` therefore bounds failure by `2 exp[-m q²/(256S)]`. The readout calculation is identical without sqrt(N). This is the same dimension-free Bernstein inequality used in the original bounded-activation compressor; the variance and maximal-summand terms give exponent at least `3m q²/(640S)`.

A union bound over all 2^d inputs and at most L stages has failure probability less than 1/200. On success, pruning and sampling together have physical preactivation errors at most `q A_{s-1} sqrt(k_s/S)/4` in normalized Euclidean norm. Apply the lambda-Lipschitz clipped activations. Define a postactivation disturbance as the difference between the virtual state and the original clipped layer applied to the previous virtual state, with the analogous scalar readout disturbance. Their total norm is at most r/4, since

```text
sum_s ||eta_s||²/N + |eta_out|²
  <= (r²/(16S)) [sum_{s=2}^H A_{s-1}² k_s + A_H² Ev]
  <= r²/16.
```

The clipped network agrees with the original on this allowed disturbance and is score-stable. This proves the output approximation. There is no assumption that the recursively sampled states of the original unbounded activation stay bounded: clipping first makes that statement true, and the noisy-RMS hypothesis justifies clipping afterward.

The stored sampled coordinates form an ordinary finite network. For destination j and source i its internal coefficient is

```text
Wbar_ji a_i/(a_j m p_i).
```

Independent source lists in adjacent layers give the following expected normalized energies:

```text
first layer: k_1/A_1² <= 1,
internal layer s: (A_{s-1}²/A_s²) ||Wbar_s||_F²
                  <= A_{s-1}²/(lambda² R²),
readout: A_H² Ev.
```

Their sum is at most `1+K+S=Q`. Markov's inequality gives energy at most 4Q with probability at least 3/4. Intersect this with the all-input approximation event. This establishes the claimed compressor and the cancellation of every factor of the original learner width N.

## 4. Polynomial-depth finite coding for ReLU and GELU

For ReLU, the normalized clipped activation is the same at every neuron:

```text
psi_a(t)=min(1,max(0,t)).
```

There are no extra activation parameters. For GELU it is the one-parameter family

```text
psi_a(t)=clip(t Phi(a t),-1,1),    a>0.
```

On an interval |t|≤U, this family has a supremum-error eta net whose cardinality is polynomial in U and eta^(-1), so its **logarithmic** cardinality is `O(log(2+U/eta))`. To verify this, small a≤eta/(4U²) is uniformly eta-close to `clip(t/2)`, while large a≥4/eta is uniformly eta-close to clipped ReLU because `sup_t|GELU(t)−ReLU(t)|<1`. On the remaining interval, differentiation in log(a) gives

```text
|d[t Phi(a t)]/d log(a)| = |a t² phi_normal(a t)| <= U.
```

A log(a)-grid of mesh eta/(4U), plus the two limiting activations, has at most

```text
2 + O((U/eta) log(2+U/eta))
```

members. Clipping preserves the approximation and the common Lipschitz/absolute-value bounds. The limiting activations may be used for finite coding; they are not added to the Bayesian prior.

For an energy cutoff K set

```text
r_0 = c/sqrt(1+H K),
S_0 = 1 + lambda² R² K²,
Q_0 = 1 + K + S_0,
m_0 = ceil(256 lambda² S_0 r_0^(-2) [d+log(400L)]),
B = 8 sqrt(m_0 Q_0),
A = 2 + lambda(d+1+m_0)(B+1),
eta = 1/[128 (H+1) A^(H+1)],
U = (d+1+m_0)(B+1).
```

Use m_0 rather than the smaller network-specific sampling budget in the previous section. The concentration and energy arguments remain valid. Since the original output has global margin greater than 1/2, the compressed output has signed margin at least 7/16. Double its readout, giving signed margin at least 7/8. The displayed B bounds every resulting coordinate.

Round weights with coordinate error at most eta, retaining a bound B+1. For GELU also replace each normalized clipped activation by an eta-approximate member of its finite net on [−U,U]. All hidden outputs remain in [−1,1], and all relevant preactivations lie in that interval [−U,U]. A direct layer recursion gives final output discrepancy at most `(H+1) eta A^(H+1)≤1/128`, hence preserves the strict signs with substantial margin.

With

```text
P = m_0(d+2)+(H−1)m_0²,
log M_act = 0 for ReLU,
log M_act = O(log(2+U/eta)) for GELU,
H_code(K) = P log(3+4(B+1)/eta) + H m_0 log M_act,
```

all supported globally margin-separated functions of energy at most K, across all learner widths, belong to one finite class of logarithmic cardinality at most H_code(K).

The widths, energies, coefficient bounds, and **logarithmic coding costs** are polynomial in d,L,K,R,c^(-1),lambda, up to explicit logarithms. The grid precision eta may be exponentially small in depth; only log(1/eta) enters the code length, including for the one-parameter GELU activation cover. In particular

```text
m_0 = O(lambda^4 R² c^(-2) L K³ [d+log L]),
H_code(K) = O_tilde(lambda^8 R^4 c^(-4) L^4 K^6 [d+log L]²)
```

when the other elementary terms are dominated; the exact finite-code formula should be used in boundary cases. This is a C^6-type result for teacher energy linear in C, rather than C². It has no exponent that grows with depth.

This coding argument is specialized to ReLU/GELU. An arbitrary Lipschitz activation produces an infinite-dimensional normalized activation family, whose generic cover can be exponentially expensive in depth. The broader all-Lipschitz fixed-depth theorem does not resolve that issue.

## 5. Cheap Boolean witnesses and strong-prior learning

The independently derived paired-channel construction in [robust Boolean implementations](robust-witnesses.md) implements a layered NOR/COPY/NOT circuit of width C and H stages at the same depth, with two physical neurons per logical wire. Balanced cloning works at every N≥2C, including nonmultiples of 2C.

For ReLU, a decoded bit is the difference of two physical neurons. NOR uses preactivations `1.5c−2a−2b` and `.5c−2a−2b`; COPY uses `2a−.5c` and `2a−1.5c`; the constant uses `1.5c,.5c`. These decoders have plateaus around the Boolean inputs. Group-mean injected errors perturb each decoded bit by at most `sqrt(8C) r_s`; bit errors reset at the next gate, and the constant rail accumulates only the sum of its noises. Thus total noise radius `1/(64 sqrt(CH))` leaves signed output above 3/4 and every noisy hidden RMS below 3.

The witness satisfies

```text
kappa <= D_teacher := 16d +160(H−1)C+40C,
2C <= Ev <=40C.
```

At the reference radius c/sqrt(1+H Ev), c=.01, it has strict robustness slack: both clean and noisy clipped outputs equal f/2, and noisy hidden RMS is less than 3. Choose prior envelope R=4.

For GELU, fix k=1000, multiply the two ReLU preactivations by k and decode their GELU outputs divided by k. Gate error is at most 2/k and resets at each stage. Use the exact constant identity `GELU(kc)−GELU(−kc)=kc`. The same-depth width-2C witness has

```text
D_teacher <=16 k² d +160(H−1)C+40C/k²,
2C/k² <=Ev<=40C/k²,
signed noisy output >3/4,
noisy hidden RMS <5k
```

on radius `min{1/64,k/(64sqrt(CH))}`. The same reference radius lies inside this ball. Use prior envelope R=6k and lambda=2. The constants are large but universal.

At every fixed N these witnesses are interior points of the support: the input set and disturbance ball are compact, the noise radius varies continuously with parameters, and all inequalities have strict slack. Their energy is bounded independently of learner width.

**Strong-prior theorem.** For ReLU or exact GELU, with the fixed support parameters just specified, there is a sample bound polynomial jointly in d,L,C,1/epsilon,log(1/delta), independent of learner width, for every N≥2C in the Gaussian strong-prior limit. One may use a finite-class bound of order

```text
n >= (2/epsilon)[H_code(2D_teacher+1)+log(1/delta)].
```

Indeed an open ball around the target has small-variance Gaussian rate at most D_teacher. At each fixed N, the raw energy tail above `2D_teacher+1`, divided by this target mass, tends to zero. The same holds after support normalization and any noiseless training conditioning, since the target remains consistent. The finite class handles the retained functions on a single sample event independent of N. The required small positive variance threshold may depend on N.

## 6. Finite scales gamma>=2: full weighted balls are cheap enough

Use weighted parameter coordinates

```text
u = (sqrt(d/N) W1, W2,...,WH, sqrt(N) v).
```

Their squared Euclidean norm is kappa. Under the Gaussian conventions in the main papers, every coordinate has variance `sigma²=t²/N`; the parameter dimension is

```text
p=N(d+2)+(L−2)N².
```

For gamma≥2 one has `sigma²=N^(−gamma)≤N^(−2)`, and therefore

```text
p sigma² <= d+L =: V.
```

There is a weighted Euclidean ball around each witness, of radius rho independent of N, entirely in the prior support and entirely realizing f. Moreover `log(1/rho)=O(L log(2+C+L))` for ReLU, and the same with universal k-dependent constants for GELU.

Here are explicit sufficient choices. Let R_teacher=3 for ReLU and 5k for GELU; let b=sqrt(160C), b_v=sqrt(40C) for ReLU and sqrt(40C)/k for GELU; set

```text
S_b=1+lambda(b+1),
E_b=lambda(2+R_teacher H) S_b^(H−1),
rho=min{1/(4k_0), 1/[32((b_v+1)E_b+R_teacher)],
                    (R−R_teacher)/(4E_b)},
k_0=1 for ReLU, k_0=k for GELU.
```

A weighted perturbation of size at most rho has first-layer RMS output error at most lambda sqrt(2) rho, each internal operator perturbation at most rho, and scaled readout perturbation at most rho. Its readout energy is at least C/k_0². Thus its reference noise radius stays within the witness's certified noise ball. Compare the perturbed and witness networks under the same arbitrary allowed noise. The hidden RMS differences satisfy

```text
e_1<=lambda sqrt(2)rho,
e_s<=lambda(b+1)e_{s−1}+lambda R_teacher rho,
e_s<=rho E_b.
```

The output difference is at most `rho[(b_v+1)E_b+R_teacher]≤1/32`. All perturbed signed outputs stay above 1/2 and every hidden RMS is strictly below R. Clean and noisy clipped outputs therefore agree exactly. This proves the whole ball is admissible, with uniform slack.

Let `c_G=2/(e sqrt(2pi))` and define

```text
D_mass = D_teacher + V log[c_G^(-1) max{1,sqrt(V)/rho}].
```

Inside the ball constrain each weighted coordinate to its center plus an interval of half-width `sigma min{1,rho/(sigma sqrt(p))}`. For a standard Gaussian scalar and any center, integrating the density on such an interval yields the product lower bound

```text
mu(target ball) >= exp[-D_mass/sigma²].
```

In detail, the negative logarithm times sigma² is at most the center's squared norm plus `p sigma² log[c_G^(-1) max{1,sigma sqrt(p)/rho}]`; use `p sigma²≤V`.

Since kappa has law `sigma² chi-square_p`, its moment generating function at `1/(4sigma²)` gives

```text
mu{kappa>K}/mu(target ball)
 <= exp{-[K/4−D_mass−V log(2)/2]/sigma²}.
```

Take

```text
K = 4[D_mass+V log(2)/2+log(2/epsilon)].
```

Because sigma²≤1, this ratio is at most epsilon/2, simultaneously at every N≥2C and every sigma²≤N^(−2). Support normalization cancels, and the bound remains valid after any noiseless training sample. A single finite-class sample event therefore gives

```text
n >= (2/epsilon)[H_code(K)+log(1/delta)]
```

as a sufficient sample bound for posterior-average sign error at most epsilon, simultaneously over all these widths and scales. Use epsilon/3 for a posterior-correct-label probability strictly greater than 2/3 except on a test set of mass at most epsilon.

The resulting bound is polynomial jointly in depth and width, with a C^6-type leading dependence up to logarithms. It does not require neuron merging or a low-rank witness in the support definition.

## 7. Remaining gap and naturality

The strongest completed conclusion here is the strong-prior limit and gamma≥2, not the entire gamma≥1 regime. For 1≤gamma<2, the full weighted ball pays for `p sigma²` of order `N^(2−gamma)`, which is not width-independent. An open robust target neighborhood does not fix this.

The earlier merging-cylinder argument leaves an unconstrained Gaussian bulk acting on directions orthogonal to clean clone populations. That bulk annihilates the clean teacher states but can act on the adversarial internal disturbances in this support condition. Proving that enough of this bulk preserves internal robustness and the RMS envelope is the missing quantitative target-mass theorem. It cannot be assumed from exact-witness robustness or positive support.

Bounded noisy activity and stable predictions under internal disturbances are direct network properties one might study independently of these learning proofs. They are still assumptions: no empirical claim about standard trained networks has been established here. The fixed reference radius also becomes smaller when readout energy increases; both that calibration and the required all-input guarantee deserve scrutiny. The result supplies a concrete alternative with an honest worse width polynomial, not evidence that the quadratic theorem follows from any generic robustness notion.
