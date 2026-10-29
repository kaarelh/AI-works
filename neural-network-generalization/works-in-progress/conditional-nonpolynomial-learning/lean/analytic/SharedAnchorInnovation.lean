import AnchorReplacementProduct
import GaussianCouplingTruncation

/-! A Gaussian innovation gives a variance-scaled shared-anchor coupling.
All KL charges are the actual discarded conditional entropy. -/
noncomputable section
set_option maxHeartbeats 2000000
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory InformationTheory Set
open scoped ENNReal NNReal
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.RobustEntropy
variable {A : Type*} [MeasurableSpace A] [StandardBorelSpace A] [Nonempty A]

theorem sharedAnchorCoupling_gaussian_innovation
    (Q G : Measure (A × ℝ)) [IsProbabilityMeasure Q] [IsProbabilityMeasure G]
    (hKL : klDiv Q G≠∞) (m : A → ℝ) (hm : Measurable m) {σ δ : ℝ}
    (hσ : 0<σ) (hδ : 0<δ)
    (hprod : G.map (fun p => (p.1,(p.2-m p.1)/σ))=G.fst.prod (gaussianReal 0 1))
    (hgap : (klDiv Q G).toReal-(klDiv Q.fst G.fst).toReal≤δ) :
    (∫p,(Real.tanh p.2.1-Real.tanh p.2.2)^2 ∂sharedAnchorCoupling Q G)≤
      σ^2*(520*Real.sqrt (Real.sqrt δ)+16*δ) := by
  let F : A × ℝ → A × ℝ := fun p => (p.1,(p.2-m p.1)/σ)
  let I : A × ℝ → ℝ := fun p => (p.2-m p.1)/σ
  have hF : Measurable F := by dsimp [F]; fun_prop
  have hI : Measurable I := by dsimp [I]; fun_prop
  let R := anchorReplacement Q G
  let M := sharedAnchorCoupling Q G
  let Y : A × (ℝ × ℝ) → ℝ := fun p => I (p.1,p.2.1)
  let Z : A × (ℝ × ℝ) → ℝ := fun p => I (p.1,p.2.2)
  let b : A × (ℝ × ℝ) → ℝ := fun p => m p.1
  have hY : Measurable Y := hI.comp (by fun_prop)
  have hZ : Measurable Z := hI.comp (by fun_prop)
  have hb : Measurable b := hm.comp measurable_fst
  have hRM : R.map F=Q.fst.prod (gaussianReal 0 1) :=
    anchorReplacement_product_map Q G hKL (gaussianReal 0 1) F hF (fun _ => rfl) hprod
  have hRI : R.map I=gaussianReal 0 1 := by
    calc
      _ = (R.map F).snd := by
        unfold Measure.snd
        rw [Measure.map_map measurable_snd hF]
        rfl
      _ = (Q.fst.prod (gaussianReal 0 1)).snd := by rw [hRM]
      _ = _ := by simp
  have hMY : M.map Y=Q.map I := by
    calc
      _ = (M.map (fun p => (p.1,p.2.1))).map I :=
        (Measure.map_map hI (by fun_prop)).symm
      _ = _ := by rw [sharedAnchorCoupling_left]
  have hMZ : M.map Z=gaussianReal 0 1 := by
    calc
      _ = (M.map (fun p => (p.1,p.2.2))).map I :=
        (Measure.map_map hI (by fun_prop)).symm
      _ = R.map I := by rw [sharedAnchorCoupling_right]
      _ = _ := hRI
  have hcond := anchorReplacement_conditional_finite Q G hKL
  have hd := klDiv_map_le Q R hI
  rw [hRI] at hd
  have hf : klDiv (M.map Y) (gaussianReal 0 1)≠∞ := by
    rw [hMY]
    exact ne_top_of_le_ne_top hcond hd
  have hc : (klDiv (M.map Y) (gaussianReal 0 1)).toReal≤δ := by
    rw [hMY]
    have hh := ENNReal.toReal_mono hcond hd
    rw [anchorReplacement_conditional_toReal Q G hKL] at hh
    exact hh.trans hgap
  have hmis : M.real {p | Y p≠Z p}≤2*Real.sqrt δ := by
    have hs : 0<Real.sqrt δ := Real.sqrt_pos.mpr hδ
    have hh := sharedAnchorCoupling_mismatch Q G hs
    have hfin : ENNReal.ofReal (1/Real.sqrt δ)*klDiv Q R+ENNReal.ofReal (Real.sqrt δ)≠∞ := by finiteness
    have hhr := ENNReal.toReal_mono hfin hh
    rw [ENNReal.toReal_add (by finiteness) ENNReal.ofReal_ne_top,ENNReal.toReal_mul,
      ENNReal.toReal_ofReal (one_div_pos.mpr hs).le,ENNReal.toReal_ofReal hs.le,
      anchorReplacement_conditional_toReal Q G hKL] at hhr
    have hdiv : ((klDiv Q G).toReal-(klDiv Q.fst G.fst).toReal)/Real.sqrt δ≤Real.sqrt δ := by
      apply (div_le_iff₀ hs).mpr
      rw [← sq,Real.sq_sqrt hδ.le]
      exact hgap
    have heq : {p | Y p≠Z p}={p : A × (ℝ × ℝ) | p.2.1≠p.2.2} := by
      ext p
      simp only [Set.mem_setOf_eq,Y,Z,I,ne_eq,div_left_inj' hσ.ne',sub_left_inj]
    rw [heq]
    change (sharedAnchorCoupling Q G {p | p.2.1≠p.2.2}).toReal≤_
    have hid : 1/Real.sqrt δ*((klDiv Q G).toReal-(klDiv Q.fst G.fst).toReal)=
        ((klDiv Q G).toReal-(klDiv Q.fst G.fst).toReal)/Real.sqrt δ := by ring
    rw [hid] at hhr
    linarith only [hhr,hdiv]
  have hh := gaussian_coupling_tanh_polynomial M Y Z b hY hZ hb hf hMZ hδ hc hmis σ
  have hleft (p : A × (ℝ × ℝ)) : b p+σ*Y p=p.2.1 := by dsimp [b,Y,I]; field_simp; ring
  have hright (p : A × (ℝ × ℝ)) : b p+σ*Z p=p.2.2 := by dsimp [b,Z,I]; field_simp; ring
  simp_rw [hleft,hright] at hh
  exact hh


