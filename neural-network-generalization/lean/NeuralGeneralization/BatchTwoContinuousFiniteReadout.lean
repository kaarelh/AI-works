import NeuralGeneralization.ReadoutDual
import NeuralGeneralization.BatchTwoContinuousModel
import NeuralGeneralization.ConcreteReadoutDual

/-! Uniform regression dual readout. Projection onto a scaled symmetric convex
hull gives l1 coefficients polynomial in energy and inverse accuracy, without
assuming a classification margin or an invertible covariance. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoContinuous.FiniteReadout

variable {X E : Type*} [Fintype X] [DecidableEq X] [Nonempty X]
  [NormedAddCommGroup E] [InnerProductSpace ℝ E]

def signedFeature (h : X → E) (M : ℝ) (a : X×Bool) : E :=
  (M*(if a.2 then (1 : ℝ) else -1)) • h a.1

theorem exists_approximate_dual (h : X → E) (u : E) {K η : ℝ}
    (hK : 0<K) (hη : 0<η) (hu : ‖u‖^2≤K) :
    ∃ β : X → ℝ, (∑ x,|β x|)≤K/η ∧
      ∀ x, |inner ℝ (h x) u-∑ y,β y*inner ℝ (h x) (h y)|≤η := by
  classical
  let M := K/η
  have hM : 0<M := div_pos hK hη
  let a := signedFeature h M
  let S := convexHull ℝ (Set.range a)
  have haS (i : X×Bool) : a i∈S := subset_convexHull ℝ (Set.range a) ⟨i,rfl⟩
  have hSne : S.Nonempty := ⟨a (Classical.arbitrary X,false),haS _⟩
  have hSc : IsCompact S := (Set.finite_range a).isCompact_convexHull ℝ
  have hSv : Convex ℝ S := convex_convexHull ℝ (Set.range a)
  obtain ⟨v,hv,hmin⟩ := exists_norm_eq_iInf_of_complete_convex hSne hSc.isComplete hSv u
  have hproj := (norm_eq_iInf_iff_real_inner_le_zero hSv hv).mp hmin
  obtain ⟨p,hp,hpsum,hprep⟩ := ReadoutDual.convexHull_range_weights a hv
  let β : X → ℝ := fun x => M*(p (x,true)-p (x,false))
  have hsum : (∑ x, (p (x,true)+p (x,false)))=1 := by
    simpa only [Fintype.sum_prod_type,Fintype.sum_bool,add_comm] using hpsum
  have hβ : (∑ x,|β x|)≤M := by
    calc
      _ ≤ ∑ x, M*(p (x,true)+p (x,false)) := by
        apply Finset.sum_le_sum
        intro x _
        dsimp only [β]
        rw [abs_mul,abs_of_pos hM]
        exact mul_le_mul_of_nonneg_left
          ((abs_sub (p (x,true)) (p (x,false))).trans_eq (by rw [abs_of_nonneg (hp _), abs_of_nonneg (hp _)])) hM.le
      _ = M := by rw[←Finset.mul_sum,hsum,mul_one]
  have hrep : (∑ x,β x • h x)=v := by
    rw [←hprep,Fintype.sum_prod_type]
    apply Finset.sum_congr rfl
    intro x _
    simp only [Fintype.sum_bool,a,signedFeature,β,if_pos,if_neg,Bool.false_eq_true,not_false_eq_true,
      mul_one,mul_neg_one,neg_smul,sub_smul,mul_smul]
    module
  have hbound : inner ℝ v (u-v)≤K := by
    rw [inner_sub_right,real_inner_self_eq_norm_sq]
    have hc := real_inner_le_norm v u
    nlinarith [sq_nonneg (‖v‖-‖u‖),sq_nonneg ‖u‖]
  refine ⟨β,hβ,?_⟩
  intro x
  have hpos := hproj (a (x,true)) (haS _)
  have hneg := hproj (a (x,false)) (haS _)
  simp only [inner_sub_right,a,signedFeature,if_pos,if_neg,Bool.false_eq_true,not_false_eq_true,
    mul_one,mul_neg_one,real_inner_smul_right] at hpos hneg
  rw [real_inner_comm v (u-v)] at hpos hneg
  have hc : M*|inner ℝ (h x) (u-v)|≤K := by
    rw [real_inner_comm (h x) (u-v)] at hpos hneg
    rcases le_total 0 (inner ℝ (h x) (u-v)) with hp'|hn'
    · rw [abs_of_nonneg hp']; nlinarith
    · rw [abs_of_nonpos hn']; nlinarith
  have herr : |inner ℝ (h x) (u-v)|≤η := by
    have he : M*η=K := div_mul_cancel₀ K hη.ne'
    nlinarith
  rw [inner_sub_right,←hrep,inner_sum] at herr
  simpa only [real_inner_smul_right] using herr

end NeuralGeneralization.BatchTwoContinuous.FiniteReadout
