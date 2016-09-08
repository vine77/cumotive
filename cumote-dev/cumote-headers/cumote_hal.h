/*               
NAME: CUMOTE
TODO List:
-interface with COM to handle IRQ's

*/

/*****************************************************************************
 * cumote_hal.h
 * Hardware Abstraction Layer (HAL)... THIS MAY ACTUALLY BE CALLED A PHY LAYER... 
 * 
 * Abstracts out the details of the AT86RF230 Radio.
 ****************************************************************************/

#pragma regalloc-

#ifndef _DELAY_INCLUDED_
    #include <delay.h>
#endif

#ifndef _CUMOTE_HAL_INCLUDED_
    #define _CUMOTE_HAL_INCLUDED_
#endif

#ifndef _STDLIB_INCLUDED_
    #include <stdlib.h>
#endif
      

#define ED_THRESH        0x10     //energy detection threshold

/****************************************************************************/
//List of Transceiver Registers
#define TRX_STATUS       0x01
#define TRX_STATE        0x02
#define TRX_CTRL_0       0x03
#define PHY_TX_PWR       0x05
#define PHY_RSSI         0x06
#define PHY_ED_LEVEL     0x07
#define PHY_CC_CCA       0x08
#define CCA_THRES        0x09
#define IRQ_MASK         0x0E
#define IRQ_STATUS       0x0F
#define VREG_CTRL        0x10
#define BATMON           0x11
#define XOSC_CTRL        0x12
#define FTN_CTRL         0x18
#define PLL_CF           0x1A
#define PLL_DCU          0x1B
#define PART_NUM         0x1C
#define VERSION_NUM      0x1D
#define MAN_ID_0         0x1E
#define MAN_ID_1         0x1F
#define SHORT_ADDR_0     0x20
#define SHORT_ADDR_1     0x21
#define PAN_ID_0         0x22
#define PAN_ID_1         0x23
#define IEEE_ADDR_0      0x24
#define IEEE_ADDR_1      0x25
#define IEEE_ADDR_2      0x26
#define IEEE_ADDR_3      0x27
#define IEEE_ADDR_4      0x28
#define IEEE_ADDR_5      0x29
#define IEEE_ADDR_6      0x2A
#define IEEE_ADDR_7      0x2B
#define XAH_CTRL         0x2C
#define CSMA_SEED_0      0x2D
#define CSMA_SEED_1      0x2E

//List of Transceiver States
#define STATUS_P_ON             0x00
#define STATUS_BUSY_RX          0x01
#define STATUS_BUSY_TX          0x02
#define STATUS_RX_ON            0x06
#define STATUS_TRX_OFF          0x08
#define STATUS_PLL_ON           0x09
#define STATUS_SLEEP            0x0F
#define STATUS_BUSY_RX_AACK     0x11
#define STATUS_BUSY_TX_ARET     0x12
#define STATUS_RX_AACK_ON       0x16
#define STATUS_TX_ARET_ON       0x19
#define STATUS_RX_ON_NOCLK      0x1C
#define STATUS_RX_AACK_ON_NOCLK 0x1D
#define STATUS_BUSY_RX_AACK_NOCLK   0x1E
#define STATUS_STATE_TRANSITION_IN_PROGRESS 0x1F


//List of Transceiver Control Commands
#define TRX_CMD_NOP             0x00
#define TRX_CMD_TX_START        0x02
#define TRX_CMD_FORCE_TRX_OFF   0x03
#define TRX_CMD_RX_ON           0x06
#define TRX_CMD_TRX_OFF         0x08
#define TRX_CMD_PLL_ON          0x09
#define TRX_CMD_RX_AACK_ON      0x16
#define TRX_CMD_TX_ARET_ON      0x19


//IRQ status masks
#define IRQ_BAT_LOW      0x80       //Battery low signal
#define IRQ_TRX_UR       0x40       //FIFO underrun signal
#define IRQ_TRX_END      0x08       //End of frame (transmit and receive)
#define IRQ_RX_START     0x04       //Beginning of receive frame
#define IRQ_PLL_UNLOCK   0x02       //PLL goes from lock to unlock state
#define IRQ_PLL_LOCK     0x01       //PLL goes from unlock to lock state

