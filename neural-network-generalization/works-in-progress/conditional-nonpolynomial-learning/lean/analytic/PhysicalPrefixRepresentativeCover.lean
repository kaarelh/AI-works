import PhysicalPathBlockCovers
import UniformBlockConstants

/-! Iteration of actual, original-input-indexed block covers. The final
normalization cancels the literal physical gain product and charges only the
adjusted entropy remainder. -/
noncomputable section
set_option maxHeartbeats 2500000
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators ENNReal RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.ConcreteModel
variable {d H : ℕ} {t : ℝ} {f : BooleanFunction d}
local instance (B : CanonicalProgramState d) : DecidableEq B.Index := Classical.decEq _
variable {P : ControlledMarginPath d H t f} {S : Finset (Cube d)} {states : ℕ→CanonicalProgramState d}

def representativeRadius (E : ℕ→ℝ) (good : ℕ→Prop) [DecidablePred good]
    (r : ℝ) : ℕ→ℝ
  | 0=>r
  | n+1=>representativeRadius E good r n * Real.exp (E n-if good n then 1 else 0)

lemma representativeRadius_pos (E : ℕ→ℝ) (good : ℕ→Prop) [DecidablePred good]
    {r : ℝ} (hr : 0<r) (n : ℕ) : 0<representativeRadius E good r n := by
  induction n with
  | zero=>exact hr
  | succ n ih=>exact mul_pos ih (Real.exp_pos _)

 theorem physical_indexed_block_cover
    (hd : 1≤d)
    (hzero : ∀x y,inner ℝ ((states 0).feature x) ((states 0).feature y)=
      inner ℝ (normalizedInputFeature d x) (normalizedInputFeature d y))
    (hstep : ∀j<H,PhysicalEntropySplitStep P S j (states j) (states (j+1)))
    {ε : ℝ} (hε : 0<ε) (b n : ℕ) (hb : 1≤b) (hfit : n*b≤H)
    (ha : 0<(physicalVariance P:ℝ)⁻¹-1)
    (good : ℕ→Prop) [DecidablePred good]
    {E B : ℝ} (hB : 0<B) (T k : ℕ) (hT : 0<T)
    (hgridSize : (canonicalBlockHSBound E)^2≤(B/64)^2*k)
    (hgridError : ∀Q:ℝ,0≤Q→Q≤(canonicalBlockHSBound E)^2→
      Real.sqrt (Q/(T:ℝ)^2+(B/64)^2)≤B/32)
    (hcost : ∀i<n,good i→(b:ℝ)*disjointBlockCost (physicalLayerCost P) 0 b i≤E)
    (hfree : t^b≤B/32)
    (hnonlinear : ∀i<n,good i→disjointBlockCost (pathNonlinearCost hstep ε) 0 b i≤
      B/(16*canonicalBlockNonlinearBound E))
    (hminimum : ∀i<n,B≤Real.exp ((disjointBlockCost (physicalLayerCost P) 0 b i-
      (b:ℝ)*subcriticalCostBaseline (physicalVariance P))/((physicalVariance P:ℝ)⁻¹-1)-1)) :
    IndexedActualBallCover (states (n*b)).feature (((2*T+1)^k)^n)
      (representativeRadius
        (fun i=>(disjointBlockCost (physicalLayerCost P) 0 b i-
          (b:ℝ)*subcriticalCostBaseline (physicalVariance P))/((physicalVariance P:ℝ)⁻¹-1))
        good (2*Real.sqrt 2) n) := by
  classical
  let Ex := fun i=>(disjointBlockCost (physicalLayerCost P) 0 b i-
    (b:ℝ)*subcriticalCostBaseline (physicalVariance P))/((physicalVariance P:ℝ)⁻¹-1)
  let r := representativeRadius Ex good (2*Real.sqrt 2)
  have hr (i:ℕ) : 0<r i := representativeRadius_pos Ex good (by positivity) i
  have hnorm (x:Cube d) : ‖(states 0).feature x‖≤Real.sqrt 2 := by
    apply Real.le_sqrt_of_sq_le
    rw [←real_inner_self_eq_norm_sq,hzero,real_inner_self_eq_norm_sq]
    exact normalizedInputFeature_norm_sq_le_two hd x
  have h0 : IndexedActualBallCover (states (0*b)).feature 1 (r 0) := by
    let z : Cube d := fun _=>false
    refine ⟨{z},by simp,?_⟩
    intro x
    refine ⟨z,by simp,?_⟩
    have hid := congrArg (fun j=>dist ((states j).feature x) ((states j).feature z)) (Nat.zero_mul b)
    rw [hid]
    rw [dist_eq_norm]
    exact (norm_sub_le _ _).trans (by change _≤2*Real.sqrt 2; linarith [hnorm x,hnorm z])
  have hh := indexed_cover_iteration (fun i=>(states (i*b)).feature) r 1 ((2*T+1)^k) n h0 ?_
  · simpa only [one_mul] using hh
  intro i hi z
  have hifit : i*b+b≤H := by
    have hh := Nat.mul_le_mul_right b (show i+1≤n by omega)
    rw [Nat.add_mul,Nat.one_mul] at hh
    omega
  by_cases hg : good i
  · obtain ⟨Y,hY,hcard,hcover⟩ := physical_path_good_block_cover hstep hε (i*b) b hifit hb
      hB T k hT hgridSize hgridError
      (by simpa only [disjointBlockCost,Nat.zero_add] using hcost i hi hg) hfree
      (by simpa only [disjointBlockCost,Nat.zero_add] using hnonlinear i hi hg)
      {x | dist ((states (i*b)).feature x) ((states (i*b)).feature z)≤r i}
      ((states (i*b)).feature z) (hr i) (fun x hx=>hx)
    refine ⟨Y,(fun y hy=>hY hy),hcard,?_⟩
    intro x hx
    obtain ⟨y,hy,hxy⟩ := hcover x hx
    refine ⟨y,hy,?_⟩
    have hbnd : B*r i/2≤r (i+1) := by
      change B*r i/2≤r i*Real.exp (Ex i-if good i then 1 else 0)
      rw [if_pos hg]
      have hm := mul_le_mul_of_nonneg_right (hminimum i hi) (hr i).le
      change B*r i≤Real.exp (Ex i-1)*r i at hm
      nlinarith [mul_nonneg hB.le (hr i).le]
    have hid := congrArg (fun j=>dist ((states j).feature x) ((states j).feature y))
      (show i*b+b=(i+1)*b by ring)
    rw [←hid]
    exact hxy.trans hbnd
  · obtain ⟨Y,hY,hcard,hcover⟩ := indexed_cover_one_ball
      (states (i*b)).feature (states (i*b+b)).feature (r i) (Real.exp (Ex i))
      (Real.exp_pos _).le
      (fun x y=>by simpa only [Ex,disjointBlockCost,Nat.zero_add] using
        physical_path_block_pair_gain hstep (i*b) b hifit ha x y) z (hr i).le
    refine ⟨Y,hY,hcard.trans (by exact one_le_pow₀ (by omega)),?_⟩
    intro x hx
    obtain ⟨y,hy,hxy⟩ := hcover x hx
    refine ⟨y,hy,?_⟩
    have hid := congrArg (fun j=>dist ((states j).feature x) ((states j).feature y))
      (show i*b+b=(i+1)*b by ring)
    rw [←hid]
    simpa only [r,representativeRadius,if_neg hg,sub_zero,mul_comm] using hxy

#print axioms physical_indexed_block_cover
end ConditionalNonpolynomial.Analytic
