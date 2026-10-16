import NeuralGeneralization.NeuralRadialSpectrum
import NeuralGeneralization.BinomialGeometricBounds

/-! Exponential far-pair coherence of the actual neural spectral tail. -/
noncomputable section
namespace NeuralGeneralization.NeuralTailCoherence
open scoped BigOperators
open NeuralRadialSpectrum WalshLevelKrawtchouk

lemma low_degree_count {d r : ℕ} (hr : r≤d) :
    (Finset.univ.filter (fun S : Finset (Fin d)=>S.card≤r)).card=
      ∑j∈Finset.range (r+1),d.choose j := by
  classical
  let A := Finset.univ.filter (fun S : Finset (Fin d)=>S.card≤r)
  have hmaps : ∀S∈A,S.card∈Finset.range (r+1) := by
    intro S hS
    apply Finset.mem_range.mpr
    have hh := (Finset.mem_filter.mp hS).2
    omega
  have hs := Finset.sum_fiberwise_of_maps_to hmaps (fun _ : Finset (Fin d)=>(1:ℕ))
  simp only [Finset.sum_const,nsmul_eq_mul,mul_one] at hs
  have hcount : (∑j∈Finset.range (r+1),(A.filter (fun S=>S.card=j)).card)=A.card := by
    simpa using hs
  change A.card= _
  rw [← hcount]
  apply Finset.sum_congr rfl
  intro j hj
  have hjr : j≤r := by have := Finset.mem_range.mp hj; omega
  have he : A.filter (fun S=>S.card=j)=
      Finset.univ.filter (fun S : Finset (Fin d)=>S.card=j) := by
    ext S
    simp only [A,Finset.mem_filter,Finset.mem_univ,true_and]
    constructor
    · exact And.right
    · intro hS
      exact ⟨hS ▸ hjr,hS⟩
  rw [he,card_level]

lemma high_degree_count {d r : ℕ} (hr : 3*r≤d) :
    (Finset.univ.filter (fun S : Finset (Fin d)=>d-r≤S.card)).card≤2*d.choose r := by
  classical
  have hc : (Finset.univ.filter (fun S : Finset (Fin d)=>d-r≤S.card)).card≤
      (Finset.univ.filter (fun S : Finset (Fin d)=>S.card≤r)).card := by
    apply Finset.card_le_card_of_injOn (fun S : Finset (Fin d)=>Sᶜ)
    · intro S hS
      apply Finset.mem_filter.mpr
      refine ⟨Finset.mem_univ _,?_⟩
      rw [Finset.card_compl,Fintype.card_fin]
      have hh := (Finset.mem_filter.mp hS).2
      omega
    · intro S _ T _ hST
      exact compl_injective hST
  rw [low_degree_count (by omega : r≤d)] at hc
  exact hc.trans (BinomialGeometry.choose_sum_range_le hr)

lemma extreme_trace_bound {d r : ℕ} (depth : ℕ) (hr : 0<r) (hdim : 6*r≤d) :
    walshSpectralTail (arcsineProfile d depth) (d-r)≤2/(2:ℝ)^r := by
  classical
  let A := Finset.univ.filter (fun S : Finset (Fin d)=>d-r≤S.card)
  have hp : (0:ℝ)<d.choose (2*r) := by
    exact_mod_cast Nat.choose_pos (by omega : 2*r≤d)
  have hpoint (S : Finset (Fin d)) (hS : S∈A) :
      walshCoefficients (arcsineProfile d depth) S≤1/(d.choose (2*r):ℝ) := by
    have hcard := (Finset.mem_filter.mp hS).2
    have hh := arcsineProfile_coefficient_binomial_le_tail depth (2*r) S (by omega)
    apply (le_div_iff₀ hp).mpr
    simpa only [mul_comm] using hh.trans (spectral_tail_le_one d depth (2*r))
  have hs := Finset.sum_le_sum hpoint
  simp only [Finset.sum_const,nsmul_eq_mul] at hs
  have hcount : (A.card:ℝ)≤2*(d.choose r:ℝ) := by
    exact_mod_cast high_degree_count (d:=d) (r:=r) (by omega)
  have hgrowth : (2:ℝ)^r*(d.choose r:ℝ)≤d.choose (2*r) := by
    have hh := BinomialGeometry.choose_growth (D:=d) (k:=r) (j:=2*r) (B:=2*r)
      (by omega) le_rfl (by omega)
    rw [show 2*r-r=r by omega] at hh
    exact_mod_cast hh
  calc
    _ ≤ (A.card:ℝ)*(1/(d.choose (2*r):ℝ)) := hs
    _ ≤ (2*(d.choose r:ℝ))*(1/(d.choose (2*r):ℝ)) :=
      mul_le_mul_of_nonneg_right hcount (by positivity)
    _ ≤ 2/(2:ℝ)^r := by
      rw [mul_one_div]
      apply (div_le_div_iff₀ hp (by positivity : (0:ℝ)<2^r)).mpr
      nlinarith only [hgrowth]

