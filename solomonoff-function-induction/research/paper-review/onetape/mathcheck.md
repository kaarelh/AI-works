# One-tape definition of SFI: mathematics check (2026-10-13)

Scope: `git diff 68961062 -- paper/sections paper/main.tex paper-steeper/sections`. 16 hunks in 7 files of Paper 1: abstract, intro, related, setting, versions, learn and discussion. Paper 2 and `paper/main.tex` are unchanged. Nothing was edited; this file is the only output.

Each claim in each hunk was checked against the paper's own statements:
- `def:setting:machine`, `prop:setting:machinelaw`
- `thm:setting:universal` / `eq:setting:mixture`
- the paragraph "SFI as one universal machine on one random tape"
- `def:setting:sfi`, `thm:setting:invariance`
- `def:versions:variants`, `rem:versions:Wdelim`, `thm:versions:chain`, `prop:versions:Wgap`, `rem:versions:Wrate`, `prop:versions:tape`, `q:versions:open`, `thm:versions:nocoding`

## Verdict

- **No claim became false.** The mathematics is unchanged: no inequality, constant or hypothesis in any numbered statement was touched.
- **Findings:** three statements now read more strongly than the results support (M1–M3), and two sentences have an unclear referent (M4, M5). Each has an exact fix of about the same length.
- **Non-mathematical notes:** N1 and N2.
- **Structure is intact.** Details are in the next section.

## Structural checks (all pass)

- **Paper 1 tokens.** A script compared, in order, every `\begin{..}`, `\label{..}`, `\section`, `\subsection`, `\footnote`, `\status{..}` and `\src{..}` token of each `paper/sections/*.tex` and `paper/main.tex` with base 68961062. The sequences are identical in every file.
  - No numbered environment, section, subsection or numbered equation was added or deleted.
  - No label was renamed or removed.
  - No `\status`/`\src` call was removed.
  - Only `\cref` counts changed: setting +1 (`\eqref{eq:setting:mixture}`) and versions +6.
- **Paper 2.** `git diff 68961062 --quiet -- paper-steeper` reports no changes.
  - Paper 2 never describes SFI itself as "a random program reading random bits".
  - Its descriptions are "universal prior over random (partial) functions" and, in the `setup.tex` table, "the law of the universal function machine; $M_F=\sum_i m(i)\nu_{T_i}$ for $D\ne\emptyset$". Both agree with the one-tape definition.
  - The private-versus-shared distinction and the program-length/likelihood split are untouched.
- **Companion numbers.** `research/paper-review/scratch/editor/check_companion_numbers.py` ends with ALL OK. The current `main.aux` gives:
  - `thm:versions:chain` = 4.4
  - `prop:versions:shared` = 4.7
  - `thm:learn:dominance` = 5.1
  - `prop:learn:freshnoise` = 5.6

  These are the numbers Paper 2 cites.
- **Build.** `paper/main.log` has 0 undefined references.

## Hunk-by-hunk

