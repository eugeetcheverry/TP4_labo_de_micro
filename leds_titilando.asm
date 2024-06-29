 .include "m328pdef.inc"


 .def aux_SREG = r22
 .def vleds = r23
 .def rleds = r24
 .org SRAM_START

.cseg

.org 0X0000
	rjmp main

.org OC1Aaddr
	rjmp toggle_leds

main:
	;Inicializo stack-pointer
	ldi r16, low(RAMEND)
	out spl, r16
	ldi r16, high(RAMEND)
	out sph, r16

	;inicializo los puertos 
	ldi r16, 0b01011111
	out ddrc, r16

	ldi r16, 0b00001111
	out ddrb, r16 

	rcall leds_titilando

wait: 
	rjmp wait

/*leds_titilando
	ldi r16, 0b10000000
	out TCCR1A, r16
	ldi r16, 0x0f
	out OCR1AH, r16
	ldi r16, 0b00111100
	ldi OCRIAL, r16
	ldi r16, 0x02
	sts TIMSK1, r16
	sei ; Habilito las interrupciones globales
	ldi rleds, 6
	ldi vleds, 0x0f
	ldi r16, 0b00001101
	sts TCCR1B, r16; cuando seteamos el prescaler 64 arranca a contar


toggle_leds: 
	out PINC, vleds 
	out PINB, vleds ; haciendo con toggle
	reti*/

leds_titilando:
	cli
	ldi r16, 0b10000000
	sts TCCR1A, r16
	ldi r16, 0x0f ;para una frecuencia de 2hz
	sts OCR1AH, r16
	ldi r16, 0b00111100 ;para una frecuencia de 2hz
	sts OCR1AL, r16
	clr r16
	sts TIMSK1, r16 ; TIFR1 1
	sei
	ldi rleds, 6
	ldi vleds, 0b00001111
	ldi r16, 0b00001101
	sts TCCR1B, r16
toggle_leds:
	sbis TIFR1, 1
	rjmp toggle_leds
	dec rleds
	cpi rleds, 0
	breq fin_timer
	out PINC, vleds 
	out PINB, vleds 
	sbi TIFR1, 1
	rjmp toggle_leds; haciendo con toggle
fin_timer:
	clr r16
	sts TCCR1B, r16
	out PORTC, r16
	out PORTB, r16
	ret






