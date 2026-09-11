*&---------------------------------------------------------------------*
*& Report ZDP_VISITOR
*& Tight Coupled Visitor
*&---------------------------------------------------------------------*
*& Pattern:  Visitor (Behavioral)
*& Intent:   Represent an operation to be performed on the elements of
*&           an object structure. Visitor lets you define a new
*&           operation without changing the classes of the elements on
*&           which it operates.
*&
*& How this example implements it:
*&   - `lif_visitable` is the element interface. It declares `accept`,
*&     which takes a visitor and hands control over to it.
*&   - `lif_visitor` is the visitor interface. It declares `visit`,
*&     which receives the element it should operate on.
*&   - `simple_visitable` is a concrete element. Its `accept` does the
*&     double dispatch: it calls `visitor->visit( me )`, passing itself
*&     so the visitor knows which element it is working on.
*&   - `simple_visitor` is a concrete visitor. Its `visit` holds the
*&     operation that is applied to the element -- the behaviour lives
*&     in the visitor, not in the element class.
*&---------------------------------------------------------------------*
REPORT zdp_visitor.


" Forward declaration: the two interfaces reference each other.
INTERFACE lif_visitor DEFERRED.


INTERFACE lif_visitable.
  "! Hands this element over to a visitor, which then calls back into
  "! the visitor's own `visit` method (double dispatch).
  METHODS accept
    IMPORTING visitor TYPE REF TO lif_visitor.
ENDINTERFACE.


INTERFACE lif_visitor.
  "! Performs this visitor's operation on the given element.
  METHODS visit
    IMPORTING visitable TYPE REF TO lif_visitable.
ENDINTERFACE.


CLASS simple_visitable DEFINITION.
  PUBLIC SECTION.
    INTERFACES lif_visitable.
ENDCLASS.

CLASS simple_visitable IMPLEMENTATION.

  METHOD lif_visitable~accept.
    IF visitor IS NOT BOUND.
      RETURN.
    ENDIF.
    " Second half of the double dispatch: pass ourselves back in.
    visitor->visit( me ).
  ENDMETHOD.

ENDCLASS.


CLASS simple_visitor DEFINITION.
  PUBLIC SECTION.
    INTERFACES lif_visitor.
ENDCLASS.

CLASS simple_visitor IMPLEMENTATION.

  METHOD lif_visitor~visit.
    IF visitable IS NOT BOUND.
      RETURN.
    ENDIF.
    cl_demo_output=>write( |simple_visitor is visiting an element of type | &&
                           |{ cl_abap_classdescr=>get_class_name( visitable ) }| ).
  ENDMETHOD.

ENDCLASS.


START-OF-SELECTION.

  " The element does not know what the operation is -- it only knows
  " how to accept a visitor.
  DATA(element) = NEW simple_visitable( ).
  DATA(visitor) = NEW simple_visitor( ).

  cl_demo_output=>write( |Visitor pattern: the element accepts a visitor, | &&
                         |the visitor supplies the behaviour.| ).

  element->lif_visitable~accept( visitor ).

  cl_demo_output=>display( ).
