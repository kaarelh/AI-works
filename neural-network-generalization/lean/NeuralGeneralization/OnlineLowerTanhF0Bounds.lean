import NeuralGeneralization.OnlineLowerTanhAllGainLimit
import NeuralGeneralization.OnlineLowerTanhMonotone

noncomputable section
open scoped Topology
open Filter
namespace NeuralGeneralization.OnlineLowerTanh

lemma balancedParity_normalized_lower (r:ℕ) (a:ℝ) (ha:1≤a) :
    (1/2:ℝ)≤balancedParity r a/oddParityKappa r := by
  have h:=balancedParity_lower r a (by linarith)
  have ht:=scalar_tanh_monotone ha
  have hone:=tanh_one_gt_three_quarters
  have hk:=oddParityKappa_pos r
  apply (le_div_iff₀ hk).mpr
  nlinarith [mul_le_mul_of_nonneg_left ht hk.le]

lemma scalarF0_ge_half (a:ℝ) (ha:1≤a) : (1/2:ℝ)≤scalarF0 a := by
  exact ge_of_tendsto (balancedParity_normalized_tendsto a (by linarith))
    (Eventually.of_forall (fun r=>balancedParity_normalized_lower r a ha))

lemma balancedParity_normalized_le_one (r:ℕ) (a:ℝ) :
    balancedParity r a/oddParityKappa r≤1 := by
  have h:=parityCorrelation_monotone_cap r (fun _=>a) 0
  have habs:|balancedParity r a|=|parityCorrelation (fun _:Fin (2*r+1)=>a) 0| := by
    unfold balancedParity
    rw [abs_mul,abs_pow,abs_neg,abs_one,one_pow,one_mul]
  apply (div_le_one (oddParityKappa_pos r)).mpr
  exact (le_abs_self _).trans (habs.symm ▸ h)

lemma scalarF0_le_one (a:ℝ) (ha:0<a) : scalarF0 a≤1 := by
  exact le_of_tendsto (balancedParity_normalized_tendsto a ha)
    (Eventually.of_forall (fun r=>balancedParity_normalized_le_one r a))

end NeuralGeneralization.OnlineLowerTanh
