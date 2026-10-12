# Paper 1: mathematical review of history-aware prediction and the worked examples (reviewer B)

**Scope.** `paper/sections/hist.tex`, `app-hist.tex`, `examples.tex` and `app-examples.tex`, read against `research/tracks/history/notes-final.md` and `research/tracks/examples/notes-final.md` (with `referee.md` and the check scripts), the request in `research/00-brief.md`, and the binding notes at the top of `paper/OUTLINE.md`. I checked every statement and proof in these four files line by line. Where a claim is numerical, I recomputed it independently. Issues are listed at the end and in `issues-p1-math-B.json`. Severities follow the brief: fatal, major or minor.

**Verdict.** I found no fatal error. The mathematics of these sections is sound and faithful to the final notes. The quantitative claims I could test all reproduce exactly. There are seven major issues:

* two missing hypotheses that make a printed lemma and a displayed identity false as written (MB-01, MB-02);
* a proof sketch presented inside a theorem statement (MB-03). I give a short fix that turns it into a full proof at the cost of an extra $K(\lceil C_{\rm dir}\rceil)$ term.
* an overstated summary of Hänni's Thm 1 (MB-04);
* two arXiv-form problems a reader will notice: status and source markup, and the "request" citation (MB-05, MB-06);
* an undefined process that supports a quantitative remark (MB-07).

The minor issues are notation clashes, wording, and computed values placed in lemma statements.

---

## 1. What I checked and how

### 1.1 Re-run of a sample of the project's scripts

Copies of the scripts were run in `research/paper-review/scratch/p1-math-B/mirror/`, using `run_sample.sh` (log in `rerun_log.txt`). The outputs were compared byte for byte with the saved ones.

| script | what it supports in the paper | result |
|---|---|---|
| history `c1_brief_counterexample` | `prop:hist:sketchfails` | identical |
| history `c5_gf_agreement` | `lem:hist:charsum`, $\max_GN(G)=8,22$; local search $56,142,322,740$ | identical |
| history `c6_set_order_lemma` | `prop:hist:strict`(iii): at most $n$ consistent orders | identical |
| history `c9_normalised_lower_bounds` | `prop:hist:normchain` (finite proxy) | identical |
| history referee `r4_combinatorial_lemmas` | `prop:hist:strict`(iii) for $n=6,7$; `lem:hist:block` | identical |
| examples `e1_eisenstat_exact` | `prop:ex:law`, `lem:ex:pstar`, $\Ex UB_n$ | identical |
| examples `e3_cyclic` | `tab:ex:cycle`, cyclic law | identical |
| examples `e6_cyclic_sharp` | brooms, depth count, Robbins window, normalised proxy (min margin $2.77$), SI codes | identical except the runtime line |
| examples `e7_eisenstat_dp` | `lem:ex:behind` exact values, `prop:ex:burnin`, `prop:ex:rulestats`, $\Var(UB_n)$ | identical except the runtime line |

### 1.2 Independent checks (no project code imported)

The checks are in `research/paper-review/scratch/p1-math-B/`.

* **`m2_eisenstat_independent.py`** works from the paper's definitions only.
  * `prop:ex:law`(a): the formula $\binom n{N^1}(\frac29)^nr^{s^+-n}$ equals the exact law, by enumeration in exact rationals for $n=3,4,5$ (456, 1108 and 3140 data sets; error $0$).
  * The normaliser $Z(S)$ matches on 165, 330 and 792 domains.
  * The example $S=\{0,1,3\}$ gives exactly $\frac15$ and $\frac1{10}$.
  * `lem:ex:pstar`: the closed form equals the exact conditional on 475 and 2414 (history, input) pairs (difference $0$).
  * A frontier DP written from the proof of `prop:ex:burnin` gives the following at $n=10,20,40,80,160$, exactly the values printed in `lem:ex:behind`, `prop:ex:burnin` and the proof of `prop:ex:rulestats`:
    * $\Pr[\eta_n<\tau_n]=6.48\cdot10^{-2}$, $1.55\cdot10^{-2}$, $1.11\cdot10^{-3}$, $7.31\cdot10^{-6}$, $4.27\cdot10^{-10}$;
    * $\Ex N_{\rm touch}(n)=2.611$, $2.907$, $2.993$, $3.000$ (at $n=10,\dots,80$);
    * expected rule errors $1.575$, $1.891$, $1.992$, $2.000$;
    * $\Pr[\text{no error}]\to\frac12$;
    * $\Ex L_{P^*}\to3\vartheta$.
  * Constants:
    * $\vartheta=0.7995167$;
    * $\frac{H(1/3)}2=0.4591479$;
    * $\sigma^2=1.0496602$;
    * the i.i.d. cost $1.2516$;
    * the return probability $\frac23$;
    * $\frac13$ expected $B$-steps per cycle and $\frac23$ errors per cycle;
    * the Hoeffding sum $19.5\le20$.
