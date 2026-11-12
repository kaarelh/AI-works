import NeuralGeneralization.BatchTwoContinuousSphereLaw
import NeuralGeneralization.BatchTwoContinuousStatements

/-! Explicit polynomial budgets for the sphere score-to-sign example. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory
namespace NeuralGeneralization.BatchTwoContinuousSphere
open BatchTwoContinuous

def scoreTolerance (n : ℕ) (ε : ℝ) := ε/(12*Real.sqrt ((n:ℝ)+1))
def scoreAccuracy (n : ℕ) (ε : ℝ) := ε/(6*Real.sqrt ((n:ℝ)+1))
def sphereResource (n : ℕ) (ε : ℝ) := 1+((n:ℝ)+1)+1/ε

/-- A polynomial in dimension and inverse accuracy, with logarithmic
confidence dependence. Neither the learner width nor scale occurs. -/
def sphereSampleBudget (A : ℝ) (m n : ℕ) (ε δ : ℝ) :=
  (12/ε)*(A*30^m*(sphereResource n ε)^(2*m)+13*sphereResource n ε+Real.log (1/δ))

theorem score_parameters (n : ℕ) {ε : ℝ} (hε : 0<ε) (hε1 : ε<1) :
    0<scoreTolerance n ε ∧ scoreTolerance n ε<scoreAccuracy n ε ∧
    scoreTolerance n ε<1 ∧
    inverseGap (scoreTolerance n ε) (scoreAccuracy n ε)=1/scoreTolerance n ε := by
  have hr : 1≤Real.sqrt ((n:ℝ)+1) := Real.one_le_sqrt.mpr (by have hn := Nat.cast_nonneg (α := ℝ) n; linarith)
  have hp : 0<scoreTolerance n ε := by unfold scoreTolerance; positivity
  have he : scoreAccuracy n ε=2*scoreTolerance n ε := by
    unfold scoreAccuracy scoreTolerance
    field_simp
    ring
  have hb : scoreTolerance n ε<1 := by
    unfold scoreTolerance
    apply (div_lt_one (by positivity)).mpr
    linarith
  refine ⟨hp, by rw [he]; linarith, hb, ?_⟩
  unfold inverseGap
  rw [he, show 2*scoreTolerance n ε-scoreTolerance n ε=scoreTolerance n ε by ring,
    min_eq_right hb.le]

theorem sphere_resource_bounds (n : ℕ) {ε : ℝ} (hε : 0<ε) (hε1 : ε<1) :
    1≤sphereResource n ε ∧ 1/scoreTolerance n ε≤12*(sphereResource n ε)^2 := by
  let R := sphereResource n ε
  have hv : 0<1/ε := by positivity
  have hR : 1≤R := by dsimp [R, sphereResource]; nlinarith [Nat.cast_nonneg (α := ℝ) n]
  have hd : (n:ℝ)+1≤R := by dsimp [R, sphereResource]; linarith
  have hi : 1/ε≤R := by dsimp [R, sphereResource]; nlinarith [Nat.cast_nonneg (α := ℝ) n]
  have hs : Real.sqrt ((n:ℝ)+1)≤(n:ℝ)+1 :=
    Real.sqrt_le_self_iff.mpr (Or.inr (by have hn := Nat.cast_nonneg (α := ℝ) n; linarith))
  have hmul : Real.sqrt ((n:ℝ)+1)*(1/ε)≤R*R :=
    mul_le_mul (hs.trans hd) hi hv.le (by linarith)
  have he : 1/scoreTolerance n ε=12*(Real.sqrt ((n:ℝ)+1)*(1/ε)) := by
    unfold scoreTolerance
    field_simp
  exact ⟨hR, by rw [he]; nlinarith⟩

theorem sphere_envelope_bound {A : ℝ} (hA : 0≤A) (m n : ℕ)
    {ε v t : ℝ} (hε : 0<ε) (hε1 : ε<1) (hv : 0≤v) (ht : 0≤t)
    (hvb : v≤12*(sphereResource n ε)^2) (htb : t≤2*(sphereResource n ε)^2) :
    regressionEnvelope A m (n+1) 1 1
      (inverseGap (scoreTolerance n ε) (scoreAccuracy n ε)) v t ≤
      A*30^m*(sphereResource n ε)^(2*m) := by
  obtain ⟨hρ, _, _, hu⟩ := score_parameters n hε hε1
  obtain ⟨hR, hub⟩ := sphere_resource_bounds n hε hε1
  have hd : (n:ℝ)+1≤sphereResource n ε := by unfold sphereResource; nlinarith [Nat.cast_nonneg (α := ℝ) n, one_div_pos.mpr hε]
  have hRR : sphereResource n ε≤(sphereResource n ε)^2 := by nlinarith
  have hbase : 1+(↑(n+1):ℝ)+(↑(1:ℕ):ℝ)+1+
      inverseGap (scoreTolerance n ε) (scoreAccuracy n ε)+v+t≤30*(sphereResource n ε)^2 := by
    rw [hu]
    push_cast
    nlinarith
  have hbase0 : 0≤1+(↑(n+1):ℝ)+(↑(1:ℕ):ℝ)+1+
      inverseGap (scoreTolerance n ε) (scoreAccuracy n ε)+v+t := by rw [hu]; positivity
  unfold regressionEnvelope
  calc
    _ ≤ A*(30*(sphereResource n ε)^2)^m := mul_le_mul_of_nonneg_left
      (pow_le_pow_left₀ hbase0 hbase m) hA
    _ = _ := by rw [mul_pow, ← pow_mul, mul_assoc]

theorem sphere_finite_budget {A : ℝ} (hA : 0≤A) (m n : ℕ)
    {ε δ : ℝ} (hε : 0<ε) (hε1 : ε<1) (hδ : 0<δ) :
    (6/(ε/2))*(regressionEnvelope A m (n+1) 1 1
      (inverseGap (scoreTolerance n ε) (scoreAccuracy n ε))
      (logInverseTolerance (scoreTolerance n ε)) (Real.log (1/(ε/2)))+
        Real.log (6/((ε/2)*δ))) ≤ sphereSampleBudget A m n ε δ := by
  obtain ⟨hρ, _, hρ1, _⟩ := score_parameters n hε hε1
  obtain ⟨hR, hub⟩ := sphere_resource_bounds n hε hε1
  have hi : 1/ε≤sphereResource n ε := by unfold sphereResource; nlinarith [Nat.cast_nonneg (α := ℝ) n, one_div_pos.mpr hε]
  have hRR : sphereResource n ε≤(sphereResource n ε)^2 := by nlinarith
  have hlogρ : logInverseTolerance (scoreTolerance n ε)=Real.log (1/scoreTolerance n ε) := by
    unfold logInverseTolerance
    rw [min_eq_right hρ1.le]
  have hεinv : 1≤1/(ε/2) := (one_le_div (by positivity)).mpr (by linarith)
  have hρinv : 1≤1/scoreTolerance n ε := (one_le_div hρ).mpr hρ1.le
  have he := sphere_envelope_bound hA m n hε hε1
    (v := logInverseTolerance (scoreTolerance n ε)) (t := Real.log (1/(ε/2)))
    (by rw [hlogρ]; exact Real.log_nonneg hρinv) (Real.log_nonneg hεinv)
    (by rw [hlogρ]; exact (Real.log_le_self (by positivity)).trans hub)
    (by have h := Real.log_le_self (by positivity : 0≤1/(ε/2))
        have hh : 1/(ε/2)=2*(1/ε) := by field_simp
        rw [hh] at h ⊢
        nlinarith)
  have hlog : Real.log (6/((ε/2)*δ)) ≤ 13*sphereResource n ε+Real.log (1/δ) := by
    have hh : 6/((ε/2)*δ)=12*(1/ε)*(1/δ) := by field_simp; ring
    rw [hh, Real.log_mul (by positivity) (by positivity),
      Real.log_mul (by norm_num) (by positivity)]
    have h12 := Real.log_le_self (by norm_num : (0:ℝ)≤12)
    have hi' := Real.log_le_self (by positivity : 0≤1/ε)
    nlinarith
  have hc : 6/(ε/2)=12/ε := by field_simp; norm_num
  rw [hc]
  unfold sphereSampleBudget
  exact mul_le_mul_of_nonneg_left (by linarith) (by positivity)

theorem sphere_strong_budget {A : ℝ} (hA : 0≤A) (m n : ℕ)
    {ε δ : ℝ} (hε : 0<ε) (hε1 : ε<1) :
    (6/(ε/2))*(regressionEnvelope A m (n+1) 1 1
      (inverseGap (scoreTolerance n ε) (scoreAccuracy n ε)) 0 0+
        Real.log (1/δ)) ≤ sphereSampleBudget A m n ε δ := by
  have he := sphere_envelope_bound hA m n hε hε1 (v := 0) (t := 0)
    (by norm_num) (by norm_num) (by positivity) (by positivity)
  have hR := (sphere_resource_bounds n hε hε1).1
  have hc : 6/(ε/2)=12/ε := by field_simp; norm_num
  rw [hc]
  unfold sphereSampleBudget
  exact mul_le_mul_of_nonneg_left (by linarith) (by positivity)

end NeuralGeneralization.BatchTwoContinuousSphere
