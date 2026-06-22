     A* DISPLAY FILE : CMDMAIN  - MAIN MENU
     A                                      DSPSIZ(24 80 *DS3)
     A                                      PRINT
     A                                      CA03(03 'Exit')
     A          R MAINMENU
     A                                  1  4'TEHMS'
     A                                  1 31'TAJ HOTEL MUMBAI'
     A                                  1 66'MAIN MENU'
     A            WUSER         40A  O  2  4
     A                                  5 10'1. Reservations'
     A                                  6 10'2. Guest Check-In / Check-Out'
     A                                  7 10'3. Room Status'
     A                                  8 10'4. Billing / Invoice'
     A                                  9 10'5. Housekeeping'
     A                                 10 10'6. Reports'
     A                                 11 10'7. Administration'
     A                                 13 10'90. Sign Off'
     A                                 20  4'Selection . . :'
     A            OPTION         2A  I 20 20
     A                                 22  4'F3=Exit'
     A            MSGLIN        78A  O 23  2DSPATR(HI)
