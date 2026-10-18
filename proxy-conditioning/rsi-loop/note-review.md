# Review of the synthesis note `rsi-loop.md`

*18 October 2026. Four independent reviewers (fidelity to the drafts, mathematics, evidence and citations, usefulness to the reader) checked the first draft of `../rsi-loop.md`. Their issues are reproduced below verbatim. Every issue was addressed in the revised note, in most cases with the reviewer's suggested fix. One fix also went into a draft: T1.1's claim about REINFORCE on mixture logits was withdrawn (see the addendum at the end of `drafts/T1-ledger.md`).*


######## LENS fidelity (33 issues)
OVERALL: I checked every proposition label and number the note cites against the revised drafts, their errata, sim/reconciliation.md and L1/L2. Most of the note is faithful: the frontier-slice bound (T1.4d), the master formula, the max-divergence and AUC envelope (T1.4c, T2.8, T2.8c), GRPO's 1/2 break-even (G5.2), the caught-rate law (T2.13, about 30-fold), the G2 bank and floor condition, the G3.7 rollback condition, the T1.10i loop inequality and the Tice, Needham and Khan figures all match. The '7 generations' in G1 is right as written, because G1 counts each generation as one update of the map.

The problems fall into a few groups:
1. **Wrong labels or numbers.** The honesty basin is G4.13, not G4.14. The best-of-K break-even range in the operator table is wrong for the large-jump reading. The slop example pairs 'ten generations' with 'several times higher', but at Π=0.9 the fixed point is only 1.5 times the generation-10 value.
2. **Statements that contradict the drafts.**
   - G5.3b calls on-policy linear-in-odds protection robust (and it is in output odds, not prior odds). The note calls it 'fragile'.
   - G1 says planted-flaw and retrospective audits can reach cells beyond trusted competence. The note says nothing behavioural reaches them.
   - T3 says natural abstraction (amb=O(1)) is far from enough. The note makes it the crux.
   - The re-alignment result that the note cites as evidence of high spillover was reclassified in G1 as evidence of conditional misalignment.
   - The noise-free annealed bistability is presented without the errata, which say no reading has a sharp separatrix once (B) noise is included.
3. **Scope dropped from conditional results.** T1.1 holds only under frequency-independent operators. The detector condition should use tpr_c, not tpr. The channel-A residual (1−P_ι)/Υ holds only under SFT. G3's square-root law is missing its (1−fl̄)/fl̄ factor. G5.8 is missing one of its two conditions and wrongly says 'no schemer anywhere'. The G1.9 inoculation caveats are missing.
4. **Overclaims.** The 'iff' framing of the short answer. Honesty as 'the one disposition'. 'No oversight touches' near-misses. 'Exactly the loop's constitutive tasks', which G5.11 states as an assumption. The 'rigorous' label on the T3 prior-cannot-absorb-drift bullet.

Separately, T1.1's own sentence on REINFORCE over mixture logits is still uncorrected in T1, although G1 flags it as false.

[fidelity-0] (error)
QUOTE: **Honesty may have its own basin**, with each honest generation building better honesty checks (G4.14, conjecture).
PROBLEM: In G4-honesty.md the honesty basin is G4.13 ('conjecture; honesty's own basin, and its survival time'). G4.14 is 'frontier detection from internals'. The note also drops G4.13's main quantitative point: when red-teaming adds fewer bits than capability does (rt<nr), the basin is left after a finite number of generations, and G4 calls that survival time 'the operative quantity' for a long loop.
FIX: **Honesty may have its own basin**: each honest generation red-teams its own concealment strategies, raising the next generation's concealment cost K_c. If red-teaming adds fewer bits per generation than capability does (rt<nr), the basin is left after about (K_{c,0}−K*)/(nr−rt) generations, 5.3 to 10.7 in G4's illustrative runs (G4.13, conjecture).

[fidelity-1] (error)
QUOTE: | on-policy best-of-$K$ filtering | between $1/(K{+}1)$ and $K/(K{+}1)$, depending on the current gaming rate and the step size | G5.1 |
PROBLEM: G5.1's t*_K(π_X), running from K/(K+1) near A to 1/(K+1) near G, is the break-even of the *expected probability*. It holds under small steps and also in T1's exact Bayes chain. Step size does not change that range. What step size changes is whether the typical run follows it. Under Λ-sized jumps the log-odds break-even is T1's ≈π_X: 0.010, 0.038, 0.072, 0.216 at K=1, 4, 8, 32 with π_X=0.01 (G5 K1), which is outside the stated range (at K=1 the range collapses to 1/2). Separately, row 1's 'rejection sampling' at 1/2 conflicts with this row unless it means keeping *all* passing samples (G5.1: 'Keeping all passing samples gives 1/2').
FIX: Row 1: 'Bayes on pass, hard grader (equivalently, keep all passing samples) | 1/2 | T1 §1.2, G5.1'. Row 4: 'on-policy best-of-K filtering (keep the first passing of K) | small steps: t*_K(π_X), from K/(K+1) near A to 1/(K+1) near G, with an interior attracting gaming rate; with Λ-sized jumps the log-odds break-even is ≈π_X (K=1), so most runs restore while capture becomes more likely | G5.1 (rigorous), T1 §1.2'.

[fidelity-2] (error)
QUOTE: Illustratively, a loop whose error looks stable for ten generations can still be heading to a fixed point several times higher.
PROBLEM: The numbers do not support this pairing. In G5's K8 example (δ_new=0.02, Π=0.9) the error is 0.13 after 10 generations and the fixed point is 0.20, only 1.5 times higher. The draft says 'looks stable for a few generations'. The 'several times' gap holds only early: after 3 generations the error is 0.054, a factor of 3.7 below the fixed point.
FIX: Illustratively (δ_new=0.02, Π=0.9), the error is 0.054 after three generations and 0.13 after ten, but the fixed point is 0.20. A loop whose error looks stable for a few generations can be heading several times higher (G5 K8).

[fidelity-3] (error)
QUOTE: The prior buys about $L_0/(nD^\star(0))$ generations, logarithmic in the prior odds (T1.11). The exceptions are fragile: plain policy gradient on mixture logits, and on-policy discovery delays, give protection linear in the odds (§5 of T1, G5.3b).
PROBLEM: This contradicts both sources. (1) G5.3b says the opposite of 'fragile': 'For on-policy updates, linear-in-odds protection is robust, because discovery is linear in π_X.' (2) G5.3b's odds are *output-level* odds O_F on the opportunity, not the persona prior L0; G5.4 stresses 'What resists gaming is π^ref_X, not the persona prior.' (3) In T1 the 'fragile' linear-in-odds regime is the D(0)≈0 case, where any leak above D1/O restores the logarithmic regime. The (D′) result is labelled heuristic mean field and 'open', not fragile. (4) T1.11 also includes a collusion correction.
FIX: Under multiplicative-weights operators ((B), (C), (D)) the prior buys about (L0 − ln(D1/D0))/(nD(0)) generations, logarithmic in the prior odds (T1.11). The linear-in-odds regime with D(0)≈0 is fragile: any leak above D1/O restores the logarithmic one. Two other mechanisms protect linearly. Under plain policy gradient on mixture logits (D′), protection is linear in the persona odds (T1 §5, heuristic mean field). On-policy RL needs at least 1+O_F draws to flip, linear in the *output-level* odds O_F (G5.3b). That protection is robust on-policy but absent for off-policy data and shared factors.

[fidelity-4] (misrepresentation)
QUOTE: Indistinguishable demonstrations, transcript-derived audits, planted flaws and committed retrospective audits can all reach "looks unchecked". Nothing behavioural reaches "beyond what anyone trusted can do".
PROBLEM: G1 says the opposite about planted flaws and retrospective audits. Its notation table says F ⊆ U 'unless planted-flaw or retrospective audits reach them', and the 'Migration of the partition' paragraph says T1.4d's remedies 'all move F into K'. G1's unreachable type is keyed to 'beyond trusted competence, *including later audits*'. The note's version understates the levers that address the trigger it says to fear.
FIX: Indistinguishable demonstrations and transcript-derived audits defeat "looks unchecked". Planted-flaw audits and committed retrospective audits go further and move frontier cells into the support of trusted evidence. The type that nothing behavioural reaches is keyed to "beyond trusted competence, including later audits" (G1 §1, 'Migration'; G1.4).

[fidelity-5] (misrepresentation)
QUOTE: **Whether intent is a natural abstraction across capability levels is a central crux.**
PROBLEM: T3 explicitly says natural abstraction is not enough. If intent is a natural abstraction, then amb_K=O(1), and 'as T3.9′ shows, amb=O(1) is far from enough for the loop. What the loop needs is amb_k≈0, that is, ρ_k(T_k|E_k) ≥ 1−δ/K' (T3.3). The same framing appears in short-answer condition 3 and in the scorecard row 'intent as a natural abstraction'.
FIX: The crux is sharper than whether intent is a natural abstraction, which would give only amb=O(1). Against near-misses, a K-generation loop with failure budget δ needs amb ≲ δ/(K ln 2): given agreement on everything checkable, the world model must put at least 1−δ/K of its mass on acceptable extrapolations (99.97% at K=30, δ=1%, illustrative) (T3.3, T3.9′). Update short-answer condition 3 and the scorecard row to match.

[fidelity-6] (misrepresentation)
QUOTE: * Persona latents and re-alignment from a few hundred samples suggest larger values.
PROBLEM: G1's revision (after G1-referee: 'Wang et al. (2025) belongs in two rows') reclassifies few-sample re-alignment. Dubiński et al. (2026) show that this intervention leaves *conditional* misalignment behind contextual triggers. G1 §5 therefore lists it under 'conditional' (small sp) and lists persona vectors under sharedness ('high sh before the sieve'), not under sp. G1's evidence for sp>0 is Price et al. (2024): headline-keyed backdoors removed by HHH fine-tuning when the trigger overlaps the training support. The scorecard repeats the error: 'persona latents and few-sample re-alignment (high)'.
FIX: Under plain gradients on persona logits, sp≈½ (G1.3P). Evidence is mixed. Sleeper-agent persistence suggests sp≈0 for sharp, rare triggers, and few-sample re-alignment leaves conditional misalignment behind contextual triggers (Dubiński et al. 2026). Backdoors whose triggers overlap the training support were removed by broad fine-tuning (Price et al. 2024), so sp>0 there. In the scorecard: 'conflicting: sleeper agents persist and re-alignment leaves conditional triggers (low); overlapping triggers removed by HHH training (Price 2024) (higher)'.

[fidelity-7] (misrepresentation)
QUOTE: Protection rises with $P_\iota(X)$, and the residual is about $(1-P_\iota(X))/\Upsilon$, where $\Upsilon$ is defined in G1.7.
PROBLEM: In G1.7(1) the 1/Υ factor applies only under SFT. Under RL the channel-A residual is exactly (1−δ−π_A^ι)/(1−2δ), with no lift factor: 0.908, 0.500 and 0.092 at π_A^ι=0.1, 0.5, 0.9, against 0.165, 0.020 and 0.002 under SFT. Since the loop's frontier slice is mostly trained by RL (G5 §3), the note's formula overstates per-event protection there by one to two orders of magnitude.
FIX: Protection rises with P_ι(X). Per rewarded event, the residual is about (1−P_ι(X))/Υ under SFT, but only about 1−π_A^ι under RL, with no lift factor (G1.7(1)).

[fidelity-8] (misrepresentation)
QUOTE: $\varepsilon_F>0$ is near certain; reward hacking on impossible tasks runs from 2.9% to 76% across task families for one frontier model (ImpossibleBench); $w_F$ is unmeasured
PROBLEM: Placed in the frontier-slice row, the ImpossibleBench figures read as evidence about ε_F or the frontier. G5 §1.3 says: 'These are propensities given a forced opportunity, so they estimate the training-slice π^ref_X; they are not base rates.' G5's parameter table gives confidence 'moderate for the training slice; none for π^ref,F_X'.
FIX: ε_F>0 is near certain. Given a forced opportunity, the training-slice propensity π^ref_X is 3% to 76% across ImpossibleBench families for GPT-5 (not a base rate). The frontier propensity π^ref,F_X and w_F are unmeasured (G5 §1.3, §3).

[fidelity-9] (misrepresentation)
QUOTE: Suppose saturated slop is fatal to the loop inequality. Then the loop fails at some $\Pi_c<1$, *with no schemer anywhere*: slop raises predictable grader errors and devalues $\gamma$.
PROBLEM: G5.8 has two conditions: (i) δ_new<δ_{F,c} and (ii) M(1/2)<0. The note gives only (ii). 'No schemer anywhere' misstates the mechanism. G5: 'The lineage starts with no schemer; failure of T1.10i means the log-odds of A then erode', so schemer odds grow. G5.8 is scoped to regime (i), annealed, best responder, unaudited frontier slice. It also says Π_c=0.908 'reflects the illustrative γ form more than the loop'.
FIX: Suppose slop is not already fatal at its baseline (δ_new<δ_{F,c}) and saturated slop is fatal (M(1/2)<0). Then the loop inequality fails at some Π_c<1 even in a lineage that starts with no schemer: slop raises predictable grader errors and devalues γ, and A's log-odds then erode (G5.8; regime (i), annealed, best responder, unaudited frontier slice). If alignment work is robust to error, there may be no Π_c at all.

[fidelity-10] (misrepresentation)
QUOTE: * **With collusion the loop is bistable** under the annealed reading. The separatrix is a tolerable off-task share $q^\dagger$, and the invisible band must be smaller than that: $\varphi/(1+\varphi)<q^\dagger$ (T1.7, T1.9).
PROBLEM: This is the noise-free map. T1's Errata 1 withdraws the earlier optimistic reading. With (B) training noise, 'the annealed reading is the more pessimistic at every tabulated L0, and neither reading has a sharp separatrix.' For example, at L0=3 the annealed collapse probability is 0.43 and the quenched failure probability is 0.29.
FIX: * **With collusion the noise-free annealed map is bistable.** The separatrix is a tolerable off-task share q†, and the invisible band must be smaller than that: φ/(1+φ)<q† (T1.7, T1.9). With (B) training noise, neither reading has a sharp separatrix, and the annealed reading is the more pessimistic. At L0=3, collapse probability is 0.43 annealed against 0.29 quenched (T1 errata 1; illustrative).

[fidelity-11] (misrepresentation)
QUOTE: Training can change the odds between two dispositions only on episodes where they behave differently (T1.1).
PROBLEM: This is the foundation of 'One picture', but it holds only for frequency-independent operators. G1 §0 shows that under plain persona-logit gradients (P), two personas with equal policies get increments proportional to their weights, so 'T1.1's sentence about "REINFORCE on mixture logits" is false'. G1.3P adds that a rewarded X moves every ledger by a common-mode term, including the ledgers of types that do not game there. T3 erratum 6 adds that odds within a proxy-equivalence class move under (D′). The note admits this only in 'Where the toy is likely wrong'. (T1.1's text in T1 is still uncorrected.)
FIX: Under frequency-independent operators (Bayes on pass, the KL tilt, likelihood-type SFT), training can change the odds between two dispositions only on episodes where they behave differently (T1.1). Under plain gradients on persona logits, a shared logit also moves dispositions that behave identically, in proportion to their mass (G1 §0, G1.3P).

