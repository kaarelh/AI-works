import NeuralGeneralization.OnlineLowerTanhNearBulk

/-! # Deleting two arbitrary coordinates from an actual near-balanced bulk -/
noncomputable section
open scoped BigOperators Topology Classical
open Filter
namespace NeuralGeneralization.OnlineLowerTanh

lemma finset_erase_pair_card_bounds {α : Type*} [DecidableEq α]
    (S : Finset α) (i j : α) :
    ((S.erase i).erase j).card ≤ S.card ∧
      S.card ≤ ((S.erase i).erase j).card+2 := by
  have h₁ := Finset.card_erase_le (s:=S) (a:=i)
  have h₂ := Finset.card_erase_le (s:=S.erase i) (a:=j)
  have h₃ := Finset.pred_card_le_card_erase (s:=S) (a:=i)
  have h₄ := Finset.pred_card_le_card_erase (s:=S.erase i) (a:=j)
  omega

namespace NearBalancedSequence
variable (B : NearBalancedSequence) (i j : ∀ k, Fin (B.N k))

lemma erased_bulk_tendsto :
    Tendsto (fun k => (((B.bulk k).erase (i k)).erase (j k)).card) atTop atTop := by
  refine tendsto_atTop.2 fun b => ?_
  filter_upwards [B.bulk_tendsto.eventually_ge_atTop (b+2)] with k hk
  have hh := finset_erase_pair_card_bounds (B.bulk k) (i k) (j k)
  omega

lemma erased_bulk_fraction :
    Tendsto (fun k => (B.N k : ℝ)⁻¹*
      ((((B.bulk k).erase (i k)).erase (j k)).card : ℝ)) atTop (𝓝 1) := by
  let e := fun k => (B.N k : ℝ)⁻¹*((B.bulk k).card-
    ((((B.bulk k).erase (i k)).erase (j k)).card : ℝ))
  have he : Tendsto e atTop (𝓝 0) := by
    have hup : Tendsto (fun k => 2/(B.N k : ℝ)) atTop (𝓝 0) :=
      tendsto_const_nhds.div_atTop (tendsto_natCast_atTop_atTop.comp B.N_tendsto)
    apply squeeze_zero _ _ hup
    · intro k
      have hc := (finset_erase_pair_card_bounds (B.bulk k) (i k) (j k)).1
      have hcR : (((((B.bulk k).erase (i k)).erase (j k)).card) : ℝ) ≤ (B.bulk k).card := by exact_mod_cast hc
      exact mul_nonneg (inv_nonneg.mpr (Nat.cast_nonneg _)) (sub_nonneg.mpr hcR)
    · intro k
      have hc := (finset_erase_pair_card_bounds (B.bulk k) (i k) (j k)).2
      have hcR : ((B.bulk k).card : ℝ) ≤
          ((((B.bulk k).erase (i k)).erase (j k)).card : ℝ)+2 := by exact_mod_cast hc
      have hh := mul_le_mul_of_nonneg_left (show
        ((B.bulk k).card : ℝ)-((((B.bulk k).erase (i k)).erase (j k)).card : ℝ) ≤ 2 by linarith)
        (inv_nonneg.mpr (Nat.cast_nonneg (B.N k) : (0 : ℝ) ≤ B.N k))
      simpa only [e, div_eq_mul_inv, mul_comm] using hh
  have hh := B.bulk_fraction.sub he
  simp only [sub_zero] at hh
  convert hh using 1
  funext k
  dsimp [e]
  ring

/-- The original neuron sequence, dimensions, gains, and energy constants are
unchanged. Only the selected bulk loses the two indicated coordinates; they
need not be distinct or belong to the original bulk. -/
def erasePair : NearBalancedSequence where
  N := B.N
  N_pos := B.N_pos
  N_odd := B.N_odd
  N_tendsto := B.N_tendsto
  u := B.u
  u_nonneg := B.u_nonneg
  maximal := B.maximal
  bulk := fun k => ((B.bulk k).erase (i k)).erase (j k)
  bulk_tendsto := B.erased_bulk_tendsto i j
  bulk_fraction := B.erased_bulk_fraction i j
  a := B.a
  a_tendsto := B.a_tendsto
  D := B.D
  D_nonneg := B.D_nonneg
  D_tendsto := B.D_tendsto
  K := B.K
  K_nonneg := B.K_nonneg
  bulk_close := by
    intro k x hx
    exact B.bulk_close k x (Finset.mem_of_mem_erase (Finset.mem_of_mem_erase hx))
  bulk_energy := by
    intro k
    exact (Finset.sum_le_sum_of_subset_of_nonneg
      ((Finset.erase_subset _ _).trans (Finset.erase_subset _ _))
      (fun x _ _ => sq_nonneg (B.u k x-B.a k))).trans (B.bulk_energy k)
  full_energy := B.full_energy
  rms := B.rms
  efficiency_lower := B.efficiency_lower

@[simp] lemma erasePair_bulk (k : ℕ) :
    (B.erasePair i j).bulk k = ((B.bulk k).erase (i k)).erase (j k) := rfl

lemma erasePair_bulk_subset (k : ℕ) : (B.erasePair i j).bulk k ⊆ B.bulk k :=
  (Finset.erase_subset _ _).trans (Finset.erase_subset _ _)

lemma erasePair_bulk_card (k : ℕ) :
    ((B.erasePair i j).bulk k).card ≤ (B.bulk k).card ∧
      (B.bulk k).card ≤ ((B.erasePair i j).bulk k).card+2 :=
  finset_erase_pair_card_bounds (B.bulk k) (i k) (j k)

@[simp] lemma not_mem_erasePair_left (k : ℕ) : i k ∉ (B.erasePair i j).bulk k := by
  intro hx
  exact (Finset.mem_erase.mp (Finset.mem_of_mem_erase hx)).1 rfl

@[simp] lemma not_mem_erasePair_right (k : ℕ) : j k ∉ (B.erasePair i j).bulk k := by
  intro hx
  exact (Finset.mem_erase.mp hx).1 rfl

/-- Even after either deleted coordinate joins the complement, its normalized
energy still vanishes, by the full RMS convergence and retained bulk fraction. -/
lemma erasePair_outside_energy_tendsto :
    Tendsto (fun k => (B.N k : ℝ)⁻¹*
      (∑ x ∈ ((B.erasePair i j).bulk k)ᶜ,(B.u k x)^2)) atTop (𝓝 0) :=
  (B.erasePair i j).outside_energy_tendsto

end NearBalancedSequence
end NeuralGeneralization.OnlineLowerTanh
