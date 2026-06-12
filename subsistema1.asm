# DESAFIO 1 - Secuencia de Pell recursiva

.data
msg_k:          .asciz "Ingrese cantidad de frecuencias (3-15): "
msg_n:          .asciz "Ingrese intensidad n: "
msg_out_a:      .asciz "Intensidad ["
msg_out_b:      .asciz "] -> Pulso de estabilizacion: "
msg_error:      .asciz "Entrada invalida. Intente nuevamente.\n"
newline:        .asciz "\n"

.text
.globl main

main:
    la a0, msg_k
    li a7, 4
    ecall

    li a7, 5
    ecall

    li t0, 3
    blt a0, t0, error

    li t0, 16
    bge a0, t0, error

    mv s0, a0              # s0 = k
    li s1, 0               # s1 = contador de intensidades procesadas

loop_intensidades:
    bge s1, s0, fin_programa

    la a0, msg_n
    li a7, 4
    ecall

    li a7, 5
    ecall

    blt a0, zero, error
    mv s2, a0              # s2 = n original

    jal ra, pell
    mv s3, a0              # s3 = P_n

    la a0, msg_out_a
    li a7, 4
    ecall

    mv a0, s2
    li a7, 1
    ecall

    la a0, msg_out_b
    li a7, 4
    ecall

    mv a0, s3
    li a7, 1
    ecall

    la a0, newline
    li a7, 4
    ecall

    addi s1, s1, 1
    j loop_intensidades

# pell(n)
# Casos base: P_0 = 0, P_1 = 1
# Caso recursivo: P_n = 2 * P_(n-1) + P_(n-2)
pell:
    beq a0, zero, pell_base_cero

    li t0, 1
    beq a0, t0, pell_base_uno

    addi sp, sp, -12
    sw ra, 8(sp)
    sw s0, 4(sp)
    sw s1, 0(sp)

    mv s0, a0              # s0 = n

    addi a0, s0, -1
    jal ra, pell
    mv s1, a0              # s1 = P_(n-1)

    addi a0, s0, -2
    jal ra, pell           # a0 = P_(n-2)

    slli s1, s1, 1         # 2 * P_(n-1), usando shift left
    add a0, s1, a0         # P_n

    lw s1, 0(sp)
    lw s0, 4(sp)
    lw ra, 8(sp)
    addi sp, sp, 12
    jr ra

pell_base_cero:
    li a0, 0
    jr ra

pell_base_uno:
    li a0, 1
    jr ra

error:
    la a0, msg_error
    li a7, 4
    ecall
    j main

fin_programa:
    li a7, 10
    ecall
