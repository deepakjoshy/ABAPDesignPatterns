*&---------------------------------------------------------------------*
*& Report ZDP_SINGLETON
*&---------------------------------------------------------------------*
*& Pattern:  Singleton (Creational)
*& Intent:   Ensure a class has only one instance, and provide a
*&           single global point of access to it.
*&
*& How this example implements it:
*&   - CREATE PRIVATE on the class stops anyone outside the class
*&     from instantiating it directly with `NEW` / `CREATE OBJECT`.
*&   - A class-level attribute (`instance`) holds the one-and-only
*&     object. It starts out empty.
*&   - The class method `get_instance` is the only way callers can
*&     get a reference: the first call creates the object and caches
*&     it, every later call just returns the cached reference.
*&---------------------------------------------------------------------*
REPORT zdp_singleton.

CLASS lcl_application DEFINITION CREATE PRIVATE.

  PUBLIC SECTION.
    "! Returns the single shared instance, creating it on first access.
    CLASS-METHODS get_instance
      RETURNING VALUE(result) TYPE REF TO lcl_application.

    METHODS set_name
      IMPORTING name TYPE string.

    METHODS get_name
      RETURNING VALUE(result) TYPE string.

  PRIVATE SECTION.
    "! The one shared instance. Empty until the first get_instance( ) call.
    CLASS-DATA instance TYPE REF TO lcl_application.
    DATA name TYPE string.

ENDCLASS.


CLASS lcl_application IMPLEMENTATION.

  METHOD get_instance.
    IF instance IS NOT BOUND.
      instance = NEW #( ).
    ENDIF.
    result = instance.
  ENDMETHOD.

  METHOD set_name.
    me->name = name.
  ENDMETHOD.

  METHOD get_name.
    result = name.
  ENDMETHOD.

ENDCLASS.


START-OF-SELECTION.

  " First caller creates the instance and sets its name.
  DATA(app_a) = lcl_application=>get_instance( ).
  app_a->set_name( 'Configured by app_a' ).

  " Second caller only ever asks for "the" instance -- it never
  " creates its own, so it sees the name app_a set above.
  DATA(app_b) = lcl_application=>get_instance( ).

  cl_demo_output=>write( |app_a name: { app_a->get_name( ) }| ).
  cl_demo_output=>write( |app_b name: { app_b->get_name( ) }| ).
  cl_demo_output=>write( |app_a and app_b are the same object: { xsdbool( app_a = app_b ) }| ).
  cl_demo_output=>display( ).
