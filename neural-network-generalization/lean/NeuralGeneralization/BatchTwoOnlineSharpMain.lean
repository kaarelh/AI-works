import NeuralGeneralization.BatchTwoOnlineMain
import NeuralGeneralization.BatchTwoOnlineSharpTeacher
import NeuralGeneralization.BatchTwoOnlineSharpWidth
import NeuralGeneralization.BatchTwoOnlineSharpCount

/-! The boxed strong-prior online theorem with the manuscript's exact F_L
and B_L budgets, for both protocols and actual posterior-sampled mistakes. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators ENNReal Topology
namespace NeuralGeneralization.BatchTwoOnlineSharp
open ConcreteModel CompressionSampling BatchTwoOnline MeasureTheory Filter

def normCapacity (d r : ℕ) (J : ℝ) : ℝ := normLogCount d (normWidth d r (J+1)) r

theorem normLogCount_nonneg (d u r : ℕ) : 0≤normLogCount d u r := by
  unfold normLogCount
  apply mul_nonneg (by positivity)
  apply Real.log_nonneg
  have hh : 0≤16*((r:ℝ)+2)*u*max (u:ℝ) ((d:ℝ)+1)*((u:ℝ)*(u+1))^(r+1) := by positivity
  linarith

theorem normCapacity_nonneg (d r : ℕ) (J : ℝ) : 0≤normCapacity d r J :=
  normLogCount_nonneg d _ r

theorem norm_compression {d N r : ℕ} (hd : 1≤d) (hN : 0<N)
    {K : ℝ} (hK : 1≤K) (φ : ℝ→ℝ) (hφ : admissibleActivation φ)
    (f : BooleanFunction d) (w : Weights d N r) (hw : weightedSquaredNorm w≤K)
    (hmargin : w∈marginEvent φ (1/2) f) :
    ∃v : Weights d (normWidth d r K) r,v∈marginEvent φ (1/2) f ∧
      boundedWeights (normWidth d r K) v ∧ weightedSquaredNorm v≤9*K :=
  norm_compression_of_row_bound hd hN hK φ hφ f w hw hmargin
    (normWidth_pos hK) (normWidth_ge_energy d r K) (normWidth_row_bound hd hK)

theorem lowEnergyFunctions_compressed_paper {d C N r : ℕ}
    (hd : 1≤d) (φ : ℝ→ℝ) (hφ : admissibleActivation φ)
    (f : BooleanFunction d) (hf : realizesAtComplexity (r:=r) φ f C) (hCN : C≤N) :
    ∀g∈lowEnergyFunctions (N:=N) (r:=r) φ f,
      ∃w : Weights d (normWidth d r (teacherBudget d C r+1)) r,
        w∈marginEvent φ (1/2) g ∧ boundedWeights (normWidth d r (teacherBudget d C r+1)) w := by
  intro g hg
  obtain ⟨hne,he⟩:=(mem_lowEnergyFunctions φ f g).mp hg
  obtain ⟨w,hw,hcost⟩:=exists_nearoptimal_margin_network φ (1/2) g hne 1 zero_lt_one
  have ht:=realizesAtComplexity_paper_energy φ f hf hCN
  have hN:0<N:=lt_of_lt_of_le (Nat.succ_le_iff.mp hf.1) hCN
  have hK:1≤teacherBudget d C r+1:=by linarith [teacherBudget_nonneg d C r]
  obtain ⟨v,hv,hvb,_⟩:=norm_compression hd hN hK φ hφ g w (by linarith) hw
  exact ⟨v,hv,hvb⟩

