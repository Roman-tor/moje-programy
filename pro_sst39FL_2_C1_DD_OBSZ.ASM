; ZAPIS FLASH SST39SFxxx /128kB do 512kB/ umieszczonej w plytce FLASH V2!
; FD E1..E3..E5..E9 zajete jako instrukcje Z80 ! wolne E2, E4, E6, E7, E8
HILO:      EQU 23bh      ;  w MONITORze CA80
PRINT:     EQU 01D4h     ; wysw. komunikatu /CA80/ wg (HL), koniec FF
PARAM:     EQU 01F4h     ; pobiera bajty do hl, podac PWYS
EXPR:      EQU 0213h     ; pobranie liczb szesnastkowych na stos
LADR:      EQU 20h       ; LADR - wyswietlenie rej. HL w postaci HEX
LBYTE:     EQU 18h       ; LBYTE - wyswietlenie rej. A w postaci HEX
KO3:       EQU 0A23h     ; "Error" z CA80
ERR:       EQU 0A23h     ; tekst "Err" ca80
CLR:       EQU 10h       ; CLR - kasowanie wyswietlacza
CLR1:      EQU 11h       ; CLR1 - kasowanie wyswietlacza bez zmiany PWYS
TI:        EQU 7         ; TI - pobranie znaku z echem na CA80
TI1:       EQU 8         ; j.w. lecz bez ustawiania PWYSW
PWYS:      EQU 0FFF6h    ; PWYS
;USPWYS:    EQU 28h       ; ustawienie paramet. wyswietlania
clr_buf:   EQU 0CA0h     ; zerowanie bufora z kalkulatora CA80
CO:        EQU 01E0h     ; wyswietlenie cyfry szesnastkowej umieszczonej w rej. C w/g PWYS
CSTS:      EQU 0FFC3h    ; czy klaw. wcisniety ?
CI:        EQU 0FFC6h    ; czekanie na puszczenie klawisza a potem na wcisniec
;NMIU:      EQU 0FFCCh    ; obsluga przerwania niemaskowalnego uzytkownika
CIM:       EQU 184H      ; jak CSTS
PLEW:      EQU 0C56h     ; przesuniecie bufora w lewo o 1/CA88
CYF0:      EQU 0FFF7h    ; wysw. cyfry na pozycji 0 wyswietlacza CA80
CYF1:      EQU 0FFF8h    ; wysw. cyfry na pozycji 1
CYF2:      EQU 0FFF9h
CYF3:      EQU 0FFFAh
CYF4:      EQU 0FFFBh
CYF5:      EQU 0FFFCh
CYF6:      EQU 0FFFDh
CYF7:      EQU 0FFFEh
TSIED:     EQU 0318h     ; tabl. zawieraj. kody 7-segm. cyfr szesnast.dla potrzeb wyswietl.
adr5:      EQU 7555h     ; konfiguracja dla SST39FSxxx  /by ZEGAR Flash/
adrA:      EQU 7AAAh     ; konfiguracja j.w.
FL:        EQU 6000h     ; adres pamieci FLASH na plytce  j.w.
BUFOR:     EQU 5000h     ; poczatek bufora w RAM
SEKT:      EQU BUFOR+0FFDh; numer sektora - ustawiany przez (LS373), chodzi o najstarsza cyfre 5
DL_SEKT:   EQU 0FFFh     ; dlugosc sektora 4 kB - koniec na FFFh
PR_CA:     EQU 0FE30h    ; tu beda zapisywane odczytane numery programow / 1,2 ...itd/ - na 144 programow
FL_DANE:   EQU 0FEC0h    ; tu adres zapisu do FLASH SST 39xxx   ; moze byc np. 5abc
nr_sekt:   EQU FL_DANE-1 ; FEBF
sekt_FL:   EQU FL_DANE-2 ; nr sekt. podczas szuk. dlug. programu - FEBE
SEKT_P:    EQU FL_DANE+4 ; tu aktualny nr sektora - FEC4
r_od:      EQU FL_DANE+5 ; pocz. programu w CA - FED5-FEC6
dl_zap:    EQU r_od+2    ; dlugosc zapisu - ile bajtow - FEC7-FEC8
r_do:      EQU r_od+4    ; koniec programu w CA - FEC9-FECA
buf_adr:   EQU dl_zap+6  ; 5. bajtow w RAM CA80 na adres FLASH -> FECC
p_pr_FL:   EQU dl_zap+11 ; FED2 -pocz. prog. w pam. FLASH podczas zap. nr programu
su_CA:     EQU p_pr_FL+2 ; przechowanie sumy kontrolnej programu z CA
mar_PR:    EQU 0FDE4h    ; marker pocz. programu FD E4
mar_NAZ:   EQU 0DDE2h    ; marker pocz. nazwy DD E2, moze byc inny, np. FD E4
  ; LCD
L1:        EQU 80h       ; pocz. 1. linii LCD
L2:        EQU 0C0h      ; pocz. 2. linii
L3:        EQU 94h       ; pocz. 3. linii
L4:        EQU 0D4h      ; pocz. 4. linii
ile_cyf:   EQU 0FEFCh    ; ile cyfr wywietlac na CA80
poz_wys:   EQU ile_cyf+1 ; 0FEFDh
poz_cyf:   EQU ile_cyf+2 ; 0FEFEh ; tu akt. pozycja CYF /od FFF7 do max FFFE /
nr_L:      EQU 0FEEAh    ; tu aktualnie wyswiet. nr linii
pr_ile:    EQU 0FE1Bh    ; ilosc znalezionych programow
nr_pr:     EQU pr_ile+1   ; tu nr programu podczas szukania
instr:     EQU 0E8h      ; INSTRUKCJA LCD
DANA:      EQU 0E9h      ; DANA
LCD_RDR    EQU 0EBh      ; odczyt pozycji kursora
LCD_BUSY   EQU 0EAh      ; odczyt
  ;===
  ; ; format pliku z nr i nazwama programu w pamieci EEPROM/FLASH /przyklad/:
  ; FD E4 pocz. programu
  ; 01 - nr programu
  ; 00 C0 ; dwa bajty - pocz. programu w RAM CA80 - tu od C000h
  ; 31 66 FF.. .. ..  - nasz program
  ; wewnatrz programu nazwa, po DD E2
  ; FD E4 marker konca i pocz. nastepnego prog.
  ; 02 .....program nr 2
  ; 00 D0  ; pocz. programu w CA80 - od D000h
  ; 21 11 22 .. .. ..  program
  ; FD E4 nastepny prog.
  ; 03 ..... itd
  ;
  ; FD E4 FF  - koniec obszaru z numerami, nazwami programow
  ; V. ..DD_1 - zmiana: SEKT_P tylko przy zlec. 7
  ; ...3 lipca dodalem FLASH 2 z mozliwoscia zapisu OBSZARu
  ; E1 .. zmiana JR Z, xx  .. JR linia 1097

 ORG 0C000h  ; program testujacy dla pracy krokowej - MIK 05 str. 187
 zap_FL:
  ld sp, 0FF66h
  ld HL,obs_przer  ; wlaczenie obslugi "F1" w NMI - dolny lewy
  ld (CI+1),HL
EEP_1:
  rst 10h
  defb 80h ; po powrocie, gdy wcis. klaw F1/Z/ , czysc wysw. CA
  ld hl, flash2
  call print ; "FlaSh_2" na CA
  defb 71h
  call ini_LCD
  call wpis_PLD ; duze polskie znaki diakrytyczne
  call wysw_kom_1
  call TI ; pobierz nr zlec.
  defb 17h
  ld E,A             ; nr zlecenia
  cp LCTX            ; czy "legalne"
  jp nc,EREE ; nielegalne
  rst CLR
  defb 70H
  ld HL,CTBLX        ;tablica rozejsc
  ld D,0             ;w E numer zlecenia
  add HL,DE
  add HL,DE
  ld E,(HL)
  inc HL
  ld D,(HL)
  ex DE,HL
  jp (HL)            ;Pseudo CALL

  EREE:
  rst CLR
  defb 80H
  ld HL,ERR ; "ERROR" na CA
  call PRINT
  defb 53H
  call op_100ms
  defb 9
  rst 10h
  defb 53h
  jr zap_FL

CTBLX:
      DEFW Z0 ; kasowanie CALEJ pamieci FLASH /lub sektora/ - przygotowanie do zapisu programow
      DEFW Z1 ; szukaj pierwszy wolny nr programu
      DEFW Z2 ; przeglad FLASH
      DEFW Z3 ; suma kontrolna FLASH, od 0 do konca programow FD E4 FF
      DEFW Z4 ; Zapisz RAM [od][.][do][.][od_flash] do FLASH lub zapis programu
      DEFW Z5 ; szukanie programu/nazwy, przepisanie programu [NR_prog] do CA
      DEFW Z6 ; przepisz FLASH do RAM
      DEFW Z7 ; dlugosc programu, adresy w pam. FLASH, CA
      DEFW ini_FL ; inicjacja FLASH - wpis od 0000 FD E4 FF
LCTX:  EQU ($-CTBLX)/2 ; ilosc programow/zlecen

OBS_PRZER: ; obsluga, gdy wcisniemy klawisz F1 - powrot na pocz. programu
  call CIM   ;jak CD F3 FF
  push AF
  cp 17H     ; kod klaw. "F1"
  jp z, EEP_1
  pop AF
  ret
