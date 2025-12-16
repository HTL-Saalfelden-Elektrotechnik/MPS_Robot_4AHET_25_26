MODULE user
    VAR bool dummy;
	CONST robtarget demo1 :=[[-37.66,384.13,588.69],[0.325256,-0.626832,0.628471,0.326059],[1,-1,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
	CONST robtarget demo12:=[[-37.66,384.13,477.55],[0.325228,-0.626811,0.628499,0.326073],[1,-1,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
	CONST robtarget demo2 :=[[-168.31,386.22,611.37],[0.325279,-0.626817,0.628504,0.326002],[1,-1,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
	CONST robtarget demo22:=[[-168.32,386.24,477.53],[0.325274,-0.626819,0.628497,0.326016],[1,-1,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
	TASK PERS tooldata mps_gripper:=[TRUE,[[19.1444,-0.0485131,159.842],[1,0,0,0]],[0.2,[0,0,0],[1,0,0,0],0,0,0]];
	TASK PERS wobjdata mps_schiene_2:=[FALSE,TRUE,"",[[0,0,0],[1,0,0,0]],[[181.648,-451.609,156.535],[0.692856,0.141225,-0.126493,-0.695705]]];
	TASK PERS tooldata mps2:=[TRUE,[[-539023,250370,210589],[1,0,0,0]],[0.3,[0,0,0],[1,0,0,0],0,0,0]];
	CONST robtarget origin:=[[266.15,0.03,749.32],[0.461703,3.01589E-05,0.887035,-2.9031E-05],[0,-1,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
	CONST robtarget safety_testing:=[[194.38,-433.69,561.10],[0.461556,-9.98679E-05,0.887111,-7.75619E-05],[-1,0,-1,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
	CONST robtarget testing_origin:=[[194.36,-299.83,661.42],[0.461504,-8.58549E-05,0.887138,-7.04485E-05],[-1,0,-1,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
	CONST robtarget testing:=[[191.71,-436.39,105.97],[0.617731,0.000120194,0.786389,-0.000499537],[-1,1,-2,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];

	PROC testing_take_part()
        TPWrite "Take part from testing";
        
        ! Open gripper
        Reset do_Zu;
        Set do_Auf;
        
        MoveL testing_origin, v1000, fine, tool0;
        MoveL safety_testing, v1000, fine, tool0;
        MoveL testing, v500, fine, tool0;
        
        Reset do_Auf;
        Set do_Zu;
        
        WaitTime 2;
        
        MoveL safety_testing, v500, fine, tool0;
        MoveL testing_origin, v1000, fine, tool0;
        MoveL origin, v1000, fine, tool0;
        
        TPWrite "Took part from testing, closing socket";
    ENDPROC
   
    PROC demo()
        ! move to starting point (optional)
        MoveL origin, v1000, fine, tool0;
        
        MoveL demo12, v1000, fine, tool0;
        
        ! Close Gripper
        Reset do_Auf;
        Set do_Zu;

        ! Move to second point
        MoveL demo1, v1000, fine, tool0;
        MoveL demo2, v1000, fine, tool0;
        MoveL demo22, v1000, fine, tool0;

        ! Open gripper
        Reset do_Zu;
        Set do_Auf;

        ! move to starting point
        MoveL demo2, v1000, fine, tool0;
        MoveL demo1, v1000, fine, tool0;
        
        MoveL origin, v1000, fine, tool0;

        TPWrite "Demo done";
    ENDPROC
    
    PROC moveToOrigin()
		MoveJ origin, v1000, z0, tool0;
        
        dummy := setOrigin(TRUE);
	ENDPROC
    
	PROC takeTesting()
        TPWrite "Taking part on testing";
        
		MoveL [[265.41,-261.25,677.52],[0.470964,-0.0386347,0.881165,-0.0157509],[-1,0,-1,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z15, tool0;
		MoveL [[73.33,-261.25,677.51],[0.470972,-0.0386563,0.881161,-0.0157133],[-1,0,-1,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, fine, tool0;
		Set do_Auf;
		WaitTime 0.5;
		Reset do_Auf;
		WaitTime 0.5;
		MoveJ [[73.33,-440.50,199.61],[0.471171,-0.00572951,0.882021,0.00187983],[-1,0,-2,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z0, tool0;
		MoveJ [[185.77,-444.71,179.53],[0.599925,-0.0212401,0.799564,0.0183378],[-1,1,-2,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z0, tool0;
		MoveL [[185.78,-444.71,108.94],[0.600043,-0.021302,0.799474,0.0183213],[-1,1,-2,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z0, tool0;
		MoveL [[193.02,-444.74,108.95],[0.600027,-0.021247,0.799489,0.0182769],[-1,1,-2,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, fine, tool0;
		Set do_Zu;
		WaitTime 0.5;
		Reset do_Zu;
		WaitTime 0.5;
		MoveL [[193.01,-444.74,575.52],[0.6,-0.0212249,0.799509,0.0182975],[-1,0,-1,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z0, tool0;
		MoveL [[193.01,301.77,583.32],[0.599978,-0.0212565,0.799525,0.0182967],[0,-1,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z0, tool0;

        dummy := checkSafety();
        WaitDI D652_10_DI9, 1;
        
		MoveL [[193.01,301.77,281.89],[0.599978,-0.021248,0.799525,0.0182889],[0,-2,1,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z0, tool0;
		MoveJ [[241.76,273.64,262.29],[0.455681,0.00287924,0.889073,0.043548],[0,-2,1,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z0, tool0;
		MoveL [[403.06,430.22,262.28],[0.45559,0.00286721,0.889112,0.043701],[0,-1,1,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z0, tool0;
		MoveL [[403.06,430.23,239.83],[0.455551,0.00283861,0.889125,0.0438342],[0,-1,1,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, fine, tool0;
		Set do_Auf;
		WaitTime 0.5;
		Reset do_Auf;
		WaitTime 0.5;
		MoveL [[403.05,430.24,257.93],[0.455547,0.00282884,0.889128,0.0438205],[0,-1,1,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, fine, tool0;
		Set do_Zu;
		WaitTime 0.5;
		Reset do_Zu;
		WaitTime 0.5;
        
        dummy := sorting_start_belt();
        
        MoveL [[176.66,411.65,264.66],[0.455621,0.0029393,0.889088,0.0438445],[0,-1,1,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, fine, tool0;
		MoveL [[176.64,411.58,590.68],[0.455558,0.00290587,0.889121,0.0438432],[0,-1,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z20, tool0;
		MoveL [[176.63,188.91,687.57],[0.455486,0.00289569,0.88916,0.0438028],[0,-1,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z20, tool0;
        
		moveToOrigin;
	ENDPROC

ENDMODULE