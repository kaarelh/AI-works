# Independent check for Prop pa:memo: if ONE beta prices both the axiom prior and the proof text (as Def pa:lsch
# states), is memorising at the first occurrence cheaper for every beta?  D(beta) = A + beta*W is affine in beta;
# memorising costs beta*|s| + c.  Uses the track's own derivation library (a scratch copy of research/tracks/pa/checks).
import sys, os, math
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, '..', 'mathC_pa_checks_copy'))
os.chdir(os.path.join(HERE, '..', 'mathC_pa_checks_copy'))
from nd import Proof, size
import thm
from arith import AX, SCH
CITE = lambda n: math.log2(len(Proof.RULES)) + math.log2(n)
L1, L2 = math.log2(23), 10.0
for T, (gi, nax) in {'T_Ind': (thm.ind_cite, 8), 'T_CVI': (thm.ind_via_cvi, 9), 'T_LNP': (thm.ind_via_lnp, 9)}.items():
    for name in thm.THM:
        pf = Proof(AX, SCH); thm.DERIV[name](pf, gi, thm.lemmas_inline(gi)); pf.check_closed(thm.THM[name])
        d1, d2 = pf.bits(L1, nax), pf.bits(L2, nax)
        W = (d2 - d1) / (L2 - L1); A = d1 - L1 * W
        s = size(thm.THM[name]); c = CITE(nax + 1)
        # memorise cheaper iff beta*s + c < A + beta*W  iff  beta*(s-W) < A - c
        always = (W >= s) and (A > c)
        dd = [pf.bits_decodable(L1, nax) / d1 - 1]
        print(f"{T:6s} {name:6s} |s|={s:3d} written W={W:7.1f} non-symbol A={A:7.1f} c={c:5.2f}  "
              f"beta*(at log2 23)={(d1-c)/s:6.1f}  memorise wins for every single beta: {always}  decodable +{100*dd[0]:.1f}%")
