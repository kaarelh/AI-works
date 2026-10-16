# Referee B (formal accuracy and references) on `tracks/philosophy/notes.md`

*Referee report, 2026-10-16. Object: `notes.md` (674 lines, third-run version), its `refs.bib` (89 entries) and its scripts `checks/c4`–`c8` with their saved outputs. My task: check every formal statement (prove or refute, with independent seeded code), re-verify the bibliography, and check consistency with `../../NOTATION-draft.md` and the other threads' records. I read the record in full, both briefs, NOTATION-draft, referee A's report (to avoid duplicating it; I do not repeat its philosophical points), the cited statements in the current records of `sfi`, `fundamentals`, `logic`, `terms` (final records) and `laws`, `shape` (development records), and the saved outputs of scout P's `c1`–`c3`. My code is in `referee_code/` (rb1–rb5 and rb3b; each is seeded with 20261016 or deterministic and writes its `.out` next to itself). It was written from the record's descriptions, without reading the developer's c5, c6, c7 code or c4's Part B code. Where it imports a developer file, the report says exactly what is used and why. No git command was run.*

---

## Verdict

**Major revision, confined to the computed parts of §4.4. The proved statements need only minor fixes.** Nothing is fatal. Every proposition the record proves itself is correct as stated, up to small wording points:
* Props 2.1–2.5, 3.1, 4.1–4.4 and the analogy bound of §5.4;
* the gap closed in Prop 4.3 (the universal quantifier over $E$ in $\theta_{\rm K3}$) is closed correctly.

I re-derived each proof. Where a computation helps, I checked the statement independently:
* the conservation-world numbers, all of them;
* the black-box certification bound, by exact game-tree search for $m=2,3$;
* the flagpole instance counts;
* the answer-distribution identities;
* the geocentric arc and sensitivity figures;
* the counter-model;
* the $q$-constants and the ring estimate.

Every reference to another thread's statement exists under the cited number in the current records and says what the record says it says. Exceptions are a few paraphrases (issues 9–13).

**Two computational results in §4.4 are wrong as stated**, and they need correcting before the paper uses them.
1. **Part C, distances as data.** The table built by `c8` is not a table of least tolerances. It is presented as one, and the record's readings use its entries as thresholds. At a distance tolerance of 1%, the vicarious hypothesis is compatible with the longitude data at **5.12′**, not 6.31′. I found this with my own optimiser and re-checked it with `c8`'s own residual function. So the summary's "needs a longitude tolerance of at least 6.31′" and "below 6.31′ only the ellipse is compatible, in every syntax" are **refuted**. Three more entries of the table are also not minimal (issue 1).
2. **Part A, the law texts.** The "written-down syntax" contains two errors.
   * The S1/S3 *equant* text describes the wrong model. It puts the centre at $2e$ and the equant at $3e$, while the bisected equant has them at $e$ and $2e$. With the same elements, that text's longitudes differ from the bisected equant's by up to 327′. The family it describes has minimax error 3.50′, not 8.17′.
   * The S1/S3 *vicarious* text is a sheared reparametrisation of the computed family.

   The law-text table (1030 and 1060 bits) is therefore wrong; the correct values are 990 and 990 bits (or 960 for the equant). The MAP rows of §4.4 do not change (issue 2).

Every other number I re-computed agrees with the record:
* **Minimax errors.** My own exchange algorithm reproduces `c4`'s five minimax errors to four decimals: 640.7908′, 23.0508′, 8.1653′, 1.4127′, 1.0733′. The circle's value is exact.
* **Occam factors.**
  * The circle's at 720′ is exactly 20.929 bits (c4: 20.93).
  * Hit-or-miss estimates in my own adaptive boxes agree with `c4` to within 0.06 bits in six further cases (eight runs). Three of these are the cases `c4b` could not finish: the ellipse and the eccentric at 720′, the equant at 120′ (issue 4).
* **Part B, K3 in geocentric data.**
  * The geocentric minimax errors 0.6266′ and 0.6318′ are reproduced.
  * What K3 saves agrees with `c4` to within 0.07 bits at 8′, 4′, 2′ and 1′, from an independent hit-and-run on the linearised region.

**References.** The shared WebSearch budget of this session was exhausted after my seventh search (the tool returned "budget used up, limit 200 per turn, shared by every agent"). So I re-verified only 7 of the 89 entries by WebSearch: Craig 1953 and 1956, Kleene 1952 (pages 27–66 confirmed), Craig–Vaught 1958, Putnam 1965, Ramsey 1931 (pages not confirmable) and Hempel 1958. All seven agree with `refs.bib`. The other 82 still need a WebSearch pass at revision (issue 14). From my own knowledge, without a search, I flag four fields to check.

Issues are numbered 1–3 (major) and 4–17 (minor).

---

## Major issues

### 1. (Major) §0, §4.4 Part C, §9: `c8`'s table is not a table of least tolerances; the 6.31′ threshold is refuted

**Claims.**
* §0: "With distances as data at relative tolerance 1%, the vicarious hypothesis needs a longitude tolerance of at least 6.31′ (2.01′ at 2%, 23.7′ at 0.2%) … so below 6.31′ only the ellipse is compatible, in every syntax."
* §4.4 Part C, reading 2: "for δ < 6.31′ the ellipse is the only compatible form in the pool, in every syntax."
* §9 row §4.4 C: "the vicarious hypothesis needs longitude tolerance ≥ 6.31′".

