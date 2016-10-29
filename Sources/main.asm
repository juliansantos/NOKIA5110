; Firmware Julian Santos for NOKIA 5110

            INCLUDE 'MC9S08JM16.inc'
pin_RST EQU 0
pin_DC  EQU 4
pin_LED EQU 5
                  
            XDEF _Startup
            ABSENTRY _Startup

            ORG     0B0H        ; Insert your data definition here
var_delay DS.B   2
            
            ORG    0C000H
            
_Startup:
			CLRA 
           	STA SOPT1 				; disenabling watchdog
            LDHX   #RAMEnd+1        ; initialize the stack pointer
            TXS	

main:		JSR initial_config
			JSR init_SPI
			JSR pulse_RST
			
bucle:		BCLR pin_DC,PTFD ; command mode
			MOV #21H,SPI1DL
			BRCLR SPI1S_SPTEF,SPI1S,*
			MOV #0B8H,SPI1DL
			BRCLR SPI1S_SPTEF,SPI1S,*
			MOV #04H,SPI1DL
			BRCLR SPI1S_SPTEF,SPI1S,*
			MOV #14H,SPI1DL
			BRCLR SPI1S_SPTEF,SPI1S,*
			MOV #20H,SPI1DL
			BRCLR SPI1S_SPTEF,SPI1S,*
			MOV #09H,SPI1DL
			BRCLR SPI1S_SPTEF,SPI1S,*
			
			BRA bucle
			
			BRA main

initial_config:
					BSET 7,PTEDD
					BSET 6,PTEDD
					BSET 5,PTEDD
					BSET 4,PTEDD
					
					BSET pin_LED,PTFDD
					BSET pin_DC,PTFDD
					BSET pin_RST,PTFDD 
					BCLR pin_LED,PTFD
					BCLR pin_DC,PTFD
					BSET pin_RST,PTFD
					RTS 
init_SPI:
					;INITIALIZATION ON SPI AS A MASTER 
					BCLR SPI1C1_LSBFE,SPI1C1                                       ; (NO) LSB First (Shifter Direction)
					BSET SPI1C1_SSOE,SPI1C1                                        ; (YES) Slave Select Output Enable
					BCLR SPI1C1_CPHA,SPI1C1                                        ; (NO) Clock Phase
					BCLR SPI1C1_CPOL,SPI1C1                                        ; (NO) Clock Polarity
					BSET SPI1C1_MSTR,SPI1C1                                        ; (YES) Master Mode 
					BCLR SPI1C1_SPTIE,SPI1C1                              ; (NO) SPI Transmit Interrupt Enable {Polling}
					BSET SPI1C1_SPE,SPI1C1                                ; (YES) SPI System Enable 
					BCLR SPI1C1_SPIE,SPI1C1                               ; (NO) SPI Interrupt Enable (for SPRF and MODF) 
					
					MOV #0H,SPI2C1										  ; (NO) all SPI2			
		
					BCLR SPI2C2_SPC0,SPI2C2                           ; (NO) SPI Pin Control 0
					BCLR SPI2C2_SPISWAI,SPI2C2                        ; (NO) SPI Stop in Wait Mode
					BCLR SPI2C2_BIDIROE,SPI2C2                        ; (NO) Bidirectional Mode Output Enable
					BSET SPI2C2_MODFEN,SPI2C2                         ; (YES) Master Mode-Fault Function Enable
					BCLR SPI2C2_SPIMODE,SPI2C2                        ; (NO) SPI 8 BIT
					BCLR SPI2C2_SPMIE,SPI2C2                          ; (NO) SPI Match Interrupt Enable
		
					MOV #45H,SPI1BR ; 64us period
				;	MOV #%01010100,SPI1C1		 
				;	MOV #%00000000,SPI1C2		 
					RTS
			
pulse_RST:
			MOV #100,var_delay
			JSR delayAx5ms ; 
			BCLR pin_RST,PTFD
			MOV #100,var_delay
			JSR delayAx5ms ; 
			BSET pin_RST,PTFD
			RTS			
;******************************************Subroutine for create delays
delayAx5ms:			 ; 6 cycles the call of subroutine
					PSHH ; save context H
					PSHX ; save context X
					PSHA ; save context A
					LDA var_delay ;  cycles
delay_2:            LDHX #1387H ; 3 cycles 
delay_1:            AIX #-1 ; 2 cycles
			    	CPHX #0 ; 3 cycles  
					BNE delay_1 ; 3 cycles
					DECA ;1 cycle
					CMP #0 ; 2 cycles
					BNE delay_2  ;3 cycles
					PULA ; restore context A
					PULX ; restore context X
					PULH ; restore context H
					RTS ; 5 cycles	
						
            ORG Vreset				; Reset
			DC.W  _Startup	
