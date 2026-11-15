import NeuralGeneralization.BatchTwoManuscriptResourcePolynomial
import NeuralGeneralization.BatchTwoManuscriptGrid

/-! A universal degree-45 envelope for the literal logarithmic grid entropy. -/
noncomputable section
set_option autoImplicit false
set_option maxHeartbeats 1000000
namespace NeuralGeneralization.BatchTwoManuscriptResources

def gridLogFactor (p : Input) : ℝ :=
  Real.log (3+32*weightBound p*((p.dimension:ℝ)+p.depth+1)*
    (2*(widthBound p:ℝ)*(weightBound p+1))^p.depth/p.radius)

theorem gridLogFactor_nonneg (p : Input) : 0≤gridLogFactor p := by
  have hB := (weightBound_pos p).le
  have hr := p.radius_pos
  unfold gridLogFactor
  apply Real.log_nonneg
  have hh : 0≤32*weightBound p*((p.dimension:ℝ)+p.depth+1)*
      (2*(widthBound p:ℝ)*(weightBound p+1))^p.depth/p.radius := by positivity
  linarith

theorem gridLogFactor_upper (p : Input) :
    gridLogFactor p≤Real.log 35+Real.log (weightBound p)+
      Real.log ((p.dimension:ℝ)+p.depth+1)+
      (p.depth:ℝ)*Real.log (2*(widthBound p:ℝ)*(weightBound p+1))+Real.log (p.radius⁻¹) := by
  let B := weightBound p
  let D := (p.dimension:ℝ)+p.depth+1
  let V := 2*(widthBound p:ℝ)*(weightBound p+1)
  let R := p.radius⁻¹
  have hB : 1≤B := weightBound_ge_one p
  have hD : 1≤D := by dsimp [D]; linarith [Nat.cast_nonneg (α:=ℝ) p.dimension,Nat.cast_nonneg (α:=ℝ) p.depth]
  have hM : (1:ℝ)≤widthBound p := by exact_mod_cast widthBound_pos p
  have hV : 1≤V := by dsimp [V]; nlinarith [weightBound_ge_one p]
  have hR : 1≤R := (one_le_inv₀ p.radius_pos).mpr p.radius_le_one
  have hpow : 1≤V^p.depth := one_le_pow₀ hV
  have hX : 1≤B*D*V^p.depth*R :=
    one_le_mul_of_one_le_of_one_le
      (one_le_mul_of_one_le_of_one_le (one_le_mul_of_one_le_of_one_le hB hD) hpow) hR
  have hB0 : 0<B := by linarith
  have hD0 : 0<D := by linarith
  have hV0 : 0<V := by linarith
  have hR0 : 0<R := by linarith
  have hid : gridLogFactor p=Real.log (3+32*(B*D*V^p.depth*R)) := by
    unfold gridLogFactor
    congr 1
    dsimp [B,D,V,R]
    field_simp
  rw [hid]
  have hh := Real.log_le_log (show 0<3+32*(B*D*V^p.depth*R) by positivity)
    (show 3+32*(B*D*V^p.depth*R)≤35*(B*D*V^p.depth*R) by linarith)
  rw [Real.log_mul (by norm_num : (35:ℝ)≠0) (by positivity : B*D*V^p.depth*R≠0),
    Real.log_mul (by positivity : B*D*V^p.depth≠0) hR0.ne',
    Real.log_mul (by positivity : B*D≠0) (pow_pos hV0 _).ne',
    Real.log_mul hB0.ne' hD0.ne',Real.log_pow] at hh
  change _≤Real.log 35+Real.log B+Real.log D+(p.depth:ℝ)*Real.log V+Real.log R
  linarith

variable {AK AR AF : ℝ} (hK : 0<AK) (hR : 0<AR) (hF : 0<AF)

include hK hR hF in
theorem gridLogFactor_polynomial : PolynomialGrowth AK AR AF gridLogFactor 2 := by
  have hB := (weightBound_polynomial hK hR hF).log weightBound_ge_one
  have hD : PolynomialGrowth AK AR AF (fun p=>(p.dimension:ℝ)+p.depth+1) 1 :=
    (PolynomialGrowth.dimension.add PolynomialGrowth.depth).add ((PolynomialGrowth.const 1).mono (by omega))
  have hlogD := hD.log (by intro p; linarith [Nat.cast_nonneg (α:=ℝ) p.dimension,Nat.cast_nonneg (α:=ℝ) p.depth])
  have hbase := ((widthBound_polynomial hK hR hF).mul
    ((weightBound_polynomial hK hR hF).add ((PolynomialGrowth.const 1).mono (by omega)))).const_mul 2
  have hbase' : PolynomialGrowth AK AR AF (fun p=>2*(widthBound p:ℝ)*(weightBound p+1)) 43 :=
    hbase.congr (by intro p; ring)
  have hlogBase := hbase'.log (by
    intro p
    have hm : (1:ℝ)≤widthBound p := by exact_mod_cast widthBound_pos p
    nlinarith [weightBound_ge_one p])
  have hdepth := PolynomialGrowth.depth.mul hlogBase
  have hlogR := (PolynomialGrowth.radius (AK:=AK) (AF:=AF) hR).log
    (fun p=>(one_le_inv₀ p.radius_pos).mpr p.radius_le_one)
  have hall := (((((PolynomialGrowth.const (Real.log 35)).mono (by omega : 0≤2)).add
    (hB.mono (by omega))).add (hlogD.mono (by omega))).add hdepth).add (hlogR.mono (by omega))
  exact hall.nonnegative_le gridLogFactor_nonneg gridLogFactor_upper

include hK hR hF in
theorem gridEntropy_polynomial : PolynomialGrowth AK AR AF gridEntropy 45 :=
  (parameterCount_polynomial hK hR hF).mul (gridLogFactor_polynomial hK hR hF)

end NeuralGeneralization.BatchTwoManuscriptResources
