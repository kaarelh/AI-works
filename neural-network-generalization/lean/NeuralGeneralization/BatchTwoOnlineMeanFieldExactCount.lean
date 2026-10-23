import NeuralGeneralization.BatchTwoOnlineMeanFieldExactBudgets
import NeuralGeneralization.ParameterCounting

/-! The appendix's real bounded-parameter count, without rounding the weight
bound or the sensitivity up before taking the exponential-in-depth factor. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1000000
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoOnlineMeanFieldExact
open ConcreteModel

theorem hiddenSensitivity_real_bound (d u r : ℕ) {B : ℝ} (hB : 0≤B) :
    hiddenSensitivity d u B r≤((d:ℝ)+1)*(1+u*(B+1))^r := by
  induction r with
  | zero=>simp [hiddenSensitivity]
  | succ r ih=>
    let X:=((d:ℝ)+1)*(1+u*(B+1))^r
    have hb:1≤1+(u:ℝ)*(B+1):=by
      have hp:0≤(u:ℝ)*(B+1):=by positivity
      linarith
    have hX:1≤X:=one_le_mul_of_one_le_of_one_le (by linarith [Nat.cast_nonneg d (α:=ℝ)])
      (one_le_pow₀ hb)
    change (u:ℝ)*(1+B*hiddenSensitivity d u B r)≤_
    calc
      _ ≤ (u:ℝ)*(1+B*X):=by gcongr
      _ ≤ (1+(u:ℝ)*(B+1))*X:=by nlinarith [Nat.cast_nonneg u (α:=ℝ)]
      _ = _:=by dsimp [X];rw [pow_succ];ring

theorem sensitivity_bound (d u r : ℕ) (hu : 0<u) {B : ℝ} (hB : 0≤B) :
    nextSensitivity u B (hiddenSensitivity d u B r)≤sensitivity d u r B := by
  have h:=hiddenSensitivity_real_bound d u (r+1) hB
  change nextSensitivity u B (hiddenSensitivity d u B r)≤_ at h
  apply h.trans
  unfold sensitivity
  apply mul_le_mul_of_nonneg_right _ (by positivity)
  have huR:(1:ℝ)≤u:=by exact_mod_cast hu
  nlinarith [Nat.cast_nonneg r (α:=ℝ)]

def representedFunctions (d u r : ℕ) (B : ℝ) : Finset (BooleanFunction d) := by
  classical
  exact Finset.univ.filter fun f=>∃w : Weights d u r,
    w∈marginEvent Real.tanh (1/2) f ∧ ∀i,|w i|≤B

@[simp] theorem mem_representedFunctions {d u r : ℕ} {B : ℝ} {f : BooleanFunction d} :
    f∈representedFunctions d u r B ↔ ∃w : Weights d u r,
      w∈marginEvent Real.tanh (1/2) f ∧ ∀i,|w i|≤B := by
  classical
  simp [representedFunctions]

theorem representedFunctions_count (d u r : ℕ) (hu : 0<u) {B : ℝ} (hB : 1≤B) :
    ((representedFunctions d u r B).card:ℝ)≤
      Real.exp ((hiddenParameterCount d u r+u:ℕ)*Real.log (3+16*B*sensitivity d u r B)) := by
  classical
  let A:=representedFunctions d u r B
  let T:=sensitivity d u r B
  let Q:ℕ:=⌈B*T⌉₊
  let Z:=↥(Finset.Icc (-(Q:ℤ)) (Q:ℤ))
  have hT:0<T:=by dsimp [T,sensitivity];positivity
  have hB0:0≤B:=by linarith
  have hQ: B*T≤(Q:ℝ):=Nat.le_ceil _
  let w (f:↥A):Weights d u r:=Classical.choose (mem_representedFunctions.mp f.property)
  have hw (f:↥A):w f∈marginEvent Real.tanh (1/2) f.val ∧ ∀i,|w f i|≤B:=
    Classical.choose_spec (mem_representedFunctions.mp f.property)
  have hcode (f:↥A) (i:WeightIndex d u r):⌊T*w f i⌋∈Finset.Icc (-(Q:ℤ)) (Q:ℤ):=by
    have hb:=abs_le.mp ((hw f).2 i)
    have hlo:-(Q:ℝ)≤T*w f i:=by nlinarith [mul_le_mul_of_nonneg_left hb.1 hT.le]
    have hhi:T*w f i≤(Q:ℝ):=by nlinarith [mul_le_mul_of_nonneg_left hb.2 hT.le]
    apply Finset.mem_Icc.mpr
    constructor
    · apply Int.le_floor.mpr
      simpa using hlo
    · simpa using Int.floor_mono hhi
  let code (f:↥A):WeightIndex d u r→Z:=fun i=>⟨⌊T*w f i⌋,hcode f i⟩
  have hinj:Function.Injective code:=by
    intro f g heq
    apply Subtype.ext
    apply margin_functions_eq_of_output_close Real.tanh (w f) (w g) f.val g.val (hw f).1 (hw g).1
    intro x
    have hweights (i:WeightIndex d u r):|w f i-w g i|≤1/T:=by
      have hi:⌊T*w f i⌋=⌊T*w g i⌋:=congrArg Subtype.val (congrFun heq i)
      have hh:=Int.abs_sub_lt_one_of_floor_eq_floor hi
      rw [←mul_sub,abs_mul,abs_of_pos hT] at hh
      exact (le_div_iff₀ hT).mpr (by nlinarith)
    have hh:=networkOutput_parameter_stability Real.tanh tanh_admissible (w f) (w g) B (1/T)
      hB0 (by positivity) (hw g).2 hweights x
    apply hh.trans
    calc
      _ ≤ (1/T)*T:=mul_le_mul_of_nonneg_left (sensitivity_bound d u r hu hB0) (by positivity)
      _ = 1:=by field_simp
  have hz:Fintype.card Z=2*Q+1:=by
    change Fintype.card ↥(Finset.Icc (-(Q:ℤ)) (Q:ℤ))=_
    rw [Fintype.card_coe,Int.card_Icc]
    omega
  have hcard: A.card≤(2*Q+1)^Fintype.card (WeightIndex d u r):=by
    have hh:=Fintype.card_le_of_injective code hinj
    simpa only [Fintype.card_coe,Fintype.card_fun,hz] using hh
  have hbase:(2*Q+1:ℕ)≤3+16*B*T:=by
    have hceil:(Q:ℝ)<B*T+1:=Nat.ceil_lt_add_one (by positivity)
    push_cast
    nlinarith
  have hpos:0<3+16*B*T:=by positivity
  calc
    (A.card:ℝ) ≤ ((2*Q+1:ℕ):ℝ)^Fintype.card (WeightIndex d u r):=by exact_mod_cast hcard
    _ ≤ (3+16*B*T)^Fintype.card (WeightIndex d u r):=
      pow_le_pow_left₀ (Nat.cast_nonneg _) hbase _
    _ = _:=by
      nth_rw 1 [←Real.exp_log hpos]
      rw [←Real.exp_nat_mul]
      congr 1
      rw [weightIndex_card]
      unfold hiddenParameterCount
      push_cast
      ring

def functions (d r : ℕ) (K : ℝ) : Finset (BooleanFunction d) :=
  representedFunctions d (compressedWidth d r K) r (compressedBound d r K)

end NeuralGeneralization.BatchTwoOnlineMeanFieldExact
