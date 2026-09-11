*&---------------------------------------------------------------------*
*& Report ZDP_CHAINOFRESP
*&---------------------------------------------------------------------*
*& Pattern:  Chain of Responsibility (Behavioral)
*& Intent:   Avoid coupling the sender of a request to its receiver by
*&           giving more than one object a chance to handle the request.
*&           Chain the receiving objects and pass the request along the
*&           chain until one of them handles it.
*&
*& How this example implements it:
*&   - `handler` is the abstract link in the chain. It knows exactly one
*&     thing about the rest of the chain: its `successor`.
*&   - `concrete_handler1/2/3` each own a fixed range of request numbers
*&     (0-9, 10-19, 20-29). A handler that recognises the request answers
*&     it; otherwise it simply forwards the request to its successor.
*&   - The demo wires the chain as handler1 -> handler2 -> handler3 and
*&     then sends *every* request to handler1 only. The caller never
*&     decides who handles what -- the chain does.
*&   - `class_name( )` is only a display helper: it trims the runtime
*&     type name down to the bare class name for the demo output.
*&---------------------------------------------------------------------*
REPORT zdp_chainofresp.

TYPES request_list TYPE STANDARD TABLE OF i WITH EMPTY KEY.


CLASS handler DEFINITION ABSTRACT.

  PUBLIC SECTION.
    "! Hooks the next handler of the chain in behind this one.
    METHODS set_successor
      IMPORTING successor TYPE REF TO handler.

    "! Handles the request, or passes it on to the successor.
    METHODS handle_request ABSTRACT
      IMPORTING request TYPE i.

  PROTECTED SECTION.
    "! Next link in the chain. Unbound for the last handler.
    DATA successor TYPE REF TO handler.

    "! Bare class name of the running handler, used for the demo output.
    METHODS class_name
      RETURNING VALUE(result) TYPE string.

ENDCLASS.


CLASS handler IMPLEMENTATION.

  METHOD set_successor.
    me->successor = successor.
  ENDMETHOD.

  METHOD class_name.
    DATA match_offset TYPE i.
    DATA match_length TYPE i.
    DATA places       TYPE i.

    result = cl_abap_classdescr=>get_class_name( me ).
    FIND REGEX 'CLASS=' IN result MATCH OFFSET match_offset MATCH LENGTH match_length.
    places = match_offset + match_length.
    SHIFT result BY places PLACES LEFT.
  ENDMETHOD.

ENDCLASS.


CLASS concrete_handler1 DEFINITION INHERITING FROM handler.

  PUBLIC SECTION.
    "! Handles requests 0..9, forwards everything else.
    METHODS handle_request REDEFINITION.

ENDCLASS.


CLASS concrete_handler1 IMPLEMENTATION.

  METHOD handle_request.
    IF request >= 0 AND request < 10.
      cl_demo_output=>write( |{ class_name( ) } handled request { request }| ).
    ELSEIF successor IS BOUND.
      successor->handle_request( request ).
    ENDIF.
  ENDMETHOD.

ENDCLASS.


CLASS concrete_handler2 DEFINITION INHERITING FROM handler.

  PUBLIC SECTION.
    "! Handles requests 10..19, forwards everything else.
    METHODS handle_request REDEFINITION.

ENDCLASS.


CLASS concrete_handler2 IMPLEMENTATION.

  METHOD handle_request.
    IF request >= 10 AND request < 20.
      cl_demo_output=>write( |{ class_name( ) } handled request { request }| ).
    ELSEIF successor IS BOUND.
      successor->handle_request( request ).
    ENDIF.
  ENDMETHOD.

ENDCLASS.


CLASS concrete_handler3 DEFINITION INHERITING FROM handler.

  PUBLIC SECTION.
    "! Handles requests 20..29, forwards everything else.
    METHODS handle_request REDEFINITION.

ENDCLASS.


CLASS concrete_handler3 IMPLEMENTATION.

  METHOD handle_request.
    IF request >= 20 AND request < 30.
      cl_demo_output=>write( |{ class_name( ) } handled request { request }| ).
    ELSEIF successor IS BOUND.
      successor->handle_request( request ).
    ENDIF.
  ENDMETHOD.

ENDCLASS.


START-OF-SELECTION.

  " Build the chain: first -> second -> third. The last one has no successor.
  DATA(first)  = NEW concrete_handler1( ).
  DATA(second) = NEW concrete_handler2( ).
  DATA(third)  = NEW concrete_handler3( ).

  first->set_successor( second ).
  second->set_successor( third ).

  DATA(requests) = VALUE request_list( ( 2 ) ( 5 ) ( 14 ) ( 22 ) ( 18 ) ( 3 ) ( 27 ) ( 20 ) ).

  cl_demo_output=>write( |Every request below is handed to concrete_handler1 only -- | &&
                         |the chain itself works out who is able to answer it.| ).

  LOOP AT requests INTO DATA(request).
    first->handle_request( request ).
  ENDLOOP.

  cl_demo_output=>display( ).