Z0:
ERASE: ; kasowanie CALEJ pamieci SST39EExxx "FF" 128 -512 kB
   ld a, 1               ;lub sektora /4 kB/
   out (instr), A
   call busy
   ld a, L4
   out (instr), A
   ld hl, erase_FL ;  "KASOWAC FLASH ?"
   call wys_tekst
   call busy
   ld hl, klaw_C ; "KLAW. C CALA PAMIEC"
   call wys_tekst
   ld hl, klaw_2 ; "KLAW. 2 SEKT nr 0-7F",
   call wys_tekst
   call op_100ms
   defb 7 ; opozn. ok. 0,7 sek
 er12:
   ld a, 8 ; wylacz LCD
   out (instr), a
   call op_100ms
   defb 7 ; opozn. ok. 0,7 sek
   ld a, 0Ch
   out (instr), A
   call op_100ms
   defb 7
   call CSTS ;  wcis. klaw.
   cp 2  ; czy klaw. 2 - kasuj tylko jeden sektor
   jr z, wyb_sekt
   cp 0Ch ; czy klaw. C
   jr nz, er12
   ;jr er12

 er13:
   ld a, L3 ; linia 3.
   ld b, 20  ; wszystkie znaki
   call CLR_LCD_ZN ;
   ld HL, klaw_C1
   call wys_tekst
 er131:
   call CSTS
   cp 10h ; " G " ; powrot do Z0
   jr z, Z0
   cp 0Eh ; " E " ? - kasuj cala pamiec
   jr nz, er131
   ;jr er131
 er132:
   call er11 ; kasuj cala pamiec
   ld hl, er_ok ; "ERASE OK"  po skasowaniu
   call print
   defb 80h
   rst 8 ; CF
   jp zap_FL
    ; KASOWANIE CALEJ PAMIECI !!!
 er11:
  ld hl, adr5  ; HL - 7555h
  ld de, adrA  ; DE - 7AAAh
  ld a, 55h
  ld (hl), E       ; 1 cykl pod 7555 dana AA
  ld (de), a       ; 2 cykl pod 7AAA ->   55
  ld (hl), 80h     ; 3 cykl pod 7555 ->   80
  ld (hl), 0AAh    ; 4 cykl po  7555 =>   AA
  ld (de), a       ; 5 cykl pod 7AAA ->   55
  ld (hl), 10h     ; 6 cykl pod 7555 ->   10
  ld b, 11  ; nota katalog. Tsce max 20ms
 er2:
  halt ; 2 ms
  djnz er2
  ret
         ; wcisnisnieto klaw. 2 - kasowanie jednego sektora
wyb_sekt: ; sektora FLASH 0-7F
  ld a, L1
  ld b, 20 ; tyle znakow skasowac na LCD
  call CLR_LCD_ZN
  halt
 wyb1A:
  rst 10h
  defb 80h
  ld HL, nr_sect ;"nr.SEct" na CA
  call print
  defb 62h
  ld a, L1
  out (INSTR), A
  ld hl, sekt_wyb  ; "podaj nr sektora" na LCD
  call wys_tekst
  ld c, 1 ; jeden parametr
  call EXPR ; pobierz na stos
  defb 20h
  pop bc ; C nr sektora
  ld a, c
  cp 80h ; sektory 0 - 7F !!!
  jr nc, wyb1A
  push AF ; przechowaj
  call kas_sekt
  ld HL, er_ok  ; "ERASE OK" na CA80
  call print
  defb 80h
  rst 8 ; CF
  pop AF
  rst LBYTE ; wysw. rej. A
  defb 20h
  rst 8 ; CF
  jp WYB1A

kas_sekt:
  ld (sekt), A ; ustaw sektor - LS373 ! kasowanie 4 kB !
  push AF
  EXX ; chron rejestry
  ld A, 55h
  ld HL, adr5    ; adres
  ld DE, adrA    ; adres
  ld (HL),0AAh   ; 1. cykl - dana AA pod adres 7555
  ld (DE), A     ; 2. cykl - dana 55 -> 7AAA
  ld (HL), 80H   ; 3. cykl -dana 80 -> 7555
  ld (HL), 0AAh  ; 4. cykl -dana AA -> 7555
  ld (DE), A     ; 5. cykl -dana 55 -> 7AAA
  ld H, 60H      ; dowolny - A18..A12 w LS373- nota katalogowa
  ld (HL), 30H   ; 6. cykl -dana 30 -> 6055
  ld B,0FH       ; op. ok. 32 ms
 op3:
  halt           ; 2 ms
  djnz  op3      ; max 25 ms
  EXX
  pop AF ; do wyswietlenia na CA
  ret
;==
Z1:    ; szukaj pierwszy wolny numer programu
  call CLR_OB
  call szuk_numer ; znajdz numery progr. i wpisz do RAM CA80
  ; sprawdz, ktory pierwszy wolny
nr_free: ; ktory numer programu jest wolny oraz ile programow znaleziono
   ld e, 1 ; zaczynamy od 1/, moze byc 0
 nr0:
   ld a, e ; szukamy tego numeru od <PR_CA> FC-FC64
   ld HL, pr_ca ; pocz. szukania
   ld bc, 64h ; koniec obszaru, numery prog. 1 do 99, FD, FE, FF to markery
   cpir ; porownuje (HL) z A, HL+1, BC-1
   jp po, nr2
   ld a, e
   inc a
   daa  ; tu ograniczamy numery programów do liczb dziesietnych 1-99
   ld e, a    ; jeœli chcesz wiêcej, wykreœl DAA
   jr nr0
 nr2:  ; znaleziono nr nieuzywany - pierwszy wolny
   push af ; dla CA
   push af ; dla LCD
   ld a, L4
   out (INSTR), a
   ld HL, nr_1WOL; tekst na LCD "pierwszy wolny nr " <rej.A>
   call wys_tekst ; bez INC (IX) = przeskok na nastepna linie
   pop af
   call wysw_A ; na LCD
 nr21:
   pop af
   ld E, A ; zapamietanie do porownania
   rst LBYTE ; wysw. rej. A PWYS 20  wolny numer
   defb 20h
   ld HL, nr_fr ; nrFree
   call print
   defb 62h
   ld A, 0Fh ; kursor jako mrugajacy blok, dla zwrocenia uwagi
   out (INSTR), A
   halt
   ld A, L4+17
   out (INSTR), A
   rst 8 ; CF czekaj na klawisz
   ld a, 0Eh ; kurosor jako belka
   out (INSTR), A
   jp EEP_1

Z2:  ; przeglad FLASH  SST39SFxxx
  ld a, 1
  out (instr), A ; czysc LCD  ; D7 80
  call busy
  ld a, L4
  out (instr), A
  ld hl, przeg
  call wys_tekst
 P21:
  rst 10h ; D7 czysc wysw. CA
  defb 40h
  call zap_FL39_od ; pobranie adr. /i kontrola/ pocz. przegladania
  jr nc, P21 ; adres FL prawidlowy /dla 512 kB -max to 7.FFFF
  ;jr P21                       ; dla 128 kB - 1.FFFF, 256 kB - 3.FFFF
  ; adres OK
 P22:
  ld hl, (buf_adr+2)
  PUSH  HL
  POP   IX  ; potrzebne do <SET_SEKT>
  LD    (FL_DANE),HL   ; przechowanie
  CALL  SET_SEKT       ; ustaw sektor na podstawie adresu, adres moze byc 5. cyfrowy
  PUSH IX
  POP HL
  rst 10h ; D7 czysc wysw. CA - CYF2
  defb 12h
  jr PU0

 P22a: ;przy "cofaniu", przekracznie 0000 na FFFF - ustawienie adresu
  ld a, L
  cp 0FFh
  jr nz, PU0
  ld a, H
  cp 5Fh
  jr nz, PU0
  ld H, 6Fh
  ld a, (sekt_P)
  ;ld A, (SEKT)
  dec a
  cp 0FFh
  jr nz, P22b
  ld a, 7Fh ; ostatni sektor /dla FLASH 512 kB, 1F - 128 kB, 3F - 256 kB
 P22b:
  ld (sekt_P), A
  ld (SEKT), A ; ustaw adres  FLASH
 PU0:
  RST   LADR      ; wysw. adresu poczatk.
  DEFB  43H
  ld a, (sekt_P) ; wysw. sektora i nadpisanie starszego polbajtu H
  ;ld A, (SEKT) ; **
  ld (SEKT), A
  rst LBYTE
  defb 26h
  LD    A,(HL)    ; pobranie danej
  RST   LBYTE     ; wyswietlenie (HL)
  DEFB  20H
  RST   TI1       ; pobr. znaku
  JR    C,PU1     ; wcisnieto CR / = /
  DEC   HL        ; do tylu
  JR    Z, P22A; SU0     ; wcisnieto SPAC / . /
  INC   HL        ; odtworzenie HL
  CP    10H       ;klaw. G - nowy adres
  jr z, P21
    ; wprowadzanie zakonczono klawiszem CR/=/, zwieksz adres
 PU1:
  INC   HL        ; do przodu
  call spr_adr_prz ; sprawdz adres, czy koniec sektora - z FFF przeskok na 1000
  JR    PU0

spr_adr_prz: ; przeskok na nastepny sektor ?
  bit 4, H  ; bylo FFF a jest po INC IX 1000
  ret z ; adres < od 1000
    ; adres FFF+1 , zmiana sektora na plytce FLASH, i IX=6000
  ld a, (SEKT_P); pomocniczy adres
  ;ld A, (SEKT)
  inc a
  cp 80h ; 20h dla SST39_SF010 /128kB/, 40-...020 /256kB/, 80 -..40 /512 kB/
  jr nz, spr12
 spr12a:
  xor A ; zaczynamy od sektora 0 /
 spr12:
  ld (sekt), a ; wybranie sektora na plytce FLASH by ZEGAR
  ld (SEKT_P), a
  cp 7Fh
  jp z, END_SZUK
  ld HL, FL ; od poczatku - od 6000h
  ret
;====
Z3:  ; suma kontrolna FLASH, od 0 do konca programow FD E4 FF
  ld A, 1
  out (INSTR), A; czysc LCD
  halt
  ld A, L1
  out (INSTR), A
  halt
  ld HL, suma_od ; "SUMA 0-"
  call wys_tekst
  nop
  call suma_k
  ld hl, suma ; "Su."
  call print
  defb 26h
  push ix
  pop hl
  rst 20h ; E7
  defb 42h
  ld A, L1+8
  out (INSTR), A
  halt
  push IY
  pop HL ; adres konca programow
  call wys_adr_lcd ; wysw. HL
  halt
  ld A, L1+7
  out (INSTR), A
  halt
  ld A, (SEKT_P) ; **
  ;ld A, (SEKT); nr sektora - koniec sumy kontrolnej
  call wysw_A
  halt
  push IX
  pop HL
  ld A, L1+16
  out (INSTR), A
  call wys_adr_lcd ; wysw. sumy
  ld a, 7Fh
  ld (SEKT), A ; ostatni sektor
  push IX
  pop DE
  ld HL, zapisana ; "ZAPISANA"
  call wys_tekst
  ld HL, (FL+0FFEh); adres dwoch ostanich bajtow w pam. FLASH
  call wys_adr_LCD
  XOR A ; CY=0, wazne przy odejmowaniu  !!!
  sbc HL, DE
  jr z, Z34
  ; sumy rozne
  ld A, L4
  out (INSTR), A
  halt
  ld HL, wp_su_ko ; "KL F4/W - WPISZ SUME"
  call wys_tekst
  ld HL, su_nok ; "no"
  jr Z341
 Z34: ; sumy sie zgadzaja
  ld HL, EE_OK ; "Ok"
 Z341:
  call print
  defb 20h
  rst 8 ; CF czekaj na klawisz
  cp 14h ; klawisz F4/W wpisz sume policzona
  call z, wpisz_sume ; wpisanie sumy obliczonej do pamieci pod 7FFFE-FF /dla 512 kB
  jp EEP_1

