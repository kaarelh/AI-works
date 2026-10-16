import NeuralGeneralization.BinomialSecondMoment
import NeuralGeneralization.IteratedArcsineLevelBounds
import NeuralGeneralization.ArcsineTraceReal
import NeuralGeneralization.NeuralSpectrumMonotone
import NeuralGeneralization.PairedWalshLevels

/-! Sharp second moments of the actual all-depth neural spectrum. -/
noncomputable section
namespace NeuralGeneralization
open scoped BigOperators

theorem arcsineProfile_coefficient_antitone_card {d : ℕ} (depth : ℕ)
    (S T : Finset (Fin d)) (hcard : S.card≤T.card) :
    walshCoefficients (arcsineProfile d depth) T≤
      walshCoefficients (arcsineProfile d depth) S := by
  obtain ⟨U,hUT,hU⟩ := Finset.exists_subset_card_eq hcard
  rw [arcsineProfile_coefficient_eq_of_card_eq depth S U hU.symm]
  exact arcsineProfile_coefficient_antitone depth hUT

lemma paired_level_mass_uniform {d depth k B : ℕ} {U β : ℝ}
    (hk : 0<k) (hβ : 0≤β)
    (hlevel : ∀ S : Finset (Fin d),pairedWalshDegree S≤B →
      (pairedWalshDegree S:ℝ)^(1+β)*((d+1).choose (pairedWalshDegree S):ℝ)*
        walshCoefficients (arcsineProfile d depth) S≤U)
    (S : Finset (Fin d)) (hSk : k≤pairedWalshDegree S) (hSB : pairedWalshDegree S≤B) :
    ((d+1).choose (pairedWalshDegree S):ℝ)*walshCoefficients (arcsineProfile d depth) S
      ≤U/(k:ℝ)^(1+β) := by
  have hk0 : (0:ℝ)<k := by exact_mod_cast hk
  have hcast : (k:ℝ)≤(pairedWalshDegree S:ℝ) := by exact_mod_cast hSk
  have hp := Real.rpow_le_rpow hk0.le hcast (by linarith : 0≤1+β)
  have hn : 0≤((d+1).choose (pairedWalshDegree S):ℝ)*
      walshCoefficients (arcsineProfile d depth) S :=
    mul_nonneg (Nat.cast_nonneg _) (arcsineProfile_coefficient_nonneg d depth S)
  have hh := mul_le_mul_of_nonneg_right hp hn
  apply (le_div_iff₀ (Real.rpow_pos_of_pos hk0 _)).mpr
  nlinarith only [hh,hlevel S hSB]

lemma level_scale_trace_identity {k : ℕ} (hk : 0<k) (β U : ℝ) :
    (k:ℝ)*(U/(k:ℝ)^(1+β))=U*(k:ℝ)^(-β) := by
  have hk0 : (0:ℝ)<k := by exact_mod_cast hk
  rw [Real.rpow_add hk0,Real.rpow_one,Real.rpow_neg hk0.le]
  field_simp

