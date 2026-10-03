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


/-! ## T1 §3 (escalation dimension, unstructured classes) -- InfLearn/Unstructured.lean -/

#print axioms InfLearn.Unstructured.chain_not_acc
#print axioms InfLearn.Unstructured.thm_3_2_lower
#print axioms InfLearn.Unstructured.thm_3_2_upper
#print axioms InfLearn.Unstructured.thm_3_2
#print axioms InfLearn.Unstructured.vsVerifier_attains
#print axioms InfLearn.Unstructured.vsVerifier_escCount_le
#print axioms InfLearn.Unstructured.thm_3_9_upper
#print axioms InfLearn.Unstructured.thm_3_9_upper_honest
#print axioms InfLearn.Unstructured.thm_3_9_Esc_le
#print axioms InfLearn.Unstructured.thm_3_9_Esc_le_card
#print axioms InfLearn.Unstructured.elasticChain_length_le
#print axioms InfLearn.Unstructured.thm_3_9_coSingleton_lower
#print axioms InfLearn.Unstructured.exists_honest_prover_coSingleton
#print axioms InfLearn.Unstructured.thm_3_9_coSingleton_forces
#print axioms InfLearn.Unstructured.thm_3_9_coSingleton
#print axioms InfLearn.Unstructured.exists_class_Esc_eq
#print axioms InfLearn.Unstructured.vsVerifier_cost_eq_escCount
#print axioms InfLearn.Unstructured.vsVerifier_escQueries_chain
#print axioms InfLearn.Unstructured.elasticChain_iff
#print axioms InfLearn.Unstructured.Esc_le_worstCost
#print axioms InfLearn.Unstructured.maxEl_le_worstCost
#print axioms InfLearn.Unstructured.worstCost_vsVerifier_le
#print axioms InfLearn.Unstructured.card_coSingleton
#print axioms InfLearn.Unstructured.vsFin_ssubset_of_esc

/-! ## T3 §3-4 (export and certification) -- InfLearn/Export.lean -/

#print axioms InfLearn.Export.invisible_perturbation
#print axioms InfLearn.Export.samples_do_not_determine
#print axioms InfLearn.Export.no_free_export_perturbation
#print axioms InfLearn.Export.exists_poly_interp
#print axioms InfLearn.Export.no_free_export_samples
#print axioms InfLearn.Export.no_free_export_samples_everywhere
#print axioms InfLearn.Export.no_free_export_samples_emb
#print axioms InfLearn.Export.no_free_export_samples_Icc
#print axioms InfLearn.Export.no_free_export_from_samples
#print axioms InfLearn.Export.no_sound_committing_rule
#print axioms InfLearn.Export.nodeClosed_of_addPolyClosed
#print axioms InfLearn.Export.no_free_export_samples_of_poly_subset
#print axioms InfLearn.Export.no_free_export_finite_jet
#print axioms InfLearn.Export.no_free_export_finite_jet'
#print axioms InfLearn.Export.no_free_export_away
#print axioms InfLearn.Export.no_free_export_germ
#print axioms InfLearn.Export.exists_interval_iff_radius_le
#print axioms InfLearn.Export.midrange_sound
#print axioms InfLearn.Export.optimalRule_sound
#print axioms InfLearn.Export.radius_le_of_sound
#print axioms InfLearn.Export.no_interval_of_unbounded
#print axioms InfLearn.Export.coherence_cannot_calibrate
#print axioms InfLearn.Export.coherence_cannot_calibrate_unbounded
#print axioms InfLearn.Export.no_certification_without_regularity
#print axioms InfLearn.Export.lip_cert_sound_point
#print axioms InfLearn.Export.lip_cert_sound_indexed
#print axioms InfLearn.Export.dist_le_iff_sup
#print axioms InfLearn.Export.lip_cert_sound
#print axioms InfLearn.Export.lip_cert_sound_noisy
#print axioms InfLearn.Export.lip_cert_complete_of_net
#print axioms InfLearn.Export.lip_cert_complete
#print axioms InfLearn.Export.lip_cert_complete'
#print axioms InfLearn.Export.lip_lower_bound_of_packing
#print axioms InfLearn.Export.lip_lower_bound_cube
#print axioms InfLearn.Export.lip_lower_bound_cube_adaptive
#print axioms InfLearn.Export.lip_lower_bound_interval
#print axioms InfLearn.Export.lazy_bisection_sound
#print axioms InfLearn.Export.lazy_bisection_miss
#print axioms InfLearn.Export.lazy_bisection_resolution
#print axioms InfLearn.Export.mono_lower_bound
#print axioms InfLearn.Export.mono_lower_bound_ceil
#print axioms InfLearn.Export.abstain_of_line