suma_k: ; obl. sume kontrolna od 0 do konca programow FD E4 FF
  xor A     ; suma liczona wlacznie z FD, bez E2 FF
  LD IX, 0  ; w IX bedzie liczona suma: ADD IX, BC
  ld (SEKT), A ; ustaw adres FLASH
  ld (SEKT_P), A
 Z3A:
  ld HL, FL
 Z31:
  ld A, (HL)
  ld C, A
  add IX, BC
 Z3B:
  cp 0FDh
  push AF
  inc HL
  ld A, H
  cp 70h ; koniec sektora ?
  jr nz, Z33
 Z32: ; jesli koniec sektora lub koniec FLASH
  ld A, (SEKT_P)
  inc A
  ld (SEKT), A
  ld (SEKT_P), A
  ld HL, FL
  cp 7Fh ; koniec FLASH
  jp z, END_SZUK ;Z3A ; tylko koniec sektora
 Z33:
  pop AF
  jr nz, Z31
  ld a, (HL)
  cp 0E4h
  jr nz, Z31
  inc HL
  ld a, (HL)
  dec HL
  cp 0FFh ; koniec programow
  jr nz, Z31
  push HL
  pop IY ; adres konca programow
  ret ; powrot z podprogramu obl. sumy kontr.

wpisz_sume: ; wpis sumy kontrolnej do pamieci
  ld A, 7Fh ; ostatni sektor
  call kas_sekt ; ld (SEKT), A
  ld HL, FL+0FFEh
  call SST_B_KEY ; odblokowanie FLASH
  ld (HL), E
  inc HL
  call SST_B_KEY
  ld (HL), D
  ret
;===
Z4:      ; kl. E - zapisz program [CAod][.][CAdo][.][nr_progamu] do FLASH
         ; kl. 7 - zapisz obszar [CAod][.][CAdo][.][od_flash] CA80 -> FLASH
         ; PRZED ZAPISEM OBSZARU MUSIMY SKASOWAC SEKTOR/SEKTORY !!!!, robi to podprogram <spr_sektFF>
  ld ix, FL ; na plytce FLASH = od 6000h !
  ld IY, SEKT_P ; do zwiekszania sektora o 1 gdy przekroczymy adres  6FFF
  ld (IY), 0 ; zaczynamy od sektora 0
  call ini_lcd
  halt
  ld a, L3
  out (instr), A
  halt
  ld hl, zap_progr
  call wys_tekst
  halt
  ld a, L4
  out (instr), A
  halt
  ld hl, zap_obsz
  call wys_tekst
 Z41:
  call TI
  defb 20h
  cp 0Eh ; klawisz E
  jp z, progr ; zapis programu [od] [do] [nr]
  cp 7 ;
  jr nz, Z41
  ;jr Z41
 ;===
obsz: ; zapisanie obszaru FLASH - SKASUJ SEKTOR, od ktorego chcesz zapisac obszar !
  ld a, L3 ; pozycja
  ld b, 20 ; ile skasowac
  call CLR_LCD_ZN
  ld hl, zap_39SF ; "ZAP.FLA.39"
  call print
  defb 80h
  call op_100ms
  defb 15 ; opozn. ok. 1,5 sek
  rst 10h ; D7 czysc wysw. CA
  defb 40h
  push IY ; = FEC4 (FEC4)=0
  call pob_adr_CA  ; pobranie adresow [CA_OD] i [CA_DO]
 zap1:
  call zap_FL39_od   ; pobranie adresu
  jr nc, zap1 ; adres FL prawidlowy /dla 512 kB -max to 7.FFFF
  ;jr zap1
 zap2:
  pop IY
  ld IX, (buf_adr+2)
  push ix
  pop hl
  ld (FL_DANE), HL ; przechowanie
  call set_sekt ; ustaw sektor na podstawie adresu zapisu do FLASH
  call spr_sektFF ; sprawdz, czy sektor wolny /FF/
  jr z, zap3 ; sektor zajety, podaj nowy adres
  push hl
  ld hl, SEKT_ERR
  call print
  defb 80h
  call op_100ms
  defb 5
  pop hl
zap3:
  ld hl, (r_od) ; pocz. obszaru RAM do przepisania
  ld de, (r_do) ; koniec RAM do przepisania,  potrzebne do HILO
 licz: ; zapis FLASH
  ld c, (hl) ; pobranie danej
  call SST_B_KEY ; odblokowanie FLASH
  ld (ix+0), c ; wpis do FLASH
  inc ix
      ; sprawdz czy koniec sektora - zmiana adr. z 6FFF na 7000
  ld a, IXH
  cp 70h
  jr nz, licz2 ; jeszcze nie koniec sektora
    ; przeskocz na nastepny sektor
  call ADD_SEKT_IX
 licz2:
  rst 20h ; E7 wysw. HL
  defb 44h
  call hilo ;  HL+1, HL = DE?
  jr nc, licz ; zapisuj dalej
 licz3:   ; koniec zapisu - dopisz jeszcze FD E4 (FF) jako koniec programu
  call spr_end_sekt
 licz21:
  ld c, 0FFh
  call SST_B_KEY
  ld (IX), C ; na wszelki wypadek...FF jako ostatni bajt zapisu
  inc IX
  call spr_end_sekt
  jr ini_FL1
 ini_FL:
  xor A
  ld (SEKT), A
  ld IX, FL
 ini_FL1:
  ld c, 0FDh
  call SST_B_KEY
  ld (IX), C
  inc IX
  call spr_end_sekt
  ld c, 0E4h
  call SST_B_KEY
  ld (IX), C
  inc IX
  call spr_end_sekt
  ld c, 0FFh
  call SST_B_KEY
  ld (IX), C
  nop
  nop
  nop
 ; call spr_zap_CA ; zmienia IX !!
 ; call spr_za_FL
 ; jp nz, Z4 ; zapis bledny, suma kontrolna z CA inna niz z FLASH
  ld HL, end_wr ; "end write" na CA
  call print
  defb 40h
  ld a, L3
  out (INSTR), A
  halt
  ld hl, end_wr1 ;"KONIEC ZAPISU" na LCD
  call wys_tekst
  rst 8 ; CF czekaj na wcisniecie klawisza
  jp EEP_1 ; pocz. programu

spr_end_sekt: ; jesli koniec sekktora 6FFF
  ld a, IXH
  cp 6Fh
  ret nz
  ld a, IXL
  cp 0FFh ; IX=6FFF , na nastepny sektor
  ret nz
  ld IX, FL ; od 6000
  call zw_sekt ; nastepny sektor
  ret
 ;==========
progr: ; zapis programu [OD_CA] . [DO_CA] . [NR] = /nr programu
  rst 10h ; D7 czysc wysw. CA
  defb 10h ; jedna cyfra
  ld a, L4 ; pozycja
  ld b, 14 ; ile skasowac
  call CLR_LCD_ZN
  push IY ; = SEKT_P
    ; zapisz obszar w CA /wpisywania  numerow/ bajtami FF
  call CLR_OB
  call szuk_numer ; odczyt numerow programow i wpis do RAM CA80 od FE40
  call pob_adr_CA  ; pobranie adresow: pocz - koniec w CA
  pop IY
  jr Z42_1
 Z42: ; gdy error przy wpisywaniu nr sektora, max 7F
  rst 10h
  defb 50h
  ld hl, er_1
  call print
  defb 35h
  call op_100ms
  defb 6
 Z42_1:
  rst 10h ; D7 czysc dwa znaki na CA
  defb 20h
  ld hl, nr_prog ; na CA "nrProg."
  call print
  defb 62h
 Z43:
  ld a, L2
  out (instr), a
  halt
  ld hl,kon_pr2 ; "PODAJ NR PROGRAMU" _LCD
  call wys_tekst
  call param ; pobierz nr programu /do HL/
  defb 20h; PWYSW
  ld a, L ; nr programu
  cp 80h
  jr nc, Z42 ; max sektor to 7F
  call spr_NR ; sprawdz, czy numer wolny
  jr nz, Z43b ; numer wolny
    ; numer zajety, wpisz inny
  push AF
  ld HL, NR_NF ; na CA "nr.no.Fr."
  call print
  defb 62h
  pop AF
  rst 18h ; DF wysw. A
  defb 20h
  rst 8 ; CF
  jr Z42

 Z43b: ; numer wolny
  rst 18h ; wysw. A
  defb 20h
  push af
  call wysw_A1 ; wysw. nr programu, bez zera poczatkowego
  pop af
  ld (NR_PR), A ; zapamietanie
   ; szukaj konca programow: FD E4 FF, zacznij od sektora 0, dares od 6000 = FL
  xor A ; A=0
  call SPR12 ;ld (SEKT), A
  ld DE, mar_PR ; FD E4
 Z431:
  call szuk_mar
  ld a, (HL)
  cp 0FFh
  jr nz, Z431
   ; znaleziono koniec programow FD E4 FF - zapisz sektor (IY) i adres (HL)
  push HL
  pop BC ; koniec programow w pam. FLASH, sektor wskazuje (IY)
  ld a, (NR_PR)
  call SST_B_KEY ; odblokowanie i wpis do FLASH
  ld (HL), A
  inc HL
  ld A, H
  cp 70h
  call z, zw_sekt
  ld DE, (R_OD) ; pocz. programu w CA
  call SST_B_KEY
  ld (HL), E
  inc HL
  ld A, H
  cp 70h
  call z, zw_sekt
  call SST_B_KEY
  ld (HL), D
  inc HL
  ld A, H
  cp 70h
  call z, zw_sekt
  push HL
  pop IX  ; pocz. zapisu programu w pam. FLASH
  ;call dane_sumy
  ld (P_PR_FL), HL ; pocz. programu w pam. FLASH - przechowanie w FED2
  jp zap3

 ADD_SEKT_IX:
  ld a, (sekt_P)
  ;ld A, (SEKT)
  inc a ; nastepny sektor
  ld (sekt), a ; ustaw adres w pam. FLASH- nastepny sektor
  ld (sekt_P), a
  ld ix, FL
  ret

