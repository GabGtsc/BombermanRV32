    .data

    .eqv SCREEN_START 0xFF000000
    .eqv SCREEN_END 0xFF012C00
    .text
    .include "source/draw_square.s"
    .globl main
main:
# Preenche a tela de vermelho
    li     t1, SCREEN_START # endereco inicial da Memoria VGA - Frame 0
    li     t2, SCREEN_END # endereco final
    li     t3,0x00000000 # cor vermelho|vermelho|vermelhor|vermelho
LOOP:
    beq    t1,t2,FORA    # Se for o último endereço então sai do loop
    sw     t3,0(t1)      # escreve a word na memória VGA
    addi   t1,t1,4       # soma 4 ao endereço'
    j      LOOP          # volta a verificar
FORA:
    li a0, 0x0101
    li a1, 0xFF
    call draw_square 

    li a0, 0x0202
    call draw_square


    li     a7, 32
    li     a0, 5000
    ecall   #sleep 5000
    li     a7, 10
    li     a0, 0
    ecall                #exit



