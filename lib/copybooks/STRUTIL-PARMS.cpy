      *****************************************************************
      * STRUTIL-PARMS - parameter block for CALL "STRUTIL".
      *
      *     MOVE "UPPER"  TO SU-FUNCTION
      *     MOVE WS-NAME  TO SU-TEXT
      *     CALL "STRUTIL" USING STRUTIL-PARMS
      *     IF SU-OK  ... SU-TEXT(1:SU-LENGTH) ...
      *****************************************************************
       01  STRUTIL-PARMS.
           05  SU-FUNCTION         PIC X(8).
               88  SU-UPPER                  VALUE "UPPER".
               88  SU-LOWER                  VALUE "LOWER".
               88  SU-TRIM                   VALUE "TRIM".
               88  SU-REVERSE                VALUE "REVERSE".
           05  SU-TEXT             PIC X(80).
           05  SU-LENGTH           PIC 9(3).
           05  SU-RC               PIC 9(2).
               88  SU-OK                     VALUE 0.
               88  SU-BAD-FUNCTION           VALUE 90.
