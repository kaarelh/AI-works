# Thread F: the certified notebook

*Research note by Claude (Anthropic), thread F of the follow-up to [`../slack-imitation.md`](../slack-imitation.md), version 2. Draft; not refereed. Code: [`threadF_certified.py`](threadF_certified.py) and [`threadF_cbc.py`](threadF_cbc.py) (experiment F1, exact posteriors). Outputs: `threadF_certified.out`, `threadF_certified_summary.json`, `threadF_cbc.out`, about 25 minutes on 4 cores.*

Setting and notation are those of slack-imitation.md §§1–3: a deterministic human P on append-only notebooks, a hidden clock, runs of n = n₀ + σ steps (σ = ρn), the majority decoder G, K = K(P), Lemma 1 of note.md, Theorem 1 of without-a-check.md, τ(y) the human's remaining time, (T1), (T2) and Lemma S. Nothing below asks the human whether a run has gone off track.

## Answers in brief

1. **The model** (§1). Notebook entries are typed and cite earlier entries: *certified claims* (with a proof, or code plus its machine record), *obstruction records* ("attempt at A: partial work; stopped at gap Z"), *suggestions* (plans, judgments), and *machine records* made by the scaffold. A *reliance discipline* Δ in the task instruction says what may be relied on and how negatives are recorded. The *local check* L(e) asks only: is e well-formed under Δ, and does its certificate establish its claim from exactly the entries it cites? Its verdict on e never changes as the notebook grows. It is not an on-track judgment.
2. **Invalid entries cost at most ⌊K⌋ runs, with no bisection** (Lemma F1, Theorem F2). If the human's own entries pass L (*self-validity*), then *every* invalid entry on a run, not only the first, sits at a mistake. So slack imitation with the check (CSI) has E[#runs with an invalid entry] + ((σ+1)/((D+1)n))·E[#failed runs with none] ≤ ⌊K⌋, and K/log₂(1/α) with ask-before-committing. Checking each step *before* committing it (CSI-CBC) repairs invalid steps during the run, with at most ⌊K⌋ asks in all. Failures of self-validity cost task queries, never correctness.
3. **What is still needed: bounded setback at valid entries, (B^V_D)** (§3). If L is sound, every claim in a notebook that passes it is true (Lemma F0), so (B^V_D) says *true content may redirect the human but not derail it for long*. The check takes out of the assumption: fabricated values, verdicts, fabricated citations, wrong retractions, paraphrases that overclaim, premature "proof complete", laundered "✓ verified". What remains are effects of attention and priority: an obstruction record on the approach that would have worked, a weaker true result, a suggestion, a misleading true lemma. (B-omit) is unchanged. With a human referee as L, the invalid entries it misses stay under the old (B-commit).
4. **The remaining assumption cannot be dropped** (Theorem F3). Some humans are self-valid, sound and disciplined, recover from every omission at once and from every invalid entry within one step, and have one flaw: they never retry an approach that has a recorded obstruction. On them, every protocol that uses task queries and local checks needs Ω(n₀K/(ε log(n₀/ε))) of them. This is the hidden-insight bound, reached through a *true* record.
5. **The negative-result problem** (§4). Under Δ, "tried A; it fails" is either invalid (caught) or an obstruction record. If the imitator really got stuck on A for lack of the insight, and the human trusts the record, that *is* still a fooled case, as bad as a silent human in the worst case. Three design features blunt it, and one human property removes it:
   * *Exposure by consequence.* A false negative is usually followed by a confident claim that some other route works. If that claim is false, it is invalid and caught. In F1 this cuts failures from 155 → 325 → 644 (n = 32 → 64 → 128) to about 10.
   * *Specific records are less confident than verdicts.* A record must say where the attempt stopped, so the posterior splits over gap locations, and ask-before-committing fires on more of them.
   * *A retry rule* (Theorem F4). If an approach may be set aside only after r obstruction records written at different steps, every derailment costs r mistakes. What remains is (A-pers): a recorded failure does not stop the human's own later attempt from succeeding. In F1, r = 2 and r = 3 divide the trusting human's failures by 3 and 4.
   * *Gap-triggered recovery* (G): a human who re-attacks a stated gap within d steps has bounded setback there, and slack absorbs it. In F1 such humans cost 13–15 failed runs at every n.
6. **With a certified result** (Proposition F5), checking the claimed solution's dependency cone is a verifier run by a referee, and a wrong claim in the cone is located with one task query instead of a search. Correctness then rests on L's soundness alone.
7. **Costs** (§6).
   * *Bisection is not needed.* Locality makes the check prefix-closed for free, and every invalid entry is its own locator.
   * *But checking costs N entries per round, not log n looks.* For a long project that is typically about 2 task steps of refereeing per round (range 0.3–15), unless certificates are machine-checked. The verifier version needs only the cone per output, plus a full check per rejection (at most ⌊K⌋ of them).
   * *n₀ grows* by about 1.2–1.6× in mathematics and software, and 1.3–2× in empirical work.
   * *K is unchanged* as a program, since the discipline is part of the problem statement.
