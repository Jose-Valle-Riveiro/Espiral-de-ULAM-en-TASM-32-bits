.model small
.stack
.data
    cadena DB ' Ingrese la cantidad de puntos $'
    cadena2 DB ' ERROR: vuelva a ingresar el numero $'
    acumulador DB 3 dup(0)
    b DB 100, 10, 1
    cantPuntos DW 0
    puntoX DW 0
    puntoY DW 0
    direccion DB 0
    contador DW 0
    limite DW 1
    ciclos DW 0
    output db ' (    ,    )    $', 0Dh, 0Ah, '$'  ; Nuevo formato con espacio para el número

.code
programa:
    MOV AX, @data
    MOV DS, AX

    MOV DX, OFFSET cadena
    MOV AH, 09H
    INT 21H

INICIALIZAR_CONTADOR:
    MOV DI, 0

CAPTURAR_NUMERO:
    MOV AX, 0
    MOV AH, 01H
    INT 21H

    CMP AL, 48
    JL LIMPIAR_ACUMULADOR
    CMP AL, 57
    JA LIMPIAR_ACUMULADOR

    MOV acumulador[di], al
    SUB acumulador[di], 30H
    INC DI
    CMP DI, 3
    JB CAPTURAR_NUMERO

    MOV SI, 2
    MOV DI, 0
    JMP CONVERTIR_NUMERO

CONVERTIR_NUMERO:
    MOV AX, 0
    MOV AL, acumulador[SI]
    MUL b[SI]
    JO LIMPIAR_ACUMULADOR
    JC LIMPIAR_ACUMULADOR
    ADD cantPuntos, AX
    JC LIMPIAR_ACUMULADOR
    DEC SI
    INC DI
    CMP DI, 3
    JB CONVERTIR_NUMERO
	CMP cantPuntos, 100
	JA LIMPIAR_ACUMULADOR
    JMP IMPRIMIR_NUMERO

LIMPIAR_ACUMULADOR:
    MOV AH, 0FH
    INT 10H
    MOV AH, 0
    INT 10H
    MOV cantPuntos, 0
    MOV acumulador[0], 0
    MOV acumulador[1], 0
    MOV acumulador[2], 0
    MOV DI, 0
    MOV DX, OFFSET cadena2
    MOV AH, 09H
    INT 21H
    JMP CAPTURAR_NUMERO

IMPRIMIR_NUMERO:
    MOV puntoX, 0
    MOV puntoY, 0
    MOV BX, 1                  ; Número inicial = 1
    CALL imprimir_coordenadas
    CMP cantPuntos, 1
    JA ContinuarProceso
    JMP Finalizar

ContinuarProceso:
    MOV direccion, 0
    MOV contador, 0
    MOV limite, 1
    MOV ciclos, 0
    MOV SI, 2

loop_spiral:
    MOV AX, contador
    CMP AX, limite
    JB move_in_current_dir

    INC direccion
    AND direccion, 03h
    MOV contador, 0
    INC ciclos
    CMP ciclos, 2
    JNE no_increment_limite
    INC limite
    MOV ciclos, 0

no_increment_limite:
    INC contador
    JMP update_coords

move_in_current_dir:
    INC contador

update_coords:
    CMP direccion, 0
    JE derecha
    CMP direccion, 1
    JE arriba
    CMP direccion, 2
    JE izquierda
    JMP abajo

derecha:
    INC puntoX
    JMP print_coords

arriba:
    INC puntoY
    JMP print_coords

izquierda:
    DEC puntoX
    JMP print_coords

abajo:
    DEC puntoY

print_coords:
    MOV BX, SI                 ; Cargar número actual
    CALL imprimir_coordenadas
    INC SI
    CMP SI, cantPuntos
    JBE loop_spiral
	
Finalizar:
    MOV AH, 4CH
    INT 21H

imprimir_coordenadas PROC
    PUSH AX
    PUSH CX
    PUSH DX
    PUSH BX
    PUSH SI
    PUSH DI
    
    ; Convertir coordenada X
    MOV AX, puntoX
    LEA DI, output + 2
    CALL convert_number

    ; Convertir coordenada Y
    MOV AX, puntoY
    LEA DI, output + 7
    CALL convert_number

    ; Convertir y mostrar el número (en BX)
    MOV AX, BX
    LEA DI, output + 12       ; Posición para el número
    CALL convert_number

    ; Imprimir cadena completa
    MOV DX, OFFSET output
    MOV AH, 09H
    INT 21H
    
    POP DI
    POP SI
    POP BX
    POP DX
    POP CX
    POP AX
    RET
imprimir_coordenadas ENDP

convert_number PROC
    ; Guardar registros manualmente
    PUSH AX
    PUSH CX
    PUSH DX
    PUSH BX
    PUSH SI
    PUSH DI
    
    MOV SI, DI
    TEST AX, AX
    JNS positivo
    MOV BYTE PTR [DI], '-'
    INC DI
    NEG AX
    JMP convertir_digitos

positivo:
    MOV BYTE PTR [DI], ' '
    INC DI

convertir_digitos:
    MOV CX, 10
    MOV BX, 3
    ADD DI, 2

convert_loop:
    XOR DX, DX
    DIV CX
    ADD DL, '0'
    MOV [DI], DL
    DEC DI
    DEC BX
    JNZ convert_loop

rellenar_espacios:
    CMP DI, SI
    JAE fin_relleno
    MOV BYTE PTR [DI], ' '
    DEC DI
    JMP rellenar_espacios

fin_relleno:
    ; Restaurar registros manualmente
    POP DI
    POP SI
    POP BX
    POP DX
    POP CX
    POP AX
    RET
convert_number ENDP

end programa
