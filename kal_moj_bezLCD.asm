  ; kalendarz wieczny od 1.01.0001 / nie bylo roku 0000 !!/
  ; uwzgledniajacy zmiane kalendarza na gregorianksi - brak dni 5-14.10.1582 - 10 dni
  ; date wpisujemy: DDMMRRR i wciskamy "="
  ; klawisz A - oblicznie ilosci dni pomiedzy dwiema datami
  ; klawisz C - obliczanie dnia tygodnia - po uruchomieniu rpogramu jestesmy w zlec. A;
PRINT:       EQU 01D4H ; wyœwietla tekst wg (HL), + PWyœw CD D4 01 44, po ostatnim zanku musi byc FF
PARAM:       EQU 01F4h ; pobiera bajty do hl, podaæ PWYS
TABM:        EQU 32DH  ; tabela ograniczen miesiecy CA80
CSTS:        EQU 0FFC3h; pobiera znak z klawiatury /flaga C/
COM:         EQU 01ABh ; wyœw. zawartosc rej. C, podac PWYS
CI:          EQU 0FFC6h; czekanie na puszczenie klawisza a potem na wcisniecie
CIM:         EQU 184H ; jak CSTS
hilo:        EQU 023bh

CYF0:        EQU 0FFF7h ;wyœw. cyfry na pozycji 0 wyœwietlacza CA80
CYF1:        EQU 0FFF8h ;wyœw. cyfry na pozycji 1
CYF2:        EQU 0FFF9h
CYF3:        EQU 0FFFAh
CYF4:        EQU 0FFFBh
CYF5:        EQU 0FFFCh
CYF6:        EQU 0FFFDh
CYF7:        EQU 0FFFEh
   ; z kalkulatora CA88
bufX:        EQU 0FE10H ; bufor X
bufY:        EQU 0FE1Ah
bufZ:        EQU 0FE3Ah
clr_buf:     EQU 0CA0h ; zerowanie bufora
clr_bufX:    EQU 0E2Ch ; zerowanie bufora X /j.w +ld hl, FE10
mnoz:        EQU 0E09h ; operacja mno?enia bufor?w bufX=bufX*bufY
dodaj:       EQU 0Db0h ; operacja dodawania bufor?w j.w.
kas_bufor:   EQU 0E2Ch ; kas. bufora  do obliczeñ (podprogr.z kalkulatora)
wpis_buf:    EQU 0C57h ; wpis liczby do bufora
wys_buf:     EQU 0D41h ; wyœwietla bufor, podprogram z kalkulatora CA88, do zam_16_na_10
 
 ORG    0D000h   ; kalendarz wieczny
  ; lata podzielne przez 4, ale nie przez 100 beda przestepne, z wyjatkiem
  ; tych podzielnych przez 400 (lata 1600, 2000, 2400 itd beda w kalendarzu
  ; gregorianskim przestepne, a 1700, 1800, 1900, 2100 itd nie).
        
kal_start:
  ld sp, 0FF66h
  ld hl, CIEE ; wlacz obsluge klaw. "G"
  ld (CI+1), hl
  rst 10h  ; D7 80
  defb 80h
  ld hl, pod_date ; "data." tekst na ca80
  call print
  defb 42h ; PWYS
  call pob_date ;  pobranie liczb /daty/ DDmmRRRR
  rst 10h
  defb 80h
  ld a, 0FFh
  ld (0FE4Ah), a
  call wpis_daty ;
  jr c, kal_start ; data nie istnieje
  ld hl, wzorzec_daty
  ld de, 0FE00h
  ld bc, 9 ; tyle znakow ma wzorzec daty
  ldir      ; przesun
  ld hl, (0FE0bh) ; szukane lata

 oblicz_dzien:
  call spr_pol_daty ; czy szukana data <= od 4.10.1582 czy >= od 15.10.1582
  call wysw_czekaj ; na CA80
  call sprawdz_zgodnosc ;  data= data  + 1
  call kal3 ; sprawdz czy rok przestepny
 kal5:
  rst 10h
  defb 80h
  ld hl, pn ; poczatek nazwy dni
  ld a, (0FE00h)
  dec a
  ld e, a
  ld d, 0
  add hl, de ; 7 x bo 7. dni tygodnia
  add hl, de
  add hl, de
  add hl, de
  add hl, de
  add hl, de
  add hl, de
  call PRINT ;wyswietla tekst wg (HL)
  defb 61h ; PWYS
  ld b, 3
  call opoz_szuk; opoznienie
  jr c, pob_zlec   ; wcisnieto jakis klawisz
  ld de, 0FE02h ; wysw. dzien i miesiac
  ld a, (de)
  ld l, a
  dec de
  ld a, (de)
  ld h, a
  rst 20h ; E7 44 wysw. rej HL
  defb 44h
  ld hl,(0FE03h); rok
  rst 20h
  defb 40h
  ld hl, 0FFFBh ; cyfra wyswietlacza
  set 7, (hl)
  ld hl, 0FFFDh
  set 7, (hl)
  ld b, 3
  call opoz_szuk ; opoznienie
  jr c, pob_zlec
  jr kal5

