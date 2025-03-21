; solo imprime vacios

.MODEL small
.STACK 100h
.DATA
    mensajeBienvenida db 'Generador de la Espiral de Ulam en coordenadas', 0Dh, 0Ah, '$'
    mensajeNumero db 'Ingrese el numero de valores: $'
    
    x dw 1
    y dw 0
    direccion db 0   ; 0=der, 1=arriba, 2=izq, 3=abajo
    pasos dw 1       ; Ahora `dw` para coincidir con `CX`
    contador dw 1    ; Cambiado a `dw`
    limite dw 0      ; También `dw` para evitar error con `CMP`

    dxStr db '(', '  ', ',', '  ', ')', 0Dh, 0Ah, '$'  ; Formato de salida

.CODE
Inicio:
    ; Cargar segmento de datos
    mov ax, @data
    mov ds, ax

    ; Mostrar mensaje de bienvenida
    mov dx, offset mensajeBienvenida
    mov ah, 09h
    int 21h

    ; Pedir numero al usuario
    mov dx, offset mensajeNumero
    mov ah, 09h
    int 21h
    call LeerNumero

    mov limite, ax  ; Guardamos el número ingresado en `limite`

    ; Inicializar valores correctamente
    mov ax, 1
    mov x, ax
    mov ax, 0
    mov y, ax

    ; Mostrar primera coordenada (1,0)
    call ImprimirCoordenada

BucleEspiral:
    mov ax, contador
    cmp ax, limite
    jge FinPrograma  ; Si alcanzamos el límite, terminamos

    mov cx, pasos  ; Cargar cantidad de pasos en CX

Movimiento:
    cmp direccion, 0
    je Derecha
    cmp direccion, 1
    je Arriba
    cmp direccion, 2
    je Izquierda
    cmp direccion, 3
    je Abajo

Derecha:
    inc x
    jmp ImprimirYContinuar
Arriba:
    inc y
    jmp ImprimirYContinuar
Izquierda:
    dec x
    jmp ImprimirYContinuar
Abajo:
    dec y
    jmp ImprimirYContinuar

ImprimirYContinuar:
    call ImprimirCoordenada
    inc contador
    loop Movimiento  ; Mover múltiples pasos en la misma dirección

    ; Cambiar dirección
    inc direccion
    cmp direccion, 4
    jne NoReset
    mov direccion, 0  ; Reiniciar a derecha

NoReset:
    test direccion, 1  ; Cada 2 vueltas, aumentar pasos
    jnz NoAumentarPasos
    inc pasos

NoAumentarPasos:
    jmp BucleEspiral

FinPrograma:
    mov ax, 4C00h
    int 21h

; --------------------------------
; Subrutina: Leer un número del usuario
LeerNumero PROC
    mov ah, 01h
    int 21h
    sub al, '0'  ; Convertir ASCII a número
    cbw          ; Extender a `AX`
    ret
LeerNumero ENDP

; --------------------------------
; Subrutina: Convertir número a ASCII
ConvertirNumero PROC
    mov dx, 0         ; Limpiar DX
    mov cx, 10        ; Base 10
    div cx            ; AX / 10 → AL = cociente, AH = residuo
    add al, '0'       ; Convertir cociente a ASCII
    add ah, '0'       ; Convertir residuo a ASCII
    mov dh, al        ; Guardar decenas en DH
    mov dl, ah        ; Guardar unidades en DL
    ret
ConvertirNumero ENDP

; --------------------------------
; Subrutina: Imprimir la coordenada (x, y)
ImprimirCoordenada PROC
    ; Convertir x a ASCII
    mov ax, x
    call ConvertirNumero
    mov dxStr+1, dl  ; Guardamos primer dígito de `x`
    mov dxStr+2, dh  ; Guardamos segundo dígito de `x`

    ; Convertir y a ASCII
    mov ax, y
    call ConvertirNumero
    mov dxStr+4, dl  ; Guardamos primer dígito de `y`
    mov dxStr+5, dh  ; Guardamos segundo dígito de `y`

    ; Imprimir la coordenada
    mov dx, offset dxStr
    mov ah, 09h
    int 21h
    ret
ImprimirCoordenada ENDP

END Inicio