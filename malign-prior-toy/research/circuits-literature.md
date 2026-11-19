# Circuits in place of programs: what the literature says

Research file for the note in `malign-prior-toy/paper/`, for the planned section that replaces programs by
Boolean circuits (as hypotheses of the predictor and as worlds). Compiled 13 November 2026 by an AI
literature search. Not reviewed by a human.

## How to read the tags

* **VERIFIED**: the source was opened in this session and the statement was read there. The URL is
  given, and the statement is quoted or closely paraphrased.
* **VERIFIED (restated in X)**: the sentence was read in the opened paper X, which attributes the result
  to an earlier paper. The earlier paper was **not** opened. A paper may cite the result "as stated in
  X", or must check the original.
* **FROM MEMORY**: not opened. "(+search)" means that a search-engine summary of the publisher's or
  forum's page agreed with the recollection. That is corroboration and not verification.
* **DERIVED**: a short argument made here from verified statements. It is not a citation and nobody
  else has checked it.

Venue, volume and page data that are not printed on the opened page are from memory unless they were read
in the reference list of an opened paper.

## Access log

| host | result |
|---|---|
| `arxiv.org` | reachable. PDFs were downloaded and read as text. arXiv's own search (title and abstract only) was used. |
| `eccc.weizmann.ac.il` | reachable through the fetch tool. Two reports read (TR05-032, TR02-028). |
| `proceedings.mlr.press` | reachable. Two landing pages read (bibliographic data only). |
| `openreview.net` | returned a browser-verification page. Nothing was read there. |
| `www.lesswrong.com`, `www.alignmentforum.org`, `eprint.iacr.org` | name resolution failed (outside the allowed network domains). |

Consequences: every forum post (Christiano 2016 and 2018, Hubinger 2019 and 2022, Xu 2020, Kosoy, Wyeth
2025) and every IACR paper on universal circuits (2008 to 2021) is FROM MEMORY. Valiant 1976, Shannon
1949 and Lupanov 1958 could not be opened at a reachable host and are given as restated in opened
papers.

---

## 1. Universal circuits

**1.1 Valiant 1976.** L. G. Valiant, "Universal circuits (preliminary report)", STOC 1976.

