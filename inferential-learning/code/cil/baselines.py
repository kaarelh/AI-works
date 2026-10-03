"""Statistical step verifiers: the average-case baseline (process-reward-model style).

A *statistical verifier* scores a step ``before -> after`` (in a context of
facts) with a classifier trained on labelled examples, and accepts it iff the
score clears a threshold.  This mimics a process reward model (PRM): it is
trained to separate human-like valid steps from human-like invalid ones, and it
is judged by its in-distribution accuracy.  It does **not** represent rules, so
nothing ties its acceptance region to the set of valid steps outside the
training distribution -- which is exactly what an adversarial prover exploits
(see :mod:`cil.provers` and ``experiments/exp_adversarial_prover.py``).

Features (:class:`StepFeaturizer`)
----------------------------------
The step is reduced to its minimal rewrite core ``(u, v)`` (the deepest entry
of :func:`cil.rules.diff_chain`).  Features are

* hashed bags of subterm-shape n-grams of ``u`` (prefix ``L``), of ``v``
  (``R``) and their count differences (``D``): node symbols, depth-1 shapes
  ``f(g,h)``, parent>child>grandchild paths, and the depth-2 root shape;
* numeric 'tree-edit' features: sizes and depths and their changes, the depth
  of the rewrite position, whether one side is a subterm of the other, leaf
  multiset agreement, atoms introduced / dropped, Jaccard overlap of the
  subterm sets, the largest common subterm, the relative size of the
  anti-unifier ``lgg(u, v)``, numeral sums, and the number of context facts.

Symbols are abstracted: object atoms become ``atom`` and numerals above 3
become ``N`` (so the classifier can generalise across variable names and
numbers, as a learned verifier must).

Training data (:func:`build_step_dataset`)
------------------------------------------
Positives are human steps that a world oracle cannot refute (as if each step
were labelled by a careful annotator, as in PRM800K -- so the baseline gets
*more* supervision than the positive-only rule learner).  Negatives are (i) the
human steps that the oracle refutes (sporadic noise, systematic fallacies),
(ii) random perturbations of human steps, anywhere in the result term and
inside the rewritten core (kept only if refuted), and optionally (iii)
instances of the known fallacy schemas in human-like contexts.

Models: logistic regression (``'logreg'``), histogram gradient boosting
(``'gboost'``) and a random forest (``'forest'``), all from scikit-learn and
deterministic given the seed.

Thresholds (:func:`calibrate_threshold`) are calibrated on an in-distribution
calibration set to a target *balanced* precision ``TPR / (TPR + FPR)`` (the
precision under equal class priors).
"""
from __future__ import annotations

import random
from collections import Counter
from dataclasses import dataclass
from typing import Dict, List, Optional, Sequence, Tuple

import numpy as np

from .domains import algebra as alg
from .rules import diff_chain
from .terms import App, Term, Var, atoms, depth, lgg, nonvar_size, subterms

__all__ = [
    "StepFeaturizer", "LabeledExample", "build_step_dataset", "StatisticalVerifier",
    "calibrate_threshold", "binary_metrics", "roc_auc",
]


# ---------------------------------------------------------------------------
# Featurisation
# ---------------------------------------------------------------------------


def _sym(t: Term) -> str:
    """Abstract node symbol: operators keep their head, atoms -> 'atom',
    numerals 0..3 keep their value, larger numerals -> 'N'."""
    if type(t) is Var:
        return "?"
    if t.args:
        return t.head
    if t.head.isdigit():
        return t.head if len(t.head) == 1 and t.head in "0123" else "N"
    return "atom"


def _shape1(t: Term) -> str:
    if type(t) is Var or not t.args:
        return _sym(t)
    return _sym(t) + "(" + ",".join(_sym(a) for a in t.args) + ")"


def _shape2(t: Term) -> str:
    if type(t) is Var or not t.args:
        return _sym(t)
    return _sym(t) + "(" + ",".join(_shape1(a) for a in t.args) + ")"


