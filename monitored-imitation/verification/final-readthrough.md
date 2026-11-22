# Final read-through of `paper/verified-slack-imitation.tex`

*Pre-delivery read by Claude (Anthropic), 22 November 2026, of the 28-page build of 09:28 (the PDF matches the source). No existing file was changed. Line numbers are .tex lines.*

## Verdict

The paper can go out after the eleven must-fix items in §3, most of them one-line edits.
* **Proposition 11.1 has one real gap,** about cached notebooks. Its argument and constants are right.
* **"Beyond determinism"** drops conditions that thread Z states, and overstates one result.
* **One headline figure disagrees** across sections (40% against 40–45%).
* **One figure caption is false.**
* **The abstract runs to about 490 words.** A 248-word replacement is at the end.

## 1. The new mathematics

### Proposition 11.1 (agnostic cost)

**What checks out.**
* *Hit-first order.* Weighted-majority (WM) weights depend only on the multiset of trials. If the hit is listed first in its round, its prediction comes from exactly the earlier rounds' data. That prediction is the decoder that committed the step, so each hit is a WM mistake and R ≤ M. If the round's other queries came first, they could flip the prediction at the hit.
* *The WM bound with many labels.* When the plurality label is wrong, the true label holds at most half the weight. So w(h)β^{M_h} ≤ ((1+β)/2)^M, which gives c₁M ≤ K_h + c₂M_h.
* *The trial count.* In S, U, S, H the scan's j-th notebook is query 2j−1, and the first mistake lies below n₀ (Lemma 4.2). So a search makes at most 2n₀−1 queries, and the trials number at most 2n₀R + A.
* *The constants.* At β = ½, c₁ = 0.415 and c₂ = 1, and rounding c₁ down to 0.41 keeps the bound valid. The exact threshold is ε_h < 0.2075/n₀.

**Gaps.**
1. **Caching (must fix).** The scan skips cached notebooks (l. 130). Under exact Bayes a cached notebook is never a mistake. A WM learner can still mislabel one: 90% of the weight on a wrong label is still 0.45 against 0.10 after one trial at β = ½. The scan can then pass over the first mistake. The search either runs to 2n or abstains wrongly, which breaks l. 590 and the 2n₀R + A count. Cache-first decoding (as in Prop. 4.10) closes the gap, and so does dropping the cache.
2. **The gloss (l. 600).** Only the scan's queries, about half of all queries, fall on the human's own chains. The U and H queries fall on the imitator's runs after their first mistake, so h must be accurate there as well.
3. **Hygiene.**
   * ε_h is pathwise and counts repeated queries.
   * The WM factor β is also the audit rate, inside a statement that counts audits.
   * "Audits only at the round's end" is always true.
   * Total queries are not stated.
   * With audits, R grows linearly in T.
   * Needing ε_h < 1/(5n₀) means one step in 120 at n₀ = 24, under exact equality of three-month steps. That is close to realizability, so "rarely mislabels" (Verdict, l. 622) undersells the condition.

### "Beyond determinism" (l. 602–609) against thread Z

* **Stochastic style.**
  * Two of Z1's conditions are missing: V reads only canonical notebooks (S3), and (A1)–(A3′) hold for the content map (S4).
  * So is Z's caveat that this "covers little of the real noise".
  * π is not defined here. Elsewhere it is the posing round (§5) and the canonicalization map (§7.2).
* **Occasional deviations.**
  * Lemma Z2 says the potential falls by *at least* 1−h(δ), and only in expectation.
  * Four conditions are omitted:
    * a learner over *stochastic* hypotheses (a deterministic class refutes the human at its first deviation);
    * deviation probability *at most* δ, fresh at every query;
    * (A2-C) and (A3′-C), on the core's chain;
    * no asks.
  * The learner decodes the *posterior's* most likely step, not the core's.
  * Re-asks are "necessary" only for decoder-based protocols (Z12).
  * The figure 1.9n₀K is right: 1/(1−h(0.1)) = 1.88.
* **No dominant choice: overstated.** Z10 is an example (H = {P}, K = 0, a fair coin), not an implication from "no deterministic imitator succeeds".
* **VSI-D.** It matches Z8 exactly. "Run it, up to m times" should say a fresh draw each time.
* **Toy and probabilities.** These are faithful: chained imitation correct 3–22% of the time, VSI-D at 0.69–1.12 queries per problem, abstentions up to 63%, and 45% / 60%.

## 2. The read-through

