# Independent adversarial audit of the bounded-width analog compiler

Audit date: 24 October 2026, approximately 08:06 UTC. Reviewed source:
`analog-base4-compiler.md`, including the updated table for all 16 original
fanin-two gates and reuse of `T` as a robust scratch bit. The exact reviewed
source hash and an exhaustive gate-table check are recorded in
`analog_compiler_audit_checks.json`.

**Verdict: the representation theorem passes this audit.** I found no
substantive gap in the small-memory error induction, digit recovery, fixed
schedule, coefficient accounting, or polynomial depth bound. This does not
prove a polynomial Frobenius-product compiler or resolve the NNBayes question.

## 1. Amplification has adequate quantitative slack

With `c=tanh(1)` and `phi(u)=tanh(u/c)`, the claimed growth and contraction
constants are valid:

\[
 c=0.761594155955764888\ldots,
 \quad\frac{\tanh(3/4)}{3c/4}=1.11196398137659\ldots>1.1,
\]

\[
 \frac{\operatorname{sech}^2(3/4)}c
 =0.783338217101527\ldots<0.8.
\]

The interval `[3c/4,1]` is invariant: its lower endpoint is mapped upward,
and `phi(1)<1`. It contains the fixed point `c`, so the derivative bound gives
contraction of the distance to `c`, including trajectories that cross `c`.
Oddness supplies the negative branch.

For `delta=eta=4^(-20M)`, the two ceilings in the draft sum to at most

\[
 415.152985\,M+23.817623<500M\qquad(M\ge2).
\]

The initial lower-amplitude hypothesis is available both for digit extraction
and for NAND. After NAND, the preactivation magnitude is at least `c-2eta`,
so its tanh is far above `delta/10`. Holds of an already accurate robust bit
contract its error instead of accumulating it.

## 2. The carry/pop induction is not circular

An ideal signed base-four word has magnitude at most `delta/3`; a nonempty
word has leading-sign gap at least `delta/6`. Reading only valid predetermined
positions ensures that every extracted temporary word is nonempty.

Assume the bootstrap error bound `delta/100` for a small register. A held or
copied small value is below `delta/2`. A pop preactivation has magnitude at
most

\[
 \delta/3+4\delta/100+(\delta/c)\eta<\delta/2.
\]

Thus the cubic tanh error used in the pop recurrence is justified *before*
using that recurrence. The append preactivation is even smaller. No large
digital scratch value is inserted into the small memory without its explicit
factor `delta/c`.

The main-register recurrence, including its first-layer approximation, is

\[
 E_R\le(T_{\max}+1)\delta^3+N\delta\eta.
\]

For a read, start with `E_R+delta^3`, count at most `T_max` additional holds,
at most `N` pops, and pessimistically amplify every earlier error by `4^N`.
This gives exactly the stated safe envelope

\[
 E_T\le4^N[(2T_{\max}+2)\delta^3+3N\delta\eta].
\]

Since `N=M-1`, its ratio to `delta` is bounded by

\[
 (10000M^3+2)4^{-39M}+3M4^{-19M}.
\]

Both summands decrease for `M>=2`; at `M=2` their sum is below
`7.941e-23`. This is much smaller than `1/100`. At extraction, the additional
initial tanh therefore leaves a gap at least
`delta/6-E_T-delta^3 > delta/10`. This validates the amplifier, which validates
the digital outputs used in subsequent pops/appends, closing the simultaneous
induction.

All holds of `R` while gates or amplifiers operate are included in `T_max`.
There is no uncounted loss from the original input: all input bits are encoded
in the first layer, and later accesses use the stored word.

## 3. Register reuse and arbitrary gates are sound

After both operands have been read, `T` is no longer needed as a small
temporary word. Reusing it as a robust scratch bit is legal. The next read
overwrites it with `tanh(R)`, so no previous robust value leaks into a later
temporary-word error bound.

I exhaustively evaluated all 16 displayed NAND programs on all four operand
pairs and on both possible initial scratch-bit values. Every truth table
matches, all outputs are left in `U`, and the maximum program length is five
NAND operations. The check is saved separately. In-place updates use old
source values, exactly as simultaneous feedforward matrix maps do.

