import NeuralGeneralization.DepthNormBallNetwork
import Mathlib.Algebra.Order.Floor.Ring

/-! The depth-dependent amplitude and population schedule, with rounding controlled. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1000000
open scoped BigOperators
namespace NeuralGeneralization.DepthNormBall
open Classical ConcreteModel

def vertices (q : ℕ) : ℝ := Fintype.card (Cube q)
lemma vertices_pos (q : ℕ) : 0 < vertices q := by unfold vertices; exact_mod_cast Fintype.card_pos
lemma vertices_one_le (q : ℕ) : 1 ≤ vertices q := by
  unfold vertices
  exact_mod_cast Fintype.card_pos (α := Cube q)
lemma width_real (q : ℕ) : (width q:ℝ)=2*vertices q := by simp [width,vertices]
lemma width_one_le (q : ℕ) : (1:ℝ) ≤ width q := by exact_mod_cast width_pos q

def growth (q m : ℕ) : ℝ := Real.log (vertices q)*((m:ℝ)-1)/(2*m*(m+1))
def amplitude (q m j : ℕ) : ℝ := (3/4)*Real.exp (((j:ℝ)-m)*growth q m)
def populationReal (q m j : ℕ) : ℝ := Real.exp ((j:ℝ)*Real.log (width q)/m)
def population (q m j : ℕ) : ℕ := ⌈populationReal q m j⌉₊
def depthBudget (q m : ℕ) : ℝ := Real.exp (2*Real.log (vertices q)/(m+1))

lemma growth_nonneg (q : ℕ) {m : ℕ} (hm : 0 < m) : 0 ≤ growth q m := by
  have hmR : (1:ℝ) ≤ m := by exact_mod_cast hm
  unfold growth
  exact div_nonneg (mul_nonneg (Real.log_nonneg (vertices_one_le q)) (by linarith)) (by positivity)

lemma amplitude_pos (q m j : ℕ) : 0 < amplitude q m j := by unfold amplitude; positivity
lemma amplitude_le (q : ℕ) {m : ℕ} (hm : 0 < m) {j : ℕ} (hj : j ≤ m) :
    amplitude q m j ≤ 3/4 := by
  have hjR : (j:ℝ) ≤ m := by exact_mod_cast hj
  have he : Real.exp (((j:ℝ)-m)*growth q m) ≤ 1 :=
    Real.exp_le_one_iff.mpr (mul_nonpos_of_nonpos_of_nonneg (by linarith) (growth_nonneg q hm))
  unfold amplitude
  linarith
lemma amplitude_last (q m : ℕ) : amplitude q m m=3/4 := by simp [amplitude]
lemma amplitude_ratio (q m j : ℕ) :
    amplitude q m (j+1)/amplitude q m j=Real.exp (growth q m) := by
  have he : ((j+1:ℕ):ℝ)-m=((j:ℝ)-m)+1 := by push_cast; ring
  unfold amplitude
  rw [he,add_mul,one_mul,Real.exp_add]
  field_simp

lemma populationReal_pos (q m j : ℕ) : 0 < populationReal q m j := Real.exp_pos _
lemma populationReal_one_le (q m j : ℕ) : 1 ≤ populationReal q m j := by
  apply Real.one_le_exp_iff.mpr
  exact div_nonneg (mul_nonneg (Nat.cast_nonneg j) (Real.log_nonneg (width_one_le q))) (Nat.cast_nonneg m)
lemma populationReal_le (q : ℕ) {m : ℕ} (hm : 0 < m) {j : ℕ} (hj : j ≤ m) :
    populationReal q m j ≤ width q := by
  have hmR : (0:ℝ)<m := by exact_mod_cast hm
  rw [populationReal,← Real.exp_log (Nat.cast_pos.mpr (width_pos q))]
  rw [Real.log_exp]
  apply Real.exp_le_exp.mpr
  apply (div_le_iff₀ hmR).mpr
  have hjR : (j:ℝ)≤m := by exact_mod_cast hj
  nlinarith [mul_le_mul_of_nonneg_right hjR (Real.log_nonneg (width_one_le q))]
lemma population_zero (q m : ℕ) : population q m 0=1 := by simp [population,populationReal]
lemma population_last (q : ℕ) {m : ℕ} (hm : 0 < m) : population q m m=width q := by
  have hmR : (m:ℝ)≠0 := by exact_mod_cast hm.ne'
  have he : (m:ℝ)*Real.log (width q)/m=Real.log (width q) := by field_simp
  simp [population,populationReal,he,Real.exp_log (Nat.cast_pos.mpr (width_pos q))]
lemma population_pos (q m j : ℕ) : 0 < population q m j :=
  Nat.one_le_ceil_iff.mpr (populationReal_pos q m j)
