"""Check 4: inference-rule specialisation (illustrative numbers, not data).
Situation-typed imitation: in situation type tau (frequency pi), the human applies schema
sigma_tau with prob 1-eta, else picks uniformly among M candidate steps.  A hypothesis either
models type tau with sigma_tau (cost ell bits) or predicts uniformly (cost 0).
Per-step gain g = log2 M - crossentropy; rate rho = pi*g/ell.  Then:
  * simplicity only (c-threshold),
  * + coherence (designated contexts) with witness sets,
  * + meaning postulates (numeric facts as designated premises),
  * + world feedback (random numerical evaluation; frequency data),
and the cross-validation pathology, guard erosion and the coherence-repair trade-off."""
from math import log2
import itertools, random

M, eta = 64, 0.05
def xent_matched():          # cross-entropy of teacher channel under the matched model
    p_hit = 1 - eta + eta / M
    return -(p_hit * log2(p_hit) + (M - 1) * (eta / M) * log2(eta / M))
g = log2(M) - xent_matched()
print(f"per-step gain of knowing a type's schema: g = {g:.3f} bits (M={M}, eta={eta})")

# name: (pi, ell, valid, kill_by)   kill_by subset of {'coh','post','world'}; witness = rules needed
C = {
 "MP":            (0.20,  20, True,  set()),
 "andE":          (0.15,  18, True,  set()),
 "subst(=)":      (0.15,  20, True,  set()),
 "andI":          (0.10,  18, True,  set()),
 "impI":          (0.08,  25, True,  set()),
 "orI":           (0.05,  18, True,  set()),
 "cancel x/x":    (0.05,  22, True,  set()),
 "topI":          (0.01,   8, True,  set()),
 "orE (cases)":   (0.01,  40, True,  set()),
 "negI (reductio)": (0.01, 35, True, set()),
 "botE (ex falso)": (0.002, 15, True, set()),
 "induction":     (0.001, 45, True,  set()),
 # systematic errors
 "AC (affirm. consequent)": (0.02, 20, False, {"coh"}),
 "freshman's dream":        (0.01, 22, False, {"post", "world"}),
 "gambler's fallacy":       (0.005, 30, False, {"world"}),
 "quantifier swap":         (0.003, 30, False, {"post"}),   # dies once '0 != 1' is designated
 "conditional perfection":  (0.01, 25, False, set()),       # coherent alt. meaning in closed worlds
 "idiosyncratic false lemma": (0.0005, 300, False, set()),
}
witness = {"AC (affirm. consequent)": {"impI"}}   # Post witness p:=bot, q:=(A->A): premises A->A and bot->(A->A) by impI (T2 Cor 6.2)
rate = {k: v[0] * g / v[1] for k, v in C.items()}
print("\nrates (bits/sample per bit), sorted:")
for k in sorted(rate, key=rate.get, reverse=True):
    print(f"  {'V' if C[k][2] else 'E'}  {k:28s} rho = {rate[k]:.2e}")

def select(c, filters):
    S = {k for k in C if rate[k] > c}
    if "coh" in filters:
        S = {k for k in S if not ("coh" in C[k][3] and witness.get(k, set()) <= S)}
    if "post" in filters:
        S = {k for k in S if "post" not in C[k][3]}
    if "world" in filters:
        S = {k for k in S if "world" not in C[k][3]}
    return S

print("\nwhich systematic errors survive, as a function of c and of the filters:")
cs = [3e-2, 1e-2, 3e-3, 1e-3, 3e-4, 1e-4, 1e-5]
for filt in [(), ("coh",), ("coh", "post"), ("coh", "post", "world")]:
    print(f"  filters = {filt or ('simplicity only',)}")
    for c in cs:
        S = select(c, filt)
        lostV = sorted(k for k in C if C[k][2] and k not in S)
        keptE = sorted(k for k in S if not C[k][2])
        print(f"    c={c:.0e}: valid lost={len(lostV)} {lostV if len(lostV) < 5 else ''}| errors kept={keptE}")

# windows: c must exceed the rate of every error that only simplicity can remove,
# and stay below the rate of every valid rule.  'residue' = errors no filter in the list removes.
residue_cls = {"conditional perfection"}          # cheap, coherent, empirically adequate
hi = min(rate[k] for k in C if C[k][2])
for filt in [(), ("coh",), ("coh", "post"), ("coh", "post", "world")]:
    left = [k for k in C if not C[k][2] and k in select(0.0, filt)]   # errors left for simplicity
    lo_all = max(rate[k] for k in left)
    lo_nores = max([rate[k] for k in left if k not in residue_cls], default=0.0)
    print(f"  filters {filt or ('none',)}: errors left for simplicity = {left}")
    print(f"     window to remove all of them: ({lo_all:.2e}, {hi:.2e}) {'nonempty' if lo_all < hi else 'EMPTY'};"
          f"  excluding the residue class: ({lo_nores:.2e}, {hi:.2e}) {'nonempty' if lo_nores < hi else 'EMPTY'}")

# --- guard erosion -------------------------------------------------------------
pi0, ell_guard = 0.0005, 12
gain_guard = log2(M / eta) - log2(M - 1)
rho_guard = pi0 * gain_guard / ell_guard
print(f"\nguard erosion: guard 'x != 0' on cancellation: gain/context {gain_guard:.2f} bits, "
      f"rate {rho_guard:.2e}; dropped (=> unsound x/x->1) for c > {rho_guard:.2e}, "
      f"while e.g. botE kept until c = {rate['botE (ex falso)']:.2e}")

# --- coherence-repair trade-off ------------------------------------------------
# Constrained optimum: maximise sum (r - c k) over S with S coherent.  If a witness rule of a
# fallacy is less valuable than the fallacy, the optimum drops the WITNESS, not the fallacy.
def best_constrained(c, comps, wit):
    names = list(comps)
    best, bestS = -1e9, None
    for mask in itertools.product([0, 1], repeat=len(names)):
        S = {nm for nm, b in zip(names, mask) if b}
        if any(f in S and w <= S for f, w in wit.items()): continue
        val = sum(comps[nm][0] * g - c * comps[nm][1] for nm in S)
        if val > best: best, bestS = val, S
    return bestS
comps = {"MP": (0.20, 20), "topI": (0.01, 8), "impI": (0.004, 25), "AC": (0.02, 20)}
wit = {"AC": {"impI"}}
for c in [2e-3, 5e-4, 2e-4]:
    unc = sorted(k for k in comps if comps[k][0]*g > c*comps[k][1])
    print(f"  c={c:.0e} (impI rare, rate {comps['impI'][0]*g/25:.1e}): unconstrained {unc} -> coherent optimum {sorted(best_constrained(c, comps, wit))}")
comps["impI"] = (0.08, 25)
print(f"  c=5e-04 with impI frequent: coherent optimum {sorted(best_constrained(5e-4, comps, wit))}")

# --- cross-validation pathology --------------------------------------------------
from math import comb
def H2(q): return 0.0 if q in (0, 1) else -(q*log2(q)+(1-q)*log2(1-q))
p = 2**-10; hyps = [(0, 1.0), (110, H2(p)), (10100, 0.0)]
print("\ncross-validation on held-out imitation data (population log-loss of the c-selected model):")
for c in [1e-1, 1e-3, 1e-5, 1e-7]:
    k, r = min(hyps, key=lambda h: c*h[0]+h[1])
    print(f"  c={c:.0e}: selected K={k:5d}, held-out loss={r:.5f}")
print("  => held-out loss is minimised by the smallest c, i.e. by the error-memorising model")
