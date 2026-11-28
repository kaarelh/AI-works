## 6. Inputs from outside

Rehearsal draws the top-level input z from D₀; deployment may draw it otherwise. Like R1, the bounds in K below are empty for a person under a generic prior; those in 2^K are empty for any human of interest. Statements cited by number are those of `proofs/shift-abstain.md`.

### 6.1 Shift

**Theorem S4 (three kinds of shift)** (proved here, from R1, S1, N1 and N3). Run Protocol R for n rounds with top-level law D₀ and deploy M^(T).

(i) *The shift that the system makes itself costs nothing.* For every set X₁ of inputs, the probability that the question of round T lies in X₁ is 1/L times the expected number of calls of the deployed run in X₁, whatever the scaffold does with the answers. So Theorem R1 needs no factor for shift.

(ii) *A shift of the top-level law to D₀′ ≤ B·D₀ costs the factor B* (S1). For N laws with disjoint supports there is a class on which every protocol pays the factor N, and all laws of ℓ bits cost about 2^ℓ (N3, S2).

(iii) *Any other shift has no guarantee:* where D₀ does not dominate D₀′ nothing was asked, and N1 applies.

*Proof.* (i) The asked index J is uniform and independent of the run, and the deployed run has the law of the run of round T. (ii), (iii): the cited statements (`proofs/shift-abstain.md`, Theorem 2.5). ∎

Part (i) is the reduction of Ross, Gordon and Bagnell (2011) as used by Li and Zhang (2025). *What it does not say:* (i) equates expected numbers of calls. A kind of call rarer than about one in n is probably never asked; there the prior fixes the answer.

**Proposition S1 (density ratio)** (proved here; (a) is the standard change of measure).

(a) Let E′ and E be expectations over a run with z drawn from D₀′ and from D₀. If D₀′ ≤ B·D₀, then E′[φ] ≤ B·E[φ] for an answerer fixed before the run and every function φ ≥ 0 of runs. So every bound of Section 3 on the deployed run (unfaithful calls, the distance of R2, a validated rate) holds with the factor B. Without domination, add sup φ·D₀′{z : D₀′(z) > B·D₀(z)}.

(b) The *visit measure* of an answerer gives each set of inputs the expected number of calls of its run in it. Let d̄ be the average of the visit measures of M^(1), …, M^(n), and d′ ≤ B·d̄ a measure on inputs. Then E ∫ TV(P, M^(T)) dd′ ≤ (2L − 1)·B·E β, where β is the expected number of unfaithful calls of the run of M^(T). The factor 2L − 1 cannot be lowered below L/2.

*Proof.* (a) The expectation of φ given z does not depend on the law of z. (b) `proofs/shift-abstain.md`, Proposition 2.3 and Example 2.2. ∎

In the example an early mixture errs at the first call, is thereby sent away from the input x₁ that the human system visits L − 1 times, and its error at x₁ never shows in its own runs. For L = 100, n = 10⁴ and a human of weight 1/L, a deployment that visits x₁ meets 0.4975 unfaithful calls in expectation where B alone would allow 0.0463. So for visit measures S1 fails with B alone, by the factor L/(2 ln L): the compounding of errors of Ross and Bagnell (2010). *What S1 does not say:* anything about tasks to which D₀ gives no mass.

**Proposition S3 (a property of tasks)** (proved here). Let Γ be a set of tasks with D₀(Γ) = p > 0. On a task in Γ the deployed run has at most L·K ln 2/(p·n) unfaithful calls in expectation, for a deterministic human. For protocols that take each question from a run on a task drawn from D₀ the factor 1/p is necessary: if δ ≤ 1/4 and L/(2δ) is an integer, there are a scaffold and a class for which failure probability at most δ on Γ for every member needs n ≥ (L/(4δ) − L)/p. Proof: `proofs/shift-abstain.md`, Proposition 2.4. *What it does not say:* 1/p is the price of a property that was not singled out. A property named in advance costs nothing (rehearse on D₀ given Γ); N unknown disjoint ones cost the factor N (N3).

[Here the block of part lower-bounds: Theorem N3 and what S2 needs.]

