import NeuralGeneralization.NetworkCylinderProbability
import Mathlib.Probability.Independence.Basic

/-! The paper's layerwise Gaussian bulk radius, with a width-uniform joint
probability bound. Every marginal below is the actual free-coordinate law. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory
open scoped BigOperators NNReal
namespace NeuralGeneralization.BatchTwoMerging
open ConcreteModel

theorem continuous_coordinateMatrixOperator {m n : Type*} [Fintype m] [Fintype n] :
    Continuous (coordinateMatrixOperator : (m × n → ℝ) → (EuclideanSpace ℝ n →L[ℝ] EuclideanSpace ℝ m)) := by
  classical
  let L : (m × n → ℝ) →ₗ[ℝ] (EuclideanSpace ℝ n →L[ℝ] EuclideanSpace ℝ m) :=
    { toFun := coordinateMatrixOperator
      map_add' := by
        intro a b
        ext x i
        simp [coordinateMatrixOperator,Matrix.toLpLin_apply,Matrix.mulVec,dotProduct,add_mul,Finset.sum_add_distrib]
      map_smul' := by
        intro c a
        ext x i
        simp [coordinateMatrixOperator,Matrix.toLpLin_apply,Matrix.mulVec,dotProduct,mul_assoc,Finset.mul_sum] }
  exact L.continuous_of_finiteDimensional

theorem iid_map_injection {I J : Type*} [Fintype I] [Fintype J]
    (e : J → I) (he : Function.Injective e) (v : ℝ≥0) :
    (Measure.pi (fun _ : I => gaussianReal 0 v)).map (fun z j => z (e j))=
      Measure.pi (fun _ : J => gaussianReal 0 v) := by
  classical
  have hi : iIndepFun (fun i : I => fun z : I → ℝ => z i)
      (Measure.pi (fun _ : I => gaussianReal 0 v)) := iIndepFun_pi (fun _ => aemeasurable_id)
  have hj := hi.precomp he
  have hmap := hj.map_fun_eq_pi_map (fun j => (measurable_pi_apply (e j)).aemeasurable)
  simpa only [Measure.pi_map_eval,measure_univ,Finset.prod_const_one,one_smul] using hmap

def sharpBulkBound (r : ℕ) : ℝ := Real.sqrt (16*Real.log 9+8*Real.log (4*((r : ℝ)+2)))

theorem sharpBulkBound_nonneg (r : ℕ) : 0 ≤ sharpBulkBound r := Real.sqrt_nonneg _

theorem sharpBulkBound_sq (r : ℕ) :
    (sharpBulkBound r)^2=16*Real.log 9+8*Real.log (4*((r : ℝ)+2)) := by
  apply Real.sq_sqrt
  have h1 : 0 ≤ Real.log (9 : ℝ) := Real.log_nonneg (by norm_num)
  have h2 : 0 ≤ Real.log (4*((r : ℝ)+2)) := Real.log_nonneg (by linarith [Nat.cast_nonneg (α := ℝ) r])
  positivity

