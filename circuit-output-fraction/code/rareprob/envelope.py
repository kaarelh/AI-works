"""Tractable envelopes and the envelope importance-sampling estimator.

An envelope is a nonnegative arithmetic circuit phi with nodes
    'ONE'            constant 1
    'ZERO'           constant 0
    'LIT' (i, b)     [x_i = b]
    'BOX' j          [B_j(x) = 1] for a sub-function B_j of the circuit
                     ("dense leaf"): its mass is estimated by Monte Carlo and
                     it is sampled by rejection
    'SUM' children   sum
    'PROD' children  product of children with pairwise-disjoint supports
so phi(x) counts the derivations (proof trees) of x. If phi(x) >= 1 whenever
C(x) = 1 ("phi dominates C"), then with Q = D * phi / E_D[phi]

    W = C(X) / phi(X),   X ~ Q,

lies in [0, 1] and has mean p / E_D[phi]. Without boxes E_D[phi] is exact
(bottom-up sum-product) and Q is sampled exactly (top-down: pick a SUM child
with probability proportional to its mass, recurse into every PROD child,
fill the remaining variables from D). Then p = E_D[phi] * E_Q[W], and the
relative variance is at most K - 1, K = E_D[phi] / p = E[phi(X) | C(X) = 1].

With boxes, masses are estimates m_hat; sampling with m_hat gives a proposal
whose bias on every derivation T is the factor r(T) = prod_{boxes in T}
m_hat/m. The final interval divides out the extreme values of r(T), which are
computed exactly by max-/min-product dynamic programming over derivations
from the boxes' confidence intervals.
"""

from __future__ import annotations

import math
import sys
from dataclasses import dataclass, field

import numpy as np

from .circuit import Circuit
from .dist import Product
from .stats import Estimate, sequential_mean

_TINY = sys.float_info.min  # smallest positive normal double


@dataclass
class Box:
    nnf: object  # NNF instance
    node: int
    rho: dict  # restriction (within the node's support)
    sup: int  # free support bitmask
    value: float = float("nan")
    lo: float = float("nan")
    hi: float = float("nan")
    evaluations: int = 0

    def eval(self, X: np.ndarray) -> np.ndarray:
        return self.nnf.eval_batch(X, self.node, self.rho)


