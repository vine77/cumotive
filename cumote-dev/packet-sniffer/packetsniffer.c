#include <mega644.h>   
#include "cumote_hal.h"
#include "mega644_usart.h"
     
unsigned int ms_counter;

/*
Program description:
    Program will initialize everything on boot and wait for input from C++ program. 
    C++ program will set the listening channel and tell sniffer to start listening
    Sniffer will then turn RX on and report any events via the USART.
*/

// Sniffer States                         
#define     INIT    0
#define     WAIT    1
#define     RUNNING 2     
#define     TEST    3 
#define     ENERGY_DETECTION 4

// USART Rx States
#define     RX_WAIT     0
#define     RX_SET_CHAN 1

#define     RX_ACK      0xdd    // pre-define 0xdd to tell visual c++ program that we're done receiving   
#define     RX_ED       0xaa

//usart rx commands
#define     RX_CMD_SET_CHAN     0xab
#define     RX_CMD_RUN          0xca
#define     RX_CMD_HALT         0x9d  
#define     RX_CMD_ED           0xba  // energy detection

unsigned char ack[4] = {0xff,0xff,0xff,0xdd};
unsigned char *g_ack_head = ack;
unsigned char preamble[5] = {0xff,0xff,0xff,0xff,0x00};  // last byte of preamble will hold message size
unsigned char *g_preamble_head = preamble;  
unsigned char ed_preamble[4] = {0xff,0xff,0xff,0xaa};
unsigned char *g_ed_preamble_head = ed_preamble;


interrupt [TIM1_COMPA] void handle_tim1(void) {
    if (ms_counter > 0)
        ms_counter--;
}

void usart_rx_ack(void);
void usart_rx_preamble(unsigned char size);
void usart_rx_ed_preamble(void);

void main(void)  {
    unsigned char my_msg[255];    // big enough to hold any single message
    unsigned char *string_head;   // make sure we keep track of start of array
    unsigned char ack_msg[4];
    unsigned char *ack_head;
    unsigned char i;        
    unsigned char sniffer_state;  // keep track of what sniffer's doing
    unsigned char rx_state;       // keep track of what usart rx state machine is doing
    unsigned char my_rx_data;
    
    sniffer_state = INIT;
    COM_init();
    COM_set_MCU_clock(3);   // set clock to 4 MHz
    COM_enable_interrupt_IRQ();
    HAL_initialization();
    
    // timer initialization
    TCCR1A = 0b00000000;
    OCR1AH = 1;
    OCR1AL = 0b11110100;
    TCCR1B = 0b00001010; // clk/8... count to 500 for 1ms at 4MHz.
    TCCR1C = 0; 
    TIMSK1 = 0b00000010;  // interrupt on compare A match
    
    m644_init_usart();  // attempt high speed connection
    
    ms_counter = 500;  // one half second
    
    #asm
        sei
    #endasm
    
    rx_state = RX_WAIT;    
    
    HAL_set_state(STATUS_TRX_OFF);  // initialize radio's state
        
    string_head = my_msg;
    for (i=0; i<4; i++) {
        my_msg[i] = 0xff;  // preamble
    }                                 
    my_msg[4] = 15;
    for (i=0;i<15;i++)  {
        my_msg[i+5] = i;
    }
                  
    ack_head = ack_msg;
    for (i=0; i<3; i++)  {
        ack_msg[i] = 0xff;
    }                     
    ack_msg[3] = 0xdd;
    
    sniffer_state = WAIT;
    
    /// todo: separate the two state machines for cleaner code. 
        
    while(1)  {    // need to check certain flags in usart module periodically and act appropriately        
        //First, check for messages.
        if (is_buffer_empty() == 0)  {
            my_rx_data = get_usart_byte();  // get the message from the buffer.
            
            // first, check special case RX events
            if (rx_state == RX_SET_CHAN)  {
                HAL_set_radio_channel(my_rx_data);
                rx_state = RX_WAIT;
                usart_rx_ack();  // acknowledge successful channel change
            }
            else if (rx_state == RX_WAIT)  {
                if (my_rx_data == RX_CMD_RUN)  {
                    HAL_set_state(STATUS_RX_ON);  // turn rx on if it's off
                    sniffer_state = RUNNING;         
                    usart_rx_ack();
                }
               
                else if (my_rx_data == RX_CMD_HALT)  {
                    HAL_set_state(STATUS_TRX_OFF);  // turn rx off if it is on
                    sniffer_state = WAIT;
                    usart_rx_ack();
                }
            
                else if (my_rx_data == RX_CMD_ED)  {
                    HAL_set_state(STATUS_RX_ON);  // turn rx on
                    sniffer_state = ENERGY_DETECTION;
                    usart_rx_ack();
                    ms_counter = 0;
                }
            
                else if (my_rx_data == RX_CMD_SET_CHAN)  {
                    rx_state = RX_SET_CHAN;
                }
            }
        }
        
        if (sniffer_state == WAIT)  {
            // for now, just do nothing. wait.
        }                                     
        
        else if (sniffer_state == RUNNING)  {
            if (COM_IRQ_pending == 1)  {  // radio has info for the application
                COM_IRQ_handler();   // figure out what the IRQ is.
                if (COM_IRQ_status == IRQ_RX_START)  {
                    COM_upload_frame();  // upload the frame from the radio
                    // now, transmit the data over the USART.
                    // first, transmit the preamble and message size                  
                    usart_rx_preamble(HAL_rx_frame_length);
                    // then, pass the usart the pointer to the 802.15.4 message string
                    while(busy_flag == 1);
                    m644_add_message(HAL_rx_frame,HAL_rx_frame_length);
                    m644_start_tx();
                }
                else if (COM_IRQ_status == IRQ_TRX_END)  {  // either we missed the RX_START IRQ or this is just happening at the end of a received frame that we've already started downloading.
                }
            }                        
        }
        
        else if (sniffer_state == ENERGY_DETECTION)  {
            if (ms_counter == 0)  {
                for (i=11;i<=26;i++)  {  // iterate through the channels and form a message to send
                    HAL_set_radio_channel(i);
                    HAL_set_state(STATUS_RX_ON);
                    my_msg[i-11] = HAL_energy_detection();
                    HAL_set_state(STATUS_TRX_OFF);                
                }
                usart_rx_ed_preamble();
                while(busy_flag == 1);
                m644_add_message(string_head,16);
                m644_start_tx();
                while(busy_flag == 1);
                ms_counter = 50; // wait a little bit before taking the next sample             
            }            
        } 
          
        else if (sniffer_state == TEST)  {  // use just for testing USB connection... tests the ACK.
            while(busy_flag == 1);
            while(ms_counter > 0);
            m644_add_message(ack_head,4);
            m644_start_tx();      
            ms_counter = 100;
        }        
    }
}                       

void usart_rx_ack(void)  {
    while(busy_flag == 1);
    m644_add_message(g_ack_head,4);  // send a one byte response. 3 bytes of ff, then one command byte. In this case, ack.
    m644_start_tx();
}     

void usart_rx_preamble(unsigned char size)  {  // pass the size of the message to come
    preamble[4] = size;    
    while (busy_flag == 1);  // wait until we can transmit safely
    m644_add_message(g_preamble_head,5);  
    m644_start_tx();
}         

void usart_rx_ed_preamble()  {
    while (busy_flag == 1);
    m644_add_message(g_ed_preamble_head,4);
    m644_start_tx();
}