%include 'c:\EjemplosNASM\PROYECTO\macros.asm'
%include 'c:\EjemplosNASM\PROYECTO\Usuarios.asm'
%include 'c:\EjemplosNASM\PROYECTO\archivos.asm'



org 100h
section .text
  
main:
	;jmp IniciarJuego
	print CRLF
  print separador
  print menu1
  
  call GetCh

  cmp  al,49
  je MenuLogin

  cmp al,50
  je MenuRegistro

  cmp al,51
  je Salir

  jmp main
  
  call Salir







;======================MENU LOGIN=======================
MenuLogin:
  LimpiarUsername Username
  LimpiarPassword Password
  print CRLF
  print separador
  print msgUsername
  ObtenerTexto Username
  print msgPassword
  ObtenerTexto Password
  ;COMPROBAR SI ES EL ADMIN
  ComprobarAdmin Username,Password
  cmp bl,0
  ja MenuAdmin
  ;COMPROBAR SI EXITE EL USUARIO REGISTRADO
  Login Username,Password
  cmp ah,0
  ja MenuUser
	print separador
	print msgError
	
  jmp main
  

;======================MENU REGISTRO====================

MenuRegistro:
  print CRLF
  print separador
  LimpiarUsername Username
  LimpiarPassword Password
  print msgUsername
  ObtenerTexto Username
  print msgPassword
  ObtenerTexto Password
  RegistrarUsuario Username,espacioblanco,coma,Password,pcoma
  jmp main
  


;======================MENU ADMIN========================
MenuAdmin:
  print CRLF
  print separador
  print Encabezado
  print menu3
  call GetCh

  cmp  al,49
  je MenuLogin

  cmp al,50
  je MenuRegistro

  cmp al,51
  je main

  jmp MenuAdmin


;======================MENU USUARIO NORMAL===============

MenuUser:
	xor ax,ax
  print CRLF
  print separador
  print Encabezado
  print menu2
  call GetCh

  cmp  al,49
  je IniciarJuego

  cmp al,50
  je MenuCargar

  cmp al,51
  je main

  jmp MenuUser

;======================MENU CARGAR NIVELES==================
MenuCargar:
	print CRLF
	print separador
	print CRLF
	LimpiarNiveles 
	AbrirArchivoNiveles 
	print bufferNivel
	print CRLF
	print msgCargado
	jmp MenuUser


;====================== INICIAR JUEGO ===================
IniciarJuego:
 ;iniciar el modo video., 13h
	mov al,13h
	xor ah,ah
	int 10h	

	;posicionar directamente a la memoria de video
	mov ax,0A000H
	mov es,ax
	xor di,di

	
	CargarNivel
	
  imprimir Username, 02h,0
	imprimir nivelActual,0Dh,0
	imprimir CenPuntos,0Dh+09h,0
	imprimir DecPuntos,0Dh+0Ah,0
	imprimir UniPuntos,0Dh+0Bh,0
	call Cronometro
	call DefinirMargen
	mov ax,[CoordX]
	mov bx,[CoordY]
	call DibujarCarro
  imprimir cero,26h,0
	jmp ModoPause


	mainLoop:
	  
    call Cronometro

		call DibujarCarro
		
		call LogicaJuego

		;Comparando limite de tiempo
		mov ax,[TiempoRelativo]
		mov bx,[TiempoPartida]
		cmp ax,bx
		je ArmarNivel


	  mov cx,0000h			
	  mov dx, 03fffh	
	  call Delay	

	  call HasKey 	
	  jz mainLoop

	  call GetChVideo	
	
	  cmp al,1bh			; es ESC?
	  je ModoPause		;si es ESC entra en modoPausa
		
		cmp al,'r'
		je AumentarPunteo
	

		cmp al,'t'
		je DisminuirPunteo
		jne MovDerecha	;sino comprobar movimientos


;AQUI TERMINA EL FLUJO DEL PROGRAMA



