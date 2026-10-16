# Referee A (proofs) for thread `logic`

*Referee record, 2026-10-16. Subject: `research/tracks/logic/notes.md` (development round, 636 lines) and its scripts in `checks/`. Status: IN PROGRESS (partial; written early for restart safety).*

## Running list of issues found so far (to be consolidated)

1. Prop 4.5: hidden hypothesis, $B$ (or $B\cup T$) must be true (or at least $B\cup T\nvdash\neg\Con(B\cup T)$) for $T+\gamma$ to be consistent.
2. §5.1 remark after Prop 5.1: "case (iii) holding iff $B\nvdash\forall x\varphi$" needs $B$ $\Sigma_1$-sound.
3. Remark 3.4: the dyadic count must use distinct indices across levels (odd numerators, or index the pair $(j,L)$).
4. Prop 3.8 / 3.9: "strings read as numbers" must be an injective coding that recovers the length (length-lexicographic rank); "$\Phi_0(\underline{x_2})$ is a false $\Sigma_1$ sentence" holds only up to $\Q$-equivalence.
5. Prop 5.2 / §0.1 wording: "settle" must mean "prove"; in the $\omega$-inconsistent case the Gaifman condition fails.
6. Cor 2.6': "slower than any computable unbounded function" needs "nondecreasing".
7. Prop 4.5(c) proof: "$\lim\Dis\le2^{-j}$" is the unnormalised mass; the ratio claim is right.
8. Novelty of Thm 3.1 against Bienvenu et al. / Shen: to be checked.
9. Calude–Jürgensen characterisation in §6: to be checked.
