<!-- BLOCK A: caveats on A1 to A3. It goes into Section 1 of the note, at the placeholder after "Closed deployment". -->

**Caveats on the assumptions.** Numbers refer to `proofs/assumptions.md`.

*A1.* The protocol's data cannot show that A1 fails. If the human answers the second call of a run from memory of the first, single calls put in separate sittings are answered as by a human without memory; every theorem holds for the system of such humans, which can be at total variation 1/2 from the real one (Example 1.1). If the human is reset between *episodes* and remembers inside them, R1, R3 and V1(a) hold for a deterministic human with whole episodes as the unit asked (E1, Section 9). One person who answers n questions remembers them; A1 for the rehearsal then needs a fresh person per question, and what is imitated is a pool (Remark 1.1a). A human who answers differently because no run depends on the answer is imitated as such (Proposition 1.15).

*A2.* Without it R1 is an oracle inequality (standard; Barron and Cover 1991): for every ν in H the bound is L·ln(1/w(ν))/n plus the divergence of ν from the human, summed along the *mixtures'* runs, not the human system's, and averaged over the rounds (Theorem 2.1). In a class of two hypotheses, one of which has exactly the human system's runs, that one is refuted with probability 0.44, at an input that only wrong answers reach, and the imitator then fails half the time for ever (Example 2.3).

*A3.* If the asked call is computed from the run with a seed of ℓ bits, a hypothesis that holds the seed is never refuted, and the deployed run has at least (L−1)/(2^ℓ+1) unfaithful calls in expectation for every n, in a class with K = 1 (Example 3.3). Rehearsal runs taken from a generator leave a like floor (Example 3.3a). A prior that has seen the rehearsal data memorises them (Example 3.6).

<!-- BLOCK B: Section 9 of the note. -->

## 9. What remains a bet

Numbers refer to `proofs/assumptions.md`. A closed deployment and A1 to A3 are assumed unless stated otherwise.

### 9.1 The budget

For an excess failure δ with a fraction θ of the calls replaceable, R3 needs n = K ln 2/(θδ) answers for a deterministic human and K ln 2/(2θ²δ²) otherwise. For the former and θ = δ = 0.1:

| human time | n | K paid for |
|---|---|---|
| a working life of 10⁵ hours, an hour per answer | 10⁵ | 1443 bits |
| 50 years, a year per answer | 50 | 0.72 bits |
| 10⁶ people for 2000 hours, an hour per answer | 2·10⁹ | 2.9·10⁷ bits |

K for a person is unknown; Landauer's estimate of the learned content of memory, about 10⁹ bits (1986; from secondary sources), suggests its order under a prior that knows nothing of the individual. At K = 10⁹ and an hour per answer the count is 3.5·10⁷ working years. With a year per answer, which the researcher thinks research may need, every bound here is empty: a certificate alone takes 300 years. More people help little: the last row imitates a pool, and the bound credits sequential batches, not answers, unless questions do not depend on answers (Propositions 6.3, 6.5).

**Theorem N8 (the factor K under low stakes; proved here).** Let δ < 1/10 and N := g/(2δ) an integer. The inputs are d blocks of N cells, each cell in 2k+1 copies; the class is the 2^K functions that are 1 on one cell per block, K = d·log₂N. The scaffold draws a block and g of its cells, asks every copy (L = g·(2k+1) calls) and outputs 1 if most copies of some cell answered 1. Every member's human system tolerates k faults with failure 0. Yet failure at most δ for every member needs, in expectation over a uniform member,

  n ≥ (1−10δ)·K·g/(8δ·log₂(g/(2δ))),

while 2g·K ln 2/δ + 1 questions suffice (R3).

