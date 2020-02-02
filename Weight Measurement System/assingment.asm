;-------------------Precompilation Mapping-------------------
TRIGPIN  EQU P1.2	; set TRIGPIN to Pin p1.3
ECHOPIN  EQU P1.3	; set ECHOPIN to Pin p1.2
TRIGPIN2 EQU P1.4	; set TRIGPIN2 to Pin p1.4
ECHOPIN2 EQU P1.5	; set ECHOPIN2 to Pin p1.5
TRIGPIN3 EQU P1.6	; set TRIGPIN3 to Pin p1.6
ECHOPIN3 EQU P1.7	; set ECHOPIN3 to Pin p1.7
Rs 		 EQU P2.3	; set Rs to Pin p2.3
Rw 		 EQU P2.4	; set Rw to Pin p2.4
E 		 EQU P2.5	; set E to Pin p2.5

ORG 0000H
SJMP INITMAIN
;ISR space

ORG 0030H
INITMAIN:

;SETUP for Ultrasonic
CLR TRIGPIN ;will be used as trigger
SETB ECHOPIN ;will be used to take echo, used as INPUT

CLR TRIGPIN2 ;will be used as trigger
SETB ECHOPIN2 ;will be used to take echo, used as INPUT

CLR TRIGPIN3 ;will be used as trigger
SETB ECHOPIN3 ;will be used to take echo, used as INPUT

;Timer0 setup
	MOV TL0,#207D
	MOV TH0,#207D
	MOV	SCON, #52H  ; Serial mode 1, enable receiver, set transmist interrupt flag 
	MOV	TMOD, #22H  ; Timer 1 mode 2
	MOV	TH1, #0FDH  ; 9600bps with SMOD=0 for 11.0592MHz crystal
	ANL	PCON, #7FH  ; SMOD=0
	SETB TR1

;used as counter for US
MOV A,#00H

MAIN:
	MOV 81H, #30H ;Copy immediate data 30H to SP 
	ACALL US_SCAN
	PUSH ACC;store acc value
	ACALL US_SCAN2
	PUSH ACC;store acc value
	ACALL US_SCAN3
	PUSH ACC;store acc value
	
	MOV 0F0H,#39
	SUBB A,B
JNC STOP ;simple if else structure
		SJMP CONT
	STOP:
		ACALL OFF
		SJMP MAIN
		
	CONT:
		ACALL SPLIT
		ACALL DISPLAY_LCD
		ACALL DELAY_200ms
		
		
		
SJMP MAIN


OFF:

	
	ACALL EMPTY
	ACALL DELAY_200ms
RET


EMPTY:

	MOV A,#38H;initialization
	ACALL CMD;issuecommand
	MOV A,#0EH;LCDON,cursorON
	ACALL CMD;
	MOV A,#01H;clearLCD
	ACALL CMD;
	MOV A,#06H;shiftcursorright
	ACALL CMD;
	MOV A,#86H;cursor:line1,position6
	ACALL CMD;
	MOV A,#080H;
	ACALL CMD;
	ACALL DELAY 
	MOV A,#'N';display“N”
	ACALL DISPLAY
	ACALL DELAY
	MOV A,#'o';display“o”
	ACALL DISPLAY
	ACALL DELAY
	MOV A,#' ';display“ ”
	ACALL DISPLAY
	ACALL DELAY
	MOV A,#'o';display“o”
	ACALL DISPLAY
	ACALL DELAY
	MOV A,#'b';display“b”
	ACALL DISPLAY
	ACALL DELAY
	MOV A,#'j';display“j”
	ACALL DISPLAY
	ACALL DELAY
	MOV A,#'e';display“e”
	ACALL DISPLAY
	ACALL DELAY
	MOV A,#'c';display“c”
	ACALL DISPLAY
	ACALL DELAY
	MOV A,#'t';display“t”
	ACALL DISPLAY
	ACALL DELAY
RET

US_SCAN: ;<---Corrupt R6--->
	MOV A,#00H
	SETB TRIGPIN;trigger
	ACALL DELAY_10us;delay 10us
	CLR TRIGPIN;stop pulse
	
	BLOCK_ECHO : JNB ECHOPIN,BLOCK_ECHO ;block here until echo is HIGH
	
	;START COUNTING UNTIL P3.1 IS LOW
	TIMER_LOOP:
		SETB TR0;run the timer
		WAIT_OF : JNB TF0,WAIT_OF ;wait until overflow
		CLR TR0
		CLR TF0
		INC A ;every increment of acc is equivalent to 1cm
	JB ECHOPIN,TIMER_LOOP ;if echo is still high, run again
RET

US_SCAN2: ;<---Corrupt R6--->
	MOV A,#00H
	SETB TRIGPIN2;trigger
	ACALL DELAY_10us;delay 10us
	CLR TRIGPIN2;stop pulse
	
	BLOCK_ECHO2 : JNB ECHOPIN2,BLOCK_ECHO2 ;block here until echo is HIGH
	
	;START COUNTING UNTIL P3.1 IS LOW
	TIMER_LOOP2:
		SETB TR0;run the timer
		WAIT_OF2 : JNB TF0,WAIT_OF2 ;wait until overflow
		CLR TR0
		CLR TF0
		INC A ;every increment of acc is equivalent to 1cm
	JB ECHOPIN2,TIMER_LOOP2 ;if echo is still high, run again
RET

