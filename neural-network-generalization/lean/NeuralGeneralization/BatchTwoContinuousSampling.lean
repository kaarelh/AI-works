import NeuralGeneralization.BatchTwoContinuousFreeze
import Mathlib.Data.Nat.Log

/-! Actual simultaneous neuron sampling on any finite set of real inputs. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
open MeasureTheory ProbabilityTheory Set
namespace NeuralGeneralization.BatchTwoContinuous
open ConcreteModel CompressionSampling

variable {ι : Type*} [Fintype ι]

theorem exists_real_input_sampling_lists {d N M r : ℕ} [NeZero N] (hM : 0 < M)
    (φ : ℝ → ℝ) (hφ : ∀ t, |φ t| ≤ 1) {ρ q K : ℝ}
    (hρ : 0 < ρ) (hq : 0 < q) (hqsq : q^2=(N : ℝ)) (hK : 0 < K)
    (w u : Weights d N r) (hw : weightedSquaredNorm w ≤ K) (hu : weightedSquaredNorm u ≤ K)
    (input : ι → RealInput d)
    (hint : ∀ s i j, |u (Sum.inr (Sum.inl (s,i,j)))| ≤ 2*internalRowNorm w s i/(ρ*q))
    (hout : ∀ j, |u (Sum.inr (Sum.inr j))| ≤ 2*outputRowNorm w/(ρ*q))
    (hwidth : (Fintype.card ι : ℝ)*(((r : ℝ)*M+1)*2^d*
      (2*Real.exp (-ρ^4*(M : ℝ)/32))) ≤ 1/4) :
    ∃ I : Fin (r+1) → Fin M → Fin N,
      weightedSquaredNorm (sampledWeights u I) ≤ 4*K ∧
      retainedRowMass w I ≤ 8*(M : ℝ)*K ∧
      ∀ x : ι, ∀ y : Cube d,
        (∀ s a, |rowSamplingError φ (freezeInput (input x) u) I y s a| ≤
          ρ/2*q*internalRowNorm w s (I s.succ a)) ∧
        |((N : ℝ)/M)*∑ a,
          u (Sum.inr (Sum.inr (I (Fin.last r) a)))*
            finalHidden φ u (input x) (I (Fin.last r) a)-output φ u (input x)| ≤ ρ/2*q*outputRowNorm w := by
  classical
  let A : ι → Set (Fin (r+1) → Fin M → Fin N) :=
    fun x => badRowEvent φ ρ q (freezeInput (input x) w) (freezeInput (input x) u)
  have hA (x : ι) : (allLayerLists N M r).real (A x) ≤
      ((r : ℝ)*M+1)*2^d*(2*Real.exp (-ρ^4*(M : ℝ)/32)) := by
    apply badRowEvent_probability hM φ hφ hρ hq hqsq
    · exact hint
    · exact hout
  have hbad : (allLayerLists N M r).real (⋃ x, A x) ≤ 1/4 :=
    (finite_failure_union_le (allLayerLists N M r) A hA).trans hwidth
  let B : Set (Fin (r+1) → Fin M → Fin N) := {I | 8*(M : ℝ)*K ≤ retainedRowMass w I}
  let C : Set (Fin (r+1) → Fin M → Fin N) := {I | 4*K ≤ weightedSquaredNorm (sampledWeights u I)}
  have hB : (allLayerLists N M r).real B ≤ 1/8 := retainedRowMass_tail hM w hK hw
  have hC : (allLayerLists N M r).real C ≤ 1/4 := sampled_cost_tail hM u hK hu
  obtain ⟨I,hIA,hIB,hIC⟩ := exists_outside_three_events (⋃ x, A x) B C hbad hB hC (by norm_num)
  refine ⟨I,(lt_of_not_ge hIC).le,(lt_of_not_ge hIB).le,?_⟩
  intro x y
  have hnot : I ∉ A x := fun hx => hIA (Set.mem_iUnion.mpr ⟨x,hx⟩)
  constructor
  · intro s a
    exact le_of_not_gt (fun h => hnot (Or.inl ⟨y,s,a,h⟩))
  · have h := le_of_not_gt (fun h => hnot (Or.inr ⟨y,h⟩))
    simpa only [finalHidden_freeze, output_freeze, outputRowNorm_freeze, freezeInput] using h

def netDimension (d : ℕ) (ι : Type*) [Fintype ι] : ℕ := d+Nat.clog 2 (Fintype.card ι)

theorem net_card_budget (d : ℕ) : (Fintype.card ι : ℝ)*2^d ≤ 2^(netDimension d ι) := by
  have h := Nat.le_pow_clog (by norm_num : 1 < 2) (Fintype.card ι)
  have hn : Fintype.card ι*2^d ≤ 2^(netDimension d ι) := by
    unfold netDimension
    rw [pow_add, mul_comm]
    exact Nat.mul_le_mul_left _ h
  exact_mod_cast hn

theorem real_sampling_width_budget (d r K : ℕ) (hK : 1 ≤ K) :
    let M := compressionWidth (netDimension d ι) r K
    let ρ : ℝ := (compressionQ r K : ℝ)⁻¹
    (Fintype.card ι : ℝ)*(((r : ℝ)*M+1)*2^d*
      (2*Real.exp (-ρ^4*(M : ℝ)/32))) ≤ 1/4 := by
  dsimp only
  have h := compressionWidth_row_bound (netDimension d ι) r K hK
  have hb := mul_le_mul_of_nonneg_right (net_card_budget (ι := ι) d)
    (show 0 ≤ (((r : ℝ)*compressionWidth (netDimension d ι) r K+1)*
      (2*Real.exp (-((compressionQ r K : ℝ)⁻¹)^4*(compressionWidth (netDimension d ι) r K : ℝ)/32))) by positivity)
  calc
    _ ≤ (((r : ℝ)*compressionWidth (netDimension d ι) r K+1)*2^(netDimension d ι)*
        (2*Real.exp (-((compressionQ r K : ℝ)⁻¹)^4*(compressionWidth (netDimension d ι) r K : ℝ)/32))) := by
      simpa only [mul_assoc, mul_comm, mul_left_comm] using hb
    _ ≤ 1/4 := h

end NeuralGeneralization.BatchTwoContinuous