pob_zlec: ; jesli A- obl. ilosci dni, C-obl. dzien tygodnia
  call CSTS
  jr nc, pob_zlec
  cp 0Ah ; klawisz A
  jr z, oblicz_il_dni;
  cp 0Ch ; klawisz C
  jp z, kal_start
  jr pob_zlec

oblicz_il_dni: ; obliczanie ilosci dni miedzy dwiema datami
  rst 10h
  defb 80h
  ld sp, 0FF66h
 kal8:
  ld hl, pod_date_od; tekst "data.od." na CA80
  call print
  defb 71h
  call pob_date ; pobranie daty "od"
  call wpis_daty
  jr c, kal8 ; bledna data
  ld hl, 0FE09h ; pobrana data FE09-dzien, 0A-m-c, 0B-lata, 0C- stulecie
  ld de, 0FE1Ah ; przesun do tego obszaru
  ld bc, 4 ; ile bajtow przesunac
  ldir
 kal82:
  rst 10h
  defb 80h
 kal_82_1:
  ld hl, pod_date_do ; tekst "data.do." na CA80
  call print
  defb 71h
  call pob_date ; pobiera date "do", wpis od FE1A-dzien, 1B-m-c, 1C-
  call wpis_daty   ;wpis od FE1A-dzien, 1B-m-c, 1C-rok/lata, 1D-stulecie
  jr c, kal82 ; bledna data
  call por_daty ; porownuje daty, jesli od < do , to OK , jesli od > do,
  ld hl, 1                           ; zamienia miejscami w buforze
  push hl
  push hl
  pop IY ; po kazdym zwiekszeniu dnia IY=IY+1
  pop ix
  dec ix ; ix=0, jesli il. dni > ffff, to ix=ix+1
  call wysw_czekaj;
  call sprawdz_zgodnosc ; dodaje dzien do dnia, az daty sie zgodza
  call wysw_dni
  jp pob_zlec

pob_date: ; pobranie daty do bufora FE02-FE05
         ; FE02-lata, 03-stulecie, 04-miesiac, 05-dzien
      ; czysc wysw. ca80   ; dat 28.VI.1987 w buf. zapisana tak 87 19 06 28
  ld hl, 0FE00h                ; potem data dublowana do FE09-28, 0A-07, 0B-87, 0C-19
  call clr_buf ; zerowanie obszaru / w CA88 kalkulator
  call pob_kl_dat
  jr c, pob_date ; blednie wpisano date

 pob_date1:
  call pob_kl_dat ;
  jr c, pob_date
  jr z, pob_date1
  cp 0Ah
  jr c, pob_date1

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
  rst 10h
  defb 80h
  ld c, 0
  call 1E0h
  defb 80h
  jr pob_kl_dat

 pob_kl_dat2:
  ld a, (hl)
  cp 0Fh ; max il. cyfr pobranych, ale licza sie tylko ostatnie 7 lub 8
  jr nc, pob_kl_dat
  ld a, c
  cp 0Ah ; tylko cyfry 0-9 !
  jr nc, pob_kl_dat
  ld a, (hl)
  or a
  jr nz, pob_kl_dat3
  rst 10h
  defb 80h

 pob_kl_dat3: ;
   call 1E0h
   defb 80h
   push hl
   call 0C56h ; wpis pobranej cyfry (rej. C) do bufora
   pop hl
   jr pob_kl_dat

 test_kl:   ;
  push af
  push hl

 yy: ; dobijanie kropek do wyswietlanej daty, bardziej czytelne
  ld hl, CYF4
  res 7, (hl)  ; kasowanie "." na wysw. ca80
  ld hl, CYF6
  res 7, (hl)
 xx:
  ld hl, CYF3
  set 7, (hl)   ; dodanie "."
  ld hl, CYF5
  set 7, (hl)
 zz:
  pop hl
  pop af
  cp 10h ; czy "G" - nowa data
  scf
  cp 12h ; klawisz "="
  jr z, przepisz_date
  or a
  ret nz
  ld c, 0h
  inc c
  ret