lemma population_le (q : ℕ) {m : ℕ} (hm : 0 < m) {j : ℕ} (hj : j ≤ m) :
    population q m j ≤ width q := Nat.ceil_le.mpr (populationReal_le q hm hj)
lemma populationReal_le_population (q m j : ℕ) :
    populationReal q m j ≤ population q m j := Nat.le_ceil _
lemma population_le_twice (q m j : ℕ) :
    (population q m j:ℝ) ≤ 2*populationReal q m j := by
  have h := Nat.ceil_lt_add_one (populationReal_pos q m j).le
  change (population q m j:ℝ)<populationReal q m j+1 at h
  linarith [populationReal_one_le q m j]
lemma populationReal_step (q m j : ℕ) :
    populationReal q m (j+1)=populationReal q m j*Real.exp (Real.log (width q)/m) := by
  unfold populationReal
  rw [← Real.exp_add]
  congr 1
  push_cast
  ring
lemma population_ratio (q m j : ℕ) :
    (population q m (j+1):ℝ)/(population q m j:ℝ) ≤
      2*Real.exp (Real.log (width q)/m) := by
  have hn : (0:ℝ)<population q m j := by exact_mod_cast population_pos q m j
  apply (div_le_iff₀ hn).mpr
  calc
    _ ≤ 2*populationReal q m (j+1) := population_le_twice q m (j+1)
    _ = 2*Real.exp (Real.log (width q)/m)*populationReal q m j := by rw [populationReal_step]; ring
    _ ≤ _ := mul_le_mul_of_nonneg_left (populationReal_le_population q m j) (by positivity)

lemma depthBudget_one_le (q m : ℕ) : 1 ≤ depthBudget q m := by
  apply Real.one_le_exp_iff.mpr
  exact div_nonneg (mul_nonneg (by norm_num) (Real.log_nonneg (vertices_one_le q))) (by positivity)

lemma initial_balance (q : ℕ) {m : ℕ} (hm : 0 < m) :
    vertices q*(amplitude q m 0)^2=(9/16:ℝ)*depthBudget q m := by
  have hmR : (m:ℝ)≠0 := by exact_mod_cast hm.ne'
  have hm1 : (m:ℝ)+1≠0 := by positivity
  have he : Real.log (vertices q)+2*((0:ℝ)-m)*growth q m = 2*Real.log (vertices q)/(m+1) := by
    unfold growth
    field_simp
    <;> ring
  unfold amplitude depthBudget
  simp only [Nat.cast_zero,mul_pow]
  rw [← Real.exp_nat_mul,← Real.exp_log (vertices_pos q)]
  have he' : (2:ℝ)*Real.log (Real.exp (Real.log (vertices q)))/(m+1) =
      Real.log (vertices q)+2*((0:ℝ)-m)*growth q m := by rw [Real.log_exp]; exact he.symm
  rw [he']
  rw [Real.exp_add]
  ring

lemma relay_balance (q : ℕ) {m : ℕ} (hm : 0 < m) :
    Real.exp (Real.log (width q)/m)*(Real.exp (growth q m))^2 ≤ 2*depthBudget q m := by
  have hmR : (m:ℝ)≠0 := by exact_mod_cast hm.ne'
  have hmR1 : (1:ℝ)≤m := by exact_mod_cast hm
  have hm1 : (m:ℝ)+1≠0 := by positivity
  have he : Real.log (width q)/m+2*growth q m=
      Real.log 2/m+2*Real.log (vertices q)/(m+1) := by
    rw [width_real,Real.log_mul (by norm_num) (vertices_pos q).ne']
    unfold growth
    field_simp
    <;> ring
  have htwo : Real.exp (Real.log 2/m) ≤ (2:ℝ) := by
    rw [← Real.exp_log (by norm_num : (0:ℝ)<2)]
    apply Real.exp_le_exp.mpr
    rw [Real.log_exp]
    apply (div_le_iff₀ (by positivity : (0:ℝ)<m)).mpr
    nlinarith [Real.log_nonneg (by norm_num : (1:ℝ)≤2)]
  rw [← Real.exp_nat_mul,← Real.exp_add]
  norm_num only [Nat.cast_ofNat]
  rw [he,Real.exp_add]
  exact mul_le_mul_of_nonneg_right htwo (Real.exp_pos _).le

lemma schedule_relay_bound (q : ℕ) {m : ℕ} (hm : 0 < m) (j : ℕ) :
    ((population q m (j+1):ℝ)/(population q m j:ℝ))*
      (amplitude q m (j+1)/amplitude q m j)^2 ≤ 4*depthBudget q m := by
  rw [amplitude_ratio]
  have hh := mul_le_mul_of_nonneg_right (population_ratio q m j) (sq_nonneg (Real.exp (growth q m)))
  have hb := relay_balance q hm
  linarith

end NeuralGeneralization.DepthNormBall
