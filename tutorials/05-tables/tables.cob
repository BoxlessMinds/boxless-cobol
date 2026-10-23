       IDENTIFICATION DIVISION.
       PROGRAM-ID. TABLES.
      *****************************************************************
      * Lesson 05 - Tables (arrays)
      *
      *   OCCURS n TIMES      repeat an item; subscripts start at 1
      *   INDEXED BY idx      an index, faster than a subscript, and
      *                       needed by SEARCH
      *   SEARCH              linear search from the current index
      *   SEARCH ALL          binary search; needs ASCENDING KEY and
      *                       the data must be in that order
      *
      * A common trick: load constant data with VALUEd FILLERs, then
      * REDEFINE the same storage as a table.
      *****************************************************************
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-PRODUCT-DATA.
      *                                   code name    price 999V99
           05  FILLER  PIC X(17) VALUE "A100Widget  00999".
           05  FILLER  PIC X(17) VALUE "B200Gadget  02450".
           05  FILLER  PIC X(17) VALUE "C300Doohicky00125".
           05  FILLER  PIC X(17) VALUE "D400Gizmo   10000".
       01  WS-PRODUCT-TABLE REDEFINES WS-PRODUCT-DATA.
           05  WS-PRODUCT          OCCURS 4 TIMES
                                   ASCENDING KEY IS WS-PROD-CODE
                                   INDEXED BY PROD-IDX.
               10  WS-PROD-CODE    PIC X(4).
               10  WS-PROD-NAME    PIC X(8).
               10  WS-PROD-PRICE   PIC 9(3)V99.

      * A table filled at run time.
       01  WS-SQUARES.
           05  WS-SQUARE           PIC 9(3) OCCURS 10 TIMES.

       01  WS-SUB                  PIC 99.
       01  WS-TOTAL                PIC 9(5)V99    VALUE 0.
       01  WS-PRICE-OUT            PIC ZZ,ZZ9.99.

       PROCEDURE DIVISION.
       MAIN-PARA.
           DISPLAY "Products:"
           PERFORM VARYING WS-SUB FROM 1 BY 1 UNTIL WS-SUB > 4
               MOVE WS-PROD-PRICE(WS-SUB) TO WS-PRICE-OUT
               DISPLAY "  " WS-PROD-CODE(WS-SUB) " "
                       WS-PROD-NAME(WS-SUB) WS-PRICE-OUT
               ADD WS-PROD-PRICE(WS-SUB) TO WS-TOTAL
           END-PERFORM
           MOVE WS-TOTAL TO WS-PRICE-OUT
           DISPLAY "  Total price      " WS-PRICE-OUT

      *    Linear SEARCH: start at entry 1, test each WHEN in turn.
           SET PROD-IDX TO 1
           SEARCH WS-PRODUCT
               AT END
                   DISPLAY "Gizmo not found"
               WHEN WS-PROD-NAME(PROD-IDX) = "Gizmo"
                   SET WS-SUB TO PROD-IDX
                   DISPLAY "SEARCH found Gizmo at entry " WS-SUB
           END-SEARCH

      *    Binary SEARCH ALL on the ascending key.
           SEARCH ALL WS-PRODUCT
               AT END
                   DISPLAY "C300 not found"
               WHEN WS-PROD-CODE(PROD-IDX) = "C300"
                   MOVE WS-PROD-PRICE(PROD-IDX) TO WS-PRICE-OUT
                   DISPLAY "SEARCH ALL found C300: "
                           WS-PROD-NAME(PROD-IDX) WS-PRICE-OUT
           END-SEARCH

           PERFORM VARYING WS-SUB FROM 1 BY 1 UNTIL WS-SUB > 10
               COMPUTE WS-SQUARE(WS-SUB) = WS-SUB * WS-SUB
           END-PERFORM
           DISPLAY "Squares: " WS-SQUARE(1) " " WS-SQUARE(2) " "
                   WS-SQUARE(3) " ... " WS-SQUARE(10)
           STOP RUN.
