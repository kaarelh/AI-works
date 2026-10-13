# Claims ledger: Paper 2 (steeper simplicity priors in SFI), after the restructure of 2026-10-13

> **Binding notes (unchanged).** The absorption objection is a standard point: never "Wyeth's objection"; the label `rem:absorb:wyeth` stays, its printed title is "Answer to the absorption objection". The paper presents the material for the first time, in the "we" voice; the author's notes are credited only in at most five neutral footnotes (now two: the proposal in `intro.tex`, the change of slope in `kinks.tex`) and in the acknowledgements (`research/paper-review/REFRAME.md`). Statuses are rendered in prose and the `\status{}`/`\src{}` calls print nothing (`research/paper-review/DECISIONS.md` §A1–§A2). Computed numbers stand outside statements, introduced by "a direct computation (code in the accompanying repository) gives …"; κ = 0 numbers are illustrations.

Binding plan of the restructure: `research/paper-review/restructure/PLAN.md` (labels, notation §4, statuses §5). Sources of claims: the refereed record `research/tracks/steeper/notes-final.md` ("steeper") for the base material, and for the new material the sub-track records `research/tracks/split/{iid,kink,teacher}/notes-final.md` with the verification reports `research/tracks/split/verify-{iid,kink,teacher}.md`, which override the synthesis `research/tracks/split/notes-final.md` where they correct it. Writer logs: `research/paper-review/restructure/log-W1.md` … `log-W6.md`, `log-front.md`.

## 1. What the paper claims, in one paragraph per reason

* **Precondition: absorption** (§4). In every class that contains its own mixture (SI, SFI with shared randomness, the weak and the history-aware classes) every λ-MAP is shorter than $\ell^*_\lambda$, a fixed-λ learner reproduces a deterministic teacher's errors, and no sampler longer than $\ell^*_\lambda$ is selected (`thm:absorb:absorption`, `thm:split:shared`); no product hypothesis is universal (`cor:absorb:nouniversal`), at a price on shared coins and up to labelled history (`prop:absorb:price`, `prop:absorb:history`).
* **Common geometry: kinks** (§5). λ-MAPs on one data set are read off the hull (`lem:setup:hull`); one kink lemma, data and population readings (`lem:kink:main`); the split on one data set and its converse (`cor:kink:split`, `thm:kink:converse`); a universal member flattens every kink (`prop:kink:universal`).
* **First and main reason: the model–randomness split** (§6, §7). Per query (PQ), every $\lambda_n$-MAP with $1\le\lambda_n=o(n)$ is eventually a shortest program equivalent to the sampler, with a rate for fixed λ > 1 that depends on the class only through a margin, and no such rate at λ = 1 (`thm:recovery:main`, `prop:recovery:lambda1`, `prop:recovery:necessity`); the sample kink (`thm:recovery:kink`); frozen labels allow only identification on the run (`prop:recovery:frozen`, `thm:split:private`(iv)); λ = 1 on one data set (`thm:split:lambda1`). The full table of the noisy parity has a product kink at the parity, set models have none (`prop:parity:kink`, `prop:parity:range`, `prop:parity:sets`).
* **Second reason: the teacher's mistakes** (§8, §9). The kink lemma with right slope $2^{-m}$ gives the teacher theorem over all product hypotheses (`prop:teacher:kinks`, `thm:teacher:main`); the reuse factor explains why λ ∝ n is needed (`lem:teacher:reuse`, `prop:teacher:schedules`, `prop:limits:plain`); full tables for every m (`cor:teacher:fulltable`); windows below 0.1233 asymptotically (`prop:teacher:sharp`, `prop:teacher:rates`). Structured rules add a second kink and defeat the window (`prop:limits:envelope`, `prop:limits:rateblind`, `prop:limits:separable`).

**Flip-rate decimals** (verify-teacher §9). $G_1>H(p)$ holds exactly for $p<p_0=0.0559643\ldots$; the sufficient decimal printed everywhere (abstract, introduction, Paper 1 `sec:steep`) is $p<0.05596$, not the base's 0.056, which is false for a few dyadic rule sizes now that $s_0$ is arbitrary. The asymptotic junta window needs $1-\log(\frac32-p)>H(p)$, i.e. $p<p_1=0.1233072\ldots$; printed as $p\le0.1233$.

