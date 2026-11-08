import NeuralGeneralization.OnlineLowerSamplingVariance

noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.OnlineLowerRelu

/-- Moment form of the finite two-rail estimate. All hypotheses are elementary
coordinate identities in the uniform independent sampling law. -/
theorem min_square_bound_of_moments {Ω : Type*} [Fintype Ω]
    (X Y:Ω→ℝ) (R:ℝ) (hR:0≤R)
    (hAB:finiteAverage (fun ω=>Y ω^2)≤finiteAverage (fun ω=>X ω^2))
    (hX:∀ω,X ω^2≤R*finiteAverage (fun ω=>X ω^2))
    (hY:∀ω,Y ω^2≤R*finiteAverage (fun ω=>Y ω^2))
    (hXY:finiteAverage (fun ω=>X ω^2*Y ω^2)=
      finiteAverage (fun ω=>X ω^2)*finiteAverage (fun ω=>Y ω^2)) :
    finiteAverage (fun ω=>Y ω^2)≤2*R*finiteAverage (fun ω=>min (X ω^2) (Y ω^2)) := by
  let A := finiteAverage (fun ω=>X ω^2)
  let B := finiteAverage (fun ω=>Y ω^2)
  let E := finiteAverage (fun ω=>min (X ω^2) (Y ω^2))
  have hA : 0≤A := finiteAverage_nonneg _ (fun ω=>sq_nonneg _)
  have hB : 0≤B := finiteAverage_nonneg _ (fun ω=>sq_nonneg _)
  have hE : 0≤E := finiteAverage_nonneg _ (fun ω=>le_min (sq_nonneg _) (sq_nonneg _))
  have hpoint (ω:Ω) : X ω^2*Y ω^2≤R*(A+B)*min (X ω^2) (Y ω^2) := by
    have hm : max (X ω^2) (Y ω^2)≤R*(A+B) := by
      apply max_le
      · nlinarith [hX ω]
      · nlinarith [hY ω]
    have hh := mul_le_mul_of_nonneg_left hm (le_min (sq_nonneg (X ω)) (sq_nonneg (Y ω)))
    rw [min_mul_max] at hh
    nlinarith
  have havg := finiteAverage_mono _ _ hpoint
  rw [hXY,finiteAverage_mul_left] at havg
  change A*B≤R*(A+B)*E at havg
  change B≤2*R*E
  change B≤A at hAB
  rcases hA.eq_or_lt with hAz | hAz
  · nlinarith [mul_nonneg hR hE]
  · have hh : R*(A+B)*E≤2*A*R*E := by
      nlinarith [mul_nonneg (sub_nonneg.mpr hAB) (mul_nonneg hR hE)]
    nlinarith

theorem scalarSpread_le_shift {p:ℕ} (hp:0<p) (z:Fin p→ℝ) (c:ℝ) :
    scalarSpread z≤∑ i,(z i-c)^2 := by
  have hn : (0:ℝ)<p := by exact_mod_cast hp
  rw [scalarSpread_eq hp,scalar_shift_identity]
  have hs := sq_nonneg ((∑ i,z i)-(p:ℝ)*c)
  refine le_of_mul_le_mul_right ?_ hn
  field_simp
  nlinarith

theorem scalarSpread_perturb {p:ℕ} (hp:0<p) (z a:Fin p→ℝ) :
    scalarSpread z≤2*scalarSpread a+2*(∑ i,(z i-a i)^2) := by
  calc
    _ ≤ ∑ i,(z i-scalarMean a)^2 := scalarSpread_le_shift hp z _
    _ ≤ ∑ i,(2*(a i-scalarMean a)^2+2*(z i-a i)^2) := by
      apply Finset.sum_le_sum
      intro i _
      nlinarith [sq_nonneg ((a i-scalarMean a)-(z i-a i))]
    _ = _ := by rw [Finset.sum_add_distrib,←Finset.mul_sum,←Finset.mul_sum]; rfl

