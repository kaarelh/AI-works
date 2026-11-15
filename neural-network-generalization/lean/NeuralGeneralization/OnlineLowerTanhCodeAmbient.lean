import NeuralGeneralization.OnlineLowerTanhCodeAmbientCoordinates
import NeuralGeneralization.OnlineLowerTanhCodeAmbientJensen

/-! The exact retained-code theorem on arbitrary larger Boolean cubes. -/
noncomputable section
open scoped BigOperators Classical
namespace NeuralGeneralization.OnlineLowerTanh
open OnlineLower OnlineLowerRelu OnlineLowerGeometry ConcreteModel

/-- Conditioning on any number of unused coordinates preserves the exact
support-stability constant. The best retained support is fixed before conditioning. -/
theorem ambient_code_stability_of_canonical {p d k : ℕ}
    (size : Fin p→Bool→ℕ) (e : Fin d ≃ Fin (carrierDimension size) ⊕ Fin k)
    (A : Finset (Fin p→Bool)) (hA : A.Nonempty) (K : ℝ) (hK : 4 ≤ K)
    (hcode : ∀ b : ℝ,∀ u : Fin (carrierDimension size)→ℝ,
      carrierCodeMass size A (carrierBalancedCost size) b u ≤ Real.sqrt (b^2+incomingEnergy u) ∧
      ∃θ∈A,b^2+(∑i∈(carrierTransversal size θ)ᶜ,u i^2)≤K*Real.sqrt (b^2+incomingEnergy u)*
        (Real.sqrt (b^2+incomingEnergy u)-carrierCodeMass size A (carrierBalancedCost size) b u))
    (b : ℝ) (u : Fin d→ℝ) :
    ambientCarrierCodeMass size e A b u ≤ Real.sqrt (b^2+incomingEnergy u) ∧
    ∃θ∈A,b^2+(∑i∈(ambientSupport e (carrierTransversal size θ))ᶜ,u i^2)≤
      K*Real.sqrt (b^2+incomingEnergy u)*
        (Real.sqrt (b^2+incomingEnergy u)-ambientCarrierCodeMass size e A b u) := by
  let v := ambientActiveWeights e u
  let z := ambientExtraWeights e u
  let R : Cube k→ℝ := fun y=>Real.sqrt ((b+incomingLinear z y)^2+incomingEnergy v)
  let q : Cube k→ℝ := fun y=>carrierCodeMass size A (carrierBalancedCost size) (b+incomingLinear z y) v
  obtain ⟨θ,hθ,hmin⟩ := A.exists_min_image (fun θ=>∑i∈(carrierTransversal size θ)ᶜ,v i^2) hA
  let E : ℝ := ∑i∈carrierTransversal size θ,v i^2
  have hE : 0≤E := Finset.sum_nonneg (fun i _=>sq_nonneg _)
  have hpart : E+(∑i∈(carrierTransversal size θ)ᶜ,v i^2)=incomingEnergy v :=
    Finset.sum_add_sum_compl (carrierTransversal size θ) (fun i=>v i^2)
  have hEtotal : E ≤ incomingEnergy v := by
    have hh : 0≤∑i∈(carrierTransversal size θ)ᶜ,v i^2:=Finset.sum_nonneg (fun i _=>sq_nonneg _)
    linarith
  have hR2 (y : Cube k) : R y^2=(b+incomingLinear z y)^2+incomingEnergy v :=
    Real.sq_sqrt (add_nonneg (sq_nonneg _) (incomingEnergy_nonneg _))
  have hlocal (y : Cube k) : R y^2-E≤K*R y*(R y-q y) := by
    obtain ⟨ψ,hψ,hh⟩:=(hcode (b+incomingLinear z y) v).2
    have hmin' := hmin ψ hψ
    rw [hR2]
    change _≤K*R y*(R y-q y) at hh
    linarith
  have hmean : (∑y:Cube k,R y^2)/(Fintype.card (Cube k):ℝ)=(Real.sqrt (b^2+incomingEnergy u))^2 := by
    simp_rw [hR2]
    rw [Real.sq_sqrt (add_nonneg (sq_nonneg _) (incomingEnergy_nonneg _))]
    change finiteAverage (fun y:Cube k=>(b+incomingLinear z y)^2+incomingEnergy v)=_
    rw [finiteAverage_add,finiteAverage_const,←cubeMean_eq_finiteAverage,affine_secondMoment]
    rw [ambient_energy_split e]
    dsimp [z,v]
    ring
  have hh := support_stability_finite_average_nonnegative K E
    (Real.sqrt (b^2+incomingEnergy u)) (ambientCarrierCodeMass size e A b u) R q
    hK hE (Real.sqrt_nonneg _)
    (fun y=>Real.sqrt_nonneg _) (fun y=>by rw [hR2];nlinarith [sq_nonneg (b+incomingLinear z y)])
    (fun y=>(hcode (b+incomingLinear z y) v).1) hlocal hmean
    (ambient_codeMass_le_conditioned size e A b u)
  refine ⟨hh.1,θ,hθ,?_⟩
  have he : (Real.sqrt (b^2+incomingEnergy u))^2-E=
      b^2+(∑i∈(ambientSupport e (carrierTransversal size θ))ᶜ,u i^2) := by
    rw [Real.sq_sqrt (add_nonneg (sq_nonneg _) (incomingEnergy_nonneg _)),
      ambient_outside_energy,ambient_energy_split e]
    dsimp [v] at hpart
    linarith
  simpa only [he] using hh.2

