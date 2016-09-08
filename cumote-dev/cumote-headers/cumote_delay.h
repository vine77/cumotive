
 //   unsigned char COM_mcu_freq;   // Byte representing current clock speed of MCU. 16,8,4,2, or 1 MHz. Stored as a power of 2 (4,3,2,1,0)

//Delay specified time in microseconds based on the variable above
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