* **`m3_gf_and_constants.py`**:
  * $\max_GN(G)=8$ for GF(4), over all total and all partial $G$;
  * $\max_GN(G)=22$ for GF(8), over all $8^8$ total $G$;
  * $\log_2(\#\text{triples}/\max N)=2.585$ and $4.348$, consistent with the optimum $4.348$ at $q=3$ (referee r3);
  * the losses in the sketch-fails example ($1$ bit against $2$);
  * $\log_2\binom n{\lfloor n/2\rfloor}\ge n-\log_2(n+1)$ for $2\le n\le4096$;
  * $\log((N-1)!)$, per-pair values and Robbins' window, matching `tab:ex:cycle`;
  * the cyclic law $1/(N-1)_k$ and the broom bound $1/(N-1)_{k-1}$, by enumeration for $d=2,3$.
* **`m1_chainsemi_restriction.py`**: a counterexample to `lem:ex:chainsemi` and to `eq:ex:depth` as printed, and confirmation that both hold once $z$ is restricted to nonzero $d$-bit strings (MB-01, MB-02).

### 1.3 Line-by-line mathematical review

**Hänni's counterexamples (`thm:hist:chain`, `thm:hist:skipped`, `prop:hist:orderfree`, `prop:hist:normchain`).** Correct, as are their proofs in `app:hist`:

* the disjointness lemma `lem:hist:chain0`;
* the lower bound via the conditional coding theorem, $\bar\ell_{n-1}-K(\ell_n)-c_\omega$;
* the upper bound $\bar\ell_{n-1}+K(n)+c$;
* the $\ell_i=i$ form, $\pm(2\log n+c_\omega)$;
* the weak-semimeasure induction;
* the broom normaliser bounds for the normalised predictor. These give $\ell_{t-1}-K(\ell_t)-K(t-2)-c_\omega$ per step and $n(n-1)/2-n(4\log n+c_\omega)$ in total. The skipped-string analogue is $\ell-2K(\ell)-c_\omega$.

**Hänni's Thm 1.**

* The three readings are stated faithfully, and so is the choice of Reading C.
* `prop:hist:sketchfails` is correct: $1$ against $2$ bits, verified.
* The shared-simulator theorem is correct, including the measure-of-union step and the disjointness across orders.
* So are the Bayes form, the directed-information identity, and the randomized chain ($I(f\to x)=n(n+1)/2$, $\Ex\LSFI\ge n(n-1)/2$).
* The minimax theorem is correct as follows:
  * Step 1: Sion's theorem plus the bound $1+I_\nu$;
  * Step 2: the Lipschitz constant $|Y|^n/\ln2$;
  * Step 3(a): a grid search;
  * Step 3(b): a certified search against a lower-semicomputable right side;
  * Step 4: the complexity bookkeeping;
  * for reveal laws that do not see $f$, case (b) is complete. For laws that do see $f$, it is a sketch (MB-03).
* `cor:hist:thm1`(a)–(c) are correct under the stated hypotheses. Part (c) has a small problem for defective reveal samplers (MB-19).
* `prop:hist:shannon`: the identity in (a) is checked by the chain rule.
* `prop:hist:nopathwise` is correct.
* The only problem in this subsection is the summary sentence at `hist.tex` l.109 (MB-04).

**\SFIhist{}, the chronological semimeasure and SI.**

* The interval-allocation proof of `thm:hist:representation` is correct. I checked the invariants (I1)–(I4), the "$\ge$ with $\rho(z')$" step for siblings that are processed later, and the inductive identification of $\{\omega:T^\omega(x_{1:i})=y_i\}$ with $S(z)$.
* `cor:hist:H4` follows.
* `lem:hist:block` is correct. I checked $B(\code(b))=\{b\}$, the partition of $B(za)$, and the semimeasure inequality.
* So are `thm:hist:si`(a)–(d) and `prop:hist:inputloss`.
* The (LHG) consequences in `prop:hist:lhg` are correct as conditional statements. Their framing needs a hedge (MB-08).
* The definition of $\MHin$ and its domination property, which `thm:hist:si` uses, are not stated (MB-15).

**The hierarchy SFI $\prec$ count $\prec$ set $\prec$ hist.**

* `prop:hist:variants` is correct.
* So is `prop:hist:strict`:
  * (i): the subset $A$ with $K(A\mid S)\ge\log\binom n{\lfloor n/2\rfloor}-1$;
  * (ii): the time-stamped chain lemma, with $n$ computable from $|x_n|$;
  * (iii): backward reconstruction, at most $n$ orders per tape, giving $\log n!-\log n-c$. One trivial omission: the empty-set case of "longest element" (MB-16).
* `prop:hist:strictinf` is correct.
* `prop:hist:programs` is correct, including the Kraft and summation-by-parts argument for (d).

**What SFI can exploit.**

* The sandwich theorem is correct, including the fixed machine that reads $p$ as a self-delimiting program.
* So is `cor:hist:initial`.
* `lem:hist:charsum` is correct: $\mathbf C_u\mathbf C_u^{\mathsf T}=2^qI$ and the spectral bound $|v^{\mathsf T}\mathbf C_uv|\le2^{3q/2}$.
* So is `thm:hist:gf`:
  * (b): the count $2^{3q-1}$ of triples and the $2^{1-k}$ fraction;
  * (c): Jensen, giving $3q/2-2$.
* `thm:hist:expected` is correct.
* So is `prop:hist:info`. Its counterexample (b) is the construction of `prop:hist:strict`(i).
* The "not attained" remark uses an undefined process (MB-07).

**The cyclic permutation.**

* The bijection and the uniform ordering are correct.
* `thm:ex:cycle`(a)–(d) are correct. The Robbins form follows from $(N-1)!=N!/N$, and I checked it numerically.
* So is the broom bound in `thm:ex:ksteps`(a). The cyclic law's $1/(N-1)_k$ comes from contracting the path.
* The depth-count lemma `lem:ex:depth` is correct.
* The proof of (b), and the lemma `lem:ex:chainsemi`, omit the restriction of $z$ to nonzero $d$-bit strings. As printed, the lemma and the displayed identity are false (MB-01, MB-02). With the restriction, (b), (c) and `prop:ex:orderfree`(a) follow as written.
* `prop:ex:orderfree`(b) is correct, and so is the comparison "within one bit for $k\le N/2$".
* `prop:ex:normalised` is correct:
  * the broom $B_{t-1}$ gives $\Znorm\ge2^{-K(t-1)-c}/(N-1)_{t-2}$;
  * $\log(N-1)_{t-1}-\log(N-1)_{t-2}=\log(N-t+1)$;
  * the sum bound and the "$\le2N$" remark are right.
* So are `prop:ex:cycset` (backward reconstruction from the fixed last input $0^d$) and `prop:ex:cycsi`. For the latter I checked the supermartingale started at $V_0:=1$, the header bound $\log\rho(1^d0)\le-K(d)+c$ for $M$ and $\Mnorm$, and Ville's inequality.
* So are `prop:ex:cycraw`, `rem:ex:prior` and the heuristic for `conj:ex:raw`.

**Eisenstat's example.** All statements are correct, and every number reproduces:

* `lem:ex:shape`, `prop:ex:UB` and `thm:ex:sandwich` (Levin–Schnorr for $P_{1/3}$, $g_n\ge\tau_n$ when the heads are ahead, Borel–Cantelli via `lem:ex:behind`);
* `prop:ex:asymp`:
  * the decomposition $a(N^0_n-\frac n3)+\log3\,(G_{N^0_n}-\frac12N^0_n)$ is checked algebraically;
  * the exact mean and variance;
  * the conditional characteristic-function proof of the CLT, which needs no random-index theorem because $G$ is independent of $N^0_n$;
* `thm:ex:expected`: Kraft given $g_n$; $\Pr[b_{<g_n}=s]\le P_{1/3}(s)$; the Cauchy–Schwarz tail; $\Ex g_n\le\frac n2+\frac12$, since $\{\tau_n=k\}\in\sigma(\text{coins},b_{<k})$; the entropy bound on $\mathbb N$;
* `prop:ex:law`(a),(b);
* `rem:ex:email`, with the identity $UB_n-\tau_nH(\frac13)=\frac23(G-\frac12N^0)$;
* `lem:ex:pstar`;
* `prop:ex:burnin`: the walk analysis, $2\beta^2-3\beta+1=0$, $\beta=\frac12$, the return probability $\frac23$ and the geometric $N_{\rm touch}$;
* `thm:ex:eisensi`(a),(b), which give SI's bounded loss: $\Ex L^y_\rho\le3\vartheta+c$;
* `cor:ex:rule`;
* `prop:ex:rulestats`: Wald's identity over i.i.d. cycles, $\frac29+\frac19+\frac13=\frac23$ errors per cycle, an expected total of $2$, and $\Pr[\text{no error}]=\frac12$.

**Positive examples.** `prop:ex:deterministic`, the four examples and `prop:ex:frozen` are correct. I checked:

* the Laplace integral $1/((n+1)\binom ne)$;
* the lower bound $nH(\varepsilon)$ for every learner when the inputs do not see the unrevealed noise;
* `rem:ex:fresh`.

---

## 2. Numbered issues

Line numbers refer to the current files.

### Major

**MB-01. `app-examples.tex`, `lem:ex:chainsemi` (l.33–40): the lemma is false as printed.**

* *Problem.* The sum runs "over the $z$ for which $D(x,z)$ is a data set", with no restriction on $z_i$. The proof's "z is the orbit of $x$ up to its first visit to $0^{|x|}$" needs $z_i\ne0^{|x|}$.
* *Evidence.*
  * The source (examples notes-final Lemma 2.2) has "strings different from $0^{|x|}$".
  * Counterexample: the point mass on $F\equiv0^d$. For nonzero $x$, every $D(x,(0^d,\dots,0^d))$ is the data set $\{(x,0^d),(0^d,0^d)\}$ or $\{(x,0^d)\}$, so the sum is at least the number of lengths allowed, and it is unbounded.
  * `m1` prints the sums $2,3,4,5,7$ for $|z|\le1,2,3,4,6$; the restricted sum is $1$.
* *Fix.* Range over finite sequences $z$ of strings different from $0^{|x|}$, as in the source. The consequence $K(z\mid x)\le\LSFI(D(x,z))+c$ then holds for those $z$. Update `q:ex:depthweak`, which refers to "the notation of `lem:ex:chainsemi`".

**MB-02. `app-examples.tex`, `eq:ex:depth` in the proof of `thm:ex:ksteps`(b) (l.63–67); also used in the proof of `prop:ex:orderfree`(a) (l.72) and in `q:ex:depthweak` (`examples.tex` l.68): a displayed identity is false as printed.**

* *Problem.* $\sum_{x,z}\nu(D(x,z))=\Ex|A_k(F)|\le N-k$ is stated "summing over nonzero $d$-bit $x$ and $|z|=k-1$". The sentence before it, "other nonzero $x$ have none", is false when $z$ may contain $0^d$ or non-$d$-bit strings.
* *Evidence.*
  * Counterexample: $F\equiv0^d$ with $d=2$ and $k=2$. Every nonzero $x$ has $z=(0^d)$ with $F\supseteq D(x,z)$, so the sum is $3>N-k=2$, while $A_2(F)=\emptyset$ (`m1`).
  * The source (examples Thm 2.3, proof of part 2) sums over $z\in(\{0,1\}^n\setminus\{0^n\})^{k-1}$.
* *Fix.* State the range: $x\in\{0,1\}^d\setminus\{0^d\}$ and $z\in(\{0,1\}^d\setminus\{0^d\})^{k-1}$. Then $q:=\nu(D(\cdot,\cdot))/(N-k)$ is a sub-probability on a set that contains $(x_k,x_{k-1},\dots,x_1)$, and the Gibbs step and the coding-theorem step go through unchanged. Use the same range in `q:ex:depthweak`.

**MB-03. `hist.tex`, `thm:hist:minimax` (l.96–101); `app-hist.tex`, Step 3 case (b) (l.104): a proof sketch is stated as part of a theorem.**

* *Problem.* The statement asserts case (b), computable real values, also for reveal laws that see $f$. The proof of that case is a sketch: the computability of $C_{\rm dir}$ to within 1 is "not written out". Only the `\status` tag says so. The arXiv conversion strips the tag, which would leave a sketched statement presented as proved, against the binding note.
* *Evidence.* `app-hist` l.104: "this is not written out, so this case is a proof sketch". The history notes give Thm 3.8 the status "(b) for kernels that see f: proof sketch".
* *Fix.* Either of two options.
  * (i) Restrict case (b) in the statement to reveal laws that do not see $f$, and move the $f$-seeing case to a remark marked "Proof sketch".
  * (ii) Close the gap at a small cost. Run the certified search of Step 3(b) with an integer $\gamma\in[C_{\rm dir},C_{\rm dir}+1]$, for example $\lceil C_{\rm dir}\rceil$, supplied as advice.
    * The search still halts, because Step 2 gives a rational $G'$ with $\max_f\Phi_f(G')\le2+C_{\rm dir}<3+\gamma$.
    * Its output satisfies $(\star)$.
    * So for $f$-seeing kernels, case (b) holds with the extra term $K(\lceil C_{\rm dir}\rceil)\le\log(C_{\rm dir}+1)+2\log\log(C_{\rm dir}+2)+c$.

    State that version as proved, and list the version without this term in `rem:hist:thm1open`(iv).