### 6.2 Open systems

Now no scaffold can be run in advance, and inputs arrive in any way.

**Proposition S5 (asking at random, for ever)** (proved here; label-efficient prediction, Cesa-Bianchi, Lugosi and Stoltz 2005, applied to the regret bound of R1). After the input x_t is fixed, a coin decides with probability q that the human answers and the pair joins the data; otherwise the current mixture M^(t) answers. Then E Σ_t KL(P ‖ M^(t))(x_t) ≤ K ln 2/q over all steps. For a deterministic human the mixture gives at most (1 − q)·K ln 2/q wrong answers in expectation over the whole unbounded run; an example comes within the factor 2 ln 2. Proof: `proofs/shift-abstain.md`, Theorem 3.1. *What it does not say:* which steps are wrong. And the human never leaves.

**Theorem N7 (the asking cannot stop early)** (proved here). At each step a learner sees an input and asks the human, predicts, or abstains; it sees an answer only when it asks. Sil counts its wrong predictions, Abs its abstentions.

(a) Let the class contain the N thresholds x ↦ 1[x ≤ i], 0 ≤ i < N, and show the inputs 1, …, N − 1 in order. Every learner with at most Q ≤ N/2 − 1 questions has E[Sil + Abs]·(Q + 1) ≥ 3N/16 for a uniformly drawn threshold as the human, hence for some threshold; if Q + 1 divides N, a learner with at most Q questions has E[Sil + Abs]·(Q + 1) < N/2.

(b) For every class of functions, every human f in it and every b ≥ K, *enumeration* (keep the hypotheses of weight at least 2^(−b) that fit the answers; ask where two of them differ) is never wrong and asks at most 2^b − 1 questions, on input sequences of any length.

Proof: `proofs/shift-abstain.md`, Theorem 3.3 and Corollary 3.6.

So a deterministic human can leave an open system: never later than after 2^b − 1 questions, if a bound b ≥ K is known; but for 2^K equally weighted thresholds as in (a), not before 2^K·min{1/2, 3/(16j)} − 1 questions on some run, if j silent mistakes and unanswered abstentions are tolerated in expectation. Only in that sense can the asking not stop. *What it does not say.* (a) is a worst case over one class and one sequence. For a human who is not deterministic see Section 7.5.

## 7. Failing obviously

An imitator may *abstain*; a run halts at its first abstention and is then *aborted*. A *silent error* is an answer that is neither the human's nor an abstention. Until Section 7.5 the human is a function f; A is the set of asked inputs; c denotes constants of the reference machine.

### 7.1 The threshold rule

**Theorem Ab1** (proved here; the Bayes-mixture form of the trade-off of Sayedi, Zadimoghaddam and Blum 2010). For η < 1/2 the rule Thr_η answers y if M_D(y|x) ≥ 1 − η and abstains otherwise.

(a) On any sequence of asked inputs, apply the rule to each input before the human answers; let it be wrong u times and abstain v times. Then u·log₂(1/η) + v·log₂(1/(1 − η)) ≤ K. So u ≤ K/log₂(1/η) and v ≤ K/log₂(1/(1 − η)) ≤ K ln 2/η; examples attain the first two bounds up to rounding. If η < w(f) the rule is never wrong, at any input.

(b) Rehearse with Thr_η answering the calls and one uniformly chosen call of each run, the aborting one included, put to the human. The run of the rule of a uniformly chosen round has at most L·K/(n·log₂(1/η)) wrong answers in expectation and is aborted with probability at most L·K ln 2/(n·η).

*Proof.* (a) As in the proof of R1, the product over the asked rounds of M^(t)(f(x_t)|x_t) telescopes and is at least w(f). The factor is at most η at a wrong round and below 1 − η at an abstention round. If η < w(f), then M_D(f(x)|x) ≥ w(f) > η, and no other answer reaches 1 − η. (b) The asked call is a uniformly chosen one of the L call slots. So round t is a wrong round with probability 1/L times the expected number of wrong answers of its run, and an abstention round with probability 1/L times its abort probability. Take expectations in (a). ∎