## 2. Ledger (generated from the sources in input order; numbers from the build of 2026-10-13)

Status and source are the environment's `\status{}` and `\src{}`; definitions carry `\src{}` only. Tables are listed after the environments of their file.

### `intro.tex`

| no. | id | kind: title | status | source |
|---|---|---|---|---|
| 1 | `tab:intro:claims` | table:  |  |  |

### `related.tex`

(no theorem-like environments)

### `setup.tex`

| no. | id | kind: title | status | source |
|---|---|---|---|---|
| 3.1 | `def:setup:data` | definition: Data |  | steeper \S1.1; split/iid Defs 1.1, 1.3; split/teacher \S1.0 |
| 3.2 | `rem:setup:objects` | remark: Which object; repeated inputs | remark | split/iid Remark 1.4(a),(b),(d); split/teacher \S1.0 |
| 3.3 | `def:setup:product` | definition: Product hypothesis; private randomness |  | steeper Def 1.1 |
| 3.4 | `def:setup:shared` | definition: Shared hypothesis |  | steeper Def 1.2 |
| 3.5 | `def:setup:class` | definition: Hypothesis class |  | steeper Def 1.3, \S1.2; split/iid Def 1.1 |
| 3.6 | `def:setup:objectives` | definition: Steeper objectives |  | steeper \S1.3 |
| 3.7 | `lem:setup:basic` | lemma: Basic properties | proved | steeper Lemma 1.1 |
| 3.8 | `rem:setup:persample` | remark: Per-sample form; $\lambda=cn$ gives batch objectives | remark | steeper \S1.3 |
| 3.9 | `lem:setup:hull` | lemma: Hull lemma | proved; computed; strengthening of (iv) refuted | steeper Lemma 1.2 (T5 Lemma 3.1); split/kink Thms 2.1, 2.2, Prop 2.3; checks c5(a), c6(F), k1, rB1 |
| 3.10 | `lem:setup:coding` | lemma: Coding bound | proved | steeper Lemma 1.6; split/kink Remark 2.5, Cor 3.3(a) |

### `absorb.tex`

| no. | id | kind: title | status | source |
|---|---|---|---|---|
| 4.1 | `rem:absorb:examples` | remark: Classes with an absorbing member | proved | steeper \S1.4, examples (1)--(5) |
| 4.2 | `thm:absorb:absorption` | theorem: Absorption | proved | steeper Thm 1 |
| 4.3 | `rem:absorb:reading` | remark: Reading | remark; known | steeper remarks after Thm 1 |
| 4.4 | `thm:split:shared` | theorem: SI, or SFI with shared randomness, $\lambda>1$ | proved; computed | steeper Thm 5; split/kink Prop 3.5; check c4(C); referee r4, q4(A) |
| 4.5 | `prop:absorb:pricing` | proposition: Per-input pricing | proved; computed | steeper Prop 1.3 (T5 Thm 2.1, Prop 2.2); check c2(a); referee r2 |
| 4.6 | `cor:absorb:nouniversal` | corollary: No universal product hypothesis | proved | steeper Cor 1.4 |
| 4.7 | `rem:absorb:wyeth` | remark: Answer to the absorption objection | remark; cites proved results | steeper \S1.8 |
| 4.8 | `q:absorb:shared` | question: shared hypotheses | open | steeper \S1.4; companion paper q:setting:rpf |

### `kinks.tex`