def ambientRetainedOddSupports {p d k : ℕ} (size : Fin p→Bool→ℕ)
    (e : Fin d ≃ Fin (carrierDimension size) ⊕ Fin k)
    (A : Finset (Fin p→Bool)) : Finset (Finset (Fin d)) :=
  Finset.univ.filter (fun S=>Odd S.card ∧ ∃θ∈A,S⊆ambientSupport e (carrierTransversal size θ))

lemma ambient_projection_le_support_energy {p d k : ℕ}
    (size : Fin p→Bool→ℕ) (e : Fin d ≃ Fin (carrierDimension size) ⊕ Fin k)
    (A : Finset (Fin p→Bool)) (θ : Fin p→Bool) (hθ : θ∈A) (b : ℝ) (u : Fin d→ℝ) :
    uniformCubeMean (fun x=>(Real.tanh (cubeAffine b u x)-
      fourierProject (ambientRetainedOddSupports size e A)
        (fun x=>Real.tanh (cubeAffine b u x)) x)^2)≤
      b^2+∑i∈(ambientSupport e (carrierTransversal size θ))ᶜ,u i^2 := by
  let T:=ambientSupport e (carrierTransversal size θ)
  let v:Fin d→ℝ:=fun i=>if i∈T then u i else 0
  have hv:∀i,i∉T→v i=0:=by intro i hi;simp [v,hi]
  have hface:∀S,S∉ambientRetainedOddSupports size e A→
      walshCoefficients (fun x=>Real.tanh (cubeAffine 0 v x)) S=0 := by
    intro S hS
    by_cases ho:Odd S.card
    · apply tanh_walsh_zero_outside v T S hv
      intro hsub
      exact hS (Finset.mem_filter.mpr ⟨Finset.mem_univ _,ho,θ,hθ,hsub⟩)
    · exact tanh_walsh_zero_even v S (Nat.not_odd_iff_even.mp ho)
  have hh:=(projection_residual_le_comparison (ambientRetainedOddSupports size e A)
    (fun x=>Real.tanh (cubeAffine b u x)) (fun x=>Real.tanh (cubeAffine 0 v x)) hface).trans
      (tanh_neuron_l2_difference_le b 0 u v)
  have he:(∑i,(u i-v i)^2)=∑i∈Tᶜ,u i^2 := by
    simp only [v]
    simp_rw [sub_ite,sub_self,sub_zero,ite_pow,zero_pow (by norm_num : 2≠0)]
    rw [Finset.sum_ite]
    simp only [Finset.sum_const_zero,zero_add]
    congr 1;ext i;simp
  simpa only [sub_zero,he] using hh

