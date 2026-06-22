     A* DISPLAY FILE : RMDROOM - ROOM & HOUSEKEEPING
     A                                      DSPSIZ(24 80 *DS3)
     A                                      PRINT
     A                                      CA03(03 'Exit')
     A                                      CA05(05 'Refresh')
     A                                      CA12(12 'Cancel')
     A          R RMSFL                     SFL
     A            SEL            1A  B     3
     A            ZRNO           6A  O     7
     A            ZCAT           6A  O    16
     A            ZFLR           3S  O    26
     A            ZSTS           1A  O    35
     A            ZSTSD         12A  O    40
     A            ZCLN           1A  O    57
     A            ZCLND         12A  O    62
     A          R RMCTL                     SFLCTL(RMSFL)
     A                                      SFLSIZ(0012)
     A                                      SFLPAG(0010)
     A                                      OVERLAY
     A   51                                 SFLDSP
     A   52                                 SFLDSPCTL
     A   53                                 SFLCLR
     A   54                                 SFLEND(*MORE)
     A                                  1  4'RMIROOM'
     A                                  1 30'ROOM  &  HOUSEKEEPING'
     A                                  3  3'Sel: V=Vacant O=Occupied B=Block M=
     A                                  5  3'Op'
     A                                  5  7'Room'
     A                                  5 16'Cat'
     A                                  5 25'Flr'
     A                                  5 35'Status'
     A                                  5 57'Cleaning'
     A                                 22  3'F3=Exit F5=Refresh F12=Cancel'
     A            MSGLIN        78A  O 23  2DSPATR(HI)