zw_sekt:
  ; ld a, (sekt_P); gdy FL1 ; lepiej ld A, (SEKT) ; dla FLASH 2
  ld A, (SEKT)
  inc a ; nastepny sektor
  call SPR12 ; porownanie, czy ostatni sektor, i HL od 6000
  ret

pob_adr_CA:
  call pob_CAod  ; pobranie adresu
  ld (r_od), hl
  push HL ; do obl. dlugosci zapisu
  call pob_CAdo  ; pobranie adresu
  ld (r_do), hl   ; adres RAM do ..
  pop DE
  sbc hl, de
  inc HL
  ld (dl_zap), HL ; dlugosc bloku do zapisu
  ret

set_sekt: ; ustaw sektor wg pobranego adresu zapisu do FLASH SST39SFxx
  XOR A
  LD A, H  ; ustaw adres zapisu do FLASH
 set_sekt_odc:
  AND 0F0H
  LD L, A ;przechowanie
  LD A, (BUF_ADR+4) ; np. adres FL-12345, FEE1=01, 1234, FEE1=0 czyli sektor
  ADD A,L
  RLCA
  RLCA
  RLCA
  RLCA
  LD (SEKT), A   ; do FLASH
  LD (SEKT_P), A ; do RAM  bo FLASH V1 nie ma RAM !!
        ; ustawiamy poczatkowy adres zapisu do FLASH
  LD A, IXH
  AND 0FH ; usuwamy starsze bity
  LD B, A ; zapamietanie
  LD A, 60h
  ADD A, B
  LD IXH, A ; adres zaczyna sie od 6xxx
  RET

chip_erase: ; kasowanie CALEJ pamieci !!!
  exx ; zamiana rejestrow
  ld hl, adr5 ; HL - 7555h
  ld de, adrA ; DE - 7AAAh
  ld a, 55h
  ld (hl), E  ;0AAh ; 1 cykl pod 7555 -> AA
  ld (de), a    ; 2 cykl pod 7AAA, dana 55
  ld (hl), 80h  ; 3 cykl  pod 7555 -> 80
  ld (hl), 0AAh ; 4 cykl  po  7555 => AA
  ld (de), a    ; 5 cykl pod 7AAA -> 55
  ld (hl), 20h  ; 6 cykl  pod 7555 -> 10
  exx   ; czekaj TBLC0 + TWC /200uS + max 10mS/
  halt
  halt
  halt
  halt
  halt
  ret

op_100ms:; opozn. x 0,1s+ podac param. /cd xx yy zz/
   EX (sp), hl    ; zz - wielkosc opoznienia
   ld a, (hl)
   inc hl
   ex (sp), hl
   push hl
   push bc
   ld L,a
  op_licz:
   call op_2x50
   dec L
   jr nz, op_licz
   pop bc
   pop hl
   ret
    ; ponizej op. trwajace ok. 0,1 sek
op_2x50:  ld b, 50
 op_2ms2:    halt  ;trwa 2 ms
   djnz op_2ms2
   ret
;=============
pob_adr: ; pobranie adresu do bufora FEDF-FEE1, np. adr. 12345
         ; FEDF-45, ..E0-23, ..E1-01
  ld hl, buf_adr ; od FEDD
  call clr_buf ; zerowanie obszaru / w CA88 kalkulator
  call pob_kl_dat
  jr c, pob_adr ; blednie wpisano adres
 pob_adr1:
  call pob_kl_dat ;
  jr c, pob_adr
  jr z, pob_adr1
  cp 0Ah
  jr c, pob_adr1
 pob_kl_dat: ; pobranie
  call CI  ; cd C6FF
  call test_kl ; tylko cyfry 0-9
  ret c
  jr nz, pob_kl_dat1
  ld a, (hl)
  or a
  ret nz
  jr pob_kl_dat

 pob_kl_dat1:  ;
  or a
  ld c, a ; przechowanie pobranej liczby
  jr nz, pob_kl_dat2
  ld a, (hl)
  or a
  jr nz, pob_kl_dat2
  rst 10h ; czysc wysw. CA
  defb 80h
  ld c, 0
  call CO
  defb 50h ; ## ile miejsc wyswietlac ##
  jr pob_kl_dat

 pob_kl_dat2:
  ld a, (hl)
  cp 0Fh ; max il. cyfr pobranych, wyswietl tylko 5, patrz ##
  jr nc, pob_kl_dat     ; liczy sie tylko 5 ostatnich, na wypadek,
  ld a, c               ; gdybysmy sie pomylili przy wciskaniu klawiszy
  cp 10h ; jakie znaki - tylko 0-F !
  jr nc, pob_kl_dat
  ld a, (hl)
  or a
  jr nz, pob_kl_dat3
  rst 10h
  defb 80h
 pob_kl_dat3: ;
  call CO ; wysw. cyfry z rej. C na CA
  defb 50h ; ## ile miejsc wyswietlac, ##
  push hl
  call PLEW ; wpis pobranej cyfry (rej. C) do bufora /kalkul. CA80
  call C4 ; konwersja znakow z BUF_WYSW i wysw. na LCD
  pop hl
  jr pob_kl_dat

test_kl:
  cp 10h ; czy "G" - nowa adres
  scf
  cp 12h ; klawisz "="
  jr z, set_stos
  or a
  ret nz
  ld c, 0
  inc c
  ret
set_stos: ; wyrownanie stosu
  pop bc
  pop bc
  ret ;   jp zap11

PARAM_LCD:  ; pobieranie znakow /max 4 /HL/, adresow z jednoczesnym wysw. na lcd
  rst 28h   ; EF ustawienie parametrow wyswietlacza ca80 PWYS=FFF6
  ld a, (PWYS)
  push af
  and 0F0h ;kasuj mlodsze bity /od ktorej poz. na CA wysw
  rlca      ; zostaw ile miejsc wyswietlac
  rlca
  rlca
  rlca
  ld (ile_cyf), a ; (ile_cyfr) tyle cyfr wyswietlaj
  ld hl, CYF0; CYF0 !!!
  dec a
  ld e, a ; przechowanie
  pop af
  and 0Fh ; od ktorej pozycji na CA beda wyswietlane znaki
  add a, e
  add a, L
  ld L, a
  ld (poz_cyf), HL ; najstarsza cyfra do wyswietlania
           ; wyswietlane bedzie tylko (ile_cyf)

param1:  ; to ponizej pobiera tylko 4. znaki do HL, jesli wiecej-korzystaj z kalkulatora
  rst 8h  ; CF pobierz znak klawisza
  jr z, param1
  ld hl, 0 ; czysc hl
     par1:
  push af
  cp 10h ; czy cyfra szesnastkowa 0 - F
  jr nc, par2
  pop af
  add hl, hl
  add hl, hl
  add hl, hl
  add hl, hl ; przesun w lewo o 4 bity
  or L ; dopisz ostatnia pobrana cyfre
  ld L, A
  push hl ;ochrona zawartosci
  call C4 ; wysw. na LCD pobrany znak
  pop hl
    par3:
  rst 8h ; pobierz nastepny znak
  jr par1
    par2:
  pop af
  jr nz, par3
  push af
  call CLR1
  pop af
  ret
    ; po kazdym wpisie pobranej cyfry jest wyswietl. piec cyfr na LCD
C4: ; i konwersja cyfr z wysw. CA na kod LCD, nastepnie wysw. na LCD,
  ld a, (poz_wys) ; gdzie wyswietlac - pozycja
  out (instr), A
  ld hl, (poz_CYF) ; najbardziej znaczaca pozycja na CA80 /tu FB - CYFx/
  ld a, (ile_cyf) ; ile cyfr wyswietlac  - tu 5
  ld b, a ; ile cyfr
 c41:
  halt
  halt
  ld a, (hl)
  dec hl ; nastepna CYFRA
  call konw
  djnz c41
  ret

KONW:  ; konwersja znaku z CYFx /wysw. CA/ na kod LCD
  PUSH  HL
  PUSH  BC
  CP 0   ; jesli wyswietlacz "ciemny" - brak cyfry
  JR Z, C44 ;przeskocz, nie wyswietlaj na LCD
  LD    IY, TLCD ; tablica do konwersji znakow - moja wersja
  LD    HL, TSIED ; adres tablicy kodow 7. segm. w CA80 - od 0318h
  LD    B,10H ; dlugosc tablicy
 C42:
  CP    (HL)      ; czy to ten ?
  JR    Z, C43    ; znaleziono !
  INC   HL ; na nastepny kod rzeczyw.
  INC   IY ; na nastepny kod konwersji
  DJNZ  C42      ; szukaj dalej
C43:  ; znak znaleziony
  OR    A
  LD    A, (IY); kod na LCD
  halt
  OUT (DANA), A
C44:
  POP   BC
  POP   HL ;?
  RET
          ; odpowiedniki cyfr do wysw. na LCD /po znalezieniu cyfry z wysw. CA
TLCD:     DEFB  30h, 31h, 32h ,33h ; 0, 1, 2, 3      ; tablica TSIED - od 318h
          DEFB  34h, 35h, 36h, 37h ; 4, 5, 6, 7
          DEFB  38H, 39H, 41H, 42H ; 8, 9, A, B
          DEFB  43H, 44H, 45H, 46H ; C, D, E, F
