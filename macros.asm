%macro print 1
  push dx
  mov dx,%1
  mov ah,9
  int 21h
  pop dx
%endmacro

%macro printchar 1
  push dx
  mov dx,%1
  mov ah,2
  int 21h
  pop dx
%endmacro


%macro ObtenerTexto 1
    xor si,si   
    %%ObtenerCH:
        call GetCh
        cmp al,0dh  ;ascii salto de linea en hex
        je %%FinOT      
        mov %1[si],al
        inc si
        jmp %%ObtenerCH
        
    %%FinOT:
        mov al,24h  ;ascii $ en hex
        mov %1[si],al
%endmacro



%macro TamanoCadena 1
  push ax
 
  xor si,si   
  xor al,al

	%%ContarLetra:
    mov al, %1[si]
    cmp al, 24h
    je %%FinContar
    inc si
    jmp %%ContarLetra

  %%FinContar:
    mov cx, si
  
  pop ax
%endmacro

%macro LimpiarUsername 1
  push si
  push ax
  xor si,si
  xor al,al
  %%Recorrer:
    cmp si,7
    je %%Fin
    mov al, 24h
    mov %1[si], al
    inc si
    jmp %%Recorrer
  %%Fin:
  pop ax
  pop si
%endmacro

%macro LimpiarPassword 1
  push si
  push ax
  xor si,si
  xor al,al
  %%Recorrer:
    cmp si,4
    je %%Fin
    mov al, 24h
    mov %1[si], al
    inc si
    jmp %%Recorrer
  %%Fin:
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
	
	imprimir dece, %2+01h,0
	imprimir uni, %2 +02h,0
%endmacro

%macro imprimir 3		; 1ro = lo que imprimo ; 2do = currimiento del cursor
  ;funcion 02h, interrupción 10h 
  ;Correr el cursor N cantidad de veces
  ;donde dl = N
  
  mov ah,02h	
  mov bh,0		;pagina
  mov dh,%3		;fila
  mov dl, %2	;columna
  int 10h	
  
  ;Funcion 09H, interrupcion 21h
  ;imprimir  caracteres en consola
  mov dx,%1	
  mov ah,09h
  int 21h
  
%endmacro


%macro Pintarpx 2		
	push si

	push ax
	mov cx,15
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

%macro Pintar 2		; vector [8]
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

%macro PintarH 2		

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

%macro  fa 2
 push ax
	mov cx,11
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

%macro PintarObs 2

  push ax
	mov cx,15
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

%macro DibujarObstaculo 2
  push ax
  push bx
  push cx
  push dx
  push si
	mov ax,%1
	mov bx,%2

	xor si,si

	mov cx,bx	;coord x
	shl cx,8	
	shl bx,6
	
	add bx,cx	; bx = y*320
	add ax,bx	; sumar x a (y*320)
	

	PintarObs ObsFila1,ax
  add ax,320
  PintarObs ObsFila2,ax
  add ax,320
  PintarObs ObsFila3,ax
  add ax,320
  PintarObs ObsFila4,ax
  add ax,320
  PintarObs ObsFila4,ax
  add ax,320
  PintarObs ObsFila4,ax
  add ax,320
  PintarObs ObsFila4,ax
  add ax,320
  PintarObs ObsFila4,ax
  add ax,320
  PintarObs ObsFila4,ax
  add ax,320
  PintarObs ObsFila4,ax
  add ax,320
  PintarObs ObsFila4,ax
  add ax,320
  PintarObs ObsFila4,ax
  add ax,320
  PintarObs ObsFila4,ax
  add ax,320
  PintarObs ObsFila3,ax
  add ax,320
  PintarObs ObsFila2,ax
  add ax,320
  PintarObs ObsFila1,ax
	pop si
  pop dx
  pop cx
  pop bx
  pop ax
%endmacro


%macro ClearScreen 0
  mov ax,10
	mov bx,16
  xor si,si
  xor di,di

	mov cx,bx	;coord x
	shl cx,8	
	shl bx,6
	
	add bx,cx	; bx = y*320
	add ax,bx	; sumar x a (y*320)
	

	%%LineaArriba:
		cmp si,3600
		je %%FinLineaArriba
		Pintarpx ClearH,ax
    
		add ax,15
		inc si
		jmp %%LineaArriba
	%%FinLineaArriba:


%endmacro



%macro DesaparecerObstaculo 2
  push ax
  push bx
  push cx
  push dx
  push si
	mov ax,%1
	mov bx,%2

	xor si,si

	mov cx,bx	;coord x
	shl cx,8	
	shl bx,6
	
	add bx,cx	; bx = y*320
	add ax,bx	; sumar x a (y*320)
	PintarObs obl,ax
  add ax,320
  PintarObs obl,ax
  add ax,320
  PintarObs obl,ax
  add ax,320
  PintarObs obl,ax
  add ax,320
  PintarObs obl,ax
  add ax,320
  PintarObs obl,ax
  add ax,320
  PintarObs obl,ax
  add ax,320
  PintarObs obl,ax
  add ax,320
  PintarObs obl,ax
  add ax,320
  PintarObs obl,ax
  add ax,320
  PintarObs obl,ax
  add ax,320
  PintarObs obl,ax
  add ax,320
  PintarObs obl,ax
  add ax,320
  PintarObs obl,ax
  add ax,320
  PintarObs obl,ax
  ;%%PintFila:
  ;  cmp si,10
  ;  je %%FinPint
  ;  PintarObs obl,ax
  ;  add ax,320
  ;  inc si
  ;  jmp %%PintFila
  ;%%FinPint:

 
	pop si
  pop dx
  pop cx
  pop bx
  pop ax
%endmacro


%macro ModificarPos 2
  push bx
  push dx
  mov ax,%1

  mov bx,10
  mov dx,0
  div bx  
  add dx,48
  mov Un[0h],dx

  mov bx,10
  mov dx,0
  div bx
  add dx,48
  mov Dn[0h],dx

  mov bx,10
  mov dx,0
  div bx
  add dx,48
  mov Cn[0h],dx

  mov al,Cn[0h]
  mov ObstaculosFile[%2+0h],al
  
  mov al,Dn[0h]
  mov ObstaculosFile[%2+1h],al
 
  mov al,Un[0h]
  mov ObstaculosFile[%2+2h],al

  pop dx
  pop bx
%endmacro

%macro CargarNivel 0
  push di
  push ax
  push bx

  xor di,di
  mov di,[PunteroNivel]

  mov al,bufferNivel[di]
  cmp al,24h
  je %%FinNiveles
  
  ;IGNORA LA PALABRA NIVEL
  %%PalabraNivel:
    mov al,bufferNivel[di]
    cmp al,2ch ;coma
    je %%FinPalNivel
    inc di
    jmp %%PalabraNivel
  %%FinPalNivel:

  ;OBTIENE EL # NIVEL
  inc di
  mov al,bufferNivel[di]
  mov nivelActual[01H],al
  ;OBTIENE EL TIEMPO DE LA PARTIDA
  inc di
  inc di

  xor ax,ax 
  xor cx,cx
  mov al,bufferNivel[di]
  sub ax,48
	mov cx,10
	mul cx
	mov [TD],ax

  xor ax,ax

  inc di
  mov al,bufferNivel[di]
  sub ax,48
	mov [TU],ax

  mov bx,[TD]
	mov cx,[TU]
	add bx,cx
	mov [TiempoPartida],bx
  ;OBTIENE EL TIEMPO OBSTACULOS
  inc di
  inc di

  ;OBTIENE EL TIEMPO PREMIOS
  inc di
  inc di

  ;OBTIENE PUNTOS RESTA POR OBSTACULO
  inc di
  inc di
  xor ax,ax 
  xor cx,cx
  mov al,bufferNivel[di]
  sub ax,48
	mov [DecremeObs],ax

  ;OBTIENE PUNTOS SUMA POR PREMIO
  inc di
  inc di
  xor ax,ax 
  xor cx,cx
  mov al,bufferNivel[di]
  sub ax,48
	mov [AumentoPremio],ax

  inc di
  inc di
  ;Guardar Puntero
  mov [PunteroNivel],di
  mov dx,1
  jmp %%Finmacro
  ;Llego al final de niveles
  %%FinNiveles:
    mov dx,0
 

  %%Finmacro:
  pop bx 
  pop ax
  pop di
%endmacro