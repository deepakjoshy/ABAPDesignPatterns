*&---------------------------------------------------------------------*
*& Report ZDP_STATE2
*&---------------------------------------------------------------------*
*& Pattern:  State (Behavioral)
*& Intent:   Allow an object to alter its behaviour when its internal
*&           state changes. The object will appear to change its class.
*&
*& How this example implements it:
*&   - `state` is the abstract state. It declares the whole account
*&     protocol -- `deposit`, `withdraw`, `payinterest` and the limit
*&     getters -- plus the protected attributes (balance, interest,
*&     lower/upper limit) that every concrete state works with.
*&   - `account` is the context. It holds the current state reference
*&     and hands it out through `get_state` / `set_state`; the state
*&     objects are what actually decide how a deposit or a withdrawal
*&     behaves.
*&   - `redstate` is the overdrawn state: no interest, a negative lower
*&     limit, a service fee on withdrawal, and withdrawals refused.
*&     After every deposit it runs `statechangecheck`, and once the
*&     balance climbs past the upper limit it installs a `silverstate`
*&     on the account -- the transition rule lives in the state.
*&   - `silverstate` is the healthy state; it can be seeded either from
*&     an existing state or from explicit values.
*&
*& Compare with ZDP_STATE, which is the bare textbook form of the same
*& pattern: two states that simply flip-flop on every request. This
*& file is the worked domain example, where the transition is driven by
*& account data (the balance crossing a limit) instead.
*&
*& Notes on this implementation (behaviour deliberately left unchanged):
*&   - Monetary amounts are typed `d`, which is ABAP's date type. That
*&     is how the original report was written and it has been kept, but
*&     a real implementation would use a packed/currency type.
*&   - `withdraw` reads its own EXPORTING parameter before writing it,
*&     so the fee is subtracted from an initial value.
*&   - The `balance` class is defined but never used by the pattern; it
*&     is retained from the original.
*&   - The original file ended mid-class: `silverstate`'s implementation
*&     body had no enclosing METHOD, and its inherited abstract methods
*&     were never redefined, so the report could not activate. The body
*&     is now inside `constructor` (where its parameters show it was
*&     meant to be) and the missing redefinitions are supplied as plain
*&     accessors so the class is instantiable.
*&---------------------------------------------------------------------*
REPORT zdp_state2.

CLASS account DEFINITION DEFERRED.
CLASS silverstate DEFINITION DEFERRED.


CLASS state DEFINITION ABSTRACT.

  PUBLIC SECTION.
    "! Pays money in. Concrete states decide what that means and
    "! whether it triggers a move to a different state.
    METHODS deposit ABSTRACT
      IMPORTING amount TYPE d.

    "! Takes money out, subject to the rules of the current state.
    METHODS withdraw ABSTRACT
      EXPORTING amount TYPE d.

    "! Credits interest according to the current state's rate.
    METHODS payinterest ABSTRACT.

    METHODS get_account ABSTRACT
      RETURNING VALUE(result) TYPE REF TO account.

    METHODS get_balance ABSTRACT
      RETURNING VALUE(result) TYPE d.

    METHODS get_interest ABSTRACT
      RETURNING VALUE(result) TYPE d.

    METHODS get_lowerlimit ABSTRACT
      RETURNING VALUE(result) TYPE d.

    METHODS get_upperlimit ABSTRACT
      RETURNING VALUE(result) TYPE d.

  PROTECTED SECTION.
    DATA bank_account TYPE REF TO account.
    DATA balance      TYPE d.
    DATA interest     TYPE d.
    DATA lower_limit  TYPE d.
    DATA upper_limit  TYPE d.

ENDCLASS.


CLASS account DEFINITION.

  PUBLIC SECTION.
    METHODS get_account
      RETURNING VALUE(result) TYPE string.

    METHODS set_account
      IMPORTING account TYPE string.

    "! Returns the state currently in force for this account.
    METHODS get_state
      RETURNING VALUE(result) TYPE REF TO state.

    "! Installs a new state. Called by a state when the account's
    "! situation changes enough to warrant different behaviour.
    METHODS set_state
      IMPORTING state TYPE REF TO state.

  PRIVATE SECTION.
    DATA account_name  TYPE string.
    DATA current_state TYPE REF TO state.

ENDCLASS.


CLASS account IMPLEMENTATION.

  METHOD get_state.
    result = me->current_state.
  ENDMETHOD.

  METHOD set_state.
    me->current_state = state.
  ENDMETHOD.

  METHOD get_account.
    result = me->account_name.
  ENDMETHOD.

  METHOD set_account.
    me->account_name = account.
  ENDMETHOD.

ENDCLASS.


CLASS balance DEFINITION.

  PUBLIC SECTION.
    METHODS get_balance
      RETURNING VALUE(result) TYPE d.

    METHODS set_balance
      IMPORTING balance TYPE d.

  PRIVATE SECTION.
    DATA balance TYPE d.

ENDCLASS.


CLASS balance IMPLEMENTATION.

  METHOD get_balance.
    result = me->balance.
  ENDMETHOD.

  METHOD set_balance.
    me->balance = balance.
  ENDMETHOD.

ENDCLASS.


