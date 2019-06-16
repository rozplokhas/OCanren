module Binding :
  sig
    type t =
      { var   : Var.t
      ; term  : Term.t
      }

    val is_relevant : Env.t -> VarSet.t -> t -> bool

    val equal : t -> t -> bool
    val compare : t -> t -> int
    val hash : t -> int
  end

type t

val empty : t

val of_list : Binding.t list -> t
val of_map  : Term.t VarMap.t -> t

val split : t -> Binding.t list

(* [apply env subst x] - applies [subst] to term [x],
 *   i.e. replaces every variable to relevant binding in [subst];
 *)
val apply : Env.t -> t -> 'a -> 'a

(* [is_bound x subst] - checks whether [x] is bound by [subst] *)
val is_bound : Var.t -> t -> bool

(* [freevars env subst x] - returns all free-variables of term [x] *)
val freevars : Env.t -> t -> 'a -> VarSet.t

(* [unify ~subsume ~scope env subst x y] performs unification of two terms [x] and [y] in [subst].
 *   Unification is a process of finding substituion [s] s.t. [s(x) = s(y)].
 *   Returns [None] if two terms are not unifiable.
 *   Otherwise it returns a pair of diff and new substituion.
 *   Diff is a list of pairs (var, term) that were added to the original substituion.
 *
 *   If [subsume] argument is passed and [true] then substituion binds variables only from left term,
 *   (i.e. it returns [s] s.t. [s(x) = y]).
 *   This can be used to perform subsumption check:
 *   [y] is subsumed by [x] (i.e. [x] is more general than [x]) if such a unification succeeds.
 *)
val unify : ?subsume:bool -> ?scope:Var.scope -> Env.t -> t -> 'a -> 'a -> (Binding.t list * t) option

val merge_disjoint : Env.t -> t -> t -> t

(* [merge env s1 s2] merges two substituions *)
val merge : Env.t -> t -> t -> t option

(* [subsumed env s1 s2] checks that [s1] is subsumed by [s2] (i.e. [s2] is more general than [s1]).
 *   Subsumption relation forms a partial order on the set of substitutions.
 *)
val subsumed : Env.t -> t -> t -> bool

module Answer :
  sig
    type t = Term.t

    (* [subsumed env x y] checks that [x] is subsumed by [y] (i.e. [y] is more general than [x]) *)
    val subsumed : Env.t -> t -> t -> bool
  end

val reify : Env.t -> t -> 'a -> Answer.t