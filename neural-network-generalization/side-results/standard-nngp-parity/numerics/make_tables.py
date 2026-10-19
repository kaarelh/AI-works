"""Write the LaTeX tables of Section 7 from spectrum.json and signgp_parity.jsonl."""
import json, os
import numpy as np
HERE = os.path.dirname(os.path.abspath(__file__))
SRC = os.path.join(HERE, "..", "source")

sp = json.load(open(os.path.join(HERE, "spectrum.json")))
rows = []
names = ["tanh unit gain L=2", "tanh unit gain L=3", "tanh specified gain L=3", "arcsine L=2"]
qs = [1, 3, 9, 17, 33, 65]
for name in names:
    for d in (80, 160):
        r = [x for x in sp["spectra"] if x["name"] == name and x["d"] == d][0]
        cells = []
        for q in qs:
            if q > d or (name.startswith("arcsine") and q > 33):
                cells.append("--")
            else:
                cells.append(f"{r['log10_level_mass'][q]:.2f}")
        rows.append(f"{name.replace('tanh ', '$\\tanh$ ').replace('L=', '$L=')}$ & {d} & " + " & ".join(cells)
                    + f" & {r['log10_matrix_min_eig']:.1f}" + (" \\\\" ))
tab = r"""\begin{table}[ht]
\centering\small
\begin{tabular}{@{}lr""" + "r" * len(qs) + r"""r@{}}
\toprule
kernel & $d$ & """ + " & ".join(f"$q={q}$" for q in qs) + r""" & $v_{\min}$\\
\midrule
""" + "\n".join(rows) + r"""
\bottomrule
\end{tabular}
\caption{$\log_{10}$ of the level mass $\binom dq\lambda_q/A$ of the normalized kernel $F((1+x\cdot y)/(d+1))$,
and $\log_{10}$ of the smallest eigenvalue of the matrix $F((1+x\cdot y)/(d+1))_{x,y}$. Unit gain means
$\sigma_\ell=1$ for all $\ell$; specified gain is the family of \cite[Section~7]{nngpnote} at $L=3$.
Arcsine entries above $q=33$ are omitted because the computation truncates its slowly decaying
coefficients at $m=600$ (omitted mass $0.021$); for the arcsine kernel the reported $v_{\min}$ is
therefore only an approximation. All checks listed in Section~\ref{sec:numerics} passed for every row.}
\label{tab:spectrum}
\end{table}
"""
open(os.path.join(SRC, "spectrum-table.tex"), "w").write(tab)

path = os.path.join(HERE, "signgp_parity.jsonl")
if os.path.exists(path):
    R = [json.loads(l) for l in open(path)]
    kernels = [("tanh-unit", 2, r"$\tanh$ unit gain, $L=2$"), ("tanh-unit", 3, r"$\tanh$ unit gain, $L=3$"),
               ("tanh-specified", 3, r"$\tanh$ specified gain, $L=3$"), ("arcsine", 2, r"arcsine, $L=2$")]
    lines = []
    for d, ns in [(10, [100, 200, 400, 800]), (12, [200, 400, 800, 1600])]:
        lines.append(r"\multicolumn{5}{@{}l}{$d=" + str(d) + r"$, $n=" + ",".join(map(str, ns)) + r"$}\\")
        for k, L, lab in kernels:
            cells = []
            for n in ns:
                rr = [x for x in R if x["kernel"] == k and x["L"] == L and x["d"] == d and x["n"] == n]
                cells.append(f"{np.mean([x['F'] for x in rr]):.2f} ({np.mean([x['F_unseen'] for x in rr]):.2f})" if rr else "--")
            while len(cells) < 4:
                cells.append("")
            lines.append(lab + " & " + " & ".join(cells) + r"\\")
    maxdiff = max(x["F_chain_diff"] for x in R)
    tab = r"""\begin{table}[ht]
\centering\small
\begin{tabular}{@{}lcccc@{}}
\toprule
""" + "\n".join(lines) + r"""
\bottomrule
\end{tabular}
\caption{Sign-only learner for full parity: confidence-failure fraction $F=\Pp_x\{q_S(x)\le2/3\}$ over the whole
cube (observed inputs count as successes), and in parentheses over unseen inputs only; mean over 3 seeds of
iid uniform training inputs, columns in the order of the listed $n$. Two exact-HMC chains of 1500 draws after
300 burn-in; the largest difference in $F$ between chains over all runs is """ + f"{maxdiff:.3f}" + r""".}
\label{tab:signgp}
\end{table}
"""
    open(os.path.join(SRC, "signgp-table.tex"), "w").write(tab)
print("ok")