//Protocol Commands
#define PING        0xA1    //See if there is a transmitter in range
#define DATA_REQ    0xA5    //Request data from transmitter               

// Misc definitions
#define HAL_MAX_FRAME_SIZE  128  // page 40 of AT86RF230 datasheet defines maximum frame size
/****************************************************************************/


//Function Prototypes
void            HAL_set_RX_buff_len     (unsigned int); 
void            HAL_set_TX_buff_len     (unsigned int); 
void            HAL_initialization      (void);
void            HAL_reset               (void);          
void            HAL_statemachine_reset  (void);
unsigned char   HAL_get_radio_channel   (void);           
void            HAL_set_radio_channel   (unsigned char);  
unsigned char   HAL_get_transmit_power  (void);
void            HAL_set_transmit_power  (unsigned char);
void            HAL_get_state           (void);
void            HAL_set_state           (unsigned char);
unsigned char   HAL_run_cca             (void);
void            HAL_set_cca_mode        (unsigned char); 
unsigned char   HAL_get_RSSI            (void);
unsigned char   HAL_energy_detection    (void);  
void            HAL_transmitframe_pin   (void);       
void            HAL_retransmit          (void);
void            HAL_transmitframe_reg   (void);
void            HAL_enable_CRC          (void);
void            HAL_disable_CRC         (void);
void            HAL_auto_csma_enable    (unsigned char);
void            HAL_auto_csma_disable   (void);    
void            HAL_promte_coordinator  (void);
void            HAL_demote_coordinator  (void);                     
void            HAL_set_short_address   (unsigned char, unsigned char);
void            HAL_set_pan_id          (unsigned char, unsigned char);
void            HAL_set_CSMA_retries    (unsigned char);
//end function prototypes


/****************************************************************************/
//Global Variables to use for interfacing
register unsigned char *HAL_tx_frame;            //User code fills transmit_frame               TODO: Make these sizes variable with malloc and free!
register unsigned char *HAL_rx_frame;            //User code reads receive_frame
unsigned char HAL_LQI;                  //User code may use LQI after receiving frame
register unsigned char HAL_tx_frame_length;      //User can set frame length before transmit,
register unsigned char HAL_rx_frame_length;      //Read frame length while receiving
//unsigned char HAL_IRQ_status;  

register unsigned char HAL_radio_state;              // Store state of radio state machine
unsigned char HAL_radio_channel;            // Keep track of current operating channel
unsigned char HAL_transmit_power;           // Keep track of current transmitting power

unsigned char HAL_CRC_enabled;          // 0 if disabled, 1 if enabled
/****************************************************************************/
                                        
#ifndef _COM_INCLUDED_
    #include <CUmote_COM.h>
#endif 


#pragma regalloc+

/*----------------------------------------------------------
Initialization

-Typically only called immediately after power on. 
-Brings radio into TRX_OFF state
-Can be called from any state for a radio reset, but 
 in that case, the HAL_Radio_Reset function should be used,
 as it is faster. This must be called to get the radio
 out of the P_ON state, however.
-----------------------------------------------------------*/
void HAL_initialization(void)  {
    //COM_init();     // set up radio port pins, etc. Though, all that stuff should be in the HAL, and the COM should be a subset of the HAL...
    HAL_tx_frame = NULL;
    HAL_rx_frame = NULL;
    HAL_CRC_enabled = 0;
    delay_us(510);    
    //HAL_reset(); // need to reset the radio to initialize
    HAL_statemachine_reset();
    HAL_radio_channel = HAL_get_radio_channel();  //channel defaults to 11 on initialization
    HAL_transmit_power = HAL_get_transmit_power();  // TX power starts at 3.0dBm, encoded as 0.
}
/*==========================================================
End Initialization
============================================================*/