;========================================SUBRUTINAS==================================
LogicaJuego:
	push si
	push di
	push ax
	xor si,si
	xor ax,ax
	xor bx,bx
	xor dx,dx
	mov ax,0


	LeerObstaculo:
		;Obtener posicion x

		;Obtengo centena
		mov al,ObstaculosFile[si]
		sub ax,48
		mov cx,100
		mul cx
		mov [XC],ax


		inc si;============Paso a la decena


		xor ax,ax
		xor cx,cx

	;	;Obtengo Decena
		mov al,ObstaculosFile[si]
		sub ax,48
		mov cx,10
		mul cx
		mov [XD],ax

		inc si;===============paso a la unidad


		xor ax,ax
	
		;Obtengo Unidad
	  mov al,ObstaculosFile[si]
		sub ax,48
		mov [XU],ax

		xor ax,ax
		xor bx,bx
		xor cx,cx
		mov ax,[XC]
		mov bx,[XD]
		mov cx,[XU]
		add ax,bx
		add ax,cx
		mov [XX],ax

		xor ax,ax
		xor bx,bx
		xor cx,cx

		inc si ;========== paso la coma
		inc si ;========== paso a la centena de Y

		;Obtener posicion Y

	;Obtengo centena
		mov al,ObstaculosFile[si]
		sub ax,48
		mov cx,100
		mul cx
		mov [YC],ax


		inc si;========= paso a la decena
		xor ax,ax
		xor cx,cx

	;	;Obtengo Decena
		mov al,ObstaculosFile[si]
		sub ax,48
		mov cx,10
		mul cx
		mov [YD],ax

		inc si;========== paso a la unidad
		xor ax,ax
	
		;Obtengo Unidad
	  mov al,ObstaculosFile[si]
		sub ax,48
		mov [YU],ax

		xor ax,ax
		xor bx,bx
		xor cx,cx
		mov ax,[YC]
		mov bx,[YD]
		mov cx,[YU]
		add ax,bx
		add ax,cx
		mov [YY],ax
		
		;DibujarObstaculo [XX],[YY]
		
		;inc si
		;inc si
		;mov al,ObstaculosFile[si]
		;cmp al, 24h ;Si es el ultimo  no lo pinnto y salgooo
		;je NoPintar
		;jmp LeerObstaculo

		;compara si es un objeto ha salido, sino ha salido ni este ni lode que siguen han salido
		;entonces no lo pinto y no reviso la posicion de los demas
		cmp ax,0
		je NoPintar 

		;Si la posicion en "Y" es 200 es porque es un objeto que ya paso por pantalla y paso al siguiente
		cmp ax,200
		je PasarSiguiente 

		;Si el objeto llego a la poisicon en "Y" a 167 es xq el recorrido del objeto llego al tope
		;inferior, entonces verifico si es el ultimo bloque
		cmp ax,167
		je EsUltimo

		DibujarObstaculo [XX],[YY]

		inc ax
		dec si
		dec si
		;Reescrbor la pos Y
		ModificarPos ax,si
		inc si 
		inc si
		inc si;========= paso al punto y coma
		inc si;========= paso a la Centena del otr obj
		jmp LeerObstaculo

		

		EsUltimo:
		  DesaparecerObstaculo [XX],167
			mov ax,200
			dec si
			dec si
			;Reescrbor la pos Y
			ModificarPos ax,si
			inc si 
			inc si
			inc si
			inc si
			mov al,ObstaculosFile[si]
			cmp al, 24h ;Si es el ultimo  no lo pinnto y salgooo
			je NoPintar

		;	;Pero si no es el ultimo quiere decir de que fue un objeto que llego al fin y posteriormente 
		;	;ya no se pintara
			jmp LeerObstaculo
			;bandera que es el ultimo
		PasarSiguiente:
			inc si
			inc si
			jmp LeerObstaculo
		NoPintar:
		

	pop ax
	pop di
	pop si
	ret
	;ObstaculosFile      db '015,017;053,017;093,017;133,017;$'
	
AumentarPunteo:
	push di
	xor di,di
	xor cx,cx
	mov cx,[AumentoPremio]
	MulPuntos:
	 cmp di,cx
	 je salMul
		 

		xor ax,ax
		Unidad:
			mov al,[PUnidad]
			inc al
			cmp al,10
			jae SupUnidad
			mov [PUnidad],al
			jmp ImprimirPunteo
			SupUnidad:
				mov bl,10
			 	sub al,bl
				mov [PUnidad],al


		Decena:
			mov al,[PDecena]
			inc al
			cmp al,10
			jae SupDecena
			mov [PDecena],al
			jmp ImprimirPunteo

			SupDecena:
				mov bl,10
				sub al,bl
				mov [PDecena],al

		Centena:
			mov al,[PCentena]
			inc al
			mov [PCentena],al

		;Centema:
		ImprimirPunteo:
		  mov al,[PUnidad]
		  add al,30h
			mov [UniPuntos],al
			imprimir UniPuntos,0Dh+0Bh,0

			mov al,[PDecena]
		  add al,30h
			mov [DecPuntos],al
			imprimir DecPuntos,0Dh+0Ah,0

			mov al,[PCentena]
		  add al,30h
			mov [CenPuntos],al
			imprimir CenPuntos,0Dh+09h,0

		   inc di
			 jmp MulPuntos
		salMul:


		jmp mainLoop
		pop di
	ret

