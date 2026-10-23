import NeuralGeneralization.BatchTwoNonGaussianLinearTail
import Mathlib.MeasureTheory.Function.Floor
import Mathlib.Algebra.Order.Chebyshev

/-! A uniform small ball for the difference of two independent identically
distributed real variables. It uses interval collisions, not smooth densities
or a central limit approximation. -/
noncomputable section
open MeasureTheory Set Function
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoNonGaussian

def collisionBins (R ρ : ℝ) : ℕ := ⌈2*R/ρ⌉₊+1

def collisionBin (R ρ : ℝ) (i : ℕ) : Set ℝ :=
  Ico ((i : ℝ)*ρ-R) (((i : ℝ)+1)*ρ-R)

theorem collisionBin_measurable (R ρ : ℝ) (i : ℕ) : MeasurableSet (collisionBin R ρ i) :=
  measurableSet_Ico

theorem collisionBin_disjoint {R ρ : ℝ} (hρ : 0 < ρ) :
    Pairwise (Disjoint on (fun i : Fin (collisionBins R ρ) => collisionBin R ρ i)) := by
  intro i j hij
  apply Set.disjoint_left.mpr
  intro x hxi hxj
  change (i : ℝ)*ρ-R ≤ x ∧ x<((i : ℝ)+1)*ρ-R at hxi
  change (j : ℝ)*ρ-R ≤ x ∧ x<((j : ℝ)+1)*ρ-R at hxj
  rcases lt_or_gt_of_ne (show (i : ℕ) ≠ (j : ℕ) from fun h => hij (Fin.ext h)) with h | h
  · have hnat : (i : ℕ)+1 ≤ (j : ℕ) := h
    have hreal : (i : ℝ)+1 ≤ (j : ℝ) := by exact_mod_cast hnat
    nlinarith
  · have hnat : (j : ℕ)+1 ≤ (i : ℕ) := h
    have hreal : (j : ℝ)+1 ≤ (i : ℝ) := by exact_mod_cast hnat
    nlinarith

theorem collisionBin_cover {R ρ : ℝ} (hR : 0 ≤ R) (hρ : 0 < ρ) :
    Icc (-R) R ⊆ ⋃ i : Fin (collisionBins R ρ), collisionBin R ρ i := by
  intro x hx
  let j := ⌊(x+R)/ρ⌋₊
  have hx0 : 0 ≤ (x+R)/ρ := div_nonneg (by linarith [hx.1]) hρ.le
  have hjlo : (j : ℝ) ≤ (x+R)/ρ := Nat.floor_le hx0
  have hjhi : (x+R)/ρ < (j : ℝ)+1 := Nat.lt_floor_add_one _
  have hceil : (x+R)/ρ ≤ (⌈2*R/ρ⌉₊ : ℝ) := by
    apply le_trans _ (Nat.le_ceil _)
    exact div_le_div_of_nonneg_right (by linarith [hx.2]) hρ.le
  have hjN : j < collisionBins R ρ := by
    have hjle : j ≤ ⌈2*R/ρ⌉₊ := by exact_mod_cast hjlo.trans hceil
    dsimp [collisionBins]
    omega
  apply mem_iUnion.mpr
  refine ⟨⟨j,hjN⟩,?_⟩
  change (j : ℝ)*ρ-R ≤ x ∧ x<((j : ℝ)+1)*ρ-R
  constructor
  · have hh := (le_div_iff₀ hρ).mp hjlo
    linarith
  · have hh := (div_lt_iff₀ hρ).mp hjhi
    linarith

theorem collisionBin_diameter {R ρ : ℝ} {i : ℕ} {x y : ℝ}
    (hx : x ∈ collisionBin R ρ i) (hy : y ∈ collisionBin R ρ i) : |x-y| ≤ ρ := by
  change (i : ℝ)*ρ-R ≤ x ∧ x<((i : ℝ)+1)*ρ-R at hx
  change (i : ℝ)*ρ-R ≤ y ∧ y<((i : ℝ)+1)*ρ-R at hy
  exact abs_le.mpr ⟨by linarith,by linarith⟩