| # | file:line | hunk | verdict |
|---|---|---|---|
| 1 | abstract.tex:3 | one-tape definition; "This law dominates that of every machine of this kind and does not depend, up to a constant factor, on the choice of universal machine" | Correct for every universal $U$. $\nu_U\ge2^{-\lvert p_T\rvert}\nu_T$, and the one-tape paragraph gives $\nu_U\asymp M_F$. Scope wording: see M5. |
| 2 | intro.tex:6 | one-tape definition; "the same sequence serves every query, so this defines a random partial function" | Correct. |
| 3 | intro.tex:18 | Theorem A: function machine; "The law $M_F$ of a universal function machine ... satisfies $M_F\ge2^{-K(\nu)}\nu$" | **M1** (overstated for an arbitrary universal machine) |
| 4 | related.tex:14 | "the law of a universal machine that reads one sequence of fair coin flips for every input" | Acceptable. The section is declared informal, and $M_F$ is the law of a universal machine ($T_U$). No change needed. |
| 5 | setting.tex:4 | section opening: one-tape definition; "Formally, $U$ is ... $T_U$ ...; every universal machine gives the same law up to a constant factor" | Correct: `def:setting:sfi` and the one-tape paragraph. **M4** (referent of "special cases"); **N1** (footnote placement). |
| 6 | setting.tex:45 | "Equivalently, $T$ is a Turing machine as in the informal definition, but not necessarily universal ..." | Correct; the same content as the base. |
| 7 | setting.tex:58 | "$T_U$ reads the first self-delimiting block $p$ ... one tape read in two parts ... represents $M_F$ as the Bayes mixture (eq) ..., with posterior weight $m(i)\nu_{T_i}(D)/M_F(D)$ on $T_i$" | Two-part reading is correct: by the definition of $T_U$, $f^{T_U}_{p\omega'}=f^{T_{V(p)}}_{\omega'}$ for $p\in\mathrm{dom}V$, and $\mathrm{dom}V$ is prefix-free, giving the mixture for $D\ne\emptyset$. **M3** ("on $T_i$"). |
| 8 | setting.tex:60 | one-tape paragraph, first sentence replaced by "Every universal Turing machine $U$ in the informal definition gives $M_F$ up to a constant factor." | Correct. The proof sentences are unchanged and still give $M_F\ge2^{-K(\nu_U)}\nu_U$, $\nu_U\ge2^{-\lvert p_{T_U}\rvert}M_F$, the posteriors and the additive loss constant. "Universal" is defined later in the same paragraph, as in the base. |
| 9 | setting.tex:96 | `def:setting:sfi`: "$f^{T_U}_\omega$ of one tape $\omega\sim\mathrm{Unif}$, read by every query" | Correct; the same object. |
| 10 | setting.tex:122 | `rem:setting:recommend`: "it is the law of the one-tape definition at the start of this section" | Correct. The opening fixes $U=T_U$ formally, so "the law" is exact. |
| 11 | versions.tex:18 | W as the coin-free version (details below) | Every inequality checks. **M2** ("but small"). |
| 12 | versions.tex:25 | `rem:versions:randomness`: "Apart from the choice of a program, no randomness in $W$, $K_F$; $M_{\rm prod}$ fresh coins at each input, $M_{\rm pq}$ at each query; $M_F$ reads the rest of its one tape, shared by all inputs" | Correct. Per input versus per query matches `def:versions:variants` and `rem:setting:perinput`. |
| 13 | versions.tex:46 | the definition of $K^{\rm pad}$ moved to l.18 | Correct. $K^{\rm pad}$ is now defined before its first use at l.46 and in `prop:versions:tape`. Nothing earlier uses it. |
| 14 | versions.tex:126 | `rem:versions:answer`(2): "Coin flips or not"; "coin flips beyond the program matter little unless ..." | Correct; the same mathematics. |
| 15 | learn.tex:141 | `rem:learn:ideal`(1): "law of a universal machine on one random tape; with the tape read as a program followed by its coin flips, this law is the mixture of all machine laws ..." | **M1** (same issue as hunk 3) |
| 16 | discussion.tex:9 | "program mixture, SFI's coin-free version"; "it is the law of the one-tape definition (one universal machine, one sequence of coin flips)" | Correct. The one-tape definition fixes $U=T_U$ (setting l.4), and `rem:setting:recommend` is cited. No change needed. |

### Hunk 11 (the W passage), claim by claim

- **"the tape only selects a deterministic program, its first self-delimiting block, after which no further bits are read"; "Equivalently ... prior $2^{-\lvert p\rvert}$ on all self-delimiting deterministic programs".**
  - Since $\mathrm{dom}V$ is prefix-free, $W(D)=\sum_{p\in\mathrm{dom}V}2^{-\lvert p\rvert}\mathbf 1[\varphi_{V(p)}\supseteq D]$ equals $\mathrm{Unif}\{\omega:\omega$ begins with $p\in\mathrm{dom}V$, $\varphi_{V(p)}\supseteq D\}$.
  - This is the machine law of the function machine $\{(x,p,y):p\in\mathrm{dom}V,\varphi_{V(p)}(x)=y\}$ for $D\ne\emptyset$, as in `rem:versions:Wdelim`.
  - $W(\emptyset)<1$ is stated in the same paragraph.
