import NeuralGeneralization.OnlineLowerReluSamplingEnergy
import Mathlib.Analysis.Real.Sqrt

/-!
# From balanced physical atoms to arbitrary affine atoms

This module is an explicit reduction. The remaining balanced-atom bound
is a named hypothesis here; it must be supplied by the physical
randomized-minimum theorem in the final rail theorem. The Fourier,
sampling-law, and energy steps are all proved rather than assumed.
-/

noncomputable section
open scoped BigOperators

namespace NeuralGeneralization.OnlineLowerRelu

variable {κ : Type*} [Fintype κ] [DecidableEq κ] {β : κ → Type*}
variable [∀ j, Fintype (β j)] [∀ j, Nonempty (β j)]

theorem uniformBlockAverage_mono (F G : ((j : κ) → β j) → ℝ)
    (h : ∀ pick, F pick ≤ G pick) : uniformBlockAverage F ≤ uniformBlockAverage G := by
  apply mul_le_mul_of_nonneg_left (Finset.sum_le_sum (fun pick _ => h pick))
  exact Finset.prod_nonneg (fun _ _ => inv_nonneg.mpr (Nat.cast_nonneg _))

theorem blockEnergy_nonneg (u : (j : κ) → β j → ℝ) : 0 ≤ blockEnergy u :=
  Finset.sum_nonneg (fun _ _ => Finset.sum_nonneg (fun _ _ => sq_nonneg _))

theorem uniformBlockAverage_sub (F G : ((j : κ) → β j) → ℝ) :
    uniformBlockAverage (fun pick => F pick - G pick) =
      uniformBlockAverage F - uniformBlockAverage G := by
  simp only [uniformBlockAverage, Finset.sum_sub_distrib, mul_sub]

/-- Complete arbitrary-weight norm reduction, with the still-separate
balanced physical mass inequality stated transparently as its premise. -/
theorem arbitrary_atom_mass_of_sampled_bound {d : ℕ} {ν : Type*} [Fintype ν]
    [MeasurableSpace ν] [MeasurableSingletonClass ν]
    (e : ((j : κ) × β j) ≃ Fin d) (orientation : ν → κ → Bool)
    (weight : ν → ℝ) (hw : ∀ v, 0 ≤ weight v) (r : ν → ℕ)
    (hcard : ∀ v, (blockSupport e (orientation v)).card = 2 * r v)
    (hsize : ∀ v, 2 ≤ (blockSupport e (orientation v)).card)
    (heven : ∀ j, Even (Fintype.card (β j)))
    (u : (j : κ) → β j → ℝ) (b : ℝ)
    (hbalanced : ∀ pick : (j : κ) → β j,
      blockCodeMass e orientation weight 0 (sampledBlockWeights u pick) ^ 2 ≤
        blockEnergy (sampledBlockWeights u pick)) :
    blockCodeMass e orientation weight b u ≤ Real.sqrt (blockEnergy u) := by
  have hsq := blockCodePotential_square_le_sample_mean e orientation weight hw r hcard hsize u
  simp_rw [blockCodePotential_sample_eq_mass e orientation weight r hcard hsize heven u] at hsq
  change blockCodePotential e orientation weight u ^ 2 ≤
    uniformBlockAverage (fun pick => blockCodeMass e orientation weight 0
      (sampledBlockWeights u pick) ^ 2) at hsq
  have hmean := uniformBlockAverage_mono _ _ hbalanced
  rw [blockEnergy_sample_average] at hmean
  have hGsq := hsq.trans hmean
  have hG : blockCodePotential e orientation weight u ≤ Real.sqrt (blockEnergy u) := by
    have hs := Real.sq_sqrt (blockEnergy_nonneg u)
    have hsn := Real.sqrt_nonneg (blockEnergy u)
    have hGn := blockCodePotential_nonneg e orientation weight hw u
    nlinarith
  exact (blockCodeMass_le_potential e orientation weight hw r hcard hsize b u).trans hG

/-- Adding the actual affine bias to the incoming Euclidean energy preserves
the proved norm bound. -/
theorem arbitrary_affine_atom_mass_of_sampled_bound {d : ℕ} {ν : Type*} [Fintype ν]
    [MeasurableSpace ν] [MeasurableSingletonClass ν]
    (e : ((j : κ) × β j) ≃ Fin d) (orientation : ν → κ → Bool)
    (weight : ν → ℝ) (hw : ∀ v, 0 ≤ weight v) (r : ν → ℕ)
    (hcard : ∀ v, (blockSupport e (orientation v)).card = 2 * r v)
    (hsize : ∀ v, 2 ≤ (blockSupport e (orientation v)).card)
    (heven : ∀ j, Even (Fintype.card (β j)))
    (u : (j : κ) → β j → ℝ) (b : ℝ)
    (hbalanced : ∀ pick : (j : κ) → β j,
      blockCodeMass e orientation weight 0 (sampledBlockWeights u pick) ^ 2 ≤
        blockEnergy (sampledBlockWeights u pick)) :
    blockCodeMass e orientation weight b u ≤ Real.sqrt (b ^ 2 + blockEnergy u) :=
  (arbitrary_atom_mass_of_sampled_bound e orientation weight hw r hcard hsize heven u b
    hbalanced).trans (Real.sqrt_le_sqrt (le_add_of_nonneg_left (sq_nonneg b)))