theorem sharedAnchorCoupling_deterministic_error
    (Q G : Measure (A × ℝ)) [IsProbabilityMeasure Q] [IsProbabilityMeasure G]
    (hKL : klDiv Q G≠∞) (m : A → ℝ) (hm : Measurable m)
    (hdet : ∀ᵐp ∂G,p.2=m p.1) :
    (∫p,(Real.tanh p.2.1-Real.tanh p.2.2)^2 ∂sharedAnchorCoupling Q G)=0 := by
  have hd := anchorReplacement_ae_of_reference Q G hKL (fun p => p.2=m p.1) hdet
  have hset : MeasurableSet {p : A × ℝ | p.2=m p.1} :=
    measurableSet_eq_fun measurable_snd (hm.comp measurable_fst)
  have hl : ∀ᵐp ∂sharedAnchorCoupling Q G,p.2.1=m p.1 := by
    have hh := hd.1
    rw [← sharedAnchorCoupling_left Q G] at hh
    exact (ae_map_iff (by fun_prop) hset).mp hh
  have hr : ∀ᵐp ∂sharedAnchorCoupling Q G,p.2.2=m p.1 := by
    have hh := hd.2
    rw [← sharedAnchorCoupling_right Q G] at hh
    exact (ae_map_iff (by fun_prop) hset).mp hh
  calc
    _ = ∫_p, (0:ℝ) ∂sharedAnchorCoupling Q G := by
      apply integral_congr_ae
      filter_upwards [hl,hr] with p hp hq
      rw [hp,hq,sub_self]
      norm_num
    _ = 0 := integral_zero _ _

#print axioms sharedAnchorCoupling_gaussian_innovation
#print axioms sharedAnchorCoupling_deterministic_error
end ConditionalNonpolynomial.Analytic
