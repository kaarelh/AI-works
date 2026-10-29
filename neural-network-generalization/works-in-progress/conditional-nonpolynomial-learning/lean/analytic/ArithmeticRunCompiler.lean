import ArithmeticLayerCompiler

/-! Iterating the actual arithmetic-layer compiler. All state spaces may vary
between stages; both finite-circuit semantics and numerical errors are tracked. -/
noncomputable section
open scoped BigOperators
namespace ConditionalNonpolynomial.AnalyticLookup
open ConditionalNonpolynomial.Analytic

variable (d : ℕ → ℕ) (L : ∀ j, ArithmeticLayer (Fin (d j)) (Fin (d (j+1))))
variable (Q : ℕ) (N : ℕ → ℕ)

def compileArithmeticRun : (h : ℕ) → CircuitMap (d 0*Fintype.card (ScalarGrid Q (N 0)))
    (d h*Fintype.card (ScalarGrid Q (N h)))
  | 0 => CircuitMap.identity _
  | h+1 => (compileArithmeticRun h).then
      (quantizedLayer (L h).coefficients (fun j => ((L h).operations j).eval) Q (N h) (N (h+1)))

def exactArithmeticRun (x : Fin (d 0) → ℝ) : (h : ℕ) → Fin (d h) → ℝ
  | 0 => x
  | h+1 => (L h).eval (exactArithmeticRun x h)

def gridArithmeticRun (a : Fin (d 0) → ScalarCode Q (N 0)) :
    (h : ℕ) → Fin (d h) → ScalarCode Q (N h)
  | 0 => a
  | h+1 => quantizedUpdate (L h).coefficients (fun j => ((L h).operations j).eval)
      Q (N h) (N (h+1)) (gridArithmeticRun a h)

@[simp] theorem compileArithmeticRun_eval (a : Fin (d 0) → ScalarCode Q (N 0)) (h : ℕ) :
    (compileArithmeticRun d L Q N h).eval (oneHotState a) =
      oneHotState (gridArithmeticRun d L Q N a h) := by
  induction h with
  | zero => simp [compileArithmeticRun,gridArithmeticRun]
  | succ h ih => simp [compileArithmeticRun,gridArithmeticRun,ih]

theorem compileArithmeticRun_depth (h : ℕ) : (compileArithmeticRun d L Q N h).depth ≤ 5*h := by
  induction h with
  | zero => simp [compileArithmeticRun]
  | succ h ih =>
    have hh := CircuitMap.depth_then (compileArithmeticRun d L Q N h)
      (quantizedLayer (L h).coefficients (fun j => ((L h).operations j).eval) Q (N h) (N (h+1)))
    have hq := quantizedLayer_depth (L h).coefficients (fun j => ((L h).operations j).eval) Q (N h) (N (h+1))
    change (compileArithmeticRun d L Q N h |>.then _).depth ≤ _
    omega

theorem compileArithmeticRun_size (B : ℕ) (hc : ∀ h j i, |(L h).coefficients j i| ≤ (B:ℝ)) (h : ℕ) :
    (compileArithmeticRun d L Q N h).size ≤
      ∑ j ∈ Finset.range h, arithmeticLayerSize (d j) (d (j+1)) Q B (N j) (N (j+1)) := by
  induction h with
  | zero => simp [compileArithmeticRun]
  | succ h ih =>
    rw [compileArithmeticRun,CircuitMap.size_then,Finset.sum_range_succ]
    exact add_le_add ih (quantizedLayer_size _ _ Q B (N h) (N (h+1)) (hc h))

def layerRadius (di B Ni : ℕ) : ℕ := di*(B+1)*(Ni+1)+1

def layerNextRange (di B Ni : ℕ) : ℕ := (layerRadius di B Ni)^2+1

def layerError (di Q B Ni : ℕ) (η : ℝ) : ℝ :=
  arithmeticModulus (layerRadius di B Ni) ((di:ℝ)*η*((B:ℝ)+Ni+η))+1/(2*(Q:ℝ))

lemma layerError_nonneg (di Q B Ni : ℕ) {η : ℝ} (hη : 0≤η) : 0≤layerError di Q B Ni η := by
  unfold layerError arithmeticModulus
  positivity

lemma layerError_precision (di Q B Ni : ℕ) {η : ℝ} (hη : 0≤η) :
    1/(2*(Q:ℝ)) ≤ layerError di Q B Ni η := by
  unfold layerError arithmeticModulus
  have hh : 0 ≤ 2*(layerRadius di B Ni:ℝ)*((di:ℝ)*η*((B:ℝ)+Ni+η)) := by positivity
  linarith [Real.sqrt_nonneg ((di:ℝ)*η*((B:ℝ)+Ni+η))]

