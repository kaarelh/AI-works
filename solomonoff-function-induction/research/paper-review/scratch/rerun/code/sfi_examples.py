"""Computable proxies for the worked examples of Solomonoff function induction (SFI).

Used by the "examples" research track (research/tracks/examples/checks/).
Everything is exact arithmetic in log2 space; randomness only enters through
the seeded simulators.  Conventions follow the track notes:

* SFI's cumulative loss on a data set D is -log2 nu(D) (semimeasure convention).
  For a mixture of random-function laws this depends only on the set D.
* A history-aware predictor sees the whole past (inputs and labels).
* An "SI-like" predictor is a Bayes mixture of joint models of the interleaved
  sequence x1 y1 x2 y2 ...; its label loss is the sum of -log2 P(y_t | past, x_t).

Two examples are implemented.

1. Eisenstat's example (brief H6).  b_i ~ Bern(1/3) i.i.d. (1 = head), and at
   each step a Bern(2/3) coin c_t says "reveal the next unrevealed head"
   (label 1) or else "reveal the next unrevealed tail" (label 0).
2. Haenni's cyclic-permutation example (brief H5).  f is a uniformly random
   cyclic permutation of {0,1}^n (strings as integers 0..N-1, N = 2^n, 0^n = 0);
   x_1 = f^{-1}(0), x_k = f^{-1}(x_{k-1}), label of x_k is x_{k-1}.
"""

from __future__ import annotations

import math
from dataclasses import dataclass, field

import numpy as np
from scipy.special import gammaln

LN2 = math.log(2.0)
LOG2_3 = math.log2(3.0)
H13 = LOG2_3 - 2.0 / 3.0          # binary entropy h(1/3) in bits


# ----------------------------------------------------------------------------
# log2 helpers
# ----------------------------------------------------------------------------

def log2_binom(n, k):
    """log2 C(n, k) (vectorised); -inf outside 0 <= k <= n."""
    n = np.asarray(n, dtype=float)
    k = np.asarray(k, dtype=float)
    out = (gammaln(n + 1) - gammaln(k + 1) - gammaln(n - k + 1)) / LN2
    bad = (k < 0) | (k > n)
    return np.where(bad, -np.inf, out)


def log2_beta_counts(h, t):
    """log2 of the Laplace (uniform-prior) Bernoulli mixture probability of a
    particular sequence with h ones and t zeros: B(h+1, t+1) = h! t! / (h+t+1)!."""
    h = np.asarray(h, dtype=float)
    t = np.asarray(t, dtype=float)
    return (gammaln(h + 1) + gammaln(t + 1) - gammaln(h + t + 2)) / LN2


def log2_falling(a, k):
    """log2 of the falling factorial a (a-1) ... (a-k+1)."""
    return (math.lgamma(a + 1) - math.lgamma(a - k + 1)) / LN2


def logsumexp2(xs):
    """log2 sum 2^x over an iterable or array (handles -inf)."""
    xs = np.asarray(list(xs) if not isinstance(xs, np.ndarray) else xs, dtype=float)
    if xs.size == 0:
        return -np.inf
    m = np.max(xs)
    if m == -np.inf:
        return -np.inf
    return float(m + np.log2(np.sum(np.exp2(xs - m))))


# ----------------------------------------------------------------------------
# Eisenstat's example
# ----------------------------------------------------------------------------

P_HEAD = 1.0 / 3.0      # P(b_i = 1)
P_SHOW_HEAD = 2.0 / 3.0  # P(c_t = 1): reveal the next unrevealed head


@dataclass
class EisenstatState:
    """Bookkeeping for the revealed set after some steps.

    tau = tail frontier = 1 + index of the last revealed tail (0 if none),
    eta = head frontier = 1 + index of the last revealed head (0 if none),
    g   = smallest unrevealed index.
    All tails below tau and all heads below eta are revealed, and nothing else.
    """
    revealed: list = field(default_factory=list)   # bools, grown on demand
    labels: dict = field(default_factory=dict)      # index -> label
    tau: int = 0
    eta: int = 0
    g: int = 0
    n_heads: int = 0
    n_tails: int = 0

    def is_revealed(self, i):
        return i < len(self.revealed) and self.revealed[i]

    def add(self, i, y):
        while len(self.revealed) <= i:
            self.revealed.append(False)
        assert not self.revealed[i]
        self.revealed[i] = True
        self.labels[i] = y
        if y == 1:
            self.eta = i + 1
            self.n_heads += 1
        else:
            self.tau = i + 1
            self.n_tails += 1
        while self.is_revealed(self.g):
            self.g += 1

    @property
    def front(self):
        return max(self.tau, self.eta)

    @property
    def touching(self):
        """True iff the revealed set is an initial segment [0, front)."""
        return self.g == self.front


