       IDENTIFICATION DIVISION.
       PROGRAM-ID. FILES.
      *****************************************************************
      * Lesson 07 - Sequential files
      *
      * Reads employees.dat, writes everyone earning over 50,000 to
      * high-earners.out.  Run from this folder (make run does that).
      *
      *   ENVIRONMENT DIVISION / FILE-CONTROL   link a name to a file
      *   DATA DIVISION / FILE SECTION (FD)     the record layout
      *   OPEN / READ ... AT END / WRITE / CLOSE
      *   FILE STATUS   two-character result of every I/O ("00" = ok)
      *****************************************************************
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT EMP-FILE ASSIGN TO "employees.dat"
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS WS-EMP-STATUS.
           SELECT OUT-FILE ASSIGN TO "high-earners.out"
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS WS-OUT-STATUS.

       DATA DIVISION.
       FILE SECTION.
       FD  EMP-FILE.
       01  EMP-RECORD.
           05  EMP-ID              PIC 9(5).
           05  EMP-NAME            PIC X(20).
           05  EMP-DEPT            PIC X(10).
           05  EMP-SALARY          PIC 9(6).

       FD  OUT-FILE.
       01  OUT-RECORD              PIC X(50).

       WORKING-STORAGE SECTION.
       01  WS-EMP-STATUS           PIC XX.
       01  WS-OUT-STATUS           PIC XX.
       01  WS-EOF                  PIC X          VALUE "N".
           88  END-OF-FILE                        VALUE "Y".
       01  WS-READ-COUNT           PIC 9(3)       VALUE 0.
       01  WS-WRITE-COUNT          PIC 9(3)       VALUE 0.
       01  WS-OUT-LINE.
           05  OL-NAME             PIC X(20).
           05  OL-DEPT             PIC X(10).
           05  OL-SALARY           PIC ZZZ,ZZ9.

       PROCEDURE DIVISION.
       MAIN-PARA.
           OPEN INPUT EMP-FILE
           IF WS-EMP-STATUS NOT = "00"
               DISPLAY "Cannot open employees.dat, status "
                       WS-EMP-STATUS
               MOVE 1 TO RETURN-CODE
               STOP RUN
           END-IF
           OPEN OUTPUT OUT-FILE

      *    Priming read, then loop until AT END sets the flag.
           PERFORM READ-EMPLOYEE
           PERFORM UNTIL END-OF-FILE
               IF EMP-SALARY > 50000
                   PERFORM WRITE-HIGH-EARNER
               END-IF
               PERFORM READ-EMPLOYEE
           END-PERFORM

           CLOSE EMP-FILE OUT-FILE
           DISPLAY "Read " WS-READ-COUNT " employees, wrote "
                   WS-WRITE-COUNT " to high-earners.out"
           STOP RUN.

       READ-EMPLOYEE.
           READ EMP-FILE
               AT END
                   SET END-OF-FILE TO TRUE
               NOT AT END
                   ADD 1 TO WS-READ-COUNT
           END-READ.

       WRITE-HIGH-EARNER.
           MOVE EMP-NAME TO OL-NAME
           MOVE EMP-DEPT TO OL-DEPT
           MOVE EMP-SALARY TO OL-SALARY
           WRITE OUT-RECORD FROM WS-OUT-LINE
           ADD 1 TO WS-WRITE-COUNT
           DISPLAY "  " WS-OUT-LINE.
