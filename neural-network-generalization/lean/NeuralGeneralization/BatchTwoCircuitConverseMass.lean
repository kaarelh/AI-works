import NeuralGeneralization.BatchTwoCircuitConversePrior

/-!
# Version-space masses and exact gate-count tails
-/

namespace NeuralGeneralization.BatchTwoCircuitConverse

open scoped ENNReal BigOperators
noncomputable section
open Classical

/-- Unnormalized mass of an event in the actual NAND-description prior. -/
def descriptionMass {d : ℕ} (P : Circuit d → Prop) : ℝ≥0∞ :=
  ∑' c : Circuit d, if P c then circuitMass c else 0

theorem descriptionMass_le_one {d : ℕ} (P : Circuit d → Prop) : descriptionMass P ≤ 1 := by
  rw [← tsum_circuitMass d]
  exact ENNReal.tsum_le_tsum (fun c => by split_ifs <;> simp)

theorem descriptionMass_ne_top {d : ℕ} (P : Circuit d → Prop) : descriptionMass P ≠ ⊤ :=
  ne_top_of_le_ne_top ENNReal.one_ne_top (descriptionMass_le_one P)

theorem descriptionMass_mono {d : ℕ} {P Q : Circuit d → Prop}
    (h : ∀ c, P c → Q c) : descriptionMass P ≤ descriptionMass Q := by
  apply ENNReal.tsum_le_tsum
  intro c
  split_ifs with hp hq <;> simp_all

theorem descriptionMass_by_size {d : ℕ} (P : Circuit d → Prop) :
    descriptionMass P = ∑' n, ∑ g : Gates d n,
      if P (Circuit.mk n g) then circuitMass (Circuit.mk n g) else 0 := by
  unfold descriptionMass
  rw [← (Circuit.equivSigma d).symm.tsum_eq]
  change (∑' c : (n : ℕ) × Gates d n,
    if P (Circuit.mk c.1 c.2) then circuitMass (Circuit.mk c.1 c.2) else 0) = _
  rw [ENNReal.tsum_sigma (fun n g =>
    if P (Circuit.mk n g) then circuitMass (Circuit.mk n g) else 0)]
  simp only [tsum_fintype]

