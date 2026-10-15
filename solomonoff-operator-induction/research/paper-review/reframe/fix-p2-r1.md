# Paper 2, fixer, round 1 (2026-10-13)

Inputs: `reader-p2-r1.md` (R-F1 to R-F11, O1 to O3) and `diffcheck-p2.md` (D-F1 to D-F5, D-Obs). Each finding was checked against REFRAME.md, `research/prior/hanni-grokking-a-notion.md`, `research/prior/hanni-lesswrong-comment-thread.md` and the paper's own statements. Files edited: `sections/intro.tex`, `absorb.tex`, `algstat.tex`, `teacher.tex`, `setup.tex`, `limits.tex`, `split.tex`, `related.tex`, `app-teacher.tex`. No git command that changes state was run.

## Findings

The mathematics-invariance findings of the diffcheck (D-F1 to D-F5) were handled first. Where the reader and the diffcheck found the same problem, both ids are given.

| id | verdict | what was done |
|---|---|---|
| D-F1 | fixed | `algstat.tex:6`. "one expects none" was too general: the set structure function does change slope at the minimal sufficient statistic (`prop:algstat:parity`(i)). Now: "With shared randomness, as in the sequence case, one expects none where a random parameter of the model ends, because each of its bits pays for about one bit of data (\cref{rem:algstat:reading})." This matches `rem:algstat:reading` and Table 1, row 9. |
| D-F2 | fixed | `algstat.tex:6` footnote. Locating the split by a change of slope is Kolmogorov's structure function, so it is standard. The footnote now credits only the note's contribution: "The suggestion to look for this change of slope in function induction, and the reason why none is expected with shared randomness, first appeared in the author's note \citep{hanni2026grokking}." |
| D-F3 + R-F3 | fixed (merged) | Deleted the footnote in `absorb.tex:5`. Its credit moved to FN1 (`intro.tex:9`), at the first statement of the private-randomness idea. In line with D-F3, FN1 claims priority only for the suggestion, not for the pathology, which the paper calls a standard point: "The proposal, and the suggestion that private randomness at each input avoids its failure in sequence prediction, first appeared in the author's note \citep{hanni2026grokking} and in an online discussion (on LessWrong), where the absorption point below was also raised." Both sources contain the suggestion: grokking note l.7, and Hänni's LessWrong answer. |
| D-F4 | fixed | `intro.tex:15`. "supports this hope" became "illustrates the proposal". The three hypotheses include no universal hypothesis, so the calculation is no evidence against absorption. `rem:teacher:hanni` itself says that a universal hypothesis is not excluded. |
| D-F5 + R-F10 | fixed (D-F5); R-F10 option 1 | `teacher.tex:7` footnote. "The convex-hull view of selection" is standard: penalised selection picks hull vertices, and the earlier report has the hull lemma. That credit was replaced by the note's actual items (grokking note l.8, l.62): "The example (both versions) and its three-hypothesis calculation, the question whether the good model is a vertex of the convex hull, and an absolute complexity bound as an alternative first appeared in the author's note \citep{hanni2026grokking}." With the hull view no longer credited, R-F10's concern (credit two sections late) mostly lapses. The footnote stays in §5, next to the example (R-F10's own option 1). |
| D-Obs + R-F2 | fixed | `setup.tex:63`. The near-verbatim note phrase "a higher coefficient on the length of the program than on the likelihood term" is one REFRAME §5 names. It became "The two-part objective weights the length of a program $\lambda$ times as heavily as its negative log-likelihood; the power-prior posterior is its Bayesian form." This equals $J_\lambda=\lambda\ell-\log P$, so the mathematics is unchanged. |
| R-F1 | fixed | Table 1, row 4: "Is the three-hypothesis calculation correct, and is it realised by instances?" became "Is the three-hypothesis calculation realised by instances?" The Answer and Where cells are unchanged. |
| R-F4 | fixed | `limits.tex:48`. The hard-to-parse, verdict-like "what holds is the example for …" became "The example is favourable to the proposal, though not contrived; its conclusion holds for error rules incompressible relative to the model (\cref{thm:teacher:main})." The content is the same: the restriction to incompressible rules is kept, and the preceding sentence still says that density and length alone do not suffice. |
| R-F5 | fixed | `rem:teacher:hanni`. "rather than $p\log(1/p)\approx1/100$" corrected an approximation the paper never makes, so it was removed. The sentence now reads "…gives these numbers, with the exact binary entropy $H(2^{-10})=0.0112$." Every number of the paper already uses the exact entropy, so no statement or caveat changes. |
| R-F6 | fixed | `intro.tex:15`. "The example was chosen to favour the proposal" became "The example is favourable to the proposal". |
| R-F7 | fixed | `rem:teacher:hanni`, first sentence. "The example has two versions." became "The example comes in two versions: in total bits, and per sample as in \cref{sec:intro}." The items are unchanged. |
| R-F8 | fixed | `intro.tex:15`. "A second question is whether …" now has its own motivation: "The split between model and noise arises in its simplest form for labels drawn by a simple sampler, whose coins are the noise; programs that fill in the sampled bits store the noise as model. At $\lambda=1$, Solomonoff induction has no preference between the two; does a steeper prior prefer the sampler?" `split.tex:6`: "…no preference between the two, although only the sampler separates model from noise; a steeper prior might prefer it." The $\lambda=1$ claim about SI is unchanged. |
| R-F9 | fixed (row rewording) | Table 1. Row 2: "Can the good model of the example be selected for a range of $c$, as a vertex of the convex hull of (complexity, expected log loss)?" Row 6: "Does an absolute bound on model complexity select the same hypotheses as the penalty?" Row 9: "Against hypothesis length, does the entropy left given the hypothesis change slope at the model?" The Answer and Where cells are unchanged; they still match `lem:setup:hull` and `prop:algstat:parity`. The reader's alternative, a new intro sentence, was not needed. |
| R-F11 | rejected | REFRAME §4 says that `tab:intro:claims` "keeps its rows but no longer refers to the notes". The row "Has a steeper penalty been studied for the model–noise split?" is neutral, mentions no notes, and asks a natural question that §2 answers. |
| O1 | fixed (wording only) | `related.tex:28`, outside REFRAME's scope but a harmless clarity fix: "We re-derive, rather than copy, the results …" became "We re-derive the results …", and "Two statements change." became "Two of its statements change here." |
| O2 | rejected | The suggested rewording ("schema" → "rule") falls inside the statement of `prop:limits:guard`, and REFRAME §8 freezes statements. The finding is also outside REFRAME's scope (vocabulary of the earlier report), and σ's role is defined within the statement. This is left to the lead editor. |
| O3 | fixed | `app-teacher.tex:125`. The ambiguous "reproduce its window … and its $\lambda=1$ switch" became "give the same window … and the same $\lambda=1$ switch". The numbers are unchanged. |

