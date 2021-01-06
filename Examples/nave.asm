;========================MACROS================================
%macro PintarCarro 2 ;Fila a pintar , posicion
	push ax
	mov cx,24
	mov dx,1
	LEA si,[%1]
	mov di,%2

	%%dibuja:
  	cld
  	push cx
  	rep movsb
 	  pop cx

  	mov ax,320
  	sub ax,cx
  	add di,ax
  	dec dx
  	jnz %%dibuja
	pop ax
%endmacro

%macro print 1
  push dx
  mov dx,%1
  mov ah,9
  int 21h
  pop dx
%endmacro







%macro Pintar 2		; vector [8]
	;mov di,ax
	;mov si,%1
	;cld
	
	;mov cx,20
	;rep movsb
	;pop si
	push si


	push ax
	mov cx,22
	mov dx,1
	LEA si,[%1]
	mov di,%2

	%%dibuja:
  	cld
  	push cx
  	rep movsb
 	  pop cx

  	mov ax,320
  	sub ax,cx
  	add di,ax
  	dec dx
  	jnz %%dibuja
	pop ax
	pop si
%endmacro

%macro PintarH 2		; vector [8]


  push si
	push ax

	mov cx,1
	mov dx,1
	LEA si,[%1]
	mov di,%2

	%%dibuja:
  	cld
  	push cx
  	rep movsb
 	  pop cx

  	mov ax,320
  	sub ax,cx
  	add di,ax
  	dec dx
  	jnz %%dibuja
	pop ax
	pop si
%endmacro




%macro DivNumeros 2			; 1er = la cantidad que lleva el cronometro ; 2do = posicion donde quiero imprimirlo
	mov al,[%1]	; numero al registro al
	AAM			; divide los numeros en digitos
				; al = unidades , ah = decenas	
				
	; preparamos la unidad para ser impresa, es decir le sumamos el ascii
	add al,30h	
	mov [uni],al
	
	; preparamos la decena para ser impresa, es decir le sumamos el ascii
	add ah,30h
	mov [dece],ah
	
	imprimir dece, %2+01h
	imprimir uni, %2 +02h
%endmacro

%macro imprimir 2		; 1ro = lo que imprimo ; 2do = currimiento del cursor
  ;funcion 02h, interrupción 10h 
  ;Correr el cursor N cantidad de veces
  ;donde dl = N
  push ax
  mov ah,02h	
  mov bh,0		;pagina
  mov dh,0		;fila
  mov dl, %2	;columna
  int 10h	
  
  ;Funcion 09H, interrupcion 21h
  ;imprimir  caracteres en consola
  mov dx,%1	
  mov ah,09h
  int 21h
  pop ax
%endmacro


;==============================================================
org 100h
section .text

inicio:
	;iniciar el modo video., 13h
	mov al,13h
	xor ah,ah
	int 10h	

	;posicionar directamente a la memoria de video
	mov ax,0A000H
	mov es,ax
	xor di,di
	
	imprimir username, 02h
	mainLoop:
		call Cronometro
		call DefinirMargen	
		;===================carro===========================

		xor ax,ax
		xor bx,bx

		mov ax,[CoordX]
		mov bx,[CoordY]
		call DibujarCarro
	
		;===================delay==========================
	
		;mov cx,0000h			; tiempo del delay
		;mov dx,0fffh			; tiempo del delay
		;call Delay	



		call HasKey 		; hay tecla?
		jz mainLoop
	
		call GetCh			; si hay una tecla presiona, cual tecla es la que se presiono
	
		cmp al,'b'			; es b ? ,si sí,  se sale
		jne MovDerecha			;sino comprobar movimientos
	
	finProg:
		mov ax,3h		; funcion para el modo texto	
		int 10h
		
		mov ax,4c00h	; terminar mi programa
		int 21h
	
;==========================================AQUI TERMINA EL FLUJO GENERAL DEL PROGRAMA================












RecorridoObstaculos:
	push si
	push ax
	xor si,si

	Recorrer:
		mov al, ObstaculosFile[si]

		cmp al,'0'
		je FinRecorrer

		inc si
		inc si
		mov ah, ObstaculosFile[si]

		mov ax,30
	  mov bx,2
	  call DibujarObsatculo
	
	FinRecorrer:


	pop ax
	pop si
	ret
;===========================================================

