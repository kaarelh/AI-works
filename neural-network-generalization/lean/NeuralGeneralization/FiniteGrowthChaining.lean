import NeuralGeneralization.GreedyGrowthTree
import NeuralGeneralization.ShrinkPathBudget
import NeuralGeneralization.ChainingEntropyBudget

/-!
# A proved finite growth-functional chaining theorem

The approximation tree, geometric charging argument, and entropy budget
are constructed in the imported files. This module joins them to the
actual finite Rademacher expectation bound.
-/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
namespace NeuralGeneralization.GrowthChaining
open GrowthTree GrowthCover GrowthPath SquaredSampling
open Classical
attribute [local instance] Classical.propDecidable

variable {U : Type*} [DecidableEq U]

theorem actual_path_budget (δ : U → U → ℝ) (hdiag : ∀ x, δ x x = 0)
    (hsymm : ∀ x y, δ x y = δ y x) (htri : ∀ x y z, δ x z ≤ 4*(δ x y+δ y z))
    (F : ℕ → Finset U → ℝ) (hmono : ∀ h, Monotone (F h))
    (hanti : ∀ C, Antitone (fun h => F h C)) (hF : ∀ h C, 0 ≤ F h C)
    (c : ℝ) (hc : 0 < c)
    (hgrowth : ∀ h, GrowthAt δ (F (h+1)) (F h) (branching h) c ((2 : ℝ)^h))
    (D : ℝ) (hD : 0 < D) (x₀ : U) (C : Finset U)
    (hdiam : ∀ x ∈ C, ∀ y ∈ C, δ x y ≤ D) (B : ℝ) (hB : F 0 C ≤ B)
    (x : U) (hx : x ∈ C) (L : ℕ) :
    (∑ h ∈ Finset.range L, (2 : ℝ)^h * scale D (path δ F branching D x₀ C x h)) ≤
      4*D + 2048*B/c := by
  let s := fun h => (path δ F branching D x₀ C x h).2
  have hu : ∀ i, ∃ h, i ≤ s h := by
    intro i
    refine ⟨i+C.card, ?_⟩
    have hp := path_card_progress δ hdiag F branching branching_pos D hD.le x₀ C x hx (i+C.card)
    change i ≤ (path δ F branching D x₀ C x (i+C.card)).2
    omega
  have hs : Monotone s := path_count_monotone δ F branching D x₀ C x
  have hs0 : s 0 = 0 := rfl
  have hstep : ∀ h, s (h+1) ≤ s h+1 := by
    intro h
    dsimp only [s]
    rw [path_count_succ]
    split_ifs <;> omega
  have hh := shrink_path_budget s hu hs hs0 hstep hD.le hc
    (fun h => F h (path δ F branching D x₀ C x h).1)
    (path_potential_antitone δ F hmono hanti branching D x₀ C x)
    (fun h => hF _ _) (by simpa only [path_zero, Prod.fst] using hB)
    (fun h k hk hr hfour => by
      have hright : (branch δ F branching D x₀ C x h).val = 0 := by
        dsimp only [s] at hr
        rw [path_count_succ] at hr
        split_ifs at hr with hb
        · exact hb
        · omega
      exact path_remainder_growth_drop δ hdiag hsymm htri F hmono hanti branching c
        (fun h => (2 : ℝ)^h) hgrowth D hD x₀ C hdiam x hx h k hk hright hfour) L
  exact hh

theorem actual_edge_entropy [Fintype U] (δ : U → U → ℝ)
    (F : ℕ → Finset U → ℝ) (D : ℝ) (x₀ : U) (h : ℕ) :
    ((chainEdges (approximation δ F branching D x₀ Finset.univ) h).card : ℝ) ≤
      Real.exp (16 * (4 : ℝ)^h) := by
  have he : chainEdges (approximation δ F branching D x₀ Finset.univ) h =
      edgeSet δ F branching D x₀ Finset.univ h := by
    ext e
    simp [chainEdges, edgeSet]
  have hn := edgeSet_card δ F D x₀ Finset.univ h
  have hr : ((chainEdges (approximation δ F branching D x₀ Finset.univ) h).card : ℝ) ≤
      (2 : ℝ)^(8*4^h) := by
    rw [he]
    exact_mod_cast hn
  apply hr.trans ((two_pow_le_exp _).trans _)
  apply Real.exp_le_exp.mpr
  push_cast
  have hp : 0 ≤ (4 : ℝ)^h := by positivity
  nlinarith

