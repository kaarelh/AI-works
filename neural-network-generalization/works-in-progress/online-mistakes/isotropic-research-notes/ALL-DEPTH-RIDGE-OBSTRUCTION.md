# A fixed-depth teacher blocks affine-ridge repairs at every learner depth

This strengthens the fixed-depth conditional obstruction. It is not an unrestricted NNbayes mistake bound. It rules out a specific attempted proof of a canonical-prior exponential lower bound: showing that all minimum-energy predictions follow successive convex minimum-norm affine separators and that those minima have a first-layer ridge along the separator.

Let h>=2 be the depth of a fixed teacher, let L>=h be the learner depth, and let C,B>=1 bound the teacher's hidden widths and individual weights. The teacher has strict full-cube output margin greater than1/2. Use one constant input coordinate and no later biases. Write

    R=max{d(d+1)B²,C²B²,1},
    N>=2C R^(h-1).

The learner energy is

    E=(d/N)||W_1||_F²+sum_(l=2)^(L-1)||W_l||_F²+N||v||².

Both tanh and hardtanh(t)=max(-1,min(1,t)) are covered below. All statements are for every integer width satisfying the displayed bound.

## 1. A variable-sparsity teacher prefix

Choose q>=1 and delta=q^(-h/2), with q<=R. At teacher hidden layer j=1,...,h-1 use

    n_j=floor[N/(C q^j)]

copies of each teacher neuron. All unused neurons are zero. The width bound implies n_j>=N/(2C q^j)>=1. Keep the original first-layer weights, and divide each later teacher weight by the number of copies of its source. Thus every copy computes the teacher activation exactly.

At learner hidden layer h, merge delta times the teacher readout into all N neurons, dividing each readout coefficient among its source copies. Every resulting neuron has the desired sign and activation magnitude

    >delta/4  for tanh,
    >delta/2  for hardtanh.

For tanh, use tanh(delta/2)>=delta/4. For hardtanh, the sharper inequality follows directly from clipping and delta<=1.

The first-layer energy is at most R/q. Each other teacher layer has energy at most2R/q. The merge layer also has energy at most2R/q, since

    (N delta²/n_(h-1)) ||v_teacher||²
      <=2C delta² q^(h-1) C B² <=2R/q.

The total prefix energy is at most (2h-1)R/q.

A fully cloned scalar layer with entries a/N implements u -> phi(a u) and has energy a². A readout with entries a/N has energy a².

## 2. Balanced construction at short depths

### Tanh

For L>=h+1 choose

    a=2 R^(h/(2L)),
    q=max{1,R/a²},
    delta=q^(-h/2).

Then R/q<=a² and a>=2. Use the prefix above, followed by L-h-1 gain-a tanh layers and a gain-a readout. For u>0,

    tanh(a u)>=min{1/(2a),(a/2)u}.

Indeed below u=1/(2a), tanh(a u)>=a u/2; above that threshold, tanh(a u)>=tanh(1/2)>1/(2a). Hence the gain-a layers preserve a reached threshold and otherwise amplify the activation by at least a/2.

The initial magnitude exceeds delta/4. The condition needed to reach magnitude1/(2a) before the final readout is

    delta a^(L-h)>=2^(L-h).

If q>1, the left side equals a^L/R^(h/2)=2^L. If q=1, the inequality follows from a>=2. Thus the final signed output is strictly greater than1/2.

The total energy is at most

    (2h-1)a²+(L-h)a² <=2L a²
      =8L R^(h/L).                                 (1)

### Hardtanh

For L>=h+1 choose instead

    a=R^(h/(2L)), q=R/a²>=1, delta=q^(-h/2).

Now a>=1 and delta a^(L-h)=1. After the same prefix, gain-a hardtanh layers multiply the magnitude by a until it clips at1. The initial magnitude is strictly greater than delta/2, so a gain-a readout gives final margin greater than1/2. Its energy satisfies

    E<=2L R^(h/L).                                 (2)

