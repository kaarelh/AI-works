import NeuralGeneralization.BatchTwoGramPowerDerivative
import Mathlib.Analysis.Calculus.Deriv.MeanValue

/-! A one-step trace decrease from a controlled rank-one derivative. -/
noncomputable section
set_option autoImplicit false
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1000000
open scoped BigOperators Matrix
namespace NeuralGeneralization.BatchTwoGramPower
open Matrix
variable {ι : Type*} [Fintype ι] [DecidableEq ι]

def momentDrop (A : Matrix ι ι ℝ) (u : ι→ℝ) (p : ℕ) : ℝ :=
  ∑j∈Finset.range p,powerMoment A u (p-1-j)*powerMoment A u j

theorem momentDrop_nonneg (A : Matrix ι ι ℝ) (hA : A.PosSemidef) (u : ι→ℝ) (p : ℕ) :
    0≤momentDrop A u p := Finset.sum_nonneg fun j _=>
  mul_nonneg (powerMoment_nonneg A hA u _) (powerMoment_nonneg A hA u _)

theorem momentDrop_le_half (A : Matrix ι ι ℝ) (hA : A.PosSemidef) (u : ι→ℝ)
    {R : ℝ} (hu : (∑i,u i^2)≤R) (p : ℕ)
    (hlower : ∀i,2*(p:ℝ)*R≤hA.1.eigenvalues i) :
    momentDrop A u p≤powerMoment A u p/2 := by
  by_cases hp : p=0
  · subst p
    simpa [momentDrop] using (div_nonneg (powerMoment_nonneg A hA u 0) (by norm_num : (0:ℝ)≤2))
  have he : p-1+1=p := by omega
  have hm := powerMoment_lower_shift A hA u hlower (p-1)
  rw [he] at hm
  have hsum : momentDrop A u p≤(p:ℝ)*R*powerMoment A u (p-1) := by
    unfold momentDrop
    calc
      _ ≤ ∑_j∈Finset.range p,R*powerMoment A u (p-1) := by
        apply Finset.sum_le_sum
        intro j hj
        have hj' := Finset.mem_range.mp hj
        have hh := powerMoment_product A hA u (p-1-j) j
        rw [show p-1-j+j=p-1 by omega] at hh
        exact hh.trans (mul_le_mul_of_nonneg_right hu (powerMoment_nonneg A hA u _))
      _ = _ := by simp; ring
  nlinarith only [hm,hsum]

theorem scalar_potential_descent (F g D : ℝ→ℝ) {k : ℝ} (hk : 0≤k)
    (hF : ∀t,HasDerivAt F (-k*g t) t) (hg : ∀t,HasDerivAt g (-D t) t)
    (hD : ∀t∈Set.Icc (0:ℝ) 1,0≤D t ∧ D t≤g t/2) :
    F 1≤F 0-3*k*g 0/4 := by
  have hgDiff : Differentiable ℝ g := fun t=>(hg t).differentiableAt
  have hgMono : AntitoneOn g (Set.Icc (0:ℝ) 1) := by
    apply antitoneOn_of_deriv_nonpos (convex_Icc _ _) hgDiff.continuous.continuousOn hgDiff.differentiableOn
    intro t ht
    rw [(hg t).deriv]
    exact neg_nonpos.mpr (hD t (interior_subset ht)).1
  have hgUpper (t : ℝ) (ht : t∈Set.Icc (0:ℝ) 1) : g t≤g 0 :=
    hgMono (by simp) ht ht.1
  let f : ℝ→ℝ := fun t=>g t+t*(g 0/2)
  have hf (t : ℝ) : HasDerivAt f (-D t+g 0/2) t := by
    simpa only [f,Pi.add_apply,id_eq,one_mul] using! (hg t).add ((hasDerivAt_id t).mul_const (g 0/2))
  have hfDiff : Differentiable ℝ f := fun t=>(hf t).differentiableAt
  have hfMono : MonotoneOn f (Set.Icc (0:ℝ) 1) := by
    apply monotoneOn_of_deriv_nonneg (convex_Icc _ _) hfDiff.continuous.continuousOn hfDiff.differentiableOn
    intro t ht
    rw [(hf t).deriv]
    have ht' := interior_subset ht
    linarith [(hD t ht').2,hgUpper t ht']
  have hgLower (t : ℝ) (ht : t∈Set.Icc (0:ℝ) 1) : (1-t/2)*g 0≤g t := by
    have hh := hfMono (by simp) ht ht.1
    dsimp [f] at hh
    nlinarith only [hh]
  let v : ℝ→ℝ := fun t=>F t+k*g 0*(t-t^2/4)
  have hv (t : ℝ) : HasDerivAt v (-k*g t+k*g 0*(1-t/2)) t := by
    have hh := (hF t).add (((hasDerivAt_id t).sub ((hasDerivAt_pow 2 t).div_const 4)).const_mul (k*g 0))
    convert! hh using 1 <;> simp only [v,Pi.add_apply,id_eq,pow_one,Nat.cast_ofNat] <;> ring
  have hvDiff : Differentiable ℝ v := fun t=>(hv t).differentiableAt
  have hvMono : AntitoneOn v (Set.Icc (0:ℝ) 1) := by
    apply antitoneOn_of_deriv_nonpos (convex_Icc _ _) hvDiff.continuous.continuousOn hvDiff.differentiableOn
    intro t ht
    rw [(hv t).deriv]
    have hh := mul_le_mul_of_nonneg_left (hgLower t (interior_subset ht)) hk
    nlinarith only [hh]
  have hh := hvMono (by simp : (0:ℝ)∈Set.Icc (0:ℝ) 1) (by simp : (1:ℝ)∈Set.Icc (0:ℝ) 1) (by norm_num)
  dsimp [v] at hh
  nlinarith only [hh]

theorem trace_power_rankOne_step (A : Matrix ι ι ℝ) (u : ι→ℝ) {R : ℝ}
    (hu : (∑i,u i^2)≤R) (p : ℕ)
    (hpath : ∀t∈Set.Icc (0:ℝ) 1,(rankOnePath A u t).PosSemidef)
    (hlower : ∀t,(ht : t∈Set.Icc (0:ℝ) 1)→∀i,
      2*(p:ℝ)*R≤(hpath t ht).1.eigenvalues i) :
    Matrix.trace ((A-vecMulVec u u)^(p+1))≤Matrix.trace (A^(p+1))-
      3*((p:ℝ)+1)*powerMoment A u p/4 := by
  have hh := scalar_potential_descent
    (fun t=>Matrix.trace (rankOnePath A u t^(p+1)))
    (fun t=>powerMoment (rankOnePath A u t) u p)
    (fun t=>momentDrop (rankOnePath A u t) u p) (by positivity : (0:ℝ)≤(p:ℝ)+1)
    (fun t=>by simpa using hasDerivAt_trace_power_path A u (p+1) t)
    (hasDerivAt_powerMoment_path A u p)
    (fun t ht=>⟨momentDrop_nonneg _ (hpath t ht) u p,momentDrop_le_half _ (hpath t ht) u hu p (hlower t ht)⟩)
  simpa [rankOnePath] using hh

end NeuralGeneralization.BatchTwoGramPower