DisminuirPunteo:

	push di
	xor di,di
	xor cx,cx
	mov cx,[DecremeObs]
	DeccPuntos:
	 cmp di,cx
	 je decMul
		 
	xor ax,ax
	DUnidad:
		mov al,[PUnidad]
		cmp al,0
		je DisUnidad
		dec al
		mov [PUnidad],al
		jmp DImprimirPunteo
		DisUnidad:
			mov al,9
			mov [PUnidad],al

	DDecena:
		mov al,[PDecena]
		cmp al,0
		je DisDecena
		dec al
		mov [PDecena],al
		jmp DImprimirPunteo

		DisDecena:
			mov al,9
			mov [PDecena],al

	DCentena:
		mov al,[PCentena]
		dec al
		mov [PCentena],al

	;Centema:
	DImprimirPunteo:
	  mov al,[PUnidad]
	  add al,30h
		mov [UniPuntos],al
		imprimir UniPuntos,0Dh+0Bh,0

		mov al,[PDecena]
	  add al,30h
		mov [DecPuntos],al
		imprimir DecPuntos,0Dh+0Ah,0

		mov al,[PCentena]
	  add al,30h
		mov [CenPuntos],al
		imprimir CenPuntos,0Dh+09h,0

		mov al,[PUnidad]
		mov ah,[PDecena]
		mov bl,[PCentena]

		cmp al,0
		jne Sino
		cmp ah,0
		jne Sino
		cmp bl,0
		jne Sino
		jmp Perdio

		Sino:

		
		   inc di
			 jmp DeccPuntos
		decMul:


		pop di
		jmp mainLoop
			;jmp mainLoop
	;ret
		
Perdio:
	imprimir Terminado, 17h, 24
	imprimir exitmsg,02h,24
	
	EstadoFinalizado:
		call HasKey
		jz EstadoFinalizado
		call GetChVideo
		cmp al,20h
		je SalirJ
		jmp EstadoFinalizado
	SalirJ:
		call Reset
		;TODO:GUARDAR DATOS DE LA PARTIDA
		mov ax,3h		; funcion para el modo texto	
		int 10h

		jmp MenuUser
	ret

Reset:
	;Primero Reset el reloj
	mov ax,0
	mov [microsegundos],ax
	mov [segundos],ax
	mov [minutos],ax
	;Reset Puntos
	push ax
	push si
	xor si,si
	mov al,51
	mov UniPuntos[si], al
	mov al,48
	mov DecPuntos[si], al
	mov CenPuntos[si], al
	pop si
	pop ax
	push ax
	mov al,3
	mov [PUnidad],ax
	mov al,0
	mov [PDecena],al
	mov [PCentena],al
	pop ax
	;Reset Pos
	push ax
	mov ax,160
	mov [CoordX],ax 			
	mov [CoordY],ax
	pop ax
	ret
ModoPause:
	imprimir pau, 1Bh, 24
	imprimir exitmsg,02h,24
	EstadoPause:
		call HasKey 	
	  jz EstadoPause
		call GetChVideo	
		cmp al,1bh			
	  je SalirPause
		cmp al,20h
		je SalirJuego
		jmp EstadoPause
	SalirPause: 	
		imprimir nopause,02h,24
		imprimir nopause,19h,24
		jmp mainLoop
	SalirJuego:
		;TODO:GUARDAR DATOS DE LA PARTIDA
		;RegistrarUsuario Username,espacioblanco,coma,Password,pcoma
		GuardarPunteo Username,nivelActual,CenPuntos,DecPuntos,UniPuntos,espacioblanco,coma,pcoma,TiempoRelativo 
		mov ax,3h		; funcion para el modo texto	
		int 10h
		print separador
	
		print msgGuardado

		jmp MenuUser


