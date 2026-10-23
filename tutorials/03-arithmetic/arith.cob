       IDENTIFICATION DIVISION.
       PROGRAM-ID. ARITH.
      *****************************************************************
      * Lesson 03 - Arithmetic
      *
      * COBOL arithmetic is decimal (no binary floating point rounding
      * surprises).  Verbs: ADD, SUBTRACT, MULTIPLY, DIVIDE, COMPUTE.
      *   GIVING x       store the result in x instead of an operand
      *   ROUNDED        round instead of truncating extra decimals
      *   ON SIZE ERROR  run code when the result does not fit
      *****************************************************************
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-A                    PIC 9(3)V99    VALUE 10.50.
       01  WS-B                    PIC 9(3)V99    VALUE 3.
       01  WS-RESULT               PIC S9(5)V99   VALUE 0.
       01  WS-QUOTIENT             PIC 99.
       01  WS-REMAINDER            PIC 99.
       01  WS-SMALL                PIC 99.
       01  WS-OUT                  PIC -ZZ,ZZ9.99.

       PROCEDURE DIVISION.
       MAIN-PARA.
           ADD WS-A TO WS-B GIVING WS-RESULT
           MOVE WS-RESULT TO WS-OUT
           DISPLAY "ADD       10.50 + 3       = " WS-OUT

           SUBTRACT WS-A FROM WS-B GIVING WS-RESULT
           MOVE WS-RESULT TO WS-OUT
           DISPLAY "SUBTRACT  3 - 10.50       = " WS-OUT

           MULTIPLY WS-A BY WS-B GIVING WS-RESULT
           MOVE WS-RESULT TO WS-OUT
           DISPLAY "MULTIPLY  10.50 * 3       = " WS-OUT

           DIVIDE 17 BY 5 GIVING WS-QUOTIENT REMAINDER WS-REMAINDER
           DISPLAY "DIVIDE    17 / 5          = " WS-QUOTIENT
                   " remainder " WS-REMAINDER

      *    COMPUTE takes a normal expression: + - * / ** and ( ).
           COMPUTE WS-RESULT = (WS-A + WS-B) / 7
           MOVE WS-RESULT TO WS-OUT
           DISPLAY "COMPUTE   13.50 / 7       = " WS-OUT "  (truncated)"

           COMPUTE WS-RESULT ROUNDED = (WS-A + WS-B) / 7
           MOVE WS-RESULT TO WS-OUT
           DISPLAY "COMPUTE   ROUNDED         = " WS-OUT

           COMPUTE WS-RESULT = WS-A ** 2
           MOVE WS-RESULT TO WS-OUT
           DISPLAY "COMPUTE   10.50 ** 2      = " WS-OUT

      *    1050 does not fit in PIC 99: ON SIZE ERROR catches it and
      *    leaves WS-SMALL unchanged.
           COMPUTE WS-SMALL = WS-A * 100
               ON SIZE ERROR
                   DISPLAY "SIZE ERROR: 1050 will not fit in PIC 99"
               NOT ON SIZE ERROR
                   DISPLAY "fits: " WS-SMALL
           END-COMPUTE

      *    Without it, the high-order digits are silently dropped!
           COMPUTE WS-SMALL = WS-A * 100
           DISPLAY "Unchecked result in PIC 99 = " WS-SMALL
           STOP RUN.
