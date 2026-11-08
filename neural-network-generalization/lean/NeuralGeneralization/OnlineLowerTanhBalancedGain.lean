import NeuralGeneralization.OnlineLowerTanhConcavity
import Mathlib.Analysis.Calculus.Deriv.MeanValue

/-! Identification of any interior stationary balanced gain with the actual compact optimizer. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open Set
namespace NeuralGeneralization.OnlineLowerTanh

def balancedStationary (r : ℕ) (a : ℝ) : ℝ :=
  a*balancedParityFirst r a-balancedParity r a

theorem hasDerivAt_balancedStationary (r : ℕ) (a : ℝ) :
    HasDerivAt (balancedStationary r) (a*balancedParitySecond r a) a := by
  have h := ((hasDerivAt_id a).mul (hasDerivAt_balancedParityFirst r a)).sub (hasDerivAt_balancedParity r a)
  convert h using 1 <;> try rfl
  simp only [id_eq,one_mul]
  ring

theorem balancedStationary_strictAntiOn (r : ℕ) : StrictAntiOn (balancedStationary r) (Ici 1) := by
  apply strictAntiOn_of_deriv_neg (convex_Ici _) (fun a ha => (hasDerivAt_balancedStationary r a).continuousAt.continuousWithinAt)
  intro a ha
  have ha' : a ∈ Ici (1 : ℝ) := interior_subset ha
  rw [(hasDerivAt_balancedStationary r a).deriv]
  exact mul_neg_of_pos_of_neg (lt_of_lt_of_le (by norm_num) ha') (balancedParitySecond_neg r a ha')

theorem hasDerivAt_balancedRatio (r : ℕ) (a : ℝ) (ha : a ≠ 0) :
    HasDerivAt (balancedRatio r) (balancedStationary r a/a^2) a := by
  have h := (hasDerivAt_balancedParity r a).div (hasDerivAt_id a) ha
  convert h using 1 <;> try rfl
  simp only [balancedStationary,id_eq,mul_one]
  ring

theorem balancedGain_eq_of_stationary (r : ℕ) (a : ℝ) (ha : a ∈ Ioo (1 : ℝ) 2)
    (hroot : balancedStationary r a=0) : balancedGain r=a := by
  have hga := balancedGain_mem r
  have hmax := balancedGain_max r ⟨ha.1.le,ha.2.le⟩
  change balancedRatio r a ≤ balancedRatio r (balancedGain r) at hmax
  have hanti := balancedStationary_strictAntiOn r
  rcases lt_trichotomy (balancedGain r) a with hlt | heq | hgt
  · have hm : StrictMonoOn (balancedRatio r) (Icc 1 a) := by
      apply strictMonoOn_of_deriv_pos (convex_Icc _ _)
        ((continuousOn_balancedRatio r).mono (fun x hx => ⟨hx.1,le_trans hx.2 ha.2.le⟩))
      intro x hx
      rw [interior_Icc] at hx
      have hxp : 0 < x := by linarith [hx.1]
      rw [(hasDerivAt_balancedRatio r x hxp.ne').deriv]
      apply div_pos
      · have hh := hanti (show x ∈ Ici 1 from hx.1.le) (show a ∈ Ici 1 from ha.1.le) hx.2
        rw [hroot] at hh
        exact hh
      · positivity
    have hh := hm ⟨hga.1,hlt.le⟩ ⟨ha.1.le,le_rfl⟩ hlt
    exact False.elim (not_lt_of_ge hmax hh)
  · exact heq
  · have hm : StrictAntiOn (balancedRatio r) (Icc a 2) := by
      apply strictAntiOn_of_deriv_neg (convex_Icc _ _)
        ((continuousOn_balancedRatio r).mono (fun x hx => ⟨le_trans ha.1.le hx.1,hx.2⟩))
      intro x hx
      rw [interior_Icc] at hx
      have hxp : 0 < x := by linarith [hx.1,ha.1]
      rw [(hasDerivAt_balancedRatio r x hxp.ne').deriv]
      apply div_neg_of_neg_of_pos
      · have hh := hanti (show a ∈ Ici 1 from ha.1.le)
          (show x ∈ Ici 1 from le_trans ha.1.le hx.1.le) hx.1
        rwa [hroot] at hh
      · positivity
    have hh := hm ⟨le_rfl,ha.2.le⟩ ⟨hgt.le,hga.2⟩ hgt
    exact False.elim (not_lt_of_ge hmax hh)

end NeuralGeneralization.OnlineLowerTanh
