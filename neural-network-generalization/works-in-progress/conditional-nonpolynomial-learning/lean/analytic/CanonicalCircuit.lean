import ArithmeticReindex

/-! A concrete depth-25 threshold circuit evaluating the five arithmetic
layers of the selected-node canonical-map approximation. -/
noncomputable section
open scoped BigOperators
namespace ConditionalNonpolynomial.AnalyticLookup
open ConditionalNonpolynomial.Analytic

 def canonicalCoordinates (d n m : ℕ) : ℕ → Type
  | 0 => Fin d
  | 1 => Fin n
  | 2 => Fin n ⊕ Fin n
  | 3 => Fin m ⊕ Unit
  | 4 => Fin m ⊕ (Fin m ⊕ Unit)
  | _ => Fin m ⊕ Unit

instance canonicalCoordinates_fintype (d n m h : ℕ) : Fintype (canonicalCoordinates d n m h) := by
  unfold canonicalCoordinates
  split <;> infer_instance

instance canonicalCoordinates_decidableEq (d n m h : ℕ) : DecidableEq (canonicalCoordinates d n m h) := by
  unfold canonicalCoordinates
  split <;> infer_instance

def identityArithmeticLayer (ι : Type*) [DecidableEq ι] : ArithmeticLayer ι ι where
  coefficients := selectCoefficient
  operations := fun _=>.identity

def canonicalLayers {d n m : ℕ} (w : Fin n → Fin d → ℝ) (scale : Fin n → ℝ)
    (A : Fin m → Fin n → ℝ) (b : Fin n → ℝ) :
    (h : ℕ) → ArithmeticLayer (canonicalCoordinates d n m h) (canonicalCoordinates d n m (h+1))
  | 0 => ridgeArithmeticLayer w scale
  | 1 => ridgeSquareLayer n
  | 2 => projectionArithmeticLayer A b
  | 3 => projectionSquareLayer m
  | 4 => completionArithmeticLayer m
  | h+5 => identityArithmeticLayer (Fin m ⊕ Unit)

@[simp] theorem canonicalLayers_exact {d n m : ℕ} (w : Fin n → Fin d → ℝ)
    (scale : Fin n → ℝ) (A : Fin m → Fin n → ℝ) (b : Fin n → ℝ) (x : Fin d → ℝ) :
    finiteExactRun (canonicalCoordinates d n m) (canonicalLayers w scale A b) x 5 =
      canonicalArithmeticProgram w scale A b x := rfl

lemma selectCoefficient_bound {ι : Type*} [DecidableEq ι] (i j : ι) :
    |selectCoefficient i j|≤1 := by unfold selectCoefficient; split <;> norm_num

theorem canonicalLayers_coefficients {d n m : ℕ} (w : Fin n → Fin d → ℝ)
    (scale : Fin n → ℝ) (A : Fin m → Fin n → ℝ) (b : Fin n → ℝ)
    (B : ℕ) (hB : 1≤B) (hw : ∀j i,|w j i|≤(B:ℝ))
    (hA : ∀j i,|A j i|≤(B:ℝ)) (hb : ∀i,|b i|≤(B:ℝ)) :
    ∀ h j i, |((canonicalLayers w scale A b) h).coefficients j i| ≤ (B:ℝ) := by
  have hBreal : (1:ℝ)≤B := by exact_mod_cast hB
  intro h
  match h with
  | 0 => exact hw
  | 1 => intro j i; exact (selectCoefficient_bound _ _).trans hBreal
  | 2 =>
    rintro (j | ⟨⟩) (i | i)
    · exact hA j i
    · exact le_trans (by norm_num : |(0:ℝ)|≤1) hBreal
    · exact le_trans (by norm_num : |(0:ℝ)|≤1) hBreal
    · exact hb i
  | 3 => intro j i; exact (selectCoefficient_bound _ _).trans hBreal
  | 4 =>
    rintro (j | ⟨⟩) i
    · exact (selectCoefficient_bound _ _).trans hBreal
    · rcases i with i | (i | ⟨⟩) <;>
        exact le_trans (by norm_num [canonicalLayers,completionArithmeticLayer]) hBreal
  | h+5 => intro j i; exact (selectCoefficient_bound _ _).trans hBreal

def canonicalCircuit {d n m : ℕ} (w : Fin n → Fin d → ℝ) (scale : Fin n → ℝ)
    (A : Fin m → Fin n → ℝ) (b : Fin n → ℝ) (Q : ℕ) (N : ℕ → ℕ) :=
  compileFiniteRun (canonicalCoordinates d n m) (canonicalLayers w scale A b) Q N 5

theorem canonicalCircuit_depth {d n m : ℕ} (w : Fin n → Fin d → ℝ) (scale : Fin n → ℝ)
    (A : Fin m → Fin n → ℝ) (b : Fin n → ℝ) (Q : ℕ) (N : ℕ → ℕ) :
    (canonicalCircuit w scale A b Q N).depth≤25 := compileFiniteRun_depth _ _ _ _ 5

theorem canonicalCircuit_size {d n m : ℕ} (w : Fin n → Fin d → ℝ) (scale : Fin n → ℝ)
    (A : Fin m → Fin n → ℝ) (b : Fin n → ℝ) (Q B : ℕ) (N : ℕ → ℕ)
    (hB : 1≤B) (hw : ∀j i,|w j i|≤(B:ℝ))
    (hA : ∀j i,|A j i|≤(B:ℝ)) (hb : ∀i,|b i|≤(B:ℝ)) :
    (canonicalCircuit w scale A b Q N).size ≤
      ∑j∈Finset.range 5,arithmeticLayerSize (Fintype.card (canonicalCoordinates d n m j))
        (Fintype.card (canonicalCoordinates d n m (j+1))) Q B (N j) (N (j+1)) := by
  exact compileArithmeticRun_size _ _ _ _ B
    (fun h j i=>canonicalLayers_coefficients w scale A b B hB hw hA hb h _ _) 5

theorem canonicalCircuit_accuracy {d n m : ℕ} (w : Fin n → Fin d → ℝ)
    (scale : Fin n → ℝ) (A : Fin m → Fin n → ℝ) (b : Fin n → ℝ)
    (Q B : ℕ) (N : ℕ → ℕ) (hQ : 0<Q) (hB : 1≤B)
    (hw : ∀j i,|w j i|≤(B:ℝ)) (hA : ∀j i,|A j i|≤(B:ℝ)) (hb : ∀i,|b i|≤(B:ℝ))
    (hN : ∀h,layerNextRange (Fintype.card (canonicalCoordinates d n m h)) B (N h)≤N (h+1))
    (x : Fin d → ℝ) (hx : ∀i,|x i|≤(N 0:ℝ)) (j : Fin m ⊕ Unit) :
    |canonicalArithmeticProgram w scale A b x j-scalarDecode Q (N 5)
      (finiteGridRun (canonicalCoordinates d n m) (canonicalLayers w scale A b) Q N
        (fun i=>scalarEncode Q (N 0) (x i)) 5 j)| ≤
      arithmeticRunError (fun h=>Fintype.card (canonicalCoordinates d n m h)) Q N B 5 :=
  finiteRun_accuracy _ _ Q B N hQ (canonicalLayers_coefficients w scale A b B hB hw hA hb)
    hN x hx 5 j

#print axioms canonicalCircuit_depth
#print axioms canonicalCircuit_accuracy
end ConditionalNonpolynomial.AnalyticLookup
