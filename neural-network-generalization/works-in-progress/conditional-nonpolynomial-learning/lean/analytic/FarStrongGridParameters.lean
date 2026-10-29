import NormalizedPrefixGrid

noncomputable section
set_option maxHeartbeats 1500000
namespace ConditionalNonpolynomial.Analytic
open ConditionalNonpolynomial.AnalyticLookup

def farStrongGridPrecision (J:ℕ) (L:ℝ) : ℝ := 1/(64*((J:ℝ)+1)*(L+1))
def farStrongGridMesh (W:ℝ) (J:ℕ) (L:ℝ) : ℕ :=
  ⌈2*(W+1)/farStrongGridPrecision J L⌉₊+1

theorem farStrongGridPrecision_positive (J:ℕ) {L:ℝ} (hL:0<L) :
    0<farStrongGridPrecision J L := by unfold farStrongGridPrecision;positivity

theorem farStrongGridPrecision_le_one (J:ℕ) {L:ℝ} (hL:0<L) :
    farStrongGridPrecision J L≤1 := by
  unfold farStrongGridPrecision
  apply (div_le_one (by positivity)).mpr
  have hJ:=Nat.cast_nonneg (α:=ℝ) J
  nlinarith

theorem farStrongGridMesh_bounds {W L:ℝ} (J:ℕ) (hW:2≤W) (hL:0<L)
    (hi:(farStrongGridPrecision J L)⁻¹≤W) :
    0<farStrongGridMesh W J L ∧
    2*(W+1)/farStrongGridPrecision J L≤(farStrongGridMesh W J L:ℝ) ∧
    (farStrongGridMesh W J L:ℝ)≤W^4 := by
  have hδ:=farStrongGridPrecision_positive J hL
  have hx:0≤2*(W+1)/farStrongGridPrecision J L := by positivity
  have hceil:=Nat.ceil_lt_add_one hx
  have hle:=Nat.le_ceil (2*(W+1)/farStrongGridPrecision J L)
  have hxup:2*(W+1)/farStrongGridPrecision J L≤2*(W+1)*W := by
    rw [div_eq_mul_inv]
    exact mul_le_mul_of_nonneg_left hi (by linarith)
  have hpoly:2*(W+1)*W+2≤W^4 := by
    have hs:4≤W^2 := by nlinarith
    have hm:=mul_le_mul_of_nonneg_right hs (sq_nonneg W)
    nlinarith
  refine ⟨by unfold farStrongGridMesh;omega,?_,?_⟩
  · unfold farStrongGridMesh
    push_cast
    linarith
  · unfold farStrongGridMesh
    push_cast
    linarith

theorem farStrongGrid_total_error {W L:ℝ} (J d0:ℕ) (hW:2≤W) (hL:0<L)
    (hd:(d0:ℝ)≤W) (hi:(farStrongGridPrecision J L)⁻¹≤W) :
    (J:ℝ)*farStrongGridPrecision J L+((d0:ℝ)+1)/(2*(farStrongGridMesh W J L:ℝ))≤1/(32*L) := by
  obtain ⟨hQ,hQlo,hQup⟩:=farStrongGridMesh_bounds J hW hL hi
  have hδ:=farStrongGridPrecision_positive J hL
  have hQreal:0<(farStrongGridMesh W J L:ℝ) := by exact_mod_cast hQ
  have hround:((d0:ℝ)+1)/(2*(farStrongGridMesh W J L:ℝ))≤farStrongGridPrecision J L/4 := by
    apply (div_le_iff₀ (by positivity)).mpr
    have hh:2*(W+1)≤(farStrongGridMesh W J L:ℝ)*farStrongGridPrecision J L :=
      (div_le_iff₀ hδ).mp hQlo
    nlinarith
  have hprod:((J:ℝ)+1)*farStrongGridPrecision J L≤1/(32*L) := by
    unfold farStrongGridPrecision
    have hJ:0<(J:ℝ)+1 := by positivity
    field_simp
    nlinarith [Nat.cast_nonneg (α:=ℝ) J]
  nlinarith

def farStrongClassifierPrecision (W:ℝ) : ℝ := W^(-16:ℤ)

theorem farStrongClassifierPrecision_bounds {W L:ℝ} {M:ℕ} (hW:2≤W)
    (hL:0<L) (hLW:L≤W) (hM:(M:ℝ)≤W) :
    0<farStrongClassifierPrecision W ∧ farStrongClassifierPrecision W≤1 ∧
    (farStrongClassifierPrecision W)⁻¹≤W^16 ∧
    ((M:ℝ)+1)*farStrongClassifierPrecision W≤(1/(32*L))^2 := by
  have hWpos:0<W := by linarith
  have he:farStrongClassifierPrecision W=(W^16)⁻¹ := by norm_num only [farStrongClassifierPrecision,zpow_neg,zpow_natCast]; rfl
  have hWpow:1≤W^16 := one_le_pow₀ (by linarith)
  have h2:(M:ℝ)+1≤W^2 := resource_add_one hW (a:=1) (by simpa using hM)
  have h10:(1024:ℝ)≤W^10 := by
    have hh:=pow_le_pow_left₀ (by norm_num : (0:ℝ)≤2) hW 10
    norm_num at hh
    exact hh
  have hL2:L^2≤W^2 := pow_le_pow_left₀ hL.le hLW 2
  have hb:=resource_mul hW (resource_mul hW h2 h10 (by norm_num)) hL2 (sq_nonneg _)
  have hb':((M:ℝ)+1)*1024*L^2≤W^16 := hb.trans (resource_pow_mono hW (show 2+10+2≤16 by omega))
  rw [he]
  refine ⟨by positivity,(inv_le_one₀ (by positivity)).mpr hWpow,by simp,?_⟩
  rw [div_pow]
  apply (le_div_iff₀ (by positivity : 0<(32*L)^2)).mpr
  change ((M:ℝ)+1)*(W^16)⁻¹*(32*L)^2≤1^2
  apply (mul_le_mul_iff_right₀ (show 0<W^16 by positivity)).mp
  convert hb' using 1 <;> first | rfl | (field_simp; ring) | ring

#print axioms farStrongGridMesh_bounds
#print axioms farStrongGrid_total_error
#print axioms farStrongClassifierPrecision_bounds
end ConditionalNonpolynomial.Analytic