/-! ## T4 §4 (paradox lower bounds, Thm 4.3(b), Thm 4.4(b),(c)) -- InfLearn/ParadoxLowerBound.lean -/

#print axioms InfLearn.ParadoxLowerBound.forces_of_adversary
#print axioms InfLearn.ParadoxLowerBound.exists_nonSilent_extension
#print axioms InfLearn.ParadoxLowerBound.nonSilent_iff
#print axioms InfLearn.ParadoxLowerBound.exists_feedback_bagBags
#print axioms InfLearn.ParadoxLowerBound.exists_feedback_objBags
#print axioms InfLearn.ParadoxLowerBound.IsValue.unique
#print axioms InfLearn.ParadoxLowerBound.achieves_of_potential
#print axioms InfLearn.ParadoxLowerBound.thm_4_3_b
#print axioms InfLearn.ParadoxLowerBound.thm_4_3_b_eq
#print axioms InfLearn.ParadoxLowerBound.thm_4_4_b_bag_lower
#print axioms InfLearn.ParadoxLowerBound.thm_4_4_b_bag_upper
#print axioms InfLearn.ParadoxLowerBound.thm_4_4_b_bag_value
#print axioms InfLearn.ParadoxLowerBound.thm_4_4_b_unbounded
#print axioms InfLearn.ParadoxLowerBound.thm_4_4_b_obj_lower
#print axioms InfLearn.ParadoxLowerBound.thm_4_4_b_obj_upper
#print axioms InfLearn.ParadoxLowerBound.thm_4_4_b_obj_value
#print axioms InfLearn.ParadoxLowerBound.thm_4_4_b
#print axioms InfLearn.ParadoxLowerBound.chainStep_mem_hypC
#print axioms InfLearn.ParadoxLowerBound.hypC_coherent
#print axioms InfLearn.ParadoxLowerBound.paradox_derivation
#print axioms InfLearn.ParadoxLowerBound.essential_bag
#print axioms InfLearn.ParadoxLowerBound.chainBags_eq
#print axioms InfLearn.ParadoxLowerBound.object_descent
#print axioms InfLearn.ParadoxLowerBound.object_refutes_iff
#print axioms InfLearn.ParadoxLowerBound.exists_object
#print axioms InfLearn.ParadoxLowerBound.exists_feedback_chain
#print axioms InfLearn.ParadoxLowerBound.thm_4_4_c_lower
#print axioms InfLearn.ParadoxLowerBound.thm_4_4_c_upper
#print axioms InfLearn.ParadoxLowerBound.thm_4_4_c_value
#print axioms InfLearn.ParadoxLowerBound.thm_4_4_c_obj_value
#print axioms InfLearn.ParadoxLowerBound.thm_4_4_c
#print axioms InfLearn.ParadoxLowerBound.chainH_eq
#print axioms InfLearn.ParadoxLowerBound.card_class
#print axioms InfLearn.ParadoxLowerBound.SemSound_subset_hypC

/-! ## T5 Thm 2.1(i) (no adaptation with private randomness) -- InfLearn/NoAdaptation.lean -/

#print axioms InfLearn.NoAdaptation.gibbs
#print axioms InfLearn.NoAdaptation.expLoss_eq_sum_marg
#print axioms InfLearn.NoAdaptation.thm_2_1_i
#print axioms InfLearn.NoAdaptation.thm_2_1_i_exists
#print axioms InfLearn.NoAdaptation.thm_2_1_i_maxF
#print axioms InfLearn.NoAdaptation.margHyp_expLoss
#print axioms InfLearn.NoAdaptation.thm_2_1_i_ennreal
#print axioms InfLearn.NoAdaptation.thm_2_1_i_ennreal_maxF
#print axioms InfLearn.NoAdaptation.unifHyp_loss
#print axioms InfLearn.NoAdaptation.unifHyp_supE
#print axioms InfLearn.NoAdaptation.sum_entropy_le_sum_log_card
#print axioms InfLearn.NoAdaptation.sum_entropy_of_uniform
#print axioms InfLearn.NoAdaptation.minimax_of_uniform_marginals
#print axioms InfLearn.NoAdaptation.minimax_of_uniform_marginals_ennreal
#print axioms InfLearn.NoAdaptation.uniform_marginals_of_transitive
#print axioms InfLearn.NoAdaptation.minimax_of_transitive
#print axioms InfLearn.NoAdaptation.Example.no_uniform_marginals
#print axioms InfLearn.NoAdaptation.Example.value_lt_sum_log_card
#print axioms InfLearn.NoAdaptation.Example.sum_entropy_lt
#print axioms InfLearn.NoAdaptation.gibbs_eq
#print axioms InfLearn.NoAdaptation.unifHyp_isProductHyp
#print axioms InfLearn.NoAdaptation.unifHyp_sup'
#print axioms InfLearn.NoAdaptation.margHyp_isProductHyp
#print axioms InfLearn.NoAdaptation.entropy_marg_of_uniform
#print axioms InfLearn.NoAdaptation.unifDist_isDistOn

