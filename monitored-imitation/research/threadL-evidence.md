# Thread L: empirical evidence on bounded setback

*Literature review for the monitored-imitation project (Claude, 21 November 2026). Draft, not refereed. It reads [`../slack-imitation.md`](../slack-imitation.md) §§3–4 and [`threadE-redteam.md`](threadE-redteam.md), and asks what published evidence says about (B-omit), (B-commit) and D.*

**Sources and how far each was checked.** Web search worked. Fetching full pages worked only for arXiv: uwaterloo.ca, gwern.net and core.ac.uk are blocked by this session's network rules, so Dunbar's primary papers and the full texts of Sleesman et al. and Roth et al. were not read. Tags:
* **[checked]**: confirmed in an abstract, publisher, PMC or arXiv page, or the author's own summary, found by search. Not a full-text reading.
* **[secondary]**: confirmed only in a secondary account (news, a citing paper, a review).
* **[memory]**: from my own knowledge, not checked this session.

## Answers in brief

1. **Error detection is poor and slow.**
   * *Review:* experts asked to review find about 30% of the major errors planted in a manuscript (2.6 of 9), 50–63% of those seeded in spreadsheets, and 25–60% of code defects without tools.
   * *Use:* errors that are found by use rather than by review survive for years: Linux faults 1.8–3 years, retractions 33 months, a column flip in a lab's own software 5 years.
   * *So:* a plausible wrong entry is caught within six months well under 95% of the time, unless it is machine-checked or fails loudly when used.
2. **Recorded dead ends are rarely revisited, and many are wrong.**
   * 65% of null results are never written up. Only 16% of failed drug candidates are retried at all, and under 2% are launched in another therapeutic area. A decade of failed reactions sat in one lab's notebooks until a model mined them.
   * About two thirds of psychology papers with nonsignificant results contain at least one false negative.
   * The best-documented return to one's own dead end (Wiles and Iwasawa theory) took three years and a crisis: D ≈ 12 steps, not ≤ 2.
3. **Sunk cost is a weaker threat to a lone researcher than thread E assumed.**
   * It is robust in hypothetical vignettes, but absent or reversed in incentivized tasks, and Staw (1976) failed a recent replication.
   * Escalation in the field is real but organizational: 30–40% of IT projects escalate, firms with a single product push weak drugs forward, and famous cases last 10–14 years.
4. **Einstellung is robust in experts, and "look for alternatives" helps only partly.**
   * A familiar solution cut chess experts' performance to that of players about 3 SD weaker; the effect shrinks at the highest skill.
   * Luchins's warning "Don't be blind" freed only about half his participants. Experts who say they are searching for a better move keep looking at the familiar one.
   * It does not occur when the familiar option is a blunder. So it threatens valid but weaker entries (V4), not flagrant errors.
5. **By-product insights are a real minority, and the record is a lossy trigger.**
   * Serendipity figures in 8% of citation classics, 6% of marketed drugs (2% from laboratory incidents), and the careers of 17% of surveyed researchers.
   * Doing beats reading for learning: d ≈ 0.40 (generation effect), g ≈ 0.36 (productive failure), and experts gain least from worked examples.
   * Readers with a hypothesis miss planted anomalies: 5× fewer find a "gorilla" in a data set, and 83% of radiologists miss one in a CT scan.
6. **Experts are noisy, not deterministic.**
   * Categorical forensic decisions repeat about 90% of the time after seven months. Repeated effort estimates by the same person differ by up to 71% on average. About 10% of wine judges replicate their own medal.
   * A three-month research step will not repeat exactly, so setbacks are random, and the average-setback reading (Remark 5) is the right one.
7. **Deadlines shape work, and durations are heavy-tailed.**
   * Teams change course at the calendar midpoint, whatever the time allotted. Plans run about 60% over. IT overruns follow a power law. 57% of US PhD entrants finish within ten years, and 25% of trials are discontinued.
   * A hidden clock removes the midpoint transition and the pressure to consolidate. Heavy tails leave a failure floor Pr[τ(x₀) > n] that no theorem charges.
8. **People accept altered records of their own choices.**
   * Acceptance: 75–90% of swapped face choices go unnoticed; 69% accept a reversed moral answer, 92% an altered political answer, and 57–63% inflated symptom ratings.
   * Propagation: their later answers then move toward the planted ones. Corrections do not fully undo misinformation, and 86–96% of post-retraction citations ignore the retraction.
   * *So:* a researcher handed "its own" notebook with a plausible planted entry will usually not notice it by reading. What catches it is use.