/-- Any half-mass bounded interval gives a linear small-ball lower bound for
an iid difference, at every scale and with no density assumption. -/
theorem iid_difference_small_ball (μ : Measure ℝ) [IsProbabilityMeasure μ]
    {R ρ : ℝ} (hR : 0 ≤ R) (hρ : 0 < ρ) (hρ1 : ρ ≤ 1)
    (hcentral : 1/2 ≤ μ.real (Icc (-R) R)) :
    ρ/(8*(R+1)) ≤ (μ.prod μ).real {z : ℝ × ℝ | |z.1-z.2| ≤ ρ} := by
  classical
  let n := collisionBins R ρ
  let E (i : Fin n) := collisionBin R ρ i
  let p (i : Fin n) : ℝ := μ.real (E i)
  have hp : 1/2 ≤ ∑ i, p i := by
    apply hcentral.trans
    apply (measureReal_mono (collisionBin_cover hR hρ) (measure_ne_top _ _)).trans
    exact measureReal_iUnion_fintype_le E
  have hp0 : 0 ≤ ∑ i, p i := Finset.sum_nonneg (fun _ _ => measureReal_nonneg)
  have hsq : 1/4 ≤ (n : ℝ)*(∑ i, p i^2) := by
    have hh := Finset.sum_mul_sq_le_sq_mul_sq (s := Finset.univ) p (fun _ => (1 : ℝ))
    simp only [mul_one,one_pow,Finset.sum_const,Finset.card_univ,Fintype.card_fin,nsmul_eq_mul,mul_one] at hh
    nlinarith
  have hdisj : Pairwise (Disjoint on (fun i : Fin n => E i ×ˢ E i)) := by
    intro i j hij
    apply Set.disjoint_left.mpr
    intro z hi hj
    exact (Set.disjoint_left.mp (collisionBin_disjoint hρ hij)) hi.1 hj.1
  have hmass : (∑ i, p i^2) ≤ (μ.prod μ).real {z : ℝ × ℝ | |z.1-z.2| ≤ ρ} := by
    calc
      _ = (μ.prod μ).real (⋃ i : Fin n, E i ×ˢ E i) := by
        rw [measureReal_iUnion_fintype hdisj (fun i =>
          (collisionBin_measurable R ρ i).prod (collisionBin_measurable R ρ i))]
        apply Finset.sum_congr rfl
        intro i hi
        rw [measureReal_prod_prod]
        exact sq _
      _ ≤ _ := measureReal_mono (by
        intro z hz
        obtain ⟨i,hi⟩ := mem_iUnion.mp hz
        exact collisionBin_diameter hi.1 hi.2) (measure_ne_top _ _)
  have hn0 : (0 : ℝ) < n := by
    dsimp [n,collisionBins]
    positivity
  have hn : (n : ℝ)*ρ ≤ 2*(R+1) := by
    have hc := Nat.ceil_lt_add_one (div_nonneg (by linarith : 0 ≤ 2*R) hρ.le)
    have hcle : (⌈2*R/ρ⌉₊ : ℝ) ≤ 2*R/ρ+1 := hc.le
    have hh := mul_le_mul_of_nonneg_right hcle hρ.le
    have hid : (2*R/ρ+1)*ρ=2*R+ρ := by field_simp
    rw [hid] at hh
    dsimp [n,collisionBins]
    push_cast
    nlinarith
  have hsum0 : 0 ≤ ∑ i, p i^2 := Finset.sum_nonneg (fun _ _ => sq_nonneg _)
  apply le_trans _ hmass
  apply (div_le_iff₀ (by positivity : 0 < 8*(R+1))).mpr
  have hh := mul_le_mul_of_nonneg_right hsq hρ.le
  have hh' := mul_le_mul_of_nonneg_right hn hsum0
  nlinarith

end NeuralGeneralization.BatchTwoNonGaussian
