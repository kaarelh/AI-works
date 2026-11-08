import NeuralGeneralization.OnlineLowerTanhLocalizationPeak

/-! # Global odd-lattice localization for actual ordinary tanh parity

This is a necessary condition for competitiveness. It does not assume
or assert the eventual sharp global single-parity inequality.
-/
noncomputable section
open scoped BigOperators
open Set
namespace NeuralGeneralization.OnlineLowerTanh

theorem incomingEnergy_pos_of_ne_zero {n : ℕ} (u : Fin n → ℝ) (hu : u≠0) :
    0 < incomingEnergy u := by
  have hex : ∃i,u i≠0 := by
    by_contra h
    apply hu
    funext i
    exact not_not.mp (not_exists.mp h i)
  obtain ⟨i,hi⟩ := hex
  exact (sq_pos_of_ne_zero hi).trans_le (coordinate_sq_le_energy u i)

/-- Constant residual energy near a bounded positive odd lattice, for all
competitive odd degrees at least seven. Every quantity is defined on the
actual Boolean-cube tanh coefficient. -/
theorem global_odd_lattice_localization (c : ℝ) (hc : 0< c) :
    ∃aMin aMax K : ℝ, 0< aMin ∧ aMin< aMax ∧ 0≤ K ∧
      ∀r : ℕ,3≤ r → ∀u : Fin (2*r+1) → ℝ,u≠0 →
        c*Real.sqrt (incomingEnergy u) ≤ (2*r+1:ℕ)*|parityCorrelation u 0| →
        ∃a∈Icc aMin aMax, ∃q : Fin (2*r+1) → ℕ,
          (∀i,Odd (q i)) ∧ (∑i,(|u i|-a*(q i:ℝ))^2)≤ K := by
  obtain ⟨h,T,μ,hh,hh1,hT,hμ,hμ1,hpeak⟩ := exists_competitive_peak c hc
  let aMin := Real.pi/(4*T)
  let aMax := Real.pi/h
  let L := -2*Real.log μ
  let K := L*aMax^2
  have hTpos : 0< T := by linarith
  have haMin : 0< aMin := by dsimp [aMin]; positivity
  have haMax : 0< aMax := by dsimp [aMax]; positivity
  have hgap : aMin< aMax := by
    dsimp [aMin,aMax]
    apply (div_lt_div_iff₀ (by positivity) hh).mpr
    nlinarith [Real.pi_pos]
  have hμle : μ≤1 := by linarith
  have hlog : Real.log μ≤0 := Real.log_nonpos hμ.le hμle
  have hL : 0≤ L := by dsimp [L]; linarith
  have hK : 0≤ K := mul_nonneg hL (sq_nonneg aMax)
  refine ⟨aMin,aMax,K,haMin,hgap,hK,?_⟩
  intro r hr u hu hcomp
  obtain ⟨t,ht,hprod⟩ := hpeak r hr u (incomingEnergy_pos_of_ne_zero u hu) hcomp
  have htpos := hh.trans ht.1
  let a := Real.pi/(2*t)
  have ha : 0< a := by dsimp [a]; positivity
  have hamin : aMin≤ a := by
    dsimp [aMin,a]
    apply (div_le_div_iff₀ (by positivity) (by positivity)).mpr
    nlinarith [Real.pi_pos,ht.2]
  have hamax : a≤ aMax := by
    dsimp [aMax,a]
    apply (div_le_div_iff₀ (by positivity) hh).mpr
    nlinarith [Real.pi_pos,ht.1]
  obtain ⟨hq,hres⟩ := odd_lattice_of_sine_peak u t μ htpos hμ hprod.le
  refine ⟨a,⟨hamin,hamax⟩,fun i=>positiveOddIndex a (u i),hq,?_⟩
  have hsq := pow_le_pow_left₀ ha.le hamax 2
  have hmul := mul_le_mul_of_nonneg_left hsq hL
  have hres' : (∑i,(|u i|-a*(positiveOddIndex a (u i):ℝ))^2)≤ L*a^2 := by
    dsimp only [a,L]
    nlinarith only [hres]
  exact hres'.trans hmul

end NeuralGeneralization.OnlineLowerTanh
