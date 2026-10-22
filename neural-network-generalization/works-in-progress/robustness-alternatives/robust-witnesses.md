# Cheap internally robust ReLU and GELU circuit witnesses

Research note, independently checked by a second AI agent, 22 October 2026. This note proves an expressivity and positive-support statement. It does **not** establish the quantitative all-width Gaussian cylinder needed for the finite-scale posterior theorem.

## Convention

Let a layered NOR/COPY/NOT circuit have `H >= 1` stages and at most `C >= 1` logical wires per stage, including one constant-one wire. Pad with zero logical wires if necessary. We implement each wire by two physical neurons, so the compiled width is `W=2C`. At any learner width `N >= W`, use balanced clone groups for these `W` physical neurons. Their sizes `k_j` satisfy

`C <= N/k_j <= 4C`.

The noisy network receives arbitrary additive postactivation vectors `eta_s` and scalar output noise `eta_out`, with

`r^2 = sum_{s=1}^H ||eta_s||_2^2/N + |eta_out|^2`.

Write `r_s=||eta_s||_2/sqrt(N)`. Each clone group has identical preactivation before its new injection, since incoming teacher weights average each preceding group. Therefore the next layer depends on the injected noise only through clone-group means. For the difference decoder of a pair, the absolute noise contribution is at most

`D_s = sqrt(8C) r_s`.

This follows from Cauchy–Schwarz and `1/k_+ + 1/k_- <= 8C/N`. It does not assume coordinatewise-small noise or discard individual clone outliers.

## ReLU construction and proof

Let `c` denote the decoded constant and `a,b` decoded inputs. Decode every physical pair by its first coordinate minus its second. Use these two preactivations:

| Logical operation | First preactivation | Second preactivation |
| --- | --- | --- |
| NOR(a,b) | `1.5 c - 2a - 2b` | `.5 c - 2a - 2b` |
| COPY(a) | `2a - .5 c` | `2a - 1.5 c` |
| NOT(a) | `1.5 c - 2a` | `.5 c - 2a` |
| constant | `1.5 c` | `.5 c` |

Apply ReLU coordinatewise. At the first layer take `c=1` and input bits `(1+x_i)/2`.

For `c>0`, the NOR decoder equals `c` when `a+b<c/4`, and equals zero when `a+b>3c/4`. The COPY decoder equals zero for `a<c/4` and `c` for `a>3c/4`. NOT has the complementary plateaus. The constant decoder equals `c` exactly.

Let `c_s` be the noisy decoded constant after stage `s`, with `c_0=1`. If the gates are on their plateaus, then

`c_s=c_{s-1}+delta_{c,s}`,

`b_s=c_{s-1} b_s^ideal + delta_{b,s}`,

where each displayed delta has absolute value at most `D_s`. Consequently

`|c_s-1| <= sqrt(8CH) r`,

and every decoded bit differs from `c_s` times its ideal bit by at most `2D_s`. The latter error does not accumulate through depth.

Take

`r_ReLU = 1/(64 sqrt(CH))`.

Then `|c_s-1| <= sqrt(8)/64 < 1/8`. A NOR's incoming sum differs from the corresponding ideal sum of zero, `c`, or `2c` by at most `4D_{s-1} <= sqrt(8)/16 < c/4`. COPY and NOT require a weaker inequality. Thus the plateau assertions hold inductively at every stage. The first stage has exact incoming bits.

Read out `z=2 b_out-c_H`, combining coefficients if the output is the constant wire. Including scalar output noise, the signed output is at least

`1 - (4 sqrt(8)+1)/64 > 3/4`.

Every pre-injection physical hidden activation is at most 2 in magnitude on this noise ball, by the same plateau-region bounds. Hence its post-injection hidden RMS is at most `2+r_s < 3`, uniformly in width and input. One may use the strict envelope `R=4` for an open support condition.

## Energy and calibration

