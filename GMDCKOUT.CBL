     A* DISPLAY FILE : GMDCKOUT - CHECK-OUT
     A                                      DSPSIZ(24 80 *DS3)
     A                                      PRINT
     A                                      CA03(03 'Exit')
     A                                      CA05(05 'Refresh')
     A                                      CA12(12 'Cancel')
     A          R COSFL                     SFL
     A            SEL            1A  B     3
     A            ZRESID         6S  O     6
     A            ZNAME         24A  O    14
     A            ZROOM          5A  O    40
     A            ZTOTAL        11S 2O    47
     A            ZPAID         11S 2O    60
     A          R COCTL                     SFLCTL(COSFL)
     A                                      SFLSIZ(0012)
     A                                      SFLPAG(0010)
     A                                      OVERLAY
     A   51                                 SFLDSP
     A   52                                 SFLDSPCTL
     A   53                                 SFLCLR
     A   54                                 SFLEND(*MORE)
     A                                  1  4'GMICKOUT'
     A                                  1 32'GUEST  CHECK-OUT'
     A                                  3  3'Sel: O=Check-Out (folio must be ful
     A                                  5  3'Op'
     A                                  5  6'ResID'
     A                                  5 14'Guest'
     A                                  5 40'Room'
     A                                  5 49'Total'
     A                                  5 62'Paid'
     A                                 22  3'F3=Exit F5=Refresh F12=Cancel'
     A            MSGLIN        78A  O 23  2DSPATR(HI)
