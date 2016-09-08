
;CodeVisionAVR C Compiler V1.25.8 Standard
;(C) Copyright 1998-2007 Pavel Haiduc, HP InfoTech s.r.l.
;http://www.hpinfotech.com

;Chip type              : ATmega644
;Program type           : Application
;Clock frequency        : 4.000000 MHz
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
;Automatic register allocation : Off

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

	.INCLUDE "BaseStation.vec"
	.INCLUDE "BaseStation.inc"

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
_var_delay:
;	t -> Y+0
;      14         MOV R16,R12
        MOV R16,R12
;      15         ld R26,y  ; load t into r26. y register is stack pointer. t is lowest on stack.
        ld R26,y  ; load t into r26. y register is stack pointer. t is lowest on stack.
;      16         clr R27   ; promote t to unsigned int
        clr R27   ; promote t to unsigned int
;      17 
        
;      18         cpi R16,0 ; see if r12 is 0
        cpi R16,0 ; see if r12 is 0
;      19         breq startdelay   ; branch to starting delay...       overhead is now a bit more than 5 cycles.
        breq startdelay   ; branch to starting delay...       overhead is now a bit more than 5 cycles.
;      20    preploop:         ;~5 more cycles
   preploop:         ;~5 more cycles
;      21         lsl R26  ; multiply t by 2
        lsl R26  ; multiply t by 2
;      22         rol R27
        rol R27
;      23         dec R16
        dec R16   
;      24         cpi R16,0
        cpi R16,0
;      25         brne preploop
        brne preploop
;      26    startdelay:                      ;overhead: t=0...5. t=1...10. t=2...15. t=3...20. t=4...25.
   startdelay:                      ;overhead: t=0...5. t=1...10. t=2...15. t=3...20. t=4...25.
;      27         subi R26,3     ; lo byte
        subi R26,3     ; lo byte
;      28         sbci R27,0     ; hi byte, with carry
        sbci R27,0     ; hi byte, with carry
;      29         brmi enddelay      ; if result is negative, end loop, done with delay.
        brmi enddelay      ; if result is negative, end loop, done with delay.
;      30    enddelay:
   enddelay:        
	ADIW R28,1
	RET

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
	ST   -Y,R30
	ST   -Y,R17
	RCALL _COM_write_register
	LDD  R17,Y+0
	RJMP _0xEE
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
	RJMP _0xED
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
	RJMP _0xEE
;	i -> R17
_COM_upload_frame:
	SBIW R28,4
	CALL __SAVELOCR6
;	Twait -> R16,R17
;	Tradio -> R18,R19
;	Tmcu -> R20,R21
;	Tspi -> Y+8
;	L -> Y+7
;	i -> Y+6
	LDI  R30,LOW(32)
	ST   -Y,R30
	CALL _var_delay
	CBI  0x5,4
	LDI  R30,LOW(32)
	OUT  0x2E,R30
_0x48:
	IN   R30,0x2D
	SBRS R30,7
	RJMP _0x48
	LDI  R30,LOW(0)
	OUT  0x2E,R30
_0x4B:
	IN   R30,0x2D
	SBRS R30,7
	RJMP _0x4B
	IN   R30,0x2E
	STD  Y+7,R30
	LDI  R31,0
	ST   -Y,R31
	ST   -Y,R30
	RCALL _HAL_set_RX_buff_len
	LDD  R30,Y+7
	SWAP R30
	ANDI R30,0xF0
	LSL  R30
	MOV  R18,R30
	CLR  R19
	LDD  R30,Y+7
	LSL  R30
	LSL  R30
	LSL  R30
	MOV  R26,R30
	LDS  R30,_COM_spi_freq
	CALL __LSLB12
	MOV  R26,R30
	MOV  R30,R12
	CALL __LSRB12
	MOV  R20,R30
	CLR  R21
	LDS  R30,_COM_spi_freq
	LDI  R26,LOW(16)
	CALL __LSLB12
	MOV  R26,R30
	MOV  R30,R12
	CALL __ASRB12
	LDI  R31,0
	SBRC R30,7
	SER  R31
	STD  Y+8,R30
	STD  Y+8+1,R31
	MOVW R26,R18
	SUB  R26,R20
	SBC  R27,R21
	SUB  R26,R30
	SBC  R27,R31
	MOVW R16,R26
	ST   -Y,R16
	CALL _var_delay
	LDI  R30,LOW(0)
	STD  Y+6,R30
