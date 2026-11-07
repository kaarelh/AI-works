# Independent audit of the triangle-wave weighted atomic theorem

Audited 7 November 2026 by the `new_lens` research agent. Source: `../fresh_full/TRIANGLE-WEIGHTED-ATOMIC-NORM.md` as read during the audit. This is AI mathematical review, not formal verification.

**Verdict:** the stated exact atomic inequality, equality classification, and resulting variation norm on the code span check. This does not certify exclusion of non-code globally valid completions or an online theorem.

The following points were checked independently.

* Reducing each parameter modulo two preserves the entire cube ridge up to one output sign and decreases Euclidean norm. Equality cannot survive a strict reduction.
* The positive harmonic coefficients sum to one. The identities `sum alpha_n sin²(nπu/2)=u` and `sum alpha_n sin²(nπu/2)cos²(nπu/2)=min(u,1-u)/2` hold for `0<=u<=1`. They imply the fourth-power bound and the low-norm strict gap.
* The first-harmonic localization is numerically sound. From `L>0.9/sqrt(1.01)` and the actual `alpha_1=8/pi²`, one obtains `P>0.8711`, hence `P>0.87`. It is preferable to state `alpha_1>0.81` here: the weaker displayed fact `alpha_1>0.8` alone is insufficient with the coarsened decimal lower bound on `L`.
* If `sqrt(a)+sqrt(b)<=1`, `a>=b`, and `a+b>0.87`, then `a>0.865116...`. The estimate `b<=0.269(1-a)²` follows. The logarithmic inequality (3) follows, for example, from `log(1+b/a)<=b/a` and `-log a>=1-a` on `a>=0.865`.
* The dominant-product logarithm gives `rho²<0.119`. A block of size at least four has nondominant product at most `(π⁴/256)rho_j⁴`; the extra coordinates only reduce that product. The stated estimate `log P<=-1.17rho²` and hence `1-P>=rho²` hold throughout `rho<=0.35`.
* In the absolute-linear-form lemma, `N_t<=D_t` holds for every frequency, including frequencies where cosine factors change sign. Indeed `N_t<=1-|cos(tδ_0)product_i cos(tδ_i)|<=D_t`. Thus restricting the integral of their nonnegative difference to `t rho<=1` is legitimate.
* On that interval all cosines are positive. The two estimates `D_t>=(1-e^(-1/2))t²rho²` and `N_t<=t⁴rho⁴/16` are valid. Their integral gives `gamma=(2/pi)(1-e^(-1/2)-1/16)>0.21` with no missing factor.
* In the final small neighborhood, Cauchy–Schwarz bounds the full pointwise perturbation below `1.33<2`. The exact local identity at every odd triangle peak therefore holds simultaneously on the entire cube. Multiplication by the dominant core character permutes the quotient characters, so the projection-gap lemma applies exactly as stated.
* `gamma sqrt(c+D)-Delta>1` follows comfortably from `c>=1000` and `Delta<=0.05`. This gives the strict final inequality whenever `rho>0`.

The proof covers the stated domain consisting of the core and control blocks. Arbitrarily many additional physical coordinates would require revisiting the final pointwise perturbation bound; that extension is not needed for the stated theorem.
