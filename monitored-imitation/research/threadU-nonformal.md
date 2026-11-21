# Thread U: verification without a machine verifier

*Research note by Claude (Anthropic) on [`../verified-slack.md`](../verified-slack.md), reading it with threads F, L, Q, S and T. Draft; not refereed. No existing file was changed.*
* *Code:* [`threadU_verify.py`](threadU_verify.py), output [`threadU_verify.out`](threadU_verify.out) (12 s, fixed seeds). Run with `python3 -B threadU_verify.py`.
* *Tags:* **[F]** I fetched the page or PDF this session and read the fact there; **[S]** confirmed only through search summaries; **[M]** my memory, not checked; **[thread X]** this folder. **[J]** marks my own judgments, which most model inputs are.

## Answers in brief

1. **What f has to be.** Under VSI the output failure rate is F ≈ p·w·r̄·f_V, where r̄ is the number of distinct wrong claims verified per failing problem (1–1.6 with verdict caching). At central values (p = 0.3, r̄ = 1.3), F ≤ 5% needs f_V ≤ 0.29 in theory (w = 0.45), 0.23 in software, 0.17 in empirical work and 0.16 in judgment work. A single careful reader gives about 0.43, 0.45, 0.70 and 0.64 [J]. So each domain needs f_V cut by a factor of 1.5 to 4.
2. **Verification by use** alone is no better than reading: f = 0.53 in theory. But it catches different errors: false checkable claims (miss 0.12) and mismatches with the goal (0.30). Reading plus use by a second person takes f from 0.43 to 0.27, removing 38% of misses. In software, use is the strongest single lever: independent tests, fuzzing and differential tests take f from 0.45 to 0.13.
3. **Independent verifiers repeat each other's misses.** Fitted to three data sets (Panko's spreadsheet triads, mammography double reading, Ulery's retests), the latent correlation of misses is r ≈ 0.45–0.75. At f = 0.4 and r = 0.5:
   * a second reader leaves 0.24, not the 0.16 that independence predicts;
   * five readers leave 0.10.

   Framing the work as a colleague's matters only if the imitated human verifies, which it should not do anyway (contamination). Adversarial framing ("this is wrong; find the error") multiplies the miss rate by 0.54 on easy errors and 0.87 on subtle ones (Braz et al. [F]). I use 0.85, which takes f from 0.43 to 0.38.
4. **Partial machine verification** has the scaffold run every computation and retrieve every citation. It removes about 20% of f in theory (0.43 → 0.34) and 15–20% in empirical work. Formalizing the key lemmas removes another 24% of what is left (0.122 → 0.093), at +5% n₀ and 0.01n₀ of statement review. In software, tests and fuzzing remove 50–70%.
5. **Decomposed (cone) checking.** A single plausible slip gets no compounding: f_cone = f_entry. Its gain is the more focused local check (0.33 against 0.43 for one referee) and the location of the error.
   * *Different verifiers per entry* help only when several entries are invalid: at f_e = 0.25 with two invalid entries, 0.084 against 0.119.
   * *False flags* grow with the cone: 1 − (1−e)^c is 39% at e = 0.005 and c = 100, so adjudication is mandatory.
   * *The typed-notebook instruction* (+30% n₀, 70% feasible) costs more than the check gains. In the model V-cone scores below a located single read (32% against 47%). AI critics that segment the proof get the focus without the instruction.
6. **Delayed checks by consequence** are the only thing that touches claims false in the world. Adding them takes empirical f from 0.27 to 0.14. But outputs become provisional for r̄Δ, about 1–5 years, and replication by humans costs about 0.15n₀ per problem. Their best use is auditing a random sample, which measures F.
7. **Criticism carries no risk to correctness, as hints do not; debate adds little.** A critic can only add rejections, so a useless or hostile critic costs effort, never correctness.
   * *AI critics:* three model families, adversarially prompted, with an expert (not the imitated human) judging *located* objections. They take theory's f from 0.43 to 0.18 when added to a reader. The 2026 evidence: on real proof errors from published papers, recall is 55% zero-shot and 90% with segmented review [F]; on subtle injected errors, it is 57–73% for the strongest reviewers [S].
   * *The imitated human as critic* is blind where the imitator is: f = 0.68 alone.
   * *An AI defender (debate)* cuts upheld false objections from 0.41 to 0.23, but raises f from 0.152 to 0.165 (persuasive or obfuscated rebuttals). Use it only to adjudicate contested objections.
