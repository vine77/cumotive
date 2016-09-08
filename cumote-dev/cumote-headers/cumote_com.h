/*****************************************************************************
 * CU_MOTE COM Layer
 *   
 *   PHY Link between ATMega644 MCU and AT86RF230 Radio. Interface between HAL and PHY. 
 *   This layer must be modified for specific user hardware. Pins change, must change this.
 *   MCU change, must change this. However, HAL and MAC should stay the same
 *   
 *   TODO List:
 *   HAL needs to ask the COM layer to do the following:
 *       -Initialize radio
 *       -Grab SPI, set up SPI
 *       -Download Frame
 *       -Upload Frame
 *       -Set up RADIO properties...?
         -Read/Write Registers
         -Enter/Exit Test Mode
         -Respond to IRQ
 *   Figure out what to do if you try to enter a state you cannot enter from current state... how to handle error?
 *   Figure out external interrupt to let radio pass MCU messages?  
 *   
 *   COM needs to see interrupts from Radio, do what it can automatically, ask HAL for assistance whenever necessary.
 *****************************************************************************/

#ifndef _COM_INCLUDED_
    #define _COM_INCLUDED_
#endif   

#ifndef _MEGA644_INCLUDED_
    #include <mega644.v>    // This COM is specifically for Mega644. Change for other microcontrollers.
#endif

#ifndef _SPI_INCLUDED_   
    #include <spi.h>
#endif
                            
#ifndef _CUMOTE_ERR_INCLUDED_
    #include <CUMOTE_ERR.h>  // Definitions of error messages
#endif
 
#include <CUMOTE_DELAY.h>

/*----------------------------------------------------------
 Pin Definitions. Up to user to change for specific design
-----------------------------------------------------------*/    
    //SPI data direction registers (DDR)
    #define     DDR_MOSI        DDRB.5  // Master Out - Slave In
    #define     DDR_MISO        DDRB.6  // Master In - Slave Out
    #define     DDR_SCLK        DDRB.7  // SPI Clock 
    #define     DDR_RADIO_SEL   DDRB.4  // RADIO Slave Select Pin
                                             
    // SPI Interface Pins
    #define     RADIO_SS              PINB.4    // For MCU Configured as slave
    #define     RADIO_MOSI            PORTB.5   
    #define     RADIO_MISO            PINB.6
    #define     RADIO_SCLK            PORTB.7
    #define     RADIO_SEL             PORTB.4   // For MCU configured as master
    
    //GPIO (General purpose input output) data direction registers 
    #define     DDR_RADIO_IRQ       DDRB.2
    #define     COM_IRQ             2   // external interrupt 2
    #define     EXTERNAL_INTERRUPT  EXT_INT2    // external interrupt 2. Options are 0,1,2.
    #define     DDR_RADIO_SLP_TR    DDRB.3    
    #define     DDR_RADIO_RESET     DDRB.1      // Pin to reset RADIO
    
    #define     DDR_RADIO_TST       DDRB.0      // Pin to force Radio into test mode
    //#define     _TEST_ENABLE_
    
    //GPIO Interface Pins
    #define     RADIO_IRQ           PINB.2     // Input
    #define     RADIO_SLP_TR        PORTB.3    // Output
    #define     RADIO_RESET         PORTB.1    // Output
    #define     RADIO_TST           PORTB.0    // Output
    
    // Error handling definitions
    #define     ERROR               PORTC                /// PUT THIS STUFF IN CUMOTE_ERR.H??
    #define     DDR_ERROR           DDRC
    #define     ERROR_PIN           PORTC.0
    
   // #define     _DEBUG_ENABLE_      // Comment out this line to disable debugging functionality
    
/*=========================================================
 End Pin Definitions.                                     
==========================================================*/

/*----------------------------------------------------------
Global variables, flags, etc.
-----------------------------------------------------------*/ 
    register unsigned char COM_mcu_freq @12;   // Byte representing current clock speed of MCU. 16,8,4,2, or 1 MHz. Stored as a power of 2 (4,3,2,1,0)
    unsigned char COM_spi_freq;   // Byte representing current clock speed of SPI interface as fraction of COM_mcu_freq, 2,4,8,16,32,64, or 128. Stored as a power of 2 (1,2,3,4,5,6,7).
    unsigned char COM_IRQ_pending = 0;  // flag indicates that IRQ reg should be read
    unsigned char COM_IRQ_status;   // Relays status information to higher layers
/*==========================================================
End Global variables, flags, etc.
============================================================*/

