import NeuralGeneralization.OnlineLowerTanhCodeExact
import NeuralGeneralization.OnlineLowerTanhCodeExactSharpCore

/-! The manuscript's exact support constant, retained through code absorption. -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.OnlineLowerTanh

/-- The exact weighted code bound and quadratic support stability. The sharp
intrinsic parity theorem is the only analytic hypothesis, separately named
for every literal selected support. -/
theorem carrierCodeMass_exact_of_intrinsic_paper (K:ℝ) (hK:0<K) :
    ∃k₀ p₀:ℕ,1≤k₀ ∧ 3≤p₀ ∧
      ∀p r:ℕ,p₀≤p → (k₀:ℝ)*(Real.log ((p:ℝ)+2))^2≤(2*r:ℕ) →
      ∀size:Fin p→Bool→ℕ,(∀i s,2*r≤size i s) → (∀i s,Even (size i s)) →
      ∀A:Finset (Fin p→Bool),A.Nonempty → ∀w:(Fin p→Bool)→ℝ,
      (∀θ∈A,0≤w θ) → (∀θ∈A,w θ≤K*(p*(2*r):ℕ)) →
      (∀θ∈A,IntrinsicParityBound (carrierTransversal size θ).card (w θ)) →
      ∀W:ℝ, (∀θ∈A,w θ≤W) →
      ∀bias:ℝ,∀u:Fin (carrierDimension size)→ℝ,
      carrierCodeMass size A w bias u≤Real.sqrt (bias^2+incomingEnergy u) ∧
      ∃θ∈A,bias^2+(∑i∈(carrierTransversal size θ)ᶜ,u i^2)≤
        2*max 2 (96*Real.sqrt 6*W^2)*Real.sqrt (bias^2+incomingEnergy u)*
          (Real.sqrt (bias^2+incomingEnergy u)-carrierCodeMass size A w bias u) := by
  obtain ⟨kl,pl,hkl,hpl,hloc⟩:=actual_tanh_code_orientation_localization (1/2) K (by norm_num) hK 12
  obtain ⟨kt,pt,hkt,htail⟩:=polynomial_tails_logSquare 1 1 0 16 (by norm_num) (by norm_num) (by norm_num) 0 0
  let M:=8*K^2*codeUpperScaleConstant^2/(1/2:ℝ)^2
  let B:=2+288*K^2
  obtain ⟨d₀,hd₀⟩:=exists_nat_ge (max 2 (max K (max B (M^2))))
  let k₀:=max kl kt
  let p₀:=max pl (max pt d₀)
  refine ⟨k₀,p₀,hkl.trans (le_max_left _ _),hpl.trans (le_max_left _ _),?_⟩
  intro p r hp hR size hsize heven A hA w hw0 hw hsharp W hW bias u
  have hplp:pl≤p := (le_max_left _ _).trans hp
  have hpt:pt≤p := ((le_max_left _ _).trans (le_max_right _ _)).trans hp
  have hd₀p:d₀≤p := ((le_max_right _ _).trans (le_max_right _ _)).trans hp
  have hp3:3≤p := hpl.trans hplp
  have hthreshold (k:ℕ) (hk:k≤k₀) : (k:ℝ)*(Real.log ((p:ℝ)+2))^2≤(2*r:ℕ) :=
    (mul_le_mul_of_nonneg_right (by exact_mod_cast hk) (sq_nonneg _)).trans hR
  have h16r:(16:ℝ)≤(2*r:ℕ) := (htail p (2*r) hpt (hthreshold kt (le_max_right _ _))).1
  have h16:16≤2*r := by exact_mod_cast h16r
  have hr:1≤r := by omega
  let D:ℝ:=(p*(2*r):ℕ)
  let ρ:=Real.sqrt (bias^2+incomingEnergy u)
  let Q:=carrierCodeMass size A w bias u
  have hD0:0<D := by dsimp [D];positivity
  have hpD:(p:ℝ)≤D := by dsimp [D];exact_mod_cast (show p≤p*(2*r) by nlinarith)
  have hlarge:max 2 (max K (max B (M^2)))≤D := hd₀.trans ((show (d₀:ℝ)≤p by exact_mod_cast hd₀p).trans hpD)
  have hD2:2≤D := (le_max_left _ _).trans hlarge
  have hKD:K≤D := ((le_max_left _ _).trans (le_max_right _ _)).trans hlarge
  have hBD:B≤D := ((le_max_left _ _).trans ((le_max_right _ _).trans (le_max_right _ _))).trans hlarge
  have hMD:M^2≤D := ((le_max_right _ _).trans ((le_max_right _ _).trans (le_max_right _ _))).trans hlarge
  have hρ0:0≤ρ := Real.sqrt_nonneg _
  have henergy0:0≤bias^2+incomingEnergy u := add_nonneg (sq_nonneg _) (incomingEnergy_nonneg u)
  have hρsq:ρ^2=bias^2+incomingEnergy u := Real.sq_sqrt henergy0
  have hQ0:0≤Q := carrierCodeMass_nonneg size A w hw0 bias u
  have hW0:0≤W := by obtain ⟨θ,hθ⟩:=hA;exact (hw0 θ hθ).trans (hW θ hθ)
  have hconst:2≤2*max 2 (96*Real.sqrt 6*W^2) := by nlinarith [le_max_left (2:ℝ) (96*Real.sqrt 6*W^2)]
  have hsharpOld (v:ℝ) : max 2 (96*Real.sqrt 6*v^2)≤max 2 (288*v^2) := by
    apply max_le_max le_rfl
    have hs:Real.sqrt 6≤3 := by nlinarith [Real.sq_sqrt (by norm_num : (0:ℝ)≤6),Real.sqrt_nonneg 6]
    nlinarith [mul_le_mul_of_nonneg_right hs (sq_nonneg v)]
  by_cases hpos:0<bias^2+incomingEnergy u
  · have hρpos:0<ρ := Real.sqrt_pos.mpr hpos
    by_cases hcomp:(1/2:ℝ)*ρ≤Q
    · have hscale:=carrierCodeMass_competitive_scale (by omega : 2≤p) hr (by nlinarith : 6≤p*(2*r))
        size hsize heven A w (1/2) K (by norm_num) hK hw0 hw bias u hpos hcomp
      have hs:0<Real.sqrt ((p*r:ℕ):ℝ) := by positivity
      have hrM:ρ≤M*Real.sqrt ((p*r:ℕ):ℝ) := (div_le_iff₀ hs).mp hscale.2
      have hrD:ρ≤D := radius_le_polynomial ρ M (p*r:ℕ) D hρ0 (by dsimp [M];positivity)
        (by positivity) hD0.le (by dsimp [D];exact_mod_cast (show p*r≤p*(2*r) by nlinarith)) hMD hrM
      obtain ⟨θ,hθ,hoff⟩:=hloc p r hplp (hthreshold kl (le_max_left _ _)) size hsize heven A w hw0 hw bias u hpos hcomp
      have hwD:∀t∈A,w t≤D^2 := fun t ht=>(hw t ht).trans (by nlinarith [mul_le_mul_of_nonneg_right hKD hD0.le])
      have hSt:=code_support_constant_bound D K (w θ) (by linarith) hK.le (hw0 θ hθ) (hw θ hθ)
      have hS:max 2 (288*(w θ)^2)≤D^3 := hSt.trans (by
        have hh:=mul_le_mul_of_nonneg_right hBD (sq_nonneg D)
        dsimp [B] at hh
        nlinarith only [hh])
      have hcore:=carrierCodeMass_exact_core_paper size h16 hsize heven A w hw0 hwD bias u θ hθ
        (hsharp θ hθ) hD2 hρpos hrD ((hsharpOld (w θ)).trans hS) hoff
      refine ⟨hcore.1,θ,hθ,hcore.2.trans ?_⟩
      have hgap:0≤ρ-Q := sub_nonneg.mpr hcore.1
      have hSW:max 2 (96*Real.sqrt 6*(w θ)^2)≤max 2 (96*Real.sqrt 6*W^2) := by
        apply max_le_max le_rfl
        apply mul_le_mul_of_nonneg_left _ (by positivity)
        exact (sq_le_sq₀ (hw0 θ hθ) hW0).mpr (hW θ hθ)
      exact mul_le_mul_of_nonneg_right
        (mul_le_mul_of_nonneg_right (mul_le_mul_of_nonneg_left hSW (by norm_num)) hρ0) hgap
    · have hsmall:Q≤ρ/2 := by linarith
      obtain ⟨θ,hθ⟩:=hA
      have hv:=carrier_support_energy_le size θ bias u
      refine ⟨by linarith,θ,hθ,?_⟩
      have hgap:0≤ρ-Q := by linarith
      have hm:=mul_le_mul_of_nonneg_right (mul_le_mul_of_nonneg_right hconst hρ0) hgap
      nlinarith [sq_nonneg ρ]
  · have hezero:bias^2+incomingEnergy u=0 := by linarith
    have hrzero:ρ=0 := by dsimp [ρ];rw [hezero,Real.sqrt_zero]
    have hmass:Q≤0 := by
      apply Finset.sum_nonpos
      intro θ hθ
      have h:=intrinsicParityBound_physical_support (carrierTransversal size θ)
        (carrierTransversal_odd size heven θ) (w θ) (hw0 θ hθ) (hsharp θ hθ) u bias
      exact h.1.trans_eq hrzero
    obtain ⟨θ,hθ⟩:=hA
    have hv:=carrier_support_energy_le size θ bias u
    refine ⟨by change Q≤ρ;linarith,θ,hθ,?_⟩
    change bias^2+_≤2*max 2 (96*Real.sqrt 6*W^2)*ρ*(ρ-Q)
    rw [hrzero]
    simp only [mul_zero,zero_mul]
    linarith

end NeuralGeneralization.OnlineLowerTanh
