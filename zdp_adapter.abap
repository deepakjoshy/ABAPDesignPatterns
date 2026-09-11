*&---------------------------------------------------------------------*
*& Report ZDP_ADAPTER
*&---------------------------------------------------------------------*
*& Pattern:  Adapter (Structural)
*& Intent:   Convert the interface of a class into another interface
*&           clients expect. Adapter lets classes work together that
*&           could not otherwise because of incompatible interfaces.
*&
*& How this example implements it:
*&   - `lif_output` is the target interface every caller understands:
*&     one method, `generate_output`.
*&   - `simple_op` implements that interface directly -- no adapting
*&     needed.
*&   - `tree_output` is the adaptee: useful, but it speaks a different
*&     language (`generate_tree`) and cannot be changed.
*&   - `new_complex_op` is the adapter. It implements `lif_output`,
*&     holds a `tree_output` internally, and translates the call
*&     `generate_output( )` into `generate_tree( )`.
*&   - The demo block only ever holds a `lif_output` reference, so it
*&     cannot tell adapter and non-adapter apart.
*&---------------------------------------------------------------------*
REPORT zdp_adapter.

"! Target interface: what every caller in this report expects.
INTERFACE lif_output.
  "! Produces the output, however the implementation chooses to.
  METHODS generate_output.
ENDINTERFACE.


CLASS simple_op DEFINITION.
  PUBLIC SECTION.
    INTERFACES lif_output.
ENDCLASS.

CLASS simple_op IMPLEMENTATION.
  METHOD lif_output~generate_output.
    cl_demo_output=>write( |Simple Output - just using write.| ).
  ENDMETHOD.
ENDCLASS.


"! Adaptee: does the real work, but with an incompatible method name.
CLASS tree_output DEFINITION.
  PUBLIC SECTION.
    "! Builds a tree display -- the legacy API we have to adapt to.
    METHODS generate_tree.
ENDCLASS.

CLASS tree_output IMPLEMENTATION.
  METHOD generate_tree.
    cl_demo_output=>write( |Creating Tree ... using CL_GUI_ALV_TREE| ).
  ENDMETHOD.
ENDCLASS.


"! Adapter: exposes lif_output, delegates to the tree_output adaptee.
CLASS new_complex_op DEFINITION.
  PUBLIC SECTION.
    INTERFACES lif_output.
ENDCLASS.

CLASS new_complex_op IMPLEMENTATION.
  METHOD lif_output~generate_output.
    DATA(tree) = NEW tree_output( ).
    tree->generate_tree( ).
  ENDMETHOD.
ENDCLASS.


START-OF-SELECTION.

  DATA output TYPE REF TO lif_output.

  " A class that natively speaks the target interface.
  cl_demo_output=>write( |--- simple_op implements lif_output directly ---| ).
  output = NEW simple_op( ).
  output->generate_output( ).

  " Same call, same reference type -- but behind it sits an adapter
  " that forwards to tree_output->generate_tree( ).
  cl_demo_output=>write( |--- new_complex_op adapts tree_output ---| ).
  output = NEW new_complex_op( ).
  output->generate_output( ).

  cl_demo_output=>display( ).
