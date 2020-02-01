
.include "m16def.inc"	
 jmp reset
.org INT1addr  ; gia ack sirinas kai stop
 jmp INT1handler
.org OVF1addr
 jmp timer1handler
.cseg
.def A1=r21    ; apothikefsi timwn aisthitirwn varous
.def B1=r22 
.def B2=r23
.def B3=r24
.def B4=r25
.def ALL=r26 ;0bxxxxxQ2Q1Y
.def led_manipulator=r28    ; diaxeirisi leds
.def temp=r27

reset:

sp_init:     
	ldi r16,low(RAMEND)            ;arxikopoihsh stack pointer
	out spl,r16
	ldi r16,high(RAMEND)
	out sph,r16

switch_init:
	clr r17
	out DDRD,r17
	ser r17				           ;arxikopoihsh switch D
    out PIND,r17
led_init:
	ser r16				            ;initiallize led B
	out DDRB,r16
	ser r16
	out PORTB,r16
a_init:
	clr r17
	out DDRA,r17
	ser r17				           ;arxikopoihsh A
    out PINA,r17
    ser led_manipulator
	subi led_manipulator,0b00100000
	out PORTB,led_manipulator
	
b_init:
	ser r16
	out DDRC,r16
	clr r17				           ;arxikopoihsh C
    out PORTC,r17



interrupt_init:

ldi r17, (1 << ISC11)
sts MCUCR , r17

in r17, GICR 
ori r17, (1<<INT1)
out GICR, r17
sei

ldi r17 ,(1<< TOIE1)
out TIMSK ,r17  ;set to interrupt tou timer1


main:
call start
main_job:
call Input_Pot    
call silo_1
call silo_2
jmp main_job

Input_Pot:        ADC metatropes timwn aisthitirwn
ldi r16,0b11100000
out ADMUX,r16
sbi ADCSRA,7
sbi ADCSRA,6

cnv0:
sbic ADCSRA,6
jmp cnv0

in r18,ADCH
mov A1,r18
;out PORTB,r18
ldi r16,0b11100001
out ADMUX,r16
sbi ADCSRA,7
sbi ADCSRA,6

cnv1:
sbic ADCSRA,6
jmp cnv1

in r18,ADCH
mov B1,r18
;out PORTB,r18
ldi r16,0b11100010
out ADMUX,r16
sbi ADCSRA,7
sbi ADCSRA,6

cnv2:
sbic ADCSRA,6
jmp cnv2

in r18,ADCH
mov B2,r18
;out PORTB,r18
ldi r16,0b11100011
out ADMUX,r16
sbi ADCSRA,7
sbi ADCSRA,6

cnv3:
sbic ADCSRA,6
jmp cnv3

in r18,ADCH
mov B3,r18
;out PORTB,r18
ldi r16,0b11100100
out ADMUX,r16
sbi ADCSRA,7
sbi ADCSRA,6

cnv4:
sbic ADCSRA,6
jmp cnv4

in r18,ADCH
mov B4,r18
ret

start:              ; routines gia elegxo prin tin ekkinisi
call Input_Pot
call check_A1_to_open_led
call check_Y


in r20,PIND         ; anamoni gia patima diakopti ekkinisis
andi r20,0b00000001
cpi r20,0b00000000
breq start_is_pressed

jmp start

start_ton_imanta:    ; ksekinaei o imantas, thetoume prescaler kai timi ston timer gia na metrisei 7 deyterolepta

ldi r17, (1 << CS10)
out TCCR1B ,r17
ldi r17 ,(0 << CS11)
out TCCR1B ,r17
ldi r17 ,(1 << CS12)
out TCCR1B ,r17       ; thetoume prescaler =1024


sei                     ;set global interrupts  

ldi r17,HIGH(3000)       ;ksekinaei o timer
out TCNT1H,r17
ldi r17, LOW(3000)
out TCNT1L , r17

wait_timer:       ; vroxos anamonis gia na epistrepsei otan gyrisei apo ton interrupt handler tou timer
jmp wait_timer

timer1_finished:
                          
andi led_manipulator,0b00001001        ;leds arxikis leitourgias
   
out PORTB,led_manipulator

