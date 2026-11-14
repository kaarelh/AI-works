import NeuralGeneralization.OnlineLowerTanhFiniteParityLocalCode
import NeuralGeneralization.OnlineLowerOrbitSynthesis

/-! Input-sign invariance of the literal normalized weighted-code objective. -/
noncomputable section
open scoped BigOperators Topology Classical
open Filter Set
namespace NeuralGeneralization.OnlineLowerTanh
open OnlineLower OnlineLowerRelu OnlineLowerGeometry ConcreteModel

lemma affineSupportCoefficient_eq_atomOutput {d : ℕ} (A : Finset (Fin d)) (z : Fin (d+1)→ℝ) :
    affineSupportCoefficient A z=walshCoefficients (atomOutput Real.tanh z) A := by
  unfold affineSupportCoefficient
  apply congrArg (fun F:Cube d→ℝ=>walshCoefficients F A)
  funext x
  simp only [atomOutput,Fin.sum_univ_succ,inputVector,Fin.cases_zero,Fin.cases_succ,mul_one]
  rfl

lemma affineEuclideanRadius_orbitIncoming {d : ℕ} (z : Fin (d+1)→ℝ) (t : Cube d) :
    affineEuclideanRadius (orbitIncoming z t)=affineEuclideanRadius z := by
  unfold affineEuclideanRadius
  congr 1
  rw [Fin.sum_univ_succ,Fin.sum_univ_succ]
  simp only [orbitIncoming,Fin.cases_zero,Fin.cases_succ,mul_pow]
  have hs (i : Fin d) : labelReal (t i)^2=1 := cubeCoordinateSign_sq (t i)
  simp_rw [hs,mul_one]

lemma affineSupportCoefficient_abs_orbitIncoming {d : ℕ}
    (A : Finset (Fin d)) (z : Fin (d+1)→ℝ) (t : Cube d) :
    |affineSupportCoefficient A (orbitIncoming z t)|=|affineSupportCoefficient A z| := by
  rw [affineSupportCoefficient_eq_atomOutput,affineSupportCoefficient_eq_atomOutput]
  have hf : atomOutput Real.tanh (orbitIncoming z t)=
      (fun x=>atomOutput Real.tanh z (cubeTranslation t x)) := funext (atomOutput_orbitIncoming Real.tanh z t)
  rw [hf,walshCoefficients_translation,abs_mul,walshCharacter_abs_one,one_mul]

lemma weightedAffineCodeRatio_orbitIncoming {d : ℕ} (C : Finset (Finset (Fin d)))
    (weight : Finset (Fin d)→ℝ) (z : Fin (d+1)→ℝ) (t : Cube d) :
    weightedAffineCodeRatio C weight (orbitIncoming z t)=weightedAffineCodeRatio C weight z := by
  unfold weightedAffineCodeRatio
  simp_rw [affineEuclideanRadius_orbitIncoming,affineSupportCoefficient_abs_orbitIncoming]

lemma orbitIncoming_involutive {d : ℕ} (t : Cube d) : Function.Involutive (fun z=>orbitIncoming z t) := by
  intro z
  funext i
  refine Fin.cases ?_ (fun j=>?_) i
  · simp [orbitIncoming]
  · simp only [orbitIncoming,Fin.cases_succ]
    have hs : labelReal (t j)^2=1 := cubeCoordinateSign_sq (t j)
    calc
      z j.succ*labelReal (t j)*labelReal (t j)=z j.succ*(labelReal (t j)^2) := by ring
      _ = z j.succ := by rw [hs,mul_one]

lemma continuous_orbitIncoming {d : ℕ} (t : Cube d) : Continuous (fun z=>orbitIncoming z t) := by
  apply continuous_pi
  intro i
  refine Fin.cases ?_ (fun j=>?_) i
  · change Continuous (fun z:Fin (d+1)→ℝ=>z 0)
    exact continuous_apply 0
  · change Continuous (fun z:Fin (d+1)→ℝ=>z j.succ*labelReal (t j))
    have hc : Continuous (fun z:Fin (d+1)→ℝ=>z j.succ) := continuous_apply j.succ
    exact hc.mul_const (labelReal (t j))

/-- Every strict local maximum transfers to each independently signed
physical incoming vector; the bias remains unchanged. -/
theorem weightedAffineCodeRatio_strict_local_maximum_signs {d : ℕ}
    (C : Finset (Finset (Fin d))) (weight : Finset (Fin d)→ℝ) (z₀ : Fin (d+1)→ℝ)
    (hmax : ∀ᶠ z in 𝓝 z₀,z≠z₀ → weightedAffineCodeRatio C weight z<weightedAffineCodeRatio C weight z₀)
    (t : Cube d) :
    ∀ᶠ z in 𝓝 (orbitIncoming z₀ t),z≠orbitIncoming z₀ t →
      weightedAffineCodeRatio C weight z<weightedAffineCodeRatio C weight (orbitIncoming z₀ t) := by
  have hcont : ContinuousAt (fun z=>orbitIncoming z t) (orbitIncoming z₀ t) :=
    (continuous_orbitIncoming t).continuousAt
  change Tendsto (fun z=>orbitIncoming z t) (𝓝 (orbitIncoming z₀ t))
    (𝓝 (orbitIncoming (orbitIncoming z₀ t) t)) at hcont
  have hi₀ : orbitIncoming (orbitIncoming z₀ t) t=z₀ := orbitIncoming_involutive t z₀
  rw [hi₀] at hcont
  have hh := hcont.eventually hmax
  filter_upwards [hh] with z hz hne
  have hneq : orbitIncoming z t≠z₀ := by
    intro he
    have hh := congrArg (fun v=>orbitIncoming v t) he
    have hi : orbitIncoming (orbitIncoming z t) t=z := orbitIncoming_involutive t z
    rw [hi] at hh
    exact hne hh
  have hm := hz hneq
  simpa only [weightedAffineCodeRatio_orbitIncoming] using hm

end NeuralGeneralization.OnlineLowerTanh
