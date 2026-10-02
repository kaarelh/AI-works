import Paulsen.SmoothGaussianSample
import Paulsen.SmoothMean

/-! The complete diagonal-error calculation after diagonal mean correction. -/

namespace Paulsen.Smooth
open Matrix MeasureTheory ProbabilityTheory
open scoped BigOperators
noncomputable section

theorem moderate_corrected_diagonal_bound {n d : ℕ} [NeZero n]
    (hd : 0<d) {U W V : Frame n d} (hU : IsParseval U)
    {ε ρ t ζ θ : ℝ} (hε : 0≤ε) (hεhalf : ε≤1/2)
    (hnear : IsNearlyEqualNorm ε U) (hρ : 0≤ρ) (ht : 0≤t) (htone : t^2≤1)
    {g : FrameVector n d}
    (hsample : ModerateGaussianSample U ρ t (ζ*((d:ℝ)/(n:ℝ))*t)
      (ζ*((d:ℝ)/(n:ℝ))) (frameProjection U) g)
    (r : Fin n → ℝ)
    (htaylor : ∀ i, rowNormSq W i=rowNormSq U i+
      2*t*(moderateNoiseFrame U ρ g*U.transpose) i i+
      t^2*horizontalQuadraticDiagonal U (moderateNoiseFrame U ρ g) i+r i)
    (hremainder : ∀ i, |r i|≤10^12*((d:ℝ)/(n:ℝ))*t^3)
    (hcorrect : ∀ i, |rowNormSq V i-rowNormSq W i-t^2*normalResidualDiagonal U ρ i|≤
      θ*((d:ℝ)/(n:ℝ))*t^2) :
    ∀ i, |rowNormSq V i-(d:ℝ)/(n:ℝ)|≤
      (ε+(4*ε+3*ζ+θ+10^12*t)*t^2)*((d:ℝ)/(n:ℝ)) := by
  have hn : (0:ℝ)<n := Nat.cast_pos.mpr (NeZero.pos n)
  have hd' : (1:ℝ)≤d := by exact_mod_cast hd
  have ha : (0:ℝ)<(d:ℝ)/(n:ℝ) := by positivity
  have hp (i : Fin n) : 0<rowNormSq U i := by
    have h := (hnear i).1
    nlinarith [mul_pos (by linarith : 0<1-ε) ha]
  intro i
  let qmean := ∫ h, horizontalQuadraticDiagonal U (moderateNoiseFrame U ρ h) i
    ∂stdGaussian (FrameVector n d)
  let b₀ := (1/(n:ℝ))*(projectionLaplacian (frameProjection U) *ᵥ
    (fun j => (rowNormSq U j)⁻¹)) i
  have hmean : qmean=(d:ℝ)/(n:ℝ)-rowNormSq U i-b₀-normalResidualDiagonal U ρ i :=
    integral_horizontalQuadraticDiagonal_normalizedTangentNoise (NeZero.pos n) hU hp hρ i
  have hbase : |b₀|≤4*ε*((d:ℝ)/(n:ℝ)) := by
    have hh := horizontalQuadraticDiagonal_base_mean_abs_le hU ha hε hεhalf hnear i
    rw [horizontalQuadraticDiagonal_base_sum_eq_laplacian hU hp] at hh
    calc
      _ ≤ 4*ε/(n:ℝ) := hh
      _ ≤ (4*ε*(d:ℝ))/(n:ℝ) := div_le_div_of_nonneg_right
        (le_mul_of_one_le_right (by positivity) hd') hn.le
      _ = _ := by ring
  have hfluct := hsample.scaled_diagonal_fluctuation ht i
  change |2*t*(moderateNoiseFrame U ρ g*U.transpose) i i+
    t^2*(horizontalQuadraticDiagonal U (moderateNoiseFrame U ρ g) i-qmean)|≤_ at hfluct
  have hid : rowNormSq V i-(d:ℝ)/(n:ℝ)=
      (1-t^2)*(rowNormSq U i-(d:ℝ)/(n:ℝ))-t^2*b₀+
      (2*t*(moderateNoiseFrame U ρ g*U.transpose) i i+
        t^2*(horizontalQuadraticDiagonal U (moderateNoiseFrame U ρ g) i-qmean))+
      r i+(rowNormSq V i-rowNormSq W i-t^2*normalResidualDiagonal U ρ i) := by
    rw [htaylor, hmean]
    ring
  have horiginal : |(1-t^2)*(rowNormSq U i-(d:ℝ)/(n:ℝ))|≤ε*((d:ℝ)/(n:ℝ)) := by
    rw [abs_mul, abs_of_nonneg (sub_nonneg.mpr htone)]
    calc
      _ ≤ (1-t^2)*(ε*((d:ℝ)/(n:ℝ))) :=
        mul_le_mul_of_nonneg_left (hnear.abs_error i) (sub_nonneg.mpr htone)
      _ ≤ _ := mul_le_of_le_one_left (by positivity) (by nlinarith [sq_nonneg t])
  have hbaset : |t^2*b₀|≤t^2*(4*ε*((d:ℝ)/(n:ℝ))) := by
    rw [abs_mul, abs_of_nonneg (sq_nonneg t)]
    exact mul_le_mul_of_nonneg_left hbase (sq_nonneg t)
  rw [hid]
  calc
    _ ≤ |(1-t^2)*(rowNormSq U i-(d:ℝ)/(n:ℝ))-t^2*b₀+
      (2*t*(moderateNoiseFrame U ρ g*U.transpose) i i+
        t^2*(horizontalQuadraticDiagonal U (moderateNoiseFrame U ρ g) i-qmean))+r i|+
      |rowNormSq V i-rowNormSq W i-t^2*normalResidualDiagonal U ρ i| := abs_add_le _ _
    _ ≤ (|(1-t^2)*(rowNormSq U i-(d:ℝ)/(n:ℝ))-t^2*b₀+
      (2*t*(moderateNoiseFrame U ρ g*U.transpose) i i+
        t^2*(horizontalQuadraticDiagonal U (moderateNoiseFrame U ρ g) i-qmean))|+|r i|)+
      |rowNormSq V i-rowNormSq W i-t^2*normalResidualDiagonal U ρ i| := by
        gcongr
        exact abs_add_le _ _
    _ ≤ (|(1-t^2)*(rowNormSq U i-(d:ℝ)/(n:ℝ))-t^2*b₀|+
      |2*t*(moderateNoiseFrame U ρ g*U.transpose) i i+
        t^2*(horizontalQuadraticDiagonal U (moderateNoiseFrame U ρ g) i-qmean)|+|r i|)+
      |rowNormSq V i-rowNormSq W i-t^2*normalResidualDiagonal U ρ i| := by
        gcongr
        exact abs_add_le _ _
    _ ≤ (|(1-t^2)*(rowNormSq U i-(d:ℝ)/(n:ℝ))|+|t^2*b₀|+
      |2*t*(moderateNoiseFrame U ρ g*U.transpose) i i+
        t^2*(horizontalQuadraticDiagonal U (moderateNoiseFrame U ρ g) i-qmean)|+|r i|)+
      |rowNormSq V i-rowNormSq W i-t^2*normalResidualDiagonal U ρ i| := by
        gcongr
        rw [sub_eq_add_neg]
        exact (abs_add_le _ _).trans_eq (by rw [abs_neg])
    _ ≤ ε*((d:ℝ)/(n:ℝ))+t^2*(4*ε*((d:ℝ)/(n:ℝ)))+
      3*ζ*((d:ℝ)/(n:ℝ))*t^2+10^12*((d:ℝ)/(n:ℝ))*t^3+
      θ*((d:ℝ)/(n:ℝ))*t^2 :=
        add_le_add (add_le_add (add_le_add (add_le_add horiginal hbaset) hfluct) (hremainder i))
          (hcorrect i)
    _ = _ := by ring

theorem moderate_corrected_nearlyEqualNorm {n d : ℕ} {V : Frame n d}
    {ε t ζ θ : ℝ}
    (hbound : ∀ i, |rowNormSq V i-(d:ℝ)/(n:ℝ)|≤
      (ε+(4*ε+3*ζ+θ+10^12*t)*t^2)*((d:ℝ)/(n:ℝ))) :
    IsNearlyEqualNorm (ε+(4*ε+3*ζ+θ+10^12*t)*t^2) V := by
  intro i
  have hh := abs_le.mp (hbound i)
  constructor <;> nlinarith only [hh.1,hh.2]

end
end Paulsen.Smooth