_0x4F:
	LDD  R26,Y+6
	CP   R26,R8
	BRSH _0x50
	LDI  R30,LOW(0)
	OUT  0x2E,R30
_0x51:
	IN   R30,0x2D
	SBRS R30,7
	RJMP _0x51
	LDD  R30,Y+6
	LDI  R31,0
	ADD  R30,R6
	ADC  R31,R7
	MOVW R26,R30
	IN   R30,0x2E
	ST   X,R30
	LDD  R30,Y+6
	SUBI R30,-LOW(1)
	STD  Y+6,R30
	RJMP _0x4F
_0x50:
	LDI  R30,LOW(0)
	OUT  0x2E,R30
_0x54:
	IN   R30,0x2D
	SBRS R30,7
	RJMP _0x54
	IN   R30,0x2E
	STS  _HAL_LQI,R30
	SBI  0x5,4
	CALL __LOADLOCR6
	ADIW R28,10
	RET
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
_HAL_initialization:
	CLR  R4
	CLR  R5
	CLR  R6
	CLR  R7
	LDI  R30,LOW(0)
	STS  _HAL_CRC_enabled,R30
	__DELAY_USW 510
	RCALL _HAL_statemachine_reset
	RCALL _HAL_get_radio_channel
	STS  _HAL_radio_channel,R30
	RCALL _HAL_get_transmit_power
	STS  _HAL_transmit_power,R30
	RET
_HAL_statemachine_reset:
	RCALL _HAL_get_state
	__DELAY_USB 8
	TST  R11
	BRNE _0x61
	LDI  R30,LOW(2)
	ST   -Y,R30
	LDI  R30,LOW(8)
	ST   -Y,R30
	CALL _COM_write_register
	__DELAY_USW 510
	RJMP _0x62
_0x61:
	LDI  R30,LOW(2)
	ST   -Y,R30
	LDI  R30,LOW(3)
	ST   -Y,R30
	CALL _COM_write_register
	__DELAY_USB 8
_0x62:
	RCALL _HAL_get_state
	RET
;	length -> Y+0
_HAL_set_RX_buff_len:
;	length -> Y+0
	MOV  R0,R6
	OR   R0,R7
	BREQ _0x67
	ST   -Y,R7
	ST   -Y,R6
	CALL _free
	CLR  R8
_0x67:
	LD   R26,Y
	LDD  R27,Y+1
	CPI  R26,LOW(0x81)
	LDI  R30,HIGH(0x81)
	CPC  R27,R30
	BRLO _0x68
	LDI  R30,LOW(128)
	MOV  R8,R30
_0x68:
	LD   R30,Y
	LDD  R31,Y+1
	ST   -Y,R31
	ST   -Y,R30
	CALL _malloc
	MOVW R6,R30
	MOV  R0,R6
	OR   R0,R7
	BRNE _0x69
	CLR  R8
	RJMP _0x6A
_0x69:
	LDD  R8,Y+0
_0x6A:
	RJMP _0xEE
_HAL_get_radio_channel:
	ST   -Y,R17
;	tmp -> R17
	LDI  R30,LOW(8)
	CALL SUBOPT_0x0
	MOV  R30,R17
	ANDI R30,LOW(0x1F)
	STS  _HAL_radio_channel,R30
	RJMP _0xEF
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
	ST   -Y,R30
	ST   -Y,R17
	CALL _COM_write_register
	LDD  R30,Y+1
	STS  _HAL_radio_channel,R30
	LDD  R17,Y+0
	RJMP _0xEE
