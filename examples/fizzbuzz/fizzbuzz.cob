       IDENTIFICATION DIVISION.
       PROGRAM-ID. FIZZBUZZ.
      *****************************************************************
      * FizzBuzz 1..30: multiples of 3 print Fizz, of 5 print Buzz,
      * of both print FizzBuzz, anything else prints the number.
      *****************************************************************
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-N                    PIC 99.
       01  WS-N-OUT                PIC Z9.

       PROCEDURE DIVISION.
       MAIN-PARA.
           PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > 30
               EVALUATE FUNCTION MOD(WS-N, 3) ALSO FUNCTION MOD(WS-N, 5)
                   WHEN 0 ALSO 0
                       DISPLAY "FizzBuzz"
                   WHEN 0 ALSO ANY
                       DISPLAY "Fizz"
                   WHEN ANY ALSO 0
                       DISPLAY "Buzz"
                   WHEN OTHER
                       MOVE WS-N TO WS-N-OUT
                       DISPLAY FUNCTION TRIM(WS-N-OUT)
               END-EVALUATE
           END-PERFORM
           STOP RUN.