def _tokens(t: Term) -> Counter:
    """Bag of subterm-shape n-grams of ``t``."""
    c: Counter = Counter()
    c["r2:" + _shape2(t)] += 1
    stack = [(t, None)]
    while stack:
        u, parent = stack.pop()
        s = _sym(u)
        c["u:" + s] += 1
        if type(u) is App and u.args:
            c["s:" + _shape1(u)] += 1
            for i, a in enumerate(u.args):
                c[f"b:{s}>{i}{_sym(a)}"] += 1
                if type(a) is App and a.args:
                    for j, g in enumerate(a.args):
                        c[f"t:{s}>{i}{_sym(a)}>{j}{_sym(g)}"] += 1
                stack.append((a, u))
    return c


def _leaves(t: Term) -> Counter:
    c: Counter = Counter()
    for _, u in subterms(t):
        if type(u) is App and not u.args:
            c[u.head] += 1
    return c


def _numeral_sum(t: Term) -> float:
    s = 0
    for _, u in subterms(t):
        if type(u) is App and not u.args and u.head.isdigit():
            s += min(int(u.head), 100)
    return float(s)


NUMERIC_NAMES = [
    "size_u", "size_v", "dsize", "size_before", "size_after", "depth_u", "depth_v", "ddepth",
    "chain_len", "core_depth", "v_sub_u", "u_sub_v", "leaf_symdiff", "leaves_equal",
    "atoms_u", "atoms_v", "atoms_new", "atoms_dropped", "jaccard_sub", "max_common_sub",
    "lgg_rel", "numsum_u", "numsum_v", "dnumsum", "n_facts", "facts_on_core_atoms", "same_head",
]


class StepFeaturizer:
    """Maps steps to sparse feature vectors (hashed n-grams + numeric features).

    The hash is scikit-learn's MurmurHash3 (via ``FeatureHasher``), so features
    do not depend on ``PYTHONHASHSEED``."""

    def __init__(self, n_hash: int = 1024, signature: bool = True):
        from sklearn.feature_extraction import FeatureHasher
        self.n_hash = n_hash
        self.signature = signature
        self.hasher = FeatureHasher(n_features=n_hash, input_type="dict", alternate_sign=False)
        self.n_features = n_hash + len(NUMERIC_NAMES)

    def _tokdict(self, tu: Counter, tv: Counter, u: Term, v: Term) -> Dict[str, float]:
        d: Dict[str, float] = {}
        for k, n in tu.items():
            d["L" + k] = float(n)
        for k, n in tv.items():
            d["R" + k] = float(n)
        for k in set(tu) | set(tv):
            diff = tv.get(k, 0) - tu.get(k, 0)
            if diff:
                d["D" + k] = float(diff)
        # pairs of root shapes ('which kind of term becomes which kind of term')
        d["P1:" + _shape1(u) + "=>" + _shape1(v)] = 1.0
        d["P2:" + _shape2(u) + "=>" + _shape2(v)] = 1.0
        if self.signature:
            # abstract rule signature: the rhs with every subterm that also occurs
            # in the lhs replaced by a reference to its lhs position
            from .learners import shape_key
            d["K:" + repr(shape_key(u, v, "abstract"))] = 1.0
        return d

    def features(self, before: Term, after: Term, facts=frozenset(), both: bool = False):
        """``(token dict, numeric list)`` of the step; with ``both=True`` a pair
        ``(forward, reverse)`` where reverse is the step ``after -> before``
        (computed from the same difference chain)."""
        ch = diff_chain(before, after)
        if not ch:
            z = ({}, [0.0] * len(NUMERIC_NAMES))
            return (z, z) if both else z
        pos, u, v = ch[0]
        tu, tv = _tokens(u), _tokens(v)
        su = {w for _, w in subterms(u)}
        sv = {w for _, w in subterms(v)}
        common = su & sv
        lu, lv = _leaves(u), _leaves(v)
        au, av = atoms(u), atoms(v)
        g, _, _ = lgg(u, v)
        fatoms = set()
        for _, t in facts:
            fatoms |= atoms(t)
        shared = dict(
            leaf_symdiff=float(sum(((lu - lv) + (lv - lu)).values())), leaves_equal=float(lu == lv),
            jac=len(common) / max(1, len(su | sv)), maxc=float(max((w.size for w in common), default=0)),
            lggr=nonvar_size(g) / max(u.size, v.size), nf=float(len(facts)),
            fc=float(bool(fatoms & (au | av))),
            sh=float(type(u) is App and type(v) is App and u.head == v.head))
        nsu, nsv = _numeral_sum(u), _numeral_sum(v)

        def num(u, v, b, a, s_u, s_v, a_u, a_v, n_u, n_v):
            return [
                float(u.size), float(v.size), float(v.size - u.size), float(b.size), float(a.size),
                float(depth(u)), float(depth(v)), float(depth(v) - depth(u)),
                float(len(ch)), float(len(pos)), float(v in s_u), float(u in s_v),
                shared["leaf_symdiff"], shared["leaves_equal"],
                float(len(a_u)), float(len(a_v)), float(len(a_v - a_u)), float(len(a_u - a_v)),
                shared["jac"], shared["maxc"], shared["lggr"],
                n_u, n_v, n_v - n_u, shared["nf"], shared["fc"], shared["sh"],
            ]

        fwd = (self._tokdict(tu, tv, u, v), num(u, v, before, after, su, sv, au, av, nsu, nsv))
        if not both:
            return fwd
        rev = (self._tokdict(tv, tu, v, u), num(v, u, after, before, sv, su, av, au, nsv, nsu))
        return fwd, rev

    def token_dict(self, before: Term, after: Term) -> Dict[str, float]:
        return self.features(before, after)[0]

    def numeric(self, before: Term, after: Term, facts=frozenset()) -> List[float]:
        return self.features(before, after, facts)[1]

    def _assemble(self, parts):
        import scipy.sparse as sp
        H = self.hasher.transform([d for d, _ in parts])
        N = sp.csr_matrix(np.array([n for _, n in parts], dtype=np.float64).reshape(len(parts), len(NUMERIC_NAMES)))
        return sp.hstack([H, N], format="csr")

    def transform(self, steps: Sequence[Tuple[Term, Term, frozenset]]):
        """Sparse CSR matrix (n_steps x n_features)."""
        return self._assemble([self.features(b, a, f) for b, a, f in steps])

    def transform_both(self, steps: Sequence[Tuple[Term, Term, frozenset]]):
        """Rows ``2i`` and ``2i + 1`` are step ``i`` and its reverse."""
        parts = []
        for b, a, f in steps:
            fw, rv = self.features(b, a, f, both=True)
            parts.append(fw)
            parts.append(rv)
        return self._assemble(parts)


