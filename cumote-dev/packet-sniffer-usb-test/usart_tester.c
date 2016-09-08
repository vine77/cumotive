#include <mega644.h>
#include "cumote_hal.h"
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