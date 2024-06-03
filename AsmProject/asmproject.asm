;* * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*  Imi�: Mateusz                                        *
;*  Nazwisko: Dworaczyk                                  *
;*  Grupa: 5                                             *
;*  Sekcja: 1                                            *
;*  Temat projektu: iPot - twoja inteligentna doniczka   *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * *



;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*  Opis:                                                          *
;*                                                                 *
;*      Funkcja s�u�y do zmiany warto�ci pikseli                   *
;*      na podstawie koloru podanego przez u�ytkownika.            *
;*      Zmiana koloru odbywa si� po przeliczeniu                   *
;*      sumy kwadrat�w z r�nic warto�ci odczytanej                *
;*      oraz podanej przez u�ytkownika oraz por�wnaniu             *
;*      do zadanego zakresu.                                       *
;*      Piksele,kt�re spe�niaj� za�o�enia, zostaj�                 *
;*      zamienione na czarne, czyli usuni�te z obrazu.             *
;*                                                                 *
;*  Parametry wej�ciowe:                                           *
;*                                                                 *
;*       Wska�nik na pocz�tek tablicy warto�ci odczytanych - rcx   *
;*       Wska�nik na pocz�tek tablicy warto�ci podanych - rdx      *
;*       Warto�� zakresu, czyli threshold - r8                     *
;*                                                                 *
;*  Parametry wyj�ciowe:                                           *
;*                                                                 *
;*       Zmieniona warto�� pikseli znajduje si� pod adresem        *
;*       tablicy przekazanym do funkcji assemblerowej - rcx        *
;*                                                                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

.data
.code

revaluePixelsAsm proc
    mov r12b, 0                 ; Clear r12b
    xor rax,rax                 ; Zero rax
    xorps xmm2, xmm2            ; Zero xmm2
    xorps xmm1, xmm1            ; Zero xmm1
    xorps xmm0, xmm0            ; Zero xmm0

blue_start:                      
    mov al, byte ptr [rcx + 2]  ; Load blue channel into al
    movd xmm2, rax              ; Move blue channel into xmm2
    mov al, byte ptr [rdx + 2]  ; Load blue to remove
    movd xmm3, rax              ; Move blue to remove into xmm3
    psubd xmm2, xmm3            ; Substract blue to remove from blue

    pmuldq xmm2, xmm2           ; Square the substracted value
    jmp green_start             ; Jump to green color

green_start:                    
    xor rax, rax                ; Zero rax 
    xorps xmm3, xmm3            ; Zero xmm3
    mov al, byte ptr [rcx + 1]  ; Load green channel into al 
    movd xmm1, rax              ; Move green channel into xmm1 
    mov al, byte ptr [rdx + 1]  ; Load green to remove
    movd xmm3, rax              ; Move green to remove into xmm3
    psubd xmm1, xmm3            ; Substract green to remove from green
    
    pmuldq xmm1, xmm1           ; Square the substracted value
    jmp red_start               ; Jump to red color

red_start:   
    xor rax,rax                 ; Zero rax 
    xorps xmm3, xmm3            ; Zero xmm3
    mov al, byte ptr [rcx]      ; Load red channel into al 
    movd xmm0, rax              ; Move red channel into xmm0 
    mov al, byte ptr [rdx]      ; Load red to remove
    movd xmm3, rax              ; Move red to remove into xmm3
    psubd xmm0, xmm3            ; Substract red to remove from red
    
    pmuldq xmm0, xmm0           ; Square the substracted value
    jmp last_part               ; Jump to last color

last_part:
    xorps xmm3, xmm3            ; Zero xmm3
    xor rax, rax                ; Zero rax

                                ; Add them all together
    paddq xmm0, xmm1
    paddq xmm0, xmm2

    
    mov rax, r8                 ; Move threshold to rax

    movd xmm3, rax              ; Move into xmm3
    pmuldq xmm3, xmm3           ; Square threshold
    pcmpgtd xmm3, xmm0          ; Checking if treshold is greater than our sum
    ptest xmm3, xmm3            ; Move the flag into main cpu flags register
    jz exit                     ; Jump to exit

                                ; Set color to black
    mov [rcx], r12b
    mov [rcx + 1], r12b
    mov [rcx + 2], r12b

exit:
    ret                               ; return

revaluePixelsAsm endp
end