/*----------------------------------------------------------
Radio Hardware Reset
-----------------------------------------------------------*/
    void HAL_reset(void)  {    
        RADIO_RESET = 0;
        RADIO_SLP_TR = 0;
        delay_us(6);
        RADIO_RESET = 1;
        HAL_get_state();  // Read the current state of the radio
        
        if (HAL_radio_state == STATUS_P_ON)  {  // then special set-up is necessary
            COM_write_register(TRX_STATE,TRX_CMD_TRX_OFF);
            delay_us(510);  // Wait for transition to TRX_OFF state
            HAL_get_state();  // update the current state of the radio, should be in TRX_OFF.
            #ifdef _DEBUG_ENABLE
                if (HAL_radio_state != STATUS_TRX_OFF)
                    ERROR = HAL_INVALID_STATE_ON_RESET;  // Radio got to invalid state on reset, or reset failed
            #endif
        }
    }
/*===========================================================
End Radio Hardware Reset
============================================================*/

/*----------------------------------------------------------
Radio State Machine Reset
-----------------------------------------------------------*/
    void HAL_statemachine_reset(void)  {
        HAL_get_state();

        #ifdef _DEBUG_ENABLE
        if (HAL_radio_state == STATUS_P_ON || HAL_radio_state == STATUS_SLEEP)
            ERROR = HAL_STATEMACHINE_RESET_PRE_ERR;
        #endif

        delay_us(6);
        if (HAL_radio_state == STATUS_P_ON) {
            COM_write_register(TRX_STATE,TRX_CMD_TRX_OFF);
            delay_us(510);
        }                   
        else {
            COM_write_register(TRX_STATE,TRX_CMD_FORCE_TRX_OFF);
            delay_us(6);
        }
        HAL_get_state();  // update radio state variable

        #ifdef _DEBUG_ENABLE
        if (HAL_radio_state != STATUS_TRX_OFF)        
            ERROR = HAL_STATEMACHINE_RESET_POST_ERR;
        #endif
    }
/*===========================================================
End Radio State Machine Reset
============================================================*/

/*----------------------------------------------------------
Set Radio Transmit Buffer Length
------------------------------------------------------------*/
void HAL_set_TX_buff_len(unsigned int length)  {
    if (HAL_tx_frame != NULL) {  // previously allocated memory, must dealloc first
        free(HAL_tx_frame); 
    }  
    if (length > HAL_MAX_FRAME_SIZE)  {             
        #ifdef _DEBUG_ENABLE_
            ERROR = HAL_TX_BUFF_LEN_INVALIDPARAM; // length too large
        #endif
        HAL_tx_frame_length = HAL_MAX_FRAME_SIZE;          // default to Maximum size
    }                   
    HAL_tx_frame = malloc(length);  // HAL_tx_frame now points to the beginning of the array
    if (HAL_tx_frame == NULL) {  // Not enough free memory
        #ifdef _DEBUG_ENABLE_
            ERROR = HAL_TX_BUFF_LEN_OUTOFMEM;
        #endif
        HAL_tx_frame_length = 0;
    }                           
    else
        HAL_tx_frame_length = (unsigned char)length;        
}
/*===========================================================
END Set Radio Transmit Buffer Length
=============================================================*/


/*----------------------------------------------------------
Set Radio Receive Buffer Length
------------------------------------------------------------*/
void HAL_set_RX_buff_len(unsigned int length)  {
    if ((HAL_rx_frame != NULL)) {  // previously allocated memory, must dealloc first
        free(HAL_rx_frame);
        HAL_rx_frame_length = 0; 
    }  
    if (length > HAL_MAX_FRAME_SIZE)  {             
        #ifdef _DEBUG_ENABLE_
            ERROR = HAL_RX_BUFF_LEN_INVALIDPARAM; // length too large
        #endif
        HAL_rx_frame_length = HAL_MAX_FRAME_SIZE;          // default to Maximum size
    }
                       
    HAL_rx_frame = malloc(length);  // HAL_rx_frame now points to the beginning of the array
    
    if (HAL_rx_frame == NULL) {  // Not enough free memory
        #ifdef _DEBUG_ENABLE_
            ERROR = HAL_RX_BUFF_LEN_OUTOFMEM;
        #endif
        HAL_rx_frame_length = 0;
    }                           
    else
        HAL_rx_frame_length = (unsigned char)length;        
}
/*===========================================================
END Set Radio Receive Buffer Length
=============================================================*/

