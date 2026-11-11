# Depth two: Theorem 5.1, Corollary 5.2 and Proposition 5.3 of the red-team report, corrected

*This is a research note of the agnostic-learning note ([`../README.md`](../README.md)). It replaces §5 of the red-team report ([`red-team.md`](red-team.md), "Depth two ($L=2$) with $c=1$") and keeps its numbering: Theorem 5.1, Corollary 5.2 and Proposition 5.3, and the red-team lemmas they use, Lemma 1.0(1), Lemmas 1.1–1.3 and the depth-two part of Lemma 2.1, which §2 states and proves. The note was refereed in two rounds, each by a logic referee and a computation referee, and then re-refereed twice during finalization, each time by a scope referee and a logic-and-computation referee. The first round, on `red-team.md` §5, is [`../verification/RT-depth2-logic.md`](../verification/RT-depth2-logic.md) and [`../verification/RT-depth2-computation.md`](../verification/RT-depth2-computation.md), answered in §8. The second round, on the repaired text, is [`../verification/RT-depth2-logic-revised.md`](../verification/RT-depth2-logic-revised.md) and [`../verification/RT-depth2-computation-revised.md`](../verification/RT-depth2-computation-revised.md), answered in §9. Remarks 5.2a, 5.3a and 5.7a were added in answer to the second round, and its referees did not see them: the first two write out examples of the second-round logic referee, and the third combines refereed statements of [`B-tempered-likelihood.md`](B-tempered-likelihood.md). The first re-refereeing round, [`../verification/depth-two-referee-scope-1.md`](../verification/depth-two-referee-scope-1.md) and [`../verification/depth-two-referee-logic-computation-1.md`](../verification/depth-two-referee-logic-computation-1.md), examined these remarks and the other answers to the second round. The second re-refereeing round, [`../verification/depth-two-referee-scope-2.md`](../verification/depth-two-referee-scope-2.md) and [`../verification/depth-two-referee-logic-computation-2.md`](../verification/depth-two-referee-logic-computation-2.md), examined the text as revised after the first, including the material added in answer to it: chiefly the paragraph of Remark 5.7a on Proposition 9.1 of `B-tempered-likelihood.md` and the record of the red-team optimisation runs in §7.1. Both re-refereeing rounds returned "minor fixes", and §9 records how each of their points was resolved. The changes made in answer to the second re-refereeing round (§0.6) have not been refereed again. Remark 5.2b and the passages of §0.2 and Remark 5.7a that report observations of the scope referee of that round are marked as such and have not been refereed. The proofs are paper proofs with numerical checks; nothing here is verified in Lean. The scripts and their outputs are in [`../checks/depth-two/`](../checks/depth-two/) (§7). The brief is [`problem-brief.md`](problem-brief.md). `NNG/` denotes the project folder `neural-network-generalization/` of this repository, and "RT" abbreviates `red-team.md`.*

---

## 0. Results and what changed

