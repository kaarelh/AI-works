import NeuralGeneralization.OnlineLowerTanhNearPairResidual
import NeuralGeneralization.OnlineLowerTanhActualEqualization

/-! # Exact equality of all asymptotically balanced coordinates

Every analytic input is constructed from the literal maximizing sequence.
There is no central-limit or curvature hypothesis in the public endpoint.
-/
noncomputable section
open scoped BigOperators Topology Classical
open Filter Set
set_option backward.isDefEq.respectTransparency false
namespace NeuralGeneralization.OnlineLowerTanh
namespace NearBalancedSequence
variable (B : NearBalancedSequence)

lemma pair_equal_on_subsequence (i j : ∀ k,Fin (B.N k))
    (hij : ∀ k,i k ≠ j k)
    (hi : Tendsto (fun k => B.u k (i k)) atTop (𝓝 limitingGain))
    (hj : Tendsto (fun k => B.u k (j k)) atTop (𝓝 limitingGain)) :
    ∃ φ : ℕ → ℕ,StrictMono φ ∧
      ∀ᶠ k in atTop,B.u (φ k) (i (φ k))=B.u (φ k) (j (φ k)) := by
  obtain ⟨d⟩ := B.exists_pair_residual_data i j
  let C := B.reindex d.φ d.strictMono.tendsto_atTop
  have hnear := C.moving_scaled_correlation_lower
    (fun k => residualVariance (d.S.alphabet k)) d.S.A d.variance_fraction
      d.gain_limit d.S.gain_pos
  have heq := d.S.actual_maximizer_pair_eventually_equal
    (fun k => B.N (d.φ k)) (fun k => B.u (d.φ k))
    (fun k => i (d.φ k)) (fun k => j (d.φ k))
    (fun k => hij (d.φ k))
    (Eventually.of_forall (fun k => B.N_odd (d.φ k)))
    ((B.N_tendsto.comp d.strictMono.tendsto_atTop).eventually_ge_atTop 3)
    (Eventually.of_forall (fun k => B.maximal (d.φ k)))
    d.selected d.e d.incoming_eq d.outside_fraction limitingGain_pos
    (hi.comp d.strictMono.tendsto_atTop) (hj.comp d.strictMono.tendsto_atTop)
    d.hi_le hnear
  exact ⟨d.φ,d.strictMono,heq⟩

/-- Any two coordinates converging to the unique balanced gain in an actual
maximizing sequence must be exactly equal from some index onward. -/
theorem pair_eventually_equal (i j : ∀ k,Fin (B.N k))
    (hi : Tendsto (fun k => B.u k (i k)) atTop (𝓝 limitingGain))
    (hj : Tendsto (fun k => B.u k (j k)) atTop (𝓝 limitingGain)) :
    ∀ᶠ k in atTop,B.u k (i k)=B.u k (j k) := by
  by_contra hbad
  have hf : ∃ᶠ k in atTop,B.u k (i k) ≠ B.u k (j k) := by
    simpa only [Filter.Frequently,not_not] using hbad
  obtain ⟨φ,hφ,hne⟩ := Filter.subseq_forall_of_frequently (x := fun k : ℕ => k)
    (p := fun k => B.u k (i k) ≠ B.u k (j k)) tendsto_id hf
  let C := B.reindex φ hφ
  have hij : ∀ k,i (φ k) ≠ j (φ k) := by
    intro k he
    exact hne k (congrArg (B.u (φ k)) he)
  obtain ⟨ψ,hψ,heq⟩ := C.pair_equal_on_subsequence
    (fun k => i (φ k)) (fun k => j (φ k)) hij (hi.comp hφ) (hj.comp hφ)
  obtain ⟨k,hk⟩ := heq.exists
  exact hne (ψ k) hk

end NearBalancedSequence
end NeuralGeneralization.OnlineLowerTanh
