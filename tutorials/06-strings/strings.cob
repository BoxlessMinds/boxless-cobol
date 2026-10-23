       IDENTIFICATION DIVISION.
       PROGRAM-ID. STRINGS.
      *****************************************************************
      * Lesson 06 - Working with text
      *
      *   STRING      concatenate pieces into one field
      *   UNSTRING    split a field on delimiters
      *   INSPECT     count, replace or convert characters
      *   x(start:length)   reference modification (substring)
      *   FUNCTION TRIM / UPPER-CASE / LENGTH / REVERSE ...
      *****************************************************************
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-FIRST                PIC X(10)      VALUE "Ada".
       01  WS-LAST                 PIC X(10)      VALUE "Lovelace".
       01  WS-FULL                 PIC X(30).

       01  WS-ISO-DATE             PIC X(10)      VALUE "2026-10-23".
       01  WS-YEAR                 PIC X(4).
       01  WS-MONTH                PIC X(2).
       01  WS-DAY                  PIC X(2).

       01  WS-CSV                  PIC X(40)
                                   VALUE "Hopper,Grace,1906,Navy".
       01  WS-FIELD                PIC X(10) OCCURS 4 TIMES.
       01  WS-FIELD-COUNT          PIC 9.

       01  WS-SENTENCE             PIC X(40)
                                   VALUE "the quick brown fox".
       01  WS-COUNT                PIC 99         VALUE 0.

       PROCEDURE DIVISION.
       MAIN-PARA.
      *    DELIMITED BY SPACE stops at the first space (drops padding);
      *    DELIMITED BY SIZE takes the whole item.
           STRING WS-FIRST DELIMITED BY SPACE
                  " "      DELIMITED BY SIZE
                  WS-LAST  DELIMITED BY SPACE
               INTO WS-FULL
           END-STRING
           DISPLAY "STRING   : [" FUNCTION TRIM(WS-FULL) "]"

           UNSTRING WS-ISO-DATE DELIMITED BY "-"
               INTO WS-YEAR WS-MONTH WS-DAY
           END-UNSTRING
           DISPLAY "UNSTRING : year " WS-YEAR " month " WS-MONTH
                   " day " WS-DAY

           UNSTRING WS-CSV DELIMITED BY ","
               INTO WS-FIELD(1) WS-FIELD(2) WS-FIELD(3) WS-FIELD(4)
               TALLYING IN WS-FIELD-COUNT
           END-UNSTRING
           DISPLAY "CSV      : " WS-FIELD-COUNT " fields, name = "
                   FUNCTION TRIM(WS-FIELD(2)) " "
                   FUNCTION TRIM(WS-FIELD(1))

           INSPECT WS-SENTENCE TALLYING WS-COUNT FOR ALL "o"
           DISPLAY "INSPECT  : letter o appears " WS-COUNT " times"

           INSPECT WS-ISO-DATE REPLACING ALL "-" BY "/"
           DISPLAY "REPLACING: " WS-ISO-DATE

           INSPECT WS-SENTENCE
               CONVERTING "abcdefghijklmnopqrstuvwxyz"
                       TO "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
           DISPLAY "CONVERT  : " FUNCTION TRIM(WS-SENTENCE)

      *    Reference modification: characters 5 for a length of 5.
           DISPLAY "SUBSTR   : " WS-SENTENCE(5:5)

           DISPLAY "FUNCTIONS: length of trimmed name = "
                   FUNCTION LENGTH(FUNCTION TRIM(WS-FULL))
           DISPLAY "           reversed = "
                   FUNCTION REVERSE(FUNCTION TRIM(WS-FULL))
           STOP RUN.
