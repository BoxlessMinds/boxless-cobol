      *****************************************************************
      * TEST-PROC - assertion paragraphs.  Requires COPY TEST-WS.
      *****************************************************************
       ASSERT-EQUAL.
           ADD 1 TO TEST-RUN
           IF TEST-ACTUAL = TEST-EXPECTED
               DISPLAY "  PASS  " FUNCTION TRIM(TEST-NAME)
           ELSE
               ADD 1 TO TEST-FAILED
               DISPLAY "  FAIL  " FUNCTION TRIM(TEST-NAME)
               DISPLAY "          expected ["
                       FUNCTION TRIM(TEST-EXPECTED TRAILING) "]"
               DISPLAY "          actual   ["
                       FUNCTION TRIM(TEST-ACTUAL TRAILING) "]"
           END-IF.

       TEST-SUMMARY.
           DISPLAY "  " TEST-RUN " run, " TEST-FAILED " failed"
           IF TEST-FAILED > 0
               MOVE 1 TO RETURN-CODE
           ELSE
               MOVE 0 TO RETURN-CODE
           END-IF.
