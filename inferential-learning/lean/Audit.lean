import InfLearn

/-!
# Axiom audit

Prints the axioms used by every main theorem of the formalization.
Expected output for every declaration: a subset of
`[propext, Classical.choice, Quot.sound]` (Lean's standard classical axioms).
Any `sorryAx` or project-specific axiom would show up here.

Build with `lake build Audit`; the output is captured in `audit-output.txt`.
-/

/-! ## Foundations -- InfLearn/ConsOp.lean, InfLearn/Prop/Basic.lean, InfLearn/Steps.lean -/

#print axioms InfLearn.Cl_eq_sInter
#print axioms InfLearn.Cl_mono_rules
#print axioms InfLearn.subset_Sound
#print axioms InfLearn.Cl_subset_Cl_iff_subset_Sound
#print axioms InfLearn.ClOp_finitary
#print axioms InfLearn.ClOp_structural
#print axioms InfLearn.ClOp_substClosure_le
#print axioms InfLearn.Cl_subset_Cn2
#print axioms InfLearn.Cn2_structural
#print axioms InfLearn.compactness
#print axioms InfLearn.Cn2_finitary

/-! ## T1 (soundness under search) -- InfLearn/StepSoundness.lean -/

#print axioms InfLearn.StepSoundness.lemma_1_1
#print axioms InfLearn.StepSoundness.concl_not_derivable_of_not_mem_Sound
#print axioms InfLearn.StepSoundness.reasoner_sound_of_subset
#print axioms InfLearn.StepSoundness.thm_2_1_i
#print axioms InfLearn.StepSoundness.thm_2_1_i_univ
#print axioms InfLearn.StepSoundness.thm_2_1_i_derivation
#print axioms InfLearn.StepSoundness.thm_2_1_unsound
#print axioms InfLearn.StepSoundness.T_not_subset_Sound
#print axioms InfLearn.StepSoundness.tonk_not_mem_of_sound
#print axioms InfLearn.StepSoundness.cor_2_2_trivializes
#print axioms InfLearn.StepSoundness.Rstar_sound
#print axioms InfLearn.StepSoundness.Rstar_eq_substClosure
#print axioms InfLearn.StepSoundness.T_eq_substClosure
#print axioms InfLearn.StepSoundness.Rstar_union_T_eq_substClosure
#print axioms InfLearn.StepSoundness.T_disjoint
#print axioms InfLearn.StepSoundness.T_succ_pairwise_disjoint
#print axioms InfLearn.StepSoundness.thm_2_1_ii
#print axioms InfLearn.StepSoundness.thm_2_1_error_and_trivial
#print axioms InfLearn.StepSoundness.thm_3_1_a_static
#print axioms InfLearn.StepSoundness.thm_3_1_b_static
#print axioms InfLearn.StepSoundness.subset_sInter_VS_iff
#print axioms InfLearn.StepSoundness.reasoner_sound_for_all_VS_iff
#print axioms InfLearn.StepSoundness.target_mem_VSh
#print axioms InfLearn.StepSoundness.vsVerifier_acc_iff
#print axioms InfLearn.StepSoundness.vsVerifier_rej_iff
#print axioms InfLearn.StepSoundness.vsVerifier_esc_iff
#print axioms InfLearn.StepSoundness.thm_3_1_a
#print axioms InfLearn.StepSoundness.thm_3_1_a_reasoner
#print axioms InfLearn.StepSoundness.vsVerifier_reasoner_sound
#print axioms InfLearn.StepSoundness.thm_3_1_b
#print axioms InfLearn.StepSoundness.vsVerifier_optimal
#print axioms InfLearn.StepSoundness.thm_3_1_a_closure
#print axioms InfLearn.StepSoundness.thm_3_1_b_closure
#print axioms InfLearn.StepSoundness.vsVerifierSound_optimal
#print axioms InfLearn.StepSoundness.vsVerifier_acc_imp_vsVerifierSound_acc

/-! ## T2 §3 + T7 Lemma 6.1 (Post completeness) -- InfLearn/PostCompleteness.lean -/

#print axioms InfLearn.Post.eq_Cn2_or_eq_trivial
#print axioms InfLearn.Post.structural_extensions_Cn2
#print axioms InfLearn.Post.trivial_ne_Cn2
#print axioms InfLearn.Post.frag_eq_Cn2F_or_eq_trivial
#print axioms InfLearn.Post.frag_eq_Cn2F_or_eq_trivial_of_const
#print axioms InfLearn.Post.frag_eq_Cn2F_or_eq_trivial_of_imp_pos
#print axioms InfLearn.Post.frag_postComplete_neg
#print axioms InfLearn.Post.impFrag_postComplete
#print axioms InfLearn.Post.Cn2F_structural
#print axioms InfLearn.Post.eq_Cn2_of_coherent
#print axioms InfLearn.Post.eq_Cn2_of_consistent
#print axioms InfLearn.Post.eq_Cn2_of_satisfiable_coherent
#print axioms InfLearn.Post.eq_Cn2_iff_exists_coherent
#print axioms InfLearn.Post.versionSpace_eq_singleton_iff
#print axioms InfLearn.Post.gen_le_Cn2
#print axioms InfLearn.Post.gen_mem_versionSpace
#print axioms InfLearn.Post.learner_identifies
#print axioms InfLearn.Post.learner_mindChanges_le
#print axioms InfLearn.Post.card_changes_le
#print axioms InfLearn.Post.Cn2_le_Cn2Add
#print axioms InfLearn.Post.Cn2Add_validates
#print axioms InfLearn.Post.Cn2Add_consistent
#print axioms InfLearn.Post.Cn2Add_ne_Cn2
#print axioms InfLearn.Post.Cn2Add_not_structural
#print axioms InfLearn.Post.trivial_validates
#print axioms InfLearn.Post.le_Cn2_of_empty_eq_Taut
#print axioms InfLearn.Post.schema_invalid_iff_closedRefutation
#print axioms InfLearn.Post.exists_invalid_instance_iff_closedRefutation
#print axioms InfLearn.Post.eval_eq_closedValue
#print axioms InfLearn.Post.closedInstance_isClosed
#print axioms InfLearn.Post.size_subst_ofVal
#print axioms InfLearn.Post.stepSize_closedInstance_le
#print axioms InfLearn.Post.card_candidates_le
#print axioms InfLearn.Post.mem_candidates
#print axioms InfLearn.Post.mem_SemSound_iff_candidates

/-! ## T2 §4 (Carnap's problem) -- InfLearn/Carnap.lean -/

#print axioms InfLearn.Carnap.SCons_eq_of_subset_intClosure
#print axioms InfLearn.Carnap.SCons_intClosure_iff
#print axioms InfLearn.Carnap.SVal_eq_intClosure
#print axioms InfLearn.Carnap.Val_mrel
#print axioms InfLearn.Carnap.mrel_closure
#print axioms InfLearn.Carnap.mrel_eq_iff_closure_eq
#print axioms InfLearn.Carnap.eq_of_mrel_eq
#print axioms InfLearn.Carnap.lemma_4_1_b
#print axioms InfLearn.Carnap.CV_finitary
#print axioms InfLearn.Carnap.isClosed_CV_iff
#print axioms InfLearn.Carnap.SValS_srel
#print axioms InfLearn.Carnap.mem_intClosure_BV_iff
#print axioms InfLearn.Carnap.intClosure_BV_eq
#print axioms InfLearn.Carnap.carnap_single
#print axioms InfLearn.Carnap.carnap_single_vtop
#print axioms InfLearn.Carnap.carnap_single_vTaut
#print axioms InfLearn.Carnap.carnap_single_intClosure
#print axioms InfLearn.Carnap.SCons_BV_eq
#print axioms InfLearn.Carnap.vtop_mem_intClosure
#print axioms InfLearn.Carnap.vTaut_mem_intClosure_BV
#print axioms InfLearn.Carnap.carnap_vtop
#print axioms InfLearn.Carnap.carnap_vTaut
#print axioms InfLearn.Carnap.MCons_vtop_excludedMiddle
#print axioms InfLearn.Carnap.carnap_problem
#print axioms InfLearn.Carnap.mrel_ssubset_of_BV_ssubset
#print axioms InfLearn.Carnap.carnap_not_learnable_single
#print axioms InfLearn.Carnap.mem_intClosure_BV_diff_BV_iff
#print axioms InfLearn.Carnap.mem_BV_iff_maximal
#print axioms InfLearn.Carnap.intClosure_BV_and
#print axioms InfLearn.Carnap.vtop_violates_neg
#print axioms InfLearn.Carnap.vTaut_violates_neg
#print axioms InfLearn.Carnap.vTaut_violates_or
#print axioms InfLearn.Carnap.vTaut_violates_imp
#print axioms InfLearn.Carnap.consistent_nonBoolean_violates
#print axioms InfLearn.Carnap.eq_vtop_of_not_satisfiable
#print axioms InfLearn.Carnap.isClosed_intClosure_BV
#print axioms InfLearn.Carnap.intClosure_BV_structural
#print axioms InfLearn.Carnap.denialRank_eq_zero_iff
#print axioms InfLearn.Carnap.denialRank_eq_one_iff
#print axioms InfLearn.Carnap.denialRank_eq_two_iff
#print axioms InfLearn.Carnap.denialRank_eq_top_iff
#print axioms InfLearn.Carnap.denialRank_le_two_of_not_mem_BV
#print axioms InfLearn.Carnap.denialRank_vtop
#print axioms InfLearn.Carnap.denialRank_vTaut
#print axioms InfLearn.Carnap.Val_TTall
#print axioms InfLearn.Carnap.isClosed_BV
#print axioms InfLearn.Carnap.mrel_eq_mrel_BV_iff
#print axioms InfLearn.Carnap.TTpq_finite
#print axioms InfLearn.Carnap.structural_eq_BV
#print axioms InfLearn.Carnap.finite_telltale_structural
#print axioms InfLearn.Carnap.empty_survives
#print axioms InfLearn.Carnap.ttLearner_finite_identification
#print axioms InfLearn.Carnap.flipAt_not_mem_BV
#print axioms InfLearn.Carnap.sat_flipAt_of_not_mem
#print axioms InfLearn.Carnap.isClosed_BV_union_flipAt
#print axioms InfLearn.Carnap.mrel_flip_ssubset
#print axioms InfLearn.Carnap.exists_refutation
#print axioms InfLearn.Carnap.no_finite_telltale
#print axioms InfLearn.Carnap.exists_locking
#print axioms InfLearn.Carnap.not_BCIdentifies_of_no_telltale
#print axioms InfLearn.Carnap.EXIdentifies.bc
#print axioms InfLearn.Carnap.inBounds_empty_flip
#print axioms InfLearn.Carnap.BV_not_BC_learnable
#print axioms InfLearn.Carnap.BV_not_BC_learnable_meaning
#print axioms InfLearn.Carnap.closure_BV_diff_singleton
#print axioms InfLearn.Carnap.mrel_BV_diff_singleton
#print axioms InfLearn.Carnap.inBounds_BV_diff_singleton
#print axioms InfLearn.Carnap.not_structural_BV_diff_singleton
#print axioms InfLearn.Carnap.BV_not_determined_nonstructural

/-! ## T2 §2 + T4 §4 (coherence games) -- InfLearn/CoherenceGames.lean -/

#print axioms InfLearn.CoherenceGames.negative_bag
#print axioms InfLearn.CoherenceGames.refuted_of_superset
#print axioms InfLearn.CoherenceGames.weight_le_pow_mul
#print axioms InfLearn.CoherenceGames.halving_bound
#print axioms InfLearn.CoherenceGames.halving_bound_log
#print axioms InfLearn.CoherenceGames.halving_bound_total
#print axioms InfLearn.CoherenceGames.oligarchic_halving
#print axioms InfLearn.CoherenceGames.oligarchic_target_survives
#print axioms InfLearn.CoherenceGames.thm_2_2
#print axioms InfLearn.CoherenceGames.thm_2_2_iii_iv
#print axioms InfLearn.CoherenceGames.thm_2_2_of_derivations
#print axioms InfLearn.CoherenceGames.thm_2_2_uniform
#print axioms InfLearn.CoherenceGames.prop_2_3
#print axioms InfLearn.CoherenceGames.thm_2_4
#print axioms InfLearn.CoherenceGames.thm_2_4_memberships
#print axioms InfLearn.CoherenceGames.mem_majority_three
#print axioms InfLearn.CoherenceGames.Sound_hyp
#print axioms InfLearn.CoherenceGames.hyp_coherent
#print axioms InfLearn.CoherenceGames.tautStep_mem_hyp
#print axioms InfLearn.CoherenceGames.thm_2_4_environment
#print axioms InfLearn.CoherenceGames.thm_2_4_constant_environment
#print axioms InfLearn.CoherenceGames.thm_2_4_caveat
#print axioms InfLearn.CoherenceGames.thm_2_5
#print axioms InfLearn.CoherenceGames.majority_pos_halving
#print axioms InfLearn.CoherenceGames.majority_obj_halving
#print axioms InfLearn.CoherenceGames.thm_4_3_a
#print axioms InfLearn.CoherenceGames.thm_4_3_a_uniform
#print axioms InfLearn.CoherenceGames.supermajority_bag
#print axioms InfLearn.CoherenceGames.sum_not_subset_le
#print axioms InfLearn.CoherenceGames.thm_4_5
#print axioms InfLearn.CoherenceGames.thm_4_5_uniform

/-! ## T7 Lemma 2.3 + T4 Lemma 4.1 (blame) -- InfLearn/Blame.lean -/

#print axioms InfLearn.Blame.isClean_iff_forall_not_subset
#print axioms InfLearn.Blame.isClean_iff_forall_minConflict
#print axioms InfLearn.Blame.isClean_iff_isTransversal_sdiff
#print axioms InfLearn.Blame.isMaxClean_iff
#print axioms InfLearn.Blame.isMinTransversal_iff
#print axioms InfLearn.Blame.setOf_isMaxClean_eq_image
#print axioms InfLearn.Blame.exists_private_of_mem_minTransversal
#print axioms InfLearn.Blame.exists_minTransversal_mem_iff_of_antichain
#print axioms InfLearn.Blame.exists_minTransversal_mem_iff
#print axioms InfLearn.Blame.coe_blameSet
#print axioms InfLearn.Blame.coe_blameSet_eq_iUnion_minTransversal
#print axioms InfLearn.Blame.mem_inter_maxClean_iff
#print axioms InfLearn.Blame.mem_blameSet_iff_exists_maxClean
#print axioms InfLearn.Blame.exists_isMaxClean
#print axioms InfLearn.Blame.iInter_maxClean_eq
#print axioms InfLearn.Blame.isClean_sdiff_blameSet
#print axioms InfLearn.Blame.isClean_iInter_maxClean
#print axioms InfLearn.Blame.existsUnique_minTransversal_iff
#print axioms InfLearn.Blame.ArgTree.descend_spec
#print axioms InfLearn.Blame.ArgTree.descent_tree
#print axioms InfLearn.Blame.ArgTree.moves_lt_depth
#print axioms InfLearn.Blame.ArgTree.evals_le_maxPathFanIn
#print axioms InfLearn.Blame.ArgTree.descent_tree_not_mem
#print axioms InfLearn.Blame.ArgTree.descent_tree_not_semSound
#print axioms InfLearn.Blame.LineArg.descent
#print axioms InfLearn.Blame.LineArg.descent_index
#print axioms InfLearn.Blame.LineArg.descent_depth
#print axioms InfLearn.Blame.LineArg.descent_not_mem

/-! ## T5 §3 + T4 §7 (rate threshold) -- InfLearn/RateThreshold.lean -/

#print axioms InfLearn.RateThreshold.prod_isMin_iff
#print axioms InfLearn.RateThreshold.prod_isUniqueMin_iff
#print axioms InfLearn.RateThreshold.rate_threshold
#print axioms InfLearn.RateThreshold.isMinimizer_iff
#print axioms InfLearn.RateThreshold.Sstar_isMinimizer
#print axioms InfLearn.RateThreshold.isMinimizer_iff_eq_Sstar
#print axioms InfLearn.RateThreshold.isUniqueMinimizer_iff
#print axioms InfLearn.RateThreshold.Sstar_isUniqueMinimizer
#print axioms InfLearn.RateThreshold.ties_arbitrary
#print axioms InfLearn.RateThreshold.thm_3_2
#print axioms InfLearn.RateThreshold.thm_3_2_unique
#print axioms InfLearn.RateThreshold.thm_3_2_unique'
#print axioms InfLearn.RateThreshold.rate_blindness
#print axioms InfLearn.RateThreshold.selectable_iff
#print axioms InfLearn.RateThreshold.exists_Sstar_eq_iff
#print axioms InfLearn.RateThreshold.selectable_iff_fold
#print axioms InfLearn.RateThreshold.selectable_iff_sup'_lt_inf'
#print axioms InfLearn.RateThreshold.weakly_selectable_iff
#print axioms InfLearn.RateThreshold.isMinAt_le_of_inHull
#print axioms InfLearn.RateThreshold.onLowerHull_iff
#print axioms InfLearn.RateThreshold.lemma_3_1_ii
#print axioms InfLearn.RateThreshold.uniquePoint_iff_rates
#print axioms InfLearn.RateThreshold.chord_iff_extreme
#print axioms InfLearn.RateThreshold.chord_iff_notInOthersHull
#print axioms InfLearn.RateThreshold.isHullVertex_iff_chord
#print axioms InfLearn.RateThreshold.isHullVertex_iff_extreme
#print axioms InfLearn.RateThreshold.lemma_3_1_iii
#print axioms InfLearn.RateThreshold.lemma_3_1_iii_hyp
#print axioms InfLearn.RateThreshold.Jc_eq_of_same_point
#print axioms InfLearn.RateThreshold.not_isHullVertex_of_dominated
#print axioms InfLearn.RateThreshold.rate_inversion
#print axioms InfLearn.RateThreshold.valid_not_minimizer
#print axioms InfLearn.RateThreshold.Sstar_ne_valid
#print axioms InfLearn.RateThreshold.not_selectable
#print axioms InfLearn.RateThreshold.rates_not_separated
#print axioms InfLearn.RateThreshold.Sstar_low
#print axioms InfLearn.RateThreshold.Sstar_mid
#print axioms InfLearn.RateThreshold.Sstar_high
#print axioms InfLearn.RateThreshold.Sstar_top
#print axioms InfLearn.RateThreshold.pareto_dominated
#print axioms InfLearn.RateThreshold.no_monotone_criterion
#print axioms InfLearn.RateThreshold.valid_not_hullVertex
#print axioms InfLearn.RateThreshold.valid_never_vertex

/-! ## T3 §1-2 + T2 Prop 7.1 (contexts) -- InfLearn/Contexts.lean -/

#print axioms InfLearn.Contexts.cn2_closed_ThIn
#print axioms InfLearn.Contexts.consistent_ThIn_iff
#print axioms InfLearn.Contexts.satisfiable_ThIn_iff
#print axioms InfLearn.Contexts.holdsIn_sup_iff
#print axioms InfLearn.Contexts.sup_not_proper_iff
#print axioms InfLearn.Contexts.defFilter_pure_pure
#print axioms InfLearn.Contexts.dStable_of_disjoint
#print axioms InfLearn.Contexts.import_sound
#print axioms InfLearn.Contexts.no_truthFunctional_eternal_reading
#print axioms InfLearn.Contexts.not_exists_truthFunctional_reading
#print axioms InfLearn.Contexts.eternal_reading_witnesses
#print axioms InfLearn.Contexts.stripping_fails
#print axioms InfLearn.Contexts.conditionalizing_fails
#print axioms InfLearn.Contexts.tracksAt_conditional_of_not_proper
#print axioms InfLearn.Contexts.no_eternal_reading_pure
#print axioms InfLearn.Contexts.no_eternal_reading_modelClass
#print axioms InfLearn.Contexts.patm_example
#print axioms InfLearn.Contexts.refutes_of_inconsistent
#print axioms InfLearn.Contexts.hygiene_K_unsat
#print axioms InfLearn.Contexts.hygiene_K1_sat
#print axioms InfLearn.Contexts.hygiene_K2_sat
#print axioms InfLearn.Contexts.hygiene_K1_supp_unsat
#print axioms InfLearn.Contexts.hygiene_K2_supp_unsat
#print axioms InfLearn.Contexts.hygiene_K_proves_both
#print axioms InfLearn.Contexts.DA_valid
#print axioms InfLearn.Contexts.DA_soundRules
#print axioms InfLearn.Contexts.derivation_local_test_accepts_both
#print axioms InfLearn.Contexts.derivation_local_test_accepts_both'
#print axioms InfLearn.Contexts.certificate_refutes_false
#print axioms InfLearn.Contexts.certificate_not_both
#print axioms InfLearn.Contexts.certificate_rules_needed
#print axioms InfLearn.Contexts.refutation_sound_in_context
#print axioms InfLearn.Contexts.proper_not_both_refuted
#print axioms InfLearn.Contexts.closure_eq_univ_of_contradictory
#print axioms InfLearn.Contexts.closure_eq_univ_of_unsat
#print axioms InfLearn.Contexts.not_Cn2_le_of_consistent_unsat
#print axioms InfLearn.Contexts.not_Cn2_le_of_coherent_unsat
#print axioms InfLearn.Contexts.not_Cn2_le_of_coherent_contradictory
#print axioms InfLearn.Contexts.misdesignation_not_Cn2_le
#print axioms InfLearn.Contexts.exists_invalid_step
#print axioms InfLearn.Contexts.exists_invalid_schema
#print axioms InfLearn.Contexts.atomic_paraconsistent
#print axioms InfLearn.Contexts.atomic_nontrivial
