%include 'c:\PROYECTO\macros.asm'

org 100h
segment .text

main:
  ImprimirCadena menu1


; add your code here




ret

;======================SUBRUTINAS========================


;========================================================

segment .data

  menu1 db '(1) Ingresar',10,13,'(2) Registrar',10,13,'(3) Salir',10,10,13,'Ingrese Opcion: '