**What is refuted at depth two, and what is not.** Everything below concerns depth-two SP$_c$ in the strong-prior limit (§1.1). The failures proved here are on the cube family: $n=\lceil\lambda2^d\rceil$ samples with inputs uniform on $\{-1,1\}^d$ and fair-sign labels, at learner widths $N\ge N_0$, where $N_0=O(n\log^4n)$. Section 1.4 defines the two formulations. Both are properties of one learner, and the conjecture of `problem-brief.md` §1 lets us pick the learner. At depth two the conjecture is not refuted in either formulation: the tempered SP$_c$ of `B-tempered-likelihood.md` (B below) has (P$_2$) and (P$_2^{o(1)}[\log_2n+C_0]$) in the clipped readings, for example with $c=n^{1/2}$ (B's Theorem 6.3 with $\theta=1/2$, and its Corollary 8.1 with $\alpha=1/16$). What is refuted is that SP$_c$ has these properties for the values of $c$ named below.

- **The polynomial-sample property (P$_2$) fails for every $0<c\le\mathrm{poly}(d)$, that is, for every $c\le\mathrm{polylog}(n)$** (Corollary 5.2(a)). The excess is at least $\gamma(\lambda)(18dc+1)^{-2}(1-o(1))$, with $\gamma(1)=0.0999$. When $dc\to\infty$, for example at $c=1$, this lower bound tends to $0$, but only polylogarithmically in $n$, and that suffices to defeat every polynomial sample bound. Remark 5.2b, which is not refereed, extends this failure to every $c\le n^{o(1)}$. (P$_2$) also fails for every $c\ge n^{1-o(1)}$, by B's Proposition 9.1 on a two-point law in dimension $1$ (Remark 5.7a).
- **The "$+o(1)$" formulation (P$_2^{o(1)}[\log_2n+C_0]$) fails for $c\le\nu/\log_2n$** (Corollary 5.2(b)). The excess is at least $\Gamma_\lambda(\nu)-o(1)$, where the constant $\Gamma_\lambda(\nu)$ is at least $\gamma(\lambda)/(18\nu+1)^2$, and at least $\beta(\lambda)-o(1)$ when $c\log n\to0$ ($\beta(1)=0.4848$). The formulation asks for the bound at every learner width $N\ge n^\alpha$, and the failure holds at every $N\ge N_0$, so it occurs at widths the formulation covers, for every $\alpha>0$. By the same Proposition 9.1 of B, the formulation also fails for every $c\ge n^{1-o(1)}$.
- **The case $dc\to\infty$ (equivalently $c\log n\to\infty$), for example $c=1$, is open for the "$+o(1)$" formulation while $c=O(\log^2n)$ in the clipped readings, and while $c=O(\sqrt n\log n)$ in the unclipped ones.** Above these ranges results of B settle it (Remark 5.7a): the formulation holds for the clipped readings when $\log^2n\ll c\le n^{1-\epsilon}$, holds for all readings when $\sqrt n\log n\ll c\le n^{1-\epsilon}$, and fails for every reading when $c\ge n^{1-o(1)}$. At $c=1$ the lower bound of Corollary 5.2 tends to $0$ and the known upper bound does not. Sequences $c(n)$ that move between these ranges are not classified.
- **Not covered:** learner widths below $N_0$ (at widths $N=o(n/\log^2n)$, clipped near-minimizers have vanishing excess on this example when $n^{-O(1)}\le c\le\mathrm{poly}(d)$; Remark 5.5), the progressive-mixture predictor (Remark 5.6), and a fixed input dimension, at which the cube family is learned consistently when $c=o(n)$, but not under (R3) when $c$ is of order $n$ (§0.2, "Input dimension"). For $c\ge n^{1-o(1)}$, B's two-point laws defeat SP$_c$ in every reading already in dimension $1$, and for $c\ge n/4$ one fixed law does (Remark 5.7a).
- **Proposition 5.3** (Hadamard atoms, $d=M\asymp n$) **refutes no formulation of the conjecture.** At $d\asymp n$ no learner whatever competes with networks of width and weights $n^\alpha$ up to $o(1)$ (Remark 5.3a). What Proposition 5.3 shows is that SP$_c$ with $c=o(\sqrt n)$ is worse than the zero network, which is Bayes-optimal there, by $\beta(\lambda)-o(1)$, at every width, for inputs of norm $\sqrt d$.

**Relation to the open items of B.** Two items that B lists as open were written before this note: §0 "Still open" lists "Depth two with $c=O(\mathrm{polylog}\,n)$", and §11 "Open" (iii) lists "The negative side at depth two for $c=\mathrm{polylog}(n)$; known only from the red-team report". This note supersedes item (iii) for (P$_2$), and for the "$+o(1)$" formulation when $c\le\nu/\log_2n$: the negative side there is Corollary 5.2, refereed in two rounds. It narrows the §0 item to the open range of the third bullet above, which contains polylogarithmic $c$ such as $c=\log n$; there the negative side of the "$+o(1)$" formulation remains open. For $c\le\mathrm{polylog}(n)$, (P$_2$) fails; the "$+o(1)$" formulation fails for $c\le\nu/\log_2n$, and it holds in the clipped readings for $\log^2n\ll c$, which includes $c=\log^3n$ (Remark 5.7a, from B's Proposition 6.1 and Lemma 5.3). B's §7.5 item 3 cites `red-team.md` Theorem 5.1; that theorem is Theorem 5.1 of this note. The transition that item places at $c=O(\mathrm{polylog}\,n)$ is that of the excess on the cube, from constant to vanishing, which is the transition of the "$+o(1)$" formulation; for (P$_2$), every $c\le\mathrm{polylog}(n)$ fails (Corollary 5.2(a)).

### 0.1 Results

Throughout:

- the depth is $L=2$;
- $D_d$ is the cube example: $x$ is uniform on $\{-1,1\}^d$, and $y$ is a fair sign independent of $x$;
- $M=2^d$ and $n=\lceil\lambda M\rceil$ for a fixed $\lambda>0$;
- SP$_c$ is the strong-prior learner with Gaussian likelihood and variance ratio $c>0$. Its posterior is taken in the limit $\sigma\downarrow0$, with the sample and the learner width $N$ fixed first.

Every predictor has test MSE at least $1$, and the zero network attains $1$. So "excess" means test MSE minus $1$.

1. **Theorem 5.1 (every $c>0$).** Fix any sample and any learner width $N\ge N_0(a)=\lceil72dn\ln(2M)/a^2\rceil+1$, where $a\in(0,1]$ is a free accuracy parameter. Then every near-minimizer $w$ of the posterior energy has training residual $\mathcal R(z_w)\le(1-\vartheta_c)G+E_0$, where $\vartheta_c=1/(18dc+1)$. Its excess is therefore at least $\max\{\Psi_{\rm tri},\Psi_{\rm cor}\}$. The same lower bound holds in the strong-prior limit for Gibbs draws, Gibbs risks and posterior means, clipped or not.
2. **Corollary 5.2 (asymptotics, and what is refuted).** On an event of probability $1-o(1)$, at every width $N\ge N_0(a_d)$ with $a_d\to0$:
   - **(i)** for every $0<c\le\mathrm{poly}(d)$ the excess is at least $\gamma(\lambda)(18dc+1)^{-2}(1-o(1))$. So SP$_c$ with these $c$ fails the polynomial-sample property (P$_2$) of `problem-brief.md` §1.
   - **(ii)** if $c\le\nu/d$, the excess is at least the constant $\Gamma_\lambda(\nu)-o(1)$, where $\Gamma_\lambda(\nu)\ge\gamma(\lambda)/(18\nu+1)^2$.
   - **(iii)** if $dc\to0$, the excess is at least $\beta(\lambda)-o(1)$. This is the depth-$\ge3$ constant, with $\beta(1)=0.4848$.
   - By parts (ii) and (iii), SP$_c$ fails the "$+o(1)$" formulation (P$_2^{o(1)}$), with the $o(1)$ uniform over $d\le\log_2n+O(1)$ and the bound required at every learner width $N\ge n^\alpha$, for every $c(n)\le\nu/\log_2n$.
   - **(iv)** if $dc\to\infty$ (for example any fixed $c$, including $c=1$), the bound of Theorem 5.1 tends to $0$. It then says nothing about the "$+o(1)$" formulation.
3. **Proposition 5.3 (Hadamard atoms, $d=M$).** At every width $N\ge1$, and for every $c\le\nu\sqrt M$ with $\nu<\sqrt{\beta(\lambda)}/2$, the excess is at least $\beta(\lambda)\bigl(1-\sqrt{2\nu/\sqrt{\beta(\lambda)}}\bigr)^2-o(1)$. For $c=o(\sqrt M)$ it is at least $\beta(\lambda)-o(1)$. The inputs have Euclidean norm $\sqrt d$. For unit-ball inputs the same argument gives a constant only when $c<\sqrt{\beta(\lambda)}/2$ (Remark 5.4); it gives nothing at $c=1$. The zero network is Bayes-optimal for this law, so these are amounts by which SP$_c$ is worse than the zero network. No formulation of the conjecture is refuted (Remark 5.3a).

### 0.2 Scope

| Formulation (defined in §1.4) | Depth-two status |
|---|---|
| (P$_2$): polynomial sample size, all $d$, all learner widths $N\ge m$ | **refuted** for every $0<c\le\mathrm{poly}(d)$ (Cor. 5.2(a)). **Fails** for every $c\ge n^{1-o(1)}$, already in dimension $d=1$, and for $c\ge n/4$ already on one fixed law (B Prop. 9.1; Remark 5.7a). **Holds** for the clipped readings at $c=n^{1-\theta}$, $0<\theta<1$, and for the unclipped ones at $c=n^{1-\theta}$, $0<\theta<1/2$ (B Theorems 6.3 and 6.4). By (5.7a) and its unclipped variant, which is not refereed (Remark 5.7a, "General $c$, the polynomial-sample property"), it also holds for the clipped readings whenever $n^a\le c(n)\le n^{1-a}$ for a fixed $a>0$, and for the unclipped ones whenever $n^{1/2+a}\le c(n)\le n^{1-a}$ (Remark 5.7a). **Not classified** here: $c$ that exceed every power of $\log n$ but are at most $n^{o(1)}$ (Remark 5.2b, which is not refereed, puts them on the failing side); for the unclipped readings also $c\ge n^a$, for some $a>0$, with $c\le n^{1/2+o(1)}$; and sequences $c(n)$ that move between these ranges |
| (P$_2^{o(1)}[\log_2n+C_0]$): $o(1)$ uniform over $d\le\log_2n+C_0$, all learner widths $N\ge n^\alpha$ | **refuted** for every $c(n)\le\nu/\log_2n$, $\nu>0$ (Cor. 5.2(b)). **Fails** for every $c\ge n^{1-o(1)}$ (B Prop. 9.1, $d=1$; Remark 5.7a). **Holds** for the clipped readings when $\log^2n\ll c\le n^{1-\epsilon}$, and for all readings when $\sqrt n\log n\ll c\le n^{1-\epsilon}$ (Remark 5.7a, from B). **Open** when $c\log n\to\infty$ and $c=O(\log^2n)$ (clipped readings) or $c=O(\sqrt n\log n)$ (unclipped readings); this includes every fixed $c$, e.g. $c=1$ (Remarks 5.7a, 5.8) |
| "$+o(1)$" with the $o(1)$ uniform over $d\le n$, or over $d$ up to a fixed fraction of $n$ | **false for every learner** (Remark 5.3a), so it cannot separate SP$_c$ from other learners. Proposition 5.3 shows that SP$_c$ with $c=o(\sqrt n)$ is worse than the Bayes-optimal zero network by $\beta(\lambda)-o(1)$, for inputs of norm $\sqrt d$. For unit-ball inputs it shows a constant gap $\beta(\lambda)\bigl(1-\sqrt{2c/\sqrt{\beta(\lambda)}}\bigr)_+^2-o(1)$ only for $c<\sqrt{\beta(\lambda)}/2$, the full $\beta(\lambda)-o(1)$ only when $c\to0$, and nothing at $c=1$ (Remark 5.4) |
| fixed $d$ | **not refuted** by the cube family when $c=o(n)$. At every width its excess is at most $(8\cdot2^d/\delta+4c)/n$ with probability at least $1-\delta-2^de^{-n/2^{d+3}}$, that is $O((2^d/\delta+c)/n)$, which tends to $0$ when $c=o(n)$ and is $O(2^d/n)$ for bounded $c$ (`A-tight-conditioning-fails.md` Prop. 5.2(c) with $t=1$, refereed). The bound grows like $1/\delta$, not like $\log(1/\delta)$: it shows that the family does not refute the "$+o(1)$" formulation at a fixed $d$, while for (P$_2$) "not refuted" means only that no refutation is known. When $c\ge C_1n$, $C_1\approx5.83$, near-minimizers (R3) fail on the cube itself at every fixed $d$, and the scope referee of the second re-refereeing round observes the same at $d=1$ for every $c$ of order $n$ ("Input dimension" below). For $c\ge n^{1-o(1)}$, (P$_2$) restricted to $d=1$ fails under every reading on B's two-point laws, which change with $n$, and for $c\ge n/4$ on one fixed law (first row) |

The failures proved in this note, those of Corollary 5.2, and the comparison of Proposition 5.3 hold under the following restrictions. The failure for $c\ge n^{1-o(1)}$ taken from B holds at every learner width and for every reading, in dimension $1$ (Remark 5.7a).

- **Widths.** Learner widths $N\ge N_0$. For Theorem 5.1 with $a=1/d$, $N_0=O(n\log^4n)$. For Proposition 5.3, any $N\ge1$. Nothing is proved at smaller widths (Remark 5.5). Both formulations ask for the bound at every width at least the competitors' width bound, so a failure at every $N\ge N_0$ shows that SP$_c$ does not have them.
- **Predictors.** Near-minimizers, Gibbs draws, Gibbs risks and posterior means, clipped or not: the readings (R1), (R1′), (R2) and (R3) of §1.4. The progressive-mixture predictor is not covered (Remark 5.6).
- **Input dimension.** The cube family has $d=\log_2n+O(1)$. At a fixed $d$ it is learned consistently when $c=o(n)$ (last row of the table). When $c$ is of order $n$, near-minimizers fail on the cube itself, already at a fixed $d$.
  - For $c\ge C_1n$ with $C_1=2(1+\sqrt{1/2})^2\approx5.83$, every $w$ with $\kappa_N(w)\le1/2$ lies in $\mathcal N_1(S)$, and at every width and every $d$ this set contains constant networks with nonzero output, whose excess does not depend on $n$ (`A-tight-conditioning-fails.md`, the paragraph after Proposition 8.3, at slack $t=1$).
  - The scope referee of the second re-refereeing round observes the same for every $c\ge n/k$ with $k$ fixed. Since $\min F_{c,S}\ge W/c$, every $w$ with $\kappa_N(w)+\mathcal R(z_w)/c\le1$ lies in $\mathcal N_1(S)$, and at $d=1$ some constant output of size of order $k^{-1/2}$ qualifies, with excess of order $1/k$ whatever $n$. The referee's script certifies, at $d=1$, near-minimizers with excess at least $0.050$ at $c=n/10$ and at least $0.085$ at $c=n/4$, on each of 200 samples for each $n\in\{10^3,10^4,10^5\}$ ([`../checks/depth-two-referee-scope-2/fixed_d_and_other_c.out`](../checks/depth-two-referee-scope-2/fixed_d_and_other_c.out), part (1)).
  - On the cube family this failure concerns reading (R3) only; B's two-point laws defeat every reading (first row of the table). As the referee notes, (R1), (R1′) and (R2) are not affected on the cube; the following argument for this is not refereed. By Lemma 1.1 they concentrate, as $\sigma\downarrow0$, on $\mathcal N_\zeta$ for every $\zeta>0$, and every $w\in\mathcal N_\zeta$ has excess at most $\kappa_N(w)\le G/c+\zeta$, by Lemma 1.0(1) and $\min F_{c,S}\le F_{c,S}(0)=(G+W)/c$. Since $\mathbb E\,G\le2^d$, $G/c=O(2^d/n)$ in probability when $c$ is of order $n$.

### 0.3 Changes relative to RT §5 (first referee round)

1. **The scope error (major).** RT's Corollary 5.2 ended: "It does **not** refute the '$+o(1)$' formulation, since $\varepsilon_d\asymp1/\log^2n$." That is false on part of the corollary's own range, "$c\le\mathrm{poly}(d)$", which contains $c\to0$.
   - Theorem 5.1's bound is of order $(dc+1)^{-2}$.
   - This bound is a constant when $c\le\nu/d$.
   - When $dc\to0$, the same near-minimizer budget combined with Lemma 1.2(a) gives $\beta(\lambda)$.

   Corollary 5.2 now states the three regimes, and the "does not refute" sentence is kept only for $dc\to\infty$ (§4).
2. **Theorem 5.1 is stated more fully.** Both lower bounds are now stated, from the same budget. The memorizer accuracy $a$ is now free, so the required width can be $O(n\log^4n)$ instead of $O(n^3\log^2n)$. The display is deterministic. The strong-prior limit is uniform over samples.
3. **Scope is explicit.** The scope statements name the widths, the predictors and the input normalisation, and say over which $d$ the "$+o(1)$" formulation is uniform.
4. **Proposition 5.3.** It now assumes $Q>0$, holds for $c\le\nu\sqrt M$ with $\nu<\sqrt{\beta(\lambda)}/2$, and gives an explicit rate. It also records its dependence on inputs of norm $\sqrt d$: under unit-ball inputs only $c<\sqrt{\beta(\lambda)}/2$ survives.
5. **Numbers.** The parenthetical numbers of Corollary 5.2 are corrected. The red-team's "positive side at $L=2$" paragraph and §5.4 numerics are corrected (Remark 5.7, §6).

### 0.4 Changes after the second referee round

1. **The learner-width quantifier (major).** (P$_2^{o(1)}$) now asks for the bound at every learner width $N\ge n^\alpha$, the competitors' width bound, as `problem-brief.md` §1 does with $N\ge m$ and as `B-tempered-likelihood.md` Corollary 8.1 does. The earlier text asked for every $N\ge1$, which made the property false for every learner whose output is one network of the learner's width (Remark 5.2a), so its refutation said nothing about SP$_c$. No proof changes: the failures hold at every $N\ge N_0$, which includes widths $N\ge n^\alpha$.
2. **Proposition 5.3 (major).** The note no longer says that Proposition 5.3 refutes a formulation of the conjecture. With $d$ of order $n$ no learner competes with $\mathcal G^{(\alpha)}_n$ up to $o(1)$ (Remark 5.3a), so the former entries "refuted for every $c=o(\sqrt n)$" and "with unit-ball inputs, refuted only for $c<\sqrt{\beta(1)}/2$" were empty or false. Proposition 5.3 is now described by what it shows: SP$_c$ is worse than the Bayes-optimal zero network.
3. **The open range.** For the clipped readings with $\log^2n\ll c\le n^{1-\epsilon}$, results of `B-tempered-likelihood.md` give the "$+o(1)$" formulation; Remark 5.7a states what that note proves at depth two and what follows by combining its statements. The open range is now $c\log n\to\infty$ with $c=O(\log^2n)$ (clipped readings) or $c=O(\sqrt n\log n)$ (unclipped readings). The source for the other end, B's Proposition 9.1, which settles $c\ge n^{1-o(1)}$ negatively, was added only after the first re-refereeing round (§0.5 item 1).
4. **Minor corrections.**
   - Lemma 1.2 is stated for any finite set of atoms.
   - The Gibbs-risk reading (R1′) and the measurability of (R1) are added.
   - In the proof of Proposition 5.3, the step "$Q^+\le2M$" is replaced by $Q\le M$.
   - The fixed-$d$ row states its dependence on $c$ and $\delta$.
   - Corollary 5.2(b) states its limit in $\sigma$ correctly, and the $c=1$ numbers say which accuracy $a$ they use.
   - A misrounded table entry is corrected, as are an erratum that rounded lower bounds up, the headline and wording of the erratum for RT §0 item 6, and one sentence of the first-round response.
   - Two scripts were corrected and re-run (§7).

### 0.5 Changes after the first re-refereeing round

The first re-refereeing round ([`../verification/depth-two-referee-scope-1.md`](../verification/depth-two-referee-scope-1.md) and [`../verification/depth-two-referee-logic-computation-1.md`](../verification/depth-two-referee-logic-computation-1.md)) raised fifteen minor points; the table "First re-refereeing round" of §9 answers them one by one. The changes are these.

1. **Large $c$.** Remark 5.7a now cites B's Proposition 9.1. The previous text said that B does not treat the negative side at depth two, which is false. At $L=2$ that proposition makes both formulations fail for every $c\ge n^{1-o(1)}$, and (P$_2$) fail on one fixed law for $c\ge n/4$. It supplies the source for the open range stated in the previous revision, which had treated this range as settled without citing anything.
2. **One learner.** §0 and §1.4 say that both formulations are properties of one learner and that the conjecture is not refuted at depth two. Remark 5.5, §0.1 item 2 and the erratum for RT §0 item 6 now say that SP$_c$ fails the formulations. §0 records which open items of B this note supersedes or narrows.
3. **Proof steps.** Remark 5.3a writes out the Gibbs-risk reading and the passage from the average over sign vectors to one law at arbitrarily small $\sigma$. Remark 5.7a writes out the passage from B's statements to the readings of §1.4 and keeps $\epsilon_n$ independent of $\delta$. The proof of Corollary 5.2(b) takes $\epsilon_n>0$ without loss of generality.
4. **Record.** §7.1 records the optimisation runs of RT §5.4 from their run files, since RT §5 is replaced by a pointer to this note, and §6 adds an erratum for RT Appendix A.
5. **Wording.** The unit-ball clauses of §0.2 and of the erratum for RT §6.1, the relay of B's §7.5 item 3, the numerics bullet of the erratum for RT §0 item 6, the §8 preamble and the §9 row for logic issue 6.

Two scripts were added, `prop91_l2.py` and `rt54_record.py` (§7). No existing script changed.

### 0.6 Changes after the second re-refereeing round

The second re-refereeing round ([`../verification/depth-two-referee-scope-2.md`](../verification/depth-two-referee-scope-2.md) and [`../verification/depth-two-referee-logic-computation-2.md`](../verification/depth-two-referee-logic-computation-2.md)) raised twenty-one points, all minor, including nits and optional suggestions; the table "Second re-refereeing round" of §9 answers them one by one. None changes a theorem, a proof or a number. The changes are these.

1. **Status statements.** §0 and §0.2 now say that at a fixed $d$ the cube family is learned consistently when $c=o(n)$, and that for $c$ of order $n$ near-minimizers (reading (R3)) fail on the cube itself, with the source in `A-tight-conditioning-fails.md` and the scope referee's script. §1.4 names $\phi$ where it says that the conjecture is not refuted at depth two. In the (P$_2$) row of §0.2, "Other $c$ are not settled here" is replaced by what (5.7a) gives for (P$_2$) and what is not classified, and Remark 5.7a derives the new range.
2. **A displayed bound.** (5.7a) and the Theorem 6.3 bullet of Remark 5.7a name the objects they bound at confidence $1-\delta$, and say in what form the readings at $\sigma<\sigma_0$ satisfy them.
3. **Qualifiers.** "$n/c\le n^{o(1)}$" in Remark 5.7a; the range of $c$ in the small-width clauses of §0 and §8 (L2); "supersedes item (iii)" restricted in §0, which now also says which transition B's §7.5 item 3 locates; "$c\ge\sqrt{\beta(\lambda)}/2$" and the learner width $N=8$ in Remark 5.4; "for $c\le\mathrm{poly}(d)$" in §8 (C3); "refuted by Corollary 5.2" in the §9 row for logic issue 6; "arbitrarily small $\sigma$" in §0.5 item 3; what `prop91_l2.py` asserts and which weights it uses, in §7 and Remark 5.7a.
4. **Additions that are not refereed.** Every change listed in this subsection was made after the last referee round and is not refereed. Two of them extend proved statements: Remark 5.2b extends Corollary 5.2(a) to every $c\le n^{o(1)}$, and Remark 5.7a records that the fixed-law failure extends to every $c\ge n/k$ with $k$ fixed; both are observations of the scope referee. Two others are new derivations, each marked where it appears: the paragraph "General $c$, the polynomial-sample property" of Remark 5.7a, which gives the (P$_2$) range $n^a\le c\le n^{1-a}$ stated in §0.2, and the argument in §0.2, "Input dimension", that the readings (R1), (R1′) and (R2) are not affected on the cube when $c$ is of order $n$.
5. **Record.** The header, §0.5, §0.6 and §9 cite the re-refereeing reports by path, and call their rounds the first and the second re-refereeing round; §7 names their script folders. The item of §6 on the RT §5 "Open" paragraph is phrased as a record, and §8 (L5 and the preamble) follows the fixed-$d$ change.

Before this revision the lead editor added "at the run's width" to the near-minimizer clause of the erratum for RT §0 item 6, moved it to that clause in the erratum for RT Appendix A, and added the sentence on the polynomial-sample version to the erratum for RT §7 item 3 (§6). No script changed.

---

## 1. Setting

### 1.1 Networks, energy, learner

**Network.** A depth-two network of width $N$ has parameters $w=(W^1,v)$, where $W^1\in\mathbb R^{N\times(d+1)}$ has rows $\omega_1,\dots,\omega_N$ and $v\in\mathbb R^N$. It computes

$$
z_w(x)=\sum_{j=1}^Nv_j\tanh(\omega_j\cdot\bar x),\qquad\bar x=(1,x)\in\mathbb R^{d+1}.
$$

There are no separate biases; the constant coordinate carries offsets.

**Energy.** The energy is

$$
\kappa_N(w)=\frac dN\lVert W^1\rVert_F^2+N\lVert v\rVert_2^2 .
$$

This is `NNG/side-results/continuous-domains/source/paper.tex` (`paper.tex` below), eq. `energy`, at $L=2$. Write $\kappa_N(w)=\lVert\Lambda w\rVert^2$, where $\Lambda$ is diagonal and positive, and let $P=N(d+2)$ be the number of parameters.

**Learner SP$_c$.** The prior $\mu_\sigma$ has density proportional to $e^{-\kappa_N/(2\sigma^2)}$. The likelihood is $y_i\sim\mathcal N(z_w(x_i),c\sigma^2)$, and the posterior is

$$
\Pi_\sigma(dw)=\Pi_{\sigma,N,S}(dw)=\frac{e^{-F_{c,S}(w)/(2\sigma^2)}dw}{\int e^{-F_{c,S}/(2\sigma^2)}},\qquad F_{c,S}(w)=\kappa_N(w)+\frac1c\sum_{i=1}^n\bigl(z_w(x_i)-y_i\bigr)^2 .
$$

Here $c>0$ may depend on $n$ and $d$. This is `problem-brief.md` §2. The clean-label scaling of `NNG/works-in-progress/slt-likelihood/README.md` §2 is $c=1$.

**Limit order.** First fix $d,n,c,N$ and the sample $S$, then let $\sigma\downarrow0$.

**Near-minimizers.** For $\zeta>0$ put $\mathcal N_\zeta=\mathcal N_\zeta^{(N)}(S)=\{w:F_{c,S}(w)\le\min F_{c,S}+\zeta\}$. The minimum exists by Lemma 1.1.

Lemma 1.1 below holds verbatim at every depth, but only $L=2$ is used here.

### 1.2 Predictors

Let $\operatorname{clip}(u)=\max\{-1,\min\{1,u\}\}$ and $L_D(f)=\mathbb E_{(x,y)\sim D}(f(x)-y)^2$.

- **Gibbs.** A draw $w\sim\Pi_\sigma$, with output $z_w$ or $\operatorname{clip}z_w$. The corresponding risks are $\mathcal G_\sigma=\mathbb E_{\Pi_\sigma}L_D(z_w)$ and $\mathcal G^{\rm clip}_\sigma=\mathbb E_{\Pi_\sigma}L_D(\operatorname{clip}z_w)$.
- **Posterior means.** $\bar z_\sigma=\mathbb E_{\Pi_\sigma}z_w$, $\operatorname{clip}\bar z_\sigma$, and $\bar f_\sigma=\mathbb E_{\Pi_\sigma}\operatorname{clip}z_w$. These are finite by Lemma 1.0(1) and Lemma 1.1(ii).
- **Near-minimizers.** Any point of $\mathcal N_1$.

The progressive-mixture predictor of `problem-brief.md` §2 is **not** treated (Remark 5.6).

### 1.3 The cube example and sample statistics

**Risk.** In $D_d$ the regression function is $0$ and $y^2=1$. Hence for every $f:\{-1,1\}^d\to\mathbb R$,

$$
L_{D_d}(f)=1+\frac1M\sum_{x}f(x)^2,
$$

so $\min_fL_{D_d}(f)=1$, attained by the zero network.

**Sample statistics.** Let the inputs of a sample $S=((x_i,y_i))_{i\le n}$ lie in a finite set $\mathcal A$ of atoms. In the cube example $\mathcal A=\{-1,1\}^d$; in Proposition 5.3 it is the set of Hadamard rows. Sums $\sum_x$ run over $\mathcal A$. Define:

- the counts $k_x=\#\{i:x_i=x\}$;
- the set of seen atoms $T=\{x:k_x\ge1\}$ and its size $s=\lvert T\rvert$;
- the label sums $S_x=\sum_{i:x_i=x}y_i$, and $\bar y_x=S_x/k_x$ for $x\in T$;
- the within-atom sum of squares $W=\sum_i(y_i-\bar y_{x_i})^2$;
- the residual $\mathcal R(f)=\sum_{x\in T}k_x(f(x)-\bar y_x)^2$;
- the totals
$$
Q=\sum_{x\in T}\bar y_x^2,\qquad G=\sum_{x\in T}k_x\bar y_x^2,\qquad V=\sum_xS_x^2 .
$$

Since $k_x\ge1$ on $T$ and $\lvert\bar y_x\rvert\le1$, we have $Q\le G$, $Q\le s\le\min\{n,\lvert\mathcal A\rvert\}$ and $\sum_xk_x=n$.

**Constants.** Let $K\sim\mathrm{Bin}(n,1/M)$, and put $\beta_d=\mathbb E[K^{-1};K\ge1]$ and $p_d=\Pr[K\ge1]$. Let $\lambda'=n/M\in[\lambda,\lambda+1/M)$. Define

$$
\beta(\lambda)=e^{-\lambda}\sum_{k\ge1}\frac{\lambda^k}{k\,k!}=e^{-\lambda}\bigl(\mathrm{Ei}(\lambda)-\gamma_E-\ln\lambda\bigr),\qquad\gamma(\lambda)=\frac{(1-e^{-\lambda})^2}{4\lambda}.
$$

Their values (`bounds_t51.out`):

- $\beta(1)=0.484829$, and $\max\beta=0.517351$ at $\lambda=1.50286$;
- $\gamma(1)=0.0998941$, and $\max\gamma=0.101816$ at $\lambda=1.256431$, the root of $e^\lambda-1=2\lambda$.

Two inequalities are used:

$$
4\gamma(\lambda)\le\beta(\lambda)<1-e^{-\lambda}\qquad(\lambda>0). \tag{1.0}
$$

Let $K_\lambda\sim\mathrm{Poi}(\lambda)$. The left inequality is Cauchy–Schwarz: $(\Pr[K_\lambda\ge1])^2\le\mathbb E[K_\lambda]\,\mathbb E[K_\lambda^{-1};K_\lambda\ge1]=\lambda\beta(\lambda)$. The right inequality holds because $1/K_\lambda<1$ on $\{K_\lambda\ge2\}$, which has positive probability.

### 1.4 The two formulations

Both are `problem-brief.md` §1 at depth two. The first follows `A-tight-conditioning-fails.md` §5.1.

> **(P$_2$)** There is a polynomial $\mathsf p$ with the following property. Take any $d\ge1$, any law $D$ on $X\times[-1,1]$ with $X\subseteq[-1,1]^d$ compact, any depth-two competitor $g$ of width $m$ with weights in $[-B,B]$, any learner width $N\ge m$, any $\varepsilon,\delta\in(0,1)$, and any $n\ge\mathsf p(d,m,B,1/\varepsilon,\log(1/\delta))$. Then $\Pr[L_D(\mathsf A_n)\le L_D(g)+\varepsilon]\ge1-\delta$.

> **(P$_2^{o(1)}[\phi]$)**: the "$+o(1)$" formulation, with the $o(1)$ uniform over input dimensions $d\le\phi(n)$. There are $\alpha>0$ and numbers $\epsilon_n\to0$ with the following property. For every $\delta\in(0,1)$ there is $n_\delta$ such that, for all $n\ge n_\delta$, all $d\le\phi(n)$, every law $D$ on $X\times[-1,1]$ with $X\subseteq[-1,1]^d$ compact, and every learner width $N\ge n^\alpha$,
> $$\Pr\Bigl[L_D(\mathsf A_n)\le\inf_{g\in\mathcal G^{(\alpha)}_n}L_D(g)+\epsilon_n\Bigr]\ge1-\delta .$$
> Here $\mathcal G^{(\alpha)}_n$ is the set of depth-two networks of the same architecture with width at most $n^\alpha$ and all weights in $[-n^\alpha,n^\alpha]$.

**One learner.** (P$_2$) and (P$_2^{o(1)}[\phi]$) are properties of one learner $\mathsf A$. The conjecture asks that some Bayesian learner have them ("We may pick whichever version of Bayesian learning is best", `problem-brief.md` §1). A failure of SP$_c$ for some $c$ therefore shows only that this learner lacks the property. At depth two the conjecture is refuted neither in (P$_2$) nor in (P$_2^{o(1)}[\phi]$) with $\phi(n)=\log_2n+C_0$ (§0). With $\phi(n)\ge n/b$, for a fixed $b\ge1$, no learner has (P$_2^{o(1)}[\phi]$) (Remark 5.3a).

**Learner widths.** Both formulations ask for the bound at every learner width at least the competitors' width: $N\ge m$ in (P$_2$), as in `problem-brief.md` §1, and $N\ge n^\alpha$ in (P$_2^{o(1)}$), as in `B-tempered-likelihood.md` Corollary 8.1 ("simultaneously for all learner widths $N\ge n^\alpha$"). The text the second-round referees read asked for every $N\ge1$ in (P$_2^{o(1)}$); Remark 5.2a shows that this made the property false for every learner whose output is a single network of the learner's width. The refutations below show failure at every width $N\ge N_0$, for an $N_0$ polynomial in $n$. A formulation that asks for all $N\ge n^\alpha$ asks in particular for $N=\max\{N_0,\lceil n^\alpha\rceil\}$, so the refutations apply to (P$_2^{o(1)}$) for every $\alpha>0$. They also refute every variant that asks for the bound at some single width $N(n)\ge N_0$ for each $n$. They say nothing about variants that ask for it only at widths below $N_0$, for example only at $N=\lceil n^\alpha\rceil$ with $\alpha<1$ (Remark 5.5).

**Readings.** For SP$_c$ with $c=c(n,d)$ the output $\mathsf A_n$ is read in one of four ways:

- **(R1)** A Gibbs draw, with output $z_w$ or $\operatorname{clip}z_w$. The probability is over both the sample and the draw. The property must hold for all $\sigma\in(0,\sigma_0)$, where $\sigma_0>0$ may depend on everything except the sample.
- **(R1′)** The Gibbs risk: the test loss of the learner is taken to be $\mathcal G_\sigma$ or $\mathcal G^{\rm clip}_\sigma$, the expected test loss of one posterior draw. The probability is over the sample, with the same quantifier on $\sigma$.
- **(R2)** One of $\bar z_\sigma$, $\operatorname{clip}\bar z_\sigma$ or $\bar f_\sigma$, with the same quantifier on $\sigma$.
- **(R3)** Any point of $\mathcal N_1(S)$, chosen by any rule. The probability is then an outer probability.

The *clipped readings* are (R1) and (R3) with output $\operatorname{clip}z_w$, (R1′) with $\mathcal G^{\rm clip}_\sigma$, and (R2) with $\bar f_\sigma$; the others are *unclipped*.

Under (R1) the probability is $\mathbb E_S\,\Pi_{\sigma,S}(A_S)$, where $A_S$ is the set of draws $w$ that satisfy the inequality. This is well defined. $F_{c,S}(w)$ is jointly continuous in $(S,w)$, and the normaliser $Z_\sigma(S)=\int e^{-F_{c,S}/(2\sigma^2)}$ is positive and, by dominated convergence with $F_{c,S}\ge\kappa_N$, continuous in $S$. So the posterior density is jointly continuous, $S\mapsto\Pi_{\sigma,S}$ is a probability kernel, and Tonelli's theorem applies.

---

## 2. Lemmas

**Lemma 1.0(1) (output bound).** For every $N$ and $w$, $\sup_x\lvert z_w(x)\rvert\le\sqrt N\lVert v\rVert_2\le\sqrt{\kappa_N(w)}$.

*Proof.* Since $\lvert\tanh\rvert\le1$, we have $\lvert z_w(x)\rvert\le\lVert v\rVert_1\le\sqrt N\lVert v\rVert_2$. Also $N\lVert v\rVert_2^2\le\kappa_N(w)$. ∎

**Lemma 1.1 (strong-prior concentration, uniform in the sample).** Fix $d$, a compact $X\subseteq[-1,1]^d$, $N$, $n$, $c>0$ and $\zeta>0$. Samples range over $(X\times[-1,1])^n$.

- **(i)** For every sample, $F=F_{c,S}$ is continuous and coercive, its minimum $m_*$ is attained, and $0\le m_*\le n/c$.
- **(ii)** The quantity
$$
\epsilon_\sigma:=\sup_S\mathbb E_{\Pi_{\sigma,S}}\bigl[(1+F_{c,S})\mathbf 1_{\mathcal N_\zeta^c}\bigr]
$$
tends to $0$ as $\sigma\downarrow0$. In particular $\sup_S\Pi_{\sigma,S}(\mathcal N_\zeta^c)\le\epsilon_\sigma\to0$.
- **(iii)** Let $\Phi\ge0$ be measurable. Then $\mathbb E_{\Pi_\sigma}\Phi\ge\Pi_\sigma(\mathcal N_\zeta)\inf_{\mathcal N_\zeta}\Phi$. If moreover $\Phi\le b_0+b_1F_{c,S}$, then $\mathbb E_{\Pi_\sigma}\Phi\le\sup_{\mathcal N_\zeta}\Phi+\max\{b_0,b_1\}\epsilon_\sigma$.

*Proof.*

- **(i)** $F\ge\kappa_N=\lVert\Lambda w\rVert^2$, so $F$ is coercive; it is continuous; so the minimum is attained. Moreover $m_*\le F(0)=c^{-1}\sum_iy_i^2\le n/c$.
- **Numerator.** For $\varrho\in(0,1)$ and $t\ge0$ we have $(1+t)e^{-t/(2\sigma^2)}\le(1+2\sigma^2/\varrho)\,e^{-(1-\varrho)t/(2\sigma^2)}$. This follows from $\sup_{t\ge0}(1+t)e^{-st}\le\max\{1,1/s\}$ with $s=\varrho/(2\sigma^2)$. On $\{F>m_*+\zeta\}$, using $F\ge\kappa_N$,
$$
(1-\varrho)F=(1-\varrho)^2F+\varrho(1-\varrho)F\ge(1-\varrho)^2(m_*+\zeta)+\varrho(1-\varrho)\kappa_N .
$$
Hence
$$
\int_{\{F>m_*+\zeta\}}(1+F)e^{-F/(2\sigma^2)}\le\Bigl(1+\frac{2\sigma^2}\varrho\Bigr)e^{-(1-\varrho)^2(m_*+\zeta)/(2\sigma^2)}\Bigl(\frac{2\pi\sigma^2}{\varrho(1-\varrho)}\Bigr)^{P/2}\det\Lambda^{-1}.
$$
- **Choice of $\varrho$.** Choose $\varrho=\varrho(n,c,\zeta)$ with $(1-\varrho)^2(n/c+\zeta)\ge n/c+\zeta/2$. The map $m\mapsto(1-\varrho)^2(m+\zeta)-m-\zeta/2$ is decreasing. So $(1-\varrho)^2(m_*+\zeta)\ge m_*+\zeta/2$ for every sample, because $m_*\le n/c$.
- **Denominator.** Let $w_*$ be a minimizer, so $\kappa_N(w_*)\le m_*\le n/c$. Let $K_1$ be the closed unit neighbourhood of the compact set $\{\kappa_N\le n/c\}$.
  - The map $(w,x)\mapsto z_w(x)$ is $C^1$, so its $w$-gradient is bounded on the compact set $K_1\times X$.
  - Because $\lvert y_i\rvert\le1$, the gradient of $F_{c,S}$ on $K_1$ is then bounded by a constant $\mathrm{Lip}_1(d,X,N,n,c)$ that does not depend on $S$.
  - With $r_0=\min\{1,\zeta/(4\mathrm{Lip}_1)\}$, the ball $B(w_*,r_0)\subseteq K_1$ lies in $\{F<m_*+\zeta/4\}$. So
  $$
  \int e^{-F/(2\sigma^2)}\ge\mathrm{vol}(B_{r_0})\,e^{-(m_*+\zeta/4)/(2\sigma^2)} .
  $$
- **Ratio.** Dividing the two bounds,
$$
\mathbb E_{\Pi_\sigma}\bigl[(1+F)\mathbf 1_{\mathcal N_\zeta^c}\bigr]\le\Bigl(1+\frac{2\sigma^2}\varrho\Bigr)\Bigl(\frac{2\pi\sigma^2}{\varrho(1-\varrho)}\Bigr)^{P/2}\frac{e^{-\zeta/(8\sigma^2)}}{\det\Lambda\;\mathrm{vol}(B_{r_0})}.
$$
The right side does not depend on $S$ and tends to $0$. This proves (ii).
- **(iii)** Split $\mathbb E\Phi$ over $\mathcal N_\zeta$ and its complement. On the complement, $\Phi\le\max\{b_0,b_1\}(1+F)$. ∎

Lemma 1.0(1) gives $\lvert z_w(x)\rvert\le\sqrt{\kappa_N}\le1+F$. Lemma 1.1 then shows that $\bar z_\sigma$ and $\bar f_\sigma$ exist.

**Lemma 1.2 (atoms).** Let the inputs lie in a finite set $\mathcal A$ of atoms and the labels in $[-1,1]$, and use the notation of §1.3. For every $f:\mathcal A\to\mathbb R$:

$$
\sum_i\bigl(f(x_i)-y_i\bigr)^2=\mathcal R(f)+W, \tag{1.1}
$$

and $\mathcal R(\operatorname{clip}f)\le\mathcal R(f)$. Let $B\ge0$ and suppose $\mathcal R(f)\le B$. Then:

- **(a)** $\displaystyle\sum_{x\in\mathcal A}f(x)^2\ge\bigl(\sqrt Q-\sqrt B\bigr)_+^2$;
- **(b)** if $B<G$, then $V>0$ and $\displaystyle\sum_{x\in\mathcal A}f(x)^2\ge\frac{(G-B)^2}{4V}$. Write $\frac{(G-B)_+^2}{4V}$ for this bound, read as $0$ when $B\ge G$.

The lemma is deterministic and uses nothing about $\mathcal A$ beyond finiteness. It is applied with $\mathcal A=\{-1,1\}^d$ in Theorem 5.1 and with the Hadamard atoms in Proposition 5.3. In both cases the law is uniform on $\mathcal A$ with fair-sign labels, so $L_D(f)=1+\lvert\mathcal A\rvert^{-1}\sum_{x\in\mathcal A}f(x)^2$ and (a), (b) bound the excess.

*Proof.*

- **(1.1).** For each atom $x\in T$,
$$
\sum_{i:x_i=x}(f(x)-y_i)^2=k_x(f(x)-\bar y_x)^2+\sum_{i:x_i=x}(y_i-\bar y_x)^2 ,
$$
because the cross term contains $\sum_{i:x_i=x}(y_i-\bar y_x)=0$. Sum over $x\in T$.
- **Clipping.** $\operatorname{clip}$ is the metric projection onto $[-1,1]$, and $\bar y_x\in[-1,1]$, so $\lvert\operatorname{clip}u-\bar y_x\rvert\le\lvert u-\bar y_x\rvert$.
- **(a).** By the triangle inequality in $\ell^2(T)$,
$$
\Bigl(\sum_xf^2\Bigr)^{1/2}\ge\Bigl(\sum_Tf^2\Bigr)^{1/2}\ge\sqrt Q-\Bigl(\sum_T(f-\bar y)^2\Bigr)^{1/2},
$$
and $\sum_T(f-\bar y)^2\le\mathcal R(f)\le B$ because $k_x\ge1$.
- **(b).** Since $k_x\bar y_x=S_x$ and $S_x=0$ off $T$, expanding gives
$$
\mathcal R(f)=\sum_Tk_xf(x)^2-2\sum_xf(x)S_x+G .
$$
So $\mathcal R(f)\le B$ gives $2\sum_xf(x)S_x\ge G-B+\sum_Tk_xf^2\ge G-B>0$. Hence some $S_x\ne0$, that is, $V>0$. Cauchy–Schwarz gives $\sum_xfS_x\le(\sum_xf^2)^{1/2}V^{1/2}$. ∎

**Lemma 1.3 (concentration).** Let $n$ inputs be i.i.d. uniform on $M$ distinct atoms, with independent fair-sign labels; the cube example is one case. Put $h_d=2n^{2/3}/M$. With probability at least $1-\rho_n$, where $\rho_n:=4e^{-n^{1/3}/2}+(4+2n/M)n^{-1/3}$, the following event $\mathcal E$ holds:

$$
\lvert Q-M\beta_d\rvert\le2n^{2/3},\qquad\lvert G-Mp_d\rvert\le2n^{2/3},\qquad\lvert V-n\rvert\le n^{2/3}. \tag{1.2}
$$

If $n=\lceil\lambda M\rceil$, then moreover $\lvert\beta_d-\beta(\lambda)\rvert$ and $\lvert p_d-(1-e^{-\lambda})\rvert$ are at most $(\lambda'+1)/M$. As $M\to\infty$ along $n=\lceil\lambda M\rceil$: $\rho_n\to0$, $h_d\to0$, $\beta_d\to\beta(\lambda)$, $p_d\to1-e^{-\lambda}$ and $\lambda'\to\lambda$.

*Proof.*

- **Input part.** Put $\Sigma_1=\sum_{x\in T}k_x^{-1}$; then $\mathbb E\Sigma_1=M\beta_d$ and $\mathbb Es=Mp_d$. Both $\Sigma_1$ and $s$ are functions of the $n$ inputs with bounded differences at most $2$. Moving one input changes two counts by one, and $k\mapsto\mathbf 1[k\ge1]/k$ and $k\mapsto\mathbf 1[k\ge1]$ change by at most $1$ per unit step. McDiarmid's inequality at $t=n^{2/3}$ gives $\Pr(\lvert\Sigma_1-M\beta_d\rvert\ge n^{2/3})\le2e^{-n^{1/3}/2}$, and the same for $s$.
- **Label part.** Given the inputs, the $S_x$ are independent sums of $k_x$ Rademacher signs, with $\mathbb ES_x^2=k_x$ and $\mathrm{Var}(S_x^2)=2k_x^2-2k_x$.
  - $\mathbb E[Q\mid\text{inputs}]=\Sigma_1$ and $\mathrm{Var}(Q\mid\text{inputs})=\sum_T(2k_x^2-2k_x)/k_x^4\le2n$.
  - $\mathbb E[G\mid\text{inputs}]=s$ and $\mathrm{Var}(G\mid\text{inputs})\le2n$.
  - Write $V=n+\sum_{i\ne j}y_iy_j\mathbf 1[x_i=x_j]$; then $\mathbb EV=n$ and $\mathrm{Var}(V)=2n(n-1)/M$.

  Chebyshev's inequality at $n^{2/3}$ gives failure probabilities $2n^{-1/3}$, $2n^{-1/3}$ and $2(n/M)n^{-1/3}$. The triangle inequality then gives (1.2).
- **Poisson comparison.** Le Cam's inequality gives $d_{TV}(\mathrm{Bin}(n,1/M),\mathrm{Poi}(\lambda'))\le n/M^2=\lambda'/M$. Also $d_{TV}(\mathrm{Poi}(\lambda'),\mathrm{Poi}(\lambda))\le\lambda'-\lambda\le1/M$. The test functions $\mathbf 1[k\ge1]/k$ and $\mathbf 1[k\ge1]$ take values in $[0,1]$. ∎

