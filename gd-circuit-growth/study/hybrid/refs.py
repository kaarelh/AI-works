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


class Lin:
    """Toy-suite reference (fairness/discreteness audits): L2 logistic regression on the raw inputs (the standard encoding),
    regularization chosen by 5-fold cross-validation (sklearn LogisticRegressionCV, 10 values).  FLOPs: ~ folds x Cs x
    iterations x 4 n d (gradient + loss), with 100 iterations as the bound."""
    name = "lin"

    def fit(self, X, y, types, C, rng, budget=None):
        from sklearn.linear_model import LogisticRegressionCV
        Z = common.SH.encode_standard(X, types)
        cv = 5 if np.min(np.bincount(y)) >= 5 else 2
        m = LogisticRegressionCV(Cs=10, cv=cv, max_iter=1000).fit(Z, y)
        n, d = Z.shape
        return dict(predict=lambda T: m.predict(common.SH.encode_standard(T, types, ref=X)),
                    flops=float((cv + 1) * 10 * 100 * 4 * n * d))
