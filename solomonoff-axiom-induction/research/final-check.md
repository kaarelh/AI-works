# Final check of `research/notes-final.md`

*Fresh final checker, 2026-10-16. Folder `research/`. Task: compare every headline statement of `notes-final.md` (§1 H1–H15, and the tables of §3 that restate them) with the thread final records `tracks/<key>/notes-final.md` and their referee reports; check that every entry of `refs.bib` was verified by a scout, thread or referee; re-run three of the most important scripts; fix mismatches in `notes-final.md` minimally and record them here.*

**Restart check.** At the start of this run `research/final-check.md` did not exist and no file in `research/` was newer than `notes-final.md` (06:28); nothing from an earlier interrupted check had to be recovered.

*(In progress; sections are appended as they are completed.)*

## 1. Scripts re-run (done first, in the background)

Three of the most important scripts were re-run on fresh copies of their `checks/` folders in the scratchpad (`/tmp/claude-0/-home-user-AI-works/c4435474-536f-5a96-a73c-7d0c5ea93659/scratchpad/rerun/`), cwd = the copy's folder, the saved output moved aside first; the regenerated output was compared byte for byte (`cmp`) with the saved one in the repository.

| script | headline it supports | run time | result |
|---|---|---|---|
| `tracks/sfi/checks/c1_onetape_finite.py` (seed 20261015) | H1, E4–E5 (one-tape equivalence, finite stand-ins: 0 violations in 2 × 1,844,800 triples; closure and trichotomy items) | 38 s | **byte-identical** (md5 `b6c17d47…`) |
| `tracks/logic/checks/c1_lottery.py` (seed 20261016; prints to stdout) | H2 (survival product, $\prod_k(1-2^{-(k+1)})\approx0.288788$; batch lottery; true-lottery bookkeeping; co-r.e. streams) | 1 s | stdout **byte-identical** to the saved `c1_lottery.out` (md5 `3c552c59…`) |
| `tracks/laws/checks/l10_revision.py` (seed 20261016; reads `l4_residuals.npz`) | H8 (per-fit peakedness 1.60–3.95 / 1.89–7.08; SH wins 429/429 cells at each κ; HY* < H in 34 of 39 pairs; SH 0.4–25.7% below H) | 196 s | identical **apart from the run-time line** 196 (`# runtime 196 s` against `199 s`); every other line byte-identical |

The figures quoted in `notes-final.md` H8 were re-read from the regenerated output: l. 45 (peakedness ranges), l. 96 (34 of 39), ll. 101–104 (429 cells; 0.4% to 25.7%). No discrepancy.