9. **Overall direction.**
   * The evidence pushes (B-commit) with D ≤ 2 down in every field, and (B-omit) down for empirical work.
   * Setbacks look bimodal: caught at review or first use (D ≈ 0–1), or only after a later failure or crisis (D ≈ 4–12) or never.
   * So the claim that matters is the fraction never recovered within the project, as the note already says, not D ≤ 2.
10. **My probabilities** (§10):
    * (B-omit): 65% for theory, 40% for empirical work.
    * (B-commit) with D ≤ 2, without / with ask-before-committing: 30% / 50% for mathematics, 35% / 55% for software, 10% / 25% for empirical or judgment work.
    * Gain over chained imitation: ≥ 2× 60%, ≥ 5× 35%.
    * The verifier version is unaffected: correctness never depended on any of this.
11. **The studies that would settle most** (§11):
    * planted entries in researchers' own notebooks, presented as their own;
    * reading the record against doing the work, for by-product insights;
    * planted dead ends in problems with a known solution.

## 0. How the evidence maps onto (B_D)

A wrong entry that the human builds on costs its setback in one of three regimes:
* **(A) caught at review or first use:** D ≈ 0–1. Detection-rate studies (§1, §4) measure this.
* **(B) caught later, by a failure or a crisis:** D is the time to that event. Persistence studies (§1, §2) measure this.
* **(C) never caught within the project:** D = ∞. Studies of trust, dead ends and by-products (§2, §5, §8) bear on this.

The note's graded claim needs (B_D) to fail at no more than about 5% of confident mistakes of a kind. For commissions:

  Pr[load-bearing] × Pr[not caught within D | load-bearing] ≤ 0.05.

Most of the evidence below concerns the second factor. Little bears on the first: what share of confident commissions are load-bearing, rather than harmless paraphrases or valid alternatives.

## 1. Error detection and persistence

**Key findings.**
* *Peer review with planted errors.*
  * Schroter et al. (2008): 607 BMJ reviewers, three papers each with 9 major and 5 minor planted errors. They found on average 2.58, 2.71 and 3.0 of the 9 major errors (29–33%). Training helped only slightly. **[checked]**
  * Baxt et al. (1998): a fictitious trial with 10 major and 13 minor errors, 203 reviews. Reviewers who recommended rejection found 39% of the major errors; those who recommended acceptance, 17%. About two thirds of major errors were missed. **[checked]**
* *Spreadsheets.*
  * Panko's summaries of seeded-error experiments: individuals find 50–63% of errors (63% over 8 experiments and 982 participants), groups 83%. Detection approaches 90% only for mechanical errors in short formulas; logic and omission errors are found far less often. **[checked]**
  * Galletta et al. (1993): 56% of seeded errors found **[secondary]**, with experts no better than novices **[memory]**.
* *Code.*
  * Capers Jones (industry data, defect removal efficiency): desk checking 25–55% (average 45%), informal peer review 35–60%, formal inspection 60–96% (average 85%). **[checked]**
  * Braz et al. (2021, ICSE): 146 developers reviewed code with an input-validation vulnerability. Many found it only after being warned, and 60 (41%) missed it even then. **[checked]**
  * Edmundson et al. (2013): 30 hired developers did security reviews; effectiveness was low, and experience did not predict it. **[secondary]**
* *Mathematics.*
  * Inglis, Mejía-Ramos, Weber and Alcock (2013): 109 research mathematicians disagreed on whether a short calculus proof was valid, and those who accepted it rarely changed their minds when shown objections. **[checked]**
  * Lamport's note on 84 Mathematical Reviews reviews by one algebraist: about one paper in three had an incorrect theorem or proof. A small sample from one field. **[checked]**
  * Kempe's four-colour "proof" stood for 11 years (1879–1890) **[memory]**. Kapranov and Voevodsky's 1991 theorem was refuted indirectly by Simpson in 1998, and Voevodsky was sure it was right until the fall of 2013. **[checked]**
* *Own work against others'.* Daneman and Stainton (1993): students proofreading their own fresh essays found about 20% fewer errors than readers of a familiar essay by someone else, and no fewer after two weeks. Burgoyne et al. (2022) found no self-generation effect. **[checked]**
* *Persistence.*
  * Linux: average fault lifespan 1.8–2.5 years in 1.0–2.4 (Chou et al. 2001) and 2.5–3.0 years in 2.6 (Palix et al. 2011/2014); faults with visible runtime effects about 1 year. **[checked]**
  * Zero-day vulnerabilities: 6.9 years on average (RAND, Ablon and Bogart 2017, about 200 cases). **[checked]**
  * Retractions: on average 33 months after publication (2,047 PubMed retractions; 24 months for papers after 2002; Steen, Casadevall and Fang 2013). **[checked]**
  * Chang's lab: a column flip in inherited in-house software inverted the structures in papers of 2001–2005. Another group's structure exposed it in 2006, and five papers were retracted. **[checked]** The Reinhart–Rogoff spreadsheet error lasted about 3 years. **[memory]**
