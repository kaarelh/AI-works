# Thread brief: fundamentals (kind: math)

**Title.** Definitions and basic theorems of Solomonoff axiom induction (working name; `\SAI`).

**Read first.** `../../00-brief.md` (in full, including the epistemic policy), `../../NOTATION-draft.md` (binding), `../../select.md`, and scout F's record `../../scouts/fundamentals/notes.md` (all of it; its items F1–F27 are the starting point). Also: scout S §2.1 (decompositions), scout N1 §1 and §8 (it answers scout F's Q1 and Q2 in part), scout L §3.2 and §4 (Demski, Gaifman), the AI-paper `../../../../axiom-induction/paper/` (§2.7 trichotomy, §6, App. E) and its records `research/tracks/{model,universal,pa,time-followup}/notes-final.md`, and SOI Paper 1 `../../../../solomonoff-function-induction/paper/` (`setting.tex`, `versions.tex`, `learn.tex`).

**Deliverable.** `tracks/fundamentals/notes.md`, scripts in `tracks/fundamentals/checks/` (seeded, outputs saved next to each script), ending with a Verification log.

---

## Goal

Give the paper its definitional backbone and its "basic theorems" sections, at arXiv quality: every definition precise, every theorem with a full proof written in this paper's notation, every cited fact with an exact verified reference. Scout F has proved most of the targets in first-pass form. Your job is to (i) re-verify each proof line by line and rewrite it as a paper-quality proof, (ii) close the gaps scout F lists, (iii) attempt the open questions in the order given, and (iv) state precisely what is new against the earlier report and SOI Paper 1.

Primary object: the one-tape proof-requiring law $M_A$ ("SAI" unqualified). Everything else is a version or a variant of it.

## Targets

Priorities: **core** targets must be completed; **extension** targets are attempted after the core in the order given; for each, report proved / proof sketch / conjecture / refuted honestly.

**T1 (core) Definitions.** Write the definitions in the order they will appear in the paper:
* language, background $B$ (decidable, consistent), data sets as finite partial functions $\Sent_{\mathcal L}\rightharpoonup\{0,1\}$, three-valued data, $\psi_D$, reveal sequences (NOTATION-draft §3);
* theory machines $G$, $A^G_\omega$, laws $\nu_G$, $\nu^3_G$, the universal theory machine $G_U$, $M_A$, $M_A^3$, the posterior, $\Bel_D,\Dis_D,\Indep_D$, $\Bel_0$ (scout F Defs 2.1–2.4);
* the three conventions (semimeasure, normalised, three-valued) and the two defects (global $\Inc_0$, local $\Indep$);
* coin-free $W_A$ and Kolmogorov $K_A$; the statement, with proof, that deciders, enumerators and polynomial-delay enumerators give the same $W_A$ and $K_A$ up to $O(1)$ (Craig; cite and re-check AI-paper Thm 6.3 and TF Thm 2.2(b)); $K_{\rm fin}$ and the inequality $K_A\le K_{\rm fin}+c\le K(\psi_D)+c$;
* complexities of theories $K_\equiv$, $\mm_\equiv$, $\Ext$, $[T]$, $\Unif_A$ (scout F Def 2.7, renamed);
* the variants $M_A^{\rm nc}$, $\Bel^{\rm nc}$, $M_A^{1/2}$ and the generative $P_T$, $\Xi$ (scout F Defs 2.5, §2.9).
A short table must say which objects are new (one-tape theory machines, $G_U$, $M_A$, $K_A$, $\Unif_A$) and which are the AI-paper's (coin-free deciders, the scores $S_{\rm prove}$, $S_{\rm nc}$, $S_g$, the generative L1).

**T2 (core) Structure.** Scout F's F1(a)–(g) (semimeasure inequality with defect $=\Indep$; entailed data free and contradicting data fatal; order independence; $0<M_A(\emptyset)=1-\Inc_0<1$; additivity of $M_A^3$; $M_A$ as a containment functional), F2 (proof-requiring updating is geometric conditioning of the belief function $\Bel_0$), F18 (consistency-requiring updating is Dempster conditioning). Verify the conditioning-rule references (Suppes–Zanotti 1977; Shafer 1976; Pearl 1988; Dempster) by WebSearch to the level "known" or mark "known, unverified".

