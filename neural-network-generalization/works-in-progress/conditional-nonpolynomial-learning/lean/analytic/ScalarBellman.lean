import ScalarVarianceDrift

noncomputable section
set_option maxHeartbeats 1000000
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators ENNReal NNReal
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization

/-- Standardized controls: Q is measured relative to the fixed N(0,1); the
preactivation is sqrt(q) z. This parametrizes arbitrary finite-entropy scalar
controls at positive variance. -/
def scalarTransition (q : ℝ) (Q : Measure ℝ) : ℝ := ∫ z, varianceTest q z ∂Q

lemma varianceTest_mono {a b : ℝ} (_ha : 0≤a) (hab : a≤b) (z:ℝ) :
    varianceTest a z ≤ varianceTest b z := by
  have hs : Real.sqrt a ≤ Real.sqrt b := Real.sqrt_le_sqrt hab
  have ht : Real.tanh (Real.sqrt a*|z|) ≤ Real.tanh (Real.sqrt b*|z|) :=
    BatchTwoNonGaussian.tanh_monotone (mul_le_mul_of_nonneg_right hs (abs_nonneg z))
  have hta : 0≤Real.tanh (Real.sqrt a*|z|) := by
    simpa only [Real.tanh_zero] using BatchTwoNonGaussian.tanh_monotone
      (mul_nonneg (Real.sqrt_nonneg a) (abs_nonneg z))
  have hsq := pow_le_pow_left₀ hta ht 2
  unfold varianceTest
  rcases le_total 0 z with hz | hz
  · simpa only [abs_of_nonneg hz] using hsq
  · simpa only [abs_of_nonpos hz,mul_neg,Real.tanh_neg,neg_sq] using hsq

lemma scalarTransition_mono (Q : Measure ℝ) [IsProbabilityMeasure Q]
    {a b : ℝ} (ha : 0≤a) (hab : a≤b) :
    scalarTransition a Q ≤ scalarTransition b Q :=
  integral_mono (varianceTest_integrable Q a) (varianceTest_integrable Q b)
    (varianceTest_mono ha hab)

/-- A literal finite scalar path, including the zero-layer readout option.
Positivity is part of the valid state domain, not an assumed cost estimate. -/
inductive ScalarPath : ℝ → Type
  | stop {q : ℝ} (hq : 0<q) : ScalarPath q
  | step {q : ℝ} (hq : 0<q) (Q : Measure ℝ)
      (hprob : IsProbabilityMeasure Q)
      (hfinite : klDiv Q (gaussianReal 0 1) ≠ ∞)
      (tail : ScalarPath (scalarTransition q Q)) : ScalarPath q

def ScalarPath.cost : {q : ℝ} → ScalarPath q → ℝ
  | q, .stop _ => 1/(8*q)
  | _, .step _ Q _ _ tail => (klDiv Q (gaussianReal 0 1)).toReal+tail.cost

lemma ScalarPath.start_pos {q : ℝ} (p : ScalarPath q) : 0<q := by
  cases p <;> assumption

lemma ScalarPath.cost_nonneg {q : ℝ} (p : ScalarPath q) : 0≤p.cost := by
  induction p with
  | stop hq => exact div_nonneg (by norm_num) (by positivity)
  | step hq Q hprob hfinite tail ih => exact add_nonneg ENNReal.toReal_nonneg ih

/-- A larger initial variance can replay the same standardized controls.
Every state increases; all entropy charges remain identical. -/
theorem ScalarPath.lift {a : ℝ} (p : ScalarPath a) {b : ℝ} (hab : a≤b) :
    ∃ p' : ScalarPath b, p'.cost≤p.cost := by
  induction p generalizing b with
  | stop hq =>
    refine ⟨.stop (hq.trans_le hab), ?_⟩
    simp only [ScalarPath.cost]
    exact one_div_le_one_div_of_le (by positivity) (by linarith)
  | step hq Q hprob hfinite tail ih =>
    letI := hprob
    have hm := scalarTransition_mono Q hq.le hab
    obtain ⟨tail',htail⟩ := ih hm
    refine ⟨.step (hq.trans_le hab) Q hprob hfinite tail', ?_⟩
    change (klDiv Q (gaussianReal 0 1)).toReal+tail'.cost ≤
      (klDiv Q (gaussianReal 0 1)).toReal+tail.cost
    linarith

def scalarCosts (q : ℝ) : Set ℝ := {a | ∃ p : ScalarPath q, a=p.cost}

def scalarValue (q : ℝ) : ℝ := sInf (scalarCosts q)

lemma scalarCosts_nonempty {q : ℝ} (hq : 0<q) : (scalarCosts q).Nonempty :=
  ⟨(ScalarPath.stop hq).cost, .stop hq, rfl⟩

lemma scalarCosts_bddBelow (q : ℝ) : BddBelow (scalarCosts q) := by
  refine ⟨0,?_⟩
  rintro a ⟨p,rfl⟩
  exact p.cost_nonneg

lemma scalarValue_nonneg (q : ℝ) : 0≤scalarValue q := by
  unfold scalarValue
  apply Real.sInf_nonneg
  rintro a ⟨p,rfl⟩
  exact p.cost_nonneg

lemma scalarValue_le_path {q : ℝ} (p : ScalarPath q) : scalarValue q≤p.cost :=
  csInf_le (scalarCosts_bddBelow q) ⟨p,rfl⟩

lemma scalarValue_le_readout {q : ℝ} (hq : 0<q) : scalarValue q≤1/(8*q) :=
  scalarValue_le_path (.stop hq)

/-- Genuine Bellman-value monotonicity for all finite-entropy scalar controls. -/
theorem scalarValue_antitone {a b : ℝ} (ha : 0<a) (hab : a≤b) :
    scalarValue b≤scalarValue a := by
  apply le_csInf (scalarCosts_nonempty ha)
  rintro r ⟨p,rfl⟩
  obtain ⟨p',hp'⟩ := p.lift hab
  exact (scalarValue_le_path p').trans hp'

/-- One-step Bellman inequality for the literal finite-path infimum. -/
theorem scalarValue_bellman {q : ℝ} (hq : 0<q) (Q : Measure ℝ)
    (hprob : IsProbabilityMeasure Q)
    (hfinite : klDiv Q (gaussianReal 0 1) ≠ ∞)
    (hnext : 0<scalarTransition q Q) :
    scalarValue q ≤ (klDiv Q (gaussianReal 0 1)).toReal+
      scalarValue (scalarTransition q Q) := by
  have hh : scalarValue q-(klDiv Q (gaussianReal 0 1)).toReal ≤
      scalarValue (scalarTransition q Q) := by
    apply le_csInf (scalarCosts_nonempty hnext)
    rintro r ⟨tail,rfl⟩
    have h := scalarValue_le_path (.step hq Q hprob hfinite tail)
    change scalarValue q ≤ (klDiv Q (gaussianReal 0 1)).toReal+tail.cost at h
    linarith
  linarith

/-- Summing the actual Bellman inequalities along a finite controlled prefix. -/
theorem scalarValue_prefix (m : ℕ) (q : ℕ → ℝ) (Q : ℕ → Measure ℝ)
    (hq : ∀ j≤m, 0<q j)
    (hprob : ∀ j<m, IsProbabilityMeasure (Q j))
    (hfinite : ∀ j<m, klDiv (Q j) (gaussianReal 0 1) ≠ ∞)
    (htrans : ∀ j<m, scalarTransition (q j) (Q j)=q (j+1)) :
    scalarValue (q 0) ≤
      (∑ j ∈ Finset.range m, (klDiv (Q j) (gaussianReal 0 1)).toReal)+scalarValue (q m) := by
  induction m with
  | zero => simp
  | succ m ih =>
    have hi := ih (fun j hj => hq j (Nat.le_succ_of_le hj))
      (fun j hj => hprob j (Nat.lt_succ_of_lt hj))
      (fun j hj => hfinite j (Nat.lt_succ_of_lt hj))
      (fun j hj => htrans j (Nat.lt_succ_of_lt hj))
    have hnext : 0<scalarTransition (q m) (Q m) := by
      rw [htrans m (Nat.lt_succ_self m)]
      exact hq (m+1) le_rfl
    have hs := scalarValue_bellman (hq m (Nat.le_succ m)) (Q m)
      (hprob m (Nat.lt_succ_self m)) (hfinite m (Nat.lt_succ_self m)) hnext
    rw [htrans m (Nat.lt_succ_self m)] at hs
    rw [Finset.sum_range_succ]
    linarith

/-- The candidate critical baseline is defined in ENNReal until its finiteness
has been established. No finite baseline/linear bridge is assumed or asserted. -/
def scalarBaseline : ℝ≥0∞ := ⨆ (q : ℝ) (_ : 0<q), ENNReal.ofReal (scalarValue q)

#print axioms scalarValue_antitone
#print axioms scalarValue_bellman
end ConditionalNonpolynomial.Analytic
