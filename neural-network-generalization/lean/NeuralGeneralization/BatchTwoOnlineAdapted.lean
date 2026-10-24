import NeuralGeneralization.BatchTwoOnlineExponential

/-!
# Exponential bounds for adapted losses under uniform random order

Conditional averaging is implemented explicitly by swaps of the next
position with each remaining position. No conditional expectation or
supermartingale property is assumed of the posterior.
-/
noncomputable section
open scoped BigOperators
open Classical
attribute [local instance] Classical.propDecidable

namespace NeuralGeneralization.BatchTwoOnline
open SquaredSampling

variable {m : ℕ}

def remainingAverage (F : Equiv.Perm (Fin m) → ℝ) (i : Fin m)
    (π : Equiv.Perm (Fin m)) : ℝ :=
  (∑ j : Fin m, if i.val ≤ j.val then F (π * Equiv.swap i j) else 0) / (m-i.val : ℕ)

lemma remainingAverage_const (c : ℝ) (i : Fin m) (π : Equiv.Perm (Fin m)) :
    remainingAverage (fun _ => c) i π = c := by
  unfold remainingAverage
  have hs : (∑ j : Fin m, if i.val ≤ j.val then c else 0) = (m-i.val : ℕ)*c := by
    rw [← remaining_count i.val i.isLt.le, Finset.sum_mul]
    apply Finset.sum_congr rfl
    intro j _
    split_ifs <;> simp
  rw [hs]
  have hd' : ((m-i.val : ℕ) : ℝ) ≠ 0 := by exact_mod_cast (Nat.ne_of_gt (Nat.sub_pos_of_lt i.isLt))
  exact mul_div_cancel_left₀ c hd'

lemma remainingAverage_mono {F G : Equiv.Perm (Fin m) → ℝ}
    (h : ∀ π, F π ≤ G π) (i : Fin m) (π : Equiv.Perm (Fin m)) :
    remainingAverage F i π ≤ remainingAverage G i π := by
  apply div_le_div_of_nonneg_right _ (Nat.cast_nonneg _)
  apply Finset.sum_le_sum
  intro j _
  split_ifs
  · exact h _
  · exact le_rfl

lemma remainingAverage_add (F G : Equiv.Perm (Fin m) → ℝ)
    (i : Fin m) (π : Equiv.Perm (Fin m)) :
    remainingAverage (fun ρ => F ρ+G ρ) i π = remainingAverage F i π + remainingAverage G i π := by
  unfold remainingAverage
  rw [← add_div, ← Finset.sum_add_distrib]
  congr 1
  apply Finset.sum_congr rfl
  intro j _
  split_ifs <;> simp

lemma remainingAverage_mul (c : ℝ) (F : Equiv.Perm (Fin m) → ℝ)
    (i : Fin m) (π : Equiv.Perm (Fin m)) :
    remainingAverage (fun ρ => c*F ρ) i π = c*remainingAverage F i π := by
  unfold remainingAverage
  rw [← mul_div_assoc, Finset.mul_sum]
  congr 1
  apply Finset.sum_congr rfl
  intro j _
  split_ifs <;> simp

lemma finiteMean_div {Ω : Type*} [Fintype Ω] (F : Ω → ℝ) (c : ℝ) :
    finiteMean (fun ω => F ω/c) = finiteMean F/c := by
  unfold finiteMean
  rw [← Finset.sum_div]
  ring

/-- The exact averaging identity with any quantity determined by the past.
The only invariance premise concerns that predictable multiplier. -/
theorem weighted_remainingAverage
    (F G : Equiv.Perm (Fin m) → ℝ) (i : Fin m)
    (hF : ∀ π j, i.val ≤ j.val → F (π*Equiv.swap i j)=F π) :
    finiteMean (fun π => F π*G π) =
      finiteMean (fun π => F π*remainingAverage G i π) := by
  have he (j : Fin m) (hj : i.val ≤ j.val) :
      finiteMean (fun π => F π*G (π*Equiv.swap i j)) = finiteMean (fun π => F π*G π) := by
    have h := finiteMean_equiv (Equiv.mulRight (Equiv.swap i j)) (fun π => F π*G π)
    change finiteMean (fun π => F (π*Equiv.swap i j)*G (π*Equiv.swap i j)) = _ at h
    simp_rw [hF _ j hj] at h
    exact h
  have hd : ((m-i.val : ℕ) : ℝ) ≠ 0 := by exact_mod_cast (Nat.ne_of_gt (Nat.sub_pos_of_lt i.isLt))
  symm
  unfold remainingAverage
  simp_rw [← mul_div_assoc, Finset.mul_sum]
  rw [finiteMean_div, finiteMean_sum]
  have hs (j : Fin m) :
      finiteMean (fun π => F π*(if i.val ≤ j.val then G (π*Equiv.swap i j) else 0)) =
      (if i.val ≤ j.val then 1 else 0)*finiteMean (fun π => F π*G π) := by
    by_cases hj : i.val ≤ j.val
    · simp only [hj, if_true, one_mul]
      exact he j hj
    · simp [hj]
  simp_rw [hs]
  rw [← Finset.sum_mul, remaining_count i.val i.isLt.le]
  exact mul_div_cancel_left₀ _ hd

