*&---------------------------------------------------------------------*
*& Report ZDP_ITERATOR
*&---------------------------------------------------------------------*
*& Pattern:  Iterator (Behavioral)
*& Intent:   Provide a way to access the elements of an aggregate
*&           object sequentially without exposing its underlying
*&           representation.
*&
*& How this example implements it:
*&   - `if_collection` is the aggregate interface (add, remove, clear,
*&     size, is_empty, get) plus the factory method `get_iterator`.
*&   - `lcl_collection` is the concrete aggregate. It stores the
*&     elements in an internal table -- callers never see that table
*&     when they iterate.
*&   - `if_iterator` is the iterator interface (first, has_next,
*&     get_next, get_index, set_step) and keeps the traversal state
*&     (current position and step width).
*&   - `lcl_iterator` is the concrete iterator. It holds a reference
*&     back to the collection and walks it through `get( index )`, so
*&     the traversal logic lives outside the collection.
*&   - The demo fills a collection with `lcl_item` objects and walks
*&     it with `has_next( )` / `get_next( )` only.
*&---------------------------------------------------------------------*
REPORT zdp_iterator.


CLASS lcl_item DEFINITION.

  PUBLIC SECTION.
    METHODS constructor
      IMPORTING name TYPE string.

    DATA name TYPE string READ-ONLY.

ENDCLASS.


CLASS lcl_item IMPLEMENTATION.

  METHOD constructor.
    me->name = name.
  ENDMETHOD.

ENDCLASS.


INTERFACE if_collection DEFERRED.


INTERFACE if_iterator.

  "! Position the iterator on the first element and return it.
  METHODS first
    RETURNING VALUE(result) TYPE REF TO object.

  "! True as long as a further element can be reached with the
  "! current step width.
  METHODS has_next
    RETURNING VALUE(result) TYPE flag.

  "! Advance by the current step width and return that element.
  METHODS get_next
    RETURNING VALUE(result) TYPE REF TO object.

  METHODS get_index
    RETURNING VALUE(result) TYPE i.

  "! Change how many positions get_next( ) jumps forward.
  METHODS set_step
    IMPORTING VALUE(step) TYPE i.

  DATA step TYPE i.
  DATA current TYPE i.
  DATA collection TYPE REF TO if_collection.

ENDINTERFACE.


INTERFACE if_collection.

  "! Creates an iterator that traverses this collection.
  METHODS get_iterator
    RETURNING VALUE(result) TYPE REF TO if_iterator.

  METHODS add
    IMPORTING element TYPE REF TO object.

  METHODS remove
    IMPORTING element TYPE REF TO object.

  METHODS clear.

  METHODS size
    RETURNING VALUE(result) TYPE i.

  METHODS is_empty
    RETURNING VALUE(result) TYPE flag.

  "! Returns the element at the given position, or an unbound
  "! reference when the position does not exist.
  METHODS get
    IMPORTING index         TYPE i
    RETURNING VALUE(result) TYPE REF TO object.

ENDINTERFACE.


CLASS lcl_iterator DEFINITION.

  PUBLIC SECTION.
    INTERFACES if_iterator.

    METHODS constructor
      IMPORTING collection TYPE REF TO if_collection.

    ALIASES get_index FOR if_iterator~get_index.
    ALIASES has_next FOR if_iterator~has_next.
    ALIASES get_next FOR if_iterator~get_next.
    ALIASES first FOR if_iterator~first.
    ALIASES set_step FOR if_iterator~set_step.

  PRIVATE SECTION.
    ALIASES step FOR if_iterator~step.
    ALIASES current FOR if_iterator~current.
    ALIASES collection FOR if_iterator~collection.

ENDCLASS.


CLASS lcl_collection DEFINITION.

  PUBLIC SECTION.
    INTERFACES if_collection.

    DATA items TYPE STANDARD TABLE OF REF TO object.

    ALIASES get_iterator FOR if_collection~get_iterator.
    ALIASES add FOR if_collection~add.
    ALIASES remove FOR if_collection~remove.
    ALIASES clear FOR if_collection~clear.
    ALIASES size FOR if_collection~size.
    ALIASES is_empty FOR if_collection~is_empty.
    ALIASES get FOR if_collection~get.

ENDCLASS.


CLASS lcl_collection IMPLEMENTATION.

  METHOD if_collection~get_iterator.
    result = NEW lcl_iterator( me ).
  ENDMETHOD.

  METHOD if_collection~add.
    APPEND element TO items.
  ENDMETHOD.

  METHOD if_collection~remove.
    DELETE items WHERE table_line = element.
  ENDMETHOD.

  METHOD if_collection~clear.
    CLEAR items.
  ENDMETHOD.

  METHOD if_collection~size.
    result = lines( items ).
  ENDMETHOD.

  METHOD if_collection~is_empty.
    IF me->size( ) IS INITIAL.
      result = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD if_collection~get.
    READ TABLE items INTO result INDEX index.
  ENDMETHOD.

ENDCLASS.


CLASS lcl_iterator IMPLEMENTATION.

  METHOD constructor.
    me->collection = collection.
    step = 1.
  ENDMETHOD.

  METHOD if_iterator~first.
    current = 1.
    result = collection->get( current ).
  ENDMETHOD.

  METHOD if_iterator~get_next.
    current = current + step.
    result = collection->get( current ).
  ENDMETHOD.

  METHOD if_iterator~has_next.
    DATA(next_index) = current + step.
    DATA(next_element) = collection->get( next_index ).
    IF next_element IS BOUND.
      result = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD if_iterator~set_step.
    me->step = step.
  ENDMETHOD.

  METHOD if_iterator~get_index.
    " This example does not expose the traversal position, so the
    " initial value is returned.
  ENDMETHOD.

ENDCLASS.


START-OF-SELECTION.

  " The aggregate: callers never touch its internal table directly.
  DATA(collection) = NEW lcl_collection( ).

  collection->add( NEW lcl_item( 'Item1' ) ).
  collection->add( NEW lcl_item( 'Item2' ) ).
  collection->add( NEW lcl_item( 'Item3' ) ).
  collection->add( NEW lcl_item( 'Item4' ) ).
  collection->add( NEW lcl_item( 'Item5' ) ).

  cl_demo_output=>write( |Collection holds { collection->size( ) } items| ).
  cl_demo_output=>write( |Walking it through the iterator only:| ).

  " The iterator knows how to traverse; the collection stays opaque.
  DATA(iterator) = collection->get_iterator( ).

  WHILE iterator->has_next( ) = abap_true.
    DATA(item) = CAST lcl_item( iterator->get_next( ) ).
    cl_demo_output=>write( |  { item->name }| ).
  ENDWHILE.

  cl_demo_output=>display( ).