/-! ## T6 §2 (bilateral completeness, Scott relations) -- InfLearn/Bilateral.lean -/

#print axioms InfLearn.Bilateral.isScott_Th
#print axioms InfLearn.Bilateral.gen_eq_derives
#print axioms InfLearn.Bilateral.exists_maxCoherent
#print axioms InfLearn.Bilateral.thm_2_2_a
#print axioms InfLearn.Bilateral.thm_2_2_a_max
#print axioms InfLearn.Bilateral.thm_2_2_b
#print axioms InfLearn.Bilateral.coherent_iff_realizable
#print axioms InfLearn.Bilateral.cor_2_3
#print axioms InfLearn.Bilateral.cor_2_3_consOp
#print axioms InfLearn.Bilateral.isScott_iff_Th_Val_eq
#print axioms InfLearn.Bilateral.mem_gen_iff
#print axioms InfLearn.Bilateral.Val_Th
#print axioms InfLearn.Bilateral.isClosed_Val
#print axioms InfLearn.Bilateral.scottClosedIso
#print axioms InfLearn.Bilateral.thm_2_6_a
#print axioms InfLearn.Bilateral.thm_2_6_a_closed
#print axioms InfLearn.Bilateral.structural_gen
#print axioms InfLearn.Bilateral.structuralClosedIso
#print axioms InfLearn.Bilateral.thm_2_6_b_validates
#print axioms InfLearn.Bilateral.thm_2_6_b_eq
#print axioms InfLearn.Bilateral.thm_2_6_b_realize
#print axioms InfLearn.Bilateral.cor_2_3_mseq
#print axioms InfLearn.Bilateral.mem_gen_empty
#print axioms InfLearn.Bilateral.Val_gen_TT
#print axioms InfLearn.Bilateral.coherent_TT_iff
#print axioms InfLearn.Bilateral.isScott_sInter
#print axioms InfLearn.Bilateral.isScott_gen
#print axioms InfLearn.Bilateral.gen_subset
#print axioms InfLearn.Bilateral.Coherent.disjoint
#print axioms InfLearn.Bilateral.MaxCoherent.exhaustive
#print axioms InfLearn.Bilateral.MaxCoherent.charFn_mem_Val
#print axioms InfLearn.Bilateral.MaxCoherent.eq_split
#print axioms InfLearn.Bilateral.maxCoherent_of_mem_Val
#print axioms InfLearn.Bilateral.gen_subset_Th_Val
#print axioms InfLearn.Bilateral.Val_gen
#print axioms InfLearn.Bilateral.coherent_gen_iff
#print axioms InfLearn.Bilateral.isScott_iff_exists_Th
#print axioms InfLearn.Bilateral.Th_Val_of_isScott
#print axioms InfLearn.Bilateral.Th_closure
#print axioms InfLearn.Bilateral.Val_Th_of_isClosed
#print axioms InfLearn.Bilateral.Val_subset_Val_iff
#print axioms InfLearn.Bilateral.mem_closure_iff_agree
#print axioms InfLearn.Bilateral.substInvariant_Val
#print axioms InfLearn.Bilateral.structural_Th
#print axioms InfLearn.Bilateral.lindenbaum_interp
#print axioms InfLearn.Bilateral.lindenbaum_validates_iff
#print axioms InfLearn.Bilateral.carnap_Val_eq
#print axioms InfLearn.Bilateral.carnap_mrel_eq

/-! ## T6 Thm 3.4 + Prop 4.7 (Specker) -- InfLearn/Specker.lean -/

#print axioms InfLearn.Specker.not_matchesOn_univ
#print axioms InfLearn.Specker.exists_matchesOn
#print axioms InfLearn.Specker.thm_3_4
#print axioms InfLearn.Specker.thm_3_4_a
#print axioms InfLearn.Specker.thm_3_4_b
#print axioms InfLearn.Specker.thm_3_4_hence
#print axioms InfLearn.Specker.Qk_eq_Pk
#print axioms InfLearn.Specker.exists_prF_eq_Qk
#print axioms InfLearn.Specker.Qk_incoherent
#print axioms InfLearn.Specker.two_atom_coherent
#print axioms InfLearn.Specker.specker_parable
#print axioms InfLearn.Specker.frustrated_triangle
#print axioms InfLearn.Specker.matchesOn_neg
#print axioms InfLearn.Specker.prF_eq_Pk_of_matchesOn
#print axioms InfLearn.Specker.isProb_mixDist_atomCred