After each NAND operation the destination is amplified afresh; other occupied
bit registers use the contracting robust hold. Therefore the five-operation
programs do not multiply the digital error tolerance by five. Only the final
original gate output is appended, so the memory length remains at most
`d+S`, where `S` is the original gate count.

## 4. Layer and coefficient accounting checks

The loose read bound `1+N(K+2)` is safe. Two reads, operand storage, five
NAND-plus-amplifier operations, and insertion cost at most

\[
 (2N+5)K+4N+9
\]

layers per original gate. Adding initialization and a further output read
gives the draft's bound

\[
 (2N^2+6N)K+4N^2+11N+2<5000(N+1)^3.
\]

The strict inequality has substantial slack. Consequently, if the statistical
paper counts the final linear readout as an additional layer, the total
matrix depth can still be bounded by `5000(N+1)^3`: the hidden-layer count is
an integer strictly below that integer bound.

Every logical entry has magnitude at most four. A repeated-source NAND has
coefficient `-2`, which is allowed. Four identical physical copies of each
logical coordinate implement an entry `A_ij` using `A_ij/4` on all corresponding
edges. This exactly preserves the logical preactivation and keeps every
physical coefficient at most one. It introduces no extra nonlinear layer.

The first-layer constant rail uses coefficient one and is charged four times.
The first Frobenius norm is below three because the input-memory coefficients
have a summable geometric square series. The readout uses four coefficients
`1/(2c)<1`, has norm `1/c<2`, and produces signed output at least
`2(1-eta/c)>1`. Internal cloned matrices have exactly the logical matrix's
Frobenius norm. Thus neither constants nor cloning are uncharged resources.

## 5. Exact real rails are not an oracle-precision loophole

The exact-real theorem already fits the stated teacher class. In addition,
polynomially many **bits** of coefficient precision suffice. This distinction
is important: the required absolute error is exponentially small, but its bit
length is polynomial.

Consider the width-24 physical network with `T>=1` hidden layers. Round every
coefficient to within `epsilon`, keeping it in `[-1,1]`; nearest dyadic
rounding with endpoints included does this. Let `e_j` be the worst coordinate
error after hidden layer `j`, uniformly over all Boolean inputs. Tanh is
one-Lipschitz and every hidden coordinate remains in `[-1,1]`, so

\[
 e_1\le(d+1)\epsilon,\qquad
 e_j\le24e_{j-1}+24\epsilon.
\]

The final linear readout changes by at most `24e_T+24epsilon`. Summing the
geometric recurrence gives the convenient bound

\[
 \sup_x|z_{\rm rounded}(x)-z(x)|
 \le(d+4)24^T\epsilon.
\]

Choosing `epsilon <= [4(d+4)24^T]^-1` changes the output by at most `1/4`,
leaving margin strictly greater than one. It requires only

\[
 O(T+\log(d+1))=O((d+S+1)^3)
\]

bits per coefficient. The coefficients are computable from fixed elementary
constants and explicit dyadics, so this also gives a finite, polynomial-bit
description. The argument does not claim stability to inverse-polynomial
parameter noise, and does not improve the exponential Frobenius-product
bound.

## 6. Minor presentation clarifications

* The coefficient summary should mention `-2` for a repeated-source NAND,
  rather than saying that all NAND coefficients are only `+/-1`.
* If constant wires or a constant designated output are part of the circuit
  convention, initialize a requested robust constant by `U<-phi(+/-C)` (or
  the analogous assignment to `B`). This is one charged layer and fits the
  generous existing budget. A constant output can also use the constant rail
  directly. No memory digit needs to be allocated to it.
* For an original-input output, one read already includes amplification;
  saying "one read suffices" avoids suggesting an uncounted extra amplifier.
* The unused `D=delta` rail is harmless and charged. It could be omitted, but
  no such simplification is needed for the stated width-24 result.

These are clarifications, not failures of the construction. The theorem is a
fixed-width representation result with an exponential product bound; any
learning consequence must still use the separate posterior/compression
arguments.