;=====
Z5: ; szukanie programu i jego nazwy w pam. FLASH i wysw. na CA i LCD
szuk_progr: ; szukamy nr programu, po markerze FD E4/, zaczynamy od sektora 0
  call ini_LCD
  xor A ;  zaczynamy od poczatku
  call add_sekt_HL+4
  inc a
  ld (nr_L), a ; startujemy od 1. linii na LCD
 FL_SZ3: ;HL = 6000h
  LD DE, mar_PR ;w DE marker pocz. programu /po FD E4 jest nr programu/
  call szuk_mar ; szukaj markera
     ; znaleziono marker pocz. programu - FD E4
FL_SZ31:
  ld a, (HL) ; jesli po FD E4 jest FF FF - koniec obszaru z programami
  cp 0FFh
  jr z, END_SZUK

 FLASH_SZUK11:
  call obl_linie  ; w ktorej linii wyswietlic
  out (instr), a ; ustaw kursor na LCD
 FL_SZ2:
  ld a, (sekt_P) ; 5FFD **
  cp 7Fh ; ostatni sektor ; w 7F sa dane odnosnie SUMY KONTROLNEJ !!
  jr z, END_SZUK
  ld a, (HL); nr programu
  push AF
  rst 18h ; DF wysw. A /zmienia rej. C na CA/, nr programu
  defb 20h ;nop ; call wys_nr_pr
  pop AF ; nr programu
  call wysw_A ; nr programu na LCD
  rst 20h ; E7 wysw. HL - pocz. programu
  defb 43h
  ;ld A, (SEKT)
  ld A, (SEKT_P) ;**
  rst 18h ; DF wysw. A
  defb 26h
    ; teraz znajdz nazwe programu, po FD E4
  ld DE, mar_NAZ ; po nim nazwa programu
  call szuk_mar
  call wys_t2 ; wyswietl nazwe-max 17 znakow i sprawdz czy koniec sektora
  call obl_linie ; czy juz 4. linia, jesli 5. przeskok na 1. linie
  jr FL_SZ3

 END_SZUK:
  ld hl, kon_PR ; na LCD "KONIEC SEKTOROW"
  ld a, (nr_L)
  call obl_linie
  out (instr), A
  call wys_t2
  call op_100ms
  defb 15 ; ok. 1,5 sek
  call czysc_LCD
  ld hl, pr_END
  ld a, L1 ; ustaw kursor 1. linia
  out (instr), A
  call wys_tekst
  rst 8 ; CF- czekaj na wcisn. klawisza
  cp 0Fh ; 0-F to pobierz nr programu i przepisz do RAM
  jr nc, szuk_progr ; FLASH_SZUK1 ; wyswietlaj nazwy od nowa, jesli F1, pocz. programu FLASH
   ; wcisnieto nr programu
 SZUK2:
  call czysc_LCD
  ld hl, kon_pr2 ; "podaj nr programu"
  call wys_tekst
  rst 10h ; D7 czysc wysw. CA
  defb 20h ; dwa pierwsze znaki
  ld hl, nr_prog ; "nrProg" na CA80
  call print
  defb 62h
  call param
  defb 20h ; nr programu/sektora w L - wysw. na CA
  ld C, L ; do porownania podczas szukania
  ld A, L ; do wyswietlenia na LCD
  call wysw_A1 ; na LCD nr programu, bez zera poczatkowego
  xor A ; A=0
  ld (SEKT), A ; szukanie zaczynanmy od pierwszego sektora
  ld (SEKT_P), A
  ld (NR_SEKT), A ; do przeskoku na nastepny sektor
  ld DE, mar_PR ; marker programu FD E4
  ld hl, FL ; zacznij od 6000h
 sz21:     ; szukaj numer programu - rej. C
  call szuk_mar
  ld a, (HL); odczytany nr programu
  cp 0FFh ; FD E4 FF to koniec programow
  jr z, END_SZUK
  cp C  ; zapamietany nr programu
  inc HL
  jr nz, sz21 ; numer nie znaleziony
  ;jr sz21 ; szukaj dalej
     ; znaleziono nr programu
 sz22:  
     ; dwa nastepne bajty to pocz. programu w CA
  ld E, (HL)
  inc HL
  ld D, (HL)
  ld (r_od), DE ; pocz. programu w CA80
  inc HL
  push HL ; pocz. programu w pam. FLASH
  ld A, (SEKT)
  ld (NR_SEKT), A ; zapamietanie nr sektora /poczatek programu/
  ld DE, mar_PR ; marker pocz. programu
  ld IX, 0 ; oblicza dlugosc programu, zamiast innych "sztuczek"
  call szuk_mar ; szukaj nastepnego FD E4
  pop HL ; pocz. w pam. FLASH
  push IX
  pop DE ; dlugosc do przepisania
  dec DE
      ; przepisanie pobranego programu do CA
  ld a, (NR_SEKT) ; zapamietany nr sektora podczas szukania
  ld (SEKT), a  ; teraz CA80 ma dostep do FLASH gdzie pocz. programu
  ld bc, (R_OD) ; pocz. wpisu do RAM
 s24:
  LD A, (HL) ; odczyt z pam. FLASH
  ld (bc), A ; wpis do RAM
  inc BC
  inc HL  ; sprawdz koniec sektora
  ld a, H
  cp 70h ; czy 7000h
  call z, zw_sekt ;sz3 ; nastepny sektor
  dec DE
  ld a, D
  or E
  jr nz, s24
  ld HL, (R_OD)
  jp (HL)

  ;===========
szuk_mar: ; szukanie markera FD E4 /DD E2
  ld a, (HL)
  cp D ; czy FD
  push af
  inc IX ; tu bedzie dl. prog. podczas szukania numeru programu do przepisania da CA
  inc HL                               ; podczas nazwy - bezuzyteczne
  ld a, H
  cp 70h ; przekroczono 6FFF na 7000
  call z, zw_sekt ;sz3 ; przejdz na nastepny sektor

  pop af
  jr nz,szuk_mar
  ld a, (HL)
  cp E ; czy E2 -szuk. programu czy E4 - szuk. nazwy
  jr z, sz4 ;  jr nz, szuk_mar
  cp 0E4h ; jesli brak nazwy w programie, to po FD E4 tez bedzie FD E4
  jr nz, szuk_mar
  ld A, (NR_L) ; linia na LCD
  inc A
  ld (NR_L), A
  call obl_linie
  pop AF ; wyrownanie stosu
  jp FL_SZ31

 sz4:
  inc HL
  ld a, H
  cp 70h
  call z, zw_sekt ;sz3 ; SET nastepny sektor
  ret
  ;===============
NUM_LINII:  ; tablica adresow poczatkow linii LCD
  defb 0, L1, L2, L3, L4  ; musi byc na jednej stronie

obl_linie:      ; wpis do rej. A pocz. linii do wyswietlana
  ld a,(nr_L)  ; aktualnie nr linii do wyswietlania
  push HL
  ld HL,NUM_LINII ; (HL) wskazuje na zero
  add A,L
  ld L,A
  ld A,(HL)     ; HL wskazuje nr linii
  out (INSTR), A
  pop HL
set_linie: ; jesli byla 4. linia, przejdz na 1.
  ld a,(nr_L) ;
  cp 5 ; czy byla wyswietl. 4. linia?
  ret nz
 spr_L1:
  ld a,1 ; ustaw wyswietlanie na 1. linie LCD
  ld (nr_L), a
  rst 8 ; CF czekaj na wcis. klawisza i wysw. nastepne
  push af ; zapamietaj klawisz
  call czysc_LCD
  pop af
  cp 10h ; czy > niz F np. G, . = , F1-F4
  ret nc  ; inny niz 0-F / jesli 0 do F do przepisuje sektor do RAM
   ; przepisz program/sektor
  pop af ; pseudo RET
  jp SZUK2 ; podaj numer programu i szukaj, przepisz i uruchom go

wys_t2: ; wysw. na LCD max 17 znakow i przeskok na nastepna linie
  ld E, 18 ; max il. znakow do wysw
 wys_t21:
  ld a,(hl) ; pobierz litere
  cp 0FFh
  jr z,wys2
  halt
  out (DANA),a
     ; sprawdz, czy koniec sektora - podczas wyswietlania nazwy
  inc HL
  ld a, H
  cp 70h
  call z, ADD_SEKT_HL
  dec E
  jr nz, wys_t21 ; wysw. nastepny znak
 wys2: ; wszystkie znaki wyswietlone
  push HL
  ld HL, nr_L
  inc (HL); nastepna linia LCD
  pop HL
  ret

 ADD_SEKT_HL: ; gdy nazwa programu na przelomie dwoch sektorow, zwieksz nr sektora
  ;inc (IY+0) ; przeskok na nastepny sektor
  ;ld a, (IY+0)
  ;ld (nr_sekt), a
  ;ld (sekt), a ; ustaw adres sektora FLASH
  ;ld (sekt_P), a
  ld A, (sekt_P)
  inc A
  ld (SEKT), A
  ld (SEKT_P), A ; **
  ld HL, FL ; od poczatku
  ret
;=================
Z6: ; przepisanie FLASH do RAM w CA80
   ld A, 1   ; czysc LCD
   out (instr), A
   ld a, L4
   call busy
   out (instr), A
   ld hl, kl_0+2 ; "ODCZYT"
   call wys_tekst
 Od6:
  call zap_FL39_od ; pobranie adresu "OD" FLASH
  jr c, Od3
  jr Od6
   ; adres prawidlowy
 Od3: ; zapisz ten adres
  ld HL, (buf_adr+2)
  push HL ;4. bajty pocz. adr. FLASH , najstarszy 5.bajt zapisany w <zap15>
  ld (FL_DANE+1), HL ; zapis adresu pocz.
 Od3_1:
  ld a, L2+15
  ld b, 5
  call CLR_LCD_ZN
  call zap_EE29_do; pobranie adresu "DO" FLASH
  jr nc, Od3_1 ; adres OK, < 7.FFFF /dla 512 kB/ 3.FFFF-256 kB, 1.FFFF - 128 kB/
  ;jr Od3_1 ; adres zly, >= 80.000
 Od3_2:
  pop de ; 4. bajty pocz. adr. FLASH /liczac od najmloszej pozycji/
  ld hl, (buf_adr+2)   ; adres FLASH do ..
  or A ;
  sbc hl, de
  inc hl
  ld (dl_zap), HL
  push HL
  ld a, L3
  out (instr), A
  ld hl, dlug1 ; wysw. ilosc bajtow
  call wys_tekst
  pop HL
  call wys_adr_lcd ; wysw. ilosc bajtow
  ld bc, 7CFFh ; max wolne bajty od 8000-FCFF, /w moim CA80 - SK/
  sbc hl, bc
  jr c, Od4 ; jest OK, zmiesci sie w CA
  ;  zbyt dlugi, moze zniszczyc stos i inne dane
  ld a, L2
  out (instr), a
  ld hl, dlug ; "zapis przekroczy FD00"
  call wys_tekst