przepisz_date: ;dublowanie daty w RAM, do dalszych obliczen
  rst 10h ; D7 80
  defb 80h ;
  ld hl, 0FE05h
  ld de, 0FE09h
  ld a, (hl)
  ld (de), a
  dec hl
  inc de
  ld a, (hl)
  ld (de), a
  ld hl, (0FE02h)
  ld (0FE0bh), hl
  inc sp
  inc sp
  inc sp
  inc sp
  ret

por_daty: ; porownanie dat;  data2: 9.VIII.1992    data1: 15.XII.1987
  or a           ;                FE09 09               FE1A 15
  ld hl, (0FE0bh); rok            FE0A 08               FF1B 12
  ld de, (0FE1Ch); rok            FE0B 92               FF1C 87
  sbc hl, de     ;                FE0C 19               FF1D 19
  jr z, przep_2
  jr nc, przep_1 ;       bufor 1- do obl. il. dni: FE01 15
  jr zam_daty ;          jak i dnia tygodnia       FE02 12
                                 ;                FE03 87
 przep_2:                      ;                FE04 19
  or a
  ld hl, (0FE1Ah) ; miesiac i dzien - data "do" przy obl. il. dni
  push hl
  pop de
  ld hl, (0FE09h) ; miesiac i dzien -  data "do" przy obl. il.dni
  sbc hl, de
  jr c, zam_daty
  jr nz, przep_1 ; daty rozne
    ; daty takie same
  ld hl, data_ ; "daty =" takie same
  call print
  defb 62h
  rst 8 ; CF
  jp oblicz_il_dni

przep_1:
  ld hl, 0FE1Ah  ; skad
  ld de, 0FE01h  ; dokad             bufor 2       FE09 09
 przep_11:                    ;                 FE0A 08
  ld bc, 4      ; ile komorek                      FE0B 92
  ldir          ; przesun                          FE0C 19
  ret

zam_daty: ; zamiana dat miejscami w buforach
  ld hl, 0FE09h ; skad      bufor 2
  ld de, 0FE01h ; dokad     bufor 1
  ld bc, 4      ; ile komorek
  ldir          ; przesun
  ld hl, 0FE1Ah ; skad
  ld de, 0FE09h ; dokad
  jr przep_11

 przes_tekst: ;  wyswietlanie tekstu i przesuw /ca80
  ld (0FE10h), hl  ; adr. pocz. tekstu -przechowanie
 prz_tek1:      ; DE - koniec przesuwanego tekstu
  call przes ;
  ret c  ; powrot z podprogramu
  call hilo
  jr nc, prz_tek1
   ; koniec tekstu
  ld hl, (0FE10h) ; odtworzenie HL, pocz. tekstu
  jr prz_tek1

 wzorzec_daty: ;
  defb 6, 1, 1, 1, 0 ; 01.01.0001, 6-sobota
  defb 5,10h, 82h, 15h ; 05.10.1582
 wzor_daty_2:
  defb 05, 15h, 10h, 82h, 15h ; piatek, 15.10.1582

spr_date_1582: ;
  or a
  ld de, (0FE07h)
  sbc hl, de
  ret

zw_daty_10_1582:  ;  zwiekszenie daty w pazdzierniku 1582 r
  inc a
  daa
  cp c
  scf
  ccf
  jp z, wys_nie_ma_daty ;
  ret

