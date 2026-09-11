*&---------------------------------------------------------------------*
*& Report ZDP_TEMPLATEMETHOD
*&---------------------------------------------------------------------*
*& Pattern:  Template Method (Behavioral)
*& Intent:   Define the skeleton of an algorithm in an operation,
*&           deferring some steps to subclasses. Template Method lets
*&           subclasses redefine certain steps of an algorithm without
*&           changing the algorithm's structure.
*&
*& How this example implements it:
*&   - `template_sandwich` is the abstract base class. Its public
*&     method `prepare_sandwich` is the template method: it is FINAL,
*&     so subclasses cannot change the order of the steps.
*&   - `prepare_sandwich` always runs the same four steps:
*&     slice_bread -> add_butter -> add_extra -> add_vegetables.
*&   - `slice_bread` is private and invariant -- every sandwich gets it.
*&     `add_butter` has a default implementation a subclass MAY
*&     override (a "hook"). `add_extra` and `add_vegetables` are
*&     ABSTRACT, so every subclass MUST supply them.
*&   - `cheese_sandwich` overrides all three overridable steps;
*&     `ham_sandwich` overrides only the two mandatory ones and so
*&     keeps the inherited butter step.
*&---------------------------------------------------------------------*
REPORT zdp_templatemethod.


CLASS template_sandwich DEFINITION ABSTRACT.

  PUBLIC SECTION.
    "! The template method. Runs the fixed sequence of steps that makes
    "! a sandwich. FINAL, so the sequence itself can never be changed.
    METHODS prepare_sandwich FINAL.

  PROTECTED SECTION.
    "! Optional step with a default implementation -- subclasses may
    "! redefine it to change how much butter goes on.
    METHODS add_butter.

    "! Mandatory step. Each sandwich supplies its own filling.
    METHODS add_extra ABSTRACT.

    "! Mandatory step. Each sandwich supplies its own vegetables.
    METHODS add_vegetables ABSTRACT.

  PRIVATE SECTION.
    "! Invariant step. Identical for every sandwich, so it stays private.
    METHODS slice_bread.

ENDCLASS.

CLASS template_sandwich IMPLEMENTATION.

  METHOD prepare_sandwich.
    slice_bread( ).
    add_butter( ).
    add_extra( ).
    add_vegetables( ).
  ENDMETHOD.

  METHOD add_butter.
    cl_demo_output=>write( |Add thin layer of butter| ).
  ENDMETHOD.

  METHOD slice_bread.
    cl_demo_output=>write( |Slice bread.| ).
  ENDMETHOD.

ENDCLASS.


CLASS cheese_sandwich DEFINITION INHERITING FROM template_sandwich.

  PROTECTED SECTION.
    METHODS add_extra REDEFINITION.
    METHODS add_vegetables REDEFINITION.
    METHODS add_butter REDEFINITION.

ENDCLASS.

CLASS cheese_sandwich IMPLEMENTATION.

  METHOD add_butter.
    cl_demo_output=>write( |Add thick layer of butter| ).
  ENDMETHOD.

  METHOD add_extra.
    cl_demo_output=>write( |Add slices of camembert| ).
  ENDMETHOD.

  METHOD add_vegetables.
    cl_demo_output=>write( |Add tomato slices| ).
  ENDMETHOD.

ENDCLASS.


CLASS ham_sandwich DEFINITION INHERITING FROM template_sandwich.

  PROTECTED SECTION.
    METHODS add_extra REDEFINITION.
    METHODS add_vegetables REDEFINITION.

ENDCLASS.

CLASS ham_sandwich IMPLEMENTATION.

  METHOD add_extra.
    cl_demo_output=>write( |Add slice of ham| ).
  ENDMETHOD.

  METHOD add_vegetables.
    cl_demo_output=>write( |Add salad leaves| ).
    cl_demo_output=>write( |Add onions| ).
  ENDMETHOD.

ENDCLASS.


START-OF-SELECTION.

  " Same template method, two different sandwiches.
  cl_demo_output=>write( |Preparing a cheese sandwich:| ).
  DATA(cheese) = NEW cheese_sandwich( ).
  cheese->prepare_sandwich( ).

  " ham_sandwich does not redefine add_butter, so it inherits the
  " thin-layer default step from template_sandwich.
  cl_demo_output=>write( |Preparing a ham sandwich:| ).
  DATA(ham) = NEW ham_sandwich( ).
  ham->prepare_sandwich( ).

  cl_demo_output=>display( ).
