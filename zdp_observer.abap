*&---------------------------------------------------------------------*
*& Report ZDP_OBSERVER
*&---------------------------------------------------------------------*
*& Pattern:  Observer (Behavioral)
*& Intent:   Define a one-to-many dependency between objects so that
*&           when one object changes state, all its dependents are
*&           notified and updated automatically.
*&
*& How this example implements it:
*&   - `lcl_main_process` is the subject. It owns the state and
*&     publishes the ABAP event `state_changed`, which carries the new
*&     state to whoever is listening.
*&   - `set_state` changes the state and then raises the event -- the
*&     subject never needs to know who (or how many) are listening.
*&   - `lcl_observer` is the abstract observer. It declares the
*&     abstract handler method `on_state_changed FOR EVENT
*&     state_changed OF lcl_main_process`.
*&   - `lcl_alv_observer` and `lcl_db_observer` are concrete observers
*&     that redefine the handler and each react in their own way.
*&   - `SET HANDLER ... FOR ...` in the demo block is the registration
*&     step (attach/subscribe) of the pattern.
*&---------------------------------------------------------------------*
PROGRAM zdp_observer.


CLASS lcl_main_process DEFINITION.

  PUBLIC SECTION.
    "! Stores the new state and notifies every registered observer
    "! by raising the state_changed event.
    METHODS set_state
      IMPORTING state TYPE char1.

    "! Raised after the process state changed; carries the new state.
    EVENTS state_changed
      EXPORTING VALUE(new_state) TYPE char1.

  PRIVATE SECTION.
    DATA current_state TYPE char1.

ENDCLASS.


CLASS lcl_main_process IMPLEMENTATION.

  METHOD set_state.
    current_state = state.
    cl_demo_output=>write( |Main process new state: { current_state }| ).
    RAISE EVENT state_changed EXPORTING new_state = current_state.
  ENDMETHOD.

ENDCLASS.


CLASS lcl_observer DEFINITION ABSTRACT.

  PUBLIC SECTION.
    "! Event handler every concrete observer must redefine. It is
    "! called automatically whenever the subject raises state_changed.
    METHODS on_state_changed ABSTRACT
      FOR EVENT state_changed OF lcl_main_process
      IMPORTING new_state.

ENDCLASS.


CLASS lcl_alv_observer DEFINITION INHERITING FROM lcl_observer.

  PUBLIC SECTION.
    METHODS on_state_changed REDEFINITION.

ENDCLASS.


CLASS lcl_alv_observer IMPLEMENTATION.

  METHOD on_state_changed.
    cl_demo_output=>write( |  ALV processing reacted to new state: { new_state }| ).
  ENDMETHOD.

ENDCLASS.


CLASS lcl_db_observer DEFINITION INHERITING FROM lcl_observer.

  PUBLIC SECTION.
    METHODS on_state_changed REDEFINITION.

ENDCLASS.


CLASS lcl_db_observer IMPLEMENTATION.

  METHOD on_state_changed.
    cl_demo_output=>write( |  DB processing reacted to new state: { new_state }| ).
  ENDMETHOD.

ENDCLASS.


START-OF-SELECTION.

  " The subject: it does not know anything about its observers.
  DATA(process) = NEW lcl_main_process( ).

  " Two independent observers, each with its own reaction.
  DATA(alv_observer) = NEW lcl_alv_observer( ).
  DATA(db_observer)  = NEW lcl_db_observer( ).

  " Registration (attach): from here on both are notified automatically.
  SET HANDLER alv_observer->on_state_changed FOR process.
  SET HANDLER db_observer->on_state_changed FOR process.

  cl_demo_output=>write( |Two observers registered on the main process.| ).

  " Every state change fans out to both observers.
  process->set_state( 'A' ).
  process->set_state( 'B' ).
  process->set_state( 'C' ).

  cl_demo_output=>display( ).
