import NeuralGeneralization.OnlineLowerTanhEqualityIntrinsic

/-! # Odd-harmonic and real-defect corollaries of the unrestricted equality theorem

The global theorem yields these paper results directly. In particular, the
real-defect conclusion does not require a separate compact-box expansion.
-/
noncomputable section
open scoped BigOperators Topology Classical
namespace NeuralGeneralization.OnlineLowerTanh

/-- The paper's odd-harmonic theorem, with no bound on their count or sizes.
Equality is possible only for all first harmonics at the balanced gain. -/
theorem exists_odd_harmonic_equality_threshold :
    ∃n₀:ℕ,∀n:ℕ,n₀≤n → Odd n → ∀a:ℝ,1≤a → a≤2 →
      ∀r:Fin n→ℤ,(∀i,0<r i) → (∀i,Odd (r i)) →
      intrinsicGain (fun i=>a*(r i:ℝ))≤1/balancedCost (n/2) ∧
      (intrinsicGain (fun i=>a*(r i:ℝ))=1/balancedCost (n/2) ↔
        a=balancedGain (n/2) ∧ ∀i,r i=1) := by
  obtain ⟨N,hclass⟩:=exists_intrinsic_gain_equality_threshold
  refine ⟨N,?_⟩
  intro n hn hodd a ha ha2 r hr hrodd
  have hc:=hclass n hn hodd (fun i=>a*(r i:ℝ))
  refine ⟨hc.1,?_⟩
  constructor
  · intro heq
    have he:=hc.2.mp heq
    have hone:∀i,r i=1:=by
      intro i
      have hrR:(0:ℝ)<r i:=by exact_mod_cast hr i
      have hai:0<a*(r i:ℝ):=mul_pos (by linarith) hrR
      have hv:=he i
      rw [abs_of_pos hai] at hv
      have hbg:balancedGain (n/2)≤2:=(balancedGain_mem _).2
      have hri:(r i:ℝ)≤2:=by nlinarith
      have hriZ:r i≤2:=by exact_mod_cast hri
      obtain ⟨z,hz⟩:=hrodd i
      have hpos:=hr i
      omega
    have hnpos:0<n:=by obtain ⟨j,hj⟩:=hodd;omega
    have hfirst:=he ⟨0,hnpos⟩
    rw [hone] at hfirst
    simp only [Int.cast_one,mul_one,abs_of_nonneg (show 0≤a by linarith)] at hfirst
    exact ⟨hfirst,hone⟩
  · rintro ⟨rfl,hone⟩
    apply hc.2.mpr
    intro i
    rw [hone]
    simp only [Int.cast_one,mul_one,abs_of_pos (balancedGain_pos _)]

/-- Signed harmonic version: arbitrary signs are allowed and equality
requires the absolute harmonic integer to be one at every coordinate. -/
theorem exists_signed_odd_harmonic_equality_threshold :
    ∃n₀:ℕ,∀n:ℕ,n₀≤n → Odd n → ∀a:ℝ,1≤a → a≤2 →
      ∀r:Fin n→ℤ,(∀i,Odd (r i)) →
      intrinsicGain (fun i=>a*(r i:ℝ))≤1/balancedCost (n/2) ∧
      (intrinsicGain (fun i=>a*(r i:ℝ))=1/balancedCost (n/2) ↔
        a=balancedGain (n/2) ∧ ∀i,|r i|=1) := by
  obtain ⟨N,hclass⟩:=exists_intrinsic_gain_equality_threshold
  refine ⟨N,?_⟩
  intro n hn hodd a ha ha2 r hrodd
  have hc:=hclass n hn hodd (fun i=>a*(r i:ℝ))
  refine ⟨hc.1,?_⟩
  constructor
  · intro heq
    have he:=hc.2.mp heq
    have hone:∀i,|r i|=1:=by
      intro i
      have hv:=he i
      rw [abs_mul,abs_of_nonneg (show 0≤a by linarith)] at hv
      have hbg:balancedGain (n/2)≤2:=(balancedGain_mem _).2
      have hri:|(r i:ℝ)|≤2:=by nlinarith [abs_nonneg (r i:ℝ)]
      have hriZ:|r i|≤(2:ℤ):=by exact_mod_cast hri
      obtain ⟨z,hz⟩:=hrodd i
      obtain ⟨hlo,hhi⟩:=abs_le.mp hriZ
      have hr:r i=1 ∨ r i= -1:=by omega
      rcases hr with hr|hr <;> rw [hr] <;> norm_num
    have hnpos:0<n:=by obtain ⟨j,hj⟩:=hodd;omega
    have hfirst:=he ⟨0,hnpos⟩
    rw [abs_mul,abs_of_nonneg (show 0≤a by linarith)] at hfirst
    have hfirstR:|(r ⟨0,hnpos⟩:ℝ)|=1:=by exact_mod_cast hone ⟨0,hnpos⟩
    rw [hfirstR,mul_one] at hfirst
    exact ⟨hfirst,hone⟩
  · rintro ⟨rfl,hone⟩
    apply hc.2.mpr
    intro i
    rw [abs_mul,abs_of_pos (balancedGain_pos _)]
    have hi:|(r i:ℝ)|=1:=by exact_mod_cast hone i
    rw [hi,mul_one]

