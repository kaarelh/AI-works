import NeuralGeneralization.OnlineLowerGeometryAlgebra
import NeuralGeneralization.WalshLaplacian
import NeuralGeneralization.OnlineLowerTanhIncrementWalsh

/-! # Exact pair tails and a finite cover of noncentral positive Walsh mass -/
noncomputable section
open scoped BigOperators Classical
namespace NeuralGeneralization.OnlineLowerTanh
open OnlineLowerGeometry

/-- Total coefficient mass over supports containing both specified coordinates. -/
def coefficientPairTail {α : Type*} [Fintype α] [DecidableEq α]
    (c : Finset α → ℝ) (i j : α) : ℝ :=
  ∑ T : Finset α, if i∈T ∧ j∈T then c T else 0

/-- Fourier inversion at the four points supported on the selected pair gives
an exact pair-tail identity, with every other input fixed to `true`. -/
theorem walsh_pair_tail_identity {d : ℕ} (F : ClippingCube d → ℝ) (i j : Fin d) :
    coefficientPairTail (walshCoefficients F) i j =
      (F (cubeOne d)-F (cubeFlip i (cubeOne d))-F (cubeFlip j (cubeOne d))+
        F (cubeFlip i (cubeFlip j (cubeOne d))))/4 := by
  have he (T : Finset (Fin d)) :
      walshCoefficients F T*walshCharacter T (cubeOne d)-
      walshCoefficients F T*walshCharacter T (cubeFlip i (cubeOne d))-
      walshCoefficients F T*walshCharacter T (cubeFlip j (cubeOne d))+
      walshCoefficients F T*walshCharacter T (cubeFlip i (cubeFlip j (cubeOne d))) =
      4*(if i∈T ∧ j∈T then walshCoefficients F T else 0) := by
    simp only [walshCharacter_flip, walshCharacter_one]
    by_cases hi : i∈T <;> by_cases hj : j∈T <;> simp [hi,hj] <;> ring
  have hsum := Finset.sum_congr (s₁:=Finset.univ) (s₂:=Finset.univ) rfl (fun T _ => he T)
  simp only [Finset.sum_add_distrib, Finset.sum_sub_distrib, ← Finset.mul_sum] at hsum
  change walshExpansion (walshCoefficients F) (cubeOne d)-
    walshExpansion (walshCoefficients F) (cubeFlip i (cubeOne d))-
    walshExpansion (walshCoefficients F) (cubeFlip j (cubeOne d))+
    walshExpansion (walshCoefficients F) (cubeFlip i (cubeFlip j (cubeOne d))) =
    4*coefficientPairTail (walshCoefficients F) i j at hsum
  simp only [walshExpansion_coefficients] at hsum
  linarith

lemma noncentral_support_contains_old_pair {α : Type*} [DecidableEq α]
    (T : Finset α) (d₀ d₁ : α) (hcard : 2 ≤ T.card) (hne : T ≠ {d₀,d₁}) :
    ∃ i∈T, i∉({d₀,d₁} : Finset α) ∧ ∃ j∈T, j≠i := by
  have hnot : ¬T⊆({d₀,d₁} : Finset α) := by
    intro hs
    apply hne
    exact Finset.eq_of_subset_of_card_le hs ((Finset.card_insert_le _ _).trans (by simpa using hcard))
  obtain ⟨i, hi, hold⟩ := Finset.not_subset.mp hnot
  obtain ⟨j, hj, hji⟩ := Finset.exists_mem_ne (show 1<T.card by omega) i
  exact ⟨i,hi,hold,j,hj,hji⟩