/*----------------------------------------------------------
Function Prototypes
-----------------------------------------------------------*/
    void            COM_init                    (void); 
    void            COM_set_MCU_clock           (unsigned char clk);
    void            COM_reset_SPI_clock         (void);
    void            COM_set_SPI_clock           (unsigned char speed);
    void            COM_write_register          (unsigned char address, unsigned char data);   
    unsigned char   COM_read_register           (unsigned char address);
    void            COM_download_frame          (void); 
    void            COM_upload_frame            (void);
    void            COM_enable_interrupt_IRQ    (void);
    void            COM_disable_interrupt_IRQ   (void);  
    void            COM_reset_IRQ               (void);
/*==========================================================
End Function Prototypes
============================================================*/

/*----------------------------------------------------------
Initialization

-Set up data direction and default values on pins.
-Initialize SPI.
-----------------------------------------------------------*/
    void COM_init(void) {           // TODO: Make sure initialization of pins is finished....
        //Set up SPI I/O data direction
        DDR_MOSI = 1;
        DDR_MISO = 0;
        DDR_SCLK = 1;
        
        
        DDR_RADIO_IRQ = 0; 
        DDR_RADIO_SLP_TR = 1;
        //DDR_RADIO_RESET = 1;
        DDR_RADIO_SEL = 1;
                
        RADIO_SLP_TR = 0;
        //RADIO_RESET = 1;
        RADIO_SEL = 1;        
        
        COM_mcu_freq = 0;  // 1 MHz on power-up. 
        COM_IRQ_status = 0;  // initally, no status flags
        
        
        #ifdef _TEST_ENABLE_
            DDR_RADIO_TST = 1;
        #endif
        
        //RADIO_SEL = 0; // Select the RADIO for SPI comm
        
        #ifdef _DEBUG_ENABLE_
            DDR_ERROR = 0xff;     // all debug pins are outputs
            ERROR = NO_ERR;         // 0x00 means no error yet
        #endif
        
        COM_reset_SPI_clock();  // configure clock phase and polarity for radio
    }             
/*=========================================================
End Initialization
===========================================================*/
                                                             
/*----------------------------------------------------------
SPI Clock Initialization                                  TODO: NEED TO ADJUST THIS WHEN CLOCK SPEED IS CHANGED?? ENABLE INTERRUPTS ON SPI???
-Default to fastest SPI speed possible, f_osc/2. 
-----------------------------------------------------------*/              
    void COM_reset_SPI_clock(void)  {                                    // needs to be reflected in HAL
        //Set up SPI Control Registers
        //Bit 7 – Interrupt Enable SPIE=0 -> no ISR
        //Bit 6 – SPI Enable SPE=1 -> enable spi
        //Bit 5 – Data Order DORD=0 -> msb first
        //Bit 4 – Master/Slave Select MSTR=1 ->MCU is SPI master
        //Bit 3 – Clock Polarity CPLO=0 (for the transceiver initially)
        //Bit 2 – Clock Phase CPHA=0 (for the transceiver initially)
        //Bits 1:0 – SPR1, SPR0: SPI Clock Rate Select 1 and 0
        //SPR1:SPR0=00 along with SPI2X=1 sets SCK to f_osc/2 = 8MHz/2 = 4MHz
        
        SPCR0 = 0b01010000;  //SPI Control Register
        SPSR0 = 1;           //SPI Status Register (SPI2X)
        COM_spi_freq = 1;   // default is f_osc/2. 
    }
/*==========================================================
End SPI Clock Initialization
============================================================*/

/*----------------------------------------------------------
MCU Clock Speed Adjustment. 

-Input parameter is a power of 2, between 0 and 4. Represents speed in MHz of clock
-----------------------------------------------------------*/    
void COM_set_MCU_clock(unsigned char clk)  {                                     
    unsigned char junk;
    if (clk > 4) {
        // ERROR
        clk = 4; 
    }         
    junk = COM_read_register(TRX_CTRL_0);
    junk = junk & 0b11110000;
    junk = junk | ((0b00000111)&(clk));
    
    COM_write_register(TRX_CTRL_0,junk);    
}

/*==========================================================
End MCU Clock Speed Adjustment
============================================================*/


