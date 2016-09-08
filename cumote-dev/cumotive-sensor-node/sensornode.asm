
;CodeVisionAVR C Compiler V1.25.9 Standard
;(C) Copyright 1998-2008 Pavel Haiduc, HP InfoTech s.r.l.
;http://www.hpinfotech.com

;Chip type              : ATmega644
;Program type           : Application
;Clock frequency        : 8.000000 MHz
;Memory model           : Small
;Optimize for           : Size
;(s)printf features     : int, width
;(s)scanf features      : int, width
;External SRAM size     : 0
;Data Stack size        : 1024 byte(s)
;Heap size              : 256 byte(s)
;Promote char to int    : No
;char is unsigned       : Yes
;8 bit enums            : No
;Word align FLASH struct: No
;Enhanced core instructions    : On
;Smart register allocation : On
;Automatic register allocation : On

	#pragma AVRPART ADMIN PART_NAME ATmega644
	#pragma AVRPART MEMORY PROG_FLASH 65536
	#pragma AVRPART MEMORY EEPROM 2048
	#pragma AVRPART MEMORY INT_SRAM SIZE 4096
	#pragma AVRPART MEMORY INT_SRAM START_ADDR 0x100

	.EQU EERE=0x0
	.EQU EEWE=0x1
	.EQU EEMWE=0x2
	.EQU UDRE=0x5
	.EQU RXC=0x7
	.EQU EECR=0x1F
	.EQU EEDR=0x20
	.EQU EEARL=0x21
	.EQU EEARH=0x22
	.EQU SPSR0=0x2D
	.EQU SPDR0=0x2E
	.EQU SMCR=0x33
	.EQU MCUSR=0x34
	.EQU MCUCR=0x35
	.EQU WDTCSR=0x60
	.EQU UCSR0A=0xC0
	.EQU UDR0=0xC6
	.EQU SPL=0x3D
	.EQU SPH=0x3E
	.EQU SREG=0x3F
	.EQU GPIOR0=0x1E

	.DEF R0X0=R0
	.DEF R0X1=R1
	.DEF R0X2=R2
	.DEF R0X3=R3
	.DEF R0X4=R4
	.DEF R0X5=R5
	.DEF R0X6=R6
	.DEF R0X7=R7
	.DEF R0X8=R8
	.DEF R0X9=R9
	.DEF R0XA=R10
	.DEF R0XB=R11
	.DEF R0XC=R12
	.DEF R0XD=R13
	.DEF R0XE=R14
	.DEF R0XF=R15
	.DEF R0X10=R16
	.DEF R0X11=R17
	.DEF R0X12=R18
	.DEF R0X13=R19
	.DEF R0X14=R20
	.DEF R0X15=R21
	.DEF R0X16=R22
	.DEF R0X17=R23
	.DEF R0X18=R24
	.DEF R0X19=R25
	.DEF R0X1A=R26
	.DEF R0X1B=R27
	.DEF R0X1C=R28
	.DEF R0X1D=R29
	.DEF R0X1E=R30
	.DEF R0X1F=R31

	.MACRO __CPD1N
	CPI  R30,LOW(@0)
	LDI  R26,HIGH(@0)
	CPC  R31,R26
	LDI  R26,BYTE3(@0)
	CPC  R22,R26
	LDI  R26,BYTE4(@0)
	CPC  R23,R26
	.ENDM

	.MACRO __CPD2N
	CPI  R26,LOW(@0)
	LDI  R30,HIGH(@0)
	CPC  R27,R30
	LDI  R30,BYTE3(@0)
	CPC  R24,R30
	LDI  R30,BYTE4(@0)
	CPC  R25,R30
	.ENDM

	.MACRO __CPWRR
	CP   R@0,R@2
	CPC  R@1,R@3
	.ENDM

	.MACRO __CPWRN
	CPI  R@0,LOW(@2)
	LDI  R30,HIGH(@2)
	CPC  R@1,R30
	.ENDM

	.MACRO __ADDB1MN
	SUBI R30,LOW(-@0-(@1))
	.ENDM
	.MACRO __ADDB2MN
	SUBI R26,LOW(-@0-(@1))
	.ENDM
	.MACRO __ADDW1MN
	SUBI R30,LOW(-@0-(@1))
	SBCI R31,HIGH(-@0-(@1))
	.ENDM
	.MACRO __ADDW2MN
	SUBI R26,LOW(-@0-(@1))
	SBCI R27,HIGH(-@0-(@1))
	.ENDM
	.MACRO __ADDW1FN
	SUBI R30,LOW(-2*@0-(@1))
	SBCI R31,HIGH(-2*@0-(@1))
	.ENDM
	.MACRO __ADDD1FN
	SUBI R30,LOW(-2*@0-(@1))
	SBCI R31,HIGH(-2*@0-(@1))
	SBCI R22,BYTE3(-2*@0-(@1))
	.ENDM
	.MACRO __ADDD1N
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	SBCI R22,BYTE3(-@0)
	SBCI R23,BYTE4(-@0)
	.ENDM

	.MACRO __ADDD2N
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	SBCI R24,BYTE3(-@0)
	SBCI R25,BYTE4(-@0)
	.ENDM

	.MACRO __SUBD1N
	SUBI R30,LOW(@0)
	SBCI R31,HIGH(@0)
	SBCI R22,BYTE3(@0)
	SBCI R23,BYTE4(@0)
	.ENDM

	.MACRO __SUBD2N
	SUBI R26,LOW(@0)
	SBCI R27,HIGH(@0)
	SBCI R24,BYTE3(@0)
	SBCI R25,BYTE4(@0)
	.ENDM

	.MACRO __ANDBMNN
	LDS  R30,@0+@1
	ANDI R30,LOW(@2)
	STS  @0+@1,R30
	.ENDM

	.MACRO __ANDWMNN
	LDS  R30,@0+@1
	ANDI R30,LOW(@2)
	STS  @0+@1,R30
	LDS  R30,@0+@1+1
	ANDI R30,HIGH(@2)
	STS  @0+@1+1,R30
	.ENDM

	.MACRO __ANDD1N
	ANDI R30,LOW(@0)
	ANDI R31,HIGH(@0)
	ANDI R22,BYTE3(@0)
	ANDI R23,BYTE4(@0)
	.ENDM

	.MACRO __ORBMNN
	LDS  R30,@0+@1
	ORI  R30,LOW(@2)
	STS  @0+@1,R30
	.ENDM

	.MACRO __ORWMNN
	LDS  R30,@0+@1
	ORI  R30,LOW(@2)
	STS  @0+@1,R30
	LDS  R30,@0+@1+1
	ORI  R30,HIGH(@2)
	STS  @0+@1+1,R30
	.ENDM

	.MACRO __ORD1N
	ORI  R30,LOW(@0)
	ORI  R31,HIGH(@0)
	ORI  R22,BYTE3(@0)
	ORI  R23,BYTE4(@0)
	.ENDM

	.MACRO __DELAY_USB
	LDI  R24,LOW(@0)
__DELAY_USB_LOOP:
	DEC  R24
	BRNE __DELAY_USB_LOOP
	.ENDM

	.MACRO __DELAY_USW
	LDI  R24,LOW(@0)
	LDI  R25,HIGH(@0)
