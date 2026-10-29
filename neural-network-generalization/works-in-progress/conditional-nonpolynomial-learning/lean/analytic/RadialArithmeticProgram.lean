import CanonicalEvaluator

/-! A six-layer arithmetic implementation of radial clipping. It uses only
bounded affine forms, squares and the compiled inverse-root clipping lookup. -/
noncomputable section
open scoped BigOperators
namespace ConditionalNonpolynomial.AnalyticLookup
open ConditionalNonpolynomial.Analytic

 def radialNormLayer (d : ℕ) : ArithmeticLayer (Fin d⊕Fin d) (Fin d⊕Unit) where
  coefficients := fun j i=>match j,i with
    | .inl j,_ =>selectCoefficient (.inl j) i
    | .inr _,.inl _=>0
    | .inr _,.inr _=>1
  operations := fun _=>.identity

 def radialFactorLayer (d : ℕ) (s : ℝ) : ArithmeticLayer (Fin d⊕Unit) (Fin d⊕Unit) where
  coefficients := fun j i=>match j with
    | .inl j=>selectCoefficient (.inl j) i
    | .inr _=>(s⁻¹)^2*selectCoefficient (.inr ()) i
  operations := Sum.elim (fun _=>.identity) (fun _=>.inverseRootClip)

 def radialProductInput (d : ℕ) : ArithmeticLayer (Fin d⊕Unit) (Fin d⊕Fin d) where
  coefficients := fun j i=>match j,i with
    | .inl j,.inl i=>selectCoefficient j i
    | .inr j,.inl i=>selectCoefficient j i
    | .inl _,.inr _=>1
    | .inr _,.inr _=>-1
  operations := fun _=>.identity

 def squareArithmeticLayer (ι : Type*) [DecidableEq ι] : ArithmeticLayer ι ι where
  coefficients := selectCoefficient
  operations := fun _=>.square

 def radialProductOutput (d : ℕ) : ArithmeticLayer (Fin d⊕Fin d) (Fin d) where
  coefficients := fun j i=>match i with
    | .inl i=>(1/4:ℝ)*selectCoefficient j i
    | .inr i=>-(1/4:ℝ)*selectCoefficient j i
  operations := fun _=>.identity

 def radialArithmeticProgram {d : ℕ} (s : ℝ) (x : Fin d→ℝ) : Fin d→ℝ :=
  (radialProductOutput d).eval ((squareArithmeticLayer (Fin d⊕Fin d)).eval
    ((radialProductInput d).eval ((radialFactorLayer d s).eval
      ((radialNormLayer d).eval ((ridgeSquareLayer d).eval x)))))

@[simp] lemma radialNormLayer_left {d : ℕ} (x : (Fin d⊕Fin d)→ℝ) (j : Fin d) :
    (radialNormLayer d).eval x (.inl j)=x (.inl j) := by
  simp [ArithmeticLayer.eval,radialNormLayer,ScalarInstruction.eval]

@[simp] lemma radialNormLayer_right {d : ℕ} (x : (Fin d⊕Fin d)→ℝ) :
    (radialNormLayer d).eval x (.inr ())=∑i,x (.inr i) := by
  simp [ArithmeticLayer.eval,radialNormLayer,ScalarInstruction.eval,Fintype.sum_sum_type]

@[simp] lemma radialFactorLayer_left {d : ℕ} (s : ℝ) (x : (Fin d⊕Unit)→ℝ) (j : Fin d) :
    (radialFactorLayer d s).eval x (.inl j)=x (.inl j) := by
  simp [ArithmeticLayer.eval,radialFactorLayer,ScalarInstruction.eval]

@[simp] lemma radialFactorLayer_right {d : ℕ} (s : ℝ) (x : (Fin d⊕Unit)→ℝ) :
    (radialFactorLayer d s).eval x (.inr ())=inverseRootClip ((s⁻¹)^2*x (.inr ())) := by
  simp [ArithmeticLayer.eval,radialFactorLayer,ScalarInstruction.eval,selectCoefficient]