/*----------------------------------------------------------
Get Radio Channel

-Can't be called from P_ON or SLEEP states
------------------------------------------------------------*/
    unsigned char HAL_get_radio_channel(void)  {
        unsigned char tmp;
        #ifdef _DEBUG_ENABLE_
            if (HAL_radio_state == STATUS_P_ON || HAL_radio_state == STATUS_SLEEP)
                ERROR = HAL_GET_CHANNEL_STATE_INVALID;
        #endif
        tmp = COM_read_register(PHY_CC_CCA);
        HAL_radio_channel = (tmp & 0b00011111);                     
        return HAL_radio_channel;  //should be a number between 11 and 26
    }
/*===========================================================
END Get Radio Channel
=============================================================*/


/*----------------------------------------------------------
Set Radio Channel
TODO: If the radio transceiver is in the RX_ON or PLL_ON state and the new operating channel does not equal the one currently used, the PLL_LOCK interrupt event will be signaled. The PLL should lock to the new channel within 150 us.
------------------------------------------------------------*/
    void HAL_set_radio_channel(unsigned char channel)  {
        unsigned char tmp = COM_read_register(PHY_CC_CCA);
            if (channel < 11 || channel > 26)  {
                channel = 11;                             
                #ifdef _DEBUG_ENABLE_
                ERROR = HAL_SET_RADIO_CHANNEL_INVALID;
                #endif
            }
        tmp = (tmp&0b11100000)|channel;
        COM_write_register(PHY_CC_CCA,tmp);  
        HAL_radio_channel = channel;
        #ifdef _DEBUG_ENABLE_
            //TODO: Error detection, wrong state.
            
        #endif
    }
/*===========================================================
END Set Radio Channel
=============================================================*/

/*----------------------------------------------------------
Get Transmit Power
------------------------------------------------------------*/ 
    unsigned char HAL_get_transmit_power(void)  {
        unsigned char tmp;
        #ifdef _DEBUG_ENABLE_  //can't read in P_ON or SLEEP
            if (HAL_radio_state == STATUS_P_ON || HAL_radio_state == STATUS_SLEEP)
                ERROR = HAL_GET_TRANSMIT_POWER_STATE_INVALID;
        #endif 
        tmp = COM_read_register(PHY_TX_PWR);
        HAL_transmit_power = (tmp & 0b00001111);
        return HAL_transmit_power;
    }
/*===========================================================
END Get Transmit Power
=============================================================*/
                                           
/*----------------------------------------------------------
Set Transmit Power
------------------------------------------------------------*/ 
    void HAL_set_transmit_power(unsigned char tx_pwr)  {
        unsigned char tmp;
            if (tx_pwr > 15) {
                tx_pwr = 15;
                #ifdef _DEBUG_ENABLE_
                    ERROR = HAL_SET_TX_PWR_INVALID;
                #endif          
            }
        tmp = COM_read_register(PHY_TX_PWR);
        tmp = (tmp&0b11110000)|(tx_pwr);
        COM_write_register(PHY_TX_PWR,tmp);
        HAL_transmit_power = tx_pwr;
    }
/*===========================================================
END Set Transmit Power
=============================================================*/


/*----------------------------------------------------------
Get Radio State
------------------------------------------------------------*/
    void HAL_get_state(void)  {
        HAL_radio_state = (COM_read_register(TRX_STATUS))&0b00011111;
    }
/*===========================================================
END Set Transmit Power
=============================================================*/