/-- Arbitrary ambient dimensions and coordinate placements, with the literal
optimized balanced weights and exactly the manuscript's 2S constant. -/
theorem retainedCarrier_code_arbitrary_ambient_paper :
    ∃k₀ p₀:ℕ,1≤k₀ ∧ 3≤p₀ ∧
      ∀p r:ℕ,p₀≤p → (k₀:ℝ)*(Real.log ((p:ℝ)+2))^2≤(2*r:ℕ) →
      ∀size:Fin p→Bool→ℕ,(∀i s,2*r≤size i s) → (∀i s,size i s≤4*r) →
      (∀i s,Even (size i s)) →
      ∀A:Finset (Fin p→Bool),A.Nonempty →
      ∀W:ℝ,(∀θ∈A,carrierBalancedCost size θ≤W) →
      ∀d k:ℕ,∀e:Fin d ≃ Fin (carrierDimension size) ⊕ Fin k,
      ∀b:ℝ,∀u:Fin d→ℝ,
      ambientCarrierCodeMass size e A b u≤Real.sqrt (b^2+incomingEnergy u) ∧
      (∃θ∈A,b^2+(∑i∈(ambientSupport e (carrierTransversal size θ))ᶜ,u i^2)≤
        2*max 2 (96*Real.sqrt 6*W^2)*Real.sqrt (b^2+incomingEnergy u)*
          (Real.sqrt (b^2+incomingEnergy u)-ambientCarrierCodeMass size e A b u)) ∧
      uniformCubeMean (fun x=>(Real.tanh (cubeAffine b u x)-
        fourierProject (ambientRetainedOddSupports size e A) (fun x=>Real.tanh (cubeAffine b u x)) x)^2)≤
        2*max 2 (96*Real.sqrt 6*W^2)*Real.sqrt (b^2+incomingEnergy u)*
          (Real.sqrt (b^2+incomingEnergy u)-ambientCarrierCodeMass size e A b u) := by
  obtain ⟨k₀,p₀,hk,hp,hcode⟩:=retainedCarrier_code_projection_paper
  refine ⟨k₀,p₀,hk,hp,?_⟩
  intro p r hpp hR size hlo hhi heven A hA W hW d k e b u
  have hh:=ambient_code_stability_of_canonical size e A hA
    (2*max 2 (96*Real.sqrt 6*W^2)) (by nlinarith [le_max_left (2:ℝ) (96*Real.sqrt 6*W^2)])
    (fun b u=>let h:=hcode p r hpp hR size hlo hhi heven A hA W hW b u;⟨h.1,h.2.1⟩) b u
  refine ⟨hh.1,hh.2,?_⟩
  obtain ⟨θ,hθ,hbound⟩:=hh.2
  exact (ambient_projection_le_support_energy size e A θ hθ b u).trans hbound

@[simp] lemma ambientSupport_card {d n k : ℕ} (e : Fin d ≃ Fin n ⊕ Fin k)
    (S : Finset (Fin n)) : (ambientSupport e S).card=S.card := by
  simp [ambientSupport]

