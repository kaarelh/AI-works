# Independent audit: finite-width circuit target mass

Auditor: depth_continuous_lower. Date: 2026-10-18.

Reviewed source:
`source/critical-finite-width-circuit-mass.tex`
SHA256: `819552663e729f3ca144cb1a38fc60e6a497df6b587a2a7bb7ddafd1ca631353`.

Dependencies checked at their interfaces:

- `source/critical-finite-width-circuit-prefix.tex`, final SHA256 `4de365738a40063f994336c130d703533ba6c43429cd0c91af4c9486ef21a628`. The underlying lemma has separate independent audits by depth_critical and depth_memorization.
- `source/critical-finite-width-channel.tex`, including its approximate-prefix corollary. I independently reconstructed its score/residual projection metric, entropy distortion, concentration, and event-relative-entropy conversion; the complete source has additional independent reviews.
- Existing scalar steering after an arbitrary positive constant diagonal and the square-root entropy occupation bound.

## Verdict

Pass. No substantive mathematical gap or scope correction found.

## Checks

1. **Actual finite-prefix interface.** The prefix produces an exact unit score direction. Its score coefficient and residual standard deviation differ from the ideal pair `(sqrt(p) f, sqrt(qbar_h-p))` by at most `sqrt((2h+4) eta)`. The ideal residual is nonnegative, and the ideal total diagonal is at most one. The quantities p and qbar may depend on N; all later estimates are uniform in the stated range.

2. **Remaining depth.** There are exactly M=L-h-1 remaining hidden layers. Since T>=h log(h+2), a sufficiently large universal depth constant in L-h>=c0 T ensures both M>=L/2 and enough space for the scalar construction. In particular the replacement of its remainder denominator by L loses only a universal factor.

3. **Rarity and accuracy are self-consistent.** With a=KT, eta=8exp(4-KT), the seed rarity satisfies log(1/p)<=C(1+log K)T. The estimate h log T<=2T was checked separately. The continuation's tracked components, score bound, and entropy distortion therefore have exponents only C(1+log K)T. Choosing one fixed universal K large enough solves the required seed metric inequality; the depth constant may then be enlarged to fit the resulting continuation. There is no dependence of K on the teacher or the width.

4. **Tracked-component floor.** Cooling retains a polynomial factor in the cooling scale, the holding component is delta exp(-C S0), and delta is at least c/L. Prescribed growth and purification retain that floor. The final increasing scalar path starts at a scale at least c/L, and its stable lifting loses only a universal factor after purification. Since S0 already includes log(L+2), all score bounds are exp(O(S0)).

5. **Square-root entropy after the prefix.** The scalar suffix estimate does not require that its initial covariance be the raw first-layer covariance. Its initial scalar state is at most one. The Bellman suffix lower bound and total action give the same prefix budget used in the occupation proof; with epsilon=(A-V*)_+, this remains valid even if A-V* is negative. Thus the continuation entropy distortion is O(log L+sqrt(L(A-V*)_+))=O(S0). The stated D_j may be upper bounds on the actual entropies: dissipation and the action budget remain valid.

6. **Failure probability and width.** The prefix may be required to fail with probability at most kappa/4, where kappa has a uniform exp(-O(T)) lower bound. Its concentration condition and the continuation's explicit width condition are both satisfied by N>=exp(c1 T). The cube union contributes log|X|=d<=exp(T), not |X|.

7. **Raw-prior probability.** The approximate-prefix channel corollary applies without conditioning the constructed law on its good event. Its entropy includes the prefix N/(8L). Final event success is 1-O(kappa), so binary relative entropy yields the raw target mass exp(-N(A+1/L)). The final 1/L is absorbed into c2 T^2/L. The argument does not modify the prior support or use a width limit.

8. **Scope.** This is a quantitative target-event probability theorem. The actual learning conclusion additionally uses the independently proved collective exceptional-mass/capacity theorem and the small-width VC patch. Dependence on teacher depth remains exp(O(T)); the result does not settle a joint polynomial bound in arbitrary teacher width and teacher depth.
