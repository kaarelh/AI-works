import NeuralGeneralization.ArcsineNoiseTail
import Mathlib.Analysis.Real.Pi.Bounds

/-!
# Elementary polynomial floor for the actual neural covariance

A direct finite-cube mixing estimate bounds every power-kernel eigenvalue
from below once the power is quadratic in the ambient dimension. Selecting
one actual positive arcsine-series term then gives a polynomial lower floor
for the full covariance matrix at every fixed depth.
-/

noncomputable section
namespace NeuralGeneralization
open scoped BigOperators

/-- Away from the identity vertex, the biased dot product has an explicit
strict absolute contraction, including the antipodal vertex. -/
theorem biasedProfile_identity_gap {d : ℕ} (hd : 1 ≤ d) (x : ClippingCube d)
    (hx : x ≠ fun _ => true) :
    |biasedProfile id x| ≤ 1-2/((d : ℝ)+1) := by
  classical
  have hsign (i : Fin d) : -1 ≤ cubeCoordinateSign (x i) ∧
      cubeCoordinateSign (x i) ≤ 1 := by
    cases x i <;> norm_num [cubeCoordinateSign]
  have hsome : ∃ i, x i = false := by
    by_contra hn
    apply hx
    funext i
    have h := not_exists.mp hn i
    cases hi : x i <;> simp_all
  obtain ⟨i,hi⟩ := hsome
  have hlow : -(d : ℝ) ≤ ∑ j,cubeCoordinateSign (x j) := by
    have h := Finset.sum_le_sum (s := Finset.univ) (fun j hj => (hsign j).1)
    simpa using h
  have hupp : (∑ j,cubeCoordinateSign (x j)) ≤ (d : ℝ)-2 := by
    have h := Finset.sum_le_sum (s := Finset.univ.erase i)
      (fun j hj => (hsign j).2)
    have hc : ((Finset.univ.erase i).card : ℝ) = (d : ℝ)-1 := by
      rw [Finset.card_erase_of_mem (Finset.mem_univ i),Finset.card_univ,Fintype.card_fin]
      simpa only [Nat.cast_one] using (Nat.cast_sub hd : ((d-1 : ℕ) : ℝ) = (d : ℝ)-(1 : ℕ))
    simp only [Finset.sum_const,nsmul_eq_mul,mul_one] at h
    rw [hc] at h
    rw [← Finset.add_sum_erase _ _ (Finset.mem_univ i)]
    simp only [hi,cubeCoordinateSign,Bool.false_eq_true,if_false]
    simp only [cubeCoordinateSign] at h
    linarith
  have hD : 0 < (d : ℝ)+1 := by positivity
  unfold biasedProfile
  dsimp only [id_eq]
  rw [abs_div,abs_of_pos hD]
  apply (div_le_iff₀ hD).mpr
  rw [sub_mul,one_mul,div_mul_cancel₀ _ (ne_of_gt hD)]
  apply abs_le.mpr
  constructor <;> linarith

