# The feedback frontier: remote work is not remote working memory

Research memo, 2026-10-08. Intended for selective integration into the standalone report; the report itself has not been edited. Reproducible calculations: `calculate_feedback.py` and `feedback_results.json`.

## Suggested main-text passage

There is an additional resource between total work and sequential depth: **how many times the computation needs an answer from a distant place before deciding what to ask next**. Sending a program that returns one answer can use a much larger region than repeatedly consulting that same region as working memory. Independent queries can run in parallel; genuinely adaptive queries must wait for previous replies.

For a worker that stays at fixed comoving distance \(r\), each light-speed query and reply consumes \(2r\) of the remaining conformal light-travel budget \(L\). In the reference cosmology, \(L=16.68\) billion light-years. Ignoring processing and transmission duration, receiving \(k\) sequential answers requires

\[
2kr<L.
\]

Thus the available radius falls as \(1/k\), and a homogeneous accessible matter volume falls as \(1/k^3\). This is a special case of [Olson's cosmic conversation bound](https://arxiv.org/abs/2208.07871), with round trips counted instead of individual messages.

Long processing between messages makes the restriction stronger. In an exact de Sitter background, if every answer takes proper time \(\tau\), the light-speed deployment envelope becomes

\[
\boxed{r<\frac{c}{H}\,
\frac{\tanh(H\tau/2)}{e^{kH\tau}-1}.}
\]

When the total intervening computation spans many expansion times, the accessible radius shrinks exponentially, not merely as \(1/k\). A worker can have unlimited future proper time while having only a finite amount of time to compute an answer that reaches home. In the reference Lambda-CDM background, a fixed comoving worker initially one billion light-years away can complete at most eight light-speed query/answer cycles with instantaneous replies, or six if every reply requires a billion years of local computation.

These bounds apply to unbound workers carried apart by expansion. Bringing the relevant working state into one retained system changes the geometry. Alternatively, copying data, sending the whole program, or computing branches in parallel can remove some feedback dependencies, at costs in memory, work, or communication bandwidth. The universe limits a computation's spatial dependency structure, not just its FLOP count.

## 1. Setup and existing result

Use a flat FLRW metric, \(a(t_0)=1\), comoving spatial coordinates, and

\[
\eta(t)=\int_{t_0}^{t}\frac{dt'}{a(t')},\qquad
L=c\eta_\infty.
\]

Home and worker are comoving; their separation \(r\) is their present proper distance. We ignore peculiar motions, binding, gravitational potentials, hardware mass, finite bandwidth, and signal errors. A front at peculiar speed \(\beta c\) deploys the worker and carries its first query. The worker immediately transmits an answer after any required processing. Home immediately uses that answer to formulate the next query. Thus \(k\) answers require deployment plus \(2k-1\) subsequent one-way light messages.

[Olson (2022), equations (3)–(6)](https://arxiv.org/html/2208.07871), derives the existing zero-processing result using an integer \(n\) of alternating messages after deployment:

\[
r_n=\frac{\beta L}{1+\beta n},\qquad
V_n/V_0=(1+\beta n)^{-3}.
\]

Set \(n=2k-1\) to obtain

\[
r_k=\frac{L}{\beta^{-1}+2k-1}.
\]

These radii are **suprema**: equality puts the last reception at the infinite-future conformal boundary, which is not an event. Strictly smaller radii allow finite-time reception in this ideal zero-duration-message model. Relays cannot shorten the summed path length. Olson also explicitly distinguishes unbound systems from bound ones.

## 2. Extension: fixed proper-time computation between replies

This section is an independent extension of the preceding calculation, not a claim of literature priority. In exact de Sitter space set \(a(t)=e^{Ht}\), with \(t_0=0\). Define the **remaining conformal light distance**

\[
x(t)=c\int_t^\infty\frac{dt'}{a(t')}=
L e^{-Ht},\qquad L=c/H.
\]

A light signal across the fixed comoving distance consumes \(r\) from \(x\). A proper-time wait \(\tau\) at either comoving endpoint multiplies \(x\) by \(q=e^{-H\tau}\). These two rules fully specify the null-path calculation. For light-speed deployment, the remaining distance after each complete query, worker computation, and reply obeys

\[
x_{j+1}=q(x_j-r)-r,
\qquad x_0=L.
\]

Consequently,

\[
x_k=q^kL-(1+q)r\frac{1-q^k}{1-q}.
\]

The condition \(x_k>0\) gives the boxed formula above. A slower initial deployment consumes an additional \((\beta^{-1}-1)r\) before the repeated-query protocol begins. Hence the general envelope is

\[
\boxed{
r_k(\tau,\beta)=
\frac{L}{\beta^{-1}-1+
\coth(H\tau/2)(e^{kH\tau}-1)}.}
\]

All actual finite receptions require \(r<r_k\). In the limit \(\tau\to0\), this reduces to the existing zero-processing formula. If \(kH\tau\ll1\), processing is a small correction. For fixed positive \(\tau\) and \(kH\tau\gg1\),

\[
r_k\sim L\tanh(H\tau/2)e^{-kH\tau},
\qquad V_k\propto e^{-3kH\tau}.
\]

