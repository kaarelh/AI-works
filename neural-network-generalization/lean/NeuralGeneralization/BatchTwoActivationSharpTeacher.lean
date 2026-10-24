import NeuralGeneralization.BatchTwoOnlineSharpTeacher

/-! Exact B_* teacher-energy budget for the unified activation theorem.
The cloning identity uses no boundedness or homogeneity of the activation. -/
noncomputable section
namespace NeuralGeneralization.BatchTwoActivation
open ConcreteModel

def sharpTeacherBudget (d C r : ℕ):ℝ:=BatchTwoOnlineSharp.teacherBudget d C r

theorem sharpTeacherBudget_nonneg (d C r : ℕ):0≤sharpTeacherBudget d C r:=
  BatchTwoOnlineSharp.teacherBudget_nonneg d C r

theorem lowEnergyFunctions_sharp_norm_witness {d C N r : ℕ}
    (φ:ℝ→ℝ) (f g:BooleanFunction d) (hc:realizesAtComplexity (r:=r) φ f C)
    (hCN:C≤N) (hg:g∈lowEnergyFunctions (N:=N) (r:=r) φ f):
    ∃w:Weights d N r,w∈marginEvent φ (1/2) g ∧ weightedSquaredNorm w<sharpTeacherBudget d C r+1:=by
  obtain ⟨hgNonempty,hgEnergy⟩:=(mem_lowEnergyFunctions φ f g).mp hg
  obtain ⟨w,hw,hcost⟩:=exists_nearoptimal_margin_network φ (1/2) g hgNonempty 1 zero_lt_one
  refine ⟨w,hw,?_⟩
  have ht:=BatchTwoOnlineSharp.realizesAtComplexity_paper_energy φ f hc hCN
  change networkEnergy (N:=N) (r:=r) φ (1/2) f≤sharpTeacherBudget d C r/2 at ht
  linarith

end NeuralGeneralization.BatchTwoActivation