/-- Quantitative square-deficit transfer for the actual weighted Fourier
mass. Its two geometric hypotheses are exactly the balanced ray estimate
and the finite sampling-distance theorem, proved separately. -/
theorem block_distance_le_square_deficit {d : ℕ} {ν : Type*} [Fintype ν]
    [MeasurableSpace ν] [MeasurableSingletonClass ν]
    (e : ((j : κ) × β j) ≃ Fin d) (orientation : ν → κ → Bool)
    (weight : ν → ℝ) (hw : ∀ v, 0 ≤ weight v) (r : ν → ℕ)
    (hcard : ∀ v, (blockSupport e (orientation v)).card = 2 * r v)
    (hsize : ∀ v, 2 ≤ (blockSupport e (orientation v)).card)
    (heven : ∀ j, Even (Fintype.card (β j)))
    (u : (j : κ) → β j → ℝ) (b L dist : ℝ)
    (sampleDist : ((j : κ) → β j) → ℝ) (hL : 0 ≤ L)
    (hround : dist ≤ L * uniformBlockAverage sampleDist)
    (hsample : ∀ pick, sampleDist pick ≤
      blockEnergy (sampledBlockWeights u pick) -
        blockCodeMass e orientation weight 0 (sampledBlockWeights u pick) ^ 2) :
    dist ≤ L * (blockEnergy u - blockCodeMass e orientation weight b u ^ 2) := by
  have hsq := blockCodePotential_square_le_sample_mean e orientation weight hw r hcard hsize u
  simp_rw [blockCodePotential_sample_eq_mass e orientation weight r hcard hsize heven u] at hsq
  change blockCodePotential e orientation weight u ^ 2 ≤
    uniformBlockAverage (fun pick => blockCodeMass e orientation weight 0
      (sampledBlockWeights u pick) ^ 2) at hsq
  have hmean := uniformBlockAverage_mono _ _ hsample
  rw [uniformBlockAverage_sub, blockEnergy_sample_average] at hmean
  have hQnonneg : 0 ≤ blockCodeMass e orientation weight b u :=
    Finset.sum_nonneg (fun v _ => mul_nonneg (hw v) (abs_nonneg _))
  have hQG := blockCodeMass_le_potential e orientation weight hw r hcard hsize b u
  have hQsq := mul_self_le_mul_self hQnonneg hQG
  have hQsq' : blockCodeMass e orientation weight b u ^ 2 ≤
      blockCodePotential e orientation weight u ^ 2 := by
    simpa only [← pow_two] using hQsq
  calc
    dist ≤ L * uniformBlockAverage sampleDist := hround
    _ ≤ L * (blockEnergy u - uniformBlockAverage (fun pick =>
        blockCodeMass e orientation weight 0 (sampledBlockWeights u pick) ^ 2)) :=
      mul_le_mul_of_nonneg_left hmean hL
    _ ≤ L * (blockEnergy u - blockCodePotential e orientation weight u ^ 2) :=
      mul_le_mul_of_nonneg_left (sub_le_sub_left hsq _) hL
    _ ≤ _ := mul_le_mul_of_nonneg_left (sub_le_sub_left hQsq' _) hL

/-- Scalar conversion from a square deficit to the affine norm deficit,
including the incoming bias energy. -/
theorem affine_distance_from_square_deficit (b dist E Q L radius : ℝ)
    (hL : 1 ≤ L) (hradius : radius ^ 2 = b ^ 2 + E)
    (hdist : dist ≤ L * (E - Q ^ 2)) :
    b ^ 2 + dist ≤ 2 * L * radius * (radius - Q) := by
  have hb := mul_nonneg (sub_nonneg.mpr hL) (sq_nonneg b)
  have hgap : radius ^ 2 - Q ^ 2 ≤ 2 * radius * (radius - Q) := by
    nlinarith [sq_nonneg (radius - Q)]
  have hgapL := mul_le_mul_of_nonneg_left hgap (by linarith : 0 ≤ L)
  nlinarith

end NeuralGeneralization.OnlineLowerRelu