**Problem.** `c8` computes each entry by local sequential LP from a handful of starts. Its own docstring and §4.4 say so: "upper bounds witnessed by explicit elements … minimality is not proved". An upper bound on the least tolerance cannot support "needs at least" or "below … only the ellipse is compatible". And the bound is in fact not tight.

My method: an exchange algorithm with SLSQP on active sets of longitude and distance constraints, from 7–8 starts per cell (`rb3b`). It finds strictly better feasible elements in four cells. **Each solution was re-checked with `c8`'s own `data()` and `residuals()` functions.** My elements were moved into `c8`'s frame by the measured constant longitude offset (spread $1.4\times10^{-14}$ rad); distances agree to $4\times10^{-16}$ AU.

| form, τ | `c8` table | found here (max dlon / max dr/r by `c8`'s code) | elements (c8's frame) |
|---|---|---|---|
| vicarious, 1% | 6.31′ | **5.119′** / 1.00000% | e1 = 0.102836, e2 = 0.083797, w = −1.335871, L = −0.882335, n = 0.009146, scale 1.525097 |
| vicarious, 0.1% | 98.06′ | **94.954′** / 0.10000% | e1 = 0.092990, e2 = 0.066395 |
| vicarious, 0.05% | 146.73′ | **132.042′** / 0.05000% | e1 = 0.092988, e2 = 0.055420 |
| eccentric, 5% | 189.92′ | **150.729′** / 5.00000% | e = 0.142275 |

**[computed: `referee_code/rb3b_distances.out`]** In the other cells my values agree with `c8` to the printed precision:
* vicarious: 1.41′ (5%), 2.006′ (2%), 6.948′ (0.5%), 23.735′ (0.2%);
* eccentric: 252.45′, 286.70′, 305.33′, and infeasible at 0.2%;
* ellipse: `rb3`'s `dist` part finds that at its longitude minimax the ellipse needs only a 0.0153% distance tolerance, consistent with `c8`'s claim that it fits both kinds of data at 1.07′ down to τ = 0.05%;
* equant: at its longitude minimax it needs 0.2487%, consistent with `c8`'s "8.17′ down to 0.5%, infeasible at 0.2%".

My new cells are also monotone in τ: 2.01′, 3.54′, 5.12′, 5.97′, 6.95′ at τ = 2%, 1.5%, 1%, 0.75%, 0.5%.

**What survives.** The qualitative point survives: at τ = 1% the vicarious hypothesis is eliminated somewhere around 5′ or below, while the ellipse survives to 1.07′. The specific threshold does not. Neither 6.31′ nor my 5.12′ is proved minimal. 5.12′ is the best value either search has found.

**Fix.**
* Replace 6.31′ by 5.12′ throughout (§0, §4.4 Part C table and readings, §9). Replace 98.06′ by 94.95′, 146.73′ by 132.04′, and the eccentric's 189.92′ by 150.73′. Also replace "its longitude error jumps to 190′ at τ = 5%" by "to at most 151′".
* State every entry as "the least tolerance found (an upper bound on the least tolerance; witnessed by the printed elements)". Print the witnessing elements in the script.
* Rephrase the readings as "for δ below the vicarious hypothesis's least tolerance, which is at most 5.12′ and was not found lower by two independent searches, only the ellipse is compatible". Alternatively, prove a lower bound, for instance with interval arithmetic over a covering of the element box.
* Add the extra starts that `rb3b` uses to `c8`: perturbed minimax elements, the previous τ's optimum, the equant-like start.

### 2. (Major) §4.4 "The written-down syntax" and table A3: the S1/S3 equant text describes a different model, and the S1/S3 vicarious text a sheared one

**Claim.** "Law texts (written out as s-expressions in the script …)" and the table "law text (bits)": S1 equant 1030, vicarious 1060; S3 the same. §4.4 compares these texts with the fits and Occam factors of the forms.

**Problem.** `c4` builds both S1 texts with the helper `eqv_S1(X, Y)`. It writes the equant distance as `(+ X Y)` and the centre–equant distance as `Y`, so the centre sits at distance `X`. It is then called as:
* `eqv_S1((* 2 e), e)` for the equant. The text then has the centre at $2e$ and the equant at $3e$. The bisected equant of `c4`'s numerical model, of its S2 text and of §4.3 has the centre at $e$ and the equant at $2e$.
* `eqv_S1((+ e1 e2), e2)` for the vicarious hypothesis. The text then has the centre at $e_1+e_2$ and the equant at $e_1+2e_2$, against $e_1$ and $e_1+e_2$ in the model.

`rb2` evaluates `c4`'s own texts with an independent s-expression interpreter (existential quantifiers solved numerically). It compares them with geometric implementations of the five forms at 40 random (elements, time) points per cell. **[computed: `referee_code/rb2_law_texts.out`]**
* **Correct texts (differences ≤ 7×10⁻¹³ degrees):** the circle, the eccentric and the ellipse in all three syntaxes; the equant and the vicarious hypothesis in S2.
* **The S1/S3 equant text** differs from the bisected equant by up to 19.6° at random elements, and by up to 327′ at Mars's $e=0.0934$. It agrees to 2.5×10⁻¹⁴ degrees with the vicarious form with centre $2e$ and equant $3e$.
* **The S1/S3 vicarious text** agrees to 7.6×10⁻¹⁴ degrees with the vicarious form with centre $e_1+e_2$ and equant $e_1+2e_2$.
* **The "$2e/3e$" family** has minimax error **3.5039′** on the 1580–1600 data (`rb3` fit), not 8.17′. So in S1 and S3 the text called "equant" would survive down to about 3.5′.
* **Token counts.** My own counter reproduces every count in table A3: 31, 89, 206, 212, 109 and 75 tokens; alphabets of 31, 34 and 32 symbols.
* **Corrected texts.**
  * Equant `eqv_S1(e, e)`: 198 tokens = **990 bits**, or 192 tokens = **960 bits** with the equant distance written `(* 2 (e b))`. Both checked against the geometry.
  * Vicarious `eqv_S1(e1, e2)`: 212 − 14 = **198 tokens = 990 bits**. This is by counting: the doubled `e2` subterm, 7 tokens, occurs twice.

