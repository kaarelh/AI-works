# Thermodynamic resources for computational cosmology

Research memo, 8 October 2026. This is an input to the separate computational-cosmology report, not a revision of the foom–coom forecast. Numerical assumptions are reproduced by `calculations.py`; `calculations.json` contains the results. Distinguish established constraints, idealized resource accounting, and speculative attainability throughout.

## Main conclusions

1. **There is no established universal bound of 10^120 on future logical operations or FLOPs.** A quantity of that order follows from an accessible-work assumption divided by the Landauer cost at a positive de Sitter temperature. It is an optimistic *erasure-equivalent budget*. Relating it to useful gates requires a physical error/irreversibility model; relating it to FLOPs requires an algorithm and precision convention.
2. **A computation needs a resource vector, not just energy.** Track controllable memory, working energy, dissipated free energy or consumed entropy capacity, time, geometry/channel capacity, reliable control, and the observer who must receive its result. Resources can substitute, but are not interchangeable at a universal exchange rate.
3. **Sequentiality does not force all fuel into the fast core.** A compact processor can be resupplied from extended, gravitationally bound reservoirs. Large fuel inventory imposes engineering and acquisition constraints, not an unavoidable inventory-diameter delay on every gate. Large *working memory with arbitrary cross-memory dependencies* does impose a latency constraint.
4. **Waiting for a colder CMB is not an automatic 10^30-fold reward for doing nothing.** Existing nonequilibrium matter can absorb computational entropy now. Early harvesting, reversible resource management, and useful early computation can coexist with preserving a later cold-background option.
5. **The coldest theoretical sink is not necessarily the best operational sink.** Temperature reductions make erasures cheaper but diminish ordinary thermal radiation bandwidth. Very-low-temperature computation needs a model of modes, size, control, stability, and entropy disposal.
6. **Black holes are not established programmable general-purpose computers.** Entropy capacity, reversible dynamics, and information preservation do not establish initialization, local gate control, useful readout, or a tractable decoder.

## 1. The elementary bookkeeping

For a classical uncertain bit with degenerate logical energies, resetting it while returning the controller to its original state and disposing of the entropy into an equilibrium bath costs at least

\[
W_{\rm erase}\ge k_B T\ln 2.
\]

