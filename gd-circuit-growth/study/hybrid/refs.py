"""Reference learners for Part 8 (not proposals): sklearn histogram gradient boosting, default settings ('hgb'), with an
analytic FLOP estimate (histograms: ~ n d per tree level per class, 100 iterations, depth <= 31 leaves ~ 5 levels)."""
import numpy as np
import common


class HGB:
    name = "hgb"

    def fit(self, X, y, types, C, rng, budget=None):
        from sklearn.ensemble import HistGradientBoostingClassifier
        cat = [t == "categorical" for t in types]
        m = HistGradientBoostingClassifier(categorical_features=cat if any(cat) else None,
                                           random_state=int(rng.integers(1 << 30))).fit(X, y)
        n, d = X.shape; trees = m.n_iter_ * (1 if C == 2 else C)
        return dict(predict=m.predict, flops=float(trees * 5 * 2 * n * d), info=dict(iters=int(m.n_iter_)))
