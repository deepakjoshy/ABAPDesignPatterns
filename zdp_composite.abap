*&---------------------------------------------------------------------*
*& Report ZDP_COMPOSITE
*&---------------------------------------------------------------------*
*& Pattern:  Composite (Structural)
*& Intent:   Compose objects into tree structures to represent
*&           part-whole hierarchies. Composite lets clients treat
*&           individual objects and compositions of objects uniformly.
*&
*& How this example implements it:
*&   - `lcl_shape` is the common abstraction (Component). It declares
*&     `add`, `remove` and `display` so a client never has to ask
*&     whether it is holding a leaf or a container.
*&   - `lcl_line` is the Leaf: it renders itself and rejects `add` /
*&     `remove` because it cannot contain anything.
*&   - `lcl_picture` is the Composite: it keeps a table of child shapes
*&     and implements `display` by rendering its own name and then
*&     delegating to every child with an increased indent.
*&   - The demo nests a second picture inside the first one, so the same
*&     `display( )` call walks a two-level tree through one interface.
*&---------------------------------------------------------------------*
REPORT zdp_composite.


CLASS lcl_shape DEFINITION ABSTRACT.

  PUBLIC SECTION.
    METHODS constructor
      IMPORTING name TYPE string.

    "! Adds a child shape. Only meaningful for composites.
    METHODS add ABSTRACT
      IMPORTING shape TYPE REF TO lcl_shape.

    "! Removes a child shape. Only meaningful for composites.
    METHODS remove ABSTRACT
      IMPORTING shape TYPE REF TO lcl_shape.

    "! Renders this shape -- and, for a composite, its whole subtree.
    METHODS display ABSTRACT
      IMPORTING indent TYPE i.

  PROTECTED SECTION.
    DATA name TYPE string.

ENDCLASS.


CLASS lcl_shape IMPLEMENTATION.

  METHOD constructor.
    me->name = name.
  ENDMETHOD.

ENDCLASS.


CLASS lcl_line DEFINITION INHERITING FROM lcl_shape.

  PUBLIC SECTION.
    "! A leaf cannot hold children, so this reports a refusal.
    METHODS add REDEFINITION.

    "! A leaf cannot hold children, so this reports a refusal.
    METHODS remove REDEFINITION.

    "! Renders the line itself, indented to its level in the tree.
    METHODS display REDEFINITION.

ENDCLASS.


CLASS lcl_line IMPLEMENTATION.

  METHOD add.
    cl_demo_output=>write( |Can not add to a line -- a line is a leaf.| ).
  ENDMETHOD.

  METHOD remove.
    cl_demo_output=>write( |Can not delete from a line -- a line is a leaf.| ).
  ENDMETHOD.

  METHOD display.
    cl_demo_output=>write( |{ repeat( val = `-` occ = indent ) }{ name }| ).
  ENDMETHOD.

ENDCLASS.


CLASS lcl_picture DEFINITION INHERITING FROM lcl_shape.

  PUBLIC SECTION.
    "! Puts another shape -- leaf or picture -- into this picture.
    METHODS add REDEFINITION.

    "! Takes a previously added shape out of this picture again.
    METHODS remove REDEFINITION.

    "! Renders this picture and then every child, one level deeper.
    METHODS display REDEFINITION.

  PRIVATE SECTION.
    DATA shapes TYPE STANDARD TABLE OF REF TO lcl_shape.

ENDCLASS.


CLASS lcl_picture IMPLEMENTATION.

  METHOD add.
    APPEND shape TO shapes.
  ENDMETHOD.

  METHOD remove.
    DELETE shapes WHERE table_line = shape.
  ENDMETHOD.

  METHOD display.
    cl_demo_output=>write( |{ repeat( val = `-` occ = indent ) }{ name }| ).

    DATA child_indent TYPE i.
    child_indent = indent + 1.

    LOOP AT shapes INTO DATA(shape).
      shape->display( child_indent ).
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.


START-OF-SELECTION.

  " The outer picture, filled with four leaf lines.
  DATA(picture) = NEW lcl_picture( name = `Picture` ).
  picture->add( NEW lcl_line( name = `Left Line` ) ).
  picture->add( NEW lcl_line( name = `Top Line` ) ).
  picture->add( NEW lcl_line( name = `Right Line` ) ).
  picture->add( NEW lcl_line( name = `Bottom Line` ) ).

  " A second picture, built exactly the same way...
  DATA(nested_picture) = NEW lcl_picture( name = `Picture 2` ).
  nested_picture->add( NEW lcl_line( name = `Left Line` ) ).
  nested_picture->add( NEW lcl_line( name = `Top Line` ) ).
  nested_picture->add( NEW lcl_line( name = `Right Line` ) ).
  nested_picture->add( NEW lcl_line( name = `Bottom Line` ) ).

  " ...and added to the first one through the very same add( ) method
  " that also accepts a simple line. That is the point of the pattern.
  picture->add( nested_picture ).
  picture->add( NEW lcl_line( name = `text` ) ).

  cl_demo_output=>write( |One display( ) call walks the whole part-whole tree. | &&
                         |The client never distinguishes a line from a picture.| ).
  picture->display( 4 ).

  cl_demo_output=>display( ).
