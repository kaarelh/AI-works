# Edit log, group soi (sections/soi.tex, sections/app-soi.tex)

Status: IN PROGRESS (phase 1). Started 2026-10-17.

Binding: review/DECISIONS.md (§0, §U1, §U7, §L, §G-soi, §X), review/issues-soi.json.

## Issues

| id | status | what changed, where |
|---|---|---|
| SOI-01 | pending | |
| SOI-02 | pending | |
| SOI-03 | pending | |
| SOI-04 | pending | |
| SOI-05 | pending | |
| SOI-06 | pending | |
| SOI-07 | pending | |
| SOI-08 | pending | |
| SOI-X19 | pending | |
| SOI-L1 | pending | |

## Plan and progress (restart safety)

Originals backed up in the session scratchpad (`soi-orig/`). Measurement harness: scratch build of soi + app-soi with the
other sections' labels loaded from `main.aux` (reproduces the full build's "Float too large by 0.89507pt" and gives
9.33 pp. against 9.43 in the full build). Baseline: 8.33 pp. of text + Table 1 on its own page.

1. [x] soi.tex rewritten (16:2x): SOI-01 (statement), SOI-02/L1 item 8, SOI-03, SOI-04, SOI-08, X19, L1 list A items 1-9.
2. [x] app-soi.tex: moved items inserted before their proofs; SOI-01 (proof, incomparable), SOI-05, SOI-06, X19.
2b. [x] list B items 1 and 2 applied; Table 1 compacted to 408pt (< 0.7 textheight) and placed [t] before sec:soi:breaks; extra prose cuts. Harness: 5.72 pp. (coordinate measure; calibrated: original 9.40 vs full build 9.43).
3. [ ] quality pass (read-through, symbols, cross-refs), greps, ./test-section.sh, final log.

## Moved labels

## Shortened labelled paragraphs

## Page counts

## Requests to other groups
