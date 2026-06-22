     A* DISPLAY FILE : HRDEMP - EMPLOYEE MAINTENANCE
     A                                      DSPSIZ(24 80 *DS3)
     A                                      PRINT
     A                                      CA03(03 'Exit')
     A                                      CA06(06 'Add')
     A                                      CA05(05 'Refresh')
     A                                      CA12(12 'Cancel')
     A          R HRSFL                     SFL
     A            SEL            1A  B     3
     A            ZEID           6S  O     6
     A            ZENAME        22A  O    14
     A            ZDPT           6A  O    38
     A            ZDESIG        18A  O    46
     A            ZBASIC        11S 2O    66
     A          R HRCTL                     SFLCTL(HRSFL)
     A                                      SFLSIZ(0012)
     A                                      SFLPAG(0010)
     A                                      OVERLAY
     A   51                                 SFLDSP
     A   52                                 SFLDSPCTL
     A   53                                 SFLCLR
     A   54                                 SFLEND(*MORE)
     A                                  1  4'HRIEMP'
     A                                  1 30'EMPLOYEE  MAINTENANCE'
     A                                  3  4'Name filter:'
     A            FNAME         20A  I  3 18
     A                                  5  3'S=Edit'
     A                                  6  3'Op'
     A                                  6  6'EmpID'
     A                                  6 14'Name'
     A                                  6 38'Dept'
     A                                  6 46'Designation'
     A                                  6 70'Basic'
     A                                 22  3'F3=Exit F5=Refresh F6=Add S=Edit F1
     A            MSGLIN        78A  O 23  2DSPATR(HI)
     A          R HRDETL                    OVERLAY
     A                                  1 30'EMPLOYEE  DETAIL'
     A                                  4  6'Emp ID . . . :'
     A            DEID           6S  O  4 22
     A                                  6  6'Name . . . . :'
     A            DENAME        40A  B  6 22DSPATR(UL)
     A                                  7  6'Dept code  . :'
     A            DDPT           6A  B  7 22
     A                                  8  6'Designation :'
     A            DDESIG        30A  B  8 22
     A                                  9  6'Basic Rs . . :'
     A            DBASIC        11S 2B  9 22
     A                                 10  6'HRA   Rs . . :'
     A            DHRA          11S 2B 10 22
     A                                 11  6'Deduct Rs  . :'
     A            DDED          11S 2B 11 22
     A                                 12  6'Phone  . . . :'
     A            DPHONE        15A  B 12 22
     A                                 22  6'F12=Cancel  Enter=Save'
     A            DMSG          78A  O 23  2DSPATR(HI)