@dataclass
class Envelope:
    kind: list = field(default_factory=list)
    data: list = field(default_factory=list)
    sup: list = field(default_factory=list)
    boxes: list = field(default_factory=list)
    _cons: dict = field(default_factory=dict)
    root: int = -1

    def _mk(self, kind, data, sup):
        key = (kind, data)
        v = self._cons.get(key)
        if v is not None:
            return v
        self.kind.append(kind)
        self.data.append(data)
        self.sup.append(sup)
        self._cons[key] = len(self.kind) - 1
        return len(self.kind) - 1

    def one(self):
        return self._mk("ONE", None, 0)

    def zero(self):
        return self._mk("ZERO", None, 0)

    def lit(self, i, b):
        return self._mk("LIT", (int(i), int(b)), 1 << int(i))

    def box(self, nnf, node, rho, sup) -> int:
        key = ("BOXKEY", id(nnf), node, tuple(sorted(rho.items())))
        j = self._cons.get(key)
        if j is None:
            self.boxes.append(Box(nnf, node, dict(rho), sup))
            j = len(self.boxes) - 1
            self._cons[key] = j
        return self._mk("BOX", j, sup)

    def SUM(self, ch):
        out = []
        for c in ch:
            if self.kind[c] == "ZERO":
                continue
            if self.kind[c] == "SUM":
                out.extend(self.data[c])
            else:
                out.append(c)
        if not out:
            return self.zero()
        if len(out) == 1:
            return out[0]
        out = tuple(sorted(out))  # keep multiplicity
        s = 0
        for c in out:
            s |= self.sup[c]
        return self._mk("SUM", out, s)

    def PROD(self, ch):
        out = []
        for c in ch:
            k = self.kind[c]
            if k == "ZERO":
                return self.zero()
            if k == "ONE":
                continue
            if k == "PROD":
                out.extend(self.data[c])
            else:
                out.append(c)
        if not out:
            return self.one()
        if len(out) == 1:
            return out[0]
        out = tuple(sorted(out))
        acc = 0
        for c in out:
            if acc & self.sup[c]:
                raise ValueError("PROD children must have disjoint supports")
            acc |= self.sup[c]
        return self._mk("PROD", out, acc)

    def cone(self, v=None):
        v = self.root if v is None else v
        seen, stack = set(), [v]
        while stack:
            u = stack.pop()
            if u in seen:
                continue
            seen.add(u)
            if self.kind[u] in ("SUM", "PROD"):
                stack.extend(self.data[u])
        return sorted(seen)

    def size(self):
        return len(self.cone())

    def used_boxes(self) -> list[int]:
        return sorted({self.data[u] for u in self.cone() if self.kind[u] == "BOX"})

    # ------------------------------------------------------------ semantics
    def _dp(self, D: Product, leaf_box, combine_sum, combine_prod) -> dict:
        m: dict[int, float] = {}
        for u in self.cone():
            k = self.kind[u]
            if k == "ONE":
                m[u] = 1.0
            elif k == "ZERO":
                m[u] = 0.0
            elif k == "LIT":
                i, b = self.data[u]
                m[u] = D.lit_prob(i, b)
            elif k == "BOX":
                m[u] = leaf_box(self.boxes[self.data[u]])
            elif k == "SUM":
                m[u] = combine_sum([m[c] for c in self.data[u]])
            else:
                m[u] = combine_prod([m[c] for c in self.data[u]])
        return m

    def masses(self, D: Product) -> dict[int, float]:
        """E_D[phi_v] for every node v (boxes contribute their estimates)."""
        return self._dp(D, lambda b: b.value, sum, math.prod)

    def log_masses(self, D: Product, box_value=None) -> tuple[dict[int, float], float]:
        """(log E_D[phi_v] for every node v, eta), computed in the log domain so
        that nothing underflows. eta bounds, over all derivations T, the sum of
        the local rounding errors on T (a max-sum DP); the sampler's law on
        derivations and the computed mass are both within e^{+-eta} of exact
        arithmetic, up to the discreteness of the uniform draws (see
        envelope_estimate). Boxes contribute log(box_value(b)) (default: the
        estimate)."""
        box_value = (lambda b: b.value) if box_value is None else box_value
        u53 = 2.0 ** -50  # a generous unit of rounding error
        lm: dict[int, float] = {}
        err: dict[int, float] = {}
        for u in self.cone():
            k = self.kind[u]
            if k == "ONE":
                lm[u], loc = 0.0, 0.0
            elif k == "ZERO":
                lm[u], loc = -math.inf, 0.0
            elif k in ("LIT", "BOX"):
                v = D.lit_prob(*self.data[u]) if k == "LIT" else box_value(self.boxes[self.data[u]])
                lm[u] = math.log(v) if v > 0 else -math.inf
                loc = u53 * (2.0 + abs(lm[u])) if v > 0 else 0.0
            else:
                ch = self.data[u]
                vals = [lm[c] for c in ch]
                fin = [abs(v) for v in vals if v > -math.inf]
                if k == "SUM":
                    M = max(vals)
                    lm[u] = M + math.log(math.fsum(math.exp(v - M) for v in vals)) if M > -math.inf else -math.inf
                    loc = u53 * (4.0 * len(ch) + abs(lm[u]) + max(fin, default=0.0)) if lm[u] > -math.inf else 0.0
                else:
                    lm[u] = math.fsum(vals) if all(v > -math.inf for v in vals) else -math.inf
                    loc = u53 * len(ch) * (1.0 + sum(fin))
            if k == "SUM":
                err[u] = loc + max(err[c] for c in self.data[u])
            elif k == "PROD":
                err[u] = loc + sum(err[c] for c in self.data[u])
            else:
                err[u] = loc
        return lm, 2.0 * err[self.root] + 2.0 ** -40

    def mass(self, D: Product) -> float:
        return self.masses(D)[self.root]

    def bias_range(self, D: Product) -> tuple[float, float]:
        """(min_T r(T), max_T r(T)) over derivations T with nonzero weight,
        where r(T) = prod_{boxes in T} value/true_mass, using the boxes'
        confidence intervals for the true masses. Literal-only derivations
        have r = 1. Computed with log-domain min/max DP."""

        def leaf(b):
            return (b.value / b.hi, b.value / b.lo) if b.lo > 0 else (0.0, math.inf)

        lo_hi: dict[int, tuple] = {}
        for u in self.cone():
            k = self.kind[u]
            if k in ("ONE", "LIT"):
                lo_hi[u] = (1.0, 1.0)
            elif k == "ZERO":
                lo_hi[u] = (math.inf, -math.inf)  # no derivations
            elif k == "BOX":
                lo_hi[u] = leaf(self.boxes[self.data[u]])
            elif k == "SUM":
                ch = [lo_hi[c] for c in self.data[u]]
                lo_hi[u] = (min(c[0] for c in ch), max(c[1] for c in ch))
            else:
                ch = [lo_hi[c] for c in self.data[u]]
                lo_hi[u] = (math.prod(c[0] for c in ch), math.prod(c[1] for c in ch))
        return lo_hi[self.root]

    def evaluate(self, X: np.ndarray) -> np.ndarray:
        """phi(x) for each row of X (N, n) bool; float array."""
        X = np.asarray(X, dtype=bool)
        val: dict[int, np.ndarray] = {}
        N = X.shape[0]
        for u in self.cone():
            k = self.kind[u]
            if k == "ONE":
                val[u] = np.ones(N)
            elif k == "ZERO":
                val[u] = np.zeros(N)
            elif k == "LIT":
                i, b = self.data[u]
                val[u] = (X[:, i] == bool(b)).astype(float)
            elif k == "BOX":
                val[u] = self.boxes[self.data[u]].eval(X).astype(float)
            elif k == "SUM":
                r = np.zeros(N)
                for c in self.data[u]:
                    r = r + val[c]
                val[u] = r
            else:
                r = np.ones(N)
                for c in self.data[u]:
                    r = r * val[c]
                val[u] = r
        return val[self.root]

    def sample(self, D: Product, N: int, rng: np.random.Generator,
               masses: dict[int, float] | None = None, counter: list | None = None,
               fill_cap: int | None = None) -> np.ndarray:
        """N samples from D * phi / E[phi] (exact if there are no boxes;
        with boxes, SUM choices use the boxes' estimated masses). `masses`
        are log masses as returned by log_masses. `fill_cap`: truncate every
        box fill after that many draws (RuntimeError); a truncated sampler
        agrees with the untruncated one until it stops."""
        m = self.log_masses(D)[0] if masses is None else masses  # log masses
        assert m[self.root] > -math.inf, "envelope has zero mass"
        X = D.sample(N, rng)
        order = self.cone()[::-1]  # parents before children
        reach: dict[int, list] = {self.root: [np.arange(N)]}
        for u in order:
            parts = reach.pop(u, None)
            if not parts:
                continue
            idx = np.concatenate(parts)
            if idx.size == 0:
                continue
            k = self.kind[u]
            if k == "LIT":
                i, b = self.data[u]
                X[idx, i] = bool(b)
            elif k == "BOX":
                self._rejection_fill(self.boxes[self.data[u]], D, X, idx, rng, counter, fill_cap)
            elif k == "SUM":
                ch = self.data[u]
                lw = np.array([m[c] for c in ch])
                w = np.exp(lw - lw.max())
                choice = rng.choice(len(ch), size=idx.size, p=w / w.sum())
                for j, c in enumerate(ch):
                    sel = idx[choice == j]
                    if sel.size:
                        reach.setdefault(c, []).append(sel)
            elif k == "PROD":
                for c in self.data[u]:
                    reach.setdefault(c, []).append(idx)
        return X

    @staticmethod
    def _rejection_fill(box: Box, D: Product, X, idx, rng, counter, fill_cap: int | None = None,
                        max_rounds: int = 10_000):
        """Fill the box's columns of the rows idx with i.i.d. draws from D
        conditioned on the box: draws x ~ D in batches, and the j-th hit of
        the stream fills the j-th pending row. With fill_cap = T, a fill that
        has used more than T draws (counted from the previous hit) raises
        RuntimeError, so each fill is truncated after T draws; without it,
        at most max_rounds batches are drawn."""
        cols = [i for i in range(D.n) if (box.sup >> i) & 1]
        todo = idx
        since = 0  # draws used so far by the fill in progress
        rounds = 0
        while todo.size:
            rounds += 1
            if fill_cap is None and rounds > max_rounds:
                raise RuntimeError("rejection sampling failed: box too sparse")
            k = max(64, int(1.5 * todo.size / max(box.value, 1e-3)))
            Y = D.sample(k, rng)
            ok = box.eval(Y)
            if counter is not None:
                counter[0] += k
            hits = np.nonzero(ok)[0][: todo.size]
            if fill_cap is not None:
                starts = np.concatenate(([-since], hits[:-1] + 1)) if hits.size else np.zeros(0)
                if np.any(hits - starts + 1 > fill_cap):
                    raise RuntimeError("rejection sampling truncated: box fill exceeded its cap")
                since = k - (int(hits[-1]) + 1) if hits.size else since + k
                if hits.size < todo.size and since > fill_cap:
                    raise RuntimeError("rejection sampling truncated: box fill exceeded its cap")
            if hits.size:
                X[np.ix_(todo[: hits.size], cols)] = Y[np.ix_(hits, cols)]
                todo = todo[hits.size:]