theorem arcsine_second_moment_of_level_bound {d depth k : ℕ} {U : ℝ}
    (hk : Odd k) (hkpos : 0<k) (hdim : 3*(2*k+2)≤d+1) (hU : 4≤U)
    (hlevel : ∀ S : Finset (Fin d),pairedWalshDegree S≤2*k+1 →
      (pairedWalshDegree S:ℝ)^(1+1/(2:ℝ)^depth)*
        ((d+1).choose (pairedWalshDegree S):ℝ)*
        walshCoefficients (arcsineProfile d depth) S≤U) :
    (∑ S ∈ Finset.univ.filter (fun S : Finset (Fin d)=>k-1≤S.card),
      walshCoefficients (arcsineProfile d depth) S^2) ≤
      3*(U/(k:ℝ)^(1+1/(2:ℝ)^depth))^2/((d+1).choose k:ℝ) := by
  classical
  let β : ℝ := 1/(2:ℝ)^depth
  let B : ℕ := 2*k+1
  let A := Finset.univ.filter (fun S : Finset (Fin d)=>k-1≤S.card)
  let w := walshCoefficients (arcsineProfile d depth)
  let T : ℝ := U/(k:ℝ)^(1+β)
  have hβ : 0≤β := by dsimp [β]; positivity
  have hU0 : 0≤U := by linarith
  have hBD : B≤d := by dsimp [B]; omega
  obtain ⟨Q,hQsub,hQ⟩ := Finset.exists_subset_card_eq
    (show B≤(Finset.univ : Finset (Fin d)).card by simpa using hBD)
  have hBodd : Odd B := ⟨k,rfl⟩
  have hQdegree : pairedWalshDegree Q=B := by
    unfold pairedWalshDegree
    rw [hQ,if_neg (Nat.not_even_iff_odd.mpr hBodd)]
  have hQmass : ((d+1).choose B:ℝ)*w Q≤T := by
    have hh := paired_level_mass_uniform hkpos hβ hlevel Q (by rw [hQdegree]; dsimp [B]; omega)
      (by rw [hQdegree])
    simpa only [hQdegree] using hh
  apply BinomialGeometry.second_moment_of_fibers A pairedWalshDegree w T (w Q)
    (D:=d+1) (k:=k) (B:=B) (by dsimp [B]; omega) (by simpa [B] using hdim)
    (div_nonneg hU0 (Real.rpow_nonneg (Nat.cast_nonneg k) _))
    (arcsineProfile_coefficient_nonneg d depth Q)
  · intro S hS
    exact pairedWalshDegree_ge_of_odd S hk (Finset.mem_filter.mp hS).2
  · intro j hj
    apply (Finset.card_le_card ?_).trans (pairedWalshDegree_fiber_card_le d j)
    intro S hS
    exact Finset.mem_filter.mpr ⟨Finset.mem_univ _,(Finset.mem_filter.mp hS).2⟩
  · intro S _
    exact arcsineProfile_coefficient_nonneg d depth S
  · intro S hS hSB
    exact paired_level_mass_uniform hkpos hβ hlevel S
      (pairedWalshDegree_ge_of_odd S hk (Finset.mem_filter.mp hS).2) hSB
  · intro S hS hSB
    apply arcsineProfile_coefficient_antitone_card depth Q S
    rw [hQ]
    have hSdeg := pairedWalshDegree_le_card_add_one S
    omega
  · exact hQmass
  · have hsub : A.filter (fun S=>B<pairedWalshDegree S) ⊆
        Finset.univ.filter (fun S : Finset (Fin d)=>B≤S.card) := by
      intro S hS
      have hh := (Finset.mem_filter.mp hS).2
      have hd := pairedWalshDegree_le_card_add_one S
      exact Finset.mem_filter.mpr ⟨Finset.mem_univ _,by omega⟩
    have hs := Finset.sum_le_sum_of_subset_of_nonneg hsub
      (fun S _ _ => arcsineProfile_coefficient_nonneg d depth S)
    change (∑ S ∈ A.filter (fun S=>B<pairedWalshDegree S),w S) ≤
      walshSpectralTail (arcsineProfile d depth) B at hs
    have htrace := iterated_arcsine_spectral_tail_upper d depth B (by dsimp [B]; omega)
    have hk0 : (0:ℝ)<k := by exact_mod_cast hkpos
    have hpow : (B:ℝ)^(-β)≤(k:ℝ)^(-β) :=
      Real.rpow_le_rpow_of_nonpos hk0 (by dsimp [B]; norm_cast; omega) (by linarith)
    have hm := mul_le_mul_of_nonneg_left hpow (by norm_num : (0:ℝ)≤4)
    have hscale := mul_le_mul_of_nonneg_right hU (Real.rpow_nonneg hk0.le (-β))
    change _≤(k:ℝ)*(U/(k:ℝ)^(1+β))
    rw [level_scale_trace_identity hkpos]
    exact hs.trans (htrace.trans (hm.trans hscale))

lemma squared_level_scale {j : ℕ} (hj : 0<j) (U β : ℝ) :
    (U/(j:ℝ)^(1+β))^2=U^2*(j:ℝ)^(-2-2*β) := by
  have hj0 : (0:ℝ)<j := by exact_mod_cast hj
  have hp : ((j:ℝ)^(1+β))^2=(j:ℝ)^((1+β)*2) := by
    rw [Real.rpow_mul hj0.le,Real.rpow_two]
  rw [show -2-2*β= -((1+β)*2) by ring,Real.rpow_neg hj0.le,div_pow,hp]
  ring

/-- The extra inverse-degree factor in the actual spectral second moment.
The first omitted reduced-cube level is `j-1`, and `j` is its odd paired level. -/
theorem iteratedArcsine_tail_second_moment_sharp (depth : ℕ) :
    ∃ C : ℝ,0<C ∧ ∀ d j : ℕ,Odd j → 0<j → 3*(2*j+2)≤d+1 →
      (∑ S ∈ Finset.univ.filter (fun S : Finset (Fin d)=>j-1≤S.card),
        walshCoefficients (arcsineProfile d (depth+1)) S^2) ≤
        C*(j:ℝ)^(-2-2/(2:ℝ)^(depth+1))/((d+1).choose j:ℝ) := by
  obtain ⟨l,U,hl,hU,hlevel⟩ := iteratedArcsine_paired_level_bounds depth
  let V := max U 4
  have hV : 0<V := lt_of_lt_of_le (by norm_num : (0:ℝ)<4) (le_max_right U 4)
  refine ⟨3*V^2,by positivity,?_⟩
  intro d j hj hjpos hdim
  have hmass : ∀ S : Finset (Fin d),pairedWalshDegree S≤2*j+1 →
      (pairedWalshDegree S:ℝ)^(1+1/(2:ℝ)^(depth+1))*
        ((d+1).choose (pairedWalshDegree S):ℝ)*
        walshCoefficients (arcsineProfile d (depth+1)) S≤V := by
    intro S hS
    exact ((hlevel d S (by omega)).2).trans (le_max_left U 4)
  have hh := arcsine_second_moment_of_level_bound hj hjpos hdim (le_max_right U 4) hmass
  rw [squared_level_scale hjpos] at hh
  dsimp only [V]
  rw [show -2-2/(2:ℝ)^(depth+1)= -2-2*(1/(2:ℝ)^(depth+1)) by ring]
  simpa only [mul_assoc] using hh

