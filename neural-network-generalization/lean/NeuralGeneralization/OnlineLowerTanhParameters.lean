import NeuralGeneralization.OnlineLowerTanhFamily
import NeuralGeneralization.OnlineLowerTanhTeacher
import Mathlib.Analysis.SpecialFunctions.Exp

/-! # Explicit logarithmic rails and polynomial teacher resources -/

noncomputable section
open scoped BigOperators Topology
open Filter
namespace NeuralGeneralization.OnlineLowerTanh.Family
open OnlineLower OnlineLowerRelu OnlineLowerGeometry ConcreteModel

def constructionLog (k : ℕ) : ℝ := Real.log ((logicalDim k : ℝ)+2)
def constructionBaseline (K k : ℕ) : ℕ := 2*⌈(K:ℝ)*constructionLog k^2⌉₊
def constructionIncrement (k : ℕ) : ℕ := 2*⌈(logicalDim k:ℝ)*constructionLog k⌉₊
abbrev constructionDimension (K k : ℕ) : ℕ :=
  dimension (constructionBaseline K k) (constructionIncrement k) k
abbrev constructionTarget (K k : ℕ) : BooleanFunction (constructionDimension K k) :=
  target (constructionBaseline K k) (constructionIncrement k) k
abbrev constructionTeacherWidth (K k : ℕ) : ℕ :=
  OnlineLowerTanh.teacherWidth (constructionDimension K k) (logicalDim k)

theorem constructionLog_pos (k : ℕ) : 0 < constructionLog k := by
  apply Real.log_pos
  have hm : (0:ℝ) ≤ logicalDim k := Nat.cast_nonneg _
  linarith

theorem constructionBaseline_pos (K k : ℕ) (hK : 0 < K) : 0 < constructionBaseline K k := by
  unfold constructionBaseline
  exact Nat.mul_pos (by norm_num) (Nat.ceil_pos.mpr (mul_pos (Nat.cast_pos.mpr hK)
    (sq_pos_of_pos (constructionLog_pos k))))

theorem constructionIncrement_pos (k : ℕ) : 0 < constructionIncrement k := by
  unfold constructionIncrement
  exact Nat.mul_pos (by norm_num) (Nat.ceil_pos.mpr (mul_pos
    (Nat.cast_pos.mpr (by rw [logicalDim_eq]; omega)) (constructionLog_pos k)))

theorem constructionBaseline_even (K k : ℕ) : Even (constructionBaseline K k) :=
  ⟨⌈(K:ℝ)*constructionLog k^2⌉₊, by unfold constructionBaseline; omega⟩

theorem constructionIncrement_even (k : ℕ) : Even (constructionIncrement k) :=
  ⟨⌈(logicalDim k:ℝ)*constructionLog k⌉₊, by unfold constructionIncrement; omega⟩

theorem constructionBaseline_bounds (K k : ℕ) :
    2*(K:ℝ)*constructionLog k^2 ≤ constructionBaseline K k ∧
    (constructionBaseline K k:ℝ) ≤ 2*(K:ℝ)*constructionLog k^2+2 := by
  have hlo := Nat.le_ceil ((K:ℝ)*constructionLog k^2)
  have hhi := (Nat.ceil_lt_add_one (mul_nonneg (Nat.cast_nonneg K) (sq_nonneg (constructionLog k)))).le
  unfold constructionBaseline
  push_cast
  constructor <;> linarith

theorem constructionIncrement_bounds (k : ℕ) :
    2*(logicalDim k:ℝ)*constructionLog k ≤ constructionIncrement k ∧
    (constructionIncrement k:ℝ) ≤ 2*(logicalDim k:ℝ)*constructionLog k+2 := by
  have hlo := Nat.le_ceil ((logicalDim k:ℝ)*constructionLog k)
  have hhi := (Nat.ceil_lt_add_one (mul_nonneg (Nat.cast_nonneg (α := ℝ) (logicalDim k)) (constructionLog_pos k).le)).le
  unfold constructionIncrement
  push_cast at hlo hhi ⊢
  constructor <;> linarith

theorem splitCount_mul_bound (H R : ℕ) : splitCount H R * R ≤ H + R := by
  have hc := splitCount_le H R
  have hdiv := Nat.div_mul_le_self H R
  calc
    _ ≤ (H/R+1)*R := Nat.mul_le_mul_right _ hc
    _ ≤ _ := by nlinarith

theorem constructionDimension_pos (K k : ℕ) : 0 < constructionDimension K k := by
  exact Nat.succ_pos _

