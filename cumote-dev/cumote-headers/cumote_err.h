/*****************************************************************************
 * CU_MOTE Error Code Definitions
 *****************************************************************************/
#define     _CUMOTE_ERR_INCLUDED_

 
 #define    NO_ERR                          0x00
 #define    COM_SPI_SPEED_ERR               0x01   // Parameter used to set speed was invalid      
 #define    HAL_INVALID_STATE_ON_RESET      0x02   // Radio in invalid state after reset. Should be in TRX_OFF, but didn't make it there. This is an error.
 #define    HAL_TX_BUFF_LEN_OUTOFMEM        0x03   // HAL_tx_buff_len function failed to allocate the memory needed
 #define    HAL_TX_BUFF_LEN_INVALIDPARAM    0x04   // invalid parameter to HAL_tx_buff_len function
 #define    HAL_RX_BUFF_LEN_INVALIDPARAM    0x05   // invalid parameter to HAL_rx_buff_len function
 #define    HAL_RX_BUFF_LEN_OUTOFMEM        0x06   // HAL_rx_buff_len function failed to allocate the memory needed
 #define    HAL_GET_CHANNEL_STATE_INVALID   0x07   // HAL get channel function called while radio is in an invalid state (either P_ON or SLEEP)
 #define    HAL_GET_TRANSMIT_POWER_STATE_INVALID   0x08  // HAL get transmit power called while radio in an invalid state (P_ON or SLEEP)
 #define    HAL_SET_RADIO_CHANNEL_INVALID   0x09    // Attempted to set radio channel to an invalid channel
 #define    HAL_SET_TX_PWR_INVALID          0x0A    // Attempted to set radio power to invalid power level
 #define    HAL_INVALID_STATE_TRANSITION    0x0B    // Invalid attempted state transition in HAL_set_state function  
 #define    HAL_STATEMACHINE_RESET_PRE_ERR  0x0C    // Invalid state on attempted state machine reset in HAL_statemachine_reset function
 #define    HAL_STATEMACHINE_RESET_POST_ERR 0x0D    // HAL_statemachine_reset function failed to reset the statemachine properly
 #define    HAL_RUN_CCA_INVALID_STATE       0x0E    // HAL_run_cca function could not be run, radio in wrong state.
 #define    HAL_SET_CCA_MODE_INVALID_PARAMETER  0x0F    // HAL_set_cca_mode function passed an invalid parameter
 #define    HAL_ENERGY_DETECTION_INVALID_STATE  0x10    // HAL_energy_detection function called while radio is in an invalid state
 #define    HAL_GET_RSSI_INVALID_STATE      0x11        // HAL_get_rssi function called while radio is in an invalid state 
