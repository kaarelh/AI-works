import NeuralGeneralization.RobustCircuitEnergy

/-! # Finite-noise Boolean saturation estimates in squared Euclidean norm -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.ConcreteModel
variable {N : ℕ}

/-- No restriction is placed on the signs or magnitudes of the perturbation
coordinates. The large-perturbation branch is built into the secant bound. -/
theorem saturation_squared_error
    (b : Fin N → Bool) (q u η : Fin N → ℝ) {A U V : ℝ}
    (hA : 0 < A) (hq : ∀ i, A/2 ≤ labelReal (b i)*q i)
    (hu : (∑ i, u i^2) ≤ U) (hη : (∑ i, η i^2) ≤ V) :
    (∑ i, (Real.tanh (q i+u i)+η i-labelReal (b i))^2) ≤
      3*((N:ℝ)*(4/A)^2+(8/A)^2*U+V) := by
  have hpoint (i : Fin N) :
      (Real.tanh (q i+u i)+η i-labelReal (b i))^2 ≤
        3*((4/A)^2+(8/A)^2*(u i)^2+(η i)^2) := by
    have hs := tanh_global_secant (b i) (u := u i) hA (hq i)
    have htri : |Real.tanh (q i+u i)+η i-labelReal (b i)| ≤
        4/A+8*|u i|/A+|η i| := by
      have hh := abs_add_le (Real.tanh (q i+u i)-labelReal (b i)) (η i)
      rw [show Real.tanh (q i+u i)-labelReal (b i)+η i =
        Real.tanh (q i+u i)+η i-labelReal (b i) by ring] at hh
      linarith
    have hright : 0 ≤ 4/A+8*|u i|/A+|η i| := by positivity
    have hsq := (sq_le_sq₀ (abs_nonneg _) hright).mpr htri
    rw [sq_abs] at hsq
    have hthree (x y z : ℝ) : (x+y+z)^2 ≤ 3*(x^2+y^2+z^2) := by
      nlinarith [sq_nonneg (x-y), sq_nonneg (x-z), sq_nonneg (y-z)]
    have hh := hsq.trans (hthree (4/A) (8*|u i|/A) |η i|)
    have hterm : (8*|u i|/A)^2 = (8/A)^2*(u i)^2 := by
      rw [div_pow, mul_pow, sq_abs, div_pow]
      ring
    simpa only [hterm, sq_abs] using hh

  calc
    _ ≤ ∑ i, 3*((4/A)^2+(8/A)^2*(u i)^2+(η i)^2) :=
      Finset.sum_le_sum fun i _ => hpoint i
    _ = 3*((N:ℝ)*(4/A)^2+(8/A)^2*(∑ i, (u i)^2)+∑ i, (η i)^2) := by
      simp only [← Finset.mul_sum, Finset.sum_add_distrib, Finset.sum_const,
        Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
    _ ≤ _ := by
      have hh := mul_le_mul_of_nonneg_left hu (sq_nonneg (8/A))
      linarith

/-- RMS perturbations from a small row projection and a bounded free
operator. The latter annihilates the ideal Boolean state. -/
theorem cylinder_perturbation_squared
    (R E : Fin N → Fin N → ℝ) (h b : Fin N → ℝ)
    {ρ G B e : ℝ}
    (hR : (∑ i, ∑ j, R i j^2) ≤ ρ^2*G)
    (hE : matrixActionBound E B)
    (hkill : ∀ i, (∑ j, E i j*b j)=0)
    (hstate : (∑ i, (h i-b i)^2) ≤ (N:ℝ)*e^2)
    (hideal : ∀ i, |b i| ≤ 1) :
    (∑ i, ((∑ j, R i j*h j)+(∑ j, E i j*h j))^2) ≤
      (N:ℝ)*(4*ρ^2*G*(1+e^2)+2*B^2*e^2) := by
  have hbnorm : (∑ i,b i^2) ≤ (N:ℝ) := by
    simpa only [Fintype.card_fin, one_pow, mul_one] using
      finite_sum_sq_le_card_mul b (by norm_num : (0:ℝ)≤1) hideal
  have hnormh : (∑ i,h i^2) ≤ 2*(N:ℝ)*(1+e^2) := by
    calc
      _ ≤ ∑ i,2*((h i-b i)^2+(b i)^2) := Finset.sum_le_sum fun i _ => by
        nlinarith [sq_nonneg (h i-2*b i)]
      _ = 2*((∑ i,(h i-b i)^2)+∑ i,b i^2) := by
        simp only [← Finset.mul_sum, Finset.sum_add_distrib]
      _ ≤ _ := by nlinarith
  have hRpos : 0 ≤ ρ^2*G :=
    (Finset.sum_nonneg fun _ _ => Finset.sum_nonneg fun _ _ => sq_nonneg _).trans hR
  have hRA := NeuralGeneralization.Compression.matrix_action_squaredSum_le R h
  have hRbound : (∑ i,(∑ j,R i j*h j)^2) ≤
      ρ^2*G*(2*(N:ℝ)*(1+e^2)) :=
    hRA.trans (mul_le_mul hR hnormh
      (Finset.sum_nonneg fun _ _ => sq_nonneg _) hRpos)
  have hEbound : (∑ i,(∑ j,E i j*h j)^2) ≤ B^2*((N:ℝ)*e^2) := by
    have heq : ∀ i, (∑ j,E i j*h j) = ∑ j,E i j*(h j-b j) := by
      intro i
      simp only [mul_sub, Finset.sum_sub_distrib, hkill, sub_zero]
    simp_rw [heq]
    exact (hE _).trans (mul_le_mul_of_nonneg_left hstate (sq_nonneg B))
  calc
    _ ≤ ∑ i,2*((∑ j,R i j*h j)^2+(∑ j,E i j*h j)^2) :=
      Finset.sum_le_sum fun i _ => by
        nlinarith [sq_nonneg ((∑ j,R i j*h j)-(∑ j,E i j*h j))]
    _ = 2*((∑ i,(∑ j,R i j*h j)^2)+∑ i,(∑ j,E i j*h j)^2) := by
      simp only [← Finset.mul_sum, Finset.sum_add_distrib]
    _ ≤ _ := by nlinarith

end NeuralGeneralization.ConcreteModel