wpis_daty: ;  ;czy podana data jest  wpisana prawidlowo
  ld hl, (0FE02h) ; rok >= 1 , mies. 1-12, luty 29 dni tylko jesli rok przestepny
  ld bc, 1 ; n.e. rozpoczela sie od 1.I.0001/sobota/, 5-14.10.1582 zmiana kalendarza
  sbc hl, bc
  jr c, wys_nie_ma_daty  ; wswietl "nie ma takiej daty"
  ld hl, 0FE0Ah ; miesiac
  ld a, (hl)
  cp 13h ; rok ma 12. miesiecy
  jr nc, wys_nie_ma_daty
  cp 0
  jr z, wys_nie_ma_daty
  ld de, TABM ; poczatek ograniczenia dni miesiaca /w CA80/
  call czy_luty ;  czy luty i rok przestepny
  dec a
  cp 0
  jr z, wys_nie_ma_daty
  cp d
  jr nc, wys_nie_ma_daty
  or a ; CY=0
  ld hl, (0FE02h) ; szukane lata
  ld bc, 1582h
  sbc hl, bc
  jr z, czy_5_14 ; czy lezy miedzy 5-14.X.1582 - daty nie ma
  or a
  ret

czy_5_14: ; nie ma dni pomiedzy 5-14.10.1582
  ld hl, (0FE04h); szuk. data: dzien i miesiac
  ld bc, 510h ; 5.X /5. pazdziernik / nie ma  dni 5.10-14.10.1582
  sbc hl, bc
  jr nc, wpis_wroc ; data < 5.10.1582
  or A  ; zeruj wskaznik CY, data < 5.10.1582, powrot po wyzerowaniu wskaznika CY
  ret

wpis_wroc:
  ld hl, (0FE04h) ; szukany dzien i miesiac
  ld bc, 1510h ; 15. pazdziernika
  sbc hl, bc
  ret nc  ; data >= 15.10.1582
   ; data miedzy 5 - 15.10.1582 , blad - nie ma dni pomiedzy 5-15.10.1582
 
wys_nie_ma_daty: ;  obsluga bledu daty na ca80
  ld de, nie_ma+12h ; koniec komunikatu
 n_m_d1:
  ld hl, nie_ma ; pocz. komunikatu
 n_m_d2:
  call przes_tekst  ; wysw. komunikat /przesuw tekstu/ na ca80 i czeka na nacisniecie klawisza
  jp kal_start

spr_pol_daty: ;  czy data jest do 4.10.1582 czy od 15.10.1582
  or a
  ld hl, (0FE0bh)
  ld de, 1582h ; rok w ktorym "zabrano" 10 dni 5-14 pazdz.
  sbc hl, de
  ret c  ; rok < niz 1582
  ld a, h
  adc a, l
  jr nz, wzor_2 ; rok > niz 1582
  ld bc, 1005h ; 5.X
  ld hl, 0FE0Ah
  ld a, (hl)
  cp b
  ret c ; < niz pazdziernik
  dec hl  ; dzien
  ld a, (hl)
  cp c
  ret c ; < niz 5
 wzor_2: ;
  ld hl, wzor_daty_2  ; ld hl, 8228 ; 15.X.1582
  ld de, 0FE00h
  ld bc, 5
  ldir
  ret

zw_dz_tyg: ;  zwiekszenie dnia tygodnia o nastepny
  ld hl, 0FE00h
  inc (hl)
  ld a, (hl)
  cp 8  ; czy nastepny po niedzieli
  ret nz
  ld (hl), 1 ; poniedzialek
  ret

sprawdz_zgodnosc:
  ld de, 0FE09h ; dzien poszukiwany
  ld hl, 0FE01h
  call por_zgod ;
  jr nz, sprawdz_zgodnosc
  inc hl  ; miesiac
  inc de
  call por_zgod
  jr nz, sprawdz_zgodnosc
  inc hl  ; rok
  inc de
  call por_zgod
  jr nz, sprawdz_zgodnosc
  inc hl
  inc de  ; setki lat
 spr_zg1:
  ld a, (de)
  cp (hl)
  ret z
  call zw_stulecia ;
  jr spr_zg1