/*----------------------------------------------------------
Move radio to a new state.

TODO: Read more about state transitions in programming guide

-Reset state machine by calling this with the TRX_OFF parameter...
------------------------------------------------------------*/                                            
    void HAL_set_state(unsigned char state) { 
        unsigned char i = 35;
        HAL_get_state();  // first get current state
        switch (state)  {
            case STATUS_TRX_OFF:
                if (HAL_radio_state == STATUS_RX_ON || HAL_radio_state == STATUS_PLL_ON || HAL_radio_state == STATUS_TX_ARET_ON) {
                    COM_write_register(TRX_STATE,TRX_CMD_TRX_OFF);  // Send command
                    delay_us(5); //state transition complete in 1 us      /// CHANGE
                }                                         
                else if (HAL_radio_state == STATUS_SLEEP)  {
                    RADIO_SLP_TR = 0; // pull SLP_TR line low
                    delay_us(880); // after 880 us, out of sleep state.
                }   
                else  {
                    COM_write_register(TRX_STATE,TRX_CMD_FORCE_TRX_OFF);
                    delay_us(5);                                         /// CHANGE to 1
                }
            break;
            case STATUS_RX_ON:     
                if (HAL_radio_state == STATUS_TRX_OFF)  {
                    COM_write_register(TRX_STATE,TRX_CMD_RX_ON);
                    while(RADIO_IRQ == 0); 
                    COM_read_register(IRQ_STATUS);
                    //delay_us(180); /// TODO: within this time, IRQ should happen, indicating PLL has locked. We could instead wait for this to occur with 'while(RADIO_IRQ == 0);'...
                }   
                else if (HAL_radio_state == STATUS_RX_AACK_ON || HAL_radio_state == STATUS_PLL_ON || HAL_radio_state == STATUS_TX_ARET_ON)  {
                    COM_write_register(TRX_STATE,TRX_CMD_RX_ON);
                    delay_us(5);                /// CHANGE to 1
                }
                #ifdef _DEBUG_ENABLE_   
                else  {  // Invalid State...
                        ERROR = HAL_INVALID_STATE_TRANSITION;
                }                                            
                #endif
            break;
            case STATUS_PLL_ON:
                if (HAL_radio_state == STATUS_TRX_OFF)  {
                    COM_write_register(TRX_STATE,TRX_CMD_PLL_ON);
                    delay_us(180); // within this time, IRQ should happen, indicating PLL has locked. We could instead wait for this to occur with 'while(RADIO_IRQ == 0);'...
                                    // In fact, if IRQ doesn't happen, PLL hasn't locked, and we have an error! Uh-oh!
                }   
                else if (HAL_radio_state == STATUS_RX_AACK_ON || HAL_radio_state == STATUS_RX_ON || HAL_radio_state == STATUS_TX_ARET_ON)  {
                    COM_write_register(TRX_STATE,TRX_CMD_RX_ON);
                    delay_us(5);          /// CHANGE to 1
                }
                #ifdef _DEBUG_ENABLE)   
                else  {  // Invalid State...
                        ERROR = HAL_INVALID_STATE_TRANSITION;
                }                                            
                #endif
            break;
            case STATUS_RX_AACK_ON:  //Should only be entered in extended mode...?
                if (HAL_radio_state == STATUS_TRX_OFF) {
                    COM_write_register(TRX_STATE,TRX_CMD_RX_ON);
                    delay_us(180);  // TODO: CATCH IRQ HERE!

                    COM_write_register(TRX_STATE,TRX_CMD_RX_AACK_ON);
                    delay_us(5);      /// CHANGE to 1
                }
                else if (HAL_radio_state == STATUS_RX_ON || HAL_radio_state == STATUS_PLL_ON)  {
                    COM_write_register(TRX_STATE,TRX_CMD_RX_AACK_ON);
                    delay_us(5);       /// CHANGE to 1                 
                }                              
                else if (HAL_radio_state == STATUS_TX_ARET_ON)  {
                    COM_write_register(TRX_STATE,TRX_CMD_PLL_ON);
                    delay_us(5);        /// CHANGE to 1

                    COM_write_register(TRX_STATE,TRX_CMD_RX_AACK_ON);
                    delay_us(5);        /// CHANGE to 1
                }     
                #ifdef _DEBUG_ENABLE_                          
                else  {
                        ERROR = HAL_INVALID_STATE_TRANSITION;
                }                                            
                #endif
            break;
            case STATUS_TX_ARET_ON:                       
                if (HAL_radio_state == STATUS_TRX_OFF)  {
                    COM_write_register(TRX_STATE,TRX_CMD_PLL_ON);
                    delay_us(180);  // TODO: FIX THIS, CATCH IRQ

                    COM_write_register(TRX_STATE,TRX_CMD_TX_ARET_ON);
                    delay_us(5);    /// CHANGE to 1
                }                            
                else if (HAL_radio_state == STATUS_RX_ON || HAL_radio_state == STATUS_PLL_ON)  {
                    COM_write_register(TRX_STATE,TRX_CMD_TX_ARET_ON);
                    delay_us(5);     /// CHANGE to 1
                }                            
                else if (HAL_radio_state == STATUS_RX_AACK_ON)  {
                    COM_write_register(TRX_STATE,TRX_CMD_RX_ON);
                    delay_us(5);        /// CHANGE to 1

                    COM_write_register(TRX_STATE,TRX_CMD_TX_ARET_ON);
                    delay_us(5);        /// CHANGE to 1
                }     
                #ifdef _DEBUG_ENABLE_                        
                else  {
                        ERROR = HAL_INVALID_STATE_TRANSITION;
                }                    
                #endif
            break;
            case STATUS_SLEEP:                             
                if (HAL_radio_state == STATUS_TRX_OFF)  {
                    RADIO_SLP_TR = 1; // pull slp_tr line high to enter sleep mode                    
                    for (i=12;i>0;i--);  //Delay at least 35 cycles...
                    
                }          
                #ifdef _DEBUG_ENABLE_    
                else {
                        ERROR = HAL_INVALID_STATE_TRANSITION;
                }                    
                #endif
            break;
            default:
                #ifdef _DEBUG_ENABLE_
                    ERROR = HAL_INVALID_STATE_TRANSITION;
                #endif
            break;
        }
        HAL_get_state(); //update the state machine variable
        ///TODO: ERROR CHECKING??
    }