*Idea.* The blocks are d separate searches, as in N2b; copies add calls, not information. Proof: Theorem 6.1. The count depends on L and k only through g, the number of independent critical units: "whatever L" in R3 does not amplify such work. For additive work (L calls at uniform inputs, any k errors harmless) every protocol needs (1−2k/L−2δ)·K answers on the class of all functions on K inputs (Proposition 6.4). *What this does not say:* both are worst cases over one family; whether additive work ever needs the factor 1/(θδ) is open.

### 9.2 Rare situations, and isolation

Inputs that runs meet with probability far below 1/n are probably never asked; there the imitator does what the prior says, and R1 holds for two priors that disagree (Proposition 7.1). Averaged over the prior, a posterior draw per run is exact with no question asked (Proposition 7.7; standard, Thompson 1933): the theorems are about a human who is not typical of the prior, and a rare situation is a bet on the prior. A universal prior keeps a doubt of at least 2^(−sep−c) at each new kind of input (Section 4.1). The patch-free prior of `ultranatural/note.md`, restricted to *isolated* hypotheses, removes it:

**Theorem I1 (proved here; Theorem 9 of that note, with runs for samples).** Let H consist of functions, D(g, g′) be the probability that g and g′ give different runs, and the human f be δ-*separated*: D(f, g) is 0 or at least δ for every member g. Rehearse as in Section 2, but with one posterior draw answering each run. After n rounds the expected posterior weight of the members whose runs differ from the human's is at most 2^K·(1−δ/(2L))^n.

Proof: Theorem 7.4. The *isolated* members (heavier than every member within distance δ) are separated from one another. *The price* (Proposition 7.5): a human who is an isolated member patched where runs go with probability ε is imitated wrongly with probability at least ε per run for every n; the posterior shows no doubt until a question lands on the patch. *What it does not say:* that a person is separated. Separation depends on the reference machine, and no data decide between the two bets.

### 9.3 Memory, and a human who changes

**Theorem E1 (proved here).** Let the human be reset between episodes, each answer being a function of the messages and answers of its own episode so far. In each rehearsal round the human carries out one uniformly chosen episode of the run, and the mixture conditions on the earlier answers of the current episode. With L_e the largest number of episodes of a run and K the weight of that function, the deployed run has at most L_e·K ln 2/n unfaithful episodes in expectation, and R3 and V1(a) hold with episodes for calls. Proof: Theorems 1.7, 1.8. *What it does not say:* n counts human episodes, however long, and single messages shown to a fresh reader do not replace them (Example 1.10). For a human who is not deterministic only weaker forms hold (Theorem 1.9).

**Theorem E2 (proved here from the standard regret bound).** Let the human P_t of round t depend on the past in any way. For every ν in H,

  E[Σ_x KL(P_T‖M^(T))(x)] ≤ L·ln(1/w(ν))/n + (1/n)·Σ_t E[Σ_x KL(P_t‖ν)(x)],

the sums over x running over the calls of the runs of rounds T and t. Proof: Theorem 1.11. *What it does not say:* anything about the human after the last question (Proposition 1.14); and under steady drift the last term grows with n, so that longer rehearsal can be worse (Corollary 1.12).

### 9.4 Copy or predictor

The data fix the human's kernel on the inputs that the scaffold can produce, and nothing else (Proposition 7.8). Under A1 no predictor, however it models the world, gains on the human in expected log-likelihood (Proposition 7.9; standard, Ville 1939): a better predictor is assumed away, not excluded. A sampler and the same sampler with coins fixed in advance differ only on questions put twice (Proposition 7.10). The deployed object is a committee, redrawn at every call, episode or run; nothing makes it resemble the human inside.

### 9.5 The objections

Section 8 of the proof file classes twenty-two objections to "rehearsal is a human-imitation protocol that works as far as any protocol can". Seven are fatal to part of it:

* *K* (9.1): to "works from a reasonable number of answers", for a person;
* *critical steps:* for some scaffolds and classes no protocol amplifies work whose single steps decide the result, replicated or not (N2, N8);
* *long episodes:* on the researcher's numbers, unless scaffolds of short calls do research;
* *not a person:* one computation fixed in advance is imitated; fatal to "upload";
* *silent failures:* to "fails only obviously" at an affordable price without a further assumption (Section 7);
* *the human reads what the prior wrote:* to a class of all programs with a large scaffold and a reader who must not be harmed;
* *the human is a sampler:* no certificate free of K then bounds the unfaithful calls (V1).

The others are answerable at a price (a pool of people; a late random round; physical coins) or lie outside the theorems: whether the human system does anything, and whether it tolerates faults, which R3 assumes and the protocol never tests.

*What survives.* For a computation that we can run in advance, a human without memory who is one of the weighted candidates, and fresh coins throughout: n answers to single calls of the imitator's own runs give, for the mixture of a uniformly random round, at most L·K ln 2/n unfaithful calls per run in expectation if the human is deterministic, and L·√(K ln 2/(2n)) otherwise. For some scaffolds and classes of 2^K candidates every protocol needs a constant times K·L/(δ·log₂(L/δ)) answers. An imitator of a deterministic human can be certified at a cost without K. Nothing is offered outside that computation, at rates below about 1/n, or for a human other than the one who answered.

<!-- BLOCK C: Section 10 of the note. -->

## 10. The seven tests

The tests are those that the researcher's notes apply to any proposal. Verdicts are for the protocol of Section 2 in a closed deployment. Details: `proofs/assumptions.md`, Section 5.

| test | verdict |
|---|---|
| 1 guard | passed for each property fixed in advance; for all at once only at the price K |
| 2 machine | the rates are the scheme's; K, rare inputs and every route to a small K are the machine's |
| 3 referent | passed under A3, as far as R1 is not empty |
| 4 copy | not passed |
| 5 budget | not passed |
| 6 rock | not a rock; its failures are silent |
| 7 horizon | outside the theorems |

**1. Guard.** *What does the scheme do at an input with a property that no training input has, such as task decomposition creates?* For each property fixed in advance, the probability that the deployed run meets it although no question had it is at most L/n (R7); N properties cost the factor N. Decomposition creates none, since rehearsal runs go to full depth. The statement is false for all properties at once, and for a property chosen with the data in view; these are covered only by R1, at the price K. At an input of a new kind the answer is the prior's (N1). A last mixture kept for good is not covered in general.

**2. Machine.** *Is that a fact about the scheme, or about the reference machine?* The rate 1/n and R7 mention no machine; nor does the certificate V1(a), which can be issued for a deterministic human only. The constant K is the machine's. So is the behaviour at inputs met less than about once in n runs: on some machine a deviant answer there has probability at least one half (Paper 1, Proposition 8.2), and R1 holds for both machines. So is every route to a small K: a prior built from knowledge, or isolation (I1).

**3. Referent.** *Does a hypothesis that models how the data set was made do as well as the intended one?* Under the five parts of A3 the asked call is an unbiased sample of a fresh run. So such a hypothesis loses weight at the rate at which it deviates on the mixtures' runs, and a prior fixed first gives the hypothesis that knows the realised coins at most the probability of guessing them (Theorem 3.2). That weight must be set against the human's 2^(−K): tables of the data outweigh the human until the questions carry more than K bits, and until then the imitator answers unasked inputs as the tables do (Remark 3.2a). So the test is passed exactly as far as R1 is not empty.

**4. Copy.** *Does anything distinguish the sampler from a better predictor of it, or from the sampler with coins filled in?* No (Section 9.4). The deployed object is the Bayes predictor of the human.

**5. Budget.** *How many answers, of what length, on which questions?* Of the order of K/(θδ) single calls on the imitator's own runs, those of the early rounds being the prior's. K is forced in the worst case (N2b, N8) and for a person is out of reach at any length of answer (Section 9.1). Cheap is only the check of a given imitator of a deterministic human: 300 short answers at θ = δ = 0.1 and confidence 0.95. For a human who varies no such certificate exists, and a certificate does not produce an imitator.

