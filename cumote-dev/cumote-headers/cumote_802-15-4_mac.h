#define CUMOTE_802-15-4_INCLUDED
#include "cumote_hal.h"


    //struct PLME  {
        
    //};            
    
    //struct ADDRESS-802-15-4 {
        
    //};
    
    struct MCPS_DATA  {  // use this object to transmit data from MAC to peer. Many of these can be created... define a maximum limit?
        unsigned char   SrcAddrMode;
        unsigned int    SrcPANId;
        unsigned int    *SrcAddr;  // pointer to int; either 1 int or 4 ints
        unsigned char   DstAddrMode;
        unsigned int    DstPANId;
        unsigned int    *DstAddr;  // pointer to int; either 1 int or 4 ints
        unsigned int    msduLength; 
        unsigned char   *msdu;  // array of chars, which is the data to be transmitted
        unsigned char   msduHandle;  // TODO: HANDLE??? Will this be a pointer to the data?                        
        unsigned char   TxOptions; 
    };
                                                                                           
    
    // Handle Idea: Make array of MCPS_DATA structures. Have a maximum number allowable. Implement queue to manage?   
    // TODO: Figure out how much space required structures take up and determine how much space to allocate for each