**Lemma 2.1 (depth-two memorizer; RT Lemma 2.1(2)).** Let $X=\{-1,1\}^d$, $r:X\to[-1,1]$, $\lVert r\rVert_2^2=\sum_xr(x)^2$ and $0<a\le1$. Put

$$
A_0=3\sqrt d\,\lVert r\rVert_2,\qquad m_0=\Bigl\lceil\frac{8A_0^2\ln(2M)}{a^2}\Bigr\rceil+1,\qquad F_d=1+(d+1)(d+2)^2 .
$$

There is a function $g:X\to\mathbb R$ with $\sup_X\lvert g-r\rvert\le a/2$ such that, for every width $N\ge m_0$ and every $t\in[0,1]$, some depth-two network $w_t$ of width $N$ satisfies

$$
z_{w_t}=t\,g\ \text{ on }X,\qquad\kappa_N(w_t)\le dF_d+2t^2A_0^2=dF_d+18\,d\,t^2\lVert r\rVert_2^2 .
$$

The function $g$ depends neither on $N$ nor on $t$.

*Proof.* If $r\equiv0$, take $g\equiv0$ and $w_t=0$. Otherwise proceed in five steps. Steps 1–2 are `NNG/works-in-progress/noisy-interpolation/README.md` §2, eqs. (2)–(4), re-proved here.

**Step 1 (Fourier $\ell^1$ bound).** For $J\subseteq[d]$ let $\chi_J(x)=\prod_{j\in J}x_j$ and $\hat r(J)=M^{-1}\sum_xr(x)\chi_J(x)$, so that $r=\sum_J\hat r(J)\chi_J$. Parseval gives $\sum_J\hat r(J)^2=M^{-1}\lVert r\rVert_2^2$. Cauchy–Schwarz over the $M$ sets $J$ then gives $\sum_J\lvert\hat r(J)\rvert\le\lVert r\rVert_2$.

**Step 2 (parities as tanh mixtures).** Fix $k\ge1$. Let $b_k=0$ for odd $k$ and $b_k=1$ for even $k$. For $v\in\{-1,1\}^k$, the number $\sum_jv_j-b_k$ is an odd integer, hence nonzero.

- **Sign coefficient.** Let $\mathfrak c_k=\mathbb E_v[\prod_jv_j\,\mathrm{sign}(\sum_jv_j-b_k)]$, with $v$ uniform. Grouping by the number $i$ of negative coordinates and using $\sum_{i\le t}(-1)^i\binom qi=(-1)^t\binom{q-1}t$:
  - for $k=2m+1$, $\mathfrak c_k=2^{1-k}\sum_{i\le m}(-1)^i\binom ki=(-1)^m\binom{2m}m4^{-m}$;
  - for $k=2m$, $\mathfrak c_k=2^{1-k}\sum_{i\le m-1}(-1)^i\binom{2m}i=(-1)^{m-1}\binom{2m}m4^{-m}$.
- **Lower bound on the sign coefficient.** Put $u_m=\binom{2m}m4^{-m}$. Then $u_1=\frac12$ and $u_m/u_{m-1}=\frac{2m-1}{2m}\ge\sqrt{(m-1)/m}$, because $(2m-1)^2\ge4m(m-1)$. So $u_m\ge1/(2\sqrt m)$ by induction. Hence $\lvert\mathfrak c_k\rvert\ge1/\sqrt{2k}$ for every $k\ge1$; for $k=1$, $\mathfrak c_1=1$.
- **Slope.** Let $\alpha_d=\max\{1,\frac12\ln(4\sqrt{2d})\}$, so that $\alpha_d\le d+2$. Let $\mathfrak c_{k,\alpha}=\mathbb E_v[\prod_jv_j\tanh(\alpha(\sum_jv_j-b_k))]$. For odd integers $\ell$, $\lvert\mathrm{sign}(\ell)-\tanh(\alpha_d\ell)\rvert\le1-\tanh\alpha_d<2e^{-2\alpha_d}\le1/(2\sqrt{2d})$. A Fourier coefficient moves by at most the sup-norm change of the function, so
$$
\lvert\mathfrak c_{k,\alpha_d}\rvert\ge\frac1{\sqrt{2k}}-\frac1{2\sqrt{2d}}\ge\frac1{2\sqrt{2k}}\qquad(1\le k\le d).
$$
- **Sign-flip identity.** For $J$ with $\lvert J\rvert=k$, substitute $v_j=u_jx_j$ for $j\in J$. Then on $X$
$$
\mathbb E_{u\in\{\pm1\}^J}\Bigl[\textstyle\prod_{j\in J}u_j\tanh\bigl(\alpha_d(\sum_{j\in J}u_jx_j-b_k)\bigr)\Bigr]=\mathfrak c_{k,\alpha_d}\chi_J(x)
$$
(README eq. (4)). The row realizing $\tanh(\alpha_d(\sum_{j\in J}u_jx_j-b_k))$ is $\omega_{J,u}=\alpha_d(-b_k,(u_j\mathbf 1_{j\in J})_{j\le d})$, with $\lVert\omega_{J,u}\rVert^2=\alpha_d^2(b_k^2+k)\le(d+2)^2(d+1)<F_d$.
- **Empty set.** $\chi_\emptyset=\tanh(e_0\cdot\bar x)/\tanh1$ with $e_0=(1,0,\dots,0)$, and $\lVert e_0\rVert^2=1<F_d$.
- **Assembly.** Since tanh is odd, signs can be absorbed into rows. So $r=\sum_J\hat r(J)\chi_J$ is a signed combination of $\tanh(\omega\cdot\bar x)$ over finitely many rows with $\lVert\omega\rVert^2\le F_d$. The total absolute coefficient is at most $\max\{2\sqrt{2d},1/\tanh1\}\sum_J\lvert\hat r(J)\rvert\le3\sqrt d\lVert r\rVert_2=A_0$, since $2\sqrt2<3$ and $1/\tanh1<1.32$. Putting the remaining mass on the zero row gives $r=A_0\,\mathbb E_{\omega\sim\pi}\tanh(\omega\cdot\bar x)$ on $X$, for a probability law $\pi$ on finitely many rows of squared norm at most $F_d$.

**Step 3 (sampling).** Draw $\omega_1,\dots,\omega_{m_0}$ i.i.d. from $\pi$ and put $g=\frac{A_0}{m_0}\sum_{l=1}^{m_0}\tanh(\omega_l\cdot\bar x)$. The summands $A_0\tanh(\cdot)$ lie in $[-A_0,A_0]$ and have mean $r(x)$. Hoeffding's inequality and a union bound over the $M$ inputs give
$$
\Pr\bigl[\exists x:\lvert g(x)-r(x)\rvert>a/2\bigr]\le2M\exp\Bigl(-\frac{m_0a^2}{8A_0^2}\Bigr)<1 .
$$
Fix a realization outside this event.

**Step 4 (first layer).** Split the $N\ge m_0$ neurons into $m_0$ groups of sizes $k_l\in\{\lfloor N/m_0\rfloor,\lceil N/m_0\rceil\}$. Then $\sum_lk_l=N$ and $k_l\ge\lfloor N/m_0\rfloor\ge N/(2m_0)$. Every neuron of group $l$ gets the row $\omega_l$. The first-layer energy is
$$
\frac dN\sum_lk_l\lVert\omega_l\rVert^2\le dF_d .
$$

**Step 5 (readout).** Give each copy of feature $l$ the readout weight $tA_0/(m_0k_l)$. The output is
$$
\sum_lk_l\frac{tA_0}{m_0k_l}\tanh(\omega_l\cdot\bar x)=t\,g(x),
$$
and the readout energy is
$$
N\sum_lk_l\Bigl(\frac{tA_0}{m_0k_l}\Bigr)^2=\frac{Nt^2A_0^2}{m_0^2}\sum_l\frac1{k_l}\le\frac{Nt^2A_0^2}{m_0^2}\cdot m_0\cdot\frac{2m_0}N=2t^2A_0^2 .
$$
∎

---

## 3. Theorem 5.1

**Theorem 5.1 (depth two, cube example, every $c>0$).** Let $L=2$, take the cube example $D_d$, any $n\ge1$, any $c>0$ and any $a\in(0,1]$. Put

$$
\vartheta_c=\frac1{18dc+1},\qquad E_0=c\,(dF_d+1)+\vartheta_c\,n\,a,\qquad\mathcal R_{\max}=(1-\vartheta_c)\,G+E_0,\qquad N_0(a)=\Bigl\lceil\frac{72\,d\,n\ln(2M)}{a^2}\Bigr\rceil+1,
$$

$$
\Psi_{\rm tri}=\frac1M\bigl(\sqrt Q-\sqrt{\mathcal R_{\max}}\bigr)_+^2,\qquad\Psi_{\rm cor}=\frac{(\vartheta_cG-E_0)_+^2}{4MV}\ (\text{read as }0\text{ if }\vartheta_cG\le E_0),\qquad\Psi=\max\{\Psi_{\rm tri},\Psi_{\rm cor}\}.
$$

For every sample $S$ and every learner width $N\ge N_0(a)$:

1. **(Residual budget.)** Every $w\in\mathcal N_1$ satisfies $\mathcal R(\operatorname{clip}z_w)\le\mathcal R(z_w)\le\mathcal R_{\max}$.
2. **(Near-minimizers.)** Every $w\in\mathcal N_1$ satisfies
$$
L_{D_d}(z_w)\ \ge\ L_{D_d}(\operatorname{clip}z_w)\ \ge\ 1+\Psi .
$$
3. **(Strong-prior limit, uniform in the sample.)** For every $\eta>0$ there is $\sigma_0>0$, depending only on $(d,n,c,N,\eta)$, with the following property. For all $\sigma\in(0,\sigma_0)$ and every sample:
   - $\Pi_\sigma(\mathcal N_1)\ge1-\eta$. So a Gibbs draw satisfies part 2 with posterior probability at least $1-\eta$, and $\mathcal G_\sigma\ge\mathcal G^{\rm clip}_\sigma\ge(1-\eta)(1+\Psi)$.
   - Each $f_\sigma\in\{\bar z_\sigma,\operatorname{clip}\bar z_\sigma,\bar f_\sigma\}$ satisfies $\mathcal R(f_\sigma)\le\mathcal R_{\max}+\eta$. Hence $L_{D_d}(f_\sigma)\ge1+\Psi(\eta)$, where $\Psi(\eta)$ is $\Psi$ with $E_0$ replaced by $E_0+\eta$.

   In particular, the $\liminf_{\sigma\downarrow0}$ of $\mathcal G_\sigma$, $\mathcal G^{\rm clip}_\sigma$, $L_{D_d}(\bar z_\sigma)$, $L_{D_d}(\operatorname{clip}\bar z_\sigma)$ and $L_{D_d}(\bar f_\sigma)$ is at least $1+\Psi$.

The statement is deterministic: no probability over the sample enters. Corollary 5.2 evaluates $\Psi$ on the event of Lemma 1.3. With $a=1/n$, $N_0(1/n)\le72dn^3\ln(2M)+2$ and $E_0\le c(dF_d+1)+1$, which recovers RT's statement with a slightly smaller $E_0$. With $a=1/d$, $N_0(1/d)=\lceil72d^3n\ln(2M)\rceil+1$.

*Proof.*

- **Memorizer.** Let $r=\bar y\mathbf 1_T$, so $r(x)=\bar y_x$ on $T$ and $0$ elsewhere. Then $\lvert r\rvert\le1$ and $\lVert r\rVert_2^2=Q\le n$. So $m_0$ of Lemma 2.1 satisfies $m_0=\lceil72dQ\ln(2M)/a^2\rceil+1\le N_0(a)$. Lemma 2.1 gives $g$ with $\lvert g-\bar y\rvert\le a/2$ on $T$, and, for every $N\ge N_0(a)$ and $t\in[0,1]$, networks $w_t$ with $z_{w_t}=tg$ on $X$ and $\kappa_N(w_t)\le dF_d+18dt^2Q$.
- **Residual of $tg$.** On $T$ write $e_x=g(x)-\bar y_x$, so $\lvert e_x\rvert\le a/2$. Then $tg(x)-\bar y_x=te_x-(1-t)\bar y_x$, and
$$
\mathcal R(tg)\le\sum_Tk_x\Bigl[(1-t)^2\bar y_x^2+t(1-t)a\lvert\bar y_x\rvert+\frac{t^2a^2}4\Bigr]\le(1-t)^2G+nt\Bigl[(1-t)a+\frac{ta^2}4\Bigr]\le(1-t)^2G+nta,
$$
using $\sum_Tk_x=n$, $\lvert\bar y_x\rvert\le1$ and $a\le4$.
- **Objective.** By (1.1), $cF_{c,S}(w)-W=c\,\kappa_N(w)+\mathcal R(z_w)$ for every $w$. Hence, using $Q\le G$,
$$
cF_{c,S}(w_t)-W\le c\,dF_d+G\bigl[18dc\,t^2+(1-t)^2\bigr]+nta .
$$
For $\alpha>0$, the bracket $\alpha t^2+(1-t)^2$ is minimized at $t=1/(1+\alpha)$, with value $\alpha/(1+\alpha)$. With $\alpha=18dc$ this means $t=\vartheta_c\in(0,1]$ and value $1-\vartheta_c$. So
$$
cF_{c,S}(w_{\vartheta_c})-W\le c\,dF_d+(1-\vartheta_c)G+n\vartheta_ca .
$$
- **Part 1.** For $w\in\mathcal N_1$ we have $F_{c,S}(w)\le\min F_{c,S}+1\le F_{c,S}(w_{\vartheta_c})+1$. So
$$
c\,\kappa_N(w)+\mathcal R(z_w)\le c\,dF_d+c+(1-\vartheta_c)G+n\vartheta_ca=\mathcal R_{\max}.
$$
Drop $c\kappa_N(w)\ge0$. Clipping does not increase $\mathcal R$ (Lemma 1.2).
- **Part 2.** Apply Lemma 1.2(a) and (b) to $f=\operatorname{clip}z_w$ with $B=\mathcal R_{\max}$; note $G-B=\vartheta_cG-E_0$. Finally, $\lvert\operatorname{clip}u\rvert\le\lvert u\rvert$ and $L_{D_d}(f)=1+M^{-1}\sum_xf^2$ give $L_{D_d}(z_w)\ge L_{D_d}(\operatorname{clip}z_w)$.
- **Part 3.** Apply Lemma 1.1 with $\zeta=1$ and choose $\sigma_0$ so that $\epsilon_\sigma\le\eta\min\{1,1/c\}$ for $\sigma<\sigma_0$.
  - *Gibbs.* Lemma 1.1(iii) with $\Phi=L_{D_d}(\operatorname{clip}z_w)\ge0$ gives $\mathcal G^{\rm clip}_\sigma\ge\Pi_\sigma(\mathcal N_1)(1+\Psi)$. Also $L_{D_d}(z_w)\ge L_{D_d}(\operatorname{clip}z_w)$ pointwise.
  - *Posterior means.* $\mathcal R$ is a convex function of the finite vector $(f(x))_{x\in T}$, and $\lvert z_w(x)\rvert\le1+F$ is integrable. So Jensen's inequality gives $\mathcal R(\bar z_\sigma)\le\mathbb E_{\Pi_\sigma}\mathcal R(z_w)$. Further, $\mathcal R(\operatorname{clip}\bar z_\sigma)\le\mathcal R(\bar z_\sigma)$, and $\mathcal R(\bar f_\sigma)\le\mathbb E_{\Pi_\sigma}\mathcal R(\operatorname{clip}z_w)\le\mathbb E_{\Pi_\sigma}\mathcal R(z_w)$.
  - *Budget in the limit.* Since $0\le\mathcal R(z_w)=cF-c\kappa_N-W\le cF$, Lemma 1.1(iii) gives $\mathbb E_{\Pi_\sigma}\mathcal R(z_w)\le\sup_{\mathcal N_1}\mathcal R(z_w)+c\epsilon_\sigma\le\mathcal R_{\max}+\eta$.
  - *Conclusion.* Lemma 1.2 with $B=\mathcal R_{\max}+\eta$ gives $\Psi(\eta)$. Then let $\sigma\downarrow0$ and $\eta\downarrow0$; $\Psi(\eta)\to\Psi$ by continuity. ∎

---

## 4. Corollary 5.2

Fix $\lambda>0$. For each $d$ let $n=\lceil\lambda2^d\rceil$, and let $c=c_d>0$ and $a=a_d\in(0,1]$ be arbitrary. Let $\mathcal E_d$ be the event (1.2), which has probability at least $1-\rho_n\to1$. With $h_d=2n^{2/3}/M$, define the deterministic numbers