**Numbers.** These agree across the abstract, introduction, Table 1, §5, §9, §10, §11 and the Verdict: 70%; 25%; 45% (55/31); 50/60 and 15/20; 2n₀K; 7–45 days; 4Λ ≈ 16 (15.4); and 480. The exceptions:
* 40% (l. 69, l. 496) against 40–45% (l. 47, l. 622).
* The Figure 2 caption says the silent-human slack line is not plotted. It is the red dotted line in panel (a).
* Lines 47 and 65 drop "expected" from Theorem 4.13's bound.
* Line 475 still conditions on "reaches the informal goal within n₀", which contradicts the heavy-tail abstentions at l. 431 and l. 500. Referee 10 flagged this.

**Clarity.**
* The answer (VSI with a proof assistant on a reviewed statement) is named as such only in the Verdict, on p. 25.
* The introduction uses b, c, q, β, L, p, d and r₀ before defining them (l. 65–67).
* p is also the first-run failure rate, used at l. 313 before its definition at l. 424.
* h is a hypothesis, the binary entropy and the fuel.
* Line 587 says there is "no guarantee unless…" just before Proposition 11.1 gives one.
* Line 71 does not mark the §11 results as unrefereed.

**Layout.** There are no overfull boxes.
* **Page 20 is about 45% blank.** Figure 2 is `[t]` and is pushed to p. 21 by the placeins barrier at §10. A scratch build with `[!htb]` removes the gap and stays at 28 pages.
* **Table 1:**
  * "statement fidelity, checker" is stretched (underfull, badness 10000);
  * rows wrap and leave "ing" and "verifier" alone on a line;
  * the formal rows' 70% sits under a header that reads "theory, software".

## 3. Fixes

### Must fix (errors and inconsistencies)

1. **l. 590, 593.** After "(each round's hit first)" add ", with cache-first decoding (Proposition~\ref{prop:any-learner}): a weighted-majority learner can still mislabel a notebook whose answer it holds, and the scan, which skips cached notebooks, would pass over that mistake". At l. 593, replace "no asks, local check or bizarre check, and audits only at the round's end" with "cache-first decoding, and no asks, local check or bizarre check".
2. **l. 600.** Replace with: "So realizability can be weakened to a simple hypothesis that mislabels fewer than about one in $5n_0$ of the notebooks VSI queries (one in 120 at $n_0=24$, with exact equality of steps). Only the scan's queries lie on the human's own chains; the uniform and pointer queries lie on the imitator's runs. With the scan alone, all queries are on the human's chains and $2n_0$ becomes $n_0$. Correctness is unaffected."
3. **l. 590–595.**
   * Rename the WM factor to $\lambda$.
   * Write "on every path on which $h$ mislabels at most a fraction $\varepsilon_h$ of VSI's task queries (counted with repetition)".
   * Add "VSI makes at most $2n_0R+A$ task queries; with audits, $A\approx\beta T$, so $R$ grows linearly in $T$".
   * Write "$\varepsilon_h<0.205/n_0$".
4. **l. 606.** Replace "If no deterministic imitator's run succeeds reliably, every" with "There are humans, even with $\K=0$ (a fair coin chooses the first entry, and $V$ accepts one value), on which every". After "cannot survive", add "in general".
5. **l. 605.** Replace "If the human has … in all." with: "If the human writes a deterministic core $C$'s step with probability at least $1-\delta>\frac12$, deviating independently at every query (repeats included), then for a Bayes learner over stochastic hypotheses that contains the human (a deterministic class refutes it at its first deviation), a query at which the decoder disagrees with $C$ lowers the expected log-loss potential by at least $1-H_2(\delta)$ bits ($H_2$ the binary entropy), though one answer certifies nothing. Decoding the posterior's most likely step, with no asks, and on each rejection asking once at each of the run's first $n_0$ notebooks gives $\Ex[\text{rejections}]\le\K/(1-H_2(\delta))$ if $C$'s chain reaches $\Sv$ within $n_0$ and $V$ accepts its extensions: at $\delta=0.1$, about $1.9n_0\K$ task queries in expectation." Then change "(which is necessary)" to "(necessary for decoder-based protocols)".
6. **l. 604.** Replace with: "If a fixed canonicalization (Section~\ref{sec:case}) removes all the noise, the scaffold stores and shows only canonical entries, $V$ reads only canonical notebooks, and (A1)--(A3$'$) hold for the content map, every result transfers to that map, at a cost of at most the canonicalization's complexity plus $O(1)$ bits. Three-month steps vary mostly in content, so this covers little of the real noise."
7. **l. 69, 496.** Write "about 40\% without that conditioning (45\% with the unrefereed stochastic variants of Section~\ref{sec:practice})". In the caption add ", 45\% with those variants \cite{threadZ}".
8. **l. 513.** Change "(that line is not plotted)" to "(red dotted line)".
9. **l. 622.** Change "rarely mislabels the human's steps" to "mislabels fewer than about one in $5n_0$ of the queried steps, which is close to realizability".
10. **l. 65, 47.** Write "the expected number of rejections that end in a hit", and "at most $c+1$ per rejection that ends in a hit, in expectation".
11. **l. 475.** Change "that reaches the informal goal within $n_0$" to "that finishes".

