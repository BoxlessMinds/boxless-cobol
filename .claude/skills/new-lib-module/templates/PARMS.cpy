      *****************************************************************
      * @MOD@-PARMS - parameter block for CALL "@MOD@".
      *
      *     MOVE "@FUNC@" TO @PFX@-FUNCTION
      *     MOVE WS-VALUE TO @PFX@-INPUT
      *     CALL "@MOD@" USING @MOD@-PARMS
      *     IF @PFX@-OK  DISPLAY @PFX@-RESULT
      *****************************************************************
       01  @MOD@-PARMS.
           05  @PFX@-FUNCTION         PIC X(8).
               88  @PFX@-@FUNC@               VALUE "@FUNC@".
           05  @PFX@-INPUT            PIC X(80).
           05  @PFX@-RESULT           PIC X(80).
           05  @PFX@-RC               PIC 9(2).
               88  @PFX@-OK                  VALUE 0.
               88  @PFX@-INVALID             VALUE 10.
               88  @PFX@-BAD-FUNCTION        VALUE 90.
