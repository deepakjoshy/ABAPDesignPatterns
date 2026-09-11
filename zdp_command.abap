*&---------------------------------------------------------------------*
*& Report ZDP_COMMAND
*&---------------------------------------------------------------------*
*& Pattern:  Command (Behavioral)
*& Intent:   Encapsulate a request as an object, thereby letting you
*&           parameterise clients with different requests, queue or log
*&           requests, and support undoable operations.
*&
*& How this example implements it:
*&   - `lcl_receiver` is the object that actually knows how to do the
*&     work; its `action( )` method is the real operation.
*&   - `lcl_command` is the abstract request object. It holds the
*&     receiver and declares a single abstract `execute( )`.
*&   - `lcl_concrete_command` binds the two together: its `execute( )`
*&     simply calls `action( )` on the receiver it was constructed with.
*&   - `lcl_invoker` triggers the request through `execute_command( )`.
*&     It only ever sees the abstract command -- it knows nothing about
*&     the receiver or about what the command really does.
*&---------------------------------------------------------------------*
REPORT zdp_command.


CLASS lcl_receiver DEFINITION.

  PUBLIC SECTION.
    "! The real operation. Only a command object ever calls this.
    METHODS action.

ENDCLASS.


CLASS lcl_receiver IMPLEMENTATION.

  METHOD action.
    cl_demo_output=>write( |Receiver: action( ) was carried out.| ).
  ENDMETHOD.

ENDCLASS.


CLASS lcl_command DEFINITION ABSTRACT.

  PUBLIC SECTION.
    METHODS constructor
      IMPORTING receiver TYPE REF TO lcl_receiver.

    "! Carries out the encapsulated request on the receiver.
    METHODS execute ABSTRACT.

  PROTECTED SECTION.
    "! The object the request is finally delegated to.
    DATA receiver TYPE REF TO lcl_receiver.

ENDCLASS.


CLASS lcl_command IMPLEMENTATION.

  METHOD constructor.
    me->receiver = receiver.
  ENDMETHOD.

ENDCLASS.


CLASS lcl_concrete_command DEFINITION INHERITING FROM lcl_command.

  PUBLIC SECTION.
    "! Binds the request to lcl_receiver=>action( ).
    METHODS execute REDEFINITION.

ENDCLASS.


CLASS lcl_concrete_command IMPLEMENTATION.

  METHOD execute.
    receiver->action( ).
  ENDMETHOD.

ENDCLASS.


CLASS lcl_invoker DEFINITION.

  PUBLIC SECTION.
    "! Stores the command that will be triggered later on.
    METHODS set_command
      IMPORTING command TYPE REF TO lcl_command.

    "! Triggers the stored command without knowing what it does.
    METHODS execute_command.

  PRIVATE SECTION.
    DATA command TYPE REF TO lcl_command.

ENDCLASS.


CLASS lcl_invoker IMPLEMENTATION.

  METHOD set_command.
    me->command = command.
  ENDMETHOD.

  METHOD execute_command.
    command->execute( ).
  ENDMETHOD.

ENDCLASS.


START-OF-SELECTION.

  " The client wires receiver, command and invoker together...
  DATA(receiver) = NEW lcl_receiver( ).
  DATA(command)  = NEW lcl_concrete_command( receiver ).
  DATA(invoker)  = NEW lcl_invoker( ).

  cl_demo_output=>write( |The invoker is given a command object and later triggers it. | &&
                         |It never learns which receiver is behind the request.| ).

  " ...and from here on the invoker deals with the abstract command only.
  invoker->set_command( command ).
  invoker->execute_command( ).

  cl_demo_output=>display( ).