;======================================================================
GetCh:
  mov ah,01h
  int 21h
  ret
;======================================================================
; funcion GetCh
; ascii tecla presionada
; Salida en al codigo ascii sin eco, via BIOS		
GetChVideo:
	xor ah,ah
	int 16h
	ret
;=======================================================================
;Salir del programa
Salir:
  mov ah,4ch
  int 21h

;=======================cronometro======================================
Cronometro:
	Tiempo:
		mov ax,[microsegundos]
		inc ax
		cmp ax,60
		je masSeg
		
		mov [microsegundos],ax
		jmp imprimirTiempo
	masSeg:
		mov ax,[TiempoRelativo]
		inc ax
		mov [TiempoRelativo],ax
		xor ax,ax
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

; ======================================================
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

;===========================================================================
DefinirMargen:
	mov ax,10
	mov bx,15
	call MargenHorizontal

	mov ax,10
	mov bx,185
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
		cmp si,170
		je FinLat
		PintarH TramLineaV,ax
		add ax,320
		inc si
		jmp LineaLateral
	FinLat:
	ret


;==========================================================================  
  ;bx= coordenada y
  ;ax= coordenada x
	; y*320 + x = (x,y)
	;10 * 320 + 100 = 3300
	
DibujarCarro:
	mov ax,[CoordX]
	mov bx,[CoordY]
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


MovDerecha:
	cmp al,'d'
	jne MovIzquierda
		
	; si llega aqui es la tecla d
	mov ax,[CoordX]
	inc ax
	inc ax
	cmp ax,288
	je mainLoop
	mov [CoordX],ax
	jmp mainLoop
		
MovIzquierda:
	cmp al,61h
	jne mainLoop
		
	; si llega aqui es la tecla a
	mov ax,[CoordX]
	dec ax
	dec ax
	cmp ax,10
	je mainLoop
	mov [CoordX],ax
	jmp mainLoop
	
;=======================================================


ArmarNivel:
	mov cx,0
	mov [TiempoPartida] ,cx
	mov [TiempoRelativo],cx
	CargarNivel 
	cmp dx,0
	je SalJuego

	ClearScreen 
	call DefinirMargen
	call Reset
	mov ax,[CoordX]
	mov bx,[CoordY]
	call DibujarCarro
	;Cargar datos del juego
	imprimir pau, 1Bh, 24
	imprimir exitmsg,02h,24
	imprimir PCron,1FH,0
	imprimir punteo,16H,0	
	imprimir nivelActual,0Dh,0
	EstadoIniciar:
		call HasKey 	
	  jz EstadoIniciar
		call GetChVideo	
		cmp al,1bh			
	  je IniJuego
		cmp al,20h
		je SalJuego
		jmp EstadoIniciar
	IniJuego: 	
		imprimir nopause,02h,24
		imprimir nopause,19h,24
		jmp mainLoop
	SalJuego:
		mov cx,0
		mov [PunteroNivel],cx
	

		;TODO:GUARDAR DATOS DE LA PARTIDA
		mov ax,3h		; funcion para el modo texto	
		int 10h
		print separador
	
		;print msgGuardado

		jmp MenuUser
 ret

