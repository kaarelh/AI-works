import NeuralGeneralization.OnlineLowerTanhFiniteParityOffSupport
import NeuralGeneralization.OnlineLowerTanhFiniteParityRails

/-! Local weighted-code assembly from a selected quadratic gap and cubic cancellation. -/
noncomputable section
open scoped BigOperators Topology Classical
open Filter Set
namespace NeuralGeneralization.OnlineLowerTanh
open OnlineLower OnlineLowerRelu ConcreteModel

def affineEuclideanRadius {d : ℕ} (z : Fin (d+1)→ℝ) : ℝ := Real.sqrt (∑i,z i^2)

def affineSupportCoefficient {d : ℕ} (A : Finset (Fin d)) (z : Fin (d+1)→ℝ) : ℝ :=
  walshCoefficients (fun x=>Real.tanh (z 0+incomingLinear (fun i=>z i.succ) x)) A

def weightedAffineCodeRatio {d : ℕ} (C : Finset (Finset (Fin d)))
    (weight : Finset (Fin d)→ℝ) (z : Fin (d+1)→ℝ) : ℝ :=
  (∑A∈C,weight A*|affineSupportCoefficient A z|)/affineEuclideanRadius z

lemma continuous_affineEuclideanRadius (d : ℕ) : Continuous (@affineEuclideanRadius d) := by
  unfold affineEuclideanRadius
  fun_prop

lemma weightedAffineCodeRatio_selected_add {d : ℕ} (C : Finset (Finset (Fin d)))
    (A : Finset (Fin d)) (hA : A∈C) (weight : Finset (Fin d)→ℝ) (z : Fin (d+1)→ℝ) :
    weightedAffineCodeRatio C weight z=
      weight A*(|affineSupportCoefficient A z|/affineEuclideanRadius z)+
        (∑B∈C.erase A,weight B*|affineSupportCoefficient B z|)/affineEuclideanRadius z := by
  unfold weightedAffineCodeRatio
  rw [←Finset.add_sum_erase C _ hA,add_div]
  ring

/-- General finite-family assembly; the final odd-rail theorem supplies the
selected quadratic gap from the actual finite-degree Hessian theorem. -/
theorem weightedAffineCodeRatio_strict_local_maximum_of_gap {d : ℕ}
    (C : Finset (Finset (Fin d))) (A : Finset (Fin d)) (hA : A∈C)
    (weight : Finset (Fin d)→ℝ) (hw : ∀B∈C,0≤weight B) (hwA : 0<weight A)
    (hthree : ∀B∈C.erase A,3≤(B\A).card)
    (z₀ : Fin (d+1)→ℝ) (hz₀ : ∀i,i∉A → z₀ i.succ=0)
    (hρ : 0<affineEuclideanRadius z₀)
    (hgap : ∃c>0,∀ᶠ z in 𝓝 z₀,
      |affineSupportCoefficient A z|/affineEuclideanRadius z ≤
        |affineSupportCoefficient A z₀|/affineEuclideanRadius z₀-c*‖z-z₀‖^2) :
    ∀ᶠ z in 𝓝 z₀,z≠z₀ → weightedAffineCodeRatio C weight z<weightedAffineCodeRatio C weight z₀ := by
  let f := fun z:Fin (d+1)→ℝ=>|affineSupportCoefficient A z|/affineEuclideanRadius z
  let rem := fun z:Fin (d+1)→ℝ=>∑B∈C.erase A,weight B*|affineSupportCoefficient B z|
  let M : ℝ := 27*∑B∈C.erase A,weight B
  have hM : 0≤M := mul_nonneg (by norm_num) (Finset.sum_nonneg (fun B hB=>hw B (Finset.mem_erase.mp hB).2))
  have hrem (z : Fin (d+1)→ℝ) : rem z≤M*‖z-z₀‖^3 :=
    affine_weighted_walsh_cubic_offsupport C A weight hw hthree z₀ z hz₀
  have hremzero : rem z₀=0 := by
    have hz := hrem z₀
    simp only [sub_self,norm_zero,zero_pow (by norm_num : (3:ℕ)≠0),mul_zero] at hz
    exact le_antisymm hz (Finset.sum_nonneg (fun B hB=>mul_nonneg (hw B (Finset.mem_erase.mp hB).2) (abs_nonneg _)))
  obtain ⟨c,hc,hc'⟩ := hgap
  have hr : 0<affineEuclideanRadius z₀/2 := by linarith
  have hrad : ∀ᶠ z in 𝓝 z₀,affineEuclideanRadius z₀/2≤affineEuclideanRadius z := by
    have hh := (continuous_affineEuclideanRadius d).continuousAt.eventually
      (Ioi_mem_nhds (show affineEuclideanRadius z₀/2<affineEuclideanRadius z₀ by linarith))
    exact hh.mono (fun z hz=>hz.le)
  have hstrict := strict_local_maximum_of_quadratic_cubic z₀ f rem affineEuclideanRadius
    (weight A) c M (affineEuclideanRadius z₀/2) hwA hc hM hr hc' hrad hrem
  filter_upwards [hstrict] with z hz hne
  rw [weightedAffineCodeRatio_selected_add C A hA weight z,
    weightedAffineCodeRatio_selected_add C A hA weight z₀]
  change weight A*f z+rem z/affineEuclideanRadius z<weight A*f z₀+rem z₀/affineEuclideanRadius z₀
  rw [hremzero,zero_div,add_zero]
  exact hz hne

end NeuralGeneralization.OnlineLowerTanh
