*&---------------------------------------------------------------------*
*& Report ZDP_FLYWEIGHT
*&---------------------------------------------------------------------*
*& Pattern:  Flyweight (Structural)
*& Intent:   Use sharing to support large numbers of fine-grained
*&           objects efficiently, by keeping the state they have in
*&           common inside the shared object and passing the rest in.
*&
*& How this example implements it:
*&   - `flyweight` is the abstract flyweight. Its `operation` method
*&     takes the *extrinsic* state as an importing parameter, so the
*&     object itself never has to store it.
*&   - `flyweight_factory` builds a small pool of `concrete_flyweight`
*&     objects once (keys 'X', 'Y', 'Z') and hands out references to
*&     those same objects via `get_flyweight` -- nothing new is created
*&     per request, the instances are shared.
*&   - `unshared_concrete_flyweight` shows the other half of the GoF
*&     structure: a flyweight subclass that is *not* pooled and is
*&     simply instantiated directly by the client.
*&---------------------------------------------------------------------*
REPORT zdp_flyweight.

CLASS flyweight DEFINITION ABSTRACT.
  PUBLIC SECTION.
    "! Performs the flyweight's work. The state that varies per call
    "! (the extrinsic state) is passed in instead of being stored.
    METHODS operation ABSTRACT
      IMPORTING extrinsic_state TYPE i.
ENDCLASS.


CLASS concrete_flyweight DEFINITION INHERITING FROM flyweight.
  PUBLIC SECTION.
    METHODS operation REDEFINITION.
ENDCLASS.


CLASS concrete_flyweight IMPLEMENTATION.
  METHOD operation.
    cl_demo_output=>write( |ConcreteFlyweight (shared) -- extrinsic state: { extrinsic_state }| ).
  ENDMETHOD.
ENDCLASS.


CLASS unshared_concrete_flyweight DEFINITION INHERITING FROM flyweight.
  PUBLIC SECTION.
    METHODS operation REDEFINITION.
ENDCLASS.


CLASS unshared_concrete_flyweight IMPLEMENTATION.
  METHOD operation.
    cl_demo_output=>write( |UnsharedConcreteFlyweight -- extrinsic state: { extrinsic_state }| ).
  ENDMETHOD.
ENDCLASS.


CLASS flyweight_factory DEFINITION.
  PUBLIC SECTION.
    TYPES: BEGIN OF ty_flyweight,
             key   TYPE c LENGTH 1,
             value TYPE REF TO concrete_flyweight,
           END OF ty_flyweight.

    "! Fills the pool with the shared flyweight instances.
    METHODS constructor.

    "! Returns the pooled flyweight for the given key. Callers always
    "! get the same shared instance back -- no new object is created.
    METHODS get_flyweight
      IMPORTING flyweight_key TYPE c
      RETURNING VALUE(result) TYPE REF TO flyweight.

  PRIVATE SECTION.
    "! The pool of shared flyweights, keyed by their identifier.
    DATA flyweights TYPE HASHED TABLE OF ty_flyweight WITH UNIQUE KEY key.
ENDCLASS.


CLASS flyweight_factory IMPLEMENTATION.
  METHOD constructor.

    DATA buffer TYPE ty_flyweight.

    buffer-key   = 'X'.
    buffer-value = NEW concrete_flyweight( ).
    INSERT buffer INTO TABLE flyweights.

    buffer-key   = 'Y'.
    buffer-value = NEW concrete_flyweight( ).
    INSERT buffer INTO TABLE flyweights.

    buffer-key   = 'Z'.
    buffer-value = NEW concrete_flyweight( ).
    INSERT buffer INTO TABLE flyweights.

  ENDMETHOD.

  METHOD get_flyweight.
    DATA buffer TYPE ty_flyweight.
    READ TABLE flyweights WITH TABLE KEY key = flyweight_key INTO buffer.
    result = buffer-value.
  ENDMETHOD.
ENDCLASS.


CLASS mainapp DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS main.
ENDCLASS.


CLASS mainapp IMPLEMENTATION.
  METHOD main.

    " The extrinsic state lives with the client, not with the flyweights.
    DATA(extrinsic_state) = 22.

    DATA(factory) = NEW flyweight_factory( ).

    cl_demo_output=>write( |Asking the factory for the shared flyweights 'X', 'Y' and 'Z'| ).

    DATA(flyweight_x) = factory->get_flyweight( 'X' ).
    SUBTRACT 1 FROM extrinsic_state.
    flyweight_x->operation( extrinsic_state ).

    SUBTRACT 1 FROM extrinsic_state.
    DATA(flyweight_y) = factory->get_flyweight( 'Y' ).
    flyweight_y->operation( extrinsic_state ).

    SUBTRACT 1 FROM extrinsic_state.
    DATA(flyweight_z) = factory->get_flyweight( 'Z' ).
    flyweight_z->operation( extrinsic_state ).

    " The unshared flyweight is created by the client itself.
    SUBTRACT 1 FROM extrinsic_state.
    cl_demo_output=>write( |An unshared flyweight is created directly by the client| ).
    DATA(unshared_flyweight) = NEW unshared_concrete_flyweight( ).
    unshared_flyweight->operation( extrinsic_state ).

    cl_demo_output=>display( ).

  ENDMETHOD.
ENDCLASS.


START-OF-SELECTION.
  mainapp=>main( ).