lemma ambientCarrierCodeMass_eq_selected_of_supported {p d k : ℕ}
    (size : Fin p → Bool → ℕ) (e : Fin d ≃ Fin (carrierDimension size) ⊕ Fin k)
    (hsize : ∀ i s,1 ≤ size i s) (A : Finset (Fin p → Bool))
    (θ : Fin p → Bool) (hθ : θ ∈ A) (u : Fin d → ℝ)
    (hout : ∀ i,i ∉ ambientSupport e (carrierTransversal size θ) → u i=0) :
    ambientCarrierCodeMass size e A 0 u =
      carrierBalancedCost size θ*|walshCoefficients (fun x=>Real.tanh (incomingLinear u x))
        (ambientSupport e (carrierTransversal size θ))| := by
  unfold ambientCarrierCodeMass
  rw [Finset.sum_eq_single θ]
  · simp only [zero_add]
  · intro t ht hne
    have hnot : ¬ambientSupport e (carrierTransversal size t) ⊆
        ambientSupport e (carrierTransversal size θ) := by
      simpa only [ambientSupport,Finset.map_subset_map] using
        carrierTransversal_not_subset_of_ne size hsize t θ hne
    have hz := tanh_walsh_zero_outside u (ambientSupport e (carrierTransversal size θ))
      (ambientSupport e (carrierTransversal size t)) hout hnot
    have hz' : walshCoefficients (fun x=>Real.tanh (incomingLinear u x))
        (ambientSupport e (carrierTransversal size t))=0 := by
      have he : cubeCoordinateSign = labelReal := by funext b; cases b <;> rfl
      simpa only [cubeAffine,zero_add,incomingLinear,he] using hz
    simp only [zero_add,hz',abs_zero,mul_zero]
  · exact fun h=>False.elim (h hθ)

/-- Every retained orientation supplies an actual positive-radius attaining
ambient atom, with all unused coordinates set to zero. -/
theorem ambient_balanced_code_attainment {p d k : ℕ}
    (size : Fin p → Bool → ℕ) (e : Fin d ≃ Fin (carrierDimension size) ⊕ Fin k)
    (hsize : ∀ i s,1 ≤ size i s) (heven : ∀ i s,Even (size i s))
    (A : Finset (Fin p → Bool)) (θ : Fin p → Bool) (hθ : θ ∈ A) :
    ∃ u : Fin d → ℝ,0 < Real.sqrt (incomingEnergy u) ∧
      ambientCarrierCodeMass size e A 0 u=Real.sqrt (incomingEnergy u) := by
  let T := ambientSupport e (carrierTransversal size θ)
  let u : Fin d → ℝ := fun i=>if i∈T then balancedGain (T.card/2) else 0
  have hodd : Odd T.card := by
    simpa only [T,ambientSupport_card] using carrierTransversal_odd size heven θ
  have hout : ∀ i,i∉T → u i=0 := by intro i hi;simp only [u,if_neg hi]
  have hbalance : ∀ i∈T,|u i|=balancedGain (T.card/2) := by
    intro i hi
    simp only [u,if_pos hi,abs_of_pos (balancedGain_pos _)]
  obtain ⟨i,hi⟩ := Finset.card_pos.mp hodd.pos
  have hterm : 0 < (u i)^2 := by
    simp only [u,if_pos hi]
    exact sq_pos_of_pos (balancedGain_pos _)
  have henergy : 0 < incomingEnergy u := hterm.trans_le
    (Finset.single_le_sum (s:=Finset.univ) (f:=fun j=>u j^2)
      (fun j _=>sq_nonneg _) (Finset.mem_univ i))
  refine ⟨u,Real.sqrt_pos.mpr henergy,?_⟩
  rw [ambientCarrierCodeMass_eq_selected_of_supported size e hsize A θ hθ u hout]
  simpa only [carrierBalancedCost,T,ambientSupport_card] using
    sharp_selected_balanced_attains T hodd u hout hbalance

/-- The literal retained-code theorem, including both directions of equality,
for arbitrary ambient dimension, arbitrary unused coordinates, and arbitrary
coordinate placement. All weights are the actual optimized balanced costs. -/
theorem retainedCarrier_code_arbitrary_ambient_paper_with_equality :
    ∃ k₀ p₀ : ℕ,1 ≤ k₀ ∧ 3 ≤ p₀ ∧
      ∀ p r : ℕ,p₀ ≤ p → (k₀:ℝ)*(Real.log ((p:ℝ)+2))^2 ≤ (2*r:ℕ) →
      ∀ size : Fin p → Bool → ℕ,(∀ i s,2*r ≤ size i s) → (∀ i s,size i s ≤ 4*r) →
      (∀ i s,Even (size i s)) →
      ∀ A : Finset (Fin p → Bool),A.Nonempty →
      ∀ W : ℝ,(∀ θ∈A,carrierBalancedCost size θ ≤ W) →
      ∀ d k : ℕ,∀ e : Fin d ≃ Fin (carrierDimension size) ⊕ Fin k,
      ∀ bias : ℝ,∀ u : Fin d → ℝ,
        let ρ := Real.sqrt (bias^2+incomingEnergy u)
        let Q := ambientCarrierCodeMass size e A bias u
        Q ≤ ρ ∧
        (∃ θ∈A,bias^2+(∑i∈(ambientSupport e (carrierTransversal size θ))ᶜ,u i^2) ≤
          2*max 2 (96*Real.sqrt 6*W^2)*ρ*(ρ-Q)) ∧
        uniformCubeMean (fun x=>(Real.tanh (cubeAffine bias u x)-
          fourierProject (ambientRetainedOddSupports size e A)
            (fun x=>Real.tanh (cubeAffine bias u x)) x)^2) ≤
          2*max 2 (96*Real.sqrt 6*W^2)*ρ*(ρ-Q) ∧
        (0 < ρ → (Q=ρ ↔ bias=0 ∧ ∃ θ∈A,
          (∀ i,i ∉ ambientSupport e (carrierTransversal size θ) → u i=0) ∧
          ∀ i∈ambientSupport e (carrierTransversal size θ),
            |u i|=balancedGain ((carrierTransversal size θ).card/2))) := by
  obtain ⟨k₀,p₁,hk,hp,hcode⟩ := retainedCarrier_code_arbitrary_ambient_paper
  obtain ⟨n₀,hequality⟩ := exists_sharp_affine_equality_threshold
  refine ⟨k₀,max p₁ n₀,hk,hp.trans (le_max_left _ _),?_⟩
  intro p r hpp hR size hlo hhi heven A hA W hW d k e bias u
  have hpp₁ : p₁ ≤ p := (le_max_left _ _).trans hpp
  have hp3 : 3 ≤ p := hp.trans hpp₁
  have hlog : 0 < Real.log ((p:ℝ)+2) := Real.log_pos (by exact_mod_cast (show 1<p+2 by omega))
  have hrR : (0:ℝ) < (2*r:ℕ) := lt_of_lt_of_le
    (mul_pos (by exact_mod_cast (show 0<k₀ by omega)) (sq_pos_of_pos hlog)) hR
  have hrnat : 0 < 2*r := by exact_mod_cast hrR
  have hsize : ∀ i s,1 ≤ size i s := fun i s=>by have := hlo i s;omega
  have hdegree (θ : Fin p → Bool) : n₀ ≤ (ambientSupport e (carrierTransversal size θ)).card := by
    rw [ambientSupport_card,carrierTransversal_card]
    have hn : n₀ ≤ p := (le_max_right _ _).trans hpp
    have hs := Finset.sum_le_sum (s:=Finset.univ) (fun i _=>hsize i (θ i))
    simp only [Finset.sum_const,Finset.card_univ,Fintype.card_fin,smul_eq_mul,mul_one] at hs
    omega
  have hodd (θ : Fin p → Bool) : Odd (ambientSupport e (carrierTransversal size θ)).card := by
    simpa only [ambientSupport_card] using carrierTransversal_odd size heven θ
  have hh := hcode p r hpp₁ hR size hlo hhi heven A hA W hW d k e bias u
  refine ⟨hh.1,hh.2.1,hh.2.2,?_⟩
  intro hρ
  constructor
  · intro heq
    obtain ⟨θ,hθ,hstab⟩ := hh.2.1
    rw [heq,sub_self,mul_zero] at hstab
    have hsum : 0 ≤ ∑i∈(ambientSupport e (carrierTransversal size θ))ᶜ,u i^2 :=
      Finset.sum_nonneg (fun i _=>sq_nonneg _)
    have hb : bias=0 := by nlinarith [sq_nonneg bias]
    have hout : ∀ i,i ∉ ambientSupport e (carrierTransversal size θ) → u i=0 := by
      intro i hi
      have hv := Finset.single_le_sum (s:=(ambientSupport e (carrierTransversal size θ))ᶜ)
        (f:=fun i=>u i^2) (fun j _=>sq_nonneg _) (Finset.mem_compl.mpr hi)
      nlinarith [sq_nonneg bias,sq_nonneg (u i)]
    refine ⟨hb,θ,hθ,hout,?_⟩
    have hm := ambientCarrierCodeMass_eq_selected_of_supported size e hsize A θ hθ u hout
    rw [hb,hm] at heq
    have hc := (hequality d (ambientSupport e (carrierTransversal size θ))
      (hdegree θ) (hodd θ) u 0).2
    have heq' := (hc (by simpa only [hb] using hρ)
      (by simpa only [zero_add,carrierBalancedCost,ambientSupport_card] using heq)).2.2
    simpa only [ambientSupport_card] using heq'
  · rintro ⟨rfl,θ,hθ,hout,hbalance⟩
    rw [ambientCarrierCodeMass_eq_selected_of_supported size e hsize A θ hθ u hout]
    simpa only [zero_pow (by norm_num : (2:ℕ)≠0),zero_add,carrierBalancedCost,ambientSupport_card] using
      sharp_selected_balanced_attains (ambientSupport e (carrierTransversal size θ))
        (hodd θ) u hout (by simpa only [ambientSupport_card] using hbalance)

end NeuralGeneralization.OnlineLowerTanh
