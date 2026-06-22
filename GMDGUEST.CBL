     A* DISPLAY FILE : GMDGUEST - GUEST PROFILE MAINTENANCE
     A                                      DSPSIZ(24 80 *DS3)
     A                                      PRINT
     A                                      CA03(03 'Exit')
     A                                      CA06(06 'Add')
     A                                      CA05(05 'Refresh')
     A                                      CA12(12 'Cancel')
     A          R GMSFL                     SFL
     A            SEL            1A  B     3
     A            ZGID           7S  O     6
     A            ZNAME         30A  O    15
     A            ZCITY         16A  O    47
     A            ZPHONE        13A  O    65
     A          R GMCTL                     SFLCTL(GMSFL)
     A                                      SFLSIZ(0012)
     A                                      SFLPAG(0010)
     A                                      OVERLAY
     A   51                                 SFLDSP
     A   52                                 SFLDSPCTL
     A   53                                 SFLCLR
     A   54                                 SFLEND(*MORE)
     A                                  1  4'GMIGUEST'
     A                                  1 30'GUEST  PROFILE  MAINTENANCE'
     A                                  3  4'Name filter:'
     A            FNAME         20A  I  3 18
     A                                  5  3'S=Edit'
     A                                  6  3'Op'
     A                                  6  6'GuestID'
     A                                  6 15'Name'
     A                                  6 47'City'
     A                                  6 65'Phone'
     A                                 22  3'F3=Exit F5=Refresh F6=Add S=Edit F1
     A            MSGLIN        78A  O 23  2DSPATR(HI)
     A          R GMDETL                    OVERLAY
     A                                  1 30'GUEST  DETAIL'
     A                                  4  6'Guest ID . . :'
     A            DGID           7S  O  4 22
     A                                  6  6'Name . . . . :'
     A            DNAME         40A  B  6 22DSPATR(UL)
     A                                  7  6'Address  . . :'
     A            DADDR         40A  B  7 22
     A                                  8  6'City . . . . :'
     A            DCITY         30A  B  8 22
     A                                  9  6'Nationality :'
     A            DNAT          20A  B  9 22
     A                                 10  6'Phone  . . . :'
     A            DPHONE        15A  B 10 22
     A                                 11  6'Email  . . . :'
     A            DEMAIL        40A  B 11 22
     A                                 12  6'VIP (Y/N)  . :'
     A            DVIP           1A  B 12 22
     A                                 22  6'F12=Cancel  Enter=Save'
     A            DMSG          78A  O 23  2DSPATR(HI)