| no. | id | kind: title | status | source |
|---|---|---|---|---|
| 5.1 | `def:algstat:product` | definition: Structure functions and sufficiency |  | steeper \S3.5, product versions; split/kink \S1; split/teacher \S4 |
| 5.2 | `def:kink:kinks` | definition: Kinks, right lines and secants |  | split/kink Def 3.1; split/teacher Def 1.4, Remark 1.3; split/verify-teacher \S3 |
| 5.3 | `lem:kink:main` | lemma: The kink lemma | proved | split/teacher Lemma 1.1 (final form), Remark 1.2; split/verify-teacher \S2 |
| 5.4 | `cor:kink:locate` | corollary: Kinks locate the $\lambda$-MAPs | proved | split/kink Thm 3.2, Remark 3.2$'$; split/verify-kink \S6 |
| 5.5 | `cor:kink:split` | corollary: The split on one data set | proved | split/kink Cor 3.3 |
| 5.6 | `thm:kink:converse` | theorem: Stable MAP lengths occur only at kinks | proved | split/kink Thm 3.4 |
| 5.7 | `prop:kink:universal` | proposition: A universal member flattens every kink | proved | split/kink Prop 3.5; split/verify-kink \S5 |
| 5.8 | `rem:kink:reading` | remark: Reading | remark | split/kink \S6, Remark 3.6 |

### `recovery.tex`

