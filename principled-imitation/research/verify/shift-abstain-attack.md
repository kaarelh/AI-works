# Adversary's report on `research/prove-c/shift-abstain.md` (part `shift-abstain`)

Role: adversary. File under attack: `research/prove-c/shift-abstain.md` (917 lines; "the file"). The earlier file at this path was a 1.8 KB stub (work log only); per the instructions it was overwritten and the work restarted. Its four preliminary findings were re-checked and are kept below where they survived.

Status: IN PROGRESS (written in pieces).

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
* Script `shift-abstain_attack_stop.py` (below): thresholds with N = 64 (K = 6), inputs drawn adversarially for 10⁵ steps; the threshold rule that asks exactly its abstentions with η < 1/N makes 0 silent errors and asks at most log N + 1 ... (see output) questions in total; the counts stop growing after the first few hundred steps.

What is true (and is what Theorem 3.3 proves): for a class of N = 2^K thresholds and a horizon h ≤ N − 1, (Sil + Abs)·(Qu + 1) ≥ 3h/16 when Qu + 1 ≤ (h + 1)/2. So the number of questions needed to keep Sil + Abs ≤ s is of order min(h, 2^K)/s: asking can stop, but only after a number of questions exponential in K (at most about K·2^K, or 2^k − 1 for enumeration). For a person, 2^K is no bound, so the practical conclusion of the file survives, but the theorem must say "asking cannot stop before about 2^K/s questions", not "for ever". The outline (Addendum 3) fixes N7 as "in an open system asking cannot stop: Theorem 3.3"; the editor must restate N7 with this quantifier. This is the researcher's horizon/budget question exactly, so the wording matters.