theorem lowEnergyFunctions_card_paper {d C N r : ℕ}
    (hd : 1≤d) (φ : ℝ→ℝ) (hφ : admissibleActivation φ)
    (f : BooleanFunction d) (hf : realizesAtComplexity (r:=r) φ f C) (hCN : C≤N) :
    ((lowEnergyFunctions (N:=N) (r:=r) φ f).card:ℝ)≤
      Real.exp (normCapacity d r (teacherBudget d C r)) := by
  have hK:1≤teacherBudget d C r+1:=by linarith [teacherBudget_nonneg d C r]
  exact represented_class_card_paper _ (normWidth_pos hK) φ hφ
    (lowEnergyFunctions_compressed_paper hd φ hφ f hf hCN)

theorem strongPrior_randomOrder_paper {d C N r : ℕ}
    (hd : 1≤d) (φ : ℝ→ℝ) (hφ : admissibleActivation φ)
    (f : BooleanFunction d) (hf : realizesAtComplexity (r:=r) φ f C) (hCN : C≤N) :
    ∃σ₀ : ℝ,0<σ₀ ∧ ∀σ : ℝ,0<σ→σ<σ₀→
      NetworkRandomOrderBounds φ (1/2) (smallPrior d N r σ) f
        (normCapacity d r (teacherBudget d C r)) := by
  have hN:0<N:=lt_of_lt_of_le (Nat.succ_le_iff.mp hf.1) hCN
  have hcontinuous:=admissibleActivation_continuous hφ
  have hlim:=network_highEnergy_tail_ratio_tendsto_zero (by omega) hN hcontinuous f
    (margin_witness_at_larger_width φ f hf hCN)
  let β : ℝ:=1/Fintype.card (Cube d)
  have hβ:0<β:=by dsimp [β];positivity
  have he:=hlim.eventually (gt_mem_nhds hβ)
  obtain ⟨σ₀,hσ₀,hsub⟩:=mem_nhdsGT_iff_exists_Ioo_subset.mp he
  refine ⟨σ₀,hσ₀,?_⟩
  intro σ hσ hσlt
  have htail:=hsub ⟨hσ,hσlt⟩
  change (∑g∈Finset.univ \ lowEnergyFunctions (N:=N) (r:=r) φ f,
    functionMass φ (1/2) (smallPrior d N r σ) g)/functionMass φ (1/2) (smallPrior d N r σ) f<β at htail
  exact bounds_of_relevant_class Fintype.card_pos _ (functionMass_nonneg φ (1/2) _) _ f
    (fun _=>rfl) (small_functionMass_pos (by omega) hcontinuous f hf hCN hσ)
    (lowEnergyFunctions (N:=N) (r:=r) φ f) _ β (normCapacity_nonneg _ _ _) hβ.le
    (lowEnergyFunctions_card_paper hd φ hφ f hf hCN) htail.le

/-- L=r+2, h=F_L(d,B_L(d,C)), beta=2^(-d). This literal neural
endpoint includes expected risk, actual-draw expectation, both separate
high-probability bounds, and the entire infinite IID stream. -/
theorem strongPrior_online_paper {d C N r : ℕ}
    (hd : 1≤d) (φ : ℝ→ℝ) (hφ : admissibleActivation φ)
    (f : BooleanFunction d) (hf : realizesAtComplexity (r:=r) φ f C) (hCN : C≤N) :
    ∃σ₀ : ℝ,0<σ₀ ∧ ∀σ : ℝ,0<σ→σ<σ₀→
      NetworkOnlineBounds φ (1/2) (smallPrior d N r σ) f
        (normCapacity d r (teacherBudget d C r)) := by
  obtain ⟨σ₀,hσ₀,hbounds⟩:=strongPrior_randomOrder_paper hd φ hφ f hf hCN
  refine ⟨σ₀,hσ₀,fun σ hσ hσlt=>?_⟩
  exact network_online_of_randomOrder hd φ (1/2) _ f _ (normCapacity_nonneg _ _ _)
    (small_functionMass_pos (by omega) (admissibleActivation_continuous hφ) f hf hCN hσ)
    (hbounds σ hσ hσlt)

end NeuralGeneralization.BatchTwoOnlineSharp
