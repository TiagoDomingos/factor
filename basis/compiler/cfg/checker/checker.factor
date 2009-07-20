! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel combinators.short-circuit accessors math sequences sets
assocs compiler.cfg.instructions compiler.cfg.rpo compiler.cfg.def-use
compiler.cfg.linearization compiler.cfg.liveness
compiler.cfg.utilities ;
IN: compiler.cfg.checker

ERROR: bad-kill-block bb ;

: check-kill-block ( bb -- )
    dup instructions>> first2
    swap ##epilogue? [ [ ##return? ] [ ##callback-return? ] bi or ] [ ##branch? ] if
    [ drop ] [ bad-kill-block ] if ;

ERROR: last-insn-not-a-jump bb ;

: check-last-instruction ( bb -- )
    dup instructions>> last {
        [ ##branch? ]
        [ ##dispatch? ]
        [ ##conditional-branch? ]
        [ ##compare-imm-branch? ]
        [ ##fixnum-add? ]
        [ ##fixnum-sub? ]
        [ ##fixnum-mul? ]
        [ ##no-tco? ]
    } 1|| [ drop ] [ last-insn-not-a-jump ] if ;

ERROR: bad-loop-entry bb ;

: check-loop-entry ( bb -- )
    dup instructions>> dup length 2 >= [
        2 head* [ ##loop-entry? ] any?
        [ bad-loop-entry ] [ drop ] if
    ] [ 2drop ] if ;

ERROR: bad-kill-insn bb ;

: check-kill-instructions ( bb -- )
    dup instructions>> [ kill-vreg-insn? ] any?
    [ bad-kill-insn ] [ drop ] if ;

: check-normal-block ( bb -- )
    [ check-loop-entry ]
    [ check-last-instruction ]
    [ check-kill-instructions ]
    tri ;

ERROR: bad-successors ;

: check-successors ( bb -- )
    dup successors>> [ predecessors>> memq? ] with all?
    [ bad-successors ] unless ;

: check-basic-block ( bb -- )
    [ dup kill-block? [ check-kill-block ] [ check-normal-block ] if ]
    [ check-successors ]
    bi ;

ERROR: bad-live-in ;

ERROR: undefined-values uses defs ;

: check-mr ( mr -- )
    ! Check that every used register has a definition
    instructions>>
    [ [ uses-vregs ] map concat ]
    [ [ [ defs-vregs ] [ temp-vregs ] bi append ] map concat ] bi
    2dup subset? [ 2drop ] [ undefined-values ] if ;

: check-cfg ( cfg -- )
    compute-liveness
    [ entry>> live-in assoc-empty? [ bad-live-in ] unless ]
    [ [ check-basic-block ] each-basic-block ]
    [ flatten-cfg check-mr ]
    tri ;
