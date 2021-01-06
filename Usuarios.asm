;username,espacioblanco,coma,contra,pcoma
%macro RegistrarUsuario 5
  mov dx,UserFile
	mov ah, 3dh 		;abrir un archivo en modo escritura
	mov al,01h			
	int 21h				

	mov bx,ax ;Pasa el handle del archivo

	xor cx, cx ;Limpiar registros
	xor dx, dx ;Limpiar registros


	mov ah, 42h
	mov al, 02h ;Posiciono al final del archivo
	int 21h


	mov ah,40h
	mov cx,1
	mov dx,%2		;nueva linea
	int 21h 

  
	mov ah,40h
	TamanoCadena %1
	mov dx,%1
	int 21h 

	mov ah,40h
	mov cx,1 ;Escribir coma
	mov dx,%3
	int 21h 

	mov ah,40h
	TamanoCadena %4
  mov dx,%4
	int 21h

	mov ah,40h
	mov cx,1 ;escribir punto y coma
	mov dx,%5
	int 21h 	 


	mov ah, 3eh 		; funcion 3e, cerrar un archivo
	int 21h 			; interrupcion DOS

%endmacro



%macro Login 2

	mov dx,UserFile
	mov ah, 3dh 		;abrir un archivo en modo lectura
	mov al,00h			
	int 21h		

	mov bx,ax

	mov ah,	3fh
	mov cx,300
	mov dx,BufferUsers ;  Lectura del archivo
	int 21h

	xor si,si
	
	%%Item:
		LimpiarUsername UsernameTemp
		LimpiarPassword PasswordTemp
		%%user:
			xor di,di
			%%RecorrerUser:
				mov al,BufferUsers[si]
				cmp al,44
				je %%pass
				mov UsernameTemp[di], al
				inc si
				inc di
				jmp %%RecorrerUser
		
		%%pass:
			xor di,di
			inc si
			%%RecorrerPass:
				mov al,BufferUsers[si]
				cmp al,59
				je %%Comparar
				mov PasswordTemp[di], al
				inc si
				inc di
				jmp %%RecorrerPass

	%%Comparar:
		;print CRLF
		;print %1
		;print sep
		;print UsernameTemp
		;print CRLF
		;print %2
		;print sep
		;print PasswordTemp
		;print CRLF
		
		inc si
		inc si

		CompararCadena %1,UsernameTemp,7

		cmp ah,0
		je %%SeguirBuscando

		CompararCadena %2,PasswordTemp,4
		cmp ah,0
		ja %%Fin

	%%SeguirBuscando:
		mov al, BufferUsers[si]
		cmp al,36
		jne %%Item
		jmp %%Fin

	%%Fin:
%endmacro





%macro imprimirChar 1
  push si
	xor si,si
	%%Recorrer:
		cmp si,8
		je %%Fin
		printchar %1[si]
		inc si
		jmp %%Recorrer 
	%%Fin:
	pop si
%endmacro







%macro CompararCadena 3

	push di
	xor di,di
	mov ah,0

	%%Recorrer:
		cmp di,%3
		ja %%Coincide
		mov al, %1[di]
		mov bl, %2[di]
		inc di
		cmp al,bl
		je %%Recorrer
		jmp %%Fin

	%%Coincide:
		mov ah,1
	%%Fin:
	pop di
%endmacro










%macro ComprobarAdmin 2
	xor si,si
	mov bl, 0

	;Comprobar "a"
	mov al, %1[si]
	cmp al, 97
	jne %%Fin
	inc si


	;Comprobar "d"
	mov al, %1[si]
	cmp al, 100
	jne %%Fin
	inc si


	;Comprobar "m"
	mov al, %1[si]
	cmp al, 109
	jne %%Fin
	inc si

	;Comprobar "i"
	mov al, %1[si]
	cmp al, 105
	jne %%Fin
	inc si



	;Comprobar "n"
	mov al, %1[si]
	cmp al, 110
	jne %%Fin
	inc si

		
	;=================Comprobar Contraseña ====================
	xor si,si 

	;Comprobar "1"
	mov al, %2[si]
	cmp al, 49
	jne %%Fin
	inc si

	;Comprobar "2"
	mov al, %2[si]
	cmp al, 50
	jne %%Fin
	inc si

	;Comprobar "3"
	mov al, %2[si]
	cmp al, 51
	jne %%Fin
	inc si

	;Comprobar "4"
	mov al, %2[si]
	cmp al, 52
	jne %%Fin
	inc si

	mov bl,1		

	%%Fin:
%endmacro


%macro GuardarPunteo 9
  mov dx,PuntosFile
	mov ah, 3dh 		;abrir un archivo en modo escritura
	mov al,01h			
	int 21h				

	mov bx,ax ;Pasa el handle del archivo

	xor cx, cx ;Limpiar registros
	xor dx, dx ;Limpiar registros


	mov ah, 42h
	mov al, 02h ;Posiciono al final del archivo
	int 21h


	mov ah,40h
	mov cx,1
	mov dx,%6		;nueva linea
	int 21h 

  
	mov ah,40h
	TamanoCadena %1 ;Guardar username
	mov dx,%1
	int 21h 

	mov ah,40h
	mov cx,1 ;Escribir coma
	mov dx,%7
	int 21h 

	mov ah,40h
	TamanoCadena %2 ;guardar nivel
  mov dx,%2
	int 21h

  mov ah,40h
	mov cx,1 ;Escribir coma
	mov dx,%7
	int 21h 

	mov ah,40h
	TamanoCadena %3 ;guardar CentenaPunteo
  mov dx,%3
	int 21h

  mov ah,40h
	TamanoCadena %4 ;guardar DecenaPunteo
  mov dx,%4
	int 21h

	mov ah,40h
	TamanoCadena %5 ;guardar UnidadPunteo
  mov dx,%5
	int 21h

	mov ah,40h
	mov cx,1 ;Escribir coma
	mov dx,%7
	int 21h 

	mov al,[%9]	; numero al registro al
	AAM	 
	add al,30h
	add ah,30h
	mov [RT],ah
	mov [RU],al
  ;add ah,30h

  mov ah,40h
	mov cx,1 ;escribir punto y coma
	mov dx,RT
	int 21h 	 

	mov ah,40h
	mov cx,1 ;escribir punto y coma
	mov dx,RU
	int 21h 


	mov ah,40h
	mov cx,1 ;escribir punto y coma
	mov dx,%8
	int 21h 	 


	mov ah, 3eh 		; funcion 3e, cerrar un archivo
	int 21h 			; interrupcion DOS


%endmacro