def pstar_prob_one(state: EisenstatState, x: int) -> float:
    """Bayes-optimal history-aware probability that the label of the new input x is 1.

    Derivation (examples track notes, Lemma 3.8): an unrevealed index below eta is a tail and
    one below tau is a head.  If x >= front and the revealed set is not an initial
    segment, the side that is ahead determines the label.  If it is an initial
    segment [0, F), then with d = x - F the posterior odds head:tail are 2^d : 1.
    """
    F = state.front
    if x < F:
        if x < state.eta:
            return 0.0
        if x < state.tau:
            return 1.0
        raise ValueError("unrevealed index below both frontiers cannot occur")
    if state.touching:
        d = x - F
        return 1.0 / (1.0 + 2.0 ** (-d))
    return 1.0 if state.tau <= state.eta else 0.0


def true_input_log2prob(state: EisenstatState, x: int) -> float:
    """log2 of the true conditional probability of the next input x given the history."""
    F = state.front
    if state.touching:
        if x < F:
            return -np.inf
        d = x - F
        p = (2.0 / 9.0) * ((2.0 / 3.0) ** d + (1.0 / 3.0) ** d)
        return math.log2(p)
    if state.tau <= state.eta:          # heads ahead: tail reveal hits g, head reveal >= eta
        if x == state.g:
            return math.log2(1.0 / 3.0)
        if x >= state.eta:
            d = x - state.eta
            return math.log2((2.0 / 3.0) * (2.0 / 3.0) ** d * (1.0 / 3.0))
        return -np.inf
    # heads behind: head reveal hits g, tail reveal >= tau
    if x == state.g:
        return math.log2(2.0 / 3.0)
    if x >= state.tau:
        d = x - state.tau
        return math.log2((1.0 / 3.0) * (1.0 / 3.0) ** d * (2.0 / 3.0))
    return -np.inf


def simulate_eisenstat(n_steps: int, rng: np.random.Generator, record_every: int | None = None):
    """Run Eisenstat's process.

    Returns a dict with the reveal sequence, the state, the Bayes history-aware
    loss (per step), the touching-step count and an SI-like mixture's label loss.

    SI-like proxy: Bayes mixture of three joint models of (x1,y1,x2,y2,...):
      * 'true'  : the true process (inputs and labels),
      * 'labLap': true input model, labels by a Laplace i.i.d. rule (history-free),
      * 'null'  : inputs P(x) = 1/((x+1)(x+2)) and fair-coin labels,
    with prior weights 1/3 each.
    """
    L = 4 * n_steps + 64
    b = (rng.random(L) < P_HEAD).astype(np.int8)
    st = EisenstatState()
    xs, ys = [], []
    pstar_losses = np.zeros(n_steps)
    touching_steps = 0
    # SI-like mixture state (log2 weights including likelihood of the history)
    lw = np.log2(np.array([1.0, 1.0, 1.0]) / 3.0)
    si_label_loss = np.zeros(n_steps)
    lap_h = lap_t = 0
    head_ptr = 0  # search pointers
    tail_ptr = 0

    def bit(i):
        nonlocal b
        while i >= len(b):
            b = np.concatenate([b, (rng.random(len(b)) < P_HEAD).astype(np.int8)])
        return int(b[i])

    for t in range(n_steps):
        show_head = rng.random() < P_SHOW_HEAD
        if show_head:
            i = max(head_ptr, st.eta)
            while bit(i) != 1:
                i += 1
            x, y = i, 1
            head_ptr = i + 1
        else:
            i = max(tail_ptr, st.tau)
            while bit(i) != 0:
                i += 1
            x, y = i, 0
            tail_ptr = i + 1
        # Bayes history-aware predictor
        p1 = pstar_prob_one(st, x)
        py = p1 if y == 1 else 1.0 - p1
        assert py > 0.0, "P* assigned zero probability to the realised label"
        if st.touching:
            touching_steps += 1
        pstar_losses[t] = -math.log2(py)
        # SI-like mixture: input factor then label factor
        lin_true = true_input_log2prob(st, x)
        lin_null = -math.log2((x + 1.0) * (x + 2.0))
        lw = lw + np.array([lin_true, lin_true, lin_null])
        A = logsumexp2(lw)
        lab_true = math.log2(py)
        p_lap1 = (lap_h + 1.0) / (lap_h + lap_t + 2.0)
        lab_lap = math.log2(p_lap1 if y == 1 else 1.0 - p_lap1)
        lab_null = -1.0
        lw = lw + np.array([lab_true, lab_lap, lab_null])
        B = logsumexp2(lw)
        si_label_loss[t] = A - B
        if y == 1:
            lap_h += 1
        else:
            lap_t += 1
        st.add(x, y)
        xs.append(x)
        ys.append(y)
    return dict(xs=np.array(xs), ys=np.array(ys), state=st, b=b,
                pstar_losses=pstar_losses, touching_steps=touching_steps,
                si_label_losses=si_label_loss)


