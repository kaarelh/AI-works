import NeuralGeneralization.BatchTwoContinuousDepthFiniteBulkGeometry
import NeuralGeneralization.BatchTwoMergingSharpBulk

/-! The paper's actual Gaussian block body has probability at least one half. -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoContinuousDepthPaper
open ConcreteModel
set_option maxHeartbeats 1000000
set_option backward.isDefEq.respectTransparency false

theorem gaussian_boundary_norm_paper_tail {ι : Type*} [Fintype ι] {N d : ℕ}
    (hN : 1 ≤ N) (hcard : Fintype.card ι ≤ N*(d+1)) :
    (Measure.pi fun _ : ι => gaussianReal 0 1).real
      {x | boundaryNoiseRadius d N < ‖WithLp.toLp 2 x‖} ≤ 1/8 := by
  have ht := gaussian_boundary_paper_tail hN hcard 1 (by norm_num)
  simp only [NNReal.coe_one,mul_one] at ht
  apply le_trans (measureReal_mono (μ:=Measure.pi fun _ : ι => gaussianReal 0 1) ?_) ht
  intro x hx
  have hn := norm_nonneg (WithLp.toLp 2 x)
  have hR : 0 ≤ boundaryNoiseRadius d N := by unfold boundaryNoiseRadius;positivity
  have hs : (boundaryNoiseRadius d N)^2=(N : ℝ)*firstNoiseSquared d := by
    rw [boundaryNoiseRadius,mul_pow,Real.sq_sqrt (Nat.cast_nonneg N),
      Real.sq_sqrt (firstNoiseSquared_pos d).le]
  have he := EuclideanSpace.real_norm_sq_eq (WithLp.toLp 2 x)
  change (N : ℝ)*firstNoiseSquared d ≤ ∑ i,x i^2
  simp only [PiLp.toLp_apply] at he
  change boundaryNoiseRadius d N < ‖WithLp.toLp 2 x‖ at hx
  nlinarith

theorem gaussian_subfamily_boundary_tail {ι κ : Type*} [Fintype ι] [Fintype κ]
    {N d : ℕ} (hN : 1 ≤ N) (hcard : Fintype.card κ ≤ N*(d+1))
    (e : κ → ι) (he : Function.Injective e) :
    (Measure.pi fun _ : ι => gaussianReal 0 1).real
      {x | boundaryNoiseRadius d N < ‖WithLp.toLp 2 (fun i => x (e i))‖} ≤ 1/8 := by
  have ht := gaussian_boundary_norm_paper_tail hN hcard
  have hm := BatchTwoNonGaussian.productLaw_map_subfamily (gaussianReal 0 1) e he
  rw [← hm] at ht
  have hset : MeasurableSet {x : κ → ℝ | boundaryNoiseRadius d N < ‖WithLp.toLp 2 x‖} :=
    measurableSet_lt measurable_const ((PiLp.continuous_toLp 2 _).norm.measurable)
  have hmeas : Measurable (fun x : ι → ℝ => fun i => x (e i)) := by fun_prop
  simp only [Measure.real,Measure.map_apply hmeas hset] at ht
  exact ht

theorem gaussian_subfamily_internal_tail {ι : Type*} [Fintype ι] {N L : ℕ}
    (hN : 1 ≤ N) (hL : 1 ≤ L) (e : Fin N × Fin N → ι) (he : Function.Injective e) :
    (Measure.pi fun _ : ι => gaussianReal 0 1).real
      {x | internalNoiseRadius N L < ‖coordinateMatrixOperator (fun ij => x (e ij))‖} ≤
        1/(4*(L : ℝ)) := by
  have ht := gaussian_internal_paper_tail hN hL 1 (by norm_num)
  simp only [NNReal.coe_one,mul_one] at ht
  have hm := BatchTwoNonGaussian.productLaw_map_subfamily (gaussianReal 0 1) e he
  rw [← hm] at ht
  have hset : MeasurableSet {x : Fin N × Fin N → ℝ |
      internalNoiseRadius N L < ‖coordinateMatrixOperator x‖} := by
    apply measurableSet_lt measurable_const
    exact (BatchTwoMerging.continuous_coordinateMatrixOperator.norm).measurable
  dsimp only [internalNoiseRadius] at hset
  have hmeas : Measurable (fun x : ι → ℝ => fun i => x (e i)) := by fun_prop
  simp only [Measure.real,Measure.map_apply hmeas hset] at ht
  exact ht