_HAL_get_transmit_power:
	ST   -Y,R17
;	tmp -> R17
	LDI  R30,LOW(5)
	CALL SUBOPT_0x0
	MOV  R30,R17
	ANDI R30,LOW(0xF)
	STS  _HAL_transmit_power,R30
_0xEF:
	LD   R17,Y+
	RET
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
	RJMP _0xF0
_0x73:
	LDI  R30,LOW(15)
	CP   R30,R11
	BRNE _0x77
	CBI  0x5,3
	__DELAY_USW 880
	RJMP _0x7A
_0x77:
	LDI  R30,LOW(2)
	ST   -Y,R30
	LDI  R30,LOW(3)
_0xF0:
	ST   -Y,R30
	CALL SUBOPT_0x1
_0x7A:
	RJMP _0x71
_0x72:
	CPI  R30,LOW(0x6)
	BRNE _0x7B
	LDI  R30,LOW(8)
	CP   R30,R11
	BRNE _0x7C
	CALL SUBOPT_0x2
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
	CALL SUBOPT_0x2
	CALL SUBOPT_0x1
_0x81:
_0x80:
	RJMP _0x71
_0x7B:
	CPI  R30,LOW(0x9)
	BRNE _0x84
	LDI  R30,LOW(8)
	CP   R30,R11
	BRNE _0x85
	CALL SUBOPT_0x3
	CALL SUBOPT_0x4
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
	CALL SUBOPT_0x2
	CALL SUBOPT_0x1
_0x87:
_0x86:
	RJMP _0x71
_0x84:
	CPI  R30,LOW(0x16)
	BRNE _0x8A
	LDI  R30,LOW(8)
	CP   R30,R11
	BRNE _0x8B
	CALL SUBOPT_0x2
	CALL SUBOPT_0x4
	RJMP _0xF1
_0x8B:
	LDI  R30,LOW(6)
	CP   R30,R11
	BREQ _0x8E
	LDI  R30,LOW(9)
	CP   R30,R11
	BRNE _0x8D
_0x8E:
	RJMP _0xF1
_0x8D:
	LDI  R30,LOW(25)
	CP   R30,R11
	BRNE _0x91
	CALL SUBOPT_0x3
	CALL SUBOPT_0x1
_0xF1:
	LDI  R30,LOW(2)
	ST   -Y,R30
	LDI  R30,LOW(22)
	ST   -Y,R30
	CALL SUBOPT_0x1
_0x91:
	RJMP _0x71
_0x8A:
	CPI  R30,LOW(0x19)
	BRNE _0x92
	LDI  R30,LOW(8)
	CP   R30,R11
	BRNE _0x93
	CALL SUBOPT_0x3
	CALL SUBOPT_0x4
	RJMP _0xF2
_0x93:
	LDI  R30,LOW(6)
	CP   R30,R11
	BREQ _0x96
	LDI  R30,LOW(9)
	CP   R30,R11
	BRNE _0x95
_0x96:
	RJMP _0xF2
_0x95:
	LDI  R30,LOW(22)
	CP   R30,R11
	BRNE _0x99
	CALL SUBOPT_0x2
	CALL SUBOPT_0x1
_0xF2:
	LDI  R30,LOW(2)
	ST   -Y,R30
	LDI  R30,LOW(25)
	ST   -Y,R30
	CALL SUBOPT_0x1
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
_0xEE:
	ADIW R28,2
	RET
;	mode -> Y+1
;	tmp -> R17
;	tmp -> R17
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
;      31 #include "mega644_usart.h"

	.DSEG
_usart_msg:
	.BYTE 0x4
_usart_rx_buffer:
	.BYTE 0xD

	.CSEG