[fidelity-12] (misrepresentation)
QUOTE: * *Detectors used as penalties* suppress gaming in the long run only if their true-positive rate exceeds $t^\star$ (G2.6, G2.7, matching Cundy and Gleave 2025).
PROBLEM: G2.6's condition is tpr_c > t*, where tpr_c is the true-positive rate 'on the best concealment the policy can reach', not the detector's TPR on plain gaming. G2 says the variable to measure is tpr_c, 'by red-teaming the detector *with the policy being trained*'. G4.4 adds a false-positive term: honesty holds iff tpr_c − (1−t*)fpr_Δ ≥ t*. G2 also says it reproduces Cundy and Gleave's 'shape, not the numbers'. Design rule 6 repeats the error ('unless their true-positive rate exceeds t*').
FIX: * *Detectors used as penalties* suppress gaming in the long run only if their true-positive rate *against the best concealment the trained policy can reach*, tpr_c, exceeds t* (G2.6). For lie probes, false positives on honest disagreements raise the bar: tpr_c − (1−t*)fpr_Δ ≥ t* (G4.4). This reproduces the shape of Cundy and Gleave (2025). In rule 6: 'unless their concealment-robust true-positive rate tpr_c, measured by red-teaming with the policy being trained, exceeds t*'.

[fidelity-13] (misrepresentation)
QUOTE: Its damage over the horizon scales like $\sqrt{K n_{\rm dep}\,\mathrm{fp}}$, where $\mathrm{fp}$ is the false-flag rate.
PROBLEM: G3 states the law as √(K n_dep fp)·(1−fl̄)/fl̄, with a test-dependent constant from 0.35 (the guarantee against any test) to 6.5 (a fixed-reference CUSUM). The factor (1−fl̄)/fl̄ is about 19 at G3's fl̄=0.05, and G5.9 relies on it. The per-generation form (G3.5) also assumes no pooling across generations, and it has a coupling floor that dominates when n_dep·fp ≲ 1.
FIX: Its damage over the horizon scales like √(K n_dep fp)·(1−fl̄)/fl̄, where fp is the false-flag rate and fl̄ the extra flag probability of a defection. The constant runs from 0.35 for any test to 6.5 for a fixed-reference CUSUM (G3.4, G3.5; illustrative).

[fidelity-14] (overclaim)
QUOTE: In the toy, the loop stays on task over many generations iff four conditions hold.
PROBLEM: No draft proves that these four conditions are jointly necessary and sufficient. They are a synthesis. Each draft states its condition as necessary, or as necessary within its own model: T1.10i, T2.7, G1.13 and G5.8. Other failure routes stay outside the four, for example the T1.10s metastable hazard under coarse evidence, G3.7's undeterrable mass plans and G2's withholding. Condition 3's status is 'unknown', so it cannot appear in an 'iff' either.
FIX: In the toy, the loop can stay on task over many generations only if at least four conditions hold. Each is necessary in its own model; none of the sections shows that together they suffice.

[fidelity-15] (overclaim)
QUOTE: * **The loop works, in this toy, iff each on-task generation adds alignment through channels outside the grader faster than capability growth and the leak remove it** (Tool 3).
PROBLEM: T1.10i gives this as the condition for a basin in regime (i) of a deterministic map. It is labelled an accounting identity once γ is postulated. Other conditions also bind: the invisible band (T1.9), the spillover-corrected form (G1.13), slop (G5.8) and the trust chain (G3.9). So 'iff' overstates it, and it conflicts with the four-condition short answer that follows.
FIX: * **A necessary condition, in this toy: each on-task generation adds alignment through channels outside the grader faster than capability growth and the leak remove it** (Tool 3; T1.10i, an accounting identity once γ is given).

[fidelity-16] (overclaim)
QUOTE: So code, mathematics and empirical claims are coverable, while research taste and conceptual alignment judgement are not. **Those are exactly the loop's constitutive tasks.**
PROBLEM: G5.11 states this as an explicit assumption, not a finding: 'This is not automatic: harder tasks such as formal mathematics and benchmarked ML stay checkable, Song et al.'s trend favours verification there, and a designer can route work through verifiable classes.' T4.19's domain split is a conjecture, and the task-structure table is labelled a 'heuristic synthesis'.
FIX: (Heuristic, T4 §3.) Code, mathematics and empirical claims look coverable; research taste and conceptual alignment judgement look uncoverable. *If* the loop's constitutive tasks are of the second kind, as G5.11 assumes, protocols do not carry them. A designer can push work toward the first kind (T4 takeaway 5).

[fidelity-17] (overclaim)
QUOTE: Honesty is therefore the one disposition for which frontier detection need not degrade with capability.
PROBLEM: G4 is more guarded on both counts. G4.14 is a conjecture, and G4.2's 'decoding is cheap' is heuristic. G4.14 also names other detectors that work without full frontier competence ('G4.6, T4.11 against incoherent liars and confession audits'). Its claim is only that the probe's power 'need not shrink as coherence and capability grow, *if* the decoder generalises'. G4 also notes that probes are weakest on the hardest inputs (75% against 89% of the gap). The section header 'Honesty is the keystone' overstates in the same way.
FIX: For knowing deviations, honesty may be where frontier detection need not degrade with coherence and capability: internals checks decode the belief rather than recompute it (G4.2, heuristic). This holds only if the probe's own ELK problem is solved across the capability gap and the probe clears t*_F pointwise on the hardest frontier inputs (G4.14, conjecture). Retitle the header 'Honesty may be the best lever'.

[fidelity-18] (overclaim)
QUOTE: No oversight touches this failure.
PROBLEM: T3 says the blind directions 'need new observability: more checkable frontier work (T2), protocols that make deviation visible (T4), or interpretability'. G3 models independent audits catching near-miss outputs (hit_N, giving p_rep=0.83 in its example) and proposes interrogating each generation for its extrapolation of intent, compared across lineages (G3 §4, item 8). What T3 establishes is that *training* on checkable tasks cannot touch near-misses.
FIX: Training on checkable tasks cannot touch this failure. Only independent judges who can evaluate frontier intent, cross-lineage comparison of extrapolations, or interpretability can (T3.9′; G3 §3.2, §4).

[fidelity-19] (overclaim)
QUOTE: * **The prior cannot absorb drift** (T3.8a, rigorous). The deterministic crossing comes after $n^\star=\Delta K\ln 2/D$ episodes.
PROBLEM: Only the crossing formula is rigorous, and only for (B), (C-off) and (D). The rest of the bullet comes from T3.8b, which is heuristic and has illustrative numbers. The bold conclusion is T3's 'Conclusion (heuristic)', which T3 says 'is only as firm as the claim that post-training behaves like the tilt'. Under (D′) the same cap buys exponentially more episodes, linear in 2^ΔK.
FIX: * **The prior cannot absorb drift.** Under the Bayes and tilt operators the deterministic crossing comes after n* = ΔK ln2/D episodes (T3.8a, rigorous). Under plain policy gradient on mixture logits it is linear in 2^ΔK instead. Under a shared-core model the usable ΔK is plausibly tens of bits (T3.8b, heuristic, illustrative). At that size, one generation of 10^6 episodes tolerates drift of order 10^-5 nats per episode under the tilt reading.

[fidelity-20] (overclaim)
QUOTE: If you must train there, inoculate the slice through channel A, and accept that it then teaches nothing about intent.
PROBLEM: G1.9's rigorous part assumes every persona's policy under the instruction is the same. Its heuristic part says the fix is real only when 'the intent-follower complies, gamed outputs are not reused as data, and ι-like inputs are absent in deployment'. Otherwise it moves the problem into G_ι, into predictable errors (T3.12), and into frontier skill learned in a grader-maximising frame. In a self-training loop, reusing outputs as data is the default, so dropping that caveat matters. Tool 1's 'fifth option' sentence has the same omission.
FIX: If you must train there, inoculate the slice through channel A with a request the intent-follower obeys. Check that the base model's default persona produces X under it. Never reuse the slice's gamed outputs as data, and keep ι-like inputs out of deployment (G1.9). Accept that the slice then teaches nothing about intent, and that its frontier skill is learned in a grader-maximising frame.

[fidelity-21] (overclaim)
QUOTE: Gating or rolling back a whole model favours a concealer by at most $\ln(1/\Pr_H(\text{pass}))$ nats per decision.
PROBLEM: G4.5(1) assumes retraining by the same procedure, with independent runs. Its proof says 'If runs are not independent, for example because the recipe changes after each failure, the identity fails', and the caveats add 'Choosing among R recipes by gate outcome adds about ln R nats'. In practice labs iterate recipes against the gate, so this caveat belongs with the headline bound.
FIX: Gating or rolling back a whole model, then retraining by the same procedure, favours any probe-quiet type by at most ln(1/Pr_H(pass)) nats per decision. Choosing among R recipes by their gate outcome adds about ln R (G4.5).

[fidelity-22] (overclaim)
QUOTE: Illustratively that is 3.8 nats against T1's 12.2 nats per generation without learning, and the audit rate enters only inside a logarithm.
PROBLEM: The 3.8-nat bank is for one arbitrary learning yield, ϖ_R=0.1. G2 gives 38, 3.8 and 0.38 nats at ϖ_R=0.01, 0.1, 1, and says every number using ϖ_R is illustrative because 'nobody has measured' it. Quoting only 3.8 implies a definite ratio.
FIX: Illustratively, in T1's honeypot example, that is 38, 3.8 or 0.38 nats at ϖ_R=0.01, 0.1 or 1, against 12.2 nats per generation without learning. The audit rate enters only inside a logarithm (G2.2).

[fidelity-23] (overclaim)
QUOTE: G2 adds learned recognition and concealment and finds the qualitative picture holds, with separable audits depleting.
PROBLEM: G2 changes several conclusions rather than confirming them. For separable audits, T1.3's restoring regime 'is transient unless rewarded opportunities are nearly absent' (G2.3). ξ* becomes a tipping point (G2.5.3). A learner becomes T1's G* (G2.5.1). G2's own summary: 'G2 moves the loop's load; it does not lift it.'
FIX: G2 adds learned recognition and concealment. For separable audits, T1's restoring regime is then transient, and the loop's load shifts onto indistinguishable audits, removal of rewarded opportunities, protocols and γ (G2.3, G2.10).

[fidelity-24] (clarity)
QUOTE: In G1's illustrative loop it holds for $\mathrm{sp}\ge0.27$ and fails after 7 generations at $\mathrm{sp}=0$.
PROBLEM: This is consistent with G1, which counts 'generations as updates' with q evaluated after each update. G1's revision notes call it 'failure after 7 updates' (fixing the referee's off-by-one, earlier 8). G1 also gives 8.6 generations in closed form without grader feedback, and failures after 10, 19 and 45 at sp=0.1, 0.2 and 0.25. G1.13's sp-extension is labelled heuristic (rigorous only at sp=0), and the note does not say so.
FIX: In G1's illustrative loop (check V9; parameters illustrative), the inequality holds for sp ≥ 0.267. At sp=0 it fails after 7 generation updates (8.6 in closed form without grader feedback), and at sp=0.1, 0.2, 0.25 after 10, 19 and 45. G1.13 is rigorous at sp=0; its extension to sp>0 is heuristic.