def estimate_boxes(env: Envelope, D: Product, eps: float, delta: float,
                   rng: np.random.Generator, max_samples: int = 10**6) -> int:
    """Estimate every box mass to relative error eps (KL intervals at level
    delta / #boxes). Returns total evaluations used."""
    used = env.used_boxes()
    if not used:
        return 0
    d = delta / len(used)
    total = 0
    for j in used:
        b = env.boxes[j]

        def draw(k, b=b):  # bounded batches: a stage can be large
            out = []
            while k > 0:
                c = min(k, 1 << 15)
                out.append(np.asarray(b.eval(D.sample(c, rng)), dtype=bool))
                k -= c
            return np.concatenate(out).astype(float) if out else np.zeros(0)

        est = sequential_mean(draw, eps, d, max_samples=max_samples)
        b.value, b.lo, b.hi = est.value, est.lo, est.hi
        b.evaluations = est.samples
        total += est.samples
    return total


def envelope_estimate(C: Circuit, D: Product, env: Envelope, eps: float = 0.1,
                      delta: float = 0.05, max_samples: int = 10**6,
                      rng: np.random.Generator | None = None, batch_cap: int = 1 << 15,
                      box_eps: float | None = None, fill_cap: int | None = None) -> Estimate:
    """(eps, delta) interval for p = Pr_D[C=1], assuming env dominates C.

    fill_cap truncates every box fill of the rejection sampler after that
    many draws (RuntimeError, which callers turn into [0, 1]).

    If env does not dominate C, the interval is still valid for
    Pr_D[C=1 and phi>0] <= p, so its lower end is a valid lower bound on p.

    Floating point: masses are kept in the log domain, and the interval is
    widened by e^{+-eta} (the max-path rounding bound of log_masses), by an
    absolute tau on the mean of W in [0,1] for the discreteness of the uniform
    draws (each Bernoulli or categorical draw is off by at most 2^-53 per
    category in total variation), and rounded outwards on conversion.
    """
    rng = np.random.default_rng() if rng is None else rng
    used = env.used_boxes()
    d_box = delta / 2 if used else 0.0
    d_is = delta - d_box
    box_evals = 0
    L = max(1, _max_boxes_per_derivation(env)) if used else 0
    if used:
        # box errors compound along derivations: rho_max / rho_min <= (1 + eps/(8L))^{2L} <= e^{eps/4}
        box_evals = estimate_boxes(env, D, box_eps or eps / (8 * L), d_box, rng, max_samples)
    lm, eta = env.log_masses(D)
    logZ = lm[env.root]
    if used:
        # deductive upper bound p <= E_D[phi] <= mass with every box at its upper end
        lm_hi, eta_hi = env.log_masses(D, box_value=lambda b: b.hi)
        z_upper = _exp_up(lm_hi[env.root] + eta_hi)
    else:
        z_upper = math.inf
    if logZ == -math.inf:
        if not used:  # exact zero mass: phi = 0 everywhere, and phi dominates C
            return Estimate(0.0, 0.0, 0.0, 0, box_evals, delta, "envelope mass 0")
        return Estimate(0.0, 0.0, z_upper, 0, box_evals, delta, "estimated envelope mass 0")
    counter = [0]

    def draw(k):
        out = []
        while k > 0:
            b = min(k, batch_cap)
            X = env.sample(D, b, rng, lm, counter, fill_cap)
            c = C.eval_bits(X)
            phi = env.evaluate(X)
            w = np.zeros(b)
            w[c] = 1.0 / phi[c]
            out.append(w)
            k -= b
        return np.concatenate(out)

    eps_is = eps / 4 if used else 0.999 * eps  # slack for the outward rounding
    est = sequential_mean(draw, eps_is, d_is, max_samples=max_samples)
    rmin, rmax = env.bias_range(D) if used else (1.0, 1.0)
    n_cat = sum(len(env.data[u]) for u in env.cone() if env.kind[u] == "SUM")
    tau = (D.n + n_cat + 8) * 2.0 ** -52
    eta = eta + 2.0 ** -45 * (L + 1)  # rounding in the bias range and in 1/phi
    lo_is, hi_is = max(0.0, est.lo - tau), min(1.0, est.hi + tau)
    if lo_is > 0 and rmax < math.inf:
        lo = _exp_down(math.log(lo_is) + logZ - eta - math.log(rmax))
    else:
        lo = 0.0
    if rmin > 0:
        hi = _exp_up(math.log(hi_is) + logZ + eta - math.log(rmin)) if hi_is > 0 else 0.0
    else:
        hi = math.inf
    hi = min(hi, z_upper)
    val = min(max(est.value * math.exp(logZ), lo), hi)
    return Estimate(val, lo, hi, est.samples, est.samples + counter[0] + box_evals, delta,
                    f"envelope mass {math.exp(logZ):.4g}, size {env.size()}, boxes {len(used)}")


