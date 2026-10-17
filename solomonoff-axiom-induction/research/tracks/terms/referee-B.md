# Referee B (computation and counterexamples) for thread `terms`

*Adversarial referee report on `notes.md` (this folder, 678 lines) and its scripts in `checks/`. Written 2026-10-16.*
* *Referee code:* `referee_code/rb_logic.py` (shared syntax and derivation checker) and `referee_code/rb1_*.py` … `rb8_*.py`. Each script is seeded or deterministic and writes `<name>.out` next to itself.
* *Independence:* none of these scripts imports or copies the developer's code. Every construction was rebuilt from the text of `notes.md`, with a different syntax (nested tuples), a different derivation checker, different machines and different languages. `rb2` imports `rb1`; both are referee B's own.
* *Other files:* `referee_code/rA1_alt_output_rule.*` belong to referee A and were not touched.
* *Numbering:* results are numbered as in `notes.md`. Issues are numbered B1, B2, … to keep them apart from referee A's M1, M2, m1, ….
* *Repository state:* no git command that changes repository state was run.

## Verdict

**The computational record is sound. Every number in `notes.md` that comes from a script was reproduced. The core constructions also work when rebuilt independently from the text. There is no fatal issue.**

There is one **major** issue, **B1**, the same gap that referee A reports as M1, found independently with different code and different machines:
* The construction written in the proof of Prop 4.7 is wrong as stated.
* Its start rule gives wrong verdicts on 511 of 511 start pairs for two fresh alternating machines, and on 170 of 511 for a third.
* Its output rule with a free certificate variable makes the theory **inconsistent** for a legal machine. The two contradictory derivations were built and checked.
* The developer's script uses a different construction, and that construction passes every test.

The minor issues are:
* **B2.** In the observational translation, a bound variable of $\theta_2$ captures the output rule's variable $z$.
* **B3.** The factoring predicate of Prop 7.2 pays only when $(n-1)(m-1)>1$. The computed minima are $\min(nm,n+m)$.
* **B4.** Two of the 15 sentences of Prop 9.3 are redundant.
* **B5.** Example 3.4 depends on a script that needs more than 12 GB of memory. Its headline numbers follow from closed forms, which were checked.
* **B6.** The window bound $n-1$ in Thm 5.3 is attained, so the text's "$|u|<n$" is just off by one.
* **B7.** Gaps in the coverage of the developer's tests: three clauses of the constructions were never exercised. The referee's tests exercise them, and they pass.

What was attacked and survived:
* Thm 2.1(d), with three backgrounds, including two with observational consequences.
* Lemma 4.2 on nested pairs.
* Lemma 4.5 and Thm 4.6, on a decider and a verifier compiled from the text. Disjointness was checked by brute force on 4.4 million pairs, and semantics on all boxes tested.
* Derivations in both versions, and the model $(\mathfrak T,C^{\mathfrak T})$ on about 1.36 million instances.
* Remark 4.8.
* Lemma 5.2, by an exact Ehrenfeucht–Fraïssé game solver.
* Thm 5.3, on three fresh languages and 3000 random automata.
* Lemma 6.1, by games, together with the tightness of $2^k\max(q,1)$.
* Prop 6.3's counter, evaluated as written.
* Props 7.2 and 9.3.
* Example 3.4's numbers, in closed form.

## Issues

### Major

