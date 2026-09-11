*&---------------------------------------------------------------------*
*& Report ZDP_DECORATOR
*&---------------------------------------------------------------------*
*& Pattern:  Decorator (Structural)
*& Intent:   Attach additional responsibilities to an object
*&           dynamically. Decorators provide a flexible alternative to
*&           subclassing for extending functionality.
*&
*& How this example implements it:
*&   - `output` is the common abstraction with a single operation,
*&     `process_output( )`.
*&   - `alv_output` is the concrete component: the plain, undecorated
*&     behaviour that always sits at the bottom of the stack.
*&   - `op_decorator` is the abstract decorator. It *is* an `output` and
*&     it *has* an `output` (`inner`); its `process_output( )` just
*&     forwards to the wrapped object.
*&   - `op_pdf`, `op_xls`, `op_email` and `op_alv` are the concrete
*&     decorators: each one calls `super->process_output( )` first --
*&     running everything wrapped underneath -- and then adds its own
*&     step on top.
*&   - The selection-screen checkboxes decide at runtime which
*&     decorators get stacked, which is exactly what subclassing could
*&     not give you here.
*&---------------------------------------------------------------------*
REPORT zdp_decorator.


CLASS output DEFINITION ABSTRACT.

  PUBLIC SECTION.
    "! Produces the output. Decorators extend this step by step.
    METHODS process_output ABSTRACT.

ENDCLASS.


CLASS alv_output DEFINITION INHERITING FROM output.

  PUBLIC SECTION.
    "! The undecorated base behaviour of the whole stack.
    METHODS process_output REDEFINITION.

ENDCLASS.


CLASS alv_output IMPLEMENTATION.

  METHOD process_output.
    cl_demo_output=>write( |Standard ALV output| ).
  ENDMETHOD.

ENDCLASS.


CLASS op_decorator DEFINITION INHERITING FROM output.

  PUBLIC SECTION.
    METHODS constructor
      IMPORTING inner TYPE REF TO output.

    "! Runs the wrapped object. Subclasses add their own step after it.
    METHODS process_output REDEFINITION.

  PRIVATE SECTION.
    "! The object this decorator wraps -- component or another decorator.
    DATA inner TYPE REF TO output.

ENDCLASS.


CLASS op_decorator IMPLEMENTATION.

  METHOD constructor.
    super->constructor( ).
    me->inner = inner.
  ENDMETHOD.

  METHOD process_output.
    CHECK inner IS BOUND.
    inner->process_output( ).
  ENDMETHOD.

ENDCLASS.


CLASS op_pdf DEFINITION INHERITING FROM op_decorator.

  PUBLIC SECTION.
    "! Adds PDF generation on top of the wrapped output.
    METHODS process_output REDEFINITION.

ENDCLASS.


CLASS op_pdf IMPLEMENTATION.

  METHOD process_output.
    super->process_output( ).
    cl_demo_output=>write( |          Generating PDF| ).
  ENDMETHOD.

ENDCLASS.


CLASS op_xls DEFINITION INHERITING FROM op_decorator.

  PUBLIC SECTION.
    "! Adds Excel generation on top of the wrapped output.
    METHODS process_output REDEFINITION.

ENDCLASS.


CLASS op_xls IMPLEMENTATION.

  METHOD process_output.
    super->process_output( ).
    cl_demo_output=>write( |          Generating Excel| ).
  ENDMETHOD.

ENDCLASS.


CLASS op_email DEFINITION INHERITING FROM op_decorator.

  PUBLIC SECTION.
    "! Adds sending the result by e-mail on top of the wrapped output.
    METHODS process_output REDEFINITION.

ENDCLASS.


CLASS op_email IMPLEMENTATION.

  METHOD process_output.
    super->process_output( ).
    cl_demo_output=>write( |          Sending Email| ).
  ENDMETHOD.

ENDCLASS.


CLASS op_alv DEFINITION INHERITING FROM op_decorator.

  PUBLIC SECTION.
    "! Adds an extra ALV rendering on top of the wrapped output.
    METHODS process_output REDEFINITION.

ENDCLASS.


CLASS op_alv IMPLEMENTATION.

  METHOD process_output.
    super->process_output( ).
    cl_demo_output=>write( |          Generating ALV| ).
  ENDMETHOD.

ENDCLASS.


PARAMETERS p_pdf   AS CHECKBOX.
PARAMETERS p_email AS CHECKBOX.
PARAMETERS p_xls   AS CHECKBOX.


START-OF-SELECTION.

  " Start with the plain component...
  DATA renderer TYPE REF TO output.
  renderer = NEW alv_output( ).

  " ...then wrap it in whichever decorators were ticked. Each NEW puts
  " one more layer around what we already have.
  IF p_pdf = abap_true.
    renderer = NEW op_pdf( renderer ).
  ENDIF.

  IF p_email = abap_true.
    renderer = NEW op_email( renderer ).
  ENDIF.

  IF p_xls = abap_true.
    renderer = NEW op_xls( renderer ).
  ENDIF.

  cl_demo_output=>write( |Calling process_output( ) on the outermost decorator runs the | &&
                         |whole stack from the inside out:| ).

  " One call -- the layers unwind themselves.
  renderer->process_output( ).

  cl_demo_output=>display( ).
