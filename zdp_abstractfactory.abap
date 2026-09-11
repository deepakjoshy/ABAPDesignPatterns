*&---------------------------------------------------------------------*
*& Report ZDP_ABSTRACTFACTORY
*&---------------------------------------------------------------------*
*& Pattern:  Abstract Factory (Creational)
*& Intent:   Provide an interface for creating families of related or
*&           dependent objects without specifying their concrete classes.
*&
*& How this example implements it:
*&   - Two abstract product hierarchies define the "family":
*&     `abs_data` (how data is read) with `data_from_file` /
*&     `data_from_db`, and `abs_print` (how data is shown) with
*&     `print_simple` / `print_alv`.
*&   - `lcl_report` is the abstract creator. Its abstract methods
*&     `get_data` and `print_data` say WHAT has to happen, never WHICH
*&     concrete classes do it.
*&   - `simple_report` creates the "classic" family (file + classic
*&     list), `complex_report` creates the "rich" family (database +
*&     ALV). Each subclass keeps its family consistent.
*&   - `lcl_main_app=>run` only ever talks to the abstract
*&     `lcl_report` reference, so swapping the family is a one-line
*&     change and the calling code stays untouched.
*&---------------------------------------------------------------------*
REPORT zdp_abstractfactory.


CLASS abs_data DEFINITION ABSTRACT.
  PUBLIC SECTION.
    "! Reads the data for the report from some source.
    METHODS read_data ABSTRACT.
ENDCLASS.


CLASS data_from_file DEFINITION INHERITING FROM abs_data.
  PUBLIC SECTION.
    METHODS read_data REDEFINITION.
ENDCLASS.

CLASS data_from_file IMPLEMENTATION.
  METHOD read_data.
    cl_demo_output=>write( |Reading data from file| ).
  ENDMETHOD.
ENDCLASS.


CLASS data_from_db DEFINITION INHERITING FROM abs_data.
  PUBLIC SECTION.
    METHODS read_data REDEFINITION.
ENDCLASS.

CLASS data_from_db IMPLEMENTATION.
  METHOD read_data.
    cl_demo_output=>write( |Reading data from Database Table| ).
  ENDMETHOD.
ENDCLASS.


CLASS abs_print DEFINITION ABSTRACT.
  PUBLIC SECTION.
    "! Renders the data that was read.
    METHODS write_data ABSTRACT.
ENDCLASS.


CLASS print_alv DEFINITION INHERITING FROM abs_print.
  PUBLIC SECTION.
    METHODS write_data REDEFINITION.
ENDCLASS.

CLASS print_alv IMPLEMENTATION.
  METHOD write_data.
    cl_demo_output=>write( |Writing data into ALV| ).
  ENDMETHOD.
ENDCLASS.


CLASS print_simple DEFINITION INHERITING FROM abs_print.
  PUBLIC SECTION.
    METHODS write_data REDEFINITION.
ENDCLASS.

CLASS print_simple IMPLEMENTATION.
  METHOD write_data.
    cl_demo_output=>write( |Writing data in classic - This is actually classic| ).
  ENDMETHOD.
ENDCLASS.


"! Abstract creator: defines the steps, not the concrete product family.
CLASS lcl_report DEFINITION ABSTRACT.
  PUBLIC SECTION.
    "! Creates the data-reading product of this family and runs it.
    METHODS get_data ABSTRACT.

    "! Creates the output product of this family and runs it.
    METHODS print_data ABSTRACT.
ENDCLASS.


CLASS simple_report DEFINITION INHERITING FROM lcl_report.
  PUBLIC SECTION.
    METHODS get_data REDEFINITION.
    METHODS print_data REDEFINITION.
ENDCLASS.

CLASS simple_report IMPLEMENTATION.
  METHOD get_data.
    DATA(source) = NEW data_from_file( ).
    source->read_data( ).
  ENDMETHOD.

  METHOD print_data.
    DATA(printer) = NEW print_simple( ).
    printer->write_data( ).
  ENDMETHOD.
ENDCLASS.


CLASS complex_report DEFINITION INHERITING FROM lcl_report.
  PUBLIC SECTION.
    METHODS get_data REDEFINITION.
    METHODS print_data REDEFINITION.
ENDCLASS.

CLASS complex_report IMPLEMENTATION.
  METHOD get_data.
    DATA(source) = NEW data_from_db( ).
    source->read_data( ).
  ENDMETHOD.

  METHOD print_data.
    DATA(printer) = NEW print_alv( ).
    printer->write_data( ).
  ENDMETHOD.
ENDCLASS.


CLASS lcl_main_app DEFINITION.
  PUBLIC SECTION.
    "! Runs both product families through the same abstract interface.
    CLASS-METHODS run.
ENDCLASS.

CLASS lcl_main_app IMPLEMENTATION.
  METHOD run.
    DATA report TYPE REF TO lcl_report.

    " Family 1: read from file, print classically.
    cl_demo_output=>write( |--- simple_report (file + classic list family) ---| ).
    report = NEW simple_report( ).
    report->get_data( ).
    report->print_data( ).

    " Family 2: same calls, completely different concrete products.
    cl_demo_output=>write( |--- complex_report (database + ALV family) ---| ).
    report = NEW complex_report( ).
    report->get_data( ).
    report->print_data( ).
  ENDMETHOD.
ENDCLASS.


START-OF-SELECTION.

  lcl_main_app=>run( ).
  cl_demo_output=>display( ).
