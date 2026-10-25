# Composition test: predictions recorded before any network result was inspected (Sat Oct 24 05:16:51 2026)

Targets (d = 30, real-valued, square loss, every term has coefficient 1/2; s = x1+x2+x3+x4): see boolfuncs.make_poly_suite.
Metric: n*_4 = smallest training-set size (log-interpolated on the factor-2 grid) at which the seed-mean test-set
coefficient of x1x2x3x4 in the trained predictor reaches 0.4, i.e. 80% of its target value 0.5, at the end of training.

## Predictions

1. **Leap complexity** (Abbe, Boix-Adsera, Misiakiewicz 2023). compA, compB, compC, compD: leap 1. compE: leap 2. compF: leap 4.
   Its rates are asymptotic in d. At fixed d it does not order compA, compB and compC: once x1..x4 are found, the degree-4 term adds no new input.
2. **The noise-law predictor's move classification** (k = number of new inputs a move needs). After the linear stage, the
   x1x2x3x4 move is k = 0 in compA, compB and compC, so it should be cheap, about the active-pool size over rho^2, in all three.
   It is k = 2 after the pairs in compE, and k = 4 in compF (expensive, about c d (d/a)^2 / rho^2).
3. **The race model** (calibrated classification constants, run on the networks' exact training sets; race_predictions.json):

| target | race n*_4 |
|---|---|
| compA | 2119 |
| compB | 2013 |
| compC | 1946 |
| compD | never |
| compE | 1974 |
| compF | 2306 |
| compL | never |

   The race finds the degree-4 term with an order-4 search over all d inputs, whether or not x1..x4 are already active.
   So it predicts about the same n*_4 (about 2000) for compA, compB, compC, compE and compF. compA is slightly ahead: its coefficient is 0.27 at n = 1024, against 0.01 for compB.
4. **The user's prediction:** compA is easier than compB. The intermediate x1x2 and x3x4 are useful on their own and compose into x1x2x3x4.
5. **My prior** (Claude, before the run): compA is easier than compB, and compC lies between them.
   compF is much harder than all three only if the networks exploit the linear staircase; if they do not, the race's 'all about equal' holds.
   I put real weight on compB being easier than the user expects, because x1x2x3x4 is a symmetric function of s, the direction the linear stage learns.
