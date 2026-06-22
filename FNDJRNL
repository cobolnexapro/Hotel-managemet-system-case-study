     A* DISPLAY FILE : FNDJRNL - GL JOURNAL ENTRY
     A                                      DSPSIZ(24 80 *DS3)
     A                                      PRINT
     A                                      CA03(03 'Exit')
     A                                      CA06(06 'AddLine')
     A                                      CA10(10 'Post')
     A                                      CA12(12 'Cancel')
     A          R FJSFL                     SFL
     A            ZSEQ           3S  O     4
     A            ZACC           8A  O     9
     A            ZACCN         20A  O    19
     A            ZDR           13S 2O    41
     A            ZCR           13S 2O    56
     A          R FJCTL                     SFLCTL(FJSFL)
     A                                      SFLSIZ(0010)
     A                                      SFLPAG(0006)
     A                                      OVERLAY
     A   51                                 SFLDSP
     A   52                                 SFLDSPCTL
     A   53                                 SFLCLR
     A   54                                 SFLEND(*MORE)
     A                                  1  4'FNIJRNL'
     A                                  1 30'GL  JOURNAL  ENTRY'
     A                                  3  4'Journal #:'
     A            HJID           6S  O  3 15
     A                                  3 28'Desc:'
     A            HDESC         40A  B  3 34
     A                                  5  4'Sq'
     A                                  5  9'Account'
     A                                  5 19'Name'
     A                                  5 46'Debit'
     A                                  5 61'Credit'
     A                                 15  4'Add line:'
     A                                 16  4'Acct'
     A            NACC           8A  B 17  4
     A                                 16 14'Debit'
     A            NDR           13S 2B 17 14
     A                                 16 30'Credit'
     A            NCR           13S 2B 17 30
     A                                 16 46'Memo'
     A            NMEMO         30A  B 17 46
     A                                 19 46'Tot Debit :'
     A            TDR           15S 2O 19 60
     A                                 20 46'Tot Credit:'
     A            TCR           15S 2O 20 60
     A                                 21 46'Balance   :'
     A            TBAL          15S 2O 21 60
     A                                 22  3'F6=AddLine F10=Post F3=Exit F12=Can
     A            MSGLIN        78A  O 23  2DSPATR(HI)