# ---------------------------------------------------------------------------
# Datasets
# ---------------------------------------------------------------------------


@dataclass
class LabeledExample:
    before: Term
    after: Term
    facts: frozenset
    label: int            # 1 = valid, 0 = invalid (oracle label)
    source: str           # 'human:<kind>', 'perturb_any', 'perturb_core', 'fallacy_inst'
    group: int = 0        # derivation index (for group-wise splits)


def _perturb_core(rng: random.Random, before: Term, after: Term) -> Optional[Term]:
    """Mutate inside the rewritten core of the step (a near-miss of the step)."""
    ch = diff_chain(before, after)
    if not ch:
        return None
    pos, _, v = ch[0]
    m = alg._mutate(rng, v)
    if m is None:
        return None
    from .terms import replace
    return replace(after, pos, m)


def build_step_dataset(steps, label_oracle: alg.WorldOracle, seed: int, n_perturb_any: int = 1,
                       n_perturb_core: int = 1, n_fallacy: int = 0, label_points: int = 30) -> List[LabeledExample]:
    """Labelled in-distribution step data from human training steps (see module doc).

    ``steps`` are :class:`cil.learners.TrainStep` objects; built-in arithmetic
    steps are skipped (arithmetic is checked by computation, not learned).
    Labels come from ``label_oracle`` (a refuted step is certainly invalid; an
    unrefuted one is labelled valid).  Perturbations that the oracle cannot
    refute are dropped (they are neither clearly invalid nor human-like)."""
    rng = random.Random(seed)
    out: List[LabeledExample] = []

    def refuted(b, a, F, n=label_points):
        return label_oracle.counterexample(b, a, F, n=n) is not None

    for h in steps:
        if h.arith:
            continue
        lab = 0 if refuted(h.before, h.after, h.facts) else 1
        out.append(LabeledExample(h.before, h.after, h.facts, lab, "human:" + h.kind.split(":")[0], h.deriv))
        for src, n in (("perturb_any", n_perturb_any), ("perturb_core", n_perturb_core)):
            for _ in range(n):
                m = alg._mutate(rng, h.after) if src == "perturb_any" else _perturb_core(rng, h.before, h.after)
                if m is None or m == h.before or m == h.after or m.size > 60:
                    continue
                if refuted(h.before, m, h.facts, n=20):
                    out.append(LabeledExample(h.before, m, h.facts, 0, src, h.deriv))
    if n_fallacy:
        from .evaluation import make_invalid_steps
        for k, s in enumerate(make_invalid_steps(n_fallacy, "id", seed=seed + 17, label_oracle=label_oracle,
                                                 kinds=("fallacy",))):
            out.append(LabeledExample(s.before, s.after, s.facts, 0, "fallacy_inst", -1 - k))
    return out


