import NeuralGeneralization.BatchTwoImprovedWeightedSymmetrization
import NeuralGeneralization.RudelsonFiniteRestriction

/-! # Weighted empirical-square bootstrap and rank-one Gram control -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoImprovedWeightedSampling
open SquaredSampling
variable {α U : Type*} [Fintype α] [Fintype U] [Nonempty U]

theorem sampleEnvelope_le_weighted_deviation (w : α → ℝ)
    (n : ℕ) (G : U → α → ℝ) (hG : ∀ u x, 0 ≤ G u x)
    (hpop : ∀ u, mean w (G u) ≤ 1) (s : Fin n → α) :
    envelope (sampleTotal G s) ≤ n+
      envelope (fun u => sampleTotal G s u-n*mean w (G u)) := by
  apply envelope_le
  intro u
  have hval : 0 ≤ sampleTotal G s u := Finset.sum_nonneg (fun i _ => hG u (s i))
  rw [abs_of_nonneg hval]
  have h := le_envelope_finite (fun u => sampleTotal G s u-n*mean w (G u)) u
  have habs := le_abs_self (sampleTotal G s u-n*mean w (G u))
  have hp := mul_le_mul_of_nonneg_left (hpop u) (Nat.cast_nonneg n : (0:ℝ) ≤ n)
  linarith

theorem weighted_squared_process_bootstrap (w : α → ℝ)
    (hw : ∀ x, 0 ≤ w x) (hm : ∑ x, w x = 1)
    (n : ℕ) (F G : U → α → ℝ) (A : ℝ)
    (hA : 0 ≤ A) (hG : ∀ u x, 0 ≤ G u x) (hpop : ∀ u, mean w (G u) ≤ 1)
    (hradG : ∀ s : Fin n → α,
      finiteMean (fun ε : Fin n → Bool => envelope (signedTotal G ε s)) ≤
        A*Real.sqrt (envelope (sampleTotal G s)+1))
    (hradF : ∀ s : Fin n → α,
      finiteMean (fun ε : Fin n → Bool => envelope (signedTotal F ε s)) ≤
        A*Real.sqrt (envelope (sampleTotal G s)+1)) :
    mean (iidWeight w n) (fun s =>
      envelope (fun u => sampleTotal F s u-n*mean w (F u))) ≤
      4*A^2+2*A*Real.sqrt ((n:ℝ)+1) := by
  let v := iidWeight w n
  have hv : ∀ s, 0 ≤ v s := iidWeight_nonneg w hw n
  have hvm : ∑ s, v s = 1 := iidWeight_mass w hm n
  let S := fun s : Fin n → α => envelope (sampleTotal G s)
  let Y := mean v (fun s => Real.sqrt (S s+1))
  let Z := fun s : Fin n → α => envelope (fun u => sampleTotal G s u-n*mean w (G u))
  have hY : 0 ≤ Y := mean_nonneg v hv (fun _ => Real.sqrt_nonneg _)
  have hYsq : Y^2 ≤ mean v (fun s => S s+1) :=
    mean_sqrt_square v hv hvm _ (fun s => by
      have hs := envelope_nonneg_finite (sampleTotal G s); dsimp only [S]; linarith)
  have hS : mean v (fun s => S s+1) ≤ (n:ℝ)+1+mean v Z := by
    have hh := mean_mono v hv (fun s => add_le_add_right
      (sampleEnvelope_le_weighted_deviation w n G hG hpop s) 1)
    simp only [mean_add, mean_const v hvm] at hh
    dsimp only [S, Z]
    rw [mean_add, mean_const v hvm]
    linarith only [hh]
  have hZ : mean v Z ≤ 2*A*Y := by
    have hs := weighted_rademacher_symmetrization w hw hm n G
    have hh := mean_mono v hv hradG
    rw [mean_mul] at hh
    dsimp only [Z, Y, S]
    nlinarith only [hs, hh]
  have hYbound := square_bootstrap A ((n:ℝ)+1) Y hA (by positivity) hY
    (hYsq.trans (hS.trans (by linarith only [hZ])))
  have hs := weighted_rademacher_symmetrization w hw hm n F
  have hh := mean_mono v hv hradF
  rw [mean_mul] at hh
  have hlast := mul_le_mul_of_nonneg_left hYbound (show 0 ≤ 2*A by positivity)
  dsimp only [Y, S] at hlast
  nlinarith only [hs, hh, hlast]

/-- The expected uniform covariance error for arbitrary finite sampling
weights, with only a logarithmic dependence on feature dimension. -/
theorem weighted_gram_deviation (w : α → ℝ)
    (hw : ∀ x, 0 ≤ w x) (hmass : ∑ x, w x = 1)
    {m D : ℕ} (hm : 0 < m) (a : α → Fin D → ℝ)
    (p : U → Fin D → ℝ) (u₀ : U) (hroot : p u₀ = 0)
    (V : ℝ) (hV : 0 < V) (ha : ∀ x, ∑ j, (a x j)^2 ≤ V)
    (hp : ∀ u, ∑ j, (p u j)^2 ≤ 1)
    (hpop : ∀ u, mean w (fun x => (linearEvaluation (a x) (p u))^2) ≤ 1) :
    mean (iidWeight w m) (fun s => envelope (fun u =>
      (∑ i, (linearEvaluation (a (s i)) (p u))^2) -
        m*mean w (fun x => (linearEvaluation (a x) (p u))^2))) ≤
      4*(268435456*Real.sqrt (V*restrictionLog m D))^2 +
        2*(268435456*Real.sqrt (V*restrictionLog m D))*Real.sqrt ((m:ℝ)+1) := by
  let F := fun u x => (linearEvaluation (a x) (p u))^2
  let A := 268435456*Real.sqrt (V*restrictionLog m D)
  have hrad (s : Fin m → α) :
      finiteMean (fun ε : Fin m → Bool => envelope (signedTotal F ε s)) ≤
        A*Real.sqrt (envelope (sampleTotal F s)+1) := by
    have he : empiricalSquareEnvelope (fun i => a (s i)) p = envelope (sampleTotal F s) := rfl
    have hR : 0 < envelope (sampleTotal F s)+1 := by
      have h := envelope_nonneg_finite (sampleTotal F s); linarith
    have hh := finite_row_rademacher_bound (fun i => a (s i)) p u₀ hroot V
      (envelope (sampleTotal F s)+1) hm hV hR (fun i => ha (s i)) hp
      (fun u => (rowEnergy_le_empiricalSquareEnvelope (fun i => a (s i)) p u).trans
        (by rw [he]; linarith))
    exact hh
  exact weighted_squared_process_bootstrap w hw hmass m F F A (by dsimp [A]; positivity)
    (fun _ _ => sq_nonneg _) hpop hrad hrad

end NeuralGeneralization.BatchTwoImprovedWeightedSampling