def sharpLayerMatrix {d N r : ℕ} (J : Finset (Fin N)) (s : Fin r)
    (z : {q : WeightIndex d N r // ¬constrainedIndex J q} → ℝ) :
    Fin N × {j : Fin N // j ∉ J} → ℝ := fun q => freeCoordinateMatrix J z ((s,q.1),q.2)

def sharpFreeCoordinateEvent {d N r : ℕ} (J : Finset (Fin N)) (B : ℝ) :
    Set ({q : WeightIndex d N r // ¬constrainedIndex J q} → ℝ) :=
  {z | ∀ s : Fin r, ‖coordinateMatrixOperator (sharpLayerMatrix J s z)‖ ≤ B}

theorem continuous_sharpLayerMatrix {d N r : ℕ} (J : Finset (Fin N)) (s : Fin r) :
    Continuous (sharpLayerMatrix (d := d) J s) := by
  apply continuous_pi
  intro q
  exact continuous_apply _

theorem measurable_sharpFreeCoordinateEvent {d N r : ℕ} (J : Finset (Fin N)) (B : ℝ) :
    MeasurableSet (sharpFreeCoordinateEvent (d := d) (r := r) J B) := by
  simp only [sharpFreeCoordinateEvent,Set.setOf_forall]
  apply MeasurableSet.iInter
  intro s
  exact measurableSet_le ((continuous_coordinateMatrixOperator.comp (continuous_sharpLayerMatrix J s)).norm.measurable) measurable_const

theorem sharpLayerMatrix_map {d N r : ℕ} (J : Finset (Fin N)) (s : Fin r) (v : ℝ≥0) :
    (Measure.pi (fun _ : {q : WeightIndex d N r // ¬constrainedIndex J q} => gaussianReal 0 v)).map
      (sharpLayerMatrix J s)=Measure.pi (fun _ : Fin N × {j : Fin N // j ∉ J} => gaussianReal 0 v) := by
  apply iid_map_injection
  intro a b hab
  apply Prod.ext
  · have h := congrArg (fun q => ((freeIndexEquiv J) q).1.2) hab
    simpa using h
  · have h := congrArg (fun q => ((freeIndexEquiv J) q).2) hab
    simpa using h

theorem sharp_matrix_tail {N r : ℕ} {J : Type*} [Fintype J]
    (hN : 0 < N) (hJ : Fintype.card J ≤ N) {σ : ℝ} (hσ : 0 < σ)
    (hscale : (N : ℝ)*σ^2 ≤ 1) :
    (Measure.pi (fun _ : Fin N × J => gaussianReal 0 (σ^2).toNNReal)).real
      {z | sharpBulkBound r < ‖coordinateMatrixOperator z‖} ≤ 1/(2*((r : ℝ)+2)) := by
  have hv : 0 < ((σ^2).toNNReal : ℝ) := by rw [Real.coe_toNNReal _ (sq_nonneg σ)]; positivity
  have h := GaussianTail.gaussian_matrix_operator_tail (m := Fin N) (n := J)
    (σ^2).toNNReal hv (sharpBulkBound r/2) (by positivity [sharpBulkBound_nonneg r])
  have heq : 2*(sharpBulkBound r/2)=sharpBulkBound r := by ring
  rw [heq,Real.coe_toNNReal _ (sq_nonneg σ)] at h
  have hNR : (1 : ℝ) ≤ N := by exact_mod_cast hN
  have hc : (N+Fintype.card J : ℕ) ≤ 2*N := by omega
  have hp : (9 : ℝ)^(N+Fintype.card J) ≤ (9 : ℝ)^(2*N) := pow_le_pow_right₀ (by norm_num) hc
  have hlog : 0 ≤ Real.log (4*((r : ℝ)+2)) := Real.log_nonneg (by linarith [Nat.cast_nonneg (α := ℝ) r])
  have hB := sharpBulkBound_sq r
  have hss : 0 < σ^2 := sq_pos_of_pos hσ
  have he : (2*(N : ℝ))*Real.log 9-(sharpBulkBound r/2)^2/(2*σ^2) ≤
      -(N : ℝ)*Real.log (4*((r : ℝ)+2)) := by
    suffices (2*(N : ℝ))*Real.log 9+(N : ℝ)*Real.log (4*((r : ℝ)+2)) ≤
        (sharpBulkBound r/2)^2/(2*σ^2) by linarith
    apply (le_div_iff₀ (by positivity : 0 < 2*σ^2)).mpr
    have hm := mul_le_mul_of_nonneg_right hscale (sq_nonneg (sharpBulkBound r))
    rw [hB] at hm
    nlinarith only [hm,hB]
  have hpow : (9 : ℝ)^(2*N)=Real.exp ((2*(N : ℝ))*Real.log 9) := by
    rw [show 2*(N : ℝ)=((2*N : ℕ) : ℝ) by push_cast; rfl,
      Real.exp_nat_mul,Real.exp_log (by norm_num : (0 : ℝ) < 9)]
  calc
    _ ≤ 2*(9 : ℝ)^(N+Fintype.card J)*Real.exp (-(sharpBulkBound r/2)^2/(2*σ^2)) := by simpa using h
    _ ≤ 2*(9 : ℝ)^(2*N)*Real.exp (-(sharpBulkBound r/2)^2/(2*σ^2)) := by gcongr
    _ = 2*Real.exp ((2*(N : ℝ))*Real.log 9-(sharpBulkBound r/2)^2/(2*σ^2)) := by rw [hpow, mul_assoc,← Real.exp_add]; congr 1; ring
    _ ≤ 2*Real.exp (-(N : ℝ)*Real.log (4*((r : ℝ)+2))) := by gcongr
    _ ≤ 2*Real.exp (-Real.log (4*((r : ℝ)+2))) := by gcongr; nlinarith
    _ = _ := by rw [Real.exp_neg,Real.exp_log (by positivity)]; field_simp; ring

theorem sharpFreeCoordinateEvent_real_ge_half {d N r : ℕ} (hN : 0 < N)
    (J : Finset (Fin N)) {σ : ℝ} (hσ : 0 < σ) (hscale : (N : ℝ)*σ^2 ≤ 1) :
    (1 : ℝ)/2 ≤ (Measure.pi (fun _ : {q : WeightIndex d N r // ¬constrainedIndex J q} =>
      gaussianReal 0 (σ^2).toNNReal)).real (sharpFreeCoordinateEvent J (sharpBulkBound r)) := by
  let μ := Measure.pi (fun _ : {q : WeightIndex d N r // ¬constrainedIndex J q} => gaussianReal 0 (σ^2).toNNReal)
  let E (s : Fin r) := {z | sharpBulkBound r < ‖coordinateMatrixOperator (sharpLayerMatrix (d := d) J s z)‖}
  have hEtail (s : Fin r) : μ.real (E s) ≤ 1/(2*((r : ℝ)+2)) := by
    have h := sharp_matrix_tail (r := r) (J := {j : Fin N // j ∉ J}) hN
      (by simpa only [Fintype.card_fin] using Fintype.card_subtype_le (fun j : Fin N => j ∉ J)) hσ hscale
    have hm : MeasurableSet {z : Fin N × {j : Fin N // j ∉ J} → ℝ |
        sharpBulkBound r < ‖coordinateMatrixOperator z‖} :=
      measurableSet_lt measurable_const (continuous_coordinateMatrixOperator.norm.measurable)
    have heq := congrArg (fun m : Measure (Fin N × {j : Fin N // j ∉ J} → ℝ) => m.real {z | sharpBulkBound r < ‖coordinateMatrixOperator z‖})
      (sharpLayerMatrix_map (d := d) J s (σ^2).toNNReal)
    rw [Measure.real,Measure.map_apply (continuous_sharpLayerMatrix J s).measurable hm] at heq
    change μ.real (E s)=_ at heq
    rwa [heq]
  have heq : (sharpFreeCoordinateEvent (d := d) (r := r) J (sharpBulkBound r))ᶜ=⋃ s : Fin r, E s := by
    ext z
    simp [sharpFreeCoordinateEvent,E]
  have htail : μ.real (sharpFreeCoordinateEvent (d := d) (r := r) J (sharpBulkBound r))ᶜ ≤ 1/2 := by
    rw [heq]
    calc
      _ ≤ ∑ s : Fin r, μ.real (E s) := measureReal_iUnion_fintype_le _
      _ ≤ ∑ _s : Fin r, 1/(2*((r : ℝ)+2)) := Finset.sum_le_sum fun s _ => hEtail s
      _ ≤ 1/2 := by
        rw [Finset.sum_const,Finset.card_univ,Fintype.card_fin,nsmul_eq_mul,mul_one_div]
        apply (div_le_iff₀ (by positivity : 0 < 2*((r : ℝ)+2))).mpr
        linarith
  rw [measureReal_compl (measurable_sharpFreeCoordinateEvent J (sharpBulkBound r)),probReal_univ] at htail
  linarith

end NeuralGeneralization.BatchTwoMerging
