       IDENTIFICATION DIVISION.
       PROGRAM-ID. CONTROL-FLOW.
      *****************************************************************
      * Lesson 04 - Control flow
      *
      *   IF / ELSE / END-IF        two-way branch
      *   EVALUATE / END-EVALUATE   COBOL's switch statement
      *   PERFORM para              call a paragraph and come back
      *   PERFORM n TIMES           fixed repetition
      *   PERFORM VARYING ... UNTIL a counted loop (test before)
      *   PERFORM ... END-PERFORM   inline loop body
      *****************************************************************
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-I                    PIC 99.
       01  WS-TOTAL                PIC 9(4)       VALUE 0.
       01  WS-SCORE                PIC 999.
       01  WS-GRADE                PIC X.
       01  WS-COUNTDOWN            PIC 9          VALUE 3.

       PROCEDURE DIVISION.
       MAIN-PARA.
      *    Inline loop: sum 1..10
           PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 10
               ADD WS-I TO WS-TOTAL
           END-PERFORM
           DISPLAY "Sum of 1..10 = " WS-TOTAL

      *    Out-of-line loop: the body is the GRADE-SCORE paragraph.
           PERFORM GRADE-SCORE
               VARYING WS-SCORE FROM 40 BY 15 UNTIL WS-SCORE > 100

      *    Fixed repetition
           PERFORM 2 TIMES
               DISPLAY "Hip hip ..."
           END-PERFORM
           DISPLAY "... hooray!"

      *    Loop until a condition is true
           PERFORM UNTIL WS-COUNTDOWN = 0
               DISPLAY "T-minus " WS-COUNTDOWN
               SUBTRACT 1 FROM WS-COUNTDOWN
           END-PERFORM
           DISPLAY "Liftoff"
           STOP RUN.

       GRADE-SCORE.
      *    EVALUATE TRUE: the first WHEN whose condition holds wins.
           EVALUATE TRUE
               WHEN WS-SCORE >= 90  MOVE "A" TO WS-GRADE
               WHEN WS-SCORE >= 80  MOVE "B" TO WS-GRADE
               WHEN WS-SCORE >= 70  MOVE "C" TO WS-GRADE
               WHEN WS-SCORE >= 60  MOVE "D" TO WS-GRADE
               WHEN OTHER           MOVE "F" TO WS-GRADE
           END-EVALUATE

      *    EVALUATE on a subject; several WHENs can share one action.
           EVALUATE WS-GRADE
               WHEN "A"
               WHEN "B"
                   DISPLAY "Score " WS-SCORE " grade " WS-GRADE
                           " - merit"
               WHEN "F"
                   DISPLAY "Score " WS-SCORE " grade " WS-GRADE
                           " - retake"
               WHEN OTHER
                   DISPLAY "Score " WS-SCORE " grade " WS-GRADE
           END-EVALUATE.
