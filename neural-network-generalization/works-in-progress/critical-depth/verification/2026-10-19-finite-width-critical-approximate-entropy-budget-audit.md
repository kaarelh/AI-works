# Independent audit: approximate covariance-path entropy budget

Reviewed `source/critical-approximate-entropy-budget.tex`, SHA-256
`49f89f7ff4e1c0622bbb5dfa4ec135f2f93e2f73247ee376e2f64148bbf7e413`, on 19 October 2026.

**Verdict: the complete lemma and proof pass.**

I checked the scalar-value modulus used from `unrestricted-alternative-finite-width-upper.tex`. Its extension V(0)=V_* has |V(q)-V(q')|<=C sqrt(|q-q'|) on [0,1], together with V_*-V(q)<=Cq. Applying this to the controlled next variance and the declared next variance gives the Bellman error C sqrt(Delta). Telescoping only hidden suffixes and retaining the terminal readout cost yields the claimed prefix action budget with a total CH sqrt(Delta) error.

For transitions j>=2, the reference variance is at most one, so scalar strict dissipation gives D_j>=q_j-q_(j-1)+c q_(j-1)^2-Delta. The inflated costs E_j=D_j+Delta satisfy exact dissipation, while the total and prefix budgets increase by at most H Delta<=H sqrt(Delta). Choosing the universal constant in e=epsilon+C_1 H sqrt(Delta) large enough absorbs every such term.

For e>=1/4, Cauchy–Schwarz gives the result directly. For smaller e, applying the established last-exit dyadic-band proof to q_1,...,q_H and E_2,...,E_H is legitimate. The shifted prefixes have bounds inherited from the stronger original prefixes. Zero states are all included before the last exit from the initial low band, and every reciprocal division is restricted to states above its positive cutoff. The first transition contributes at most sqrt(A)<sqrt(3). H=1 is covered separately as stated.

The use of a single output coordinate is sufficient: |z(x0)|>=1/2 gives r>=1/(8q_H), and hence the scalar suffix bound. No signed pair or input-edge geometry is needed. The input variance bound q0<=2 does not create a hidden use of dissipation outside [0,1], because the first transition is omitted from that part of the proof.
