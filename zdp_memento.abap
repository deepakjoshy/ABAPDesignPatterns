*&---------------------------------------------------------------------*
*& Report ZDP_MEMENTO
*&---------------------------------------------------------------------*
*& Pattern:  Memento (Behavioral)
*& Intent:   Without violating encapsulation, capture and externalise
*&           an object's internal state so that the object can be
*&           restored to this state later.
*&
*& How this example implements it:
*&   - `text_editor` is the Originator. It owns the state that matters
*&     (`content` and `cursor`) and is the only class that knows how to
*&     read or write it.
*&   - `editor_memento` is the Memento. It is CREATE PRIVATE FRIENDS
*&     text_editor, so only the editor can build one, and the state
*&     getters live in its PRIVATE SECTION, so only the editor can look
*&     inside. Everybody else sees just the harmless `get_label( )`.
*&   - `text_editor->save( )` hands back a snapshot; `restore( )` takes
*&     one back and copies the state out of it again.
*&   - `editor_history` is the Caretaker. It keeps a stack of mementos
*&     and hands the newest one back on `undo( )`. It never inspects
*&     what it is holding -- it only ever passes the object around.
*&   - The demo types text, takes a checkpoint, types more text, then
*&     undoes twice and shows the content reverting step by step.
*&---------------------------------------------------------------------*
REPORT zdp_memento.

CLASS text_editor DEFINITION DEFERRED.


CLASS editor_memento DEFINITION CREATE PRIVATE FRIENDS text_editor.

  PUBLIC SECTION.
    "! A short human-readable tag for the snapshot. This is the only
    "! thing the caretaker is allowed to see -- the state itself stays
    "! private to the originator.
    METHODS get_label
      RETURNING VALUE(result) TYPE string.

  PRIVATE SECTION.
    METHODS constructor
      IMPORTING content TYPE string
                cursor  TYPE i
                label   TYPE string.

    METHODS get_content
      RETURNING VALUE(result) TYPE string.

    METHODS get_cursor
      RETURNING VALUE(result) TYPE i.

    DATA content TYPE string.
    DATA cursor  TYPE i.
    DATA label   TYPE string.

ENDCLASS.


CLASS editor_memento IMPLEMENTATION.

  METHOD constructor.
    me->content = content.
    me->cursor  = cursor.
    me->label   = label.
  ENDMETHOD.

  METHOD get_label.
    result = label.
  ENDMETHOD.

  METHOD get_content.
    result = content.
  ENDMETHOD.

  METHOD get_cursor.
    result = cursor.
  ENDMETHOD.

ENDCLASS.


CLASS text_editor DEFINITION.

  PUBLIC SECTION.
    "! Appends text at the cursor and moves the cursor to the new end.
    METHODS type
      IMPORTING text TYPE string.

    "! Captures the current state in a memento the caller can keep.
    METHODS save
      IMPORTING label         TYPE string
      RETURNING VALUE(result) TYPE REF TO editor_memento.

    "! Puts the editor back into the state held by the given memento.
    METHODS restore
      IMPORTING snapshot TYPE REF TO editor_memento.

    METHODS describe
      RETURNING VALUE(result) TYPE string.

  PRIVATE SECTION.
    DATA content TYPE string.
    DATA cursor  TYPE i.

ENDCLASS.


CLASS text_editor IMPLEMENTATION.

  METHOD type.
    content = content && text.
    cursor  = strlen( content ).
  ENDMETHOD.

  METHOD save.
    result = NEW #( content = content
                    cursor  = cursor
                    label   = label ).
  ENDMETHOD.

  METHOD restore.
    IF snapshot IS NOT BOUND.
      RETURN.
    ENDIF.
    content = snapshot->get_content( ).
    cursor  = snapshot->get_cursor( ).
  ENDMETHOD.

  METHOD describe.
    result = |"{ content }" (cursor at { cursor })|.
  ENDMETHOD.

ENDCLASS.


CLASS editor_history DEFINITION.

  PUBLIC SECTION.
    "! Pushes a snapshot onto the undo stack without looking inside it.
    METHODS push
      IMPORTING snapshot TYPE REF TO editor_memento.

    "! Pops the most recent snapshot, or an unbound reference when the
    "! stack is empty.
    METHODS undo
      RETURNING VALUE(result) TYPE REF TO editor_memento.

  PRIVATE SECTION.
    DATA snapshots TYPE STANDARD TABLE OF REF TO editor_memento WITH EMPTY KEY.

ENDCLASS.


CLASS editor_history IMPLEMENTATION.

  METHOD push.
    IF snapshot IS BOUND.
      APPEND snapshot TO snapshots.
    ENDIF.
  ENDMETHOD.

  METHOD undo.
    DATA(last) = lines( snapshots ).
    IF last = 0.
      RETURN.
    ENDIF.
    result = snapshots[ last ].
    DELETE snapshots INDEX last.
  ENDMETHOD.

ENDCLASS.


START-OF-SELECTION.

  DATA(editor)  = NEW text_editor( ).
  DATA(history) = NEW editor_history( ).

  " Type something, then park a snapshot with the caretaker.
  editor->type( `Dear customer,` ).
  history->push( editor->save( `after greeting` ) ).
  cl_demo_output=>write( |Typed greeting, checkpoint taken: { editor->describe( ) }| ).

  " Keep typing and take a second checkpoint.
  editor->type( ` your order has shipped.` ).
  history->push( editor->save( `after body` ) ).
  cl_demo_output=>write( |Typed body, checkpoint taken:     { editor->describe( ) }| ).

  " More typing -- this part is deliberately NOT checkpointed.
  editor->type( ` Ignore this sentence.` ).
  cl_demo_output=>write( |Typed an unwanted sentence:       { editor->describe( ) }| ).

  " The caretaker hands snapshots back newest-first; the editor is the
  " only one that can actually read the state out of them.
  DO 2 TIMES.
    DATA(snapshot) = history->undo( ).
    IF snapshot IS NOT BOUND.
      cl_demo_output=>write( |Nothing left to undo.| ).
      EXIT.
    ENDIF.
    editor->restore( snapshot ).
    cl_demo_output=>write( |Undo to "{ snapshot->get_label( ) }": { editor->describe( ) }| ).
  ENDDO.

  cl_demo_output=>write( |The editor is back to an earlier state, and the history | &&
                         |never once looked inside a memento.| ).
  cl_demo_output=>display( ).
