# Adversary's report on `research/prove-c/property-online.md` (part `property-online`: Theorem Pr5, the rules N and NH, the rehearsal corollary, the limits, the randomised version, the comparisons with the Bayes mixture) and on Sections 8.3 and 8.4 of `note.md`

Role: adversary. **Status of this file: IN PROGRESS** (written in pieces; this line is removed when the verdict list at the end is final).

The file under attack is `research/prove-c/property-online.md` as it stood on 15 Nov, 23:01 UTC (871 lines, Sections 0 to 10; below "the file"). Sections 8.3 and 8.4 of `note.md` (the lead's draft; below "the note") are compared with it. The file under attack was not changed. Scripts of this report: `research/verify/code/property-online_attack_*.py`, each with its output saved next to it as `.out`.

## Working notes (preliminary; replaced by the ordered findings below when complete)

Read so far: the whole file (Sections 0 to 10), Sections 8.3 and 8.4 of the note, the outline, the entry Pr5 of `research/candidate-theory.md`, and Sections 2.5, 5 and 6 of `research/understand/notes.md`.

Hand check of the proofs (no error found so far in): Lemma 1.3; Lemma 1.4 (a) to (f); Theorem 2.1; Example 2.3; Proposition 2.4; Theorem 3.1; Corollary 3.2; Theorem 3.3; Corollary 3.4; Propositions 3.5 to 3.8; Propositions 4.1 to 4.4; Proposition 5.1 and 5.2; Lemma 6.1; Theorems 6.2 and 6.3; Proposition 6.6; Examples 7.1, 7.2; Propositions 7.3, 7.4; Lemma 7.5; Theorems 7.6, 7.8; Corollary 7.7; Propositions 8.1, 8.2.

Attacks planned: exhaustive game-tree search against the rules on small instances; exact enumeration of the rehearsal protocol; the literature; the seven tests.
