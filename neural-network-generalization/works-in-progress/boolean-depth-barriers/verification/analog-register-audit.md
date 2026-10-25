# Audit of the six-register tanh circuit compiler

Date: 2026-10-24. Parent proposal in `fresh-formula-compiler.md`; this is an independent quantitative audit. The compiler has constant width and bounded entries, but its Frobenius product is exponential in its polynomial circuit-simulation depth. It does not prove a polynomial-product representation theorem.

## Parameters and exact rails

Let a Boolean circuit have d input bits and S fan-in-two gates, in topological order, and set N=d+S. Encode truth values by signs ±1. Let

c=tanh(1), delta=eta=4^(-20(N+1)), K=500(N+1), M=5000(N+1)^3.

The exponent must be written with these parentheses. Six logical registers are R,T,U,B,C,D. C=c is maintained exactly by C <- tanh(C/c). D=delta is maintained exactly by D <- tanh((atanh(delta)/delta)D). Neither rail has an uncharged bias. D is not essential when all tiny coefficients are fixed in advance, but retaining it causes no difficulty.

R holds a signed base-four word r=delta sum_(i=1)^m b_i 4^(-i), m<=N. It obeys |r|<delta/3. If m>=1, its first digit has the sign of r and |r|>=delta/6. Prepending bit b maps r to (r+delta b)/4. Popping the first bit maps r to 4r-delta b.

Initial R is tanh(r), so its initial encoding error is at most delta^3/81. The initial rails C,D are obtained from the augmented input coordinate using coefficients 1 and atanh(delta), respectively.

## Amplification lemma with the stated constants

Set phi(u)=tanh(u/c). Its nonzero fixed points are ±c. On 0<u<=c/2,

phi(u)/u >= tanh(1/2)/(c/2) >1.21>1.1.

This follows because tanh(t)/t decreases on t>0. Starting from c/2, three applications of phi exceed 3c/4. On [3c/4,1],

0<=phi'(u)<=sech(3/4)^2/c<0.784<0.8.

The interval [3c/4,1] is invariant. Thus any u with delta/10<=|u|<=1 reaches the eta-neighborhood of the appropriate fixed point in at most

ceil(log(5c/delta)/log(1.1))+3+ceil(log(2/eta)/log(1.25))

steps. The right hand side is at most 500(N+1), with substantial slack, including N=0. Oddness handles negative signs. Once within eta of ±c, repeated phi updates preserve this error (in fact contract it). The same amplifier can act on U, B, or T, depending on the instruction.

## Reading and Boolean gates

To read digit p, first copy R into T by T<-tanh(R). For p iterations, copy T into U by U<-tanh(T), amplify U for K steps, and pop T<-tanh(4T-delta U/c). The final U has the requested sign and is within eta of ±c. The last pop is optional but harmless. During the read, R,T use identity-tanh carries, B uses phi if it stores an earlier operand, and the rails are updated exactly.

To read a gate's two operands, read the first and save it in B using phi, then read the second into U. NAND is U<-tanh(C-B-U), followed by amplification. Since each operand is within eta of its target ±c, the NAND preactivation has the correct sign and magnitude at least c-2eta>c/2. Thus its new U is already much larger in magnitude than delta/10. The output is appended with R<-tanh((R+delta U/c)/4).

### Arbitrary fan-in-two gates without changing N

If S counts arbitrary two-input Boolean gates, rather than NAND gates, no expansion of the stored word is necessary. Reuse T as a third robust bit register after the operand reads. A NAND gate can write to any of B,U,T, followed by K amplifier steps on that destination. During this gadget, all occupied bit registers use phi carries. The next read resets T from R, so T need not remain small outside read subroutines.

Every two-input Boolean function has a program using at most five NAND operations on these three registers. The longest case is XNOR: first compute

T=NAND(B,U), B=NAND(B,T), U=NAND(U,T), U=NAND(B,U),

which gives XOR, then complement U via NAND(U,U). The other functions are constants, projections, literals, AND/OR/NAND/NOR, or one of the two mixed-literal AND/OR functions, all requiring at most this many operations. A repeated input uses coefficient -2, within the claimed entry bound. Store only the final original-gate result in R. The word length remains at most d+S=N.

## Error induction

Let the ideal word registers always mean exact base-four encodings of the already computed bits. During any read, |T_ideal|<=delta/3. During all steps |R_ideal|<=delta/3. Bootstrap actual |R|, and actual |T| while reading, to at most delta/2. Every identity-tanh carry or small-register update then has nonlinear error at most delta^3/24, provided its preactivation also lies within delta/2. The final bound below verifies that condition retrospectively by induction.