**Consequences.**
* The MAP rows of §4.4 do not change. In S1 and S3 the equant and the vicarious hypothesis are never MAP or runner-up: with 990 bits they lose to the ellipse by more than 400 bits. Still, the S1/S3 columns of tables A3–A5 are internally inconsistent: they attach the bisected equant's fit and Occam factor to a text that describes another model.
* The vicarious reparametrisation has unit Jacobian. It is harmless wherever the compatible region lies inside both element boxes. At 720′, though, the region contains model points with $e_1<e_2$, which the S1 parametrisation cannot reach.

**Fix.**
* Call `eqv_S1(el("e"), el("e"))` and `eqv_S1(el("e1"), el("e2"))`.
* Re-run Part A, tables A3–A5.
* Correct the law-text table: S1/S3 equant 990 (or 960), vicarious 990.
* Correct the text-difference rows of A5: S1 elli−vica −445, elli−equa −445, equa−ecce 545; S3 likewise with the ellipse at 260.
* Add `rb2`'s faithfulness test (each text evaluated against the numerical model) to `c4`'s self-checks. The assertion that every atom lies in the alphabet does not catch this kind of error.

### 3. (Major) §0, §4.4 reading 2, "What the data decide and what the syntax decides": the stated separation of scales fails for the decisive S2 pair

**Claim.** "Law-text differences are 100–800 bits (c4 table A5), an order of magnitude larger than any Occam-factor difference. So the sequence of preferred theories is set by the syntax." The summary says the same: "the law texts differ by 100–800 bits".

**Problem.** Table A5 omits one pair: the S2 vicarious text minus the S2 equant text, 468 − 450 = **18 bits**. That pair is the one that decides the rows of S2's "historical sequence" at 20′–9′, where the MAP is the equant. There the Occam-factor difference between the same two forms runs from +2.1 bits (20′) to −5.6 bits (9′: 51.78 against 57.34). The margin falls to 12.4 bits at 9′, as table A4's 0.00018 shows. So in the one syntax whose MAP sequence §0 calls "the full historical sequence", the text and data contributions to the decisive comparison are of the same order. Two further points:
* S2's equant-against-eccentric difference is 108 bits.
* After issue 2's correction, the S1/S3 equant and vicarious texts have equal length (or differ by 30 bits with the 960-bit equant text). Both lose to the ellipse by more than 400 bits, so this pair decides nothing there.

The conclusion survives as an arithmetic fact: the text difference still decides every S2 row. The stated reason, "an order of magnitude larger than *any* Occam-factor difference", is false. And it is the step from which §4.4 reading 2 draws its philosophical point.

**Fix.**
* Add the vica−equa column to A5 (S1/S3 0 after the correction, S2 18).
* Replace the sentence by: "Law-text differences are 100–800 bits for every pair except the S2 equant and vicarious texts (18 bits); there, at 20′–9′, the Occam factors move the margin by up to 6 bits, but the text difference still decides."
* Referee A's issue 1, on the guaranteed-tolerance regime, bears on the same reading. The two fixes are independent.

---

## Minor issues

### 4. §4.4 "Cross-check of the volumes": the three missing c4b cases, now done independently

`c4b` did not obtain the ellipse and the eccentric at 720′, nor the equant at 120′; §4.4 lists them as "not cross-checked". `rb3` estimates them by hit-or-miss in boxes. The boxes come from an own explorer, a uniform random walk inside the region, and grow when hits reach the outer 2% of a face. **[computed: `referee_code/rb3_mars_pool.out`]**

| form, δ | `rb3` | `c4` |
|---|---|---|
| ellipse, 720′ (explored box) | 21.12 ± 0.03 | 21.18 ± 0.03 |
| ellipse, 720′ (w over its full range, 4090 hits) | 21.16 ± 0.02 | 21.18 ± 0.03 |
| eccentric, 720′ | 20.19 ± 0.03 (explored box already spans all of w) | 20.24 ± 0.03 |
| eccentric, 720′ (w over its full range, 4126 hits) | 20.21 ± 0.02 | 20.24 ± 0.03 |
| equant, 720′ (w over its full range, 4062 hits) | 21.17 ± 0.02 | 21.20 ± 0.03 |
| equant, 120′ | 31.72 ± 0.03 | 31.70 ± 0.03 |
| ellipse, 120′ | 31.69 ± 0.03 | 31.63 ± 0.03 |
| ellipse, 60′ | 35.67 ± 0.03 | 35.68 ± 0.03 |
| circle, 720′ (exact one-dimensional integral) | 20.929 | 20.93 ± 0.02 |

**A trap for any box sampler at 720′.** The circle fits to 640.8′ < 720′, so every apsidal angle $w$ is compatible for small $e$. With $w$ opposite the true perihelion, $e$ up to about 0.011 is compatible (checked directly in `rb3`). My first, explored box for the ellipse covered only 4.6 of the $2\pi$ radians of $w$, so it missed this sliver. The full-range rerun (21.16 ± 0.02) shows the sliver's effect is within the noise. `c4`'s parallelepiped at 720′ spans 6.5 rad in $w$ (table A2).

