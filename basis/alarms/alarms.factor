! Copyright (C) 2005, 2008 Slava Pestov, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs calendar combinators.short-circuit fry
heaps init kernel math math.functions math.parser namespaces
quotations sequences system threads ;
IN: alarms

TUPLE: alarm
    { quot callable initial: [ ] }
    start-nanos 
    delay-nanos
    interval-nanos
    iteration-start-nanos
    { stop? boolean }
    thread ;

<PRIVATE

GENERIC: >nanoseconds ( obj -- duration/f )
M: f >nanoseconds ;
M: real >nanoseconds >integer ;
M: duration >nanoseconds duration>nanoseconds >integer ;

: set-next-alarm-time ( alarm -- alarm )
    ! start + delay + ceiling((now - (start + delay)) / interval) * interval
    nano-count 
    over start-nanos>> -
    over delay-nanos>> [ - ] when*
    over interval-nanos>> / ceiling
    over interval-nanos>> *
    over start-nanos>> +
    over delay-nanos>> [ + ] when*
    >>iteration-start-nanos ; inline

DEFER: call-alarm-loop

: loop-alarm ( alarm -- )
    nano-count over
    [ iteration-start-nanos>> - ] [ interval-nanos>> ] bi <
    [ set-next-alarm-time ] dip
    [ dup iteration-start-nanos>> ] [ 0 ] if
    sleep-until call-alarm-loop ;

: maybe-loop-alarm ( alarm -- )
    dup { [ stop?>> ] [ interval-nanos>> not ] } 1||
    [ drop ] [ loop-alarm ] if ;

: call-alarm-loop ( alarm -- )
    dup stop?>> [
        drop
    ] [
        [ quot>> call( -- ) ] keep
        maybe-loop-alarm
    ] if ;

: call-alarm ( alarm -- )
    '[
        _ self >>thread
        [ delay-nanos>> [ sleep ] when* ]
        [ nano-count >>iteration-start-nanos call-alarm-loop ] bi
    ] "Alarm execution" spawn drop ;

PRIVATE>

: <alarm> ( quot delay-duration/f interval-duration/f -- alarm )
    alarm new
        swap >nanoseconds >>interval-nanos
        swap >nanoseconds >>delay-nanos
        swap >>quot ; inline

: start-alarm ( alarm -- )
    f >>stop?
    nano-count >>start-nanos
    call-alarm ;

: stop-alarm ( alarm -- )
    t >>stop?
    f >>start-nanos
    drop ;

<PRIVATE

: (start-alarm) ( quot start-duration interval-duration -- alarm )
    <alarm> [ start-alarm ] keep ;

PRIVATE>

: every ( quot interval-duration -- alarm )
    [ f ] dip (start-alarm) ;

: later ( quot delay-duration -- alarm )
    f (start-alarm) ;

: delayed-every ( quot duration -- alarm )
    dup (start-alarm) ;
