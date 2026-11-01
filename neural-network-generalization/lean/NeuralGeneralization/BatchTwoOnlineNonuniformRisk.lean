import NeuralGeneralization.BatchTwoOnlineExpectation
import Mathlib.Algebra.Field.GeomSum

/-! Exact nonuniform IID one-step estimates. The exceptional contribution
is multiplied by the unseen input probability rather than charged per round. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
open Classical
attribute [local instance] Classical.propDecidable
namespace NeuralGeneralization.BatchTwoOnline
variable {X H : Type*} [Fintype X] [Fintype H] [DecidableEq H]

def unseenProbability (D : X→ℝ) {n : ℕ} (s : Fin n→X) : ℝ :=
  ∑ x, if (∀ i,s i≠x) then D x else 0

def expectedUnseen (D : X→ℝ) (n : ℕ) : ℝ := ∑ x,D x*(1-D x)^n

def iidExpectedRisk (D : X→ℝ) (w : H→ℝ) (good : H→X→Prop) (n : ℕ) : ℝ :=
  ∑ s : Fin n→X, iidWeight D n s *
    ∑ g,posterior w (fun g => allObservations (good g) n s) g * eventError D (good g)

theorem expected_unseen_eq (D : X→ℝ) (hDs : ∑ x,D x=1) (n : ℕ) :
    (∑ s : Fin n→X,iidWeight D n s * unseenProbability D s)=expectedUnseen D n := by
  unfold unseenProbability expectedUnseen
  simp_rw [Finset.mul_sum]
  rw [Finset.sum_comm]
  apply Finset.sum_congr rfl
  intro x _
  have he : (∑ s : Fin n→X, iidWeight D n s * (if ∀ i,s i≠x then D x else 0))=
      D x*(∑ s : Fin n→X,if allObservations (fun y => y≠x) n s then iidWeight D n s else 0) := by
    rw [Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro s _
    unfold allObservations
    split_ifs <;> ring
  rw [he,iid_survival]
  have hec : (∑ y,if y≠x then D y else 0)=1-D x := by
    have hsum : (∑ y,if y≠x then D y else 0)+D x=1 := by
      calc
        _ = (∑ y,if y≠x then D y else 0)+(∑ y,if y=x then D y else 0) := by simp
        _ = ∑ y,D y := by
          rw [← Finset.sum_add_distrib]
          apply Finset.sum_congr rfl
          intro y _
          by_cases hy : y=x <;> simp [hy]
        _ = 1 := hDs
    linarith
  rw [hec]

theorem eventError_le_unseen (D : X→ℝ) (hD : ∀ x,0≤D x)
    (good : X→Prop) {n : ℕ} (s : Fin n→X) (hs : allObservations good n s) :
    eventError D good≤unseenProbability D s := by
  apply Finset.sum_le_sum
  intro x _
  by_cases hx : good x
  · simp only [if_pos hx]
    split_ifs
    · exact hD x
    · exact le_refl _
  · have hu : ∀ i,s i≠x := fun i he => hx (he ▸ hs i)
    simp only [if_neg hx,if_pos hu,le_refl]

/-- A variable upper bound on retained losses refines the usual finite-class
posterior-risk estimate. -/
theorem posterior_risk_le_unseen
    (w : H→ℝ) (hw : ∀ g,0≤w g) (keep : H→Prop) (target : H)
    (ht : keep target) (hwt : 0<w target) (err : H→ℝ)
    (A : Finset H) (a U β : ℝ) (ha : 0≤a) (hU : 0≤U)
    (hbound : ∀ g,keep g → err g≤U)
    (hgood : ∀ g∈A,keep g → err g≤a)
    (htail : (∑ g∈Finset.univ \ A,w g)/w target≤β) :
    (∑ g,posterior w keep g*err g)≤a+β*U := by
  have hp := posterior_nonneg w keep hw target ht hwt
  have hs := posterior_sum w keep hw target ht hwt
  have ho := (posterior_mass_le_weight_ratio w keep hw target ht hwt (Finset.univ \ A)).trans htail
  have hpoint (g : H) : posterior w keep g*err g≤
      a*posterior w keep g+U*(if g∈A then 0 else posterior w keep g) := by
    by_cases hk : keep g
    · by_cases hg : g∈A
      · simp only [if_pos hg,mul_zero,add_zero]
        nlinarith [mul_le_mul_of_nonneg_left (hgood g hg hk) (hp g)]
      · simp only [if_neg hg]
        nlinarith [mul_le_mul_of_nonneg_left (hbound g hk) (hp g),mul_nonneg ha (hp g)]
    · simp [posterior_of_not_kept w keep g hk]
  calc
    _ ≤ ∑ g,(a*posterior w keep g+U*(if g∈A then 0 else posterior w keep g)) :=
      Finset.sum_le_sum fun g _ => hpoint g
    _ = a+U*∑ g∈Finset.univ \ A,posterior w keep g := by
      rw [Finset.sum_add_distrib,← Finset.mul_sum,hs,mul_one,← Finset.mul_sum]
      congr 2
      have hset : Finset.univ \ A=Finset.univ.filter (fun g => g∉A) := by ext; simp
      rw [hset,Finset.sum_filter]
      apply Finset.sum_congr rfl
      intro g _
      by_cases hg : g∈A <;> simp [hg]
    _ ≤ a+β*U := by nlinarith [mul_le_mul_of_nonneg_left ho hU]

theorem iid_expected_risk_le_unseen
    (D : X→ℝ) (hD : ∀ x,0≤D x) (hDs : ∑ x,D x=1)
    (w : H→ℝ) (hw : ∀ g,0≤w g) (good : H→X→Prop)
    (target : H) (ht : ∀ x,good target x) (hwt : 0<w target) (n : ℕ) :
    iidExpectedRisk D w good n≤expectedUnseen D n := by
  rw [← expected_unseen_eq D hDs n]
  apply Finset.sum_le_sum
  intro s _
  apply mul_le_mul_of_nonneg_left _ (iidWeight_nonneg D hD n s)
  have hkeep : allObservations (good target) n s := fun i => ht (s i)
  have hp := posterior_nonneg w (fun g => allObservations (good g) n s) hw target hkeep hwt
  have hs := posterior_sum w (fun g => allObservations (good g) n s) hw target hkeep hwt
  calc
    _ ≤ ∑ g,posterior w (fun g => allObservations (good g) n s) g * unseenProbability D s := by
      apply Finset.sum_le_sum
      intro g _
      by_cases hg : allObservations (good g) n s
      · exact mul_le_mul_of_nonneg_left (eventError_le_unseen D hD (good g) s hg) (hp g)
      · simp [posterior_of_not_kept w (fun g => allObservations (good g) n s) g hg]
    _ = _ := by rw [← Finset.sum_mul,hs,one_mul]

/-- Exact nonuniform expectation estimate with the logarithmic class term
and a summable exceptional-mass term. -/
theorem iid_expected_risk_relevant_bound
    (D : X→ℝ) (hD : ∀ x,0≤D x) (hDs : ∑ x,D x=1)
    (w : H→ℝ) (hw : ∀ g,0≤w g) (good : H→X→Prop)
    (target : H) (ht : ∀ x,good target x) (hwt : 0<w target)
    (A : Finset H) (h β : ℝ) (hh : 0≤h)
    (hcard : (A.card:ℝ)≤Real.exp h)
    (htail : (∑ g∈Finset.univ \ A,w g)/w target≤β) {n : ℕ} (hn : 0<n) :
    iidExpectedRisk D w good n≤(h+1)/(n:ℝ)+β*expectedUnseen D n := by
  let keep := fun s : Fin n→X => fun g => allObservations (good g) n s
  let err := fun g => eventError D (good g)
  let env := survivorEnvelope A keep err h (n:ℝ)
  have hnp : 0<(n:ℝ) := Nat.cast_pos.mpr hn
  have hmean := expected_survivorEnvelope_le (iidWeight D n) (iidWeight_nonneg D hD n)
    (iidWeight_sum D hDs n) A keep err h (n:ℝ) hnp hcard (fun g _ => by
      rw [iid_survival,event_survival_eq_one_sub_error D hDs]
      exact pow_one_sub_le_exp _ (eventError_le_one D hD hDs (good g)) n)
  have hpoint (s : Fin n→X) :
      (∑ g,posterior w (keep s) g*err g)≤env s+β*unseenProbability D s := by
    apply posterior_risk_le_unseen w hw (keep s) target (fun i => ht (s i)) hwt err A
      (env s) (unseenProbability D s) β
      (survivorEnvelope_nonneg A keep err h n hh hnp s)
      (Finset.sum_nonneg fun x _ => by split_ifs; exact hD x; exact le_refl _)
      (fun g hg => eventError_le_unseen D hD (good g) s hg)
      (fun g hg hk => error_le_survivorEnvelope A keep err h n hnp s g hg hk) htail
  calc
    _ ≤ ∑ s : Fin n→X,iidWeight D n s*(env s+β*unseenProbability D s) :=
      Finset.sum_le_sum fun s _ => mul_le_mul_of_nonneg_left (hpoint s) (iidWeight_nonneg D hD n s)
    _ = (∑ s : Fin n→X,iidWeight D n s*env s)+β*expectedUnseen D n := by
      simp_rw [mul_add]
      rw [Finset.sum_add_distrib,← expected_unseen_eq D hDs n,Finset.mul_sum]
      congr 1
      apply Finset.sum_congr rfl
      intro s _
      ring
    _ ≤ _ := add_le_add hmean le_rfl

end NeuralGeneralization.BatchTwoOnline
