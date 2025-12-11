
MODULE user
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

ENDMODULE