_m644_init_usart:
	LDI  R30,LOW(1)
	MOV  R10,R30
	CLR  R13
	LDI  R30,LOW(66)
	STS  192,R30
	LDI  R30,LOW(192)
	STS  193,R30
	LDI  R30,LOW(6)
	STS  194,R30
	LDI  R30,LOW(0)
	STS  197,R30
	STS  196,R30
	__PUTB1MN _usart_rx_buffer,10
	__PUTB1MN _usart_rx_buffer,11
	__PUTB1MN _usart_rx_buffer,12
	RCALL _m644_enable_trx
	RET
_m644_add_message:
;	*new_msg -> Y+1
;	len -> Y+0
	LDI  R30,LOW(1)
	CP   R30,R13
	BRNE _0xB6
	LDI  R30,LOW(0)
	RJMP _0xED
_0xB6:
	LD   R30,Y
	STS  _usart_msg,R30
	LDD  R30,Y+1
	LDD  R31,Y+1+1
	__PUTW1MN _usart_msg,1
	LDI  R30,LOW(0)
	__PUTB1MN _usart_msg,3
	LDI  R30,LOW(1)
_0xED:
	ADIW R28,3
	RET
_m644_start_tx:
	__GETB2MN _usart_msg,3
	LDS  R30,_usart_msg
	CP   R26,R30
	BRSH _0xB7
	LDI  R30,LOW(1)
	MOV  R13,R30
	CALL SUBOPT_0x5
_0xB7:
	RET
_m644_enable_trx:
	LDS  R30,193
	ORI  R30,LOW(0x18)
	STS  193,R30
	RET
_handle_rxc:
	CALL SUBOPT_0x6
	ST   -Y,R17
;	junk -> R17
	__GETB2MN _usart_rx_buffer,12
	CPI  R26,LOW(0xA)
	BRSH _0xB8
	__GETB1MN _usart_rx_buffer,11
	SUBI R30,-LOW(1)
	__PUTB1MN _usart_rx_buffer,11
	SUBI R30,LOW(1)
	LDI  R31,0
	SUBI R30,LOW(-_usart_rx_buffer)
	SBCI R31,HIGH(-_usart_rx_buffer)
	MOVW R26,R30
	LDS  R30,198
	ST   X,R30
	__GETB1MN _usart_rx_buffer,12
	SUBI R30,-LOW(1)
	__PUTB1MN _usart_rx_buffer,12
	SUBI R30,LOW(1)
	__GETB2MN _usart_rx_buffer,11
	CPI  R26,LOW(0xA)
	BRNE _0xB9
	LDI  R30,LOW(0)
	__PUTB1MN _usart_rx_buffer,11
_0xB9:
	RJMP _0xBA
_0xB8:
	LDS  R17,198
_0xBA:
	LD   R17,Y+
	RJMP _0xF3
;	to_return -> R17
_handle_txc:
	CALL SUBOPT_0x6
	SBIS 0xB,7
	RJMP _0xBF
	CBI  0xB,7
	RJMP _0xC0
_0xBF:
	SBI  0xB,7
_0xC0:
	__GETB2MN _usart_msg,3
	LDS  R30,_usart_msg
	CP   R30,R26
	BRNE _0xC1
	CLR  R13
	RJMP _0xC2
_0xC1:
	CALL SUBOPT_0x5
_0xC2:
_0xF3:
	LD   R30,Y+
	OUT  SREG,R30
	LD   R31,Y+
	LD   R30,Y+
	LD   R27,Y+
	LD   R26,Y+
	RETI