Ignoring the helpful factor 1/4 at appends, the main error is bounded by

E_R <= N delta eta/(4c)+(M+1)delta^3/24.

At the start of each read, copying R into T adds at most delta^3/24. Each pop multiplies the existing T error by 4, adds at most delta eta/c from the approximate digit, and at most delta^3/24 from tanh. All intervening small-register carries together contribute at most M delta^3/24. A deliberately loose bound for every read prefix is

E_T <= 4^N [ E_R + N delta eta/c +(M+1)delta^3/24 ]
    <= 3(N+1)4^N delta^2.

The second inequality holds for all N>=0 with the displayed delta,M (the quantities M delta are tiny). Relative to delta,

E_T/delta <=3(N+1)4^(-19N-20)<1/1000.

E_R/delta is smaller still. Hence R and reading T remain within delta/2, and every pop or append preactivation does also: its ideal value is at most delta/3 and its error is at most 4E_T+delta eta/c, far below delta/6. This closes the bootstrap.

Before each requested digit extraction, |T|>=delta/6-E_T>0.165 delta. The additional tanh copy changes it by at most delta^3/24, so the amplifier receives magnitude greater than delta/10. All digit decisions and all Boolean gate signs are therefore valid.

## Explicit depth count

A digit-p read costs at most 1+p(K+2) hidden updates. For a general two-input gate, two reads, a B save, at most five NAND-plus-amplifier steps, and an append cost at most

(2N+5)K+4N+9.

An initialization and a final designated-output read add at most 2+N(K+2). With S<=N, the entire hidden depth is bounded by

(2N^2+6N)K+4N^2+11N+2 <5000(N+1)^3.

If the basis already consists of NAND gates, the stronger bound 1000(N+1)^3 suffices. A constant circuit or an output that is an original input is handled by the same final-read convention, with the trivial N=0 case handled directly from C.

## Four clones, coefficient bound, and margin

Use four identical physical copies of each logical register, for hidden width24. An effective logical coefficient A_ij is implemented by coefficient A_ij/4 from each of the four source copies to each of the four target copies. Then each target's preactivation is exactly the intended logical preactivation. All effective coefficients have magnitude at most4: popping uses4; repeated-input NAND may use2; phi uses1/c<2; the D rail has atanh(delta)/delta<2; all other coefficients are smaller. Thus every physical internal coefficient has magnitude at most1. First-layer input coefficients already have magnitude at most1, including the rail creation weights.

The scalar readout places weight 1/(2c)<1 on each of the four U copies and zero on the others. It equals2U/c, so the signed output margin is at least2(1-eta/c)>1.

There is no uncharged copying or norm saving: if all six logical coordinates are cloned fourfold, the full internal matrix is A tensor (J_4/4), and its Frobenius norm is exactly ||A||_F because ||J_4/4||_F=1. The first matrix's norm gains a factor2 and the final readout's norm loses a factor2. Cloning therefore preserves the Frobenius product while bringing the entrywise bounds below1. A crude constant bound on each logical matrix norm gives P<=exp(O((N+1)^3)), not P<=poly(N).

## Audit conclusion

With explicit parentheses in delta, a stated instruction schedule for holding each register, and the three-register gadget above if S counts arbitrary fan-in-two gates, the claimed width24, entrywise-bounded tanh compiler is quantitatively consistent. No circularity or hidden bias was found. The large small-digit precision is essential, but fully allowed in the current real-parameter model and safely absorbed by the long amplifier.

## Complete two-input NAND program table

Let the initial operands be B=a and U=b. Below `N(X,Y)` means NAND of the two robust signed bits; every assignment is a NAND tanh update followed by K amplification steps on its destination. Semicolon-separated assignments are sequential, and other robust working bits use phi carries. Every program leaves its output in U and uses at most the three work registers B,U,T. The truth string is ordered (a,b)=(0,0),(0,1),(1,0),(1,1), using 0/1 truth notation only in this table.