* *Errors that pass review.*
  * Half of psychology papers that use significance tests contain a p-value inconsistent with its test statistic, and one in eight a grossly inconsistent one (Nuijten et al. 2016). **[checked]**
  * About one fifth of genomics papers with Excel gene lists contain corrupted gene names (Ziemann et al. 2016), and later scans find the rate has not fallen. **[checked]**

**Implications.**
* *(B-commit).*
  * *Review alone does not get to 95%.* One deliberate review pass catches 30–60% of planted errors; outside machine checks, no study shows a single pass near 95%.
  * *Several uses help less than independence suggests.* A verify-before-relying instruction gives the human several passes, one per use. Three independent passes at 50% would reach 88%. But passes share blind spots: Ulery et al. found that 30% of examiners' false negatives repeat (§6).
* *D.* Errors found by use rather than by review live for about 1–3 years in large shared artefacts, which is 4–12 steps. A project notebook is smaller and used more intensively, so it should be faster, but I found no data.
* *(B-omit).* Omissions are the hardest errors to detect by inspection (Panko). This agrees with thread E that confident omissions are invisible to a reader.
* **Direction:** down for (B-commit) with D ≤ 2 in every field. Least for software with machine-checked entries, where D ≈ 0 for executable claims as the note assumes.

## 2. Revisiting negative results