/*===========================================================
END Move radio to a new state
=============================================================*/


//--------------------------------------------------CCA Section----------------------------------------------------//
/*----------------------------------------------------------
Set clear channel assessment mode of operation.

-Mode can be 1,2, or 3. Default is 1.
------------------------------------------------------------*/  
    void HAL_set_cca_mode(unsigned char mode)  {
        unsigned char tmp;
        if (mode < 1 || mode > 3)  {
            mode = 1;
            #ifdef _DEBUG_ENABLE_
                ERROR = HAL_SET_CCA_MODE_INVALID_PARAMETER;
            #endif
        }                                  
        tmp = COM_read_register(PHY_CC_CCA);
        mode = mode << 5;  // shift bits to proper location.
        tmp = tmp & 0b10011111; // Clear CCA mode bits
        tmp = tmp | mode;  // set CCA mode bits with mode variable
        COM_write_register(PHY_CC_CCA,tmp);  
    }
/*===========================================================
END Set clear channel assessment mode of operation.
=============================================================*/

/*----------------------------------------------------------
Clear Channel Assessment
        
-Radio should be in RX_ON or BUSY_RX state before running this
-Will return the result of the CCA for the current channel. 0 for busy, nonzero for idle.
------------------------------------------------------------*/ 
    unsigned char HAL_run_cca(void)  {
        unsigned char tmp;
        HAL_get_state();  // update radio state
        if (HAL_radio_state == STATUS_RX_ON || HAL_radio_state == STATUS_BUSY_RX)  {
            tmp = COM_read_register(PHY_CC_CCA); 
            tmp = tmp | 0b10000000; // set MSB to 1. 
            COM_write_register(PHY_CC_CCA,tmp); // start CCA.
            delay_us(140);  // wait for CCA to finish.
            tmp = COM_read_register(TRX_STATUS);  // bit 6 is of interest for return value
            /// TODO: check MSB of tmp to make sure that CCA did indeed finish.
            return (tmp & 0b01000000);  // clear all but bit 6, which indicates status of channel.
        }   
        #ifdef _DEBUG_ENABLE_
            else
                ERROR = HAL_RUN_CCA_INVALID_STATE;
        #endif
        return 0;
    }
