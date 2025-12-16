MODULE Manager
    VAR bool on_origin := TRUE;

    PROC check_take_testing()
        IF on_origin THEN
            on_origin := FALSE;
            
            closeServerSocket;
            TPWrite "closing handling socket";

            takeTesting;
        ELSE
            TPWrite "Arm not on origin, not taking part on testing";
        ENDIF
    ENDPROC
    
    FUNC bool isOnOrigin()
        dummy := checkSafety();
        RETURN on_origin;
    ENDFUNC
    
    FUNC bool setOrigin(bool set)
        on_origin := set;
        
        RETURN on_origin;
    ENDFUNC
    
    FUNC bool checkSafety()
        IF (on_origin) THEN
            Set D652_10_DO10;
        ELSE
            Reset D652_10_DO10;
        ENDIF
        RETURN TRUE;
    ENDFUNC
ENDMODULE