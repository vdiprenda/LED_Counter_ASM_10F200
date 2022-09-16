; 
; File:     LEDCounterMain.as
; Target:   PIC10F200
; Author:   VJD
; Date:     2022-09-16
; Compiler: pic-as(v2.30)
; IDE:      MPLABX v5.40
; CERTIFIED : 
;   
; Let's create a counter, and every time we increment, put on the appropriate
; leds. We have to reset the counter when it turns to8
;
; Description:
;
;   Example 2 project for the PIC10F200 controller using the pic-as(v2.31) 
;    tool chain.
;
; Add this line in the project properties box 
;    "pic-as Global Options -> Additional options": 
;
;   -Wa,-a -Wl,-DCODE=2,-pStartCode=0h,-pResetVec=0ffh 
; 
    PROCESSOR   10F200
    PAGEWIDTH   132
    RADIX       dec
;
; Include target specific definitions for special function registers
;
#include <xc.inc>
;
; Set the configuration word
;
 config WDTE = OFF       ; Watchdog Timer (WDT disabled)
 config CP = OFF         ; Code Protect (Code protection off)
 config MCLRE = ON       ; Master Clear Enable (GP3/MCLR pin function  is MCLR)
;
; Declare one byte in RAM
;
    PSECT   MainData,global,class=RAM,space=1,delta=1,noexec
    global  Delay_v1, Delay_v2, Counter, LED_Mask
Temp:       DS      1
Delay_v1:   DS      1
Delay_v2:   DS      1
Counter:    DS      1
LED_Mask:    DS	    1
;
; See: 
; https://electronics.stackexchange.com/questions/550331/
;     pic10f200-blinking-led-pic-as-assembly
;
    PSECT   StartCode,class=CODE,delta=2
    global  Start
Start:
    movwf   OSCCAL      ;Set factory default for the oscillator calibration
    ;osccal register is at 05h

    movlw   11000000B
    option              ;to turn off T0CKI

#ifdef CMCON0           ;CMCON0 is at 07h, but it exists only for the PIC10F206
    movlw   01110001B   ;bit 3 to 0 for turning comparator off
    movwf   CMCON0
#endif

    movlw   11111000B   ;set GP0,GP1,GP2 to output direction
    tris    GPIO
    movlw   00000000B
    movwf   Counter	; The counter will be the physical count that gets inc
    movwf   LED_Mask	; The mask will be the counter with bit 3 set '1xxx'
    
Loop:
    movf    Counter, 0	; move the value of Counter to w
    IORLW   1000B	; inclusive or the counter with '1000' -> w
    movwf   LED_Mask	; move w to the LED_MASK
    movf    LED_Mask,0
    
    ;; BCF     GPIO,LED_Mask
    MOVWF   GPIO
    call    Delay
    call    Delay
    call    Delay
    call    Delay
    call    Delay
    call    Delay
    call    Delay
    call    Delay
    call    Delay
    
    ;; BSF     GPIO,LED_Mask ;turn LED off again
    MOVLW   1000B
    MOVWF   GPIO
    call    Delay
    call    Delay
    call    Delay
    call    Delay
    call    Delay
    call    Delay
    call    Delay
    call    Delay
    call    Delay
    call    Delay
 
    INCF    Counter,1 
    goto    Loop        ;loop forever
    
Delay:
    movlw   100         ;put the decimal number 100 into w
    movwf   Delay_v1    ;put 100 in register 0Ah
    ;register 11h should be general purpose register that I can use
    ;to put in values
    movwf   Delay_v2
    ;put 100 in 12h
Delay_Loop:
    DECFSZ  Delay_v1,F
    ;decrement the register and store the result in itself
    ;and skip the next instruction if the result was zero
    goto    Delay_Loop
    
    DECFSZ  Delay_v2,F
    ;the same with the second register that I filled
    goto    Delay_Loop
    retlw 0
;
; The PIC10F200 reset vector is the highest 
; instruction word in the code space.
;
; This is used to load the WREG with the factory 
; oscillator calibration value then  the program 
; counter rollover to zero to start the code.
;
    PSECT   ResetVec,class=CODE,delta=2
    global  ResetVector
ResetVector:

    end     ResetVector 