# ---------------------------------------------------------------------------
# Metrics and calibration
# ---------------------------------------------------------------------------


def roc_auc(scores: Sequence[float], labels: Sequence[int]) -> float:
    from sklearn.metrics import roc_auc_score
    return float(roc_auc_score(labels, scores))


def binary_metrics(scores: Sequence[float], labels: Sequence[int], threshold: float) -> Dict[str, float]:
    """TPR (recall on valid steps), FPR (false-accept rate on invalid steps),
    raw precision, balanced precision TPR/(TPR+FPR), balanced accuracy and raw
    accuracy of the rule ``accept iff score >= threshold``."""
    s = np.asarray(scores, dtype=float)
    y = np.asarray(labels, dtype=int)
    acc = s >= threshold
    P, N = max(1, int((y == 1).sum())), max(1, int((y == 0).sum()))
    tp = int((acc & (y == 1)).sum())
    fp = int((acc & (y == 0)).sum())
    tpr, fpr = tp / P, fp / N
    return {
        "threshold": float(threshold), "tpr": tpr, "fpr": fpr,
        "precision": tp / max(1, tp + fp),
        "balanced_precision": tpr / (tpr + fpr) if tpr + fpr > 0 else 1.0,
        "balanced_accuracy": 0.5 * (tpr + 1 - fpr),
        "accuracy": float((acc == (y == 1)).mean()),
        "n_pos": int((y == 1).sum()), "n_neg": int((y == 0).sum()), "fp": fp, "tp": tp,
    }


def calibrate_threshold(scores: Sequence[float], labels: Sequence[int], target_precision: float) -> float:
    """The threshold with the highest recall among those attaining balanced
    precision ``>= target_precision`` on the calibration data (the usual
    operating-point choice on a precision-recall curve).

    ``target_precision = 1.0`` gives the lowest threshold above the highest
    invalid score (no false accept on the calibration set)."""
    s = np.asarray(scores, dtype=float)
    y = np.asarray(labels, dtype=int)
    P, N = max(1, int((y == 1).sum())), max(1, int((y == 0).sum()))
    order = np.argsort(-s, kind="mergesort")
    s_sorted, y_sorted = s[order], y[order]
    tp = np.cumsum(y_sorted == 1)
    fp = np.cumsum(y_sorted == 0)
    tpr, fpr = tp / P, fp / N
    with np.errstate(invalid="ignore", divide="ignore"):
        bprec = np.where(tpr + fpr > 0, tpr / (tpr + fpr), 1.0)
    # candidate cut after position i accepts the i+1 highest scores; only cut
    # between distinct score values
    best = None
    for i in range(len(s_sorted)):
        if i + 1 < len(s_sorted) and s_sorted[i + 1] == s_sorted[i]:
            continue          # only cut between distinct score values
        if bprec[i] >= target_precision - 1e-12:
            best = s_sorted[i]
    if best is None:
        # nothing can be accepted at this precision: threshold above every score
        return float(np.nextafter(s_sorted[0], np.inf)) if len(s_sorted) else 1.0
    return float(best)


# ---------------------------------------------------------------------------
# The statistical verifier
# ---------------------------------------------------------------------------