__DELAY_USW_LOOP:
	SBIW R24,1
	BRNE __DELAY_USW_LOOP
	.ENDM

	.MACRO __CLRD1S
	LDI  R30,0
	STD  Y+@0,R30
	STD  Y+@0+1,R30
	STD  Y+@0+2,R30
	STD  Y+@0+3,R30
	.ENDM

	.MACRO __GETD1S
	LDD  R30,Y+@0
	LDD  R31,Y+@0+1
	LDD  R22,Y+@0+2
	LDD  R23,Y+@0+3
	.ENDM

	.MACRO __PUTD1S
	STD  Y+@0,R30
	STD  Y+@0+1,R31
	STD  Y+@0+2,R22
	STD  Y+@0+3,R23
	.ENDM

	.MACRO __PUTD2S
	STD  Y+@0,R26
	STD  Y+@0+1,R27
	STD  Y+@0+2,R24
	STD  Y+@0+3,R25
	.ENDM

	.MACRO __POINTB1MN
	LDI  R30,LOW(@0+@1)
	.ENDM

	.MACRO __POINTW1MN
	LDI  R30,LOW(@0+@1)
	LDI  R31,HIGH(@0+@1)
	.ENDM

	.MACRO __POINTD1M
	LDI  R30,LOW(@0)
	LDI  R31,HIGH(@0)
	LDI  R22,BYTE3(@0)
	LDI  R23,BYTE4(@0)
	.ENDM

	.MACRO __POINTW1FN
	LDI  R30,LOW(2*@0+@1)
	LDI  R31,HIGH(2*@0+@1)
	.ENDM

	.MACRO __POINTD1FN
	LDI  R30,LOW(2*@0+@1)
	LDI  R31,HIGH(2*@0+@1)
	LDI  R22,BYTE3(2*@0+@1)
	LDI  R23,BYTE4(2*@0+@1)
	.ENDM

	.MACRO __POINTB2MN
	LDI  R26,LOW(@0+@1)
	.ENDM

	.MACRO __POINTW2MN
	LDI  R26,LOW(@0+@1)
	LDI  R27,HIGH(@0+@1)
	.ENDM

	.MACRO __POINTBRM
	LDI  R@0,LOW(@1)
	.ENDM

	.MACRO __POINTWRM
	LDI  R@0,LOW(@2)
	LDI  R@1,HIGH(@2)
	.ENDM

	.MACRO __POINTBRMN
	LDI  R@0,LOW(@1+@2)
	.ENDM

	.MACRO __POINTWRMN
	LDI  R@0,LOW(@2+@3)
	LDI  R@1,HIGH(@2+@3)
	.ENDM

	.MACRO __POINTWRFN
	LDI  R@0,LOW(@2*2+@3)
	LDI  R@1,HIGH(@2*2+@3)
	.ENDM

	.MACRO __GETD1N
	LDI  R30,LOW(@0)
	LDI  R31,HIGH(@0)
	LDI  R22,BYTE3(@0)
	LDI  R23,BYTE4(@0)
	.ENDM

	.MACRO __GETD2N
	LDI  R26,LOW(@0)
	LDI  R27,HIGH(@0)
	LDI  R24,BYTE3(@0)
	LDI  R25,BYTE4(@0)
	.ENDM

	.MACRO __GETD2S
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	LDD  R24,Y+@0+2
	LDD  R25,Y+@0+3
	.ENDM

	.MACRO __GETB1MN
	LDS  R30,@0+@1
	.ENDM

	.MACRO __GETB1HMN
	LDS  R31,@0+@1
	.ENDM

	.MACRO __GETW1MN
	LDS  R30,@0+@1
	LDS  R31,@0+@1+1
	.ENDM

	.MACRO __GETD1MN
	LDS  R30,@0+@1
	LDS  R31,@0+@1+1
	LDS  R22,@0+@1+2
	LDS  R23,@0+@1+3
	.ENDM

	.MACRO __GETBRMN
	LDS  R@0,@1+@2
	.ENDM

	.MACRO __GETWRMN
	LDS  R@0,@2+@3
	LDS  R@1,@2+@3+1
	.ENDM

	.MACRO __GETWRZ
	LDD  R@0,Z+@2
	LDD  R@1,Z+@2+1
	.ENDM

	.MACRO __GETD2Z
	LDD  R26,Z+@0
	LDD  R27,Z+@0+1
	LDD  R24,Z+@0+2
	LDD  R25,Z+@0+3
	.ENDM

	.MACRO __GETB2MN
	LDS  R26,@0+@1
	.ENDM

	.MACRO __GETW2MN
	LDS  R26,@0+@1
	LDS  R27,@0+@1+1
	.ENDM

	.MACRO __GETD2MN
	LDS  R26,@0+@1
	LDS  R27,@0+@1+1
	LDS  R24,@0+@1+2
	LDS  R25,@0+@1+3
	.ENDM

	.MACRO __PUTB1MN
	STS  @0+@1,R30
	.ENDM

	.MACRO __PUTW1MN
	STS  @0+@1,R30
	STS  @0+@1+1,R31
	.ENDM

	.MACRO __PUTD1MN
	STS  @0+@1,R30
	STS  @0+@1+1,R31
	STS  @0+@1+2,R22
	STS  @0+@1+3,R23
	.ENDM

	.MACRO __PUTBR0MN
	STS  @0+@1,R0
	.ENDM

	.MACRO __PUTDZ2
	STD  Z+@0,R26
	STD  Z+@0+1,R27
	STD  Z+@0+2,R24
	STD  Z+@0+3,R25
	.ENDM

	.MACRO __PUTBMRN
	STS  @0+@1,R@2
	.ENDM

	.MACRO __PUTWMRN
	STS  @0+@1,R@2
	STS  @0+@1+1,R@3
	.ENDM

	.MACRO __PUTBZR
	STD  Z+@1,R@0
	.ENDM

	.MACRO __PUTWZR
	STD  Z+@2,R@0
	STD  Z+@2+1,R@1
	.ENDM

	.MACRO __GETW1R
	MOV  R30,R@0
	MOV  R31,R@1
	.ENDM

	.MACRO __GETW2R
	MOV  R26,R@0
	MOV  R27,R@1
	.ENDM

	.MACRO __GETWRN
	LDI  R@0,LOW(@2)
	LDI  R@1,HIGH(@2)
	.ENDM

	.MACRO __PUTW1R
	MOV  R@0,R30
	MOV  R@1,R31
	.ENDM

	.MACRO __PUTW2R
	MOV  R@0,R26
	MOV  R@1,R27
	.ENDM

	.MACRO __ADDWRN
	SUBI R@0,LOW(-@2)
	SBCI R@1,HIGH(-@2)
	.ENDM

	.MACRO __ADDWRR
	ADD  R@0,R@2
	ADC  R@1,R@3
	.ENDM

	.MACRO __SUBWRN
	SUBI R@0,LOW(@2)
	SBCI R@1,HIGH(@2)
	.ENDM

	.MACRO __SUBWRR
	SUB  R@0,R@2
	SBC  R@1,R@3
	.ENDM

	.MACRO __ANDWRN
	ANDI R@0,LOW(@2)
	ANDI R@1,HIGH(@2)
	.ENDM

	.MACRO __ANDWRR
	AND  R@0,R@2
	AND  R@1,R@3
	.ENDM

	.MACRO __ORWRN
	ORI  R@0,LOW(@2)
	ORI  R@1,HIGH(@2)
	.ENDM

	.MACRO __ORWRR
	OR   R@0,R@2
	OR   R@1,R@3
	.ENDM

	.MACRO __EORWRR
	EOR  R@0,R@2
	EOR  R@1,R@3
	.ENDM

	.MACRO __GETWRS
	LDD  R@0,Y+@2
	LDD  R@1,Y+@2+1
	.ENDM

	.MACRO __PUTWSR
	STD  Y+@2,R@0
	STD  Y+@2+1,R@1
	.ENDM

	.MACRO __MOVEWRR
	MOV  R@0,R@2
	MOV  R@1,R@3
	.ENDM

	.MACRO __INWR
	IN   R@0,@2
	IN   R@1,@2+1
	.ENDM

	.MACRO __OUTWR
	OUT  @2+1,R@1
	OUT  @2,R@0
	.ENDM

	.MACRO __CALL1MN
	LDS  R30,@0+@1
	LDS  R31,@0+@1+1
	ICALL
	.ENDM

	.MACRO __CALL1FN
	LDI  R30,LOW(2*@0+@1)
	LDI  R31,HIGH(2*@0+@1)
	CALL __GETW1PF
	ICALL
	.ENDM

	.MACRO __CALL2EN
	LDI  R26,LOW(@0+@1)
	LDI  R27,HIGH(@0+@1)
	CALL __EEPROMRDW
	ICALL
	.ENDM

	.MACRO __GETW1STACK
	IN   R26,SPL
	IN   R27,SPH
	ADIW R26,@0+1
	LD   R30,X+
	LD   R31,X
	.ENDM

	.MACRO __NBST
	BST  R@0,@1
	IN   R30,SREG
	LDI  R31,0x40
	EOR  R30,R31
	OUT  SREG,R30
	.ENDM


	.MACRO __PUTB1SN
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1SN
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1SN
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1SNS
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	ADIW R26,@1
	ST   X,R30
	.ENDM

	.MACRO __PUTW1SNS
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	ADIW R26,@1
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1SNS
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	ADIW R26,@1
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1PMN
	LDS  R26,@0
	LDS  R27,@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1PMN
	LDS  R26,@0
	LDS  R27,@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1PMN
	LDS  R26,@0
	LDS  R27,@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1PMNS
	LDS  R26,@0
	LDS  R27,@0+1
	ADIW R26,@1
	ST   X,R30
	.ENDM

	.MACRO __PUTW1PMNS
	LDS  R26,@0
	LDS  R27,@0+1
	ADIW R26,@1
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1PMNS
	LDS  R26,@0
	LDS  R27,@0+1
	ADIW R26,@1
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1RN
	MOVW R26,R@0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1RN
	MOVW R26,R@0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1RN
	MOVW R26,R@0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1RNS
	MOVW R26,R@0
	ADIW R26,@1
	ST   X,R30
	.ENDM

	.MACRO __PUTW1RNS
	MOVW R26,R@0
	ADIW R26,@1
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1RNS
	MOVW R26,R@0
	ADIW R26,@1
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1RON
	MOV  R26,R@0
	MOV  R27,R@1
	SUBI R26,LOW(-@2)
	SBCI R27,HIGH(-@2)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1RON
	MOV  R26,R@0
	MOV  R27,R@1
	SUBI R26,LOW(-@2)
	SBCI R27,HIGH(-@2)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1RON
	MOV  R26,R@0
	MOV  R27,R@1
	SUBI R26,LOW(-@2)
	SBCI R27,HIGH(-@2)
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1RONS
	MOV  R26,R@0
	MOV  R27,R@1
	ADIW R26,@2
	ST   X,R30
	.ENDM

	.MACRO __PUTW1RONS
	MOV  R26,R@0
	MOV  R27,R@1
	ADIW R26,@2
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1RONS
	MOV  R26,R@0
	MOV  R27,R@1
	ADIW R26,@2
	CALL __PUTDP1
	.ENDM


	.MACRO __GETB1SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R30,Z
	.ENDM

	.MACRO __GETB1HSX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R31,Z
	.ENDM

	.MACRO __GETW1SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R0,Z+
	LD   R31,Z
	MOV  R30,R0
	.ENDM

	.MACRO __GETD1SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R0,Z+
	LD   R1,Z+
	LD   R22,Z+
	LD   R23,Z
	MOVW R30,R0
	.ENDM

	.MACRO __GETB2SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R26,X
	.ENDM

	.MACRO __GETW2SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R27,X
	MOV  R26,R0
	.ENDM

	.MACRO __GETD2SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R1,X+
	LD   R24,X+
	LD   R25,X
	MOVW R26,R0
	.ENDM

	.MACRO __GETBRSX
	MOVW R30,R28
	SUBI R30,LOW(-@1)
	SBCI R31,HIGH(-@1)
	LD   R@0,Z
	.ENDM

	.MACRO __GETWRSX
	MOVW R30,R28
	SUBI R30,LOW(-@2)
	SBCI R31,HIGH(-@2)
	LD   R@0,Z+
	LD   R@1,Z
	.ENDM

	.MACRO __LSLW8SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R31,Z
	CLR  R30
	.ENDM

	.MACRO __PUTB1SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	ST   X+,R30
	ST   X+,R31
	ST   X+,R22
	ST   X,R23
	.ENDM

	.MACRO __CLRW1SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	CLR  R0
	ST   Z+,R0
	ST   Z,R0
	.ENDM

	.MACRO __CLRD1SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	CLR  R0
	ST   Z+,R0
	ST   Z+,R0
	ST   Z+,R0
	ST   Z,R0
	.ENDM

	.MACRO __PUTB2SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	ST   Z,R26
	.ENDM

	.MACRO __PUTW2SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	ST   Z+,R26
	ST   Z,R27
	.ENDM

	.MACRO __PUTD2SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	ST   Z+,R26
	ST   Z+,R27
	ST   Z+,R24
	ST   Z,R25
	.ENDM

	.MACRO __PUTBSRX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	ST   Z,R@1
	.ENDM

	.MACRO __PUTWSRX
	MOVW R30,R28
	SUBI R30,LOW(-@2)
	SBCI R31,HIGH(-@2)
	ST   Z+,R@0
	ST   Z,R@1
	.ENDM

	.MACRO __PUTB1SNX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R27,X
	MOV  R26,R0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1SNX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R27,X
	MOV  R26,R0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1SNX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R27,X
	MOV  R26,R0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X+,R31
	ST   X+,R22
	ST   X,R23
	.ENDM

	.MACRO __MULBRR
	MULS R@0,R@1
	MOVW R30,R0
	.ENDM

	.MACRO __MULBRRU
	MUL  R@0,R@1
	MOVW R30,R0
	.ENDM

	.MACRO __MULBRR0
	MULS R@0,R@1
	.ENDM

	.MACRO __MULBRRU0
	MUL  R@0,R@1
	.ENDM

	.MACRO __MULBNWRU
	LDI  R26,@2
	MUL  R26,R@0
	MOVW R30,R0
	MUL  R26,R@1
	ADD  R31,R0
	.ENDM

	.CSEG
	.ORG 0

	.INCLUDE "sensornode.vec"
	.INCLUDE "sensornode.inc"

