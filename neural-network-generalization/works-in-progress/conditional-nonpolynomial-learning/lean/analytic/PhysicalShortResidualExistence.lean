import PhysicalShortResidualProgram

noncomputable section
set_option maxHeartbeats 500000
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory InformationTheory ConditionalAnalytic
open scoped BigOperators RealInnerProductSpace ENNReal
namespace ConditionalNonpolynomial.Analytic.PhysicalShort
open NeuralGeneralization.ConcreteModel ConditionalNonpolynomial.AnalyticLookup

 def canonicalQuadratureMesh (d : ℕ) (Z δ : ℝ) : ℕ :=
  ⌈(4*(Z*((d+1:ℝ)*(1+2*((d+1:ℝ)*4))))*4)/δ⌉₊+1
 def canonicalQuadratureSamples (d : ℕ) (Z δ : ℝ) : ℕ :=
  ⌈(1024*(Z*(((d+1:ℝ)*4)+((d+1:ℝ)*4)^2))^2*
    (1+(d:ℝ)*Real.log (2*(canonicalQuadratureMesh d Z δ:ℝ)+1)))/δ^2⌉₊+1

lemma canonicalQuadratureMesh_positive (d : ℕ) (Z δ : ℝ) : 0<canonicalQuadratureMesh d Z δ := by
  unfold canonicalQuadratureMesh
  omega
lemma canonicalQuadratureSamples_positive (d : ℕ) (Z δ : ℝ) : 0<canonicalQuadratureSamples d Z δ := by
  unfold canonicalQuadratureSamples
  omega
lemma canonicalQuadratureMesh_suffices (d : ℕ) (Z : ℝ) {δ : ℝ} (hδ : 0<δ) :
    4*(Z*((d+1:ℝ)*(1+2*((d+1:ℝ)*4))))*4≤(canonicalQuadratureMesh d Z δ:ℝ)*δ := by
  apply (div_le_iff₀ hδ).mp
  apply (Nat.le_ceil _).trans
  unfold canonicalQuadratureMesh
  push_cast
  linarith
lemma canonicalQuadratureSamples_suffices (d : ℕ) (Z : ℝ) {δ : ℝ} (hδ : 0<δ) :
    1024*(Z*(((d+1:ℝ)*4)+((d+1:ℝ)*4)^2))^2*
    (1+(d:ℝ)*Real.log (2*(canonicalQuadratureMesh d Z δ:ℝ)+1))≤
      (canonicalQuadratureSamples d Z δ:ℝ)*δ^2 := by
  apply (div_le_iff₀ (sq_pos_of_pos hδ)).mp
  apply (Nat.le_ceil _).trans
  unfold canonicalQuadratureSamples
  push_cast
  linarith

lemma canonicalQuadrature_final_error {g τ : ℝ} (hg : 1≤g) (hτ : 0<τ) (hτ1 : τ≤1) :
    g*((τ/(8*g))^2+Real.sqrt ((3+2*(τ/(8*g))^2)*(τ/(8*g))^2))≤τ := by
  let ζ := τ/(8*g)
  have hg0 : 0<g := by linarith
  have hζ : 0<ζ := by dsimp [ζ];positivity
  have hζ1 : ζ≤1 := by dsimp [ζ];apply (div_le_iff₀ (by positivity : 0<8*g)).mpr;linarith
  have hζsq : ζ^2≤ζ := by nlinarith
  have hsqrt : Real.sqrt ((3+2*ζ^2)*ζ^2)≤3*ζ := by
    apply (Real.sqrt_le_iff).mpr
    constructor
    · positivity
    · have hh : ζ^2≤1 := by nlinarith
      have hm := mul_le_mul_of_nonneg_right hh (sq_nonneg ζ)
      nlinarith
  have hid : 8*g*ζ=τ := by dsimp [ζ];field_simp
  change g*(ζ^2+Real.sqrt ((3+2*ζ^2)*ζ^2))≤τ
  have hm := mul_le_mul_of_nonneg_left (add_le_add hζsq hsqrt) hg0.le
  nlinarith

namespace FiniteCanonicalDynamics
variable {d H : ℕ} {t : ℝ} {f : BooleanFunction d} {P : ControlledMarginPath d H t f}
variable {S : Finset (Cube d)} {states : ℕ → CanonicalProgramState d}

def quadratureZ (M : FiniteCanonicalDynamics P S states) (j : Fin H) :=
  canonicalNormalizer (M.layer j).law (canonicalBasisValues (M.layer j).law (M.layerSpan j)) gaussianRowNorm

def quadratureError (M : FiniteCanonicalDynamics P S states) (j : Fin H) (τ : ℝ) :=
  (τ/(8*(1+M.linearGain j)))^2

def quadratureCount (M : FiniteCanonicalDynamics P S states) (j : Fin H) (τ : ℝ) :=
  canonicalQuadratureSamples (M.layerInputDimension j) (M.quadratureZ j) (M.quadratureError j τ)

def residualCoefficientBudget (M : FiniteCanonicalDynamics P S states) (j : Fin H) : ℕ :=
  ⌈1+normalizingScale M.linearGain j+(canonicalRadius P (canonicalSignPrecision P) j)⁻¹^2+
    M.quadratureZ j+(1+M.linearGain j)⌉₊+1

lemma quadratureZ_positive (M : FiniteCanonicalDynamics P S states) (j : Fin H) : 0<M.quadratureZ j :=
  canonicalNormalizer_pos _ _ _

