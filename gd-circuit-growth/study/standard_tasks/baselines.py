"""Reference learners for calibration (not part of the comparison proper):
  linear - multinomial logistic regression on the standard encoding (sklearn, L2, C = 1): the 'kernel background' alone
  hgb    - sklearn HistGradientBoostingClassifier with default settings (early stopping on 10% when n > 10000): a strong
           tabular reference
usage: python baselines.py <linear|hgb> <dataset> [...]   -> results/<linear|hgb>__<dataset>.json
"""
import sys, numpy as np
import harness as H


class Linear:
    name = "linear"

    def fit(self, X, y, types, C, rng):
        from sklearn.linear_model import LogisticRegression
        Z = H.encode_standard(X, types)
        m = LogisticRegression(C=1.0, max_iter=2000).fit(Z, y)
        return dict(predict=lambda T: m.predict(H.encode_standard(T, types, ref=X)), flops=float("nan"))


class HGB:
    name = "hgb"

    def fit(self, X, y, types, C, rng):
        from sklearn.ensemble import HistGradientBoostingClassifier
        cat = [t == "categorical" for t in types]
        m = HistGradientBoostingClassifier(categorical_features=cat if any(cat) else None, random_state=int(rng.integers(1 << 30)))
        m.fit(X, y)
        return dict(predict=m.predict, flops=float("nan"))


if __name__ == "__main__":
    L = {"linear": Linear, "hgb": HGB}[sys.argv[1]]()
    H.evaluate(L, sys.argv[2:], verbose=False)
    print("done", sys.argv[1])