__RESET:
	CLI
	CLR  R30
	OUT  EECR,R30

;INTERRUPT VECTORS ARE PLACED
;AT THE START OF FLASH
	LDI  R31,1
	OUT  MCUCR,R31
	OUT  MCUCR,R30

;DISABLE WATCHDOG
	LDI  R31,0x18
	WDR
	IN   R26,MCUSR
	CBR  R26,8
	OUT  MCUSR,R26
	STS  WDTCSR,R31
	STS  WDTCSR,R30

;CLEAR R2-R14
	LDI  R24,13
	LDI  R26,2
	CLR  R27
__CLEAR_REG:
	ST   X+,R30
	DEC  R24
	BRNE __CLEAR_REG

;CLEAR SRAM
	LDI  R24,LOW(0xF00)
	LDI  R25,HIGH(0xF00)
	LDI  R26,LOW(0x100)
	LDI  R27,HIGH(0x100)
__CLEAR_SRAM:
	ST   X+,R30
	SBIW R24,1
	BRNE __CLEAR_SRAM

;GLOBAL VARIABLES INITIALIZATION
	LDI  R30,LOW(__GLOBAL_INI_TBL*2)
	LDI  R31,HIGH(__GLOBAL_INI_TBL*2)
__GLOBAL_INI_NEXT:
	LPM  R24,Z+
	LPM  R25,Z+
	SBIW R24,0
	BREQ __GLOBAL_INI_END
	LPM  R26,Z+
	LPM  R27,Z+
	LPM  R0,Z+
	LPM  R1,Z+
	MOVW R22,R30
	MOVW R30,R0
__GLOBAL_INI_LOOP:
	LPM  R0,Z+
	ST   X+,R0
	SBIW R24,1
	BRNE __GLOBAL_INI_LOOP
	MOVW R30,R22
	RJMP __GLOBAL_INI_NEXT
__GLOBAL_INI_END:

;GPIOR0 INITIALIZATION
	LDI  R30,__GPIOR0_INIT
	OUT  GPIOR0,R30

;STACK POINTER INITIALIZATION
	LDI  R30,LOW(0xFFF)
	OUT  SPL,R30
	LDI  R30,HIGH(0xFFF)
	OUT  SPH,R30

;DATA STACK POINTER INITIALIZATION
	LDI  R28,LOW(0x500)
	LDI  R29,HIGH(0x500)

	JMP  _main

	.ESEG
	.ORG 0

	.DSEG
	.ORG 0x500
;       1 #include <mega644.h>
;       2 	#ifndef __SLEEP_DEFINED__
	#ifndef __SLEEP_DEFINED__
;       3 	#define __SLEEP_DEFINED__
	#define __SLEEP_DEFINED__
;       4 	.EQU __se_bit=0x01
	.EQU __se_bit=0x01
;       5 	.EQU __sm_mask=0x0E
	.EQU __sm_mask=0x0E
;       6 	.EQU __sm_powerdown=0x04
	.EQU __sm_powerdown=0x04
;       7 	.EQU __sm_powersave=0x06
	.EQU __sm_powersave=0x06
;       8 	.EQU __sm_standby=0x0C
	.EQU __sm_standby=0x0C
;       9 	.EQU __sm_ext_standby=0x0E
	.EQU __sm_ext_standby=0x0E
;      10 	.EQU __sm_adc_noise_red=0x02
	.EQU __sm_adc_noise_red=0x02
;      11 	.SET power_ctrl_reg=smcr
	.SET power_ctrl_reg=smcr
;      12 	#endif
	#endif
;      13 #include "cumote_hal.h"
_HAL_LQI:
	.BYTE 0x1
_HAL_radio_channel:
	.BYTE 0x1
_HAL_transmit_power:
	.BYTE 0x1
_HAL_CRC_enabled:
	.BYTE 0x1

	.CSEG
;	t -> Y+0
;      14         MOV R16,R12
;      15         ld R26,y  ; load t into r26. y register is stack pointer. t is lowest on stack.
;      16         clr R27   ; promote t to unsigned int
;      17 
;      18         cpi R16,0 ; see if r12 is 0
;      19         breq startdelay   ; branch to starting delay...       overhead is now a bit more than 5 cycles.
;      20    preploop:         ;~5 more cycles
;      21         lsl R26  ; multiply t by 2
;      22         rol R27
;      23         dec R16
;      24         cpi R16,0
;      25         brne preploop
;      26    startdelay:                      ;overhead: t=0...5. t=1...10. t=2...15. t=3...20. t=4...25.
;      27         subi R26,3     ; lo byte
;      28         sbci R27,0     ; hi byte, with carry
;      29         brmi enddelay      ; if result is negative, end loop, done with delay.
;      30    enddelay:

	.DSEG
_COM_spi_freq:
	.BYTE 0x1
_COM_IRQ_pending:
	.BYTE 0x1
_COM_IRQ_status:
	.BYTE 0x1

	.CSEG
_COM_init:
	SBI  0x4,5
	CBI  0x4,6
	SBI  0x4,7
	CBI  0x4,2
	SBI  0x4,3
	SBI  0x4,4
	CBI  0x5,3
	SBI  0x5,4
	CLR  R12
	LDI  R30,LOW(0)
	STS  _COM_IRQ_status,R30
	RCALL _COM_reset_SPI_clock
	RET
_COM_reset_SPI_clock:
	LDI  R30,LOW(80)
	OUT  0x2C,R30
	LDI  R30,LOW(1)
	OUT  0x2D,R30
	STS  _COM_spi_freq,R30
	RET
_COM_set_MCU_clock:
	ST   -Y,R17
;	clk -> Y+1
;	junk -> R17
	LDD  R26,Y+1
	CPI  R26,LOW(0x5)
	BRLO _0x13
	LDI  R30,LOW(4)
	STD  Y+1,R30
_0x13:
	LDI  R30,LOW(3)
	CALL SUBOPT_0x0
	ANDI R17,LOW(240)
	LDD  R30,Y+1
	ANDI R30,LOW(0x7)
	OR   R17,R30
	LDI  R30,LOW(3)
	CALL SUBOPT_0x1
	LDD  R17,Y+0
	RJMP _0xF3
;	speed -> Y+0
_COM_write_register:
	ST   -Y,R17
;	address -> Y+2
;	data -> Y+1
;	junk -> R17
	CBI  0x5,4
	LDD  R30,Y+2
	ANDI R30,LOW(0x3F)
	SUBI R30,-LOW(192)
	OUT  0x2E,R30
_0x22:
	IN   R30,0x2D
	SBRS R30,7
	RJMP _0x22
	IN   R17,46
	LDD  R30,Y+1
	OUT  0x2E,R30
_0x25:
	IN   R30,0x2D
	SBRS R30,7
	RJMP _0x25
	SBI  0x5,4
	LDD  R17,Y+0
	ADIW R28,3
	RET
_COM_read_register:
	ST   -Y,R17
;	address -> Y+1
;	junk -> R17
	CBI  0x5,4
	LDD  R30,Y+1
	ANDI R30,LOW(0x3F)
	SUBI R30,-LOW(128)
	OUT  0x2E,R30
_0x2C:
	IN   R30,0x2D
	SBRS R30,7
	RJMP _0x2C
	IN   R17,46
	LDI  R30,LOW(0)
	OUT  0x2E,R30
_0x2F:
	IN   R30,0x2D
	SBRS R30,7
	RJMP _0x2F
	SBI  0x5,4
	IN   R30,0x2E
	LDD  R17,Y+0
	RJMP _0xF3
_COM_download_frame:
	ST   -Y,R17
;	i -> R17
	CALL SUBOPT_0x2
	CBI  0x5,4
	LDI  R30,LOW(96)
	OUT  0x2E,R30
_0x36:
	IN   R30,0x2D
	SBRS R30,7
	RJMP _0x36
	LDS  R26,_HAL_CRC_enabled
	CPI  R26,LOW(0x1)
	BRNE _0x39
	MOV  R30,R9
	SUBI R30,-LOW(2)
	OUT  0x2E,R30
	RJMP _0x3A
_0x39:
	OUT  0x2E,R9
_0x3A:
_0x3B:
	IN   R30,0x2D
	SBRS R30,7
	RJMP _0x3B
	LDI  R17,LOW(0)
_0x3F:
	CP   R17,R9
	BRSH _0x40
	MOVW R26,R4
	CLR  R30
	ADD  R26,R17
	ADC  R27,R30
	LD   R30,X
	OUT  0x2E,R30