/-- A uniform error bound for the actual finite power spectrum. -/
theorem biasedDot_power_coefficient_mixing_error {d : ℕ} (hd : 1 ≤ d)
    (m : ℕ) (S : Finset (Fin d)) :
    1-(2 : ℝ)^d*(1-2/((d : ℝ)+1))^m ≤
      (2 : ℝ)^d * walshCoefficients (biasedProfile (fun t => t^m)) S := by
  classical
  let q : ℝ := 1-2/((d : ℝ)+1)
  have hdR : (1 : ℝ) ≤ d := by exact_mod_cast hd
  have hq0 : 0 ≤ q := by
    dsimp [q]
    have hD : 0 < (d : ℝ)+1 := by positivity
    have h := (div_le_one hD).mpr (show (2 : ℝ) ≤ d+1 by linarith)
    linarith
  have hsignabs (x : ClippingCube d) (i : Fin d) : |cubeCoordinateSign (x i)|=1 := by
    cases x i <;> norm_num [cubeCoordinateSign]
  have hχ (x : ClippingCube d) : |walshCharacter S x|=1 := by
    simp [walshCharacter,Finset.abs_prod,hsignabs]
  let e : ClippingCube d := fun _ => true
  let F : ClippingCube d → ℝ := fun x => (biasedProfile id x)^m*walshCharacter S x
  have he : F e = 1 := by
    simp [F,e,biasedProfile,cubeCoordinateSign,walshCharacter,add_comm,
      show (d : ℝ)+1 ≠ 0 by positivity]
  have hterm (x : ClippingCube d) (hx : x ∈ Finset.univ.erase e) : -q^m ≤ F x := by
    have hgap := biasedProfile_identity_gap hd x (Finset.mem_erase.mp hx).1
    have habs : |F x| ≤ q^m := by
      dsimp [F]
      rw [abs_mul,abs_pow,hχ,mul_one]
      exact pow_le_pow_left₀ (abs_nonneg _) hgap m
    exact (abs_le.mp habs).1
  have hsum := Finset.sum_le_sum hterm
  have hc : ((Finset.univ.erase e).card : ℝ) ≤ (2 : ℝ)^d := by
    have h := Finset.card_le_card (Finset.erase_subset (a := e) (s := Finset.univ))
    have h' : (Finset.univ.erase e).card ≤ Fintype.card (ClippingCube d) := by simpa using h
    exact_mod_cast (by simpa [ClippingCube] using h' : (Finset.univ.erase e).card ≤ 2^d)
  have hsum' : -(2 : ℝ)^d*q^m ≤ ∑ x ∈ Finset.univ.erase e,F x := by
    simp only [Finset.sum_const,nsmul_eq_mul] at hsum
    have hmul := mul_le_mul_of_nonneg_right hc (pow_nonneg hq0 m)
    linarith
  have hM : (Fintype.card (ClippingCube d) : ℝ) = (2 : ℝ)^d := by simp [ClippingCube]
  unfold walshCoefficients uniformCubeMean
  rw [hM,mul_div_cancel₀ _ (pow_ne_zero _ (by norm_num : (2 : ℝ) ≠ 0))]
  change 1-(2 : ℝ)^d*q^m ≤ ∑ x,F x
  rw [← Finset.add_sum_erase _ _ (Finset.mem_univ e),he]
  linarith

/-- Quadratic-time mixing needs no analytic asymptotics. -/
theorem biasedDot_power_coefficient_mixing {d : ℕ} (hd : 1 ≤ d)
    (m : ℕ) (hm : (d+1)^2 ≤ m) (S : Finset (Fin d)) :
    (1/2 : ℝ) ≤ (2 : ℝ)^d * walshCoefficients (biasedProfile (fun t => t^m)) S := by
  let q : ℝ := 1-2/((d : ℝ)+1)
  have hdR : (1 : ℝ) ≤ d := by exact_mod_cast hd
  have hD : 0 < (d : ℝ)+1 := by positivity
  have ht : 2/((d : ℝ)+1) ≤ 1 := (div_le_one hD).mpr (by linarith)
  have hq0 : 0 ≤ q := by dsimp [q]; linarith
  have hq1 : q ≤ 1 := by
    dsimp [q]
    linarith [div_nonneg (by norm_num : (0 : ℝ) ≤ 2) hD.le]
  have hbern := one_sub_pow_mul_le_one ht (d+1)
  have hc : (1+(d+1 : ℕ)* (2/((d : ℝ)+1))) = 3 := by push_cast; field_simp; ring
  rw [hc] at hbern
  have hblock : q^(d+1) ≤ (1/2 : ℝ) := by dsimp [q]; linarith
  have hpm : q^m ≤ (1/2 : ℝ)^(d+1) := by
    calc
      q^m ≤ q^((d+1)^2) := pow_le_pow_of_le_one hq0 hq1 hm
      _ = (q^(d+1))^(d+1) := by rw [pow_two,pow_mul]
      _ ≤ _ := pow_le_pow_left₀ (pow_nonneg hq0 _) hblock _
  have hmass : (2 : ℝ)^d*q^m ≤ 1/2 := by
    have h := mul_le_mul_of_nonneg_left hpm (by positivity : (0 : ℝ) ≤ 2^d)
    have he : (2 : ℝ)^d*(1/2 : ℝ)^(d+1)=1/2 := by
      rw [pow_succ,← mul_assoc,← mul_pow]
      norm_num
    rwa [he] at h
  have hmixed := biasedDot_power_coefficient_mixing_error hd m S
  change 1-(2 : ℝ)^d*q^m ≤ _ at hmixed
  linarith

/-- At a square index the elementary Wallis lower bound gives the sharper
cubic polynomial estimate, without Stirling or Gamma asymptotics. -/
theorem arcsineLinkCoefficient_square_index_lower (d : ℕ) :
    1 ≤ 12*((d : ℝ)+1)^3 * arcsineLinkCoefficient ((d+1)^2) := by
  let n := (d+1)^2
  let D : ℝ := (d : ℝ)+1
  have hD : 1 ≤ D := by dsimp [D]; linarith [Nat.cast_nonneg (α := ℝ) d]
  have hn : 0 < n := by dsimp [n]; positivity
  have hWallis : 1 ≤ (4*(n : ℝ))*arcsineDerivativeCoefficient n^2 := by
    obtain ⟨j,hj⟩ := Nat.exists_eq_succ_of_ne_zero (Nat.ne_of_gt hn)
    rw [hj]
    simpa only [Nat.succ_eq_add_one,Nat.cast_add,Nat.cast_one] using
      arcsineDerivativeCoefficient_square_lower j
  have hnR : (n : ℝ)=D^2 := by dsimp [n,D]; push_cast; rfl
  have ha0 := (arcsineDerivativeCoefficient_pos n).le
  have hlinear : 1 ≤ 2*D*arcsineDerivativeCoefficient n := by
    apply (sq_le_sq₀ (by norm_num : (0 : ℝ) ≤ 1)
      (by positivity : 0 ≤ 2*D*arcsineDerivativeCoefficient n)).mp
    rw [hnR] at hWallis
    nlinarith only [hWallis]
  have hm : (2*n+1 : ℝ) ≤ 3*D^2 := by rw [hnR]; nlinarith
  have hc := (arcsineCoefficient_pos n).le
  have hid : (2*n+1 : ℝ)*arcsineCoefficient n = arcsineDerivativeCoefficient n := by
    unfold arcsineCoefficient
    field_simp
  have hraw : 1 ≤ 6*D^3*arcsineCoefficient n := by
    calc
      1 ≤ 2*D*arcsineDerivativeCoefficient n := hlinear
      _ = 2*D*(2*n+1 : ℝ)*arcsineCoefficient n := by rw [← hid]; ring
      _ ≤ 2*D*(3*D^2)*arcsineCoefficient n := by
        gcongr
      _ = _ := by ring
  have hpi : (1/2 : ℝ) ≤ 2/Real.pi := by
    apply (le_div_iff₀ Real.pi_pos).mpr
    linarith [Real.pi_lt_four]
  have hnorm : arcsineCoefficient n ≤ 2*arcsineLinkCoefficient n := by
    unfold arcsineLinkCoefficient
    nlinarith [mul_le_mul_of_nonneg_right hpi hc]
  have hscaled := mul_le_mul_of_nonneg_left hnorm (by positivity : (0 : ℝ) ≤ 6*D^3)
  change 1 ≤ 12*D^3*arcsineLinkCoefficient n
  nlinarith only [hraw,hscaled]

/-- Every eigenvalue of the first-layer full covariance matrix is at least
`1 / (24*(d+1)^3)`. This is weaker than the optimal floor but polynomial. -/
theorem first_arcsine_full_coefficient_polynomial_lower {d : ℕ} (hd : 1 ≤ d)
    (S : Finset (Fin d)) :
    1 ≤ 24*((d : ℝ)+1)^3 *
      ((2 : ℝ)^d*walshCoefficients (arcsineProfile d 1) S) := by
  let n := (d+1)^2
  have hp := biasedDot_power_coefficient_mixing hd (2*n+1)
    (show (d+1)^2 ≤ 2*n+1 by dsimp [n]; omega) S
  have hbase : ∀ T, 0 ≤ walshCoefficients (arcsineProfile d 0) T :=
    arcsineProfile_coefficient_nonneg d 0
  have ht := profile_series_coefficient_term_lower
    (arcsineProfile d 0) (arcsineProfile d 1) arcsineLinkCoefficient (fun j => 2*j+1)
    hbase (fun j => (arcsineLinkCoefficient_pos j).le) (arcsineProfile_series d 0) n S
  have ht' := mul_le_mul_of_nonneg_left ht (by positivity : (0 : ℝ) ≤ 2^d)
  have he : (fun x => arcsineProfile d 0 x^(2*n+1)) =
      biasedProfile (fun t => t^(2*n+1)) := rfl
  rw [he] at ht'
  have hcp := mul_le_mul_of_nonneg_left hp (arcsineLinkCoefficient_pos n).le
  have hmass : arcsineLinkCoefficient n/2 ≤
      (2 : ℝ)^d*walshCoefficients (arcsineProfile d 1) S := by
    nlinarith only [ht',hcp]
  have hc := arcsineLinkCoefficient_square_index_lower d
  change 1 ≤ 12*((d : ℝ)+1)^3*arcsineLinkCoefficient n at hc
  have hh := mul_le_mul_of_nonneg_left hmass
    (by positivity : (0 : ℝ) ≤ 24*((d : ℝ)+1)^3)
  nlinarith only [hc,hh]

/-- Uniform polynomial full-matrix eigenvalue floor at every fixed positive
depth, proved for the actual iterated arcsine covariance. -/
theorem iterated_arcsine_full_coefficient_polynomial_lower {d : ℕ} (hd : 1 ≤ d)
    (k : ℕ) (S : Finset (Fin d)) :
    (2/Real.pi)^k / (24*((d : ℝ)+1)^3) ≤
      (2 : ℝ)^d*walshCoefficients (arcsineProfile d (k+1)) S := by
  have hfirst := first_arcsine_full_coefficient_polynomial_lower hd S
  have hiter := iterated_arcsine_coefficient_lower d k S
  have hc0 : 0 ≤ (2/Real.pi)^k := by positivity
  have hfirst' := mul_le_mul_of_nonneg_left hfirst hc0
  have hiter' := mul_le_mul_of_nonneg_left hiter
    (by positivity : (0 : ℝ) ≤ 24*((d : ℝ)+1)^3*(2 : ℝ)^d)
  apply (div_le_iff₀ (by positivity : (0 : ℝ) < 24*((d : ℝ)+1)^3)).mpr
  nlinarith only [hfirst',hiter']

end NeuralGeneralization
