import NeuralGeneralization.OnlineLowerTanhCodeVanishing
import Mathlib.Analysis.MeanInequalities

/-! Energy-based AM–GM sharpens local vanishing from D to sqrt(D). -/
noncomputable section
open scoped BigOperators Classical
namespace NeuralGeneralization.OnlineLowerTanh
open ConcreteModel

lemma nonneg_prod_le_average_pow {ι : Type*} (A : Finset ι) (z : ι → ℝ)
    (hA : A.Nonempty) (hz : ∀i∈A,0≤z i) :
    (∏i∈A,z i) ≤ ((∑i∈A,z i)/(A.card:ℝ))^A.card := by
  have hc : (0:ℝ)<A.card := by exact_mod_cast hA.card_pos
  have hg := Real.geom_mean_le_arith_mean A (fun _ => (1:ℝ)) z
    (fun _ _ => by norm_num) (by simpa using hc) hz
  simp only [Real.rpow_one,Finset.sum_const,one_mul,nsmul_eq_mul,mul_one] at hg
  have hp:=pow_le_pow_left₀ (Real.rpow_nonneg (Finset.prod_nonneg hz) _) hg A.card
  simpa only [Real.rpow_inv_natCast_pow (Finset.prod_nonneg hz) (ne_of_gt hA.card_pos)] using hp

lemma absolute_prod_le_energy {d : ℕ} (A : Finset (Fin d)) (u : Fin d → ℝ)
    (τ : ℝ) (hτ : 0≤τ) (henergy : (∑i∈A,u i^2)≤τ^2) :
    (∏i∈A,|u i|) ≤ (τ/Real.sqrt (A.card:ℝ))^A.card := by
  by_cases hA:A.Nonempty
  · have hc : (0:ℝ)<A.card := by exact_mod_cast hA.card_pos
    have hprod:=nonneg_prod_le_average_pow A (fun i=>u i^2) hA (fun _ _=>sq_nonneg _)
    have havg: (∑i∈A,u i^2)/(A.card:ℝ) ≤ (τ/Real.sqrt (A.card:ℝ))^2 := by
      rw [div_pow,Real.sq_sqrt hc.le]
      exact div_le_div_of_nonneg_right henergy hc.le
    have hp:=hprod.trans (pow_le_pow_left₀ (by positivity) havg A.card)
    have he : (∏i∈A,u i^2)=(∏i∈A,|u i|)^2 := by
      rw [←Finset.prod_pow];simp only [sq_abs]
    rw [he] at hp
    have he' : ((τ/Real.sqrt (A.card:ℝ))^2)^A.card=((τ/Real.sqrt (A.card:ℝ))^A.card)^2 := by
      rw [←pow_mul,←pow_mul,Nat.mul_comm]
    rw [he'] at hp
    exact (sq_le_sq₀ (Finset.prod_nonneg fun _ _=>abs_nonneg _) (by positivity)).mp hp
  · have he:A=∅:=Finset.not_nonempty_iff_eq_empty.mp hA
    simp [he]

theorem tanh_walshCoefficient_partial_energy {d : ℕ}
    (A B : Finset (Fin d)) (hAB:A⊆B) (u:Fin d→ℝ) (b τ:ℝ)
    (hτ:0≤τ) (henergy:(∑i∈A,u i^2)≤τ^2) :
    |walshCoefficients (fun x=>Real.tanh (b+incomingLinear u x)) B| ≤
      (Real.sqrt (A.card:ℝ)*τ)^A.card := by
  by_cases hA:A.Nonempty
  · have hc:(0:ℝ)<A.card:=by exact_mod_cast hA.card_pos
    have hs:0<Real.sqrt (A.card:ℝ):=Real.sqrt_pos.mpr hc
    have hfac:(A.card.factorial:ℝ)≤(A.card:ℝ)^A.card:=by exact_mod_cast Nat.factorial_le_pow A.card
    calc
      _ ≤ (A.card.factorial:ℝ)*∏i∈A,|u i| := tanh_walshCoefficient_partial_bound A B hAB u b
      _ ≤ (A.card:ℝ)^A.card*(τ/Real.sqrt (A.card:ℝ))^A.card :=
        mul_le_mul hfac (absolute_prod_le_energy A u τ hτ henergy)
          (Finset.prod_nonneg fun _ _=>abs_nonneg _) (by positivity)
      _ = _ := by
        rw [←mul_pow]
        congr 1
        field_simp [hs.ne']
        nlinarith [Real.sq_sqrt hc.le]
  · have he:A=∅:=Finset.not_nonempty_iff_eq_empty.mp hA
    have h:=tanh_walshCoefficient_partial_bound A B hAB u b
    simpa [he] using h

theorem tanh_walshCoefficient_inactive_energy_bound {d:ℕ}
    (A B:Finset (Fin d)) (u:Fin d→ℝ) (b τ D:ℝ) (k:ℕ)
    (hk:k≤(B\A).card) (hD:(k:ℝ)≤D) (hτ:0≤τ)
    (henergy:(∑i∈Aᶜ,u i^2)≤τ^2) :
    |walshCoefficients (fun x=>Real.tanh (b+incomingLinear u x)) B|≤(Real.sqrt D*τ)^k := by
  obtain ⟨J,hJ,hcard⟩:=Finset.exists_subset_card_eq hk
  have hJB:J⊆B:=fun i hi=>(Finset.mem_sdiff.mp (hJ hi)).1
  have hJA:J⊆Aᶜ:=fun i hi=>Finset.mem_compl.mpr (Finset.mem_sdiff.mp (hJ hi)).2
  have hE:(∑i∈J,u i^2)≤τ^2 :=
    (Finset.sum_le_sum_of_subset_of_nonneg hJA (fun _ _ _=>sq_nonneg _)).trans henergy
  have hh:=tanh_walshCoefficient_partial_energy J B hJB u b τ hτ hE
  rw [hcard] at hh
  exact hh.trans (pow_le_pow_left₀ (by positivity)
    (mul_le_mul_of_nonneg_right (Real.sqrt_le_sqrt hD) hτ) k)
end NeuralGeneralization.OnlineLowerTanh
