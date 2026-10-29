import MarginPathExtraction
import SharpNetworkRepairErrorBound
noncomputable section
set_option maxHeartbeats 800000
open MeasureTheory InformationTheory
open scoped BigOperators ENNReal InnerProductSpace
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.ConcreteModel NeuralGeneralization.GaussianFieldTilt
open NeuralGeneralization.CovarianceDualLift NeuralGeneralization.ActualBoundedDual
open NeuralGeneralization.BoundedDual

def sharpPathRepairEpsilon (d r : ℕ) (A τ U : ℝ) : ℝ :=
  repairPrecision (r+1) (1+Real.sqrt (2*U))
    (Real.sqrt (2*U)) (pathRepairRho A τ)/(Fintype.card (Cube d):ℝ)^4

lemma sharpPathRepairEpsilon_pos (d r : ℕ) {A τ U : ℝ} (hA : 0≤A) (hτ : 0<τ) :
    0<sharpPathRepairEpsilon d r A τ U := by
  have hm : (0:ℝ)<Fintype.card (Cube d) := by exact_mod_cast Fintype.card_pos
  have hρ := (pathRepairRho_bounds hA hτ).1
  apply div_pos
  · exact repairPrecision_pos _ (by positivity) (Real.sqrt_nonneg _) hρ
  · positivity

lemma sharpPathRepair_precision_bound (d r : ℕ) {A τ U : ℝ} (hA : 0≤A) (hτ : 0<τ) :
    Real.sqrt (2*U)*((r+1:ℕ)*(Fintype.card (Cube d):ℝ)^4*sharpPathRepairEpsilon d r A τ U*
      (2+Real.sqrt (2*U))^(r+1))≤pathRepairRho A τ := by
  have hm : (0:ℝ)<Fintype.card (Cube d) := by exact_mod_cast Fintype.card_pos
  have hB : 0<A+τ := by linarith
  have hρ := (pathRepairRho_bounds hA hτ).1
  have hW := Real.sqrt_nonneg (2*U)
  have hpower : 0<(2+Real.sqrt (2*U))^(r+1) := by positivity
  unfold sharpPathRepairEpsilon repairPrecision
  rw [show 1+(1+Real.sqrt (2*U))=2+Real.sqrt (2*U) by ring]
  field_simp
  nlinarith [mul_nonneg hW hρ.le]

