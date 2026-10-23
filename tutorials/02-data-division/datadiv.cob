       IDENTIFICATION DIVISION.
       PROGRAM-ID. DATADIV.
      *****************************************************************
      * Lesson 02 - The DATA DIVISION
      *
      * Every variable is declared up front with a level number and a
      * PICTURE (PIC) clause describing its size and type:
      *   PIC X(n)       alphanumeric, n characters
      *   PIC 9(n)       unsigned numeric, n digits
      *   PIC S9(n)      signed numeric
      *   PIC 9(n)V99    implied decimal point (V takes no storage)
      *   PIC -,--9.99   edited picture, for display only
      *
      * Level 01 starts a record; higher levels (05, 10 ...) nest
      * inside it.  Level 88 names a condition on the field above it.
      *****************************************************************
       DATA DIVISION.
       WORKING-STORAGE SECTION.
      * An elementary item: a single field.
       01  WS-GREETING             PIC X(20)
                                   VALUE "Welcome to COBOL".

      * A group item: just the sum of its parts, in order.
       01  WS-CUSTOMER.
           05  WS-CUST-ID          PIC 9(5)       VALUE 42.
           05  WS-CUST-NAME.
               10  WS-FIRST-NAME   PIC X(10)      VALUE "Grace".
               10  WS-LAST-NAME    PIC X(10)      VALUE "Hopper".
           05  WS-BALANCE          PIC S9(7)V99   VALUE -1234.50.
           05  WS-STATUS           PIC X          VALUE "A".
               88  WS-ACTIVE                      VALUE "A".
               88  WS-CLOSED                      VALUE "C".

      * Edited pictures turn raw numbers into readable text.
       01  WS-ID-OUT               PIC ZZZZ9.
       01  WS-BALANCE-OUT          PIC -,---,--9.99.

       PROCEDURE DIVISION.
       MAIN-PARA.
           DISPLAY WS-GREETING

           MOVE WS-CUST-ID TO WS-ID-OUT
           MOVE WS-BALANCE TO WS-BALANCE-OUT
           DISPLAY "Customer id  : " WS-ID-OUT
           DISPLAY "Name         : " WS-FIRST-NAME " " WS-LAST-NAME
      *    A group item can be displayed as a whole - it is just bytes.
           DISPLAY "Name (group) : [" WS-CUST-NAME "]"
           DISPLAY "Raw balance  : " WS-BALANCE
           DISPLAY "Edited       : " WS-BALANCE-OUT

      *    88-levels read like booleans ...
           IF WS-ACTIVE
               DISPLAY "Status       : active"
           END-IF
      *    ... and SET ... TO TRUE moves the 88's VALUE into the field.
           SET WS-CLOSED TO TRUE
           DISPLAY "Status field : " WS-STATUS
           STOP RUN.
