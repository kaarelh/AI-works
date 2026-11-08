import NeuralGeneralization.OnlineLowerTanhCodePhysicalProduct
import NeuralGeneralization.OnlineLowerTanhLocalizationPhases

/-! # Determinant localization for actual physical tanh Fourier products -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.OnlineLowerTanh
open OnlineLowerRelu

def supportPhase {d : ℕ} (A : Finset (Fin d)) (j : Fin d) : Bool := decide (j∈A)

theorem supportPhase_selected {d : ℕ} (A : Finset (Fin d)) :
    selectedPhaseCoordinates (supportPhase A)=A := by
  ext j
  simp [selectedPhaseCoordinates,supportPhase]

theorem supportPhase_switched {d : ℕ} (A B : Finset (Fin d)) :
    switchedOffCoordinates (supportPhase A) (supportPhase B)=A\B := by
  ext j
  simp [switchedOffCoordinates,supportPhase]

theorem physical_phaseWave {d : ℕ} (A : Finset (Fin d)) (u : Fin d→ℝ) (t : ℝ) :
    (∏j,phaseWave (supportPhase A j) (2*t*u j/Real.pi)) =
      |trigProduct A (fun j=>t*u j)| := by
  unfold trigProduct
  rw [Finset.abs_prod]
  apply Finset.prod_congr rfl
  intro j _
  have he : Real.pi*(2*t*u j/Real.pi)/2=t*u j := by field_simp
  by_cases hj : j∈A <;> simp [phaseWave,supportPhase,hj,he]

theorem physical_phase_energy {d : ℕ} (u : Fin d→ℝ) (t : ℝ) :
    (∑j,(2*t*u j/Real.pi)^2)=4*t^2*incomingEnergy u/Real.pi^2 := by
  unfold incomingEnergy
  have hp (j : Fin d) : (2*t*u j/Real.pi)^2=(4*t^2/Real.pi^2)*u j^2 := by ring
  simp only [hp,←Finset.mul_sum]
  ring

/-- Starting from one actual constant-height physical resonance, the
collective determinant estimate bounds every competing support. -/
theorem physical_trig_product_localization {d : ℕ} (A B : Finset (Fin d))
    (u : Fin d→ℝ) (s t μ K q : ℝ) (hs : s≠0) (hμ : 0<μ) (hK : 0<K)
    (hpeak : μ≤|trigProduct A (fun j=>s*u j)|)
    (henergy : 8*s^2*incomingEnergy u/Real.pi^2-4*Real.log μ≤K)
    (hcard : 8*K*q≤((A\B).card:ℝ)*(B.card:ℝ))
    (hshift : (t/s)^2*(-2*Real.log μ)≤q) :
    |trigProduct B (fun j=>t*u j)|≤Real.exp (-q/2) := by
  let x : Fin d→ℝ := fun j=>2*s*u j/Real.pi
  have hpk : μ≤∏j,phaseWave (supportPhase A j) (x j) := by
    simpa only [x,physical_phaseWave] using hpeak
  have herr := resonance_phase_error_bound (supportPhase A) x μ hμ hpk
  have hIE := phaseInteger_energy_le (supportPhase A) x
  have hIE' : (∑j,(phaseInteger (supportPhase A j) (x j):ℝ)^2)≤K := by
    have hE : (∑j,x j^2)=4*s^2*incomingEnergy u/Real.pi^2 := physical_phase_energy u s
    rw [hE] at hIE
    simp only [div_eq_mul_inv] at hIE henergy
    nlinarith only [hIE,herr,henergy]
  have hh := actual_phase_product_small (supportPhase A) (supportPhase B) x
    (t/s) K (-2*Real.log μ) q hK hIE' herr
    (by simpa only [supportPhase_switched,supportPhase_selected] using hcard) hshift
  have he (j : Fin d) : (t/s)*x j=2*t*u j/Real.pi := by
    dsimp [x]
    field_simp
  simpa only [he,physical_phaseWave] using hh

theorem carrierTransversal_card_lower {p R : ℕ} (size : Fin p→Bool→ℕ)
    (hR : ∀i s,R≤size i s) (θ : Fin p→Bool) :
    p*R≤(carrierTransversal size θ).card := by
  rw [carrierTransversal_card]
  have hh := Finset.sum_le_sum (fun i (_:i∈Finset.univ)=>hR i (θ i))
  simp only [Finset.sum_const,Finset.card_univ,Fintype.card_fin,smul_eq_mul] at hh
  omega

/-- The determinant mass is proportional to the number of switched
pairs times the total selected degree; it has no factor-1/p loss. -/
theorem carrierTransversal_determinant_mass {p R : ℕ} (size : Fin p→Bool→ℕ)
    (hR : ∀i s,R≤size i s) (old new : Fin p→Bool) :
    (((changedRails old new).card*R:ℕ):ℝ)*((p*R:ℕ):ℝ) ≤
      (((carrierTransversal size old\carrierTransversal size new).card:ℕ):ℝ)*
        ((carrierTransversal size new).card:ℝ) := by
  have hd := carrierTransversal_difference_card_lower size hR new old
  have hc := carrierTransversal_card_lower size hR new
  have hsym : changedRails new old=changedRails old new := by
    ext i;simp [changedRails,ne_comm]
  rw [hsym] at hd
  exact_mod_cast Nat.mul_le_mul hd hc

end NeuralGeneralization.OnlineLowerTanh
