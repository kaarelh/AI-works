# Verification

This folder holds the record of how the note and its proofs were checked. All checkers were AI models; no human has checked the mathematics.

*(This file is completed when the review round has finished; the sections below describe the process.)*

## How the proofs were checked

The note has eight parts. For each part KEY:

1. A prover wrote the proofs (a working file, kept on the working branch under `research/`).
2. `KEY-check.md`: a referee went through that file line by line, recomputed the constants and tested statements numerically.
3. `KEY-attack.md`: an adversary looked for counterexamples by exact computation on small instances, for hidden assumptions, for prose that claims more than the theorems, and checked the citations.
4. An editor verified and decided every finding, corrected the proofs into `../proofs/KEY.md`, and wrote the text of the part for the note. The last section of each proof file, "Checking", lists the findings and decisions.
5. `KEY-second.md`: a second checker read the statements that the editor had added or changed and that no independent verifier had seen, and compared the note's text with the proof file. The editor's decisions on these findings are in the subsection "Second check" of the proof file.

The reports of steps 2 and 3 refer to the statements by the numbers of the provers' drafts. These mostly agree with the numbers in `../proofs/KEY.md`; where they differ, the "Checking" section says so.

## How the assembled note was checked

Five referees read `../note.md`: `referee-reader.md` (as the reader for whom it is written), `referee-math.md` (the mathematics as printed, and every pair of an upper and a lower bound against each other), `referee-consistency.md` (labels, cross-references, the same quantity everywhere, the numbers of Section 11), `referee-references.md` (the references and Section 12), `reproduction.md` (a re-run of every script).

`code/` holds the checkers' scripts with their saved outputs.