All eight runs agree with `c4` to within 0.06 bits, and all but the ellipse at 120′ (0.06) to within 0.03 bits. The record should cite the three formerly missing cases as cross-checked by independent code, and mention the polar structure of the 720′ region, where small $e$ allows every $w$, as a trap for box samplers.

### 5. §4.3 and §4.4: the minimax thresholds, now with independent support; say what kind of bound they are

`rb3` finds the five minimax errors with a method different from `c4`'s: exchange on active sets with SLSQP, from least-squares fits at 8 apsidal angles (3 more start pairs for the vicarious hypothesis). It reproduces `c4`'s table A1 to four decimals: 640.7908′ (exact, by one-dimensional convex minimisation), 23.0508′, 8.1653′, 1.4127′, 1.0733′. This is good evidence that they are global minima, but not a proof. §4.3 already says so. The readings in §0 and §4.4 ("the forms drop out … as δ falls below their minimax errors; this is syntax-free"), and Part B's "compatible with the data at every δ ≥ 0.632′", should carry the same status: [computed; upper bounds witnessed by elements; matched by an independent search].

### 6. §4.4 Part B: independent confirmation; one wording point

`rb5` re-implements the geocentric model: Earth in the J2000 ecliptic, Mars in its best heliocentric plane, inclination 1.8828° and node 50.757° reproduced. **[computed: `referee_code/rb5_k3_geocentric.out`]**
* **Minimax errors.** 0.6266′ with ρ free (ρ = 1.523676; the K3 value from the fitted periods is 1.523687) and 0.6318′ with K3. Both as in `c4`.
* **What K3 saves**, from hit-and-run on the linearised compatible polytope (exact chords, whitened, 60,000 samples per δ): 11.27–11.32, 12.28–12.32, 13.32–13.35 and 14.69–14.71 bits at 8′, 4′, 2′ and 1′ over three kernel widths, against `c4`'s 11.28, 12.31, 13.39 and 14.73. The record's figures stand (it quotes 11.3, 12.3, 13.4, 14.7).
* **Linearisation.** The share of linearised samples that are exactly compatible is 0.819, 0.901, 0.958 and 0.968 at 8′, 4′, 2′ and 1′, matching `c4`'s 0.820, 0.895, 0.948 and 0.972.

The shear argument ($V_8/V_9=p_Y(0)$, unit Jacobian) and the odds formula $2^{s(\delta)-|\mathrm{K3}|}$ are correct. One wording point: "K3 does exactly one job: it replaces the size element ρ" (§0) is the reading of Prop 4.4. Prop 4.3 shows that K3 without the other elements has content too, so say "given the other elements, K3 does exactly one job".

### 7. Prop 2.3(a): wording of the tight bound

The statement says "it must query at least $2^m-\binom m{\lfloor m/2\rfloor}$ points on some input, and this many can be necessary". The proof, and §9 ("and that many suffice"), show that this many *suffice*. "Can be necessary" is redundant with the lower bound. Replace it by "and this many suffice, so the bound is exact".

**[computed: `referee_code/rb1_formal.out` (3)]** Exact minimax game-tree search over the explicit set of permutations gives 2 queries for $m=2$ (24 permutations) and 5 for $m=3$ (40,320 permutations), equal to $2^m-\binom m{\lfloor m/2\rfloor}$. For arbitrary maps with $m=2$ (256 maps) it gives 4 = $2^m$. The refutation of scout N2's Prop 5.2(a) stands.

### 8. Props 2.1, 2.4: small statement fixes

* **Prop 2.1(b)** is stated for $J\subseteq[k]$ and calls the difference "the mass of theories that answer $\mathcal Q$ partially through $J$". By Def 2.0 a partial answer needs $J\subsetneq[k]$. For $J=[k]$ the difference is $\mathrm{Un}_D(\mathcal Q)$ (and $\Bel_D(\bigvee_i\varphi_i)=1$). Restrict to $\emptyset\ne J\subsetneq[k]$, or add the case.
* **Prop 2.4, last sentence.** "On every $D$ consistent with $f_x$" should read "on every $D$ with $f_x\supseteq D$", which is what $\mu_g(D)=1$ needs. It also needs $f_x$ to be consistent with $B$, which is (H) for $\mu=\delta_x$. The proof is otherwise complete. One detail is worth a clause: the theory machine emits a label only after the tape prefix fixes the part of $\Phi(\omega)$ that $g$ reads.
* **Independent checks.** **[computed: rb1 (4)]** On 279 random finite cases (propositional random theories, random backgrounds and data), Prop 2.1(a) and (b) hold to $4\times10^{-16}$, and Prop 2.5(d)'s Fréchet bound and monotonicity hold exactly. **[computed: rb1 (1)]** Every number quoted in Prop 2.2 and in "Computed [c5]" is reproduced: the gains, the shares, the exact $m=12$ expectations (2415.58 / 3004.85 / 2416.58, share 0.1961; whole cycle 0.2317 and 2.7537 bits per step), the question-answering losses, and N2's run (2643.5 / 3286.4). For $m\le16$ I confirmed $g_t\le\log_2(S/C)+1$ and its monotonicity for $t\le C/2$.

### 9. §1.4, §1.7: hypotheses and statuses of cited results