**T3 (core) Computability.** F3(a)–(d): $M_A=Q-\Inc_0$ with $Q$ lower semicomputable; $\Inc_0$ not computable, Solovay complete, Martin-Löf random (given Kučera–Slaman; verify the reference); $M_A$ not lower semicomputable; conditionals computable in $\emptyset'$. Contrast with P1 Prop 3.7 (`prop:setting:machinelaw`) and Prop A.10 (`prop:setting:computability`): $M_F$ is lsc.

**T4 (core) Universality and invariance.** F4 (mixture identity and dominance $M_A\ge2^{-K(\nu)}\nu$, with the instances (i)–(iii)), F5 (machine invariance), F6 (background as a prior shift), F7 (faithful translations, both directions), F7′ (adding vocabulary changes weights of old-vocabulary data by $O(1)$). For F7′ give the one-line pointer to `terms` T1 (class-level and penalised versions belong there).

**T5 (core) Loss bounds.** F13 (loss against any consistent r.e. $T$ deciding the stream, in any order: $\le-\log\mm(\Ext T)+c\le K_\equiv(T)+c$), F14 (laws plus exceptions; theory-machine laws), F15 (mistake bounds; the Kolmogorov predictor's $2^{k+1}$ errors-or-abstentions), F16 (three-valued merging; write out the integrability step rather than citing P1 Thm 5.3), F17 (lower bound $K(\text{labels}\mid\dom D)-c$).

**T6 (core) Versions.** F10 (coding lower bound for pairwise-incompatible families; the chain $2^{-K_A}\le W_A\le2^cM_A\le2^{K(S)+c}2^{-K_A}$ with slack $K(\text{question})$), F11 (no coding theorem: the $\log d$ gap on two literals of a fresh predicate). **Prove F11(ii) and (iii) directly** with theory machines (the two-atom constructions of P1 Props 4.5, 4.6(b) translate verbatim to machines emitting literals), so that this thread does not depend on `sfi`'s transfer theorem. F12 (coding up to factor 2 for whole theories via Solovay, Vereshchagin, Shekhovtsov–Zakharov): verify these three references by WebSearch and state exactly what each proves; if the factor-2 transfer to infinite sets cannot be verified, downgrade to Solovay's factor 3.

**T7 (core) The consistency-requiring variants.** F19 (0/1 CR weight is a plausibility, bounded below on every consistent $D$: it learns nothing), F20 (the Dempster predictor has linear loss where PR has $O(1)$; order dependence), F21 (graded CR is a weak semimeasure $\ge M_A$, not logically coherent), N1's N10 decomposition of the CR predictor as a mixture of PR and a "weak theory plus data" component. Conclude with the precise reason PR is primary.

**T8 (core) Limits and identification.** F22 (limit posterior in total variation), F23 (complete decidable truths identified up to equivalence; uniform trichotomy), F24 (incomplete r.e. truths: two-valued data leave the prior restricted to $\Ext(T^*)$, three-valued data identify $[T^*]$; text vs informant, with a verified Gold 1967 reference), F25 (computable structures; the one-tape ω-gap in its basic form), F26(a),(b) (Th(ℕ): unbounded loss, the bounds $K(\text{labels}_n\mid n)-c\le L_A(D_n)\le n+K(n)+c$), F27 (random theories above $\Q$ are almost surely incomplete; verify Jockusch–Soare and the effective inseparability of $\Q$). For F24(a)'s claim that the most probable class can be a strict extension, either prove it or mark it as a proof sketch with the missing bound named. State Q1 (does $\Unif(E_\infty)>0$ imply an r.e. theory proves $D_\infty$?) and point to `logic` T1 for its answer (no in general; yes for bounded inconsistency arity and $\Pi_1$ streams).

**T9 (core) The generative variant.** Scout F §2.9 (i)–(iv): supports, reweighting by the size principle, question conditioning (proved there), identification of $\Th(T^*)$ under the generative model against $\Ext(T^*)$ under PR. Keep this short; it is the bridge to the AI-paper's model.

**T10 (extension) Comparison with other priors over first-order theories.** Scout L's Observation L2 (Demski 2012: a random complete theory; per-sentence description cost; no independent outcome; oracle needed to run it). Find a readable source for Demski's construction (WebSearch; the AGI 2012 paper; MIRI or author mirrors; lesswrong.com itself cannot be fetched, but search snippets and mirrors can be used) and turn L2 into a proposition with a full proof, or leave it a proof sketch with the unverified point named. (Observation L1, the Gaifman condition, belongs to `logic` T4.)

**T11 (extension, in this order) Open questions of scout F.**
1. Q5: is the normalised cumulative loss of $M_A$ order dependent? (P1 Prop 3.17(b) shows order dependence for *some* laws of random partial functions, and leaves the case of $M_F$ itself open: P1 Question A.8, `q:setting:normorder`, with the criterion $(\star)$ of P1 App. A. The logical structure of sentence data may make the $M_A$ case easier than the $M_F$ case: whether a theory decides one sentence can depend on how it labels another. Note that the atomic-fragment equivalence holds only up to constant factors, which do not control normalised conditionals exactly, so a direct construction is needed. A positive answer for $M_A$ is worth reporting to the SOI papers as well.)
2. Q4: how large can $\log(M_A^{1/2}(D)/M_A(D))$ be? Conjecture: linearly large in $|D|$, as P1 Thm 3.12(iii).
3. Q7: an exponential lower bound for the Kolmogorov predictor's mistakes on sentence data (the analogue of P1's conjunction ladder, Thm 9.10).
4. Q6: does $M_A$ dominate every lower semicomputable "probability of provability"? (P1 Question 3.14 is the analogue.)
5. Q2 in general (beyond the $\Pi_1$ case that `logic` T2 handles): is $\Unif_A[T]\asymp\mm_\equiv(T)$?