;==============================================================================================================
;Variables
section .data  
	ObstaculosFile      db '015,017;053,017;093,017;133,000;$'

	bufferNivel    db 100 dup('$'),'$'
	uni 			     db 0,"$"
	dece 			     db 0,"$"
	UniPuntos			 db 51,'$'
	DecPuntos			 db 48,'$'
	CenPuntos			 db 48,'$'
  menu1          db 10,13,'(1) Ingresar',10,13,'(2) Registrar',10,13,'(3) Salir',10,10,13,'Ingrese Opcion: $'
  msgUsername    db 10,13,'Username: $'
  msgPassword    db 10,13,'Password: $'
  msgErrorLogin  db 10,13,'Datos Incorrectos'
  CRLF           db 10,13,'$'
  Encabezado     db 10,13,'UNIVERSIDAD DE SAN CARLOS DE GUATEMALA',10,13,'FACULTAD DE INGENIERIA',10,13,'CIENCIAS Y SISTERMAS',10,13,'ARQUITECTURA DE COMPUTADORES Y ENSAMBLADORES',10,13,'NOMBRE: YIMMI DANIEL RUANO PERNILLO',10,13,'CARNET:201503470',10,13,'SECCION: A',10,13,'$'
  menu2          db 10,13,'(1) Iniciar Juego',10,13,'(2) Cargar Juego',10,13,'(3) Cerrar Sesion',10,10,13,'Ingrese Opcion: $'
  menu3          db 10,13,'(1) Top 10 puntos',10,13,'(2) Top 10 tiempo',10,13,'(3) Cerrar Sesion',10,10,13,'Ingrese Opcion: $'
  msgGuardado    db 10,13,'Datos del Juego Guardado '
	msgCargado     db 10,13,'Juego Cargado con Exito.',10,13,'$'
	Username       db 7 dup('$'), '$'

	Password       db 4 dup('$'), '$'
  UsernameTemp   db 7 dup('$'), '$'
  PasswordTemp   db 4 dup('$'), '$'
  BufferUsers    db 300 dup('$'), '$'
  separador      db '===============================================$'
	microsegundos  dw 0
	segundos 	     dw 0
	minutos		     dw 0
	msgError       db 10,13,'Credenciales Incorrectas',10,13,'$'
	pau 					 db '[Esc] Jugar$'
	Terminado			 db 'Juego Terminado$'
	exitmsg				 db '[Space] Salir$'
	punteo				 db '003$'
	cero 					 db '0$'
	PUnidad				 db 3
	PDecena				 db 0
	PCentena			 db 0
	PCron          db '00 00 00$'
	           

	XU       dw 0
	XD 	     dw 0
	XC		   dw 0
	XX			 dw 0
	YU       dw 0
	YD 	     dw 0
	YC		   dw 0
	YY			 dw 0

	
  ;----------------------Rutas-------------------------------------
  UserFile      db 'data/users.txt',0
  LoadFile      db 'data/entrada.pla',0
  PuntosFile    db 'data/puntos.rep',0
  ;---------------------Variables del juego-------------------------
  puntos        db 0
  nivelActual   db 'Nx$'

  espacioblanco db 0xa,'$'
  coma          db 44,'$'
  pcoma         db 59,'$'

  ; variables que van a llevar la posicion de mi nave
	CoordX 			  dw 160
	CoordY 			  dw 160  
;----------------------CARROS Y OBSTACULOS-------------------------------

	
	; variables que pintan la carro
						    ;  1	2 	3		4		 5		6		7		 8		 9	 10	  11	 12	  13   14   15   16   17   18  19   20
	carroFilaLuz  DB 0,0, 0 , 0 , 39 , 14, 14 , 14 , 39 , 39 , 39 , 39 , 39 , 39 , 39 , 39 , 14 , 14 , 14 , 39 , 0 , 0, 0,0 
	carroFilaNor  DB 0,0, 0 , 0 , 39 , 39, 39 , 39 , 39 , 39 , 39 , 39 , 39 , 39 , 39 , 39 , 39 , 39 , 39 , 39 , 0 , 0, 0,0
	carroFilaLla  DB 0,0, 27, 27, 39 , 39, 39 , 39 , 39 , 39 , 39 , 39 , 39 , 39 , 39 , 39 , 39 , 39 , 39 , 39 , 27, 27,0,0

  ;Variables que pintan carro  verd
	ObsFila1	    db  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	ObsFila2      db 42,44, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,44,42
	ObsFila3      db 44,42,42,42,42,42,42,42,42,42,42,42,42,42,44
	ObsFila4			db	0,42,44,44,44,44,44,44,44,44,44,44,44,42,0

	obl           db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0


	TramLineaH    db 3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3
	ClearH    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	;ClearH    db 3,3,3,3,3,3,3,3,3,3,3,3,3,3,3


	TramLineaV    db 3

	nopause				db  0,0,0,0,0,0,0,0,0,0,0,0,0,'$'
	Un db '0'
  Dn db '0'
  Cn db '0'

	PunteroNivel   dw 0
	TiempoPartida  dw 0
	TiempoRelativo dw 0
	TiempoObs			 dw 0
	TiempoPremio	 dw 0
	AumentoPremio	 dw 4
	DecremeObs		 dw 0
	TD			 dw 0
	TU			 dw 0
	RT       dw 0
	RU       dw 0