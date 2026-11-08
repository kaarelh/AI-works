import NeuralGeneralization.OnlineLowerSamplerMinimum

/-! # Fourier phases and total positive mass for actual even rail neurons -/

noncomputable section
open scoped BigOperators

namespace NeuralGeneralization.OnlineLowerRelu

theorem mem_samplerSupport_index {p : ℕ} (P r : Fin p → ℕ)
    (τ : Finset (Fin p)) (i : Fin p) (side : Bool) (k : Fin (samplerSize P r i side)) :
    railIndex (samplerSize P r) ⟨i,side,k⟩ ∈ samplerSupport P r τ ↔ side = decide (i ∈ τ) := by
  unfold samplerSupport
  simp only [Finset.mem_biUnion, Finset.mem_univ, true_and, mem_physicalRail]
  simp
  rw [Equiv.symm_apply_apply]

theorem sampler_trigKernel_nonneg {p : ℕ} (P r : Fin p → ℕ)
    (hP : ∀ i, Even (P i)) (hr : ∀ i, Even (r i))
    (a b : Fin p → ℝ) (τ : Finset (Fin p)) (t : ℝ) :
    0 ≤ trigKernel (samplerSupport P r τ) (samplerWeights P r a b) t := by
  unfold trigKernel
  apply div_nonneg _ (sq_nonneg t)
  unfold trigProduct
  rw [← Equiv.prod_comp (railIndex (samplerSize P r))
    (fun j => if j ∈ samplerSupport P r τ then Real.sin (t * samplerWeights P r a b j)
      else Real.cos (t * samplerWeights P r a b j))]
  rw [Fintype.prod_sigma]
  apply Finset.prod_nonneg
  intro i _
  rw [Fintype.prod_sigma]
  apply Finset.prod_nonneg
  intro side _
  simp_rw [mem_samplerSupport_index, samplerWeights_apply]
  rw [Finset.prod_const]
  simp only [Finset.card_univ, Fintype.card_fin]
  have heven : Even (samplerSize P r i side) := by
    cases side
    · exact hP i
    · exact (hr i).add (by decide : Even 2)
  exact heven.pow_nonneg _

def samplerHalfDegree {p : ℕ} (P r : Fin p → ℕ) (τ : Finset (Fin p)) : ℕ :=
  ∑ i, if i ∈ τ then (r i + 2) / 2 else P i / 2