**B1. Prop 4.7: the construction in the text fails in two ways. The script's construction is correct. (Independent confirmation of referee A's M1.)**
* *Where.* §4.5, proof of Prop 4.7: "Compile as in Lemma 4.5 with phases 2 and 3 only (no certificate) … At start pairs this gives the output rules, with $R:=X$; the rest of the proof of Thm 4.6(i)–(iii) applies." The output rules of Def 4.4 are $\forall x\forall z\,(C(x,\eta\,{\rm st}(s)\,z)\to R(x)^{\pm})$.
* *Evidence 1: the start rule* (computed: `rb1_two_stack.out`, Part C). Prop 4.7 was compiled exactly as written. The start rule is Lemma 4.5's, which pushes ${\rm blk}(\#)$ onto $r$; only phases 2 and 3 follow. Three fresh one-tape alternating machines were used:
  * E11: existential, with a left move, for "contains 11";
  * U10: universal, for "every 1 is immediately followed by 0";
  * EVENJ: deterministic, for even length.

  The least-fixed-point membership of the start pairs $(x,\eta\,{\rm st}(s))$, $|x|\le8$, disagrees with the specification for **511/511** words (E11), **511/511** (U10) and **170/511** (EVENJ). Phase 2 reads the bits of ${\rm blk}(\#)$ as raw input letters. The record's own self-check 7 found this in the script, but the text was never corrected.
* *Evidence 2: the output rule with $z$* (computed: same file, Part C). The start rule was then corrected to the script's version, $(Z;c(s)Y)\Rightarrow(Z;c(s_2){\rm blk}(\#)Y)$. With the output rules of Def 4.4, phase 3 rewinds any block-aligned $z$ onto the tape, so the machine runs on $z'\#x$, and nothing in Prop 4.7's hypotheses constrains it there.
  * EVENJ's start state accepts when it reads $0$ or $1$ instead of $\#$. That is legal, because every start tape begins with $\#$.
  * For $|x|\le4$, 20 start pairs $(x,0\,{\rm st}(s)\,{\rm blk}(a))$ lie in $C^{\mathfrak T}$ although $x$ has odd length.
  * The referee's generator built a derivation of $R(t_0)$ (54 lines, $z={\rm blk}(0)=01$) and one of $\neg R(t_0)$ (59 lines). The independent checker `rb_logic.check` accepted both, so **the theory is inconsistent.**
  * E11 and U10 get stuck on every junk prefix, so they give 0 such pairs. The script's own machine behaves the same way, which is why the developer's checks could not see the problem. Referee A observed the same thing with a different added transition.
* *What passes.* Two changes give 0 wrong verdicts on all three machines: the separator on $l$, and the **exact** output rules $\forall x\,(C(x,\eta\,{\rm st}(s))\to R(x)^{\pm})$, with $\mathrm{Std}(x)$ added in the observational version. With these changes:
  * every datum with $|x|\le6$ (127 per machine) has a derivation in the relation version and in the $\theta_2$/Std version, and every derivation checks;
  * the largest line grows linearly in $|x|$, by 12 symbols per letter (relation version) and 20 (observational version) for E11 and U10, and by 8 and 16 for EVENJ, as the (a1) budget needs.
* *Fix.* As in referee A's M1. Write the start rule $(Z;c(s)Y)\Rightarrow(Z;c(s_2){\rm blk}(\#)Y)$ and the exact output rules into the proof. Define $\mathcal R$ from the exact start pairs. Say explicitly that the free-$z$ output rule of Def 4.4 is used only with a certificate phase, which consumes $z$.
* *Scope.* Thm 4.6 and Prop 9.1 are not affected, because there phase 0 consumes $z$. This was checked on V11, whose certificates are arbitrary words (Part A: 16129 pairs, 0 mismatches). Prop 4.7 feeds the (a1) column of Cor 5.4, Thm 8.1(iv) and Table 7.4; those stand once the proof is restated.

### Minor

**B2. Bound-variable capture in the observational translation of the output rules.**
* *Where.* Lemma 4.2 defines $\theta_2(a,b):=\forall z\,(\mathrm{Pair}(z)\to\cdots\to R(z))$. Def 4.4's output rules quantify a variable that is also called $z$: $\forall x\forall z\,(C(x,0\,{\rm st}(s)\,z)\to R(x))$. $T^O_P$ is defined as "replace each atom $C(a,b)$ by $\theta_2(a,b)$".
* *Problem.* Done literally, the inner $\forall z$ of $\theta_2$ captures the certificate variable. The translated output rule then says something else, and $\mathsf K$'s A4 cannot instantiate the outer $z$ inside it.
* *Evidence* (computed: `rb1_two_stack.out`, Part D). With $\theta_2$'s bound variable named $z$, as in the text, the generator's derivation of $R(t_{0011})$ breaks at the MP step that uses the output rule ("builder MP mismatch"). With a fresh bound variable, as in the developer's scripts (`theta2` uses `w`), every derivation checks.
* *Fix.* Define $\theta_2$ with a variable that occurs nowhere else, for example $\forall p\,(\mathrm{Pair}(p)\to\cdots)$, or say "with a fresh bound variable".

**B3. Prop 7.2 and Table 7.4: the factoring predicate pays only when $(n-1)(m-1)>1$.**
* *Where.*
  * Table 7.4, row "atom-to-atom implication theories": "**yes**: $nm$ vs $n+m$".
  * The reading after Prop 7.2, that a new concept "pays in restricted inference formats".
  * The thread brief, which says the factoring predicate "saves $nm-(n+m)$ implications".
* *Evidence* (computed: `rb6_monadic_factoring.out`, Part D). The search runs exhaustively, in increasing size, over all atom-to-atom implication theories.
  * Without $X$, the least theory equivalent to $T_{\rm dir}$ has exactly $nm$ members for $(n,m)\in\{(1,1),(1,2),(2,1),(2,2),(1,3),(3,1),(2,3),(3,2),(1,4)\}$. This confirms (b).
  * When the theory may also use $X$, and must have the same $\{A,B\}$-consequences as $T_{\rm dir}$, the least sizes are 2, 3, 4 and 5 for $(n,m)=(1,2),(1,3),(2,2),(2,3)$. That is $\min(nm,n+m)$ in each case.
  * So $X$ saves nothing for $n=1$, $m=1$ or $n=m=2$.
* *Proof of the general value (a few lines, for the record).*
  * In such a theory every path from $A_i$ to $B_j$ is either a direct edge or $A_i\to X\to B_j$.
  * Any other path would give one of three consequences that $T_{\rm dir}$ lacks, by Prop 7.2(b)'s one-element models: $A_i\to A_{i'}$, $B_j\to B_{j'}$, or $B_j\to A_i$. This includes paths through $X$, such as $A_{i'}\to X\to A_i$.
  * Let $I=\{i:A_i\to X\}$ and $J=\{j:X\to B_j\}$. Every pair outside $I\times J$ needs its own edge, so the theory has at least $|I|+|J|+nm-|I||J|$ members.
  * This bilinear function of $(|I|,|J|)$ is minimised at a corner of $[0,n]\times[0,m]$, which gives $\min(nm,n+m)$.
