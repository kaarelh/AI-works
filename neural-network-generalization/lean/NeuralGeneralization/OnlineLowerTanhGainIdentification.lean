import NeuralGeneralization.OnlineLowerTanhOptimizedGain
import NeuralGeneralization.OnlineLowerTanhInterpolation
import NeuralGeneralization.OnlineLowerTanhBalancedGain

/-! The holomorphic stationary branch is real on real degrees and equals the
literal balanced maximizer at every sufficiently large odd integer. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped Topology BigOperators
open Complex Set Metric Filter ComplexConjugate
namespace NeuralGeneralization.OnlineLowerTanh

lemma hammingRatio_conj (j:ℕ) (z:ℂ) :
    hammingRatio j (conj z)=conj (hammingRatio j z) := by
  simp [hammingRatio,map_ofNat,map_prod,map_div₀,map_sub,map_add,map_mul]

lemma prefactoredRatio_conj (j:ℕ) (z:ℂ) :
    prefactoredRatio j (conj z)=conj (prefactoredRatio j z) := by
  simp [prefactoredRatio,hammingRatio_conj,map_div₀,map_mul,map_add]

lemma complexLogistic_conj (j:ℕ) (a:ℂ) :
    complexLogistic j (conj a)=conj (complexLogistic j a) := by
  simp [complexLogistic,map_ofNat,map_div₀,map_mul,map_add,map_neg,←Complex.exp_conj]

lemma complexLogisticFirst_conj (j:ℕ) (a:ℂ) :
    complexLogisticFirst j (conj a)=conj (complexLogisticFirst j a) := by
  simp [complexLogisticFirst,map_ofNat,map_div₀,map_mul,map_add,map_neg,map_pow,←Complex.exp_conj]

lemma complexF_conj (z a:ℂ) : complexF (conj z) (conj a)=conj (complexF z a) := by
  simp [complexF,complexLogistic_conj,prefactoredRatio_conj,Complex.conj_tsum,
    map_sub,map_mul,map_pow,map_ofNat]

lemma complexFDerivative_conj (z a:ℂ) :
    complexFDerivative (conj z) (conj a)=conj (complexFDerivative z a) := by
  simp [complexFDerivative,complexLogisticFirst_conj,prefactoredRatio_conj,
    Complex.conj_tsum,map_mul,map_pow,map_ofNat]

lemma complexStationary_conj (z a:ℂ) :
    complexStationary (conj z) (conj a)=conj (complexStationary z a) := by
  simp [complexStationary,complexFDerivative_conj,complexF_conj,map_mul,map_sub]

lemma actualGainBranch_real (b:ActualGainBranch) (x:ℝ)
    (hx:0<x) (hxT:b.threshold<x) : (b.gain (x:ℂ)).im=0 := by
  have hxN : b.threshold<‖(x:ℂ)‖ := by simpa [Complex.norm_real,Real.norm_eq_abs,abs_of_pos hx] using hxT
  obtain ⟨hmem,hzero,huniq⟩:=b.root (x:ℂ) hx hxN
  have hconjmem : conj (b.gain (x:ℂ))∈closedBall (limitingGain:ℂ) b.radius := by
    rw [Metric.mem_closedBall,dist_eq_norm]
    have he : conj (b.gain (x:ℂ))-(limitingGain:ℂ)=conj (b.gain (x:ℂ)-(limitingGain:ℂ)) := by simp
    rw [he,Complex.norm_conj]
    simpa only [Metric.mem_closedBall,dist_eq_norm] using hmem
  have hconjzero : complexStationary (x:ℂ) (conj (b.gain (x:ℂ)))=0 := by
    have hh:=complexStationary_conj (x:ℂ) (b.gain (x:ℂ))
    simpa [hzero] using hh
  have hd := huniq _ hconjmem
  rw [hconjzero,norm_zero,mul_zero,zero_div] at hd
  have he : b.gain (x:ℂ)=conj (b.gain (x:ℂ)) := sub_eq_zero.mp (norm_eq_zero.mp (le_antisymm hd (norm_nonneg _)))
  exact Complex.conj_eq_iff_im.mp he.symm

