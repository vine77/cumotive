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

     /*   if (sniffer_state == WAIT)  {
            if (is_buffer_empty() == 0)  {  // message ready and waiting
                my_rx_data = get_usart_byte();  // get the next byte from the buffer. Then, analyze that byte.
                if (rx_state == RX_WAIT)  {
                    if (my_rx_data == RX_CMD_SET_CHAN)  {
                        rx_state = RX_SET_CHAN;
                    }
                    else if (my_rx_data == RX_CMD_RUN)  {
                        HAL_set_state(STATUS_RX_ON);      // Activate receiver
                        sniffer_state = RUNNING;
                        usart_rx_ack();  // acknowledge the run command
                    }
                    else if(my_rx_data == RX_CMD_ED)  {
                        HAL_set_state(STATUS_RX_ON);
                        sniffer_state = ENERGY_DETECTION;
                        usart_rx_ack();
                        ms_counter = 0;
                    }
                }
                else if (rx_state == RX_SET_CHAN)  {
                    HAL_set_radio_channel(my_rx_data);    // set the appropriate channel. TODO: CHECK TO SEE IF CHANNEL IS CLEARED WHEN CHANGING RADIO STATE...
                    rx_state = RX_WAIT;
                    usart_rx_ack();  // acknowledge the channel change message   /// TODO: add capability to report errors?
                }
            }
        }
        else if (sniffer_state == RUNNING)  {
            if (is_buffer_empty() == 0)  {  // message ready and waiting. Check to see if we should stop
                my_rx_data = get_usart_byte();
                if (rx_state == RX_WAIT)  {
                    if (my_rx_data == RX_CMD_HALT)  {
                        HAL_set_state(STATUS_TRX_OFF);  // disable receiver
                        sniffer_state = WAIT;  // back to wait... wait for command to restart
                        while(busy_flag == 1);
                        m644_add_message(ack_head,4);
                        m644_start_tx();
                    }
                }
            }

            if (COM_IRQ_pending == 1)  {  // radio has info for the application   /// TODO: THIS DOES NOT WORK! METHOD FOR SENDING PREAMBLE IS BROKEN
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
        else if (sniffer_state == TEST)  {
            while(busy_flag == 1);
            while(ms_counter > 0);
            m644_add_message(ack_head,4);
            m644_start_tx();
            ms_counter = 100;
        }
        else if (sniffer_state == ENERGY_DETECTION)  {  // special mode. Iterate each channel, do detection, report findings to Visual C++ program.
            if (is_buffer_empty() == 0)  {  // message ready and waiting
                my_rx_data = get_usart_byte();  // get the message
                if (my_rx_data == RX_CMD_HALT)  {
                    HAL_set_state(STATUS_TRX_OFF);
                    sniffer_state = WAIT;
                    rx_state = RX_WAIT;
                    usart_rx_ack();
                }
            }
            else if (ms_counter == 0)  {
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
        }  */
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
