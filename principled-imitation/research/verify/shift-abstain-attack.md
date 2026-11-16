# Adversary's report on `research/prove-c/shift-abstain.md` (part `shift-abstain`: S1 to S3, the three kinds of shift, open systems, Ab1 to Ab3, N4, the trade-off)

Role: adversary. The file under attack is `research/prove-c/shift-abstain.md` (917 lines; below "the file"). Status of this report: IN PROGRESS (written in pieces; sections are filled in as the work proceeds).

Conventions as in the file: log is log₂ and ln the natural logarithm; K = log(1/w(P)); L is the horizon; n the number of rehearsal rounds; a "function" is a deterministic sampler; Sil, Abs, Qu are the numbers of silent errors, abstentions and questions.

## Work log (to be replaced by the final text)

* Read the file in full, the candidate theory, `research/prove/lower-bounds.md` Sections 1, 2 and 4, the digests `ask-for-help.md` (Sections 2.1, 2.5 to 2.10, 3) and `notes.md` (Sections 5 and 6).
* Findings so far, to be confirmed by scripts:
  1. Prose overclaim: "the asking cannot stop", "the three quantities cannot all be bounded", "silent errors plus abstentions grow linearly with the number of inputs". The file's own Proposition 4.3(a) stops the asking after at most K ln 2/η questions with no silent error. The lower bound of Theorem 3.3 holds for horizons below the size of the class only.
  2. Prose overclaim: "in a closed system abstention saves at most the factor (1 − a)²". Proved for the needle class with uniform cells only; false for a class whose unlearned region is rare and recognisable.
  3. Not new and not attributed: Theorem 2.5(i) is the reduction of Ross, Gordon and Bagnell; Example 2.2 and Lemma 1.4(3) are the compounding of errors of Ross and Bagnell (2010).
  4. Example 3.2(ii) understates the tightness of Theorem 3.1(b): the bound is attained in the limit.