;      32 
;      33 //unsigned int ms_counter;
;      34 
;      35 /*
;      36 Program description:
;      37    Program listens on Channel 13 for incoming data. On reception, it packages up a message and relays it over the USART through the USB to the pd or MAX module.
;      38    This is derived from packet sniffer code.
;      39 */
;      40 
;      41 
;      42 /*interrupt [TIM1_COMPA] void handle_tim1(void) {
;      43     if (ms_counter > 0)
;      44         ms_counter--;
;      45 } */
;      46 
;      47 //void usart_rx_ack(void);
;      48 void usart_rx_preamble(unsigned char size);
;      49 
;      50 void main(void)  {
_main:
;      51     unsigned char i;
;      52     unsigned char my_msg[4];
;      53     COM_init();
	SBIW R28,4
;	i -> R17
;	my_msg -> Y+0
	CALL _COM_init
;      54     COM_set_MCU_clock(3);   // set clock to 4 MHz
	LDI  R30,LOW(3)
	ST   -Y,R30
	CALL _COM_set_MCU_clock
;      55     COM_enable_interrupt_IRQ();
	CALL _COM_enable_interrupt_IRQ
;      56     HAL_initialization();
	CALL _HAL_initialization
;      57 
;      58     // timer initialization
;      59 /*    TCCR1A = 0b00000000;
;      60     OCR1AH = 1;
;      61     OCR1AL = 0b11110100;
;      62     TCCR1B = 0b00001010; // clk/8... count to 500 for 1ms at 4MHz.
;      63     TCCR1C = 0;
;      64     TIMSK1 = 0b00000010;  // interrupt on compare A match*/
;      65 
;      66     m644_init_usart();  // attempt high speed connection
	CALL _m644_init_usart
;      67 
;      68 //    ms_counter = 500;  // one half second
;      69 
;      70     #asm
;      71         sei
        sei
;      72     #endasm
;      73 
;      74     HAL_set_state(STATUS_TRX_OFF);  // initialize radio's state
	LDI  R30,LOW(8)
	ST   -Y,R30
	CALL _HAL_set_state
;      75 
;      76     HAL_set_radio_channel(13); // switch to channel 13
	LDI  R30,LOW(13)
	ST   -Y,R30
	CALL _HAL_set_radio_channel
;      77     HAL_set_state(STATUS_RX_ON);  // turn receiver on
	LDI  R30,LOW(6)
	ST   -Y,R30
	CALL _HAL_set_state
;      78 
;      79     while(1)  {    // need to check certain flags in usart module periodically and act appropriately
_0xC3:
;      80         if (COM_IRQ_pending == 1)  {  // radio has info for the application
	LDS  R26,_COM_IRQ_pending
	CPI  R26,LOW(0x1)
	BRNE _0xC6
;      81             COM_IRQ_handler();  // check to see what the IRQ was
	CALL _COM_IRQ_handler
;      82             if (COM_IRQ_status == IRQ_RX_START)  {
	LDS  R26,_COM_IRQ_status
	CPI  R26,LOW(0x4)
	BRNE _0xC7
;      83                 COM_upload_frame();  // upload the frame from the radio
	CALL _COM_upload_frame
;      84                 for (i=0;i<3;i++)  {
	LDI  R17,LOW(0)
_0xC9:
	CPI  R17,3
	BRSH _0xCA
;      85                     my_msg[i] = HAL_rx_frame[i];
	MOV  R30,R17
	LDI  R31,0
	MOVW R26,R28
	ADD  R30,R26
	ADC  R31,R27
	MOVW R0,R30
	MOVW R26,R6
	CLR  R30
	ADD  R26,R17
	ADC  R27,R30
	LD   R30,X
	MOVW R26,R0
	ST   X,R30
;      86                 }
	SUBI R17,-1
	RJMP _0xC9
_0xCA:
;      87                 my_msg[3] = HAL_LQI;
	MOVW R30,R28
	ADIW R30,3
	LDS  R26,_HAL_LQI
	STD  Z+0,R26
;      88                 // now, transmit the data over the USART.
;      89                 // first, transmit the preamble and message size
;      90                 usart_rx_preamble(HAL_rx_frame_length+1);
	MOV  R30,R8
	SUBI R30,-LOW(1)
	ST   -Y,R30
	RCALL _usart_rx_preamble
;      91                 // then, pass the usart the pointer to the 802.15.4 message string
;      92                 m644_add_message(my_msg,HAL_rx_frame_length+1);
	MOVW R30,R28
	ST   -Y,R31
	ST   -Y,R30
	MOV  R30,R8
	SUBI R30,-LOW(1)
	ST   -Y,R30
	CALL _m644_add_message
;      93                 m644_start_tx();
	CALL _m644_start_tx
;      94             }
;      95             else if (COM_IRQ_status == IRQ_TRX_END)  {  // either we missed the RX_START IRQ or this is just happening at the end of a received frame that we've already started downloading.
	RJMP _0xCB
_0xC7:
	LDS  R26,_COM_IRQ_status
	CPI  R26,LOW(0x8)
	BRNE _0xCC
;      96             }
;      97         }
_0xCC:
_0xCB:
;      98     }
_0xC6:
	RJMP _0xC3
;      99 }
_0xCD:
	RJMP _0xCD