*What it does not say.* The counts are over asked rounds; an unasked error teaches nothing. In (b) the rule itself must drive the rehearsal.

### 7.2 The minimum over a plausible set

For a set 𝒞 of hypotheses, Min_𝒞 answers y with probability min_{ν∈𝒞} ν(y|x) and abstains with the rest. Order the hypotheses by posterior weight. The *top set* keeps those whose weight is at least α times the total weight of those ranked no lower; it has at most 1/α members. The *ratio set* keeps those of weight at least α times the largest, and contains the top set.

**Theorem Ab2** (the rule, the top set and the first clause of (b): Cohen, Hutter and Nanda 2022; the rest proved here, (a) from their domination at a single step). The human may be any sampler.

(a) *Dominance.* If P ∈ 𝒞, then on every scaffold, with inputs from anywhere, the run of Min_𝒞 is, in a coupling, the human system's run or an initial part of it followed by an abort. So every set of complete runs has at most its probability under the human system.

(b) P stays in both sets for ever with probability at least 1 − α/w(P) (Ville's inequality); a deterministic human with certainty if α ≤ w(f).

(c) *Coverage.* In the class of all programs, Min over the ratio set abstains with certainty wherever sep(x; A) ≤ log₂(1/α) − c. For programs of total functions it answers f(x) wherever sep(x; A) > K + K_D + log₂(1/α) + c, where K_D is the length of the shortest program consistent with the data.

(d) *Abort after rehearsal.* After n rounds of Protocol R freeze the top set 𝒞 and deploy Min_𝒞 on the same scaffold. For a deterministic human the run is aborted with probability at most Pr[f ∉ 𝒞] + δ + L·(K ln 2 + ln(1/(αδ)))/(α·n) + L(L − 1)·K ln 2/n. For samplers it is at most α/w(P) + δ + (L/α)·√(2Γ/n) + L(L − 1)·√(K ln 2/(2n)), where Γ := ln S + ½·ln(1/(α·w(P))) + ln(1/δ) and S := Σ_ν √w(ν); the term ln S is needed.

Proof: `proofs/shift-abstain.md`, Theorems 5.1, 5.3, 5.6 and Proposition 5.2. For (a), keep each answer of the human's run with probability min/P. For (c), patch a plausible hypothesis on a simple set without asked inputs, with either of two answers.

*What it does not say.* P ∈ 𝒞 is a theorem only for α ≤ δ·w(P), or α ≤ w(f). Then by (c) the rule refuses every unasked input simpler than about K, and (d) needs n of order 2^K, for samplers 4^K: empty for a person. With a moderate α, that the human is within log₂(1/α) bits of the best explanation is an assumption which the data cannot confirm.

*Comparison.* Cohen, Hutter and Nanda keep the demonstrator, who may have memory, and query with the leftover probability. They bound the expected sum of cubed query probabilities by |𝒜|·α⁻³·(24/w + 12) (their Theorem 1; 𝒜 the actions, w the demonstrator's prior weight), and events unlikely under the demonstrator with factors that grow with time (their Theorem 5). Here the query is an abort, domination is exact for whole runs, and the price moves into (d).

### 7.3 The novelty rule

**Proposition Ab3** (proved here; Observation B of the researcher's notes). For programs of total functions, Nov_s asks, or abstains, at x if sep(x; A) < s, and otherwise answers as the shortest program consistent with the data. (a) It asks at most 2^s − 1 questions on any input sequence, whatever the human. (b) If s > 2K + c it is never wrong. (c) Frozen, it refuses exactly {x : sep(x; A) < s}, for ever: with the s of (b), every unasked input simpler than about 2K. With a smaller s nothing here guarantees its answers.

*Proof.* (a) Each question uses up a test of fewer than s bits. (b) If the shortest consistent program g is wrong at x, the set {g ≠ f} separates x from A and takes at most 2K + c bits. ∎

### 7.4 The trade-off, rocks and whitelists

**Proposition N4** (standard: the example of singletons for learners that may say "I don't know", Li, Littman and Walsh 2008). A learner that is never silently wrong for every member of a class asks or abstains wherever a member that agrees with the human on A differs from the human. With the zero function as the human and the 2^d point functions in the class, that is every new input. Proof: `proofs/shift-abstain.md`, Proposition 7.1.

**Theorem Ab4** (proved here; the lower bound of row 3 follows from the exact result of Zhang and Chaudhuri 2016). For a deterministic human of K bits:

| setting | can be had | cannot be had |
|---|---|---|
| open system; Thr_η, audits at rate q, abstentions answered | E[Sil] ≤ ((1 − q)/q)·K/log₂(1/η), at most K ln 2/η abstentions | 2^K thresholds, inputs in order, at most Q ≤ 2^(K−1) − 1 questions: E[Sil + Abs]·(Q + 1) ≥ 3·2^K/16, Abs counting unanswered abstentions (N7(a)) |
| open system, no silent error | 2^b − 1 questions for a known b ≥ K (N7(b)) | point functions: every new input asked or refused (N4) |
| every answer shown, at most k wrong, K ≥ k + 1 | about K ln 2·2^(K/(k+1)) abstentions (Ab1(a)) | 2^K thresholds, rules without coins: (k + 1)·2^(K/(k+1))/e − k − 1 abstentions on some sequence |
| closed system | Ab1(b) | a needle class with cells of equal mass, for (1 − a)·L/(2σ) an integer: silent failure σ with abort probability a needs n ≥ (1 − a)²·L/(4σ) − L |

Proof: `proofs/shift-abstain.md`, Theorem 7.3. *What it does not say.* The last row is one closed system. Where the inputs that the questions missed are rare and recognisable, abstaining on them saves a factor of order a/σ in questions (Example 4.5a).

**Rocks and whitelists.** In the table the rules are frozen and sep stands for sep(x; A). For programs of total functions, every rule that is never silently wrong for all hypotheses within r bits of the best explanation of the data refuses every x with sep(x; A) ≤ r − c (Proposition 7.5). This forces the second column of rows 1, 2 and 4 (in row 2 with b − K_D for r); in rows 3 and 5 it is a property of the rule.

| rule | refuses at least | refuses at most | sound when |
|---|---|---|---|
| never silently wrong for all programs | all unasked inputs | | always |
| enumeration, budget b | sep ≤ b − K_D − c | sep ≤ 2b + c | b ≥ K |
| Thr_η, η = 2^(−r) | sep < r − c | unknown | posterior weight of f above η |
| Min, ratio set, α = 2^(−r) | sep ≤ r − c | sep ≤ K + K_D + r + c | f within r bits of the best explanation |
| Nov_r | sep < r | sep < r | r > 2K + c, or the shortest consistent program is right elsewhere |
| mixture | nothing | nothing | not guaranteed off A |

*Rocks.* With a parameter that makes soundness a theorem for all data (η < 2^(−K), α ≤ 2^(−K), r > 2K + c), rows 3 to 5 refuse every unasked input simpler than about K. One expects K for a person to exceed the complexity of every input ever written (this depends on the reference machine); then they are the rocks the researcher rejects, like row 1. Enumeration is sound once b ≥ K; its forced radius b − K_D shrinks as the data single out the human. *Whitelists.* With a moderate r the same rules refuse what a test of about r bits separates from A, and rows 4 and 5 nothing beyond the third column: the whitelists he accepts. Soundness is then the assumption in the last column, and its failure is silent. The exception is Thr_η on the system it rehearsed: there Ab1(b) bounds its wrong answers per run by L·K/(n·r) in expectation, without that assumption, and its abort probability by L·K ln 2·2^r/n. If the calls of a decomposition share a property of fewer than r − c bits that no asked input has, rows 1 and 3 to 5 refuse them all, and row 2 does if b − K_D ≥ r; the mixture errs at each with probability at least 2^(−r−c). For the class of all programs rows 2 to 6 are not computable.

**Between the rock and the bet: batches.** The rules above are never silently wrong, or they count their silent errors on asked inputs only. If the inputs to be answered are known as a batch before any of them is answered, a small *rate* of silent errors can be bought at a price that is linear in a bound on K.

**Proposition Ab5** (the algorithm and its guarantee are those of Goldwasser, Kalai, Kalai and Montasser 2020, who treat classes of finite VC dimension with two answers; proved here for a countable class with any answers). Let the human be a function of weight at least 2^(−b), for a known b. Put n questions drawn independently from a law P. Let V be the set of functions of weight at least 2^(−b) that fit the answers, and h the heaviest of them. Given a batch z_1, …, z_m and ε ∈ (0, 1], the rule Bat_ε repeats one step: while some member c of V differs from h at more than ε·m batch inputs that are not yet refused, it refuses every batch input at which c and h differ. Then it answers h at the others.

(a) *Sound up to ε.* On every batch, chosen in any way after the questions, at most ε·m answers are wrong. This holds with certainty.

(b) *Few refusals where the questions came from.* Let γ := (2b ln 2 + ln(1/δ))/n. With probability at least 1 − δ over the questions, for every batch the refused inputs lie in a set of P-mass below γ/ε. If then the batch consists of m further draws from P, ε ≥ 7.4·γ and ε·m ≥ b ln 2 + ln(1/δ), nothing is refused, with probability at least 1 − δ over the batch.

(c) *A test of whether the human is needed again.* If the rule refuses nothing, the whole batch is answered with at most ε·m errors, and no question about the batch was put. If it refuses, the human can instead answer (b ln 2 + ln(1/δ))/ε inputs of the batch, drawn uniformly and independently; with probability at least 1 − δ every function of weight at least 2^(−b) that fits all the answers is then wrong at no more than ε·m inputs of the batch.

*Proof.* (a) When the rule stops, no member of V differs from h at more than ε·m of the inputs that it answers, and the human is a member of V. (b) Each step refuses more than ε·m inputs, so there are fewer than 1/ε steps. Two functions that differ on a set of P-mass above γ both fit n independent questions with probability below 2^(−2b)·δ, and there are fewer than 2^(2b) pairs; so each step refuses a set of mass at most γ. The second claim and (c): `proofs/shift-abstain.md`, Theorem 7.6. ∎

So n = (2b ln 2 + ln(1/δ))/(ε·ε′) questions buy a rule that is silently wrong on at most a fraction ε of any batch and refuses a set of mass below ε′ under the law of its questions. It is a whitelist whose soundness, up to the rate ε, is a theorem, at a price linear in b; enumeration needs up to 2^b − 1 answered abstentions (N7(b)), and the frozen minimum rule a rehearsal of the order of 2^K rounds (Ab2(d)). With ε·m < 1 the rule is enumeration: never wrong, and a rock. *What it does not say.* (i) ε is a fraction of the batch and not a bound for a run: a batch that is one run with related calls can be refused entirely, and the ε·m wrong answers may all lie in the same runs. (ii) Off the law P the rule may refuse everything. (iii) The batch must be known before any of it is answered. The calls of fresh runs are such a batch if the scaffold's questions do not depend on the answers; the questions of a rehearsal are then independent draws from one law, and (b) applies to them. For questions that depend on the answers there is only a form by stages (Theorem 7.6, item 5), and the obvious rule for inputs that arrive one at a time is led to refuse everything (Example 7.9 there). (iv) The human must be a function, and a bound b ≥ K must be known; if K > b the errors are silent. (v) For a person the price is as far out of reach as that of R1.

### 7.5 A human who is not deterministic

Dominance (Ab2(a)) holds as stated. If the human has everywhere a preferred answer of probability at least 1 − ε₀ > 1 − η, then in expectation Thr_η gives another answer in at most K ln 2/kl(1 − ε₀ ‖ η) asked rounds and abstains in at most K ln 2/kl(ε₀ ‖ η), kl(a ‖ b) being the divergence in nats between coins of bias a and b (Proposition 4.7); it then imitates that answer, not the distribution. Where every answer has probability below 1 − η it abstains once the mixture is close to the human. No rule has both counts of Ab1(a) for all samplers: with a fair coin of weight 1/2 and the 2^N functions on N inputs, of weight 2^(−N−1) each, at most (N + 1)/4 expected silent errors against every function force at least (N − 1)/2 expected abstentions against the coin, which costs one bit (Proposition 4.8).