_0x41:
	IN   R30,0x2D
	SBRS R30,7
	RJMP _0x41
	SUBI R17,-1
	RJMP _0x3F
_0x40:
	SBI  0x5,4
	RJMP _0xF2
;	Twait -> R16,R17
;	Tradio -> R18,R19
;	Tmcu -> R20,R21
;	Tspi -> Y+8
;	L -> Y+7
;	i -> Y+6
_COM_enable_interrupt_IRQ:
	LDS  R30,105
	ORI  R30,LOW(0x30)
	STS  105,R30
	SBI  0x1D,2
	RET
_handle_IRQ:
	ST   -Y,R30
	LDI  R30,LOW(1)
	STS  _COM_IRQ_pending,R30
	LD   R30,Y+
	RETI
_COM_IRQ_handler:
	LDS  R26,_COM_IRQ_pending
	CPI  R26,LOW(0x1)
	BRNE _0x59
	LDI  R30,LOW(0)
	STS  _COM_IRQ_pending,R30
	LDI  R30,LOW(15)
	ST   -Y,R30
	CALL _COM_read_register
	STS  _COM_IRQ_status,R30
_0x59:
	RET
_COM_disable_CLKM:
	ST   -Y,R17
;	junk -> R17
	LDI  R30,LOW(3)
	CALL SUBOPT_0x0
	ANDI R17,LOW(248)
	LDI  R30,LOW(3)
	CALL SUBOPT_0x1
	RJMP _0xF2
_HAL_initialization:
	CLR  R4
	CLR  R5
	CLR  R6
	CLR  R7
	LDI  R30,LOW(0)
	STS  _HAL_CRC_enabled,R30
	__DELAY_USW 1020
	RCALL _HAL_statemachine_reset
	RCALL _HAL_get_radio_channel
	STS  _HAL_radio_channel,R30
	RCALL _HAL_get_transmit_power
	STS  _HAL_transmit_power,R30
	RET
_HAL_statemachine_reset:
	RCALL _HAL_get_state
	__DELAY_USB 16
	TST  R11
	BRNE _0x61
	LDI  R30,LOW(2)
	ST   -Y,R30
	LDI  R30,LOW(8)
	ST   -Y,R30
	CALL _COM_write_register
	__DELAY_USW 1020
	RJMP _0x62
_0x61:
	LDI  R30,LOW(2)
	ST   -Y,R30
	LDI  R30,LOW(3)
	ST   -Y,R30
	CALL _COM_write_register
	__DELAY_USB 16
_0x62:
	RCALL _HAL_get_state
	RET
_HAL_set_TX_buff_len:
;	length -> Y+0
	MOV  R0,R4
	OR   R0,R5
	BREQ _0x63
	ST   -Y,R5
	ST   -Y,R4
	CALL _free
_0x63:
	LD   R26,Y
	LDD  R27,Y+1
	CPI  R26,LOW(0x81)
	LDI  R30,HIGH(0x81)
	CPC  R27,R30
	BRLO _0x64
	LDI  R30,LOW(128)
	MOV  R9,R30
_0x64:
	LD   R30,Y
	LDD  R31,Y+1
	ST   -Y,R31
	ST   -Y,R30
	CALL _malloc
	MOVW R4,R30
	MOV  R0,R4
	OR   R0,R5
	BRNE _0x65
	CLR  R9
	RJMP _0x66
_0x65:
	LDD  R9,Y+0
_0x66:
	RJMP _0xF3
;	length -> Y+0
_HAL_get_radio_channel:
	ST   -Y,R17
;	tmp -> R17
	LDI  R30,LOW(8)
	CALL SUBOPT_0x0
	MOV  R30,R17
	ANDI R30,LOW(0x1F)
	STS  _HAL_radio_channel,R30
	RJMP _0xF2
_HAL_set_radio_channel:
	ST   -Y,R17
;	channel -> Y+1
;	tmp -> R17
	LDI  R30,LOW(8)
	CALL SUBOPT_0x0
	LDD  R26,Y+1
	CPI  R26,LOW(0xB)
	BRLO _0x6C
	CPI  R26,LOW(0x1B)
	BRLO _0x6B
_0x6C:
	LDI  R30,LOW(11)
	STD  Y+1,R30
_0x6B:
	MOV  R30,R17
	ANDI R30,LOW(0xE0)
	LDD  R26,Y+1
	OR   R30,R26
	MOV  R17,R30
	LDI  R30,LOW(8)
	CALL SUBOPT_0x1
	LDD  R30,Y+1
	STS  _HAL_radio_channel,R30
	LDD  R17,Y+0
	RJMP _0xF3
_HAL_get_transmit_power:
	ST   -Y,R17
;	tmp -> R17
	LDI  R30,LOW(5)
	CALL SUBOPT_0x0
	MOV  R30,R17
	ANDI R30,LOW(0xF)
	STS  _HAL_transmit_power,R30
	RJMP _0xF2
;	tx_pwr -> Y+1
;	tmp -> R17
_HAL_get_state:
	LDI  R30,LOW(1)
	ST   -Y,R30
	CALL _COM_read_register
	ANDI R30,LOW(0x1F)
	MOV  R11,R30
	RET
_HAL_set_state:
	ST   -Y,R17
;	state -> Y+1
;	i -> R17
	LDI  R17,35
	CALL _HAL_get_state
	LDD  R30,Y+1
	CPI  R30,LOW(0x8)
	BRNE _0x72
	LDI  R30,LOW(6)
	CP   R30,R11
	BREQ _0x74
	LDI  R30,LOW(9)
	CP   R30,R11
	BREQ _0x74
	LDI  R30,LOW(25)
	CP   R30,R11
	BRNE _0x73
_0x74:
	LDI  R30,LOW(2)
	ST   -Y,R30
	LDI  R30,LOW(8)
	RJMP _0xF4
_0x73:
	LDI  R30,LOW(15)
	CP   R30,R11
	BRNE _0x77
	CBI  0x5,3
	__DELAY_USW 1760
	RJMP _0x7A
_0x77:
	LDI  R30,LOW(2)
	ST   -Y,R30
	LDI  R30,LOW(3)
_0xF4:
	ST   -Y,R30
	CALL SUBOPT_0x3
_0x7A:
	RJMP _0x71
_0x72:
	CPI  R30,LOW(0x6)
	BRNE _0x7B
	LDI  R30,LOW(8)
	CP   R30,R11
	BRNE _0x7C
	CALL SUBOPT_0x4
	CALL _COM_write_register
_0x7D:
	SBIS 0x3,2
	RJMP _0x7D
	LDI  R30,LOW(15)
	ST   -Y,R30
	CALL _COM_read_register
	RJMP _0x80
_0x7C:
	LDI  R30,LOW(22)
	CP   R30,R11
	BREQ _0x82
	LDI  R30,LOW(9)
	CP   R30,R11
	BREQ _0x82
	LDI  R30,LOW(25)
	CP   R30,R11
	BRNE _0x81
_0x82:
	CALL SUBOPT_0x4
	CALL SUBOPT_0x3
_0x81:
_0x80:
	RJMP _0x71
_0x7B:
	CPI  R30,LOW(0x9)
	BRNE _0x84
	LDI  R30,LOW(8)
	CP   R30,R11
	BRNE _0x85
	CALL SUBOPT_0x2
	CALL SUBOPT_0x5
	RJMP _0x86
_0x85:
	LDI  R30,LOW(22)
	CP   R30,R11
	BREQ _0x88
	LDI  R30,LOW(6)
	CP   R30,R11
	BREQ _0x88
	LDI  R30,LOW(25)
	CP   R30,R11
	BRNE _0x87