;     100 
;     101 void usart_rx_preamble(unsigned char size)  {  // pass the size of the message to come
_usart_rx_preamble:
;     102     unsigned char preamble[5];
;     103     preamble[0] = preamble[1] = preamble[2] = preamble[3] = 0xff;
	SBIW R28,5
;	size -> Y+5
;	preamble -> Y+0
	LDI  R30,LOW(255)
	STD  Y+3,R30
	STD  Y+2,R30
	STD  Y+1,R30
	ST   Y,R30
;     104     preamble[4] = size;
	LDD  R30,Y+5
	STD  Y+4,R30
;     105     m644_add_message(preamble,5);
	MOVW R30,R28
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(5)
	ST   -Y,R30
	CALL _m644_add_message
;     106     m644_start_tx();
	CALL _m644_start_tx
;     107     while (busy_flag == 1); // wait for preamble to finish transmitting
_0xCE:
	LDI  R30,LOW(1)
	CP   R30,R13
	BREQ _0xCE
;     108 }
	ADIW R28,6
	RET

_allocate_block_G2:
	SBIW R28,2
	CALL __SAVELOCR6
	__GETWRN 16,17,4096
	MOVW R26,R16
	LDI  R30,LOW(0)
	LDI  R31,HIGH(0)
	ST   X+,R30
	ST   X,R31
_0xD1:
	MOV  R0,R16
	OR   R0,R17
	BREQ _0xD3
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
	BREQ _0xD4
	__PUTWSR 18,19,6
	RJMP _0xD5
_0xD4:
	LDI  R30,LOW(4352)
	LDI  R31,HIGH(4352)
	STD  Y+6,R30
	STD  Y+6+1,R31
_0xD5:
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
	BRLO _0xD6
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
	RJMP _0xEC
_0xD6:
	MOVW R16,R18
	RJMP _0xD1
_0xD3:
	LDI  R30,LOW(0)
	LDI  R31,HIGH(0)
_0xEC:
	CALL __LOADLOCR6
	ADIW R28,10
	RET
_find_prev_block_G2:
	CALL __SAVELOCR4
	__GETWRN 16,17,4096
_0xD7:
	MOV  R0,R16
	OR   R0,R17
	BREQ _0xD9
	MOVW R26,R16
	ADIW R26,2
	CALL __GETW1P
	MOVW R18,R30
	MOVW R26,R30
	LDD  R30,Y+4
	LDD  R31,Y+4+1
	CP   R30,R26
	CPC  R31,R27
	BRNE _0xDA
	MOVW R30,R16
	RJMP _0xEB
_0xDA:
	MOVW R16,R18
	RJMP _0xD7
_0xD9:
	LDI  R30,LOW(0)
	LDI  R31,HIGH(0)
