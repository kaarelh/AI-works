import NeuralGeneralization.RankOnePotential
import NeuralGeneralization.GreedyGrowthCover

/-! Concrete finite-level growth from actual convex-hull energy minima. -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.SquaredSampling
open Classical
attribute [local instance] Classical.propDecidable

variable {m D : ℕ} {U : Type*} [DecidableEq U]

def rankPotential (a : Fin m → Fin D → ℝ) (p : U → Fin D → ℝ)
    (offset : ℝ) (S : Finset U) : ℝ :=
  if S.Nonempty then 2-energyMinimum a p S+offset else 0

lemma rankPotential_nonneg (a : Fin m → Fin D → ℝ) (p : U → Fin D → ℝ)
    (offset : ℝ) (hoff : 0 ≤ offset)
    (hbound : ∀ x, rankOneEnergy a (p x) ≤ 2) (S : Finset U) :
    0 ≤ rankPotential a p offset S := by
  unfold rankPotential
  split_ifs with hS
  · obtain ⟨x, hx⟩ := hS
    have he := (energyMinimum_le a p S ⟨x, hx⟩ (p x)
      (subset_convexHull ℝ _ ⟨x, hx, rfl⟩)).trans (hbound x)
    linarith
  · exact le_rfl

lemma rankPotential_le (a : Fin m → Fin D → ℝ) (p : U → Fin D → ℝ)
    (offset : ℝ) (hoff : 0 ≤ offset) (S : Finset U) :
    rankPotential a p offset S ≤ 2+offset := by
  unfold rankPotential
  split_ifs with hS
  · linarith only [energyMinimum_nonneg a p S]
  · linarith only [hoff]

lemma rankPotential_mono (a : Fin m → Fin D → ℝ) (p : U → Fin D → ℝ)
    (offset : ℝ) (hoff : 0 ≤ offset)
    (hbound : ∀ x, rankOneEnergy a (p x) ≤ 2) : Monotone (rankPotential a p offset) := by
  intro S T hST
  by_cases hS : S.Nonempty
  · simp only [rankPotential, if_pos hS, if_pos (hS.mono hST)]
    linarith only [energyMinimum_antitone a p hS hST]
  · rw [rankPotential, if_neg hS]
    exact rankPotential_nonneg a p offset hoff hbound T

lemma separated_minimizers (a : Fin m → Fin D → ℝ) (p : U → Fin D → ℝ)
    {K : Type*} (x : K → U) (H : K → Finset U) (r : ℝ) (hr : 0 < r)
    (hmem : ∀ i, x i ∈ H i)
    (hball : ∀ i y, y ∈ H i → rankOneDistance a (p (x i)) (p y) ≤ r/64)
    (hsep : ∀ i j, i ≠ j → r ≤ rankOneDistance a (p (x i)) (p (x j))) :
    ∀ i j, i ≠ j → (r/32)^2 ≤
      rankOneMetricSquared a (energyMinimizer a p (H i)) (energyMinimizer a p (H j)) := by
  intro i j hij
  have hi := energyMinimizer_in_ball a p (H i) ⟨x i, hmem i⟩ (p (x i)) (r/64) (by positivity) (hball i)
  have hj := energyMinimizer_in_ball a p (H j) ⟨x j, hmem j⟩ (p (x j)) (r/64) (by positivity) (hball j)
  have htri₁ := rankOneDistance_triangle a (p (x i)) (p (x j)) (energyMinimizer a p (H i))
  have htri₂ := rankOneDistance_triangle a (energyMinimizer a p (H i)) (p (x j)) (energyMinimizer a p (H j))
  rw [rankOneDistance_symm a (energyMinimizer a p (H j)) (p (x j))] at htri₂
  have hd : r/32 ≤ rankOneDistance a (energyMinimizer a p (H i)) (energyMinimizer a p (H j)) := by
    linarith only [hsep i j hij, htri₁, htri₂, hi, hj, hr]
  rw [← rankOneDistance_sq]
  exact pow_le_pow_left₀ (by positivity) hd 2

