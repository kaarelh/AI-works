import Paulsen.ConditionedSeedEvents
import Paulsen.DensePerturbation
import Paulsen.PolarGram
import Paulsen.GraphCorrection

/-! Deterministic assembly of a huge-row seed from scalar error budgets. -/

namespace Paulsen

open Matrix
open scoped BigOperators

noncomputable section

theorem largeNeighbors_card_comp_equiv {ι κ : Type*}
    [Fintype ι] [Fintype κ] [DecidableEq ι] [DecidableEq κ]
    (e : κ ≃ ι) (w : ι → ι → ℝ) (γ : ℝ) (i : κ) :
    (largeNeighbors (fun a b => w (e a) (e b)) γ i).card =
      (largeNeighbors w γ (e i)).card := by
  classical
  unfold largeNeighbors
  rw [Fintype.card_congr e]
  apply Finset.card_equiv e
  intro j
  simp

/-- An explicit exceptional set can be used without manually relabeling rows. -/
theorem correction_of_exceptional_set {n d : ℕ}
    (hd : 0 < d) (hdn : d ≤ n) (U : Frame n d) (ε γ : ℝ)
    (hU : IsParseval U) (hUn : IsNearlyEqualNorm ε U)
    (hε : 0 ≤ ε) (hγ : 0 < γ) (hγa : γ ≤ (d : ℝ) / n)
    (S : Finset (Fin n)) (htrace : (∑ i ∈ S, rowNormSq U i) ≤ 1 / 4)
    (hbad : 10 * S.card ≤ n)
    (hdense : ∀ i ∉ S, 4 * n ≤
      5 * (largeNeighbors (fun i j => (frameProjection U i j) ^ 2) γ i).card)
    (hsmall : 112 * ε * ((d : ℝ) / n) ≤ γ) :
    HasCorrection U (8 * ε * (d : ℝ)) := by
  classical
  let good : Set (Fin n) := {i | i ∉ S}
  let e := Equiv.Set.sumCompl good
  have hn : 0 < n := lt_of_lt_of_le hd hdn
  have hSc : S.card < (Finset.univ : Finset (Fin n)).card := by
    simp only [Finset.card_univ, Fintype.card_fin]
    omega
  obtain ⟨i, _, hi⟩ := Finset.exists_mem_notMem_of_card_lt_card hSc
  letI : Nonempty good := ⟨⟨i, hi⟩⟩
  have hcard : Fintype.card (goodᶜ : Set (Fin n)) = S.card := by
    simp [good, Fintype.card_subtype]
  apply sharp_correction_of_small_exceptional_leverage e hd hdn U ε γ
    hU hUn hε hγ hγa
  · have heq : (∑ j : (goodᶜ : Set (Fin n)), rowNormSq U j) =
        ∑ i ∈ S, rowNormSq U i :=
      (Finset.sum_subtype S (fun i => by simp [good]) (rowNormSq U)).symm
    simpa only [e, Equiv.Set.sumCompl_apply_inr, heq] using htrace
  · simpa [hcard] using hbad
  · intro j
    rw [largeNeighbors_card_comp_equiv e (fun a b => (frameProjection U a b) ^ 2) γ]
    exact hdense j j.property
  · exact hsmall

theorem rowNormSq_sub_comm {n d : ℕ} (A B : Frame n d) (i : Fin n) :
    rowNormSq (A - B) i = rowNormSq (B - A) i := by
  simp only [rowNormSq, Matrix.sub_apply]
  apply Finset.sum_congr rfl
  intro j _
  ring

theorem rowNormSq_sub_triangle {n d : ℕ} (A B C : Frame n d) (i : Fin n) :
    rowNormSq (A - C) i ≤ 2 * rowNormSq (A - B) i + 2 * rowNormSq (B - C) i := by
  simp only [rowNormSq, Matrix.sub_apply, Finset.mul_sum, ← Finset.sum_add_distrib]
  apply Finset.sum_le_sum
  intro j _
  nlinarith [sq_nonneg (A i j - 2 * B i j + C i j)]

