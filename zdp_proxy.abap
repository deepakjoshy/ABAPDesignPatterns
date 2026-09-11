*&---------------------------------------------------------------------*
*& Report ZDP_PROXY
*&---------------------------------------------------------------------*
*& Pattern:  Proxy (Structural)
*& Intent:   Provide a surrogate or placeholder for another object to
*&           control access to it.
*&
*& How this example implements it:
*&   - `lif_data` is the common subject interface: it declares
*&     `get_data` and `write_data`. Both the proxy and the real object
*&     implement it, so the client cannot tell them apart.
*&   - `lcl_t100_data` is the real subject. It is the expensive one --
*&     it actually hits the database and reads table T100.
*&   - `lcl_proxy_data` is the proxy. It holds a reference to the real
*&     subject but leaves it unbound until it is genuinely needed
*&     (virtual proxy / lazy instantiation), and it first checks that
*&     the requested language matches the logon language before
*&     forwarding the call at all (protection proxy).
*&   - `write_data` on the proxy answers by itself when no real subject
*&     was ever created, and otherwise delegates to it.
*&
*& Note: the original report referenced the table type TT_T100 without
*& declaring it, which made the report non-standalone. The local TYPES
*& declaration below supplies it; nothing else about the flow changed.
*&---------------------------------------------------------------------*
REPORT zdp_proxy.

TYPES tt_t100 TYPE STANDARD TABLE OF t100 WITH EMPTY KEY.


INTERFACE lif_data.

  DATA t100_rows TYPE tt_t100.

  "! Fetches the message texts for the requested language.
  METHODS get_data
    IMPORTING language TYPE spras OPTIONAL
    CHANGING  data     TYPE tt_t100.

  "! Reports what was fetched.
  METHODS write_data.

ENDINTERFACE.


CLASS lcl_proxy_data DEFINITION.

  PUBLIC SECTION.
    INTERFACES lif_data.

  PRIVATE SECTION.
    "! The real subject. Stays unbound until a request actually
    "! justifies creating it.
    DATA real_data TYPE REF TO lif_data.

ENDCLASS.


CLASS lcl_t100_data DEFINITION.

  PUBLIC SECTION.
    INTERFACES lif_data.

ENDCLASS.


CLASS lcl_proxy_data IMPLEMENTATION.

  METHOD lif_data~get_data.
    " Access control: only the logon language is served. Anything else
    " is refused here and the real subject is never even built.
    IF language <> sy-langu.
      EXIT.
    ENDIF.

    real_data = NEW lcl_t100_data( ).
    real_data->get_data(
      EXPORTING language = language
      CHANGING  data     = data ).
  ENDMETHOD.

  METHOD lif_data~write_data.
    IF real_data IS NOT BOUND.
      cl_demo_output=>write( |Proxy: no real subject was created, so there is no data to display.| ).
    ELSE.
      real_data->write_data( ).
    ENDIF.
  ENDMETHOD.

ENDCLASS.


CLASS lcl_t100_data IMPLEMENTATION.

  METHOD lif_data~get_data.
    SELECT * FROM t100 INTO TABLE lif_data~t100_rows
      UP TO 200000000 ROWS
      WHERE sprsl = language.
    data = lif_data~t100_rows.
  ENDMETHOD.

  METHOD lif_data~write_data.
    cl_demo_output=>write( |Real subject: { lines( lif_data~t100_rows ) } row(s) read from T100.| ).
  ENDMETHOD.

ENDCLASS.


START-OF-SELECTION.

  " The client is typed against the interface, not against either
  " concrete class -- it only ever talks to the proxy.
  DATA proxy TYPE REF TO lif_data.
  DATA rows  TYPE tt_t100.

  proxy = NEW lcl_proxy_data( ).

  cl_demo_output=>write( |Client asks the proxy for language 'E' (logon language is '{ sy-langu }').| ).
  proxy->get_data(
    EXPORTING language = 'E'
    CHANGING  data     = rows ).

  proxy->write_data( ).

  cl_demo_output=>write( |Rows handed back to the client: { lines( rows ) }| ).
  cl_demo_output=>display( ).