/-- The dimension estimate is proved from the literal integer splitting;
no continuum replacement of the physical pair count is made. -/
theorem constructionDimension_log_bounds (K k : ℕ) (hK : 1 ≤ K) (hk : 1 ≤ k)
    (hl : 1 ≤ constructionLog k) :
    (logicalDim k:ℝ)*constructionLog k^2 ≤ constructionDimension K k ∧
    (constructionDimension K k:ℝ) ≤ 80*(K:ℝ)*(logicalDim k:ℝ)*constructionLog k^2 := by
  let R := constructionBaseline K k
  let H := constructionIncrement k
  let p := OnlineLowerRelu.Family.pairDim k
  let m := logicalDim k
  let l := constructionLog k
  have hKr : (1:ℝ) ≤ K := by exact_mod_cast hK
  have hm : (1:ℝ) ≤ m := by exact_mod_cast (show 1≤logicalDim k by rw [logicalDim_eq]; omega)
  have hp : m ≤ p ∧ p ≤ 2*m := by
    dsimp [m,p]
    rw [logicalDim_eq,OnlineLowerRelu.Family.pairDim_eq]
    omega
  have hpR : (m:ℝ) ≤ p := by exact_mod_cast hp.1
  have hpR2 : (p:ℝ) ≤ 2*m := by exact_mod_cast hp.2
  have hl0 : 0 ≤ l := le_trans (by norm_num) hl
  have hlu : 1 ≤ l^2 := by nlinarith
  have hRl := (constructionBaseline_bounds K k).1
  have hRu := (constructionBaseline_bounds K k).2
  have hHu := (constructionIncrement_bounds k).2
  have hR4 : (R:ℝ) ≤ 4*(K:ℝ)*l^2 := by
    have hh : 1 ≤ (K:ℝ)*l^2 := by nlinarith
    change (R:ℝ) ≤ 2*(K:ℝ)*l^2+2 at hRu
    linarith
  have hH4 : (H:ℝ) ≤ 4*(m:ℝ)*l^2 := by
    change (H:ℝ) ≤ 2*(m:ℝ)*l+2 at hHu
    have hml : 1 ≤ (m:ℝ)*l^2 := by nlinarith
    have hlsq : (m:ℝ)*l ≤ m*l^2 := mul_le_mul_of_nonneg_left (by nlinarith) (by positivity)
    linarith
  have hsplit : (splitCount H R:ℝ)*R ≤ H+R := by exact_mod_cast splitCount_mul_bound H R
  have hd : (constructionDimension K k:ℝ) =
      1+2*((p:ℝ)+2*splitCount H R)*R+4*p+2*H := by
    change ((dimension R H k:ℕ):ℝ) = _
    rw [dimension_eq]
    simp only [pairDim, Nat.cast_add,Nat.cast_mul,Nat.cast_ofNat]
    norm_num [p,OnlineLowerRelu.Family.pairDim,OnlineLowerRelu.Family.prefixDim,OnlineLowerRelu.Family.pathDim]
    ring
  have hpRnonneg : (0:ℝ) ≤ p := Nat.cast_nonneg _
  have hRnonneg : (0:ℝ) ≤ R := Nat.cast_nonneg _
  constructor
  · have hr2 : 2*l^2 ≤ (R:ℝ) := by
      change 2*(K:ℝ)*l^2 ≤ R at hRl
      nlinarith
    have hprod : 2*(m:ℝ)*l^2 ≤ (p:ℝ)*R := by
      nlinarith only [mul_le_mul hpR hr2 (by positivity) hpRnonneg]
    have hHnonneg : (0:ℝ) ≤ H := Nat.cast_nonneg _
    have hgnonneg : (0:ℝ) ≤ splitCount H R := Nat.cast_nonneg _
    rw [hd]
    nlinarith [mul_nonneg hgnonneg hRnonneg]
  · have hpr : (p:ℝ)*R ≤ 8*(K:ℝ)*m*l^2 := by
      have hh := mul_le_mul hpR2 hR4 hRnonneg (by positivity : (0:ℝ)≤2*m)
      nlinarith only [hh]
    have hunit : 1 ≤ (K:ℝ)*m*l^2 := by nlinarith [mul_nonneg (by linarith : 0≤(K:ℝ)-1) (by positivity : 0≤(m:ℝ)*l^2)]
    have hmu : (m:ℝ)*l^2 ≤ (K:ℝ)*m*l^2 := by nlinarith [mul_nonneg (by linarith : 0≤(K:ℝ)-1) (by positivity : 0≤(m:ℝ)*l^2)]
    have hKu : (K:ℝ)*l^2 ≤ (K:ℝ)*m*l^2 := by nlinarith [mul_nonneg (by linarith : 0≤(m:ℝ)-1) (by positivity : 0≤(K:ℝ)*l^2)]
    have hmle : (m:ℝ) ≤ (K:ℝ)*m*l^2 := by nlinarith [mul_nonneg (by positivity : 0≤(m:ℝ)) (by nlinarith : 0≤(K:ℝ)*l^2-1)]
    rw [hd]
    nlinarith