/-- Dense entries of a reference Gram matrix give a correction after a
controlled perturbation and polar normalization. Every graph hypothesis is
discharged from the displayed scalar budgets. -/
theorem correction_of_dense_reference_gram_generic {n d : ℕ}
    (hd : 0 < d) (hdn : d ≤ n) (V : Frame n d) (A : Frame n n)
    (δ γ ρ B : ℝ) (hVn : IsEqualNorm V)
    (hVp : IsNearlyParseval δ V) (hδ0 : 0 ≤ δ) (hδhalf : δ ≤ 1 / 2)
    (hγ : 0 < γ) (hγa : γ ≤ (d : ℝ) / n) (hρ : 0 < ρ)
    (hdense : ∀ i, 17 * n ≤
      20 * (largeNeighbors (fun i j => (A i j) ^ 2) (4 * γ) i).card)
    (herror : sqDistance A (frameProjection V) ≤ B)
    (hrow : 12 * ((d : ℝ) / n) * δ ^ 2 + 2 * ρ ≤ γ / 20)
    (hcount : 10 * B ≤ ρ * n)
    (hleverage : (2 * ((d : ℝ) / n) / ρ) * B ≤ 1 / 4)
    (hsmall : 224 * δ * ((d : ℝ) / n) ≤ γ) :
    HasCorrection V (2 * δ ^ 2 * (d : ℝ) + 32 * δ * (d : ℝ)) := by
  classical
  have hn : 0 < n := lt_of_lt_of_le hd hdn
  letI : NeZero n := ⟨Nat.ne_of_gt hn⟩
  obtain ⟨U, hUp, hUn, hcost, hpolar⟩ :=
    exists_polar_normalization_row_gram V δ hδ0 hδhalf hVn hVp
  let S := Finset.univ.filter (fun i => ρ < rowNormSq (A - frameProjection V) i)
  have hbad : 10 * S.card ≤ n := by
    have he := (exceptional_rows_energy_le A (frameProjection V) ρ).trans herror
    change ρ * (S.card : ℝ) ≤ B at he
    have hcard : 10 * (S.card : ℝ) ≤ (n : ℝ) := by nlinarith
    exact_mod_cast hcard
  have hupper (i : Fin n) : rowNormSq U i ≤ 2 * ((d : ℝ) / n) := by
    have hi := (hUn i).2
    have ha : 0 ≤ (d : ℝ) / n := by positivity
    nlinarith
  have htrace : (∑ i ∈ S, rowNormSq U i) ≤ 1 / 4 := by
    have he := exceptional_rows_leverage_le A (frameProjection V) (rowNormSq U) ρ
      (2 * ((d : ℝ) / n)) hρ (by positivity) hupper
    apply he.trans
    apply le_trans _ hleverage
    exact mul_le_mul_of_nonneg_left herror (by positivity)
  have hdenseU (i : Fin n) (hi : i ∉ S) : 4 * n ≤
      5 * (largeNeighbors (fun i j => (frameProjection U i j) ^ 2) γ i).card := by
    have hcut : rowNormSq (A - frameProjection V) i ≤ ρ := by
      simpa only [S, Finset.mem_filter, Finset.mem_univ, true_and, not_lt] using hi
    have hpol : rowNormSq (frameProjection V - frameProjection U) i ≤
        6 * ((d : ℝ) / n) * δ ^ 2 := by
      rw [rowNormSq_sub_comm]
      exact hpolar i
    have herr : (∑ j, (A i j - frameProjection U i j) ^ 2) ≤ γ / 20 := by
      have ht := rowNormSq_sub_triangle A (frameProjection V) (frameProjection U) i
      change rowNormSq (A - frameProjection U) i ≤ γ / 20
      linarith
    simpa only [Fintype.card_fin] using
      dense_neighbors_survive_perturbation A (frameProjection U) γ hγ i (by
        simpa only [Fintype.card_fin] using hdense i) herr
  have hcorr := correction_of_exceptional_set hd hdn U (2 * δ) γ
    hUp hUn (by positivity) hγ hγa S htrace hbad hdenseU (by nlinarith)
  convert hcorr.transfer hcost using 1
  ring

