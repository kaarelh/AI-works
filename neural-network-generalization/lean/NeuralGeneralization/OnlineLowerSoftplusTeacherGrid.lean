import NeuralGeneralization.OnlineLowerSoftplusBasic
import NeuralGeneralization.OnlineLowerTeacher
import Mathlib.Topology.Algebra.InfiniteSum.NatInt
import Mathlib.Analysis.SpecificLimits.Normed

/-! A dimension-independent softplus approximation bound on the integer grid. -/
noncomputable section
set_option maxHeartbeats 1000000
open scoped BigOperators Classical
namespace NeuralGeneralization.OnlineLowerSoftplus
open ConcreteModel OnlineLower

lemma softplus_relu_error_exp (x : ℝ) :
    |softplus x-relu x| ≤ Real.exp (-|x|) := by
  have hlog (t : ℝ) : softplus t ≤ Real.exp t := by
    have h := Real.log_le_sub_one_of_pos (show 0 < 1+Real.exp t by positivity)
    dsimp [softplus]
    linarith
  by_cases hx : 0 ≤ x
  · rw [relu,max_eq_right hx,softplus_neg_identity x]
    have hs := softplus_nonneg (-x)
    have he : x+softplus (-x)-x=softplus (-x) := by ring
    rw [he,abs_of_nonneg hs,abs_of_nonneg hx]
    exact hlog (-x)
  · rw [relu,max_eq_left (le_of_not_ge hx),sub_zero,abs_of_nonneg (softplus_nonneg x),
      abs_of_neg (lt_of_not_ge hx),neg_neg]
    exact hlog x

lemma integer_geometric_hasSum : HasSum (fun z : ℤ => (1/2 : ℝ)^z.natAbs) 3 := by
  have h : HasSum (fun n : ℕ => (1/2 : ℝ)^n) 2 := by
    convert hasSum_geometric_of_abs_lt_one (r:=(1/2:ℝ)) (by norm_num) using 1 <;> norm_num
  have h₁ : HasSum (fun n : ℕ => (1/2 : ℝ)^(n : ℤ).natAbs) 2 := by simpa using h
  have h₂ : HasSum (fun n : ℕ => (1/2 : ℝ)^(-(n : ℤ)).natAbs) 2 := by simpa using h
  have hh := HasSum.of_nat_of_neg (f := fun z : ℤ => (1/2 : ℝ)^z.natAbs) h₁ h₂
  norm_num at hh ⊢
  exact hh

lemma integer_exp_le_geometric (G : ℝ) (hG : 1 ≤ G) (z : ℤ) :
    Real.exp (-G*|(z : ℝ)|) ≤ (1/2 : ℝ)^z.natAbs := by
  have hE : Real.exp (-G) ≤ 1/2 := by
    rw [Real.exp_neg]
    have h := Real.add_one_le_exp G
    have he : (2:ℝ) ≤ Real.exp G := by linarith
    simpa using (one_div_le_one_div_of_le (by norm_num : (0:ℝ)<2) he)
  have hcast : (z.natAbs : ℝ)=|(z : ℝ)| := by
    have hh := congrArg (fun q : ℤ => (q : ℝ)) (Int.natCast_natAbs z)
    simpa only [Int.cast_natCast, Int.cast_abs] using hh
  rw [←hcast,mul_comm,Real.exp_nat_mul]
  exact pow_le_pow_left₀ (Real.exp_nonneg _) hE _

lemma integer_grid_error_sum (G : ℝ) (hG : 1 ≤ G) (d : ℕ) (z : ℤ) :
    (∑j : Fin (d+1),Real.exp (-G*|((z-(j.val:ℤ)):ℝ)|)) ≤ 3 := by
  let e : Fin (d+1) → ℤ := fun j => z-j.val
  have he : Function.Injective e := by
    intro i j hij
    apply Fin.ext
    dsimp [e] at hij
    omega
  have hsum := Summable.sum_le_tsum ((Finset.univ : Finset (Fin (d+1))).image e)
    (fun z _ => by positivity : ∀z ∉ (Finset.univ : Finset (Fin (d+1))).image e,0 ≤ (1/2:ℝ)^z.natAbs)
    integer_geometric_hasSum.summable
  rw [Finset.sum_image (fun _ _ _ _ h => he h),integer_geometric_hasSum.tsum_eq] at hsum
  simpa only [e, Int.cast_sub, Int.cast_natCast] using
    (Finset.sum_le_sum (fun j _ => integer_exp_le_geometric G hG (e j))).trans hsum

