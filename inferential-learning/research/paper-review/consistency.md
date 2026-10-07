# Consistency and rendering review

Reviewer lens: cross-section consistency and rendering. This covers (a) rendering defects, (b) notation and macro consistency, (c) the accuracy of every `\cref`-backed claim in `intro.tex`, `abstract.tex`, `philosophy.tex` and `open.tex`, and (d) the intro's verification and Lean statistics.

**Note on versions.** `research/paper-review/main.txt` comes from the 05:59 PDF. While this review ran, `intro.tex`, `abstract.tex`, `philosophy.tex` and `open.tex` were revised (06:31–06:34). I therefore rebuilt the current sources in a scratch copy with `build.sh`: 0 errors, 0 undefined references or citations, 265 pages. Every finding below was re-checked against the current files. Claims that the revision already fixed are listed at the end and are not reported as issues.

---

## (a) Rendering

Both builds (old and current) have no `??`, no undefined references or citations, no multiply defined labels and no stray macro names. The garbled-looking `RΣP \S Cd` in main.txt line 3218 is a pdftotext artefact of `\setminus\bigcup`, not a defect.

### R1. The division-of-labour table floats to the last page (major)
- **Where:** `philosophy.tex`, `\begin{table}[ht]` for `tab:philosophy:labour`.
- **What happens:** Section 13 starts on p. 152, but the table is printed on p. 265, after the bibliography and every appendix, including the Lean appendix. The table is too tall for `[ht]`, and without `p` it cannot go on a float page, so LaTeX defers it to the end of the document. The old PDF showed the same thing for both philosophy tables (old Tables 22–23, pp. 261–263).
- **Fix:** use `\begin{table}[!htbp]`, or `[p]`, or add `\clearpage` at the end of `philosophy.tex`.

### R2. The Lean map table (tab:lean:map) runs off the page (major)
- **Where:** `app-lean.tex`, the longtable column specification `p{3.4cm} p{6.6cm} p{2.0cm} l`.
- **What happens:** The `l` Fidelity column cannot wrap, which gives an overfull box of 222.6 pt (about 7.8 cm). In the rendered PDF, three cells are cut off at the page edge:
  - "exact for the lower bound; the min…"
  - "exact (deterministic learners; one c…"
  - "exact for (d); variant for (b); specia…"
- **Further defects in the same table:**
  - The 2.0 cm Module column is too narrow. It collides with the next column ("CoherenceGamesexact", "CoherenceGamesspecial case"), pushes entries onto a second line ("PostCompleteness / exact") and is hyphenated as "Para- doxLower- Bound".
  - Long `\texttt` names overflow by up to 38 pt.
- **Fix:** see issue list.

### R3. Overfull theorem headers in twotier.tex (minor)
These headers overflow because their `\src` superscript boxes cannot break:
- line 77: 32 pt;
- line 306: 14 pt;
- line 388: 49 pt;
- line 406: 26 pt.

`intro.tex` (the item-(4) heading) overflows by 6 pt.

### R4. Doubled parentheses in assumption titles (minor)
amsthm adds its own parentheses, so these titles print with two pairs:
- "Assumption 7.1 ((Floor))" (`twotier.tex:53`);
- "Assumption 2.14 ((WS), sound evaluation)" (`setting.tex:315`);
- "Assumption 10.3 ((BG), bounded gap)" (`informal.tex:64`).

### R5. PDF bookmarks lose their content (minor)
These titles have no `\texorpdfstring`:
- `app-setting.tex` lines 15, 38, 95, 135, 145 use `\Cref` in subsection titles. The bookmarks read "Proof of (closure facts)".
- `physics.tex:495` ("$100=99.9$") and `app-caution.tex:203` ("$k=2$, $h=3$") have math in their titles, and hyperref strips it.

---

## (b) Notation and macros

### Macro definitions
I collected every `\providecommand`, `\newcommand`, `\renewcommand` and `\def` in `sections/*.tex`. That is 87 distinct names.
- No name has two different definitions.
- I also checked with a test document loading `preamble.tex`. The only name already defined before a section's `\providecommand` is `\Fm` (in `twotier.tex`), and it has the identical definition `\mathrm{Fm}`.
- So no `\providecommand` silently keeps a conflicting meaning.

### Agreement with NOTATION.md
- **Channels (P), (C), (W).** These are used consistently. `informal.tex` adds (O) for objects and states explicitly that "(O) is the world channel (W) … objects (W2), with computation (W1, W3) as a special case". The mapping is documented, so this is not a defect.
- **R^P, Σ^P, designated contexts and positions, negative bag.** These are consistent across setting, coherence, twotier and informal.
- **Soundness notions** (`def:setting:soundness`: δ-sound, 0-sound, uniformly δ-sound, target-, practice- and truth-soundness, depth-d sound). These are used consistently in the sections.
  - *Note for NOTATION.md (not a paper issue):* NOTATION.md glosses "δ-sound" as "uniformly over provers". In the paper, "uniformly δ-sound" names the strictly stronger single-event notion. NOTATION.md should say "for every prover".