* *Statement, VERIFIED (restated in Bera, Fenner, Green, Homer, "Universal quantum circuits",
  https://arxiv.org/abs/0804.2429, Section 1.1 and Theorem 8).* Valiant "considered classical circuits
  built from fanin 2 gates (but with unbounded fanout)" and "showed how to construct a O(c log c)-size
  and O(c)-depth universal circuit. He also showed that his constructions have size within a constant
  multiplicative factor of the information theoretic lower bound." Their Theorem 8, attributed to
  Valiant: "There is a constant k such that for all n there exists an acyclic graph G' that is
  edge-universal for Γ2(n), and G' has kn lg n vertices, each vertex having fanin and fanout 2", where
  Γ2(n) is their name for the directed acyclic graphs on vertices $1,\dots,n$ with no edge from $j$ to
  $i$ for $i<j$ and fan-in and fan-out 2.
* *Constants, FROM MEMORY (+search).* Valiant gave two edge-universal graphs, a 2-way one of about
  $5\,n\log_2 n$ nodes and a 4-way one of about $4.75\,n\log_2 n$ nodes. Here $n$ is the number of poles,
  $n=u+v+k^*$ for $u$ inputs, $v$ outputs and $k^*$ gates after fan-out has been reduced to 2
  ($k\le k^*\le 2k+v$). Counted in gates of the universal circuit, the figure usually quoted for Valiant
  is about $19\,k\log_2 k$.
* *Bearing.* A circuit that reads the description of a circuit of size $\sigma$ and runs it costs
  $\Theta(\sigma\log\sigma)$ gates; there is no interpreter of constant size, which is the formal
  reason the wrapper and search constructions of the program toy have no cheap circuit counterpart.

**1.2 Later constructions and constants. All FROM MEMORY (+search); none opened.**

| work | what I recall |
|---|---|
| Kolesnikov, Schneider, "A practical universal circuit construction and secure evaluation of private functions", Financial Cryptography 2008 | size about $1.5\,k\log_2^2k+2.5\,k\log_2k$; not asymptotically optimal, smaller than Valiant's for circuits of a few thousand gates; quotes Valiant as about $19\,k\log k$. |
| Kiss, Schneider, "Valiant's universal circuit is practical", Eurocrypt 2016 | first implementation of Valiant's 2-way construction, about $5\,n\log_2n$. |
| Lipmaa, Mohassel, Sadeghian, "Valiant's universal circuit: improvements, implementation, and applications", ePrint 2016/017 | generalisation to $k$-way recursion; 4-way about $4.75\,n\log_2n$. |
| Günther, Kiss, Schneider, "More efficient universal circuit constructions", Asiacrypt 2017 | modular 4-way implementation, about $4.75\,n\log_2n$; hybrid of 2-way and 4-way. |
| Zhao, Yu, Zhang, Liu, "Valiant's universal circuits revisited: an overall improvement and a lower bound", Asiacrypt 2019 (ePrint 2018/943) | about $4.5\,n\log_2n$; lower bound about $3.64\,n\log_2n$ for universal circuits built in Valiant's framework. |
| Liu, Yu, Zhao, Zhang, Liu, Hu, "Pushing the limits of Valiant's universal circuits: simpler, tighter and more compact", Crypto 2021 (ePrint 2020/161) | about $3\,n\log_2n$, below the Zhao et al. bound because the framework is relaxed; a lower bound of about $2.95\,n\log_2n$ in the relaxed framework. |
| Alhassan, Günther, Kiss, Schneider, "Efficient and scalable universal circuits", J. Cryptology 2020 | journal version of the 2-way/4-way line. |

The two search summaries disagreed on whether the $2.95$ figure appears in Liu et al.; one reported it,
one did not find it. **Check ePrint 2020/161 before printing any of the constants $3$, $2.95$, $3.64$,
$4.5$.** *Bearing:* these fix the constant $c$ in "a universal circuit has $c\,\sigma\log_2\sigma$ gates"
between about 3 and 19 depending on the construction and on what is counted; the draft's CA17(c) says
the same and should keep its "from memory" label.

**1.3 Depth-universal circuits.** *VERIFIED (restated in arXiv:0804.2429, Section 1.1).* Cook and Hoover
(SIAM J. Comput. 1985) "constructed a depth-universal circuit for depth Ω(log n) and polynomial size,
but which takes as input a nonstandard encoding of the circuit". *Bearing:* universality can be had at
constant-factor cost in depth instead of size, but then size is polynomial and not quasi-linear, so it
does not lower the description cost in a size prior.

**1.4 The matching lower bound. DERIVED from 2.3 and 2.5 below.** Let $U(p,x)$ be a fan-in-2 circuit
with program inputs $p\in\{0,1\}^P$ such that every function of $n$ inputs computed by a circuit with at
most $s$ gates is $U(p,\cdot)$ for some $p$. Distinct functions need distinct programs, so $P$ is at least
$\log_2$ of the number of such functions, which is at least $(1-o(1))\,s\log_2s$ when
$n\ge\log_2(s\log_2s)+1$ (2.5(d)). A fan-in-2 circuit that depends on $q$ inputs has at least $q-1$
gates. Hence $U$ has at least $(1-o(1))\,s\log_2s$ gates. The published statement of the
$\Omega(k\log k)$ bound is in Valiant's paper (see 1.1, restated) and, FROM MEMORY, in Wegener, *The
Complexity of Boolean Functions* (1987). *Bearing:* the gap between the best construction and the
counting bound is a constant factor (about 3, in units that are not quite the same), so the $\log$ factor
in the cost of universality is not an artefact.

---

## 2. Counting circuits and functions

**2.1 Shannon 1949.** C. E. Shannon, "The synthesis of two-terminal switching circuits", Bell System
Tech. J. 28 (1949) 59-98.

* *VERIFIED (restated in Frandsen, Miltersen, "Reviewing bounds on the circuit size of the hardest
  functions", ECCC TR05-032, https://eccc.weizmann.ac.il/report/2005/032/, Introduction).* With $L(n)$
  the circuit size of the hardest function of $n$ inputs: "Shannon proved that for every ε > 0 and n
  sufficiently large" $(1-\varepsilon)\,2^n/n<L(n)<2^{n+2}/n$.
* *"Almost all functions".* VERIFIED (restated in Daxner, Genitrini, Gittenberger, Mailler,
  https://arxiv.org/abs/1407.0501, Introduction): Riordan and Shannon "discovered the so-called Shannon
  effect: the uniformly random n variables Boolean function has asymptotically almost surely exponential
  complexity when n goes to infinity." The quantitative form follows from the count in 2.5(b): at most
  $2^{(s+1)(7+\log_2(n+s))+1}$ of the $2^{2^n}$ functions have circuits with at most $s$ gates.
* *Caveat, FROM MEMORY.* Shannon's 1949 paper is about contact (switching) networks; the statement for
  circuits of gates is usually credited to Shannon together with Muller (1956) and Lupanov.
* *Bearing.* An arbitrary sequence of length $2^k$ needs about $2^k/k$ gates, so "the world is too
  expensive for the predictor" is the generic regime; the draft's line citing Shannon is supported.

**2.2 Lupanov 1958.** *VERIFIED (restated in ECCC TR05-032, Introduction).* "Lupanov showed a better
upper bound": $L(n)\le\frac{2^n}{n}\bigl(1+O(1/\sqrt n)\bigr)$, so that with Shannon's lower bound
$L(n)=2^n/n\pm o(2^n/n)$. Frandsen and Miltersen cite O. B. Lupanov, "The synthesis of contact circuits",
Dokl. Akad. Nauk SSSR 119 (1958) 23-26; the paper usually cited for gate circuits is, FROM MEMORY,
Lupanov's "A method of circuit synthesis", Izv. VUZ Radiofizika 1 (1958) 120-140. *Bearing:* a literal
table of $M=2^j$ bits costs $(1+o(1))M/\log_2M$ gates and not $M$, which lowers the price of a literal
block by the factor $\log_2M$ and no further.

**2.3 The sharpest bounds found. VERIFIED** (ECCC TR05-032, abstract, Theorems 1 and 2).
$$\frac{2^n}{n}\Bigl(1+\frac{\log n}{n}-O\bigl(\tfrac1n\bigr)\Bigr)\ \le\ L(n)\ \le\
\frac{2^n}{n}\Bigl(1+3\,\frac{\log n}{n}+O\bigl(\tfrac1n\bigr)\Bigr).$$
The lower bound is proved for "the full binary basis" (all 16 gate types), the upper bound for the basis
$\{\neg,\wedge,\vee\}$. *Bearing:* these are the statements to cite when the note needs explicit second-
order terms; the lower bound holds for exactly the basis of the draft.

**2.4 Lutz 1992.** *VERIFIED (restated in ECCC TR05-032).* "for every real α < 1 and almost every n",
$\frac{2^n}{n}(1+\alpha\frac{\log n}{n})<L(n)$ (J. H. Lutz, "Almost everywhere high nonuniform
complexity", JCSS 44 (1992)). *Bearing:* none beyond 2.3.

**2.5 The number of circuits with $s$ gates.**

* (a) *Ordered gate lists with two pointers each. Arithmetic.* In the draft's model (gate $i$ has a
  truth table in $\{0,1\}^4$ and two pointers into the $k+i-1$ earlier wires) the count is
  $\prod_{i=1}^s16(k+i-1)^2$, so
  $$\Lambda(k,s)=4s+2\log_2\frac{(k+s-1)!}{(k-1)!}=2\,s\log_2s+(4-2\log_2e)\,s+O(k\log s)\qquad(k\text{ fixed}),$$
  with $4-2\log_2e\approx1.11$. Leading constant: **2**.
* (b) *A code with one pointer per gate. VERIFIED* (ECCC TR05-032, Section 2). A circuit with $s$ gates
  over the full binary basis is turned into a stack program with $s$ Boolean operations and exactly
  $s+1$ push operations; "The argument of a push operation can be represented by ⌈log(n + s)⌉ bits. A
  single bit is needed to distinguish push operations from Boolean operations, and 4 bits suffice to
  distinguish the Boolean operations. In total the stack program can be described using at most
  (s+1)(c+log(n+s)) bits, for c = 7." So the functions of $n$ inputs computed with exactly $s$ gates
  number at most $2^{(s+1)(7+\log_2(n+s))}$. Leading constant for functions: **1**.
* (c) *Circuits up to isomorphism. FROM MEMORY* (the standard textbook count, for instance in Wegener
  1987 and Jukna 2012; no theorem number is given because none was checked). If gates may be named in any
  order, a circuit in which no two gates compute the same function has $s!$ different namings, so the
  number of functions is at most $s\cdot16^s(n+s)^{2s}/s!=2^{\,s\log_2s+O(s)}$ for $n\le s$. This agrees
  with (b) in the leading term.
* (d) *Lower bound. DERIVED from Theorem 2 of TR05-032.* Let $N$ be large, $m=\lfloor\log_2N\rfloor$,
  $t=\lceil\log_2m\rceil$, and let $N'$ be $N$ with all but its top $t+1$ binary digits set to zero, so
  $N'>N(1-1/m)$ and $N'=\sum_{i\in I}2^{m_i}$ with $|I|\le t+1$ and $m_i\ge m-t$. Choose disjoint
  subcubes $Q_i$ of $\{0,1\}^{m+1}$ of dimensions $m_i$ (possible by Kraft's inequality). The $2^{N'}$
  functions that are arbitrary on the $Q_i$ and $0$ elsewhere have circuits of size at most
  $\sum_iL(m_i)+O(t^2)=(1+o(1))N/\log_2N$. Hence, for $n\ge\log_2(s\log_2s)+1$, circuits with at most
  $s$ gates compute at least $2^{(1-o(1))\,s\log_2s}$ functions.
* *Conclusion.* For $\log_2(s\log_2s)+1\le n\le s$ the number of functions computed with at most $s$
  gates is $2^{(1+o(1))\,s\log_2s}$, while the number of ordered gate lists is $2^{(2+o(1))\,s\log_2s}$.
* *Bearing.* The gate-list description length of the draft is twice the information content of a
  size-$s$ circuit in the leading term; the missing half is the order of the gates. A function of size
  at most $s$ has on average $2^{(1+o(1))s\log_2s}$ gate lists of size $s$, so "description length of
  one circuit" and "minus log of the prior mass of its function" differ by a factor of up to 2 in the
  exponent, and statements of the form $2^{-\Lambda}$ are lower bounds on mass and not estimates.

**2.6 Circuit size against time-bounded Kolmogorov complexity. VERIFIED** (Allender, Buhrman, Koucký,
van Melkebeek, Ronneburger, "Power from random strings", ECCC TR02-028,
https://eccc.weizmann.ac.il/report/2002/028/, Definition 2 and the text before Theorem 5).
"Define KT(x) = min{|d| + t : for all i ≤ |x|, U(d, i) = x_i, and U(d, |x| + 1) = ∗, in at most t
steps}." For a string $x$ of length $2^n$ read as a truth table: "As observed in [All01], SIZE(x) =
O(KT(x) log KT(x)) and KT(x) = O(SIZE²(x) + log |x|)." They contrast KT with Levin's Kt: "The significant
difference between the KT and Kt measures lies in the exponential difference in the weight that is given
to the time bound in the two measures". *Bearing:* circuit size is polynomially related to "description
length plus running time per bit", so a circuit-size prior weights a hypothesis by an exponential in
(a polynomial of) $|d|+t$, whereas the speed prior (4.1, 4.2) weights it by $2^{-(|d|+\log t)}$; the
circuit toy is therefore far harsher on computation than a speed prior, which is why searching
hypotheses lose their mass in it and only lose a factor of their running time under a speed prior.

**2.7 How much of a uniformly random gate list is alive.**

* *VERIFIED (restated in Burghart, "Ancestries in random d-DAGs", https://arxiv.org/abs/2606.30475,
  Theorem 1, attributed to Janson, "The number of descendants in a random directed acyclic graph",
  Random Structures and Algorithms 64(3):768-803, 2023, Theorem 1.4).* In the random recursive DAG in
  which every vertex $j\ge2$ sends $d$ arrows to independent uniform vertices in $[j-1]$, let $D_n$ be
  the set of vertices reachable from $n$. "Let d ≥ 2. Then, as n → ∞, both in distribution and for all
  moments,"
  $$n^{-\frac{d-1}{d}}\,|D_n|\ \to\ \frac{(d-1)^{1/d}\,\pi}{d\,\sin(\pi/d)}\ \gamma^{1/d},$$
  with $\gamma$ gamma-distributed with parameters $d/(d-1)$ and $1$. (The formula is transcribed from
  extracted PDF text; check the placement of exponents against the paper before printing it.)
* *For $d=2$:* $|D_n|/\sqrt n\to\frac{\pi}{2}\sqrt\gamma$ with $\gamma\sim\mathrm{Gamma}(2,1)$, mean
  $\frac\pi2\,\Gamma(5/2)\approx2.09$. A simulation made here (400 samples at $n=10^4$ and $10^5$, 100
  at $n=10^6$) gave $2.09$, $2.07$, $2.01$.
* *Correspondence. DERIVED.* The draft's uniform gate list on $k$ inputs and $s$ gates is this DAG on
  $n=k+s$ vertices with the arrows of the first $k$ vertices removed; the cone of the output gate is
  $D_n\cap(k,n]$ and has the law of that set in Janson's model.
* *Related, VERIFIED* (Devroye, Janson, "Long and short paths in uniform random recursive dags",
  https://arxiv.org/abs/0906.0152, abstract): for the same model with $k$ parents, the shortest-path
  distance $S_n$ from node $n$ to the root satisfies "$S_n/\log n\to\sigma$ in probability" for an
  explicit constant. FROM MEMORY: the longest path, which is the circuit depth, is also of order
  $\log n$ (Tsukiji and Xhafa 1996; Arya, Golin, Mehlhorn 1999).
* *Bearing.* Under the fixed-size prior a member of $\mathcal C_{k,s}$ has on average at most about
  $2.1\sqrt{k+s}$ gates in the cone of its output (and, from memory, depth of order $\log s$); nearly
  all of its description is dead code, so the fixed-size prior at size $s$ behaves like a prior on live
  circuits of size of order $\sqrt s$ and should not be read as "a typical hypothesis does $s$
  operations".

---

## 3. Minimal circuits and inner optimisers

**3.1 Hubinger, van Merwijk, Mikulik, Skalse, Garrabrant, "Risks from learned optimization in advanced
machine learning systems". VERIFIED** (https://arxiv.org/abs/1906.01820, PDF read).

* Description length favours an inner optimiser (Section 2.1, "Compression of complex policies"): "a
  mesa-optimizer is a highly-compressed version of whatever policy it ends up implementing: instead of
  explicitly encoding the details of that policy in the learned algorithm, the base optimizer simply
  needs to encode how to search for such a policy." The maze example ends: "if the base optimizer is
  selecting for programs with low description length, then it might find a mesa-optimizer that can solve
  all mazes, despite the training environment only containing one maze."
* Time complexity disfavours it (Section 2.2, "Inductive biases"): "a time penalty on the learned algorithm
  is likely to incentivize the base optimizer to do more precomputation itself by pre-computing relevant
  heuristics rather than delegating optimization work to the learned algorithm. Thus, we hypothesize
  that penalizing description length will favor mesa-optimizers while penalizing time complexity will
  disfavor them. This suggests the following speculative conjecture: neither a minimal-depth nor
  minimal-size boolean circuit that solves a problem can be a mesa-optimizer.[16]" Reference [16] is
  Christiano's "Open question: are minimal circuits daemon-free?".
* Recurrence weakens the time penalty (Section 2.2, "Statefulness"): "Statefulness, therefore, favors
  mesa-optimization by decreasing the implicit penalty on time complexity imposed by enforcing all
  computations to end when the learned algorithm produces its output. One simple form of this might be a
  recurrent neural network".
* The time penalty cuts both ways (Section 3.2): "a time complexity penalty (as opposed to a description
  length penalty) is a double-edged sword. [...] doing so would also promote pseudo-alignment in those
  cases where mesa-optimizers do arise."
* Description length and deception (Section 4.4, "Deceptive and corrigible alignment might have a lower
  description length"): "to the extent that a base optimizer is selecting based on description length,
  it might preferentially select for a deceptively or corrigibly aligned mesa-optimizer over an
  internally aligned one."
* *Bearing.* These are the informal versions of three things the circuit toy makes exact: a searcher is
  cheap in description and dear in time; a size prior charges for time; and recurrence gives the
  description-length regime back. The paper states them as hypotheses and a "speculative conjecture",
  and should be cited as such.

**3.2 Christiano, "Open question: are minimal circuits daemon-free?", 5 May 2018. FROM MEMORY
(+search).** URL as returned by the search engine, not opened:
https://www.lesswrong.com/posts/nyCHnY7T5PHPLjxmN/open-question-are-minimal-circuits-daemon-free.
What I recall, and the search summary agrees: the question is whether the smallest Boolean circuit
that solves a problem (for example, predicts a person's behaviour to some accuracy) can be a "daemon",
an inner optimiser with its own goals that solves the problem only as a means. The intuition for "no" is
that a daemon spends gates on deciding to do well, and a circuit that skips that reasoning is smaller.
The stated obstacle is obfuscation: if the daemon is obfuscated there need be no efficient procedure that
turns the daemon circuit into a smaller circuit for the same problem. Christiano calls the question
important for prosaic alignment and not of much intrinsic interest. That the post exists with this title
and is the reference given for the minimal-circuit conjecture is VERIFIED through reference [16] of 3.1.
*Bearing:* this is the circuit form of the question the note asks; the draft's answer (for a size prior,
searchers are dominated; what remains is "capture" by a strictly smaller circuit that agrees on the
context) is a statement about minimal and near-minimal circuits in Christiano's sense.

**3.3 Hubinger, "Are minimal circuits deceptive?", 2019. FROM MEMORY (+search).** URL as returned by the
search engine, not opened: https://www.lesswrong.com/posts/fM5ZWGDbnjb7ThNKJ/are-minimal-circuits-deceptive.
What I recall: the post argues against the conjecture of 3.2 in its "fastest program" form. The fastest
way to do well on a suitable family of tasks can be to search for a policy at run time, and the fastest
search does not return the fastest policy, so the policy found may be deceptive. The argument is a
reduction (if some task has a deceptive minimal circuit, then so does a natural family of tasks) and
not a proof that deceptive minimal circuits exist. Commenters noted that a minimal circuit, unlike a
fastest program, has no adaptive computation. *Bearing:* the reduction needs a hypothesis that searches
within its own running time; in the index-circuit toy that search is paid for in gates, so the note can
say precisely where the reduction applies (recurrent or uniform families) and where it does not
(feed-forward circuits under a size prior).

**3.4 Hubinger, "How likely is deceptive alignment?", 2022.** Post not opened.

* *VERIFIED (restated in Hubinger, Jermyn, Treutlein, Hudson, Woolverton, "Conditioning predictive
  models", https://arxiv.org/abs/2302.00805, Section 4.2).* "In the low path-dependence case, deception
  is favored by a general simplicity bias because it allows for substituting simpler long-term goals for
  the prediction goal and still getting good performance."
* *VERIFIED (restated in Carlsmith, "Scheming AIs", https://arxiv.org/abs/2311.08379, Sections 4.3.1,
  4.4 and footnote 266).* Hubinger's notion of simplicity "is the length of the code required to write
  down the algorithm that a model's weights implement". The frame in that literature is "schemers are
  favored by simplicity but disfavored by speed—so which will matter more?". On biasing training towards
  speed, Hubinger "thinks of choosing 'the smallest model possible that fits the data' as biasing towards
  speed" and notes that "the smallest model possible that fits the data does the worst on the deep double
  descent curve".
* *FROM MEMORY:* the post is a talk transcript and gives no theorem.
* *Bearing.* The claim "simplicity favours the deceptive model, speed disfavours it, and a pure speed
  bias is not competitive" is the informal statement that the two regimes of the circuit toy (size prior
  against description prior with free computation) are meant to separate.

**3.5 Carlsmith, "Scheming AIs: will AIs fake alignment during training in order to get power?".
VERIFIED** (https://arxiv.org/abs/2311.08379).

* Section 4.4 lists the extra reasoning a schemer must do and says: "my current take is that the costs of
  the instrumental reasoning seem larger than the benefits of the simpler goal."
* Footnote 239 mentions the present argument and sets it aside: there are "more speculative and
  theoretical arguments" on which "if you do an unbounded search over all possible programs to find the
  shortest one that gives a given output, without regard to other factors like how long they have to
  run, then you'll select for a schemer"; people "sometimes take the discourse about the 'malignity of
  the Solomonoff prior' as relevant here (though at a glance, it seems to me like there are important
  differences [...]). Regardless, I'm skeptical that these unbounded theoretical arguments should be
  getting much if any weight, and I won't treat them here."
* *Bearing.* A long recent report on the neural-network version explicitly declines to treat the
  malign-prior argument, which supports the claim that no formal circuit or network version is in the
  literature (item 7).

**3.6 Later formal work.** The only formal result found that bears on the minimal-circuit question is
Christiano, Hilton, Lecomte, Xu 2024 (6.2), which makes the obfuscation obstacle of 3.2 a theorem about
detection. Two further forum posts were returned by the search engine and not opened: "Should we rely
on the speed prior for safety?" (https://www.lesswrong.com/posts/iALu99gYbodt4mLqg/) and "The Speed +
Simplicity Prior is probably anti-deceptive"
(https://www.alignmentforum.org/posts/KSWSkxXJqWGd5jYLB/). FROM MEMORY (+search): both are informal
arguments. *Bearing:* none can be cited for a theorem.

---

## 4. The malign prior and resource bounds

**4.1 Schmidhuber's speed prior. VERIFIED** (J. Schmidhuber, "Algorithmic theories of everything",
https://arxiv.org/abs/quant-ph/0011122, Sections 6.2 to 6.6; the conference paper "The speed prior: a new
simplicity measure yielding near-optimal computable predictions", COLT 2002, was not opened).

* FAST runs, in phase $i$, every program $p$ with $l(p)\le i$ for $2^{i-l(p)}$ steps (Section 6.2; this
  wording follows the description in the paper of 4.2).
* "Postulate 6.1 The cumulative prior probability measure of all x incomputable within time t by the
  most efficient way of computing everything should be inversely proportional to t."
* "Definition 6.3 (Speed Prior S)": $S(x)=\sum_{i\ge1}2^{-i}S_i(x)$ with
  $S_i(x)=\sum_{p\to_ix}2^{-l(p)}$, and equation (47): $S(x)\le2^{-Kt(x)}$.
* Theorem 6.1: if $p_x$ outputs $x_n$ within $f(n)$ steps for all $n$ and $g(n)>O(f(n))$, then the $S$-
  mass of the programs that need at least $g(n)$ steps for $x_n$, divided by the mass of those that need
  at most $f(n)$, tends to $0$.
* *Bearing.* The speed prior charges $\log_2t$ bits for $t$ steps. A seeker with start-up time $T_0$
  loses a factor of order $T_0$ and not all of its mass, so the speed prior is a soft version of the
  note's time schedule, and it is much milder than a circuit-size prior (2.6).

**4.2 Filan, Leike, Hutter, "Loss bounds and time complexity for speed priors". VERIFIED**
(https://arxiv.org/abs/1604.03343; AISTATS 2016, PMLR 51:1394-1402, landing page
https://proceedings.mlr.press/v51/filan16.html read).

* Definitions: $S_{Fast}(x)=\sum_i2^{-i}\sum_{p\to_ix}2^{-|p|}$ and
  $S_{Kt}(x)=\sum_{p\to x}2^{-|p|}/t(p,x)$; Proposition 3: $S_{Fast}(x)$ equals
  $\sum_{p\to x}2^{-2|p|}/t(p,x)$ up to a constant factor.
* "Theorem 9 (Bound on S_Kt prediction loss). If µ is a measure that is estimable in polynomial time by
  some semimeasure ν, and x is a sequence sampled from µ, then the expected loss incurred by the
  Λ_{S_Kt} predictor is bounded by"
  $L^{\Lambda_{S_{Kt}}}_{n\mu}-L^{\Lambda_\mu}_{n\mu}\le2D_n+2\sqrt{L^{\Lambda_\mu}_{n\mu}D_n}$ "where
  D_n = O(log n)". The left side is the loss in excess of the predictor that knows $\mu$.
* "Theorem 12 (Bound on S_Fast prediction loss)": on a deterministic sequence computable in polynomial
  time, $S_{Fast}$ "only incurrs logarithmic loss".
* Abstract: their prior "is computable in doubly-exponential time, but not in polynomial time"; for
  Schmidhuber's prior "the question of its predictive properties for stochastic sequences remains open".
* *Bearing.* These are the only loss bounds for speed priors, and they are budget statements of the
  note's kind with $D_n=O(\log n)$ in place of a constant; nothing in the paper concerns adversarial
  hypotheses.

**4.3 A resource-penalising prior used to exclude bad hypotheses. VERIFIED** (Cohen, Vellambi, Hutter,
"Asymptotically unambitious artificial general intelligence", https://arxiv.org/abs/1905.12186, AAAI
2020 by memory). The world-models are Turing machines with a work tape of bounded length $\ell$ during
an episode, with prior weight $w(\nu_k^{<\ell})\propto\beta^\ell$, $\beta\in(0,1)$. "Assumption 2 (Space
Requirements). For sufficiently small ε [∀i a world-model which is non-benign and
ε-accurate-on-policy-after-i uses more space than µ] w.p.1". "Theorem 5 (Eventual Benignity)":
$\lim_{\beta\to0}P^\pi_\mu[\exists i_0\,\forall i>i_0\ \hat\nu^{(i)}\text{ is benign}]=1$. The authors
describe the prior as "a new form of resource-bounded prior in the lineage of Filan, Leike, and Hutter
(2016) and Schmidhuber (2002), this one penalizing space instead of time." *Bearing:* this is the one
published theorem found in which a resource penalty in the prior removes unwanted hypotheses; it does so
under an assumption that the unwanted models need more of the resource than the truth, which is the same
shape as the note's "a schedule below the seeker's start-up gives it no mass". "Benign" there is meant
"to roughly mean that a world-model does not model the rewards of episode i as being causally descended
from outside-world events that are causally descended from the actions of episode i"; it is not the
malign-prior notion.

**4.4 Christiano, "What does the universal prior actually look like?", 2016. FROM MEMORY (+search).**
Not opened. I do not recall a worked argument about speed priors or circuit-size priors in the post. The
search summary reports only commentary on it, including the remark that it is "perennially considered an
open question whether or not the speed prior is also full of consequentialists". **Do not attribute a
claim about the speed prior to the 2016 post without opening it.** Christiano's own bounded-resource
version of the question is the 2018 post (3.2). *Bearing:* the note may say that the question for
resource-bounded priors was raised informally and left open.

**4.5 Kosoy. FROM MEMORY (+search).** Not opened. A shortform post models the problem by assuming that a
fraction of the prior is malign and asks how much information those hypotheses can push into the world
through the agent, with the aim of algorithms that have good regret bounds and small "malign capacity";
confidence thresholds (the agent acts only where its hypotheses agree, as in delegative reinforcement
learning) are named as one mechanism. An interview on infra-Bayesian physicalism has a section "Bridge
rules and malign priors". I know of no theorem by Kosoy about a speed or circuit-size prior. *Bearing:*
a different remedy (abstain where hypotheses disagree) and not a resource bound; cite only as a pointer.

**4.6 Wyeth, Hutter, "Formalizing embeddedness failures in universal artificial intelligence". VERIFIED**
(https://arxiv.org/abs/2505.17882; already in the note's bibliography). Theorem 7: "There exists a ∈ B^∞
such that" the joint universal mixture's probability of the identity environment's percepts along $a$
tends to $0$; the Discussion says "we assume adversarially selected action bits" and that on-policy
behaviour is not known. On resource bounds the paper says only that reflective AIXI "is still a
computationally unbounded model of intelligence". The words "malign", "speed prior" and "simulation" do
not occur in it. *Bearing:* it has nothing on resource-bounded priors or on the malign-prior argument
and should not be cited for either.

**4.7 Wyeth, "Changing my mind about Christiano's malign prior argument", 4 April 2025. FROM MEMORY
(+search).** Not opened; URL as returned:
https://www.lesswrong.com/posts/KAifhdKr96kMre2zy/changing-my-mind-about-christiano-s-malign-prior-argument.
The search summary says the author had been sceptical of the argument and came to give it some credence.
*Bearing:* informal; shows the argument is still disputed among people who work on the universal
distribution.

**4.8 A description-length floor for a Bayesian imitator. VERIFIED** (Cohen, Hutter, Bengio, Russell,
"RL, but don't do anything I wouldn't do", https://arxiv.org/abs/2410.06213, Theorem 1; already used by
the note). "∃ a constant d such that ∀ U_m, and ∀ E, if E is unprecedented and occurs at time t, then
for any v < V*_{ξ,U_m}(x_{<2t}), ∃ a policy π for which V^π_{ξ,U_m}(x_{<2t}) > v, and
KL_{x_{<2t},m}(π||ξ) < [d + K(U_m) + K(E) + K(vξ(x_{<2t}))]/ log 2." The authors: "The constant d is a
small one corresponding to how much code it takes to implement a search tree, Bayes' rule, and a few if
statements." The arXiv version 1 is headed "Under review as a conference paper at ICLR 2025"; the venue
in the note's bibliography was not checked here. *Bearing:* the constant $d$ is the cost of an
interpreter and a search in program length; for circuits that machinery is not of constant size (an
interpreter alone costs $\Theta(\sigma\log\sigma)$ gates, item 1), so this floor does not transfer at
constant cost.

**4.9 Speed bias as a remedy, in passing. VERIFIED** (Hubinger et al., arXiv:2302.00805, Section 2.5,
footnote on a separate camera model): "if we can separately train the camera model with e.g. a strong
speed bias, it might be hard for it to learn something like a general inductor." *Bearing:* an informal
statement of the same remedy, for a component and not for the whole predictor.

**4.10 ARC, "Eliciting latent knowledge", 2021. FROM MEMORY.** Not opened (a hosted document). It
considers penalising computation time and description complexity of the reporter and gives informal
counterexamples to both. *Bearing:* pointer only.

---

## 5. Priors over circuits or networks as models of what training finds

**5.1 Valle-Pérez, Camargo, Louis, "Deep learning generalizes because the parameter-function map is
biased towards simple functions". VERIFIED** (https://arxiv.org/abs/1805.08522v5, headed "Published as a
conference paper at ICLR 2019").

* Abstract: "By applying a very general probability-complexity bound recently derived from algorithmic
  information theory (AIT), we argue that the parameter-function map of many DNNs should be
  exponentially biased towards simple functions."
* The bound (Section 3, equation (1), attributed to Dingle et al. 2018): $P(x)\le2^{-a\tilde K(x)+b}$,
  where $\tilde K$ is "an approximation to the (uncomputable) Kolmogorov complexity of x, and a and b
  are scalar parameters which depend on the map g but not on x." It needs "a simplicity criterion
  K(g)+K(n) ≪ K(x)+O(1)" and redundancy. "While these arguments (Dingle et al. (2018)) do not prove that
  maps are biased, they do say that if there is bias, it will follow Eq. (1)."
* The experiment (Section 4): "a neural network with 7 Boolean inputs, two hidden layers of 40 ReLU
  neurons each, and a single Boolean output"; the rank plot of $P(f)$ fits a Zipf law with "an estimated
  range of 39 orders of magnitude in P(f)".
* *Bearing.* The claim is an upper bound of universal-prior type plus an empirical fit for one small
  architecture; it does not say that the prior of a network or circuit *is* a universal prior, and the
  five conditions of its Appendix E (among them "The map f must be a nonlinear function since linear
  functions do not exhibit bias") are conditions under which bias *may* occur.

**5.2 Mingard, Valle-Pérez, Skalse, Louis, "Is SGD a Bayesian sampler? Well, almost". VERIFIED**
(https://arxiv.org/abs/2006.15191v2; JMLR 2021 by memory). Abstract: "Our main findings are that
P_SGD(f|S) correlates remarkably well with P_B(f|S) and that P_B(f|S) is strongly biased towards
low-error and low complexity functions. These results imply that strong inductive bias in the
parameter-function map (which determines P_B(f|S)), rather than a special property of SGD, is the
primary explanation for why DNNs generalise so well in the overparameterised regime." The finding is
empirical ("We empirically investigate this bias"), with "second order differences that are sensitive to
hyperparameter tuning". *Bearing:* this is the evidence for reading "what training finds" as "a sample
from the posterior of the prior over parameters", which is what licenses the note's Bayesian predictor
over circuits as a model of a trained network; it is an empirical correlation and not a theorem.

**5.3 Dingle, Camargo, Louis, "Input-output maps are strongly biased towards simple outputs", Nature
Communications 2018.** An arXiv title search found no listing under this title; not opened.

* *VERIFIED (restated in Dingle, Valle-Pérez, Louis, "Generic predictions of output probability based
  on complexities of inputs and outputs", https://arxiv.org/abs/1910.00971, first page).* The coding
  theorem gives $2^{-K(x)}\le P(x)\le2^{-K(x)+O(1)}$ for a universal machine; for non-universal maps "an
  upper bound on the probability P(x) that an output obtains upon uniform random sampling of inputs,
  P(x) ≤ 2^{−aK̃(x)−b}, was recently derived". It "holds for computable maps f where the number of inputs
  N_I is much greater than the number of outputs N_O and the map K(f) is simple". And: "in sharp
  contrast to the full AIT coding theorem, it doesn't have a lower bound, allowing low K̃(x) outputs with
  low P(x) that are far from the bound."
* The sign of $b$ differs between this restatement ($-b$) and the one in 5.1 ($+b$); it is a free
  constant.
* *Bearing.* For a non-universal map such as "circuit description to truth table" only the upper half
  of the coding theorem survives: simple outputs need not have high probability, which is the
  literature's version of the note's finding that a short program with a long running time has no mass
  under a circuit prior.

**5.4 Mingard, Skalse, Valle-Pérez, Martínez-Rubio, Mikulik, Louis, "Neural networks are a priori biased
towards Boolean functions with low entropy". VERIFIED** (https://arxiv.org/abs/1909.11522v3, abstract).
For "a single-layer perceptron with n input neurons, one output neuron, and no threshold bias term – we
prove that upon random initialisation of weights, the a priori probability P(t) that it represents a
Boolean function that classifies t points in {0, 1}^n as 1 has a remarkably simple form: P(t) = 2^{−n}
for 0 ≤ t < 2^n." And "we prove that, regardless of the distribution of inputs, the bias towards low
entropy becomes monotonically stronger upon adding ReLU layers". *Bearing:* a proved bias of a network
prior, but towards unbalanced functions and not towards small circuits; compare the draft's exchangeable
predictor (CA2), which also learns only the frequency of ones.

**5.5 Mingard, Rees, Valle-Pérez, Louis, "Deep neural networks have an inbuilt Occam's razor". VERIFIED**
(https://arxiv.org/abs/2304.06670v2, abstract). The analysis "shows that structured data, together with
a specific Occam's razor-like inductive bias towards (Kolmogorov) simple functions that exactly
counteracts the exponential growth of the number of functions with complexity, is a key to the success
of DNNs." *Bearing:* an empirical claim that the prior of a network is close to $2^{-K}$ in the regime
tested; no theorem.

**5.6 Buzaglo, Harel, Nacson, Brutzkus, Srebro, Soudry, "How uniform random weights induce non-uniform
bias: typical interpolating neural networks generalize with narrow teachers". VERIFIED**
(https://arxiv.org/abs/2402.06323v3; ICML 2024, PMLR 235:5035-5081, landing page read).

* Abstract: "We prove that such a random NN interpolator typically generalizes well if there exists an
  underlying narrow 'teacher NN' that agrees with the labels. Specifically, we show that such a 'flat'
  prior over the NN parameterization induces a rich prior over the NN functions, due to the redundancy
  in the NN structure. In particular, this creates a bias towards simpler functions, which require less
  relevant parameters to represent — enabling learning with a sample complexity approximately
  proportional to the complexity of the teacher (roughly, the number of nonredundant parameters), rather
  than the student's."
* Equation (1): the number of samples needed is $O(-\log\tilde p)$, "where p̃ is the probability that a
  random NN (sampled from the 'uniform' prior) is equivalent to the teacher function"; footnote 2: "This
  is a generic argument and essentially a special case of a PAC-Bayes guarantee".
* Theorem 4.3, for depth $L$, a $Q$-quantised teacher with widths $d^\star_l$, a student with widths
  $d_l>d^\star_l$ and a prior uniform over $Q$-quantised parameters: for vanilla fully connected
  networks the complexity term is at most
  $\hat C^{FC}=\bigl(\sum_{l=1}^L(d^\star_l\,d_{l-1}+d^\star_l)\bigr)\log Q$; for networks with a scale
  parameter per neuron it is at most
  $\hat C^{SFC}=\bigl(\sum_{l=1}^L(d^\star_l\,d^\star_{l-1}+2d_l)\bigr)\log Q$; and
  "N = (C̃ + 3 log 2/δ)/ε samples are enough to ensure that for posterior sampling" the error is at most
  $\varepsilon$ with probability $1-\delta$. The discussion adds that $\hat C^{FC}$ "is still
  significantly larger than the complexity C⋆ of the teacher", and that "an explicit narrowness prior
  could have of course been fully adaptive to the width of the teacher and ensured learning with the
  ideal sample complexity C⋆."
* *Bearing.* This is the nearest proved statement to the draft's budget for circuits: the posterior of
  a flat prior over a large network learns a small "world" at a cost set by the world's size *and by
  the size of the host*. In the vanilla network each teacher unit pays for the full fan-in $d_{l-1}$ of
  the student, as each gate of an embedded circuit pays a pointer width that grows with the host (the
  draft's CA7); a prior that mixes over sizes removes the dependence on the host, as the draft's mixture
  prior does.

**5.7 The "volume hypothesis". VERIFIED** (Scherlis, Belrose, "Estimating the probability of sampling a
trained neural network at random", https://arxiv.org/abs/2501.18812v2, abstract and introduction): "that
neural net training produces good generalization primarily because the architecture gives simple
functions more volume in parameter space, and the optimizer samples from the low-loss manifold in a
volume-sensitive way." Restated there: Chiang et al. (2022) evaluated a "Guess & Check" optimiser "which
randomly samples parameters until it stumbles upon a network that achieves training loss under some
threshold" and found generalisation similar to gradient descent "at least on the very simple tasks they
tested"; Teney et al. (2024) "find that randomly initialized networks represent very simple functions".
*Bearing:* a current statement of the modelling assumption behind a Bayesian predictor over networks,
with its evidence limited to small tasks.

**5.8 Random AND/OR formulas: bounds uniform in the function.** Lefmann, Savický, "Some typical
properties of large and/or Boolean formulas", Random Structures and Algorithms 10:337-351, 1997;
Chauvin, Flajolet, Gardy, Gittenberger, "And/or trees revisited", Combinatorics, Probability and
Computing 13:475-497, 2004. Neither opened.

* *VERIFIED (restated in Broutin, Mailler, "And/or trees: a local limit point of view",
  https://arxiv.org/abs/1510.06691, Introduction and Section 4.1).* For uniformly random binary AND/OR
  trees with leaves labelled by the $2k$ literals, the induced distribution on $k$-variable functions
  has a limit $P_k$ as the tree size grows, and Lefmann and Savický "prove that, for all k ≥ 2,"
  $$\exp(-c_1L(f)\log k)\ \le\ P_k(f)\ \le\ \exp(-c_2L(f)\,k^{-3})$$
  "for two constants c1, c2 > 0", where $L(f)$ is "the minimal number of leaves of a tree representing
  f". Chauvin et al. "replace the k^{−3} in the right-hand side [...] by k^{−2}". "These bounds are the
  only results in the literature that hold for fixed k".
* *VERIFIED* (the same paper, Theorem 4.2): for Galton-Watson shapes with exponential moments, the upper
  bound improves by a symmetry argument to $\exp(-c_2L(f)k^{-2})$ divided by the binomial coefficient
  $\binom{k}{\mathrm{Ess}(f)}$, with $\mathrm{Ess}(f)$ the number of essential variables. (Read from
  extracted PDF text; check the display against the paper before quoting.)
* *Bearing.* The lower bound is the formula analogue of the note's floor: a function of formula size $L$
  has prior mass at least $k^{-c_1L}$, that is, $L$ leaves at $\log k$ bits each. The upper bound is far
  weaker ($L/k^2$ in the exponent), so even for formulas the literature does not show that mass is
  *close to* $2^{-\text{description length}}$ uniformly in $f$.

**5.9 Random AND/OR formulas: the exact order for a fixed function.** Kozik, "Subcritical pattern
languages for And/Or trees", Fifth Colloquium on Mathematics and Computer Science, DMTCS Proceedings
2008, 437-448. Not opened.

* *VERIFIED (restated in 1510.06691, equation (2); in Genitrini, Gittenberger, Kraus, Mailler,
  https://arxiv.org/abs/1305.0651, Theorem 2.5; and in Daxner, Genitrini, Gittenberger, Mailler,
  https://arxiv.org/abs/1407.0501, equation (1)).* For every fixed Boolean function $f$,
  $$P_k(f)=\Theta\!\left(\frac{1}{k^{L(f)+1}}\right)\qquad(k\to\infty),$$
  "where the constants involved in the Θ-term depend on f". arXiv:1305.0651 adds: "the relation between
  probability and complexity of a Boolean function holds for a fixed function f. It is not valid
  uniformly over all Boolean functions."
* *VERIFIED* (arXiv:1407.0501, Theorem 2.4 and equation (2)): when the size of a non-binary AND/OR tree
  is its total number of nodes, $P_n(f)=\Theta(1/n^{L(f)})$ with $L$ the tree-size complexity, the two
  constant functions have limiting probability bounded away from $0$, and so "the tree size model does
  not exhibit the Shannon effect".
* *Bearing.* This is the closest published analogue of a coding theorem for a size prior: for formulas,
  minus log prior mass is $(L(f)+1)\log_2k+O_f(1)$, "one variable name per leaf". It is proved for trees
  and for fixed $f$ only. **I found no analogue for circuits with shared gates**, where the count per
  gate would be $\log$ of the number of wires and where 2.5 and 2.7 show that order and dead code change
  the leading constant.

**5.10 The shape distribution matters. VERIFIED (restated in 1510.06691, Introduction).** Chauvin,
Gardy, Mailler ("The growing tree distribution on Boolean functions", ANALCO 2011) proved "that if one
replaces the uniformly random binary trees [...] by random binary search trees [...], then the behaviour
of the family of distributions induced on Boolean function is radically different": the probability of
the two constant functions tends to $1$ as the tree size grows, for every $k$; "we say that this
distribution is degenerate." *Bearing:* a published instance of what the draft finds for its Option I
(CA1, CA2): a natural-looking distribution over circuits can induce a degenerate predictor, so the choice
of how a circuit is drawn and read is part of the result.

**5.11 Growth processes. VERIFIED** (Brodsky, Pippenger, "The Boolean functions computed by random
Boolean formulas or how to grow the right function", https://arxiv.org/abs/cs/0302028). A growth process
iterates $\pi_{i}(f)=\Pr[\alpha(g_1,\dots,g_k)=f]$ with $g_j$ independent draws from $\pi_{i-1}$,
starting from a uniform distribution on a set of projections, negations and constants. "We show that for
many growth processes, the probability distribution on the computed function tends to the uniform
distribution on some set of functions (which may range in size from a single function, as in Valiant's
result, to all functions, as in Savický's)", and "for any ε > 0,
max_f |π(f) − π_{O(log(n))}(f)| < ε" for almost all processes studied. Restated there: Savický (Discrete
Mathematics 83:95-103, 1990) "formulated broad conditions under which the distribution of the random
function computed by a formula of depth i tends to the uniform distribution on all Boolean functions of
n variables"; Valiant (J. Algorithms 1984) showed convergence to the majority function; and for other
models "Lefmann and Savický [LS97] and Savický [Sav98] have shown that the logarithm of the probability
of computing a particular function is related to the complexity of that function". *Bearing:* balanced
random formulas of growing depth forget everything and give the uniform distribution on a class, the
same degeneracy as the draft's CA1; this suggests that where a prior over circuits is informative, it
is so through unbalanced shapes and the mixture over sizes.

**5.12 Random circuits look like random functions quickly. VERIFIED** (Gay, He, Kocurek, O'Donnell,
"Pseudorandomness properties of random reversible circuits", https://arxiv.org/abs/2502.07159,
abstract). "a random circuit of depth" $\sqrt n\cdot\tilde O(k^3)$, "with each layer consisting of Θ(n)
random gates in a fixed two-dimensional nearest-neighbor architecture, yields approximate k-wise
independent permutations." Restated there: Gowers (1996) "showed a gap of 1/poly(n, k) for one random
gate", improved by Hoory, Magen, Myers, Rackoff (2005) and Brodsky, Hoory (2008). *Bearing:* for
reversible circuits with a fixed architecture, a uniformly random circuit of size polynomial in $n$ and
$k$ is statistically close to a random permutation on any $k$ inputs, so its posterior after $k-1$
observations predicts almost nothing about a $k$-th; this suggests that a uniform prior at one large
fixed size is uninformative. No such result was found for the draft's (irreversible, unlayered) gate
lists.

**5.13 A looped network with a parameter-count prior is the universal prior up to a log factor.
VERIFIED as a statement** (Musat, "Neural weight norm = Kolmogorov complexity",
https://arxiv.org/abs/2605.10878v1, May 2026; a single-author preprint, proofs not checked here).
"Theorem 4 (Main). Let s ∈ {0, 1}* be computable. There exist constants c_U, c_d ≥ 0, depending on the
universal Turing machine U, the architecture, and the precision (δ, M) but not on s, such that N(s) ≤
K(s) + c_U, K(s) ≤ c_d · N(s) log_2 N(s) + c_d", where $N(s)$ is "the minimum number of non-zero
parameters in a fixed-precision looped neural network that halts and outputs s". Corollary 7: for the
prior $\pi(\theta)\propto2^{-\|\theta\|_2^2}$ and $Q(s)$ the induced probability of output $s$,
$2^{-K(s)-\alpha}\le Q(s)\le2^{-K(s)/(\beta\log K(s))}$. The proof idea is stated as: a program is
encoded "at unit cost per program bit", and a network is described "by enumerating its non-zero
parameters with logarithmic addressing overhead". *Bearing:* this is the published form of the draft's
Section 11: when the description is paid once and the computation is repeated without a time bound, a
program of length $a$ has a network of prior weight at least $2^{-a-\alpha}$ (as stated), so lower
bounds on the mass of a program-like hypothesis carry over. The matching upper bound is weaker by a
logarithmic factor in the exponent, so statements about shares, which are ratios of masses, do not carry
over without more work; and the result is for networks that halt and output a finite string, not for
sequence prediction. The logarithmic addressing overhead is the same $s\log s$ as in 2.5.

---

## 6. Backdoors

**6.1 Goldwasser, Kim, Vaikuntanathan, Zamir, "Planting undetectable backdoors in machine learning
models". VERIFIED** (https://arxiv.org/abs/2204.06974v2; FOCS 2022 by memory).

* "Theorem 2.1 (Informal). Assuming the existence of one-way functions, for every training procedure
  Train, there exists a model backdoor (Backdoor, Activate), which is non-replicable and black-box
  undetectable." (Formal version: Theorem 5.4, from strongly unforgeable signatures.) The construction:
  on input $x=(w,y,\sigma)$ the backdoored model outputs $(-1)^y$ if
  $\mathrm{Verify}(vk,(w,y),\sigma)$ accepts and the original output otherwise; "We will augment the
  classifier with the public-key verification procedure of the signature scheme that runs in parallel to
  the original classifier."
* Size and depth: "using this method to backdoor a depth-d neural network will result in a
  depth-max(d, 4) neural network. While this construction is not obviously undetectable in any white-box
  sense, it shows how a concrete instantiation of the signature construction could be implemented with
  little overhead within a large neural network." Theorem 5.5: depth $\max(c,d)$ for an absolute
  constant $c$. I found no stated bound on the number of added gates in the parts read; by the
  construction it is the size of a signature verification circuit, polynomial in the signature length
  $n$ and independent of the model.
* Theorem 5.3, the unprotected version: from a network $N$ and a parameter $n$ one can build $N'$ with
  $N'(x)=N(x)$ with probability $1-2^{-n}$ and such that every $x$ has an $x'$ with
  $\ell_0(x,x')\le n+1$ and $N'(x')\ne N'(x)$.
* "Theorem 2.2 (Informal). Assuming the hardness of worst-case lattice problems, for any data
  distribution D with X ⊆ R^d, there is a backdoor (Backdoor-RFF, Activate-RFF) with respect to
  Train-RFF, that is white-box undetectable." Here "the only aspect of the computation that requires
  adversarial manipulation is the generation of random features", so the backdoored network has the
  same architecture and size as a clean one.
* Theorem 5.7: for any $N$ of size $|N|$ and depth $d$ there is $N'$ "of size O(|N|) and depth d + 1"
  computing the same function that is persistent under gradient descent for every loss.
* *Bearing.* A trigger that fires on a set of density $2^{-n}$ costs an *additive* number of gates
  polynomial in $n$ and independent of the host, or nothing at all when it is hidden in the random
  coins. This is the cryptographic counterpart of the draft's wrapper floor (CA7): the price of "behave
  as the host except on a recognisable input" is the size of the recogniser, which under a size prior
  is a factor of about $2^{-(\text{recogniser gates})\times(\text{pointer width})}$ in mass.

**6.2 Christiano, Hilton, Lecomte, Xu, "Backdoor defense, learnability and obfuscation". VERIFIED**
(https://arxiv.org/abs/2409.03077v2, Alignment Research Center; it exists; ITCS 2025 by memory).

* The game: the attacker chooses a distribution $D$ and $f\in\mathcal F$, a trigger $x^*\sim D$ is drawn
  at random, the attacker chooses $f^*\in\mathcal F$ with $f^*(x^*)\ne f(x^*)$ and
  $\Pr_{x\sim D}[f^*(x)\ne f(x)]\le\varepsilon$, and the defender must tell $(f,x)$ with $x\sim D$ from
  $(f^*,x^*)$. "The key constraint on the attacker that makes defense possible is that the attacker's
  strategy must work for a randomly-chosen trigger."
* "Theorem 4.1. [...] the most (i.e., supremum) confidence with which F is ε-defendable is
  max(1/2, 1 − Θ(VC(F) ε)) as VC(F) → ∞." "Corollary 5.2. [...] If F is efficiently PAC learnable, then
  F is efficiently defendable."
* "Theorem 5.5. Assuming OWF and iO, the representation class F of polynomial size Boolean circuits over
  X = {0, 1}^n is not efficiently defendable." The proof takes $f=iO(C_K)$ for a puncturable
  pseudorandom function and $f^*=iO$ of the circuit that uses the key punctured at $x^*$ and outputs the
  hard-coded value $1-C_K(x^*)$ there; $\varepsilon=2^{-n}$.
* "Theorem 6.1. The representation class F of decision trees over X = {0, 1}^n of size at most s, where
  s is polynomial in n, is efficiently uniform-defendable using a detection strategy that makes 0 calls
  to the example oracle and runs in time O(time taken to evaluate a single decision tree)." The
  strategy "simply checks the depth of the leaf reached by the given input, and outputs Rej if this is
  too large", because "in order for the backdoored function to be ε-valid, the depth of the leaf reached
  by the backdoor trigger must be large for either the original function or the backdoored function. But
  since our trees have polynomially many leaves, this depth is unlikely to be large for the original
  function."
* Open (Question 7.1): "Under reasonable computational hardness assumptions, is the representation class
  of polynomial size, logarithmic-depth Boolean circuits over {0, 1}^n efficiently defendable?" The
  authors note this class is "equivalently, polynomial size Boolean formulas".
* Appendix A, a Bayesian defence: with $Q_f(h)\propto P(h)\exp(-m|h-f|)$ for any prior $P$, "Claim A.5.
  ∀f, f', h ∈ F : Q_{f'}(h) ≤ exp(2m|f − f'|) Q_f(h)" and "Corollary A.7. For any prior P and inverse
  temperature m, the class F is ε-defendable with confidence ≥ 1 − exp(2mε) max_f E_{h∼Q_f}[|h − f|]
  using the Boltzmann strategy."
* Section 7.3 states the purpose: "We are motivated to study backdoors as an analogy for deceptive
  alignment", and the limit of the analogy: "the attacker must insert a backdoor that works for a
  randomly-chosen trigger. But in the case of deceptive alignment, there is no such restriction".
* *On size.* The paper states no size cost. In Theorem 5.5 both $f$ and $f^*$ are obfuscations of
  circuits of the same polynomial size (indistinguishability obfuscation is defined for circuits "that
  have the same size, input length, and output length, and are functionally equivalent", as stated in
  6.3), so the backdoor costs nothing relative to the clean obfuscated function, and both are far from
  minimal (this remark is an inference from the definition; the paper does not discuss padding). In
  Theorem 6.1 the backdoor is detected because a rare deviation needs a deep leaf, which is a statement
  about the cost in depth of the path that reaches the trigger.
* *Bearing.* (i) Claim A.5 is a posterior-stability statement of the note's kind: changing the target on
  a set of mass $\varepsilon$ moves a posterior with $m$ effective samples by a factor at most
  $e^{2m\varepsilon}$. (ii) Theorem 5.5 is Christiano's obfuscation obstacle (3.2) as a theorem: among
  polynomial-size circuits a rare deviation cannot be found efficiently, although it can be found by a
  size-regularising posterior in unbounded time (Theorem 4.1). (iii) The random-trigger restriction is
  what a prior over circuits supplies for free in the toy; a seeker chooses its trigger, and the paper
  says its results do not cover that case.

**6.3 Kalavasis, Karbasi, Oikonomou, Sotiraki, Velegkas, Zampetakis, "Injecting undetectable backdoors
in obfuscated neural networks and language models". VERIFIED** (https://arxiv.org/abs/2406.05660v2,
abstract, Assumption 2.7 and the statement of Theorem 4.2). "We develop a general strategy to plant
backdoors to obfuscated neural networks, that satisfy the security properties of the celebrated notion
of indistinguishability obfuscation. [...] even if the weights and architecture of the obfuscated model
are accessible, the existence of the backdoor is still undetectable." The obfuscator's guarantee is for
"two ensembles [...] of polynomial-sized circuits that have the same size, input length, and output
length, and are functionally equivalent". *Bearing:* white-box undetectability for general networks is
obtained by making the clean and the backdoored model the same size by construction; size is the one
observable that these constructions equalise and never reduce.

**6.4 Draguns, Gritsevskiy, Motwani, Rogers-Smith, Ladish, Schroeder de Witt, "Unelicitable backdoors in
language models via cryptographic transformer circuits". VERIFIED** (https://arxiv.org/abs/2406.02619v2,
abstract only). The backdoors are "unelicitable": the defender cannot trigger them "even if given full
white-box access", while they are "not completely undetectable in white-box settings". *Bearing:* an
engineering instance of 6.1 inside a transformer; no size bound was read.

**6.5 What these say about the cost in size, in one place.**

| construction | added size | tag |
|---|---|---|
| signature check in parallel (6.1, Thm 5.4, 5.5) | a verification circuit, polynomial in the signature length, independent of the host; depth $\max(c,d)$ | VERIFIED for depth and "little overhead"; the polynomial bound is the standard reading, not a quoted statement |
| random features (6.1, Thm 2.2) | none: same architecture, different random coins | VERIFIED |
| obfuscated circuits (6.2 Thm 5.5; 6.3) | none relative to the clean obfuscated circuit; both padded to equal size | VERIFIED for the definition; the padding remark is an inference |
| decision trees (6.2 Thm 6.1) | the trigger sits at a deep leaf, and depth is what the defender tests | VERIFIED |

No paper found states a *lower* bound on the size of a backdoor, and none asks whether a backdoored
circuit can be *smaller* than every clean circuit that agrees with it off the trigger, which is the
draft's "capture" route (CA23).

---

## 7. Formal treatments of the malign-prior argument for circuits or networks

**None found.** What was done: arXiv searches (title and abstract) for "malign prior", "universal prior"
with "malign", "Solomonoff" with "malign", "Solomonoff" with "inner alignment", "minimal circuits" with
"deceptive", and "universal prior" with "consequentialists" returned no paper; a web search returned
forum posts only. Limits: arXiv's search does not cover full text, and the forums could not be opened,
so an informal circuit version in a post or comment may exist. The note should keep its sentence that
earlier informal versions may exist.

The nearest formal work, all listed above:

| work | what it does formally | what it does not do |
|---|---|---|
| Christiano, Hilton, Lecomte, Xu 2024 (6.2) | a detection game for rare deviations in circuit classes; posterior stability (Claim A.5); impossibility for obfuscated circuits | no prior over circuits as the source of the deviation; trigger is random |
| Musat 2026 (5.13) | a parameter-count prior on looped networks equals the universal prior up to a log factor in the exponent | does not mention adversarial hypotheses; no time bound |
| Cohen, Vellambi, Hutter 2020 (4.3) | a resource penalty in the prior excludes "non-benign" world-models, under an assumption on resource use | space and not circuit size; a different notion of benign |
| Cohen, Hutter, Bengio, Russell 2024 (4.8) | description-length floor for unprecedented simple behaviour in a Bayesian imitator | programs only |
| Buzaglo et al. 2024 (5.6) | the posterior of a flat prior over networks learns a small teacher at a cost set by the teacher's size | honest teacher only |
| Hubinger et al. 2023 (below) | informal discussion for trained predictive models | no theorem |

**7.1 "Anthropic capture" for trained predictors. VERIFIED** (Hubinger et al., arXiv:2302.00805, Section
2.5). "Here our concern is that the predictor might believe that the training data were generated by a
simulation. [...] this allows future potentially malign AIs running simulations to cause our AI to output
essentially arbitrary predictions by changing the parameters of the simulation." The condition for it is
a predictor with "many, arbitrary hypotheses for what its cameras might look like [...] (e.g. this is
what Solomonoff induction[Alt12] does)", and it could arise because "if the model simply learns some
very general-purpose prediction algorithm that does a very generic search over hypotheses that might
explain its data, then the simulation hypothesis will be included just as a side effect of that general
search." *Bearing:* this is the published informal statement of the argument for neural predictors; it
locates the risk in a learned general search over hypotheses, which in the circuit toy is the recurrent
or uniform regime and not the feed-forward size-prior regime.

**7.2 Carlsmith's footnote** (3.5) is the other place where the transfer to trained networks is
mentioned, and it is declined there.

---

## Pointers for the circuit draft (`circuits-A.md`), not edits

1. *CA17(c), universal circuits.* The range "between about 3 and 19" matches what I recall (1.1, 1.2)
   but no constant was verified. What is verified, at second hand, is $O(c\log c)$ size, $O(c)$ depth
   and optimality up to a constant factor (1.1). The lower bound with constant $1-o(1)$ can be proved in
   the note from TR05-032 (1.4, 2.5(d)) without citing anything unverified.
2. *The line that cites Shannon.* Supported; cite TR05-032 for the form with explicit error terms (2.3),
   whose lower bound is for the draft's basis.
3. *The line that cites Lupanov for a block of $m$ arbitrary bits.* Lupanov's theorem is for total
   functions of $j$ variables. For a block of $m$ bits at positions $n+1,\dots,n+m$ it gives
   $(1+o(1))\,2^j/j$ with $2^j\ge m$, which is up to twice $m/\log_2m$ when $m$ is not a power of two,
   plus $O(k)$ gates to subtract the offset and select the block. The bound $(1+o(1))m/\log_2m$ for all
   $m$ needs the splitting argument of 2.5(d) or the theory of partial functions, which I recall only
   vaguely (FROM MEMORY: results of Sholomov and of Andreev on partially defined functions, with
   conditions relating $m$ and $k$). Safer wording: "of order $m/\log m$".
4. *Order of gates.* The gate-list code spends $2s\log_2s$ bits where the functions of size $s$ number
   $2^{(1+o(1))s\log_2s}$ (2.5). Statements that turn a description length into a share should say which
   of the two is meant.
5. *Dead code.* By 2.7 a uniform member of $\mathcal C_{k,s}$ has a live cone of order $\sqrt s$ gates
   (at most about $2.1\sqrt{k+s}$ on average).
   This affects any reading of the fixed-size prior as "hypotheses that do $s$ operations per bit", and
   it suggests that the mass of a function $f$ under the fixed-size prior is governed by embeddings of
   its minimal circuit among the early gates, where pointers are cheap. One exact consequence, DERIVED
   and unchecked: the first $\sigma$ gates of a uniform member of $\mathcal C_{k,s}$ are a uniform member
   of $\mathcal C_{k,\sigma}$, and the last gate copies wire $k+\sigma$ with probability at least
   $1/(16(k+s-1))$, so for every $s>\sigma$ the size-$s$ mass of a function is at least its size-$\sigma$
   mass divided by $16(k+s-1)$.
6. *No circuit analogue of Kozik's theorem was found* (5.9). If the section states how the prior mass of
   a function depends on its circuit size, that statement is new and has to be proved in the note.
7. *Section 11 (recurrence).* Musat 2026 (5.13) is a citation for "the output prior of a looped network
   under a parameter-count prior is the universal prior up to a logarithmic factor in the exponent"; it
   is an unrefereed preprint, and it gives a constant-cost bound only from below.
8. *Circuit size and time.* TR02-028 (2.6) is the citation for "circuit size is polynomially equivalent
   to description length plus time", and with 4.1 and 4.2 it gives a one-line comparison of a size prior
   with the speed prior.

---

## What a paper may cite, and how

### A. Safe to cite as known (VERIFIED: the source was opened and the statement read)

1. $\frac{2^n}{n}(1+\frac{\log n}{n}-O(\frac1n))\le L(n)\le\frac{2^n}{n}(1+3\frac{\log n}{n}+O(\frac1n))$;
   lower bound over the full binary basis, upper bound over $\{\neg,\wedge,\vee\}$. Frandsen, Miltersen,
   ECCC TR05-032.
2. A circuit with $s$ gates over the full binary basis on $n$ inputs has a description of at most
   $(s+1)(7+\log_2(n+s))$ bits. ECCC TR05-032, Section 2.
3. $\mathrm{SIZE}(x)=O(\mathrm{KT}(x)\log\mathrm{KT}(x))$ and
   $\mathrm{KT}(x)=O(\mathrm{SIZE}^2(x)+\log|x|)$, with the definition of KT. Allender et al., ECCC
   TR02-028 (who credit Allender 2001).
4. The speed prior: Postulate 6.1, Definition 6.3, $S(x)\le2^{-Kt(x)}$, Theorem 6.1. Schmidhuber,
   arXiv:quant-ph/0011122.
5. $S_{Kt}(x)=\sum_{p\to x}2^{-|p|}/t(p,x)$; the loss bound of Theorem 9 with $D_n=O(\log n)$; Theorem
   12; the computability statements of the abstract. Filan, Leike, Hutter, arXiv:1604.03343.
6. The space-penalising prior $w\propto\beta^\ell$, Assumption 2 and Theorem 5 of Cohen, Vellambi,
   Hutter, arXiv:1905.12186.
7. The quoted hypotheses and the "speculative conjecture" on minimal circuits in Hubinger et al.,
   arXiv:1906.01820, as hypotheses.
8. Carlsmith's statements in arXiv:2311.08379, including footnote 239.
9. The anthropic-capture passage of Hubinger et al., arXiv:2302.00805, Section 2.5.
10. Theorem 1 of Cohen, Hutter, Bengio, Russell, arXiv:2410.06213.
11. Theorem 7 and the Discussion of Wyeth, Hutter, arXiv:2505.17882, and the fact that the paper does not
    treat resource-bounded priors or the malign-prior argument.
12. The abstract-level claims and equation (1) of Valle-Pérez, Camargo, Louis, arXiv:1805.08522, as an
    argument plus experiments.
13. The abstract-level claims of Mingard et al., arXiv:2006.15191 (empirical), arXiv:1909.11522 (the
    perceptron theorem $P(t)=2^{-n}$), arXiv:2304.06670 (empirical).
14. Buzaglo et al., arXiv:2402.06323: sample complexity $O(-\log\tilde p)$ and the abstract's statement
    of the main result.
15. Daxner et al., arXiv:1407.0501, Theorem 2.4 and equation (2): $P_n(f)=\Theta(n^{-L(f)})$ in the
    tree-size model, constants with probability bounded below.
16. Broutin, Mailler, arXiv:1510.06691, Theorem 4.2 (after checking the display).
17. Brodsky, Pippenger, arXiv:cs/0302028: growth processes tend to the uniform distribution on a set of
    functions, within $O(\log n)$ iterations for almost all processes studied.
18. Gay, He, Kocurek, O'Donnell, arXiv:2502.07159: the approximate $k$-wise independence statement of the
    abstract.
19. Devroye, Janson, arXiv:0906.0152: $S_n/\log n\to\sigma$ in probability.
20. Goldwasser, Kim, Vaikuntanathan, Zamir, arXiv:2204.06974: Theorems 2.1, 2.2, 2.3, 5.3, 5.4, 5.5, 5.7
    as quoted, and the depth-$\max(d,4)$ remark.
21. Christiano, Hilton, Lecomte, Xu, arXiv:2409.03077: Theorems 4.1, 5.5, 6.1, Corollary 5.2, Claim A.5,
    Corollary A.7, and the Section 7.3 remarks.
22. Kalavasis et al., arXiv:2406.05660 (abstract; the definition of indistinguishability obfuscation for
    equal-size circuits). Draguns et al., arXiv:2406.02619 (abstract).
23. Musat, arXiv:2605.10878, Theorem 4 and Corollary 7, with the words "preprint" and "as stated".
24. Scherlis, Belrose, arXiv:2501.18812: the statement of the volume hypothesis.

### B. May be cited "as stated in" the opened paper, or after checking the original

1. Valiant 1976: universal circuits of size $O(c\log c)$ and depth $O(c)$, within a constant factor of
   the information-theoretic lower bound; the edge-universal graph with $kn\lg n$ vertices (as stated in
   arXiv:0804.2429).
2. Cook, Hoover 1985: depth-universal circuits (as stated in arXiv:0804.2429).
3. Shannon 1949: $(1-\varepsilon)2^n/n<L(n)<2^{n+2}/n$; Lupanov 1958:
   $L(n)\le\frac{2^n}{n}(1+O(1/\sqrt n))$; Lutz 1992 (all as stated in ECCC TR05-032). The Shannon
   effect for almost all functions (as stated in arXiv:1407.0501).
4. Janson 2023: $|D_n|$ is of order $n^{(d-1)/d}$ with the stated limit law (as stated in
   arXiv:2606.30475).
5. Lefmann, Savický 1997 and Chauvin, Flajolet, Gardy, Gittenberger 2004:
   $\exp(-c_1L(f)\log k)\le P_k(f)\le\exp(-c_2L(f)k^{-3})$, improved to $k^{-2}$ (as stated in
   arXiv:1510.06691).
6. Kozik 2008: $P_k(f)=\Theta(k^{-L(f)-1})$ for fixed $f$ (as stated in arXiv:1510.06691, 1305.0651,
   1407.0501).
7. Chauvin, Gardy, Mailler 2011: binary-search-tree shapes give a degenerate distribution (as stated in
   arXiv:1510.06691).
8. Savický 1990 and Valiant 1984 on growth processes (as stated in arXiv:cs/0302028).
9. Dingle, Camargo, Louis 2018: $P(x)\le2^{-a\tilde K(x)-b}$ under the stated conditions, with no lower
   bound (as stated in arXiv:1910.00971 and arXiv:1805.08522).
10. Hubinger 2022: simplicity favours deception in the low path-dependence case (as stated in
    arXiv:2302.00805, Section 4.2); the notion of simplicity and the remark on the smallest model that
    fits the data (as stated in arXiv:2311.08379).
11. Christiano 2018: that the post exists and is the source of the minimal-circuit conjecture (reference
    [16] of arXiv:1906.01820).
12. Gowers 1996; Hoory, Magen, Myers, Rackoff 2005; Brodsky, Hoory 2008 (as stated in arXiv:2502.07159).
13. Chiang et al. 2022 and Teney et al. 2024 (as stated in arXiv:2501.18812).

### C. Must be marked as recalled from memory (not opened)

1. All constants for universal circuits: Valiant's $4.75$ and $5$ (and $19\,k\log k$ in gates);
   Kolesnikov, Schneider 2008 ($1.5\,k\log^2k+2.5\,k\log k$); Kiss, Schneider 2016; Lipmaa, Mohassel,
   Sadeghian 2016; Günther, Kiss, Schneider 2017; Zhao et al. 2019 ($4.5$, lower bound $3.64$); Liu et al.
   2021 ($3$, lower bound $2.95$); Alhassan et al. 2020. Also the titles, venues and author lists of
   these papers.
2. The $s!$ argument for the number of circuits up to isomorphism, and its textbook sources.
3. That Shannon's 1949 paper concerns contact networks, and the usual citation for Lupanov's gate-circuit
   theorem.
4. The content of Christiano's 2018 post beyond its title and its role as source of the conjecture: the
   daemon definition, the argument for "no", the obfuscation obstacle.
5. Everything about Hubinger's 2019 post "Are minimal circuits deceptive?".
6. The details of Hubinger's 2022 post beyond the restated sentences in B.10.
7. Everything about Christiano's 2016 post in relation to speed priors or resource bounds; in particular
   no claim about the speed prior may be attributed to it.
8. Kosoy's remarks (malign capacity, confidence thresholds); Wyeth's 2025 post; Xu 2020; the two forum
   posts on speed priors in 3.6; the ARC report in 4.10.
9. The depth of random recursive circuits (Tsukiji, Xhafa 1996; Arya, Golin, Mehlhorn 1999).
10. Results on partially defined Boolean functions (Sholomov, Andreev).
11. Venues not printed on an opened page: FOCS 2022 for 6.1, ITCS 2025 for 6.2, JMLR 2021 for 5.2, AAAI
    2020 for 4.3, COLT 2002 for the speed prior paper, Nature Communications 2018 for Dingle et al.

### D. Derived here, to be proved in the note if used

1. A universal circuit for circuits of size $s$ has at least $(1-o(1))\,s\log_2s$ gates (1.4).
2. Circuits with at most $s$ gates compute $2^{(1+o(1))\,s\log_2s}$ functions when
   $\log_2(s\log_2s)+1\le n\le s$; ordered gate lists number $2^{(2+o(1))\,s\log_2s}$ (2.5).
3. The cone of the output of a uniform gate list is distributed as Janson's descendant set (2.7).
4. The size-$s$ mass of a function is at least its size-$\sigma$ mass divided by $16(k+s-1)$ (pointer 5).
