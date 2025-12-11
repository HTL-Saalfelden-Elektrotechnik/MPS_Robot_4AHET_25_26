MODULE Manager
    VAR bool on_origin := TRUE;

    PROC check_take_testing()
        IF on_origin THEN
            on_origin := FALSE;
            
            testing_take_part;
        ELSE
            TPWrite "Arm not on origin, not taking part on testing";
        ENDIF
    ENDPROC
    
ENDMODULE