US_SCAN3: ;<---Corrupt R6--->
	MOV A,#00H
	SETB TRIGPIN3;trigger
	ACALL DELAY_10us;delay 10us
	CLR TRIGPIN3;stop pulse
	
	BLOCK_ECHO3 : JNB ECHOPIN3,BLOCK_ECHO3 ;block here until echo is HIGH
	
	;START COUNTING UNTIL P3.1 IS LOW
	TIMER_LOOP3:
		SETB TR0;run the timer
		WAIT_OF3 : JNB TF0,WAIT_OF3 ;wait until overflow
		CLR TR0
		CLR TF0
		INC A ;every increment of acc is equivalent to 1cm
	JB ECHOPIN3,TIMER_LOOP3 ;if echo is still high, run again
RET


SPLIT:
	MOV 0F0H,31H
	MOV A,#43
	SUBB A,B
	MOV B,#100
	DIV AB
	MOV A,B
	MOV B,#10
	DIV AB
	MOV R1,A; Multiple of 10
	MOV R2,B; Multiple of 1
	MOV 0F0H,32H
	MOV A,#57
	SUBB A,B
	MOV B,#100
	DIV AB
	MOV A,B
	MOV B,#10
	DIV AB
	MOV R3,A; Multiple of 10
	MOV R4,B; Multiple of 1
	MOV 0F0H,33H
	MOV A,#41
	SUBB A,B
	MOV B,#100
	DIV AB
	MOV A,B
	MOV B,#10
	DIV AB
	MOV R5,A; Multiple of 10
	MOV R6,B; Multiple of 1
RET

DISPLAY_LCD:

MOV A,#38H;initialization
ACALL CMD;issuecommand
MOV A,#0EH;LCDON,cursorON
ACALL CMD;
MOV A,#01H;clearLCD
ACALL CMD;
MOV A,#06H;shiftcursorright
ACALL CMD;
MOV A,#86H;cursor:line1,position6
ACALL CMD;
MOV A,#080H;
ACALL CMD;

MOV A,#'L';display“L”
ACALL DISPLAY;calldatadisplaysubroutine
MOV A,#'=';display“=”
ACALL DISPLAY;
MOV A,R1;display“N”
add A,#30H
ACALL DISPLAY;
ACALL SEND
MOV A,R2;display the value inside R2
add A,#30H
ACALL DISPLAY;
ACALL SEND
MOV A,#'-';
ACALL SEND
MOV A,#'c';display“c”
ACALL DISPLAY;
MOV A,#'m';display“m”
ACALL DISPLAY;

MOV A,#' ';display“ ”
ACALL DISPLAY;
MOV A,#'W';display“W”
ACALL DISPLAY;
MOV A,#'=';display“=”
ACALL DISPLAY;
MOV A,R3;display the value inside R3
add A,#30H
ACALL DISPLAY;
ACALL SEND
MOV A,R4;display the value inside R4
add A,#30H
ACALL DISPLAY;
ACALL SEND
MOV A,#'-';
ACALL SEND
MOV A,#'c';display“c”
ACALL DISPLAY;
MOV A,#'m';display“m”
ACALL DISPLAY;
MOV A,#' ';display“ ”
ACALL DISPLAY;

MOV A,#0C0H;
ACALL CMD;


MOV A,#'H';display“H”
ACALL DISPLAY;
MOV A,#'=';display“=”
ACALL DISPLAY;
MOV A,R5;ddisplay the value inside R5
add A,#30H
ACALL DISPLAY;
ACALL SEND
MOV A,R6;display the value inside R6
add A,#30H
ACALL DISPLAY;
ACALL SEND
MOV A,#0AH
ACALL SEND
MOV A,#'c';display“c”
ACALL DISPLAY;
MOV A,#'m';display“m”
ACALL DISPLAY;

RET;

SEND:	
	JNB	TI, SEND
	CLR	TI
	MOV	SBUF, A
RET	    
    

CMD:MOV P0,A;issuecommandcode
CLR RS;clearRS=0,forcommand
CLR RW;clearR/W=0,towritetoLCD
SETB E;setE=1
CLR E;clearE=0,togenerateanH-to-Lpulse
ACALL DELAY;giveLCDsometime

RET;

DISPLAY:
MOV P0,A;issuedata
SETB RS;setRS=1,fordata
CLR RW;clearR/W=0,towritetoLCD
SETB E;setE=1
CLR E;clearE=0,togenerateanH-to-Lpulse
ACALL DELAY;giveLCDsometime
RET;

DELAY:
MOV R0, #250
DJNZ R0, $
RET

;--------------------------DELAY SUBROUTINES-------------------------------

DELAY_1ms: ;delay for 1ms subroutine <---Corrupts R6 and R7--->
	MOV R6,#0FAH 
	MOV R7,#0FAH
	D1usL1: DJNZ R6,D1usL1 ;Additive wait algorithm
	D1usL2: DJNZ R7,D1usL2 
RET

DELAY_200ms: ;delay for 200ms subroutine <---Corrupts R5,R6 and R7--->
	MOV R5,#200
	D200usL1:
		ACALL DELAY_1ms
		DJNZ R5,D200usL1
RET

DELAY_10us: ;delay for 10us subroutine <---Corrupts R6--->
	MOV R6,#05H;DJNZ uses 2 machine cycles, 2 us
	D10usL1: DJNZ R6,D10usL1
RET

DELAY2:
    MOV R0, #10
RPT1:    
    MOV R1, #250
RPT2:    
    MOV R2, #250
RPT3:
    NOP
    NOP
    DJNZ R2, RPT3
    DJNZ R1, RPT2
    DJNZ R0, RPT1
RET

END