Od31:
  call CI
  cp 12h ; = OK
  jr nz, Od3_1
 Od4: ; pobierz adres zapisu do RAM
  rst 10h ; D7
  defb 40h
  call pob_CAod ; RAM "od"
  ld a, h
  cp 80h ; adres wpisu do CA musi byc >= 8000h !! /4000-7FFF FLASH/
  jr nc, Od5 ; jest OK
    ; adres bledny
  ld a, L3
  out (instr), A
  ld hl, pop_adr ; "popraw adres > 8000"
  call wys_tekst
  call op_100ms
  defb 15 ; opozn. ok. 1,5 sek
  rst 10h
  defb 40h
  ld b, 17
  ld a, L3
  call CLR_LCD_ZN
  jr Od4
Od5: ;przepisz obszar z FLASH do CA /adr. pocz.  >=8000h
    ; HL-pocz. zapisu w CA, pocz. w FLASH ( BUF_ADR+4)
  push hl
  ld ix, (FL_DANE+1)
  ld a, IXH ; do ustawienia sektora przy odczycie
  ld H, A
  ; starsze bajty adresu, do ustawienia sektora
  call set_sekt
  pop HL ; adres pocz, zapisu do CA
  ld de, (DL_ZAP)
 Od51:
  ld c, (IX) ; adres w FLASH; max to 6FFF, przeskok na 7000 to zmiana seltora
  ld (HL), c ; wpis do CA
  inc ix
  ld a, IXH
  bit 4, A ; lub CP 70h - jeden takt mniej
  ;jr z, Od52
  ;call ADD_SEKT_IX ; bo IX = 7000
  call nz, ADD_SEKT_IX
Od52:  ; sprawdz, czy koniec zapisu /DL_ZAP/
  inc hl
  dec de
  XOR A
  CP E
  jr NZ, Od51 ; zapisuj dalej
  CP D
  jr nz, Od51
  dec HL
  push HL
  rst 20h ; E7 -wysw. rej. HL
  defb 41h
  ld hl, end_wr
  call print
  defb 35h
  ld a, L1+12
  out (instr), A
  ld hl, RAM_do ; "do"
  call wys_tekst
  pop HL
  call wys_adr_LCD
  rst 8 ; CF czekaj na wcis. klaw
  jp zap_FL ; koniec obszaru zapisu RAM, wroc na pocz. programu
;==
Z7:
  call czysc_LCD
  ld hl, kon_pr2 ; "podaj nr programu"
  call wys_tekst
  rst 10h ; D7 czysc wysw. CA
  defb 20h ; dwa pierwsze znaki
  ld hl, nr_prog ; "nrProg" na CA80
  call print
  defb 62h
  call param
  defb 20h ; nr programu/sektora w L - wysw. na CA
  ld C, L ; do porownania podczas szukania
  ld A, L ; do wyswietlenia na LCD
  call wysw_A1 ; na LCD nr programu, bez zera poczatkowego
  call SPR12A ; zacznij do sektora 0 i HL = 6000
  ld DE, mar_PR ; marker programu FD E4
 sz21a:     ; szukaj numer programu - rej. C
  ld a, (HL)
  cp D ; czy FD
  push af
  inc HL
  ld a, H
  cp 70h ; przekroczono 6FFF na 7000
  call z, ZW_SEKT ; przejdz na nastepny sektor
  pop af
  jr nz,sz21a
  ld a, (HL)
  cp E ; czy E2 -szuk. programu
  jr nz, sz21a
  inc HL
  ld a, H
  cp 70h ; przekroczono 6FFF na 7000
  call z, ZW_SEKT ; przejdz na nastepny sektor
  ld a, (HL); odczytany nr programu
  cp 0FFh ; FD E4 FF to koniec programow
  jp z, END_SZUK
  cp C  ; zapamietany nr programu
  inc HL
  jr nz, sz21a ; numer nie znaleziony  
  ;inc HL
  ;jr sz21a ; szukaj dalej
     ; znaleziono nr programu
 sz22a:
  ;inc HL ; dwa nastepne bajty to pocz. programu w CA
  ld E, (HL)
  inc HL
  ld D, (HL)
  ld (r_od), DE ; pocz. programu w CA80
  inc HL
  push HL ; pocz. programu w pam. FLASH
  ld (BUF_ADR), HL ; zapamietanie + sektor ponizej
  ld A, (SEKT_P)
  ld (BUF_ADR-1), A ; zapamietaj - aktualny nr sektora - pocz. programu w pam. FLASH
  ld DE, mar_PR ; marker pocz. programu
  ld IX, 0 ; oblicza dlugosc programu, zamiast innych "sztuczek"
  call szuk_mar ; szukaj nastepnego FD E4
  push HL
  dec HL
  dec HL
  dec HL
  ; ustaw kurosor na wysw. konca programu w pam. FLASH
  ld A, L2+16
  out (INSTR), A
  ld (BUF_ADR+3), HL ; koniec programu w pam. FLASH /plus sektor !!!/
  ld A, (SEKT_P)
  ;ld A, (SEKT)
  ld (BUF_ADR+2),A
  halt
  call wys_adr_LCD
   ; ustaw kurosor na wysw. pocz. programu w pam. FLASH
  ld A, L2+10
  halt
  out (INSTR), A
  ld HL, (BUF_ADR); pocz. programu
  halt
  call wys_adr_LCD
  ld A, "-"
  halt
  out (DANA), A
  ld A, (BUF_ADR+2)
  halt
  call wysw_A
  ld A, L2+9
  halt
  out (INSTR), A
  ld A, (BUF_ADR-1)
  halt
  call wysw_A
  ld A, L2
  halt
  out (INSTR), A
  ld HL, FLA ; "FLASH"
  halt
  call wys_tekst
  ld HL, (R_OD); pocz. programu w CA80
  rst LADR ; wysw. HL
  defb 44h
  ld HL, CYF4
  set 7, (HL)
  push IX
  pop HL
  rst LADR ; wysw. HL
  defb 40h
  ld A, L3
  out (INSTR), A
  ld HL, CA_DL ; "PROGRAM CA"
  halt
  call wys_tekst
  ld HL, (R_OD) ; pocz. progr. w CA "od"
  halt
  call wys_adr_LCD
  ld a, "-"
  halt
  out (DANA), A
  push IX
  pop BC
  adc HL, BC
  dec HL
  halt
  call wys_adr_LCD
  nop
  nop
  nop
  rst 8 ; CF
  jp EEP_1
;==
;Z8: ; inicjacja FLASH - wpis od 00000 FD E4 FF
;  jp ini_FL
CLR_LCD_ZN:
 ; kasuje znaki na lcd: ilosc w rej. B, rej. A - od pozycji
  push af
  call busy
  out (instr), A ; ustawia kursor
  push hl
  ld a, 20h ; kod spacj1
  kas:
  call busy
  out (DANA), A
  djnz kas
  pop hl
  pop af
  call busy
  out (instr), A ; powrot kursora na pocz. kasowanych znakow
  ret
;===============
; obsluga LCD
ini_lcd:
  ld a, 30h ;
  out (instr),a
  halt
  halt
  halt
  ld a, 30h
  out (instr),a
  call op_100us
  call op_100us
  ld a, 30h
  out (instr),a
  call op_100us
  ld a, 38h ; sterowanie 8-bit
  out (instr),a
  call busy
  ld a, 1 ; czysc LCD
  out (instr),a
  halt
  halt
  call op_100us
  ld a, 0Eh ; kursor na dole i wlacz LCD
  out (instr),a
  call op_100us
  ld a, 6
  out (instr),a
  halt
  ;call wpis_PLD
  ;ld a, L1
  ;out (instr), A
  ret    ; powrot z podprogramu ini_lcd

op_100uS:
  ld a, 50h
  op2:
  dec a
  jr nz, op2
  ret

busy: ; czy LCD gotowe na dalsze instrukcje
   push af
  busy1:
   in a,(LCD_BUSY)
   and 80h
   jr nz, busy1
   pop af
   ret

WYS_tekst: ; wysw. tekst wg (hl), koniec tekstu FF
 ld a, (hl)
 cp 0FFH
 ret z
 call busy
 out (DANA), A
 inc hl
 jr WYS_tekst

CZYSC_LCD: ; czysci lcd i ustawia kursor na pozycji poczatkowej LCD
  LD        A,1
  OUT       (instr),A
  HALT                     ; opoznienie
  HALT
 U_K_HOME:                                      ; ustaw kursor na poczatek LCD
  LD        A,L1           ; 1. linia/
  OUT       (instr),A
  HALT                     ; opoznienie
  HALT
  RET

WYS_ADR_LCD: ; wyswietla 4. znaki z rej. HL, wg aktualnej pozycji kursora
  PUSH BC
  LD A, H
  CALL wysw_A ; rozdziela rej. A na dwa bajty i wyswietla na lcd
  LD A, L
  CALL wysw_A ; HL na kody liter/cyfr na lcd
  POP BC
  RET

ROZDZIEL: ; dzieli rej. A na dwie liczby/znaki i umieszcza w HL
  PUSH AF
  AND 0F0H; usun mlodsze bity
  RRCA ; na prawo
  RRCA
  RRCA
  RRCA
  CALL ZAMIEN; zamienia litery na cyfry, cyfry bez zmian
  LD L, A
  POP AF
  AND 0FH ; usun starsze bity
  CALL ZAMIEN
  LD H, A
  RET

