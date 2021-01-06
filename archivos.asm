%macro AbrirArchivoNiveles 0
	mov dx,LoadFile
	mov ah, 3dh 		;abrir un archivo en modo lectura
	mov al,00h			
	int 21h		

	mov bx,ax

	mov ah,	3fh
	mov cx,100
	mov dx,bufferNivel ;  Lectura del archivo
	int 21h


%endmacro 



%macro LimpiarNiveles 0

  push si
  push ax
  xor si,si
  xor al,al
  %%Recorrer:
    cmp si,100
    je %%Fin
    mov al, 24h
    mov bufferNivel[si], al
    inc si
    jmp %%Recorrer
  %%Fin:
  pop ax
  pop si

%endmacro



