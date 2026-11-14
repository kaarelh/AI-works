import NeuralGeneralization.BatchTwoGramPowerSharp
import NeuralGeneralization.BatchTwoImprovedGramSubspace

/-! Exponential Gram concentration on padded active coordinate subspaces. -/
noncomputable section
set_option autoImplicit false
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1000000
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoGramPower
open BatchTwoImprovedWeightedSampling SquaredSampling Classical
variable {D m Q : ℕ} {α : Type*} [Fintype α]

def restrictSlots (S : Finset (Fin D)) (u : Fin D→ℝ) : Fin (Fintype.card S)→ℝ :=
  fun i=>u ((Fintype.equivFin S).symm i)

def expandSlots (S : Finset (Fin D)) (u : Fin (Fintype.card S)→ℝ) : Fin D→ℝ :=
  fun j=>if h:j∈S then u ((Fintype.equivFin S) ⟨j,h⟩) else 0

theorem expandSlots_off (S : Finset (Fin D)) (u : Fin (Fintype.card S)→ℝ)
    (j : Fin D) (hj : j∉S) : expandSlots S u j=0 := by simp [expandSlots,hj]

theorem restrict_expandSlots (S : Finset (Fin D)) (u : Fin (Fintype.card S)→ℝ) :
    restrictSlots S (expandSlots S u)=u := by
  funext i
  simp [restrictSlots,expandSlots]

theorem expand_restrictSlots (S : Finset (Fin D)) (u : Fin D→ℝ)
    (hu : ∀j,j∉S→u j=0) : expandSlots S (restrictSlots S u)=u := by
  funext j
  by_cases hj : j∈S <;> simp [expandSlots,restrictSlots,hj,hu j]

theorem sum_restrictSlots (S : Finset (Fin D)) (f : Fin D→ℝ) :
    (∑i,restrictSlots S f i)=∑j∈S,f j := by
  unfold restrictSlots
  rw [(Fintype.equivFin S).symm.sum_comp (fun j:S=>f j)]
  exact Finset.sum_coe_sort S f

theorem sum_restrictSlots_zero (S : Finset (Fin D)) (f : Fin D→ℝ)
    (hf : ∀j,j∉S→f j=0) : (∑i,restrictSlots S f i)=∑j,f j := by
  rw [sum_restrictSlots]
  exact Finset.sum_subset (Finset.subset_univ S) (fun j _ hj=>hf j hj)

theorem restrictSlots_energy (S : Finset (Fin D)) (u : Fin D→ℝ) :
    (∑i,(restrictSlots S u i)^2)≤∑j,u j^2 := by
  change (∑i,restrictSlots S (fun j=>u j^2) i)≤_
  rw [sum_restrictSlots]
  exact Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ S) (fun j _ _=>sq_nonneg _)

theorem restrictSlots_energy_eq (S : Finset (Fin D)) (u : Fin D→ℝ)
    (hu : ∀j,j∉S→u j=0) : (∑i,(restrictSlots S u i)^2)=∑j,u j^2 := by
  apply sum_restrictSlots_zero S (fun j=>u j^2)
  intro j hj
  rw [hu j hj,zero_pow (by decide : (2:ℕ)≠0)]

theorem expandSlots_energy (S : Finset (Fin D)) (u : Fin (Fintype.card S)→ℝ) :
    (∑j,expandSlots S u j^2)=∑i,u i^2 := by
  have hh := restrictSlots_energy_eq S (expandSlots S u) (expandSlots_off S u)
  rw [restrict_expandSlots] at hh
  exact hh.symm

theorem restrictSlots_dot (S : Finset (Fin D)) (v : Fin D→ℝ)
    (u : Fin (Fintype.card S)→ℝ) :
    restrictSlots S v ⬝ᵥu=v ⬝ᵥexpandSlots S u := by
  have hh := sum_restrictSlots_zero S (fun j=>v j*expandSlots S u j)
    (fun j hj=>by rw [expandSlots_off S u j hj,mul_zero])
  have he : restrictSlots S (fun j=>v j*expandSlots S u j)=
      fun i=>restrictSlots S v i*u i := by
    funext i
    simp [restrictSlots,expandSlots]
  rw [he] at hh
  exact hh

theorem weighted_badGramOn_exponential (w : α→ℝ) (hw : ∀x,0≤w x)
    (hmass : ∑x,w x=1) (hm : 0<m) (hQ : 0<Q) (v : α→Fin D→ℝ)
    (S : Finset (Fin D))
    (hiso : ∀u : Fin D→ℝ,(∀j,j∉S→u j=0)→
      mean w (fun x=>(v x ⬝ᵥu)^2)=∑j,u j^2)
    (hv : ∀x,(∑j,v x j^2)≤2*(Q:ℝ)) :
    mean (iidWeight w m) (fun s=>if badGramOn v (fun u=>∀j,j∉S→u j=0) s then (1:ℝ) else 0)≤
      (S.card:ℝ)*Real.exp (-(m:ℝ)/(16*((Q:ℝ)+1))) := by
  let v' := fun x=>restrictSlots S (v x)
  have hi : Isotropic w v' := by
    intro u
    simp only [v',restrictSlots_dot]
    rw [hiso (expandSlots S u) (expandSlots_off S u),expandSlots_energy]
  have he (s : Fin m→α) (hs : badGramOn v (fun u=>∀j,j∉S→u j=0) s) : badGram v' s := by
    obtain ⟨u,hu,hunit,hsmall⟩ := hs
    refine ⟨restrictSlots S u,(restrictSlots_energy_eq S u hu).trans hunit,?_⟩
    have hh (x : α) : linearEvaluation (v' x) (restrictSlots S u)=linearEvaluation (v x) u := by
      change restrictSlots S (v x) ⬝ᵥrestrictSlots S u=v x ⬝ᵥu
      rw [restrictSlots_dot,expand_restrictSlots S u hu]
    simpa only [hh] using hsmall
  calc
    _ ≤mean (iidWeight w m) (fun s=>if badGram v' s then (1:ℝ) else 0) := by
      apply mean_mono _ (iidWeight_nonneg w hw m)
      intro s
      by_cases hs : badGramOn v (fun u=>∀j,j∉S→u j=0) s
      · simp [hs,he s hs]
      · simp only [if_neg hs]; split_ifs <;> norm_num
    _ ≤_ := by
      simpa only [Fintype.card_coe] using weighted_badGram_exponential_radius w hw hmass hm hQ v' hi
        (fun x=>(restrictSlots_energy S (v x)).trans (hv x))

end NeuralGeneralization.BatchTwoGramPower
