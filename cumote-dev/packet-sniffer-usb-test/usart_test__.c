#include <mega644.h>
	#ifndef __SLEEP_DEFINED__
	#define __SLEEP_DEFINED__
	.EQU __se_bit=0x01
	.EQU __sm_mask=0x0E
	.EQU __sm_powerdown=0x04
	.EQU __sm_powersave=0x06
	.EQU __sm_standby=0x0C
	.EQU __sm_ext_standby=0x0E
	.EQU __sm_adc_noise_red=0x02
	.SET power_ctrl_reg=smcr
	#endif
#include "cumote_hal.h"
        MOV R16,R12
        ld R26,y  ; load t into r26. y register is stack pointer. t is lowest on stack.
        clr R27   ; promote t to unsigned int

        cpi R16,0 ; see if r12 is 0
        breq startdelay   ; branch to starting delay...       overhead is now a bit more than 5 cycles.
   preploop:         ;~5 more cycles
        lsl R26  ; multiply t by 2
        rol R27
        dec R16
        cpi R16,0
        brne preploop
   startdelay:                      ;overhead: t=0...5. t=1...10. t=2...15. t=3...20. t=4...25.
        subi R26,3     ; lo byte
        sbci R27,0     ; hi byte, with carry
        brmi enddelay      ; if result is negative, end loop, done with delay.
   enddelay:
#include "mega644_usart.h"

unsigned int ms_counter;

interrupt [TIM1_COMPA] void handle_tim1(void) {
    if (ms_counter > 0)
        ms_counter--;
}


void main(void)  {
    unsigned char my_msg[15];
    unsigned char *string_head;
    unsigned char i;
    COM_init();
    COM_set_MCU_clock(3);
    HAL_initialization();

    DDRD.7 = 1;
    PORTD.7 = 0;

    // timer initialization
    TCCR1A = 0b00000000;
    OCR1AH = 1;
    OCR1AL = 0b11110100;
    TCCR1B = 0b00001010; // clk/8... count to 500 for 1ms at 4MHz.
    TCCR1C = 0;
    TIMSK1 = 0b00000010;  // interrupt on compare A match

    m644_init_usart();  // attempt high speed connection


    #asm
        sei
    #endasm

    ms_counter = 1000;  // one second
    string_head = my_msg;
    for (i=0; i<4; i++) {
        my_msg[i] = 0xff;  // preamble
    }
    my_msg[4] = 15;
    for (i=0; i<15; i++)  {
        my_msg[i+5] = i;
    }

    while(1)  {
        if (ms_counter == 0)  {
            ms_counter = 1000;  // reset counter
            m644_add_message(string_head,20);
            m644_start_tx();
        }
    }
}