* *Fix.* In Table 7.4, write "yes when $(n-1)(m-1)>1$: $\min(nm,n+m)$ vs $nm$". Optionally add the one-line proof as Prop 7.2(d). Read the brief's "saves $nm-(n+m)$" as $\max(0,nm-n-m)$.

**B4. Prop 9.3: two of the 15 sentences are redundant.**
* $\forall x\,(J(x,\mathtt e)\to J(\mathtt s_1x,\mathtt e))$ and its negated form are the instances $y:=\mathtt e$ of $\forall x\forall y\,(J(x,y)\to J(\mathtt s_1x,y))$ and of its negated form.
* *Evidence* (computed: `rb5_binary_observable.out`, Part C, checked syntactically). The record's own case analysis never uses them: the case "$(1u',\cdot)$" covers $(1u',\varepsilon)$.
* The other claims of Prop 9.3 hold:
  * truth at all values $|x|,|y|\le7$: 0 false instances;
  * checked derivations of all 3969 $J$-literals with $|u|,|v|\le5$ (at most 46 lines) and of all 511 $R$-literals with $|w|\le8$ (at most 68 lines);
  * negative control: in a shifted world 30 instances are false.
* *Fix.* Say "13 sentences", or keep 15 and note the redundancy. This is cosmetic.