* **§1.4 item 1** cites "`sfi` Prop 7.6 [proved there]" for "the diagonal separations under time bounds come from free deduction". In the final `sfi` record only parts (a) and (b) are proved; (c) is a proof sketch. Write "`sfi` Prop 7.6(a), (b)".
* **§1.4 item 1** also gives the axiom-side time-penalty equivalence only one-tape (`sfi` Thm 3.4, under (S$_{\rm tape}$)). The coin-free version is `sfi` Thm 7.1, under (S). Cite both.
* **§1.7 item 4** omits the hypothesis of `sfi` Props 6.3–6.5: $\mathcal L\supseteq\mathcal L_{\rm ar}$ and $B$ decidable and consistent with $\Q\subseteq\Cn(B)$. The separation needs arithmetic in the background. Add it.
* **§1.7 item 8** states the hypothesis "a true background $B\supseteq\Q$". `logic` Prop 4.1(b) needs only $B$ decidable and consistent with $\Q\subseteq\Cn(B)$. The stronger hypothesis is harmless; matching the source is better.
* **§1.7 item 5 and §2.3(c)** cite "AI-paper `thm:univ:omega`", a LaTeX label. NOTATION §0 asks for printed numbers. `fundamentals` (Prop 8.5, final record) calls the Bayesian ω-gap "AI-paper Thm 3.9". Check that number and use it.

### 10. §1.6 step 3: one paraphrase of `terms` is stronger than the theorem

"An observational theory that uses unnamed objects must assert an observational sentence false of every named object (`terms` Thm 5.1, …, Prop 9.1)." `terms` Thm 8.1(iv) and Thm 5.1 say less: such a theory "must prove some $\{\mathtt e,\mathtt s_0,\mathtt s_1\}$-sentence false in the named structure". Only for the theory built there is that sentence $\exists z\,\mathtt s_1\mathtt s_1z=z$, "true of no named object" (Prop 9.1(b)). A sentence false in the structure need not have the form "something that no named object satisfies". Use `terms`' wording. The rest of §1.6's summary of `terms` Thm 8.1 matches the final `terms` record.

### 11. §3.3, §3.4, §5.4 L12: cited hypotheses missing or mis-booked

* **§3.3** says `laws` Prop 7.1 shows that the successor theory "refutes the exact old law". Prop 7.1(c) needs $\eta Pa\ne0$. Add it.
* **§3.4.** Is the Copernicus gain the unification term of `laws` Prop 5.8(c)? The record's own hedge ("not checked in detail") is warranted. `laws` §5.3 books Copernicus's $\sum_pa_p$ bits as *total* support against free-phase Ptolemy, that is, $I(h;D)$. Prop 5.8(c)'s term is $U=k_C$ for two data sets sharing a $k_C$-bit constant. For $n$ planets that share the Sun's parameter, the natural multi-set generalisation gives about $(n-1)k_C$. That equals $\sum_pa_p-k_C$ only if each coincidence costs $a_p\approx k_C$. State which quantity is meant, or drop the identification.
* **§5.4 L12** says checking instances "of an arithmetical conjecture leaves $\Bel(\forall x\,P(x))$ at its prior value for every $N$ (`logic` Prop 4.6)". `logic` Prop 4.6 is for $\Delta_0$ formulas $P$, or more generally instances that $B$ decides. For a $\Pi_1$ property $P$ the instances are not $B$-decided and do carry information. Write "of a decidable ($\Delta_0$) property".

### 12. §1.4 item 2, §5.1(b): `shape`'s clause bound is restated with an undefined symbol and a stronger hypothesis

"At least $A_d2^{d-1}$ when every derived equation has weight $d\ge3$." The bound is `shape` Cor 2.7(a): $a_*2^{d_*-1}$, where $d_*\ge3$ is the *least* weight of a nonzero derived equation and $a_*$ is the number of circuits of that weight. It does not need every derived equation to have the same weight; that is the simplex family, Cor 2.8. Define the symbol, or use `shape`'s. Every other `shape` statement the record uses checks out against the `shape` record: Thm 1.11, 1.12, 2.6, Cor 2.7(c), 2.8, Prop 3.1, Thm 3.6 (exponent $2^{\Omega(m^{\varepsilon/3})}$, given GKRS 2019), Prop 4.2, Thm 4.3 (factor ≤ 9, ≤ 3 for the chain encoding), Prop 5.1, Thm 5.2, Thm 6.2.

### 13. Smaller formal and numerical points