8. **The design law holds** (§7). Every type tag and certificate is written by the human and imitated, but nothing is certified by being written: L checks it, and L's verdict never enters the notebook. Machine records are made by the scaffold in both chains. Step-level rules are checked by the protocol, which sees step boundaries; the human does not.
9. **Experiment F1** (§8; exact Bayes, commissions made at posterior 0.9, 20 humans per cell, trusting humans).
   * *Checkable claims:* SI and SI-ABC (α = 0.3) grow in proportion to n, about 260 → 700 → 1,200 failed runs. CSI stays at 9–11, and CSI-CBC at 0.
   * *A false negative followed by a valid weaker result:* every protocol grows in proportion to n, unless α is below the base rate (α = 0.05: no failures, 7–15 asks per problem). Humans who revisit gaps cost 13–15 at every n.
10. **Believability** (§9). Bounded setback at valid entries with D ≤ 2, with asking:
    * 60% for mathematics with machine-checked certificates (55% with a human referee);
    * 65% for software;
    * 30% for empirical work;
    * about 5 points more with the retry rule, except in empirical work.

    slack-imitation.md §4 has 55/60/30% for (B-commit), and thread L 50/55/25%. So the gain in believability is modest. The large gain is the verifier version for mathematics and software, whose correctness no longer depends on any setback assumption and whose verifier can now be a referee.

## 1. The model

**Entries.** Each entry e has a kind, a list of citations cit(e) (earlier entries or the problem statement x₀) and a content:
* **C, a certified claim:** a statement plus a certificate (a proof, or a reference to code and its machine record) establishing it from the cited entries. Certified negatives (a counterexample, an impossibility proof, a failing test with its record) are C entries. So are retractions: "entry e is invalid; here is the failing step".
* **O, an obstruction record:** "attempt at approach A: [partial work, certified like a C entry]; stopped at gap Z". It claims the partial work and that the attempt stopped at Z. It claims nothing about Z.
* **S, a suggestion:** a plan, conjecture or judgment of promise, marked as such. It asserts nothing certified.
* **R, a machine record:** the output of code or of a proof checker, or a retrieved source text. The scaffold appends it, in the reference chain and in imitator runs alike.

**The reliance discipline Δ.** It is part of the task instruction, so part of x₀ and of the reference chain.
* **(Δ1)** Certificates and partial work may rely only on C entries, R entries, or the partial work of O entries. Never on S entries, and never on the gap of an O entry.
* **(Δ2)** Negative results are recorded only as certified C entries or as O entries. No verdicts.
* **(Δ3)** Plans and judgments are recorded only as S entries.
* **(Δ4)** Claims about computations cite an R entry already present. Claims about the literature quote a retrieved R entry.
* **(Δ5_r)**, optional. An approach may be set aside only by a certified obstruction, or by an S entry that cites r O entries on it. At most one attempt at a given approach per step.

**The local check.** L(e) ∈ {0, 1} is a verdict on (x₀, e, cit(e)): is e well-formed under Δ, and does its certificate (or its partial work) establish what it claims from exactly the entries it cites? An S entry passes if it is well-formed. Step-level rules, such as Δ5's one attempt per step, are judged on the step that appended e. The protocol knows step boundaries; the human never sees them.
* *L is relative.* It asks whether e follows from what e cites, not whether what e cites is true.
* *L is local.* Its verdict on e is fixed once e is written.
* *L is not an on-track judgment.* It asks nothing about where the project is going.

**Assumptions.**
* **(L0)** L is a fixed function, as P is. It may be the human under a check instruction, another referee, or a machine (a proof checker, a test runner).
* **(L1) Self-validity.** At every notebook on which the human is asked for a step, every entry it appends passes L. Its entries stay valid relative to what they cite even when they cite the imitator's errors.
* **(L2) Soundness.** If L(e) = 1 and e's premises are true, e's claims are true.

(L1) is what localizes. (L2) is used only to describe what valid notebooks contain, and for correctness in Proposition F5.

**Lemma F0 (valid notebooks are true).** Under (L2), in a notebook all of whose entries pass L, every claim is true. Its only contents that are not true statements are gap locations, which claim nothing about the gap, and suggestions, which claim nothing certified.

*Proof.* Induction on position. By (Δ1) the premises are earlier C or R entries or partial work, which are true by induction, or correct by construction for R. ∎

## 2. Invalid entries are found at mistakes

**Lemma F1 (every invalid step is a mistake).** Assume (L0) and (L1). If the imitator's step at x′_k appends an entry e with L(e) = 0, then G(x′_k) ≠ P(x′_k). This holds whatever else the run contains.

*Proof.* By (L1) every entry of P(x′_k) passes L, and e does not, so the two lists differ. L(e) depends only on e, its citations and its step, all fixed once e is written. ∎

