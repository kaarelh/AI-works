import NeuralGeneralization.RankOneGrowth
import NeuralGeneralization.FiniteChaining

/-!
# Finite empirical squared-process bootstrap

This combines the literal finite symmetrization theorem with conditional
Rademacher estimates. The majorant's own quadratic process controls the
normalizing empirical energy; the conclusion has no random norm term.
-/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.SquaredSampling

variable {X U : Type*} [Fintype X] [Nonempty X] [Fintype U] [Nonempty U]

lemma finiteMean_square_jensen (f : X → ℝ) : finiteMean f^2 ≤ finiteMean (fun x => f x^2) := by
  have hc : (Fintype.card X:ℝ) ≠ 0 := by positivity
  have h := weighted_square_jensen (fun _ : X => 1/(Fintype.card X:ℝ)) f
    (fun _ => by positivity) (by simp)
  simp only [← Finset.mul_sum] at h
  simpa only [finiteMean, one_div, div_eq_mul_inv, mul_comm, mul_one] using h

lemma finiteMean_sqrt_square (f : X → ℝ) (hf : ∀ x, 0 ≤ f x) :
    (finiteMean (fun x => Real.sqrt (f x)))^2 ≤ finiteMean f := by
  have h := finiteMean_square_jensen (fun x => Real.sqrt (f x))
  simpa only [Real.sq_sqrt (hf _)] using h

lemma envelope_nonneg_finite (f : U → ℝ) : 0 ≤ envelope f := by
  obtain ⟨u⟩ := ‹Nonempty U›
  exact (abs_nonneg _).trans (le_envelope_finite f u)

lemma sampleTotal_nonneg (n : ℕ) (G : U → X → ℝ) (hG : ∀ u x, 0 ≤ G u x)
    (s : Fin n → X) (u : U) : 0 ≤ sampleTotal G s u :=
  Finset.sum_nonneg (fun i _ => hG u (s i))

lemma sampleEnvelope_le_deviation (n : ℕ) (G : U → X → ℝ)
    (hG : ∀ u x, 0 ≤ G u x) (hpop : ∀ u, finiteMean (G u) ≤ 1) (s : Fin n → X) :
    envelope (sampleTotal G s) ≤ (n:ℝ)+
      envelope (fun u => sampleTotal G s u-(n:ℝ)*finiteMean (G u)) := by
  apply envelope_le
  intro u
  rw [abs_of_nonneg (sampleTotal_nonneg n G hG s u)]
  have h := le_envelope_finite (fun u => sampleTotal G s u-(n:ℝ)*finiteMean (G u)) u
  have hh := le_abs_self (sampleTotal G s u-(n:ℝ)*finiteMean (G u))
  have hpop' := mul_le_mul_of_nonneg_left (hpop u) (Nat.cast_nonneg n : (0:ℝ)≤n)
  nlinarith only [h, hh, hpop']

lemma finite_rademacher_symmetrization_finite (n : ℕ) (F : U → X → ℝ) :
    finiteMean (fun s : Fin n → X =>
      envelope (fun u => sampleTotal F s u-(n:ℝ)*finiteMean (F u))) ≤
      2*finiteMean (fun s : Fin n → X =>
        finiteMean (fun ε : Fin n → Bool => envelope (signedTotal F ε s))) := by
  obtain ⟨v, hv⟩ := Finite.exists_max (fun ux : U × X => |F ux.1 ux.2|)
  have h := finite_rademacher_symmetrization_centered n F (fun u x => hv (u,x))
  rwa [finiteMean_comm] at h

/-- A deterministic quadratic inequality removes the self-normalizing
empirical square norm. -/
lemma square_bootstrap (A B Y : ℝ) (hA : 0 ≤ A) (hB : 0 ≤ B) (hY : 0 ≤ Y)
    (h : Y^2 ≤ B+2*A*Y) : Y ≤ 2*A+Real.sqrt B := by
  have hs := Real.sqrt_nonneg B
  have hsq := Real.sq_sqrt hB
  by_contra hn
  have hgt : 2*A+Real.sqrt B < Y := lt_of_not_ge hn
  have hprod : 0 < (Y-(2*A+Real.sqrt B))*(Y+Real.sqrt B) := by
    apply mul_pos <;> linarith only [hgt, hA, hs]
  nlinarith only [hprod, h, hsq, mul_nonneg hA hs]

/-- Conditional actual Rademacher estimates for a response and its
quadratic majorant imply a uniform population/sample deviation bound. -/
theorem finite_squared_process_bootstrap (n : ℕ) (F G : U → X → ℝ) (A : ℝ)
    (hA : 0 ≤ A) (hG : ∀ u x, 0 ≤ G u x) (hpop : ∀ u, finiteMean (G u) ≤ 1)
    (hradG : ∀ s : Fin n → X,
      finiteMean (fun ε : Fin n → Bool => envelope (signedTotal G ε s)) ≤
        A*Real.sqrt (envelope (sampleTotal G s)+1))
    (hradF : ∀ s : Fin n → X,
      finiteMean (fun ε : Fin n → Bool => envelope (signedTotal F ε s)) ≤
        A*Real.sqrt (envelope (sampleTotal G s)+1)) :
    finiteMean (fun s : Fin n → X =>
      envelope (fun u => sampleTotal F s u-(n:ℝ)*finiteMean (F u))) ≤
      4*A^2+2*A*Real.sqrt ((n:ℝ)+1) := by
  let S := fun s : Fin n → X => envelope (sampleTotal G s)
  let Y : ℝ := finiteMean (fun s : Fin n → X => Real.sqrt (S s+1))
  let Z := fun s : Fin n → X =>
    envelope (fun u => sampleTotal G s u-(n:ℝ)*finiteMean (G u))
  have hY : 0 ≤ Y := finiteMean_nonneg (fun _ => Real.sqrt_nonneg _)
  have hYsq : Y^2 ≤ finiteMean (fun s : Fin n → X => S s+1) :=
    finiteMean_sqrt_square _ (fun s => by have hs := envelope_nonneg_finite (sampleTotal G s); dsimp only [S]; linarith)
  have hS : finiteMean (fun s : Fin n → X => S s+1) ≤ (n:ℝ)+1+finiteMean Z := by
    have hh := finiteMean_mono (fun s => add_le_add_right (sampleEnvelope_le_deviation n G hG hpop s) 1)
    simp only [finiteMean_add, finiteMean_const] at hh
    dsimp only [S, Z]
    rw [finiteMean_add, finiteMean_const]
    linarith only [hh]
  have hZ : finiteMean Z ≤ 2*A*Y := by
    have hs := finite_rademacher_symmetrization_finite n G
    have hh := finiteMean_mono hradG
    rw [finiteMean_mul] at hh
    dsimp only [Z, Y, S]
    nlinarith only [hs, hh]
  have hYbound := square_bootstrap A ((n:ℝ)+1) Y hA (by positivity) hY
    (hYsq.trans (hS.trans (by linarith only [hZ])))
  have hs := finite_rademacher_symmetrization_finite n F
  have hh := finiteMean_mono hradF
  rw [finiteMean_mul] at hh
  have hlast := mul_le_mul_of_nonneg_left hYbound (show 0 ≤ 2*A by positivity)
  dsimp only [Y, S] at hlast
  nlinarith only [hs, hh, hlast]

end NeuralGeneralization.SquaredSampling
