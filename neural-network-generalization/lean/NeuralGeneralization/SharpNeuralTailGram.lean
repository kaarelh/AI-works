import NeuralGeneralization.NeuralTailGram
import NeuralGeneralization.CubeRestrictionLog
import NeuralGeneralization.CubeNearAsymptotics
import NeuralGeneralization.TailCoherenceAsymptotics

/-! A dimension-normalized tail Gram bound for actual IID neural-kernel samples. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
namespace NeuralGeneralization.RandomRestriction
open scoped BigOperators Matrix.Norms.L2Operator
open SquaredSampling Classical NeuralRadialSpectrum CubeFarPairs
attribute [local instance] Classical.propDecidable

/-- An explicit universal constant; optimization is immaterial here. -/
def gramMomentConstant : ℝ :=
  256*restrictionConstant+512*restrictionConstant*(Real.exp 1+1)+2048

def gramConstant : ℝ := 1+32*(gramMomentConstant+1)

lemma gramMomentConstant_nonneg : 0 ≤ gramMomentConstant := by
  unfold gramMomentConstant restrictionConstant
  positivity

lemma gramConstant_pos : 0 < gramConstant := by
  unfold gramConstant
  have := gramMomentConstant_nonneg
  linarith

lemma tailGramBudget_le_dimension_square {d n : ℕ} (hd : 0<d)
    (rho ell tau s2 : ℝ) (hrho : 0≤rho) (hell : 0≤ell) (htau : 0≤tau) (hs2 : 0≤s2)
    (hcoh : (d:ℝ)*rho≤tau) (hnear : (n:ℝ)*nearProbabilityBound d≤1) :
    tailGramBudget d n rho ell tau s2≤
      gramMomentConstant*(tau+Real.sqrt ((n:ℝ)*(d:ℝ)*s2)+(n:ℝ)*ell)^2 := by
  let H := tau+Real.sqrt ((n:ℝ)*(d:ℝ)*s2)+(n:ℝ)*ell
  have hR : 0≤restrictionConstant := by unfold restrictionConstant; positivity
  have hL := restrictionLog_cube_le hd
  have hlog := log_cube_card_le d
  have hlog0 : 0≤Real.log (Fintype.card (ClippingCube d):ℝ) :=
    Real.log_nonneg (by exact_mod_cast Fintype.card_pos_iff.mpr inferInstance)
  have hn0 : (0:ℝ)≤n := Nat.cast_nonneg n
  have hd0 : (0:ℝ)≤d := Nat.cast_nonneg d
  have hq0 := nearProbabilityBound_nonneg d
  have hsqrt := Real.sq_sqrt (mul_nonneg (mul_nonneg hn0 hd0) hs2)
  have hH0 : 0≤H := by dsimp [H]; positivity
  have htauH : tau≤H := by dsimp [H]; have := Real.sqrt_nonneg ((n:ℝ)*(d:ℝ)*s2); have := mul_nonneg (Nat.cast_nonneg n (α:=ℝ)) hell; linarith
  have hsqrtH : Real.sqrt ((n:ℝ)*(d:ℝ)*s2)≤H := by dsimp [H]; have := mul_nonneg hn0 hell; linarith
  have hnellH : (n:ℝ)*ell≤H := by dsimp [H]; have := Real.sqrt_nonneg ((n:ℝ)*(d:ℝ)*s2); linarith
  have htau2 : tau^2≤H^2 := (sq_le_sq₀ htau hH0).mpr htauH
  have hsqrt2 : (n:ℝ)*(d:ℝ)*s2≤H^2 := by
    rw [←hsqrt]
    exact (sq_le_sq₀ (Real.sqrt_nonneg _) hH0).mpr hsqrtH
  have hnell2 : ((n:ℝ)*ell)^2≤H^2 := (sq_le_sq₀ (mul_nonneg hn0 hell) hH0).mpr hnellH
  have hdrho : ((d:ℝ)*rho)^2≤tau^2 :=
    (sq_le_sq₀ (mul_nonneg hd0 hrho) htau).mpr hcoh
  have hnq : ((n:ℝ)*tau*nearProbabilityBound d)^2≤H^2 := by
    have hh : (n:ℝ)*tau*nearProbabilityBound d≤tau := by nlinarith only [mul_le_mul_of_nonneg_left hnear htau]
    exact ((sq_le_sq₀ (by positivity) htau).mpr hh).trans htau2
  have h₁ : restrictionConstant*restrictionLog (Fintype.card (ClippingCube d))
      (Fintype.card (ClippingCube d))*rho^2*Real.log (Fintype.card (ClippingCube d))≤
      8*restrictionConstant*H^2 := by
    calc
      _ ≤ restrictionConstant*(8*(d:ℝ))*rho^2*(d:ℝ) := by gcongr
      _ = 8*restrictionConstant*((d:ℝ)*rho)^2 := by ring
      _ ≤ 8*restrictionConstant*H^2 := mul_le_mul_of_nonneg_left (hdrho.trans htau2) (by positivity)
  have h₂ : 2*restrictionConstant*(Real.exp 1+1)*(n:ℝ)*
      restrictionLog (Fintype.card (ClippingCube d)) (Fintype.card (ClippingCube d))*s2≤
      16*restrictionConstant*(Real.exp 1+1)*H^2 := by
    calc
      _ ≤ 2*restrictionConstant*(Real.exp 1+1)*(n:ℝ)*(8*(d:ℝ))*s2 := by gcongr
      _ = 16*restrictionConstant*(Real.exp 1+1)*((n:ℝ)*(d:ℝ)*s2) := by ring
      _ ≤ _ := mul_le_mul_of_nonneg_left hsqrt2 (by positivity)
  have h₃ : 16*(n:ℝ)^2*(ell+tau*nearProbabilityBound d)^2≤64*H^2 := by
    have hx := sq_nonneg ((n:ℝ)*ell-(n:ℝ)*tau*nearProbabilityBound d)
    nlinarith only [hx,hnell2,hnq]
  unfold tailGramBudget gramMomentConstant
  change _≤(256*restrictionConstant+512*restrictionConstant*(Real.exp 1+1)+2048)*H^2
  nlinarith only [h₁,h₂,h₃]

