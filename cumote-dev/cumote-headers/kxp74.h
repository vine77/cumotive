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
#ifndef _KXP74_INCLUDED_
    #define _KXP74_INCLUDED_
#endif
#include <spi.h>
#include <delay.h>

//SPI Chip Select (CS)
#define DDR_SENSOR1_CS   DDRD.0
#define SENSOR1_CS       PORTD.0

//KXP74 SPI Commands
//The accelerometer uses an 8-bit command register to carry out its functions
#define CONVERT_XAXIS    0x00
#define CONVERT_ZAXIS    0x01
#define CONVERT_YAXIS    0x02
#define READ_REGISTER    0x03
#define WRITE_REGISTER   0x04

//Operational Modes
//The 8-bit read/write control register selects the various operational modes
//  Bit 7   Bit 6   Bit 5   Bit 4     Bit 3     Bit 2    Bit 1       Bit 0
//  0       0       0       Speed_0   Speed_1   Enable   Self test   Parity
#define DEFAULT_MODE     0b00100  //Enable and set to 32KHz low noise mode
#define STANDBY_MODE     0b00000
#define SELF_TEST        0b00110

/****************************************************************************/
void init_sensor_spi(void) {
  //Set SPI chip select data direction
  DDR_SENSOR1_CS = 1;
  //Initialize chip select signals high
  SENSOR1_CS = 1;
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
  SENSOR1_CS = 0;  //CS low to select sensor 1 and start transmission
  //On the falling edge of CS, 2-byte command written to control register
  junk = spi(WRITE_REGISTER);  //Initiate write to the control register
//  junk = spi(DEFAULT_MODE);    //Set enable bit in the register       

  junk = spi(0b00011100);  // lowest sample speed, lowest power use
  
  SENSOR1_CS = 1;  //CS goes high at the end of transmission
}

void sensor_standby(void)  {
    unsigned char junk = 0;
    SENSOR1_CS = 0;
    junk = spi(WRITE_REGISTER);
    junk = spi(0b00011000);  // power save mode
    SENSOR1_CS = 1;
}

/****************************************************************************/
unsigned char get_sensor(unsigned char axis) {
  //Accelerometer Read Back Operation
  //Sample, convert and read back sensor data with 12-bit ADC
  unsigned char byte1, byte2, junk;
      SENSOR1_CS = 0;  //CS low to select chip and start transmission
      //On the falling edge of CS, 2-byte command written to control reg
      junk = spi(axis);  //Send command to initiate conversion of axis
      //There must be a minimum of 40us between the first and second
      //bytes to give the A/D conversion enough time to complete
      delay_us(50);
      byte1 = spi(0x00);  //Read in most significant 8 bits
      byte2 = spi(0x00);  //Read in least significant 4 bits

      SENSOR1_CS = 1;  //CS goes high at the end of transmission
      //Return only 8 most significant bits for now
      return byte1;
}

/****************************************************************************/