### Lean tags
- **Mixed namespace prefixes.** Some tags carry a module namespace (`Post.…`, `RateThreshold.…`, `Blame.…`); others do not (`thm_2_2`, `negative_bag`, `carnap_single`, `thm_3_1_a_static`). The latter cannot be located in the formalization. See the issue list.
- **Duality tag conflicts with the map.** The tag on `thm:existence:duality` is `Carnap.Val_mrel` "(semantic half, propositional Fm)". `tab:lean:map` and `lean/README.md` instead give `Bilateral.scottClosedIso`, which is exact and holds over an arbitrary formula type.

---

## (c) Cross-referenced claims in abstract, intro, philosophy and open

I extracted the statement of every result cited from these four files (about 80 labels) and compared each claim with it. The claims below are still inaccurate in the current sources.

### intro.tex
1. **"Coherence belongs on the root and the anchored contexts only (thm:physics:realizability)."**
   - Only part (a) of the theorem supports this, and (a) is *frame-free*.
   - In the frame semantics the condition is necessary but not sufficient (part (c)).
   - `physics.tex` says explicitly: "The locality of (a) is a consequence of (R2), not a fact about the frame semantics, where rigid parameters and shared filters force cross-context constraints." The exact condition under limit semantics is `prop:physics:framerealizability`.
   - T3's verification log calls the stronger reading an overclaim (A1, remark (i)).
2. **"Designating 'idealization plus full background' as coherent forces a globally paraconsistent logic (prop:physics:misdesignation)."**
   - The proposition, titled "Mis-designation forces global sub-classicality", proves two things. (a) Some classical schema used in the derivation of ⊥ is lost globally. (b) Global atomic paraconsistency holds only when the designated context contains both α and ¬α.
   - `physics.tex`'s own Reading distinguishes the two cases.
3. **"It is also the largest sound policy (thm:caution:vs)."**
   - Maximality holds only for deterministic verifiers (part (c)).
   - For randomized verifiers, part (b) bounds only a joint probability. The paper itself warns that the conditional reading is false.
4. **"Finitely many bilateral data plus one coherence datum can [fix the classical meanings] (thm:coherence:telltale)."**
   - This holds only among *structural* meanings.
   - Part (d) of the same theorem shows that without structurality BV is not identifiable in the limit at all.
5. **Intro method paragraph.** See (d) below.

### abstract.tex
The 06:31 revision fixed the earlier overclaims. These were eternalism, "settle", the scope of informal identification, and verification. No remaining issue.

### philosophy.tex
1. **The labour table is misplaced.** See R1.
2. **"Coherence among exported tolerances never refutes a tolerance that is too wide … (thm:physics:coherencetol)."**
   - The cited theorem is about common shifts: a coherence-only calibrator must choose ε̂ ≥ β.
   - The up-set fact being invoked is the remark after the theorem (T3 Prop 4.2) and `tab:physics:onesided`.
3. **The judgment-layer list.** The text says "What remains is provably ineliminable (thm:physics:judgment)" and then lists reading, top model *and trusted base*.
   - The theorem covers only the reading and the open world, i.e. (J1) and (J2).
   - `physics.tex` says "(J1) and (J2) cannot be removed" and calls (J3) "the trusted core of any proof checker".
   - This also conflicts with `intro.tex` and `abstract.tex`, which correctly say the layer consists of the reading and the top model.
4. **"The world channel is needed for completeness under ambiguous blame (thm:twotier:blame, prop:twotier:coherenceonly)."**
   - The theorem's title and `prop:twotier:coherenceonly`(b) say that *world or bilateral* evidence is needed, and that one designated denial repairs it.
5. **"Yet no computable learner on the same channels decides Σ₂ truth (thm:coherence:popper)."**
   - The tell-tale concerns propositional meanings. Part (e) of the Popper theorem concerns arithmetic, with text, coherence searches and a Δ₀ oracle.
   - The channels are not the same. The following text admits the difference of domain, but "on the same channels" remains inaccurate.
6. **"This is, as it happens, exactly the convention adopted by Lean's Mathlib …"**
   - The experiment's total semantics uses complex values and the principal square root. Mathlib's `Real.sqrt` of a negative number is 0. Only the division convention x/0=0 coincides.
   - `experiments.tex` says "and the convention of Lean's Mathlib" about the whole total semantics.

### open.tex
All citations are accurate:
- `thm:caution:unstructured` and `thm:informal:escalation`: 2^{K(h*)} escalations;
- `thm:twotier:depth`;
- `thm:physics:judgment` and `prop:physics:gricean`;
- the two conjectures.

---

## (d) Verification and Lean statistics in intro.tex

### Referee counts
**Intro claim:** "Every main result was attacked by two or three independent referees instructed to refute it." This is **false**. Each theory document had two or three referees, but they were assigned *disjoint* sections:
- T1: A covered §§1–3, B covered §§4–6;
- T2: A covered §2, B §3, C §§4–7;
- T3: A covered §§1–2, B §§3–4, C §§5–6;
- T4: A covered §§1–3, B §§4–5, C §§6–7;
- T5: A covered §§1–2, B §§3–6;
- T6: A covered §§0–3, B §§4–5;
- T7: A covered §§1–4, B §§5–6;
- L3: one referee.

