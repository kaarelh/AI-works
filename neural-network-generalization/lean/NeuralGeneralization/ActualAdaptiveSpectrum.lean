import NeuralGeneralization.NeuralSharpSecondMoment
import NeuralGeneralization.AdaptiveBinomialBudget
import NeuralGeneralization.AdaptiveScalarBudget

/-! The actual neural spectral estimates in the normalized form used by
adaptive sampling. Every constant here is derived from the proved all-depth
arcsine coefficient comparison, rather than supplied as a spectral premise. -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.AdaptiveCutoff

lemma rpow_minus_one {r β : ℝ} (hr : 0<r) :
    r^(-1-β)=r^(-β)/r := by
  rw [show -1-β= -β-1 by ring,Real.rpow_sub hr,Real.rpow_one]

lemma rpow_minus_two {r β : ℝ} (hr : 0<r) :
    r^(-2-2*β)=(r^(-β))^2/r^2 := by
  rw [show -2-2*β=(-β)*2-2 by ring,Real.rpow_sub hr,
    Real.rpow_mul hr.le,Real.rpow_two,Real.rpow_two]

/-- One depth-dependent constant bounds the actual tail eigenvalues,
second moment, and trace at every sparse odd cutoff. -/
theorem actual_spectral_budget (depth : ℕ) :
    ∃ C : ℝ, 1≤C ∧ ∀ d r : ℕ, 1≤r → Odd r → 64*r≤d →
      let β : ℝ := 1/(2:ℝ)^(depth+1)
      let T : ℝ := (r:ℝ)^(-β)
      let K : ℝ := ((d+1).choose (r+2):ℝ)
      (∀ S : Finset (Fin d), r<S.card →
        walshCoefficients (arcsineProfile d (depth+1)) S≤C*T/((r:ℝ)*K)) ∧
      (∑ S ∈ Finset.univ.filter (fun S : Finset (Fin d)=>r+1≤S.card),
        walshCoefficients (arcsineProfile d (depth+1)) S^2)≤C*T^2/((r:ℝ)^2*K) ∧
      walshSpectralTail (arcsineProfile d (depth+1)) (r+1)≤C*T ∧
      (∀ S : Finset (Fin d), r<S.card →
        walshCoefficients (arcsineProfile d (depth+1)) S≤C/K) := by
  obtain ⟨U,hU,hupper⟩ := iteratedArcsine_tail_eigenvalue_sharp depth
  obtain ⟨V,hV,hsecond⟩ := iteratedArcsine_tail_second_moment_sharp_odd_cutoff depth
  let C := max 4 (max U V)
  have hC4 : 4≤C := le_max_left _ _
  have hCU : U≤C := (le_max_left U V).trans (le_max_right _ _)
  have hCV : V≤C := (le_max_right U V).trans (le_max_right _ _)
  refine ⟨C,by linarith only [hC4],?_⟩
  intro d r hr hrodd hdim
  dsimp only
  let β : ℝ := 1/(2:ℝ)^(depth+1)
  let T : ℝ := (r:ℝ)^(-β)
  let K : ℝ := ((d+1).choose (r+2):ℝ)
  have hr0 : (0:ℝ)<r := by exact_mod_cast (show 0<r by omega)
  have hr1 : (1:ℝ)≤r := by exact_mod_cast hr
  have hK : 0<K := Nat.cast_pos.mpr (Nat.choose_pos (by omega))
  have hβ : 0≤β := by dsimp [β]; positivity
  have hpow1 : (r+2:ℝ)^(-1-β)≤(r:ℝ)^(-1-β) :=
    Real.rpow_le_rpow_of_nonpos hr0 (by linarith) (by linarith)
  have hpow2 : (r+2:ℝ)^(-2-2*β)≤(r:ℝ)^(-2-2*β) :=
    Real.rpow_le_rpow_of_nonpos hr0 (by linarith) (by linarith)
  have hT0 : 0≤T := Real.rpow_nonneg hr0.le _
  have he1 : (r:ℝ)^(-1-β)=T/(r:ℝ) := rpow_minus_one hr0
  have he2 : (r:ℝ)^(-2-2*β)=T^2/(r:ℝ)^2 := rpow_minus_two hr0
  have hmax : ∀ S : Finset (Fin d),r<S.card →
      walshCoefficients (arcsineProfile d (depth+1)) S≤C*T/((r:ℝ)*K) := by
    intro S hS
    have hh := hupper d r hrodd (by omega) S hS
    change _≤U*(r+2:ℝ)^(-1-β)/K at hh
    apply hh.trans
    calc
      _ ≤ C*(r:ℝ)^(-1-β)/K := by gcongr
      _ = _ := by rw [he1]; ring
  refine ⟨hmax,?_,?_,?_⟩
  · have hh := hsecond d r hrodd (by omega)
    change _≤V*(r+2:ℝ)^(-2-2/(2:ℝ)^(depth+1))/K at hh
    rw [show -2-2/(2:ℝ)^(depth+1)= -2-2*β by dsimp [β]; ring] at hh
    apply hh.trans
    calc
      _ ≤ C*(r:ℝ)^(-2-2*β)/K := by gcongr
      _ = _ := by rw [he2]; ring
  · have hh := iterated_arcsine_spectral_tail_upper d (depth+1) (r+1) (by omega)
    have hp : (r+1:ℝ)^(-β)≤T :=
      Real.rpow_le_rpow_of_nonpos hr0 (by linarith) (by linarith)
    have hh' : walshSpectralTail (arcsineProfile d (depth+1)) (r+1)≤4*(r+1:ℝ)^(-β) := by
      simpa only [Nat.cast_add,Nat.cast_one] using hh
    exact hh'.trans (by gcongr)
  · intro S hS
    apply (hmax S hS).trans
    have hp : T≤1 := by
      simpa only [Real.rpow_zero] using Real.rpow_le_rpow_of_exponent_le hr1 (by linarith : -β≤0)
    have hh : T/(r:ℝ)≤1 := (div_le_iff₀ hr0).mpr (by simpa only [one_mul] using hp.trans hr1)
    calc
      _ = (C/K)*(T/(r:ℝ)) := by ring
      _ ≤ (C/K)*1 := mul_le_mul_of_nonneg_left hh (by positivity)
      _ = _ := by ring

end NeuralGeneralization.AdaptiveCutoff
