import NeuralGeneralization.OnlineLowerCentralBinomialBounds

/-! Uniform cubic error in the holomorphic central-binomial normalization. -/
noncomputable section
open scoped BigOperators Topology
open Filter
namespace NeuralGeneralization.OnlineLowerTanh

theorem norm_tsum_quartic_bound {a : ℝ} (ha : 1≤a) (f : ℕ→ℂ)
    (hf : ∀j, ‖f j‖≤16/(a+2*j)^4) :
    Summable f ∧ ‖∑'j,f j‖≤128/a^3 := by
  have hd : Summable (fun j:ℕ => 16/(a+2*j)^4) := by
    simpa [div_eq_mul_inv] using (summable_inverse_fourth_shift ha).mul_left 16
  have hn : Summable (fun j => ‖f j‖) := hd.of_nonneg_of_le (fun j=>norm_nonneg _) hf
  refine ⟨hn.of_norm,(norm_tsum_le_tsum_norm hn).trans ?_⟩
  calc
    _ ≤ ∑'j:ℕ,16/(a+2*j)^4 := hn.tsum_le_tsum hf hd
    _ = 16*(∑'j:ℕ,1/(a+2*j)^4) := by simp_rw [div_eq_mul_inv,one_mul]; rw [tsum_mul_left]
    _ ≤ 16*(8/a^3) := mul_le_mul_of_nonneg_left (tsum_inverse_fourth_bound ha) (by norm_num)
    _ = _ := by ring

theorem centralBinomial_even_inverse_tendsto {z : ℂ} (hz : z∈centralBinomialDomain) :
    Tendsto (fun j:ℕ => (centralBinomialEvenShift z j)⁻¹) atTop (𝓝 0) := by
  apply tendsto_zero_iff_norm_tendsto_zero.mpr
  have ht : Tendsto (fun j:ℕ => ‖z‖+2*(j:ℝ)) atTop atTop := by
    simpa only [add_comm] using
      (tendsto_natCast_atTop_atTop.const_mul_atTop (by norm_num : (0:ℝ)<2)).atTop_add
        (tendsto_const_nhds (x:=‖z‖))
  have hl : Tendsto (fun j:ℕ => 2/(‖z‖+2*(j:ℝ))) atTop (𝓝 0) :=
    tendsto_const_nhds.div_atTop ht
  apply squeeze_zero (fun j=>norm_nonneg _) _ hl
  intro j
  simpa using centralBinomial_inverse_center_bound hz j 0 (by norm_num)

theorem centralBinomialTelescoper_difference {z : ℂ} (hz : z∈centralBinomialDomain) (j : ℕ) :
    centralBinomialTelescoper z j = (1/2:ℂ)*
      ((centralBinomialEvenShift z j)⁻¹-(centralBinomialEvenShift z (j+1))⁻¹) := by
  have h0 := centralBinomialEvenShift_ne_zero hz j
  have h1 := centralBinomialEvenShift_ne_zero hz (j+1)
  have he : centralBinomialEvenShift z (j+1)=centralBinomialEvenShift z j+2 := by
    simp [centralBinomialEvenShift]; ring
  rw [he] at h1 ⊢
  unfold centralBinomialTelescoper
  field_simp
  ring

theorem summable_centralBinomialTelescoper {z : ℂ} (hz : z∈centralBinomialDomain) :
    Summable (centralBinomialTelescoper z) := by
  have he := (norm_tsum_quartic_bound (show 1≤‖z‖ by linarith [hz.2])
    _ (centralBinomial_inverse_error_bound hz)).1
  have hs := (summable_centralBinomialInverse hz.1.le).sub he
  simpa only [sub_sub_cancel] using hs

theorem tsum_centralBinomialTelescoper {z : ℂ} (hz : z∈centralBinomialDomain) :
    (∑'j,centralBinomialTelescoper z j)=(1/2:ℂ)*z⁻¹ := by
  apply HasSum.tsum_eq
  apply (summable_centralBinomialTelescoper hz).hasSum_iff_tendsto_nat.mpr
  have ht := ((tendsto_const_nhds (x:=z⁻¹)).sub (centralBinomial_even_inverse_tendsto hz)).const_mul (1/2:ℂ)
  simp only [sub_zero] at ht
  convert ht using 1
  funext n
  simp_rw [centralBinomialTelescoper_difference hz]
  rw [←Finset.mul_sum,Finset.sum_range_sub']
  simp [centralBinomialEvenShift]

theorem centralBinomialLog_expansion {z : ℂ} (hz : z∈centralBinomialDomain) :
    ‖centralBinomialLog z-(1/4:ℂ)*z⁻¹‖≤128/‖z‖^3 := by
  have hs := summable_centralBinomialInverse hz.1.le
  have hl := summable_centralBinomialLogTerm hz.1.le
  have ht := summable_centralBinomialTelescoper hz
  obtain ⟨_,h1⟩ := norm_tsum_quartic_bound (show 1≤‖z‖ by linarith [hz.2])
    _ (centralBinomial_log_first_error_bound hz)
  obtain ⟨_,h2⟩ := norm_tsum_quartic_bound (show 1≤‖z‖ by linarith [hz.2])
    _ (centralBinomial_inverse_error_bound hz)
  rw [hl.tsum_add hs] at h1
  rw [hs.tsum_sub ht,tsum_centralBinomialTelescoper hz] at h2
  have he : centralBinomialLog z-(1/4:ℂ)*z⁻¹ =
      -(1/2:ℂ)*((∑'j,centralBinomialLogTerm j z)+(∑'j,(centralBinomialShift z j)⁻¹^2)) +
      (1/2:ℂ)*((∑'j,(centralBinomialShift z j)⁻¹^2)-(1/2:ℂ)*z⁻¹) := by
    unfold centralBinomialLog
    ring
  rw [he]
  have hh := norm_add_le
    (-(1/2:ℂ)*((∑'j,centralBinomialLogTerm j z)+(∑'j,(centralBinomialShift z j)⁻¹^2)))
    ((1/2:ℂ)*((∑'j,(centralBinomialShift z j)⁻¹^2)-(1/2:ℂ)*z⁻¹))
  have hhalf : ‖(1/2:ℂ)‖=(1/2:ℝ) := by norm_num
  simp only [norm_mul,norm_neg,hhalf] at hh
  nlinarith

theorem centralBinomialLog_norm_bound {z : ℂ} (hz : 0<z.re) (ha : 32≤‖z‖) :
    ‖centralBinomialLog z‖ ≤ 1/‖z‖ := by
  have hdom : z∈centralBinomialDomain := ⟨hz,by linarith⟩
  have he := centralBinomialLog_expansion hdom
  have hnorm : ‖(1/4:ℂ)*z⁻¹‖=1/(4*‖z‖) := by
    norm_num [norm_mul,norm_div,norm_inv]
    ring
  have htriangle := norm_sub_le (centralBinomialLog z) ((1/4:ℂ)*z⁻¹)
  have hh := norm_le_norm_sub_add (centralBinomialLog z) ((1/4:ℂ)*z⁻¹)
  rw [hnorm] at hh
  refine hh.trans (le_trans (add_le_add he le_rfl) ?_)
  have ha0 : 0<‖z‖ := by linarith
  apply (le_div_iff₀ ha0).mpr
  field_simp
  nlinarith [sq_nonneg (‖z‖-32)]

/-- Uniform two-term expansion throughout the right half-plane. -/
theorem centralBinomialHolomorphic_expansion {z : ℂ} (hz : 0<z.re) (ha : 32≤‖z‖) :
    ‖centralBinomialHolomorphic z-(1+(1/4:ℂ)*z⁻¹+(1/32:ℂ)*z⁻¹^2)‖ ≤
      257/‖z‖^3 := by
  let L := centralBinomialLog z
  let u : ℂ := (1/4)*z⁻¹
  have hdom : z∈centralBinomialDomain := ⟨hz,by linarith⟩
  have he : ‖L-u‖≤128/‖z‖^3 := centralBinomialLog_expansion hdom
  have hL : ‖L‖≤1/‖z‖ := centralBinomialLog_norm_bound hz ha
  have ha0 : 0<‖z‖ := by linarith
  have hfrac : 1/‖z‖≤1 := (div_le_one ha0).mpr (by linarith)
  have hL1 : ‖L‖≤1 := hL.trans hfrac
  have hu : ‖u‖≤1 := by
    dsimp [u]
    norm_num [norm_mul,norm_div,norm_inv]
    have hi : ‖z‖⁻¹≤1 := by simpa [one_div] using hfrac
    linarith
  have hT := Complex.exp_bound hL1 (n:=3) (by norm_num)
  norm_num [Finset.sum_range_succ] at hT
  have hpoly : (1:ℂ)+L+L^2/2=1+L+(1/2:ℂ)*L^2 := by ring
  have hT' : ‖Complex.exp L-(1+L+(1/2:ℂ)*L^2)‖≤1/‖z‖^3 := by
    have hpow := pow_le_pow_left₀ (norm_nonneg L) hL 3
    have hp : (1/‖z‖)^3=1/‖z‖^3 := by rw [div_pow,one_pow]
    rw [hp] at hpow
    have hh : (∑ i∈Finset.range 3,L^i/(i.factorial:ℂ)) = 1+L+(1/2:ℂ)*L^2 := by
      norm_num [Finset.sum_range_succ]
      ring
    have hT₀ := Complex.exp_bound hL1 (n:=3) (by norm_num)
    rw [hh] at hT₀
    norm_num at hT₀
    nlinarith [pow_nonneg (norm_nonneg L) 3]
  have hs : ‖L+u‖≤2 := (norm_add_le L u).trans (by linarith)
  have hc : ‖(1/2:ℂ)*(L-u)*(L+u)‖≤‖L-u‖ := by
    rw [norm_mul,norm_mul]
    norm_num
    nlinarith [mul_le_mul_of_nonneg_left hs (norm_nonneg (L-u))]
  have hid : Complex.exp L-(1+u+(1/2:ℂ)*u^2) =
      (Complex.exp L-(1+L+(1/2:ℂ)*L^2))+(L-u)+(1/2:ℂ)*(L-u)*(L+u) := by ring
  have heq : 1+u+(1/2:ℂ)*u^2=1+(1/4:ℂ)*z⁻¹+(1/32:ℂ)*z⁻¹^2 := by dsimp [u]; ring
  unfold centralBinomialHolomorphic
  change ‖Complex.exp L-_‖≤_
  rw [←heq,hid]
  have hh := (norm_add_le ((Complex.exp L-(1+L+(1/2:ℂ)*L^2))+(L-u))
      ((1/2:ℂ)*(L-u)*(L+u))).trans
    (add_le_add (norm_add_le _ _) le_rfl)
  have h257 : 257/‖z‖^3=1/‖z‖^3+2*(128/‖z‖^3) := by ring
  rw [h257]
  linarith

end NeuralGeneralization.OnlineLowerTanh
