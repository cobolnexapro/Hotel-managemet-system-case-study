     A* DISPLAY FILE : BLDBILL  - BILLING / INVOICE
     A                                      DSPSIZ(24 80 *DS3)
     A                                      PRINT
     A                                      CA03(03 'Exit')
     A                                      CA06(06 'AddLine')
     A                                      CA10(10 'Pay')
     A                                      CA11(11 'Print')
     A                                      CA12(12 'Cancel')
     A          R BLSFL                     SFL
     A            BSEQ           3S  O     4
     A            BTYPE          4A  O     9
     A            BDESC         30A  O    15
     A            BQTY           7S 2O    47
     A            BRATE          9S 2O    56
     A            BAMT          11S 2O    67
     A          R BLCTL                     SFLCTL(BLSFL)
     A                                      SFLSIZ(0014)
     A                                      SFLPAG(0007)
     A                                      OVERLAY
     A   51                                 SFLDSP
     A   52                                 SFLDSPCTL
     A   53                                 SFLCLR
     A   54                                 SFLEND(*MORE)
     A                                  1  4'BLIBILL'
     A                                  1 32'GUEST  FOLIO  /  INVOICE'
     A                                  3  4'Invoice #:'
     A            HINVID         6S  O  3 15
     A                                  3 30'Res #:'
     A            HRESID         6S  B  3 37
     A                                  3 50'Guest:'
     A            HGNAME        22A  O  3 57
     A                                  5  4'Sq'
     A                                  5  9'Type'
     A                                  5 15'Description'
     A                                  5 49'Qty'
     A                                  5 60'Rate'
     A                                  5 73'Amount'
     A                                 15  4'Add line:'
     A                                 16  4'Type'
     A            NTYPE          4A  B 17  4
     A                                 16 11'Description'
     A            NDESC         30A  B 17 11
     A                                 16 43'Qty'
     A            NQTY           7S 2B 17 43
     A                                 16 52'Rate'
     A            NRATE          9S 2B 17 52
     A                                 16 63'GST%'
     A            NGSTP          5S 2B 17 63
     A                                 19 50'Sub Total :'
     A            TSUBT         12S 2O 19 64
     A                                 20 50'GST       :'
     A            TGST          12S 2O 20 64
     A                                 21 50'Grand Tot :'
     A            TTOTAL        12S 2O 21 64
     A                                 19  4'Pay mode:'
     A            PMODE          4A  B 19 14
     A                                 20  4'Amount  :'
     A            PAMT          11S 2B 20 14
     A                                 22  3'F6=AddLine F10=Pay F11=Print F3=Exi
     A            MSGLIN        78A  O 23  2DSPATR(HI)
