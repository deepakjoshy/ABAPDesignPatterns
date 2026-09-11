*&---------------------------------------------------------------------*
*& Report ZDP_PROTOTYPE
*&---------------------------------------------------------------------*
*& Pattern:  Prototype (Creational)
*& Intent:   Specify the kinds of objects to create using a prototypical
*&           instance, and create new objects by copying that prototype.
*&
*& How this example implements it:
*&   - `prototype` is the abstract prototype. It carries the state that
*&     a copy would have to reproduce (`id`) and declares the abstract
*&     `clone` method that every concrete prototype must supply.
*&   - `concrete_prototype1` and `concrete_prototype2` are the two
*&     prototypical instances. Each one redefines `clone` and is the
*&     sole authority on how a copy of itself is produced.
*&   - The client never names a concrete class when it needs another
*&     object: it holds a prototype, calls `clone( )`, and casts the
*&     result back down to the concrete type it expects.
*&
*& Note on this particular implementation:
*&   `clone` here returns `me` -- the prototype hands back a reference
*&   to itself rather than a freshly copied object. That is the original
*&   behaviour of this report and it is kept unchanged; a production
*&   implementation would build a new instance (or use the runtime's
*&   deep-copy support) inside `clone`.
*&---------------------------------------------------------------------*
REPORT zdp_prototype.


CLASS prototype DEFINITION ABSTRACT.

  PUBLIC SECTION.
    METHODS constructor
      IMPORTING id TYPE string.

    "! Returns the identifier this prototype was created with.
    METHODS get_id
      RETURNING VALUE(result) TYPE string.

    "! Produces a copy of this prototype. Every concrete prototype
    "! decides for itself how it is copied.
    METHODS clone ABSTRACT
      RETURNING VALUE(result) TYPE REF TO prototype.

  PRIVATE SECTION.
    DATA id TYPE string.

ENDCLASS.


CLASS prototype IMPLEMENTATION.

  METHOD constructor.
    me->id = id.
  ENDMETHOD.

  METHOD get_id.
    result = me->id.
  ENDMETHOD.

ENDCLASS.


CLASS concrete_prototype1 DEFINITION INHERITING FROM prototype.

  PUBLIC SECTION.
    METHODS clone REDEFINITION.

ENDCLASS.


CLASS concrete_prototype1 IMPLEMENTATION.

  METHOD clone.
    result = me.
  ENDMETHOD.

ENDCLASS.


CLASS concrete_prototype2 DEFINITION INHERITING FROM prototype.

  PUBLIC SECTION.
    METHODS clone REDEFINITION.

ENDCLASS.


CLASS concrete_prototype2 IMPLEMENTATION.

  METHOD clone.
    result = me.
  ENDMETHOD.

ENDCLASS.


START-OF-SELECTION.

  " First prototypical instance. The client configures it once...
  DATA(original_one) = NEW concrete_prototype1( id = 'I' ).

  " ...and from then on asks the prototype itself for further objects.
  DATA(copy_one) = CAST concrete_prototype1( original_one->clone( ) ).

  " Second prototype -- the client code below is identical apart from
  " the type it casts to, which is the point of the pattern.
  DATA(original_two) = NEW concrete_prototype2( id = 'II' ).
  DATA(copy_two) = CAST concrete_prototype2( original_two->clone( ) ).

  cl_demo_output=>write( |Prototype 1 id: { original_one->get_id( ) }| ).
  cl_demo_output=>write( |Cloned from prototype 1, id: { copy_one->get_id( ) }| ).
  cl_demo_output=>write( |Prototype 2 id: { original_two->get_id( ) }| ).
  cl_demo_output=>write( |Cloned from prototype 2, id: { copy_two->get_id( ) }| ).
  cl_demo_output=>write( |Clone returns the same object as its prototype: | &&
                         |{ xsdbool( copy_one = original_one ) }| ).
  cl_demo_output=>display( ).