### Should fix (clarity and layout)

12. **l. 47:** use the abstract below.
13. **After l. 54, insert:** "\paragraph{Our answer.} The scheme we are most sure of is verified slack imitation with a proof assistant checking an independently reviewed formal statement: give the imitator slack, rerun each problem until the proof checks, and on a rejection scan the run from the start until its first step that differs from the human's. Outputs are correct if the statement and the checker are; the search costs at most $2n_0\K$ task queries over any number of problems. We put it at about 70\% given the idealizations."
14. **l. 510:** use `\begin{figure}[!htb]` (tested).
15. **l. 65–67:** drop "/b" (say $b=1$ without asks), and gloss c, q, β and L. Add "($d$ the depth of the lemma tree, $r_0$ the rounds per lemma, $p$ the round by which lemmas are posed)".
16. **l. 480–488, Table 1:**
    * use `>{\raggedright\arraybackslash}p{5.6cm}>{\raggedright\arraybackslash}p{3.3cm}cc` and add `\usepackage{array}`;
    * change the header to "formal; theory, software";
    * write "same, unreviewed and unhardened".
17. **l. 496:** delete the draft history ("An earlier draft put VSI-R at 58\% / 66\% … \cite{redteam3}.").
18. **l. 313:** write "about $p\,w\,f$ ($p$ the first-run failure rate)", or rename it $p_{\mathrm f}$ at l. 313, 424 and 560.
19. **l. 433, 604:** give the canonicalization map a name other than $\pi$, and note at l. 604 that the bound is an upper bound; at l. 433, dropping style lowers it.
20. **l. 587:** append "or, for a weighted-majority learner, a simple hypothesis rarely mislabels the queried steps (Proposition~\ref{prop:agnostic})".
21. **l. 71:** add "Proposition~\ref{prop:agnostic} and the stochastic results of Section~\ref{sec:practice} \cite{threadZ} are unrefereed."
22. **l. 607:** write "draw a hypothesis from the posterior and run it, with a fresh draw each time, up to $m$ times".
23. **l. 556:** write "about 40\%, below chain VSI-R's 50\%".
24. **l. 103, 77–79:** drop "(the \emph{design law})", which is never used, and change "$D$" to "$\mathcal D$".
25. **l. 616, 665:** cut the baseline sentence that repeats l. 504, and cite referee 10 in Appendix C.

## Proposed abstract (248 words)

> A learner imitates a human researcher, modelled as a fixed deterministic program $P$, by Bayesian (Solomonoff-style) induction on the human's three-month steps. The baseline, chained imitation, needs about $n\K/\varepsilon$ task queries for failure rate $\varepsilon$ on $n$-step runs, where $\K=\K(P)$; on humans whose insights are rare, problem-specific and never recovered once missed, every protocol that asks only for task steps needs nearly that. The scheme we are most sure of is \emph{verified slack imitation} (VSI) with a proof assistant on an independently reviewed formal statement: the imitator gets $n=n_0+\sigma$ steps where the human needs $n_0$, each problem is rerun until the proof checks, and a rejected run is scanned from the start for its first step that differs from the human's. Correctness then rests on the statement and the checker alone. If the human is in the learner's class and its own chain reaches a verifiable solution within $n_0$ steps, there are at most $\K$ rejections, each located within $2n_0$ task queries: at most $2n_0\K$ in all, with no $1/\varepsilon$, within a logarithm of optimal even with a perfect verifier. So $O(\K)$ fails in the worst case; it holds under bounded setback, and on formal blueprints a rejection costs at most about 7--45 one-day queries, independent of the size of the work. We put the probability that VSI works at about 70\% given the idealizations (40--45\% without), 50--60\% for informal theory and software with combined human and AI verifiers, and 15--20\% for empirical work.
