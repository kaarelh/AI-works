# Thread T: calibrating the machine verifier

*Research note by Claude (Anthropic) on the 70% row of [`../verified-slack.md`](../verified-slack.md) (§2, §6, §7), "VSI with a proof assistant on a formally stated goal". It checks the estimates in thread S §1.1 ([`threadS-redteam2.md`](threadS-redteam2.md)) against published evidence. This is a draft and has not been refereed. No existing file was changed.*

*How sources are tagged:* **[F]**, I fetched the source page this session and read the fact there; **[S]**, confirmed only through search-engine summaries this session; **[M]**, from my own memory, not checked this session; **[thread X]**, one of this folder's reports. Several hosts were blocked from this session (lean-lang.org, openwall.com, seclists.org, spectrum.ieee.org, icml.cc, the Lean Zulip archive, matharena.ai), so facts from them are [S].

The full source list is at the end. Today is 2026-11-21. Several of the most important data points are from 2026.

## Answers in brief

1. **(a) Misformalization is about 10 times more common than the note's 2% guess, unless the statement is independently reviewed.**
   * *Best research-level evidence: AnnalsChallenge* (Buzzard and coauthors, Oct 2026). Experts hand-wrote 50 Annals main theorems in Lean, then gave each an in-depth manual review. Even after that, AI audits found mistakes in **11 of the 50 (22%)**. Separately, 7 of the 50 published theorems lacked assumptions [F].
   * *Formal Conjectures* (DeepMind), where review is mandatory: **291 misformalizations fixed** among about 4,565 non-supporting statements, so at least 6% [F].
   * *Competition benchmarks:* 5–60% unfaithful. Examples: miniF2F, more than half with discrepancies [F]; ProofNet, 32–56% [S].
2. **About half of misformalizations are fail-safe in VSI.**
   * *Fail-safe:* a false statement cannot be proved, so VSI abstains (a cost, not an error).
   * *Dangerous:* a statement that is true but weaker than the goal. Rerun-until-accepted then hunts for its loophole.
   * *Evidence for the hunting:* in DeepMind's Aletheia run on Erdős problems, 50 of the 63 "technically correct" solutions were vacuous misreadings [S]. Aristotle "solved" Erdős #124 only in its weaker, misstated version [S]. In Formal Conjectures, AI proof runs "primarily reveal misformalizations" [F].
3. **My estimates for a research goal written carefully by an expert:**
   * *Without independent review:* about **25%** of statements have some unfaithfulness, and about 10% have a weaker, exploitable one (when new definitions are needed). For statements in vetted Mathlib vocabulary, the figures are 8% and 3%.
   * *With independent review* (a second formalizer, at least two AI audits, test lemmas for definitions, automated proof and disproof probes): about **4%** and 1.5%.
   * *Contribution to output failure,* under rerun-until-accepted: about 0.5–1% reviewed, and 1–5% unreviewed (the high end when new definitions are needed).
4. **(b) The cost of formal proof collapsed in 2025–26.** Thread S's "several times the informal proof when libraries are missing" is now too pessimistic for mathematics.
   * *FLT:* Claude formalized all of Fermat's Last Theorem in **11 days**: about 13M lines, building the missing algebraic geometry along the way, checked by Comparator against Mathlib's statement [F]. Buzzard's human project had a 5-year plan [S].
   * *Others:* Gauss finished sphere packing in dimension 8 in 5 days and dimension 24 in 2 weeks, and the strong PNT in 3 weeks, later 2–3 days [S]. Poincaré's main phase took about 2 weeks after 4 months of preparation [F].
   * *Counter-signals:* only about 42% of OpenAI's roughly 720 AI-generated manuscripts had Lean checks in October 2026 [S]. On ArXivLean (proving fresh research theorems without the paper's proof) the best score was 17% in March 2026 [S].
5. **The formal-proof multiplier ι in 2026, for a goal already statable, with AI formalization agents at the end of the chain:**
   * P(ι ≤ 1.5) ≈ **65%**, P(ι ≤ 2) ≈ **80%**, P(ι ≤ 3) ≈ **90%**, varying strongly by field (§2.3). With 2023-style human formalization: 10%, 20% and 40%.
   * *Why 2× matters:* ι ≤ 2 is exactly the margin the note's worst case has: 2n₀K against a bar of 4n₀K.