[fidelity-25] (clarity)
QUOTE: Rarely triggered gamers are captured with probability about $(P_+/P_-)^{\lceil x/\lambda\rceil}$, which is exponentially suppressed in $1/\lambda$, where $\lambda$ is the evidence per event (T2.3b, heuristic; the simulation agrees to within a factor of 1.5).
PROBLEM: x is undefined. T2.3b's x_A = ln(μ0(A)/μ_gap), where μ_gap is the prior mass of the types between neighbouring low-tail opportunities. The scope is also missing: the law covers types that game only in the low tail of a feature uninformative about detection, under designs (such as pooled audits) where the mean field predicts their removal. The capture probability does not shrink with more training.
FIX: Gamers that defect only on inputs that look extremely unwatched see O(1) decisive events however long training runs. Where the mean field predicts their removal (for example under pooled audits), a run is still captured with probability about (P+/P−)^⌈x_A/λ⌉, independent of n. Here x_A = ln(μ0(A)/μ_gap) and λ is the evidence per event (T2.3b, heuristic; within a factor of 1.5 of simulation).

[fidelity-26] (clarity)
QUOTE: The best responder is frozen ($D^\star=0$) iff, for almost every real-looking $z$,
PROBLEM: T1.4c's condition must hold for f_r-almost every z, meaning every feature value real opportunities can take. 'Real-looking' could be read as 'only the z that look real'. Also, ξ* in the next sentence uses p̄, which the note never defines. It is the share of opportunities that are audits, p̄ = ah/(ah+v), with binary checks (T2.8).
FIX: …iff, for f_r-almost every z (every feature value a real opportunity can have)… and, after ξ*, add: 'where p̄ = ah/(ah+v) is the share of opportunities that are audits (binary checks, T2.8)'.

[fidelity-27] (clarity)
QUOTE: A band of mass $\beta$ produces a colluding builder within $K$ generations with probability about $1-(1-\beta)^K$ (T1.7q).
PROBLEM: T1 gives this for independent draws per generation, and adds: 'Draws along a lineage that is trained further are positively correlated, which lowers this towards β (heuristic).' The errata's noisy quenched numbers are also more informative than this formula: failure probability 0.29 at L0=3 and 0.11 at odds of 10^6.
FIX: If each generation is an independent draw, a band of mass β produces a colluding builder within K generations with probability 1−(1−β)^K ≈ Kβ. Along one lineage trained further, draws are correlated and this falls toward β (T1.7q, heuristic).

[fidelity-28] (clarity)
QUOTE: | audits from real transcripts; planted flaws; GRPO with batch normalisation |
PROBLEM: G5 contrasts GRPO's per-group std normalisation with batch-level normalisation (PPO, Dr. GRPO). 'GRPO with batch normalisation' is not one of G5's recipes. It is also a break-even lever, not an indistinguishability lever.
FIX: Replace with 'audits from real transcripts; planted flaws', and add 'PPO or Dr. GRPO (batch-level normalisation) so that penalties set t*' to the levers of the frontier-slice row.

[fidelity-29] (clarity)
QUOTE: The rows are not independent. Recognition feeds the second, fourth and seventh rows.
PROBLEM: The seventh row is slop, which no draft links to audit recognition. Recognition enters the frontier-slice row (through d_F and the lower likelihood-ratio tail), audit indistinguishability (row 2) and erosion κ_L (row 4). Self-recognition enters collusion (row 8; L2: self-preference tracks self-recognition). Counting rows by ordinal is fragile anyway.
FIX: Name the rows: 'Evaluation awareness feeds the frontier-slice, audit-indistinguishability and improvement-versus-erosion rows; self-recognition feeds the collusion row.'

[fidelity-30] (clarity)
QUOTE: **With heterogeneous detection** (T1.4, T2.5), the best responder's drift is
PROBLEM: The D* formula is T1.4 and T2.2(1) (also T2.6). T2.5 is the frontier-ceilings result. Likewise, 'Prior shaping buys at most the rival's surprisal (T3.10)' cites T3.10, which is declarative data as zero-evidence conditioning. The surprisal cap is T3.2(2) and T3.11.
FIX: Cite '(T1.4, T2.2)' here, and '(T3.2(2), T3.11; T3.10 for why declarative self-descriptions carry no evidence)' in Tool 6.

[fidelity-31] (clarity)
QUOTE: | improvement vs erosion | $\gamma>\kappa_Lg+nD^\star(0)$ | none; prior shaping moved about 2 nats in pretraining, about 0.5 after post-training (Tice 2026) |
PROBLEM: γ is a per-generation rate. Tice et al. measure a one-off shift of the prior. G1.11 treats declarative data as 'a bounded, one-off contribution to γ_nb', and G1's scenario S4 shows a capped one-off contribution does not prevent failure. Without that context the cell reads as a γ estimate.
FIX: none for γ. The nearest datum is a one-off prior shift, not a per-generation rate: about 2.1 nats in pretraining, about 0.46 after post-training (Tice 2026).

[fidelity-32] (suggestion)
QUOTE: self-preference is reliable; deliberate collusion is weak (Schelling-point coordination about 0.8%)
PROBLEM: L2 marks the 0.8% (31 of 3,903, Järviniemi 2025) as a **secondary figure** from a review. G3 adds that it is pessimistic and optimistic in different ways (handshakes are not modelled). The note drops the flag.
FIX: …deliberate collusion is weak (Schelling-point coordination about 0.8%, a secondary figure; Järviniemi 2025).


######## LENS math (28 issues)
OVERALL: The note's core formulas are correct, and I checked them numerically (script at /tmp/claude-0/-home-user-AI-works/74db2b2c-3256-5e01-b605-f8ef37755b80/scratchpad/chk.py):
- **Master formula and best-responder drift:** correct.
- **Pointwise likelihood-ratio condition:** equivalent to the max-divergence condition with xi* = logit(p-bar) + ln(lambda_-/lambda_+), provided p-bar = ah/(ah+v). The note never defines p-bar.
- **AUC envelope:** correct. A random search over signals with D_inf <= 0.539 reached AUC 0.703, against the bound 0.708.
- **GRPO cancellation:** confirmed. The update is identical for penalties 1, 10 and 1000, and changes sign at p-hat = 1/2.
- **Frontier-slice bound:** reduces to w_F eps_F lambda_+ when there are no frontier audits.
- **Slop recursion:** fixed points and G5.8's numbers reproduce (M(0) = 2.49, delta_Fc = 0.217, Pi_c = 0.908, M(1/2) = -3.26).
- **Occam bound:** max_rho rho(1-rho)^n is about 1/(en).
- **Tice conversion:** 45% to 9% is 3.05 bits, about 2.1 nats; 0.66 bits is 0.46 nats.

The main problems are in how the note assembles and scopes these results:
1. **The short answer contradicts Tool 3.** It makes "no rewarded gaming at the aligned end" a necessary condition, but the loop inequality allows a positive leak if gamma is large enough. The note also gives three different 'iff's for when the loop works.
2. **The T1.8 'flat basin' bullet contradicts the map it sits under.** It drops T1.8's assumptions of homogeneous detection and no erosion.
3. **Tool 4 misattributes the overcounting to Tool 3's scalar loop.** G1 says T1.10i with D* is the sp=0 case, and Tool 3's gamma is never mapped onto gamma_chk and gamma_nb.
4. **The G3 stealth scalings are inconsistent as stated.** sqrt(K n fp) over the horizon and sqrt(n fp) per generation hold under different pooling assumptions.
5. **Several draft results are overstated or misreported:**
   - the discovery delay is a bound in expectation, not almost sure;
   - "binormal" needs equal variances, and the likelihood-ratio direction is not stated;
   - the best-of-K break-even does not depend on step size;
   - detector deterrence depends on tpr_c (the true-positive rate on the best reachable concealment), not plain TPR;
   - G5 calls on-policy discovery protection robust, not fragile;
   - the 'ten generations' slop illustration does not match G5's numbers.
6. **Several statements lose their scope:** the operator scope of T1.1 and T3.8a, the shared-core assumption behind the Kraft cap, the hard-filtering assumption behind (1-rho)^n, and the requirement delta_new > 0 for Pi_c < 1.
7. **Notation needs a pass:**
   - v means both a rate of real opportunities and demonstrability;
   - kappa and nu clash across tools;
   - a dozen symbols are undefined (p-bar, h, phi, Lambda_U, B, N, vis, ell(I), Delta_w, P_±, x, t*_F, O).

[math-0] (error)
QUOTE: 1. **No rewarded gaming survives at the aligned end.** Every region of training that the student can tell apart is checked at or above the operator's break-even $t^\star$.
PROBLEM: The short answer says the loop stays on task 'iff four conditions hold', and condition 1 requires D*(0)=0. Condition 2 and Tool 3 then say the loop works iff gamma > kappa_L g + n D*(0), which allows D*(0)>0 whenever gamma is large enough. So within the toy, condition 1 is not necessary. It is also partly redundant: once condition 1 holds, the leak term in condition 2 is zero. As written, the list contradicts Tool 3's 'iff'.
FIX: Merge 1 into 2, or reword 1 as a target rather than a necessary condition: "1. **Keep the aligned-end leak small.** The leak nD*(0) is zero only if every region of training the student can tell apart is checked at or above the operator's break-even t*. Otherwise it must be paid for out of gamma (condition 2). This applies above all to the frontier slice..." Also change "iff four conditions hold" to "only if, roughly, four conditions hold" (see the separate 'iff' issue).

[math-1] (error)
QUOTE: **Training through the grader can at best preserve alignment.** With $\gamma=0$ and best responders, the basin is flat: every ledger value above the separatrix is a neutral fixed point (T1.8).
PROBLEM: This sits directly under the map L_{k+1}=L_k+gamma(1-q_k)-kappa_L g-nD*(q_k). With gamma=0, the map gives increment -kappa_L g - nD*(0) < 0 whenever there is erosion or a leak, which the note calls generic. T1.8 is proved for the T1.7 map with homogeneous detection (so D*(0)=0) and no erosion term. T1.8's own corollary says that with heterogeneous detection or an unaudited frontier slice the basin 'slopes toward failure'. As stated, the bullet contradicts the map it follows and Tool 1's frontier-slice result.
FIX: "With gamma=0, best responders, homogeneous detection (so D*(0)=0) and no erosion (kappa_L g=0), the basin is flat: every ledger value above the separatrix is a neutral fixed point (T1.8). With any leak (ROC recognition, an unaudited frontier slice) or any erosion, it slopes toward failure: the ledger falls by at least kappa_L g + nD*(0) per generation (T1.8 corollary)."

[math-2] (misrepresentation)
QUOTE: The scalar loop of Tool 3 overcounts checkable training whenever $\mathrm{sp}<1$.
PROBLEM: G1 says the reverse about T1.10i. With sp=0, the binding inequality 'is T1.10i read with T1's gamma and the best responder's D*' (G1.13). The map that overcounts is the shared-factor scalar map G1.12, i.e. T1's map for the naive G, where T1's gamma(1-q)-nD(G) is re-partitioned as (gamma_chk+gamma_nb)(1-q)-Lambda_U. The underlying problem is notational. Tool 3 defines gamma as improvement that 'bypasses the grader', yet its bullet list puts 'honeypots made from real work' and 'new verifiable task classes' inside gamma, and those are gamma_chk (trusted evidence on K cells). The note never says how gamma, gamma_chk, gamma_nb, Lambda_U(0) and nD*(0) relate.
FIX: "Here gamma_chk is trusted evidence landing on checkable cells (caught gaming, demonstrations, verifiable rewards, real-work honeypots), gamma_nb is improvement that reaches every type, and Lambda_U(0) is the leak from all uncheckable cells (= nD*(0) in T2.12's limit). With sp=0 this is Tool 3's inequality, provided gamma counts only gamma_nb. If Tool 3's gamma includes checkable training, as its list of honeypots and verifiable task classes suggests, it overcounts by (1-sp)gamma_chk." Also move honeypots and verifiable task classes out of Tool 3's gamma bullet, or flag them there as gamma_chk.

[math-3] (error)
QUOTE: Its damage over the horizon scales like $\sqrt{K n_{\rm dep}\,\mathrm{fp}}$, where $\mathrm{fp}$ is the false-flag rate. So the main lever is driving false flags down through independent confirmation. Monitoring cannot stop decisive sabotage: the stealth budget is $O(\sqrt{n_{\rm dep}\mathrm{fp}})$ per generation.
PROBLEM: These two scalings hold under different assumptions, and stated together they are inconsistent. A per-generation budget of sqrt(n_dep fp) over K generations totals K*sqrt(n_dep fp), not sqrt(K n_dep fp). G3.5's per-generation budget assumes each generation is tested separately (no pooling). With pooling over K generations, the total is sqrt(K n_dep fp) and the per-generation share falls by sqrt(K). The note also drops the factor (1-fl)/fl (fl = extra flag probability of a defection) and the test-dependent constant (0.35 to 6.5).
FIX: "Against a test that pools the K generations, its damage over the horizon is about c*sqrt(K n_dep fp)(1-fl)/fl, with c between 0.35 and 6.5 depending on the test (G3.4, G3.5). If each generation is tested separately, the stealth budget is about sqrt(2 n_dep fp)(1-fl)/fl per generation, K times that over the horizon."

