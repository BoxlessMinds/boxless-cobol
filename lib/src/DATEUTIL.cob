       IDENTIFICATION DIVISION.
       PROGRAM-ID. DATEUTIL.
      *****************************************************************
      * DATEUTIL - date helpers.  Parameters: DATEUTIL-PARMS.cpy
      *   VALIDATE  check DU-DATE (YYYYMMDD); DU-RESULT VALID/INVALID
      *   FORMAT    DU-RESULT = YYYY-MM-DD
      *   DOW       DU-RESULT = day name, e.g. FRIDAY
      * An invalid date sets DU-INVALID-DATE for every function.
      *****************************************************************
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-DAY-NAMES.
           05  FILLER              PIC X(9) VALUE "MONDAY".
           05  FILLER              PIC X(9) VALUE "TUESDAY".
           05  FILLER              PIC X(9) VALUE "WEDNESDAY".
           05  FILLER              PIC X(9) VALUE "THURSDAY".
           05  FILLER              PIC X(9) VALUE "FRIDAY".
           05  FILLER              PIC X(9) VALUE "SATURDAY".
           05  FILLER              PIC X(9) VALUE "SUNDAY".
       01  WS-DAY-TABLE REDEFINES WS-DAY-NAMES.
           05  WS-DAY-NAME         PIC X(9) OCCURS 7 TIMES.
       01  WS-DAY-NUM              PIC 9.

       LINKAGE SECTION.
       COPY DATEUTIL-PARMS.

       PROCEDURE DIVISION USING DATEUTIL-PARMS.
       MAIN-PARA.
           SET DU-OK TO TRUE
           MOVE SPACES TO DU-RESULT
           IF NOT (DU-VALIDATE OR DU-FORMAT OR DU-DAY-OF-WEEK)
               SET DU-BAD-FUNCTION TO TRUE
               GOBACK
           END-IF

           PERFORM CHECK-DATE
           IF DU-INVALID-DATE
               IF DU-VALIDATE
                   MOVE "INVALID" TO DU-RESULT
               END-IF
               GOBACK
           END-IF

           EVALUATE TRUE
               WHEN DU-VALIDATE
                   MOVE "VALID" TO DU-RESULT
               WHEN DU-FORMAT
                   STRING DU-YYYY "-" DU-MM "-" DU-DD
                       DELIMITED BY SIZE INTO DU-RESULT
               WHEN DU-DAY-OF-WEEK
      *            Day 1 of INTEGER-OF-DATE is Monday 1601-01-01.
                   COMPUTE WS-DAY-NUM = FUNCTION MOD(
                       FUNCTION INTEGER-OF-DATE(DU-DATE-NUM) - 1, 7) + 1
                   MOVE WS-DAY-NAME(WS-DAY-NUM) TO DU-RESULT
           END-EVALUATE
           GOBACK.

       CHECK-DATE.
           IF DU-DATE-NUM NOT NUMERIC
               SET DU-INVALID-DATE TO TRUE
           ELSE
               IF FUNCTION TEST-DATE-YYYYMMDD(DU-DATE-NUM) NOT = 0
                   SET DU-INVALID-DATE TO TRUE
               END-IF
           END-IF.

       END PROGRAM DATEUTIL.