theorem euclidean_operator_norm_sq_le_of_frameEnergy {n d : ℕ}
    (V : Frame n d) (K : ℝ) (hK : 0 ≤ K)
    (hV : ∀ x, frameEnergy V x ≤ K * vectorNormSq x) :
    ‖(Matrix.toEuclideanLin V).toContinuousLinearMap‖ ^ 2 ≤ K := by
  have hs : (Real.sqrt K) ^ 2 = K := Real.sq_sqrt hK
  have hop : ‖(Matrix.toEuclideanLin V).toContinuousLinearMap‖ ≤ Real.sqrt K := by
    apply ContinuousLinearMap.opNorm_le_bound _ (Real.sqrt_nonneg _)
    intro x
    have hsq : ‖Matrix.toEuclideanLin V x‖ ^ 2 ≤ K * ‖x‖ ^ 2 := by
      simpa only [EuclideanSpace.real_norm_sq_eq, Matrix.toLpLin_apply,
        frameEnergy, vectorNormSq, Matrix.mulVec, dotProduct] using hV x.ofLp
    change ‖Matrix.toEuclideanLin V x‖ ≤ Real.sqrt K * ‖x‖
    have hnonneg := mul_nonneg (Real.sqrt_nonneg K) (norm_nonneg x)
    have hprod : (Real.sqrt K * ‖x‖) ^ 2 = K * ‖x‖ ^ 2 := by rw [mul_pow, hs]
    nlinarith [norm_nonneg (Matrix.toEuclideanLin V x)]
  exact (pow_le_pow_left₀ (norm_nonneg _) hop 2).trans_eq hs

theorem tangentSeed_operator_norm_sq_le {n d : ℕ}
    (X Z : Frame n d) (a t η H : ℝ) (ha : 0 < a)
    (hη : 0 ≤ η) (hXp : IsNearlyParseval η X)
    (hH : (∑ i, rowNormSq Z i) ≤ H) :
    ‖(Matrix.toEuclideanLin (tangentSeed X Z a t)).toContinuousLinearMap‖ ^ 2 ≤
      2 * (1 + η) + 2 * t ^ 2 * H := by
  have hH0 : 0 ≤ H := (Finset.sum_nonneg fun i _ => rowNormSq_nonneg Z i).trans hH
  apply euclidean_operator_norm_sq_le_of_frameEnergy _ _ (by positivity)
  intro x
  apply (frameEnergy_tangentSeed_le X Z a t η ha hXp x).trans
  exact mul_le_mul_of_nonneg_right
    (add_le_add le_rfl (mul_le_mul_of_nonneg_left hH (by positivity))) (vectorNormSq_nonneg x)

/-- The Gram coupling follows solely from total noise energy and the
Lipschitz property of tangent normalization. -/
theorem tangentSeed_gram_coupling_le {n d : ℕ}
    (X Z Z₀ : Frame n d) (a t η δ H₀ C : ℝ) (ha : 0 < a)
    (hη : 0 ≤ η) (hδ : 0 ≤ δ) (hXn : ∀ i, rowNormSq X i = a)
    (hXp : IsNearlyParseval η X) (hZ : ∀ i, rowDot X Z i = 0)
    (hZ₀ : ∀ i, rowDot X Z₀ i = 0)
    (hVp : IsNearlyParseval δ (tangentSeed X Z a t))
    (hH₀ : (∑ i, rowNormSq Z₀ i) ≤ H₀) (hC : sqDistance Z₀ Z ≤ C) :
    sqDistance (frameProjection (tangentSeed X Z₀ a t))
      (frameProjection (tangentSeed X Z a t)) ≤
        2 * (2 * (1 + η) + 2 * t ^ 2 * H₀ + 1 + δ) * t ^ 2 * C := by
  have hH₀0 : 0 ≤ H₀ := (Finset.sum_nonneg fun i _ => rowNormSq_nonneg Z₀ i).trans hH₀
  have hnorm₀ := tangentSeed_operator_norm_sq_le X Z₀ a t η H₀ ha hη hXp hH₀
  have hnorm := hVp.euclidean_operator_norm_sq_le hδ
  have hdist := (tangentSeed_sqDistance_le X Z₀ Z a t ha hXn hZ₀ hZ).trans
    (mul_le_mul_of_nonneg_left hC (sq_nonneg t))
  apply (sqDistance_gram_le (tangentSeed X Z₀ a t) (tangentSeed X Z a t)).trans
  calc
    _ ≤ (2 * ((2 * (1 + η) + 2 * t ^ 2 * H₀) + (1 + δ))) * (t ^ 2 * C) :=
      mul_le_mul (by linarith) hdist (sqDistance_nonneg _ _) (by positivity)
    _ = _ := by ring

