(* Copyright (c) 2009-2011 Tjark Weber. All rights reserved. *)

signature HolSmtLib = sig

  include Abbrev

  val GENERIC_SMT_TAC : (goal -> SolverSpec.result) -> tactic

  val CVC_ORACLE_TAC : tactic
  val YICES_TAC : tactic
  val Z3_ORACLE_TAC : tactic
  val Z3_TAC : tactic

  (* The tactics below accept a list of theorems, like metis_tac[] *)
  val z3_tac : thm list -> tactic
  val z3o_tac : thm list -> tactic

  val CVC_ORACLE_PROVE : term -> thm
  val YICES_PROVE : term -> thm
  val Z3_ORACLE_PROVE : term -> thm
  val Z3_PROVE : term -> thm

  (* exposed tunables, mostly for debugging *)
  val include_theorems : bool ref

end