For a partially uncertain register the entropy reduction, rather than the number of addresses overwritten, is the relevant quantity. Known or correlated data can be uncomputed rather than expensively discarded. Side information must be accounted for as a physical resource: quantum conditional entropy can even be negative, allowing work extraction while consuming entanglement. This is not cyclic free work. [Bennett 2003](https://arxiv.org/abs/physics/0210005), [del Rio et al. 2011](https://doi.org/10.1038/nature10123).

Logical reversibility changes the accounting. The map `(input, blank scratch) -> (input, output, blank scratch)` can be implemented by computing, copying the classical output, and uncomputing the intermediate history. Its temporary-space/time costs matter, but it need not erase one independent bit per logical step. That is the crucial reason a thermal erasure bound cannot simply be called a FLOP bound. [Bennett 1973](https://doi.org/10.1147/rd.176.0525).

A rigorous finite-reservoir version is instructive. For an initially uncorrelated system and Gibbs reservoir undergoing joint unitary dynamics,

\[
\beta Q=\Delta S_{\rm erased}+I(S':R')+D(\rho'_R\Vert\rho_R),
\]

with entropies in nats and \(\beta=(k_BT)^{-1}\). The extra terms represent correlations and displacement of the finite bath from its initial thermal state. A freely available infinite bath is an assumption, not the literal contents of one cosmological patch. [Reeb and Wolf 2014](https://arxiv.org/abs/1306.4352).

Useful idealized balances are

\[
B_{\rm reset}+B_{\rm error}+B_{\rm control}
\le B_{\rm initial}+B_{\rm imported}+B_{\rm exported},
\]

where each term is an appropriately defined entropy quantity in bits, and

\[
W_{\rm available}=F_T(\rho)-F_T(\rho_{\rm eq}),\qquad
F_T=E-TS.
\]

The reference bath, allowed conserved charges, and controllable transformations must be specified. A kilogram of hot radiation, a kilogram of cold matter, and a kilogram of a nearly extremal black hole are not identical work resources. The replacement `available work = Mc²` is an explicitly optimistic efficiency assumption, not mass-energy equivalence alone.

For a simple bath-and-battery model with conversion efficiency \(\eta\),

\[
B_{\rm erase}\lesssim {\eta Mc^2\over k_BT\ln2}.
\]

This formula does not mean the processor itself must contain mass \(M\), that one gate consumes one erasure, or that \(B\) bits can be stored simultaneously. Nor should independent-looking resource terms be added if they represent the same entropy deficit counted twice.

## 2. What the 10^120 number is and is not

Krauss and Starkman (2004) analyze idealized harvesting from an accelerating universe and divide a collected-energy estimate by a de Sitter noise-temperature cost. Their Eq. 8 gives \(1.35\times10^{120}\) processed bits. The paper also analyzes outward distributed processors required to return their results, combining finite causal deadlines with a physical operation-rate estimate. It does not provide a fixed-error microscopic implementation for arbitrary reversible computations. Its assumptions include highly optimistic mass-to-radiation conversion. [Primary text, especially Eqs. 4–11](https://arxiv.org/html/astro-ph/0404510).

There are three distinct quantities which popular summaries tend to merge:

- A bound or estimate on the number of orthogonal physical transitions by a deadline.
- A finite supply of low-entropy degrees of freedom or erasure equivalents.
- The number of useful logical gates in a reliably controlled program.

They coincide only after extra assumptions. For example, if a chosen device produces an average \(h\) bits of unrecoverable error entropy per useful gate, its resource bound is approximately

\[
G\le B_{\rm erase}/h.
\]

For \(h=10^{-20}\), the same \(10^{120}\)-bit entropy budget supports \(10^{140}\) gates in this accounting. This is an illustration of model dependence, **not** a claim that such hardware is available. Conversely, error correction, output archiving, switching losses, and transport can make the feasible gate count much smaller.

If an ideal reversible machine has no noise, Landauer alone supplies no finite upper bound on repeated gate applications. A 400-bit reversible counter already has more than \(10^{120}\) distinct counter states; visiting them need not irreversibly erase a bit at each increment. That observation defeats a purported universal *Landauer-to-gates derivation*. It does not establish that a perfectly isolated, reliable 400-bit physical computer can operate for a cosmological duration, or that counting represents valuable computation.

The unitary quantum speed limit also needs careful interpretation: orthogonalization time is not automatically the clock period of every abstract logical gate. Jordan supplies explicit reasons why additional locality and information-density constraints are needed. [Jordan 2017](https://arxiv.org/abs/1701.01175).

### Numerical conversions, conditional on stable Λ

Using the declared reference values \(H_0=67.4\) km/s/Mpc and \(\Omega_\Lambda=0.685\),

\[
H_\Lambda=1.81\times10^{-18}\ {\rm s}^{-1},\quad
R_\Lambda=c/H_\Lambda=1.66\times10^{26}\ {\rm m},\quad
T_{\rm dS}={\hbar H_\Lambda\over2\pi k_B}=2.20\times10^{-30}\ {\rm K}.
\]

The semiclassical horizon temperature and entropy follow from [Gibbons and Hawking 1977](https://doi.org/10.1103/PhysRevD.15.2738). These are asymptotic positive-Λ assumptions, not a measured promise about the arbitrarily distant future.

| Resource mass | Ideal erasures at 2.725 K | Ideal erasures at T_dS | Schwarzschild entropy in bits for the same mass |
|---|---:|---:|---:|
| Earth | 2.06×10^64 | 2.55×10^94 | 1.37×10^66 |
| Sun | 6.85×10^69 | 8.50×10^99 | 1.51×10^77 |
| Milky Way stars, 5.43×10^10 solar masses | 3.72×10^80 | 4.61×10^110 | 4.46×10^98 |
| Illustrative energy inventory 3.5×10^67 J | 1.34×10^90 | 1.66×10^120 | 5.80×10^117 |

The erasure columns assume \(\eta=1\), usable rest energy, and arbitrarily good access to the stated bath. They are **not** executable gate counts. The black-hole column is a different counterfactual final state, not a third estimate of the same quantity. Their different mass scaling (linear versus quadratic) illustrates the danger of calling both “the number of computations in a mass”. Source of the Milky Way stellar mass convention: [McMillan 2017](https://arxiv.org/abs/1608.00971); no dark matter fuel assumed in that row.

## 3. Aestivation: the important correction

Sandberg, Armstrong, and Ćirković proposed that storing resources until cosmic cooling could multiply irreversible computation by about \(10^{30}\), potentially explaining quiet civilizations. Their proposal is an optimization argument conditioned on a cosmological future and particular resource handling, not evidence that aliens exist. [2017 preprint](https://arxiv.org/abs/1705.03394).

Bennett, Hanson, and Riedel object that computational entropy can be placed into finite nonequilibrium reservoirs, rather than immediately dumped into the CMB. Ideal reversible transfers consume one bit of available negentropy per bit reset, without requiring a colder external background. In their model, waiting becomes beneficial only after the internally available entropy deficits have been exploited and the remaining opportunity is a finite reservoir cooling against the changing bath. Their further construction stores entropy in captured radiation rather than losing it irretrievably. They explicitly leave realistic insulation, finite photon modes, and thermalization rates unresolved. Thus the critique undermines “nothing useful should happen until the CMB cools”, not every possible advantage of patience. [Bennett, Hanson, and Riedel 2019](https://arxiv.org/abs/1902.06730).

**Our resource-ledger interpretation:** There are at least three distinct actions: acquire controllable reservoirs before they become inaccessible; exploit entropy deficits already present; and export entropy across the boundary of the controlled system. A civilization can do the first two early while reserving the third for better conditions. “Compute now” does not logically imply “spend the final cold-background option now”. This is a more useful temporal decomposition than simply “harvest, sleep, compute”.

A concrete illustrative mechanism is an entropy tape. The processor's uncertain register is swapped into a fresh initialized tape segment. The processor becomes clean while the segment carries the old entropy. Carrying the segment into a controlled warehouse is not the same as irretrievably thermalizing it into the uncontrolled environment. The warehouse does fill; transport, control, and insulation consume resources. But no cosmic cooling is needed for the elementary swap. Whether more useful work can later be recovered depends on the full physical state, including correlations, not just the macroscopic label “used tape”.

This does not license counting the same clean tape twice. Its initial purity has been spent. The preserved option is the later thermodynamic use of the whole controlled compound system relative to a colder environment.

## 4. Why arbitrarily slow is not automatically arbitrarily efficient

Logical reversibility is compatible with nonzero physical dissipation. Real controllers, memory maintenance, and error rejection can spend entropy even when the desired mathematical map is reversible. Different hardware families have different costs; no universal positive entropy-per-gate floor is currently established by Landauer's principle.

For an illustrative finite-temperature device, let a gate take time \(\tau\), with slow-drive friction cost \(A/\tau\) bits and error/maintenance cost \(\Gamma\tau\) bits. Then

\[
b(\tau)=A/\tau+\Gamma\tau,\qquad
\tau_*=(A/\Gamma)^{1/2},\qquad b_* =2\sqrt{A\Gamma}.
\]

This is our simple optimization model, not a theorem for every physical computer. It identifies the missing variable in “run slower”: slowing saves dynamic loss while exposing hardware to noise for longer. Engineering changes both \(A\) and \(\Gamma\). It may also make the two-term approximation fail. Contemporary thermodynamic computing studies explicitly distinguish finite-time, protocol, accuracy, and stability costs. [Wimsatt et al. 2021](https://doi.org/10.1007/s10955-021-02733-1), [Ray et al. 2021 on momentum computing](https://doi.org/10.1103/PhysRevResearch.3.023164).

A second illustrative model is an Arrhenius memory with escape rate \(\nu_0 e^{-E_b/k_BT}\). To keep the probability of any escape below \(\delta\) across \(n\) cells for duration \(t\), the union-bound estimate requires

\[
E_b\gtrsim k_BT\ln(n\nu_0t/\delta).
\]

The energy barrier is stored energy, not necessarily dissipated afresh each gate. Still, finite hardware cannot be assumed to protect a record for arbitrary time at zero maintenance cost. Tunneling, radiation, material decay, and controller failure need separate treatment. This equation is a diagnostic model, not a fundamental lifetime theorem.

A recent directly relevant paper is Reilly and Lloyd (2025), which emphasizes that error syndromes and fresh ancillas belong in total negentropy accounting. It obtains entropy demand proportional to \(D\epsilon\log(1/\epsilon)\) for depth \(D\) and fixed physical error probability \(\epsilon\). It also discusses why black-hole control and decoding may be prohibitive. [Primary preprint](https://arxiv.org/abs/2506.16527).

Our qualification: a statement linear in depth **at fixed ε** does not prove a hardware-independent positive ε floor. It cannot, by itself, settle the existence of arbitrarily economical increasingly well-protected computer families. Its formal black-hole quantity \(E-T_HS=E/2\) also is not automatically extractable work relative to a specified bath: the reference equilibrium and allowed operations still matter.

## 5. An overlooked rate constraint: cold sinks have little bandwidth

Here is an original diagnostic calculation, deliberately less strong than a universal theorem. In the large-radiator/geometric-optics approximation, radiation from area \(A\) at temperature \(T\) carries power \(P\sim\sigma A T^4\). Dividing by Landauer's energy scale gives an erasure-equivalent throughput

\[
\dot B_{\rm thermal}\sim {\sigma A T^3\over k_B\ln2}.
\]

For cooling into a nonzero-temperature bath one needs the appropriate *net* flux; it goes to zero as emitter and bath equilibrate. Radiation entropy adds a factor of order unity, not a change of scaling. Lloyd's earlier analysis already includes entropy rejection as a computer bottleneck; the novel point here is combining the cold-sink scaling with a cosmological maximum scale. [Lloyd 2000](https://arxiv.org/abs/quant-ph/9908043).

Formally substitute \(A\sim4\pi(c/H)^2\) and \(T\sim\hbar H/(2\pi k_B)\). The result is

\[
\dot B_{\rm thermal}=O(H),
\]

only order one thermally encoded bit per Hubble time. Using the constants above, the literal Stefan–Boltzmann substitution gives 0.012 erasure equivalents per Hubble time, and emitting 3.5×10^67 J takes about 2.4×10^132 years.

**Do not present these last numbers as achievable or rigorous cosmic bounds.** At \(T_{\rm dS}\), the Wien peak wavelength is about eight horizon radii; geometric optics, an ordinary flat-space radiator, and an effectively infinite bath are no longer self-consistent. The calculation's purpose is exactly to expose that breakdown. Also it neglects incoming bath radiation; at exact equality of temperatures the net thermal heat current vanishes. The useful conclusion is that a Landauer count at \(10^{-30}\) K is incomplete without a low-frequency channel and finite-mode analysis.

Possible responses include running hotter, using nonthermal carriers with more energy per transmitted bit, keeping entropy in nearby reservoirs, or accepting fantastically long runtimes. They trade budget, memory, and time; none is a free conversion of “10^120 cheap erasures” into “10^120 fast gates”. Very cold finite systems also face control/time tradeoffs when preparing nearly pure states. [Taranto et al. 2023](https://doi.org/10.1103/PRXQuantum.4.010332).

## 6. Can one spend a large resource fraction on a sequential computation?

**Proposed construction at the level of an abstract physical architecture:** establish a gravitationally bound reservoir safely outside its collapse radius, put a comparatively small working processor near its center, and deliver work carriers or clean ancillas into that core while removing exhausted carriers or used ancillas. The resource flow can be buffered and pipelined. After start-up, a remote fuel shell need not receive the intermediate mathematical state after each gate. Only the small core implements the chain of dependent state transitions.

This separates three sizes:

- The *working-state size*, which sets how much information a sequential step must access.
- The *resource-inventory size*, which sets how long operation can be sustained.
- The *entropy-disposal surface and channels*, which help set sustainable throughput.

A statement that the entire fuel inventory must fit within one gate light-crossing time confuses the first two. In conventional computers, a power station is already a remote resource reservoir; making the lifetime fuel supply larger does not slow each processor cycle. A cosmic design faces vastly worse transport and gravity constraints but the logical distinction survives.

For a single dependency chain requiring arbitrary access to \(q\) widely separated working bits, the story differs. Physics may force communication delays or additional locality-aware algorithmic overhead. One cannot use a whole galaxy as coherent scratch space while retaining nanosecond arbitrary memory access. The report should distinguish *deep small-space computation fueled by vast resources* from *deep computation whose every step mixes vast working memory*.

The architecture is not a proof that nearly all currently reachable negentropy can be acquired and used with efficiency near one. Acquisition rockets, capture, friction, long-term reservoirs, gravity, quantum control, and cosmic lifetime all cost resources. The correct conditional statement is: **neither the speed of light nor black-hole avoidance alone rules out feeding a deep compact computation with an extended resource supply.** A useful open research target is the maximum achievable fraction as a function of workspace, allowed completion time, and error tolerance.

## 7. Black holes: four separate roles

A hole can be a gravitational energy extractor, an energy reservoir, an entropy sink, or a proposed computational device. These roles should never be merged.

For a Schwarzschild hole in an appropriate asymptotically flat approximation,

\[
S_{\rm BH}/(k_B\ln2)={4\pi GM^2\over\hbar c\ln2},\quad
T_H={\hbar c^3\over8\pi GMk_B},\quad
{dS_{\rm BH}\over dE}=1/T_H.
\]

A small injected energy \(dE\) therefore permits entropy increase \(dE/T_H\) under the semiclassical generalized-second-law accounting. This is not access to all the pre-existing horizon entropy as initialized RAM. Accretion changes the mass and temperature; swallowing the processor destroys ordinary exterior access to it. A solar-mass hole has entropy about 1.5×10^77 bits but Hawking temperature around 6×10^-8 K, much warmer than the late de Sitter floor.

A gravitational redshift trick also needs honest accounting. In a static equilibrium exterior with lapse \(\alpha\), the local Tolman temperature scales as \(T_{\rm local}=T_\infty/\alpha\), while energy delivered to infinity is \(E_\infty=\alpha E_{\rm local}\). Thus a local thermal erasure cost corresponds to \(E_\infty\ge k_BT_\infty\ln2\): moving a computer down a gravitational well does not by itself make the cost vanish to the distant accountant. Proper clock time and control/holding forces must also be included. Near coinciding black-hole/cosmological horizons, Schwarzschild formulas and temperature normalizations require replacement, not extrapolation.

Unitary evaporation implies information preservation under the corresponding theory. It does not give a user a method to implement an arbitrary circuit efficiently. Hayden–Preskill assumes rapid mixing and extensive coherent access to radiation; Harlow–Hayden identifies complexity obstacles to a relevant decoding task under complexity assumptions. These are reasons to distinguish a physical evolution from a programmable computer, not proofs that every conceivable black-hole computation is impossible. [Hayden and Preskill 2007](https://arxiv.org/abs/0708.4025), [Harlow and Hayden 2013](https://arxiv.org/abs/1301.4504). Special idealized decoding constructions exist, so blanket claims of unavoidable exponential decoding are too strong. [Yoshida and Kitaev 2017](https://arxiv.org/abs/1710.03363).

## 8. Infinite future does not automatically mean infinite useful computation

Dyson's original indefinite-subjective-life construction required a cooling cosmology and scaling assumptions. Positive asymptotic Λ changes that environment. [Dyson 1979](https://doi.org/10.1103/RevModPhys.51.447). But the converse slogan “finite de Sitter entropy proves a finite number of all operations” is too fast.

A finite-dimensional closed quantum system can evolve indefinitely. Its continuum of mathematical amplitudes is not an unlimited store of reliably distinguishable classical records. Similarly, a finite-state deterministic classical machine may cycle indefinitely without producing an indefinitely growing library of distinct retained results. A machine with \(s\) complete-state bits has at most \(2^s\) distinguishable classical configurations; a nonrepeating autonomous trajectory cannot visit more, absent external input or a larger controller. This gives a *state/repetition* observation, not a Landauer bound.

Finite de Sitter entropy's interpretation as a finite closed Hilbert space is a quantum-gravity proposal, not something established by horizon thermodynamics alone. Banks, Fischler, and Paban discuss operational problems with verifying its recurrences; Boddy, Carroll, and Pollack discuss a different embedding in which the patch approaches a quiescent state rather than dynamical fluctuation histories. [Banks et al. 2002](https://arxiv.org/abs/hep-th/0210160), [Boddy et al. 2014](https://arxiv.org/abs/1405.0298).

For a report about computations we can intentionally instantiate from now onward, it is cleaner to require initialization from our accessible state, an explicit success criterion, and a durable or experienced result on designated worldlines. A rare equilibrium fluctuation accidentally resembling a computer is not automatically a resource we can schedule or program.

## 9. Suggested open problems and optimization questions

**A real sequential-resource frontier.** Given memory \(q\), tolerated failure probability \(\delta\), resource mass \(M\), geometry \(\mathcal G\), and completion time \(\mathcal T\), bound the largest executable circuit depth. Explicitly permit moving fuel and ancillas while charging communication and maintenance. This goes beyond summing cosmic energy.

**Entropy-location optimization.** At each time choose whether to keep entropy in a controlled warehouse, radiate it, or place it behind a horizon. Compare the opportunity cost in remaining computation and the danger of losing control. This is the physical analogue of spending versus investing, and extends foom–coom's scalar budget.

**Who must receive the answer?** A distributed civilization can value experiences in causally separating descendants without receiving their final output. A central scientific question requires a returned answer. The same expansion geometry defines different feasible sets for these objectives.

**What type of experience or output is valuable?** Linear value in independent local experiences may favor parallelism. Value from a single long-lived, memory-rich trajectory places weight on depth, integrity, and communication. Physics cannot choose the utility function.

**Survival-adjusted patience.** If the marginal erasure yield improves as \(1/T(t)\) but resource survival declines as \(p(t)\), an illustrative objective is \(p(t)W(t)/T(t)\). Even before introducing discounting, its optimum need not occur at the minimum attainable temperature. This equation is our deliberately simple decision model; risk to the state of a long sequential computation also accumulates over its execution, not just while waiting.

**Specification and control budgets.** Counting accessible states or Hamiltonian transitions must be complemented by the information needed to prepare and control the requested computation. Black-hole entropy can be high precisely where that access is least understood.

## Audit note: possible error in a widely used harvesting coefficient

This deserves independent verification before publication. For pure de Sitter, let \(u=HR_{\rm today}/c\). Sending an outward null front and immediately returning photons gives redshift factor \((1-2u)/(1-u)\), for \(0\le u\le1/2\). If a shell is counted by its conserved initial rest mass, direct integration gives received fraction of initial horizon rest energy

\[
3\int_0^{1/2} u^2{1-2u\over1-u}\,du
=3(17/24-\ln2)=0.0455585\approx1/22.
\]

Krauss–Starkman instead report 1/64. Their Eq. 5 appears to apply time-diluted matter density to a shell labeled by present distance without a compensating shell-volume expansion. This could be a coordinate/convention issue; do not claim an error solely on this memo. The main thermodynamic points do not depend on which coefficient survives. In either case it is an order-unity factor relative to a speculative engineering envelope, not a universal exact usable budget.