/-- A stronger form of the paper's fixed-real-defect result: at every
sufficiently large odd degree, an arbitrary nonempty exactly equal positive
bulk and arbitrary real complementary coordinates attain the optimum iff all
magnitudes equal the unique balanced gain. No bound on the defect count or
its coordinate values is needed once the unrestricted theorem is available. -/
theorem exists_real_defect_equality_threshold :
    ∃n₀:ℕ,∀n:ℕ,n₀≤n → Odd n → ∀u:Fin n→ℝ,
      ∀I:Finset (Fin n),I.Nonempty → ∀a:ℝ,0<a → (∀i∈I,u i=a) →
      intrinsicGain u≤1/balancedCost (n/2) ∧
      (intrinsicGain u=1/balancedCost (n/2) ↔
        a=balancedGain (n/2) ∧ ∀i,i∉I → |u i|=balancedGain (n/2)) := by
  obtain ⟨N,hclass⟩:=exists_intrinsic_gain_equality_threshold
  refine ⟨N,?_⟩
  intro n hn hodd u I hI a ha hbulk
  have hc:=hclass n hn hodd u
  refine ⟨hc.1,?_⟩
  constructor
  · intro heq
    have he:=hc.2.mp heq
    obtain ⟨i,hi⟩:=hI
    have hgain:=he i
    rw [hbulk i hi,abs_of_pos ha] at hgain
    exact ⟨hgain,fun j _=>he j⟩
  · rintro ⟨hgain,hout⟩
    apply hc.2.mpr
    intro i
    by_cases hi:i∈I
    · rw [hbulk i hi,abs_of_pos ha,hgain]
    · exact hout i hi

/-- The compact defect slice used in the paper; `I` indexes its equal bulk. -/
def boundedRealDefectSlice {n : ℕ} (I : Finset (Fin n)) (B : ℝ) : Set (Fin n → ℝ) :=
  {u | ∃ a ∈ Set.Icc (1:ℝ) 2,
    (∀ i ∈ I, u i = a) ∧ ∀ i, i ∉ I → u i ∈ Set.Icc (-B) B}

/-- Literal attainment of the fixed-real-defect maximum. The threshold here
is independent even of the defect count and of the bounding box. -/
theorem exists_bounded_real_defect_maximum_threshold :
    ∃ n₀ : ℕ, ∀ n : ℕ, n₀ ≤ n → Odd n →
      ∀ I : Finset (Fin n), ∀ B : ℝ, 2 < B →
      (fun _ : Fin n => balancedGain (n/2)) ∈ boundedRealDefectSlice I B ∧
      intrinsicGain (fun _ : Fin n => balancedGain (n/2)) = 1/balancedCost (n/2) ∧
      ∀ u ∈ boundedRealDefectSlice I B,
        intrinsicGain u ≤ 1/balancedCost (n/2) ∧
        (intrinsicGain u = 1/balancedCost (n/2) ↔
          ∀ i, |u i| = balancedGain (n/2)) := by
  obtain ⟨N,hclass⟩ := exists_intrinsic_gain_equality_threshold
  refine ⟨N,?_⟩
  intro n hn hodd I B hB
  refine ⟨?_, ?_, fun u _ => hclass n hn hodd u⟩
  · refine ⟨balancedGain (n/2), balancedGain_mem _, (fun _ _ => rfl), ?_⟩
    intro i hi
    have hm := balancedGain_mem (n/2)
    exact ⟨by linarith [hm.1], by linarith [hm.2]⟩
  · apply (hclass n hn hodd _).2.mpr
    intro i
    exact abs_of_pos (balancedGain_pos _)

end NeuralGeneralization.OnlineLowerTanh