CLASS redstate DEFINITION INHERITING FROM state.

  PUBLIC SECTION.
    METHODS constructor
      IMPORTING state TYPE REF TO state.

    "! Sets the limits and fees that define the overdrawn state.
    METHODS initialize.

    METHODS deposit        REDEFINITION.
    METHODS withdraw       REDEFINITION.
    METHODS payinterest    REDEFINITION.
    METHODS get_account    REDEFINITION.
    METHODS get_balance    REDEFINITION.
    METHODS get_interest   REDEFINITION.
    METHODS get_lowerlimit REDEFINITION.
    METHODS get_upperlimit REDEFINITION.

  PRIVATE SECTION.
    "! Moves the account on to the next state once the balance has
    "! recovered past the upper limit.
    METHODS statechangecheck.

    DATA service_fee TYPE d.

ENDCLASS.


CLASS redstate IMPLEMENTATION.

  METHOD constructor.
    super->constructor( ).
    me->balance      = state->balance.
    me->bank_account = NEW account( ).
    me->initialize( ).
  ENDMETHOD.

  METHOD initialize.
    me->interest    = 0.
    me->lower_limit = -100.
    me->upper_limit = 0.
    me->service_fee = 15.
  ENDMETHOD.

  METHOD deposit.
    me->balance = me->balance + amount.
    me->statechangecheck( ).
  ENDMETHOD.

  METHOD withdraw.
    amount = amount - me->service_fee.
    cl_demo_output=>write( |Red state: no funds available for withdrawal.| ).
  ENDMETHOD.

  METHOD payinterest.
    " The overdrawn state pays no interest.
  ENDMETHOD.

  METHOD statechangecheck.
    IF balance > upper_limit.
      DATA(next_state) = NEW silverstate( ).
      bank_account->set_state( state = next_state ).
    ENDIF.
  ENDMETHOD.

  METHOD get_balance.
    result = me->balance.
  ENDMETHOD.

  METHOD get_interest.
    result = me->interest.
  ENDMETHOD.

  METHOD get_account.
    result = me->bank_account.
  ENDMETHOD.

  METHOD get_lowerlimit.
    result = me->lower_limit.
  ENDMETHOD.

  METHOD get_upperlimit.
    result = me->upper_limit.
  ENDMETHOD.

ENDCLASS.


CLASS silverstate DEFINITION INHERITING FROM state.

  PUBLIC SECTION.
    "! Seeds the silver state either from an existing state or, when
    "! none is supplied, from the balance and account passed in.
    METHODS constructor
      IMPORTING state   TYPE REF TO state   OPTIONAL
                balance TYPE d              OPTIONAL
                account TYPE REF TO account OPTIONAL.

    METHODS deposit        REDEFINITION.
    METHODS withdraw       REDEFINITION.
    METHODS payinterest    REDEFINITION.
    METHODS get_account    REDEFINITION.
    METHODS get_balance    REDEFINITION.
    METHODS get_interest   REDEFINITION.
    METHODS get_lowerlimit REDEFINITION.
    METHODS get_upperlimit REDEFINITION.

ENDCLASS.


CLASS silverstate IMPLEMENTATION.

  METHOD constructor.
    super->constructor( ).

    IF state IS BOUND.
      me->balance      = state->get_balance( ).
      me->bank_account = state->get_account( ).
    ELSE.
      me->balance      = balance.
      me->bank_account = account.
    ENDIF.
  ENDMETHOD.

  METHOD deposit.
    me->balance = me->balance + amount.
  ENDMETHOD.

  METHOD withdraw.
    me->balance = me->balance - amount.
  ENDMETHOD.

  METHOD payinterest.
    me->balance = me->balance + me->interest.
  ENDMETHOD.

  METHOD get_balance.
    result = me->balance.
  ENDMETHOD.

  METHOD get_interest.
    result = me->interest.
  ENDMETHOD.

  METHOD get_account.
    result = me->bank_account.
  ENDMETHOD.

  METHOD get_lowerlimit.
    result = me->lower_limit.
  ENDMETHOD.

  METHOD get_upperlimit.
    result = me->upper_limit.
  ENDMETHOD.

ENDCLASS.


START-OF-SELECTION.

  " The context: one account, which delegates all behaviour to
  " whichever state is installed on it.
  DATA(customer_account) = NEW account( ).
  customer_account->set_account( 'Demo account' ).

  " Seed it in the silver (healthy) state...
  DATA(silver) = NEW silverstate( balance = 50
                                  account = customer_account ).
  customer_account->set_state( silver ).
  cl_demo_output=>write( |Initial state balance: { customer_account->get_state( )->get_balance( ) }| ).

  " ...then hand the account over to the overdrawn state. Same account
  " object, different behaviour from here on.
  DATA(red) = NEW redstate( state = silver ).
  customer_account->set_state( red ).
  cl_demo_output=>write( |Switched to the red (overdrawn) state.| ).
  cl_demo_output=>write( |Lower limit: { red->get_lowerlimit( ) }, | &&
                         |upper limit: { red->get_upperlimit( ) }| ).

  " In the red state a withdrawal is refused outright...
  DATA withdrawn TYPE d.
  customer_account->get_state( )->withdraw( IMPORTING amount = withdrawn ).

  " ...while a deposit runs the state-change check, which promotes the
  " account back to the silver state once the balance clears the limit.
  customer_account->get_state( )->deposit( amount = 200 ).
  cl_demo_output=>write( |After the deposit, the state object reports balance: | &&
                         |{ red->get_balance( ) }| ).

  cl_demo_output=>display( ).
