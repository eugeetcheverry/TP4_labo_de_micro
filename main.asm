/*a) Escriba un programa usando el Timer 0 para generar una se�al cuadrada de 1000 Hz en el pin
PC2.*/

/*Tenemos que la frecuencia del erloj del sistema es de 16MHz
A 1kHz de frecuencia tenemos un pe�odo de T=1ms.     0xe0*/
/*
.include "m328pdef.inc"

.def salida = r17
.def mask = r18

.cseg
.org 0x0000
	rjmp main

.org OC0Aaddr
	rjmp interrupt

main:
	; Inicializo el Stack Pointer
	ldi r16, LOW(RAMEND)
	out spl, r16
	ldi r16, HIGH(RAMEND)
	out sph, r16

	; Configuro la salida
	ldi r16, 0x04
	out DDRC, r16 ; Tenemos la salida en el PINC2

	; Configuro el timer 0
	ldi r16, 0b10000010
	out TCCR0A, r16

	ldi r16, 0x7d
	out OCR0A, r16

	ldi r16, 0x02
	sts TIMSK0, r16

	sei ; Habilito las interrupciones globales

	clr salida
	ldi mask, 0x04

	out PORTC, salida ; salida inicial en 0

	ldi r16, 0b00000011
	out TCCR0B, r16 ; cuando seteamos el prescaler 64 arranca a contar

main_loop:
	rjmp main_loop

interrupt: 
	ldi salida, 0b00000100
	out PINC, salida  ; haciendo con toggle
	reti */


/*Escriba un programa que genere una onda cuadrada de 500 Hz en el pin PB1. Luego de la
configuraci�n inicial, el micro debe quedar en un bucle infinito sin ejecutar ning�n tipo de l�gica y
las interrupciones deben estar deshabilitadas.*/
/*
.include "m328pdef.inc"

.cseg
.org 0x0000
	rjmp main

main:
	; Inicializo el Stack Pointer
	ldi r16, LOW(RAMEND)
	out spl, r16
	ldi r16, HIGH(RAMEND)
	out sph, r16

	; Configuro la salida
	ldi r16, 0x02
	out DDRB, r16

	; Configuro el CTC
	ldi r17, 0b10000000
	sts TCCR1A, r17
	ldi r17, 0b00001101 ; los ultimos tres bits son el prescaler
	sts TCCR1B, r17

	ldi r17, 250
	sts OCR1AL, r17

	cli ; Deshabilito las interrupciones

fin:
	rjmp fin */


/*Conectar un pulsador al pin PB1 (usando R de pull-up interna) y un led al PB2 con una resistencia
limitadora de corriente. Cuando se presiona la tecla el programa debe incrementar la intensidad
del led. Al llegar a la m�xima intensidad el siguiente paso lo apagar� completamente. La cantidad
de pasos ser� definida por el programador, pero debe ser mayor a 8.
El programa se debe resolver utilizando el modo PWM del timer. Se debe considerar que la tecla
tiene rebote y se usar� un timer para esperarlo de forma no bloqueante.*/

.include "m328pdef.inc"

.def contador = r18

.cseg
.org 0x0000
	rjmp main

.org PCI0addr
	rjmp interrupciones

.org OC0Aaddr
	rjmp anti_rebote

.org INT_VECTORS_SIZE

main:
	; Inicializo el Stack Pointer
	ldi r16, LOW(RAMEND)
	out sph, r16
	ldi r16, HIGH(RAMEND)
	out spl, r16

	; Configuro la entrada y salida
	ldi r16, 0x04 ; Necesito el PB1 como entrada y el PB2 como salida
	out DDRB, r16
	ldi r16, 0x02
	out PORTB, r16 ; Configuro la resistencia de PULL-UP

	; Configuro el timer 1
	ldi r16, 0b00100001
	sts TCCR1A, r16

	; Configuracion interrupcion de pinchange
	ldi r16, 0X01
	sts PCICR, r16
	ldi r16, 0X02
	sts PCMSK0, r16 

	; Configuro interrupcion timer 0 para anti rebote
	ldi r16, 0b10000010 ; uso modo ctc, me baso en overflow
	out TCCR0A, r16

	ldi r17, 255
	out OCR0A, r17

	ldi r16, 0x02
	sts TIMSK0, r16

	ldi r16 , 0x02
	out TIFR0 , r16

	clr contador
	ldi r19, 10

	sei ; Habilito interrupciones globales

	ldi r16, 0b00001100 ; prescaler en 256, 
	sts TCCR1B, r16


main_loop:
	rjmp main_loop

interrupciones:
	add contador, r19
	sts OCR1BL, contador
	ldi r16, 0b00000100
	out TCCR0B, r16
	reti

anti_rebote:
	cpi contador, 247
	breq casi_fin
	reti

casi_fin:	
	cli
fin:
	rjmp fin 