| no. | id | kind: title | status | source |
|---|---|---|---|---|
| 6.1 | `def:split:setting` | definition: Samplers, equivalent programs, margins and fill-ins |  | steeper \S3.1; split/iid Defs 1.1--1.3; split/kink \S5.0 |
| 6.2 | `lem:split:ville` | lemma: Ville deficiency | proved; computed; Ville's inequality known | steeper Lemma 3.1; split/iid Lemma 2.2; split/verify-kink \S2.3; check c4(A); referee q3(B) |
| 6.3 | `thm:recovery:main` | theorem: Exact model recovery | proved | split/iid Thms 3.1, 3.2, 4.1(i)--(iv), (iv$'$); split/verify-iid \S1.2 |
| 6.4 | `rem:recovery:posterior` | remark: Concentration on $\mathcal E$, not on $\mathcal E_0$ | remark; a natural strengthening refuted | split/iid Thm 3.2 and the refutation after it |
| 6.5 | `rem:recovery:method` | remark: Method and literature | remark; known | split/iid \S3, remarks after Thm 3.1 |
| 6.6 | `prop:recovery:lambda1` | proposition: $\lambda=1$ against $\lambda>1$ | proved; computed | split/iid Prop 5.1(a),(b),(b$'$), Prop 4.4(b), Thm 4.1(iv$'$); split/verify-iid \S1.4 |
| 6.7 | `thm:recovery:kink` | theorem: A sample has a kink at the shortest equivalent length | proved | split/kink Lemmas 5.1--5.3, Thm 5.4, Cor 5.7(a),(d) (scheme (pq)); split/iid Lemma 8.1(i)--(iii); split/verify-kink \S2--\S3 |
| 6.8 | `rem:recovery:window` | remark: The $\ell_0$ in the right window | proved; a natural strengthening refuted | split/iid Lemma 8.1(iv); split/verify-iid \S1.7 |
| 6.9 | `cor:recovery:noisy` | corollary: Noisy computable functions | proved | split/iid Cor 6.1(i)--(v) |
| 6.10 | `thm:split:private` | theorem: Private randomness; any input rule | proved; computed; Kakutani-type argument known | steeper Thm 4; split/iid Prop 3.3, Prop 7.2(a); split/verify-iid \S1.1, \S2 item 4; check c4(C); referee r4, q3(C) |
| 6.11 | `prop:recovery:frozen` | proposition: Frozen labels | proved | split/iid Props 7.5, 7.6(b),(d) |
| 6.12 | `thm:split:lambda1` | theorem: SFI at $\lambda=1$ | proved | steeper Thm 3 |
| 6.13 | `rem:split:reading` | remark: What frozen labels give | remark | steeper \S3.3; split/iid Prop 3.3, Prop 7.5 |
| 6.14 | `q:recovery:open` | question: Rates, frozen labels, misspecification | open | split/notes-final \S6 items 1--6; split/iid Props 4.3, 4.4, Conj 7.4; split/kink \S8 |
| 2 | `tab:recovery:times` | table:  |  |  |

### `parity.tex`

| no. | id | kind: title | status | source |
|---|---|---|---|---|
| 7.1 | `def:teacher:instance` | definition: The instance |  | steeper Setting 2.0; split/teacher Prop 5.3 (any $s_0$); split/kink \S4 |
| 7.2 | `lem:teacher:list` | lemma: List decoding for semimeasures | proved; computed | steeper Lemma 2.1 (T5 Lemma 2.5a, generalised); checks c2(b), referee r3 |
| 7.3 | `lem:teacher:floor` | lemma: Risk floor | proved; computed | steeper Lemma 2.2 (T5 Lemma 2.5b); check c2(b) |
| 7.4 | `lem:teacher:coding` | lemma: Coding the error rule with a hypothesis | proved | steeper Lemma 2.3; referee r3, q2(c) |
| 7.5 | `lem:teacher:twopart` | lemma: Two-part lower bounds | proved | steeper Lemma 2.4 (T5 Thm 2.5(c)) |
| 7.6 | `lem:teacher:sharpfloor` | lemma: Randomness of the error rule sharpens the floor | proved; computed | steeper Lemma 2.2c (T5 Lemma 2.5c for semimeasures); check c7(C) |
| 7.7 | `prop:parity:kink` | proposition: A kink at the parity | proved | split/kink Prop 4.1 |
| 7.8 | `prop:parity:range` | proposition: The $\lambda$-range of ``parity plus noise'' | proved; computed | split/kink Prop 4.2, Cor 4.3; split/verify-kink \S4.1 |
| 7.9 | `def:algstat:set` | definition: Set models |  | steeper \S3.5, Definitions |
| 7.10 | `prop:parity:sets` | proposition: Set models have no steep kink at the parity | proved; computed | split/kink Prop 4.4; checks k8(D), rB2 |
| 7.11 | `rem:algstat:reading` | remark: Reading: one bit for one bit | remark | steeper \S3.5, Reading |
| 7.12 | `rem:algstat:restricted` | remark: Restricted model families | known; unverified (content per abstracts); remark | steeper \S3.5, relation to restricted model families |
| 7.13 | `q:parity:open` | question: set kinks | open | split/kink \S8 item 4; split synthesis \S6 item 7 |

### `teacher.tex`

| no. | id | kind: title | status | source |
|---|---|---|---|---|
| 8.1 | `rem:teacher:hanni` | remark: The three-hypothesis calculation | computed | steeper \S2.1; checks c1, T5 re-run |
| 8.2 | `lem:teacher:reuse` | lemma: Duplication | proved; computed | split/teacher Lemma 3.0; split/verify-teacher \S4; check t7(C) |
| 8.3 | `prop:teacher:schedules` | proposition: Which schedules keep the identification | proved; computed | split/teacher Prop 3.6, Prop 3.2(a); split/verify-teacher \S6; check v3 |
| 8.4 | `rem:limits:schedule` | remark: Fixed $\lambda$ against $\lambda\propto n$ | remark (from proved results); known | steeper end of \S2.5, \S4.4; split/teacher \S3.0, Remark 3.5 |
| 8.5 | `prop:teacher:kinks` | proposition: The two kink bounds | proved; computed | split/teacher Prop 2.1(a),(b); checks t1(B), rB2(E) |
| 8.6 | `thm:teacher:main` | theorem: The teacher's-mistakes theorem | proved | steeper Thm 2; split/teacher Prop 2.1(c), Remark 2.6 (a1); split/verify-teacher \S8 |
| 8.7 | `rem:teacher:numbers` | remark: Numbers for the running example | computed | steeper \S2.4 ``Numbers''; checks c3, c6(B), c7(D); referee r1, q4(B); split/teacher t6(D), v5(D) |
| 8.8 | `rem:teacher:hypotheses` | remark: What the theorem relies on | remark | steeper \S2.4 ``The hypotheses Theorem 2 relies on''; split/teacher Table 2.2 |
| 8.9 | `rem:teacher:selected` | remark: What is selected | remark; computed; a natural strengthening refuted | split/teacher \S2.1 ``What is selected''; checks t5(A),(B), rA1(A), rB3(A) |
| 8.10 | `cor:teacher:fulltable` | corollary: Full truth tables: the window starts at the reuse factor | proved; computed | steeper Cor 2.5 (T5 Thm 3.5, Cor 3.5a); split/teacher Props 3.1(a),(b), 2.4(iii); checks c3, c7(H), t1(D), rB2(B) |
| 8.11 | `cor:teacher:sampled` | corollary: Finite samples | proved; computed | steeper Cor 2.7, Lemma 2.6; check c3 |
| 8.12 | `prop:teacher:sharp` | proposition: Charging the information about the rule | proved; computed | split/teacher Lemma 5.1, Prop 5.2, Remark 2.6 (a2); split/verify-teacher \S6, \S8; checks t4(B), t6(B), rB7(B) |
| 8.13 | `prop:teacher:rates` | proposition: A window for every flip rate below $0.1233$, asymptotically | proved; computed | split/teacher Prop 5.3; split/verify-teacher \S9; checks t4(A), t6(A), rB7(A), v5(A),(B) |
| 8.14 | `q:teacher:open` | question: other models, flip rates, samples and schedules | open | steeper \S2.6; split/teacher \S5 ``What remains open'', Prop 3.3(c), Prop 3.6; split synthesis \S6 items 8--10, 12, 14 |
| 3 | `tab:teacher:numbers` | table:  |  |  |

### `limits.tex`

| no. | id | kind: title | status | source |
|---|---|---|---|---|
| 9.1 | `prop:limits:envelope` | proposition: Error envelopes | proved; computed | steeper Prop 2.17 (T5 Prop 4.5, all-hypothesis form); split/teacher Prop 2.1(d), Prop 4.1; split/verify-teacher \S2; check c7(B); referee q4(C) |
| 9.2 | `prop:limits:rateblind` | proposition: Rate blindness | proved; computed | steeper Prop 2.11; split/teacher Prop 4.2; final-check row 18; checks c3, c6(A) |
| 9.3 | `prop:limits:separable` | proposition: Separable components | proved; computed | steeper Prop 2.12 (T5 Thm 3.2, Thm 4.1); check c5(a) |
| 9.4 | `rem:limits:hull` | remark: What a hull cannot see | remark | split/teacher Remark 4.3; steeper Props 2.12--2.15 |
| 9.5 | `q:limits:open` | question: structured errors and the choice of $c$ | open | steeper \S2.6; split/notes-final \S6 items 11, 15 |

### `computable.tex`

| no. | id | kind: title | status | source |
|---|---|---|---|---|
| 10.1 | `prop:related:computable` | proposition: Computable product classes | proved; the examples are remarks | steeper Prop 4.4; split/iid Cor 6.2, Def 1.1; split/kink \S5.0 |
| 10.2 | `rem:computable:examples` | remark: Examples | remark | steeper Prop 4.4 |
| 10.3 | `prop:related:computability` | proposition: Computability of the steeper predictor | proved | steeper Prop 4.5 |
| 10.4 | `rem:related:nn` | remark: Neural-network Bayes | remark | steeper Rem 4.7; split/iid Def 1.1, Cor 6.2 |
| 10.5 | `q:related:open` | question: resource bounds and computability | open | steeper \S4.6 items 6, 7 |

### `discussion.tex`

| no. | id | kind: title | status | source |
|---|---|---|---|---|
| 4 | `tab:discussion:reasons` | table:  |  |  |

### `app-setup.tex`

| no. | id | kind: title | status | source |
|---|---|---|---|---|
| A.1 | `rem:setup:hullconverse` | remark: The converse in (iv) | proved; computed | steeper Lemma 1.2, refuted strengthening of (iv); check c6(F) |

### `app-absorb.tex`

| no. | id | kind: title | status | source |
|---|---|---|---|---|
| B.1 | `ex:split:noisyparity` | example: Noisy parity, full table: an illustration | computed; illustration | steeper Ex 3.4; check c4(C); referee q1(J) |
| B.2 | `rem:absorb:condsemi` | remark: The universal conditional semimeasure never learns | proved | steeper Rem 1.5 (T5 Thm 2.4) |
| B.3 | `rem:absorb:why` | remark: Why private randomness is what matters | remark; cites proved results | steeper \S1.6; foundations Thm 4.2, Prop 4.5, Rem 4.5a |
| B.4 | `prop:absorb:price` | proposition: The price of private randomness | proved; computed | steeper Prop 1.7; check c6(D) |
| B.5 | `prop:absorb:history` | proposition: Labelled history restores universality | proved; computed | steeper Prop 4.1 (T5 Prop 2.6); check c5(d) |
| B.6 | `prop:absorb:inputs` | proposition: A history of inputs only | proved | steeper Prop 4.2 |

### `app-kinks.tex`

| no. | id | kind: title | status | source |
|---|---|---|---|---|
| C.1 | `lem:kink:secant` | lemma: Lines against secants | proved | split/teacher Def 1.4, Lemma 1.5; split/verify-teacher \S3 |
| C.2 | `prop:algstat:product` | proposition: Steeper two-part codes over products | proved | steeper Prop 3.6; split/kink Cor 3.3 |

### `app-recovery.tex`

| no. | id | kind: title | status | source |
|---|---|---|---|---|
| D.1 | `lem:recovery:ratios` | lemma: Likelihood ratios | proved; strong law and Ville's inequality known | split/iid Lemmas 2.1, 2.2(b),(c); split/kink Lemma 5.1 (pq); split/verify-kink \S2.1 |
| D.2 | `prop:recovery:necessity` | proposition: What is necessary | proved | split/iid Props 4.2, 4.3, 4.4(a),(b), Remark 4.5; split/verify-iid \S1.5 |
| D.3 | `rem:recovery:frozentable` | remark: Frozen labels on a finite domain | proved | split/iid Cor 6.1(vi); split/verify-iid \S1.10 |
| D.4 | `prop:recovery:beyond` | proposition: Adaptive inputs, misspecification, $\lambda=cn$ | proved | split/iid Props 7.2(b), 7.3(iii$'$), 3.4(a)--(c); split/verify-iid \S1.3, \S1.8 |

### `app-split.tex`

| no. | id | kind: title | status | source |
|---|---|---|---|---|
| D.5 | `lem:split:stream` | lemma: Fill-ins from stored stream prefixes | proved; computed | steeper Lemma 3.2$'$ (adapts foundations Prop 4.4); check c7(A) |
| D.6 | `prop:split:si` | proposition: SI at $\lambda=1$ | proved; (iii) known | steeper Prop 3.3 |
| D.7 | `rem:split:siprograms` | remark: No split in SI's program representation | proved | steeper Rem 4.3 |

### `app-parity.tex`

| no. | id | kind: title | status | source |
|---|---|---|---|---|
| E.1 | `prop:algstat:set` | proposition: Steeper two-part codes over sets | proved; a natural reading refuted | steeper Prop 3.5 |
| E.2 | `rem:algstat:near1` | remark: $\lambda$ near $1$ | remark | steeper Prop 3.5, refuted reading |
| E.3 | `prop:algstat:coarse` | proposition: Sets from products | proved for computable hypotheses; that it is the standard set--distribution translation is believed (known; unverified) | steeper Prop 3.7 |
| E.4 | `q:algstat:lsc` | question: lower-semicomputable product models | open | steeper Prop 3.7, open part |
| E.5 | `prop:algstat:parity` | proposition: Sets against products | proved; computed | steeper Prop 3.8 (T5 Thm 2.5); split/kink Props 4.1, 4.4, Cor 4.3; checks c2(c), c4(C), c7(C) |
| 5 | `tab:parity:ranges` | table:  |  |  |

### `app-teacher.tex`

| no. | id | kind: title | status | source |
|---|---|---|---|---|
| F.1 | `prop:teacher:frozen` | proposition: Frozen noise, counted once or per query | proved | split/teacher Prop 3.7; split/verify-teacher \S7 |
| F.2 | `prop:limits:plain` | proposition: Plain Bayes, MDL and SI learn the errors | proved; computed | steeper Props 2.9, 2.10; checks c3, c6(G), c7(G) |
| F.3 | `lem:teacher:finite` | lemma: Finite sample | proved | steeper Lemma 2.6 (adapts T5 Lemma 1.2) |
| F.4 | `ex:teacher:version1` | example: The total-bits version of the example | proved (instance of \cref{thm:teacher:main}); computed | steeper Ex 2.7a; checks c6(C), c6(H) |
| F.5 | `prop:teacher:concentration` | proposition: The power posterior concentrates on near-minimisers | proved; computed | steeper Prop 2.8; checks c5(e), c7(F); referee q1(F) |
| 6 | `tab:teacher:rates` | table:  |  |  |

### `app-limits.tex`

| no. | id | kind: title | status | source |
|---|---|---|---|---|
| G.1 | `lem:limits:robust` | lemma: The criterion is robust in the machine constant | proved; computed | steeper Lemma 2.11a; check c6(A) |
| G.2 | `prop:limits:guard` | proposition: Guard erosion | proved; computed | steeper Prop 2.13 (T5 Prop 4.4); checks c5(b), c6(G), c7(E); referee q1(I) |
| G.3 | `prop:limits:noident` | proposition: $\lambda$ cannot be chosen from imitation data | proved; computed; (i) known | steeper Prop 2.14 (T5 Thm 4.3); check c5(c) |
| G.4 | `prop:limits:inputlaw` | proposition: The selection depends on the input law | proved | steeper Prop 2.15 |
| G.5 | `prop:limits:ood` | proposition: Steeper simplicity and unseen properties | proved | steeper Prop 2.16 |

### `app-related.tex`

(no theorem-like environments)


## 3. Answers to the author's questions (Paper 2's share), updated

* **"A nice theorem saying model + data splits work, at least in some contexts."** `thm:recovery:main` (Theorem A of the introduction): per query, exact for every $1\le\lambda_n=o(n)$, with a margin rate for fixed λ > 1; on one data set, `cor:kink:split` (Theorem B) at every kink; the noisy parity's full table has such a kink (`prop:parity:kink`, `prop:parity:range`).
* **Sampler versus fill-ins.** At λ = 1 similar posterior weight on a data set (`thm:split:lambda1`, `prop:split:si`); per query λ = 1 has the same limit, but no class-free rate (`prop:recovery:lambda1`); for fixed λ > 1 fill-ins have exponentially small posterior mass at every n (`thm:recovery:main`(c), `thm:split:private`(iii)); with shared randomness or in SI, no long sampler is selected (`thm:split:shared`).
* **The teacher's mistakes.** For incompressible product-form error rules at $p<0.05596$, every near-optimal hypothesis knows the parity and not the errors, for $c\in(2^{-m},c_{\rm hi})$ (`thm:teacher:main`); "the good model is a hull vertex on the whole window" fails in explicit rate codes (`rem:teacher:selected`); λ must grow with n because of the reuse factor (`lem:teacher:reuse`), while noise needs only a fixed λ > 1; not for every rule with the same density and description length (`prop:limits:envelope`).
* **Change of slope of the entropy left against hypothesis length.** Made precise as a kink (`def:kink:kinks`, `cor:kink:split`, `thm:kink:converse`); present for product models of the noisy parity at every flip rate below 1/4 for large d, absent for set models (`prop:parity:kink`, `prop:parity:range`(iii), `prop:parity:sets`).
* **Absolute complexity bound.** Every penalised minimiser solves a length-bounded problem, not conversely (`lem:setup:hull`(iv), `rem:setup:hullconverse`).
* **Prior work.** λ-weighted two-part MDL in noisy classification, two-part MDL for density estimation (Barron and Cover, "studied by" only), restricted model families (`rem:related:mdl`, `sec:related`, `rem:related:new`).

The notation swaps and corrections relative to the steeper record of the base version (former §2, P1–P14) are in the base file (`git show dcb3a3a3:solomonoff-function-induction/paper-steeper/CLAIMS.md`); the restructure's notation is `PLAN.md` §4.