| Truth string | Function | Program | NAND count |
|---|---|---|---:|
| 0000 | 0 | T=N(B,B); U=N(B,T); U=N(U,U) | 3 |
| 0001 | a AND b | U=N(B,U); U=N(U,U) | 2 |
| 0010 | a AND NOT b | U=N(U,U); U=N(B,U); U=N(U,U) | 3 |
| 0011 | a | U=N(B,B); U=N(U,U) | 2 |
| 0100 | NOT a AND b | B=N(B,B); U=N(B,U); U=N(U,U) | 3 |
| 0101 | b | no update | 0 |
| 0110 | a XOR b | T=N(B,U); B=N(B,T); U=N(U,T); U=N(B,U) | 4 |
| 0111 | a OR b | B=N(B,B); U=N(U,U); U=N(B,U) | 3 |
| 1000 | NOT(a OR b) | B=N(B,B); U=N(U,U); U=N(B,U); U=N(U,U) | 4 |
| 1001 | a XNOR b | T=N(B,U); B=N(B,T); U=N(U,T); U=N(B,U); U=N(U,U) | 5 |
| 1010 | NOT b | U=N(U,U) | 1 |
| 1011 | a OR NOT b | B=N(B,B); U=N(B,U) | 2 |
| 1100 | NOT a | U=N(B,B) | 1 |
| 1101 | NOT a OR b | U=N(U,U); U=N(B,U) | 2 |
| 1110 | NOT(a AND b) | U=N(B,U) | 1 |
| 1111 | 1 | T=N(B,B); U=N(B,T) | 2 |

The table has been exhaustively checked on its four possible operand inputs with a plain Boolean interpreter. Constants and projections could instead be obtained more cheaply by exact rail/copy updates, but the displayed NAND-only form makes the five-operation bound uniform.

## Exact-draft comments

The parent draft's amplifier bound directly uses phi(u)/u>1.1 on (0,3c/4], which is correct: tanh(3/4)/(3c/4)>1.111. Its displayed estimate E_T/delta <=(10000M^3+2)4^(-39M)+3M4^(-19M), with M=N+1, is conservative by an extra factor4 in both terms and is valid. Its induction and gate-depth bounds check.

One wording repair: appending two NOT gates to make the designated output last changes the stated S and N. Instead delete gates outside the designated output's ancestry and choose a topological order with the output last; the number of gates is then at most S. If the output is an original input, read it directly. Alternatively explicitly include any appended gates in the declared S.

## Audit of polynomial-bit rounding and P/poly characterization

The parent draft's Sections7–8 are valid. For fixed width w=24 and physical coefficient error at most epsilon, rounded toward zero, compare exact hidden states with the rounded-weight network's exact hidden states. Hidden outputs are bounded by1 and all rounded weights remain bounded by1. Therefore e_1<=(d+1)epsilon and e_l<=w e_(l-1)+w epsilon in coordinate sup norm. For H>=1 this gives

 e_H <=w^(H-1)(d+3)epsilon,

with a conservative constant3. The scalar readout adds at most w e_H+w epsilon error; hence the parent bound (d+3)w^(H+1)epsilon is certainly valid. Taking epsilon<=[20(d+3)w^(H+1)]^-1 changes the output by at most1/20. The constructed teacher's margin is greater than1.9, so the rounded network retains margin greater than1. All physical coefficients require only O(H+log(d+1)) dyadic bits.

At fixed width the parameter count is O(d+H). A polynomial-depth bounded-coefficient unit-margin network therefore has polynomially many rounded advice bits, even when its original real parameters are uncomputable. This is a NONUNIFORM existence statement: no procedure is asserted for recovering rounded bits from arbitrary original reals. P/poly permits arbitrary advice strings depending on input length, so there is no hidden effectiveness assumption.

To evaluate that rounded network, choose per-neuron arithmetic/tanh error at most an inverse exponential in H, whose binary precision is O(H+log(d+1)). The same recurrence bounds the final numerical error. Clipping computed activation approximations into[-1,1] is harmless and keeps the later preactivation range literally within[-w,w]. First-layer arguments lie in[-d-1,d+1]. On these domains tanh is polynomial-time computable to polynomially many bits. For a nonnegative rational z, compute exp(2z) to sufficient absolute precision using O(d+b) Taylor terms for a b-bit target, then use (exp(2z)-1)/(exp(2z)+1); integer parts have only O(d) bits. For negative z use oddness. Rational arithmetic and division need polynomial time in d,b and the input coefficient length. Round activations back to the prescribed fixed binary precision after each update.

Thus a deterministic polynomial-time evaluator with the polynomial advice string computes the correct Boolean sign: weight rounding and activation approximation each cost less than1/4, versus the original margin1. Unrolling this computation gives polynomial-size Boolean circuits. The converse inclusion P/poly into width24 bounded-coefficient polynomial-depth margin-tanh networks is the explicit compiler. Hence these Boolean families are exactly P/poly.

The conclusion is about nonuniform representability at polynomial depth. It does not assert polynomial Frobenius product, efficient learnability, or robustness to inverse-polynomial absolute perturbations of internal analog memories.
