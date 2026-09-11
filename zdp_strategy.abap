*&---------------------------------------------------------------------*
*& Report ZDP_STRATEGY
*&---------------------------------------------------------------------*
*& Pattern:  Strategy (Behavioral)
*& Intent:   Define a family of algorithms, encapsulate each one, and
*&           make them interchangeable. Strategy lets the algorithm vary
*&           independently from the clients that use it.
*&
*& How this example implements it:
*&   - `lif_strategy` is the common interface every algorithm honours.
*&     It declares a single operation, `algorithm`.
*&   - `concrete_strategya`, `concrete_strategyb` and
*&     `concrete_strategyc` are the interchangeable algorithms. Each
*&     implements `lif_strategy~algorithm` in its own way.
*&   - `context` holds a reference to one strategy, handed in through
*&     its constructor, and exposes `context_interface`. The context
*&     never knows which concrete algorithm it is holding -- it just
*&     delegates to the interface.
*&   - The demo below swaps a different strategy into the context three
*&     times; the calling code stays identical while the behaviour
*&     changes.
*&---------------------------------------------------------------------*
REPORT zdp_strategy.


INTERFACE lif_strategy.
  "! Runs the algorithm this strategy stands for.
  METHODS algorithm.
ENDINTERFACE.


CLASS concrete_strategya DEFINITION.
  PUBLIC SECTION.
    INTERFACES lif_strategy.
ENDCLASS.

CLASS concrete_strategya IMPLEMENTATION.

  METHOD lif_strategy~algorithm.
    cl_demo_output=>write( |Called Concrete Strategy A algorithm.| ).
  ENDMETHOD.

ENDCLASS.


CLASS concrete_strategyb DEFINITION.
  PUBLIC SECTION.
    INTERFACES lif_strategy.
ENDCLASS.

CLASS concrete_strategyb IMPLEMENTATION.

  METHOD lif_strategy~algorithm.
    cl_demo_output=>write( |Called Concrete Strategy B algorithm.| ).
  ENDMETHOD.

ENDCLASS.


CLASS concrete_strategyc DEFINITION.
  PUBLIC SECTION.
    INTERFACES lif_strategy.
ENDCLASS.

CLASS concrete_strategyc IMPLEMENTATION.

  METHOD lif_strategy~algorithm.
    cl_demo_output=>write( |Called Concrete Strategy C algorithm.| ).
  ENDMETHOD.

ENDCLASS.


CLASS context DEFINITION.

  PUBLIC SECTION.
    "! Stores the strategy this context should delegate to.
    METHODS constructor
      IMPORTING strategy TYPE REF TO lif_strategy.

    "! The operation clients call. Delegates to the configured
    "! strategy without knowing which one it is.
    METHODS context_interface.

  PRIVATE SECTION.
    DATA strategy TYPE REF TO lif_strategy.

ENDCLASS.

CLASS context IMPLEMENTATION.

  METHOD constructor.
    me->strategy = strategy.
  ENDMETHOD.

  METHOD context_interface.
    IF me->strategy IS NOT BOUND.
      RETURN.
    ENDIF.
    me->strategy->algorithm( ).
  ENDMETHOD.

ENDCLASS.


START-OF-SELECTION.

  cl_demo_output=>write( |Strategy pattern: same context call, three different algorithms.| ).

  " Strategy A plugged into the context.
  DATA(context_a) = NEW context( strategy = NEW concrete_strategya( ) ).
  context_a->context_interface( ).

  " Same client code, strategy B swapped in.
  DATA(context_b) = NEW context( strategy = NEW concrete_strategyb( ) ).
  context_b->context_interface( ).

  " Same client code again, strategy C swapped in.
  DATA(context_c) = NEW context( strategy = NEW concrete_strategyc( ) ).
  context_c->context_interface( ).

  cl_demo_output=>display( ).