**Key findings.**
* *File drawer.* Franco, Malhotra and Simonovits (2014), 221 TESS survey experiments: about 60% of strong results were published but 20% of null results, and 65% of null results were never written up. The filter is the authors, not journals. **[checked]**
* *Failed drug candidates.* Neuberger, Oraiopoulos and Drakeman (*Drug Discovery Today*), 834 molecules that entered trials in 1980–2012: 16% were tried in another indication, 10% of initial failures in a different therapeutic area, and under 2% were ever launched outside their first area. Infliximab and etanercept, failures for sepsis that became blockbusters for rheumatoid arthritis, are the famous exceptions. **[secondary]**
* *Failures kept but unused.* Raccuglia et al. (2016, *Nature*): about 4,000 reactions from a decade of one lab's notebooks, mostly failures that had never been digitized ("dark reactions"). A model trained on them predicted successful conditions 89% of the time and beat the chemists' own strategies. **[checked]**
* *How scientists treat surprises* (Dunbar's in vivo studies of four molecular biology labs). Unexpected results are common (over half in one secondary account). They are first attributed to methodological error. Conceptual change comes when they recur and colleagues challenge the interpretation. **[secondary]**; the primary papers were blocked.
* *Recorded negatives are often wrong.*
  * About two thirds of psychology articles that report nonsignificant results show evidence of at least one false negative (Hartgerink, Wicherts and van Assen 2017). **[checked]**
  * Median power in neuroscience was about 21% (Button et al. 2013), though power varies widely between studies (Nord et al. 2017). **[checked]**
* *Returning to one's own dead end.*
  * Wiles dropped Iwasawa theory around 1991. In September 1994, examining the failing Kolyvagin–Flach method, he saw it was "all I needed to make my original Iwasawa theory work from three years earlier". **[checked]**
  * Lewis Thomas set aside the floppy ears of papain-injected rabbits for years before returning to them **[memory]**. Kellner saw the same effect and never pursued it (Barber and Fox 1958). **[checked]**
* *Others returning.* In 22 million papers, "sleeping beauties", ignored for years and then heavily cited, are "far from exceptional" (Ke et al. 2015). **[checked]**

**Implications.**
* *V2's mechanism is confirmed.* Dead ends are recorded but rarely revisited, by the same researcher or anyone else.
* *Recovery comes when the alternatives run out.* Wiles fits thread E's "a few steps if every alternative fails and A is retried", but the timescale is years, D ≈ 12 steps.
* *Where alternatives are few and exhaustible* (mathematics), slack σ = 20–40 can absorb such a setback under Remark 5. Where they are not (empirical work, judgment), it is ∞.
* *A twist.* In low-power fields the human's own recorded negatives are often false, and the reference chain already lives with that. The imitator's base-rate negative is an extra false negative at exactly the critical attempt. Nothing here suggests that humans treat it differently from their own.
* **Direction:** down for (B-commit) with D ≤ 2 in mathematics and empirical work. Mildly up for "slack absorbs large finite setbacks" in mathematics.

## 3. Sunk cost and escalation of commitment

**Key findings.**
* *Meta-analyses.*
  * Roth, Robbert and Straus (2015), 98 effect sizes from 1976–2013: the effect is present, its size depends on the type of decision, it weakens with time in utilization decisions, and it is strongest in students and the young. Economic education does not reduce it. **[checked]** I could not retrieve the pooled d.
  * Sleesman et al. (2012, *AMJ*): a meta-analysis of the determinants of escalation (project, psychological, social, structural). **[checked]** for scope; the pooled correlations were not retrieved.
* *Replications.*
  * Negrini, Riedl and Wibral (2020): the bias replicated in hypothetical scenarios. In an incentivized task there was a robust *reverse* effect: larger sunk investments made continuing less likely, and responsibility for the first investment did not matter. **[checked]**
  * Białek et al. (2021), N = 365: no escalation; participants invested more in the more promising projects. The FLoRA atlas lists Staw (1976) as having one failed and one mixed replication. **[checked]**
* *Field and managers.*
  * Keil, Mann and Rai (2000): 30–40% of information-systems projects show some escalation, and escalated projects perform worse. **[checked]**
  * Guedj and Scharfstein (2004), 235 cancer drug candidates: early-stage firms with one product advance more candidates to Phase II, and those candidates do worse, which the authors read as reluctance to abandon the only candidate. **[checked]**
  * Boulding, Morgan and Staelin (1997): senior executives stayed committed to failing launches, and no decision procedure tested removed the commitment entirely. **[checked]**
  * Schmidt and Calantone (2002): managers let a really new product proceed further despite worsening feedback. **[secondary]**
  * Royer (2003, *HBR*): an Essilor project ran about 10 years after the first warning signs; RCA's SelectaVision ran 1970–1984. **[secondary]**

**Implications.**
* *V3 is mostly organizational.* Its well-documented cases involve stakeholders, budgets and careers.
* *For a lone cold-start researcher* handed a plan it believes to be its own, the ingredients that should matter (personal responsibility, self-justification) are the ones that fail to replicate in incentivized tests.
* *What is missing* is any study of how long individual researchers persist on a wrong direction.
* *D for a direction* is a fraction of n₀, not ≤ 2 steps, as thread E said. What matters is that it is finite and well below σ. Stopping rules reduce persistence partly (Boulding et al.), which weakly supports content-triggered audits.
* **Direction:** slightly up on V3's frequency relative to thread E, which rated it common in every field. Down on D ≤ 2 for direction-level commissions.

## 4. Einstellung and anchoring in experts

**Key findings.**
* *Luchins (1942).* After practice problems solved by one formula, most participants used it on critical problems that had a simpler solution, and many failed the extinction problem. After the warning "Don't be blind", only a little over half switched to the simple solution. **[secondary]** That 70–80% of the experimental groups showed the effect is **[memory]**.
* *Bilalić, McLeod and Gobet (2008, Cognitive Psychology).* A familiar but non-optimal solution cut experts' performance to that of players about 3 SD weaker. The effect decreased with expertise: "inflexibility of experts is both reality and myth". **[checked]**
* *Bilalić, McLeod and Gobet (2008, Cognition).* Experts who reported looking for a better solution kept fixating on squares tied to the familiar one. **[checked]**
* *Sheridan and Reingold (2013).* An eye-movement replication: experts who found the optimum gradually disengaged from the familiar move. When the familiar move was a blunder, all the experts avoided it. **[checked]**
* *Design fixation.*
  * Jansson and Smith (1991): engineers copied flawed features from an example, and instructions to avoid them did not help. **[secondary]**
  * Chrysikou and Weisberg (2005): such instructions did reduce fixation. **[checked]**
  * Sio, Kotovsky and Cagan (2015), a meta-analysis of 43 studies: examples raise similarity to themselves and lower variety, but raise novelty. A single uncommon example helps most. **[checked]**
* *Anchoring in experts.*
  * Englich, Mussweiler and Strack (2006): judges' sentences followed a prosecution demand set by dice, and experience did not reduce the effect **[checked]**; about 5.3 against 7.8 months for anchors of 3 and 9 **[memory]**.
  * Mussweiler, Strack and Pfeiffer (2000): car experts were anchored like non-experts, and "considering the opposite" reduced anchoring. **[checked]** for the title claim; **[secondary]** for the experts.
  * Townson (2019), a meta-analysis: r ≈ .40, and expertise aggravated the effect. **[checked]**
  * Northcraft and Neale (1987): estate agents were anchored by list prices they denied using. **[memory]**

**Implications.**
* *V4 is supported.* A confident, valid but weaker entry anchors the later work. Generic "look for alternatives" instructions only partly help, because experts believe they are already looking.
* *An offset:* the very strongest experts are less affected, and careful researchers are the target population.
* *Blunders are rejected.* Einstellung concerns workable but inferior routes, so D is the weaker route's extra time, and ∞ only if S needs the better result. This supports the verify instruction against flagrant errors, not against V4.
* *Remedies that work are specific:* consider the opposite; one uncommon alternative. The scaffold analogue is an instruction, part of the reference chain, to state and test one alternative to each load-bearing approach.
* *Ask-before-committing does not remove it.* The commissions left after SI-ABC are confident plurality content, which is exactly what anchors.
* **Direction:** down for (B-commit) in mathematics and judgment work, with or without ask-before-committing.

## 5. Serendipity and by-product discoveries

**Key findings.**
* *Citation classics.* Campanario (1996): 17 of 205 commentaries (8.3%) report serendipity. **[checked]**
* *Drugs.* Hargrave-Thomas, Yu and Reynisson (2012): 84 of 1,437 marketed drugs (5.8%) were serendipitous, 31 (2.2%) after a laboratory incident and 53 (3.7%) in the clinic. A further 18% of drugs derive from serendipitous ones. For anticancer drugs the figure is 35% by one count; other coverage gives 15%. **[checked]**
* *Surveys.* Willems et al. (2022), as cited by Ross, Copeland and Firestein (2024): 17% of more than 3,000 researchers reported a serendipitous discovery. **[secondary]**, not checked.
* *Mechanisms.* Yaqub (2018) lists four: theory-led, observer-led, error-borne and network-emergent. The observer-led and error-borne kinds arise from doing. **[checked]**
* *Reports trigger insight too.* In Dunbar's labs, much reinterpretation of unexpected results happens at lab meetings, from colleagues who only heard the report; labs with more diverse members drew more distant analogies. **[secondary]**
* *Same observation, different response.* Thomas and Kellner both saw the floppy ears; only Thomas pursued them (Barber and Fox 1958). **[checked]**
* *Doing against reading.*
  * The generation effect is d = 0.40 over 86 studies (Bertsch et al. 2007). **[checked]**
  * Problem solving before instruction gives g = 0.36 over 53 studies (Sinha and Kapur 2021). **[checked]**
  * For experts, worked examples become redundant and solving problems is better: the expertise reversal effect (Kalyuga et al. 2003). **[secondary]**
  * Active self-explanation extracts more from worked examples (Chi et al. 1989). **[memory]**
* *Noticing anomalies while reading with a task.*
  * Students given hypotheses to test were less likely to find a gorilla drawn in the data (odds ratio 4.8, N = 33; Yanai and Lercher 2020). **[secondary]**
  * 20 of 24 radiologists searching CT scans for nodules missed a gorilla in the lung, and most of them looked straight at it (Drew, Võ and Wolfe 2013). **[checked]**

**Implications.**
* *How large the risk is.* By-products of doing account for perhaps 5–20% of significant discoveries, and the share is highest in experimental science.
* *The record is a lossy trigger.* Reading it recovers some insights, as Dunbar's lab meetings show. But it is lossy: the floppy ears were not in the protocol, and the imitator would not write a rare observation.
* *In mathematics,* by-products come from computing examples, which can be recorded in full. The generation and expertise-reversal results still suggest that reading yields less than doing.
* *The imitator's plan is a frame.* A reader primed by the record's framing (a hypothesis, a plan) is less likely to notice an anomaly, and the imitator's confident plan is such a frame.
* **Direction:** down for (B-omit) in empirical work (to 40%), slightly down for theory (to 65%). The note's mitigation, recording raw intermediate data, is supported but only partly: it helps with the record, not with the world.

## 6. Consistency of expert judgment

**Key findings.**
* *Noise* (Kahneman, Sibony and Sunstein 2021): occasion noise is real, but usually smaller than stable pattern noise. **[secondary]**
* *Ashton (2000), a review of test–retest reliability in professional judgment:* it varies by field, and knowledge of it is "meager" **[checked]**; the mean is about r = 0.78 over 41 studies **[memory]**.
* *Fingerprint examiners* (Ulery et al. 2012): 72 examiners retested after about seven months repeated 89% of their individualizations and 90% of their exclusions. Changes were mostly to "inconclusive", and clustered on borderline pairs. 30% of false negatives repeated; no false positive did. **[checked]**
* *Context.* 4 of 5 experts reversed their own earlier identifications when given misleading context (Dror, Charlton and Péron 2006) **[checked]**. In a follow-up, two thirds of experts made decisions inconsistent with their own past ones (Dror and Charlton 2006). **[secondary]**
* *Software estimates.* The same estimator on the same task: mean difference up to 71% (Grimstad and Jørgensen 2007). **[checked]**
* *Wine judges.* About 10% replicated their score within one medal band, and another 10% sometimes gave the same wine Bronze and Gold (Hodgson 2008). **[checked]**
* *Conference review.* At NeurIPS in 2014 and 2021, about half of the papers accepted by one committee were rejected by the other, and 23% of decisions differed. These are committees, not one person. **[checked]**
* *A person's second guess* carries partly independent error, more so after a delay (Vul and Pashler 2008; replications mixed, a large field study positive). **[checked]**

**Implications.**
* *Determinism holds only roughly.* It holds for clear categorical decisions (about 90%) and fails for borderline judgments and open-ended production. A three-month step is open-ended production, so two cold starts on the same notebook would differ. P is really a distribution, and the theorems need their stochastic extension (the note's §8).
* *Setbacks are random.* Detection of a planted entry is itself noisy, so the average-setback form (Remark 5) is the right reading.
  * Independent cold starts help if the noise is occasion noise.
  * They help less if it is stable: Ulery's false negatives partly repeat.
* *Context moves expert verdicts* (Dror). The notebook's other entries are context, so confident imitator entries bias later verdicts.
* **Direction:** none directly on the table's (B_D) rows. Slightly down on the gain claims for a real human: noise lowers posterior confidence, so more asks, and it strains Lemma 1's single P.

## 7. Deadlines and project durations

**Key findings.**
* *Parkinson's law.* Bryan and Locke (1967): given more time, people set lower goals and work more slowly. **[checked]** for the paper; **[secondary]** for the mechanism.
* *The midpoint transition.* Gersick (1988), eight teams with one week to six months: each made its major transition at the calendar midpoint between first meeting and deadline. Later studies support a single transition, not always at the midpoint. **[checked]**
* *Spaced deadlines.* Ariely and Wertenbroch (2002): evenly spaced deadlines beat self-imposed ones in a proofreading task. A recent replication in *Psychological Science* failed, and Data Colada called the effect implausibly large. **[checked]** "Student syndrome" (Goldratt 1997) is a practitioners' concept without controlled data. **[memory]**
* *Planning fallacy.* Theses predicted to take 33.9 days took 55.5, and about 30% finished by the predicted date (Buehler, Griffin and Ross 1994). **[checked]**
* *Heavy tails.*
  * The cost overruns of 5,392 IT projects follow a power law (Flyvbjerg et al. 2022). **[checked]**
  * The time to prove 144 conjectures fits an exponential with rate 0.01 per year, a mean of 100 years (Hisano and Sornette 2012). **[checked]**
* *Completion.*
  * 56.7% of US PhD entrants finish within ten years, about 48% in history (CGS PhD Completion Project). **[checked]**
  * 25% of 1,017 randomized trials were discontinued, 10% of all trials for poor recruitment, and 55% of the discontinued trials stayed unpublished (Kasenda et al. 2014). **[checked]**
  * About one software project in four is abandoned (attributed to Keil et al.). **[secondary]**

**Implications.**
* *The hidden clock removes stated deadlines and the midpoint transition.* By Bryan and Locke, the human may set broader or lower goals. If consolidation needs a deadline, τ(x₀) can be ∞ (thread E §3.1). This is not a (B_D) issue, but it raises n₀ and the floor of failures.
* *Leaked time cues will act.* (B-omit) with g = ∅ holds by construction under a hidden clock, but the content clock leaks (V12). Gersick's teams responded to elapsed time, not to the work done, so cues of elapsed time in the notebook will drive transitions.
* *Heavy tails leave a floor.* With n₀ at the median duration, half of the problems need more than n₀ steps. Under a power law, even n = 2n₀ leaves a material share unfinished; my guess is 10–25%.
  * This floor hits both schemes.
  * In a real comparison, slack's extra steps also absorb the human's own tail, which favours slack imitation.
* **Direction:** neutral on (B_D); slightly up on the gain at ≥ 2× in practice; down on absolute success rates.

## 8. Trust in one's own past notes

**Key findings.**
* *Choice blindness.*
  * Johansson et al. (2005, *Science*), 120 participants and 15 face pairs: under 10% of swapped choices were detected at once, and about a fifth to a quarter by any measure. **[checked]**; the sources differ on the exact figure.
  * Hall, Johansson and Strandberg (2012): 69% missed at least one of two reversed answers on a moral survey, then argued for the reversed position. **[checked]**
  * Hall et al. (2013), during the Swedish election: at most 22% of manipulated political answers were detected, 92% of participants accepted at least one, and voting intentions moved. **[checked]**
  * Merckelbach, Jelicic and Pieters (2011): 57–63% were blind to inflated ratings of their own symptoms, and their ratings a week later moved toward the planted ones. **[checked]**
* *Source confusion.* People adopted others' items as their own in 3–9% of cases (cryptomnesia; Brown and Murphy 1989), more often in written tasks. **[secondary]**
* *Corrections do not erase.*
  * Walter and Tukachinsky (2020), 32 studies and N = 6,527: corrections reduce, but do not eliminate, the effect of misinformation. **[checked]**
  * Self-assessments persisted after participants were told the feedback had been fabricated (Ross, Lepper and Hubbard 1975). **[checked]**
* *Science's own record.* In one sample of 961 post-retraction citations, 86% did not mention the retraction. One retracted trial was cited without the retraction in 96% of later citations (Schneider 2020). **[checked]**
* *Researchers and their own work.*
  * Voevodsky (§1) and Chang's inherited code (§1).
  * Over half of 1,576 surveyed researchers had failed to reproduce their own experiments (Baker 2016; self-report). **[checked]**
* *Size matters.* Detection rises with the size of the change. **[memory]**, from the choice-blindness literature.

**Implications.**
* *Plausibility checking is all the cold-start human has.* By design it has no memory outside the notebook, so it cannot notice a mismatch with what it remembers. What is left is checking for plausibility and coherence, which is weak for attitudes and verdicts (choice blindness) and catches 30–60% of checkable content (§1).
* *Planted entries steer later ones.* They do not merely survive: later entries move toward them (Merckelbach; Hall 2013). That is the propagation mechanism behind V3 and V4.
* *The verify instruction is the right lever.* It catches errors by use, which reading does not. Use, not review, is what catches planted errors.
* **Direction:** strongly down for (B-commit) in empirical and judgment work; down for mathematics.

## 9. Synthesis: what the evidence says about D

* **Setbacks are bimodal.**
  * *Regime A* (D ≈ 0–1) covers perhaps 30–60% of load-bearing wrong entries under human review, and nearly all executable claims with machine checks.
  * *Regime B* (D ≈ 4–12) covers errors that surface at a later failure: about 1 year for visible software faults, 2–3 years for retractions, 3 years for Wiles.
  * *Regime C* (∞) covers trusted dead ends, by-products that arise from the world, and confident wrong verdicts nobody uses in a checkable way.
* **D ≤ 2 at 95% of confident commissions** therefore needs most confident commissions to be harmless: faithful paraphrase, valid alternatives, entries that are not load-bearing.
  * That is plausible for content at the level of wording.
  * It is implausible for slots that are certainly due: results, verdicts, outcomes of attempts (V1, V2, V13).
* **What matters is regime C.** Under Remark 5, slack σ = 20–40 absorbs regime B when it is a minority. Regime C sets β, the share of the learner's hits that concern mistakes that sink a run alone, and with it the realized gain cap (1−ρ)/β (thread E §3.6).
* **My guesses for the share of confident commissions in regime C,** informed by §§1, 2 and 8:
  * mathematics 3–10%;
  * software 2–8%, lower with tests;
  * empirical work 10–25%;
  * judgment work 10–30%.

## 10. My calibrated probabilities

On the note's graded reading: the assumption fails at no more than about 5% of the imitator's confident mistakes of that kind.

| claim | v2 (note) | mine | main evidence |
|---|---|---|---|
| (B-omit), theory and mathematics | 70% | 65% | doing beats reading (§5); framing hides anomalies (§5); reports do trigger insight (Dunbar) |
| (B-omit), empirical or judgment work | 50% | 40% | serendipity 5–20%, much of it from the world outside the record (§5) |
| (B-commit), D ≤ 2, mathematics, without / with ABC | 35% / 55% | 30% / 50% | review catches ~30% (§1); dead ends returned to after years (§2); Einstellung on the confident residue (§4) |
| (B-commit), D ≤ 2, software | 40% / 60% | 35% / 55% | desk checks 25–55%, faults live 1–3 years (§1); machine checks would raise both by about 10 points |
| (B-commit), D ≤ 2, empirical or judgment work | 15% / 30% | 10% / 25% | choice blindness, persistence after correction, false negatives (§§2, 8) |
| beats chained imitation by ≥ 2× (n₀ ≈ 20–40, with ABC) | 70% | 60% | β plausibly 5–20%; slack also absorbs lateness and the human's tail (§7); noise (§6) |
| by ≥ 5× (with ABC) | 50% | 35% | needs β ≲ 10%, which is doubtful outside mathematics and software |

* **Why only modest moves.** Thread E had already priced in most of these mechanisms; the evidence mainly confirms them, and adds the two-mode shape of setbacks and the strength of trust in one's own record.
* **The largest new push** is §8 together with §1: a careful human does not reliably catch a plausible planted entry by reading, and use catches it only on a timescale of a year or more.
* **What would move me up:**
  * evidence that most confident commissions are not load-bearing;
  * the verify instruction lifting detection at use above 80% in the notebook setting.
* **What would move me down:** a planted-dead-end study (§11, study 3) in which fewer than a third of researchers retry the planted approach within the project.
* **Unchanged:** with a verifier (Proposition 4), failures are never output, and all of this affects only the cost.

## 11. Studies that would most reduce uncertainty

**Study 1: planted entries in researchers' own notebooks** (measures β and the distribution of D directly).
* *Participants:* about 60 researchers in three strata (mathematics or theory, software, wet lab), each with an electronic lab notebook and a project of at least a year.
* *Procedure:*
  * With consent to undisclosed edits and full debriefing, the research team makes 3–4 edits per person over 6–12 months, at random times, in entries at least four weeks old.
  * Each edit is drawn from: a dropped insight or observation; "tried A; it fails" where A later worked or was the researcher's own next step; a plausible wrong value; an alternative plan; a dropped hedge. Sham edits (neutral rewording) serve as controls.
* *Measures:* explicit detection; time until the edit stops being acted on; extra time to the project's next milestone against matched sham edits; and the fraction never recovered within the study.
* *Arms:* with and without a standing "entries may contain errors; verify before relying" banner.
* *Output:* the fraction in each of regimes A, B and C, by type and field. That is the quantity the note says decides the gain, set against (D+1)/(ρn₀).
* *Risks:* ethics approval for deception, and real harm to projects. Restrict edits to entries that can be restored and audit them at the end.

**Study 2: reading the record against doing the work** (tests (B-omit) for by-product insights, and the raw-data mitigation).
* *Task:* a half-day analysis or computation, in mathematics (small cases of a conjecture) and data analysis, with a planted pattern that leads to the key insight (an anomaly, or a regularity in the small cases).
* *Arms* (about 40 experts each):
  * (a) do the work;
  * (b) read a complete record of the same work, written by a yoked participant or an LLM imitator, with raw intermediate data;
  * (c) read the same record with summaries only;
  * (d) read (b) with a confident plan entry added that frames the next step.
* *Measures:* the fraction who reach the insight, and how long it takes.
* *Prediction from §5:* (a) > (b) > (c), with (d) the lowest. The size of (a) − (b) is what (B-omit) needs to be small.

**Study 3: planted dead ends with a known solution** (V2 in isolation).
* *Task:* problems with a unique short route A (olympiad-style proofs, debugging tasks with one root cause), about 120 graduate students or professionals, in two sessions a week apart.
* *Procedure:* each participant resumes from a notebook presented as theirs from session 1. The notebook carries one of:
  * "tried A; it fails" (a verdict);
  * "tried A; stuck at step k, where …" (the note's mitigation);
  * no mention of A.
* *Measures:* the probability of retrying A within the session, time to solution, and stated confidence that A fails.
* *Why first:* it is cheap, and it tests the mitigation directly. If verdicts cut the retry rate below a third of the control's, V2 is in regime C for practical purposes and the note's "record where stuck" instruction is essential.

*Folded into study 1:* give 10 participants the same notebook state twice, two months apart, and measure how far the two next steps overlap. That bears on determinism (§6).

## Citations not reached

* *Pages blocked:* the full texts behind Dunbar's figures (Fugelsang et al. 2004, Dunbar and Fugelsang 2005), Sleesman et al. (2012) and Roth et al. (2015), on uwaterloo.ca, gwern.net and core.ac.uk. They would need those hosts allowed in the session's network settings.
* *Figures not found:* the exact percentages for Luchins (1942), Johansson et al. (2005) and Inglis et al. (2013), and Ashton's mean of r = 0.78, should be checked against the originals before they are quoted.
