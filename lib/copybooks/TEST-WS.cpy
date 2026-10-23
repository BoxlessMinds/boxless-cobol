      *****************************************************************
      * TEST-WS - working storage for the tiny test harness.
      * COPY into WORKING-STORAGE; COPY TEST-PROC at the end of the
      * PROCEDURE DIVISION.  For each case:
      *     MOVE "what is tested" TO TEST-NAME
      *     MOVE expected-value   TO TEST-EXPECTED
      *     MOVE actual-value     TO TEST-ACTUAL
      *     PERFORM ASSERT-EQUAL
      * Finish with PERFORM TEST-SUMMARY then STOP RUN.
      *****************************************************************
       01  TEST-COUNTERS.
           05  TEST-RUN            PIC 9(4) VALUE 0.
           05  TEST-FAILED         PIC 9(4) VALUE 0.
       01  TEST-CASE.
           05  TEST-NAME           PIC X(50).
           05  TEST-EXPECTED       PIC X(80).
           05  TEST-ACTUAL         PIC X(80).
