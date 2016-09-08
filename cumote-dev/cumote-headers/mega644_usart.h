// Assumes the mcu is a mega644. Requires interrupts enabled to function properly. Assumes a 4MHz clock.

// TODO: Make an Rx Buffer so this can receive messages from USART and build them automatically. Offer function to get one byte at a time from the buffer, as a queue.
//       Buffer will simply drop messages when it's received too many. Need to build in auto-retry in visual c++ prog. and get alert when it's retried too many times.
//       There is more info to receive if head pointer is not equal to tail pointer

#ifndef _CUMOTE_USART_
    #define _CUMOTE_USART_
    
    #define USART_DATA UDR0
    
    void m644_init_usart(void);
    inline void     m644_enable_rx      (void);
    inline void     m644_disable_rx     (void);
    inline void     m644_enable_tx      (void);
    inline void     m644_disable_tx     (void);
    inline void     m644_enable_trx     (void);
    inline void     m644_disable_trx    (void);  
    unsigned char   get_usart_byte      (void);
    unsigned char   is_buffer_empty     (void);
    interrupt [USART0_RXC] void     handle_rxc      (void);
    interrupt [USART0_TXC] void     handle_txc      (void);
    unsigned char m644_add_message(unsigned char *,unsigned char);
                        
    unsigned char m644_baud_divisor; 
    
    struct {
        unsigned char length;  // in number of bytes
        unsigned char *string;
        unsigned char i; //keeps track of which byte we're on
    } usart_msg;
    
    struct  {         
        unsigned char buff[10];
        unsigned char head;  // keep track of current byte to read
        unsigned char tail;  // keep track of current byte to write
        unsigned char num_elements;
    } usart_rx_buffer;
    
    unsigned char busy_flag;  // is a message being sent?
        

    // Standard initialization. Sets all internal registers appropriately. Default of maximum transmission speed  
    void m644_init_usart(void)  {
        m644_baud_divisor = 1;           
        busy_flag = 0;
        UCSR0A = 0b01000010;  // double comm speed
        UCSR0B = 0b11000000;  // enable rx and tx interrupts
        UCSR0C = 0b00000110;  // asynchronous, no parity, one stop bit, 8 data bits
        UBRR0H = 0;
        UBRR0L = 0;  // 0.5 MBps baud rate    
        usart_rx_buffer.head = 0;
        usart_rx_buffer.tail = 0; 
        usart_rx_buffer.num_elements = 0;
        m644_enable_trx();       
    }
    
    void m644_init_usart_slow(void)  {  //9600 baud
        busy_flag = 0;
        UCSR0A = 0b01000000;  
        UCSR0B = 0b11000000;
        UCSR0C = 0b00000110;  // asynchronous, no parity, one stop bit, 8 data bits
        UBRR0H = 0;
        UBRR0L = 25;         //9600 baud
    }
    
    unsigned char m644_add_message(unsigned char *new_msg, unsigned char len) {
        if (busy_flag == 1)
            return 0;  //false
        usart_msg.length = len;
        usart_msg.string = new_msg;
        usart_msg.i = 0;
        return 1;
    }                                              
    
    void m644_start_tx(void) {
        if (usart_msg.i < usart_msg.length)  {
            busy_flag = 1;  // We're busy. Go away now.
            USART_DATA = usart_msg.string[usart_msg.i++];  // send first element
        }
    }
                                                       
    // Initialization that sets baud rate to less than maximum, specified by divisor
//    void m644_init_usart(unsigned char baud_divisor)  {
//        m644_baud_divisor = baud_divisor;
//    }                                                       
    
    inline void m644_enable_rx(void)  {
        UCSR0B |= 0b00010000;
    }
    
    inline void m644_disable_rx(void)  {
        UCSR0B &= 0b11101111;
    }
    
    inline void m644_enable_tx(void)  {
        UCSR0B |= 0b00001000;
    }
    
    inline void m644_disable_tx(void)  {
        UCSR0B &= 0b11110111;
    }      
    
    inline void m644_enable_trx(void)  {
        UCSR0B |= 0b00011000;
    }
    
    inline void m644_disable_trx(void)  {
        UCSR0B &= 0b11100111;
    }                 
    
    interrupt [USART0_RXC] void handle_rxc(void)  {        
        unsigned char junk;  // used to throw away received data if buffer is full
        if (usart_rx_buffer.num_elements < 10)  {
            usart_rx_buffer.buff[usart_rx_buffer.tail++] = USART_DATA;
            usart_rx_buffer.num_elements++;
            if (usart_rx_buffer.tail == 10)
                usart_rx_buffer.tail = 0;
        }             
        else {
            junk = USART_DATA;
        }
    }
    
    unsigned char get_usart_byte(void)  {  // read one byte from rx buffer
        /// TODO: disable interrupt here to prevent producer/consumer race condition? Will that cause problems with RF interrupts?
        unsigned char to_return = NULL;       
        if (usart_rx_buffer.num_elements > 0)  {
            to_return = usart_rx_buffer.buff[usart_rx_buffer.head++];
            usart_rx_buffer.num_elements--;
            if (usart_rx_buffer.head == 10)
                usart_rx_buffer.head = 0;
        }
                /// TODO: BEWARE RACE CONDITION WITH PRODUCER/CONSUMER! DISABLE INTERRUPTS FOR THESE FUNCTIONS???
        return to_return;
    } 
    
    unsigned char is_buffer_empty(void)  {  // return 1 if buffer empty, 0 if buffer has something in it
        if (usart_rx_buffer.num_elements == 0)
            return 1;  //empty
        else
            return 0;  // not empty
    }  
    

    interrupt [USART0_TXC] void handle_txc(void)  {
        PORTD.7 = ~PORTD.7;
        if (usart_msg.i == usart_msg.length)  {
            busy_flag = 0;  // we're done with the message
        }                                                 
        else {
            USART_DATA = usart_msg.string[usart_msg.i++];  // send next byte
        }
    }                  
    
    
#endif