_0x88:
	CALL SUBOPT_0x4
	CALL SUBOPT_0x3
_0x87:
_0x86:
	RJMP _0x71
_0x84:
	CPI  R30,LOW(0x16)
	BRNE _0x8A
	LDI  R30,LOW(8)
	CP   R30,R11
	BRNE _0x8B
	CALL SUBOPT_0x4
	CALL _COM_write_register
	CALL SUBOPT_0x5
	RJMP _0xF5
_0x8B:
	LDI  R30,LOW(6)
	CP   R30,R11
	BREQ _0x8E
	LDI  R30,LOW(9)
	CP   R30,R11
	BRNE _0x8D
_0x8E:
	RJMP _0xF5
_0x8D:
	LDI  R30,LOW(25)
	CP   R30,R11
	BRNE _0x91
	CALL SUBOPT_0x2
	__DELAY_USB 13
_0xF5:
	LDI  R30,LOW(2)
	ST   -Y,R30
	LDI  R30,LOW(22)
	ST   -Y,R30
	CALL SUBOPT_0x3
_0x91:
	RJMP _0x71
_0x8A:
	CPI  R30,LOW(0x19)
	BRNE _0x92
	LDI  R30,LOW(8)
	CP   R30,R11
	BRNE _0x93
	CALL SUBOPT_0x2
	CALL SUBOPT_0x5
	RJMP _0xF6
_0x93:
	LDI  R30,LOW(6)
	CP   R30,R11
	BREQ _0x96
	LDI  R30,LOW(9)
	CP   R30,R11
	BRNE _0x95
_0x96:
	RJMP _0xF6
_0x95:
	LDI  R30,LOW(22)
	CP   R30,R11
	BRNE _0x99
	CALL SUBOPT_0x4
	CALL SUBOPT_0x3
_0xF6:
	LDI  R30,LOW(2)
	ST   -Y,R30
	LDI  R30,LOW(25)
	ST   -Y,R30
	CALL SUBOPT_0x3
_0x99:
	RJMP _0x71
_0x92:
	CPI  R30,LOW(0xF)
	BRNE _0xA1
	LDI  R30,LOW(8)
	CP   R30,R11
	BRNE _0x9B
	SBI  0x5,3
	LDI  R17,LOW(12)
_0x9F:
	CPI  R17,1
	BRLO _0xA0
	SUBI R17,1
	RJMP _0x9F
_0xA0:
_0x9B:
_0xA1:
_0x71:
	CALL _HAL_get_state
	LDD  R17,Y+0
_0xF3:
	ADIW R28,2
	RET
;	mode -> Y+1
;	tmp -> R17
;	tmp -> R17
_HAL_transmitframe_pin:
	SBI  0x5,3
	__DELAY_USB 13
	CBI  0x5,3
	CALL _COM_download_frame
	RET
;	junk -> R17
;	junk -> R17
;	user_csma -> Y+1
;	junk -> R17
;	junk -> R17
;	junk -> R17
;	junk -> R17
;	hi -> Y+1
;	lo -> Y+0
;	hi -> Y+1
;	lo -> Y+0
;	retries -> Y+0
;	mask -> Y+0
;      31 #include "kxp74.h"
_init_sensor_spi:
	SBI  0xA,0
	SBI  0xB,0
	RET
_set_sensor_clock:
	LDI  R30,LOW(93)
	OUT  0x2C,R30
	LDI  R30,LOW(0)
	OUT  0x2D,R30
	RET
_init_sensors:
	CALL SUBOPT_0x6
;	junk -> R17
	LDI  R30,LOW(28)
	ST   -Y,R30
	CALL _spi
	MOV  R17,R30
	SBI  0xB,0
	RJMP _0xF2
_sensor_standby:
	CALL SUBOPT_0x6
;	junk -> R17
	LDI  R30,LOW(24)
	ST   -Y,R30
	CALL _spi
	MOV  R17,R30
	SBI  0xB,0
_0xF2:
	LD   R17,Y+
	RET
_get_sensor:
	CALL __SAVELOCR4
;	axis -> Y+4
;	byte1 -> R17
;	byte2 -> R16
;	junk -> R19
	CBI  0xB,0
	LDD  R30,Y+4
	ST   -Y,R30
	CALL _spi
	MOV  R19,R30
	__DELAY_USB 133
	LDI  R30,LOW(0)
	ST   -Y,R30
	CALL _spi
	MOV  R17,R30
	LDI  R30,LOW(0)
	ST   -Y,R30
	CALL _spi
	MOV  R16,R30
	SBI  0xB,0
	MOV  R30,R17
	CALL __LOADLOCR4
	ADIW R28,5
	RET
;      32 
;      33 /*----------------------------------------------------
;      34     This program is the run-time code for the sensor nodes
;      35 in the CUmotive system. It is derived from code used for
;      36 the BOOM 2008 demo.
;      37 
;      38 Features to implement:
;      39     -CSMA-CA distributed time-slot allocation? (Will require something a bit more sophisticated than I first thought)
;      40     -Channel selection (will require a separate program on a base-station that responds to user input, and communicates with whole network)
;      41     -When a node first comes online, it must find a base station to communicate with. Channel scan: send quick pings on a given channel, listen for responses. Select channel with loudest responses. Nothing above a threshold, keep scanning.
;      42 
;      43 
;      44 -----------------------------------------------------*/
;      45 
;      46 #define NODE_STATE_INIT         0
;      47 #define NODE_STATE_CHANNEL_SCAN 1
;      48 #define NODE_STATE_RUNNING      3
;      49 
;      50 unsigned int ms_counter;

	.DSEG
_ms_counter:
	.BYTE 0x2
;      51 register unsigned char node_state;
;      52 
;      53 
;      54 interrupt [TIM1_COMPA] void handle_tim1(void) {  // will use to set sleep duration, eventually.

	.CSEG
_handle_tim1:
	ST   -Y,R0
	ST   -Y,R26
	ST   -Y,R27
	ST   -Y,R30
	ST   -Y,R31
	IN   R30,SREG
	ST   -Y,R30
;      55     if (ms_counter > 0)
	CALL SUBOPT_0x7
	BRSH _0xC6
;      56         ms_counter--;
	LDS  R30,_ms_counter
	LDS  R31,_ms_counter+1
	SBIW R30,1
	CALL SUBOPT_0x8
;      57 }
_0xC6:
	LD   R30,Y+
	OUT  SREG,R30
	LD   R31,Y+
	LD   R30,Y+
	LD   R27,Y+
	LD   R26,Y+
	LD   R0,Y+
	RETI
