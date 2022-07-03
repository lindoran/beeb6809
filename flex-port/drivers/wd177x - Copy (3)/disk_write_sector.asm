	* WRITE
	*
	* WRITE ONE SECTOR
WRITE		BSR	SEEK				; SEEK TO TRACK
		LDA	#WTCMND				; SETUP WRITE SCTR COMMAND
	IF DRIVERS_FLEX
		TST	PRCNT				; ARE WE SPOOLING?
		BEQ	WRITE2				; SKIP IF NOT
		SWI3					;  CHANGE TASKS IF SO
		NOP					;  NECESSARY FOR SBUG
	ENDIF
WRITE2		ORCC	#$50				;  DISABLE INTERRUPTS
		STA	COMREG				; ISSUE WRITE COMMAND
		LBSR	DEL32U				; DELAY
		CLRB					;  GET SECTOR LENGTH (=256)
WRITE3		LDA	COMREG				; CHECK WD STATUS
		BITA	#DRQ				; READY FOR DATA?
		BNE	WRITE5				; SKIP IF READY
		BITA	#BUSY				; STILL BUSY?
		BNE	WRITE3				; LOOP IF SO
		TFR	A,B				; ERROR IF NOT
		BRA	WRITE6
WRITE5		LDA	,X+				; GET A DATA BYTE
		STA	DATREG				; SEND TO DISK
		DECB					; DEC THE COUNT
		BNE	WRITE3				; FINISHED?
		BSR	WAIT				; WAIT TIL WD IS FINISHED
WRITE6		BITB	#DRQ
		BEQ	1F	
		TST	DATREG				; DB: clear pending data	
1		ANDB	#WTMSK				; MASK ERRORS
		ANDCC	#$AF				;  ENABLE INTERRUPTS
		RTS					;  RETURN
