import NeuralGeneralization.BatchTwoContinuousDepthFiniteParameters

/-! Sharp finite-product telescoping estimates for the normalized network. -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoContinuousDepthPaper
set_option maxHeartbeats 1200000
set_option backward.isDefEq.respectTransparency false

def productSensitivity (b : ℕ → ℝ) (s : Finset ℕ) : ℝ :=
  ∑ i ∈ s,∏ j ∈ s.erase i,b j

theorem productSensitivity_nonneg (b : ℕ → ℝ) (s : Finset ℕ) (hb : ∀ i ∈ s,0 ≤ b i) :
    0 ≤ productSensitivity b s := by
  apply Finset.sum_nonneg
  intro i hi
  exact Finset.prod_nonneg (fun j hj => hb j (Finset.mem_of_mem_erase hj))

theorem productSensitivity_insert (b : ℕ → ℝ) (s : Finset ℕ) {j : ℕ} (hj : j ∉ s) :
    productSensitivity b (insert j s)=(∏ i ∈ s,b i)+b j*productSensitivity b s := by
  unfold productSensitivity
  rw [Finset.sum_insert hj,Finset.erase_insert hj]
  congr 1
  rw [Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro i hi
  have hij : i ≠ j := by intro h;subst i;exact hj hi
  rw [Finset.erase_insert_of_ne hij.symm,Finset.prod_insert]
  exact fun h => hj (Finset.mem_of_mem_erase h)

theorem numerical_chain_bounds (L : ℕ) (b u e : ℕ → ℝ) {R η : ℝ}
    (hR : 0 ≤ R) (hη : 0 ≤ η) (hb : ∀ j < L,0 ≤ b j)
    (hu0 : u 0 ≤ R) (he0 : e 0 ≤ 0)
    (hu : ∀ j < L,u (j+1) ≤ b j*u j)
    (he : ∀ j < L,e (j+1) ≤ b j*e j+η*u j) :
    u L ≤ R*(∏ j ∈ Finset.range L,b j) ∧
    e L ≤ R*η*productSensitivity b (Finset.range L) := by
  induction L with
  | zero => simpa [productSensitivity] using And.intro hu0 he0
  | succ L ih =>
    have hh := ih (fun j hj => hb j (by omega))
      (fun j hj => hu j (by omega)) (fun j hj => he j (by omega))
    have hbL := hb L (by omega)
    constructor
    · calc
        _ ≤ b L*u L := hu L (by omega)
        _ ≤ b L*(R*∏ j ∈ Finset.range L,b j) := mul_le_mul_of_nonneg_left hh.1 hbL
        _ = R*(∏ j ∈ Finset.range (L+1),b j) := by rw [Finset.prod_range_succ];ring
    · calc
        _ ≤ b L*e L+η*u L := he L (by omega)
        _ ≤ b L*(R*η*productSensitivity b (Finset.range L))+η*(R*∏ j ∈ Finset.range L,b j) :=
          add_le_add (mul_le_mul_of_nonneg_left hh.2 hbL) (mul_le_mul_of_nonneg_left hh.1 hη)
        _ = R*η*productSensitivity b (Finset.range (L+1)) := by
          rw [Finset.range_add_one,productSensitivity_insert _ _ Finset.notMem_range_self]
          ring

theorem finite_product_le_rpow_sum_sq (s : Finset ℕ) (b : ℕ → ℝ)
    (hs : 0 < s.card) (hb : ∀ i ∈ s,0 ≤ b i) {B : ℝ} (hB : 0 < B)
    (hbudget : ∑ i ∈ s,(b i)^2 ≤ B) :
    (∏ i ∈ s,b i) ≤ (B/(s.card : ℝ))^((s.card : ℝ)/2) := by
  classical
  have hcard : (0 : ℝ) < s.card := by exact_mod_cast hs
  have ha : 0 < B/(s.card : ℝ) := div_pos hB hcard
  have hp := product_le_average_power (fun i : s => (b i)^2) (fun _ => sq_nonneg _)
    ha (by
      simp only [Fintype.card_coe,div_mul_cancel₀ _ hcard.ne',Finset.sum_coe_sort]
      exact (Finset.sum_coe_sort s (fun i => (b i)^2)).le.trans hbudget)
  have hp' : (∏ i ∈ s,b i)^2 ≤ (B/(s.card : ℝ))^s.card := by
    simpa only [Fintype.card_coe,Finset.prod_coe_sort,Finset.prod_pow] using hp
  have hr : ((B/(s.card : ℝ))^((s.card : ℝ)/2))^2=(B/(s.card : ℝ))^s.card := by
    rw [← Real.rpow_natCast,← Real.rpow_mul ha.le]
    norm_num only [Nat.cast_ofNat]
    rw [div_mul_cancel₀ _ (by norm_num : (2 : ℝ) ≠ 0),Real.rpow_natCast]
  have hn : 0 ≤ ∏ i ∈ s,b i := Finset.prod_nonneg hb
  have hn' : 0 ≤ (B/(s.card : ℝ))^((s.card : ℝ)/2) := Real.rpow_nonneg ha.le _
  nlinarith

theorem productSensitivity_bound {L : ℕ} (hL : 2 ≤ L) (b : ℕ → ℝ)
    (hb : ∀ i < L,0 ≤ b i) {B : ℝ} (hB : 0 < B)
    (hbudget : ∑ i ∈ Finset.range L,(b i)^2 ≤ B) :
    productSensitivity b (Finset.range L) ≤
      (L : ℝ)*(B/((L : ℝ)-1))^(((L : ℝ)-1)/2) := by
  have ht (i : ℕ) (hi : i ∈ Finset.range L) :
      (∏ j ∈ (Finset.range L).erase i,b j) ≤ (B/((L : ℝ)-1))^(((L : ℝ)-1)/2) := by
    have hc : ((Finset.range L).erase i).card=L-1 := by
      rw [Finset.card_erase_of_mem hi,Finset.card_range]
    have hsum : (∑ j ∈ (Finset.range L).erase i,(b j)^2) ≤ B := by
      apply le_trans _ hbudget
      exact Finset.sum_le_sum_of_subset_of_nonneg (Finset.erase_subset _ _) (fun _ _ _ => sq_nonneg _)
    have hh := finite_product_le_rpow_sum_sq ((Finset.range L).erase i) b
      (by rw [hc];omega) (fun j hj => hb j (Finset.mem_range.mp (Finset.mem_of_mem_erase hj))) hB hsum
    rw [hc,Nat.cast_sub (by omega : 1 ≤ L),Nat.cast_one] at hh
    exact hh
  unfold productSensitivity
  calc
    _ ≤ ∑ _i ∈ Finset.range L,(B/((L : ℝ)-1))^(((L : ℝ)-1)/2) :=
      Finset.sum_le_sum (fun i hi => ht i hi)
    _ = _ := by simp

/-- The sharp L-term telescoping factor, controlled by total squared layer
norms rather than a depth-exponential maximum of individual layer norms. -/
theorem numerical_chain_error {L : ℕ} (hL : 2 ≤ L) (b u e : ℕ → ℝ) {R η B : ℝ}
    (hR : 0 ≤ R) (hη : 0 ≤ η) (hB : 0 < B) (hb : ∀ j < L,0 ≤ b j)
    (hu0 : u 0 ≤ R) (he0 : e 0 ≤ 0)
    (hu : ∀ j < L,u (j+1) ≤ b j*u j)
    (he : ∀ j < L,e (j+1) ≤ b j*e j+η*u j)
    (hbudget : ∑ i ∈ Finset.range L,(b i)^2 ≤ B) :
    e L ≤ R*(L : ℝ)*η*(B/((L : ℝ)-1))^(((L : ℝ)-1)/2) := by
  have hh := (numerical_chain_bounds L b u e hR hη hb hu0 he0 hu he).2
  have hp := productSensitivity_bound hL b hb hB hbudget
  exact hh.trans ((mul_le_mul_of_nonneg_left hp (mul_nonneg hR hη)).trans_eq (by ring))

theorem inflated_layer_square_sum {L : ℕ} (a : Fin L → ℝ) {K η : ℝ}
    (ha : ∀ i,0 ≤ a i) (hK : 0 ≤ K) (hη : 0 ≤ η) (hbudget : ∑ i,(a i)^2 ≤ K+1) :
    ∑ i,(a i+η)^2 ≤ K+1+2*η*Real.sqrt ((L : ℝ)*(K+1))+(L : ℝ)*η^2 := by
  have hsum := Finset.sum_mul_sq_le_sq_mul_sq Finset.univ (fun _ : Fin L => (1 : ℝ)) a
  simp only [one_mul,one_pow,Finset.sum_const,Finset.card_univ,Fintype.card_fin,nsmul_eq_mul,mul_one] at hsum
  have hsq : (∑ i,a i)^2 ≤ (L : ℝ)*(K+1) :=
    hsum.trans (mul_le_mul_of_nonneg_left hbudget (Nat.cast_nonneg L))
  have hroot := Real.sq_sqrt (show 0 ≤ (L : ℝ)*(K+1) by positivity)
  have hsa : 0 ≤ ∑ i,a i := Finset.sum_nonneg (fun i _ => ha i)
  have hsum' : (∑ i,a i) ≤ Real.sqrt ((L : ℝ)*(K+1)) := by
    nlinarith [Real.sqrt_nonneg ((L : ℝ)*(K+1))]
  have he : (∑ i,(a i+η)^2)=(∑ i,(a i)^2)+2*η*(∑ i,a i)+(L : ℝ)*η^2 := by
    simp_rw [add_sq]
    simp only [Finset.sum_add_distrib,Finset.sum_const,Finset.card_univ,Fintype.card_fin,nsmul_eq_mul]
    rw [← Finset.sum_mul,← Finset.mul_sum]
    ring
  rw [he]
  nlinarith [mul_le_mul_of_nonneg_left hsum' (show 0 ≤ 2*η by positivity)]

end NeuralGeneralization.BatchTwoContinuousDepthPaper