def threshold_cost_13(state: EisenstatState) -> float:
    """-log2 P_{1/3}(b_{<tau}) = (tau - T) log2 3 + T log2(3/2): the loss of the
    threshold hypothesis 'Bern(1/3) below tau, constant 1 at and above tau' on the
    revealed data (when all of [0, tau) is revealed; otherwise an upper bound)."""
    T = state.n_tails
    return (state.tau - T) * LOG2_3 + T * math.log2(1.5)


def iid13_cost(state: EisenstatState) -> float:
    """Loss of the i.i.d. Bern(1/3) hypothesis on the revealed data."""
    return state.n_heads * LOG2_3 + state.n_tails * math.log2(1.5)


def threshold_mixture_loss(idx, lab) -> dict:
    """Exact -log2 of an x-only Bayes mixture of random-function laws on data {(idx_j, lab_j)}.

    Components (prior weight 1/3 per family):
      * iid   : labels i.i.d. Bern(theta), theta ~ U[0,1]      (Laplace)
      * thr1_s: Bern(theta) (theta ~ U[0,1]) below s, constant 1 at and above s
      * thr0_s: Bern(theta) below s, constant 0 at and above s
    with s ~ pi(s) = 1/((s+1)(s+2)), s = 0, 1, 2, ...
    The value depends only on the set of pairs (order-free).
    Also returns the losses of the best single components.
    """
    idx = np.asarray(idx)
    lab = np.asarray(lab)
    order = np.argsort(idx)
    idx = idx[order]
    lab = lab[order]
    M = int(idx[-1]) + 1 if idx.size else 0
    h_tot = int(lab.sum())
    t_tot = int(idx.size - h_tot)
    # prefix counts below s for s = 0..M-1 (s >= M handled as a lump)
    ones = np.zeros(M + 1, dtype=np.int64)
    zeros = np.zeros(M + 1, dtype=np.int64)
    np.add.at(ones, idx[lab == 1] + 1, 1)
    np.add.at(zeros, idx[lab == 0] + 1, 1)
    h_pre = np.cumsum(ones)[:M]   # heads with index < s, s = 0..M-1
    t_pre = np.cumsum(zeros)[:M]
    s = np.arange(M)
    log_pi = -np.log2((s + 1.0) * (s + 2.0))
    lb = log2_beta_counts(h_pre, t_pre)
    thr1 = np.where(t_tot - t_pre == 0, lb, -np.inf) + log_pi
    thr0 = np.where(h_tot - h_pre == 0, lb, -np.inf) + log_pi
    lump = float(log2_beta_counts(h_tot, t_tot)) - math.log2(M + 1.0)   # sum_{s>=M} pi(s) = 1/(M+1)
    iid = float(log2_beta_counts(h_tot, t_tot))
    total = logsumexp2(np.concatenate([[iid], thr1, thr0, [lump, lump]]) - LOG2_3)
    return dict(loss=-total,
                best_thr1=-(float(np.max(thr1)) if M else 0.0),
                iid_laplace=-iid)


def bayes_xonly_surprisal(state: EisenstatState) -> float:
    """-log2 P(D_n | dom D_n) under the true process (exact; examples track notes, Prop 3.7).

    With n = |S|, M = max S + 1, g = min(N \\ S), H = number of heads:
      * no gap (S = [0, n)):   log2 C(2n, n) - log2 C(n, H)
      * gap:  log2 C(n+g, g) - log2 C(n, H) - (M-n) log2 r + log2((2/3)^(M-n) + (1/3)^(M-n)),
        r = 2/3 if the largest revealed index is a head, else 1/3.
    """
    n = state.n_heads + state.n_tails
    H = state.n_heads
    M = state.front
    g = state.g
    if g == M:
        assert M == n
        return float(log2_binom(2 * n, n) - log2_binom(n, H))
    top_label = state.labels[M - 1]
    e = M - n
    # -e log2 r + log2((2/3)^e + (1/3)^e), computed without underflow:
    #   r = 2/3: log2(1 + 2^-e);   r = 1/3: e + log2(1 + 2^-e)
    corr = math.log2(1.0 + 2.0 ** (-e)) + (0.0 if top_label == 1 else float(e))
    return float(log2_binom(n + g, g) - log2_binom(n, H) + corr)


