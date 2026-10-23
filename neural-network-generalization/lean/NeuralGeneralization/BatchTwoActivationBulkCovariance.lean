import NeuralGeneralization.BatchTwoActivationBulkDecomposition

/-!
# The deterministic covariance decomposition for unbounded activations

The only activation assumptions are a global Lipschitz bound and vanishing at
zero. A global row cutoff forces every retained tail row to have a large source
residual. Its covariance is then represented by unit-source atoms with bounded
total squared-radius weight.
-/

noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoActivation

/-- A scalar outer-product perturbation estimate. -/
theorem scalar_outer_error {z z' u u' b c : ℝ}
    (hb : 0≤b) (hc : 0≤c) (he : |z-u|≤b) (he' : |z'-u'|≤b)
    (hu : |u|≤c) (hu' : |u'|≤c) :
    |z*z'-u*u'|≤b^2+2*b*c := by
  have hz' : |z'|≤b+c := by
    calc
      _ = |(z'-u')+u'| := by congr 1; ring
      _ ≤ |z'-u'|+|u'| := abs_add_le _ _
      _ ≤ b+c := add_le_add he' hu'
  calc
    _ = |(z-u)*z'+u*(z'-u')| := by congr 1; ring
    _ ≤ |(z-u)*z'|+|u*(z'-u')| := abs_add_le _ _
    _ = |z-u| *|z'|+|u| *|z'-u'| := by rw [abs_mul,abs_mul]
    _ ≤ b*(b+c)+c*b := by gcongr
    _ = _ := by ring

/-- A large residual pays for both the bounded displacement and the
unbounded cross term in a tail outer product. -/
theorem tail_scalar_outer_error {φ : ℝ→ℝ} {ℓ B S δ T w z z' u u' : ℝ}
    (hφ : zeroLipschitzActivation ℓ φ) (hℓ : 0≤ℓ) (hB : 0≤B)
    (hS : 0≤S) (hδ : 0≤δ) (hT : 0<T) (hBT : 2*B≤T)
    (hw : 0≤w) (hw1 : w≤1) (htail : 0<w→T≤2*S*δ)
    (he : |z-u|≤B) (he' : |z'-u'|≤B)
    (hu : |u|≤S*δ) (hu' : |u'|≤S*δ) :
    |w*(φ z*φ z'-φ u*φ u')|≤6*ℓ^2*B*S^2*δ^2/T := by
  have h := scalar_outer_error (mul_nonneg hℓ hB) (by positivity : 0≤ℓ*(S*δ))
    ((hφ.2 z u).trans (mul_le_mul_of_nonneg_left he hℓ))
    ((hφ.2 z' u').trans (mul_le_mul_of_nonneg_left he' hℓ))
    ((activation_abs_le hφ u).trans (mul_le_mul_of_nonneg_left hu hℓ))
    ((activation_abs_le hφ u').trans (mul_le_mul_of_nonneg_left hu' hℓ))
  by_cases hwp : 0<w
  · have hs := htail hwp
    have hBS : B≤S*δ := by linarith
    have hbound : (ℓ*B)^2+2*(ℓ*B)*(ℓ*(S*δ))≤3*ℓ^2*B*(S*δ) := by
      have hp := mul_le_mul_of_nonneg_left hBS (by positivity : 0≤ℓ^2*B)
      nlinarith
    have hbound' : 3*ℓ^2*B*(S*δ)≤6*ℓ^2*B*S^2*δ^2/T := by
      apply (le_div_iff₀ hT).mpr
      have hp := mul_le_mul_of_nonneg_left hs (by positivity : 0≤3*ℓ^2*B*(S*δ))
      nlinarith
    calc
      _ = w*|φ z*φ z'-φ u*φ u'| := by rw [abs_mul,abs_of_nonneg hw]
      _ ≤ |φ z*φ z'-φ u*φ u'| := by
        exact mul_le_of_le_one_left (abs_nonneg _) hw1
      _ ≤ (ℓ*B)^2+2*(ℓ*B)*(ℓ*(S*δ)) := h
      _ ≤ _ := hbound.trans hbound'
  · have hw0 : w=0 := le_antisymm (le_of_not_gt hwp) hw
    rw [hw0,zero_mul,abs_zero]
    positivity

/-- The complete empirical covariance estimate, with no hidden boundedness
assumption on the original feature rows. -/
theorem empirical_bulk_covariance {J I : Type*} [Fintype J] [Fintype I]
    {φ : ℝ→ℝ} {ℓ B S T A : ℝ} (hφ : zeroLipschitzActivation ℓ φ)
    (hℓ : 0≤ℓ) (hB : 0≤B) (hS : 0≤S) (hT : 0<T) (hBT : 2*B≤T)
    (z u : J→I→ℝ) (δ w : J→ℝ)
    (hδ : ∀j, 0≤δ j) (hw : ∀j, 0≤w j) (hw1 : ∀j, w j≤1)
    (htail : ∀j, 0<w j→T≤2*S*δ j)
    (he : ∀j i, |z j i-u j i|≤B) (hu : ∀j i, |u j i|≤S*δ j)
    (henergy : ∑ j, (δ j)^2≤(Fintype.card J : ℝ)*A) (i k : I) :
    |∑ j, (φ (z j i)*φ (z j k) -
      ((1-w j)*φ (z j i)*φ (z j k)+w j*φ (u j i)*φ (u j k)))|≤
      (Fintype.card J : ℝ)*(6*ℓ^2*B*S^2*A/T) := by
  classical
  have hid (j : J) : φ (z j i)*φ (z j k) -
      ((1-w j)*φ (z j i)*φ (z j k)+w j*φ (u j i)*φ (u j k))=
      w j*(φ (z j i)*φ (z j k)-φ (u j i)*φ (u j k)) := by ring
  simp_rw [hid]
  calc
    _ ≤ ∑ j, |w j*(φ (z j i)*φ (z j k)-φ (u j i)*φ (u j k))| :=
      Finset.abs_sum_le_sum_abs _ _
    _ ≤ ∑ j, 6*ℓ^2*B*S^2*(δ j)^2/T := by
      apply Finset.sum_le_sum
      intro j _
      exact tail_scalar_outer_error hφ hℓ hB hS (hδ j) hT hBT
        (hw j) (hw1 j) (htail j) (he j i) (he j k) (hu j i) (hu j k)
    _ = (6*ℓ^2*B*S^2/T)*(∑ j, (δ j)^2) := by
      rw [Finset.mul_sum]
      congr 1
      ext j
      ring
    _ ≤ (6*ℓ^2*B*S^2/T)*((Fintype.card J : ℝ)*A) :=
      mul_le_mul_of_nonneg_left henergy (by positivity)
    _ = _ := by ring

/-- The next-layer diagonal follows from the same source-energy event. -/
theorem empirical_activation_diagonal {J : Type*} [Fintype J]
    {φ : ℝ→ℝ} {ℓ B S A : ℝ} (hφ : zeroLipschitzActivation ℓ φ)
    (hℓ : 0≤ℓ) (hB : 0≤B) (hS : 0≤S)
    (z u δ : J→ℝ) (hδ : ∀j, 0≤δ j)
    (he : ∀j, |z j-u j|≤B) (hu : ∀j, |u j|≤S*δ j)
    (henergy : ∑ j, (δ j)^2≤(Fintype.card J : ℝ)*A) :
    (∑ j, (φ (z j))^2)≤(Fintype.card J : ℝ)*(2*ℓ^2*B^2+2*ℓ^2*S^2*A) := by
  have hz j : |φ (z j)|≤ℓ*B+ℓ*S*δ j := by
    have hzu : |z j|≤B+S*δ j := by
      calc
        _ = |(z j-u j)+u j| := by congr 1; ring
        _ ≤ |z j-u j|+|u j| := abs_add_le _ _
        _ ≤ _ := add_le_add (he j) (hu j)
    have hh := (activation_abs_le hφ (z j)).trans (mul_le_mul_of_nonneg_left hzu hℓ)
    nlinarith
  have hsq j : (φ (z j))^2≤2*ℓ^2*B^2+2*ℓ^2*S^2*(δ j)^2 := by
    have hn : 0≤ℓ*B+ℓ*S*δ j := add_nonneg (mul_nonneg hℓ hB) (mul_nonneg (mul_nonneg hℓ hS) (hδ j))
    have hh := sq_le_sq₀ (abs_nonneg (φ (z j))) hn |>.mpr (hz j)
    rw [sq_abs] at hh
    nlinarith [sq_nonneg (ℓ*B-ℓ*S*δ j)]
  calc
    _ ≤ ∑ j, (2*ℓ^2*B^2+2*ℓ^2*S^2*(δ j)^2) := Finset.sum_le_sum (fun j _ => hsq j)
    _ = (Fintype.card J : ℝ)*(2*ℓ^2*B^2)+(2*ℓ^2*S^2)*(∑ j, (δ j)^2) := by
      rw [Finset.sum_add_distrib,Finset.sum_const,←Finset.mul_sum]
      simp only [Finset.card_univ,nsmul_eq_mul]
    _ ≤ (Fintype.card J : ℝ)*(2*ℓ^2*B^2)+(2*ℓ^2*S^2)*((Fintype.card J : ℝ)*A) := by
      gcongr
    _ = _ := by ring

end NeuralGeneralization.BatchTwoActivation
