import NeuralGeneralization.BatchTwoNeuralConverseModel
import NeuralGeneralization.Cloning

/-! Actual block-diagonal parallel composition, including its gain certificate. -/
namespace NeuralGeneralization.BatchTwoNeuralConverse
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1000000
open scoped BigOperators
open Classical
open ConcreteModel
variable {d n m N r : ℕ}

def directWeights (e : (Fin n ⊕ Fin m) ≃ Fin N)
    (w : Weights d n r) (v : Weights d m r) : Weights d N r
  | Sum.inl (i,j) => match e.symm i with
    | Sum.inl a => w (Sum.inl (a,j))
    | Sum.inr a => v (Sum.inl (a,j))
  | Sum.inr (Sum.inl (s,i,j)) => match e.symm i,e.symm j with
    | Sum.inl a, Sum.inl b => w (Sum.inr (Sum.inl (s,a,b)))
    | Sum.inr a, Sum.inr b => v (Sum.inr (Sum.inl (s,a,b)))
    | _,_ => 0
  | Sum.inr (Sum.inr i) => match e.symm i with
    | Sum.inl a => w (Sum.inr (Sum.inr a))
    | Sum.inr a => v (Sum.inr (Sum.inr a))

def directVector (e : (Fin n ⊕ Fin m) ≃ Fin N) (h : Fin n → ℝ) (k : Fin m → ℝ) :
    Fin N → ℝ := fun i => Sum.elim h k (e.symm i)

theorem sum_direct (e : (Fin n ⊕ Fin m) ≃ Fin N) (h : Fin n → ℝ) (k : Fin m → ℝ) :
    (∑ i, directVector e h k i) = (∑ i,h i)+(∑ i,k i) := by
  unfold directVector
  rw [e.symm.sum_comp]
  simp

theorem firstHidden_direct (φ : ℝ → ℝ) (e : (Fin n ⊕ Fin m) ≃ Fin N)
    (w : Weights d n r) (v : Weights d m r) (x : Cube d) :
    firstHidden φ (directWeights e w v) x =
      directVector e (firstHidden φ w x) (firstHidden φ v x) := by
  funext i
  cases hi : e.symm i <;> simp [firstHidden,directWeights,directVector,hi]

theorem hiddenStep_direct (φ : ℝ → ℝ) (e : (Fin n ⊕ Fin m) ≃ Fin N)
    (w : Weights d n r) (v : Weights d m r) (h : Fin n → ℝ) (k : Fin m → ℝ) (s : Fin r) :
    hiddenStep φ (directWeights e w v) (directVector e h k) s =
      directVector e (hiddenStep φ w h s) (hiddenStep φ v k s) := by
  funext i
  cases hi : e.symm i with
  | inl a =>
    change φ (∑ j, _) = _
    have hs : (∑ j, directWeights e w v (Sum.inr (Sum.inl (s,i,j)))*directVector e h k j) =
        ∑ b, w (Sum.inr (Sum.inl (s,a,b)))*h b := by
      calc
        _ = ∑ j, directVector e (fun b => w (Sum.inr (Sum.inl (s,a,b)))*h b) (fun _ => 0) j := by
          apply Finset.sum_congr rfl
          intro j _
          cases hj : e.symm j <;> simp [directWeights,directVector,hi,hj]
        _ = _ := by rw [sum_direct]; simp
    rw [hs]
    simp [directVector,hi,hiddenStep]
  | inr a =>
    change φ (∑ j, _) = _
    have hs : (∑ j, directWeights e w v (Sum.inr (Sum.inl (s,i,j)))*directVector e h k j) =
        ∑ b, v (Sum.inr (Sum.inl (s,a,b)))*k b := by
      calc
        _ = ∑ j, directVector e (fun _ => 0) (fun b => v (Sum.inr (Sum.inl (s,a,b)))*k b) j := by
          apply Finset.sum_congr rfl
          intro j _
          cases hj : e.symm j <;> simp [directWeights,directVector,hi,hj]
        _ = _ := by rw [sum_direct]; simp
    rw [hs]
    simp [directVector,hi,hiddenStep]

theorem hiddenFold_direct (φ : ℝ → ℝ) (e : (Fin n ⊕ Fin m) ≃ Fin N)
    (w : Weights d n r) (v : Weights d m r) (ss : List (Fin r))
    (h : Fin n → ℝ) (k : Fin m → ℝ) :
    ss.foldl (hiddenStep φ (directWeights e w v)) (directVector e h k) =
      directVector e (ss.foldl (hiddenStep φ w) h) (ss.foldl (hiddenStep φ v) k) := by
  induction ss generalizing h k with
  | nil => rfl
  | cons s ss ih => simp only [List.foldl_cons, hiddenStep_direct]; exact ih _ _

