import NeuralGeneralization.BatchTwoActivationPolynomialDual

/-! Polynomial finite reconstruction with every local numerical budget
chosen explicitly. The polynomial degrees are deliberately loose. -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoActivation
open FiniteDifferential GaussianAngularFields GaussianAngularPrice
variable {I : Type*} [Fintype I] [Nonempty I] [DecidableEq I] {N n : ℕ}

def polynomialCutoffFeature (φ : ℝ → ℝ) (k : ℕ) (i : I) (z : I → ℝ) : ℝ :=
  smoothCutoff (cutoffRate I ((k:ℝ)^8)) ((k:ℝ)^8) z *
    smoothActivation (clippedActivation φ (4*(k:ℝ)^8)) (1/(k:ℝ)^12) (z i)

def polynomialLayerBad (c : I → Fin n → ℝ) (φ : ℝ → ℝ) (k N : ℕ) (M q : ℝ) :
    Set (Fin N → Fin n → ℝ) :=
  activationLayerBad c (fun pq z => polynomialCutoffFeature φ k pq.1 z*
    polynomialCutoffFeature φ k pq.2 z) N M ((k:ℝ)^32) ((k:ℝ)^4) q

def polynomialBulkSourceBound (k r : ℕ) : ℝ :=
  4*(k:ℝ)^36+4*(k:ℝ)^48*((r:ℝ)+1)+4

def polynomialStepWeightBound (k r : ℕ) (V Bh : ℝ) : ℝ :=
  (V+1)*polynomialBulkSourceBound k r+V*Bh*(k:ℝ)^10

