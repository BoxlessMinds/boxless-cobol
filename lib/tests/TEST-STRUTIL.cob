       IDENTIFICATION DIVISION.
       PROGRAM-ID. TEST-STRUTIL.
      *****************************************************************
      * Unit tests for lib/src/STRUTIL.cob
      *****************************************************************
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       COPY TEST-WS.
       COPY STRUTIL-PARMS.

       PROCEDURE DIVISION.
       MAIN-PARA.
           DISPLAY "TEST-STRUTIL"

           MOVE "UPPER converts to upper case" TO TEST-NAME
           MOVE "UPPER" TO SU-FUNCTION
           MOVE "Hello, World" TO SU-TEXT
           CALL "STRUTIL" USING STRUTIL-PARMS
           MOVE "HELLO, WORLD" TO TEST-EXPECTED
           MOVE SU-TEXT TO TEST-ACTUAL
           PERFORM ASSERT-EQUAL

           MOVE "UPPER sets length" TO TEST-NAME
           MOVE "012" TO TEST-EXPECTED
           MOVE SU-LENGTH TO TEST-ACTUAL
           PERFORM ASSERT-EQUAL

           MOVE "LOWER converts to lower case" TO TEST-NAME
           MOVE "LOWER" TO SU-FUNCTION
           MOVE "COBOL Rocks" TO SU-TEXT
           CALL "STRUTIL" USING STRUTIL-PARMS
           MOVE "cobol rocks" TO TEST-EXPECTED
           MOVE SU-TEXT TO TEST-ACTUAL
           PERFORM ASSERT-EQUAL

           MOVE "TRIM removes leading spaces" TO TEST-NAME
           MOVE "TRIM" TO SU-FUNCTION
           MOVE "     padded" TO SU-TEXT
           CALL "STRUTIL" USING STRUTIL-PARMS
           MOVE "padded" TO TEST-EXPECTED
           MOVE SU-TEXT TO TEST-ACTUAL
           PERFORM ASSERT-EQUAL

           MOVE "TRIM of all spaces gives length 0" TO TEST-NAME
           MOVE SPACES TO SU-TEXT
           CALL "STRUTIL" USING STRUTIL-PARMS
           MOVE "000" TO TEST-EXPECTED
           MOVE SU-LENGTH TO TEST-ACTUAL
           PERFORM ASSERT-EQUAL

           MOVE "REVERSE reverses significant text" TO TEST-NAME
           MOVE "REVERSE" TO SU-FUNCTION
           MOVE "COBOL" TO SU-TEXT
           CALL "STRUTIL" USING STRUTIL-PARMS
           MOVE "LOBOC" TO TEST-EXPECTED
           MOVE SU-TEXT TO TEST-ACTUAL
           PERFORM ASSERT-EQUAL

           MOVE "unknown function returns RC 90" TO TEST-NAME
           MOVE "BOGUS" TO SU-FUNCTION
           CALL "STRUTIL" USING STRUTIL-PARMS
           MOVE "90" TO TEST-EXPECTED
           MOVE SU-RC TO TEST-ACTUAL
           PERFORM ASSERT-EQUAL

           PERFORM TEST-SUMMARY
           STOP RUN.

       COPY TEST-PROC.
