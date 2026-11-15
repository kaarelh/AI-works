import NeuralGeneralization.OnlineLowerReluCoverageVariation
import NeuralGeneralization.OnlineLowerTanhSynthesis
import NeuralGeneralization.OnlineLowerTanhCodeNetwork
import NeuralGeneralization.OnlineLowerTanhSharpParity

/-! # Literal tanh variation infimum and the exact retained-code norm

The infimum quantifies over all finite actual affine tanh representations,
including their bias coordinates. The eventual endpoint discharges the
sharp intrinsic parity theorem instead of retaining it as an assumption.
-/
set_option maxHeartbeats 800000
noncomputable section
open scoped BigOperators Classical Topology
open Filter
namespace NeuralGeneralization.OnlineLowerTanh
open ConcreteModel OnlineLower OnlineLowerGeometry
open OnlineLowerRelu (finiteVariationCost atomicWeightedCost_eq_variation cubeAffine)

def tanhVariationCosts {d : ℕ} (F : Cube d → ℝ) : Set ℝ :=
  {B | ∃ (q : ℕ) (a : Fin q → Fin (d+1) → ℝ) (c : Fin q → ℝ),
    (∀ x,atomicScore Real.tanh a c x = F x) ∧ B = finiteVariationCost a c}

def tanhVariation {d : ℕ} (F : Cube d → ℝ) : ℝ := sInf (tanhVariationCosts F)

lemma tanh_atomOutput_eq_affine {d : ℕ} (a : Fin (d+1) → ℝ) :
    atomOutput Real.tanh a = fun x => Real.tanh (cubeAffine (a 0) (fun i => a i.succ) x) := by
  funext x
  unfold atomOutput
  rw [Fin.sum_univ_succ]
  simp only [inputVector,Fin.cases_zero,Fin.cases_succ,mul_one]
  rfl

lemma retained_mass_le_tanh_finiteVariationCost {d q : ℕ} {ι : Type*} [Fintype ι]
    (A : ι → Finset (Fin d)) (w : ι → ℝ) (hw : ∀ i,0 ≤ w i)
    (hatom : ∀ (u : Fin d → ℝ) (b : ℝ),
      retainedFourierMass A w (fun x => Real.tanh (cubeAffine b u x)) ≤
        Real.sqrt (b^2+∑ i,u i^2))
    (a : Fin q → Fin (d+1) → ℝ) (c : Fin q → ℝ) :
    retainedFourierMass A w (atomicScore Real.tanh a c) ≤ finiteVariationCost a c := by
  apply (retainedFourierMass_sum A w hw c (fun j => atomOutput Real.tanh (a j))).trans
  apply Finset.sum_le_sum
  intro j _
  apply mul_le_mul_of_nonneg_left _ (abs_nonneg _)
  rw [tanh_atomOutput_eq_affine,Fin.sum_univ_succ]
  exact hatom (fun i => a j i.succ) (a j 0)