por_zgod: ;
  ld a, (de)
  cp (hl)
  call nz, zw_date ;
  ret

zw_date: ; zwiekszenie dnia miesiaca o jeden dzien
  inc iy ; potrzebne do oblicz. ilosci dni pomiedzy datami
  push af
  exx
  ld de, TABM ; tabela dni w m-cu - od 32Dh/CA80/ max. ilosci dni w miesiacu
  call zw_dz_tyg
  inc hl ; wskazuje dzien
  inc hl ; wskazuje miesiac
  ld a, (hl)
  call czy_luty ;
  cp d
  jr c, zw_2
  ld a, 1
  ld (hl), a
  inc hl
  ld a, (hl)
  inc a
  daa
  cp 13h
  jr c, zw_2
  ld a, 1
  ld (hl), a
  inc hl
  ld a, (hl)
  inc a
  daa
  ld (hl), a
  cp 0
  jr nz, zw_3
  inc hl
  ld a, (hl)
  inc a
  daa
 zw_2:
  ld (hl), a
  call spr_dni_5_14 ; jesli 5.10.1582 to zwieksz na 15.10.1582 - przy obliczniu ilosci dni
 zw_3:
  exx
  pop af
  ret

spr_rok_przest: ;  sprawdza czy rok przestepny
  ld b, 4 ; rok przestepny co 4. lata
 spr_r1:
  add a, b
  daa
  jr nc, spr_r1
  ret

czy_luty:  ; spr. czy luty i rok przestepny
  cp 0Ah
  jr c, czy_luty_1
  sub 6
 czy_luty_1:
  dec a
  add a, e
  ld e, a
  ld a, (de)
  ld d, a
  push hl
  ld a, (hl)
  cp 2 ; czy luty
  jr nz, czy_luty_2
  inc hl
  ld a, (hl)
  call spr_rok_przest
  cp 0
  jr nz, czy_luty_2
  ld a, (hl)
  cp 0
  jr nz, czy_luty_4
  inc hl
  ld a, (hl)
  cp 17h
  jr nc, czy_luty_3

 czy_luty_4:
  or a
  ld a, d
  inc a
  daa
  ld d, a

 czy_luty_2:
  pop hl
  or a
  dec hl ; dzien
  ld a, (hl)
  inc a
  daa
  ret

czy_luty_3:
  cp 20h ; czy rok 2000
  jr z, czy_luty_4
  cp 24h
  jr z, czy_luty_4
  jr czy_luty_2

zw_stulecia: ;  zwieksz stulecie o 1
  call zw_stulecie ;
  ld (hl), a
  call zm_dz_tyg;
  ld a, (hl)
  cp 16h
  ret c ; mniejsze niz 1600
  ret z
  cp 20h
  ret z
  cp 24h
  ret z
  call zm_dz_tyg ;  dzien tygod - 1
  ret

zm_dz_tyg: ; dzien tygodnia -1
  push hl
  ld hl, 0FE00h
  dec (hl)
  ld a, (hl)
  cp 0
  jr nz, zm_dz_tyg_1
  ld (hl), 7
 zm_dz_tyg_1:
  pop hl
  ret

kal3: ; sprawdz czy rok przestepny
  or a
  ld hl, 0FE02h ; miesiac
  ld a, (hl)
  cp 3 ; czy marzec
  ret nc  ; nie marzec
  inc hl
  ld a, (hl)
  cp 0
  ret nz
  inc hl
  ld a, (hl)
  cp 17h ; czy rok 1700
  ret c
  cp 20h
  ret z
  cp 24h
  ret z
  call zw_dz_tyg ;zwieksz dzien tygodnia
  ret

wysw_czekaj: ;
  ld hl, czekaj
  call PRINT  ; wyïswietla "czekaj"
  defb 61h
  ret

zw_stulecie: ;  zwieksz setki lat o +1
  ld bc, 8EACh ; 36524 dni w stuleciu (?)
  add iy, bc
  jr nc, nzw
     ; jesli il. dni > FFFFh to zwieksz IX - potrzebne do mnozenia
  or a
  ld a, ixL  ;defb 0DDh  ;defb 7Dh ; ld a; ixL DD7D
  inc a
  daa
  ld ixL, a  ;defb 0DDh   ;defb 6Fh ; ld ixL, a   dd 6F
 nzw: ; nie zwiekszaj ix, tylko setki lat
  or a
  ld a, (hl)
  inc a
  daa
  ret