looop:
call Input_Pot            ; ksana elegxos varous, aisthitirwn uperthermansis silo2
call check_B2
call check_q1
call check_q2
jmp looop

ddd:
jmp start


silo_1:            ;elegxos gia epilogi paroxea ylikou sto silo1
in r20,PIND
andi r20,0b00000010
cpi r20,0b00000000
breq silo_1_is_pressed
ret

silo_2:           ;elegxos gia epilogi paroxea ylikou sto silo2
in r20,PIND
andi r20,0b00000100
cpi r20,0b00000000
breq silo_2_is_pressed
ret


start_is_pressed:     ;patithike to start elegxontai vari kai ksekinaei o imantas
;energopoihsh rele run
call check_A1
call check_B1
call check_B3
mov temp,led_manipulator
andi temp,0b00100000
cpi temp,0b00000000
breq start_ton_imanta      ;an ta vari einai ok ksekinaei o imantas
cpi temp,0b00000000        
brne ddd     

silo_1_is_pressed:     ;energopoihsh led gia silo1
ldi r20,0b11011110     
out PORTB,r20          
ret

silo_2_is_pressed:    ;energopoihsh led gia silo2
ldi r20,0b11111010
out PORTB,r20
ret

check_A1_to_open_led:     ;elegxos paroxis ylikou sto megalo silo gia na anapsei to katallilo led
cpi A1,50
brsh open_led1
cpi A1,50
brlo close_led1
ret

close_led1:           ;kleinoume to led1 an den yparxei arketo yliko
mov temp,led_manipulator
andi temp,0b00000010
cpi temp,0b00000010
breq skippp
adiw led_manipulator,2 ;0b00000010
out PORTB,led_manipulator
skippp:
ret

open_led1:              ;anoigoume to led1 an yparxei yliko
mov temp,led_manipulator
andi temp,0b00000010
cpi temp,0b00000000
breq skip
subi led_manipulator,2 ;0b00000010
out PORTB,led_manipulator
skip:
ret

check_A1:       ;elegxos timis aisthitira varous a1(megalo silo)
cpi A1,50
brlo siren
ret

check_B1:       ;elegxos timis aisthitirwn varous silo1
cpi B1,50
brsh branch_out_of_reach
ret


check_B2:       
cpi B2,200
brsh change_silo_2
ret


check_B3:     ;elegxos timis aisthitirwn varous silo2
cpi B3,50
brsh branch_out_of_reach
ret

branch_out_of_reach:
jmp start

check_B4:
call check_q1
call check_q2
cpi B4,200
brsh end
ret
 
end:          ;telos diadikasias anavei to led3
ldi led_manipulator,0b11110111
out PORTB,led_manipulator
jmp end

change_silo_2:        ; allagi se silo2
ldi led_manipulator,0b00100001
out PORTB,led_manipulator
loopa:
call check_B4
jmp loopa

check_Y:         
in temp,PIND
andi temp,0b00000110
cpi temp,0b00000100
breq Y1
cpi temp,0b00000010
breq Y2
ret

Y1:
mov temp,led_manipulator
andi temp,0b00100000
cpi temp,0b00000000
breq skip1
subi led_manipulator,0b00100000
out PortB,led_manipulator
skip1:
mov temp,led_manipulator
andi temp,0b00001000
cpi temp,0b00001000
breq skip11
adiw led_manipulator,0b00001000
out PortB,led_manipulator
skip11:
ret

Y2:
mov temp,led_manipulator
andi temp,0b00001000
cpi temp,0b00000000
breq skip_1
subi led_manipulator,0b00001000
out PortB,led_manipulator
skip_1:
mov temp,led_manipulator
andi temp,0b00100000
cpi temp,0b00100000
breq skip_11
adiw led_manipulator,0b00100000
out PortB,led_manipulator
skip_11:
ret


siren:           ; sirina 
ldi led_manipulator,0b11011110   
out PORTB,led_manipulator
siren1:
ldi temp,0b11111111        ;anoigei i sirina
out PORTC,temp
wait_ACK:
in temp,PIND
andi temp,0b01000000 ; ektos apo to sw2 gia interrupt patame kai to sw6 gia ack opote an exei patithei gyrname ekei pou imastan
cpi temp,0b00000000
breq siren_stopped
jmp wait_ACK

