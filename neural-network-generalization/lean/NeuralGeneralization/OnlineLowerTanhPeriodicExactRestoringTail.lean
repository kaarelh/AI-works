import NeuralGeneralization.OnlineLowerTanhPeriodicHarmonic

/-! Exact rational error bounds for the restoring-curvature truncation. -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.OnlineLowerTanh

lemma restoringTail_choose (j : ℕ) :
    (2*(j:ℝ)+13)^2+2 =
      8*((j+2).choose 2:ℝ)+40*((j+1).choose 1:ℝ)+123 := by
  have h := odd_square_choose j
  simp only [Nat.choose_one_right, Nat.cast_add, Nat.cast_one]
  nlinarith

lemma restoringTail_hasSum {q : ℝ} (hq : |q|<1) :
    HasSum (fun j : ℕ => ((2*(j:ℝ)+13)^2+2)*q^(j+6))
      (q^6*(8/(1-q)^3+40/(1-q)^2+123/(1-q))) := by
  have h2 := hasSum_choose_mul_geometric_of_norm_lt_one 2 (r:=q) hq
  have h1 := hasSum_choose_mul_geometric_of_norm_lt_one 1 (r:=q) hq
  have h0 := hasSum_geometric_of_abs_lt_one hq
  have h := (((h2.mul_left 8).add (h1.mul_left 40)).add (h0.mul_left 123)).mul_right (q^6)
  convert! h using 1
  · ext j
    rw [restoringTail_choose, pow_add]
    ring
  · norm_num
    ring

lemma restoringTail_summable {q : ℝ} (hq : |q|<1) :
    Summable (fun j : ℕ => ((2*(j:ℝ)+13)^2+2)*q^(j+6)) :=
  (restoringTail_hasSum hq).summable

lemma restoringTail_sum {q : ℝ} (hq : |q|<1) :
    (∑' j : ℕ, ((2*(j:ℝ)+13)^2+2)*q^(j+6)) =
      q^6*(8/(1-q)^3+40/(1-q)^2+123/(1-q)) :=
  (restoringTail_hasSum hq).tsum_eq

lemma restoringTail_le_upper {q : ℝ} (hq0 : 0≤q) (hq : q≤17/200) :
    (∑' j : ℕ, ((2*(j:ℝ)+13)^2+2)*q^(j+6)) ≤
      (17/200:ℝ)^6*(8/(1-17/200)^3+40/(1-17/200)^2+123/(1-17/200)) := by
  have hq1 : |q|<1 := by rw [abs_of_nonneg hq0]; linarith
  have hu : |(17/200:ℝ)|<1 := by norm_num
  calc
    _ ≤ ∑' j : ℕ, ((2*(j:ℝ)+13)^2+2)*(17/200:ℝ)^(j+6) :=
      Summable.tsum_le_tsum
        (fun j => mul_le_mul_of_nonneg_left (pow_le_pow_left₀ hq0 hq _) (by positivity))
        (restoringTail_summable hq1) (restoringTail_summable hu)
    _ = _ := restoringTail_sum hu

lemma restoringTail_remainder_lt {q : ℝ} (hq0 : 0≤q) (hq : q≤17/200) :
    (∑' j : ℕ, ((2*(j:ℝ)+13)^2+2)*q^(j+6)) + 295*q^15/(1-q) < 1/10000 := by
  have htail := restoringTail_le_upper hq0 hq
  have hp : 0<1-q := by linarith
  have hpoly : 295*q^15/(1-q) ≤ 295*(17/200:ℝ)^15/(1-17/200) := by
    apply div_le_div₀ (by positivity) ?_ (by positivity) (by linarith)
    exact mul_le_mul_of_nonneg_left (pow_le_pow_left₀ hq0 hq 15) (by norm_num)
  have hexact :
      (17/200:ℝ)^6*(8/(1-17/200)^3+40/(1-17/200)^2+123/(1-17/200)) +
      295*(17/200:ℝ)^15/(1-17/200) < 1/10000 := by norm_num
  linarith

/-- Exact remainder after a finite geometric approximation of a normalized coefficient. -/
lemma restoringRatio_geometric_remainder {q : ℝ} (hq0 : 0≤q) (hq1 : q<1)
    (j m n : ℕ) (hm : 0<m) :
    q^j*(1-q)/(1-q^m) -
        (1-q)*(∑ ℓ ∈ Finset.range n, q^(j+m*ℓ)) =
      q^(j+m*n)*(1-q)/(1-q^m) := by
  have hqm : q^m<1 := pow_lt_one₀ hq0 hq1 (by omega)
  have hd : 1-q^m≠0 := by linarith
  have hs : (∑ ℓ ∈ Finset.range n, q^(j+m*ℓ)) =
      q^j*(∑ ℓ ∈ Finset.range n, (q^m)^ℓ) := by
    rw [Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro ℓ hℓ
    rw [pow_add, pow_mul]
  rw [hs, pow_add, pow_mul]
  have hg := geom_sum_mul_neg (q^m) n
  have hg' : (1-q^m)*(∑ ℓ ∈ Finset.range n, (q^m)^ℓ)=1-(q^m)^n := by
    nlinarith [hg]
  field_simp
  rw [hg']
  ring

lemma restoringRatio_geometric_error_le {q : ℝ} (hq0 : 0≤q) (hq1 : q<1)
    (j m n K : ℕ) (hm : 0<m) (hK : K≤j+m*n) :
    |q^j*(1-q)/(1-q^m) -
        (1-q)*(∑ ℓ ∈ Finset.range n, q^(j+m*ℓ))| ≤ q^K := by
  rw [restoringRatio_geometric_remainder hq0 hq1 j m n hm]
  have hqm : q^m<1 := pow_lt_one₀ hq0 hq1 (by omega)
  have hqm' : q^m≤q := by
    simpa only [pow_one] using pow_le_pow_of_le_one hq0 hq1.le hm
  have hd : 0<1-q^m := by linarith
  rw [abs_of_nonneg (by positivity)]
  calc
    _ ≤ q^(j+m*n) := by
      apply (div_le_iff₀ hd).mpr
      exact mul_le_mul_of_nonneg_left (by linarith) (pow_nonneg hq0 _)
    _ ≤ q^K := pow_le_pow_of_le_one hq0 hq1.le hK

lemma restoringRatio_geometric_error_le_margin {q : ℝ} (hq0 : 0≤q) (hq1 : q<1)
    (j m n : ℕ) (hm : 0<m) (hK : 15≤j+m*n) :
    |q^j*(1-q)/(1-q^m) -
        (1-q)*(∑ ℓ ∈ Finset.range n, q^(j+m*ℓ))| ≤ q^15/(1-q) := by
  apply (restoringRatio_geometric_error_le hq0 hq1 j m n 15 hm hK).trans
  apply (le_div_iff₀ (by linarith : 0<1-q)).mpr
  nlinarith [pow_nonneg hq0 15, mul_nonneg (pow_nonneg hq0 15) hq0]

end NeuralGeneralization.OnlineLowerTanh