theorem networkOutput_direct (φ : ℝ → ℝ) (e : (Fin n ⊕ Fin m) ≃ Fin N)
    (w : Weights d n r) (v : Weights d m r) (x : Cube d) :
    networkOutput φ (directWeights e w v) x = networkOutput φ w x+networkOutput φ v x := by
  have hf : finalHidden φ (directWeights e w v) x =
      directVector e (finalHidden φ w x) (finalHidden φ v x) := by
    unfold finalHidden
    rw [firstHidden_direct,hiddenFold_direct]
  unfold networkOutput
  rw [hf]
  calc
    _ = ∑ i, directVector e
        (fun a => w (Sum.inr (Sum.inr a))*finalHidden φ w x a)
        (fun a => v (Sum.inr (Sum.inr a))*finalHidden φ v x a) i := by
      apply Finset.sum_congr rfl
      intro i _
      cases hi : e.symm i <;> simp [directWeights,directVector,hi]
    _ = _ := sum_direct e _ _


def leftSlopes (e : (Fin n ⊕ Fin m) ≃ Fin N) (D : Slopes N r) : Slopes n r :=
  fun s i => D s (e (Sum.inl i))
def rightSlopes (e : (Fin n ⊕ Fin m) ≃ Fin N) (D : Slopes N r) : Slopes m r :=
  fun s i => D s (e (Sum.inr i))

theorem leftSlopes_mem (e : (Fin n ⊕ Fin m) ≃ Fin N) (D : Slopes N r)
    (hD : D ∈ slopeCube N r) : leftSlopes e D ∈ slopeCube n r :=
  ⟨fun s i => hD.1 s _,fun s i => hD.2 s _⟩
theorem rightSlopes_mem (e : (Fin n ⊕ Fin m) ≃ Fin N) (D : Slopes N r)
    (hD : D ∈ slopeCube N r) : rightSlopes e D ∈ slopeCube m r :=
  ⟨fun s i => hD.1 s _,fun s i => hD.2 s _⟩

theorem pathRow_direct (e : (Fin n ⊕ Fin m) ≃ Fin N)
    (w : Weights d n r) (v : Weights d m r) (D : Slopes N r) (ss : List (Fin r)) :
    pathRow (directWeights e w v) D ss =
      directVector e (pathRow w (leftSlopes e D) ss) (pathRow v (rightSlopes e D) ss) := by
  induction ss with
  | nil =>
    funext i
    cases hi : e.symm i <;> simp [pathRow,directWeights,directVector,hi]
  | cons s ss ih =>
    funext i
    simp only [pathRow,ih]
    cases hi : e.symm i with
    | inl a =>
      calc
        _ = ∑ j, directVector e
            (fun b => pathRow w (leftSlopes e D) ss b*leftSlopes e D s b*
              w (Sum.inr (Sum.inl (s,b,a)))) (fun _ => 0) j := by
          apply Finset.sum_congr rfl
          intro j _
          cases hj : e.symm j with
          | inl b =>
            have he : j=e (Sum.inl b) := by simpa using congrArg e hj
            simp [directVector,directWeights,hi,hj,leftSlopes,←he]
          | inr b => simp [directVector,directWeights,hi,hj]
        _ = _ := by rw [sum_direct]; simp [directVector,hi]
    | inr a =>
      calc
        _ = ∑ j, directVector e (fun _ => 0)
            (fun b => pathRow v (rightSlopes e D) ss b*rightSlopes e D s b*
              v (Sum.inr (Sum.inl (s,b,a)))) j := by
          apply Finset.sum_congr rfl
          intro j _
          cases hj : e.symm j with
          | inl b => simp [directVector,directWeights,hi,hj]
          | inr b =>
            have he : j=e (Sum.inr b) := by simpa using congrArg e hj
            simp [directVector,directWeights,hi,hj,rightSlopes,←he]
        _ = _ := by rw [sum_direct]; simp [directVector,hi]

theorem square_sum_direct (e : (Fin n ⊕ Fin m) ≃ Fin N) (h : Fin n → ℝ) (k : Fin m → ℝ) :
    (∑ i, (directVector e h k i)^2) = (∑ i, (h i)^2)+(∑ i, (k i)^2) := by
  calc
    _ = ∑ i, directVector e (fun a => (h a)^2) (fun a => (k a)^2) i := by
      apply Finset.sum_congr rfl
      intro i _
      cases hi : e.symm i <;> simp [directVector,hi]
    _ = _ := sum_direct e _ _

