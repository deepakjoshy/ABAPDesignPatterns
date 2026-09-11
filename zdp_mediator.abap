*&---------------------------------------------------------------------*
*& Report ZDP_MEDIATOR
*&---------------------------------------------------------------------*
*& Pattern:  Mediator (Behavioral)
*& Intent:   Define an object that encapsulates how a set of objects
*&           interact. Mediator promotes loose coupling by keeping
*&           objects from referring to each other explicitly, and it
*&           lets you vary their interaction independently.
*&
*& How this example implements it:
*&   - `lcl_united_nations` is the abstract mediator. It declares the
*&     single abstract operation `declear`, which colleagues call to
*&     send a message to "the other side".
*&   - `lcl_un_security_council` is the concrete mediator. It knows
*&     both colleagues and decides who receives a message: whoever
*&     did NOT send it.
*&   - `lcl_country` is the abstract colleague. It only ever holds a
*&     reference to the mediator -- never to the other colleague.
*&   - `lcl_usa` and `lcl_irag` are the concrete colleagues. They talk
*&     by calling `declear` on the mediator and receive through
*&     `get_message`, so the two countries are never directly coupled.
*&---------------------------------------------------------------------*
REPORT zdp_mediator.

CLASS lcl_united_nations DEFINITION DEFERRED.


CLASS lcl_country DEFINITION ABSTRACT.

  PUBLIC SECTION.
    METHODS constructor
      IMPORTING mediator TYPE REF TO lcl_united_nations.

  PROTECTED SECTION.
    "! The only link a colleague has to the outside world.
    DATA mediator TYPE REF TO lcl_united_nations.

ENDCLASS.


CLASS lcl_country IMPLEMENTATION.

  METHOD constructor.
    me->mediator = mediator.
  ENDMETHOD.

ENDCLASS.


CLASS lcl_united_nations DEFINITION ABSTRACT.

  PUBLIC SECTION.
    "! Routes a message from the sending colleague to the other one.
    METHODS declear ABSTRACT
      IMPORTING message   TYPE string
                colleague TYPE REF TO lcl_country.

ENDCLASS.


CLASS lcl_irag DEFINITION INHERITING FROM lcl_country.

  PUBLIC SECTION.
    METHODS constructor
      IMPORTING mediator TYPE REF TO lcl_united_nations.

    "! Sends a message -- always via the mediator, never directly.
    METHODS declear
      IMPORTING message TYPE string.

    "! Called by the mediator when the other colleague spoke.
    METHODS get_message
      IMPORTING message TYPE string.

ENDCLASS.


CLASS lcl_irag IMPLEMENTATION.

  METHOD constructor.
    super->constructor( mediator ).
  ENDMETHOD.

  METHOD declear.
    me->mediator->declear( message   = message
                           colleague = me ).
  ENDMETHOD.

  METHOD get_message.
    cl_demo_output=>write( |伊拉克获得对方信息: { message }| ).
  ENDMETHOD.

ENDCLASS.


CLASS lcl_usa DEFINITION INHERITING FROM lcl_country.

  PUBLIC SECTION.
    METHODS constructor
      IMPORTING mediator TYPE REF TO lcl_united_nations.

    "! Sends a message -- always via the mediator, never directly.
    METHODS declear
      IMPORTING message TYPE string.

    "! Called by the mediator when the other colleague spoke.
    METHODS get_message
      IMPORTING message TYPE string.

ENDCLASS.


CLASS lcl_usa IMPLEMENTATION.

  METHOD constructor.
    super->constructor( mediator ).
  ENDMETHOD.

  METHOD declear.
    me->mediator->declear( message   = message
                           colleague = me ).
  ENDMETHOD.

  METHOD get_message.
    cl_demo_output=>write( |美国获得对方信息: { message }| ).
  ENDMETHOD.

ENDCLASS.


CLASS lcl_un_security_council DEFINITION INHERITING FROM lcl_united_nations.

  PUBLIC SECTION.
    METHODS set_colleague1
      IMPORTING colleague TYPE REF TO lcl_usa.

    METHODS set_colleague2
      IMPORTING colleague TYPE REF TO lcl_irag.

    METHODS declear REDEFINITION.

  PRIVATE SECTION.
    DATA colleague1 TYPE REF TO lcl_usa.
    DATA colleague2 TYPE REF TO lcl_irag.

ENDCLASS.


CLASS lcl_un_security_council IMPLEMENTATION.

  METHOD set_colleague1.
    me->colleague1 = colleague.
  ENDMETHOD.

  METHOD set_colleague2.
    me->colleague2 = colleague.
  ENDMETHOD.

  METHOD declear.
    " The mediator is the only place that knows both sides.
    IF colleague = colleague1.
      colleague2->get_message( message ).
    ELSE.
      colleague1->get_message( message ).
    ENDIF.
  ENDMETHOD.

ENDCLASS.


START-OF-SELECTION.

  " The concrete mediator sits between the two colleagues.
  DATA(security_council) = NEW lcl_un_security_council( ).

  " Each colleague only knows the mediator.
  DATA(america) = NEW lcl_usa( security_council ).
  DATA(iraq)    = NEW lcl_irag( security_council ).

  security_council->set_colleague2( iraq ).
  security_council->set_colleague1( america ).

  cl_demo_output=>write( |Both countries talk only through the Security Council:| ).

  america->declear( '不准研制核武器，否则就要发动战争' ).
  iraq->declear( '我们没有核武器，也不怕侵略' ).

  cl_demo_output=>display( ).