Cronometro:
	Tiempo:
		mov ax,[microsegundos]
		inc ax
		cmp ax,60
		je masSeg
		
		mov [microsegundos],ax
		jmp imprimirTiempo
	masSeg:
		mov ax,[segundos]
		inc ax
		cmp ax,60
		je masMin
		mov [segundos],ax
	
		mov ax,0
		mov [microsegundos],ax
		jmp imprimirTiempo
	masMin:
		mov ax,[minutos]
		inc ax
		mov [minutos],ax
		
		mov ax,0
		mov [segundos],ax
		mov [microsegundos],ax
	imprimirTiempo:
		DivNumeros minutos, 1EH				; el numero a imprimir en pantalla, y la posicion donde quiero que se imprima
		DivNumeros segundos, 21H
		DivNumeros microsegundos, 024H
	ret



;========================================MOVIMIENTO DE MI CARRO=====================================
MovDerecha:
	cmp al,'d'
	jne MovIzquierda
		
	; si llega aqui es la tecla d
	mov ax,[CoordX]
	inc ax
	inc ax
	cmp ax,290
	je mainLoop
	mov [CoordX],ax
	jmp mainLoop
		
MovIzquierda:
	cmp al,'a'
	jne mainLoop
		
	; si llega aqui es la tecla a
	mov ax,[CoordX]
	dec ax
	dec ax
	cmp ax,10
	je mainLoop
	mov [CoordX],ax
	jmp mainLoop
	


		
	
;=======================SUBRUTINAS=============================

DefinirMargen:
	mov ax,10
	mov bx,15
	call MargenHorizontal

	mov ax,10
	mov bx,190
	call MargenHorizontal

  mov ax,10
	mov bx,15
	call MargenVertical

	mov ax,310
	mov bx,15
	call MargenVertical
	ret


MargenHorizontal:
	
	xor si,si

	mov cx,bx	;coord x
	shl cx,8	
	shl bx,6
	
	add bx,cx	; bx = y*320
	add ax,bx	; sumar x a (y*320)
	
	LineaArriba:
		cmp si,15
		je FinLineaArriba
		Pintar TramLineaH,ax
		add ax,20
		inc si
		jmp LineaArriba
	FinLineaArriba:
	
	ret

MargenVertical:
	xor si,si

	mov cx,bx	;coord x
	shl cx,8	
	shl bx,6
	
	add bx,cx	; bx = y*320
	add ax,bx	; sumar x a (y*320)

	LineaLateral:
		cmp si,175
		je FinLat
		PintarH TramLineaV,ax
		add ax,320
		inc si
		jmp LineaLateral
	FinLat:
	ret





		
;======================================================================

;limpiar la pantalla, y pintarla de negro, por completo
;procedimiento directo a la memoria de video
ClearScreen:	
	;x=11 , y= 16
	mov cx,bx	;coord x
	shl cx,8	
	shl bx,6
	
	add bx,cx	; bx = y*320
	add ax,bx	; sumar x a (y*320)
	
	xor si,si
	xor di,di

	Reco:
		cmp si,85
		je FinReco
		Pintarpx ColorNegro,ax
		add ax,640
		inc si
		jmp Reco
	FinReco:
		



	ret
	
	
;==========================================================================
;procedimiento de delay
;funcion 86h, interrupcion 15h
;Esta funcion recibe un numero de 32 bits, pero en dos partes
; de 16 bits c/u cx y en dx,  CX es la parte alta y DX es la parte baja
;Esta funcion causa retardos de un microsegundo=1/1 000 000

Delay:
	mov ah,86h
	int 15h
	ret

;==========================================================================
    ; funcion HasKey
    ; hay una tecla presionada en espera?
    ; zf = 0 => Hay tecla esperando 
    ; zf = 1 => No hay tecla en espera     
HasKey:
	push ax
	mov ah,01h	
	int 16h
	pop ax
	ret
	
;======================================================================
    ; funcion GetCh
    ; ascii tecla presionada
    ; Salida en al codigo ascii sin eco, via BIOS		
	GetCh:
		xor ah,ah
		int 16h
		ret

;==========================================================================  
    ;bx= coordenada y
    ;ax= coordenada x
	; y*320 + x = (x,y)
	;10 * 320 + 100 = 3300
	;	CoordX 			dw 160
	;CoordY 			dw 146
	