**6. Rock.** *Does the scheme still act on the inputs that matter?* It acts everywhere in the closed system; its unfaithful calls are unmarked and must be taken as an adversary's. The theory has the opposite corner too: the minimum rule (Ab2) fails only visibly on any input, and where it is sound without an assumption it refuses every input of a new simple kind; with a moderate plausible set it is a whitelist whose soundness the data cannot confirm. Nothing here acts on new inputs, fails only visibly and needs no assumption.

**7. Horizon.** *Granting perfect per-call imitation, does the scaffold do anything?* No theorem about the learner can say. Three points weigh against. R3 needs a human system that survives arbitrarily replaced answers, which the protocol never tests. Where that tolerance comes from replication it buys no amplification (N8). And the budget is met only by short calls, while the researcher expects that an episode able to do research may take a year.

<!-- END OF THE SECTION TEXT. Everything below is for the lead and for the reference list. It is not part of the note. -->

---

## Notes for the lead (not part of the note's text)

**Where the three blocks go.** The blocks are marked by the comments "BLOCK A", "BLOCK B", "BLOCK C" and "END", which `research/orchestration/assemble.py` looks for. Block A replaces the placeholder "[PLACEHOLDER: caveats on A1 to A3, supplied by part `assumptions`.]" at the end of Section 1 in `research/sections/rehearsal-core.md`. Blocks B and C are Sections 9 and 10. The lead's draft `note.md` has no text for Sections 9 and 10; what it has on this part is the sentences on A1, A3 and closed systems in its Section 1, which the part rehearsal-core has already revised with this part's material (A3 in five parts, the three conditions of a closed deployment). Block A adds to that revision and repeats nothing of it.

**Length.** Words of two or more letters, counted by a script: caveats 260 (limit 300), Section 9 1098 (limit 1100), Section 10 653 (limit 800). Counted as whitespace-separated tokens (`wc -w`, with every formula fragment, number, table bar and bullet as a token): 305, 1345, 766. So Section 9 meets the limit in words and not in tokens. If tokens are what counts, cut first: the table of 9.1 (57 tokens; its three numbers can go into one sentence), then Section 9.4 (87 tokens; test 4 of Section 10 could carry its three pointers), then the sentence on additive work in 9.1 (29 tokens).

**Labels.** N8 (Theorem 6.1 of `proofs/assumptions.md`), I1 (Theorem 7.4, price: Proposition 7.5), E1 (Theorems 1.7 and 1.8), E2 (Theorem 1.11), as the outline's Addendum 3 assigns them. No other label is introduced. R7 is cited, not restated. Statements without a label are cited by their number in the proof file.

**Letters.** k tolerated faults, θ the tolerated fraction, δ failure probability, as the outline fixes them. In N8: d blocks (as in N2b), g cells drawn (as g regions in N5), N cells per block. In the caveat on A3 the seed has ℓ bits (the proof file writes k there; k is taken). L_e is the largest number of episodes of a run; ε in "the price" of I1 is the probability that a run meets the patch; κ does not appear. The proof file writes m for the tolerated faults, m_b for the blocks and B for the cells drawn; its header says so.

