#include <mega644.h>   
#include "cumote_hal.h"
#include "mega644_usart.h" 
    
//unsigned int ms_counter;

/*
Program description:
   Program listens on Channel 13 for incoming data. On reception, it packages up a message and relays it over the USART through the USB to the pd or MAX module.
   This is derived from packet sniffer code.
*/


/*interrupt [TIM1_COMPA] void handle_tim1(void) {
    if (ms_counter > 0)
        ms_counter--;
} */

//void usart_rx_ack(void);
void usart_rx_preamble(unsigned char size);

void main(void)  {    
    unsigned char i;
    unsigned char my_msg[4];
    COM_init();
    COM_set_MCU_clock(3);   // set clock to 4 MHz
    COM_enable_interrupt_IRQ();
    HAL_initialization();
    
    // timer initialization
/*    TCCR1A = 0b00000000;
    OCR1AH = 1;
    OCR1AL = 0b11110100;
    TCCR1B = 0b00001010; // clk/8... count to 500 for 1ms at 4MHz.
    TCCR1C = 0; 
    TIMSK1 = 0b00000010;  // interrupt on compare A match*/
    
    m644_init_usart();  // attempt high speed connection
    
//    ms_counter = 500;  // one half second
    
    #asm
        sei
    #endasm             
    
    HAL_set_state(STATUS_TRX_OFF);  // initialize radio's state
            
    HAL_set_radio_channel(13); // switch to channel 13
    HAL_set_state(STATUS_RX_ON);  // turn receiver on
    
    while(1)  {    // need to check certain flags in usart module periodically and act appropriately                                                                       
        if (COM_IRQ_pending == 1)  {  // radio has info for the application
            COM_IRQ_handler();  // check to see what the IRQ was
            if (COM_IRQ_status == IRQ_RX_START)  {
                COM_upload_frame();  // upload the frame from the radio
                for (i=0;i<3;i++)  {
                    my_msg[i] = HAL_rx_frame[i];
                }                               
                my_msg[3] = HAL_LQI;
                // now, transmit the data over the USART.
                // first, transmit the preamble and message size                  
                usart_rx_preamble(HAL_rx_frame_length+1);
                // then, pass the usart the pointer to the 802.15.4 message string
                m644_add_message(my_msg,HAL_rx_frame_length+1);
                m644_start_tx();
            }
            else if (COM_IRQ_status == IRQ_TRX_END)  {  // either we missed the RX_START IRQ or this is just happening at the end of a received frame that we've already started downloading.
            }
        }            
    }
}                       

void usart_rx_preamble(unsigned char size)  {  // pass the size of the message to come
    unsigned char preamble[5];
    preamble[0] = preamble[1] = preamble[2] = preamble[3] = 0xff;
    preamble[4] = size;
    m644_add_message(preamble,5);  
    m644_start_tx(); 
    while (busy_flag == 1); // wait for preamble to finish transmitting
}