**MB-04. `hist.tex` l.109 (also `abstract.tex`, which is outside this review's files): the summary of Thm 1 is overstated.**

* *Problem.* "So Thm 1 is true in Hänni's reading, with an extra $K(n)+K(A)$ for random reveal laws; only the proof sketch fails." This says more than `cor:hist:thm1` and the notes establish:
  * part (a) needs (A1), (A2) and computable-real $P$ and $\Delta_f$, that is, samplers that halt almost surely;
  * Hänni's class $C$ includes defective samplers, and that case is open, as are infinite alphabets;
  * with the extra $K(n)+K(A)$, the bound proved is not the bound of Thm 1.

  "Only the proof sketch fails" implies that everything else holds.
* *Evidence.* The history notes' "Verdict on Thm 1" says it is true "in each of the following cases" (three bullets) and that "three things remain open". `intro.tex` l.19 correctly adds "under finiteness hypotheses". The abstract's "holds in its intended reading" drops every hypothesis.
* *Fix.* Replace the sentence with: "In Hänni's reading (Reading C), Thm 1 holds pathwise for deterministic reveal policies (`cor:hist:thm1`(b)); in expectation, for samplers that halt almost surely and finite alphabets up to the horizon, it holds with an extra $K(n)+K(A)$ (`cor:hist:thm1`(a)); and in general it holds with the reveal entropy added (`cor:hist:thm1`(c)). Defective samplers, infinite alphabets and the removal of $K(n)+K(A)$ are open (`rem:hist:thm1open`). The proof sketch fails (`prop:hist:sketchfails`)." Align the abstract with this.

**MB-05. All theorem-like environments and both tables in the four files: the PDF prints status and source markup, and several status tags carry content that the statements lack.**

* *Problem.* The current PDF prints `[proved]` tags and grey notes with process vocabulary, for example:
  * "Theorem 5.3 (Hänni's chain). [proved] history Thm 2.1";
  * "[computed] examples §2.6; checks e3, e6";
  * "check c9", "checks c3, c8, r2";
  * "Hänni's request".

  When the conversion strips the tags, the following information is lost unless it is moved into the text:
  * `thm:hist:minimax`: the sketch in case (b) (MB-03);
  * `prop:hist:operator`: "given the unverified description";
  * `prop:hist:lhg`: "LHG known, unverified beyond the abstract";
  * `cor:hist:H4`: "identification known (unverified)";
  * `conj:hist:algmi`: "untested";
  * `prop:ex:orderfree`: "sharper weak case open";
  * `rem:ex:where`: "other-direction part conditional";
  * every "computed" part, for example `prop:hist:normchain`, `thm:hist:gf`, `lem:ex:depth`, `prop:ex:asymp` and `prop:ex:burnin`.
* *Evidence.*
  * The binding note says that the final PDF has no `\status` or `\src`, and no "track" or "referee" vocabulary. It also requires computed results to read "a direct computation (code in the accompanying repository) gives …".
  * `main.tex` still inputs `app-verification`.
* *Fix.* In the conversion pass, rewrite each item listed above so that the statement or the sentence after it carries the qualifier. Examples:
  * "Under the per-query reading of operator induction (`rem:versions:operator`), …";
  * "We have neither a proof nor a counterexample" after `conj:hist:algmi`;
  * "a direct computation (code in the accompanying repository) gives …" for the computed parts.

  Then delete every `\status` and `\src`, including the two inside the table floats.

**MB-06. The "request" citation and conversational references: `hist.tex` l.12, l.117; `examples.tex` l.7, l.31, l.35, l.108, l.112; `app-examples.tex` l.140; `bib/core.bib` l.19 (`hanni2026request`).**

* *Problem.*
  * The sole author's informal request to the AI system is cited as a published reference: "Personal communication to the author, 11 October 2026; quoted verbatim in `solomonoff-function-induction/research/00-brief.md`".
  * It is quoted conversationally: "his request conjectures …", "Hänni's request: …", "as quoted in his request".
  * The bibliography names the internal brief file.
  * A "personal communication to the author" from the author himself does not make sense on arXiv.
* *Evidence.* The binding note: no "brief" vocabulary; "No conversational references to 'his request'"; Hänni's ideas are credited through citations to his notes or by stating the authorship arrangement.
* *Fix.*
  * Cite the conjecture ("as good as SI"), the cyclic-permutation example and the e-mail argument as the author's unpublished notes or correspondence. For example: "K. Hänni, e-mail to S. Eisenstat, 2025, unpublished; quoted with permission", if that can be confirmed; otherwise "the author's unpublished notes".
  * Phrase the text as "the author conjectured" or "Conjecture (Hänni 2026)".
  * Remove the repository path from the bibliography entry.

**MB-07. `hist.tex` l.193 and l.187; `app-hist.tex` l.245 (proof of `thm:hist:expected`): the "GF process" is never defined.**

* *Problem.* The remark that the bound of `thm:hist:expected` is "not attained in general", and the claim that the process "fails Reading B", rest on "the GF triple revealed in random order". The paper never defines it: neither $f$ off $\{a,b\}$ nor the reveal law. "$I(f\to x)\approx2q$" is given without its exact value. "$q$ bits for \SFIhist{}" (and "against $q$ for \SFIhist{}" at l.187) conflates $\LH\le q+c$ with the Bayes loss $q$. A reader cannot check the claim.
* *Evidence.* The history notes §5.3 ("As a Reading-B process") define $f(a)=r$, $f(b)=r+ab$, a fixed marker value elsewhere, and a uniformly random order of $a,b$. They give $I(f\to x)=(q-1)+\log(2^q-1)$, using the fact that $f$ identifies $\{a,b\}$.
* *Fix.*
  * Add the definition in one sentence, with a marker outside $\{0,1\}^q$, for example $\epsilon$.
  * State $I(f\to x)=(q-1)+\log(2^q-1)$.
  * Write "the predictor of `thm:hist:gf`(a) has $\Ex L_P=q$, and its reveal law has an $O(1)$ oracle program, while $\Ex\LSFI\ge3q/2-2$".
  * At l.187, write "against the Bayes history-aware loss $q$ ($\LH\le q+c$)".

### Minor

**MB-08. `hist.tex` l.157–166 (`prop:hist:lhg`, `rem:hist:H4verdict`): the (LHG) hypotheses need a hedge.**

* *Problem.*
  * (LHG-odd) is presented on a par with (LHG-even), although the cited abstract supports at most the even form.
  * The example "each odd bit repeated at the next even position" is attributed to Lattimore et al. "(abstract seen only)", but that example is not in the abstract quoted.
  * `rem:hist:H4verdict` says "conditionally on `prop:hist:lhg`", that is, conditional on a proposition rather than on its hypotheses.
* *Evidence.* The history notes §4.4: "LHG's abstract supports (LHG-even). (LHG-odd) is the same pattern shifted by one fixed leading bit; we have not checked that their construction covers it."
* *Fix.* Add: "(LHG-even) is the form suggested by their abstract; (LHG-odd), the same pattern after one leading bit, is not claimed there." Hedge or drop the example. Write "conditionally on (LHG-even) and (LHG-odd)".

**MB-09. `hist.tex` l.20, l.127, l.135, l.157; `app-examples.tex` l.237: informal hedges.**

* *Problem.* The text uses informal hedges about how the sources were checked:
  * "(abstract seen only)", twice;
  * "is known, but not checked against the sources";
  * "These are Hutter's chronological semimeasures …", stated as fact;
  * "proved by hand";
  * "Separately written implementations".

  For the Hutter identification, a precise conditional statement is available.
* *Fix.*
  * Write "according to the abstract of …".
  * Replace the Hutter sentence with: "If Hutter's universal chronological semimeasure is universal in the class of lsc chronological semimeasures (for finite alphabets), then by `cor:hist:H4`(a) it agrees with $\MH$ on those alphabets up to constant factors; we do not use this."
  * Write "proved in the text" and "independent implementations".

**MB-10. `examples.tex` l.25 (the SI paragraph): a tautology and an overloaded $k$.**

* *Problem.* "so $L^y_M=\LMy$" renders as "$L^y_M=L^y_M$". In the same paragraph, $k$ is both the horizon in $L^y_\rho(k)$ and the domination exponent in "$\rho(\code(h))\ge2^{-k}\Prob(h)$ … by at most $k$".
* *Fix.* Write "for $\rho=M$ this is the label loss $\LMy$ of `sec:hist:si`". Rename the domination exponent, for example to $a$, here and in `lem:ex:silabel`.

**MB-11. `hist.tex` l.42, l.92, l.184; `app-hist.tex` l.30, l.239: the confidence exponent is written $k$.**

* *Problem.* `hist.tex` writes the confidence exponent as $k$ ("all but a $2^{-k}$ fraction"). `NOTATION.md` §4 item 4 fixes $j$ for Paper 1, and `examples.tex` uses $j$. In `sec:hist`, $k$ also denotes chain lengths.
* *Fix.* Use $j$.

**MB-12. `hist.tex` l.33 (`thm:hist:chain`) against `examples.tex` l.74 (`prop:ex:normalised`): $\bar\ell$ has two meanings.**

* *Problem.* $\bar\ell_k$ is the cumulative block length $\sum_{i\le k}\ell_i$ in `sec:hist`, but $\bar\ell_t$ is the normalised per-step loss in `sec:ex`. `app-hist` calls the same step loss $\beta_t$.
* *Fix.* Use one symbol for the normalised step loss in both sections (for example $\beta_t$), and keep $\bar\ell_k$ for block lengths.

**MB-13. `hist.tex` l.85 (`thm:hist:directed`(a)): "For any law $\nu$" is ambiguous.**

* *Problem.* The phrase reads as if $\nu$ could be arbitrary. The identity holds for the law $\nu$ of $f$, computable or not.
* *Fix.* Write "For the law $\nu$ of $f$ (computable or not) …".

**MB-14. `hist.tex` l.92; `app-hist.tex` l.125, l.129 (`prop:hist:shannon`(c)): $\Delta_f$ needs its restriction to $n$ steps.**

* *Problem.* "$K(\Delta_f)\ge n(n+1)/2-k-c$" and "$I(f;\Theta)=H(\Delta_f)$" use the infinite reveal law. In the randomized chain, $K(\Delta_f)=\infty$ for almost every $f$. The statement defines $\Theta$ as $\Delta_f$ restricted to $n$ steps, but then writes $H(\Delta_f)$.
* *Fix.* Write $\Delta_f^{(n)}$ for the restriction to $n$ steps, and $H(\Theta)$.

**MB-15. `hist.tex` l.147; `app-hist.tex` l.207: $\MHin$ is used without its definition or domination property.**

* *Problem.* $\MHin$ is introduced only as "the universal chronological semimeasure for inputs given previous labels (roles exchanged)". `thm:hist:si`(a),(b) use its domination property, which is not stated.
* *Fix.* Add: "$\MHin$ is the law of the universal function machine on finite label lists (the empty list included), answering with the next input. By `thm:hist:representation` with the roles exchanged (same proof), $\MHin\ge2^{-K(\rho')-c}\rho'$ for every lsc chronological semimeasure $\rho'(x_{1:n}\Vert y_{1:n-1})$."

**MB-16. `app-hist.tex` l.164 (proof of `prop:hist:strict`(ii)): "Output the longest element of the set" is undefined at time 1, when the set is empty.**

* *Fix.* Add "or $\epsilon$ if it is empty".

**MB-17. `hist.tex` l.143: the summary of `prop:hist:programs` drops a constant and a quantifier.**

* *Problem.* The sentence "pays at most $\Ktail(n)$ extra bits" omits the $+c$. "Pays more than $\log n+\log\log n$ … infinitely often" omits that this is for the worst labelling, along every input sequence.
* *Fix.* Add both.

**MB-18. `hist.tex` l.17 (`def:hist:predictor`): private memory is not in the definition.**

* *Problem.* The definition of a computable sampler has no private memory, while `thm:hist:shared`, `thm:hist:minimax` and `cor:hist:thm1` allow samplers "with private memory".
* *Fix.* Add one sentence: a sampler may keep memory between calls, and it then predicts through its sequence law and the conditionals that law induces (`lem:hist:memory`).

**MB-19. `hist.tex` l.106 (`cor:hist:thm1`(c)): defective reveal samplers.**

* *Problem.* The statement covers all samplers $\Delta_f$, defective ones included. For a defective $\Delta_f$, $\Ex_{x\mid f}$ and the entropy $H_f(x_{1:n})$ of a reveal sequence that exists with probability below 1 are undefined.
* *Fix.* Either restrict (c) to reveal samplers that halt with probability 1, or define the expectation over the sub-probability of complete reveal sequences and define $H_f$ accordingly.

**MB-20. `app-examples.tex` l.170 (`lem:ex:behind`), l.51, l.57: computed values inside a lemma and inside proofs.**

* *Problem.* Computed numbers appear inside a lemma statement ("The exact values are $6.48\cdot10^{-2}$ …"). Computational re-checks of proved inequalities appear inside proofs: "a 120-digit computation confirms the window", and "No violation occurs over all 625 partial functions …".
* *Fix.* Move the exact values to a remark of the form "a direct computation (code in the accompanying repository) gives …". Rephrase the re-checks in the same way, or drop them.

**MB-21. `app-examples.tex` l.150–166 (`tab:ex:eisenstat`): unexplained columns.**

* *Problem.* The caption does not explain the columns "$L_{P^*}$" and "touching". "SFIproxy" and "SIproxy" are informal names.
* *Fix.* Add to the caption: "$L_{P^*}$: loss of the Bayes predictor of `lem:ex:pstar`; touching: number of touching steps (`prop:ex:burnin`)". Rename the columns, for example to "order-free mixture" and "joint mixture".

**MB-22. `examples.tex` l.197 (`q:ex:normalised`): "set-based history-aware predictors have loss $O(1)$ in both".**

* *Problem.* In Eisenstat's example, $P^*$'s loss is finite almost surely and $3\vartheta$ in expectation. It is not bounded on every path: it is heavy-tailed, and 20.6 bits occurred in a simulation.
* *Fix.* Write "loss $O(1)$ (on every path for the cycle, in expectation in Eisenstat's example)".

**MB-23. `hist.tex` l.181: "This covers … the full cyclic permutation ($K(e)\le K(d)+c$)" is ambiguous.**

* *Problem.* The sentence concerns the lexicographic order of $\{0,1\}^d$, not the reveal order of `def:ex:cyclic`, but it can be read as a statement about the cycle order.
* *Fix.* Write "and the full cyclic permutation in the lexicographic order of $\{0,1\}^d$; in its reveal order, \SFIhist{} pays $O(1)$ (`prop:ex:cychist`)".

**MB-24. `hist.tex` l.30, l.41, l.60, l.88, l.103; `examples.tex` l.35: results named after the sole author.**

* *Problem.* In a sole-author paper by Hänni, results are titled "Hänni's chain", "Hänni's skipped strings", "Hänni's Theorem 1" and "Hänni's randomized chain", and the author's own expectations are reported in the third person ("Hänni expected that …"). A reader sees the author naming results after himself and correcting "Hänni's" sketches.
* *Fix.* Use neutral titles: "The chain example", "Skipped strings", "Theorem 1 of the author's notes", "The randomized chain". Attribute through "the author's notes \citep{hanni2026notes}" or through the authorship arrangement in the title footnote.

---

## 3. Summary counts

| severity | count | ids |
|---|---|---|
| fatal | 0 | — |
| major | 7 | MB-01 to MB-07 |
| minor | 17 | MB-08 to MB-24 |

Every number I re-derived matches, and all nine re-run scripts reproduce their saved outputs. The two false-as-printed items (MB-01, MB-02) are local, and fixing the hypothesis restores the source's correct statements; no downstream result changes. MB-03 can be closed by a three-line argument (option (ii)).
