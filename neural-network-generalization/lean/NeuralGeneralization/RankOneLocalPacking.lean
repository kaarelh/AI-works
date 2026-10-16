import NeuralGeneralization.RankOneQuasimetric
import NeuralGeneralization.GaussianMixedPacking

/-! Concrete local packing for the rank-one squared process. -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.SquaredSampling
open GaussianTranslatePacking

variable {m D : ℕ}

def weightedRows (a : Fin m → Fin D → ℝ) (z : Fin D → ℝ) : Fin m → Fin D → ℝ :=
  fun i j => linearEvaluation (a i) z * a i j

lemma rowForm_weightedRows (a : Fin m → Fin D → ℝ) (z v : Fin D → ℝ) (i : Fin m) :
    rowForm (weightedRows a z i) v = linearEvaluation (a i) z * linearEvaluation (a i) v := by
  simp only [rowForm, weightedRows, linearEvaluation, Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro j _
  ring

lemma squaredImageNorm_weightedRows_sub (a : Fin m → Fin D → ℝ) (z u v : Fin D → ℝ) :
    squaredImageNorm (weightedRows a z) (u-v) =
      ∑ i, (linearEvaluation (a i) u-linearEvaluation (a i) v)^2 * linearEvaluation (a i) z^2 := by
  unfold squaredImageNorm
  apply Finset.sum_congr rfl
  intro i _
  rw [rowForm_weightedRows]
  change (_ * linearEvaluation (a i) (fun j => u j-v j))^2 = _
  rw [linearEvaluation_sub]
  ring

lemma weightedRows_trace_le (a : Fin m → Fin D → ℝ) (z : Fin D → ℝ) (V : ℝ)
    (hvar : ∀ i, (∑ j, a i j^2) ≤ V) :
    (∑ i, ∑ j, weightedRows a z i j^2) ≤ V*∑ i, linearEvaluation (a i) z^2 := by
  simp only [weightedRows, mul_pow, ← Finset.mul_sum]
  calc
    (∑ i, linearEvaluation (a i) z^2 * ∑ j, a i j^2) ≤
        ∑ i, linearEvaluation (a i) z^2 * V :=
      Finset.sum_le_sum (fun i _ => mul_le_mul_of_nonneg_left (hvar i) (sq_nonneg _))
    _ = V*∑ i, linearEvaluation (a i) z^2 := by rw [Finset.mul_sum]; apply Finset.sum_congr rfl; intros; ring

lemma rankOneEnergy_controls_euclidean (a : Fin m → Fin D → ℝ) (u : Fin D → ℝ) :
    (∑ j, u j^2) ≤ rankOneEnergy a u := by
  exact le_add_of_nonneg_right (Finset.sum_nonneg (fun _ _ => sq_nonneg _))

lemma rankOneMetricSquared_scaled_local_comparison
    (a : Fin m → Fin D → ℝ) (x y z : Fin D → ℝ) (c R : ℝ) (hc : 0 ≤ c)
    (hR : ∀ i, c*(linearEvaluation (a i) x-linearEvaluation (a i) y)^2 ≤ R) :
    c*rankOneMetricSquared a x y ≤
      2*R*((∑ i, (linearEvaluation (a i) x-linearEvaluation (a i) z)^2) +
        ∑ i, (linearEvaluation (a i) y-linearEvaluation (a i) z)^2) +
      4*c*squaredImageNorm (weightedRows a z) (x-y) := by
  rw [squaredImageNorm_weightedRows_sub]
  have hp (i : Fin m) :
      c*((linearEvaluation (a i) x-linearEvaluation (a i) y)^2 *
        (linearEvaluation (a i) x^2+linearEvaluation (a i) y^2)) ≤
      2*R*((linearEvaluation (a i) x-linearEvaluation (a i) z)^2+
        (linearEvaluation (a i) y-linearEvaluation (a i) z)^2) +
      4*c*((linearEvaluation (a i) x-linearEvaluation (a i) y)^2 * linearEvaluation (a i) z^2) := by
    let X := linearEvaluation (a i) x
    let Y := linearEvaluation (a i) y
    let Z := linearEvaluation (a i) z
    have h₁ : X^2+Y^2 ≤ 2*((X-Z)^2+(Y-Z)^2)+4*Z^2 := by
      nlinarith only [sq_nonneg (X-2*Z), sq_nonneg (Y-2*Z)]
    have h₂ := mul_le_mul_of_nonneg_left h₁ (mul_nonneg hc (sq_nonneg (X-Y)))
    have h₃ := mul_le_mul_of_nonneg_right (hR i)
      (show 0 ≤ (X-Z)^2+(Y-Z)^2 by positivity)
    change c*((X-Y)^2*(X^2+Y^2)) ≤ 2*R*((X-Z)^2+(Y-Z)^2)+4*c*((X-Y)^2*Z^2)
    nlinarith only [h₂, h₃]
  have hs := Finset.sum_le_sum (fun i (_ : i ∈ Finset.univ) => hp i)
  simpa only [rankOneMetricSquared, Finset.sum_add_distrib, ← Finset.mul_sum] using hs

/-- A single Gaussian packing controls an actual rank-one separated family
localized in the quadratic energy around a common point. -/
theorem rankOne_local_packing {K : Type*} [Fintype K]
    (a : Fin m → Fin D → ℝ) (z : Fin D → ℝ) (u : K → Fin D → ℝ)
    (V W t ρ δ : ℝ) (hV : 0 < V) (hW : 0 < W) (ht : 0 ≤ t)
    (hρ : 0 ≤ ρ) (hδ : 0 < δ)
    (hvar : ∀ i, (∑ j, a i j^2) ≤ V)
    (hsize : 8*(m:ℝ)*Real.exp (-t^2/(2*V)) ≤ 1)
    (htrace : (∑ i, ∑ j, weightedRows a z i j^2) ≤ W)
    (henergy : ∀ j, rankOneEnergy a (fun l => u j l-z l) ≤ ρ)
    (hsep : ∀ i j, i ≠ j → δ^2 ≤ rankOneMetricSquared a (u i) (u j)) :
    (Fintype.card K : ℝ) ≤
      2*Real.exp ((16*ρ^2*t^2+64*ρ*W)/δ^2) := by
  let s : ℝ := Real.sqrt ((32*ρ*t^2+128*W)/δ^2)
  have hnum : 0 < 32*ρ*t^2+128*W := by positivity
  have hspos : 0 < s := Real.sqrt_pos.2 (div_pos hnum (sq_pos_of_pos hδ))
  have hssq : s^2 = (32*ρ*t^2+128*W)/δ^2 :=
    Real.sq_sqrt (le_of_lt (div_pos hnum (sq_pos_of_pos hδ)))
  have hsid : s^2*δ^2 = 32*ρ*t^2+128*W := by rw [hssq]; field_simp
  have hscaledsep (i j : K) (hij : i ≠ j) :
      (∃ l, 2*t ≤ |rowForm (a l) (s • (u i-z)-s • (u j-z))|) ∨
        16*W ≤ squaredImageNorm (weightedRows a z) (s • (u i-z)-s • (u j-z)) := by
    have hsub : s • (u i-z)-s • (u j-z) = s • (u i-u j) := by ext l; simp only [Pi.sub_apply, Pi.smul_apply, smul_eq_mul]; ring
    rw [hsub]
    by_contra hn
    push Not at hn
    have hrow (l : Fin m) : s^2*(linearEvaluation (a l) (u i)-linearEvaluation (a l) (u j))^2 ≤ 4*t^2 := by
      have hh := (sq_le_sq₀ (abs_nonneg _) (mul_nonneg (by norm_num) ht)).2 (le_of_lt (hn.1 l))
      rw [rowForm_smul, rowForm_sub, sq_abs, mul_pow] at hh
      simpa only [rowForm, linearEvaluation, mul_pow, show (2:ℝ)^2=4 by norm_num] using hh
    have himage : s^2*squaredImageNorm (weightedRows a z) (u i-u j) < 16*W := by
      simpa only [squaredImageNorm_smul] using hn.2
    have hlocal := rankOneMetricSquared_scaled_local_comparison a (u i) (u j) z (s^2) (4*t^2) (sq_nonneg s) hrow
    have hui := (rankOneEnergy_controls_rows a (u i) z).trans (henergy i)
    have huj := (rankOneEnergy_controls_rows a (u j) z).trans (henergy j)
    have hsum := mul_le_mul_of_nonneg_left (add_le_add hui huj) (show 0 ≤ 8*t^2 by positivity)
    have hlow := mul_le_mul_of_nonneg_left (hsep i j hij) (sq_nonneg s)
    nlinarith only [hlocal, hsum, himage, hlow, hsid, hW, mul_nonneg hρ (sq_nonneg t)]
  have hbound := gaussian_mixed_packing a (weightedRows a z) (fun j => s • (u j-z))
    V W t (s^2*ρ) hV hW ht hvar (by simpa using hsize) htrace hscaledsep
    (fun j => by
      have he := (rankOneEnergy_controls_euclidean a (fun l => u j l-z l)).trans (henergy j)
      simpa only [Pi.smul_apply, smul_eq_mul, Pi.sub_apply, mul_pow, ← Finset.mul_sum] using
        mul_le_mul_of_nonneg_left he (sq_nonneg s))
  have heq : s^2*ρ/2 = (16*ρ^2*t^2+64*ρ*W)/δ^2 := by rw [hssq]; ring
  rwa [heq] at hbound

/-- Explicit row count version, with the actual base row energy at most one. -/
theorem rankOne_local_packing_explicit {K : Type*} [Fintype K]
    (a : Fin m → Fin D → ℝ) (z : Fin D → ℝ) (u : K → Fin D → ℝ)
    (V ρ δ : ℝ) (hm : 0 < m) (hV : 0 < V) (hρ : 0 ≤ ρ) (hδ : 0 < δ)
    (hvar : ∀ i, (∑ j, a i j^2) ≤ V)
    (hz : (∑ i, linearEvaluation (a i) z^2) ≤ 1)
    (henergy : ∀ j, rankOneEnergy a (fun l => u j l-z l) ≤ ρ)
    (hsep : ∀ i j, i ≠ j → δ^2 ≤ rankOneMetricSquared a (u i) (u j)) :
    (Fintype.card K : ℝ) ≤
      2*Real.exp ((32*ρ^2*V*Real.log (8*(m:ℝ))+64*ρ*V)/δ^2) := by
  let C : ℝ := 8*(m:ℝ)
  have hm' : (1:ℝ) ≤ m := by exact_mod_cast hm
  have hC : 0 < C := by dsimp only [C]; linarith
  have hlog : 0 ≤ Real.log C := Real.log_nonneg (by dsimp only [C]; linarith)
  let t : ℝ := Real.sqrt (2*V*Real.log C)
  have ht2 : t^2 = 2*V*Real.log C := Real.sq_sqrt (by positivity)
  have hsize : C*Real.exp (-t^2/(2*V)) ≤ 1 := by
    have he : -t^2/(2*V) = -Real.log C := by rw [ht2]; field_simp
    rw [he, Real.exp_neg, Real.exp_log hC]
    exact le_of_eq (mul_inv_cancel₀ (ne_of_gt hC))
  have htrace := (weightedRows_trace_le a z V hvar).trans
    (show V*(∑ i, linearEvaluation (a i) z^2) ≤ V by nlinarith only [mul_le_mul_of_nonneg_left hz hV.le])
  have h := rankOne_local_packing a z u V V t ρ δ hV hV (Real.sqrt_nonneg _)
    hρ hδ hvar hsize htrace henergy hsep
  have he : (16*ρ^2*t^2+64*ρ*V)/δ^2 =
      (32*ρ^2*V*Real.log C+64*ρ*V)/δ^2 := by rw [ht2]; ring
  rwa [he] at h

/-- The corresponding actual entropy tradeoff. -/
theorem rankOne_local_packing_log {K : Type*} [Fintype K] [Nonempty K]
    (a : Fin m → Fin D → ℝ) (z : Fin D → ℝ) (u : K → Fin D → ℝ)
    (V ρ δ : ℝ) (hm : 0 < m) (hV : 0 < V) (hρ : 0 ≤ ρ) (hδ : 0 < δ)
    (hvar : ∀ i, (∑ j, a i j^2) ≤ V)
    (hz : (∑ i, linearEvaluation (a i) z^2) ≤ 1)
    (henergy : ∀ j, rankOneEnergy a (fun l => u j l-z l) ≤ ρ)
    (hsep : ∀ i j, i ≠ j → δ^2 ≤ rankOneMetricSquared a (u i) (u j)) :
    Real.log ((Fintype.card K:ℝ)/2)*δ^2 ≤
      32*ρ^2*V*Real.log (8*(m:ℝ))+64*ρ*V := by
  have hc : 0 < (Fintype.card K:ℝ)/2 := by positivity
  have h := rankOne_local_packing_explicit a z u V ρ δ hm hV hρ hδ hvar hz henergy hsep
  have he : (Fintype.card K:ℝ)/2 ≤
      Real.exp ((32*ρ^2*V*Real.log (8*(m:ℝ))+64*ρ*V)/δ^2) := by linarith only [h]
  have hl := Real.log_le_iff_le_exp hc |>.2 he
  exact (le_div_iff₀ (sq_pos_of_pos hδ)).mp hl

end NeuralGeneralization.SquaredSampling