ZAMIEN: ; zamiana cyfr hex na ASCII, wg ZEGAR
     ; do wyswietlania na LCD
  CP 0AH    ; litera czy cyfra - cyfry <= 9, litery > 9
  SBC A,69H
  DAA
  RET

wysw_A: ; wyswietla zaw. rej A na lcd, wg aktualn. stanu lcd
  push hl
  call rozdziel
  ld a, L
  call busy
  out (DANA), A
  ld a, H
  call busy
  out (DANA), A
  pop hl
  ret

wysw_A1:; wyswietlenie rej. A na LCD bez zera poczatkowego, np. godzina 7:55:25
  push hl
  call rozdziel
  ld a, L ;
  cp 30h
  jr z, WA1
  call busy
  out (DANA), A
 WA1:
  ld a, H
  call busy
  out (DANA), A
 wys1:
  pop hl
  ret

wpis_PLD: ; wpis duzych liter PL
   ld hl, ZNAKI_PLD
   jr wp_1
wpis_PLM: ; wpis malych liter PL do LCD
   ld hl, znaki_plm
  wp_1:
   ld a, 40h
   out (instr), A
;wpis_CGRAM: ; wpis znakow do LCD
   ld b, 64 ; 40h
 wp_2:
   ld a, (hl)
   call busy
   out (DANA), A
   inc hl
   djnz wp_2
   halt
   ret
ZNAKI_PLM: ; male litery  /diakrytyczne/
       defb 0,0,0Eh,1,0Fh,11h,0Fh,2   ; -> 0 /a z "ogonkiem"
       defb 2,4,0Eh,10h,10h,11h,0Eh,0 ; c -> 1
       defb 0,0Eh,11h,1Fh,10h,0Eh,2,0 ; e
       defb 0Ch,4,6,4,0Ch,4,0Eh,0     ; l
       defb 2,4,16h,19h,11h,11h,11h,0 ; n
       defb 2,4,0Eh,11h,11h,11h,0Eh,0 ; o
       defb 2,4,0Eh,10h,0Eh,1,1Eh,0   ; s
       defb 0,4,1Fh,2,4,8,1Fh,0       ; z -> 7
ZNAKI_PLD:  ; duze litery
       defb 0Eh,11h,11h,1Fh,11h,11h,2,0  ; -> 0  /A z "ogonkiem"
       defb 4,0Eh,11h,10h,10h,11h,0Eh,0  ; C -> 1
       defb 1Fh,10h,10h,1Ch,10h,10h,1Fh,2 ;E
       defb 10h,10h,14h,18h,10h,10h,1Fh,0; L
       defb 4,15h,19h,15h,13h,11h,11h,0  ; N
       defb 4,0Eh,11h,11h,11h,11h,0Eh,0  ; O
       defb 4,0Fh,10h,1Fh,1,11h,1Fh,0    ; S
       defb 4,1Fh,11H,2,0Ch,11H,1Fh,0    ; Z -> 7

pob_CAod:
  ld hl, CA_od ; RAM od....
  call print
  defb 44h
  ld a, L1
  out (instr), a
  halt
  ld hl, ram_od
  call wys_tekst
  halt
  ld a, L1+7 ; tu pocz. wysw. pobieranego adresu "od"
 pob1:
  ld (poz_wys), a
  call param_LCD ; pobiera adres, max 4. cyfry /HL/
  defb 40h ; PWYSW
  ret

pob_CAdo:
  ld hl, CA_do ; RAM do ....
  call print
  defb 44h
  ld a, L1+12; tu pocz. wysw. pobieranego adresu "do"
  out (instr), A
  halt
  ld hl, ram_do
  call wys_tekst
  ld a, L1+15
  jr pob1

zap_FL39_od:
  ld hl, FLod ; zapis do SST 39SF od sektora....
  call print
  defb 44h
  ld a, L2
  out (instr), A
  halt
  ld hl, FL_od
  call wys_tekst
  ld a, L2+6
  ld (poz_wys), a
  ld a, 5 ; bedzie teraz 5. liczb
  ld (ile_cyf), a
  ld HL, CYF4 ; /FFFB/
  ld (poz_cyf), HL
  jr zap22

zap_EE29_do:   ; np. adres 65432 : FEDF-32, FEE0-54, FEE1-06
  ld hl, FLdo ; FLdo ....  np. 7654  FEDF-54 FEE0-76
  call print
  defb 44h
  rst 10h
  defb 40h
  ld a, L2+12; tu pocz. wysw. pobieranego adresu "do"
  out (instr), A
  halt
  ld hl, ram_do ; "do"
  call wys_tekst
  ld a, L2+15
  ld (poz_wys), a
 zap22:
  halt
  call pob_adr ; pobiera adres
  ld a, (buf_adr) ; jesli wcisnieto tylko 0
  cp 0
  jr nz, zap23 ; wcisnieto inna niz 0
  ld a, L2+6
  out (instr), A ; ustaw kursor
  halt
  ld a, 30h ; "0"
  out (DANA), A
zap23:
  ld a, (buf_adr+4)
  and 0Fh
  cp 8 ;2 - dla SST39010/max 1.FFFF/, 4-SST29020 /max 3.FFFF, 8-SST29040 max 7.FFFF
  ret c   ; zap2
     ; adres >1FFFF - /SST29010/lub >3FFF lub > 7FFFF  = ERROR
  ld hl, KO3 ; "ERROR"
  call print
  defb 50h
  call op_100ms
  defb 10 ; opozn. ok. 1 sek
  rst 10h ; D7 czysc wysw. CA
  defb 50h
  XOR A ; CY=0  ret
  ret

END_PROGR: ; koniec obszaru z programami
  ld a, L3
  out (instr), a
  ld hl,kon_pr
  call wys_tekst
  ld hl, end_wr
  call print
  defb 30h
  rst 8 ; CF czekaj na klawisz
  jp Z5

SST_B_KEY:                 ; odblokowanie flash (SST39SF040) wg ZEGAR
        push HL            ; nie stosujemy pollingu
        push DE            ; ani innych sztuczek - mierzymy czas
        push AF            ; 4 * 11 cykli /rozkazy PUSH/
        push BC            ; zapis do Flash Tbp MAX 20 us
        ld b, 9            ; wait 170 * 0.125us (8 MHz > 20 us)
 op4:                      ; czekamy na koniec zapisu poprzedniego bajtu
        djnz  op4          ; 9*13 taktow = 117
        pop BC             ; 10
        ld A, 55h ;        ; 7 taktow
        ld HL, adr5        ; adres 10 taktow
        ld (HL), 0AAh ; 1. cykl zapisu -  10 taktow
        ld DE, adrA        ; adres  10
        ld (DE), A    ; 2. cykl zap.   7 taktow
        pop AF             ; 10
        pop DE             ; 10
        ld (HL),0A0H  ; 3.  cykl zapisu - 10 taktow - klucz
        pop HL             ; 10
        ret    ; 10 taktow ; razem ok. 255 taktow - 63,75 us
 ; ===========
wysw_kom_1:  ; wyswietl komunikaty po uruchomieniu programu
   ld a, L1
   call busy
   out (instr), A
   ld hl, CA_EE2 ; "ZAP-ODCZ PROG FLASH"
   call wys_tekst; i przeskocz na nastepna linie LCD
   ret

spr_sektFF: ; czy wolne sektory
   ld B, 0
   ld HL, (dl_zap)
   ld DE, 0FFFh
 s_FF:
   sbc HL, DE
   inc B ; ilosc potrzebnych sektorow
   jr nc, s_FF
   push BC ; B = ilosc potrzebnych sektorow do zapisu obszaru
     ; odworz pierwszy sektor wg adresu zapisu do FLASH
   ld HL, BUF_ADR+4
   ld D, (HL)
   dec HL
   ld A, (HL)
   and 0F0h ; usun mlodsze bity
   add A, D ; pierwszy sektor zapisu
   rrca   ; na prawo
   rrca
   rrca
   rrca
   ld E, A ; zapamietanie nr /poczatkowego sektora/
   ld C, A
  s_FF1:
   ld (SEKT), A ; ustaw sektor
   ld (SEKT_P), A ; **
   ld (IY), A ; IY = SEKT_P = FDE4
   ld HL,FL
   ld D,0FFH
  s_FF2:
   ld a, (HL)
   cp D
   push AF
   inc HL
   ld a, H
   cp 70h
   jr z, s_FF3; nastepny sektor
   pop AF
   jr nz, s_FF4
   jr s_FF2
 s_FF3:
   pop AF
   inc (IY) ; przeskok na nastepny sektor
   ld a,(IY)
   ld (SEKT), A ; ustawienie adresu FLASH
   ld (SEKT_P), A ;**
   djnz s_FF1 ; zmniejsz il. sektorow do sprawdzenia i sprawdz nastepny
    ; sektory sprawdzone. wroc na sektor poczatkowy wpisu, wg pobranego adresu
   ld (IY), C
   ld A, C
   ld (SEKT), A
   ld (SEKT_P), A ; **
   pop BC ; jesli wszystko OK
   xor a ; zeruj A , znak ze wszystkie bajty w sektorze = FF
   ret ; powrot

 s_FF4:  ; sektor  nie jest pusty
   ld hl, sekt_Z ; sec.no FrE"
   call print
   defb 80h
   ld hl, SEKT_NOF ; "SEKTOR ZAJETY"
   ld a, L4
   out (INSTR), A
   call busy
   call WYS_TEKST ; max 20 znakow
   ld HL, sekt_kas ; "DO KASOW OD "
   ld a, L3
   call busy
   out (INSTR), A
   call busy
   call WYS_TEKST
   ld A, E
   call busy
   call wysw_A ; poczatkowy sektor do kasowania
   ld HL, _IL ; " IL"
   call wys_tekst
   pop BC ; w B ile trzeba skasowac sektorow
   ld A, B
   call wysw_A
   rst 8
   call szuk_wol
   rst 8 ; CF
   JP WYB_SEKT
 ;=========
szuk_wol: ; pokaz adres gdzie zaczynaja sie FF FF FF ...
  call suma_K ; rej. HL wskazuje FD
  inc HL
  inc HL
  inc HL
  push HL
  ld A, L4
  out (INSTR), A
  ld HL, _wol
  call wys_tekst
  halt
  ld A, L4+15
  out (INSTR), A
  pop HL
  call wys_adr_LCD ; wysw. rej. HL
  ld A, L4+14
  halt
  out (INSTR), A
  ld A, (IY)
  call wysw_A ; sektor 0 - 7F
  rst 20h
  defb 40h
  rst 8 ; CF
  ret
