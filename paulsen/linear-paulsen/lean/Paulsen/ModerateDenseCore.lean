import Paulsen.ModerateDenseVariance
import Paulsen.DensePerturbation
import Mathlib.Analysis.Complex.ExponentialBounds

/-! A dense core in the actual affine retained-tangent Gaussian. -/

namespace Paulsen
open Matrix MeasureTheory ProbabilityTheory Set
open scoped BigOperators
noncomputable section

theorem retainedTangentRow_small_fraction_failure {n d : ℕ} [NeZero n]
    {U : Frame n d} (hU : IsParseval U) {ρ a t : ℝ}
    (hρ : 0≤ρ) (ha : 0<a) (ht : 0<t)
    (m : EuclideanSpace ℝ (Fin n)) (i : Fin n)
    (hgood : (((retainedTangentVarianceGood U ρ a i)ᶜ).card:ℝ)/(n:ℝ)≤1/1000) :
    (stdGaussian (FrameVector n d)).real {g |
      1/20 ≤ smallCoordinateFraction (t*Real.sqrt (a/(n:ℝ))/1000)
        (m+t • Matrix.toEuclideanLin (retainedTangentRowFactor U ρ i) g)} ≤
      Real.exp (-(a*(n:ℝ))/(4000000000000*Real.pi^2)) := by
  have hn : (0:ℝ)<n := Nat.cast_pos.mpr (NeZero.pos n)
  have hs : 0<Real.sqrt (a/(n:ℝ)) := Real.sqrt_pos.mpr (by positivity)
  have hsqrt : Real.sqrt (2*(t^2*a/(8*(n:ℝ))))=t*Real.sqrt (a/(n:ℝ))/2 := by
    apply (Real.sqrt_eq_iff_eq_sq (by positivity) (by positivity)).mpr
    rw [div_pow, mul_pow, Real.sq_sqrt (by positivity)]
    ring
  have hratio : (t*Real.sqrt (a/(n:ℝ))/1000)/Real.sqrt (2*(t^2*a/(8*(n:ℝ))))=1/500 := by
    rw [hsqrt]
    field_simp
    norm_num
  have hthreshold : Real.exp 1*((t*Real.sqrt (a/(n:ℝ))/1000)/
      Real.sqrt (2*(t^2*a/(8*(n:ℝ))))+
      (((retainedTangentVarianceGood U ρ a i)ᶜ).card:ℝ)/(n:ℝ)+1/1000)≤1/20 := by
    rw [hratio]
    calc
      _ ≤ Real.exp 1*(1/500+1/1000+1/1000) := by gcongr
      _ ≤ 3*(1/500+1/1000+1/1000) := by
        gcongr
        exact le_of_lt Real.exp_one_lt_three
      _ ≤ _ := by norm_num
  have hb := retainedTangentRow_smallCoordinate_tail hU hρ ha ht
    (show (0:ℝ)<t*Real.sqrt (a/(n:ℝ))/1000 by positivity)
    (show (0:ℝ)≤1/1000 by norm_num) m i
  have he : -((1/1000:ℝ)^2*(t*Real.sqrt (a/(n:ℝ))/1000)^2*(n:ℝ))/
      (2*Real.pi^2*(2*t^2/(n:ℝ))) = -(a*(n:ℝ))/(4000000000000*Real.pi^2) := by
    simp only [div_pow, mul_pow, Real.sq_sqrt (show (0:ℝ)≤a/(n:ℝ) by positivity)]
    field_simp
    ring
  rw [he] at hb
  exact (measureReal_mono (fun g hg => hthreshold.trans hg)).trans hb

def moderateVarianceExceptional {n d : ℕ} (U : Frame n d) (ρ : ℝ) : Finset (Fin n) :=
  Finset.univ.filter fun i => ((d:ℝ)/(n:ℝ))/1000000≤positiveResidualRowLoss U ρ i