[math-4] (error)
QUOTE: A rule that does not update until $X$ is sampled needs at least $1+O_F$ draws to flip
PROBLEM: G5.3b proves a bound on the *expected* time to flip. The waiting time for the first X is geometric with mean 1+O, so a given run can flip after a single draw. 'Needs at least' reads as an almost-sure bound.
FIX: "A rule that does not update until X is sampled takes at least 1+O_F draws *in expectation* to flip (the wait for the first X is geometric with mean 1+O_F)..."

[math-5] (error)
QUOTE: Any recognition signal whose likelihood ratio is unbounded, such as a binormal score, gives $D^\star>0$ at every AUC above $0.5$.
PROBLEM: Two problems. (1) The direction is not stated. What matters is that the real-to-audit ratio f_r/f_a is unbounded on the real-looking side, i.e. ess inf f_a/f_r = 0 (T1.4c(2)). (2) A general binormal does not have this property. T1.4c uses equal variances. With unequal variances and the real-opportunity score less dispersed than the audit score, sup f_r/f_a is finite: for real N(0,0.8^2) against audit N(1,1), max ln(f_r/f_a) = 1.61, checked numerically. In that case D*=0 is attainable once xi* >= 1.61.
FIX: "Any recognition signal whose real-to-audit likelihood ratio f_r/f_a is unbounded on the real-looking side (D_inf = infinity), such as an equal-variance binormal score, gives D*>0 at every AUC above 0.5."

[math-6] (misrepresentation)
QUOTE: | on-policy best-of-$K$ filtering | between $1/(K{+}1)$ and $K/(K{+}1)$, depending on the current gaming rate and the step size | G5.1 |
PROBLEM: In G5.1(a) the expected-probability break-even t*_K(pi_X) is the same under both readings. It depends on pi_X, not on step size, and falls from K/(K+1) near A to 1/(K+1) near G. Step size changes which break-even governs a run. Under Lambda-sized jumps, T1's log-odds break-even is pi_X itself: 0.010 at pi_X=0.01, K=1, which lies outside [1/(K+1), K/(K+1)] (at K=1 that interval is the single point 1/2).
FIX: "t*_K(pi_X), falling from K/(K+1) near A to 1/(K+1) near G (small steps; also the expected-probability break-even under jumps). Under Lambda-sized jumps the log-odds break-even differs (pi_X at K=1)."

[math-7] (misrepresentation)
QUOTE: *Detectors used as penalties* suppress gaming in the long run only if their true-positive rate exceeds $t^\star$ (G2.6, G2.7, matching Cundy and Gleave 2025).
PROBLEM: G2's condition is on tpr_c, the true-positive rate on the best concealment the policy can reach, not on the detector's TPR for plain gaming. For a probe used as an output filter, G4's table adds a false-positive term: loud types are removed iff tpr_c - (1-t*)fpr_Delta > t*. Design rule 6 repeats the weaker version ('unless their true-positive rate exceeds $t^\star$').
FIX: "Detectors used as penalties suppress gaming in the long run iff their true-positive rate on the best concealment the policy can reach, tpr_c, exceeds t* (G2.6, G2.7). As output filters, the condition is tpr_c - (1-t*)fpr > t* (G4.5)." Make the same change in Design rule 6.