siren_stopped:

timer_1sec:

ldi r17,HIGH(57723)      ;ksekinaei o timer
out TCNT1H,r17
ldi r17, LOW(57723)
out TCNT1L , r17
ldi r20,0b11111111
ldi r17, (1 << CS10)
out TCCR1B ,r17
ldi r17 ,(0 << CS11)
out TCCR1B ,r17
ldi r17 ,(1 << CS12)
out TCCR1B ,r17       ;; thetoume prescaler =1024

sei  ;set global interrupts

again:   ; an patithei start pame stin leitourgia ekkinisis
in r21,PIND
andi r21,0b00000001
cpi r21,0b00000000
breq reset2
jmp again

reset2:    ; stamatame ton timer prin pame se leitourgia ekkinisis
ldi r17,0
out TCCR1B,r17
ldi led_manipulator,0b11111111

jmp start

int1handler: ;ACK i STOP patithike 
push r17
in r17, SREG
push r17

mov r17,led_manipulator  ;elegxos mesw twn leds an prokeitai gia stop h ack
andi r17,0b00000001
cpi r17,0b00000000
breq ack_pressed

stop1:         ; an paixtei stop perimenoume na patithei to sw0 gia restart
ori led_manipulator,0b11010100   
out PORTB,led_manipulator
call Input_Pot              ; synexizoume na elegxoume gia vari an exei patithei stop
call check_A1_to_open_led
call check_Y
wait_return:
in r17, PIND
andi r17,0b00000001   ;gia epistrofi stop pataw sw0
cpi r17,0b00000000
breq reset1
jmp wait_return
sei
jmp stop1
reset1:
andi led_manipulator,0b01111111   
out PORTB,led_manipulator
pop r17
out SREG, r17
pop r17
reti
ack_pressed:   ;exei patithei ack ara sirina kai anavosvima ana 1 sec
ldi r17,0b00000000 ; svinoume sirina
out PORTC,r17
pop r17
out SREG, r17
pop r17      
reti 
    
timer1handler:

push r17
in r17, SREG
push r17
 
mov r17,led_manipulator
andi r17, 0b00000001 ;vlepw poios timer einai ,an led0(error) kleisto einai o timer ekkinisis
cpi r17,0b00000000
breq one_sec

seven_secs:  ; epta deytera perasan apla epistrefoume stin ekkinisi
pop r17
out SREG, r17
pop r17
sei
jmp timer1_finished

one_sec: 
cpi r20,0b11111110
breq close
cpi r20,0b11011110
breq close
open:              ; an sto proigoumeno interrupt ekleise to anoigw
ldi r20,0b11111110     
andi r20,0b11011111
out PORTB,r20
jmp loop
close:            ; an sto proigoumeno interrupt anoikse to kleinw
ldi r20,0b11111111
andi r20,0b11011111   
out PORTB,r20      ; etsi kathe 1 sec pou ginetai interrupt anavei i svinei 
loop:

in r17,PIND
andi r17,0b00000001       ; an patithei start fevgoume se leitourgia ekkinisis
cpi r17,0b00000000
breq endd
ldi r17,HIGH(57723)      ;settaroume ksana ton timer gia nea metrisi (allo ena sec) .ayto epanalamvanetai kathe fora pou metraei ena sec mexri 
out TCNT1H,r17           ;na patisoume sw0.
ldi r17, LOW(57723)
out TCNT1L , r17
ldi r20,0b11111111
ldi r17, (1 << CS10)
out TCCR1B ,r17
ldi r17 ,(0 << CS11)
out TCCR1B ,r17
ldi r17 ,(1 << CS12)
out TCCR1B ,r17     

pop r17
out SREG, r17
pop r17
 
endd:
reti


check_q1:  ;elegxos asthitira yperthermansis q1 me polling
in r29,PIND
andi r29,0b00010000 
cpi r29,0b00000000
breq step
ret


check_q2:     ;elegxos airthitira yperthermansis q2 me polling
in r29,PIND
andi r29,0b00100000 
cpi r29,0b000000000
breq step
ret

step:      ;anavoume ta katallila leds kai jump sti sirina
ori led_manipulator,0b11010010
out PORTB,led_manipulator
jmp siren