/-- A concrete approximate certificate yields a genuine controlled path for
the same Boolean sign function, with at most one further entropy-slack cost. -/
theorem certificate_to_margin_path_sharp {d N r : ℕ} (hd : 0<d) (hN : 0<N)
    {σ A τ U : ℝ} (hσ : 0<σ) (hscale : Real.sqrt N*σ≤1)
    (hA : 0≤A) (hτ : 0<τ)
    (hNorm : (Real.sqrt N*σ)^2*(A+τ)≤U) (w : Weights d N r) (f : BooleanFunction d)
    (hmargin : w∈marginEvent Real.tanh (1/2) f)
    (star : Fin (r+1)→Cube d × Cube d→ℝ) (G : ℝ)
    (hstar : ∀j,entryL1 (star j)≤G)
    (hbudget : (∑j,networkCertificateCost σ w star j)+projectedReadoutSquared σ w/(2*N)≤A+τ)
    (hdefect : ∀j,maxAbs (hiddenMoments d N σ r w j-
      mean (hiddenReferences d N σ r w j) (features Real.tanh) (star j))≤
        (sharpPathRepairEpsilon d r A τ U)^2) :
    ∃ P : ControlledMarginPath d (r+1) (Real.sqrt N*σ) f,P.action≤A+2*τ := by
  have hU : 0≤U := le_trans (mul_nonneg (sq_nonneg _) (by linarith)) hNorm
  let ε := sharpPathRepairEpsilon d r A τ U
  let ρ := pathRepairRho A τ
  let B := A+τ
  have hε : 0<ε := sharpPathRepairEpsilon_pos d r hA hτ
  have hρ := pathRepairRho_bounds hA hτ
  have hρ0 : 0<ρ := hρ.1
  have hρ8 : ρ≤1/8 := by dsimp [ρ]; linarith [hρ.2]
  have hB : 0<B := by dsimp [B]; linarith
  have hn : (0:ℝ)<N := by exact_mod_cast hN
  have ht : 0<Real.sqrt N*σ := mul_pos (Real.sqrt_pos.mpr hn) hσ
  have hP0 : 0≤projectedReadoutSquared σ w := sq_nonneg _
  have hR0 : 0≤projectedReadoutSquared σ w/(2*N) := div_nonneg hP0 (by positivity)
  have hD0 : 0≤∑j,networkCertificateCost σ w star j :=
    Finset.sum_nonneg (fun _ _=>ENNReal.toReal_nonneg)
  have hD : (∑j,networkCertificateCost σ w star j)≤B := by dsimp [B]; linarith
  have hR : projectedReadoutSquared σ w/(2*N)≤B := by dsimp [B]; linarith
  obtain ⟨C,D,Q,hzero,hgram,hprob,hfinite,hcost,hrec,herr,hterminal⟩ :=
    actual_network_path_repair_sharp hd hN hσ w star G ε hε.le hstar hdefect
  have he0 := sharpNetworkRepairError_nonneg σ w star ε hε.le (r+1)
  have hDn : (Real.sqrt N*σ)^2*(∑j,networkCertificateCost σ w star j)≤U :=
    (mul_le_mul_of_nonneg_left hD (sq_nonneg _)).trans hNorm
  have he := sharpNetworkRepairError_bound σ w star ε U hε.le hU
    (by rw [abs_of_pos ht]; exact hscale) hDn
  have heW : Real.sqrt (2*U)*sharpNetworkRepairError σ w star ε (r+1)≤ρ := by
    apply (mul_le_mul_of_nonneg_left he (Real.sqrt_nonneg _)).trans
    simpa only [one_mul,mul_assoc] using sharpPathRepair_precision_bound d r hA hτ
  obtain ⟨b,hb,hout,herrb⟩ := actual_network_readout_transport hN hσ w
    (C (r+1)) (D (r+1)) hterminal (sharpNetworkRepairError σ w star ε (r+1))
      (herr (r+1) le_rfl)
  have hP : σ^2*projectedReadoutSquared σ w≤2*U := by
    have hh := (div_le_iff₀ (show (0:ℝ)<2*N by positivity)).mp hR
    have hnrm : (N:ℝ)*σ^2*B≤U := by
      simpa only [mul_pow,Real.sq_sqrt hn.le] using hNorm
    calc
      _ ≤ σ^2*(B*(2*N)) := mul_le_mul_of_nonneg_left hh (sq_nonneg _)
      _ = 2*((N:ℝ)*σ^2*B) := by ring
      _ ≤ _ := by linarith
  have hpred (x : Cube d) : |inner ℝ b (D (r+1) x)-networkOutput Real.tanh w x|≤ρ := by
    exact (herrb x).trans ((mul_le_mul_of_nonneg_right (Real.sqrt_le_sqrt hP) he0).trans heW)
  let lam := 1/(1-2*ρ)
  have hden : 0<1-2*ρ := by linarith
  have hlam : 0<lam := by dsimp [lam]; positivity
  have hlamsq : lam^2≤1+16*ρ := half_margin_scaling_cost ρ hρ0.le hρ8
  have hmargin' : ∀x,(1:ℝ)/2<labelReal (f x)*inner ℝ (lam • b) (D (r+1) x) := by
    intro x
    have hm := hmargin x
    have he := abs_le.mp (hpred x)
    have hlow : 1/2-ρ<labelReal (f x)*inner ℝ b (D (r+1) x) := by
      cases hf : f x <;> simp only [hf,labelReal] at hm ⊢ <;> norm_num at hm ⊢ <;> linarith
    have hh := mul_lt_mul_of_pos_left hlow hlam
    have hid : lam*(1/2-ρ)=1/2 := by dsimp [lam]; field_simp
    rw [hid] at hh
    rw [real_inner_smul_left]
    nlinarith
  have hbRate : ‖b‖^2/(2*(Real.sqrt N*σ)^2)≤projectedReadoutSquared σ w/(2*N) := by
    rw [mul_pow,Real.sq_sqrt hn.le]
    exact transported_readout_rate hN hσ b _ hb
  have hcRate : ‖lam • b‖^2/(2*(Real.sqrt N*σ)^2)≤
      (1+16*ρ)*(projectedReadoutSquared σ w/(2*N)) := by
    rw [norm_smul,Real.norm_eq_abs,mul_pow,sq_abs,mul_div_assoc]
    exact (mul_le_mul_of_nonneg_left hbRate (sq_nonneg lam)).trans
      (mul_le_mul_of_nonneg_right hlamsq hR0)
  let P : ControlledMarginPath d (r+1) (Real.sqrt N*σ) f := {
    scale_positive := ht
    scale_le_one := hscale
    feature := D
    law := Q
    readout := lam • b
    initial := by
      intro x y
      rw [←hzero x,←hzero y]
      have hh := hgram 0 (by omega) x y
      change inner ℝ (C 0 x) (C 0 y)=
        inner ℝ (normalizedInputFeature d x) (normalizedInputFeature d y) at hh
      exact hh
    probability := hprob
    finiteKL := hfinite
    recursion := hrec
    margin := hmargin' }
  refine ⟨P,?_⟩
  have hsums : (∑j : Fin (r+1),(klDiv (Q j)
      (fieldLaw (scaledFeatureCoefficients (Real.sqrt N*σ) (D j)))).toReal)≤
        ∑j,networkCertificateCost σ w star j :=
    Finset.sum_le_sum (fun j _=>hcost j j.isLt)
  have haction : P.action≤(1+16*ρ)*B := by
    unfold ControlledMarginPath.action
    dsimp only [P]
    have hh := mul_le_mul_of_nonneg_left hbudget (show 0≤1+16*ρ by positivity)
    have hz : 0≤16*ρ*(∑j,networkCertificateCost σ w star j) := by positivity
    dsimp [B] at *
    nlinarith
  apply haction.trans_eq
  dsimp [ρ,pathRepairRho,B]
  field_simp
  ring

/-- Explicit width sufficient for a genuine, strictly margin-separated
population path. Its logarithmic precision dependence is polynomial in depth. -/
def sharpMarginPathWidth (d r : ℕ) (A τ U : ℝ) : ℝ :=
  certificateWidth d r A τ ((sharpPathRepairEpsilon d r A τ U)^2)

/-- Every sufficiently positive original parameter event contains a network
whose sign function admits a genuine low-action controlled Gaussian path. -/
theorem event_contains_margin_paths_sharp {d N r : ℕ} (hd : 0<d) (hN : 0<N)
    {σ A τ U : ℝ} (hσ : 0<σ) (hscale : Real.sqrt N*σ≤1)
    (hA : 0≤A) (hτ : 0<τ)
    (hNorm : (Real.sqrt N*σ)^2*(A+τ)≤U) (hwidth : sharpMarginPathWidth d r A τ U≤N)
    (E : Set (Weights d N r))
    (hMass : Real.exp (-(N:ℝ)*A)≤(smallPrior d N r σ).real E) :
    ∃w∈E,∀f : BooleanFunction d,w∈marginEvent Real.tanh (1/2) f →
      ∃P : ControlledMarginPath d (r+1) (Real.sqrt N*σ) f,P.action≤A+2*τ := by
  have hε := sharpPathRepairEpsilon_pos d r (U := U) hA hτ
  obtain ⟨w,hw,star,hstar,_hprob,_hfinite,hbudget,hdefect⟩ :=
    finite_width_entropy_certificate d N r hd hN σ A τ
      ((sharpPathRepairEpsilon d r A τ U)^2) hσ hA hτ (sq_pos_of_pos hε) hwidth E hMass
  refine ⟨w,hw,?_⟩
  intro f hm
  exact certificate_to_margin_path_sharp hd hN hσ hscale hA hτ hNorm w f hm star _ hstar hbudget hdefect

attribute [local instance] Classical.propDecidable

/-- Failure of an actual posterior circuit ceiling produces a genuine
controlled path for a sign function outside that ceiling. Every probability,
Gaussian law, input and output margin in this theorem is concrete. -/
theorem posterior_failure_contains_margin_path_sharp {d N r n : ℕ}
    (hd : 0<d) (hN : 0<N) {σ A τ U : ℝ} (hσ : 0<σ)
    (hscale : Real.sqrt N*σ≤1) (hA : 0≤A) (hτ : 0<τ)
    (f : BooleanFunction d) (sample : Fin n→Cube d) (B : Set (BooleanFunction d))
    (hZ : Real.exp (-(N:ℝ)*A)≤posteriorDenominator Real.tanh (1/2) (smallPrior d N r σ) f sample)
    (hbad : (∑g : BooleanFunction d,if g∈B then
      networkPosterior Real.tanh (1/2) (smallPrior d N r σ) f sample g else 0)<5/6)
    (hNorm : (Real.sqrt N*σ)^2*(A+Real.log 6/N+τ)≤U)
    (hwidth : sharpMarginPathWidth d r (A+Real.log 6/N) τ U≤N) :
    ∃g : BooleanFunction d,g∉B ∧ consistent f sample g ∧
      ∃P : ControlledMarginPath d (r+1) (Real.sqrt N*σ) g,
        P.action≤A+Real.log 6/N+2*τ := by
  have hraw := posterior_ceiling_failure_exp_mass tanh_continuous (by norm_num : (0:ℝ)≤1/2)
    (smallPrior d N r σ) f sample B hN A hZ hbad
  have hA' : 0≤A+Real.log 6/N := by
    have hh : 0≤Real.log (6:ℝ) := Real.log_nonneg (by norm_num)
    positivity
  obtain ⟨w,hw,hpaths⟩ := event_contains_margin_paths_sharp hd hN hσ hscale hA' hτ hNorm hwidth
    (compatibleClassEvent Real.tanh (1/2) f sample Bᶜ) hraw
  obtain ⟨g,hg,hc,hm⟩ := (mem_compatibleClassEvent Real.tanh (1/2) f sample Bᶜ w).mp hw
  exact ⟨g,hg,hc,hpaths g hm⟩

#print axioms certificate_to_margin_path_sharp
#print axioms event_contains_margin_paths_sharp
#print axioms posterior_failure_contains_margin_path_sharp
end ConditionalNonpolynomial.Analytic