theorem gainEnergy_direct (hn : 0<n) (hm : 0<m) (e : (Fin n ⊕ Fin m) ≃ Fin N)
    (w : Weights d n r) (v : Weights d m r) (D : Slopes N r) :
    gainEnergy (directWeights e w v) D =
      (N : ℝ)/n*gainEnergy w (leftSlopes e D)+(N : ℝ)/m*gainEnergy v (rightSlopes e D) := by
  have hnR : (n : ℝ)≠0 := by exact_mod_cast hn.ne'
  have hmR : (m : ℝ)≠0 := by exact_mod_cast hm.ne'
  unfold gainEnergy
  simp_rw [pathRow_direct,square_sum_direct]
  rw [Finset.sum_add_distrib]
  field_simp

theorem gainSq_direct_le (hn : 0<n) (hm : 0<m) (e : (Fin n ⊕ Fin m) ≃ Fin N)
    (w : Weights d n r) (v : Weights d m r) :
    gainSq (directWeights e w v) ≤ (N : ℝ)/n*gainSq w+(N : ℝ)/m*gainSq v := by
  change sSup (gainEnergy (directWeights e w v) '' slopeCube N r) ≤ _
  apply csSup_le ((slopeCube_nonempty N r).image _)
  rintro _ ⟨D,hD,rfl⟩
  rw [gainEnergy_direct hn hm]
  exact add_le_add
    (mul_le_mul_of_nonneg_left (gainEnergy_le_gainSq w _ (leftSlopes_mem e D hD)) (by positivity))
    (mul_le_mul_of_nonneg_left (gainEnergy_le_gainSq v _ (rightSlopes_mem e D hD)) (by positivity))

theorem readoutEnergy_direct (hn : 0<n) (hm : 0<m) (e : (Fin n ⊕ Fin m) ≃ Fin N)
    (w : Weights d n r) (v : Weights d m r) :
    readoutEnergy (directWeights e w v) =
      (N : ℝ)/n*readoutEnergy w+(N : ℝ)/m*readoutEnergy v := by
  have hnR : (n : ℝ)≠0 := by exact_mod_cast hn.ne'
  have hmR : (m : ℝ)≠0 := by exact_mod_cast hm.ne'
  have hrow : (fun i => directWeights e w v (Sum.inr (Sum.inr i))) =
      directVector e (fun i => w (Sum.inr (Sum.inr i))) (fun i => v (Sum.inr (Sum.inr i))) := by
    funext i
    cases hi : e.symm i <;> simp [directWeights,directVector,hi]
  unfold readoutEnergy
  simp_rw [show ∀ i, directWeights e w v (Sum.inr (Sum.inr i)) =
    directVector e (fun i => w (Sum.inr (Sum.inr i))) (fun i => v (Sum.inr (Sum.inr i))) i from congrFun hrow]
  rw [square_sum_direct]
  field_simp

theorem gain_strict_direct (hn : 0<n) (hm : 0<m) (hN : 0<N)
    (e : (Fin n ⊕ Fin m) ≃ Fin N) (w : Weights d n r) (v : Weights d m r)
    (Λ : ℝ) (hw : gainSq w < Λ^2*((r : ℝ)+1)*readoutEnergy w)
    (hv : gainSq v < Λ^2*((r : ℝ)+1)*readoutEnergy v) :
    gainSq (directWeights e w v) < Λ^2*((r : ℝ)+1)*readoutEnergy (directWeights e w v) := by
  have hnR : (0 : ℝ)<n := by exact_mod_cast hn
  have hmR : (0 : ℝ)<m := by exact_mod_cast hm
  have hNR : (0 : ℝ)<N := by exact_mod_cast hN
  have h1 := mul_lt_mul_of_pos_left hw (div_pos hNR hnR)
  have h2 := mul_lt_mul_of_pos_left hv (div_pos hNR hmR)
  have hg := gainSq_direct_le hn hm e w v
  rw [readoutEnergy_direct hn hm]
  nlinarith


theorem first_squaredSum_direct (e : (Fin n ⊕ Fin m) ≃ Fin N)
    (w : Weights d n r) (v : Weights d m r) :
    (∑ i, ∑ j, (directWeights e w v (Sum.inl (i,j)))^2) =
      (∑ i, ∑ j, (w (Sum.inl (i,j)))^2)+(∑ i, ∑ j, (v (Sum.inl (i,j)))^2) := by
  calc
    _ = ∑ i, directVector e (fun a => ∑ j, (w (Sum.inl (a,j)))^2)
        (fun a => ∑ j, (v (Sum.inl (a,j)))^2) i := by
      apply Finset.sum_congr rfl
      intro i _
      cases hi : e.symm i <;> simp [directWeights,directVector,hi]
    _ = _ := sum_direct e _ _

