import NeuralGeneralization.BatchTwoActivationProductNormalizationEnergy
import NeuralGeneralization.BatchTwoActivationSharpTeacher

/-! Sharp actual energy sublevels embed in the width-independent auxiliary
class at the manuscript's product/AM-GM scale. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1000000
open scoped BigOperators RealInnerProductSpace
namespace NeuralGeneralization.BatchTwoActivation
open ConcreteModel

theorem sharpProductScale_pos {d r : ℕ} {ℓ K:ℝ} (hd:0<d) (hℓ:0<ℓ) (hK:0<K):
    0<sharpProductScale d r ℓ K:=by
  unfold sharpProductScale
  have hdR:0<(d:ℝ):=by exact_mod_cast hd
  positivity

theorem physicalProduct_scaled_le {d N r : ℕ} {φ:ℝ→ℝ} {ℓ K:ℝ}
    (hd:0<d) (hN:0<N) (hφ:zeroLipschitzActivation ℓ φ) (hℓ:0<ℓ)
    (w:Weights d N r) (hK:0<K) (hw:weightedSquaredNorm w≤K):
    ℓ^(r+1)*physicalProduct hN hφ w≤sharpProductScale d r ℓ K:=by
  have hh:=mul_le_mul_of_nonneg_left (physicalProduct_le hd hN hφ w hK hw)
    (pow_nonneg hℓ.le (r+1))
  apply hh.trans_eq
  unfold sharpProductScale
  ring

def AuxiliaryNetwork.scaleReadout {d H:ℕ} (W:AuxiliaryNetwork d H) {a:ℝ}
    (ha:0≤a) (ha1:a≤1):AuxiliaryNetwork d H:={ W with
  readout:=a • W.readout
  readout_norm:=by
    rw [norm_smul,Real.norm_eq_abs,abs_of_nonneg ha]
    exact (mul_le_mul_of_nonneg_left W.readout_norm ha).trans (by simpa using ha1) }

theorem auxiliary_scaleReadout_state {d H:ℕ} (W:AuxiliaryNetwork d H) {a:ℝ}
    (ha:0≤a) (ha1:a≤1) (x:Cube d) (s:ℕ):
    auxiliaryFamilyState (fun _:Unit=>W.scaleReadout ha ha1) (fun _:Fin 1=>x) s () 0=
      auxiliaryFamilyState (fun _:Unit=>W) (fun _:Fin 1=>x) s () 0:=by
  rfl

theorem exists_sharp_auxiliary_normalization {d N r : ℕ} {φ:ℝ→ℝ} {ℓ K:ℝ}
    (hd:0<d) (hN:0<N) (hφ:zeroLipschitzActivation ℓ φ) (hℓ:0<ℓ)
    (w:Weights d N r) (hK:0<K) (hw:weightedSquaredNorm w≤K):
    ∃W:AuxiliaryNetwork d (r+1),∀x,networkOutput φ w x=auxiliaryOutput W (sharpProductScale d r ℓ K) x:=by
  obtain ⟨V,hV⟩:=physicalProductNetwork_normalization hN hφ hℓ w
  let P:=ℓ^(r+1)*physicalProduct hN hφ w
  let Q:=sharpProductScale d r ℓ K
  have hP:0≤P:=mul_nonneg (pow_nonneg hℓ.le _) (physicalProduct_nonneg hN hφ w)
  have hQ:0<Q:=sharpProductScale_pos hd hℓ hK
  have hPQ:P≤Q:=physicalProduct_scaled_le hd hN hφ hℓ w hK hw
  have ha:0≤P/Q:=div_nonneg hP hQ.le
  have ha1:P/Q≤1:=(div_le_one hQ).mpr hPQ
  refine ⟨V.scaleReadout ha ha1,?_⟩
  intro x
  rw [hV x]
  unfold auxiliaryOutput
  rw [auxiliary_scaleReadout_state V ha ha1]
  change P*⟪V.readout,_⟫=Q*⟪(P/Q) • V.readout,_⟫
  rw [real_inner_smul_left]
  field_simp

theorem energy_network_mem_sharp_auxiliary {d N r : ℕ} {φ:ℝ→ℝ} {ℓ K:ℝ}
    (hd:0<d) (hN:0<N) (hφ:zeroLipschitzActivation ℓ φ) (hℓ:0<ℓ)
    (w:Weights d N r) (hK:0<K) (hw:weightedSquaredNorm w≤K)
    (f:BooleanFunction d) (hf:∀x,(1/2:ℝ)≤labelReal (f x)*networkOutput φ w x):
    f∈auxiliaryFunctions d (r+1) (sharpProductScale d r ℓ K):=by
  classical
  obtain ⟨W,hW⟩:=exists_sharp_auxiliary_normalization hd hN hφ hℓ w hK hw
  apply Finset.mem_filter.mpr
  refine ⟨Finset.mem_univ _,W,?_⟩
  intro x
  rw [←hW x]
  exact hf x

theorem lowEnergyFunctions_subset_sharp_auxiliary {d C N r : ℕ} {φ:ℝ→ℝ} {ℓ:ℝ}
    (hd:0<d) (hφ:zeroLipschitzActivation ℓ φ) (hℓ:0<ℓ)
    (f:BooleanFunction d) (hc:realizesAtComplexity (r:=r) φ f C) (hCN:C≤N):
    lowEnergyFunctions (N:=N) (r:=r) φ f⊆
      auxiliaryFunctions d (r+1) (sharpProductScale d r ℓ (sharpTeacherBudget d C r+1)):=by
  intro g hg
  obtain ⟨w,hw,hcost⟩:=lowEnergyFunctions_sharp_norm_witness φ f g hc hCN hg
  have hN:0<N:=lt_of_lt_of_le (Nat.succ_le_iff.mp hc.1) hCN
  exact energy_network_mem_sharp_auxiliary hd hN hφ hℓ w
    (by linarith [sharpTeacherBudget_nonneg d C r]) hcost.le g (fun x=>(hw x).le)


theorem energyFunctions_subset_sharp_auxiliary {d r:ℕ} {φ:ℝ→ℝ} {ℓ K:ℝ}
    (hd:0<d) (hφ:zeroLipschitzActivation ℓ φ) (hℓ:0<ℓ) (hK:0<K):
    energyFunctions d r φ K⊆auxiliaryFunctions d (r+1) (sharpProductScale d r ℓ K):=by
  classical
  intro f hf
  obtain ⟨_,N,hN,w,hw,hm⟩:=Finset.mem_filter.mp hf
  exact energy_network_mem_sharp_auxiliary hd hN hφ hℓ w hK hw f hm

end NeuralGeneralization.BatchTwoActivation
