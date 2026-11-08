import Mathlib.Topology.MetricSpace.Contracting
import Mathlib.Analysis.Complex.LocallyUniformLimit
import Mathlib.Tactic

noncomputable section
open scoped Topology
open Complex Set Metric Filter
namespace NeuralGeneralization.OnlineLowerTanh

lemma contraction_on_disk (T:ℂ→ℂ) (a₀:ℂ) (r:ℝ) (hr:0≤r)
    (hmap:MapsTo T (closedBall a₀ r) (closedBall a₀ r))
    (hcon:∀a∈closedBall a₀ r,∀b∈closedBall a₀ r,
      dist (T a) (T b)≤(1/2:ℝ)*dist a b) :
    ∃b∈closedBall a₀ r,T b=b ∧
      (∀n:ℕ,dist (T^[n] a₀) b≤2*r*(1/2:ℝ)^n) ∧
      (∀a∈closedBall a₀ r,dist a b≤2*dist a (T a)) := by
  let D := closedBall a₀ r
  letI : CompleteSpace D := isClosed_closedBall.isComplete.completeSpace_coe
  let x : D := ⟨a₀,mem_closedBall_self hr⟩
  letI : Nonempty D := ⟨x⟩
  let f : D→D := fun a=>⟨T a,hmap a.property⟩
  have hf : ContractingWith (1/2:NNReal) f := by
    refine ⟨by norm_num,LipschitzWith.of_dist_le_mul ?_⟩
    intro a b
    exact hcon a a.property b b.property
  let b : D := hf.fixedPoint f
  have hfixed : T (b:ℂ)=(b:ℂ) := congrArg Subtype.val hf.fixedPoint_isFixedPt
  have hiter (n:ℕ) : ((f^[n] x:D):ℂ)=T^[n] a₀ := by
    induction n with
    | zero => rfl
    | succ n ih =>
      rw [Function.iterate_succ_apply',Function.iterate_succ_apply']
      change T ((f^[n] x:D):ℂ)=T (T^[n] a₀)
      rw [ih]
  refine ⟨b,b.property,hfixed,?_,?_⟩
  · intro n
    have hh:=hf.apriori_dist_iterate_fixedPoint_le x n
    change dist ((f^[n] x:D):ℂ) (b:ℂ) ≤ dist a₀ (T a₀)*(1/2:ℝ)^n/(1-1/2) at hh
    rw [hiter] at hh
    have hm : dist a₀ (T a₀)≤r := by
      rw [dist_comm]
      exact hmap x.property
    calc
      _ ≤ dist a₀ (T a₀)*(1/2:ℝ)^n/(1-1/2) := hh
      _ ≤ r*(1/2:ℝ)^n/(1-1/2) := by gcongr
      _ = _ := by ring
  · intro a ha
    have hh:=hf.dist_fixedPoint_le (⟨a,ha⟩:D)
    change dist a (b:ℂ)≤dist a (T a)/(1-(1/2:ℝ)) at hh
    convert hh using 1 <;> ring

/-- A uniformly contracting analytic iteration produces an actual holomorphic
fixed-point branch. No implicit-function theorem at infinity is required. -/
theorem holomorphic_contraction_branch (T:ℂ→ℂ→ℂ) {U:Set ℂ} (hU:IsOpen U)
    (a₀:ℂ) (r:ℝ) (hr:0≤r)
    (hmap:∀z∈U,MapsTo (T z) (closedBall a₀ r) (closedBall a₀ r))
    (hcon:∀z∈U,∀a∈closedBall a₀ r,∀b∈closedBall a₀ r,
      dist (T z a) (T z b)≤(1/2:ℝ)*dist a b)
    (hcomp:∀a:ℂ→ℂ,DifferentiableOn ℂ a U→MapsTo a U (closedBall a₀ r)→
      DifferentiableOn ℂ (fun z=>T z (a z)) U) :
    ∃b:ℂ→ℂ,DifferentiableOn ℂ b U ∧ ∀z∈U,
      b z∈closedBall a₀ r ∧ T z (b z)=b z ∧
      ∀a∈closedBall a₀ r,dist a (b z)≤2*dist a (T z a) := by
  classical
  have hex (z:U) := contraction_on_disk (T z) a₀ r hr (hmap z z.property) (hcon z z.property)
  choose bs hmem hfix herr hres using hex
  let b : ℂ→ℂ := fun z=>if hz:z∈U then bs ⟨z,hz⟩ else a₀
  have hb (z:ℂ) (hz:z∈U) : b z=bs ⟨z,hz⟩ := by simp [b,hz]
  let F : ℕ→ℂ→ℂ := fun n z=>(T z)^[n] a₀
  have hFmem (n:ℕ) : MapsTo (F n) U (closedBall a₀ r) := by
    intro z hz
    exact (hmap z hz).iterate n (mem_closedBall_self hr)
  have hFd (n:ℕ) : DifferentiableOn ℂ (F n) U := by
    induction n with
    | zero => exact differentiableOn_const _
    | succ n ih =>
      have hh:=hcomp (F n) ih (hFmem n)
      simpa only [F,Function.iterate_succ_apply'] using hh
  have hlim : TendstoUniformlyOn F b atTop U := by
    apply Metric.tendstoUniformlyOn_iff.mpr
    intro ε hε
    have hp:= (tendsto_pow_atTop_nhds_zero_of_lt_one (by norm_num : 0≤(1/2:ℝ)) (by norm_num)).const_mul (2*r)
    have he : ∀ᶠ n:ℕ in atTop,2*r*(1/2:ℝ)^n<ε := by
      exact (tendsto_order.mp (by simpa using hp)).2 ε hε
    filter_upwards [he] with n hn
    intro z hz
    rw [hb z hz,dist_comm]
    exact (herr ⟨z,hz⟩ n).trans_lt hn
  refine ⟨b,hlim.tendstoLocallyUniformlyOn.differentiableOn (Eventually.of_forall hFd) hU,?_⟩
  intro z hz
  rw [hb z hz]
  exact ⟨hmem ⟨z,hz⟩,hfix ⟨z,hz⟩,hres ⟨z,hz⟩⟩

end NeuralGeneralization.OnlineLowerTanh