/-- An actual high-probability Gram upper bound. Its remaining hypotheses
are explicit scalar inequalities, and its spectral maximum may be any
proved upper bound on the actual tail coefficients. -/
theorem arcsine_tail_gram_good_probability_of_scalars {d r n : ℕ}
    (depth : ℕ) (hr : 0<r) (hdim : 6*r≤d) (hn : 4≤n)
    (hnm : 2*n≤Fintype.card (ClippingCube d))
    (ell : ℝ) (hell : 0≤ell)
    (hmax : ∀ S : Finset (Fin d),r≤S.card → walshCoefficients (arcsineProfile d depth) S≤ell)
    (htau : 0<walshSpectralTail (arcsineProfile d depth) r)
    (hcoh : (d:ℝ)*neuralTailCoherence d r≤walshSpectralTail (arcsineProfile d depth) r)
    (hnear : (n:ℝ)*nearProbabilityBound d≤1)
    (herrors : (n:ℝ)*((n:ℝ)-1)/(Fintype.card (ClippingCube d):ℝ)+
      (n:ℝ)^2*nearProbabilityBound d≤1/32) :
    15/16≤ConcreteModel.sampleProbability (ConcreteModel.uniformLaw d) n
      (fun s => ∀ u : Fin n → ℝ,
        finiteQuadratic (fun i j => arcsineTailCovariance d depth r (s i) (s j)) u≤
          (gramConstant*(walshSpectralTail (arcsineProfile d depth) r+
            Real.sqrt ((n:ℝ)*(d:ℝ)*(∑ S∈Finset.univ.filter
              (fun S : Finset (Fin d)=>r≤S.card),walshCoefficients (arcsineProfile d depth) S^2))+
            (n:ℝ)*ell))*(∑ i,u i^2)) := by
  let w : Finset (Fin d) → ℝ := fun S =>
    if r≤S.card then walshCoefficients (arcsineProfile d depth) S else 0
  let tau := walshSpectralTail (arcsineProfile d depth) r
  let s2 := ∑ S∈Finset.univ.filter (fun S : Finset (Fin d)=>r≤S.card),
    walshCoefficients (arcsineProfile d depth) S^2
  let H := tau+Real.sqrt ((n:ℝ)*(d:ℝ)*s2)+(n:ℝ)*ell
  let t := 32*(gramMomentConstant+1)*H
  have hw (S : Finset (Fin d)) : 0≤w S := by
    dsimp [w]; split_ifs; exact arcsineProfile_coefficient_nonneg d depth S; exact le_rfl
  have hwm (S : Finset (Fin d)) : w S≤ell := by
    dsimp [w]; split_ifs with h; exact hmax S h; exact hell
  have hfar (x y : ClippingCube d) (hxy : far x y) :
      |walshKernel w x y|≤neuralTailCoherence d r := by
    obtain ⟨h₁,h₂⟩ := far_real_bounds hxy
    exact NeuralTailCoherence.arcsineTailCovariance_far depth hr hdim x y h₁ h₂
  have htrace : (∑ S,w S)=tau := by simp only [w,tau,walshSpectralTail,Finset.sum_filter]
  have hs2 : (∑ S,w S^2)=s2 := by
    dsimp [s2]; rw [Finset.sum_filter]
    apply Finset.sum_congr rfl
    intro S _
    dsimp only [w]
    split_ifs <;> simp
  have hs20 : 0≤s2 := Finset.sum_nonneg (fun _ _=>sq_nonneg _)
  have hH : 0<H := by dsimp [H]; positivity
  have hC := gramMomentConstant_nonneg
  have ht : 0<t := by dsimp [t]; positivity
  have hmoment := tailGramBudget_le_dimension_square (by omega : 0<d)
    (neuralTailCoherence d r) ell tau s2 (neuralTailCoherence_pos d r).le hell htau.le hs20 hcoh hnear
  have hratio : tailGramBudget d n (neuralTailCoherence d r) ell tau s2/t^2≤1/32 := by
    apply (div_le_iff₀ (sq_pos_of_pos ht)).mpr
    apply hmoment.trans
    change gramMomentConstant*H^2≤1/32*(32*(gramMomentConstant+1)*H)^2
    have hnum : gramMomentConstant≤32*(gramMomentConstant+1)^2 := by nlinarith only [hC,sq_nonneg gramMomentConstant]
    have hh := mul_le_mul_of_nonneg_right hnum (sq_nonneg H)
    nlinarith only [hh]
  have hp := far_walsh_gram_probability w hw (neuralTailCoherence d r) ell t
    (neuralTailCoherence_pos d r) hell ht hwm hfar (by omega) hn hnm
  rw [htrace,hs2] at hp
  have hbad : ConcreteModel.sampleProbability (ConcreteModel.uniformLaw d) n
      (fun s => ∃ u : Fin n → ℝ,t*(∑i,u i^2)<
        |finiteQuadratic (fun i j=>walshKernel w (s i) (s j)) u-tau*(∑i,u i^2)|)≤1/16 := by
    linarith only [hp,hratio,herrors]
  have hgood := ConcreteModel.sampleProbability_compl (ConcreteModel.uniformLaw d) n
    (fun s => ∃ u : Fin n → ℝ,t*(∑i,u i^2)<
      |finiteQuadratic (fun i j=>walshKernel w (s i) (s j)) u-tau*(∑i,u i^2)|)
  have hprob : 15/16≤ConcreteModel.sampleProbability (ConcreteModel.uniformLaw d) n
    (fun s => ¬∃ u : Fin n → ℝ,t*(∑i,u i^2)<
      |finiteQuadratic (fun i j=>walshKernel w (s i) (s j)) u-tau*(∑i,u i^2)|) := by linarith
  apply hprob.trans
  apply ConcreteModel.sampleProbability_mono
  intro s hs u
  have hb : |finiteQuadratic (fun i j=>walshKernel w (s i) (s j)) u-tau*(∑i,u i^2)|≤t*(∑i,u i^2) :=
    le_of_not_gt (fun hu=>hs ⟨u,hu⟩)
  have htauH : tau≤H := by dsimp [H]; have := Real.sqrt_nonneg ((n:ℝ)*(d:ℝ)*s2); have := mul_nonneg (Nat.cast_nonneg n (α:=ℝ)) hell; linarith
  have hu0 : 0≤∑i,u i^2 := Finset.sum_nonneg (fun _ _=>sq_nonneg _)
  have hu := le_abs_self (finiteQuadratic (fun i j=>walshKernel w (s i) (s j)) u-tau*(∑i,u i^2))
  change finiteQuadratic (fun i j=>walshKernel w (s i) (s j)) u≤gramConstant*H*(∑i,u i^2)
  have hmult := mul_le_mul_of_nonneg_right htauH hu0
  dsimp only [t] at hb
  unfold gramConstant
  nlinarith only [hb,hu,hmult]


