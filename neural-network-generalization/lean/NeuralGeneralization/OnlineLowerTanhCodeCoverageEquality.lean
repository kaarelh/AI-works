import NeuralGeneralization.OnlineLowerTanhCodeProjectionSharp
import NeuralGeneralization.OnlineLowerTanhEqualityAffine

/-! Equality and attainment in the literal sharp retained-carrier code theorem. -/
noncomputable section
open scoped BigOperators Classical
namespace NeuralGeneralization.OnlineLowerTanh
open OnlineLower OnlineLowerRelu OnlineLowerGeometry ConcreteModel

lemma carrierTransversal_not_subset_of_ne {p : ℕ} (size : Fin p → Bool → ℕ)
    (hsize : ∀ i s,1 ≤ size i s) (s t : Fin p → Bool) (hne : s ≠ t) :
    ¬carrierTransversal size s ⊆ carrierTransversal size t := by
  intro hsub
  have h := carrierTransversal_difference_card_lower size hsize t s
  rw [Finset.sdiff_eq_empty_iff_subset.mpr hsub,Finset.card_empty,mul_one] at h
  have he : changedRails t s=∅ := Finset.card_eq_zero.mp (Nat.eq_zero_of_le_zero h)
  apply hne
  funext i
  by_contra hi
  have hm : i ∈ changedRails t s := by simp [changedRails,Ne.symm hi]
  rw [he] at hm
  exact Finset.notMem_empty i hm

