*&---------------------------------------------------------------------*
*& Report ZDP_STATE
*&---------------------------------------------------------------------*
*& Pattern:  State (Behavioral)
*& Intent:   Allow an object to alter its behaviour when its internal
*&           state changes. The object will appear to change its class.
*&
*& How this example implements it:
*&   - `state` is the abstract state. It declares the single abstract
*&     operation `handle`, which every concrete state must supply.
*&   - `context` is the object whose behaviour varies. It holds exactly
*&     one state reference (`current_state`) and its own `request`
*&     method does nothing itself -- it simply delegates to whichever
*&     state is currently plugged in.
*&   - `concrete_statea` and `concrete_stateb` are the two behaviours.
*&     Each one handles the request and then swaps the context over to
*&     the other state, so the transition rule lives inside the states
*&     rather than inside the context.
*&   - The demo calls `request( )` four times on the same context and
*&     the reported state alternates A -> B -> A -> B, which is the
*&     "appears to change its class" effect.
*&
*& Compare with ZDP_STATE2, which applies the same pattern to a
*& worked bank-account example where the transition is driven by the
*& account balance rather than by a plain flip-flop.
*&---------------------------------------------------------------------*
REPORT zdp_state.

CLASS context DEFINITION DEFERRED.


CLASS state DEFINITION ABSTRACT.

  PUBLIC SECTION.
    "! Handles a request on behalf of the context and decides which
    "! state the context should move to next.
    METHODS handle ABSTRACT
      IMPORTING context TYPE REF TO context.

  PROTECTED SECTION.
    "! Returns the bare local class name of an object, e.g.
    "! CONCRETE_STATEB, stripped of the program/class prefix that the
    "! runtime type description carries.
    CLASS-METHODS class_name_of
      IMPORTING instance      TYPE REF TO object
      RETURNING VALUE(result) TYPE string.

ENDCLASS.


CLASS state IMPLEMENTATION.

  METHOD class_name_of.
    DATA offset TYPE i.
    DATA length TYPE i.

    result = cl_abap_classdescr=>get_class_name( instance ).

    FIND REGEX 'CLASS=' IN result MATCH OFFSET offset MATCH LENGTH length.
    IF sy-subrc = 0.
      result = substring( val = result off = offset + length ).
    ENDIF.
  ENDMETHOD.

ENDCLASS.


CLASS context DEFINITION.

  PUBLIC SECTION.
    METHODS constructor
      IMPORTING state TYPE REF TO state.

    "! Forwards the request to the state that is currently installed.
    METHODS request.

    "! The state in force right now. Concrete states replace this
    "! reference to move the context on.
    DATA current_state TYPE REF TO state.

ENDCLASS.


CLASS context IMPLEMENTATION.

  METHOD constructor.
    me->current_state = state.
  ENDMETHOD.

  METHOD request.
    me->current_state->handle( context = me ).
  ENDMETHOD.

ENDCLASS.


CLASS concrete_statea DEFINITION INHERITING FROM state.

  PUBLIC SECTION.
    METHODS handle REDEFINITION.

ENDCLASS.


CLASS concrete_stateb DEFINITION INHERITING FROM state.

  PUBLIC SECTION.
    METHODS handle REDEFINITION.

ENDCLASS.


CLASS concrete_statea IMPLEMENTATION.

  METHOD handle.
    DATA(next_state) = NEW concrete_stateb( ).
    context->current_state = next_state.
    cl_demo_output=>write( |State: { class_name_of( next_state ) }| ).
  ENDMETHOD.

ENDCLASS.


CLASS concrete_stateb IMPLEMENTATION.

  METHOD handle.
    DATA(next_state) = NEW concrete_statea( ).
    context->current_state = next_state.
    cl_demo_output=>write( |State: { class_name_of( next_state ) }| ).
  ENDMETHOD.

ENDCLASS.


START-OF-SELECTION.

  " The context starts out in state A...
  DATA(initial_state) = NEW concrete_statea( ).
  DATA(context) = NEW context( state = initial_state ).

  cl_demo_output=>write( |Four identical calls to context->request( ) -- | &&
                         |the behaviour differs each time because the state changes.| ).

  " ...and each identical request flips it to the other state.
  context->request( ).
  context->request( ).
  context->request( ).
  context->request( ).

  cl_demo_output=>display( ).
