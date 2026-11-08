import NeuralGeneralization.OnlineLowerCentralBinomialComplex

/-! Uniform estimates for the elementary central-binomial product. -/
noncomputable section
open scoped BigOperators Topology
open Filter
namespace NeuralGeneralization.OnlineLowerTanh

theorem inverse_fourth_le_telescope {x : ℝ} (hx : 1≤x) :
    1/x^4 ≤ 8*(1/x^3-1/(x+2)^3) := by
  have hx0 : 0<x := by linarith
  have hx2 : 0<x+2 := by linarith
  apply (div_le_iff₀ (pow_pos hx0 4)).mpr
  have he : 8*(1/x^3-1/(x+2)^3)*x^4 =
      8*x*((x+2)^3-x^3)/(x+2)^3 := by field_simp <;> ring
  rw [he]
  apply (le_div_iff₀ (pow_pos hx2 3)).mpr
  nlinarith [pow_nonneg hx0.le 2,pow_nonneg hx0.le 3]

theorem sum_range_inverse_fourth_bound {a : ℝ} (ha : 1≤a) (n : ℕ) :
    (∑ j∈Finset.range n,1/(a+2*j)^4) ≤ 8/a^3 := by
  have h := Finset.sum_le_sum (s:=Finset.range n)
    (fun j _ => inverse_fourth_le_telescope (show 1≤a+2*(j:ℝ) by linarith [Nat.cast_nonneg (α:=ℝ) j]))
  have he : (∑ j∈Finset.range n,8*(1/(a+2*(j:ℝ))^3-1/(a+2*(j:ℝ)+2)^3)) =
      8*(1/a^3-1/(a+2*n)^3) := by
    rw [← Finset.mul_sum]
    have hh := Finset.sum_range_sub' (fun j:ℕ => 1/(a+2*(j:ℝ))^3) n
    simp only [Nat.cast_zero,mul_zero,add_zero] at hh
    convert congrArg (fun t:ℝ => 8*t) hh using 2 <;> congr 1
    funext j
    push_cast
    ring
  rw [he] at h
  have hp : 0≤1/(a+2*(n:ℝ))^3 := by positivity
  have h8 : 8/a^3=8*(1/a^3) := by ring
  rw [h8]
  linarith

theorem summable_inverse_fourth_shift {a : ℝ} (ha : 1≤a) :
    Summable (fun j:ℕ => 1/(a+2*j)^4) :=
  summable_of_sum_range_le (fun j => by positivity) (sum_range_inverse_fourth_bound ha)

