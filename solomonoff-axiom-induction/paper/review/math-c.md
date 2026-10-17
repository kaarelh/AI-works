# Mathematics review C: §7 (shape), §9 (laws), §10 (kepler), Appendices E (app-shape), G (app-laws), H (app-kepler)

*Reviewer C, 2026-10-17. In progress (restart-safe skeleton; working notes are appended as issues are found and replaced by the final numbered list).*

## Working notes

Build: full build under the lock, 0 errors / 0 undefined refs / 0 undefined cites / 0 multiply defined / 0 overfull >10pt, 230 pages.

### shape (§7, App. E) -- read in full against shape record §0-§13; numbers checked against checks/c1,c3,c5,c6,c7 outputs
- C-w1 [minor] shape.tex prop:shape:depth(d) "Hence ... k=Omega(log m/loglog m)" uses (c) with k growing in m, but (c) is stated "for m large enough given k"; the appendix proof flags this. Fix: state the uniform form of Hastad used, or soften (d).
- C-w2 [minor] shape.tex l.32 "compatibility with Q(S) already forces proj Phi = S" omits "for a sound reasoner" (lem:shape:forces needs soundness).
- all computed numbers in §7/App E found in saved outputs (0.252521 c7 J; 2352, 56/56 c1 E; m=6 r=3 d*=2 4 vs 8 c1 D; equivalence minima c7 G; 12 laws c7 C; ratios 65.1/136.6/256.1/461.0 and 7 vs 5 rounds c7 E; 0.623-0.885 c7 K; rounds 1,3,4,5,5,5,6,7 c7 D; m2^{m-1} rules m=2..7, deletions m<=5 c3 A; 9852/30 c3 D; 330 checkpoints c5; 21.74/54.09/129.87 c7 L; sp_k table c6 B + refB m=17,18).