def kappa_touching(dmax: int = 200) -> float:
    """Expected Bayes loss (bits) of one touching step:
    sum_d (2/9)[(2/3)^d log2(1+2^-d) + (1/3)^d log2(1+2^d)]."""
    tot = 0.0
    for d in range(dmax):
        tot += (2.0 / 9.0) * ((2.0 / 3.0) ** d * math.log2(1.0 + 2.0 ** (-d))
                              + (1.0 / 3.0) ** d * math.log2(1.0 + 2.0 ** d))
    return tot


# ----------------------------------------------------------------------------
# Cyclic-permutation example
# ----------------------------------------------------------------------------

def random_cycle_order(n: int, rng: np.random.Generator) -> np.ndarray:
    """x_1, ..., x_{N-1}: a uniformly random ordering of the nonzero n-bit strings
    (as integers); this is a uniformly random cyclic permutation f with
    f(x_1) = 0, f(x_k) = x_{k-1}."""
    N = 2 ** n
    xs = rng.permutation(np.arange(1, N))
    return xs


def cyclic_example_losses(n: int, rng: np.random.Generator, checkpoints=None) -> dict:
    """Losses of three proxies on the full cycle of a random cyclic permutation.

    SFI proxy (x-only, order-free): mixture (weights 1/6) of the laws
      cyc  (uniform cyclic permutation), perm (uniform permutation), func (uniform
      function), and the deterministic maps zero, identity, successor mod N.
    History proxy: mixture (weights 1/3) of the history-aware predictors
      copy (label = previous input, first label 0), unif (uniform label),
      fresh (uniform over labels not yet used).
    SI proxy (blocks of n bits as symbols): mixture (weights 1/3) of joint models
      true (inputs uniform over unseen nonzero strings then 0; labels copy),
      inright (true inputs, uniform labels), null (all symbols uniform).
    Returns cumulative losses after k steps for k in checkpoints (k = 1..N).
    """
    N = 2 ** n
    order = random_cycle_order(n, rng)
    xs = np.concatenate([order, [0]])           # x_1..x_N (x_N = 0^n closes the cycle)
    ys = np.concatenate([[0], xs[:-1]])          # y_k = x_{k-1}, y_1 = 0
    if checkpoints is None:
        checkpoints = sorted(set([1, 2, 4, N // 4, N // 2, N - 1, N]))
    out = {}
    # SFI proxy: order-free; compute at each checkpoint from scratch
    for k in checkpoints:
        Dx, Dy = xs[:k], ys[:k]
        comps = []
        # cyclic permutation law
        if k <= N - 1:
            comps.append(-log2_falling(N - 1, k))
        else:
            comps.append(-log2_falling(N - 1, N - 1))
        comps.append(-log2_falling(N, k))                       # uniform permutation
        comps.append(-k * n)                                     # uniform function
        comps.append(0.0 if np.all(Dy == 0) else -np.inf)        # zero map
        comps.append(0.0 if np.all(Dy == Dx) else -np.inf)       # identity
        comps.append(0.0 if np.all(Dy == (Dx + 1) % N) else -np.inf)  # successor
        sfi = -(logsumexp2(np.array(comps)) - math.log2(6))
        out.setdefault('sfi', {})[k] = sfi
        out.setdefault('cyc_alone', {})[k] = -comps[0]
    # History proxy and SI proxy: sequential
    lw_h = np.full(3, -math.log2(3))
    lw_s = np.full(3, -math.log2(3))
    si_lab = 0.0
    used_labels = set()
    seen_inputs = set()
    for k in range(1, N + 1):
        x, y = int(xs[k - 1]), int(ys[k - 1])
        prev = 0 if k == 1 else int(xs[k - 2])
        copy_lp = 0.0 if y == prev else -np.inf
        unif_lp = -float(n)
        fresh_lp = -math.log2(N - len(used_labels)) if y not in used_labels else -np.inf
        lw_h = lw_h + np.array([copy_lp, unif_lp, fresh_lp])
        # SI proxy
        if k <= N - 1:
            avail = N - 1 - len(seen_inputs)      # unseen nonzero strings
            true_in = -math.log2(avail) if (x != 0 and x not in seen_inputs) else -np.inf
        else:
            true_in = 0.0 if x == 0 else -np.inf
        lw_s = lw_s + np.array([true_in, true_in, -float(n)])
        A = logsumexp2(lw_s)
        lw_s = lw_s + np.array([copy_lp, -float(n), -float(n)])
        B = logsumexp2(lw_s)
        si_lab += A - B
        used_labels.add(y)
        seen_inputs.add(x)
        if k in checkpoints:
            out.setdefault('hist', {})[k] = -logsumexp2(lw_h)
            out.setdefault('si_label', {})[k] = si_lab
    out['checkpoints'] = checkpoints
    return out
