*&---------------------------------------------------------------------*
*& Report ZDP_INTERPRETER
*&---------------------------------------------------------------------*
*& Pattern:  Interpreter (Behavioral)
*& Intent:   Given a language, define a representation for its grammar
*&           along with an interpreter that uses the representation to
*&           interpret sentences in the language.
*&
*& How this example implements it:
*&   - `lcl_context` carries the state that is shared by every
*&     expression while a sentence is being interpreted: the input
*&     string to work on and the output produced so far.
*&   - `lcl_abstract_expression` is the abstract grammar node. It
*&     declares the single abstract operation `interpret`, which every
*&     concrete node must redefine.
*&   - `lcl_plus_expression` and `lcl_minus_expression` are the
*&     terminal/non-terminal nodes of the grammar. Each one redefines
*&     `interpret` and reacts to the shared context in its own way.
*&   - The demo builds a sentence as an ordered list of expression
*&     nodes and hands the same context to each node in turn, which is
*&     how the pattern walks an abstract syntax tree.
*&---------------------------------------------------------------------*
REPORT zdp_interpreter.

CLASS lcl_context DEFINITION DEFERRED.


CLASS lcl_abstract_expression DEFINITION ABSTRACT.

  PUBLIC SECTION.
    "! Interprets one node of the sentence against the shared context.
    "! Every concrete expression redefines this with its own behaviour.
    METHODS interpret ABSTRACT
      IMPORTING context TYPE REF TO lcl_context.

ENDCLASS.


CLASS lcl_context DEFINITION.

  PUBLIC SECTION.
    METHODS constructor
      IMPORTING input TYPE string.

    "! Returns the sentence that is currently being interpreted.
    METHODS get_input
      RETURNING VALUE(result) TYPE string.

    METHODS set_input
      IMPORTING input TYPE string.

    "! Returns the result accumulated by the expressions so far.
    METHODS get_output
      RETURNING VALUE(result) TYPE string.

    METHODS set_output
      IMPORTING output TYPE string.

  PRIVATE SECTION.
    DATA input TYPE string.
    DATA output TYPE i.

ENDCLASS.


CLASS lcl_context IMPLEMENTATION.

  METHOD constructor.
    me->input = input.
  ENDMETHOD.

  METHOD get_input.
    result = input.
  ENDMETHOD.

  METHOD set_input.
    me->input = input.
  ENDMETHOD.

  METHOD get_output.
    result = output.
  ENDMETHOD.

  METHOD set_output.
    me->output = output.
  ENDMETHOD.

ENDCLASS.


CLASS lcl_plus_expression DEFINITION INHERITING FROM lcl_abstract_expression.

  PUBLIC SECTION.
    METHODS interpret REDEFINITION.

ENDCLASS.


CLASS lcl_plus_expression IMPLEMENTATION.

  METHOD interpret.
    DATA(input) = context->get_input( ).
    cl_demo_output=>write( |PlusExpression++ reading context input '{ input }'| ).
  ENDMETHOD.

ENDCLASS.


CLASS lcl_minus_expression DEFINITION INHERITING FROM lcl_abstract_expression.

  PUBLIC SECTION.
    METHODS interpret REDEFINITION.

ENDCLASS.


CLASS lcl_minus_expression IMPLEMENTATION.

  METHOD interpret.
    DATA(input) = context->get_input( ).
    cl_demo_output=>write( |MinusExpression-- reading context input '{ input }'| ).
  ENDMETHOD.

ENDCLASS.


START-OF-SELECTION.

  " The context holds the sentence every expression node works on.
  DATA(context) = NEW lcl_context( '10' ).

  " A "sentence" in this tiny grammar is just an ordered list of nodes.
  DATA expressions TYPE STANDARD TABLE OF REF TO lcl_abstract_expression.

  expressions = VALUE #( ( NEW lcl_plus_expression( )  )
                         ( NEW lcl_plus_expression( )  )
                         ( NEW lcl_minus_expression( ) )
                         ( NEW lcl_minus_expression( ) )
                         ( NEW lcl_minus_expression( ) ) ).

  cl_demo_output=>write( |Interpreting a sentence of { lines( expressions ) } expressions| ).
  cl_demo_output=>write( |Context input: { context->get_input( ) }| ).

  " Each node interprets itself against the very same shared context.
  LOOP AT expressions INTO DATA(expression).
    expression->interpret( context ).
  ENDLOOP.

  cl_demo_output=>write( |Context output after interpretation: { context->get_output( ) }| ).
  cl_demo_output=>display( ).
