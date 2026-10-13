"""fc2 (final check of ../notes-final.md): margins gamma_L of kink k6's per-query class at every cap s1(B) uses.

s1(B) takes gamma_L = 2.652e-4 for every cap L >= 22, also at iid's cap L_eps = 66 (lambda = 1.5), while
k6_perquery.out prints the margin only up to cap 65. This script executes k6's class construction (its source up to
the line "x_all = np.arange(M)", i.e. before the simulations of part (D); stdout of that prefix is suppressed) and
evaluates k6's own function gamma_le(L) at caps up to 100. It also lists the shortest programs whose gap is below
2.652e-4. Deterministic (k6's construction is seeded).
Run: python3 -I fc2_k6_margins.py > fc2_k6_margins.out
"""
import contextlib
import io
from pathlib import Path

src_path = Path(__file__).resolve().parent.parent / "kink" / "checks" / "k6_perquery.py"
src = src_path.read_text()
cut = src.index("x_all = np.arange(M)")
g = {"__name__": "k6_prefix"}
with contextlib.redirect_stdout(io.StringIO()):
    exec(compile(src[:cut], "k6_prefix", "exec"), g)

print(f"k6 class: l* = {g['ellstar']}, {len(g['ENTRIES'])} (length, gap, count) entries, Kraft sum = {g['kraft']:.4f}")
for L in [20, 21, 22, 23, 26, 27, 30, 40, 42, 43, 60, 65, 66, 67, 70, 80, 100]:
    print(f"gamma_L({L}) = {g['gamma_le'](L):.4e}")
small = sorted((l, h) for l, h, c in g["ENTRIES"] if 1e-15 < h < 2.652e-4 - 1e-7)
print(f"programs with 0 < gap < 2.652e-4: {len(small)}")