/-- Complete deterministic huge-seed implication. The reference seed supplies
the dense counts; every other hypothesis is a scalar error or size budget. -/
theorem huge_seed_correction_of_budgets_generic {n d : ℕ}
    (hd : 0 < d) (hdn : d ≤ n) (X Z Z₀ : Frame n d)
    (η t δ γ ρ H H₀ C : ℝ)
    (hXn : IsEqualNorm X) (hXp : IsNearlyParseval η X) (hη : 0 ≤ η)
    (hZ : ∀ i, rowDot X Z i = 0) (hZ₀ : ∀ i, rowDot X Z₀ i = 0)
    (hVp : IsNearlyParseval δ (tangentSeed X Z ((d : ℝ) / n) t))
    (hδ0 : 0 ≤ δ) (hδhalf : δ ≤ 1 / 2)
    (hH : (∑ i, rowNormSq Z i) ≤ H) (hH₀ : (∑ i, rowNormSq Z₀ i) ≤ H₀)
    (hC : sqDistance Z₀ Z ≤ C) (hγ : 0 < γ) (hγa : γ ≤ (d : ℝ) / n) (hρ : 0 < ρ)
    (hdense : ∀ i, 17 * n ≤ 20 * (largeNeighbors
      (fun i j => (frameProjection (tangentSeed X Z₀ ((d : ℝ) / n) t) i j) ^ 2)
        (4 * γ) i).card)
    (hrow : 12 * ((d : ℝ) / n) * δ ^ 2 + 2 * ρ ≤ γ / 20)
    (hcount : 10 * (2 * (2 * (1 + η) + 2 * t ^ 2 * H₀ + 1 + δ) * t ^ 2 * C) ≤ ρ * n)
    (hleverage : (2 * ((d : ℝ) / n) / ρ) *
      (2 * (2 * (1 + η) + 2 * t ^ 2 * H₀ + 1 + δ) * t ^ 2 * C) ≤ 1 / 4)
    (hsmall : 224 * δ * ((d : ℝ) / n) ≤ γ) :
    HasCorrection X (2 * t ^ 2 * H + 4 * δ ^ 2 * (d : ℝ) + 64 * δ * (d : ℝ)) := by
  have ha : 0 < (d : ℝ) / n := div_pos (Nat.cast_pos.mpr hd)
    (Nat.cast_pos.mpr (lt_of_lt_of_le hd hdn))
  have hVn := tangentSeed_isEqualNorm X Z t ha hXn hZ
  have he := tangentSeed_gram_coupling_le X Z Z₀ ((d : ℝ) / n) t η δ H₀ C
    ha hη hδ0 hXn hXp hZ hZ₀ hVp hH₀ hC
  have hc := correction_of_dense_reference_gram_generic hd hdn
    (tangentSeed X Z ((d : ℝ) / n) t)
    (frameProjection (tangentSeed X Z₀ ((d : ℝ) / n) t)) δ γ ρ _
    hVn hVp hδ0 hδhalf hγ hγa hρ hdense he hrow hcount hleverage hsmall
  have hdistance : sqDistance X (tangentSeed X Z ((d : ℝ) / n) t) ≤ t ^ 2 * H := by
    rw [sqDistance_symm]
    exact (tangentSeed_distance_from_input X Z ((d : ℝ) / n) t ha hXn hZ).trans
      (mul_le_mul_of_nonneg_left hH (sq_nonneg t))
  convert hc.transfer hdistance using 1
  ring

