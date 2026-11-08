import NeuralGeneralization.OnlineLowerCosineQuantitative

noncomputable section
open scoped Topology
open Set MeasureTheory
namespace NeuralGeneralization.OnlineLowerTanh

def cutoffCosinePower (n:ℕ) (a p ρ y:ℝ) : ℝ :=
  if ρ≤p+y/(a*Real.sqrt n) then truncatedCosinePower n (y/Real.sqrt n) else 0

def cutoffCosineMajorant (y:ℝ) : ℝ := (y^4+16*y^2)*Real.exp (-y^2/8)

lemma cutoffCosinePower_nonneg (n:ℕ) (a p ρ y:ℝ) : 0≤cutoffCosinePower n a p ρ y := by
  unfold cutoffCosinePower
  split_ifs
  · exact truncatedCosinePower_nonneg n _
  · rfl

lemma cutoffCosinePower_bound (n:ℕ) (hn:0<n) (a p ρ y:ℝ) :
    cutoffCosinePower n a p ρ y≤Real.exp (-y^2/8) := by
  unfold cutoffCosinePower
  split_ifs
  · have h:=truncatedCosinePower_bound n (y/Real.sqrt n)
    have hn':0<(n:ℝ) := Nat.cast_pos.mpr hn
    have he:(n:ℝ)*(y/Real.sqrt n)^2=y^2 := by
      rw [div_pow,Real.sq_sqrt hn'.le]; field_simp
    convert h using 1
    congr 1
    nlinarith [he]
  · exact (Real.exp_pos _).le

lemma cutoffCosinePower_error (n:ℕ) (hn:0<n) (a p ρ y:ℝ)
    (ha:0<a) (hgap:1/4≤a*(p-ρ)) :
    |cutoffCosinePower n a p ρ y-Real.exp (-y^2/2)|≤cutoffCosineMajorant y/(n:ℝ) := by
  have hn':0<(n:ℝ) := Nat.cast_pos.mpr hn
  unfold cutoffCosinePower
  split_ifs with hcut
  · exact (scaled_cosine_error n hn y).trans (div_le_div_of_nonneg_right
      (mul_le_mul_of_nonneg_right (by nlinarith [sq_nonneg y]) (Real.exp_pos _).le) hn'.le)
  · have hs:0<Real.sqrt (n:ℝ) := Real.sqrt_pos.mpr hn'
    have hlt:y<(ρ-p)*(a*Real.sqrt n) :=
      (div_lt_iff₀ (mul_pos ha hs)).mp (by linarith)
    have hy:y< -Real.sqrt (n:ℝ)/4 := by
      have hh:=mul_le_mul_of_nonneg_right hgap hs.le
      nlinarith
    have hn16:(n:ℝ)≤16*y^2 := by
      have hs2:=Real.sq_sqrt hn'.le
      nlinarith [sq_nonneg (y+Real.sqrt (n:ℝ)/4)]
    rw [zero_sub,abs_neg,Real.abs_exp]
    apply (Real.exp_le_exp.mpr (show -y^2/2≤-y^2/8 by nlinarith [sq_nonneg y])).trans
    apply (le_div_iff₀ hn').mpr
    unfold cutoffCosineMajorant
    have hh:=mul_le_mul_of_nonneg_right (show (n:ℝ)≤y^4+16*y^2 by nlinarith [show 0≤y^4 by positivity]) (Real.exp_pos (-y^2/8)).le
    nlinarith

@[fun_prop] lemma measurable_cutoffCosinePower (n:ℕ) (a p ρ:ℝ) :
    Measurable (cutoffCosinePower n a p ρ) := by
  unfold cutoffCosinePower
  apply Measurable.ite
  · exact measurableSet_le measurable_const (by fun_prop)
  · fun_prop
  · fun_prop

end NeuralGeneralization.OnlineLowerTanh