theorem square_sub_max_le (z t:ℝ) (hz:0≤z) (ht:0≤t) :
    (z-max z t)^2≤t^2 := by
  by_cases h:z≤t
  · rw [max_eq_right h]
    nlinarith
  · rw [max_eq_left (le_of_not_ge h)]
    nlinarith

/-- This is the scalar rounding step of the sampling transfer. `Z` is the
rail chosen deterministically by larger second moment, and `T` is discarded.
The selected common gain is the mean of the selected rail means. -/
theorem deterministic_rail_rounding {Ω : Type*} [Fintype Ω] [Nonempty Ω]
    (p:ℕ) (hp:2≤p) (Z T:Ω→Fin p→ℝ) (R:ℝ) (hR:0≤R)
    (hZ:∀ω i,0≤Z ω i) (hT:∀ω i,0≤T ω i)
    (hAB:∀i,finiteAverage (fun ω=>T ω i^2)≤finiteAverage (fun ω=>Z ω i^2))
    (hZbound:∀ω i,Z ω i^2≤R*finiteAverage (fun ω=>Z ω i^2))
    (hTbound:∀ω i,T ω i^2≤R*finiteAverage (fun ω=>T ω i^2))
    (hpair:∀i,finiteAverage (fun ω=>Z ω i^2*T ω i^2)=
      finiteAverage (fun ω=>Z ω i^2)*finiteAverage (fun ω=>T ω i^2))
    (hcross:∀i j,i≠j→finiteAverage (fun ω=>Z ω i*Z ω j)=
      finiteAverage (fun ω=>Z ω i)*finiteAverage (fun ω=>Z ω j)) :
    finiteAverage (fun ω=>∑ i,(Z ω i-scalarMean (fun j=>finiteAverage (fun ω=>Z ω j)))^2)+
      finiteAverage (fun ω=>∑ i,T ω i^2) ≤
      (4+10*R)*finiteAverage (fun ω=>(∑ i,min (Z ω i^2) (T ω i^2))+
        scalarSpread (fun i=>max (Z ω i) (T ω i))) := by
  let D := finiteAverage (fun ω=>∑ i,T ω i^2)
  let M := finiteAverage (fun ω=>∑ i,min (Z ω i^2) (T ω i^2))
  let V := finiteAverage (fun ω=>scalarSpread (fun i=>max (Z ω i) (T ω i)))
  have hM : 0≤M := finiteAverage_nonneg _ (fun ω=>Finset.sum_nonneg (fun i _=>le_min (sq_nonneg _) (sq_nonneg _)))
  have hV : 0≤V := finiteAverage_nonneg _ (fun ω=>scalarSpread_nonneg _)
  have hD : D≤2*R*M := by
    dsimp [D,M]
    rw [finiteAverage_sum,finiteAverage_sum,Finset.mul_sum]
    apply Finset.sum_le_sum
    intro i _
    exact min_square_bound_of_moments (fun ω=>Z ω i) (fun ω=>T ω i) R hR
      (hAB i) (fun ω=>hZbound ω i) (fun ω=>hTbound ω i) (hpair i)
  have hspread : finiteAverage (fun ω=>scalarSpread (Z ω))≤2*V+2*D := by
    have hpoint (ω:Ω) : scalarSpread (Z ω)≤
        2*scalarSpread (fun i=>max (Z ω i) (T ω i))+2*(∑ i,T ω i^2) := by
      have h := scalarSpread_perturb (by omega : 0<p) (Z ω) (fun i=>max (Z ω i) (T ω i))
      have hs : (∑ i,(Z ω i-max (Z ω i) (T ω i))^2)≤∑ i,T ω i^2 := by
        apply Finset.sum_le_sum
        intro i _
        exact square_sub_max_le _ _ (hZ ω i) (hT ω i)
      linarith
    have h := finiteAverage_mono _ _ hpoint
    rw [finiteAverage_add,finiteAverage_mul_left,finiteAverage_mul_left] at h
    exact h
  have hc := independent_centering_bound p hp Z hcross
  rw [finiteAverage_add]
  change _+D≤(4+10*R)*(M+V)
  nlinarith [mul_nonneg hR hV]

end NeuralGeneralization.OnlineLowerRelu