8. **A new cost the folder does not count: unlocated rejections.** If V rejects the human's own correct result without saying where, VSI searches and then scans the whole run before it abstains, about 1.5n₀ task queries. Requiring *located* objections cuts V-human's cost per problem from 0.16n₀ to 0.08n₀, and its model P(works) rises from 35% to 47%. Route (i) handles a located objection; if the flagged step turns out to be the human's own, a second judge decides.
9. **The best protocols** (§4). Each is VSI with the V named.
   * *Informal theory:* machine checks, three AI critics, and one adversarial expert reader who judges objections (LEAN). f_V = 0.15 (0.05–0.35), about 3 task steps per problem. Model 62%; **my estimate 50%**.
   * *Software without a full spec:* fixed tests, independent tests from the intent, fuzzing, and AI critics. f_V = 0.07 (0.01–0.22). Model 73%; **60%**.
   * *Empirical:* the scaffold reruns everything, plus independent re-analysis, AI critics and a reader. f_V = 0.27. Model 23%; **15%**. Narrowing the goal to "the claim follows from the data" gives model 28%, **25%**.
   * *Judgment:* AI red team, a pre-mortem by a second expert, a judge, and fact checks. f_V = 0.21. Model 28%; **20%**.
10. **55% or more:** software without a full spec, yes (60%). Informal theory is borderline: 50% now, about 55–58% if f_V ≤ 0.15 is *measured* on imitator-style wrong results. Empirical and judgment work, no. Their residual errors (false in the world, wrong forecasts) need later data. Unconditionally, the human's own false-claim rate h (10–35% in empirical fields) alone exceeds the 5% bar, unless V filters it out.
11. **The measurement that would move the numbers most:** f_V of the combined protocol on the imitator's own wrong claimed solutions, by error type, with joint misses recorded. In the model it explains 35–50% of the variance of the output-failure criterion; transfer (does p fall?) explains 6–17%. Problems with a formal statement can serve as ground truth (§6).

## 1. The target, with arithmetic

* **Output failure.** F = (p·w·r̄ + h)·f_V (thread S's p·w·f_eff, with r̄ distinct wrong claims and h the rate at which the human's own chain ends in a wrong claim).
  * *The folder's convention:* it conditions on the human's chain *succeeding*, so h = 0, and I use that convention for comparability.
  * *Unconditional figures* (h > 0) are reported in §4.
* **The thresholds f\*.** F ≤ 0.05 means f_V ≤ f\* = 0.05/(p·w·r̄). With p = 0.3 and r̄ = 1.3:

  | domain | w | p·w·r̄ | f\* | f\* with h |
  |---|---|---|---|---|
  | informal theory | 0.45 | 0.176 | 0.29 | 0.21 (h = 0.065) |
  | software | 0.55 | 0.215 | 0.23 | 0.16 (h = 0.10) |
  | empirical | 0.75 | 0.293 | 0.17 | 0.10 (h = 0.22) |
  | judgment | 0.825 | 0.322 | 0.16 | 0.09 (h = 0.25) |

* **Effort.** "Works" also needs effort ≤ a fifth of chained imitation's, 4n₀K.
  * *VSI's effort* is (1+ι)·s·n₀K for searches (s ≈ 0.5–2; worst case 2) plus T·c_p, where c_p = β + n₀·c_V + (false rejections)·(cost of each).
  * *The condition:* T/K ≤ (4 − (1+ι)s)·n₀/c_p. At n₀ = 30, s = 1.25 and ι = 0.08, a protocol costing 3 steps per problem allows T ≤ 26K.
  * *Cost per verification* scales with the project. Refereeing costs 2–10% of producing [thread S], so I put a careful expert read at 0.04n₀, about 1.2 steps or four months, for a 5–10-year project's main result [J].
* **The human-does-it baseline.** A protocol costing c_p per problem saves at most n₀/c_p over the human doing each problem: about 10× for c_p = 3, at any T.

## 2. The model, and how it is calibrated

