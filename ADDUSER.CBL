     A* DISPLAY FILE : ADDUSER - USER ADMINISTRATION
     A                                      DSPSIZ(24 80 *DS3)
     A                                      PRINT
     A                                      CA03(03 'Exit')
     A                                      CA06(06 'Add')
     A                                      CA05(05 'Refresh')
     A                                      CA12(12 'Cancel')
     A          R USSFL                     SFL
     A            SEL            1A  B     3
     A            ZUID          10A  O     6
     A            ZUNAME        30A  O    18
     A            ZUROLE        10A  O    50
     A            ZUSTS          1A  O    63
     A          R USCTL                     SFLCTL(USSFL)
     A                                      SFLSIZ(0012)
     A                                      SFLPAG(0010)
     A                                      OVERLAY
     A   51                                 SFLDSP
     A   52                                 SFLDSPCTL
     A   53                                 SFLCLR
     A   54                                 SFLEND(*MORE)
     A                                  1  4'ADIUSER'
     A                                  1 32'USER  ADMINISTRATION'
     A                                  3  3'Sel: R=Reset Pwd  L=Lock  U=Unlock'
     A                                  5  3'Op'
     A                                  5  6'User'
     A                                  5 18'Name'
     A                                  5 50'Role'
     A                                  5 63'St'
     A                                 22  3'F3=Exit F5=Refresh F6=Add F12=Cance
     A            MSGLIN        78A  O 23  2DSPATR(HI)
     A          R USDETL                    OVERLAY
     A                                  1 32'NEW  USER'
     A                                  5  6'User ID  . . :'
     A            DUID          10A  B  5 22DSPATR(UL)
     A                                  6  6'Name . . . . :'
     A            DUNAME        40A  B  6 22
     A                                  7  6'Role (ADMIN/'
     A                                  8  6'MANAGER/'
     A                                  9  6'FRONTDESK) . :'
     A            DUROLE        10A  B  9 22
     A                                 11  4'Password blank => set on first sign
     A                                 22  6'F12=Cancel  Enter=Save'
     A            DMSG          78A  O 23  2DSPATR(HI)
