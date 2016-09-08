
	.DEF _HAL_tx_frame=R4
	.DEF _HAL_rx_frame=R6
	.DEF _HAL_tx_frame_length=R9
	.DEF _HAL_rx_frame_length=R8
	.DEF _HAL_radio_state=R11
	.DEF _COM_mcu_freq=R12
	.DEF _m644_baud_divisor=R10
	.DEF _busy_flag=R13
_229:
	.DW  0x00

;GPIOR0 INITIALIZATION
	.EQU  __GPIOR0_INIT=0x00

;HEAP START MARKER INITIALIZATION
__HEAP_START_MARKER:
	.DW  0,0

__GLOBAL_INI_TBL:
	.DW  0x04
	.DW  0x1000
	.DW  __HEAP_START_MARKER*2

	.DW  0x02
	.DW  _p_S62
	.DW  _229*2

	.DW  0
_0xF4:
