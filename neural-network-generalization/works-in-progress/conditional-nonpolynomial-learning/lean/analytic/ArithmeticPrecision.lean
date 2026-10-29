import ArithmeticRunCompiler

/-! Explicit inverse-polynomial precision for a fixed number of arithmetic
layers, including square roots. Five layers require only a 32nd-power mesh. -/
noncomputable section
namespace ConditionalNonpolynomial.AnalyticLookup
open ConditionalNonpolynomial.Analytic

def layerAmplification (di B Ni : ℕ) : ℕ :=
  let M := di*(B+Ni+1)
  2*layerRadius di B Ni*M+M+2

lemma layerError_sqrt_bound (di Q B Ni : ℕ) {η : ℝ}
    (hη : 0≤η) (hηone : η≤1) (hprecision : 1/(2*(Q:ℝ))≤η) :
    layerError di Q B Ni η ≤ (layerAmplification di B Ni:ℝ)*Real.sqrt η := by
  let M : ℝ := (di:ℝ)*((B:ℝ)+Ni+1)
  let u : ℝ := (di:ℝ)*η*((B:ℝ)+Ni+η)
  have hM : 0≤M := by dsimp [M]; positivity
  have hu : 0≤u := by dsimp [u]; positivity
  have huM : u≤M*η := by
    dsimp [u,M]
    have hh := mul_le_mul_of_nonneg_left hηone (mul_nonneg (Nat.cast_nonneg di) hη)
    nlinarith
  have hs := Real.sq_sqrt hη
  have hηroot : η≤Real.sqrt η := by nlinarith [Real.sqrt_nonneg η]
  have hsqrt : Real.sqrt u≤(M+1)*Real.sqrt η := by
    apply (Real.sqrt_le_iff).mpr
    constructor
    · positivity
    · have hMm : M≤(M+1)^2 := by nlinarith
      have hh := mul_le_mul_of_nonneg_right hMm hη
      nlinarith
  have hlin : 2*(layerRadius di B Ni:ℝ)*u ≤
      2*(layerRadius di B Ni:ℝ)*M*Real.sqrt η := by
    have hh := huM.trans (mul_le_mul_of_nonneg_left hηroot hM)
    simpa only [mul_assoc] using mul_le_mul_of_nonneg_left hh
      (by positivity : 0≤2*(layerRadius di B Ni:ℝ))
  have he : layerError di Q B Ni η =
      2*(layerRadius di B Ni:ℝ)*u+Real.sqrt u+1/(2*(Q:ℝ)) := rfl
  rw [he]
  unfold layerAmplification
  push_cast
  dsimp [M] at hsqrt hlin
  nlinarith

def precisionBudget (K ε : ℝ) : ℕ → ℝ
  | 0 => ε
  | h+1 => precisionBudget K ((ε/K)^2) h

lemma precisionBudget_nonneg {K ε : ℝ} (hε : 0≤ε) (h : ℕ) : 0≤precisionBudget K ε h := by
  induction h generalizing ε with
  | zero => exact hε
  | succ h ih => exact ih (sq_nonneg _)

lemma precisionBudget_le {K ε : ℝ} (hK : 1≤K) (hε : 0≤ε) (hεone : ε≤1) (h : ℕ) :
    precisionBudget K ε h≤ε := by
  induction h generalizing ε with
  | zero => rfl
  | succ h ih =>
    have hKpos : 0<K := by linarith
    have hdiv : 0≤ε/K := div_nonneg hε hKpos.le
    have hdivle : ε/K≤ε := (div_le_iff₀ hKpos).mpr (by nlinarith)
    have hsquare : (ε/K)^2≤ε := by nlinarith
    exact (ih (sq_nonneg _) (hsquare.trans hεone)).trans hsquare

lemma precisionBudget_five (K ε : ℝ) : precisionBudget K ε 5=ε^32/K^62 := by
  simp only [precisionBudget]
  ring

lemma sqrt_scaled_square {K ε : ℝ} (hK : 0<K) (hε : 0≤ε) :
    K*Real.sqrt ((ε/K)^2)=ε := by
  rw [Real.sqrt_sq (div_nonneg hε hK.le)]
  field_simp

/-- Actual recursively propagated layer error is at most ε under the explicit
mesh budget. The exponent depends only on the number of arithmetic layers. -/
theorem arithmeticRunError_precision_bound (d : ℕ→ℕ) (Q B : ℕ) (N : ℕ→ℕ)
    {K ε : ℝ} (hK : 1≤K) (hε : 0≤ε) (hεone : ε≤1) (h : ℕ)
    (hamp : ∀j<h,(layerAmplification (d j) B (N j):ℝ)≤K)
    (hprec : 1/(2*(Q:ℝ))≤precisionBudget K ε h) :
    arithmeticRunError d Q N B h≤ε := by
  induction h generalizing ε with
  | zero => exact hprec
  | succ h ih =>
    have hKpos : 0<K := by linarith
    have hs : 0≤(ε/K)^2 := sq_nonneg _
    have hdiv : 0≤ε/K := div_nonneg hε hKpos.le
    have hdivle : ε/K≤ε := (div_le_iff₀ hKpos).mpr (by nlinarith)
    have hsle : (ε/K)^2≤1 := by nlinarith
    have hprev := ih hs hsle (fun j hj=>hamp j (by omega)) hprec
    have he0 := arithmeticRunError_nonneg d Q N B h
    have he1 := hprev.trans hsle
    have hh := layerError_sqrt_bound (d h) Q B (N h) he0 he1
      (arithmeticRunError_precision d Q N B h)
    change layerError (d h) Q B (N h) (arithmeticRunError d Q N B h)≤ε
    calc
      _ ≤ (layerAmplification (d h) B (N h):ℝ)*Real.sqrt (arithmeticRunError d Q N B h) := hh
      _ ≤ K*Real.sqrt ((ε/K)^2) := mul_le_mul (hamp h (by omega))
        (Real.sqrt_le_sqrt hprev) (Real.sqrt_nonneg _) (by linarith)
      _ = ε := sqrt_scaled_square hKpos hε

theorem fiveLayer_polynomial_precision (d : ℕ→ℕ) (Q B : ℕ) (N : ℕ→ℕ)
    {K ε : ℝ} (hK : 1≤K) (hε : 0<ε) (hεone : ε≤1)
    (hamp : ∀j<5,(layerAmplification (d j) B (N j):ℝ)≤K)
    (hQ : K^62≤2*(Q:ℝ)*ε^32) :
    arithmeticRunError d Q N B 5≤ε := by
  apply arithmeticRunError_precision_bound d Q B N hK hε.le hεone 5 hamp
  rw [precisionBudget_five]
  have hKpos : 0<K := by linarith
  have hQpos : 0<(Q:ℝ) := by
    have hp : 0<K^62 := pow_pos hKpos _
    by_contra hn
    have hnon : (Q:ℝ)≤0 := le_of_not_gt hn
    have hmul := mul_nonpos_of_nonpos_of_nonneg (by linarith : 2*(Q:ℝ)≤0) (pow_nonneg hε.le 32)
    linarith
  apply (div_le_div_iff₀ (by positivity : 0<2*(Q:ℝ)) (pow_pos hKpos 62)).mpr
  nlinarith

#print axioms fiveLayer_polynomial_precision
end ConditionalNonpolynomial.AnalyticLookup