theorem geometric_tail (C : ℕ) :
    (∑' n : ℕ, if C ≤ n then (2⁻¹ : ℝ≥0∞)^(n+1) else 0) = (2⁻¹ : ℝ≥0∞)^C := by
  have hshift : (∑' n : ℕ, if C ≤ n+C then (2⁻¹ : ℝ≥0∞)^(n+C+1) else 0) =
      (2⁻¹ : ℝ≥0∞)^C := by
    simp only [Nat.le_add_left, ↓reduceIte]
    have he : ∀ n, n+C+1 = C+(n+1) := by omega
    simp_rw [he]
    simp_rw [pow_add (2⁻¹ : ℝ≥0∞) C]
    rw [ENNReal.tsum_mul_left, ENNReal.tsum_geometric_add_one,
      ENNReal.one_sub_inv_two, inv_inv]
    rw [ENNReal.inv_mul_cancel (by norm_num) (by norm_num), mul_one]
  have hs := HasSum.sum_range_add
    (f := fun n : ℕ => if C ≤ n then (2⁻¹ : ℝ≥0∞)^(n+1) else 0)
    (k := C) (ENNReal.summable.hasSum_iff.mpr hshift)
  have hz : (∑ n ∈ Finset.range C,
      if C ≤ n then (2⁻¹ : ℝ≥0∞)^(n+1) else 0) = 0 := by
    apply Finset.sum_eq_zero
    intro n hn
    simp only [Finset.mem_range] at hn
    simp [Nat.not_le.mpr hn]
  simpa only [hz, zero_add] using hs.tsum_eq

/-- Exact geometric gate-count tail. -/
theorem descriptionMass_size_ge (d C : ℕ) :
    descriptionMass (fun c : Circuit d => C ≤ c.size) = (2⁻¹ : ℝ≥0∞)^C := by
  rw [descriptionMass_by_size]
  have he : ∀ n, (∑ g : Gates d n,
      if C ≤ (Circuit.mk n g).size then circuitMass (Circuit.mk n g) else 0) =
      if C ≤ n then (2⁻¹ : ℝ≥0∞)^(n+1) else 0 := by
    intro n
    change (∑ g : Gates d n, if C ≤ n then circuitMass (Circuit.mk n g) else 0) = _
    by_cases hn : C ≤ n
    · simp only [hn, ↓reduceIte, sum_circuitMass_size]
    · simp only [hn, ↓reduceIte, Finset.sum_const_zero]
  convert (tsum_congr he).trans (geometric_tail C) using 1
  apply tsum_congr
  intro n
  apply Finset.sum_congr rfl
  intro g hg
  by_cases hn : C ≤ n <;> simp only [hn, ↓reduceIte]

/-- The mass of an exact version space is at most the gate-count tail at its
minimum consistent circuit size. -/
theorem fitting_mass_le_complexity_tail {d : ℕ} (f : Input d → Bool)
    (A : Finset (Input d)) :
    descriptionMass (fun c => c.Fits f A) ≤ (2⁻¹ : ℝ≥0∞)^(complexity f A) := by
  rw [← descriptionMass_size_ge d (complexity f A)]
  exact descriptionMass_mono (fun c hc => complexity_le f A c hc)


/-- Prior mass cannot be lost by an injective repair beyond its pointwise cost. -/
theorem repair_mass_lower_bound {d : ℕ} (P Q : Circuit d → Prop)
    (repair : Circuit d → Circuit d) (hinj : Function.Injective repair)
    (β : ℝ≥0∞) (hgood : ∀ c, P c → Q (repair c))
    (hratio : ∀ c, P c → β * circuitMass c ≤ circuitMass (repair c)) :
    β * descriptionMass P ≤ descriptionMass Q := by
  unfold descriptionMass
  rw [← ENNReal.tsum_mul_left]
  calc
    (∑' c : Circuit d, β * (if P c then circuitMass c else 0)) ≤
        ∑' c : Circuit d, if Q (repair c) then circuitMass (repair c) else 0 := by
      apply ENNReal.tsum_le_tsum
      intro c
      by_cases hp : P c
      · simp only [hp, hgood c hp, ↓reduceIte]
        exact hratio c hp
      · simp only [hp, ↓reduceIte, mul_zero]
        exact zero_le
    _ ≤ ∑' c : Circuit d, if Q c then circuitMass c else 0 :=
      ENNReal.tsum_comp_le_tsum_of_injective hinj _

theorem Gates.card_add_le (d s r : ℕ) :
    Fintype.card (Gates d (s+r)) ≤
      Fintype.card (Gates d s) * (d+s+r+1)^(2*r) := by
  induction r with
  | zero => simp
  | succ r ih =>
    rw [Nat.add_succ, Gates.card_succ]
    calc
      Fintype.card (Gates d (s+r)) * (d+2+(s+r))^2 ≤
          (Fintype.card (Gates d s) * (d+s+r+1)^(2*r)) * (d+2+(s+r))^2 :=
        Nat.mul_le_mul_right _ ih
      _ ≤ (Fintype.card (Gates d s) * (d+s+(r+1)+1)^(2*r)) * (d+2+(s+r))^2 :=
        Nat.mul_le_mul_right _ (Nat.mul_le_mul_left _ (Nat.pow_le_pow_left (by omega) _))
      _ = Fintype.card (Gates d s) * (d+s+(r+1)+1)^(2*(r+1)) := by
        have he : d+2+(s+r) = d+s+(r+1)+1 := by omega
        rw [he, Nat.mul_assoc, ← pow_add]
        congr 2

lemma ennreal_div_mul_div (a b c e : ℝ≥0∞) (hb : b ≠ 0) (hbtop : b ≠ ⊤) :
    (a / b) * (c / e) = (a * c) / (b * e) := by
  simp only [div_eq_mul_inv, ENNReal.mul_inv (Or.inl hb) (Or.inl hbtop)]
  ac_rfl

/-- An explicit common lower bound for repairing all source circuits of at most K gates. -/
def repairRatio (d K : ℕ) : ℝ≥0∞ :=
  (2⁻¹ : ℝ≥0∞)^(3*d+3) / ((d+K+(3*d+3)+1 : ℕ) : ℝ≥0∞)^(2*(3*d+3))

theorem circuitMass_overwrite_ge {d : ℕ} (c : Circuit d) (target : Input d)
    (y : Bool) (K : ℕ) (hK : c.size ≤ K) :
    repairRatio d K * circuitMass c ≤ circuitMass (c.overwrite target y) := by
  let R := 3*d+3
  let B := d+K+R+1
  have hcard : Fintype.card (Gates d (c.size+R)) ≤
      Fintype.card (Gates d c.size) * B^(2*R) := by
    exact (Gates.card_add_le d c.size R).trans
      (Nat.mul_le_mul_left _ (Nat.pow_le_pow_left (by dsimp [B]; omega) _))
  have hcast : (Fintype.card (Gates d (c.size+R)) : ℝ≥0∞) ≤
      (B : ℝ≥0∞)^(2*R) * Fintype.card (Gates d c.size) := by
    have := (show (Fintype.card (Gates d (c.size+R)) : ℝ≥0∞) ≤
      (Fintype.card (Gates d c.size) : ℝ≥0∞) * (B : ℝ≥0∞)^(2*R) by
        exact_mod_cast hcard)
    simpa only [mul_comm] using this
  have hB0 : (B : ℝ≥0∞)^(2*R) ≠ 0 := by
    apply pow_ne_zero
    have : 0 < B := by dsimp [B]; omega
    exact_mod_cast this.ne'
  have hBtop : (B : ℝ≥0∞)^(2*R) ≠ ⊤ := ENNReal.pow_ne_top (ENNReal.natCast_ne_top _)
  change ((2⁻¹ : ℝ≥0∞)^R / (B : ℝ≥0∞)^(2*R)) *
    ((2⁻¹ : ℝ≥0∞)^(c.size+1) / Fintype.card (Gates d c.size)) ≤ _
  rw [ennreal_div_mul_div _ _ _ _ hB0 hBtop]
  calc
    ((2⁻¹ : ℝ≥0∞)^R * (2⁻¹ : ℝ≥0∞)^(c.size+1)) /
        ((B : ℝ≥0∞)^(2*R) * Fintype.card (Gates d c.size)) ≤
      ((2⁻¹ : ℝ≥0∞)^R * (2⁻¹ : ℝ≥0∞)^(c.size+1)) /
        Fintype.card (Gates d (c.size+R)) := ENNReal.div_le_div_left hcast _
    _ = circuitMass (c.overwrite target y) := by
      unfold circuitMass
      rw [Circuit.size_overwrite, ← pow_add]
      have he : R+(c.size+1) = c.size+(3*d+3)+1 := by dsimp [R]; omega
      rw [he]

/-- The concrete geometric prior's mass bridge. No abstract repair-cost or
posterior-mass hypothesis remains in this statement. -/
theorem geometric_repair_mass (d K : ℕ) (f : Input d → Bool)
    (A : Finset (Input d)) (x : Input d) :
    repairRatio d K * descriptionMass (fun c => c.Fits f A ∧ c.size ≤ K) ≤
      descriptionMass (fun c => c.Fits f (insert x A)) := by
  apply repair_mass_lower_bound _ _ (fun c => c.overwrite x (f x))
    (Circuit.overwrite_injective x (f x))
  · intro c hc
    exact c.fits_overwrite f A hc.1 x
  · intro c hc
    exact circuitMass_overwrite_ge c x (f x) K hc.2


theorem circuitMass_le_descriptionMass {d : ℕ} (P : Circuit d → Prop)
    (c : Circuit d) (hc : P c) : circuitMass c ≤ descriptionMass P := by
  unfold descriptionMass
  simpa only [hc, ↓reduceIte] using
    (ENNReal.le_tsum (f := fun a : Circuit d => if P a then circuitMass a else 0) c)

theorem descriptionMass_real_pos {d : ℕ} (P : Circuit d → Prop)
    (c : Circuit d) (hc : P c) : 0 < (descriptionMass P).toReal :=
  (circuitMass_toReal_pos c).trans_le
    (ENNReal.toReal_mono (descriptionMass_ne_top P) (circuitMass_le_descriptionMass P c hc))

theorem descriptionMass_split_size {d : ℕ} (P : Circuit d → Prop) (K : ℕ) :
    descriptionMass P = descriptionMass (fun c => P c ∧ c.size ≤ K) +
      descriptionMass (fun c => P c ∧ K < c.size) := by
  unfold descriptionMass
  rw [← ENNReal.tsum_add]
  apply tsum_congr
  intro c
  by_cases hp : P c <;> by_cases hk : c.size ≤ K <;>
    simp [hp, hk, lt_iff_not_ge]

theorem descriptionMass_large_size_le {d : ℕ} (P : Circuit d → Prop) (K : ℕ) :
    descriptionMass (fun c => P c ∧ K < c.size) ≤ (2⁻¹ : ℝ≥0∞)^(K+1) := by
  rw [← descriptionMass_size_ge d (K+1)]
  exact descriptionMass_mono (fun c hc => by omega)

end
end NeuralGeneralization.BatchTwoCircuitConverse
