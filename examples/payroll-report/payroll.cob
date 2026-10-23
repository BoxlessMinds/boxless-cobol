       IDENTIFICATION DIVISION.
       PROGRAM-ID. PAYROLL.
      *****************************************************************
      * Payroll report with department control breaks.
      *
      * Input payroll.dat (sorted by department), one line per worker:
      *   cols  1-6   department
      *   cols  7-11  employee id
      *   cols 12-31  name
      *   cols 32-34  hours worked   99V9   (405 = 40.5 hours)
      *   cols 35-39  hourly rate    999V99 (02250 = 22.50)
      *
      * Gross = hours * rate, with hours over 40 paid at 1.5x.
      * Tax is a flat 20%.  Subtotals print when the department
      * changes; a grand total prints at the end.  The report date is
      * formatted by the DATEUTIL library module.
      *****************************************************************
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT PAY-FILE ASSIGN TO "payroll.dat"
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS WS-PAY-STATUS.

       DATA DIVISION.
       FILE SECTION.
       FD  PAY-FILE.
       01  PAY-RECORD.
           05  PAY-DEPT            PIC X(6).
           05  PAY-EMP-ID          PIC 9(5).
           05  PAY-NAME            PIC X(20).
           05  PAY-HOURS           PIC 99V9.
           05  PAY-RATE            PIC 999V99.

       WORKING-STORAGE SECTION.
       COPY DATEUTIL-PARMS.

       01  WS-PAY-STATUS           PIC XX.
       01  WS-EOF                  PIC X          VALUE "N".
           88  END-OF-FILE                        VALUE "Y".
       01  WS-PREV-DEPT            PIC X(6)       VALUE SPACES.

       01  WS-CALC.
           05  WS-OVERTIME         PIC 99V9.
           05  WS-GROSS            PIC 9(5)V99.
           05  WS-TAX              PIC 9(5)V99.
           05  WS-NET              PIC 9(5)V99.

       01  WS-TOTALS.
           05  WS-DEPT-GROSS       PIC 9(6)V99    VALUE 0.
           05  WS-DEPT-NET         PIC 9(6)V99    VALUE 0.
           05  WS-GRAND-GROSS      PIC 9(7)V99    VALUE 0.
           05  WS-GRAND-NET        PIC 9(7)V99    VALUE 0.

       01  WS-RULE                 PIC X(70)      VALUE ALL "-".

       01  WS-DETAIL-LINE.
           05  DL-DEPT             PIC X(7).
           05  DL-EMP-ID           PIC 9(5).
           05  FILLER              PIC X(2)       VALUE SPACES.
           05  DL-NAME             PIC X(20).
           05  DL-HOURS            PIC Z9.9.
           05  FILLER              PIC X(2)       VALUE SPACES.
           05  DL-GROSS            PIC ZZ,ZZ9.99.
           05  FILLER              PIC X(2)       VALUE SPACES.
           05  DL-TAX              PIC Z,ZZ9.99.
           05  FILLER              PIC X(2)       VALUE SPACES.
           05  DL-NET              PIC ZZ,ZZ9.99.

       01  WS-TOTAL-LINE.
           05  TL-LABEL            PIC X(39).
           05  TL-GROSS            PIC ZZZ,ZZ9.99.
           05  FILLER              PIC X(11)      VALUE SPACES.
           05  TL-NET              PIC ZZZ,ZZ9.99.

       PROCEDURE DIVISION.
       MAIN-PARA.
           OPEN INPUT PAY-FILE
           IF WS-PAY-STATUS NOT = "00"
               DISPLAY "Cannot open payroll.dat, status "
                       WS-PAY-STATUS
               MOVE 1 TO RETURN-CODE
               STOP RUN
           END-IF

           PERFORM PRINT-HEADINGS
           PERFORM READ-PAY
           IF NOT END-OF-FILE
               MOVE PAY-DEPT TO WS-PREV-DEPT
           END-IF
           PERFORM UNTIL END-OF-FILE
               IF PAY-DEPT NOT = WS-PREV-DEPT
                   PERFORM DEPT-BREAK
                   MOVE PAY-DEPT TO WS-PREV-DEPT
               END-IF
               PERFORM PROCESS-EMPLOYEE
               PERFORM READ-PAY
           END-PERFORM
           PERFORM DEPT-BREAK

           MOVE "GRAND TOTAL" TO TL-LABEL
           MOVE WS-GRAND-GROSS TO TL-GROSS
           MOVE WS-GRAND-NET TO TL-NET
           DISPLAY WS-RULE
           DISPLAY WS-TOTAL-LINE
           CLOSE PAY-FILE
           STOP RUN.

       PRINT-HEADINGS.
           MOVE "FORMAT" TO DU-FUNCTION
           ACCEPT DU-DATE-NUM FROM DATE YYYYMMDD
           CALL "DATEUTIL" USING DATEUTIL-PARMS
           DISPLAY "PAYROLL REPORT" "    run date " DU-RESULT
           DISPLAY WS-RULE
           DISPLAY "DEPT   ID     NAME                HOURS"
                   "     GROSS       TAX        NET"
           DISPLAY WS-RULE.

       READ-PAY.
           READ PAY-FILE
               AT END SET END-OF-FILE TO TRUE
           END-READ.

       PROCESS-EMPLOYEE.
           IF PAY-HOURS > 40
               COMPUTE WS-OVERTIME = PAY-HOURS - 40
           ELSE
               MOVE 0 TO WS-OVERTIME
           END-IF
           COMPUTE WS-GROSS ROUNDED =
               (PAY-HOURS - WS-OVERTIME) * PAY-RATE
               + WS-OVERTIME * PAY-RATE * 1.5
           COMPUTE WS-TAX ROUNDED = WS-GROSS * 0.20
           COMPUTE WS-NET = WS-GROSS - WS-TAX

           ADD WS-GROSS TO WS-DEPT-GROSS WS-GRAND-GROSS
           ADD WS-NET   TO WS-DEPT-NET   WS-GRAND-NET

           MOVE PAY-DEPT   TO DL-DEPT
           MOVE PAY-EMP-ID TO DL-EMP-ID
           MOVE PAY-NAME   TO DL-NAME
           MOVE PAY-HOURS  TO DL-HOURS
           MOVE WS-GROSS   TO DL-GROSS
           MOVE WS-TAX     TO DL-TAX
           MOVE WS-NET     TO DL-NET
           DISPLAY WS-DETAIL-LINE.

       DEPT-BREAK.
           MOVE SPACES TO TL-LABEL
           STRING "  subtotal " WS-PREV-DEPT DELIMITED BY SIZE
               INTO TL-LABEL
           MOVE WS-DEPT-GROSS TO TL-GROSS
           MOVE WS-DEPT-NET TO TL-NET
           DISPLAY WS-TOTAL-LINE
           DISPLAY " "
           MOVE 0 TO WS-DEPT-GROSS WS-DEPT-NET.