6. **(c) Kernels are sound against honest proofs, but not against adversarial search.**
   * *2026 bugs:* AI-assisted adversarial testing found at least four Lean 4 soundness holes in the kernel and runtime, fixed in 4.32.1–4.34.0, one of which also fooled the independent checker nanoda [S]. It also found several Rocq guard-checker and universe bugs, two still unfixed [S].
   * *Practical relevance:* none of these is reachable by an honest proof. They matter because VSI's "rerun until accepted" is a filter, and any optimizing component in the loop is a search.
   * *Hardened checking makes (c) about 99.5%:* a pinned, patched version; Comparator or SafeVerify; an axiom whitelist; no `native_decide`; at least two kernels.
7. **(d) The domain is narrow, and the row is conditional on it.**
   * *Mathematics:* only 50 of 207 recent Annals main theorems (24%, easiest first) could even be *stated* after 10 months of expert work. Some areas are "essentially impossible to state right now": symplectic geometry, Lie theory, moduli stacks, Shimura varieties [F].
   * *Combined with "fixed in advance"* (my guess): about 5–15% of multi-year mathematics projects are in the domain today, about 10–25% of mathematics and TCS effort, and a few percent of all valuable research.
8. **Software specifications misformalize too.** In an audit of CLEVER, a Lean verified-code benchmark, 80 of 161 reference specifications were arguably wrong [F]. The bugs Fonseca et al. found in verified systems sat at the specification, shim and tool boundaries, not in verified code [S]. seL4 cost about 25 person-years for 8,700 lines of C [S].
9. **The 70% row:**
   * *As VSI is now specified* (no statement review required, an unhardened checker, the human formalizing in-chain): about **60%**.
   * *With a mandatory statement protocol and hardened checking:* about **72%**.
   * *With, in addition, the formalizer moved into the verifier:* about **75–78%**.

   The number survives, but its basis changes: (b) is much better than thread S feared, and (a) is much worse than the note's 2%.
10. **The most valuable design change: put the formalizer into V.**
    * *The change:* the human's chain ends with a blueprint-quality informal proof. V is then "an AI formalization agent, within budget B, produces a proof of the *fixed* formal statement that a hardened kernel accepts".
    * *Correctness* still rests only on the statement and the kernel. n₀ inflation shrinks to the cost of the blueprint, and a formalizer failure becomes an abstention, not an error.
    * *The price:* the formalizer is an optimizer, so the statement protocol and hardened checking become mandatory, not optional (§5.3).

## 1. Misformalization

### 1.1 Evidence

