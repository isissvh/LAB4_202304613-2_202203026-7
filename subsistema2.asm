# DESAFIO 2 - Validacion de Llaves de Sombras

.data
llaves:             .space 80

msg_m:              .asciz "Ingrese cantidad de llaves (1-20): "
msg_llave:          .asciz "Ingrese llave de 32 bits en decimal: "
msg_error:          .asciz "Entrada invalida. Intente nuevamente.\n"
hex_prefix:         .asciz "0x"
msg_aceptada:       .asciz " -> LLAVE ACEPTADA - PORTAL ABIERTO\n"
msg_falla_paridad:  .asciz " -> RECHAZADA (Fallo de Paridad)\n"
msg_falla_patron:   .asciz " -> RECHAZADA (Sobrecarga de Patron)\n"

.text
.globl main

main:
    la a0, msg_m
    li a7, 4
    ecall

    li a7, 5
    ecall

    li t0, 1
    blt a0, t0, error

    li t0, 21
    bge a0, t0, error

    mv s1, a0              # s1 = m
    la s0, llaves          # s0 = base del arreglo
    li s2, 0               # s2 = indice

leer_llaves:
    bge s2, s1, procesar_llaves

    la a0, msg_llave
    li a7, 4
    ecall

    li a7, 5
    ecall

    slli t0, s2, 2
    add t0, s0, t0
    sw a0, 0(t0)

    addi s2, s2, 1
    j leer_llaves

procesar_llaves:
    li s2, 0

loop_llaves:
    bge s2, s1, fin_programa

    slli t0, s2, 2
    add t0, s0, t0
    lw s3, 0(t0)           # s3 = llave actual

    la a0, hex_prefix
    li a7, 4
    ecall

    mv a0, s3
    li a7, 34              # imprimir entero en hexadecimal
    ecall

    mv a0, s3
    jal ra, validar_paridad_impar
    beq a0, zero, llave_falla_paridad

    mv a0, s3
    jal ra, validar_sin_patron_111
    beq a0, zero, llave_falla_patron

    la a0, msg_aceptada
    li a7, 4
    ecall
    j siguiente_llave

llave_falla_paridad:
    la a0, msg_falla_paridad
    li a7, 4
    ecall
    j siguiente_llave

llave_falla_patron:
    la a0, msg_falla_patron
    li a7, 4
    ecall

siguiente_llave:
    addi s2, s2, 1
    j loop_llaves

# Retorna a0 = 1 si la cantidad de bits encendidos es impar; 0 si es par.
validar_paridad_impar:
    mv t0, a0              # copia de la llave
    li t1, 0               # acumulador de paridad
    li t2, 0               # contador de bits revisados
    li t3, 32

paridad_loop:
    beq t2, t3, paridad_fin

    andi t4, t0, 1         # aisla bit menos significativo
    xor t1, t1, t4         # alterna la paridad si el bit es 1
    srli t0, t0, 1         # siguiente bit

    addi t2, t2, 1
    j paridad_loop

paridad_fin:
    mv a0, t1
    jr ra

# Retorna a0 = 1 si NO aparece el patron 111; 0 si aparece.
validar_sin_patron_111:
    mv t0, a0
    srli t1, t0, 1
    and t2, t0, t1
    srli t1, t0, 2
    and t2, t2, t1

    bne t2, zero, patron_falla

    li a0, 1
    jr ra

patron_falla:
    li a0, 0
    jr ra

error:
    la a0, msg_error
    li a7, 4
    ecall
    j main

fin_programa:
    li a7, 10
    ecall
