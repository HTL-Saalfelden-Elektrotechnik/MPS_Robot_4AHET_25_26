
MODULE user
	CONST robtarget demo1 :=[[390, 300,430],[1.57634E-05,0,-1,7.6938E-06],[0,-1,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
	CONST robtarget demo12:=[[390, 300,200],[9.22253E-05,0,-1,3.28185E-05],[0,-1,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
	CONST robtarget demo2 :=[[390,-300,430],[5.23278E-05,0,-1,1.32244E-05],[-1,-1,-1,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
	CONST robtarget demo22:=[[390,-300,200],[4.89628E-05,0,-1,1.79639E-05],[-1,-1,-1,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];

	PROC testing_take_part()
        TPWrite "Take part from testing";
    ENDPROC
    
    PROC demo()
        TPWrite "TODO: Demo brumm brumm";
        ! move to starting point (optional)
        MoveL demo12, vmax, fine, tool0;
        
        ! Close Gripper
        Reset do_Auf;
        Set do_Zu;
        WaitDI di_Offen, 0;

        ! Move to second point
        MoveL demo1, vmax, fine, tool0;
        MoveL demo2, vmax, fine, tool0;
        MoveL demo22, vmax, fine, tool0;

        ! Open gripper
        Reset do_Zu;
        Set do_Auf;
        WaitDI di_Offen, 1;

        ! move to starting point
        MoveL demo2, vmax, fine, tool0;
        MoveL demo1, vmax, fine, tool0;
        MoveL demo12, vmax, fine, tool0;

        TPWrite "Brumm brumm done";
    ENDPROC

ENDMODULE