theorem polynomial_gaussian_one_step {J : Type*} [Fintype J] [DecidableEq J]
    (c : I → Fin n → ℝ) (x : Fin N → Fin n → ℝ) (k : ℕ) (hk : 128≤k)
    {φ : ℝ → ℝ} {ℓ M B q V Bh : ℝ}
    (hφ : zeroLipschitzActivation ℓ φ) (hℓ0 : 0<ℓ) (hM0 : 0<M) (hB0 : 0≤B) (hq0 : 0<q)
    (hℓ : ℓ≤k) (hM : M≤k) (hB : B≤k)
    (hq : q≤k) (hA : 8*(q+Real.log 3)≤k)
    (hgauss : gaussianBulkThreshold I M≤k)
    (hlog : Real.log (2*Fintype.card I)≤k)
    (hb : ∀t,|deriv scalarCutoff t|≤B) (hbb : ∀t,|deriv (deriv scalarCutoff) t|≤B)
    (hN : 0<N) (hvar : ∀i,(∑j,(c i j)^2)≤M)
    (hgood : x∉polynomialLayerBad c φ k N M q)
    (h : J → I → ℝ) (v : J → ℝ) (hV : 0≤V) (hBh : 0≤Bh)
    (hv : ∀j,0≤v j) (hvV : ∀j,v j≤V) (hh : ∀j i,|h j i|≤Bh)
    (hQ : ∀i j,|weightedFeatureGram h v i j-gram c i j|≤1/(k:ℝ)^160) :
    ∃(ψ : (Fin (k^48) ⊕ Fin (k^20)) → ℝ → ℝ)
      (W : (Fin (k^48) ⊕ Fin (k^20)) → J → ℝ)
      (v' : (Fin (k^48) ⊕ Fin (k^20)) → ℝ),
      (∀j,zeroLipschitzActivation ℓ (ψ j)) ∧
      (∀j,0≤v' j ∧ v' j≤max 1 (8*(q+Real.log 3))) ∧
      (∀j l,|W j l|≤polynomialStepWeightBound k (Fintype.card J) V Bh) ∧
      (∀j i,|ψ j (∑l,W j l*h l i)|≤
        ℓ*(Fintype.card J:ℝ)*polynomialStepWeightBound k (Fintype.card J) V Bh*Bh) ∧
      ∀p q', |weightedFeatureGram (fun j i => ψ j (∑l,W j l*h l i)) v' p q'-
        (∑j,φ (fieldLinear c (x j) p)*φ (fieldLinear c (x j) q'))/(N:ℝ)|<1/(k:ℝ) := by
  have hkR : (128:ℝ)≤k := by exact_mod_cast hk
  have hk0 : 0<k := by omega
  have hkR0 : (0:ℝ)<k := Nat.cast_pos.mpr hk0
  have hkR1 : (1:ℝ)≤k := by linarith
  have hk16 : (16:ℝ)≤k := by linarith
  let T := (k:ℝ)^8
  let τ := 1/(k:ℝ)^12
  let a := cutoffRate I T
  let A := 8*(q+Real.log 3)
  let R := polynomialBulkSourceBound k (Fintype.card J)
  have hT : 0<T := pow_pos hkR0 _
  have ha : 0<a := cutoffRate_pos hT
  have hA0 : 0<A := by dsimp [A]; positivity
  have hR : 0≤R := by dsimp [R,polynomialBulkSourceBound]; positivity
  let b := polynomialCutoffJet (I:=I) hk16 hℓ0.le hB0 hℓ hB hlog hφ hb hbb
  have hbval (i : I) (z : I → ℝ) : (b i).value z=polynomialCutoffFeature φ k i z := rfl
  have happ (p q' : I) (z : I → ℝ) : |(b p).value z*(b q').value z-
      actualCutoffFeature φ a T p z*actualCutoffFeature φ a T q' z|≤16*ℓ^2*T*τ :=
    cutoffFeature_covariance_approximation hℓ0.le ha hT (by positivity)
      hB0 hφ hb hbb p q' z
  have henergy : ∑j,‖gaussianResidualSource c M (x j)‖^2≤(N:ℝ)*A := by
    have hn : x∉residualBadRows c N M q := fun hx => hgood (Or.inl hx)
    have ht : ∑j,‖gaussianResidualSource c M (x j)‖^2<8*(N:ℝ)*(q+Real.log 3) := lt_of_not_ge hn
    dsimp [A]
    nlinarith
  have hdual : x∉scaledBadRows c (fun (pq : I×I) z => (b pq.1).value z*(b pq.2).value z)
      N (((k:ℝ)^16)^2) ((k:ℝ)^4) q := by
    intro hh'
    apply hgood (Or.inr ?_)
    simpa only [hbval,←pow_mul] using hh'
  have hBT : 2*gaussianBulkThreshold I M≤T := by
    have hpow := power_coefficient_enlarge hkR1 (show (2:ℝ)≤k by linarith) (show 1+1≤8 by omega)
    dsimp [T]
    nlinarith
  have hQη : ∀i j,|weightedFeatureGram h v i j-gram c i j|≤(1/(k:ℝ)^10)^2 := by
    intro i j
    apply (hQ i j).trans
    have he : (1/(k:ℝ)^10)^2=1/(k:ℝ)^20 := by field_simp <;> ring
    rw [he]
    exact reciprocal_power_mono hkR1 (by norm_num) (by omega)
  have hnA : 0<k^20 := Nat.pow_pos hk0
  have hnB : 0<k^48 := Nat.pow_pos hk0
  have hm0 : (0:ℝ)<Fintype.card I := Nat.cast_pos.mpr Fintype.card_pos
  have hbudgetA : 2*(Fintype.card I:ℝ)^2*Real.exp (-(k^20:ℝ)*(((1/(k:ℝ)^2)/A)/(ℓ*Real.sqrt M)^2)^2/2)<1 := by
    have hr := atom_sampling_rate_polynomial hkR hℓ0 hM0 hA0 hℓ hM hA (le_refl ((k:ℝ)^20))
    have hs := finite_covariance_union_small hm0 hkR hlog hr
    have he : -((k:ℝ)^20)*(((1/(k:ℝ)^2)/A)/(ℓ*Real.sqrt M)^2)^2/2=
        -(((k:ℝ)^20)*(((1/(k:ℝ)^2)/A)/(ℓ*Real.sqrt M)^2)^2/2) := by ring
    rw [he]
    exact hs.trans (by norm_num)
  have hbudgetB : 2*(Fintype.card I:ℝ)^2*Real.exp (-(k^48:ℝ)*((1/(k:ℝ)^2)/(4*ℓ*T)^2)^2/2)+
      2*(k^48:ℝ)*(Fintype.card J:ℝ)*Real.exp (2*((k:ℝ)^4*((k:ℝ)^16)^2)-R^2/2)<1 := by
    have hr := bulk_sampling_rate_polynomial hkR hℓ0 hℓ (le_refl ((k:ℝ)^48))
    have hs := finite_covariance_union_small hm0 hkR hlog hr
    have hRbound : 4*((k:ℝ)^4*((k:ℝ)^16)^2)+4*(k^48:ℝ)*((Fintype.card J:ℝ)+1)+4≤R := by
      dsimp [R,polynomialBulkSourceBound]
      ring_nf
      exact le_rfl
    have ht := gaussian_source_union_small (by positivity : 0≤(k:ℝ)^4*((k:ℝ)^16)^2)
      (by positivity : 0≤(k^48:ℝ)) (Nat.cast_nonneg (Fintype.card J)) hRbound
    have he : -((k:ℝ)^48)*((1/(k:ℝ)^2)/(4*ℓ*T)^2)^2/2=
        -(((k:ℝ)^48)*((1/(k:ℝ)^2)/(4*ℓ*T)^2)^2/2) := by ring
    rw [he]
    dsimp [T] at *
    linarith
  obtain ⟨ψ,W,v',hψ,hv',hW,hstate,hcov⟩ := gaussian_one_step_realization c x hφ hℓ0 hM0 ha hT
    hA0 (pow_pos hkR0 16) (pow_nonneg hkR0.le 16) (pow_nonneg hkR0.le 16)
    (pow_pos hkR0 4) (by positivity : 0≤1/(k:ℝ)^160) (by positivity : 0<1/(k:ℝ)^10)
    (by positivity : 0≤1/(k:ℝ)^2) (by positivity : 0≤1/(k:ℝ)^2)
    hR hV hBh hN hnA hnB hBT (cutoffRate_scale hT) hvar henergy b happ hdual
    h v hv hvV hh hQ hQη (by simpa only [Nat.cast_pow] using hbudgetA)
    (by simpa only [Nat.cast_pow] using hbudgetB)
  have hWbound : max (Real.sqrt V*R) (V*Bh/(4*(1/(k:ℝ)^10)))≤
      polynomialStepWeightBound k (Fintype.card J) V Bh := by
    apply max_le
    · have hsqrt : Real.sqrt V≤V+1 := by
        have hs := Real.sq_sqrt hV
        nlinarith [Real.sqrt_nonneg V,sq_nonneg V]
      have hm := mul_le_mul_of_nonneg_right hsqrt hR
      dsimp [polynomialStepWeightBound]
      nlinarith [mul_nonneg (mul_nonneg hV hBh) (pow_nonneg hkR0.le 10)]
    · have he : V*Bh/(4*(1/(k:ℝ)^10))=V*Bh*(k:ℝ)^10/4 := by field_simp <;> ring
      rw [he]
      dsimp [polynomialStepWeightBound]
      nlinarith [mul_nonneg (mul_nonneg hV hBh) (pow_nonneg hkR0.le 10)]
  refine ⟨ψ,W,v',hψ,hv',fun j l => (hW j l).trans hWbound,?_,?_⟩
  · intro j i
    apply (hstate j i).trans
    gcongr
  · intro p q'
    apply (hcov p q').trans_le
    exact polynomial_one_step_error hkR hℓ0.le (Real.sqrt_nonneg _) hM0.le hA0.le
      hℓ hgauss hM hA hq

end NeuralGeneralization.BatchTwoActivation
