	* CHKRDY
	*
	* CHECK DRIVE READY ROUTINE
CHKRDY		LDA	3,X				; GET DRIVE NUMBER
		CMPA	#1				; BE SURE IT'S 0 OR 1
		BLS	OK				; BRANCH IF OK
		LDB	#$80				; ELSE, SHOW NOT READY
		ORCC	#$01				; SEC
		RTS					; RETURN
OK		CLRB					;  SHOW NO ERROR Z, Cy=0
		RTS
		
