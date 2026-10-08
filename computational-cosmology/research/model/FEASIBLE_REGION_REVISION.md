# Sharpening the feasible computation region

Prepared for the computational-cosmology revision, 8 October 2026. This memo supplies publication-ready text, an explicit solved hardware model, and an optional cosmological consequence. It does **not** certify an ultimate physical gate budget. The script `analysis/feasible_region.py` and its JSON output reproduce the normalized figure `figures/hardware-feasible-region.{png,svg}`.

## 1. From a resource list to a testable feasible region

The task must specify its inputs and their locations, the desired output or internal process, the output location, allowable error, and a deadline. Fix a finite instruction alphabet and an architecture whose processors, memories, channels, controllers, clocks, and repair systems have quantitative contracts. A contract states capacities, valid operating ranges, operation durations, energy and entropy costs, and failure bounds. In curved spacetime it also identifies the clocks used to measure durations.

For a compiled circuit or adaptive protocol, ask whether there exists a placement and schedule that meets those contracts. The schedule must keep every required datum alive, route every dependency, respect channel capacity and causal arrival, and have sufficient work and entropy resources **at each stage**, not just in the final sum. It must also fit the program, input, live state, controller, and retained output into the specified storage. A short program may generate a long execution; the generated instructions and their controller are still physical operations. This is a concrete constraint problem once the hardware contracts are supplied. It is not yet a complete characterization of which contracts nature allows.

There are then two distinct kinds of result:

- **Outer bound:** use physical or architecture-specific *lower* bounds on duration and resource cost to exclude schedules.
- **Conditional inner bound:** exhibit a full schedule using primitives with justified *upper* bounds on duration, cost, and error. This is sufficient inside the specified architecture model. A proposed futuristic primitive is not an experimentally demonstrated cosmic computer.

For a simple static architecture with $P$ processors, each executing at most $r$ compiled operations per second, useful outer relaxations include

$$t\geq L_0\equiv\max\left\{\frac{W}{Pr},\frac{D}{r},L_{\rm dep},\max_K\frac{Q_K}{C_K}\right\}.$$

Here $W$ is compiled work, $D$ is compiled dependency depth, $L_{\rm dep}$ includes propagation along dependent paths, and $Q_K/C_K$ is the duration needed to convey the required information across a communication cut with capacity $C_K$. Routing, control, fault correction, and communication coding must either already be included in the compiled job or added explicitly. For variable capacity replace $Q_K\leq C_Kt$ by $Q_K\leq\int_0^t C_K(s)ds$. For genuinely parallel output requirements, or quantum channels with assistance, use the relevant information-transmission task and channel capacity rather than treating every signal as a freely compressible classical bit string.

If the chosen implementation necessarily maintains $q$ protected memory units throughout its execution, constant entropy costs $h$ per compiled operation and $\gamma$ per protected memory-unit second give

$$B\geq hW+\gamma qt+B_{\rm other}\geq hW+\gamma qL_0+B_{\rm other}.$$

Entropy budgets are expressed in units of $k_B\ln2$ throughout. Crucially, **peak workspace alone does not imply the $qt$ term**: the actual quantity is the integral of live protected storage, $\int q(t)dt$. A large archive that is switched off, compressed, passively retained, or reconstructed can have different costs. The lifecycle extends until the result is delivered under the task's contract; a result required to remain available until a later deadline must be maintained until then.

For a proposed schedule with protected logical-location failure bounds $p_j$, channel error bounds $\epsilon_e$, and storage-error contribution $\epsilon_{\rm store}$, the conservative sufficient reliability condition is

$$\sum_jp_j+\sum_e\epsilon_e+\epsilon_{\rm store}\leq\delta.$$

This union bound does not require independence. It is a sufficient reliability test, not a universal necessary condition. The physical construction is incomplete if its primitive error guarantees cannot be sustained with the counted finite equipment.

Aggregate $(W,D,q)$ cannot decide feasibility: two circuits with the same counts can have different communication cuts, spatial inputs, and dependence on distant memories. One may admit mostly local processing while the other repeatedly waits for information from opposite sides of the system. Conversely, independent remote jobs may count as successful distributed experiences even when their outputs cannot later be reunited.

