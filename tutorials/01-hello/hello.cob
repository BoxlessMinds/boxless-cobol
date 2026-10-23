       IDENTIFICATION DIVISION.
       PROGRAM-ID. HELLO.
      *****************************************************************
      * Lesson 01 - Hello, COBOL
      *
      * Fixed-format source layout (the classic 80-column card):
      *   columns 1-6   sequence number area (ignored)
      *   column  7     indicator: '*' = comment line, '-' = continue
      *   columns 8-11  Area A: division/section/paragraph names, 01s
      *   columns 12-72 Area B: statements
      *
      * Every program has up to four divisions, in this order:
      *   IDENTIFICATION  names the program        (required)
      *   ENVIRONMENT     files and machine setup  (optional)
      *   DATA            variables                (optional)
      *   PROCEDURE       the code that runs       (optional)
      *****************************************************************
       PROCEDURE DIVISION.
           DISPLAY "Hello from COBOL".
           STOP RUN.