**B5. Example 3.4 rests on a script that cannot be rerun in a normal container. The numbers are right, and their closed forms should be in the record.**
* *Evidence.* Scout S's `s2_craig_blowup.py` was rerun on a scratch copy twice. Both times the container's cgroup OOM killer killed it, the second time at 12.67 GB resident (kernel log: `Memory cgroup out of memory: Killed process … python3 … anon-rss:12674248kB`). The machine has 16 GB in all, of which about 14 GB was available during the referee's runs. The record says the rerun took 78 s and was identical, so it must have run with more memory available.
* *Independent recomputation* (computed: `rb8_craig_arith.out`). The words were regenerated from s2's seed and checked against the printed prefixes. The closed forms are:
  * $N=4(2^{n+1}-1)$ candidate lines for $|w|=n$;
  * $L^*=n+2$ lines in a shortest derivation, which is minimal because every line needs its premise earlier;
  * $d_T=\sum_{j=0}^{n}(j+2)+(n+2)+[\#_1w\text{ odd}]$;
  * $\log_{10}k\ge\log_{10}\sum_{L=1}^{L^*-1}N^L$;
  * $\log_{10}$ of the Craig axiom $\ge\log_{10}((k+1)|\varphi^b|)$.

  These reproduce every row of s2's table: $N$, $L^*$ and $d_T$ for all 15 rows, and the two logarithms to within 0.006 for the rows $|w|\ge5$ (the "+" rows). At $|w|=24$: $N=134217724$, $L^*=26$, $d_T=376$, $\log_{10}k\ge203.20$, Craig axiom $\ge10^{204.61}$ symbols. For $|w|\le4$, s2's exact counts exceed these lower bounds, as they must.
* *Fix.* Give these closed forms in Example 3.4, and mark $10^{203.2}$ as a lower bound: sequences with fewer lines, independent of the search order. Then the example no longer depends on a 12-GB script. Optionally record s2's memory need in §13.

**B6. Thm 5.3's window: the bound $\max(n-1,1)$ is attained, so "$|u|<n$" in the computed paragraph is an off-by-one, not a looser valid alternative.**
* *Evidence* (computed: `rb4_regular.out`, Part A). On 3000 random DFAs (2–7 states; 1–128 residual classes, computed exactly from the automaton), the least separating window never exceeds $\max(n-1,1)$. It equals $n-1$ in 249 cases with $n\ge3$, so the proof's bound cannot be lowered in general.
* *Fix.* As referee A's m11: align §5.2's computed paragraph ("the window $|u|<n$ that the proof guarantees") with the proof ($\{0,1\}^{<\max(n-1,1)}$) and with §16 item 4.
* *The construction itself passes* (Part B). The test used three languages the developer did not use:
  * MOD3, $n=3$: window 2, 21 sentences;
  * END01, $n=4$: window 3, 63 sentences;
  * a random 10-residual language RND: window 3, 147 sentences.

  Every sentence is true at every $t_v$ with $|v|\le9$. All 511 data with $|w|\le8$ have checked derivations. Lines grow linearly in $|w|$: for example, END01 needs at most 539 lines at $|w|=8$, and the largest line grows from 89 to 147 symbols for $|w|$ from 1 to 8.

**B7. Coverage gaps in the developer's tests. The claims are fine; the scripts left three clauses unexercised.**
* (a) *"B is treated exactly as the blank"* (Lemma 4.5(1)). Neither EQ nor VER ever reads the symbol B: both write it only on their last or second-to-last step. The referee's verifier V11 writes B and then reads it in state `chk2`. Its compiled program passes:
  * 314 rules;
  * 0 overlaps, symbolically and by brute force on 4,417,314 pairs;
  * 0 mismatches on 16129 $(x,z)$ pairs;
  * checked derivations of all 127 data with $|w|\le6$ (relation version) and all 63 with $|w|\le5$ (observational version).
* (b) *Junk-robustness.* The alternating test machine of `t3_alternating` gets stuck on every junk prefix, so it cannot expose B1 (see also referee A's M1).
* (c) *Nested pairs.* `t4_two_stack` Part C checks the pairing lemma on words and pairs of words only. The referee's `rb2` checks Lemma 4.2(i)–(iii) on a fragment of $\mathfrak U$ of 552 elements that includes pairs of pairs: 292008 triples, 0 violations, with $\theta_2$ evaluated as a quantifier, not through the lemma.
* *Fix (optional).* Add one machine that reads B, and one alternating machine that accepts on a junk prefix, as standing regression tests.

## Agreement with referee A

* **M1** is confirmed independently: different compiler, different checker, different machines (B1 above).
* **m11** is confirmed and sharpened: the bound $n-1$ is attained (B6).
* **m12**, the "$u=u'b$" typo in the proof of Thm 5.1, is confirmed by re-deriving the one-edge claim. With the outside-in convention $t_{bu'v}=\mathtt s_bt_{u'v}$. The composition step itself was tested and holds (`rb3`, Part B).
* **m2** (consistency hypothesis in Prop 6.3) is trivially right: an inconsistent sentence proves every $\mathrm{Inf}_n$. Nothing to compute.
* The literature issues **M2**, **m4** and **m8** were not assessed, because computation cannot settle them.

## What was tested and found correct

| claim | referee test | result |
|---|---|---|
| Thm 2.1(d), finite analogue | `rb7`: semantic (model-set) implementation, independent of `t1`; three backgrounds $B_1$ (the developer's), $B_2\vdash o_1$, $B_3\vdash o_0\vee o_1$; 30 machines each, 8 tapes | 0 tape-wise disagreements in consistency or observational content; 0 disagreements of the law on 34590 data sets per background; 0 class-wise disagreements in 240000 checks per background; dropping the theoretical axioms instead of projecting changes the law for 25, 20, 29 of 30 machines |
| Lemma 4.2 | `rb2` A: fragment of $\mathfrak U$ with nested pairs | 0 violations of (i)–(iii) |
| Prop 9.1(b) | `rb2` B | without pairs the two output rules of $T^O$ fail (200/200 random $R$) |
| Remark 4.8 | `rb2` C: ANBN's tag-0 rules in $\mathfrak U$ | 0 of 11835 word-valued instances false; 2783 of 71725 instances with pair values (nested pairs included) false, so $\mathrm{Std}$ is needed |
| Def 4.4, Lemma 4.5 (i)–(ii) | `rb1` A: own compiler from the text; ANBN ($0^n1^n$, crossing-off with left moves), V11 (verifier, certificates in unary, reads B) | linear; 0 symbolic overlaps; 0 doubly-matched pairs by brute force (417690 and 4417314 pairs); no rule at a halting prefix; semantics 0 mismatches (7665 and 16129 pairs) |
| Thm 4.6 (i)–(iii) | `rb1` B: $T^C$ and $T^O$ built from the text (fresh bound variable, see B2); derivations checked by `rb_logic` | ANBN: 511 data in each version, 0 invalid (at most 348 and 939 lines). V11: 127 and 63 data, 0 invalid. Members of the relation version evaluated in $(\mathfrak T,C^{\mathfrak T},X_{\rm acc})$: 841624 and 518164 instances, 0 false, 0 undetermined (runs memoised along paths; cycles detected) |
| Prop 4.7 | `rb1` C | see B1 |
| Lemma 5.2 (a) | `rb3` A: exact EF-game solver; structures built from replicated components, so that $\equiv_q$ non-isomorphic pairs are common | 226, 133 and 145 informative pairs for $q=1,2,3$; 213, 95 and 273 disjoint unions tested; 0 violations |
| Lemma 5.2(b), as used in Thm 5.1 | `rb3` B: gluing a context to a subtree by one edge between an $H$-marked and an $\mathrm{Rt}$-marked element | 101 cases with $\equiv_2$ marked roots, 0 violations; control: unmarked-equivalent but marked-inequivalent roots break $\equiv_2$ in 103 of 115 cases |
| Lemma 6.1 | `rb3` C: games, not sentence evaluation | truncation at $\max(q,1)$ preserves $\equiv_q$ in all 185 structures ($k=2,3$; $q=1,2$); truncation at $q-1$ breaks it in 40/40; the bound $2^kq$ is attained by "every cell has $\ge q$ elements" |
| Lemma 6.1 with $k=0$, Prop 6.3(a), Prop 7.1(b) | `rb3` D | 1200 random pure-equality sentences of rank 1–4: truth constant on sizes $q$ to $q+2$ |
| Thm 5.3 | `rb4` A, B | see B6 |
| §5.2's residual counts | `rb4` C, independent | identical to `t4_regular.out` Part B for all five languages |
| Prop 6.3(b), $\mathrm{Cnt}'_k$ | `rb6` A: formula as written, evaluated on all cell sets ($k=1$) and on 3047 and 3767 cell sets ($k=2,3$) | matches the record's characterisation in every case; least model has $2^k$ cells |
| $\lvert\mathrm{Cnt}'_k\rvert=64k+13$ | `rb6` B | reproduced in scout N1's convention, with $\neg a\to b$ written $a\vee b$ as in `t5`. Other conventions give $62k+13$ (xor in DNF) and $24k+14$ (with $\leftrightarrow$, xor and $\to$ primitive): linear in every convention |
| Thm 6.2(c) | `rb6` C | no injective non-surjective self-map on sets of size $\le7$ |
| Prop 7.2 | `rb6` D | see B3 |
| Prop 9.3 | `rb5` | see B4 |
| Example 3.4 | `rb8` | see B5 |

## Developer's scripts

All five were rerun on scratch copies with `python3 -I`, and all five outputs are byte-identical to the saved `.out` files:

| script | wall time |
|---|---|
| `t1_hempel_toy` | 3.7 s |
| `t3_alternating` | 7.0 s |
| `t4_two_stack` | 30.0 s |
| `t4_regular` | 17.0 s |
| `t5_monadic` | 1.2 s |

The scouts' scripts:
* `s3_vocab_ontology.py`: output identical.
* `c2_finite_models.py`: standard output identical to the saved `.out`.
* `s2_craig_blowup.py` could not be rerun (B5).

Every number quoted from these outputs in `notes.md` (§2, §4.2, §4.4, §4.5, §5.2, §6.1, §9.3, §13) was compared with the saved outputs, and all agree. For example:
* 24480 and 21830 checks, and 37/40;
* 140 and 274 rules; 30705 and 8001 pairs;
* 144 and 147 sentences; 447 and 1155 lines; largest lines 145 and 341;
* 318 of 12519;
* largest lines $61+12|x|$ and $193+20|x|$;
* 63 and 119 sentences, with at most 637 lines;
* $64k+13$ and 6560 structures.

## Verification log

*Reading.* In full:
* the project brief `../../00-brief.md`;
* this thread's `00-brief.md`;
* `notes.md`;
* referee A's `referee-A.md`, read after the referee's own tests were designed, to avoid duplication and to cross-check;
* the developer's scripts, in part: the headers, the compilers in `t4_two_stack.py` and `t3_alternating.py`, and the counting code in `t5_monadic.py`. These were read to understand the saved outputs; nothing was copied.

Scout N1's `c2_finite_models.py` was read only for its symbol-count convention.

*Reruns of the developer's scripts.* The five `checks/*.py` and `hilbert_check.py` were copied to `…/scratchpad/rerun_terms/` and run with `python3 -I`. All outputs were byte-identical. The scouts' `s3` and `c2` were run in `…/scratchpad/rerun_scouts/` and were identical. `s2` was OOM-killed twice (B5).

*Referee scripts.* All final outputs are saved next to the scripts in `referee_code/`. All eight were then rerun from scratch copies in `…/scratchpad/rb_rerun/`, and every output was identical to the saved one. Seeds and wall times:

| script | seed | wall time |
|---|---|---|
| `rb1_two_stack` | deterministic | 75 s |
| `rb2_pairing` | seed 20261016 | 5 s |
| `rb3_ef_games` | seed 20261016 | 16 s |
| `rb4_regular` | seed 20261016 | 14 s |
| `rb5_binary_observable` | deterministic | 7 s |
| `rb6_monadic_factoring` | seed 20261016 | 12 s |
| `rb7_hempel_projection` | seed 20261016 | 31 s |
| `rb8_craig_arith` | deterministic | under 1 s |

*Self-corrections during the referee work.*
1. **`rb3` pool design.** The first version drew random dense structures. For $q=2,3$ it found no $\equiv_q$ pair that was not isomorphic, so the union test was vacuous. Structures built from replicated components fixed this.
2. **`rb3` control design.** The first gluing control could not fail. It was replaced by a control with unmarked-equivalent but marked-inequivalent roots, which breaks $\equiv_2$ in 103 of 115 cases.
3. **`rb1` speed.** The first `rb1` scanned all rules at every step and did not finish in 10 minutes. Rules are now indexed by the tag-and-state prefix of $l$. That is sound, because every current pattern's $l$ begins with such a prefix.
4. **`rb1` semantic evaluation.** The first version used a fixed step budget and reported 5866 undetermined runs. It now memoises results along whole runs and detects cycles: 0 undetermined.
5. **A shell mistake.** A `pkill -f` in the same shell command as a patch killed that shell, so the patch was not applied. This was noticed, and the patch was reapplied and checked before the final runs.
6. **`rb6` Part C.** The first version tested a contradictory condition and was vacuous. It now tests injectivity and non-surjectivity separately.

*Not done.*
* No rerun of `s2` (memory).
* Nothing under charged deduction beyond derivation sizes on small inputs. The fit-class theorems (Thm 3.3, Cor 3.5, Prop 4.1, Prop 9.4) are asymptotic and rest on SD, TF and CKS. They were read, not computed.
* Theorem 5.1 itself is a non-existence statement over all finite theories. Only its two lemmas and the transplant step were tested.
* No literature checks: that is referee A's part. Referee A's novelty point M2 was not assessed.

*Repository state.* Files were written only in `research/tracks/terms/`, namely this report and `referee_code/rb*.py` with their `.out` files, and in the session scratchpad. No git command that changes repository state was run.
