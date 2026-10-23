       IDENTIFICATION DIVISION.
       PROGRAM-ID. SUBPROG.
      *****************************************************************
      * Lesson 08 - Subprograms and the library
      *
      *   CALL "NAME" USING a b    run another program, passing data
      *   LINKAGE SECTION          the callee's view of the caller's
      *                            data (no storage of its own)
      *   BY REFERENCE (default)   the callee can change the item
      *   BY CONTENT               the callee gets a copy
      *   GOBACK                   return to the caller
      *
      * STRUTIL and DATEUTIL are separately compiled modules in lib/.
      * Their parameter blocks come from copybooks so caller and callee
      * always agree on the layout.  At run time GnuCOBOL finds them
      * through COB_LIBRARY_PATH (the Makefile sets it to build/lib).
      *
      * DOUBLE-IT is a nested program defined at the end of this file.
      *****************************************************************
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       COPY STRUTIL-PARMS.
       COPY DATEUTIL-PARMS.
       01  WS-NUMBER               PIC 9(4)       VALUE 21.

       PROCEDURE DIVISION.
       MAIN-PARA.
           MOVE "UPPER" TO SU-FUNCTION
           MOVE "grace hopper" TO SU-TEXT
           CALL "STRUTIL" USING STRUTIL-PARMS
           DISPLAY "STRUTIL UPPER   : " SU-TEXT(1:SU-LENGTH)

           MOVE "REVERSE" TO SU-FUNCTION
           CALL "STRUTIL" USING STRUTIL-PARMS
           DISPLAY "STRUTIL REVERSE : " SU-TEXT(1:SU-LENGTH)

           MOVE "DOW" TO DU-FUNCTION
           MOVE 19691209 TO DU-DATE-NUM
           CALL "DATEUTIL" USING DATEUTIL-PARMS
           DISPLAY "1969-12-09 was a " DU-RESULT

           MOVE "VALIDATE" TO DU-FUNCTION
           MOVE 20261332 TO DU-DATE-NUM
           CALL "DATEUTIL" USING DATEUTIL-PARMS
           DISPLAY "2026-13-32 is " DU-RESULT " (rc " DU-RC ")"

      *    BY CONTENT: DOUBLE-IT changes its copy, ours stays 21.
           CALL "DOUBLE-IT" USING BY CONTENT WS-NUMBER
           DISPLAY "After BY CONTENT   : " WS-NUMBER
      *    BY REFERENCE: DOUBLE-IT changes our field.
           CALL "DOUBLE-IT" USING BY REFERENCE WS-NUMBER
           DISPLAY "After BY REFERENCE : " WS-NUMBER
           STOP RUN.

      *----------------------------------------------------------------
       IDENTIFICATION DIVISION.
       PROGRAM-ID. DOUBLE-IT.
       DATA DIVISION.
       LINKAGE SECTION.
       01  LK-NUMBER               PIC 9(4).
       PROCEDURE DIVISION USING LK-NUMBER.
           MULTIPLY 2 BY LK-NUMBER
           GOBACK.
       END PROGRAM DOUBLE-IT.

       END PROGRAM SUBPROG.
