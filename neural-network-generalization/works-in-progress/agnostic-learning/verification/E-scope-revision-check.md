# Check of E's revision in answer to the scope report (`verification/E-scope.md`)

*Published record of the independent check of the E note's revision in answer to its scope report, made during finalization. Paths under `stage/` refer to the lead's unpublished working copies; the pre-revision text there equals the note as committed before the revision. The check's scripts and outputs are in [`../checks/revision-check-E-scope/`](../checks/revision-check-E-scope/).*

**Verdict: minor_fixes.** Every issue the author was asked to handle (5 for §0 row 6 and Answers (2), 7, 8, 9 and 11) is resolved as the new "Scope referee" table says. Each is either a correct fix or, for the Answers (2) part of issue 5, a valid rebuttal. Every changed passage is mathematically correct. Nothing outside the scope answers changed, and every link resolves from `research-notes/`. One changed passage claims slightly more than is shown: the two summaries of the new d-threshold leave out "at n = 2^d" (item 1 below). Two wording nits remain (items 2 and 3).

Compared: `stage/E-pre-scope.md` against `research-notes/E-finite-prior-scale.md`, line by line and word by word (`../checks/revision-check-E-scope/worddiff.py`, `../checks/revision-check-E-scope/diff.txt`). There are 14 hunks, and each traces to one of the scope issues or to the record in the intro, §7, §8 and §9.

## Record of the scope issues

| issue | author's resolution | check |
|---|---|---|
| 1–4, 6, 10 | answered in the README by the lead editor | listed as such in E §9; not checked here (README pointers exist) |
| 5 | §0 row 6 fixed (n/2^d→λ∈(0,∞), β from (I4), n=2^d named); Answers (2) rebutted; README part to the lead editor | fix matches Cor 5.3's hypotheses. The rebuttal is valid: Answers (2) (line 23, unchanged) contains neither "n≍2^d" nor "β(λ)"; it states the case d=log₂n |
| 7 | §2.1 and §2.7 reworded to what the proof needs; Remark 2.8 extended; zero-network comparison not added | correct. Re-derived: (c) ⇒ budget 8A+4n^θ(U+2)²; θ_{L,γ} depends only on the power of n (Cases I–III). Remark 2.8 checked against B Lemma 2.3(a) (K=n^θ+1, competitor-free), Thm 6.3 (capacity term 8(2/H)^{H/2}D_n n^{-(1-θH)/2}) and Cor 8.1 (α<1/(4H)). Ratio ≥ (2(U+2)²)^{H/2} (=18 at H=2, U=1) holds on 20000 random cases; 8A≥4E_*; α-range 1/(8H) vs 1/(4H) confirmed by exponent bookkeeping. No zero-network result was added, as the instructions required |
| 8 | §6 "Two qualifications", row 7, Answers (1), the paragraph after Cor 5.4, §7 item 9 with new script, §8 | numbers reproduced by an independent implementation (different β_n method). Schedule n=2^d: e=0 exactly for d≤172/80/293, 0.0604, 0.4618, 0.1008, 0.1778, 0.4742, and 0.4848 at d=1600; nondecreasing after the threshold. With exact β_n, cK_lb/n≥β_n at every d up to the same thresholds, so no a, t or δ gives e>0 there at n=2^d. The small-width statement holds: Lemma 2.2, (C1)–(C2) and the regime-S sum (<0.76ε) use no θ<θ_{L,γ}; the event is E_H∩⋂E_{2.2}(δ/(4N²)) with probability >1−δ; only (I1) is used; Jensen gives the mean. On the cube with g≡0, A≈0.66–0.72·d² and (C1)–(C2) hold from d≈22–39; small widths lie below n ≤ N_*. Author's script re-run: byte-identical output, 5.1 s |
| 9 | row 7 and Answers (1) restate the (I3) dependence | fixed |
| 11 | Lemma 1.1 paragraph and open problem 5 | correct. The second form of (b) holds for every prior; Lemmas 2.1, 2.2 and 5.1 use only it. `paper.tex` eq. `law` is variance one, so Lemma 5.1's moment bound is unchanged. The correction "(I2) does not involve the prior" is right |

## Remaining problems

1. **(minor) The d-threshold summaries omit "at n = 2^d".** The places are §0 row 7, "(for H=2 and θ≤0.55, at no d≤172)", and §0 Answers (1), "Theorem 5.2 certifies no excess at any d≤172". The §9 row 8 phrase "no choice of a, t or δ gives e>0 up to the stated d" has the same gap. §6 and §7 item 9 state the restriction correctly, but these summaries read as statements about Theorem 5.2 at every n. They are false at other sample sizes. At n=λ2^d with λ<1, with δ=0.01, t=10⁻⁶ and β_n ≥ β(λ)−n/M² (A Lemma 4.3(c)), Theorem 5.2 certifies a positive excess earlier:
   - (H,θ)=(2,0.55): from d=156 (λ≈0.07), and e=0.0085 at d=172 (λ≈0.32);
   - (2,0.6): from d=75;
   - (3,0.36): from d=259.

   The qualitative claim "certified only at large d" stands. *Fix:* "at no d≤172 when n=2^d" in row 7; "certifies no excess at n=2^d for any d≤172" in Answers (1); "at n=2^d" in §9 row 8.
2. **(nit) The paragraph after Corollary 5.4 says "θ<1".** For θ≤0 the term 2n^{-θ}A does not vanish, so the claim is false there. *Fix:* "0<θ<1".
3. **(nit) §9, Scope referee paragraph, says "reproduced Table 7.1".** The referee reproduced only the six λ=1 values of e. *Fix:* "reproduced the λ=1 column of Table 7.1".

Optional: Remark 2.8's α<1/(8H) is a limit of this proof's budget (§2.1), not of the learner, and a pointer to §2.1 would keep a reader from taking it as a property of the learner.

## Files (scratch, `../checks/revision-check-E-scope/`)

- `indep_excess.py`/`.out`: independent schedule computation of e; β_n by the integral formula; β(1) in closed form.
- `indep_lower_and_lambda.py`/`.out`: Part B, the bound cK_lb/n ≥ β_n with exact β_n; Part C, the scan over λ behind item 1.
- `remark28_and_smallwidth.py`/`.out`: the capacity ratio, the α ranges, A=O(d²) and (C1)–(C2) on the cube.
- `rerun_author.out`: the re-run of `checks/E/excess_near_threshold.py`, identical to the committed output.
- `worddiff.py`, `diff.txt`: the comparison of the two versions.