For either activation at L=h, direct rounded cloning of the teacher gives E<=2hR, hence (E/L)^L<=(2R)^h.

## 3. Long tanh depths

Use q=R and delta=R^(-h/2) in the prefix, whose energy is at most2h. Pad with unit-gain tanh layers, then put m gain-2 layers before a unit-gain readout, where

    m=ceil(log_(3/2)[(1/2)sqrt(16R^h+3L)])+1.

This is possible when L>=h+m+1. The reciprocal inequality

    1/tanh(u)²<=1/u²+3,  0<u<=1,

shows that after at most L unit-gain layers the magnitude is at least (16R^h+3L)^(-1/2). A gain-2 layer multiplies magnitudes below1/2 by more than3/2 and preserves larger magnitudes. Thus m such layers give strict final margin. Layer counting gives

    E<=L+h+3m.                                     (3)

The elementary bound

    m<=4+2h log R+2log(L+1)

follows from 16R^h+3L<=19R^h(L+1) and the definition of m.
Let H=h(log R+1)+1. If L>=100H then L>=h+m+1: use 2log(L+1)<=L/4 for L>=32 and h+5+2hlogR<=2H+3. In that range, (3) implies

    E-L<=6H+6+6log(L+1),

and therefore

    (E/L)^L<=exp(E-L)
             <=exp(6h+12) R^(6h)(L+1)^6.           (4)

If h<L<100H, (1) gives

    (E/L)^L<=8^L R^h
             <=exp[100(h+1)log8] R^[h(100log8+1)].

Together with the L=h direct construction, these estimates give the uniform bound

    (E/L)^L <= exp[220(h+1)] R^(210h)(L+1)^6        (5)

for every L>=h.

The constants are deliberately loose. The important point is that, for fixed teacher depth h, the right side is polynomial in the teacher size and learner depth.

## 4. Long hardtanh depths

With q=R and delta=R^(-h/2), unit-gain hardtanh layers preserve every hidden activation exactly. Put

    m=ceil[(h/2)log_2 R]+1

gain-2 layers at the end, followed by a unit-gain readout. For L>=h+m+1 these layers amplify the initial magnitude greater than delta/2 to a strict margin, and

    E<=L+h+3m,
    (E/L)^L<=exp(h+6) R^[3h/(2log2)]
             <=exp(h+6)R^(3h).                     (6)

If h<L<h+m+1, then L<h+3+(h/(2log2))log R. Bound (2) yields

    (E/L)^L<=2^L R^h<=2^(h+3)R^(3h/2),

which is also at most the right side of (6). The L=h direct construction satisfies the same bound. Therefore

    (E/L)^L <= exp(h+6)R^(3h)                      (7)

at every learner depth L>=h. Unlike (5), this bound is independent of learner depth.

## 5. Conditional online consequence

Suppose that at every history the closed-global-margin energy minimum has all first-layer rows proportional to the current convex minimum-norm unit-margin affine separator a_t, and that predictions follow its affine sign. All later matrices may be arbitrary. For either activation, Lipschitz constant1 and phi(0)=0 give the ridge product bound

    Q_t=||a_t||² <= (4/d)(E/L)^L.

If each a_t has global affine absolute margin at least1, a mistaken round raises Q_t by at least4/(d+1). Thus the total number of mistakes is at most (d+1)/d times the right side of (5) for tanh, and at most (d+1)/d times the right side of (7) for hardtanh.

If only the wrong affine sign is known, multiply these bounds by4. If no ridge comparison is available after the final update, add one.

The conclusion is conditional on the affine-ridge reduction, not a claim that actual unrestricted minimizers satisfy it. It shows that a small fixed-depth teacher prevents an exponential-in-complexity lower bound through this mechanism even at an arbitrarily deep learner. A successful canonical-prior construction must exploit genuinely different nonlinear minimizers or another prediction mechanism.