theorem rowTangentNoiseFactor_constraints {n d : ℕ} (X : Frame n d) (g : FrameVector n d) :
    ∀ i, rowDot X (frameOfVector (Matrix.toEuclideanLin (rowTangentNoiseFactor X) g)) i = 0 := by
  apply (mem_rowTangentSpace X _).mp
  rw [rowTangentNoiseFactor_apply]
  exact (rowTangentSpace X).smul_mem _ ((rowTangentSpace X).starProjection_apply_mem g)

theorem IsNearlyParseval.mono {n d : ℕ} {X : Frame n d} {η δ : ℝ}
    (hX : IsNearlyParseval η X) (hηδ : η ≤ δ) : IsNearlyParseval δ X := by
  intro x
  have h := hX x
  have hm := mul_le_mul_of_nonneg_right hηδ (vectorNormSq_nonneg x)
  constructor <;> nlinarith

/-- The deterministic implication instantiated with the actual coupled
Gaussian noises. Fluctuation and remainder budgets imply the spectral error;
no covariance or graph estimates are assumed beyond the dense row counts. -/
theorem conditioned_seed_correction_of_sample_generic {n d : ℕ}
    (hd : 0 < d) (hdn : d ≤ n) (X : Frame n d)
    (η t δ γ ρ H C b r : ℝ) (g : FrameVector n d)
    (hXn : IsEqualNorm X) (hXp : IsNearlyParseval η X) (hη : 0 ≤ η)
    (hH : (∑ i, rowNormSq (conditionedNoise X g) i) ≤ H)
    (hC : sqDistance (frameOfVector (Matrix.toEuclideanLin (rowTangentNoiseFactor X) g))
      (conditionedNoise X g) ≤ C)
    (hb : ‖conditionedFluctuation X g‖ ≤ b)
    (hr : tangentRemainderBudget (conditionedNoise X g) ((d : ℝ) / n) t ≤ r)
    (hδbound : η + t ^ 2 * (η + (d : ℝ) ^ 2 / n + b) + r ≤ δ)
    (hδ0 : 0 ≤ δ) (hδhalf : δ ≤ 1 / 2)
    (hγ : 0 < γ) (hγa : γ ≤ (d : ℝ) / n) (hρ : 0 < ρ)
    (hdense : ∀ i, 17 * n ≤ 20 * (largeNeighbors
      (fun i j => (frameProjection (tangentSeed X
        (frameOfVector (Matrix.toEuclideanLin (rowTangentNoiseFactor X) g))
        ((d : ℝ) / n) t) i j) ^ 2) (4 * γ) i).card)
    (hrow : 12 * ((d : ℝ) / n) * δ ^ 2 + 2 * ρ ≤ γ / 20)
    (hcount : 10 * (2 * (2 * (1 + η) + 2 * t ^ 2 * (2 * H + 2 * C) + 1 + δ) * t ^ 2 * C)
      ≤ ρ * n)
    (hleverage : (2 * ((d : ℝ) / n) / ρ) *
      (2 * (2 * (1 + η) + 2 * t ^ 2 * (2 * H + 2 * C) + 1 + δ) * t ^ 2 * C) ≤ 1 / 4)
    (hsmall : 224 * δ * ((d : ℝ) / n) ≤ γ) :
    HasCorrection X (2 * t ^ 2 * H + 4 * δ ^ 2 * (d : ℝ) + 64 * δ * (d : ℝ)) := by
  have hn : 0 < n := lt_of_lt_of_le hd hdn
  have hVp : IsNearlyParseval δ (conditionedSeed X t g) := by
    exact (conditionedSeed_equalNorm_and_nearParseval X hn hd hXn η t b r hXp g hb hr).2.mono hδbound
  have hH₀ : (∑ i, rowNormSq
      (frameOfVector (Matrix.toEuclideanLin (rowTangentNoiseFactor X) g)) i) ≤ 2 * H + 2 * C := by
    have he := rowTangentNoise_energy_le X g
    linarith
  exact huge_seed_correction_of_budgets_generic hd hdn X (conditionedNoise X g)
    (frameOfVector (Matrix.toEuclideanLin (rowTangentNoiseFactor X) g))
    η t δ γ ρ H (2 * H + 2 * C) C hXn hXp hη
    (tangentNoiseFactor_constraints X g).1 (rowTangentNoiseFactor_constraints X g)
    hVp hδ0 hδhalf hH hH₀ hC hγ hγa hρ hdense hrow hcount hleverage hsmall