/*----------------------------------------------------------
SPI Clock Initialization, Variable Speed Version
-Default to fastest SPI speed possible, f_osc/2.
-Input parameter sets actual clock speed, f_osc/2, f_osc/4,
-  f_osc/8, f_osc/16, etc.
Parameter Input:
0 = fosc/4
1 = fosc/16
2 = fosc/64
3 = fosc/128            
4 = fosc/2
5 = fosc/8
6 = fosc/32
7 = fosc/64
-----------------------------------------------------------*/              
    void COM_set_SPI_clock(unsigned char speed)  {     // needs to be reflected in HAL   
        //Set up SPI Control Registers
        //Bit 7 – Interrupt Enable SPIE=0 -> no ISR
        //Bit 6 – SPI Enable SPE=1 -> enable spi
        //Bit 5 – Data Order DORD=0 -> msb first
        //Bit 4 – Master/Slave Select MSTR=1 ->MCU is SPI master
        //Bit 3 – Clock Polarity CPLO=0 (for the transceiver initially)
        //Bit 2 – Clock Phase CPHA=0 (for the transceiver initially)
        //Bits 1:0 – SPR1, SPR0: SPI Clock Rate Select 1 and 0
        //SPR1:SPR0=00 along with SPI2X=1 sets SCK to f_osc/2 = 8MHz/2 = 4MHz
        
        switch (speed) {
            case 0: SPCR0 = 0b01010000;
                SPSR0 = 1;
                COM_spi_freq = 2;
                break;
            case 1: SPCR0 = 0b01010001;
                SPSR0 = 0;    
                COM_spi_freq = 4;
                break;
            case 2: SPCR0 = 0b01010010;
                SPSR0 = 0;     
                COM_spi_freq = 6;
                break;
            case 3: SPCR0 = 0b01010011;
                SPSR0 = 0;      
                COM_spi_freq = 7;
                break;
            case 4: SPCR0 = 0b01010000;
                SPSR0 = 1;
                COM_spi_freq = 1;
                break;
            case 5: SPCR0 = 0b01010001;
                SPSR0 = 1;      
                COM_spi_freq = 3;
                break;
            case 6: SPCR0 = 0b01010010;
                SPSR0 = 1;    
                COM_spi_freq = 5;
                break;
            case 7: SPCR0 = 0b01010011;
                SPSR0 = 1;      
                COM_spi_freq = 6;
                break;
            default: SPCR0 = 0b01010000;
                SPSR0 = 1; 
                COM_spi_freq = 1;
                #ifdef _DEBUG_ENABLE_
                    ERROR = COM_SPI_SPEED_ERR;  // Invalid parameter for SPI
                #endif
            break;
        }
    }
/*==========================================================
End SPI Clock Initialization
============================================================*/


/*----------------------------------------------------------
Write RADIO Register, blocking variant
    - Can be used to send commands to radio.
    - 
-----------------------------------------------------------*/  
    void COM_write_register(unsigned char address, unsigned char data) {
        unsigned char junk;
        RADIO_SEL = 0;  // make sure radio is selected
        //First 2 bits are 11, rest is address. Start transmitting command
        SPDR0 = 192 + (address & 0b00111111);
        while((SPSR0&0x80) == 0);  //Wait for transfer to complete
        junk = SPDR0;
        SPDR0 = data;
        while ((SPSR0&0x80) == 0);  //Wait for transfer to complete
        RADIO_SEL = 1;   // de-select radio 
    }
/*==========================================================
End Write RADIO Register, blocking variant
============================================================*/  
 

/*----------------------------------------------------------
Read RADIO Register, blocking variant
    - Can be used to get radio status
    - 
-----------------------------------------------------------*/  
    unsigned char COM_read_register(unsigned char address) {
        unsigned char junk;
        RADIO_SEL = 0;  // make sure radio is selected
        //Address should only be 6 bits. MSB should be 1, bit 6 should be 0.
        //Writing to SPDR0 starts transmission
        SPDR0 = 128 + (address & 0b00111111);
        while((SPSR0&0x80) == 0); //Wait for transfer to complete
        junk = SPDR0;
        //Start next transmission, transmit junk, get back data from register
        SPDR0 = 0x00;
        while((SPSR0&0x80) == 0); //Wait for transfer to complete
        RADIO_SEL = 1;
        return SPDR0; //Return contents of register in transceiver
    }
/*==========================================================
End Write RADIO Register, blocking variant
============================================================*/  

/*----------------------------------------------------------
Write RADIO Register, nonblocking variant
    - Can be used to send commands to radio. Do we need COM_send_cmd?
    - 
-----------------------------------------------------------*/  
    //TODO: Write interrupt-enabled version. Select which version with a define statement?
/*=========================================================
End Write RADIO Register, nonblocking variant
    - Can be used to send commands to radio. 
    - 
============================================================*/

/*-----------------------------------------------------------
Download Frame to Radio

-TODO: CHECK THIS FUNCTION! SHOULD IT FORCE A TRANSITION TO PLL_ON? IT SHOULD LIKELY USE HAL FUNCTIONALITY TO DO SO, ANYWAY
------------------------------------------------------------*/
    void COM_download_frame(void)  {
        unsigned char i;
        COM_write_register(TRX_STATE,TRX_CMD_PLL_ON);   // TODO: Make sure radio is in right state to do this. Signal error if not. Do this from HAL?
        RADIO_SEL = 0;
        SPDR0 = 0b01100000;  //Frame transmit mode, see AT86RF230 Datasheet
        while((SPSR0&0x80) == 0);  //Wait for transfer to complete
        if (HAL_CRC_enabled == 1)
            SPDR0 = HAL_tx_frame_length + 2;  //Frame length + CRC
        else
            SPDR0 = HAL_tx_frame_length;
        while((SPSR0&0x80) == 0);  //Wait for transfer to complete
        for (i=0;i<HAL_tx_frame_length;i++) {
            SPDR0 = HAL_tx_frame[i];
            while((SPSR0&0x80) == 0);  //Wait for transfer to complete
        }
        RADIO_SEL = 1;
    }