lemma entropy_gap_numeric (g η V L r w : ℝ)
    (hg : 0 ≤ g) (hη : 0 < η) (hV : 0 < V) (hL : 0 ≤ L)
    (hr : 0 ≤ r) (hw : 0 ≤ w)
    (hentropy : w^2*(r/32)^2 ≤ 128*g^2*V*L+128*g*V) :
    r*w/(512*Real.sqrt (V*(L+1/η))) ≤ g+η := by
  have hA : 0 < V*(L+1/η) := by positivity
  have hspos : 0 < Real.sqrt (V*(L+1/η)) := Real.sqrt_pos.2 hA
  have hssq : Real.sqrt (V*(L+1/η))^2 = V*(L+1/η) := Real.sq_sqrt hA.le
  have hfirst : g^2*L ≤ (g+η)^2*L :=
    mul_le_mul_of_nonneg_right (pow_le_pow_left₀ hg (by linarith only [hη]) 2) hL
  have hsecond : g ≤ (g+η)^2/η := by
    apply (le_div_iff₀ hη).2
    nlinarith only [sq_nonneg g, mul_nonneg hg hη.le, sq_nonneg η]
  have htotal : g^2*L+g ≤ (L+1/η)*(g+η)^2 := by
    calc
      _ ≤ (g+η)^2*L+(g+η)^2/η := add_le_add hfirst hsecond
      _ = _ := by ring
  have hmul := mul_le_mul_of_nonneg_left htotal (show 0 ≤ 131072*V by positivity)
  have hscaled : (r*w)^2 ≤ 131072*V*(g^2*L+g) := by nlinarith only [hentropy]
  have hlarge : 0 ≤ V*(L+1/η)*(g+η)^2 := by positivity
  have hfinal : (r*w)^2 ≤ (512*Real.sqrt (V*(L+1/η))*(g+η))^2 := by
    simp only [mul_pow, hssq]
    nlinarith only [hscaled, hmul, hlarge]
  have hroot := (sq_le_sq₀ (mul_nonneg hr hw) (show 0 ≤ 512*Real.sqrt (V*(L+1/η))*(g+η) by positivity)).mp hfinal
  exact (div_le_iff₀ (by positivity : 0 < 512*Real.sqrt (V*(L+1/η)))).2 (by nlinarith only [hroot])

/-- This is a proved growth inequality for the actual energy potential.
All geometric and cardinality inputs refer to the literal row process. -/
theorem rankPotential_growth {K : Type*} [Fintype K] [Nonempty K]
    (a : Fin m → Fin D → ℝ) (p : U → Fin D → ℝ)
    (C : Finset U) (x : K → U) (H : K → Finset U)
    (V η r w offset : ℝ) (hm : 0 < m) (hV : 0 < V) (hη : 0 < η) (hr : 0 < r)
    (hw : 0 ≤ w) (hoff : 0 ≤ offset)
    (hvar : ∀ i, (∑ j, a i j^2) ≤ V)
    (hrow : ∀ y, (∑ i, linearEvaluation (a i) (p y)^2) ≤ 1)
    (hmem : ∀ i, x i ∈ H i) (hsub : ∀ i, H i ⊆ C)
    (hball : ∀ i y, y ∈ H i → rankOneDistance a (p (x i)) (p y) ≤ r/64)
    (hsep : ∀ i j, i ≠ j → r ≤ rankOneDistance a (p (x i)) (p (x j)))
    (hcard : w^2 ≤ Real.log ((Fintype.card K:ℝ)/2))
    (t : ℝ) (ht : ∀ i, t ≤ rankPotential a p offset (H i)) :
    r*w/(512*Real.sqrt (V*(Real.log (8*(m:ℝ))+1/η)))+t ≤
      rankPotential a p (offset+η) C := by
  let i₀ : K := Classical.choice inferInstance
  have hH (i : K) : (H i).Nonempty := ⟨x i, hmem i⟩
  have hC : C.Nonempty := (hH i₀).mono (hsub i₀)
  let θ : ℝ := 2+offset-t
  let g : ℝ := θ-energyMinimum a p C
  have hmin (i : K) : energyMinimum a p (H i) ≤ θ := by
    have h := ht i
    rw [rankPotential, if_pos (hH i)] at h
    dsimp only [θ]
    linarith only [h]
  have hg : 0 ≤ g := by
    dsimp only [g]
    exact sub_nonneg.mpr ((energyMinimum_antitone a p (hH i₀) (hsub i₀)).trans (hmin i₀))
  have henergy (i : K) : rankOneEnergy a
      (fun j => energyMinimizer a p (H i) j-energyMinimizer a p C j) ≤ 2*g := by
    have h := energyMinimizer_gap a p (hH i) (hsub i)
    dsimp only [g]
    linarith only [h, hmin i]
  have hz : (∑ i, linearEvaluation (a i) (energyMinimizer a p C)^2) ≤ 1 :=
    indexedHull_rowEnergy_le a p C 1 (fun y _ => hrow y) (energyMinimizer_mem a p C hC)
  have hent := rankOne_local_packing_log a (energyMinimizer a p C)
    (fun i => energyMinimizer a p (H i)) V (2*g) (r/32) hm hV (by positivity) (by positivity)
    hvar hz henergy (separated_minimizers a p x H r hr hmem hball hsep)
  have hsmall := mul_le_mul_of_nonneg_right hcard (sq_nonneg (r/32))
  have hmc : (1:ℝ) ≤ m := by exact_mod_cast hm
  have hL : 0 ≤ Real.log (8*(m:ℝ)) := Real.log_nonneg (by linarith only [hmc])
  have hnum := entropy_gap_numeric g η V (Real.log (8*(m:ℝ))) r w hg hη hV hL hr.le hw
    (show w^2*(r/32)^2 ≤ 128*g^2*V*Real.log (8*(m:ℝ))+128*g*V by nlinarith only [hent, hsmall])
  rw [rankPotential, if_pos hC]
  dsimp only [g, θ] at hnum
  linarith only [hnum]

