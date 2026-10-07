# Orchestration scripts

These scripts started the separate Claude instances that did the work, in this order:

1. **Answers on Peano arithmetic.** These preceded the paper:
   * `pa-answer-check.js`: the "what is conditional on what" answer;
   * `pa-untagged-check.js`: untagged PA without mistakes in the data;
   * `induction-learning.js`: learning the induction schema.
2. **Research tracks:** `schemas-research-a.js` and `schemas-research-b.js`. These cover the cases, single, untagged and experiments tracks, each with an adversarial referee and a revision.
3. **Writing:** `schemas-write-a.js`, `-b.js` and `-c.js`.
4. **Whole-paper review:** `schemas-review-d.js`.
5. **Editing:** `schemas-edit-e1.js` and `schemas-edit-e2.js`.
6. **Final alignment and consistency check:** `schemas-final-f.js`.

They refer to absolute paths in the original working environment.
