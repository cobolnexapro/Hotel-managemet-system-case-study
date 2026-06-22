     A* DISPLAY FILE : RPDMENU - REPORTS MENU
     A                                      DSPSIZ(24 80 *DS3)
     A                                      PRINT
     A                                      CA03(03 'Exit')
     A          R RPTMENU
     A                                  1  4'TEHMS'
     A                                  1 33'REPORTS  SUITE'
     A            WUSER         40A  O  2  4
     A                                  6 12'1. Occupancy & Revenue'
     A                                  7 12'2. Revenue Summary'
     A                                  8 12'3. Inventory Valuation'
     A                                  9 12'4. Trial Balance (GL)'
     A                                 10 12'5. Payroll Register'
     A                                 12 12'90. Return to Main Menu'
     A                                 18  4'Selection . . :'
     A            OPTION         2A  I 18 20
     A                                 22  4'F3=Exit'
     A            MSGLIN        78A  O 23  2DSPATR(HI)
