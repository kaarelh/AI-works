import NeuralGeneralization.OnlineLowerTanhOutlierComparison

/-! # Outlier exclusion at the literal ambient dimension -/
noncomputable section
open scoped BigOperators Topology Classical
namespace NeuralGeneralization.OnlineLowerTanh

theorem finite_equal_bulk_not_maximizer {N : ℕ} (hN : Odd N)
    (u : Fin N → ℝ) (A : Finset (Fin N)) (a K : ℝ)
    (ha : 1 ≤ a) (hK : 0 ≤ K) (hb : 0 < A.card) (hproper : A.card < N)
    (hlarge : 32*(scalarFirstError+scalarFirstBound+K+1) ≤ 2*(A.card/2:ℕ)+1)
    (hsmall : ((N:ℝ)-A.card+1)/(A.card:ℝ) ≤ 1/32)
    (hcap : |parityCorrelation u 0| ≤ balancedParity (A.card/2) a*
      (1+K/(2*(A.card/2:ℕ)+1)^2))
    (hbulk : ∀ i ∈ A,|u i|=a) (hout : ∀ i,i ∉ A → 5*a/2 ≤ |u i|) :
    ¬IsIntrinsicMaximizer u := by
  obtain ⟨s,rfl⟩ := hN
  let r := A.card/2
  let j := s-r
  have hrs : r ≤ s := by dsimp [r];omega
  have hsj : r+j=s := by dsimp [j];omega
  have hcount : j+1 ≤ Aᶜ.card := by
    have hc : Aᶜ.card=(2*s+1)-A.card := by simp only [Finset.card_compl,Fintype.card_fin]
    rw [hc]
    dsimp [j,r]
    omega
  have hden : (A.card:ℝ) ≤ 2*(r:ℝ)+1 := by
    have hh : A.card ≤ 2*r+1 := by dsimp [r];omega
    exact_mod_cast hh
  have hnum : (j:ℝ)+1 ≤ ((2*s+1:ℕ):ℝ)-(A.card:ℝ)+1 := by
    have hh : j+1 ≤ ((2*s+1)-A.card)+1 := by
      have hc : Aᶜ.card=(2*s+1)-A.card := by simp only [Finset.card_compl,Fintype.card_fin]
      omega
    have hhR := Nat.cast_le (α:=ℝ).mpr hh
    simpa only [Nat.cast_add,Nat.cast_one,Nat.cast_sub hproper.le] using hhR
  have hsmall' : ((j:ℝ)+1)/(2*(r:ℝ)+1) ≤ 1/32 := by
    have hd : (0:ℝ) < A.card := by exact_mod_cast hb
    exact (div_le_div₀ (by linarith [Nat.cast_nonneg (α:=ℝ) j]) hnum hd hden).trans hsmall
  have henergy : a^2*((2*(r+j:ℕ)+1:ℕ)+5*((j:ℝ)+1)) ≤ incomingEnergy u := by
    have he := separated_outliers_energy A u a (by linarith) hbulk hout
    have hc : (j:ℝ)+1 ≤ Aᶜ.card := by exact_mod_cast hcount
    have hpen : 5*((j:ℝ)+1) ≤ (21/4:ℝ)*(Aᶜ.card:ℝ) := by
      nlinarith [Nat.cast_nonneg (α:=ℝ) Aᶜ.card]
    rw [hsj]
    exact (mul_le_mul_of_nonneg_left (add_le_add_right hpen _) (sq_nonneg a)).trans he
  have hh := outlier_coefficient_strict_comparison r j a K (parityCorrelation u 0)
    (incomingEnergy u) ha hK hlarge hsmall' hcap henergy
  rw [hsj] at hh
  intro hmax
  have hcompare := hmax (fun _ => a)
  rw [intrinsicGain_balanced_at_gain s a ha] at hcompare
  exact (not_le_of_gt hh) hcompare

end NeuralGeneralization.OnlineLowerTanh
