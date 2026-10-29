import Mathlib.Analysis.InnerProductSpace.PiL2
import Mathlib.LinearAlgebra.Dimension.Constructions

/-! Exact block padding of varying finite-dimensional Hilbert states into one
fixed Hilbert space. All norm and Lipschitz bounds have factor one. -/
noncomputable section
open scoped BigOperators ENNReal NNReal
namespace ConditionalNonpolynomial.Analytic
variable {J : Type*} [Fintype J] [DecidableEq J]
variable (E : J → Type*) [∀j,NormedAddCommGroup (E j)] [∀j,InnerProductSpace ℝ (E j)]

def blockEmbedding (i : J) : E i →ₗᵢ[ℝ] PiLp 2 E where
  toFun := PiLp.single 2 i
  map_add' x y := PiLp.single_add 2 i
  map_smul' c x := by
    ext j
    by_cases hj : j=i
    · subst j
      simp
    · simp [PiLp.single_eq_of_ne 2 hj]
  norm_map' x := PiLp.norm_single 2 E i x

def blockProjection (i : J) : PiLp 2 E →L[ℝ] E i := PiLp.proj 2 E i

@[simp] theorem blockProjection_embedding (i : J) (x : E i) :
    blockProjection E i (blockEmbedding E i x)=x := by
  change (PiLp.single 2 i x).ofLp i=x
  exact PiLp.single_eq_same 2 i x

theorem blockProjection_norm (i : J) (x : PiLp 2 E) :
    ‖blockProjection E i x‖≤‖x‖ := PiLp.norm_apply_le x i

theorem blockProjection_opNorm (i : J) : ‖blockProjection E i‖≤1 := by
  apply (blockProjection E i).opNorm_le_bound (by norm_num)
  intro x
  simpa only [one_mul] using blockProjection_norm E i x

theorem blockProjection_dist (i : J) (x y : PiLp 2 E) :
    dist (blockProjection E i x) (blockProjection E i y)≤dist x y := by
  simpa only [dist_eq_norm,map_sub] using blockProjection_norm E i (x-y)

def blockLiftLinear {i j : J} (A : E i →L[ℝ] E j) : PiLp 2 E →L[ℝ] PiLp 2 E :=
  (blockEmbedding E j).toContinuousLinearMap.comp (A.comp (blockProjection E i))

@[simp] theorem blockLiftLinear_embedding {i j : J} (A : E i →L[ℝ] E j) (x : E i) :
    blockLiftLinear E A (blockEmbedding E i x)=blockEmbedding E j (A x) := by
  simp [blockLiftLinear]

theorem blockLiftLinear_norm_apply {i j : J} (A : E i →L[ℝ] E j) (x : PiLp 2 E) :
    ‖blockLiftLinear E A x‖≤‖A‖*‖x‖ := by
  change ‖blockEmbedding E j (A (blockProjection E i x))‖≤_
  rw [(blockEmbedding E j).norm_map]
  exact (A.le_opNorm _).trans (mul_le_mul_of_nonneg_left (blockProjection_norm E i x) (norm_nonneg _))

theorem blockLiftLinear_opNorm {i j : J} (A : E i →L[ℝ] E j) :
    ‖blockLiftLinear E A‖≤‖A‖ :=
  (blockLiftLinear E A).opNorm_le_bound (norm_nonneg _) (blockLiftLinear_norm_apply E A)

def blockLiftMap {i j : J} (N : E i → E j) : PiLp 2 E → PiLp 2 E :=
  fun x => blockEmbedding E j (N (blockProjection E i x))

@[simp] theorem blockLiftMap_embedding {i j : J} (N : E i → E j) (x : E i) :
    blockLiftMap E N (blockEmbedding E i x)=blockEmbedding E j (N x) := by
  simp [blockLiftMap]

theorem blockLiftMap_lipschitz {i j : J} (N : E i → E j) {K : ℝ≥0}
    (hN : LipschitzWith K N) : LipschitzWith K (blockLiftMap E N) := by
  apply LipschitzWith.of_dist_le_mul
  intro x y
  change dist (blockEmbedding E j (N (blockProjection E i x)))
    (blockEmbedding E j (N (blockProjection E i y)))≤_
  rw [(blockEmbedding E j).dist_map]
  exact (hN.dist_le_mul _ _).trans
    (mul_le_mul_of_nonneg_left (blockProjection_dist E i x y) K.coe_nonneg)

theorem blockLiftMap_zero {i j : J} (N : E i → E j) (hN : N 0=0) :
    blockLiftMap E N 0=0 := by simp [blockLiftMap,hN]

theorem blockLiftMap_range {i j : J} (N : E i → E j) (R : ℝ)
    (hN : ∀x,‖N x‖≤R) (x : PiLp 2 E) : ‖blockLiftMap E N x‖≤R := by
  change ‖blockEmbedding E j (N (blockProjection E i x))‖≤R
  rw [(blockEmbedding E j).norm_map]
  exact hN _

/-- The actual state recurrence commutes exactly with block padding. -/
theorem blockLift_recursion {i j : J} (A : E i →L[ℝ] E j) (N : E i → E j)
    (x : E i) (y : E j) (hstep : y=A x+N x) :
    blockEmbedding E j y=blockLiftLinear E A (blockEmbedding E i x)+
      blockLiftMap E N (blockEmbedding E i x) := by
  rw [blockLiftLinear_embedding,blockLiftMap_embedding,← map_add,hstep]

theorem blockAmbient_finrank [∀j,FiniteDimensional ℝ (E j)] :
    Module.finrank ℝ (PiLp 2 E)=∑j,Module.finrank ℝ (E j) := by
  rw [← Module.finrank_pi_fintype]
  exact LinearEquiv.finrank_eq (WithLp.linearEquiv 2 ℝ (∀j,E j))

theorem blockAmbient_finrank_le [∀j,FiniteDimensional ℝ (E j)] {D : ℕ}
    (hD : ∀j,Module.finrank ℝ (E j)≤D) :
    Module.finrank ℝ (PiLp 2 E)≤Fintype.card J*D := by
  rw [blockAmbient_finrank]
  calc
    _ ≤ ∑_j : J,D := Finset.sum_le_sum fun j _ => hD j
    _ = _ := by simp

#print axioms blockLift_recursion
#print axioms blockAmbient_finrank_le
end ConditionalNonpolynomial.Analytic
