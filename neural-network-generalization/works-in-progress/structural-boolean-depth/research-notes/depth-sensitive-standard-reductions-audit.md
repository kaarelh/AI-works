# Depth-sensitive audit of standard Boolean circuit reductions

Research scratch, 25 October 2026. No public manuscript edits. This supplements
`general-depth-checkpoints.md` and `time-space-subexponential-audit.md`.

Let a bounded-fanin Boolean circuit have input dimension `d`, gate count `s`,
supplied depth `h`, and let the intended neural learner have depth `L >= h`.
The question here is whether standard reductions yield `log P_F=o(L)` for
**every** circuit with `d,s <= poly(L)`, including `h=Theta(L)`. None of the
reductions checked below establishes that assertion. Two additional structural
regimes do admit explicit bounds.

Write

    K = log(d+s+L+3),    g = K/log(K+2).

The previously established cone-blocking compiler gives, for a depth-`a`
bounded-fanin circuit of polynomial resources,

    log P_F = O(K + a g).                                      (1)

An arbitrary function of `b` Boolean bits has a constant-threshold-depth
truth-table implementation with `log P_F=O(b+log(b+2))`. When these two
constructions are composed, their exponents add. Required internal Boolean
accuracy can be inverse polynomial in the number of boundary bits; the extra
gain is logarithmic and is absorbed by `K`. This is a statement about Boolean
states, not unrestricted real tanh states.

## 1. Keeping the useful structure in the synchronous depth reduction

Gál--Jang prove minimum-depth bounds `O(sqrt(s log s))` for layered circuits and
`O(sqrt s)` for synchronous circuits. The former is obtained through the
Dymond--Tompa two-person pebbling theorem, which produces a **formula** of the
new depth. It does not preserve polynomial size. Its automatic size bound is
`exp(O(sqrt(s log s)))`; applying the existing formula compiler therefore gives
`log P_F=O(s)` when `s,d,L` are polynomially related. This is not `o(L)` for
general `s=poly(L)`.

The synchronous proof has a more useful mixed structure. All inputs are at
level zero and every wire goes between adjacent levels. For a parameter `y`,
take the first level with at most `y` gates. Every preceding level has more
than `y` gates, so the retained prefix has depth at most `s/y+O(1)`. The entire
suffix is a function of the at most `y` cut bits and may be replaced by its
truth table. Thus (1), applied only to the retained prefix, proves

    log P_F <= O(K + y + (s/y) g).                              (2)

If no such level exists before the output, retaining the whole circuit gives
the same bound because its depth is at most `s/y+O(1)`. Choosing an integer
`y` comparable to `sqrt(s g)` yields

    log P_F <= O(K + sqrt(s K/log(K+2))).                       (3)

More accurately, if `w_j` is the actual width of the `j`th level, one can use

    log P_F <= O(K + min_j [j g + w_j]).                        (4)

For polynomial resources and `h=Theta(L)`, (3) is sublinear in `L` whenever

    s = o(L^2 log log L / log L).                              (5)

This is a limited positive regime, not the requested all-polynomial-size
theorem. For a uniform width bound `C` and a Boolean first layer, cutting at
level one already gives `O(C+K)`, often stronger than (3). Formula (3) is useful
when early levels may be wide but a small cut is reached soon. If new input
variables are injected after a cut, their distinct values must also be included
in the suffix state. The cut width in (4) then becomes `w_j+r_j`, where `r_j`
counts distinct subsequently injected input bits. Omitting these bits would
invalidate the reduction.

Primary source: Anna Gál and Jing-Tang Jang, *The Size and Depth of Layered
Boolean Circuits*, LATIN 2010, §§3--4, especially Theorem D and the proof of
Theorem 2: https://www.cs.utexas.edu/~panni/sizedepth.pdf . The published IPL
version has DOI https://doi.org/10.1016/j.ipl.2010.11.023 . Bounds (2)--(5) are
the present combination with the existing neural compiler.

## 2. A treewidth regime, with the table size charged explicitly

Let `v` count all circuit vertices, including literal-input vertices, and let
`k` be the treewidth of its underlying undirected graph. There is a tanh
constant-margin realization with

    log P_F = O((k+log(v+d+3)) log(v+3)),                       (6)

and physical depth `O(log(v+3))`. The hidden width and coefficient magnitudes
may be `2^{O(k)} poly(v+d)`; these exponential factors are included in (6).

Here is the resource-accounted dynamic-programming proof.

Start with a binary tree decomposition of depth `O(log(v+3))`, polynomially
many bags, and bag size `O(k+1)`. The standard balanced-decomposition theorem
gives such a decomposition. Enlarge each bag by adding the at most two
predecessors of every circuit vertex already in it. Bag size grows by at most
three. Running intersection is preserved: for a vertex `u`, its old bag subtree
meets the old subtree of every vertex having `u` as predecessor, because the
corresponding circuit edge is covered by a bag. The enlarged bags therefore
form a tree decomposition of the ternary gate-constraint graph.

Introduce a Boolean variable for every circuit vertex. Anchor each gate
constraint, each input equation `z_u=x_i`, and the output condition `z_out=1`
at one bag containing its scope. Acyclicity and the gate equations imply that
this constraint system is satisfiable exactly when the circuit accepts `x`.

For a bag `B_t` and assignment `a` to it, let `A_t(a;x)` assert that `a` extends
to an assignment satisfying all constraints anchored in the subtree below `t`.
If `t` has children `l,r`, then

    A_t(a;x) = Local_t(a;x)
               AND [OR over b agreeing with a: A_l(b;x)]
               AND [OR over c agreeing with a: A_r(c;x)].       (7)

