       IDENTIFICATION DIVISION.
       PROGRAM-ID. STRUTIL.
      *****************************************************************
      * STRUTIL - string helpers.  Parameters: STRUTIL-PARMS.cpy
      *   UPPER    upper-case SU-TEXT
      *   LOWER    lower-case SU-TEXT
      *   TRIM     remove leading spaces from SU-TEXT
      *   REVERSE  reverse the significant characters of SU-TEXT
      * Every function sets SU-LENGTH to the length of SU-TEXT
      * ignoring trailing spaces (0 when SU-TEXT is all spaces).
      *****************************************************************
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-WORK                 PIC X(80).

       LINKAGE SECTION.
       COPY STRUTIL-PARMS.

       PROCEDURE DIVISION USING STRUTIL-PARMS.
       MAIN-PARA.
           SET SU-OK TO TRUE
           EVALUATE TRUE
               WHEN SU-UPPER
                   MOVE FUNCTION UPPER-CASE(SU-TEXT) TO SU-TEXT
               WHEN SU-LOWER
                   MOVE FUNCTION LOWER-CASE(SU-TEXT) TO SU-TEXT
               WHEN SU-TRIM
                   PERFORM TRIM-TEXT
               WHEN SU-REVERSE
                   PERFORM REVERSE-TEXT
               WHEN OTHER
                   SET SU-BAD-FUNCTION TO TRUE
           END-EVALUATE
           PERFORM SET-LENGTH
           GOBACK.

       TRIM-TEXT.
           IF SU-TEXT NOT = SPACES
               MOVE FUNCTION TRIM(SU-TEXT LEADING) TO WS-WORK
               MOVE WS-WORK TO SU-TEXT
           END-IF.

       REVERSE-TEXT.
           PERFORM SET-LENGTH
           IF SU-LENGTH > 0
               MOVE FUNCTION REVERSE(SU-TEXT(1:SU-LENGTH)) TO WS-WORK
               MOVE WS-WORK TO SU-TEXT
           END-IF.

       SET-LENGTH.
           IF SU-TEXT = SPACES
               MOVE 0 TO SU-LENGTH
           ELSE
               MOVE FUNCTION LENGTH(FUNCTION TRIM(SU-TEXT TRAILING))
                   TO SU-LENGTH
           END-IF.

       END PROGRAM STRUTIL.
