import NeuralGeneralization.BatchTwoManuscriptPolynomialAlgebra

/-! Literal resource exponents: rank 13, sampled width 21, parameter count 43,
and bounded coefficients 22 in the universal problem size. -/
noncomputable section
set_option autoImplicit false
set_option maxHeartbeats 1000000
namespace NeuralGeneralization.BatchTwoManuscriptResources
variable {AK AR AF : ℝ} (hK : 0<AK) (hR : 0<AR) (hF : 0<AF)

include hR hF in
theorem localError_inverse_polynomial : PolynomialGrowth AK AR AF (fun p=>(localError p)⁻¹) 8 := by
  exact (((PolynomialGrowth.depth.mul (PolynomialGrowth.failure hF)).mul
    ((PolynomialGrowth.radius hR).pow 2)).const_mul 1000).congr (by intro p; unfold localError; field_simp)

include hF in
theorem localFailure_inverse_polynomial : PolynomialGrowth AK AR AF (fun p=>(localFailure p)⁻¹) 2 := by
  exact ((PolynomialGrowth.depth.mul (PolynomialGrowth.failure hF)).const_mul 100).congr
    (by intro p; unfold localFailure; field_simp)

include hK hR hF in
theorem rank_polynomial : PolynomialGrowth AK AR AF (fun p=>(rank p:ℝ)) 13 := by
  exact ((((PolynomialGrowth.energy hK).mul (localError_inverse_polynomial hR hF)).mul
    (localFailure_inverse_polynomial hF)).const_mul 2).ceil.congr (by
      intro p; unfold rank; congr 1; congr 1; field_simp)

include hK hR hF in
theorem activeEnergy_polynomial : PolynomialGrowth AK AR AF activeEnergy 13 := by
  exact (((PolynomialGrowth.energy hK).const_mul 8).mono (by omega : 3≤13)).add
    ((rank_polynomial hK hR hF).const_mul 2)

include hK hF in
theorem readoutEnergy_polynomial : PolynomialGrowth AK AR AF readoutEnergy 5 := by
  exact ((((PolynomialGrowth.energy hK).const_mul 4).add
    ((PolynomialGrowth.const (2*Real.log 2)).mono (by omega))).mul
      (localFailure_inverse_polynomial hF)).congr (by intro p; unfold readoutEnergy; field_simp)

include hK hR hF in
theorem messageCost_polynomial : PolynomialGrowth AK AR AF messageCost 14 := by
  have hd : PolynomialGrowth AK AR AF (fun p=>(p.dimension:ℝ)+1) 1 :=
    PolynomialGrowth.dimension.add ((PolynomialGrowth.const 1).mono (by omega))
  exact (((hd.mul (rank_polynomial hK hR hF)).add ((PolynomialGrowth.const 2).mono (by omega))).const_mul
    (Real.log 2)).congr (by intro p; unfold messageCost; ring)