_0xEB:
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
	JMP _0xDB
	SBIW R30,4
	MOVW R16,R30
	ST   -Y,R17
	ST   -Y,R16
	CALL _find_prev_block_G2
	MOVW R18,R30
	SBIW R30,0
	BREQ _0xDC
	MOVW R26,R16
	ADIW R26,2
	CALL __GETW1P
	__PUTW1RNS 18,2
	LDD  R30,Y+8
	LDD  R31,Y+8+1
	SBIW R30,0
	BREQ _0xDD
	ST   -Y,R31
	ST   -Y,R30
	CALL _allocate_block_G2
	MOVW R20,R30
	SBIW R30,0
	BREQ _0xDE
	MOVW R26,R16
	CALL __GETW1P
	STD  Y+6,R30
	STD  Y+6+1,R31
	MOVW R26,R30
	LDD  R30,Y+8
	LDD  R31,Y+8+1
	CP   R26,R30
	CPC  R27,R31
	BRSH _0xDF
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	STD  Y+8,R30
	STD  Y+8+1,R31
_0xDF:
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
	RJMP _0xEA
_0xDE:
	MOVW R30,R16
	__PUTW1RNS 18,2
_0xDD:
_0xDC:
_0xDB:
	LDI  R30,LOW(0)
	LDI  R31,HIGH(0)
_0xEA:
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
	BREQ _0xE0
	ST   -Y,R31
	ST   -Y,R30
	CALL _allocate_block_G2
	MOVW R16,R30
	SBIW R30,0
	BREQ _0xE1
	ST   -Y,R17
	ST   -Y,R16
	LDI  R30,LOW(0)
	ST   -Y,R30
	LDD  R30,Y+5
	LDD  R31,Y+5+1
	ST   -Y,R31
	ST   -Y,R30
	CALL _memset
_0xE1:
_0xE0:
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
_p_S62:
	.BYTE 0x2

	.CSEG

;OPTIMIZER ADDED SUBROUTINE, CALLED 4 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x0:
	ST   -Y,R30
	CALL _COM_read_register
	MOV  R17,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 7 TIMES, CODE SIZE REDUCTION:15 WORDS
SUBOPT_0x1:
	CALL _COM_write_register
	__DELAY_USB 7
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 5 TIMES, CODE SIZE REDUCTION:5 WORDS
SUBOPT_0x2:
	LDI  R30,LOW(2)
	ST   -Y,R30
	LDI  R30,LOW(6)
	ST   -Y,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x3:
	LDI  R30,LOW(2)
	ST   -Y,R30
	LDI  R30,LOW(9)
	ST   -Y,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x4:
	CALL _COM_write_register
	__DELAY_USB 240
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:13 WORDS
SUBOPT_0x5:
	__GETW2MN _usart_msg,1
	__GETB1MN _usart_msg,3
	SUBI R30,-LOW(1)
	__PUTB1MN _usart_msg,3
	SUBI R30,LOW(1)
	LDI  R31,0
	ADD  R26,R30
	ADC  R27,R31
	LD   R30,X
	STS  198,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x6:
	ST   -Y,R26
	ST   -Y,R27
	ST   -Y,R30
	ST   -Y,R31
	IN   R30,SREG
	ST   -Y,R30
	RET

__LSLB12:
	TST  R30
	MOV  R0,R30
	MOV  R30,R26
	BREQ __LSLB12R
__LSLB12L:
	LSL  R30
	DEC  R0
	BRNE __LSLB12L
__LSLB12R:
	RET

__ASRB12:
	TST  R30
	MOV  R0,R30
	MOV  R30,R26
	BREQ __ASRB12R
__ASRB12L:
	ASR  R30
	DEC  R0
	BRNE __ASRB12L
__ASRB12R:
	RET

__LSRB12:
	TST  R30
	MOV  R0,R30
	MOV  R30,R26
	BREQ __LSRB12R
__LSRB12L:
	LSR  R30
	DEC  R0
	BRNE __LSRB12L
__LSRB12R:
	RET

__GETW1P:
	LD   R30,X+
	LD   R31,X
	SBIW R26,1
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