lemma levelKernel_abs_le_choose {d : ℕ} (j : ℕ) (x y : ClippingCube d) :
    |levelKernel j x y|≤(d.choose j:ℝ) := by
  classical
  unfold levelKernel
  calc
    _ ≤ ∑S∈Finset.univ.filter (fun S : Finset (Fin d)=>S.card=j),
        |walshCharacter S x*walshCharacter S y| := Finset.abs_sum_le_sum_abs _ _
    _ = ∑S∈Finset.univ.filter (fun S : Finset (Fin d)=>S.card=j),(1:ℝ) := by
      apply Finset.sum_congr rfl
      intro S hS
      have hx : |walshCharacter S x|=1 := (sq_eq_one_iff.mp (walshCharacter_sq S x)).elim
        (fun h=>by simp [h]) (fun h=>by simp [h])
      have hy : |walshCharacter S y|=1 := (sq_eq_one_iff.mp (walshCharacter_sq S y)).elim
        (fun h=>by simp [h]) (fun h=>by simp [h])
      rw [abs_mul,hx,hy,mul_one]
    _ = _ := by rw [Finset.sum_const,card_level]; simp

lemma middle_level_coherence {d r j : ℕ} (x y : ClippingCube d)
    (hr : 0<r) (hrj : r≤j) (hjr : j≤d-r)
    (hfar₁ : (d:ℝ)/4≤hammingDist x y)
    (hfar₂ : (hammingDist x y:ℝ)≤3*(d:ℝ)/4) :
    |levelKernel j x y|≤(d.choose j:ℝ)*((d+1:ℝ)*Real.exp (-(r:ℝ)/4)) := by
  have hj : 0<j := by omega
  have hjd : j<d := by omega
  have hp : (0:ℝ)<d.choose j := by exact_mod_cast Nat.choose_pos hjd.le
  have hh := far_pair_levelKernel_bound_all x y j hj hjd hfar₁ hfar₂
  have hmin : r≤min j (d-j) := by omega
  have hminR : (r:ℝ)≤(min j (d-j):ℕ) := by exact_mod_cast hmin
  have he : Real.exp (-(min j (d-j):ℕ)/4)≤Real.exp (-(r:ℝ)/4) := by
    apply Real.exp_le_exp.mpr
    linarith
  have hm := mul_le_mul_of_nonneg_left he (by positivity : (0:ℝ)≤d+1)
  have ht := (div_le_iff₀ hp).mp (hh.trans hm)
  simpa only [mul_comm] using ht

/-- Uniform far-pair coherence of every actual arcsine spectral tail. -/
theorem arcsineTailCovariance_far {d r : ℕ} (depth : ℕ) (hr : 0<r) (hdim : 6*r≤d)
    (x y : ClippingCube d)
    (hfar₁ : (d:ℝ)/4≤hammingDist x y)
    (hfar₂ : (hammingDist x y:ℝ)≤3*(d:ℝ)/4) :
    |arcsineTailCovariance d depth r x y|≤
      (d+1:ℝ)*Real.exp (-(r:ℝ)/4)+2/(2:ℝ)^r := by
  classical
  let E : ℝ := (d+1:ℝ)*Real.exp (-(r:ℝ)/4)
  let M : ℕ→ℝ := fun j=>(d.choose j:ℝ)*levelWeight d depth j
  have hE : 0≤E := by dsimp [E]; positivity
  have hM (j : ℕ) : 0≤M j := mul_nonneg (Nat.cast_nonneg _) (levelWeight_nonneg _ _ _)
  have hpoint (j : ℕ) (hj : j∈Finset.range (d+1)) :
      |if r≤j then levelWeight d depth j*levelKernel j x y else 0|≤
        E*M j+(if d-r≤j then M j else 0) := by
    by_cases hrj : r≤j
    · rw [if_pos hrj,abs_mul,abs_of_nonneg (levelWeight_nonneg d depth j)]
      by_cases hhigh : d-r≤j
      · rw [if_pos hhigh]
        have hh := mul_le_mul_of_nonneg_left (levelKernel_abs_le_choose j x y)
          (levelWeight_nonneg d depth j)
        have hEM : 0≤E*M j := mul_nonneg hE (hM j)
        dsimp only [M] at hEM ⊢
        nlinarith only [hh,hEM]
      · rw [if_neg hhigh,add_zero]
        have hh := mul_le_mul_of_nonneg_left
          (middle_level_coherence x y hr hrj (by omega) hfar₁ hfar₂)
          (levelWeight_nonneg d depth j)
        dsimp only [E,M]
        nlinarith only [hh]
    · rw [if_neg hrj,abs_zero]
      exact add_nonneg (mul_nonneg hE (hM j)) (by split_ifs; exact hM j; exact le_rfl)
  rw [tailCovariance_degree_sum]
  calc
    _ ≤ ∑j∈Finset.range (d+1),
        |if r≤j then levelWeight d depth j*levelKernel j x y else 0| :=
      Finset.abs_sum_le_sum_abs _ _
    _ ≤ ∑j∈Finset.range (d+1),(E*M j+(if d-r≤j then M j else 0)) :=
      Finset.sum_le_sum hpoint
    _ = E+walshSpectralTail (arcsineProfile d depth) (d-r) := by
      rw [Finset.sum_add_distrib,← Finset.mul_sum]
      dsimp only [M]
      rw [levelWeight_total,mul_one,← spectral_tail_degree_sum]
    _ ≤ E+2/(2:ℝ)^r := by linarith only [extreme_trace_bound depth hr hdim]
    _ = _ := rfl

end NeuralGeneralization.NeuralTailCoherence