/*============================================================
END Download Frame to Radio
=============================================================*/ 

/*------------------------------------------------------------
Upload Frame From Radio --> Called after interrupt signal received
--------------------------------------------------------------*/
    void COM_upload_frame(void)  {
        unsigned int Twait;  // wait time in ms before starting frame upload to prevent buffer underrun. 
        unsigned int Tradio;  // time radio takes for full frame reception
        unsigned int Tmcu;   // time mcu takes for full frame reception                            
        unsigned int Tspi;  // time spi interface takes to download frame size
        unsigned char L;  // length of frame to be received
        unsigned char i;
        
        var_delay(32); // wait 32us to ensure that radio has downloaded frame size
        
        // download frame size
        RADIO_SEL = 0;
        SPDR0 = 0b00100000;  // Upload frame command
        while((SPSR0&0x80)==0);  // Wait for SPI transfer to complete
        SPDR0 = 0x00;  //transmit junk byte to receive frame length byte
        while((SPSR0&0x80)==0);  // Wait for SPI transfer to complete
        L = SPDR0;  // get frame length from SPI
        
        // check to see if proper memory was allocated already, allocate if not.
        HAL_set_RX_buff_len(L);
        
        // calculate wait time
        Tradio = (L << 5); //(32us per byte, 32*L gives time in us for radio to get frame)
        Tmcu = ((L<<3)<<COM_spi_freq)>>COM_mcu_freq;   // See documentation for explanation
        Tspi = (16 << COM_spi_freq)>>COM_mcu_freq;
        Twait = Tradio - Tmcu - Tspi;        
        
        // wait 
        var_delay(Twait);  // Need to replace with a variable wait function...?
        
        // Download actual frame data
        for (i=0; i<HAL_rx_frame_length; i++)  {
            SPDR0 = 0x00;
            while((SPSR0&0x80) == 0);
            HAL_rx_frame[i] = SPDR0;
// my_count++;  ///////////////////////////////////////// REMOVE WHEN DONE WITH LINK TEST!           
        }                            
        SPDR0 = 0x00;
        while((SPSR0&0x80) == 0);
        HAL_LQI = SPDR0;  // Last byte is link quality indication
        
        RADIO_SEL = 1;
    }
/*=============================================================
END Upload Frame From Radio
==============================================================*/ 

/*------------------------------------------------------------
Enable Interrupt for IRQ
    -Requires IRQ to be an external interrupt port... works for external interrupt line 0,1,2.
--------------------------------------------------------------*/ 
    void COM_enable_interrupt_IRQ(void)  {                  
        // register EICRA bits...
        // register EIMSK bits... 
    
        EICRA |= ((0b00000011)<<(COM_IRQ<<1));  // set up external interrupt to trigger on rising edge
        EIMSK |= ((0b00000001)<<(COM_IRQ));   // enable proper external interrupt line
    }
/*=============================================================
END Enable Interrupt for IRQ
==============================================================*/ 
/*------------------------------------------------------------
Disable Interrupt for IRQ
--------------------------------------------------------------*/ 
    void COM_disable_interrupt_IRQ(void)  {
        EICRA &= ~((0b00000011)<<(COM_IRQ<<1));
        EIMSK &= ~((0b00000001)<<(COM_IRQ));
    }
/*=============================================================
END Disable Interrupt for IRQ
==============================================================*/

/*------------------------------------------------------------
Interrupt-based IRQ detection... Need to dispatch appropriate handlers... but where? how?
--------------------------------------------------------------*/ 
    interrupt [EXTERNAL_INTERRUPT] void handle_IRQ(void)  {
        COM_IRQ_pending = 1;
    } 
/*=============================================================
END Interrupt-based IRQ detection
==============================================================*/

/*------------------------------------------------------------
IRQ Handler
--------------------------------------------------------------*/ 
    void COM_IRQ_handler(void)  {
        if (COM_IRQ_pending == 1) {
            COM_IRQ_pending = 0;
            COM_IRQ_status = COM_read_register(IRQ_STATUS);   // upper levels will define how to respond to these interrupts
        }   
    }
/*=============================================================
END IRQ Handler
==============================================================*/

/*
TODO List:
    -IRQ Handling... interrupt? polling? Can't call functions from interrupt, right?
    -Delays in receive function...
*/