
	.DEF _HAL_tx_frame=R4
	.DEF _HAL_rx_frame=R6
	.DEF _HAL_tx_frame_length=R9
	.DEF _HAL_rx_frame_length=R8
	.DEF _HAL_radio_state=R11
	.DEF _COM_mcu_freq=R12
	.DEF _m644_baud_divisor=R10
	.DEF _busy_flag=R13
_195:
	.DB  0xFF,0xFF,0xFF,0xDD
_196:
	.DW  _ack
_197:
	.DB  0xFF,0xFF,0xFF,0xFF,0x0
_198:
	.DW  _preamble
_199:
	.DB  0xFF,0xFF,0xFF,0xAA
_200:
	.DW  _ed_preamble
_277:
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

	.DW  0x04
	.DW  _ack
	.DW  _195*2

	.DW  0x02
	.DW  _g_ack_head
	.DW  _196*2

	.DW  0x05
	.DW  _preamble
	.DW  _197*2

	.DW  0x02
	.DW  _g_preamble_head
	.DW  _198*2

	.DW  0x04
	.DW  _ed_preamble
	.DW  _199*2

	.DW  0x02
	.DW  _g_ed_preamble_head
	.DW  _200*2

	.DW  0x02
	.DW  _p_S65
	.DW  _277*2

	.DW  0
_0x124:
