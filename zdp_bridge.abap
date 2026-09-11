*&---------------------------------------------------------------------*
*& Report ZDP_BRIDGE
*&---------------------------------------------------------------------*
*& Pattern:  Bridge (Structural)
*& Intent:   Decouple an abstraction from its implementation so that
*&           the two can vary independently.
*&
*& How this example implements it:
*&   - `abstract_road` is the abstraction (speed way vs. street). It
*&     does NOT inherit from the vehicle hierarchy -- it HOLDS one.
*&   - `abstract_car` is the implementor hierarchy (car vs. bus).
*&   - `set_vehicle` is the bridge: it plugs any vehicle into any road
*&     at runtime, so 2 roads x 2 vehicles = 4 combinations without a
*&     single extra class.
*&   - `run` on the road prints the road part and then delegates to
*&     `vehicle->run( )` for the vehicle part.
*&   - `class_name_of` uses RTTI to show which concrete implementor
*&     got bridged in, proving the road never knew its type at
*&     compile time.
*&---------------------------------------------------------------------*
REPORT zdp_bridge.

CLASS abstract_car DEFINITION DEFERRED.
CLASS cl_abap_typedescr DEFINITION LOAD.


"! Small RTTI helper: strips the program prefix off a local class name.
CLASS lcl_rtti DEFINITION.
  PUBLIC SECTION.
    "! Returns the plain (unqualified) class name of an object reference.
    CLASS-METHODS class_name_of
      IMPORTING object        TYPE REF TO object
      RETURNING VALUE(result) TYPE string.
ENDCLASS.

CLASS lcl_rtti IMPLEMENTATION.
  METHOD class_name_of.
    DATA match_offset TYPE i.
    DATA match_length TYPE i.

    result = cl_abap_classdescr=>get_class_name( object ).

    FIND REGEX 'CLASS=' IN result
      MATCH OFFSET match_offset
      MATCH LENGTH match_length.
    IF sy-subrc = 0.
      SHIFT result BY ( match_offset + match_length ) PLACES LEFT.
    ENDIF.
  ENDMETHOD.
ENDCLASS.


"! Abstraction side of the bridge: a road that some vehicle drives on.
CLASS abstract_road DEFINITION ABSTRACT.
  PUBLIC SECTION.
    "! Plugs an implementor (vehicle) into this abstraction (road).
    METHODS set_vehicle
      IMPORTING vehicle TYPE REF TO abstract_car.

    "! Drives this road, delegating the vehicle part to the implementor.
    METHODS run ABSTRACT.

  PROTECTED SECTION.
    DATA vehicle TYPE REF TO abstract_car.
ENDCLASS.

CLASS abstract_road IMPLEMENTATION.
  METHOD set_vehicle.
    me->vehicle = vehicle.
    cl_demo_output=>write( |Bridged in vehicle: { lcl_rtti=>class_name_of( me->vehicle ) }| ).
  ENDMETHOD.
ENDCLASS.


"! Implementor side of the bridge: anything that can drive.
CLASS abstract_car DEFINITION ABSTRACT.
  PUBLIC SECTION.
    "! Prints what kind of vehicle is doing the driving.
    METHODS run ABSTRACT.
ENDCLASS.


CLASS speed_way DEFINITION INHERITING FROM abstract_road.
  PUBLIC SECTION.
    METHODS run REDEFINITION.
ENDCLASS.

CLASS speed_way IMPLEMENTATION.
  METHOD run.
    cl_demo_output=>write( |Road: run on the speed way.| ).
    vehicle->run( ).
  ENDMETHOD.
ENDCLASS.


CLASS street DEFINITION INHERITING FROM abstract_road.
  PUBLIC SECTION.
    METHODS run REDEFINITION.
ENDCLASS.

CLASS street IMPLEMENTATION.
  METHOD run.
    cl_demo_output=>write( |Road: run on the street.| ).
    vehicle->run( ).
  ENDMETHOD.
ENDCLASS.


CLASS car DEFINITION INHERITING FROM abstract_car.
  PUBLIC SECTION.
    METHODS run REDEFINITION.
ENDCLASS.

CLASS car IMPLEMENTATION.
  METHOD run.
    cl_demo_output=>write( |Vehicle: this is a car running.| ).
  ENDMETHOD.
ENDCLASS.


CLASS bus DEFINITION INHERITING FROM abstract_car.
  PUBLIC SECTION.
    METHODS run REDEFINITION.
ENDCLASS.

CLASS bus IMPLEMENTATION.
  METHOD run.
    cl_demo_output=>write( |Vehicle: this is a bus running.| ).
  ENDMETHOD.
ENDCLASS.


CLASS mainapp DEFINITION.
  PUBLIC SECTION.
    "! Combines each road with a vehicle to show the bridge at work.
    CLASS-METHODS main.
ENDCLASS.

CLASS mainapp IMPLEMENTATION.
  METHOD main.
    " Abstraction 1 (speed way) bridged to implementor 1 (car).
    cl_demo_output=>write( |--- speed_way + car ---| ).
    DATA(highway) = NEW speed_way( ).
    highway->set_vehicle( NEW car( ) ).
    highway->run( ).

    " Abstraction 2 (street) bridged to implementor 2 (bus).
    " Neither hierarchy had to change to get this combination.
    cl_demo_output=>write( |--- street + bus ---| ).
    DATA(side_road) = NEW street( ).
    side_road->set_vehicle( NEW bus( ) ).
    side_road->run( ).
  ENDMETHOD.
ENDCLASS.


START-OF-SELECTION.

  mainapp=>main( ).
  cl_demo_output=>display( ).
