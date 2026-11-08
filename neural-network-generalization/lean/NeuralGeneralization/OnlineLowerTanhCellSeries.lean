import NeuralGeneralization.OnlineLowerTanhQuantitativeCell
import Mathlib.Order.SuccPred.IntervalSucc

/-! # Exact infinite decomposition into cutoff sine cells -/
noncomputable section
open scoped BigOperators Topology Classical
open MeasureTheory Set Filter
namespace NeuralGeneralization.OnlineLowerTanh

lemma iUnion_positive_cells {h : ℝ} (hh : 0 < h) :
    (⋃ l : ℕ, Ioc ((l : ℝ)*h) (((l : ℝ)+1)*h)) = Ioi 0 := by
  have hu : ¬ BddAbove (Set.range (fun l : ℕ => (l : ℝ)*h)) := by
    rintro ⟨b, hb⟩
    obtain ⟨N, hN⟩ := exists_nat_gt (b/h)
    have hle := hb ⟨N, rfl⟩
    have hgt : b < (N : ℝ)*h := (div_lt_iff₀ hh).mp hN
    linarith
  have hh' := iUnion_Ioc_map_succ_eq_Ioi
    (f := fun l : ℕ => (l : ℝ)*h) (fun l => by simp; positivity) hu
  simpa only [Nat.bot_eq_zero, Nat.cast_zero, zero_mul, Order.succ_eq_add_one,
    Nat.cast_add, Nat.cast_one] using hh'

/-- The infinite cell series is the actual cutoff integral; its convergence
comes from integrability of the literal function, not an assumed expansion. -/
theorem hasSum_integral_truncated_cells (f : ℝ → ℝ) (hf : IntegrableOn f (Ioi 0))
    (h ρ : ℝ) (hh : 0 < h) (hρ : 0 < ρ) :
    HasSum (fun l : ℕ => ∫ t : ℝ in
      Ioc ((l : ℝ)*h) (((l : ℝ)+1)*h) ∩ Ici ρ, f t)
      (∫ t : ℝ in Ioi ρ, f t) := by
  have hmono : Monotone (fun l : ℕ => (l : ℝ)*h) := by
    intro i j hij
    exact mul_le_mul_of_nonneg_right (by exact_mod_cast hij) hh.le
  have hd : Pairwise (fun i j : ℕ => Disjoint
      (Ioc ((i : ℝ)*h) (((i : ℝ)+1)*h) ∩ Ici ρ)
      (Ioc ((j : ℝ)*h) (((j : ℝ)+1)*h) ∩ Ici ρ)) := by
    intro i j hij
    have hx := hmono.pairwise_disjoint_on_Ioc_succ hij
    simp only [Order.succ_eq_add_one, Nat.cast_add, Nat.cast_one] at hx
    exact hx.mono inter_subset_left inter_subset_left
  have hunion : (⋃ l : ℕ, Ioc ((l : ℝ)*h) (((l : ℝ)+1)*h) ∩ Ici ρ) = Ici ρ := by
    rw [← iUnion_inter, iUnion_positive_cells hh]
    ext t
    simp only [mem_inter_iff, mem_Ioi, mem_Ici]
    exact ⟨fun ht => ht.2, fun ht => ⟨hρ.trans_le ht, ht⟩⟩
  have hfi : IntegrableOn f (⋃ l : ℕ, Ioc ((l : ℝ)*h) (((l : ℝ)+1)*h) ∩ Ici ρ) := by
    rw [hunion]
    exact hf.mono_set (fun t ht => hρ.trans_le ht)
  have hs := hasSum_integral_iUnion (fun l => measurableSet_Ioc.inter measurableSet_Ici) hd hfi
  rw [hunion] at hs
  have he : (∫ t : ℝ in Ici ρ, f t) = ∫ t : ℝ in Ioi ρ, f t :=
    setIntegral_congr_set (Ioi_ae_eq_Ici (μ := volume) (a := ρ)).symm
  rwa [he] at hs

end NeuralGeneralization.OnlineLowerTanh
