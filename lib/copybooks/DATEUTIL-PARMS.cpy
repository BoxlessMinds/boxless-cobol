      *****************************************************************
      * DATEUTIL-PARMS - parameter block for CALL "DATEUTIL".
      *
      *     MOVE "FORMAT"  TO DU-FUNCTION
      *     MOVE 20261023  TO DU-DATE-NUM
      *     CALL "DATEUTIL" USING DATEUTIL-PARMS
      *     IF DU-OK  DISPLAY DU-RESULT          *> 2026-10-23
      *****************************************************************
       01  DATEUTIL-PARMS.
           05  DU-FUNCTION         PIC X(8).
               88  DU-VALIDATE               VALUE "VALIDATE".
               88  DU-FORMAT                 VALUE "FORMAT".
               88  DU-DAY-OF-WEEK            VALUE "DOW".
           05  DU-DATE.
               10  DU-YYYY         PIC 9(4).
               10  DU-MM           PIC 9(2).
               10  DU-DD           PIC 9(2).
           05  DU-DATE-NUM REDEFINES DU-DATE
                                   PIC 9(8).
           05  DU-RESULT           PIC X(10).
           05  DU-RC               PIC 9(2).
               88  DU-OK                     VALUE 0.
               88  DU-INVALID-DATE           VALUE 10.
               88  DU-BAD-FUNCTION           VALUE 90.
