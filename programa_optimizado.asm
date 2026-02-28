.data
    vector_x: .word 1, 2, 3, 4, 5, 6, 7, 8
    vector_y: .space 32
    const_a:  .word 3
    const_b:  .word 5
    tamano:   .word 8

.text
.globl main

main:
    # Inicialización
    la   $s0, vector_x        # puntero X
    la   $s1, vector_y        # puntero Y
    lw   $t0, const_a         # A
    lw   $t1, const_b         # B
    lw   $t2, tamano          # tamaño
    
    sll  $t2, $t2, 2          # tamaño en bytes (n * 4)
    addu $t3, $s0, $t2        # dirección final de X

loop:
    beq  $s0, $t3, fin        # si puntero X llegó al final, salir

    lw   $t4, 0($s0)          # cargar X[i]
    addi $s0, $s0, 4          # avanzar puntero X (rellena delay load)

    mul  $t5, $t4, $t0        # X[i] * A
    addu $t5, $t5, $t1        # + B

    sw   $t5, 0($s1)          # guardar resultado
    addi $s1, $s1, 4          # avanzar puntero Y

    j loop

fin:
    li $v0, 10
    syscall