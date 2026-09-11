*&---------------------------------------------------------------------*
*& Report ZDP_BUILDER
*&---------------------------------------------------------------------*
*& Pattern:  Builder (Creational)
*& Intent:   Separate the construction of a complex object from its
*&           representation, so that the same construction process can
*&           create different representations.
*&
*& How this example implements it:
*&   - `lif_pizza` / `lcl_pizza` is the product being built: dough,
*&     sauce and topping.
*&   - `pizza_builder` is the abstract builder. It provides the shared
*&     `create_new_pizza` step and declares the three abstract build
*&     steps `build_dough`, `build_sauce`, `build_topping`.
*&   - `veg_pizza_builder` and `cheese_pizza_builder` are the concrete
*&     builders -- same steps, different representations.
*&   - `cook` is the director. `construct_pizza` always runs the same
*&     sequence (create, dough, sauce, topping) and never knows which
*&     kind of pizza comes out.
*&---------------------------------------------------------------------*
REPORT zdp_builder.


"! The product: the parts a pizza is assembled from.
INTERFACE lif_pizza.
  DATA dough   TYPE string.
  DATA sauce   TYPE string.
  DATA topping TYPE string.
ENDINTERFACE.


CLASS lcl_pizza DEFINITION.
  PUBLIC SECTION.
    INTERFACES lif_pizza.
ENDCLASS.


"! Abstract builder: defines the steps, leaves the recipe open.
CLASS pizza_builder DEFINITION ABSTRACT.
  PUBLIC SECTION.
    "! Creates the empty product this builder will fill in.
    METHODS create_new_pizza
      RETURNING VALUE(result) TYPE REF TO lif_pizza.

    "! Sets the dough of the pizza under construction.
    METHODS build_dough ABSTRACT.

    "! Sets the sauce of the pizza under construction.
    METHODS build_sauce ABSTRACT.

    "! Sets the topping of the pizza under construction.
    METHODS build_topping ABSTRACT.

  PROTECTED SECTION.
    DATA pizza TYPE REF TO lif_pizza.
ENDCLASS.

CLASS pizza_builder IMPLEMENTATION.
  METHOD create_new_pizza.
    pizza = NEW lcl_pizza( ).
    result = pizza.
  ENDMETHOD.
ENDCLASS.


CLASS veg_pizza_builder DEFINITION INHERITING FROM pizza_builder.
  PUBLIC SECTION.
    METHODS build_dough REDEFINITION.
    METHODS build_sauce REDEFINITION.
    METHODS build_topping REDEFINITION.
ENDCLASS.

CLASS veg_pizza_builder IMPLEMENTATION.
  METHOD build_dough.
    pizza->dough = 'Thin Crust'.
  ENDMETHOD.

  METHOD build_sauce.
    pizza->sauce = 'Mild'.
  ENDMETHOD.

  METHOD build_topping.
    pizza->topping = 'Olives, Pineapples, Jalapenos'.
  ENDMETHOD.
ENDCLASS.


CLASS cheese_pizza_builder DEFINITION INHERITING FROM pizza_builder.
  PUBLIC SECTION.
    METHODS build_dough REDEFINITION.
    METHODS build_sauce REDEFINITION.
    METHODS build_topping REDEFINITION.
ENDCLASS.

CLASS cheese_pizza_builder IMPLEMENTATION.
  METHOD build_dough.
    pizza->dough = 'Thick Crust'.
  ENDMETHOD.

  METHOD build_sauce.
    pizza->sauce = 'Mild Hot'.
  ENDMETHOD.

  METHOD build_topping.
    pizza->topping = 'Cheese, Cheese, Cheese, more Cheese'.
  ENDMETHOD.
ENDCLASS.


"! Director: knows the construction sequence, not the recipe.
CLASS cook DEFINITION.
  PUBLIC SECTION.
    "! Runs the full build sequence with the given builder and
    "! returns the finished pizza.
    METHODS construct_pizza
      IMPORTING builder       TYPE REF TO pizza_builder
      RETURNING VALUE(result) TYPE REF TO lif_pizza.

  PRIVATE SECTION.
    DATA current_builder TYPE REF TO pizza_builder.
ENDCLASS.

CLASS cook IMPLEMENTATION.
  METHOD construct_pizza.
    current_builder = builder.
    result = current_builder->create_new_pizza( ).

    current_builder->build_dough( ).
    current_builder->build_sauce( ).
    current_builder->build_topping( ).
  ENDMETHOD.
ENDCLASS.


START-OF-SELECTION.

  DATA(chef) = NEW cook( ).

  " Same director, same three build steps...
  DATA(veg_pizza) = chef->construct_pizza( NEW veg_pizza_builder( ) ).
  cl_demo_output=>write( |Veg pizza    -> dough: { veg_pizza->dough }, | &&
                         |sauce: { veg_pizza->sauce }, | &&
                         |topping: { veg_pizza->topping }| ).

  " ...different builder, completely different representation.
  DATA(cheese_pizza) = chef->construct_pizza( NEW cheese_pizza_builder( ) ).
  cl_demo_output=>write( |Cheese pizza -> dough: { cheese_pizza->dough }, | &&
                         |sauce: { cheese_pizza->sauce }, | &&
                         |topping: { cheese_pizza->topping }| ).

  cl_demo_output=>display( ).
