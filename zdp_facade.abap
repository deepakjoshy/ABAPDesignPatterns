*&---------------------------------------------------------------------*
*& Report ZDP_FACADE
*&---------------------------------------------------------------------*
*& Pattern:  Facade (Structural)
*& Intent:   Provide a unified interface to a set of interfaces in a
*&           subsystem. Facade defines a higher-level interface that
*&           makes the subsystem easier to use.
*&
*& How this example implements it:
*&   - The subsystem is made of several small pieces: `lcl_data`
*&     (fetches the data) and two output writers, `lcl_write_alv` and
*&     `lcl_write_log`, both implementing the `lif_write` interface.
*&   - `lcl_facade` is the facade. Its single method `process_report`
*&     hides the whole "get data, pick a writer, write it" sequence.
*&   - The caller in START-OF-SELECTION never touches the subsystem
*&     classes: it just says which output channel it wants ('A' for
*&     ALV, anything else for the log) and the facade does the rest.
*&---------------------------------------------------------------------*
REPORT zdp_facade.

CLASS lcl_data DEFINITION.
  PUBLIC SECTION.
    "! Subsystem part 1: retrieving the data for the report.
    METHODS constructor.
ENDCLASS.


INTERFACE lif_write.
  "! Common contract of every output channel of the subsystem.
  METHODS write_data.
ENDINTERFACE.


CLASS lcl_write_alv DEFINITION.
  PUBLIC SECTION.
    INTERFACES lif_write.
ENDCLASS.


CLASS lcl_write_log DEFINITION.
  PUBLIC SECTION.
    INTERFACES lif_write.
ENDCLASS.


CLASS lcl_facade DEFINITION.
  PUBLIC SECTION.
    "! The one entry point clients need: fetches the data and writes it
    "! through the requested output channel.
    "! @parameter write_type | 'A' selects ALV output, anything else the log.
    METHODS process_report
      IMPORTING write_type TYPE char1.
ENDCLASS.


CLASS lcl_data IMPLEMENTATION.
  METHOD constructor.
    cl_demo_output=>write( |Subsystem: getting data| ).
  ENDMETHOD.
ENDCLASS.


CLASS lcl_write_alv IMPLEMENTATION.
  METHOD lif_write~write_data.
    cl_demo_output=>write( |Subsystem: writing data in ALV| ).
  ENDMETHOD.
ENDCLASS.


CLASS lcl_write_log IMPLEMENTATION.
  METHOD lif_write~write_data.
    cl_demo_output=>write( |Subsystem: writing data in Log| ).
  ENDMETHOD.
ENDCLASS.


CLASS lcl_facade IMPLEMENTATION.
  METHOD process_report.

    " Step 1 of the hidden sequence: get the data.
    DATA(report_data) = NEW lcl_data( ).

    " Step 2: pick the output channel the client asked for.
    DATA writer TYPE REF TO lif_write.
    IF write_type = 'A'.
      writer = NEW lcl_write_alv( ).
    ELSE.
      writer = NEW lcl_write_log( ).
    ENDIF.

    " Step 3: write it.
    writer->write_data( ).

  ENDMETHOD.
ENDCLASS.


START-OF-SELECTION.

  " The client only knows the facade -- one object, one call.
  DATA(facade) = NEW lcl_facade( ).

  cl_demo_output=>write( |Client asks the facade for a report with write type 'A'| ).
  facade->process_report( write_type = 'A' ).

  cl_demo_output=>display( ).