include hK hR hF in
theorem bankSize_polynomial : PolynomialGrowth AK AR AF (fun p=>(bankSize p:ℝ)) 21 := by
  have hq := rank_polynomial hK hR hF
  have hqp := hq.add ((PolynomialGrowth.const 1).mono (by omega))
  have he := localError_inverse_polynomial (AK:=AK) hR hF
  have hη := localFailure_inverse_polynomial (AK:=AK) (AR:=AR) hF
  have hfirst := ((((activeEnergy_polynomial hK hR hF).add hq).add
    ((PolynomialGrowth.const 1).mono (by omega))).mul he).const_mul 10000
  have harg : PolynomialGrowth AK AR AF (fun p=>4*((rank p:ℝ)+1)/localFailure p) 15 :=
    ((hqp.const_mul 4).mul hη).congr (by intro p; field_simp)
  have hlog := harg.log (by
    intro p
    apply (le_div_iff₀ (localFailure_pos p)).mpr
    nlinarith [localFailure_le_one p,Nat.cast_nonneg (α:=ℝ) (rank p)])
  have hsecond := ((hqp.mul hlog).const_mul 64).mono (by omega : 14≤21)
  have harg2 : PolynomialGrowth AK AR AF (fun p=>2/localFailure p) 2 :=
    (hη.const_mul 2).congr (by intro p; field_simp)
  have hlog2 := harg2.log (by
    intro p
    apply (le_div_iff₀ (localFailure_pos p)).mpr
    linarith [localFailure_le_one p])
  have hd : PolynomialGrowth AK AR AF (fun p=>(p.dimension:ℝ)*Real.log 2) 1 :=
    (PolynomialGrowth.dimension.const_mul (Real.log 2)).congr (by intro p; ring)
  have hfactor := (hd.add hlog2).add ((PolynomialGrowth.const 1).mono (by omega))
  have hthird := ((((readoutEnergy_polynomial (AR:=AR) hK hF).mul ((PolynomialGrowth.radius hR).pow 2)).mul
    hfactor).const_mul 512).mono (by omega : 12≤21)
  exact ((hfirst.max_growth hsecond).max_growth hthird).ceil.congr (by
    intro p
    unfold bankSize sampleCost
    congr 2 <;> field_simp <;> ring)

include hK hR hF in
theorem widthBound_polynomial : PolynomialGrowth AK AR AF (fun p=>(widthBound p:ℝ)) 21 := by
  have hm := bankSize_polynomial hK hR hF
  have hother := (PolynomialGrowth.depth.mul (messageCost_polynomial hK hR hF)).divide_ge_one
    (fun p=>p.energy_ge_one)
  have ho := hother.ceil.mono (by omega : 15≤21)
  exact ((hm.max_growth ho).max_growth ((PolynomialGrowth.const 1).mono (by omega))).congr (by
    intro p; unfold widthBound; simp only [Nat.cast_max,Nat.cast_one])

include hK hR hF in
theorem parameterCount_polynomial :
    PolynomialGrowth AK AR AF (fun p=>(parameterCount p.dimension (widthBound p) p.depth:ℝ)) 43 := by
  have hm := widthBound_polynomial hK hR hF
  have hd : PolynomialGrowth AK AR AF (fun p=>(p.dimension:ℝ)+1) 1 :=
    PolynomialGrowth.dimension.add ((PolynomialGrowth.const 1).mono (by omega))
  have hf := (hm.mul hd).mono (by omega : 22≤43)
  have hl : PolynomialGrowth AK AR AF (fun p=>((p.depth-2:ℕ):ℝ)) 1 :=
    PolynomialGrowth.depth.nonnegative_le (fun p=>Nat.cast_nonneg _) (fun p=>by exact_mod_cast Nat.sub_le p.depth 2)
  exact ((hf.add (hl.mul (hm.pow 2))).add (hm.mono (by omega))).congr (by
    intro p; unfold parameterCount; push_cast; ring)

include hK hR hF in
theorem smallBound_polynomial : PolynomialGrowth AK AR AF smallBound 22 := by
  have hm := widthBound_polynomial hK hR hF
  have hp := parameterCount_polynomial hK hR hF
  have hh := (((hm.mul (PolynomialGrowth.energy hK)).const_mul 4).mono (by omega : 24≤43)).add
    (hp.const_mul (2*Real.log 2))
  have hsq := ((hh.mul (PolynomialGrowth.failure hF)).const_mul 4)
  exact hsq.sqrt_even.congr (by intro p; unfold smallBound; congr 1; field_simp <;> ring)

include hK hR hF in
theorem firstBound_polynomial : PolynomialGrowth AK AR AF firstBound 6 := by
  have hd : PolynomialGrowth AK AR AF (fun p=>(p.dimension:ℝ)+1) 1 :=
    PolynomialGrowth.dimension.add ((PolynomialGrowth.const 1).mono (by omega))
  have hnum := ((PolynomialGrowth.energy hK).const_mul 4).add ((hd.const_mul (2*Real.log 2)).mono (by omega))
  exact (((hnum.mul (localError_inverse_polynomial hR hF)).const_mul 4).mono
    (by omega : 11≤12)).sqrt_even.congr (by intro p; unfold firstBound; congr 1; field_simp <;> ring)

