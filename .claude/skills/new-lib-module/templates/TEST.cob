       IDENTIFICATION DIVISION.
       PROGRAM-ID. TEST-@MOD@.
      *****************************************************************
      * Unit tests for lib/src/@MOD@.cob
      *****************************************************************
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       COPY TEST-WS.
       COPY @MOD@-PARMS.

       PROCEDURE DIVISION.
       MAIN-PARA.
           DISPLAY "TEST-@MOD@"

           MOVE "@FUNC@ returns the input" TO TEST-NAME
           MOVE "@FUNC@" TO @PFX@-FUNCTION
           MOVE "sample" TO @PFX@-INPUT
           CALL "@MOD@" USING @MOD@-PARMS
           MOVE "sample" TO TEST-EXPECTED
           MOVE @PFX@-RESULT TO TEST-ACTUAL
           PERFORM ASSERT-EQUAL

           MOVE "@FUNC@ of spaces returns RC 10" TO TEST-NAME
           MOVE SPACES TO @PFX@-INPUT
           CALL "@MOD@" USING @MOD@-PARMS
           MOVE "10" TO TEST-EXPECTED
           MOVE @PFX@-RC TO TEST-ACTUAL
           PERFORM ASSERT-EQUAL

           MOVE "unknown function returns RC 90" TO TEST-NAME
           MOVE "BOGUS" TO @PFX@-FUNCTION
           CALL "@MOD@" USING @MOD@-PARMS
           MOVE "90" TO TEST-EXPECTED
           MOVE @PFX@-RC TO TEST-ACTUAL
           PERFORM ASSERT-EQUAL

           PERFORM TEST-SUMMARY
           STOP RUN.

       COPY TEST-PROC.