;      58 
;      59 void main(void)  {
_main:
;      60     //unsigned char my_msg[16];
;      61     //unsigned char *string_head;   // make sure we keep track of start of array
;      62     unsigned char i;
;      63     unsigned char sensor_val[2];
;      64     unsigned char sample[3];
;      65 
;      66     node_state = NODE_STATE_INIT;
	SBIW R28,5
;	i -> R17
;	sensor_val -> Y+3
;	sample -> Y+0
	CLR  R10
;      67 
;      68     // disable portions of MCU that will not be used
;      69     PRR = 0b11100011;  // disable Two Wire Interface, Timer 2, Timer 0, USART, and ADC
	LDI  R30,LOW(227)
	STS  100,R30
;      70 
;      71 
;      72     // Clock setup
;      73     COM_init();
	CALL _COM_init
;      74     COM_set_MCU_clock(4);   // set clock to 8 MHz... except we're configured to run off internal clock.
	LDI  R30,LOW(4)
	ST   -Y,R30
	CALL _COM_set_MCU_clock
;      75     COM_disable_CLKM();      // turn off CLKM as we're running off internal clock
	CALL _COM_disable_CLKM
;      76 
;      77     // Sensor setup
;      78     // accelerometer setup
;      79     init_sensor_spi();
	CALL _init_sensor_spi
;      80     set_sensor_clock();
	CALL _set_sensor_clock
;      81     sensor_standby();  // put sensor in power-save mode. When we want to use the sensor, call init_sensors();
	CALL _sensor_standby
;      82 
;      83     //back to radio spi clock
;      84     COM_reset_SPI_clock();
	CALL _COM_reset_SPI_clock
;      85 
;      86     // timer initialization
;      87     TCCR1A = 0b00000000;
	LDI  R30,LOW(0)
	STS  128,R30
;      88     OCR1AH = 1;
	LDI  R30,LOW(1)
	STS  137,R30
;      89     OCR1AL = 0b11110100;
	LDI  R30,LOW(244)
	STS  136,R30
;      90     TCCR1B = 0b00001010; // clk/8... count to 500 for 1ms at 4MHz.
	LDI  R30,LOW(10)
	STS  129,R30
;      91     TCCR1C = 0;
	LDI  R30,LOW(0)
	STS  130,R30
;      92     TIMSK1 = 0b00000010;  // interrupt on compare A match
	LDI  R30,LOW(2)
	STS  111,R30
;      93 
;      94     ms_counter = 0;
	LDI  R30,0
	STS  _ms_counter,R30
	STS  _ms_counter+1,R30
;      95 
;      96     #asm
;      97         sei
        sei
;      98     #endasm
;      99 
;     100     // Radio network layer initialization
;     101     HAL_initialization();
	CALL _HAL_initialization
;     102     COM_enable_interrupt_IRQ();
	CALL _COM_enable_interrupt_IRQ
;     103     HAL_set_radio_channel(13);  // initialize radio's channel
	LDI  R30,LOW(13)
	ST   -Y,R30
	CALL _HAL_set_radio_channel
;     104     HAL_set_state(STATUS_TRX_OFF);  // initialize radio's state
	LDI  R30,LOW(8)
	ST   -Y,R30
	CALL _HAL_set_state
;     105 
;     106     //node_state = NODE_STATE_CHANNEL_SCAN;  // first, try to find a channel to communicate on
;     107     node_state = NODE_STATE_RUNNING;
	LDI  R30,LOW(3)
	MOV  R10,R30
;     108 
;     109     //HAL_set_TX_buff_len(16);  // message is 16 bits long...
;     110    // for (i = 0; i< 16; i++)  {
;     111    //     HAL_tx_frame[i] = i;
;     112    // }
;     113    // COM_download_frame();
;     114 
;     115     HAL_set_TX_buff_len(3); // one byte per axis for now
	LDI  R30,LOW(3)
	LDI  R31,HIGH(3)
	ST   -Y,R31
	ST   -Y,R30
	CALL _HAL_set_TX_buff_len
;     116     while(1)  {
_0xC7:
;     117 
;     118         if (node_state == NODE_STATE_RUNNING)  {
	LDI  R30,LOW(3)
	CP   R30,R10
	BRNE _0xCA
;     119             set_sensor_clock();
	CALL _set_sensor_clock
;     120             while (ms_counter > 0);  // wait for next sample.
_0xCB:
	CALL SUBOPT_0x7
	BRLO _0xCB
;     121             init_sensors();
	CALL _init_sensors
;     122             ms_counter = 1;
	LDI  R30,LOW(1)
	LDI  R31,HIGH(1)
	CALL SUBOPT_0x8
;     123             while (ms_counter > 0);  // wait to come out of standby... TODO: How long should this take?
_0xCE:
	CALL SUBOPT_0x7
	BRLO _0xCE
;     124             // first, sample accelerometer.
;     125 
;     126             for (i=0;i<3;i++)  {  // iterate through axes
	LDI  R17,LOW(0)
_0xD2:
	CPI  R17,3
	BRSH _0xD3
;     127                 HAL_tx_frame[i] = get_sensor(i); // get sample for each axis
	MOV  R30,R17
	LDI  R31,0
	ADD  R30,R4
	ADC  R31,R5
	PUSH R31
	PUSH R30
	ST   -Y,R17
	CALL _get_sensor
	POP  R26
	POP  R27
	ST   X,R30
;     128             }
	SUBI R17,-1
	RJMP _0xD2
_0xD3:
;     129             sensor_standby();
	CALL _sensor_standby
;     130 
;     131             COM_reset_SPI_clock();
	CALL _COM_reset_SPI_clock
;     132             HAL_transmitframe_pin();  // Should download data, then transmit... [fingers crossed]
	CALL _HAL_transmitframe_pin
;     133 
;     134             if (COM_IRQ_pending == 1)  {
	LDS  R26,_COM_IRQ_pending
	CPI  R26,LOW(0x1)
	BRNE _0xD4
;     135                 COM_IRQ_handler();
	CALL _COM_IRQ_handler
;     136             }
;     137             // now we should try to put chip to sleep... but that's for later.
;     138             ms_counter = 10;  // wait 10 ms before transmitting again. Around 100 samples per second...
_0xD4:
	LDI  R30,LOW(10)
	LDI  R31,HIGH(10)
	CALL SUBOPT_0x8
;     139         }
;     140     }
_0xCA:
	RJMP _0xC7
;     141 }
_0xD5:
	RJMP _0xD5
;     142 
;     143 /*
;     144 TODO List:
;     145 1) Test transmission/reception
;     146 2) Test accelerometer spi data capture
;     147 3) Test putting node to sleep
;     148 */

_allocate_block_G2:
	SBIW R28,2
	CALL __SAVELOCR6
	__GETWRN 16,17,4096
	MOVW R26,R16
	LDI  R30,LOW(0)
	LDI  R31,HIGH(0)
	ST   X+,R30
	ST   X,R31
_0xD6:
	MOV  R0,R16
	OR   R0,R17
	BREQ _0xD8
	MOVW R26,R16
	CALL __GETW1P
	ADD  R30,R16
	ADC  R31,R17
	ADIW R30,4
	MOVW R20,R30
	ADIW R26,2
	CALL __GETW1P
	MOVW R18,R30
	SBIW R30,0
	BREQ _0xD9
	__PUTWSR 18,19,6
	RJMP _0xDA
_0xD9:
	LDI  R30,LOW(4352)
	LDI  R31,HIGH(4352)
	STD  Y+6,R30
	STD  Y+6+1,R31
_0xDA:
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	SUB  R30,R20
	SBC  R31,R21
	MOVW R26,R30
	LDD  R30,Y+8
	LDD  R31,Y+8+1
	ADIW R30,4
	CP   R26,R30
	CPC  R27,R31
	BRLO _0xDB
	MOVW R30,R20
	__PUTW1RNS 16,2
	MOVW R30,R18
	__PUTW1RNS 20,2
	LDD  R30,Y+8
	LDD  R31,Y+8+1
	MOVW R26,R20
	ST   X+,R30
	ST   X,R31
	__ADDWRN 20,21,4
	MOVW R30,R20
	RJMP _0xF1
_0xDB:
	MOVW R16,R18
	RJMP _0xD6
_0xD8:
	LDI  R30,LOW(0)
	LDI  R31,HIGH(0)
_0xF1:
	CALL __LOADLOCR6
	ADIW R28,10
	RET
_find_prev_block_G2:
	CALL __SAVELOCR4
	__GETWRN 16,17,4096