theorem samplerSupport_card_half {p : ℕ} (P r : Fin p → ℕ)
    (hP : ∀ i, Even (P i)) (hr : ∀ i, Even (r i)) (τ : Finset (Fin p)) :
    (samplerSupport P r τ).card = 2 * samplerHalfDegree P r τ := by
  rw [samplerSupport_card]
  unfold samplerHalfDegree
  rw [Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro i _
  obtain ⟨u, hu⟩ := hP i
  obtain ⟨v, hv⟩ := hr i
  split_ifs <;> omega

theorem parity_phase_subset_sum {ι : Type*} [Fintype ι] [DecidableEq ι]
    (u v : ι → ℕ) (τ : Finset ι) :
    (-1 : ℝ) ^ ((∑ i, if i ∈ τ then v i else u i) + 1) =
      (-1 : ℝ) ^ ((∑ i, u i) + 1) * ∏ i ∈ τ, (-1 : ℝ) ^ (u i + v i) := by
  have hprod : (∏ i, (-1 : ℝ) ^ u i) * (∏ i ∈ τ, (-1 : ℝ) ^ (u i + v i)) =
      ∏ i, (-1 : ℝ) ^ (if i ∈ τ then v i else u i) := by
    rw [← Finset.prod_ite_mem_eq τ (fun i => (-1 : ℝ) ^ (u i + v i)),
      ← Finset.prod_mul_distrib]
    apply Finset.prod_congr rfl
    intro i _
    by_cases hi : i ∈ τ
    · rw [if_pos hi, if_pos hi, pow_add]
      have hs : (-1 : ℝ) ^ u i * (-1 : ℝ) ^ u i = 1 := by
        rw [← pow_two, ← pow_mul, Nat.mul_comm (u i) 2, pow_mul]
        norm_num
      rw [← mul_assoc, hs, one_mul]
    · simp [hi]
  calc
    _ = (∏ i, (-1 : ℝ) ^ (if i ∈ τ then v i else u i)) * (-1) := by
      rw [Finset.prod_pow_eq_pow_sum, pow_succ]
    _ = ((∏ i, (-1 : ℝ) ^ u i) * (∏ i ∈ τ, (-1 : ℝ) ^ (u i + v i))) * (-1) := by
      rw [hprod]
    _ = _ := by rw [Finset.prod_pow_eq_pow_sum, pow_succ]; ring

def samplerPhaseBits {p : ℕ} (P r : Fin p → ℕ) (i : Fin p) : Bool :=
  realSignBit ((-1 : ℝ) ^ (P i / 2 + (r i + 2) / 2))

theorem samplerPhaseBits_sign {p : ℕ} (P r : Fin p → ℕ) (i : Fin p) :
    railBit (samplerPhaseBits P r i) = (-1 : ℝ) ^ (P i / 2 + (r i + 2) / 2) := by
  apply railBit_realSignBit
  simp

theorem sampler_phase_alignment {p : ℕ} (P r : Fin p → ℕ) (τ : Finset (Fin p)) :
    (-1 : ℝ) ^ (samplerHalfDegree P r τ + 1) =
      (-1 : ℝ) ^ ((∑ i, P i / 2) + 1) * ∏ i ∈ τ, railBit (samplerPhaseBits P r i) := by
  simp_rw [samplerPhaseBits_sign]
  exact parity_phase_subset_sum (fun i => P i / 2) (fun i => (r i + 2) / 2) τ

/-- Exact absolute value of the signed coefficient sum: all its terms
share one global phase after the explicitly selected parity phases. -/
theorem sampler_signed_sum_abs_eq_potential_mass {p : ℕ} (hp : 0 < p)
    (P r : Fin p → ℕ) (hPtwo : ∀ i, 2 ≤ P i)
    (hP : ∀ i, Even (P i)) (hr : ∀ i, Even (r i)) (a b : Fin p → ℝ) :
    |∑ τ : Finset (Fin p), (∏ i ∈ τ, railBit (samplerPhaseBits P r i)) *
      walshCoefficients (fun x => max (cubeAffine 0 (samplerWeights P r a b) x) 0)
        (samplerSupport P r τ)| =
      ∑ τ : Finset (Fin p), supportFourierPotential (samplerSupport P r τ)
        (samplerWeights P r a b) := by
  have hterm (τ : Finset (Fin p)) := relu_walsh_signed_eq_potential_of_nonneg
    (samplerSupport P r τ) (samplerSupport_two_le hp P r τ hPtwo)
    (samplerSupport_card_half P r hP hr τ) (samplerWeights P r a b)
    (sampler_trigKernel_nonneg P r hP hr a b τ)
  simp_rw [sampler_phase_alignment, mul_assoc] at hterm
  have hsum := Finset.sum_congr rfl (fun τ (_ : τ ∈ Finset.univ) => hterm τ)
  rw [← Finset.mul_sum] at hsum
  have hbase : |(-1 : ℝ) ^ ((∑ i, P i / 2) + 1)| = 1 := by simp
  calc
    _ = |(-1 : ℝ) ^ ((∑ i, P i / 2) + 1) *
        ∑ τ : Finset (Fin p), (∏ i ∈ τ, railBit (samplerPhaseBits P r i)) *
          walshCoefficients (fun x => max (cubeAffine 0 (samplerWeights P r a b) x) 0)
            (samplerSupport P r τ)| := by rw [abs_mul, hbase, one_mul]
    _ = _ := by
      rw [hsum]
      exact abs_of_nonneg (Finset.sum_nonneg (fun τ _ => supportFourierPotential_nonneg _ _))

/-- The positive Fourier mass of every balanced even-rail atom is bounded
by the proved randomized minimum, in the literal physical network model. -/
theorem sampler_potential_mass_bound {p : ℕ} (hp : 0 < p)
    (P r : Fin p → ℕ) (hPtwo : ∀ i, 2 ≤ P i)
    (hP : ∀ i, Even (P i)) (hr : ∀ i, Even (r i))
    (n : ℕ) (hD : (∑ i, P i) = n + 2)
    (a b : Fin p → ℝ) (hb : ∀ i, 0 ≤ b i) (hab : ∀ i, b i ≤ a i) :
    (∑ τ : Finset (Fin p), supportFourierPotential (samplerSupport P r τ)
      (samplerWeights P r a b)) ≤
      (n.choose (n / 2) : ℝ) / (2 : ℝ) ^ (n + 1) *
        @finiteAverage (Fin p → Bool) inferInstance
          (@minimumRailAmplitude (Fin p) inferInstance ⟨⟨0,hp⟩⟩ a b) := by
  rw [← sampler_signed_sum_abs_eq_potential_mass hp P r hPtwo hP hr a b]
  exact actual_relu_randomized_minimum hp P r (fun i => by have := hPtwo i; omega)
    n hD (Finset.even_sum _ (fun i _ => hP i)) a b (samplerPhaseBits P r) 0 hb hab

end NeuralGeneralization.OnlineLowerRelu