lemma quadratureError_positive (M : FiniteCanonicalDynamics P S states) (j : Fin H) {τ : ℝ} (hτ : 0<τ) :
    0<M.quadratureError j τ := by
  have hg := M.linearGain_one_le j
  unfold quadratureError
  positivity

lemma residualCoefficientBudget_bounds (M : FiniteCanonicalDynamics P S states) (j : Fin H) :
    1≤M.residualCoefficientBudget j ∧
    normalizingScale M.linearGain j≤(M.residualCoefficientBudget j:ℝ) ∧
    (canonicalRadius P (canonicalSignPrecision P) j)⁻¹^2≤(M.residualCoefficientBudget j:ℝ) ∧
    M.quadratureZ j≤(M.residualCoefficientBudget j:ℝ) ∧
    1+M.linearGain j≤(M.residualCoefficientBudget j:ℝ) := by
  have hs := normalizingScale_one_le M.linearGain M.linearGain_one_le j
  have hg := M.linearGain_one_le j
  have hZ := M.quadratureZ_positive j
  have hpow := sq_nonneg (canonicalRadius P (canonicalSignPrecision P) j)⁻¹
  have hh := Nat.le_ceil (1+normalizingScale M.linearGain j+
    (canonicalRadius P (canonicalSignPrecision P) j)⁻¹^2+M.quadratureZ j+(1+M.linearGain j))
  have hB : (⌈1+normalizingScale M.linearGain j+
    (canonicalRadius P (canonicalSignPrecision P) j)⁻¹^2+M.quadratureZ j+(1+M.linearGain j)⌉₊:ℝ)≤
      (M.residualCoefficientBudget j:ℝ) := by unfold residualCoefficientBudget;push_cast;linarith
  refine ⟨by unfold residualCoefficientBudget;omega,?_,?_,?_,?_⟩ <;> linarith

/-- Actual bounded fourteen-stage residual programs, including constructive
choices of finite quadrature budgets. No quadrature or matrix certificate is
left as a hypothesis. -/
theorem exists_residual_program (M : FiniteCanonicalDynamics P S states) (hd : 1≤d)
    (j : Fin H) {τ : ℝ} (hτ : 0<τ) (hτ1 : τ≤1) :
    ∃w:Fin (M.quadratureCount j τ)→Fin (M.layerInputDimension j)→ℝ,
    ∃a:Fin (M.quadratureCount j τ)→ℝ,
    ∃A:Fin (M.layerRank j)→Fin (M.quadratureCount j τ)→ℝ,
    ∃b:Fin (M.quadratureCount j τ)→ℝ,
      (M.residualProgram j w a A b).bounded (M.residualCoefficientBudget j) ∧
      ∀x:EuclideanSpace ℝ (Fin (canonicalAmbientDimension states H)),
        ‖WithLp.toLp 2 ((M.residualProgram j w a A b).eval (fun i=>x i))-
          (canonicalAmbientIso states H).symm
            (M.normResidual (canonicalSignPrecision P) j (canonicalAmbientIso states H x))‖≤τ := by
  let δ := M.quadratureError j τ
  let T := canonicalQuadratureMesh (M.layerInputDimension j) (M.quadratureZ j) δ
  have hδ : 0<δ := M.quadratureError_positive j hτ
  obtain ⟨w,a,A,b,hw,hA,hb,happrox⟩ := actual_reindexed_canonical_program (M.layer j).law (M.layerSpan j)
    (Fintype.equivFin (states j).Index).symm (M.layer j).finiteKL 4 (by norm_num) T
    (canonicalQuadratureMesh_positive _ _ _) δ hδ (M.quadratureCount j τ)
    (canonicalQuadratureSamples_positive _ _ _)
    (canonicalQuadratureMesh_suffices _ _ hδ) (canonicalQuadratureSamples_suffices _ _ hδ)
  obtain ⟨hB,hscale,hrad,hZ,hgain⟩ := M.residualCoefficientBudget_bounds j
  have hBr : (1:ℝ)≤M.residualCoefficientBudget j := by exact_mod_cast hB
  refine ⟨w,a,A,b,?_,?_⟩
  · exact residualArithmeticProgram_bounded _ _ w a A b _ _ hB
      (fun k i=>(linearCoefficients_bound _ k i).trans ((M.residualPreEncoded_norm j).trans hscale))
      hrad (fun k i=>(hw k i).trans hBr)
      (fun k i=>(hA k i).trans (by
        change M.quadratureZ j/2≤(M.residualCoefficientBudget j:ℝ)
        linarith [M.quadratureZ_positive j]))
      (fun i=>by rw [abs_of_nonneg (hb i).1];exact (hb i).2.trans hZ)
      (fun k i=>(linearCoefficients_bound _ k i).trans ((M.residualPost_norm j).trans hgain))
  · intro x
    apply (M.residualProgram_error hd j w a A b (δ+Real.sqrt ((3+2*δ)*δ)) ?_ x).trans
    · exact canonicalQuadrature_final_error (by linarith [M.linearGain_one_le j]) hτ hτ1
    · intro v
      have hh := happrox v
      rw [canonicalProgramVector_coordinates] at hh
      exact hh

#print axioms exists_residual_program
end FiniteCanonicalDynamics
end ConditionalNonpolynomial.Analytic.PhysicalShort