* **Error types** (shares are [J]; the "deep" share follows thread L's regime-C estimates).
  * *Theory:* false checkable claim 0.15; local inference slip 0.30; gap at the hard step 0.30; mismatch with the goal 0.12; citation or record 0.05; deep 0.08.
  * *The weighting:* the decoder errs where its posterior lacks the human's insight, so the mix is weighted towards the hard step. The scaffold computes values (Δ4), so it is weighted away from slips in computation.
  * *Other domains:* software, empirical and judgment have their own mixtures (code, `DOMAINS`).
* **Methods.** Each method has a miss probability per type, a human cost, and a false-objection rate (code, with comments). The anchors:
  * *Reading:* 0.43 overall in theory (thread S: 0.2–0.5);
  * *Use:* catches computational claims, misses gaps;
  * *Machine checks:* certain on computational claims and citations, blind elsewhere;
  * *Cone check:* 0.33, against thread S's 0.1–0.35;
  * *AI critic:* recall 0.5–0.6 per family on imitator-style errors (below PAT's 0.9 on published errors, near its 0.55 zero-shot), times a judge acceptance of 0.9.
* **Correlation.** A probit model with three latent factors:
  * a common factor (λ_c = 0.20; 0.60 for deep errors);
  * a method factor (λ_m = 0.30, so readers correlate at 0.5);
  * a person factor (0.15).

  §3.2 calibrates these.
* **The uncertainty.** A global multiplier u ~ logN(0, 0.55) scales every miss probability. It is the main uncertainty.
* **P(works).** P = 0.87 (0.70 empirical, 0.65 judgment) × feasibility of the instruction × P(F ≤ 5% and effort met). Here p ~ U[0.1, 0.5], learning transfers with probability 0.3 (0.15 for empirical and judgment), and T/K is log-uniform on [3, 30].
* **Calibration against the folder** (using its f ranges):

  | row | the folder | the model |
  |---|---|---|
  | V-human, theory | 40% | 39% |
  | V-cone, theory | 45% | 40% |
  | V-human, empirical | 10% | 8% |
  | tests only | 45% | 39% |

  So the model reproduces the folder's judgments where they overlap, and is slightly more pessimistic. I nonetheless shade its new rows down (§4).

## 3. The six levers

### 3.1 Verification by use

* **Evidence.**
  * *Errors are found by use, over years* [thread L]:
    * Linux faults live 1.8–3 years, and retractions come 33 months after publication;
    * Kapranov–Voevodsky was refuted indirectly, through a consequence.
  * *In First Proof's second round* [F], blind referees refuted a central lemma by building an explicit counterexample, and showed two displayed inequalities false by a scaling argument. Both are use.
  * *In software,* random differential testing found 79 wrong-code bugs in GCC and 202 in LLVM, in heavily reviewed code [thread T, S].
  * *In economics and political science,* re-analysis of 110 studies found coding errors in about 25% of them, and about 70% robustness [S].
* **The limit.** Use tests what can be instantiated. A gap at the hard step of a proof usually survives examples, because the claimed lemma is plausible and true on small cases: that is why it is plausible. I put use's miss at 0.65 there, against 0.12 on checkable claims.
* **The numbers** (theory): use alone 0.53; reading alone 0.43; reading plus use by different people 0.27 (by the same person 0.29). Cost: 0.04n₀ per problem. In the model P(works) goes from 47% to 55% (53% if one person does both).

### 3.2 Independent verifiers

* **Calibration** (Part A of the code):

  | data set | single miss | joint miss: independent / observed | latent r |
  |---|---|---|---|
  | Panko's spreadsheet triads, pooled [S] | 0.37 | 0.05 / 0.17–0.19 | 0.60–0.68 |
  | mammography pairs [S] | 0.20 | 0.04 / 0.08–0.12 | 0.44–0.75 |
  | Ulery's same examiner, 30% of false negatives repeat [thread L] | 0.075 | 0.006 / 0.022 | 0.52 |

  Porter et al. found no difference in detection between teams of 1, 2 and 4 reviewers [S]. Knight and Leveson rejected independence of failures in N-version programs [S].
* **Composition.** At f = 0.40, r = 0.5:

  | readers | joint miss | if independent |
  |---|---|---|
  | 2 | 0.239 | 0.160 |
  | 3 | 0.167 | 0.064 |
  | 5 | 0.102 | 0.010 |

  The model's two-expert row gives f = 0.285, P 53%. Readers repeat one another's misses: *different methods* (use, machines, AI critics) correlate less, at λ_c = 0.2, which is why combinations of methods beat committees.
* **Colleague framing.**
  * *The size of the own-style penalty:* students find about 20% fewer errors in their own essays [thread L], and LLMs judging their own proofs lose 5–15 points of accuracy, e.g. 76.9% against 79–92% for o3 [F].
  * *In the model:* the imitated human verifying its own style is ×1.25 on misses (P 41%); framing it as a colleague's recovers half (×1.12, P 44%); another expert gets P 47%.
  * *Against framing:* it is also a deception that style recognition defeats [thread S §3], and the reader's later task answers are contaminated.
  * *So:* the imitated human should not verify.
* **Adversarial framing** (Braz et al., 146 developers [F]):

  | vulnerability | found unprompted | of the rest, found after "there is a vulnerability" | miss multiplier |
  |---|---|---|---|
  | SQL injection (easier) | 65% | 46% | 0.54 |
  | input validation (subtle) | 18% | 13% | 0.87 |

  * *The price is more false alarms:* mammography pairing adds 4–10% to the false-positive rate [S]. I model the false-objection rate ×1.6.
  * *In the model:* f 0.43 → 0.38, P 47% → 51%. It is cheap and worth having, but small, because the imitator's errors are the subtle kind.

### 3.3 Partial machine verification

* **What it covers.** The scaffold already appends machine records (thread F's R entries): every computation is run, and every citation is retrieved and quoted.
  * *What that catches:* a false checkable claim (miss 0.15) and a fabricated or misquoted citation (0.10). First Proof's referees found several such citations in AI solutions [F].
  * *What it misses:* inference.
  * *The numbers* in theory: f 0.43 → 0.34 (−21%), at +8% n₀ (feasible at 95% [J]).
* **Empirical work.** Rerunning the code and statcheck-style consistency checks catch computational and reporting errors.
  * *How common they are:* half of psychology papers have an inconsistent p-value [thread L]; coding errors were found in about 25% of 110 studies, though over 85% were computationally reproducible [S].
  * *The numbers:* f 0.70 → 0.58 (−17%).
* **Key lemmas formalized**, with the formalizer in V (thread T).
  * *How a failure is handled:* a failure to prove a lemma is a *flag* for the judge, not a rejection, because formalizers fail on true lemmas 5–30% of the time.
  * *Coverage:* about half of the key lemmas are statable [J; thread T: 24% of Annals main theorems are statable, and lemmas are more elementary].
  * *The numbers:* the full protocol's f goes 0.122 → 0.093 (−24%), at +5% n₀ and 0.01n₀ of statement review. In the model P barely moves (55% → 53%), because effort rises as fast as failure falls.
* **Software.** Fuzzing, sanitizers and static analysis remove 50–70% of f with tests. Capers Jones reports that six test stages plus static analysis reach about 95% defect removal, with single stages near 35% [S], which is nearly independent compounding across methods.

### 3.4 Decomposed verification

* **The model** (Part C). A wrong claim with m invalid entries in its cone passes only if every invalid entry is missed:

  | per-entry miss f_e | m = 1 | m = 2: same / different verifier | m = 3: same / different |
  |---|---|---|---|
  | 0.25 | 0.25 | 0.119 / 0.084 (0.062 if independent) | 0.073 / 0.034 |

* **What the gain is.** The imitator's plausible wrong result usually has *one* bad step, since steps that validly use a false lemma pass the relative check L. So the gain is focus (f_e of 0.20–0.25 against 0.35 for local slips when reading whole), plus location: route (i) costs one task query, not a search.
* **What it cannot see.** Global errors, where the cone proves a different statement than the goal. A final-statement check is part of V-cone; even with it, the residual is 0.45 of the 0.12 share.
* **False flags.** On a correct cone of c entries the probability of at least one flag is 1 − (1−e)^c:

  | e | c = 30 | c = 100 | c = 300 |
  |---|---|---|---|
  | 0.005 | 0.14 | 0.39 | 0.78 |
  | 0.005, adjudicated (a second referee upholds a spurious flag w.p. 0.25) | 0.04 | 0.12 | 0.31 |

* **Obstruction records for verifiers.** A referee who cannot confirm an entry writes where it got stuck, which makes each flag adjudicable. Under (L1) a flag on a step that turns out to be the human's own is a false flag, the excused case.
* **Verdict.** One referee costs 0.08n₀, plus +30% n₀ for typed entries, which thread F gives 70% feasibility. That is why V-cone scores 32% in the model against 47% for a located single read. AI critics that segment the proof (PAT's 55% → 90%) buy the focus without the instruction.

### 3.5 Delayed verification by consequence

* **Evidence.**
  * *Replication rates* are about 36% (psychology) to 62% (social science in *Nature* and *Science*) [M].
  * *Prediction markets* call direct replications 73% of the time, over 103 findings, and are optimistic [S]. Reading-based judgment of empirical truth thus misses many false claims: f > 0.5, as thread S says.
* **In the model** (empirical): adding a held consequence check takes f from 0.27 to 0.14 and the output criterion from 51% to 64%. But at 0.15n₀ of human replication per problem, effort falls to 45%, and P to 17%. If replications fall outside the human-effort count (automated labs, other groups), P is about 29%.
* **What a delay does to the protocol.**
  * *Outputs are provisional* for r̄·Δ (Δ ≈ 4–12 steps), since each rejection restarts the wait.
  * *Wrong provisional outputs pile up:* λ·Δ·F_pre at throughput λ. Downstream use must wait, or track dependencies and be invalidated.
  * *Learning lags* by Δ for error modes shared across problems. With problem-specific insights it costs nothing extra, because nothing transfers.
  * *The human's later answers are contaminated* once the human knows the outcome, so searches after a late rejection should use runs the human has not seen discussed.
* **Recommendation.** Replicate a random 5–10% sample as an *audit of F*, which is the one unbiased measurement there is, rather than every output.

### 3.6 Criticism and debate

* **The structure.** A critic writes located objections ("entry 17 fails because H is not satisfied at x = 0"), and a judge decides each one.
  * *What it never does:* a critic's output never enters the notebook or the data, and it can only *add* rejections. So, like thread Q's hints, it cannot make a wrong result pass. A useless critic leaves f where it was, and a hostile one causes false rejections, which cost effort.
  * *What correctness then needs:* that the critics raise the error, and that the judge accepts valid objections. Judging a located objection is much easier than finding the error. With CriticGPT, human–critic teams caught as many inserted bugs as the critic alone and hallucinated less [F]. With critique assistance, labellers found flaws on 78% of inputs instead of 54% [S].
* **What it needs.**
  * *Critics independent of the imitator:* several model families. The imitated human as critic shares the imitator's posterior, so it is blind on problem-specific gaps (f = 0.68 alone; reading plus it, 0.33).
  * *A judge* who is not the imitated human.
  * *Located objections,* with an excusal rule: an objection on a step that is the human's own goes to a second judge.
  * *Budgets for false objections.* SPOT-era precision was 6% [S]; most 2026 reviewers keep false positives below 10% per paper [F]. I model 0.10 upheld false objections per family per verification, about 0.4 task steps per problem, and 10% lost problems.
  * *Rotation.* Critic prompts are rotated and hidden, because a fixed critic is exactly what a resampling learner can select against (thread S's enrichment: log₂(f_m/f_h) bits).
* **What it buys.** Three critic families take theory's f from 0.31 alone, or 0.43 for a reader alone, to 0.18 with both; P 47% → 64%. This is the largest single gain in this note. Without the AI critics, the best protocol's f rises from 0.15 to 0.30 and P drops 11 points.
* **Debate.** A defender rebuts each objection.
  * *The evidence:* debate beat consultancy, 84% against 74% (Michael et al.), and 88% against 78% (Khan et al.), on reading comprehension with an information gap [S]. That is not error-finding in proofs.
  * *The risk:* obfuscated arguments, whose flaw is hard to locate (Barnes 2020 [S]). Prover–estimator debate (Brown-Cohen, Irving and Piliouras 2025) addresses completeness under a stability assumption, and has no empirical test [S].
  * *In the model,* judge acceptance falls from 0.9 to 0.8 and false objections halve: f 0.152 → 0.165, P 62% → 61%.
  * *So:* use a defender only on contested objections, and never let the generator's side be an optimizer that argues for acceptance.
* **Beyond imitation.** The outputs are still the imitator's runs, and the design law is untouched. But sureness now rests partly on an AI critic's recall, not on any property of the human.

## 4. Combinations by domain

f_V is given at u = 1, with u = 0.6–1.6 in brackets. Cost is human task steps per problem at n₀ = 30, including β = 1. "T/K max" is where effort meets the bar. "My P" shades the model down by 8–13 points for:
* unmeasured miss rates on imitator-style errors;
* an AI imitator sharing AI critics' blind spots;
* selection against fixed critics;
* lost yield.

| domain | protocol (VSI with this V) | f_V | cost | T/K max | model P | **my P** |
|---|---|---|---|---|---|---|
| theory | V-human, unlocated (folder row) | 0.43 (0.25–0.64) | 4.9 | 17 | 35% | 35% |
| theory | **LEAN:** machine + 3 AI critics + adversarial expert judge | 0.15 (0.05–0.35) | 3.1 | 26 | 62% | **50%** |
| theory | FULL: LEAN + use by a 2nd expert (for T/K ≲ 15) | 0.12 (0.03–0.31) | 4.3 | 19 | 55% | 48% |
| theory | FULL + cone check | 0.10 (0.03–0.22) | 6.8 | 10 | 27% | 25% |
| software | fixed tests only (folder: 45%) | 0.45 (0.28–0.63) | 1.0 | 82 | 39% | 40% |
| software | **LEAN:** tests + independent tests + fuzzing + 3 AI critics | 0.07 (0.01–0.22) | 2.9 | 29 | 73% | **60%** |
| software | FULL + review + staged use by the requester | 0.045 (0.01–0.15) | 4.4 | 19 | 62% | 55% |
| empirical | V-human, unlocated (folder: 10%) | 0.70 (0.41–0.94) | 5.5 | 15 | 9% | 9% |
| empirical | **FAST:** rerun + independent re-analysis + 3 AI critics + reader | 0.27 (0.06–0.57) | 4.3 | 18 | 23% | **15%** |
| empirical | FAST + held replication | 0.14 (0.03–0.38) | 9.0 | 9 | 17% (29% if replication is not human effort) | 15–25% |
| empirical | FAST, goal narrowed to "the claim follows from the data" | 0.17 (0.05–0.43) | 4.3 | 18 | 28% | **25%** |
| judgment | AI red team + pre-mortem + judge + fact checks | 0.21 (0.06–0.54) | 4.1 | 20 | 28% | **20%** |
| judgment | the same + outcome check later | 0.15 (0.04–0.46) | 4.6 | 18 | 30% | 20% |

* **Unconditional** (h > 0: math 3–10%, software 5–15%, empirical 10–35%, judgment 15–35%):

  | protocol | conditional | unconditional |
  |---|---|---|
  | theory LEAN | 62% | 55% |
  | software LEAN | 73% | 65% |
  | empirical FAST | 23% | 13% |
  | judgment | 28% | 16% |

  In empirical fields the human's own false-claim rate alone is 2–7 times the bar. No imitation scheme meets "5% false in the world" there unless V filters out the human's errors too.
* **Lost problems.** Upheld false objections make VSI abstain on about 10% of problems under the critic-heavy protocols, against 2% for one reader. They cost yield, not correctness.

## 5. Changes to VSI that follow

1. **Located rejections only.** V must name the entry and the reason. Route (i) task-queries it; if the step is the human's own, a second judge decides; if that judge upholds it, abstain at once instead of scanning. This saves about 1.5n₀ task queries per false rejection, or per correct rejection of the human's own claim.
2. **Combine methods, not readers.** Machines, use and AI critics correlate less with each other than readers do (r ≈ 0.2 against 0.5).
3. **Treat critics as hints.** Accept only rejections; keep generators away from arguing for acceptance; rotate and hide critic prompts; cache verdicts on canonical claims.
4. **Drop the typed-notebook instruction for V-cone.** Get decomposition from segmenting AI critics. Keep thread F's Δ4 (machine records), which costs +8% n₀.
5. **Choose the protocol by T/K.** Each 0.04n₀ of human checking costs about 7 in T/K max (26 → 19 from LEAN to FULL). Heavy protocols pay only for small deployments.
6. **For empirical work, narrow S\*** to "the analysis is correct and the claim follows from the data". Label outputs provisional for truth in the world, and audit a random sample by replication.

## 6. Recommendation

* **Informal mathematics and theory:** VSI with LEAN. That is: scaffold records for computations and citations; three AI critic families reviewing segment by segment, adversarially; one expert other than the imitated human, reading in adversarial framing and judging located objections; route (i) with excusal; β = 1. Add use by a second expert when T/K ≲ 15, and key-lemma formalization where the lemmas are statable and the formalizer is in V. **50%** (40–60%), against 40% for the folder's V-human row.
* **Software without a full spec:** VSI with LEAN: acceptance tests fixed at x₀; independent property, differential and fuzz tests derived from the intent (AI-written, with human-reviewed properties); sanitizers; three AI critics. Add staged use by the requester when intent is the main risk. **60%** (50–68%), against 45% for tests alone.
* **Empirical science:** VSI with FAST on the narrowed goal, with provisional status and replication audits for truth. **25%** on the narrowed goal, **15%** on truth conditional on the human's chain succeeding, **about 10%** unconditionally.
* **Judgment work** (strategy, design): the AI red team, pre-mortem, judge and fact checks, with outputs that state their assumptions so later outcomes can be checked. **20%** conditional, **about 12%** unconditional.
* **55% or more.** Software, yes. Informal theory, 55–58% if a measurement shows f_V ≤ 0.15 with a deep share ≤ 5%: in the model, deep share 0.04 and critic misses ×0.7 give 64–68%. Empirical and judgment work, no: their best is about 25%, capped by errors only later data reveal and by the human's own error rate.
* **The measurement.** Run the actual imitator on problems with ground truth: problems that have a formal statement, or known answers, or are planted into real projects. Collect its wrong claimed solutions, mixed blind with correct ones, run the full protocol, and record per type:
  * each component's misses;
  * the joint misses (the correlations);
  * the deep share;
  * the false objections.
  * *Sample size:* about 200 wrong claims estimate f_V ≈ 0.15 to ±0.05, and about 50 separate 0.15 from 0.30 (80% power).
  * *The worth:* in the model this explains 35–50% of the variance in the output criterion. Next in worth are p·w and transfer, then T/K, which is a design choice.
  * *Validation:* to certify F ≤ 5% directly, 60 audited outputs with no failure suffice (the rule of three).

## 7. Limits

* *The inputs are judgments.* Most miss probabilities, type shares and costs are [J]. The anchors come from planted, injected or published errors, not from an imitator's own wrong results, and that is the gap the measurement in §6 fills.
* *The structure is simple.* One latent model with fixed loadings, types independent given the latents, and a global u for level uncertainty. Moving the correlations over a wide range changes P by ±3 points, and the deep share from 0.04 to 0.25 by 64% → 54%.
* *The effort criterion depends on a T/K prior.* That prior is not knowledge; the T/K max column is the honest form.
* *Same conditioning as the folder:* determinism, realizability, and a chain that succeeds. Practical learners that resample would select against fixed AI critics, which my shading only partly prices.
* *Sources not reached:* Braz et al. was read in full text; Panko's, Ulery's 2011 cross-examiner, and the mammography figures are from search summaries; Mitchell, Russo and Pennington's pre-mortem effect could not be confirmed and is not used.

## Sources

* **Detection and correlation:** Panko 1999 (*JMIS*) and its nominal-group reanalysis, arXiv 0802.3479 [S]; Braz, Fregnan, Çalikli and Bacchelli, ICSE 2021, arXiv 2102.06251 [F]; Porter, Siy, Toman and Votta, *TSE* 1997 [S]; Knight and Leveson, *TSE* 1986 [S]; Basili and Selby, *TSE* 1987 [S]; Capers Jones on defect removal efficiency [S]; double reading in mammography (RSNA and *BJC* reports) [S]; Ulery et al., *PNAS* 2011 [S]; Ulery et al. 2012, Daneman and Stainton, Lamport [thread L].
* **Mathematics and AI review:** Dekoninck et al., Open Proof Corpus, arXiv 2506.21621 [F]; First Proof second batch, arXiv 2606.18119 [F]; Google, Paper Assistant Tool, arXiv 2606.28277 [F]; the injected-error audit of AI reviewers, arXiv 2611.17052 [F for the abstract, S for the 57–73%]; SPOT, arXiv 2505.11855 [S]; FLAWS [S].
* **Critique and debate:** McAleese et al., CriticGPT, arXiv 2407.00215 [F]; Saunders et al., arXiv 2206.05802 [S]; Michael et al., arXiv 2311.08702 [S]; Khan et al., ICML 2024, arXiv 2402.06782 [S]; Barnes 2020, obfuscated arguments [S]; Brown-Cohen, Irving and Piliouras, arXiv 2506.13609 [S].
* **Empirical verification:** Brodeur et al., I4R mass reproduction, IZA DP 16912 [S]; Stodden, Seiler and Ma, *PNAS* 2018 [S]; Dreber, Camerer et al. on replication markets, *PLOS ONE* 2021 [S]; replication rates [M].
* **This folder:** [`../verified-slack.md`](../verified-slack.md); threads F, L, Q, S and T.