/-- Compatibility form; full spark is not used by the construction. -/
theorem fullSpark_correction_of_exceptional_set {n d : ℕ}
    (hd : 0 < d) (hdn : d ≤ n) (U : Frame n d) (ε γ : ℝ)
    (_hUs : IsFullSpark U) (hU : IsParseval U) (hUn : IsNearlyEqualNorm ε U)
    (hε : 0 ≤ ε) (hγ : 0 < γ) (hγa : γ ≤ (d : ℝ) / n)
    (S : Finset (Fin n)) (htrace : (∑ i ∈ S, rowNormSq U i) ≤ 1 / 4)
    (hbad : 10 * S.card ≤ n)
    (hdense : ∀ i ∉ S, 4 * n ≤
      5 * (largeNeighbors (fun i j => (frameProjection U i j) ^ 2) γ i).card)
    (hsmall : 112 * ε * ((d : ℝ) / n) ≤ γ) :
    HasCorrection U (8 * ε * (d : ℝ)) := by
  exact correction_of_exceptional_set hd hdn U ε γ hU hUn hε hγ hγa S htrace hbad hdense hsmall

/-- Compatibility form; full spark is not used by the construction. -/
theorem correction_of_dense_reference_gram {n d : ℕ}
    (hd : 0 < d) (hdn : d ≤ n) (V : Frame n d) (A : Frame n n)
    (δ γ ρ B : ℝ) (_hVs : IsFullSpark V) (hVn : IsEqualNorm V)
    (hVp : IsNearlyParseval δ V) (hδ0 : 0 ≤ δ) (hδhalf : δ ≤ 1 / 2)
    (hγ : 0 < γ) (hγa : γ ≤ (d : ℝ) / n) (hρ : 0 < ρ)
    (hdense : ∀ i, 17 * n ≤
      20 * (largeNeighbors (fun i j => (A i j) ^ 2) (4 * γ) i).card)
    (herror : sqDistance A (frameProjection V) ≤ B)
    (hrow : 12 * ((d : ℝ) / n) * δ ^ 2 + 2 * ρ ≤ γ / 20)
    (hcount : 10 * B ≤ ρ * n)
    (hleverage : (2 * ((d : ℝ) / n) / ρ) * B ≤ 1 / 4)
    (hsmall : 224 * δ * ((d : ℝ) / n) ≤ γ) :
    HasCorrection V (2 * δ ^ 2 * (d : ℝ) + 32 * δ * (d : ℝ)) := by
  exact correction_of_dense_reference_gram_generic hd hdn V A δ γ ρ B hVn hVp hδ0 hδhalf hγ hγa hρ hdense herror hrow hcount hleverage hsmall