theorem tsum_inverse_fourth_bound {a : ℝ} (ha : 1≤a) :
    (∑' j:ℕ,1/(a+2*j)^4) ≤ 8/a^3 :=
  (summable_inverse_fourth_shift ha).tsum_le_of_sum_range_le (sum_range_inverse_fourth_bound ha)

theorem centralBinomial_log_first_error {z : ℂ} (hz : z∈centralBinomialDomain) (j : ℕ) :
    ‖centralBinomialLogTerm j z+(centralBinomialShift z j)⁻¹^2‖ ≤
      ‖(centralBinomialShift z j)⁻¹^2‖^2 := by
  have hq := centralBinomialInverse_norm_lt_quarter hz j
  have h := Complex.norm_log_one_add_sub_self_le
    (z := -(centralBinomialShift z j)⁻¹^2) (by rw [norm_neg]; linarith)
  simp only [norm_neg,← sub_eq_add_neg,sub_neg_eq_add] at h
  refine h.trans ?_
  have hp : 0 < 1-‖(centralBinomialShift z j)⁻¹^2‖ := by linarith
  have hi : (1-‖(centralBinomialShift z j)⁻¹^2‖)⁻¹ ≤ 2 := by
    have hh := one_div_le_one_div_of_le (by norm_num : (0:ℝ)<1/2)
      (show (1:ℝ)/2 ≤ 1-‖(centralBinomialShift z j)⁻¹^2‖ by linarith)
    norm_num [one_div] at hh ⊢
    exact hh
  have hh := mul_le_mul_of_nonneg_left hi (sq_nonneg ‖(centralBinomialShift z j)⁻¹^2‖)
  linarith

theorem halfplane_inverse_shift_bound {z : ℂ} (hz : 0≤z.re) (hz0 : 0<‖z‖)
    {x : ℝ} (hx : 0≤x) : ‖(z+(x:ℂ))⁻¹‖ ≤ 2/(‖z‖+x) := by
  have h := (halfplane_norm_add_real hz hx).2.2
  rw [norm_inv,← one_div]
  have hh := one_div_le_one_div_of_le (show (0:ℝ)<(‖z‖+x)/2 by positivity) h
  have he : 1/((‖z‖+x)/2)=2/(‖z‖+x) := by field_simp
  simpa only [he] using hh

def centralBinomialEvenShift (z : ℂ) (j : ℕ) : ℂ := z+2*(j:ℂ)
def centralBinomialTelescoper (z : ℂ) (j : ℕ) : ℂ :=
  (centralBinomialEvenShift z j * (centralBinomialEvenShift z j+2))⁻¹

theorem centralBinomialEvenShift_ne_zero {z : ℂ} (hz : z∈centralBinomialDomain) (j : ℕ) :
    centralBinomialEvenShift z j ≠ 0 := by
  have h := (halfplane_norm_add_real hz.1.le (show (0:ℝ)≤2*j by positivity)).1
  have he : z+Complex.ofReal (2*(j:ℝ))=centralBinomialEvenShift z j := by simp [centralBinomialEvenShift]
  rw [he] at h
  intro hh
  rw [hh,norm_zero] at h
  linarith [hz.2]

theorem centralBinomial_inverse_center_bound {z : ℂ} (hz : z∈centralBinomialDomain)
    (j : ℕ) (a : ℝ) (ha : 0≤a) :
    ‖(centralBinomialEvenShift z j+(a:ℂ))⁻¹‖ ≤ 2/(‖z‖+2*j) := by
  have h := halfplane_inverse_shift_bound hz.1.le (by linarith [hz.2])
    (show (0:ℝ)≤2*j+a by positivity)
  have he : z+Complex.ofReal (2*(j:ℝ)+a)=centralBinomialEvenShift z j+(a:ℂ) := by
    simp [centralBinomialEvenShift]; ring
  rw [he] at h
  refine h.trans ?_
  have hp : 0<‖z‖+2*(j:ℝ) := by linarith [hz.2,Nat.cast_nonneg (α:=ℝ) j]
  exact div_le_div_of_nonneg_left (by norm_num) hp (by linarith)

theorem centralBinomial_inverse_error_identity {z : ℂ} (hz : z∈centralBinomialDomain) (j : ℕ) :
    (centralBinomialShift z j)⁻¹^2-centralBinomialTelescoper z j =
      -(centralBinomialShift z j)⁻¹^2 * (centralBinomialEvenShift z j)⁻¹ *
        (centralBinomialEvenShift z j+2)⁻¹ := by
  have hv := centralBinomialEvenShift_ne_zero hz j
  have hw : centralBinomialShift z j ≠ 0 := by
    have hh := (centralBinomialShift_norm_bounds hz.1.le j).1
    intro he
    rw [he,norm_zero] at hh
    linarith [hz.2]
  have hv2 : centralBinomialEvenShift z j+2 ≠ 0 := by
    have hh := centralBinomialEvenShift_ne_zero hz (j+1)
    simpa [centralBinomialEvenShift,Nat.cast_add,Nat.cast_one,mul_add,add_assoc] using hh
  have he : centralBinomialShift z j=centralBinomialEvenShift z j+1 := by
    simp [centralBinomialShift,centralBinomialEvenShift]; ring
  unfold centralBinomialTelescoper
  field_simp
  rw [he]
  ring

theorem centralBinomial_inverse_error_bound {z : ℂ} (hz : z∈centralBinomialDomain) (j : ℕ) :
    ‖(centralBinomialShift z j)⁻¹^2-centralBinomialTelescoper z j‖ ≤
      16/(‖z‖+2*j)^4 := by
  rw [centralBinomial_inverse_error_identity hz j,norm_mul,norm_mul,norm_neg,norm_pow]
  have h0 := centralBinomial_inverse_center_bound hz j 0 (by norm_num)
  have h1 := centralBinomial_inverse_center_bound hz j 1 (by norm_num)
  have h2 := centralBinomial_inverse_center_bound hz j 2 (by norm_num)
  norm_num only [Complex.ofReal_ofNat] at h2
  simp only [Complex.ofReal_zero,add_zero] at h0
  have he : centralBinomialEvenShift z j+(1:ℂ)=centralBinomialShift z j := by
    simp [centralBinomialEvenShift,centralBinomialShift]; ring
  norm_num only [Complex.ofReal_one,Complex.ofReal_ofNat] at h1
  rw [he] at h1
  calc
    _ ≤ (2/(‖z‖+2*j))^2*(2/(‖z‖+2*j))*(2/(‖z‖+2*j)) := by gcongr
    _ = _ := by field_simp <;> ring

theorem centralBinomial_log_first_error_bound {z : ℂ} (hz : z∈centralBinomialDomain) (j : ℕ) :
    ‖centralBinomialLogTerm j z+(centralBinomialShift z j)⁻¹^2‖ ≤
      16/(‖z‖+2*j)^4 := by
  refine (centralBinomial_log_first_error hz j).trans ?_
  have h1 := centralBinomial_inverse_center_bound hz j 1 (by norm_num)
  have he : centralBinomialEvenShift z j+(1:ℂ)=centralBinomialShift z j := by
    simp [centralBinomialEvenShift,centralBinomialShift]; ring
  norm_num only [Complex.ofReal_one,Complex.ofReal_ofNat] at h1
  rw [he] at h1
  rw [norm_pow]
  calc
    _ ≤ ((2/(‖z‖+2*j))^2)^2 := by gcongr
    _ = _ := by field_simp <;> ring

end NeuralGeneralization.OnlineLowerTanh