theorem typicalBody_gaussian_mass {d N r : ℕ} (hN : 1 ≤ N) :
    (1/2 : ℝ) ≤ (Measure.pi fun _ : WeightIndex d N r => gaussianReal 0 1).real
      ((WithLp.toLp 2) ⁻¹' typicalBody d N r) := by
  classical
  let μ : Measure (Weights d N r) := Measure.pi fun _ => gaussianReal 0 1
  let A : Set (Weights d N r) := (WithLp.toLp 2) ⁻¹' typicalBody d N r
  let F : Set (Weights d N r) := {x | boundaryNoiseRadius d N <
    ‖firstBlockProjection d N r (WithLp.toLp 2 x)‖}
  let V : Set (Weights d N r) := {x | boundaryNoiseRadius d N <
    ‖readoutBlockProjection d N r (WithLp.toLp 2 x)‖}
  let I : Fin r → Set (Weights d N r) := fun s => {x | internalNoiseRadius N (r+2) <
    ‖internalBlockProjection d N r s (WithLp.toLp 2 x)‖}
  have hf : μ.real F ≤ 1/8 := by
    exact gaussian_subfamily_boundary_tail hN (by simp) Sum.inl Sum.inl_injective
  have hv : μ.real V ≤ 1/8 := by
    exact gaussian_subfamily_boundary_tail hN (by simp only [Fintype.card_fin];nlinarith [Nat.zero_le (N*d)])
      (fun i => Sum.inr (Sum.inr i)) (fun i j hij => Sum.inr_injective (Sum.inr_injective hij))
  have hi (s : Fin r) : μ.real (I s) ≤ 1/(4*((r : ℝ)+2)) := by
    have hh := gaussian_subfamily_internal_tail hN (by omega : 1 ≤ r+2)
      (fun ij : Fin N × Fin N => (Sum.inr (Sum.inl (s,ij)) : WeightIndex d N r)) (by
        intro ij kl h
        exact Prod.mk.inj (Sum.inl_injective (Sum.inr_injective h)) |>.2)
    simpa only [μ,I,internalBlockProjection,LinearMap.coe_mk,AddHom.coe_mk,PiLp.toLp_apply,Nat.cast_add,Nat.cast_ofNat] using hh
  have hA : MeasurableSet A :=
    (typicalBody_closed d N r).measurableSet.preimage (PiLp.continuous_toLp 2 _).measurable
  have hsub : Aᶜ ⊆ (F ∪ V) ∪ ⋃ s,I s := by
    intro x hx
    by_contra hn
    have hn' : x ∉ F ∧ x ∉ V ∧ ∀ s,x ∉ I s := by
      simpa only [Set.mem_union,Set.mem_iUnion,not_or,not_exists,and_assoc] using hn
    apply hx
    apply (mem_typicalBody (WithLp.toLp 2 x)).mpr
    exact ⟨le_of_not_gt hn'.1,le_of_not_gt hn'.2.1,fun s => le_of_not_gt (hn'.2.2 s)⟩
  have hbad : μ.real Aᶜ ≤ 1/2 := by
    calc
      _ ≤ μ.real ((F ∪ V) ∪ ⋃ s,I s) := measureReal_mono hsub
      _ ≤ μ.real (F ∪ V)+μ.real (⋃ s,I s) := measureReal_union_le _ _
      _ ≤ (μ.real F+μ.real V)+∑ s,μ.real (I s) :=
        add_le_add (measureReal_union_le _ _) (measureReal_iUnion_fintype_le I)
      _ ≤ (1/8+1/8)+∑ _s : Fin r,1/(4*((r : ℝ)+2)) :=
        add_le_add (add_le_add hf hv) (Finset.sum_le_sum (fun s _ => hi s))
      _ ≤ 1/2 := by
        simp only [Finset.sum_const,Finset.card_univ,Fintype.card_fin,nsmul_eq_mul]
        have hr : 0 ≤ (r : ℝ) := Nat.cast_nonneg r
        have hh : (r : ℝ)/(4*((r : ℝ)+2)) ≤ 1/4 := by
          apply (div_le_iff₀ (by positivity)).mpr
          linarith
        have hh' : (r : ℝ)*(1/(4*((r : ℝ)+2))) ≤ 1/4 := by simpa only [mul_one_div] using hh
        linarith
  have ht := measureReal_add_measureReal_compl (μ:=μ) hA
  rw [probReal_univ] at ht
  change 1/2 ≤ μ.real A
  linarith

end NeuralGeneralization.BatchTwoContinuousDepthPaper
