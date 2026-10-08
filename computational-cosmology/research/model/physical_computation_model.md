# A resource model for computational cosmology

Research memo, 8 October 2026. This is a proposed synthesis and several elementary deductions, not a claim that a complete characterization of physically realizable computation is known. Public sources are linked at the claims they support; a compact source ledger follows the memo.

## The main recommendation

Do not characterize the future universe by one number of operations. Characterize a **set of implementable, causally embedded, error-controlled computations**, with an explicit rule for where the answer or the valuable process must occur. A useful resource vector is

\[
\mathcal R=(B_{\rm cl},B_{\rm q},\mathcal A,W,\Sigma,\{C_{ij},L_{ij}\},\tau_{\rm life},K_{\rm program},\epsilon).
\]

Here the entries are classical memory, coherent quantum memory, available energy–time action, usable work, entropy-disposal capacity, communication bandwidth and latency, reliable lifetime, controllable specification length, and allowed error. These resources are not independent, and their upper bounds are not in general simultaneously achievable.

The largest conceptual correction to the preceding foom–coom model is that **a finite budget of irreversible bit erasures is not a finite budget of all logical gates**. A second correction is that **one region's aggregate transition rate is not the speed of one arbitrarily deep computation**. A third is that **computations running in many places need not be processors of a single computer**.

## 1. What counts as having run the computation?

A task should specify four things:

1. A program or input–output relation, including the admissible inputs and the precision of the answer.
2. Where and when the input becomes available.
3. Where and when the output must be available, or alternatively where a valuable ongoing process must be instantiated.
4. An acceptable error probability or trace-distance error, and a reliability period for the result.

The distinction in item 3 is substantial. A trillion isolated simulations can have value even if no observer can ever collect their results. They cannot necessarily act as a trillion cores solving a problem that requires repeated mutual communication. An unknown quantum input has additional restrictions beyond a classical input: Kent's no-summoning theorem shows that, in relativistic quantum theory, some tasks asking for the state at a later, contingently selected location are impossible even with enormous local computational resources. The obstruction combines no-cloning and no-signalling. [Kent, 2013](https://arxiv.org/abs/1101.4612)

A robust task definition should also exclude post hoc interpretations under which any complicated physical motion is declared to have computed a desired answer. Count the cost of encoding, controlling, and decoding. Require the apparatus to implement the stated relation across the promised family of inputs, rather than fitting an arbitrary interpretation to one accidental trajectory. A thermal fluctuation that happens to spell the answer is not a reliable implementation of a specified algorithm.

For subjective experiences or simulated worlds, an external readout may be unnecessary. The task contract then describes the internal causal process, not merely a final string. That distinction matters both physically and ethically: producing the same final record by a shortcut is not automatically the same task as instantiating the entire intervening history.

## 2. A proposed parallel machine

Start from a spacetime and its matter state on the present slice. It is adequate for many estimates to use an expanding FLRW background with bound, approximately stationary islands; genuinely large rearrangements require solving for the changed gravitational field.

An architecture consists of local processor worldtubes. Each has a controllable memory, a local clock, a finite gate set, a noise model, a supply of usable work or purity, and an entropy outlet. Directed communication channels connect the worldtubes along causal paths. The channels have finite capacity and may close permanently as regions become causally separated. Fuel, apparatus, clocks, control information, and repair systems are all physical resources in the architecture.

A circuit is a directed acyclic graph of local operations and causal messages. Gate placement must respect both the logical dependencies and the available hardware. For adaptive computations, this is a family of such graphs indexed by previous classical outcomes. Quantum circuits have local quantum channels on the wires, classical feed-forward, and no uncharged copying of unknown states. Use a fixed finite universal gate set, with approximation error included in the task contract; otherwise one could hide an arbitrarily complex answer in a continuously specified gate.

