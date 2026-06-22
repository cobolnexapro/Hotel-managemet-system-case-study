     A* DISPLAY FILE : RSDRESV  - RESERVATION MAINTENANCE
     A                                      DSPSIZ(24 80 *DS3)
     A                                      PRINT
     A                                      CA03(03 'Exit')
     A                                      CA06(06 'Add')
     A                                      CA05(05 'Refresh')
     A                                      CA12(12 'Cancel')
     A                                      CA13(13 'CheckIn')
     A          R RSSFL                     SFL
     A            SEL            1A  B     3
     A            ZRESID         6S  O     6
     A            ZNAME         22A  O    14
     A            ZCAT           6A  O    38
     A            ZROOM          6A  O    46
     A            ZFRDT         10A  O    54
     A            ZTODT         10A  O    65
     A            ZSTS           1A  O    77
     A          R RSCTL                     SFLCTL(RSSFL)
     A                                      SFLSIZ(0012)
     A                                      SFLPAG(0010)
     A                                      OVERLAY
     A   51                                 SFLDSP
     A   52                                 SFLDSPCTL
     A   53                                 SFLCLR
     A   54                                 SFLEND(*MORE)
     A                                  1  4'RSIRESV'
     A                                  1 28'RESERVATION  MAINTENANCE'
     A                                  3  4'Filter status (R/C/O/X/blank):'
     A            FSTS           1A  I  3 36
     A                                  5  3'S=Select'
     A                                  6  3'Op'
     A                                  6  6'ResID'
     A                                  6 14'Guest Name'
     A                                  6 38'Cat'
     A                                  6 46'Room'
     A                                  6 54'From'
     A                                  6 65'To'
     A                                  6 77'St'
     A                                 22  3'F3=Exit F5=Refresh F6=Add F13=Check
     A            MSGLIN        78A  O 23  2DSPATR(HI)
     A          R RSDETL                    OVERLAY
     A                                  1 28'NEW / EDIT  RESERVATION'
     A                                  4  6'Reservation #:'
     A            DRESID         6S  O  4 22
     A                                  6  6'Guest ID . . :'
     A            DGSTID         7S  B  6 22
     A                                  7  6'Guest Name . :'
     A            DGNAME        30A  O  7 22
     A                                  9  6'Category . . :'
     A            DCAT           6A  B  9 22DSPATR(UL)
     A                                 10  6'From (DDMMYY):'
     A            DFRDT          6A  B 10 22
     A                                 11  6'To   (DDMMYY):'
     A            DTODT          6A  B 11 22
     A                                 12  6'Pax  . . . . :'
     A            DPAX           2S  B 12 22
     A                                 13  6'Type (WI/OB/'
     A                                 14  6'AB/CB/GB)  . :'
     A            DTYPE          2A  B 14 22
     A                                 15  6'Advance Rs . :'
     A            DADV           9S 2B 15 22
     A                                 22  6'F12=Cancel   Enter=Save'
     A            DMSG          78A  O 23  2DSPATR(HI)