spr_dni_5_14: ; zwieksz. daty z 5.10.1582 na 15.10.1582 przy obl. dni
  ld hl, (0FE01h)   ; zmiana kalendarza z julianskiego na gregorianski
  ld de, 1005h ; 5.X    ; 4.X.1582/czwartek/, nastepny to 15.10.1582/piatek
  sbc hl, de
  ret nz
  ld hl, (0FE03h)
  ld de, 1582h
  sbc hl, de
  ret nz
  ld a, 15h ; 15-ty dzien pazdziernika
  ld (0FE01h), a
  dec IY
  ret 

wysw_dni:
  call przelicz_dni ; WYJ: BUFX
  ld a, ixL  ;defb 0ddh  ;defb 7dh ; dd 7d ld a, ixL - mlodszy bajt IX
  cp 0
  jr nz, wysw_dni1
  call w_dni1
  ret

wysw_dni1: ; il. dni > od FFFFh
  rst 10h
  defb 80h ; czysc wysw. ca80
  ld hl, bufZ
  call clr_buf
  ld hl, bufX
  ld de, bufZ
  ld bc, 5h
  ldir ; przesun/zapamietanie
  ld a, ixL  ;defb 0ddh  ;defb 7dh ; dd 7d ld a, ixL - mlodszy. bajt IX
  ld (bufY+2), a ; wpis do bufY - mnoznik
  cp 0Ah
  jr c, cyf_2 ; ile razy mnozyc przez 65536 /FFFFh/
  ld hl, 2
  jr cyf_wp  ; wpisz cyfre do bufora
 cyf_2:
  ld hl, 1
 cyf_wp:
  ld (bufY),hl
  call clr_bufX ; zeruj bufor X
  ld hl, stala_FFFF
  ld de, bufX
  ld bc, 5
  ldir
    ; mnozenie
  call mnoz ; razy - bufX=bufX * bufY
  ld hl, bufY
  call clr_buf
  ld hl, bufZ
  ld de, bufY
  ld bc, 5
  ldir
  call dodaj ; dodaj il. dni przelicz. z IY do bufora X
  ld hl, bufX
  call wys_buf ; wysw. il. dni na ca80
  call w_dni1
  ret

przelicz_dni: ; wysw. dni na ca80 i na lcd
  call clr_bufX ; czysc bufor X do obliczen il. dni
  push IY
  pop hl ; ilosc przezytych dni hexadecymalnie, max 65535, reszta mnoznik w IX
  dec hl ; gdyz np. od 1.01 do 3.01 sa dwa czy trzy dni przezyte? pierwszy drugi i trzeci dzien ?
  call przelicz ;  ilosc dni w postaci dziesietnej na ca80
  ret           ;  w buforze  FE10-FE14

w_dni1: ; wysw. "dn." na ca80 i il. dni na lcd
  ld hl, dn ; "dn." przed iloscia dni na ca80
  call PRINT ; wysw. "dn." na CA80
  defb 26h ; PWYSW
  ret

PRZES: ; przesuwa tekst na wyœwietlaczu ca80, jesli wcis. jakis klawisz to wyjscie z procedury
  LD C, (HL)
  CALL COM ; wyœwietla rej. C
   defb 80h; to jest parametr PWYœ 80
  LD B, 1H ; wartoœæ opóŸnienia
  CALL opoz_szuk ; tu ewentualne wyjsciej jesli wcisnieto jakis klaw.
  RET


CIEE: ; obsluga, gdy wcisniemy klawisz G - powrot na pocz. programu
  call CIM   ;jak CD F3 FF
  push AF
  cp 10H     ;Kod klaw. "G"
  jp z, kal_start
  pop AF
  ret

     ;  teksty  na CA80
pod_date: ; "data"
     defb 5eh, 77h, 31h, 77h, 0FFh
czekaj:
     defb 39h, 5bh, 79h, 78h, 77h, 0Fh, 0FFh ; "czekaj