/-- A complete finite growth-functional bound for the literal
Rademacher process. All covering, path, and entropy steps are proved.
The metric-energy factor two allows squared one-sided row processes. -/
theorem finite_rademacher_growth [Fintype U] [Nonempty U]
    (m : ℕ) (a : U → Fin m → ℝ) (x₀ : U) (hroot : ∀ i, a x₀ i = 0)
    (δ : U → U → ℝ) (hnonneg : ∀ x y, 0 ≤ δ x y) (hdiag : ∀ x, δ x x = 0)
    (hsymm : ∀ x y, δ x y = δ y x) (htri : ∀ x y z, δ x z ≤ 4*(δ x y+δ y z))
    (henergy : ∀ x y, (∑ i, (a x i-a y i)^2) ≤ 2 * δ x y ^ 2)
    (F : ℕ → Finset U → ℝ) (hmono : ∀ h, Monotone (F h))
    (hanti : ∀ C, Antitone (fun h => F h C)) (hF : ∀ h C, 0 ≤ F h C)
    (c : ℝ) (hc : 0 < c)
    (hgrowth : ∀ h, GrowthAt δ (F (h+1)) (F h) (branching h) c ((2 : ℝ)^h))
    (D : ℝ) (hD : 0 < D) (hdiam : ∀ x y, δ x y ≤ D)
    (B : ℝ) (hB : F 0 Finset.univ ≤ B) :
    finiteMean (fun ε : Fin m → Bool =>
      envelope (fun u => ∑ i, cubeCoordinateSign (ε i) * a u i)) ≤
      65536 * (D + B/c) := by
  let π := approximation δ F branching D x₀ Finset.univ
  obtain ⟨L, hL⟩ := (approximation_eventually_zero δ hnonneg hdiag hsymm htri F branching
    branching_pos D hD.le x₀ Finset.univ (fun x _ y _ => hdiam x y) (Finset.mem_univ _)).exists
  have hlast : ∀ u i, a (π L u) i = a u i := by
    intro u i
    have he := henergy (π L u) u
    have hz : δ (π L u) u = 0 := hL u (Finset.mem_univ _)
    rw [hz] at he
    have hsingle : (a (π L u) i-a u i)^2 ≤ ∑ j, (a (π L u) j-a u j)^2 :=
      Finset.single_le_sum (f := fun j => (a (π L u) j-a u j)^2)
        (fun j _ => sq_nonneg _) (Finset.mem_univ i)
    nlinarith [sq_nonneg (a (π L u) i-a u i)]
  let T : ℝ := ∑ h ∈ Finset.range L, chainingWeight h
  have hT : 0 ≤ T := Finset.sum_nonneg (fun h _ => (chainingWeight_pos h).le)
  let ε₀ : ℝ := D/(1+T)
  have hε : 0 < ε₀ := div_pos hD (by linarith)
  have hεT : ε₀*T ≤ D := by
    have he : ε₀*(1+T) = D := div_mul_cancel₀ D (by linarith : 1+T ≠ 0)
    nlinarith
  let σ : (h : ℕ) → ChainEdge π h → ℝ := fun h e => 2 * δ e.val.1 e.val.2 + ε₀
  have hσ : ∀ h < L, ∀ e, 0 < σ h e := by
    intro h hh e
    have hd := hnonneg e.val.1 e.val.2
    dsimp only [σ]
    linarith
  have hσenergy : ∀ h < L, ∀ e : ChainEdge π h,
      (∑ i, (a e.val.1 i-a e.val.2 i)^2) ≤ σ h e^2 := by
    intro h hh e
    have he := henergy e.val.1 e.val.2
    have hd := hnonneg e.val.1 e.val.2
    dsimp only [σ]
    nlinarith [sq_nonneg (δ e.val.1 e.val.2)]
  let G : ℝ := 16*(4*D+2048*B/c)+D
  have hG : ∀ u, (∑ h ∈ Finset.range L, chainingWeight h * σ h (chainEdgeOf π h u)) ≤ G := by
    intro u
    have hpath := actual_path_budget δ hdiag hsymm htri F hmono hanti hF c hc hgrowth
      D hD x₀ Finset.univ (fun x _ y _ => hdiam x y) B hB u (Finset.mem_univ _) L
    have hinc (h : ℕ) : δ (π (h+1) u) (π h u) ≤ scale D (path δ F branching D x₀ Finset.univ u h) :=
      approximation_increment δ hsymm htri F branching D x₀ Finset.univ
        (fun x _ y _ => hdiam x y) (Finset.mem_univ _) h u (Finset.mem_univ _)
    calc
      _ ≤ ∑ h ∈ Finset.range L, chainingWeight h *
          (2 * scale D (path δ F branching D x₀ Finset.univ u h) + ε₀) := by
        apply Finset.sum_le_sum
        intro h hh
        apply mul_le_mul_of_nonneg_left _ (chainingWeight_pos h).le
        dsimp only [σ, chainEdgeOf]
        linarith [hinc h]
      _ = 16*(∑ h ∈ Finset.range L, (2 : ℝ)^h * scale D (path δ F branching D x₀ Finset.univ u h)) + ε₀*T := by
        have hp (h : ℕ) : chainingWeight h *
            (2 * scale D (path δ F branching D x₀ Finset.univ u h) + ε₀) =
            16*((2 : ℝ)^h * scale D (path δ F branching D x₀ Finset.univ u h)) +
              ε₀ * chainingWeight h := by unfold chainingWeight; ring
        simp_rw [hp]
        rw [Finset.sum_add_distrib, ← Finset.mul_sum, ← Finset.mul_sum]
      _ ≤ G := by dsimp only [G]; linarith
  have hb := finite_rademacher_weighted_chaining_coefficients m L a π
    (fun u i => by simpa only [π, approximation_zero] using hroot i) hlast chainingWeight σ
    (fun h _ => chainingWeight_pos h) hσ hσenergy G hG
  have hent := chaining_entropy_budget (fun h => ((chainEdges π h).card : ℝ)) L
    (fun h _ => actual_edge_entropy δ F D x₀ h)
  have hBnonneg : 0 ≤ B := (hF 0 Finset.univ).trans hB
  have hGnonneg : 0 ≤ G := by dsimp only [G]; positivity
  have hbound := mul_le_mul_of_nonneg_left (show 1 + (∑ h ∈ Finset.range L,
    ((chainEdges π h).card : ℝ) * (2 * Real.exp (-(chainingWeight h ^ 2) / 2) / chainingWeight h ^ 2)) ≤ 2 by linarith) hGnonneg
  apply hb.trans (hbound.trans _)
  dsimp only [G]
  have hBc : 0 ≤ B/c := div_nonneg hBnonneg hc.le
  have he : (16*(4*D+2048*B/c)+D)*2 = 130*D + 65536*(B/c) := by ring
  rw [he]
  nlinarith only [hD]

end NeuralGeneralization.GrowthChaining