The deployment speed drops out of the leading large-\(k\) behavior because the long adaptive processing history dominates the conformal budget. This is a model of communication plus specified proper-time computation, not an assertion that a useful gate must take \(\tau\).

For one remotely computed answer,

\[
\tau<\frac1H\ln\!\left(\frac{L-r/\beta}{r}\right).
\]

Every nonzero unbound comoving distance therefore leaves a finite answer-returning processing window, despite infinite proper time along the worker's future worldline.

## 3. Numerical checks in the report's full reference cosmology

The exact de Sitter formula uses \(L=c/H_\Lambda=17.53\) Gly. It must not be combined with the present Lambda-CDM value \(L=16.68\) Gly while described as an exact formula. The accompanying script separately integrates the radiation+matter+Lambda expansion history and explicitly propagates every null leg and proper-time wait. It verifies the de Sitter closed form against its recurrence, the zero-processing limit, and monotonic shrinking with processing time.

With a light-speed first query or deployment envelope:

| Present comoving distance | Maximum complete answers, negligible processing | Maximum complete answers, 1 Gyr processing per answer | Maximum one-shot worker processing before final reply |
|---|---:|---:|---:|
| 10 million light-years | 833 | 67 | 129.76 Gyr |
| 100 million light-years | 83 | 30 | 89.31 Gyr |
| 1 billion light-years | 8 | 6 | 48.01 Gyr |

The maximum one-shot processing entries are suprema, with the final reply arriving ever later as the limit is approached. At 1 Gly, initial deployment at \(0.1c\) instead gives three complete instantaneous-answer cycles and a one-shot processing window of 33.27 Gyr. These are ideal homogeneous-background examples, not modeled trajectories of particular nearby galaxies.

Some feedback radii for the same full cosmology:

| Number of answers \(k\) | Negligible processing | 1 Gyr processing per answer |
|---|---:|---:|
| 1 | 8.340 Gly | 8.100 Gly |
| 10 | 0.8340 Gly | 0.6153 Gly |
| 100 | 0.08340 Gly | 0.001564 Gly |

**Small-distance caution:** the last 1.564 Mly entry is the formal homogeneous comoving envelope, not an expansion limit on actual resources within our bound Local Group. Extrapolating the formula to tiny distances without changing the worldlines would produce physically misleading conclusions. The same issue eventually affects any asymptotic exponential-volume statement about real clustered matter.

## 4. A scheduling corollary: communicate before long waits when dependencies permit

Suppose \(k\) queries require unequal worker computation times \(\tau_1,\ldots,\tau_k\), total \(T\). Define prefix times \(T_j=\sum_{i=1}^j\tau_i\). Repeated application of the same null-leg and wait rules gives the exact de Sitter boundary

\[
r_k=\frac{L}{\beta^{-1}+e^{HT}
                   +2\sum_{j=1}^{k-1}e^{HT_j}}.
\]

For fixed \(T\), putting more work into earlier rounds increases the prefix times and decreases the admissible radius. If the dependencies permit arbitrary redistribution of work among rounds, the largest radius comes from doing all expensive processing after the earlier communication:

\[
r_{\rm late}=\frac{L}{\beta^{-1}+2(k-1)+e^{HT}}.
\]

Doing it all in the first round instead gives

\[
r_{\rm early}=\frac{L}{\beta^{-1}+(2k-1)e^{HT}}.
\]

This does not authorize moving a necessary calculation after the answer that depends on it. It identifies an architectural incentive to gather information early and do long local processing later, if the algorithm allows that separation. It also shows why stating only total local computation time is insufficient: where that time lies along the communication dependency path matters.

## 5. Connection to a feasible-computation region

For a computation mapped to fixed comoving workers, each directed dependency path must obey a finite conformal budget. Null communication contributes the Euclidean comoving edge length; processing at a worker contributes \(c\int dt/a(t)\) over its actual execution interval. If a path starts now and ends at a finite future event, its sum is strictly less than \(L\). For a DAG with specified workers and proper-time processing requirements, earliest feasible node times can be calculated by taking the latest arriving prerequisite and then advancing by the node's proper duration. Fixed proper-duration processing and null arrival maps are monotone, so starting earlier cannot delay completion in this model.

This supplies an explicit test for the geometry part of a feasible region. It does not supply bandwidth, energy, storage, reliability, or assembly feasibility. Nor does it bound the number of local gates independently of their physical duration. An indefinitely continuing local process can occupy infinite proper time but a finite conformal interval, without completing infinitely many operations at any finite event.

Feedback depth is not message count. Arbitrarily many nonadaptive queries may share the same causal layer, subject to bandwidth and hardware. Conversely, even a one-bit adaptive reply forces a dependency. Transmitting the dataset, program, or a tree of possible future responses can trade space, work, and specification complexity for fewer remote rounds. Whether those trades are affordable belongs in the computational model.

**Attribution and confidence.** The zero-processing frontier and its volume scaling are Olson's existing result. The equal- and unequal-proper-time formulas are transparent extensions derived here and checked against explicit null-path propagation; no priority claim is made. They apply to prescribed unbound comoving workers in the stated backgrounds. They are not bounds on all possible gravitational engineering, moving processors, or retained fuel-fed machines.
