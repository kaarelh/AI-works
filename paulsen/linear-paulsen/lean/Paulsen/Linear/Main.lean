import Paulsen.Linear.ManyRow
import Paulsen.Linear.ModerateDrift
import Paulsen.SharpProjection

/-!
# The linear Paulsen bound

The final theorems: the frame form (`Paulsen.SharpPaulsenBound`, stated in
`Paulsen.Definitions`) and the projection form (`Paulsen.SharpProjectionBound`).
They are assembled from the many-row seed (`manyRowBound`), the drifted
moderate-row seed (`moderateParsevalBound`), the Hamilton–Moitra bound for
bounded rank, and complementation/normalisation, with no block partition.
-/

namespace Paulsen.Linear

open Paulsen

/-- **The linear Paulsen bound.** -/
theorem sharpPaulsenBound : SharpPaulsenBound :=
  sharpPaulsenBound_of_seeds (by norm_num [moderateA]) manyRowB_pos manyRowC_pos
    moderateEps_pos moderateCost_pos.le manyRowCost_nonneg
    manyRowBound moderateParsevalBound

/-- **Projection form.** -/
theorem sharpProjectionBound : SharpProjectionBound :=
  sharpProjectionBound_of_sharpPaulsenBound sharpPaulsenBound

end Paulsen.Linear
