*&---------------------------------------------------------------------*
*& Report ZDP_FACTORYMETHOD2
*&---------------------------------------------------------------------*
*& Pattern:  Factory Method (Creational)
*& Intent:   Define an interface for creating an object, but let
*&           subclasses decide which class to instantiate. Factory
*&           Method lets a class defer instantiation to subclasses.
*&
*& How this example implements it:
*&   - `creator` is an *interface* declaring `factorymethod`, which
*&     returns something that implements the `product` interface.
*&   - `concrete_creatora` and `concrete_creatorb` implement that
*&     interface and each picks its own product class:
*&     `concrete_producta` / `concrete_productb`.
*&   - `product` is also an interface; each concrete product answers
*&     `get_name` with its own name, so the demo can print both the
*&     runtime class and the product's own name.
*&   - `main_app=>main` keeps a collection of creators typed as the
*&     `creator` interface and calls the same factory method on each.
*&   - The `get_clazz_name` macro is a reflection helper: it asks
*&     `cl_abap_classdescr` for the runtime class name of a reference
*&     and strips the leading 'CLASS=' prefix.
*&
*& Variant note: unlike ZDP_FACTORYMETHOD (abstract classes and
*& REDEFINITION), this variant builds the whole pattern out of
*& interfaces, and the products carry a `get_name` method of their own.
*&---------------------------------------------------------------------*
REPORT zdp_factorymethod2 NO STANDARD PAGE HEADING LINE-SIZE 80.

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


INTERFACE product.
  TYPES ty_productname(30) TYPE c.

  DATA name TYPE ty_productname.

  "! Returns the product's own display name.
  METHODS get_name
    RETURNING VALUE(result) TYPE ty_productname.
ENDINTERFACE.


CLASS concrete_producta DEFINITION.
  PUBLIC SECTION.
    INTERFACES product.
ENDCLASS.


CLASS concrete_producta IMPLEMENTATION.
  METHOD product~get_name.
    result = 'ConcreteProductA'.
  ENDMETHOD.
ENDCLASS.


CLASS concrete_productb DEFINITION.
  PUBLIC SECTION.
    INTERFACES product.
ENDCLASS.


CLASS concrete_productb IMPLEMENTATION.
  METHOD product~get_name.
    result = 'ConCreteProductB'.
  ENDMETHOD.
ENDCLASS.


INTERFACE creator.
  "! The factory method. Each implementing class decides which
  "! concrete product it returns.
  METHODS factorymethod
    RETURNING VALUE(result) TYPE REF TO product.
ENDINTERFACE.


CLASS concrete_creatora DEFINITION.
  PUBLIC SECTION.
    INTERFACES creator.
ENDCLASS.


CLASS concrete_creatora IMPLEMENTATION.
  METHOD creator~factorymethod.
    result = NEW concrete_producta( ).
  ENDMETHOD.
ENDCLASS.


CLASS concrete_creatorb DEFINITION.
  PUBLIC SECTION.
    INTERFACES creator.
ENDCLASS.


CLASS concrete_creatorb IMPLEMENTATION.
  METHOD creator~factorymethod.
    result = NEW concrete_productb( ).
  ENDMETHOD.
ENDCLASS.


CLASS main_app DEFINITION.
  PUBLIC SECTION.
    "! All creators, held only by the `creator` interface type.
    CLASS-DATA creators TYPE TABLE OF REF TO creator.

    "! Runs the demo: every creator is asked for a product and the
    "! resulting class and product name are reported.
    CLASS-METHODS main.
ENDCLASS.


CLASS main_app IMPLEMENTATION.
  METHOD main.

    DATA class_name TYPE abap_abstypename.
    DATA product_name TYPE product=>ty_productname.

    FIELD-SYMBOLS <creator> TYPE REF TO creator.

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

      " The client only ever calls the interface's factory method.
      DATA(created_product) = <creator>->factorymethod( ).

      " Reflection gives the runtime class, the product gives its name.
      get_clazz_name created_product class_name.
      product_name = created_product->get_name( ).
      cl_demo_output=>write( |  Class = { class_name }, Product = { product_name }| ).

    ENDLOOP.

    cl_demo_output=>display( ).

  ENDMETHOD.
ENDCLASS.


START-OF-SELECTION.
  main_app=>main( ).