The running-intersection property proves both directions of this identity.
For fixed `a`, gate constraints in `Local_t` are constants, while its input
constraints are a conjunction of at most `O(k+1)` input literals. Precompute
these local terms and retain them until their merge level. Each merge uses two
unbounded-fanin threshold layers. There are `2^{O(k)}` table entries and at
most `2^{O(k)}` connections per entry, hence total gates and wires are
`2^{O(k)} poly(v+d)`. The whole threshold circuit has depth `O(log(v+3))` and
integer coefficient/bias magnitudes at most `2^{O(k)} poly(v+d)`.

For completeness, replace each threshold gate by a sufficiently steep tanh.
If `F` bounds fan-in, requiring each previous gate to be within `1/(10F)` of
its Boolean value preserves a fixed sign margin at the next threshold. A gain
`O(log(F+2))` achieves this accuracy. Consequently every layer has Frobenius
norm with logarithm `O(k+log(v+d+3))`; multiplying over the stated number of
layers proves (6). This also accounts for identity padding and constant rails.

Thus, when `v,d <= poly(L)`, a sufficient condition for sublinear logarithmic
product is

    k = o(L/log L).                                           (8)

This can cover wide circuits with small treewidth. It gives no all-width result:
polynomial-size, polynomial-depth circuits need not have such small treewidth.
No graph-parameter lower bound on their *minimum neural product* is asserted.

The balanced decomposition theorem is stated precisely as Lemma 1 of Maurice
Jansen and Jayalal Sarma, *Balancing Bounded Treewidth Circuits*, citing
Bodlaender's Theorem 4.3: width `3k+2`, binary depth at most
`2 ceil(log_{5/4} v)`. Source:
https://www.cse.iitm.ac.in/~jayalal/research/papers/JS10.pdf . A modern statement
with explicit `O(kv)` construction time is Lemma 3.6 of Bodlaender, Groenland,
and Jacob, https://arxiv.org/abs/2206.11832 . The dynamic-programming argument
above avoids inserting only a bounded-fanin depth bound while forgetting the
replacement size.

## 3. What the generic standard reductions actually charge

**Valiant edge deletion.** For a DAG with `m` edges and depth `h`, the classical
lemma removes at most `O(m log(h/b)/log h)` edges to leave depth at most `b`.
Guessing cut-edge values and expanding residual cones gives `log P_F=O(B(b))`,
where the generic resource expression is

    B(b) = m log(h/b)/log h + 2^b + log(d+s).                   (9)

For `m>=h` and growing `h`, this displayed expression does not become
`o(h)`: if `b>=log_2 h`, its `2^b` term is at least `h`; below that threshold,
`log(h/b)/log h=1-o(1)`. This is only a limitation of the generic parameter
guarantee. A particular circuit may have far smaller cuts. The residue-class
cut in an already layered graph yields the previously recorded `s/log s`
budget and must use the size *after* any identity insertion.

**Functional gate-elimination depth reduction.** Golovnev--Kulikov--Williams
give, for arbitrary depth, an OR of `2^{ceil(s/3.9)}` bounded-width CNFs.
The corresponding constant-depth threshold/tanh construction has logarithmic
product `O(s+log d)`. This is an improvement over a naive full circuit-state
enumeration, but remains a size bound rather than a sublinear-depth bound.
Their discussion also explicitly distinguishes graph-only reductions from
functional ones. Source: *Circuit Depth Reductions*, ITCS 2021, Theorem 1.1
and §1.6.1, https://www.golovnev.org/papers/depth.pdf .

**Polynomial-processor parallelization.** Williams' time/parallel-depth
tradeoff gives semi-unbounded-fanin circuits of size
`T^{O(1)} 2^{O(T/q)}` and depth `O(q)` for suitable `q`. Direct norm accounting
therefore gives a budget `O(T+q log T)`, not an established `o(T)` bound.
Moreover a serial evaluation of a size-`s` circuit has time tied to `s`, not
its parallel depth `h`. Source: *Parallelizing Time With Polynomial Circuits*,
Theorem 1.2 and Corollary 1.2,
https://people.csail.mit.edu/rrw/spaa-journal-rev4.pdf . The earlier
Chandra--Stockmeyer--Vishkin cone blocking recalled there is the same
`log log` blocking mechanism already accounted for in (1).

**Arithmetic depth reduction.** VSBR and the depth-four arithmetic reductions
require a bounded formal polynomial degree. Arithmetizing a Boolean depth-`h`
circuit can have degree `2^h`. A Boolean function's unique multilinear
representative has degree at most `d`, but a small circuit over the Boolean
quotient does not automatically give a comparably small arithmetic circuit for
that representative. Repeatedly arithmetizing `AND(z,z)` illustrates the degree
issue even though that particular Boolean circuit simplifies immediately.
Thus the formal-degree hypothesis cannot be replaced silently by input count.

## 4. Remaining generic case

The unresolved regime includes circuits with `d>=Omega(L)`, no early
sublinear-bit cut, large treewidth, and no known small-space or small-formula
semantic simulation, even though all supplied resources are polynomial in
`L`. Standard bounds in total size do not resolve this regime.

The existing low-product-to-PNC1 converse produces integer **arithmetic sign**
formulas; it must not silently be promoted to an equally small Boolean formula
simulation. The existing FAQ already records the relevant quantitative
representation consequences. No unconditional impossibility is claimed here.
The present audit yields the restricted upper bounds (3) and (6), not the
requested universal compiler.
