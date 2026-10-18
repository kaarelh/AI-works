"""Referee checks for drafts/G4-honesty.md (report: drafts/G4-honesty-referee.md).

Run:  python3 G4_referee_checks.py > G4_referee_checks_output.txt
R1..R8 correspond to items in the referee report.  All parameter values are the
draft's illustrative ones unless stated.
"""
import math

import numpy as np
from scipy import stats

rng = np.random.default_rng(7)


def hr(t):
    print("=" * 78)
    print(t)


def bkl(p, q):
    s = 0.0
    for a, b in ((p, q), (1 - p, 1 - q)):
        if a > 0:
            s += a * math.log(a / b)
    return s


# ---------------------------------------------------------------------------
hr("R1. G4.10 item 4: the wall's leak when confessors game at relative rate rg.\n"
   "    Brute force from per-episode rewards (selection (D)).")
w, aC, dJ, lm, lc = 0.05, 0.95, 0.3, 0.05, 0.05


def brute(rg):
    # main channel: Gc games on rg*w episodes, Gd on w episodes, reward 1 per gamed episode
    Jm_c, Jm_d = rg * w, w
    # confession channel (accuracy reward): Gc games on rg*w episodes and confesses
    # (accepted w.p. aC); on the (1-rg) w episodes it complies and truthfully says so (1).
    # Gd games on w episodes and denies; denial rejected w.p. dJ.
    Jc_c = 1 - rg * w * (1 - aC)
    Jc_d = 1 - w * dJ
    return lm * (Jm_d - Jm_c) + lc * (Jc_d - Jc_c)   # drift of Gd against Gc


def draft(rg):
    return lm * w * (1 - rg) - lc * w * rg * (aC + dJ - 1)


def corrected(rg):
    return lm * w * (1 - rg) - lc * w * (dJ - rg * (1 - aC))


for rg in (1.0, 0.9, 0.8, 0.75, 0.7, 0.5):
    print(f"  rg={rg:.2f}: brute {brute(rg):+.6f}  draft formula {draft(rg):+.6f}  corrected {corrected(rg):+.6f}")
from scipy.optimize import brentq
print(f"  break-even rg: brute {brentq(brute, 0.01, 0.999):.4f}; draft {brentq(draft, 0.01, 0.999):.4f};"
      f" corrected closed form (lm + lc dJ... ) {brentq(corrected, 0.01, 0.999):.4f}")
print("  corrected closed form for equal lambdas: rg* = (1 - dJ)/(1 - (1-aC)) =",
      f"{(1 - dJ) / (1 - (1 - aC)):.4f}")

# ---------------------------------------------------------------------------
hr("R2. Per-output discard (a gate applied to every episode) is not bounded Goodhart.\n"
   "    If firing outputs are discarded and the rest feed training or the next\n"
   "    generation's data, the odds of a probe-quiet type against H move by up to\n"
   "    n w_Delta ln(1/(1-fpr_Delta)) per generation, which grows linearly in n.")
n, wD = 10 ** 5, 0.005
for fpr in (0.05, 0.3):
    per = math.log(1 / (1 - fpr))
    print(f"  fpr_Delta={fpr}: per disagreement episode {per:.4f} nats; per generation n w_D x = {n * wD * per:.1f} nats"
          f" (single final gate in the draft: {math.log(1 / stats.binom.cdf(10, 100, fpr)):.4f} nats)")

# ---------------------------------------------------------------------------
hr("R3. The gate's exponent is not the G4.3 KL.  ln Pr_S(pass) ~ -N KL(k/N || tpr).")
N, k = 100, 10
for t in (0.9, 0.2, 0.1):
    exact = math.log(stats.binom.cdf(k, N, t)) - math.log(stats.binom.cdf(k, N, 0.05))
    print(f"  tpr={t}: exact log odds change {exact:+.2f}; -N KL(k/N||tpr) = {-N * bkl(k / N, t) if t > k / N else 0:+.2f};"
          f" -N KL(tpr||fpr) (G4.3 scale) = {-N * bkl(t, 0.05):+.2f}")

