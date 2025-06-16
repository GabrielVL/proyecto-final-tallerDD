.section .text, "ax"    
.global start           


.equ PADDLE_X, 0x10000000       @ Posición X de la paleta (16 bits)
.equ PADDLE_Y, 0x10000004       @ Posición Y de la paleta (fija, 16 bits)
.equ BALL_X, 0x10000008         @ Posición X de la bola (16 bits)
.equ BALL_Y, 0x1000000C         @ Posición Y de la bola (16 bits)
.equ BALL_VX, 0x10000010        @ Velocidad X de la bola (16 bits con signo)
.equ BALL_VY, 0x10000014        @ Velocidad Y de la bola (16 bits con signo)
.equ BLOCK_MAP, 0x10001000      @ Cuadrícula de bloques (10x5, 1 byte: 0=vacío, 1=normal)
.equ PADDLE_DIR, 0x10000018     @ Dirección de la paleta (1=derecha, -1=izquierda)

start:
    @ Inicializa el estado del juego
    bl init_game

game_loop:
    @ Actualiza la posición de la paleta
    bl update_paddle

    @ Actualiza la posición de la bola
    bl update_ball

    @ Verifica colisiones
    bl check_collisions

    @ Verifica si el juego terminó
    bl check_game_state

    @ Vuelve al bucle principal
    b game_loop

@ Inicializa el estado del juego
init_game:
    @ Establece la posición de la paleta (centro, parte inferior)
    mov r0, #144        @ X = (320 - 32) / 2
    mov r1, #232        @ Y = 240 - 8
    ldr r2, =PADDLE_X
    str r0, [r2]
    ldr r2, =PADDLE_Y
    str r1, [r2]
    mov r0, #1          @ Dirección inicial: derecha
    ldr r2, =PADDLE_DIR
    str r0, [r2]

    @ Establece la posición inicial de la bola (centro, encima de la paleta)
    mov r0, #156        @ X = 320 / 2
    mov r1, #200        @ Y
    ldr r2, =BALL_X
    str r0, [r2]
    ldr r2, =BALL_Y
    str r1, [r2]

    @ Establece la velocidad inicial de la bola
    mov r0, #2          @ vx = 2
    mov r1, #-2         @ vy = -2
    ldr r2, =BALL_VX
    str r0, [r2]
    ldr r2, =BALL_VY
    str r1, [r2]

    @ Inicializa el mapa de bloques (10x5, todos normales)
    ldr r0, =BLOCK_MAP
    mov r1, #50         @ 10x5 bloques
    mov r2, #1          @ Bloque normal
init_blocks_loop:
    strb r2, [r0], #1
    subs r1, r1, #1
    bne init_blocks_loop
    bx lr

@ Actualiza la posición de la paleta (movimiento simulado)
update_paddle:
    @ Carga la posición X actual y la dirección
    ldr r0, =PADDLE_X
    ldr r1, [r0]
    ldr r2, =PADDLE_DIR
    ldr r3, [r2]
    @ Mueve la paleta según la dirección
    add r1, r1, r3, lsl #2  @ X += dir * 4
    @ Verifica los límites
    cmp r1, #0
    movlt r1, #0            @ Limita en el borde izquierdo
    mvneq r3, r3            @ Invierte dirección
    cmp r1, #288            @ 320 - 32 (ancho de la paleta)
    movgt r1, #288          @ Limita en el borde derecho
    mvneq r3, r3            @ Invierte dirección
    @ Almacena los nuevos valores
    str r1, [r0]
    str r3, [r2]
    bx lr

@ Actualiza la posición de la bola
update_ball:
    ldr r0, =BALL_X
    ldr r1, =BALL_Y
    ldr r2, =BALL_VX
    ldr r3, =BALL_VY
    @ Carga los valores actuales
    ldr r4, [r0]        @ X
    ldr r5, [r1]        @ Y
    ldr r6, [r2]        @ vx
    ldr r7, [r3]        @ vy
    @ Actualiza la posición
    add r4, r4, r6      @ X += vx
    add r5, r5, r7      @ Y += vy
    @ Verifica los límites de la pantalla
    cmp r4, #0
    mvnlt r6, r6        @ Invierte vx si X < 0
    movlt r4, #0
    cmp r4, #312        @ 320 - 8
    mvngt r6, r6        @ Invierte vx si X > 312
    movgt r4, #312
    cmp r5, #0
    mvnlt r7, r7        @ Invierte vy si Y < 0
    movlt r5, #0
    cmp r5, #232        @ 240 - 8
    bgt ball_out        @ La bola salió por la parte inferior
    @ Almacena los nuevos valores
    str r4, [r0]
    str r5, [r1]
    str r6, [r2]
    str r7, [r3]
    bx lr
ball_out:
    @ Marca el fin del juego (placeholder)
    b game_over

@ Verifica colisiones con la paleta y los bloques
check_collisions:
    @ Verifica colisión con la paleta
    ldr r0, =BALL_X
    ldr r1, [r0]        @ X de la bola
    ldr r0, =BALL_Y
    ldr r2, [r0]        @ Y de la bola
    ldr r0, =PADDLE_X
    ldr r3, [r0]        @ X de la paleta
    ldr r0, =PADDLE_Y
    ldr r4, [r0]        @ Y de la paleta
    cmp r2, r4          @ Y de la bola >= Y de la paleta
    blt check_blocks
    cmp r1, r3
    blt check_blocks
    add r3, r3, #32     @ Ancho de la paleta
    cmp r1, r3
    bgt check_blocks
    @ La bola golpeó la paleta, invierte vy
    ldr r0, =BALL_VY
    ldr r1, [r0]
    mvn r1, r1
    str r1, [r0]
check_blocks:
    @ Verifica colisiones con bloques
    ldr r0, =BALL_X
    ldr r1, [r0]        @ X de la bola
    ldr r0, =BALL_Y
    ldr r2, [r0]        @ Y de la bola
    @ Convierte a coordenadas de la cuadrícula
    lsr r3, r1, #5      @ X del bloque = X de la bola / 32
    lsr r4, r2, #4      @ Y del bloque = Y de la bola / 16
    @ Verifica si está dentro de la cuadrícula
    cmp r3, #10
    bge end_collisions
    cmp r4, #5
    bge end_collisions
    @ Calcula el índice del bloque
    mov r5, #10
    mul r0, r4, r5      @ Y * 10
    add r4, r0, r3      @ Índice = Y * 10 + X
    ldr r5, =BLOCK_MAP
    ldrb r6, [r5, r4]   @ Obtiene el tipo de bloque
    cmp r6, #0
    beq end_collisions
    @ Golpeó un bloque, elimínalo
    mov r7, #0
    strb r7, [r5, r4]
    @ Invierte la dirección de la bola (simplificado: invierte vy)
    ldr r0, =BALL_VY
    ldr r1, [r0]
    mvn r1, r1
    str r1, [r0]
end_collisions:
    bx lr

@ Verifica el estado del juego
check_game_state:
    @ Verifica si todos los bloques fueron destruidos
    ldr r0, =BLOCK_MAP
    mov r1, #50
check_block_loop:
    ldrb r2, [r0], #1
    cmp r2, #0
    movne r0, #0        @ No completado
    bxne lr
    subs r1, r1, #1
    bne check_block_loop
    @ Nivel completado
    b level_complete
    bx lr

game_over:
    @ Placeholder: reinicia el juego
    b start

level_complete:
    @ Placeholder: reinicia para el siguiente nivel
    b init_game

.end