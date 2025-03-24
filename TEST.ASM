.model small
.stack
.data
    cadena DB ' Ingrese la cantidad de puntos $'
    cadena2 DB ' ERROR: vuelva a ingresar el numero $'
    acumulador DB 3 dup(0)
    b DB 100, 10, 1
    cantPuntos DW 0
    salida DB 3 dup(0), '$'
    numActual DW 1  ; Contador de número en la espiral
    puntoX DW 0
    puntoY DW 0
    direccion DB 0
    contador DW 0
    limite DW 1
    ciclos DW 0
    output db ' (    ,    )', 0Dh, 0Ah, '$'

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
    MOV DX, OFFSET cadena
    MOV AH, 09H
    INT 21H
    JMP CAPTURAR_NUMERO

IMPRIMIR_NUMERO:
    MOV puntoX, 0
    MOV puntoY, 0
    CALL imprimir_coordenadas
    CMP cantPuntos, 1
    JA ContinuarProceso      ; Cambiamos el salto condicional
    JMP Finalizar

ContinuarProceso:            ; Etiqueta intermedia
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
    CALL imprimir_coordenadas  ; Imprimir coordenadas
    CALL IMPRIMIR_NUMERO2       ; Imprimir el número de la coordenada actual
    INC numActual              ; Incrementar el número en la espiral

    INC SI
    CMP SI, cantPuntos
    JBE loop_spiral


Finalizar:
    MOV AH, 4CH
    INT 21H

imprimir_coordenadas PROC
    ; Guardar registros manualmente (reemplazo de PUSHA)
    PUSH AX
    PUSH CX
    PUSH DX
    PUSH BX
    PUSH SI
    PUSH DI
    
    MOV AX, puntoX
    LEA DI, output + 2
    CALL convert_number

    MOV AX, puntoY
    LEA DI, output + 7
    CALL convert_number

    MOV DX, OFFSET output
    MOV AH, 09H
    INT 21H
    
    ; Restaurar registros manualmente (reemplazo de POPA)
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

IMPRIMIR_NUMERO2 PROC
		
		XOR AX, AX 	;limpiamos ax 
		MOV AX, numActual	;movemos cantpuntos a al
		DIV b[0]	;dividimos lo que esta en al (cantpuntos) dentro de la posicion 0 de b (100)
		MOV salida[0], AL	;movemos el cociente, es decir, la cantidad de veces que cabe b[0] en cantpuntos, a la variable salida en la posicion 0
		
		
		MOV BH, AH	;mueve el residuo de la division (AH) a BH
		XOR AX, AX	;limpiamos ax
		MOV AL, BH	;mueve el residuo que estaba en BH a AL
		DIV b[1]	;Dividimos el residuo dentro de 10 (B[1])
		MOV salida[1], AL ;movemos el cociente de la division a salida[1]
		MOV salida[2], AH ;y el residuo lo movemos a salida[2]
		
		;convertimos el numero a ascii
		ADD salida[0], 30h
		ADD salida[1], 30h
		ADD salida[2], 30h
		
		;imprimir salida
		LEA DX, salida ;LEA:calcula la direccion y la almacena en un registro
		MOV AH, 09H
		INT 21H
        RET

IMPRIMIR_NUMERO2 ENDP

end programa