/-- Uniform actual sampled tail-Gram control throughout a fixed exponential
sample range. All probability, masking, coherence, and collision estimates
are discharged; only the actual tail's scalar eigenvalue upper bound is
provided by the caller. -/
theorem eventually_arcsine_tail_gram_good (depth : ℕ) (hdepth : 1≤depth) :
    ∀ᶠ d : ℕ in Filter.atTop,∀ r n : ℕ,0<r →131072*r≤d →
      SmallSampleCutoff.logDimension d^2/2≤(r:ℝ) →4≤n →
      (n:ℝ)≤Real.exp ((d:ℝ)/128) →
      ∀ ell : ℝ,0≤ell →
      (∀ S : Finset (Fin d),r≤S.card →walshCoefficients (arcsineProfile d depth) S≤ell) →
      15/16≤ConcreteModel.sampleProbability (ConcreteModel.uniformLaw d) n
        (fun s => ∀ u : Fin n → ℝ,
          finiteQuadratic (fun i j=>arcsineTailCovariance d depth r (s i) (s j)) u≤
            (gramConstant*(walshSpectralTail (arcsineProfile d depth) r+
              Real.sqrt ((n:ℝ)*(d:ℝ)*(∑ S∈Finset.univ.filter
                (fun S : Finset (Fin d)=>r≤S.card),walshCoefficients (arcsineProfile d depth) S^2))+
              (n:ℝ)*ell))*(∑ i,u i^2)) := by
  filter_upwards [TailCoherenceAsymptotics.eventually_dimension_radius_le_trace depth hdepth,
    CubeFarPairs.eventually_near_and_collision_small] with d hcoh hnear r n hr hdim hlog hn hnmax ell hell hmax
  obtain ⟨hnm,hnq,herrors⟩ := hnear n hn hnmax
  have hlo := TailCoherenceAsymptotics.spectral_tail_inverse_dimension_lower depth d r hdepth hr hdim
  have htau : 0<walshSpectralTail (arcsineProfile d depth) r := lt_of_lt_of_le (by positivity) hlo
  exact arcsine_tail_gram_good_probability_of_scalars depth hr (by omega) hn hnm ell hell hmax htau
    (hcoh r hr hdim hlog) hnq herrors

end NeuralGeneralization.RandomRestriction
