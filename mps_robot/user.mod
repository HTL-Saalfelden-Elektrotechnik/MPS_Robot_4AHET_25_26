MODULE user
    VAR bool dummy;
	CONST robtarget demo1 :=[[-37.66,384.13,588.69],[0.325256,-0.626832,0.628471,0.326059],[1,-1,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
	CONST robtarget demo12:=[[-37.66,384.13,477.55],[0.325228,-0.626811,0.628499,0.326073],[1,-1,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
	CONST robtarget demo2 :=[[-168.31,386.22,611.37],[0.325279,-0.626817,0.628504,0.326002],[1,-1,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
	CONST robtarget demo22:=[[-168.32,386.24,477.53],[0.325274,-0.626819,0.628497,0.326016],[1,-1,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
	TASK PERS tooldata mps_gripper:=[TRUE,[[19.1444,-0.0485131,159.842],[1,0,0,0]],[0.2,[0,0,0],[1,0,0,0],0,0,0]];
	TASK PERS wobjdata mps_schiene_2:=[FALSE,TRUE,"",[[0,0,0],[1,0,0,0]],[[181.648,-451.609,156.535],[0.692856,0.141225,-0.126493,-0.695705]]];
	TASK PERS tooldata mps2:=[TRUE,[[-539023,250370,210589],[1,0,0,0]],[0.3,[0,0,0],[1,0,0,0],0,0,0]];
	CONST robtarget origin:=[[63.48,0.03,678.23],[0.461605,2.06047E-05,0.887086,-4.94406E-05],[0,-1,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
	CONST robtarget safety_testing:=[[194.38,-433.69,561.10],[0.461556,-9.98679E-05,0.887111,-7.75619E-05],[-1,0,-1,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
	CONST robtarget testing_origin:=[[194.36,-299.83,661.42],[0.461504,-8.58549E-05,0.887138,-7.04485E-05],[-1,0,-1,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
	CONST robtarget testing:=[[191.71,-436.39,105.97],[0.617731,0.000120194,0.786389,-0.000499537],[-1,1,-2,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    CONST robtarget slide_handling:=[[177.52,279.35,82.28],[0.618294,0.0112885,0.785812,0.00920564],[0,-2,2,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    CONST robtarget slide_handling1:=[[66.35,279.32,289.53],[0.618245,0.0112295,0.785852,0.00915021],[1,-1,1,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    CONST robtarget belt_sorting := [[403.06,430.23,239.83],[0.455551,0.00283861,0.889125,0.0438342],[0,-1,1,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    CONST robtarget belt_sorting1:=[[408.70,430.84,292.96],[0.429055,0.0057989,0.903254,0.003164],[0,-1,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    CONST robtarget belt_sorting2:=[[169.65,430.83,292.96],[0.429038,0.00580409,0.903262,0.0031333],[0,-1,1,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    CONST robtarget safety_45:=[[94.86,349.26,539.38],[0.429064,0.0058247,0.903249,0.00335818],[0,-1,1,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    CONST robtarget drop_box:=[[-0.52,-108.19,431.52],[0.324939,0.629938,0.624648,-0.327729],[-2,-1,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    CONST robtarget drop_box1:=[[-0.52,-108.19,653.61],[0.324936,0.629952,0.624642,-0.327719],[-2,-1,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    
    PROC demo()
        ! move to starting point (optional)
        MoveL origin, v400, fine, tool0;
        
        MoveL demo12, v400, fine, tool0;
        
        ! Close Gripper
        Reset do_Auf;
        Set do_Zu;

        ! Move to second point
        MoveL demo1, v400, fine, tool0;
        MoveL demo2, v400, fine, tool0;
        MoveL demo22, v400, fine, tool0;

        ! Open gripper
        Reset do_Zu;
        Set do_Auf;

        ! move to starting point
        MoveL demo2, v400, fine, tool0;
        MoveL demo1, v400, fine, tool0;
        
        MoveL origin, v400, fine, tool0;

        TPWrite "Demo done";
    ENDPROC
    
    PROC moveToOrigin()
		MoveJ origin, v400, z0, tool0;
        
        dummy := setSafe(TRUE);
	ENDPROC
    
	PROC takeTesting()
        TPWrite "Taking part on testing";
        
        
		!MoveL [[265.41,-261.25,677.52],[0.470964,-0.0386347,0.881165,-0.0157509],[-1,0,-1,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]], v400, z15, tool0;
		MoveL [[73.33,-261.25,677.51],[0.470972,-0.0386563,0.881161,-0.0157133],[-1,0,-1,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]], v400, z15, tool0;

		Set do_Auf;
        
        MoveJ [[73.33,-440.50,199.61],[0.471171,-0.00572951,0.882021,0.00187983],[-1,0,-2,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]], v400, z0, tool0;
		MoveJ [[185.77,-444.71,179.53],[0.599925,-0.0212401,0.799564,0.0183378],[-1,1,-2,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]], v400, z0, tool0;
		MoveL [[185.78,-444.71,108.94],[0.600043,-0.021302,0.799474,0.0183213],[-1,1,-2,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]], v400, z0, tool0;
		MoveL [[193.02,-444.74,108.95],[0.600027,-0.021247,0.799489,0.0182769],[-1,1,-2,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]], v400, fine, tool0;

        Reset do_Auf;
		Set do_Zu;
		WaitTime 0.5;
        
        dummy := testing_reset_counter();


		MoveL [[193.01,-444.74,575.52],[0.6,-0.0212249,0.799509,0.0182975],[-1,0,-1,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]], v400, z200, tool0;
		MoveL [[193.01,301.77,583.32],[0.599978,-0.0212565,0.799525,0.0182967],[0,-1,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]], v400, z0, tool0;

        dummy := checkSafety();
        WaitDI D652_10_DI10, 1;
        
		!MoveL [[193.01,301.77,281.89],[0.599978,-0.021248,0.799525,0.0182889],[0,-2,1,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]], v400, z0, tool0;
		MoveJ belt_sorting2, v400, z150, tool0;
        
		MoveL belt_sorting1, v400, z0, tool0;
        MoveL belt_sorting, v400, fine, tool0;
        
        Reset do_Zu;
		Set do_Auf;
        
		WaitTime 0.5;
		
        if(not sorting_start_belt()) THEN
            abort_sorting;
        ENDIF

		MoveL belt_sorting1, v400, fine, tool0;

        MoveL belt_sorting2, v400, z100, tool0;
		MoveJ safety_45, v400, z100, tool0;

        dummy := setSafe(TRUE);
        
		moveToOrigin;
	ENDPROC
    
    PROC take_handling()
        ! Move to slide
        MoveL slide_handling1, v1000, fine, tool0;
        MoveL slide_handling, v400, fine, tool0;
        
        ! Close gripper
        Reset do_Auf;
        Set do_zu;
        WaitTime 0.5;
        
        ! handling_reset_counter();
        
        MoveL slide_handling1, v100, fine, tool0;
        
        dummy := setSafe(FALSE);
        WaitDI D652_10_DI10, 1;
        
        ! Move to belt
        MoveJ belt_sorting2, v400, fine, tool0;
        MoveL belt_sorting1, v400, fine, tool0;
		MoveJ belt_sorting, v400, fine, tool0;
        
        ! Put part into slide
        Reset do_Zu;
        Set do_Auf;
        WaitTime 0.5;
        
        if(not sorting_start_belt()) THEN
            abort_sorting;
        ENDIF
        
        ! move back to origin
        MoveJ belt_sorting1, v100, fine, tool0;
        MoveL belt_sorting2, v400, fine, tool0;
        MoveJ safety_45, v400, z100, tool0;
        
        dummy := setSafe(TRUE);
        
        moveToOrigin;
    ENDPROC
    
    PROC abort_sorting()
        MoveL belt_sorting1, v400, fine, tool0;
        MoveL belt_sorting2, v400, fine, tool0;
            
        dummy := setSafe(TRUE);
            
        MoveJ safety_45, v400, fine, tool0;
            
        moveToOrigin;
            
        MoveJ drop_box1, v400, z100, tool0;
        MoveL drop_box, v400, z0, tool0;
            
        WaitTime 0.2;
            
        Reset do_Zu;
        Set do_Auf;
        WaitTime 0.5;
            
        MoveL drop_box1, v400, z100, tool0;
        
        moveToOrigin;
            
        RETURN;
    ENDPROC


ENDMODULE