def softHat (G : ℝ) (j : ℕ) (t : ℝ) : ℝ :=
  ∑q : Fin 3,hatCoefficient q*(softplus (G*(t-j+1-q.val))/G)

def softParitySpline (G : ℝ) (d : ℕ) (t : ℝ) : ℝ :=
  ∑j : Fin (d+1),(-1:ℝ)^j.val*softHat G j.val t

lemma softParitySpline_error (G : ℝ) (hG : 1 ≤ G) (d t : ℕ) :
    |softParitySpline G d t-paritySpline d t| ≤ 12/G := by
  have hGp : 0 < G := by linarith
  have hpoint (j : Fin (d+1)) (q : Fin 3) :
      |softplus (G*((t:ℝ)-j.val+1-q.val))/G-relu ((t:ℝ)-j.val+1-q.val)| ≤
        Real.exp (-G*|((t:ℝ)-j.val+1-q.val)|)/G := by
    have hr : relu (G*((t:ℝ)-j.val+1-q.val)) = G*relu ((t:ℝ)-j.val+1-q.val) := by
      unfold relu
      rw [mul_max_of_nonneg _ _ hGp.le,mul_zero]
    have he : softplus (G*((t:ℝ)-j.val+1-q.val))/G-relu ((t:ℝ)-j.val+1-q.val)=
        (softplus (G*((t:ℝ)-j.val+1-q.val))-relu (G*((t:ℝ)-j.val+1-q.val)))/G := by
      rw [hr];field_simp
    rw [he,abs_div,abs_of_pos hGp]
    have hh := softplus_relu_error_exp (G*((t:ℝ)-j.val+1-q.val))
    rw [abs_mul,abs_of_pos hGp] at hh
    simpa only [neg_mul] using div_le_div_of_nonneg_right hh hGp.le
  have hq (q : Fin 3) : (∑j : Fin (d+1),Real.exp (-G*|((t:ℝ)-j.val+1-q.val)|)) ≤ 3 := by
    convert integer_grid_error_sum G hG d ((t:ℤ)+1-q.val) using 1
    apply Finset.sum_congr rfl
    intro j _
    push_cast
    congr 3 <;> ring
  have hex : softParitySpline G d t-paritySpline d t =
      ∑j : Fin (d+1),∑q : Fin 3,(-1:ℝ)^j.val*hatCoefficient q*
        (softplus (G*((t:ℝ)-j.val+1-q.val))/G-relu ((t:ℝ)-j.val+1-q.val)) := by
    unfold softParitySpline paritySpline softHat
    rw [←Finset.sum_sub_distrib]
    apply Finset.sum_congr rfl;intro j _
    rw [←hat_sum]
    rw [Finset.mul_sum,Finset.mul_sum,←Finset.sum_sub_distrib]
    apply Finset.sum_congr rfl;intro q _;ring
  rw [hex,Finset.sum_comm]
  calc
    _ ≤ ∑q : Fin 3,∑j : Fin (d+1),|(-1:ℝ)^j.val*hatCoefficient q*
        (softplus (G*((t:ℝ)-j.val+1-q.val))/G-relu ((t:ℝ)-j.val+1-q.val))| := by
      exact (Finset.abs_sum_le_sum_abs _ _).trans
        (Finset.sum_le_sum fun q _ => Finset.abs_sum_le_sum_abs _ _)
    _ ≤ ∑q : Fin 3,∑j : Fin (d+1),|hatCoefficient q| *
        (Real.exp (-G*|((t:ℝ)-j.val+1-q.val)|)/G) := by
      apply Finset.sum_le_sum;intro q _
      apply Finset.sum_le_sum;intro j _
      rw [abs_mul,abs_mul,abs_neg_one_pow,one_mul]
      exact mul_le_mul_of_nonneg_left (hpoint j q) (abs_nonneg _)
    _ = ∑q : Fin 3,|hatCoefficient q| * ((∑j : Fin (d+1),Real.exp (-G*|((t:ℝ)-j.val+1-q.val)|))/G) := by
      simp_rw [←Finset.mul_sum,←Finset.sum_div]
    _ ≤ ∑q : Fin 3,|hatCoefficient q| * (3/G) := Finset.sum_le_sum fun q _ =>
      mul_le_mul_of_nonneg_left (div_le_div_of_nonneg_right (hq q) hGp.le) (abs_nonneg _)
    _ = _ := by norm_num [Fin.sum_univ_succ,hatCoefficient];ring
end NeuralGeneralization.OnlineLowerSoftplus