/-- Every noncentral support of cardinality at least two contains an old
coordinate and a distinct partner. Nonnegative high-degree coefficients may
therefore be charged to the corresponding ordered pair tails. -/
theorem noncentral_mass_le_pair_tails {α : Type*} [Fintype α] [DecidableEq α]
    (c : Finset α → ℝ) (d₀ d₁ : α) (hc : ∀T, 2≤T.card → 0≤c T) :
    (∑T : Finset α, if 2≤T.card ∧ T≠({d₀,d₁} : Finset α) then c T else 0) ≤
      ∑i∈({d₀,d₁} : Finset α)ᶜ, ∑j∈Finset.univ.erase i, coefficientPairTail c i j := by
  have hterm (T : Finset α) (i j : α) (hji : j≠i) :
      0 ≤ if i∈T ∧ j∈T then c T else 0 := by
    split_ifs with h
    · apply hc
      have hh := (Finset.one_lt_card).2 ⟨i,h.1,j,h.2,hji.symm⟩
      omega
    · rfl
  have hpoint (T : Finset α) :
      (if 2≤T.card ∧ T≠({d₀,d₁} : Finset α) then c T else 0) ≤
        ∑i∈({d₀,d₁} : Finset α)ᶜ, ∑j∈Finset.univ.erase i,
          if i∈T ∧ j∈T then c T else 0 := by
    by_cases h : 2≤T.card ∧ T≠({d₀,d₁} : Finset α)
    · rw [if_pos h]
      obtain ⟨i, hi, hold, j, hj, hji⟩ := noncentral_support_contains_old_pair T d₀ d₁ h.1 h.2
      have hjset : j∈Finset.univ.erase i := Finset.mem_erase.mpr ⟨hji,Finset.mem_univ _⟩
      have hiset : i∈({d₀,d₁} : Finset α)ᶜ := Finset.mem_compl.mpr hold
      have hinner := Finset.single_le_sum (s:=Finset.univ.erase i)
        (f:=fun j=>if i∈T ∧ j∈T then c T else 0)
        (fun j hj=>hterm T i j (Finset.mem_erase.mp hj).1) hjset
      have houter := Finset.single_le_sum (s:=({d₀,d₁} : Finset α)ᶜ)
        (f:=fun i=>∑j∈Finset.univ.erase i,if i∈T ∧ j∈T then c T else 0)
        (fun i _=>Finset.sum_nonneg (fun j hj=>hterm T i j (Finset.mem_erase.mp hj).1)) hiset
      have hh : c T ≤ ∑j∈Finset.univ.erase i,if i∈T ∧ j∈T then c T else 0 := by
        simpa only [hi,hj,and_self,ite_true] using hinner
      exact hh.trans houter
    · rw [if_neg h]
      exact Finset.sum_nonneg fun i _=>Finset.sum_nonneg fun j hj=>hterm T i j (Finset.mem_erase.mp hj).1
  have hh := Finset.sum_le_sum (s:=Finset.univ) (fun T _=>hpoint T)
  calc
    _ ≤ _ := hh
    _ = _ := by
      unfold coefficientPairTail
      rw [Finset.sum_comm]
      apply Finset.sum_congr rfl
      intro i hi
      rw [Finset.sum_comm]

lemma incrementLinear_cubeOne {d : ℕ} (δ : Fin d → ℝ) :
    incrementLinear δ (cubeOne d) = 0 := by
  simp [incrementLinear, cubeOne]

lemma incrementLinear_single_flip {d : ℕ} (δ : Fin d → ℝ) (i : Fin d) :
    incrementLinear δ (cubeFlip i (cubeOne d)) = δ i := by
  unfold incrementLinear
  have he (k : Fin d) : δ k*(if cubeFlip i (cubeOne d) k then 0 else 1) =
      if k=i then δ i else 0 := by
    by_cases hk : k=i
    · subst k; simp [cubeFlip, cubeOne]
    · simp [cubeFlip, cubeOne, Function.update_of_ne hk, hk]
  simp_rw [he]
  simp

lemma incrementLinear_pair_flip {d : ℕ} (δ : Fin d → ℝ) (i j : Fin d) (hij : i≠j) :
    incrementLinear δ (cubeFlip i (cubeFlip j (cubeOne d))) = δ i+δ j := by
  unfold incrementLinear
  have he (k : Fin d) : δ k*(if cubeFlip i (cubeFlip j (cubeOne d)) k then 0 else 1) =
      (if k=i then δ i else 0)+(if k=j then δ j else 0) := by
    by_cases hi : k=i
    · subst k; simp [cubeFlip, cubeOne, hij, hij.symm]
    · by_cases hj : k=j
      · subst k; simp [cubeFlip, cubeOne, hij, hij.symm]
      · simp [cubeFlip, cubeOne, Function.update_of_ne hi, Function.update_of_ne hj, hi, hj]
  simp_rw [he]
  rw [Finset.sum_add_distrib]
  simp

/-- The exact tail above a pair is one quarter of the mixed difference at the
minimum degree; no sum over the other input bits remains. -/
theorem increment_walsh_pair_tail {d : ℕ} (δ : Fin d → ℝ) (f : ℝ → ℝ)
    (n : ℝ) (i j : Fin d) (hij : i≠j) :
    coefficientPairTail (walshCoefficients (incrementScore δ f n)) i j =
      (f n-f (n+δ i)-f (n+δ j)+f (n+δ i+δ j))/4 := by
  rw [walsh_pair_tail_identity]
  simp only [incrementScore, incrementLinear_cubeOne, incrementLinear_single_flip,
    incrementLinear_pair_flip δ i j hij, add_zero, add_assoc]