After expanding the pair decoders, every internal weight has magnitude at most 4. A first-layer physical row has squared norm at most 16, allowing gate inputs that are themselves constant wires. An internal base row has squared norm at most 40, including repeated gate inputs. The base readout squared norm is at most 10 and at least 2. Balanced cloning preserves rowwise computations and multiplies each internal squared-Frobenius cost by at most 2. Therefore the normalized Gaussian energy obeys the conservative bound

`kappa_N <= 16d + 160(H-1)C + 40C`,

and the readout energy satisfies

`2C <= E_v=N||v||_2^2 <= 40C`.

In particular, the data-independent reference radius

`r_ref(w)=.01/sqrt(1+H E_v(w))`

is less than the certified `r_ReLU` at every cloned witness. The clean output is exactly the target sign, and the perturbed signed output remains above `3/4`.

## GELU construction

Let `phi(t)=t Phi(t)` and fix the universal gain `k=1000`. The elementary identities

`phi(t)-phi(-t)=t`,

`D:=sup_t |phi(t)-ReLU(t)| < 1`

are sufficient.

For each logical gate, multiply the two ReLU preactivations in the table by `k`, apply GELU, and decode the physical pair difference divided by `k`. This approximates the ReLU gate decoder uniformly by at most `e=2/k=.002`. For the constant wire use the pair with preactivations `kc,-kc`; its decoder is exactly `c`, including away from Boolean inputs. All subsequent preactivations are ordinary linear combinations of preceding physical neurons: the incoming factor `k` cancels their decoder factor `1/k`. Thus only first-layer weights acquire the large constant factor `k`; internal coefficient bounds remain universal.

Now `D_s=sqrt(8C) r_s/k`. The constant still accumulates only the deltas, while the bit error relative to the new constant is at most `e+2D_s`. Use

`r_GELU = min{1/64, k/(64 sqrt(CH))}`.

The NOR plateau test for the ReLU comparison is `2e+4D_{s-1}<c/4`, which holds since its left side is at most `.004+sqrt(8)/16`, whereas `c >= 1-sqrt(8)/64`. COPY and NOT again require less. This proves the induction despite approximate GELU gate outputs. The final signed output, including scalar output noise, is at least

`1 - (4 sqrt(8)+1)/64 - 2e > 3/4`.

A conservative hidden RMS envelope is `R=5k`. Indeed the corresponding ReLU positive preactivations are bounded by 2, GELU differs from ReLU by less than 1, and the postactivation injection adds at most `r_s` to RMS.

The conservative energy and readout estimates become

`kappa_N <= 16k^2 d + 160(H-1)C + 40C/k^2`,

`2C/k^2 <= E_v <= 40C/k^2`.

The same reference radius `.01/sqrt(1+H E_v)` is at most `.01` and at most `.01 k/sqrt(2CH)`, hence lies inside `r_GELU`. Thus the general Boolean-function guarantee survives at the same circuit depth and width `2C`, with universal (albeit loose) constants. Unlike the ReLU clean decoder, the GELU clean logits need not equal the ideal signs exactly; their signs and strict margins are sufficient.

## What follows, and what does not

At each fixed finite width, the finite input set and compact disturbance ball make the robust minimum margin and maximum hidden RMS continuous in weights, including a continuously varying reference radius. The strict margins and envelope slack above therefore give an open neighborhood of every witness satisfying the robustness-plus-envelope condition. Every nondegenerate Gaussian prior gives this neighborhood positive probability. The witness has polynomial energy independent of learner width.

The companion [internal-noise learning note](internal-noise.md) establishes the needed capacity theorem and obtains learning in the strong-prior limit and at every `gamma>=2`. At those stronger scales, a full weighted parameter ball also gives the required quantitative target mass.

The present witness construction alone does **not** give a lower bound of the form `exp[-N poly(d,C,L)/t^2]` on its neighborhood uniformly over arbitrary `N` at mean field. There, constraining all `N^2` coordinates in a small ball is too expensive for the current raw-mass comparison. The old merging cylinder permits an unconstrained Gaussian bulk that annihilates clean population states but can act on adversarial non-population perturbations. Extending the robustness guarantee to enough of that bulk is a separate probabilistic theorem.