lemma carrierCodeMass_eq_selected_of_supported {p : ℕ} (size : Fin p → Bool → ℕ)
    (hsize : ∀ i s,1 ≤ size i s) (A : Finset (Fin p → Bool))
    (w : (Fin p → Bool) → ℝ) (θ : Fin p → Bool) (hθ : θ ∈ A)
    (u : Fin (carrierDimension size) → ℝ)
    (hout : ∀ i,i ∉ carrierTransversal size θ → u i=0) :
    carrierCodeMass size A w 0 u =
      w θ*|walshCoefficients (fun x=>Real.tanh (incomingLinear u x)) (carrierTransversal size θ)| := by
  unfold carrierCodeMass
  rw [Finset.sum_eq_single θ]
  · simp only [zero_add]
  · intro s hs hne
    have hz := tanh_walsh_zero_outside u (carrierTransversal size θ)
      (carrierTransversal size s) hout (carrierTransversal_not_subset_of_ne size hsize s θ hne)
    have hz' : walshCoefficients (fun x=>Real.tanh (incomingLinear u x))
        (carrierTransversal size s)=0 := by
      have he : cubeCoordinateSign = labelReal := by funext b; cases b <;> rfl
      simpa only [cubeAffine,zero_add,incomingLinear,he] using hz
    simp only [zero_add,hz',abs_zero,mul_zero]
  · exact fun h=>False.elim (h hθ)

lemma intrinsicGain_balanced_odd (n : ℕ) (hodd : Odd n) :
    intrinsicGain (fun _ : Fin n=>balancedGain (n/2))=1/balancedCost (n/2) := by
  obtain ⟨r,hr⟩ := hodd
  have he : n=2*r+1 := by omega
  subst n
  simpa only [show (2*r+1)/2=r by omega] using intrinsicGain_balanced r

lemma sharp_selected_balanced_attains {d : ℕ} (A : Finset (Fin d))
    (hodd : Odd A.card) (u : Fin d → ℝ)
    (hout : ∀ i,i ∉ A → u i=0)
    (hbalance : ∀ i∈A,|u i|=balancedGain (A.card/2)) :
    balancedCost (A.card/2)*|walshCoefficients (fun x=>Real.tanh (incomingLinear u x)) A| =
      Real.sqrt (incomingEnergy u) := by
  have hv : (fun i=>|subsetWeights A u i|)=(fun _=>balancedGain (A.card/2)) := by
    funext i
    exact hbalance _ (A.equivFin.symm i).property
  have hg : intrinsicGain (subsetWeights A u)=1/balancedCost (A.card/2) := by
    rw [←intrinsicGain_abs_weights,hv]
    exact intrinsicGain_balanced_odd A.card hodd
  have hn : 0 < incomingEnergy (subsetWeights A u) := by
    have hcard : 0 < A.card := hodd.pos
    let j : Fin A.card := ⟨0,hcard⟩
    have hb : |subsetWeights A u j|=balancedGain (A.card/2) := congrFun hv j
    have hpos : 0 < (subsetWeights A u j)^2 := by
      nlinarith [balancedGain_pos (A.card/2),sq_abs (subsetWeights A u j)]
    exact hpos.trans_le (Finset.single_le_sum (fun i _=>sq_nonneg _) (Finset.mem_univ j))
  have hs : 0 < Real.sqrt (incomingEnergy (subsetWeights A u)) := Real.sqrt_pos.mpr hn
  unfold intrinsicGain at hg
  have hh := (div_eq_div_iff hs.ne' (balancedCost_pos (A.card/2)).ne').mp hg
  rw [tanh_walshCoefficient_eq_selected_of_outside_zero A u hout,
    incomingEnergy_eq_selected_of_outside_zero A u hout]
  nlinarith

/-- Exact equality/attainment, with the same literal 2S support and
orthogonal-projection bounds as the manuscript on the canonical carrier cube. -/
theorem retainedCarrier_code_paper_with_equality :
    ∃ k₀ p₀ : ℕ,1 ≤ k₀ ∧ 3 ≤ p₀ ∧
      ∀ p r : ℕ,p₀ ≤ p → (k₀:ℝ)*(Real.log ((p:ℝ)+2))^2 ≤ (2*r:ℕ) →
      ∀ size : Fin p → Bool → ℕ,(∀ i s,2*r ≤ size i s) → (∀ i s,size i s ≤ 4*r) →
      (∀ i s,Even (size i s)) →
      ∀ A : Finset (Fin p → Bool),A.Nonempty →
      ∀ W : ℝ,(∀ θ∈A,carrierBalancedCost size θ ≤ W) →
      ∀ bias : ℝ,∀ u : Fin (carrierDimension size) → ℝ,
        let ρ := Real.sqrt (bias^2+incomingEnergy u)
        let Q := carrierCodeMass size A (carrierBalancedCost size) bias u
        Q ≤ ρ ∧
        (∃ θ∈A,bias^2+(∑i∈(carrierTransversal size θ)ᶜ,u i^2) ≤
          2*max 2 (96*Real.sqrt 6*W^2)*ρ*(ρ-Q)) ∧
        uniformCubeMean (fun x=>(Real.tanh (cubeAffine bias u x)-
          fourierProject (retainedCarrierOddSupports size A)
            (fun x=>Real.tanh (cubeAffine bias u x)) x)^2) ≤
          2*max 2 (96*Real.sqrt 6*W^2)*ρ*(ρ-Q) ∧
        (0 < ρ → (Q=ρ ↔ bias=0 ∧ ∃ θ∈A,
          (∀ i,i ∉ carrierTransversal size θ → u i=0) ∧
          ∀ i∈carrierTransversal size θ,|u i|=balancedGain ((carrierTransversal size θ).card/2))) := by
  obtain ⟨k₀,p₁,hk,hp,hcode⟩ := retainedCarrier_code_projection_paper
  obtain ⟨n₀,hequality⟩ := exists_sharp_affine_equality_threshold
  refine ⟨k₀,max p₁ n₀,hk,hp.trans (le_max_left _ _),?_⟩
  intro p r hpp hR size hlo hhi heven A hA W hW bias u
  have hpp₁ : p₁ ≤ p := (le_max_left _ _).trans hpp
  have hp3 : 3 ≤ p := hp.trans hpp₁
  have hlog : 0 < Real.log ((p:ℝ)+2) := Real.log_pos (by exact_mod_cast (show 1<p+2 by omega))
  have hrR : (0:ℝ) < (2*r:ℕ) := lt_of_lt_of_le
    (mul_pos (by exact_mod_cast (show 0<k₀ by omega)) (sq_pos_of_pos hlog)) hR
  have hrnat : 0 < 2*r := by exact_mod_cast hrR
  have hsize : ∀ i s,1 ≤ size i s := fun i s=>by have := hlo i s;omega
  have hdegree (θ : Fin p → Bool) : n₀ ≤ (carrierTransversal size θ).card := by
    have hn : n₀ ≤ p := (le_max_right _ _).trans hpp
    have hs := Finset.sum_le_sum (s:=Finset.univ) (fun i _=>hsize i (θ i))
    rw [carrierTransversal_card]
    simp only [Finset.sum_const,Finset.card_univ,Fintype.card_fin,smul_eq_mul,mul_one] at hs
    omega
  have hh := hcode p r hpp₁ hR size hlo hhi heven A hA W hW bias u
  refine ⟨hh.1,hh.2.1,hh.2.2,?_⟩
  intro hρ
  constructor
  · intro heq
    obtain ⟨θ,hθ,hstab⟩ := hh.2.1
    rw [heq,sub_self,mul_zero] at hstab
    have hsum : 0 ≤ ∑i∈(carrierTransversal size θ)ᶜ,u i^2 := Finset.sum_nonneg (fun i _=>sq_nonneg _)
    have hb : bias=0 := by nlinarith [sq_nonneg bias]
    have hout : ∀ i,i ∉ carrierTransversal size θ → u i=0 := by
      intro i hi
      have hv := Finset.single_le_sum (s:=(carrierTransversal size θ)ᶜ)
        (f:=fun i=>u i^2) (fun j _=>sq_nonneg _) (Finset.mem_compl.mpr hi)
      nlinarith [sq_nonneg bias,sq_nonneg (u i)]
    refine ⟨hb,θ,hθ,hout,?_⟩
    have hm := carrierCodeMass_eq_selected_of_supported size hsize A (carrierBalancedCost size) θ hθ u hout
    rw [hb,hm] at heq
    have hc := (hequality (carrierDimension size) (carrierTransversal size θ)
      (hdegree θ) (carrierTransversal_odd size heven θ) u 0).2
    apply (hc (by simpa only [hb] using hρ) (by simpa only [zero_add,carrierBalancedCost] using heq)).2.2
  · rintro ⟨rfl,θ,hθ,hout,hbalance⟩
    rw [carrierCodeMass_eq_selected_of_supported size hsize A (carrierBalancedCost size) θ hθ u hout]
    simpa only [zero_pow (by norm_num : (2:ℕ)≠0),zero_add,carrierBalancedCost] using
      sharp_selected_balanced_attains (carrierTransversal size θ)
        (carrierTransversal_odd size heven θ) u hout hbalance

end NeuralGeneralization.OnlineLowerTanh
