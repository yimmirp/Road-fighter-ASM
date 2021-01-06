

org 100h

section .text

Inicio:
  mov ax, 13h
  xor ah,ah
  int 10h

  ;mov ax,data
  ;mov ds,ax
  mov ax,0A000h
  mov es,ax
  xor di,di

  Video:
    xor cx,cx

    mov cx,20 ;ancho
    mov dx,1  ;alto
    LEA si,[carroFilaLla]
    mov di,36000
    call dibuja
    jmp Video
  ret


dibuja:
  cld
  push cx
  rep movsb
  pop cx

  mov ax,320
  sub ax,cx
  add di,ax
  dec dx
  jnz dibuja  
  ret

section .data
  carroFilaLuz  DB 0 , 0 , 39 , 14, 14 , 14 , 39 , 39 , 39 , 39 , 39 , 39 , 39 , 39 , 14 , 14 , 14 , 39 , 0 , 0 
	carroFilaNor  DB 0 , 0 , 39 , 39, 39 , 39 , 39 , 39 , 39 , 39 , 39 , 39 , 39 , 39 , 39 , 39 , 39 , 39 , 0 , 0
	carroFilaLla  DB 27, 27, 39 , 39, 39 , 39 , 39 , 39 , 39 , 39 , 39 , 39 , 39 , 39 , 39 , 39 , 39 , 39 , 27, 27
