"""Thread W: rerun thread U's P(works) model with thread W's estimates of w.

Imports research/threadU_verify.py unchanged and overrides only the w range of each domain
in memory. Run from the folder that holds this file: python3 -B threadW_rerun.py
"""
import contextlib
import io
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import threadU_verify as U  # noqa: E402

W_RANGES = {  # uniform ranges for w, the share of failed runs that carry a confident claimed solution
    #            thread U      thread W     thread W, with final-answer asks
    "math":      ((0.3, 0.6),  (0.4, 0.8),  (0.2, 0.5)),
    "software":  ((0.4, 0.7),  (0.4, 0.8),  (0.2, 0.5)),
    "empirical": ((0.6, 0.9),  (0.75, 0.95), (0.55, 0.85)),
    "judgment":  ((0.7, 0.95), (0.83, 0.97), (0.65, 0.9)),
}
ROWS = {
    "math": ["V-human: one expert reads (unlocated verdict)", U.BEST["math"]],
    "software": ["fixed acceptance tests only (folder's test-suite row)", U.BEST["software"]],
    "empirical": ["V-human: one expert reads (unlocated)", U.BEST["empirical"]],
    "judgment": ["V-human: one expert reads (unlocated)", U.BEST["judgment"]],
}

with contextlib.redirect_stdout(io.StringIO()):
    res = U.part_b()

print("P(works) [P(output failure <= 5%), median F] in thread U's model, by the w range used")
print("%-10s %-58s %-26s %-26s %-26s" % ("domain", "protocol", "w: thread U", "w: thread W",
                                          "w: thread W + asks"))
for dom, names in ROWS.items():
    orig = U.DOMAINS[dom]["w"]
    for name in names:
        fm, ft, cost, fr, loc, iota, feas = res[(dom, name)]
        cells = []
        for wr in W_RANGES[dom]:
            U.DOMAINS[dom]["w"] = wr
            pw, po, pe, med, cp, ab = U.p_works(dom, fm, cost, fr, loc, iota, feas)
            cells.append("%2.0f%% [%2.0f%%, F %4.1f%%]" % (100 * pw, 100 * po, 100 * med))
        U.DOMAINS[dom]["w"] = orig
        print("%-10s %-58s %-26s %-26s %-26s" % (dom, name[:58], *cells))

print("\nCentral products F = p*w*rbar*f_V (p = 0.3, rbar = 1.3; f_V from thread U's best protocol)")
for dom, w_u, w_w, w_a, f in [("theory", 0.45, 0.6, 0.35, 0.15), ("software", 0.55, 0.6, 0.35, 0.07),
                              ("empirical", 0.75, 0.85, 0.7, 0.27), ("judgment", 0.825, 0.9, 0.78, 0.21)]:
    out = []
    for w in (w_u, w_w, w_a):
        out.append("w %.2f: p*w %.3f, F %.1f%%, f* %.2f" % (w, 0.3 * w, 100 * 0.3 * w * 1.3 * f,
                                                         0.05 / (0.3 * w * 1.3)))
        # f* is the largest f_V that meets F <= 5% at these central values
    print("  %-9s f_V %.2f | %s" % (dom, f, " | ".join(out)))
