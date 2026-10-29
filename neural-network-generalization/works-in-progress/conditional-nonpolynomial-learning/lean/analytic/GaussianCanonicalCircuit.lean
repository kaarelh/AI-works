import NormalizedCanonicalApproximation

/-! An actual constant-depth threshold circuit for a normalized canonical
Gaussian layer. This closes the analytic quadrature to finite-bit interface. -/
noncomputable section
set_option maxHeartbeats 1000000
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators RealInnerProductSpace ENNReal
namespace ConditionalNonpolynomial.AnalyticLookup
open ConditionalNonpolynomial.Analytic ConditionalAnalytic

lemma euclidean_norm_of_coordinate_bounds {ι : Type*} [Fintype ι]
    (x : EuclideanSpace ℝ ι) {ε : ℝ} (hε : 0≤ε) (hx : ∀i,|x i|≤ε) :
    ‖x‖≤((Fintype.card ι:ℝ)+1)*ε := by
  have hs : ‖x‖^2≤(Fintype.card ι:ℝ)*ε^2 := by
    rw [EuclideanSpace.real_norm_sq_eq]
    calc
      _ ≤ ∑_i:ι,ε^2 := Finset.sum_le_sum fun i _=>by
        simpa only [sq_abs] using pow_le_pow_left₀ (abs_nonneg (x i)) (hx i) 2
      _ = _ := by simp
  have hd : (Fintype.card ι:ℝ)≤((Fintype.card ι:ℝ)+1)^2 := by
    nlinarith [Nat.cast_nonneg (Fintype.card ι) (α:=ℝ)]
  have hm := mul_le_mul_of_nonneg_right hd (sq_nonneg ε)
  apply (sq_le_sq₀ (norm_nonneg _) (by positivity)).mp
  nlinarith

lemma canonicalProgramVector_coordinates {d n m : ℕ} (w : Fin n→Fin d→ℝ)
    (a : Fin n→ℝ) (A : Fin m→Fin n→ℝ) (b : Fin n→ℝ) (x : Fin d→ℝ) :
    completionToVector (canonicalProgramVector w a A b x)=
      WithLp.toLp 2 (canonicalArithmeticProgram w a A b x) := by
  ext i
  rcases i with i|⟨⟩ <;> rfl

variable {d : ℕ} (ρ : Measure (Fin d→ℝ)) [IsProbabilityMeasure ρ]
variable (V : Submodule ℝ (Lp ℝ 2 ρ)) [FiniteDimensional ℝ V]

def canonicalCoefficientBudget (α : ℝ) : ℕ :=
  ⌈canonicalNormalizer ρ (canonicalBasisValues ρ V) (fun z=>gaussianRowNorm z/α)⌉₊+1

lemma canonicalCoefficientBudget_one (α : ℝ) : 1≤canonicalCoefficientBudget ρ V α := by
  unfold canonicalCoefficientBudget
  omega

lemma canonicalCoefficientBudget_bound (α : ℝ) :
    canonicalNormalizer ρ (canonicalBasisValues ρ V) (fun z=>gaussianRowNorm z/α)≤
      (canonicalCoefficientBudget ρ V α:ℝ) := by
  have hh := Nat.le_ceil (canonicalNormalizer ρ (canonicalBasisValues ρ V) (fun z=>gaussianRowNorm z/α))
  unfold canonicalCoefficientBudget
  push_cast
  linarith