def arithmeticRunError (B : ℕ) : ℕ → ℝ
  | 0 => 1/(2*(Q:ℝ))
  | h+1 => layerError (d h) Q B (N h) (arithmeticRunError B h)

lemma arithmeticRunError_nonneg (B h : ℕ) : 0≤arithmeticRunError d Q N B h := by
  induction h with
  | zero => simp [arithmeticRunError]
  | succ h ih => exact layerError_nonneg _ _ _ _ ih

lemma arithmeticRunError_precision (B h : ℕ) : 1/(2*(Q:ℝ))≤arithmeticRunError d Q N B h := by
  cases h with
  | zero => rfl
  | succ h => exact layerError_precision _ _ _ _ (arithmeticRunError_nonneg d Q N B h)

lemma finiteArithmeticLayer_range {di do' : ℕ} (A : ArithmeticLayer (Fin di) (Fin do'))
    (B Ni No : ℕ) (hc : ∀ j i, |A.coefficients j i| ≤ (B:ℝ))
    (x : Fin di → ℝ) (hx : ∀ i, |x i| ≤ (Ni:ℝ))
    (hNo : layerNextRange di B Ni ≤ No) (j : Fin do') : |A.eval x j| ≤ (No:ℝ) := by
  have hs := affine_absolute_bound (A.coefficients j) x B Ni (Nat.cast_nonneg _) (hc j) hx
  have hP : (1:ℝ)≤layerRadius di B Ni := by
    exact_mod_cast (show 1≤layerRadius di B Ni from Nat.le_add_left 1 _)
  have hbound : (di:ℝ)*B*Ni ≤ layerRadius di B Ni := by
    unfold layerRadius
    push_cast
    nlinarith [Nat.cast_nonneg di (α:=ℝ),Nat.cast_nonneg B (α:=ℝ),Nat.cast_nonneg Ni (α:=ℝ)]
  have ho := (A.operations j).range_bound (∑i,A.coefficients j i*x i) (layerRadius di B Ni)
    hP (hs.trans hbound)
  have hh : (layerRadius di B Ni:ℝ)^2+1 ≤ No := by exact_mod_cast hNo
  exact ho.trans hh

theorem exactArithmeticRun_range (B : ℕ) (hc : ∀ h j i, |(L h).coefficients j i| ≤ (B:ℝ))
    (hN : ∀ h, layerNextRange (d h) B (N h) ≤ N (h+1))
    (x : Fin (d 0) → ℝ) (hx : ∀i,|x i|≤(N 0:ℝ)) (h : ℕ) :
    ∀i,|exactArithmeticRun d L x h i|≤(N h:ℝ) := by
  induction h with
  | zero => exact hx
  | succ h ih =>
    exact finiteArithmeticLayer_range (L h) B (N h) (N (h+1)) (hc h)
      (exactArithmeticRun d L x h) ih (hN h)

theorem arithmeticRun_accuracy (B : ℕ) (hQ : 0<Q)
    (hc : ∀ h j i, |(L h).coefficients j i| ≤ (B:ℝ))
    (hN : ∀ h, layerNextRange (d h) B (N h) ≤ N (h+1))
    (x : Fin (d 0) → ℝ) (hx : ∀i,|x i|≤(N 0:ℝ)) (h : ℕ) (j : Fin (d h)) :
    |exactArithmeticRun d L x h j - scalarDecode Q (N h)
      (gridArithmeticRun d L Q N (fun i=>scalarEncode Q (N 0) (x i)) h j)| ≤
      arithmeticRunError d Q N B h := by
  induction h with
  | zero => exact scalarEncode_error Q (N 0) hQ (x j) (hx j)
  | succ h ih =>
    exact instructionLayer_accuracy (L h).coefficients (L h).operations Q B (N h) (N (h+1)) hQ
      (hc h) (exactArithmeticRun d L x h) (exactArithmeticRun_range d L N B hc hN x hx h)
      (gridArithmeticRun d L Q N (fun i=>scalarEncode Q (N 0) (x i)) h)
      (arithmeticRunError d Q N B h) (arithmeticRunError_nonneg d Q N B h)
      (arithmeticRunError_precision d Q N B h) ih (hN h) j

#print axioms compileArithmeticRun_eval
#print axioms compileArithmeticRun_depth
#print axioms arithmeticRun_accuracy
end ConditionalNonpolynomial.AnalyticLookup