So (M1) and (M-prefix) of slack-imitation.md hold automatically. Unlike a state check, no flip has to be searched for, and no batching assumption (M3) is used.

**Protocols.** Slack, hidden clock and append-only notebook as in SI, with Δ in x₀.
* **CSI.** In each round, run the current imitator and check every committed entry (verdicts are cached, since they never change). If some committed step has an invalid entry, task-query that step. Otherwise task-query a uniformly random step. Add the answer.
* **CSI-ABC.** Runs are built with ask-before-committing. Asked steps are the human's, and are not checked.
* **CSI-CBC (check before committing).** Before committing the decoder's step at x′_k, check its entries. If one is invalid, ask the human for that step instead, append its answer, and add it to the data at once. After the run, task-query a uniformly random step.

**Assumption (B^V_D).** This is (B_D) of slack-imitation.md, required only at committed mistakes on runs all of whose entries pass L. Let the imitator append g ≠ P(y)'s entries at notebook y:
* (B-omit) if g is part of the human's step, τ(y ∪ g) ≤ τ(y);
* (B-valid) otherwise, τ(y ∪ g) ≤ τ(y) + D.

**Theorem F2 (certified slack imitation).** Assume τ(x₀ᵗ) ≤ n₀ for every problem, (L0), (L1) and (B^V_D), and let c = max{1, (σ+1)/(D+1)}. For every sequence of problems, possibly chosen adaptively:
* **(a) CSI:** E[#runs with an invalid entry] + (c/n)·E[#failed runs with no invalid entry] ≤ ⌊K⌋. So at most ⌊K⌋ invalid runs, and E[#failed runs] ≤ min{n, (D+1)n/(σ+1)}·⌊K⌋.
* **(b) CSI-ABC:** the same with ⌊K⌋ replaced by K/max{1, log₂(1/α)}, and at most K/log₂(1/(1−α)) asks on every path. (B^V_D) is needed only at committed mistakes.
* **(c) CSI-CBC:** at most ⌊K⌋ check-triggered asks on every path, no run contains an invalid entry, and (c/n)·E[#failed runs] ≤ ⌊K⌋.
* **(d) Sampled checks.** If each committed entry is checked independently with probability β, (a) holds with E Σ_t [1 − (1−β)^{m_t}] in place of E[#runs with an invalid entry]. Here m_t is the number of invalid steps of run t. In particular there are at most ⌊K⌋/β invalid runs.

*Proof.*
* *(a).* Fix round t; the run is fixed before the query's coin.
  * If the run has an invalid committed entry, the query lands on a mistake by Lemma F1, so q_t(M_t) = 1.
  * If it has none and fails, every entry passes L, so (B^V_D) applies at each mistake, Lemma S gives |M_t| ≥ c, and q_t(M_t) ≥ c/n.
  * q_t may depend on the run, so Theorem 1 of without-a-check.md gives E Σ_t q_t(M_t) ≤ ⌊K⌋.
* *(b).* Asked steps are the human's and pass L, so every invalid entry is at a committed step. The argument of Proposition 5(b) of slack-imitation.md gives each committed hit log₂(1/α) bits, or 1 bit by Lemma 1 when α > ½. The asks are counted as in 5(a).
* *(c).* A check-triggered ask lands on a mistake of the decoder in use, by Lemma F1. It lowers Φ by at least 1 (Lemma 1), and Φ ≤ K. The runs pass L by construction, so Lemma S applies to their committed mistakes, with asked steps as correct steps. For the uniform query, list the asks before step k, then the query's answer: if the query lands on a committed mistake, its answer was a mistake of the decoder that made that step, so it is worth at least 1 bit. Conclude as in Proposition 5(b).
* *(d).* The query lands on an invalid step with probability at least 1 − (1−β)^{m_t}. ∎

**Remarks.**
* *Drops.* Where (L1) fails, a flagged step may be the human's own. Query it anyway: the answer is the human's step, so nothing false is learned (thread A, Lemma A). Mark it excused, and go on to the next flagged step or to the uniform query. Each distinct drop costs one task query. (a) holds if (B^V_D) also covers runs whose only invalid entries are excused. So self-validity affects cost, not correctness.
* *How much weaker (B^V_D) is depends on L.* It is (B_D) minus the invalid entries that L catches. With a machine check (a proof assistant, tests, recorded computations), that is every false claim, and (B^V_D) is bounded setback at true content. A human referee misses a share of plausible errors: thread L cites 25–55% detection for desk checks of code and 60–96% for formal inspection. The errors it misses stay under the old (B-commit).

## 3. What remains, and why some of it must

**What the check removes from the assumption.** Thread E's list of violations, under Δ and L:

| | kinds (thread E numbering) | why |
|---|---|---|
| caught at a mistake (at most ⌊K⌋ runs in all) | V1 fabricated value; V2 *as a verdict*; V6 fabricated citation; V7 wrong retraction; V9 paraphrase that drops a condition from a claim; V13 premature "proof complete" (in mathematics and software); V15 laundered verification | each becomes a claim whose certificate does not establish it, or an entry that breaks Δ |
| removed at the source | V1 for computations | the scaffold computes values (Δ4) |
| left to (B^V_D) | V2 as an O entry on a live approach; V3 and V8 suggestions; V4 a weaker true result; misleading true lemmas (detours); V11 morale; V14 read-out | true content, gaps and suggestions are valid |
| left to (B-omit), unchanged | V5 by-product insights; hedges | omissions are invisible to any local check (thread A, Theorem C) |

**What each valid kind needs.**
* *Valid alternatives* (another correct proof, another correct design) need nothing beyond using true certified content as one's own: D = 0.
* *Detours* (a true lemma that points the wrong way) cost the detour. That is bounded if lines of work have content budgets ("pause a line of work after b entries without a certified milestone"), and unbounded if the detour never visibly fails.
* *O entries on a live approach* are the trap of §4.
* *Weaker true results* become O entries if Δ requires a result to state its gap to the target ("W proved; T∖W open"). Einstellung still threatens them: thread L reports that it is robust in experts for valid but weaker options, and that a warning freed only about half of Luchins's subjects.
* *Suggestions* are bounded if the human re-plans from certified content each step and treats suggestions as one input. Sunk cost is weaker for a lone researcher than thread E assumed (thread L §3).

So (B^V_D) says that true content may redirect the human but does not derail it for long. Every remaining failure is one of attention or priority, not of false belief. The next theorem shows that no local check can remove these.

**The class TRUST(m, n₀, q, η).** Problems p ∈ [m], each with approaches A₀, …, A_{n₀−1}. θ = (t_p, k_p)_p: t_p = ∞ with probability 1 − η, otherwise uniform on {0, …, n₀−1}, and k_p uniform on [q]. These are Theorem 3's insights, attached to approaches.
* *Entries:*
  * O_j: "attempt at A_j: [standard partial work]; stopped at gap Z_j", the same text for every θ;
  * C_{j,k}: "A_j works; Z_j holds by k";
  * X_{j,k}: the retraction of C_{j,k}.
* *L is exact:* L(O_j) = 1; L(C_{j,k}) = [θ_p = (j, k)]; L(X_{j,k}) = [θ_p ≠ (j, k)].
* *The human P_θ* at notebook y. Let c be the last C or X entry of y.
  1. If c = C_{j,k} is invalid, append X_{j,k}. If it is valid, append nothing.
  2. Otherwise let J be the least j such that y contains no O_j. Append C_{t_p,k_p} if J = t_p, and O_J if J ≠ t_p.
* *Success:* S = "y contains C_{t_p,k_p}", or t_p = ∞. It is preserved by appending, and τ(x₀) ≤ t_p + 1 ≤ n₀ when t_p < ∞.

**Theorem F3 (an assumption on valid content is necessary).**
* *(a) The humans of TRUST are good at everything else.* Every P_θ is deterministic and a function of the notebook (hidden clock). It satisfies (L0)–(L2) with an exact L, and Δ (no verdicts). It never builds on an invalid entry. And at every notebook y:
  * τ(y ∪ ∅) = τ(y);
  * τ(y ∪ e) ≤ τ(y) + 1 for every invalid entry e;
  * τ(y ∪ e) ≤ τ(y) for every valid entry e except O_{t_p}, after which τ = ∞ unless S already holds.
* *(b) Yet every protocol pays the hidden-insight price.* Let n ≥ n₀ and q ≥ 4n/n₀. Take any protocol that makes Q task queries and C single-entry checks, at any notebooks, adaptively and possibly at random, and outputs an imitator that appends at most one entry per step. Then its run on a fresh problem fails with probability at least (η/2)(1 − 6(Q+C)/(n₀m)).
  * So for ε ≤ 1/16, with η = 8ε, reaching failure probability ε needs Q + C ≥ n₀m/8, which is Ω(n₀·E[K]/(ε log(n₀/ε))) for fixed ρ.
  * The same holds with O_j replaced by a weaker true result W_j that pre-empts C_{j,·}, or by a suggestion "set A_j aside" that the human follows.

*Proof.*
* *(a).* Read it off the definition.
  * An invalid C is retracted in one step, after which rule 2 acts as before. After an X entry, valid or not, rule 2 applies, and an X never affects S.
  * A valid O_j with j ≠ t_p only saves the human an attempt.
  * O_{t_p} makes J skip t_p for ever.
* *(b), point queries.* Every answer about p depends on θ_p only through whether θ_p lies in a set A of at most q points sharing one approach j:
  * rule 1 tests the single point of c;
  * rule 2 tests {J} × [q], and reveals k_p on a hit;
  * a check tests one point.

  Call that event a *hit*. Given the past and no hit on p yet, θ_p has the prior law restricted to the points not yet excluded, and that set has mass at least 1 − η, because t_p = ∞ is never excluded. So each query hits with probability at most (|A|·η/(n₀q))/(1 − η) ≤ 2η/n₀. Hence Pr[the fresh problem p was hit] ≤ 2η(Q+C)/(n₀m), as in Theorem 3.
* *(b), coupling.* Without a hit, every answer about p equals the answer for t_p = ∞. So the transcript then equals the one for θ′, which is θ with t_p set to ∞, and θ′ is independent of (t_p, k_p).
  * Call p *heavy* if it receives at least n₀/2 queries. On every path at most 2(Q+C)/n₀ problems are heavy.
  * Hence Pr[t_p < ∞, no hit, heavy] ≤ η·Pr[p heavy | t_p = ∞] ≤ η·Pr[p heavy]/(1 − η) ≤ 4η(Q+C)/(n₀m).
* *(b), guessing.* Suppose t_p < ∞, there is no hit, and p is not heavy. Then θ_p is uniform on at least n₀q/2 points given the transcript. The run, a function of the transcript and independent coins, contains at most n claims. So it contains C_{θ_p} with probability at most 2n/(n₀q) ≤ ½.
* *(b), conclusion.* Pr[fail] ≥ ½·(η − 2η(Q+C)/(n₀m) − 4η(Q+C)/(n₀m)).
  * The consequence uses E[K] = m(h(η) + η log₂(n₀q)) ≤ 8εm·log₂(e·n₀q/(8ε)).
  * The variants change only the text of the trap entry. ∎

*How the trap arises.* On TRUST, the class-prior decoder writes O_j at every step, each at mass at least 1 − 2η/n₀. Its trap O_{t_p} is a confident valid commission, so ask-before-committing does not fire unless α < 2η/n₀. Then it asks at every attempt, n₀ times per problem: thread E §4's trade, which is not cheap here.

## 4. Negative results

**Is the honest false negative still a fooled case?** Suppose the imitator, lacking the insight, attempts A, gets stuck at Z, and writes an accurate O entry; the human, on reading it, does not retry A. Then yes, it is still a fooled case.
* *Checkable or harmless?* The record is checkable, and valid. It is harmless only if the human retries.
* *How bad.* With trust and no retry, it is exactly Theorem F3's trap: a single mistake, found at rate 1/n, as for silent humans.
* *How often.* The discipline does not change the base rates that make "stuck" the decoder's plurality outcome. The evidence (thread L §2) confirms the mechanism: recorded dead ends are rarely revisited (16% of failed drug candidates are ever retried), many recorded negatives are false (about two thirds of psychology papers with null results contain at least one), and Wiles's return to his own abandoned approach took three years, D ≈ 12 steps.

Four things blunt it.

**(i) Exposure by consequence.** An imitator that believes A fails usually goes on to claim that another route B works. If B does not work, that claim is invalid, and CSI catches the run at a mistake, which teaches that B fails here.
* *What escapes:* a run that ends empty-handed, or one that settles on a true weaker result.
* *In F1:* type N (false negative, then a checkable fallback) costs 9–11 failed runs under CSI at every n, against 155 → 325 → 644 under SI. Type W (false negative, then a valid weaker result) is not helped at all.

**(ii) Specific records are less confident.** Under Δ2 the decoder's negative names its gap. Suppose the hypotheses that predict failure disagree about where the attempt stops, the most common gap having share s of them. Then the top label's mass is at most π_fail·s, where a verdict pools all of them into one label of mass π_fail.
* *What this buys:* ask-before-committing fires whenever π_fail·s < 1 − α, so some confident verdicts become unconfident records, which go to the human.
* *The price:* more asks on genuine dead ends, within the (ln 2)K/α lifetime budget.
* *Requirement:* μ must treat the gap location as content, not wording.

**(iii) A retry rule moves the decision into the discipline.** Call an approach A *live* on a problem if **(A-pers)** holds: at every notebook of a run that passes L on which A is open (not set aside), the human's step appends no O entry on A. If it attempts A, it succeeds.

**Theorem F4 (the r-fold retry rule).** Assume τ(x₀) ≤ n₀, (L0), (L1), and Δ with (Δ5_r). Assume (B^V_D) at every valid committed mistake except the steps that set a live approach aside, where nothing is assumed. Then a failed run that passes L has |M| ≥ min{c, r}, with c = max{1, (σ+1)/(D+1)}. So Theorem F2(a)–(c) hold with min{c, r} in place of c.

*Proof.*
* If no live approach is set aside on the run, apply Lemma S.
* Otherwise let the live approach A be set aside at step k.
  * By (L2), a valid certified obstruction is true, so it cannot set aside a live approach. So the set-aside entry is an S entry. It passes L, so it cites r O entries on A, written at r distinct steps before k; the one-attempt-per-step rule is checked by L at the step level.
  * A was open at each of those steps. By (A-pers) the human's step there appends no O entry on A, while the imitator's step does.
  * That gives r mistakes. ∎

*Cost.* The human's own dead approaches now get r attempts. If a fraction f of its time goes into attempts that end in O entries, and a repeat attempt costs a fraction c_r of the first, n₀ grows by the factor 1 + (r−1)·c_r·f.
* *For example,* f = 0.3, c_r = 0.3 and r = 3 add 18% to n₀, and charge derailments n/3 instead of n.
* *In F1* the rule costs the human r − 1 extra steps on 90% of problems, and divides the trusting human's failures by 2.9–3.0 (r = 2) and 3.8–3.9 (r = 3). The decoder's derailing runs there have r + 1 mistakes.

*What remains is (A-pers),* a property of ability, not of decision: once forced to retry, the human succeeds despite the record. Einstellung is its main threat, since the retry may follow the recorded partial work into the same gap. A fresh-start variant helps here: Δ can require the retry to begin without reading the previous attempt's partial work. Its cost is part of c_r.

**(iv) Gap-triggered recovery, with no rule.** **(G)**: if the human's own attempt at A from y would succeed, then from every valid y′ ⊇ y that holds an O entry on A with gap Z, A still open, the human establishes Z within d steps.
* Then O entries on live approaches satisfy (B-valid) with D = d.
* (G) is thread C's persistence for the item "a proof of Z", with the trigger made explicit. The O entry names the crux, which is the best trigger a record can give.
* In F1, humans who revisit a gap after one step cost 13–15 failed runs at every n.

## 5. With a certified result

**Proposition F5 (a referee as a localizing verifier).** Let S(y) be: y contains an entry claiming a solution of x₀ whose *dependency cone* passes L. The cone is the entry together with, recursively, everything it cites. S is preserved by appending. Assume τ(x₀) ≤ n₀, (L0) and (L1).

Protocol CSI-V, for each problem: run the imitator; then
* if some candidate solution's cone passes L, output it;
* else if some candidate's cone has an invalid entry, task-query that entry's step, add the answer, and rerun;
* else check every committed entry, and task-query an invalid step if there is one. If there is none, task-query uniform steps of the fixed run until one lands on a mistake, add the answers (the hit first), and rerun.

Then:
* (a) every output's cone passes L, so it is correct under (L2), whatever the human's setbacks;
* (b) almost surely at most ⌊K⌋ runs are rejected;
* (c) a rejection with an invalid entry costs one task query. Under (B^V_D), one without costs at most min{n, (D+1)n/(σ+1)} task queries in expectation;
* (d) the checks number |cone| per output, plus at most N_t per rejected run.

*Proof.* Each rejection ends with a task query at a mistake of the decoder in use. It is either at an invalid step (Lemma F1), or found by the search on a run with no invalid entry. Such a run has a mistake, because a run without mistakes is the human's own, which satisfies S. Lemma 1 gives (b). (c) follows from Lemma S and the geometric search, by Wald's identity, as in Proposition 4 of slack-imitation.md. ∎

Compared with Proposition 4, the verifier is a referee reading one proof, not an oracle, and a wrong lemma in it costs one task query, not a search of up to n. Under (L2) with a human referee, errors that look right get through; with a proof assistant or a test suite they do not.

## 6. Costs

* **Checks per round.** Every committed entry, once. Verdicts are cached, asked steps need no check, and a rerun shares its prefix up to the first changed step.
  * *Size.* Suppose a careful mathematician's three-month step (about 60 working days) has 5–20 entries, and refereeing one locally takes half an hour to a day. Then a run of n ≈ 50 steps costs 0.3–15 task steps of refereeing, about 2 for 10 entries at two hours each. That usually exceeds the round's one task query.
  * *When it pays.* The full check pays only if invalid confident commissions are a sizeable share of the slow failures.
  * *Cheaper options:*
    * machine certificates (free);
    * the verifier version (the cone per output, and a full check per rejection only);
    * sampled checks (Theorem F2(d): at most ⌊K⌋/β invalid runs for β·N checks per round);
    * a cheap batched skim for *format*, which catches verdicts, uncited claims and unmarked plans, with semantic checks of claims only.
* **Bisection.** It is not needed. Locality gives prefix-closure free, and every invalid entry is its own locator, so locating costs nothing beyond checking.
  * Bisection over batched prefix checks would save verdicts (⌈log₂ n⌉ looks) but not reading. Each look must read its prefix, as thread A §3 found for state checks. Validity has no shortcut by skimming, except for format.
  * So thread A's (M3) is plausible only for the format tier.
* **n₀.**
  * *Certificates:* about +10–30% in mathematics (written proofs of lemmas as one goes), +10–20% in software (tests), +20–50% in empirical work (recorded computations and provenance).
  * *O entries instead of verdicts:* a little.
  * *The retry rule:* the factor 1 + (r−1)·c_r·f.
  * *Total:* about 1.2–1.6× in mathematics and software, 1.3–2× in empirical work.
  * *Effects.* The bound (D+1)K/ρ does not depend on n₀. The fallback n₀K/(1−ρ), the compute, and the risk that τ(x₀) > n₀ (heavy tails) all grow with it.
* **K.** Unchanged as a program: the discipline is part of x₀, and P is the same program.
  * In practice, longer labels mean more wording to learn, and that sits inside K.
  * Asks fire more often on specific content, within the (ln 2)K/α budget.
  * A check verdict is an answer of the same human to a check input, so it could be added to the data as a label (thread A's "checks become training data"). This is not used here.

## 7. The design law

Thread E §4: a correct imitator step must produce exactly P(y).
* **Type tags, citations, certificates, O formats and suggestion marks** are written by the human in the reference chain and imitated, so (T1) holds. They certify nothing by being written. L checks each one, and its verdict is held by the protocol, never written into the notebook. This is what distinguishes the design from self-written "✓ verified" tags.
* **The protocol never strikes an entry.** An invalid step is either queried after the run (CSI) or replaced by the human's own step (CBC, as in ask-before-committing). Striking without asking would make the run another decoder's output and lose Lemma 1.
* **Machine records** are produced by the scaffold in both chains, y ↦ P(y) ∪ exec(·). That is still a function of y.
* **Step-level rules** ("one attempt per approach per step") are behaviour for the human, with no markers in the notebook. Only the protocol, which knows step boundaries, checks them, so the clock stays hidden.
* **Content-triggered rules** (Δ5's count, content budgets, audits after b entries) use content, not time.
* **Provenance stays hidden.** L is relative, so the human never needs to know whether an entry is its own.

## 8. Experiment F1

**Why a new class.** In E6 the imitator's wrong commitments are confident only at t_p = n₀ − 1 (referee 5), which flatters ask-before-committing. F1 separates *when* from *what*.
* A value-free "setup" entry reveals when the decision is due.
* The decision is then made at posterior π = 0.9, the base rate.

**The class** (code docstring).
* *Problems.* m = 100 problems with unknown (t_p, k_p): t_p uniform on {0, …, n₀−6}, k_p = 1 with probability 0.9. The human writes "setup" at any step j ≥ t_p, then its decision; σ = n/2.
* *Types of decision:*
  * **C:** a certified value, invalid if wrong;
  * **N:** an attempt at approach 2, recorded as success or as a valid O entry, then the fallback claim "value 1 works", which is invalid if k_p = 2;
  * **W:** like N, but the fallback is a weaker true result, valid for every problem.
* *Humans:*
  * **trusting:** builds on invalid claims and never retries a recorded gap;
  * **revisit:** retries a gap after one step;
  * **noticing:** corrects everything at once.
* *Measurement.* Online for R = 4·m·n rounds, with one task query per round, as in referee 5's test. The entry is the number of failed runs during learning, the quantity Theorem F2 bounds. 20 humans per cell, the same humans and seeds in every row of a column.

| type and human | protocol | n = 32 | n = 64 | n = 128 |
|---|---|---|---|---|
| C, trusting | SI | 295 ± 26 | 693 ± 72 | 1,224 ± 109 |
| | SI-ABC, α = 0.3 | TBD | TBD | TBD |
| | CSI (and CSI-ABC) | 9.4 ± 0.8 | 10.8 ± 0.7 | 9.7 ± 0.5 |
| | CSI-CBC | TBD | TBD | TBD |
| N, trusting | SI | 155 ± 16 | 325 ± 36 | 644 ± 52 |
| | SI-ABC, α = 0.3 | TBD | TBD | TBD |
| | CSI (and CSI-ABC) | 9.4 ± 0.8 | 10.8 ± 0.7 | 9.7 ± 0.5 |
| | CSI-CBC | TBD | TBD | TBD |
| W, trusting | SI = CSI | 295 ± 26 | 693 ± 72 | 1,224 ± 109 |
| | SI-ABC = CSI-ABC, α = 0.3 | TBD | TBD | TBD |
| | SI-ABC, α = 0.05 | TBD | TBD | TBD |
| | SI = CSI, retry rule r = 2 | 100 ± 11 | 226 ± 25 | 418 ± 35 |
| | SI = CSI, retry rule r = 3 | 77 ± 8 | 161 ± 15 | 315 ± 26 |
| W, revisit | SI = CSI | 12.5 ± 1.0 | 13.8 ± 1.1 | 12.9 ± 0.8 |
| W, noticing | SI = CSI | 12.2 ± 1.0 | 13.5 ± 1.0 | 12.9 ± 0.8 |

**Reading.**
* *Checkable claims (C).* On trusting humans, SI's failures grow in proportion to n (one mistake per failed run). Ask-before-committing at α = 0.3 does not help, because the wrong value is committed at mass 0.9 TBD. CSI stays at about the number of k_p = 2 problems (about 10) at every n, and CSI-CBC removes those failures too, at one ask each.
* *Exposure by consequence (N).* The valid false negative is followed by an invalid fallback claim, and CSI catches every such run. CSI-CBC repairs the fallback step but leaves the false negative in that run, so each k_p = 2 problem still fails a few times (TBD).
* *The residual (W).* The false negative followed by a valid weaker result grows in proportion to n under every protocol with α = 0.3, check or no check, exactly as Theorem F3 predicts. Only α below the base rate removes it (α = 0.05: no failures, TBD asks), as in thread E §4.
* *The retry rule.* It divides W's failures by 2.9–3.0 (r = 2) and 3.8–3.9 (r = 3), as Theorem F4 predicts: the derailing run has r + 1 mistakes. The human's own runs take r − 1 more steps on k_p = 1 problems.
* *Humans who revisit gaps* (bounded setback at O entries) cost 12–15 failed runs at every n, the same as noticing humans: slack absorbs the setback.
* *The cost of the check.* About 0.8n entry checks per round (27, 51 and 99), of which 1–4 are claims or records.
* *Identical rows.* SI and CSI coincide on type W, and C and W coincide under SI, because the check never fires there and the classes have the same structure with the same seeds. Common random numbers.

**What F1 does not show.** It illustrates the theorems on a toy class. Whether real humans are trusting or revisiting, and whether a referee's L catches the imitator's invalid entries, are the open empirical questions.

## 9. Believability

These are for a careful researcher, on the graded reading of slack-imitation.md §4: the property fails at no more than about 5% of the relevant cases. Thread L's evidence moves several of them down.

| claim | mathematics | software | empirical |
|---|---|---|---|
| (L1) self-validity: own entries fail a fresh local check at under 2% of entries | 80% (95% formal) | 90% | 65% |
| L catches at least 70% of the imitator's invalid confident entries: human referee / machine | 50% / 97% | 60% / 90% (tests) | 40% / 85% (computations only) |
| (ii) Δ can be followed at ≤ 1.5× n₀, and τ(x₀) ≤ n₀ stays plausible | 70% (25% if fully formal) | 80% | 45% |
| (B^V_D), D ≤ 2, with asking: human L / machine L | 55% / 60% | 60% / 65% | 30% / 30% |
| the same with the retry rule (Δ5, r = 3), i.e. (A-pers) for retries | 60% / 65% | 65% / 70% | 30% / 35% |
| (B-commit), D ≤ 2, with asking: slack-imitation.md §4 / thread L | 55% / 50% | 60% / 55% | 30% / 25% |
| (B-omit), unchanged (raw-record rule helps a little) | 70% | 70% | 50% |
| CSI beats chained imitation by ≥ 2× / ≥ 5× (n₀ ≈ 20–40, with asking), net of check cost | 70% / 50% | 75% / 55% | 60% / 35% |
| CSI-V outputs are correct (L sound in practice): human L / machine L | 75% / 98% | 90% (as good as the tests) | – |

**Why these numbers.**
* *Mathematics.*
  * *What the check takes out.* Of thread E's common violations in mathematics, the check removes the verdict form of V2 and the occasional V1, V6, V9, V13 and V15. Their setbacks are mostly ∞, so this is real progress on the assumption.
  * *What it leaves.* The commonest residue is V2's: the record on the attempt that would have worked. The evidence says such records are rarely revisited. Precise gaps help (the crux is named), and the retry rule helps more, but Einstellung limits (A-pers). Hence +5 points, not +20.
  * *The referee.* Detection rates (thread L §1) make human L weak against plausible errors. So for correctness, the verifier version wants a proof assistant.
* *Software.* Certificates are tests and records, so L is a machine for most claims, and stuck records are reproducible failures with logs, which invite retries. The residue is design choices kept by sunk cost and weak-but-passing tests (true but misleading).
* *Empirical work.* The certified part is the computations. The damaging content is mostly valid: underpowered null results recorded accurately, analysis choices, interpretations as suggestions. The check helps against fabricated values and laundered checks, not against these. Hence no change.
* *Against slack-imitation.md §4.* The (B-commit) row moves from 55/60/30% to 60–65/65–70/30–35% with machine checking and the retry rule. That is modest. The verifier version moves the most: in mathematics and software, correctness depends only on L's soundness, and a proof assistant or test suite makes that near-certain.

## 10. Open problems

1. **Deployment.** A frozen imitator with check-before-committing must do something at an invalid step: abstain, or drop the entry. Is there a PAC theorem for that filtered decoder, as thread H gives for asking?
2. **Measure (A-pers) and (G).** Plant an O entry on the approach that worked into researchers' own notebooks, with and without the retry rule and the fresh-start variant, and measure retries and their success.
3. **Referee sensitivity.** How often does a careful local referee pass the imitator's wrong certificates? Those are its plausible errors, the hardest case for review.
4. **Relational local checks.** Theorem F3 rules out single-entry checks. Could a check over a few entries ("is this O entry's gap certified elsewhere in the notebook?") localize some valid traps, without becoming an on-track judgment?
5. **Empirical work.** Certified records of experiments need the scaffold to run the experiments in the reference chain too. Outside that, the certified notebook covers only computations.