/*===========================================================
END Clear Channel Assessment
=============================================================*/
    
//-------------------------------------------------END CCA SECTION-------------------------------------------------//


/*----------------------------------------------------------
Energy Detection
       
-Radio should be in RX_ON or BUSY_RX
-Runs an ED (energy detection) measurement for the current radio channel
-Return value will be a number from 0 to 84. 0 is <-91dBm, 84 is >-7dBm. 1dBm gradient between endpoints.

TODO: Automatic energy detection when frame is received... grab that data for each received frame??
------------------------------------------------------------*/ 
    unsigned char HAL_energy_detection(void)  {
        HAL_get_state();  // update radio state
        if (HAL_radio_state == STATUS_RX_ON || HAL_radio_state == STATUS_BUSY_RX)  {
            COM_write_register(PHY_ED_LEVEL,0);
            delay_us(140); 
            return COM_read_register(PHY_ED_LEVEL);
        } 
        #ifdef _DEBUG_ENABLE_
            else
                ERROR = HAL_ENERGY_DETECTION_INVALID_STATE;
        #endif 
        return 0;
    }
/*===========================================================
END Energy Detection
=============================================================*/ 


/*----------------------------------------------------------
RSSI Measurement
       
-Radio should be in RX_ON or BUSY_RX          

TODO: Get frame RSSI? Option to return RSSI with every received frame...?
------------------------------------------------------------*/ 
    unsigned char HAL_get_RSSI(void) {
        HAL_get_state();  //update radio state
        if (HAL_radio_state == STATUS_RX_ON || HAL_radio_state == STATUS_BUSY_RX)  {
            return COM_read_register(PHY_RSSI);
        }   
        #ifdef _DEBUG_ENABLE_
            else
                ERROR = HAL_GET_RSSI_INVALID_STATE;
        #endif 
    return 0;
    }
/*===========================================================
END RSSI Measurement
=============================================================*/ 
                                
/*----------------------------------------------------------
Transmit Frame with Pin Start (streamlined)
    -Requires TX Buffer to be filled already
------------------------------------------------------------*/   
    void HAL_transmitframe_pin(void)  {
        //Do we need to make sure we're in the right state first?
        RADIO_SLP_TR = 1;  // Pull SLP_TR high to force radio into BUSY_TX state. 
        delay_us(5);     /// CHANGE to 1
        RADIO_SLP_TR = 0; // Reset pin to 0
        
        // Now, radio will transmit a frame. But, we need to download the frame before it can be transmitted. 
        // We will do this while the radio is getting ready to transmit.
        COM_download_frame();
        
        /// TODO: Check when transmit is done before returning? 
    }
/*===========================================================
END Transmit Frame with Pin Start
=============================================================*/ 

/*----------------------------------------------------------
Retransmit Frame with Pin Start

-Used for retransmitting. Frame already downloaded in radio,
use pin to retransmit.
------------------------------------------------------------*/   
    void HAL_retransmit(void)  {    
        RADIO_SLP_TR = 1;
        delay_us(5);     /// CHANGE to 1
        RADIO_SLP_TR = 0;
    }
/*===========================================================
END Retransmit Frame with Pin Start
=============================================================*/                                                                  

/*----------------------------------------------------------
Transmit Frame with Register Start (streamlined) (requires interrupts to be disabled!)
    -Requires TX Buffer to be filled already
------------------------------------------------------------*/  
    void HAL_transmitframe_reg(void)  {
        //Do we need to make sure we're in the right state first?
        COM_write_register(TRX_STATE,TRX_CMD_TX_START);  // Tell radio to start transmission
        COM_download_frame();        
        /// TODO: Check when transmit is done before returning?
    }
/*===========================================================
END Transmit Frame with Register Start
=============================================================*/  

