MODULE Manager
    VAR bool in_safe_zone := TRUE;

    PROC check_take_testing()
        IF in_safe_zone THEN
            in_safe_zone := FALSE;
            
            closeServerSocket;

            takeTesting;
        ELSE
            TPWrite "Arm not in safe zone, not taking part on testing";
            TPWrite "!!! Human action required !!!";
        ENDIF
    ENDPROC
    
    FUNC bool isSafe()
        RETURN in_safe_zone;
    ENDFUNC
    
    FUNC bool setSafe(bool set)
        in_safe_zone := set;
        
        dummy := checkSafety();
        
        RETURN in_safe_zone;
    ENDFUNC
    
    FUNC bool checkSafety()
        IF (isSafe()) THEN
            Set D652_10_DO10;
        ELSE
            Reset D652_10_DO10;
        ENDIF
        RETURN TRUE;
    ENDFUNC
ENDMODULE