# ---------------------------------------------------------------------------
hr("R4. Model-level correlation of probe firings.  Suppose 5% of S instances have a\n"
   "    probe blind spot (tpr 0.06 on all their questions) and 95% have tpr 0.94\n"
   "    (mean tpr 0.896).  The gate's effect on S collapses from ~-178 nats.")
PH = stats.binom.cdf(k, N, 0.05)
iid = stats.binom.cdf(k, N, 0.896)
mix = 0.05 * stats.binom.cdf(k, N, 0.06) + 0.95 * stats.binom.cdf(k, N, 0.94)
print(f"  i.i.d. at mean tpr: {math.log(iid / PH):+.1f} nats;  with 5% blind-spot instances: {math.log(mix / PH):+.2f} nats")

# ---------------------------------------------------------------------------
hr("R5. G4.3 when the designer cannot tell disagreement questions from agreement\n"
   "    questions (no ground truth on o != b at the frontier).  Share of Delta among\n"
   "    probed questions = 0.05; probe fpr on agreement questions = 0.01.")
sh, fpr_eq = 0.05, 0.01
for tpr, fprD in ((0.9, 0.05), (0.2, 0.05), (0.9, 0.3)):
    pS = sh * tpr + (1 - sh) * fpr_eq
    pH = sh * fprD + (1 - sh) * fpr_eq
    per_q = bkl(pS, pH)
    print(f"  tpr={tpr} fpr_D={fprD}: pooled KL per question {per_q:.4f}; per Delta-question equivalent"
          f" {per_q / sh:.3f} vs draft {bkl(tpr, fprD):.3f} (ratio {per_q / sh / bkl(tpr, fprD):.2f})")

# ---------------------------------------------------------------------------
hr("R6. G4.7 when the judge's unaided detection also verifies a true confession\n"
   "    (accept w.p. a' = aC + (1-aC) dJ).  Confess-minus-deny with c_m = 0.")
for aCx in (0.9, 0.95, 0.99):
    for d in (0.0, 0.05, 0.2):
        a2 = aCx + (1 - aCx) * d
        diff_draft = aCx + d - 1
        diff_corr = a2 - (1 - d)
        print(f"  aC={aCx} dJ={d}: draft {diff_draft:+.4f}  correlated {diff_corr:+.4f}")
print("  audit at rate a also verifies true confessions: need a >= (1-aC)/(2-aC):",
      ", ".join(f"aC={x}: {(1 - x) / (2 - x):.4f} (draft {1 - x:.3f})" for x in (0.9, 0.99)))

# ---------------------------------------------------------------------------
hr("R7. G4.9 with a mixed gamer population: only a share s_c of gaming events is\n"
   "    confessed.  Expected rewarded events N_cl/(aC s_c) + w_F eps_F T_pat.")
Ncl, aC9, wF, epsF, Tp, lp = 50, 0.9, 0.1, 0.05, 1000, 0.05
for sc in (1.0, 0.43, 0.1):
    ev = Ncl / (aC9 * sc) + wF * epsF * Tp
    # Monte Carlo
    first = rng.geometric(aC9 * sc, size=(20000, Ncl))
    during = rng.poisson(wF * epsF / Ncl * Tp, size=(20000, Ncl))
    mc = (first + during).sum(axis=1).mean()
    print(f"  s_c={sc:.2f}: formula {lp * ev:.2f} nats (MC {lp * mc:.2f}); no confessions {lp * n * wF * epsF:.1f}")
print("  With G4.7 at d_J=0 (frontier) and no confession audit, s_c is set by tie-breaking, not incentive.")

# ---------------------------------------------------------------------------
hr("R8. H7 reparameterised so the confession judge has the main channel's detection.\n"
   "    In H7 the main-channel judge catches nothing (J_main = w for gamers) but d_J = 0.3.\n"
   "    With the same weak judge on both channels, d_J ~ 0.  Drift Gd vs Gc per episode:")
for aCx, d in ((0.95, 0.3), (0.95, 0.0), (0.99, 0.0), (0.99, 0.02), (1.0, 0.0)):
    print(f"  aC={aCx} dJ={d}: {-lc * w * (aCx + d - 1):+.6f}  ({'confessors gain' if aCx + d - 1 > 0 else 'deniers gain or tie'})")
