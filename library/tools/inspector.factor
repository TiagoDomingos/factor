! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: inspector
USING: generic hashtables io kernel kernel-internals lists math
memory namespaces prettyprint sequences strings test unparser
vectors words ;

SYMBOL: inspecting

GENERIC: sheet ( obj -- sheet )

M: object sheet ( obj -- sheet )
    dup class "slots" word-prop
    [ second ] map
    tuck [ execute ] map-with 2list ;

PREDICATE: list nonvoid cons? ;

M: nonvoid sheet >list unit ;

M: vector sheet >list unit ;

M: array sheet >list unit ;

M: hashtable sheet hash>alist unzip 2list ;

: column ( list -- list )
    [ unparse ] map
    [ [ length ] map 0 [ max ] reduce ] keep
    [ swap CHAR: \s pad-right ] map-with ;

: describe ( obj -- list )
    sheet dup first length count swons
    dup peek over first [ set ] 2each
    [ column ] map
    seq-transpose
    [ " | " join ] map ;

: vocab-banner ( word -- )
    dup word-vocabulary [
        dup interned? [
            "This word is located in the " write
        ] [
            "This is an orphan not part of the dictionary." print
            "It claims to belong to the " write
        ] ifte
        word-vocabulary unparse write " vocabulary." print
    ] [
        drop
        "The word is a uniquely generated symbol." print
    ] ifte ;

GENERIC: extra-banner ( obj -- )

M: word extra-banner ( obj -- )
    dup vocab-banner
    metaclass [
        "This is a class whose behavior is specifed by the " write
        unparse. " metaclass." print
    ] when* ;

M: object extra-banner ( obj -- ) drop ;

: inspect-banner ( obj -- )
    "You are looking at an instance of the " write dup class unparse.
    " class:" print
    "  " write dup unparse. terpri
    "It takes up " write dup size unparse write " bytes of memory." print
    extra-banner ;

: inspect ( obj -- )
    dup inspecting set
    dup inspect-banner describe [ print ] each ;
