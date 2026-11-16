# Adversary's report on `research/prove-c/shift-abstain.md` (part `shift-abstain`)

Role: adversary. File under attack: `research/prove-c/shift-abstain.md` (917 lines; "the file"). The earlier file at this path was a 1.8 KB stub (work log only); per the instructions it was overwritten and the work restarted. Its four preliminary findings were re-checked and are kept below where they survived.

Status: COMPLETE. Findings: no FATAL, 2 MAJOR, 9 MINOR, 5 WORDING.

Conventions as in the file: log = log₂, ln natural; K = log(1/w(f)) or log(1/w(P)); L horizon; n rounds; Sil, Abs, Qu = silent errors, abstentions, questions. Scripts: `research/verify/code/shift-abstain_attack_*.py` with outputs `.out`.

Read for this report: the whole file; `research/outline.md` (addendum 3, labels); `research/candidate-theory.md` S1–S3, Ab1–Ab3, N3, N4; `research/understand/notes.md` Sections 3E, 5, 6.2; `research/understand/ask-for-help.md` Sections 2.1, 3.1–3.5.

## Findings (ordered by severity)

### FATAL

None found.

### MAJOR

**M1. "The asking cannot stop" (Corollary 3.6, Section 3 title, summary item (2), Theorem 7.3 (L3) and "In words", and the outline's label N7) is false as stated; the theorem proved (Theorem 3.3) is a statement about a class whose size grows with the horizon.**

Evidence.
* Corollary 3.6 builds, for each Q and h, a class of h + 1 functions (log(h + 1) bits). Its gloss "a rule that asks at most Q questions ... makes silent mistakes or abstains ... at a rate per step that tends to 1/(4(Q + 1)) or more as the horizon grows, *however simple the class*" and "A bound on the total number of silent errors over an unbounded deployment, as in Theorem 3.1(b), *requires the human for ever*" reverse the quantifiers: the class is not fixed, its complexity log(h + 1) grows with h.
* For every *fixed* class the file itself gives rules with finitely many questions and zero silent errors over an unbounded deployment on arbitrary inputs: Proposition 4.3(a) (threshold rule, abstentions put to the human, η < w(f)/W: no wrong answer ever, at most K/log(1/(1 − η)) ≤ K ln 2/η questions on every path), and Proposition 6.1(3) (enumeration with budget k ≥ K: never wrong, at most 2^k − 1 questions on every sequence). The digest `ask-for-help.md` Section 3.1 says the same (≤ ⌊1/α⌋ − 1 queries, never wrong), and its Section 3.4 "Consequence" sentence, which the file follows, contradicts its own Section 3.1.
* Theorem 7.3 contradicts its own "In words": corner (U1) "q → 0 with η < w(f)" has Sil = 0, unasked Abs = 0 and Qu ≤ K ln 2/η for ever, so "on inputs from outside, the three quantities cannot all be bounded" is false; and (L3)'s "if the number of questions stays bounded while inputs keep arriving, silent errors plus abstentions grow linearly with the number of inputs" is false for any fixed class once the bound on questions exceeds about K·2^K (or 1/w(f)).
* Script `shift-abstain_attack_stop.py` / `.out`: the threshold class of Theorem 3.3 *fixed* at N = 16, 64, 256 (K = 4, 6, 8), every member as the human, horizon 10⁵ steps, inputs random or adversarial (boundary inputs that refute one hypothesis at a time). The threshold rule with η = 0.99/N that puts exactly its abstentions to the human makes 0 silent errors and 0 unasked abstentions; it asks at most N − 1 questions (15, 63, 255 in the adversarial case; 7, 12, 18 with random inputs), and the last question is at step ≤ 474. So for a fixed class all three quantities are bounded over an unbounded horizon.

What is true (and is what Theorem 3.3 proves): for a class of N = 2^K thresholds and a horizon h ≤ N − 1, (Sil + Abs)·(Qu + 1) ≥ 3h/16 when Qu + 1 ≤ (h + 1)/2. So the number of questions needed to keep Sil + Abs ≤ s is of order min(h, 2^K)/s: asking can stop, but only after a number of questions exponential in K (at most about K·2^K, or 2^k − 1 for enumeration). For a person, 2^K is no bound, so the practical conclusion of the file survives, but the theorem must say "asking cannot stop before about 2^K/s questions", not "for ever". The outline (Addendum 3) fixes N7 as "in an open system asking cannot stop: Theorem 3.3"; the editor must restate N7 with this quantifier. This is the researcher's horizon/budget question exactly, so the wording matters.

**M2. "In a closed system abstention saves at most the factor (1 − a)² in questions" (title of Section 4.4, summary item (3), Theorem 7.3 "In words", Section 10 items 3 and 6) is false as a statement about closed systems; Theorem 4.5 proves it only for the needle class with cells of equal mass, i.e. as a worst case over scaffolds.**

Evidence (script `shift-abstain_attack_closed.py` / `.out`). Same class as Theorem 4.5 (zero function and one-cell indicators), OR scaffold with L = 10 i.i.d. calls, but the cells have unequal mass: one common cell, and N₁ rare cells each of mass π with p_c = 1 − (1 − π)^L = 4σ. Without abstention, the argument of Theorem 4.5 applied cell by cell (σ(f_c) ≥ Pr[c unasked]·p_c − σ(f₀)) forces n ≥ Σ_c (1 − 2σ/p_c) = N₁/2. With abstention, the protocol that asks only the common cell and deploys "answer the common cell from the data, abstain at every rare cell" has silent failure 0 for every member, n = 1, and abort probability a = 1 − (1 − N₁π)^L. For a = 0.2 the saving factor is ≥ 28, 275, 2758 at σ = 10⁻³, 10⁻⁴, 10⁻⁵ (against 1/(1 − a)² = 1.56); for a = 0.5 it is ≥ 84, 836, 8371 (against 4). The factor grows like a/(8σ).

Correct reading: for every L and σ there is a closed system (Theorem 4.5's) in which abstention with abort probability a reduces the number of questions needed by at most (1 − a)² (up to the additive L); abstention cannot improve the *worst case* over scaffolds of a given L/σ by more than that. When the unlearned part of the task law is rare and recognisable (a whitelist situation), abstention can save an unbounded factor. Section 10 item 6 ("abstention would not make the closed system cheaper either") must carry "in the worst case". Theorem 4.5 itself HOLDS (proof re-derived; see the verdict list).

### MINOR

**m1. "Which are rocks" (Section 7.3) overstates for enumeration.** The paragraph says rows two to five are rocks "whenever their parameter is chosen so that soundness is a theorem", and that a slack safe without knowing the gap "must be at least K ... k ≥ K with K_D possibly small". For the threshold rule (η ≤ 2^(−K)), the ratio rule (α ≤ 2^(−K)) and the novelty rule (s > 2K + c₂) the forced refusal radius is about K whatever the data (Theorem 5.3(a),(d), Proposition 6.2(1)); that part holds. For enumeration with budget k ≥ K, soundness is a theorem (Proposition 6.1(3)) but the forced radius proved is k − K_D − c (Proposition 7.5(2)), which shrinks to about k − K as the data make the human the best explanation (K_D → K). So enumeration with a known upper bound k on K is sound by theorem and is *not proved* to be a rock once the data carry about K bits; neither is it proved to be a whitelist of small width (the proved width is 2k + c₂). The paragraph should say "rows three to five always; row two while K_D is small (fewer than about K bits of data)". For a person this needs on the order of K informative answers, so the practical verdict is unchanged; the classification table is right as written (its row two has the K_D).

**m2. The "whitelist" refusal rate of the novelty rule is measured on the rehearsal driver's runs, not on the runs of the deployed frozen rule.** Proposition 6.2(3) bounds (1/n)Σ_t d_t{sep(x; A) < s}, where d_t is the visit measure of the *driver* of round t (any driver). The frozen Nov_s answers with g_D and halts at abstentions; its runs follow the driver's runs only where g_D and the driver agree. Section 7.3 ("they refuse a small part of the calls: at most about 2^a·a·L/n of them for the novelty rule") reads as an abort probability of the deployed rule, which is not proved. Theorem 5.6 shows the missing step for the minimum rule (Lemma 1.4(2) plus a term (L − 1)·E β(M^(t))); for Nov_s the analogous term needs g_D to be right on the visited region, which is the unproved assumption of Proposition 6.2(2). Suggested fix: state 6.2(3) as a statement about rehearsal runs, or add "if the driver is the human system's answers up to that term".

**m3. Labels clash with `research/outline.md`, Addendum 3 (binding).** The file proposes N6 (Theorem 3.3), N7 (Theorem 4.5), N8 (Proposition 4.6), N9 (Proposition 4.8), Ab4 (Theorem 5.6), Ab5 (Theorem 7.3), Ab6 (Proposition 7.5), S4 (Theorem 2.5), S5 (Theorem 3.1). The outline fixes N6 for lower-bounds (non-deterministic human), N7 = Theorem 3.3 of this file, N8 for assumptions (Theorem 6.1 there), Ab4 = Theorem 7.3 of this file. The editor must use the outline's labels; the others must be unlabelled or announced. And N7's outline wording "asking cannot stop" must be corrected (M1).

**m4. Not new, and not attributed in the file.** (i) Lemma 1.2, Corollary 1.3 and Theorem 2.5(i) (the asked call is a uniformly chosen call of the learner's own run; hence no shift factor for the system's own shift) are the reduction of Ross, Gordon and Bagnell (AISTATS 2011, "A Reduction of Imitation Learning and Structured Prediction to No-Regret Online Learning", from memory) in the form of Li and Zhang ("Stagger", arXiv:2412.07057, per outline Addendum 2, item 1, not opened by me). The outline requires this credit; the file gives none. (ii) The factor L of Lemma 1.4(3) and Example 2.2 (errors on the expert's distribution versus one's own) is the compounding-error phenomenon of Ross and Bagnell (AISTATS 2010, "Efficient Reductions for Imitation Learning", from memory). (iii) Theorem 3.1 is label-efficient prediction (Cesa-Bianchi, Lugosi, Stoltz 2005, cited [digest]) applied to the Bayes regret; Observation A of the notes. (iv) Proposition 6.1(3), Proposition 7.1 and Corollary 7.2 are the KWIK enumeration bound and its lower bound (Li, Littman, Walsh 2008, cited [digest]). (v) Proposition 4.6 is Zhang and Chaudhuri's theorem (credited correctly; see the citation check). (vi) Theorem 5.1 and Proposition 5.2(a),(b) are the top-set rule and Ville step of Cohen, Hutter and Nanda plus the derivation of `ask-for-help.md` Section 3.2 (credited correctly).

**m5. Corollary 3.5 ("the factor K cannot be removed") compares different products.** The lower bound is on E[Sil + Abs]·(Q̄ + u) with u = K/log N₁, the upper bound of Theorem 3.1(d) on E[Sil]·Q̄. The two match only when Q̄ ≥ u (then Q̄ + u ≤ 2Q̄), and the lower bound needs Q̄ + u ≤ (h + u)/4 (horizon at most the class size, as in M1). Say so in the statement.

**m6. Prop 7.5 / Section 7.3 inconsistency on α.** Item 4 says soundness for all data when α ≤ 2^(−K) (correct for functions, Proposition 5.2(c)); the "Which are rocks" paragraph says α ≤ δ·2^(−K) (the sampler condition). Use one, with the class named.

**m7. "The same kernel" (Section 5.5, last sentence).** Cohen, Hutter and Nanda's imitator uses the cumulative top set; the candidate's Ab2 and Theorem 5.3 use the ratio set, a superset (Proposition 5.2(a)), which can be much larger (Example 5.7(a)). The kernels coincide only for 𝒞^cum.

**m8. Theorem 7.3 (U2) "No further question is needed, for any number of later runs".** The per-run bounds of Theorem 4.4 are for a round T drawn afresh for every run; a rule kept for good costs Markov's 1/δ′ (the file's own "One rule for good"). Add the qualifier.

**m9. Proposition 5.2(d) (prior-averaged set) is stated without the caveat that it is an average over humans drawn from the prior;** the digest (`ask-for-help.md` 3.5) notes the machine test will not accept it as a guarantee for one human. One clause.

### WORDING

**w1.** Example 3.2(i): equality in the limit of Theorem 3.1(a) also needs W = 1 (the bound is ln(W/w(P)) ≤ K ln 2).
**w2.** Corollary 3.6 "however simple the class": the class has log(h + 1) bits, growing with h (part of M1).
**w3.** Section 5.4 Reading: "n of order 4^K·L²·K/δ²" drops the ln S_½ term of Γ.
**w4.** Theorem 3.3(c) "optimal up to a factor that tends to 2": the learner of (c) is not optimal (exact optima, `shift-abstain_attack_thresholds.out`: N = 48, Q = 3: optimum 216 against 264 for the learner of (c)); the sentence is about the gap between bound (a) and this learner, which is what it says, but "(a) is optimal up to a factor 2" should read "(a) is within a factor tending to 2 of the optimum".
**w5.** The citation of Cohen, Hutter and Nanda: confirmed (see below). The source header gives the JMLR paper ID 21-0618; "23(334):1–30" agrees with the listing found by web search.

## Exact computations done for this report

* `shift-abstain_attack_stop.py`: M1 (fixed threshold class; zero silent errors, at most N − 1 questions over 10⁵ steps).
* `shift-abstain_attack_closed.py`: M2 (unequal cell masses; saving factor ≥ a/(8σ)).
* `shift-abstain_attack_thresholds.py`, written independently of the prover's scripts: (A) exact minimum of N·E[Sil] for Theorem 3.3(a) by dynamic programming, N ≤ 48, Q ≤ 5: no violation of (N²/(Q + 1) − (Q + 1))/4; the values equal the prover's (e.g. N = 12, Q = 1: 22; N = 16, Q = 2: 28 in the prover's table, same code path not shared). (B) Proposition 4.6: the game value equals C(m + 1, ≤ k + 1) − 1 for k ≤ 3, m ≤ 7, including k = 3, m = 7 (162), which the prover's table left capped (≥ 140).
* `shift-abstain_attack_s1.py`: Example 2.2 by exact brute force over all rehearsal histories (rational arithmetic) for three small (L, n, ω): the closed forms of the file are exact; at L = 100 and L = 1000 the violation of the candidate's S1 is by factors 10.7 and 72.3.

## Citation checks

* **Cohen, Hutter, Nanda, "Fully General Online Imitation Learning", JMLR 23 (2022), 1–30; arXiv:2102.08686.** Opened the arXiv v2 TeX source in this session (`\jmlrheading{23}{2022}{...}{21-0618}`). Theorems 1–5 as transcribed in Section 5.5 agree with the source, including s_α = |𝒜|α^(−3)(24w(π^d)^(−1) + 12), the conditions α < w(π^d) and fairness, the "crux" (π^i(0,a|h) ≤ π^d(a|h), π^i(a|h) ≤ (1 + θ_q)π^d(a|h)), the quotes "effectively quartic in w(π^d)^(−1)" and "the training never ends", and the credit of the minimum over top models to Cohen and Hutter's pessimistic agent. Issue 334 confirmed by a web search listing (jmlr.org was not reachable from this session). What the file attributes to them (the kernel, the cumulative set, one-step domination, Ville step = their Theorem 2) is theirs; what it claims is not in their paper (frozen use with abort, exact run domination, coverage, closed-system abort bound) is indeed not stated there as far as the source shows (their paper keeps the demonstrator for ever; their Theorem 5 carries the factor Π(1 + θ_q)). HOLDS.
* **Zhang and Chaudhuri, "The Extended Littlestone's Dimension for Learning with Mistakes and Abstentions", COLT 2016, PMLR 49:1584–1616; arXiv:1604.06162.** Opened the arXiv TeX source: setting ("The adversary then reveals an outcome"), the k-SZB model (at most k mistakes, at most d nontrivial rounds), and Theorem (thresholds): ELdim(H, k) = max{t : C(t, ≤ k + 1) ≤ n} for n thresholds. Venue and pages confirmed by web search (PMLR page). The file's translation (a (k, m) bound exists iff N ≤ C(m + 1, ≤ k + 1) − 1) is consistent with this, and my independent game computation agrees. HOLDS.
* **El-Yaniv and Wiener, JMLR 11:1605–1641 (2010).** Bibliographic data confirmed by web search (JMLR 11(53)). The theorem number ("Theorem 7") and its statement were not checked by me; the file marks it [digest]. NOT VERIFIED (only used for attribution).
* **Yu and Blanchard, arXiv:2602.17918; Sayedi, Zadimoghaddam, Blum (NeurIPS 2010); Li, Littman, Walsh (ICML 2008); Cesa-Bianchi, Lugosi, Stoltz (IEEE TIT 2005); Lattimore, Hutter, Sunehag; Diuk, Li, Leffler.** All [digest] in the file and used for comparison only; not checked by me. No proof depends on them.
* **Ville, Pinsker, TV ≤ √(2H²), Kraft, C(t, ≤ j) ≤ (et/j)^j:** standard; correctly stated.
* **Missing citations:** Ross–Gordon–Bagnell 2011, Li–Zhang (Stagger), Ross–Bagnell 2010 (m4).

## The researcher's seven tests (`understand/notes.md`, Section 5)

1. *Guard.* Answered precisely: Theorem 2.5(iii), Theorem 5.3, Proposition 7.5 and the last sentence of Section 7.3 (a decomposition-created property of fewer than a bits that no asked input has: every abstaining row refuses all such calls, the mixture errs with probability ≥ 2^(−a−c) at each). Theorem 2.5(i) handles self-produced shift only in expectation over calls, which the file says. Nothing caught.
2. *Machine.* The radii carry machine constants c₁, c₂, c₃ and K itself is machine-relative; the file says the window between the radii is machine-dependent (remark after Theorem 5.3). The claim "K for a person exceeds the complexity of every input that will be written down" (Section 7.3) is machine-relative and should be flagged as such. Proposition 5.2(d) fails this test (m9). sep and the plausible sets need a 0″-type oracle (totality of deciders), beyond "unlimited compute" unless that includes oracles; the file says "not computable".
3. *Referent.* Corollary 5.5's assumption (A_α) is where a "how the data were made" hypothesis can win; the file states it cannot be checked from the data. Nothing caught.
4. *Copy.* Engaged: Example 5.7(b) (fill-ins of the coins), Propositions 4.7 (imitates the mode, not the law) and 4.8. Nothing caught.
5. *Budget.* 2^k, K ln 2·2^K, 2^(2K+c), 4^K·L²·K/δ² are stated as empty for a person. Caught: M1 — the file turns "exponential in K" into "for ever".
6. *Rock.* Section 7.3. Caught: m1 (enumeration's forced radius depends on K_D) and M2 (abstention can be cheap when the unlearned region is rare and recognisable, which is the whitelist case the researcher accepts).
7. *Horizon.* Outside the theorems, as the notes say. The online form (Theorem 3.1) keeps the human for ever, which the researcher rejects; the file says so.

## What is not new

See m4. In addition: Theorem 5.1(2)–(4) and Theorem 5.6(b)'s first claim are the derivations of `ask-for-help.md` Section 3.2 (claims 2–5), extended; Theorem 3.3(a) is the digest's Section 3.4 argument with a better constant; Proposition 4.3(a) and the never-wrong threshold rule are item X2 of `understand/repo.md`; Proposition 6.1(1),(2) is Observation B of the notes. Example 2.2, Propositions 2.3, 4.7, 4.8, Theorems 4.5, 5.3(b), 5.6(a), Corollary 3.5 and Proposition 7.5 appear to be new to this project (not a novelty claim for the note, per Addendum 3).

## Verdicts, statement by statement

Proof re-derived line by line unless marked otherwise.

| statement | verdict | note |
|---|---|---|
| Lemma 1.1 (regret on asked inputs) | HOLDS | standard; proof checked |
| Lemma 1.2, Corollary 1.3 (R1 for any driver) | HOLDS | needs the Ross–Gordon–Bagnell / Li–Zhang credit (m4) |
| Lemma 1.4 (coupling) | HOLDS | factor L = compounding error (m4) |
| Proposition 2.1 (S1 for the top-level law) | HOLDS | (c)3 uses HR Theorem 3.1, not re-checked |
| Example 2.2 (candidate's S1 refuted) | HOLDS | exact brute force agrees; candidate S1 (visit-measure form) BROKEN |
| Proposition 2.3 (factor (2L − 1)B) | HOLDS | lower bound L/2 from Example 2.2 |
| Proposition 2.4 (S3) | HOLDS | (c) relies on LB Lemma 1.10(2) with the sharpened count (file's Section 10 item 9); (d) cites LB Theorem 4.3 |
| Theorem 2.5 (three kinds of shift) | HOLDS WITH CHANGE | add the credit for (i) (m4); (ii),(iii) are the cited LB statements |
| Theorem 3.1 (online form, q for ever) | HOLDS | standard (label-efficient prediction); human for ever |
| Example 3.2 | HOLDS | w1 (W = 1) |
| Lemma 3.4 | HOLDS | |
| Theorem 3.3 (thresholds; Sil+Abs × questions) (outline N7) | HOLDS WITH CHANGE | the inequalities hold (independent exact check, N ≤ 48); the label/gloss "asking cannot stop" must become "cannot stop before order min(h, 2^K)/(Sil+Abs) questions" (M1) |
| Corollary 3.5 (the factor K) | HOLDS WITH CHANGE | compares (Q̄ + u) with Q̄; valid when Q̄ ≥ u and h ≤ class size (m5) |
| Corollary 3.6 (asking cannot stop) | BROKEN as stated | the displayed inequality holds (it is Theorem 3.3(a) for a class of h + 1 members); "however simple the class" and "requires the human for ever" are false for every fixed class (M1; contradicted by Propositions 4.3(a), 6.1(3)) |
| Definition 4.0, Theorem 4.1 (Ab1 counts) | HOLDS | |
| Example 4.2 | HOLDS | |
| Proposition 4.3 | HOLDS | tightness example checked |
| Theorem 4.4 (Ab1 under rehearsal) | HOLDS | requires Thr_η to drive the rehearsal, as stated |
| Theorem 4.5 (needle class with abstention) | HOLDS | proof and the algebra of the second claim re-derived; the prose generalisation is BROKEN (M2) |
| Proposition 4.6 (thresholds, every answer shown) | HOLDS | independent game computation equals C(m + 1, ≤ k + 1) − 1 for k ≤ 3, m ≤ 7; Zhang–Chaudhuri theorem confirmed in the source |
| Proposition 4.7 (human with a mode) | HOLDS | kl monotonicity and both explicit forms checked |
| Proposition 4.8 (no both counts for samplers) | HOLDS | identity re-derived |
| Theorem 5.1 (Ab2 dominance) | HOLDS | |
| Proposition 5.2 (plausible sets, Ville) | HOLDS WITH CHANGE | (d) needs the "average over the prior" caveat (m9) |
| Theorem 5.3 (coverage) | HOLDS | (a)–(d) re-derived under (P1)–(P3); (P1)–(P3) for the class of programs computing total functions are plausible but their constants are machine-dependent |
| Proposition 5.4 | HOLDS | El-Yaniv–Wiener attribution NOT VERIFIED |
| Corollary 5.5 | HOLDS | |
| Theorem 5.6 (abort after rehearsal) | HOLDS | supermartingale and union bounds re-derived; Reading w3 |
| Example 5.7 | HOLDS | (b): "void" needs |𝒞| ≥ 2, true (2^(c₀) + 1 members) |
| Section 5.5 (comparison with CHN) | HOLDS WITH CHANGE | statements agree with the source; "same kernel" only for 𝒞^cum (m7) |
| Proposition 6.1 (Ab3) | HOLDS | constant = c₂ of (P2) |
| Proposition 6.2 | HOLDS WITH CHANGE | (3) is about the driver's visit measures, not an abort bound for the deployed frozen rule (m2) |
| Proposition 7.1, Corollary 7.2 (N4) | HOLDS | (2) uses an order that puts a last (adversary knows the human), fine for a lower bound |
| Theorem 7.3 (trade-off; outline Ab4) | HOLDS WITH CHANGE | the listed bounds hold; "In words" is BROKEN in two sentences ("the three quantities cannot all be bounded", "grow linearly", M1; "saves at most (1 − a)²", M2); (U2) qualifier m8 |
| Definition 7.4, Proposition 7.5 | HOLDS | items 0–6 re-derived |
| Section 7.3 classification and "Which are rocks / whitelists" | HOLDS WITH CHANGE | m1 (enumeration), m2 (novelty refusal rate), m6 |
| Candidate S1 (visit-measure form) | BROKEN | Example 2.2 |
| Candidate S3 | HOLDS WITH CHANGE | as made exact in Proposition 2.4 |
| Candidate Ab1, Ab2, Ab3, N4 | HOLDS WITH CHANGE | Ab2 needs the constant c₁ and the ratio-set caveats; N4 "ask or abstain"; Ab1's "in line with N4" sentence with j = log(1/η) |

Status: COMPLETE.