- **"Always $W\le2^{O(1)}M_F$".** `thm:versions:chain` for $D\ne\emptyset$; at $D=\emptyset$, $W(\emptyset)=\Omega\le1=M_F(\emptyset)$.
- **"$\log(M_F(D)/W(D))\le\min\{K^{\rm pad}(L_{1/2}(M_F,D)),K(\mathrm{dom}D)\}+O(1)$".**
  - The first term is the last sentence of `prop:versions:tape`(a).
  - The second term follows from `thm:versions:chain`: $M_F\le2^{O(1)}M_w\le2^{K(\mathrm{dom}D)+O(1)}2^{-K_F(D)}\le2^{K(\mathrm{dom}D)+O(1)}W(D)$.
  - At $D=\emptyset$ the bound is trivial.
  - The same minimum is in `tab:versions:compare` and `q:versions:open`.
- **The glosses on $L_{1/2}$ and $K^{\rm pad}$** match `prop:versions:tape`(a). "Nondecreasing, unbounded, at most $K(N)$" is proved in the appendix proof of (c).
- **"The gap is unbounded".** `prop:versions:Wgap`: "$M_F/W$ ... unbounded".
- **"on two-point binary data sets over $d$-bit inputs it is at most $K^{\rm pad}(2^{d+1})+O(1)$".** By `prop:versions:tape`(b) with $\lvert D\rvert=2$, $W(D)\ge2^{-2-K^{\rm pad}(2^{d+1})-c'}$, and $M_F\le1$.
- **"hence at most $2\log(h(d)+2)+O_h(1)$ for every computable, nondecreasing, unbounded $h$".**
  - `rem:versions:Wrate` states this verbatim. Its proof applies (c) with $g(N)=h(\max(0,\lfloor\log N\rfloor-1))$, which needs $h:\mathbb N\to\mathbb N$, as in (c).
  - This exact form replaces the brief's looser "grows more slowly than $2\log h(d)$", which is correct.
- **The terminology sentence** ($K_F$ as prefix complexity of the constraint, $W$ as its algorithmic probability) is unchanged.

## Findings and exact fixes

**M1. "A universal machine" where only $T_U$ has the exact property** (intro.tex:18 Theorem A; learn.tex:141 `rem:learn:ideal`(1))

*Theorem A.* "The law $M_F$ of a universal function machine, the prior of SFI, satisfies $M_F\ge2^{-K(\nu)}\nu$ ...".
- The next sentence, "Changing the universal machine changes $M_F$ by at most a constant factor", treats $M_F$ as depending on the choice of machine. So the first sentence reads as a property of every universal function machine.
- With the exact constant $2^{-K(\nu)}$, that holds for $T_U$ by `eq:setting:mixture`, and for every $T_U$-type construction by `thm:setting:invariance`(a).
- For an arbitrary universal $U$ in the sense of the one-tape paragraph, only $\nu_U\ge2^{-\lvert p_{T_U}\rvert}M_F\ge2^{-K(\nu)-O_U(1)}\nu$ holds.
- The base said "There is a universal function machine; its law ...", which is exact.

Fix (intro.tex:18), replace

> `The law $\MF$ of a universal function machine, the prior of SFI, satisfies`

with

> `There is a universal function machine whose law $\MF$, the prior of SFI, satisfies`

*rem:learn:ideal(1).* "the law of a universal machine on one random tape; with the tape read as a program followed by its coin flips, this law is the mixture of all machine laws with weights $m(i)$".
- The program-then-coins reading and the identity $M_F=\sum_i m(i)\nu_{T_i}$ are exact for $T_U$ only, and only on $D\ne\emptyset$ (`eq:setting:mixture`).
- For another universal machine the law is this mixture only up to a constant factor.

Fix (learn.tex:141), replace

> `SFI is the Bayes predictor for the law of a universal machine on one random tape; with the tape read as a program followed by its coin flips, this law is the mixture of all machine laws with weights`

with

> `SFI is the Bayes predictor for the law $\MF$ of the universal function machine $T_U$ on one random tape; with the tape read as a program followed by its coin flips, $\MF$ is, on nonempty data sets, the mixture of all machine laws with weights`

**M2. "but small" reads as a general claim** (versions.tex:18, hunk 11)

"The gap is unbounded (`prop:versions:Wgap`) but small: on two-point binary data sets over $d$-bit inputs it is at most ...".
- The colon is meant to restrict "small" to that class, but the sentence can be read as saying the $W$–$M_F$ gap is small in general.
- In general only $\min\{K^{\rm pad}(L_{1/2}(M_F,D)),K(\mathrm{dom}D)\}+O(1)$ is proved.
- Whether $\log(M_F/W)=O(K(d,\lvert D\rvert))$ is open (`q:versions:open`).

Fix (shorter), replace

> `The gap is unbounded (\cref{prop:versions:Wgap}) but small: on two-point binary data sets over $d$-bit inputs it is at most`

with

> `The gap is unbounded (\cref{prop:versions:Wgap}), but on two-point binary data sets over $d$-bit inputs it is at most`

**M3. Posterior weight "on $T_i$" instead of "of $i$"** (setting.tex:58, hunk 7)

- $m(i)\nu_{T_i}(D)/M_F(D)$ is the posterior weight of the index $i$.
- The enumeration $(T_i)$ repeats machines, so the posterior weight of the machine $T_i$ is the sum of this quantity over all $j$ with $T_j=T_i$.
- The base said "the posterior weight of $i$".

Fix, replace

> `with posterior weight $\mm(i)\nu_{T_i}(D)/\MF(D)$ on $T_i$ after $D$.`

with

> `with posterior weight $\mm(i)\nu_{T_i}(D)/\MF(D)$ on index $i$ after $D$.`

**M4. "Special cases" has lost its referent** (setting.tex:4, hunk 5)

- In the base, "deterministic programs and private streams are special cases" followed "one random tape read by all inputs (`def:setting:machine`)".
- Now it follows "every universal machine gives the same law up to a constant factor", so it can be misread as "special cases of universal machines".
- `prop:setting:includes` says they are special cases of function machines, the class $M_F$ dominates.

Fix, replace

> `Deterministic programs and private random streams per input are special cases (\cref{prop:setting:includes}), and`

with

> `Deterministic programs and private random streams per input are special cases of the function machines that $U$ simulates (\cref{def:setting:machine,prop:setting:includes}), and`

**M5 (optional). Scope of dominance in the abstract** (abstract.tex:3, hunk 1)

- In "This law dominates that of every machine of this kind", "of this kind" can be read as "universal Turing machines of this kind". Dominance over those alone is much weaker than `thm:setting:universal`, which covers every function machine.

Fix (+10 characters; abstract 1884 → 1894 ≤ 1920), replace

> `This law dominates that of every machine of this kind and`

with

> `This law dominates that of every such machine, universal or not, and`

## Non-mathematical notes

**N1. Footnote placement** (setting.tex:4)
- The unchanged credit footnote ("The private random stream per input, with the resulting dominance ..., first appeared in the author's working notes") now sits on "the coin flips are shared by all inputs, not drawn afresh at each input". That sentence is not what it credits.
- Fix: move the `\footnote{...}` unchanged to the end of the sentence "Deterministic programs and private random streams per input are special cases (...), and \cref{sec:versions} compares the variants." This puts it before "Proofs are in \cref{app:setting}."
- The token order is unchanged and the footnote number stays the same.

**N2. Length** (brief item 8, "same length or shorter overall")
- `paper/sections/*.tex` grew by 1,515 characters:
  - versions +869
  - setting +273
  - intro +246
  - learn +47
  - abstract +44
  - discussion +33
  - related +3
- The abstract is at 1884 source characters, within 1920. The page count is unchanged at 91 (log-edit.md).
- This is not a mathematical issue. M2 saves 9 characters and M3 adds 4.
- Further cuts that change no claim:
  - drop "both to predict outputs at new inputs and to infer the function" in setting l.4;
  - in versions l.18, drop the duplicated reference "\cref{rem:versions:Wrate}", since the same bound with that reference follows at l.46.