include hK hR hF in
theorem activeBound_polynomial : PolynomialGrowth AK AR AF activeBound 11 := by
  exact ((((activeEnergy_polynomial hK hR hF).mul (localError_inverse_polynomial hR hF)).const_mul 4).mono
    (by omega : 21≤22)).sqrt_even.congr (by intro p; unfold activeBound; congr 1; field_simp)

theorem localError_le_one (p : Input) : localError p≤1 := by
  unfold localError
  apply (div_le_one (by have := depth_pos p; positivity)).mpr
  have hr := p.radius_le_one
  have hr0 := p.radius_pos
  have hf := p.failure_le_eighth
  have hf0 := p.failure_pos
  have hd2 : (2:ℝ)≤p.depth := by exact_mod_cast p.depth_ge_two
  nlinarith [mul_le_mul_of_nonneg_left (show p.radius^2≤1 by nlinarith) hf0.le]

include hK hR hF in
theorem gaussianBound_polynomial : PolynomialGrowth AK AR AF gaussianBound 1 := by
  have harg : PolynomialGrowth AK AR AF (fun p=>6*(bankSize p:ℝ)/localError p) 29 :=
    (((bankSize_polynomial hK hR hF).mul (localError_inverse_polynomial hR hF)).const_mul 6).congr
      (by intro p; field_simp)
  have hlog := harg.log (by
    intro p
    apply (le_div_iff₀ (localError_pos p)).mpr
    have hm : (1:ℝ)≤bankSize p := by exact_mod_cast bankSize_pos p
    linarith [localError_le_one p])
  exact ((PolynomialGrowth.const 2).mono (by omega) |>.max_growth
    ((hlog.mono (by omega : 1≤2)).sqrt_even.const_mul 2))

include hK hR hF in
theorem weightBound_polynomial : PolynomialGrowth AK AR AF weightBound 22 := by
  have hsmall := smallBound_polynomial hK hR hF
  have hfirst := (firstBound_polynomial hK hR hF).mono (by omega : 6≤22)
  have hqp := (rank_polynomial hK hR hF).add ((PolynomialGrowth.const 1).mono (by omega))
  have hact := (((activeBound_polynomial hK hR hF).mul
    ((hqp.mono (by omega : 13≤14)).sqrt_even (n:=7))).const_mul 2).divide_ge_one (g:=fun p=>(bankSize p:ℝ))
      (fun p=>by exact_mod_cast bankSize_pos p)
  have hgauss := ((gaussianBound_polynomial hK hR hF).const_mul (Real.sqrt 2)).divide_ge_one
    (g:=fun p=>Real.sqrt (bankSize p:ℝ)) (fun p=>by
      have hh : (1:ℝ)≤bankSize p := by exact_mod_cast bankSize_pos p
      simpa using Real.sqrt_le_sqrt hh)
  have hmid := (hact.mono (by omega : 18≤22)).add (hgauss.mono (by omega : 1≤22))
  have hread := (((readoutEnergy_polynomial (AR:=AR) hK hF).mono (by omega : 5≤6)).sqrt_even (n:=3)).divide_ge_one
    (g:=fun p=>(bankSize p:ℝ)) (fun p=>by exact_mod_cast bankSize_pos p)
  have hone : PolynomialGrowth AK AR AF (fun _=>1) 22 := (PolynomialGrowth.const 1).mono (by omega : 0≤22)
  exact ((hsmall.max_growth (((hfirst.max_growth hmid).max_growth (hread.mono (by omega))).max_growth hone)).max_growth hone).congr
    (by intro p; unfold weightBound largeBound; simp only [mul_assoc])

end NeuralGeneralization.BatchTwoManuscriptResources