* **Prop 4.1.** For a second-order Ramsey sentence, "proves" should be "entails" (semantic consequence). Part (b) is proved semantically anyway.
* **Prop 4.3(a) and the bridge.** $\theta_{\rm K3}$, or $B$, should also contain the true sentence $0\le e<1\to a(1-e\cos E)>0$. It ensures $x(\mathrm{Ea},t)\ne0$, so that $-\mathrm{dir}_g(\mathrm{Sun},t)=x(\mathrm{Ea},t)/|x(\mathrm{Ea},t)|$ in a non-standard model. The record's "enough true analysis" covers this; naming it makes the isolation of $B$'s role in $\theta_{\rm K3}$ complete. **[computed: rb4 (3)]** Over 300 random K12 + K3 models (outer planet, Earth in the ecliptic, Mars's plane random), the largest angle of Mars from opposition over 20 years is at least 175° in every model. Over 50 random $\mathcal M_0$ models it never exceeds $6\times10^{-14}$°.
* **c7.** **[computed: rb4 (1)]** I reproduce every figure:
  * the arc percentiles 0.11 / 9.52 / 46.68 / 90.22 / 133.91 / 170.34 / 179.96°;
  * day 0 at 47.6180°;
  * monotone sweep on 60 seeded days, with the great-circle identity to $9\times10^{-15}$ rad;
  * sensitivity median 969, 95th percentile 2676, maximum 3556′ per unit ρ;
  * the crude bits 9.80 / 10.80 / 11.80.

  c7's "$\mathcal M_0$ … within $1.2\times10^{-6}$° (rounding)" is $10^{-14}$° in exact arithmetic (rb4 (2)). It is cosmetic; say "to rounding".
* **§4.3.** The Saturn range $q=1.0013$–$1.0019$ is for windows ≥ 30 yr, as for Jupiter; the 12-year fit gives 1.00487 (scout P `c3`). Say so. All other §4.3 and §4.5 figures match scout P's saved outputs:
  * the window maxima for Mercury, Mars, Jupiter, Saturn and the Moon;
  * 575.4″ per century;
  * 910 yr / 18.3′ and 900 yr / 43.8′.

  **[computed: rb1 (6)]** Independently: $1+m_J/M=1.00095$; $1+m_S/M=1.00029$; ring factor $g(\alpha=0.5445)=1.3093$, so Saturn's ring estimate is 1.00154, of which Jupiter supplies $1.250\times10^{-3}$.
* **§4.5 item 2, sourcing.** 5025.6″ is not "the difference 5599.74 − 574.1, not checked against a source". From memory (not search-verified here), it is the general precession used in Clemence's decomposition (5025.645″ per century). Then $5557.18-5025.645=531.54$″ is the planetary part, derivable from Clemence's own figures rather than from course material. Verify against Clemence 1947 or arXiv 1008.1811 and cite accordingly.
* **§6.2.** "The only proper one (up to affine change)": a constant score is also proper. Say "the only strictly proper local scoring rule on more than two outcomes, up to positive affine transformation".
* **§6.1 / `laws` Rem 4.4.** **[computed: rb1 (2)]** $\Ex|S_{100}|=7.9589\varepsilon$ and $\Ex|S_{1000}|=25.2250\varepsilon$ exactly, as quoted.
* **Prop 3.1(b).** Define the cost precisely: the number of closed instances of the universally quantified conjuncts ($\Lambda_s$ has two). The minimum is then the semantic (Herbrand) count the proof uses. **[computed: rb1 (5)]** Own exact rational linear algebra gives:
  * shadow data ($u=2,3$): 1, 2, 2, 1;
  * reference shadow: 1, 0, 1, 0;
  * height: 0, 1, 0, 1.

  These are as stated. `c6`'s docstring says "t = cot(elevation)" while the record uses the tangent; harmless but inconsistent.

### 14. References: re-verification incomplete in this report; four fields to check

* **Re-verified by WebSearch here, all agreeing with `refs.bib`:**
  * craig1953axiomatizability: JSL 18(1):30–32, doi 10.2307/2266324;
  * craig1956replacement: Phil. Rev. 65(1):38–55; JSL review 22(3):317–318;
  * kleene1952finite: pp. 27–66 per the JSL reviews; the bibliography is pp. 67–68; Kleene does not treat identity;
  * craigvaught1958finite: JSL 23(3):289–308, "for 1958, published 1959";
  * putnam1965craig: J. Phil. 62(10):251–260, doi 10.2307/2023298; reprinted in *Mathematics, Matter and Method*, ch. 14;
  * hempel1958theoretician: Minnesota Studies II, pp. 37–98; PhilArchive's 173–226 is the *Aspects* reprint;
  * ramsey1931theories: the volume and date confirmed, pp. 212–236 not confirmable, as the entry's own comment already says.
* **Not re-verified here (82 entries).** The session's WebSearch budget was exhausted. These must be re-checked at revision; this report does not vouch for them.
* **Fields to check, from my own knowledge (not search-verified):**
  * woodward2014simplicity has no pages (I believe BJPS 65(1):91–123);
  * putnam1963degree has no pages (I believe pp. 761–783 of the Schilpp volume);
  * lewis1970define omits the issue number, although its own comment confirms 67(13);
  * kepler1992new omits the translator (William H. Donahue).
* **Keys.** Every key cited in `notes.md` is in `refs.bib` (script check). 26 entries are in `refs.bib` but cited nowhere in `notes.md`, for instance carnap1950logical, lewis1994humean, woodward2014simplicity, statman1979lower and gold1967language. §7 lists several of them as kept for the paper. The brief allows this, but the paper's bibliography should be built from the keys actually cited.

### 15. Notation (NOTATION-draft)

The record's local symbols clash with global ones in several places. Some clashes fall within one section.
* **λ.** $\lambda(b,t)$ for heliocentric longitude (§4.1), while NOTATION §1 reserves λ for the steepness exponent "**only**". §4.2 uses both ("λ-MAP"). Use $\ell$ or $\theta$ for longitudes ($\theta$ is already used in §4.3–4.4).
* **N.** $N$ is the north ecliptic pole (§4.1) and the number of poles (§3.2), while NOTATION §1 sets $N:=2^d$.
* **E.** $E$ is the eccentric anomaly, $E_b$ the elements and $E^-$ a set of numerals, while $E_D$ is the compatibility event (NOTATION §4.1). All four occur in §4.
* **T, π.** In Prop 2.2, $T$ is a number of steps (it is a theory everywhere else). $\pi$ is the permutation and the number π in the same proposition.
* **V, C.** $V_F$ is a volume, while $V$ is the universal machine. $C$ is a weight-class size and the Occam factor; the record already requests $\mathrm{Occ}_F$.
* **Φ.** $\Phi$ is the sampler (§2.4) and the antecedent of $\theta_{\rm K3}$. In `shape` it is an explicit theory.
* **h, s.** $h$ is the height function, while NOTATION §5 makes it a derivation budget. $s$ is the shadow function, K3's saving $s(\delta)$, and a bound variable in the law texts.
* **EP.** `laws` and this record write $\|\mathcal A\|$, while NOTATION §6.4 writes $|\mathcal A|$. Align NOTATION with the records (a cross-thread request).

### 16. Cross-thread consistency: what I checked and found consistent

Every labelled statement the record cites exists in the current records with the cited content, apart from issues 9–12.
* **`sfi` (final):** Thm 2.1 (a)–(c), Prop 2.2, Thm 3.1 (now including $D=\emptyset$), Thm 3.4, Prop 6.1(a), (c) (status "proved"), Props 6.3–6.5, Prop 7.6. `sfi` §17.2 already lists this record's uses and finds them unchanged.
* **`fundamentals` (final):** Prop 2.1, Thm 4.1, Prop 4.3, Thm 4.4, Cor 4.5, Thm 5.1, Prop 8.3, Prop 8.5, Prop 9.1.
* **`logic` (final):** Thm 2.2, Thm 2.9(b), Cor 2.10, Prop 4.1(b), Prop 4.6, Props 5.1–5.2, Thm 5.3.
* **`terms` (final):** Thm 2.1, Lemma 3.1, Thm 3.3, Cor 3.5, Props 4.1, 4.3, Thm 4.6, Prop 4.7, Thm 5.1, 5.3, Thm 6.2, 6.4, 6.5, Rem 6.6, Thm 8.1, Prop 9.1.
* **`laws` (development):** Prop 2.1, Cor 2.2, Props 2.4, 2.5, 3.4, 4.3, Rem 4.4, Def 5.2, Props 5.5(b), 5.8, 5.9, 6.1, 7.1, §3.6, §8, §10 items 1, 2, 4, 6.
* **`shape` (development):** see issue 12.

Two records are not yet final. When `laws` and `shape` publish their final records, the numbers must be re-checked, as the record's own item 10 says. The `laws` cross-check of §4.3 is consistent: `laws`' minimax values are below the least-squares maxima, as here.

### 17. Small points in the Verification log and statuses

* **c4b.** The Verification log says the three missing cases "remain undone". Issue 4 now supplies them; cite `rb3`.
* **§9, row §4.4 C.** "values are upper bounds witnessed by elements, minimality not proved" is right, but it contradicts the row's own statement "needs … ≥ 6.31′". Fix with issue 1.
* **§9, row §5.4 (analogy bound).** "[proved: immediate from the definitions]" is right. It needs only that a program enumerating $T_1$ can be combined with one computing $\tau$; the pair costs $K(T_1)+K(\tau)+c$, by $K(x,y)\le K(x)+K(y)+c$. Fine as it stands.

---

## What I checked and found correct (no change requested)

* **Prop 2.1** (partition of $E_D$), **Prop 2.2** (cycle structure of a uniform random permutation; gain bounds; Stirling; mixture bound), **Prop 2.3(a)** (adversary arguments and the matching strategy), **(b)** (standard), **Prop 2.4** (sampling construction, theory machine, dominance), **Prop 2.5(d)**. Proofs re-derived; numbers re-computed (rb1).
* **Prop 3.1** (a)–(c): the equivalence $\Lambda_h\leftrightarrow\Lambda_s$; the instance counts, with the semantic lower bounds; the conservative expansions; the interventional consequences (rb1 (5)).
* **Prop 4.1** (b): the counter-model by rotating the orbital plane and the phase. **Prop 4.2**: rescaling $a$ preserves directions and enforces K3. **Prop 4.3** (a), (b): Kepler's second law forces $r_M=\kappa r_E$, so the periods are equal and the axes unequal; the transfer to non-standard models through $\theta_{\rm K3}$ is valid with the universal quantifier over $E$; Remarks (i), (ii) are correct, including the inner-planet failure. **Prop 4.4** (a), (b): the open great-circle arc, and the bound δ < α/2 (rb4).
* **§4.4 Part A**:
  * the minimax errors (rb3);
  * the Occam factors in seven cases (rb3; the circle's exactly);
  * the MAP table, from the record's Occam factors and texts: the smallest margin is 12.44 bits (S2, 9′), as "at least $2^{-12}$" says;
  * the K3 arithmetic: 375 − 11.28 = 363.7, 375 − 14.73 = 360.3, and 375/15 to 450/11.3 gives 25–40 bodies;
  * the Elias-gamma remark only increases the decisive S2 margins.
* **§4.4 Part B**: the shear identity, the odds formula, and the numbers to within 0.07 bits (rb5).
* **§6.1** figures, **§4.5** figures, scout P's quoted tables.

---

## Verification log

1. **Restart check.** At the start of this run no `referee-B.md` or `referee_code/` existed in this folder. A skeleton was written first and saved after each major step.
2. **Read in full.**
   * `notes.md` (all 674 lines), `00-brief.md`, `../../00-brief.md`, `../../NOTATION-draft.md`, and `referee-A.md`, to avoid duplication.
   * In the other threads, the statements cited by this record:
     * `sfi/notes-final.md`: Thm 2.1, Prop 2.2, Thm 3.1, Cor 3.2, Thm 3.4, Prop 3.5, Prop 6.1, Lemma 6.3′, Props 6.3–6.5, Prop 7.6, §17;
     * `fundamentals/notes-final.md`: Prop 2.1, Thm 4.1, Props 4.2–4.3, Thm 4.4, Cor 4.5, Thm 5.1, Props 8.3–8.5;
     * `logic/notes-final.md`: Thm 2.2, Thm 2.9, Cor 2.10, Prop 4.1, Prop 4.6;
     * `terms/notes-final.md`: Thm 2.1, Thm 6.5, Rem 6.6, Cor 5.4, Thm 8.1 with "What this does and does not show";
     * `laws/notes.md`: Props 4.3, Rem 4.4, Def 5.4, Prop 5.5, 5.8, 5.9, 6.1, 7.1, §3.6, §10;
     * `shape/notes.md`: Thm 1.11, 1.12, 2.6, Cor 2.7, 2.8, Prop 4.2, Thm 4.3, Thm 3.6, Prop 5.1, Thm 5.2, Thm 6.2.
   * Scout P's saved outputs `c1_kepler_fit.out`, `c3_kepler_constant.out`.
   * `c4_mars_pool.py`: the law texts and the numerical model of Part A, and `c4_mars_pool.out` A1–A5, B. The model was read only to locate the texts; my models were written from geometry.
   * `c8_mars_distances.py`, read after `rb3`'s `dist` part had produced its 5.12′, to re-check that value with c8's own functions.
   * The saved outputs of c4b, c5–c8.
   * I did not read the code of c5, c6, c7 or c4's Part B before writing rb1, rb4 and rb5.
3. **Scripts.** All are in `referee_code/`; numpy 2.4.6, scipy 1.17.1, pyerfa 2.0.1.5 (from the session's scratch library folder, outside the repository), python 3.11.15.
   * `rb1_formal.py` (seed 20261016; run time not recorded, well under the tool's 20-minute limit): Prop 2.2 and c5's numbers; random-walk means; exact game-tree search for Prop 2.3(a) ($m=2,3$; 7,165 memoised states for $m=3$); random finite checks of Props 2.1 and 2.5(d); flagpole instance counts by own Fraction linear algebra; §4.5 constants; c7's crude bits. Output `rb1_formal.out`.
   * `rb2_law_texts.py` (seed 20261016). Imports only `TEXTS`, `K3`, `ALPHABET`, `el`, `eqv_S1`, `Lt`, `Mt` from `../checks/c4_mars_pool.py`, the objects under test. It evaluates them with its own interpreter against its own geometric models; recounts tokens; builds and checks corrected texts. Output `rb2_law_texts.out`.
   * `rb3_mars_pool.py` (seed 20261016; parts `fit`, `circle`, `occam`, `occam720`, `dist`, run separately, each appending to `rb3_mars_pool.out`; the fitted elements are saved in `rb3_fits.npy`):
     * the data pipeline: plan94, best plane by SVD in the equatorial frame, own in-plane origin;
     * minimax by an exchange algorithm with SLSQP;
     * the circle exact;
     * hit-or-miss Occam factors in boxes found by an own random-walk explorer, with face-growth;
     * the distance tolerances needed at the longitude minima;
     * constrained minimax for the vicarious hypothesis.

     The `occam720` part was added after I found the polar sliver at 720′ (issue 4). It forces $w$ over its full range. The `fit` part ran first. The normalisation of mirror solutions ($e<0$, $w$ → $-e$, $w+\pi$) used by the later parts, and the `occam720` part, were added afterwards; the fitting code itself was not changed.
   * `rb3b_distances.py` (seed 20261016): constrained minimax for the vicarious hypothesis and the eccentric at 10 values of τ, re-checked with `c8`'s own `data()` and `residuals()`. Output `rb3b_distances.out`.
   * `rb4_geocentric.py` (deterministic, plus seeded test days): Prop 4.4(b) and c7 (1) from plan94 with own code; c7 (2); Prop 4.3(a) on random K12 + K3 models. Output `rb4_geocentric.out`.
   * `rb5_k3_geocentric.py` (seed 20261016): the 9- and 8-element geocentric minimax fits; hit-and-run on the linearised polytope; kernel density of $y$ at 0; the exact-compatibility share. Output `rb5_k3_geocentric.out`.
4. **WebSearch.** 8 searches were attempted. The 8th, for lewis1970define, returned "budget used up (limit: 200 WebSearch calls per turn, shared by every agent in it)", and no further search was possible in this run. Results of the 7 completed searches are in issue 14. Sources consulted:
   * https://en.wikipedia.org/wiki/Craig%27s_theorem
   * https://philpapers.org/rec/WROA
   * the Cambridge JSL review listings for Kleene 1952 and Craig–Vaught 1958
   * https://richardzach.org/?p=2714
   * https://arxiv.org/pdf/1712.01713
   * https://www.cambridge.org/core/books/mathematics-matter-and-method/craigs-theorem/D58A7D5D6A86833AF3D792AB2566768B
   * https://plato.stanford.edu/Entries/ramsey/
   * https://conservancy.umn.edu/handle/11299/184621
   * https://philpapers.org/sep/hempel/
5. **Bibliography keys.** An inline script compared the keys cited in `notes.md` with those in `refs.bib`: none missing, 26 uncited (issue 14).
6. **Repository state.** Files written: `referee-B.md` and `referee_code/` (rb1–rb5, rb3b, their `.out` files, `rb3_fits.npy`). Nothing else was written. Logs of the background runs are in the session scratchpad. No git command was run.