class StatisticalVerifier:
    """A PRM-style step classifier with a decision threshold.

    ``accepts(before, after, facts)`` is True iff the step is reflexive, a
    correct numeral evaluation (the same trusted arithmetic the rule-based
    verifiers use), or ``score >= threshold``.  ``score`` is the classifier's
    probability that the step is valid.  ``score_batch`` scores many steps at
    once (the prover uses it; results are cached per step)."""

    def __init__(self, model: str = "gboost", seed: int = 0, threshold: float = 0.5, n_hash: int = 2048):
        self.model_name = model
        self.seed = seed
        self.threshold = threshold
        self.feat = StepFeaturizer(n_hash)
        self.clf = self._make(model, seed)
        self._cache: Dict[Tuple[Term, Term, frozenset], float] = {}
        self._ecache: Dict[Tuple[Term, Term, frozenset], float] = {}

    @staticmethod
    def _make(model: str, seed: int):
        if model == "logreg":
            from sklearn.linear_model import LogisticRegression
            from sklearn.pipeline import make_pipeline
            from sklearn.preprocessing import MaxAbsScaler
            return make_pipeline(MaxAbsScaler(), LogisticRegression(C=1.0, max_iter=5000))
        if model == "gboost":
            from sklearn.ensemble import HistGradientBoostingClassifier
            return HistGradientBoostingClassifier(max_iter=200, learning_rate=0.1, max_leaf_nodes=31,
                                                  early_stopping=False, random_state=seed)
        if model == "forest":
            from sklearn.ensemble import RandomForestClassifier
            return RandomForestClassifier(n_estimators=50, min_samples_leaf=2, random_state=seed, n_jobs=1)
        raise ValueError(model)

    def _dense(self, X):
        """Tree models predict much faster on dense float32 input."""
        if self.model_name in ("gboost", "forest"):
            return X.toarray().astype(np.float32)
        return X

    def _matrix(self, steps):
        return self._dense(self.feat.transform(steps))

    def fit(self, examples: Sequence[LabeledExample]) -> "StatisticalVerifier":
        X = self._matrix([(e.before, e.after, e.facts) for e in examples])
        y = np.array([e.label for e in examples], dtype=int)
        self.clf.fit(X, y)
        self.train_size = len(y)
        self.train_pos = int(y.sum())
        self._cache.clear()
        self._ecache.clear()
        return self

    def score_batch(self, steps: Sequence[Tuple[Term, Term, frozenset]]) -> List[float]:
        todo = [s for s in dict.fromkeys(steps) if s not in self._cache]
        if todo:
            p = self.clf.predict_proba(self._matrix(todo))[:, 1]
            for s, v in zip(todo, p):
                self._cache[s] = float(v)
        return [self._cache[s] for s in steps]

    def edge_scores(self, u: Term, vs: Sequence[Term], facts=frozenset()) -> List[float]:
        """Score of the undirected edge ``{u, v}`` for each ``v``: the max of
        the scores of ``u -> v`` and ``v -> u`` (cached, symmetric)."""
        facts = frozenset(facts)
        todo = [v for v in dict.fromkeys(vs) if (u, v, facts) not in self._ecache]
        if todo:
            X = self._dense(self.feat.transform_both([(u, v, facts) for v in todo]))
            p = self.clf.predict_proba(X)[:, 1]
            for k, v in enumerate(todo):
                e = float(max(p[2 * k], p[2 * k + 1]))
                self._ecache[(u, v, facts)] = e
                self._ecache[(v, u, facts)] = e
        return [self._ecache[(u, v, facts)] for v in vs]

    def score(self, before: Term, after: Term, facts=frozenset()) -> float:
        return self.score_batch([(before, after, frozenset(facts))])[0]

    def builtin(self, before: Term, after: Term) -> bool:
        """Reflexivity and trusted numeral arithmetic (shared with the rule-based verifiers)."""
        return before == after or alg.arith_step_ok(before, after)

    def accepts(self, before: Term, after: Term, facts=frozenset()) -> bool:
        if self.builtin(before, after):
            return True
        return self.score(before, after, facts) >= self.threshold

    def with_threshold(self, threshold: float) -> "StatisticalVerifier":
        """A view sharing the trained model and score cache, with another threshold."""
        v = object.__new__(StatisticalVerifier)
        v.__dict__.update(self.__dict__)
        v.threshold = threshold
        return v
