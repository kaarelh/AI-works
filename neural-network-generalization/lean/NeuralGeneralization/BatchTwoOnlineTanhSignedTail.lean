import NeuralGeneralization.BatchTwoOnlineTanhSigns
import NeuralGeneralization.BatchTwoMergingCompressedTail

/-! A simultaneous Gaussian tail bound over every signed population witness. -/
noncomputable section
set_option autoImplicit false
open MeasureTheory ProbabilityTheory
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoOnlineTanhMerging
open ConcreteModel BatchTwoMerging

theorem smallPrior_map_flipHiddenSigns {d N r : ℕ} (s : HiddenSigns N r) (σ : ℝ) :
    (smallPrior d N r σ).map (flipHiddenSigns s)=smallPrior d N r σ :=
  productGaussian_map_flipHiddenSigns s _

theorem hiddenSigns_card (N r : ℕ) :
    Fintype.card (HiddenSigns N r)=2^((r+1)*N) := by
  simp only [HiddenSigns,Fintype.card_fun,Fintype.card_bool,Fintype.card_fin,←pow_mul]
  rw [Nat.mul_comm]

def signedExceptionalPartitions {d N r Q : ℕ} (J : ℝ) : Set (Weights d N r) :=
  ⋃s : HiddenSigns N r,flipHiddenSigns s ⁻¹' exceptionalPartitions (Q:=Q) J

theorem measurable_signedExceptionalPartitions {d N r Q : ℕ} (J : ℝ) :
    MeasurableSet (signedExceptionalPartitions (d:=d) (N:=N) (r:=r) (Q:=Q) J) := by
  apply MeasurableSet.iUnion
  intro s
  exact (measurable_exceptionalPartitions J).preimage (continuous_flipHiddenSigns s).measurable

theorem smallPrior_signedExceptional_tail {d N r Q : ℕ}
    (hd : 0<d) (hN : 0<N) (hQ : 0<Q) {σ : ℝ} (hσ : 0<σ) (J : ℝ) :
    (smallPrior d N r σ).real (signedExceptionalPartitions (Q:=Q) J)≤
      Real.exp (((r+1)*N:ℕ)*Real.log 2+((r+1)*(N+1):ℕ)*Real.log (Q:ℝ)+
        (N:ℝ)/2*(d+2+r*Q:ℕ)*Real.log 2-J/(4*σ^2)) := by
  let E := ((r+1)*(N+1):ℕ)*Real.log (Q:ℝ)+
    (N:ℝ)/2*(d+2+r*Q:ℕ)*Real.log 2-J/(4*σ^2)
  have he (s : HiddenSigns N r) :
      (smallPrior d N r σ).real (flipHiddenSigns s ⁻¹' exceptionalPartitions (Q:=Q) J)=
        (smallPrior d N r σ).real (exceptionalPartitions (Q:=Q) J) := by
    conv_rhs => rw [←smallPrior_map_flipHiddenSigns s σ]
    simp only [Measure.real,Measure.map_apply (continuous_flipHiddenSigns s).measurable
      (measurable_exceptionalPartitions J)]
  calc
    _ ≤ ∑s : HiddenSigns N r,(smallPrior d N r σ).real
        (flipHiddenSigns s ⁻¹' exceptionalPartitions (Q:=Q) J) := measureReal_iUnion_fintype_le _
    _ = (Fintype.card (HiddenSigns N r):ℝ)*
        (smallPrior d N r σ).real (exceptionalPartitions (Q:=Q) J) := by simp_rw [he]; simp
    _ ≤ (2:ℝ)^((r+1)*N)*Real.exp E := by
      rw [hiddenSigns_card,Nat.cast_pow,Nat.cast_ofNat]
      exact mul_le_mul_of_nonneg_left (smallPrior_exceptionalPartitions_tail hd hN hQ hσ J)
        (by positivity)
    _ = _ := by
      have hp : (2:ℝ)^((r+1)*N)=Real.exp (((r+1)*N:ℕ)*Real.log 2) := by
        rw [Real.exp_nat_mul,Real.exp_log (by norm_num : (0:ℝ)<2)]
      rw [hp,←Real.exp_add]
      congr 1
      dsimp [E]
      ring

theorem signed_compressedEnergy_le_of_not_exceptional {d N r Q : ℕ} {J : ℝ}
    (w : Weights d N r) (hw : w∉signedExceptionalPartitions (Q:=Q) J)
    (p : LayerPartitions N r) (s : HiddenSigns N r) (hq : ∀j,populationCount (p j)≤Q) :
    compressedEnergy p (flipHiddenSigns s w)≤J := by
  by_contra h
  exact hw (Set.mem_iUnion.mpr ⟨s,Set.mem_iUnion.mpr ⟨⟨p,hq⟩,lt_of_not_ge h⟩⟩)

end NeuralGeneralization.BatchTwoOnlineTanhMerging
