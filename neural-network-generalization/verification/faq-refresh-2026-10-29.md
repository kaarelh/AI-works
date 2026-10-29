# FAQ review and explicit width–depth bounds, 29 October 2026

The [technical FAQ](../TECHNICAL-FAQ.md) was reviewed against the current manuscripts, the formal-coverage records, and the two collection-wide manuscript reviews of 29 October. This record explains the joint width–depth estimates in [Question 23](../TECHNICAL-FAQ.md#23-what-are-the-explicit-sample-complexity-polynomials-and-are-practical-sample-bounds-close). These are algebraic consequences of published budgets, not new separately formalized Lean theorems.

## Conventions and scope

For the Boolean-circuit rows, $C$ counts teacher width, constant wires, and compilation overhead. The neural learner has $L-1$ hidden layers. A teacher with $h\le L-1$ gate stages can be padded with COPY gates; if the learner matches the teacher, $L=h+1$. If the learner is deeper, its actual $L$ must be used. Width independence refers to learner width $N$.

In the following asymptotics, input dimension $d$, positive calibration $c$, accuracy $\varepsilon$, and confidence parameter $\delta$ are fixed. Set

$$
F=1+\log^2(2+C)+\log(2+L),\quad
G=\log(2+CL),\quad
\Psi=\log(2+C+\log(2+L)).
$$

The bounds are sufficient sample sizes, not lower bounds or optimality claims. The full statistical and dimensional dependence remains in the linked source formulas. In particular, the all-scales proof has inverse-accuracy factors inside its compression budget; its fixed-accuracy asymptotic cannot simply be multiplied by $1/\varepsilon$ to recover the full dependence.

| Setting | Sufficient joint bound | Fixed-depth consequence | Fixed-width consequence |
|---|---|---|---|
| Original internal-noise support, tanh, all $0<t\le1$ | $O(C^6L^{18}F^6G)$ | $O(C^6\log^{13}(2+C))$ | $O(L^{18}\log^7(2+L))$ |
| Same support, strong-prior limit at each width or finite $t\le N^{-1/2}$ | $O(C^4L^8F^4\log^2(2+L)G)$ | $O(C^4\log^9(2+C))$ | $O(L^8\log^7(2+L))$ |
| Balanced tanh averaging or signed merging | $O(C^2L^4F^2G)$ | $O(C^2\log^5(2+C))$ | $O(L^4\log^3(2+L))$ |
| ReLU/GELU population merging | $O(C^2L^6\Psi^2G)$ | $O(C^2\log^3(2+C))$ | $O(L^6\log(2+L)\log^2(2+\log(2+L)))$ |

Tanh averaging can be imposed alone or together with the original internal-noise condition; the Boolean witness belongs to their intersection. Signed merging and ReLU/GELU populations use their respective stated conditions. These rows do not establish a quadratic bound for the original internal-noise condition alone. ReLU requires $N\ge C$ and the stated GELU compiler $N\ge2C$; the counted Boolean width includes a constant wire at every stage. The stronger-scale original-support row covers finite $\gamma\ge2$, not all $\gamma\ge1$.

## Original support at all mean-field-or-stronger scales

Sources: the [learning theorem and target cylinder](../works-in-progress/improved-polynomials/original-support-all-scales/source/learning-theorem.tex), [explicit budget](../works-in-progress/improved-polynomials/original-support-all-scales/source/explicit-budget.tex), and [compression proof](../works-in-progress/improved-polynomials/original-support-all-scales/source/compression-proof.tex).

The target gain satisfies $A^2=O(F)$. Its Gaussian cylinder has normalized negative log mass $D_*=O(CLF)$. Substitution into the paper's definitions gives:

| Quantity | Sufficient order at fixed other resources |
|---|---|
| Energy and entropy cutoffs $K,B_v$ | $CLF$ |
| Squared inverse noise radius $r^{-2}$ | $CL^2F$ |
| Inverse layer reconstruction tolerance $e^{-1}$ | $CL^3F$ |
| Inverse failure allocation $\eta^{-1}$ | $L$ |
| Retained direction count $q$, variance budget $V$ | $C^2L^5F^2$ |
| Compression width $M$ and small-width threshold $N_0$ | $C^3L^8F^3$ |
| Dense parameter count $P$ | $C^6L^{17}F^6$ |
| Log grid cost per parameter | $LG$ |
| Total code length and sufficient samples | $C^6L^{18}F^6G$ |

Concretely, $r^{-2}=O(LB_v)$, $e=\alpha r^2/(1000L)$, and $\eta=\alpha/(100L)$ with $\alpha=\varepsilon/12$. Then $q=\lceil2K/(e\eta)\rceil$ and $V=8K+2q$. The reconstruction term $(V+q+1)/e$ dominates the Gram and readout contributions to compression width. Counting $M(d+1)+(L-2)M^2+M$ parameters supplies the factor $L^{17}$; precision supplies another factor of $L$.

The Lean theorem certifies the compressor, learning theorem, fixed-depth sixth-power rate, and degree-46 joint envelope with larger internal constants. It does not certify the separate manuscript allocation $16/\varepsilon$, nor state the extracted mixed asymptotic as a named theorem. The constant-wire convention and width-one qualification in the [coverage table](../lean/review/BatchTwo-coverage.md) remain in force.

## Original support at stronger scales

Source: the [stronger-scale paper](../works-in-progress/improved-polynomials/original-support/source/paper.tex), its explicit sample budget and width-dependence calculation.

Here $K=O(CLF)$ and $r^{-2}=O(LK)$. The compressed width is

$$
m=O\bigl(Kr^{-2}[d+\log(2+L)]\bigr)
 =O\bigl(C^2L^3F^2\log(2+L)\bigr).
$$

The dense parameter count is $O(C^4L^7F^4\log^2(2+L))$, and the grid log is $O(LG)$. Their product gives the second row. The allowable energy cutoffs are justified in the strong-prior limit at fixed width and at finite scales $t\le N^{-1/2}$. This proof is conventional, not Lean formalized.

## Tanh averaging and signed merging

Sources: [balanced averaging](../works-in-progress/improved-polynomials/neuron-averaging/source/paper.tex) and [signed merging](../works-in-progress/improved-polynomials/neuron-merging-naturality/source/paper.tex), the target constants, learning budgets, and width/depth consequences.

The target cost remains $D_*=O(CLF)$. The group cap is $Q=O(CLF)$, and projected energy is bounded polynomially. There are $O(LQ^2)=O(C^2L^3F^2)$ effective parameters and $O(LG)$ log grid cost per parameter. Signed partitions and unequal group sizes add coding terms without changing these powers.

Both papers also give a literal quadratic-width envelope

$$
n\ge\frac A\varepsilon\left[C^2(2+d+L+c+\log(4/\varepsilon))^9+\log(1/\delta)\right].
$$

Pruning unused Boolean wires bounds relevant width by an exponential in depth and permits absorbing width logarithms into depth powers. This yields the alternative $O(C^2L^9)$ at fixed other resources; it does not claim that $C^2L^9$ is uniformly smaller than the log-retaining bound.

The stronger count calibration $q\le1+E_v/(d+L)$ yields $Q=O(CF)$ and $O(C^2L^2F^2G)$ at fixed other resources. It changes the prior restriction. The tanh proofs in this paragraph are conventional.

## ReLU/GELU population merging

Source: the [ReLU/GELU polynomial-depth paper](../works-in-progress/relu-gelu-polynomial-depth/source/paper.tex), its explicit ReLU constants and the GELU transfer budgets.

The target cylinder radius satisfies $\log(1/\rho)=O(L\Psi)$, and its normalized cost is $D_*=O(CL^2\Psi)$. Thus $Q=O(CL^2\Psi)$, the effective parameter count is $O(C^2L^5\Psi^2)$, and the grid log is $O(LG)$. GELU replaces $C$ by $2C$ in the construction and adds population-size parameters without changing these powers. The resulting sample order is $O(C^2L^6\Psi^2G)$.

The paper also gives the literal $C^2(2+d+L+\log(4/\varepsilon))^9$ envelope. Its main explicit budgets, literal polynomial envelope, and fixed-parameter width corollaries are Lean verified. The mixed asymptotic extracted here is not an additional named Lean theorem.

## Shallow neural teachers and general activations

The [shallow paper](../works-in-progress/improved-polynomials/shallow/source/paper.tex) has $L=2$. For hidden coefficients bounded by $W_0$ and readout coefficients by $V$,

$$
\kappa_C=\frac dC\lVert W\rVert_F^2+C\lVert a\rVert_2^2
\le d(d+1)W_0^2+C^2V^2.
$$

Its norm-based summary is $\widetilde O((d(\kappa_C+d)+\log(1/\delta))/\varepsilon)$. Consequently, $W_0\le C$ and fixed $V$ give the dimensional term $d^3C^2$; allowing $W_0,V\le C$ gives $d^3C^2+dC^4$. The literal finite-cube budget gives the respective looser dimensional terms $d^4C^2$ and $d^4C^2+d^2C^4$ at fixed accuracy and confidence. All three explicit budgets and the first budget's quadratic/quartic width consequences are certified; the compact norm-based asymptotic is not separately stated in Lean.

The [general Lipschitz-activation polynomial-depth theorem](../works-in-progress/unified-activation-polynomial-depth/source/paper.tex) concerns a same-activation neural teacher, with weight bound $B$, activation Lipschitz bound $\lambda$, and offset bound $b\ge|\phi(0)|$. Its degree-13 sum envelope is explicit in $C,L,B,\lambda,b,d$ and statistical parameters. It is a conventional proof, does not assume an additional internal-noise condition, and does not assert quadratic width dependence. It should not be substituted for the Boolean-specific quadratic rows.

## Other FAQ corrections

The general pass also:

- Distinguishes the conditional impossibility of a universal joint-polynomial bound from the still-open unconditional exponential-depth lower bound for the canonical Boolean learner.
- Adds the finite-width subcritical upper bound beside the width-first exponential lower bound.
- Corrects the confidence conversion: Gibbs error at least $3/8$ gives failure at least $(q-5/8)/q$, which is positive for $q>5/8$ and equals $1/16$ at $q=2/3$.
- Updates empirical certificate and public-archive scope, and separates certified positive-tolerance regression and low-energy interpolant components from the conventionally proved iterated posterior-limit identification.
- Clarifies non-Gaussian raw rate normalization, the depth assumption in the standard fan-in variational theorem, and the scope of activation and online extensions.
- Simplifies the overview and removes conversational or historical framing where it obscured the mathematical claim. Existing numbered headings and legacy anchors are preserved.

Five AI-agent reviews covered the FAQ by topic; two independently derived and checked the polynomial estimates, followed by a review of the final displayed formulas. These are mathematical and editorial checks, not human peer review or an enlargement of formal coverage. No paper sources, PDFs, or Lean sources were changed. The [first](standalone-writing-2026-10-29.md) and [second](remaining-papers-2026-10-29.md) manuscript reviews supply the underlying current paper/status checks.

## Publication checks

- `python neural-network-generalization/verify_collection.py` passes for all 66 catalogued papers and local Markdown links; no PDF rebuild was needed.
- All 40 numbered FAQ headings, 72 explicit legacy anchors, and 40 distinct same-document link targets are preserved or resolve correctly.
- Display-math delimiters balance; no control characters or unsupported `\operatorname` commands were introduced. These source checks do not claim a visual browser-rendering test.
- `git diff --check` passes. All paper sources, published PDFs, and Lean sources are unchanged from commit `d8a9badfa960e0d8590f2febded5960a316607b6`.
- The collection file checksum manifest is refreshed for the FAQ and review documentation. No Lean rebuild or enlargement of formal coverage is claimed.
