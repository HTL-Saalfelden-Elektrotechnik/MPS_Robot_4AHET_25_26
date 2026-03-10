MODULE MainModule
    VAR bool dummyMain := TRUE;

	PROC main()
        dummyMain := checkSafety();
        movetoOrigin;
		
        WaitUntil 0 = tcpServer();
	ENDPROC
ENDMODULE