;===

CLR_OB:; "zerowanie" / FF/ obszaru do wpisywania odczytanych numerow programu
  ld B, 99 ; max il. programow - 99 , tyle przyjalem
  ld HL, PR_CA ; FE40h
  ld a, 0FFh
 pr1:
  ld (HL), A
  inc hl
  djnz PR1
  ret
szuk_numer:
  call spr12a ;XOR A ; A = 0 zaczynamy od sektora 0
  ld BC, PR_CA ; tu zapisuj /RAM CA80/ odczytane numery programow
 Z11:
  LD DE, mar_PR ;w DE marker pocz. programu /po FD E4 jest nr programu/
  call szuk_wnr ; szukaj wolny numer programu, wpisz odczyt. numery do RAM CA80
  ret
szuk_wnr:
  call szuk_mar ; szukaj markera
     ; znaleziono marker pocz. programu - FD E4
  ld a, (HL) ; jesli po FD E4 jest FF FF - koniec obszaru z programami
  cp 0FFh ; koniec programow
  ret z ; powrot po napotkaniu ostatniego programu
  ld (BC), A ; wpis do RAM CA80
  inc BC
  jr szuk_wnr

spr_nr: ;rej. A - nr programu - czy podany numer programu juz wykorzystany
   cp 0FEh  ; nr zabroniony, po FD E4 FE oznacza koniec programów w EEPROM I2C
   ret z
   cp 0FFh  ; nr zabroniony , po Fd E4 FF oznacza "pusty obszar" - wypelniony FF
   ret z
   ld bc, 64h ; max il. programów  99     ; jesli nie to przepisz program do EEPROM
   ld HL, pr_ca ; pocz. obszaru szukania numer programu w RAM
   CPIR ; szukaj
   ret ;Z=0 -> numer juz wykorzystany, Z = 1 -> nie znaleziono wsrod wpisanych -OK, jest wolny, przepisz program do EEPROM

   ; teksty na CA80
CA_od:    defb 39h, 77h, 5Ch, 0DEh, 255 ; napis "CAod."
CA_do:    defb 39h, 77h, 5eh, 0DCh, 255 ; "CAdo."
FLod:     defb 71h, 38h, 5ch, 5eh, 255 ; "FLod" - 0FFh koniec tekstu
FLdo:     defb 71h, 38h, 5eh, 5ch, 255;
nr_sect:  defb 54h, 0D0h, 6dh, 79h, 58h, 31h, 255 ; "nr.sect" - 0FFh koniec tekstu
er_1:     defb 79H, 50H, 50H, 255; "ERR"
er_ok:    defb 79H,50H,77H,6DH,79H,0 ; "ERASE"
EE_OK:    defb 5Ch, 78H, 255 ; "OK:
zap_39SF: defb 5bh,77h,0F3h, 71h,38h,0F7h,4Fh, 6Fh,  255; "ZAP.FLA.39" na CA
end_wr:   defb 0,79h, 54h, 0DEh,255 ; tekst "End" dla ca80
sekt_z:   defb 6Dh, 79h, 0D8h, 54h, 0DCh,71h, 50h, 0F9h, 255; "sec.no.Fre"
flash2:   defb 71h, 38h, 77h, 6dh, 74h, 8, 5Bh, 255 ; "FLASH_2"
nr_prog:  defb 54h, 50h, 73h,50h,5ch, 0bdh, 255 ; "nrProg. " na CA
err_fl:   defb 79H,50h,0D0H,71h,38h,77h,6dh,74h, 255  ; "Err.Flash" na CA80
SEKT_ERR: defb 6dh, 79h, 0D8h, 79h, 50h, 50h, 5Ch, 50h, 255
suma:     defb 6Dh, 9Ch,255 ; "Su." 6Dh, 1Ch, 54h, 0F7h,255 ; "Suma"
;su_NOK:   defb 6Dh, 1Ch, 54h, 0F7h, 54h,0DCh, 5Ch, 78h, 255 ; "suma. no. oK"
zap_NOK:  defb 5Bh, 77h, 73h, 0, 54h, 0DCh, 5Ch, 78h, 255 ; "ZAP. NO.OK
zap_OK:   defb 5Bh, 77h, 73h, 6, 6Dh, 0, 5Ch, 78h, 255 ; "ZAPIS OK"
su_NOK:   defb 54h, 0DCh, 255 ; "no."
nr_fr:    defb 54h, 50h, 71h, 50h, 79h, 0F9h, 255 ; "nrFree" na CA
nr_nf:    defb 54h, 5Ch, 71h, 50h, 79h, 0F9h, 255 ; "noFree" na CA
    ; tekst na LCD
  defb 0DDh, 0E2h ; marker nazwy programu
zap_SST:  defm " FL2_x39.OBSZ_5000",255
erase_FL: defm "  KASOWA",1,"  FLASH ?  ", 255
klaw_C:   defm "KLAW. C  CA",3,"A PAMI",2,1,255; WSZYSTKO", 255
klaw_C1:  defm "JESTE",6, " PEWIEN ? E OK",255
klaw_2:   defm "KLAW. 2 SEKT nr 0-7F", 255
RAM_od:   defm "RAMod:    ", 255 ; 5x spacja, gdy bledny adres, skasowanie cyfr na LCD
RAM_do:   defm "do:", 255
FL_od:   defm "FL_od:     ", 255 ; 5x spacj, jesli bedzie blad pobierania
dlug:     defm "zapis przekr. FDFF", 255
dlug1:    defm "IL. BAJT", 5, "W ", 255 ; ilosc bajtow
pop_adr:  defm "popraw ADR > 8000",255
;CA_EE2:   defm "ZAP-ODCZ PROG  FLASH" ;,255 ;
CA_EE2:   defm "0-KASUJ  1-WOLNY NR " ;"3-suma kontrol FLASH" ;,255 ;     w L1
KL_3:     defm "4-ZAPIS 5-SZUK PROGR" ; w L3
kl_1:     defm "2-PRZEGL 3-SUMA KONT";,255 ; w L2
kl_0:     defm "6-ODCZ  7-POZYCJA PR",255       ; w L4
sekt_wyb: defm "PODAJ NR SEKTORA",255
kasOD:    defm "kasOD:", 255
potw:     defm "POTWIERD",7," KL. = !!!",255
zap_progr:defm "ZAPIS PROG [nr] kl E", 255
zap_obsz: defm "ZAPIS OBSZARU  kl 7", 255
kon_pr2:  defm "PODAJ NR PROGRAMU " ,255
kon_pr:   defm "KONIEC PROGRAM",5,"W" ,255 ;..M" defb 5 "W"
przeg:    defm "PRZEG. FLASH SST39xx", 255
end_wr1:  defm "KONIEC ZAPISU FLASH ",255
sekt_noF: defm "SEKTOR ZAJ",2 ,"TY !", 255
usun_sekt:defm "KASUJ SEKTOR ?", 255
sekt_kas: defm "DO KASOW OD ", 255
pr_END:   defm "END-nrPROG lub .lub=", 255 ; na LCD
kon_sek:  defm " KONIEC SEKTOROW", 255
_IL:      defm " IL",255
_wol:     defm "WOLNY OBSZ od ", 255
find:     defm "  SZUKAM KONCA" ,255
find2:    defm " PROGRAMOW W EEPROM" ,255
nr_1WOL:  defm "PIERWSZY WOLNY NR " ,255
nr_nf1:   defm " NUMER ZAJETY" ,255
ile_pro:  defm "ZNALEZIONO " ,255
szu_dl:   defm "SZUK DLUG PROGRAMU", 255
dl_pr:    defm "dlug ", 255
FLA:      defm "FL od-do",255
CA_DL:    defm "PROGRAM CA ",255    ;
wp_su_ko: defm "KL F4/W - WPISZ SUME",255
suma_od:  defm "SUMA 0-", 255
zapisana: defm "ZAPISANA ",255

spr_zap_CA: ; obl. sume kontrolna z CA
  ld BC, 0
  ld HL, (R_OD) ; poczatek w RAM
  ld DE, (R_DO) ; koniec w RAM
  ld IX, 0
 licz_su:
  ld c, (HL)
  add IX, BC
  call hilo
  jr nc, licz_su
  ld (su_CA), IX; zapamietanie
  ret
;spr_za_FL:    ; teraz obl. sume kontr. z FLASH
  ld IX, (buf_adr+2) ; adres w pam. FLASH
  push ix  ;     np. adr. 12345-> FEDF 45, FEE0 23 FEE1 01 /poczatek sekt. 1
  pop hl   ;     np. adr. 2345 -> FEDF 45, FEE0 23, FEE1 00 / poczatek sekt 0
           ; rej. H - 23, L - 45
  ld (FL_DANE), HL ; przechowanie, FED0-45, FED1-23
 spr1:
  call set_sekt ; ustaw sektor i adres na podstawie adresu zapisu do FLASH
  ld HL, 0 ;
  xor A
  ld B, A ; zerowanie B
  ld DE, (DL_ZAP)
  nop ;?? czy inc DE ; to nie HILO, dlatego +1
 licz1a:
  ld c, (IX)
  add HL, BC
  dec DE
  ld A, E
  or D
  jr z, licz1B
  inc IX
  ld A, IXH
  cp 70h
  jr nz, licz1a ; sumuj dalej
  call z, zw_sekt  ; zwieksz sektor
  jr licz1a
 licz1B:
   ;koniec liczenia sumy
  ld BC, (su_CA) ; suma z RAM
    ; suma z EEprom w HL
  sbc HL, BC
  push AF
  jr nz, su_no
  ld hl, ZAP_OK ; napis "OK" na CA80
 su1:
  call print
  defb 80h
  rst 8 ; CF
  rst 10h ; D7 czysc wysw. CA80
  defb 20h
  pop AF ; 0 - wszystko OK, zapis poprawny
  ret
  ; sumy niezgodne
 su_no:
  ld HL, ZAP_NOK
  jr su1
;======
