// CodeVisionAVR C Compiler
// (C) 1998-2005 Pavel Haiduc, HP InfoTech S.R.L.
// I/O registers definitions for the ATmega644
#pragma used+
#pragma used+
sfrb PINA=0;
sfrb DDRA=1;
sfrb PORTA=2;
sfrb PINB=3;
sfrb DDRB=4;
sfrb PORTB=5;
sfrb PINC=6;
sfrb DDRC=7;
sfrb PORTC=8;
sfrb PIND=9;
sfrb DDRD=0xa;
sfrb PORTD=0xb;
sfrb TIFR0=0x15;
sfrb TIFR1=0x16;
sfrb TIFR2=0x17;
sfrb PCIFR=0x1b;
sfrb EIFR=0x1c;
sfrb EIMSK=0x1d;
sfrb GPIOR0=0x1e;
sfrb EECR=0x1f;
sfrb EEDR=0x20;
sfrb EEARL=0x21;
sfrb EEARH=0x22;
sfrw EEAR=0X21;   // 16 bit access
sfrb GTCCR=0x23;
sfrb TCCR0A=0x24;
sfrb TCCR0B=0x25;
sfrb TCNT0=0x26;
sfrb OCR0A=0x27;
sfrb OCR0B=0x28;
sfrb GPIOR1=0x2a;
sfrb GPIOR2=0x2b;
sfrb SPCR0=0x2c;
sfrb SPSR0=0x2d;
sfrb SPDR0=0x2e;
sfrb ACSR=0x30;
sfrb OCDR=0x31;
sfrb SMCR=0x33;
sfrb MCUSR=0x34;
sfrb MCUCR=0x35;
sfrb SPMCSR=0x37;
sfrb RAMPZ=0x3b;
sfrb SPL=0x3d;
sfrb SPH=0x3e;
sfrb SREG=0x3f;
#pragma used-
// Interrupt vectors definitions
// Needed by the power management functions (sleep.h)
#asm
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
#endasm
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
#pragma regalloc-
    // CodeVisionAVR C Compiler
// (C) 1998-2000 Pavel Haiduc, HP InfoTech S.R.L.
#pragma used+
#pragma used+
void delay_us(unsigned int n);
void delay_ms(unsigned int n);
#pragma used-
        /* CodeVisionAVR C Compiler
   Prototypes for standard library functions

   (C) 1998-2003 Pavel Haiduc, HP InfoTech S.R.L.
*/
#pragma used+
#pragma used+
int atoi(char *str);
long int atol(char *str);
float atof(char *str);
void itoa(int n,char *str);
void ltoa(long int n,char *str);
void ftoa(float n,unsigned char decimals,char *str);
void ftoe(float n,unsigned char decimals,char *str);
void srand(int seed);
int rand(void);
void *malloc(unsigned int size);
void *calloc(unsigned int num, unsigned int size);
void *realloc(void *ptr, unsigned int size); 
void free(void *ptr);
#pragma used-
#pragma library stdlib.lib
      /****************************************************************************/
//List of Transceiver Registers
//List of Transceiver States
//List of Transceiver Control Commands
//IRQ status masks
//Protocol Commands
// Misc definitions
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
            /*
  CodeVisionAVR C Compiler
  (C) 1998-2004 Pavel Haiduc, HP InfoTech S.R.L.

  Prototype for SPI access function */
  #pragma used+
#pragma used+
#pragma used+
unsigned char spi(unsigned char data);
#pragma used-
#pragma library spi.lib
                                /*****************************************************************************
 * CU_MOTE Error Code Definitions
 *****************************************************************************/
                     //   unsigned char COM_mcu_freq;   // Byte representing current clock speed of MCU. 16,8,4,2, or 1 MHz. Stored as a power of 2 (4,3,2,1,0)