**Useful implementation comparison.** In a homogeneous communication-free unit-task model, work/span scheduling gives a completion time of order $W/P+D$; [Brent's original paper](https://doi.org/10.1145/321812.321815) makes this sort of processor–time tradeoff precise. Its role here is limited: a cosmic implementation must first pay for its wires and routing. A direct construction on a nearest-neighbor chain is possible for any specified finite one- and two-register circuit: bring target registers together by adjacent swaps, apply the gate, and undo the swaps. For $q\geq2$ data registers, a two-register gate needs at most $2(q-2)$ swaps plus the gate itself. Clocking, instruction decoding, controller storage, error correction, and the elementary implementation of a swap must then be added. This crude construction shows how a sufficient schedule can be built without pretending that arbitrary long-distance gates are free. It does not promise that a cosmological workload fits the resulting budget.

## 2. A solved serial-depth frontier

Suppose a serial core performs $D$ protected primitives, with durations $\tau_1,\ldots,\tau_D$, while keeping $q$ protected memory units live. Include the working state, controller, and clock protection in $q$ or charge them separately. Let the dynamic entropy cost of a primitive be

$$h(\tau)=h_0+\frac{a}{\tau},$$

and let memory maintenance produce entropy at rate $\Gamma=\gamma q$. Here $a$ has units of entropy-bits times seconds, $h_0$ is entropy-bits per primitive, and $\Gamma$ is entropy-bits per second. The dynamic cost excludes maintenance, so it is not counted twice. This is a hardware model over a stated range of durations, not a theorem about every possible logic gate. Finite-time thermodynamic models with inverse-duration dissipation are studied by [Konopik et al.](https://www.nature.com/articles/s41467-023-36020-2). A strictly positive maintenance coefficient is an extra assumption.

For total execution time $t=\sum_j\tau_j$, Cauchy's inequality gives

$$B_{\rm req}=h_0D+a\sum_{j=1}^D\tau_j^{-1}+\Gamma t
\geq h_0D+\frac{aD^2}{t}+\Gamma t.$$

Equal-duration primitives attain the displayed bound **inside this ideal contract model**, provided that the required durations and error rates lie within its valid operating range. If $h(\tau)$ is only a cost lower bound, the expression is only an exclusion bound; if it is an implementable cost upper bound, equal timing supplies a conditional feasible schedule after the other constraints are met. Initialization, readout, routing, and acquisition costs must first be reserved from $B$.

The clean $h_0=0$ case has an explicit answer. Treat depth continuously in the following frontier; round down for an integer primitive count. If the task may deliver and finish at any $t\leq T$, with no minimum-tick constraint binding,

$$D_{\max}(B,T)=
\begin{cases}
\sqrt{(BT-\Gamma T^2)/a}, & T\leq B/(2\Gamma),\\
B/(2\sqrt{a\Gamma}), & T\geq B/(2\Gamma).
\end{cases}$$

An extra deadline allowance initially helps by allowing slower, less dissipative operations. Beyond $T_*=B/(2\Gamma)$ it does not help: the optimal machine delivers earlier rather than paying additional maintenance. At saturation the primitive duration is $\tau_*=\sqrt{a/\Gamma}$, and dynamic dissipation and maintenance each consume half the budget. If output storage is required until the deadline, its later maintenance must be added, so this plateau is not a free promise of indefinitely preserved output.

With an irreducible cost $h_0\geq0$ and minimum allowed duration $\tau_{\min}$, the exact one-dimensional optimization is

$$D_{\max}(B,T)=\max_{\tau\geq\tau_{\min}}\min\left\{\frac{T}{\tau},\frac{B}{h_0+a/\tau+\Gamma\tau}\right\},$$

restricted further by any maximum duration or finite range of primitive validity. For $h_0=0$, setting $x=\Gamma T/B$, $y=2\sqrt{a\Gamma}D/B$, and $u=\tau_{\min}\sqrt{\Gamma/a}$ yields the plotted frontier. If $0<u<1$, then $y=2x/u$ until $x=u^2/(1+u^2)$, then $y=2\sqrt{x(1-x)}$ until $x=1/2$, then $y=1$. If $u\geq1$, $y=\min\{2x/u,2/(u+1/u)\}$.

For example, constant protected gate failure $p_g$ and storage failure rate at most $\lambda$ per memory-unit second give the additional sufficient reliability target

$$Dp_g+\lambda qt+\epsilon_{\rm I/O}\leq\delta.$$

Such reliability guarantees may require larger $q$, different $a$, or more maintenance; the coefficients cannot be optimized independently when the architecture couples them. The figure intentionally assumes these separate constraints already pass.

### Consequence: a persistent-memory versus depth law

If the primitive's dynamic coefficient $a$ stays fixed while the amount of persistent memory changes, minimizing over runtime gives

$$B\geq2D\sqrt{a\gamma q},\qquad
\boxed{qD^2\leq\frac{B^2}{4a\gamma}}.$$

Thus, in this model, quadrupling the persistently maintained state halves the maximum achievable serial depth even with unlimited deadline. This is not a statement about memory capacity alone: it arises because larger *live* memory makes the slow-computation option more expensive. Reversible checkpointing and selective archives can move a workload to another part of this frontier by changing the live-memory integral.

For a specified depth and deadline, the maximum persistent memory is

$$q_{\max}(B,D,T)=\max_{0<t\leq T}\left(\frac{B}{\gamma t}-\frac{aD^2}{\gamma t^2}\right)_+.$$

The optimizing runtime is $t=\min\{T,2aD^2/B\}$, when a positive feasible memory budget exists. This is panel B of the figure. The universal-memory interpretation would be invalid if $a$ or $\gamma$ changed with $q$ in a way not included in the contract.

**Suggested figure caption.** A solved feasibility frontier for the illustrative entropy model $B_{\rm req}=aD^2/t+\gamma qt$. A: at fixed persistent memory, more allowed time improves depth only up to a finite optimal runtime; minimum gate durations reduce the frontier. B: keeping more state alive competes with achieving greater depth, with $qD^2\leq B^2/(4a\gamma)$ for an unlimited deadline and fixed hardware coefficients. $\Gamma=\gamma q$, $\Gamma_{\rm ref}=\gamma q_{\rm ref}$, and $D_{\rm ref}=B/(2\sqrt{a\gamma q_{\rm ref}})$. Points under the curves pass this model's entropy constraint; actual feasibility also requires the stated primitive, capacity, causality, work, specification, and error contracts. The figure is dimensionless and makes no numerical estimate of ultimate cosmic hardware.

## 3. Optional consequence: an entropy-limited return radius

Communication waiting can consume entropy even if no gates run. This gives an elementary connection to the cosmological part of the report. In exact de Sitter expansion, let $a(t)=e^{Ht}$, let an outbound front travel at constant peculiar speed $\beta c$, and let it immediately return a light signal to the origin upon reaching a target. The maximum initial comoving radius with a possible return is

$$r_{\rm ret}=\frac{\beta c}{(1+\beta)H}.$$

For $0\leq r<r_{\rm ret}$, integrating the two null/travel legs gives

$$t_{\rm return}(r)=-H^{-1}\ln\left(1-\frac{r}{r_{\rm ret}}\right).$$

If the origin must maintain a fixed protected state throughout this wait at entropy rate $\Gamma$, and only $B_{\rm wait}$ entropy units are allocated to waiting, then

$$\boxed{r\leq r_{\rm ret}\left[1-\exp\left(-\frac{HB_{\rm wait}}{\Gamma}\right)\right].}$$

The available radius can therefore be well inside the geometric return radius. If $HB_{\rm wait}/\Gamma=0.1$, only about $0.086\%$ of the homogeneous mass inside the geometric return sphere meets this maintenance budget; at $1$ the fraction is $25.3\%$, and at $3$ it is $85.8\%$. These fractions are $(1-e^{-u})^3$. This is a hardware and workload restriction, not a new event horizon. Storing the question more cheaply, restarting from a short specification, or choosing a different output contract can change it. Finite processing time, finite bandwidth, acquisition cost, and incoming-message protection further tighten the simple example.

The same point appears without cosmology: offloading work that saves $\Delta B$ entropy but introduces latency $L$ is not beneficial for the fixed-live-state architecture unless $\Delta B$ exceeds $\Gamma L$ plus communication overhead. Maximizing raw returned energy or raw remote operations need not maximize useful computations delivered to a maintained recipient.

## 4. Relation to the other new material

The thermodynamics agent's checkpointing construction gives an explicit *inner family*: finite blocks can trade temporary history storage against reset count and maintenance. It complements this memo's analytic duration frontier rather than duplicating it. Treat its primitive contracts just as explicitly.

The specification counting argument is also complementary. For deterministic pure outputs selected by at most $P$ classical control bits, Haar coverage by trace-distance balls of radius $\epsilon$ is at most $2^P\epsilon^{2(2^n-1)}$. Root's mixed-output repair is valid: choose one pure target representative per nonempty ball, and triangle inequality bounds its other pure targets within radius $2\epsilon$ of that representative. Thus the general bound $2^P(2\epsilon)^{2(2^n-1)}$ is safe for $\epsilon<1/2$, with different numerical constants. These concern selected arbitrary targets; they do not bound physical qubit count, supplied unknown inputs, or short-description structured states.

## Sources and validation

- [Konopik, Korten, Lutz & Linke (2023), *Fundamental energy cost of finite-time parallelizable computing*](https://www.nature.com/articles/s41467-023-36020-2): primary motivation for finite-time inverse-duration dissipation models. The maintenance-limited depth, memory, and return-radius derivations above are additional explicit calculations, not attributed to this paper.
- [Brent (1974), *The Parallel Evaluation of General Arithmetic Expressions*](https://doi.org/10.1145/321812.321815): work versus span scheduling in the ideal parallel model.
- [Bennett (1989), *Time/Space Trade-Offs for Reversible Computation*](https://doi.org/10.1137/0218053): why reversible simulation requires a time–space–garbage tradeoff, rather than making all ancillary resources disappear.
- [Portmann et al., *Causal Boxes*](https://arxiv.org/abs/1512.02240): a rigorous causal composability framework on which a physical contract model can draw.
- [Jordan (2017), *Fast quantum computation at arbitrarily low energy*](https://arxiv.org/abs/1701.01175): reason not to replace the architecture-specific rates by an alleged universal energy-per-gate theorem.

The figure code independently checks the closed-form depth frontier against 360 scalar optimization cases, including active minimum-tick constraints, and checks the memory frontier by substitution into the budget. Maximum normalized optimizer discrepancy was below $8\times10^{-9}$. These are checks of the stated model and its algebra, not experimental validation of a futuristic hardware family.
