(*
 * Copyright 2014, NICTA
 *
 * This software may be distributed and modified according to the terms of
 * the BSD 2-Clause license. Note that NO WARRANTY is provided.
 * See "LICENSE_BSD2.txt" for details.
 *
 * @TAG(NICTA_BSD)
 *)

theory TermPatternAntiquote_Tests
imports
  Lib.TermPatternAntiquote
  Main
begin

text \<open>
  Term pattern matching utility.

  Instead of writing monstrosities such as

  @{verbatim \<open>
    case t of
      Const ("Pure.imp", _) $
        P $
        Const (@{const_name Trueprop}, _) $
          (Const ("HOL.eq", _) $
            (Const (@{const_name "my_func"}, _) $ x) $ y)
      => (P, x, y)
  \<close>}

  simply use a term pattern with variables:

  @{verbatim \<open>
    case t of
      @{term_pat "PROP ?P \<Longrightarrow> my_func ?x = ?y"} => (P, x, y)
  \<close>}

  Each term_pat generates an ML pattern that can be used in any
  case-expression or name binding.
  The ML pattern matches directly on the term datatype; it does not
  perform matching in the Isabelle logic.

  Schematic variables in the pattern generate ML variables.
  The variables must obey ML's pattern matching rules, i.e.
  each can appear only once.

  Due to the difficulty of enforcing this rule for type variables,
  schematic type variables are ignored and not checked.
\<close>

text \<open>
  Example: evaluate arithmetic expressions in ML.
\<close>
ML_val {*
fun eval_num @{term_pat "numeral ?n"} = HOLogic.dest_numeral n
  | eval_num @{term_pat "Suc ?n"} = eval_num n + 1
  | eval_num @{term_pat "0"} = 0
  | eval_num @{term_pat "1"} = 1
  | eval_num @{term_pat "?x + ?y"} = eval_num x + eval_num y
  | eval_num @{term_pat "?x - ?y"} = eval_num x - eval_num y
  | eval_num @{term_pat "?x * ?y"} = eval_num x * eval_num y
  | eval_num @{term_pat "?x div ?y"} = eval_num x div eval_num y
  | eval_num t = raise TERM ("eval_num", [t]);

eval_num @{term "(1 + 2) * 3 - 4 div 5"}
*}

text \<open>Regression test: backslash handling\<close>
ML_val {*
val @{term_pat "\<alpha>"} = @{term "\<alpha>"}
*}

text \<open>Regression test: special-casing for dummy vars\<close>
ML_val {*
val @{term_pat "\<lambda>x y. _"} = @{term "\<lambda>x y. z"}
*}

end