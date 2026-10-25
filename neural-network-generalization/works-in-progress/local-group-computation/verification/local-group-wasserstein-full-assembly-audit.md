# Independent full-assembly audit: local group Wasserstein manuscript

25 October 2026. Auditor: posterior-quantifier/independent-routes subagent.

Audited source: `manuscripts/local-group-wasserstein.tex`.

* TeX SHA-256: `18c586f66f7d13fa759f637521eb8f1b7b504755a6dbeca20a52979049823776`.
* PDF SHA-256: `9764d0238b4b424358c2302a86d239f1ecb8dfd5413fdf688bcb5a63beb8142b`.

Verdict: **PASS on the mathematical proof and all displayed constants under the intended physical architecture. One minor architecture-definition clarification is requested before treating the standalone statement as fully explicit.** No mathematical counterexample or substantive proof gap was found.

## Definition clarification

The bands should explicitly form an ordered partition of all actual matrix layers before the final readout. The current source says each band is a nonempty consecutive set of physical layers, but does not expressly forbid reusing a layer or leaving an intervening layer unaccounted for. The final multiplication of the band estimates into P_F requires disjoint exhaustive charging. This was explicit in the scratch formulation and is clearly the intended model; adding one sentence resolves the formal ambiguity.

Optionally specify C_0>0 and K>=0 in the early-large-block corollary, as is usual for its polynomial upper-bound notation.

## Proof checks

1. **Architecture and scope.** Contiguous coarsening partitions, first-layer child-code access, disjoint variable channels, nonempty actual bands, charged carries, and shared input-independent constants are sufficient. Constants can be frozen as biases for difference estimates. Zero preservation is unnecessary. Arbitrary code dimensions, retained histories, and fixed-seed features are legitimately covered. Interleaved noncommutative subwords and uncharged bypasses are correctly excluded.

2. **Conditional coupling.** Given the parent product, all other complete child subwords retain their unconditional joint distribution, because the missing child product is independent uniform. The required missing product is L^(-1)aR^(-1). Shared other words plus an optimal missing-child code coupling give the stated parent coupling. Averaging the pair (a,b) removes the fixed left/right translations exactly. This does not require product-state encodings or a decoder.

3. **Root constant.** Opposite-label ordered product pairs have probability 2p(1-p). Their root code supports are at least 2/||v|| apart under every coupling. The defining factor 1/2 gives a_root^2>=4p(1-p)/||v||^2, exactly as stated. A nonconstant margin target forces v!=0. Positivity then propagates to every signal used in denominators.

4. **Physical Frobenius charging.** The first-matrix partition and common suffix give P_u^2>=sum_child(a_u/a_i)^2. Expanding the product of sums over disjoint modules yields the band inequality, even at arbitrary module depth. This is valid for actual matrices; the explicit physical-band requirement is essential.

5. **Weighted entropy telescope.** Child masses sum to one and to their respective parent masses. Weighted AM--GM therefore gives exactly the code-scale difference plus half the pre-band partition entropy. The input geometric mean, internal cancellation, and final readout factor are all correct.

6. **Maximum arity.** Each coarsening reduces entropy by at most log b. The ceiling r=ceil(log n/log b) gives the lower entropy sum displayed in the manuscript. Writing r=A/B+theta yields the nonnegative correction B theta(1-theta)/2. The bound holds without a power-of-b assumption and is exact for the balanced complete case.

7. **Early large block.** The polynomial-product assumption bounds accumulated entropy by 2K log n+O(1), because the leaf encoding size and predicate are fixed. The count of high-entropy pre-band cuts is O((K+1)/epsilon). The inequality H(mu)>=log(1/max mu) then gives a block of at least n^(1-epsilon) letters. The result is correctly confined to the stated physical hierarchy.

8. **A5 constant.** The negative class has 20/60=1/3 of the group. Six-bit encoding variance is at most six. Hence 2sqrt(p(1-p))/A_0>=2/(3sqrt(3)), matching the manuscript.

## Independent parity-construction check

For m positive input coordinates, s=-n+2m and s-tau_j=2(m-j)+1. Thus all threshold distances are odd integers and at least one in absolute value, and the ideal hidden signs are positive exactly for j<=m.

The identity

    1+sum_(j=1)^n (-1)^j(1+eta_j)=(-1)^m

follows by summing the first m alternating terms. Multiplying by 2(-1)^n gives exactly twice the input parity. With K=log(8n), the total output error is at most

    4n exp(-2K)=1/(16n)<1,

so the signed margin exceeds one. The readout's constant coefficient is bounded: 1+sum_(j=1)^n(-1)^j is either zero or one, and it is supplied by the hidden constant tanh(1).

The exact first-layer squared norm is

    K^2 [n^2+sum_j tau_j^2]+1
      =K^2 [n^2+n(n^2-1)/3]+1=O(K^2 n^3).

The readout squared norm is 4n plus at most 4/tanh(1)^2. Therefore P_F=O(n^2 log(n+1)). All shifts use the augmented input constant, and the construction is one global merge, so it supplies the claimed explicit architectural counterexample without an external representation theorem.

## Compilation check and exclusions

The existing LaTeX log contains no warning, overfull, undefined-reference, or error matches. This audit checked the complete TeX source and algebra, not merely the previous scratch note. It does not establish a Bayesian lower bound, an unrestricted intrinsic-norm lower bound, or any circuit separation. It is not a Lean verification.

## Final corrected assembly

The author applied both requested definition clarifications and rebuilt the standalone paper. I checked the actual new files and the inserted text:

* Final TeX SHA-256: `1ec5dfd674541662c9ef1ff893bb9406bac7c24be0a72eb810d11f60877dcbb3`.
* Final PDF SHA-256: `8eb543c81c4007fe242115dcd0829e1da9ed4ccea44bff93ee72fdd44bfd6139`.

The bands now explicitly form an ordered exhaustive partition of all pre-readout matrix layers, with no layer reused or omitted. The early-block corollary explicitly assumes C_0>0 and K>=0. These changes resolve the only requested clarifications. **Final verdict: PASS on the complete corrected standalone assembly.**