## Invariance checks

* **Labels, `\status`, `\src`, environments.** For every edited file, the sorted lists of `\label`, `\status`, `\src` and `\begin{…}` match commit 5acf4db3 exactly. No numbered environment, section or equation was added or removed. No footnote sits inside a theorem-like environment or a float.
* **Inline math.** The only inline math removed relative to 5acf4db3 is the note's approximation "$1/100$" (R-F5). It is not a statement of the paper.
* **Length.** `pdftotext main.pdf | wc -w` gives 35,416 words, against 35,413 at 5acf4db3 and 35,403 before this round. The PDF has 57 pages, the same as at 5acf4db3. The difference of 3 words is hyphenation-level noise.

## Footnotes citing the notes: 3

Before this round there were 4.

1. p. 2, `intro.tex:9`. Cites `hanni2026notes` (the notion of SFI) and `hanni2026grokking` (the proposal and the private-randomness suggestion; the online discussion; the absorption point).
2. p. 12, `teacher.tex:7`. Cites `hanni2026grokking`: the example, the calculation, the vertex question and the absolute bound.
3. p. 24, `algstat.tex:6`. Cites `hanni2026grokking`: the slope suggestion for function induction and its reason.

Outside these footnotes, the notes are cited only in the acknowledgements (`discussion.tex:30`, unchanged).

## Build

* **Command:** `cd paper-steeper && flock /tmp/claude-0/paper-build-sfi.lock ./build.sh`.
* **Final run:** 0 LaTeX errors, 0 undefined references, 0 undefined citations and 0 multiply defined labels. No overfull box exceeds 10pt; the only overfull box is 1.84pt, in the unchanged Code and data paragraph. The PDF has 57 pages.
* **Companion numbers:** `python3 -I research/paper-review/scratch/editor/check_companion_numbers.py` ends with **`ALL OK`**. It also prints "used not in intended: {'Theorem~5.1'}". That entry is the `\citep[Theorem~5.1(a)]{claudeSFI2026fundamentals}` added in `rem:absorb:wyeth` by the reframe pass, and `paper/main.aux` confirms that `thm:learn:dominance` is Theorem 5.1. The script's list of expected citations simply predates that citation.
* **Text dump:** `research/paper-review/reframe/p2-fix-r1-main.txt` (`pdftotext -layout`).