private lemma sum_nonzero_coefficients {ι : Type*} [Fintype ι]
    (v F : ι → ℝ) (hzero : ∀ i,v i = 0 → F i = 0) :
    (∑ i : {i : ι // v i ≠ 0},F i.val) = ∑ i,F i := by
  have h := Fintype.sum_subtype_add_sum_subtype (fun i => v i ≠ 0) F
  have hz : (∑ i : {i : ι // ¬v i ≠ 0},F i.val) = 0 := by
    apply Finset.sum_eq_zero
    intro i _
    exact hzero i.val (not_not.mp i.property)
  rw [hz,add_zero] at h
  exact h

/-- Actual finite tanh parity-orbit representation, allowing zero coefficients
and without the separate allocation condition needed for finite network energy. -/
theorem tanh_fourier_finite_variation_witness {d : ℕ} {ι : Type*} [Fintype ι]
    (hd : 0 < d) (S : ι → Finset (Fin d)) (r : ι → ℕ) (v : ι → ℝ)
    (hcard : ∀ i,(S i).card=2*r i+1) :
    ∃ (q : ℕ) (A : Fin q → Fin (d+1) → ℝ) (c : Fin q → ℝ),
      (∀ x,atomicScore Real.tanh A c x = ∑ i,v i*walshCharacter (S i) x) ∧
      finiteVariationCost A c = ∑ i,balancedCost (r i)*|v i| := by
  let I := {i : ι // v i ≠ 0}
  let e := Fintype.equivFin I
  let s : Fin (Fintype.card I) → ι := fun j => (e.symm j).val
  have hsum (F : ι → ℝ) (hzero : ∀ i,v i = 0 → F i = 0) :
      (∑ j : Fin (Fintype.card I),F (s j)) = ∑ i,F i := by
    rw [show (∑ j : Fin (Fintype.card I),F (s j)) = ∑ i : I,F i.val from
      e.symm.sum_comp (fun i : I => F i.val)]
    exact sum_nonzero_coefficients v F hzero
  have hq (i : ι) : walshCoefficients
      (atomOutput Real.tanh (supportIncoming (S i) (balancedGain (r i)))) (S i) ≠ 0 := by
    apply abs_ne_zero.mp
    rw [support_tanh_walsh_abs (S i) (r i) (hcard i)]
    exact (balancedParity_gain_pos _).ne'
  have ha (i : ι) : 0 < incomingAtomCost (supportIncoming (S i) (balancedGain (r i))) := by
    rw [supportIncoming_cost,hcard i]
    positivity [balancedGain_pos (r i)]
  obtain ⟨A,c,hA,hc,hscore,hcost⟩ := finite_orbit_synthesis Real.tanh
    (fun j => S (s j)) (fun j => supportIncoming (S (s j)) (balancedGain (r (s j))))
    (fun j => v (s j)) (fun j => hq (s j)) (fun j => ha (s j))
    (fun j => (e.symm j).property)
  refine ⟨_,A,c,?_,?_⟩
  · intro x
    rw [hscore,hsum (fun i => v i*walshCharacter (S i) x) (by intro i hi; simp [hi])]
  · rw [atomicWeightedCost_eq_variation] at hcost
    simp_rw [supported_orbit_cost _ _ (hcard _)] at hcost
    rw [←Finset.mul_sum,hsum (fun i => |v i| * balancedCost (r i)) (by intro i hi; simp [hi])] at hcost
    have hscale : (2*Real.sqrt (d : ℝ)) ≠ 0 := by positivity
    have heq := mul_left_cancel₀ hscale hcost
    simpa only [mul_comm] using heq

/-- The literal variation infimum equals the weighted Fourier norm under
an established sharp atomic bound; the representation attains its infimum. -/
theorem tanhVariation_fourier_of_atom_bound {d : ℕ} {ι : Type*} [Fintype ι]
    (hd : 0 < d) (A : ι → Finset (Fin d)) (r : ι → ℕ) (c : ι → ℝ)
    (hA : Function.Injective A) (hcard : ∀ i,(A i).card=2*r i+1)
    (hatom : ∀ (u : Fin d → ℝ) (b : ℝ),
      retainedFourierMass A (fun i => balancedCost (r i))
        (fun x => Real.tanh (cubeAffine b u x)) ≤ Real.sqrt (b^2+∑ i,u i^2)) :
    tanhVariation (fun x => ∑ i,c i*walshCharacter (A i) x) =
      ∑ i,balancedCost (r i)*|c i| := by
  let F : Cube d → ℝ := fun x => ∑ i,c i*walshCharacter (A i) x
  let W : ℝ := ∑ i,balancedCost (r i)*|c i|
  have hlower (B : ℝ) (hB : B ∈ tanhVariationCosts F) : W ≤ B := by
    obtain ⟨q,a,b,hscore,rfl⟩ := hB
    have h := retained_mass_le_tanh_finiteVariationCost A (fun i => balancedCost (r i))
      (fun i => (balancedCost_pos _).le) hatom a b
    have heq : atomicScore Real.tanh a b = F := funext hscore
    rw [heq] at h
    exact (OnlineLowerRelu.retained_mass_fourier_series A (fun i => balancedCost (r i)) c hA).symm.trans_le h
  obtain ⟨q,a,b,hscore,hcost⟩ := tanh_fourier_finite_variation_witness hd A r c hcard
  change sInf (tanhVariationCosts F) = W
  apply IsLeast.csInf_eq
  exact ⟨⟨q,a,b,hscore,hcost.symm⟩,hlower⟩

lemma carrierTransversal_injective_of_positive {p : ℕ} (size : Fin p → Bool → ℕ)
    (hsize : ∀ i b,1 ≤ size i b) : Function.Injective (carrierTransversal size) := by
  intro s t heq
  have h := carrierTransversal_difference_card_lower size hsize s t
  rw [heq,Finset.sdiff_self,Finset.card_empty,mul_one] at h
  have hz : changedRails s t = ∅ := Finset.card_eq_zero.mp (Nat.eq_zero_of_le_zero h)
  funext i
  by_contra hi
  have hm : i ∈ changedRails s t := by simp [changedRails,hi]
  rw [hz] at hm
  exact Finset.notMem_empty i hm

/-- Exact variation norm for every retained carrier-code Fourier series.
The single-parity analytic theorem is fully discharged. The constants are
absolute and the rail threshold remains logarithmic-square in pair count. -/
theorem retained_carrier_tanhVariation_eq :
    ∃ k₀ p₀ : ℕ,1 ≤ k₀ ∧ 3 ≤ p₀ ∧
      ∀ p r : ℕ,p₀ ≤ p → (k₀ : ℝ)*(Real.log ((p : ℝ)+2))^2 ≤ (2*r : ℕ) →
      ∀ size : Fin p → Bool → ℕ,(∀ i b,2*r ≤ size i b) → (∀ i b,size i b ≤ 4*r) →
      (∀ i b,Even (size i b)) → ∀ A : Finset (Fin p → Bool),A.Nonempty →
      ∀ c : A → ℝ,
        tanhVariation (fun x => ∑ θ : A,c θ*walshCharacter (carrierTransversal size θ.val) x) =
          ∑ θ : A,carrierBalancedCost size θ.val*|c θ| := by
  obtain ⟨k₀,p₁,hk₀,hp₁,hcode⟩ := carrierBalancedCode_exact_of_intrinsic
  obtain ⟨n₀,hsharp⟩ := exists_intrinsicParityBound_threshold
  refine ⟨k₀,max p₁ n₀,hk₀,hp₁.trans (le_max_left _ _),?_⟩
  intro p r hp hR size hlo hhi heven A hA c
  have hp₁p : p₁ ≤ p := (le_max_left _ _).trans hp
  have hn₀p : n₀ ≤ p := (le_max_right _ _).trans hp
  have hp3 : 3 ≤ p := hp₁.trans hp₁p
  have hlog : 0 < Real.log ((p : ℝ)+2) := Real.log_pos (by have h := Nat.cast_nonneg (α:=ℝ) p; linarith)
  have hpositive : 0 < (2*r : ℕ) := by
    have hkr : (0 : ℝ) < k₀ := by exact_mod_cast (show 0 < k₀ by omega)
    have h := lt_of_lt_of_le (mul_pos hkr (sq_pos_of_pos hlog)) hR
    exact_mod_cast h
  have hsize : ∀ i b,1 ≤ size i b := fun i b => (by omega : 1 ≤ 2*r).trans (hlo i b)
  have hsharpA (θ : Fin p → Bool) (hθ : θ ∈ A) :
      IntrinsicParityBound (carrierTransversal size θ).card (carrierBalancedCost size θ) := by
    apply hsharp _ _ (carrierTransversal_odd size heven θ)
    apply hn₀p.trans
    apply (show p ≤ p*(2*r) by nlinarith).trans
    exact carrierTransversal_card_lower size hlo θ
  have hbound (u : Fin (carrierDimension size) → ℝ) (bias : ℝ) :=
    (hcode p r hp₁p hR size hlo hhi heven A hA hsharpA bias u).1
  apply tanhVariation_fourier_of_atom_bound (by unfold carrierDimension; omega)
    (fun θ : A => carrierTransversal size θ.val)
    (fun θ : A => (carrierTransversal size θ.val).card/2) c
    ((carrierTransversal_injective_of_positive size hsize).comp Subtype.val_injective)
    (fun θ => (carrierTransversal_odd_degree size heven θ.val).symm)
  intro u bias
  have heq : retainedFourierMass (fun θ : A => carrierTransversal size θ.val)
      (fun θ : A => balancedCost ((carrierTransversal size θ.val).card/2))
      (fun x => Real.tanh (cubeAffine bias u x)) =
      carrierCodeMass size A (carrierBalancedCost size) bias u := by
    unfold retainedFourierMass carrierCodeMass carrierBalancedCost
    convert (Finset.sum_coe_sort A (fun θ => balancedCost ((carrierTransversal size θ).card/2) *
      |walshCoefficients (fun x => Real.tanh (cubeAffine bias u x)) (carrierTransversal size θ)|)) using 1
    congr 1
  rw [heq]
  exact hbound u bias

end NeuralGeneralization.OnlineLowerTanh