theorem moderateVarianceExceptional_card_le {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (hp : ∀ i, 0<rowNormSq U i) (hn : 0<n) (hd : 0<d)
    {ρ : ℝ} (hρ : 0≤ρ) : (moderateVarianceExceptional U ρ).card≤2000000 := by
  have hb := positiveResidualRowLoss_density_large_card_le hU hp hn hd hρ
    (show (0:ℝ)<1/1000000 by norm_num)
  have he : (1/1000000:ℝ)*((d:ℝ)/(n:ℝ))=((d:ℝ)/(n:ℝ))/1000000 := by ring
  rw [he] at hb
  change ((moderateVarianceExceptional U ρ).card:ℝ)≤_ at hb
  norm_num at hb
  exact_mod_cast hb

/-- Uniform over all deterministic matrix means; tangent coordinates may be correlated. -/
theorem retainedTangent_dense_core_failure {n d : ℕ} [NeZero n]
    {U : Frame n d} (hU : IsParseval U) (hd : 1000000≤d) (hdn : d≤n)
    (hdensity : (d:ℝ)/(n:ℝ)≤1/2)
    (hrows : ∀ i, ((d:ℝ)/(n:ℝ))/2≤rowNormSq U i ∧
      rowNormSq U i≤3*((d:ℝ)/(n:ℝ))/2)
    {ρ t : ℝ} (hρ : 0≤ρ) (ht : 0<t) (M : Frame n n) :
    (stdGaussian (FrameVector n d)).real {g | ∃ i, i∉moderateVarianceExceptional U ρ ∧
      1/20≤smallCoordinateFraction (t*Real.sqrt (((d:ℝ)/(n:ℝ))/(n:ℝ))/1000)
        (WithLp.toLp 2 (M i)+t • Matrix.toEuclideanLin (retainedTangentRowFactor U ρ i) g)} ≤
      (n:ℝ)*Real.exp (-(d:ℝ)/(4000000000000*Real.pi^2)) := by
  have hn : 0<n := NeZero.pos n
  have hn' : (0:ℝ)<n := Nat.cast_pos.mpr hn
  have hd' : (0:ℝ)<d := Nat.cast_pos.mpr (by omega : 0<d)
  let bad (i : Fin n) : Set (FrameVector n d) := {g | i∉moderateVarianceExceptional U ρ ∧
    1/20≤smallCoordinateFraction (t*Real.sqrt (((d:ℝ)/(n:ℝ))/(n:ℝ))/1000)
      (WithLp.toLp 2 (M i)+t • Matrix.toEuclideanLin (retainedTangentRowFactor U ρ i) g)}
  have hb (i : Fin n) : (stdGaussian (FrameVector n d)).real (bad i)≤
      Real.exp (-(d:ℝ)/(4000000000000*Real.pi^2)) := by
    by_cases hi : i∈moderateVarianceExceptional U ρ
    · simpa only [bad, hi, not_true_eq_false, false_and, setOf_false, measureReal_empty] using
        (Real.exp_pos (-(d:ℝ)/(4000000000000*Real.pi^2))).le
    · have hrow : positiveResidualRowLoss U ρ i≤((d:ℝ)/(n:ℝ))/1000000 := by
        have hh : ¬ ((d:ℝ)/(n:ℝ))/1000000≤positiveResidualRowLoss U ρ i := by
          simpa only [moderateVarianceExceptional, Finset.mem_filter, Finset.mem_univ, true_and] using hi
        exact (lt_of_not_ge hh).le
      have hc := retainedTangentVarianceGood_compl_fraction_le hU hn hd hdn hdensity hrows hρ i hrow
      have hh := retainedTangentRow_small_fraction_failure hU hρ
        (show (0:ℝ)<(d:ℝ)/(n:ℝ) by positivity) ht (WithLp.toLp 2 (M i)) i hc
      rw [div_mul_cancel₀ _ hn'.ne'] at hh
      simpa only [bad, hi, not_false_eq_true, true_and] using hh
  have he : {g | ∃ i, i∉moderateVarianceExceptional U ρ ∧
      1/20≤smallCoordinateFraction (t*Real.sqrt (((d:ℝ)/(n:ℝ))/(n:ℝ))/1000)
        (WithLp.toLp 2 (M i)+t • Matrix.toEuclideanLin (retainedTangentRowFactor U ρ i) g)} =
      ⋃ i, bad i := by ext g; simp only [mem_setOf_eq, mem_iUnion, bad]
  rw [he]
  calc
    _ ≤ ∑ i, (stdGaussian (FrameVector n d)).real (bad i) := measureReal_iUnion_fintype_le _
    _ ≤ ∑ _i : Fin n, Real.exp (-(d:ℝ)/(4000000000000*Real.pi^2)) :=
      Finset.sum_le_sum fun i _ => hb i
    _ = _ := by simp

theorem gaussian_dense_failure_budget {n : ℕ} (hn : 0<n) {d c : ℝ}
    (hc : 0<c) (hd : c*Real.log (100*(n:ℝ))≤d) :
    (n:ℝ)*Real.exp (-d/c)≤1/100 := by
  have hn' : (0:ℝ)<n := Nat.cast_pos.mpr hn
  have hdiv : Real.log (100*(n:ℝ))≤d/c := (le_div_iff₀ hc).mpr (by simpa only [mul_comm] using hd)
  have hexp : Real.exp (-d/c)≤(100*(n:ℝ))⁻¹ := by
    calc
      _ ≤ Real.exp (-Real.log (100*(n:ℝ))) := by
        apply Real.exp_le_exp.mpr
        simpa only [neg_div] using neg_le_neg hdiv
      _ = _ := by rw [Real.exp_neg, Real.exp_log (by positivity)]
  calc
    _ ≤ (n:ℝ)*(100*(n:ℝ))⁻¹ := mul_le_mul_of_nonneg_left hexp hn'.le
    _ = _ := by field_simp

theorem retainedTangent_dense_core_failure_le {n d : ℕ} [NeZero n]
    {U : Frame n d} (hU : IsParseval U) (hd : 1000000≤d) (hdn : d≤n)
    (hdensity : (d:ℝ)/(n:ℝ)≤1/2)
    (hrows : ∀ i, ((d:ℝ)/(n:ℝ))/2≤rowNormSq U i ∧
      rowNormSq U i≤3*((d:ℝ)/(n:ℝ))/2)
    (hlog : (4000000000000*Real.pi^2)*Real.log (100*(n:ℝ))≤(d:ℝ))
    {ρ t : ℝ} (hρ : 0≤ρ) (ht : 0<t) (M : Frame n n) :
    (stdGaussian (FrameVector n d)).real {g | ∃ i, i∉moderateVarianceExceptional U ρ ∧
      1/20≤smallCoordinateFraction (t*Real.sqrt (((d:ℝ)/(n:ℝ))/(n:ℝ))/1000)
        (WithLp.toLp 2 (M i)+t • Matrix.toEuclideanLin (retainedTangentRowFactor U ρ i) g)} ≤1/100 :=
  (retainedTangent_dense_core_failure hU hd hdn hdensity hrows hρ ht M).trans
    (gaussian_dense_failure_budget (NeZero.pos n) (by positivity) hlog)

/-- A small fraction of small coordinates means a large fraction of squared
entries above the corresponding graph threshold. -/
theorem smallCoordinateFraction_lt_implies_dense {n : ℕ} [NeZero n]
    (z : EuclideanSpace ℝ (Fin n)) {h : ℝ} (hh : 0≤h)
    (hz : smallCoordinateFraction h z<1/20) :
    19*n≤20*(Finset.univ.filter fun j => h^2≤(z j)^2).card := by
  let S := Finset.univ.filter fun j : Fin n => |z j|≤h
  let T := Finset.univ.filter fun j : Fin n => h^2≤(z j)^2
  have hc : (S.card:ℝ)/(n:ℝ)<1/20 := by
    simpa only [smallCoordinateFraction, Fintype.card_fin] using hz
  have hn : (0:ℝ)<n := Nat.cast_pos.mpr (NeZero.pos n)
  have hcR : 20*(S.card:ℝ)<n := by
    have hd := (div_lt_iff₀ hn).mp hc
    linarith
  have hcN : 20*S.card<n := by exact_mod_cast hcR
  have hsub : Sᶜ⊆T := by
    intro j hj
    have hj' : h < |z j| := by
      simpa only [S, Finset.mem_compl, Finset.mem_filter, Finset.mem_univ, true_and, not_le] using hj
    apply Finset.mem_filter.mpr
    refine ⟨Finset.mem_univ _, ?_⟩
    nlinarith [sq_abs (z j)]
  have hb := Finset.card_le_card hsub
  have hs := Finset.card_add_card_compl S
  simp only [Fintype.card_fin] at hs
  change 19*n≤20*T.card
  omega

theorem dense_row_ninetyfive_to_ninety {ι : Type*} [Fintype ι] [DecidableEq ι]
    (u v : ι → ℝ) {τ : ℝ} (hτ : 0<τ)
    (hdense : 19*Fintype.card ι≤20*(Finset.univ.filter fun i => 4*τ≤(u i)^2).card)
    (herror : (∑ i, (u i-v i)^2)≤τ*(Fintype.card ι:ℝ)/20) :
    9*Fintype.card ι≤10*(Finset.univ.filter fun i => τ≤(v i)^2).card := by
  let S := Finset.univ.filter fun i => 4*τ≤(u i)^2
  let T := Finset.univ.filter fun i => τ≤(v i)^2
  have he := (lost_large_entries_energy_le u v τ).trans herror
  have hcardR : 20*((S \ T).card:ℝ)≤(Fintype.card ι:ℝ) := by
    change τ*((S \ T).card:ℝ)≤τ*(Fintype.card ι:ℝ)/20 at he
    nlinarith
  have hc : 20*(S \ T).card≤Fintype.card ι := by exact_mod_cast hcardR
  have hcover : S.card≤(S \ T).card+T.card := Finset.card_le_card_sdiff_add_card
  change 19*Fintype.card ι≤20*S.card at hdense
  change 9*Fintype.card ι≤10*T.card
  omega

theorem dense_neighbors_ninetyfive_to_ninety {n : ℕ} [NeZero n]
    (A B : Frame n n) {γ : ℝ} (hγ : 0<γ) (i : Fin n)
    (hdense : 19*n≤20*(largeNeighbors (fun i j => (A i j)^2) (4*γ) i).card)
    (herror : rowNormSq (A-B) i≤γ/20) :
    9*n≤10*(largeNeighbors (fun i j => (B i j)^2) γ i).card := by
  have hn : (0:ℝ)<n := Nat.cast_pos.mpr (NeZero.pos n)
  have hd : 19*Fintype.card (Fin n)≤20*(Finset.univ.filter fun j =>
      4*(γ/(n:ℝ))≤(A i j)^2).card := by
    simpa only [largeNeighbors, Fintype.card_fin, mul_div_assoc] using hdense
  have he : (∑ j, (A i j-B i j)^2)≤(γ/(n:ℝ))*(Fintype.card (Fin n):ℝ)/20 := by
    simpa only [Fintype.card_fin, div_mul_cancel₀ _ hn.ne', rowNormSq, Matrix.sub_apply] using herror
  simpa only [Fintype.card_fin, largeNeighbors] using
    dense_row_ninetyfive_to_ninety (A i) (B i) (div_pos hγ hn) hd he

theorem retainedTangentRow_apply {n d : ℕ} (U : Frame n d) (ρ : ℝ)
    (i j : Fin n) (g : FrameVector n d) :
    Matrix.toEuclideanLin (retainedTangentRowFactor U ρ i) g j =
      Matrix.toEuclideanLin (retainedTangentFactor U ρ) g (i,j) := rfl

theorem retainedTangent_dense_neighbors {n d : ℕ} [NeZero n]
    (U : Frame n d) (ρ t : ℝ) (ht : 0≤t) (M : Frame n n) (g : FrameVector n d)
    (i : Fin n)
    (hsmall : smallCoordinateFraction (t*Real.sqrt (((d:ℝ)/(n:ℝ))/(n:ℝ))/1000)
      (WithLp.toLp 2 (M i)+t • Matrix.toEuclideanLin (retainedTangentRowFactor U ρ i) g)<1/20) :
    19*n≤20*(largeNeighbors
      (fun i j => (M i j+t*Matrix.toEuclideanLin (retainedTangentFactor U ρ) g (i,j))^2)
      (t^2*((d:ℝ)/(n:ℝ))/1000000) i).card := by
  have hz := smallCoordinateFraction_lt_implies_dense _ (show (0:ℝ)≤
    t*Real.sqrt (((d:ℝ)/(n:ℝ))/(n:ℝ))/1000 by positivity) hsmall
  have hs : (t*Real.sqrt (((d:ℝ)/(n:ℝ))/(n:ℝ))/1000)^2=
      (t^2*((d:ℝ)/(n:ℝ))/1000000)/(n:ℝ) := by
    rw [div_pow, mul_pow, Real.sq_sqrt (by positivity)]
    ring
  simpa only [hs, PiLp.add_apply, PiLp.smul_apply, smul_eq_mul,
    retainedTangentRow_apply, largeNeighbors, Fintype.card_fin] using hz

end
end Paulsen
