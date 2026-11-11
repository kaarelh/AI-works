import NeuralGeneralization.BatchTwoContinuousDepthChannelAnalysis

/-! Normalized tanh channels and their actual inverses. Inverse channels do
not enlarge bounded labels, so the shallow 8/7 inverse remains sufficient. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1000000
open Set
namespace NeuralGeneralization.BatchTwoContinuousDepthPaper
open ConcreteModel BatchTwoNeuralConverse

def normalizedTanh (r t : ℝ) : ℝ := Real.tanh (Real.artanh r*t)/r

def inverseNormalizedTanh (r y : ℝ) : ℝ := Real.artanh (r*y)/Real.artanh r

theorem artanh_neg_eq {x : ℝ} (hx : x ∈ Ioo (-1 : ℝ) 1) :
    Real.artanh (-x) = -Real.artanh x := by
  apply Real.tanh_injective
  rw [Real.tanh_artanh (by constructor <;> linarith [hx.1,hx.2]),Real.tanh_neg,Real.tanh_artanh hx]

theorem artanh_mul_chord {r y : ℝ} (hr : r ∈ Ioo (0 : ℝ) 1)
    (hy : y ∈ Icc (0 : ℝ) 1) : Real.artanh (r*y) ≤ y*Real.artanh r := by
  have ht := tanh_chord (Real.artanh_nonneg hr.1.le) hy
  rw [Real.tanh_artanh (by constructor <;> linarith [hr.1,hr.2])] at ht
  have hlo : -1 < r*y := by nlinarith [mul_nonneg hr.1.le hy.1]
  have h := Real.artanh_le_artanh hlo (Real.tanh_lt_one _) (by simpa only [mul_comm] using ht)
  rw [Real.artanh_tanh] at h
  simpa only [mul_comm] using h

theorem inverseNormalizedTanh_abs_le {r y : ℝ} (hr : r ∈ Ioo (0 : ℝ) 1)
    (hy : |y| ≤ 1) : |inverseNormalizedTanh r y| ≤ |y| := by
  have hp : 0 < Real.artanh r := Real.artanh_pos hr
  have hprod : r*y ∈ Ioo (-1 : ℝ) 1 := by
    have hy' := abs_le.mp hy
    constructor <;> nlinarith [hr.1,hr.2,mul_nonneg hr.1.le (by linarith [hy'.1] : 0 ≤ y+1),
      mul_nonneg hr.1.le (by linarith [hy'.2] : 0 ≤ 1-y)]
  have habs : |Real.artanh (r*y)| = Real.artanh (r*|y|) := by
    by_cases hy0 : 0 ≤ y
    · rw [abs_of_nonneg hy0,abs_of_nonneg (Real.artanh_nonneg (mul_nonneg hr.1.le hy0))]
    · have hy0' : y ≤ 0 := le_of_not_ge hy0
      rw [abs_of_nonpos hy0',mul_neg,artanh_neg_eq hprod,
        abs_of_nonpos (Real.artanh_nonpos (mul_nonpos_of_nonneg_of_nonpos hr.1.le hy0'))]
  unfold inverseNormalizedTanh
  rw [abs_div,abs_of_pos hp,habs]
  apply (div_le_iff₀ hp).mpr
  exact artanh_mul_chord hr ⟨abs_nonneg y,hy⟩

theorem normalizedTanh_inverse {r y : ℝ} (hr : r ∈ Ioo (0 : ℝ) 1)
    (hy : |y| ≤ 1) : normalizedTanh r (inverseNormalizedTanh r y)=y := by
  have hp : Real.artanh r ≠ 0 := (Real.artanh_pos hr).ne'
  have hprod : r*y ∈ Ioo (-1 : ℝ) 1 := by
    have hy' := abs_le.mp hy
    constructor <;> nlinarith [hr.1,hr.2,mul_nonneg hr.1.le (by linarith [hy'.1] : 0 ≤ y+1),
      mul_nonneg hr.1.le (by linarith [hy'.2] : 0 ≤ 1-y)]
  unfold normalizedTanh inverseNormalizedTanh
  rw [mul_div_cancel₀ _ hp,Real.tanh_artanh hprod,mul_div_cancel_left₀ _ hr.1.ne']

theorem normalizedTanh_abs_le_one {r t : ℝ} (hr : r ∈ Ioo (0 : ℝ) 1)
    (ht : |t| ≤ 1) : |normalizedTanh r t| ≤ 1 := by
  have ha : 0 ≤ Real.artanh r := (Real.artanh_pos hr).le
  have h1 := mul_le_mul_of_nonneg_left (abs_le.mp ht).2 ha
  have h2 := mul_le_mul_of_nonneg_left (abs_le.mp ht).1 ha
  have hu := tanh_monotone h1
  have hl := tanh_monotone h2
  simp only [mul_one,mul_neg_one,Real.tanh_neg,Real.tanh_artanh
    (show r ∈ Ioo (-1 : ℝ) 1 by constructor <;> linarith [hr.1,hr.2])] at hu hl
  unfold normalizedTanh
  rw [abs_div,abs_of_pos hr.1]
  apply (div_le_iff₀ hr.1).mpr
  simpa only [one_mul] using abs_le.mpr ⟨hl,hu⟩

def channelComposition (rs : List ℝ) (x : ℝ) : ℝ :=
  rs.foldl (fun t r => normalizedTanh r t) x

def inverseChannelComposition (rs : List ℝ) (y : ℝ) : ℝ :=
  rs.foldr inverseNormalizedTanh y

theorem inverseChannelComposition_bound (rs : List ℝ)
    (hrs : ∀ r ∈ rs, r ∈ Ioo (0 : ℝ) 1) {y : ℝ} (hy : |y| ≤ 1) :
    |inverseChannelComposition rs y| ≤ |y| := by
  induction rs with
  | nil => simp [inverseChannelComposition]
  | cons r rs ih =>
    have hrest := ih (fun r hr => hrs r (List.mem_cons_of_mem _ hr))
    change |inverseNormalizedTanh r (inverseChannelComposition rs y)| ≤ |y|
    exact (inverseNormalizedTanh_abs_le (hrs r (by simp)) (hrest.trans hy)).trans hrest

theorem channelComposition_inverse (rs : List ℝ)
    (hrs : ∀ r ∈ rs, r ∈ Ioo (0 : ℝ) 1) {y : ℝ} (hy : |y| ≤ 1) :
    channelComposition rs (inverseChannelComposition rs y)=y := by
  induction rs with
  | nil => rfl
  | cons r rs ih =>
    have hrs' := fun r hr => hrs r (List.mem_cons_of_mem _ hr)
    change channelComposition rs (normalizedTanh r
      (inverseNormalizedTanh r (inverseChannelComposition rs y)))=y
    rw [normalizedTanh_inverse (hrs r (by simp))
      ((inverseChannelComposition_bound rs hrs' hy).trans hy)]
    exact ih hrs'

theorem channelComposition_bound (rs : List ℝ)
    (hrs : ∀ r ∈ rs, r ∈ Ioo (0 : ℝ) 1) {x : ℝ} (hx : |x| ≤ 1) :
    |channelComposition rs x| ≤ 1 := by
  induction rs generalizing x with
  | nil => exact hx
  | cons r rs ih =>
    exact ih (fun r hr => hrs r (List.mem_cons_of_mem _ hr))
      (normalizedTanh_abs_le_one (hrs r (by simp)) hx)

end NeuralGeneralization.BatchTwoContinuousDepthPaper
