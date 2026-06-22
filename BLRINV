     A* PRINTER FILE : BLRINV  - TAX INVOICE
     A                                      REF(TEHMSDTA/BLPINVHD)
     A          R RHEAD                     SKIPB(01)
     A                                  1 28'TAJ HOTEL MUMBAI'
     A                                  2 30'TAX  INVOICE'
     A                                  3 20'GSTIN: 27AAAAA0000A1Z5'
     A                                  5  4'Invoice No :'
     A            PINVID         6S  O  5 17
     A                                  5 50'Date:'
     A            PDATE         10A  O  5 56
     A                                  6  4'Guest      :'
     A            PGNAME        40A  O  6 17
     A                                  7  4'Room       :'
     A            PROOM          6A  O  7 17
     A                                  9  4'Type'
     A                                  9 12'Description'
     A                                  9 50'Qty'
     A                                  9 58'Rate'
     A                                  9 70'Amount'
     A          R RDETL                     SPACEB(01)
     A            DTYPE          4A  O     4
     A            DDESC         34A  O    12
     A            DQTY           7S 2O    48
     A            DRATE          9S 2O    57
     A            DAMT          11S 2O    68
     A          R RTOT                      SPACEB(02)
     A                                    50'Sub Total :'
     A            TSUBT         12S 2O    68
     A          R RTOT2                     SPACEB(01)
     A                                    50'Discount  :'
     A            TDISC         12S 2O    68
     A          R RTOT3                     SPACEB(01)
     A                                    50'GST       :'
     A            TGST          12S 2O    68
     A          R RTOT4                     SPACEB(01)
     A                                    50'GRAND TOT :'
     A            TTOTAL        12S 2O    68
     A          R RFOOT                     SPACEB(03)
     A                                    20'Thank you for staying at Taj Hotel