def _exp_up(x: float) -> float:
    """An upper bound on e^x that is positive whenever x > -inf. Below the
    normal range math.exp has an absolute error of up to an ulp of 0, so
    there it adds 4 such ulps (exact in the subnormal range)."""
    if x == -math.inf:
        return 0.0
    y = math.exp(x)
    if y < _TINY:
        return y + 4 * math.ulp(0.0)
    return math.nextafter(y * (1 + 2.0 ** -50), math.inf)


def _exp_down(x: float) -> float:
    """A lower bound on e^x; 0 below twice the normal range's minimum."""
    if x == -math.inf:
        return 0.0
    y = math.exp(x)
    if y < 2 * _TINY:
        return 0.0
    return math.nextafter(y * (1 - 2.0 ** -50), 0.0)


def _max_boxes_per_derivation(env: Envelope) -> int:
    best: dict[int, int] = {}
    for u in env.cone():
        k = env.kind[u]
        if k == "BOX":
            best[u] = 1
        elif k == "SUM":
            best[u] = max(best[c] for c in env.data[u])
        elif k == "PROD":
            best[u] = sum(best[c] for c in env.data[u])
        else:
            best[u] = 0
    return best[env.root]


def dnf_envelope(terms, n: int) -> Envelope:
    """Envelope SUM_j PROD_{l in term_j} [l] for a DNF (KLM as a special case)."""
    E = Envelope()
    E.root = E.SUM([E.PROD([E.lit(i, b) for (i, b) in t]) for t in terms])
    return E
