*&---------------------------------------------------------------------*
*& Report ZDP_FACTORYMETHOD3
*&---------------------------------------------------------------------*
*& Pattern:  Factory Method (Creational)
*& Intent:   Define an interface for creating an object, but let
*&           subclasses decide which class to instantiate. Factory
*&           Method lets a class defer instantiation to subclasses.
*&
*& How this example implements it:
*&   - `document` is the abstract creator. It owns the collection of
*&     pages and declares the abstract factory method `createpages`,
*&     without knowing which page classes will end up in there.
*&   - `resume` and `report` are the concrete creators. Each redefines
*&     `createpages` and fills the collection with its own page
*&     classes: a resume gets skills/education/experience pages, a
*&     report gets introduction/results/conclusion/summary/bibliography.
*&   - Both constructors call `createpages( )`, so a document is fully
*&     built the moment it is instantiated.
*&   - The `get_clazz_name` macro is a reflection helper: it asks
*&     `cl_abap_classdescr` for the runtime class name of a reference
*&     and strips the leading 'CLASS=' prefix, so the demo can list the
*&     page classes that each document actually produced.
*&
*& Variant note: unlike ZDP_FACTORYMETHOD (single product per creator)
*& and ZDP_FACTORYMETHOD2 (interface-based), here the factory method
*& returns nothing and instead *populates a collection* of products --
*& the classic "document builds its own pages" illustration.
*&---------------------------------------------------------------------*
REPORT zdp_factorymethod3 NO STANDARD PAGE HEADING LINE-SIZE 80.

CLASS cl_abap_typedescr DEFINITION LOAD.

" Scratch fields used by the get_clazz_name macro below.
DATA match_offset TYPE i.
DATA shift_length TYPE i.
DATA match_length TYPE i.

" Reflection helper: &1 = object reference, &2 = receiving char field.
" Turns the runtime type name (e.g. '\CLASS=SKILLSPAGE') into the bare
" class name by cutting everything up to and including 'CLASS='.
DEFINE get_clazz_name.
  &2 = cl_abap_classdescr=>get_class_name( &1 ).
  FIND REGEX 'CLASS=' IN &2 MATCH OFFSET match_offset MATCH LENGTH match_length.
  shift_length = match_offset + match_length.
  SHIFT &2 BY shift_length PLACES LEFT.
END-OF-DEFINITION.


"! Abstract product: one page of a document.
CLASS page DEFINITION ABSTRACT.
ENDCLASS.


CLASS skillspage DEFINITION INHERITING FROM page.
ENDCLASS.


CLASS educationpage DEFINITION INHERITING FROM page.
ENDCLASS.


CLASS experiencepage DEFINITION INHERITING FROM page.
ENDCLASS.


CLASS introductionpage DEFINITION INHERITING FROM page.
ENDCLASS.


CLASS resultspage DEFINITION INHERITING FROM page.
ENDCLASS.


CLASS conclusionpage DEFINITION INHERITING FROM page.
ENDCLASS.


CLASS summarypage DEFINITION INHERITING FROM page.
ENDCLASS.


CLASS bibliographypage DEFINITION INHERITING FROM page.
ENDCLASS.


CLASS document DEFINITION ABSTRACT.
  PUBLIC SECTION.
    "! The factory method. Each concrete document decides which page
    "! classes it is made of and fills the page collection with them.
    METHODS createpages ABSTRACT.

    "! Hands out the pages this document created.
    METHODS get_pages
      EXPORTING result TYPE ANY TABLE.

  PROTECTED SECTION.
    "! The pages produced by the factory method.
    DATA pages TYPE TABLE OF REF TO page.
ENDCLASS.


CLASS document IMPLEMENTATION.
  METHOD get_pages.
    result = pages.
  ENDMETHOD.
ENDCLASS.


CLASS resume DEFINITION INHERITING FROM document.
  PUBLIC SECTION.
    METHODS constructor.
    METHODS createpages REDEFINITION.
ENDCLASS.


CLASS resume IMPLEMENTATION.
  METHOD constructor.
    super->constructor( ).
    me->createpages( ).
  ENDMETHOD.

  METHOD createpages.
    DATA page TYPE REF TO page.

    page = NEW skillspage( ).
    APPEND page TO pages.

    page = NEW educationpage( ).
    APPEND page TO pages.

    page = NEW experiencepage( ).
    APPEND page TO pages.
  ENDMETHOD.
ENDCLASS.


CLASS report DEFINITION INHERITING FROM document.
  PUBLIC SECTION.
    METHODS constructor.
    METHODS createpages REDEFINITION.
ENDCLASS.


CLASS report IMPLEMENTATION.
  METHOD constructor.
    super->constructor( ).
    me->createpages( ).
  ENDMETHOD.

  METHOD createpages.
    DATA page TYPE REF TO page.

    page = NEW introductionpage( ).
    APPEND page TO pages.

    page = NEW resultspage( ).
    APPEND page TO pages.

    page = NEW conclusionpage( ).
    APPEND page TO pages.

    page = NEW summarypage( ).
    APPEND page TO pages.

    page = NEW bibliographypage( ).
    APPEND page TO pages.
  ENDMETHOD.
ENDCLASS.


CLASS mainapp DEFINITION.
  PUBLIC SECTION.
    "! All documents, held only by their abstract type.
    CLASS-DATA documents TYPE TABLE OF REF TO document.

    "! Runs the demo: each document is asked for the pages its own
    "! factory method produced.
    CLASS-METHODS main.
ENDCLASS.


CLASS mainapp IMPLEMENTATION.
  METHOD main.

    DATA class_name TYPE abap_abstypename.
    DATA document_pages TYPE TABLE OF REF TO page.

    FIELD-SYMBOLS <document> TYPE REF TO document.
    FIELD-SYMBOLS <page>     TYPE REF TO page.

    " Creating the documents is enough -- their constructors run the
    " factory method and the pages appear by themselves.
    DATA(resume_document) = NEW resume( ).
    APPEND resume_document TO documents.

    DATA(report_document) = NEW report( ).
    APPEND report_document TO documents.

    LOOP AT documents ASSIGNING <document>.

      " Reflection tells us which concrete document we are looking at.
      get_clazz_name <document> class_name.

      CASE class_name.
        WHEN 'RESUME'.
          cl_demo_output=>write( |Resume contains the following pages:| ).
          <document>->get_pages( IMPORTING result = document_pages ).
          LOOP AT document_pages ASSIGNING <page>.
            get_clazz_name <page> class_name.
            cl_demo_output=>write( |  { class_name }| ).
          ENDLOOP.

        WHEN 'REPORT'.
          cl_demo_output=>write( |Report contains the following pages:| ).
          <document>->get_pages( IMPORTING result = document_pages ).
          LOOP AT document_pages ASSIGNING <page>.
            get_clazz_name <page> class_name.
            cl_demo_output=>write( |  { class_name }| ).
          ENDLOOP.
      ENDCASE.

    ENDLOOP.

    cl_demo_output=>display( ).

  ENDMETHOD.
ENDCLASS.


START-OF-SELECTION.
  mainapp=>main( ).