@[simp] lemma radialProductInput_left {d : ℕ} (x : (Fin d⊕Unit)→ℝ) (j : Fin d) :
    (radialProductInput d).eval x (.inl j)=x (.inl j)+x (.inr ()) := by
  simp [ArithmeticLayer.eval,radialProductInput,ScalarInstruction.eval,Fintype.sum_sum_type,
    selectCoefficient]

@[simp] lemma radialProductInput_right {d : ℕ} (x : (Fin d⊕Unit)→ℝ) (j : Fin d) :
    (radialProductInput d).eval x (.inr j)=x (.inl j)-x (.inr ()) := by
  simp [ArithmeticLayer.eval,radialProductInput,ScalarInstruction.eval,Fintype.sum_sum_type,
    selectCoefficient,sub_eq_add_neg]

@[simp] lemma squareArithmeticLayer_eval {ι : Type*} [Fintype ι] [DecidableEq ι]
    (x : ι→ℝ) (j : ι) : (squareArithmeticLayer ι).eval x j=(x j)^2 := by
  simp [ArithmeticLayer.eval,squareArithmeticLayer,ScalarInstruction.eval]

@[simp] lemma radialProductOutput_eval {d : ℕ} (x : (Fin d⊕Fin d)→ℝ) (j : Fin d) :
    (radialProductOutput d).eval x j=(x (.inl j)-x (.inr j))/4 := by
  simp [ArithmeticLayer.eval,radialProductOutput,ScalarInstruction.eval,Fintype.sum_sum_type,
    selectCoefficient]
  ring

theorem radialArithmeticProgram_eval {d : ℕ} (s : ℝ) (x : Fin d→ℝ) (j : Fin d) :
    radialArithmeticProgram s x j=x j*inverseRootClip ((∑i,(x i)^2)/s^2) := by
  simp only [radialArithmeticProgram,radialProductOutput_eval,squareArithmeticLayer_eval,
    radialProductInput_left,radialProductInput_right,radialFactorLayer_left,
    radialFactorLayer_right,radialNormLayer_left,radialNormLayer_right,
    ridgeSquareLayer_eval_left,ridgeSquareLayer_eval_right]
  have he : (s⁻¹)^2*(∑i,(x i)^2)=(∑i,(x i)^2)/s^2 := by ring
  rw [he]
  ring

lemma inverseRootClip_norm_ratio {s r : ℝ} (hs : 0<s) (hr : 0≤r) :
    inverseRootClip (r^2/s^2)=s/max s r := by
  have hsq : Real.sqrt (max 1 (r^2/s^2))=max s r/s := by
    have hp : 0≤max s r/s := div_nonneg (hr.trans (le_max_right _ _)) hs.le
    apply (sq_eq_sq₀ (Real.sqrt_nonneg _) hp).mp
    rw [Real.sq_sqrt (show 0≤max 1 (r^2/s^2) by positivity)]
    rcases le_total r s with hrs|hsr
    · rw [max_eq_left hrs,div_self hs.ne']
      have hdiv : r^2/s^2≤1 := (div_le_one (sq_pos_of_pos hs)).mpr (by nlinarith)
      rw [max_eq_left hdiv]
      norm_num
    · rw [max_eq_right hsr]
      have hdiv : 1≤r^2/s^2 := (le_div_iff₀ (sq_pos_of_pos hs)).mpr (by nlinarith)
      rw [max_eq_right hdiv,div_pow]
  rw [inverseRootClip,hsq,inv_div]

/-- The arithmetic program equals the genuine radial clipping map. -/
theorem radialArithmeticProgram_is_projection {d : ℕ} (s : ℝ) (hs : 0<s)
    (x : EuclideanSpace ℝ (Fin d)) (j : Fin d) :
    radialArithmeticProgram s (fun i=>x i) j=(s/max s ‖x‖)*x j := by
  rw [radialArithmeticProgram_eval,←EuclideanSpace.real_norm_sq_eq,
    inverseRootClip_norm_ratio hs (norm_nonneg x)]
  ring

#print axioms radialArithmeticProgram_is_projection
end ConditionalNonpolynomial.AnalyticLookup