**What changed relative to the lead's draft and the candidate theory.**
1. A1 (draft, Section 1: "One question may also stand for a long episode of work; nothing below depends on its length"): true only if the episode is one call. E1 is what holds for episodes with several exchanges; single messages cannot be rehearsed in its place (Example 1.10). New: A1 is also an assumption about the n questions of rehearsal, which one person violates (Remark 1.1a).
2. A3: the candidate's "not computable by any hypothesis" is the right reason once made exact as parts (i) and (v). The prover's file had argued otherwise; the check report corrected it.
3. Candidate, Section 10 (the seven tests): it overclaims on tests 1, 4, 5 and 6, and its sentence on test 3 needs the condition "as far as R1 is not empty". The verdict "passed by the certificate" on tests 2 and 5, which the prover's file added, is withdrawn for a human who is not deterministic.
4. Candidate, Section 13: V1 is confirmed in validity and restricted in use (it can be issued only for a nearly deterministic human). V2 ("low stakes is the only exception") needs three qualifications: the law is for classes closed under patches (I1 is the case without closure); tolerance by replication is not an exception per critical unit (N8); the guarantee averaged over the prior is another exception and is free (Proposition 7.7). V3 ("wrong there with probability about 2^(−sep)", "exact if the human is isolated") becomes: at least 2^(−sep−c), machine-relative; and I1 with its rate and its price.
5. Candidate, Section 9 ("R4 and R6 give a single coherent program"; the appeal to E5 of the record): overclaims, see test 4 in the proof file; the note's Section 5.1 has the correct statements.
6. Candidate, Section 0, item 3 ("about K/(θδ) questions suffice, whatever L"): true, and not an amplification of replicated work (N8).

**Who checked what.** `proofs/assumptions.md`, Section 12. In short: no numbered statement of the prover was found wrong by either report; both reports found the readings, the verdicts, the classes and the closing claim too strong, and all of that is corrected. N8, I1, E1, E2, Examples 1.1, 1.10, 2.3, 3.3, 3.6 and Propositions 7.1, 7.5, 7.7 to 7.10 were verified by both reports. Proposition 6.4 (additive work), Example 3.3a (the generator) and Remark 3.2a (tables against the human) come from the reports; each was re-derived or recomputed by the editor and seen by one verifier only. The verdicts of Section 10 and the classes of Section 9.5 are the editor's merge of the two reports' tables; no verifier has re-read the merge. Nothing in the section text is marked "not independently checked", because nothing in it rests on a statement that no verifier checked and the editor did not re-derive. One statement of the proof file has no verifier (Remark 6.6, a chain needs as many batches as it has links); the section text does not use it.

**Cross-references assumed.** Section 1 (A3 in five parts; the closed deployment); Section 2 (the protocol; T); Section 3 (R1, R3, R7, V1(a) and its "What it does not say"); Section 4 (N1 with the sentence on the floor in 4.1, N2, N2b; the definitions of "protocol" and "fails", which N8 uses); Section 7 (Ab2, for "the minimum rule").

**For other sections.**
1. Section 3.5 (V1): the sentence "The certificate does not contain K: 300 rounds certify an excess failure 0.1 under θ = 0.1 at δ = 0.05" agrees with 9.1 and test 5 here; both say that it is for a human who is nearly deterministic.
2. Section 3.1, the bullet "The round": the attack report on this part shows that the uniformly random round can be the dominant cost (in an additive example 31 356 answers against 790 for a round drawn from the second half, which costs a factor 2 in every bound). `proofs/rehearsal-core.md`, Proposition 5.2, Remark (ii), has the factor 2; the section text of that part does not mention the late round. Section 9.5 here mentions it in three words.
3. Section 4.4 (N5) points to N8 for the factor K: N8 is stated here for the block-majority scaffold (all 2k + 1 copies asked), with g·(2k + 1) calls; the factor between its upper and lower bound is 16 ln 2·log₂(g/(2δ))/(1 − 10δ), and with targeted questions the order is K·g/(δ·log₂(g/δ)) (Remark 6.2a).
4. Section 0 should not say "optimal up to the factor K" or "works exactly as far as any protocol can"; the wording that both reports accept is the paragraph "What survives" of 9.5.
5. The related-work section may want the attributions collected in `proofs/assumptions.md`, Section 11, "What is standard" (label-efficient prediction for the online form; delayed feedback for batches; the index of resolvability for the oracle inequality; cut and paste for episodes).
6. `research/sections/intro.md`, item 7, cites "Section 4, N8": N8 is stated in Section 9.1 (the assembly could move it, or the citation could read "N2b and N8").
7. `research/sections/open.md`, item 10, says that for nested episodes the whole-run bound "carries an extra factor, the largest number of episodes open at once". What is proved is the factor min(4·m_e, L_e/2), where m_e is the largest number of calls of one episode and L_e the largest number of episodes of a run; for two episodes there is no extra factor; whether an absolute constant holds for many interleaved episodes is open (`proofs/assumptions.md`, Theorem 1.9, Proposition 1.9a, Section 10.1, item 1). Item 4 of the same file ("under low stakes with bounded damage the only lower bound that contains K is n ≥ (1 − 2θ − 2δ)·K") is Proposition 6.4 here: it is for additive work on the class of all functions on K inputs.