_0xDC:
	MOV  R0,R16
	OR   R0,R17
	BREQ _0xDE
	MOVW R26,R16
	ADIW R26,2
	CALL __GETW1P
	MOVW R18,R30
	MOVW R26,R30
	LDD  R30,Y+4
	LDD  R31,Y+4+1
	CP   R30,R26
	CPC  R31,R27
	BRNE _0xDF
	MOVW R30,R16
	RJMP _0xF0
_0xDF:
	MOVW R16,R18
	RJMP _0xDC
_0xDE:
	LDI  R30,LOW(0)
	LDI  R31,HIGH(0)
_0xF0:
	CALL __LOADLOCR4
	ADIW R28,6
	RET
_realloc:
	SBIW R28,2
	CALL __SAVELOCR6
	LDD  R30,Y+10
	LDD  R31,Y+10+1
	SBIW R30,0
	BRNE PC+3
	JMP _0xE0
	SBIW R30,4
	MOVW R16,R30
	ST   -Y,R17
	ST   -Y,R16
	CALL _find_prev_block_G2
	MOVW R18,R30
	SBIW R30,0
	BREQ _0xE1
	MOVW R26,R16
	ADIW R26,2
	CALL __GETW1P
	__PUTW1RNS 18,2
	LDD  R30,Y+8
	LDD  R31,Y+8+1
	SBIW R30,0
	BREQ _0xE2
	ST   -Y,R31
	ST   -Y,R30
	CALL _allocate_block_G2
	MOVW R20,R30
	SBIW R30,0
	BREQ _0xE3
	MOVW R26,R16
	CALL __GETW1P
	STD  Y+6,R30
	STD  Y+6+1,R31
	MOVW R26,R30
	LDD  R30,Y+8
	LDD  R31,Y+8+1
	CP   R26,R30
	CPC  R27,R31
	BRSH _0xE4
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	STD  Y+8,R30
	STD  Y+8+1,R31
_0xE4:
	ST   -Y,R21
	ST   -Y,R20
	LDD  R30,Y+12
	LDD  R31,Y+12+1
	ST   -Y,R31
	ST   -Y,R30
	LDD  R30,Y+12
	LDD  R31,Y+12+1
	ST   -Y,R31
	ST   -Y,R30
	CALL _memmove
	MOVW R30,R20
	RJMP _0xEF
_0xE3:
	MOVW R30,R16
	__PUTW1RNS 18,2
_0xE2:
_0xE1:
_0xE0:
	LDI  R30,LOW(0)
	LDI  R31,HIGH(0)
_0xEF:
	CALL __LOADLOCR6
	ADIW R28,12
	RET
_malloc:
	ST   -Y,R17
	ST   -Y,R16
	__GETWRN 16,17,0
	LDD  R30,Y+2
	LDD  R31,Y+2+1
	SBIW R30,0
	BREQ _0xE5
	ST   -Y,R31
	ST   -Y,R30
	CALL _allocate_block_G2
	MOVW R16,R30
	SBIW R30,0
	BREQ _0xE6
	ST   -Y,R17
	ST   -Y,R16
	LDI  R30,LOW(0)
	ST   -Y,R30
	LDD  R30,Y+5
	LDD  R31,Y+5+1
	ST   -Y,R31
	ST   -Y,R30
	CALL _memset
_0xE6:
_0xE5:
	MOVW R30,R16
	LDD  R17,Y+1
	LDD  R16,Y+0
	ADIW R28,4
	RET
_free:
	LD   R30,Y
	LDD  R31,Y+1
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(0)
	LDI  R31,HIGH(0)
	ST   -Y,R31
	ST   -Y,R30
	CALL _realloc
	ADIW R28,2
	RET
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
_spi:
	LD   R30,Y
	OUT  0x2E,R30
_0xE7:
	IN   R30,0x2D
	SBRS R30,7
	RJMP _0xE7
	IN   R30,0x2E
	ADIW R28,1
	RET
_memmove:
    ldd  r25,y+1
    ld   r24,y
    adiw r24,0
    breq memmove3
    ldd  r27,y+5
    ldd  r26,y+4
    ldd  r31,y+3
    ldd  r30,y+2
    cp   r30,r26
    cpc  r31,r27
    breq memmove3
    brlt memmove1
memmove0:
    ld   r22,z+
    st   x+,r22
    sbiw r24,1
    brne memmove0
    rjmp memmove3
memmove1:
    add  r26,r24
    adc  r27,r25
    add  r30,r24
    adc  r31,r25
memmove2:
    ld   r22,-z
    st   -x,r22
    sbiw r24,1
    brne memmove2
memmove3:
    ldd  r31,y+5
    ldd  r30,y+4
	ADIW R28,6
	RET
_memset:
    ldd  r27,y+1
    ld   r26,y
    adiw r26,0
    breq memset1
    ldd  r31,y+4
    ldd  r30,y+3
    ldd  r22,y+2
memset0:
    st   z+,r22
    sbiw r26,1
    brne memset0
memset1:
    ldd  r30,y+3
    ldd  r31,y+4
	ADIW R28,5
	RET

	.DSEG
_p_S5C:
	.BYTE 0x2

	.CSEG

;OPTIMIZER ADDED SUBROUTINE, CALLED 5 TIMES, CODE SIZE REDUCTION:5 WORDS
SUBOPT_0x0:
	ST   -Y,R30
	CALL _COM_read_register
	MOV  R17,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x1:
	ST   -Y,R30
	ST   -Y,R17
	JMP  _COM_write_register

;OPTIMIZER ADDED SUBROUTINE, CALLED 4 TIMES, CODE SIZE REDUCTION:9 WORDS
SUBOPT_0x2:
	LDI  R30,LOW(2)
	ST   -Y,R30
	LDI  R30,LOW(9)
	ST   -Y,R30
	JMP  _COM_write_register

;OPTIMIZER ADDED SUBROUTINE, CALLED 6 TIMES, CODE SIZE REDUCTION:12 WORDS
SUBOPT_0x3:
	CALL _COM_write_register
	__DELAY_USB 13
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 5 TIMES, CODE SIZE REDUCTION:5 WORDS
SUBOPT_0x4:
	LDI  R30,LOW(2)
	ST   -Y,R30
	LDI  R30,LOW(6)
	ST   -Y,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x5:
	__DELAY_USW 360
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x6:
	ST   -Y,R17
	LDI  R17,0
	CBI  0xB,0
	LDI  R30,LOW(4)
	ST   -Y,R30
	CALL _spi
	MOV  R17,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:5 WORDS
SUBOPT_0x7:
	LDS  R26,_ms_counter
	LDS  R27,_ms_counter+1
	CALL __CPW02
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x8:
	STS  _ms_counter,R30
	STS  _ms_counter+1,R31
	RET

__GETW1P:
	LD   R30,X+
	LD   R31,X
	SBIW R26,1
	RET

__CPW02:
	CLR  R0
	CP   R0,R26
	CPC  R0,R27
	RET

__SAVELOCR6:
	ST   -Y,R21
__SAVELOCR5:
	ST   -Y,R20
__SAVELOCR4:
	ST   -Y,R19
__SAVELOCR3:
	ST   -Y,R18
__SAVELOCR2:
	ST   -Y,R17
	ST   -Y,R16
	RET

__LOADLOCR6:
	LDD  R21,Y+5
__LOADLOCR5:
	LDD  R20,Y+4
__LOADLOCR4:
	LDD  R19,Y+3
__LOADLOCR3:
	LDD  R18,Y+2
__LOADLOCR2:
	LDD  R17,Y+1
	LD   R16,Y
	RET

;END OF CODE MARKER
__END_OF_CODE:
