import NeuralGeneralization.ParameterSensitivityMain
import NeuralGeneralization.EuclideanPackingBound
import NeuralGeneralization.WeakMarginRepresentatives

/-! Literal Euclidean packing bound for the infimal strict-margin norm ball.
The representatives have weak margins; attainment of strict margins is not
assumed. The dimension and sensitivity constant are exactly the paper's. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
namespace NeuralGeneralization.ParameterSensitivity
open ConcreteModel

def euclideanParameter {d N r : ℕ} (w : Weights d N r) : EuclideanSpace ℝ (WeightIndex d N r) :=
  WithLp.toLp 2 (whiten w)

theorem euclideanParameter_norm_sq {d N r : ℕ} (hd : 0<d) (hN : 0<N) (w : Weights d N r) :
    ‖euclideanParameter w‖^2=weightedSquaredNorm w := by
  rw [EuclideanSpace.real_norm_sq_eq]
  have he := weightedSquaredNorm_unwhiten hd hN (whiten w)
  rw [unwhiten_whiten hd hN] at he
  exact he.symm

theorem euclideanParameter_sub {d N r : ℕ} (w v : Weights d N r) :
    euclideanParameter (w-v)=euclideanParameter w-euclideanParameter v := by
  ext i
  simp [euclideanParameter,whiten,sub_div]

def normBallFunctions (d N r : ℕ) (φ : ℝ→ℝ) (R : ℝ) : Finset (BooleanFunction d) := by
  classical
  exact Finset.univ.filter fun f => (marginEvent (N:=N) (r:=r) φ (1/2) f).Nonempty ∧
    2*networkEnergy (N:=N) (r:=r) φ (1/2) f≤R^2

/-- The printed packing proposition, including the exact parameter count. -/
theorem norm_ball_packing {d N r : ℕ} (hd : 0<d) (hN : 0<N)
    (φ : ℝ→ℝ) (hφ : admissibleActivation φ) {R : ℝ} (hR : 0≤R) :
    ((normBallFunctions d N r φ R).card:ℝ)≤
      (1+2*R*Real.sqrt (lambdaSquared d r R))^(N*(d+1)+r*N^2+N) := by
  classical
  let F := normBallFunctions d N r φ R
  have hw (f : F) : ∃ w : Weights d N r,weightedSquaredNorm w≤R^2 ∧
      ∀ x,(1/2:ℝ)≤labelReal (f.val x)*networkOutput φ w x := by
    have hf := (Finset.mem_filter.mp f.property).2
    exact exists_weak_margin_representative hd hN (admissibleActivation_continuous hφ) f.val hf.1 hf.2
  choose w hw hm using hw
  let u : F→EuclideanSpace ℝ (WeightIndex d N r) := fun f => euclideanParameter (w f)
  let Λ := Real.sqrt (lambdaSquared d r R)
  have hΛ : 0<Λ := Real.sqrt_pos.mpr (lambdaSquared_pos d r R)
  have hbound (f : F) : ‖u f‖≤R := by
    apply (sq_le_sq₀ (norm_nonneg _) hR).mp
    rw [show ‖u f‖^2=weightedSquaredNorm (w f) from euclideanParameter_norm_sq hd hN _]
    exact hw f
  have hsep (f g : F) (hfg : f≠g) : 1/Λ≤‖u f-u g‖ := by
    have hne : f.val≠g.val := fun he => hfg (Subtype.ext he)
    obtain ⟨x,hx⟩ := not_forall.mp (show ¬∀ x,f.val x=g.val x from fun h => hne (funext h))
    have hf := hm f x
    have hg := hm g x
    have hgap : 1≤|networkOutput φ (w f) x-networkOutput φ (w g) x| := by
      cases hfx : f.val x <;> cases hgx : g.val x <;>
        simp only [hfx,hgx,labelReal_false,labelReal_true,neg_one_mul,one_mul] at hf hg hx
      · exact (hx trivial).elim
      · have h := neg_le_abs (networkOutput φ (w f) x-networkOutput φ (w g) x)
        linarith
      · have h := le_abs_self (networkOutput φ (w f) x-networkOutput φ (w g) x)
        linarith
      · exact (hx trivial).elim
    have hp := parameter_sensitivity hd hN φ hφ (w f) (w g) (hw f) x
    have he : Real.sqrt (weightedSquaredNorm (w f-w g))=‖u f-u g‖ := by
      rw [← euclideanParameter_norm_sq hd hN,euclideanParameter_sub,Real.sqrt_sq (norm_nonneg _)]
    rw [he] at hp
    exact (div_le_iff₀ hΛ).mpr (by simpa [mul_comm] using hgap.trans hp)
  have hinj : Function.Injective u := by
    intro f g he
    by_contra hfg
    have hs := hsep f g hfg
    rw [he,sub_self,norm_zero] at hs
    exact (not_le_of_gt (one_div_pos.mpr hΛ)) hs
  let s := Finset.univ.image u
  have hs := euclidean_packing_bound s hR hΛ
    (by intro c hc; obtain ⟨f,_,rfl⟩ := Finset.mem_image.mp hc; exact hbound f)
    (by
      intro c hc d hd hcd
      obtain ⟨f,_,rfl⟩ := Finset.mem_image.mp hc
      obtain ⟨g,_,rfl⟩ := Finset.mem_image.mp hd
      exact hsep f g (fun he => hcd (congrArg u he)))
  have hcard : s.card=F.card := by
    rw [Finset.card_image_of_injective _ hinj]
    simp
  rw [hcard] at hs
  simpa only [F,Λ,WeightIndex,finrank_euclideanSpace,Fintype.card_sum,Fintype.card_prod,
    Fintype.card_fin,← pow_two,mul_assoc,add_assoc] using hs

#print axioms norm_ball_packing
end NeuralGeneralization.ParameterSensitivity
