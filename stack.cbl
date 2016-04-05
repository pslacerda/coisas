       IDENTIFICATION                  DIVISION.
       PROGRAM-ID. STACK.
       DATA                            DIVISION.
       WORKING-STORAGE                 SECTION.
       77 CblStackTopIdx   PIC 99 VALUE 1.
       77 CblStackPrintIdx PIC 99.
       77 CblStackItem     PIC X(32).
       77 CblStackProcPtr  USAGE PROCEDURE-POINTER.

       01 CblStack.
           02 CblStackItems OCCURS 100 TIMES.
               03 CblStackPerformItem PIC X(32).


       PROCEDURE                       DIVISION.
       Main                            SECTION.
           MOVE "Main" TO CblStackItem
           PERFORM PerformBegin
       
           PERFORM Perform1
       
           PERFORM PerformEnd
           PERFORM PrintStack
           STOP RUN
           .

       Perform1                        SECTION.
           MOVE "Perform1" TO CblStackItem
           PERFORM PerformBegin

           DISPLAY "P1"
           PERFORM Perform2

           PERFORM PerformEnd
           .

       Perform2                        SECTION.
           MOVE "Perform2" TO CblStackItem
           PERFORM PerformBegin

           DISPLAY "P2"
           PERFORM Perform3
           PERFORM Perform4

           PERFORM PerformEnd
           .

       Perform3                        SECTION.
           MOVE "Perform3" TO CblStackItem
           PERFORM PerformBegin

           DISPLAY "P3"

           PERFORM PerformEnd
           .

       Perform4                        SECTION.
           MOVE "Perform4" TO CblStackItem
           PERFORM PerformBegin

           DISPLAY "P4"

           PERFORM PrintStack
           PERFORM PerformEnd
           .

       PerformBegin                    SECTION.
           MOVE CblStackitem TO CblStackItems(CblStackTopIdx)
           ADD 1 TO CblStackTopIdx
           .

       PerformEnd                      SECTION.
           SUBTRACT 1 FROM CblStackTopIdx
           .

       PrintStack                      SECTION.
           DISPLAY '---------- BEGIN PERFORM STACK TRACE ---------'
           PERFORM VARYING CblStackPrintIdx FROM CblStackTopIdx BY -1
                                            UNTIL CblStackPrintIdx = 0
               DISPLAY CblStackItems(CblStackPrintIdx)
           END-PERFORM
           DISPLAY '---------- END PERFORM STACK TRACE ---------'
           .