**Left out for length; all in the proof file.** The guard statement for all properties of at most k bits at once (Corollary 3.2′) and its failure for the last mixture by a factor 0.4·√L (Example 3.2b); the exact price of rehearsal under A2 (Theorem 2.1(b)) and the floor for classes of functions (Remark 2.1a); K_Π (Proposition 2.2; the note has it in Section 1); the factor min(4m_e, L_e/2) for interleaved episodes (Proposition 1.9a); the drift bound with its optimal n (Corollary 1.12); the examples of a real task outside D₀ and of a date in the inputs (Examples 3.4, 3.5); exchangeable stocks of tasks (Proposition 4.2); the list of what the theory offers outside a closed deployment (Proposition 4.4); the budget tables in full, with both conventions for a year, and the break-even numbers (Section 6.2); the fifteen objections that are not fatal (Section 8); the eleven open questions (Section 10.1).

## Sources cited in the section text, with how each was read

* **T. K. Landauer (1986).** "How Much Do People Remember? Some Estimates of the Quantity of Learned Information in Long-term Memory." *Cognitive Science* 10(4):477–493. Used for one number: estimates of the learned content of long-term memory "around 10⁹ bits". Bibliographic data (dblp) and the figure were seen in web search results by the prover, by both verifiers and by the editor; nobody in this project read the paper. The proof file also names T. M. Bartol et al., *eLife* 4:e10778 (2015), 4.7 bits per synapse; the section text does not use it.
* **`ultranatural/note.md`** (this repository), Section 5: Proposition 8 and Theorem 9 ("Let f be δ-isolated and let D_n consist of n independent μ-samples labelled by f. … The expected patch-free posterior mass off f is at most 2^(K(f))·(1−δ)ⁿ") and the remarks after it. Read in the file by the prover, both verifiers and the editor.
* **Paper 1 of this repository, Proposition 8.2** (test 2): for every decidable Q and partial computable b there is a universal machine at distance K(Q, b) + c under which the deviant behaviour on Q has posterior probability at least 1/2. Quoted from the digest `research/understand/repo.md`, item D2; the paper was not opened by the prover, the verifiers or the editor.
* **A. R. Barron and T. M. Cover (1991).** "Minimum complexity density estimation." *IEEE Transactions on Information Theory* 37(4):1034–1054. The index of resolvability, min over members of complexity/n plus divergence; named by the attack report, which saw the definition quoted in a search result. Not opened by anyone in this project. The inequality itself is proved in the proof file (Lemma 0.1, Theorem 2.1).
* **W. R. Thompson (1933).** "On the likelihood that one unknown probability exceeds another in view of the evidence of two samples." *Biometrika* 25:285–294. Cited for posterior sampling, whose defining property is Proposition 7.7. Named by the attack report from memory; title and pages from the editor's memory; not opened. The proposition is proved in the proof file in two lines.
* **J. Ville (1939).** *Étude critique de la notion de collectif.* Gauthier-Villars. Ville's inequality for nonnegative supermartingales, used in Proposition 7.9; from memory; standard. In this repository the same statement is Remark H.1 of Paper 2 (digest item F1; not opened).
* Statements of other parts (R1, R3, R7, V1, N1, N2, N2b, Ab2) are cited by label; their sources are in those parts.