/*----------------------------------------------------------
Enable CRC 

-Read PHY_TX_PWR Register, set MSB to 1, Write back.
------------------------------------------------------------*/  
    void HAL_enable_CRC(void)  {
        unsigned char junk;
        junk = COM_read_register(PHY_TX_PWR);
        junk = junk|0b10000000;  // Set MSB to 1, enable auto CRC... ///TODO: DOES THIS IMPACT MAX FRAME SIZES?
        COM_write_register(PHY_TX_PWR,junk);  // write back
        HAL_CRC_enabled = 1;
    }
/*===========================================================
END Enable CRC
=============================================================*/  

/*----------------------------------------------------------
Disable CRC 
------------------------------------------------------------*/  
    void HAL_disable_CRC(void)  { 
        unsigned char junk;
        junk = COM_read_register(PHY_TX_PWR);
        junk = junk&0b01111111;  // Set MSB to 0, disable auto CRC... ///TODO: DOES THIS IMPACT MAX FRAME SIZES?
        COM_write_register(PHY_TX_PWR,junk);  // write back        
        HAL_CRC_enabled = 0;
    }
/*===========================================================
END Disable CRC
=============================================================*/  


/*--------------------------------AUTOMATED CSMA ALGORITHM SETUP---------------------------------------*/

/*----------------------------------------------------------
SETUP AUTOMATED CSMA ALGORITHM
                                                    
-Input parameter: Number of retries to perform in auto CSMA algorithm
------------------------------------------------------------*/  
    void HAL_auto_csma_setup(unsigned char user_csma)  {
        unsigned char junk = (user_csma & 0b00000111)<<1;
        COM_write_register(XAH_CTRL,junk);
    }
/*===========================================================
END SETUP AUTOMATED CSMA ALGORITHM
=============================================================*/ 

/*----------------------------------------------------------
DISABLE AUTOMATED CSMA ALGORITHM                                                    
------------------------------------------------------------*/  
    void HAL_auto_csma_disable(void)  {
        unsigned char junk = 0b11110000;
        COM_write_register(XAH_CTRL,junk);
    }
/*===========================================================
END DISABLE AUTOMATED CSMA ALGORITHM
=============================================================*/ 

//TODO: Set up all the registers for the address filter... chapter 7.3 in programming guide.


/*----------------------------------------------------------
Elect Device as Coordinator                    

-Make this current device the network coordinator with CSMA_SEED_1 register
------------------------------------------------------------*/  
    void HAL_promte_coordinator(void)  {
        unsigned char junk;
        
        junk = COM_read_register(CSMA_SEED_1);
        junk = junk | 0b00001000; // enable coordinator
        COM_write_register(CSMA_SEED_1,junk);
    }
/*===========================================================
END Elect Device as Coordinator
=============================================================*/ 

/*----------------------------------------------------------
Demote device from coordinator to ordinary device
------------------------------------------------------------*/  
    void HAL_demote_coordinator(void)  {
        unsigned char junk;        
        junk = COM_read_register(CSMA_SEED_1);
        junk = junk & 0b11110111; // disable coordinator
        COM_write_register(CSMA_SEED_1,junk);
    }
/*===========================================================
END Demote Device
=============================================================*/ 

/*----------------------------------------------------------
Set the Short Address of the device                                

-Short address is 2 bytes. Input parameters are the lo and hi bytes of the 
    address.
------------------------------------------------------------*/  
    void HAL_set_short_address(unsigned char hi, unsigned char lo) {
        COM_write_register(SHORT_ADDR_0,lo);
        COM_write_register(SHORT_ADDR_1,hi);
    }
/*===========================================================
END Set the Short Address of the device
=============================================================*/    

/*----------------------------------------------------------
Set the PAN ID of the device                                

-PAN ID is 2 bytes. Input parameters are the lo and hi bytes of the 
    address.
------------------------------------------------------------*/                                                                        
    void HAL_set_pan_id(unsigned char hi, unsigned char lo)  {
        COM_write_register(PAN_ID_0,lo);
        COM_write_register(PAN_ID_1,hi);
    }
/*===========================================================
END Set the PAN ID of the device
=============================================================*/ 

void HAL_set_CSMA_retries (unsigned char retries)  {
    COM_write_register(XAH_CTRL,(retries<<1));
}