/-- Prefix sums are defined on the fixed finite permutation space. -/
def adaptedPrefix (Y : Fin m → Equiv.Perm (Fin m) → ℝ) (n : ℕ)
    (π : Equiv.Perm (Fin m)) : ℝ := ∑ i : Fin m, if i.val<n then Y i π else 0

lemma adaptedPrefix_zero (Y : Fin m → Equiv.Perm (Fin m) → ℝ) (π) :
    adaptedPrefix Y 0 π = 0 := by simp [adaptedPrefix]

lemma adaptedPrefix_succ (Y : Fin m → Equiv.Perm (Fin m) → ℝ) (n : ℕ) (hn : n<m) (π) :
    adaptedPrefix Y (n+1) π = adaptedPrefix Y n π + Y ⟨n,hn⟩ π := by
  have ht (i : Fin m) : (if i.val<n+1 then Y i π else 0) =
      (if i.val<n then Y i π else 0)+(if i=⟨n,hn⟩ then Y i π else 0) := by
    by_cases hi : i.val<n
    · have hi' : i≠⟨n,hn⟩ := by intro h; subst i; simp at hi
      simp [hi, hi', Nat.lt_succ_of_lt hi]
    · by_cases he : i=⟨n,hn⟩
      · subst i; simp
      · have hge : ¬i.val<n+1 := by
          intro h
          apply he
          apply Fin.ext
          change i.val = n
          omega
        simp [hi, he, hge]
  unfold adaptedPrefix
  simp_rw [ht]
  rw [Finset.sum_add_distrib]
  simp

lemma adaptedPrefix_all (Y : Fin m → Equiv.Perm (Fin m) → ℝ) (π) :
    adaptedPrefix Y m π = ∑ i, Y i π := by
  unfold adaptedPrefix
  apply Finset.sum_congr rfl
  intro i _
  simp [i.isLt]

/-- Finite adapted exponential inequality on the actual uniform permutation
space. The next-loss expectation is the explicit average over unseen inputs. -/
theorem adapted_exponential_bound
    (Y : Fin m → Equiv.Perm (Fin m) → ℝ) (b : Fin m → ℝ)
    (hY : ∀ i π, 0 ≤ Y i π ∧ Y i π ≤ 1)
    (hadapt : ∀ i k j π, i.val<k.val → k.val≤j.val →
      Y i (π*Equiv.swap k j)=Y i π)
    (hmean : ∀ i π, remainingAverage (Y i) i π ≤ b i) :
    finiteMean (fun π => Real.exp (∑ i, Y i π)) ≤
      Real.exp ((Real.exp 1-1)*(∑ i, b i)) := by
  have hc : 0 ≤ Real.exp 1-1 := by linarith [Real.add_one_le_exp (1 : ℝ)]
  have hstep (i : Fin m) (π) : remainingAverage (fun ρ => Real.exp (Y i ρ)) i π ≤
      Real.exp ((Real.exp 1-1)*b i) := by
    calc
      _ ≤ remainingAverage (fun ρ => 1+(Real.exp 1-1)*Y i ρ) i π :=
        remainingAverage_mono (fun ρ => exp_unit_interval_le _ (hY i ρ).1 (hY i ρ).2) i π
      _ = 1+(Real.exp 1-1)*remainingAverage (Y i) i π := by
        rw [remainingAverage_add, remainingAverage_const, remainingAverage_mul]
      _ ≤ 1+(Real.exp 1-1)*b i := add_le_add le_rfl (mul_le_mul_of_nonneg_left (hmean i π) hc)
      _ ≤ _ := by linarith [Real.add_one_le_exp ((Real.exp 1-1)*b i)]
  have hprefix : ∀ n, n≤m → finiteMean (fun π => Real.exp (adaptedPrefix Y n π)) ≤
      Real.exp ((Real.exp 1-1)*adaptedPrefix (fun i _ => b i) n (Equiv.refl _)) := by
    intro n
    induction n with
    | zero => intro _; simp [adaptedPrefix_zero]
    | succ n ih =>
      intro hn
      have hnm : n<m := by omega
      let i : Fin m := ⟨n,hnm⟩
      have hF : ∀ π j, i.val≤j.val →
          Real.exp (adaptedPrefix Y n (π*Equiv.swap i j)) = Real.exp (adaptedPrefix Y n π) := by
        intro π j hj
        congr 1
        unfold adaptedPrefix
        apply Finset.sum_congr rfl
        intro k _
        split_ifs with hk
        · exact hadapt k i j π hk hj
        · rfl
      simp_rw [adaptedPrefix_succ Y n hnm, Real.exp_add]
      rw [weighted_remainingAverage _ _ i hF]
      calc
        _ ≤ finiteMean (fun π => Real.exp (adaptedPrefix Y n π)*
            Real.exp ((Real.exp 1-1)*b i)) :=
          finiteMean_mono fun π => mul_le_mul_of_nonneg_left (hstep i π) (Real.exp_pos _).le
        _ = Real.exp ((Real.exp 1-1)*b i) *
            finiteMean (fun π => Real.exp (adaptedPrefix Y n π)) := by
          simp_rw [mul_comm _ (Real.exp ((Real.exp 1-1)*b i))]
          rw [finiteMean_mul]
        _ ≤ Real.exp ((Real.exp 1-1)*b i) *
            Real.exp ((Real.exp 1-1)*adaptedPrefix (fun i _ => b i) n (Equiv.refl _)) :=
          mul_le_mul_of_nonneg_left (ih (by omega)) (Real.exp_pos _).le
        _ = _ := by
          rw [adaptedPrefix_succ _ n hnm, ← Real.exp_add]
          congr 1
          change _ = (Real.exp 1-1)*(_+b i)
          ring
  simpa only [adaptedPrefix_all] using hprefix m le_rfl

/-- The same adapted induction with the one-step exponential estimate supplied
explicitly. This form also handles the exact Bernoulli posterior-draw factor. -/
theorem adapted_exp_bound_of_step
    (Y : Fin m → Equiv.Perm (Fin m) → ℝ) (b : Fin m → ℝ)
    (hadapt : ∀ i k j π, i.val < k.val → k.val ≤ j.val →
      Y i (π*Equiv.swap k j)=Y i π)
    (hstep : ∀ i π, remainingAverage (fun ρ => Real.exp (Y i ρ)) i π ≤ Real.exp (b i)) :
    finiteMean (fun π => Real.exp (∑ i, Y i π)) ≤ Real.exp (∑ i, b i) := by
  have hprefix : ∀ n, n ≤ m → finiteMean (fun π => Real.exp (adaptedPrefix Y n π)) ≤
      Real.exp (adaptedPrefix (fun i _ => b i) n (Equiv.refl _)) := by
    intro n
    induction n with
    | zero => intro _; simp [adaptedPrefix_zero]
    | succ n ih =>
      intro hn
      have hnm : n < m := by omega
      let i : Fin m := ⟨n,hnm⟩
      have hF : ∀ π j, i.val ≤ j.val →
          Real.exp (adaptedPrefix Y n (π*Equiv.swap i j)) = Real.exp (adaptedPrefix Y n π) := by
        intro π j hj
        congr 1
        unfold adaptedPrefix
        apply Finset.sum_congr rfl
        intro k _
        split_ifs with hk
        · exact hadapt k i j π hk hj
        · rfl
      simp_rw [adaptedPrefix_succ Y n hnm, Real.exp_add]
      rw [weighted_remainingAverage _ _ i hF]
      calc
        _ ≤ finiteMean (fun π => Real.exp (adaptedPrefix Y n π)*Real.exp (b i)) :=
          finiteMean_mono fun π => mul_le_mul_of_nonneg_left (hstep i π) (Real.exp_pos _).le
        _ = Real.exp (b i)*finiteMean (fun π => Real.exp (adaptedPrefix Y n π)) := by
          simp_rw [mul_comm _ (Real.exp (b i))]
          rw [finiteMean_mul]
        _ ≤ Real.exp (b i)*Real.exp (adaptedPrefix (fun i _ => b i) n (Equiv.refl _)) :=
          mul_le_mul_of_nonneg_left (ih (by omega)) (Real.exp_pos _).le
        _ = _ := by
          rw [adaptedPrefix_succ _ n hnm, ← Real.exp_add]
          congr 1
          change b i+_ = _+b i
          ring
  simpa only [adaptedPrefix_all] using hprefix m le_rfl

end NeuralGeneralization.BatchTwoOnline