| source | statements | who wrote them | error rate found | notes |
|---|---|---|---|---|
| AnnalsChallenge, arXiv 2610.18301 [F] | 50 Annals main theorems (since 2020) | experts, hand-written, with an in-depth manual review | **11/50 = 22%** mistakes found by later AI audits (Claude Fable 5, GPT 5.6 Sol); 32 had no significant issue | 7/50 published theorems lacked assumptions; severity of the 11 not given; none found since release |
| Formal Conjectures, arXiv 2605.13171 [F] | 7,559 (1,642 open, 2,923 solved, 2,994 supporting) | community, increasingly AI-assisted; mandatory review by Lean and domain experts; audit before release | **291 fixed** (lower bound) | misrepresentation 48%, Lean semantics (ℕ subtraction, 0 ∈ ℕ) 35%, implicit conventions 8%, source errors 5%, syntax 3% |
| miniF2F revisited, arXiv 2511.03108 [F] | 488 competition problems | 2021 benchmark authors | discrepancies in **more than half** | the full pipeline scores 36–40% on v1 and 70% on corrected v2 |
| ProofNet, Poiroux et al. EMNLP 2025 [S]; "Ground False" 2026 [S] | 371 undergraduate theorems | benchmark authors | 118 (31.8%) wrong; a later audit finds 204/367 (56%) unfaithful, 104 (28%) false | across six more benchmarks, 4.8–60% unfaithful |
| Faults in our Formal Benchmarking, arXiv 2606.29493 [F] | 5 Lean benchmarks | – | 398 mechanically certified defects (counterexamples, vacuous theorems, unsound axioms) | – |
| PutnamBench [S] | 640+ Putnam problems [M] | benchmark authors | several fixes, with no errata page (my reading: a few %) | `f(1/2)` parsed as `f(1)/2` (putnam_2017_b3); missing injectivity hypothesis; vacuous implication (PR #322) |
| CLEVER audit, arXiv 2605.23772 [F] | 161 program specifications | benchmark authors | **80/161** arguably wrong | the software analogue |
| Aletheia, arXiv 2601.22401 [S] | 700 open Erdős problems (informal) | Erdős, as transcribed | of 63 technically correct AI solutions, **50 vacuous** by misreading | the selection effect in its pure form |

*Cases with careful experts.* The Liquid Tensor Experiment checked its definitions through examples, with Scholze's continuous support, and its statement was never found wrong [M]. Formalization turned up only 1–2 slips affecting the proof in Carleson, and only "very minor typos" in PFR [S]. FLT and Poincaré used Comparator against target statements written only in Mathlib; Poincaré added a two-pass human review of the *elaborated* statement [F].

The pattern: errors concentrate in *new definitions* and in Lean conventions (truncated subtraction, x/0 = 0, coercions, parsing), and they are found by proving, disproving, or AI auditing, not by reading.

### 1.2 What a misformalization does in VSI

S_V is fixed at x₀ and shared by the human's own reference chain. So a misformalization has one of three effects:
* **Too strong (false).** The human's chain cannot reach S_V, (A2) fails, and VSI abstains. This is fail-safe: a cost, not an error. Ground False found about half of unfaithful ProofNet items to be false [S].
* **Weaker (vacuous, or missing a requirement).** Some run proves S_V without establishing S\*. Under rerun-until-accepted this is the dangerous case: on a problem the imitator cannot yet solve, a loophole run is accepted before any correct run (thread S §1.3, wf/(c+wf) with c ≈ 0).
  * *An optimizing component takes it:* Aletheia's 50/63, Erdős #124, and Formal Conjectures' finding that AI successes mostly expose misformalizations.
  * *A faithful imitator of a careful human* takes it less often, because the human would notice "this is trivially true".
* **Incomparable.** Different, neither weaker nor stronger. This behaves like the weaker case for whatever part of S\* it drops.

*Notation.* Let m be the rate of any unfaithfulness, ω the weaker share (about 0.3–0.5), and x the chance the accepted output exploits a weaker defect: 0.3–0.5 for an imitator, and 0.5–0.9 when an optimizing formalizer is in the loop. The output-failure contribution is then f_mis ≈ m·ω·x.

### 1.3 Estimates

| statement | m (any defect) | m·ω (exploitable) | f_mis, imitator in chain | f_mis, AI formalizer in V |
|---|---|---|---|---|
| research goal needing new definitions, one expert, no independent review | 25% (15–40%) | 10% | 3–5% | 5–9% |
| research goal in vetted Mathlib vocabulary, no independent review | 8% (4–15%) | 3% | 1–1.5% | 1.5–2.5% |
| either, with the statement protocol of §5.3 | 4% (2–8%) | 1.5% | 0.5–0.7% | 0.7–1.3% |

* *Basis.* AnnalsChallenge's 22% is a rate *after* one expert review, so an unreviewed rate is at least that for definition-heavy goals. Formal Conjectures' at least 6% is for mostly short statements, reviewed. Residual rates after review are uncertain: AnnalsChallenge reports no misformalization found since release, while Formal Conjectures keeps finding them.
* *Against the note's 2%.* That guess is about right as an *effective* rate after review. As a rate of defective statements it is too low by a factor of 5–10 without review.

## 2. Formalization overhead

### 2.1 Evidence

| project | informal source | formalization | people | notes |
|---|---|---|---|---|
| de Bruijn factor (Wiedijk) [S] | – | formal text about 4× (3–6×) the size of the informal text | – | time: about a week per textbook page by hand [M] |
| Feit–Thompson (Coq) [S] | 255 pages (1963) [M] | 2006/7–2012, about 6 years | 15 coauthors | about 170k lines [M] |
| Flyspeck (HOL Light, Isabelle) [S] | Hales–Ferguson 1998 | 2003–Aug 2014; estimated at 20 work-years | about 22 [M] | |
| Liquid Tensor [S] | Clausen–Scholze | Dec 2020–Jul 2022, 19 months | a dozen-plus | built condensed mathematics from scratch |
| PFR [S] | the GGMT preprint (Nov 2023), found within weeks | **3 weeks** (done Dec 5, 2023) | about 25 | Tao wrote about 5% of the lines |
| Carleson [S] | a blueprint written for the project | under 13 months (Jul 2025) | blueprint by 5 analysts plus formalizers | |
| Strong PNT, Gauss (Math Inc) [S] | Tao–Kontorovich project from Jan 2024 | **3 weeks** (2025), later 2–3 days | AI plus a small team | |
| Sphere packing in dimensions 8 and 24, Gauss [S] | Viazovska et al.; human project since 2024 | rest of dimension 8 in **5 days**, dimension 24 in **2 weeks** (Feb–Mar 2026) | AI | from about 70k to about 200k lines |
| FLT, Claude [F] | Darmon–Diamond–Taylor exposition | **11 days** (Aug 2026), about 13M lines, about 6B output tokens | AI, with occasional human direction | Comparator against Mathlib's FLT; standard axioms only |
| Poincaré [F] | blueprint by mathematicians | preparation from May 2026, main phase **about 2 weeks** | 3 AI engineers plus reviewers | 2.8M lines; Comparator plus the Nanoda kernel |
| 246 prime gaps, AxiomProver [S] | human blueprint | Aug 2026 | 41 contributors | |
| seL4 [S] | 8,700 lines of C, about 2 person-years of implementation [M] | about 25 person-years in all, about 12 on the kernel; 200k lines of Isabelle | team | $350–700 per line, against about $1,000 per line for EAL6 assurance |

* *Counter-signals.*
  * *OpenAI's ~720 manuscripts:* about 42% Lean-checked by early October 2026 [S].
  * *ArXivLean (proof search without the paper's proof):* best about 17% of 41 theorems, at about $10 per attempt [S].
  * *A mathematician's report:* autoformalizing his papers went from "impossible" in March 2026, through "too costly" in May, to "practical" in July [S].
  * *Tao (June 2026):* almost all of his IEANTN formalization tasks were being done by AI within hours, against weeks for volunteers [S, secondary sources].
* *Selection bias.* The landmark cases are self-reported successes by well-resourced teams, so I discount them.

### 2.2 Library coverage and AI

*Before 2025, coverage set the cost.* Missing definitions made formalization several times the informal effort (Liquid Tensor, Feit–Thompson). About 1,000 key definitions separate Mathlib from stating recent Annals papers (Zulip estimate, Feb 2026 [S]).

*Since 2025, agents build the library as they go.* FLT needed Jacobians as schemes and much automorphic machinery, all generated in 11 days. So coverage now limits *stating the goal* (domain (d) and misformalization (a)) more than *proving it*. The two pull in opposite directions: cheap AI-built definitions are exactly where misformalizations live.

*What is still costly:*
* *A blueprint-quality informal proof:* Carleson, Poincaré and the 246 prime gaps all used human blueprints;
* *gaps that formalization uncovers*, which send the chain back to research;
* *compute:* billions of tokens for the largest results.

### 2.3 Multiplier by field (2026; goal already statable; AI agents formalize at the end of the chain)

| field | P(ι ≤ 1.5) | P(ι ≤ 2) | P(ι ≤ 3) |
|---|---|---|---|
| combinatorics, elementary and analytic number theory, discrete geometry, finite groups, checkable search | 80% | 90% | 95% |
| algebra and algebraic number theory, the statable parts of algebraic geometry, harmonic analysis, probability | 65% | 80% | 90% |
| geometric analysis, PDE, differential geometry, dynamics | 45% | 65% | 80% |
| TCS: complexity, algorithms (thin machine-model libraries) | 50% | 70% | 85% |
| functional correctness of systems software | 20% | 35% | 60% |
| **mathematics, weighted by where goals are statable** | **65%** | **80%** | **90%** |

* *Why these are my estimates.* With n₀ = 20–40 three-month steps (5–10 years), an AI formalization of weeks adds under one step. The tail comes from three things: new research that is messier than decades-polished proofs, formalization exposing gaps, and fields where the formalizer fails and humans must step in (ι of 2–5).
* *Human-only formalization (2023 practice):* 10%, 20% and 40%.
* *Formalizing every step* (thread F's fully formal discipline, 25% at 1.5×) remains far costlier. VSI needs only the final artifact.

## 3. Checker soundness

* **Lean 4 in 2026** [S]:
  * *4.32.1 (Jul 2026):* a kernel bug found by P. Hulin with GPT-5.6, exploitable only by a malicious metaprogram running in the kernel's process.
  * *A nested-inductive projection bug:* versions up to 4.31 accept a proof of 0 = 1; fixed in the nightly of 2026-07-29.
  * *4.33.1 and 4.34.0 (Sep 2026):* three holes reported by D. Selsam (OpenAI) from model-driven adversarial testing. The `is_prop` bug was also accepted by the independent nanoda kernel; lean4lean is believed unaffected. The others were a history-dependent `is_def_eq` cache and a reference-count overflow that becomes a use-after-free (with at least 18 GB of RAM).
  * *"hasLooseBVars is not conservative":* a now-fixed exploit cited by Formal Conjectures [F].
  * *Proofs that skip the kernel:* `native_decide` trusts the compiler. ProofGate found it in 11 of 197 Kimina miniF2F proofs [S].
* **Rocq** [S]:
  * *CVE-2026-72705:* a guard-checker bug gives False with no axioms. It was found by Claude Opus 4.6 fuzzing and fixed in 9.2.0.
  * *CVE-2026-72714* (a universe-check bypass, giving Hurkens' paradox) and *CVE-2026-72704* are unfixed as of 9.2.0.
  * *CVE-2020-37268:* `Print Assumptions` can miss unsafe flags.
  * *History:* Coq's `critical-bugs` file lists dozens of soundness bugs over its life [M].
* **Isabelle/HOL.** Overloading combined with `typedef` admitted circular definitions and inconsistency (Kunčar–Popescu, 2015–17; tightened in Isabelle 2016) [S]. HOL Light and CakeML's Candle have kernels verified in themselves [M].
* **Relevance.**
  * *For honest work:* I know of no case where an honest development was accepted wrongly because of a kernel bug. All the 2026 bugs need deliberately built inputs.
  * *For VSI:* the filter rewards whatever passes, and an LLM-based imitator or formalizer has read the 2026 advisories. So the threat is real only with an optimizing component and an unhardened pipeline.
* **Estimates.** P(an accepted wrong output relies on a checker or pipeline flaw):
  * *Hardened checking:* about 0.1–0.5%. That means a patched, pinned version; Comparator or SafeVerify; an axiom whitelist of propext, Choice and Quot.sound; no `native_decide` or custom metaprograms; a separate process; and replay by at least two kernels, Lean plus lean4lean.
  * *A plain `lake build` of the imitator's project:* 1–3%.
  * *The pipeline, more than the kernel:* statement substitution and environment tampering are the commoner exploit, which is why Comparator exists.

## 4. The domain

* **Mathematics.**
  * *Statable today:* in AnnalsChallenge, 50 of 207 main theorems were stated, easiest first, and 0 of 74 of difficulty 4–5 [F]. By field: combinatorics 8/13, convex and discrete geometry 6/10, number theory 20/50, group theory 8/20, probability 4/14, dynamics 4/21, algebraic geometry 8/54, differential geometry 3/27, PDE 2/29, Lie groups 0/16.
  * *Fixed in advance* (my guess): about 30–50% of papers answer a question posed before the work began, and fewer multi-year programmes do, perhaps 20–35%, since their value is often a new definition or question (thread S §1.1).
  * *Combined:* about 5–15% of multi-year mathematics projects today, more for paper-sized problems in combinatorics and number theory. It rises with Mathlib, which AI now extends fast.
* **TCS.** Lower bounds, algorithmic guarantees and cryptographic reductions are statable in principle, but machine-model and probability libraries are thin. Perhaps 10–20% of projects are in the domain.
* **Verified software.**
  * *Examples:* seL4, CompCert, CakeML, HACL\*.
  * *Effort:* proof effort is about 5–10× implementation effort for seL4 [S/M].
  * *CompCert:* Csmith found no wrong-code bugs in its verified parts, against 79 in GCC and 202 in LLVM. It did find bugs in the then-unverified front end, and one from a misunderstood PowerPC semantics [S].
  * *Specifications are the weak point:* the CLEVER audit's 50% wrong specifications, and Fonseca et al.'s 16 boundary bugs.
  * *Share:* a small one, though AI may shrink the 5–10×.
* **Checkable search.** The verifier is cheap and crisp, for example:
  * SAT certificates: Boolean Pythagorean triples (2016) and Schur number five (2017) [M];
  * BB(5), proved in Coq in 2024 [M];
  * FunSearch and AlphaEvolve constructions [M].

  The risk here is a proxy property, not misformalization.
* **Empirical science and design.** Essentially outside the domain.
* **Overall.** The domain is a few percent of valuable research, and perhaps 10–25% of mathematics and TCS effort. The 70% applies only inside it. A *stream* of in-domain problems, as "performance on lots of problems" needs, exists: Erdős-type lists, Formal Conjectures, verification obligations.

## 5. Synthesis

### 5.1 Calibrated probabilities

| quantity | estimate |
|---|---|
| a research goal written carefully by an expert is misformalized: no independent review / with review | 25% / 4% (any defect); 10% / 1.5% exploitable, for goals needing new definitions. Vetted-vocabulary goals, unreviewed: 8% any, 3% exploitable |
| misformalization's contribution to output failure under rerun-until-accepted | 3–5% unreviewed with new definitions, 1–1.5% in vetted vocabulary; 0.5–1% with the protocol |
| the human's own chain ends with a formal proof within 1.5× / 2× / 3× the informal duration (2026, AI formalization at the end) | 65% / 80% / 90% (human-only: 10% / 20% / 40%) |
| the same, with the formalizer in V (ι counts only the blueprint) | 85% / 93% / 97% for the cost; the formalizer's false-rejection rate becomes abstentions, about 5–30% by field |
| checker or pipeline lets through a wrong output: hardened / not | 0.1–0.5% / 1–3% |

### 5.2 The 70% row

Same conditioning as the note: determinism, realizability, the chain succeeding. P(works) is the product of three factors:
* *(a):* P(misformalization keeps output failure within the 5% budget). The 0.80 assumes a mix of goals that need new definitions and goals in vetted vocabulary;
* *(c):* P(no accepted output relies on a checker or pipeline flaw);
* *effort:* P(effort at or below a fifth of chained imitation). That is P(ι ≤ 2) × 0.87 for the cost issues other than ι (heavy tails, wording-level K, writing statements, futile searches), plus partial credit of 0.5 for ι in (2, 3] and 0.15 above 3. With the formalizer in V this gives 0.83, less a little for fallback formalizations by the human.

| version | (a) | (c) | effort | **P(works)** |
|---|---|---|---|---|
| VSI as specified now (no statement review required, plain checker, human formalizes in-chain) | 0.80 | 0.97 | 0.76 | **≈ 60%** |
| plus the statement protocol and hardened checking | 0.96 | 0.995 | 0.76 | **≈ 72%** |
| plus the formalizer in V (a stronger protocol, since x rises) | 0.95 | 0.99 | 0.82 | **≈ 77%** |

* **Verdict.** Keep the row at **70%** only if the note *requires* the statement protocol. Without it, lower the row to about 60%. With all the changes below, raise it to about 75%.
* **What moves the number.** Most of the swing in either direction comes from (a), not (b).
* **Correcting the text.** Replace §6's "perhaps 2% of carefully written statements" with "about 25% unreviewed when new definitions are needed, about 4% after independent review, contributing about 0.5–1% to output failure". Replace thread S's "several times the informal proof" with "about 1.1–1.5× in 2026 in covered fields".
* **The unconditional figure** (thread S: about 40%) moves little. These changes affect the conditional row, and the idealizations dominate the rest.

### 5.3 Design changes

1. **A statement protocol, required.** The trusted part is only the final statement plus every definition it unfolds to outside vetted Mathlib. Lemma statements inside the proof need no fidelity review, because the kernel checks how they are used. Make that trusted cone small, then:
   * *Write two independent formalizations, and machine-check that they are equivalent.* Correlated errors remain, especially Lean-semantics ones (35% of Formal Conjectures' fixes), so this is not a multiplication of error rates.
   * *Run at least two AI audits from different model families.* They caught 22% after expert review in AnnalsChallenge.
   * *Give each new definition test lemmas,* such as worked examples and characterizing properties, as in Formal Conjectures (36% of its statements are tests) and the Liquid Tensor Experiment.
   * *Exhibit non-vacuity witnesses* showing the hypotheses can be met.
   * *Probe the statement automatically:* attempt proofs and disproofs of it, of special cases and of its negation.
   * *Get human sign-off on the elaborated statement* (Poincaré's second pass).
2. **Halt on a flag; do not rerun past it.** A STATEMENT-DEFECT entry in *any* run halts the problem for review of the statement. Otherwise rerun-until-accepted selects *against* the runs that noticed the loophole.
3. **An anomaly trigger at acceptance.** Route a proof to statement review before output when it is far shorter or faster than the human's chain should need, or when it bypasses the blueprint's milestone lemmas (LeanTrail-style alignment). Vacuous proofs are short.
4. **Put the formalizer into V.**
   * *The change:* the human's chain ends with a blueprint. V runs a formalization agent with a fixed seed and budget B on the claimed solution and its cited cone, then checks the result. S_V stays preserved by appending.
   * *Failures:* when the formalizer fails on a run whose scan finds no mistake, fall back to asking the human to formalize, the current design, rather than abstaining.
   * *What it changes:* correctness is unchanged. ι drops to the blueprint overhead, but x rises, because the formalizer optimizes. So items 1–3 and 5 are prerequisites.
5. **Hardened checking** (§3). It is cheap, and becomes mandatory once any optimizing component is in the loop.
6. **Count the cost of writing statements** in effort. AnnalsChallenge took about 10 months for 50 research statements by a team. AI drafting plus review should bring this to days per statement. That is still a per-problem cost s, which caps the number of problems T at about (4 − 2ι)·n₀K/s.

### 5.4 What to measure first

* *Planted-defect trials.* Seed known misformalizations, both weaker and false, into goal statements, then measure:
  1. the protocol's catch rate;
  2. how often the imitator's accepted outputs exploit the survivors (x), for an imitator alone and with a formalizer in V.
* *The formalizer's false-rejection rate* on the human's own correct informal proofs, by field and budget.
* *ι on real projects:* time from informal completion to a kernel-checked artifact, including fixing the gaps formalization finds.

## Sources

* **Misformalization:** Firsching et al., *Formal Conjectures*, arXiv 2605.13171 (v2, Nov 2026) [F]; Browning, Hristova, Ledvinka, Springer, Su, McKoen and Buzzard, *AnnalsChallenge*, arXiv 2610.18301 [F]; Ospanov, Farnia and Yousefzadeh, arXiv 2511.03108 [F]; Poiroux et al., arXiv 2406.07222 [S]; "Ground False" (ICML/NeurIPS 2026 listings) [S]; Ammanamanchi, Bhat and Biderman, arXiv 2606.29493 [F]; Maestro, arXiv 2610.25920, and PutnamBench PR #322 [S]; Sosso, Arora and Spitters, arXiv 2605.23772 [F]; Feng et al. (Aletheia), arXiv 2601.22401 [F for the abstract, S for the funnel numbers]; Erdős #124 (Buzzard on the Lean Zulip) [S]; ProofGate (ICML 2026) [S]; Venturim et al., LeanTrail, arXiv 2610.35926 [F].
* **Overhead:** Anthropic, "Formalizing Fermat's Last Theorem" (Sep 4, 2026) [F]; Zhang et al., Poincaré, arXiv 2610.08329 [F]; Math Inc's Gauss on strong PNT and sphere packing [S]; AxiomProver on the 246 prime gaps [S]; Tao on IEANTN, June 2026 [S]; ArXivLean (MathArena) [S]; OpenAI's math release, Oct 2026 [S]; PFR, the Liquid Tensor Experiment, Carleson, Flyspeck, Feit–Thompson and Wiedijk's de Bruijn factor [S], with the details marked [M] in the tables; the seL4 numbers page and Klein et al. [S]; Yang et al., PLDI 2011 (Csmith) [S]; Fonseca et al., EuroSys 2017 [S].
* **Soundness:** Lean release notes for 4.32.1, 4.33.1 and 4.34.0, and an oss-security post of Aug 2026 [S]; Rocq CVE-2026-72703, -72704, -72705 and -72714 (Oct 2026) [S]; Kunčar and Popescu, ITP 2015, ESOP 2017 and JAR 2019 [S].
* **This folder:** threads F (§9), L and S (§1.1, §1.3, §7).