theorem constructionLog_comparison (k : ℕ) (hk : 2 ≤ k) :
    Real.log (k:ℝ) ≤ constructionLog k ∧ constructionLog k ≤ 5*Real.log (k:ℝ) := by
  have hkn : 0 < k := by omega
  have hknR : (0:ℝ) < k := Nat.cast_pos.mpr hkn
  have hpow : 16 ≤ k^4 := (by norm_num : (16:ℕ)≤2^4).trans (Nat.pow_le_pow_left hk 4)
  have hdim : logicalDim k+2 ≤ k^5 := by
    calc
      _ ≤ 10*k := by rw [logicalDim_eq]; omega
      _ ≤ 16*k := by omega
      _ ≤ k^4*k := Nat.mul_le_mul_right k hpow
      _ = _ := by ring
  constructor
  · apply Real.log_le_log hknR
    have hh : k ≤ logicalDim k+2 := by rw [logicalDim_eq]; omega
    exact_mod_cast hh
  · have hh := Real.log_le_log
      (show (0:ℝ)<(logicalDim k:ℝ)+2 by positivity)
      (show (logicalDim k:ℝ)+2 ≤ (k:ℝ)^5 by exact_mod_cast hdim)
    simpa only [Real.log_pow, Nat.cast_ofNat, constructionLog] using hh

/-- Explicit joint dimension and teacher-width polynomials in the path
index; all ceilings and repeated columns are included. -/
theorem construction_resource_bounds (K k : ℕ) (hK : 1 ≤ K) (hk : 2 ≤ k)
    (hlog : 1 ≤ Real.log (k:ℝ)) :
    (k:ℝ)*Real.log (k:ℝ)^2 ≤ constructionDimension K k ∧
    (constructionDimension K k:ℝ) ≤ 20000*(K:ℝ)*(k:ℝ)*Real.log (k:ℝ)^2 ∧
    (constructionTeacherWidth K k:ℝ) ≤ 300000*(K:ℝ)*(k:ℝ)^2*Real.log (k:ℝ)^2 := by
  have hcomparison := constructionLog_comparison k hk
  have hl : 1 ≤ constructionLog k := hlog.trans hcomparison.1
  have hbase := constructionDimension_log_bounds K k hK (by omega) hl
  have hm : k ≤ logicalDim k ∧ logicalDim k ≤ 10*k := by rw [logicalDim_eq]; omega
  have hmR : (k:ℝ) ≤ logicalDim k := by exact_mod_cast hm.1
  have hmR2 : (logicalDim k:ℝ) ≤ 10*(k:ℝ) := by exact_mod_cast hm.2
  have hkR : (2:ℝ) ≤ k := by exact_mod_cast hk
  have hKR : (1:ℝ) ≤ K := by exact_mod_cast hK
  have hsq : constructionLog k^2 ≤ 25*Real.log (k:ℝ)^2 := by nlinarith [hcomparison.2]
  have hslo : Real.log (k:ℝ)^2 ≤ constructionLog k^2 := by nlinarith [hcomparison.1]
  have hd : (constructionDimension K k:ℝ) ≤ 20000*(K:ℝ)*(k:ℝ)*Real.log (k:ℝ)^2 := by
    have hh := mul_le_mul hmR2 hsq (sq_nonneg _) (by positivity : (0:ℝ)≤10*k)
    have hhh := mul_le_mul_of_nonneg_left hh (by positivity : (0:ℝ)≤80*K)
    nlinarith only [hbase.2, hhh]
  refine ⟨?_,hd,?_⟩
  · exact (mul_le_mul hmR hslo (sq_nonneg _) (Nat.cast_nonneg _)).trans hbase.1
  · have hml : (logicalDim k:ℝ)+1 ≤ 11*(k:ℝ) := by linarith
    have hunit : 1 ≤ (K:ℝ)*(k:ℝ)*Real.log (k:ℝ)^2 := by
      have hs : 1 ≤ Real.log (k:ℝ)^2 := by nlinarith
      nlinarith [mul_nonneg (by linarith : 0≤(K:ℝ)-1) (by positivity : 0≤(k:ℝ)*Real.log (k:ℝ)^2)]
    have hdl : (constructionDimension K k:ℝ)+1 ≤
        20001*(K:ℝ)*(k:ℝ)*Real.log (k:ℝ)^2 := by linarith
    have hh := mul_le_mul hml hdl (by positivity : (0:ℝ)≤(constructionDimension K k:ℝ)+1)
      (by positivity : (0:ℝ)≤11*k)
    change (((logicalDim k+1)*(constructionDimension K k+1):ℕ):ℝ) ≤ _
    push_cast at hh ⊢
    nlinarith only [hh, mul_nonneg (by positivity : (0:ℝ)≤K*k^2) (sq_nonneg (Real.log (k:ℝ)))]

end NeuralGeneralization.OnlineLowerTanh.Family