theorem iteratedArcsine_tail_second_moment_sharp_odd_cutoff (depth : ℕ) :
    ∃ C : ℝ,0<C ∧ ∀ d r : ℕ,Odd r → 3*(2*(r+2)+2)≤d+1 →
      (∑ S ∈ Finset.univ.filter (fun S : Finset (Fin d)=>r+1≤S.card),
        walshCoefficients (arcsineProfile d (depth+1)) S^2) ≤
        C*(r+2:ℝ)^(-2-2/(2:ℝ)^(depth+1))/((d+1).choose (r+2):ℝ) := by
  obtain ⟨C,hC,h⟩ := iteratedArcsine_tail_second_moment_sharp depth
  refine ⟨C,hC,?_⟩
  intro d r hr hdim
  have hr2 : Odd (r+2) := hr.add_even (by decide : Even 2)
  simpa only [show r+2-1=r+1 by omega,Nat.cast_add,Nat.cast_ofNat] using
    h d (r+2) hr2 (by omega) hdim

/-- The first omitted paired level bounds every eigenvalue above an odd
head cutoff. This uses actual inclusion monotonicity, including extreme degrees. -/
theorem iteratedArcsine_tail_eigenvalue_sharp (depth : ℕ) :
    ∃ C : ℝ,0<C ∧ ∀ d r : ℕ,Odd r → 200*(r+2)≤99*(d+1) →
      ∀ S : Finset (Fin d),r<S.card →
      walshCoefficients (arcsineProfile d (depth+1)) S≤
        C*(r+2:ℝ)^(-1-1/(2:ℝ)^(depth+1))/((d+1).choose (r+2):ℝ) := by
  obtain ⟨l,U,hl,hU,hlevel⟩ := iteratedArcsine_paired_level_bounds depth
  refine ⟨U,hU,?_⟩
  intro d r hr hdim S hS
  obtain ⟨Q,hQS,hQ⟩ := Finset.exists_subset_card_eq (show r+1≤S.card by omega)
  have hr2 : Odd (r+2) := hr.add_even (by decide : Even 2)
  have hQdegree : pairedWalshDegree Q=r+2 := by
    have hlow := pairedWalshDegree_ge_of_odd Q hr2 (by rw [hQ]; omega)
    have hup := pairedWalshDegree_le_card_add_one Q
    rw [hQ] at hup
    omega
  have hpoint := (hlevel d Q (by rwa [hQdegree])).2
  rw [hQdegree] at hpoint
  have hj0 : (0:ℝ)<(r+2:ℕ) := by positivity
  have hjD : r+2≤d+1 := by omega
  have hc : (0:ℝ)<(d+1).choose (r+2) := by exact_mod_cast Nat.choose_pos hjD
  have hp : (0:ℝ)<(r+2:ℕ)^(1+1/(2:ℝ)^(depth+1)) := Real.rpow_pos_of_pos hj0 _
  have hbound : walshCoefficients (arcsineProfile d (depth+1)) Q≤
      (U/((r+2:ℕ):ℝ)^(1+1/(2:ℝ)^(depth+1)))/((d+1).choose (r+2):ℝ) := by
    apply (le_div_iff₀ hc).mpr
    apply (le_div_iff₀ hp).mpr
    nlinarith only [hpoint]
  have hm := arcsineProfile_coefficient_antitone (depth+1) hQS
  have he : (U/((r+2:ℕ):ℝ)^(1+1/(2:ℝ)^(depth+1)))/((d+1).choose (r+2):ℝ)=
      U*(r+2:ℝ)^(-1-1/(2:ℝ)^(depth+1))/((d+1).choose (r+2):ℝ) := by
    push_cast
    rw [show -1-1/(2:ℝ)^(depth+1)= -(1+1/(2:ℝ)^(depth+1)) by ring,
      Real.rpow_neg (by positivity : (0:ℝ)≤r+2)]
    ring
  rw [he] at hbound
  exact hm.trans hbound

end NeuralGeneralization
