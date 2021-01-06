%macro print 1
  push dx
  mov dx,%1
  mov ah,9
  int 21h
  pop dx
%endmacro
section .data
  buffer db '000,000$'
  crlf db 10,13,'$'
  Un db '0'
  Dn db '0'
  Cn db '0'


org 100h
section .text

main:
  print buffer
  print crlf
  mov ax,89
  
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
  mov buffer[4h],al
  
  mov al,Dn[0h]
  mov buffer[5h],al
 
  mov al,Un[0h]
  mov buffer[6h],al


  print buffer

  mov ax,4c00h	; terminar mi programa
	int 21h