nie_ma: ; "nie ma takiej daty"
     defb  54h, 30h, 79h, 0h, 54h, 77h, 0h, 31h, 77h, 78h,30h, 79h, 0Fh,0h
     defb  5eh,77h, 31h, 0EEh, 0
pn: ; poniedzia³ek
     defb 73h, 5ch, 54h, 30h, 79h, 5eh, 0FFh
wt: ; wtorek
     defb 3eh, 31h, 5ch, 50h, 79h, 78h, 0FFh
sr:  ; œroda
     defb 6dh, 50h, 5ch, 5eh, 77h, 0h, 0FFh
czw: ; czwartek
     defb 39h, 5bh, 1ch, 77h, 50h,31h, 0FFh
pt: ; pi¹tek
     defb 73h, 30h, 0F7h,31h, 79h, 78h, 0FFh
so: ; sobota
     defb 6dh, 5ch, 7ch, 5ch, 31h, 77h, 0FFh
nd: ; niedziela
     defb 37h, 30h, 79h, 5eh, 5bh, 30h, 0FFh
obl_il_dni: ; "obl. ilosci dni"
     defb 5ch, 7ch, 0b8h, 4, 38h, 5ch, 6dh, 58h, 10h, 5eh, 54h, 10h,
pod_date_od: ; "data od."
     defb 5eh, 77h, 31h, 77h, 0, 5ch, 0DEh, 0FFh
pod_date_do: ; "data do"
     defb 5eh, 77h, 31h, 77h, 0, 5eh, 5ch, 0FFh
data_: defb 5Eh, 77h, 31h, 77h, 0, 48h, 255
dn: ; "dn."
    defb 5eh, 0d4h, 0FFh

opoz_szuk:
  push hl                ; i jesli wcisnieto jakis klawisz, wyjscie z procedury
 opoz_szuk1:
  call 1A0Eh; opóŸnienie ok. 0,4 s
  call CSTS ; pobierz klawisz
  jr c,wyj1
  djnz opoz_szuk1
 wyj1:
  pop hl
  ret

przelicz:
  ld bc, 0d8F0h ; (-10.000), uzupe³nienie do 2 liczby 10.000
  call zamien_16
  ld bc, 0FC18h ; (-1.000, uzupe³. do 2 liczby 1.000
  call zamien_16
  ld bc, 0FF9ch ; (-100)
  call zamien_16
  ld bc, 0FFF6h ; (-10)
  call zamien_16
  ld a, l
  ld hl, 0FE10h ; pocz¹tek bufora
  push hl
  call wpis_buf
  call ile_cyfr
  pop hl
  call wys_buf
  ret

ile_cyfr: ; sprawdza ile cyfr znaczacych w buforze
  ld hl, 0FE10h
  push hl
  ld hl, 0FE14h ; 4. i 5. cyfra
  ld a, (hl)
  cp 0
  jr z, dal
  jr cyfr_5
 dal:
  dec hl
  ld a, (hl)
  cp 0
  jr z, dal11
  cp 10h ; liczba 3. cyfrowa
  jr c, cyfry_3
  jr cyfry_4
 dal11:
  dec hl
  ld a, (hl)
  cp 10h
  jr nc, cyfry_2   ; liczba 2. cyfrowa
         ; jedna cyfra
  ld a, 1

pow_cyfr:
  pop hl
  ld (hl), a
  ret
cyfr_5:
  ld a, 5
  jr pow_cyfr
cyfry_4:
  ld a, 4
  jr pow_cyfr
cyfry_3:
  ld a, 3
  jr pow_cyfr
cyfry_2:
  ld a, 2
  jr pow_cyfr

zamien_16: ; zamiana liczby 16. na 10.
  xor a
 zam_1:
  ld e, l
  ld d, h
  inc a
  add hl, bc
  jr c, zam_1
  dec a
  ld l, e
  ld h, d
  push hl
  ld hl, 0FE10h ;pocz. bufora
  call wpis_buf
  pop hl
  ret

stala_FFFF: defb 5, 1, 36h, 55h, 6 ; 65536

   defb 0DDh, 0E2h
    defm " KALENDARZ bezLcd" , 255 ; nazwa
 