/-- Compatibility form; full spark is not used by the construction. -/
theorem huge_seed_correction_of_budgets {n d : ℕ}
    (hd : 0 < d) (hdn : d ≤ n) (X Z Z₀ : Frame n d)
    (η t δ γ ρ H H₀ C : ℝ)
    (hXn : IsEqualNorm X) (hXp : IsNearlyParseval η X) (hη : 0 ≤ η)
    (hZ : ∀ i, rowDot X Z i = 0) (hZ₀ : ∀ i, rowDot X Z₀ i = 0)
    (_hVs : IsFullSpark (tangentSeed X Z ((d : ℝ) / n) t))
    (hVp : IsNearlyParseval δ (tangentSeed X Z ((d : ℝ) / n) t))
    (hδ0 : 0 ≤ δ) (hδhalf : δ ≤ 1 / 2)
    (hH : (∑ i, rowNormSq Z i) ≤ H) (hH₀ : (∑ i, rowNormSq Z₀ i) ≤ H₀)
    (hC : sqDistance Z₀ Z ≤ C) (hγ : 0 < γ) (hγa : γ ≤ (d : ℝ) / n) (hρ : 0 < ρ)
    (hdense : ∀ i, 17 * n ≤ 20 * (largeNeighbors
      (fun i j => (frameProjection (tangentSeed X Z₀ ((d : ℝ) / n) t) i j) ^ 2)
        (4 * γ) i).card)
    (hrow : 12 * ((d : ℝ) / n) * δ ^ 2 + 2 * ρ ≤ γ / 20)
    (hcount : 10 * (2 * (2 * (1 + η) + 2 * t ^ 2 * H₀ + 1 + δ) * t ^ 2 * C) ≤ ρ * n)
    (hleverage : (2 * ((d : ℝ) / n) / ρ) *
      (2 * (2 * (1 + η) + 2 * t ^ 2 * H₀ + 1 + δ) * t ^ 2 * C) ≤ 1 / 4)
    (hsmall : 224 * δ * ((d : ℝ) / n) ≤ γ) :
    HasCorrection X (2 * t ^ 2 * H + 4 * δ ^ 2 * (d : ℝ) + 64 * δ * (d : ℝ)) := by
  exact huge_seed_correction_of_budgets_generic hd hdn X Z Z₀ η t δ γ ρ H H₀ C hXn hXp hη hZ hZ₀ hVp hδ0 hδhalf hH hH₀ hC hγ hγa hρ hdense hrow hcount hleverage hsmall

/-- Compatibility form; full spark is not used by the construction. -/
theorem conditioned_seed_correction_of_sample {n d : ℕ}
    (hd : 0 < d) (hdn : d ≤ n) (X : Frame n d)
    (η t δ γ ρ H C b r : ℝ) (g : FrameVector n d)
    (hXn : IsEqualNorm X) (hXp : IsNearlyParseval η X) (hη : 0 ≤ η)
    (_hVs : IsFullSpark (conditionedSeed X t g))
    (hH : (∑ i, rowNormSq (conditionedNoise X g) i) ≤ H)
    (hC : sqDistance (frameOfVector (Matrix.toEuclideanLin (rowTangentNoiseFactor X) g))
      (conditionedNoise X g) ≤ C)
    (hb : ‖conditionedFluctuation X g‖ ≤ b)
    (hr : tangentRemainderBudget (conditionedNoise X g) ((d : ℝ) / n) t ≤ r)
    (hδbound : η + t ^ 2 * (η + (d : ℝ) ^ 2 / n + b) + r ≤ δ)
    (hδ0 : 0 ≤ δ) (hδhalf : δ ≤ 1 / 2)
    (hγ : 0 < γ) (hγa : γ ≤ (d : ℝ) / n) (hρ : 0 < ρ)
    (hdense : ∀ i, 17 * n ≤ 20 * (largeNeighbors
      (fun i j => (frameProjection (tangentSeed X
        (frameOfVector (Matrix.toEuclideanLin (rowTangentNoiseFactor X) g))
        ((d : ℝ) / n) t) i j) ^ 2) (4 * γ) i).card)
    (hrow : 12 * ((d : ℝ) / n) * δ ^ 2 + 2 * ρ ≤ γ / 20)
    (hcount : 10 * (2 * (2 * (1 + η) + 2 * t ^ 2 * (2 * H + 2 * C) + 1 + δ) * t ^ 2 * C)
      ≤ ρ * n)
    (hleverage : (2 * ((d : ℝ) / n) / ρ) *
      (2 * (2 * (1 + η) + 2 * t ^ 2 * (2 * H + 2 * C) + 1 + δ) * t ^ 2 * C) ≤ 1 / 4)
    (hsmall : 224 * δ * ((d : ℝ) / n) ≤ γ) :
    HasCorrection X (2 * t ^ 2 * H + 4 * δ ^ 2 * (d : ℝ) + 64 * δ * (d : ℝ)) := by
  exact conditioned_seed_correction_of_sample_generic hd hdn X η t δ γ ρ H C b r g hXn hXp hη hH hC hb hr hδbound hδ0 hδhalf hγ hγa hρ hdense hrow hcount hleverage hsmall

end

end Paulsen
