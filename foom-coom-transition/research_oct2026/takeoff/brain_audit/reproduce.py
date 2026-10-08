#!/usr/bin/env python3
"""Audit Forethought's brain-undertraining arithmetic; standard library only.

Sources and interpretation are in REPORT.md. This is a conditional calculation,
not a fitted model of human learning or universal algorithmic efficiency.
"""
from pathlib import Path
import csv
import hashlib
import json
import math

ROOT = Path(__file__).resolve().parent
FITS = {
    "Besiroglu_2024_notebook": dict(A=482.01, B=2085.43, alpha=0.3478, beta=0.3658, E=1.8172),
    "Hoffmann_2022_rounded": dict(A=406.4, B=410.7, alpha=0.34, beta=0.28, E=1.69),
    "Hoffmann_2022_precise": dict(A=406.4, B=410.7, alpha=0.3392, beta=0.2849, E=1.6934),
}


def loss(P, D, fit):
    return fit["E"] + fit["A"] / P ** fit["alpha"] + fit["B"] / D ** fit["beta"]


def matched_loss(P, D, fit):
    """Minimize 6*P*D with loss fixed; exact first-order solution."""
    A, B, a, b = (fit[k] for k in ("A", "B", "alpha", "beta"))
    ell = A / P ** a + B / D ** b
    # At the optimum: a*(A/P**a) = b*(B/D**b).
    Pstar = (A * (a + b) / (b * ell)) ** (1 / a)
    Dstar = (B * (a + b) / (a * ell)) ** (1 / b)
    original_compute = 6 * P * D
    new_compute = 6 * Pstar * Dstar
    assert math.isclose(loss(Pstar, Dstar, fit), loss(P, D, fit), rel_tol=1e-12)
    assert math.isclose(a * A / Pstar ** a, b * B / Dstar ** b, rel_tol=1e-12)
    return dict(P=P, D=D, C=original_compute, P_opt=Pstar, D_opt=Dstar, C_opt=new_compute,
                log10_training_gain=math.log10(original_compute/new_compute),
                parameter_reduction=P/Pstar, data_multiplier=Dstar/D)


def fixed_compute(C, fit):
    A, B, a, b = (fit[k] for k in ("A", "B", "alpha", "beta"))
    G = (a*A/(b*B)) ** (1/(a+b))
    P = G*(C/6)**(b/(a+b))
    return dict(P_opt=P, D_opt=C/(6*P), C=C)


def grid_replica(P, D, fit):
    """The original notebook's 300-point logspace search, without numpy."""
    A, B, a, b = (fit[k] for k in ("A", "B", "alpha", "beta"))
    ell = A/P**a+B/D**b
    rows=[]
    for i in range(300):
        p=10**(5+13*i/299)
        remainder=ell-A/p**a
        if remainder>0:
            d=(B/remainder)**(1/b)
            rows.append((6*p*d,p,d))
    c,p,d=min(rows)
    return dict(P_opt=p,D_opt=d,C_opt=c,log10_training_gain=math.log10(6*P*D/c))


def stopping_for_raw_tail(logH, q=None):
    """Illustrative tails with same initial k and integrated log-headroom.

    q=None: k=k0*exp(-x/tau), tau=logH/k0.
    q>1: k=k0*(1+x/tau)**(-q), tau=(q-1)*logH/k0.
    Both define valid common-multiplier models by F(x)=integral a(x) dx.
    """
    k0, budget = 1e-29, 1e120
    tau=logH/k0 if q is None else (q-1)*logH/k0
    def logk(x):
        return math.log(k0)-x/tau if q is None else math.log(k0)-q*math.log1p(x/tau)
    lo,hi=-50.0,120.0
    for _ in range(300):
        mid=(lo+hi)/2
        x=10**mid
        log_remaining=math.log(budget)+math.log1p(-x/budget) if x<budget else -math.inf
        if logk(x)+log_remaining>0:
            lo=mid
        else:
            hi=mid
    lx=(lo+hi)/2
    x=10**lx
    return dict(ceiling_log10=logH/math.log(10),q=q,tau=tau,
                log10_optimal_x=lx,research_fraction=x/budget,
                log10_k_at_stop=logk(x)/math.log(10))


def main():
    P, C=1e14,1e24
    D=C/(6*P)
    results={"fits":FITS,"same_loss":{n:matched_loss(P,D,f) for n,f in FITS.items()},
             "notebook_grid_replica":grid_replica(P,D,FITS["Besiroglu_2024_notebook"]),
             "fixed_compute":fixed_compute(C,FITS["Besiroglu_2024_notebook"])}
    assert abs(results["same_loss"]["Besiroglu_2024_notebook"]["log10_training_gain"]-
               results["notebook_grid_replica"]["log10_training_gain"])<0.001
    fit=FITS["Besiroglu_2024_notebook"]
    rows=[]
    for p in [1e13,1e14,1e15]:
        for d in [1e7,1e9,1e11,1e13,1e15]:
            rows.append(matched_loss(p,d,fit))
    with (ROOT/"undertraining_sensitivity.csv").open("w",newline="") as out:
        w=csv.DictWriter(out,fieldnames=list(rows[0]));w.writeheader();w.writerows(rows)
    results["brain_lifetime_30_years_FLOP_equivalents"]={str(b):b*30*365.25*24*3600 for b in [1e13,1e15,1e17]}
    results["illustrative_raw_tails"]=[stopping_for_raw_tail(12*math.log(10),q) for q in [None,2,1.1,1.01]]
    results["landauer_300K"]={"joules_per_bit_erasure":1.380649e-23*300*math.log(2),
                             "erasures_per_joule":1/(1.380649e-23*300*math.log(2))}
    notebook=ROOT/"sources"/"forethought_undertraining.ipynb"
    if notebook.exists():
        results["notebook_sha256"]=hashlib.sha256(notebook.read_bytes()).hexdigest()
    (ROOT/"results.json").write_text(json.dumps(results,indent=2)+"\n")
    for name,row in results["same_loss"].items():
        print(f"{name}: gain={row['log10_training_gain']:.6f} OOM; P*={row['P_opt']:.6g}; D*={row['D_opt']:.6g}")
    for row in results["illustrative_raw_tails"]:
        print(f"raw tail q={row['q']}: log10 x*={row['log10_optimal_x']:.6f}")


if __name__=="__main__":
    main()