//Delay specified time in microseconds based on the variable above
void var_delay(unsigned char t)  {   
void var_delay(unsigned char t)  {   
void var_delay(unsigned char t)  {   
    // r12 should have value of COM_mcu_freq... what about t?
    #asm   
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
    #endasm
}
/*----------------------------------------------------------
 Pin Definitions. Up to user to change for specific design
-----------------------------------------------------------*/    
    //SPI data direction registers (DDR)
                                                                 // SPI Interface Pins
                            //GPIO (General purpose input output) data direction registers 
                                //#define     _TEST_ENABLE_
        //GPIO Interface Pins
                        // Error handling definitions
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
        DDRB.5   = 1;
        DDRB.6   = 0;
        DDRB.7   = 1;
                        DDRB.2 = 0; 
        DDRB.3     = 1;
        //DDR_RADIO_RESET = 1;
        DDRB.4   = 1;
                        PORTB.3     = 0;
        //RADIO_RESET = 1;
        PORTB.4    = 1;        
                COM_mcu_freq = 0;  // 1 MHz on power-up. 
        COM_IRQ_status = 0;  // initally, no status flags
                                                            //RADIO_SEL = 0; // Select the RADIO for SPI comm
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
    junk = COM_read_register(0x03);
    junk = junk & 0b11110000;
    junk = junk | ((0b00000111)&(clk));
        COM_write_register(0x03,junk);    
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
        PORTB.4    = 0;  // make sure radio is selected
        //First 2 bits are 11, rest is address. Start transmitting command
        SPDR0 = 192 + (address & 0b00111111);
        while((SPSR0&0x80) == 0);  //Wait for transfer to complete
        junk = SPDR0;
        SPDR0 = data;
        while ((SPSR0&0x80) == 0);  //Wait for transfer to complete
        PORTB.4    = 1;   // de-select radio 
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
        PORTB.4    = 0;  // make sure radio is selected
        //Address should only be 6 bits. MSB should be 1, bit 6 should be 0.
        //Writing to SPDR0 starts transmission
        SPDR0 = 128 + (address & 0b00111111);
        while((SPSR0&0x80) == 0); //Wait for transfer to complete
        junk = SPDR0;
        //Start next transmission, transmit junk, get back data from register
        SPDR0 = 0x00;
        while((SPSR0&0x80) == 0); //Wait for transfer to complete
        PORTB.4    = 1;
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
        COM_write_register(0x02,0x09);   // TODO: Make sure radio is in right state to do this. Signal error if not. Do this from HAL?
        PORTB.4    = 0;
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
        PORTB.4    = 1;
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
        PORTB.4    = 0;
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
                PORTB.4    = 1;
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
            (*(unsigned char *) 0x69) |= ((0b00000011)<<(2   <<1));  // set up external interrupt to trigger on rising edge
        EIMSK |= ((0b00000001)<<(2   ));   // enable proper external interrupt line
    }
/*=============================================================
END Enable Interrupt for IRQ
==============================================================*/ 
/*------------------------------------------------------------
Disable Interrupt for IRQ
--------------------------------------------------------------*/ 
    void COM_disable_interrupt_IRQ(void)  {
        (*(unsigned char *) 0x69) &= ~((0b00000011)<<(2   <<1));
        EIMSK &= ~((0b00000001)<<(2   ));
    }
/*=============================================================
END Disable Interrupt for IRQ
==============================================================*/
/*------------------------------------------------------------
Interrupt-based IRQ detection... Need to dispatch appropriate handlers... but where? how?
--------------------------------------------------------------*/ 
    interrupt [4    ] void handle_IRQ(void)  {
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
            COM_IRQ_status = COM_read_register(0x0F);   // upper levels will define how to respond to these interrupts
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
    HAL_tx_frame = 0;
    HAL_rx_frame = 0;
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
        PORTB.1     = 0;
        PORTB.3     = 0;
        delay_us(6);
        PORTB.1     = 1;
        HAL_get_state();  // Read the current state of the radio
                if (HAL_radio_state == 0x00)  {  // then special set-up is necessary
            COM_write_register(0x02,0x08);
            delay_us(510);  // Wait for transition to TRX_OFF state
            HAL_get_state();  // update the current state of the radio, should be in TRX_OFF.
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
                                            delay_us(6);
        if (HAL_radio_state == 0x00) {
            COM_write_register(0x02,0x08);
            delay_us(510);
        }                   
        else {
            COM_write_register(0x02,0x03);
            delay_us(6);
        }
        HAL_get_state();  // update radio state variable
                                        }
/*===========================================================
End Radio State Machine Reset
============================================================*/
/*----------------------------------------------------------
Set Radio Transmit Buffer Length
------------------------------------------------------------*/
void HAL_set_TX_buff_len(unsigned int length)  {
    if (HAL_tx_frame != 0) {  // previously allocated memory, must dealloc first
        free(HAL_tx_frame); 
    }  
    if (length > 128  )  {             
                                    HAL_tx_frame_length = 128  ;          // default to Maximum size
    }                   
    HAL_tx_frame = malloc(length);  // HAL_tx_frame now points to the beginning of the array
    if (HAL_tx_frame == 0) {  // Not enough free memory
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
    if ((HAL_rx_frame != 0)) {  // previously allocated memory, must dealloc first
        free(HAL_rx_frame);
        HAL_rx_frame_length = 0; 
    }  
    if (length > 128  )  {             
                                    HAL_rx_frame_length = 128  ;          // default to Maximum size
    }
                           HAL_rx_frame = malloc(length);  // HAL_rx_frame now points to the beginning of the array
        if (HAL_rx_frame == 0) {  // Not enough free memory
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
                                                    tmp = COM_read_register(0x08);
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
        unsigned char tmp = COM_read_register(0x08);
            if (channel < 11 || channel > 26)  {
                channel = 11;                             
                                                            }
        tmp = (tmp&0b11100000)|channel;
        COM_write_register(0x08,tmp);  
        HAL_radio_channel = channel;
                                            }
/*===========================================================
END Set Radio Channel
=============================================================*/
/*----------------------------------------------------------
Get Transmit Power
------------------------------------------------------------*/ 
    unsigned char HAL_get_transmit_power(void)  {
        unsigned char tmp;
                                                    tmp = COM_read_register(0x05);
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
                                                                }
        tmp = COM_read_register(0x05);
        tmp = (tmp&0b11110000)|(tx_pwr);
        COM_write_register(0x05,tmp);
        HAL_transmit_power = tx_pwr;
    }
/*===========================================================
END Set Transmit Power
=============================================================*/
/*----------------------------------------------------------
Get Radio State
------------------------------------------------------------*/
    void HAL_get_state(void)  {
        HAL_radio_state = (COM_read_register(0x01))&0b00011111;
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
            case 0x08:
                if (HAL_radio_state == 0x06 || HAL_radio_state == 0x09 || HAL_radio_state == 0x19) {
                    COM_write_register(0x02,0x08);  // Send command
                    delay_us(5); //state transition complete in 1 us      /// CHANGE
                }                                         
                else if (HAL_radio_state == 0x0F)  {
                    PORTB.3     = 0; // pull SLP_TR line low
                    delay_us(880); // after 880 us, out of sleep state.
                }   
                else  {
                    COM_write_register(0x02,0x03);
                    delay_us(5);                                         /// CHANGE to 1
                }
            break;
            case 0x06:     
                if (HAL_radio_state == 0x08)  {
                    COM_write_register(0x02,0x06);
                    while(PINB.2      == 0); 
                    COM_read_register(0x0F);
                    //delay_us(180); /// TODO: within this time, IRQ should happen, indicating PLL has locked. We could instead wait for this to occur with 'while(RADIO_IRQ == 0);'...
                }   
                else if (HAL_radio_state == 0x16 || HAL_radio_state == 0x09 || HAL_radio_state == 0x19)  {
                    COM_write_register(0x02,0x06);
                    delay_us(5);                /// CHANGE to 1
                }
                                                                                                    break;
            case 0x09:
                if (HAL_radio_state == 0x08)  {
                    COM_write_register(0x02,0x09);
                    delay_us(180); // within this time, IRQ should happen, indicating PLL has locked. We could instead wait for this to occur with 'while(RADIO_IRQ == 0);'...
                                    // In fact, if IRQ doesn't happen, PLL hasn't locked, and we have an error! Uh-oh!
                }   
                else if (HAL_radio_state == 0x16 || HAL_radio_state == 0x06 || HAL_radio_state == 0x19)  {
                    COM_write_register(0x02,0x06);
                    delay_us(5);          /// CHANGE to 1
                }
                                                                                                    break;
            case 0x16:  //Should only be entered in extended mode...?
                if (HAL_radio_state == 0x08) {
                    COM_write_register(0x02,0x06);
                    delay_us(180);  // TODO: CATCH IRQ HERE!
                    COM_write_register(0x02,0x16);
                    delay_us(5);      /// CHANGE to 1
                }
                else if (HAL_radio_state == 0x06 || HAL_radio_state == 0x09)  {
                    COM_write_register(0x02,0x16);
                    delay_us(5);       /// CHANGE to 1                 
                }                              
                else if (HAL_radio_state == 0x19)  {
                    COM_write_register(0x02,0x09);
                    delay_us(5);        /// CHANGE to 1
                    COM_write_register(0x02,0x16);
                    delay_us(5);        /// CHANGE to 1
                }     
                                                                                                    break;
            case 0x19:                       
                if (HAL_radio_state == 0x08)  {
                    COM_write_register(0x02,0x09);
                    delay_us(180);  // TODO: FIX THIS, CATCH IRQ
                    COM_write_register(0x02,0x19);
                    delay_us(5);    /// CHANGE to 1
                }                            
                else if (HAL_radio_state == 0x06 || HAL_radio_state == 0x09)  {
                    COM_write_register(0x02,0x19);
                    delay_us(5);     /// CHANGE to 1
                }                            
                else if (HAL_radio_state == 0x16)  {
                    COM_write_register(0x02,0x06);
                    delay_us(5);        /// CHANGE to 1
                    COM_write_register(0x02,0x19);
                    delay_us(5);        /// CHANGE to 1
                }     
                                                                                                    break;
            case 0x0F:                             
                if (HAL_radio_state == 0x08)  {
                    PORTB.3     = 1; // pull slp_tr line high to enter sleep mode                    
                    for (i=12;i>0;i--);  //Delay at least 35 cycles...
                                    }          
                                                                                                    break;
            default:
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
                                                }                                  
        tmp = COM_read_register(0x08);
        mode = mode << 5;  // shift bits to proper location.
        tmp = tmp & 0b10011111; // Clear CCA mode bits
        tmp = tmp | mode;  // set CCA mode bits with mode variable
        COM_write_register(0x08,tmp);  
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
        if (HAL_radio_state == 0x06 || HAL_radio_state == 0x01)  {
            tmp = COM_read_register(0x08); 
            tmp = tmp | 0b10000000; // set MSB to 1. 
            COM_write_register(0x08,tmp); // start CCA.
            delay_us(140);  // wait for CCA to finish.
            tmp = COM_read_register(0x01);  // bit 6 is of interest for return value
            /// TODO: check MSB of tmp to make sure that CCA did indeed finish.
            return (tmp & 0b01000000);  // clear all but bit 6, which indicates status of channel.
        }   
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
        if (HAL_radio_state == 0x06 || HAL_radio_state == 0x01)  {
            COM_write_register(0x07,0);
            delay_us(140); 
            return COM_read_register(0x07);
        } 
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
        if (HAL_radio_state == 0x06 || HAL_radio_state == 0x01)  {
            return COM_read_register(0x06);
        }   
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
        PORTB.3     = 1;  // Pull SLP_TR high to force radio into BUSY_TX state. 
        delay_us(5);     /// CHANGE to 1
        PORTB.3     = 0; // Reset pin to 0
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
        PORTB.3     = 1;
        delay_us(5);     /// CHANGE to 1
        PORTB.3     = 0;
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
        COM_write_register(0x02,0x02);  // Tell radio to start transmission
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
        junk = COM_read_register(0x05);
        junk = junk|0b10000000;  // Set MSB to 1, enable auto CRC... ///TODO: DOES THIS IMPACT MAX FRAME SIZES?
        COM_write_register(0x05,junk);  // write back
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
        junk = COM_read_register(0x05);
        junk = junk&0b01111111;  // Set MSB to 0, disable auto CRC... ///TODO: DOES THIS IMPACT MAX FRAME SIZES?
        COM_write_register(0x05,junk);  // write back        
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
        COM_write_register(0x2C,junk);
    }
/*===========================================================
END SETUP AUTOMATED CSMA ALGORITHM
=============================================================*/ 
/*----------------------------------------------------------
DISABLE AUTOMATED CSMA ALGORITHM                                                    
------------------------------------------------------------*/  
    void HAL_auto_csma_disable(void)  {
        unsigned char junk = 0b11110000;
        COM_write_register(0x2C,junk);
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
                junk = COM_read_register(0x2E);
        junk = junk | 0b00001000; // enable coordinator
        COM_write_register(0x2E,junk);
    }
/*===========================================================
END Elect Device as Coordinator
=============================================================*/ 
/*----------------------------------------------------------
Demote device from coordinator to ordinary device
------------------------------------------------------------*/  
    void HAL_demote_coordinator(void)  {
        unsigned char junk;        
        junk = COM_read_register(0x2E);
        junk = junk & 0b11110111; // disable coordinator
        COM_write_register(0x2E,junk);
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
        COM_write_register(0x20,lo);
        COM_write_register(0x21,hi);
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
        COM_write_register(0x22,lo);
        COM_write_register(0x23,hi);
    }
/*===========================================================
END Set the PAN ID of the device
=============================================================*/ 
void HAL_set_CSMA_retries (unsigned char retries)  {
    COM_write_register(0x2C,(retries<<1));
}
/*****************************************************************************
 * kxp74.h
 * Interface code for KXP74 accelerometer, which is compatible with the CUmote platform
 * 
 * Cornell University
 * February 2008
 * Andrew Godbehere and Nathan Ward
 ****************************************************************************/
/****************************************************************************/
//Include
    /*
  CodeVisionAVR C Compiler
  (C) 1998-2004 Pavel Haiduc, HP InfoTech S.R.L.

  Prototype for SPI access function */
  // CodeVisionAVR C Compiler
// (C) 1998-2000 Pavel Haiduc, HP InfoTech S.R.L.
//SPI Chip Select (CS)
//KXP74 SPI Commands
//The accelerometer uses an 8-bit command register to carry out its functions
//Operational Modes
//The 8-bit read/write control register selects the various operational modes
//  Bit 7   Bit 6   Bit 5   Bit 4     Bit 3     Bit 2    Bit 1       Bit 0
//  0       0       0       Speed_0   Speed_1   Enable   Self test   Parity
/****************************************************************************/
void init_sensor_spi(void) {
void init_sensor_spi(void) {
void init_sensor_spi(void) {
void init_sensor_spi(void) {
  //Set SPI chip select data direction
  DDRD.0 = 1;
  //Initialize chip select signals high
  PORTD.0 = 1;
}
/****************************************************************************/
void set_sensor_clock(void) {
  //Set the clock polarity and phase for the accelerometers if other slaves
  //(with different clock settings) are also being used by the MCU
  SPCR0 = 0b01011101;
  SPSR0 = 0;
  //SPCR0 &= 0b11110111;
  //SPCR0 &= 0b11111011;
}
/****************************************************************************/
void init_sensors(void) {
  //Upon power up, the Master must write the operational mode command to
  //each accelerometer's 8-bit control register.
  unsigned char junk = 0;
  //Sensor 1
  PORTD.0 = 0;  //CS low to select sensor 1 and start transmission
  //On the falling edge of CS, 2-byte command written to control register
  junk = spi(0x04);  //Initiate write to the control register
//  junk = spi(DEFAULT_MODE);    //Set enable bit in the register       
  junk = spi(0b00011100);  // lowest sample speed, lowest power use
    PORTD.0 = 1;  //CS goes high at the end of transmission
}
void sensor_standby(void)  {
    unsigned char junk = 0;
    PORTD.0 = 0;
    junk = spi(0x04);
    junk = spi(0b00011000);  // power save mode
    PORTD.0 = 1;
}
/****************************************************************************/
unsigned char get_sensor(unsigned char axis) {
  //Accelerometer Read Back Operation
  //Sample, convert and read back sensor data with 12-bit ADC
  unsigned char byte1, byte2, junk;
      PORTD.0 = 0;  //CS low to select chip and start transmission
      //On the falling edge of CS, 2-byte command written to control reg
      junk = spi(axis);  //Send command to initiate conversion of axis
      //There must be a minimum of 40us between the first and second
      //bytes to give the A/D conversion enough time to complete
      delay_us(50);
      byte1 = spi(0x00);  //Read in most significant 8 bits
      byte2 = spi(0x00);  //Read in least significant 4 bits
      PORTD.0 = 1;  //CS goes high at the end of transmission
      //Return only 8 most significant bits for now
      return byte1;
}
/****************************************************************************/
 /// This is a test program, transmitting data over channel 13 once every second. Use this to test link before attempting accelerometer interface.
    unsigned int ms_counter;
interrupt [14] void handle_tim1(void) {  // will use to set sleep duration, eventually. 
    if (ms_counter > 0)
        ms_counter--;
}
void main(void)  {
    //unsigned char my_msg[16];  
    //unsigned char *string_head;   // make sure we keep track of start of array
    unsigned char i;
    unsigned char sensor_val[2];
    unsigned char sample[3];        
                      // disable portions of MCU that will not be used
    (*(unsigned char *) 0x64) = 0b11100011;  // disable Two Wire Interface, Timer 2, Timer 0, USART, and ADC
            COM_init();
    COM_set_MCU_clock(3);   // set clock to 4 MHz
//    COM_write_register();  //
    HAL_initialization();
    COM_enable_interrupt_IRQ();
    HAL_set_radio_channel(13);
        // accelerometer setup
    init_sensor_spi();
    set_sensor_clock();
    init_sensors();
        //back to radio spi clock
    COM_reset_SPI_clock();
        // timer initialization
    (*(unsigned char *) 0x80) = 0b00000000;
    (*(unsigned char *) 0x89) = 1;
    (*(unsigned char *) 0x88) = 0b11110100;
    (*(unsigned char *) 0x81) = 0b00001010; // clk/8... count to 500 for 1ms at 4MHz.
    (*(unsigned char *) 0x82) = 0; 
    (*(unsigned char *) 0x6f) = 0b00000010;  // interrupt on compare A match
        ms_counter = 0;
        #asm
        sei
    #endasm
        HAL_set_state(0x08);  // initialize radio's state            
        //HAL_set_TX_buff_len(16);  // message is 16 bits long...
   // for (i = 0; i< 16; i++)  {
   //     HAL_tx_frame[i] = i;
   // }
   // COM_download_frame();                               
        HAL_set_TX_buff_len(3); // one byte per axis for now
    while(1)  {
        set_sensor_clock();
        sensor_standby();
        while (ms_counter > 0);  // wait for next sample.
        init_sensors();             
        ms_counter = 5;
        while (ms_counter > 0);  // wait to come out of standby...
        // first, sample accelerometer.
                for (i=0;i<3;i++)  {  // iterate through axes
            HAL_tx_frame[i] = get_sensor(i); // get sample for each axis
        }
                COM_reset_SPI_clock();
        HAL_transmitframe_pin();  // Should download data, then transmit... [fingers crossed]
                if (COM_IRQ_pending == 1)  {
            COM_IRQ_handler();
        }
                // now we should try to put chip to sleep... but that's for later.        
        ms_counter = 10;  // wait 10 ms before transmitting again. Around 100 samples per second...
    }
}  
/*
TODO List:
1) Test transmission/reception
2) Test accelerometer spi data capture
3) Test putting node to sleep
*/                     