This is an engineering specialization of existing work on relativistic information processing, rather than a wholly new foundational formalism. The **causal boxes** framework already supplies a composable model of quantum information-processing networks, including timed messages and relativistic protocols. It is richer than needed here because it can also represent superpositions of causal structures. [Portmann et al., 2017](https://arxiv.org/abs/1512.02240)

Define the feasible set \(\mathfrak F_{\epsilon}(I,O)\) as the tasks that some allowed architecture can implement with inputs at \(I\), outputs or experiences at \(O\), and total error at most \(\epsilon\). The practical research objective is to put **constructive inner bounds** and **physical outer bounds** on this set. A list of necessary inequalities gives only an outer bound. It does not establish that a design saturating all of them exists.

### A causal restriction with large consequences

Let \(I\) be the region from which we can issue new instructions today. Any new computation controlled by those instructions and contributing to an answer at an event \(o\) must lie in

\[
J^+(I)\cap J^-(o).
\]

For an answer received at any finite time along a receiver worldline \(\gamma\), replace \(J^-(o)\) by the union of the causal pasts of its future events. A one-way colony does not need to lie in that return region to run its own computations. This cleanly separates **what we can cause**, **what can return a result**, and **what can remain in repeated communication**.

In a flat FLRW spacetime, a radial causal message obeys \(|d\chi|\le c\,dt/a(t)\). If the future conformal-time interval is finite, the available *comoving communication distance* is finite even though proper time can be infinite. For an ideal light-speed outward instruction followed by a returning light signal to the original comoving worldline, the maximal round-trip comoving radius is half the remaining one-way conformal distance. More generally, if deployment is at fixed peculiar speed \(\beta c\) and the reply is light-speed, it is \(\beta/(1+\beta)\) of that distance, before allowing any processing delay. These are elementary causal-geometric deductions, not harvesting-efficiency estimates.

## 3. The inequalities worth carrying through every estimate

### 3.1 Memory: distinguishable states, not entropy of the particular data

If a device can reliably hold any of \(2^B\) classical messages, it needs \(B\) distinguishable bits. Its actual logical state may be pure or fully known; the relevant quantity for capacity is the logarithm of the available distinguishable state space, not the thermodynamic entropy of that particular pure state.

For an appropriate complete, bounded, weakly gravitating system of energy \(E\) and effective radius \(R\), the Bekenstein bound gives the familiar outer envelope

\[
B\lesssim {2\pi ER\over\hbar c\ln2}.
\]

Its use requires care about the complete system, its container, the definition of energy, and vacuum contributions. It should not be treated as a universal elementary formula for arbitrary subregions of quantum field theory. [Bekenstein, 1981](https://doi.org/10.1103/PhysRevD.23.287)

For a roughly spherical gravitating system, combining the corresponding non-collapse scale with this entropy scale gives

\[
B\lesssim {A\over4\ell_P^2\ln2}={\pi R^2\over\ell_P^2\ln2}.
\]

In general curved spacetimes, area-based entropy statements are properly formulated with light-sheets and appropriate hypotheses, rather than arbitrary spatial volumes. These are powerful bounds, but saturation by externally usable, programmable memory is a separate question. A horizon entropy is not an engineering specification for RAM. [Bousso, 1999](https://arxiv.org/abs/hep-th/9905177)

For quantum computation, a controllable \(B\)-qubit device has a state space of dimension \(2^B\), but that does not make it an accessible classical memory for \(2^B\) bits. The Holevo bound constrains the classical information recoverable from an encoded quantum ensemble. Count any pre-shared entanglement and classical communication separately. [Holevo, 1973](https://www.mathnet.ru/php/archive.phtml?jrnid=ppi&option_lang=eng&paperid=903&wshow=paper)

### 3.2 Speed: action, not consumed fuel

For a closed system with the relevant Hamiltonian and mean energy \(E_{\rm act}\) above its ground state, orthogonalization takes at least

\[
\tau_\perp\ge {\pi\hbar\over2E_{\rm act}}.
\]

This is a speed limit on physical state evolution. It does not say that each gate consumes \(E_{\rm act}\), or that all the rest energy of an object is available as a controllable gate interaction. [Margolus and Levitin, 1998](https://arxiv.org/abs/quant-ph/9710043)

For the usual idealized decomposition into independently counted, orthogonalizing operating subsystems, the resulting aggregate bound has the form

\[
G_\perp\lesssim {2\over\pi\hbar}\sum_i\int E_{{\rm act},i}\,d\tau_i.
\]

In curved spacetime, use local proper times and appropriately defined local energies; do not assume a unique globally conserved cosmological energy. An observer-time expression includes the proper-time lapse factors. Nor should arbitrary tiny rotations be counted as separate full-strength logical operations.

**Critical warning about Lloyd:** his aggregate \(2E/(\pi\hbar)\) transition rate, the maximum-memory estimate, and a processor's causal depth are different quantities. In the black-hole discussion, the average per-bit time is proportional to \(\hbar B/E\), comparable to a horizon-crossing time. The phrase “serial” in that discussion does not turn the aggregate gate rate into the speed of one arbitrary dependency chain. The paper itself qualifies whether the limiting architectures can be controlled or attained. [Lloyd, 2000](https://arxiv.org/html/quant-ph/9908043)

This qualification is substantive. Jordan constructs local, time-independent Hamiltonian models whose computational clock speed becomes arbitrarily large relative to both mean energy and energy uncertainty as the computation length increases. The model does not violate the state-orthogonalization theorem; it invalidates the unrestricted inference from that theorem to a universal gate-rate bound. Limits on density, communication and controllability must be added. Thus the quantity above should be labelled an orthogonal-transition or architecture-dependent action budget, not a proven count of every possible useful quantum gate. [Jordan, 2017](https://arxiv.org/abs/1701.01175)

A constant nonzero operating energy integrated over infinite proper time has infinite action. Therefore a finite mass–energy reservoir, by itself, does **not** make the above integrated rate bound finite. A claimed lifetime gate bound needs additional assumptions about dissipation, noise, usable lifetime, clocking, stability, or the definition of valuable computation.

### 3.3 Entropy and work: erase only what is actually discarded

Resetting an unbiased bit against a thermal bath at temperature \(T\), under the usual conditions, requires at least \(k_BT\ln2\) of work and exports the associated entropy. A work budget \(W\) consequently supports at most \(W/(k_BT\ln2)\) such resets in the ideal reversible limit. This is not a universal cost per logical gate. Finite reservoirs, correlations, and non-equilibrium resources need explicit accounting; even the standard bound has finite-reservoir corrections. [Reeb and Wolf, 2014](https://arxiv.org/abs/1306.4352)

More generally, track how much entropy can be deposited in accessible sinks, and track the transformations used to convert fuel and existing low-entropy resources into that capacity. Do not count a pure memory bank, the work obtainable by randomizing it, and its capacity to absorb the same entropy as three separate resources. The relevant entropy can be conditional on information retained elsewhere.

Logical reversibility allows an input-preserving computation to retain or later uncompute intermediate information. Bennett's compute–copy–uncompute construction establishes this at the algorithmic level. It does not, by itself, supply robust, finite-speed, cosmologically durable hardware. [Bennett, 1973](https://www.cs.princeton.edu/courses/archive/fall04/cos576/papers/bennett73.html)

The memory cost is not necessarily a complete stored history of every gate. Reversible pebbling trades storage against recomputation; for example Bennett gives simulations using time \(O(T^{1+\delta})\) and space \(O(S\log T)\) for any fixed \(\delta>0\). Thus an enormous ratio of logical gates to entropy disposal is not ruled out merely by invoking finite memory. [Bennett, 1989](https://doi.org/10.1137/0218053)

### 3.4 Depth and communication

For an approximately static architecture, a transparent necessary inequality is

\[
T_{\rm job}\ge\max_{p\in\text{causal paths}}
\left[\sum_{v\in p}\tau_v+\sum_{e\in p}{\ell_e\over c}\right].
\]

The sum includes processing times and data transport, with the corresponding causal propagation law used in curved spacetime. Parallel resources can reduce elapsed time only to the extent that the task admits independent work. A circuit DAG's depth is a constraint on that implementation; proving that *every* algorithm for an input–output problem needs that depth is a separate complexity-theoretic question.

Each spatial cut also has a bandwidth budget. If a task requires transferring \(Q\) independent bits across a cut, \(Q\) cannot exceed the channel capacity integrated over the time during which the relevant communication remains possible. The capacity depends on signal energy, modes, noise, aperture, and duration; a speed-of-light latency bound is not itself a bandwidth bound. Existing quantum communication limits provide the appropriate literature rather than an assumption of free all-to-all wires. [Bekenstein and Schiffer, 1990/2003 preprint](https://arxiv.org/abs/quant-ph/0311050)

### 3.5 Reliability

For a circuit of \(G\) locations, a simple sufficient condition is logical error probability per location \(p_L\le\epsilon/G\), from a union bound. If errors are independent and every error is fatal, the exact success probability is \((1-p_L)^G\). These conditions concern logical errors after protection, not bare physical errors. A billion independent short jobs also need not each satisfy the reliability target of one giant monolithic job.

Fault-tolerance theorems show that arbitrarily long computations can be protected below suitable noise thresholds with overhead growing with the target computation size and accuracy. “Arbitrarily long” here means an architecture family that can use growing resources, not infinite reliable computation in one fixed finite device. [Aharonov and Ben-Or](https://arxiv.org/abs/quant-ph/9611025)

Error correction transfers entropy into ancillas or syndrome records; eventual disposal belongs in the budget. The entropy rate is not generally exactly one bit per error: it depends on the distribution and correlations of the noise and retained information. [Nielsen et al., 1998](https://arxiv.org/abs/quant-ph/9706064)

For long idle periods, storage errors and apparatus decay can matter more than errors per logical gate. Passive protection can give large lifetimes and should not be excluded by fiat. In particular, a May 2026 preprint constructs a geometrically local 3D stabilizer-Hamiltonian family with exponentially long memory lifetimes at nonzero temperature. This is an idealized model result, not an indefinitely stable finite universal computer. [Balasubramanian, Davydova and Lin, 2026](https://arxiv.org/abs/2605.10943)

## 4. Two compact deductions

### 4.1 Global memory has a minimum communication scale

Suppose a computer must keep \(B\) independently distinguishable bits simultaneously and each of its global synchronization rounds really requires communication across its enclosing diameter. Using the area bound above,

\[
R\gtrsim\ell_P\sqrt{{B\ln2\over\pi}},\qquad
\tau_{\rm round}\gtrsim 2t_P\sqrt{{B\ln2\over\pi}}.
\]

Consequently, for \(D_{\rm global}\) such rounds completed within time \(T\),

\[
D_{\rm global}\sqrt B\lesssim {\sqrt\pi\over2\sqrt{\ln2}}{T\over t_P}.
\]

This is our elementary combination of a conditional memory bound and causality. Here R must describe the actual spatial extent of the stored, independently addressable working information, and the dependency under discussion must actually propagate across a diameter of that extent. It is not legitimate to enclose a tiny core in an arbitrarily large empty sphere and infer a large latency from that chosen sphere. An implementation using only a radius-scale dependency has the same formula without the factor two: for B=10^122 its optimistic lower scale is about 8 billion years. It is **not** a general gate-depth theorem: a sequential program using a small local working set need not communicate across all its fuel or storage on every step. It is also optimistic, since a physically useful computer may be very far from saturating the gravitational entropy bound.

For orientation, the lower limit is approximately \(5.1\times10^{-44}\sqrt B\) seconds per diameter-crossing round. With \(B=10^{100}\), that is about two months; with \(B=10^{120}\), about 1.6 billion years. These are not predictions of actual processor speed. They illustrate why “near-universe-sized memory, globally synchronized every tiny timestep” is a qualitatively different ambition from many small computers.

At fixed energy, the weak-gravity Bekenstein expression gives a related bound,

\[
\tau_{\rm round}\gtrsim {B\hbar\ln2\over\pi E}.
\]

The actual geometry and the definition of a synchronization round determine order-one constants. Near horizons, gravitational time dilation makes a naive flat-space saturation argument still less trustworthy.

### 4.2 Fuel need not fit inside the processor

The user's apparent choice—put all the matter in a tiny computer and make a black hole, or leave it dispersed and lose it—omits an architecture class. A compact processor can be fed gradually from an extended, retained fuel reservoir. The total fuel inventory does not have to be present in the active logic at once. Waste entropy can leave the processor as fuel arrives.

This trades simultaneous mass concentration for storage lifetime, delivery losses, finite collection reach, and entropy-outlet constraints. It can in principle support a long narrow computation using much more total fuel than the core's own mass. It does not rescue matter that never enters the relevant causal delivery region, and it does not give a proof that a large fraction of all reachable cosmic negentropy can be concentrated into one reliable computation. The useful research question is the **achievable cumulative entropy disposal and lifetime of a causally supplied core**, not merely its instantaneous mass.

Moving the computational state between processors is another option, but transferring a large working memory consumes bandwidth and latency, and unknown quantum states cannot simply be cloned into all successor machines. Repeated migration also does not by itself evade horizons.

## 5. Why a finite entropy budget does not give a simple finite gate budget

A useful extreme is the reversible Brownian computation. Its legal configurations form a path. A random walk can explore that path and eventually reach the end, with no fixed heat cost for each unbiased forward or backward move. In a modern first-passage/resetting analysis, the thermodynamic reset cost scales logarithmically with the path's state-space size while the mean completion time scales quadratically. The controller and resetting protocol are essential parts of this accounting. [Utsumi, Golubev and Peper, 2023](https://arxiv.org/html/2304.11760)

A simple equilibrium illustration is a legal path with \(L\) nonterminal states at energy zero and one terminal state at energy \(-\Delta\). Its equilibrium terminal probability is

\[
p_f={e^{\Delta/(k_BT)}\over L+e^{\Delta/(k_BT)}}.
\]

To make \(p_f\ge1-\epsilon\), choose

\[
\Delta\ge k_BT\ln\!\left[{L(1-\epsilon)\over\epsilon}\right].
\]

This elementary calculation displays a logarithmic free-energy scale for endpoint stabilization, not a linear \(Lk_BT\) scale. It is **not** a full cosmological construction: one must create the legal-state network without already knowing the answer, wait for completion, stabilize it against off-path errors, count the reset and readout, and provide the required memory. Exact zero error would require an infinite trap depth in this toy model. A finite error contract avoids that unphysical demand.

The right conclusion is neither “infinite useful computation is achievable” nor “there are exactly \(10^{120}\) gates left.” It is that the achievable relation among logical work, entropy production, time, memory, and reliability remains an essential modeling choice. The Brownian example is a good adversarial test for any proposed universal gate bound.

An autonomous deterministic machine with exactly \(B\) classical state bits **including its entire controller, clock, program position and retained input** has only \(2^B\) states. If it repeats a complete state, it cycles; therefore it cannot make more than \(2^B\) distinct state visits without extra state or input. But that exponential counting observation is not a \(B\)-gate limit, and cycling is not the same as no ongoing physical evolution or no repeated experience. Quantum amplitudes and analog coordinates add further distinctions between exact mathematical states and operationally distinguishable states. Neither argument settles the metaphysics of repeated minds.

## 6. Specification complexity

There are three different limitations here.

**Programmable alternatives.** A controller with \(P\) independently specifiable binary settings selects at most \(2^P\) configurations. If a task means “print this particular independently chosen, incompressible \(n\)-bit string,” its specification or input must carry approximately \(n\) bits. Unlimited runtime does not replace those controllable input distinctions. If the target was chosen only after seeing random output, that is a different task.

**Description length is not output length.** A short program can calculate a vast number of digits of pi. For deterministic halting computations, conditional on the physical laws and supplied input, the algorithmic information in the output is bounded by the program's description length plus a machine-dependent constant. Random or measured inputs can supply additional information, but then count them as inputs. Low description complexity does not imply fast execution: a short program can take an enormous time or fail to halt.

**Description length is not working memory.** A huge structured state may be compactly describable but costly to access or update in compressed form. A computational task can require a large live working set even if the program is tiny. Conversely, a short streaming computation can emit an output much larger than its working memory only if there is somewhere for that output to go. Include the output archive or receiver in the physical system when its simultaneous availability matters.

For a fixed finite gate alphabet and bounded gate arity, the number of circuits of length \(G\) on \(B\) wires is at most roughly \((cB^k)^G\). The description of an arbitrary such circuit therefore takes order \(G\log B\) bits; structured circuits may have much shorter generating programs. Generic \(B\)-qubit states require exponentially large classical specifications at fixed accuracy, though a naturally supplied unknown quantum state can be manipulated without first learning that specification. This is another reason not to equate Hilbert-space dimension with programmable classical information.

Kolmogorov complexity is an informative distinction, not a computable feasibility oracle. There is no general algorithm that, given an arbitrary program, decides all the physical resources its terminating execution will need: even the simpler halting problem obstructs such a universal decision procedure. A feasible-region theory can still give strong necessary conditions and constructive sufficient ones for useful task classes.

## 7. Equal gate counts can describe very different futures

| Task | Main bottleneck beyond total gates |
|---|---|
| Many independent short simulated lives or experiments | Local hardware, replication, cumulative work/entropy; return communication may be unnecessary |
| One long adaptive computation with a small working set | Sequential causal depth, clocking, reliability and fuel delivery over its whole lifetime |
| Repeated global updates of a huge distributed memory | Light-crossing times, bandwidth, retained connectivity and simultaneous memory |
| A quantum task requiring unknown states at contingently chosen remote sites | No-cloning and relativistic task constraints; extra energy may not solve it |
| Print a particular externally selected high-complexity string | Specification/input capacity and output storage |
| Simulate a local physical system and report a short statistic | Can exploit locality, reversibility and compressed output; total microscopic trajectories need not be externally recorded |

For the adaptive example, an explicit black-box dependency chain supplies a clean depth requirement: query \(i+1\) depends on the unknown answer to query \(i\). If instead a known function happens to admit a shortcut, that shortcut is part of the algorithmic optimization problem. Do not confuse the depth of a chosen implementation with a proven lower bound for all equivalent algorithms.

## 8. The physical Church–Turing assumptions

A finite precision local quantum circuit is a defensible working model of controllable computation under ordinary quantum mechanics and relativity. It is an assumption about the relevant physical regime, not a theorem of completed quantum gravity. Quantum computing can alter complexity dramatically without solving uncomputable functions or supplying all exponential branches as separately readable answers. The foundational literature explicitly distinguishes a physical computability principle from a classical efficiency thesis. [Deutsch, 1985](https://doi.org/10.1098/rspa.1985.0070)

Proposals involving closed timelike curves, special relativistic spacetimes, arbitrary analog precision, nonlinear quantum mechanics or exotic gravitational dynamics change the assumed physics. The appropriate treatment is to put them in separate scenarios, with the costs of initial conditions, finite precision, stability, signal extraction and error control specified. They are not established methods for turning an asymptotically de Sitter universe into a halting oracle. Aaronson's survey provides a useful catalogue of such proposals and their difficulties. [Aaronson, 2005](https://arxiv.org/abs/quant-ph/0502072)

A single de Sitter horizon's entropy bound is a statement about a patch, not automatically an upper bound on the sum of memories across all descendants. In a universe with positive cosmological constant, a civilization launched from here can influence only a finite initial comoving volume; nevertheless that volume's physical extent grows, and descendants can occupy regions that eventually cease communicating. One cannot put all their late-time computation under a single horizon-area bound without a separate argument. A finite reachable initial matter inventory is also not, by itself, a finite-all-future-gates theorem. The output contract and architecture determine which resource region is relevant.

Likewise, horizon entropy does not by itself prove that all future physics is exactly a finite-state classical automaton. A finite-dimensional-Hilbert-space interpretation of de Sitter entropy is an additional theoretical position. Keep a distinction between semiclassical entropy bounds, accessible memory, and claims about the ultimate ontology.

## 9. What should or will be run?

Even a single decision maker should generally face a **resource portfolio problem**, not a scalar FLOP-allocation problem. Research can improve gate count, depth, memory, reversibility, reliability, propulsion, harvesting, cooling, or coordination. These improvements need not share one multiplier.

The marginal value of a research action is a weighted sum of the resources it saves or creates, with weights set by their scarcity for the chosen tasks. Schematically, if \(R_j\) is a resource and \(\lambda_j=\partial V/\partial R_j\) its shadow value, an action is attractive when

\[
\sum_j\lambda_j\,\Delta R_j+\Delta V_{\rm task\ quality}
>\text{the resources and delay it costs}.
\]

This is the multiresource version of the foom–coom threshold. It recovers the simpler formula only when all valuable computation and research can be reduced to one common efficiency multiplier and one fungible remaining budget.

The exchange argument for doing all research first can fail once resources have deadlines. Early expansion may preserve future resources that disappear from reach if research is prolonged. Early observations may record physical information that will otherwise be lost. Research can continue while distant collectors execute a previously designed policy. Later cooling can change the price of some entropy disposal, but existing low-entropy sinks can also make computation feasible now; the thermal background is not the only outlet. [Bennett, Hanson and Riedel, 2019](https://arxiv.org/abs/1902.06730)

This suggests several distinct transitions to investigate: research versus deployment, centralized versus autonomous computation, accumulation versus consumption of entropy capacity, deep individual processes versus many short ones, preserving information versus overwriting it, and reversible slow execution versus less reversible fast execution. Their order depends on values and physical uncertainty; it is not determined by a universal operations budget.

## 10. Research questions worth prioritizing

1. **A sequential-core achievable bound.** Construct an explicit retained reservoir, fuel-delivery system, processor and entropy sink, with a specified classical memory size and error tolerance. Lower-bound the number of useful causal steps it can execute, rather than multiplying mass by a generic operations rate.
2. **Reliability over extreme time.** Optimize passive protection, active correction, fresh hardware replacement and reversible computation together. The unknown of greatest interest may be the minimum entropy cost per *reliable task*, not per nominal gate.
3. **A cosmological compilation problem.** Given a circuit's work, memory, locality and depth profile, optimize its placement in an expanding spacetime and report whether its output is central, distributed or purely internal.
4. **Uniform versus arbitrary specifications.** Separate compactly generated simulated worlds from arbitrary high-complexity initial conditions. Their limits can differ by exponentially large factors.
5. **Conditional future scenarios.** Evaluate a stable cosmological constant, metastable vacuum, changing dark energy, uncertain matter stability and quantum-gravity alternatives separately. A tight answer within a branch is more informative than silently averaging incomparable models.
6. **Value of a disconnected future.** The operational resource region changes when value attaches to computations wherever they run instead of answers brought home. This is not merely a philosophical footnote; it changes which cosmic resources count.

## Source ledger and confidence notes

The strongest established ingredients used above are ordinary causal propagation, orthodox quantum-information constraints, logical reversibility constructions, and conditional speed/entropy/reliability theorems. Gravitational entropy bounds and assumptions about the infinitely distant future carry additional hypotheses. The proposed resource region and the combined memory–round-time inequality are our synthesis, not quoted results of a named paper.

- Bekenstein, 1981, *Universal upper bound on the entropy-to-energy ratio for bounded systems*: https://doi.org/10.1103/PhysRevD.23.287 — storage envelope with substantial hypotheses; not a claim of RAM attainability.
- Bousso, 1999, *A Covariant Entropy Conjecture*: https://arxiv.org/abs/hep-th/9905177 — light-sheet formulation; call it a conjecture/conditional bound at this level.
- Margolus and Levitin, 1998, *The maximum speed of dynamical evolution*: https://arxiv.org/abs/quant-ph/9710043 — energy above ground, orthogonal states, rate not lifetime expenditure.
- Jordan, 2017, *Fast quantum computation at arbitrarily low energy*: https://arxiv.org/abs/1701.01175 — explicit obstruction to promoting orthogonalization limits to universal computational gate rates.
- Lloyd, 2000, *Ultimate physical limits to computation*: https://arxiv.org/html/quant-ph/9908043 — aggregate speed, capacity and compression; explicitly cautions about control and attainability.
- Bennett, 1973, *Logical Reversibility of Computation*: https://www.cs.princeton.edu/courses/archive/fall04/cos576/papers/bennett73.html — reversible simulation.
- Bennett, 1989, *Time/Space Trade-Offs for Reversible Computation*: https://doi.org/10.1137/0218053 — uncomputation need not retain a full history forever.
- Reeb and Wolf, 2014, *An improved Landauer principle with finite-size corrections*: https://arxiv.org/abs/1306.4352 — precise entropy/heat accounting.
- Utsumi, Golubev and Peper, 2023, *Thermodynamic cost of Brownian computers in the stochastic thermodynamics of resetting*: https://arxiv.org/html/2304.11760 — logarithmic resetting cost with quadratic-time path exploration in its model; not a demonstrated cosmic computer.
- Bekenstein and Schiffer, 1990, *Quantum Limitations on the Storage and Transmission of Information*, preprint uploaded 2003: https://arxiv.org/abs/quant-ph/0311050 — information channels, not free wires.
- Holevo, 1973, *Bounds for the quantity of information transmitted by a quantum communication channel*: https://www.mathnet.ru/php/archive.phtml?jrnid=ppi&option_lang=eng&paperid=903&wshow=paper — accessible classical information.
- Aharonov and Ben-Or, 1996/1997, *Fault Tolerant Quantum Computation with Constant Error*: https://arxiv.org/abs/quant-ph/9611025 — a growing architecture family, not a finite eternal machine.
- Nielsen, Caves, Schumacher and Barnum, 1998, *Information-theoretic approach to quantum error correction and reversible measurement*: https://arxiv.org/abs/quant-ph/9706064 — error-correction entropy disposal.
- Balasubramanian, Davydova and Lin, 2026 preprint, *A passive self-correcting quantum memory in three dimensions*: https://arxiv.org/abs/2605.10943 — current model construction; only its abstract was checked in detail here, so do not overstate its engineering scope.
- Portmann, Matt, Maurer, Renner and Tackmann, 2017, *Causal Boxes*: https://arxiv.org/abs/1512.02240 — existing formal framework for the network side of the proposal.
- Kent, 2013, *A no-summoning theorem in relativistic quantum theory*: https://arxiv.org/abs/1101.4612 — an irreducibly spacetime/quantum obstruction.
- Deutsch, 1985, *Quantum theory, the Church–Turing principle and the universal quantum computer*: https://doi.org/10.1098/rspa.1985.0070 — foundational working model.
- Aaronson, 2005, *NP-complete Problems and Physical Reality*: https://arxiv.org/abs/quant-ph/0502072 — survey of exotic-computation proposals; not a theorem that quantum gravity must be BQP.
- Bennett, Hanson and Riedel, 2019, *Comment on “The aestivation hypothesis for resolving Fermi's paradox”*: https://arxiv.org/abs/1902.06730 — existing negentropy reservoirs and the limitations of background-temperature-only reasoning.
