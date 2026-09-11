*&---------------------------------------------------------------------*
*& Report ZDP_SINGLETONFACTORY
*&---------------------------------------------------------------------*
*& Pattern:  Singleton Factory (Creational) -- Singleton + Factory
*& Intent:   Ensure a class has only one instance and provide a global
*&           point of access to it, and let that single instance decide
*&           which concrete class to instantiate for a requested type,
*&           so clients create products without naming their classes.
*&
*& How this example implements it:
*&   - `notification` is the product interface. `email_notification`
*&     and `sms_notification` are the two concrete products.
*&   - `notification_factory` is the factory, and it is itself a
*&     Singleton: `CREATE PRIVATE` blocks outside instantiation and the
*&     class method `get_instance` is the single point of access. The
*&     first call creates and caches the factory, later calls return
*&     the very same reference.
*&   - The instance method `create_notification` is the factory part:
*&     it maps a channel key ('EMAIL' / 'SMS') onto a concrete product
*&     class and returns it typed only as `notification`.
*&   - Because there is exactly one factory object, the counter
*&     `created_count` it keeps is a true total across all clients --
*&     which is what makes the two patterns worth combining here.
*&---------------------------------------------------------------------*
REPORT zdp_singletonfactory.

INTERFACE notification.
  "! Delivers the message to the recipient over this channel.
  METHODS send
    IMPORTING message TYPE string
    RETURNING VALUE(result) TYPE string.
ENDINTERFACE.


CLASS email_notification DEFINITION.
  PUBLIC SECTION.
    INTERFACES notification.

    METHODS constructor
      IMPORTING recipient TYPE string.

  PRIVATE SECTION.
    DATA recipient TYPE string.
ENDCLASS.


CLASS email_notification IMPLEMENTATION.

  METHOD constructor.
    me->recipient = recipient.
  ENDMETHOD.

  METHOD notification~send.
    result = |E-mail to { recipient }: { message }|.
  ENDMETHOD.

ENDCLASS.


CLASS sms_notification DEFINITION.
  PUBLIC SECTION.
    INTERFACES notification.

    METHODS constructor
      IMPORTING recipient TYPE string.

  PRIVATE SECTION.
    DATA recipient TYPE string.
ENDCLASS.


CLASS sms_notification IMPLEMENTATION.

  METHOD constructor.
    me->recipient = recipient.
  ENDMETHOD.

  METHOD notification~send.
    result = |SMS to { recipient }: { message }|.
  ENDMETHOD.

ENDCLASS.


CLASS notification_factory DEFINITION CREATE PRIVATE.

  PUBLIC SECTION.
    "! Returns the single shared factory, creating it on first access.
    CLASS-METHODS get_instance
      RETURNING VALUE(result) TYPE REF TO notification_factory.

    "! Creates a product for the requested channel. Returns an unbound
    "! reference if the channel is unknown.
    METHODS create_notification
      IMPORTING channel       TYPE string
                recipient     TYPE string
      RETURNING VALUE(result) TYPE REF TO notification.

    "! How many products this one factory has handed out so far.
    METHODS get_created_count
      RETURNING VALUE(result) TYPE i.

  PRIVATE SECTION.
    "! The one shared factory. Empty until the first get_instance( ) call.
    CLASS-DATA instance TYPE REF TO notification_factory.
    DATA created_count TYPE i.

ENDCLASS.


CLASS notification_factory IMPLEMENTATION.

  METHOD get_instance.
    IF instance IS NOT BOUND.
      instance = NEW #( ).
    ENDIF.
    result = instance.
  ENDMETHOD.

  METHOD create_notification.
    CASE channel.
      WHEN 'EMAIL'.
        result = NEW email_notification( recipient ).
      WHEN 'SMS'.
        result = NEW sms_notification( recipient ).
      WHEN OTHERS.
        CLEAR result.
    ENDCASE.

    IF result IS BOUND.
      created_count = created_count + 1.
    ENDIF.
  ENDMETHOD.

  METHOD get_created_count.
    result = created_count.
  ENDMETHOD.

ENDCLASS.


START-OF-SELECTION.

  " Client A asks for "the" factory -- it cannot use NEW itself.
  DATA(factory_a) = notification_factory=>get_instance( ).
  DATA(mail) = factory_a->create_notification( channel   = 'EMAIL'
                                               recipient = 'dj@example.com' ).
  cl_demo_output=>write( |Factory built an e-mail product: { mail->send( 'Build finished' ) }| ).

  " Client B never creates its own factory, it just asks for the shared one.
  DATA(factory_b) = notification_factory=>get_instance( ).
  DATA(text) = factory_b->create_notification( channel   = 'SMS'
                                               recipient = '+91 90000 00000' ).
  cl_demo_output=>write( |Factory built an SMS product:    { text->send( 'Build finished' ) }| ).

  " Unknown channel: the factory decides there is nothing to build.
  DATA(unknown) = factory_b->create_notification( channel   = 'FAX'
                                                  recipient = 'nobody' ).
  IF unknown IS NOT BOUND.
    cl_demo_output=>write( |Channel 'FAX' is unknown, so the factory returned no product| ).
  ENDIF.

  " Singleton proof: one object, and therefore one shared creation count.
  cl_demo_output=>write( |factory_a and factory_b are the same object: { xsdbool( factory_a = factory_b ) }| ).
  cl_demo_output=>write( |Products created by the single factory: { factory_a->get_created_count( ) }| ).
  cl_demo_output=>display( ).