theorem internal_squaredSum_direct (e : (Fin n ⊕ Fin m) ≃ Fin N)
    (w : Weights d n r) (v : Weights d m r) (s : Fin r) :
    (∑ i, ∑ j, (directWeights e w v (Sum.inr (Sum.inl (s,i,j))))^2) =
      (∑ i, ∑ j, (w (Sum.inr (Sum.inl (s,i,j))))^2)+
      (∑ i, ∑ j, (v (Sum.inr (Sum.inl (s,i,j))))^2) := by
  have hrow (i : Fin N) :
      (∑ j, (directWeights e w v (Sum.inr (Sum.inl (s,i,j))))^2) =
      directVector e (fun a => ∑ j, (w (Sum.inr (Sum.inl (s,a,j))))^2)
        (fun a => ∑ j, (v (Sum.inr (Sum.inl (s,a,j))))^2) i := by
    cases hi : e.symm i with
    | inl a =>
      calc
        _ = ∑ j, directVector e (fun b => (w (Sum.inr (Sum.inl (s,a,b))))^2) (fun _ => 0) j := by
          apply Finset.sum_congr rfl
          intro j _
          cases hj : e.symm j <;> simp [directWeights,directVector,hi,hj]
        _ = _ := by rw [sum_direct]; simp [directVector,hi]
    | inr a =>
      calc
        _ = ∑ j, directVector e (fun _ => 0) (fun b => (v (Sum.inr (Sum.inl (s,a,b))))^2) j := by
          apply Finset.sum_congr rfl
          intro j _
          cases hj : e.symm j <;> simp [directWeights,directVector,hi,hj]
        _ = _ := by rw [sum_direct]; simp [directVector,hi]
  simp_rw [hrow]
  exact sum_direct e _ _

theorem first_coefficient_le {a b c : ℝ} (ha : 0≤a) (hb : 0<b) (hbc : b≤c) :
    a/c ≤ (c/b)*(a/b) := by
  have hc : 0<c := hb.trans_le hbc
  apply (div_le_iff₀ hc).mpr
  have h1 : 1≤c/b := (le_div_iff₀ hb).mpr (by simpa)
  have h2 : a≤(c/b)*a := by nlinarith
  have he : (c/b)*(a/b)*c=(c/b)*((c/b)*a) := by ring
  rw [he]
  exact h2.trans (by nlinarith)

theorem weightedSquaredNorm_direct_le (hn : 0<n) (hm : 0<m)
    (hnN : n≤N) (hmN : m≤N) (e : (Fin n ⊕ Fin m) ≃ Fin N)
    (w : Weights d n r) (v : Weights d m r) :
    weightedSquaredNorm (directWeights e w v) ≤
      (N : ℝ)/n*weightedSquaredNorm w+(N : ℝ)/m*weightedSquaredNorm v := by
  have hnR : (0 : ℝ)<n := by exact_mod_cast hn
  have hmR : (0 : ℝ)<m := by exact_mod_cast hm
  have hnNR : (n : ℝ)≤N := by exact_mod_cast hnN
  have hmNR : (m : ℝ)≤N := by exact_mod_cast hmN
  have h1 : (1 : ℝ)≤N/n := (le_div_iff₀ hnR).mpr (by simpa)
  have h2 : (1 : ℝ)≤N/m := (le_div_iff₀ hmR).mpr (by simpa)
  have hfw := mul_le_mul_of_nonneg_right (first_coefficient_le (Nat.cast_nonneg d) hnR hnNR)
    (show 0≤∑ i, ∑ j, (w (Sum.inl (i,j)))^2 by positivity)
  have hfv := mul_le_mul_of_nonneg_right (first_coefficient_le (Nat.cast_nonneg d) hmR hmNR)
    (show 0≤∑ i, ∑ j, (v (Sum.inl (i,j)))^2 by positivity)
  have hiw := mul_le_mul_of_nonneg_right h1
    (show 0≤∑ s, ∑ i, ∑ j, (w (Sum.inr (Sum.inl (s,i,j))))^2 by positivity)
  have hiv := mul_le_mul_of_nonneg_right h2
    (show 0≤∑ s, ∑ i, ∑ j, (v (Sum.inr (Sum.inl (s,i,j))))^2 by positivity)
  have hr := readoutEnergy_direct hn hm e w v
  unfold readoutEnergy at hr
  unfold weightedSquaredNorm
  rw [first_squaredSum_direct]
  simp_rw [internal_squaredSum_direct]
  rw [Finset.sum_add_distrib]
  nlinarith

end
end NeuralGeneralization.BatchTwoNeuralConverse