/-- The statement concerns the original actual Gaussian controlled law,
actual orthonormal-basis canonical map, and an actual finite threshold DAG.
The sole numerical premises are explicit quadrature sample/mesh budgets. -/
theorem gaussian_canonical_threshold_evaluator
    (hKL : klDiv ρ (Measure.pi fun _ : Fin d=>gaussianReal 0 1)≠∞)
    (S α : ℝ) (hS : S≠0) (hα : α≠0) (U : ℕ) (hU : 0<U)
    (T : ℕ) (hT : 0<T) (δ ε : ℝ) (hδ : 0<δ) (hε : 0<ε) (hεone : ε≤1)
    (n : ℕ) (hn : 0<n)
    (hmesh : let Z := canonicalNormalizer ρ (canonicalBasisValues ρ V) (fun z=>gaussianRowNorm z/α)
      4*(Z*((d+1:ℝ)*(1+2*((d+1:ℝ)*U))))*U≤(T:ℝ)*δ)
    (hbudget : let Z := canonicalNormalizer ρ (canonicalBasisValues ρ V) (fun z=>gaussianRowNorm z/α)
      1024*(Z*(((d+1:ℝ)*U)+((d+1:ℝ)*U)^2))^2*
        (1+(d:ℝ)*Real.log (2*(T:ℝ)+1))≤(n:ℝ)*δ^2) :
    let B := canonicalCoefficientBudget ρ V α
    let dims := fun h=>Fintype.card (canonicalCoordinates d n (Module.finrank ℝ V) h)
    let N := arithmeticRanges dims B U
    let K := fiveStageAmplification dims B U
    let Q := fiveStageMesh K ε
    let R := ((1+Real.sqrt (2*(klDiv ρ (Measure.pi fun _ : Fin d=>gaussianReal 0 1)).toReal))/|α|)*
      (((d:ℝ)+1)*U)
    ∃c:CircuitMap (Fintype.card (Fin d)*Fintype.card (ScalarGrid Q U))
      (Fintype.card (Fin (Module.finrank ℝ V)⊕Unit)*Fintype.card (ScalarGrid Q (N 5))),
      c.depth≤25 ∧
      c.size≤∑j∈Finset.range 5,arithmeticLayerSize (dims j) (dims (j+1)) Q B (N j) (N (j+1)) ∧
      ∀v:ParameterCube (Fin d) (U:ℝ),
        ∃a:(Fin (Module.finrank ℝ V)⊕Unit)→ScalarCode Q (N 5),
          c.eval (encodeCoordinateState Q U (fun i=>scalarEncode Q U (v.val i)))=
            encodeCoordinateState Q (N 5) a ∧
          ‖canonicalVector V (normalizedTanhL2 ρ S α (WithLp.toLp 2 v.val))-
            WithLp.toLp 2 (fun j=>scalarDecode Q (N 5) (a j))‖≤
              δ+Real.sqrt ((1+2*(R+δ))*δ)+((Module.finrank ℝ V:ℝ)+2)*ε := by
  dsimp only
  let B := canonicalCoefficientBudget ρ V α
  let dims := fun h=>Fintype.card (canonicalCoordinates d n (Module.finrank ℝ V) h)
  let N := arithmeticRanges dims B U
  let K := fiveStageAmplification dims B U
  let Q := fiveStageMesh K ε
  obtain ⟨w,a,A,b,hw,hA,hb,happrox⟩ := actual_normalized_canonical_program ρ V hKL
    S α hS hα (U:ℝ) (by exact_mod_cast hU) T hT δ hδ n hn hmesh hbudget
  have hB := canonicalCoefficientBudget_one ρ V α
  have hBreal : (1:ℝ)≤B := by exact_mod_cast hB
  have hZ := canonicalNormalizer_pos ρ (canonicalBasisValues ρ V) (fun z=>gaussianRowNorm z/α)
  have hZB := canonicalCoefficientBudget_bound ρ V α
  have hwB : ∀j i,|w j i|≤(B:ℝ) := fun j i=>(hw j i).trans hBreal
  have hAB : ∀j i,|A j i|≤(B:ℝ) := by intro j i; have hh:=hA j i; linarith
  have hbB : ∀i,|b i|≤(B:ℝ) := by
    intro i
    rw [abs_of_nonneg (hb i).1]
    exact (hb i).2.trans hZB
  obtain ⟨c,hdepth,hsize,hcodes⟩ := canonical_finite_evaluator w a A b B U hB hwB hAB hbB ε hε hεone
  refine ⟨c,hdepth,hsize,?_⟩
  intro v
  obtain ⟨codes,hceval,hcerr⟩ := hcodes v.val v.property
  refine ⟨codes,hceval,?_⟩
  let f : EuclideanSpace ℝ (Fin (Module.finrank ℝ V)⊕Unit) :=
    WithLp.toLp 2 (canonicalArithmeticProgram w a A b v.val)
  let g : EuclideanSpace ℝ (Fin (Module.finrank ℝ V)⊕Unit) :=
    WithLp.toLp 2 (fun j=>scalarDecode Q (N 5) (codes j))
  have hfg : ‖f-g‖≤((Module.finrank ℝ V:ℝ)+2)*ε := by
    have hh := euclidean_norm_of_coordinate_bounds (f-g) hε.le hcerr
    simpa only [Fintype.card_sum,Fintype.card_fin,Fintype.card_unit,Nat.cast_add,Nat.cast_one,
      show (1:ℝ)+1=2 by norm_num,add_assoc] using hh
  have hf := happrox v
  rw [canonicalProgramVector_coordinates] at hf
  have hh := dist_triangle (canonicalVector V (normalizedTanhL2 ρ S α (WithLp.toLp 2 v.val))) f g
  simp only [dist_eq_norm] at hh
  rw [norm_sub_rev (canonicalVector V (normalizedTanhL2 ρ S α (WithLp.toLp 2 v.val))) f] at hh
  exact hh.trans (add_le_add hf hfg)

#print axioms gaussian_canonical_threshold_evaluator
end ConditionalNonpolynomial.AnalyticLookup