lemma complexFDerivative_odd_eq_balanced (r:ℕ) (a:ℝ) (ha:1<a) :
    complexFDerivative ((2*r+1:ℕ):ℂ) (a:ℂ)=
      (balancedParityFirst r a/oddParityKappa r:ℝ) := by
  have hc := complexF_hasDerivAt (z:=((2*r+1:ℕ):ℂ))
    (by simp only [Complex.natCast_re]; positivity) (a:=(a:ℂ)) ha
  have hr := hc.comp_ofReal
  have hreal := ((hasDerivAt_balancedParity r a).div_const (oddParityKappa r)).ofReal_comp
  have he : (fun y:ℝ=>complexF ((2*r+1:ℕ):ℂ) (y:ℂ))=
      (fun y:ℝ=>((balancedParity r y/oddParityKappa r:ℝ):ℂ)) :=
    funext (complexF_odd_eq_balanced r)
  rw [he] at hr
  exact hr.unique hreal

lemma complexStationary_odd_eq_balanced (r:ℕ) (a:ℝ) (ha:1<a) :
    complexStationary ((2*r+1:ℕ):ℂ) (a:ℂ)=
      (balancedStationary r a/oddParityKappa r:ℝ) := by
  unfold complexStationary balancedStationary
  rw [complexFDerivative_odd_eq_balanced r a ha,complexF_odd_eq_balanced]
  push_cast
  ring

/-- Exact equality with the actual chosen finite-degree maximizer. -/
theorem actualGainBranch_eq_balancedGain (b:ActualGainBranch) (r:ℕ)
    (hr:b.threshold<(2*r+1:ℕ)) :
    b.gain ((2*r+1:ℕ):ℂ)=(balancedGain r:ℂ) := by
  let n:ℝ := (2*r+1:ℕ)
  have hn:0<n := by dsimp [n]; positivity
  change b.threshold<n at hr
  have hreal := actualGainBranch_real b n hn hr
  let a:ℝ := (b.gain (n:ℂ)).re
  have he : b.gain (n:ℂ)=(a:ℂ) := by
    apply Complex.ext <;> simp [a,hreal]
  have hnN:b.threshold<‖(n:ℂ)‖ := by simpa [Complex.norm_real,Real.norm_eq_abs,abs_of_pos hn] using hr
  obtain ⟨hmem,hroot,_⟩:=b.root (n:ℂ) hn hnN
  have hnear:dist (a:ℂ) (limitingGain:ℂ)<(1/8:ℝ) := by
    rw [←he]
    have hh:dist (b.gain (n:ℂ)) (limitingGain:ℂ)≤b.radius:=hmem
    linarith [b.radius_small,b.radius_pos]
  obtain ⟨ha1,ha2⟩:=limitingGain_disk_bounds hnear
  have ha: a∈Ioo (1:ℝ) 2 := by
    simp only [Complex.ofReal_re] at ha1
    rw [Complex.norm_real,Real.norm_eq_abs,abs_of_pos (by linarith : 0<a)] at ha2
    exact ⟨ha1,ha2⟩
  rw [he] at hroot
  change complexStationary ((2*r+1:ℕ):ℂ) (a:ℂ)=0 at hroot
  rw [complexStationary_odd_eq_balanced r a ha.1] at hroot
  have hs:balancedStationary r a=0 := by
    have hh : balancedStationary r a/oddParityKappa r=0 := by exact_mod_cast hroot
    exact (div_eq_zero_iff.mp hh).resolve_right (oddParityKappa_pos r).ne'
  have hg:=balancedGain_eq_of_stationary r a ha hs
  simpa only [n,Complex.ofReal_natCast] using he.trans (congrArg Complex.ofReal hg.symm)

end NeuralGeneralization.OnlineLowerTanh