## What is known (references to verify)

Solomonoff 1964, 1978; Levin; Li–Vitányi (coding theorem); Gács; Solovay 1977 (random r.e. sets), Vereshchagin 2007, Shekhovtsov–Zakharov 2023; Kučera–Slaman 2001 and Calude–Hertling–Khoussainov–Wang; de Leeuw–Moore–Shannon–Shapiro 1956; Jockusch–Soare 1972; Gold 1967; Shafer 1976, Dempster 1967, Suppes–Zanotti 1977, Pearl 1988; Demski 2012; Gaifman 1964. Scout F §8 and scout L's `refs.bib` record what was verified and at what level. "Known" requires a verified exact reference; otherwise write "known, unverified" and hedge.

## What to verify computationally

* Re-implement scout F's finite propositional stand-in **independently** (do not copy `c1_toy.py`): theories as model sets, random finite priors with inconsistent mass; check F1, F2, F18–F21, the F24 toy limit, and the three-valued merging identity of F16 on exactly enumerable instances. Compare with `../../scouts/fundamentals/checks/c1_toy.out`.
* F11(i): compute the colouring bound $\ell=\lceil\log(d/\log3)\rceil-1$ against $3^{2^\ell}<2^d$ for a range of $d$, and on a toy universal list of "short theories" exhibit the colliding pair.
* For any extension target attempted, a seeded finite check where one exists.

## What this thread must NOT do

* Not the relation to SOI: the one-tape equivalence with consistent SOI (scout F's F8), the atomic-fragment transfer (F9) and everything time-bounded belong to `sfi`. Cite them as `sfi` T3 and T5.
* Not the lottery, the $\Pi_1$ derandomisation, the coding theorem for $\Pi_1$ data, Chaitin, Gödel phenomena, the uniform ω-gap, the Th(ℕ) growth rate (F26(c)): all `logic`.
* Not theoretical terms beyond F6, F7, F7′ (`terms`), not approximate laws or exceptions with a steeper prior (`laws`), not reasoner-relative variants (`shape`).
* Not philosophy beyond one-paragraph "reading" remarks.