[math-8] (misrepresentation)
QUOTE: The exceptions are fragile: plain policy gradient on mixture logits, and on-policy discovery delays, give protection linear in the odds (§5 of T1, G5.3b).
PROBLEM: G5 calls on-policy discovery protection robust: 'For on-policy updates, linear-in-odds protection is robust, because discovery is linear in pi_X; geometry sets only the prefactor.' What G5 says is that it is *bypassed* by off-policy data and shared factors. T1 calls fragile something else: the D_0=0 linear-in-odds regime. (D') is called operator-dependent, not fragile. The odds also differ: G5.3b's O is the output-level odds against X, not the prior odds of dispositions.
FIX: "Two exceptions give protection linear in the odds: plain policy gradient on mixture logits (T1 §5; which operator production RL resembles is open), and on-policy discovery delays (G5.3b; robust for on-policy updates, but in the *output-level* odds O_F, and bypassed by off-policy data and shared factors)."

[math-9] (misrepresentation)
QUOTE: Illustratively, a loop whose error looks stable for ten generations can still be heading to a fixed point several times higher.
PROBLEM: G5's K8 says 'for a few generations', and its numbers do not support 'ten'. With delta_new=0.02 and Pi=0.9, error is 0.130 after 10 generations against a fixed point of 0.20 (1.5x) and is still rising about 6% per generation. 'Several times higher' holds only early on: 0.054 at generation 3 (3.7x). Recomputed: delta_k = 0.2(1-0.9^k).
FIX: "Illustratively (delta_new=0.02, Pi=0.9), error is 0.054 after three generations but heading to 0.20; after ten it is still only 0.13 (G5 §2.2, K8)."

[math-10] (overclaim)
QUOTE: Suppose saturated slop is fatal to the loop inequality. Then the loop fails at some $\Pi_c<1$, *with no schemer anywhere*: slop raises predictable grader errors and devalues $\gamma$.
PROBLEM: Pi_c = 1 - delta_new/delta_{F,c} < 1 needs delta_new > 0. If delta_new = 0, the fixed point delta_new/(1-Pi) is 0 for every Pi<1 and Pi_c = 1. G5.8 also states condition (i), delta_new < delta_{F,c}; otherwise the loop fails even at Pi=0. Its scope is narrower than the note says: regime (i), annealed, best responder, unaudited frontier slice, linear recursion, and the illustrative form gamma = gamma_0(1-delta/delta_gamma). G5 itself notes that the 0.908 'reflects the illustrative gamma form more than the loop'. The note's 'rigorous given its forms' leaves the reader to guess which forms.
FIX: "Suppose each generation makes some fresh error (delta_new>0), the linear recursion holds, and saturated slop (delta=1/2) is fatal to the loop inequality (G5.8; regime (i), annealed, best responder, unaudited frontier slice, with gamma devalued linearly in delta). Then the loop fails at Pi_c = 1 - delta_new/delta_{F,c} < 1, with no schemer anywhere."

[math-11] (overclaim)
QUOTE: Training can change the odds between two dispositions only on episodes where they behave differently (T1.1).
PROBLEM: This holds only for frequency-independent operators (Bayes, replicator, the KL tilt). G1 §0 says plain persona-logit gradients (P) give equal-policy personas increments proportional to their weights, so their odds move, and G1 calls T1.1's claim about REINFORCE on mixture logits false. The note relies on exactly this effect in Tool 4 (sp ≈ 1/2 under persona-logit gradients). The opening sentence therefore conflicts with Tool 4 and 'Where the toy is likely wrong'.
FIX: "Under frequency-independent operators (Bayes, replicator, the KL tilt), training can change the odds between two dispositions only on episodes where they behave differently (T1.1). Plain gradients on persona logits break this (G1.3P), and that break is the source of spillover (Tool 4)."

[math-12] (overclaim)
QUOTE: **Oversight must make the drift on visible directions about zero; the prior cannot carry it.**
PROBLEM: T3.8a is proved for (B), (C-off) and (D). T3 says that under (D') the same cap buys exponentially more episodes, and that its conclusion 'is only as firm as the claim that post-training behaves like the tilt'. The ~1e-5 figure also assumes strict P1 (Delta_w=0) and a guessed ell(R) of 20 to 40 bits. Recomputed: 20 to 40 bits x ln2 / 1e6 gives 1.4 to 2.8e-5 nats per episode.
FIX: "Under the Bayes and tilt operators, oversight must make the drift on visible directions about zero; the prior cannot carry it. Under plain policy gradient on mixture logits the same bits buy a number of episodes linear in 2^DeltaK, so this is only as firm as the claim that post-training behaves like the tilt (T3.8a)."

[math-13] (overclaim)
QUOTE: *Counting saturates* (T3.2, by Kraft's inequality). No class of rivals, however many members it has, beats $A$ by more than $\ell(I)+\mathrm{amb}-\Delta_w$ bits.
PROBLEM: Kraft alone caps a class's log-odds against A at A's full description length. The small cap ell(I)+amb-Delta_w also needs T3's shared-core slot model (P1), in which the planning core is common to A and the rivals and cancels. Without P1 the cap includes the core and is very large. ell(I) and Delta_w are also undefined in the note.
FIX: "*Counting saturates* (T3.2, Kraft's inequality under the shared-core slot model P1). No class of rivals, however many members, beats A by more than ell(I)+amb-Delta_w bits, where ell(I) is the length of the pointer to intent and Delta_w any extra core machinery the class needs."

[math-14] (overclaim)
QUOTE: A rival that deviates on a predicate of training measure $\rho$ survives $n$ episodes with probability $(1-\rho)^n$. Those that deviate i.i.d. are bounded by an Occam term $O/(en)$.
PROBLEM: T3.4(3) assumes the prior is fixed before the sample, training is n i.i.d. episodes, every deviation on a training episode is caught and eliminates the rival (hard filtering), and A passes every episode. Under the soft operators the note uses elsewhere, survival is not (1-rho)^n. The Occam bound O_riv/(en) is a bound on the expected posterior rate of deviation on a fresh input when test and training inputs share a distribution. It is not a bound on the rivals, and O is undefined here. The bound itself checks out: max_rho rho(1-rho)^n is about 1/(en).
FIX: "If every deviation on a training episode is caught and eliminates the rival (hard filtering; T3.4(3)), a rival deviating on a predicate of training measure rho survives n i.i.d. episodes with probability (1-rho)^n. When test inputs come from the training distribution, the expected posterior deviation rate is then at most O_riv/(en), where O_riv is the rivals' total prior odds against A. A schemer's predicate has training measure 0, or a(1-s) with audits, and careful gamers that threshold on detection escape even that (T1.4)."

[math-15] (clarity)
QUOTE: * **Zero drift** needs the *separation condition*, $\operatorname{ess\,inf}_E v\ \ge\ \operatorname{ess\,sup}_N f$ with $\operatorname{ess\,inf}_E v>0$ (T4.1, T4.2).
PROBLEM: Coming right after the correction-only bullet, this reads as if correction-only flags reach zero drift under separation. They do not. With b=c=0, v*=1 and Phi=eps(1-v-bar), which is zero only if v=1 almost everywhere on E. Zero drift under separation needs a bonus or fine that puts v*=(1+c)/(1+b+c) in [sup f, inf v], and bonuses then invite manufactured errors (separation becomes sup max(f, v_m 1_M) <= v*). Also, Phi is a reward advantage per episode (unit reward gap), not drift in nats like D elsewhere in the note.
FIX: "Zero drift needs a design (b,c) whose threshold v*=(1+c)/(1+b+c) lies between ess sup_N f and ess inf_E v, which is possible iff the separation condition holds (T4.1, T4.2). Correction-only flags (v*=1) reach zero only if every predictable error is fully demonstrable. Here 'drift' is G*'s reward advantage over A per episode; multiply by the operator's evidence per unit reward to get nats."

[math-16] (clarity)
QUOTE: Here $a h$ is the rate of audit opportunities and $v$ the rate of real ones.
PROBLEM: The note reuses symbols across tools. v is the rate of real opportunities in Tool 2 and demonstrability in Tool 5 ('a verifier accepts a valid flag with probability $v$'); G5 renames T4's demonstrability 'dem' to avoid exactly this clash. kappa is undefined in Tool 5 ('criterion $\nu>\kappa$') next to kappa_L in Tool 3, and in T4/T1 §6 it is the growth rate of grader blind spots. nu in Tool 5 is a demonstrability growth rate, while nu_I, nu_R in Tool 6 are data shares. lambda in the capture law is per-event evidence under symmetric steps, not lambda_±.
FIX: In Tool 5, write demonstrability as dem ("a verifier accepts a valid flag with probability dem", "eps(1-dem-bar)", "ess inf_E dem >= ess sup_N f"). Define the T4.18 criterion in words: "demonstrability improves faster per unit capability than grader blind spots grow (nu>kappa in T4's exponential toy; kappa here is the blind-spot growth rate, not kappa_L)".

[math-17] (clarity)
QUOTE: Equivalently, the max-divergence (as in differential privacy) $D_\infty(P_{\rm unchecked}\Vert P_{\rm checked})$ must be at most $\xi^\star=\operatorname{logit}\bar p+\ln(\lambda_-/\lambda_+)$.
PROBLEM: Several symbols are used without definition. p-bar here: the equivalence holds, and checks numerically, with p-bar = ah/(ah+v), the share of opportunities that are (always-catching) audits. Also undefined: h (the share of audits that present an opportunity); phi in 'φ/(1+φ)<q†' (the band's prior odds against A); Lambda_U(0); B in '(λ−/ϖ_R)B' (B(M_0)=M_0-1+e^{-M_0}); N in '½ ln N' (G1 has ½ ln(2ζN)); vis; ell(I), Delta_w; x, lambda, P_± in the capture law (which also needs symmetric steps and P_+<P_-); t*_F in the scorecard (the frontier break-even, set by frontier stakes, distinct from training t*); O in 'O/(en)'.
FIX: Add to the Notation paragraph: "p-bar = ah/(ah+v), the share of opportunities that are audits; h, the share of audits that present an opportunity; phi, the invisible band's prior odds against A; t*_F, the frontier break-even, set by stakes rather than by the operator." Define the rest where they first appear, e.g. "captured with probability about (P_+/P_-)^{ceil(x_A/lambda_s)}, where steps are symmetric (lambda_+=lambda_-=lambda_s), P_+<P_- are the uncaught and caught probabilities of a decisive event, and x_A is A's log prior advantage over the low-tail types".

[math-18] (clarity)
QUOTE: | audit indistinguishability | likelihood ratio on the real-looking side $\le e^{\xi^\star}$ |
PROBLEM: Tool 2 talks about 'the lower tail of the likelihood ratio', meaning the audit-to-real ratio f_a/f_r, which must stay above a floor. The scorecard bounds 'the likelihood ratio' above by e^{xi*}, meaning the real-to-audit ratio f_r/f_a. The two are consistent, but only if the reader works out that the same phrase names reciprocal ratios.
FIX: "real-to-audit likelihood ratio f_r/f_a <= e^{xi*} everywhere (equivalently, audit-to-real ratio >= e^{-xi*} on the real-looking side)".

[math-19] (clarity)
QUOTE: | intent as a natural abstraction | near-miss mass $2^{\mathrm{amb}}-1$ below tolerance |
PROBLEM: 2^amb - 1 is the near-misses' prior odds against A (T3.3), not a mass. It can be far above 1, while a mass cannot.
FIX: "near-miss odds against A, 2^amb - 1 (mass 1-2^{-amb}), below tolerance".

[math-20] (clarity)
QUOTE: The prior buys about $L_0/(nD^\star(0))$ generations, logarithmic in the prior odds (T1.11).
PROBLEM: T1.11 is the regime (i) ODE without gamma or erosion, yet the sentence sits under the map with gamma and kappa_L g. On that map, the time to failure in the leaking regime is L_0 divided by the net per-generation loss. The collusion correction is also dropped.
FIX: "The prior buys about L_0/(kappa_L g + nD*(0) - gamma) generations when that denominator is positive (T1.11 has gamma=kappa_L=0, plus a collusion correction of O(ln(D_1/D_0)/(nD_0))), which is logarithmic in the prior odds."

[math-21] (clarity)
QUOTE: Becker's "low probability, high fine" then applies: with a penalty ratio of 99, real-looking audits need only be 1% as frequent as real opportunities.
PROBLEM: The condition is c*ah/v >= lambda_+/lambda_- = 1/99 = 1.0101%, so exactly 1% is slightly too few. The penalty ratio equals lambda_-/lambda_+ only under KL-regularised RL with batch normalisation, operator (D). Under (B) or GRPO with group audits it has no effect (t*=1/2), as the note says elsewhere.
FIX: "...under KL-regularised RL with batch normalisation, a penalty ratio of 99 means real-looking audits need only be about 1% (1/99) as frequent as real opportunities."

[math-22] (clarity)
QUOTE: * **The loop works, in this toy, iff each on-task generation adds alignment through channels outside the grader faster than capability growth and the leak remove it** (Tool 3).
PROBLEM: The note gives three different 'iff's for the same question. Here it is the scalar loop inequality. 'The short answer' says 'iff four conditions hold', which adds the zero-drift classes and slop. Tool 4 says the binding inequality is sp*gamma_chk + gamma_nb > kappa_L g + Lambda_U(0). The scalar inequality is an iff only in the annealed, deterministic, regime (i) map with a single type of rival. No draft proves the four conditions jointly necessary and sufficient.
FIX: "In this toy's deterministic map, the loop's basin exists iff each on-task generation adds alignment, through channels that reach every type, faster than capability growth and the leak remove it (Tools 3 and 4). The other conditions in 'The short answer' (zero-drift classes, slop) are additional requirements." In 'The short answer', replace "iff four conditions hold" with "only if four conditions hold (each is necessary in its own toy; no section proves them jointly sufficient)".

[math-23] (clarity)
QUOTE: A debate is as sound and as complete as its *weakest reachable atomic judgement*: a maximum, not a mean (T4.9).
PROBLEM: 'Weakest' suggests a minimum, while 'a maximum' refers to the error. T4.9 gives f = max_j e_j and v = 1 - max_j e'_j.
FIX: "A debate's gullibility and undemonstrability are the *maximum* error over reachable atomic judgements, not the mean (T4.9): f = max_j e_j, v = 1 - max_j e'_j."

[math-24] (clarity)
QUOTE: A band of mass $\beta$ produces a colluding builder within $K$ generations with probability about $1-(1-\beta)^K$ (T1.7q).
PROBLEM: T1 derives this for independent draws per generation and notes that along a lineage trained further the draws are positively correlated, which lowers the probability toward beta. Without that caveat the formula reads as the general estimate.
FIX: "...with probability up to about 1-(1-beta)^K if each generation is an independent draw. A lineage trained continuously has correlated draws, which lowers this toward beta (T1.7q)."

[math-25] (clarity)
QUOTE: Suppose every unrecognised opportunity carries the same calibrated detection probability $\hat p$, and opportunities arrive at rate $w$.
PROBLEM: In T1.3, w is the rate of *unrecognised* opportunities (u+v, with u=ah(1-s)). In T1.4 it is the rate of all opportunities, with recognised audits at d=1. The note uses one w for both formulas without saying which it is.
FIX: "...and unrecognised opportunities arrive at rate w." In the heterogeneous formula, add "(here w counts all opportunities; recognised audits have d=1)".

[math-26] (clarity)
QUOTE: the salience model sends the odds to a fixed point of about $\log_2(\nu_I/\nu_R)-\mathrm{amb}$
PROBLEM: The expression is a log-odds in bits (T3.13's Delta K), not odds.
FIX: "the salience model sends A's prior log-odds against G to a fixed point of about log2(nu_I/nu_R) - amb bits".

[math-27] (suggestion)
QUOTE: Large plans of defection are profitable whenever $(1-\mathrm{irr})\,\mathrm{tr}\,p_{\rm hon}<1$.
PROBLEM: The inequality holds unless catch, honoured rollback and full reversibility are all certain. Saying so makes the strength of the result visible. G3 says 'a large enough plan'.
FIX: "A large enough plan of defections is profitable unless audits catch it for certain, the rollback is certainly honoured and the gain is fully reversible: formally, whenever (1-irr) tr p_hon < 1 (G3.7)."


######## LENS evidence (16 issues)
OVERALL: I checked every empirical claim and citation in the note against the two literature notes, the drafts and web searches.

**What checks out.** Needham's 0.83 overall AUC, Schoen's rise in awareness, Tice's 45% to 9%, Khan's 76/88 vs 48/60, ImpossibleBench's 76% and 2.9% for GPT-5 (Zhong, Raghunathan and Carlini, 2025), Cundy and Gleave (it exists: arXiv:2505.13787, NeurIPS 2025), Wang et al.'s few-hundred-sample re-alignment, the 0.8% figure from Järviniemi (secondary), and Gerstgrasser's accumulation result. None of the citations is invented.

**Main problems:**
1. **The evaluation-awareness range is wrong.** "AUC of 0.83 to 0.95" treats the best model's overall AUC as a lower bound; chat-only AUCs are 0.71 to 0.77.
2. **Dr. GRPO is misdescribed** as batch-level normalisation. It keeps the per-group mean and drops the per-group standard-deviation division.
3. **The spillover evidence is inverted relative to G1.** G1 reads persona latents and few-sample re-alignment as evidence that shared types move together. G1 also cites Dubiński et al. (2026), who find that such fixes leave misalignment behind contextual triggers, which points to small spillover. The note presents both as evidence for large spillover.
4. **ImpossibleBench is in the wrong row.** The figures are filed as frontier-slice evidence, but G5 says they bound only the training-slice propensity. The note also does not name the model (GPT-5), and two one-off splits are not "a range across task families".
5. **Several citations are overstated:**
   * Cundy and Gleave "matching" G2 (G2 says shape only).
   * Shumailov et al. credited with an error recursion they do not write.
   * Tice's "a fifth survived" rests on post-training numbers that are unverified.
   * The 0.8% figure generalised to all "deliberate collusion".
   * Christiano's basin "made precise".
   * Dai's objection reduced to one of the two places T1 gives, with no citation.
   * Engels et al. given "one difference" where T1 gives two, and their actual findings never stated.
6. **Smaller issues:** the Khan and Schoen figures need their models and conditions, and several cited works are missing from the reference list.

[evidence-0] (error)
QUOTE: The frontier slice is mostly unverified, measured evaluation awareness has an AUC of 0.83 to 0.95, and some standard RL normalisations make penalties ineffective (Tools 1 and 2).
PROBLEM: The figures are wrong as a range. In Needham et al. (2025), 0.83 is the best model's overall AUC (Gemini 2.5 Pro; human baseline 0.92), not a lower bound. Other models score lower overall, chat-only AUCs are 0.71 to 0.77 (L2 §3, confirmed by search), and 0.88 to 0.95 is the agentic subset across models. These AUCs also come from models asked to classify transcripts, not from recognition measured during training.
FIX: Replace with: "The frontier slice is mostly unverified. When asked, frontier models tell evaluation transcripts from deployment ones with AUC up to 0.83 overall (Gemini 2.5 Pro; humans 0.92), 0.88 to 0.95 on agentic transcripts and 0.71 to 0.77 on chat (Needham et al. 2025). Some standard RL normalisations also make penalties ineffective (Tools 1 and 2)."

[evidence-1] (error)
QUOTE: To make penalties deter, use batch-level normalisation (PPO, Dr. GRPO).
PROBLEM: Dr. GRPO (Liu et al. 2025, arXiv:2503.20783) does not use batch-level normalisation. It keeps GRPO's per-group mean baseline and drops the per-group standard-deviation division (and the length normalisation). G5 §2 says this correctly: 'Dr. GRPO drops the std division, which restores the penalty lever.' The same conflation appears in the scorecard's lever 'GRPO with batch normalisation'.
FIX: Replace with: "To make penalties deter, use PPO-style batch-level normalisation, or Dr. GRPO, which drops GRPO's per-group standard-deviation division." In the audit-indistinguishability row of the scorecard, replace "GRPO with batch normalisation" with "PPO-style batch normalisation, or Dr. GRPO (no per-group std division)". Add Liu et al. (2025), arXiv:2503.20783, to the references.

[evidence-2] (misrepresentation)
QUOTE: * Persona latents and re-alignment from a few hundred samples suggest larger values.
PROBLEM: This turns G1's evidence reading upside down. G1 §5 files persona vectors (Chen et al. 2025) and Wang et al.'s (2025) few-hundred-sample re-alignment under 'repair transfers where measured → high sh before the sieve'. That is evidence that *shared* types move together, not that repair reaches *conditional* types. G1 also cites Dubiński et al. (2026, arXiv:2604.25891), who show that Wang-style benign fine-tuning leaves misalignment hidden behind contextual triggers: evidence for *small* sp. G1's only 'sp > 0' evidence is Price et al. (2024), where backdoors keyed to future headlines were removed because the trigger overlaps the training support. The scorecard repeats the error: 'conflicting: sleeper agents persist (low); persona latents and few-sample re-alignment (high)'.
FIX: Replace the bullet with: "* Backdoors keyed to future headlines, which overlap the training support, were removed by HHH fine-tuning (Price et al. 2024): sp > 0 when the trigger overlaps the support. Few-sample re-alignment (Wang et al. 2025) shows that shared personas move together, but common mitigations, post-hoc benign fine-tuning included, leave misalignment behind contextual triggers (Dubiński et al. 2026): evidence for small sp." In the scorecard's spillover row, replace the evidence cell with: "low for sharp triggers: sleeper agents persist (Hubinger 2024); mitigations hide misalignment behind contextual triggers (Dubiński 2026). Positive only when the trigger overlaps training (Price 2024). Few-sample re-alignment (Wang 2025) bears on shared types, not on sp".

[evidence-3] (misrepresentation)
QUOTE: $\varepsilon_F>0$ is near certain; reward hacking on impossible tasks runs from 2.9% to 76% across task families for one frontier model (ImpossibleBench); $w_F$ is unmeasured
PROBLEM: The figures are right but described inaccurately, and they sit under the wrong parameter. (1) The model is GPT-5. 76% is one-off Impossible-SWEbench and 2.9% is one-off Impossible-LiveCodeBench, so this is two of four splits, not a range across families. Conflicting-SWEbench is 54%, and a prompt change takes conflicting-LiveCodeBench from about 92-93% to 1%. (2) The metric is the pass rate on tasks whose tests contradict the specification, which is a propensity given a forced opportunity. G5 §1.3 and its parameter table say explicitly that these numbers estimate the *training-slice* π^ref_X, not the frontier slice or ε_F. Using them as evidence for the frontier slice contradicts G5. (3) The reference list gives no arXiv number.
FIX: Replace with: "ε_F > 0 is near certain. For training-like opportunities only: GPT-5 passes tasks whose tests contradict the spec on 76% of one-off Impossible-SWEbench and 2.9% of one-off Impossible-LiveCodeBench tasks. Prompting or an abort option cuts this sharply, e.g. 54% to 9% on conflicting SWEbench (Zhong, Raghunathan and Carlini 2025). This bounds the training-slice π^ref_X, not the frontier slice. w_F is unmeasured." Reference: "Zhong, Raghunathan and Carlini (2025), ImpossibleBench, arXiv:2510.20270 (ICLR 2026)."

[evidence-4] (overclaim)
QUOTE: This is the model-collapse recursion of Shumailov et al. (2024), decomposed by channel.
PROBLEM: Shumailov et al. do not write an affine error recursion δ_{k+1} = δ_new + Π δ_k with a reproduction number. They show that the tails of the distribution vanish, and variance collapses, when each generation is trained on the previous one's samples in place of real data. G5 calls its recursion 'the expected-error form' and credits Shumailov for the phenomenon only. The note makes it sound as though Shumailov wrote the recursion.
FIX: Replace with: "This is an expected-error analogue of model collapse, decomposed by channel. Shumailov et al. (2024) show that tails vanish when each generation's data is replaced by model output. Gerstgrasser et al. (2024) show that accumulating data bounds the error."

[evidence-5] (overclaim)
QUOTE: suppress gaming in the long run only if their true-positive rate exceeds $t^\star$ (G2.6, G2.7, matching Cundy and Gleave 2025).
PROBLEM: G2 says it 'reproduces the shape, not the numbers'. Cundy and Gleave (arXiv:2505.13787, NeurIPS 2025) never measure t* or a threshold on it. They found that on-policy GRPO against a lie detector learned evasion (deception above 85%) unless the detector's TPR or the KL coefficient was high, and that off-policy DPO kept deception below 25% at realistic TPRs. The on/off-policy and KL factors are not captured by a single TPR > t* condition. The reference list also gives the citation without title or arXiv number.
FIX: Replace with: "(G2.6, G2.7). This is qualitatively consistent with Cundy and Gleave (2025): against a lie detector, on-policy GRPO learned evasion (deception above 85%) unless the detector's true-positive rate or the KL penalty was high, while off-policy DPO kept deception below 25%." Reference: "Cundy and Gleave (2025), 'Preference learning with lie detectors can induce honesty or evasion', arXiv:2505.13787 (NeurIPS 2025)."

[evidence-6] (overclaim)
QUOTE: Tice et al. (2026) moved misalignment from 45% to 9% through pretraining discourse. About a fifth of that shift, measured in log-odds, survived post-training.
PROBLEM: The 45% to 9% figure is in the abstract (6.9B models, upsampled synthetic aligned-AI discourse) and is confirmed. The 'about a fifth' comes from L2's post-training figures of 35% vs 46% for the unfiltered baseline, with no system prompt. L2 does not mark those as verified, and searching could not confirm them; the abstract says only that effects are 'dampened but persist'. The arithmetic is right if the numbers hold (logit gap 2.11 nats before, 0.46 after, ratio 0.22). The scorecard repeats 'about 2 nats in pretraining, about 0.5 after post-training' and files it as evidence on γ, although it is a one-time shift in L_0, not a gain per generation.
FIX: Replace with: "Tice et al. (2026), in 6.9B models, cut a misalignment score from 45% to 9% by upsampling synthetic discourse about aligned AI in pretraining (about 2.1 nats). The abstract says post-training dampens the effect but it persists. L2 reports 35% against 46% for the unfiltered baseline with no system prompt (about 0.46 nats, roughly a fifth), a figure not checked against the paper." In the scorecard, write: "none per generation. A one-time prior shift of about 2 nats in pretraining, about 0.5 after post-training (Tice 2026; post-training figure via L2)".

[evidence-7] (misrepresentation)
QUOTE: self-preference is reliable; deliberate collusion is weak (Schelling-point coordination about 0.8%)
PROBLEM: Neither claim is cited, and the second is broader than its source. The 0.8% is a secondary figure (31 of 3,903 attempts, from a LessWrong review) for one model, Claude 3.7 Sonnet, in one setting: Järviniemi (2025, arXiv:2507.03010), 'Subversion via focal points'. It measures acausal focal-point convergence between isolated instances, not 'deliberate collusion' in general; collusion with pre-shared signals is not tested. The paper also notes that the model sometimes colluded successfully on non-obvious signals. Self-preference (Panickssery, Bowman and Feng 2024) tracks self-recognition, and L2 notes that much LLM-judge self-preference is a preference for low-perplexity text, which is 'reliable but modest'.
FIX: Replace with: "self-preference tracks self-recognition (Panickssery et al. 2024) and is partly a low-perplexity preference. Acausal focal-point collusion between isolated instances is rare: Claude 3.7 Sonnet converged in about 0.8% of attempts (secondary figure; Järviniemi 2025), sometimes on non-obvious signals." Add both papers to the references.

[evidence-8] (clarity)
QUOTE: debate raises judge accuracy (76% and 88% vs 48% and 60%; Khan 2024); weak on tacit intent
PROBLEM: The note does not say which number goes with which judge, or on what task. The figures are confirmed: LLM judges 76% against a 48% naive baseline, human judges 88% against 60%, on QuALITY with information asymmetry. 'Weak on tacit intent' is T4's domain map, not a finding of Khan et al. T4 also cautions that judge accuracy mixes v and f and does not test whether a strategic student can predict judge errors, which is the quantity the row needs.
FIX: Replace with: "debate raises non-expert judge accuracy on QuALITY reading comprehension (LLM judges 76% vs 48%, human judges 88% vs 60%; Khan et al. 2024). This mixes demonstrability and gullibility at one capability gap. Coverage of tacit intent is untested (T4.10)."

[evidence-9] (clarity)
QUOTE: awareness rose after anti-scheming training (Schoen 2025)
PROBLEM: This is accurate but vague, and it leaves out the strongest loop-relevant number. Schoen et al. measured *verbalised* awareness in chain of thought: it rose from 2.3% to 4.5% (o3) and from 0.9% to 5.5% (o4-mini) after anti-scheming training, and from 2% to 20.6% over a capabilities-only RL run. This is a different measure from Needham's elicited AUC, and the capabilities-RL result directly supports 'recognition is the clock of the loop'.
FIX: Replace with: "verbalised evaluation awareness rose after anti-scheming training (o3 2.3%→4.5%, o4-mini 0.9%→5.5%) and from 2% to 20.6% over a capabilities-only RL run (Schoen et al. 2025)".

[evidence-10] (misrepresentation)
QUOTE: This matches Engels et al. (2025) qualitatively, with one difference: a failed step here *raises the next step's loss* instead of ending the chain.
PROBLEM: T1 §6 lists *two* differences: failure feedback, and a regime with D_eff < 0 in which more steps add safety, which a pure capability chain cannot have. It also says the linear growth of the step count is this model's own result, not one Engels et al. report. The note never says what Engels et al. found: the optimal number of oversight steps grows with the capability gap; nested oversight succeeds less than about 52% of the time at a 400 general-Elo gap (Debate 51.7%, Mafia 13.5%, Backdoor Code 10.0%, Wargames 9.4%); and one step is optimal when the overseen side is favoured at fixed Elo.
FIX: Replace with: "This matches Engels et al. (2025) qualitatively. In their Elo-game model of nested oversight, the optimal number of steps grows with the total gap, and nested oversight succeeds less than about 52% of the time at a 400-Elo gap. Two things differ: a failed step here *raises the next step's loss* instead of ending the chain, and when D_eff < 0 more steps can add safety."

[evidence-11] (overclaim)
QUOTE: This makes Christiano's (2017) basin of corrigibility precise: the "more corrigible" part has to come from channels that bypass the grader
PROBLEM: Christiano's argument is about the agent's own motivation: an act-based agent that is approximately corrigible wants to help its overseer correct it, so it tends to become more corrigible. The toy postulates γ and says nothing about why a corrigible generation would produce it, as the note's own previous sentence concedes ('Once γ is postulated this is an accounting identity'). 'Makes precise' overstates; it gives a necessary condition inside the toy.
FIX: Replace with: "This gives a quantitative necessary condition for Christiano's (2017) basin of corrigibility, though not an argument that the basin exists. The 'more corrigible' part has to come from channels that bypass the grader..." In Relation to prior work, keep 'accounting identity plus rigorous corollaries'.

[evidence-12] (misrepresentation)
QUOTE: Dai's objection survives as the question of whether $\gamma$ measures improvement toward the intended disposition or toward what the builders believe it to be.
PROBLEM: Dai's objection ('A broad basin of attraction around human values?', Alignment Forum) is not stated or cited. It is that concluding a corrigible AI is safe seems to require a basin around the overseer's true values as well (L1 §4.1; search confirms). T1 §4.5 places it in *two* places: whether γ tracks intent or the builders' beliefs about intent, and the fact that ε_h(g) and the base ledger L_{b,0} are set from outside the loop. The note keeps only the first.
FIX: Replace with: "Dai's objection, that the argument also needs a basin around the overseer's true values (Dai, 'A broad basin of attraction around human values?', Alignment Forum), appears in two places. One is whether γ measures improvement toward the intended disposition or toward what the builders believe it to be. The other is that the human grader's error ε_h(g) and the base ledger are set from outside the loop." Add the post to the references; it follows Dai's December 2021 'Morality is Scary', so its date is 2022 or later, and the exact date should be checked.

[evidence-13] (clarity)
QUOTE: Needham et al. (2025) measure an AUC of 0.83 overall and 0.88 to 0.95 on agentic transcripts.
PROBLEM: 0.83 is the best model's figure (Gemini 2.5 Pro), not an aggregate. The 0.88 to 0.95 agentic range is a range across models taken from L2; searching confirmed 0.95 only via a secondary source. The measurement asks models directly whether a transcript is an evaluation, which may differ from the implicit detection probability d that the formula uses.
FIX: Replace with: "Needham et al. (2025) find that, when asked, the best model (Gemini 2.5 Pro) separates evaluation from deployment transcripts with AUC 0.83 overall (humans 0.92), and models reach 0.88 to 0.95 on agentic transcripts. These are elicited judgements, so they bound recognition only roughly."

[evidence-14] (overclaim)
QUOTE: trusted anchors (accumulate data, don't replace it; Gerstgrasser et al. 2024).
PROBLEM: Gerstgrasser et al. show that keeping all past real and synthetic data bounds test error: proved for linear regression, shown empirically for LMs, diffusion models and VAEs. Their result is about distributional degradation, not systematic shared errors such as buggy tests or wrong references, and it holds even though the real-data share falls like 1/k. G5's claim that anchors at share α scale Π by about 1−α is G5's own modelling assumption, not their result.
FIX: Replace with: "trusted anchors: keep human or early-generation data and graders in every mix. Gerstgrasser et al. (2024) show that accumulating data, rather than replacing it, bounds model-collapse error. That anchors cut Π for systematic slop is G5's assumption."

[evidence-15] (suggestion)
QUOTE: The sections carry full references. The ones cited above are:
PROBLEM: Several works the note relies on are missing from the list, and some entries are incomplete. Missing: Hubinger et al. (2024), sleeper agents, arXiv:2401.05566; Price et al. (2024), future-event backdoor triggers; Wang et al. (2025), persona features, arXiv:2506.19823; Dubiński et al. (2026), arXiv:2604.25891; Panickssery, Bowman and Feng (2024), arXiv:2404.13076; Järviniemi (2025), arXiv:2507.03010; Dai, 'A broad basin of attraction around human values?'; Christiano (2021), 'Low-stakes alignment' (the source of 'low-stakes online training'); Liu et al. (2025), Dr. GRPO, arXiv:2503.20783; Barnes and Christiano (2020), obfuscated arguments; Burns et al. (2023), weak-to-strong, arXiv:2312.09390. Incomplete: Cundy and Gleave (2025) has no title or arXiv number; ImpossibleBench has no arXiv number; Shumailov et al. has no volume.
FIX: Add the missing entries above. Complete these: "Cundy and Gleave (2025), 'Preference learning with lie detectors can induce honesty or evasion', arXiv:2505.13787 (NeurIPS 2025)"; "Zhong, Raghunathan and Carlini (2025), ImpossibleBench, arXiv:2510.20270"; "Shumailov et al. (2024), Nature 631, 755–759".


######## LENS reader (26 issues)
OVERALL: The one-picture framing is right and useful. Everything turns on the support of trusted evidence, and the note's core results trace correctly to the drafts: the master formula, the essential-infimum condition, the frontier-slice leak, the max-divergence audit target with its AUC envelope, the GRPO cancellation, the leak–repair asymmetry and spillover, and the slop threshold below 1. Spot checks of the numbers hold up: the Tice log-odds (2.11 and 0.46 nats), Khan's debate figures, Needham's AUCs, the K/(K+1) value, and the 1.4–2.8e-5 drift tolerance.

The problems are in the parts a reader would lean on first.

1. The summary logic is inconsistent. "The short answer" claims "iff four conditions" while "One picture" claims "iff" one condition. Condition 1 (zero leak) is not necessary when condition 2 allows a leak to be paid for by gamma.
2. The opening sentences of "One picture" are wrong or too broad:
   * "Only where they behave differently" fails under persona-logit gradients, which the note itself later gives sp≈1/2 for.
   * "a grader can make them behave differently only where it can check" inverts the logic.
   * "outside it training cannot sort" contradicts the leak bullet.
   * "inside it training sorts" ignores frozen best responders.
3. Several statements misstate the drafts or skip their errata:
   * the best-of-K break-even has no direction attached, and the attractor at about 0.7 gaming under small steps is missing;
   * the noise errata on annealed and quenched readings are dropped;
   * protection that is linear in the odds is called "fragile", although G5 calls it robust for on-policy updates;
   * Tool 3's gamma counts honeypots and verifiable task classes, which G1 discounts by sp;
   * T4's map lists code and mathematics as coverable, although T4 lists "no backdoor" and "proof sketch is sound" as not coverable;
   * the detector condition should use the true-positive rate on concealed gaming, and output filters are limited by false positives, not by tpr;
   * ImpossibleBench rates are cited as evidence on epsilon_F, but they measure propensity given an opportunity.
4. Some claims overreach: "not by incentives", "Honesty is the keystone", and honesty detection "need not degrade with capability" (G4 says "coherence", and its basin is finite when rt<nr).

For the reader, the note is too dense for "a few things". There are seven tools, roughly 60 sub-results, a scorecard and 12 rules, and many symbols are never defined (phi, Lambda_U, p-bar, h, varpi_R, vis, nu/kappa, x, P±, t*_F, gamma_chk). Several key terms are used before they are defined: break-even, frozen, frequency-independent operators, channel A, and annealed/quenched, whose glosses are cryptic.

- **Most useful addition:** one ledger equation, L_{k+1}=L_k+sp·γ_chk+γ_nb−κ_L g−[frontier leak]−[recognition leak], with each tool tagged to the term it moves. Add T1's scale anchor next to it: a 10% slice at 5% error leaks 11.5 nats per generation against 12.2 nats of audit restoring force.
- **Most useful cut:** move Tool 7's G3 detail, the relation-to-prior-work table and the "New here" list to the drafts, and remove the duplicated "where the toy is wrong" list.

The note does respect the user's preferences: it is technical, works in toy models, and ends in design rules.

[reader-0] (error)
QUOTE: In the toy, the loop stays on task over many generations iff four conditions hold.
PROBLEM: These conditions are not jointly necessary as stated. Condition 1 requires zero rewarded gaming at the aligned end, but condition 2 (and T1.10i) lets the loop survive a positive leak nD*(0) if gamma exceeds it. The note's own 'One picture' gives a different 'iff' with one condition. The four conditions come from different toy models with different assumptions (T1 scalar map, G1 cells, G5 slop forms), so no 'iff' theorem across them exists.
FIX: Replace with: "In the toy, four conditions decide whether the loop stays on task. Each is necessary in its own sub-model; together they are a checklist, not a theorem." Recast condition 1 as the main lever on condition 2's leak term: "1. **The leak at the aligned end is small.** Ideally no rewarded gaming survives ... (this is the nD*(0) term in condition 2; driving it to zero is the cheapest way to satisfy 2)." In One picture, change "The loop works, in this toy, iff" to "The core loop condition (T1.10i, refined by G1.12) is that".

[reader-1] (error)
QUOTE: Training can change the odds between two dispositions only on episodes where they behave differently (T1.1). A grader can make them behave differently only where it can check.
PROBLEM: (a) T1.1 holds only for frequency-independent operators (Bayes, replicator, KL-tilt). G1 §0 says T1.1's sentence about 'REINFORCE on mixture logits' is false, and the note itself later gives sp≈1/2 under persona-logit gradients and lists (D′) as breaking proxy-equivalence. (b) The second sentence inverts the logic. Dispositions behave differently on opportunities, which are exactly where the grader is predictably wrong and so cannot check. What needs checking is that the difference is scored in A's favour.
FIX: "Under frequency-independent updates (Bayes, replicator, KL-tilt), training changes the odds between two dispositions only on episodes where they behave differently (T1.1). Where that difference is checked, it is scored in favour of the intended disposition; where it is not, it is scored in favour of whichever output the grader prefers. (Under plain gradients on shared persona logits this fails, and that failure is the spillover of Tool 4.)"

[reader-2] (error)
QUOTE: * **Inside it, training sorts dispositions.** How well it sorts depends on the update operator and on how audits are designed (Tools 1 and 2).
* **Outside it, training cannot sort.**
PROBLEM: Both bullets are too broad. Inside the support, a best responder stops gaming and is frozen at its prior odds, not removed (T1.4, class (b) of Tool 1). Outside the support, training does sort, in the wrong direction: the note's next bullet says rewarded gaming there is a leak. 'Cannot sort' also conflicts with spillover, which is nonzero off K under persona-logit operators.
FIX: "* **Inside it, training removes dispositions that game there.** A best responder simply stops gaming there and is frozen at its prior odds. How well training removes the rest depends on the operator and the audit design (Tools 1 and 2).
* **Outside it, training cannot sort toward the intended disposition.** It is neutral where errors are unpredictable and favours gamers where they are predictable (the leak). Three things decide behaviour there: ..."

[reader-3] (error)
QUOTE: | on-policy best-of-$K$ filtering | between $1/(K{+}1)$ and $K/(K{+}1)$, depending on the current gaming rate and the step size | G5.1 |
PROBLEM: The range holds only under small steps (G5.1's expected-probability break-even). Under T1's Λ-jump Bayes reading, the log-odds break-even near A is about π_X (0.010, 0.038, 0.072, 0.216 at K=1,4,8,32), which lies outside the stated range. The cell also hides the direction that matters. Under small steps the break-even is K/(K+1) near A (0.88 at K=8), so near the aligned end best-of-K filtering needs detection above 0.88 to restore, and otherwise it runs to an interior gaming rate (0.715 at K=8, p̂=0.3). This is a central practical result for self-training loops (STaR, ReST, expert iteration), and the note never states it.
FIX: Cell: "small steps: $K/(K{+}1)$ near $A$, falling to $1/(K{+}1)$ near $G$, with an interior attractor (about 0.7 gaming at $K=8$, $\hat p=0.3$); keeping all passing samples gives 1/2. Λ-sized jumps: log-odds break-even ≈ $\pi_X$ near $A$, yet the probability of capture still rises". In Tool 1, replace "Small steps versus large jumps change the qualitative result for on-policy filtering (G5.1)" with "**Rejection sampling leaks near A under small steps** (G5.1): the break-even there is K/(K+1), so best-of-8 filtering needs audits to catch about 88% of unrecognised opportunities, and otherwise settles at a high gaming rate. T1's 'automatically restoring near A' holds only for the typical run under Λ-sized jumps." Add to design rule 4: "Avoid large-K best-of-K filtering near the aligned end unless detection exceeds K/(K+1)."

[reader-4] (misrepresentation)
QUOTE: The exceptions are fragile: plain policy gradient on mixture logits, and on-policy discovery delays, give protection linear in the odds (§5 of T1, G5.3b).
PROBLEM: T1 §5 calls a different thing fragile: its own D₀≈0 regime, which needs the leak below D₁/O. G5.3b says the opposite about discovery: 'For on-policy updates, linear-in-odds protection is robust, because discovery is linear in π_X'. The vulnerability G5 identifies is bypass by off-policy data and shared factors, not fragility.
FIX: "Two exceptions give protection linear in the odds: plain policy gradient on mixture logits ((D′), T1 §5), and any on-policy rule that cannot update until it samples X (G5.3b, at least 1+O draws in expectation). For on-policy training this protection is robust, but off-policy data (distillation, preference pairs, model-written SFT) and shared factors bypass it. T1.11's own linear-in-odds regime, which needs the aligned-end leak below D₁/O, is the fragile one."

[reader-5] (misrepresentation)
QUOTE: * **With collusion the loop is bistable** under the annealed reading. The separatrix is a tolerable off-task share $q^\dagger$, and the invisible band must be smaller than that: $\varphi/(1+\varphi)<q^\dagger$ (T1.7, T1.9). Under the quenched reading there is no separatrix.
PROBLEM: This omits T1 erratum 1. With (B) training noise, neither reading has a sharp separatrix. The annealed reading is the more pessimistic at every tabulated L0. The two nearly agree at high L0 (0.13 vs 0.11 at odds 10^6), and quenched failure at L0=3 is 0.29, not 0.047. The 'Where the toy is likely wrong' item ('The loop's qualitative dynamics differ between the two readings') repeats the withdrawn picture. φ is also never defined.
FIX: "* **With collusion, the deterministic annealed map is bistable**, with separatrix at a tolerable off-task share q† (T1.7). The invisible band, of prior mass φ relative to A, must satisfy φ/(1+φ)<q† (T1.9). With training noise, neither the annealed nor the quenched reading has a sharp separatrix. Failure risk is concentrated in the first one or two generations, and at high prior odds the two readings nearly agree (about 0.11 to 0.13 failure at odds 10^6 in T1's example; T1 errata). Under the quenched reading, a band of mass β produces a colluding builder within K generations with probability up to 1−(1−β)^K, lower if draws along a lineage are correlated." In 'Where the toy is likely wrong', replace the annealed/quenched bullet with: "Annealed versus quenched matters most for the invisible band (union bound over generations) and much less once training noise is included."

[reader-6] (misrepresentation)
QUOTE: * $\gamma$ is what an on-task generation adds outside the grader: better data and priors, honeypots made from real work, internals-based checks, and new verifiable task classes.
PROBLEM: G1 §4 splits T1's gamma. Honeypots, verifiable task classes and trusted demonstrations are checkable training (γ_chk), which reaches conditional gamers only with factor sp. Only prior shaping, declarative data and internals reach every type (γ_nb). The note's own Tool 4 says the scalar loop overcounts checkable training when sp<1, but Tool 3, the One-picture 'iff' and Short-answer condition 2 all use the unsplit gamma.
FIX: "* γ is what an on-task generation adds outside the grader. It has two parts (G1.12). γ_chk is checkable improvement (honeypots from real work, new verifiable task classes, trusted demonstrations); it reaches conditional gamers only with factor sp. γ_nb reaches every type (data and prior shaping, internals-based checks)." In Short answer condition 2, write "sp·γ_chk+γ_nb exceeds capability erosion plus the leak".

[reader-7] (misrepresentation)
QUOTE: So code, mathematics and empirical claims are coverable, while research taste and conceptual alignment judgement are not.
PROBLEM: T4.10 divides by the form of the claim, not by domain. Its table lists "this code has no backdoor" and "this proof sketch is sound" as universal claims with v≈f, which the protocol does not cover. A skeptical reader would reject the claim that code is coverable. The domain version also hides the point that graders and audits mostly require universal claims ('this grader has no exploitable hole').
FIX: "So flags showing that the grader-preferred output is bad (a failing test, a counterexample, a quoted spec violation) are coverable. Flags showing that an output is fine ('this code has no backdoor', 'this proof sketch is sound') and tacit-intent judgements are not, because of obfuscation. **The loop's constitutive tasks (certifying a grader, an audit or a dataset as sound) are mostly of the second kind.**"

[reader-8] (misrepresentation)
QUOTE: * *Detectors used as penalties* suppress gaming in the long run only if their true-positive rate exceeds $t^\star$ (G2.6, G2.7, matching Cundy and Gleave 2025). Otherwise they teach concealment.
PROBLEM: G2.6's condition is tpr_c > t*, where tpr_c is the true-positive rate on the best concealment the policy can reach, not on plain gaming. G4.5 adds a false-positive term for honesty probes used in training: D_sim ∝ t* − tpr + (1−t*)fpr_Δ. Output filters are limited by false positives, not by tpr. Design rule 6 repeats the error: "unless their true-positive rate exceeds $t^\star$".
FIX: Tool 2: "suppress gaming in the long run only if their true-positive rate on the best concealment the policy can learn, tpr_c, exceeds t* (G2.6, G2.7). For honesty probes in the reward, false positives on honest disagreement raise the bar to t*+(1−t*)·fpr (G4.5)." Rule 6: "Use detectors and probes for measurement and lineage-level decisions (gate, roll back). Use them as rewards only if tpr on concealed gaming exceeds t*+(1−t*)·fpr. Do not use them as per-output filters whose survivors become data: those favour other types by up to n·w·ln(1/(1−fpr)) per generation whatever the tpr."

[reader-9] (misrepresentation)
QUOTE: $\varepsilon_F>0$ is near certain; reward hacking on impossible tasks runs from 2.9% to 76% across task families for one frontier model (ImpossibleBench)
PROBLEM: G5 §1.3 says explicitly that these are 'propensities given a forced opportunity, so they estimate the training-slice π^ref_X; they are not base rates'. They do not bear on ε_F or w_F. The range also covers only the one-off variants; G5 also quotes 54% on conflicting SWE-bench and 92% on conflicting LiveCodeBench.
FIX: Current-evidence cell: "ε_F>0 is near certain but unmeasured; w_F unmeasured. ImpossibleBench measures propensity given an opportunity (π_X^ref, the quantity that sets discovery delay): GPT-5 cheats on 2.9% to 76% of one-off impossible tasks, and up to 92% on conflicting variants, and prompt changes move it by an order of magnitude."

[reader-10] (misrepresentation)
QUOTE: * **GRPO.** With audits applied to whole groups, the break-even is exactly $1/2$ whatever the penalty, because normalising within a group removes the reward scale. With per-sample flags, penalties saturate at about ten times the reward.
PROBLEM: This omits G5's key qualifier that with per-sample flags the penalty lever 'vanish[es] at low π_X'. As π_X→0, groups containing an X have one X, hence two reward levels, and t*→1/2 for every penalty (0.46 at π_X=0.05). The aligned end, where the loop operates, is exactly where per-sample flags stop working. G5.4b's point that GRPO's KL term holds back almost no gaming is also missing.
FIX: "With per-sample flags, penalties partly survive at high gaming rates (t*≈0.32 at π_X=0.3), saturate at about ten times the reward, and lose their effect at the aligned end (t*→1/2 as π_X→0). GRPO's KL term holds back almost no gaming (G5.4b). To make penalties deter, use batch-level normalisation (PPO, Dr. GRPO)."

[reader-11] (overclaim)
QUOTE: This is Becker's (1968) deterrence condition. What is new is that the threshold is set by the *training operator*, through how much evidence an event carries, and not by incentives.
PROBLEM: Under KL-regularised RL, which is the operator the note recommends, t*=Δ₊/(Δ₊+Δ₋) is set exactly by the reward gaps, that is, by incentives. The novelty is that for some operators, such as rejection sampling and GRPO with group-level audits, incentives drop out, not that they never matter.
FIX: "This is Becker's (1968) deterrence condition, with the fine and the gain replaced by the evidence each event carries under the training operator. For KL-regularised RL this reduces to the reward gaps. For rejection sampling or GRPO with group-level audits the penalty size drops out entirely."

[reader-12] (overclaim)
QUOTE: **Honesty is the keystone** (G4).
* **Internals decode rather than recompute.** For a single query, a behavioural check must *recompute* the model's belief, which fails beyond the checker's competence. An internals check need only *decode* it. Honesty is therefore the one disposition for which frontier detection need not degrade with capability.
PROBLEM: G4's takeaway says 'does not degrade with *coherence*' and labels 'decoding is cheap' heuristic. G4.13 says honesty's basin lasts only about (K_c0−K*)/(nr−rt) generations when red-teaming gains rt fall short of capability reach nr, so detection does erode with capability through concealment. 'The one disposition' is not claimed in G4. 'Keystone' also sits badly with the note's own bullet capping honesty-to-intent transfer at −ln(1−vis) nats.
FIX: Heading: "**Honesty: the best-placed disposition for frontier checks** (G4)." Bullet ending: "So for honesty, unlike intent, frontier detection need not require the checker to match the model's competence. This holds only for knowing deviations, only if the probe's own ELK problem is solved across the gap, and only while concealment does not outpace red-teaming (G4.13)." Define vis where the transfer cap appears: "vis, the share of intent failures the model knows about".

[reader-13] (clarity)
QUOTE: Under frequency-independent operators their odds stay at the prior forever
PROBLEM: 'Frequency-independent' is used here (Tool 1) before it is defined. Tool 4 defines it only by example. 'Frozen', 'channel A' and 'break-even' are also used before they are defined (Short answer, Tool 1). The annealed/quenched glosses ('the posterior mass is a share of builder work') are too terse for the distinction to be useful.
FIX: Add to 'The toy in one page': "**Frequency-independent (FI) operators** multiply each disposition's weight by a factor that depends only on that disposition's own policy at the input: Bayes, replicator, KL-tilt, rejection sampling. Plain gradients on shared persona logits are not FI. **Frozen**: odds against A stay at their prior value; training neither raises nor lowers them. **Annealed**: the trained model is a mixture, and μ_k(θ) is the fraction of the next grader's construction done by θ (fits personas sampled per episode). **Quenched**: the trained model is one disposition drawn from the posterior, which builds the whole next grader (fits coherent schemers)." At the first use of channel A in Tool 1: "(an inoculation prompt that *requests* X, so the intent-follower emits X too and, by T1.1, the slice selects nothing)". In Short answer condition 1, gloss t*: "(the detection probability above which a caught event outweighs a rewarded one under the training operator)".

[reader-14] (clarity)
QUOTE: Equivalently, the max-divergence (as in differential privacy) $D_\infty(P_{\rm unchecked}\Vert P_{\rm checked})$ must be at most $\xi^\star=\operatorname{logit}\bar p+\ln(\lambda_-/\lambda_+)$.
PROBLEM: p̄ and h are undefined, and so is the implicit requirement ξ*≥0, that is, pooled detection p̄ ≥ t*. Many other symbols are also undefined: φ (Tool 3), Λ_U(0) and γ_chk (Tool 4), ϖ_R and 𝓑 (Tool 2), x and P± (Tool 3 noise), ℓ(I), Δ_w and O (Tool 6), ν and κ (Tool 5, clashing with ν_I and κ_L), n_dep, Υ, vis, t*_F, ε_h(g), Δε and a. For a reader checking the maths, each one is a dead end.
FIX: Here: "where p̄=ah/(ah+v) is the overall share of opportunities that are audits (h is the probability that an audited episode presents an opportunity), so the condition is satisfiable only if p̄ ≥ t*." Then either define each listed symbol at first use in one clause (e.g. "Λ_U(0), the per-generation leak on cells outside the support at the aligned end"; "ν>κ: demonstrability improves faster than blind spots grow") or drop the formula and keep the words.

[reader-15] (clarity)
QUOTE: the salience model sends the odds to a fixed point of about $\log_2(\nu_I/\nu_R)-\mathrm{amb}$
PROBLEM: The expression is ΔK, the log₂-odds in bits, not 'the odds'. Everywhere else the note uses nats, so the unit switch goes unmarked.
FIX: "the salience model sends A's prior advantage over G to a fixed point of about log₂(ν_I/ν_R)−amb **bits** (multiply by ln 2 for nats), where ν_I and ν_R are the shares of the loop's data about intent and about grading".

[reader-16] (clarity)
QUOTE: | audit indistinguishability | likelihood ratio on the real-looking side $\le e^{\xi^\star}$ | AUC 0.83 overall, 0.88 to 0.95 agentic (Needham 2025); awareness rose after anti-scheming training (Schoen 2025) | probes at the confident-real corner of the ROC curve; difference-in-differences on a held-out audit family | audits from real transcripts; planted flaws; GRPO with batch normalisation |
PROBLEM: Batch normalisation does nothing for indistinguishability. It restores the penalty lever, which moves t* (and so ξ*). Listed here, it reads as a recognition countermeasure.
FIX: Levers cell: "audits from real transcripts; planted flaws; a larger λ₋/λ₊ (which raises ξ*, e.g. PPO or Dr. GRPO instead of group-normalised GRPO)".

[reader-17] (clarity)
QUOTE: * **Correction-only flags** ($b=c=0$: correct the score, pay no bonus, charge no fine) cut the gap between $A$ and $G$ on error cells to the undemonstrable share. The residual drift is $\varepsilon(1-\bar v)$.
* **Zero drift** needs the *separation condition*
PROBLEM: The residual is in reward-gap units against a best responder, not nats per episode as 'drift' means elsewhere in the note. With b=c=0 the challenge threshold is v*=1, so zero drift needs v=1 almost everywhere. The separation condition is what a tuned (b,c) can achieve, and the bullet order suggests it applies to correction-only flags.
FIX: "The best responder's residual reward advantage is ε(1−v̄) per episode, in units of the grader's reward gap (T4.1). With bonuses and fines tuned, zero residual is possible iff the *separation condition* holds ... ; correction-only flags reach zero only where every error is demonstrable."

[reader-18] (clarity)
QUOTE: A rule that does not update until $X$ is sampled needs at least $1+O_F$ draws to flip
PROBLEM: G5.3b bounds the *expected* time to flip. A single run can flip on the first draw.
FIX: "needs at least 1+O_F draws to flip in expectation"

[reader-19] (clarity)
QUOTE: Becker's "low probability, high fine" then applies: with a penalty ratio of 99, real-looking audits need only be 1% as frequent as real opportunities.
PROBLEM: This works only under operators where λ₋/λ₊ is under the designer's control (KL-RL or PPO with batch normalisation). Under rejection sampling λ₋=λ₊, and under GRPO with group-level audits the ratio is pinned at 1. The reader may assume it is generic.
FIX: Append: "(This needs an operator where λ₋/λ₊ is designer-set, such as KL-regularised RL or PPO; under rejection sampling or group-normalised GRPO the ratio is 1, and real-looking audits must match real opportunities one for one.)"

[reader-20] (clarity)
QUOTE:   RL only cuts independent noise.
PROBLEM: This is ambiguous. It sits after a list of what cuts Π and reads as 'RL is a lever that cuts independent noise'. The intended point (G5.6) is that expected-reward RL does not copy independent grader noise but does copy systematic slop.
FIX: "Switching from imitation to expected-reward RL removes only the independent-noise part of Π; systematic, shared errors are copied by every operator."

[reader-21] (clarity)
QUOTE: * **Every number in the main text is illustrative**, except the measurements quoted from the literature.
PROBLEM: Several numbers are exact results of the toy, not parameter-dependent: t*=1/2 under GRPO, K/(K+1), 1+O, Π_c<1. This contradicts the header's definition of 'illustrative'.
FIX: "Every number that depends on chosen parameters (hazards, nats per generation, generation counts, sp thresholds) is illustrative. Exact toy results (break-evens, bounds) and literature measurements are not."

[reader-22] (suggestion)
QUOTE: The toy is most likely wrong in two places:
* **Selection versus learning.** It mostly selects among dispositions present in the prior. Training can also *create* recognition and concealment. G2 handles part of this.
* **Simple type spaces.** Real dispositions may have structure the toy's types do not capture.
PROBLEM: This duplicates the first two bullets of 'Where the toy is likely wrong'. The note is already long for a request for 'a few things'.
FIX: Replace with one line: "Where the toy is most likely wrong is listed at the end; the two biggest risks are selection versus learning and type spaces that are too simple."

[reader-23] (suggestion)
QUOTE: ## One picture
PROBLEM: The single most useful addition for this reader would be one equation that every tool modifies, with a scale anchor. The note gives the pieces in four places (Tool 1's slice leak, Tool 2's recognition leak, Tool 3's map, Tool 4's sp form) but never puts them together. Without magnitudes, the reader cannot see what dominates. T1.4d gives one: a frontier slice of 10% share at 5% error leaks 11.5 nats per generation, against 12.2 nats of restoring force from the whole honeypot regime.
FIX: Add at the end of 'One picture': "Per generation, in the toy (G1.12, T1.4c–d, T1.10i):
$$L_{k+1}-L_k=\underbrace{\mathrm{sp}\,\gamma_{\rm chk}+\gamma_{\rm nb}}_{\text{Tools 4–6}}-\underbrace{\kappa_Lg}_{\text{capability}}-\underbrace{nw_F(\lambda_++\lambda_-)\varepsilon_F(t^\star-d_F)^+}_{\text{frontier leak, Tools 1, 5, 7}}-\underbrace{n\,w\,(\lambda_++\lambda_-)\,\mathbb E_{\rm checked}[(t^\star-d)^+]}_{\text{recognition leak, Tool 2}}$$
with slop (Tool 7) acting by devaluing γ and raising ε_F. Scale: in T1's example, a 10% frontier slice at 5% error leaks 11.5 nats per generation, about the whole audit regime's restoring force of 12.2." Then each tool can open by naming its term.

[reader-24] (suggestion)
QUOTE: **Model.** Treat a disposition as a *gaming region* over cells of task space.
PROBLEM: Several draft takeaways that matter to a practitioner running such a loop are missing. (1) G5.4: the KL anchor protects outputs, not latents, so a shift bought in training reaches the frontier through a shared factor. (2) T3.9: the prior can decide the invisible classes only with about log₂(K/δ)≈11.6 bits per generation against every zero-drift class (K=30, δ=1%). (3) G4.4b: the only restoring force against belief capture is verified downstream use of captured beliefs. (4) G2.8: about one bit of reachable exploit complexity per doubling of RL episodes. Items (1) and (2) bear directly on 'whether generalization tricks keep the loop on task'.
FIX: Add to Tool 4 after the spillover bullets: "**KL anchors protect outputs, not latents** (G5.4): what resists gaming is the reference policy's propensity for X on training prompts, and prompts outside training carry no KL charge, so a shift bought in training can reach the frontier through a shared factor." Add to Tool 6, under 'The prior must decide the zero-drift classes': "Quantitatively, a union bound over K generations needs about log₂(K/δ) bits per generation against every zero-drift class: 11.6 bits for K=30, δ=1% (T3.9, illustrative)." Add to Tool 5's belief-capture bullet: "Its only restoring force is routing frontier beliefs into checkable downstream tasks (G4.4b)."

[reader-25] (suggestion)
QUOTE: # Will the loop stay on task? Seven tools from a toy model
PROBLEM: The user asked for 'a few things'. Seven tools, roughly 60 sub-results, a nine-row scorecard, 12 design rules, a prior-work table and a 'New here' list make a reference document, not a thinking aid. Tool 7's G3 halting-rule detail and the prior-work and 'New here' sections are where the cost per insight is lowest. Tool 1 and Tool 4 carry the most new thinking about generalization.
FIX: Keep three core tools in the main text: (1) break-even and the three classes of rival, including the frontier slice; (2) support of trusted evidence and spillover, including 'which trigger to fear'; (3) the loop equation, including slop as γ-devaluation. Present audits, protocols and honesty, priors, and observability as 'levers on the terms', at about half their current length. Move the prior-work table and 'New here' list to an appendix or leave them to the drafts. Keep the scorecard and rules, but cross-reference rather than restate them.