$$
\underline\Psi_{\rm tri}:=\Bigl(\sqrt{\beta_d-h_d}-\sqrt{(1-\vartheta_c)(p_d+h_d)+c(dF_d+1)/M+\vartheta_c\lambda'a}\Bigr)_+^2,\qquad
\underline\Psi_{\rm cor}:=\frac{\bigl(\vartheta_c(p_d-h_d-\lambda'a)-c(dF_d+1)/M\bigr)_+^2}{4(\lambda'+h_d/2)},
$$

and $\underline\Psi_d=\max\{\underline\Psi_{\rm tri},\underline\Psi_{\rm cor}\}$; here $\sqrt u$ is read as $0$ for $u<0$. On $\mathcal E_d$:

- $Q/M\ge\beta_d-h_d$;
- $p_d-h_d\le G/M\le p_d+h_d$;
- $V/M\le\lambda'+h_d/2$.

$\Psi_{\rm tri}$ increases in $Q$ and decreases in $G$; $\Psi_{\rm cor}$ increases in $G$ and decreases in $V$. Dividing by $M$ therefore gives $\Psi\ge\underline\Psi_d$ on $\mathcal E_d$. The same bound holds for $\Psi(\eta)$ with $E_0$ replaced by $E_0+\eta$.

For $\nu\ge0$ define

$$
\Gamma_\lambda(\nu)=\max\Bigl\{\frac{\gamma(\lambda)}{(18\nu+1)^2},\ \Bigl(\sqrt{\beta(\lambda)}-\sqrt{(1-e^{-\lambda})\tfrac{18\nu}{18\nu+1}}\Bigr)_+^2\Bigr\}.
$$

$\Gamma_\lambda$ is continuous, nonincreasing and positive, with $\Gamma_\lambda(0)=\beta(\lambda)$ by (1.0). At $\lambda=1$ its values are:

| $\nu$ | 0 | 0.001 | 0.01 | 0.05 | $1/18$ | 0.1 | 1 |
|---|---|---|---|---|---|---|---|
| $\Gamma_1(\nu)$ | 0.4848 | 0.3488 | 0.1488 | 0.0277 | 0.0250 | 0.0127 | 0.0003 |

The two branches cross at $\nu=0.0390$. The second branch vanishes for $\nu\ge0.1829$.

**Corollary 5.2.** Assume $a_d\to0$; for example $a_d=1/d$, which gives $N_0(a_d)=O(n\log^4n)$. On $\mathcal E_d$, at every width $N\ge N_0(a_d)$, the conclusions of Theorem 5.1 hold with $\Psi\ge\underline\Psi_d$, and:

- **(i)** If $c_d\le d^k$ for a fixed $k$, then $\underline\Psi_d\ge\gamma(\lambda)(18dc_d+1)^{-2}(1-o(1))$, with the $o(1)$ uniform over $c\in(0,d^k]$.
- **(ii)** If $dc_d\le\nu$ for all large $d$, then $\underline\Psi_d\ge\Gamma_\lambda(\nu)-o(1)$.
- **(iii)** If $dc_d\to0$, then $\underline\Psi_d\ge\beta(\lambda)-o(1)$.
- **(iv)** If $dc_d\to\infty$, then on $\mathcal E_d$ the bound $\Psi$ of Theorem 5.1 itself tends to $0$.

Consequently:

- **(a)** If $c_d\le\mathrm{poly}(d)$, depth-two SP$_c$ fails (P$_2$) under each of (R1), (R1′), (R2) and (R3). If $c=c(n)$, the hypothesis reads $c(n)\le\mathrm{polylog}(n)$ along $n=\lceil\lambda2^d\rceil$. It covers every fixed $c>0$ and every $c\to0$.
- **(b)** Suppose $c=c(n,d)\le\nu/\log_2n$ for all large $n$, for some $\nu>0$. Let $C_0\ge\max\{0,\log_2(1/\lambda)\}$. Then depth-two SP$_c$ fails (P$_2^{o(1)}[\log_2n+C_0]$) under each of (R1), (R1′), (R2) and (R3), for every $\alpha>0$ and every $\epsilon_n\to0$. Along $n=\lceil\lambda2^d\rceil$, at every width $N\ge N_0(a_d)$, and so at the width $N=\max\{N_0(a_d),\lceil n^\alpha\rceil\}$ that the formulation covers, the excess is at least $\Gamma_\lambda(\nu)-o(1)$, and the $\limsup_{\sigma\downarrow0}$ of the probability that the inequality of (P$_2^{o(1)}$) holds is at most $\rho_n\to0$. If moreover $c\log n\to0$, the excess is at least $\beta(\lambda)-o(1)$.
- **(c)** If $c\log n\to\infty$ along the family (equivalently $dc_d\to\infty$; this includes every $c$ bounded below, e.g. $c=1$), Theorem 5.1 gives only a vanishing lower bound. It neither proves nor refutes (P$_2^{o(1)}$). See Remarks 5.7a and 5.8.

*Proof.*

**Limits on the family.** By Lemma 1.3, $h_d\to0$, $\lambda'\to\lambda$, $\beta_d\to\beta(\lambda)$ and $p_d\to1-e^{-\lambda}$. Also $a_d\to0$.

**(i)** Since $c\le d^k$,
$$
\frac{c(dF_d+1)}{M\vartheta_c}=\frac{c(18dc+1)(dF_d+1)}M\le\frac{d^k(18d^{k+1}+1)(dF_d+1)}{2^d}\to0 .
$$
So the numerator of $\underline\Psi_{\rm cor}$ is $\vartheta_c^2(p_d-h_d-\lambda'a_d-o(1))_+^2=\vartheta_c^2(1-e^{-\lambda})^2(1+o(1))$. Its denominator is $4\lambda(1+o(1))$.

**(ii)** Put $\vartheta_\nu=1/(18\nu+1)$. Then $\vartheta_c\ge\vartheta_\nu$, $1-\vartheta_c\le1-\vartheta_\nu=18\nu/(18\nu+1)$, $\vartheta_c\lambda'a_d\le\lambda'a_d$, and $c(dF_d+1)\le\nu(F_d+1)$, so $c(dF_d+1)/M\to0$. For large $d$ we have $p_d-h_d-\lambda'a_d>0$. Each of these quantities enters $\underline\Psi_{\rm cor}$ and $\underline\Psi_{\rm tri}$ monotonically, so the four bounds can be applied separately. Hence
$$
\underline\Psi_{\rm cor}\ge\frac{\bigl(\vartheta_\nu(p_d-h_d-\lambda'a_d)-\nu(F_d+1)/M\bigr)_+^2}{4(\lambda'+h_d/2)}\to\gamma(\lambda)\vartheta_\nu^2,
$$
$$
\underline\Psi_{\rm tri}\ge\Bigl(\sqrt{\beta_d-h_d}-\sqrt{(1-\vartheta_\nu)(p_d+h_d)+\nu(F_d+1)/M+\lambda'a_d}\Bigr)_+^2\to\Bigl(\sqrt{\beta(\lambda)}-\sqrt{(1-e^{-\lambda})(1-\vartheta_\nu)}\Bigr)_+^2 .
$$

**(iii)** For every $\nu>0$, eventually $dc_d\le\nu$, so $\liminf\underline\Psi_d\ge\Gamma_\lambda(\nu)$. Let $\nu\downarrow0$ and use $\Gamma_\lambda(0)=\beta(\lambda)$.

**(iv)** On $\mathcal E_d$, $V\ge n-n^{2/3}$, so $\Psi_{\rm cor}\le\vartheta_c^2G^2/(4MV)\to0$. Also $\mathcal R_{\max}\ge(1-\vartheta_c)G\ge(1-\vartheta_c)(p_d-h_d)M$, while $Q\le(\beta_d+h_d)M$. Since $(1-\vartheta_c)(p_d-h_d)\to1-e^{-\lambda}>\beta(\lambda)$ by (1.0), $\Psi_{\rm tri}=0$ for large $d$.

**(a)** Suppose $\mathsf p$ exists.

- *Setup.* Take the competitor $g\equiv0$: width $m=1$, all weights $0$, $B=1$, and $L_{D_d}(g)=1$. Fix $\delta\in(0,1)$ and put $\varepsilon_d=\gamma(\lambda)\vartheta_{c_d}^2/3\in(0,1)$.
- *The sample threshold is passed.* $1/\varepsilon_d=3(18dc_d+1)^2/\gamma(\lambda)$ is at most a polynomial in $d$. So $\lvert\mathsf p(d,1,1,1/\varepsilon_d,\log(1/\delta))\rvert$ is at most a polynomial in $d$, and $n=\lceil\lambda2^d\rceil$ exceeds it for $d\ge d_1$.
- *The bound fails.* By (i), $\underline\Psi_d\ge2\varepsilon_d$ for $d\ge d_2$, and also $\rho_n<(1-\delta)/2$. Fix $d\ge\max\{d_1,d_2\}$ and $N\ge N_0(a_d)$. On $\mathcal E_d$, every $w\in\mathcal N_1$ has $L_{D_d}(\operatorname{clip}z_w)\ge1+2\varepsilon_d$.
- *(R3).* The event $\{L(\mathsf A_n)\le1+\varepsilon_d\}$ lies in $\mathcal E_d^c$, which has probability at most $\rho_n<1-\delta$.
- *(R1).* By Theorem 5.1(3) with $\eta=(1-\delta)/2$, for $\sigma<\sigma_0$ the probability of $\{L(\mathsf A_n)\le1+\varepsilon_d\}$ is at most $\rho_n+\sup_S\Pi_{\sigma,S}(\mathcal N_1^c)<1-\delta$.
- *(R1′).* By Theorem 5.1(3), on $\mathcal E_d$ and for $\sigma<\sigma_0(\eta)$, $\mathcal G_\sigma\ge\mathcal G^{\rm clip}_\sigma\ge(1-\eta)(1+2\varepsilon_d)$, which exceeds $1+\varepsilon_d$ when $\eta<\varepsilon_d/(1+2\varepsilon_d)$. So the event $\{\mathcal G\le1+\varepsilon_d\}$ lies in $\mathcal E_d^c$.
- *(R2).* $\underline\Psi_d(\eta)\to\underline\Psi_d$ as $\eta\downarrow0$. By Theorem 5.1(3) with $\eta$ so small that $\underline\Psi_d(\eta)>\varepsilon_d$, for $\sigma<\sigma_0$ the event lies in $\mathcal E_d^c$.
- *Conclusion.* In every reading (P$_2$) asks for probability at least $1-\delta$ at all small $\sigma$, and this fails.

**(b)** The steps are the following.

- *Dimension range.* $n\ge\lambda2^d$ gives $d\le\log_2n+\log_2(1/\lambda)\le\log_2n+C_0$, so $D_d$ is admissible.
- *Bound on $dc_d$.* $dc_d\le\nu d/\log_2(\lambda2^d)\to\nu$. So for every $\nu'>\nu$, (ii) gives $\liminf_d\underline\Psi_d\ge\Gamma_\lambda(\nu')$. Continuity of $\Gamma_\lambda$ gives $\liminf_d\underline\Psi_d\ge\Gamma_\lambda(\nu)>0$.
- *Competitor class.* The zero network lies in $\mathcal G^{(\alpha)}_n$, and every $f$ has $L_{D_d}(f)\ge1$. So $\inf_{\mathcal G^{(\alpha)}_n}L_{D_d}=1$.
- *Failure.* Without loss of generality $\epsilon_n>0$: a larger $\epsilon_n$ only enlarges the event in (P$_2^{o(1)}$), so if the property held with some $\epsilon_n\to0$, it would also hold with $\max\{\epsilon_n,1/n\}$, which is positive and tends to $0$. Since $\epsilon_n\to0$, for large $d$ we have $\underline\Psi_d\ge\Gamma_\lambda(\nu)/2>2\epsilon_n$. Fix $\alpha>0$ and a width $N\ge N_0(a_d)$; the width $N=\max\{N_0(a_d),\lceil n^\alpha\rceil\}$ is one that (P$_2^{o(1)}$) covers. Repeat the argument of (a) with $\varepsilon_d$ replaced by $\epsilon_n$. Under (R1) the probability in (P$_2^{o(1)}$) is at most $\rho_n+\eta$ for $\sigma<\sigma_0(\eta)$; under (R1′), (R2) and (R3) it is at most $\rho_n$ for all small $\sigma$. So its $\limsup_{\sigma\downarrow0}$ is at most $\rho_n$, and for small $\eta$ and large $d$ the probability is below $1-\delta$ at all small $\sigma$.
- *Case $c\log n\to0$.* Then $dc_d\to0$, and (iii) applies.

**(c)** This is (iv): the theorem's own bound vanishes. ∎

**Numbers** (`bounds_t51.out`, `t1_range.out`). These are worst cases on $\mathcal E_d$ at $\lambda=1$, with $a=1/n$ unless stated.

- **$c=1$, $a=1/n$**, so at widths $N\ge N_0(1/n)$, which is $5.7\cdot10^{31}$ at $d=30$:
  - the bound is $0$ for every $d\le29$ and $1.9\cdot10^{-8}$ at $d=30$;
  - it is at least $2\varepsilon_d$ for every $33\le d\le1000$; the ratio to $\gamma\vartheta_1^2$ is smallest at $d=33$, where it is $0.718$;
  - its maximum over $1\le d\le1000$ is $2.26\cdot10^{-7}$, at $d=35$;
  - for larger $d$ it is about $\gamma(1)\vartheta_1^2$; for example $8.5\cdot10^{-8}$ at $d=60$.
- **$c=1$, $a=1/d$**, at widths $N\ge N_0(1/d)=O(n\log^4n)$: the bound is at least $2\varepsilon_d$ for every $34\le d\le1000$, but not at $d=33$, where it is $1.80\cdot10^{-7}<2\varepsilon_{33}=1.88\cdot10^{-7}$.

  At $c=1$ the bound has no quantitative use.
- **Small $c$.**

| $c$ | $d=30$ | $d=60$ | $d=200$ | limit |
|---|---|---|---|---|
| $1/d$ | $3\cdot10^{-4}$ | $3\cdot10^{-4}$ | $3\cdot10^{-4}$ | $\Gamma_1(1)=3\cdot10^{-4}$ |
| $0.05/d$ | 0.0275 | 0.0277 | 0.0277 | $\Gamma_1(0.05)=0.0277$ |
| $1/d^2$ | 0.0430 | 0.0988 | 0.2189 | $\beta(1)=0.4848$ |
| $1/d^3$ | 0.3403 | 0.4099 | 0.4616 | $\beta(1)=0.4848$ |
| $1/d^3$, with $a=1/d$ | 0.2328 | 0.3090 | 0.3889 | $\beta(1)=0.4848$ |

- **Widths.** At $d=30$, $N_0(1/n)=5.7\cdot10^{31}$, while $N_0(1/d)=4.5\cdot10^{16}=4.2\cdot10^7\,n$.

**Remark 5.2a (why (P$_2^{o(1)}$) asks only for learner widths $N\ge n^\alpha$).** This remark records an example of the second-round logic referee (`../verification/RT-depth2-logic-revised.md`, issue 1). If (P$_2^{o(1)}$) asked for the bound at every learner width $N\ge1$, it would fail for every learner whose output at width $N$ is a network of width $N$ or its clip, as under (R1) and (R3), whatever the learner does.

- *Law and competitor.* Take $d=1$, $x$ uniform on $\{-1,0,1\}$, and $y=g^*(x)$ with $g^*(x)=\frac12[\tanh(1+2x)+\tanh(1-2x)]$. Then $g^*$ is a depth-two network of width $2$ with weights in $[-2,2]$, so $g^*\in\mathcal G^{(\alpha)}_n$ once $n^\alpha\ge2$, and $L_D(g^*)=0$.
- *Width one.* A width-one network $v\tanh(\omega_0+\omega_1x)$ is monotone in $x$, and so is its clip. Here $g^*(0)=\tanh1$ and $g^*(\pm1)=\frac12(\tanh3-\tanh1)$, so $\Delta=g^*(0)-g^*(\pm1)=0.6449$. The best monotone fit to the three values $(g^*(-1),g^*(0),g^*(1))$ pools the two neighbouring values that are out of order, and its mean squared error is $\Delta^2/6=0.0693$. So every width-one output has $L_D\ge0.0693$, while $\inf_{\mathcal G^{(\alpha)}_n}L_D+\epsilon_n\to0$. The referee's optimisation over width-one networks attains this value (`../checks/verify-RT-depth2-logic-revised/width1_strawman.out`).

Under that definition every learner of this kind would fail the property, including the tempered SP$_c$ that `B-tempered-likelihood.md` proves consistent, read under (R1) or (R3); so "SP$_c$ fails it" would say nothing about SP$_c$. Section 1.4 therefore asks for the bound at every $N\ge n^\alpha$, the competitors' width bound. Corollary 5.2(b) is unaffected, since it shows failure at every $N\ge N_0(a_d)$.

**Remark 5.2b (Corollary 5.2(a) for every $c\le n^{o(1)}$).** *Not refereed; observed by the scope referee of the second re-refereeing round* ([`../verification/depth-two-referee-scope-2.md`](../verification/depth-two-referee-scope-2.md), issue 3). Let $c_{\max}(d)\ge1$ satisfy $\log_2c_{\max}(d)/d\to0$. Then Corollary 5.2(i) holds with the $o(1)$ uniform over $c\in(0,c_{\max}(d)]$, and Corollary 5.2(a) holds for every $c_d\le c_{\max}(d)$. Along $n=\lceil\lambda2^d\rceil$ this hypothesis reads $c(n)\le n^{o(1)}$. So SP$_c$ fails (P$_2$) under each of (R1), (R1′), (R2) and (R3) for every $c(n)\le n^{o(1)}$, for example for $c=2^{\sqrt{\log_2n}}$, which exceeds every power of $\log n$.

*Proof.* The proofs of (i) and (a) use $c\le d^k$ in two places only.

- The proof of (i) needs $c(dF_d+1)/(M\vartheta_c)=c(18dc+1)(dF_d+1)/M\to0$. Since $dF_d+1=O(d^4)$, this quantity is at most $2^{o(d)}/2^d$, uniformly over $c\le c_{\max}(d)$.
- The proof of (a) needs $n\ge\mathsf p(d,1,1,1/\varepsilon_d,\log(1/\delta))$. Here $1/\varepsilon_d=3(18dc_d+1)^2/\gamma(\lambda)=2^{o(d)}$, so at fixed $\delta$ the right side is $2^{o(d)}$, and $n\ge\lambda2^d$ exceeds it for large $d$. ∎

The referee's script evaluates the worst case of $\underline\Psi_{\rm cor}$ on $\mathcal E_d$ ($\lambda=1$, $a=1/d$) at $c=2^{\sqrt d}$ and at $c=d^{\ln d}$. Its ratio to $\gamma(1)\vartheta_c^2$ is $0.988$ at $d=256$ and $0.999$ at $d=4096$, and $\log_2(1/\varepsilon_d)/d$ falls to $0.04$ and $0.06$ at $d=4096$ ([`../checks/depth-two-referee-scope-2/fixed_d_and_other_c.out`](../checks/depth-two-referee-scope-2/fixed_d_and_other_c.out), part (5)). Together with the range $n^a\le c(n)\le n^{1-a}$ in which (5.7a) gives (P$_2$) for the clipped readings (Remark 5.7a), and with B's Proposition 9.1 for $c\ge n^{1-o(1)}$, this remark would leave unclassified, for the clipped readings, only sequences $c(n)$ that move between these ranges.

---

## 5. Proposition 5.3 and remarks

**Proposition 5.3 (Hadamard atoms; constant excess when $d=M$).**

- *Atoms.* Let $M=2^k$ and $d=M$. Let $\xi_1,\dots,\xi_M\in\{-1,1\}^d$ be the rows of the Sylvester–Hadamard matrix, so $\xi_j\cdot\xi_l=M\delta_{jl}$ and $\lVert\xi_j\rVert_2=\sqrt d$.
- *Law.* Let $D^{\rm H}_M$ draw $x$ uniform on $\{\xi_j\}$ and an independent fair sign $y$. Then $L_{D^{\rm H}_M}(f)=1+M^{-1}\sum_jf(\xi_j)^2$.
- *Sample.* Let $n=\lceil\lambda M\rceil$, and define $k_j,T,\bar y_j,Q,G,V,\mathcal R$ as in §1.3 with atoms $\xi_j$.

Then:

1. For every width $N\ge1$, every $c>0$ and every sample with $Q>0$, every $w\in\mathcal N_1$ satisfies
$$
\mathcal R(\operatorname{clip}z_w)\le\mathcal R(z_w)\le\mathcal R^{\rm H}_{\max}:=c\bigl(2\sqrt Q+1\bigr)+\frac n{9Q},
$$
and hence
$$
L(z_w)-1\ge L(\operatorname{clip}z_w)-1\ge\Psi^{\rm H}:=\frac1M\Bigl(\sqrt Q-\sqrt{\mathcal R^{\rm H}_{\max}}\Bigr)_+^2 .
$$
The strong-prior statements of Theorem 5.1(3) hold verbatim with $\mathcal R^{\rm H}_{\max}$ and $\Psi^{\rm H}$ in place of $\mathcal R_{\max}$ and $\Psi$.
2. Lemma 1.3 applies verbatim, since it uses only "uniform on $M$ atoms, independent fair signs". Let $\mathcal E_M$ be its event; on it $Q>0$ for large $M$. On $\mathcal E_M$:
   - if $c\le\nu\sqrt M$ with $0\le\nu<\sqrt{\beta(\lambda)}/2$, the excess of every predictor in part 1 is at least
   $$
   \beta(\lambda)\Bigl(1-\sqrt{2\nu/\sqrt{\beta(\lambda)}}\Bigr)^2-o(1);
   $$
   - for $c\le\sqrt M$ it is at least $\beta(\lambda)-4\sqrt c\,M^{-1/4}-O_\lambda(M^{-1/3})$. In particular it is at least $\beta(\lambda)-o(1)$ when $c=o(\sqrt M)$.

*Proof.*

- **Network.** Let $u=M^{-1}\sum_{j\in T}\bar y_j\xi_j\in\mathbb R^d$. Then $u\cdot\xi_l=\bar y_l\mathbf 1_T(l)$ and $\lVert u\rVert^2=Q/M$. Fix $\tau>0$ and give every first-layer row the value $(0,\tau u)$ and every readout weight the value $1/(N\tau)$. Then
$$
z(x)=\tau^{-1}\tanh(\tau u\cdot x),\qquad\kappa_N=\frac dN\,N\tau^2\lVert u\rVert^2+N^2(N\tau)^{-2}=\tau^2Q+\tau^{-2},
$$
using $d=M$. Take $\tau^2=Q^{-1/2}$, which needs $Q>0$; then $\kappa_N=2\sqrt Q$.
- **Accuracy.** By $\lvert\tanh s-s\rvert\le\lvert s\rvert^3/3$, $\lvert z(\xi_l)-\bar y_l\rvert\le\tau^2\lvert\bar y_l\rvert^3/3\le\tau^2/3$ on $T$, and $z=0$ off $T$. So $\mathcal R(z)\le n\tau^4/9=n/(9Q)$.
- **Budget.** As in Theorem 5.1, for $w\in\mathcal N_1$,
$$
\mathcal R(z_w)\le c\kappa_N(w)+\mathcal R(z_w)\le c\bigl(\kappa_N(w_u)+1\bigr)+\mathcal R(z_{w_u})\le\mathcal R^{\rm H}_{\max}.
$$
Lemma 1.2(a), which holds for any finite atom set, and the proof of Theorem 5.1(3) give part 1.
- **Part 2, quantities on the event.** Put $Q^\pm=M\beta_d\pm2n^{2/3}$. On $\mathcal E_M$, $\Psi^{\rm H}\ge M^{-1}\bigl(\sqrt{Q^-}-\sqrt{c(2\sqrt{Q^+}+1)+n/(9Q^-)}\bigr)_+^2$. Also $Q^-/M=\beta(\lambda)-O_\lambda(M^{-1/3})$, and $Q^-\le M\beta_d\le M$.
- **Case $c\le\nu\sqrt M$.** The residual satisfies $\mathcal R^{\rm H}_{\max}/M\le\nu(2\sqrt{Q^+/M}+M^{-1/2})+O(1/M)\to2\nu\sqrt{\beta(\lambda)}$, which gives the first bound.
- **Case $c\le\sqrt M$.** Always $Q\le s\le M$, so $2\sqrt Q+1\le3\sqrt M$, and on $\mathcal E_M$ also $n/(9Q^-)=O_\lambda(1)$. Hence $\mathcal R^{\rm H}_{\max}/M\le3cM^{-1/2}+O_\lambda(M^{-1})$ and $\sqrt{\mathcal R^{\rm H}_{\max}/M}\le\sqrt3\sqrt c\,M^{-1/4}+O_\lambda(M^{-1/2})$. Since $(\sqrt q-r)_+^2\ge q-2r$ for $q\le1$, applied with $q=Q^-/M$, the excess is at least $\beta(\lambda)-2\sqrt3\sqrt c\,M^{-1/4}-O_\lambda(M^{-1/3})$, and $2\sqrt3<4$. ∎

Numbers (`prop53_check.out`, worst case on $\mathcal E_M$, $\lambda=1$; the script prints five decimals):

| $c$ | $M=2^{10}$ | $2^{14}$ | $2^{20}$ | $2^{30}$ | $2^{40}$ | $2^{60}$ | limit |
|---|---|---|---|---|---|---|---|
| $1$ | 0.093 | 0.279 | 0.416 | 0.474 | 0.483 | 0.4848 | $\beta(1)=0.4848$ |
| $0.1\sqrt M$ | 0.015 | 0.062 | 0.093 | 0.103 | 0.104 | 0.104 | 0.1044 |

Explicit networks at $M\le1024$ and $N\in\{1,3\}$ pass every identity. The largest observed ratio $\lvert z-\bar y\rvert/(\tau^2/3)$ was $0.983$.

Remarks on Proposition 5.3:

- **Polynomial-in-$d$ bounds.** Here $n\asymp d$, so the proposition does not contradict polynomial-in-$d$ sample bounds.
- **What it shows.** On $D^{\rm H}_M$ the zero network is Bayes-optimal. Proposition 5.3 shows that SP$_c$ is worse than it by $\beta(\lambda)(1-\sqrt{2\nu/\sqrt{\beta(\lambda)}})^2-o(1)$ when $c\le\nu\sqrt M$ with $\nu<\sqrt{\beta(\lambda)}/2$, and by $\beta(\lambda)-o(1)$ when $c=o(\sqrt M)$, at every learner width and under every reading of §1.4. It refutes no formulation of the conjecture. Its regime is $d=M\asymp n$. There $n$ is only linear in $d$, so polynomial sample bounds make no claim, and no learner competes with $\mathcal G^{(\alpha)}_n$ up to $o(1)$ (Remark 5.3a). The property it does contradict, "$L_D(\mathsf A_n)\le L_D(0)+o(1)$ uniformly over laws with $d\le n/\lambda$", which covers its dimension $d=M\le n/\lambda$, is met by the learner that always outputs $0$.
- **Input norm.** The construction uses $\lVert\xi_j\rVert=\sqrt d$; Remark 5.4 treats unit-ball inputs.

**Remark 5.3a (no learner competes with $\mathcal G^{(\alpha)}_n$ uniformly over $d\le n$).** This example is due to the second-round logic referee (`../verification/RT-depth2-logic-revised.md`, issue 2). Fix $\alpha>0$ and let $d=n$. Let $x$ be uniform on the unit vectors $e_1,\dots,e_n$, which lie in $[-1,1]^d$ and in the unit ball, and let $y=\theta_j$ at $x=e_j$, for a sign vector $\theta\in\{-1,1\}^n$. Call this law $D_\theta$.

- *Competitor.* $g_\theta(x)=n^\alpha\tanh(n^{-\alpha}\theta\cdot x)$ has width one, first-layer weights $0$ and $\pm n^{-\alpha}$ and readout $n^\alpha$, so $g_\theta\in\mathcal G^{(\alpha)}_n$. Since $0\le s-\tanh s\le s^3/3$ for $s\ge0$, $\lvert g_\theta(e_j)-\theta_j\rvert\le n^{-2\alpha}/3$, and so $L_{D_\theta}(g_\theta)\le n^{-4\alpha}/9$.
- *One output.* Let $\mathcal U$ be the set of $j$ such that $e_j$ is not a training input; $\lvert\mathcal U\rvert/n\to e^{-1}$ in probability. Draw $\theta$ uniformly. Given the sample and the learner's internal randomness $\xi$ (for example a posterior draw), the signs $(\theta_j)_{j\in\mathcal U}$ are independent fair signs, independent of the output $f=f_\xi$. For $j\in\mathcal U$ let $s_j$ be the sign of $f(e_j)$, with $s_j=1$ when $f(e_j)=0$. Then $(f(e_j)-\theta_j)^2\ge1$ whenever $\theta_j=-s_j$, and these events are independent, each of conditional probability $1/2$. So $L_{D_\theta}(f)\ge n^{-1}\#\{j\in\mathcal U:\theta_j=-s_j\}$, and Hoeffding's inequality gives $L_{D_\theta}(f)\ge1/(2e)-o(1)>1/7$ with probability $1-o(1)$ over $\theta$, the sample and $\xi$. This covers (R1), (R2) and (R3), whose outputs are single functions.
- *Gibbs risk.* Under (R1′) the learner's loss is the average $\mathbb E_\xi L_{D_\theta}(f_\xi)$, not the loss of one output. Given the sample, put $q_j=\Pr_\xi(s_j(\xi)=-\theta_j)$ for $j\in\mathcal U$. Each $q_j$ is a function of $\theta_j$ alone, so the $q_j$ are independent, lie in $[0,1]$ and have mean $1/2$. Since $\mathbb E_\xi L_{D_\theta}(f_\xi)\ge n^{-1}\sum_{j\in\mathcal U}q_j$, the same Hoeffding step gives $\mathbb E_\xi L_{D_\theta}(f_\xi)\ge1/(2e)-o(1)$ with probability $1-o(1)$ over $\theta$ and the sample.
- *One law.* The $o(1)$ terms above do not depend on the learner. So both bounds hold for every learner and every learner width, and for SP$_c$ at every $c$ and every $\sigma$. Since $\inf_{\mathcal G^{(\alpha)}_n}L_{D_\theta}+\epsilon_n\le n^{-4\alpha}/9+\epsilon_n<1/7$ for large $n$, the probability of the inequality of (P$_2^{o(1)}$), averaged over $\theta$, is $o(1)$ at every $\sigma$. Suppose (P$_2^{o(1)}[\phi]$) held with $\phi(n)\ge n$. Fix $n\ge n_\delta$ and $N\ge n^\alpha$. Each law $D_\theta$ would have a threshold $\sigma_0(\theta)$, and at any $\sigma$ below $\min_\theta\sigma_0(\theta)$, a minimum over the $2^n$ sign vectors, the probability would be at least $1-\delta$ for every $\theta$, and so also on average. For large $n$ this contradicts the previous sentence.

So (P$_2^{o(1)}[\phi]$) is false for every learner, every reading, every learner width and every $c$ once $\phi(n)\ge n$. With $d=\lfloor n/b\rfloor$ unit vectors, for a fixed $b\ge1$, the same argument gives test MSE at least $e^{-b}/2-o(1)$, so $\phi(n)\ge n/b$ is excluded as well. Proposition 5.3 has $d=M\ge n/(\lambda+1)$, which is this case with $b=\lambda+1$. The referee's script (`../checks/verify-RT-depth2-logic-revised/every_learner_dn.out`) shows $\lvert\mathcal U\rvert/n\approx0.368$ and $L_{D_\theta}(g_\theta)\le n^{-4\alpha}/9$ for $n$ up to $10^6$.

**Remark 5.4 (input normalisation).**

- **Proposition 5.3 under unit-ball inputs: the comparison with the zero network survives only for small $c$.** In the unit-ball model of `paper.tex` §2 (`problem-brief.md` §2, "or unit ball"), the inputs become $\xi_j/\sqrt d$.
  - *Cost.* The same function values need rows $(0,\tau\sqrt d\,u)$. Since $d=M$, the energy is $\tau^2MQ+\tau^{-2}$, minimized at $\tau^2=(MQ)^{-1/2}$ with value $2\sqrt{MQ}=\Theta(M)$, comparable to the gain $G$. The accuracy is $\tau^2/3$, so $\mathcal R\le n/(9MQ)$. `prop53_check.out` checks the cost exactly.
  - *What the proof still gives.* The proof of Proposition 5.3 then yields $\mathcal R(z_w)\le c(2\sqrt{MQ}+1)+n/(9MQ)$ on $\mathcal N_1$. On $\mathcal E_M$ this is $M(2c\sqrt{\beta(\lambda)}+o(1))$ for fixed $c$. So Lemma 1.2(a) shows that SP$_c$ is worse than the zero network by at least $\beta(\lambda)\bigl(1-\sqrt{2c/\sqrt{\beta(\lambda)}}\bigr)_+^2-o(1)$, and by $\beta(\lambda)-o(1)$ when $c\to0$.
  - *Numbers.* At $\lambda=1$ the limit is $0.334$ at $c=0.01$ and $0.104$ at $c=0.1$, and it vanishes for $c\ge\sqrt{\beta(1)}/2=0.348$ (`prop53_check.out`, part (3)).
  - *What is not settled.* For $c\ge\sqrt{\beta(\lambda)}/2$, in particular $c=1$, the proof gives nothing under unit-ball inputs, and whether SP$_c$ is then worse than the zero network by a constant is open. In the first-round logic referee's local optimisation at $c\in\{1,4\}$, at learner width $N=8$ with $M=d\in\{64,256\}$ (`../checks/verify-RT-depth2-logic/opt_hadamard.out`), the lowest-objective networks found under unit-ball inputs have test excess at most $0.003$, which suggests that SP$_c$ is not worse by a constant there. That is evidence, not proof, and local optimisation at width $8$ cannot rule out cheaper memorizers at larger widths. This is a question about the learner. It bears on no formulation of the conjecture (Remark 5.3a).
- **Theorem 5.1 and Corollary 5.2 survive unit-ball normalisation.** A row $\omega=(\omega_0,\omega_{1:d})$ acting on $\bar x$ equals the row $(\omega_0,\sqrt d\,\omega_{1:d})$ acting on $(1,x/\sqrt d)$, with squared norm at most $d\lVert\omega\rVert^2\le dF_d$. So the memorizer's first-layer energy becomes at most $d^2F_d$. Nothing else changes. Theorem 5.1 then holds with $dF_d$ replaced by $d^2F_d$ in $E_0$, and every asymptotic statement of Corollary 5.2 is unchanged, since only $c\,d^2F_d/M\to0$ is used.

**Remark 5.5 (learner width).**

- **Where the failures are proved.** Theorem 5.1 and Corollary 5.2 hold at learner widths $N\ge N_0(a)$. With $a=1/d$ this is $N\ge\lceil72d^3n\ln(2M)\rceil+1=O(n\log^4n)$, and with $a=1/n$ it is $O(n^3\log^2n)$. They therefore refute, for SP$_c$ with the stated $c$, the width-uniform formulations of §1.4: (P$_2$) in the range of Corollary 5.2(a), and also (P$_2^{o(1)}$), with its widths $N\ge n^\alpha$, in the range of Corollary 5.2(b). In the same ranges they refute, for SP$_c$, any formulation that asks for the bound at one width $N\ge N_0$. Nothing is proved at smaller widths, so a formulation that asks for the bound only at widths below $N_0$, for example only at $N=\lceil n^\alpha\rceil$ with $\alpha<1$, is not refuted.
- **Small widths succeed.** At much smaller widths the same learner succeeds on this example. Use the display of RT Proposition 6.1, which `small-learner-width.md` Theorem 1(c) re-proves, with probability at least $1-\delta/2$. Both first-round width referees had found the display correct (`../verification/RT-width-logic.md` §2, `../verification/RT-width-computation.md` §2), and `small-learner-width.md` was refereed again (`../verification/RT-width-logic-revised.md`, `../verification/RT-width-computation-revised.md`). Apply it at $L=2$ with the zero competitor as a width-one network with $B=1$, so that $U=1$, $E_*=d(d+1)+2$, $K=d^2+d+3+4n/c$ (the $K'$ of Theorem 1(c)) and $P_N=N(d+2)$. Then, with probability at least $1-\delta$, every $w\in\mathcal N_1$ at width $N$ has
$$
L_{D_d}(\operatorname{clip}z_w)-1\le\frac{c(d^2+d+3)+8}n+4\sqrt{\frac{N(d+2)\ln\bigl(2+2n\sqrt{KN}(d+N+1)\sqrt{K+1}\bigr)+\ln(4/\delta)}{2n}}+4\sqrt{\frac{\ln(4/\delta)}{2n}}.
$$
Along $n=\lceil\lambda2^d\rceil$ with $n^{-O(1)}\le c\le\mathrm{poly}(d)$, the right side tends to $0$ when $N=o(n/\log^2n)$.
- **Conclusion.** For clipped near-minimizers the failure is a large-width phenomenon. On this example it is absent below about $n/\log^2n$ and proved above about $n\log^4n$.

**Remark 5.6 (predictors).** Corollary 5.2 and Proposition 5.3 cover:

- near-minimizers (reading (R3));
- Gibbs draws (R1) and Gibbs risks (R1′), clipped or not;
- the three posterior means $\bar z_\sigma$, $\operatorname{clip}\bar z_\sigma$ and $\bar f_\sigma$ (R2).

They do **not** cover the progressive-mixture predictor of `problem-brief.md` §2, the average over prefixes $t=0,\dots,n$ of posterior means. The prefix posteriors at small $t$ are not controlled by Theorem 5.1, so no lower bound is claimed for it.

**Remark 5.7 (above the window: larger $c$).** This remark is cited, not proved here.

- **The bound.** `B-tempered-likelihood.md` Proposition 6.1 with Lemma 5.3(a) holds for every $c>0$; it was refereed in `../verification/B-logic.md`, `../verification/B-computation.md` and `../verification/B-scope.md`. Apply it with $H=1$ and the competitor $g\equiv0$ written as a width-one network with weights in $[-1,1]$, so that $E_*=d^2+d+2$, $U=1$ and $K=n/c+1$. With probability at least $1-\delta$, on every law $D$ and at every width $N\ge1$:
$$
L_D(\operatorname{clip}z_w)\le L_D(0)+\frac{c(d^2+d+3)}n+8D_n\sqrt{\frac1c+\frac1n}+8\sqrt{\frac{\ln(2/\delta)}{2n}},\qquad D_n=\sqrt{2(d+1)\ln(n+1)} .
$$
This holds for clipped near-minimizers; the same bound holds in the strong-prior limit for $\mathcal G^{\rm clip}_\sigma$ and $\bar f_\sigma$.
- **On the cube family.** Along $n=\lceil\lambda2^d\rceil$, $D_n=\Theta(d)$, so the clipped excess tends to $0$ when $c/d^2\to\infty$ and $cd^2/n\to0$.
- **The window, clipped predictors, $n=\lceil\lambda2^d\rceil$.**
  - Constant excess for $c\le\nu/\log_2n$ (Corollary 5.2).
  - Vanishing excess for $\log^2n\ll c\ll n/\log^2n$.
  - In between, only $\Omega((dc+1)^{-2})$ from below and $O(d/\sqrt c)$ from above are known.
- **Unclipped predictors.** The unclipped version (`B-tempered-likelihood.md` Prop. 6.1 with Lemma 5.3(b)) has a main term of order $D_n\sqrt n/c$, so it vanishes only for $c\gg\sqrt n\log n$.

This replaces RT's "positive side at $L=2$" paragraph, whose "$c^\star=\mathrm{polylog}(n)$" is replaced by the window above.

**Remark 5.7a (what `B-tempered-likelihood.md` gives at depth two for general $c$, and the open range).** This remark answers issue 3 of the second-round logic referee; its paragraph on large $c$ answers point S1 of the first re-refereeing round (§9). It cites `B-tempered-likelihood.md` (B below) and separates what B states from what follows by combining B's statements.

*Stated in B at depth two ($H=1$).*

- **Theorem 6.3** allows every $\theta\in(0,1)$ when $H=1$. For $c=n^{1-\theta}$, every law $D$ on $X\times[-1,1]$ in every dimension $d$, every fixed competitor $g$ of width $m$ with weights in $[-B,B]$, and every $\delta$, with probability at least $1-\delta$ and at every learner width $N\ge m$, the clipped output of every near-minimizer, and the $\limsup_{\sigma\downarrow0}$ of the clipped Gibbs risk and of $L_D(\bar f_\sigma)$, have excess over $L_D(g)$ at most $(E_*+1)n^{-\theta}+8\sqrt2\,D_nn^{-(1-\theta)/2}+(4+(U+1)^2)\sqrt{\ln(2/\delta)/(2n)}$, with $D_n=\sqrt{2(d+1)\ln(n+1)}$ and a polynomial sample size. The clipped readings of §1.4 at $\sigma<\sigma_0$ satisfy this bound with $\ln(4/\delta)$ in place of $\ln(2/\delta)$, plus $4\eta$ under (R1′) and (R2) (passage to the readings, below). So SP$_{n^{1-\theta}}$ has (P$_2$) for the clipped readings. **Theorem 6.4** does the same for the unclipped readings when $\theta<1/2$.
- **Corollary 8.1** at $H=1$: for $0<\alpha<1/8$ and $c=n^{(2-8\alpha)/3}$ (B allows $\alpha<1/4$, but at $H=1$ its bound decays only for $\alpha<1/8$), against $\mathcal G^{(\alpha)}_n$, at every learner width $N\ge n^\alpha$, for every law in every dimension, the clipped readings have excess at most $\Xi_nn^{-\beta}$, with $\Xi_n=d(d+1)+4+8\sqrt2\sqrt{2(d+1)\ln(n+1)}+4\sqrt{2\ln(2/\delta)}$ and $\beta=\min\{(1-4\alpha)/3,\ \frac12-4\alpha\}>0$. At each fixed $\delta$, $\Xi_nn^{-\beta}\to0$ uniformly over $d\le\log_2n+C_0$. This gives (P$_2^{o(1)}[\log_2n+C_0]$) for the clipped readings at these $c$, which range over $(n^{1/3},n^{2/3})$, once $\epsilon_n$ and $n_\delta$ are chosen as in the paragraph on the class $\mathcal G^{(\alpha)}_n$ below, so that $\epsilon_n$ does not depend on $\delta$. Here $\epsilon_n$ is the part of $\Xi_nn^{-\beta}$ that does not involve $\delta$, evaluated at $d=\lfloor\log_2n+C_0\rfloor$, plus $2n^{-\beta/2}$. And $n_\delta$ is so large that the $\delta$-term $4\sqrt{2\ln(4/\delta)}\,n^{-\beta}$, which is B's term at confidence $\delta/2$, is below $n^{-\beta/2}$ for $n\ge n_\delta$. B states the bound for the $\limsup_{\sigma\downarrow0}$ of the clipped Gibbs risk, for every near-minimizer and for $\bar f_\sigma$; the readings of §1.4 need it at all $\sigma<\sigma_0$, and the paragraph after this list supplies that.
- **§7.5 item 3**: on the noisy cube, the proof of Theorem 6.3 gives vanishing excess as soon as $c\gg D_n^2=O(d\log n)$ and $c=o(n)$. B states only the first condition; the second is needed for the term $c(E_*+1)/n$ of its Proposition 6.1. B does not treat the negative side on the noisy cube at depth two, since its Lemma 7.2 needs $H\ge2$; it cites the red-team Theorem 5.1, which is Theorem 5.1 of this note. B's Theorem 7.4 and §7.5 items 1–2, where B treats the threshold on the noisy cube for general $c$, assume $H\ge2$ (B's §7 opens with "Throughout this section $H\ge2$") and do not apply here.
- **Proposition 9.1(a),(b)**, which B states for every $L=H+1\ge2$, every $c>0$ and every $n$, and which its §9 Discussion repeats "for every $c$ and $n$ with $n/c\ge2L$". It concerns the noiseless two-point law $D_{\delta_0}$ in dimension $1$: $x$ uniform on $\{\pm\delta_0\}$ and $y=\operatorname{sign}x$. Put $K=n/c+1$ and $\eta_0=\delta_0K/2$, which is B's $\eta$ at $L=2$. (a) For every sample, every near-minimizer at every learner width has test MSE at least $(1-\eta_0)^2$ when $\eta_0\le1$, and so do the $\liminf_{\sigma\downarrow0}$ of $\mathcal G_\sigma$, $\mathcal G^{\rm clip}_\sigma$, $L_D(\bar z_\sigma)$ and $L_D(\bar f_\sigma)$. (b) When $\delta_0\le1/2$, a width-one network with weights at most $1.5\,\delta_0^{-1/2}$ fits $D_{\delta_0}$ exactly. The consequences at depth two are drawn in the paragraph on large $c$ below.

*Passage to the readings.* B's positive statements hold on an event of probability at least $1-\delta$ that depends on neither $\sigma$ nor $N$. B's threshold $\sigma_0(N,n,c,d,H,\eta)$ does not depend on the sample (the paragraph after B's Proposition 6.1): for $\sigma<\sigma_0$, on that event, the draws that violate the bound have posterior mass at most $\eta$, and the clipped Gibbs risk, hence also $L_D(\bar f_\sigma)$, exceeds the bound by at most $4\eta$. To obtain a reading of §1.4 at confidence $1-\delta$, apply B at confidence $\delta/2$. Under (R1) take $\eta=\delta/2$; the probability over the sample and the draw is then at least $(1-\delta/2)^2\ge1-\delta$. Under (R1′) and (R2) take $\eta$ so small that $4\eta$ fits in the slack left in $\epsilon_n$, which is allowed because $\sigma_0$ may depend on $n$. (R3) involves no $\sigma$. For the unclipped readings the correction comes from B's Lemma 3.1, which is also uniform in the sample. This is the argument of `A-tight-conditioning-fails.md` §5.4, and it is used below without further mention.

*General $c$, one fixed competitor.* B's Proposition 6.1 holds for every $c>0$, with $K=n/c+1$, and its Lemma 5.3 holds for every $K>0$. Inserting Lemma 5.3(a) with $K=n/c+1$ and $\delta'=\delta/2$ into Proposition 6.1, as in the proof of B's Theorem 6.3, gives the following. For every law, every fixed competitor $g$ and every $c>0$, with probability at least $1-\delta$ and at every $N\ge m$, the clipped output of every near-minimizer, and the $\limsup_{\sigma\downarrow0}$ of the clipped Gibbs risk and of $L_D(\bar f_\sigma)$, have

$$
\text{excess over }L_D(g)\ \le\ \frac{c(E_*+1)}n+8D_n\sqrt{\frac1c+\frac1n}+\bigl(4+(U+1)^2\bigr)\sqrt{\frac{\ln(2/\delta)}{2n}} . \tag{5.7a}
$$

By the passage to the readings above, the clipped readings of §1.4 at $\sigma<\sigma_0$ satisfy (5.7a) with $\ln(4/\delta)$ in place of $\ln(2/\delta)$, plus $4\eta$ under (R1′) and (R2). B does not display (5.7a) for general $c$. Remark 5.7 is (5.7a) with $g\equiv0$ written as a width-one network; both second-round referees checked that instance against B.

*General $c$, the polynomial-sample property (not refereed; pointed out by both referees of the second re-refereeing round).* Suppose that $n^a\le c(n)\le n^{1-a}$ for a fixed $a>0$ and all large $n$. The three terms of (5.7a) are then at most $(E_*+1)n^{-a}$, $8\sqrt2\,D_nn^{-a/2}$ and $(4+(U+1)^2)\sqrt{\ln(2/\delta)/(2n)}$. The sample-size arithmetic of B's Theorem 6.3, with $a$ in place of $\theta$ in the first term and in place of $1-\theta$ in the second, gives a sample size polynomial in $(d,m,B,1/\varepsilon,\log(1/\delta))$, of a degree that depends on $a$; adding the constant from which the condition on $c(n)$ holds keeps it polynomial. So SP$_c$ has (P$_2$) for the clipped readings for every such $c(n)$, not only for $c=n^{1-\theta}$. The unclipped variant of (5.7a), whose middle term is of order $D_n\sqrt n/c$ (end of the next paragraph), gives (P$_2$) for the unclipped readings when $n^{1/2+a}\le c(n)\le n^{1-a}$. B states neither consequence. Both referees of the second re-refereeing round point out the first, and its scope referee also the second.

*General $c$, the class $\mathcal G^{(\alpha)}_n$.* As in the proof of B's Corollary 8.1, apply (5.7a) to a minimizer $g$ of $L_D$ over $\mathcal G^{(\alpha)}_n$, which exists and depends only on $D$ and $n$, with $m=\lfloor n^\alpha\rfloor$ and $B=n^\alpha$. Then $E_*+1\le(d(d+1)+4)n^{4\alpha}$ and $4+(U+1)^2\le8n^{4\alpha}$, so at every learner width $N\ge n^\alpha$

$$
\text{excess over }\min_{\mathcal G^{(\alpha)}_n}L_D\ \le\ c\,\bigl(d(d+1)+4\bigr)n^{4\alpha-1}+8D_n\sqrt{\frac1c+\frac1n}+8n^{4\alpha}\sqrt{\frac{\ln(2/\delta)}{2n}} .
$$

Let $d\le\log_2n+C_0$, so that $D_n^2=O(\log^2n)$. Suppose $c/\log^2n\to\infty$ and $c\le n^{1-\epsilon}$ for some $\epsilon>0$, and take $0<\alpha<\min\{1/8,\epsilon/4\}$. The three terms are $O(n^{4\alpha-\epsilon}\log^2n)$, $O(\log n/\sqrt c)$ and, at fixed $\delta$, $O(n^{4\alpha-1/2})$, so all three tend to $0$. Let $\epsilon_n$ be the sum of the first two terms at $d=\lfloor\log_2n+C_0\rfloor$, where they are largest, plus $2n^{2\alpha-1/4}$. Let $n_\delta$ be so large that the third term, with $\delta$ replaced by $\delta/2$, is below $n^{2\alpha-1/4}$ for $n\ge n_\delta$, which is possible because $2\alpha<1/4$; under (R1′) and (R2), take $4\eta\le n^{2\alpha-1/4}$ in the passage to the readings. Then $\epsilon_n$ does not depend on $\delta$ and tends to $0$, and this gives (P$_2^{o(1)}[\log_2n+C_0]$) for the clipped readings. For the unclipped readings, B's Lemma 5.3(b), the unclipped part of its Proposition 6.1 and its sample-uniform Lemma 3.1 give the same with the middle term replaced by $4(\sqrt K+1)\sqrt K\,D_n/\sqrt n+(\sqrt K+1)^2\sqrt{\ln(2/\delta)/(2n)}$, $K=n/c+1$, which is of order $D_n\sqrt n/c$. So they give (P$_2^{o(1)}[\log_2n+C_0]$) when $c/(\sqrt n\log n)\to\infty$ and $c\le n^{1-\epsilon}$, with $\epsilon_n$ and $n_\delta$ chosen in the same way. The new $\delta$-term is of order $\sqrt n/c$ at fixed $\delta$, so the slack added to $\epsilon_n$ becomes $2n^{2\alpha-1/4}+2(\sqrt n/c)^{1/2}$. B states neither statement for general $c$; both are the combinations just described.

*Large $c$: B's two-point law.* At $L=2$ take $\delta_0=\min\{1/2,1/K\}$, so that $\delta_0\le1/2$ and $\eta_0=\delta_0K/2\le1/2$. B's Proposition 9.1 then gives, for every sample and at every learner width, test MSE at least $1/4$ for every near-minimizer and for the $\liminf_{\sigma\downarrow0}$ of every posterior predictor of §1.2, while a width-one network with weights at most $1.5\max\{\sqrt2,\sqrt K\}$ has test MSE $0$. Up to corrections that tend to $0$ as $\sigma\downarrow0$ uniformly in the sample, the lower bound holds at all small $\sigma$, not only in the limit, and under every reading of §1.4. B's proof bounds these corrections by $\Pi_\sigma(\mathcal N_1^c)$ and $\mathbb E_{\Pi_\sigma}[(1+F)\mathbf 1_{\mathcal N_1^c}]$, which tend to $0$ uniformly in the sample by B's Lemma 3.1, and $\operatorname{clip}\bar z_\sigma$ is covered because clip is $1$-Lipschitz. `../checks/depth-two/prop91_l2.out` checks the arithmetic. Two consequences follow.

- If $n/c(n)\le n^{o(1)}$, that is, if $c(n)\ge n^{1-\epsilon}$ eventually for every $\epsilon>0$, then $K=n^{o(1)}$. For every $\alpha>0$ the competitor lies in $\mathcal G^{(\alpha)}_n$ once $n$ is large, so $\inf_{\mathcal G^{(\alpha)}_n}L_D=0$, and the dimension $d=1$ is at most $\log_2n+C_0$. So SP$_c$ fails (P$_2^{o(1)}[\phi]$) for every $\phi\ge1$, under every reading and at every learner width. It also fails (P$_2$). The competitor has width $1$ and weight bound $B_n=n^{o(1)}$, so for every polynomial $\mathsf p$ and fixed $\varepsilon,\delta$, eventually $n\ge\mathsf p(1,1,B_n,1/\varepsilon,\log(1/\delta))$. At such $n$ the excess of SP$_c$ is at least $1/4$ up to the corrections above, which is more than $\varepsilon=1/10$.
- If $c(n)\ge n/4$ for all large $n$, then $K\le5$. One fixed law, $D_{1/5}$, and one fixed width-one competitor, with first-layer row $(0,\sqrt5)=(0,2.2361)$ and readout $1/\tanh(1/\sqrt5)=2.3832$, defeat SP$_c$ at every such $n$: every reading has test MSE at least $(1-K/10)^2\ge1/4$, up to the same corrections, against $0$. So (P$_2$) fails already on one fixed law in dimension $1$. The scope referee of the second re-refereeing round observes that the same argument, with $\delta_0=1/(k+1)$, first-layer row $(0,\sqrt{k+1})$ and readout $1/\tanh(1/\sqrt{k+1})$, gives one fixed law for every $c\ge n/k$ with a fixed $k\ge1$ ([`../checks/depth-two-referee-scope-2/fixed_d_and_other_c.out`](../checks/depth-two-referee-scope-2/fixed_d_and_other_c.out), part (3)); this extension is not refereed.

In the first case the failure is asymptotic. For $c=n/\ln n$ the competitor, with its actual largest weight $1/\tanh\sqrt{\delta_0}\approx\sqrt K$ rather than the bound $1.5\max\{\sqrt2,\sqrt K\}$, lies in $\mathcal G^{(\alpha)}_n$ from $n=10^{16}$ on when $\alpha=0.05$, and from $n=10^{123}$ on when $\alpha=0.01$ (`prop91_l2.out`). When $K\to\infty$ the inputs $\pm\delta_0$ shrink with $n$, and B's Remark 9.4 notes that rescaling the inputs to unit range removes such laws. The failure at $c\ge n/4$ uses a fixed law.

*The status of (P$_2^{o(1)}[\log_2n+C_0]$) at depth two*, for $c=c(n)$:

| $c(n)$ | clipped readings | unclipped readings |
|---|---|---|
| $c\le\nu/\log_2n$ for all large $n$ | fails (Corollary 5.2(b)) | fails (Corollary 5.2(b)) |
| $c\log n\to\infty$ and $c=O(\log^2n)$; includes every fixed $c$, e.g. $c=1$ | open | open |
| $c/\log^2n\to\infty$ and $c=O(\sqrt n\log n)$ | holds (this remark) | open |
| $c/(\sqrt n\log n)\to\infty$ and $c\le n^{1-\epsilon}$ | holds (this remark) | holds (this remark) |
| $n/c\le n^{o(1)}$, that is $c\ge n^{1-o(1)}$ | fails (B Proposition 9.1, $d=1$; this remark) | fails (B Proposition 9.1, $d=1$; this remark) |

At $c=1$ the lower bound of Corollary 5.2 tends to $0$ and the upper bound (5.7a) tends to infinity. A sequence $c(n)$ that fits no row, for example one that oscillates between rows, is not classified here.

*The two formulations differ at depth two.* At $c=\log^3n$, for example, (P$_2$) fails by Corollary 5.2(a), since $c=O(d^3)$, while (P$_2^{o(1)}[\log_2n+C_0]$) holds for the clipped readings, at rate $O(1/\sqrt{\log n})$. This is the distinction RT §2.3 A3 draws.

**Remark 5.8 (what is open).**

1. **The "$+o(1)$" formulation when $c$ is not small.** It is open whether depth-two SP$_c$ has (P$_2^{o(1)}[\log_2n+C_0]$) when $c\log n\to\infty$ and $c=O(\log^2n)$ (clipped readings), or $c=O(\sqrt n\log n)$ (unclipped readings); see Remark 5.7a. This range includes every fixed $c$, and in particular the clean-label scaling $c=1$.
   - On the cube family at $n\asymp2^d$ the known bounds are $\Omega((dc+1)^{-2})$ from below (Corollary 5.2(i)) and $O(d/\sqrt c)$ from above for clipped predictors (Remark 5.7). A lower bound by a constant there would refute the formulation in this range.
   - The proof of Theorem 5.1 would give a constant for every fixed $c$ if some depth-two network computed $t\cdot(\text{a fit of }\bar y\mathbf 1_T)$ at energy $\mathrm{poly}(d)+O(t^2G)$, instead of Lemma 2.1's $dF_d+18dt^2Q$. The bracket would then be minimized at a $t$ bounded away from $0$.
   - At depth two, memorizing arbitrary signs on $s$ distinct cube points needs energy of order at least $s/d^2$ (`A-tight-conditioning-fails.md` Proposition 8.2(a) with $H=1$). So that lower bound does not exclude such a network.
2. **The progressive-mixture predictor** (Remark 5.6).
3. **Widths between $n/\log^2n$ and $n\log^4n$** (Remark 5.5).
4. **Proposition 5.3 under unit-ball normalisation for $c\ge\sqrt{\beta(\lambda)}/2$**, e.g. $c=1$: whether SP$_c$ is then worse than the zero network by a constant (Remark 5.4). This is a question about the learner. It bears on no formulation of the conjecture, since at $d\asymp n$ no learner meets one (Remark 5.3a).

---

## 6. Errata for other places in `red-team.md` that summarise §5

`red-team.md` §5 is replaced by a pointer to this note. The first group of items gives replacement text for the places elsewhere in `red-team.md` that summarise §5; the second records the corrections to §5 itself. They follow from §§3–5 and §7.1 and claim nothing beyond them; where they cite `B-tempered-likelihood.md`, they cite statements that Remark 5.7a restates and checks.

*Summaries of §5 elsewhere in `red-team.md`.*

- **§0 item 6.** Replace by:
  > 6. **(3) $L=2$: the learner still fits part of the noise. Its excess is at least of order $(dc+1)^{-2}$ for every $c\le\mathrm{polylog}(n)$, at least a constant when $c\le\nu/\log n$, and at least the full $\beta(\lambda)-o(1)$ when $c=o(1/\log n)$** (corrected §5, `depth-two.md`).
  >    - Proved: for every $0<c\le\mathrm{poly}(d)$, excess $\ge\gamma(\lambda)(18dc+1)^{-2}(1-o(1))$ at $n=\lceil\lambda2^d\rceil$ (for example $\approx0.0999/(18d+1)^2$ at $c=1$, $\lambda=1$). So SP$_c$ fails the polynomial-sample version (Theorem 5.1, Corollary 5.2(a)).
  >    - Proved: constant excess $\ge\Gamma_\lambda(\nu)-o(1)$ when $c\le\nu/d$, and $\ge\beta(\lambda)-o(1)$ when $dc\to0$. So SP$_c$ fails the "$+o(1)$" version, uniform over $d\le\log_2n+O(1)$ and required at every learner width $N\ge n^\alpha$, for $c(n)\le\nu/\log_2n$ (Corollary 5.2(b)).
  >    - Proved: with $d=M\approx n/\lambda$ (Hadamard atoms, inputs of norm $\sqrt d$) and $c=o(\sqrt n)$, SP$_c$ is worse than the Bayes-optimal zero network by $\beta(\lambda)-o(1)$ at every width (Proposition 5.3). This refutes no version of the conjecture: at $d\asymp n$ no learner competes with networks of width and weights $n^\alpha$ up to $o(1)$ (`depth-two.md` Remark 5.3a).
  >    - Open: whether the "$+o(1)$" version holds when $c\log n\to\infty$ and $c=O(\log^2n)$ for clipped predictors, or $c=O(\sqrt n\log n)$ for unclipped ones; this includes every fixed $c$ and $c=1$. Above these ranges it is settled: it holds for $\log^2n\ll c\le n^{1-\epsilon}$ (clipped predictors) and for $\sqrt n\log n\ll c\le n^{1-\epsilon}$ (all predictors), and it fails for $c\ge n^{1-o(1)}$, on a two-point law in dimension $1$ (`depth-two.md` Remark 5.7a, from `B-tempered-likelihood.md` Proposition 6.1, Corollary 8.1 and Proposition 9.1).
  >    - Numerics: on one sample each ($\lambda=1$, $c=1$), the networks found by L-BFGS show that every network whose objective is at most theirs leaves training residual at most $(1-\phi)G$, with $\phi\ge0.395$ at $d=8$ and $\phi\ge0.577$ at $d=10$ ($\phi\approx0.396$ and $0.578$). At the run's width, every near-minimizer leaves at most $(1-\phi)G+c$, so it absorbs at least $0.389$ and $0.576$ of $G$. The two runs used different optimizer budgets, so they show no trend in $d$ (`depth-two.md` §7.1).
- **§2.3 A3, last sentence.** Replace "The depth-two cube bound (Theorem 5.1) refutes only the polynomial one." by: "The depth-two cube bound (Theorem 5.1) refutes the polynomial one for every $c\le\mathrm{poly}(d)$. It also refutes the '$+o(1)$' one when $c\le\nu/\log_2n$, with constant excess $\Gamma_\lambda(\nu)$, and $\beta(\lambda)$ when $c\log n\to0$. It is silent on the '$+o(1)$' one when $c\log n\to\infty$, e.g. for every fixed $c$. The two formulations do differ at depth two: at $c=\log^3n$ the polynomial one fails, while the '$+o(1)$' one holds for clipped predictors (`depth-two.md` Remark 5.7a)."
- **§6.1 "High dimension with repeated inputs".** Replace "fails, by Proposition 5.3 ($d=M$, depth two)" by: "fails for every learner, for a reason unrelated to close conditioning: with $d=n$ and $x$ uniform on the unit vectors, no learner competes with networks of width and weights $n^\alpha$ up to $o(1)$ (`depth-two.md` Remark 5.3a). Proposition 5.3 adds that SP$_c$ with $c=o(\sqrt n)$ is worse there than the Bayes-optimal zero network by $\beta(\lambda)-o(1)$, for inputs of norm $\sqrt d$. For unit-ball inputs it shows a constant gap $\beta(\lambda)\bigl(1-\sqrt{2c/\sqrt{\beta(\lambda)}}\bigr)_+^2-o(1)$ only for $c<\sqrt{\beta(\lambda)}/2$, the full $\beta(\lambda)-o(1)$ only when $c\to0$, and nothing at $c=1$ (`depth-two.md` Remark 5.4)."
- **§6.4, second bullet.** Replace by: "Whether depth-two SP$_c$ satisfies the '$+o(1)$' version when $c\log n\to\infty$ and $c=O(\log^2n)$ (clipped predictors; up to $c=O(\sqrt n\log n)$ for unclipped ones), for example at every fixed $c$. On the cube family this asks whether the excess stays above a constant at $n$ superpolynomial in $d$ (`depth-two.md` Remarks 5.7a and 5.8)."
- **§7 item 3, last sentence.** Replace "At depth two, $c^\star$ is only polylogarithmic." by "At depth two, on the cube family and for clipped predictors, the transition lies between $c\approx1/\log n$ (constant excess below) and $c\approx\log^2n$ (vanishing excess above). For the polynomial-sample version, every $c\le\mathrm{polylog}(n)$ fails (Corollary 5.2(a)), and $c=n^{1-\theta}$ with $0<\theta<1$ works for clipped predictors (`B-tempered-likelihood.md` Theorem 6.3)."
- **Appendix A, paragraph on `memorize_opt.py` / `memorize_opt2.py`.** Replace "The runs are those in the §5 table, plus the $c\in\{4,16\}$ sweep at $d=8$." by "The runs are recorded in `depth-two.md` §7.1, which reproduces the table and the tempering sweep of the former §5.4." Replace "the captured fractions are lower bounds on what every near-minimizer captures for that sample" by "the captured fraction $\phi$ is a lower bound on what every network with objective at most the one found captures for that sample; at the run's width, every near-minimizer captures at least $\phi-c/G$, which is $0.389$ and $0.576$ in the two depth-two runs at $c=1$ (`depth-two.md` §7.1)".

*Corrections to §5 itself, now replaced by this note.*

- **§5 heading.** Replace "Depth two ($L=2$) with $c=1$" by "Depth two ($L=2$), every $c>0$".
- **Corollary 5.2.** Replace its last two sentences, including the parenthetical, by Corollary 5.2 and the "Numbers" paragraph of §4.
- **The sentence after Proposition 5.3.** Replace "It therefore does not contradict polynomial-in-$d$ sample bounds, but it does refute the user's dimension-free phrasing at $L=2$ with a constant excess." by: "It therefore does not contradict polynomial-in-$d$ sample bounds. It refutes no dimension-free phrasing either, since at $d\asymp n$ no learner competes with networks of width and weights $n^\alpha$ up to $o(1)$ (`depth-two.md` Remark 5.3a). It shows that SP$_c$ with $c=o(\sqrt n)$ is worse than the Bayes-optimal zero network by $\beta(\lambda)-o(1)$."
- **"The positive side at $L=2$" paragraph.** Replace by Remarks 5.7 and 5.7a.
- **§5.4 numerics.** Carried into §7.1 of this note, from the run files, with three corrections. Delete "At depth two, the captured fraction rises with $d$, from 0.40 to 0.58." The two depth-two rows are certified lower bounds for single samples, obtained with different optimizer budgets (3×20000 against 1×6000 L-BFGS iterations). Their values of $\phi$ are $0.396$ and $0.578$ (certified: at least $0.395$ and $0.577$), which the table rounds up to 0.40 and 0.58. And "this yields a lower bound on the noise captured by *every* near-minimizer for that sample" holds for the networks whose objective is at most the one found; for every near-minimizer, $c/G$ must be subtracted.
- **§5 "Open" paragraph.** Its question, whether the depth-two excess on the cube at $c=1$ stays above a constant, is still open; it is item 1 of Remark 5.8. The paragraph did not say that the neighbouring regimes are settled: for $c\le\nu/\log_2n$ the excess is constant (Corollary 5.2(b)), and for $\log^2n\ll c\ll n/\log^2n$ the clipped excess tends to $0$ (Remark 5.7).

---

## 7. Numerical record

All scripts are in `../checks/depth-two/`, and each has a matching `.out` file produced by `python3 X.py > X.out` in that folder.

| Script | What it checks | Result |
|---|---|---|
| `bounds_t51.py` | $\beta,\gamma$ and their maxima; $\beta\ge4\gamma$ on $\lambda\in[0.05,10]$; Theorem 5.1's explicit bound on the worst case of $\mathcal E_d$ for $c=1$ and small $c$, with $a=1/n$ and $a=1/d$; $\Gamma_\lambda(\nu)$ and its branch crossing; convergence of the explicit bound at $c=\nu/d$ to $\Gamma_1(\nu)$ ($d\le400$); widths $N_0$ | values as in §§1.3, 4. Example: $c=\nu/d$, $\nu=0.05$: $0.0275$ ($d=30$), $0.0277$ ($d\ge60$) |
| `t1_range.py` | $c=1$, $\lambda=1$, at 200 digits, for $a=1/n$ and $a=1/d$ and every $1\le d\le1000$: the first $d$ with a positive bound; the largest bound; the $d$ with bound $\ge2\varepsilon_d$; the smallest ratio to $\gamma\vartheta_1^2$; whether that ratio is nondecreasing on $[31,1000]$ (not used in the text) | positive from $d=30$ for both $a$. $a=1/n$: maximum $2.26\cdot10^{-7}$ at $d=35$; $\ge2\varepsilon_d$ for every $33\le d\le1000$, smallest ratio $0.718$ at $d=33$. $a=1/d$: $\ge2\varepsilon_d$ for every $34\le d\le1000$, smallest ratio $0.748$ at $d=34$. The ratio never decreases |
| `prop53_check.py` | Prop. 5.3 with explicit matrices ($M\le1024$, $N\in\{1,3\}$, $\lambda\in\{1,1.5\}$): orthogonality, $\kappa_N=2\sqrt Q$, error $\le\tau^2/3$, $\mathcal R\le n/(9Q)$, unit-ball cost $\tau^2MQ+\tau^{-2}$; (2) explicit bound on $\mathcal E_M$ for $c=1$ and $c=\nu\sqrt M$, printed with five decimals; (3) unit-ball bound for $c\in\{1,0.5,0.3,0.1,0.01,1/\log_2M\}$ | all assertions pass; table in §5 (for example $0.01549$ at $M=2^{10}$, $c=0.1\sqrt M$). Unit ball: $0$ at $c\ge0.5$; at $M=2^{60}$, $0.0025$ ($c=0.3$), $0.104$ ($c=0.1$), $0.334$ ($c=0.01$) |
| `lemma_checks.py` | Lemma 1.2(a),(b) with a general budget against the exact constrained minimum (3000 instances); $\mathcal R(tg)\le(1-t)^2G+nta$ (20000 random and adversarial instances); the bracket (sympy); $\mathfrak c_k=\pm\binom{2m}m4^{-m}$ and $\lvert\mathfrak c_k\rvert\ge1/\sqrt{2k}$ ($k\le40$); $\lvert\mathfrak c_{k,\alpha_d}\rvert2\sqrt{2k}\ge1$ ($1\le k\le d\le80$) | 0 violations; minimum $1.337$ |
| `lemma21_net.py` | Lemma 2.1 built explicitly ($d=3,4,5$; $a\in\{1,\frac12\}$; $N\in\{m_0,2.5m_0+3\}$; $t\in\{1,0.37,\vartheta_1\}$): exact mixture, mass $\le A_0$, rows $\le F_d$, $\sup\lvert g-r\rvert\le a/2$, output $=tg$, $\kappa_N\le dF_d+2t^2A_0^2$, residual and objective chain | all pass |
| `lemma13_mc.py` | $\mathrm{Var}(S^2)=2k^2-2k$ ($k\le10$); frequency of $\mathcal E_d$ against its guaranteed lower bound ($d=8,10,12,14$) | frequency $0.930/0.972/0.995/0.999$ against guarantees $-0.11/0.38/0.62/0.76$ |
| `prop91_l2.py` | B's Proposition 9.1 at $L=2$ (Remark 5.7a): for $\delta_0=\min\{1/2,1/K\}$ on a grid of $K$, it asserts $\eta_0\le1/2$, $\omega^2\ge2$, $\omega\le v\le1.5\,\omega$ and the weight bound $1.5\max\{\sqrt2,\sqrt K\}$ of the width-one competitor, and prints B's lower bound $(1-\eta_0)^2$ and the error of the competitor's fit; the fixed law $\delta_0=1/5$ for $K\le5$; for $c=n/\ln n$ and $c=n/\ln^2n$, the least $n=10^j$ from which the competitor, with its actual weights, lies in $\mathcal G^{(\alpha)}_n$, $\alpha\in\{0.1,0.05,0.01\}$; the asserted step $\lvert z(x)-z(x')\rvert\le(\kappa_N/2)\lvert x-x'\rvert$ on 20000 random networks | all assertions pass; fixed competitor: row $(0,2.2361)$, readout $2.3832$; $c=n/\ln n$: from $10^{6}$, $10^{16}$, $10^{123}$; $c=n/\ln^2n$: from $10^{16}$, $10^{40}$, $10^{282}$; largest Lipschitz ratio $0.962$ |
| `rt54_record.py` | the runs of RT §5.4 (§7.1): rebuilds the two samples, computes $G,Q,V,W$ exactly, reads the recorded objective values from the run files, and evaluates the certified bounds, allowing for the two-decimal rounding of the recorded values | $G=154.8$ ($d=8$) and $634.07$ ($d=10$); depth two, $c=1$: $\phi\ge0.3958$ and $0.5777$; every near-minimizer captures at least $0.3894$ and $0.5761$ of $G$, and has excess at least $0.0146$ and $0.0325$ |

Two scripts changed after the second referee round, and both were re-run. `prop53_check.py` now prints five decimals in part (2): its earlier output $0.0155$ had been rounded again to $0.016$ in the table of §5, while the value is $0.01549$. `t1_range.py` now runs at 200 digits and covers $a=1/d$ and every $d\ge1$; at 80 digits it had reported 68 spurious decreases of the ratio at $d\ge806$, which were rounding noise. The docstrings of `bounds_t51.py`, `lemma_checks.py` and `prop53_check.py` now name this note; `bounds_t51.py` and `lemma_checks.py` were re-run, and their outputs are unchanged. After the first re-refereeing round, `prop91_l2.py` and `rt54_record.py` were added; each runs in under a second. No existing script changed then, and no script changed after the second re-refereeing round.

These results agree with the referees' independent scripts: `../checks/verify-RT-depth2-logic/` and `../checks/verify-RT-depth2-computation/` (first round), and `../checks/verify-RT-depth2-logic-revised/` and `../checks/verify-RT-depth2-computation-revised/` (second round). The examples of Remarks 5.2a and 5.3a are checked in the second-round logic referee's `width1_strawman.py` and `every_learner_dn.py`. The scripts of the two re-refereeing rounds are in `../checks/depth-two-referee-scope-1/`, `../checks/depth-two-referee-logic-computation-1/`, `../checks/depth-two-referee-scope-2/` and `../checks/depth-two-referee-logic-computation-2/`. In the second of these rounds the logic-and-computation referee re-ran `prop91_l2.py` and `rt54_record.py`, whose outputs were byte-identical to the recorded ones, found the six older scripts unchanged and their four re-run outputs identical to the published ones, and re-ran three runs of §7.1 from an unmodified copy of `memorize_opt2.py` ($d=10$, $L=2$, $c=1$; $d=8$, $L=2$, $c\in\{4,16\}$), each of which reproduced its run file to every printed digit. The values at $c=d^{-3}$ differ slightly from those the first-round logic referee reports (0.342/0.410/0.462): that referee used the surrogate values $Q=\beta M$, $G=(1-e^{-1})M$, $V=M$, while §4 uses the worst case on $\mathcal E_d$.

### 7.1 The optimisation runs of RT §5.4

RT §5.4 reported local optimisations of $F_c$ on single samples. RT §5 is replaced by a pointer to this note, so the runs are recorded here, with the values read from the run files. The depth-three rows concern Claim A. They are kept so that the record of RT §5.4 is complete, and nothing in this note uses them.

The runs used `../checks/red-team-and-literature/memorize_opt.py` and `memorize_opt2.py` on the cube example with $\lambda=1$: $n=M=2^d$ inputs drawn with replacement, fair-sign labels, sample seed $0$ at $d=8$ and $1$ at $d=10$, and L-BFGS on $F_c-W/c=\kappa_N+\mathcal R/c$. The $d=8$, $c=1$ runs used 3 restarts of up to 20000 iterations; the $d=10$ runs and the tempering sweep used 1 restart of up to 6000 (RT Appendix A). The two samples have $s=164$ seen atoms and $G=154.8$ at $d=8$, and $s=640$ and $G=634.07$ at $d=10$ (`rt54_record.out`). The captured fraction of the network found is $\phi=1-c(F_c-W/c)/G$.

| $d$ | $L$ | $N$ | $c$ | $F_c-W/c$ found | $\kappa_N$ | $\mathcal R$ | $\phi$ | excess of the network found (seen-atom part) | run file |
|---|---|---|---|---|---|---|---|---|---|
| 8 | 2 | 256 | 1 | 93.51 | 58.32 | 35.19 | 0.396 | 0.2057 (0.1556) | `../checks/verify-RT-depth2-computation/rerun_d8_L2_c1.txt` |
| 10 | 2 | 512 | 1 | 267.75 | 198.17 | 69.58 | 0.578 | 0.2887 (0.2285) | `../checks/red-team-and-literature/run_d10_L2.txt` |
| 8 | 3 | 128 | 1 | 46.8 | 43.7 | 3.1 | 0.70 | 0.500 (0.367) | none in the repository |
| 10 | 3 | 128 | 1 | 89.76 | 87.17 | 2.59 | 0.858 | 0.5967 (0.4223) | `../checks/red-team-and-literature/run_d10_L3.txt` |
| 8 | 2 | 256 | 4 | 37.74 | 1.44 | 145.20 | 0.025 | 0.0160 (0.0101) | `../checks/red-team-and-literature/run_d8_L2_c4.txt` |
| 8 | 3 | 128 | 4 | 38.61 | 1.26 | 149.37 | 0.002 | 0.0084 (0.0053) | `../checks/red-team-and-literature/run_d8_L3_c4.txt` |
| 8 | 2 | 256 | 16 | 9.68 | 0 | 154.80 | 0 | 0 | `../checks/red-team-and-literature/run_d8_L2_c16.txt` |
| 8 | 3 | 128 | 16 | 9.68 | 0 | 154.80 | 0 | 0 | `../checks/red-team-and-literature/run_d8_L3_c16.txt` |

The values of the first row are those of the first-round computation referee's re-run, which reproduces RT's table; RT's own run file for that row is not in the repository. Nor is any run file for the third row: its values are those printed in RT §5.4, and its $F_c-W/c$ is $\kappa_N+\mathcal R$ from them. At $c=16$ the optimiser returned the zero network, whose objective is $G/16$.

*What the runs certify.* The value found bounds $\min F_c$ from above. So, for that sample and at the run's width (`rt54_record.out`, which allows for the two-decimal rounding of the recorded objective):

- every network whose objective is at most the one found has $\mathcal R\le(1-\phi)G$. At depth two and $c=1$, $\phi\ge0.3958$ ($d=8$) and $\phi\ge0.5777$ ($d=10$);
- every near-minimizer, whose objective exceeds the minimum by at most $1$, has $\mathcal R\le(1-\phi)G+c$, so it captures at least $\phi-c/G$ of $G$: $0.3894$ and $0.5761$ at depth two and $c=1$. By Lemma 1.2(b) its clipped excess is then at least $0.0146$ ($d=8$) and $0.0325$ ($d=10$);
- at $c=4$ and $c=16$ nothing is certified for near-minimizers, since $\phi-c/G<0$.

The field "rigorous near-min excess LB" of the run files is $(\phi G)^2/(4MV)$. It is the bound for networks whose objective is at most the one found, and it omits the slack $c$ of a near-minimizer.

*What RT §5.4 read from the runs*, with the corrections of §6. At depth three the networks found essentially interpolate, and their excess exceeds the seen-atom ceiling $Q/M\approx0.47$ because they also predict nonzero values on unseen atoms. The two depth-two runs at $c=1$ used different optimiser budgets, so they show no trend in $d$. In the sweep at $d=8$, the $c=1$ memorizer at depth three ($\kappa_N=43.7$, $\mathcal R=3.1$) has $F_4-W/4=44.5>G/4=38.7$, so it is no longer competitive at $c=4$. Local optimisation can miss partial memorizers, so the runs do not bound from above what near-minimizers capture. RT read the sweep as placing the transition at this $n=256$ between $c=1$ and $c=4$, below the asymptotic value $n^{1-1/H}=16$ of depth three; for the reason just given, that reading is not certified.

---

## 8. Response to the first-round referees

§8 is the response to the first round, updated in place in five bullets (L2, L3, L5, C2, C3) to match the current text; §9 records the later rounds, including these updates.

Entries are keyed to the issue lists L = `../verification/RT-depth2-logic.md` §3 and C = `../verification/RT-depth2-computation.md` §7. J is the major issue as both verdicts state it; it is the same as L1 and C1. The referees' constant $\kappa$ is renamed $\nu$, to avoid a clash with the energy $\kappa_N$.

**J (= L1 = C1). Major: false scope claim in Corollary 5.2 (last sentence), §2.3 A3 and the §0 item 6 "Open" bullet. Accepted, fixed, and the result strengthened.**

- *Diagnosis.* The sentence "It does not refute the '$+o(1)$' formulation, since $\varepsilon_d\asymp1/\log^2n$" was false on the corollary's own range, which includes $c\to0$. $\varepsilon_d$ is of order $(dc+1)^{-2}$, which is of order one when $c=O(1/d)$.
- *Fix.* Corollary 5.2 now has three regimes:
  - for $c\le\nu/d$, excess $\ge\Gamma_\lambda(\nu)-o(1)\ge\gamma(\lambda)/(18\nu+1)^2-o(1)$; this is $0.0277$ at $\nu=0.05$, $\lambda=1$;
  - for $dc\to0$, excess $\ge\beta(\lambda)-o(1)$, from the same budget $(1-\vartheta_c)G+E_0$ with Lemma 1.2(a) in place of 1.2(b);
  - both refute the "$+o(1)$" formulation uniform over $d\le\log_2n+C_0$, for every $c(n)\le\nu/\log_2n$ (Corollary 5.2(b)).
- *Scope of the old sentence.* It is kept only where it is true: when $dc\to\infty$, which includes every $c$ bounded below (Corollary 5.2(c),(iv)).
- *Theorem 5.1.* It now states both bounds, so the corollary needs no new argument.
- *Errata.* §6 gives replacement text for A3, for §0 item 6 (the "Open" bullet is restricted to $c\log n\to\infty$, which covers $c$ bounded below), for §6.4, and for §7 item 3.
- *Numbers.* The referees' values are reproduced, here as worst cases on the event:
  - at $c=0.05/d$: $0.0275$ at $d=30$ and $0.0277$ for $d\ge60$ (the referee's surrogate gives $0.0277$ at every $d$);
  - at $c=d^{-3}$: $0.340$, $0.410$ and $0.462$ for $d=30$, $60$ and $200$.

**L2. Minor: width not stated in Corollary 5.2. Accepted.**

- Theorem 5.1 and Corollary 5.2 now state the width $N\ge N_0(a)$.
- I adopted C3's choice $a=1/d$, which gives $N_0=O(n\log^4n)$.
- The optional $a=\eta(18dc+1)^{-1/2}$ was not used. For fixed $c$ it would save a further width factor of order $d\eta^2/c$. But it does not tend to $0$ when $dc=O(1)$, so it would lose part of the constants in regimes (ii)–(iii) of Corollary 5.2, which need $a_d\to0$.
- Remark 5.5 states that only width-uniform formulations, or formulations that ask for one width $N\ge N_0$, are refuted.
- Remark 5.5 also records the small-width contrast: by the display of RT Prop. 6.1 (which the width referees found correct, and which `small-learner-width.md` Theorem 1(c) now re-proves), with the zero competitor, clipped near-minimizers have vanishing excess on this example at $N=o(n/\log^2n)$ when $n^{-O(1)}\le c\le\mathrm{poly}(d)$.

**L3. Minor: the predictors covered are not named; the progressive mixture is not covered. Accepted.**

- §1.2, Corollary 5.2(a) via the readings of §1.4, and Remark 5.6 name the predictors covered: near-minimizers, Gibbs draws and Gibbs risks (clipped or not), and $\bar z_\sigma$, $\operatorname{clip}\bar z_\sigma$, $\bar f_\sigma$.
- The progressive mixture is explicitly excluded, and no claim is made for it.

**L4. Minor: Proposition 5.3 depends on inputs of norm $\sqrt d$. Accepted.**

- Proposition 5.3 now states $\lVert\xi_j\rVert=\sqrt d$.
- Remark 5.4 confirms that under unit-ball normalisation the same construction costs $2\sqrt{MQ}=\Theta(M)$, comparable to $G$; the cost is checked exactly in `prop53_check.out`.
- One refinement of the referee's "the proof fails": that holds for $c$ of order one (e.g. $c=1$; vanishing for all $c\ge\sqrt{\beta(\lambda)}/2=0.348$ at $\lambda=1$). For smaller $c$ the same argument still gives excess $\ge\beta(\lambda)(1-\sqrt{2c/\sqrt{\beta(\lambda)}})_+^2-o(1)$, and $\beta(\lambda)-o(1)$ when $c\to0$ (Remark 5.4, `prop53_check.out` part (3)). The §0.1 summary, the Remark 5.8 open problem and the §6 erratum for §6.1 are worded accordingly.
- The referee's optimisation at $c\in\{1,4\}$ is cited as evidence only.
- Remark 5.4 also proves the referee's statement that Theorem 5.1 and Corollary 5.2 survive unit-ball normalisation with $dF_d\to d^2F_d$.

**L5. Minor: the quantifier on $d$ in the "$+o(1)$" formulation. Accepted.**

- §1.4 defines (P$_2^{o(1)}[\phi]$) with an explicit dimension range $d\le\phi(n)$, together with the readings (R1)–(R3).
- §0.2 gives the referee's table, with one addition: the fixed-$d$ row now cites `A-tight-conditioning-fails.md` Proposition 5.2 (refereed) for the consistency of the cube family at a fixed $d$, which holds when $c=o(n)$ (§0.2, last row and "Input dimension").

**L6. Minor: wording and edge cases. Accepted, item by item.**

- "$\Omega(1/(dc)^2)$" is now $\Omega((dc+1)^{-2})$.
- $O(d/\sqrt c)$ is stated as a bound for clipped predictors only, and the "$c^\star=\mathrm{polylog}(n)$" sentence is replaced by the two-sided window (Remark 5.7).
- Lemma 1.2(b) now proves that $B<G$ forces $V>0$.
- Proposition 5.3 assumes $Q>0$, which holds on the event for large $M$.
- The display of Theorem 5.1 is stated deterministically.
- The §5 heading is corrected (§6).
- The network scale $\epsilon$ is renamed $\tau$.
- The rate in Proposition 5.3 is now explicit: $\beta(\lambda)-4\sqrt cM^{-1/4}-O(M^{-1/3})$.

**C2. Minor: the numerical parenthetical in Corollary 5.2. Accepted.**

- The bound was recomputed on the worst case of the event, with $a=1/n$ (`bounds_t51.out`, `t1_range.out`): $0$ for $d\le29$; $1.9\cdot10^{-8}$ at $d=30$; at least $2\varepsilon_d$ for every $33\le d\le1000$; maximum $2.26\cdot10^{-7}$ at $d=35$. With $a=1/d$ the bound is at least $2\varepsilon_d$ from $d=34$ on (§4).
- These values agree with the referee's.

**C3. Minor: the width threshold is an artefact of $a=1/n$. Accepted.**

- The accuracy $a$ is a free parameter of Theorem 5.1, with $N_0(a)=\lceil72dn\ln(2M)/a^2\rceil+1$.
- I adopted the referee's sharper residual bound $\mathcal R(tg)\le(1-t)^2G+nta$, which holds for $a\le4$ and was verified on 20000 instances. It gives $E_0=c(dF_d+1)+\vartheta_cna$. This is at most RT's $c(dF_d+1)+2$ when $\vartheta_cna\le2$, for example at $a=1/n$. At the adopted $a=1/d$ it is larger for $c\le\mathrm{poly}(d)$, the range of Corollary 5.2(a), since then $\vartheta_cn/d\gg2$; that is the price of the smaller width.
- With $a=1/d$ the width is $O(n\log^4n)$, and every asymptotic statement is unchanged. Corollary 5.2 needs only $a_d\to0$.

**C4. Optional: loose constants. Not adopted.**

- The improvements would replace $18d$ by $16d$, $G$ by $Q$ in the bracket, and $F_d$ by $\max\{1,(d+1)\alpha_d^2\}$. They change constants and the first $d$ at which the $c=1$ bound is positive, but no regime and no conclusion.
- Keeping RT's constants keeps the proof aligned with the computations the referees already checked.

**C5. Minor: Proposition 5.3 needs $Q>0$; its hypothesis can be weakened. Accepted.**

- $Q>0$ is now a hypothesis of part 1.
- Part 2 covers $c\le\nu\sqrt M$ with $\nu<\sqrt{\beta(\lambda)}/2$ (limit $0.104$ at $\nu=0.1$, $\lambda=1$, matching the referee's value).
- Part 2 states the rate $4\sqrt cM^{-1/4}+O(M^{-1/3})$; it is slow, e.g. $0.093$ at $M=2^{10}$, $c=1$, worst case on the event.

**C6. Minor: the "positive side at $L=2$" paragraph. Accepted.**

- Remark 5.7 replaces it. The upper bound is now cited from the refereed `B-tempered-likelihood.md` Proposition 6.1 and Lemma 5.3(a), with explicit constants, and is stated for clipped predictors only.
- Remark 5.7 notes that the unclipped bound needs $c\gg\sqrt n\log n$, and states the window in the corrected form "$\Omega((dc+1)^{-2})$ versus $O(d/\sqrt c)$".

**C7. Minor: §5.4 numerics compare two lower bounds obtained with different optimizer budgets. Accepted.**

- Nothing in §§3–5 uses these numerics.
- §6 withdraws the sentence "the captured fraction rises with $d$" and rewords the §0 item 6 numerics bullet so that it no longer suggests a trend.

---

## 9. Referee record: second round and the two re-refereeing rounds

The second-round reports are [`../verification/RT-depth2-logic-revised.md`](../verification/RT-depth2-logic-revised.md) (logic and definitions; issues 1–9 of its §3) and [`../verification/RT-depth2-computation-revised.md`](../verification/RT-depth2-computation-revised.md) (computation; issues 1–7 of its §7, and a remark on one script). Both found every proof correct. The logic referee found two major flaws in the formulations that the note claimed to refute, and an overstated open range; the computation referee found minor numerical and wording issues.

*Fixed* means that a wrong number or statement was corrected, or a missing statement, proof step, citation or explanation was added, without reducing what any proved statement asserts. *Weakened* means that a sentence that was false or overstated now carries the missing hypothesis or qualifier, or claims less. *Declined* marks an optional suggestion that is correct but was not adopted; the text was not changed for it. *Rebutted* means that the issue was judged invalid and the text left unchanged. *Fixed (lead editor)* marks a fix that the lead editor applied before the revision that answers the report. These terms are used in all three tables of this section, and no issue in this section was rebutted.

| Report | Issue | Resolution | Where |
|---|---|---|---|
| logic 1 (major) | (P$_2^{o(1)}$) asked for the bound at every learner width $N\ge1$, which makes it false for every learner under (R1) and (R3) (width-one example) and conflicts with `B-tempered-likelihood.md` Corollary 8.1 | **fixed**: the formulation asks for every $N\ge n^\alpha$; the example is Remark 5.2a; the failures hold at every $N\ge N_0$, hence at widths the formulation covers | §0 (summary, §0.1 item 2, §0.2, §0.4 item 1); §1.4; Corollary 5.2(b) and its proof; Remarks 5.2a, 5.5 |
| logic 2 (major) | "$+o(1)$" uniform over $d\le n$ is false for every learner, so Proposition 5.3 refutes nothing specific to close conditioning there; "unit-ball inputs: refuted only for $c<0.348$" is a false status | **weakened**: every claim that Proposition 5.3 refutes a formulation of the conjecture is withdrawn; it is described as "worse than the Bayes-optimal zero network by $\beta(\lambda)-o(1)$"; Remark 5.3a proves the impossibility | §0 (summary, §0.1 item 3, §0.2 row 3, §0.4 item 2); remarks after Prop. 5.3; Remarks 5.3a, 5.4, 5.8 item 4; §6 (RT §0 item 6, RT §6.1, the sentence after RT Prop. 5.3) |
| logic 3 | the open range is overstated: for clipped readings with $\log^2n\ll c\le n^{1-\epsilon}$, `B-tempered-likelihood.md` gives the "$+o(1)$" formulation | **fixed**, after checking B: B states it only for $c=n^{(2-8\alpha)/3}$, $0<\alpha<1/8$ (Corollary 8.1); for other $c$ it follows from B's Proposition 6.1 and Lemma 5.3(a), combined in Remark 5.7a; the open range is now $c\log n\to\infty$ with $c=O(\log^2n)$ (clipped) or $c=O(\sqrt n\log n)$ (unclipped), and contains $c=1$ | §0 (summary, §0.2 row 2, §0.4 item 3); Corollary 5.2(c); Remarks 5.7a, 5.8 item 1; §6 (RT §0 item 6, A3, §6.4) |
| logic 4 | erratum for RT §0 item 6: "fully when $c\lesssim1/\log n$" (the full $\beta(\lambda)$ needs $c=o(1/\log n)$); "precisely, when $c\log n\to\infty$" is not an equivalence | **fixed**: headline restated; "precisely" removed | §6, RT §0 item 6 |
| logic 5 | fixed-$d$ row: $O(2^d/n)$ needs bounded $c$ and fixed confidence | **fixed**: the row quotes the bound $(8\cdot2^d/\delta+4c)/n$ and says "$O(2^d/n)$ for bounded $c$" | §0.2, last row |
| logic 6 (optional) | Corollary 5.2(b) needs only infinitely many $n$, so its hypothesis could be $\liminf_d\,dc_d<\infty$ | **declined**: the observation is correct for subsequences of one family $n=\lceil\lambda2^d\rceil$. Adopting it would strengthen Corollary 5.2(b) beyond what is written out here: the dichotomy "refuted by Corollary 5.2 iff $\liminf c\log n<\infty$" over all $n$ needs the limit step of Corollary 5.2(ii) along a varying $\lambda\in[1,2)$. Lemma 1.3's bounds are explicit and depend on $\lambda$ only through $\lambda'=n/M$, so they are uniform there; the limit step is what is not written out. Remark 5.7a says that sequences fitting no row of its table are not classified | Corollary 5.2(b) unchanged; Remark 5.7a, note under the table |
| logic 7 | §8, response C3: "$E_0$ at least as good as RT's" holds only when $\vartheta_cna\le2$, not at the adopted $a=1/d$ | **fixed** | §8, C3 |
| logic 8 | (R1) needs joint measurability of $S\mapsto\Pi_{\sigma,S}$; the Gibbs-risk reading is not among (R1)–(R3) | **fixed**: measurability paragraph and reading (R1′) added; Corollary 5.2(a),(b) and Remark 5.6 cover (R1′) | §1.4; Corollary 5.2 and its proof; Remark 5.6 |
| logic 9 | the summary "refutes (P$_2$) but not the $+o(1)$ formulation" must not be cited | **fixed**: §0 states the regimes of Corollary 5.2 with issues 1 and 3 applied; the sentence appears only as a quotation of the withdrawn RT text | §0 (summary, §0.3 item 1) |
| computation 1 | table after Proposition 5.3, $c=0.1\sqrt M$, $M=2^{10}$: printed $0.016$, value $0.01549$ | **fixed**: $0.015$; `prop53_check.py` prints five decimals and was re-run | §5 table; `prop53_check.py`, `.out`; §7 |
| computation 2 | erratum numerics bullet rounds the lower bounds up ("at least 0.40/0.58" against $0.396/0.578$) | **fixed**: for networks at least as good as those found the bound is stated with $\phi\ge0.395$ and $\phi\ge0.577$ ($\phi\approx0.396$ and $0.578$; corrected again after the first re-refereeing round, point LC5 below), and every near-minimizer absorbs at least $0.389$ and $0.576$ of $G$; the §5.4 erratum notes the rounding in RT's table | §6 (RT §0 item 6, RT §5.4); §7.1 |
| computation 3 | proof of Proposition 5.3: "$Q^+\le2M$" needs $M$ large | **fixed**: uses $Q\le s\le M$; the proof gives the constant $2\sqrt3<4$, and the statement keeps $4$ | §5, proof of Proposition 5.3 |
| computation 4 | Lemma 1.2(a),(b) are stated "in the cube example" but applied to the Hadamard atoms | **fixed**: §1.3 and Lemma 1.2 are stated for any finite atom set | §1.3; Lemma 1.2; proof of Proposition 5.3 |
| computation 5 | fixed-$d$ row: $O(2^d/n)$ holds only for bounded $c$ | **fixed** (same change as logic 5) | §0.2, last row |
| computation 6 | Corollary 5.2(b): "tends to 0 at every $N\ge N_0(a_d)$" is an iterated limit | **fixed**: the $\limsup_{\sigma\downarrow0}$ of the probability is at most $\rho_n\to0$ | Corollary 5.2(b) and its proof |
| computation 7 (note) | the $c=1$ numbers use $a=1/n$; with $a=1/d$ the bound first reaches $2\varepsilon_d$ at $d=34$ | **fixed**: the numbers name their $a$ and width; `t1_range.py` covers $a=1/d$ | §4, "Numbers"; §8, C2; `t1_range.py`, `.out` |
| computation, script remark | `t1_range.py` promises a monotonicity check, and at 80 digits it lists 68 spurious decreases | **fixed**: the script runs at 200 digits and was re-run; no decrease remains | `t1_range.py`, `.out`; §7 |

### First re-refereeing round

The first re-refereeing round, [`../verification/depth-two-referee-scope-1.md`](../verification/depth-two-referee-scope-1.md) (scope and definitions) and [`../verification/depth-two-referee-logic-computation-1.md`](../verification/depth-two-referee-logic-computation-1.md) (logic and computation), read the text as revised after the second round; its referees are not the referees above. The scope referee checked whether the formulations claimed refuted are well defined, non-vacuous and consistent with `problem-brief.md` §1 and with B's Corollary 8.1; whether every status entry is exactly right; and every statement about what B proves at depth two, against B. The logic-and-computation referee checked the passages that changed against the text the second-round referees read: it re-derived their statements and numbers, and re-ran the four scripts that §7 says were changed or re-run, whose outputs were identical to the recorded ones. Both returned the verdict "minor fixes", and both found the three major issues of the second-round logic report fixed. The scope referee found every refutation the note claims correct, and one false statement about B (S1 below). The logic-and-computation referee reproduced every changed number, found one of them rounded the wrong way inside an upper bound (LC5), and found steps missing in Remark 5.3a (LC2).

The rows follow the two issue lists: S1–S6 for the scope report, and LC1–LC3 and the nits LC4–LC9 for the logic-and-computation report; the four parts of S6 have separate rows. Every point was judged valid. The optional suggestion S6(d) was declined, and no point was rebutted. None affects Theorem 5.1, Corollary 5.2 or Proposition 5.3.

| Point | Issue | Resolution | Where |
|---|---|---|---|
| S1 | Remark 5.7a said "B does not treat the negative side at depth two". B's Proposition 9.1 holds for every $L\ge2$ and $c>0$; at $L=2$ it makes (P$_2$) and (P$_2^{o(1)}[\phi]$) fail for every $c\ge n^{1-o(1)}$, and (P$_2$) fail on one fixed law for $c\ge n/4$. The note left this range unclassified, while §0 and the erratum for RT §0 item 6 treated it as settled without a source | **fixed**, and the sentence about B weakened: Remark 5.7a lists Proposition 9.1(a),(b) and B's §9 Discussion among B's depth-two statements, restricts "B does not treat the negative side" to the noisy cube, derives both failures in a paragraph on large $c$ and adds a table row; §0, §0.2 and the erratum cite it | §0 (bullets 1–3, "Not covered"); §0.2 rows 1, 2 and 4 and the sentence after the table; §0.4 item 3; Remark 5.7a; §6 (RT §0 item 6); `prop91_l2.py` |
| S2 | Remark 5.3a proves "every reading" only for readings whose output is one function; under (R1′) the loss is an average over draws | **fixed**: the Gibbs-risk step ($q_j$ and Hoeffding's inequality) is written out | Remark 5.3a, "Gibbs risk" |
| S3 | Remark 5.7a, Corollary 8.1 bullet: $\Xi_n$ depends on $\delta$, but $\epsilon_n$ must be chosen before $\delta$; B states Corollary 8.1 for the $\limsup_{\sigma\downarrow0}$, and (R1) needs B at confidence $\delta/2$ with posterior bad mass $\delta/2$ | **fixed**: $\epsilon_n$ and $n_\delta$ are chosen so that $\epsilon_n$ does not depend on $\delta$; a paragraph "Passage to the readings" applies B at confidence $\delta/2$, with $\eta=\delta/2$ under (R1) and $4\eta$ absorbed in $\epsilon_n$ under (R1′) and (R2); the paragraph on the class $\mathcal G^{(\alpha)}_n$, including its unclipped variant, makes the same choice | Remark 5.7a |
| S4 | the unit-ball parenthesis of §0.2 row 3 and of the erratum for RT §6.1 attaches to "$\beta(\lambda)-o(1)$", while Remark 5.4 proves $\beta(\lambda)(1-\sqrt{2c/\sqrt{\beta(\lambda)}})_+^2-o(1)$; "for all laws with $d\le n$" misses Proposition 5.3 when $\lambda<1$ | **weakened**: both places state the constant gap for $c<\sqrt{\beta(\lambda)}/2$, the full $\beta(\lambda)-o(1)$ only when $c\to0$, and nothing at $c=1$; the property is stated over $d\le n/\lambda$ | §0.2 row 3; §5, "What it shows"; §6 (RT §6.1) |
| S5 | (P$_2$) and (P$_2^{o(1)}$) are properties of one learner, the conjecture lets us pick the learner, and at depth two it is not refuted; Remark 5.5 could be read as refuting the brief's formalisation itself | **weakened**: §0 and §1.4 say so, citing B's Theorem 6.3 and Corollary 8.1 at $c=n^{1/2}$; Remark 5.5 now says "refute, for SP$_c$ with the stated $c$", and §0.1 item 2 and the erratum for RT §0 item 6 say "SP$_c$ fails" | §0, first paragraph; §0.1 item 2; §1.4, "One learner"; Remark 5.5; §6 (RT §0 item 6) |
| S6(a) | B's open items "Depth two with $c=O(\mathrm{polylog}\,n)$" (its §0) and "(iii) The negative side at depth two for $c=\mathrm{polylog}(n)$" (its §11) are out of date | **fixed**: §0 records that this note supersedes item (iii) and narrows the §0 item, and that B's §7.5 item 3 cites what is now Theorem 5.1 of this note. B itself is not changed here | §0, "Relation to the open items of B" |
| S6(b) | once RT §5 is a pointer, the runs of RT §5.4 are in neither document, although the erratum for RT §0 item 6 quotes them and RT Appendix A refers to "the §5 table" | **fixed**: §7.1 records the table and the tempering sweep of RT §5.4 from the run files, with certified values from a new script; an erratum for RT Appendix A points there | §7.1; §6 (RT §5.4, RT Appendix A); `rt54_record.py` |
| S6(c) | logic 6 was declined, not rebutted; the §8 preamble said a C3 sentence is "corrected there", but the correction is in §8 | **fixed**: logic 6 relabelled "declined"; preamble rewritten (as LC3) | §9, row logic 6; §8, preamble |
| S6(d) (optional) | B's Remark 6.5 with $w'=0$ gives vanishing clipped excess on the cube for $\log^2n\ll c=o(n)$, a wider window than the $\log^2n\ll c\ll n/\log^2n$ of Remark 5.7 | **declined**: the stated window is correct, and widening it would strengthen a cited claim beyond what the refereed text states; no status entry depends on its upper end | none |
| LC1 | the unit-ball clause of §0.2 row 3 and of the RT §6.1 erratum overstates what Remark 5.4 proves | **weakened** (as S4), with the suggested wording | §0.2 row 3; §6 (RT §6.1) |
| LC2 | Remark 5.3a chooses $\theta_n$ for a fixed output, which for SP$_c$ depends on $\sigma$ and $N$; the Gibbs-risk reading is not covered; $\lceil n/b\rceil$ should be $\lfloor n/b\rfloor$ | **fixed**: a step "One law" uses the minimum of $\sigma_0(\theta)$ over the $2^n$ sign vectors; (R1′) as in S2; $\lfloor n/b\rfloor$ | Remark 5.3a |
| LC3 | the §8 preamble said that §8 is the response "as it was made", although four of its bullets were updated in place | **fixed**: the preamble names the four bullets (L2, L3, C2, C3); five since the second re-refereeing round, with L5 | §8, preamble |
| LC4 (nit) | in the proof of Corollary 5.2(b) the (R1′) step needs $\epsilon_n>0$, which "numbers $\epsilon_n\to0$" does not ensure | **fixed**: without loss of generality $\epsilon_n>0$, since the property only weakens when $\epsilon_n$ grows | proof of Corollary 5.2(b), "Failure" |
| LC5 (nit) | the numerics bullet of the erratum for RT §0 item 6 states the upper bound $(1-\phi)G$ with $\phi$ rounded up: $0.396$ and $0.578$, while the run files give $1-93.51/154.8=0.3959$ and $1-267.75/634.1=0.5777$ | **fixed**: the bound is stated with $\phi\ge0.395$ and $\phi\ge0.577$; §7.1 gives $0.3958$ and $0.5777$, computed from the exact $G$ and allowing for the rounding of the recorded objective | §6 (RT §0 item 6, RT §5.4); §7.1 |
| LC6 (nit) | the relay of B's §7.5 item 3 ("vanishing excess as soon as $c\gg D_n^2$") omits $c=o(n)$ | **weakened**: "and $c=o(n)$" added, with the reason | Remark 5.7a, third bullet |
| LC7 (nit) | the reason given for declining logic 6 overstates the gap: Lemma 1.3's bounds are uniform for $\lambda$ in compact sets | **fixed**: the reason now names the limit step along a varying $\lambda$ | §9, row logic 6 |
| LC8 (nit) | RT Appendix A says that the captured fractions bound what every near-minimizer captures; for near-minimizers the bound is $\phi-c/G$ | **fixed**: erratum for RT Appendix A added | §6 (RT Appendix A) |
| LC9 (nit) | Remark 5.5 can be read as saying that the range of Corollary 5.2(a) refutes (P$_2^{o(1)}$) | **fixed**: "(P$_2$) in the range of Corollary 5.2(a), and also (P$_2^{o(1)}$), with its widths $N\ge n^\alpha$, in the range of Corollary 5.2(b)" | Remark 5.5 |

Besides these changes, the header mentions this round, §0.5 lists its changes, and §7 records the two new scripts.

### Second re-refereeing round

The second re-refereeing round, [`../verification/depth-two-referee-scope-2.md`](../verification/depth-two-referee-scope-2.md) (scope and definitions) and [`../verification/depth-two-referee-logic-computation-2.md`](../verification/depth-two-referee-logic-computation-2.md) (logic and computation), read the text as revised after the first re-refereeing round, with particular care for the material added in answer to it: the paragraph of Remark 5.7a on B's Proposition 9.1, and §7.1. Both returned the verdict "minor fixes". Both found the three major issues of the second-round logic report still fixed and the new material correct. The scope referee found every statement about what B proves at depth two correct, and three status statements not exact (its issues 1–3). The logic-and-computation referee re-derived every changed statement and number, re-ran the two new scripts and three of the runs of §7.1, and found one displayed bound worded too broadly (its issue 1), ten nits and one optional suggestion.

The rows follow the two reports: issues 1–3 and nits 4–9 of the scope report, and issue 1, nits 2–11 and the optional point 12 of the logic-and-computation report. Every point was judged valid, and no point was rebutted. Two observations of the scope referee extend refereed statements; they are recorded in the text and marked as not refereed (Remark 5.2b, and the large-$c$ paragraph of Remark 5.7a). Two new derivations are also marked as not refereed (§0.6 item 4). No change alters Theorem 5.1, Corollary 5.2 or Proposition 5.3.

| Report | Point | Resolution | Where |
|---|---|---|---|
| scope | issue 1: "learned consistently" and "not refuted by the cube family" at a fixed $d$ need $c=o(n)$; for $c$ of order $n$ near-minimizers fail on the cube itself at $d=1$; the fixed-$d$ row understates B's two-point failure; A's bound grows like $1/\delta$ | **weakened**: the qualifier $c=o(n)$ is added. The fixed-$d$ row and "Input dimension" state what happens for $c$ of order $n$, citing the paragraph after A's Proposition 8.3 ($c\ge C_1n$, $C_1\approx5.83$) and the referee's script, and record the referee's note that (R1), (R1′) and (R2) are not affected. The row gives B's two-point failure for every $c\ge n^{1-o(1)}$, and says that for (P$_2$) "not refuted" means only that no refutation is known | §0, "Not covered"; §0.2, last row and "Input dimension"; §8, L5 and preamble |
| scope | issue 2: §1.4 says that the conjecture is not refuted "in either formulation" without naming $\phi$; for $\phi(n)\ge n/b$ no learner has (P$_2^{o(1)}[\phi]$) | **weakened**: §1.4 names $\phi(n)=\log_2n+C_0$ and adds the case $\phi(n)\ge n/b$ (Remark 5.3a) | §1.4, "One learner" |
| scope | issue 3: "Other $c$ are not settled here" understates what the note settles for (P$_2$): (5.7a) gives it in the clipped readings for $n^a\le c\le n^{1-a}$, and the proof of Corollary 5.2(a) works for every $c\le n^{o(1)}$ | **fixed**, by the minimal change: the sentence is replaced by what (5.7a) gives (the clipped readings for $n^a\le c(n)\le n^{1-a}$, the unclipped ones for $n^{1/2+a}\le c(n)\le n^{1-a}$) and by what is not classified, and Remark 5.7a derives the range. The extension to $c\le n^{o(1)}$ would strengthen Corollary 5.2(a), so it is the separate Remark 5.2b, marked "not refereed; observed by the scope referee of the second re-refereeing round", with its two-line proof | §0, bullet 1; §0.2, row 1; Remark 5.2b; Remark 5.7a, "General $c$, the polynomial-sample property" |
| scope | nit 4 (optional): "the transition" at depth two has two meanings; the erratum for RT §7 item 3 should add that for the polynomial-sample version every $c\le\mathrm{polylog}(n)$ fails and $c=n^{1-\theta}$ works | **fixed (lead editor)** in the erratum for RT §7 item 3. The paragraph on B's open items now notes the same about B's §7.5 item 3 | §6 (RT §7 item 3); §0, "Relation to the open items of B" |
| scope | nit 5: Remark 5.4 says that the proof gives nothing "for $c$ of order one", which is false for constants below $\sqrt{\beta(\lambda)}/2$ | **weakened**: "for $c\ge\sqrt{\beta(\lambda)}/2$, in particular $c=1$" | Remark 5.4, "What is not settled" |
| scope | nit 6: the near-minimizer clause of the erratum for RT §0 item 6 needs "at the run's width", and in the erratum for RT Appendix A that qualifier belongs to the near-minimizer clause | **fixed (lead editor)**: both errata attach "at the run's width" to the near-minimizer clause | §6 (RT §0 item 6, RT Appendix A) |
| scope | nit 7: "$n/c=n^{o(1)}$", read two-sidedly, excludes $c\gg n$, which the argument covers | **fixed** (as logic-and-computation nit 3) | Remark 5.7a, large $c$ and the status table |
| scope | nit 8 (optional): the fixed-law failure holds for every $c\ge n/k$ with $k$ fixed, not only for $k=4$ | **fixed**: recorded in Remark 5.7a as the referee's observation, with its construction and script, and marked as not refereed; the refereed statement keeps $c\ge n/4$ | Remark 5.7a, large $c$ |
| scope | nit 9: the header sentence that the new material "has not been reviewed" is out of date, and §9 cites the reports of the first re-refereeing round without paths | **fixed**: the header, §0.5, §0.6 and §9 cite the four re-refereeing reports by path | header; §0.5; §0.6; §9 |
| logic and computation | issue 1: (5.7a) and the Theorem 6.3 bullet state B's bounds "for the clipped readings" at confidence $1-\delta$; B proves them for near-minimizers and the $\sigma\downarrow0$ limits, and the readings at $\sigma<\sigma_0$ need $\ln(4/\delta)$ and $4\eta$ | **weakened**: both name what is bounded at confidence $1-\delta$ (the clipped output of every near-minimizer, and the $\limsup_{\sigma\downarrow0}$ of the clipped Gibbs risk and of $L_D(\bar f_\sigma)$), and add that the clipped readings at $\sigma<\sigma_0$ satisfy the bound with $\ln(4/\delta)$ in place of $\ln(2/\delta)$, plus $4\eta$ under (R1′) and (R2) | Remark 5.7a, Theorem 6.3 bullet and (5.7a) |
| logic and computation | nit 2: in the erratum for RT §0 item 6, "every near-minimizer leaves at most $(1-\phi)G+c$" needs "at the run's width" | **fixed (lead editor)** (as scope nit 6). The report adds that the bound extends to larger widths by zero padding; that argument does not apply here, since zero padding changes $\kappa_N$, which depends on $N$. The bound extends to integer multiples of the run's width, where clones have the same energy (scope nit 6), and the text claims only the run's width | §6 (RT §0 item 6) |
| logic and computation | nit 3: write "$n/c\le n^{o(1)}$" in the first large-$c$ consequence and in the last row of the status table | **fixed** | Remark 5.7a, large $c$ and the status table |
| logic and computation | nit 4: Remark 5.4 should state the width of the cited optimisation | **fixed**: "at learner width $N=8$ with $M=d\in\{64,256\}$", and local optimisation at width $8$ cannot rule out cheaper memorizers at larger widths | Remark 5.4, "What is not settled" |
| logic and computation | nit 5: the small-width parenthetical of §0 needs the range of $c$ | **weakened**: "when $n^{-O(1)}\le c\le\mathrm{poly}(d)$", as in Remark 5.5; the same clause is added in §8, L2 | §0, "Not covered"; §8, L2 |
| logic and computation | nit 6: "supersedes item (iii)" is broad: the negative side of the "$+o(1)$" formulation at polylogarithmic $c$ with $c\log n\to\infty$ is open | **weakened**: "supersedes item (iii) for (P$_2$), and for the '$+o(1)$' formulation when $c\le\nu/\log_2n$"; the open part is named | §0, "Relation to the open items of B" |
| logic and computation | nit 7: in the §9 row for logic issue 6, "refuted iff" is false after the large-$c$ paragraph | **weakened**: "refuted by Corollary 5.2 iff" | §9, row logic 6 |
| logic and computation | nit 8: §0.5 item 3 says that Remark 5.3a passes to one law "at every $\sigma$" | **weakened**: "at arbitrarily small $\sigma$" | §0.5, item 3 |
| logic and computation | nit 9: in §8 (C3), "at the adopted $a=1/d$ it is larger" needs $c\le\mathrm{poly}(d)$ | **weakened**: "for $c\le\mathrm{poly}(d)$, the range of Corollary 5.2(a)" | §8, C3 |
| logic and computation | nit 10: the §7 row for `prop91_l2.py` says that the script checks the lower bound $(1-\eta_0)^2$, which it only prints, and its entry points use the competitor's actual weights, not the bound $1.5\max\{\sqrt2,\sqrt K\}$ | **weakened**: the row lists what the script asserts and what it prints, and says "with its actual weights"; Remark 5.7a names the actual largest weight, about $\sqrt K$ | §7, row `prop91_l2.py`; Remark 5.7a, large $c$ |
| logic and computation | nit 11: the header is out of date once this report is recorded; the §6 item on the RT §5 "Open" paragraph is phrased as an edit to a section that is now a pointer | **fixed**: header updated and this table added; the item is phrased as a record | header; §9; §6, "Corrections to §5 itself" |
| logic and computation | optional 12: "Other $c$ are not settled here" understates what (5.7a) gives for (P$_2$) | **fixed** (as scope issue 3) | §0.2, row 1; Remark 5.7a |

**Check of the final revision.** An independent check of the text as revised in answer to the second re-refereeing round ([`../verification/depth-two-revision-check.md`](../verification/depth-two-revision-check.md)) found every point of both reports resolved as the table above says and no mathematical error in a changed passage. It raised four minor record and labelling points and three optional ones. The lead editor resolved the four: the §6 introduction now says that the errata cite statements of `B-tempered-likelihood.md` that Remark 5.7a restates; the paragraph "General $c$, the polynomial-sample property", the (P$_2$) range it gives in §0.2 and the new argument in §0.2, "Input dimension", are marked as not refereed, and §0.6 item 4 and the introduction to the table above list them; row LC3 records the fifth bullet of the §8 preamble; and the header says "re-refereed twice during finalization". The optional points (an open item in Remark 5.8 for the unclassified (P$_2$) ranges, a clause on what the ratio in Remark 5.2b illustrates, and the one-line check of the $c\ge n/k$ extension) were not adopted; the first is covered by the "Not classified" list in §0.2.
