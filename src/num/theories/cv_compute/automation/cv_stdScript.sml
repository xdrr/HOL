(*
  Apply cv translator to standard theories list, pair, sptree, etc.
*)
open HolKernel Parse boolLib bossLib;
open cv_typeTheory cvTheory cv_typeLib cv_repLib;
open arithmeticTheory wordsTheory cv_repTheory cv_primTheory cv_transLib;
open pairTheory listTheory optionTheory sumTheory alistTheory indexedListsTheory;
open rich_listTheory sptreeTheory;

val _ = new_theory "cv_std";

(*----------------------------------------------------------*
   pair
 *----------------------------------------------------------*)

val _ = cv_rep_for [] “(x:'a, y:'b)”

Theorem cv_FST[cv_rep]:
  f_a (FST v) = cv_fst ((from_pair f_a f_b) (v: 'a # 'b))
Proof
  Cases_on ‘v’ \\ gvs [from_pair_def]
QED

Theorem cv_SND[cv_rep]:
  f_b (SND v) = cv_snd ((from_pair f_a f_b) (v: 'a # 'b))
Proof
  Cases_on ‘v’ \\ gvs [from_pair_def]
QED

(*----------------------------------------------------------*
   option
 *----------------------------------------------------------*)

val _ = cv_rep_for [] “SOME (x:'a)”

Theorem cv_THE[cv_rep]:
  v <> NONE ==> f_a (THE v) = cv_snd ((from_option f_a) (v:'a option))
Proof
  Cases_on ‘v’ \\ gvs [from_option_def]
QED

Theorem cv_IS_SOME[cv_rep]:
  b2c (IS_SOME v) = cv_ispair ((from_option f_a) (v:'a option))
Proof
  Cases_on ‘v’ \\ gvs [from_option_def]
QED

Theorem cv_IS_NONE[cv_rep]:
  b2c (IS_NONE v) = cv_sub (Num 1) (cv_ispair ((from_option f_a) (v:'a option)))
Proof
  Cases_on ‘v’ \\ gvs [from_option_def]
QED

(*----------------------------------------------------------*
   sum
 *----------------------------------------------------------*)

val res = cv_trans ISL;
val res = cv_trans ISR;

val res = cv_trans_pre OUTL;

Theorem OUTL_pre[cv_pre]:
  OUTL_pre x <=> ISL x
Proof
  Cases_on ‘x’ \\ fs [res]
QED

val res = cv_trans_pre OUTR;

Theorem OUTR_pre[cv_pre]:
  OUTR_pre x <=> ISR x
Proof
  Cases_on ‘x’ \\ fs [res]
QED

(*----------------------------------------------------------*
   list
 *----------------------------------------------------------*)

Theorem cv_HD[cv_rep]:
  v <> [] ==> f_a (HD v) = cv_fst ((from_list f_a) (v:'a list))
Proof
  Cases_on ‘v’ \\ fs [from_list_def]
QED

Theorem cv_TL[cv_rep]:
  (from_list f_a) (TL v) = cv_snd ((from_list f_a) (v:'a list))
Proof
  Cases_on ‘v’ \\ fs [from_list_def]
QED

val res = cv_trans oHD_def;
val res = cv_trans NULL_DEF;
val res = cv_trans oEL_def;

val res = cv_trans SNOC;
val res = cv_trans APPEND;

val res = cv_trans FLAT;

val res = cv_trans TAKE_def;

val res = cv_trans DROP_def;

val res = cv_trans_pre EL;

Theorem EL_pre[cv_pre]:
  !n xs. EL_pre n xs <=> n < LENGTH xs
Proof
  Induct \\ rw [] \\ simp [Once res] \\ Cases_on ‘xs’ \\ gvs []
QED

val res = cv_trans LEN_DEF;
val res = cv_trans LENGTH_LEN;

val res = cv_trans REV_DEF;
val res = cv_trans REVERSE_REV;

val res = cv_trans SUM_ACC_DEF;
val res = cv_trans SUM_SUM_ACC;

Theorem FRONT[local]:
  FRONT (x::xs) = case xs of [] => [] | _ => x :: FRONT xs
Proof
  Cases_on ‘xs’ \\ gvs [FRONT_DEF]
QED

val res = cv_trans_pre FRONT;

Theorem FRONT_pre[cv_pre]:
  !xs. FRONT_pre xs <=> xs <> []
Proof
  Induct_on ‘xs’
  \\ once_rewrite_tac [res] \\ gvs []
  \\ Cases_on ‘xs’ \\ gvs []
QED

Theorem LAST[local]:
  LAST (x::xs) = case xs of [] => x | _ => LAST xs
Proof
  Cases_on ‘xs’ \\ gvs [LAST_DEF]
QED

val res = cv_trans_pre LAST;

Theorem LAST_pre[cv_pre]:
  !xs. LAST_pre xs <=> xs <> []
Proof
  Induct_on ‘xs’
  \\ once_rewrite_tac [res] \\ gvs []
  \\ Cases_on ‘xs’ \\ gvs []
QED

Definition list_mem_def:
  list_mem y [] = F /\
  list_mem y (x::xs) = if x = y then T else list_mem y xs
End

val res = cv_trans list_mem_def;

val lemma = cv_rep_for [] “list_mem x xs” |> DISCH_ALL

Theorem cv_rep_MEM[cv_rep]:
  from_to f_a t_a ==>
  cv_rep T (cv_list_mem (f_a x) (from_list f_a xs)) b2c (MEM (x:'a) xs)
Proof
  qsuff_tac ‘MEM x xs = list_mem x xs’
  >- (simp [] \\ mp_tac lemma \\ fs [])
  \\ Induct_on ‘xs’ \\ gvs [list_mem_def] \\ metis_tac []
QED

Triviality conj_eq_if:
  x /\ y <=> if x then y else F
Proof
  Cases_on ‘x’ \\ gvs []
QED

Triviality if_not:
  (if ~b then x else y) = if b then y else x
Proof
  Cases_on ‘b’ \\ gvs []
QED

val all_distinct =
  ALL_DISTINCT |> DefnBase.one_line_ify NONE |> PURE_REWRITE_RULE [conj_eq_if,if_not]

val res = cv_trans all_distinct;

val is_prefix =
  isPREFIX |> DefnBase.one_line_ify NONE |> PURE_REWRITE_RULE [conj_eq_if,if_not]

val res = cv_trans is_prefix;

val res = cv_trans LUPDATE_DEF;

Triviality index_of:
  INDEX_OF x [] = NONE /\
  INDEX_OF x (y::ys) =
    if x = y then SOME 0 else
      case INDEX_OF x ys of
      | NONE => NONE
      | SOME n => SOME (n+1)
Proof
  gvs [INDEX_OF_def,INDEX_FIND_def]
  \\ rw [] \\ gvs []
  \\ simp [Once listTheory.INDEX_FIND_add]
  \\ Cases_on ‘INDEX_FIND 0 ($= x) ys’ \\ gvs []
  \\ rename [‘_ = SOME y’] \\ PairCases_on ‘y’ \\ gvs []
QED

val res = cv_trans_pre index_of;

Definition replicate_acc_def:
  replicate_acc n x acc =
    if n = 0:num then acc else replicate_acc (n-1) x (x::acc)
End

val res = cv_trans replicate_acc_def;

Theorem REPLICATE:
  REPLICATE n c = replicate_acc n c []
Proof
  qsuff_tac ‘!n c acc. replicate_acc n c acc = REPLICATE n c ++ acc’ >- gvs []
  \\ Induct \\ gvs [] \\ simp [Once replicate_acc_def]
  \\ rewrite_tac [GSYM SNOC_APPEND,SNOC_REPLICATE] \\ gvs []
QED

val res = cv_trans REPLICATE;
val res = cv_trans (PAD_LEFT |> REWRITE_RULE [GSYM REPLICATE_GENLIST]);
val res = cv_trans (PAD_RIGHT |> REWRITE_RULE [GSYM REPLICATE_GENLIST]);

val res = cv_trans nub_def;

val res = cv_trans ALOOKUP_def

val res = cv_trans findi_def (* TODO: improve *)

val res = cv_trans ZIP_def;

Theorem UNZIP_eq:
  UNZIP ts =
    case ts of
    | [] => ([],[])
    | (x::xs) => let (t1,t2) = UNZIP xs in (FST x :: t1, SND x :: t2)
Proof
  Cases_on ‘ts’ \\ gvs []
  \\ gvs [UNZIP] \\ Cases_on ‘UNZIP t’ \\ gvs []
QED

val res = cv_trans UNZIP_eq

Definition genlist_def:
  genlist i f 0 = [] /\
  genlist i f (SUC n) = f i :: genlist (i+1:num) f n
End

Theorem genlist_eq_GENLIST[cv_inline]:
  GENLIST = genlist 0
Proof
  qsuff_tac ‘!i f n. genlist i f n = GENLIST (f o (λk. k + i)) n’
  >- (gvs [FUN_EQ_THM] \\ rw [] \\ AP_THM_TAC \\ AP_TERM_TAC \\ gvs [FUN_EQ_THM])
  \\ Induct_on ‘n’ \\ gvs [genlist_def]
  \\ rewrite_tac [listTheory.GENLIST_CONS] \\ gvs []
  \\ rw [] \\ AP_THM_TAC \\ AP_TERM_TAC \\ gvs [FUN_EQ_THM,arithmeticTheory.ADD1]
QED

Definition count_loop_def:
  count_loop n k = if n = 0:num then [] else k::count_loop (n-1) (k+1:num)
End

val res = cv_trans count_loop_def;

Theorem cv_COUNT_LIST[cv_inline]:
  COUNT_LIST n = count_loop n 0
Proof
  qsuff_tac `!n k. count_loop n k = MAP (\i. i + k) (COUNT_LIST n)` >>
  simp[] >>
  Induct \\ rw[] \\ simp [rich_listTheory.COUNT_LIST_def,Once count_loop_def]
  \\ gvs [MAP_MAP_o,combinTheory.o_DEF,ADD1] \\ AP_THM_TAC \\ AP_TERM_TAC
  \\ gvs [FUN_EQ_THM]
QED

Theorem K_THM[cv_inline] = combinTheory.K_THM;
Theorem I_THM[cv_inline] = combinTheory.I_THM;
Theorem o_THM[cv_inline] = combinTheory.o_THM;

Definition list_mapi_def:
  list_mapi i f [] = [] /\
  list_mapi i f (x::xs) = f i x :: list_mapi (i + 1n) f xs
End

Theorem MAPi_eq_list_mapi[cv_inline]:
  MAPi = list_mapi 0
Proof
  qsuff_tac `!l i f. list_mapi i f l = MAPi (f o (λn. n + i)) l`
  >- gvs[FUN_EQ_THM, combinTheory.o_DEF, SF ETA_ss] >>
  Induct >> rw[list_mapi_def] >> gvs[combinTheory.o_DEF, ADD1]
QED

Definition cv_map_fst_def:
  cv_map_fst cv =
    cv_if (cv_ispair cv)
      (Pair (cv_fst (cv_fst cv)) (cv_map_fst (cv_snd cv)))
      (Num 0)
Termination
  WF_REL_TAC ‘measure cv_size’ >> cv_termination_tac
End

Theorem cv_MAP_FST[cv_rep]:
  from_list a (MAP FST l) = cv_map_fst (from_list (from_pair a b) l)
Proof
  Induct_on `l` >> rw[from_list_def] >>
  simp[Once cv_map_fst_def, SimpRHS] >>
  Cases_on `h` >> gvs[from_pair_def]
QED

Definition cv_map_snd_def:
  cv_map_snd cv =
    cv_if (cv_ispair cv)
      (Pair (cv_snd (cv_fst cv)) (cv_map_snd (cv_snd cv)))
      (Num 0)
Termination
  WF_REL_TAC ‘measure cv_size’ >> cv_termination_tac
End

Theorem cv_MAP_SND[cv_rep]:
  from_list b (MAP SND l) = cv_map_snd (from_list (from_pair a b) l)
Proof
  Induct_on `l` >> rw[from_list_def] >>
  simp[Once cv_map_snd_def, SimpRHS] >>
  Cases_on `h` >> gvs[from_pair_def]
QED

(*----------------------------------------------------------*
   sptree / num_map / num_set
 *----------------------------------------------------------*)

val res = cv_trans sptreeTheory.insert_def;
val res = cv_trans sptreeTheory.lookup_def;

val def = sptreeTheory.fromList_def;
val res = cv_auto_trans sptreeTheory.fromList_def;

val res = cv_trans sptreeTheory.mk_BN_def;
val res = cv_trans sptreeTheory.mk_BS_def;
val res = cv_trans sptreeTheory.delete_def;

val res = cv_trans sptreeTheory.union_def;
val res = cv_trans sptreeTheory.inter_def;
val res = cv_trans sptreeTheory.difference_def;

val res = cv_auto_trans sptreeTheory.toList_def;
val res = cv_auto_trans sptreeTheory.mk_wf_def;
val res = cv_auto_trans sptreeTheory.size_def;

val res = cv_trans sptreeTheory.list_to_num_set_def;
val res = cv_trans sptreeTheory.list_insert_def;
val res = cv_trans sptreeTheory.alist_insert_def;

val res = cv_trans sptreeTheory.lrnext_def;

val res = cv_trans sptreeTheory.spt_center_def
val res = cv_auto_trans sptreeTheory.apsnd_cons_def;
val res = cv_auto_trans_pre sptreeTheory.spt_centers_def;

Theorem spt_centers_pre[cv_pre,local]:
  !x y. spt_centers_pre x y
Proof
  ho_match_mp_tac sptreeTheory.spt_centers_ind
  \\ rpt strip_tac \\ simp [Once res]
QED

val res = cv_trans sptreeTheory.spt_left_def
val res = cv_trans sptreeTheory.spt_right_def

val res = cv_trans sptreeTheory.subspt_eq;

val lam = sptreeTheory.toAList_def |> SPEC_ALL |> concl |> find_term is_abs;

Definition toAList_foldi_def:
  toAList_foldi = foldi ^lam
End

val toAList_foldi_eq = sptreeTheory.foldi_def
                  |> CONJUNCTS |> map (ISPEC lam)
                  |> LIST_CONJ |> REWRITE_RULE [GSYM toAList_foldi_def]
                  |> SIMP_RULE std_ss [];

val res = cv_trans_pre toAList_foldi_eq;

Theorem toAList_foldi_pre[cv_pre]:
  !a0 a1 a2. toAList_foldi_pre a0 a1 a2
Proof
  Induct_on ‘a2’ \\ gvs [] \\ simp [Once res] \\ gvs []
QED

val res = cv_trans
  (sptreeTheory.toAList_def |> REWRITE_RULE [GSYM toAList_foldi_def,FUN_EQ_THM]);

Definition cv_right_depth_def:
  cv_right_depth (Num _) = 0:num /\
  cv_right_depth (Pair x y) = cv_right_depth y + 1
End

Definition every_empty_snd_def:
  every_empty_snd [] = T /\
  every_empty_snd ((n,x)::xs) = if x = LN then every_empty_snd xs else F
End

Theorem every_empty_snd:
  !ys. EVERY ((\t. isEmpty t) o SND) ys = every_empty_snd ys
Proof
  Induct \\ gvs [every_empty_snd_def,FORALL_PROD]
QED

val res = cv_trans every_empty_snd_def;

Definition map_spt_right_def:
  map_spt_right [] = [] /\
  map_spt_right ((i,x)::xs) = (i, spt_right x) :: map_spt_right xs
End

Definition map_spt_left_def:
  map_spt_left [] = [] /\
  map_spt_left ((i,x)::xs) = (i, spt_left x) :: map_spt_left xs
End

Theorem map_spt_right_left:
  MAP (\(i,t). (i,spt_right t)) ys = map_spt_right ys /\
  MAP (\(i,t). (i,spt_left t)) ys = map_spt_left ys
Proof
  Induct_on ‘ys’ \\ gvs [map_spt_left_def,map_spt_right_def,FORALL_PROD]
QED

Definition combine_rle_isEmpty_def:
  combine_rle_isEmpty [] = [] /\
  combine_rle_isEmpty [t] = [t] /\
  combine_rle_isEmpty ((i,x)::(j,y)::xs) =
    if x = LN /\ y = LN then combine_rle_isEmpty ((i + j:num,x)::xs)
    else (i,x)::combine_rle_isEmpty ((j,y)::xs)
End

val _ = cv_trans_rec combine_rle_isEmpty_def
  (WF_REL_TAC ‘measure cv_size’ \\ rw []
   \\ cv_termination_tac
   \\ rename [‘cv_eq x’] \\ Cases_on ‘x’ \\ gvs [] \\ Cases_on ‘m’ \\ gvs []
   \\ rename [‘cv_eq x’] \\ Cases_on ‘x’ \\ gvs [] \\ Cases_on ‘m’ \\ gvs []
   \\ rename [‘cv_add x y’] \\ Cases_on ‘x’ \\ Cases_on ‘y’ \\ gvs [])

Triviality to_combine_rle_isEmpty:
  combine_rle isEmpty = combine_rle_isEmpty
Proof
  rw [FUN_EQ_THM]
  \\ completeInduct_on ‘LENGTH x’
  \\ rw [] \\ gvs [PULL_FORALL]
  \\ Cases_on ‘x’ \\ gvs [combine_rle_def,combine_rle_isEmpty_def]
  \\ Cases_on ‘t’ \\ gvs [combine_rle_def,combine_rle_isEmpty_def]
  \\ rename [‘x::y::_’] \\ PairCases_on ‘x’ \\ PairCases_on ‘y’
  \\ gvs [combine_rle_def,combine_rle_isEmpty_def]
  \\ IF_CASES_TAC \\ gvs []
  \\ IF_CASES_TAC \\ gvs []
QED

Definition spt_centers_acc_def:
  spt_centers_acc i xs acc =
    case xs of
    | [] => (i,acc)
    | ((j,x)::xs) =>
      case spt_center x of
      | NONE => spt_centers_acc (i + j) xs acc
      | SOME y => spt_centers_acc (i + j) xs ((i:num,y)::acc)
End

Triviality spt_centers_acc_thm:
  !i xs acc j ys.
    spt_centers i xs = (j,ys) ==>
    spt_centers_acc i xs acc = (j,REVERSE ys ++ acc)
Proof
  ho_match_mp_tac spt_centers_acc_ind
  \\ rw [] \\ pop_assum mp_tac
  \\ Cases_on ‘xs’
  \\ simp [Once spt_centers_acc_def, Once spt_centers_def]
  \\ PairCases_on ‘h’ \\ gvs [spt_centers_def]
  \\ simp [AllCaseEqs()] \\ strip_tac \\ gvs []
  \\ Cases_on ‘spt_centers (h0 + i) t’ \\ gvs [apsnd_cons_def]
QED

Triviality combine_rle_LESS_TRANS = MATCH_MP
  (LESS_LESS_EQ_TRANS |> RES_CANON |> last)
  (SPEC_ALL sum_size_combine_rle_LE);

Definition spts_to_alist_acc_def:
  spts_to_alist_acc i xs acc =
   let ys = combine_rle_isEmpty xs in
     if EVERY (isEmpty o SND) ys then REVERSE acc
     else let
            (j,acc1) = spt_centers_acc i ys acc;
            rights = MAP (\(i,t). (i,spt_right t)) ys;
            lefts = MAP (\(i,t). (i,spt_left t)) ys
          in
            spts_to_alist_acc j (rights ++ lefts) acc1
Termination
  WF_REL_TAC `measure (SUM o MAP (spt_size (K 0) o SND) o FST o SND)`
  \\ rw [MAP_MAP_o, SUM_APPEND, GSYM SUM_MAP_PLUS]
  \\ irule (combine_rle_LESS_TRANS |> REWRITE_RULE [combinTheory.o_DEF])
  \\ qexists_tac `isEmpty`
  \\ gvs [to_combine_rle_isEmpty]
  \\ irule SUM_MAP_same_LESS
  \\ fs [EVERY_MEM, EXISTS_MEM]
  \\ rw [] \\ TRY (qexists_tac `e`)
  \\ pairarg_tac \\ fs []
  \\ rename [`spt_size _ (spt_left spt)`] \\ Cases_on `spt`
  \\ fs [spt_size_def, spt_left_def, spt_right_def]
End

Triviality spts_to_alist_acc_thm:
  !i xs acc.
    spts_to_alist_acc i xs acc =
    REVERSE acc ++ spts_to_alist i xs
Proof
  ho_match_mp_tac spts_to_alist_acc_ind \\ rw []
  \\ simp [Once spts_to_alist_acc_def]
  \\ simp [Once spts_to_alist_def,to_combine_rle_isEmpty]
  \\ IF_CASES_TAC \\ gvs []
  \\ rpt (pairarg_tac \\ gvs [])
  \\ drule spt_centers_acc_thm \\ strip_tac \\ gvs []
QED

Theorem toSortedAList_acc:
  toSortedAList spt = spts_to_alist_acc 0 [(1,spt)] []
Proof
  gvs [spts_to_alist_acc_thm,toSortedAList_def]
QED

val pre = cv_auto_trans_pre spts_to_alist_acc_def;
Theorem spts_to_alist_acc_pre[cv_pre,local]:
  !i xs acc. spts_to_alist_acc_pre i xs acc
Proof
  ho_match_mp_tac spts_to_alist_acc_ind
  \\ rw [] \\ simp [Once pre]
  \\ rw [] \\ res_tac \\ gvs []
  \\ gvs [LAMBDA_PROD]
QED

val _ = cv_trans toSortedAList_acc;

(*----------------------------------------------------------*
   num |-> 'a
 *----------------------------------------------------------*)

Definition from_fmap_def:
  from_fmap (f:'a -> cv) (m: num |-> 'a) =
    from_sptree_sptree_spt f (fromAList (fmap_to_alist m))
End

Definition to_fmap_def:
  to_fmap (t:cv -> 'a) m =
    alist_to_fmap (toAList (to_sptree_spt t m))
End

Theorem from_to_fmap[cv_from_to]:
  from_to (f0:'a -> cv) t0 ==>
  from_to (from_fmap f0) (to_fmap t0)
Proof
  strip_tac
  \\ drule (fetch "-" "from_sptree_to_sptree_spt_thm")
  \\ gvs [from_fmap_def,to_fmap_def,from_to_def] \\ rw []
  \\ gvs [finite_mapTheory.TO_FLOOKUP]
  \\ gvs [FUN_EQ_THM,sptreeTheory.ALOOKUP_toAList,sptreeTheory.lookup_fromAList]
QED

Theorem cv_rep_FEMPTY[cv_rep]:
  from_fmap f FEMPTY = Num 0
Proof
  EVAL_TAC \\ gvs [] \\ EVAL_TAC
QED

Theorem cv_rep_FLOOKUP[cv_rep]:
  from_option f (FLOOKUP m n) = cv_lookup (Num n) (from_fmap f m)
Proof
  gvs [from_fmap_def,GSYM $ fetch "-" "cv_lookup_thm",sptreeTheory.lookup_fromAList]
QED

Theorem cv_rep_FUPDATE[cv_rep]:
  from_fmap f (m |+ (k,v)) = cv_insert (Num k) (f v) (from_fmap f m)
Proof
  gvs [from_fmap_def,GSYM $ fetch "-" "cv_insert_thm"] \\ AP_TERM_TAC
  \\ dep_rewrite.DEP_REWRITE_TAC [sptreeTheory.spt_eq_thm,sptreeTheory.wf_insert]
  \\ gvs [wf_fromAList,lookup_insert,lookup_fromAList,finite_mapTheory.FLOOKUP_SIMP]
  \\ rw []
QED

(*----------------------------------------------------------*
   Misc.
 *----------------------------------------------------------*)

val _ = cv_trans v2n_custom_def;

val _ = export_theory();
