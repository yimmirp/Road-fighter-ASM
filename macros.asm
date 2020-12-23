%macro ImprimirCadena 1
  push dx
  mov dx,%1
  mov ah,9
  int 21h
  pop dx
%endmacro