DibujarCarro:
	;push ax

	;mov ax,ds
	;mov es,ax	;guardando la dirección base
	
	;pop ax
	xor si,si

	mov cx,bx	;coord x
	shl cx,8	
	shl bx,6
	
	add bx,cx	; bx = y*320
	add ax,bx	; sumar x a (y*320)
	

	
	PintarCarro carroFilaLuz,ax
	
	add ax,320
	PintarCarro carroFilaNor,ax	

	
	add ax,320		
	PintarCarro carroFilaLla,ax	

	add ax,320		
	PintarCarro carroFilaLla,ax	

	add ax,320		
	PintarCarro carroFilaLla,ax	

	add ax,320		
	PintarCarro carroFilaLla,ax	

	;Cuerpo Carro

	add ax,320
	PintarCarro carroFilaNor,ax	

	add ax,320
	PintarCarro carroFilaNor,ax	

	add ax,320
	PintarCarro carroFilaNor,ax	

	add ax,320
	PintarCarro carroFilaNor,ax	

	add ax,320
	PintarCarro carroFilaNor,ax	

	add ax,320
	PintarCarro carroFilaNor,ax	

	add ax,320
	PintarCarro carroFilaNor,ax	

	add ax,320
	PintarCarro carroFilaNor,ax	

	add ax,320
	PintarCarro carroFilaNor,ax	

	add ax,320
	PintarCarro carroFilaNor,ax	
	
	;Llanta
	add ax,320		
	PintarCarro carroFilaLla,ax	

	add ax,320		
	PintarCarro carroFilaLla,ax	

	add ax,320		
	PintarCarro carroFilaLla,ax	

	add ax,320		
	PintarCarro carroFilaLla,ax	


	add ax,320
	PintarCarro carroFilaNor,ax	

	add ax,320
	PintarCarro carroFilaNor,ax	
	
	ret


DibujarObsatculo:
	push ax
	mov ax,ds
	mov es,ax	;guardando la dirección base
	
	pop ax
	
	mov cx,bx	;coord x
	shl cx,8	
	shl bx,6
	
	add bx,cx	; bx = 320
	add ax,bx	; sumar x a y
	
	;add ax,buffer

	
	MDibujarObstaculo ObsFilaNor	
		
	add ax,320		
	MDibujarObstaculo ObsFilaNor	

	xor si,si
	ObsLlantaAtras:
		cmp si,3
		je FinLlantasAtras
		add ax,320		
		MDibujarObstaculo ObsFilaLla	
		inc si
		jmp ObsLlantaAtras
	FinLlantasAtras:
	
	xor si ,si
  CuerpoCarro:
		cmp si,9
		je FinCuerpo
		add ax,320		
		MDibujarObstaculo ObsFilaNor	
		inc si
		jmp CuerpoCarro
	FinCuerpo:

	xor si, si
  ObsLlantaAdelante:
		cmp si,3
		je FinLlantasAdelante
		add ax,320		
		MDibujarObstaculo ObsFilaLla	
		inc si
		jmp ObsLlantaAdelante
	FinLlantasAdelante:






	add ax,320		
	MDibujarObstaculo ObsFilaNor

	add ax,320		
	MDibujarObstaculo ObsFilaLuz		

	ret
;==============================================================



section .data
	username db 'yimmi$'
	nivel db 'N1$'
	puntos db '000$'

	
	;variables de int
	microsegundos 	dw 0
	segundos 		dw 0
	minutos			dw 0
	
	; variables que van a llevar la posicion de mi carro
	CoordX 			dw 160
	CoordY 			dw 146
	
	
	;variables de string
	uni 			db 0,"$"
	dece 			db 0,"$"
	
	ObstaculosFile      db '0,0;$'
	
	; variables que pintan la carro
						    ;  1	2 	3		4		 5		6		7		 8		 9	 10	  11	 12	  13   14   15   16   17   18  19   20
	carroFilaLuz  DB 0,0, 0 , 0 , 39 , 14, 14 , 14 , 39 , 39 , 39 , 39 , 39 , 39 , 39 , 39 , 14 , 14 , 14 , 39 , 0 , 0, 0,0 
	carroFilaNor  DB 0,0, 0 , 0 , 39 , 39, 39 , 39 , 39 , 39 , 39 , 39 , 39 , 39 , 39 , 39 , 39 , 39 , 39 , 39 , 0 , 0, 0,0
	carroFilaLla  DB 0,0, 27, 27, 39 , 39, 39 , 39 , 39 , 39 , 39 , 39 , 39 , 39 , 39 , 39 , 39 , 39 , 39 , 39 , 27, 27,0,0

  ; Variables que pintan carro  verd
	ObsFilaLuz	db  0 , 0 , 2 , 14 , 14 , 14 , 2 , 2 , 2 , 14 , 14 , 14 , 2 , 0 , 0
	ObsFilaNor  db  0 , 0 , 2 , 2  , 2  , 2  , 2 , 2 , 2 , 2  , 2  , 2  , 2 , 0 , 0 
	ObsFilaLla  db  27, 27, 2 , 2  , 2  , 2  , 2 , 2 , 2 , 2  , 2  , 2  , 2 , 27, 27

	TramLineaH db 3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3
	TramLineaV db 3



	