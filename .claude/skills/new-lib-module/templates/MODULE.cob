       IDENTIFICATION DIVISION.
       PROGRAM-ID. @MOD@.
      *****************************************************************
      * @MOD@ - @DESC@
      * Parameters: @MOD@-PARMS.cpy
      *   @FUNC@     copy @PFX@-INPUT to @PFX@-RESULT (replace me)
      * Return codes: 00 ok, 10 invalid input, 90 unknown function.
      *****************************************************************
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-WORK                 PIC X(80).

       LINKAGE SECTION.
       COPY @MOD@-PARMS.

       PROCEDURE DIVISION USING @MOD@-PARMS.
       MAIN-PARA.
           SET @PFX@-OK TO TRUE
           MOVE SPACES TO @PFX@-RESULT
           EVALUATE TRUE
               WHEN @PFX@-@FUNC@
                   PERFORM DO-@FUNC@
               WHEN OTHER
                   SET @PFX@-BAD-FUNCTION TO TRUE
           END-EVALUATE
           GOBACK.

       DO-@FUNC@.
           IF @PFX@-INPUT = SPACES
               SET @PFX@-INVALID TO TRUE
           ELSE
               MOVE @PFX@-INPUT TO WS-WORK
               MOVE WS-WORK TO @PFX@-RESULT
           END-IF.

       END PROGRAM @MOD@.
