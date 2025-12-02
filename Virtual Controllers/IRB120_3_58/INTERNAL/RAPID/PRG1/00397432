MODULE TcpServer_MultiPort

    VAR socketdev sockTest;
    VAR socketdev sockDebug;
    VAR socketdev sockHandle;

    VAR socketdev clientSocket;
    VAR num status;
    VAR bool connOK;

    CONST string ROBOT_IP := "10.0.1.70";

    CONST num PORT_TESTING_DEBUG   := 520;
    CONST num PORT_PROCESSING_DEBUG  := 530;
    CONST num PORT_HANDLING_DEBUG := 540;

    PROC main()

        TPWrite "Starting TCP multi-port server on " + ROBOT_IP;

        ! --- Create 3 listening sockets ---
        SocketCreate sockTest;
        SocketCreate sockDebug;
        SocketCreate sockHandle;

        SocketBind sockTest,  ROBOT_IP, PORT_TESTING_DEBUG;
        SocketBind sockDebug, ROBOT_IP, PORT_PROCESSING_DEBUG;
        SocketBind sockHandle,ROBOT_IP, PORT_HANDLING_DEBUG;

        SocketListen sockTest;
        SocketListen sockDebug;
        SocketListen sockHandle;

        TPWrite "Listening:";
        TPWrite " - debug_testing on port 510";
        TPWrite " - debug_processing on port 520";
        TPWrite " - debug_handling on port 530";

        WHILE TRUE DO

            ! --- Check each socket one-by-one ---
            connOK := FALSE;

            ! Check TEST port
            status := SocketGetStatus(sockTest);
            IF status = 2 THEN      ! 2 = pending connection
                SocketAccept sockTest, clientSocket;
                connOK := TRUE;
                debug_testing;
            ENDIF

            ! Check DEBUG port
            status := SocketGetStatus(sockDebug);
            IF status = 2 THEN
                SocketAccept sockDebug, clientSocket;
                connOK := TRUE;
                debug_processing;
            ENDIF

            ! Check HANDLING port
            status := SocketGetStatus(sockHandle);
            IF status = 2 THEN
                SocketAccept sockHandle, clientSocket;
                connOK := TRUE;
                debug_handling;
            ENDIF

            ! Close if something connected
            IF connOK THEN
                SocketClose clientSocket;
            ELSE
                Path_20;  ! avoid CPU overload
            ENDIF

        ENDWHILE

    ENDPROC


    PROC debug_testing()
        TPWrite "Running grab_testing";
        ! --- Your logic here ---
    ENDPROC


    PROC debug_processing()
        TPWrite "Running debug_processing";
        ! --- Your logic here ---
    ENDPROC


    PROC  debug_handling()
        TPWrite "Running grab_handling";
        ! --- Your logic here ---
    ENDPROC

ENDMODULE
