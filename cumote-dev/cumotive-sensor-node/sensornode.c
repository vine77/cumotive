#include <mega644.h>   
#include "cumote_hal.h"
#include "kxp74.h"
 
/*----------------------------------------------------
    This program is the run-time code for the sensor nodes
in the CUmotive system. It is derived from code used for 
the BOOM 2008 demo. 

Features to implement:
    -CSMA-CA distributed time-slot allocation? (Will require something a bit more sophisticated than I first thought)
    -Channel selection (will require a separate program on a base-station that responds to user input, and communicates with whole network)
    -When a node first comes online, it must find a base station to communicate with. Channel scan: send quick pings on a given channel, listen for responses. Select channel with loudest responses. Nothing above a threshold, keep scanning.


-----------------------------------------------------*/
          
#define NODE_STATE_INIT         0                                    
#define NODE_STATE_CHANNEL_SCAN 1
#define NODE_STATE_RUNNING      3
    
unsigned int ms_counter;
register unsigned char node_state;


interrupt [TIM1_COMPA] void handle_tim1(void) {  // will use to set sleep duration, eventually. 
    if (ms_counter > 0)
        ms_counter--;
}

void main(void)  {
    //unsigned char my_msg[16];  
    //unsigned char *string_head;   // make sure we keep track of start of array
    unsigned char i;
    unsigned char sensor_val[2];
    unsigned char sample[3];        
                  
    node_state = NODE_STATE_INIT;
    
    // disable portions of MCU that will not be used
    PRR = 0b11100011;  // disable Two Wire Interface, Timer 2, Timer 0, USART, and ADC
    
    
    // Clock setup    
    COM_init();
    COM_set_MCU_clock(4);   // set clock to 8 MHz... except we're configured to run off internal clock. 
    COM_disable_CLKM();      // turn off CLKM as we're running off internal clock
               
    // Sensor setup
    // accelerometer setup
    init_sensor_spi();
    set_sensor_clock();
    sensor_standby();  // put sensor in power-save mode. When we want to use the sensor, call init_sensors();
    
    //back to radio spi clock
    COM_reset_SPI_clock();    

    // timer initialization
    TCCR1A = 0b00000000;
    OCR1AH = 1;
    OCR1AL = 0b11110100;
    TCCR1B = 0b00001010; // clk/8... count to 500 for 1ms at 4MHz.
    TCCR1C = 0; 
    TIMSK1 = 0b00000010;  // interrupt on compare A match
    
    ms_counter = 0;
    
    #asm
        sei
    #endasm
        
    // Radio network layer initialization        
    HAL_initialization();
    COM_enable_interrupt_IRQ();
    HAL_set_radio_channel(13);  // initialize radio's channel
    HAL_set_state(STATUS_TRX_OFF);  // initialize radio's state            
    
    //node_state = NODE_STATE_CHANNEL_SCAN;  // first, try to find a channel to communicate on
    node_state = NODE_STATE_RUNNING;
    
    //HAL_set_TX_buff_len(16);  // message is 16 bits long...
   // for (i = 0; i< 16; i++)  {
   //     HAL_tx_frame[i] = i;
   // }
   // COM_download_frame();                               
    
    HAL_set_TX_buff_len(3); // one byte per axis for now
    while(1)  {
        
        if (node_state == NODE_STATE_RUNNING)  {
            set_sensor_clock();
            while (ms_counter > 0);  // wait for next sample.
            init_sensors();             
            ms_counter = 1;
            while (ms_counter > 0);  // wait to come out of standby... TODO: How long should this take?
            // first, sample accelerometer.
        
            for (i=0;i<3;i++)  {  // iterate through axes
                HAL_tx_frame[i] = get_sensor(i); // get sample for each axis
            }
            sensor_standby();
        
            COM_reset_SPI_clock();
            HAL_transmitframe_pin();  // Should download data, then transmit... [fingers crossed]
        
            if (COM_IRQ_pending == 1)  {
                COM_IRQ_handler();
            }        
            // now we should try to put chip to sleep... but that's for later.        
            ms_counter = 10;  // wait 10 ms before transmitting again. Around 100 samples per second...
        }
    }
}  

/*
TODO List:
1) Test transmission/reception
2) Test accelerometer spi data capture
3) Test putting node to sleep
*/                     