lemma growth_family_log (h : ℕ) :
    ((2:ℝ)^h)^2 ≤ Real.log (((2^(4^(h+1)) : ℕ):ℝ)/2) := by
  have hlog : (1:ℝ)/2 ≤ Real.log 2 := by
    have hh := Real.one_sub_inv_le_log_of_pos (show (0:ℝ)<2 by norm_num)
    norm_num at hh ⊢
    exact hh
  have hpow : ((2:ℝ)^h)^2 = (4:ℝ)^h := by
    rw [← pow_mul, Nat.mul_comm h 2, pow_mul]
    norm_num
  rw [hpow, Real.log_div (by positivity) (by norm_num), Nat.cast_pow, Real.log_pow]
  norm_num only [Nat.cast_ofNat, Nat.cast_pow]
  have hfour : (1:ℝ) ≤ 4^h := one_le_pow₀ (by norm_num)
  have hmul := mul_le_mul_of_nonneg_left hlog (show 0 ≤ 4*(4:ℝ)^h-1 by linarith only [hfour])
  rw [pow_succ]
  nlinarith only [hmul, hfour]

/-- The exact finite-growth interface used by the constructive chaining tree. -/
theorem rankPotential_growthAt
    (a : Fin m → Fin D → ℝ) (p : U → Fin D → ℝ)
    (V η offset : ℝ) (h : ℕ) (hm : 0 < m) (hV : 0 < V) (hη : 0 < η) (hoff : 0 ≤ offset)
    (hvar : ∀ i, (∑ j, a i j^2) ≤ V)
    (hrow : ∀ y, (∑ i, linearEvaluation (a i) (p y)^2) ≤ 1) :
    GrowthCover.GrowthAt (fun x y => rankOneDistance a (p x) (p y))
      (rankPotential a p offset) (rankPotential a p (offset+η))
      (2^(4^(h+1))) (1/(512*Real.sqrt (V*(Real.log (8*(m:ℝ))+1/η)))) (2^h) := by
  have hk : 0 < 2^(4^(h+1)) := by positivity
  letI : Nonempty (Fin (2^(4^(h+1)))) := Fin.pos_iff_nonempty.mp hk
  intro C r hr x H hmem hsub hball hsep t ht
  have hh := rankPotential_growth a p C x H V η r (2^h) offset hm hV hη hr
    (by positivity) hoff hvar hrow hmem hsub hball (fun i j hij => (hsep i j hij).1)
    (by simpa only [Fintype.card_fin] using growth_family_log h) t ht
  convert hh using 1 <;> ring

end NeuralGeneralization.SquaredSampling
