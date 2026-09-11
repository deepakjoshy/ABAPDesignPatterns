*&---------------------------------------------------------------------*
*& Report ZDP_FACTORYMETHOD
*&---------------------------------------------------------------------*
*& Pattern:  Factory Method (Creational)
*& Intent:   Define an interface for creating an object, but let
*&           subclasses decide which class to instantiate. Factory
*&           Method lets a class defer instantiation to subclasses.
*&
*& How this example implements it:
*&   - `creator` is the abstract creator. It declares the abstract
*&     factory method `factorymethod`, which returns a `product` but
*&     says nothing about which concrete product that will be.
*&   - `concrete_creatora` and `concrete_creatorb` redefine
*&     `factorymethod` and each decides its own product class:
*&     `concrete_producta` and `concrete_productb` respectively.
*&   - `main_app=>main` holds a collection of creators typed only as
*&     the abstract `creator`, calls the same `factorymethod` on each,
*&     and gets back different concrete products.
*&   - The `get_clazz_name` macro is a small reflection helper: it asks
*&     `cl_abap_classdescr` for the runtime class name of a reference
*&     and strips the leading 'CLASS=' prefix, so the demo can show
*&     which class was really instantiated.
*&
*& Variant note: this is the basic GoF structure with an abstract
*& creator/product class hierarchy (see ZDP_FACTORYMETHOD2 for the
*& interface-based variant and ZDP_FACTORYMETHOD3 for the
*& document/pages variant).
*&---------------------------------------------------------------------*
REPORT zdp_factorymethod.

CLASS product DEFINITION DEFERRED.
CLASS concrete_producta DEFINITION DEFERRED.
CLASS concrete_productb DEFINITION DEFERRED.

CLASS creator DEFINITION DEFERRED.
CLASS concrete_creatora DEFINITION DEFERRED.
CLASS concrete_creatorb DEFINITION DEFERRED.

CLASS cl_abap_typedescr DEFINITION LOAD.

" Scratch fields used by the get_clazz_name macro below.
DATA match_offset TYPE i.
DATA shift_length TYPE i.
DATA match_length TYPE i.

" Reflection helper: &1 = object reference, &2 = receiving char field.
" Turns the runtime type name (e.g. '\CLASS=CONCRETE_PRODUCTA') into
" the bare class name by cutting everything up to and including 'CLASS='.
DEFINE get_clazz_name.
  &2 = cl_abap_classdescr=>get_class_name( &1 ).
  FIND REGEX 'CLASS=' IN &2 MATCH OFFSET match_offset MATCH LENGTH match_length.
  shift_length = match_offset + match_length.
  SHIFT &2 BY shift_length PLACES LEFT.
END-OF-DEFINITION.


CLASS product DEFINITION ABSTRACT.
ENDCLASS.


CLASS concrete_producta DEFINITION INHERITING FROM product.
ENDCLASS.


CLASS concrete_productb DEFINITION INHERITING FROM product.
ENDCLASS.


CLASS creator DEFINITION ABSTRACT.
  PUBLIC SECTION.
    "! The factory method. Subclasses decide which concrete product
    "! is actually created.
    METHODS factorymethod ABSTRACT
      RETURNING VALUE(result) TYPE REF TO product.
ENDCLASS.


CLASS concrete_creatora DEFINITION INHERITING FROM creator.
  PUBLIC SECTION.
    METHODS factorymethod REDEFINITION.
ENDCLASS.


CLASS concrete_creatora IMPLEMENTATION.
  METHOD factorymethod.
    result = NEW concrete_producta( ).
  ENDMETHOD.
ENDCLASS.


CLASS concrete_creatorb DEFINITION INHERITING FROM creator.
  PUBLIC SECTION.
    METHODS factorymethod REDEFINITION.
ENDCLASS.


CLASS concrete_creatorb IMPLEMENTATION.
  METHOD factorymethod.
    result = NEW concrete_productb( ).
  ENDMETHOD.
ENDCLASS.


CLASS main_app DEFINITION.
  PUBLIC SECTION.
    "! All creators, held only by their abstract type.
    CLASS-DATA creators TYPE TABLE OF REF TO creator.

    "! Runs the demo: every creator is asked for a product and the
    "! resulting concrete class is reported.
    CLASS-METHODS main.
ENDCLASS.


CLASS main_app IMPLEMENTATION.
  METHOD main.

    DATA class_name TYPE abap_abstypename.
    DATA current_creator TYPE REF TO creator.

    FIELD-SYMBOLS <creator> TYPE any.

    DATA(creator_a) = NEW concrete_creatora( ).
    APPEND creator_a TO creators.

    DATA(creator_b) = NEW concrete_creatorb( ).
    APPEND creator_b TO creators.

    LOOP AT creators ASSIGNING <creator>.

      " Which creator is at work here?
      get_clazz_name <creator> class_name.
      CASE class_name.
        WHEN 'CONCRETE_CREATORA'.
          cl_demo_output=>write( |ConcreteCreatorA creates Product A| ).
        WHEN 'CONCRETE_CREATORB'.
          cl_demo_output=>write( |ConcreteCreatorB creates Product B| ).
      ENDCASE.

      " The client only ever calls the abstract factory method.
      current_creator = <creator>.
      DATA(created_product) = current_creator->factorymethod( ).

      " ... and reflection shows which concrete product came back.
      get_clazz_name created_product class_name.
      cl_demo_output=>write( |  Product = { class_name }| ).

    ENDLOOP.

    cl_demo_output=>display( ).

  ENDMETHOD.
ENDCLASS.


START-OF-SELECTION.
  main_app=>main( ).