theorem increment_walsh_pair_tail_mixed {d : ℕ} (δ : Fin d → ℝ) (f : ℝ → ℝ)
    (n : ℝ) (i j : Fin d) (hij : i≠j) :
    coefficientPairTail (walshCoefficients (incrementScore δ f n)) i j =
      mixedBackwardDifference [δ i,δ j] f n/4 := by
  rw [increment_walsh_pair_tail δ f n i j hij]
  simp only [mixedBackwardDifference]
  ring

/-- Specialization of the finite covering bound to the actual increment-cube
coefficients, with exact second differences on the right. -/
theorem increment_noncentral_mass_le_pair_differences {d : ℕ}
    (δ : Fin d → ℝ) (f : ℝ → ℝ) (n : ℝ) (d₀ d₁ : Fin d)
    (hc : ∀T, 2≤T.card → 0≤walshCoefficients (incrementScore δ f n) T) :
    (∑T : Finset (Fin d), if 2≤T.card ∧ T≠({d₀,d₁} : Finset (Fin d))
      then walshCoefficients (incrementScore δ f n) T else 0) ≤
      ∑i∈({d₀,d₁} : Finset (Fin d))ᶜ, ∑j∈Finset.univ.erase i,
        mixedBackwardDifference [δ i,δ j] f n/4 := by
  have hh := noncentral_mass_le_pair_tails (walshCoefficients (incrementScore δ f n)) d₀ d₁ hc
  calc
    _ ≤ _ := hh
    _ = _ := by
      apply Finset.sum_congr rfl
      intro i hi
      apply Finset.sum_congr rfl
      intro j hj
      exact increment_walsh_pair_tail_mixed δ f n i j (Finset.mem_erase.mp hj).1.symm

/-- Summing ordered pair products costs only total old increment times total
increment; the omitted diagonal contributes nonnegative mass. -/
lemma increment_pair_budget {α : Type*} [Fintype α] [DecidableEq α]
    (δ : α → ℝ) (hδ : ∀i,0≤δ i) (O : Finset α) :
    (∑i∈O,∑j∈Finset.univ.erase i,δ i*δ j) ≤ (∑i∈O,δ i)*(∑j,δ j) := by
  calc
    _ ≤ ∑i∈O,∑j,δ i*δ j := Finset.sum_le_sum fun i _ =>
      Finset.sum_le_sum_of_subset_of_nonneg (Finset.erase_subset _ _)
        (fun j _ _ => mul_nonneg (hδ i) (hδ j))
    _ = _ := by simp_rw [← Finset.mul_sum]; rw [← Finset.sum_mul]

/-- Quantitative form of the pair cover used for actual dominant-pair costs. -/
theorem noncentral_mass_le_weighted_pair_budget {α : Type*} [Fintype α] [DecidableEq α]
    (c : Finset α → ℝ) (d₀ d₁ : α) (hc : ∀T,2≤T.card → 0≤c T)
    (δ : α → ℝ) (hδ : ∀i,0≤δ i) (L : ℝ) (hL : 0≤L)
    (hpair : ∀i∈({d₀,d₁} : Finset α)ᶜ,∀j,j≠i → coefficientPairTail c i j ≤ L*(δ i*δ j)) :
    (∑T : Finset α,if 2≤T.card ∧ T≠({d₀,d₁} : Finset α) then c T else 0) ≤
      L*((∑i∈({d₀,d₁} : Finset α)ᶜ,δ i)*(∑j,δ j)) := by
  calc
    _ ≤ ∑i∈({d₀,d₁} : Finset α)ᶜ,∑j∈Finset.univ.erase i,coefficientPairTail c i j :=
      noncentral_mass_le_pair_tails c d₀ d₁ hc
    _ ≤ ∑i∈({d₀,d₁} : Finset α)ᶜ,∑j∈Finset.univ.erase i,L*(δ i*δ j) := by
      apply Finset.sum_le_sum
      intro i hi
      exact Finset.sum_le_sum fun j hj=>hpair i hi j (Finset.mem_erase.mp hj).1
    _ = L*(∑i∈({d₀,d₁} : Finset α)ᶜ,∑j∈Finset.univ.erase i,δ i*δ j) := by
      simp_rw [← Finset.mul_sum]
    _ ≤ _ := mul_le_mul_of_nonneg_left (increment_pair_budget δ hδ _) hL

end NeuralGeneralization.OnlineLowerTanh
