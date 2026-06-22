     A* DISPLAY FILE : IVDITEM - INVENTORY
     A                                      DSPSIZ(24 80 *DS3)
     A                                      PRINT
     A                                      CA03(03 'Exit')
     A                                      CA06(06 'Add')
     A                                      CA05(05 'Refresh')
     A                                      CA12(12 'Cancel')
     A          R IVSFL                     SFL
     A            SEL            1A  B     3
     A            ZITEM         10A  O     6
     A            ZIDESC        26A  O    18
     A            ZUOM           4A  O    46
     A            ZQTY          11S 3O    51
     A            ZADJ           9S 3B    64
     A          R IVCTL                     SFLCTL(IVSFL)
     A                                      SFLSIZ(0012)
     A                                      SFLPAG(0010)
     A                                      OVERLAY
     A   51                                 SFLDSP
     A   52                                 SFLDSPCTL
     A   53                                 SFLCLR
     A   54                                 SFLEND(*MORE)
     A                                  1  4'IVIITEM'
     A                                  1 32'INVENTORY  CONTROL'
     A                                  3  3'Sel + Adj qty:  R=Receive  I=Issue'
     A                                  5  3'Op'
     A                                  5  6'Item'
     A                                  5 18'Description'
     A                                  5 46'UOM'
     A                                  5 53'OnHand'
     A                                  5 66'Adj'
     A                                 16  4'Add item:'
     A                                 17  4'Code'
     A            NITEM         10A  B 18  4
     A                                 17 16'Description'
     A            NDESC         30A  B 18 16
     A                                 17 48'UOM'
     A            NUOM           4A  B 18 48
     A                                 17 54'Rate'
     A            NRATE          9S 2B 18 54
     A                                 22  3'F3=Exit F5=Refresh F6=AddItem F12=C
     A            MSGLIN        78A  O 23  2DSPATR(HI)