So in round 1 each result was attacked by **one** referee. Round 2 re-checked only the changed items, each with one fresh referee.

### "Four false statements and about twenty significant gaps"
- Round-1 fatal issues: T2, T4, T5 and L3 each had one, so 4. Round-1 major issues: 3 + 3 + 4 + 4 + 0 + 0 + 6 = 20 for T1–T7, and L3 had none. These figures match `reverification-round2.md`.
- However, at least eight of the twenty "major" issues were counterexamples to statements as written, so the major issues were not only gaps:
  - T1 A-1: Thm 3.1(b) under the conditional reading, which is `thm:caution:vs`(b);
  - T1 A-2: the gloss of Prop 2.3;
  - T2 A9: Cor 2.8;
  - T3 A1: Thm 2.4 against Def 1.3;
  - T3 B1: Thm 3.9(c), via the rope counterexample;
  - T4 C2: Prop 6.5;
  - T7 A1: the equality in Prop 2.4(c);
  - T7 A2: Prop 3.2;
  - T7 B2: Thm 5.6 optimality, which fails at finite d (`thm:twotier:blame`).
- "Four false statements" therefore understates how many false statements were found.

### The second round
**Intro claim:** "The second round found two further major problems in sec:twotier … and two in glosses of a literature memo. These were repaired too. The sec:twotier repairs were checked by a further referee and by computation."
- **T7.** The two T7 majors (Thm 5.5 and Thm 6.6(e)) were repaired. This is recorded in round 2 of T7's log, and `twotier.tex` tags both "as repaired in two rounds". However, the log ends with "*Items to re-verify after round 2*". Nothing in `research/` records a further referee, so "checked by a further referee" is unsupported.
- **L3.** The two L3 majors (Thm D′'s 'Open' item and §0 #3 gloss; §4.5) were **not** repaired in the memo:
  - `lit/L3-…md` was last modified at 02:07, before round 2 (03:49);
  - it still contains the gloss "Among convergent credences, incoherent ones reach Π₂ and weakly coherent ones do not" (line 46);
  - it still contains the "Open" item about {W_e infinite} (line 336), which the referee said is settled.
- The paper itself states `prop:coherence:costs` only for full syntactic classes, which the referee confirmed are correct. So the paper is fine, but "These were repaired too" is not.

### "The full records are in research/verification/"
- T3 has no file there. Its log says the copy "still has to be made".
- The round-2 repair logs for T7 are in the theory file and in `T7-verification.md`.

### Lean statistics
These match `lean/README.md` and `audit-output.txt`: 14,571 lines in 17 modules (stated as "about 14,600"), 483 + 357 = 840 axiom checks, no `sorry`, toolchain v4.32.0.
- "About fifty paper results": `tab:lean:map` has 49 distinct labels. Two more results carry `\leanok` tags but are missing from the table (`lem:imitation:cautious`, `prop:coherence:adm`). That makes 51.
- "About a third … special cases, weaker statements or variants": 15 of the 49 rows are non-exact, so about a third.

### Lean table versus body tags and README
1. **thm:caution:vs.** The row "thm:caution:vs (b) … special case" contradicts the body tag "(c) thm_3_1_b". `thm_3_1_b` is the deterministic part (c).
2. **thm:simplicity:pricing.** The row "exact for the lower bound; the minimax equality is not formalized" contradicts the body tag `NoAdaptation.minimax_of_transitive`, which proves the minimax value under the group condition. The README rates the value part "weaker".
3. **Two fidelity labels contradict the README and the table's own legend:**
   - `thm:existence:structural`: the table says "exact (fixed signature)", the README says "special case";
   - `thm:informal:paradoxes`: the table says "exact (deterministic learners; one concrete chain)", but by the legend a deterministic-only result is a special case.
4. **Tagging contradicts app-lean.** 28 results in the table carry no `\leanok` tag in the body. They include results the intro lists as machine-checked: tonk, doctrinal, bilateral completeness, the arity theorem, objects and paradoxes, no free export, and the Lipschitz certifier. This sits awkwardly with app-lean's sentence "Theorems carrying the tag … are formalized in the sense of tab:lean:map" and with NOTATION.md's rule "Use \leanok{Name} if the result is formalized".

---

## Already fixed by the 06:31–06:34 revision (not reported)
- **Abstract:**
  - eternalism;
  - "settle" changed to "answer, in part";
  - "Every main result was attacked by independent referees", which is accurate;
  - the identification scope.
- **Intro:**
  - linear cost now limited to cited rules;
  - decidable theories made conditional;
  - collateral loss in `thm:twotier:main`;
  - the kink "proved for parity teachers";
  - eternalism "only at the meta level";
  - the halving-type learner;
  - the Lean fidelity fraction.
- **Philosophy:**
  - the Daniels/independence reading;
  - the list of assumptions and "relies on nothing else";
  - "in our model it is a bounded-gap practice";
  - "Bounded-gap data only bracket it";
  - the answers table removed in favour of `tab:intro:answers`.
